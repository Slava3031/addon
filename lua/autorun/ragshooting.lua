include( "autorun/weaponragshooting.lua" )
AddCSLuaFile( "autorun/weaponragshooting.lua" )
-- setmetatable(ShootWait, { __index = function() return 0.1 end })
cc = Vector


bullets = {
	["weapon_pwb_m590a1"] = 9,
	["weapon_pwb_remington_870"] = 9,
	["weapon_pwb_saiga_12"] = 6,
	["weapon_pwb_spas_12"] = 6,
	["weapon_pwb_protecta"] = 8,
	["qwb_m3super"] = 2,
}
cir = {
	["weapon_pwb_m590a1"] = 0.02,
	["weapon_pwb_mp5"] = 0.1,
	["weapon_pwb_akm"] = 0.1,
	["weapon_pwb_cz75"] = 0.1,
	["weapon_pwb_desert_eagle"] = 0.1,
	["weapon_pwb_rpk"] = 0.1,
	["weapon_pwb_aks74u"] = 0.1,
	["weapon_pwb_fnp45"] = 0.1,
	["weapon_pwb_hk416"] = 0.1,
	["weapon_pwb_l96a1"] = 0.1,
	["qwb_m3super"] = 0.1,
	["weapon_pwb_m134"] = 0.4,
}

Vectors = {
	["weapon_pwb_aks74u"] = Vector(14,-1,2),
	["qwb_glock18"] = cc(3,-1,1),
	["qwb_m3super"] = cc(12,-1,4),
	["qwb_usp"] = cc(5,0,4),
	["weapon_pwb2_vectorsmg"] = cc(0,0,0),
	["qwb_ump45"] = cc(12,-1,4),
	["weapon_pwb_akm"] =Vector(14,-1,2),
	["weapon_pwb_l85a1"]= Vector(12,-1,2),
	["weapon_pwb_cz75"] = Vector(14,0,4),
	["weapon_sib_usp"] = cc(1,-1,2),
	["weapon_pwb_desert_eagle"] = Vector(12,0,2),
	["weapon_pwb_fnp45"] = Vector(14,0,4),
	["weapon_pwb_glock17"] = Vector(14,0,4),
	["weapon_pwb_hk23e"] = Vector(3,-1,0),
	["weapon_pwb_mp5"] = cc(14,-1,2),
	["weapon_pwb_uzi"] = cc(14,0,4),
	["weapon_pwb_xm1014"] = cc(12,-1,4),
	["weapon_pwb_hk417"] = Vector(12,-1,4),
	["weapon_pwb_spas_12"] = cc(13,-1,2),
	["weapon_pwb_m9"]= cc(14,0,4),
	["weapon_pwb_hk416"] = Vector(12,-1,4),
	["weapon_pwb_rpk"] = cc(14,0,4),
	["weapon_pwb_l96a1"] = Vector(12,-1,4),
	["weapon_pwb_m134"] = Vector(3,-1,0),
	["weapon_pwb_remington_870"] = cc(12,-1,4),
	["weapon_pwb_m200"] = cc(12,-1,4),
	["weapon_pwb_m249"] = cc(12,-1,4),
	["weapon_pwb_saiga_12"] = cc(12,-1,4),
	["weapon_pwb_m320"] = cc(12,-1,4),
	["weapon_pwb_p99"] = cc(14,0,4),
	["weapon_pwb_tmp"] = cc(12,-1,4),
	["weapon_pwb_p90"] = cc(14,-1,2),
	["weapon_pwb_tar21"] = cc(12,-1,4),
	["weapon_pwb_mp7"] = cc(14,-1,2),
	["weapon_pwb_pkm"] = cc(14,-1,2),
	["weapon_pwb_protecta"] = cc(12,-1,4),
	["weapon_pwb_m590a1"] = cc(12,-1,4),
	["weapon_pwb_m98b"] = cc(12,-1,4),
	["weapon_sib_glock"] = cc(3,-1,1),
	["weapon_sib_m249"] = cc(12,-1,4),
	["weapon_sib_m14"] = cc(0,-2,2),
	["qwb_awp"] = cc(12,-1,4),
	["weapon_sib_beretta"] = cc(1,-1,2),
	["weapon_sib_deagle"] = cc(1,-2,1),
}

