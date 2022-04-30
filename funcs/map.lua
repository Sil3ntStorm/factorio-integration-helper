-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local map = {}
local on_tick_n = require('__flib__.on-tick-n')
local fml = require('utils/lua_is_stupid')
local config = fml.include('utils/config')
local strutil = fml.include('utils/string_replace')
local constants = fml.include('constants')
local proto = fml.include('utils/proto')
local tp = fml.include('funcs/teleport')
local tc = require('utils/type_check')

function map.getDistance(pos, tgt)
    local x = (tgt.x - pos.x) ^ 2
    local y = (tgt.y - pos.y) ^ 2
    local d = (x + y) ^ 0.5
    return d
end

function map.getRandomPositionInRange(pos, range)
    local x = pos.x - range / 2
    local y = pos.y - range / 2
    local x2 = pos.x + range / 2
    local y2 = pos.y + range / 2
    return {x = math.random(x, x2), y = math.random(y, y2)}
end

function map.getRandomPosition(pos, min, max)
    if min > max then
        min = max
    end
    local rand_x = math.random(min or 0, max or 10)
    local rand_y = math.random(min or 0, max or 10)
    local x = pos.x + (math.random() >= .5 and -rand_x or rand_x)
    local y = pos.y + (math.random() >= .5 and -rand_y or rand_y)
    return {x = x, y = y}
end

function map.getRandomPositionInRealDistance(pos, distance)
    -- inspired by stdlib::Position
    local direction = math.random(0, 360)
    local x = pos.x + math.sin(direction) * distance
    local y = pos.y + math.cos(direction) * distance
    return {x=x, y=y}
end

function map.set_equipment_for_item_on_ground(item_on_ground, equip)
    -- Should be moved out of here maybe?
    if not item_on_ground.stack.grid then
        item_on_ground.stack.create_grid()
    end
    for _, eq in pairs(equip) do
        item_on_ground.stack.grid.put{name = eq.name, position = eq.position}
    end
end

--

function map.teleport_random(player, target_surface, distance)
    if not tc.is_player(player) or not tc.is_surface(target_surface) or type(distance) ~= 'number' then
        game.print('Missing parameters: player, target_surface, distance are required', constants.error)
        return
    end
    local task = {}
    task['action'] = 'find_teleport_location'
    task['player'] = player
    task['dest_surface'] = target_surface
    task['distance'] = distance
    task['next_action'] = 'teleport_player'

    on_tick_n.add(game.tick + 1, task)
end

function map.timed_teleport_random(player, target_surface, distance, seconds)
    if not tc.is_player(player) or not tc.is_surface(target_surface) or type(distance) ~= 'number' then
        game.print('Missing parameters: player, target_surface, distance are required', constants.error)
        return
    end
    seconds = seconds or math.random(1, 10)

    local task = {}
    task['action'] = 'teleport_delay'
    task['player'] = player
    task['dest_surface'] = target_surface
    task['delay'] = seconds - 1
    task['distance'] = distance

    on_tick_n.add(game.tick + 60, task)
    if #config['msg-map-teleport-countdown'] > 0 then
        task.player.force.print(strutil.replace_variables(config['msg-map-teleport-countdown'], {task.player.name, seconds}), constants.neutral)
    end
end

function map.timed_teleport(player, target_surface, position, seconds)
    if not tc.is_player(player) or not tc.is_surface(target_surface) or not tc.is_position(position) then
        game.print('Missing parameters: player, target_surface, position are required', constants.error)
        return
    end
    seconds = seconds or math.random(1, 10)

    local task = {}
    task['action'] = 'teleport_delay'
    task['dest_surface'] = target_surface
    task['player'] = player
    task['position'] = position
    task['delay'] = seconds - 1

    on_tick_n.add(game.tick + 60, task)
    if #config['msg-map-teleport-countdown'] > 0 then
        task.player.force.print(strutil.replace_variables(config['msg-map-teleport-countdown'], {task.player.name, seconds}), constants.neutral)
    end
