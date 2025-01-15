local bleedsounds = {"player/pl_pain1.wav", "player/pl_pain2.wav", "player/damage1.wav",  "player/pl_pain3.wav", "player/damage2.wav", "player/damage3.wav", "player/pl_pain5.wav", "player/pl_pain6.wav", "player/pl_pain6.wav", "player/pl_pain4.wav"}
--урон по разным костям регдолла
local r_tooth = math.random(4,9)

local Organs = {
    ["brain"] = 20,
    ["lungs"] = 30,
    ["liver"] = 30,
    ["stomach"] = 40,
    ["intestines"] = 40,
    ["heart"] = 10,
    ["artery"] = 1,
    ["spine"] = 10,
    ["pelvis"] = 1,
	["kidneys"] = 25,
	["pancreas"] = 20,
	["spleen"] = 15,
	["ribs"] = 35
}

local LiverTimers = {}
local AortaTimers = {}
local MouthTimers = {}
local TraheaTimers = {}
local HeartTimers = {}
local LungTimers = {}
local AllTimers = {}
local walkSpeeds = {}
local runSpeeds = {}

local function HandleOrganDamage(target, dmginfo)
    local bullet_force = dmginfo:GetDamageForce()
    local bullet_pos = dmginfo:GetDamagePosition()
	local damage = dmginfo:GetDamage() or 0
    if not target.Organs then
        target.Organs = Organs
    end

    if target:IsPlayer() and dmginfo:IsBulletDamage() then
        local attacker = dmginfo:GetAttacker()
        if attacker and attacker:IsPlayer() and attacker:GetActiveWeapon() then
            if attacker:GetActiveWeapon():GetClass() != "wep_mann_hmcd_pnevmat" then
                local pos,ang = target:GetBonePosition(target:LookupBone('ValveBiped.Bip01_Head1'))
                local head = util.IntersectRayWithOBB(bullet_pos,bullet_force, pos, ang, Vector(2,-5,-3),Vector(7,3,3))
                local mouth = util.IntersectRayWithOBB(bullet_pos,bullet_force, pos, ang, Vector(-1,-5,-3),Vector(2,1,3))
                local trahea = util.IntersectRayWithOBB(bullet_pos,bullet_force, pos, ang, Vector(-9,-1,-0.8), Vector(-2,0.2,0.8))
                
                local pos1, ang1 = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Spine1"))
                local aorta = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos1, ang1, Vector(-4, 1, 1), Vector(4, 2, 2))
				local liver = util.IntersectRayWithOBB(bullet_pos,bullet_force, pos1, ang1, Vector(-1,-2,-5),Vector(4,4,1))
                local kidneys = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos1, ang1, Vector(-6, -3, -2), Vector(2, 3, 4))
                local pancreas = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos1, ang1, Vector(-5, -2, -1), Vector(3, 2, 3))
                local spleen = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos1, ang1, Vector(-7, -3, -1), Vector(-3, 2, 4))


                local pos2, ang2 = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Spine2"))
                local lung = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos2, ang2, Vector(1, -1, -6), Vector(8, 7, 6))
				local heart = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos2, ang2, Vector(1, 0, -1), Vector(5, 4, 3))
                local rib = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos2, ang2, Vector(-4,-6,-1), Vector(7,10,1))
                
                local pos3, ang3 = target:GetBonePosition(target:LookupBone('ValveBiped.Bip01_Pelvis'))
                local pelvis = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos3, ang3, Vector(-4, -3, -3), Vector(4, 3, 3))

				 local pos5, ang5 = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Spine4"))
                 local spine = util.IntersectRayWithOBB(bullet_pos,bullet_force, pos5, ang5, Vector(-8, -1, -1), Vector(2, 0, 1))
				 local pos6, ang6 = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Spine1"))
				 local spine2 = util.IntersectRayWithOBB(bullet_pos,bullet_force, pos6, ang6, Vector(-8, -3, -1), Vector(2, -2, 1))


                local pos7, ang7 = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Head1"))
                local artery1 = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos7, ang7, Vector(-3, -2, -2), Vector(0, -1, -1))
                local artery2 = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos7, ang7, Vector(-3, -2, 1), Vector(0, -1, 2))
                 
                local rib2 = util.IntersectRayWithOBB(bullet_pos, bullet_force, pos1, ang1, Vector(-4,-6,-1), Vector(7,10,1))
                
				local timerName = "organ_timer" .. target:SteamID()
                if head then
                    print("Head Hitted")
					target:ChatPrint("Вы получили повреждение мозга!")
                    target:Kill()
					target.Organs["brain"] = 0
					target:EmitSound("NPC_Barnacle.BreakNeck", 511, 200, 1, CHAN_ITEM)
                end

                if mouth then
                    print("Mouth Hitted")
					target:ChatPrint("Пуля попала вам в область рта, ваша челюсть свисает, вы лишились нескольких зубов.")
                    target:SetNWInt("Tooth", target:GetNWInt("Tooth", 32) - r_tooth)
                    target:SetNWBool("ArterialBleeding", true)
                    timer.Create(timerName, 0.3, 0, function()
						if not IsValid(target) then timer.Remove(timerName); return end
                        local handPos, handAng = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Neck1"))
                        local bloodPos = handPos + handAng:Forward() * 50
                        local bloodTrace = util.TraceLine({
                            start = bloodPos,
                            endpos = bloodPos - Vector(0, 0, 100),
                            filter = target
                        })
						if not IsValid(target) then timer.Remove(timerName); return end
                        target:SetWalkSpeed(50)
                        target:SetRunSpeed(100)
                        if bloodTrace.Hit then
                            if default_dblood == false then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal(table.Random(artery_paint), bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
                            if default_dblood == true then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal("Blood", bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
							if not IsValid(target) then timer.Remove(timerName); return end
                            target:SetNWInt("Blood", target:GetNWInt("Blood", 5000) - 10)
                            target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 1)
                            target:EmitSound(table.Random(bleedsounds), 75, 100, 1, CHAN_AUTO)
                        end
                    end)
                     AllTimers[timerName] = timerName
					MouthTimers[target:SteamID()] = timerName
                end

                if trahea then
                    print("Trahea hit")
					target:ChatPrint("Пуля попала вам в трахею, дыхание затруднено.")
                    target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 30)
                     local timerName = "organ_timer" .. target:SteamID()
                    timer.Create(timerName, 3, 0, function()
						if not IsValid(target) then timer.Remove(timerName); return end
                        local handPos, handAng = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Head1"))
                        local bloodPos = handPos + handAng:Forward() * 50
                        local bloodTrace = util.TraceLine({
                            start = bloodPos,
                            endpos = bloodPos - Vector(0, 0, 100),
                            filter = target
                        })
                        if bloodTrace.Hit then
                            if default_dblood == false then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal(table.Random(venous_paint), bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
                            if default_dblood == true then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal("Blood", bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
							if not IsValid(target) then timer.Remove(timerName); return end
                            target:SetNWInt("Blood", target:GetNWInt("Blood", 5000) - target:GetNWInt("O2", 100) / 3)
                            target:SetNWInt("O2", target:GetNWInt("O2", 100) - 15)
                        end
                    end)
                     AllTimers[timerName] = timerName
                     TraheaTimers[target:SteamID()] = timerName
                end
                
                if aorta then
                    print("Aorta Hitted")
					 target:ChatPrint("В вас попали! У вас разорвалась аорта!")
                    target:EmitSound("player/pl_pain5.wav", 75, 100, 1, CHAN_AUTO)
                    target:EmitSound("player/breathe1.wav", 75, 100, 1, CHAN_AUTO)
                    target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 20)
                    target:SetNWBool("ArterialBleeding", true)
					target.aorta = true
                    local timerName = "organ_timer" .. target:SteamID()
                    timer.Create(timerName, 0.3, 0, function()
						if not IsValid(target) then timer.Remove(timerName); return end
                        local handPos, handAng = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Spine2"))
                        local bloodPos = handPos + handAng:Forward() * 50
                        local bloodTrace = util.TraceLine({
                            start = bloodPos,
                            endpos = bloodPos - Vector(0, 0, 100),
                            filter = target
                        })
						if not IsValid(target) then timer.Remove(timerName); return end
                        target:SetWalkSpeed(50)
                        target:SetRunSpeed(100)
                        if bloodTrace.Hit then
                            if default_dblood == false then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal(table.Random(artery_paint), bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
                            if default_dblood == true then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal("Blood", bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
							if not IsValid(target) then timer.Remove(timerName); return end
                            target:SetNWInt("Blood", target:GetNWInt("Blood", 5000) - 10)
                            target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 2)
                            target:EmitSound(table.Random(bleedsounds), 75, 100, 1, CHAN_AUTO)
                        end
                    end)
                     AllTimers[timerName] = timerName
                    AortaTimers[target:SteamID()] = timerName
                end

                if heart then
					if not IsValid(target) then return end
                    print("Heart Hitted")
					target:ChatPrint("Бум, вам попали в сердце, у вас сильная отдышка и очень массивная боль.")
                    target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 30)
                    target:SetNWBool("ArterialBleeding", true)
                    local timerName = "organ_timer" .. target:SteamID()
                    timer.Create(timerName, 0.3, 0, function()
						if not IsValid(target) then timer.Remove(timerName); return end
                        local handPos, handAng = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Spine2"))
                        local bloodPos = handPos + handAng:Forward() * 50
                        local bloodTrace = util.TraceLine({
                            start = bloodPos,
                            endpos = bloodPos - Vector(0, 0, 100),
                            filter = target
                        })
						if not IsValid(target) then timer.Remove(timerName); return end
                        target:SetWalkSpeed(50)
                        target:SetRunSpeed(100)
                        if bloodTrace.Hit then
                            if default_dblood == false then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal(table.Random(artery_paint), bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
                            if default_dblood == true then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal("Blood", bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
							if not IsValid(target) then timer.Remove(timerName); return end
                            target:SetNWInt("Blood", target:GetNWInt("Blood", 5000) - 10)
                            target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 2)
                            target:EmitSound(table.Random(bleedsounds), 75, 100, 1, CHAN_AUTO)
                        end
                    end)
                    AllTimers[timerName] = timerName
                    HeartTimers[target:SteamID()] = timerName
                end

                if lung then
					if not IsValid(target) then return end
                    print("Lung Hitted")
					target:ChatPrint("Вы чувствуете, что ваша грудная клетка переполняется кислородом, видимо у вас пневмоторакс! Вы кашляете кровью!")
                     local timerName = "organ_timer" .. target:SteamID()
                    timer.Create(timerName, 3, 0, function()
						if not IsValid(target) then timer.Remove(timerName); return end
                        local handPos, handAng = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Head1"))
                        local bloodPos = handPos + handAng:Forward() * 50
                        local bloodTrace = util.TraceLine({
                            start = bloodPos,
                            endpos = bloodPos - Vector(0, 0, 100),
                            filter = target
                        })
                        if bloodTrace.Hit then
                            if default_dblood == false then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal(table.Random(venous_paint), bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
                            if default_dblood == true then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal("Blood", bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
							if not IsValid(target) then timer.Remove(timerName); return end
                            target:SetNWInt("Blood", target:GetNWInt("Blood", 5000) - target:GetNWInt("O2", 100) / 5)
                            target:SetNWInt("O2", target:GetNWInt("O2", 100) - 15)
                        end
                    end)
                    AllTimers[timerName] = timerName
                    LungTimers[target:SteamID()] = timerName
                end
                
                if pelvis then
					if not IsValid(target) then return end
                    print("Pelvis Hitted")
					 target:ChatPrint("Вам сломало таз! Это довольно сильная боль!")
                    target:EmitSound("player/pl_pain5.wav", 75, 100, 1, CHAN_AUTO)
                    target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 30)
                    target:SetWalkSpeed(50)
                    target:SetRunSpeed(100)
                    timer.Simple(1, function() if IsValid(target) then target:SetWalkSpeed(200); target:SetRunSpeed(300) end end)
                    target.Organs["pelvis"] = 0
                end
				
                if liver then
					if not IsValid(target) then return end
                    print("Liver Hitted")
					target:ChatPrint("Ваша печень повреждена!")
                    target:EmitSound("player/pl_pain5.wav", 75, 100, 1, CHAN_AUTO)
                    target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 10)
                    target:SetNWBool("LiverBleeding", true)
                    local timerName = "organ_timer" .. target:SteamID()
                    timer.Create(timerName, 0.6, 0, function()
						if not IsValid(target) then timer.Remove(timerName); return end
                        local handPos, handAng = target:GetBonePosition(target:LookupBone("ValveBiped.Bip01_Spine"))
                        local bloodPos = handPos + handAng:Forward() * 50
                        local bloodTrace = util.TraceLine({
                            start = bloodPos,
                            endpos = bloodPos - Vector(0, 0, 100),
                            filter = target
                        })
						if not IsValid(target) then timer.Remove(timerName); return end
                        target:SetWalkSpeed(50)
                        target:SetRunSpeed(100)
                        if bloodTrace.Hit then
                            if default_dblood == false then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal("Cross", bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
                            if default_dblood == true then
								if not IsValid(target) then timer.Remove(timerName); return end
                                util.Decal("Blood", bloodTrace.HitPos + bloodTrace.HitNormal, bloodTrace.HitPos - bloodTrace.HitNormal)
                            end
							if not IsValid(target) then timer.Remove(timerName); return end
                            target:SetNWInt("Blood", target:GetNWInt("Blood", 5000) - 10)
                            target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 2)
                            target:EmitSound(table.Random(bleedsounds), 75, 100, 1, CHAN_AUTO)
                        end
                    end)
                    AllTimers[timerName] = timerName
                     LiverTimers[target:SteamID()] = timerName
                end
				 if artery1 or artery2 then
					if target.Organs["artery"] ~= 0 then
						target.Organs["artery"] = math.Clamp((target.Organs["artery"] or 1) - damage, 0, 1)
						if target.Organs["artery"] == 0 then
							if not target.fake then
								Faking(target)
							end
						end
					end
                end
				if spine or spine2 then
					if target.Organs["spine"] ~= 0 then
						target.Organs["spine"] = math.Clamp((target.Organs["spine"] or 10) - damage, 0, 10)
						if target.Organs["spine"] == 0 then
							if not target.fake then
								Faking(target)
								target:ChatPrint("Your spine was broken.")
							end
						end
					end
				end
                if kidneys then
					if not IsValid(target) then return end
                    print("kidneys Hitted")
					 target:ChatPrint("У вас повреждены почки!")
                    target.Organs["kidneys"] = math.Clamp((target.Organs["kidneys"] or 25) - damage, 0, 25)
                    target:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 60, math.random(230, 240), 0.1, CHAN_AUTO)
					if target:IsPlayer() then
					  target:SetWalkSpeed(math.max(target:GetWalkSpeed() - 30, 0))
                     target:SetRunSpeed(math.max(target:GetRunSpeed() - 30, 0))
					  target:SetNWInt("Pain", target:GetNWInt("Pain", 0) + 10)
					 end
                end

                if pancreas then
					if not IsValid(target) then return end
                    print("pancreas Hitted")
					target:ChatPrint("У вас повреждена поджелудочная железа!")
                    target.Organs["pancreas"] = math.Clamp((target.Organs["pancreas"] or 20) - damage, 0, 20)
					 target:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 60, math.random(230, 240), 0.1, CHAN_AUTO)
					if target:IsPlayer() then
					 target.stamina = math.max(target.stamina - 15, 0)
					 end
                end
				
                 if spleen then
					if not IsValid(target) then return end
                    print("spleen Hitted")
					 target:ChatPrint("У вас повреждена селезёнка!")
                     target.Organs["spleen"] = math.Clamp((target.Organs["spleen"] or 15) - damage, 0, 15)
                     target:EmitSound("ambient/water/drip" .. math.random(1, 4) .. ".wav", 60, math.random(230, 240), 0.1, CHAN_AUTO)
					 if target:IsPlayer() then
					  target.arterybloodlosing = math.min(target.arterybloodlosing + 20, 250)
					end
                end

                 if rib or rib2 then
					if not IsValid(target) then return end
					if target.Organs["ribs"] ~= 0 then
						 target:ChatPrint("Вам сломало ребра!")
                         target.Organs["ribs"] = math.Clamp((target.Organs["ribs"] or 35) - (damage or 0), 0, 35)
                         target:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						  if target:IsPlayer() then
						 target:SetWalkSpeed(math.max(target:GetWalkSpeed() - 15, 0))
                         target:SetRunSpeed(math.max(target:GetRunSpeed() - 15, 0))
					    end
					end
                end
            end
        end
    end
