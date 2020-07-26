local require = GLOBAL.require
local modinit = require("modinit")
local mod = modinit("simple_health_bar")

local print = trace;
local import = _G.import;
local eventmgr = import("events")()

local inited = nil

local logger = import("log");
logger.log(_M._path, "modmain.start")

local regtime = GetTime()

xpcall(function ()
	logger.log(_M._path, "mod.import main.lua")
	mod.import("main")
end, print)



trace("[mod] simple_health_bar ....... init ok")
logger.log(_M._path, "modmain.end")


--[[
import("log").debug()
]]