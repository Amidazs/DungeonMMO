--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local ProfileSchema = require(
    shared:WaitForChild("ProfileSchema")
)

local ProgressionConfig = require(
    shared:WaitForChild("ProgressionConfig")
)

local AttributeConfig = require(
    shared:WaitForChild("AttributeConfig")
)

local SkillProgressionDefinitions = require(
    shared:WaitForChild("SkillProgressionDefinitions")
)

local SkillProgressionConfig = require(
    shared:WaitForChild("SkillProgressionConfig")
)

local RaceDefinitions = require(
    shared:WaitForChild("RaceDefinitions")
)
local C4FirstTransferBranches = require(
    shared:WaitForChild("C4FirstTransferBranches")
)
local C4OriginalFirstTransferQuestStages = require(
    shared:WaitForChild("C4OriginalFirstTransferQuestStages")
)

local ClassProgressionDefinitions = require(
    shared:WaitForChild("ClassProgressionDefinitions")
)

local SecondaryClassDefinitions = require(
    shared:WaitForChild("SecondaryClassDefinitions")
)

local CharacterIdentityRules = require(
    shared:WaitForChild("CharacterIdentityRules")
)

local EquipmentSlots = require(
    shared:WaitForChild("EquipmentSlots")
)

local ItemDefinitions = require(
    shared:WaitForChild("ItemDefinitions")
)

local ProfessionDefinitions = require(
    shared:WaitForChild("ProfessionDefinitions")
)
local ProfessionSelectionRules = require(
    shared:WaitForChild("ProfessionSelectionRules")
)

local BankConfig = require(
    shared:WaitForChild("BankConfig")
)

local ItemTransferRules = require(
    shared:WaitForChild("ItemTransferRules")
)

local DungeonDifficultyDefinitions = require(
    shared:WaitForChild("DungeonDifficultyDefinitions")
)

local ProfileMigration = {}

local IDENTITY_VERSION = 1
local FIGHTER_ID = "Fighter"

local LEGACY_STARTER_SKILLS = table.freeze({
    ShieldBash = table.freeze({
        Known = true,
        StarterGranted = true,
        PurchasedRank = 1,
        Proficiency = 0,
    }),
    Mend = table.freeze({
        Known = true,
        StarterGranted = true,
        PurchasedRank = 1,
        Proficiency = 0,
    }),
})

local LEGACY_STARTER_LOADOUT = table.freeze({
    [1] = "ShieldBash",
    [2] = "Mend",
})

local function finite(value: any): boolean
    return (
        type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
    )
end

local function nonnegative_integer(
    value: any,
    fallback: number
): number
    if not finite(value) or value < 0 then
        return fallback
    end

    return math.floor(value)
end

local function positive_integer(
    value: any,
    fallback: number
): number
    if not finite(value) or value < 1 then
        return fallback
    end

    return math.max(1, math.floor(value))
end

local function deep_fill(
    target: any,
    defaults: any
)
    for key, default in pairs(defaults) do
        local current = target[key]

        if current == nil then
            target[key] = ProfileSchema.deep_clone(default)
        elseif type(default) == "table" then
            if type(current) ~= "table" then
                target[key] = ProfileSchema.deep_clone(default)
            else
                deep_fill(current, default)
            end
        end
    end
end

local function known_race_id(value: any): string?
    if type(value) ~= "string" then
        return nil
    end

    if not RaceDefinitions.get(value) then
        return nil
    end

    return value
end

local function identity_copy(value: any): any
    if type(value) == "table" then
        return ProfileSchema.deep_clone(value)
    end

    return {}
end

local function set_identity(
    identity: any,
    race_id: string?,
    base_class_id: string?,
    class_id: string?,
    stage: string
): any
    identity.Version = IDENTITY_VERSION
    identity.RaceId = race_id
    identity.BaseClassId = base_class_id
    identity.ClassId = class_id
    identity.CreationStage = stage

    return identity
end

