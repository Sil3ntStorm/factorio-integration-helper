-- Copyright 2022 Sil3ntStorm https://github.com/Sil3ntStorm
--
-- Licensed under MS-RL, see https://opensource.org/licenses/MS-RL

data:extend({
    {
        name = 'sil-ihlp-msg-research-changed',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bc',
        default_value = '__1__ just became a priority research...'
    },
    {
        name = 'sil-ihlp-msg-research-canceled',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'be',
        default_value = '__1__ research has been canceled...'
    },
    {
        name = 'sil-ihlp-msg-research-advanced',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ba',
        default_value = 'Wow, this research goes fast...'
    },
    {
        name = 'sil-ihlp-msg-research-reduced',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bb',
        default_value = 'Ohoh, looks like research has been slow...'
    },
    {
        name = 'sil-ihlp-msg-research-disabled',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bg',
        default_value = 'Research has been disabled for __1__ seconds'
    },
    {
        name = 'sil-ihlp-msg-research-arti-speed',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bh',
        default_value = 'Artillery is shooting faster for __2__ seconds'
    },
    {
        name = 'sil-ihlp-msg-research-arti-range',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bi',
        default_value = 'Artillery is shooting __1__ further for __2__ seconds'
    },
    {
        name = 'sil-ihlp-msg-research-lab-speed',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bj',
        default_value = '__1__ research labs are running at __2__% speed for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-research-enabled',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bh',
        default_value = 'Research has been enabled'
    },
    {
        name = 'sil-ihlp-msg-build-repair',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'da',
        default_value = '__1__ buildings have been repaired. A total of __2__ hitpoints have been restored'
    },
    {
        name = 'sil-ihlp-msg-build-ghost',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'db',
        default_value = 'Construction is really fast, __1__ buildings were constructed'
    },
    {
        name = 'sil-ihlp-msg-build-bp',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'dc',
        default_value = 'Construction is really fast, __1__ buildings were constructed'
    },
    {
        name = 'sil-ihlp-msg-build-decon',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'dd',
        default_value = '__1__ buildings were deconstructed'
    },
    {
        name = 'sil-ihlp-msg-map-teleport-player',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fa',
        default_value = '__1__ just got teleported __2__ tiles from __3__ to __4__'
    },
    {
        name = 'sil-ihlp-msg-map-reset-assembler',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fb',
        default_value = 'A disturbance in the force caused __1__ assembling machines to lose their alignment'
    },
    {
        name = 'sil-ihlp-msg-map-revive-biters',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fc',
        default_value = 'Biters have a __1__% chance to respawn on death for __2__ seconds'
    },
    {
        name = 'sil-ihlp-msg-map-revive-biters-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fd',
        default_value = 'Biters ran out of their magic potion and won\'t respawn upon death'
    },
    {
        name = 'sil-ihlp-msg-map-enemy-turret',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fe',
        default_value = '__1__ artillery turrets within __2__ tiles now belong to the enemy'
    },
    {
        name = 'sil-ihlp-msg-map-remove-entity',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ff',
        default_value = '__1__ __2__ have disappeared into the void'
    },
    {
        name = 'sil-ihlp-msg-map-remove-entity-nothing',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fg',
        default_value = 'No entities were found for __1__'
    },
    {
        name = 'sil-ihlp-msg-player-walk-speed-inc',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ga',
        default_value = 'All that walking __1__ has been doing seems to have paid off, they are running __2__% faster for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-walk-speed-dec',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gb',
        default_value = '__1__ legs are getting weak, they are walking __2__% slower for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-craft-speed-inc',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ga',
        default_value = '__1__ biceps have been growing, they are crafting __2__% faster for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-craft-speed-dec',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gb',
        default_value = '__1__ arms are tired, they are crafting __2__% slower for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-on-fire',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gc',
        default_value = 'Anything within __2__ blocks around __1__ is now on fire (__3__ seconds)'
    },
    {
        name = 'sil-ihlp-msg-player-barrage-start',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gd',
        default_value = 'Stay away from __1__, they seem to attract __2__ __3__ every __4__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-barrage-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ge',
        default_value = 'Barrage has ended'
    },
    {
        name = 'sil-ihlp-msg-player-dump-inventory',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gf',
        default_value = '__1__ has come down with a serious case of diarrhea and seems to displace their inventory over __2__ tiles (__3__ seconds)'
    },
    {
        name = 'sil-ihlp-msg-player-dump-inventory-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gf',
        default_value = '__1__ is feeling better again. They lost __2__ items'
    },
    {
        name = 'sil-ihlp-msg-player-cancel-handcraft',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gg',
        default_value = '__1__ apparently does not need any of the __2__ items they were crafting'
    },
    {
        name = 'sil-ihlp-msg-player-start-handcraft',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gh',
        default_value = '__1__ decided they urgently need __2__ __3__'
    },
    {
        name = 'sil-ihlp-teleport-delay',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 20,
        maximum_value = 180,
        minimum_value = 1,
        order = '9f'
    },
    {
        name = 'sil-ihlp-teleport-attempts',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 10,
        maximum_value = 20,
        minimum_value = 1,
        order = '9j'
    },
    {
        name = 'sil-ihlp-max-walk-speed-modifier',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 200,
        minimum_value = 100,
        maximum_value = 1500,
        order = '8k'
    },
    {
        name = 'sil-ihlp-max-craft-speed-modifier',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 200,
        minimum_value = 100,
        maximum_value = 1500,
        order = '8l'
    }
})
