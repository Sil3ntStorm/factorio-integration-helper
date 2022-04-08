-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local player = {}

local constants = require('constants')
local config = require('utils/config')
local strutil = require('utils/string_replace')
local map = require('funcs/map')
local fml = require('utils/lua_is_stupid')
local on_tick_n = require('__flib__.on-tick-n')

function player.modify_walk_speed(player_, modifier, duration, chance)
    if not player_ then
        game.print('player is required', constants.error)
        return
    end
    if not player_.character then
        game.print('player must have a character', constants.error)
        return
    end
    modifier = modifier or 100
    -- clamp value
    modifier = math.max(1, math.min(config['max-walk-speed-modifier'], modifier))
    duration = duration or math.random(10, 60)
    chance = chance or 100

    if math.random(1, 100) > chance then
        return
    end
    if not global.silinthlp_walk_speed then
        global.silinthlp_walk_speed = {}
    end
    if global.silinthlp_walk_speed[player_.name] then
        -- We already adjusted this player.
        return
    end

    local original = player_.character_running_speed_modifier

    local task = {}
    task['action'] = 'restore_walking_speed'
    task['player'] = player_
    task['modifier'] = modifier
    task['original'] = original

    global.silinthlp_walk_speed[player_.name] = on_tick_n.add(game.tick + (duration * 60), task)

    player_.character_running_speed_modifier = math.max(-0.97, (original * 100 + modifier) / 100 - 1)
    if modifier < 100 and #config['msg-player-walk-speed-dec'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-walk-speed-dec'], {player_.name, 100 - modifier, duration}), constants.bad)
    elseif modifier >= 100 and #config['msg-player-walk-speed-inc'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-walk-speed-inc'], {player_.name, modifier - 100, duration}), constants.good)
    end
end

function player.modify_craft_speed(player_, modifier, duration, chance)
    if not player_ then
        game.print('player is required', constants.error)
        return
    end
    if not player_.character then
        game.print('player must have a character', constants.error)
        return
    end
    modifier = modifier or 100
    -- clamp value
    modifier = math.max(1, math.min(config['max-craft-speed-modifier'], modifier))
    duration = duration or math.random(10, 60)
    chance = chance or 100

    if math.random(1, 100) > chance then
        return
    end
    if not global.silinthlp_craft_speed then
        global.silinthlp_craft_speed = {}
    end
    if global.silinthlp_craft_speed[player_.name] then
        -- We already adjusted this player.
        return
    end

    local original = player.character_crafting_speed_modifier

    local task = {}
    task['action'] = 'restore_crafting_speed'
    task['player'] = player_
    task['modifier'] = modifier
    task['original'] = original

    global.silinthlp_craft_speed[player_.name] = on_tick_n.add(game.tick + (duration * 60), task)

    player_.character_crafting_speed_modifier = math.max(-0.97, (original * 100 + modifier) / 100 - 1)
    if modifier < 100 and #config['msg-player-craft-speed-dec'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-craft-speed-dec'], {player_.name, 100 - modifier, duration}), constants.bad)
    elseif modifier >= 100 and #config['msg-player-craft-speed-inc'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-craft-speed-inc'], {player_.name, modifier - 100, duration}), constants.good)
    end
end

function player.set_on_fire(player, range, chance)
    if not player.character then
        -- possibly dead right now.
        return
    end
    range = math.min(100, math.max(0, range))
    local x = player.position.x - range
    local y = player.position.y - range
    local x2 = player.position.x + range
    local y2 = player.position.y + range
    while x < x2 do
        local y3 = y
        while y3 < y2 do
            if math.random(1, 100) <= chance and map.getDistance(player.position, {x=x, y=y3}) <= range then
                player.surface.create_entity{
                    position = {x = x, y = y3},
                    name = 'fire-flame-on-tree',
                    target = player.character
                }
            end
            y3 = y3 + 1
        end
        x = x + 1
    end
end

function player.on_fire(player_, duration, range, chance)
    if not player_ then
        game.print('player is required', constants.error)
        return
    end
    duration = duration or math.random(10, 60)
    range = range or math.random(10, 40)
    chance = chance or 80
    
    range = math.min(80, math.max(10, range))

    local task = {}
    task['action'] = 'player_on_fire'
    task['player'] = player_
    task['chance'] = chance
    task['range'] = range
    task['lastTick'] = game.tick + duration * 60
    task['lastPos'] = player_.position
    task['executed'] = game.tick
    task['nthTick'] = math.max(1, math.floor((range / 2 - 2) / (1 + math.max(player_.character_running_speed_modifier, player_.character_running_speed))))

    player.set_on_fire(player_, range, chance)
    on_tick_n.add(game.tick + task.nthTick, task)
    if #config['msg-player-on-fire'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-on-fire'], {player_.name, range, duration}), constants.bad)
    end
