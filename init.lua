---@param value string?
---@return number?
local function parse(value)
	if value == nil then return nil end

	local no_chg = string.sub(value, 5)

	return tonumber(no_chg)
end

---@param tbl table
---@param path string[]
---@param value any
---@return nil
local function table_set(tbl, path, value)
	if #path == 1 then
		tbl[path[1]] = value
	else
		if tbl[path[1]] == nil then
			tbl[path[1]] = {}
		end

		local first = table.remove(path, 1)
		table_set(tbl[first], path, value)
	end
end

---@class ControlParams
---@field id string
---@field prop string
---@field min number
---@field max number
---@field x number
---@field y number

---@param params ControlParams
---@return string
local function control(params)
	core.register_on_player_receive_fields(function (player, formname, fields)
		if formname ~= "visuals2:main" then return end

		local value = parse(fields[params.id])
		if value == nil then return end

		value = params.min + (value / 1000.0 * (params.max - params.min))
		local lighting = {}
		table_set(lighting, params.prop:split("."), value)
		player:set_lighting(lighting)
	end)

	return string.format([[
		label[%f,%f;%s]
		scrollbar[%f,%f;3,0.5;horizontal;%s;0]
	]], params.x, params.y, params.prop,
		params.x, params.y + 0.2, params.id)
end

core.register_globalstep(function ()
	local player = core.get_player_by_name("singleplayer")
	if player ~= nil then
		local controls = player:get_player_control()
		if controls.aux1 then
			local form_controls = {
				control {
					id = "artificial_light_r",
					prop = "artificial_light.r",
					min = 0,
					max = 1,
					x = 0,
					y = 0.25,
				},
				control {
					id = "artificial_light_g",
					prop = "artificial_light.g",
					min = 0,
					max = 1,
					x = 3,
					y = 0.25,
				},
				control {
					id = "artificial_light_b",
					prop = "artificial_light.b",
					min = 0,
					max = 1,
					x = 6,
					y = 0.25,
				},
			}

			local formspec = string.format([[
				formspec_version[10]
				size[20,5]
				position[0.5,1.0]
				no_prepend[]
				bgcolor[#00000020;false]
				anchor[0.5,1]
				%s
			]], table.concat(form_controls, "\n"))

			core.show_formspec(
				player:get_player_name(),
				"visuals2:main",
				formspec
			)
		end
	end
end)
