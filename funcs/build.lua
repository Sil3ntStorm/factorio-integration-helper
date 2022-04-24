-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

local build = {}
local research = require('funcs/research_tree')
local constants = require('constants')
local config = require('utils/config')
local strutil = require('utils/string_replace')
local proto = require('utils/proto')
local fml = require('utils/lua_is_stupid')
local map = require('funcs/map')
local tc = require('utils/type_check')

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
    if not tc.is_surface(surface) or not tc.is_force(force) or not tc.is_position(position) then
        game.print('Invalid input parameters. Surface, Force, Position are required', constants.error)
        return
    end
    if ignore_tech ~= false and ignore_tech ~= true then
        ignore_tech = false
    end
    if include_remnants ~= false and include_remnants ~= true then
        include_remnants = false
    end
    range = range or 20
    chance = chance or 75
    local count = createResearchedGhosts(surface.find_entities_filtered{name='entity-ghost', radius=range, position=position, force=force}, chance, ignore_tech)
    local validTypes = proto.get_entity_prototypes()
    if include_remnants then
        local corpses = surface.find_entities_filtered{type='corpse', radius=range, position=position}
        for _, corpse in pairs(corpses) do
            if corpse.valid then
                local toBuild = string.sub(corpse.name, 1, -10)
                local isValidType = fml.contains(validTypes, toBuild)
                if not isValidType then
                    log('Type ' .. toBuild .. ' is not listed in valid entities: ' .. serpent.line(validTypes))
                end
                if math.random(1, 100) <= chance and string.sub(corpse.name, -8) == 'remnants' and (ignore_tech or research.can_build(force, toBuild)) and isValidType then
                    local res = surface.create_entity{
                        name = toBuild,
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
        end
    end

    if #config['msg-build-ghost'] > 0 then
        force.print(strutil.replace_variables(config['msg-build-ghost'], {count}), count > 0 and constants.good or constants.neutral)
    end

end

build.repair_base = function(surface, force, position, range, chance, min_gain, max_gain)
    if not tc.is_surface(surface) or not tc.is_force(force) or not tc.is_position(position) then
        game.print('Invalid input parameters. Surface, Force, Position are required', constants.error)
        return
    end
    range = range or 15
    chance = chance or 75
    min_gain = min_gain or 20
    max_gain = max_gain or 150
    local total_gain = 0
    local count = 0
    for _, e in pairs(surface.find_entities_filtered{radius=range, position=position, force=force}) do
        if e.name ~= 'entity-ghost' and e.type ~= 'fire' and e.type ~= 'character' and math.random(1,100) <= chance then
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
        force.print(strutil.replace_variables(config['msg-build-repair'], {count, math.floor(total_gain + 0.5)}), constants.good)
    end
end

build.build_blueprint = function(surface, force, position, bp_string, ignore_tech)
    if not tc.is_surface(surface) or not tc.is_force(force) or not tc.is_position(position) or not bp_string or #bp_string < 10 then
        game.print('Invalid input parameters. Surface, Force, Position, Blueprint are required', constants.error)
        return
    end
    if ignore_tech ~= false and ignore_tech ~= true then
        ignore_tech = false
    end
    local bp = surface.create_entity{name='item-on-ground', position=map.getRandomPositionInRange(position, 90), stack='blueprint'}
    if bp.stack.import_stack(bp_string) == 1 then
        game.print('Invalid Blueprint', constants.error)
        bp.destroy()
        return
    end
    local entities = bp.stack.build_blueprint{surface=surface, force=force, position=position, force_build=true, skip_fog_of_war=false, raise_built=false}
    bp.destroy()
    if #entities > 0 then
        local area = getArea(entities)
        local destroy_cliffs = ignore_tech or research.can_build(force, 'cliff-explosives')
        for _, e in pairs(surface.find_entities_filtered{area=area, to_be_deconstructed=true}) do
            if e.type == 'tree' or string.sub(e.name, 1, 5) == 'rock-' then
                e.destroy()
            elseif e.type == 'cliff' and destroy_cliffs then
                e.destroy()
            end
        end
    end
    local count = createResearchedGhosts(entities, 100, ignore_tech)
    if #config['msg-build-bp'] > 0 then
        force.print(strutil.replace_variables(config['msg-build-bp'], {count}), count > 0 and constants.good or constants.neutral)
    end
end

function build.deconstruct(surface, force, position, range, chance, max_count, ignore_tech)
    if not tc.is_surface(surface) or not tc.is_force(force) then
        game.print('Invalid input parameters. Surface and Force are required', constants.error)
        return
    end
    if position and not tc.is_position(position) then
        game.print('Invalid input parameters. If specified position must be valid position', constants.error)
        return
    end
    range = range or 500
    chance = chance or 5
    max_count = max_count or 2048
    if ignore_tech ~= false and ignore_tech ~= true then
        ignore_tech = false
    end

    chance = math.max(0, math.min(chance, 100))
    chance = chance * 10

    local entities = {}
    if tc.is_position(position) and type(range) == 'number' then
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
