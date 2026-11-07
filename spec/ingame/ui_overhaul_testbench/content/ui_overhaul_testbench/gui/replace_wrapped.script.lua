--- Stands in for a mod that replaces a recipe it reads from a module field UI Overhaul wraps
-- (Don't Auto Pin: "table index is nil" at startup, mod.io report on revision 4). Here the field is
-- popover_react_util.PopoverWindowContent, which UI Overhaul's terminal popover wraps; the
-- replacement puts the popover in a box with the id "probe.replaced_popover" and calls the original
-- by the field's function, as such mods do. Only in a run whose --only names replace_wrapped_recipe,
-- so the other checks see the popover as it is.
-- @module ui_overhaul_testbench.gui.replace_wrapped
local fixture = require("/ui_overhaul_testbench/fixture.lua")

local replace_wrapped = {}

---@return boolean
local function wanted()
	for _i, name in ipairs(fixture.only or {}) do
		if name == "replace_wrapped_recipe" then return true end
	end
	return false
end

---@param replacement_api react.ReplacementApi
function replace_wrapped.replace(replacement_api)
	if not wanted() then return end
	local ok, err = pcall(function()
		local react = require("::/gui/main/react.lua")
		local builtin = require("::/gui/main/builtin.lua")
		local popover_react_util = require("::/gui/main/popover_react_util.tl")
		local original = popover_react_util.PopoverWindowContent
		replacement_api.ReplaceRecipe(original,
			---@param ... any the popover's params
			---@return react.TreeNodeId
			function(...)
				return builtin.BoxLayout{ meta = { id = "probe.replaced_popover" },
					children = { react.CallOriginalRecipe(original, ...) } }
			end)
	end)
	debugPrint("[testbench] replace of a wrapped recipe: ", ok and "ok" or ("failed: " .. tostring(err)))
end

---@return table
function data()
	return replace_wrapped
end

return replace_wrapped
