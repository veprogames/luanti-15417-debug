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
---@field default number
---@field min number
---@field max number
---@field x number
---@field y number

---@param params ControlParams
---@return string
local function control(params)
	core.register_on_player_receive_fields(function (player, formname, fields)
		if formname ~= "visuals2:main" then return end

		if fields[params.id] ~= nil and string.sub(fields[params.id], 0, 3) == "VAL" then
			return
		end

		local value = parse(fields[params.id])
		if value == nil then return end

		value = params.min + (value / 1000.0 * (params.max - params.min))
		core.chat_send_player(player:get_player_name(), string.format("Set %s to %f", params.prop, value))
		local lighting = player:get_lighting()
		table_set(lighting, params.prop:split("."), value)

		print("\n\n\n=============")
		print("Call player:set_lighting with:")
		print(dump(lighting))
		player:set_lighting(lighting)
		print("\nplayer:get_lighting() is now:")
		print(dump(player:get_lighting()))
	end)

	local span = math.abs(params.min - params.max)
	local interpolation = (params.default - params.min) / span
	local initial_value = 1000.0 * interpolation

	return string.format([[
		label[%f,%f;%s]
		scrollbar[%f,%f;3,0.5;horizontal;%s;%d]
	]], params.x, params.y, params.prop,
		params.x, params.y + 0.2, params.id,
		initial_value)
end

core.register_globalstep(function ()
	local player = core.get_player_by_name("singleplayer")
	if player ~= nil then
		local controls = player:get_player_control()
		if controls.aux1 then
			local lighting = player:get_lighting()
			print("applying defaults to formspec:", dump(lighting))
			local form_controls = {
				control {
					id = "artificial_light_r",
					prop = "artificial_light.r",
					min = 0,
					max = 1.04,
					x = 0,
					y = 0.25,
					default = lighting.artificial_light.r,
				},
				control {
					id = "artificial_light_g",
					prop = "artificial_light.g",
					min = 0,
					max = 1.04,
					x = 3,
					y = 0.25,
					default = lighting.artificial_light.g,
				},
				control {
					id = "artificial_light_b",
					prop = "artificial_light.b",
					min = 0,
					max = 1.04,
					x = 6,
					y = 0.25,
					default = lighting.artificial_light.b,
				},
				control {
					id = "vignette_dark",
					prop = "vignette.dark",
					min = -2,
					max = 2,
					x = 0,
					y = 1.25,
					default = lighting.vignette.dark,
				},
				control {
					id = "vignette_bright",
					prop = "vignette.bright",
					min = -2,
					max = 2,
					x = 3,
					y = 1.25,
					default = lighting.vignette.bright,
				},
				control {
					id = "vignette_power",
					prop = "vignette.power",
					min = -1,
					max = 1,
					x = 6,
					y = 1.25,
					default = lighting.vignette.power,
				},
				control {
					id = "r0_x",
					prop = "volumetric_light.scattering_coefficients.x",
					min = -2,
					max = 2,
					x = 0,
					y = 4.25,
					default = lighting.volumetric_light.scattering_coefficients.x,
				},
				control {
					id = "r0_y",
					prop = "volumetric_light.scattering_coefficients.y",
					min = -2,
					max = 2,
					x = 5,
					y = 4.25,
					default = lighting.volumetric_light.scattering_coefficients.y,
				},
				control {
					id = "r0_z",
					prop = "volumetric_light.scattering_coefficients.z",
					min = -2,
					max = 2,
					x = 10,
					y = 4.25,
					default = lighting.volumetric_light.scattering_coefficients.z,
				},
				control {
					id = "r0_strength",
					prop = "volumetric_light.strength",
					min = 0,
					max = 1,
					x = 15,
					y = 4.25,
					default = lighting.volumetric_light.strength,
				},
				control {
					id = "foliage_translucency",
					prop = "foliage_translucency",
					min = 0,
					max = 10,
					x = 0,
					y = 2.25,
					default = lighting.foliage_translucency,
				},
				control {
					id = "specular_intensity",
					prop = "specular_intensity",
					min = 0,
					max = 10,
					x = 3,
					y = 2.25,
					default = lighting.specular_intensity,
				},
				-- cdl
				control {
					id = "cdl_o_x",
					prop = "cdl.offset.x",
					min = -1,
					max = 1,
					x = 10,
					y = 0.25,
					default = lighting.cdl.offset.x,
				},
				control {
					id = "cdl_o_y",
					prop = "cdl.offset.y",
					min = -1,
					max = 1,
					x = 13,
					y = 0.25,
					default = lighting.cdl.offset.y,
				},
				control {
					id = "cdl_o_z",
					prop = "cdl.offset.z",
					min = -1,
					max = 1,
					x = 16,
					y = 0.25,
					default = lighting.cdl.offset.z,
				},
				control {
					id = "cdl_s_x",
					prop = "cdl.slope.x",
					min = -2,
					max = 2,
					x = 10,
					y = 1.25,
					default = lighting.cdl.slope.x,
				},
				control {
					id = "cdl_s_y",
					prop = "cdl.slope.y",
					min = -2,
					max = 2,
					x = 13,
					y = 1.25,
					default = lighting.cdl.slope.y,
				},
				control {
					id = "cdl_s_z",
					prop = "cdl.slope.z",
					min = -2,
					max = 2,
					x = 16,
					y = 1.25,
					default = lighting.cdl.slope.z,
				},
				control {
					id = "cdl_p_x",
					prop = "cdl.power.x",
					min = -2,
					max = 2,
					x = 10,
					y = 2.25,
					default = lighting.cdl.power.x,
				},
				control {
					id = "cdl_p_y",
					prop = "cdl.power.y",
					min = -2,
					max = 2,
					x = 13,
					y = 2.25,
					default = lighting.cdl.power.y,
				},
				control {
					id = "cdl_p_z",
					prop = "cdl.power.z",
					min = -2,
					max = 2,
					x = 16,
					y = 2.25,
					default = lighting.cdl.power.z,
				},
			}

			local formspec = string.format([[
				formspec_version[10]
				size[20,11]
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
