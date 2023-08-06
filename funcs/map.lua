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
local mapping = fml.include('utils/mapping')
local plr = fml.include('funcs/player')

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

function map.set_equipment_for_item_on_ground(item_on_ground, equip, energy_level, shield_level)
    -- Should be moved out of here maybe?
    if not item_on_ground or not equip then
        log('Invalid item or equipment specified')
        return
    end
    energy_level = energy_level or 100
    shield_level = shield_level or 100
    if not item_on_ground.stack.grid then
        item_on_ground.stack.create_grid()
    end
    for _, eq in pairs(equip) do
        local itm = item_on_ground.stack.grid.put{name = eq.name, position = eq.position}
        if itm.max_energy > 0 then
            itm.energy = eq.energy * (energy_level / 100)
        end
        if itm.max_shield > 0 then
            itm.shield = eq.shield * (shield_level / 100)
        end
    end
end

--

function map.timed_teleport_random(player, distance, seconds, target_surface)
    if not tc.is_player(player) or type(distance) ~= 'number' then
        game.print('Missing parameters: player, distance are required', constants.error)
        return
    end
    if type(seconds) ~= 'number' then
        seconds = math.random(1, 10)
    end
    if not target_surface or not tc.is_surface(target_surface) then
        target_surface = plr.get_surface(player)
    end
    seconds = math.ceil(seconds)

    local task = {}
    task['action'] = seconds == 0 and 'find_teleport_location' or 'teleport_delay'
    task['player'] = player
    task['dest_surface'] = target_surface
    task['delay'] = math.max(0, seconds - 1)
    task['distance'] = distance
    if seconds == 0 then
        task['next_action'] = 'teleport_player'
    end

    on_tick_n.add(game.tick + math.max(1, math.min(1, seconds) * 60), task)
    if #config['msg-map-teleport-countdown'] > 0 and seconds >= 1 then
        task.player.force.print(strutil.replace_variables(config['msg-map-teleport-countdown'], {task.player.name, seconds}), constants.neutral)
    end
end

function map.timed_teleport(player, position, seconds, target_surface)
    if not tc.is_player(player) or not tc.is_position(position) then
        game.print('Missing parameters: player and position are required', constants.error)
        return
    end
    if type(seconds) ~= 'number' then
        seconds = math.random(1, 10)
    end
    if not target_surface or not tc.is_surface(target_surface) then
        target_surface = plr.get_surface(player)
    end
    seconds = math.ceil(seconds)

    local task = {}
    task['action'] = 'teleport_delay'
    task['dest_surface'] = target_surface
    task['player'] = player
    task['position'] = position
    task['delay'] = math.max(0, seconds - 1)

    on_tick_n.add(game.tick + math.max(1, math.min(1, seconds) * 60), task)
    if #config['msg-map-teleport-countdown'] > 0 and seconds >= 1 then
        task.player.force.print(strutil.replace_variables(config['msg-map-teleport-countdown'], {task.player.name, seconds}), constants.neutral)
    end
end

