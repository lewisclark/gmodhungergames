hook.Add("PlayerAuthed", "HG_CreateRow", function(ply)
	HG.DB:RunQuery("INSERT INTO players VALUES ('" .. ply:AccountID() .. "', '0', '0', '0', '0') ON DUPLICATE KEY UPDATE `totalgames` = `totalgames`;")
end)