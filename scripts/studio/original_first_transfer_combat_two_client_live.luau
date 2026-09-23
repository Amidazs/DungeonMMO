--!strict
-- Two real unpublished clients and the unchanged Dungeon combat runtime.
-- All source injections and fake level-18 profiles live in a temp Studio place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Source quest live test must use a local, unpublished Studio place.")

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local runtime_source = SSS.Dungeon.DungeonRuntime

--[[
Replaces one exact source anchor inside the disposable Studio instance.

Args:
    original (string): Unique audited DungeonRuntime source statement.
    replacement (string): Test-only in-memory source replacement.

Returns:
    nil: Fails if the source has changed or contains repeated anchors.
]]
local function replace_once(original: string, replacement: string)
    local source = runtime_source.Source
    local start = assert(string.find(source, original, 1, true))
    assert(not string.find(
        source, original, start + #original, true
    ), "Dungeon source injection anchor is ambiguous.")
    runtime_source.Source = source:sub(1, start - 1)
        .. replacement .. source:sub(start + #original)
end

local context = Instance.new("ModuleScript")
context.Name = "FirstTransferCombatContext_TEMP"
context.Source = "return {}"
context.Parent = SSS.Dungeon

replace_once(
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. 'require(script.Parent.FirstTransferCombatContext_TEMP)'
        .. '.runtime = runtime'
)
replace_once(
    '    if RunService:IsStudio() then\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            {player},',
    '    if RunService:IsStudio() then\n'
        .. '        while #Players:GetPlayers() < 2 do task.wait(0.1) end\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            Players:GetPlayers(),'
)

WS:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
WS:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
WS:SetAttribute("DungeonMMOStudioBaseClass", "Fighter")
WS:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
WS:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)

local channel = Instance.new("RemoteEvent")
channel.Name = "FirstTransferCombatChannel_TEMP"
channel.Parent = RS


local client = Instance.new("LocalScript")
client.Name = "FirstTransferCombatRealClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("FirstTransferCombatChannel_TEMP")
local request = RS.Combat.Remotes:WaitForChild("SkillRequest")
channel.OnClientEvent:Connect(function(action, skill_id)
    if action == "CAST" then
        request:FireServer(skill_id)
        channel:FireServer("CAST_SENT", skill_id)
    end
end)
channel:FireServer("READY")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "FirstTransferCombatServer_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local CS = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local channel = RS.FirstTransferCombatChannel_TEMP
local context = require(SSS.Dungeon.FirstTransferCombatContext_TEMP)
local sources = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local careers = require(RS.Core.Shared.OriginalFirstTransferDefinitions)
local state = require(SSS.Core.Services.ProgressionRuntimeState)
local mana = require(SSS.Combat.ManaService)
local stamina = require(SSS.Combat.StaminaService)
local cooldowns = require(SSS.Combat.SkillCooldownService)
local damage = require(SSS.Combat.DamageService)
local combat = require(RS.Combat.Shared.SkillDefinitions)
local responses = {}

--[[
Records genuine client acknowledgements without accepting skill effects.

Args:
    player (Player): Roblox-authenticated originating client.
    action (string): Client ready or actual sent skill identifier.
    skill_id (string?): Client-reported requested skill, not authority.

Returns:
    nil: Stores test transport receipts for later server-side verification.
]]
local function record_response(player, action, skill_id)
    responses[tostring(player.UserId) .. ":" .. action] =
        skill_id or true
end
channel.OnServerEvent:Connect(record_response)

