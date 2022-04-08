-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local DEV = true

local constants = require('constants')
local research = require('funcs/research_tree')
local build = require('funcs/build')
local map = require('funcs/map')
local fn_player = require('funcs/player')
local config = require('utils/config')
local strutil = require('utils/string_replace')
local on_tick_n = require('__flib__.on-tick-n')

local function onTick(event)
    local list = on_tick_n.retrieve(event.tick)
    if not list then
        return
    end

    for _, task in pairs(list) do
        if task.action == 'enable_research' then
            research.enable_research(task.force, 100, task.queue, task.has_queue)
        elseif task.action == 'teleport_player' then
            if not global.silinthlp_teleport[task.player.name] then
                return
            end
            local tile = task.surface.get_tile(task.position)
            local distance = map.getDistance(task.player.position, task.position)
            local attempts = global.silinthlp_teleport[task.player.name]

            local player_prototype = task.player.character.prototype
            if task.player.vehicle then
                player_prototype = task.player.vehicle.prototype
            end
            local size = math.ceil(math.abs(player_prototype.collision_box.left_top.x) + math.abs(player_prototype.collision_box.right_bottom.x))

            local do_tp = function(player, dest, surface)
                local oldPos = player.position
                if player.vehicle then
                    player.vehicle.teleport(dest, surface)
                else
                    player.teleport(dest, surface)
                end
                global.silinthlp_teleport[player.name] = nil
                if #config['msg-map-teleport-player'] > 0 then
                    player.force.print(strutil.replace_variables(config['msg-map-teleport-player'], {player.name, math.floor(distance + 0.5), '[gps=' .. math.floor(oldPos.x + 0.5) .. ',' .. math.floor(oldPos.y + 0.5) .. ']', '[gps=' .. math.floor(dest.x + 0.5) .. ',' .. math.floor(dest.y + 0.5) .. ']'}))
                end
            end
            local do_fallback = function()
                if global.silinthlp_teleport[task.player.name] < config['teleport-attempts'] then
                    map.teleport_random(task.player, task.surface, distance)
                else
                    local pos = task.surface.find_non_colliding_position(player_prototype.name, task.position, 50, size)
                    if pos then
                        do_tp(task.player, pos, task.surface)
                    else
                        task.player.print('Failed to find suitable teleport target. Aborted teleport.')
                    end
                end
            end

            if not tile.collides_with('player-layer') then
                local pos = task.position
                local orig = '[gps=' .. pos.x .. ', ' .. pos.y .. ']'
                if not task.surface.can_place_entity{name=player_prototype.name, position=task.position, force=task.player.force} then
                    pos = task.surface.find_non_colliding_position(player_prototype.name, task.position, 10, size)
                end
                if pos and task.surface.can_place_entity{name=player_prototype.name, position=pos, force=task.player.force} then
                    do_tp(task.player, pos, task.surface)
                else
                    do_fallback(task, distance)
                end
            else
                do_fallback(task, distance)
            end
        elseif task.action == 'teleport_delay' then
            if task.delay == 0 then
                -- TODO: Use safe teleportation
                local oldPos = task.player.position
                local dest = task.position
                if task.player.vehicle then
                    task.player.vehicle.teleport(dest, task.surface)
                else
                    task.player.teleport(dest, task.surface)
                end
                if #config['msg-map-teleport-player'] > 0 then
                    task.player.force.print(strutil.replace_variables(config['msg-map-teleport-player'], {task.player.name, math.floor(map.getDistance(oldPos, dest) + 0.5), '[gps=' .. math.floor(oldPos.x + 0.5).. ',' .. math.floor(oldPos.y + 0.5) .. ']', '[gps=' .. dest.x .. ',' .. dest.y .. ']'}))
                end
            else
                task.player.force.print('Teleporting ' .. task.player.name .. ' in ' .. task.delay .. ' seconds...')
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'restore_walking_speed' then
            task.player.character_running_speed_modifier = task.original
            global.silinthlp_walk_speed[task.player.name] = nil
        elseif task.action == 'restore_crafting_speed' then
            task.player.character_crafting_speed_modifier = task.original
            global.silinthlp_craft_speed[task.player.name] = nil
        elseif task.action == 'player_on_fire' then
            if map.getDistance(task.player.position, task.lastPos) > task.range / 2 or task.executed + 120 <= game.tick then
                fn_player.set_on_fire(task.player, task.range, task.chance)
                task['lastPos'] = task.player.position
                task['executed'] = game.tick
            end
            if task.player.character then
                task['nthTick'] = math.max(1, math.floor((task.range / 2 - 2) / (1 + math.max(task.player.character_running_speed_modifier, task.player.character_running_speed))))
            else
                -- player dead, try again in 20 ticks
                task['nthTick'] = 20
            end
            if task.lastTick - task.nthTick >= game.tick then
                on_tick_n.add(game.tick + task.nthTick, task)
            end
        elseif task.action == 'reset_arti_speed' then
            local original = task.force.get_gun_speed_modifier('artillery-turret')
            task.force.set_gun_speed_modifier('artillery-turret', original - task.added)
        elseif task.action == 'reset_arti_range' then
            task.force.artillery_range_modifier = task.force.artillery_range_modifier - task.added
        elseif task.action == 'spawn_explosive' then
            map.spawn_explosive(task.player.surface, task.player.position, task.item, task.itemCount, task.player.character, task.chance, task.range, nil, task.rnd_tgt, task.homing)
            task.count = task.count - 1
            if task.count > 0 then
                on_tick_n.add(game.tick + task.delay, task)
            elseif #config['msg-player-barrage-end'] > 0 then
                task.player.force.print(config['msg-player-barrage-end'], constants.good)
            end
        elseif task.action == 'restore_lab_speed' then
            task.force.laboratory_speed_modifier = task.force.laboratory_speed_modifier - task.added
            if #config['msg-'] > 0 then
                task.force.print()
            end
        elseif task.action == 'disable_biter_revive' then
            global.silinthlp_biter_revive = nil
            if #config['msg-map-revive-biters-end'] > 0 then
                game.print(config['msg-map-revive-biters-end'], constants.good)
            end
        elseif task.action == 'dump_inventory' then
            fn_player.dump_inventory_impl(task.player, task.range, task.chance, task.end_tick, task.dropped)
        elseif task.action == 'cancel_handcraft' then
            fn_player.cancel_handcraft_impl(task)
        elseif task.action == 'start_handcraft' then
            fn_player.start_handcraft_impl(task)
        else
            game.print('WARNING! Event ' .. task.action .. ' is not implemented! Please report to SilentStorm at https://github.com/Sil3ntStorm/factorio-integration-helper/issues', constants.error)
        end
    end
