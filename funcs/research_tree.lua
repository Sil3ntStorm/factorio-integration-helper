-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local research = {}
local on_tick_n = require('__flib__.on-tick-n')
local constants = require('constants')
local config = require('utils/config')
local strutil = require('utils/string_replace')

function research.init()
    global.silinthlp_tech = {}
    for _, f in pairs(game.forces) do 
        if not global.silinthlp_tech[f.name] then
            global.silinthlp_tech[f.name] = {}
        end
        for _, t in pairs(f.technologies) do
            for _, e in pairs(t.effects) do
                if e.type == 'unlock-recipe' then
                    global.silinthlp_tech[f.name][e.recipe] = t.name
                end
            end
        end
    end
end

function research.can_build(force, prototype)
    local researched = true
    if global.silinthlp_tech[force.name][prototype] then
        researched = force.technologies[global.silinthlp_tech[force.name][prototype]].researched
    end
    return researched and force.recipes[prototype] and force.recipes[prototype].enabled
end

function research.can_research(force, tech)
    for _, r in pairs(force.technologies[tech].prerequisites) do
        if not r.researched then
            return false
        end
    end
    return true
end

function research.available_research(force)
    local result = {}
    for _, t in pairs(force.technologies) do
        if (not t.researched and research.can_research(force, t.name)) then
            result[t.name] = t
        end
    end
    return result
end

