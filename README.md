# SilentStorm Integration Helper <!-- omit in toc -->
A [Factorio](https://factorio.com) mod for people streaming the game, that are looking
to spice up their game by letting viewers trigger actions in the game.

The mod does not do anything on its own, without something triggering actions.
To this end the remote interface `silentstorm-integration-helper` is provided by the mod.

You will need to provide your own means of communicating between your streaming platform
of choice and the game. Factorio does provide RCON to interface with the game.

## Table of contents <!-- omit in toc -->
- [Available Functions](#available-functions)
  - [build_ghosts](#build_ghosts)
    - [Parameters](#parameters)
    - [Examples](#examples)
  - [repair_base](#repair_base)
    - [Parameters](#parameters-1)
    - [Examples](#examples-1)
  - [build_bp](#build_bp)
    - [Parameters](#parameters-2)
    - [Examples](#examples-2)
  - [deconstruct](#deconstruct)
    - [Parameters](#parameters-3)
    - [Examples](#examples-3)
  - [gain_research](#gain_research)
    - [Parameters](#parameters-4)
    - [Examples](#examples-4)
  - [cancel_research](#cancel_research)
    - [Parameters](#parameters-5)
    - [Examples](#examples-5)
  - [disable_research](#disable_research)
    - [Parameters](#parameters-6)
    - [Examples](#examples-6)
  - [random_research](#random_research)
    - [Parameters](#parameters-7)
    - [Examples](#examples-7)
  - [forget_research](#forget_research)
    - [Parameters](#parameters-8)
    - [Examples](#examples-8)
  - [set_arti_speed](#set_arti_speed)
    - [Parameters](#parameters-9)
    - [Examples](#examples-9)
  - [set_arti_range](#set_arti_range)
    - [Parameters](#parameters-10)
    - [Examples](#examples-10)
  - [set_lab_speed](#set_lab_speed)
    - [Parameters](#parameters-11)
    - [Examples](#examples-11)
  - [teleport](#teleport)
    - [Parameters](#parameters-12)
    - [Examples](#examples-12)
  - [teleport_distance](#teleport_distance)
    - [Parameters](#parameters-13)
    - [Examples](#examples-13)
  - [enemy_arty](#enemy_arty)
    - [Parameters](#parameters-14)
    - [Examples](#examples-14)
  - [remove_entity](#remove_entity)
    - [Parameters](#parameters-15)
    - [Examples](#examples-15)
  - [reset_recipe](#reset_recipe)
    - [Parameters](#parameters-16)
    - [Examples](#examples-16)
  - [biter_revive](#biter_revive)
    - [Parameters](#parameters-17)
    - [Examples](#examples-17)
  - [snap_wires](#snap_wires)
    - [Parameters](#parameters-18)
    - [Examples](#examples-18)
  - [load_turrets](#load_turrets)
    - [Parameters](#parameters-19)
    - [Examples](#examples-19)
  - [advance_rocket](#advance_rocket)
    - [Parameters](#parameters-20)
    - [Examples](#examples-20)
  - [rain_item](#rain_item)
    - [Parameters](#parameters-21)
    - [Examples](#examples-21)
  - [modify_walk_speed](#modify_walk_speed)
    - [Parameters](#parameters-22)
    - [Examples](#examples-22)
  - [modify_craft_speed](#modify_craft_speed)
    - [Parameters](#parameters-23)
    - [Examples](#examples-23)
  - [on_fire](#on_fire)
    - [Parameters](#parameters-24)
    - [Examples](#examples-24)
  - [barrage](#barrage)
    - [Parameters](#parameters-25)
    - [Examples](#examples-25)
  - [dump_inv](#dump_inv)
    - [Parameters](#parameters-26)
    - [Examples](#examples-26)
  - [cancel_hand_craft](#cancel_hand_craft)
    - [Parameters](#parameters-27)
    - [Examples](#examples-27)
  - [start_hand_craft](#start_hand_craft)
    - [Parameters](#parameters-28)
    - [Examples](#examples-28)
  - [get_naked](#get_naked)
    - [Parameters](#parameters-29)
    - [Examples](#examples-29)
  - [vacuum](#vacuum)
    - [Parameters](#parameters-30)
    - [Examples](#examples-30)
  - [drain_battery](#drain_battery)
    - [Parameters](#parameters-31)
    - [Examples](#examples-31)
  - [drain_shields](#drain_shields)
    - [Parameters](#parameters-32)
    - [Examples](#examples-32)

## Available Functions

Bold parameters are mandatory and must be provided, otherwise an error will be printed
to the game chat for all players.

All other parameters can be omitted, which will then use the default value.

If you want to specify a later parameter, you need to provide all those before it as well.
You can explicitly opt to use the default value by specifying the parameter as `nil`.

surface for example would usually be something like `game.players['player_name'].surface`
position would similarly be a player position most often e.g. 
`game.players['player_name'].position` but it can also be a fixed position presented like
`{x=0, y=0}`.

### build_ghosts

Builds ghosted entities around a location on the map.
You can optionally have it attempt to build destroyed entities (which have not left
a ghost) as well. However that will not work for all types of buildings due to game
limitations and it may not create anything, or in some cases even create the wrong building.

#### Parameters

- **surface**: A surface of the game.
- **force**: A force of which to repair damaged entities.
- **position**: The center point around which to repair entities.
- range: How many tiles around the position to build entities. Defaults to `20`.
- chance: Percentage chance of a ghosted / destroyed entity actually being built. 
  Defaults to `75`.
- ignore_technology: Boolean. Whether or not to build entities the specified force does
  not yet have researched. Defaults to `false`.
  When set to true it will build stuff that the specified force cannot currently build
  (either because it is not researched, or it cannot be built at all).
- include_remnants: Boolean. Whether or not to attempt to restore destroyed buildings
  that do not have a ghost. Defaults to `false`. When set to true it will _attempt_ 
  to restore destroyed buildings. However due to some limitations no guarantees are made
  as to the success. If a destroyed building cannot be identified it is not build.

#### Examples

Minimum parameters:
`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'build_ghosts', plr.surface, plr.force, plr.position)`

Restore even without ghosts, provided the destroyed building is researched:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'build_ghosts', plr.surface, plr.force, plr.position, nil, nil, nil, true)`

### repair_base

The `repair_base` function repairs entities around a location on the map. Minimum and 
maximum health points restored are configurable.

#### Parameters
  - **surface**: A surface of the game on which to repair things.
  - **force**: A force of which to repair damaged entities.
  - **position**: The center point around which to repair entities.
  - range: How many tiles around the position to repair entities. Defaults to `15`.
  - chance: Percentage chance of a damaged entity actually being repaired. Defaults to `75`.
  - minimum_health_gain: If an entity is being repaired it is at least being repaired for
    this many HP. Defaults to `20`.
  - maximum_health_gain: A single entity is never repaired for more than this many HP.
    Defaults to `150`.

#### Examples

Uses the default values for all non-optional parameters. Repairs between 20 and 150 health
for 75% of entities within 15 tiles of the player.
`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'repair_base', 
plr.surface, plr.force, plr.position)`

Repairs exactly 100 health for 75% of entities within 10 tiles of the player.
`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'repair_base', 
plr.surface, plr.force, plr.position, 10, nil, 100, 100)`

### build_bp

Allows to build arbitrary constructions. Simply create a blueprint of whatever it is
you want to have build, use the share / export feature of the blueprint and copy the
string and specify that as the `blueprint_string` parameter.

By default it will not build a blue belt for example if the force selected didn't yet
research them, but that can be overridden.

#### Parameters
- **surface**: A surface of the game on which to construct the blueprint.
- **force**: A force to use to build the blueprint.
- **position**: The position at which the blueprint build will be centered.
- **blueprint_string**: An exported blueprint string to build.
- ignore_technology: Boolean. Whether or not to actually build entities in the blueprint
  that the chosen force can not currently build. Defaults to `false`. When set to true then
  it will build any entity, even those that have not yet been researched by the force
  specified. When set to false (the default) it will leave such entities as ghosts.

#### Examples

Build the blueprint as yourself centered around player:
`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'build_bp', plr.surface, plr.force, plr.position, '0eNqV0VGLgzAMB/Dv8n/O4Fp13vWrjDF0C1tgRrF1nEi/+7T3cqCD7a0pyS8hmVDfB+560QA3Qc6terjDBC9Xre7LXxg7hoMEbkDQqlkiP9Q+VEFaRSSIXvgXzsQjgTVIEP5TUjCedGhq7ueErXpC13pJz7nbwmQlYYTbmZlWluutbod+AS1lx0gr1r7HFsUL1lC+xWYfTWvKN9n8o2nXbFrCvOh0EPfvfoQH9z4R9tvk5Y8ti735MsbG+ARLmaB2')`

Build a blueprint as enemy:
`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'build_bp', plr.surface, game.forces['enemy'], plr.position, '0eNqNj80Kg0AMhN9lziuY7Y/tvkopRdsgCxplf0pF9t272ovQHnoKEzJfZmY0XeTRWQkwM+x9EA9zmeFtK3W37MI0Mgxs4B4KUveLaqMUITrHAUnByoNfMJSuCizBBssfyiqmm8S+YZcPfvkVxsFnyyDLt4wpdKkw5Uk7Skl9UfR/FNIbSg62FjCbvgpPdn516BPtq7OuDkcqiXRKb62sWyU=')`

### deconstruct

Marks random buildings of the specified force for deconstruction by construction robots,
effectively stopping the building.

#### Parameters
- **surface**: A surface of the game to deconstruct buildings on.
- **force**: A force of which to mark buildings for deconstruction.
- position: A position around which to center the deconstruction. If specified must be
  a valid position around which the range parameter will be applied.
  Defaults to the `entire surface`.
- range: How many tiles around the position to mark buildings for deconstruction. Defaults to `500`.
- chance: Percentage chance of a building being marked for deconstruction. Defaults to `5`.
- maximum_count: How many buildings to mark for deconstruction at most. With a high chance
  and a big base this will cause the impact area to be limited in a small area.
  This function will never mark more than the number of buildings specified here. Defaults to `500`.
- ignore_technology: Boolean. Do not mark for deconstruction anything that the specified force
  cannot currently craft. Defaults to `false`.

#### Examples

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'deconstruct', plr.surface, plr.force, plr.position, 250)`

### gain_research

Advance the currently active research by an amount

#### Parameters
- **force**: The game force to advance the research for
- chance: Percentage chance to actually advance the research. Defaults to `75`.
- percentage: By what percentage to increase the research by. Valid value range is -100 to 100.
  A value of 100 will finish the research instantly.  
  Negative values will decrease the current research progress. Defaults to a `random value between 10 and 75`.
  Default value has a 5% chance to be negative.

#### Examples

Lose up to 25% of the current research, or gain up to 50% research progress. The actual value
here will vary each time this is ran due to the random number being passed in.

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'gain_research', plr.force, 100, math.random(-25, 50))`

### cancel_research

Cancels the current active research

#### Parameters
- **force**: The game force to cancel research for
- chance: Percentage chance to actually do something. Defaults to `50`.

#### Examples

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'cancel_research', plr.force, 100)`

### disable_research
Cancels all the active research for a force, disables all Labs and prevents accessing
the Tech Tree for a specified amount of time.

#### Parameters
- **force**: A game force for which to disable the research.
- chance: Percentage chance for anything to actually happen. Defaults to `50`.
- duration: Number of seconds to disable research for. Defaults to a `random value between 30 and 300 seconds`.

#### Examples

Disable research for 1 minute

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'disable_research', plr.force, 100, 60)`

### random_research

Start a random research that is available to be researched and put it to the top of the
research queue. If the research queue is full, the last item of the research queue is dropped.

#### Parameters
- **force**: The game force to start a random research for.
- chance: Percentage chance for anything to happen. Defaults to `50`.

#### Examples

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'random_research', plr.force, 100)`

### forget_research

Removes a random technology that has already been researched. All machines
using the technology lose their recipe. Does **not** disable dependent
technologies. So if you lose Optics for example, you will still be able to
use Laser Turrets, despite it being behind Optics.

#### Parameters
- **force**: The force to disable a random research for.
- chance: Percentage chance to actually do anything. Defaults to `50`.

#### Examples

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'forget_research', plr.force, 100)`

### set_arti_speed

Increases the artillery shooting speed of a team for a specified number of seconds.

#### Parameters
- **force**: The force to increase the shooting speed for.
- **levels**: How many research levels of artillery speed to add. Valid range: 1 to 21.
- chance: Percentage chance to actually do something. Defaults to `50`
- duration: For how many seconds to increase the shooting speed for. Defaults to a `random value between 60 and 180`.

#### Examples

Increase artillery shooting speed by 5 research levels for 30 seconds

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'set_arti_speed', plr.force, 5, 100, 30)`

### set_arti_range

Increase the artillery range of a team for a specified number of seconds.

#### Parameters
- **force**: The game force for which to increase the artillery range.
- **levels**: How many research levels of artillery range to add. Valid range: 1 to 21.
- chance: Percentage chance to actually do something. Defaults to `50`.
- duration: For how many seconds to increase the range for. Defaults to a `random value between 60 and 180`.

#### Examples

Increase artillery shooting range by 5 research levels for 30 seconds

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'set_arti_range', plr.force, 5, 100, 30)`

### set_lab_speed

Increases the speed that research labs work at. This will make research progress
faster, however it will also make them consume science packs faster. Can be considered
the less cheaty version of [gain_research](#gainresearch).

#### Parameters
- **force**: The game force for which to increase the lab speed.
- change: percentage by which to change the lab speed. -100 will make labs run half their
  current speed. 100 will make labs run twice their current speed.  
  Defaults to `a random value between 1 and 100`. Default value has a 5% chance to be negative.
  Valid range is -100 to 100.
- chance: Percentage chance for lab speed change to actually happen. Defaults to `75`.
- duration:  (random 10 - 180)

#### Examples

Run all the labs of the specified force, twice as fast for 60 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'set_lab_speed', plr.force, 100, 100, 60)`

### teleport

Teleports a player to the given location on a given surface after a given delay.
If the player is inside a vehicle it will be teleported alongside the player if
possible, otherwise the player is evicted from the vehicle before teleport.

Will not teleport player into places they cannot get out of.
Will not teleport player onto water if they cannot swim.

#### Parameters
- **player**: The player to teleport
- **position**: The position to teleport the player to.
- delay: Seconds before the teleport happens. Defaults to a `random value between 1 and 10`.
- surface: The destination surface to teleport the player to. Defaults to `their current surface`.

#### Examples

Teleport the player to coordinates 250, -500 onto Nauvis Orbit after 10 seconds.

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'teleport', plr, {x=250, y=-500}, 10, game.surfaces['Nauvis Orbit'])`

### teleport_distance

Teleports a player the given number of tiles from their current location.
If the player is inside a vehicle it will be teleported alongside the player if
possible, otherwise the player is evicted from the vehicle before teleport.

Will not teleport player into places they cannot get out of.
Will not teleport player onto water if they cannot swim.

If a surface is specified, please note that the player coordinates on their **current** surface
will be used as _origin_ coordinates. If the specified surface does not contain these coordinates
the teleport will fail.

#### Parameters
- **player**: The player to teleport
- **distance**: Number of tiles to teleport the player.
- delay: Number of seconds to delay the teleport for. Defaults to a `random value from 1 to 10` seconds.
- surface: The surface to teleport the player to. Defaults to `their current surface`.

#### Examples

After 5 seconds teleport the player 250 tiles from their current location.

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'teleport_distance', plr, 250, 5)`

### enemy_arty

Finds artillery turrets of the provided force and converts them to an enemy artillery turret.

#### Parameters
- **surface**: The surface to search for artillery turrets.
- **force**: The game force (team) of which to find artillery turrets.
- position: The position to center the search area around. Defaults to `{x=0, y=0}`.
- range: Number of tiles around the position to find artillery turrets.
  Defaults to a `random value between 500 and 5000`.
- max: Maximum number of artillery turrets to convert to an enemy artillery.
  Defaults to a `random value between 1 and 10`.
- chance: Percentage chance to convert a found artillery turret to an enemy turret.
  Defaults to a `random value between 10 and 100`.
- enemy_force: The force to assign the artillery turret to. Defaults to `game.forces['enemy']`.

#### Examples

Find up to 2 artillery turrets of the specified players force within 500 tiles around their
position and convert them to the enemy force.

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'enemy_arty', plr.surface, plr.force, plr.position, 500, 2, 100)`

### remove_entity

Outright erases buildings from the map. Can either erase random or specific entities.
When removing random entities it will pick a random building to remove and remove up
to the specified number of this entity. It will **NOT** remove multiple different entities.

#### Parameters
- **surface**: The surface to search for buildings to remove
- **force**: The force of which to delete buildings
- position: The center of the area to search for buildings to remove. Defaults to `{x=0, y=0}`.
- range: The number of tiles around the position to search for buildings to remove.
  Defaults to a `random value between 40 and 200`.
- name: Name of an entity to remove. Defaults to `randomly selected`.
- max: Maximum number of entities to remove. Defaults to a `random value between 5 and 20`.
  Won't remove more than this many buildings.
- chance: Percentage chance for any selected building to actually remove.
  Defaults to a `random value between 25 and 80`.

#### Examples

Remove a random type of entity around the player using the default values

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'remove_entity', plr.surface, plr.force, plr.position)`

Remove 20% of oil refineries (up to 100) within 1000 tiles around the player

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'remove_entity', plr.surface, plr.force, nil, 1000, 'oil-refinery', 100, 20)`

### reset_recipe

Removes the currently active recipe from any machine that has a recipe set.  
Note: Due to the fact that furnaces (at least vanilla ones) do not actually
have a set recipe, but instead select it automatically based on the input
material, they are not affected by this function.

#### Parameters
- **surface**: The surface to search for buildings.
- **force**: The force of which to search buildings.
- position: The center point to search around. Defaults to search the `entire surface`.
- range: The number of tiles around the position to search for buildings. Defaults to `500`.
- chance: The chance for any found building to actually remove the selected recipe of. Defaults to `2`.
- max_count: The maximum number of machines to actually reset. Defaults to `100`.

#### Examples

Remove recipes for machines within a 500 tile radius around the player

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'reset_recipe', plr.surface, plr.force, plr.position)`

### biter_revive

For a limited time biters have a chance to respawn when being killed.
Can be limited to biters dying in a specific area.
If a delay is specified, players within the area where biters will be revived will see a warning message.

#### Parameters
- chance: Percentage chance for every biter that dies to be revived.
  Defaults to a `random value between 10 and 100`.
- duration: Seconds for which to revive biters. Defaults to a `random value between 30 and 180` seconds.
- surface: Surface on which to revive biters. Defaults to `every surface`.
- position: Position around which to revive biters. Defaults to `anywhere`.
- range: Number of tiles around the position within which to revive biters. Defaults to `anywhere`.
- delay: Number of seconds before biters start being revived. Defaults to `0 seconds`.

#### Examples

Biters everywhere will have a 50% chance to be revived upon death for 2 minutes

`remote.call('silentstorm-integration-helper', 'biter_revive', 50, 120)`

Revive 25% of killed biters 500 tiles around the location specified for 30 seconds

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'biter_revive', 25, 30, plr.surface, plr.position, 500)`

### snap_wires

Cuts circuit wires and / or power cables between entities.

#### Parameters
- **surface**: Surface on which to disconnect wires.
- **force**: Force of which to find buildings to disconnect wires from.
- **position**: Center position around which to disconnect wires.
- range: Number of tiles around the position in which to disconnect wires.
  Defaults to a `random value between 50 and 200`.
- circuit: Boolean. Whether or not to disconnect circuit wires. Defaults to `true`.
- power: Boolean. Whether or not to disconnect power cables. Defaults to `true`.
- chance: Percentage chance to actually disconnect a wire. Defaults to a `random value between 10 and 20`.
- delay: Delay in seconds after which to disconnect wires. Defaults to `0 seconds`.

#### Examples

Cut powerlines (but not circuit connections) within 100 tiles of the player

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'snap_wires', plr.surface, plr.force, plr.position, 100, false, true)`

### load_turrets

Loads turrets around a location with particular ammunition.

#### Parameters
- **surface**: The surface on which to search for turrets.
- **force**: The force of which to find turrets of.
- position: The position around which to find turrets. Defaults to `{x=0, y=0}`.
- range: The number of tiles around the position in which to load turrets. Defaults to the `entire surface`.
- ammo_type: The name of the ammunition to load. Defaults to `firearm-magazine` (which is yellow ammo).
- chance: Percentage chance for any turret to actually be loaded with ammunition.
  Defaults to a `random value between 60 and 90`.
- count: How many of the specified ammunition to load for each turret. Defaults to a `random value between 5 and 50`.
  Will not load more than a full stack of the ammunition selected.  
  If set to a numeric value all turrets that do receive ammunition will be loaded with that many ammunition.  
  Other than a numeric value it can also be set to a string `random[:x[:y]]`, which will cause each individual turret
  to be loaded with a random value between x and y. Where x and y are optional and default to 5 and 50 respectively.
- replace: Boolean. Whether or not to replace the current ammunition in the turret. Defaults to `false`.
  If set to false any turret that is selected but currently has a different ammunition loaded than was specified will be skipped.
  If set to true, the currently loaded ammunition will be dropped on the ground and the specified ammunition will be loaded instead.
- delay: Delay in seconds after which to load turrets. Defaults to `0 seconds`.

#### Examples

Load 90% of turrets within 50 tiles around the player with 25 red ammunition, ignoring what
they currently have loaded:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'load_turrets', plr.surface, plr.force, plr.position, 50, 'piercing-rounds-magazine', 90, 25, true)`

### advance_rocket

Add rocket parts to rocket silos, advancing (or reverting) their launch progress.

#### Parameters
- **surface**: The surface on which to find rocket silos.
- **force**: The force of which to find rocket silos.
- position: The position around which to find rocket silos. Defaults to `{x=0, y=0}`.
- range: Number of tiles around the position in which to find rocket silos. Defaults to the `entire surface`.
- parts: How many rocket parts to add to found rocket silos. Defaults to a `random value between 10 and 75`.
  If set to a numeric value all rocket silos that get selected will receive the specified number of rocket parts.  
  Other than a numeric value it can also be set to a string `random[:x[:y]]`, which will cause each
  individual rocket silo to gain random number of rocket parts between x and y.
  Where x and y are optional and default to 10 and 75 respectively. Using 'random:5:20' for example
  would mean a random number between 5 and 20 for each rocket silo.  
  Setting this to a negative number will remove rocket parts from the silos, thereby reducing the
  progress on the rocket.
- chance: Percentage chance of a found silo to be selected for adding / removing rocket parts.
  Defaults to a `random number between 60 and 90`.
- delay: Number of seconds after which to add rocket parts to silos. Defaults to `0 seconds`.

#### Examples

Add 10 cargo rocket sections to every silo within 100 tiles around the player.

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'advance_rocket', plr.surface, plr.force, plr.position, 100, 10, 100)`

### rain_item

Spawns a specified amount of an item onto the ground at a specific location, or at
the location of a specified entity (either biters or players).

**If entity is provided then surface and position are ignored**

#### Parameters
- **surface**: The surface on which to rain items. __Ignored if entity is specified__
- **position**: The position around which to center the items. __Ignored if entity is specified__
- **entity**: The entity around which to center the spawning of items.
  _Optional if surface and position are specified_. Takes precedence over surface and position.
- **item**: Internal game name of the item to spawn. Must be a valid item.
- range: Number of tiles around the position in which to spawn the specified item.
- count: How many of the item to spawn. Defaults to a `random value between 10 and 200`.
- duration: Over how many seconds to spawn the item. Defaults to a `random value between 5 and 30` seconds.
- delay: Number of seconds before spawning starts.

#### Examples

Drop 100 Fish over the course of 5 seconds within 30 tiles of the specified player.

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'rain_item', nil, nil, plr, 'raw-fish', 30, 100, 5)

### modify_walk_speed

Increases or decreases the walking speed of a player.

#### Parameters
- **player**: The player of which to set the walking speed.
- modifier: percentage to which to set the walking speed of the player. Defaults to `100` (no change).
  Valid range is between 1 and the mod setting for maximum speed.
- duration: Number of seconds for which to adjust the player speed. Afterwards the original value
  will be restored. Defaults to a `random value between 10 and 60`.
- chance: percentage chance to actually change the walking speed of the player. Defaults to `100`. 
- delay: Number of seconds after which to actually change the walking speed of the player.
  Defaults to `0 seconds`.

#### Examples

Have the player walk at half speed after 5 seconds for a total of 10 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'modify_walk_speed', plr, 50, 10, 100, 5)`

### modify_craft_speed

Increases or decreases the hand crafting speed of a player.

#### Parameters
- **player**: The player of which to set the hand crafting speed.
- modifier: percentage to which to set the crafting speed. Defaults to `100`. Valid range is
  between 1 and the mod setting for crafting speed.
- duration: Number of seconds after which the crafting speed is restored to the previous value.
  Defaults to a `random value between 10 and 60 seconds`.
- chance: percentage chance for the player crafting speed to be actually changed. Defaults to `100`.
- delay: Number of seconds before the crafting speed to be changed. Defaults to `0` seconds.

#### Examples

After 5 seconds make a player craft at half speed for 10 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'modify_craft_speed', plr, 50, 10, 100, 5)`

### on_fire

Creates fire centered around a player.

#### Parameters
- **player**: The player on which to center the fire.
- duration: Duration in seconds for how long to keep creating fire around the player.
  Defaults to a `random value between 10 and 60` seconds.
- range: Number of tiles to set on fire centered on the player. Defaults to a 
  `random value between 10 and 40` tiles. Valid range is 4 to 80.
- chance: Chance for fire to be created for each tile. Defaults to `80`.
- delay: Number of seconds after which to start creating the fire. Defaults to `0` seconds.

#### Examples

After 10 seconds make the player be engulfed in flames for 10 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'on_fire', plr, 10, 4, 90, 10)`

### barrage

Launches a configured number of projectiles at a player with configurable delays.
Optionally launches multiple projectiles at once.

#### Parameters
- **player**: The player to launch projectiles at.
- item: A projectile name. Defaults to `explosive-rocket`.
- range: The number of tiles around the player to target the projectiles at.
  Defaults to a `random number between 10 and 50`.
- count: The number of projectiles to shoot at once. Defaults to a `random number between 5 and 20`.
- iterations: The number of times the configured count of projectiles are launched.
  Defaults to a `random value between 2 and 20`.
- pause: Number of seconds between each iteration. Defaults to a `random value between 1 and 10`.
  Other than a numeric value it can also be set to a string `random[:x[:y]]`, which will cause
  each individual iteration to be delayed a random number of seconds between x and y.
  Where x and y are optional and default to 1 and 10 respectively. Using 'random:5:20' for example
  would mean a random number between 5 and 20 seconds between each shelling.  
- chance: Percentage chance for each individual projectile to be launched. Defaults to `90`.
- delay: Number of seconds before the first shelling starts. Defaults to `0`. Can be used
  to give a warning to the player.
- homing: How many projectiles (out of `count`) will target the player, rather than a location
  within `range` tiles around the player. Defaults to `25% of count`.
- random_target: Boolean. Whether or not to chose a random target location within range tiles
  around the player. Defaults to `true`. When set to true will choose a random target within
  `range` tiles around the player. When set to `false` it will choose the location the player
  was occupying when the projectile is spawned, unless less than `homing_count` shots have been
  fired, in which case the projectile will aim at the player itself.
- speed_modifier: Double. Projectile speed modifier applied to spawned projectiles. Valid values are > 0.33.
  Defaults to `1`. Allows to increase or decrease the speed at which the projectile will fly to its target.
  Values < 1 make it slower, values > 1 will make it faster.
- range_modifier: Double. Projectile range modifier applied to spawned projectiles. Valid values are > 1.
  Defaults to `1`. Allows to increase the range of projectiles. The range determines how long a projectile
  will be able to remain in the air, flying towards its target. If a projectile has flown for more tiles
  than its range (without hitting its target), it will simply hit the ground at its maximum distance.
- location: Fixed position to launch a barrage at. If specified the player will be ignored (but still needs
  to be specified). If specified surface must also be specified. Defaults to `player location`.
- surface: Surface to use for the fixed location. If location is specified so must the surface.
  Defaults to `player surface`.
- continue_on_death: Boolean. Whether to keep firing at the last player location upon death, or hold fire
  until the player respawns. Defaults to `true` which will keep firing when the player targeted is dead.

#### Examples

Send 5 atomic warheads to the player, each of which detonates within 50 tiles around the location of the player
when the rocket spawned. The warheads will be launched with at least 5 seconds of delay between them:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'barrage', plr, 'atomic-rocket', 50, 1, 5, 'random:5', 100, 5, 0, true)`

Send 2 atomic warheads to the player, one of which will follow the player the other one detonating
at a fixed location within 40 tiles of the player location when it was created:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'barrage', plr, 'atomic-rocket', 40, 2, 1, nil, 100, 5, 1, true)`

After 5 seconds send 10 atomic warheads to the specified location (0, 0 in this case) on the specified surface:
`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'barrage', plr, 'atomic-rocket', 50, 1, 10, 'random:5', 100, 5, 0, true, nil, nil, {x=0,y=0}, plr.surface)`

### dump_inv

Will drop the player inventory onto the ground surrounding the player
optionally over a specified time.

#### Parameters
- **player**: The player whose inventory to drop
- range: Number of tiles around the current player location within which the inventory items will
  be dropped. Defaults to a `random value between 10 and 80`.
- chance: A percentage chance for each individual item to be dropped.
  Defaults to a `random value between 50 and 100`.
- delay: Number of seconds after which the inventory dropping starts. Defaults to `0` seconds.
- duration: Number of seconds over which the inventory will be dropped. Defaults to `0` seconds.
  A value of 0 causes the inventory to be dropped instantly.
- mark_for_pickup: Boolean. Defaults to `false`. When set to true the items will be marked for
  pickup by bots and can also be picked up by simply walking over them, without the need to
  hold the pickup item key.

#### Examples

Drop about 60% of the player inventory within 55 tiles around the player,
over the course of 5 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'dump_inv', plr, 55, 60, 0, 5)`

Drop all of the inventory of the player within 40 tiles around the player instantly:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'dump_inv', plr, 40, 100)`

Drop all connected players inventory around their respective location over the course of 2 seconds:

`for _, plr in pairs(game.connected_players) do remote.call('silentstorm-integration-helper', 'dump_inv', plr, 30, 100, 0, 2) end`

### cancel_hand_craft

Cancels current handcrafting by a player. Optionally disabled handcrafting for a player
for a specified duration.

#### Parameters
- **player**: The player for which to cancel their current hand crafting.
- chance: Percentage chance of actually cancelling the hand crafting for each
  crafted item. Defaults to a `random value between 25 and 80`.
- delay: Number of seconds after which the hand crafting is being canceled.
  Defaults to `0` seconds.
- duration: Number of seconds for which to disable hand crafting. Defaults to `0` seconds.

#### Examples

Prevent player from hand crafting for 10 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'cancel_hand_craft' plr, 100, 0, 10)`

Stop hand crafting for the player, but allow them to queue new stuff:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'cancel_hand_craft', plr, 100, 0, 0)`

### start_hand_craft

Starts hand crafting a specific item by a player.  
By default a random item that the player can currently craft. 
The player needs the ingredients in their inventory and the item
needs to be able to be handcrafted. The technology must also be researched.

#### Parameters
- **player**: The player that will do the handcrafting.
- item: The name of the item to handcraft. If not specified a random item will be chosen,
  for which the player has the ingredients.
- count: Maximum number of items to be crafted (depending on ingredient availability).
  Defaults to a `random value between 1 and 100`.
- chance: percentage chance for the handcrafting to happen. Defaults to `100`.
- delay: Number of seconds until the hand crafting starts. Defaults to `0` seconds.

#### Examples

Have the player start handcrafting 10 Steel furnaces, if the player has the material for it:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'start_hand_craft', plr, 'steel-furnace', 10)`

Have the player start handcrafting up to 10 of any item they have the material for it:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'start_hand_craft', plr, nil, 10)`

### get_naked

Drops the players armor and optionally denies the player their armor for a specified time.

#### Parameters
- **player**: The player whose armor to remove.
- delay: Number of seconds after which the armor is removed from the player.
  Defaults to `0` seconds.
- distance: Number of tiles around the player that the armor will be put.
  Defaults to a `random value between 50 and 100`. If set to `0` the armor will
  be put back into the armor inventory after the duration has expired.
- duration: Number of seconds between the armor being removed from the player
  and it being put on the ground. Defaults to a `random value between 2 and 10` seconds.
- battery: Percentage of battery charge to retain when the armor is returned to the player.
  Defaults to a `random value between 50 and 75`.
- shield: Percentage of shield charge to retain when the armor is returned to the player.
  Defaults to a `random value between 0 and 20`.

#### Examples

After 5 seconds have the player have to live without their armor for 30 seconds and after
30 seconds dump it within 100 tiles around the player:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'get_naked', plr, 5, 100, 30)`

Drop the player armor within 50 tiles around them after 5 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'get_naked', plr, 5, 50, 0)`

### vacuum

Increases the range that the player picks up items in when
pressing the pickup key (default F).

#### Parameters
- **player**: The player to increase the pickup range for.
- range: Number of tiles by which to increase the range that the player can pick up items in.
  Defaults to a `random value between 1 and 5`.
- duration: Number of seconds before the range is restored to the previous value. Defaults to
  a `random value between 5 and 20`. Valid values are 1 to 300 inclusive.
- chance: Percentage chance for the player pickup range to be increased.
  Defaults to a `random value between 75 and 95`.
- delay: Number of seconds before the pickup range is changed. Defaults to `0` seconds.
- pickup: Boolean. Whether or not the player automatically picks up stuff in range, or have to
  press their pickup hotkey instead. Defaults to `true` meaning it will automatically pick up stuff.

#### Examples

Player automatically picks up stuff within 11 tiles around them for 20 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'vacuum', plr, 10, 20, 100)`

### drain_battery

Drains the battery of player armor or their spidertron
to a specified value or by a specified percentage of their current charge.

#### Parameters
- **player**: The player of which to drain the batteries.
- percent: percentage by which to increase / decrease the battery level.
  Defaults to a `random value between -90 and 90`.
- chance: Percentage change for the batteries to drain.
  Defaults to a `random value between 50 and 100`.
- delay: Number of seconds before the batteries to drain.
  Defaults to `0` seconds.
- absolute: Boolean. Defaults to `false`. If set to true then the battery
  charge level is set to the specified level in `percent`. When false the current
  value will be used to adjust the battery level by the percentage value.
- duration: For how many seconds to keep the battery charge at the specified level.
  Defaults to `0` seconds.

#### Examples

Remove all battery charge from the player armor for 20 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'drain_battery', plr, 0, 100, 0, true, 20)`

### drain_shields

Drains the shields of player armor or their spidertron
to a specified value or by a specified percentage of their current charge.

#### Parameters
- **player**: The player of which to drain the shields.
- percent: percentage by which to increase / decrease the shields level.
  Defaults to a `random value between -90 and 90`.
- chance: Percentage change for the shields to drain.
  Defaults to a `random value between 50 and 100`.
- delay: Number of seconds before the shields to drain. Defaults to `0` seconds.
- absolute: Boolean. Defaults to `false`. If set to true then the shield charge level
  is set to the specified level in `percent`. When false the current value will be
  used to adjust the shield level by the percentage value.
- duration: For how many seconds to keep the shield charge at the specified level.
  Defaults to `0` seconds.

#### Examples

Remove all shield charge from the player armor for 20 seconds:

`local plr = game.players['foo'] remote.call('silentstorm-integration-helper', 'drain_shields', plr, 0, 100, 0, true, 20)`