end

local function onEntityDied(event)
    if not global.silinthlp_biter_revive then
        return
    end
    local cfg = global.silinthlp_biter_revive
    if math.random(1, 100) > cfg.chance then
        return
    end
    if cfg.surface and event.entity.surface ~= cfg.surface then
        return
    end
    if cfg.position and cfg.range and map.getDistance(cfg.position, event.entity.position) > cfg.range then
        return
    end
    local cmd = nil
    local target = nil
    if event.entity.type == 'Unit' then
        cmd = event.entity.command
    elseif event.entity.type == 'Turret' then
        target = event.shooting_target
    end
    if cmd and cmd.type == defines.command.attack then
        target = cmd.target
    end
    local ent = event.entity.surface.create_entity{
        name=event.entity.name,
        position=event.entity.position,
        force=event.entity.force,
        target=target,
    }
    if ent and cmd then
        ent.set_command(cmd)
    end
end

local function cancelTP()
    if global.silinthlp_nexttp then
        on_tick_n.remove(global.silinthlp_nexttp)
        global.silinthlp_nexttp = nil
    end
end

local function help()
    game.print([[Values in parentheses denote the default value if not specified. If applicable the valid range that is enforced for a parameter is listed after the default value. Available functions are:
    repair_base: surface, force, position, range (15), chance (75), minimum_health_gain (20), maximum_health_gain (150)
    build_ghosts: surface, force, position, range (20), chance (75), ignore_technology (false), include_remnants (false)
    build_bp: surface, force, position, blueprint_string, ignore_technology (false)
    deconstruct: surface, force, position (entire surface), range (500), chance (5), maximum_count (500), ignore_technology (false)
    gain_research: force, chance (75), percentage (random 10 - 75, 5% chance to decrease) Valid values: -100 to 100
    cancel_research: force, chance (50)
    disable_research: force, chance (50), seconds (random 30 - 300)
    random_research: force, chance (50)
    set_arti_speed: force, levels Valid range: 1 to 21, chance (50), duration (random 60 - 180)
    set_arti_range: force, levels Valid range: 1 to 21, chance (50), duration (random 60 - 180)
    set_lab_speed: force, percent change (random 1 - 100 5% chance to be negative) Valid range: -100 to 100, chance (75), duration (random 10 - 180)
    teleport_distance: player, destination surface, distance
    teleport_delay: player, target_surface, position, seconds
    enemy_arty: surface, force, position (0,0), range (random 500 - 5000), max (random 1 - 10), chance (random 10 - 100)
    remove_entity: surface, force, position (0, 0), range (random 40 - 200), entity name (randomly selected), max (random 5 - 20), chance (random 10 - 100)
    reset_recipe: surface, force, position (entire surface), range (500), chance (2), max_count (100)
    biter_revive: chance (random 10 - 100), duration (random 30 - 180), surface (any), position (anywhere), range (anywhere)
    modify_walk_speed: player, modifier percentage (100) Valid value: 1 - mod setting, duration (random 10 - 60 seconds), chance (100)
    modify_craft_speed: player, modifier percentage (100) Valid value: 1 - mod setting, duration (random 10 - 60 seconds), chance (100)
    on_fire: player, duration (random 10 - 60 seconds), range (random 10 - 40) valid range: 10 - 80, chance (80)
    barrage: player, item (explosive-rocket), range (random 10 - 50), count per shot (random 5 - 20), total shots (random 5 - 20), pause between shots (random 1 - 10 seconds), chance (90), homing (true) valid values: [true, false], random_target (true) valid values: [true, false]
    dump_inv: player, range (random 10 - 80 blocks), chance (random 50 - 100), delay after which dropping starts (0), duration over which to drop inventory (0, instant drop), mark_for_pickup (false) valid values [true, false]
    cancel_hand_craft: player, chance (random 25 - 80), delay (0 seconds), countdown (false) valid values [true, false]
    start_hand_craft: player, item name (random item that can be crafted), count (random 1 - 100) valid range: 1 - 1000, chance (100), delay (0 seconds)
    ]])