function research.get_random_available_research(force, exclude_current)
    local avail = research.available_research(force)
    local keys = {}
    for k in pairs(avail) do
        table.insert(keys, k)
    end
    local result = keys[math.random(1, #keys)]
    if exclude_current and force.current_research and #keys > 1 and force.current_research.name == result then
        local tries = 0
        while force.current_research.name == result and tries < 5 do
            result = keys[math.random(1, #keys)]
            tries = tries + 1
        end
    end
    return avail[result]
end

function research.start_research(force, chance)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 50
    if math.random(1, 100) <= chance then
        local prev_name = ''
        if force.current_research then
            prev_name = force.current_research.localised_name
        end
        local selected = research.get_random_available_research(force, true)
        if force.research_queue_enabled then
            local queue = force.research_queue or {}
            force.research_queue_enabled = false
            force.cancel_current_research()
            force.add_research(selected)
            force.research_queue_enabled = true
            for _, r in pairs(queue) do
                force.add_research(r)
            end
        else
            force.cancel_current_research()
            force.add_research(selected)
        end
        if #config['msg-research-changed'] > 0 then
            force.print(strutil.replace_variables(config['msg-research-changed'], {selected.localised_name, prev_name, force.name}), constants.neutral)
        end
    end
end

function research.cancel_research(force, chance)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 50
    if math.random(1, 100) <= chance then
        local prev_name = ''
        if force.current_research then
            prev_name = force.current_research.localised_name
        end
        force.cancel_current_research()
        if #config['msg-research-canceled'] > 0 then
            force.print(strutil.replace_variables(config['msg-research-canceled'], {prev_name, force.name}), constants.neutral)
        end
    end
end

function research.advance_research(force, chance, percent)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 75
    if not percent then
        percent = math.random(10, 75)
        if math.random(1, 100) <= 5 then
            percent = percent * -1
        end
    end
    percent = math.max(-100, math.min(percent, 100))
    if math.random(1, 100) <= chance then
        local current = force.research_progress
        local active_research = force.current_research
        if not active_research then
            return
        end
        local target = current + (percent / 100)
        target = math.min(1, math.max(0, target))
        force.research_progress = target
        if target > current and #config['msg-research-advanced'] > 0 then
            force.print(strutil.replace_variables(config['msg-research-advanced'], {active_research.localised_name, string.format('%.2f', target * 100), force.name}), constants.good)
        elseif target < current and #config['msg-research-reduced'] > 0 then
            force.print(strutil.replace_variables(config['msg-research-reduced'], {active_research.localised_name, string.format('%.2f', target * 100), force.name}), constants.bad)
        end
    end
end

function research.disable_research(force, chance, seconds)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 50
    if not seconds then
        seconds = math.random(30, 300)
    end
    if math.random(1, 100) <= chance then
        local hasQueue = force.research_queue_enabled
        local queue = force.research_queue or {}
        local task = {}
        task['action'] = 'enable_research'
        task['force'] = force
        task['has_queue'] = hasQueue
        task['queue'] = queue
        force.disable_research()
        force.research_queue_enabled = false
        force.cancel_current_research()
        on_tick_n.add(game.tick + (seconds * 60), task)
        if #config['msg-research-disabled'] > 0 then
            force.print(strutil.replace_variables(config['msg-research-disabled'], {seconds}), constants.bad)
        end
    end
end

function research.enable_research(force, chance, queue, enable_queue)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 50
    if math.random(1, 100) <= chance then
        force.enable_research()
        if enable_queue then
            force.research_queue_enabled = true
            force.research_queue = queue
        elseif #queue > 0 then
            force.add_research(queue[1])
        end
        if #config['msg-research-enabled'] > 0 then
            force.print(config['msg-research-enabled'], constants.good)
        end
    end
end

function research.change_speed(force, boost, chance, duration)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 75
    duration = duration or math.random(10, 180)

    local function rndBoost()
        local val = math.random(1, 100)
        if math.random(1, 100) <= 5 then
            val = val * -1
        end
        return val
    end

    if not boost then
        boost = rndBoost()
    end
    boost = math.min(200, math.max(-100, boost))
    if boost == 0 then
        boost = rndBoost()
    end

    if math.random(1, 100) >= chance then
        return
    end

    local original = force.laboratory_speed_modifier
    local modifier = 1 + (boost / 100)
    if original == 0 then
        -- No lab speed research yet for this force
        force.laboratory_speed_modifier = math.max(-1, modifier - 1)
    else
        force.laboratory_speed_modifier = math.max(-1, original + modifier - 1)
    end

    local task = {}
    task['action'] = 'restore_lab_speed'
    task['force'] = force
    task['modifier'] = modifier
    task['original'] = original
    task['added'] = force.laboratory_speed_modifier - original

    on_tick_n.add(game.tick + duration * 60, task)

    if #config['msg-research-lab-speed'] > 0 then
        force.print(strutil.replace_variables(config['msg-research-lab-speed'], {force.name, (force.laboratory_speed_modifier + 1) * 100, duration}), modifier > 1 and constants.good or constants.bad)
    end
end

function research.set_arti_range(force, levels, chance, duration)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 50
    duration = duration or math.random(60, 180)
    levels = math.floor(math.min(21, math.max(1, levels)))

    if math.random(1, 100) > chance then
        return
    end

    local task = {}
    task['action'] = 'reset_arti_range'
    task['force'] = force
    task['added'] = levels * 0.3

    force.artillery_range_modifier = force.artillery_range_modifier + task.added

    on_tick_n.add(game.tick + duration * 60, task)

    if #config['msg-research-arti-range'] > 0 then
        force.print(strutil.replace_variables(config['msg-research-arti-range'], {levels, duration}), constants.good)
    end
end

function research.set_arti_speed(force, levels, chance, duration)
    if not force then
        game.print('Force is required')
        return
    end
    chance = chance or 50
    duration = duration or math.random(60, 180)
    levels = math.floor(math.min(21, math.max(1, levels)))
    
    if math.random(1, 100) > chance then
        return
    end

    local task = {}
    task['action'] = 'reset_arti_speed'
    task['force'] = force
    task['added'] = levels

    local original = force.get_gun_speed_modifier('artillery-turret')
    force.set_gun_speed_modifier('artillery-turret', original + levels)
    
    on_tick_n.add(game.tick + duration * 60, task)

    if #config['msg-research-arti-speed'] > 0 then
        force.print(strutil.replace_variables(config['msg-research-arti-speed'], {levels, duration}), constants.good)
    end
end

return research
