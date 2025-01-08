if SERVER then util.AddNetworkString('info_org') end
function RADS_SendINFO(ply)
    if not IsValid(ply) then return end
    net.Start("info_org")
    net.WriteTable({
        pain = ply.pain or 0,
        painlosing = ply.painlosing or false,
        organs = ply.Organs
    })

    net.Send(ply)
end

function RADS_Bleed(ent)
    table.insert(BleedingEntities, ent)
end

hook.Add("HomigradDamage", tostring(math.random(9999, 99999)), function(ply, hitGroup, dmginfo, rag)
    if dmginfo:GetAttacker():IsRagdoll() then return end
    local dmg = dmginfo:GetDamage()
    dmg = dmg * 1.3
    if dmginfo:IsDamageType(DMG_BLAST + DMG_SLASH + DMG_BULLET) then -- print(dmg,"1")
        if dmginfo:IsDamageType(DMG_SLASH) then dmg = dmg * 4.5 end
        if dmginfo:IsDamageType(DMG_BULLET) then -- print(dmg,"2")
            dmg = dmg
        end

        dmg = dmg * 2 -- print(dmg,"3")
    elseif dmginfo:IsDamageType(DMG_VEHICLE + DMG_CRUSH + DMG_BUCKSHOT + DMG_GENERIC) then
        dmg = dmg * 1.5 -- print(dmg,"4") -- print(dmginfo:GetDamageForce(),"сила дмг")
    elseif dmginfo:IsDamageType(DMG_CLUB + DMG_BURN + DMG_DROWN + DMG_SHOCK) then
        dmg = dmg * 6.5 -- print(dmg,"5")
    elseif not dmginfo:IsDamageType(DMG_BLAST + DMG_NERVEGAS) then
        dmg = dmg * 2 -- print(dmg,"6")
    else -- print(dmg,"7")
        if dmginfo:GetAttacker():IsRagdoll() then dmg = dmg * 0 end
        dmginfo:SetDamage(dmginfo:GetDamage()) -- local x = dmginfo:GetDamage() -- if x > 1500 then --     x = x /5 --     print(x,"новый дмг типа х") -- end
        if ply.painlosing > 10 or ply.pain > GetConVar("rads_painlimit"):GetInt() or ply.Blood < GetConVar("rads_bloodlimit"):GetInt() and not ply.Otrub then -- print(dmg,"8") -- print(dmginfo:GetDamageForce(),"9")
            ply.gotuncon = true
        end
    end

    if dmginfo:IsDamageType(DMG_CLUB + DMG_GENERIC) then dmginfo:ScaleDamage((IsValid(wep) and wep.GetBlocking and not wep:GetBlocking()) and 1 or 0.25) end
    if dmginfo:IsDamageType(DMG_CRUSH) then
        dmginfo:ScaleDamage(GetConVar("rads_scalefalldmg"):GetFloat())
        dmg = dmg * GetConVar("rads_scalefalldmg"):GetFloat()
    end
    print("дамаг rads "..dmg/ply.painlosing)
    dmg = dmg / ply.painlosing
    dmg = dmg
    ply.pain = ply.pain + dmg
    ply.cock = ply.pain / 50
    if GetConVar("rads_adjusttimer"):GetBool() then
        if timer.Exists("radstimer" .. ply:EntIndex()) and ply.fake then
            timer.Adjust("radstimer" .. ply:EntIndex(), ply.cock, nil, nil)
        else
            timer.Create("radstimer" .. ply:EntIndex(), ply.cock, 1, function() end)
        end
    end
end)

