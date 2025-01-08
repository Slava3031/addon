if SERVER then
    local lastPainSoundTime = {}
    local lastFreeFallSoundTime = {}
    function RADS.PainSound(ply)
        local g = "man"
        if string.find(ply:GetModel(), "alyx.mdl") or string.find(ply:GetModel(), "mossman.mdl") or string.find(ply:GetModel(), "mossman_arctic.mdl") or string.find(ply:GetModel(), "p2_chell.mdl") or string.find(ply:GetModel(), "female_") then g = "woman" end
        if string.find(ply:GetModel(), "combine") or string.find(ply:GetModel(), "police.mdl") then g = "combine" end
        if GetConVar("rads_painsounds"):GetBool() then
            local curTime = CurTime()
            local cooldown = 0.3
            if g == "man" then
                if not lastPainSoundTime[ply] or curTime - lastPainSoundTime[ply] >= cooldown then
                    local rndmsnd = math.random(1, #RADS.MalePain)
                    local randomSound = RADS.MalePain[rndmsnd]
                    ply:EmitSound(randomSound)
                    lastPainSoundTime[ply] = curTime
                end
            elseif g == "woman" then
                if not lastPainSoundTime[ply] or curTime - lastPainSoundTime[ply] >= cooldown then
                    local rndmsnd = math.random(1, #RADS.FemalePain)
                    local randomSound = RADS.FemalePain[rndmsnd]
                    ply:EmitSound(randomSound)
                    lastPainSoundTime[ply] = curTime
                end
            elseif g == "combine" then
                if not lastPainSoundTime[ply] or curTime - lastPainSoundTime[ply] >= cooldown then
                    local rndmsnd = math.random(1, #RADS.CombinePain)
                    local randomSound = RADS.CombinePain[rndmsnd]
                    ply:EmitSound(randomSound)
                    lastPainSoundTime[ply] = curTime
                end
            end
        end
    end

    function RADS.FreeFall(ply)
        local g = "man"
        if string.find(ply:GetModel(), "alyx.mdl") or string.find(ply:GetModel(), "mossman.mdl") or string.find(ply:GetModel(), "female_") then g = "woman" end
        if string.find(ply:GetModel(), "combine") or string.find(ply:GetModel(), "police.mdl") then g = "combine" end
        if GetConVar("rads_painsounds"):GetBool() then
            local curTime = CurTime()
            local cooldown = 0.3
            if g == "man" then
                if not lastFreeFallSoundTime[ply] or curTime - lastFreeFallSoundTime[ply] >= cooldown then
                    local rndmsnd = math.random(1, #RADS.MaleFall)
                    local randomSound = RADS.MaleFall[rndmsnd]
                    ply:EmitSound(randomSound)
                    lastFreeFallSoundTime[ply] = curTime
                end
            elseif g == "woman" then
                if not lastFreeFallSoundTime[ply] or curTime - lastFreeFallSoundTime[ply] >= cooldown then
                    local rndmsnd = math.random(1, #RADS.FemaleFall)
                    local randomSound = RADS.FemaleFall[rndmsnd]
                    ply:EmitSound(randomSound)
                    lastFreeFallSoundTime[ply] = curTime
                end
            elseif g == "combine" then
                if not lastFreeFallSoundTime[ply] or curTime - lastFreeFallSoundTime[ply] >= cooldown then
                    local rndmsnd = math.random(1, #RADS.CombineFall)
                    local randomSound = RADS.CombineFall[rndmsnd]
                    ply:EmitSound(randomSound)
                    lastFreeFallSoundTime[ply] = curTime
                end
            end
        end
    end

    _P = FindMetaTable("Player")
    _ENT = FindMetaTable("Entity")
    function _P:IsRag()
        return self:GetNWBool("radsfa")
    end

    function _P:GetRads()
        return self:GetNWEntity("player_ragdoll")
    end

    function RADS.IsTTT()
        if engine.ActiveGamemode() == "terrortown" then return true end
        return false
    end

    function _ENT:GetOwnerrr()
        if self:GetNWEntity("owner") ~= nil then return self:GetNWEntity("owner") end
        return nil
    end

    function _ENT:IsRads()
        if self:GetNWEntity("owner") ~= nil then return true end
        return false
    end

    function RADS.IsJmodAct()
        return type(JMod) == "table"
    end

    hook.Add("PhysgunDrop", "RADS.Drop", function(ply, ent)
        if ply:IsSuperAdmin() and ent:IsRagdoll() and ent:IsRads() then ent.physgunned = false end
        if ply:IsSuperAdmin() and ent:IsPlayer() then ent.physgunned = false end
    end)

    hook.Add("PhysgunPickup", "RADS.Pickup", function(ply, ent)
        if ply:IsSuperAdmin() and ent:IsPlayer() and not ent.fake then
            rads(ent)
            ent.physgunned = true
            return false
        end

        if ent:IsRagdoll() and ent:IsRads() then ent.physgunned = true end
    end)

    hook.Add("CanPlayerSuicide", "RADS.SuicideAllow", function(ply)
        if not GetConVar("rads_enablekill"):GetBool() and ply.Otrub then
            ply:ChatPrint("Нельзя кильнуться в отрубе")
            return false
        end
        return true
    end)

    local CurTime = CurTime
    local time
    local player_GetAll = player.GetAll
    local tbl
    hook.Add("PlayerSpawn", "RADS.SpawnReset", function(ply)
        ply:SetParent(nil)
        while not ply:IsInWorld() and not timer.Exists("respawntimer" .. ply:EntIndex()) do
            ply:Spawn()
        end

        if timer.Exists("respawntimer" .. ply:EntIndex()) then return end
        if timer.Exists("radstimer" .. ply:EntIndex()) then timer.Remove("radstimer" .. ply:EntIndex()) end
        net.Start('REMOVECALC')
        net.Send(ply)
        local exr = ply:GetNWEntity("player_ragdoll")
        if IsValid(exr) then
            ply:SetNWBool('radsfa', false)
            exr:RemoveEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
            ply:SetNWEntity('deadbody', exr)
            exr:SetNWEntity('deadbodyowner', ply)
            ply:SetNWEntity("player_ragdoll", nil)
            exr:SetNWEntity("RagdollController", nil)
            exr:SetNWEntity("owner", nil)
        end

        ply.fake = false
        ply.physgunned = false
        ply.brokenspine = false
    end)

    util.AddNetworkString("ragscale")
    hook.Add("Think", "RADS.PlayerThink", function(ply)
        tbl = player_GetAll()
        time = CurTime()
        for i = 1, #tbl do
            hook.Run("Player Think", tbl[i], time)
        end
    end)

    util.AddNetworkString('REMOVECALC')
    util.AddNetworkString("ADDCALC")
    fallChanceTable = {
        [HITGROUP_HEAD] = 0.7,
        [HITGROUP_CHEST] = 0.5,
        [HITGROUP_STOMACH] = 0.4,
        [HITGROUP_LEFTARM] = 0.2,
        [HITGROUP_RIGHTARM] = 0.2,
        [HITGROUP_LEFTLEG] = 0.5,
        [HITGROUP_RIGHTLEG] = 0.5
    }

    function shouldFall(bodyPart)
        return math.random() < fallChanceTable[bodyPart]
    end

    concommand.Add("rads_viewrag", function(ply, cmd, args)
        if not ply:IsSuperAdmin() then return end
        local tr = ply:GetEyeTrace()
        if not IsValid(tr.Entity) or not tr.Entity:IsPlayer() then return end
        local tarpp = tr.Entity
        rads(tarpp)
    end)
end

local CustomWeight = {
    ["models/player/police_fem.mdl"] = 50,
    ["models/player/police.mdl"] = 60,
    ["models/player/combine_soldier.mdl"] = 70,
    ["models/player/combine_super_soldier.mdl"] = 80,
    ["models/player/combine_soldier_prisonguard.mdl"] = 70,
    ['models/player/charple.mdl'] = 5
}

if SERVER then
    util.AddNetworkString("SendSavedPlayerWeaponsToActivator")
    util.AddNetworkString("SavedPlayerWeapons")
    function SendSavedPlayerWeapons(ply)
        net.Start("SavedPlayerWeapons")
        net.WriteTable(ply.Info.Weapons3)
        net.Send(ply)
    end

    savedPlayerState = {}
    function RADS_EzArmorSaveInfo(ply)
        local steamID = ply:SteamID()
        savedPlayerState[steamID] = {
            EZarmor = {},
            EZhealth = ply.EZhealth or nil,
            EZirradiated = ply.EZirradiated or nil,
            EZoxygen = ply.EZoxygen or nil,
            EZbleeding = ply.EZbleeding or nil,
            EZvirus = ply.EZvirus or nil
        }

        if ply.EZarmor then
            savedPlayerState[steamID].EZarmor = {
                items = ply.EZarmor.items or nil,
                speedFrac = ply.EZarmor.speedFrac or nil,
                effects = ply.EZarmor.effects or nil,
                mskmat = ply.EZarmor.mskmat or nil,
                sndlop = ply.EZarmor.sndlop or nil,
                suited = ply.EZarmor.suited or nil,
                bodygroups = ply.EZarmor.bodygroups or nil,
                totalWeight = ply.EZarmor.totalWeight or nil
            }
        end
    end

    function RADS_RestoreEzArmor(ply) -- SendSavedPlayerWeapons(ply)
        local steamID = ply:SteamID()
        if savedPlayerState[steamID] then
            local state = savedPlayerState[steamID]
            if RADS.IsJmodAct() and ply.EZarmor then
                ply.EZarmor = {
                    items = state.EZarmor.items,
                    speedFrac = state.EZarmor.speedFrac,
                    effects = state.EZarmor.effects,
                    mskmat = state.EZarmor.mskmat,
                    sndlop = state.EZarmor.sndlop,
                    suited = state.EZarmor.suited,
                    bodygroups = state.EZarmor.bodygroups,
                    totalWeight = state.EZarmor.totalWeight
                }

                ply.EZhealth = state.EZhealth
                ply.EZirradiated = state.EZirradiated
                ply.EZoxygen = state.EZoxygen
                ply.EZbleeding = state.EZbleeding
                ply.EZvirus = state.EZvirus
            end

            savedPlayerState[steamID] = nil
        end
    end

    function RADS_SavePlyInfo(ply)
        ply.Info = {}
        local info = ply.Info
        info.HasSuit = ply:IsSuitEquipped()
        info.SuitPower = ply:GetSuitPower()
        info.Ammo = ply:GetAmmo()
        info.ActiveWeapon = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() or nil
        info.runspeed = ply:GetRunSpeed()
        info.walkspeed = ply:GetWalkSpeed()
        info.ActiveWeapon2 = ply:GetActiveWeapon()
        GetFakeWeapon(ply)
        info.Angles = ply:GetAngles()
        info.Weapons = {}
        for i, wep in pairs(ply:GetWeapons()) do
            info.Weapons[wep:GetClass()] = {
                Clip1 = wep:Clip1(),
                Clip2 = wep:Clip2(),
                AmmoType = wep:GetPrimaryAmmoType()
            }
        end

        info.Weapons2 = {}
        for i, wep in ipairs(ply:GetWeapons()) do
            info.Weapons2[i - 1] = wep:GetClass()
        end

        info.Weapons3 = {}
        for i, wep in ipairs(ply:GetWeapons()) do
        end

        SendSavedPlayerWeapons(ply) -- info.Weapons3[wep:GetClass()] = wep:GetPrintName()
        info.eyeviewcvar = ply:GetInfoNum('eyeview_enabled', 1)
        info.AllAmmo = {}
        local i
        for ammo, amt in pairs(ply:GetAmmo()) do
            i = i or 0
            i = i + 1
            info.AllAmmo[ammo] = {i, amt}
        end
        return info
    end

    function RADS_ReturnPlyInfo(ply)
        ClearFakeWeapon(ply)
        ply:SetSuppressPickupNotices(true)
        local info = ply.Info
        if not info then return end
        ply:StripWeapons()
        ply:StripAmmo()
        ply.slots = {}
        for name, wepinfo in pairs(info.Weapons or {}) do
            local weapon = ply:Give(name, true)
            if IsValid(weapon) and wepinfo.Clip1 ~= nil and wepinfo.Clip2 ~= nil then
                weapon:SetClip1(wepinfo.Clip1)
                weapon:SetClip2(wepinfo.Clip2)
            end
        end

        for ammo, amt in pairs(info.Ammo or {}) do
            ply:GiveAmmo(amt, ammo)
        end

        if info.ActiveWeapon then ply:SelectWeapon(info.ActiveWeapon) end
        if info.HasSuit then
            ply:EquipSuit()
            ply:SetSuitPower(info.SuitPower or 0)
        else
            ply:RemoveSuit()
        end

        ply:SetRunSpeed(info.runspeed)
        ply:SetWalkSpeed(info.walkspeed)
        ply:SetHealth(info.Hp or 0)
        ply:SetArmor(info.Armor or 0)
        ply:SetEyeAngles(info.Angles)
        info.Weapons3 = nil
    end

    function GetFakeWeapon(ply)
        ply.curweapon = ply.Info.ActiveWeapon
    end

    function ClearFakeWeapon(ply)
        if ply.FakeShooting then DespawnWeapon(ply) end
    end

    function RADS_RagBones(ent) --     util.AddNetworkString('RetrieveWeaponFromRagdoll') -- net.Receive("RetrieveWeaponFromRagdoll", function(len, ply) --  weaponClass = net.ReadTable() --     local tr = ply:GetEyeTrace() --     if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" then --         local owner = tr.Entity:GetNWEntity("owner") --         local deadbodyowner = tr.Entity:GetNWEntity('deadbodyowner') --         if IsValid(owner) and owner:IsPlayer() or IsValid(deadbodyowner) and deadbodyowner:IsPlayer() then --             if owner.Info and owner.Info.Weapons3 then --                 owner.Info.Weapons3[weaponClass] = nil --                 ply:Give(weaponClass) --             else --                 ply:Give(weaponClass) --             end --         end --     end -- end) 
        local rag = ent:GetNWEntity("player_ragdoll")
        local ragdollBones = rag:GetPhysicsObjectCount()
        local vel = ent:GetVelocity() / 1
        for i = 0, rag:GetPhysicsObjectCount() - 1 do
            local physobj = rag:GetPhysicsObjectNum(i)
            local ragbonename = rag:GetBoneName(rag:TranslatePhysBoneToBone(i))
            local bone = ent:LookupBone(ragbonename)
            if bone then
                local bonemat = ent:GetBoneMatrix(bone)
                if bonemat then
                    local bonepos = bonemat:GetTranslation()
                    local boneang = bonemat:GetAngles()
                    physobj:SetPos(bonepos, true)
                    physobj:SetAngles(boneang)
                    if ent:Alive() then vel = vel end
                    if not ent:Alive() then vel = vel / 2 end
                    physobj:AddVelocity(vel)
                end
            end
        end
    end

    function RADS_ValidPos(originalPos, ply)
        local maxAttempts = 35
        local initialRadius = 1
        local searchRadiusIncrement = 2
        local rag = ply:GetNWEntity("player_ragdoll")
        local mins, maxs = ply:GetCollisionBounds()
        local traceOriginalPos = util.TraceHull({
            start = originalPos,
            endpos = originalPos + Vector(0, 0, 0),
            mins = mins,
            maxs = maxs,
            mask = MASK_PLAYERSOLID
        })

        if traceOriginalPos.Hit then
            for attempt = 1, maxAttempts do
                print(attempt)
                local currentRadius = initialRadius + (attempt - 1) * searchRadiusIncrement
                local foundValidPos = false
                for x = -1, 1 do
                    for y = -1, 1 do
                        if x ~= 0 or y ~= 0 then
                            local offset = Vector(x * currentRadius, y * currentRadius, 0)
                            local newPos = originalPos + offset
                            if util.IsInWorld(newPos) then
                                local trace = util.TraceHull({
                                    start = newPos,
                                    endpos = newPos + Vector(0, 0, 0),
                                    mins = mins,
                                    maxs = maxs,
                                    mask = MASK_PLAYERSOLID
                                })

                                if not trace.Hit then return newPos end
                                foundValidPos = true
                                break
                            end
                        end
                    end
                end
            end
            return nil
        else
            return originalPos
        end
    end

    hook.Add("RADS_Ready", "RADS.CustomApi", function(rag) print("") end)
    function rads(ply)
        if not GetConVar("rads_status"):GetBool() then
            print("Script is disabled. Not executing functionality.")
            return
        end

        if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
        if timer.Exists("radstimer" .. ply:EntIndex()) then return end
        if ply:GetNWBool("gh.Ghosted") then return end
        local rag = ply:GetNWEntity("player_ragdoll")
        if IsValid(rag) then
            if ply.brokenspine then
                ply:ChatPrint("Спина сломана")
                ply:EmitSound("ambient/voices/cough" .. math.random(1, 4) .. ".wav", 75, math.random(90, 110))
                return
            end

            ply:SetNWBool("radsfa", false)
            local health = ply:Health()
            ragpos = rag:GetPos()
            respawnmodel = ply:GetModel()
            spawnpos = RADS_ValidPos(rag:GetPos(), ply)
            if spawnpos == nil then
                ply:ChatPrint("Нет места,чтобы встать.")
                return
            end

            ply:Spawn()
            ply:SetPos(spawnpos) -- RADS_PostRag(ply)
            rag:Remove()
            if table.HasValue(BleedingEntities, rag) then table.insert(BleedingEntities, ply) end
            ply.fake = false
            ply:SetModel(respawnmodel)
            ply.resetinv = true
            hook.Run("RADSLoadout", ply)
            ply.resetinv = false
            ply:SetParent(nil)
            ply:SetNoDraw(false)
            ply:SetMoveType(MOVETYPE_WALK)
            ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
            ply:DrawViewModel(true)
            ply:DrawWorldModel(true)
            ply:SetSuppressPickupNotices(false)
            ply:SetShouldPlayPickupSound(true)
            ply.FakeShooting = false
            ply:SetNWEntity("player_ragdoll", nil)
            ply:SetViewEntity(ply)
            ply:SetHealth(health)
            net.Start("REMOVECALC")
            net.Send(ply)
            if IsValid(rag.target) then rag.target:Remove() end
            timer.Remove("respawntimer" .. ply:EntIndex())
        else
            local veh
            if ply:InVehicle() then
                veh = ply:GetVehicle()
                ply:ExitVehicle()
            end

            ply:SetNoDraw(true)
            timer.Create("respawntimer" .. ply:EntIndex(), 99999, 1, function() end)
            ply.fake = true
            if ply.IsBleeding or (ply.BloodLosing or 0) > 0 then
                rag.IsBleeding = true
                rag.bloodNext = CurTime()
                rag.Blood = ply.Blood
                RADS_Bleed(rag)
            end

            RADS_SavePlyInfo(ply)
            RADS_EzArmorSaveInfo(ply)
            if not ply:IsInWorld() then return end
            net.Start("ADDCALC")
            net.Send(ply)
            local rag = ents.Create("prop_ragdoll")
            rag:SetModel(ply:GetModel())
            rag:SetSkin(ply:GetSkin())
            for k, v in pairs(ply:GetBodyGroups()) do
                rag:SetBodygroup(v.id, ply:GetBodygroup(v.id))
            end

            rag:SetNWVector("plycolor", ply:GetPlayerColor())
            rag:SetAngles(ply:GetAngles())
            rag:Spawn()
            timer.Simple(0, function()
                ply:SetNWBool("radsfa", true) -- RADS_PreRag(ply)
                ply:SetParent(rag)
                ply:SetMoveType(MOVETYPE_NONE)
                ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
            end)

            rag:Activate()
            local wep = ply:GetActiveWeapon()
            if IsValid(wep) and table.HasValue(Guns, wep:GetClass()) then
                SpawnWeapon(ply)
                ply.FakeShooting = true
            end

            rag:SetCollisionGroup(COLLISION_GROUP_WEAPON)
            ply:SetNWEntity("player_ragdoll", rag)
            rag:SetNWEntity("owner", ply)
            rag:SetPos(ply:GetPos())
            if GetConVar("rads_supersus"):GetBool() then
                local light = ents.Create("light_dynamic")
                light:SetPos(rag:GetPos() + Vector(0, 0, 20))
                light:SetKeyValue("brightness", "5")
                light:SetKeyValue("distance", "200")
                light:SetKeyValue("style", "0")
                light:Spawn()
                light:Activate()
                light:Fire("TurnOn", "", 0)
                light:SetParent(rag)
            end

            local rpos = rag:GetPos()
            timer.Simple(0, function()
                if RADS.IsJmodAct() then
                    local armors = {}
                    for id, info in pairs(ply.EZarmor.items) do
                        local ent = CreateArmor(rag, info)
                        ent.armorID = id
                        ent.ragdoll = rag
                        ent.Owner = ply
                        armors[id] = ent
                        ent:CallOnRemove("Fake", Remove, ply)
                    end

                    rag.armors = armors
                    rag:CallOnRemove("Armors", RemoveRag)
                end
            end)

            if IsValid(rag:GetPhysicsObject()) then rag:GetPhysicsObject():SetMass(CustomWeight[rag:GetModel()] or 20) end
            rag:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)
            ply:SetActiveWeapon(nil)
            ply:DropObject()
            ply:SetPos(rag:GetPos())
            rag.pulse = ply.pulse or 0
            RADS_RagBones(ply)
            hook.Run("RADS_READY", rag)
        end

        if IsValid(veh) then rag:GetPhysicsObject():SetVelocity(veh:GetPhysicsObject():GetVelocity() * 5) end
    end

    function CC(ply, message)
        if not IsValid(ply) then return end
        local curTime = CurTime()
        if ply.lastChatTime == nil or curTime - ply.lastChatTime >= 3 then
            ply.lastChatTime = curTime
            ply:ChatPrint(message)
        end
    end

    hook.Add("PlayerFootstep", "RADS.BrokenBones", function(ply, pos, foot, sound, volume, filter)
        if ply.LeftLeg <= 0.6 or ply.RightLeg <= 0.6 then
            if ply:IsSprinting() then
                ply.pain = ply.pain + 3
                CC(ply, "Ваша нога вывихнута,бег причиняет боль")
            end
        end
    end)

    hook.Add("Player Think", "RADS.SYNCPOS", function(ply)
        local qw = ply:GetNWEntity('player_ragdoll')
        if IsValid(qw) and ply:IsRag() then
            local qe = qw:GetAttachment(qw:LookupAttachment("eyes")).Pos
            ply:SetPos(qe)
        end
    end)

    util.AddNetworkString("CheckPulseAndLink")
    net.Receive("CheckPulseAndLink", function(len, ply)
        local ragdoll = net.ReadEntity()
        if IsValid(ragdoll) and ragdoll:IsRagdoll() then
            local downer = ragdoll:GetNWEntity('deadbodyowner')
            local owner = nil
            if IsValid(downer) then
                ply:ChatPrint("У него нет пульса. ")
            else
                owner = RagdollOwner(ragdoll)
                if IsValid(owner) and owner:IsPlayer() then
                    local pulse = owner.pulse
                    local hp = owner:Health()
                    if pulse >= 130 then ply:ChatPrint('У него высокий пульс. ') end
                    if pulse >= 60 then
                        ply:ChatPrint("У него нормальный пульс. ")
                    elseif pulse <= 50 and pulse >= 30 and hp <= 20 then
                        ply:ChatPrint("У него низкий пульс. ")
                    elseif pulse <= 15 then
                        ply:ChatPrint("У него нет пульса. ")
                    end
                end
            end
        end
    end)

    util.AddNetworkString("rads.bloodcheck")
    net.Receive("rads.bloodcheck", function(len, ply)
        local r = net.ReadEntity()
        if IsValid(r) and r:IsRagdoll() then
            net.Start("rads.bloodcheck")
            local i = r.Blood or 0
            net.WriteInt(i, 14)
            net.Send(ply)
        end
    end)

    function _P:PickupEnt()
        local ply = self
        local rag = ply:GetNWEntity("player_ragdoll")
        local phys = rag:GetPhysicsObjectNum(7)
        local offset = phys:GetAngles():Right() * 5
        local traceinfo = {
            start = phys:GetPos(),
            endpos = phys:GetPos() + offset,
            filter = rag,
            output = trace,
        }

        local trace = util.TraceLine(traceinfo)
        if trace.Entity == Entity(0) or trace.Entity == NULL or not trace.Entity.canpickup then return end
        if trace.Entity:GetClass() == "wep" then
            ply:Give(trace.Entity.curweapon, true):SetClip1(trace.Entity.Clip)
            ply.wep.Clip = trace.Entity.Clip
            trace.Entity:Remove()
        end
    end

    function _P:DropWeapon1(wep)
        local ply = self
        wep = wep or ply:GetActiveWeapon()
        if not IsValid(wep) then return end
        ply:DropWeapon(wep)
        wep.Spawned = true
        ply:SetActiveWeapon(nil)
    end

    hook.Add("PlayerSay", "dropweaponhuy", function(ply, text)
        if string.lower(text) == "#drop" or string.lower(text) == "*drop" or string.lower(text) == "!drop" then
            if not ply.fake then
                ply:DropWeapon1()
                return ""
            else
                if IsValid(ply.wep) then
                    if IsValid(ply.WepCons) then
                        ply.WepCons:Remove()
                        ply.WepCons = nil
                    end

                    if IsValid(ply.WepCons2) then
                        ply.WepCons2:Remove()
                        ply.WepCons2 = nil
                    end

                    ply.wep.canpickup = true
                    ply.wep:SetOwner()
                    ply.wep.curweapon = ply.curweapon
                    ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 = ply.wep.Clip
                    ply:StripWeapon(ply.Info.ActiveWeapon)
                    ply.Info.Weapons[ply.Info.ActiveWeapon] = nil
                    ply.wep = nil
                    ply.Info.ActiveWeapon = nil
                    ply.Info.ActiveWeapon2 = nil
                    ply:SetActiveWeapon(nil)
                    ply.FakeShooting = false
                else
                    ply:PickupEnt()
                end
                return ""
            end
        end
    end)

    hook.Add("Think", "radsshoot", function()
        for i, ply in pairs(player.GetAll()) do
            if ply:Alive() then
                if IsValid(ply:GetNWEntity("player_ragdoll")) and ply.FakeShooting then
                    SpawnWeapon(ply)
                else
                    if IsValid(ply.wep) then DespawnWeapon(ply) end
                end
            end
        end
    end)

    function _P:PickupEnt()
        local ply = self
        local rag = ply:GetNWEntity("player_ragdoll")
        local phys = rag:GetPhysicsObjectNum(7)
        local offset = phys:GetAngles():Right() * 5
        local traceinfo = {
            start = phys:GetPos(),
            endpos = phys:GetPos() + offset,
            filter = rag,
            output = trace,
        }

        local trace = util.TraceLine(traceinfo)
        if trace.Entity == Entity(0) or trace.Entity == NULL or not trace.Entity.canpickup then return end
        if trace.Entity:GetClass() == "wep" then
            ply:Give(trace.Entity.curweapon, true):SetClip1(trace.Entity.Clip)
            ply.wep.Clip = trace.Entity.Clip
            trace.Entity:Remove()
        end
    end

    util.AddNetworkString("Unload")
    net.Receive("Unload", function(len, ply)
        local wep = net.ReadEntity()
        local oldclip = wep:Clip1()
        local ammo = wep:GetPrimaryAmmoType()
        wep:EmitSound("snd_jack_hmcd_ammotake.wav")
        wep:SetClip1(0)
        ply:GiveAmmo(oldclip, ammo)
    end)

    hook.Add("KeyPress", "Shooting", function(ply, key)
        if not ply:Alive() then return end
        if key == IN_RELOAD then Reload(ply.wep) end
    end)

    local lbt = 0 -- util.AddNetworkString('RequestRagdollInfo') -- util.AddNetworkString('SendPlayerWeaponsAndAmmo') --     util.AddNetworkString('RequestRagdollInfo') --     net.Receive("RequestRagdollInfo", function(len, ply) --         local ragdoll = net.ReadEntity() --         if IsValid(ragdoll) and ragdoll:GetClass() == "prop_ragdoll" then --             owner = ragdoll:GetNWEntity("owner") --             deadbodyowner = ragdoll:GetNWEntity('deadbodyowner') --             if IsValid(owner) and owner:IsPlayer() or IsValid(deadbodyowner) and deadbodyowner:IsPlayer() then --                 local weaponsData = owner.Info and owner.Info.Weapons3 or {} --                 local ammoData = owner.Info and owner.Info.AllAmmo or {} --                 if not weaponsData or not AmmoData then --                 local weaponsData = deadbodyowner.Info and deadbodyowner.Info.AllAmmo or {} --                 end --                 net.Start("SendPlayerWeaponsAndAmmo") --                 net.WriteTable({weapons = weaponsData, ammo = ammoData}) --                 net.Send(ply) --             end --         end --     end
    util.AddNetworkString("RADS.CHATSAY")
    hook.Add('Think', "RADS.CHAT", function()
        if CurTime() - lbt >= 600 then
            net.Start('RADS.CHATSAY')
            net.Broadcast()
            lbt = CurTime()
        end
    end)

    hook.Add("PlayerUse", "nouse", function(ply, ent) if ply.fake then return false end end)
    function deathrem(victim)
        local rag = victim:GetNWEntity("player_ragdoll")
        net.Start('ADDCALC')
        net.Send(victim)
        timer.Remove('respawntimer' .. victim:EntIndex())
        if victim.IsBleeding or (victim.BloodLosing or 0) > 0 then
            rag.IsBleeding = true
            rag.bloodNext = CurTime()
            rag.Blood = victim.Blood
            RADS_Bleed(rag)
        end

        if IsValid(rag.ZacConsLH) then
            rag.ZacConsLH:Remove()
            rag.ZacConsLH = nil
        end

        if IsValid(rag.ZacConsRH) then
            rag.ZacConsRH:Remove()
            rag.ZacConsRH = nil
        end

        if not IsValid(rag) and not RADS.IsTTT() then
            victim:SetNWBool("radsfa", false)
            local rag = ents.Create("prop_ragdoll")
            rag:SetModel(victim:GetModel())
            rag:SetPos(victim:GetPos())
            rag:SetAngles(victim:GetAngles())
            rag:Spawn()
            rag:Activate()
            rag:SetSkin(victim:GetSkin())
            for key, value in pairs(victim:GetBodyGroups()) do
                rag:SetBodygroup(value.id, victim:GetBodygroup(value.id))
            end

            if victim.IsBleeding or (victim.BloodLosing or 0) > 0 then
                rag.IsBleeding = true
                rag.bloodNext = CurTime()
                rag.Blood = victim.Blood
                RADS_Bleed(rag)
            end

            rag:SetNWVector("plycolor", victim:GetPlayerColor())
            victim:SetNWEntity("player_ragdoll", rag)
            rag:SetNWEntity("owner", victim)
            RADS_RagBones(victim)
            if IsValid(rag:GetPhysicsObject()) then
                local CustomWeightt = CustomWeight[rag:GetModel()]
                rag:GetPhysicsObject():SetMass(30)
            end

            victim:SetPos(rag:GetPos())
            if RADS.IsJmodAct() then
                local armors = {}
                for id, info in pairs(victim.EZarmor.items) do
                    local ent = CreateArmor(rag, info)
                    ent.armorID = id
                    ent.ragdoll = rag
                    ent.Owner = victim
                    armors[id] = ent
                    ent:CallOnRemove("Fake", Remove, victim)
                end

                rag.armors = armors
                rag:CallOnRemove("Armors", RemoveRag)
            end

            victim:SetParent(nil)
            if not victim:IsBot() then
                local steamID = victim:SteamID()
                if victim.Info then
                    victim.Info.Hp = nil
                    victim.Info.Armor = nil
                end

                if victim.Info then
                    victim.Info.Weapons2 = {}
                    victim.Info.Weapons = {}
                    victim.Info.AllAmmo = {}
                end

                savedPlayerState[steamID] = nil
                if victim:HasGodMode() then victim:GodDisable() end
            end
        end
    end

    hook.Add("DoPlayerDeath", "RADS.DeathH3", function(ply, att, dmg) deathrem(ply) end)
    hook.Add("PlayerDeath", "RADS.DeathH1", function(v, i, a)
        v:SetParent(nil)
        v:SetNWBool('brokenspine', false)
        v.pulse = 0
    end)

    hook.Add("PlayerDeath", "RADS.DeathH2", function(victim, inflictor, attacker)
        local rag = victim:GetNWEntity('player_ragdoll') -- deathrem(victim)
        victim:SetParent(nil)
        victim:SetNWBool('brokenspine', false)
        if GetConVar('rads_spectatorfix'):GetBool() then
            net.Start('REMOVECALC')
            net.Send(victim)
        end

        victim.pulse = 0
    end)

    concommand.Add("rads_ragdolize", function(ply, cmd, args)
        if ply:GetMoveType() == MOVETYPE_OBSERVER then return end
        if not RADS.IsTTT() and ply.fake then -- local mz = math.random(1,2) -- if mz == 2 then --     local r = math.random(2,10) --     timer.Simple(r,function() --         Seizure(victim:GetRads()) --     end) -- end
            if ply:IsRag() then if ply:GetRads().physgunned then return nil end end
            if timer.Exists("radstimer" .. ply:EntIndex()) then return nil end
            if timer.Exists("StunTime" .. ply:EntIndex()) then return nil end
            if timer.Exists("Epilepsy" .. ply:EntIndex()) then return nil end
            if ply.brokenspine then return nil end
            if GetConVar('rads_painstatus'):GetBool() and ply:IsRag() and ply.pain > (GetConVar("rads_painlimit"):GetInt() * (ply.Blood / 5000)) or ply.Blood < GetConVar("rads_bloodlimit"):GetInt() then return end
            if IsValid(ply:GetNWEntity("player_ragdoll")) and ply:GetNWEntity("player_ragdoll"):GetVelocity():Length() > 300 then return nil end
        end

        if table.Count(constraint.FindConstraints(ply:GetNWEntity("player_ragdoll"), 'Rope')) > 0 then
            ply:ChatPrint("Ты связан,не получится встать")
            return nil
        end

        rads(ply)
        if not RADS.IsTTT() and not ply.fake then timer.Create("radstimer" .. ply:EntIndex(), 1.5, 1, function() end) end
    end)

    hook.Add("PlayerDisconnected", "removeallwhenleave", function(ply)
        local steamID = ply:SteamID()
        savedPlayerState[steamID] = nil
        if ply.Info then
            ply.Info.Hp = nil
            ply.Info.Armor = nil
            ply.Info = nil
        end

        if savedPlayerState[steamID] then savedPlayerState[steamID] = nil end
        local exr = ply:GetNWEntity("player_ragdoll")
        if IsValid(exr) then
            ply:SetNWEntity("player_ragdoll", nil)
            exr:SetNWEntity('owner', nil)
            exr:SetNWEntity("RagdollController", nil)
        end
    end)

    hook.Add("OnPlayerHitGround", "GovnoJopa", function(ply, a, b, speed)
        if speed > 200 then
            local tr = {}
            tr.start = ply:GetPos()
            tr.endpos = ply:GetPos() - Vector(0, 0, 10)
            tr.mins = ply:OBBMins()
            tr.maxs = ply:OBBMaxs()
            tr.filter = ply
            local traceResult = util.TraceHull(tr)
            if traceResult.Entity:IsPlayer() and not traceResult.Entity.fake then rads(traceResult.Entity) end
        end
    end)

    hook.Add("Think", "VelocityFakeHitPlyCheck", function()
        for i, rag in pairs(ents.FindByClass("prop_ragdoll")) do
            if IsValid(rag) then
                rag:SetCollisionGroup(COLLISION_GROUP_WEAPON) -- if rag:GetVelocity():Length() > 5 then -- rag:SetCollisionGroup(COLLISION_GROUP_NONE) -- else
            end
        end
    end)

    hook.Add("Think", "RemoveRagdoll", function()
        for _, ply in ipairs(player.GetAll()) do -- end
            local ragdoll_entity = ply:GetRagdollEntity()
            if IsValid(ragdoll_entity) then ragdoll_entity:Remove() end
        end
    end)

    function propknocked(ply)
        if timer.Exists("propknocked" .. ply:UserID()) then
            return true
        else
            timer.Create("propknocked" .. ply:UserID(), 1, 1, function() end)
            return false
        end
    end

    hook.Add("EntityTakeDamage", "fallfromclub", function(target, dmginfo)
        local random = math.Rand(1, 2)
        if target:IsPlayer() and GetConVar('rads_fallonclub'):GetBool() and dmginfo:IsDamageType(DMG_CLUB) and not target.fake then
            if GetConVar('rads_randomfallfromclub'):GetBool() then if random > 1.7 then rads(target) end end
            if not GetConVar('rads_randomfallfromclub'):GetBool() then -- ply.pain = ply.pain + 5
                rads(target)
            end
        end
    end)

    hook.Add("EntityTakeDamage", "fallondamage", function(target, dmginfo)
        if target:IsPlayer() then -- ply.pain = ply.pain + 5
            if GetConVar('rads_fallchance'):GetBool() and not target.fake then
                local damagePosition = dmginfo:GetDamagePosition()
                local bodyPart = target:LastHitGroup(damagePosition)
                if fallChanceTable[bodyPart] and shouldFall(bodyPart) then rads(target) end
            end
        end
    end)

    hook.Add("EntityTakeDamage", "stundmg", function(target, dmginfo)
        if IsValid(target) and not target.fake then -- target.pain = target.pain + 7
            if IsValid(dmginfo:GetAttacker()) then
                local attacker = dmginfo:GetAttacker()
                local inflictor = dmginfo:GetInflictor()
                if IsValid(attacker) and IsValid(inflictor) then if attacker:IsPlayer() and attacker:GetActiveWeapon() and attacker:GetActiveWeapon():IsValid() then if attacker:GetActiveWeapon():GetClass() == "weapon_stunstick" then Stun(target) end end end
            end
        end
    end)

    function Seizure(ent) -- target.pain = target.pain + 20
        if ent:IsRagdoll() then
            local seizuret = math.random(1, 6)
            local iterrr = seizuret * 10
            RagdollOwner(ent):ChatPrint("судороги начались лол")
            timer.Create("seizuret_" .. ent:EntIndex(), seizuret, 1, function() end)
            timer.Create("seizuret_" .. ent:EntIndex(), 0.1, iterrr, function() ent:GetPhysicsObjectNum(1):SetVelocity(ent:GetPhysicsObjectNum(1):GetVelocity() + Vector(math.random(-45, 45), math.random(-45, 45), 0)) end)
        end
    end

    function Stun(Entity)
        if Entity:IsPlayer() then
            rads(Entity)
            local stuntime = math.random(1, 15)
            local iter = stuntime * 10
            timer.Create("StunTime" .. Entity:EntIndex(), stuntime, 1, function() end)
            local radsrag = Entity:GetNWEntity("player_ragdoll")
            if not IsValid(radsrag) then return end
            timer.Create("StunEffect" .. Entity:EntIndex(), 0.1, iter, function()
                local rand = math.random(1, 2)
                if rand == 2 then end
                radsrag:GetPhysicsObjectNum(1):SetVelocity(radsrag:GetPhysicsObjectNum(1):GetVelocity() + Vector(math.random(-85, 85), math.random(-85, 85), 0)) -- Entity:Say('#drop')
                radsrag:EmitSound("ambient/energy/spark2.wav")
            end)
        end
    end

    function RADS_Epilepsy(Entity)
        if Entity:IsPlayer() then
            local rag = Entity:GetNWEntity('player_ragdoll')
            if IsValid(rag) then return end
            rads(Entity)
            local mineptime, maxeptime = GetConVar('rads_mineptime'):GetInt(), GetConVar('rads_maxeptime'):GetInt()
            local eptime = math.random(mineptime, maxeptime)
            local iterr = eptime * 10
            timer.Create("Epilepsy" .. Entity:EntIndex(), eptime, 1, function() end)
            local radsrag = Entity:GetNWEntity("player_ragdoll")
            if not IsValid(radsrag) then return end
            timer.Create("EpilepsyM" .. Entity:EntIndex(), 0.1, iterr, function()
                local rand = math.random(1, 2)
                if rand == 2 then end
                radsrag:GetPhysicsObjectNum(1):SetVelocity(radsrag:GetPhysicsObjectNum(1):GetVelocity() + Vector(math.random(-125, 125), math.random(-125, 125), 0)) -- Entity:Say('#drop')
            end)

            radsrag:EmitSound("lol.wav")
        end
    end

    concommand.Add('rads_epil', function(ply) RADS_Epilepsy(ply) end)
    function RADS_RagdollCollision(ragdoll, collisionData)
        if GetConVar('rads_doorbreach'):GetBool() then
            local collidedEntity = collisionData.HitEntity
            if IsValid(collidedEntity) and (collidedEntity:GetClass() == "prop_door_rotating" or collidedEntity:GetClass() == "func_door") then
                local ragdollVelocity = collisionData.OurOldVelocity:Length()
                if ragdollVelocity >= 450 then BreachDoor(ragdoll, collidedEntity, collisionData) end
            end
        end
    end

    hook.Add("PlayerInitialSpawn", "rads-knocked-callback", function(ply)
        ply:AddCallback("PhysicsCollide", function(phys, data) hook.Run("Player Collide", ply, data.HitEntity, data) end)
        net.Start("RADS.CHATSAY")
        net.Send(ply)
    end)

    hook.Add("Player Collide", "rads-knocked", function(ply, hitEnt, data)
        if GetConVar('rads_propknock'):GetBool() and not ply:HasGodMode() and data.Speed > 350 or not GetConVar('rads_propknock'):GetBool() and not ply:HasGodMode() and data.Speed >= 250 / hitEnt:GetPhysicsObject():GetMass() * 20 and not ply.fake and hitEnt:IsPlayerHolding() and hitEnt:GetVelocity():Length() > 150 then
            timer.Simple(0, function()
                if not IsValid(ply) or ply.fake then return end
                if hook.Run("Should Fake Collide", ply, hitEnt, data) == false then return end
                rads(ply)
                RADS.PainSound(ply)
            end)
        end
    end)

    util.AddNetworkString('nodraw_helmet')
    function CreateArmor(ragdoll, info)
        local item = JMod.ArmorTable[info.name]
        if not item then return end
        local Index = ragdoll:LookupBone(item.bon)
        if not Index then return end
        local Pos, Ang = (ply or ragdoll):GetBonePosition(Index)
        if not Pos then return end
        local ent = ents.Create(item.ent)
        local Right, Forward, Up = Ang:Right(), Ang:Forward(), Ang:Up()
        Pos = Pos + Right * item.pos.x + Forward * item.pos.y + Up * item.pos.z
        Ang:RotateAroundAxis(Right, item.ang.p)
        Ang:RotateAroundAxis(Up, item.ang.y)
        Ang:RotateAroundAxis(Forward, item.ang.r)
        ent.IsArmor = true
        ent:SetPos(Pos)
        ent:SetAngles(Ang)
        local color = info.col
        ent:SetColor(Color(color.r, color.g, color.b, color.a))
        ent:Spawn() -- timer.Simple(.1,function()
        ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE) -- ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        if IsValid(ent:GetPhysicsObject()) then
            ent:GetPhysicsObject():SetMaterial("Armorflesh")
            ent:GetPhysicsObject():SetMass(1)
            ent:GetPhysicsObject():EnableCollisions(false)
        end

        timer.Simple(0.1, function()
            local ply = RagdollOwner(ragdoll) -- end)
            if item.bon == "ValveBiped.Bip01_Head1" and ply and IsValid(ply) and ply:IsPlayer() then
                net.Start("nodraw_helmet")
                net.WriteEntity(ent)
                net.Send(ply)
            end
        end)

        constraint.Weld(ent, ragdoll, 0, ragdoll:TranslateBoneToPhysBone(Index), 0, true, false)
        ragdoll:DeleteOnRemove(ent)
        return ent
    end

    local function Remove(self, ply)
        if self.override then return end
        self.ragdoll.armors[self.armorID] = nil
        JMod.RemoveArmorByID(ply, self.armorID, true)
    end

    local function RemoveRag(self)
        for id, ent in pairs(self.armors) do
            if not IsValid(ent) then continue end
            ent.override = true
            ent:Remove()
        end
    end

    hook.Add("OnEntityCreated", "ragdoor", function(ent) if IsValid(ent) and ent:IsRagdoll() and GetConVar('rads_doorbreach'):GetBool() then ent:AddCallback("PhysicsCollide", function(ragdoll, collisionData) RADS_RagdollCollision(ragdoll, collisionData) end) end end)
    function BreachDoor(ragdoll, door, collisionData)
        if GetConVar('rads_doorbreach'):GetBool() then
            local ragdollVelocity = collisionData.OurOldVelocity:GetNormalized()
            local breachedDoor = ents.Create("prop_physics")
            breachedDoor:SetModel(door:GetModel())
            breachedDoor:SetSkin(door:GetSkin())
            for key, value in pairs(door:GetBodyGroups()) do
                breachedDoor:SetBodygroup(value.id, door:GetBodygroup(value.id))
            end

            breachedDoor:SetPos(door:GetPos())
            breachedDoor:SetAngles(door:GetAngles())
            door:Remove()
            breachedDoor:Spawn()
            local phys = breachedDoor:GetPhysicsObject()
            if IsValid(phys) then
                local force = ragdollVelocity * phys:GetMass()
                phys:ApplyForceCenter(force, collisionData.HitPos)
            end
        end
    end

    concommand.Add("rads_god", function(ply, cmd, args)
        if IsValid(ply) and ply:IsSuperAdmin() then
            if ply:HasGodMode() then
                ply:GodDisable()
                ply:PrintMessage(HUD_PRINTTALK, "God disabled.")
            else
                ply:GodEnable()
                ply:EmitSound("restains.wav", 150, 200, 1, CHAN_ITEM)
                ply:PrintMessage(HUD_PRINTTALK, "God enabled.")
            end
        end
    end)

    hook.Add("EntityFireBullets", "lol", function(ent, data)
        if ent:IsPlayer() and not ent.fake and GetConVar("rads_firefall"):GetBool() then
            if math.random() < 0.01 then
                ent:SetVelocity(-Vector(0, 35, 0))
                rads(ent)
            end
        end
    end)

    hook.Add("EntityTakeDamage", "falldamage", function(target, dmginfo)
        if GetConVar('rads_ragonfall'):GetBool() then
            if target:IsPlayer() and dmginfo:IsFallDamage() and not target.fake then
                if dmginfo:GetDamage() > 8 then
                    target:EmitSound("NPC_Barnacle.BreakNeck", 511, 200, 1, CHAN_ITEM)
                    rads(target)
                end
            end
        end
    end)

    hook.Add("PlayerDeathSound", "DeFlatline", function()
        return true -- hook.Add("EntityTakeDamage", "fallonexploded", function(target, damageInfo) --     if IsValid(target) and target:IsPlayer() and not target.fake then --         local damageType = damageInfo:GetDamageType() --         if (damageType == DMG_BLAST) then --             rads(target) --             local rag = target:GetNWEntity('player_ragdoll') --             if IsValid(rag) then --                 local forceMagnitude = math.min(damageInfo:GetDamage() * 100, 5000)  --                 local explosionPosition = damageInfo:GetDamagePosition() --                 for i = 0, rag:GetPhysicsObjectCount() - 1 do --                     local physobj = rag:GetPhysicsObjectNum(i) --                     if IsValid(physobj) then --                         local bonePosition, boneAngle = rag:GetBonePosition(rag:TranslatePhysBoneToBone(i)) --                         if bonePosition and boneAngle then --                             local forceDirection = (bonePosition - explosionPosition):GetNormalized()  --                             physobj:ApplyForceOffset(forceDirection * forceMagnitude, bonePosition) --                         end --                     end --                 end --             end        --         end --     end -- end)
    end)

    local noise = Sound("death.wav")
    hook.Add("PlayerDeath", "NewSound", function(vic, unused1, unused2) vic:EmitSound(noise) end)
    hook.Add("PlayerTick", "CheckPlayerSpeed", function(ply, mv)
        if GetConVar('rads_fallonspeedlimit'):GetBool() and not ply.fake then
            local speed = ply:GetVelocity():Length()
            local rag = ply:GetNWEntity('player_ragdoll')
            if not IsValid(rag) and ply:GetMoveType() ~= MOVETYPE_NOCLIP and not ply:HasGodMode() and ply:GetMoveType() ~= MOVETYPE_OBSERVER then
                if speed >= 900 then
                    rads(ply)
                    RADS.FreeFall(ply)
                end
            end
        end
    end)

    hook.Add("RADSLoadout", "RADSLuaLoad", function(ply)
        if not ply.resetinv and not GetConVar('rads_loadoutusinglua'):GetBool() then
            return
        else
            RADS_ReturnPlyInfo(ply)
            RADS_RestoreEzArmor(ply)
        end

        if RADS.IsTTT() then
            ply:Give('weapon_zm_improvised')
            ply:Give('weapon_zm_carry')
            ply:Give('weapon_ttt_unarmed')
        end
    end)

    hook.Add("PreCleanupMap", "getupnoobis", function()
        for i, v in pairs(player.GetAll()) do
            if v.brokenspine then v:Kill() end
            if v.fake then rads(v) end
        end
    end)

    util.AddNetworkString("ebal_chellele")
    hook.Add("PlayerSwitchWeapon", "fakewep", function(ply, oldwep, newwep)
        rag = ply:GetNWEntity('player_ragdoll')
        if IsValid(rag) then
            if ply.fake then
                if IsValid(ply.Info.ActiveWeapon2) and IsValid(ply.wep) and ply.wep.Clip ~= nil and ply.wep.Amt ~= nil and ply.wep.AmmoType ~= nil then
                    ply.Info.ActiveWeapon2:SetClip1(ply.wep.Clip or 0)
                    ply:SetAmmo(ply.wep.Amt or 0, ply.wep.AmmoType or 0)
                end

                if table.HasValue(Guns, newwep:GetClass()) then
                    if IsValid(ply.wep) then DespawnWeapon(ply) end
                    ply:SetActiveWeapon(newwep)
                    ply.Info.ActiveWeapon = newwep
                    ply.curweapon = newwep:GetClass()
                    RADS_SavePlyInfo(ply)
                    ply:SetActiveWeapon(nil)
                    SpawnWeapon(ply)
                    ply.FakeShooting = true
                else
                    if IsValid(ply.wep) then DespawnWeapon(ply) end
                    ply:SetActiveWeapon(nil)
                    ply.curweapon = nil
                    ply.FakeShooting = false
                end

                net.Start("ebal_chellele")
                net.WriteEntity(ply)
                net.WriteString(ply.curweapon or "")
                net.Broadcast()
                return true
            end
        end
    end)

    hook.Add("Player Think", "ragmovement", function(ply, time)
        if not ply:Alive() then return end
        local rag = ply:GetNWEntity('player_ragdoll')
        if not IsValid(rag) or not ply:Alive() then return end
        local walkTime = 1 -- rag:SetFlexWeight(5,0)
        local eyeangs = ply:EyeAngles()
        local head = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_Head1")))
        if ply:KeyDown(IN_ATTACK) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local pos = ply:EyePos()
            pos[3] = head:GetPos()[3]
            if not ply.FakeShooting then
                local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand")))
                local ang = ply:EyeAngles()
                ang:RotateAroundAxis(eyeangs:Forward(), 90)
                ang:RotateAroundAxis(eyeangs:Right(), 75)
                local shadowparams = {
                    secondstoarrive = 0.4,
                    pos = head:GetPos() + eyeangs:Forward() * 50 + eyeangs:Right() * -5,
                    angle = ang,
                    maxangular = 670,
                    maxangulardamp = 600,
                    maxspeeddamp = 50,
                    maxspeed = 500,
                    teleportdistance = 0,
                    deltatime = 0.01,
                }

                phys:Wake()
                phys:ComputeShadowControl(shadowparams)
            end
        end

        if ply.curweapon and Automatic[ply.curweapon] then
            if ply:KeyDown(IN_ATTACK) then if ply.FakeShooting then FireShot(ply.wep) end end
        else
            if ply:KeyPressed(IN_ATTACK) then if ply.FakeShooting then FireShot(ply.wep) end end
        end

        if ply:KeyDown(IN_JUMP) and (table.Count(constraint.FindConstraints(ply:GetNWEntity("player_ragdoll"), 'Rope')) > 0 or ((rag.IsWeld or 0) > 0)) and (ply.lastuntietry or 0) < CurTime() and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then -- if(ply:KeyDown(IN_MOVERIGHT)) and !timer.Exists("StunTime"..ply:EntIndex()) and !timer.Exists("Epilepsy"..ply:EntIndex()) and not ply.Otrub then --     local pos = ply:EyePos() --     pos[3] = head:GetPos()[3] --         local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Calf" )) ) --         local ang=ply:EyeAngles() --         ang:RotateAroundAxis(eyeangs:Forward(),90) --         ang:RotateAroundAxis(eyeangs:Right(),80) --         local shadowparams = { --             secondstoarrive=0.4, --             pos=head:GetPos()+eyeangs:Forward()*55+eyeangs:Right()*2, --             angle=ang, --             maxangular=670, --             maxangulardamp=600, --             maxspeeddamp=50, --             maxspeed=500, --             teleportdistance=0, --             deltatime=0.01, --         } --         phys:Wake() --         phys:ComputeShadowControl(shadowparams) --     end -- if(ply:KeyDown(IN_MOVELEFT)) and !timer.Exists("StunTime"..ply:EntIndex()) and !timer.Exists("Epilepsy"..ply:EntIndex()) and not ply.Otrub then --     local pos = ply:EyePos() --     pos[3] = head:GetPos()[3] --         local phys = rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Calf" )) ) --         local ang=ply:EyeAngles() --         ang:RotateAroundAxis(eyeangs:Forward(),90) --         ang:RotateAroundAxis(eyeangs:Right(),80) --         local shadowparams = { --             secondstoarrive=0.4, --             pos=head:GetPos()+eyeangs:Forward()*55+eyeangs:Right()*2, --             angle=ang, --             maxangular=670, --             maxangulardamp=600, --             maxspeeddamp=50, --             maxspeed=500, --             teleportdistance=0, --             deltatime=0.01, --         } --         phys:Wake() --         phys:ComputeShadowControl(shadowparams) --     end
            ply.lastuntietry = CurTime() + 1
            rag.IsWeld = math.max((rag.IsWeld or 0) - 0.1, 0)
            local RopeCount = table.Count(constraint.FindConstraints(ply:GetNWEntity("player_ragdoll"), 'Rope'))
            Ropes = constraint.FindConstraints(ply:GetNWEntity("player_ragdoll"), 'Rope')
            Try = math.random(1, 10 * RopeCount)
            local phys = rag:GetPhysicsObjectNum(1)
            local speed = 200
            local shadowparams = {
                secondstoarrive = 0.05,
                pos = phys:GetPos() + phys:GetAngles():Forward() * 20,
                angle = phys:GetAngles(),
                maxangulardamp = 30,
                maxspeeddamp = 30,
                maxangular = 90,
                maxspeed = speed,
                teleportdistance = 0,
                deltatime = 0.01,
            }

            phys:Wake()
            phys:ComputeShadowControl(shadowparams)
            if Try > (7 * RopeCount) or ((rag.IsWeld or 0) > 0) then
                if RopeCount > 1 or (rag.IsWeld or 0 > 0) then
                    if RopeCount > 1 then ply:ChatPrint("Осталось: " .. RopeCount - 1) end
                    if (rag.IsWeld or 0) > 0 then ply:ChatPrint("Осталось отбить гвоздей: " .. tostring(math.ceil(rag.IsWeld))) end
                else
                    ply:ChatPrint("Ты развязался")
                end

                Ropes[1].Constraint:Remove()
                rag:EmitSound("restains.wav", 90, 50, 0.5, CHAN_AUTO)
            end
        end

        if ply:KeyDown(IN_USE) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local phys = head
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(), 90)
            local shadowparams = {
                secondstoarrive = 0.5,
                pos = head:GetPos() + Vector(0, 0, 20 / math.Clamp(rag:GetVelocity():Length() / 300, 1, 12)),
                angle = angs,
                maxangulardamp = 10,
                maxspeeddamp = 10,
                maxangular = 370,
                maxspeed = 40,
                teleportdistance = 0,
                deltatime = deltatime,
            }

            head:Wake()
            head:ComputeShadowControl(shadowparams)
        end

        if ply:KeyDown(IN_ATTACK2) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local physa = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand")))
            local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand"))) --rhand
            local ang = ply:EyeAngles()
            ang:RotateAroundAxis(eyeangs:Forward(), 90)
            ang:RotateAroundAxis(eyeangs:Right(), 75)
            local pos = ply:EyePos()
            pos[3] = head:GetPos()[3]
            local shadowparams = {
                secondstoarrive = 0.4,
                pos = head:GetPos() + eyeangs:Forward() * 50 + eyeangs:Right() * 15,
                angle = ang,
                maxangular = 670,
                maxangulardamp = 600,
                maxspeeddamp = 50,
                maxspeed = 500,
                teleportdistance = 0,
                deltatime = 0.01,
            }

            physa:Wake()
            if not ply.suiciding or TwoHandedOrNo[ply.curweapon] then
                if TwoHandedOrNo[ply.curweapon] and IsValid(ply.wep) then
                    local ang = ply:EyeAngles()
                    ang:RotateAroundAxis(ang:Forward(), 90)
                    ang:RotateAroundAxis(ang:Up(), 20)
                    ang:RotateAroundAxis(ang:Right(), 10)
                    shadowparams.angle = ang
                    ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
                    shadowparams.pos = shadowparams.pos
                    phys:ComputeShadowControl(shadowparams)
                    shadowparams.pos = shadowparams.pos + eyeangs:Forward() * -50 + eyeangs:Right() * -15
                    physa:ComputeShadowControl(shadowparams)
                elseif IsValid(ply.wep) and IsValid(ply.wep:GetPhysicsObject()) then
                    ang:RotateAroundAxis(ply:EyeAngles():Forward(), 90)
                    ang:RotateAroundAxis(ply:EyeAngles():Up(), 110)
                    ang:RotateAroundAxis(eyeangs:Right(), -30)
                    shadowparams.angle = ang
                    shadowparams.pos = shadowparams.pos + eyeangs:Right() * -15
                    ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
                    physa:ComputeShadowControl(shadowparams)
                else
                    physa:ComputeShadowControl(shadowparams)
                end
            else
                if ply.FakeShooting and IsValid(ply.wep) then
                    shadowparams.maxspeed = 500
                    shadowparams.maxangular = 500
                    shadowparams.pos = head:GetPos() - ply.wep:GetAngles():Forward() * 12
                    shadowparams.angle = ply.wep:GetPhysicsObject():GetAngles()
                    ply.wep:GetPhysicsObject():ComputeShadowControl(shadowparams)
                    physa:ComputeShadowControl(shadowparams)
                end
            end
        end

        if ply:KeyDown(IN_SPEED) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local bone = rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand"))
            local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand")))
            if not IsValid(rag.ZacConsLH) and (not rag.ZacNextGrLH or rag.ZacNextGrLH <= CurTime()) then -- if !TwoHandedOrNo[ply.curweapon] then --     local shadowparams = { --     secondstoarrive=0.5, --     pos=head:GetPos(), --     angle=angs, --     maxangulardamp=10, --     maxspeeddamp=10, --     maxangular=370, --     maxspeed=1120, --     teleportdistance=0, --     deltatime=deltatime, --     } --     phys:Wake() --     phys:ComputeShadowControl(shadowparams)
                rag.ZacNextGrLH = CurTime() + 0.1
                for i = 1, 3 do
                    local offset = phys:GetAngles():Up() * -5
                    if i == 2 then offset = phys:GetAngles():Right() * 5 end
                    if i == 3 then offset = phys:GetAngles():Right() * -5 end
                    local traceinfo = {
                        start = phys:GetPos(),
                        endpos = phys:GetPos() + offset,
                        filter = rag,
                        output = trace,
                    }

                    local trace = util.TraceLine(traceinfo)
                    if trace.Hit and not trace.HitSky then
                        local cons = constraint.Weld(rag, trace.Entity, bone, trace.PhysicsBone, GetConVar('rads_lefthandlimit'):GetInt(), false, false)
                        if IsValid(cons) then
                            rag.ZacConsLH = cons
                            local pos = rag.ZacConsLH:GetPos() -- rag:EmitSound("physics/rubber/rubber_tire_strain3.wav", 100, 100, 1)   -- if IsValid(rag.ZacConsLH) then
                            net.Start("CapturePositionLH")
                            net.WriteVector(pos)
                            net.Send(ply)
                            if trace.Entity:IsPlayer() and GetConVar('rads_fallwhengrabbed'):GetBool() then -- end 
                                rads(trace.Entity)
                            end
                        end

                        break
                    end
                end
            end
        else
            if IsValid(rag.ZacConsLH) then
                rag.ZacConsLH:Remove()
                rag.ZacConsLH = nil
            end
        end

        if ply:KeyDown(IN_WALK) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then -- end
            local bone = rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand"))
            local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand")))
            if not IsValid(rag.ZacConsRH) and (not rag.ZacNextGrRH or rag.ZacNextGrRH <= CurTime()) then
                rag.ZacNextGrRH = CurTime() + 0.1
                for i = 1, 3 do
                    local offset = phys:GetAngles():Up() * 5
                    if i == 2 then offset = phys:GetAngles():Right() * 5 end
                    if i == 3 then offset = phys:GetAngles():Right() * -5 end
                    local traceinfo = {
                        start = phys:GetPos(),
                        endpos = phys:GetPos() + offset,
                        filter = rag,
                        output = trace,
                    }

                    local trace = util.TraceLine(traceinfo)
                    if trace.Hit and not trace.HitSky then
                        local cons = constraint.Weld(rag, trace.Entity, bone, trace.PhysicsBone, GetConVar('rads_righthandlimit'):GetInt(), false, false)
                        if IsValid(cons) then
                            rag.ZacConsRH = cons
                            local pos = rag.ZacConsRH:GetPos() -- rag:EmitSound("physics/rubber/rubber_tire_strain3.wav", 100, 100, 1)  -- if IsValid(rag.ZacConsRH) then
                            net.Start("CapturePositionRH")
                            net.WriteVector(pos)
                            net.Send(ply)
                            if trace.Entity:IsPlayer() and GetConVar('rads_fallwhengrabbed'):GetBool() then -- end
                                rads(trace.Entity)
                            end
                        end

                        break
                    end
                end
            end
        else
            if IsValid(rag.ZacConsRH) then
                rag.ZacConsRH:Remove()
                rag.ZacConsRH = nil
            end
        end

        if (ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsLH)) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_Spine")))
            local lh = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand")))
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(), 90)
            angs:RotateAroundAxis(angs:Up(), 90)
            local speed = GetConVar('rads_pullupspeed'):GetInt()
            if rag.ZacConsLH.Ent2:GetVelocity():LengthSqr() < 1000 then
                local shadowparams = {
                    secondstoarrive = 0.5,
                    pos = lh:GetPos(),
                    angle = phys:GetAngles(),
                    maxangulardamp = 10,
                    maxspeeddamp = 10,
                    maxangular = 50,
                    maxspeed = speed,
                    teleportdistance = 0,
                    deltatime = deltatime,
                }

                phys:Wake()
                phys:ComputeShadowControl(shadowparams)
            end
        end

        if (ply:KeyDown(IN_FORWARD) and IsValid(rag.ZacConsRH)) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local phys = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_Spine")))
            local rh = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand")))
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(), 90)
            angs:RotateAroundAxis(angs:Up(), 90)
            local speed = GetConVar('rads_pullupspeed'):GetInt()
            if rag.ZacConsRH.Ent2:GetVelocity():LengthSqr() < 1000 then
                local shadowparams = {
                    secondstoarrive = 0.5,
                    pos = rh:GetPos(),
                    angle = phys:GetAngles(),
                    maxangulardamp = 10,
                    maxspeeddamp = 10,
                    maxangular = 50,
                    maxspeed = speed,
                    teleportdistance = 0,
                    deltatime = deltatime,
                }

                phys:Wake()
                phys:ComputeShadowControl(shadowparams)
            end
        end

        if (ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsLH)) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local phys = rag:GetPhysicsObjectNum(1)
            local chst = rag:GetPhysicsObjectNum(0)
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(), 90)
            angs:RotateAroundAxis(angs:Up(), 90)
            local speed = 30
            if rag.ZacConsLH.Ent2:GetVelocity():LengthSqr() < 1000 then
                local shadowparams = {
                    secondstoarrive = 0.5,
                    pos = chst:GetPos(),
                    angle = phys:GetAngles(),
                    maxangulardamp = 10,
                    maxspeeddamp = 10,
                    maxangular = 50,
                    maxspeed = speed,
                    teleportdistance = 0,
                    deltatime = deltatime,
                }

                phys:Wake()
                phys:ComputeShadowControl(shadowparams)
            end
        end

        if (ply:KeyDown(IN_BACK) and IsValid(rag.ZacConsRH)) and not timer.Exists("StunTime" .. ply:EntIndex()) and not timer.Exists("Epilepsy" .. ply:EntIndex()) and not ply.Otrub then
            local phys = rag:GetPhysicsObjectNum(1)
            local chst = rag:GetPhysicsObjectNum(0)
            local angs = ply:EyeAngles()
            angs:RotateAroundAxis(angs:Forward(), 90)
            angs:RotateAroundAxis(angs:Up(), 90)
            local speed = 30
            if rag.ZacConsRH.Ent2:GetVelocity():LengthSqr() < 1000 then
                local shadowparams = {
                    secondstoarrive = 0.5,
                    pos = chst:GetPos(),
                    angle = phys:GetAngles(),
                    maxangulardamp = 10,
                    maxspeeddamp = 10,
                    maxangular = 50,
                    maxspeed = speed,
                    teleportdistance = 0,
                    deltatime = deltatime,
                }

                phys:Wake()
                phys:ComputeShadowControl(shadowparams)
            end
        end
    end)

    util.AddNetworkString('CapturePositionRH')
    util.AddNetworkString('CapturePositionLH')
    hook.Add("Player Think", "Pulse", function(ply, curTime)
        if not ply.pulse and ply:Alive() then ply.pulse = 70 end
        local rag = ply:GetNWEntity('player_ragdoll')
        local lastPulseChange = ply.lastPulseChange or 0
        if curTime - lastPulseChange >= 2 then
            local change = math.random(-7, 7)
            if ply.pulse >= 130 then
                ply.pulse = math.max(ply.pulse - math.random(3, 5), 0)
                ply:SetNWBool("radshighpulse", true)
            elseif ply.pulse <= 50 and ply:Alive() then
                ply.pulse = math.min(ply.pulse + math.random(10, 20), 100)
                ply:SetNWBool("radshighpulse", false)
            end

            if not ply:Alive() then ply.pulse = 0 end
            if ply.pulse >= 55 and ply.pulse <= 129 then ply:SetNWBool("radshighpulse", false) end
            ply.pulse = ply.pulse + change
            rag.pulse = ply.pulse
            ply.lastPulseChange = curTime
        end
    end)
