--!strict
-- Verified C4 skill-RANK entries, NOT unique buttons or ability names.
-- A level may offer several upgrades of the same skill.
-- Other brackets remain unmapped until verified from C4 source pages.
local C4SkillVolumeTargets = {}

local TARGETS = table.freeze({
    Human = table.freeze({
        Fighter = table.freeze({
            SourceClass = "Human Fighter",
            SourceUrl = "https://l2hub.info/c4/classes/fighter",
            Levels = table.freeze({
                [1] = 2, [5] = 13, [10] = 12, [15] = 12,
            }),
        }),
        Mage = table.freeze({
            SourceClass = "Human Mystic",
            SourceUrl = "https://l2hub.info/c4/classes/mage",
            Levels = table.freeze({
                [1] = 7, [5] = 1, [7] = 15, [14] = 21,
            }),
        }),
    }),
    Elf = table.freeze({
        Fighter = table.freeze({
            SourceClass = "Elven Fighter",
            SourceUrl = "https://l2hub.info/c4/classes/elven_fighter",
            Levels = table.freeze({
                [1] = 2, [5] = 13, [10] = 13, [15] = 12,
            }),
        }),
        Mage = table.freeze({
            SourceClass = "Elven Mystic",
            SourceUrl = "https://l2hub.info/c4/classes/elven_mage",
            Levels = table.freeze({
                [1] = 7, [5] = 1, [7] = 14, [14] = 20,
            }),
        }),
    }),
})

-- Returns verified C4 base-class targets, without guessing missing levels.
--
-- Args:
--   race_id (string): Human or Elf.
--   base_class_id (string): Fighter or Mage.
-- Returns:
--   any?: Source class, URL and per-level rank-entry count or nil.
function C4SkillVolumeTargets.get(
    race_id: string,
    base_class_id: string
): any?
    local race = TARGETS[race_id]
    return if race then race[base_class_id] else nil
end

-- Returns every verified C4 reference used by the parity audit.
--
-- Args:
--   None.
-- Returns:
--   any: Frozen race/class target map.
function C4SkillVolumeTargets.all(): any
    return TARGETS
end

return table.freeze(C4SkillVolumeTargets)
