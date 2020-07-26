local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local RGBAColor = function(r, g, b, a)
    return {r = r or 1, g = g or 1, b = b or 1, a = a or 1, Get = function(self)
            return self.r, self.g, self.b, self.a
        end, Set = function(self, r2, g2, b2, a2)
            self.r = r2 or 1
            self.g = g2 or 1
            self.b = b2 or 1
            self.a = a2 or 1
        end}
end
local Clamp01 = function(num)
    return math.min(math.max(num, 0), 1)
end
local Lerp = function(a, b, p)
    return a + (b - a) * p
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
local DYC_TextHealthbar =
    Class(
    Widget,
    function(self, data)
        Widget._ctor(self, "DYC_TextHealthbar")
        self.text = self:AddChild(Text(NUMBERFONT, 20, ""))
        self.c1 = data.c1 or "="
        self.c2 = data.c2 or "#"
        self.cnum = data.cnum or 10
        self.numCoeff = data.numCoeff or 1
        self.percentage = 1
        self.fontSize = data.fontSize or 20
        self.hbScale = data.hbScale or 1
        self:SetPercentage()
        self:SetHBScale()
        if data.color then
            self:SetTextColor(data.color)
        end
    end
)
function DYC_TextHealthbar:SetStrings(c1, c2, cnum)
    c1 = c1 or self.c1
    c2 = c2 or self.c2
    cnum = cnum or self.cnum
    cnum = math.max(1, cnum)
    self.c1 = c1
    self.c2 = c2
    self.cnum = cnum
    self:SetPercentage()
end
function DYC_TextHealthbar:SetLength(cnum)
    cnum = cnum or self.cnum
    self.cnum = cnum
    self:SetPercentage()
end
function DYC_TextHealthbar:SetPercentage(p)
    p = p or self.percentage
    p = math.max(0, math.min(p, 1))
    self.percentage = p
    local c1 = self.c1
    local c2 = self.c2
    local cnum = self.cnum * self.numCoeff
    local str = ""
    for i = 1, cnum do
        if p == 0 or (i ~= 1 and i * 1.0 / cnum > p) then
            str = str .. c1
        else
            str = str .. c2
        end
    end
    self.text:SetString(str)
end
function DYC_TextHealthbar:SetFontSize(fs)
    fs = fs or self.fontSize
    self.fontSize = fs
    self.text:SetSize(self.fontSize * self.hbScale)
end
function DYC_TextHealthbar:SetHBScale(s)
    s = s or self.hbScale
    self.hbScale = s
    self:SetFontSize()
end
function DYC_TextHealthbar:SetColor(r, g, b, a)
    r = r or 1
    g = g or 1
    b = b or 1
    a = a or 1
    if type(r) == "table" then
        r.r = r.r or r.x or r[1] or 1
        r.g = r.g or r.y or r[2] or 1
        r.b = r.b or r.z or r[3] or 1
        r.a = r.a or r[1] or 1
        self.text:SetColour(r.r, r.g, r.b, r.a)
    else
        self.text:SetColour(r, g, b, a)
    end
end
local DYC_GraphicHealthbar =
    Class(
    Widget,
    function(self, data)
        Widget._ctor(self, "DYC_GraphicHealthbar")
        self:SetScaleMode(data.isDemo and SCALEMODE_NONE or SCALEMODE_PROPORTIONAL)
        self:SetMaxPropUpscale(999)
        self.worldOffset = Vector3(0, 0, 0)
        self.screen_offset = Vector3(0, 0, 0)
        self.isDemo = data.isDemo
        self.bg = self:AddChild(Image(data.basic.atlas, data.basic.texture))
        self.bg:SetClickable(self.isDemo or false)
        self.bg2 = self:AddChild(Image(data.basic.atlas, data.basic.texture))
        self.bg2:SetClickable(self.isDemo or false)
        self.text = self:AddChild(Text(NUMBERFONT, 20, ""))
        self.healthReductions = {}
        self.style = "textonbar"
        self.showBg = true
        self.showBg2 = true
        self.showValue = true
        self.hp = 100
        self.hpMax = 100
        self.percentage = 1
        self.opacity = 1
        self.hbScale = 1
        self.hbYOffset = 0
        self.hbWidth = 120
        self.hbHeight = 18
        self.barMargin = {x1 = 3, x2 = 3, y1 = 3, y2 = 3, fixed = true}
        self.fontSize = 20
        self.hrDuration = 0.8
        self.screenWidth = 1920
        self.screenHeight = 1080
        self.bgColor = RGBAColor(1, 1, 1)
        self.bg2Color = RGBAColor(0, 0, 0)
        self.barColor = RGBAColor(1, 1, 1)
        self.hrColor = RGBAColor(1, 1, 1)
        self.preUpdateFn = nil
        self.onSetPercentage = nil
        self:SetData(data)
        self:SetOpacity()
        self:SetHBSize(120, 18)
        self:SetFontSize(20)
        self:StartUpdating()
        self:AddToTable()
    end
)
DYC_GraphicHealthbar.ghbs = {}
function DYC_GraphicHealthbar:AddToTable()
    TableAdd(DYC_GraphicHealthbar.ghbs, self)
