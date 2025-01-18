
AddCSLuaFile()

ENT.Base = "base_nextbot"
-- v (Stuff you can customize) v
-- lines ~36-54: attack distance, and attack power
-- line ~416: acceleration
-- lines ~504-524: damage setup

-- I made every sound ENT a table so you could add more than one sound each. I wouldn't try chaseMusic, because I don't know what will happen.
-- you can also use ctrl+f to search for the terms listed above.
ENT.PhysgunDisabled = true
ENT.AutomaticFrameAdvance = true
-- REMINDER: sounds MUST be at a bitrate of 44100 HZ. If they are not, then the sound will not play.
ENT.JumpSound = {
	Sound("freemankiller/nextbot/617-lookup01.mp3"),
	Sound("freemankiller/nextbot/617-lookup02.mp3"),
}
ENT.JumpHighSound = {
	Sound("freemankiller/nextbot/617-pigstick01.mp3"),
	Sound("freemankiller/nextbot/617-pigstick02.mp3"),
	Sound("freemankiller/nextbot/617-pigstick03.mp3"),
	Sound("freemankiller/nextbot/617-pigstick04.mp3"),
}
ENT.TauntSounds = {
	Sound("freemankiller/nextbot/knife_stab.mp3"),
}
ENT.ScareSounds = {
	Sound("freemankiller/nextbot/617-iseeyou01.mp3"),
	Sound("freemankiller/nextbot/617-iseeyou02.mp3"),
	Sound("freemankiller/nextbot/617-iseeyou03.mp3"),
	Sound("freemankiller/nextbot/617-imhere01.mp3"),
	Sound("freemankiller/nextbot/617-imhere02.mp3"),
	Sound("freemankiller/nextbot/617-imhere03.mp3"),
	Sound("freemankiller/nextbot/617-imhere04.mp3"),
	Sound("freemankiller/nextbot/617-overhere01.mp3"),
	Sound("freemankiller/nextbot/617-overhere02.mp3"),
	Sound("freemankiller/nextbot/617-overhere03.mp3"),
}
ENT.ScareSoundsClose = {
	Sound("freemankiller/nextbot/617-pigstick01.mp3"),
	Sound("freemankiller/nextbot/617-pigstick02.mp3"),
	Sound("freemankiller/nextbot/617-pigstick03.mp3"),
	Sound("freemankiller/nextbot/617-pigstick04.mp3"),
	Sound("freemankiller/nextbot/617-turnaround01.mp3"),
	Sound("freemankiller/nextbot/617-turnaround02.mp3"),
}
ENT.HurtSounds = {
	Sound("freemankiller/nextbot/617-303pain01.mp3"),
	Sound("freemankiller/nextbot/617-303pain02.mp3"),
	Sound("freemankiller/nextbot/617-303pain03.mp3"),
	Sound("freemankiller/nextbot/617-303pain04.mp3"),
	Sound("freemankiller/nextbot/617-303pain05.mp3"),
	Sound("freemankiller/nextbot/617-303pain06.mp3"),
	Sound("freemankiller/nextbot/617-303pain07.mp3"),
	Sound("freemankiller/nextbot/617-303pain08.mp3"),
}
ENT.DeathSounds = {
	Sound("freemankiller/nextbot/617-death01.mp3"),
	Sound("freemankiller/nextbot/617-death02.mp3"),
	Sound("freemankiller/nextbot/617-death03.mp3"),
}
ENT.RagdollBreakSounds = {
	Sound("physics/body/body_medium_break2.wav"),
	Sound("physics/body/body_medium_break3.wav"),
	Sound("physics/body/body_medium_break4.wav"),
}
local chaseMusic = Sound("freemankiller/nextbot/617-auraloop01.mp3")

local workshopID = "2878878136" -- REPLACE THIS WITH UPLOADED ADDON ID LATER ON!!!!!!!!!!!!!!!!!!!!!

local IsValid = IsValid

local lastSpawn = nil