end

function player.barrage(player_, itemToSpawn, range, countPerVolley, count, secondsBetweenVolley, chance, homing, randomize_target)
    if not player_ then
        game.print('player is required', constants.error)
        return
    end
    
    itemToSpawn = itemToSpawn or 'explosive-rocket'
    range = range or math.random(10, 50)
    countPerVolley = countPerVolley or math.random(5, 20)
    count = count or math.random(2, 20)
    secondsBetweenVolley = secondsBetweenVolley or math.random(1, 10)
    chance = chance or 90
    if homing ~= false and homing ~= true then
        homing = true
    end
    if randomize_target ~= false and randomize_target ~= true then
        randomize_target = true
    end

    local task = {}
    task['action'] = 'spawn_explosive'
    task['player'] = player_
    task['chance'] = chance
    task['item'] = itemToSpawn
    task['count'] = count - 1
    task['delay'] = secondsBetweenVolley * 60
    task['itemCount'] = countPerVolley
    task['range'] = range
    task['homing'] = homing
    task['rnd_tgt'] = randomize_target
    
    if #config['msg-player-barrage-start'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-barrage-start'], {player_.name, countPerVolley, {'item-name.' .. itemToSpawn}, secondsBetweenVolley, count}), constants.bad)
    end
    if math.random(1, 100) <= chance then
        map.spawn_explosive(task.player.surface, task.player.position, task.item, task.itemCount, task.player.character, task.chance, task.range, nil, task.rnd_tgt, task.homing)
    end
    if count > 1 then
        on_tick_n.add(game.tick + secondsBetweenVolley * 60, task)
    elseif #config['msg-player-barrage-end'] > 0 then
        player_.force.print(config['msg-player-barrage-end'], constants.good)
    end
end

function player.dump_inventory_done_msg(player_, dropped)
    if #config['msg-player-dump-inventory-end'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-dump-inventory-end'], {player_.name, dropped}), constants.good)
    end
end

function player.dump_inventory_stack(player_, item, range, do_pickup)
    if not player_ or not player_.character or not item or not range then
        return nil
    end
    
    local inv = player_.get_main_inventory()
    if not inv then
        return nil
    end
    
    local stack = inv.find_item_stack(item)
    if not stack then
        return nil
    end

    local count = stack.count
    for i = 1, count do
        local pos = map.getRandomPosInRange(player_.position, range)
        player_.surface.spill_item_stack(pos, {name=stack.name, count=1}, false, do_pickup and player_.force or nil)
    end
    inv.remove(stack)
    return count
end

