-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local teleport = {}
local on_tick_n = require('__flib__.on-tick-n')
local fml = require('utils/lua_is_stupid')
local map = fml.include('funcs/map')
local config = fml.include('utils/config')
local strutil = fml.include('utils/string_replace')
local constants = fml.include('constants')

function teleport.getPlayerPrototype(player)
    local player_prototype = player.character.prototype
    if player.vehicle and player.vehicle ~= 'locomotive' then
        player_prototype = player.vehicle.prototype
    end
    return player_prototype
end

function teleport.getNonCollidingPosition(surface, position, player, range)
    range = range or 10
    local player_prototype = teleport.getPlayerPrototype(player)
    local size = math.ceil(math.abs(player_prototype.collision_box.left_top.x) + math.abs(player_prototype.collision_box.right_bottom.x))
    local pos = position
    if not surface.can_place_entity{name=player_prototype.name, position=position, force=player.force} then
        pos = surface.find_non_colliding_position(player_prototype.name, position, range, size)
    end
    return pos
end

function teleport.checkTeleportLocationValid(surface, position, player)
    local chunkPos = {x = position.x / 32, y = position.y / 32}
    if (not surface.is_chunk_generated(chunkPos)) then
        surface.request_to_generate_chunks(position, 2)
        surface.force_generate_chunk_requests()
    end
    local tile = surface.get_tile(position)
    local player_prototype = teleport.getPlayerPrototype(player)
    if not tile.collides_with('player-layer') then
        return position and surface.can_place_entity{name=player_prototype.name, position=position, force=player.force}
    end
    return false
end

function teleport.setTeleportDestinationForPlayer(surface, pos, player)
    global.silinthlp_teleport[player.name].location = pos
    global.silinthlp_teleport[player.name].surface = surface
end

function teleport.getTeleportDestinationForPlayer(player, surface)
    if global.silinthlp_teleport and global.silinthlp_teleport[player.name] then
        if surface and not global.silinthlp_teleport[player.name].location then
            return teleport.getNonCollidingPosition(surface, {x = 0, y = 0}, player, 50)
        end
        return global.silinthlp_teleport[player.name].location
    end
    return nil
end

function teleport.findRandomTeleportLocationForPlayer(task)
    if not global.silinthlp_teleport then
        global.silinthlp_teleport = {}
    end
    if not global.silinthlp_teleport[task.player.name] then
        global.silinthlp_teleport[task.player.name] = {attempts = 1, location = nil, finder = nil}
    else
        global.silinthlp_teleport[task.player.name].attempts = global.silinthlp_teleport[task.player.name].attempts + 1
    end
    if global.silinthlp_teleport[task.player.name].location then
        if task.next_action then
            task['action'] = task.next_action
            task.next_action = nil
            on_tick_n.add(game.tick + 1, task)
        end
        return
    end

    local tgtPos = map.getRandomPositionInRealDistance(task.player.position, task.distance)
    if not teleport.checkTeleportLocationValid(task.dest_surface, tgtPos, task.player) then
        tgtPos = teleport.getNonCollidingPosition(task.dest_surface, tgtPos, task.player)
    end
    if teleport.checkTeleportLocationValid(task.dest_surface, tgtPos, task.player) then
        teleport.setTeleportDestinationForPlayer(task.dest_surface, tgtPos, task.player)
    elseif global.silinthlp_teleport[task.player.name].attempts > config['teleport-attempts'] then
        -- Too many attempts, send player to spawn
        tgtPos = teleport.getNonCollidingPosition(task.dest_surface, {x = 0, y = 0}, task.player)
        teleport.setTeleportDestinationForPlayer(task.dest_surface, tgtPos, task.player)
    end
    -- Try again next time
    global.silinthlp_teleport[task.player.name].finder = on_tick_n.add(game.tick + 1, task)
end

function teleport.actualTeleport(player, surface, dest)
    if not player or not surface or not dest then
        game.print('Missing parameters', constants.error)
        return
    end
    if not teleport.checkTeleportLocationValid(surface, dest, player) then
        if #config['msg-map-teleport-fail'] > 0 then
            player.force.print(strutil.replace_variables(config['msg-map-teleport-fail'], {player.name, surface.name}), constants.neutral)
        end
        global.silinthlp_teleport[player.name] = nil
        return
    end
    local oldPos = player.position
    if player.vehicle then
        if player.vehicle.type ~= 'locomotive' then
            player.vehicle.teleport(dest, surface)
        else
            player.vehicle.set_driver(nil)
            player.teleport(dest, surface)
        end
    else
        player.teleport(dest, surface)
    end
    global.silinthlp_teleport[player.name] = nil
    if #config['msg-map-teleport-player'] > 0 then
        local distance = map.getDistance(oldPos, dest)
        player.force.print(strutil.replace_variables(config['msg-map-teleport-player'], {player.name, math.floor(distance + 0.5), '[gps=' .. math.floor(oldPos.x + 0.5) .. ',' .. math.floor(oldPos.y + 0.5) .. ']', '[gps=' .. math.floor(dest.x + 0.5) .. ',' .. math.floor(dest.y + 0.5) .. ']'}))
    end
end

return teleport