local function fresh_identity(value: any): any
    return set_identity(
        identity_copy(value),
        nil,
        nil,
        nil,
        CharacterIdentityRules.Stages.RaceSelection
    )
end

local function legacy_identity(value: any): any
    return set_identity(
        identity_copy(value),
        nil,
        FIGHTER_ID,
        FIGHTER_ID,
        CharacterIdentityRules.Stages.LegacyRaceSelection
    )
end

local function sanitize_v4_identity(value: any): any
    local identity = identity_copy(value)

    if identity.Version ~= IDENTITY_VERSION then
        return fresh_identity(identity)
    end

    local stage = identity.CreationStage

    if stage == CharacterIdentityRules.Stages.RaceSelection then
        return fresh_identity(identity)
    end

    if stage == CharacterIdentityRules.Stages.ClassSelection then
        local race_id = known_race_id(identity.RaceId)

        if not race_id then
            return fresh_identity(identity)
        end

        return set_identity(
            identity,
            race_id,
            nil,
            nil,
            CharacterIdentityRules.Stages.ClassSelection
        )
    end

    if (
        stage
        == CharacterIdentityRules.Stages.LegacyRaceSelection
    ) then
        return legacy_identity(identity)
    end

    if stage == CharacterIdentityRules.Stages.Complete then
        local race_id = known_race_id(identity.RaceId)
        local base_class_id = identity.BaseClassId
        local class_id = identity.ClassId
        local base_definition = if type(base_class_id) == "string"
            then ClassProgressionDefinitions.get(base_class_id)
            else nil
        local race_allowed = false

        if base_definition and type(base_definition.AllowedRaces) == "table" then
            for _, allowed_race in ipairs(base_definition.AllowedRaces) do
                if allowed_race == race_id then
                    race_allowed = true
                    break
                end
            end
        end

        if (
            not race_id
            or not base_definition
            or class_id ~= base_class_id
            or not race_allowed
        ) then
            return fresh_identity(identity)
        end

        return set_identity(
            identity,
            race_id,
            base_class_id,
            class_id,
            CharacterIdentityRules.Stages.Complete
        )
    end

    return fresh_identity(identity)
end

local function attribute_minimum(
    identity: any,
    attribute_name: string,
    legacy_source: boolean
): number
    if legacy_source then
        return AttributeConfig.BASE_VALUE
    end

    local race_id = known_race_id(
        if type(identity) == "table"
            then identity.RaceId
            else nil
    )

    if not race_id then
        return AttributeConfig.BASE_VALUE
    end

    local baseline = RaceDefinitions.get_base_attributes(
        race_id
    )

    if (
        baseline
        and type(baseline[attribute_name]) == "number"
    ) then
        return baseline[attribute_name]
    end

    return AttributeConfig.BASE_VALUE
end

local function sanitize_attribute(
    value: any,
    minimum: number
): number
    if not finite(value) then
        return minimum
    end

    return math.max(minimum, math.floor(value))
end

local function sanitize_skill_state(
    skill_id: string,
    state: any,
    default_state: any
): any
    local cleaned = if type(state) == "table"
        then ProfileSchema.deep_clone(state)
        else ProfileSchema.deep_clone(default_state or {})

    local definition = SkillProgressionDefinitions.get(
        skill_id
    )

    local starter = (
        cleaned.StarterGranted == true
        or (
            default_state ~= nil
            and default_state.StarterGranted == true
        )
    )

    local known = cleaned.Known == true or starter

    local max_rank = if definition
        then definition.MaxRank
        else 99

    local minimum_rank = if starter then 1 else 0

    local rank = nonnegative_integer(
        cleaned.PurchasedRank,
        minimum_rank
    )

    rank = math.clamp(
        rank,
        minimum_rank,
        max_rank
    )

    if not known then
        rank = 0
    end

    local proficiency = nonnegative_integer(
        cleaned.Proficiency,
        0
    )

    if definition then
        proficiency = math.min(
            proficiency,
            SkillProgressionConfig.get_skill_max_threshold(
                definition
            )
        )
    end

    cleaned.Known = known
    cleaned.StarterGranted = starter
    cleaned.PurchasedRank = rank
    cleaned.Proficiency = proficiency

    return cleaned
