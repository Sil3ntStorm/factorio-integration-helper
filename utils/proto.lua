-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local proto = {}
local fml = require('utils/lua_is_stupid')
local mapping = fml.include('utils/mapping')

function proto.get_entity_prototypes()
    local result = game.get_filtered_entity_prototypes({{filter='buildable'}, {filter='minable', mode='and'}, {filter='flag', flag='placeable-player', mode='and'}})
    local ret = {}
    for name, _ in pairs(result) do
        ret[name] = true
    end
    result = game.get_filtered_entity_prototypes({{filter='flag', flag='placeable-player', mode='or'}, {filter='flag', flag='player-creation', mode='or'}, {filter='type', type='corpse', mode='and', invert=true}})
    for name, _ in pairs(result) do
        ret[name] = true
    end
    local rval = {}
    for name, _ in pairs(ret) do
        table.insert(rval, name)
    end
    return rval
end

function proto.get_projectiles()
    local result = game.get_filtered_entity_prototypes({{filter='type', type='projectile'}, {filter='type', type='artillery-projectile', mode='or'}})
    local rval = {}
    for name, _ in pairs(result) do
        table.insert(rval, name)
    end
    return rval
end

function proto.get_ammunition_types(cat)
    local result = game.get_filtered_item_prototypes({{filter='type', type='ammo'}})
    local rval = {}
    for _, ammo in pairs(result) do
        if ammo.get_ammo_type().category == cat then
            table.insert(rval, ammo.name)
        end
    end
    return rval
end

function proto.get_supported_ammo_types()
    local result = {}
    for _, v in pairs(mapping.get_gun_ammo_mapping()) do
        for _, a in pairs(proto.get_ammunition_types(v)) do
            table.insert(result, a)
        end
    end
    return result
end

return proto