end
function DYC_GraphicHealthbar:SetData(data)
    self.data = data
    self.basicAtlas = data.basic.atlas
    self.basicTex = data.basic.texture
    self.bgAtlas = data.bg and data.bg.atlas
    self.bgTex = data.bg and data.bg.texture
    self.barAtlas = data.bar and data.bar.atlas
    self.barTex = data.bar and data.bar.texture
    self:SetBgSkn(data.bgSkn)
    self:SetBarSkn(data.barSkn)
end
function DYC_GraphicHealthbar:SetBgTexture(atlas, tex)
    self.bg:SetTexture(atlas, tex)
    self.bg2:SetTexture(atlas, tex)
end
function DYC_GraphicHealthbar:SetBgSkn(data)
    self.bgSknData = data or nil
    if self.bgSkn then
        self.bgSkn:Kill()
        self.bgSkn = nil
    end
    if self.bgSknData then
        self.bgSkn = self:AddChild(DYC_SlicedImage(self.bgSknData))
        self.bgSkn:SetClickable(self.isDemo or false)
        self.bgSkn:MoveToBack()
        self.showBg = false
    else
        self:SetBgTexture(self.bgAtlas or self.basicAtlas, self.bgTex or self.basicTex)
        self.showBg = true
    end
    if self.data and (self.data.bg2 or not self.data.bg) then
        self.showBg2 = true
    else
        self.showBg2 = false
    end
    self.bgColor = self.data and self.data.bg and self.data.bg.color or RGBAColor(1, 1, 1)
    self.bg2Color = self.data and self.data.bg2 and self.data.bg2.color or RGBAColor(0, 0, 0)
end
function DYC_GraphicHealthbar:SetBarSkn(data)
    self.barSknData = data or nil
    if self.bar then
        self.bar:Kill()
        self.bar = nil
    end
    if self.barSknData then
        self.bar = self:AddChild(DYC_SlicedImage(self.barSknData))
        self.bar:SetClickable(self.isDemo or false)
        self.bar:MoveToFront()
        self.text:MoveToFront()
    else
        self.bar = self:AddChild(Image(self.barAtlas or self.basicAtlas, self.barTex or self.basicTex))
        self.bar:SetClickable(self.isDemo or false)
        self.bar:MoveToFront()
        self.text:MoveToFront()
    end
end
function DYC_GraphicHealthbar:SetBarTexture(atlas, tex)
    if self.bar.SetTexture then
        self.bar:SetTexture(atlas, tex)
    end
end
function DYC_GraphicHealthbar:SetValue(current, max, noDR)
    self.hp = current or self.hp
    self.hpMax = max or self.hpMax
    self.text:SetString(string.format("%d/%d", current, max))
    self:SetPercentage(current / max, noDR)
end
function DYC_GraphicHealthbar:SetYOffSet(h, useHBScale)
    h = h or self.hbYOffset
    self.hbYOffset = h
    local screenScale = self.screenWidth / 1920
    self:SetScreenOffset(-5 * screenScale, self.hbYOffset * (useHBScale and self.hbScale or 1) * screenScale)