function map.spawn_explosive(surface, position, item, count, target, chance, target_range, position_range, randomize_target, homing_count, user_speed_modifier, user_range_modifier)
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
    if type(homing_count) ~= 'number' then
        homing_count = math.max(1, math.floor(count * 0.25 + 0.5))
    end

    if not fml.contains(proto.get_projectiles(), item) then
        game.print(item .. ' is not a valid type!', constants.error)
        return
    end
    if type(user_speed_modifier) ~= 'number' then
        user_speed_modifier = 1.0
    end
    if type(user_range_modifier) ~= 'number' then
        user_range_modifier = 1.0
    end

    user_speed_modifier = math.max(0.1, user_speed_modifier)
    user_range_modifier = math.max(0.5, user_range_modifier)

    local speed_multiplier = 1
    local origTgtPos = {}
    if target.position then
        origTgtPos = target.position
        if target.prototype.type == 'character' then
            speed_multiplier = speed_multiplier + math.max(target.character_running_speed, target.prototype.running_speed)
        end
        if target.vehicle then
            speed_multiplier = math.max(target.vehicle.speed, speed_multiplier)
        end
    else
        origTgtPos = target
    end
    local base_speed = 0.5
    local evo = 0
    if target.force then
        -- seems to be exclusively based on time passed
        evo = target.force.evolution_factor
    end
    if game.map_settings.enemy_evolution.enabled then
        evo = math.max(evo, game.forces['enemy'].evolution_factor)
    end
    base_speed = math.max(base_speed, evo)
    local pow_multiplier = 2 ^ (speed_multiplier - 1)
    local final_speed = base_speed * pow_multiplier * user_speed_modifier
    if target.prototype then
        if target.prototype.type == 'character' then
            final_speed = math.max(target.character_running_speed + 0.2, final_speed)
        end
        if target.vehicle then
            final_speed = math.max(target.vehicle.speed + 0.5, final_speed)
        end
    end
    final_speed = math.max(0.25, final_speed)

    local shot = 0
    local srcPos = map.getRandomPositionInRealDistance(position, position_range)
    if count > 0 or math.random(1, 100) <= chance then
        surface.create_entity{
            name = item,
            position = srcPos,
            source_position = srcPos,
            target = homing_count > shot and target or origTgtPos,
            speed = final_speed,
            max_range = map.getDistance(origTgtPos, srcPos) * 10 * final_speed * user_range_modifier
        }
        shot = shot + 1
    end

    if count > 1 then
        for i = 1, count do
            if math.random(1, 100) <= chance then
                local tgtPos = randomize_target and map.getRandomPositionInRange(origTgtPos, target_range) or (shot < homing_count and target or origTgtPos)
                local tgtPos2 = tgtPos
                if tgtPos2.position then
                    tgtPos2 = tgtPos2.position
                end
                local srcPos2 = map.getRandomPositionInRange(srcPos, math.min(config['explosive-spawn-range'] + count, config['explosive-spawn-max-range']))
                surface.create_entity{
                    name = item,
                    position = srcPos2,
                    source_position = srcPos2,
                    target = shot < homing_count and target or tgtPos,
                    speed = final_speed,
                    max_range = math.max(target_range, map.getDistance(tgtPos2, srcPos2)) * 10 * final_speed * user_range_modifier
                }
                shot = shot + 1
            end
        end
    end
end

function map.reset_assembler_impl(surface, force, position, range, chance, max_count, recipe)
    chance = math.max(1, math.min(100, chance)) * 10
    local entities = {}
    if position then
        entities = surface.find_entities_filtered{position=position, radius=range, force=force, to_be_deconstructed=false, type='assembling-machine'}
    else
        entities = surface.find_entities_filtered{force=force, to_be_deconstructed=false, type='assembling-machine'}
    end
    local actual = {}
    for _, e in pairs(entities) do
        if type(recipe) == 'string' then
            if not e.recipe_locked and e.get_recipe() ~= nil and e.get_recipe().name == recipe then
                table.insert(actual, e)
            end
        elseif not e.recipe_locked and e.get_recipe() ~= nil and e.name ~= 'water-well-pump' and #e.get_recipe().ingredients > 0 then
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

    return count
end

function map.reset_assembler(surface, force, position, range, chance, max_count)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('Invalid input parameters. Surface and Force are required', constants.error)
        return
    end
    if type(range) ~= 'number' then
        range = 500
    end
    if type(chance) ~= 'number' then
        chance = 2
    end
    if type(max_count) ~= 'number' then
        max_count = 100
    end

    local count = map.reset_assembler_impl(surface, force, position, range, chance, max_count)

    if #config['msg-map-reset-assembler'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-reset-assembler'], {count}), count > 0 and constants.bad or constants.neutral)
    end
end

function map.revive_biters_on_death_impl(task)
    task.action = 'disable_biter_revive'
    global.silinthlp_biter_revive = task
    on_tick_n.add(task.lastTick, task)
    if #config['msg-map-revive-biters'] > 0 then
        game.print(strutil.replace_variables(config['msg-map-revive-biters'], {task.chance, task.duration}), task.chance > 0 and constants.bad or constants.neutral)
    end
end

