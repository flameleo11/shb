local function IsTable(o)
    return o ~= nil and type(o) == "table"
end
local function IsString(o)
    return o ~= nil and type(o) == "string"
end
local function IsNonEmptyString(o)
    return IsString(o) and #o > 0
end
local localization = {}
localization.language = "en"
localization.supportedLanguage = "en"
function localization:GetLanguage()
    local lan = string.lower(LanguageTranslator and LanguageTranslator.defaultlang or "en")
    self.language = lan
    return lan
end
function localization:GetSupportedLanguage()
    local abbr = self:GetLanguage()
    if abbr and type(abbr) == "string" then
        abbr = string.lower(abbr)
        if abbr == "cn" or abbr == "chs" or abbr == "sc" or abbr == "zh" or abbr == "zhr" then
            self.supportedLanguage = "chs"
            return "chs"
        elseif abbr == "cht" or abbr == "tw" then
            self.supportedLanguage = "cht"
            return "cht"
        end
        self.supportedLanguage = "en"
        return "en"
    end
    self.supportedLanguage = "en"
    return "en"
end
function localization:GetStrings(lan)
    lan = lan or self:GetSupportedLanguage()
    local strings = self.L2S[lan] or self.strings_en
    strings.GetString = function(strs, key, default)
        key = string.lower(key)
        return (IsNonEmptyString(strs[key]) and strs[key]) or (IsString(self.strings_en[key]) and self.strings_en[key]) or
            default or
            "N/A"
    end
    strings.HasString = function(strs, key)
        key = string.lower(key)
        return IsNonEmptyString(strs[key]) or IsString(self.strings_en[key])
    end
    strings.GetStrings = function(strs, key)
        local strs2 = IsTable(strs[key]) and strs[key] or {}
        if not strs2.GetString then
            strs2.GetString = function(strs2, k, d)
                return strs2[k] or (IsTable(self.strings_en[key]) and self.strings_en[key][k]) or d or "N/A"
            end
        end
        return strs2
    end
    self.strings = strings
    return strings
end
function localization:GetString(key, default)
    if not self.strings then
        self:GetStrings()
    end
    return self.strings:GetString(key, default)
end
function localization:HasString(key)
    if not self.strings then
        self:GetStrings()
    end
    return self.strings:HasString(key)
