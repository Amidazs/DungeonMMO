--!strict
-- Duskguard confusion and self-immobility authority regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Confusion = require(
    ServerScriptService.Combat.C4NpcConfusionService
)
local Immobile = require(
    ServerScriptService.Combat.C4PlayerImmobileService
)

local checks = 0

--[[
Counts one control-authority assertion.

Args:
    condition (boolean): Observed authority state.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Duskguard Controls] " .. label)
end

--[[
Creates one disposable humanoid model.

Args:
    name (string): Fixture model name.
    position (Vector3): Root position.

Returns:
    Model: Workspace-owned fixture.
]]
local function fixture_model(
    name: string,
    position: Vector3
): Model
    local model = Instance.new("Model")
    model.Name = name

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = false
    root.Position = position
    root.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = model

    model.PrimaryPart = root
    model.Parent = Workspace
    return model
end

--[[
Runs confusion target exclusion and immobility restoration checks.

Args:
    None.

Returns:
    nil: Prints bounded control-authority evidence.
]]
local function main()
    local enemy = fixture_model(
        "TEMP_DuskguardConfusionEnemy",
        Vector3.zero
    )
    local excluded_model = fixture_model(
        "TEMP_DuskguardCaster",
        Vector3.new(1, 0, 0)
    )
    local eligible_model = fixture_model(
        "TEMP_DuskguardOtherPlayer",
        Vector3.new(2, 0, 0)
    )

    local applied = assert(Confusion.apply(
        enemy,
        111,
        5,
        6,
        20
    ))
    check(
        applied
            and Confusion.is_confused(enemy)
            and enemy:GetAttribute("C4Confused") == true
            and enemy:GetAttribute(
                "C4ConfusionRetargetsRemaining"
            ) == 5,
        "Confusion installs exact five-action server state"
    )

    local selected = Confusion.choose_player_target(
        enemy,
        {
            {
                player = {UserId = 111},
                root = excluded_model.HumanoidRootPart,
            },
            {
                player = {UserId = 222},
                root = eligible_model.HumanoidRootPart,
            },
        }
    )
    check(
        selected
            and selected.player.UserId == 222,
        "Confusion excludes the original caster from compatible targets"
    )

    Confusion.clear(enemy)
    check(
        not Confusion.is_confused(enemy)
            and enemy:GetAttribute("C4Confused") == false,
        "Confusion clears without stale AI state"
    )

    local owner_model = fixture_model(
        "TEMP_DuskguardLastStandOwner",
        Vector3.new(5, 0, 0)
    )
    local owner = {
        UserId = 333,
        Character = owner_model,
    }
    local root = assert(
        owner_model:FindFirstChild("HumanoidRootPart")
    ) :: BasePart

    local rooted = assert(Immobile.apply(owner, 30))
    check(
        rooted
            and Immobile.is_immobile(owner)
            and root.Anchored
            and owner_model:GetAttribute("C4Immobile") == true,
        "Last Stand immobility anchors only the live server root"
    )

    Immobile.clear(owner)
    check(
        not Immobile.is_immobile(owner)
            and not root.Anchored
            and owner_model:GetAttribute("C4Immobile") == false,
        "self immobility clears and restores service-owned anchoring"
    )

    enemy:Destroy()
    excluded_model:Destroy()
    eligible_model:Destroy()
    owner_model:Destroy()

    print((
        "[C4 Duskguard Controls] PASS: %d assertions"
    ):format(checks))
end

main()
