local FollowText = require "widgets/followtext"
local assets = {
    Asset("ATLAS", "images/dyc_white.xml"),
    Asset("IMAGE", "images/dyc_white.tex"),
    Asset("ATLAS", "images/dyc_shb_icon.xml"),
    Asset("IMAGE", "images/dyc_shb_icon.tex"),
    Asset("ATLAS", "images/dyc_button_close.xml"),
    Asset("IMAGE", "images/dyc_button_close.tex"),
    Asset("ATLAS", "images/dycghb_claw.xml"),
    Asset("IMAGE", "images/dycghb_claw.tex"),
    Asset("ATLAS", "images/dycghb_shadow.xml"),
    Asset("IMAGE", "images/dycghb_shadow.tex"),
    Asset("ATLAS", "images/dycghb_shadow_i.xml"),
    Asset("IMAGE", "images/dycghb_shadow_i.tex"),
    Asset("ATLAS", "images/dycghb_round.xml"),
    Asset("IMAGE", "images/dycghb_round.tex"),
    Asset("ATLAS", "images/dycghb_panel.xml"),
    Asset("IMAGE", "images/dycghb_panel.tex"),
    Asset("ATLAS", "images/dycghb_pixel.xml"),
    Asset("IMAGE", "images/dycghb_pixel.tex"),
    Asset("ATLAS", "images/dycghb_pixel_i.xml"),
    Asset("IMAGE", "images/dycghb_pixel_i.tex"),
    Asset("ATLAS", "images/dycghb_buckhorn.xml"),
    Asset("IMAGE", "images/dycghb_buckhorn.tex"),
    Asset("ATLAS", "images/dycghb_victorian.xml"),
    Asset("IMAGE", "images/dycghb_victorian.tex"),
    Asset("ATLAS", "images/dycghb_victorian_i.xml"),
    Asset("IMAGE", "images/dycghb_victorian_i.tex")
}
local prefabs = {}
local Color = SimpleHealthBar.Color
local TableRemoveValue = SimpleHealthBar.lib.TableRemoveValue
local TableContains = SimpleHealthBar.lib.TableContains
local function IsDST()
    return TheSim:GetGameID() == "DST"
end
local function IsClient()
    return IsDST() and not TheWorld.ismastersim
end
local function IsSteam()
    return PLATFORM == "WIN32_STEAM" or PLATFORM == "OSX_STEAM" or PLATFORM == "LINUX_STEAM"
end
local function DYCGetPlayer()
    if IsDST() then
        return ThePlayer
    else
        return GetPlayer()
    end
end
local function IsDistOK(other)
    local player = DYCGetPlayer()
    if player == other then
        return true
    end
    if not player or not player:IsValid() or not other:IsValid() then
        return false
    end
    local dis = player:GetPosition():Dist(other:GetPosition())
    return dis <= TUNING.DYC_HEALTHBAR_MAXDIST
end
local function GetDistanceToCamera(ent)
    if TheSim.GetCameraPos ~= nil then
        local cpos = Vector3(TheSim:GetCameraPos())
        return cpos:Dist(ent:GetPosition())
    else
        local pitch = TheCamera.pitch * DEGREES
        local heading = TheCamera.heading * DEGREES
        local cos_pitch = math.cos(pitch)
        local cos_heading = math.cos(heading)
        local sin_heading = math.sin(heading)
        local dx = -cos_pitch * cos_heading
        local dy = -math.sin(pitch)
        local dz = -cos_pitch * sin_heading
        local xoffs, zoffs = 0, 0
        if TheCamera.currentscreenxoffset ~= 0 then
            local hoffs = 2 * TheCamera.currentscreenxoffset / RESOLUTION_Y
            local magic_number = 1.03
            local screen_heights = math.tan(TheCamera.fov * .5 * DEGREES) * TheCamera.distance * magic_number
            xoffs = -hoffs * sin_heading * screen_heights
            zoffs = hoffs * cos_heading * screen_heights
        end
        local cpos =
            Vector3(
            TheCamera.currentpos.x - dx * TheCamera.distance + xoffs,
            TheCamera.currentpos.y - dy * TheCamera.distance,
            TheCamera.currentpos.z - dz * TheCamera.distance + zoffs
        )
        return cpos:Dist(ent:GetPosition())
    end
