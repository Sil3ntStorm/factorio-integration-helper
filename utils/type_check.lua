local tchck = {}
-- Will still error out in Factorio when providing a Factorio type that is not of
-- the desired type, saying that x does not have member y rather than retuning nil
-- Presumably due to some bridging of LUA mod interface and C++ Factorio code and
-- safety checks failing in the C++ layer

function tchck.is_position(obj)
    return type(obj) == 'table' and type(obj.x) == 'number' and type(obj.y) == 'number'
end

function tchck.is_surface(obj)
    return type(obj) == 'table' and type(obj.daytime) == 'number'
end

function tchck.is_player(obj)
    return type(obj) == 'table' and type(obj.is_player) == 'function' and obj.is_player()
end

function tchck.is_force(obj)
    return type(obj) == 'table' and type(obj.get_ammo_damage_modifier) == 'function'
end

return tchck
