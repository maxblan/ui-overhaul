-- statistics_common.lua: the balance of the statistics tabs reads an entity's account through
-- calculateBalance, which fails a native assertion (no Lua error, the game ends) for an entity whose
-- account is gone, as for a vehicle sold or replaced since the table read its rows. The stand-in
-- engine raises where the game would crash, so a read it should not get fails the spec.
local fake_react = require("fake_react")

---@return table the module, as the spec uses it
local function load()
	return fake_react.load("/ui_overhaul/gui/statistics_common.lua", {})
end

local ACCOUNT, TRANSPORT_VEHICLE, GAME_TIME = "account", "vehicle", "time"
local WORLD = 1

describe("statistics_common", function()
	local globals = _G ---@type table<string, any> global name -> value, of any type
	local saved ---@type any the global api before the spec
	local components ---@type table<integer, table<string, table>> entity -> component type -> component
	local balanced ---@type integer[] the entities calculateBalance was asked for
	before_each(function()
		saved = globals.api
		components = {
			[WORLD] = { [GAME_TIME] = { gameTime = 5000 } },
			[10] = { [ACCOUNT] = { balance = 0, loan = 0 }, [TRANSPORT_VEHICLE] = {} },
			[11] = { [TRANSPORT_VEHICLE] = {} }, -- exists, its account already removed
		}
		balanced = {}
		local mock = {
			type = { ComponentType = { ACCOUNT = ACCOUNT, TRANSPORT_VEHICLE = TRANSPORT_VEHICLE, GAME_TIME = GAME_TIME } },
			util = { getDefaultYearDuration = function() return 1000 end },
			engine = {
				---@param entity integer
				---@return boolean
				entityExists = function(entity) return components[entity] ~= nil end,
				---@param entity integer
				---@param componentType string
				---@return table?
				getComponent = function(entity, componentType)
					local of = components[entity]
					return of and of[componentType]
				end,
				util = {
					getWorld = function() return WORLD end,
					finance = {
						---@param entities integer[]
						---@return integer
						calculateBalance = function(entities)
							for _i, entity in ipairs(entities) do
								local of = components[entity]
								-- the game: "Assertion 'it != components.end()' failed", a native crash
								assert(of and of[ACCOUNT], "native crash: no Account component on " .. entity)
								balanced[#balanced + 1] = entity
							end
							return -250
						end,
					},
				},
			},
		}
		-- A partial stand-in; the cast keeps LuaLS from merging the mock's types into the global `api`.
		_G.api = mock --[[@as api]]
	end)
	after_each(function()
		globals.api = saved
	end)

	it("reads the balance of an entity that has an account", function()
		local common = load()
		assert.are.equal(-250, common.balance(10))
		assert.are.same({ 10 }, balanced)
	end)

	it("gives 0 and reads nothing for an entity whose account is gone", function()
		local common = load()
		assert.are.equal(0, common.balance(11))
		assert.are.equal(0, common.balance(12)) -- removed altogether
		assert.are.same({}, balanced)
	end)

	it("keeps the cached balance safe when a vehicle loses its account between reads", function()
		local common = load()
		local cached = common.makeBalanceCache()
		assert.are.equal(-250, cached(10))
		components[10][ACCOUNT] = nil
		components[WORLD][GAME_TIME].gameTime = 9000 -- past the cache's second: read again
		assert.are.equal(0, cached(10))
		assert.are.same({ 10 }, balanced)
	end)

	it("has: the entity exists and still has the component", function()
		local common = load()
		assert.is_true(common.has(10, ACCOUNT))
		assert.is_false(common.has(11, ACCOUNT))
		assert.is_true(common.has(11, TRANSPORT_VEHICLE))
		assert.is_false(common.has(12, TRANSPORT_VEHICLE))
	end)
end)
