--!strict
local GuildProgressionConfig = {}

GuildProgressionConfig.CLEAR_REWARDS = table.freeze({
    [1] = table.freeze({XP = 0, Gold = 0}),
    [2] = table.freeze({XP = 100, Gold = 40}),
    [3] = table.freeze({XP = 175, Gold = 70}),
    [4] = table.freeze({XP = 250, Gold = 100}),
})

GuildProgressionConfig.UPGRADES = table.freeze({
    [1] = table.freeze({XP = 1000, Gold = 2500}),
    [2] = table.freeze({XP = 3000, Gold = 7500}),
    [3] = table.freeze({XP = 7500, Gold = 20000}),
    [4] = table.freeze({XP = 15000, Gold = 50000}),
})

function GuildProgressionConfig.clear_reward(count: number): any
    return GuildProgressionConfig.CLEAR_REWARDS[math.clamp(math.floor(count), 1, 4)]
end

function GuildProgressionConfig.upgrade_requirement(level: number): any?
    return GuildProgressionConfig.UPGRADES[math.floor(level)]
end

return table.freeze(GuildProgressionConfig)
