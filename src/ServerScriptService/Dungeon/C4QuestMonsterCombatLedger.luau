--!strict
-- Server-owned source-quest kill ledger for instanced challenge monsters.
-- Not attached to a live encounter until a quest room registers its models.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local Source = require(
    RS.Core.Shared.C4OriginalFirstTransferQuestStages
)
local Careers = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)

local Ledger = {}
Ledger.__index = Ledger

local FRAGMENT_COUNT = 4

--[[
Creates a session-scoped source-monster combat ledger.

Args:
    options (any): Loaded profiles, session ID and real member checker.

Returns:
    any: Isolated server-owned receipt authority, initially unbound.
]]
function Ledger.new(options: any): any
    assert(type(options) == "table" and options.profiles)
    assert(type(options.session_id) == "string"
        and options.session_id ~= "")
    assert(type(options.is_member_active) == "function")
    return setmetatable({
        _profiles = options.profiles,
        _session_id = options.session_id,
        _is_member_active = options.is_member_active,
        _enemies = {},
        _pending = {},
        _quest_service = nil,
        _scout_actor = nil,
    }, Ledger)
end

--[[
Attaches the world-verified quest service after both services exist.

Args:
    service (any): Real server original advancement quest service.

Returns:
    nil: Links the service without exposing a client request.
]]
function Ledger:attach_quest_service(service: any)
    assert(service and type(service.record_world_event) == "function")
    self._quest_service = service
end

--[[
Registers the server-only physical rescue actor with this quest world binder.

Args:
    actor (any): Authenticated live Dungeon scout prompt authority.

Returns:
    nil: The quest service can verify either real combat or NPC interaction.
]]
function Ledger:attach_scout_actor(actor: any)
    assert(actor and type(actor.verify) == "function"
        and type(actor.available) == "function")
    self._scout_actor = actor
end

--[[
Registers one genuine, existing quest monster life inside its encounter.

Args:
    enemy (Model): Server-spawned model with real living Humanoid.
    branch_id (string): Original source-quest class branch.
    encounter_id (string): Current authoritative dungeon encounter.
    step_index (number?): Exact enabled stage three or six; defaults to three.

Returns:
    boolean: Whether this exact model life can produce quest evidence.
]]
function Ledger:register_enemy(
    enemy: Model, branch_id: string, encounter_id: string,
    step_index: number?
): boolean
    if typeof(enemy) ~= "Instance" or not enemy:IsA("Model")
    then
        return false
    end
    local quest = Source.get(branch_id)
    local index = step_index or 3
    local step = quest and quest.Steps[index]
    if (index ~= 3 and index ~= 5 and index ~= 6)
        or not step or step.Kind ~= "QuestMonsterDefeat"
    then
        return false
    end
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    local enemy_id = enemy:GetAttribute("DungeonEnemyId")
    if not enemy:IsDescendantOf(workspace)
        or not humanoid or humanoid.Health <= 0
        or type(encounter_id) ~= "string" or encounter_id == ""
        or enemy:GetAttribute("DungeonEncounterId") ~= encounter_id
        or enemy:GetAttribute("SourceQuestMonsterId") ~= step.TargetId
        or type(enemy_id) ~= "string" or enemy_id == ""
        or self._enemies[enemy] ~= nil
    then
        return false
    end
    self._enemies[enemy] = {
        BranchId = branch_id,
        Step = index,
        TargetId = step.TargetId,
        EncounterId = encounter_id,
        ReceiptId = HttpService:GenerateGUID(false),
        Hits = {},
        Claimed = false,
    }
    return true
end

--[[
Checks immutable original quest identity again at damage and reward time.

A copied quest table alone must never authorize personal enemy credit.
Checking at reward time also denies stale damage recorded before the
owner changed class, level, selection or quest stage.

Args:
    character (any): Current authoritative selected owner character.
    branch_id (string): Original branch of the registered enemy life.
    step_index (number): Exact server-registered combat quest stage.

Returns:
    boolean: True only for the eligible unadvanced original owner.
]]
function Ledger.is_owner_eligible(
    character: any, branch_id: string, step_index: number
): boolean
    local career = Careers.for_branch(branch_id)
    local quest = Source.get(branch_id)
    local identity = type(character) == "table"
        and character.Identity
    local advancement = type(character) == "table"
        and character.ClassAdvancement
    local state = advancement and advancement.OriginalFirstTransferQuest
    return career ~= nil and quest ~= nil
        and type(identity) == "table"
        and identity.RaceId == career.RaceId
        and identity.BaseClassId == career.BaseClassId
        and identity.ClassId == "Fighter"
        and type(advancement) == "table"
        and advancement.OriginalFirstTransferChoiceId == branch_id
        and type(state) == "table"
        and state.BranchId == branch_id
        and state.Step == step_index
        and state.Ready ~= true
        and (tonumber(character.Level) or 0) >= quest.StartLevel
        and quest.Steps[step_index] ~= nil
        and quest.Steps[step_index].Kind == "QuestMonsterDefeat"