end
localization.strings_en = {
    menu_title = "SHB Settings",
    menu_gstyle = "Global HB Style:",
    menu_cstyle = "Player HB Style:",
    menu_bstyle = "Boss HB Style:",
    menu_preview = "Preview:",
    menu_value = "Health Value:",
    menu_length = "HB Length:",
    menu_thickness = "HB Thickness:",
    menu_pos = "HB Position:",
    menu_color = "HB Color:",
    menu_opacity = "HB Opacity:",
    menu_dd = "Damage Display:",
    menu_limit = "Limit:",
    menu_anim = "HB Animation:",
    menu_wallhb = "Wall HB:",
    menu_hotkey = "Hotkey:",
    menu_icon = "Icon:",
    menu_visit = "Visit:",
    hint_gstyle = "HB Style for ordinary creatures.",
    hint_cstyle = "Your own HB style! Different from other players!",
    hint_value = "Show health value or not.",
    hint_thickness = "Not working with text healthbar.",
    hint_opacity = "Not working with text healthbar.",
    hint_dd = "Show damage dealt and health healed?",
    hint_limit = "Limit the number of HB displayed to increase performance?",
    hint_anim = "Disable animation to increase performance?",
    hint_wallhb = "Disable wall healthbars to increase performance?",
    hint_hotkey = "Hotkey to turn on/off setting window.",
    hint_icon = "Show the heart icon?",
    hint_overhead2 = "Health value shown inside healthbar.",
    hint_dynamic = "Color varies with health percentage of the mob.",
    hint_dynamic2 = "Color varies with hostility of the mob.",
    hint_dynamic_dark = "Darker dynamic color.",
    hint_thb = "No preview for text health bar.",
    hint_apply = "Apply current settings!",
    hint_fixedthickness = "Fixed thickness(unit: pixel)!",
    hint_dynamicthickness = "Dynamic thickness(varies with mob's size)!",
    hint_mistake = "Looks like you disabled both icon and hotkey! If this is a mistake, enter 'shb.menu:Toggle()' in console!",
    hint_hotkeyreminder = "Hint: you can press %s to open SHB setting window!",
    followcfg = "Use Configuration",
    followglobal = "Use Global Style",
    nomodification = "No unauthorized modification is allowed!",
    title = "SimpleHealthBar",
    draggable = "Mouse Left to drag",
    about = "About",
    abouttext = " ",
    more = "More",
    back = "Back",
    receiveitem = "New item obtained",
    thx = "Thanks for supporting!",
    happysf = "Happy Spring Festival!",
    chosenone = "Congrats!",
    message = "Message",
    locked = "Locked",
    unlock = "Unlock",
    ok = "OK",
    tieba = "Baidu Forum",
    steam = "Steam",
    getplayerid = "Get Player Id",
    playerid = "Player Id",
    unlimited = "Unlimited",
    standard = "Standard",
    shadow = "Shadow",
    claw = "Claw",
    victorian = "Victorian",
    buckhorn = "Buckhorn",
    pixel = "Pixel",
    simple = "Simple",
    basic = "Basic",
    hidden = "Hidden",
    heart = "Heart",
    circle = "Circle",
    square = "Square",
    diamond = "Diamond",
    star = "Star",
    square2 = "Square2",
    apply = "Apply",
    on = "ON",
    off = "OFF",
    bottom = "Bottom",
    overhead = "Overhead",
    overhead2 = "Overhead2",
    dynamic = "Dynamic",
    dynamic2 = "Dynamic_Hostility",
    dynamic_dark = "Dynamic_Dark",
    white = "White",
    black = "Black",
    red = "Red",
    green = "Green",
    blue = "Blue",
    yellow = "Yellow",
    cyan = "Cyan",
    magenta = "Magenta",
    gray = "Gray",
    orange = "Orange",
    purple = "Purple",
    none = "None"
}
localization.strings_chs = {
    menu_title = "简易血条设置",
    menu_gstyle = "全局血条样式:",
    menu_cstyle = "玩家血条样式:",
    menu_bstyle = "Boss血条样式:",
    menu_preview = "预览:",
    menu_value = "生命值:",
    menu_length = "血条长度:",
    menu_thickness = "血条厚度:",
    menu_pos = "血条位置:",
    menu_color = "血条颜色:",
    menu_opacity = "不透明度:",
    menu_dd = "伤害显示:",
    menu_limit = "数量限制:",
    menu_anim = "血条动画:",
    menu_wallhb = "墙体血条:",
    menu_hotkey = "热键:",
    menu_icon = "图标:",
    menu_visit = "访问:",
    hint_gstyle = "普通生物的血条样式",
    hint_cstyle = "你自己的样式，与其他玩家不同的",
    hint_value = "是否显示血量",
    hint_thickness = "字符血条此项无效",
    hint_opacity = "字符血条此项无效",
    hint_dd = "显示造成的伤害和治疗值？",
    hint_limit = "限制显示的血条数量来防卡顿？",
    hint_anim = "关闭动画来防止卡顿？",
    hint_wallhb = "关闭墙的血条以防止卡顿？",
    hint_hotkey = "用以开启和关闭设置窗口的热键",
    hint_icon = "是否显示心形图标？",
    hint_overhead2 = "生命值显示在血条内",
    hint_dynamic = "颜色随生物生命百分比而变化",
    hint_dynamic2 = "颜色随生物敌意而变化",
    hint_dynamic_dark = "更暗的动态颜色",
    hint_thb = "文本血条无法预览",
    hint_apply = "应用当前设置！",
    hint_fixedthickness = "固定厚度(单位: 像素)!",
    hint_dynamicthickness = "动态厚度(随生物体积变化)!",
    hint_mistake = "检测到你似乎同时关闭了图标和热键！如果你只是手滑了，那么在控制台输入'shb.menu:Toggle()'重新打开！",
    hint_hotkeyreminder = "温馨提示：你可以按%s键打开简易血条设置窗口！",
    followcfg = "跟随mod配置",
    followglobal = "使用全局样式",
    nomodification = "未经许可禁止擅自修改！",
    title = "简易血条",
    draggable = "鼠标左键可拖动",
    about = "关于",
    abouttext = "有问题访问贴吧steam留言",
    more = "更多",
    back = "返回",
    receiveitem = "恭喜您获得了",
    thx = "感谢您的支持！",
    happysf = "新年快乐！",
    chosenone = "就决定是你了！",
    message = "消息",
    locked = "未解锁",
    unlock = "解锁",
    ok = "确定",
    tieba = "百度贴吧",
    steam = "Steam",
    getplayerid = "查看玩家ID",
    playerid = "玩家ID",
    unlimited = "不限制",
    standard = "标准",
    shadow = "暗影",
    claw = "利爪",
    victorian = "维多利亚",
    buckhorn = "鹿角",
    pixel = "像素",
    simple = "简易",
    basic = "基础",
    hidden = "隐藏",
    heart = "心形",
    circle = "圆形",
    square = "方形",
    diamond = "钻石",
    star = "五角星",
    square2 = "方形2",
    apply = "应用",
    on = "开启",
    off = "关闭",
    bottom = "底部",
    overhead = "头顶",
    overhead2 = "头顶2",
    dynamic = "动态",
    dynamic2 = "动态_敌意",
    dynamic_dark = "动态_暗",
    white = "白",
    black = "黑",
    red = "红",
    green = "绿",
    blue = "蓝",
    yellow = "黄",
    cyan = "青",
    magenta = "品红",
    gray = "灰",
    orange = "橙",
    purple = "紫",
    none = "无"
}
localization.L2S = {en = localization.strings_en, chs = localization.strings_chs}
return localization