Vectors2 = {
	["weapon_pwb_saiga_12"] = cc(12,-2,-1),
	["qwb_m3super"] = cc(12,-2,-1),
	["weapon_pwb_m590a1"] = cc(12,-2,-1),
	["weapon_pwb_aks74u"] = cc(12,-3,-2),
	["weapon_pwb_xm1014"] = cc(12,-2,-1),
	["weapon_pwb_spas_12"] = cc(15,-4,-3),
	["weapon_pwb_p90"] = cc(3,-2,-4),
	["weapon_pwb_protecta"] = cc(12,-2,-1),
	["weapon_pwb_tmp"] = cc(7,-2,-4),
	["weapon_pwb_p99"] = cc(0,-3,-1),
	["qwb_glock18"] = cc(4,-3,-1),
	["qwb_ump45"] = cc(12,-2,-4),
	["weapon_pwb_akm"] = cc(12,-3,-2),
	["weapon_pwb_mp7"] = cc(12,-2,-4),
	["weapon_pwb2_vectorsmg"] = cc(0,0,0),
	["weapon_pwb_l85a1"]= cc(12,-2,-4),
	["weapon_pwb_m134"] = cc(12,-2,-2),
	["weapon_pwb_rpk"] = cc(12,-2,-2),
	["weapon_pwb_mp5"] = cc(12,-3,-2),
	["weapon_pwb_glock17"] = cc(4,-3,-1),
	["weapon_pwb_tar21"] = cc(7,-2,-4),
	["weapon_pwb_l96a1"] = cc(12,-2,-4),
	["weapon_pwb_pkm"] = cc(12,-2,-2),
	["weapon_pwb_hk23e"] = cc(12,-2,-2),
	["weapon_pwb_m249"] = cc(12,-2,-4),
	["weapon_pwb_hk416"] = cc(12,-2,-4),
	["weapon_pwb_m9"] = cc(0,-3,0),
	["weapon_pwb_hk417"] = cc(12,-2,-4),
	["weapon_pwb_m200"] = cc(12,-2,-4),
	["weapon_pwb_m98b"] = cc(12,-2,-4),
	["weapon_pwb_m320"] = cc(12,-2,-4),
	["weapon_pwb_remington_870"] = cc(12,-2,-1),
	["weapon_sib_glock"] = cc(0,-1,0),
	["weapon_sib_m249"] = cc(14,0,0),
	["weapon_sib_m14"] = cc(16,-4,-1),
	["qwb_awp"] = cc(7,-2,-4),
	["qwb_usp"] = cc(0,-3,-1),
	["weapon_sib_deagle"] = cc(-2,-2,1),
	["weapon_sib_usp"] = cc(-2,-2,1) 
}
function checkwepinfo(weaponName)
    local weapon = (weaponName)
    if weapon and weapon.Damage then
        return weapon.Damage
    elseif weapon and weapon.Primary and weapon.Primary.Damage then
        return weapon.Primary.Damage
    end
end
function getsound(weaponClassName)
    if not weapons.Get(weaponClassName) then
        return nil
    end
    local weaponTable = weapons.Get(weaponClassName)
    if not weaponTable.Primary or not weaponTable.Primary.Sound then
        return nil
    end
    
    -- Return the weapon sound
    return weaponTable.Primary.Sound