end

--[[
Checks that an actual connected dungeon player is eligible to damage this
monster, and that their selected quest matches this exact monster stage.

Args:
    context (any): Server-created DamageService hit context.
    record (any): Previously registered unique enemy life.

Returns:
    (number?, any?): Real eligible owner UserId and character, or nil.
]]
local function eligible_owner(
    self: any, context: any, record: any
): (number?, any?)
    local player = context.attacker
    if typeof(player) ~= "Instance" or not player:IsA("Player")
        or player.Parent ~= Players
        or player.Character ~= context.attacker_character
        or not self._is_member_active(
            player.UserId, context.target, record.EncounterId
        )
    then
        return nil, nil
    end
    local humanoid = player.Character
        and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil, nil
    end
    local character = self._profiles:get_character(player.UserId)
    if not Ledger.is_owner_eligible(
        character, record.BranchId, record.Step
    ) then
        return nil, nil
    end
    return player.UserId, character
end

--[[
Checks the Rogue's personal trial weapon at the actual damage instant.

Args:
    character (any): Server-loaded owner character.
    branch_id (string): Source quest branch.

Returns:
    boolean: True when the hit meets branch-specific equipment rules.
]]
local function valid_trial_hit(character: any, branch_id: string): boolean
    if branch_id ~= "HumanRogue" then return true end
    local equipment = character.Equipment
    local weapon = equipment and equipment.Weapon
    return weapon == "neti_trial_dagger"
        or weapon == "neti_trial_bow"
end

--[[
Chooses precisely one still-unearned report fragment for a Scout owner.

Args:
    state (any): Owner's current authoritative original quest record.

Returns:
    {[string]: boolean}?: Exactly one proof or nil when already complete.
]]
local function next_proof(state: any): {[string]: boolean}?
    local proofs = state.Proofs or {}
    for index = 1, FRAGMENT_COUNT do
        local proof_id = "PriasLetter" .. tostring(index)
        if proofs[proof_id] ~= true then
            return {[proof_id] = true}
        end
    end
    return nil
end

--[[
Creates server-only proof from a registered dead monster and its owner.

Args:
    self (any): Current session's world verifier.
    user_id (number): Actual contributor who earned the monster kill.
    record (any): Validated unique physical monster life.

Returns:
    any?: A personal quest event, or nil if this owner has moved on.
]]
local function event_for_owner(
    self: any, user_id: number, record: any
): any?
    local character = self._profiles:get_character(user_id)
    if not Ledger.is_owner_eligible(
        character, record.BranchId, record.Step
    ) then
        return nil
    end
    local state = character.ClassAdvancement.OriginalFirstTransferQuest
    local proof_ids = if record.TargetId == "GloamBulwark"
        then {GloamBulwarkSeal = true}
        elseif record.TargetId == "ThornboundColossus"
        then {VerdantGuardianSeal = true}
        elseif record.TargetId == "Ridgebreaker"
        then {RidgebreakerSigil = true}
        elseif record.TargetId == "BrackenWarden"
        then {RustedKey = true}
        elseif record.TargetId == "CinderBrigand"
        then {
            StolenJewelry = true, StolenTomes = true,
            StolenRing = true, StolenNecklace = true,
        }
        elseif record.BranchId == "HumanRogue"
        then {SpartoiBone = true}
        elseif record.BranchId == "HumanWarrior"
        then {IronrootToken = true}
        elseif record.BranchId == "HumanKnight"
        then {StonewatchBadge = true}
        elseif record.BranchId == "ElvenKnight"
        then {VerdantPatrolReport = true}
        else next_proof(state)
    if not proof_ids then return nil end
    return {
        EventId = "QuestKill:" .. record.ReceiptId
            .. ":" .. tostring(user_id),
        MonsterReceiptId = record.ReceiptId,
        ActorUserId = user_id,
        Kind = "QuestMonsterDefeat",
        TargetId = record.TargetId,
        VerifiedProofIds = proof_ids,
        TrialWeaponVerified = record.Hits[user_id] == true,
    }
