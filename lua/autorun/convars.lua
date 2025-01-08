if SERVER then
    CreateConVar("rads_fallchance", "1", {FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable the custom fall chance system")
    CreateConVar("rads_propknock", "1", {FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable the prop knock system")
    CreateConVar("rads_timer", "1", {FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable the radstimer")
    CreateConVar("rads_ragonfall", "1", {FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable ragdoll on fall")
    CreateConVar("rads_doorbreach", "1", {FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable door breaching in ragdoll!")
    CreateConVar("rads_loadoutusinglua", "1", {FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable loadout weapon method")
    CreateConVar("rads_fallonspeedlimit", "1", {FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable ragdoll on high speed(900 units)")
    CreateConVar("rads_status", "1", {FCVAR_SERVER_CAN_EXECUTE}, "Enable/disable script")
    CreateConVar("rads_drawpain", "0", {FCVAR_SERVER_CAN_EXECUTE}, "")
    CreateConVar("rads_fallwhengrabbed", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Enable/disable fall when grabbed by ragdoll")
    CreateConVar("rads_firefall", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_painsounds", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_realisticdmg", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Enable/disable realistic falldmg")
    CreateConVar("rads_adjusttimer", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_bones", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_scalefalldmg", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_vehicleragspeed", "15", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar('rads_righthandlimit', '0',{FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE},"Force limit to right hand grip")
    CreateConVar('rads_spectatorfix', '0',{FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE},"Fix spectators for murder and another gms")
    CreateConVar('rads_bloodlimit', '1000',{FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE},"")
    CreateConVar('rads_supersus', '0',{FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE},"")
    CreateConVar('rads_lefthandlimit', '0',{FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE},"Force limit to right hand grip")
    CreateConVar("rads_shooting", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Enable/disable shooting in ragdoll")
    CreateConVar("rads_pullupspeed", "30", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Speed in pullups")
    CreateConVar("rads_shtfallchan", "0.05", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_shtfall", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_painstatus", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_enablekill", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_physdmg", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Phys dmg from fall")
    CreateConVar("rads_mineptime", "10", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Epilepsy mintime")
    CreateConVar("rads_maxeptime", "25", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Epilepsy maxtime")
    CreateConVar("rads_handspeed", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Hands speed")
    CreateConVar("rads_fallonclub", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Fall on club dmg")
    CreateConVar("rads_painlimit", "190", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_randomfallfromclub", "1", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "Fall on club dmg")
    CreateConVar("rads_spinehealth", "2", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_hearthealth", "5", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_lungshealth", "10", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_brainhealth", "5", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_intestineshealth", "15", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_stomachhealth", "5", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
    CreateConVar("rads_liverhealth", "5", {FCVAR_SERVER_CAN_EXECUTE,FCVAR_ARCHIVE}, "")
end
if CLIENT then
    hook.Add("PopulateToolMenu", "RADS.LOLMENU", function()
        spawnmenu.AddToolMenuOption("RADS", "Options", "Rads", "Client Settings", "", "", function(panel)
            
            panel:ClearControls()

            panel:AddControl("CheckBox", {
                Label = "#convar.help.thirdperson",
                Command = "rads_thirdperson"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.disable_lerp",
                Command = "rads_disablelerp"
            })
            panel:AddControl("CheckBox", {
                Label = "[debug]",
                Command = "rads_draworg"
            })
            panel:NumSlider( "#convar.help.view_mode" , "rads_viewmode",0,1,0 )
            panel:NumSlider( "#convar.help.view_fov", "rads_viewfov", 80, 150,0 )
        end)
        spawnmenu.AddToolMenuOption("RADS", "Options", "RadsBodyAdmin", "Admin Body Settings", "", "", function(panel)
            panel:AddControl("CheckBox", {
                Label = "#convar.help.pain_status",
                Command = "rads_painstatus"
            })
            panel:NumSlider('#convar.help.blood_limit','rads_bloodlimit',1,5000,0)
            panel:NumSlider('#convar.help.max_epilepsy','rads_maxeptime',1,120,0)
            panel:NumSlider('#convar.help.min_epilepsy','rads_mineptime',1,120,0)
            panel:NumSlider('#convar.help.pain_limit','rads_painlimit',1,999,0)
            panel:NumSlider('#convar.help.heart_health','rads_hearthealth',1,50,0)
            panel:NumSlider('#convar.help.spine_health','rads_spinehealth',1,50,0)
            panel:NumSlider('#convar.help.intestines_health','rads_intestineshealth',1,50,0)
            panel:NumSlider('#convar.help.stomach_health','rads_stomachhealth',1,50,0)
            panel:NumSlider('#convar.help.brain_health','rads_brainhealth',1,50,0)
            panel:NumSlider('#convar.help.lungs_health','rads_lungshealth',1,50,0)
            panel:NumSlider('#convar.help.liver_health','rads_liverhealth',1,50,0)
        end)
        spawnmenu.AddToolMenuOption("RADS", "Options", "RadsAdmin", "Admin Settings", "", "", function(panel)

            panel:ClearControls()
    
            panel:AddControl("Header", {Text = "Admin Settings"})
            
            panel:AddControl("CheckBox", {
                Label = "#convar.help.script_status",
                Command = "rads_status"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.kill_status",
                Command = "rads_enablekill"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.pain_sounds",
                Command = "rads_painsounds"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.adjust_timer",
                Command = "rads_adjusttimer"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.fallfromshooting",
                Command = "rads_firefall"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.supersus",
                Command = "rads_supersus"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.fall_on_speed",
                Command = "rads_fallonspeedlimit"
            })        
            panel:AddControl("CheckBox", {
                Label = "#convar.help.door_breach",
                Command = "rads_doorbreach"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.bones_status",
                Command = "rads_bones"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.fall_on_falllol",
                Command = "rads_ragonfall"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.fall_when_grabbed",
                Command = "rads_fallwhengrabbed"
            })
            panel:AddControl("CheckBox", {
                Label = "#convar.help.shooting_status",
                Command = "rads_shooting"
            })
            panel:NumSlider( '#convar.help.rh_force' , 'rads_righthandlimit',0,20000,0 )
            panel:NumSlider( '#convar.help.lh_force' , 'rads_lefthandlimit',0,20000,0 )
            panel:NumSlider('#convar.help.pullup_speed','rads_pullupspeed',30,60,0)
            panel:NumSlider('#convar.help.scale_fall_dmg','rads_scalefalldmg',0.1,50,10)

        end)
    end)

    
end
