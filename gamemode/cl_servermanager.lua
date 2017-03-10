HG.ServerListData = HG.ServerListData or {}
local frame, lstServerListData, chosenServer
local isMenuOpen = false

// fonts
do
	surface.CreateFont("HG_ServerListFont", {
		font = "NEOTERICc",
		size = 19,
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

	surface.CreateFont("HG_CloseXButtonFont", {
		font = "NEOTERICc",
		size = 24,
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

	surface.CreateFont("HG_ServerListTitleFont", {
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

	surface.CreateFont("HG_ServerListSubTitleFont", {
		font = "NEOTERICc",
		size = 26,
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

function loadServerListing()
	if not IsValid(lstServerListData) then return end

	lstServerListData:Clear()

	for k, v in ipairs(HG.ServerListData) do
		local partyType = v.partytype == 0 and "Solo" or "Parties of " .. v.partytype

		local line = lstServerListData:AddLine("HG #" .. v.rowid, partyType, v.aliveplayers .. "/" .. v.maxplayers, tobool(v.active) and "Started" or "Waiting")

		for i = 1, 4 do // kinda hacky way to set font for all columns
			line.Columns[i]:SetFont("HG_ServerListFont")
		end

		line.Paint = function(self, w, h)
			local color = tobool(v.active) and Color(255, 50, 50) or Color(50, 255, 50)

			draw.RoundedBox(0, 0, 0, w, h, color)
		end
	end
end

net.Receive("HGHUB_GetServers", function()
	HG.ServerListData = net.ReadTable()
	loadServerListing()
end)

function HG.ServerListMenu()
	if isMenuOpen then
		if IsValid(frame) then
			frame:Remove()
		end

		isMenuOpen = false

		return
	end

	isMenuOpen = true

	net.Start("HGHUB_GetServers")
	net.SendToServer()

	local w, h = ScrW(), ScrH()
	local frameW, frameH = w / 3, h / 2

	if frameW < 453.33333333333 then frameW = 453.33333333333 end
	if frameH < 384 then frameH = 384 end

	frame = vgui.Create("DFrame")
	frame:SetTitle("")
	frame:SetSize(frameW, frameH)
	frame:Center()
	frame:MakePopup()
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame.Paint = function(self, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40))

		draw.SimpleText("Hunger Games Server List", "HG_ServerListTitleFont", w / 2, h / 24, Color(255, 255, 255), 1, 1)

		draw.SimpleText("Name", "HG_ServerListSubTitleFont", w / 14.5, h / 8.2, Color(255, 255, 255), 1, 1)
		draw.SimpleText("Party Type", "HG_ServerListSubTitleFont", w / 3.3, h / 8.2, Color(255, 255, 255), 1, 1)
		draw.SimpleText("Players", "HG_ServerListSubTitleFont", w / 1.77, h / 8.2, Color(255, 255, 255), 1, 1)
		draw.SimpleText("Status", "HG_ServerListSubTitleFont", w / 1.22, h / 8.2, Color(255, 255, 255), 1, 1)
	end
	frame.OnClose = function()
		if timer.Exists("ConnectToHGServer") then
			timer.Destroy("ConnectToHGServer")
			HG.Notify("Cancelled joining server " .. chosenServer)
		end
	end
	frame.OnRemove = frame.OnClose // frame.OnClose is not called when the frame is removed, so we need to use this too

	local btnClose = vgui.Create("DButton", frame)
	btnClose:SetSize(frameW / 14, frameH / 13)
	btnClose:SetPos(frameW / 1.089, frameH / 81)
	btnClose:SetFont("HG_CloseXButtonFont")
	btnClose:SetText("X")
	btnClose:SetTextColor(Color(255, 60, 60))
	btnClose.Paint = function() end
	btnClose.DoClick = function()
		frame:Close()
	end

	local btnRefreshListing = vgui.Create("DButton", frame)
	btnRefreshListing:SetSize(frameW / 7, frameH / 13)
	btnRefreshListing:SetPos(frameW / 90, frameH / 81)
	btnRefreshListing:SetFont("HG_ServerListFont")
	btnRefreshListing:SetText("Refresh")
	btnRefreshListing.Paint = function(self, w, h)
		draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255))
	end
	btnRefreshListing.DoClick = function()
		net.Start("HGHUB_GetServers")
		net.SendToServer()
	end

	lstServerListData =  vgui.Create("DListView", frame)
	lstServerListData:SetSize(frameW - 20, frameH)
	lstServerListData:SetPos(0, frameH / 6)
	lstServerListData:CenterHorizontal()
	lstServerListData:SetMultiSelect(false)
	lstServerListData:AddColumn("Name"):SetFixedWidth(math.Round(frameW / 5.3))
	lstServerListData:AddColumn("Type"):SetFixedWidth(math.Round(frameW / 3.4))
	lstServerListData:AddColumn("Players Alive"):SetFixedWidth(math.Round(frameW / 3.8))
	lstServerListData:AddColumn("Status"):SetFixedWidth(999)
	lstServerListData:SetHideHeaders(true)
	lstServerListData:SetDataHeight(25)
	lstServerListData.Paint = function() end
	lstServerListData.DoDoubleClick = function(self, lineId, line)
		if tobool(HG.ServerListData[lineId].active) then
			HG.Notify(line:GetColumnText(1) .. " has already started.")
			return
		elseif HG.ServerListData[lineId].aliveplayers >= HG.ServerListData[lineId].maxplayers then
			HG.Notify(line:GetColumnText(1) .. " is currently full.")
			return
		end

		chosenServer = line:GetColumnText(1)

		HG.Notify("Connecting to " .. chosenServer .. " in 10 seconds, close the menu to cancel.")

		timer.Create("ConnectToHGServer", 1, 10, function()
			HG.Notify("Connecting to " .. chosenServer .. " in " .. tostring(timer.RepsLeft("ConnectToHGServer")) .. " seconds, close the menu to cancel.")

			if timer.RepsLeft("ConnectToHGServer") == 0 then
				net.Start("HG_CommitToServer")
					net.WriteInt(HG.ServerListData[lineId].rowid, 8)
				net.SendToServer()
			end
		end)
	end
end

net.Receive("HG_CommitToServer", function()
	RunConsoleCommand("connect", net.ReadString())
end)