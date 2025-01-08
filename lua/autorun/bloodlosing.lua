hook.Add("PlayerSpawn","homigrad-blood",function(ply)
	if timer.Exists("respawntimer"..ply:EntIndex()) then return end
	ply.IsBleeding = false
	BleedingEntities[ply] = nil
	ply.Blood = 5000
	ply.BloodLosing=0
	ply.stamina = 100
	ply.LeftLeg = 1
	ply.RightLeg = 1
	ply.RightArm = 1
	ply.LeftArm = 1
	ply.Attacker = nil
	ply.Blood = 5000
	ply:ConCommand("soundfade 0 1")
	ply.bloodNext = CurTime()
	ply.OrgansNextThink = CurTime()
end)
if SERVER then
function player.GetListByName(name)
	local list = {}

	if name == "^" then
		return
	elseif name == "*" then

		return player.GetAll()
	end

	for i,ply in pairs(player.GetAll()) do
		if string.find(string.lower(ply:Name()),string.lower(name)) then list[#list + 1] = ply end
	end

	return list
end
util.AddNetworkString("info_blood")
util.AddNetworkString("blood particle")
util.AddNetworkString("blood particle headshoot")
util.AddNetworkString("blood particle explode")
util.AddNetworkString("organism_info")
end
function BloodParticle(pos,vel)
	net.Start("blood particle")
	net.WriteVector(pos)
	net.WriteVector(vel)
	net.Broadcast()
end
function BloodParticleHeadshoot(pos,vel)
	net.Start("blood particle headshoot")
	net.WriteVector(pos)
	net.WriteVector(vel)
	net.Broadcast()
end
function BloodParticleExplode(pos)
	net.Start("blood particle explode")
	net.WriteVector(pos)
	net.Broadcast()
end
BleedingEntities = BleedingEntities or {}

hook.Add("HomigradDamage","phildcorn",function(ply,hitGroup,dmginfo,rag)
	if not dmginfo:IsDamageType(DMG_BULLET+DMG_SLASH+DMG_BLAST+DMG_ENERGYBEAM+DMG_NEVERGIB+DMG_ALWAYSGIB+DMG_PLASMA+DMG_AIRBOAT+DMG_SNIPER+DMG_BUCKSHOT) then return end
	local dmg
	if dmginfo:IsDamageType(DMG_BUCKSHOT+DMG_SLASH) then 
		dmg = dmginfo:GetDamage() * 4
	else 
		dmg = dmginfo:GetDamage() 
	end

	ply.BloodLosing = ply.BloodLosing + dmg
end)

local tr = {filter = {}}
local math_Clamp = math.Clamp
bleedinginterval = math.random(0.25,1)
local util_TraceHull = util.TraceHull
local math_Rand = math.Rand
local util_Decal = util.Decal



hook.Add("Player Think", "homigrad-blood", function(ply, CurTime)
    if not ply:Alive() or ply:HasGodMode() or ply.bloodNext > CurTime then return end
    local ragg = ply:GetNWEntity('player_ragdoll')
	local rg = ply:GetNWEntity('player_ragdoll')
    local ent
    if IsValid(ragg) and ply:IsRag() then
        ent = ragg
    else
        ent = ply 
    end
    ply.Organs = ply.Organs or {}
	if ply.BloodLosing == 0 then
		BleedingEntities[rg] = nil
	end
	if ply.Blood == 0 then
	ply:Kill()
	end
	if ent:IsPlayer() and ent:GetMoveType() ~= MOVETYPE_OBSERVER then
		local neck = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Neck1")):GetTranslation()
	end
 
    if ply.BloodLosing > 0 then
        ply.BloodLosing = ply.BloodLosing - 0.5
        ply.Blood = math.max(ply.Blood - ply.BloodLosing / 2, 0)
		ply.pain = ply.pain + ply.BloodLosing / 10
        BloodParticle(ent:GetPos() + ent:OBBCenter(), VectorRand(-15, 15))
		print(tostring(ply:Nick().." "..ply.BloodLosing .. " КРОВОПОТЕРЯ. АКТУАЛЬНАЯ КРОВЬ: " .. ply.Blood .. ". БОЛЬ: " .. ply.pain))
    elseif ply.Blood < 5000 then
        ply.Blood = ply.Blood
    end


    local randomDelay = math.random(0.75, 3)

    ply.bloodNext = CurTime + 0.25
end)


local math_random = math.random
local CurTime = CurTime
local time

local tr = {}

local randVec = Vector(0,0,-1)
OrgansNextThink = 0
InternalBleeding = 20
local player_GetAll = player.GetAll

hook.Add("Player Think","InternalBleeding",function(ply,time)
	for i,ply in pairs(player_GetAll()) do
		ply.OrgansNextThink = ply.OrgansNextThink or OrgansNextThink
		if not(ply.OrgansNextThink>CurTime())then
			ply.OrgansNextThink=CurTime() + math.random(0.2)
			if ply.Organs and ply:Alive() then
				if ply.Organs["brain"]==0 then
					ply:Kill()
				end
				if ply.Organs["liver"]==0 then
					ply.InternalBleeding=ply.InternalBleeding or InternalBleeding
					ply.InternalBleeding=math.max(ply.InternalBleeding-0.1,0)
					ply.Blood=ply.Blood-ply.InternalBleeding / 10
					RADS_Bleed(ply)
				end
				if ply.Organs["stomach"]==0 then
					ply.InternalBleeding2=ply.InternalBleeding2 or InternalBleeding
					ply.InternalBleeding2=math.max(ply.InternalBleeding2-0.1,0)
					ply.Blood=ply.Blood-ply.InternalBleeding2 / 10
					if ply:IsRag() then
						local rag = ply:GetNWEntity('player_ragdoll')
						rag.Blood = ply.Blood
						RADS_Bleed(rag)
						else
						ply.Blood = ply.Blood
						RADS_Bleed(ply)
						end
				end
				if ply.Organs["intestines"]==0 then
					ply.InternalBleeding3=ply.InternalBleeding3 or InternalBleeding
					ply.InternalBleeding3=math.max(ply.InternalBleeding3-0.1,0)
					ply.Blood=ply.Blood-ply.InternalBleeding3 / 10
					if ply:IsRag() then
						local rag = ply:GetNWEntity('player_ragdoll')
						RADS_Bleed(rag)
						else
						RADS_Bleed(ply)
						end
				end
				if ply.Organs["heart"]== 0 then
					ply.InternalBleeding4=ply.InternalBleeding4 or InternalBleeding
					ply.InternalBleeding4=math.max(ply.InternalBleeding4*10-0.1,0)
					ply.Blood=ply.Blood-ply.InternalBleeding4*3 / 10
					if ply:IsRag() then
						local rag = ply:GetNWEntity('player_ragdoll')
						rag.Blood = ply.Blood
						RADS_Bleed(rag)
						else
						ply.Blood = ply.Blood
						RADS_Bleed(ply)
						end
				end
				if ply.Organs["lungs"]== 0 then
					ply.InternalBleeding5=ply.InternalBleeding5 or InternalBleeding
					ply.InternalBleeding5=math.max(ply.InternalBleeding5-0.1,0)
					ply.Blood=ply.Blood-ply.InternalBleeding5 / 10
					if ply:IsRag() then
						local rag = ply:GetNWEntity('player_ragdoll')
						rag.Blood = ply.Blood
						RADS_Bleed(rag)
						else
						ply.Blood = ply.Blood
						RADS_Bleed(ply)
						end
				end
				ply.InternalBleeding6 = ply.InternalBleeding6 or 0
				ply.InternalBleeding6 = math.max(ply.InternalBleeding6-0.1,0)
				ply.Blood = ply.Blood - ply.InternalBleeding6 / 10

				if ply.Organs["spine"]==0 then
					ply.brokenspine=true
					if !ply.fake then rads(ply) end
				end
			end
		end
	end
end)
function remtbl(entf)
    for i, ent in ipairs(BleedingEntities) do
        if ent == entf then
            table.remove(BleedingEntities, i)
            break 
        end
    end
end
concommand.Add("zblood",function(ply)
	local r = ply:GetEyeTrace().Entity
	remtbl(r)
end)
hook.Add("Think","homigrad-bleeding-ents",function()
	time = CurTime()
	for i,ent in pairs(BleedingEntities) do
		if not IsValid(ent) or ent:IsPlayer() then continue end

		ent.bloodNext = ent.bloodNext or time
		if ent.bloodNext > time then continue end
		ent.bloodNext = time + 0.25
		BloodParticle(ent:GetPos() + ent:OBBCenter(),VectorRand(-15,15))
		ent.Blood = ent.Blood or 1500
		ent.Blood = math.min(0,ent.Blood - 35)
		if ent.Blood <= math.random(-3500,-100) then remtbl(ent) end
	end
end)

hook.Add("PlayerDeath","deathblood",function(ply)
	ply.Blood = 5000
	ply.BloodLosing = 0
	ply.LeftLeg = 1
	ply.RightLeg = 1
	ply.RightArm = 1
	ply.LeftArm = 1
	ply.brokenspine = false
	ply:ConCommand("soundfade 0 1")
	ply:SetDSP(0)
	net.Start("info_blood")
	net.WriteFloat(ply.Blood)
	net.Send(ply)
end)

concommand.Add("!r_organisminfo", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    local targetPlayer = nil
    local targetName = args[1]
    for _, playerObj in ipairs(player.GetAll()) do
        if playerObj:Name() == targetName then
            targetPlayer = playerObj
            break
        end
    end
    if not targetPlayer then
        targetPlayer = ply
    end
    net.Start("organism_info")
    net.WriteTable(targetPlayer.Organs)
    net.WriteString(
        "Кровь (мл): " .. tostring(targetPlayer.Blood) .. "\n" ..
        "Кровотечение (мл/удар): " .. tostring(targetPlayer.BloodLosing) .. "\n" ..
        "Боль: " .. tostring(targetPlayer.pain) .. "\n" ..
        "Игрок: " .. targetPlayer:Name()
    )
    net.Send(ply)
end)


concommand.Add("!r_organismsetvalue",function(ply,cmd,args)
	if not ply:IsAdmin() then return end
	
	local huyply = args[3] and player.GetListByName(args[3])[1] or ply
	
	huyply.Organs[args[1]] = args[2]
end)