end
vecZero = Vector(0,0,0)
vecZero = Vector(0,0,0)
if GetConVar('rads_shooting'):GetBool() then
function SpawnWeapon(ply,clip1)
	if !IsValid(ply.wep) and table.HasValue(Guns,ply.curweapon) then
		local rag = ply:GetNWEntity("player_ragdoll")
		if IsValid(rag) then
			ply.FakeShooting=true
			ply.wep=ents.Create("wep")
			ply.wep:SetModel(weapons.Get(ply.curweapon).WorldModel)
			-- ply.wep:SetModel()
			ply.wep:SetOwner(ply)
			local vec1=rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetPos()
			local vec2 = vecZero
			vec2:Set((Vectors[ply.curweapon] or Vector(0,0,0)))
			vec2:Rotate(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetAngles())
			ply.wep:SetPos(vec1+vec2)
			ply.wep:SetAngles(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetAngles()-Angle(0,0,180))
			ply.wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			ply.wep:Spawn()
			ply:SetNWEntity("wep",ply.wep)
			CheckAmmo(ply, ply.wep)
			if !IsValid(ply.WepCons) then
				local cons = constraint.Weld(ply.wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )),0,true)
				if IsValid(cons) then
					ply.WepCons=cons
				end
			end

			ply.wep.curweapon = ply.curweapon
			net.Start("ebal_chellele")
			net.WriteEntity(ply)
			net.WriteString(ply.curweapon)
			net.Broadcast()
			rag.wep = ply.wep
			rag.wep:CallOnRemove("inv",remove,rag)
			ply.wep.rag = rag
			ply.wep.Clip = ply.Info.Weapons[ply.curweapon].Clip1
			ply.wep.AmmoType = ply.Info.Weapons[ply.curweapon].AmmoType

			ply:SetNWString("curweapon",ply.wep.curweapon)
			if (TwoHandedOrNo[ply.curweapon]) then
				ply.wep:GetPhysicsObject():SetMass(1)
				local vec1=rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetPos()
				local vec22 = vecZero
				vec22:Set(Vectors2[ply.curweapon])
				vec22:Rotate(rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" ))):GetAngles())
				rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) ):SetPos(vec1+vec22)
				local modelhuy = ply:GetModel() == "models/knyaje pack/dibil/sso_politepeople.mdl"
				rag:GetPhysicsObjectNum( rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )) ):SetAngles(ply:GetNWEntity("player_ragdoll"):GetPhysicsObjectNum( 7 ):GetAngles()-Angle(0,0,modelhuy and 90 or 180))
				if !IsValid(ply.WepCons2) then
					local cons2 = constraint.Weld(ply.wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )),0,true)			--2hand constraint
					if IsValid(cons2) then
						ply.WepCons2=cons2
					end
				end
			end
		end
	end
end

function DespawnWeapon(ply)
	if not ply.Info then return end

	if not ply.Info.Weapons[ply.Info.ActiveWeapon] then return end
	ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 = ply.wep.Clip
	ply.Info.ActiveWeapon2=ply.curweapon

		if IsValid(ply.wep) and ply:Alive() then
			ply.wep:Remove()
			ply.wep=nil
		elseif IsValid(ply.wep) and !ply:Alive() then
            ply.wep.canpickup=true
            ply.wep:SetOwner(nil)
            ply.wep.curweapon=ply.curweapon
            ply.wep=nil
        end

		if IsValid(ply.WepCons) and ply:Alive() then
			ply.WepCons:Remove()
			ply.WepCons=nil
		elseif IsValid(ply.WepCons) then
			ply.WepCons=nil
		end

		if IsValid(ply.WepCons2) and ply:Alive() then
			ply.WepCons2:Remove()
			ply.WepCons2=nil
		elseif IsValid(ply.WepCons2) then
			ply.WepCons2=nil
		end
		ply.FakeShooting=false
end
function CheckAmmo(ply, wep)
	if ply:Alive() then
		wep.Clip = ply.Info.Weapons[ply.Info.ActiveWeapon].Clip1 or 0
		wep.MaxClip = ply.Info.ActiveWeapon2:GetMaxClip1() or 0
		-- print(ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType()))
		wep.Amt=ply:GetAmmoCount(ply.Info.ActiveWeapon2:GetPrimaryAmmoType()) or 0
		wep.AmmoType=ply.Info.ActiveWeapon2:GetPrimaryAmmoType() or 0
	else
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) then return end

		wep.Clip = wep:Clip1()
		wep.AmmoType=wep:GetPrimaryAmmoType()
		-- print(wep.Clip, wep.AmmoType)
	end
end

function SpawnWeaponEnt(weapon, pos, ply)
    local wep = ents.Create("wep")
    wep:SetModel(GunsModel[weapon])
    wep:SetPos(pos)
    wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    wep:Spawn()
    wep:SetAngles(ply:EyeAngles() or Angle(0,0,0))
    wep:GetPhysicsObject():ApplyForceOffset(VectorRand(-2,2),wep:GetPos())
    wep.curweapon = ply.curweapon
    wep.Clip = ply.Clip
    wep.AmmoType = ply.AmmoType
    wep.canpickup=true
    return wep
end

function Reload(wep)
	if not wep then return end
	local weptable = weapons.Get(wep.curweapon)
	if !IsValid(wep) then return nil end
	if ShootWait[wep.curweapon]==nil then return nil end
	local ply = wep:GetOwner()
	if !timer.Exists("reload"..wep:EntIndex()) and wep.Clip!=wep.MaxClip and wep.Amt>0 then
		wep:EmitSound( "weapons/smg1/smg1_reload.wav", 75, 100, 1 )
		timer.Create("reload"..wep:EntIndex(), ReloadTime[wep.curweapon], 1, function()
			if IsValid(wep) then
				local oldclip = wep.Clip
				wep.Clip = math.Clamp(wep.Clip+wep.Amt,0,wep.MaxClip)
				local needed = wep.Clip-oldclip
				wep.Amt=wep.Amt-needed
				ply.Info.Ammo[wep.AmmoType]=wep.Amt
			end
		end)
	end
