-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local misc = {}

function misc.se_is_nav_mode(plr)
    if remote.interfaces['space-exploration'] and remote.interfaces['space-exploration']['remote_view_is_active'] then
        return remote.call('space-exploration', 'remote_view_is_active', {player=plr})
    end
    return false
end

function misc.se_start_nav_view(plr, surface, pos)
    if remote.interfaces['space-exploration']['remote_view_start'] then
        log('starting remote view to ' .. surface.name .. ' at ' .. serpent.line(pos))
        remote.call('space-exploration', 'remote_view_start', {player = plr, zone_name = surface.name, position = pos})
        return true
    end
    return false
end

function misc.se_stop_nav_view(plr)
    if remote.interfaces['space-exploration']['remote_view_stop'] then
        log('stopping remote view to ' .. plr.surface.name .. ' at ' .. serpent.line(plr.position))
        remote.call('space-exploration', 'remote_view_stop', {player = plr})
        return true
    end
    return false
end

return misc
