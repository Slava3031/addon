AddCSLuaFile()
SWEP.Base = "medkit"
SWEP.PrintName = "Restains"
SWEP.Author = "desync"
SWEP.Instructions = "Cuff someone"
SWEP.Category = "rads tool's"
SWEP.Slot = 5
SWEP.SlotPos = 3
SWEP.Spawnable = true
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel = "models/freeman/flexcuffs.mdl"

if SERVER then
    util.AddNetworkString("huyvalues")
else
    net.Receive("huyvalues", function(len)
        local self = net.ReadEntity()
        self.CuffPly = net.ReadEntity()
        self.CuffTime = net.ReadFloat()
    end)
end

local cuffingInProgress = false 
local lastAttackTime = 0 
local cooldown = 3 

function SWEP:PrimaryAttack()
    if SERVER then
        local curTime = CurTime()

        if not cuffingInProgress and curTime >= lastAttackTime + cooldown then
            local owner = self:GetOwner()
            local tr = {}
            tr.start = owner:EyePos()
            local dir = owner:EyeAngles():Forward()
            tr.endpos = tr.start + dir * 150
            tr.filter = owner
            tr.mins = Vector(-5, -5, 0) 
            tr.maxs = Vector(5, 5, 20)

            local traceResult = util.TraceHull(tr)
            local ent = traceResult.Entity

            local ply = RagdollOwner(ent) and ent

            if IsValid(ent) and ply then
                self.CuffPly = ply
                self.CuffTime = curTime
                owner:Lock()
                net.Start("huyvalues")
                net.WriteEntity(self)
                net.WriteEntity(ply)
                net.WriteFloat(curTime)
                net.Send(owner)
                lastAttackTime = curTime 
                owner:UnLock()
            end
        end
    end
end
local cuffTime = 1.5
function SWEP:Think()
    if SERVER then
        if self.CuffPly then
            local pos1 = self.CuffPly:GetPos()
            local pos2 = self:GetOwner():GetPos()

            if pos1:Distance(pos2) >= 155 then
                self.CuffPly = nil
            elseif self.CuffTime and self.CuffTime + cuffTime <= CurTime() then

                self:Cuff(self.CuffPly)
                self.CuffPly = nil 
                self.CuffTime = nil 
            end
        end
    end
end
if CLIENT then
    function SWEP:DrawHUD()
        local owner = self:GetOwner()
        local tr = {}
        tr.start = owner:EyePos()
        local dir = owner:EyeAngles():Forward()
        tr.endpos = tr.start + dir * 45
        tr.filter = owner

        local traceResult = util.TraceLine(tr)
        local ent = traceResult.Entity

        local ply = RagdollOwner(ent) or ent
        ply = ply:IsPlayer() and ply
        local hit = traceResult.Hit and 1 or 0

        local x,y = traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y
        
        if not IsValid(ent) then
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255 * hit))
            draw.NoTexture()
            -- Circle(x, y, 5 / frac, 32)
        else
            local frac = traceResult.Fraction
            surface.SetDrawColor(Color(255, 255, 255, 255))
            draw.NoTexture()
            -- Circle(x, y, 5 / frac, 32)
            draw.DrawText(ply and ("связать "..ply:Nick()) or "", "TargetID", x, y - 40, color_white, TEXT_ALIGN_CENTER )
            if self.CuffTime then
                surface.DrawRect(x - 50,y + 50,100 - math.max((self.CuffTime - CurTime() + cuffTime) * 100,0),25)
            end
        end
    end
end