end

NextShot=0


HMCD_SurfaceHardness={
    [MAT_METAL]=.95,[MAT_COMPUTER]=.95,[MAT_VENT]=.95,[MAT_GRATE]=.95,[MAT_FLESH]=.5,[MAT_ALIENFLESH]=.3,
    [MAT_SAND]=.1,[MAT_DIRT]=.3,[74]=.1,[85]=.2,[MAT_WOOD]=.5,[MAT_FOLIAGE]=.5,
    [MAT_CONCRETE]=.9,[MAT_TILE]=.8,[MAT_SLOSH]=.05,[MAT_PLASTIC]=.3,[MAT_GLASS]=.6
}


local pos = Vector(0,0,0)

function FireShot(wep)
	if not IsValid(wep) then 
		print("Weapon is not valid!")
		return 
	end
	-- local shootWait = ShootWait[wep.curweapon]
    -- if shootWait ~= nil and shootWait > CurTime() then 
    --     return 
    -- end
	-- wep.NextShot = 0
	-- local shootWait = ShootWait[wep.curweapon] or 1
	-- wep.NextShot = CurTime() + shootWait
    -- if wep.NextShot > CurTime() then
    --     return
    -- end
	local weptable = weapons.Get(wep.curweapon)
	function wep:BulletCallbackFunc(dmgAmt,ply,tr,dmg,tracer,hard,multi)
		if(tr.MatType==MAT_FLESH)then
			util.Decal("Blood",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal)
			local vPoint = tr.HitPos
			local effectdata = EffectData()
			effectdata:SetOrigin( vPoint )
			util.Effect( "BloodImpact", effectdata )
		end
		if(self.NumBullet or 1>1)then return end
		if(tr.HitSky)then return end
		if(hard)then self:RicochetOrPenetrate(tr) end
	end
	function wep:RicochetOrPenetrate(initialTrace)
		local AVec,IPos,TNorm,SMul=initialTrace.Normal,initialTrace.HitPos,initialTrace.HitNormal,HMCD_SurfaceHardness[initialTrace.MatType]
		if not(SMul)then SMul=.5 end
		local ApproachAngle=-math.deg(math.asin(TNorm:DotProduct(AVec)))
		local MaxRicAngle=80*SMul
		if(ApproachAngle>(MaxRicAngle*1.25))then 
			local MaxDist,SearchPos,SearchDist,Penetrated=(math.random(5,40)/SMul)*.15,IPos,5,false
			while((not(Penetrated))and(SearchDist<MaxDist))do
				SearchPos=IPos+AVec*SearchDist
				local PeneTrace=util.QuickTrace(SearchPos,-AVec*SearchDist)
				if((not(PeneTrace.StartSolid))and(PeneTrace.Hit))then
					Penetrated=true
				else
					SearchDist=SearchDist+5
				end
			end
			if(Penetrated)then
				self:FireBullets({
					Attacker=self:GetOwner(),
					Damage=1,
					Force=1,
					Num=1,
					Tracer=0,
					TracerName="",
					Dir=-AVec,
					Spread=Vector(0,0,0),
					Src=SearchPos+AVec
				})
				Damage = 0
				if checkwepinfo(wep.curweapon) ~= nil then
					Damage=checkwepinfo(wep.curweapon)
					else
					Damage=math.random(25,50)
					end
				self:FireBullets({
					Attacker=self:GetOwner(),
					Damage ,
					Force=math.random(20,60) / 40 *.65,
					Num=1,
					Tracer=0,
					TracerName="",
					Dir=AVec,
					Spread=Vector(0,0,0),
					Src=SearchPos+AVec
				})
			end
		elseif(ApproachAngle<(MaxRicAngle*.75))then -- ping whiiiizzzz
			sound.Play("snd_jack_hmcd_ricochet_"..math.random(1,2)..".wav",IPos,70,math.random(90,100))
			local NewVec=AVec:Angle()
			NewVec:RotateAroundAxis(TNorm,180)
			NewVec=NewVec:Forward()
			self:FireBullets({
				Attacker=self:GetOwner(),
				Damage=checkwepinfo(wep.curweapon),
				Force=math.random(5,20)/60,
				Num=1,
				Tracer=0,
				TracerName="",
				Dir=-NewVec,
				Spread=Vector(0,0,0),
				Src=IPos+TNorm
			})
		end
	end
	if wep.Clip<=0  then
		sound.Play("snd_jack_hmcd_click.wav",wep:GetPos(),65,100)
		wep.NextShot = CurTime() + ShootWait[wep.curweapon] 
	return nil end
	if timer.Exists("reload"..wep:EntIndex()) then 
		return nil 
	end
	-- wep:EmitSound( "weapons/smg1/smg1_reload.wav", 75, 100, 1 )
	local guninfo = wep.GunInfo
	
	wep.NextShot=wep.NextShot or NextShot
	shootWait = ShootWait[wep.curweapon]
	-- wep.NextShot = CurTime() + ShootWait[wep.curweapon]
	if ( wep.NextShot > CurTime() ) then return end

	wep.NextShot = CurTime() + (shootWait or 1)
	local Attachment = wep:GetAttachment(wep:LookupAttachment("muzzle"))

	local shootOrigin = Attachment and Attachment.Pos or wep:GetPos() + wep:GetAngles():Forward() * 10
	local shootAngles = Attachment and Attachment.Ang or wep:GetAngles()
	local shootDir = shootAngles:Forward()
	local damage = math.random(5,45)
	if bullets[wep.curweapon] then
    damage = damage * bullets[wep.curweapon]
	end
	local ply = wep:GetOwner()
	local bullet = {}
		bullet.Num 			= (weptable.NumBullet or 1)
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= Vector(weptable.Primary.Cone or 0,weptable.Primary.Cone or 0,0)
		bullet.Tracer		= 1
		bullet.TracerName 	= 4
		bullet.Force		= math.random(5,15)
		bullet.Damage		= damage
		bullet.Attacker 	= ply
		bullet.Callback=function(ply,tr)
			wep:BulletCallbackFunc(damage,ply,tr,damage,false,true,false)
		end

	wep:FireBullets( bullet )
	wep:EmitSound( getsound(wep.curweapon), 75, 100, 1, CHAN_WEAPON)
		local ply = wep:GetOwner()
		local rag = ply:GetNWEntity("player_ragdoll") 
		local deathrag = ply:GetNWEntity('deadbody')
		if IsValid(deathrag) then return end
		if IsValid(rag) then
		rag:GetPhysicsObjectNum(0):ApplyForceCenter(ply:EyeAngles():Forward()*-damage*0.75)
		end
		wep:GetPhysicsObject():ApplyForceCenter(wep:GetAngles():Forward()*-damage*0.05+wep:GetAngles():Right()*VectorRand(-90,90)+wep:GetAngles():Up()*100)
	wep.Clip=wep.Clip-1
	-- Make a muzzle flash
	local effectdata = EffectData()
	effectdata:SetOrigin( shootOrigin )
	effectdata:SetAngles( shootAngles )
	effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )

