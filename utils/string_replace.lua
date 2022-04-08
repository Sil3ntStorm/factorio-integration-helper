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

return strutil
