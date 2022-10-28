


-- Get the spawnpoint pos
local spawnpoint = core.setting_get_pos("static_spawnpoint")
if not spawnpoint then
	spawnpoint = core.string_to_pos("0, 0, 0")
end

-- Allow TNT only this far from spawn
local spawn_buffer_distance = tonumber(core.settings:get("spawn_buffer_distance")) or 1000



minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	local node_name = newnode.name

	if (node_name ~= 'tnt:tnt') then return false end


	local player_name = placer:get_player_name()

	-- delete the node if it's too close to spawn
	local distance_to_spawn = vector.distance(pos, spawnpoint)


	-- minetest.chat_send_player(player_name, "Placenode "..newnode.name.." ... btw the spawnpoint is "..minetest.pos_to_string(spawnpoint).." distance_to_spawn:"..distance_to_spawn)
	
	if (distance_to_spawn < spawn_buffer_distance) then
		minetest.chat_send_player(player_name, minetest.colorize("#ffa500", "[No TNT Near Spawn] No TNT within "..spawn_buffer_distance.." meters of spawn. (You are only "..distance_to_spawn.." meters.)"))
		minetest.remove_node(pos)
		return true
	end
end)