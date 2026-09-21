--!strict
-- Live corpse skinning is opt-in. No existing dungeon Marauder is tagged,
-- so humanoid enemies never become hide sources through a generic death.
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")

local SkinningEligibility = require(
    SSS.Core.Services:WaitForChild("SkinningEligibility")
)

local CorpseSkinningRuntime = {}

local BEAST_TAG = "DungeonMMOSkinnableBeast"
local SKINNING_RANGE = 12
local HIDE_NODE = table.freeze({
    ProfessionId = "Skinning",
    ItemId = "raw_hide",
    Quantity = 1,
    XP = 8,
})

-- Args:
--   model: any; the server-owned creature model to check.
-- Returns:
--   boolean: whether the corpse may grant hide before player range checks.
function CorpseSkinningRuntime.can_skin_model(model: any): boolean
    if typeof(model) ~= "Instance" or not model:IsA("Model")
        or not model:IsDescendantOf(workspace)
        or not CollectionService:HasTag(model, BEAST_TAG)
        or Players:GetPlayerFromCharacter(model) ~= nil
    then
        return false
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil
        and SkinningEligibility.can_skin(
            model:GetAttribute("CreatureSpeciesId"),
            model:GetAttribute("CreatureFamily"),
            humanoid.Health <= 0,
            model:GetAttribute("LootComplete"),
            model:GetAttribute("SkinningClaimed")
        )
end

-- Args:
--   player: Player; the player using the corpse prompt.
--   model: Model; the server-owned defeated and looted creature.
--   professions: any; the existing authoritative profession service.
-- Returns:
--   any: the grant or a rejection with a stable reason.
function CorpseSkinningRuntime.try_skin(
    player: Player,
    model: Model,
    professions: any
): any
    if not CorpseSkinningRuntime.can_skin_model(model) then
        return {ok = false, reason = "CreatureNotSkinnable"}
    end

    local root = player.Character
        and player.Character:FindFirstChild("HumanoidRootPart")
    local target = model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
    local player_humanoid = player.Character
        and player.Character:FindFirstChildOfClass("Humanoid")
    if not root or not root:IsA("BasePart")
        or not target or not target:IsA("BasePart")
        or not player_humanoid or player_humanoid.Health <= 0
        or (root.Position - target.Position).Magnitude > SKINNING_RANGE
    then
        return {ok = false, reason = "NotAtSkinnableCreature"}
    end

    -- This is synchronous: a second request cannot enter before the claim.
    model:SetAttribute("SkinningClaimed", true)
    local ok, result = pcall(function()
        return professions:gather(player.UserId, HIDE_NODE)
    end)
    if not ok or type(result) ~= "table" or result.ok ~= true then
        model:SetAttribute("SkinningClaimed", false)
        return if ok and type(result) == "table"
            then result
            else {ok = false, reason = "SkinningGrantFailed"}
    end
    return result
end

type WatchState = {
    model: Model,
    root: BasePart,
    professions: any,
    action_result: (Player, any) -> (),
    prompt: ProximityPrompt?,
}

-- Args:
--   state: WatchState; active model, root and existing prompt state.
-- Returns:
--   nil: updates only eligible dead and looted animal-corpse prompts.
local function refresh_prompt(state: WatchState)
    local ready = CorpseSkinningRuntime.can_skin_model(state.model)
    if state.prompt then
        state.prompt.Enabled = ready
        return
    end
    if not ready then
        return
    end

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "BeastSkinningPrompt"
    prompt.ActionText = "Skin"
    prompt.ObjectText = state.model.Name
    prompt.MaxActivationDistance = SKINNING_RANGE
    prompt.HoldDuration = 0.5
    prompt.RequiresLineOfSight = false
    state.prompt = prompt

    prompt.Triggered:Connect(function(player)
        local result = CorpseSkinningRuntime.try_skin(
            player, state.model, state.professions)
        if result.ok then
            prompt.Enabled = false
        end
        state.action_result(player, result)
    end)
    prompt.Parent = state.root
end

-- Args:
--   model: Model; a tagged and fully constructed server creature.
--   professions: any; the existing profession service.
--   action_result: (Player, any) -> (); forwards server results to client.
--   lifetime_root: Instance; the owner of the skinning runtime.
-- Returns:
--   nil: watches death and loot completion, without retaining old corpses.
local function watch_corpse(
    model: Model,
    professions: any,
    action_result: (Player, any) -> (),
    lifetime_root: Instance
)
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local part = model.PrimaryPart
        or model:FindFirstChild("HumanoidRootPart")
    if not humanoid or not part or not part:IsA("BasePart") then
        return
    end
    if not SkinningEligibility.is_species_allowed(
        model:GetAttribute("CreatureSpeciesId"),
        model:GetAttribute("CreatureFamily")
    ) then
        return
    end
    if model:GetAttribute("SkinningClaimed") == nil then
        model:SetAttribute("SkinningClaimed", false)
    end

    local state: WatchState = {
        model = model,
        root = part,
        professions = professions,
        action_result = action_result,
        prompt = nil,
    }
    local listeners: {RBXScriptConnection} = {}

    local function disconnect()
        for _, listener in ipairs(listeners) do
            listener:Disconnect()
        end
        table.clear(listeners)
    end

    table.insert(listeners, model.Destroying:Connect(disconnect))
    table.insert(listeners, lifetime_root.Destroying:Connect(disconnect))
    table.insert(listeners,
        humanoid.Died:Connect(function()
            refresh_prompt(state)
        end))
    table.insert(listeners,
        model:GetAttributeChangedSignal("LootComplete"):Connect(function()
            refresh_prompt(state)
        end))
    table.insert(listeners,
        model:GetAttributeChangedSignal("SkinningClaimed")
            :Connect(function()
                refresh_prompt(state)
            end))
    refresh_prompt(state)
end

-- Args:
--   config: any; includes root, professions and action_result callback.
-- Returns:
--   nil: watches future server-tagged animal corpses until root teardown.
function CorpseSkinningRuntime.attach(config: any)
    local root = assert(config.root, "Corpse skinning root required")
    local professions = assert(
        config.professions, "Corpse skinning professions required")
    local action_result = assert(
        config.action_result, "Corpse skinning result callback required")
    local watched: {[Model]: boolean} = {}

    local function register(instance: Instance)
        if not instance:IsA("Model") or watched[instance] then
            return
        end
        watched[instance] = true
        watch_corpse(instance, professions, action_result, root)
    end

    local added = CollectionService:GetInstanceAddedSignal(BEAST_TAG)
        :Connect(register)
    for _, instance in ipairs(CollectionService:GetTagged(BEAST_TAG)) do
        register(instance)
    end
    root.Destroying:Connect(function()
        added:Disconnect()
    end)
end

return table.freeze(CorpseSkinningRuntime)
