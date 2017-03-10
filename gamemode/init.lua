HG = HG or {}

require("mysqloo")
HG.DB = mysqloo.CreateDatabase("omni.me.uk", "no", "no", "no")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_input.lua")
AddCSLuaFile("cl_servermanager.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_hud.lua")

include("shared.lua")
include("sv_servermanager.lua")
include("sv_datamanager.lua")

RunConsoleCommand("sv_sticktoground", "0")
RunConsoleCommand("sv_gravity", "800")
RunConsoleCommand("sv_airaccelerate", "150")
RunConsoleCommand("sv_accelerate", "8")
RunConsoleCommand("sv_friction", "6")
RunConsoleCommand("sv_stopspeed", "75")

util.AddNetworkString("HG_Notify")

function GM:CanPlayerSuicide() return false end
function GM:GetFallDamage() return 0 end
function GM:PlayerShouldTakeDamage() return false end
function GM:PlayerSwitchWeapon() return false end

function HG.Msg(...)
	MsgC(Color(50, 255, 50), ..., "\n")
end

function HG.Notify(ply, msg)
	net.Start("HG_Notify")
		net.WriteString(msg)
	net.Send(ply)
end

function GM:PlayerSpawn(ply)
	ply:SetJumpPower(280)
	ply:SetRunSpeed(250)
	ply:SetWalkSpeed(250)
	ply:SetCanWalk(false)
	ply:SetNoCollideWithTeammates(true)
end