concommand.Add("getcd", function(ply) ply:ChatPrint(timer.TimeLeft("radstimer" .. ply:EntIndex()) or "lol") end)
local empty = {}
hook.Add("Player Think", "oopsie", function(ply, time)
    if not ply:Alive() or (ply.painNext or time) > time or ply:HasGodMode() then return end
    ply.painNext = time + 0.1
    if ply.painlosing > 5 then ply.pain = ply.pain + 8 end
    if ply.pain >= 1800 then
        ply:Kill()
        return
    end

    ply.pain = math.max(ply.pain - ply.painlosing * 1, 0)
    ply.painlosing = math.max(ply.painlosing - 0.01, 1)
    if ply.painNextNet <= time then
        ply.painNextNet = time + 0.25
        ply.painNextNet = time + 0.25
        net.Start("info_pain")
        net.WriteFloat(ply.pain)
        net.WriteFloat(ply.painlosing)
        net.Send(ply)
    end

    if IsUnconscious(ply) then
        GetUnconscious(ply)
    else
        ply:ConCommand("soundfade 0 1")
    end
end)

if SERVER then util.AddNetworkString("info_pain") end
hook.Add("PostPlayerDeath", "RefreshPain", function(ply)
    ply.pain = 0
    ply.painlosing = 1
    ply:ConCommand("soundfade 0 1")
    ply.Otrub = false
    net.Start("info_pain")
    net.WriteFloat(ply.pain)
    net.WriteFloat(ply.painlosing)
    net.Send(ply)
end)

function IsUnconscious(ply)
    if ply.painlosing > 20 or ply.pain > GetConVar('rads_painlimit'):GetInt() and GetConVar("rads_painstatus"):GetBool() or ply.Blood < GetConVar("rads_bloodlimit"):GetInt() then
        ply.Otrub = true
        ply:SetDSP(16)
    else
        ply.Otrub = false
        ply:SetDSP(1)
    end

    ply:SetNWInt("Otrub", ply.Otrub)
    return ply.Otrub
end

function GetUnconscious(ply)
    if ply:Alive() then
        ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), 0.5, 0.5)
    else
    end

    if not ply.fake then rads(ply) end
    if ply.gotuncon then ply.pain = ply.pain + 100 end
    ply.gotuncon = false
    local rag = ply:GetNWEntity("player_ragdoll")
    if IsValid(rag) and ply.Otrub then rag:SetEyeTarget(Vector(0, 0, 0)) end
end

hook.Add("PlayerSpawn", "Damage", function(ply)
    if timer.Exists('respawntimer' .. ply:EntIndex()) then return end
    rag = ply:GetNWEntity('player_ragdoll')
    ply.Organs = {
        ['brain'] = 5,
        ['lungs'] = 10,
        ['liver'] = 5,
        ['stomach'] = 5,
        ['intestines'] = 15,
        ['heart'] = 5,
        ['artery'] = 1,
        ['spine'] = 2,
        ['bladder'] = 1
    }

    ply.pulse = 70
    ply.pain = 0
    ply.mental = 100
    ply.nobrain = false
    ply.painlosing = 0
    ply.pain = 0
    ply.painNext = 0
    ply.painNextNet = 0
    ply.Blood = 5000
    ply.cock = 0
    ply.bloodtype = math.random(1, 4)
    ply.InternalBleeding = nil
    ply.InternalBleeding2 = nil
    ply.InternalBleeding3 = nil
    ply.InternalBleeding4 = nil
    ply.InternalBleeding5 = nil
    ply:SetNWBool('radshighpulse', false)
    ply.brokenspine = false
    ply.LeftLeg = 1
    ply.RightArm = 1
    ply.RightLeg = 1
    ply.LeftArm = 1
    ply.msgLeftArm = 0
    ply.msgRightArm = 0
    ply.msgLeftLeg = 0
    ply.msgRightLeg = 0
    ply.LastDMGInfo = nil
    ply.LastHitPhysicsBone = nil
    ply.LastHitBoneName = nil
    ply.LastHitGroup = nil
    ply.LastAttacker = nil
    RADS_SendINFO(ply)
    ply:ChatPrint("Ваша группа крови: " .. tostring(ply.bloodtype))
end)