end

local function capture_original_loadout(raw: any): any?
    if (
        type(raw) == "table"
        and type(raw.Characters) == "table"
        and type(raw.Characters.Slot1) == "table"
        and type(
            raw.Characters.Slot1.Progression
        ) == "table"
        and type(
            raw.Characters.Slot1.Progression.Loadout
        ) == "table"
    ) then
        return ProfileSchema.deep_clone(
            raw.Characters.Slot1.Progression.Loadout
        )
    end

    return nil
end

local function sanitize_loadout(
    loadout: any
): any
    local source = if type(loadout) == "table"
        then loadout
        else {}

    local cleaned = {}
    local seen = {}

    for slot = 1, SkillProgressionConfig.MAX_ACTIVE_SLOTS do
        local skill_id = source[slot]

        if (
            type(skill_id) == "string"
            and not seen[skill_id]
        ) then
            cleaned[slot] = skill_id
            seen[skill_id] = true
        end
    end

    return cleaned
end

local function sanitize_profession_state(value: any): any
    local xp = if type(value) == "table"
        then nonnegative_integer(value.XP, 0)
        else 0

    return {
        Level = ProfessionDefinitions.level_from_xp(xp),
        XP = xp,
    }
end

local function sanitize_bank(value: any): any
    local source_items = if type(value) == "table"
            and type(value.Items) == "table"
        then value.Items
        else {}

    local cleaned = {
        Version = BankConfig.VERSION,
        Items = {},
    }
    local used = 0
    local stack_entries: {[string]: any} = {}

    for _, entry in ipairs(source_items) do
        if type(entry) == "table"
            and type(entry.ItemId) == "string"
        then
            local quantity = nonnegative_integer(
                entry.Quantity,
                0
            )
            local definition = ItemDefinitions.get(
                entry.ItemId
            )
            local bankable = ItemTransferRules.can_bank(
                entry.ItemId
            )

            if definition and bankable and quantity > 0 then
                if definition.Stackable == true then
                    local existing = stack_entries[entry.ItemId]
                    if existing then
                        existing.Quantity += quantity
                    elseif used < BankConfig.CAPACITY then
                        local new_entry = {
                            ItemId = entry.ItemId,
                            Quantity = quantity,
                        }
                        table.insert(cleaned.Items, new_entry)
                        stack_entries[entry.ItemId] = new_entry
                        used += 1
                    end
                else
                    local remaining_slots =
                        BankConfig.CAPACITY - used
                    local accepted = math.min(
                        quantity,
                        math.max(0, remaining_slots)
                    )

                    for _ = 1, accepted do
                        table.insert(cleaned.Items, {
                            ItemId = entry.ItemId,
                            Quantity = 1,
                        })
                    end

                    used += accepted
                end
            end

            if used >= BankConfig.CAPACITY then
                -- Existing stackable rows later in the source may still
                -- merge without consuming a slot, so do not break here.
            end
        end
    end

    return cleaned
end


local function sanitize_bestiary(value: any): any
    local result = {
        Version = 1,
        Entries = {},
    }

    if type(value) ~= "table" or type(value.Entries) ~= "table" then
        return result
    end

    for creature_id, raw_entry in pairs(value.Entries) do
        if type(creature_id) == "string" and type(raw_entry) == "table" then
            local kills = raw_entry.Kills
            if type(kills) ~= "number"
                or kills ~= kills
                or kills < 0
                or kills >= math.huge
                or kills % 1 ~= 0
            then
                kills = 0
            end

            local milestones = {}
            if type(raw_entry.Milestones) == "table" then
                for milestone_id, unlocked in pairs(raw_entry.Milestones) do
                    if type(milestone_id) == "string" and unlocked == true then
                        milestones[milestone_id] = true
                    end
                end
            end

            result.Entries[creature_id] = {
                Kills = kills,
                Milestones = milestones,
            }
        end
    end

    return result