end
end
-- if CLIENT then
-- 	CreateClientConVar('rads_ragshootingcrosshair',1, true,true,'Adds laser beam from weapon in ragdoll',0,1)
-- 	hook.Add("PostDrawOpaqueRenderables", "DrawWeaponTrace", function()
-- 		local ply = LocalPlayer()
-- 		local wep = ply:GetNWEntity('wep')
-- 		local rag = ply:GetNWBool('radsfa')
-- 		local activewepsh = ply:GetInfoNum('rads_ragshootingcrosshair',0)
-- 		if IsValid(wep) and activewepsh and rag then
-- 			local Attachment = wep:GetAttachment(wep:LookupAttachment("muzzle"))
-- 			if Attachment then
-- 				local shootOrigin = Attachment.Pos
-- 				local shootAngles = Attachment.Ang
-- 				local shootDir = shootAngles:Forward()
	
-- 				local traceData = {}
-- 				traceData.start = shootOrigin
-- 				traceData.endpos = shootOrigin + shootDir * 10000 
-- 				traceData.filter = {ply, wep}
-- 				local traceResult = util.TraceLine(traceData)
	
-- 				render.DrawLine(shootOrigin, traceResult.HitPos, Color(255, 0, 0), false)
-- 			end
-- 		end
-- 	end)
	
-- end