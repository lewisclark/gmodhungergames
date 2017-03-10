// fonts
do
	surface.CreateFont("HG_HUDScrollFont", {
		font = "NEOTERICc",
		size = 27,
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

local dontDraw = {["CHudAmmo"] = true, ["CHudBattery"] = true, ["CHudCrosshair"] = true, ["CHudDamageIndicator"] = true, ["CHudHealth"] = true, ["CHudSecondaryAmmo"] = true}

function GM:HUDShouldDraw(name)
	if dontDraw[name] then return false end

	return true
end


local i, scrollMessages = 1, {"Welcome to ElysianGaming Hunger Games!", "Press F8 to view and connect to a Hunger Games server."}

surface.SetFont("HG_HUDScrollFont")
local textW = surface.GetTextSize(scrollMessages[i])
local textX = -textW - 10

hook.Add("HUDPaint", "HG_HUDSrollBar", function()
	local scrollBarH = ScrH() / 29

	draw.RoundedBox(0, 0, 0, ScrW(), scrollBarH, Color(40, 40, 40, 230))
	
	surface.SetFont("HG_HUDScrollFont")
	surface.SetTextPos(textX, ScrH() / 800)
	surface.SetTextColor(255, 255, 255, 255)
	surface.DrawText(scrollMessages[i])

	if textX > ScrH() + (textW * 2) then
		i = i + 1

		if i > #scrollMessages then i = 1 end

		surface.SetFont("HG_HUDScrollFont")
		textW = surface.GetTextSize(scrollMessages[i])
		textX = -textW - 10
	else
		textX = textX + 1
	end
end)