end

function map.spawn_explosive(surface, position, item, count, target, chance, target_range, position_range, randomize_target, homing)
    if not tc.is_surface(surface) or not tc.is_position(position) or not item then
        game.print('surface, position and item are required', constants.error)
        return
    end
    count = count or 1
    target = target or map.getRandomPositionInRange(position, target_range)
    chance = chance or 100
    target_range = target_range or 20
    position_range = position_range or 80
    if randomize_target ~= false and randomize_target ~= true then
        randomize_target = true
    end
    if homing ~= false and homing ~= true then
        homing = true
    end

    if not fml.contains(proto.get_projectiles(), item) then
        game.print(item .. ' is not a valid type!', constants.error)
        return
    end

    local origTgtPos = {}
    if target.position then
        origTgtPos = target.position
    else
        origTgtPos = target
    end

    local srcPos = map.getRandomPositionInRealDistance(position, position_range)
    if count > 0 or math.random(1, 100) <= chance then
        surface.create_entity{
            name = item,
            position = srcPos,
            source_position = srcPos,
            target = homing and target or origTgtPos,
            speed = 0.5,
            max_range = map.getDistance(origTgtPos, srcPos) * 1.25
        }
    end

    if count > 1 then
        for i = 1, count do
            if math.random(1, 100) <= chance then
                local tgtPos = randomize_target and map.getRandomPositionInRange(origTgtPos, target_range) or (homing and target or origTgtPos)
                local tgtPos2 = tgtPos
                if tgtPos2.position then
                    tgtPos2 = tgtPos2.position
                end
                local srcPos2 = map.getRandomPositionInRange(srcPos, 5 + count)
                surface.create_entity{
                    name = item,
                    position = srcPos2,
                    source_position = srcPos2,
                    target = tgtPos,
                    speed = 0.5,
                    max_range = math.max(target_range * 2, map.getDistance(tgtPos2, srcPos2) * 1.25)
                }
            end
        end
    end
end

function map.reset_assembler(surface, force, position, range, chance, max_count)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('Invalid input parameters. Surface and Force are required', constants.error)
        return
    end
    range = range or 500
    chance = chance or 2
    max_count = max_count or 100

    chance = chance * 10

    local entities = {}
    if position then
        entities = surface.find_entities_filtered{position=position, radius=range, force=force, to_be_deconstructed=false, type='assembling-machine'}
    else
        entities = surface.find_entities_filtered{force=force, to_be_deconstructed=false, type='assembling-machine'}
    end
    local actual = {}
    for _, e in pairs(entities) do
        if not e.recipe_locked and e.get_recipe() ~= nil and e.name ~= 'water-well-pump' and #e.get_recipe().ingredients > 0 then
            table.insert(actual, e)
        end
    end

    local count = 0
    for _, e in pairs(actual) do
        if count < max_count and math.random(1, 1000) <= chance then
            local items = e.set_recipe(nil)
            for item, cnt in pairs(items) do
                surface.spill_item_stack(e.position, {name=item, count=cnt}, false)
            end
            count = count + 1
        end
    end

    if #config['msg-map-reset-assembler'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-reset-assembler'], {count}), count > 0 and constants.bad or constants.neutral)
    end
end

function map.revive_biters_on_death(chance, duration, surface, position, range)
    chance = chance or math.random(10, 100)
    duration = duration or math.random(30, 180)

    chance = math.max(0, math.min(chance, 100))

    local task = {}
    task['action'] = 'disable_biter_revive'
    task['chance'] = chance
    task['surface'] = surface
    task['position'] = position
    task['range'] = range
    task['ends'] = game.tick + duration * 60
    
    global.silinthlp_biter_revive = task
    on_tick_n.add(task.ends, task)

    if #config['msg-map-revive-biters'] > 0 then
        game.print(strutil.replace_variables(config['msg-map-revive-biters'], {chance, duration}), chance > 0 and constants.bad or constants.neutral)
    end
