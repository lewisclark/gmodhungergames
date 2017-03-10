GM.Name = "secret shiz"
GM.Author = "Omni"
GM.Email = "N/A"
GM.Website = "http://omni.me.uk"

HG = HG or {}


hook.Add("SetupMove", "AutoHopAndStrafe", function(ply, move, cmd)
	if ply:GetVelocity():Length2D() > 0 and ply:WaterLevel() <= 0 then
	    if not ply:IsOnGround() then
	    	move:SetButtons(bit.band(move:GetButtons(), bit.bnot(IN_JUMP)))

	    	if cmd:GetMouseX() > 0 then
		    	move:SetSideSpeed(9999999)
		    elseif cmd:GetMouseX() < 0 then
		    	move:SetSideSpeed(-9999999)
		    end
	    end
	end
end)