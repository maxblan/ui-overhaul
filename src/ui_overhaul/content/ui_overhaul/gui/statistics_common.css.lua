-- Statistics tabs: the line with quick filters and totals above the table (statistics_common.QuickFilterBar),
-- the same on every tab that has one (Lines, Vehicles, Stations, Warehouses). Scoped to the window as the
-- base statistics stylesheet is, so a tab that adds the bar needs no entry here.
local ssu = require("::/gui/main/stylesheetutil.lua")

---@return table
function data()
	-- how far the game got, for a crash while it loads (issue #7); this Lua state may lack debugPrint
	pcall(function() debugPrint("[ui_overhaul] stylesheet statistics_common") end)
	local result = {}
	local add = ssu.makeAdder(result)
	add("R::StatisticsContainer BoxLayout!uio-statistics-quick-filters", {
		innerSpacing = { 12, 0 },
		margin = { 4, 18, 6, 18 },
	})
	return result
end