end
function DYC_GraphicHealthbar:SetPercentage(p, noDR)
    local oldP = self.percentage
    p = p or self.percentage
    p = math.max(0, math.min(p, 1))
    if oldP - p > 0.01 and not noDR and self.shown then
        self:DisplayHealthReduction(oldP, p)
    end
    self.percentage = p
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local barW, barH = self:GetBarFullSize()
    local barVW, barVH = self:GetBarVirtualSize()
    local actualBarW = barW - barVW * (1 - p)
    local ox, oy = self:GetBarOffset()
    self.bar:SetSize(actualBarW, barH)
    self.bar:SetPosition(-(barW - actualBarW) / 2 + ox, oy, 0)
    if self.textHealthBar then
        self.textHealthBar:SetPercentage(p)
    end
    if self.onSetPercentage then
        self.onSetPercentage(self, p)
    end
end
function DYC_GraphicHealthbar:SetHBSize(w, h)
    w = w or self.hbWidth
    h = h or self.hbHeight
    w = math.max(w, 0)
    h = math.max(h, 0)
    self.hbWidth = w
    self.hbHeight = h
    w = w * self.hbScale
    h = h * self.hbScale
    self.bg:SetSize(w, h)
    self.bg2:SetSize(math.max(w - 2, 0), math.max(h - 2, 0))
    if self.bgSknData and self.bgSkn then
        local bgw, bgh = self:GetBgSknSize()
        self.bgSkn:SetSize(bgw, bgh)
        local ox, oy = self:GetBgOffset()
        self.bgSkn:SetPosition(ox, oy, 0)
    end
    self:SetPercentage()
    self:SetYOffSet()
    if self.textHealthBar then
        self.textHealthBar:SetFontSize(self.hbHeight * 1)
    end
end
function DYC_GraphicHealthbar:SetFontSize(fs)
    fs = fs or self.fontSize
    self.fontSize = fs
    self.text:SetSize(self.fontSize * self.hbScale)
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    if self.style == "textoverbar" then
        self.text:SetPosition(0, h / 2 + self.fontSize * self.hbScale * 0.35, 0)
    elseif self.style == "barovertext" then
        self.text:SetPosition(0, -h / 2 - self.fontSize * self.hbScale * 0.35, 0)
    else
        self.text:SetPosition(0, 0, 0)
    end
end
function DYC_GraphicHealthbar:SetHBScale(s)
    s = s or self.hbScale
    self.hbScale = s
    self:SetHBSize()
    self:SetFontSize()
    if self.textHealthBar then
        self.textHealthBar:SetHBScale(s)
    end
end
function DYC_GraphicHealthbar:SetStyle(style)
    style = style or self.style
    if style == self.style then
        return
    end
    self.style = style
    self:SetFontSize()
end
function DYC_GraphicHealthbar:SetOpacity(a)
    a = a or self.opacity
    self.opacity = a
    local c = self.bgColor
    self.bg:SetTint(c.r, c.g, c.b, self.showBg and a or 0)
    c = self.bg2Color
    self.bg2:SetTint(c.r, c.g, c.b, self.showBg and self.showBg2 and a or 0)
    c = self.barColor
    self.bar:SetTint(c.r, c.g, c.b, a)
    if self.bgSkn then
        self.bgSkn:SetTint(1, 1, 1, a)
    end
end
function DYC_GraphicHealthbar:SetBarColor(r, g, b)
    r = r or 1
    g = g or 1
    b = b or 1
    if type(r) == "table" then
        self.barColor.r = r.r or r.x or r[1] or 1
        self.barColor.g = r.g or r.y or r[2] or 1
        self.barColor.b = r.b or r.z or r[3] or 1
    else
        self.barColor.r = r
        self.barColor.g = g
        self.barColor.b = b
    end
    self:SetOpacity()
    if self.textHealthBar then
        self.textHealthBar:SetColor(r, g, b)
    end
end
function DYC_GraphicHealthbar:SetTextColor(r, g, b, a)
    r = r or 1
    g = g or 1
    b = b or 1
    a = a or 1
    if type(r) == "table" then
        r.r = r.r or r.x or r[1] or 1
        r.g = r.g or r.y or r[2] or 1
        r.b = r.b or r.z or r[3] or 1
        r.a = r.a or r[1] or 1
        self.text:SetColour(r.r, r.g, r.b, r.a)
    else
        self.text:SetColour(r, g, b, a)
    end