end

function map.enemy_artillery(surface, force, position, range, max, chance)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('surface and force are required', constants.error)
        return
    end
    position = position or {x=0, y=0}
    range = range or math.random(500, 5000)
    max = max or math.random(1, 10)
    chance = chance or math.random(10, 100)

    chance = math.max(0, math.min(chance, 100))

    local found = surface.find_entities_filtered{type='artillery-turret', radius=range, force=force, position=position}
    local cnt = 0
    for _, e in pairs(found) do
        if math.random(1, 100) <= chance then
            e.force = 'enemy'
            cnt = cnt + 1
        end
        if cnt >= max then
            break
        end
    end
    if #config['msg-map-enemy-turret'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-enemy-turret'], {cnt, range}), cnt > 0 and constants.bad or constants.neutral)
    end
end

function map.remove_entities(surface, force, position, range, name, max, chance)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('surface and force are required', constants.error)
        return
    end
    position = position or {x = 0, y = 0}
    range = range or math.random(50, 200)
    max = max or math.random(5, 20)
    chance = chance or math.random(25, 80)

    local function rndItem()
        local names = proto.get_entity_prototypes()
        local idx = math.random(1, fml.actual_size(names))
        return names[idx]
    end
    local allowRandom = false
    if not name then
        name = rndItem()
        allowRandom = true
    end

    chance = math.max(0, math.min(chance, 100))
    local found = surface.find_entities_filtered{name=name, force=force, radius=range, position=position}
    local lp = 1
    while allowRandom and #found == 0 and lp < 50 do
        name = rndItem()
        found = surface.find_entities_filtered{name=name, force=force, radius=range, position=position}
        lp = lp + 1
    end
    local cnt = 0
    for _, e in pairs(found) do
        if math.random(1, 100) <= chance then
            if e.destroy({raise_destroy=true}) then
                cnt = cnt + 1
            end
        end
        if cnt >= max then
            break
        end
    end
    if #found == 0 and #config['msg-map-remove-entity-nothing'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-remove-entity-nothing'], {{'entity-name.' .. name}}), constants.neutral)
    elseif #config['msg-map-remove-entity'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-remove-entity'], {cnt, {'entity-name.' .. name}}), cnt > 0 and constants.bad or constants.neutral)
    end
end

function map.disconnect_wires(surface, force, position, range, circuit, power, chance)
    if not tc.is_surface(surface) or not tc.is_force(force) or not tc.is_position(position) then
        game.print('Invalid / missing parameters: surface, force and position are required', constants.error)
        return
    end

    range = range or math.random(50, 200)
    chance = chance or math.random(20, 80)

    chance = math.max(1, math.min(100, chance))

    if circuit ~= true and circuit ~= false then
        circuit = true
    end
    if power ~= true and power ~= false then
        power = true
    end

    local result = surface.find_entities_filtered{position = position, radius = range, force = force}
    local count = 0
    local count_pwr = 0
    for _, ent in pairs(result) do
        if math.random(1, 100) <= chance then
            if circuit and ent.circuit_connected_entities then
                count = count + #ent.circuit_connected_entities.green + #ent.circuit_connected_entities.red
                ent.disconnect_neighbour(defines.wire_type.red)
                ent.disconnect_neighbour(defines.wire_type.green)
            end
            if power then
                local old_id = ent.electric_network_id
                ent.disconnect_neighbour(defines.wire_type.copper)
                if ent.electric_network_id ~= old_id then
                    count_pwr = count_pwr + 1
                end
            end
        end
    end
    if #config['msg-map-snap-wires'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-snap-wires'], {count, count_pwr, range, strutil.get_gps_tag(surface, position)}), count + count_pwr > 0 and constants.bad or constants.neutral)
    end
end

return map