RagdollDamageBoneMul = {
    [HITGROUP_LEFTLEG] = 0.7,
    [HITGROUP_RIGHTLEG] = 0.7,
    [HITGROUP_GENERIC] = 0.9,
    [HITGROUP_LEFTARM] = 0.6,
    [HITGROUP_RIGHTARM] = 0.6,
    [HITGROUP_CHEST] = 1,
    [HITGROUP_STOMACH] = 0.9,
    [HITGROUP_HEAD] = 2,
}

bonetohitgroup = {
    ["ValveBiped.Bip01_Head1"] = 1,
    ["ValveBiped.Bip01_R_UpperArm"] = 5,
    ["ValveBiped.Bip01_R_Forearm"] = 5,
    ["ValveBiped.Bip01_R_Hand"] = 5,
    ["ValveBiped.Bip01_L_UpperArm"] = 4,
    ["ValveBiped.Bip01_L_Forearm"] = 4,
    ["ValveBiped.Bip01_L_Hand"] = 4,
    ["ValveBiped.Bip01_Pelvis"] = 3,
    ["ValveBiped.Bip01_Spine2"] = 2,
    ["ValveBiped.Bip01_L_Thigh"] = 6,
    ["ValveBiped.Bip01_L_Calf"] = 6,
    ["ValveBiped.Bip01_L_Foot"] = 6,
    ["ValveBiped.Bip01_R_Thigh"] = 7,
    ["ValveBiped.Bip01_R_Calf"] = 7,
    ["ValveBiped.Bip01_R_Foot"] = 7
}

local util_TraceLine = util.TraceLine
function GetPhysicsBoneDamageInfo(ent, dmgInfo)
    local pos = dmgInfo:GetDamagePosition()
    local dir = dmgInfo:GetDamageForce():GetNormalized()
    dir:Mul(1024 * 8)
    local tr = {}
    tr.start = pos
    tr.endpos = pos + dir
    tr.filter = filter
    filterEnt = ent
    tr.ignoreworld = true
    local result = util_TraceLine(tr)
    if result.Entity ~= ent then
        tr.endpos = pos - dir
        return util_TraceLine(tr).PhysicsBone
    else
        return result.PhysicsBone
    end
end

function RagdollOwner(rag)
    if not IsValid(rag) then return end
    local ent = rag:GetNWEntity("owner")
    return IsValid(ent) and ent
end

