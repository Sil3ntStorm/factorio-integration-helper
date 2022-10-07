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

function mapping.item_name_overrides()
    local list = {}
    list['artillery-projectile'] = 'artillery-shell'
    list['atomic-rocket'] = 'atomic-bomb'
    list['se-plague-rocket'] = 'se-plague-bomb'
    return list
end

function mapping.locale_tuple(item)
    local key = ''
    item = mapping.item_name_overrides()[item] or item

    if game.entity_prototypes[item] then
        log(item .. ' (E) = ' .. game.entity_prototypes[item].type)
        key = 'entity-name.'
    elseif game.item_prototypes[item] then
        log(item .. ' (I) = ' .. game.item_prototypes[item].type)
        key = 'item-name.'
    end

    if game.item_prototypes[item] then
        local tmp = game.item_prototypes[item]
        if tmp.type == 'ammo' or tmp.type == 'capsule' then
            key = 'item-name.'
        end
    end

    local se_size = 0
    if string.sub(item, 1, 20) == 'se-space-pipe-long-s' then
        se_size = tonumber(string.sub(item, 22))
        item = 'se-space-pipe-long-straight'
    elseif string.sub(item, 1, 20) == 'se-space-pipe-long-j' then
        se_size = tonumber(string.sub(item, 22))
        item = 'se-space-pipe-long-junction'
    elseif string.sub(item, 1, 18) == 'se-falling-meteor-' then
        item = 'meteorite'
    end

    local retvar = { key .. item }
    if se_size > 0 then
        table.insert(retvar, se_size)
    end

    return retvar
end

return mapping
