# no_tnt_near_spawn

[![ContentDB](https://content.minetest.net/packages/cj_clippy/no_tnt_near_spawn/shields/title/)](https://content.minetest.net/packages/cj_clippy/no_tnt_near_spawn/)

## Features

* Removes TNT nodes (and other griefer favorites) placed within a configurable *horizontal* distance from spawn.
* Configurable no TNT zone size using the setting `spawn_buffer_distance` in minetest config. (Default 300)
* Notifies the player via chat when attempting to place TNT in a protected zone.
* Configurable list of `protected_spawnpoints`. Add as few or as many as you like.
* Defaults to `static_spawnpoint` as the centerpoint of the no TNT zone, falling back to `0, 0, 0` if not set.

## Motivation 

I run an anarchy pvp server and griefers love to obliterate the spawnpoint with TNT, lava, or whatever dangerous node they can find. It makes the server inaccessible to new players and I really want new combatents on my server! So I made this mod, which prevents players from placing TNT, lava, and fire within a configurable horizontal distance from spawn.


## Example usage

### world.mt

```txt
load_mod_no_tnt_near_spawn = true
```

### minetest.conf

```txt
protected_spawnpoints = 0,125,0 ; 1000,5,200 ; -300,2,-400
spawn_buffer_distance = 100
allow_lava = false
allow_fire = false
allow_tnt = false
```