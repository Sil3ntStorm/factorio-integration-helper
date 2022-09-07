-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local player = {}

local constants = require('constants')
local config = require('utils/config')
local strutil = require('utils/string_replace')
local map = require('funcs/map')
local fml = require('utils/lua_is_stupid')
local proto = fml.include('utils/proto')
local on_tick_n = require('__flib__.on-tick-n')
local tc = require('utils/type_check')
local research = fml.include('funcs/research_tree')

function player.modify_walk_speed_impl(task)
    if not global.silinthlp_walk_speed then
        global.silinthlp_walk_speed = {}
    end
    if global.silinthlp_walk_speed[task.player.name] then
        -- We already adjusted this player.
        return
    end
    if not task.player.character then
        -- currently dead? Try again later
        on_tick_n.add(game.tick + 60, task)
        return
    end

    local original = task.player.character_running_speed_modifier

    task['action'] = 'restore_walking_speed'
    task['original'] = original

    global.silinthlp_walk_speed[task.player.name] = on_tick_n.add(game.tick + (task.duration * 60), task)

    task.player.character_running_speed_modifier = math.max(-0.97, (original * 100 + task.modifier) / 100 - 1)
    if task.modifier < 100 and #config['msg-player-walk-speed-dec'] > 0 then
        task.player.force.print(strutil.replace_variables(config['msg-player-walk-speed-dec'], {task.player.name, 100 - task.modifier, task.duration}), constants.bad)
    elseif task.modifier >= 100 and #config['msg-player-walk-speed-inc'] > 0 then
        task.player.force.print(strutil.replace_variables(config['msg-player-walk-speed-inc'], {task.player.name, task.modifier - 100, task.duration}), constants.good)
    end
end

function player.modify_walk_speed(player_, modifier, duration, chance, delay)
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    if not player_.character then
        game.print('player must have a character', constants.error)
        return
    end
    modifier = modifier or 100
    duration = duration or math.random(10, 60)
    chance = chance or 100
    if type(delay) ~= 'number' then
        delay = 0
    end

    -- clamp values
    modifier = math.max(1, math.min(config['max-walk-speed-modifier'], modifier))
    chance = math.max(1, math.min(100, chance))

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

    local task = {}
    task['action'] = 'set_walking_speed'
    task['player'] = player_
    task['modifier'] = modifier
    task['duration'] = duration
    task['delay'] = delay - 1

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        player.modify_walk_speed_impl(task)
    end
end

function player.modify_craft_speed_impl(task)
    if not global.silinthlp_craft_speed then
        global.silinthlp_craft_speed = {}
    end
    if global.silinthlp_craft_speed[task.player.name] then
        -- We already adjusted this player.
        return
    end
    if not task.player.character then
        -- currently dead? Try again later
        on_tick_n.add(game.tick + 60, task)
        return
    end

    local original = task.player.character_crafting_speed_modifier

    task['action'] = 'restore_crafting_speed'
    task['original'] = original

    global.silinthlp_craft_speed[task.player.name] = on_tick_n.add(game.tick + (task.duration * 60), task)

    task.player.character_crafting_speed_modifier = math.max(-0.97, (original * 100 + task.modifier) / 100 - 1)
    if task.modifier < 100 and #config['msg-player-craft-speed-dec'] > 0 then
        task.player.force.print(strutil.replace_variables(config['msg-player-craft-speed-dec'], {task.player.name, 100 - task.modifier, task.duration}), constants.bad)
    elseif task.modifier >= 100 and #config['msg-player-craft-speed-inc'] > 0 then
        task.player.force.print(strutil.replace_variables(config['msg-player-craft-speed-inc'], {task.player.name, task.modifier - 100, task.duration}), constants.good)
    end
end

