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
        return
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
    task['executed'] = game.tick
    local speed = 1
    if player_.character then
        speed = math.max(player_.character_running_speed_modifier, player_.character_running_speed)
    end
    task['nthTick'] = math.max(1, math.floor((range / 2 - 2) / (1 + speed)))

    if #config['msg-player-on-fire'] > 0 then
        player_.force.print(strutil.replace_variables(config['msg-player-on-fire'], {player_.name, range, duration}), constants.bad)
    end
    if delay == 0 then
        player.set_on_fire(player_, range, chance)
        on_tick_n.add(game.tick + task.nthTick, task)
    else
        on_tick_n.add(game.tick + 60, task)
    end
end

function player.barrage(player_, itemToSpawn, range, countPerVolley, count, secondsBetweenVolley, chance, delay, homing, randomize_target)
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    
    itemToSpawn = itemToSpawn or 'explosive-rocket'
    range = range or math.random(10, 50)
    countPerVolley = countPerVolley or math.random(5, 20)
    count = count or math.random(2, 20)
    secondsBetweenVolley = secondsBetweenVolley or math.random(1, 10)
    chance = chance or 90
    if type(delay) ~= 'number' then
        delay = 0
    end
    if homing ~= false and homing ~= true then
        homing = true
    end
    if randomize_target ~= false and randomize_target ~= true then
        randomize_target = true
    end

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
    task['homing'] = homing
    task['rnd_tgt'] = randomize_target

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
            map.spawn_explosive(task.player.surface, task.player.position, task.item, task.itemCount, task.player.character, task.chance, task.range, nil, task.rnd_tgt, task.homing)
        end
        if count > 1 then
            secondsBetweenVolley = strutil.get_random_from_string_or_value(secondsBetweenVolley, 1, 10)
            on_tick_n.add(game.tick + secondsBetweenVolley * 60, task)
        elseif #config['msg-player-barrage-end'] > 0 then
            player_.force.print(config['msg-player-barrage-end'], constants.good)
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
    if not tc.is_player(player_) then
        game.print('player is required', constants.error)
        return
    end
    chance = chance or math.random(25, 80)
    chance = math.min(100, math.max(1, chance))
    duration = duration or 0
    if countdown ~= false and countdown ~= true then
        countdown = false
    end
    if type(delay) ~= 'number' then
        delay = 0
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
        if fml.actual_size(choices) == 0 then
            -- TODO: Print an error message maybe? Or pass it up a level to the caller?
            return nil
        end

        item = choices[math.random(1, fml.actual_size(choices))]
    end

    if math.random(1, 100) <= task.chance then
        task.player.begin_crafting{count=task.count, recipe=item}
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
    task['start_tick'] = game.tick + delay * 60

    if delay > 0 then
        on_tick_n.add(game.tick + 60 * delay, task)
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
        table.insert(equip, {name = eq.name, position = eq.position})
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
    local worn_armor = {}
    if not armor_inv.is_empty() then
        local equip = player.get_equipment_grid_content(armor_inv[1])
        worn_armor['name'] = armor_inv[1].name
        worn_armor['equipment'] = equip

        global.silinthlp_naked = global.silinthlp_naked or {}
        global.silinthlp_naked[task.player.name] = global.silinthlp_naked[task.player.name] or {name = '', equipment = {}}
        global.silinthlp_naked[task.player.name].name = armor_inv[1].name
        global.silinthlp_naked[task.player.name].equipment = equip

        if task.duration == 0 then
            local pos = map.getRandomPositionInRealDistance(task.player.position, task.distance)
            local ent = task.player.surface.spill_item_stack(pos, {name=armor_inv[1].name, count=1}, false, nil)
            map.set_equipment_for_item_on_ground(ent[1], equip)
        end
        armor_inv.remove(armor_inv[1])
    end
    local extra_armor = {}
    for name, count in pairs(main_inv.get_contents()) do
        local stack = main_inv.find_item_stack(name)
        if stack.type == 'armor' then
            local equip = player.get_equipment_grid_content(stack)
            table.insert(extra_armor, {name = stack.name, equipment = equip})
            if task.duration == 0 then
                local pos = map.getRandomPositionInRealDistance(task.player.position, task.distance)
                local ent = task.player.surface.spill_item_stack(pos, {name = stack.name, count = 1}, false, nil)
                map.set_equipment_for_item_on_ground(ent[1], equip)
            end
            main_inv.remove(stack)
        end
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

function player.get_naked(player_, delay, distance, duration)
    if not tc.is_player(player_) or not player_.character then
        game.print('Missing parameters: player is required and player must be alive', constants.error)
        return
    end

    if type(delay) ~= 'number' then
        delay = 0
    end
    distance = distance or math.random(50, 100)
    duration = duration or math.random(2, 10)

    distance = math.abs(distance)
    duration = math.max(0, duration)

    local task = {}
    task['action'] = 'get_naked'
    task['player'] = player_
    task['delay'] = delay
    task['distance'] = distance
    task['duration'] = duration
    task['end_tick'] = game.tick + delay * 60 + duration * 60

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        player.get_naked_impl(task, true)
    end
end

function player.give_armor_impl(player_, armor_spec, pos, as_active_armor, leave_on_ground)
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
        map.set_equipment_for_item_on_ground(ent[1], armor_spec.equipment)
        if not leave_on_ground and (inv.can_insert(armor_spec.name) or as_active_armor) then
            if not inv.can_insert(armor_spec.name) then
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

return player