end
function DYC_GraphicHealthbar:DisplayHealthReduction(oldP, newP)
    local hr = self.bg2:AddChild(Image(self.basicAtlas, self.basicTex))
    hr:SetClickable(self.isDemo or false)
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local w2, h2 = self:GetBarVirtualSize()
    local actualBarW = w2 * math.max(0, oldP - newP)
    local posX = ((newP + oldP) / 2 - 0.5) * w2
    local ox, oy = self:GetBarVirtualOffset()
    local c = self.data and self.data.hrUseBarColor and self.barColor or self.hrColor
    hr:SetSize(actualBarW, h2)
    hr:SetPosition(posX + ox, oy, 0)
    hr:SetTint(c.r, c.g, c.b, self.opacity)
    hr.fadeTimer = self.hrDuration
    table.insert(self.healthReductions, hr)
end
function DYC_GraphicHealthbar:AnimateIn(speed)
    self.animHBWidth = self.hbWidth
    self.animIn = true
    self.animSpeed = speed or 5
    self:SetHBSize(0, self.hbHeight)
end
function DYC_GraphicHealthbar:AnimateOut(speed)
    self.animHBWidth = 0
    self.animOut = true
    self.animSpeed = speed or 5
end
function DYC_GraphicHealthbar:Kill()
    TableRemoveValue(DYC_GraphicHealthbar.ghbs, self)
    Widget.Kill(self)
end
function DYC_GraphicHealthbar:OnMouseButton(button, down, x, y, ...)
    local returnValue = DYC_GraphicHealthbar._base.OnMouseButton(self, button, down, x, y, ...)
    if not down and button == MOUSEBUTTON_LEFT then
        self.dragging = false
    end
    if not self.focus then
        return false
    end
    if self.isDemo and down and button == MOUSEBUTTON_LEFT then
        self.dragging = true
    end
    return returnValue
end
function DYC_GraphicHealthbar:GetSize()
    return self.bg:GetSize()
end
function DYC_GraphicHealthbar:GetBgMargin()
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local margin =
        self.bgSknData and self.bgSknData.margin or (self.data and self.data.bg and self.data.bg.margin) or
        {x1 = 0, x2 = 0, y1 = 0, y2 = 0}
    local mx1 = margin.fixed and margin.x1 or margin.x1 * h
    local mx2 = margin.fixed and margin.x2 or margin.x2 * h
    local my1 = margin.fixed and margin.y1 or margin.y1 * h
    local my2 = margin.fixed and margin.y2 or margin.y2 * h
    return mx1, mx2, my1, my2
end
function DYC_GraphicHealthbar:GetBarMargin()
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local margin =
        self.barSknData and self.barSknData.margin or (self.data and self.data.bar and self.data.bar.margin) or
        self.barMargin
    local mx1 = margin.fixed and margin.x1 or margin.x1 * h
    local mx2 = margin.fixed and margin.x2 or margin.x2 * h
    local my1 = margin.fixed and margin.y1 or margin.y1 * h
    local my2 = margin.fixed and margin.y2 or margin.y2 * h
    return mx1, mx2, my1, my2
end
function DYC_GraphicHealthbar:GetBarVirtualMargin()
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local vmargin =
        self.barSknData and self.barSknData.vmargin or (self.data and self.data.bar and self.data.bar.vmargin) or
        (self.barSknData and self.barSknData.margin) or
        (self.data and self.data.bar and self.data.bar.margin) or
        self.barMargin
    local px1 = vmargin.fixed and vmargin.x1 or vmargin.x1 * h
    local px2 = vmargin.fixed and vmargin.x2 or vmargin.x2 * h
    local py1 = vmargin.fixed and vmargin.y1 or vmargin.y1 * h
    local py2 = vmargin.fixed and vmargin.y2 or vmargin.y2 * h
    return px1, px2, py1, py2
end
function DYC_GraphicHealthbar:GetBgOffset()
    local mx1, mx2, my1, my2 = self:GetBgMargin()
    return (mx1 - mx2) / 2, (my1 - my2) / 2
end
function DYC_GraphicHealthbar:GetBarOffset()
    local mx1, mx2, my1, my2 = self:GetBarMargin()
    return (mx1 - mx2) / 2, (my1 - my2) / 2
end
function DYC_GraphicHealthbar:GetBarVirtualOffset()
    local px1, px2, py1, py2 = self:GetBarVirtualMargin()
    return (px1 - px2) / 2, (py1 - py2) / 2
end
function DYC_GraphicHealthbar:GetBgSknSize()
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local mx1, mx2, my1, my2 = self:GetBgMargin()
    return math.max(w - mx1 - mx2, 2), math.max(h - my1 - my2, 2)
