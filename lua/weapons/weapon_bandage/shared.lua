if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = "Bandage"
SWEP.Author = ""
SWEP.Category = "rads tool's"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/v_pred_bandages.mdl"
SWEP.WorldModel = "models/weapons/pred_bandages.mdl"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Bndg = true
function SWEP:Initialize()
    self:SetHoldType("normal")
end
function SWEP:Think()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if SERVER then
        if ply:KeyPressed(IN_ATTACK2) then
            local tr = ply:GetEyeTrace()
            if IsValid(tr.Entity) then
                local tre = tr.Entity
                if tr.Entity:GetClass() == "prop_ragdoll" then
                    trr = tr.Entity
                    tre = tr.Entity:GetNWEntity("owner")
                end
                if IsValid(tre) and tre:IsPlayer() and (tre.BloodLosing or 0) > 0 then
                    tre.BloodLosing = (tre.BloodLosing or 0) - 15
                    if tre.BloodLosing <= 0 then
                        BleedingEntities[trr] = nil
                    end
                    self.Weapon:Remove()
                end
            end
        end
    end
end

function SWEP:SecondaryAttack()
end


function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    if not IsValid(ply) then return end

    if SERVER then
        if ply.BloodLosing > 0 then
            ply.BloodLosing = ply.BloodLosing - 15
            self.Weapon:Remove()
        end
        self:SetNextPrimaryFire(CurTime() + 1)
    end
end