--[[
Waits only for a verified actual live session and server-side effect.

Args:
    predicate (() -> any): Real Roblox world or profile observation.
    label (string): Describes the exact missing acceptance result.
    seconds (number): Bounded timeout to avoid hiding broken tests.

Returns:
    any: First non-nil server-authoritative result.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = predicate()
        if result then return result end
        task.wait(0.12)
    until os.clock() >= deadline
    error("[First Transfer Combat] TIMEOUT " .. label)
end

--[[
Loads completed source proof and already purchased ability in a test profile.

Args:
    profiles (any): Real live Dungeon exclusive profile writer.
    player (Player): Authenticated test client and personal item owner.
    branch_id (string): Existing stable first-transfer quest branch.
    rank (number): Actual authored purchased skill rank, one or two.

Returns:
    nil: One disposable original class and runtime combat snapshot.
]]
local function prepare(profiles, player, branch_id, rank)
    local quest = assert(sources.get(branch_id))
    local definition = assert(careers.for_branch(branch_id))
    local skill_id = if branch_id == "HumanRogue"
        then "AshenbladeOpening" else "GreenwardRenewal"
    local prerequisite = if branch_id == "HumanRogue"
        then "FighterDaggerStrike" else "ElvenFighterRenewal"
    local prepared, reason = profiles:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Level = if rank == 1 then 24 else 28
        character.Identity = {
            Version = 1, RaceId = definition.RaceId,
            BaseClassId = "Fighter", ClassId = definition.Id,
            CreationStage = "Complete",
        }
        local proofs = {}
        for _, proof_id in ipairs(quest.RequiredProofIds) do
            proofs[proof_id] = true
        end
        character.ClassAdvancement = {
            Version = 1,
            CompletedByRace = {},
            OriginalFirstTransferChoiceId = branch_id,
            OriginalFirstTransferClassId = definition.Id,
            OriginalFirstTransferReceiptId =
                "LiveOriginalCombat:" .. tostring(player.UserId),
            OriginalFirstTransferQuest = {
                QuestId = quest.Id, BranchId = branch_id,
                Step = #quest.Steps + 1, Count = 0,
                Ready = true, AppliedEvents = {}, Proofs = proofs,
            },
        }
        character.Equipment.Weapon = if branch_id == "HumanRogue"
            then "scout_dagger" else "apprentice_longbow"
        character.Progression.Skills[prerequisite] = {
            Known = true, PurchasedRank = if branch_id == "HumanRogue"
                then 3 else 1,
            Proficiency = if branch_id == "HumanRogue" then 80 else 30,
        }
        character.Progression.Skills[skill_id] = {
            Known = true, PurchasedRank = rank, Proficiency = 80,
        }
        character.Progression.Loadout[1] = skill_id
    end)
    assert(prepared, "Disposable original career seed rejected: "
        .. tostring(reason))
    local character = assert(profiles:get_character(player.UserId))
    assert(careers.awarded(character) == definition,
        "Real migration rejected an unbacked original class")
    state.set_character(player.UserId, character)
    state.apply_runtime_stats(player)
    local allowed, why = state.is_skill_usable(player.UserId, skill_id)
    assert(allowed, "Actual original combat gate rejected legal skill: "
        .. tostring(why))
end

--[[
Locates the actual CombatRoom1 encounter's physically spawned enemy.

Args:
    None.

Returns:
    Model: Live instance combat target with server-owned humanoid state.
]]
local function find_enemy()
    local folder = WS.DungeonGameplayRuntime.DungeonEnemies
    return wait_for(function()
        for _, enemy in ipairs(folder:GetChildren()) do
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 and enemy.PrimaryPart
            then
                return enemy
            end
        end
    end, "physical active-room dungeon enemy", 20)
end

--[[
Requests an actual client combat skill and observes its transport receipt.

Args:
    player (Player): Admitted live multiplayer client.
    skill_id (string): One real server-registered and equipped ability.

Returns:
    nil: Client performed the real SkillRequest RemoteEvent path.
]]
local function request(player, skill_id)
    local key = tostring(player.UserId) .. ":CAST_SENT"
    responses[key] = nil
    channel:FireClient(player, "CAST", skill_id)
    wait_for(function()
        return responses[key] == skill_id
    end, "genuine client skill remote for " .. skill_id, 12)
end

--[[
Executes a genuine client dagger strike on a registered instanced enemy.

Args:
    profiles (any): Current Dungeon profile owner authority.
    human (Player): Earned Ashenblade test client with real dagger.
    elf (Player): Other real player whose class must not be advanced.

Returns:
    nil: Confirms real melee damage, spent stamina and cooldown.
]]
local function verify_ashenblade(profiles, human, elf)
    prepare(profiles, human, "HumanRogue", 1)
    local enemy = find_enemy()
    local humanoid = assert(enemy:FindFirstChildOfClass("Humanoid"))
    local root = assert(enemy.PrimaryPart)
    root.Anchored = true
    humanoid.MaxHealth = 1000
    humanoid.Health = 1000
    local user_root = assert(human.Character.HumanoidRootPart)
    user_root.CFrame = CFrame.lookAt(
        root.Position + Vector3.new(0, 0, 4),
        root.Position
    )
    user_root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.4)
    local before = humanoid.Health
    assert(profiles:mutate(human.UserId, function(profile)
        profile.Characters.Slot1.Equipment.Weapon = "marauder_sword"
    end), "Disposable wrong-weapon combat denial setup failed")
    state.set_character(human.UserId,
        assert(profiles:get_character(human.UserId)))
    assert(not state.is_skill_usable(human.UserId, "AshenbladeOpening"),
        "Sword cannot authorize an earned dagger-only first-class skill")
    request(human, "AshenbladeOpening")
    task.wait(0.8)
    assert(humanoid.Health == before
        and cooldowns.get_remaining(human, "AshenbladeOpening") == 0,
        "Real client wrong-weapon request damaged enemy or spent cooldown")
    assert(profiles:mutate(human.UserId, function(profile)
        profile.Characters.Slot1.Equipment.Weapon = "scout_dagger"
    end), "Disposable real dagger restore was rejected")
    state.set_character(human.UserId,
        assert(profiles:get_character(human.UserId)))
    assert(state.is_skill_usable(human.UserId, "AshenbladeOpening"),
        "Restored earned dagger cannot authorize real combat skill")
    print("[First Transfer Combat] WRONG_WEAPON_CLIENT_CAST_DENIED_PASS")
    local stamina_before = stamina.get(human)
    request(human, "AshenbladeOpening")
    wait_for(function()
        return humanoid.Health < before
    end, "paid Ashenblade Opening hits a real instanced monster", 12)
    assert(stamina.get(human) <= stamina_before - 18
        and cooldowns.get_remaining(human, "AshenbladeOpening") > 4,
        "Actual Ashenblade combat did not spend stamina/cooldown")
    assert(profiles:get_character(elf.UserId).Identity.ClassId
        ~= "Ashenblade", "Client cast cross-granted wrong player's class")
    print("[First Transfer Combat] REAL_ASHENBLADE_ENEMY_HIT_PASS")