function map.revive_biters_on_death(chance, duration, surface, position, range, delay)
    if surface and not tc.is_surface(surface) then
        game.print('surface must be a valid surface if specified', constants.error)
        return
    end
    if position and not tc.is_position(position) then
        game.print('position must be a valid position if specified', constants.error)
        return
    end
    if range and type(range) ~= 'number' then
        game.print('range must be a number when specified', constants.error)
        return
    end
    chance = chance or math.random(10, 100)
    duration = duration or math.random(30, 180)

    chance = math.max(0, math.min(chance, 100))
    if type(delay) ~= 'number' then
        delay = 0
    end

    local task = {}
    task['action'] = 'enable_biter_revive'
    task['chance'] = chance
    task['surface'] = surface
    task['position'] = position
    task['range'] = range
    task['duration'] = duration
    task['lastTick'] = game.tick + delay * 60 + duration * 60
    task['delay'] = math.max(0, delay - 1)

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        map.revive_biters_on_death_impl(task)
    end
end

function map.enemy_artillery(surface, force, position, range, max, chance, enemy_force)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('surface and force are required', constants.error)
        return
    end
    if not position or not tc.is_position(position) then
        position = {x=0, y=0}
    end
    if type(range) ~= 'number' then
        range = math.random(500, 5000)
    end
    if type(max) ~= 'number' then
        max = math.random(1, 10)
    end
    if type(chance) ~= 'number' then
        chance = math.random(10, 100)
    end
    if not enemy_force or not tc.is_force(enemy_force) then
        enemy_force = game.forces['enemy']
    end

    chance = math.max(1, math.min(chance, 100))

    local found = surface.find_entities_filtered{type='artillery-turret', radius=range, force=force, position=position}
    local cnt = 0
    for _, e in pairs(found) do
        if math.random(1, 100) <= chance then
            e.force = enemy_force
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

function map.remove_entities(surface, force, position, range, name, max, chance, leave_content, item_class, center_around_all_players)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('surface and force are required', constants.error)
        return
    end
    if not tc.is_position(position) then
        position = {x = 0, y = 0}
    end
    if type(range) ~= 'number' then
        range = math.random(40, 200)
    end
    if type(max) ~= 'number' then
        max = math.random(5, 20)
    end
    if type(chance) ~= 'number' then
        chance = math.random(25, 80)
    end
    if type(leave_content) ~= 'boolean' then
        leave_content = false
    end
    if type(center_around_all_players) ~= 'boolean' then
        center_around_all_players = false
    end

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
    local useClass = false
    if type(item_class) == 'string' then
        if fml.contains(proto.get_available_entity_types(), item_class) then
            useClass = true
        else
            log('Invalid class ' .. item_class .. ' specified. Available: ' .. serpent.line(proto.get_available_entity_types()))
        end
    end

    local function doSearch(surface, force, range, position, use_class, item_class, item_name)
        local result = {}
        if use_class then
            result = surface.find_entities_filtered{type=item_class, force=force, radius=range, position=position}
        else
            result = surface.find_entities_filtered{name=item_name, force=force, radius=range, position=position}
        end
        return result
    end

    local function searchLoop(surface, force, range, position, use_class, item_class, name, center_around_all_players)
        local found = {}
        if not center_around_all_players then
            found = doSearch(surface, force, range, position, use_class, item_class, name)
        else
            for _, lplr in pairs(force.connected_players) do
                local tmp = doSearch(surface, force, range, lplr.position, use_class, item_class, name)
                for _, ent in pairs(tmp) do
                    table.insert(found, ent)
                end
            end
        end
        return found
    end

    chance = math.max(0, math.min(chance, 100))
    local found = searchLoop(surface, force, range, position, useClass, item_class, name, center_around_all_players)
    local lp = 1
    while allowRandom and #found == 0 and lp < 50 do
        name = rndItem()
        found = searchLoop(surface, force, range, position, useClass, item_class, name, center_around_all_players)
        lp = lp + 1
    end

    local whitelisted_content_entity_types = {'transport-belt', 'underground-belt', 'splitter', 'linked-belt', 'loader', 'loader1x1'}
    local cnt = 0
    for _, e in pairs(found) do
        if math.random(1, 100) <= chance then
            local pos = e.position
            local e_name = e.name
            if leave_content and fml.contains(whitelisted_content_entity_types, e.type) then
                if e.die() then
                    local ghst = surface.find_entities_filtered{ghost_name=e_name, position=pos, radius=1}
                    for _, gh in pairs(ghst) do
                        gh.destroy()
                    end
                    cnt = cnt + 1
                elseif e.destroy({raise_destroy=true}) then
                    cnt = cnt + 1
                else
                    log('Failed to die/destroy entity ' .. e.name .. ' a ' .. e.type .. ' at ' .. serpent.line(e.position))
                end
            else
                if e.destroy({raise_destroy=true}) then
                    cnt = cnt + 1
                else
                    log('Failed to destroy entity ' .. e.name .. ' a ' .. e.type .. ' at ' .. serpent.line(e.position))
                end
            end
        end
        if cnt >= max then
            break
        end
    end
    local msg_name = name
    if useClass then
        if fml.contains(whitelisted_content_entity_types, item_class) and item_class ~= 'loader1x1' then
            msg_name = item_class
        else
            msg_name = proto.name_for_entity_type(item_class)
        end
    end
    if #found == 0 and #config['msg-map-remove-entity-nothing'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-remove-entity-nothing'], {{'entity-name.' .. msg_name}}), constants.neutral)
    elseif #config['msg-map-remove-entity'] > 0 then
        force.print(strutil.replace_variables(config['msg-map-remove-entity'], {cnt, {'entity-name.' .. msg_name}}), cnt > 0 and constants.bad or constants.neutral)
    end
