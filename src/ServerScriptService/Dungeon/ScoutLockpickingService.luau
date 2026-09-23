--!strict
-- Server-registered physical dungeon locks. Each eligible party member
-- receives at most one private reward per lock and per dungeon session.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local ItemDefinitions = require(Shared.ItemDefinitions)
local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
local Inventory = require(
    game:GetService("ServerScriptService").Core.Services.InventoryService
)

local MAX_DISTANCE = 10
local LEVELS = table.freeze({20, 24, 28, 32, 36})
local ScoutLockpickingService = {}
ScoutLockpickingService.__index = ScoutLockpickingService

--[[
Returns a stable response without exposing private profile or session data.

Args:
    ok (boolean): Whether the request succeeded.
    reason (string): Public diagnostic for accepted/rejected interaction.

Returns:
    any: Bounded server-owned result payload.
]]
local function result(ok: boolean, reason: string): any
    return {ok = ok, reason = reason}
end

--[[
Builds a bounded durable reward record for this character's current run.

Args:
    character (any): Actual loaded profile character inside mutation.
    session_id (string): The current authoritative dungeon run.

Returns:
    any: Per-lock idempotency ledger for this one session.
]]
local function ledger_for(character: any, session_id: string): any
    local ledger = character.ScoutLockRewards
    if type(ledger) ~= "table"
        or ledger.SessionId ~= session_id
        or type(ledger.Locks) ~= "table"
    then
        ledger = {SessionId = session_id, Locks = {}}
        character.ScoutLockRewards = ledger
    end
    return ledger.Locks
end

--[[
Creates an isolated authoritative lock interaction service.

Args:
    sessions (any): DungeonSessionService for live party claims.
    profiles (any): Exclusive writer-owned ProfileService.
    session_id (string): Admitted reserved dungeon session ID.
    dungeon_id (string): Exact server-selected dungeon content ID.

Returns:
    any: Service with only server-registered physical lock targets.
]]
function ScoutLockpickingService.new(
    sessions: any, profiles: any, session_id: string,
    dungeon_id: string, on_open: ((Player) -> ())?
): any
    assert(type(session_id) == "string" and session_id ~= "")
    assert(type(dungeon_id) == "string" and dungeon_id ~= "")
    return setmetatable({
        _sessions = sessions,
        _profiles = profiles,
        _session_id = session_id,
        _dungeon_id = dungeon_id,
        _locks = {},
        _on_open = on_open,
    }, ScoutLockpickingService)
end

--[[
Registers a physical server-owned lock and its fixed reward definition.

Args:
    definition (any): Stable ID, difficulty, active checkpoint sequence,
        physical BasePart, bounded reward and optional required quest.

Returns:
    any: Result and a genuine server-connected ProximityPrompt.
]]
function ScoutLockpickingService:register(definition: any): any
    local rank = definition and definition.Rank
    local id = definition and definition.Id
    local part = definition and definition.Part
    local quantity = definition and definition.RewardQuantity
    local checkpoint = definition and definition.CheckpointSequence
    local item_id = definition and definition.RewardItemId
    if type(id) ~= "string" or not id:match("^[%w_%-]+$")
        or #id > 64 or self._locks[id]
        or type(rank) ~= "number" or rank % 1 ~= 0
        or rank < 1 or rank > 5
        or type(checkpoint) ~= "number" or checkpoint < 0
        or checkpoint % 1 ~= 0
        or not part or not part:IsA("BasePart")
        or not part:IsDescendantOf(workspace)
        or type(item_id) ~= "string"
        or not ItemDefinitions.get(item_id)
        or type(quantity) ~= "number" or quantity % 1 ~= 0
        or quantity < 1 or quantity > 5
        or (definition.QuestId ~= nil
            and (type(definition.QuestId) ~= "string"
                or definition.QuestId == ""))
    then
        return result(false, "InvalidServerLockDefinition")
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ScoutLockpickPrompt"
    prompt.ActionText = "Pick Lock"
    prompt.ObjectText = "Sealed Cache " .. tostring(rank)
    prompt.MaxActivationDistance = MAX_DISTANCE
    prompt.RequiresLineOfSight = true
    prompt.HoldDuration = 0.4
    prompt.Parent = part
    self._locks[id] = table.freeze({
        Id = id,
        Rank = rank,
        Part = part,
        RewardItemId = item_id,
        RewardQuantity = quantity,
        CheckpointSequence = checkpoint,
        QuestId = definition.QuestId,
    })
    prompt.Triggered:Connect(function(player: Player)
        local opened = self:try_open(player, id)
        if opened.ok and self._on_open then
            self._on_open(player)
        end
    end)
    return {ok = true, reason = "Registered", prompt = prompt}
end