end

--[[
Executes a genuine client self-heal and verifies actual resource spend.

Args:
    profiles (any): Current authoritative Dungeon player profile store.
    elf (Player): Earned and equipped Greenward Scout client.
    human (Player): Other party member, not the heal target.

Returns:
    nil: Real owner health rises, other's health stays unchanged.
]]
local function verify_greenward(profiles, elf, human)
    prepare(profiles, elf, "ElvenScout", 1)
    local avatar = assert(elf.Character)
    local healer = assert(avatar:FindFirstChildOfClass("Humanoid"))
    local other = assert(human.Character
        :FindFirstChildOfClass("Humanoid"))
    local root = assert(avatar.HumanoidRootPart)
    root.Anchored = true
    root.CFrame = CFrame.new(0, 160, 0)
    other.MaxHealth = 2500
    other.Health = 1750
    healer.MaxHealth = 2500
    healer.Health = 1400
    local before = healer.Health
    local other_before = other.Health
    assert(profiles:mutate(elf.UserId, function(profile)
        profile.Characters.Slot1.Progression
            .Skills.GreenwardRenewal = nil
    end), "Disposable unpurchased-heal test setup failed")
    state.set_character(elf.UserId,
        assert(profiles:get_character(elf.UserId)))
    assert(not state.is_skill_usable(elf.UserId, "GreenwardRenewal"),
        "Unpurchased Greenward heal must fail server combat eligibility")
    request(elf, "GreenwardRenewal")
    task.wait(0.8)
    -- Natural Humanoid health regeneration can advance between frames.
    -- An unauthorized 35-HP heal must not appear in this short window.
    assert(healer.Health < before + 15
        and cooldowns.get_remaining(elf, "GreenwardRenewal") == 0,
        "Unpurchased real client Greenward heal restored significant HP "
            .. "or started its server cooldown")
    prepare(profiles, elf, "ElvenScout", 1)
    print("[First Transfer Combat] UNPURCHASED_CLIENT_HEAL_DENIED_PASS")
    local mana_before = mana.get(elf)
    local minimum = assert(
        combat.get_for_rank("GreenwardRenewal", 1)
    ).MANA_COST
    request(elf, "GreenwardRenewal")
    wait_for(function()
        return healer.Health >= before + 25
    end, "real client Greenward self-heal increases owner health", 12)
    assert(other.Health == other_before,
        "Greenward self-heal incorrectly healed another party member")
    assert(mana.get(elf) <= mana_before - minimum + 1
        and cooldowns.get_remaining(elf, "GreenwardRenewal") > 10,
        "Greenward paid client cast did not spend mana and cooldown")
    print("[First Transfer Combat] REAL_GREENWARD_OWNER_HEAL_PASS")
