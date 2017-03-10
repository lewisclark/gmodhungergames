local scoreboard = {}

// fonts
do
	surface.CreateFont("HG_ScoreboardGeneralFont", {
		font = "NEOTERICc",
		size = 32,
		weight = 300,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	})
end

local latencyMat1 = Material("eghg/scoreboard/latency-1.png")
local latencyMat2 = Material("eghg/scoreboard/latency-2.png")
local latencyMat3 = Material("eghg/scoreboard/latency-3.png")
local latencyMat4 = Material("eghg/scoreboard/latency-4.png")
local speakerMatUnmuted = Material("eghg/scoreboard/speaker-unmuted.png")
local speakerMatMuted = Material("eghg/scoreboard/speaker-muted.png")

function scoreboard:ShowScoreboard()
	scoreboard.frame = IsValid(scoreboard.frame) and scoreboard.frame or vgui.Create("DFrame")
	scoreboard.frame:SetVisible(false)
	scoreboard.frame:ShowCloseButton(false)
	scoreboard.frame:SetTitle("")

	local yPos = (ScrH() / 1.4) * 2

	local scrW, scrH = ScrW(), ScrH()
	scoreboard.rowY = 0

	local frameW, frameH = scrW / 3.6, scrH / 1.4

	if frameW < 355.55555555556 then frameW = 355.55555555556 end
	if frameH < 514.28571428571 then frameH = 514.28571428571 end

	scoreboard.frame:SetSize(frameW, frameH)
	scoreboard.frame.Paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, Color(230, 230, 230))
		draw.RoundedBox(0, 3, 3, w - 6, h - 6, Color(40, 40, 40))

		local textW, textH = draw.SimpleText("ElysianGaming Hunger Games", "HG_ScoreboardGeneralFont", w / 2, h / 27, Color(255, 255, 255), 1, 1)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawLine(w / 4, h / 12.5, w / 1.32, h / 12.5)
	end

	hook.Add("Think", "HG_ScoreboardAnim", function()
		scoreboard.frame:SetVisible(true)
		yPos = Lerp(4 * FrameTime(), yPos, (ScrH() / 2) - (frameH / 2))
		scoreboard.frame:SetPos((ScrW() / 2) - (frameW / 2), yPos)
	end)

	gui.EnableScreenClicker(true)

	local panel = vgui.Create("DScrollPanel", scoreboard.frame)
	panel:SetSize(scoreboard.frame:GetWide() - 20, scoreboard.frame:GetTall() / 1.135)
	panel:SetPos(10, scoreboard.frame:GetTall() / 10)
	panel.Paint = function() end
	panel:GetVBar():SetSize(0, 0)

	function scoreboard:CreatePlayerRow(ply)
		local row = vgui.Create("DButton", panel)
		row:SetSize(panel:GetWide(), 36)
		row:SetPos(0, scoreboard.rowY)
		row:SetText("")
		row.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(230, 230, 230))
		end
		row.OnMousePressed = function(self, keyCode) 
			if keyCode == MOUSE_RIGHT then
				scoreboard.dropdown = vgui.Create("DMenu", ScoreboardScrollPanel)
				scoreboard.dropdown:SetPos(input.GetCursorPos())
				scoreboard.dropdown.Paint = function(self, w, h) 
					draw.RoundedBox(2, 0, 0, w, h, Color(210, 210, 210, 255))
				end

				scoreboard.dropdown:AddOption(ply:Nick(), function() SetClipboardText(ply:Nick()) end)
				scoreboard.dropdown:AddSpacer()
				scoreboard.dropdown:AddOption("Invite to party", function() end)
				scoreboard.dropdown:AddSpacer()
				scoreboard.dropdown:AddOption("Open Profile", function() ply:ShowProfile() end)
				scoreboard.dropdown:AddOption("Copy SteamID", function() SetClipboardText(ply:SteamID()) end)
				scoreboard.dropdown:AddOption("Copy SteamID64", function() SetClipboardText(ply:SteamID64()) end)
				scoreboard.dropdown:AddOption("Copy Profile URL", function() SetClipboardText("http://steamcommunity.com/profiles/" .. ply:SteamID64()) end)
			end
		end

		local nameLabel = vgui.Create("DLabel", panel)
		nameLabel:SetText(ply:Nick())
		nameLabel:SetFont("HG_ScoreboardGeneralFont")
		nameLabel:SizeToContents()
		nameLabel:SetPos(6, scoreboard.rowY)
		nameLabel:SetTextColor(Color(40, 40, 40))

		local latencyImg = vgui.Create("DImage", panel)
		latencyImg:SetPos(panel:GetWide() - 32, scoreboard.rowY + 6)
		latencyImg:SetSize(24, 24)

		local ping = ply:Ping() or 999

		if ping <= 100 then
			latencyImg:SetMaterial(latencyMat4)
		elseif ping <= 200 then
			latencyImg:SetMaterial(latencyMat3)
		elseif ping <= 300 then
			latencyImg:SetMaterial(latencyMat2)
		else
			latencyImg:SetMaterial(latencyMat1)
		end

		local isMuted = vgui.Create("DImageButton", panel)
		isMuted:SetPos(panel:GetWide() / 1.29, scoreboard.rowY + 1)
		isMuted:SetSize(32, 32)
		isMuted.DoClick = function()
			if ply == LocalPlayer() then return end

			ply:SetMuted(not ply:IsMuted())
			isMuted:SetMaterial(ply:IsMuted() and speakerMatMuted or speakerMatUnmuted)
		end
		isMuted:SetMaterial(ply:IsMuted() and speakerMatMuted or speakerMatUnmuted)

		scoreboard.rowY = scoreboard.rowY + 39
	end

	for _, ply in ipairs(player.GetAll()) do
		scoreboard:CreatePlayerRow(ply)
	end

	function scoreboard:HideScoreboard()
		gui.EnableScreenClicker(false)

		hook.Add("Think", "HG_ScoreboardAnim", function()
			yPos = Lerp(5.5 * FrameTime(), yPos, scoreboard.frame:GetTall() * 2)
			scoreboard.frame:SetPos((ScrW() / 2) - (frameW / 2), yPos)

			if IsValid(scoreboard.dropdown) then
				scoreboard.dropdown:Remove()
			end

			if math.floor(yPos) >= ScrH() then
				hook.Remove("Think", "HG_ScoreboardAnim")

				if IsValid(scoreboard.frame) then
					scoreboard.frame:Remove()
				end
			end
		end)
	end
end

function GM:ScoreboardShow()
	scoreboard:ShowScoreboard()
end

function GM:ScoreboardHide()
	if scoreboard.frame:IsVisible() and scoreboard.HideScoreboard then
		scoreboard:HideScoreboard()
	end
end