hook.Add("HomigradDamage", "Organs", function(ply, hitgroup, dmginfo, rag)
    local ent = rag or ply
    local inf = dmginfo:GetInflictor()
    if hitgroup == HITGROUP_HEAD then
        if dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then
            dmginfo:ScaleDamage(1)
            ply:SetDSP(37)
        end

        if dmginfo:GetDamageType() == DMG_CRUSH and dmginfo:GetDamage() >= 6 and ent:GetVelocity():Length() > 700 then
            ply:ChatPrint("Твоя шея была сломана")
            ent:EmitSound("NPC_Barnacle.BreakNeck", 511, 200, 1, CHAN_ITEM)
            dmginfo:ScaleDamage(5555 * 5)
            return
        end
    end

    if GetConVar("rads_bones"):GetBool() then
        if dmginfo:GetDamage() >= 40 or (dmginfo:GetDamageType() == DMG_CRUSH and dmginfo:GetDamage() >= 6 and ent:GetVelocity():Length() > 700) then
            local brokenLeftLeg = hitgroup == HITGROUP_LEFTLEG
            local brokenRightLeg = hitgroup == HITGROUP_RIGHTLEG
            local brokenLeftArm = hitgroup == HITGROUP_LEFTARM
            local brokenRightArm = hitgroup == HITGROUP_RIGHTARM
            local sub = dmginfo:GetDamage() / 10
            if brokenLeftArm then
                ply.LeftArm = math.min(0.6, ply.LeftArm - sub)
                if ply.msgLeftArm < CurTime() then
                    ply.msgLeftArm = CurTime() + 1
                    ply.pain = ply.pain + 35
                    ply.pulse = ply.pulse + 50 -- rag.pain = ply.pain 
                    ply:ChatPrint("Правая рука вывихнута") -- rag.pulse = ply.pulse
                    ent:EmitSound("NPC_Barnacle.BreakNeck", 70, 65, 0.4, CHAN_ITEM)
                end
            end

            if brokenRightArm then
                ply.RightArm = math.max(0.6, ply.RightArm - sub)
                if ply.msgRightArm < CurTime() then
                    ply.msgRightArm = CurTime() + 1
                    ply.pain = ply.pain + 35
                    ply.pulse = ply.pulse + 50 -- rag.pain = ply.pain 
                    ply:ChatPrint("Левая рука вывихнута") -- rag.pulse = ply.pulse
                    ent:EmitSound("NPC_Barnacle.BreakNeck", 70, 65, 0.4, CHAN_ITEM)
                end
            end

            if brokenLeftLeg then
                ply.LeftLeg = math.max(0.6, ply.LeftLeg - sub)
                if ply.msgLeftLeg < CurTime() then
                    ply.msgLeftLeg = CurTime() + 1
                    ply.pain = ply.pain + 35
                    ply.pulse = ply.pulse + 50 -- rag.pain = ply.pain 
                    ply:ChatPrint("Левая нога вывихнута") -- rag.pulse = ply.pulse
                    ply:SetWalkSpeed(ply:GetWalkSpeed() / 2)
                    ply:SetRunSpeed(ply:GetRunSpeed() - 200)
                    ent:EmitSound("NPC_Barnacle.BreakNeck", 70, 65, 0.4, CHAN_ITEM)
                end
            end

            if brokenRightLeg then
                ply.RightLeg = math.max(0.6, ply.RightLeg - sub)
                if ply.msgRightLeg < CurTime() then
                    ply.msgRightLeg = CurTime() + 1
                    ply.pain = ply.pain + 35
                    ply.pulse = ply.pulse + 50 -- rag.pain = ply.pain 
                    ply:ChatPrint("Правая нога вывихнута") -- rag.pulse = ply.pulse
                    ply:SetWalkSpeed(ply:GetWalkSpeed() / 2)
                    ply:SetRunSpeed(ply:GetRunSpeed() - 200)
                    ent:EmitSound("NPC_Barnacle.BreakNeck", 70, 65, 0.4, CHAN_ITEM)
                end
            end
        end
    end

    local penetration = dmginfo:GetDamageForce()
    if dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH) then
        penetration:Mul(0.015)
    else
        penetration:Mul(0.004)
    end

    if not rag or (rag and not dmginfo:IsDamageType(DMG_CRUSH)) then
        local dmg = dmginfo:GetDamage()
        if hitgroup == HITGROUP_HEAD and math.random(1, math.max(math.floor(dmginfo:GetDamage()), 1)) == 1 and dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_CLUB + DMG_GENERIC + DMG_BUCKSHOT) then
            timer.Simple(0.01, function()
                local wep = ply:GetActiveWeapon()
                if ply:Alive() and not ply.fake and (IsValid(wep) and not wep.GetBlocking and true or not wep:GetBlocking()) then
                    rads(ply)
                    ply.pulse = ply.pulse + 35
                end
            end)
        end

        local dmgpos = dmginfo:GetDamagePosition()
        local pos, ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine2'))
        local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-1, 0, -6), Vector(10, 6, 6))
        if AAA then
            if ply.Organs['lungs'] ~= 0 then
                ply.Organs['lungs'] = math.max(ply.Organs['lungs'] - dmg, 0)
                ply.pulse = ply.pulse + dmg / 15
                print(ply.Organs['lungs'] .. ' lungs HEALTH')
                ply:ChatPrint(ply.Organs['lungs'] .. ' Здоровье легких')
                if ply:GetNWBool('radsfa') then
                    local rag = ply:GetNWEntity('player_ragdoll')
                    rag.Blood = ply.Blood
                    RADS_Bleed(rag)
                else
                    ply.Blood = ply.Blood
                    RADS_Bleed(ply)
                end

                if ply.Organs['lungs'] == 0 then timer.Simple(3, function() if ply:Alive() then ply:ChatPrint("Ты чувствуешь, как воздух заполняет твою грудную клетку. ") end end) end
            end
        end

        local pos, ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Head1'))
        local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(3, -6, -4), Vector(9, 4, 4))
        if AAA then
            if ply.Organs['brain'] ~= 0 and dmginfo:IsDamageType(DMG_BULLET) then
                ply.Organs['brain'] = math.max(ply.Organs['brain'] - dmg, 0)
                ply.pulse = ply.pulse + dmg / 3
                print(ply.Organs['brain'] .. ' brain HEALTH')
                ply:ChatPrint(ply.Organs['brain'] .. ' Здоровье мозга аэээфэээаэфэээа')
                if ply:GetNWBool('radsfa') then
                    local rag = ply:GetNWEntity('player_ragdoll')
                    rag.Blood = ply.Blood
                    RADS_Bleed(rag)
                else
                    ply.Blood = ply.Blood
                    RADS_Bleed(ply)
                end

                if ply.Organs["brain"] == 0 then
                    dmginfo:ScaleDamage(2) -- ply:Kill() -- ply:TakeDamage(dmginfo:GetDamage()*5,game.GetWorld(),game.GetWorld())
                    return -- dmginfo:SetDamageForce(dmginfo:GetDamageForce()/2)
                end
            end
        end

        local pos, ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1')) --brain
        local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-4, -1, -6), Vector(2, 5, -1))
        if AAA then --ply:ChatPrint("You were hit in the liver.")
            if ply.Organs['liver'] ~= 0 and not dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['liver'] = math.max(ply.Organs['liver'] - dmg, 0)
                ply.pulse = ply.pulse + dmg / 10
                print(ply.Organs['liver'] .. ' liver HEALTH')
                ply:ChatPrint(ply.Organs['liver'] .. ' Здоровье печени')
            end
        end

        local pos, ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1')) --if ply.Organs['liver']==0 then ply:ChatPrint("Твоя печень была уничтожена.") end --liver
        local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-4, -1, -1), Vector(2, 5, 6))
        if AAA then --ply:ChatPrint("You were hit in the stomach.")
            if ply.Organs['stomach'] ~= 0 and not dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['stomach'] = math.max(ply.Organs['stomach'] - dmg, 0)
                ply.pulse = ply.pulse + dmg / 5
                print(ply.Organs['stomach'] .. ' stomach HEALTH')
                ply:ChatPrint(ply.Organs['stomach'] .. ' Здоровье живота')
                if ply.Organs['stomach'] == 0 then ply:ChatPrint("Ты чувствуешь острую боль в животе.") end
            end
        end

        local pos, ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine')) --stomach
        local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-4, -1, -6), Vector(1, 5, 6))
        if AAA then --ply:ChatPrint("You were hit in the intestines.")
            if ply.Organs['intestines'] ~= 0 and not dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['intestines'] = math.max(ply.Organs['intestines'] - dmg, 0)
                ply.pulse = ply.pulse + dmg / 5
                print(ply.Organs['intestines'] .. ' instestines HEALTH')
                if ply:GetNWBool('radsfa') then
                    local rag = ply:GetNWEntity('player_ragdoll')
                    rag.Blood = ply.Blood
                    RADS_Bleed(rag)
                else
                    ply.Blood = ply.Blood
                    RADS_Bleed(ply)
                end
            end
        end

        local pos, ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine2')) --if ply.Organs['intestines']==0 then ply:ChatPrint("Твои кишечник был уничтожен.")end
        local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(1, 0, -1), Vector(5, 4, 3))
        if AAA then
            if ply.Organs['heart'] ~= 0 and not dmginfo:IsDamageType(DMG_CLUB) then
                ply.Organs['heart'] = math.max(ply.Organs['heart'] - dmg, 0)
                ply.pulse = ply.pulse - dmg
                print(ply.Organs['heart'] .. ' heart HEALTH')
                ply:ChatPrint(ply.Organs['heart'] .. ' Здоровье сердца')
                if ply:GetNWBool('radsfa') then
                    local rag = ply:GetNWEntity('player_ragdoll')
                    rag.Blood = ply.Blood
                    RADS_Bleed(rag)
                else
                    ply.Blood = ply.Blood
                    RADS_Bleed(ply)
                end

                if ply.Organs['heart'] <= 0 then
                    timer.Simple(3, function()
                        ply:ChatPrint("Чувствуя едва покалывающее сердце,у вас темнеет в глазах. ")
                        ply:Kill()
                    end)
                end
            end
        end

        if dmginfo:IsDamageType(DMG_BULLET + DMG_SLASH + DMG_BLAST + DMG_ENERGYBEAM + DMG_NEVERGIB + DMG_ALWAYSGIB + DMG_PLASMA + DMG_AIRBOAT + DMG_SNIPER + DMG_BUCKSHOT) then --heart --and ent:LookupBone(bonename)==2 then
            local pos, ang = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Head1'))
            local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-3, -2, -2), Vector(0, -1, -1))
            local AAA2 = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-3, -2, 1), Vector(0, -1, 2))
            if AAA or AAA2 then --ply:ChatPrint("You were hit in the artery.")
                if ply.Organs['artery'] ~= 0 and not dmginfo:IsDamageType(DMG_CLUB) then
                    ply.Organs['artery'] = math.max(ply.Organs['artery'] - dmg, 0)
                    ply:ChatPrint("Вам попали в артерию,кровь начинает хлестать")
                    ply.BloodLosing = ply.BloodLosing + 45
                end
            end
        end

        RADS_SendINFO(ply)
        local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine4'))
        local ang = matrix:GetAngles()
        local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine4'))
        local AAA = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-8, -1, -1), Vector(2, 0, 1))
        local matrix = ent:GetBoneMatrix(ent:LookupBone('ValveBiped.Bip01_Spine1'))
        local ang = matrix:GetAngles()
        local pos = ent:GetBonePosition(ent:LookupBone('ValveBiped.Bip01_Spine1'))
        local AAA2 = util.IntersectRayWithOBB(dmgpos, penetration, pos, ang, Vector(-8, -3, -1), Vector(2, -2, 1))
        if AAA or AAA2 then
            if ply.Organs['spine'] ~= 0 then
                ply.Organs['spine'] = math.Clamp(ply.Organs['spine'] - dmg, 0, 1)
                print(ply.Organs['spine'] .. ' SPINE HEALTH')
                ply:ChatPrint(ply.Organs['spine'] .. ' Здоровье спины')
                if ply.Organs['spine'] == 0 then
                    timer.Simple(.4, function() if not ply.fake then rads(ply) end end)
                    ply.brokenspine = true
                    ply:ChatPrint("Ты почувствовал,как часть твоего тела онемела.")
                    ent:EmitSound("NPC_Barnacle.BreakNeck", 70, 125, 0.7, CHAN_ITEM)
                end
            end
        end
    end