end

--[[
Starts genuine two-client instanced combat with earlier quests seeded only
in the disposable Studio profiles to isolate new combat functionality.

Args:
    None.

Returns:
    nil: Runs both actual effects using existing Dungeon combat services.
]]
local function main()
    local members = wait_for(function()
        local players = Players:GetPlayers()
        return if #players == 2 then players else nil
    end, "two real multiplayer Studio clients", 45)
    table.sort(members, function(a, b)
        return a.UserId < b.UserId
    end)
    local human, elf = members[1], members[2]
    local runtime = wait_for(function()
        return context.runtime
    end, "real Dungeon runtime", 35)
    local profiles = runtime.ProfileService
    local sessions = runtime.SessionService
    local session = wait_for(function()
        local current = sessions:get_for_user(human.UserId)
        if not current or current.State ~= "Active" then return nil end
        for _, player in ipairs(members) do
            local member = current.Members[tostring(player.UserId)]
            if not member or member.Mode ~= "Active"
                or not profiles:get_character(player.UserId)
                or not player.Character
                or not player.Character:FindFirstChild("HumanoidRootPart")
                or not responses[tostring(player.UserId) .. ":READY"]
            then return nil end
        end
        return current
    end, "admitted two-player real dungeon instance", 75)
    prepare(profiles, human, "HumanRogue", 1)
    prepare(profiles, elf, "ElvenScout", 1)
    local trigger = wait_for(function()
        for _, part in ipairs(CS:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if part:GetAttribute("AnchorId") == "Temple.Room1.Trigger"
            then return part end
        end
    end, "real first-room combat trigger", 22)
    for _, player in ipairs(members) do
        player.Character.HumanoidRootPart.CFrame =
            trigger.CFrame * CFrame.new(0, 0, 9)
        task.wait(0.15)
        player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(
            trigger.Position + Vector3.new(0, 0, -2)
        )
    end
    wait_for(function()
        local current = sessions:get(session.SessionId)
        local state = current and current.InstanceState
        local progress = state and state.EncounterRuntime
        return progress and progress.EncounterStates
            and progress.EncounterStates.CombatRoom1 == "Active"
    end, "actual instanced combat room became active", 18)
    for _, player in ipairs(members) do
        local avatar = player.Character
        avatar:FindFirstChildOfClass("Humanoid").MaxHealth = 2500
        avatar:FindFirstChildOfClass("Humanoid").Health = 2500
    end
    verify_ashenblade(profiles, human, elf)
    task.wait(1)
    verify_greenward(profiles, elf, human)
    print("[First Transfer Combat] TWO_CLIENT_ORIGINAL_CASTS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[First Transfer Combat] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(140, function()
    STS:EndTest("FAIL global first-transfer combat timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "OriginalFirstTransferActualCombat_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Original first-transfer live combat failed: " .. tostring(result))
print("[First Transfer Combat] VERIFIED_TWO_CLIENT_REAL_CASTS_PASS")