--[[
Verifies live session, world distance and earned first-transfer skill rank.

Args:
    player (Player): Genuine server-resolved interaction source.
    lock (any): Whitelisted server-registered world lock.

Returns:
    string?: Rejection reason or nil when the attempt is authorized.
]]
function ScoutLockpickingService:_rejection(
    player: Player, lock: any
): string?
    if not player or player.Parent ~= Players then
        return "UnauthenticatedPlayer"
    end
    local session = self._sessions:get(self._session_id)
    local member = session and session.Members[tostring(player.UserId)]
    if not session or session.SessionId ~= self._session_id
        or session.DungeonId ~= self._dungeon_id
        or session.State ~= "Active"
        or not member or member.Connected ~= true
        or member.Abandoned == true or member.Mode ~= "Active"
    then
        return "DungeonMemberUnavailable"
    end
    local checkpoint = session.Checkpoint
    if not checkpoint or checkpoint.Sequence < lock.CheckpointSequence then
        return "LockRoomNotReached"
    end

    local character_model = player.Character
    local humanoid = character_model
        and character_model:FindFirstChildOfClass("Humanoid")
    local root = character_model
        and character_model:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0
        or not root or not root:IsA("BasePart")
        or not lock.Part:IsDescendantOf(workspace)
        or (root.Position - lock.Part.Position).Magnitude > MAX_DISTANCE
    then
        return "LockOutOfReach"
    end

    local character = self._profiles:get_character(player.UserId, 1)
    local identity = character and character.Identity
    local state = character and character.Progression
        and character.Progression.Skills
        and character.Progression.Skills.ScoutLockpicking
    local level = tonumber(character and character.Level) or 0
    local rank = state and tonumber(state.PurchasedRank) or 0
    if not identity
        or (identity.RaceId ~= "Human" and identity.RaceId ~= "Elf")
        or (identity.BaseClassId ~= "Ranger"
            and identity.BaseClassId ~= "Rogue")
        or type(state) ~= "table" or state.Known ~= true
        or rank < lock.Rank or rank > 5
        or level < LEVELS[lock.Rank]
        or not SkillDefinitions.get("ScoutLockpicking")
    then
        return "LockpickingRankRequired"
    end
    if lock.QuestId then
        local quests = character.Quests
        if not quests or type(quests.Completed) ~= "table"
            or quests.Completed[lock.QuestId] ~= true
        then
            return "LockQuestRequired"
        end
    end
    return nil
end

--[[
Awards a server-authored reward in the same profile mutation as its ledger.

Args:
    user_id (number): Admitted party member.
    lock (any): Registered reward, not values supplied by a client.

Returns:
    any: Idempotent grant, already-claimed or transaction failure.
]]
function ScoutLockpickingService:_award(
    user_id: number, lock: any
): any
    local outcome = result(false, "RewardNotCommitted")
    local ok, reason = self._profiles:mutate(user_id, function(profile: any)
        local slot = profile.Account.SelectedCharacterSlot
        local character = profile.Characters[
            "Slot" .. tostring(slot)
        ]
        assert(character, "RewardCharacterMissing")
        local ledger = ledger_for(character, self._session_id)
        if ledger[lock.Id] == true then
            outcome = result(false, "LockAlreadyClaimed")
            return
        end
        local grant = Inventory.apply_item_to_character(
            character, lock.RewardItemId, lock.RewardQuantity
        )
        assert(grant.ok, "LockRewardRejected")
        ledger[lock.Id] = true
        outcome = result(true, "LockOpened")
    end)
    if not ok then
        return result(false, reason or "RewardCommitFailed")
    end
    return outcome
end

--[[
Handles a physical ProximityPrompt; never trusts client rank, lock or loot.

Args:
    player (Player): Real server-authenticated prompt-triggering player.
    lock_id (string): Previously server-registered lock ID only.

Returns:
    any: Genuine one-time claim and atomic reward result.
]]
function ScoutLockpickingService:try_open(
    player: Player, lock_id: string
): any
    local lock = self._locks[lock_id]
    if not lock then
        return result(false, "UnknownWorldLock")
    end
    local rejection = self:_rejection(player, lock)
    if rejection then
        return result(false, rejection)
    end

    -- The session claim survives reconnects. An already claimed lock
    -- still retries a failed profile grant; the character ledger stops
    -- duplicates if the first grant actually committed.
    local claim_id = "ScoutLock:" .. lock.Id
    local claim = self._sessions:claim_resource_node_once(
        self._session_id, player.UserId, claim_id
    )
    if not claim.ok and claim.reason ~= "ResourceAlreadyClaimed" then
        return result(false, claim.reason or "LockClaimFailed")
    end
    local latest_rejection = self:_rejection(player, lock)
    if latest_rejection then
        return result(false, latest_rejection)
    end
    return self:_award(player.UserId, lock)
end

return table.freeze(ScoutLockpickingService)
