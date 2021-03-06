
local modinit = require("modinit")
local mod = modinit("simple_health_bar")

local logger = _G.import("log");
logger.log(_M._path, "guis start")

------------------------------------------------------------
-- rem
------------------------------------------------------------


local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local Screen = require "widgets/screen"
local Button = require "widgets/button"
local Spinner = require "widgets/spinner"
local dycguis = {}
local function IsDST()
    return TheSim:GetGameID() == "DST"
end
local function DYCGetPlayer()
    if IsDST() then
        return ThePlayer
    else
        return GetPlayer()
    end
end
local function DYCGetWorld()
    if IsDST() then
        return TheWorld
    else
        return GetWorld()
    end
end
local GetScreenScale = function()
    local sw, sh = TheSim:GetScreenSize()
    return sw / 1920
end
local GetMouseScreenPos = function()
    return TheSim:GetScreenPos(TheInput:GetWorldPosition():Get())
end
local RGBAColor = function(r, g, b, a)
    return {r = r or 1, g = g or 1, b = b or 1, a = a or 1, Get = function(self)
            return self.r, self.g, self.b, self.a
        end}
end
local Lerp = function(a, b, p)
    return a + (b - a) * p
end
local function StrSpl(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    local i = 1
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        t[i] = s
        i = i + 1
    end
    return t
end
local TableContains = function(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end
local TableAdd = function(t, value)
    if not TableContains(t, value) then
        table.insert(t, value)
    end
end
local TableGetIndex = function(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
end
local TableRemoveValue = function(t, value)
    local index = TableGetIndex(t, value)
    if index then
        table.remove(t, index)
    end
end
local DYC_Root =
    Class(
    Widget,
    function(self, data)
        Widget._ctor(self, "DYC_Root")
        self.keepTop = data.keepTop
        self.moveLayerTimer = 0
        if data.keepTop then
            self:StartUpdating()
        end
    end
)
function DYC_Root:OnUpdate(dt)
    dt = dt or 0
    self.moveLayerTimer = self.moveLayerTimer + dt
    if self.keepTop and self.moveLayerTimer > 0.5 then
        self.moveLayerTimer = 0
        self:MoveToFront()
    end
end
dycguis.Root = DYC_Root
local DYC_Text =
    Class(
    Text,
    function(self, font, size, text, hittest)
        if font and type(font) == "table" then
            local data = font
            Text._ctor(self, data.font or NUMBERFONT, data.fontSize or 30, data.text)
            if data.color then
                local c = data.color
                self:SetColor(c.r or c[1] or 1, c.g or c[2] or 1, c.b or c[3] or 1, c.a or c[4] or 1)
            end
            if data.regionSize then
                self:SetRegionSize(data.regionSize.w, data.regionSize.h)
            end
            self.alignH = data.alignH
            self.alignV = data.alignV
            self.focusFn = data.focusFn
            self.unfocusFn = data.unfocusFn
            self.hittest = data.hittest
        else
            Text._ctor(self, font or NUMBERFONT, size or 30, text)
            self.hittest = hittest
            if text then
                self:SetText(text)
            end
        end
    end
)
function DYC_Text:GetImage()
    if not self.image then
        self.image = self:AddChild(Image("images/ui.xml", "button.tex"))
        self.image:MoveToBack()
        self.image:SetTint(0, 0, 0, 0)
    end
    return self.image
end
function DYC_Text:SetText(str)
    local oldWidth = self:GetWidth()
    local oldHeight = self:GetHeight()
    local pos = self:GetPosition()
    self:SetString(str)
    if self.alignH and self.alignH ~= ANCHOR_MIDDLE then
        local newWidth = self:GetWidth()
        pos.x = pos.x + (newWidth - oldWidth) / 2 * (self.alignH == ANCHOR_LEFT and 1 or -1)
    end
    if self.alignV and self.alignV ~= ANCHOR_MIDDLE then
        local newHeight = self:GetHeight()
        pos.y = pos.y + (newHeight - oldHeight) / 2 * (self.alignV == ANCHOR_BOTTOM and 1 or -1)
    end
    if self.alignH or self.alignV then
        self:SetPosition(pos)
    end
    if self.hittest then
        self:GetImage():SetSize(self:GetSize())
    end
end
function DYC_Text:SetColor(...)
    self:SetColour(...)
end
function DYC_Text:GetWidth()
    local w, h = self:GetRegionSize()
    w = w < 10000 and w or 0
    return w
end
function DYC_Text:GetHeight()
    local w, h = self:GetRegionSize()
    h = h < 10000 and h or 0
    return h
end
function DYC_Text:GetSize()
    local w, h = self:GetRegionSize()
    w = w < 10000 and w or 0
    h = h < 10000 and h or 0
    return w, h
end
function DYC_Text:OnGainFocus()
    DYC_Text._base.OnGainFocus(self)
    if self.focusFn then
        self.focusFn(self)
    end
end
function DYC_Text:OnLoseFocus()
    DYC_Text._base.OnLoseFocus(self)
    if self.unfocusFn then
        self.unfocusFn(self)
    end
end
function DYC_Text:AnimateIn(speed)
    self.textString = self.string
    self.animSpeed = speed or 60
    self.animIndex = 0
    self.animTimer = 0
    self:SetText("")
    self:StartUpdating()
end
function DYC_Text:OnUpdate(dt)
    dt = dt or 0
    if DYC_Text._base.OnUpdate then
        DYC_Text._base.OnUpdate(self, dt)
    end
    if dt > 0 and self.animIndex and self.textString and #self.textString > 0 then
        self.animTimer = self.animTimer + dt
        if self.animTimer > 1 / self.animSpeed then
            self.animTimer = 0
            self.animIndex = self.animIndex + 1
            if self.animIndex > #self.textString then
                self.animIndex = nil
                self:SetText(self.textString)
            else
                local ascii = string.byte(string.sub(self.textString, self.animIndex, self.animIndex))
                if ascii and ascii > 127 then
                    self.animIndex = self.animIndex + 2
                end
                self:SetText(string.sub(self.textString, 1, self.animIndex))
            end
        end
    end
end
dycguis.Text = DYC_Text
local DYC_SlicedImage =
    Class(
    Widget,
    function(self, data)
        Widget._ctor(self, "DYC_SlicedImage")
        self.images = {}
        self.mode = "slice13"
        self.texScale = data.texScale or 1
        self.width = 100
        self.height = 100
        self:SetTextures(data)
    end
)
function DYC_SlicedImage:__tostring()
    return string.format("%s (%s)", self.name, self.mode)
end
function DYC_SlicedImage:SetTextures(data)
    assert(data.mode)
    self.images = {}
    self.mode = data.mode
    if self.mode == "slice13" or self.mode == "slice31" then
        local img = nil
        img = self:AddChild(Image(data.atlas, data.texname .. "_1.tex"))
        img.oriW, img.oriH = img:GetSize()
        img.imgPos = 1
        self.images[1] = img
        img = self:AddChild(Image(data.atlas, data.texname .. "_2.tex"))
        img.oriW, img.oriH = img:GetSize()
        img.imgPos = 2
        self.images[2] = img
        img = self:AddChild(Image(data.atlas, data.texname .. "_3.tex"))
        img.oriW, img.oriH = img:GetSize()
        img.imgPos = 3
        self.images[3] = img
        if self.mode == "slice13" then
            assert(self.images[1].oriH == self.images[3].oriH, "Height must be equal!")
            assert(self.images[1].oriH == self.images[2].oriH, "Height must be equal!")
        else
            assert(self.images[1].oriW == self.images[3].oriW, "Width must be equal!")
            assert(self.images[1].oriW == self.images[2].oriW, "Width must be equal!")
        end
        return
    elseif self.mode == "slice33" then
        local img = nil
        for i = 1, 3 do
            for j = 1, 3 do
                img = self:AddChild(Image(data.atlas, data.texname .. "_" .. i .. j .. ".tex"))
                img.oriW, img.oriH = img:GetSize()
                img.imgPos = i * 10 + j
                self.images[i * 10 + j] = img
                if i > 1 then
                    assert(self.images[i * 10 + j].oriW == self.images[(i - 1) * 10 + j].oriW, "Width must be equal!")
                end
                if j > 1 then
                    assert(self.images[i * 10 + j].oriH == self.images[i * 10 + j - 1].oriH, "Height must be equal!")
                end
            end
        end
        return
    end
    error("Mode not supported!")
    self:SetSize()
end
function DYC_SlicedImage:SetSize(w, h)
    w = w or self.width
    h = h or self.height
    if self.mode == "slice13" then
        local img1 = self.images[1]
        local img2 = self.images[2]
        local img3 = self.images[3]
        local scale = math.min(self.texScale, math.min(w / (img1.oriW + img3.oriW), h / img1.oriH))
        local w1 = img1.oriW * scale
        local w3 = img3.oriW * scale
        local w2 = math.max(0, w - w1 - w3)
        img1:SetSize(w1, h)
        img2:SetSize(w2, h)
        img3:SetSize(w3, h)
        local x2 = (w1 - w3) / 2
        local x1 = -w1 / 2 - w2 / 2 + x2
        local x3 = w3 / 2 + w2 / 2 + x2
        img1:SetPosition(x1, 0, 0)
        img2:SetPosition(x2, 0, 0)
        img3:SetPosition(x3, 0, 0)
        self.width = w1 + w2 + w3
        self.height = h
    elseif self.mode == "slice31" then
        local img1 = self.images[1]
        local img2 = self.images[2]
        local img3 = self.images[3]
        local scale = math.min(self.texScale, math.min(h / (img1.oriH + img3.oriH), w / img1.oriW))
        local h1 = img1.oriH * scale
        local h3 = img3.oriH * scale
        local h2 = math.max(0, h - h1 - h3)
        img1:SetSize(w, h1)
        img2:SetSize(w, h2)
        img3:SetSize(w, h3)
        local y2 = (h1 - h3) / 2
        local y1 = -h1 / 2 - h2 / 2 + y2
        local y3 = h3 / 2 + h2 / 2 + y2
        img1:SetPosition(0, y1, 0)
        img2:SetPosition(0, y2, 0)
        img3:SetPosition(0, y3, 0)
        self.height = h1 + h2 + h3
        self.width = w
    elseif self.mode == "slice33" then
        local imgs = self.images
        local scale =
            math.min(self.texScale, math.min(w / (imgs[11].oriW + imgs[13].oriW), h / (imgs[11].oriH + imgs[31].oriH)))
        local ws, hs, xs, ys = {}, {}, {}, {}
        ws[1] = imgs[11].oriW * scale
        ws[3] = imgs[13].oriW * scale
        ws[2] = math.max(0, w - ws[1] - ws[3])
        hs[1] = imgs[11].oriH * scale
        hs[3] = imgs[31].oriH * scale
        hs[2] = math.max(0, h - hs[1] - hs[3])
        xs[2] = (ws[1] - ws[3]) / 2
        xs[1] = -ws[1] / 2 - ws[2] / 2 + xs[2]
        xs[3] = ws[3] / 2 + ws[2] / 2 + xs[2]
        ys[2] = (hs[1] - hs[3]) / 2
        ys[1] = -hs[1] / 2 - hs[2] / 2 + ys[2]
        ys[3] = hs[3] / 2 + hs[2] / 2 + ys[2]
        for i = 1, 3 do
            for j = 1, 3 do
                imgs[i * 10 + j]:SetSize(ws[j], hs[i])
                imgs[i * 10 + j]:SetPosition(xs[j], ys[i], 0)
            end
        end
        self.width = ws[1] + ws[2] + ws[3]
        self.height = hs[1] + hs[2] + hs[3]
    end
end
function DYC_SlicedImage:GetSize()
    return self.width, self.height
end
function DYC_SlicedImage:SetTint(r, g, b, a)
    for k, v in pairs(self.images) do
        v:SetTint(r, g, b, a)
    end
end
function DYC_SlicedImage:SetClickable(b)
    for k, v in pairs(self.images) do
        v:SetClickable(b)
    end
end
dycguis.SlicedImage = DYC_SlicedImage
local DYC_Spinner =
    Class(
    Spinner,
    function(self, options, width, height, textinfo, editable, atlas, textures)
        Spinner._ctor(self, options, width, height, textinfo, editable, atlas, textures, true)
        self.bgDYC = self:AddChild(Image("images/dyc_white.xml", "dyc_white.tex"))
        self.bgDYC:SetTint(0, 0, 0, 0.1)
        self.bgDYC:SetSize(self.width, self.height)
        self.bgDYC:MoveToBack()
    end
)
function DYC_Spinner:GetSelectedHint()
    return self.options[self.selectedIndex].hint or ""
end
function DYC_Spinner:SetSelected(data, data2)
    if data == nil and data2 ~= nil then
        return self:SetSelected(data2)
    end
    for k, v in pairs(self.options) do
        if v.data == data then
            self:SetSelectedIndex(k)
            return true
        end
    end
    if data2 then
        return self:SetSelected(data2)
    else
        return false
    end
end
function DYC_Spinner:SetSelectedIndex(idx, ...)
    DYC_Spinner._base.SetSelectedIndex(self, idx, ...)
    if self.setSelectedIndexFn then
        self.setSelectedIndexFn(self)
    end
end
function DYC_Spinner:OnGainFocus()
    DYC_Spinner._base.OnGainFocus(self)
    if self.focusFn then
        self.focusFn(self)
    end
end
function DYC_Spinner:OnLoseFocus()
    DYC_Spinner._base.OnLoseFocus(self)
    if self.unfocusFn then
        self.unfocusFn(self)
    end
end
function DYC_Spinner:OnMouseButton(button, down, x, y, ...)
    DYC_Spinner._base.OnMouseButton(self, button, down, x, y, ...)
    if not down and button == MOUSEBUTTON_LEFT then
        if self.mouseLeftUpFn then
            self.mouseLeftUpFn(self)
        end
    end
    if not self.focus then
        return false
    end
    if down and button == MOUSEBUTTON_LEFT then
        if self.mouseLeftDownFn then
            self.mouseLeftDownFn(self)
        end
    end
end
dycguis.Spinner = DYC_Spinner
local DYC_ImageButton =
    Class(
    Button,
    function(self, data)
        Button._ctor(self, "DYC_ImageButton")
        data = data or {}
        local atlas, normal, focus, disabled = data.atlas, data.normal, data.focus, data.disabled
        atlas = atlas or "images/ui.xml"
        normal = normal or "button.tex"
        focus = focus or "button_over.tex"
        disabled = disabled or "button_disabled.tex"
        self.width = data.width or 100
        self.height = data.height or 30
        self.screenScale = 0.9999
        self.moveLayerTimer = 0
        self.followScreenScale = data.followScreenScale
        self.draggable = data.draggable
        if data.draggable then
            self.clickoffset = Vector3(0, 0, 0)
        end
        self.dragging = false
        self.draggingTimer = 0
        self.draggingPos = {x = 0, y = 0}
        self.keepTop = data.keepTop
        self.image = self:AddChild(Image())
        self.image:MoveToBack()
        self.atlas = atlas
        self.image_normal = normal
        self.image_focus = focus or normal
        self.image_disabled = disabled or normal
        self.color_normal = data.colornormal or RGBAColor(1, 0.6, 0.45)
        self.color_focus = data.colorfocus or RGBAColor(1, 0.6, 0.45)
        self.color_disabled = data.colordisabled or RGBAColor(1, 0.6, 0.45)
        if data.cb then
            self:SetOnClick(data.cb)
        end
        if data.text then
            self:SetText(data.text)
            self:SetFont(data.font or NUMBERFONT)
            self:SetTextSize(data.fontSize or self.height * 0.75)
            local r, g, b, a = 1, 1, 1, 1
            if data.textColor then
                r = data.textColor.r
                g = data.textColor.g
                b = data.textColor.b
                a = data.textColor.a
            end
            self:SetTextColour(r, g, b, a)
        end
        self:SetTexture(self.atlas, self.image_normal)
        self:StartUpdating()
    end
)
function DYC_ImageButton:SetSize(w, h)
    w = w or self.width
    h = h or self.height
    self.width = w
    self.height = h
    self.image:SetSize(self.width, self.height)
end
function DYC_ImageButton:GetSize()
    return self.image:GetSize()
end
function DYC_ImageButton:SetTexture(atlas, tex)
    self.image:SetTexture(atlas, tex)
    self:SetSize()
    local c = self.color_normal
    self.image:SetTint(c.r, c.g, c.b, c.a)
end
function DYC_ImageButton:SetTextures(atlas, normal, focus, disabled)
    local default_textures = false
    if not atlas then
        atlas = atlas or "images/frontend.xml"
        normal = normal or "button_long.tex"
        focus = focus or "button_long_halfshadow.tex"
        disabled = disabled or "button_long_disabled.tex"
        default_textures = true
    end
    self.atlas = atlas
    self.image_normal = normal
    self.image_focus = focus or normal
    self.image_disabled = disabled or normal
    if self:IsEnabled() then
        if self.focus then
            self:OnGainFocus()
        else
            self:OnLoseFocus()
        end
    else
        self:OnDisable()
    end
end
function DYC_ImageButton:OnGainFocus()
    DYC_ImageButton._base.OnGainFocus(self)
    if self:IsEnabled() then
        self:SetTexture(self.atlas, self.image_focus)
        local c = self.color_focus
        self.image:SetTint(c.r, c.g, c.b, c.a)
    end
    if self.image_focus == self.image_normal then
        self.image:SetScale(1.2, 1.2, 1.2)
    end
    if self.focusFn then
        self.focusFn(self)
    end
end
function DYC_ImageButton:OnLoseFocus()
    DYC_ImageButton._base.OnLoseFocus(self)
    if self:IsEnabled() then
        self:SetTexture(self.atlas, self.image_normal)
        local c = self.color_normal
        self.image:SetTint(c.r, c.g, c.b, c.a)
    end
    if self.image_focus == self.image_normal then
        self.image:SetScale(1, 1, 1)
    end
    if self.unfocusFn then
        self.unfocusFn(self)
    end
end
function DYC_ImageButton:OnMouseButton(button, down, x, y, ...)
    DYC_ImageButton._base.OnMouseButton(self, button, down, x, y, ...)
    if not down and button == MOUSEBUTTON_LEFT and self.dragging then
        self.dragging = false
        if self.dragEndFn then
            self.dragEndFn(self)
        end
    end
    if not self.focus then
        return false
    end
    if self.draggable and button == MOUSEBUTTON_LEFT then
        if down then
            self.dragging = true
            self.draggingPos.x = x
            self.draggingPos.y = y
        end
    end
end
function DYC_ImageButton:OnControl(control, down, ...)
    if self.draggingTimer <= 0.3 then
        if DYC_ImageButton._base.OnControl(self, control, down, ...) then
            self:StartUpdating()
            return true
        end
        self:StartUpdating()
    end
    if not self:IsEnabled() or not self.focus then
        return
    end
end
function DYC_ImageButton:Enable()
    DYC_ImageButton._base.Enable(self)
    self:SetTexture(self.atlas, self.focus and self.image_focus or self.image_normal)
    local c = self.focus and self.color_focus or self.color_normal
    self.image:SetTint(c.r, c.g, c.b, c.a)
    if self.image_focus == self.image_normal then
        if self.focus then
            self.image:SetScale(1.2, 1.2, 1.2)
        else
            self.image:SetScale(1, 1, 1)
        end
    end
end
function DYC_ImageButton:Disable()
    DYC_ImageButton._base.Disable(self)
    self:SetTexture(self.atlas, self.image_disabled)
    local c = self.color_disabled or self.color_normal
    self.image:SetTint(c.r, c.g, c.b, c.a)
end
function DYC_ImageButton:OnUpdate(dt)
    dt = dt or 0
    local newss = GetScreenScale()
    if self.followScreenScale and newss ~= self.screenScale then
        self:SetScale(newss)
        local offset = self:GetPosition()
        offset.x = offset.x * newss / self.screenScale
        offset.y = offset.y * newss / self.screenScale
        self.o_pos = offset
        self:SetPosition(offset)
        self.screenScale = newss
    end
    if self.draggable and self.dragging then
        self.draggingTimer = self.draggingTimer + dt
        local x, y = GetMouseScreenPos()
        local dx = x - self.draggingPos.x
        local dy = y - self.draggingPos.y
        self.draggingPos.x = x
        self.draggingPos.y = y
        local offset = self:GetPosition()
        offset.x = offset.x + dx
        offset.y = offset.y + dy
        self.o_pos = offset
        self:SetPosition(offset)
    end
    if not self.dragging then
        self.draggingTimer = 0
    end
    self.moveLayerTimer = self.moveLayerTimer + dt
    if self.keepTop and self.moveLayerTimer > 0.5 then
        self.moveLayerTimer = 0
        self:MoveToFront()
    end
end
dycguis.ImageButton = DYC_ImageButton
local DYC_Window =
    Class(
    Widget,
    function(self)
        Widget._ctor(self, "DYC_Window")
        self.width = 400
        self.height = 300
        self.paddingX = 40
        self.paddingY = 42
        self.screenScale = 0.9999
        self.currentLineY = 0
        self.currentLineX = 0
        self.lineHeight = 35
        self.lineSpacingX = 10
        self.lineSpacingY = 3
        self.fontSize = self.lineHeight * 0.9
        self.font = NUMBERFONT
        self.titleFontSize = 40
        self.titleFont = NUMBERFONT
        self.titleColor = RGBAColor(1, 0.7, 0.4)
        self.draggable = true
        self.dragging = false
        self.draggingPos = {x = 0, y = 0}
        self.draggableChildren = {}
        self.moveLayerTimer = 0
        self.keepTop = false
        self.currentPageIndex = 1
        self.pages = {}
        self.animTargetSize = nil
        self.bg =
            self:AddChild(
            DYC_SlicedImage(
                {mode = "slice33", atlas = "images/dycghb_panel.xml", texname = "dycghb_panel", texScale = 1.0}
            )
        )
        self.bg:SetSize(self.width, self.height)
        self.bg:SetTint(1, 1, 1, 1)
        self:SetCenterAlignment()
        self:AddDraggableChild(self.bg, true)
        self.root = self.bg:AddChild(Widget("root"))
        self.rootTL = self.root:AddChild(Widget("rootTL"))
        self.rootT = self.root:AddChild(Widget("rootT"))
        self.rootTR = self.root:AddChild(Widget("rootTR"))
        self.rootL = self.root:AddChild(Widget("rootL"))
        self.rootM = self.root:AddChild(Widget("rootM"))
        self.rootR = self.root:AddChild(Widget("rootR"))
        self.rootB = self.root:AddChild(Widget("rootB"))
        self.rootBL = self.root:AddChild(Widget("rootBL"))
        self.rootBR = self.root:AddChild(Widget("rootBR"))
        self:SetSize()
        self:SetOffset(0, 0, 0)
        self:StartUpdating()
    end
)
function DYC_Window:SetBottomLeftAlignment()
    self.bg:SetVAnchor(ANCHOR_BOTTOM)
    self.bg:SetHAnchor(ANCHOR_LEFT)
end
function DYC_Window:SetTopLeftAlignment()
    self.bg:SetVAnchor(ANCHOR_TOP)
    self.bg:SetHAnchor(ANCHOR_LEFT)
end
function DYC_Window:SetCenterAlignment()
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
end
function DYC_Window:SetOffset(...)
    self.bg:SetPosition(...)
end
function DYC_Window:GetOffset()
    return self.bg:GetPosition()
end
function DYC_Window:SetSize(w, h)
    w = w or self.width
    h = h or self.height
    self.width = w
    self.height = h
    self.bg:SetSize(w, h)
    self.rootTL:SetPosition(-w / 2, h / 2, 0)
    self.rootT:SetPosition(0, h / 2, 0)
    self.rootTR:SetPosition(w / 2, h / 2, 0)
    self.rootL:SetPosition(-w / 2, 0, 0)
    self.rootM:SetPosition(0, 0, 0)
    self.rootR:SetPosition(w / 2, 0, 0)
    self.rootBL:SetPosition(-w / 2, -h / 2, 0)
    self.rootB:SetPosition(0, -h / 2, 0)
    self.rootBR:SetPosition(w / 2, -h / 2, 0)
end
function DYC_Window:GetSize()
    return self.width, self.height
end
function DYC_Window:SetTitle(str, font, fontSize, c)
    str = str or ""
    font = font or self.titleFont
    fontSize = fontSize or self.titleFontSize
    c = c or self.titleColor
    if not self.title then
        self.title = self.rootT:AddChild(DYC_Text(font, fontSize))
    end
    self.titleFont = font
    self.titleFontSize = fontSize
    self.titleColor = c
    self.title:SetString(str)
    self.title:SetFont(font)
    self.title:SetSize(fontSize)
    self.title:SetPosition(0, -fontSize / 2 * 1.3 - self.paddingY, 0)
    self.title:SetColor(c.r or c[1] or 1, c.g or c[2] or 1, c.b or c[3] or 1, c.a or c[4] or 1)
end
function DYC_Window:GetPage(pageIndex)
    pageIndex = pageIndex or self.currentPageIndex
    pageIndex = math.max(1, math.floor(pageIndex))
    while self.pages[pageIndex] == nil do
        table.insert(self.pages, {root = self.rootTL:AddChild(Widget("rootPage" .. pageIndex)), contents = {}})
    end
    return self.pages[pageIndex]
end
function DYC_Window:SetCurrentPage(pageIndex)
    pageIndex = math.max(1, math.floor(pageIndex))
    self.currentPageIndex = pageIndex
    self.currentLineY = 0
    self.currentLineX = 0
    return self:GetPage()
end
function DYC_Window:ShowPage(pageIndex)
    pageIndex = pageIndex or self.currentPageIndex
    pageIndex = math.max(1, math.min(math.floor(pageIndex), #self.pages))
    self:SetCurrentPage(pageIndex)
    for i = 1, #self.pages do
        self:ToggleContents(i, i == pageIndex)
    end
    if self.pageChangeFn then
        self.pageChangeFn(self, pageIndex)
    end
end
function DYC_Window:ShowNextPage()
    local pageIndex = self.currentPageIndex + 1
    if pageIndex > #self.pages then
        pageIndex = 1
    end
    self:ShowPage(pageIndex)
end
function DYC_Window:ShowPreviousPage()
    local pageIndex = self.currentPageIndex - 1
    if pageIndex < 1 then
        pageIndex = #self.pages
    end
    self:ShowPage(pageIndex)
end
function DYC_Window:ClearPages()
    if #self.pages <= 0 then
        return
    end
    for i = 1, #self.pages do
        self:ClearContents(i)
    end
end
function DYC_Window:AddContent(w, width)
    local page = self:GetPage()
    local uie = page.root:AddChild(w)
    if not width then
        if uie.GetRegionSize then
            width = uie:GetRegionSize()
        elseif uie.GetWidth then
            width = uie:GetWidth()
        elseif uie.width then
            width = uie.width
        end
    end
    width = width or 100
    uie:SetPosition(
        self.paddingX + self.currentLineX + width / 2,
        -self.paddingY - self.currentLineY - self.lineHeight * 0.5,
        0
    )
    self.currentLineX = self.currentLineX + width + self.lineSpacingX
    TableAdd(page.contents, uie)
    return uie
end
function DYC_Window:ToggleContents(pageIndex, b)
    local page = self:GetPage(pageIndex)
    if b then
        page.root:Show()
    else
        page.root:Hide()
    end
end
function DYC_Window:ClearContents(pageIndex)
    pageIndex = pageIndex or self.currentPageIndex
    for k, v in pairs(self:GetPage(pageIndex).contents) do
        v:Kill()
    end
    self:GetPage(pageIndex).contents = {}
    self.currentLineY = 0
    self.currentLineX = 0
end
function DYC_Window:NewLine(k)
    self.currentLineY = self.currentLineY + (k or 1) * self.lineHeight + self.lineSpacingY
    self.currentLineX = 0
end
function DYC_Window:AddDraggableChild(child, includeChildren)
    TableAdd(self.draggableChildren, child)
    if includeChildren then
        for k, v in pairs(child.children) do
            self:AddDraggableChild(v, true)
        end
    end
end
function DYC_Window:OnRawKey(key, down, ...)
    local returnValue = DYC_Window._base.OnRawKey(self, key, down, ...)
    if not self.focus then
        return false
    end
    return returnValue
end
function DYC_Window:OnControl(control, down, ...)
    local returnValue = DYC_Window._base.OnControl(self, control, down, ...)
    if not self.focus then
        return false
    end
    return returnValue
end
function DYC_Window:OnMouseButton(button, down, x, y, ...)
    local returnValue = DYC_Window._base.OnMouseButton(self, button, down, x, y, ...)
    if not down and button == MOUSEBUTTON_LEFT then
        self.dragging = false
    end
    if not self.focus then
        return false
    end
    if self.draggable and button == MOUSEBUTTON_LEFT then
        if down then
            local deepestFocus = self:GetDeepestFocus()
            if deepestFocus and TableContains(self.draggableChildren, deepestFocus) then
                self.dragging = true
                self.draggingPos.x = x
                self.draggingPos.y = y
            end
        end
    end
    return returnValue
end
function DYC_Window:Toggle(b, isOK)
    b = b ~= nil and b or not self.shown
    if b then
        self:Show()
    else
        self:Hide()
    end
    if self.toggleFn then
        self.toggleFn(self, b)
    end
    if not b and isOK and self.okFn then
        self.okFn(self)
    end
    if not b and not isOK and self.cancelFn then
        self.cancelFn(self)
    end
end
function DYC_Window:AnimateSize(tw, th, speed)
    if tw and th then
        self.animTargetSize = {w = tw, h = th}
        self.animSpeed = speed or 5
    end
end
function DYC_Window:OnUpdate(dt)
    dt = dt or 0
    if self.animTargetSize and dt > 0 then
        local w, h = self:GetSize()
        if math.abs(w - self.animTargetSize.w) < 1 then
            self:SetSize(self.animTargetSize.w, self.animTargetSize.h)
            self.animTargetSize = nil
        else
            self:SetSize(
                Lerp(w, self.animTargetSize.w, self.animSpeed * dt),
                Lerp(h, self.animTargetSize.h, self.animSpeed * dt)
            )
        end
    end
    local newss = GetScreenScale()
    if newss ~= self.screenScale then
        self.bg:SetScale(newss)
        local offset = self:GetOffset()
        offset.x = offset.x * newss / self.screenScale
        offset.y = offset.y * newss / self.screenScale
        self:SetOffset(offset)
        self.screenScale = newss
    end
    if self.draggable and self.dragging then
        local x, y = GetMouseScreenPos()
        local dx = x - self.draggingPos.x
        local dy = y - self.draggingPos.y
        self.draggingPos.x = x
        self.draggingPos.y = y
        local offset = self:GetOffset()
        offset.x = offset.x + dx
        offset.y = offset.y + dy
        self:SetOffset(offset)
    end
    self.moveLayerTimer = self.moveLayerTimer + dt
    if self.keepTop and self.moveLayerTimer > 0.5 then
        self.moveLayerTimer = 0
        self:MoveToFront()
    end
end
dycguis.Window = DYC_Window
local DYC_Banner =
    Class(
    DYC_Window,
    function(self, data)
        DYC_Window._ctor(self)
        self:SetTopLeftAlignment()
        self.bg:SetClickable(false)
        self.bg:SetTint(1, 1, 1, 0)
        self.paddingX = 35
        self.paddingY = 35
        self.lineHeight = 32
        self.fontSize = 32
        self.font = DEFAULTFONT
        self.bannerColor = data.color or RGBAColor()
        self.bannerText =
            self:AddContent(
            DYC_Text(
                {
                    font = self.font,
                    fontSize = self.fontSize,
                    alignH = ANCHOR_LEFT,
                    text = data.text or "???",
                    color = self.bannerColor
                }
            )
        )
        local windowW, windowH = self.currentLineX + self.paddingX * 2, self.lineHeight + self.paddingY * 2
        self:SetSize(windowW, windowH)
        self.windowW = windowW
        self.bannerText:AnimateIn()
        self:SetOffset(700, -windowH / 2)
        self.shouldFadeIn = true
        self.bannerOpacity = 0
        self.bannerTimer = data.duration or 5
        self.bannerIndex = 1
    end
)
function DYC_Banner:SetShouldFadeOut()
    self.shouldFadeIn = false
end
function DYC_Banner:OnUpdate(dt)
    DYC_Banner._base.OnUpdate(self, dt)
    dt = dt or 0
    if dt > 0 then
        self.bannerTimer = self.bannerTimer - dt
        if self.shouldFadeIn then
            self.bannerOpacity = math.min(1, self.bannerOpacity + dt * 3)
        else
            self.bannerOpacity = self.bannerOpacity - dt
            if self.bannerOpacity <= 0 then
                if self.bannerHolder then
                    self.bannerHolder:RemoveBanner(self)
                end
                self:Kill()
            end
        end
        if self.bannerOpacity > 0 then
            self.bg:SetTint(1, 1, 1, self.bannerOpacity)
            local c = self.bannerColor
            self.bannerText:SetColor(c.r or c[1] or 1, c.g or c[2] or 1, c.b or c[3] or 1, self.bannerOpacity)
            local w, h = self:GetSize()
            local offset = self:GetOffset()
            local x, y = offset.x, offset.y
            local tX, tY = w / 2 * self.screenScale, (h / 2 - h * self.bannerIndex) * self.screenScale
            local p = 0.1
            self:SetOffset(Lerp(x, tX, p), Lerp(y, tY, p))
        end
    end
end
dycguis.Banner = DYC_Banner
local DYC_BannerHolder =
    Class(
    DYC_Root,
    function(self, data)
        data = data or {}
        DYC_Root._ctor(self, data)
        self.banners = {}
        self.bannerInfos = {}
        self.bannerInterval = data.interval or 0.3
        self.bannerShowTimer = 999
        self.bannerSound = data.sound or "dontstarve/HUD/XP_bar_fill_unlock"
        self.maxBannerNum = data.max or 6
        self:StartUpdating()
    end
)
function DYC_BannerHolder:PushMessage(text, duration, color, playSound)
    table.insert(self.bannerInfos, {text = text, duration = duration, color = color, playSound = playSound})
end
function DYC_BannerHolder:ShowMessage(text, duration, color, playSound)
    local banner = self:AddChild(DYC_Banner({text = text, duration = duration, color = color}))
    self:AddBanner(banner)
    local player = DYCGetPlayer()
    if playSound and player and player.SoundEmitter and self.bannerSound then
        player.SoundEmitter:PlaySound(self.bannerSound)
    end
end
function DYC_BannerHolder:AddBanner(banner)
    banner.bannerHolder = self
    local banners = self.banners
    table.insert(banners, 1, banner)
    for i = 1, #banners do
        banners[i].bannerIndex = i
    end
end
function DYC_BannerHolder:RemoveBanner(banner)
    for k, v in pairs(self.banners) do
        if v == banner then
            table.remove(self.banners, k)
            break
        end
    end
    for k, v in pairs(self.banners) do
        v.bannerIndex = k
    end
end
function DYC_BannerHolder:OnUpdate(dt)
    dt = dt or 0
    local banners = self.banners
    local infos = self.bannerInfos
    if dt > 0 and #banners > 0 then
        for i = 1, #banners do
            local banner = banners[i]
            if i > self.maxBannerNum then
                banner:SetShouldFadeOut()
            elseif banner.bannerTimer <= 0 then
                banner:SetShouldFadeOut()
            end
        end
    end
    if dt > 0 and #infos > 0 then
        self.bannerShowTimer = self.bannerShowTimer + dt
        if self.bannerShowTimer >= self.bannerInterval then
            self.bannerShowTimer = 0
            local info = infos[1]
            table.remove(infos, 1)
            if #infos <= 0 then
                self.bannerShowTimer = 999
            end
            self:ShowMessage(info.text, info.duration, info.color, info.playSound)
        end
    end
end
dycguis.BannerHolder = DYC_BannerHolder
local DYC_MessageBox =
    Class(
    DYC_Window,
    function(self, data)
        DYC_Window._ctor(self)
        self.messageText =
            self.rootM:AddChild(
            DYC_Text({font = self.font, fontSize = data.fontSize or self.fontSize, color = RGBAColor(0.9, 0.9, 0.9, 1)})
        )
        self.strings = data.strings
        self.callback = data.callback
        local closeButton =
            self.rootTR:AddChild(
            DYC_ImageButton(
                {
                    width = 40,
                    height = 40,
                    atlas = "images/dyc_button_close.xml",
                    normal = "dyc_button_close.tex",
                    focus = "dyc_button_close.tex",
                    disabled = "dyc_button_close.tex",
                    colornormal = RGBAColor(1, 1, 1, 1),
                    colorfocus = RGBAColor(1, 0.2, 0.2, 0.7),
                    colordisabled = RGBAColor(0.4, 0.4, 0.4, 1),
                    cb = function()
                        if self.callback then
                            self.callback(self, false)
                        end
                        self:Kill()
                    end
                }
            )
        )
        closeButton:SetPosition(-self.paddingX - closeButton.width / 2, -self.paddingY - closeButton.height / 2, 0)
        local okButton =
            self.rootB:AddChild(
            DYC_ImageButton(
                {width = 100, height = 50, text = self.strings:GetString("ok"), cb = function()
                        if self.callback then
                            self.callback(self, true)
                        end
                        self:Kill()
                    end}
            )
        )
        okButton:SetPosition(0, self.paddingY + okButton.height / 2, 0)
        if data.message then
            self:SetMessage(data.message)
        end
        if data.title then
            self:SetTitle(data.title, nil, (data.fontSize or self.fontSize) * 1.3)
        end
    end
)
function DYC_MessageBox:SetMessage(str)
    self.messageText:SetText(str)
end
function DYC_MessageBox.ShowMessage(str, title, root, strings, cb, fs, w, h, aw, ah, at)
    local mb =
        root:AddChild(DYC_MessageBox({message = str, title = title, callback = cb, strings = strings, fontSize = fs}))
    if at then
        mb.messageText:AnimateIn()
    end
    if w and h and aw and ah then
        mb:SetSize(aw, ah)
        mb:AnimateSize(w, h, 10)
    elseif w and h then
        mb:SetSize(w, h)
    end
end
dycguis.MessageBox = DYC_MessageBox
local ulcklnk = "unlocklink";
local flnk = "forumlink";
local ulck = "unlock";
local lckd = "locked";
local pli = "playerid";
local vlnk = "VisitURL";
local bdtb = "tieba";
local stm = "steam";
local lnk_b = "https://tieba.baidu.com/f?&kw=yichaodong";
local lnk_s = "https://steamcommunity.com/sharedfiles/filedetails/?id=1207269058";
local lnk_u = "http://www.lofter.com/lpost/1f97e9e0_12dd7bde8";
  

local DYC_CfgMenu =
    Class(
    DYC_Window,
    function(self, data)
        DYC_Window._ctor(self)
        self.strings = data.strings
        self.GHB = data.GHB
        self.GetEntHBColor = data.GetEntHBColor
        self.GetHBStyle = data.GetHBStyle
        self.ShowMessage = data.ShowMessage
        self.hintText =
            self.rootBL:AddChild(
            DYC_Text(
                {font = self.font, fontSize = self.fontSize, color = RGBAColor(1, 1, 0.7, 1), alignH = ANCHOR_LEFT}
            )
        )
        self.hintText:SetPosition(self.paddingX, self.paddingY + self.hintText:GetHeight() / 2 + 10 + 50)
        local closeButton =
            self.rootTR:AddChild(
            DYC_ImageButton(
                {
                    width = 40,
                    height = 40,
                    atlas = "images/dyc_button_close.xml",
                    normal = "dyc_button_close.tex",
                    focus = "dyc_button_close.tex",
                    disabled = "dyc_button_close.tex",
                    colornormal = RGBAColor(1, 1, 1, 1),
                    colorfocus = RGBAColor(1, 0.2, 0.2, 0.7),
                    colordisabled = RGBAColor(0.4, 0.4, 0.4, 1),
                    cb = function()
                        self:Toggle(false)
                    end
                }
            )
        )
        closeButton:SetPosition(-self.paddingX - closeButton.width / 2, -self.paddingY - closeButton.height / 2, 0)
        local applyButton =
            self.rootBR:AddChild(
            DYC_ImageButton(
                {width = 100, height = 50, text = self.strings:GetString("apply"), cb = function()
                        self:DoApply()
                        self:Toggle(false, true)
                    end}
            )
        )
        applyButton:SetPosition(-self.paddingX - applyButton.width / 2, self.paddingY + applyButton.height / 2, 0)
        applyButton.focusFn = function()
            self:ShowHint(self.strings:GetString("hint_apply", ""))
        end
        local flexibleButton =
            self.rootBL:AddChild(
            DYC_ImageButton(
                {width = 100, height = 50, text = self.strings:GetString("more"), cb = function()
                        self:NextPage()
                    end}
            )
        )
        flexibleButton:SetPosition(
            self.paddingX + flexibleButton.width / 2,
            self.paddingY + flexibleButton.height / 2,
            0
        )
        flexibleButton.focusFn = function()
            self:ShowHint(self.strings:GetString("hint_flexible", ""))
        end
        self:SetSize(700, 785)
        self:SetOffset(400, 0, 0)
        self:SetTitle(self.strings:GetString("menu_title") or "SHB Settings", nil, nil, RGBAColor(1, 0.65, 0.55))
        self.pageInfos = {{width = 700, height = 785, animSpeed = 20}, {width = 575, height = 480, animSpeed = 10}}
        self:RefreshPage()
        self.pageChangeFn = function(self, index)
            if index == 1 then
                flexibleButton:SetText(self.strings:GetString("more"))
                if self.title then
                    self:SetTitle(self.strings:GetString("menu_title"))
                end
            else
                flexibleButton:SetText(self.strings:GetString("back"))
                if self.title then
                    self:SetTitle(self.strings:GetString("about"))
                end
            end
        end
        TheInput:AddKeyHandler(
            function(key, down)
                if not down then
                    local tKeyStr = self.hotkeySpinner:GetSelectedData()
                    if tKeyStr and #tKeyStr > 0 and _G[tKeyStr] and _G[tKeyStr] == key then
                        if _G.TheFrontEnd and TheFrontEnd.screenstack and #TheFrontEnd.screenstack > 0 then
                            local screen = TheFrontEnd:GetActiveScreen()
                            if screen and screen.name ~= "HUD" then
                                return
                            end
                        end
                        self:Toggle()
                    end
                end
            end
        )
    end
)
function DYC_CfgMenu:RefreshPage()
    self:ClearPages()
    local strings = self.strings
    local GHB = self.GHB
    local options_gstyle = {
        {text = strings:GetString("standard"), data = "standard"},
        {text = strings:GetString("simple"), data = "simple"},
        {text = strings:GetString("claw"), data = "claw"},
        {text = strings:GetString("shadow"), data = "shadow"},
        {text = strings:GetString("victorian"), data = "victorian"},
        {text = strings:GetString("buckhorn"), data = "buckhorn"},
        {text = strings:GetString("pixel"), data = "pixel"},
        {text = strings:GetString("heart"), data = "heart", hint = "♥♥♥♡♡"},
        {text = strings:GetString("circle"), data = "circle", hint = "●●●○○"},
        {text = strings:GetString("square"), data = "square", hint = "■■■□□"},
        {text = strings:GetString("diamond"), data = "diamond", hint = "◆◆◆◇◇"},
        {text = strings:GetString("star"), data = "star", hint = "★★★☆☆"},
        {text = strings:GetString("basic"), data = "basic", hint = "#####==="},
        {text = strings:GetString("hidden"), data = "hidden"}
    }
    local options_cstyle = {
        {text = strings:GetString("followglobal"), data = "global"},
        {text = strings:GetString("standard"), data = "standard"},
        {text = strings:GetString("simple"), data = "simple"},
        {text = strings:GetString("claw"), data = "claw"},
        {text = strings:GetString("shadow"), data = "shadow"},
        {text = strings:GetString("victorian"), data = "victorian"},
        {text = strings:GetString("buckhorn"), data = "buckhorn"},
        {text = strings:GetString("pixel"), data = "pixel"},
        {text = strings:GetString("heart"), data = "heart", hint = "♥♥♥♡♡"},
        {text = strings:GetString("circle"), data = "circle", hint = "●●●○○"},
        {text = strings:GetString("square"), data = "square", hint = "■■■□□"},
        {text = strings:GetString("diamond"), data = "diamond", hint = "◆◆◆◇◇"},
        {text = strings:GetString("star"), data = "star", hint = "★★★☆☆"},
        {text = strings:GetString("basic"), data = "basic", hint = "#####==="},
        {text = strings:GetString("hidden"), data = "hidden"}
    }
    local options_value = {
        {text = strings:GetString("on"), data = "true"},
        {text = strings:GetString("off"), data = "false"}
    }
    local options_length = {
        {text = "1", data = 1},
        {text = "2", data = 2},
        {text = "3", data = 3},
        {text = "4", data = 4},
        {text = "5", data = 5},
        {text = "6", data = 6},
        {text = "7", data = 7},
        {text = "8", data = 8},
        {text = "9", data = 9},
        {text = "10", data = 10},
        {text = "11", data = 11},
        {text = "12", data = 12},
        {text = "13", data = 13},
        {text = "14", data = 14},
        {text = "15", data = 15},
        {text = "16", data = 16}
    }
    local options_thickness = {
        {text = "50%", data = 0.5, hint = strings:GetString("hint_dynamicthickness")},
        {text = "60%", data = 0.6, hint = strings:GetString("hint_dynamicthickness")},
        {text = "70%", data = 0.7, hint = strings:GetString("hint_dynamicthickness")},
        {text = "80%", data = 0.8, hint = strings:GetString("hint_dynamicthickness")},
        {text = "90%", data = 0.9, hint = strings:GetString("hint_dynamicthickness")},
        {text = "100%", data = 1.0, hint = strings:GetString("hint_dynamicthickness")},
        {text = "110%", data = 1.1, hint = strings:GetString("hint_dynamicthickness")},
        {text = "120%", data = 1.2, hint = strings:GetString("hint_dynamicthickness")},
        {text = "130%", data = 1.3, hint = strings:GetString("hint_dynamicthickness")},
        {text = "140%", data = 1.4, hint = strings:GetString("hint_dynamicthickness")},
        {text = "150%", data = 1.5, hint = strings:GetString("hint_dynamicthickness")},
        {text = "10", data = 10, hint = strings:GetString("hint_fixedthickness")},
        {text = "12", data = 12, hint = strings:GetString("hint_fixedthickness")},
        {text = "14", data = 14, hint = strings:GetString("hint_fixedthickness")},
        {text = "16", data = 16, hint = strings:GetString("hint_fixedthickness")},
        {text = "18", data = 18, hint = strings:GetString("hint_fixedthickness")},
        {text = "20", data = 20, hint = strings:GetString("hint_fixedthickness")},
        {text = "22", data = 22, hint = strings:GetString("hint_fixedthickness")},
        {text = "24", data = 24, hint = strings:GetString("hint_fixedthickness")},
        {text = "26", data = 26, hint = strings:GetString("hint_fixedthickness")},
        {text = "28", data = 28, hint = strings:GetString("hint_fixedthickness")},
        {text = "30", data = 30, hint = strings:GetString("hint_fixedthickness")}
    }
    local options_pos = {
        {text = strings:GetString("bottom"), data = "bottom"},
        {text = strings:GetString("overhead"), data = "overhead"},
        {text = strings:GetString("overhead2"), data = "overhead2", hint = strings:GetString("hint_overhead2")}
    }
    local options_color = {
        {text = strings:GetString("dynamic"), data = "dynamic", hint = strings:GetString("hint_dynamic")},
        {text = strings:GetString("dynamic_dark"), data = "dynamic_dark", hint = strings:GetString("hint_dynamic_dark")},
        {text = strings:GetString("dynamic2"), data = "dynamic2", hint = strings:GetString("hint_dynamic2")},
        {text = strings:GetString("white"), data = "white"},
        {text = strings:GetString("black"), data = "black"},
        {text = strings:GetString("red"), data = "red"},
        {text = strings:GetString("green"), data = "green"},
        {text = strings:GetString("blue"), data = "blue"},
        {text = strings:GetString("yellow"), data = "yellow"},
        {text = strings:GetString("cyan"), data = "cyan"},
        {text = strings:GetString("magenta"), data = "magenta"},
        {text = strings:GetString("gray"), data = "gray"},
        {text = strings:GetString("orange"), data = "orange"},
        {text = strings:GetString("purple"), data = "purple"}
    }
    local options_opacity = {
        {text = "10%", data = 0.1},
        {text = "20%", data = 0.2},
        {text = "30%", data = 0.3},
        {text = "40%", data = 0.4},
        {text = "50%", data = 0.5},
        {text = "60%", data = 0.6},
        {text = "70%", data = 0.7},
        {text = "80%", data = 0.8},
        {text = "90%", data = 0.9},
        {text = "100%", data = 1.0}
    }
    local options_dd = {
        {text = strings:GetString("on"), data = "true"},
        {text = strings:GetString("off"), data = "false"}
    }
    local options_limit = {
        {text = strings:GetString("unlimited"), data = 0},
        {text = "30", data = 30},
        {text = "20", data = 20},
        {text = "10", data = 10},
        {text = "5", data = 5},
        {text = "2", data = 2}
    }
    local options_anim = {
        {text = strings:GetString("on"), data = "true"},
        {text = strings:GetString("off"), data = "false"}
    }
    local options_wallhb = {
        {text = strings:GetString("on"), data = "true"},
        {text = strings:GetString("off"), data = "false"}
    }
    local options_hotkey = {
        {text = strings:GetString("none"), data = ""},
        {text = "H", data = "KEY_H"},
        {text = "J", data = "KEY_J"},
        {text = "K", data = "KEY_K"},
        {text = "L", data = "KEY_L"},
        {text = "F1", data = "KEY_F1"},
        {text = "F2", data = "KEY_F2"},
        {text = "F3", data = "KEY_F3"},
        {text = "F4", data = "KEY_F4"},
        {text = "F5", data = "KEY_F5"},
        {text = "F6", data = "KEY_F6"},
        {text = "F7", data = "KEY_F7"},
        {text = "F8", data = "KEY_F8"},
        {text = "F9", data = "KEY_F9"},
        {text = "F10", data = "KEY_F10"},
        {text = "F11", data = "KEY_F11"},
        {text = "F12", data = "KEY_F12"},
        {text = "INSERT", data = "KEY_INSERT"},
        {text = "DELETE", data = "KEY_DELETE"},
        {text = "HOME", data = "KEY_HOME"},
        {text = "END", data = "KEY_END"},
        {text = "PAGEUP", data = "KEY_PAGEUP"},
        {text = "PAGEDOWN", data = "KEY_PAGEDOWN"}
    }
    local options_icon = {
        {text = strings:GetString("on"), data = "true"},
        {text = strings:GetString("off"), data = "false"}
    }
    local spinnerWidth = 300
    self:NewLine(1.6)
    local gStyleText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_gstyle"), true))
    gStyleText.focusFn = function()
        self:ShowHint(strings:GetString("hint_gstyle", ""))
    end
    self.gStyleSpinner =
        self:AddContent(
        DYC_Spinner(options_gstyle, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.gStyleSpinner.focusFn = function(self2)
        self:ChangePreview(self.GetHBStyle(nil, self2:GetSelectedData()).graphic)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.gStyleSpinner.setSelectedIndexFn = function(self2, idx)
        self2.stlUlckd = true
        self:ChangePreview(self.GetHBStyle(nil, self2:GetSelectedData()).graphic)
        self:ShowHint(self2:GetSelectedHint())
        self2:SetTextColour(1, 1, 1, 1)
        if self.gStyleSpinner.stlUlckd and self.cStyleSpinner.stlUlckd then
            self.ulButton:Hide()
        end
        self:CheckStyle(
            self2:GetSelectedData(),
            function()
                self2.stlUlckd = false
                self2:SetTextColour(0.6, 0, 0, 1)
                self:ShowHint(strings:GetString(lckd, ""))
                self.ulButton:Show()
            end
        )
    end
    self.ulButton =
        self:AddContent(
        DYC_ImageButton(
            {
                width = 70,
                height = self.lineHeight,
                text = strings:GetString(ulck),
                cb = function()
                    local ld = SHB["localData"]
                    ld:GetString(
                        ulcklnk,
                        function(str)
                            _G[vlnk](str or lnk_u)
                        end
                    )
                end
            }
        )
    )
    self.ulButton.focusFn = function()
        self:ShowHint(strings:GetString("hint_" .. ulck, ""))
    end
    self:NewLine()
    local cStyleText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_cstyle"), true))
    cStyleText.focusFn = function()
        self:ShowHint(strings:GetString("hint_cstyle", ""))
    end
    self.cStyleSpinner =
        self:AddContent(
        DYC_Spinner(options_cstyle, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.cStyleSpinner.focusFn = function(self2)
        local style = self2:GetSelectedData()
        style = style ~= "global" and style or self.gStyleSpinner:GetSelectedData()
        self:ChangePreview(self.GetHBStyle(nil, style).graphic)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.cStyleSpinner.setSelectedIndexFn = function(self2, idx)
        self2.stlUlckd = true
        local style = self2:GetSelectedData()
        style = style ~= "global" and style or self.gStyleSpinner:GetSelectedData()
        self:ChangePreview(self.GetHBStyle(nil, style).graphic)
        self:ShowHint(self2:GetSelectedHint())
        self2:SetTextColour(1, 1, 1, 1)
        if self.gStyleSpinner.stlUlckd and self.cStyleSpinner.stlUlckd then
            self.ulButton:Hide()
        end
        self:CheckStyle(
            self2:GetSelectedData(),
            function()
                self2.stlUlckd = false
                self2:SetTextColour(0.6, 0, 0, 1)
                self:ShowHint(strings:GetString(lckd, ""))
                self.ulButton:Show()
            end
        )
    end
    self:NewLine(1.4)
    local previewText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_preview"), true))
    previewText.focusFn = function()
        self:ShowHint(strings:GetString("hint_preview", ""))
    end
    self.ghb =
        self:AddContent(GHB({isDemo = true, basic = {atlas = "images/dyc_white.xml", texture = "dyc_white.tex"}}), 300)
    self:NewLine(1.4)
    local valueText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_value"), true))
    valueText.focusFn = function()
        self:ShowHint(strings:GetString("hint_value", ""))
    end
    self.valueSpinner =
        self:AddContent(
        DYC_Spinner(options_value, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.valueSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.valueSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local lengthText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_length"), true))
    lengthText.focusFn = function()
        self:ShowHint(strings:GetString("hint_length", ""))
    end
    self.lengthSpinner =
        self:AddContent(
        DYC_Spinner(options_length, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.lengthSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.lengthSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local thicknessText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_thickness"), true))
    thicknessText.focusFn = function()
        self:ShowHint(strings:GetString("hint_thickness", ""))
    end
    self.thicknessSpinner =
        self:AddContent(
        DYC_Spinner(options_thickness, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.thicknessSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.thicknessSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local posText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_pos"), true))
    posText.focusFn = function()
        self:ShowHint(strings:GetString("hint_pos", ""))
    end
    self.posSpinner =
        self:AddContent(
        DYC_Spinner(options_pos, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.posSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.posSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local colorText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_color"), true))
    colorText.focusFn = function()
        self:ShowHint(strings:GetString("hint_color", ""))
    end
    self.colorSpinner =
        self:AddContent(
        DYC_Spinner(options_color, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.colorSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.colorSpinner.setSelectedIndexFn = function(self2)
        self:ChangePreviewColor()
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local opacityText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_opacity"), true))
    opacityText.focusFn = function()
        self:ShowHint(strings:GetString("hint_opacity", ""))
    end
    self.opacitySpinner =
        self:AddContent(
        DYC_Spinner(options_opacity, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.opacitySpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.opacitySpinner.setSelectedIndexFn = function(self2)
        self:ChangePreviewColor()
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local ddText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_dd"), true))
    ddText.focusFn = function()
        self:ShowHint(strings:GetString("hint_dd", ""))
    end
    self.ddSpinner =
        self:AddContent(
        DYC_Spinner(options_dd, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.ddSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.ddSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local animText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_anim"), true))
    animText.focusFn = function()
        self:ShowHint(strings:GetString("hint_anim", ""))
    end
    self.animSpinner =
        self:AddContent(
        DYC_Spinner(options_anim, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.animSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.animSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local wallhbText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_wallhb"), true))
    wallhbText.focusFn = function()
        self:ShowHint(strings:GetString("hint_wallhb", ""))
    end
    self.wallhbSpinner =
        self:AddContent(
        DYC_Spinner(options_wallhb, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.wallhbSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.wallhbSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local hotkeyText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_hotkey"), true))
    hotkeyText.focusFn = function()
        self:ShowHint(strings:GetString("hint_hotkey", ""))
    end
    self.hotkeySpinner =
        self:AddContent(
        DYC_Spinner(options_hotkey, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.hotkeySpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.hotkeySpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:NewLine()
    local iconText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_icon"), true))
    iconText.focusFn = function()
        self:ShowHint(strings:GetString("hint_icon", ""))
    end
    self.iconSpinner =
        self:AddContent(
        DYC_Spinner(options_icon, spinnerWidth, self.lineHeight, {font = self.font, size = self.fontSize, false})
    )
    self.iconSpinner.focusFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self.iconSpinner.setSelectedIndexFn = function(self2)
        self:ShowHint(self2:GetSelectedHint())
    end
    self:SetCurrentPage(2)
    self:NewLine(1.6)
    local visitText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("menu_visit"), true))
    visitText.focusFn = function()
        self:ShowHint(strings:GetString("hint_visit", ""))
    end
    self:AddContent(
            DYC_ImageButton(
                {
                    width = 100,
                    height = self.lineHeight,
                    text = strings:GetString(bdtb),
                    cb = function()
                        local ld = SHB["localData"]
                        ld:GetString(
                            flnk,
                            function(str)
                                _G[vlnk](str or lnk_b)
                            end
                        )
                    end
                }
            )
        ).focusFn = function()
        self:ShowHint(strings:GetString("hint_" .. bdtb, ""))
    end
    self:AddContent(
            DYC_ImageButton(
                {width = 100, height = self.lineHeight, text = strings:GetString(stm), cb = function()
                        _G[vlnk](lnk_s)
                    end}
            )
        ).focusFn = function()
        self:ShowHint(strings:GetString("hint_" .. stm, ""))
    end
    self:NewLine()
    self:AddContent(
            DYC_ImageButton(
                {width = 160, height = self.lineHeight, text = strings:GetString("get" .. pli), cb = function()
                        self.ShowMessage(SHB.uid, strings:GetString(pli), nil, 40, 600, 300, 200, 100, true)
                    end}
            )
        ).focusFn = function()
        self:ShowHint(strings:GetString("hint_get" .. pli, ""))
    end
    self:NewLine(1.5)
    self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("abouttext"), true)).focusFn = function()
        self:ShowHint("")
    end
    self:NewLine()
    local modinfo =
        self:AddContent(
        DYC_Text(self.font, self.fontSize, strings:GetString("title") .. "(DST " .. SHB.version .. ")", true)
    )
    modinfo.focusFn = function()
        self:ShowHint(strings:GetString("hint_title", ""))
    end
    self:NewLine()
    local maDebYdyC = self:AddContent(DYC_Text(self.font, self.fontSize, "Copyright (c) 2019 DYC", true))
    maDebYdyC.focusFn = function()
        self:ShowHint(strings:GetString("hint_copyright", "maDe bY dyC"))
    end
    self:NewLine()
    local noModText = self:AddContent(DYC_Text(self.font, self.fontSize, strings:GetString("nomodification"), true))
    noModText.focusFn = function()
        self:ShowHint(strings:GetString("hint_nomodification", ""))
    end
    self:ShowPage(1)
end
local specialList = {
    [1] = "victorian";
    [2] = "buckhorn";
    [3] = "pixel";
}

local checkTimer = 0
local checkTimer2 = 999
local checkTimer3 = 99999
local checkTimerInfo = 999
local gtu = "https://gitee.com/dyc666/ds/raw/master/shbdst";
local pubcode  = "5e34364bfe22df1a24f178fd";
local pubcode2 = "5c5f98187e4c9f0ce454d24e";
local pricode2 = "Tg4aW3HctE2t4po9o25zbATeXzX2WxEUyszqmdY4XFOg";
local ld     = SHB["localData"]
local std    = "standard";
local dhstl  = "DYC_HEALTHBAR_STYLE";
local dhstlc = "DYC_HEALTHBAR_STYLE_CHAR";
local GetUData = function(k, cb)
    if not SHB.uid then
        if cb then
            cb()
        end
        return
    end
    ld:GetString(
        SHB.uid .. k,
        function(str)
            if cb then
                cb(str)
            end
        end
    )
end
function DYC_CfgMenu:CheckStyle(style, noFn)
    GetUData(
        style,
        function(str)
            if not str and TableContains(specialList, style) then
                noFn()
            end
        end
    )
end
function DYC_CfgMenu:CheckGlobals(dt)
    local strings = self.strings
    checkTimer = checkTimer + dt
    if checkTimer > 1 then
        checkTimer = 0
        if TUNING[dhstl] and type(TUNING[dhstl]) == "string" and TableContains(specialList, TUNING[dhstl]) then
            GetUData(
                TUNING[dhstl],
                function(str)
                    if not str then
                        TUNING[dhstl] = std
                    end
                end
            )
        end
        if TUNING[dhstlc] and type(TUNING[dhstlc]) == "string" and TableContains(specialList, TUNING[dhstlc]) then
            GetUData(
                TUNING[dhstlc],
                function(str)
                    if not str then
                        TUNING[dhstlc] = std
                    end
                end
            )
        end
    end
    checkTimer2 = checkTimer2 + dt
    if checkTimer2 > 300 then
        checkTimer2 = 0
        if not self.gt then
            self.gt = SHB["lib"]["GTData"]()
        end
        local gt = self.gt

    end
end
function DYC_CfgMenu:NextPage()
    self:ShowNextPage()
    local info = self.pageInfos[self.currentPageIndex]
    if info then
        self:AnimateSize(info.width, info.height, info.animSpeed or 20)
    end
    self:ShowHint()
end
function DYC_CfgMenu:ChangePreview(graphicData)
    if not self.ghb then
        return
    end
    if graphicData and not self.ghb.shown then
        self.ghb:Show()
    elseif not graphicData and self.ghb.shown then
        self.ghb:Hide()
    end
    if graphicData then
        self.ghb:SetData(graphicData)
        self.ghb:SetHBSize(210, 32)
        self.ghb:SetOpacity(graphicData.opacity or 0.8)
        self:ChangePreviewColor()
        if self.animSpinner:GetSelectedData() == "true" then
            self.ghb:AnimateIn(10)
        end
    end
    if not self.ghb.onSetPercentage then
        self.ghb.onSetPercentage = function()
            self:ChangePreviewColor()
        end
    end
end
function DYC_CfgMenu:ChangePreviewColor()
    if not self.ghb then
        return
    end
    self.ghb:SetBarColor(self.GetEntHBColor({hpp = self.ghb.percentage, info = self.colorSpinner:GetSelectedData()}))
    self.ghb:SetOpacity(self.opacitySpinner:GetSelectedData())
end
function DYC_CfgMenu:ShowHint(str)
    str = str or ""
    self.hintText:SetText(str)
    self.hintText:AnimateIn()
end
function DYC_CfgMenu:DoApply()
    if self.applyFn then
        self.applyFn(
            self,
            {
                menu = self,
                gstyle = self.gStyleSpinner:GetSelectedData(),
                cstyle = self.cStyleSpinner:GetSelectedData(),
                value = self.valueSpinner:GetSelectedData(),
                length = self.lengthSpinner:GetSelectedData(),
                thickness = self.thicknessSpinner:GetSelectedData(),
                pos = self.posSpinner:GetSelectedData(),
                color = self.colorSpinner:GetSelectedData(),
                opacity = self.opacitySpinner:GetSelectedData(),
                dd = self.ddSpinner:GetSelectedData(),
                anim = self.animSpinner:GetSelectedData(),
                wallhb = self.wallhbSpinner:GetSelectedData(),
                hotkey = self.hotkeySpinner:GetSelectedData(),
                icon = self.iconSpinner:GetSelectedData()
            }
        )
    end
end
function DYC_CfgMenu:Toggle(b, isOK, ...)
    DYC_CfgMenu._base.Toggle(self, b, isOK, ...)
end
function DYC_CfgMenu:OnUpdate(dt)
    DYC_CfgMenu._base.OnUpdate(self, dt)
    dt = dt or 0
    self:CheckGlobals(dt)
end
dycguis.CfgMenu = DYC_CfgMenu


logger.log(_M._path, "guis end")
return dycguis