function player.modify_craft_speed(player_, modifier, duration, chance, delay)
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    if not player_.character then
        game.print('player must have a character', constants.error)
        return
    end
    modifier = modifier or 100
    duration = duration or math.random(10, 60)
    chance = chance or 100
    if type(delay) ~= 'number' then
        delay = 0
    end

    -- clamp value
    modifier = math.max(1, math.min(config['max-craft-speed-modifier'], modifier))
    chance = math.max(1, math.min(100, chance))

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

    local task = {}
    task['action'] = 'set_crafting_speed'
    task['player'] = player_
    task['modifier'] = modifier
    task['duration'] = duration
    task['delay'] = delay - 1

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        player.modify_craft_speed_impl(task)
    end
end

function player.set_on_fire(player_, range, chance)
    if not tc.is_player(player_) or not player_.character then
        -- possibly dead right now.
        return false
    end
    range = math.min(100, math.max(0, range))
    local x = player_.position.x - range
    local y = player_.position.y - range
    local x2 = player_.position.x + range
    local y2 = player_.position.y + range
    while x < x2 do
        local y3 = y
        while y3 < y2 do
            if math.random(1, 100) <= chance and map.getDistance(player_.position, {x=x, y=y3}) <= range then
                player_.surface.create_entity{
                    position = {x = x, y = y3},
                    name = 'fire-flame-on-tree',
                    target = player_.character
                }
            end
            y3 = y3 + 1
        end
        x = x + 1
    end
    return true
end

function player.on_fire(player_, duration, range, chance, delay)
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    duration = duration or math.random(10, 60)
    range = range or math.random(10, 40)
    chance = chance or 80

    range = math.min(80, math.max(4, range))
    if type(delay) ~= 'number' then
        delay = 0
    end

    local task = {}
    task['action'] = 'player_on_fire'
    task['player'] = player_
    task['chance'] = chance
    task['range'] = range
    task['firstTick'] = game.tick + delay * 60
    task['lastTick'] = game.tick + delay * 60 + duration * 60
    task['lastPos'] = player_.position
    task['executed'] = 0
    local speed = 1
    if player_.character then
        speed = math.max(player_.character_running_speed_modifier, player_.character_running_speed)
    end
    task['nthTick'] = math.max(1, math.floor((range / 2 - 2) / (1 + speed)))

    if #config['msg-player-on-fire'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-on-fire'], {player_.name, range, duration}), constants.bad)
    end
    if delay == 0 then
        if player.set_on_fire(player_, range, chance) then
            task['executed'] = game.tick
        end
        on_tick_n.add(game.tick + task.nthTick, task)
    else
        on_tick_n.add(game.tick + 60, task)
    end
end

function player.barrage(player_, itemToSpawn, range, countPerVolley, count, secondsBetweenVolley, chance, delay, homing_count, randomize_target, speed_modifier, range_modifier)
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    
    if type(itemToSpawn) ~= 'string' then
        itemToSpawn = 'explosive-rocket'
    end
    if type(range) ~= 'number' then
        range = math.random(10, 50)
    end
    if type(countPerVolley) ~= 'number' then
        countPerVolley = math.random(5, 20)
    end
    if type(count) ~= 'number' then
        count = math.random(2, 20)
    end
    secondsBetweenVolley = secondsBetweenVolley or math.random(1, 10)
    if type(chance) ~= 'number' then
        chance = 90
    end
    if type(delay) ~= 'number' then
        delay = 0
    end
    if type(homing_count) ~= 'number' then
        homing_count = math.floor(count * 0.25 + 0.5)
    end
    if type(randomize_target) ~= 'boolean' then
        randomize_target = true
    end
    if type(speed_modifier) ~= 'number' then
        speed_modifier = 1.0
    end
    if type(range_modifier) ~= 'number' then
        range_modifier = 1.0
    end

    speed_modifier = math.max(0.1, speed_modifier)
    range_modifier = math.max(0.5, range_modifier)
    homing_count = math.min(homing_count, count)

    if not fml.contains(proto.get_projectiles(), itemToSpawn) then
        game.print(itemToSpawn .. ' is not a valid type!', constants.error)
        return
    end

    local task = {}
    task['action'] = 'spawn_explosive'
    task['player'] = player_
    task['chance'] = chance
    task['item'] = itemToSpawn
    task['count'] = count - (delay > 0 and 0 or 1)
    task['delay'] = secondsBetweenVolley
    task['itemCount'] = countPerVolley
    task['range'] = range
    task['homing'] = homing_count
    task['rnd_tgt'] = randomize_target
    task['speed_modifier'] = speed_modifier
    task['range_modifier'] = range_modifier

    if #config['msg-player-barrage-start'] > 0 then
        if itemToSpawn == 'artillery-projectile' then
            itemToSpawn = 'artillery-shell'
        elseif itemToSpawn == 'atomic-rocket' then
            itemToSpawn = 'atomic-bomb'
        end
        player_.force.print(strutil.replace_variables(config['msg-player-barrage-start'], {player_.name, countPerVolley, {'item-name.' .. itemToSpawn}, strutil.split(secondsBetweenVolley, ':')[1], count, delay}), constants.bad)
    end
    if delay > 0 then
        on_tick_n.add(game.tick + delay * 60, task)
    else
        if math.random(1, 100) <= chance then
            map.spawn_explosive(task.player.surface, task.player.position, task.item, task.itemCount, task.player.character, task.chance, task.range, nil, task.rnd_tgt, task.homing, task.speed_modifier, task.range_modifier)
        end
        if count > 1 then
            secondsBetweenVolley = strutil.get_random_from_string_or_value(secondsBetweenVolley, 1, 10)
            on_tick_n.add(game.tick + secondsBetweenVolley * 60, task)
        elseif #config['msg-player-barrage-end'] > 0 then
            player_.force.print(strutil.replace_variables(config['msg-player-barrage-end'], {player_.name}), constants.good)
        end
    end