end

if CLIENT then
    surface.CreateFont("ScFont", {
        font = "Roboto",
        size = 24,
        weight = 1100,
        outline = false
    })

    lastView = nil
    local organData = {}
    local function DrawOrganRect(x, y, width, height, healthPercentage, organName)
        local filledWidth = width * healthPercentage
        draw.RoundedBox(0, x, y, width, filledWidth, Color(0, 255, 0))
        draw.RoundedBox(0, x, y, width, height, Color(255, 0, 0))
        draw.SimpleText(organName, "DefaultFixedDropShadow", x + width / 2, y + filledWidth / 2 + 35, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("HP: " .. math.floor(healthPercentage * 100), "DefaultFixedDropShadow", x + width / 2, y + filledWidth / 2 + 45, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end

    local function DrawOrganHealth()
        if not organData.organs or next(organData.organs) == nil then return end
        local startX = 55
        local startY = 55
        local width = 35
        local height = 100
        for organ, health in pairs(organData.organs) do
            local healthPercentage = health / 100
            local organName = organ
            DrawOrganRect(startX, startY, width, height * healthPercentage, healthPercentage, organName)
            startX = startX + width + 25
        end
    end

    net.Receive("info_org", function()
        organData = net.ReadTable()
        DrawOrganHealth()
    end)

    hook.Add("HUDPaint", "DrawOrganHealth", function() if GetConVar('rads_draworg'):GetBool() then DrawOrganHealth() end end)
    CreateClientConVar("rads_draworg", "0", {FCVAR_ARCHIVE, ""})
    CreateClientConVar("rads_thirdperson", "0", {FCVAR_ARCHIVE, "Thirdperson"})
    CreateClientConVar("rads_viewmode", "1", {FCVAR_ARCHIVE, "0 means view from eyes but with movement,1 means from eyes without movement"})
    CreateClientConVar("rads_debug", "0", {"FOR DEBUGGING"})
    CreateClientConVar("rads_mouthscale", "6", {FCVAR_ARCHIVE, "Mouth Scale while speaking"})
    CreateClientConVar("rads_viewfov", "100", {FCVAR_ARCHIVE, "Fov in ragdoll."})
    CreateClientConVar("rads_disablelerp", "0", {FCVAR_ARCHIVE, ""})
    CreateClientConVar("rads_drawmotd", "1", {FCVAR_ARCHIVE, "Draw motd"})
    hook.Add("OnEntityCreated", "pastedcolorragdolls", function(ent)
        if ent:IsRagdoll() then
            timer.Create("ragdollcolors-timer" .. tostring(ent), 0.1, 0, function()
                if IsValid(ent) then
                    ent.playerColor = ent:GetNWVector("plycolor")
                    ent.GetPlayerColor = function() return ent.playerColor end
                    timer.Remove("ragdollcolors-timer" .. tostring(ent))
                end
            end)
        end
    end)

    local helmEnt
    net.Receive("nodraw_helmet", function() helmEnt = net.ReadEntity() end)
    if IsValid(helmEnt) then
        helmEnt:SetNoDraw(true)
        helmEnt:SetColor(Color(0, 0, 0, 0))
        helmEnt:SetRenderMode(RENDERMODE_TRANSCOLOR)
    end

    hook.Add("Think", "mouthanim", function()
        for i, ply in pairs(player.GetAll()) do
            local ent = IsValid(ply:GetNWEntity("player_ragdoll")) and ply:GetNWEntity("player_ragdoll") or ply
            local flexes = {ent:GetFlexIDByName("jaw_drop"), ent:GetFlexIDByName("left_part"), ent:GetFlexIDByName("right_part"), ent:GetFlexIDByName("left_mouth_drop"), ent:GetFlexIDByName("right_mouth_drop")}
            local volume = ply:VoiceVolume()
            local weight = math.Clamp(volume * 666, 0, 6) or 0
            if ply:IsSpeaking() then
                for k, v in pairs(flexes) do
                    ent:SetFlexWeight(v, weight)
                end
            end
        end
    end)
    local oldFakeOrigin = Vector(0, 0, 0)
    local oldFakeAng = Angle(0, 0, 0)
    local oldOrigin = Vector(0, 0, 0)
    local oldAng = Angle(0, 0, 0)
    local lerping = 1
    local MyLerp = 0
    function HomigradCam(ply, vec, ang, fov, znear, zfar)
        local eye = ply:GetAttachment(ply:LookupAttachment("eyes"))
        local org = eye.Pos
        local ang1 = LerpAngle(0, ply:EyeAngles(), eye.Ang)
        local org1 = eye.Pos + eye.Ang:Up() * 2 + eye.Ang:Forward() * 2.5
        local fov = math.Clamp(ply:GetInfoNum("rads_viewfov", 100), 80, 150)
        if ply:GetInfoNum('rads_thirdperson', 0) == 1 then fov = 100 end
        if ply:GetNWBool("radsfa") == true and IsValid(ply:GetNWEntity("player_ragdoll")) then
            local attach = ply:GetNWEntity("player_ragdoll"):GetAttachment(1)
            local headBoneIndex = ply:GetNWEntity("player_ragdoll"):LookupBone("ValveBiped.Bip01_Head1")
            ply:GetNWEntity("player_ragdoll"):ManipulateBoneScale(headBoneIndex, Vector(0, 0, 0))
            lerping = Lerp(3 * FrameTime(), lerping, 0)
            local view = {
                origin = LerpVector(lerping, attach.Pos, oldOrigin),
                angles = LerpAngle(lerping, LerpAngle(0.35, ang1, attach.Ang), oldAng),
                fov = fov,
                drawviewer = true
            }

            oldFakeOrigin = view.origin
            oldFakeAng = view.angles
            return view
        end

        if ply:InVehicle() == true then
            -- org = eye.Pos + eye.Ang:Forward() * 0.8
            ang = eye.Ang
            MyLerp = 1
            ply:ManipulateBoneScale(ply:LookupBone("ValveBiped.Bip01_Head1"), vector_origin)
            anglerp = LerpAngle(MyLerp, ang1, ang)
        else
            anglerp = LerpAngle(MyLerp / 2, ang1, sightAng or Angle(0, 0, 0))
        end

        lerping = Lerp(3 * FrameTime(), lerping, 1)
        local view = {
            origin = LerpVector(lerping, oldFakeOrigin, LerpVector(MyLerp, org1, org)),
            angles = LerpAngle(lerping, oldFakeAng, LerpAngle(0.01, anglerp, ang1)),
            fov = fov,
            drawviewer = true,
            -- znear = 0.2
        }

        oldOrigin = view.origin
        oldAng = view.angles
        return view
    end

    function RadsMM(ply, origin, angles, fov)
        local rag = ply:GetNWEntity("player_ragdoll")
        if IsValid(rag) then
            local att = rag:GetAttachment(rag:LookupAttachment("eyes"))
            if att then
                local view = {}
                local v = angles
                if lastView == nil then
                    lastView = {
                        origin = att.Pos,
                        angles = att.Ang,
                        fov = fov
                    }
                end

                local lerpedAngles = LerpAngle(0.8, lastView.angles, att.Ang)
                local lerpedang = LerpAngle(0.8, lastView.angles, v)
                if ply:GetInfoNum("rads_viewmode", 1) == 1 then
                    view.origin = att.Pos
                    view.angles = lerpedAngles
                else
                    if ply:GetInfoNum("rads_thirdperson", 0) == 1 then
                        view.origin = rag:GetPos() - (angles:Forward() * 100) + Vector(0, 0, 50)
                        view.angles = angles
                    else
                        if GetConVar("rads_disablelerp"):GetInt() == 1 then
                            view.origin = att.Pos
                            view.angles = Angle(lerpedang.p, lerpedang.y, additionalRoll)
                        else
                            view.origin = att.Pos
                            view.angles = lerpedang -- тут гавно
                        end
                    end
                end

                view.znear = 1
                fov = math.Clamp(ply:GetInfoNum("rads_viewfov", 100), 80, 150)
                if ply:GetInfoNum('rads_thirdperson', 0) == 1 then fov = 100 end
                view.fov = fov
                view.drawviewer = true
                lastView = {
                    origin = view.origin,
                    angles = view.angles,
                    fov = fov
                }
                return view
            end
        end
    end

    net.Receive("REMOVECALC", function(ply) hook.Remove('CalcView', 'govnishe') end)
    net.Receive('ADDCALC', function(ply) 
    hook.Add("CalcView", "govnishe", RadsMM) 
    -- hook.Add("CalcView", "govnishe", HomigradCam) 
    end)
    scrw, scrh = ScrW(), ScrH()
    hook.Add("RenderScreenspaceEffects", "RADS.FFAFAPFPAP", function()
        local ply = LocalPlayer()
        local rag = ply:GetNWBool('radsfa')
        local pulsehigh = ply:GetNWBool('radshighpulse')
        if rag and not GetConVar("rads_thirdperson"):GetBool() then DrawToyTown(2, ScrH() / 2) end
        if pulsehigh then
            DrawMotionBlur(0.4, 0.8, 0.01)
            DrawBloom(0.65, 2, 9, 9, 1, 1, 1, 1, 1)
        end
    end)

    local grtodown = Material("vgui/gradient-u")
    local grtoup = Material("vgui/gradient-d")
    local grtoright = Material("vgui/gradient-l")
    local grtoleft = Material("vgui/gradient-r")
    pain, painlosing, impulse = 0, 0, 0
    net.Receive("info_pain", function()
        pain = net.ReadFloat()
        painlosing = net.ReadFloat()
    end)

    local ScrW, ScrH = ScrW, ScrH
    local math_Clamp = math.Clamp
    local k = 0
    local k4 = 0
    local time = 0
    pain, painlosing, impulse = 0, 0, 0
    net.Receive("info_pain", function()
        pain = net.ReadFloat()
        painlosing = net.ReadFloat()
    end)

    local icons = {}
    net.Receive("CapturePositionLH", function()
        local posLH = net.ReadVector()
        table.insert(icons, {
            pos = posLH,
            time = CurTime()
        })
    end)

    net.Receive("CapturePositionRH", function()
        local posRH = net.ReadVector()
        table.insert(icons, {
            pos = posRH,
            time = CurTime()
        })
    end)

    hook.Add("HUDPaint", "DrawIcons", function()
        if posLH ~= nil or posRH ~= nil then
            for i, icon in ipairs(icons) do
                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(Material("vgui/gmod_hand"))
                surface.DrawTexturedRect(icon.pos.x, icon.pos.y, iconWidth, iconHeight)
                if CurTime() - icon.time >= 5 then table.remove(icons, i) end
            end
        end
    end)

    hook.Add("HUDPaint", "PainEffect", function()
        local w, h = ScrW(), ScrH() -- if not LocalPlayer():Alive() then return end
        local k = Lerp(0.1, k, math.Clamp(pain / 250, 0, 15))
        local k2 = painlosing >= 5 and (painlosing / 5 - 1) or 0
        DrawMotionBlur(0.2, k2 * 0.9, k2 * 0.06)
        surface.SetMaterial(grtodown)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(0, h * k - h, w, h * 2)
        surface.SetMaterial(grtoup)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(0, h - h * k, w, h)
        surface.SetMaterial(grtoright)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(-w + w * k, 0, w, h)
        surface.SetMaterial(grtoleft)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(w - w * k, 0, w, h)
        DrawMotionBlur(0.2, k * 0.7, k * 0.03)
    end)

    local addmat_r = Material("CA/add_r")
    local addmat_g = Material("CA/add_g")
    local addmat_b = Material("CA/add_b")
    local vgbm = Material("vgui/black")
    local function DrawCA(rx, gx, bx, ry, gy, by)
        render.UpdateScreenEffectTexture()
        addmat_r:SetTexture("$basetexture", render.GetScreenEffectTexture())
        addmat_g:SetTexture("$basetexture", render.GetScreenEffectTexture())
        addmat_b:SetTexture("$basetexture", render.GetScreenEffectTexture())
        render.SetMaterial(vgbm)
        render.DrawScreenQuad()
        render.SetMaterial(addmat_r)
        render.DrawScreenQuadEx(-rx / 2, -ry / 2, ScrW() + rx, ScrH() + ry)
        render.SetMaterial(addmat_g)
        render.DrawScreenQuadEx(-gx / 2, -gy / 2, ScrW() + gx, ScrH() + gy)
        render.SetMaterial(addmat_b)
        render.DrawScreenQuadEx(-bx / 2, -by / 2, ScrW() + bx, ScrH() + by)
    end

    net.Receive("info_impulse", function() impulse = net.ReadFloat() * 50 end)
    local k3 = 0
    hook.Add("RenderScreenspaceEffects", "renderimpulse", function()
        k3 = math.Clamp(Lerp(0.01, k3, impulse), 0, 50)
        DrawCA(4 * k3, 2 * k3, 0, 2 * k3, 1 * k3, 0) -- if LocalPlayer():Alive() then
    end)

    net.Receive('RADS.CHATSAY', function()
        chat.AddText(Color(255, 0, 221), "THIS SERVER IS USING RADS RAGDOLL V2 BY < BLANK > & VIZY") -- end
    end)
end