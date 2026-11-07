-- Another mod's recipe replacement, between UI Overhaul's two configs: it replaces a recipe it reads
-- from a field UI Overhaul wraps, the way Don't Auto Pin does (check replace_wrapped_recipe).
---@return table
function data()
	return {
		type = "react-replacement-config",
		data = {
			filePath = "ui_overhaul_testbench_1::/ui_overhaul_testbench/gui/replace_wrapped.script",
			doReplaceFn = "replace",
			order = 0,
		},
	}
end
