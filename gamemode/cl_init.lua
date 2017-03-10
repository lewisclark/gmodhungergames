HG = HG or {}

include("shared.lua")
include("cl_input.lua")
include("cl_servermanager.lua")
include("cl_scoreboard.lua")
include("cl_hud.lua")

function HG.Notify(msg)
	chat.AddText(Color(255, 255, 255), msg)
end

net.Receive("HG_Notify", function()
	HG.Notify(net.ReadString())
end)