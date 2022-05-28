-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local constants = require('constants')
local research = require('funcs/research_tree')
local build = require('funcs/build')
local map = require('funcs/map')
local fn_player = require('funcs/player')
local config = require('utils/config')
local strutil = require('utils/string_replace')
local tp = require('funcs/teleport')
local on_tick_n = require('__flib__.on-tick-n')

local function showTextOnPlayer(msg, plr, color, scale)
    if #msg == 0 or not plr or not plr.connected or not plr.character then
        return
    end
    color = color or constants.neutral
    rendering.draw_text{text = msg, surface = plr.surface, target = plr.character, time_to_live = 60, forces = {plr.force}, color = color, scale_with_zoom = true, alignment = 'center', target_offset={0, -2.5}, scale=scale}
end

local function onTick(event)
    local list = on_tick_n.retrieve(event.tick)
    if not list then
        return
    end

    for _, task in pairs(list) do
        if task.action == 'enable_research' then
            research.enable_research(task.force, 100, task.queue, task.has_queue)
        elseif task.action == 'find_teleport_location' then
            tp.findRandomTeleportLocationForPlayer(task)
        elseif task.action == 'teleport_player' then
            if not global.silinthlp_teleport[task.player.name] then
                return
            end
            tp.actualTeleport(task.player, task.dest_surface, tp.getTeleportDestinationForPlayer(task.player, task.dest_surface))
        elseif task.action == 'teleport_delay' then
            if not task.player.valid or not task.player.connected then
                game.print('Player no longer connected, aborting teleport', constants.error)
                return
            end
            if task.delay == 0 then
                if not task.player.character or not task.player.character.valid then
                    -- player dead
                    on_tick_n.add(game.tick + 60, task)
                    return
                end
                local pos = nil
                if task.position then
                    -- fixed teleport
                    if not tp.checkTeleportLocationValid(task.dest_surface, task.position, task.player) then
                        task.position = tp.getNonCollidingPosition(task.dest_surface, task.position, task.player, 10) or task.position
                    end
                    tp.actualTeleport(task.player, task.dest_surface, task.position)
                else
                    -- Random teleport
                    task.action = 'find_teleport_location'
                    task.next_action = 'teleport_player'
                    on_tick_n.add(game.tick + 1, task)
                end
            else
                if #config['msg-map-teleport-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-map-teleport-countdown'], {task.player.name, task.delay})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, nil, scale)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'set_walking_speed' then
            if task.delay == 0 then
                fn_player.modify_walk_speed_impl(task)
            else
                if #config['msg-player-walk-speed-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-player-walk-speed-countdown'], {task.player.name, task.delay, task.duration, task.modifier})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, nil, scale)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'restore_walking_speed' then
            task.player.character_running_speed_modifier = task.original
            global.silinthlp_walk_speed[task.player.name] = nil
            if #config['msg-player-walk-speed-end'] > 0 then
                task.player.force.print(strutil.replace_variables(config['msg-player-walk-speed-end'], {task.player.name}), constants.neutral)
            end
        elseif task.action == 'set_crafting_speed' then
            if task.delay == 0 then
                fn_player.modify_craft_speed_impl(task)
            else
                if #config['msg-player-craft-speed-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-player-craft-speed-countdown'], {task.player.name, task.delay, task.duration, task.modifier})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, nil, scale)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'restore_crafting_speed' then
            task.player.character_crafting_speed_modifier = task.original
            global.silinthlp_craft_speed[task.player.name] = nil
            if #config['msg-player-craft-speed-end'] > 0 then
                task.player.force.print(strutil.replace_variables(config['msg-player-craft-speed-end'], {task.player.name}), constants.neutral)
            end
        elseif task.action == 'player_on_fire' then
            if game.tick < task.firstTick then
                if #config['msg-player-on-fire-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-player-on-fire-countdown'], {math.floor((task.firstTick - game.tick) / 60), math.floor((task.lastTick - task.firstTick) / 60), task.range})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, constants.bad, scale)
                end
                on_tick_n.add(game.tick + 60, task)
            else
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
            end
        elseif task.action == 'reset_arti_speed' then
            local original = task.force.get_gun_speed_modifier('artillery-shell')
            task.force.set_gun_speed_modifier('artillery-shell', original - task.added)
            if #config['msg-research-arti-speed-end'] > 0 then
                task.force.print(config['msg-research-arti-speed-end'], constants.bad)
            end
        elseif task.action == 'reset_arti_range' then
            task.force.artillery_range_modifier = task.force.artillery_range_modifier - task.added
            if #config['msg-research-arti-range-end'] > 0 then
                task.force.print(config['msg-research-arti-range-end'], constants.bad)
            end
        elseif task.action == 'spawn_explosive' then
            map.spawn_explosive(task.player.surface, task.player.position, task.item, task.itemCount, task.player.character, task.chance, task.range, nil, task.rnd_tgt, task.homing)
            task.count = task.count - 1
            if task.count > 0 then
                local delay = task.delay
                local tmp = strutil.split(delay, ':')
                if tmp[1] == 'random' then
                    tmp[2] = tmp[2] or 1
                    tmp[3] = tmp[3] or 10
                    delay = math.random(math.min(tmp[2], tmp[3]), math.max(tmp[2], tmp[3]))
                end
                on_tick_n.add(game.tick + delay * 60, task)
            elseif #config['msg-player-barrage-end'] > 0 then
                task.player.force.print(strutil.replace_variables(config['msg-player-barrage-end'], {task.player.name}), constants.good)
            end
        elseif task.action == 'restore_lab_speed' then
            task.force.laboratory_speed_modifier = task.force.laboratory_speed_modifier - task.added
            if #config['msg-research-lab-speed-end'] > 0 then
                task.force.print(strutil.replace_variables(config['msg-research-lab-speed-end'], {task.force.name}))
            end
        elseif task.action == 'enable_biter_revive' then
            if task.delay == 0 then
                map.revive_biters_on_death_impl(task)
            else
                if #config['msg-map-revive-biters-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-map-revive-biters-countdown'], {task.chance, task.duration, task.delay})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    for _, plr in pairs(game.players) do
                        local show = true
                        if task.surface and plr.surface ~= task.surface then
                            show = false
                        end
                        if task.position and task.range and map.getDistance(plr.position, task.position) >= task.range then
                            show = false
                        end
                        if show then
                            showTextOnPlayer(msg, plr, constants.bad, scale)
                        end
                    end
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'disable_biter_revive' then
            global.silinthlp_biter_revive = nil
            if #config['msg-map-revive-biters-end'] > 0 then
                game.print(config['msg-map-revive-biters-end'], constants.good)
            end
        elseif task.action == 'dump_inventory' then
            fn_player.dump_inventory_impl(task.player, task.range, task.chance, task.end_tick, task.dropped, task.pickup)
        elseif task.action == 'welcome' then
            game.print('SilentStorm Integration Helper initialized')
        elseif task.action == 'cancel_handcraft' then
            fn_player.cancel_handcraft_impl(task)
        elseif task.action == 'start_handcraft' then
            fn_player.start_handcraft_impl(task)
        elseif task.action == 'get_naked' then
            if task.delay == 0 then
                fn_player.get_naked_impl(task, true)
            else
                if #config['msg-player-naked-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-player-naked-countdown'], {task.player.name, task.delay, task.duration})
                    showTextOnPlayer(msg, task.player)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'dress_player' then
            local pos = map.getRandomPositionInRange(task.player.position, task.distance or 20)
            fn_player.give_armor_impl(task.player, task.worn, pos, true, task.distance > 0)
            for _, a in pairs(task.extra) do
                pos = map.getRandomPositionInRange(task.player.position, task.distance or 20)
                fn_player.give_armor_impl(task.player, a, pos, false, task.distance > 0)
            end
            if task.origin == 'naked' then
                if #config['msg-player-naked-end-ground'] > 0 and task.distance > 0 then
                    task.player.force.print(strutil.replace_variables(config['msg-player-naked-end-ground'], {task.player.name, task.distance}), constants.neutral)
                elseif #config['msg-player-naked-end'] > 0 and task.distance == 0 then
                    task.player.force.print(strutil.replace_variables(config['msg-player-naked-end'], {task.player.name}), constants.good)
                end
            end
        elseif task.action == 'disconnect_wires' then
            if task.delay == 0 then
                map.disconnect_wires_impl(task)
            else
                if #config['msg-map-snap-wires-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-map-snap-wires-countdown'], {task.delay, task.range, strutil.get_gps_tag(task.surface, task.position)})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    for _, plr in pairs(game.players) do
                        if plr.force == task.force then
                            showTextOnPlayer(msg, plr, constants.bad, scale)
                        end
                    end
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'load_ammunition' then
            if task.delay == 0 then
                map.load_ammunition_impl(task)
            else
                if #config['msg-map-load-ammo-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-map-load-ammo-countdown'], {{'item-name.' .. task.ammo}, task.delay})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    for _, plr in pairs(game.players) do
                        local show = true
                        if task.surface and plr.surface ~= task.surface then
                            show = false
                        end
                        if task.position and task.range and map.getDistance(plr.position, task.position) >= task.range then
                            show = false
                        end
                        if show then
                            showTextOnPlayer(msg, plr, constants.good, scale)
                        end
                    end
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'vacuum' then
            if task.delay == 0 then
                fn_player.vacuum_impl(task)
            else
                if #config['msg-player-vacuum-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-player-vacuum-countdown'], {task.player.name, task.range, task.delay, task.duration})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, constants.good, scale)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'reset-vacuum' then
            if #config['msg-player-vacuum-end'] > 0 then
                task.player.force.print(strutil.replace_variables(config['msg-player-vacuum-end'], {task.player.name}), constants.bad)
            end
            task.player.character_item_pickup_distance_bonus = task.player.character_item_pickup_distance_bonus - task.range
            task.player.character_loot_pickup_distance_bonus = task.player.character_loot_pickup_distance_bonus - task.range
        elseif task.action == 'advance_rocket' then
            if task.delay == 0 then
                map.advance_rocket_silo_impl(task)
            else
                if #config['msg-map-adv-silo-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-map-adv-silo-countdown'], {task.surface.name, strutil.get_gps_tag(task.surface, task.position or {x=0, y=0}), task.position ~= nil and task.range or '∞', task.chance, strutil.split(task.parts, ':')[1], task.delay})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    for _, plr in pairs(game.players) do
                        local show = true
                        if task.surface and plr.surface ~= task.surface then
                            show = false
                        end
                        if task.position and task.range and map.getDistance(plr.position, task.position) >= task.range then
                            show = false
                        end
                        if task.force ~= plr.force then
                            show = false
                        end
                        if show then
                            showTextOnPlayer(msg, plr, constants.good, scale)
                        end
                    end
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'set_shields' or task.action == 'set_batteries' then
            if task.delay == 0 then
                local conf_name = 'msg-player-'
                if task.action == 'set_shields' then
                    conf_name = conf_name .. 'shields'
                else
                    conf_name = conf_name .. 'batt'
                end
                if task.percent < 0 then
                    conf_name = conf_name .. '-dec'
                else
                    conf_name = conf_name .. '-inc'
                end
                if task.duration > 0 then
                    conf_name = conf_name .. '-dur'
                end
                if task.print and #config[conf_name] > 0 then
                    local msg = ''
                    if task.duration > 0 then
                        msg = strutil.replace_variables(config[conf_name], {task.player.name, task.percent, task.duration})
                    else
                        msg = strutil.replace_variables(config[conf_name], {task.player.name, task.percent})
                    end
                    task.player.force.print(msg, task.percent > 0 and constants.good or constants.bad)
                end
                task.print = false
                if task.action == 'set_shields' then
                    fn_player.set_shields_impl(task)
                else
                    fn_player.set_battery_impl(task)
                end
                if game.tick < task.end_tick then
                    on_tick_n.add(game.tick + 30, task)
                else
                    -- It's all over
                    local conf_name = 'msg-player-'
                    if task.action == 'set_shields' then
                        conf_name = conf_name .. 'shields'
                    else
                        conf_name = conf_name .. 'batt'
                    end
                    conf_name = conf_name .. '-end'
                    log('attempting ' .. conf_name)
                    if #config[conf_name] > 0 then
                        local msg = strutil.replace_variables(config[conf_name], {task.player.name})
                        task.player.force.print(msg, constants.good)
                    end
                end
            else
                local conf_name = task.action == 'set_shields' and 'msg-player-shields-countdown' or 'msg-player-batt-countdown'
                if #config[conf_name] > 0 then
                    local color = constants.neutral
                    local v = strutil.split(task.percent, ':')[1]
                    if type(task.percent) == 'number' then
                        v = task.absolute and math.abs(task.percent) or task.percent
                        color = v < 0 and constants.bad or constants.good
                    end
                    local msg = strutil.replace_variables(config[conf_name], {task.player.name, v, task.delay})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, color, scale)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        else
            game.print('WARNING! Event ' .. (task.action or 'NA') .. ' is not implemented! Please report to SilentStorm at https://github.com/Sil3ntStorm/factorio-integration-helper/issues', constants.error)
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
    teleport_delay: player, target_surface, position, seconds (random 1 - 10)
    teleport_delay_distance: player, target_surface, distance, seconds (random 1 - 10)
    enemy_arty: surface, force, position (0,0), range (random 500 - 5000), max (random 1 - 10), chance (random 10 - 100)
    remove_entity: surface, force, position (0, 0), range (random 40 - 200), entity name (randomly selected), max (random 5 - 20), chance (random 10 - 100)
    reset_recipe: surface, force, position (entire surface), range (500), chance (2), max_count (100)
    biter_revive: chance (random 10 - 100), duration (random 30 - 180), surface (any), position (anywhere), range (anywhere), delay (0 seconds)
    snap_wires: surface, force, position, range (random 50 - 200), circuit (true) [true, false], power (true) [true, false], chance (random 20 - 80), delay (0 seconds)
    load_turrets: surface, force, position (0, 0), range (entire surface), ammo_type (yellow ammo), chance (random 60 - 90 %), count (random 5 - 50) ['random' or numeric value to give same amount to all turrets], replace (false), delay (0 seconds)
    advance_rocket: surface, force, position (0, 0), range (entire surface), parts (random 10 - 75) ['random' or numeric value to give same to every silo. Can be negative to remove parts from silos], chance (random 60-90%), delay (0 seconds)
    modify_walk_speed: player, modifier percentage (100) Valid value: 1 - mod setting, duration (random 10 - 60 seconds), chance (100), delay (0 seconds)
    modify_craft_speed: player, modifier percentage (100) Valid value: 1 - mod setting, duration (random 10 - 60 seconds), chance (100), delay (0 seconds)
    on_fire: player, duration (random 10 - 60 seconds), range (random 10 - 40) valid range: 4 - 80, chance (80), delay (0 seconds)
    barrage: player, item (explosive-rocket), range (random 10 - 50), count per shot (random 5 - 20), total shots (random 5 - 20), pause between shots (random 1 - 10 seconds) ['random' or numeric value in seconds], chance (90), delay (0), homing (25% of count) valid values: [number <= count], random_target (true) valid values: [true, false]
    dump_inv: player, range (random 10 - 80 blocks), chance (random 50 - 100), delay after which dropping starts (0), duration over which to drop inventory (0, instant drop), mark_for_pickup (false) valid values [true, false]
    cancel_hand_craft: player, chance (random 25 - 80), delay (0 seconds), duration(0 seconds), countdown (false) valid values [true, false]
    start_hand_craft: player, item name (random item that can be crafted), count (random 1 - 100) valid range: 1 - 1000, chance (100), delay (0 seconds)
    get_naked: player, delay (0 seconds), distance (random 50 - 100), duration (random 2 - 10 seconds)
    vacuum: player, range (random 1 - 5), duration (random 5 - 20 seconds) [valid: 1 - 300], chance (random 75 - 95), delay (0 seconds)
    ]])
