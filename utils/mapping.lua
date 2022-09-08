-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local mapping = {}

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

function mapping.locale_tuple(item)
    local key = ''
    if item == 'artillery-projectile' then
        item = 'artillery-shell'
    elseif item == 'atomic-rocket' then
        item = 'atomic-bomb'
    end

    if game.entity_prototypes[item] then
        key = 'entity-name.'
    elseif game.item_prototypes[item] then
        key = 'item-name.'
    end

    local se_size = 0
    if string.sub(item, 1, 20) == 'se-space-pipe-long-s' then
        se_size = tonumber(string.sub(item, 22))
        item = 'se-space-pipe-long-straight'
    elseif string.sub(item, 1, 20) == 'se-space-pipe-long-j' then
        se_size = tonumber(string.sub(item, 22))
        item = 'se-space-pipe-long-junction'
    end

    local retvar = { key .. item }
    if se_size > 0 then
        table.insert(retvar, se_size)
    end
    return retvar
end

return mapping