end

local function onLoad()
    remote.remove_interface('sil-integration-helper')
    remote.add_interface('sil-integration-helper', {
        repair_base=build.repair_base,
        build_ghosts=build.build_ghosts,
        build_bp=build.build_blueprint,
        deconstruct=build.deconstruct,
        gain_research=research.advance_research,
        cancel_research=research.cancel_research,
        disable_research=research.disable_research,
        random_research=research.start_research,
        set_arti_speed=research.set_arti_speed,
        set_arti_range=research.set_arti_range,
        set_lab_speed=research.change_speed,
        teleport_distance=map.teleport_random,
        teleport_delay_distance=map.teleport_delay, -- not yet done
        teleport_delay=map.timed_teleport,
        enemy_arty=map.enemy_artillery,
        remove_entity=map.remove_entities,
        reset_recipe=map.reset_assembler,
        biter_revive=map.revive_biters_on_death,
        modify_walk_speed=fn_player.modify_walk_speed,
        modify_craft_speed=fn_player.modify_craft_speed,
        on_fire=fn_player.on_fire,
        barrage=fn_player.barrage,
        dump_inv=fn_player.dump_inventory,
        cancel_hand_craft=fn_player.cancel_handcraft,
        start_hand_craft=fn_player.start_handcraft,
        help=help
    })
end

script.on_init(function()
    on_tick_n.init()
    research.init()
    onLoad()
end)

script.on_configuration_changed(function()
    -- catch new recipes on mod changes
    research.init()
end)

script.on_load(onLoad)
script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_entity_died, onEntityDied, {{filter='type', type='unit'}, {filter='type', type='turret', mode='or'}})
script.on_event(defines.events.on_player_created, function(event)
    local plr = game.get_player(event.player_index)
    if plr and plr.connected then
        plr.print('SilentStorm Integration Helper initialized')
        if DEV and plr.character then
            plr.character_running_speed_modifier = 1.2
        end
    end
end)