end)

hook.Add("HomigradDamage", "BurnDamage", function(ply, hitgroup, dmginfo)
    if dmginfo:IsDamageType(DMG_BURN) then
        local dmg = dmginfo:GetDamage()
        ply.pulse = ply.pulse + dmg
        dmginfo:ScaleDamage(5)
    end
end)

hook.Add("EntityTakeDamage", "ragdmg", function(ent, dmginfo)
    if ent:IsPlayer() and ent:GetNWBool("gh.Ghosted", false) then return end
    if IsValid(ent:GetPhysicsObject()) and dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_CLUB + DMG_GENERIC + DMG_BLAST) then
        print(dmginfo:GetDamageForce()) -- print(dmginfo:GetDamageForce():GetNormalized(),"сила дмг11",dmginfo:GetDamage(),"урон11") -- ent:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamage(),dmginfo:GetDamagePosition())
        ent:GetPhysicsObject():ApplyForceOffset(dmginfo:GetDamageForce():GetNormalized() * math.min(dmginfo:GetDamage(), 3000), dmginfo:GetDamagePosition())
    end

    local ply = RagdollOwner(ent) or ent -- print(tostring(dmginfo:GetDamage()))
    if not ply or not ply:IsPlayer() or not ply:Alive() or ply:HasGodMode() then return end
    local rag = ply ~= ent and ent
    local physics_bone = GetPhysicsBoneDamageInfo(ent, dmginfo)
    local hitgroup
    local isfall
    local bonename = ent:GetBoneName(ent:TranslatePhysBoneToBone(physics_bone))
    ply.LastHitBoneName = bonename
    if bonetohitgroup[bonename] then hitgroup = bonetohitgroup[bonename] end
    local mul = RagdollDamageBoneMul[hitgroup]
    local entAtt = dmginfo:GetAttacker()
    local att = (entAtt:IsPlayer() and entAtt:Alive() and entAtt) or (entAtt:GetClass() == "wep" and entAtt:GetOwner())
    att = dmginfo:GetDamageType() ~= DMG_CRUSH and att or ply.LastAttacker
    ply.LastAttacker = att
    ply.LastHitGroup = hitgroup
    if dmginfo:IsDamageType(DMG_BLAST) then -- if not rag then --     return -- end
        dmginfo:ScaleDamage(2)
    end

    dmginfo:SetDamage(dmginfo:GetDamage())
    kekw = DamageInfo()
    kekw:SetAttacker(dmginfo:GetAttacker())
    kekw:SetInflictor(dmginfo:GetInflictor())
    kekw:SetDamage(dmginfo:GetDamage())
    kekw:SetDamageType(dmginfo:GetDamageType())
    kekw:SetDamagePosition(dmginfo:GetDamagePosition())
    kekw:SetDamageForce(dmginfo:GetDamageForce())
    if rag and mul then dmginfo:ScaleDamage(mul) end
    ply.LastDMGInfo = kekw
    local ply = RagdollOwner(ent) or ent
    if not ply.pulse then ply.pulse = 72 end
    ply.pulse = ply.pulse
    ply.pulse = ply.pulse + 2
    if IsValid(rag) then rag.pulse = rag.pulse + 2 end
    dmginfo:ScaleDamage(1.2)
    hook.Run("HomigradDamage", ply, hitgroup, dmginfo, rag)
    RADS.PainSound(ent)
    dmginfo:ScaleDamage(0.2) -- RADS_PreRag(rag)
    if rag then
        if dmginfo:GetDamageType() == DMG_CRUSH then dmginfo:ScaleDamage(1 / 40 / 15) end
        RADS_SendINFO(ply)
        ply:SetHealth(ply:Health() - dmginfo:GetDamage())
        if ply:Health() <= 0 then
            ply:Kill()
            if ttt then
                rag = ply:GetNWEntity('player_ragdoll')
                ply:SetNWEntity('player_ragdoll', nil)
                rag:SetNWEntity('owner', nil)
                rag:Remove()
            end
        end
    end
end)

hook.Add('DoPlayerDeath', tostring(math.random(0, 9999)), function(ply)
    local rag = ply:GetNWEntity('player_ragdoll')
    rag.IsBleeding = true
    rag.Blood = ply.Blood / 10 -- rag.bloodNext = CurTime()
    RADS_Bleed(rag)
    ply:SetNWBool('radsfa', false)
    ply:SetNWBool('brokenspine', false)
end)