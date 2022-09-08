local tchck = {}
-- Will still error out in Factorio when providing a Factorio type that is not of
-- the desired type, saying that x does not have member y rather than retuning nil
-- Presumably due to some bridging of LUA mod interface and C++ Factorio code and
-- safety checks failing in the C++ layer

function tchck.is_position(obj)
    return type(obj) == 'table' and ((type(obj.x) == 'number' and type(obj.y) == 'number') or (#obj == 2 and type(obj[1]) == 'number' and type(obj[2]) == 'number'))
end

function tchck.is_surface(obj)
    return type(obj) == 'table' and type(obj.daytime) == 'number'
end

function tchck.is_player(obj)
    return type(obj) == 'table' and obj.object_name == 'LuaPlayer' and type(obj.is_player) == 'function' and obj.is_player()
end

function tchck.is_force(obj)
    if type(obj) == 'string' then
        return game.forces[obj] ~= nil
    end
    return type(obj) == 'table' and type(obj.get_ammo_damage_modifier) == 'function'
end

function tchck.is_unit(obj)
    return type(obj) == 'table' and obj.valid and obj.object_name == 'LuaEntity' and obj.type == 'unit'
end

return tchck
