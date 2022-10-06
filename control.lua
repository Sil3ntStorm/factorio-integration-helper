﻿-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
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
local fml = require('utils/lua_is_stupid')
local mapping = fml.include('utils/mapping')

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
            if task.player and task.player.character then
                -- We can forego resetting the character speed when dead, as a new character won't have the buff in the first place
                task.player.character_running_speed_modifier = task.original
            end
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
            if task.player and task.player.character then
                -- We can forego resetting the character speed when dead, as a new character won't have the buff in the first place
                task.player.character_crafting_speed_modifier = task.original
            end
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
                    local ok = fn_player.set_on_fire(task.player, task.range, task.chance)
                    if ok then
                        task['lastPos'] = task.player.position
                        task['executed'] = game.tick
                    end
                end
                if task.player.character then
                    task['nthTick'] = math.max(1, math.floor((task.range / 2 - 2) / (1 + math.max(task.player.character_running_speed_modifier, task.player.character_running_speed))))
                else
                    -- player dead, try again in 20 ticks and increase duration
                    task['nthTick'] = 20
                    if task.executed == 0 then
                        if not task.original_end then
                            task['original_end'] = task.lastTick
                        end
                        task.lastTick = task.lastTick + 20
                    end
                end
                if task.original_end and task.original_end + 60 * 120 < game.tick then
                    -- 2 minutes after original end, just kill it.
                    return
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
            map.spawn_explosive(task.player.surface, task.player.position, task.item, task.itemCount, task.player.character, task.chance, task.range, nil, task.rnd_tgt, task.homing, task.speed_modifier, task.range_modifier)
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
            if task.delay == 0 then
                fn_player.cancel_handcraft_impl(task, true)
            else
                if #config['msg-player-cancel-handcraft-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-player-cancel-handcraft-countdown'], {task.player.name, task.delay, task.duration, task.chance})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, constants.bad, scale)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
        elseif task.action == 'start_handcraft' then
            if task.delay == 0 then
                fn_player.start_handcraft_impl(task)
            else
                if #config['msg-player-start-handcraft-countdown'] > 0 then
                    local msg = strutil.replace_variables(config['msg-player-start-handcraft-countdown'], {task.player.name, task.delay, task.chance})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    showTextOnPlayer(msg, task.player, constants.neutral, scale)
                end
                task.delay = task.delay - 1
                on_tick_n.add(game.tick + 60, task)
            end
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
            fn_player.give_armor_impl(task.player, task.worn, pos, true, task.distance > 0, task.battery_pct, task.shield_pct)
            for _, a in pairs(task.extra) do
                pos = map.getRandomPositionInRange(task.player.position, task.distance or 20)
                fn_player.give_armor_impl(task.player, a, pos, false, task.distance > 0, task.battery_pct, task.shield_pct)
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
            task.player.character_item_pickup_distance_bonus = math.min(0, task.player.character_item_pickup_distance_bonus - task.range)
            task.player.character_loot_pickup_distance_bonus = math.min(0, task.player.character_loot_pickup_distance_bonus - task.range)
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
        elseif task.action == 'auto_pickup' then
            fn_player.auto_pickup_impl(task)
        elseif task.action == 'rain_item' then
            if task.delay == 0 then
                map.rain_item_impl(task)
            else
                if #config['msg-map-rain-countdown'] > 0 then
                    local sur = task.entity and task.entity.surface or task.surface
                    local pos = task.entity and task.entity.position or task.position
                    local msg = strutil.replace_variables(config['msg-map-rain-countdown'], {task.count, mapping.locale_tuple(task.item), task.range, strutil.get_gps_tag(sur, pos), sur.name, task.duration, task.delay})
                    local scale = nil
                    if #msg < 5 then
                        scale = 1.7
                    end
                    for _, plr in pairs(game.players) do
                        local show = true
                        if sur and plr.surface ~= task.surface then
                            show = false
                        end
                        if pos and task.range and map.getDistance(plr.position, pos) >= task.range then
                            show = false
                        end
                        if show then
                            showTextOnPlayer(msg, plr, constants.neutral, scale)
                        end
                    end
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
        forget_research=research.unresearch_tech,
        set_arti_speed=research.set_arti_speed,
        set_arti_range=research.set_arti_range,
        set_lab_speed=research.change_speed,
        teleport=map.timed_teleport,
        teleport_distance=map.timed_teleport_random,
        enemy_arty=map.enemy_artillery,
        remove_entity=map.remove_entities,
        reset_recipe=map.reset_assembler,
        biter_revive=map.revive_biters_on_death,
        snap_wires=map.disconnect_wires,
        load_turrets=map.load_ammunition,
        advance_rocket=map.advance_rocket_silo,
        rain_item=map.rain_item,
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
