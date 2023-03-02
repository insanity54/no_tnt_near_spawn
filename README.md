# no_tnt_near_spawn

[![ContentDB](https://content.minetest.net/packages/cj_clippy/no_tnt_near_spawn/shields/title/)](https://content.minetest.net/packages/cj_clippy/no_tnt_near_spawn/)

## Features

* Removes TNT nodes placed within a configurable distance from spawn.
* Configurable no TNT zone size using the setting `spawn_buffer_distance` in minetest config. (Default 1000)
* Notifies the player of chat when attempting to place TNT
* Uses `static_spawnpoint` as the centerpoint of the no TNT zone, falling back to `0, 0, 0` if not set.


## Motivation 

I wanted to enable TNT in my public multiplayer world, but I was sure that griefers would misuse it and blow holes in the cool scenery, farms, and buildings that all the players have worked hard to create. I still wanted to have fun with TNT, but in a designated area. So I made this mod, which prevents players from placing TNT nodes within a configurable distance from spawn.
