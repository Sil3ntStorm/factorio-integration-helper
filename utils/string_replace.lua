-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local strutil = {}

strutil.replace_variables = function(str, replacements)
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

return strutil