if SERVER then -- SERVER --
	local npc_hidden_FMK_can_retreat =
	CreateConVar("npc_hidden_FMK_can_retreat", 1, FCVAR_NONE,
	"Rare behaviour of The Hidden doing a short retreat when damaged. Higher chance on low health.")
	
	local npc_hidden_FMK_regen_per_sec =
	CreateConVar("npc_hidden_FMK_regen_per_sec", 5, FCVAR_NONE,
	"Health regenerated per second.")
	
	local npc_hidden_FMK_ragdoll_messup =
	CreateConVar("npc_hidden_FMK_ragdoll_messup", 0, FCVAR_NONE,
	"Mess up ragdolls in Hidden's path when hunting.")
	
	local npc_hidden_FMK_antistuck =
	CreateConVar("npc_hidden_FMK_antistuck", 1, FCVAR_NONE,
	"Antistuck. Disable if the map is very simplistic and hidden tends to teleport.")
	
	local npc_hidden_FMK_legacy_model =
	CreateConVar("npc_hidden_FMK_legacy_model", 0, FCVAR_NONE,
	"Replaces death model with HL2 one. Enable if any mods cause problems with it.")
	
	local npc_hidden_FMK_respawn =
	CreateConVar("npc_hidden_FMK_respawn", 0, FCVAR_NONE,
	"If he can respawn after death. 1 = enabled, 0 = disabled.")
	
	local npc_hidden_FMK_screenshake =
	CreateConVar("npc_hidden_FMK_screenshake", 1, FCVAR_NONE,
	"Move screen during scare. 1 = enabled, 0 = disabled.")
	
	local npc_hidden_FMK_damage =
	CreateConVar("npc_hidden_FMK_damage", 1e8, FCVAR_NONE,
	"Damage dealt by each blow (customize delay by npc_hidden_FMK_attack_interval). Default is 1e8, translated 100000000, pretty much insta-kill.")
	
	local npc_hidden_FMK_desired_speed =
	CreateConVar("npc_hidden_FMK_desired_speed", 500, FCVAR_NONE,
	"Desired maximum speed. Default 500. Randomized by a value + or - between 0 and 20. +150 if singleplayer due to higher player walkspeed.")
	
	local npc_hidden_FMK_targeted_by_npcs =
	CreateConVar("npc_hidden_FMK_targeted_by_npcs", 1, FCVAR_NONE,
	"If Hidden will align nearby NPCs to be hostile towards him. 1 = enabled, 0 = disabled. If you have a weak PC and spawn many NPCs, disabiling this might improve performance.")
	
	local npc_hidden_FMK_health =
	CreateConVar("npc_hidden_FMK_health", 617, FCVAR_NONE,
	"Health the hidden spawns at. It will not regen beyond this amount.")
	
	local npc_hidden_FMK_huntsound_interval =
	CreateConVar("npc_hidden_FMK_huntsound_interval", 7, FCVAR_NONE,
	"Delay in seconds between announcing himself to a victim. Added by a random value between 0 and 2.")
	
	local npc_hidden_FMK_huntsound_distance =
	CreateConVar("npc_hidden_FMK_huntsound_distance", 1250, FCVAR_NONE,
	"Hidden will announce himself when within this range (if interval is not on cooldown).")
	
	local npc_hidden_FMK_regen_on_attack =
	CreateConVar("npc_hidden_FMK_regen_on_attack", 145, FCVAR_NONE,
	"Health the hidden regenerates on attack (except prop smashing). Will never go over his health (also configureable). Set to 0 to disable.")
	
	local npc_hidden_FMK_grenade_chance =
	CreateConVar("npc_hidden_FMK_grenade_chance", 10, FCVAR_NONE,
	"Chance of the hidden spawning grenade at victim. Insert value from 0 (never) to 100 (always). Delay (interval) is a seperate command.")
	
	local npc_hidden_FMK_grenade_interval =
	CreateConVar("npc_hidden_FMK_grenade_interval", 15, FCVAR_NONE,
	"Time in seconds until another grenade attempt. Chance is a seperate command.")
	
	local npc_hidden_FMK_grenade_throw_sound =
	CreateConVar("npc_hidden_FMK_grenade_throw_sound", 1, FCVAR_NONE,
	"If a sound should be made if a grenade is thrown. 1 = True (default), 0 = False")
	
	local npc_hidden_FMK_acquire_distance =
	CreateConVar("npc_hidden_FMK_acquire_distance", 6170, FCVAR_NONE,
	"The maximum distance at which hidden_FMK will chase a target.")
	
	local npc_hidden_FMK_spawn_protect =
	CreateConVar("npc_hidden_FMK_spawn_protect", 0, FCVAR_NONE,
		"If set to 1, hidden_FMK will not target players or hide within 100 units of \z
	a spawn point.")
	
	local npc_hidden_FMK_attack_distance =
	CreateConVar("npc_hidden_FMK_attack_distance", 80, FCVAR_NONE,
	"The reach of hidden_FMK's attack.")
	
	local npc_hidden_FMK_attack_interval =
	CreateConVar("npc_hidden_FMK_attack_interval", 0.2, FCVAR_NONE,
	"The delay between hidden_FMK's attacks.")
	
	local npc_hidden_FMK_attack_force =
	CreateConVar("npc_hidden_FMK_attack_force", 300, FCVAR_NONE,
		"The physical force of hidden_FMK's attack. Higher values throw things \z
	farther.")
	
	local npc_hidden_FMK_smash_props =
	CreateConVar("npc_hidden_FMK_smash_props", 1, FCVAR_NONE,
	"If set to 1, hidden_FMK will punch through any props placed in their way.")
	
	local npc_hidden_FMK_allow_jump =
	CreateConVar("npc_hidden_FMK_allow_jump", 1, FCVAR_NONE,
	"If set to 1, hidden_FMK will be able to jump.")
	
	local npc_hidden_FMK_shut_up =
	CreateConVar("npc_hidden_FMK_shut_up", 0, FCVAR_NONE,
	"If set to 1, the hidden is mute and cannot talk. Set 0 to disable.")
	
	local npc_hidden_FMK_hiding_scan_interval =
	CreateConVar("npc_hidden_FMK_hiding_scan_interval", 10, FCVAR_NONE,
		"hidden_FMK will only seek out hiding places every X seconds. This can be an \z
		expensive operation, so it is not recommended to lower this too much. \z
		However, if distant hidden_FMKs are not hiding from you quickly enough, you \z
	may consider lowering this a small amount.")
	
	local npc_hidden_FMK_hiding_repath_interval =
	CreateConVar("npc_hidden_FMK_hiding_repath_interval", 1, FCVAR_NONE,
	"The path to hidden_FMK's hiding spot will be redetermined every X seconds.")
	
	local npc_hidden_FMK_chase_repath_interval =
	CreateConVar("npc_hidden_FMK_chase_repath_interval", 0.1, FCVAR_NONE,
		"The path to and position of hidden_FMK's target will be redetermined every \z
	X seconds.")
	
	local npc_hidden_FMK_expensive_scan_interval =
	CreateConVar("npc_hidden_FMK_expensive_scan_interval", 1, FCVAR_NONE,
		"Slightly expensive operations (distance calculations and entity \z
	searching) will occur every X seconds.")
	
	local npc_hidden_FMK_force_download =
	CreateConVar("npc_hidden_FMK_force_download", 1, FCVAR_ARCHIVE,
		"If set to 1, clients will be forced to download hidden_FMK resources \z
		(restart required after changing).\n\z
		WARNING: If this option is disabled, clients will be unable to see or \z
	hear hidden_FMK!")
	
	-- So we don't spam voice TOO much.
	local TAUNTKILL_INTERVAL = 0.35
	local HURT_SOUND_INTERVAL = 0.8
	local PATH_INFRACTION_TIMEOUT = 5
	
	if npc_hidden_FMK_force_download:GetBool() then
		resource.AddWorkshop(workshopID)
	end
	
	util.AddNetworkString("hidden_FMK_nag")
	util.AddNetworkString("hidden_FMK_navgen")
	
	-- Pathfinding is only concerned with static geometry anyway.
	local trace = {
		mask = MASK_SOLID_BRUSHONLY
	}
	
	local function isPointNearSpawn(point, distance)
		--TODO: Is this a reliable standard??
		if not GAMEMODE.SpawnPoints then return false end
		
		local distanceSqr = distance * distance
		for _, spawnPoint in pairs(GAMEMODE.SpawnPoints) do
			if not IsValid(spawnPoint) then continue end
			
			if point:DistToSqr(spawnPoint:GetPos()) <= distanceSqr then
				return true
			end
		end
		
		return false
	end
	
	local function isPositionExposed(pos)
		local curTime = CurTime()
		for _, ply in pairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() and ply:IsLineOfSightClear(pos) then
				-- This spot can be seen!
				return true
			end
		end
		
		return false
	end
	
	local VECTOR_hidden_FMK_HEIGHT = Vector(0, 0, 96)
	local function isPointSuitableForHiding(point)
		trace.start = point
		trace.endpos = point + VECTOR_hidden_FMK_HEIGHT
		local tr = util.TraceLine(trace)
		
		return (not tr.Hit)
	end
	
	local g_hidingSpots = nil
	local function buildHidingSpotCache()
		local rStart = SysTime()
		
		g_hidingSpots = {}
		
		-- Look in every area on the navmesh for usable hiding places.
		-- Compile them into one nice list for lookup.
		local areas = navmesh.GetAllNavAreas()
		local goodSpots, badSpots = 0, 0
		for _, area in pairs(areas) do
			for _, hidingSpot in pairs(area:GetHidingSpots()) do
				if isPointSuitableForHiding(hidingSpot) then
					g_hidingSpots[goodSpots + 1] = {
						pos = hidingSpot,
						nearSpawn = isPointNearSpawn(hidingSpot, 200),
						occupant = nil
					}
					goodSpots = goodSpots + 1
					else
					badSpots = badSpots + 1
				end
			end
		end
		
		print(string.format("npc_hidden_FMK: found %d suitable (%d unsuitable) hiding \z
			places in %d areas over %.2fms!", goodSpots, badSpots, #areas,
		(SysTime() - rStart) * 1000))
	end
	
	local ai_ignoreplayers = GetConVar("ai_ignoreplayers")
	local function isValidTarget(ent)
		-- Ignore non-existant entities.
		if not IsValid(ent) then return false end
		
		-- Ignore dead players (or all players if `ai_ignoreplayers' is 1)
		if ent:IsPlayer() then
			if ai_ignoreplayers:GetBool() then return false end
			return ent:Alive()
		end
		
		-- Ignore dead NPCs, other hidden_FMKs, and dummy NPCs.
		local class = ent:GetClass()
		return (ent:IsNPC()
			and ent:Health() > 0
			and class ~= "npc_hidden_FMK"
		and not class:find("bullseye"))
	end
	
	hook.Add("PlayerSpawnedNPC", "hidden_FMKMissingNavmeshNag", function(ply, ent)
		if not IsValid(ent) then return end
		if ent:GetClass() ~= "npc_hidden_FMK" then return end
		if navmesh.GetNavAreaCount() > 0 then return end
		
		-- Try to explain why hidden_FMK isn't working.
		net.Start("hidden_FMK_nag")
		net.Send(ply)
	end)
	
	local generateStart = 0
	local function navEndGenerate()
		local timeElapsedStr = string.NiceTime(SysTime() - generateStart)
		
		if not navmesh.IsGenerating() then
			print("npc_hidden_FMK: Navmesh generation completed in " .. timeElapsedStr)
			else
			print("npc_hidden_FMK: Navmesh generation aborted after " .. timeElapsedStr)
		end
		
		-- Turn this back off.
		RunConsoleCommand("developer", "0")
	end
	
	local DEFAULT_SEEDCLASSES = {
		-- Source games in general
		"info_player_start",
		
		-- Garry's Mod (Obsolete)
		"gmod_player_start", "info_spawnpoint",
		
		-- Half-Life 2: Deathmatch
		"info_player_combine", "info_player_rebel", "info_player_deathmatch",
		
		-- Counter-Strike (Source & Global Offensive)
		"info_player_counterterrorist", "info_player_terrorist",
		
		-- Day of Defeat: Source
		"info_player_allies", "info_player_axis",
		
		-- Team Fortress 2
		"info_player_teamspawn",
		
		-- Left 4 Dead (1 & 2)
		"info_survivor_position",
		
		-- Portal 2
		"info_coop_spawn",
		
		-- Age of Chivalry
		"aoc_spawnpoint",
		
		-- D.I.P.R.I.P. Warm Up
		"diprip_start_team_red", "diprip_start_team_blue",
		
		-- Dystopia
		"dys_spawn_point",
		
		-- Insurgency
		"ins_spawnpoint",
		
		-- Pirates, Vikings, and Knights II
		"info_player_pirate", "info_player_viking", "info_player_knight",
		
		-- Obsidian Conflict (and probably some generic CTF)
		"info_player_red", "info_player_blue",
		
		-- Synergy
		"info_player_coop",
		
		-- Zombie Master
		"info_player_zombiemaster",
		
		-- Zombie Panic: Source
		"info_player_human", "info_player_zombie",
		
		-- Some maps start you in a cage room with a start button, have building
		-- interiors with teleportation doors, or the like.
		-- This is so the navmesh will (hopefully) still generate correctly and
		-- fully in these cases.
		"info_teleport_destination",
	}
	
	local function addEntitiesToSet(set, ents)
		for _, ent in pairs(ents) do
			if IsValid(ent) then
				set[ent] = true
			end
		end
	end
	
	local NAV_GEN_STEP_SIZE = 25
	local function navGenerate()
		local seeds = {}
		
		-- Add a bunch of the usual classes as walkable seeds.
		for _, class in pairs(DEFAULT_SEEDCLASSES) do
			addEntitiesToSet(seeds, ents.FindByClass(class))
		end
		
		-- For gamemodes that define their own spawnpoint entities.
		addEntitiesToSet(seeds, GAMEMODE.SpawnPoints or {})
		
		if next(seeds, nil) == nil then
			print("npc_hidden_FMK: Couldn't find any places to seed nav_generate")
			return false
		end
		
		for seed in pairs(seeds) do
			local pos = seed:GetPos()
			pos.x = NAV_GEN_STEP_SIZE * math.Round(pos.x / NAV_GEN_STEP_SIZE)
			pos.y = NAV_GEN_STEP_SIZE * math.Round(pos.y / NAV_GEN_STEP_SIZE)
			
			-- Start a little above because some mappers stick the
			-- teleport destination right on the ground.
			trace.start = pos + vector_up
			trace.endpos = pos - vector_up * 16384
			local tr = util.TraceLine(trace)
			
			if not tr.StartSolid and tr.Hit then
				print(string.format("npc_hidden_FMK: Adding seed %s at %s", seed, pos))
				navmesh.AddWalkableSeed(tr.HitPos, tr.HitNormal)
				else
				print(string.format("npc_hidden_FMK: Couldn't add seed %s at %s", seed,
				pos))
			end
		end
		
		-- The least we can do is ensure they don't have to listen to this noise.
		for _, hidden_FMK in pairs(ents.FindByClass("npc_hidden_FMK")) do
			hidden_FMK:Remove()
		end
		
		-- This isn't strictly necessary since we just added EVERY spawnpoint as a
		-- walkable seed, but I dunno. What does it hurt?
		navmesh.SetPlayerSpawnName(next(seeds, nil):GetClass())
		
		navmesh.BeginGeneration()
		
		if navmesh.IsGenerating() then
			generateStart = SysTime()
			hook.Add("ShutDown", "hidden_FMKNavGen", navEndGenerate)
			else
			print("npc_hidden_FMK: nav_generate failed to initialize")
			navmesh.ClearWalkableSeeds()
		end
		
		return navmesh.IsGenerating()
	end
	
	concommand.Add("npc_hidden_FMK_learn", function(ply, cmd, args)
		if navmesh.IsGenerating() then
			return
		end
		
		-- Rcon or single-player only.
		local isConsole = (ply:EntIndex() == 0)
		if game.SinglePlayer() then
			print("npc_hidden_FMK: Beginning nav_generate requested by " .. ply:Name())
			
			-- Disable expensive computations in single-player. hidden_FMK doesn't use
			-- their results, and it consumes a massive amount of time and CPU.
			-- We'd do this on dedicated servers as well, except that sv_cheats
			-- needs to be enabled in order to disable visibility computations.
			RunConsoleCommand("nav_max_view_distance", "1")
			RunConsoleCommand("nav_quicksave", "1")
			
			-- Enable developer mode so we can see console messages in the corner.
			RunConsoleCommand("developer", "1")
			elseif isConsole then
			print("npc_hidden_FMK: Beginning nav_generate requested by server console")
			else
			return
		end
		
		local success = navGenerate()
		
		-- If it fails, only the person who started it needs to know.
		local recipients = (success and player.GetHumans() or {ply})
		
		net.Start("hidden_FMK_navgen")
		net.WriteBool(success)
		net.Send(recipients)
	end)
	
	ENT.LastPathRecompute = 0
	ENT.LastTargetSearch = 0
	ENT.LastJumpScan = 0
	ENT.LastCeilingUnstick = 0
	ENT.LastAttack = 0
	ENT.LastHuntSound = -npc_hidden_FMK_huntsound_interval:GetFloat()
	ENT.LastFrag = -npc_hidden_FMK_grenade_chance:GetFloat()
	ENT.LastCameraTurn = 0
	ENT.LastHidingPlaceScan = 0
	ENT.LastTaunt = 0
	ENT.NextDoorOpen = 0
	ENT.TimeoutUntil = 0
	ENT.TimeoutPosition = nil
	ENT.NextJump = 0
	ENT.NextHPRegen = 0
	ENT.HuntTeleportAnger = 0
	ENT.IsLowCollision = false
	
	ENT.HideUntil = 0
	ENT.NoExtraRetreat = 0
	
	ENT.WaitWithNextTargetUntil = 0
	
	-- Anti stuck
	ENT.Spawnpoint = nil
	ENT.StuckCycles = 0
	ENT.MaxStuckCycles = 4
	ENT.AntiStuckDetectDelay = 1.5
	ENT.NextStuckCheck = 0
	ENT.NextStuckDecay = 0
	ENT.LastPos = nil
	
	ENT.LastRelationshipUpdate = 0
	
	ENT.CurrentTarget = nil
	ENT.HidingSpot = nil
	
	function ENT:BodyUpdate()
		 self:BodyMoveXY()
	end
		
	function ENT:Initialize()
		-- Cosmetic for context menu and vision-extending mods
		self:SetModel("models/player/soldier_stripped.mdl")
		self.loco:SetDesiredSpeed(5500)
		self:SetMaterial("models/props_combine/stasisshield_sheet")
		
		-- Targetable
		self:AddFlags(FL_OBJECT)
		
		-- Spawn effect resets render override. Bug!!!
		self:SetSpawnEffect(false)
		
		self:SetMaxHealth(npc_hidden_FMK_health:GetFloat())
		
		self:SetBloodColor(BLOOD_COLOR_RED)
		
		-- Just in case.
		self:SetHealth(npc_hidden_FMK_health:GetFloat())
		
		--self:DrawShadow(false) -- Why doesn't this work???
		
		--"Disables shadows" - Sure?
		self:SetRenderMode(RENDERMODE_TRANSCOLOR)
		
		self:SetColor(Color(255, 255, 255, 1))
		
		-- Less than Human-sized collision.
		self:SetCollisionBounds(Vector(-9, -9, 0), Vector(9, 9, 60))
		
		self.loco:SetDeathDropHeight(5000)
		
		-- In Sandbox, players are faster in singleplayer.
		self.loco:SetDesiredSpeed(game.SinglePlayer() and (npc_hidden_FMK_desired_speed:GetFloat() + math.random(-20,20) + 150) or (npc_hidden_FMK_desired_speed:GetFloat() + math.random(-20,20)))
		
		-- Take corners a bit sharp.
		self.loco:SetAcceleration(math.random(380,420))
		self.loco:SetDeceleration(math.random(180,220))
		
		-- This isn't really important because we reset it all the time anyway.
		self.loco:SetJumpHeight(400)
		
		-- Rebuild caches.
		self:OnReloaded()
		
		self.Spawnpoint = self:GetPos()
		self.LastPos = self.Spawnpoint
		lastSpawn = self.Spawnpoint
	end
	
	ENT.dead = false
	function ENT:OnKilled(dmginfo)
		if !self.dead then
			self.dead = true
			else
			return
		end
		local finalSound = table.Random(self.HurtSounds)
		self:Remove()
		hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )
		self:EmitSound(table.Random(self.DeathSounds), math.Rand(400,600), math.Rand(80,100))
		timer.Remove("TIMER")
		timer.Remove("DOOR")
		timer.Remove("STUCK")
		
		local body = ents.Create( "prop_ragdoll" )
		body:SetPos( self:GetPos() )
		if !npc_hidden_FMK_legacy_model:GetBool() then
			body:SetModel("models/player/hidden.mdl")
			else
			body:SetModel("models/player/soldier_stripped.mdl")
			body:SetAngles((dmginfo:GetAttacker():GetPos() - self:GetPos()):Angle())
		end
		body:Spawn()
		body:GetPhysicsObject():ApplyForceCenter(dmginfo:GetDamageForce())
		body:GetPhysicsObject():SetAngles(Vector(20,20,20):Angle())
		
		timer.Create("BodyForce"..tostring(body:EntIndex()), math.Rand(1.5,6), math.Rand(1,3), function()	
			if not IsValid(body) then return end
			body:GetPhysicsObject():ApplyForceCenter(Vector(math.random(1000,3000),math.random(500,1500),math.random(500,1500)))
		end)
		
		timer.Create("BodyDissolve"..tostring(body:EntIndex()), math.Rand(10,50), 1, function()
			if npc_hidden_FMK_respawn:GetBool() then
				local newHidden = ents.Create( "npc_hidden_FMK" )
				newHidden:SetPos(lastSpawn)
				newHidden:Spawn()
			end			
			if not IsValid(body) then return end
			body:GetPhysicsObject():ApplyForceCenter(dmginfo:GetDamageForce())
			body:EmitSound(finalSound, math.Rand(10,60), math.Rand(10,80))
			local Dissolver = ents.Create( "env_entity_dissolver" )
			timer.Simple(5, function()
				if IsValid(Dissolver) then
					Dissolver:Remove() -- backup edict save on error
				end
			end)
			Dissolver.Target = "dissolve"..body:EntIndex()
			Dissolver:SetKeyValue( "dissolvetype", 0)
			Dissolver:SetKeyValue( "magnitude", 0 )
			Dissolver:SetPos(body:GetPos())
			Dissolver:Spawn()
			
			body:SetName(Dissolver.Target)			
			Dissolver:Fire( "Dissolve", Dissolver.Target, 0 )
			Dissolver:Fire( "Kill", "", 0.1 )	
		end )
	end
	
	ENT.LastHurt = 0
	function ENT:OnInjured(dmginfo)	
		currentTime = CurTime()
		if self:Health() <= dmginfo:GetDamage() then
			self:OnKilled(dmginfo)
			return
		end
		self:SetHealth(self:Health() - dmginfo:GetDamage())
		if currentTime - self.LastHurt > HURT_SOUND_INTERVAL then
			self.LastHurt = currentTime
			self:EmitSound(table.Random(self.HurtSounds), 350, 100)
		end
		if math.random(0,self:Health()/15) < 2 and npc_hidden_FMK_can_retreat:GetBool() and currentTime > self.NoExtraRetreat then
			self.HideUntil = currentTime + math.random(2,6)
			--PrintMessage(HUD_PRINTTALK, "YOUCH!")
			self.NoExtraRetreat = currentTime + math.random(3,15)
		end
		self:SetVelocity(self:GetVelocity() * math.Rand(0.75,1.10))
	end
	
	function ENT:OnReloaded()
		if g_hidingSpots == nil then
			buildHidingSpotCache()
		end
	end
	
	function ENT:OnRemove()
		-- Give up our hiding spot when we're deleted.
		self:ClaimHidingSpot(nil)
		timer.Remove("TIMER")
		timer.Remove("DOOR")
		timer.Remove("DOOR_CLOSER")
		timer.Remove("STUCK")
	end
	
	function ENT:GetNearestTarget()
		-- Only target entities within the acquire distance.
		local maxAcquireDist = npc_hidden_FMK_acquire_distance:GetInt()
		local maxAcquireDistSqr = maxAcquireDist * maxAcquireDist
		local myPos = self:GetPos()
		local acquirableEntities = ents.FindInSphere(myPos, maxAcquireDist)
		local distToSqr = myPos.DistToSqr
		local getPos = self.GetPos
		local target = nil
		local getClass = self.GetClass
		
		for _, ent in pairs(acquirableEntities) do
			-- Ignore invalid targets, of course.
			if ent:GetClass() == "npc_enemyfinder" then continue end
			if not isValidTarget(ent) then continue end
			
			if npc_hidden_FMK_targeted_by_npcs:GetBool() then
				if ent:IsNPC() then
					ent:AddEntityRelationship(self, D_FR, 3)
				end
			end	
			
			-- Spawn protection! Ignore players within 200 units of a spawn point
			-- if `npc_hidden_FMK_spawn_protect' = 1.
			--TODO: Only for the first few seconds?
			if npc_hidden_FMK_spawn_protect:GetBool() and ent:IsPlayer()
				and isPointNearSpawn(ent:GetPos(), 100)
				then
				continue
			end
			
			-- Find the nearest target to chase.
			local distSqr = distToSqr(getPos(ent), myPos)
			if distSqr < maxAcquireDistSqr then
				if CurTime() < self.WaitWithNextTargetUntil and distSqr > 5000000 then
					--PrintMessage(HUD_PRINTTALK, "WaitWithNextTargetUntil: "..self.WaitWithNextTargetUntil - CurTime())
					--PrintMessage(HUD_PRINTTALK, "Target too far away: "..distSqr)
					continue
					else
					--PrintMessage(HUD_PRINTTALK, "(off) WaitWithNextTargetUntil: "..self.WaitWithNextTargetUntil - CurTime())
					--PrintMessage(HUD_PRINTTALK, "Target distance: "..distSqr)
				end
				target = ent
				maxAcquireDistSqr = distSqr
			end
		end
		
		return target
	end
	
	local timeout_length = 0.8
	local timeout_random_min = 0.05
	local timeout_random_max = 0.1
	local timeout_close_door_extra = 0
	local door_opener_delay = 0.25
	function ENT:OpenAndCloseDoors(closeagain) 
		self.NextDoorOpen = CurTime() + door_opener_delay
		for _, ent in pairs(ents.FindInSphere(self:LocalToWorld(self:OBBCenter()), 25)) do -- nearEntities
			local doorState = false
			if ent:GetClass() == "func_door_rotating"  then -- Normal doors
				doorState = ent:GetInternalVariable( "m_toggle_state" ) == 0
				elseif ent:GetClass() == "func_door" then -- Like blast doors
				doorState = ent:GetInternalVariable( "m_toggle_state" ) == 1
				elseif ent:GetClass() == "prop_door_rotating"  then		-- Weirdo Doors (usually without handle)
				doorState = ent:GetInternalVariable( "m_eDoorState" ) == 0
				else
				continue
			end
			
			if doorState then	-- The door is closed
				ent:Fire("Open")
				self.TimeoutPosition = self:GetPos()
				self:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
				self.TimeoutUntil = CurTime() + timeout_length + math.Rand(timeout_random_min, timeout_random_max)
				if not closeagain then
					timer.Create("DOOR", 1.5, 1, function() self:SetCollisionGroup(COLLISION_GROUP_NONE) end ) -- And leave it open
					else
					timer.Create("DOOR", 1.9, 1, function() self:SetCollisionGroup(COLLISION_GROUP_NONE) ent:Fire("Close") end ) -- And close it again after opening
					self.TimeoutUntil = self.TimeoutUntil + timeout_close_door_extra
				end
				elseif closeagain then -- Door is open and we are supposed to close it
				self:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
				timer.Create("DOOR_CLOSER", 2.5, 1, function() self:SetCollisionGroup(COLLISION_GROUP_NONE) ent:Fire("Close") end )	
			end
		end
	end
	
	--TODO: Giant ugly monolith of a function eww eww eww.
	function ENT:AttackNearbyTargets(radius)
		local attackForce = npc_hidden_FMK_attack_force:GetInt()
		local hitSource = self:LocalToWorld(self:OBBCenter())
		local nearEntities = ents.FindInSphere(hitSource, radius)
		local hit = false
		for _, ent in pairs(nearEntities) do
			if string.find(ent:GetClass():lower(), "turret" ) then
				pcall(function() -- In case this turret is unkillable
					local explosion = ents.Create( "env_explosion" ) -- The explosion entity
					explosion:SetPos(ent:GetPos() ) -- Put the position of the explosion at the position of the entity
					explosion:Spawn() -- Spawn the explosion
					explosion:SetKeyValue( "iMagnitude", "0" ) -- the magnitude of the explosion
					explosion:Fire( "Explode", 0, 0 ) -- explode	
					ent:Remove()
					hit = 1
				end)
				goto continueANT
			end
			
			if npc_hidden_FMK_ragdoll_messup:GetBool() then
				if ent:GetClass() == "prop_ragdoll" and ent:GetModel() != "models/Humans/Charple01.mdl" then
					ent:SetModel("models/Humans/Charple01.mdl")
					self:EmitSound(table.Random(self.RagdollBreakSounds), math.Rand(400,600), math.Rand(80,120))
				end
			end
			
			if isValidTarget(ent) then
				local health = ent:Health()
				if ent:IsPlayer() and IsValid(ent:GetVehicle()) then
					-- Hiding in a vehicle, eh?
					local vehicle = ent:GetVehicle()
					
					local vehiclePos = vehicle:LocalToWorld(vehicle:OBBCenter())
					local hitDirection = (vehiclePos - hitSource):GetNormal()
					
					-- Give it a good whack.
					local phys = vehicle:GetPhysicsObject()
					if IsValid(phys) then
						phys:Wake()
						local hitOffset = vehicle:NearestPoint(hitSource)
						phys:ApplyForceOffset(hitDirection
							* (attackForce * phys:GetMass()),
						hitOffset)
					end
					vehicle:TakeDamage(math.max(npc_hidden_FMK_damage:GetFloat(), ent:Health()), self, self)
					
					-- Oh, and make a nice SMASH noise.
					vehicle:EmitSound(string.format(
						"physics/metal/metal_sheet_impact_hard%d.wav",
					math.random(6, 8)), 350, 120)
					else
					ent:EmitSound(string.format(
						"physics/body/body_medium_impact_hard%d.wav",
					math.random(1, 6)), 350, 120)
				end
				
				local hitDirection = (ent:GetPos() - hitSource):GetNormal()
				-- Give the player a good whack. hidden_FMK means business.
				-- This is for those with god mode enabled.
				ent:SetVelocity(hitDirection * attackForce + vector_up * 125)
				
				local dmgInfo = DamageInfo()
				dmgInfo:SetAttacker(self)
				dmgInfo:SetInflictor(self)
				dmgInfo:SetDamage(npc_hidden_FMK_damage:GetFloat())
				dmgInfo:SetDamagePosition(self:GetPos())
				dmgInfo:SetDamageForce((hitDirection * attackForce
				+ vector_up * 125) * 100)
				ent:TakeDamageInfo(dmgInfo)
				
				local newHealth = ent:Health()
				
				-- Hits only count if we dealt some damage.
				hit = (hit or (newHealth < health))
				elseif ent:GetMoveType() == MOVETYPE_VPHYSICS then
				if not npc_hidden_FMK_smash_props:GetBool() then continue end
				if ent:IsVehicle() and IsValid(ent:GetDriver()) then continue end
				
				-- Knock away any props put in our path.
				local entPos = ent:LocalToWorld(ent:OBBCenter())
				local hitDirection = (entPos - hitSource):GetNormal()
				local hitOffset = ent:NearestPoint(hitSource)
				
				-- Remove anything tying the entity down.
				-- We're crashing through here!
				constraint.RemoveAll(ent)
				
				-- Get the object's mass.
				local phys = ent:GetPhysicsObject()
				local mass = 0
				local material = "Default"
				if IsValid(phys) then
					mass = phys:GetMass()
					material = phys:GetMaterial()
				end
				
				-- Don't make a noise if the object is too light.
				-- It's probably a gib.
				if mass >= 5 then
					ent:EmitSound(material .. ".ImpactSoft", 350, 120)
				end
				
				-- Unfreeze all bones, and give the object a good whack.
				for id = 0, ent:GetPhysicsObjectCount() - 1 do
					local phys = ent:GetPhysicsObjectNum(id)
					if IsValid(phys) then
						phys:EnableMotion(true)
						phys:ApplyForceOffset(hitDirection * (attackForce * mass),
						hitOffset)
					end
				end
				
				-- Deal some solid damage, too.
				ent:TakeDamage(25, self, self)
			end
		end
		::continueANT::
		return hit
	end
	
	function ENT:IsHidingSpotFull(hidingSpot)
		-- It's not full if there's no occupant, or we're the one in it.
		local occupant = hidingSpot.occupant
		if not IsValid(occupant) or occupant == self then
			return false
		end
		
		return true
	end
	
	--TODO: Weight spots based on how many people can see them.
	function ENT:GetNearestUsableHidingSpot()
		local nearestHidingSpot = nil
		local nearestHidingDistSqr = 1e8
		
		local myPos = self:GetPos()
		local isHidingSpotFull = self.IsHidingSpotFull
		local distToSqr = myPos.DistToSqr
		
		-- This could be a long loop. Optimize the heck out of it.
		for _, hidingSpot in pairs(g_hidingSpots) do
			-- Ignore hiding spots that are near spawn, or full.
			if hidingSpot.nearSpawn or isHidingSpotFull(self, hidingSpot) then
				continue
			end
			
			--TODO: Disallow hiding places near spawn?
			local hidingSpotDistSqr = distToSqr(hidingSpot.pos, myPos)
			if math.random(0,3) == 2 -- Tear the "nearest point" out of the code. This way they actually tranverse the map
				and not isPositionExposed(hidingSpot.pos)
				then
				nearestHidingDistSqr = hidingSpotDistSqr
				nearestHidingSpot = hidingSpot
			end
		end
		
		return nearestHidingSpot
	end
	
	function ENT:ClaimHidingSpot(hidingSpot)
		-- Release our claim on the old spot.
		if self.HidingSpot ~= nil then
			self.HidingSpot.occupant = nil
		end
		
		-- Can't claim something that doesn't exist, or a spot that's
		-- already claimed.
		if hidingSpot == nil or self:IsHidingSpotFull(hidingSpot) then
			self.HidingSpot = nil
			return false
		end
		
		-- Yoink.
		self.HidingSpot = hidingSpot
		self.HidingSpot.occupant = self
		return true
	end
	
	local HIGH_JUMP_HEIGHT = 500
	function ENT:AttemptJumpAtTarget()
		-- No double-jumping.
		if not self:IsOnGround() then return end
		if CurTime() < self.NextJump then return end
		
		local targetPos = self.CurrentTarget:GetPos()
		local xyDistSqr = (targetPos - self:GetPos()):Length2DSqr()
		local zDifference = targetPos.z - self:GetPos().z
		local maxAttackDistance = npc_hidden_FMK_attack_distance:GetInt()
		if xyDistSqr <= math.pow(maxAttackDistance + 400, 2)
			and zDifference >= maxAttackDistance
			then
			--TODO: Set up jump so target lands on parabola.
			local jumpHeight = zDifference + 50
			self.loco:SetJumpHeight(jumpHeight)
			self.loco:Jump()
			self.loco:SetJumpHeight(300)
			self:SetVelocity(self:GetVelocity() * math.random(5,8))
			
			if not npc_hidden_FMK_shut_up:GetBool() then
			if math.random(0,4) == 3 then
				self:EmitSound((jumpHeight > HIGH_JUMP_HEIGHT and
				table.Random(self.JumpHighSound) or table.Random(self.JumpSound)), math.random(25,500), 100)
			end
			end
			
			self.NextJump = CurTime() + math.random(0,4)
		end
	end
	
	local VECTOR_HIGH = Vector(0, 0, 16384)
	ENT.LastPathingInfraction = 0
	function ENT:RecomputeTargetPath()
		if CurTime() - self.LastPathingInfraction < PATH_INFRACTION_TIMEOUT then
			-- No calculations for you today.
			return
		end
		
		local targetPos = self.CurrentTarget:GetPos()
		
		-- Run toward the position below the entity we're targetting,
		-- since we can't fly.
		trace.start = targetPos
		trace.endpos = targetPos - VECTOR_HIGH
		trace.filter = self.CurrentTarget
		local tr = util.TraceEntity(trace, self.CurrentTarget)
		
		-- Of course, we sure that there IS a "below the target."
		if tr.Hit and util.IsInWorld(tr.HitPos) then
			targetPos = tr.HitPos
		end
		
		local rTime = SysTime()
		self.MovePath:Compute(self, targetPos)
		
		-- If path computation takes longer than 5ms (A LONG TIME),
		-- disable computation for a little while for this bot.
		if SysTime() - rTime > 0.005 then
			self.LastPathingInfraction = CurTime()
		end
	end
	
	function ENT:BehaveStart()
		self.MovePath = Path("Follow")
		self.MovePath:SetMinLookAheadDistance(500)
		self.MovePath:SetGoalTolerance(10)
		--self:StartActivity(ACT_RUN)
		local runlayer = self:AddLayeredSequence(137, 2) -- https://wiki.facepunch.com/gmod/BaseAnimatingOverlay
		self:SetLayerWeight(runlayer, 1)
		self:SetLayerLooping(runlayer, true)
		self:SetLayerPlaybackRate(runlayer, 0.95)
		--PrintTable(self:GetSequenceList())
	end
	
	function ENT:NextbotTeleport()
		self.LastPathRecompute = 0
		local pos = self.CurrentTarget:GetPos()
		local radius = 3000 -- adjust as needed
		local min_distance = 600 -- adjust as needed
		local max_height_diff = 100 -- adjust as needed
		local new_pos = pos + Vector(math.random(-radius, radius), math.random(-radius, radius), 0)
		local search_try = 0
		-- check if the new position is walkable
		while not util.IsInWorld(new_pos) or new_pos:Distance(pos) < min_distance or math.abs(new_pos.z - pos.z) > max_height_diff  do
			new_pos = pos + Vector(math.random(-radius, radius), math.random(-radius, radius), 0)
			search_try = search_try + 1
			if search_try > 100 then
				return
			end
		end
		if not util.IsInWorld(new_pos) then return false end 
		self:SetPos(new_pos)
		return true
	end
	
	function ENT:RegenHealth(self, healthRegen)
		if self:Health() < self:GetMaxHealth() then
			if (self:Health() + healthRegen) >= self:GetMaxHealth() then
				self:SetHealth(self:GetMaxHealth())
				else
				self:SetHealth(self:Health() + healthRegen)
			end
		end
	end
	
	function ENT:HidingSpotCycle()
		local currentTime = CurTime()
		if currentTime - self.LastHidingPlaceScan >= npc_hidden_FMK_hiding_scan_interval:GetFloat() then
			self.LastHidingPlaceScan = currentTime						
			-- Grab a new hiding spot.
			local hidingSpot = self:GetNearestUsableHidingSpot()
			self:ClaimHidingSpot(hidingSpot)
		end
		
		if self.HidingSpot ~= nil then
			local hidingInterval = npc_hidden_FMK_hiding_repath_interval:GetFloat()
			if currentTime - self.LastPathRecompute >= hidingInterval then
				self.LastPathRecompute = currentTime
				self.MovePath:Compute(self, self.HidingSpot.pos)
			end
			self.MovePath:Update(self)
		end
	end
	
	local ai_disabled = GetConVar("ai_disabled")
	function ENT:BehaveUpdate() --TODO: Split this up more. Eww.
		if ai_disabled:GetBool() then
			if math.random() < 0.99 then -- Be angry sometimes about AI_disabled
				return
				else	
				self:EmitSound(table.Random(self.HurtSounds), math.Rand(25,85), math.Rand(10,100))
				return
			end	
		end
		
		
		local currentTime = CurTime()
		
		if currentTime > self.NextHPRegen and npc_hidden_FMK_regen_per_sec:GetFloat() != 0 then
			self:RegenHealth(self, npc_hidden_FMK_regen_per_sec:GetFloat())
			self.NextHPRegen = currentTime + 1
		end
		
		if(CurTime() > self.NextDoorOpen) then -- Open Doors->
			if math.random(1,100) > 3 then
				self:OpenAndCloseDoors(false)
				else
				self:OpenAndCloseDoors(true)
			end
		end
		
		if self.HideUntil > currentTime then
			self:HidingSpotCycle(self)
			self:AttackNearbyTargets(25)
			return
		end
		
		if self.TimeoutUntil > currentTime then 
			if self.TimeoutPosition == nil then return end
			self:SetPos(self.TimeoutPosition)
			--print("sleep")
			return 
		end
		
		if currentTime > self.NextStuckDecay then
			if self.StuckCycles > 0 then
				self.StuckCycles = self.StuckCycles - 1
			end
			self.NextStuckDecay = currentTime + (self.AntiStuckDetectDelay + 1)
		end
		
		if currentTime > self.NextStuckCheck and npc_hidden_FMK_antistuck:GetBool() then
			--print("Check")
			if IsValid(self.CurrentTarget) then
				if self.LastPos:Distance(self:GetPos()) > 150 then
					self.HuntTeleportAnger = self.HuntTeleportAnger + self.AntiStuckDetectDelay - math.Rand(0.1, self.AntiStuckDetectDelay)
					--PrintMessage(HUD_PRINTTALK, "Hunt teleport anger: "..self.HuntTeleportAnger)
				end
				--print(self.CurrentTarget)
				self.NextStuckCheck = currentTime + self.AntiStuckDetectDelay
				--PrintMessage(HUD_PRINTTALK, "Distance: "..self.LastPos:Distance(self:GetPos()))
				if self.LastPos:Distance(self:GetPos()) < 10 then
					self.StuckCycles = self.StuckCycles + 1
					self:EmitSound(Sound("freemankiller/nextbot/617-aurain01.wav"), math.random(600), math.random(90,110))
					self:SetCollisionBounds(Vector(-3, -3, 0), Vector(3, 3, 30))
					self.IsLowCollision = true
					self.loco:SetAcceleration(math.random(380,420) / 1.25)
					self.loco:SetDeceleration(math.random(180,220) / 1.25)
				end
				--PrintMessage(HUD_PRINTTALK, "Stuck cycle: "..self.StuckCycles)
				
				self.LastPos = self:GetPos()
				
				if self.StuckCycles == self.MaxStuckCycles - 1 then		
					--PrintMessage(HUD_PRINTTALK, "Teleport!")
					self:SetCollisionGroup(COLLISION_GROUP_VEHICLE_CLIP)
					timer.Create("STUCK", 1.5, 0.2, function() self:SetCollisionGroup(COLLISION_GROUP_NONE) end )
					self:SetVelocity(Vector(math.Rand(100,500), math.Rand(100,500), math.Rand(100,500)))
					local newPos = nil
					local newPosTries = 0
					while newPos == nil and newPosTries < 10 do
						newPosTries = newPosTries + 1
						newPos = self:GetPos() + Vector(math.random(-35, 35), math.random(-35, 35), math.random(-35, 35))
						if not util.IsInWorld(newPos) then
							newPos = nil
							--PrintMessage(HUD_PRINTTALK, "Pos null")
							else
							self:SetPos(newPos)
							--PrintMessage(HUD_PRINTTALK, "Pos not null, teleport!")
						end
					end	
				end
				
				if self.StuckCycles == self.MaxStuckCycles then
					self.StuckCycles = 0
					self:SetPos(self.Spawnpoint)
				end
				if self.HuntTeleportAnger > 10 then	
					self:NextbotTeleport()
					self.HuntTeleportAnger = 0
				end
				else
				self.StuckCycles = 0
				--print("finished hunt")
				self.NextStuckCheck = currentTime + self.AntiStuckDetectDelay
			end
			if IsLowCollision and self.StuckCycles == 0 then	
				self:SetCollisionBounds(Vector(-9, -9, 0), Vector(9, 9, 60))
				self:EmitSound(Sound("freemankiller/nextbot/617-auraout01.wav"), math.random(600), math.random(90,110))
				self.loco:SetAcceleration(math.random(380,420))
				self.loco:SetDeceleration(math.random(180,220))
			end
		end
		
		local scanInterval = npc_hidden_FMK_expensive_scan_interval:GetFloat()
		if currentTime - self.LastTargetSearch > scanInterval then
			local target = self:GetNearestTarget()
			
			if target ~= self.CurrentTarget then
				-- We have a new target! Figure out a new path immediately.
				self.LastPathRecompute = 0
			end
			
			self.CurrentTarget = target
			self.LastTargetSearch = currentTime
		end
		
		-- Do we have a target?
		if IsValid(self.CurrentTarget) then
			-- Be ready to repath to a hiding place as soon as we lose target.
			self.LastHidingPlaceScan = 0
			
			local theTarget = self.CurrentTarget
			
			--Grenade?
			if currentTime - self.LastFrag > npc_hidden_FMK_grenade_interval:GetFloat() then
				self.LastFrag = currentTime
				if math.random(0, 100) < npc_hidden_FMK_grenade_chance:GetFloat() then			
					local frag = ents.Create( "npc_grenade_frag" )
					frag:SetPos(theTarget:GetPos() + Vector(math.Rand(0,35),math.Rand(0,35),math.Rand(80,100)))
					frag:Spawn()
					frag:Input("SetTimer", self, self, math.Rand(2.8,3.5))
					frag:GetPhysicsObject():ApplyForceCenter(Vector(math.Rand(15,80),math.Rand(15,80),math.Rand(0,60)))
					if npc_hidden_FMK_grenade_throw_sound:GetBool() then
						theTarget:EmitSound("weapons/slam/throw.wav", math.Rand(100,300), math.Rand(80,100))
						self:EmitSound("weapons/slam/throw.wav", math.Rand(50,150), math.Rand(80,100))
					end
				end
			end
			
			-- Near enough?
			local targetDistance = self:GetPos():Distance(self.CurrentTarget:GetPos())
			if(targetDistance <= npc_hidden_FMK_huntsound_distance:GetFloat()) then		
				-- Scare target				
				if currentTime - self.LastHuntSound > npc_hidden_FMK_huntsound_interval:GetFloat() then
					self.LastHuntSound = currentTime + math.random(0, 2)
					local scareSound = nil
					local pitch = math.Rand(95,105)
					if not npc_hidden_FMK_shut_up:GetBool() then
					if(targetDistance <= 300) and math.random(0,1) == 0 then
						scareSound = table.Random(self.ScareSoundsClose)
						theTarget:EmitSound(scareSound, (math.Rand(50,70)), pitch)
						else
						scareSound = table.Random(self.ScareSounds)
						theTarget:EmitSound(scareSound, (math.Rand(35,60)), pitch)
					end		
					self:EmitSound(scareSound, math.Rand(60,80), pitch)
					end
					if theTarget:IsPlayer() and math.random(1,75) == 50 then -- Original was 1,50
						local theName = string.lower(theTarget:GetName())
						local cutter = string.find(theName, " ")
						if cutter != nil and math.random(0,3) != 3 then
							theName = string.sub(theName, 1, cutter - 1)
						end
						for i, ply in ipairs( player.GetAll() ) do
							if not npc_hidden_FMK_shut_up:GetBool() then
							ply:SendLua("chat.AddText(Color(255, 255, 100),\"617\",Color(255, 255, 255),\": ..."..theName.."...\")")
							end
						end
					end
					if theTarget:IsPlayer() and npc_hidden_FMK_screenshake:GetBool() then
						timer.Create("TIMER", math.Rand(0.25, 2), 1, function()		
							--theTarget:EmitSound(Sound("freemankiller/nextbot/heartbeat.wav"), math.Rand(600,800), math.Rand(100,150))
							theTarget:SetEyeAngles((self:GetPos() - theTarget:GetShootPos() * math.Rand(0, 2.4)):Angle())
							self.LastCameraTurn = currentTime + math.Rand(0, 2.5)
						end )
					end						
				end
			end	
			
			-- Attack anyone nearby while we're rampaging.
			local attackInterval = npc_hidden_FMK_attack_interval:GetFloat()
			if currentTime - self.LastAttack > attackInterval then
				local attackDistance = npc_hidden_FMK_attack_distance:GetInt()
				if self:AttackNearbyTargets(attackDistance) then
					if currentTime - self.LastTaunt > TAUNTKILL_INTERVAL then
						self.LastTaunt = currentTime
						self:EmitSound(table.Random(self.TauntSounds), math.random(300,400), math.random(97,103))
						self:RegenHealth(self, npc_hidden_FMK_regen_on_attack:GetFloat())
						self.HuntTeleportAnger = 0
						self.WaitWithNextTargetUntil = currentTime + math.random(0,30)
					end
					
					-- Immediately look for another target.
					self.LastTargetSearch = 0
					-- Reset antistuck
					self.StuckCycles = 0
				end
				
				self.LastAttack = currentTime
			end
			
			-- Recompute the path to the target every so often.
			local repathInterval = npc_hidden_FMK_chase_repath_interval:GetFloat()
			if currentTime - self.LastPathRecompute > repathInterval then
				self.LastPathRecompute = currentTime
				self:RecomputeTargetPath()
			end
			
			-- Move!
			self.MovePath:Update(self)
			
			-- Try to jump at a target in the air.
			if self:IsOnGround() and npc_hidden_FMK_allow_jump:GetBool()
				and currentTime - self.LastJumpScan >= scanInterval
				then
				self:AttemptJumpAtTarget()
				self.LastJumpScan = currentTime
				--self:StartActivity(ACT_RUN)
				--self:AddLayeredSequence(137, 5)
			end
			else -- NO VALID TARGET
			local hidingScanInterval = npc_hidden_FMK_hiding_scan_interval:GetFloat()
			self:HidingSpotCycle()
		end
		if currentTime - self.LastCeilingUnstick >= scanInterval then
			self:UnstickFromCeiling()
			self.LastCeilingUnstick = currentTime
		end
		
		if currentTime - self.LastStuck >= 5 then
			self.StuckTries = 0
		end
	end
	
	ENT.LastStuck = 0
	ENT.StuckTries = 0
	function ENT:OnStuck()
		-- Jump forward a bit on the path.
		self.LastStuck = CurTime()
		
		local newCursor = self.MovePath:GetCursorPosition()
		+ 40 * math.pow(2, self.StuckTries)
		self:SetPos(self.MovePath:GetPositionOnPath(newCursor))
		self.StuckTries = self.StuckTries + 1
		
		-- Hope that we're not stuck anymore.
		self.loco:ClearStuck()
	end
	
	function ENT:UnstickFromCeiling()
		if self:IsOnGround() then return end
		
		-- NextBots LOVE to get stuck. Stuck in the morning. Stuck in the evening.
		-- Stuck in the ceiling. Stuck on each other. The stuck never ends.
		local myPos = self:GetPos()
		local myHullMin, myHullMax = self:GetCollisionBounds()
		local myHull = myHullMax - myHullMin
		local myHullTop = myPos + vector_up * myHull.z
		trace.start = myPos
		trace.endpos = myHullTop
		trace.filter = self
		local upTrace = util.TraceLine(trace, self)
		
		if upTrace.Hit and upTrace.HitNormal ~= vector_origin
			and upTrace.Fraction > 0.5
			then
			local unstuckPos = myPos
			+ upTrace.HitNormal * (myHull.z * (1 - upTrace.Fraction))
			self:SetPos(unstuckPos)
		end
	end
	
	else -- CLIENT --
	
	CreateClientConVar("npc_hidden_FMK_visibilitymode_client", "2", true, false, "Different view modes, easier customization in spawnmenu utilites. CLIENTSIDE, all players need to do this for it to be synched.")
	CreateClientConVar("npc_hidden_FMK_visibilitymode_custom_texture", "pp/sharpen", true, false, "Use custom texture if npc_hidden_FMK_visibilitymode_client == 7.")
	CreateClientConVar("npc_hidden_FMK_visibilitymode_custom_texture_size", 128, true, false, "If using custom texture, set size from center here.")
	
	
	local spriteIndex = 1
	local maxSprite = 6
	local MAT_hidden_FMK = Material("npc_hidden_FMK/hidden_FMK_k1")
	local nextUpdateTime = CurTime()
	local updateSpriteCooldown = 0.12
	
	local cycleMax = 6
	local cycleNow = 0
	local cycleCooldown = 5
	
	local function nextSprite()
		if CurTime() < nextUpdateTime and cycleNow < cycleMax then
			return
			else
			nextUpdateTime = CurTime() + updateSpriteCooldown
			cycleNow = cycleNow + 1
		end
		
		if spriteIndex < maxSprite then
			spriteIndex = spriteIndex + 1
			else
			spriteIndex = 1
		end
		
		if cycleNow == cycleMax then
			nextUpdateTime = nextUpdateTime + cycleCooldown
			cycleNow = 0
		end
		
		MAT_hidden_FMK = Material("npc_hidden_FMK/hidden_FMK_k"..spriteIndex)
	end
	
	nextSprite()
	
	language.Add("npc_hidden_FMK", "The Hidden")
	
	ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
	
	local developer = GetConVar("developer")
	local function DevPrint(devLevel, msg)
		if developer:GetInt() >= devLevel then
			print("npc_hidden_FMK: " .. msg)
		end
	end
	
	local panicMusic = nil
	local lastPanic = 0 -- The last time we were in music range of a hidden_FMK.
	
	--TODO: Why don't these flags show up? Bug? Documentation would be lovely.
	local npc_hidden_FMK_music_volume =
	CreateConVar("npc_hidden_FMK_music_volume", 1,
		bit.bor(FCVAR_DEMO, FCVAR_ARCHIVE),
	"Maximum music volume when being chased by hidden_FMK. (0-1, where 0 is muted)")
	
	-- If another hidden_FMK comes in range before this delay is up,
	-- the music will continue where it left off.
	local MUSIC_RESTART_DELAY = 2
	
	-- Beyond this distance, hidden_FMKs do not count to music volume.
	local MUSIC_CUTOFF_DISTANCE = 1000
	
	-- Max volume is achieved when MUSIC_hidden_FMK_PANIC_COUNT hidden_FMKs are this close,
	-- or an equivalent score.
	local MUSIC_PANIC_DISTANCE = 200
	
	-- That's a lot of hidden_FMK.
	local MUSIC_hidden_FMK_PANIC_COUNT = 8
	
	local MUSIC_hidden_FMK_MAX_DISTANCE_SCORE =
	(MUSIC_CUTOFF_DISTANCE - MUSIC_PANIC_DISTANCE) * MUSIC_hidden_FMK_PANIC_COUNT
	
	local function updatePanicMusic()
		if #ents.FindByClass("npc_hidden_FMK") == 0 then
			-- Whoops. No need to run for now.
			DevPrint(4, "Halting music timer.")
			timer.Remove("hidden_FMKPanicMusicUpdate")
			
			if panicMusic ~= nil then
				panicMusic:Stop()
			end
			
			return
		end
		
		if panicMusic == nil then
			if IsValid(LocalPlayer()) then
				panicMusic = CreateSound(LocalPlayer(), chaseMusic)
				panicMusic:Stop()
				else
				return -- No LocalPlayer yet!
			end
		end
		
		local userVolume = math.Clamp(npc_hidden_FMK_music_volume:GetFloat(), 0, 1)
		if userVolume == 0 or not IsValid(LocalPlayer()) then
			panicMusic:Stop()
			return
		end
		
		local totalDistanceScore = 0
		local nearEntities = ents.FindInSphere(LocalPlayer():GetPos(), 1000)
		for _, ent in pairs(nearEntities) do
			if IsValid(ent) and ent:GetClass() == "npc_hidden_FMK" then
				local distanceScore = math.max(0, MUSIC_CUTOFF_DISTANCE
				- LocalPlayer():GetPos():Distance(ent:GetPos()))
				totalDistanceScore = totalDistanceScore + distanceScore
			end
		end
		
		local musicVolume = math.min(1,
		totalDistanceScore / MUSIC_hidden_FMK_MAX_DISTANCE_SCORE)
		
		local shouldRestartMusic = (CurTime() - lastPanic >= MUSIC_RESTART_DELAY)
		if musicVolume > 0 then
			if shouldRestartMusic then
				panicMusic:Play()
			end
			
			if not LocalPlayer():Alive() then
				-- Quiet down so we can hear hidden_FMK taunt us.
				musicVolume = musicVolume / 4
			end
			
			lastPanic = CurTime()
			elseif shouldRestartMusic then
			panicMusic:Stop()
			return
			else
			musicVolume = 0
		end
		
		musicVolume = math.max(0.01, musicVolume * userVolume)
		
		panicMusic:Play()
		
		-- Just for kicks.
		panicMusic:ChangePitch(math.Clamp(game.GetTimeScale() * 100, 50, 255), 0)
		panicMusic:ChangeVolume(musicVolume, 0)
	end
	
	local REPEAT_FOREVER = 0
	local function startTimer()
		if not timer.Exists("hidden_FMKPanicMusicUpdate") then
			timer.Create("hidden_FMKPanicMusicUpdate", 0.05, REPEAT_FOREVER,
			updatePanicMusic)
			DevPrint(4, "Beginning music timer.")
		end
	end
	
	local SPRITE_SIZE = 128
	function ENT:Initialize()
		self:SetModel("models/player/soldier_stripped.mdl")
		self:SetRenderBounds(
			Vector(-SPRITE_SIZE / 2, -SPRITE_SIZE / 2, 0),
			Vector(SPRITE_SIZE / 2, SPRITE_SIZE / 2, SPRITE_SIZE),
			Vector(5, 5, 5)
		)
		startTimer()
	end
	
	local DRAW_OFFSET = SPRITE_SIZE / 2 * vector_up
	function ENT:DrawTranslucent()
		SPRITE_SIZE = 128
		local currentSetting = GetConVar("npc_hidden_FMK_visibilitymode_client"):GetInt()
		if currentSetting == 2 then -- Default
			nextSprite()
			elseif currentSetting == 1 then -- Gaslike (barely visible tho)
			MAT_hidden_FMK = Material("pp/dof")
			elseif currentSetting == 3 then -- Easy knife
			MAT_hidden_FMK = Material("npc_hidden_FMK/hidden_FMK")
			elseif currentSetting == 4 then -- "Secret" - Trippy
			MAT_hidden_FMK = Material("pp/sharpen")
			elseif currentSetting == 5 then -- The evil bubble
			MAT_hidden_FMK = Material("nature/cloud001c")
			SPRITE_SIZE = 100
			elseif currentSetting == 6 then -- Wrap
			MAT_hidden_FMK = Material("particle/warp1_warp")
			SPRITE_SIZE = 60
			elseif currentSetting == 7 then -- Custom Texture
			MAT_hidden_FMK = Material(GetConVar("npc_hidden_FMK_visibilitymode_custom_texture"):GetString())
			SPRITE_SIZE = GetConVar("npc_hidden_FMK_visibilitymode_custom_texture_size"):GetFloat()
			elseif currentSetting == 8 then -- Wrap
			MAT_hidden_FMK = Material("effects/strider_bulge_dudv_dx60")
			SPRITE_SIZE = 95
			else -- 0
			MAT_hidden_FMK = Material("fmk/invis")
		end
		
		render.SetMaterial(MAT_hidden_FMK)
		
		-- Get the normal vector from hidden_FMK to the player's eyes, and then compute
		-- a corresponding projection onto the xy-plane.
		local pos = self:GetPos() + DRAW_OFFSET
		local normal = EyePos() - pos
		normal:Normalize()
		local xyNormal = Vector(normal.x, normal.y, 0)
		xyNormal:Normalize()
		
		-- hidden_FMK should only look 1/3 of the way up to the player so that they
		-- don't appear to lay flat from above.
		local pitch = math.acos(math.Clamp(normal:Dot(xyNormal), -1, 1)) / 3
		local cos = math.cos(pitch)
		normal = Vector(
			xyNormal.x * cos,
			xyNormal.y * cos,
			math.sin(pitch)
		)
		
		render.DrawQuadEasy(pos, normal, SPRITE_SIZE, SPRITE_SIZE,
		color_white, 180)
	end
	
	surface.CreateFont("hidden_FMKHUD", {
		font = "Arial",
		size = 56
	})
	
	surface.CreateFont("hidden_FMKHUDSmall", {
		font = "Arial",
		size = 24
	})
	
	local function string_ToHMS(seconds)
		local hours = math.floor(seconds / 3600)
		local minutes = math.floor((seconds / 60) % 60)
		local seconds = math.floor(seconds % 60)
		
		if hours > 0 then
			return string.format("%02d:%02d:%02d", hours, minutes, seconds)
			else
			return string.format("%02d:%02d", minutes, seconds)
		end
	end
	
	local flavourTexts = {
		{
			"Gotta learn fast!",
			"Learning this'll be a piece of cake!",
			"This is too easy."
			}, {
			"This must be a big map.",
			"This map is a bit bigger than I thought.",
			}, {
			"Just how big is this place?",
			"This place is pretty big."
			}, {
			"This place is enormous!",
			"A guy could get lost around here."
			}, {
			"Surely I'm almost done...",
			"There can't be too much more...",
			"This isn't gm_bigcity, is it?",
			"Is it over yet?",
			"You never told me the map was this big!"
		}
	}
	local SECONDS_PER_BRACKET = 300 -- 5 minutes
	local color_yellow = Color(255, 255, 80)
	local flavourText = ""
	local lastBracket = 0
	local generateStart = 0
	local function navGenerateHUDOverlay()
		draw.SimpleTextOutlined("hidden_FMK is studying this map.", "hidden_FMKHUD",
			ScrW() / 2, ScrH() / 2, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, color_black)
		draw.SimpleTextOutlined("Please wait...", "hidden_FMKHUD",
			ScrW() / 2, ScrH() / 2, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, color_black)
		
		local elapsed = SysTime() - generateStart
		local elapsedStr = string_ToHMS(elapsed)
		draw.SimpleTextOutlined("Time Elapsed:", "hidden_FMKHUDSmall",
			ScrW() / 2, ScrH() * 3/4, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
		draw.SimpleTextOutlined(elapsedStr, "hidden_FMKHUDSmall",
			ScrW() / 2, ScrH() * 3/4, color_white,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		
		-- It's taking a while.
		local textBracket = math.floor(elapsed / SECONDS_PER_BRACKET) + 1
		if textBracket ~= lastBracket then
			flavourText = table.Random(flavourTexts[math.min(5, textBracket)])
			lastBracket = textBracket
		end
		draw.SimpleTextOutlined(flavourText, "hidden_FMKHUDSmall",
			ScrW() / 2, ScrH() * 4/5, color_yellow,
		TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end
	
	net.Receive("hidden_FMK_navgen", function()
		local startSuccess = net.ReadBool()
		if startSuccess then
			generateStart = SysTime()
			lastBracket = 0
			hook.Add("HUDPaint", "hidden_FMKNavGenOverlay", navGenerateHUDOverlay)
			else
			Derma_Message("Oh no. hidden_FMK doesn't even know where to start with \z
				this map.\n\z
				If you're not running the Sandbox gamemode, switch to that and try \z
			again.", "Error!")
		end
	end)
	
	local nagMe = true
	
	local function requestNavGenerate()
		RunConsoleCommand("npc_hidden_FMK_learn")
	end
	
	local function stopNagging()
		nagMe = false
	end
	
	local function navWarning()
		Derma_Query("It will take a while (possibly hours) for hidden_FMK to figure \z
			this map out.\n\z
			While he's studying it, you won't be able to play,\n\z
			and the game will appear to have frozen/crashed.\n\z
			\n\z
			Also note that THE MAP WILL BE RESTARTED.\n\z
			Anything that has been built will be deleted.", "Warning!",
			"Go ahead!", requestNavGenerate,
		"Not right now.", nil)
	end
	
	net.Receive("hidden_FMK_nag", function()
		if not nagMe then return end
		
		if game.SinglePlayer() then
			Derma_Query("Uh oh! hidden_FMK doesn't know this map.\n\z
				Would you like him to learn it?",
				"This map has no navmesh!",
				"Yes (LAGS GAME UNTIL DONE)", navWarning,
				"No", nil,
			"No. Don't ask again.", stopNagging)
			else
			Derma_Query("Uh oh! This map has no navmesh. \z
				He won't be able to move!\n\z
				Because you're not in a single-player game, he isn't able to \z
				learn it.\n\z
				\n\z
				Ask the server host about teaching this map to hidden_FMK.\n\z
				\n\z
				If you ARE the server host, you can run npc_hidden_FMK_learn over \z
				rcon.\n\z
				Keep in mind that it may take hours during which you will be \z
				unable\n\z
				to play, and THE MAP WILL BE RESTARTED.",
				"This map has no navmesh!",
				"Ok", nil,
			"Ok. Don't say this again.", stopNagging)
		end
	end)
end

concommand.Add("npc_hidden_FMK_SAVE_SERVER_SETTINGS", function()
	local settingSaveData = {
		npc_hidden_FMK_screenshake = GetConVar("npc_hidden_FMK_screenshake"):GetBool(),
		npc_hidden_FMK_targeted_by_npcs = GetConVar("npc_hidden_FMK_targeted_by_npcs"):GetBool(),
		npc_hidden_FMK_smash_props = GetConVar("npc_hidden_FMK_smash_props"):GetBool(),
		npc_hidden_FMK_allow_jump = GetConVar("npc_hidden_FMK_allow_jump"):GetBool(),
		npc_hidden_FMK_spawn_protect = GetConVar("npc_hidden_FMK_spawn_protect"):GetBool(),
		npc_hidden_FMK_antistuck = GetConVar("npc_hidden_FMK_antistuck"):GetBool(),
		npc_hidden_FMK_legacy_model = GetConVar("npc_hidden_FMK_legacy_model"):GetBool(),
		npc_hidden_FMK_ragdoll_messup = GetConVar("npc_hidden_FMK_ragdoll_messup"):GetBool(),
		npc_hidden_FMK_acquire_distance = GetConVar("npc_hidden_FMK_acquire_distance"):GetInt(),
		npc_hidden_FMK_damage = GetConVar("npc_hidden_FMK_damage"):GetFloat(),
		npc_hidden_FMK_health = GetConVar("npc_hidden_FMK_health"):GetFloat(),
		npc_hidden_FMK_regen_on_attack = GetConVar("npc_hidden_FMK_regen_on_attack"):GetFloat(),
		npc_hidden_FMK_regen_per_sec = GetConVar("npc_hidden_FMK_regen_per_sec"):GetFloat(),
		npc_hidden_FMK_attack_interval = GetConVar("npc_hidden_FMK_attack_interval"):GetFloat(),
		npc_hidden_FMK_attack_force = GetConVar("npc_hidden_FMK_attack_force"):GetInt(),
		npc_hidden_FMK_huntsound_interval = GetConVar("npc_hidden_FMK_huntsound_interval"):GetFloat(),
		npc_hidden_FMK_huntsound_distance = GetConVar("npc_hidden_FMK_huntsound_distance"):GetFloat(),
		npc_hidden_FMK_desired_speed = GetConVar("npc_hidden_FMK_desired_speed"):GetFloat(),
		npc_hidden_FMK_grenade_chance = GetConVar("npc_hidden_FMK_grenade_chance"):GetFloat(),
		npc_hidden_FMK_grenade_interval = GetConVar("npc_hidden_FMK_grenade_interval"):GetFloat(),
		npc_hidden_FMK_grenade_throw_sound = GetConVar("npc_hidden_FMK_grenade_throw_sound"):GetBool(),
		npc_hidden_FMK_chase_repath_interval = GetConVar("npc_hidden_FMK_chase_repath_interval"):GetFloat(),
		npc_hidden_FMK_respawn = GetConVar("npc_hidden_FMK_respawn"):GetBool(),
		npc_hidden_FMK_can_retreat = GetConVar("npc_hidden_FMK_can_retreat"):GetBool(),
		npc_hidden_FMK_shut_up = GetConVar("npc_hidden_FMK_shut_up"):GetBool(),
	}
	settingSaveData = util.TableToJSON(settingSaveData)
	file.Write("thehidden_clientsettings.json", settingSaveData)
	print("The Hidden settings saved to harddrive! See: garrysmod/data/thehidden_serversettings.json")
end)

concommand.Add("npc_hidden_FMK_LOAD_SERVER_SETTINGS", function()
	if !file.Exists("thehidden_clientsettings.json", "data" ) then
		print("No saved The Hidden NPC server settings found! Requires garrysmod/data/thehidden_serversettings.json")
		return
	end
	local Ldata = util.JSONToTable(file.Read("thehidden_clientsettings.json"))
	GetConVar("npc_hidden_FMK_screenshake"):SetBool(Ldata.npc_hidden_FMK_screenshake)
	GetConVar("npc_hidden_FMK_targeted_by_npcs"):SetBool(Ldata.npc_hidden_FMK_targeted_by_npcs)
	GetConVar("npc_hidden_FMK_smash_props"):SetBool(Ldata.npc_hidden_FMK_smash_props)
	GetConVar("npc_hidden_FMK_allow_jump"):SetBool(Ldata.npc_hidden_FMK_allow_jump)
	GetConVar("npc_hidden_FMK_spawn_protect"):SetBool(Ldata.npc_hidden_FMK_spawn_protect)
	GetConVar("npc_hidden_FMK_antistuck"):SetBool(Ldata.npc_hidden_FMK_antistuck)
	GetConVar("npc_hidden_FMK_legacy_model"):SetBool(Ldata.npc_hidden_FMK_legacy_model)
	GetConVar("npc_hidden_FMK_ragdoll_messup"):SetBool(Ldata.npc_hidden_FMK_ragdoll_messup)
	GetConVar("npc_hidden_FMK_acquire_distance"):SetInt(Ldata.npc_hidden_FMK_acquire_distance)
	GetConVar("npc_hidden_FMK_damage"):SetFloat(Ldata.npc_hidden_FMK_damage)
	GetConVar("npc_hidden_FMK_health"):SetFloat(Ldata.npc_hidden_FMK_health)
	GetConVar("npc_hidden_FMK_regen_on_attack"):SetFloat(Ldata.npc_hidden_FMK_regen_on_attack)
	GetConVar("npc_hidden_FMK_regen_per_sec"):SetFloat(Ldata.npc_hidden_FMK_regen_per_sec)
	GetConVar("npc_hidden_FMK_attack_interval"):SetFloat(Ldata.npc_hidden_FMK_attack_interval)
	GetConVar("npc_hidden_FMK_attack_force"):SetInt(Ldata.npc_hidden_FMK_attack_force)
	GetConVar("npc_hidden_FMK_huntsound_interval"):SetFloat(Ldata.npc_hidden_FMK_huntsound_interval)
	GetConVar("npc_hidden_FMK_huntsound_distance"):SetFloat(Ldata.npc_hidden_FMK_huntsound_distance)
	GetConVar("npc_hidden_FMK_desired_speed"):SetFloat(Ldata.npc_hidden_FMK_desired_speed)
	GetConVar("npc_hidden_FMK_grenade_chance"):SetFloat(Ldata.npc_hidden_FMK_grenade_chance)
	GetConVar("npc_hidden_FMK_grenade_throw_sound"):SetBool(Ldata.npc_hidden_FMK_grenade_throw_sound)
	GetConVar("npc_hidden_FMK_grenade_interval"):SetFloat(Ldata.npc_hidden_FMK_grenade_interval)
	GetConVar("npc_hidden_FMK_chase_repath_interval"):SetFloat(Ldata.npc_hidden_FMK_chase_repath_interval)
	GetConVar("npc_hidden_FMK_respawn"):SetBool(Ldata.npc_hidden_FMK_respawn)
	GetConVar("npc_hidden_FMK_can_retreat"):SetBool(Ldata.npc_hidden_FMK_can_retreat)
	GetConVar("npc_hidden_FMK_shut_up"):SetBool(Ldata.npc_hidden_FMK_shut_up)
	
	print("The Hidden settings loaded from harddrive! See: garrysmod/data/thehidden_serversettings.json")
end)

concommand.Add( "npc_hidden_FMK_RESET_SERVER_SETTINGS", function()
	GetConVar("npc_hidden_FMK_screenshake"):Revert()
	GetConVar("npc_hidden_FMK_targeted_by_npcs"):Revert()
	GetConVar("npc_hidden_FMK_smash_props"):Revert()
	GetConVar("npc_hidden_FMK_allow_jump"):Revert()
	GetConVar("npc_hidden_FMK_spawn_protect"):Revert()
	GetConVar("npc_hidden_FMK_antistuck"):Revert()
	GetConVar("npc_hidden_FMK_legacy_model"):Revert()
	GetConVar("npc_hidden_FMK_ragdoll_messup"):Revert()
	GetConVar("npc_hidden_FMK_acquire_distance"):Revert()
	GetConVar("npc_hidden_FMK_damage"):Revert()
	GetConVar("npc_hidden_FMK_health"):Revert()
	GetConVar("npc_hidden_FMK_regen_on_attack"):Revert()
	GetConVar("npc_hidden_FMK_regen_per_sec"):Revert()
	GetConVar("npc_hidden_FMK_attack_interval"):Revert()
	GetConVar("npc_hidden_FMK_attack_force"):Revert()
	GetConVar("npc_hidden_FMK_huntsound_interval"):Revert()
	GetConVar("npc_hidden_FMK_huntsound_distance"):Revert()
	GetConVar("npc_hidden_FMK_desired_speed"):Revert()
	GetConVar("npc_hidden_FMK_grenade_chance"):Revert()
	GetConVar("npc_hidden_FMK_grenade_interval"):Revert()
	GetConVar("npc_hidden_FMK_grenade_throw_sound"):Revert()
	GetConVar("npc_hidden_FMK_chase_repath_interval"):Revert()
	GetConVar("npc_hidden_FMK_respawn"):Revert()
	GetConVar("npc_hidden_FMK_can_retreat"):Revert()
	GetConVar("npc_hidden_FMK_shut_up"):Revert()
end )

concommand.Add( "npc_hidden_FMK_REMOVE_ALL", function()
	local amount = 0
	for k, v in pairs( ents.GetAll() ) do
		if string.match(v:GetClass(),"npc_hidden_fmk") then
			v:Remove()
			amount = amount + 1
		end
	end
	print("Removed Hidden: "..amount)
end )

pcall(function() -- In case some other mod already made this category
	hook.Add( "AddToolMenuCategories", "TheHiddenCategory", function()
		spawnmenu.AddToolCategory( "Utilities", "NPC", "#NPC" )
	end )
end)


hook.Add( "PopulateToolMenu", "TheHiddenCategory", function()
	spawnmenu.AddToolMenuOption( "Utilities", "NPC", "Hidden_Menu", "#The Hidden settings", "", "", function( panel ) -- DForm
		panel:ClearControls()
		panel:Help("Client")
		local combobox, label = panel:ComboBox( "Visibility Mode", "npc_hidden_FMK_visibilitymode_client" )
		combobox:SetSortItems(false)
		combobox:AddChoice( "Invisible", 0)
		combobox:AddChoice( "Gas", 1)
		combobox:AddChoice( "Defau	lt Knife", 2)
		combobox:AddChoice( "Simple Knife", 3)
		combobox:AddChoice( "The Evil Bubble!", 5)
		combobox:AddChoice( "Distortion Wrap", 6)
		combobox:AddChoice( "Blue Energy", 8)
		combobox:AddChoice( "Custom", 7)
		panel:TextEntry("Custom Material", "npc_hidden_FMK_visibilitymode_custom_texture")
		panel:NumSlider( "Custom Mat. Size", "npc_hidden_FMK_visibilitymode_custom_texture_size", 1, 128)
		panel:Help(" ")
		panel:Help(" ")
		panel:Help("Server")
		panel:Button("Save server settings", "npc_hidden_FMK_SAVE_SERVER_SETTINGS")
		panel:Button("Load server settings", "npc_hidden_FMK_LOAD_SERVER_SETTINGS")
		panel:Button("Reset server settings", "npc_hidden_FMK_RESET_SERVER_SETTINGS")
		panel:CheckBox("Screenshake", "npc_hidden_FMK_screenshake")
		panel:CheckBox("NPCs scared/hostile", "npc_hidden_FMK_targeted_by_npcs")
		panel:CheckBox("Smash props", "npc_hidden_FMK_smash_props")
		panel:CheckBox("Can jump", "npc_hidden_FMK_allow_jump")
		panel:CheckBox("Player spawn protect", "npc_hidden_FMK_spawn_protect")
		panel:CheckBox("Antistuck system", "npc_hidden_FMK_antistuck")
		panel:CheckBox("Legacy model", "npc_hidden_FMK_legacy_model")
		panel:CheckBox("(Experimental) Ragdoll destruction", "npc_hidden_FMK_ragdoll_messup")
		panel:CheckBox("Can retreat", "npc_hidden_FMK_can_retreat")
		panel:CheckBox("Stop voicelines", "npc_hidden_FMK_shut_up")
		panel:NumSlider( "Hunt Range", "npc_hidden_FMK_acquire_distance", 1000, 10000)
		panel:NumSlider( "Damage", "npc_hidden_FMK_damage", 0, 1e8)
		panel:NumSlider( "Health", "npc_hidden_FMK_health", 0, 1000)
		panel:NumSlider( "Health per Second", "npc_hidden_FMK_regen_per_sec", 0, 250)
		panel:NumSlider( "Attack HP Regen", "npc_hidden_FMK_regen_on_attack", 0, 250)
		panel:NumSlider( "Attack interval (seconds)", "npc_hidden_FMK_attack_interval", 0.01, 1)
		panel:NumSlider( "Attack Force", "npc_hidden_FMK_attack_force", 1, 1000)
		panel:NumSlider( "Huntsound interval (seconds)", "npc_hidden_FMK_huntsound_interval", 1, 15)
		panel:NumSlider( "Huntsound max. distance", "npc_hidden_FMK_huntsound_distance", 650, 3000)
		panel:NumSlider( "Max. Speed", "npc_hidden_FMK_desired_speed", 0, 1000)
		panel:NumSlider( "Grenade Chance", "npc_hidden_FMK_grenade_chance", 0, 100)
		panel:NumSlider( "Grenade attempt interval (seconds)", "npc_hidden_FMK_grenade_interval", 2, 100)
		panel:CheckBox("Grenade Throw Sound", "npc_hidden_FMK_grenade_throw_sound")
		panel:Help("Every (interval) seconds, a dice is rolled. If it's below (grenade throw chance), then it will be thrown.")
		panel:NumSlider( "Chase Repath Interval", "npc_hidden_FMK_chase_repath_interval", 0.1, 1)	
		panel:Help(" ")
		panel:CheckBox("Respawn some time after death", "npc_hidden_FMK_respawn")
		panel:Help("Respawned Hiddens cannot be removed by the original creator. Host/Server must use this button to remove all Hiddens.")
		panel:Button("Remove all (current) Hidden NPCs", "npc_hidden_FMK_REMOVE_ALL")
	end )
end )

hook.Add( "PlayerSay", "TheHiddenDoNotSay", function( ply, text )
	local heckStart, heckEnd = string.find(text:lower(), "the hidden")
	if heckStart then
		if math.random(0,2) != 2 then goto chance2 end
		if !ply:Alive() then
			ply:EmitSound(Sound("freemankiller/nextbot/knife_stab.mp3"), math.random(10,25), math.random(98,102))
			return ""
		end
		local civilText = string.sub(text, 1, heckStart + math.random(-1,6))
		ply:TakeDamage(GetConVar("npc_hidden_FMK_damage"):GetFloat(), ply, ply)
		ply:EmitSound(Sound("freemankiller/nextbot/knife_stab.mp3"), math.random(35,45), math.random(98,102))
		return civilText
	end
	::chance2::
	heckStart, heckEnd = string.find(text:lower(), "617")
	if heckStart then
		if math.random(0,2) != 2 then return end
		if !ply:Alive() then
			ply:EmitSound(Sound("freemankiller/nextbot/knife_stab.mp3"), math.random(10,25), math.random(98,102))
			return ""
		end
		local civilText = string.sub(text, 1, heckStart + math.random(0,1))
		ply:TakeDamage(GetConVar("npc_hidden_FMK_damage"):GetFloat(), ply, ply)
		ply:EmitSound(Sound("freemankiller/nextbot/knife_stab.mp3"), math.random(35,45), math.random(98,102))
		return civilText
	end
end )

--
-- List the NPC as spawnable.
--
list.Set("NPC", "npc_hidden_FMK", {
	Name = "The Hidden",
	Class = "npc_hidden_FMK",
	Category = "Nextbot",
	AdminOnly = false
})																																																									
