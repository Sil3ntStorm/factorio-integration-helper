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
        name = 'sil-ihlp-msg-research-arti-speed-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bhb',
        default_value = 'Artillery overclock has ended, shooting speed is back to normal'
    },
    {
        name = 'sil-ihlp-msg-research-arti-range',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bi',
        default_value = 'Artillery is shooting further for __2__ seconds'
    },
    {
        name = 'sil-ihlp-msg-research-arti-range-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bi',
        default_value = 'Artillery range has returned to normal'
    },
    {
        name = 'sil-ihlp-msg-research-lab-speed',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bja',
        default_value = '__1__ research labs are running at __2__% speed for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-research-lab-speed-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bjb',
        default_value = '__1__ research labs have returned to normal research speed'
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
        name = 'sil-ihlp-msg-research-lost',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bi',
        default_value = '__2__ has just lost access to the __1__ technology'
    },
    {
        name = 'sil-ihlp-msg-research-nothing',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'bga',
        default_value = '__1__ no research found'
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
        name = 'sil-ihlp-msg-map-teleport-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'faa',
        default_value = 'Teleporting __1__ in __2__ seconds'
    },
    {
        name = 'sil-ihlp-msg-map-teleport-player',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fab',
        default_value = '__1__ just got teleported __2__ tiles from __3__ to __4__'
    },
    {
        name = 'sil-ihlp-msg-map-teleport-fail',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fac',
        default_value = 'Failed to find a suitable target position for __1__ on __2__. Aborting teleportation'
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
        name = 'sil-ihlp-msg-map-revive-biters-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fcb',
        default_value = '__3__'
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
        name = 'sil-ihlp-msg-map-snap-wires',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fh',
        default_value = '__1__ circuit connections and __2__ power poles within __3__ meters around __4__ have been cut'
    },
    {
        name = 'sil-ihlp-msg-map-snap-wires-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fhb',
        default_value = '__1__'
    },
    {
        name = 'sil-ihlp-msg-map-load-ammo',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fi',
        default_value = 'Loaded __1__ turrets with a total of __2__ __3__ __5__ meters around __4__'
    },
    {
        name = 'sil-ihlp-msg-map-load-ammo-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fia',
        default_value = 'Loading turrets with __1__ in __2__ seconds'
    },
    {
        name = 'sil-ihlp-msg-map-adv-silo',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fjb',
        default_value = '__4__% chance for rocket silos __3__ meters around __2__ to gain __5__ parts in __6__ seconds'
    },
    {
        name = 'sil-ihlp-msg-map-adv-silo-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fjb',
        default_value = 'A total of __1__ rocket parts where added to __2__ rocket silos __3__ meters around __4__'
    },
    {
        name = 'sil-ihlp-msg-map-adv-silo-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fjb',
        default_value = ''
    },
    {
        name = 'sil-ihlp-msg-map-adv-silo-no-result',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'fjc',
        default_value = 'No rocket silo found'
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
        order = 'gab',
        default_value = '__1__ legs are getting weak, they are walking __2__% slower for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-walk-speed-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gac',
        default_value = '__2__'
    },
    {
        name = 'sil-ihlp-msg-player-walk-speed-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gad',
        default_value = ''
    },
    {
        name = 'sil-ihlp-msg-player-craft-speed-inc',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gb',
        default_value = '__1__ biceps have been growing, they are crafting __2__% faster for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-craft-speed-dec',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gbb',
        default_value = '__1__ arms are tired, they are crafting __2__% slower for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-craft-speed-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gbc',
        default_value = '__2__'
    },
    {
        name = 'sil-ihlp-msg-player-craft-speed-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gbd',
        default_value = '__1__ crafting speed has returned to normal'
    },
    {
        name = 'sil-ihlp-msg-player-on-fire',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gc',
        default_value = 'For __3__ seconds, anything within __2__ meters around __1__ will be on fire in __4__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-on-fire-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gcb',
        default_value = '__1__'
    },
    {
        name = 'sil-ihlp-msg-player-barrage-start',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gd',
        default_value = 'Stay away from __1__, in __6__ seconds they seem to attract __2__ __3__ every __4__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-barrage-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ge',
        default_value = 'Barrage on __1__ has ended'
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
        name = 'sil-ihlp-msg-player-cancel-handcraft-start',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gga',
        default_value = '__1__ might lose some of their crafting queue in __2__ seconds and won\'t be able to handcraft for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-cancel-handcraft-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ggb',
        default_value = '__2__'
    },
    {
        name = 'sil-ihlp-msg-player-cancel-handcraft',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ggc',
        default_value = '__1__ apparently does not need any of the __2__ items they were crafting'
    },
    {
        name = 'sil-ihlp-msg-player-start-handcraft-nothing',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ghb',
        default_value = '__1__ is laking the ingredients to craft anything'
    },
    {
        name = 'sil-ihlp-msg-player-start-handcraft-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ghb',
        default_value = '__2__'
    },
    {
        name = 'sil-ihlp-msg-player-start-handcraft',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'ghc',
        default_value = '__1__ decided they urgently need __2__ __3__'
    },
    {
        name = 'sil-ihlp-msg-player-naked-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gi',
        default_value = '__1__ is losing all protection in __2__ seconds (for __3__ seconds)'
    },
    {
        name = 'sil-ihlp-msg-player-naked',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gj',
        default_value = '__1__ will have to live without their most valued treasures for __2__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-naked-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gk',
        default_value = '__1__ found their lost treasures'
    },
    {
        name = 'sil-ihlp-msg-player-naked-end-ground',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gk',
        default_value = '__1__ treasures have been spotted within __2__ meters around their location'
    },
    {
        name = 'sil-ihlp-msg-player-vacuum',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gla',
        default_value = '__1__ starts sucking the air in really hard. All items on the ground within __2__ meters are being sucked in (__3__ seconds)'
    },
    {
        name = 'sil-ihlp-msg-player-vacuum-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'glb',
        default_value = '__1__ ran out of breath and cannot suck in far away items anymore'
    },
    {
        name = 'sil-ihlp-msg-player-vacuum-fail',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'glc',
        default_value = '__1__ tried to suck the air in really hard but failed miserably'
    },
    {
        name = 'sil-ihlp-msg-player-vacuum-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gld',
        default_value = '__3__'
    },
    {
        name = 'sil-ihlp-msg-player-shields-dec',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gmaa',
        default_value = '__1__ encountered atmospheric disturbances which reduced their shields to __2__% of capacity'
    },
    {
        name = 'sil-ihlp-msg-player-shields-inc',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gmab',
        default_value = '__1__ encountered a powerful force, boosting their shield charge, now sitting at __2__%'
    },
    {
        name = 'sil-ihlp-msg-player-shields-dec-dur',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gmba',
        default_value = '__1__ encountered atmospheric disturbances reducing their shields to __2__% of capacity for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-shields-inc-dur',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gmbb',
        default_value = '__1__ encountered a powerful force, boosting their shield charge, now sitting at __2__% for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-shields-no-shield',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gmc',
        default_value = '__1__ does not have shields'
    },
    {
        name = 'sil-ihlp-msg-player-shields-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gmd',
        default_value = '__1__ will gain __2__% shields in __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-shields-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gme',
        default_value = '__1__\'s shields have recovered and are behaving normally again'
    },
    {
        name = 'sil-ihlp-msg-player-batt-inc',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gnaa',
        default_value = '__1__ found some extra batteries, increasing their armor charge to __2__% of capacity'
    },
    {
        name = 'sil-ihlp-msg-player-batt-dec',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gnab',
        default_value = 'A short circuit in __1__\'s armor caused their battery charge to decrease to __2__% of capacity'
    },
    {
        name = 'sil-ihlp-msg-player-batt-inc-dur',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gnba',
        default_value = '__1__ found some extra batteries, increasing their armor charge to __2__% of capacity for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-batt-dec-dur',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gnbb',
        default_value = 'A short circuit in __1__\'s armor caused their battery charge to decrease to __2__% of capacity for __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-batt-no-batt',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gnc',
        default_value = '__1__ does not have any batteries'
    },
    {
        name = 'sil-ihlp-msg-player-batt-countdown',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gnd',
        default_value = '__1__ will gain __2__% battery charge in __3__ seconds'
    },
    {
        name = 'sil-ihlp-msg-player-batt-end',
        type = 'string-setting',
        setting_type = 'runtime-global',
        auto_trim = true,
        allow_blank = true,
        order = 'gne',
        default_value = '__1__\'s batteries have recovered and are behaving normally again'
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
    },
    {
        name = 'sil-ihlp-explosive-spawn-range',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 5,
        minimum_value = 1,
        maximum_value = 25,
        order = '9k1'
    },
    {
        name = 'sil-ihlp-explosive-spawn-max-range',
        type = 'int-setting',
        setting_type = 'runtime-global',
        default_value = 75,
        minimum_value = 10,
        maximum_value = 150,
        order = '9k2'
    },
})
