-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local strutil = {}

local fml = require('utils/lua_is_stupid')

strutil.replace_variables_o = function(str, replacements)
    local count = 1
    local result = {''}
    for _, r in pairs(replacements) do
        local var = '__' .. count .. '__'
        local s, e = string.find(str, var)
        if s ~= nil and e ~= nil then
            if s > 1 then
                table.insert(result, string.sub(str, 1, s - 1))
            end
            table.insert(result, r)
            str = string.sub(str, e + 1, -1)
        end
        count = count + 1
    end
    if #str > 0 then
        table.insert(result, str)
    end
    return result
end

strutil.replace_variables = function(str, replacements)
    local result = {''}
    local rs = fml.actual_size(replacements)
    local s, e = string.find(str, '__')
    while s and e do
        local s2, e2 = string.find(str, '__', e)
        if s2 and e2 then
            local var = string.sub(str, s, e2 + 1)
            local idx = tonumber(string.sub(str, e + 1, s2 - 1))
            if s > 1 then
                table.insert(result, string.sub(str, 1, s - 1))
            end
            if idx <= rs then
                table.insert(result, replacements[idx])
            end
            str = string.sub(str, e2 + 1, -1)
        end
        s, e = string.find(str, '__')
    end
    if #str > 0 then
        table.insert(result, str)
    end
    return result
end

strutil.get_gps_tag = function(surface, position)
    local msg = '[gps='
    if position and position.x and position.y then
        msg = msg .. math.floor(position.x + 0.5) .. ',' .. math.floor(position.y + 0.5)
    else
        msg = msg .. '0,0'
    end
    if surface.name ~= 'nauvis' then
        msg = msg .. ',' .. surface.name
    end
    msg = msg .. ']'
    return msg
end

strutil.split = function(str, delim)
    local result = {}
    string.gsub(str, '([^' .. delim .. ']+)', function (r)
        table.insert(result, r)
    end)
    return result
end

strutil.get_random_from_string_or_default = function(str, default_min, default_max)
    local tmp = strutil.split(str, ':')
    if tmp[1] == 'random' then
        tmp[2] = tmp[2] or default_min
        tmp[3] = tmp[3] or default_max
        return math.random(math.min(tmp[2], tmp[3]), math.max(tmp[2], tmp[3]))
    end
    return math.random(default_min, default_max)
end

strutil.get_random_from_string_or_value = function(str, default_min, default_max)
    local tmp = strutil.split(str, ':')
    if tmp[1] == 'random' then
        tmp[2] = tmp[2] or default_min
        tmp[3] = tmp[3] or default_max
        return math.random(math.min(tmp[2], tmp[3]), math.max(tmp[2], tmp[3]))
    end
    return str
end

return strutil
