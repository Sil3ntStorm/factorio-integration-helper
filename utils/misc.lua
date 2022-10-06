-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local misc = {}

function misc.is_se_nav_mode(plr)
	if remote.interfaces['space-exploration'] and remote.interfaces['space-exploration']['remote_view_is_active'] then
		return remote.call('space-exploration', 'remote_view_is_active', {player=plr})
	end
	return false
end

return misc