end
function DYC_GraphicHealthbar:GetBarFullSize()
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local mx1, mx2, my1, my2 = self:GetBarMargin()
    return math.max(w - mx1 - mx2, 2), math.max(h - my1 - my2, 2)
end
function DYC_GraphicHealthbar:GetBarVirtualSize()
    local w, h = self:GetSize()
    w = w or 1
    h = h or 1
    local px1, px2, py1, py2 = self:GetBarVirtualMargin()
    return math.max(w - px1 - px2, 0), math.max(h - py1 - py2, 0)
end
function DYC_GraphicHealthbar:SetTarget(target)
    self.target = target
    self:OnUpdate()
end
function DYC_GraphicHealthbar:SetWorldOffset(offset)
    self.worldOffset = offset
    self:OnUpdate()
end
function DYC_GraphicHealthbar:SetScreenOffset(x, y)
    self.screen_offset.x = x
    self.screen_offset.y = y
    self:OnUpdate()
end
function DYC_GraphicHealthbar:GetScreenOffset()
    return self.screen_offset.x, self.screen_offset.y
end
function DYC_GraphicHealthbar:OnUpdate(dt)
    dt = dt or 0
    if self.target and self.target:IsValid() then
        if self.preUpdateFn then
            self.preUpdateFn(dt)
        end
        local world_pos = nil
        if self.target.AnimState then
            world_pos =
                Vector3(
                self.target.AnimState:GetSymbolPosition(
                    self.symbol or "",
                    self.worldOffset.x,
                    self.worldOffset.y,
                    self.worldOffset.z
                )
            )
        else
            world_pos = self.target:GetPosition()
        end
        if world_pos then
            local screen_pos = Vector3(TheSim:GetScreenPos(world_pos:Get()))
            screen_pos.x = screen_pos.x + self.screen_offset.x
            screen_pos.y = screen_pos.y + self.screen_offset.y
            self:SetPosition(screen_pos)
        end
    end
    if self.animOut and dt > 0 then
        if math.abs(self.hbWidth - self.animHBWidth) < 3 then
            self.animOut = false
            self:SetHBSize(self.animHBWidth, self.hbHeight)
            self:Kill()
            return
        else
            self:SetHBSize(Lerp(self.hbWidth, self.animHBWidth, self.animSpeed * dt), self.hbHeight)
        end
    elseif self.animIn and dt > 0 then
        if math.abs(self.hbWidth - self.animHBWidth) < 1 then
            self.animIn = false
            self:SetHBSize(self.animHBWidth, self.hbHeight)
        else
            self:SetHBSize(Lerp(self.hbWidth, self.animHBWidth, self.animSpeed * dt), self.hbHeight)
        end
    end
    local hrs = self.healthReductions
    if #hrs > 0 and dt > 0 then
        for i = #hrs, 1, -1 do
            local hr = hrs[i]
            hr.fadeTimer = hr.fadeTimer - dt
            if hr.fadeTimer < 0 then
                table.remove(hrs, i)
                hr:Kill()
                break
            end
            local c = self.data and self.data.hrUseBarColor and self.barColor or self.hrColor
            hr:SetTint(c.r, c.g, c.b, self.opacity * hr.fadeTimer / self.hrDuration)
        end
    end
    if self.showValue and not self.text.shown then
        self.text:Show()
    elseif not self.showValue and self.text.shown then
        self.text:Hide()
    end
    local sw, sh = TheSim:GetScreenSize()
    if sw ~= self.screenWidth or sh ~= self.screenHeight then
        self.screenWidth = sw
        self.screenHeight = sh
        self:SetYOffSet()
    end
    if self.isDemo and self.dragging and dt > 0 then
        local scale = self:GetScale()
        local x, y = TheInput:GetScreenPosition():Get()
        local pos = self:GetWorldPosition()
        local barW, barH = self:GetBarVirtualSize()
        barW = barW * scale.x
        barH = barH * scale.y
        local ox, oy = self:GetBarVirtualOffset()
        ox = ox * scale.x
        oy = oy * scale.y
        local p = (x - (pos.x + ox) + barW / 2) / barW
        self:SetPercentage(p, true)
        if not self.focus then
            self.dragging = false
        end
    end
end
return DYC_GraphicHealthbar