end

local function sanitize_reputation(value: any): any
    local points = 0

    if type(value) == "table"
        and type(value.Factions) == "table"
        and type(value.Factions.Scholars) == "table"
    then
        local candidate = value.Factions.Scholars.Points
        if type(candidate) == "number"
            and candidate == candidate
            and candidate >= 0
            and candidate < math.huge
            and candidate % 1 == 0
        then
            points = candidate
        end
    end

    return {
        Version = 1,
        Factions = {
            Scholars = {
                Points = points,
            },
        },
    }
end
-- Sanitizes versioned dungeon-depth progression without touching legacy
-- DungeonProgress data.
local function sanitize_dungeon_difficulty_progress(value: any): any
    local result = {
        Version = 1,
        Dungeons = {},
    }

    if type(value) ~= "table" or type(value.Dungeons) ~= "table" then
        return result
    end

    for dungeon_id, raw_state in pairs(value.Dungeons) do
        local ordered = DungeonDifficultyDefinitions.ordered(dungeon_id)
        if #ordered > 0 and type(raw_state) == "table" then
            local raw_completed = raw_state.Completed
            local completed = {}
            local highest_order = 0
            local prefix_complete = true

            for _, difficulty in ipairs(ordered) do
                local is_complete = type(raw_completed) == "table"
                    and raw_completed[difficulty.Id] == true
                if prefix_complete and is_complete then
                    completed[difficulty.Id] = true
                    highest_order = difficulty.Order
                else
                    prefix_complete = false
                end
            end

            if highest_order > 0 then
                result.Dungeons[dungeon_id] = {
                    Completed = completed,
                    HighestClearedOrder = highest_order,
                }
            end
        end
    end

    return result
end

local function sanitize_market(value: any): any
    local result = {Version = 1, ActiveListingIds = {}, History = {}, Recovery = {}}
    if type(value) ~= "table" then return result end
    if type(value.ActiveListingIds) == "table" then
        local seen = {}
        for _, listing_id in ipairs(value.ActiveListingIds) do
            if type(listing_id) == "string" and listing_id ~= "" and not seen[listing_id] then
                table.insert(result.ActiveListingIds, listing_id)
                seen[listing_id] = true
            end
        end
    end
    if type(value.History) == "table" then
        for transaction_id, receipt in pairs(value.History) do
            if type(transaction_id) == "string" and transaction_id ~= "" and type(receipt) == "table" then
                result.History[transaction_id] = ProfileSchema.deep_clone(receipt)
            end
        end
    end
    if type(value.Recovery) == "table" then
        for listing_id, receipt in pairs(value.Recovery) do
            if type(listing_id) == "string" and listing_id ~= "" and type(receipt) == "table" then
                result.Recovery[listing_id] = ProfileSchema.deep_clone(receipt)
            end
        end
    end
    return result
end

local function sanitize_race_change(value: any): any
    local result = {Version = 1, ArchivedByRace = {}, History = {}}
    if type(value) ~= "table" then return result end
    if type(value.ArchivedByRace) == "table" then
        for race_id, archive in pairs(value.ArchivedByRace) do
            if RaceDefinitions.get(race_id) and type(archive) == "table" then
                local clean = {Skills = {}, Advancement = {}}
                if type(archive.Skills) == "table" then
                    for skill_id, state in pairs(archive.Skills) do
                        if type(skill_id) == "string" and type(state) == "table" then
                            clean.Skills[skill_id] = sanitize_skill_state(skill_id, state, {})
                        end
                    end
                end
                if type(archive.Advancement) == "table" then
                    clean.Advancement = ProfileSchema.deep_clone(archive.Advancement)
                end
                result.ArchivedByRace[race_id] = clean
            end
        end
    end
    if type(value.History) == "table" then
        for transaction_id, receipt in pairs(value.History) do
            if type(transaction_id) == "string" and transaction_id ~= "" and type(receipt) == "table" then
                result.History[transaction_id] = ProfileSchema.deep_clone(receipt)
            end
        end
    end
    return result
