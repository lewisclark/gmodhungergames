util.AddNetworkString("HGHUB_GetServers")
HG.ServerListData = HG.ServerListData or {}

util.AddNetworkString("HG_CommitToServer")

local function getServerListData()
	HG.DB:RunQuery("SELECT * FROM servers;", function(query, status, data)
		HG.ServerListData = data
	end)
end
timer.Create("HG_UpdateServerListData", 3, 0, getServerListData)

net.Receive("HGHUB_GetServers", function(len, ply)
	net.Start("HGHUB_GetServers")
		net.WriteTable(HG.ServerListData)
	net.Send(ply)
end)

net.Receive("HG_CommitToServer", function(len, ply)
	local chosenServer = net.ReadInt(8)
	local serverData

	HG.Msg(ply:Nick() .. " requested to join HG server #" .. chosenServer)

	for _, v in ipairs(HG.ServerListData) do
		if v.rowid == chosenServer then
			serverData = v
		end
	end

	if not serverData then HG.Msg("Could not find a server matching the rowid " .. chosenServer) return end

	HG.DB:RunQuery("UPDATE players SET activeserver = '" .. chosenServer .. "' WHERE accountid = '" .. ply:AccountID() .. "';")

	HG.Msg(ply:Nick() .. " has now committed to HG #" .. chosenServer)

	net.Start("HG_CommitToServer")
		net.WriteString(serverData.serverip)
	net.Send(ply)
end)

getServerListData()