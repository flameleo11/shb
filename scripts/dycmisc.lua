local lib = {}
local Clamp = function(num, min, max)
    assert(max >= min, "max needs to be larger than min!")
    return math.min(math.max(num, min), max)
end
lib.Clamp = Clamp
local Clamp01 = function(num)
    return math.min(math.max(num, 0), 1)
end
lib.Clamp01 = Clamp01
local Round = function(num)
    return math.floor(num + 0.5)
end
lib.Round = Round
local Lerp = function(n1, n2, p)
    return (n2 - n1) * p + n1
end
lib.Lerp = Lerp
local TableCount = function(t)
    local c = 0
    for k, v in pairs(t) do
        c = c + 1
    end
    return c
end
lib.TableCount = TableCount
local TableContains = function(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end
lib.TableContains = TableContains
local TableAdd = function(t, value)
    if not TableContains(t, value) then
        table.insert(t, value)
    end
end
lib.TableAdd = TableAdd
local TableGetIndex = function(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
end
lib.TableGetIndex = TableGetIndex
local TableRemoveValue = function(t, value)
    local index = TableGetIndex(t, value)
    if index then
        table.remove(t, index)
    end
end
lib.TableRemoveValue = TableRemoveValue
local function StringStartWith(str, key)
    if str == nil or key == nil then
        return false
    end
    return string.sub(str, 1, #key) == key
end
lib.StringStartWith = StringStartWith
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
lib.StrSpl = StrSpl
local NewDrml = function()
    return {
        urlD = "http://dreamlo.com/lb/",
        mode = "",
        content = "",
        data = {},
        ReadAsync = function(self, publicCode, callback, name)
            if name == nil then
                return
            end
            self:Clear()
            self.mode = "read"
            local url = self.urlD .. publicCode .. "/pipe-get/" .. name
            TheSim:QueryServer(
                url,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and string.len(result) > 1 then
                        self.content = result
                        if string.len(result) > 5 then
                            local lineitems = StrSpl(result, "|")
                            if #lineitems > 5 then
                                self.data[lineitems[1]] = {}
                                self.data[lineitems[1]].text = self:D2T(lineitems[4]) or ""
                                self.data[lineitems[1]].score = tonumber(lineitems[2]) or 0
                                self.data[lineitems[1]].seconds = tonumber(lineitems[3]) or 0
                                self.data[lineitems[1]].date = lineitems[5] or ""
                                self.data[lineitems[1]].index = tonumber(lineitems[6]) or 0
                            elseif #lineitems == 5 then
                                self.data[lineitems[1]] = {}
                                self.data[lineitems[1]].text = ""
                                self.data[lineitems[1]].score = tonumber(lineitems[2]) or 0
                                self.data[lineitems[1]].seconds = tonumber(lineitems[3]) or 0
                                self.data[lineitems[1]].date = lineitems[4] or ""
                                self.data[lineitems[1]].index = tonumber(lineitems[5]) or 0
                            end
                        end
                    end
                    if callback then
                        callback(self, isSuccessful)
                    end
                end,
                "GET"
            )
        end,
        ReadAllAsync = function(self, publicCode, callback)
            self:Clear()
            self.mode = "read"
            local url = self.urlD .. publicCode .. "/pipe"
            TheSim:QueryServer(
                url,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and string.len(result) > 1 then
                        result = string.gsub(result, "\r", "")
                        self.content = result
                        local lines = StrSpl(result, "\n")
                        if #lines < 1 then
                            if callback then
                                callback(self, isSuccessful)
                            end
                            return
                        end
                        for k, v in pairs(lines) do
                            if string.len(v) > 5 then
                                local lineitems = StrSpl(v, "|")
                                if #lineitems > 5 then
                                    self.data[lineitems[1]] = {}
                                    self.data[lineitems[1]].text = self:D2T(lineitems[4]) or ""
                                    self.data[lineitems[1]].score = tonumber(lineitems[2]) or 0
                                    self.data[lineitems[1]].seconds = tonumber(lineitems[3]) or 0
                                    self.data[lineitems[1]].date = lineitems[5] or ""
                                    self.data[lineitems[1]].index = tonumber(lineitems[6]) or 0
                                elseif #lineitems == 5 then
                                    self.data[lineitems[1]] = {}
                                    self.data[lineitems[1]].text = ""
                                    self.data[lineitems[1]].score = tonumber(lineitems[2]) or 0
                                    self.data[lineitems[1]].seconds = tonumber(lineitems[3]) or 0
                                    self.data[lineitems[1]].date = lineitems[4] or ""
                                    self.data[lineitems[1]].index = tonumber(lineitems[5]) or 0
                                end
                            end
                        end
                    end
                    if callback then
                        callback(self, isSuccessful)
                    end
                end,
                "GET"
            )
        end,
        WriteAsync = function(self, privateCode, callback, name, score, seconds, text)
            if name == nil then
                return
            end
            score = score or 0
            seconds = seconds or 0
            text = text or ""
            self:Clear()
            self.mode = "write"
            local url =
                self.urlD .. privateCode .. "/add/" .. name .. "/" .. score .. "/" .. seconds .. "/" .. self:T2D(text)
            TheSim:QueryServer(
                url,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and string.len(result) > 1 then
                        result = string.gsub(result, "\r", "")
                        self.content = result
                    end
                    if callback then
                        callback(self, isSuccessful)
                    end
                end,
                "GET"
            )
        end,
        D2T = function(self, str)
            str = str or self
            str = string.gsub(str, "%^c%$", ":")
            str = string.gsub(str, "%^s%$", "/")
            str = string.gsub(str, "%^q%$", "%?")
            str = string.gsub(str, "%^e%$", "=")
            str = string.gsub(str, "%^a%$", "&")
            str = string.gsub(str, "%^p%$", "%%")
            str = string.gsub(str, "%^m%$", "%*")
            str = string.gsub(str, "%^v%$", "|")
            str = string.gsub(str, "%^o%$", "#")
            str = string.gsub(str, "%^s2%$", "\\")
            str = string.gsub(str, "%^g%$", ">")
            str = string.gsub(str, "%^l%$", "<")
            str = string.gsub(str, "%^n%$", "\r\n")
            str = string.gsub(str, "%^t%$", "\t")
            return str
        end,
        T2D = function(self, str)
            str = str or self
            str = string.gsub(str, "\r", "")
            str = string.gsub(str, ":", "%^c%$")
            str = string.gsub(str, "/", "%^s%$")
            str = string.gsub(str, "%?", "%^q%$")
            str = string.gsub(str, "=", "%^e%$")
            str = string.gsub(str, "&", "%^a%$")
            str = string.gsub(str, "%%", "%^p%$")
            str = string.gsub(str, "%*", "%^m%$")
            str = string.gsub(str, "|", "%^v%$")
            str = string.gsub(str, "#", "%^o%$")
            str = string.gsub(str, "\\", "%^s2%$")
            str = string.gsub(str, ">", "%^g%$")
            str = string.gsub(str, "<", "%^l%$")
            str = string.gsub(str, "\n", "%^n%$")
            str = string.gsub(str, "\t", "%^t%$")
            return str
        end,
        IsResultOK = function(self)
            if self.mode == "write" then
                return self.content ~= nil and string.find(self.content, "OK") ~= nil
            else
                return self.content ~= nil and string.len(self.content) > 0
            end
        end,
        Clear = function(self)
            self.content = ""
            self.data = {}
            self.mode = ""
        end
    }
end
lib.NewDrml = NewDrml
local GTData = function()
    return {
        content = "",
        data = {},
        ReadAllAsync = function(self, url, callback)
            self:Clear()
            local url = url
            TheSim:QueryServer(
                url,
                function(result, isSuccessful, resultCode)
                    if isSuccessful and string.len(result) > 1 then
                        result = string.gsub(result, "\r", "")
                        self.content = result
                        local lines = StrSpl(result, "\n")
                        if #lines < 1 then
                            if callback then
                                callback(self, isSuccessful)
                            end
                            return
                        end
                        for k, v in pairs(lines) do
                            if string.len(v) > 2 then
                                v = string.gsub(v, "\t", "|")
                                local lineitems = StrSpl(v, "|")
                                if #lineitems > 1 then
                                    self.data[lineitems[1]] = {}
                                    self.data[lineitems[1]].text = lineitems[2] or ""
                                    if string.len(lineitems[2]) > 1 then
                                        local textitems = StrSpl(lineitems[2], ",")
                                        if #textitems > 0 then
                                            for k2, v2 in pairs(textitems) do
                                                if string.len(v2) > 2 then
                                                    local textkv = StrSpl(v2, "-")
                                                    if #textkv > 1 then
                                                        self.data[lineitems[1]][textkv[1]] = textkv[2]
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if callback then
                        callback(self, isSuccessful)
                    end
                end,
                "GET"
            )
        end,
        Clear = function(self)
            self.content = ""
            self.data = {}
        end
    }
end
lib.GTData = GTData
local LocalData = function()
    return {
        path = "mod_config_data/",
        name = "dyc",
        SetName = function(self, str)
            self.name = str
        end,
        SetString = function(self, key, str)
            TheSim:SetPersistentString(
                self.path .. self.name .. "_" .. key,
                str,
                ENCODE_SAVES,
                function(isSuccessful, str)
                end
            )
        end,
        GetString = function(self, key, cb)
            TheSim:GetPersistentString(
                self.path .. self.name .. "_" .. key,
                function(isSuccessful, str)
                    if cb then
                        cb(isSuccessful and str)
                    end
                end
            )
        end,
        EraseString = function(self, key)
            TheSim:ErasePersistentString(
                self.path .. self.name .. "_" .. key,
                function(isSuccessful)
                end
            )
        end
    }
end
lib.LocalData = LocalData
return lib
