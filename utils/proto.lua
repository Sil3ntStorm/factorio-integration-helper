-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local proto = {}

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

return proto