end

function player.dump_inventory_done_msg(player_, dropped)
    if #config['msg-player-dump-inventory-end'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-dump-inventory-end'], {player_.name, dropped}), constants.good)
    end
end

function player.dump_inventory_stack(player_, item, range, do_pickup)
    if not tc.is_player(player_) or not player_.character or type(item) ~= 'string' or type(range) ~= 'number' then
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
        local pos = map.getRandomPositionInRange(player_.position, range)
        local ent = player_.surface.spill_item_stack(pos, {name=stack.name, count=1}, do_pickup, do_pickup and player_.force or nil, true)
        while not ent or #ent < 1 do
            pos = map.getRandomPositionInRange(player_.position, range)
            ent = player_.surface.spill_item_stack(pos, {name=stack.name, count=1}, do_pickup, do_pickup and player_.force or nil, true)
        end
        if stack.type == 'blueprint' or stack.type == 'blueprint-book' or stack.type == 'deconstruction-item' or stack.type == 'upgrade-item' or stack.type == 'item-with-tags' then
            -- just returning nil/empty string for stuff that cannot be exported would have been too complicated I guess...
            local export = stack.export_stack()
            if #export > 0 and #ent > 0 then
                ent[1].stack.import_stack(export)
            end
        elseif stack.grid then
            -- copy equipment grid (e.g. spidertron / armor in inv)
            map.set_equipment_for_item_on_ground(ent[1], stack.grid.equipment)
        end
        -- Since Factorio insists on having properties on generic entities
        -- that only exists on very few, specific instances of them
        -- while hard erroring when attempting to check / set them, rather
        -- than just accepting / returning nil values...
        if stack.health then
            ent[1].stack.health = stack.health
        end
        if stack.type == 'ammunition' and stack.ammo then
            ent[1].stack.ammo = stack.ammo
        end
        if stack.type == 'item-with-tags' and stack.tags then
            ent[1].stack.tags = stack.tags
        end
        if stack.durability then
            ent[1].stack.durability = stack.durability
        end
    end
    inv.remove(stack)
    return count
end

