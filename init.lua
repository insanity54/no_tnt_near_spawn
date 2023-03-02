
-- Get the spawnpoint pos
local spawnpoint = core.setting_get_pos("static_spawnpoint")
if not spawnpoint then
	spawnpoint = core.string_to_pos("0, 0, 0")
end


-- Allow nodes within this distance from spawn
local spawn_buffer_distance = tonumber(core.settings:get("spawn_buffer_distance")) or 1000

-- Disallowed node types
local disallowed_nodes = {
	["fire:basic_flame"] = not core.settings:get_bool("allow_fire"),
	["fire:permanent_flame"] = not core.settings:get_bool("allow_fire"),
	["fire:flint_and_steel"] = not core.settings:get_bool("allow_fire"),
	["tnt:tnt"] = not core.settings:get_bool("allow_tnt"),
	["default:lava_source"] = not core.settings:get_bool("allow_lava"),
	["default:lava_flowing"] = not core.settings:get_bool("allow_lava"),
}

-- Debug: log the disallowed nodes table
minetest.log("action", "[No TNT Near Spawn] disallowed nodes:")
for node_name, is_disallowed in pairs(disallowed_nodes) do
  minetest.log("action", string.format("[No TNT Near Spawn] - %s: %s", node_name, tostring(is_disallowed)))
end


-- Override flint and steel item
if not core.settings:get_bool("allow_fire") then
	local flint_and_steel_def = minetest.registered_tools["fire:flint_and_steel"]

	if flint_and_steel_def then
    local original_on_use = flint_and_steel_def.on_use

    local overridden_on_use = function(itemstack, user, pointed_thing)

        -- Check if the user is allowed to place fire
        local pos = user:get_pos()
        local distance_to_spawn = math.floor(vector.distance(pos, spawnpoint))

        if distance_to_spawn < spawn_buffer_distance and not core.settings:get_bool("allow_fire") then
            minetest.chat_send_player(user:get_player_name(), minetest.colorize("#ffa500", "No fire within "..spawn_buffer_distance.." meters of spawn. (You are only "..distance_to_spawn.." meters.)"))
            return itemstack
        end

        -- Call the original on_use function
        return original_on_use(itemstack, user, pointed_thing)
    end

    -- Override the flint and steel item
    minetest.override_item("fire:flint_and_steel", {
        on_use = overridden_on_use
    })
	end
end



-- Override lava bucket item
if not core.settings:get_bool("allow_lava") then
	local lava_bucket_def = minetest.registered_craftitems["bucket:bucket_lava"]

	if lava_bucket_def then
    local original_on_place = lava_bucket_def.on_place


    local overridden_on_place = function(itemstack, placer, pointed_thing)


      -- Check if the placer is allowed to place lava
      local pos = placer:get_pos()
      local distance_to_spawn = math.floor(vector.distance(pos, spawnpoint))

      if distance_to_spawn < spawn_buffer_distance and not core.settings:get_bool("allow_lava") then
          minetest.chat_send_player(placer:get_player_name(), minetest.colorize("#ffa500", "No lava within "..spawn_buffer_distance.." meters of spawn. (You are only "..distance_to_spawn.." meters.)"))
          return itemstack
      end

      -- Call the original on_use function
    	minetest.log("action", string.format("LAVA PLACED by "..placer:get_player_name().." at "..pos:to_string()))
      return original_on_place(itemstack, placer, pointed_thing)
    end

    -- Override the lava bucket item
    minetest.override_item("bucket:bucket_lava", {
	    on_place = overridden_on_place
	  })
	end
end


minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local node_name = newnode.name

	if disallowed_nodes[node_name] then

		local player_name = placer:get_player_name()

		-- delete the node if it's too close to spawn
		local distance_to_spawn = math.floor(vector.distance(pos, spawnpoint))

		if distance_to_spawn < spawn_buffer_distance then
			local message = "That block is not allowed within "..spawn_buffer_distance.." meters of spawn. (You are only "..distance_to_spawn.." meters.)"
			minetest.chat_send_player(player_name, minetest.colorize("#ffa500", message))
			minetest.remove_node(pos)
			return true
		end
	end
end)
