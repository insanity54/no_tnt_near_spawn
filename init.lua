-- Read spawnpoints from config
local raw_spawnpoints = core.settings:get("protected_spawnpoints")
local spawnpoints = {}

-- Helper: parse a string into a vector
local function parse_pos(str)
	local x, y, z = str:match("^%s*(-?%d+%.?%d*),%s*(-?%d+%.?%d*),%s*(-?%d+%.?%d*)%s*$")
	if x and y and z then
		return { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
	end
end

-- Parse multiple spawnpoints from config
if raw_spawnpoints then
	for entry in raw_spawnpoints:gmatch("[^;]+") do
		local pos = parse_pos(entry)
		if pos then table.insert(spawnpoints, pos) end
	end
end

-- Fallback to static_spawnpoint or (0,0,0)
if #spawnpoints == 0 then
	local fallback = core.setting_get_pos("static_spawnpoint") or core.string_to_pos("0,0,0")
	table.insert(spawnpoints, fallback)
end

-- Settings
local spawn_buffer_distance = tonumber(core.settings:get("spawn_buffer_distance")) or 300
local allow_lava = core.settings:get_bool("allow_lava")
local allow_fire = core.settings:get_bool("allow_fire")
local allow_tnt = core.settings:get_bool("allow_tnt")

-- Disallowed nodes
local disallowed_nodes = {
	["fire:basic_flame"] = not allow_fire,
	["fire:permanent_flame"] = not allow_fire,
	["fire:flint_and_steel"] = not allow_fire,
	["ethereal:fire_flower"] = not allow_fire,
	["tnt:tnt"] = not allow_tnt,
	["default:lava_source"] = not allow_lava,
	["default:lava_flowing"] = not allow_lava,
	["rangedweapons:barrel"] = not allow_tnt,
}

-- Calculate shortest horizontal distance to any spawnpoint
local function closest_distance(pos)
	local shortest = math.huge
	for _, sp in ipairs(spawnpoints) do
		local dx, dz = pos.x - sp.x, pos.z - sp.z
		local dist = math.sqrt(dx * dx + dz * dz)
		if dist < shortest then shortest = dist end
	end
	return math.floor(shortest)
end

-- Lava bucket override
if not allow_lava then
	local def = minetest.registered_craftitems["bucket:bucket_lava"]
	if def then
		local original = def.on_place
		minetest.override_item("bucket:bucket_lava", {
			on_place = function(itemstack, placer, pointed_thing)
				local pos = pointed_thing.above or placer:get_pos()
				local dist = closest_distance(pos)
				if dist < spawn_buffer_distance then
					minetest.chat_send_player(placer:get_player_name(),
						minetest.colorize("#ffa500", "No lava within "..spawn_buffer_distance.." meters of spawn. (You are only "..dist.." meters.)"))
					return itemstack
				end
				return original(itemstack, placer, pointed_thing)
			end
		})
	end
end

-- Flint and steel override
if not allow_fire then
	local def = minetest.registered_tools["fire:flint_and_steel"]
	if def then
		local original = def.on_use
		minetest.override_item("fire:flint_and_steel", {
			on_use = function(itemstack, user, pointed_thing)
				local pos = pointed_thing.above or user:get_pos()
				local dist = closest_distance(pos)
				if dist < spawn_buffer_distance then
					minetest.chat_send_player(user:get_player_name(),
						minetest.colorize("#ffa500", "No fire within "..spawn_buffer_distance.." meters of spawn. (You are only "..dist.." meters.)"))
					return itemstack
				end
				return original(itemstack, user, pointed_thing)
			end
		})
	end
end

-- Global placement guard
minetest.register_on_placenode(function(pos, newnode, placer)
	if disallowed_nodes[newnode.name] then
		local dist = closest_distance(pos)
		if dist < spawn_buffer_distance then
			minetest.remove_node(pos)
			minetest.chat_send_player(placer:get_player_name(),
				minetest.colorize("#ffa500", "That block is not allowed within "..spawn_buffer_distance.." meters of spawn. (You are only "..dist.." meters.)"))
			return true
		end
	end
end)