function player.dump_inventory_impl(player_, range, chance, endTick, prevRuns, do_pickup)
    if not player_ or not player_.character or not player_.connected then
        -- disconnected or dead
        if tc.is_player(player_) then
            player_.force.print('Player is dead or no longer connected', constants.error)
        end
        return
    end
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
            player_.force.print('No inventory items found', constants.neutral)
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
    if not tc.is_player(player_) or not player_.valid or not player_.character then
        game.print('player is required and must be a valid player with a character', constants.error)
        return
    end
    range = range or math.random(10, 80)
    chance = chance or math.random(50, 100)
    chance = math.min(100, math.max(1, chance))
    duration = duration or 0
    if pickup ~= false and pickup ~= true then
        pickup = false
    end
    if type(delay) ~= 'number' then
        delay = 0
    end

    if #config['msg-player-dump-inventory'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-dump-inventory'], {player_.name, range, duration, delay}), constants.bad)
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

function player.cancel_handcraft_impl(task, do_print)
    local queue = task.player.crafting_queue
    local sz = queue and fml.actual_size(queue) or 0
    while queue and sz > 0 do
        if math.random(1, 100) <= task.chance then
            local idx = math.random(1, sz)
            task.player.cancel_crafting{index = idx, count = queue[idx].count}
            task.count = task.count + queue[idx].count
        end
        queue = task.player.crafting_queue
        sz = queue and fml.actual_size(queue) or 0
    end

    if game.tick + 20 <= task.end_tick then
        on_tick_n.add(game.tick + 20, task)
    elseif do_print then
        if #config['msg-player-cancel-handcraft'] > 0 then
            task.player.force.print(strutil.replace_variables(config['msg-player-cancel-handcraft'], {task.player.name, task.count, task.duration}), task.count > 0 and constants.bad or constants.neutral)
        end
    end
end

function player.cancel_handcraft(player_, chance, delay, duration)
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    chance = chance or math.random(25, 80)
    chance = math.min(100, math.max(1, chance))
    if type(duration) ~= 'number' then
        duration = 0
    end
    if type(delay) ~= 'number' then
        delay = 0
    end

    local task = {}
    task['action'] = 'cancel_handcraft'
    task['player'] = player_
    task['chance'] = chance
    task['count'] = 0
    task['delay'] = delay - 1
    task['duration'] = duration
    task['end_tick'] = game.tick + 60 * delay + duration * 60

    if delay > 0 then
        if #config['msg-player-cancel-handcraft-start'] > 0 then
            task.player.force.print(strutil.replace_variables(config['msg-player-cancel-handcraft-start'], {task.player.name, delay, task.duration, task.chance}), constants.bad)
        end
        on_tick_n.add(game.tick + 60, task)
    else
        player.cancel_handcraft_impl(task, true)
    end
end

function player.start_handcraft_impl(task)
    local function err()
        if #config['msg-player-start-handcraft-nothing'] > 0 then
            task.player.force.print(strutil.replace_variables(config['msg-player-start-handcraft-nothing'], {task.player.name}), constants.neutral)
        end
    end

    local item = task.item
    if item and task.player.get_craftable_count(item) == 0 then
        err()
        return
    end
    if not item then
        local choices = {}
        for name, r in pairs(task.player.force.recipes) do
            if task.player.get_craftable_count(name) > 0 and research.can_build(task.player.force, name) then
                table.insert(choices, name)
            end
        end
        if fml.actual_size(choices) == 0 then
            err()
            return
        end

        item = choices[math.random(1, fml.actual_size(choices))]
    end
    if math.random(1, 100) <= task.chance then
        local actual_count = math.min(task.player.get_craftable_count(item), task.count)
        local done = task.player.begin_crafting{count=actual_count, recipe=item}
        if #config['msg-player-start-handcraft'] > 0 then
            local product = task.player.force.recipes[item].products[1].name
            local result = ''
            if game.entity_prototypes[product] then
                result = {'entity-name.' .. product }
            elseif game.item_prototypes[product] then
                result = {'item-name.' .. product }
            end
            task.player.force.print(strutil.replace_variables(config['msg-player-start-handcraft'], {task.player.name, done, result}), constants.neutral)
        end
    end
end

function player.start_handcraft(player_, item, count, chance, delay)
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    chance = chance or 100
    chance = math.min(100, math.max(1, chance))
    count = count or math.random(1, 100)
    count = math.min(1000, math.max(1, count))
    if type(delay) ~= 'number' then
        delay = 0
    end

    local task = {}
    task['action'] = 'start_handcraft'
    task['player'] = player_
    task['chance'] = chance
    task['count'] = count
    task['item'] = item
    task['delay'] = delay - 1

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        player.start_handcraft_impl(task)
    end
