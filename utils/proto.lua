local proto = {}

function proto.get_entity_prototypes()
    local result = game.get_filtered_entity_prototypes({{filter='buildable'}, {filter='minable', mode='and'}, {filter='flag', flag='placeable-player', mode='and'}})
    local ret = {}
    for name, _ in pairs(result) do
        table.insert(ret, name)
    end
    return ret
end

return proto