end

local function sanitize_class_advancement(
    value: any, identity: any
): any
    local current_race_id = identity and identity.RaceId
    local result = {Version = 1, CompletedByRace = {}}
    if type(value) ~= "table" then return result end
    if type(value.CompletedByRace) == "table" then
        for race_id, completed in pairs(value.CompletedByRace) do
            if RaceDefinitions.get(race_id) and type(completed) == "table" then
                local clean = {}
                for class_id, done in pairs(completed) do
                    local definition = type(class_id) == "string" and SecondaryClassDefinitions.get(class_id) or nil
                    if definition and definition.RaceId == race_id and done == true then
                        clean[class_id] = true
                    end
                end
                result.CompletedByRace[race_id] = clean
            end
        end
    end
    local active = value.ActiveClassId
    if type(current_race_id) == "string" and type(active) == "string" then
        local definition = SecondaryClassDefinitions.get(active)
        local completed = result.CompletedByRace[current_race_id]
        if definition and definition.RaceId == current_race_id and completed and completed[active] == true then
            result.ActiveClassId = active
        end
    end
    -- A first-transfer choice is not an awarded class, so its original
    -- race/family must still match the current unadvanced character.
    local choice = value.OriginalFirstTransferChoiceId
    if type(choice) == "string" and type(identity) == "table"
        and identity.CreationStage == "Complete"
        and identity.ClassId == identity.BaseClassId
        and C4FirstTransferBranches.find(
            identity.RaceId, identity.BaseClassId, choice
        ) ~= nil
    then
        result.OriginalFirstTransferChoiceId = choice
        local raw_quest = value.OriginalFirstTransferQuest
        local quest = C4OriginalFirstTransferQuestStages.get(choice)
        if quest and type(raw_quest) == "table"
            and raw_quest.QuestId == quest.Id
            and raw_quest.BranchId == choice
            and type(raw_quest.Step) == "number"
            and raw_quest.Step % 1 == 0
            and raw_quest.Step >= 1
            and raw_quest.Step <= #quest.Steps + 1
            and type(raw_quest.Count) == "number"
            and raw_quest.Count % 1 == 0
            and raw_quest.Count >= 0
            and type(raw_quest.AppliedEvents) == "table"
        then
            local step = quest.Steps[raw_quest.Step]
            local progress = if step
                then math.min(raw_quest.Count, step.Required - 1)
                else 0
            local applied = {}
            local kept = 0
            for event_id, claimed in pairs(raw_quest.AppliedEvents) do
                if kept >= 64 then break end
                if type(event_id) == "string"
                    and #event_id > 0 and #event_id <= 120
                    and claimed == true
                then
                    applied[event_id] = true
                    kept += 1
                end
            end
            result.OriginalFirstTransferQuest = {
                QuestId = quest.Id, BranchId = choice,
                Step = raw_quest.Step, Count = progress,
                Ready = step == nil, AppliedEvents = applied,
                Proofs = (function()
                    local proofs = {}
                    for _, proof_id in ipairs(quest.RequiredProofIds) do
                        if type(raw_quest.Proofs) == "table"
                            and raw_quest.Proofs[proof_id] == true
                        then
                            proofs[proof_id] = true
                        end
                    end
                    return proofs
                end)(),
            }
        end
    end
    return result
end