end

function player.get_equipment_grid_content(item_stack)
    local equip = {}
    if not item_stack.grid then
        return equip
    end
    for _, eq in pairs(item_stack.grid.equipment) do
        table.insert(equip, {name = eq.name, position = eq.position, shield = eq.shield, energy = eq.energy})
    end
    return equip
end

function player.get_naked_impl(task, do_print)
    if not tc.is_player(task.player) or not task.player.valid or not task.player.connected then
        game.print('Player died or disconnected', constants.error)
        return
    end
    local armor_inv = task.player.get_inventory(defines.inventory.character_armor)
    local main_inv = task.player.get_main_inventory()
    local task_dress = {}
    task_dress['action'] = 'dress_player'
    task_dress['player'] = task.player
    task_dress['distance'] = task.distance
    task_dress['origin'] = 'naked'
    task_dress['battery_pct'] = task.battery_pct
    task_dress['shield_pct'] = task.shield_pct
    local extra_armor = {}
    for name, count in pairs(main_inv.get_contents()) do
        local stack = main_inv.find_item_stack(name)
        if stack.type == 'armor' then
            for i = 1,count do
                local equip = player.get_equipment_grid_content(stack)
                table.insert(extra_armor, {name = stack.name, equipment = equip})
                if task.duration == 0 then
                    -- Dump on to ground right away due to 0 duration
                    local pos = map.getRandomPositionInRealDistance(task.player.position, task.distance)
                    local ent = task.player.surface.spill_item_stack(pos, {name = stack.name, count = 1}, false, nil)
                    map.set_equipment_for_item_on_ground(ent[1], equip)
                end
                main_inv.remove(stack)
            end
        end
    end
    local worn_armor = {}
    if not armor_inv.is_empty() then
        local equip = player.get_equipment_grid_content(armor_inv[1])
        worn_armor['name'] = armor_inv[1].name
        worn_armor['equipment'] = equip

        if task.duration == 0 then
            -- Dump on to ground right away due to 0 duration
            local pos = map.getRandomPositionInRealDistance(task.player.position, task.distance)
            local ent = task.player.surface.spill_item_stack(pos, {name=armor_inv[1].name, count=1}, false, nil)
            map.set_equipment_for_item_on_ground(ent[1], equip)
        end
        armor_inv.remove(armor_inv[1])
    end
    task_dress['worn'] = worn_armor
    task_dress['extra'] = extra_armor
    if task.duration > 0 then
        on_tick_n.add(game.tick + task.duration * 60, task_dress)
    end
    if do_print then
        if #config['msg-player-naked'] > 0 and task.duration > 0 then
            task.player.force.print(strutil.replace_variables(config['msg-player-naked'], {task.player.name, task.duration}), constants.bad)
        elseif #config['msg-player-naked-end-ground'] > 0 and task.duration == 0 then
            task.player.force.print(strutil.replace_variables(config['msg-player-naked-end-ground'], {task.player.name, task.distance}), constants.neutral)
        end
    end
end

function player.get_naked(player_, delay, distance, duration, battery_pct, shield_pct)
    if not tc.is_player(player_) or not player_.character then
        game.print('Missing parameters: player is required and player must be alive', constants.error)
        return
    end

    if type(delay) ~= 'number' then
        delay = 0
    end
    if type(distance) ~= 'number' then
        distance = math.random(50, 100)
    end
    if type(duration) ~= 'number' then
        duration = math.random(2, 10)
    end
    if type(battery_pct) ~= 'number' then
        battery_pct = math.random(50, 75)
    end
    if type(shield_pct) ~= 'number' then
        shield_pct = math.random(0, 20)
    end

    distance = math.abs(distance)
    duration = math.max(0, duration)
    battery_pct = math.min(100, math.max(0, battery_pct))
    shield_pct = math.min(100, math.max(0, shield_pct))

    local task = {}
    task['action'] = 'get_naked'
    task['player'] = player_
    task['delay'] = delay
    task['distance'] = distance
    task['duration'] = duration
    task['end_tick'] = game.tick + delay * 60 + duration * 60
    task['battery_pct'] = battery_pct
    task['shield_pct'] = shield_pct

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        player.get_naked_impl(task, true)
    end
