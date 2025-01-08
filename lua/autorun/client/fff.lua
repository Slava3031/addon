local exit = "materials/exit.png"
local takayhuinay = "materials/rifle.png"
local zabratvse = "materials/truck.png"
local ply = LocalPlayer()
local colors = {
    realwhite = Color(255, 255, 255),
    white = Color(0, 0, 0, 119),
    hz = Color(18, 18, 18, 210),
    black = Color(151, 151, 151, 124),
    xyi = Color(21, 21, 21, 255)
}

local scrw, scrh = ScrW(), ScrH()
local isMenuOpen = false
local sizeoftekst = ScreenScale(6)
surface.CreateFont('Arialc', {
    font = 'Arial',
    size = 25,
    weight = 500,
    antialias = true,
    additive = false,
    extended = true,
})

surface.CreateFont("BoldPidoras", {
    font = "Ubuntu",
    size = sizeoftekst,
    weight = sizeoftekst,
    extended = true
})

hook.Add("HUDPaint", "ManipulateRagdollHUDPaint", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    local ragdoll = ply:GetNWEntity('player_ragdoll')
    if IsValid(ragdoll) then
        local headBoneIndex = ragdoll:LookupBone("ValveBiped.Bip01_Head1")
        if headBoneIndex then
            if ply:GetNWBool("radsfa") and not GetConVar('rads_thirdperson'):GetBool() then
                ragdoll:ManipulateBoneScale(headBoneIndex, Vector(0, 0, 0))
            else
                ragdoll:ManipulateBoneScale(headBoneIndex, Vector(1, 1, 1))
            end
        end
    end
end)

if GetConVar('rads_debug'):GetBool() then -- local function hhh() --     local fr = vgui.Create("DFrame") --     fr:SetSize(scrw / 2.4, scrh / 2.37) --     fr:Center() --     fr:MakePopup() --     fr:ShowCloseButton(false) --     fr:SetTitle("") --     fr.Paint = function(self, w, h) --         draw.RoundedBox(0, 0, 0, w, h, colors.hz) --     end --     local closebutton = vgui.Create("DImageButton", fr) --     closebutton:SetSize(32, 32) --     closebutton:SetPos(fr:GetWide() * 0.958, 5) --     closebutton:SetImage(exit) --     closebutton.DoClick = function() --         fr:Close() --         isMenuOpen = false --     end --     local grid = vgui.Create("DGrid", fr) --     grid:SetPos(25, 50) --     grid:SetCols(5) --     grid:SetColWide(fr:GetWide() * 0.2) --     local rowHeight = (150) --     grid:SetRowHeight(rowHeight) --     for weapon, clipData in pairs(playerWeapons) do --         local panel = vgui.Create("DPanel") --         panel:SetSize(120, 140) --         panel.Paint = function(self, w, h) --             draw.RoundedBox(0, 0, 0, w, h, colors.white) --         end --         local button = vgui.Create("DButton", panel) --         button:SetText(weapon) --         button:SetSize(panel:GetWide(), 25) --         button:Dock(BOTTOM) --         button:SetTextColor(colors.realwhite) --         button:SetFont("BoldPidoras") --         button.Paint = function(self, w, h) --             draw.RoundedBox(6, 0, 0, w, h, colors.xyi) --         end --         local image = vgui.Create("DImage", panel) --         image:SetImage(takayhuinay) --         image:SetSize(100, 100) --         image:SetPos(10, 10) --         image:SetContentAlignment(5) --         button.DoClick = function() --             net.Start("WeaponClicked") --             net.WriteString(weapon)  -- Отправляем имя нажатого оружия --             net.SendToServer() --             -- Удаляем оружие из таблицы playerWeapons --             playerWeapons[weapon] = nil --             -- Перерисовываем меню, чтобы оружие исчезло из списка --             grid:RemoveItem(panel) --             panel:Remove() --             grid:InvalidateLayout(true) --             sendPlayerWeaponsToServer() --         end --         grid:AddItem(panel) --     end --     local dimagebutton = vgui.Create("DImageButton", fr) --     dimagebutton:SetSize(32, 32) --     dimagebutton:SetPos(fr:GetWide() * 0.9, 5) --     dimagebutton:SetImage(zabratvse) --     dimagebutton:SetTooltip("Take All") --     dimagebutton.DoClick = function() --         for weapon, _ in pairs(playerWeapons) do --             net.Start("RetrieveWeaponFromRagdoll") --             net.WriteString(weapon) --             net.SendToServer() --         end --         fr:Close() --         isMenuOpen = false --         sendPlayerWeaponsToServer() --     end -- end
    hook.Add("HUDPaint", "PrintWeaponsAndEntity", function()
        local ply = LocalPlayer()
        if IsValid(ply) and ply:Alive() then
            local weapons = ply:GetWeapons()
            local yOffset = 10
            for _, weapon in pairs(weapons) do
                if IsValid(weapon) then
                    local weaponName = weapon:GetClass()
                    draw.SimpleText("Weapon: " .. weaponName, "DermaDefault", 10, yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    yOffset = yOffset + 20
                end
            end

            local trace = util.TraceLine({
                start = ply:EyePos(),
                endpos = ply:EyePos() + ply:GetAimVector() * 1000,
                filter = ply
            })

            if IsValid(trace.Entity) then
                local entityName = trace.Entity:GetClass()
                draw.SimpleText("Looking at: " .. entityName, "DermaDefault", 10, yOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end
        end
    end)
end