function player.dump_inventory_impl(player_, range, chance, endTick, prevRuns, do_pickup)
    local inv = player_.character.get_main_inventory()
    local content = inv.get_contents()
    local stackCount = fml.actual_size(content)

    local keys = {}
    local n = 0
    for k,v in pairs(content) do
        n = n + 1
        keys[n] = k
        -- Adjust to get real stack count
        stackCount = stackCount + math.ceil(v / game.item_prototypes[k].stack_size) - 1
    end
    local randomStackName = keys[1]
    if #keys > 1 then
        randomStackName = keys[math.random(1, #keys)]
    end

    if stackCount <= 0 then
        if prevRuns == 0 then
            player_.force.print('No inventory items found', constants.bad)
        else
            player.dump_inventory_done_msg(player_, prevRuns)
        end
        return
    end

    local nextRun = endTick - game.tick
    if nextRun > stackCount then
        nextRun = game.tick + math.floor(nextRun / stackCount)
    end

    if math.random(1, 100) <= chance then
        local cnt = player.dump_inventory_stack(player_, randomStackName, range, do_pickup)
        if cnt then
            prevRuns = prevRuns + cnt
        end
    end

    if endTick == game.tick then
        -- instant drop
        for name, count in pairs(inv.get_contents()) do
            for i = 1, math.ceil(count / game.item_prototypes[name].stack_size) do
                if math.random(1, 100) <= chance then
                    local cnt = player.dump_inventory_stack(player_, name, range, do_pickup)
                    if cnt then
                        prevRuns = prevRuns + cnt
                    end
                end
            end
        end
    end

    if nextRun > game.tick then
        local task = {}
        task['action'] = 'dump_inventory'
        task['player'] = player_
        task['range'] = range
        task['chance'] = chance
        task['duration'] = duration
        task['dropped'] = prevRuns
        task['pickup'] = do_pickup
        task['end_tick'] = endTick

        on_tick_n.add(nextRun, task)
    else
        player.dump_inventory_done_msg(player_, prevRuns)
    end
end

-- public entry point
function player.dump_inventory(player_, range, chance, delay, duration, pickup)
    if not player_ or not player_.valid or not player_.character then
        game.print('player is required and must be a valid player with a character', constants.error)
        return
    end
    range = range or math.random(10, 80)
    chance = chance or math.random(50, 100)
    chance = math.min(100, math.max(1, chance))
    delay = delay or 0
    duration = duration or 0
    if pickup ~= false and pickup ~= true then
        pickup = false
    end

    if #config['msg-player-dump-inventory'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-dump-inventory'], {player_.name, range, duration}), constants.bad)
    end

    if delay > 0 then
        local task = {}
        task['action'] = 'dump_inventory'
        task['player'] = player_
        task['range'] = range
        task['chance'] = chance
        task['duration'] = duration
        task['dropped'] = 0
        task['pickup'] = pickup
        task['end_tick'] = game.tick + delay * 60 + duration * 60

        on_tick_n.add(game.tick + delay * 60, task)
    else
        player.dump_inventory_impl(player_, range, chance, game.tick + duration * 60, 0, pickup)
    end

end

function player.cancel_handcraft_impl(task)
    if game.tick >= task.start_tick then
        local queue = task.player.crafting_queue
        local sz = fml.actual_size(queue)
        while queue and sz > 0 do
            if math.random(1, 100) <= task.chance then
                local idx = math.random(1, sz)
                task.player.cancel_crafting{index = idx, count = queue[idx].count}
                task.count = task.count + queue[idx].count
            end
            queue = task.player.crafting_queue
            sz = queue and fml.actual_size(queue) or 0
        end
    elseif task.countdown then
    end

    local nextRun = task.countdown and game.tick + 30 or task.start_tick
    if game.tick < task.start_tick and nextRun > task.start_tick then
        on_tick_n.add(task.start_tick, task)
    elseif nextRun < task.end_tick then
        on_tick_n.add(nextRun, task)
    else
        if #config['msg-player-cancel-handcraft'] > 0 then
            task.player.force.print(strutil.replace_variables(config['msg-player-cancel-handcraft'], {task.player.name, task.count, task.end_tick - task.start_tick}), constants.bad)
        end
    end
end

function player.cancel_handcraft(player_, chance, delay, duration, countdown)
    if not player_ then
        game.print('player is required', constants.error)
        return
    end
    chance = chance or math.random(25, 80)
    chance = math.min(100, math.max(1, chance))
    delay = delay or 0
    duration = duration or 0
    if countdown ~= false and countdown ~= true then
        countdown = false
    end

    local task = {}
    task['action'] = 'cancel_handcraft'
    task['player'] = player_
    task['chance'] = chance
    task['count'] = 0
    task['countdown'] = countdown
    task['start_tick'] = game.tick + delay * 60
    task['end_tick'] = game.tick + delay * 60 + duration * 60

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        player.cancel_handcraft_impl(task)
    end
end

function player.start_handcraft_impl(task)
    local item = task.item
    if not item then
        local choices = {}
        for name, r in pairs(task.player.force.recipes) do
            if task.player.get_craftable_count(name) > 0 then
                table.insert(choices, name)
            end
        end

        item = choices[math.random(1, fml.actual_size(choices))]
    end

    if math.random(1, 100) <= task.chance then
        task.player.begin_crafting{count=task.count, recipe=item}
    end
end

function player.start_handcraft(player_, item, count, chance, delay)
    if not player_ then
        game.print('player is required', constants.error)
        return
    end
    chance = chance or 100
    chance = math.min(100, math.max(1, chance))
    count = count or math.random(1, 100)
    count = math.min(1000, math.max(1, count))
    delay = delay or 0

    local task = {}
    task['action'] = 'start_handcraft'
    task['player'] = player_
    task['chance'] = chance
    task['count'] = count
    task['start_tick'] = game.tick + delay * 60

    if delay > 0 then
        on_tick_n.add(game.tick + 60 * delay, task)
    else
        player.start_handcraft_impl(task)
    end

end

return player