end

function player.give_armor_impl(player_, armor_spec, pos, as_active_armor, leave_on_ground, battery_pct, shield_pct)
    if not tc.is_player(player_) then
        return
    end
    if armor_spec and type(armor_spec.name) ~= 'string' then
        log('Invalid armor spec: ' .. serpent.line(armor_spec))
        return
    end
    local inv = nil
    if as_active_armor then
        inv = player_.get_inventory(defines.inventory.character_armor)
    else
        inv = player_.get_main_inventory()
    end
    if not inv then
        return
    end
    -- Create as an on ground item, since we cannot create a proper item stack
    -- or detect where our item got inserted into the inventory. The player
    -- may already have an item of the type we are inserting, so there is no
    -- way to apply equipment to the correct item otherwise.
    pos = pos or map.getRandomPositionInRange(player_.position, 10)
    local ent = player_.surface.spill_item_stack(pos, {name=armor_spec.name, count=1}, false, nil)
    if #ent > 0 then
        if armor_spec and armor_spec.equipment and #armor_spec.equipment > 0 then
            map.set_equipment_for_item_on_ground(ent[1], armor_spec.equipment, battery_pct, shield_pct)
        end
        if not leave_on_ground and (inv.can_insert(armor_spec.name) or as_active_armor) then
            if not inv.can_insert(armor_spec.name) then
                -- Attempt to relocate current armor into main inventory
                local inserted = player_.get_main_inventory().insert(inv[1])
                if inserted == 0 then
                    -- No space in main inventory drop old armor
                    local old = task.player.surface.spill_item_stack(pos, {name=inv[1].name, count=1}, false, nil)
                    map.set_equipment_for_item_on_ground(old[1], player.get_equipment_grid_content(inv[1]))
                end
                inv.remove(inv[1].name)
            end
            inv.insert(ent[1].stack)
            ent[1].destroy()
        end
    end
end

function player.auto_pickup_impl(task)
    local nextAfter = 10
    if not task.player.valid or not task.player.connected or not task.player.character or not task.player.character.valid then
        -- dead or disconnected
        if game.tick + nextAfter < task.end_tick then
            on_tick_n.add(game.tick + nextAfter, task)
        end
        return
    end
    local inv = task.player.get_main_inventory()
    if not inv then
        log('Player has no inventory?!?!')
        if game.tick + nextAfter < task.end_tick then
            on_tick_n.add(game.tick + nextAfter, task)
        end
        return
    end
    local result = task.player.surface.find_entities_filtered{name = 'item-on-ground', position = task.player.position, radius = task.range}
    for _, e in pairs(task.player.surface.find_entities_filtered{type = {'transport-belt', 'underground-belt', 'splitter'}, position = task.player.position, radius = task.range}) do
        table.insert(result, e)
    end
    for _, e in pairs(result) do
        if map.getDistance(e.position, task.player.position) <= task.range then
            if e.name == 'item-on-ground' and inv.can_insert(e.stack) then
                local done = inv.insert(e.stack)
                if done == e.stack.count then
                    e.destroy()
                end
            elseif e.name ~= 'item-on-ground' then
                for i = 1, e.get_max_transport_line_index() do
                    local line = e.get_transport_line(i)
                    for k = #line, 1, - 1 do
                        local on_belt = line[k]
                        if inv.insert(on_belt) == 1 then
                            line.remove_item(on_belt)
                        end
                    end
                end
            end
        end
    end
    if game.tick + nextAfter < task.end_tick then
        on_tick_n.add(game.tick + nextAfter, task)
    end
end

