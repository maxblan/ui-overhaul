--- Guarded react-replacement-config hooks (installer_early.res.lua, installer_late.res.lua); the
-- implementation is installer.lua. If it fails to load, nothing is installed and the game stays vanilla.
local guard = require("/ui_overhaul/gui/guard.lua")

-- how far the game got, for a crash while it loads (issue #7): the scripts load before any config runs;
-- in pcall, in case a Lua state that loads this file (the mod validator) has no debugPrint
pcall(function() debugPrint("[ui_overhaul] installer script loaded") end)

local INSTALLER = "ui_overhaul_1::/ui_overhaul/gui/installer.lua"

local stub = {}

---@param replacement_api react.ReplacementApi
function stub.early(replacement_api)
	-- before installer.lua and its modules load (issue #7)
	debugPrint("[ui_overhaul] early config")
	guard.call(INSTALLER, "early", function() return nil end, replacement_api)
end

---@param replacement_api react.ReplacementApi
function stub.late(replacement_api)
	guard.call(INSTALLER, "late", function() return nil end, replacement_api)
end

-- The engine loads *.script.lua resources by calling data().
---@return table
function data()
	return stub
end

return stub
