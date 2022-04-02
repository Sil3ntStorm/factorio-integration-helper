-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local config = {}
local configPrefix = 'sil-ihlp-'
local prefixLength = #configPrefix

for k, v in pairs(settings.global) do
    if string.sub(k, 1, prefixLength) == configPrefix then
        config[string.sub(k, prefixLength + 1)] = v.value
    end
end

local function onRTSettingChanged(event)
    if string.sub(event.setting, 1, prefixLength) ~= configPrefix then
        return
    end
    config[string.sub(event.setting, prefixLength + 1)] = settings.global[event.setting].value
end
script.on_event(defines.events.on_runtime_mod_setting_changed, onRTSettingChanged)

return config