function player.vacuum_impl(task)
    local original_item = task.player.character_item_pickup_distance_bonus
    local original_loot = task.player.character_loot_pickup_distance_bonus
    task['orig_item'] = original_item
    task['orig_loot'] = original_loot

    if math.random(1, 100) <= task.chance then
        task.player.character_item_pickup_distance_bonus = math.max(1, task.player.character_item_pickup_distance_bonus + task.range)
        task.player.character_loot_pickup_distance_bonus = math.max(1, task.player.character_loot_pickup_distance_bonus + task.range)
        local range_value = math.max(task.player.character_item_pickup_distance_bonus, task.player.character_loot_pickup_distance_bonus) + 1

        if #config['msg-player-vacuum'] > 0 then
            task.player.force.print(strutil.replace_variables(config['msg-player-vacuum'], {task.player.name, range_value, task.duration}), constants.good)
        end
        if task.auto_pickup then
            local pickup_task = {}
            pickup_task['action'] = 'auto_pickup'
            pickup_task['player'] = task.player
            pickup_task['range'] = task.range
            pickup_task['end_tick'] = game.tick + task.duration * 60
            on_tick_n.add(game.tick + 10, pickup_task)
        end
        task['action'] = 'reset-vacuum'
        on_tick_n.add(game.tick + task.duration * 60, task)
    elseif #config['msg-player-vacuum-fail'] > 0 then
        task.player.force.print(strutil.replace_variables(config['msg-player-vacuum-fail'], {task.player.name}), constants.neutral)
    end
end

function player.vacuum(player_, range, duration, chance, delay, auto_pickup)
    if not tc.is_player(player_) or not player_.connected or not player_.character then
        game.print('Missing parameters: player is required and player must be alive', constants.error)
        return
    end
    if type(range) ~= 'number' then
        range = math.random(1, 10)
    end
    if type(delay) ~= 'number' then
        delay = 0
    end
    if type(duration) ~= 'number' or duration < 1 then
        duration = math.random(5, 20)
    end
    if type(chance) ~= 'number' then
        chance = math.random(75, 95)
    end
    if type(auto_pickup) ~= 'boolean' then
        auto_pickup = true
    end

    range = math.abs(range)
    range = math.max(1, math.min(80, range))
    duration = math.max(1, math.min(300, duration))

    local task = {}
    task['action'] = 'vacuum'
    task['player'] = player_
    task['duration'] = duration
    task['range'] = range
    task['chance'] = chance
    task['delay'] = delay - (delay > 0 and 1 or 0)
    task['auto_pickup'] = auto_pickup

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        player.vacuum_impl(task)
    end
end

function player.get_player_grid_info(task)
    local grid = nil
    if task.player.object_name == 'LuaPlayer' then
        if not task.player.character or not task.player.character.valid then
            -- player dead, try next time around
            return
        end
        grid = task.player.character.grid
    elseif task.player.prototype == 'LuaEntity' then
        grid = task.player.grid
    end
    if not grid then
        return
    end

    return {shield = {current = grid.shield, max = grid.max_shield}, battery = {current = grid.available_in_batteries, max = grid.battery_capacity}}
end

function player.set_shields_impl(task)
    if not task.player or not tc.is_player(task.player) or not task.player.connected or not task.player.valid then
        return
    end

    local grid = nil
    local target = task.player
    if target.vehicle and target.vehicle.valid and target.vehicle.grid then
        target = task.player.vehicle
    end

    if target.object_name == 'LuaPlayer' then
        if not target.character or not target.character.valid then
            -- player dead, try next time around
            return
        end
        grid = target.character.grid
    elseif target.object_name == 'LuaEntity' then
        grid = target.grid
    end
    if not grid then
        return
    end

    if grid.max_shield <= 0 then
        -- No shields
        if #config['msg-player-shields-no-shield'] then
            task.player.force.print(strutil.replace_variables(config['msg-player-shields-no-shield'], {task.player.name}), constants.neutral)
        end
        return
    end

    local value = task.percent
    if not task.absolute then
        value = grid.shield * (1 + value / 100)
    else
        value = grid.max_shield * math.abs(value / 100)
    end
    value = math.max(0, math.min(value, grid.max_shield))
    local remaining = value
    for _, e in pairs(grid.equipment) do
        if e.type == 'energy-shield-equipment' and grid.shield ~= value then
           local cur_shield = math.max(0, math.min(remaining, e.max_shield))
           remaining = remaining - cur_shield
           e.shield = cur_shield
        end
    end