function ProfileMigration.migrate(raw: any): any
    local raw_is_table = type(raw) == "table"

    local raw_version = if raw_is_table
        then raw.SchemaVersion
        else nil

    if (
        type(raw_version) == "number"
        and raw_version > ProfileSchema.VERSION
    ) then
        error(
            string.format(
                "Profile schema %s is newer than " ..
                    "supported schema %d.",
                tostring(raw_version),
                ProfileSchema.VERSION
            )
        )
    end

    -- Only a nil storage value is genuinely new.
    -- An existing pre-v4 table represents a legacy
    -- Phase 2B-or-earlier character.
    local new_source = raw == nil

    -- Schema v4 is the accepted Phase 2C.A identity schema.
    -- Only pre-v4 data uses the one-time legacy race-selection path.
    local legacy_source = (
        raw_is_table
        and (
            type(raw_version) ~= "number"
            or raw_version < 4
        )
    )

    local original_loadout = capture_original_loadout(raw)

    local migrated = if raw_is_table
        then ProfileSchema.deep_clone(raw)
        else {}

    local defaults = ProfileSchema.create_default(0)

    deep_fill(migrated, defaults)

    migrated.SchemaVersion = ProfileSchema.VERSION

    if type(migrated.Account) ~= "table" then
        migrated.Account = ProfileSchema.deep_clone(
            defaults.Account
        )
    end

    migrated.Account.SelectedCharacterSlot = 1
    migrated.Account.Bank = sanitize_bank(
        migrated.Account.Bank
    )

    if type(migrated.Characters) ~= "table" then
        migrated.Characters = ProfileSchema.deep_clone(
            defaults.Characters
        )
    end

    if type(migrated.Characters.Slot1) ~= "table" then
        migrated.Characters.Slot1 = ProfileSchema.deep_clone(
            defaults.Characters.Slot1
        )
    end

    local slot1 = migrated.Characters.Slot1

    slot1.Bestiary = sanitize_bestiary(slot1.Bestiary)
    slot1.Reputation = sanitize_reputation(slot1.Reputation)
    slot1.Market = sanitize_market(slot1.Market)
    slot1.RaceChange = sanitize_race_change(slot1.RaceChange)

    if legacy_source then
        slot1.Identity = legacy_identity(slot1.Identity)
    elseif new_source then
        slot1.Identity = fresh_identity(slot1.Identity)
    else
        slot1.Identity = sanitize_v4_identity(
            slot1.Identity
        )
    end

    slot1.Level = positive_integer(slot1.Level, 1)

    slot1.XP = if slot1.Level >= ProgressionConfig.MAX_LEVEL
        then 0
        else nonnegative_integer(slot1.XP, 0)

    slot1.Gold = nonnegative_integer(slot1.Gold, 0)

    slot1.ClassAdvancement = sanitize_class_advancement(
        slot1.ClassAdvancement, slot1.Identity
    )

    if type(slot1.Inventory) ~= "table" then
        slot1.Inventory = {}
    end

    local equipment_source = if type(slot1.Equipment) == "table"
        then slot1.Equipment
        else {}

    local sanitized_equipment = {}

    for _, slot in ipairs(EquipmentSlots.ORDER) do
        local item_id = equipment_source[slot]

        if type(item_id) == "string" then
            local definition = ItemDefinitions.get(item_id)

            if (
                definition
                and definition.Kind == "Equipment"
                and definition.Slot == slot
            ) then
                sanitized_equipment[slot] = item_id
            end
        end
    end

    slot1.Equipment = sanitized_equipment

    if type(slot1.DungeonProgress) ~= "table" then
        slot1.DungeonProgress = {}
    end

    slot1.DungeonDifficultyProgress =
        sanitize_dungeon_difficulty_progress(
            slot1.DungeonDifficultyProgress
        )

    if type(slot1.RewardHistory) ~= "table" then
        slot1.RewardHistory = {
            Completion = {},
            Monster = {},
        }
    end

    if type(slot1.RewardHistory.Completion) ~= "table" then
        slot1.RewardHistory.Completion = {}
    end

    if type(slot1.RewardHistory.Monster) ~= "table" then
        slot1.RewardHistory.Monster = {}
    end

    if type(slot1.Progression) ~= "table" then
        -- Recipe knowledge v9: preserve only explicit learned-membership
    -- booleans and create an empty current structure for older profiles.
    local raw_crafting_knowledge = slot1.CraftingKnowledge
    local sanitized_learned_recipes = {}

    if type(raw_crafting_knowledge) == "table"
        and type(raw_crafting_knowledge.LearnedRecipes) == "table"
    then
        for recipe_id, learned in pairs(
            raw_crafting_knowledge.LearnedRecipes
        ) do
            if type(recipe_id) == "string"
                and recipe_id ~= ""
                and learned == true
            then
                sanitized_learned_recipes[recipe_id] = true
            end
        end
    end

    slot1.CraftingKnowledge = {
        Version = 1,
        LearnedRecipes = sanitized_learned_recipes,
    }

    slot1.Progression = ProfileSchema.deep_clone(
            defaults.Characters.Slot1.Progression
        )
    end

    deep_fill(
        slot1.Progression,
        defaults.Characters.Slot1.Progression
    )

    local progression = slot1.Progression

    if type(progression.Attributes) ~= "table" then
        progression.Attributes = {}
    end

    for _, attribute_name in ipairs(
        AttributeConfig.get_names()
    ) do
        local minimum = attribute_minimum(
            slot1.Identity,
            attribute_name,
            legacy_source
        )

        progression.Attributes[attribute_name] =
            sanitize_attribute(
                progression.Attributes[attribute_name],
                minimum
            )
    end

    local entitlement = ProgressionConfig.level_entitlement(
        slot1.Level
    )

    progression.AttributePointEntitlement = math.max(
        nonnegative_integer(
            progression.AttributePointEntitlement,
            0
        ),
        entitlement
    )

    progression.SkillPointEntitlement = math.max(
        nonnegative_integer(
            progression.SkillPointEntitlement,
            0
        ),
        entitlement
    )

    if type(progression.Skills) ~= "table" then
        progression.Skills = {}
    end

    local starter_defaults = if legacy_source
        then LEGACY_STARTER_SKILLS
        else {}

    if legacy_source then
        for skill_id, default_state in pairs(
            LEGACY_STARTER_SKILLS
        ) do
            progression.Skills[skill_id] =
                sanitize_skill_state(
                    skill_id,
                    progression.Skills[skill_id],
                    default_state
                )
        end
    end

    for skill_id, state in pairs(progression.Skills) do
        progression.Skills[skill_id] =
            sanitize_skill_state(
                skill_id,
                state,
                starter_defaults[skill_id]
            )
    end

    if original_loadout ~= nil then
        progression.Loadout = original_loadout
    elseif legacy_source then
        progression.Loadout = ProfileSchema.deep_clone(
            LEGACY_STARTER_LOADOUT
        )
    elseif type(progression.Loadout) ~= "table" then
        progression.Loadout = {}
    end

    progression.Loadout = sanitize_loadout(
        progression.Loadout
    )

    if type(progression.RespecCounters) ~= "table" then
        progression.RespecCounters = {}
    end

    progression.RespecCounters.Attributes =
        nonnegative_integer(
            progression.RespecCounters.Attributes,
            0
        )

    progression.RespecCounters.Skills =
        nonnegative_integer(
            progression.RespecCounters.Skills,
            0
        )

    if type(progression.OneTimeRewards) ~= "table" then
        progression.OneTimeRewards = {}
    end

    progression.OneTimeRewards.ArcSlashFirstClear =
        progression.OneTimeRewards.ArcSlashFirstClear == true

    if (
        type(progression.ArchivedSkillKnowledge)
        ~= "table"
    ) then
        progression.ArchivedSkillKnowledge = {}
    end

    local profession_source = if type(slot1.Professions) == "table"
        then slot1.Professions
        else {}
    local sanitized_professions = {}

    for _, profession_id in ipairs(ProfessionDefinitions.order()) do
        sanitized_professions[profession_id] = sanitize_profession_state(
            profession_source[profession_id]
        )
    end

    slot1.Professions = sanitized_professions
    -- Preserve every old profession's XP and crafted inventory, but
    -- never silently grant both crafting careers to an old character.
    -- A legacy character must explicitly choose its two active slots.
    slot1.ProfessionSlots = ProfessionSelectionRules.normalize(
        slot1.ProfessionSlots
    )

    return migrated
end

return table.freeze(ProfileMigration)