end

--[[
Commits one bound source drop for each eligible authentic contributor.

Args:
    self (any): Current session's world verifier.
    enemy (Model): One already lethal registered monster.
    record (any): Its pre-lethal server contribution ledger.

Returns:
    nil: Emits personal world receipts once, never group-shared loot.
]]
local function grant_earned_quest_drops(
    self: any, enemy: Model, record: any
)
    record.Claimed = true
    for user_id in pairs(record.Hits) do
        if self._is_member_active(
            user_id, enemy, record.EncounterId
        ) then
            local event = event_for_owner(self, user_id, record)
            if event then
                self._pending[user_id] = {
                    Event = event,
                    BranchId = record.BranchId,
                    Step = record.Step,
                    MonsterReceiptId = record.ReceiptId,
                }
                local outcome = self._quest_service:record_world_event(
                    user_id, event
                )
                self._pending[user_id] = nil
                if outcome.ok then
                    local saved = self._profiles:save(
                        user_id, "SourceQuestMonsterDrop"
                    )
                    if not saved then
                        warn("[C4 Quest] Owner profile could not save drop.")
                    end
                else
                    warn("[C4 Quest] Monster proof rejected: "
                        .. tostring(outcome.reason))
                end
            end
        end
    end
    self._enemies[enemy] = nil
end

--[[
Observes only real server-applied DamageService hits, never client reports.
The lethal callback follows TakeDamage and identifies the actual dead life.

Args:
    context (any): Real trusted combat-service damage context.
    damage (number): Actual health damage after defence and absorption.
    lethal (boolean): Server-verified target humanoid reached zero HP.

Returns:
    boolean: Whether this hit was a qualified quest contribution.
]]
function Ledger:record_damage(
    context: any, damage: number, lethal: boolean
): boolean
    if type(context) ~= "table"
        or typeof(context.target) ~= "Instance"
        or type(damage) ~= "number" or damage <= 0
    then
        return false
    end
    local record = self._enemies[context.target]
    if not record or record.Claimed
        or not self._quest_service then return false end
    local user_id, character = eligible_owner(self, context, record)
    local valid = user_id ~= nil
        and valid_trial_hit(character, record.BranchId)
    if valid then record.Hits[user_id] = true end
    if lethal == true then
        local humanoid = context.target:FindFirstChildOfClass(
            "Humanoid"
        )
        if humanoid and humanoid.Health <= 0 then
            grant_earned_quest_drops(self, context.target, record)
        end
    end
    return valid
end

--[[
Exposes only the exact registered physical monster stage to the quest service.

Args:
    quest (any): Actual selected source quest.
    step_index (number?): Requested stage number.

Returns:
    boolean: Whether an authentic enemy for this exact stage is registered.
]]
function Ledger:available(quest: any, step_index: number?): boolean
    if not quest or type(step_index) ~= "number" then return false end
    if self._scout_actor and quest.BranchId == "ElvenScout"
        and (step_index == 5 or step_index == 7)
    then
        return self._scout_actor:available(quest, step_index)
    end
    for _, record in pairs(self._enemies) do
        if record.BranchId == quest.BranchId
            and record.Step == step_index
        then
            return true
        end
    end
    return false
end

--[[
Consumes one exact one-use event minted by this world's lethal-hit callback.

Args:
    user_id (number): Server-resolved owner UserId.
    event (any): Exact event table minted inside record_damage.
    quest (any): Owner's authoritative source quest.
    state (any): Current saved ordered step.

Returns:
    boolean: Whether event, owner, branch and stage all match.
]]
function Ledger:verify(
    user_id: number, event: any, quest: any, state: any
): boolean
    if type(event) == "table" and event.Kind == "NpcTalk" then
        return self._scout_actor ~= nil
            and self._scout_actor:verify(user_id, event, quest, state)
    end
    local pending = self._pending[user_id]
    self._pending[user_id] = nil
    return pending ~= nil and pending.Event == event
        and state.Step == pending.Step
        and quest.BranchId == pending.BranchId
        and event.ActorUserId == user_id
        and event.MonsterReceiptId == pending.MonsterReceiptId
end

--[[
Drops all unclaimed model and provisional receipts on wipe/room shutdown.

Args:
    None.

Returns:
    nil: Invalidates an old physical encounter without altering saved loot.
]]
function Ledger:clear()
    table.clear(self._enemies)
    table.clear(self._pending)
    if self._scout_actor then
        self._scout_actor:clear()
    end
end

return table.freeze(Ledger)