end

function player.set_battery_impl(task)
    if not task.player or not tc.is_player(task.player) or not task.player.connected or not task.player.valid then
        return
    end

    local grid = nil
    local target = task.player
    if target.vehicle and target.vehicle.valid and target.vehicle.grid then
        target = task.player.vehicle
    end

    if target.object_name == 'LuaPlayer' then
        if not target.character or not target.character.valid then
            -- player dead, try next time around
            return
        end
        grid = target.character.grid
    elseif target.object_name == 'LuaEntity' then
        grid = target.grid
    end
    if not grid then
        return
    end

    if grid.battery_capacity <= 0 then
        -- No batteries
        if #config['msg-player-batt-no-batt'] then
            task.player.force.print(strutil.replace_variables(config['msg-player-batt-no-batt'], {task.player.name}), constants.neutral)
        end
        return
    end

    local value = task.percent
    if not task.absolute then
        value = grid.available_in_batteries * (1 + value / 100)
    else
        value = grid.battery_capacity * math.abs(value / 100)
    end
    value = math.max(0, math.min(value, grid.battery_capacity))
    local remaining = value
    for _, e in pairs(grid.equipment) do
        if e.type == 'battery-equipment' and grid.available_in_batteries ~= value then
           local cur_batt = math.max(0, math.min(remaining, e.max_energy))
           remaining = remaining - cur_batt
           e.energy = cur_batt
        end
    end
end

function player.discharge_common(kind, player_, percent, chance, delay, is_absolute, duration)
    if not tc.is_player(player_) or not player_.connected or not player_.character then
        game.print('Missing parameters: player is required and player must be alive', constants.error)
        return
    end
    if type(percent) ~= 'number' then
        percent = math.random(-90, 90)
    end
    if type(chance) ~= 'number' then
        chance = math.random(50, 100)
    end
    if type(delay) ~= 'number' then
        delay = 0
    end
    if type(is_absolute) ~= 'boolean' then
        is_absolute = false
    end
    if type(duration) ~= 'number' then
        duration = 0
    end
    percent = math.max(-100, math.min(percent, 100))
    chance = math.max(0, math.min(chance, 100))
    delay = math.max(0, delay)
    duration = math.max(0, duration)
    if percent == 0 then
        percent = math.random(-90, 90)
    end

    local task = {}
    task['action'] = 'set_' .. kind
    task['player'] = player_
    task['percent'] = is_absolute and math.abs(percent) or percent
    task['chance'] = chance
    task['delay'] = math.max(0, delay - 1)
    task['absolute'] = is_absolute
    task['duration'] = duration
    task['end_tick'] = game.tick + delay * 60 + duration * 60
    task['print'] = true

    if delay == 0 then
        if kind == 'shields' then
            player.set_shields_impl(task)
        else
            player.set_battery_impl(task)
        end
    else
        on_tick_n.add(game.tick + 60, task)
    end
end

function player.discharge_shields(player_, percent, chance, delay, is_absolute, duration)
    player.discharge_common('shields', player_, percent, chance, delay, is_absolute, duration)
end

function player.discharge_batteries(player_, percent, chance, delay, is_absolute, duration)
    player.discharge_common('batteries', player_, percent, chance, delay, is_absolute, duration)
end

function player.change_body_timer(player_, added_time, chance, delay, max_count)
    if not tc.is_player(player_) or not player_.connected or not player_.character then
        game.print('Missing parameters: player is required and player must be alive', constants.error)
        return
    end
    if type(added_time) ~= 'number' then
        added_time = math.random(10, 30)
    end
    if type(chance) ~= 'number' then
        chance = math.random(50, 100)
    end
    if type(delay) ~= 'number' then
        delay = 0
    end
    chance = math.max(0, math.min(chance, 100))
    delay = math.max(0, delay)

    local task = {}

end

return player
