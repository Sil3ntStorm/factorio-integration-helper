-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local map = {}
local on_tick_n = require('__flib__.on-tick-n')
local config = require('utils/config')
local strutil = require('utils/string_replace')
local constants = require('constants')
local proto = require('utils/proto')

function map.getDistance(pos, tgt)
    local x = (tgt.x - pos.x) ^ 2
    local y = (tgt.y - pos.y) ^ 2
    local d = (x + y) ^ 0.5
    return d
end

function map.getRandomPosInRange(pos, range)
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

--

function map.teleport_single(player, target_surface, position)
    local chunkPos = {x = position.x / 32, y = position.y / 32}
    if (not target_surface.is_chunk_generated(chunkPos)) then
        target_surface.request_to_generate_chunks(position, 2)
        target_surface.force_generate_chunk_requests()
    end
    local task = {}
    task['action'] = 'teleport_player'
    task['surface'] = target_surface
    task['player'] = player
    task['position'] = position
    if not global.silinthlp_teleport then
        global.silinthlp_teleport = {}
    end
    if not global.silinthlp_teleport[player.name] then
        global.silinthlp_teleport[player.name] = 1
    else
        global.silinthlp_teleport[player.name] = global.silinthlp_teleport[player.name] + 1
    end
    on_tick_n.add(game.tick + config['teleport-delay'], task)
end

function map.teleport_random(player, target_surface, distance)
    if not player or not target_surface or not distance then
        game.print('Missing parameters: player, target_surface, distance are required')
        return
    end
    local dest = map.getRandomPositionInRealDistance(player.position, distance)
    map.teleport_single(player, target_surface, dest)
end

function map.teleport_delay(player, target_surface, distance, seconds)
    game.print('not implemented')
end

function map.timed_teleport(player, target_surface, position, seconds)
    local task = {}
    task['action'] = 'teleport_delay'
    task['surface'] = target_surface
    task['player'] = player
    task['position'] = position
    task['delay'] = seconds

    on_tick_n.add(game.tick + 60, task)
end

function map.spawn_explosive(surface, position, item, count, target, chance, target_range, position_range, randomize_target)
    if not surface or not position or not item then
        game.print('surface, position and item are required')
        return
    end
    count = count or 1
    target = target or map.getRandomPosInRange(position, target_range)
    chance = chance or 100
    target_range = target_range or 20
    position_range = position_range or 80
    if randomize_target ~= false and randomize_target ~= true then
        randomize_target = true
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
            target = origTgtPos,
            speed = 0.5,
            max_range = 10
        }
    end

    if count > 1 then
        for i = 1, count do
            if math.random(1, 100) <= chance then
                local tgtPos = randomize_target and map.getRandomPosInRange(origTgtPos, target_range) or origTgtPos
                local srcPos2 = map.getRandomPosInRange(srcPos, 5 + count)
                surface.create_entity{
                    name = item,
                    position = srcPos2,
                    source_position = srcPos2,
                    target = tgtPos,
                    speed = 0.5,
                    max_range = target_range * 2
                }
            end
        end
    end
end

function map.reset_assembler(surface, force, position, range, chance, max_count)
    if not surface or not force then
        game.print('Invalid input parameters. Surface and Force are required')
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
            -- force.print('Reset ' .. e.name .. ' at [gps=' .. e.position.x .. ',' .. e.position.y .. '] doing ' .. e.get_recipe().name)
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
    if not surface or not force then
        game.print('surface and force are required')
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
    if not surface or not force then
        game.print('surface and force are required')
    end
    position = position or {x = 0, y = 0}
    range = range or math.random(50, 200)
    max = max or math.random(5, 20)
    chance = chance or math.random(25, 80)

    local function rndItem()
        local names = proto.get_entity_prototypes()
        local idx = math.random(1, #names)
        game.print('selected index ' .. idx .. ' which is ' .. names[idx])
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
    game.print('Found ' .. #found .. ' entities for ' .. name)
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

return map