end

hook.Add("PlayerDeath", "PlayerDeathCancelTimers", function(ply, attacker, dmginfo)
    for timerName, _ in pairs(AllTimers) do
		if string.find(timerName, ply:SteamID()) then
			timer.Remove(timerName)
		end
    end
    if LiverTimers[ply:SteamID()] then LiverTimers[ply:SteamID()] = nil end
    if AortaTimers[ply:SteamID()] then AortaTimers[ply:SteamID()] = nil end
    if MouthTimers[ply:SteamID()] then MouthTimers[ply:SteamID()] = nil end
    if TraheaTimers[ply:SteamID()] then TraheaTimers[ply:SteamID()] = nil end
    if HeartTimers[ply:SteamID()] then HeartTimers[ply:SteamID()] = nil end
      if LungTimers[ply:SteamID()] then LungTimers[ply:SteamID()] = nil end
	  walkSpeeds[ply] = nil
    runSpeeds[ply] = nil
    if ply.Organs then
        for organName, _ in pairs(ply.Organs) do
            ply.Organs[organName] = Organs[organName]
        end
	 end
end)

concommand.Add("reseteffects", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsPlayer() then return end
   
    for timerName, _ in pairs(AllTimers) do
		if string.find(timerName, ply:SteamID()) then
			timer.Remove(timerName)
		end
    end
    -- Сброс переменных
    ply.Blood = 5000
	ply:SetNWInt("Blood", ply.Blood)
    ply.Bloodlosing = 0
	ply:SetNWInt("BloodLosing", 0)
    ply.arterybloodlosing = 0
	ply.stamina = 100
	ply:SetNWInt("stamina", ply.stamina)
    ply.IsBleeding = false
    ply.aorta = false
    ply.brokenspine = false
    if ply.Organs then
        for organName, _ in pairs(ply.Organs) do
            ply.Organs[organName] = Organs[organName]
        end
	 end
	ply.LeftLeg = 1
	ply.RightLeg = 1
	ply.RightArm = 1
	ply.LeftArm = 1
    ply:SetWalkSpeed(200)
    ply:SetRunSpeed(300)
	ply:SetJumpPower(190)
	
    ply:ChatPrint("Эффекты сброшены.")
end)