end
local str_ghb_1 = SimpleHealthBar.ds("kti!")
local str_ghb_2 = SimpleHealthBar.ds("~qk|wzqiv")
local str_ghb_3 = SimpleHealthBar.ds('xq"mt')
local str_ghb_4 = SimpleHealthBar.ds("j}kspwzv")
local str_ghb_5 = SimpleHealthBar.ds("{pilw!")
local GH_ATLAS = "images/dyc_white.xml"
local GH_TEXTURE = "dyc_white.tex"
local GH_OFFSET_Y = -45
local GH_HEIGHT_SCALE = 60
local DYC_HB_STYLES = {
    ["heart"] = {c1 = "♡", c2 = "♥"},
    ["circle"] = {c1 = "○", c2 = "●"},
    ["square"] = {c1 = "□", c2 = "■"},
    ["diamond"] = {c1 = "◇", c2 = "◆"},
    ["star"] = {c1 = "☆", c2 = "★"},
    ["square2"] = {c1 = "░", c2 = "▓"},
    ["basic"] = {c1 = "=", c2 = "#", numCoeff = 1.6},
    ["hidden"] = {c1 = " ", c2 = " "},
    ["chinese"] = {c1 = "口", c2 = "回"},
    ["standard"] = {c1 = " ", c2 = " ", graphic = {basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"}}},
    ["simple"] = {
        c1 = " ",
        c2 = " ",
        graphic = {
            bg = {atlas = "images/ui.xml", texture = "bg_plain.tex", color = Color.New(0.3, 0.3, 0.3)},
            bar = {atlas = "images/ui.xml", texture = "bg_plain.tex", margin = {x1 = 0, x2 = 0, y1 = 0, y2 = 0}},
            basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"}
        }
    },
    [str_ghb_1] = {
        c1 = " ",
        c2 = " ",
        graphic = {
            basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"},
            bgSkn = {
                mode = "slice13",
                atlas = "images/dycghb_" .. str_ghb_1 .. ".xml",
                texname = "dycghb_" .. str_ghb_1,
                texScale = 999,
                margin = {x1 = -0.75, x2 = -0.75, y1 = -0.225, y2 = -0.225, fixed = false}
            },
            barSkn = {
                mode = "slice33",
                atlas = "images/dycghb_round.xml",
                texname = "dycghb_round",
                texScale = 1,
                margin = {x1 = 0.015, x2 = 0.015, y1 = 0.06, y2 = 0.06, fixed = false}
            }
        }
    },
    [str_ghb_2] = {
        c1 = " ",
        c2 = " ",
        graphic = {
            basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"},
            bgSkn = {
                mode = "slice13",
                atlas = "images/dycghb_" .. str_ghb_2 .. ".xml",
                texname = "dycghb_" .. str_ghb_2,
                texScale = 999,
                margin = {x1 = -1.7, x2 = -1.7, y1 = -0.45, y2 = -0.55, fixed = false}
            },
            barSkn = {
                mode = "slice33",
                atlas = "images/dycghb_" .. str_ghb_2 .. "_i.xml",
                texname = "dycghb_" .. str_ghb_2 .. "_i",
                texScale = 0.25,
                margin = {x1 = 0.03, x2 = 0.03, y1 = 0.15, y2 = 0.15, fixed = false}
            }
        }
    },
    [str_ghb_4] = {
        c1 = " ",
        c2 = " ",
        graphic = {
            basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"},
            bgSkn = {
                mode = "slice13",
                atlas = "images/dycghb_" .. str_ghb_4 .. ".xml",
                texname = "dycghb_" .. str_ghb_4,
                texScale = 999,
                margin = {x1 = -1.2, x2 = -1.2, y1 = -0.43, y2 = -0.48, fixed = false}
            },
            bar = {
                atlas = "images/ui.xml",
                texture = "bg_plain.tex",
                margin = {x1 = 0, x2 = 0, y1 = 0, y2 = 0, fixed = false}
            }
        }
    },
    [str_ghb_3] = {
        c1 = " ",
        c2 = " ",
        graphic = {
            basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"},
            bgSkn = {
                mode = "slice13",
                atlas = "images/dycghb_" .. str_ghb_3 .. ".xml",
                texname = "dycghb_" .. str_ghb_3,
                texScale = 999,
                margin = {x1 = -1.1, x2 = -0.4, y1 = -0.365, y2 = -0.285, fixed = false}
            },
            barSkn = {
                mode = "slice13",
                atlas = "images/dycghb_" .. str_ghb_3 .. "_i.xml",
                texname = "dycghb_" .. str_ghb_3 .. "_i",
                texScale = 999,
                margin = {x1 = -1.1, x2 = -0.4, y1 = -0.365, y2 = -0.285, fixed = false},
                vmargin = {x1 = 0.675, x2 = -0.075, y1 = 0.1, y2 = 0.13, fixed = false}
            },
            hrUseBarColor = true
        }
    },
    [str_ghb_5] = {
        c1 = " ",
        c2 = " ",
        graphic = {
            basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"},
            bgSkn = {
                mode = "slice33",
                atlas = "images/dycghb_" .. str_ghb_5 .. ".xml",
                texname = "dycghb_" .. str_ghb_5,
                texScale = 0.5,
                margin = {x1 = -11, x2 = -11, y1 = -9, y2 = -11, fixed = true}
            },
            barSkn = {
                mode = "slice33",
                atlas = "images/dycghb_" .. str_ghb_5 .. "_i.xml",
                texname = "dycghb_" .. str_ghb_5 .. "_i",
                texScale = 0.3
            }
        }
    }
}
local DYC_ENT_SIZE_LIST = {
    {prefab = "mean_flytrap", width = 0.9, height = 2.3},
    {prefab = "thunderbird", width = 0.85, height = 2.05},
    {prefab = "glowfly", width = 0.6, height = 2},
    {prefab = "peagawk", width = 0.85, height = 2.1},
    {prefab = "krampus", width = 1, height = 3.75},
    {prefab = "nightmarebeak", width = 1, height = 4.5},
    {prefab = "terrorbeak", width = 1, height = 4.5},
    {prefab = "spiderqueen", width = 2, height = 4.5},
    {prefab = "warg", width = 1.7, height = 5},
    {prefab = "pumpkin_lantern", width = 0.7, height = 1.5},
    {prefab = "jellyfish_planted", width = 0.7, height = 1.5},
    {prefab = "babybeefalo", width = 1, height = 2.2},
    {prefab = "beeguard", width = 0.65, height = 2},
    {prefab = "shadow_rook", width = 1.8, height = 3.5},
    {prefab = "shadow_bishop", width = 0.9, height = 3.2},
    {prefab = "walrus", width = 1.1, height = 3.2},
    {prefab = "teenbird", width = 1.0, height = 3.6},
    {tag = "player", width = 1, height = 2.65},
    {tag = "ancient_hulk", width = 1.85, height = 4.5},
    {tag = "antqueen", width = 2.4, height = 8},
    {tag = "ro_bin", width = 0.9, height = 2.8},
    {tag = "gnat", width = 0.75, height = 3},
    {tag = "spear_trap", width = 0.75, height = 3},
    {tag = "hangingvine", width = 0.85, height = 4},
    {tag = "weevole", width = 0.6, height = 1.2},
    {tag = "flytrap", width = 1, height = 3.4},
    {tag = "vampirebat", width = 1, height = 3},
    {tag = "pangolden", width = 1.4, height = 3.8},
    {tag = "spider_monkey", width = 1.6, height = 4},
    {tag = "hippopotamoose", width = 1.35, height = 3.1},
    {tag = "piko", width = 0.5, height = 1},
    {tag = "pog", width = 0.85, height = 2},
    {tag = "ant", width = 0.8, height = 2.3},
    {tag = "scorpion", width = 0.85, height = 2},
    {tag = "dungbeetle", width = 0.8, height = 2.3},
    {tag = "civilized", width = 1, height = 3.2},
    {tag = "koalefant", width = 1.7, height = 4},
    {tag = "spat", width = 1.5, height = 3.5},
    {tag = "lavae", width = 0.8, height = 1.5},
    {tag = "glommer", width = 0.9, height = 2.9},
    {tag = "deer", width = 1, height = 3.1},
    {tag = "snake", width = 0.85, height = 1.7},
    {tag = "eyeturret", width = 1, height = 4.5},
    {tag = "primeape", width = 0.85, height = 1.5},
    {tag = "monkey", width = 0.85, height = 1.5},
    {tag = "ox", width = 1.5, height = 3.75},
    {tag = "beefalo", width = 1.5, height = 3.75},
    {tag = "kraken", width = 2, height = 5.5},
    {tag = "nightmarecreature", width = 1.25, height = 3.5},
    {tag = "bishop", width = 1, height = 4},
    {tag = "rook", width = 1.25, height = 4},
    {tag = "knight", width = 1, height = 3},
    {tag = "bat", width = 0.8, height = 3},
    {tag = "minotaur", width = 1.75, height = 4.5},
    {tag = "packim", width = 0.9, height = 3.75},
    {tag = "stungray", width = 0.9, height = 3.75},
    {tag = "ghost", width = 0.9, height = 3.75},
    {tag = "tallbird", width = 1.25, height = 5},
    {tag = "chester", width = 0.85, height = 1.5},
    {tag = "hutch", width = 0.85, height = 1.5},
    {tag = "wall", width = 0.5, height = 1.5},
    {tag = "largecreature", width = 2, height = 7.2},
    {tag = "insect", width = 0.5, height = 1.6},
    {tag = "smallcreature", width = 0.85, height = 1.5}
}
local function Clamp01(num)
    if num < 0 then
        num = 0
    elseif num > 1 then
        num = 1
    end
    return num
end
local function GetHBStyle(inst, stylestring)
    local player = DYCGetPlayer()
    local style =
        stylestring or (inst and player == inst and _G["TUNING"]["DYC_HEALTHBAR_STYLE_CHAR"]) or
        (inst and inst["dycshb_cstyle_net"] and inst["dycshb_cstyle_net"]:value()) or
        _G["TUNING"]["DYC_HEALTHBAR_STYLE"]
    if type(style) == "table" and style.c1 and style.c2 then
        return style
    end
    return DYC_HB_STYLES[style] or DYC_HB_STYLES["standard"]
end
SimpleHealthBar.GetHBStyle = GetHBStyle
local function GetHpText(hpCurrent, hpMax, ent)
    local player = DYCGetPlayer()
    local style = GetHBStyle(ent)
    local c1 = style.c1
    local c2 = style.c2
    local cnum = TUNING.DYC_HEALTHBAR_CNUM * (style.numCoeff or 1)
    local str = ""
    if TUNING.DYC_HEALTHBAR_POSITION == 0 then
        str = "  \n  \n  \n  \n"
    end
    local hpp = hpCurrent / hpMax
    for i = 1, cnum do
        if hpp == 0 or (i ~= 1 and i * 1.0 / cnum > hpp) then
            str = str .. c1
        else
            str = str .. c2
        end
    end
    return str
end
local function GetEntHBSize(ent)
    if not ent then
        return 1
    end
    for k, v in pairs(DYC_ENT_SIZE_LIST) do
        if v.width and (ent.prefab == v.prefab or (v.tag and ent:HasTag(v.tag))) then
            return v.width
        end
    end
    return 1
end
local function GetEntHBHeight(ent)
    if not ent then
        return 2.65
    end
    for k, v in pairs(DYC_ENT_SIZE_LIST) do
        if v.height and (ent.prefab == v.prefab or (v.tag and ent:HasTag(v.tag))) then
            return v.height
        end
    end
    return 2.65
end
local function GetEntHBColor(data)
    data = data or {}
    local ent = data.owner
    local info = data.info or TUNING.DYC_HEALTHBAR_COLOR
    local hpp = data.hpp
    local player = DYCGetPlayer()
    if type(info) == "table" and info.Get then
        return info:Get()
    elseif type(info) == "table" and info.r and info.g and info.b then
        return info.r, info.g, info.b, info.a or 1
    elseif type(info) == "string" and (info == "dynamic_dark" or info == "dark") and hpp then
        local r, g = Clamp01((1 - hpp) * 2), Clamp01(hpp * 2)
        return r * 0.7, g * 0.5, 0, 1
    elseif type(info) == "string" and (info == "dynamic_hostility" or info == "hostility" or info == "dynamic2") then
        if ent and ent == player then
            return 0.15, 0.55, 0.7, 1
        end
        if ent and ent.components.combat then
            local defaultdamage = ent.components.combat.defaultdamage
            if
                ent.components.combat.target == player and not ent:HasTag("chester") and defaultdamage and
                    type(defaultdamage) == "number" and
                    defaultdamage > 0
             then
                return 0.8, 0, 0, 1
            end
        end
        if ent and ent.replica and ent.replica.combat and ent.replica.combat.GetTarget then
            if ent.replica.combat:GetTarget() == player then
                return 0.8, 0, 0, 1
            end
        end
        if ent and ent.components.follower then
            if ent.components.follower.leader == player then
                return 0.1, 0.7, 0.2, 1
            end
        end
        if ent and ent.replica and ent.replica.follower and ent.replica.follower.GetLeader then
            if ent.replica.follower:GetLeader() == player then
                return 0.1, 0.7, 0.2, 1
            end
        end
        if ent and ent:HasTag("hostile") then
            return 0.8, 0.5, 0.1, 1
        end
        if ent and ent:HasTag("monster") then
            return 0.7, 0.7, 0.1, 1
        end
        if ent and (ent:HasTag("chester") or ent:HasTag("companion")) then
            return 0.1, 0.7, 0.2, 1
        end
        if ent and ent:HasTag("player") then
            return 117 / 255, 27 / 255, 198 / 255, 1
        end
        return 0.7, 0.7, 0.7, 1
    elseif type(info) == "string" and SimpleHealthBar.Color:GetColor(info) then
        return SimpleHealthBar.Color:GetColor(info)
    elseif hpp then
        local r, g = Clamp01((1 - hpp) * 2), Clamp01(hpp * 2)
        return r, g, 0, 1
    end
    return 1, 1, 1, 1
end
SimpleHealthBar.GetEntHBColor = GetEntHBColor
local function InitHB(inst)
    local owner = nil
    if not inst.dychbowner then
        inst.dychbowner = inst.entity:GetParent()
        if not inst.dychbowner then
            inst:Remove()
            return
        end
        inst.dychbowner.dychealthbar = inst
    end
    owner = inst.dychbowner
    if IsDST() or TUNING.DYC_HEALTHBAR_POSITION == 0 then
        inst.dychbtext = inst.dychbowner:SpawnChild("dyc_healthbarchild")
    else
        inst.dychbtext = inst:SpawnChild("dyc_healthbarchild")
    end
    inst:EnableText(false)
    inst.dychbtext:EnableText(false)
    inst.SetHBHeight = function(inst, height)
        if TUNING.DYC_HEALTHBAR_POSITION == 0 then
            height = 0
        end
        if IsDST() then
            inst:SetOffset(0, height, 0)
            inst.dychbtext:SetOffset(0, height, 0)
        else
            inst.dychbheight = height * 1.5
        end
    end
    inst.dychbheightconst = GetEntHBHeight(inst.dychbowner)
    inst:SetHBHeight(inst.dychbheightconst)
    inst.SetHBSize = function(inst, size)
        local hbsize = math.max(1, (13 - TUNING.DYC_HEALTHBAR_CNUM) / 5) * 15 * size
        inst:SetFontSize(hbsize)
        inst.dychbtext:SetFontSize(28 * size)
        local gh = inst.graphicHealthbar
        if gh then
            if not TUNING.DYC_HEALTHBAR_FIXEDTHICKNESS then
                local thickness = TUNING.DYC_HEALTHBAR_THICKNESS or 1
                gh:SetHBSize(120 * TUNING.DYC_HEALTHBAR_CNUM / 10, 18 * thickness)
                gh:SetHBScale(size)
            else
                local thickness = TUNING.DYC_HEALTHBAR_THICKNESS or 18
                gh:SetHBSize(120 * TUNING.DYC_HEALTHBAR_CNUM / 10 * size, thickness)
            end
        end
    end
    inst:SetHBSize(GetEntHBSize(inst.dychbowner))
    if inst.graphicHealthbar then
        local gh = inst.graphicHealthbar
        gh:SetTarget(owner)
        local graphicData = GetHBStyle(owner).graphic
        if graphicData then
            gh:SetData(graphicData)
            gh:SetOpacity(TUNING.DYC_HEALTHBAR_OPACITY or graphicData.opacity or 0.8)
            gh:SetHBScale()
        end
        if graphicData and not gh.shown then
            local hideWallHB = not TUNING.DYC_HEALTHBAR_WALLHB and gh.target and gh.target:HasTag("wall")
            if not hideWallHB then
                gh:Show()
            end
        end
        if TUNING.DYC_HEALTHBAR_ANIMATION then
            if owner:HasTag("largecreature") then
                gh:AnimateIn(2)
            else
                gh:AnimateIn(8)
            end
        end
    end
    inst.dycHbStarted = true
end
shb[SimpleHealthBar.ds("wv]xli|mPJ")] = function()
    for k, v in pairs(SimpleHealthBar.GHB.ghbs) do
        local graphicData = GetHBStyle(v.target).graphic
        local hideWallHB = TUNING.DYC_HEALTHBAR_WALLHB ~= true and v.target and v.target:HasTag("wall")
        if graphicData and not hideWallHB and not v.shown then
            v:Show()
        elseif (not graphicData or hideWallHB) and v.shown then
            v:Hide()
        end
        if graphicData then
            v:SetData(graphicData)
            v:SetOpacity(TUNING.DYC_HEALTHBAR_OPACITY or graphicData.opacity or 0.8)
            v:SetHBScale()
        end
    end
end
local function fn(isDD)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst:AddTag("FX")
    local useGraphicHB = not isDD
    local label = inst.entity:AddLabel()
    label:SetFont(NUMBERFONT)
    label:SetFontSize(28)
    label:SetColour(1, 1, 1)
    label:SetText(" ")
    label:Enable(true)
    inst.text = label
    inst.SetFontSize = function(inst, size)
        inst.text:SetFontSize(size)
    end
    inst.SetOffset = function(inst, x, y, z)
        inst.text:SetWorldOffset(x, y, z)
    end
    inst.SetText = function(inst, str)
        inst.text:SetText(str)
    end
    inst.EnableText = function(inst, b)
        inst.text:Enable(b)
    end
    local OldRemove = inst.Remove
    inst.persists = false
    inst.InitHB = InitHB
    return inst
end
local function AddGHB(inst)
    if not DYCGetPlayer() or not DYCGetPlayer().HUD then
        return
    end
    local graphicData = GetHBStyle().graphic
    local gh =
        DYCGetPlayer().HUD.overlayroot:AddChild(
        SimpleHealthBar.GHB(graphicData or {basic = {atlas = GH_ATLAS, texture = GH_TEXTURE}})
    )
    gh:MoveToBack()
    gh:Hide()
    gh:SetFontSize(32)
    gh:SetYOffSet(GH_OFFSET_Y, true)
    gh:SetTextColor(1, 1, 1, 1)
    gh:SetOpacity(TUNING.DYC_HEALTHBAR_OPACITY or graphicData.opacity or 0.8)
    gh:SetStyle("textoverbar")
    gh.preUpdateFn = function(dt)
        if GetHBStyle(gh.target).graphic and dt > 0 and gh.target and TUNING.DYC_HEALTHBAR_POSITION == 1 then
            local yScale = 30 / GetDistanceToCamera(gh.target)
            gh:SetYOffSet(inst.dychbheightconst * GH_HEIGHT_SCALE * yScale)
            gh:SetStyle("textoverbar")
            if gh.fontSize ~= 32 then
                gh:SetFontSize(32)
            end
        elseif GetHBStyle(gh.target).graphic and dt > 0 and gh.target and TUNING.DYC_HEALTHBAR_POSITION == 2 then
            local yScale = 30 / GetDistanceToCamera(gh.target)
            gh:SetYOffSet(inst.dychbheightconst * GH_HEIGHT_SCALE * yScale)
            gh:SetStyle("")
            if gh.fontSize ~= 24 then
                gh:SetFontSize(24)
            end
        elseif GetHBStyle(gh.target).graphic and dt > 0 and gh.target and TUNING.DYC_HEALTHBAR_POSITION == 0 then
            gh:SetYOffSet(GH_OFFSET_Y, true)
            gh:SetStyle("textoverbar")
            if gh.fontSize ~= 32 then
                gh:SetFontSize(32)
            end
        end
    end
    inst.graphicHealthbar = gh
end
local function AddHBToList(inst)
    table.insert(SimpleHealthBar.hbs, inst)
    if TUNING.DYC_HEALTHBAR_LIMIT > 0 and #SimpleHealthBar.hbs > TUNING.DYC_HEALTHBAR_LIMIT then
        local oldHB = SimpleHealthBar.hbs[1]
        table.remove(SimpleHealthBar.hbs, 1)
    end
end
local function dychbfn()
    local inst = fn()
    if IsDST() then
        inst.entity:AddNetwork()
    end
    inst:SetFontSize(15)
    if IsDST() then
        inst.dychpini = -1
        inst.dychp = 0
        inst.dychp_net = net_float(inst.GUID, "dyc_healthbar.hp", "dychpdirty")
        inst:ListenForEvent(
            "dychpdirty",
            function(inst)
                local hpnew = inst.dychp_net:value()
                if inst.dychpini == -1 then
                    inst.dychpini = hpnew
                    if not TUNING.DYC_HEALTHBAR_DDON then
                        inst.dychpini = -2
                    end
                end
                if TUNING.DYC_HEALTHBAR_DDON then
                    if inst.dychbowner and IsDistOK(inst.dychbowner) then
                        local dd = SpawnPrefab("dyc_damagedisplay")
                        if inst.dychpini > 0 then
                            dd:DamageDisplay(inst.dychbowner, {hpOld = inst.dychpini, hpNewDefault = hpnew})
                            inst.dychpini = -2
                        else
                            dd:DamageDisplay(inst.dychbowner, {hpNewDefault = hpnew})
                        end
                    end
                end
                inst.dychp = hpnew
            end
        )
        inst.dychpmax = 0
        inst.dychpmax_net = net_float(inst.GUID, "dyc_healthbar.hpmax", "dychpmaxdirty")
        inst:ListenForEvent(
            "dychpmaxdirty",
            function(inst)
                inst.dychpmax = inst.dychpmax_net:value()
            end
        )
    end
    local hpCurrent = -1
    local hpMax = -1
    local timer = 0
    local initHp = true
    local updateOnce = false
    inst.dycHbStarted = false
    inst.OnRemoveEntity = function(inst)
        if IsDST() and inst.dychbowner and TUNING.DYC_HEALTHBAR_DDON and IsDistOK(inst.dychbowner) then
            local dd = SpawnPrefab("dyc_damagedisplay")
            dd:DamageDisplay(inst.dychbowner, {hpNewDefault = inst.dychp})
        end
        inst.Label:SetText(" ")
        if inst.dychbowner then
            inst.dychbowner.dychealthbar = nil
        end
        if inst.dychbtext then
            inst.dychbtext:Remove()
        end
        if inst.dychbtask then
            inst.dychbtask:Cancel()
        end
        if inst.graphicHealthbar then
            if TUNING.DYC_HEALTHBAR_ANIMATION then
                inst.graphicHealthbar:AnimateOut(6)
            else
                inst.graphicHealthbar:Kill()
            end
        end
        TableRemoveValue(SimpleHealthBar.hbs, inst)
    end
    function inst:DYCHBSetTimer(t)
        timer = t
        updateOnce = true
    end
    AddGHB(inst)
    AddHBToList(inst)
    inst.dychbtask =
        inst:DoPeriodicTask(
        FRAMES,
        function()
            if not inst.dycHbStarted then
                return
            end
            local owner = inst.dychbowner
            if not owner then
                return
            end
            local attacker = inst.dychbattacker
            local health = nil
            if not IsClient() then
                health = owner.components.health
            else
                health = owner.replica.health
            end
            if
                not owner:IsValid() or owner.inlimbo or owner:HasTag("playerghost") or
                    (not IsDST() and not IsDistOK(owner)) or
                    (IsClient() and not owner:HasTag("player")) or
                    health == nil or
                    health:IsDead() or
                    timer >= TUNING.DYC_HEALTHBAR_DURATION
             then
                if not IsClient() then
                    inst:Remove()
                    return
                end
            end
            if owner.dychealthbar ~= inst then
                inst:Remove()
                return
            end
            if not owner:IsValid() then
                return
            end
            local hpCurrentNew = 0
            local hpMaxNew = 0
            if not IsDST() then
                hpCurrentNew = health.currenthealth
                hpMaxNew = health.maxhealth
            else
                hpCurrentNew = inst.dychp
                hpMaxNew = inst.dychpmax
            end
            if
                health ~= nil and
                    (TUNING.DYC_HEALTHBAR_FORCEUPDATE == true or hpCurrent ~= hpCurrentNew or hpMax ~= hpMaxNew or
                        updateOnce)
             then
                updateOnce = false
                hpCurrent = hpCurrentNew
                hpMax = hpMaxNew
                local hideWallHB = not TUNING.DYC_HEALTHBAR_WALLHB and owner and owner:HasTag("wall")
                if hideWallHB then
                    inst:EnableText(false)
                    inst.dychbtext:EnableText(false)
                else
                    inst:EnableText(true)
                    inst.dychbtext:EnableText(true)
                end
                inst:SetText(GetHpText(hpCurrent, hpMax, owner))
                if TUNING.DYC_HEALTHBAR_VALUE and not GetHBStyle(owner).graphic then
                    if TUNING.DYC_HEALTHBAR_POSITION ~= 0 then
                        inst.dychbtext:SetText(string.format(" %d/%d\n   ", hpCurrent, hpMax))
                    else
                        inst.dychbtext:SetText(string.format("  \n  \n %d/%d\n   ", hpCurrent, hpMax))
                    end
                else
                    inst.dychbtext:SetText("")
                end
                if inst.SetHBHeight and inst.dychbheightconst then
                    inst:SetHBHeight(inst.dychbheightconst)
                end
                local hpp = hpCurrent / hpMax
                inst.text:SetColour(GetEntHBColor({owner = owner, hpp = hpp}))
                if inst.graphicHealthbar then
                    local gh = inst.graphicHealthbar
                    local graphicData = GetHBStyle(owner).graphic
                    if graphicData then
                        gh.showValue = TUNING.DYC_HEALTHBAR_VALUE
                        gh:SetValue(hpCurrent, hpMax, initHp)
                        gh:SetBarColor(GetEntHBColor({owner = owner, hpp = hpp}))
                    end
                end
                initHp = false
            end
            local shouldFade = true
            local combat = nil
            if not IsClient() then
                combat = owner.components.combat
            else
                combat = owner.replica.combat
            end
            if combat and combat.target then
                shouldFade = false
            else
                if attacker and attacker:IsValid() then
                    local attackerHealth = nil
                    local attackerCombat = nil
                    if not IsClient() then
                        attackerHealth = attacker.components.health
                        attackerCombat = attacker.components.combat
                    else
                        attackerHealth = attacker.replica.health
                        attackerCombat = attacker.replica.combat
                    end
                    if
                        attackerHealth and not attackerHealth:IsDead() and attackerCombat and
                            attackerCombat.target == owner
                     then
                        shouldFade = false
                    end
                end
            end
            if shouldFade then
                timer = timer + FRAMES
            else
                timer = 0
            end
            if IsDST() or TUNING.DYC_HEALTHBAR_POSITION == 0 then
            else
                local pos = owner:GetPosition()
                pos.y = inst.dychbheight or 0
                inst.Transform:SetPosition(pos:Get())
            end
        end
    )
    if IsClient() then
        inst:DoTaskInTime(
            0,
            function()
                inst:InitHB()
            end
        )
    end
    return inst
end
local function DamageDisplay(inst, target, passedData)
    if not inst:IsValid() or not target:IsValid() or target.dycddcd == true then
        inst:Remove()
        return
    end
    target.dycddcd = true
    local health = nil
    if not IsClient() then
        health = target.components.health
    else
        health = target.replica.health
    end
    inst.Transform:SetPosition((target:GetPosition() + Vector3(0, GetEntHBHeight(target) * 0.65, 0)):Get())
    local oldhealth =
        (passedData and passedData.hpOld) or (not IsDST() and target.components.health.currenthealth) or
        (target.dychealthbar and target.dychealthbar.dychp) or
        (health and health:IsDead() and 0) or
        (passedData and passedData.hpOldDefault) or
        0
    local ison = false
    local angle = math.random() * 360
    local t = TUNING.DYC_HEALTHBAR_DDDURATION / 2
    local d = 1
    local h = 2
    local g = 2 * h / t / t
    local timer = 0
    local vh = d / t
    local vv = math.sqrt(2 * g * h)
    local duration = t * 2
    local changecolor = false
    local delay = TUNING.DYC_HEALTHBAR_DDDELAY
    local timer2 = 0
    inst.dycddtask =
        inst:DoPeriodicTask(
        FRAMES,
        function()
            if not inst:IsValid() or not target:IsValid() then
                inst.dycddtask:Cancel()
                inst:Remove()
                return
            end
            timer2 = timer2 + FRAMES
            timer = timer2 - delay
            if timer2 > delay then
                if ison == false then
                    target.dycddcd = false
                    local newhealth =
                        (passedData and passedData.hpNew) or (not IsDST() and target.components.health.currenthealth) or
                        (target.dychealthbar and target.dychealthbar.dychp) or
                        (health and health:IsDead() and 0) or
                        (passedData and passedData.hpNewDefault) or
                        0
                    local amount = newhealth - oldhealth
                    local absamount = math.abs(amount)
                    if absamount < TUNING.DYC_HEALTHBAR_DDTHRESHOLD then
                        inst.dycddtask:Cancel()
                        inst:Remove()
                        return
                    else
                        ison = true
                        inst.Label:Enable(true)
                        local sign = ""
                        if amount > 0 then
                            inst.Label:SetColour(0, 1, 0)
                            sign = "+"
                        else
                            inst.Label:SetColour(1, 0, 0)
                            changecolor = true
                        end
                        if absamount < 1 then
                            inst.Label:SetText(sign .. string.format("%.2f", amount))
                        elseif absamount < 100 then
                            inst.Label:SetText(sign .. string.format("%.1f", amount))
                        else
                            inst.Label:SetText(sign .. string.format("%d", amount))
                        end
                    end
                end
                local pos = inst:GetPosition()
                local move = Vector3(vh * FRAMES * math.cos(angle), vv * FRAMES, vh * FRAMES * math.sin(angle))
                inst.Transform:SetPosition(pos.x + move.x, pos.y + move.y, pos.z + move.z)
                vv = vv - g * FRAMES
                local fontsize =
                    (1 - math.abs(timer / t - 1)) * (TUNING.DYC_HEALTHBAR_DDSIZE2 - TUNING.DYC_HEALTHBAR_DDSIZE1) +
                    TUNING.DYC_HEALTHBAR_DDSIZE1
                inst.Label:SetFontSize(fontsize)
                if changecolor then
                    local greenandblue = 1 - Clamp01(timer / t - 0.5)
                    inst.Label:SetColour(1, greenandblue, greenandblue)
                end
                if timer >= duration then
                    inst.dycddtask:Cancel()
                    inst:Remove()
                end
            end
        end
    )
end
local function dycddfn()
    local inst = fn(true)
    inst.Label:SetFontSize(TUNING.DYC_HEALTHBAR_DDSIZE1)
    inst.Label:Enable(false)
    inst.InitHB = nil
    inst.DamageDisplay = DamageDisplay
    return inst
end
return Prefab("common/dyc_damagedisplay", dycddfn, assets, prefabs), Prefab(
    "common/dyc_healthbarchild",
    fn,
    assets,
    prefabs
), Prefab("common/dyc_healthbar", dychbfn, assets, prefabs)