end

local function onLoad()
    remote.remove_interface('silentstorm-integration-helper')
    remote.add_interface('silentstorm-integration-helper', {
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
        teleport_delay=map.timed_teleport,
        teleport_delay_distance=map.timed_teleport_random,
        enemy_arty=map.enemy_artillery,
        remove_entity=map.remove_entities,
        reset_recipe=map.reset_assembler,
        biter_revive=map.revive_biters_on_death,
        snap_wires=map.disconnect_wires,
        load_turrets=map.load_ammunition,
        advance_rocket=map.advance_rocket_silo,
        modify_walk_speed=fn_player.modify_walk_speed,
        modify_craft_speed=fn_player.modify_craft_speed,
        on_fire=fn_player.on_fire,
        barrage=fn_player.barrage,
        dump_inv=fn_player.dump_inventory,
        cancel_hand_craft=fn_player.cancel_handcraft,
        start_hand_craft=fn_player.start_handcraft,
        get_naked=fn_player.get_naked,
        vacuum=fn_player.vacuum,
        drain_battery=fn_player.discharge_batteries,
        drain_shield=fn_player.discharge_shields,
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
    game.print('SilentStorm Integration Helper initialized')
end)

script.on_load(onLoad)
script.on_event(defines.events.on_tick, onTick)
script.on_event(defines.events.on_entity_died, onEntityDied, {{filter='type', type='unit'}, {filter='type', type='turret', mode='or'}})
script.on_event({defines.events.on_player_created, defines.events.on_player_joined_game}, function(event)
    local plr = game.get_player(event.player_index)
    if plr and plr.connected then
        plr.print('SilentStorm Integration Helper initialized')
    end
end)
