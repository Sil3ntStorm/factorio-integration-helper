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
local tc = require('utils/type_check')
local plr = fml.include('funcs/player')
local misc = fml.include('utils/misc')

local blacklisted_vehicle_types = {'locomotive', 'artillery-wagon', 'cargo-wagon', 'fluid-wagon'}

function teleport.getPlayerPrototype(player)
    local real_char = plr.get_character(player)
    if real_char.vehicle and not fml.contains(blacklisted_vehicle_types, real_char.vehicle.type) then
        return real_char.vehicle.prototype
    end
    return real_char.prototype
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
    local real_char = plr.get_character(player)
    if not tc.is_position(position) or not tc.is_surface(surface) or not tc.is_player(player) or not player.connected or not real_char or not real_char.valid then
        return false
    end
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
        -- location set, teleport player
        if task.next_action then
            task['action'] = task.next_action
            task.next_action = nil
            on_tick_n.add(game.tick + 1, task)
        end
        return
    end

    if not task.player.valid or not task.player.connected then
        game.print('Player no longer connected, aborting teleport', constants.error)
        return
    end
    local real_char = plr.get_character(task.player)
    if not task.player.valid or not real_char or not real_char.valid then
        -- Player dead, try again next time
        global.silinthlp_teleport[task.player.name].finder = on_tick_n.add(game.tick + 30, task)
        return
    end

    local tgtPos = map.getRandomPositionInRealDistance(real_char.position, task.distance)
    if not teleport.checkTeleportLocationValid(task.dest_surface, tgtPos, task.player) then
        tgtPos = teleport.getNonCollidingPosition(task.dest_surface, tgtPos, task.player)
    end
    if teleport.checkTeleportLocationValid(task.dest_surface, tgtPos, task.player) then
        -- Store location for teleport next run
        teleport.setTeleportDestinationForPlayer(task.dest_surface, tgtPos, task.player)
    elseif global.silinthlp_teleport[task.player.name].attempts > config['teleport-attempts'] then
        -- Too many attempts, send player to spawn
        local spawnLoc = task.player.force.get_spawn_position(task.dest_surface)
        -- Use attempts to increase the range in which a safe position is found, in an attempt to get a successful teleport
        local range = math.max(10, global.silinthlp_teleport[task.player.name].attempts * 2)
        tgtPos = teleport.getNonCollidingPosition(task.dest_surface, spawnLoc or {x = 0, y = 0}, task.player, range)
        if global.silinthlp_teleport[task.player.name].attempts >= config['teleport-attempts'] * 2 and not teleport.checkTeleportLocationValid(task.dest_surface, tgtPos, task.player) then
            -- Twice the attempts, still no location. Give up
            if #config['msg-map-teleport-fail'] > 0 then
                task.player.force.print(strutil.replace_variables(config['msg-map-teleport-fail'], {task.player.name, task.dest_surface.name}), constants.neutral)
            end
            global.silinthlp_teleport[player.name] = nil
            log('teleport failed to due location invalid: ' .. serpent.line(tgtPos) .. ' on ' .. task.dest_surface.name .. ' for ' .. task.player.name .. ' a ' .. teleport.getPlayerPrototype(task.player))
            return
        end
        teleport.setTeleportDestinationForPlayer(task.dest_surface, tgtPos, task.player)
    end
    log('FindLocation for ' .. task.player.name .. ' had ' .. global.silinthlp_teleport[task.player.name].attempts .. ' attempts out of ' .. config['teleport-attempts'])
    -- Try again next time
    global.silinthlp_teleport[task.player.name].finder = on_tick_n.add(game.tick + 1, task)
end

local function doTP(plr, ent, dest, surface)
    if ent.surface ~= surface then
        -- Cross surface, cannot be done when controller is not character
        -- as the game complains, by simply calling the overload that accepts
        -- a destination surface, even when the entity is the character that
        -- is controlled by the player...
        if plr.controller_type ~= defines.controllers.character then
            if misc.se_is_nav_mode(plr) then
                -- SE Navigation Satellite mode
                local view_surface = plr.surface
                local view_pos = plr.position
                log('ViewPos: ' .. serpent.line(view_pos) .. ' ViewSurface: ' .. view_surface.name .. ' current surface: ' .. ent.surface.name .. ' current pos: ' .. serpent.line(ent.position) .. ' dest pos: ' .. serpent.line(dest) .. ' dest surface: ' .. surface.name)
                misc.se_stop_nav_view(plr)
                log('teleporting...')
                if plr.vehicle == ent then
                    ent.teleport(dest, surface)
                else
                    plr.teleport(dest, surface)
                end
                misc.se_start_nav_view(plr, view_surface, view_pos)
            else
                -- Not SE, enforce controller mode to teleport and fuck the rest
                log('Enforce controller to ' .. ent.type)
                if ent.type == 'character' then
                    plr.set_controller{type = defines.controllers.character, character = ent}
                    plr.teleport(dest, surface)
                else
                    log('Failed to teleport. Cannot set player controller to entity type ' .. ent.type)
                end
            end
        else
            -- Player is controlling character
            if ent == plr.character then
                log('Player teleport')
                plr.teleport(dest, surface)
            elseif ent == plr.character.vehicle then
                log('Entity teleport as player vehicle')
                ent.teleport(dest, surface)
            end
        end
    else
        log('entity teleport')
        ent.teleport(dest)
    end
end

function teleport.actualTeleport(player, surface, dest)
    if not tc.is_player(player) or not tc.is_surface(surface) or not tc.is_position(dest) then
        game.print('Missing parameters: player, surface, position are required', constants.error)
        return
    end
    global.silinthlp_teleport = global.silinthlp_teleport or {}
    if not teleport.checkTeleportLocationValid(surface, dest, player) then
        if #config['msg-map-teleport-fail'] > 0 then
            player.force.print(strutil.replace_variables(config['msg-map-teleport-fail'], {player.name, surface.name}), constants.neutral)
        end
        global.silinthlp_teleport[player.name] = nil
        return
    end
    local real_char = plr.get_character(player)
    local oldPos = real_char.position
    local oldSur = real_char.surface
    log('From ' .. serpent.line(oldPos) .. ' on ' .. oldSur.name .. ' to ' .. serpent.line(dest) .. ' on ' .. surface.name)
    if real_char.vehicle then
        if not fml.contains(blacklisted_vehicle_types, real_char.vehicle.type) then
            -- real_char.vehicle.teleport(dest, surface)
            doTP(player, real_char.vehicle, dest, surface)
        else
            real_char.vehicle.set_driver(nil)
            -- real_char.teleport(dest, surface)
            doTP(player, real_char, dest, surface)
        end
    else
        -- real_char.teleport(dest, surface)
        doTP(player, real_char, dest, surface)
    end
    global.silinthlp_teleport[player.name] = nil
    if #config['msg-map-teleport-player'] > 0 then
        local distance = map.getDistance(oldPos, dest)
        player.force.print(strutil.replace_variables(config['msg-map-teleport-player'], {player.name, math.floor(distance + 0.5), strutil.get_gps_tag(oldSur, oldPos), strutil.get_gps_tag(surface, dest)}))
    end
end

return teleport
