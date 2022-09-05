-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local mapping = {}
local fml = require('utils/lua_is_stupid')

function mapping.get_gun_ammo_mapping()
    -- Lua can go get fucked, this is perfectly valid (or it should be)
    -- return {
    --     'ammo-turret': 'bullet',
    --     'artillery-turret': 'artillery-shell'
    -- }
    local ret = {}
    ret['ammo-turret'] = 'bullet'
    ret['artillery-turret'] = 'artillery-shell'
    ret['se-meteor-point-defence-container'] = 'se-meteor-point-defence'
    ret['se-meteor-defence-container'] = 'se-meteor-defence'
    return ret
end

function mapping.supported_turret_types()
    return fml.keys(mapping.get_gun_ammo_mapping())
end

return mapping
