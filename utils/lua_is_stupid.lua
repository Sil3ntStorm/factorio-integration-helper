local properLanguagePlease = {}

function properLanguagePlease.actual_size(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function properLanguagePlease.actual_length(tbl)
    return properLanguagePlease.actual_size(tbl)
end

function properLanguagePlease.contains(tbl, val)
    for k,v in pairs(tbl) do
        if k == val or v == val then
            return true
        end
    end
    return false
end

function properLanguagePlease.include(file)
    properLanguagePlease.loading = properLanguagePlease.loading or {}
    if not properLanguagePlease.loading[file] then
        properLanguagePlease.loading[file] = true
        local x = require(file)
        properLanguagePlease.loading[file] = nil
        return x
    end
end

return properLanguagePlease
