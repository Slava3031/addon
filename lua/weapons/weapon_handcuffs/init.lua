include("shared.lua")
function SWEP:Cuff(ent)
    if not IsValid(ent) then
        return
    end
    local boneL = ent:LookupBone("ValveBiped.Bip01_L_Hand")
    local boneR = ent:LookupBone("ValveBiped.Bip01_R_Hand")

    if not boneL or not boneR then
        return
    end
    local physBoneL = ent:TranslateBoneToPhysBone(boneL)
    local physBoneR = ent:TranslateBoneToPhysBone(boneR)
    local ent1 = ent:GetPhysicsObjectNum(physBoneL)
    local ent2 = ent:GetPhysicsObjectNum(physBoneR)

    if not IsValid(ent1) or not IsValid(ent2) then
        return
    end
    local h = LerpVector(1, ent1:GetPos(), ent2:GetPos())
    ent1:SetPos(h)
    local cuff = ents.Create("prop_physics")
    local ang = ent:GetPhysicsObjectNum(4):GetAngles()
    ang:RotateAroundAxis(ang:Forward(),90)
    cuff:SetModel("models/freeman/flexcuffs.mdl")
    cuff:SetBodygroup(1,1)
    cuff:SetPos(ent2:GetPos())
    cuff:SetAngles(ang)
    cuff:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    cuff:Spawn()
    cuff:SetNoDraw(true)
    
    for i = 1,3 do constraint.Rope(ent,ent,5,7,Vector(0,0,0),Vector(0,0,0),-2,0,0,0,"cable/rope.vmt",false,Color(255,255,255)) end

    constraint.Weld(cuff,ent,0,7,0,true,false)
    constraint.Weld(cuff,ent,0,5,0,true,false)

    self:Remove()
end

