-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local build = {}
local research = require('funcs/research_tree')
local constants = require('constants')
local config = require('utils/config')
local strutil = require('utils/string_replace')

local function createResearchedGhosts(entities, chance, ignore_tech)
    local count = 0
    for _, e in pairs(entities) do
        if ignore_tech or research.can_build(e.force, e.ghost_name) then
            if math.random(1,100) <= chance then
                e.revive()
                count = count + 1
            end
        end
    end
    return count
end

local function getArea(entities)
    local x = nil
    local y = nil
    local x2 = nil
    local y2 = nil
    local padding = 0.6
    for _, e in pairs(entities) do
        if not x then
            x = math.ceil(e.position.x - padding)
        end
        if not x2 then
            x2 = math.floor(e.position.x + padding)
        end
        if not y then
            y = math.ceil(e.position.y - padding)
        end
        if not y2 then
            y2 = math.floor(e.position.y + padding)
        end
        if x > e.position.x then
            x = math.ceil(e.position.x - padding)
        end
        if x2 < e.position.x then
            x2 = math.floor(e.position.x + padding)
        end
        if y > e.position.y then
            y = math.ceil(e.position.y - padding)
        end
        if y2 < e.position.y then
            y2 = math.floor(e.position.y + padding)
        end
    end
    return {left_top={x, y}, right_bottom={x2, y2}}
end

build.build_ghosts = function(surface, force, position, range, chance, ignore_tech, include_remnants)
    if not surface or not force or not position then
        game.print('Invalid input parameters. Surface, Force, Position are required')
        return
    end
    if ignore_tech == nil then
        ignore_tech = false
    elseif ignore_tech then
        ignore_tech = true
    end
    if include_remnants == nil then
        include_remnants = false
    elseif include_remnants then
        include_remnants = true
    end
    range = range or 20
    chance = chance or 75
    local count = createResearchedGhosts(surface.find_entities_filtered{name='entity-ghost', radius=range, position=position, force=force}, chance, ignore_tech)
    local corpses = surface.find_entities_filtered{type='corpse', radius=range, position=position}
    for _, corpse in pairs(corpses) do
        if string.sub(corpse.name, -8) == 'remnants' and (ignore_tech or research.can_build(force, string.sub(corpse.name, 1, -10))) then
            local res = surface.create_entity{
                name = string.sub(corpse.name, 1, -10),
                position = corpse.position,
                direction = corpse.direction,
                raise_built = true,
                move_stuck_players = true,
                force = force
            }
            if res then
                count = count + 1
            end
        end
    end

    if count > 0 and #config['msg-build-ghost'] > 0 then
        force.print(strutil.replace_variables(config['msg-build-ghost'], {count}), constants.good)
    end

end

build.repair_base = function(surface, force, position, range, chance, min_gain, max_gain)
    if not surface or not force or not position then
        game.print('Invalid input parameters. Surface, Force, Position are required')
        return
    end
    range = range or 15
    chance = chance or 75
    min_gain = min_gain or 20
    max_gain = max_gain or 150
    local total_gain = 0
    local count = 0
    for _, e in pairs(surface.find_entities_filtered{radius=range, position=position, force=force}) do
        if e.name ~= 'entity-ghost' and math.random(1,100) <= chance then
            local max = math.ceil(e.health / e.get_health_ratio())
            local heal = math.random(math.max(0, min_gain), math.max(min_gain, max_gain))
            local new_health = math.min(e.health + heal, max)
            if new_health - e.health > 0 then
                count = count + 1
            end
            total_gain = total_gain + (new_health - e.health)
            e.health = new_health
        end
    end
    if #config['msg-build-repair'] > 0 then
        force.print(strutil.replace_variables(config['msg-build-repair'], {count, total_gain}), constants.good)
    end
end

build.build_blueprint = function(surface, force, position, bp_string, ignore_tech)
    if not surface or not force or not position or not bp_string or #bp_string < 10 then
        game.print('Invalid input parameters. Surface, Force, Position, Blueprint are required')
        return
    end
    if ignore_tech == nil then
        ignore_tech = false
    elseif ignore_tech then
        ignore_tech = true
    end
    local bp = surface.create_entity{name='item-on-ground', position=position, stack='blueprint'}
    if bp.stack.import_stack(bp_string) == 1 then
        game.print('Invalid Blueprint')
        bp.destroy()
        return
    end
    local entities = bp.stack.build_blueprint{surface=surface, force=force, position=position, force_build=true, skip_fog_of_war=false, raise_built=false}
    bp.destroy()
    local area = getArea(entities)
    local destroy_cliffs = ignore_tech or research.can_build(force, 'cliff-explosives')
    for _, e in pairs(surface.find_entities_filtered{area=area, to_be_deconstructed=true}) do
        if e.type == 'tree' or string.sub(e.name, 1, 5) == 'rock-' then
            e.destroy()
        elseif e.type == 'cliff' and destroy_cliffs then
            e.destroy()
        end
    end
    local count = createResearchedGhosts(entities, 100, ignore_tech)
    if #config['msg-build-bp'] > 0 then
        force.print(strutil.replace_variables(config['msg-build-bp'], {count}), constants.good)
    end
end

function build.deconstruct(surface, force, position, range, chance, max_count, ignore_tech)
    if not surface or not force then
        game.print('Invalid input parameters. Surface and Force are required')
        return
    end
    range = range or 500
    chance = chance or 5
    max_count = max_count or 2048
    if ignore_tech == nil then
        ignore_tech = false
    elseif ignore_tech then
        ignore_tech = true
    end

    chance = math.max(0, math.min(chance, 100))
    chance = chance * 10

    local entities = {}
    if position then
        entities = surface.find_entities_filtered{position=position, radius=range, force=force, to_be_deconstructed=false}
    else
        entities = surface.find_entities_filtered{force=force, to_be_deconstructed=false}
    end

    local count = 0
    for _, ent in pairs(entities) do
        if count < max_count and math.random(1, 1000) <= chance and (ignore_tech or research.can_build(force, ent.name)) then
            if ent.order_deconstruction(force) then
                count = count + 1
            end
        end
    end

    if #config['msg-build-decon'] > 0 then
        force.print(strutil.replace_variables(config['msg-build-decon'], {count}), count > 0 and constants.bad or constants.neutral)
    end
end

return build
