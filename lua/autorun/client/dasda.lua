surface.CreateFont("RADIALFONT", {
    font = "Arial",
    extended = true,
    size = 20,
    weight = 500,
    outline = true,
})

local lastButtonUsage = {}
local centerX, centerY = ScrW() / 2, ScrH() / 2
local outerRadius = 200
local innerRadius = 50
local numButtons = 2
local buttonSize = 50
local buttonColor = Color(255, 255, 255, 255)
local hoverColor = Color(255, 0, 0, 255)
local backgroundColor = Color(0, 0, 0, 200)
local cursorVisible = false
local cooldownTime = 0.5
local heart = Material("icon16/heart_add.png")
local ic1 = Material("vgui/hud/gmod_hand")
local buttons = {
    {
        material = heart,
        text = "Проверить пульс",
        action = function()
            CheckPulseAndLink()
            lastButtonUsage[1] = CurTime()
        end
    },
    {
        material = ic1,
        text = "///",
        action = function()
            lastButtonUsage[2] = CurTime() -- CheckBlood()
        end
    }
}

local function CanUseButton(index)
    return not lastButtonUsage[index] or CurTime() - lastButtonUsage[index] >= cooldownTime
end

local function DrawCircularMenu()
    if radialmenu then
        cursorVisible = true
        local outerCircle = {}
        for i = 1, 360 do
            local angle = math.rad(i)
            local x = centerX + outerRadius * math.cos(angle)
            local y = centerY + outerRadius * math.sin(angle)
            table.insert(outerCircle, {
                x = x,
                y = y
            })
        end

        surface.SetDrawColor(0, 0, 0, 100)
        draw.NoTexture()
        surface.DrawPoly(outerCircle)
        local innerCircle = {}
        for i = 1, 360 do
            local angle = math.rad(i)
            local x = centerX + innerRadius * math.cos(angle)
            local y = centerY + innerRadius * math.sin(angle)
            table.insert(innerCircle, {
                x = x,
                y = y
            })
        end

        surface.SetDrawColor(0, 0, 0, 15)
        draw.NoTexture()
        surface.DrawPoly(innerCircle)
        surface.SetDrawColor(backgroundColor)
        surface.DrawRect(0, 0, ScrW(), ScrH())
        local mouseX, mouseY = gui.MousePos()
        for i, button in ipairs(buttons) do
            local angle = math.rad((i - 1) * (360 / #buttons))
            local buttonX = centerX + math.cos(angle) * outerRadius
            local buttonY = centerY + math.sin(angle) * outerRadius
            if mouseX >= buttonX - buttonSize / 2 and mouseX <= buttonX + buttonSize / 2 and mouseY >= buttonY - buttonSize / 2 and mouseY <= buttonY + buttonSize / 2 then
                surface.SetDrawColor(hoverColor)
            else
                surface.SetDrawColor(buttonColor)
            end

            surface.SetMaterial(button.material)
            surface.DrawTexturedRect(buttonX - buttonSize / 2, buttonY - buttonSize / 2, buttonSize, buttonSize)
            draw.SimpleText(button.text, "DefaultFixedDropShadow", buttonX, buttonY + buttonSize / 2 + 5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            if input.IsMouseDown(MOUSE_LEFT) then if mouseX >= buttonX - buttonSize / 2 and mouseX <= buttonX + buttonSize / 2 and mouseY >= buttonY - buttonSize / 2 and mouseY <= buttonY + buttonSize / 2 then if CanUseButton(i) then button.action() end end end
        end

        surface.SetDrawColor(0, 0, 0, 15)
        surface.DrawRect(centerX - buttonSize / 2, centerY - buttonSize / 2, buttonSize, buttonSize)
    end
end

net.Receive("rads.bloodcheck", function()
    local b = net.ReadInt(14)
    if b < 0 then b = b + 16384 end
    chat.AddText(Color(255, 255, 255), tostring(b))
end)

function CheckBlood() -- function CheckBlood() --     local tr = util.TraceLine({ --         start = LocalPlayer():GetShootPos(), --         endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 200, --         filter = function(ent) --             if ent:IsValid() and ent:IsRagdoll() then --                 local owner = ent:GetNWEntity('owner') --                 if IsValid(owner) and owner:IsPlayer() then --                     chat.AddText(Color(255,255,255),"Примерная кровь: "..ent.Blood + math.random(400,150)) --                 end --                 return true --             end --             return false --         end --     }) -- end
    local tr = util.TraceLine({
        start = LocalPlayer():GetShootPos(),
        endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 200,
        filter = function(ent)
            if ent:IsValid() and ent:IsRagdoll() then
                local owner = ent:GetNWEntity('owner')
                if IsValid(owner) and owner:IsPlayer() then
                    net.Start("rads.bloodcheck")
                    net.WriteEntity(ent)
                    net.SendToServer()
                end
                return true
            end
            return false
        end
    })
end

function CheckPulseAndLink()
    local tr = util.TraceLine({
        start = LocalPlayer():GetShootPos(),
        endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 200,
        filter = function(ent)
            if ent:IsValid() and ent:IsRagdoll() then
                local owner = ent:GetNWEntity('owner')
                if IsValid(owner) and owner:IsPlayer() then
                    net.Start("CheckPulseAndLink")
                    net.WriteEntity(ent)
                    net.SendToServer()
                else
                    chat.AddText(Color(255, 255, 255), "У него нет пульса.")
                end
                return true
            end
            return false
        end
    })
end

function LOOT()
    local tr = util.TraceLine({
        start = LocalPlayer():GetShootPos(),
        endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 200,
        filter = function(ent)
            if ent:IsValid() and ent:IsRagdoll() then
                local owner = ent:GetNWEntity('owner')
                if IsValid(owner) and owner:IsPlayer() then
                    net.Start("RequestRagdollInfo")
                    net.WriteEntity(ent)
                    net.SendToServer()
                else
                    chat.AddText(Color(255, 255, 255), "Невозможно залутать пустоту. ")
                end
                return true
            end
            return false
        end
    })
end

function IsPlayerLookingAtRagdoll()
    local tr = util.TraceLine({
        start = LocalPlayer():GetShootPos(),
        endpos = LocalPlayer():GetShootPos() + LocalPlayer():GetAimVector() * 200,
        filter = function(ent)
            if ent:IsValid() and ent:IsRagdoll() then
                net.Start("RequestRagdollInfo")
                net.WriteEntity(ent)
                net.SendToServer()
                return true
            end
            return false
        end
    })
    return tr and tr.Hit and tr.Entity:IsValid() and tr.Entity:IsRagdoll()
end

hook.Add("KeyPress", "CheckRagdollUse", function(ply, key)
    if key == IN_USE and not ply:GetNWBool('radsfa') and ply:GetVelocity():LengthSqr() <= 1 then
        local tr = util.TraceLine({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:GetAimVector() * 200,
            filter = function(ent) return ent:IsValid() and ent:IsRagdoll() end
        })

        if IsValid(tr.Entity) then
            local distance = ply:GetPos():Distance(tr.Entity:GetPos())
            if tr.Hit and tr.Entity:IsValid() and tr.Entity:IsRagdoll() and distance <= 75 then
                radialmenu = true
                gui.EnableScreenClicker(true)
            end
        end
    end
end)

hook.Add("KeyRelease", "CloseRadialMenu", function(ply, key)
    if key == IN_USE then
        gui.EnableScreenClicker(false)
        radialmenu = false
    end
end)

hook.Add("HUDPaint", "DrawCircularMenu", DrawCircularMenu)
local function IsCursorInButton(x, y, mouseX, mouseY)
    return mouseX >= x - buttonSize / 2 and mouseX <= x + buttonSize / 2 and mouseY >= y - buttonSize / 2 and mouseY <= y + buttonSize / 2
end