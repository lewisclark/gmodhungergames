hook.Add("OnPlayerChat", "HG_ServerListMenuChatCmdCheck", function(ply, text)
	text = string.lower(text)

	if text == "!play" then
		HG.ServerListMenu()
		return true
	elseif text == "!store" then

		return true
	end
end)

local lastKeyPress = 0
hook.Add("Think", "HG_ServerListMenuKeyCheck", function()
	if input.IsKeyDown(KEY_F8) and lastKeyPress < CurTime() then
		lastKeyPress = CurTime() + .5
		HG.ServerListMenu()
	elseif input.IsKeyDown(KEY_F7) and lastKeyPress < CurTime() then
		lastKeyPress = CurTime() + .5
	end
end)