hook.Add(
    "EntityTakeDamage",
    "ragdamage",
    function(ent, dmginfo)
        if ent.deadbody and not ent.IsBleeding and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then
            ent.IsBleeding = true
        end

        local trace = util.QuickTrace(dmginfo:GetDamagePosition(), dmginfo:GetDamageForce():GetNormalized() * 100)
        local bone = trace.PhysicsBone
        local hitgroup
        local isfall
        local bonename = ent:GetBoneName(bone)
        if bonetohitgroup[bonename] ~= nil then
            hitgroup = bonetohitgroup[bonename]
        end

        if RagdollDamageBoneMul[hitgroup] then
            if RagdollOwner(ent) then
                dmginfo:ScaleDamage(0.3)
                timer.Create("faketimer" .. RagdollOwner(ent):EntIndex(), dmginfo:GetDamage() / 30, 1, function() end)
                if hitgroup == HITGROUP_HEAD then
                    if dmginfo:GetAttacker():IsRagdoll() then return end
                    dmginfo:ScaleDamage(2)
                    if dmginfo:GetDamageType() == 2 then
                        dmginfo:ScaleDamage(2)
                    end

                    if dmginfo:GetDamageType() == 1 and dmginfo:GetDamage() > 6 and ent:GetVelocity():Length() > 500 then
                        if IsValid(RagdollOwner(ent)) then
                            RagdollOwner(ent):ChatPrint("Your neck was broken")
						    ent:EmitSound("NPC_Barnacle.BreakNeck", 511, 200, 1, CHAN_ITEM)
                        end
                        dmginfo:ScaleDamage(1000000)
                    end

                    if dmginfo:GetDamageType() == 1 and dmginfo:GetDamage() > 5 and ent:GetVelocity():Length() > 220 and RagdollOwner(ent).Otrub == 0 then
						if IsValid(RagdollOwner(ent)) then
                           RagdollOwner(ent).pain = 270
						end
                    end
                end

                if hitgroup == HITGROUP_LEFTARM then
                    if dmginfo:GetAttacker():IsRagdoll() then return end
                    dmginfo:ScaleDamage(0.3)
                    if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 10 and RagdollOwner(ent).LeftArm > 0.6 then
						if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your left arm was broken")
						 ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						 RagdollOwner(ent).LeftArm = 0.6
						  dmginfo:ScaleDamage(0.3)
						end
					end

                    if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).LeftArm > 0.6 then
						if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your left arm was broken")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						 RagdollOwner(ent).LeftArm = 0.6
						 dmginfo:ScaleDamage(0.3)
						 end
                    end
                end

                if hitgroup == HITGROUP_LEFTLEG then
                    if dmginfo:GetAttacker():IsRagdoll() then return end
                    dmginfo:ScaleDamage(0.3)
                    if dmginfo:GetDamageType() == 2 then end
                    if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 15 and RagdollOwner(ent).LeftLeg > 0.6 then
						if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your left leg was broken")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).LeftLeg = 0.6
						dmginfo:ScaleDamage(0.3)
						end
					end

                    if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).LeftLeg > 0.6 then
					if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your left leg was broken")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						 RagdollOwner(ent).LeftLeg = 0.6
						 dmginfo:ScaleDamage(0.3)
					end
					end
                end

                if hitgroup == HITGROUP_RIGHTLEG then
                    if dmginfo:GetAttacker():IsRagdoll() then return end
                    dmginfo:ScaleDamage(0.3)
                    if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 15 and RagdollOwner(ent).RightLeg > 0.6 then
						if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your right leg was broken")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightLeg = 0.6
						dmginfo:ScaleDamage(0.3)
						end
					end

                    if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).RightLeg > 0.6 then
						if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your right leg was broken")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightLeg = 0.6
						dmginfo:ScaleDamage(0.3)
						end
                    end
                end

                if hitgroup == HITGROUP_RIGHTARM then
                    if dmginfo:GetAttacker():IsRagdoll() then return end
                    dmginfo:ScaleDamage(0.3)
                    if dmginfo:GetDamageType() == 2 and dmginfo:GetDamage() > 10 and RagdollOwner(ent).RightArm > 0.6 then
						if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your right hand was broken")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightArm = 0.6
						dmginfo:ScaleDamage(0.3)
						end
					end

                    if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 600 and RagdollOwner(ent).RightArm > 0.6 then
						if IsValid(RagdollOwner(ent)) then
                        RagdollOwner(ent):ChatPrint("Your right hand was broken")
						ent:EmitSound("NPC_Barnacle.BreakNeck", 100, 200, 1, CHAN_ITEM)
						RagdollOwner(ent).RightArm = 0.6
						dmginfo:ScaleDamage(0.3)
						end
					end
                end

                 if hitgroup == HITGROUP_CHEST then
                    if dmginfo:GetAttacker():IsRagdoll() then return end
                    if dmginfo:GetDamageType() == 1 and ent:GetVelocity():Length() > 800 and  IsValid(RagdollOwner(ent)) and RagdollOwner(ent).Organs["spine"] > 0 then
						
                            RagdollOwner(ent).brokenspine = true
                            RagdollOwner(ent).Organs["spine"] = 0
							RagdollOwner(ent):ChatPrint("Your spine was broken.")
							ent:EmitSound("NPC_Barnacle.BreakNeck", 511, 200, 1, CHAN_ITEM)
                            dmginfo:ScaleDamage(0.3)
                        end
                    dmginfo:ScaleDamage(0.8)
                end

                if hitgroup == HITGROUP_STOMACH then
                    if dmginfo:GetAttacker():IsRagdoll() then return end
                    dmginfo:ScaleDamage(0.5)
                end
            end

            if ent:IsPlayer() or IsValid(RagdollOwner(ent)) then
                HandleOrganDamage(ent, dmginfo)
            end

            
            if IsValid(RagdollOwner(ent)) then
                RagdollOwner(ent).LastHit = bonename
            elseif ent:IsPlayer() then
                ent.LastHit = bonename
            end
        end

        if IsValid(RagdollOwner(ent)) then
            if dmginfo:GetDamageType() == 1 then
                if dmginfo:GetAttacker():IsRagdoll() then
                    RagdollOwner(ent):SetHealth(RagdollOwner(ent):Health())
                else
                    RagdollOwner(ent):SetHealth(RagdollOwner(ent):Health() - dmginfo:GetDamage() / 100)
                end
            end

            RagdollOwner(ent):TakeDamageInfo(dmginfo)
            if RagdollOwner(ent):Health() <= 0 and RagdollOwner(ent):Alive() then
                RagdollOwner(ent):Kill()
            end
        end
    end
)