end

---@param surface LuaSurface
---@param position MapPosition
---@param range double
---@param name string
---@param max int
---@param chance int
---@param center_around_all_players boolean
---@param force LuaForce
function map.remove_player_tiles(surface, position, range, name, max, chance, center_around_all_players, force)
    if not tc.is_surface(surface) then
        game.print('surface is required', constants.error)
        return
    end
    if not tc.is_position(position) then
        position = {x = 0, y = 0}
    end
    if type(range) ~= 'number' then
        range = math.random(20, 200)
    end
    if type(max) ~= 'number' then
        max = math.random(20, 200)
    end
    if type(chance) ~= 'number' then
        chance = math.random(25, 80)
    end
    if type(center_around_all_players) ~= 'boolean' then
        center_around_all_players = false
    end
    if type(name) ~= 'nil' and type(name) ~= 'string' then
        game.print('name must be a string when specified', constants.error)
        return
    end
    if center_around_all_players and not tc.is_force(force) then
        game.print('When centering action around all players a force must be specified. Only players of that force will be affected', constants.error)
        return
    end
    local valid_tiles = proto.get_player_floor_tiles()
    if type(name) == 'string' and not fml.contains(valid_tiles, name) then
        log('Invalid Tile name ' .. name .. ' valid choices are: ' .. serpent.line(valid_tiles))
        game.print('Invalid tile name ' .. name .. ' specified. Choose one of ' .. serpent.line(valid_tiles), constants.error)
        return
    end


    range = math.max(1, range)
    chance = math.max(0, math.min(chance, 100))
    max = math.max(1, max)

    ---@param surface LuaSurface
    ---@param force LuaForce
    ---@param position MapPosition
    local function searchLoop(surface, force, range, position, name, center_around_all_players)
        local found = {}
        if not center_around_all_players then
            found = surface.find_tiles_filtered{position = position, radius = range, has_hidden_tile = true, name = name}
        else
            for _, lplr in pairs(force.connected_players) do
                if lplr.surface == surface then
                    local tmp = surface.find_tiles_filtered{position = position, radius = range, has_hidden_tile = true, name = name}
                    for _, ent in pairs(tmp) do
                        table.insert(found, ent)
                    end
                end
            end
        end
        return found
    end

    local found = searchLoop(surface, force, range, position, name, center_around_all_players)
    log('Remove Floor - Found ' .. #found .. ' tiles within ' .. range .. ' tiles of ' .. serpent.line(position) .. ' on ' .. surface.name .. ' removing at a chance of ' .. chance .. ' at most ' .. max .. ' name = ' .. serpent.line(name))
    if #found == 0 and #config['msg-map-floor-no-result'] > 0 then
        game.print(strutil.replace_variables(config['msg-map-floor-no-result'], {surface.name, strutil.get_gps_tag(surface, position), range, name}), constants.neutral)
        return
    end

    ---@type Tile[]
    local replacement_tiles = {}
    local cnt = 0
    for _, tile in pairs(found) do
        if math.random(1, 100) <= chance then
            table.insert(replacement_tiles, {position = tile.position, name = tile.hidden_tile})
            cnt = cnt + 1
        end
        if cnt >= max then
            break
        end
    end

    surface.set_tiles(replacement_tiles, true, true, true, true)
    if name == nil then
        name = 'floor'
    else
        name = mapping.locale_tuple(name)
    end
    if #config['msg-map-floor-success'] > 0 then
        game.print(strutil.replace_variables(config['msg-map-floor-success'], {surface.name, strutil.get_gps_tag(surface, position), range, name, cnt}), cnt > 0 and constants.bad or constants.good)
    end
end

function map.disconnect_wires_impl(task)
    local result = {}
    if task.position then
        result = task.surface.find_entities_filtered{position = task.position, radius = task.range, force = task.force}
    else
        result = task.surface.find_entities_filtered{force = task.force}
    end
    local count = 0
    local count_pwr = 0
    for _, ent in pairs(result) do
        if math.random(1, 1000) <= task.chance then
            if task.circuit and ent.circuit_connected_entities then
                count = count + #ent.circuit_connected_entities.green + #ent.circuit_connected_entities.red
                ent.disconnect_neighbour(defines.wire_type.red)
                ent.disconnect_neighbour(defines.wire_type.green)
            end
            if task.power then
                local old_id = ent.electric_network_id
                ent.disconnect_neighbour(defines.wire_type.copper)
                if ent.electric_network_id ~= old_id then
                    count_pwr = count_pwr + 1
                end
            end
        end
    end
    if #config['msg-map-snap-wires'] > 0 then
        task.force.print(strutil.replace_variables(config['msg-map-snap-wires'], {count, count_pwr, task.position ~= nil and task.range or '∞', strutil.get_gps_tag(task.surface, task.position or {x=0,y=0})}), count + count_pwr > 0 and constants.bad or constants.neutral)
    end
end

function map.disconnect_wires(surface, force, position, range, circuit, power, chance, delay)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('Invalid / missing parameters: surface and force are required', constants.error)
        return
    end
    if position ~= nil and not tc.is_position(position) then
        game.print('Invalid parameters: position must be a valid position if specified', constants.error)
        return
    end

    if type(range) ~= 'number' then
        range = math.random(50, 200)
    end
    if type(circuit) ~= 'boolean' then
        circuit = true
    end
    if type(power) ~= 'boolean' then
        power = true
    end
    if type(chance) ~= 'number' then
        chance = math.random(10, 20)
    end
    if type(delay) ~= 'number' then
        delay = 0
    end

    chance = math.max(1, math.min(100, chance))
    chance = math.floor(chance * 10)

    local task = {}
    task['action'] = 'disconnect_wires'
    task['surface'] = surface
    task['force'] = force
    task['position'] = position
    task['range'] = range
    task['chance'] = chance
    task['power'] = power
    task['circuit'] = circuit
    task['delay'] = math.max(0, delay - 1)

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        map.disconnect_wires_impl(task)
    end
end

function map.load_ammunition_impl(task)
    local turrets = {}
    log('supported turrets:' .. serpent.line(mapping.supported_turret_types()))
    if task.position then
        for _, v in pairs(mapping.supported_turret_types()) do
            local result = task.surface.find_entities_filtered{type = v, force = task.force, position = task.position, radius = task.range}
            for _, e in pairs(result) do
                table.insert(turrets, e)
            end
        end
    else
        for _, v in pairs(mapping.supported_turret_types()) do
            local result = task.surface.find_entities_filtered{type = v, force = task.force}
            for _, e in pairs(result) do
                table.insert(turrets, e)
            end
        end
    end
    local count = 0
    local ent_count = 0
    for _, turret in pairs(turrets) do
        local gun_to_ammo = mapping.get_gun_ammo_mapping()
        local lookup_value = gun_to_ammo[turret.name] or gun_to_ammo[turret.type]
        local valid_ammo = proto.get_ammunition_types(lookup_value)
        log('Found turret ' .. turret.name .. ' of ' .. turret.type .. ' at ' .. serpent.line(turret.position) .. ' valid ammo types: ' .. serpent.line(valid_ammo))
        if fml.contains(valid_ammo, task.ammo) and math.random(1, 100) <= task.chance then
            local inv = turret.get_inventory(defines.inventory.turret_ammo)
            local can_insert = inv.can_insert({name=task.ammo})
            if inv and (can_insert or task.replace == true) then
                if not can_insert then
                    -- dump current ammo
                    task.surface.spill_item_stack(turret.position, {name=inv[1].name, count=inv[1].count}, false, nil, true)
                    inv.clear()
                end
                local want = math.min(game.item_prototypes[task.ammo].stack_size, math.max(1, strutil.get_random_from_string_or_value(task.count, 5, 50)))

                local done = inv.insert({name=task.ammo, count=want})
                ent_count = ent_count + (done > 0 and 1 or 0)
                count = count + done
            end
        end
    end
    if #config['msg-map-load-ammo'] > 0 then
        task.force.print(strutil.replace_variables(config['msg-map-load-ammo'], {ent_count, count, {'item-name.' .. task.ammo}, strutil.get_gps_tag(task.surface, task.position), task.position ~= nil and task.range or '∞'}), count > 0 and constants.good or constants.neutral)
    end
end

function map.load_ammunition(surface, force, position, range, ammo_type, chance, count, replace, delay)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('Invalid / missing parameters: surface and force are required', constants.error)
        return
    end
    if position ~= nil and not tc.is_position(position) then
        game.print('Invalid parameters: position must be a valid position if specified', constants.error)
        return
    end
    if type(range) ~= 'number' then
        range = 50
    end
    if type(ammo_type) ~= 'string' then
        ammo_type = 'firearm-magazine'
    end
    if type(chance) ~= 'number' then
        chance = math.random(60, 90)
    end
    if type(count) ~= 'number' and not (type(count) == 'string' and strutil.split(count, ':')[1] == 'random') then
        count = math.random(5, 50)
    end
    if type(replace) ~= 'boolean' then
        replace = false
    end
    if type(delay) ~= 'number' then
        delay = 0
    end
    if not fml.contains(game.item_prototypes, ammo_type) or not fml.contains(proto.get_supported_ammo_types(), ammo_type) then
        game.print('Invalid parameters: ' .. ammo_type .. ' is not a valid ammunition', constants.error)
        log('Invalid ammunition type ' .. ammo_type .. ' valid choices: ' .. serpent.line(proto.get_supported_ammo_types()))
        return
    end

    chance = math.min(100, math.max(1, chance))

    local task = {}
    task['action'] = 'load_ammunition'
    task['surface'] = surface
    task['force'] = force
    task['position'] = position
    task['range'] = range
    task['ammo'] = ammo_type
    task['chance'] = chance
    task['count'] = count
    task['replace'] = replace
    task['delay'] = delay - 1

    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        map.load_ammunition_impl(task)
    end
end

function map.advance_rocket_silo_impl(task)
    local silos = {}
    if task.position then
        silos = task.surface.find_entities_filtered{type = 'rocket-silo', force = task.force, position = task.position, radius = task.range}
    else
        silos = task.surface.find_entities_filtered{type = 'rocket-silo', force = task.force}
    end

    local count = 0
    local parts = 0
    for _, silo in pairs(silos) do
        if count < task.max and math.random(1, 100) <= task.chance then
            local max_value = silo.prototype.rocket_parts_required
            local want = strutil.get_random_from_string_or_value(task.parts, 10, 75)
            local get = math.min(max_value, math.max(0, silo.rocket_parts + want))
            local change = get - silo.rocket_parts

            silo.rocket_parts = get
            parts = parts + change
            if change ~= 0 then
                count = count + 1
            end
        end
    end
    if #silos == 0 and #config['msg-map-adv-silo-no-result'] > 0 then
        task.force.print(strutil.replace_variables(config['msg-map-adv-silo-no-result'], {}), constants.neutral)
    elseif #config['msg-map-adv-silo-end'] > 0 then
        local color = constants.neutral
        if parts > 0 then
            color = constants.good
        elseif parts < 0 then
            color = constants.bad
        end
        task.force.print(strutil.replace_variables(config['msg-map-adv-silo-end'], {parts, count, task.position ~= nil and task.range or '∞', strutil.get_gps_tag(task.surface, task.position or {x=0, y=0})}), color)
    end
end

function map.advance_rocket_silo(surface, force, position, range, parts, max_count, chance, delay)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('Invalid / missing parameters: surface and force are required', constants.error)
        return
    end
    if position ~= nil and not tc.is_position(position) then
        game.print('Invalid parameters: position must be a valid position if specified', constants.error)
        return
    end
    if type(range) ~= 'number' then
        range = 50
    end
    if type(chance) ~= 'number' then
        chance = math.random(60, 90)
    end
    if type(delay) ~= 'number' then
        delay = 0
    end
    if type(max_count) ~= 'number' then
        max_count = 1
    end
    if type(parts) ~= 'number' and not (type(parts) == 'string' and strutil.split(parts, ':')[1] == 'random') then
        parts = math.random(10, 75)
        if math.random(1, 100) <= 5 then
            parts = parts * -1
        end
    end
    if type(parts) == 'number' then
        parts = math.max(-100, math.min(parts, 100))
    end

    local task = {}
    task['action'] = 'advance_rocket'
    task['surface'] = surface
    task['force'] = force
    task['position'] = position
    task['range'] = range
    task['parts'] = parts
    task['max'] = max_count
    task['chance'] = chance
    task['delay'] = math.max(0, delay - 1)

    if delay > 0 then
        if #config['msg-map-adv-silo'] > 0 then
            task.force.print(strutil.replace_variables(config['msg-map-adv-silo'], {task.surface.name, strutil.get_gps_tag(task.surface, task.position or {x=0, y=0}), task.position ~= nil and task.range or '∞', task.chance, strutil.split(task.parts, ':')[1], delay}), constants.neutral)
        end
        on_tick_n.add(game.tick + 60, task)
    else
        map.advance_rocket_silo_impl(task)
    end
end

function map.rain_item_impl(task)
    for i = 1, task.per_tick do
        local sur = task.entity and task.entity.surface or task.surface
        local center = task.entity and task.entity.position or task.position

        local pos = map.getRandomPositionInRange(center, task.range)
        local ent = sur.spill_item_stack(pos, {name=task.item, count=1}, false, nil, true)
        while not ent or #ent < 1 do
            pos = map.getRandomPositionInRange(center, task.range)
            ent = sur.spill_item_stack(pos, {name=task.item, count=1}, false, nil, true)
        end
    end
    task['done'] = task.done + task.per_tick
    if task.done < task.count then
        on_tick_n.add(game.tick + task.ticks, task)
    elseif #config['msg-map-rain-end'] > 0 then
        -- Send finish message
        local sur = task.entity and task.entity.surface or task.surface
        local pos = task.entity and task.entity.position or task.position
        game.print(strutil.replace_variables(config['msg-map-rain-end'], {task.done, mapping.locale_tuple(task.item), task.range, strutil.get_gps_tag(sur, pos), sur.name}), constants.neutral)
    end
end

function map.rain_item(surface, position, entity, item, range, count, duration, delay)
    if not game.item_prototypes[item] then
        game.print('Invalid item specified', constants.error)
        return
    end
    if not (entity and (tc.is_player(entity) or tc.is_unit(entity))) and not (tc.is_surface(surface) and tc.is_position(position)) then
        game.print('Invalid / missing parameters: either a moving entity or both a surface and position are required', constants.error)
        return
    end
    if type(range) ~= 'number' then
        range = 50
    end
    if type(count) ~= 'number' then
        count = math.random(10, 200)
    end
    if type(duration) ~= 'number' then
        duration = math.random(5, 30)
    end
    if type(delay) ~= 'number' then
        delay = 0
    end

    local task = {}
    task['action'] = 'rain_item'
    task['surface'] = surface
    task['position'] = position
    task['entity'] = entity
    task['range'] = range
    task['item'] = item
    task['count'] = count
    task['duration'] = duration
    task['ticks'] = 30
    task['per_tick'] = math.ceil(math.max(1, count / (duration * 60 / task.ticks)) - 0.5)
    task['delay'] = math.max(0, delay - 1)
    task['done'] = 0

    if #config['msg-map-rain'] > 0 then
        local sur = task.entity and task.entity.surface or task.surface
        local pos = task.entity and task.entity.position or task.position
        game.print(strutil.replace_variables(config['msg-map-rain'], {task.count, mapping.locale_tuple(task.item), task.range, strutil.get_gps_tag(sur, pos), sur.name, duration, delay}), constants.neutral)
    end
    if delay > 0 then
        on_tick_n.add(game.tick + 60, task)
    else
        map.rain_item_impl(task)
    end
end

return map
