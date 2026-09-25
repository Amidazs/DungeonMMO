--!strict
local ServerScriptService =
    game:GetService("ServerScriptService")

local ManaService = require(
    ServerScriptService
        :WaitForChild("Combat")
        :WaitForChild("ManaService")
)

local assertions = 0

local function check(
    value: boolean,
    message: string
)
    assertions += 1
    if not value then
        error(
            "[Mana Service Tests] "
                .. message,
            2
        )
    end
end

local subject = Instance.new("Folder")
ManaService.initialize_player(subject)

check(
    ManaService.get(subject) == 100,
    "neutral Mana must initialize full at 100"
)
check(
    ManaService.get_max(subject) == 100,
    "neutral Max Mana must be 100"
)
check(
    subject:GetAttribute("CombatMana") == 100
        and subject:GetAttribute(
            "CombatMaxMana"
        ) == 100,
    "Mana must replicate current/max values"
)
check(
    subject:GetAttribute(
        "CombatManaRegenPerSecond"
    ) == 8,
    "neutral Spirit must replicate 8 Mana/s"
)
check(
    ManaService.try_spend(
        subject,
        20
    ) == true
        and ManaService.get(subject) == 80,
    "20 Mana spend must be atomic"
)
check(
    ManaService.try_spend(
        subject,
        81
    ) == false
        and ManaService.get(subject) == 80,
    "insufficient Mana must reject without partial spend"
)

ManaService.reset_player(subject)
check(
    ManaService.try_spend(subject, 48)
        and ManaService.get(subject) == 52,
    "split-MP affordability fixture must reach 52 Mana"
)
check(
    ManaService.try_begin_split_spend(
        subject,
        11,
        42
    ) == false
        and ManaService.get(subject) == 52,
    "C4 split cast must require initial plus completion MP"
)

ManaService.reset_player(subject)
check(
    ManaService.try_begin_split_spend(
        subject,
        11,
        42
    ) == true
        and ManaService.get(subject) == 89,
    "C4 split cast must spend only initial MP at cast start"
)
check(
    ManaService.finish_split_spend(
        subject,
        42
    ) == 42
        and ManaService.get(subject) == 47,
    "C4 split cast must spend ongoing MP only at launch"
)

ManaService.reset_player(subject)
check(
    ManaService.try_begin_split_spend(
        subject,
        11,
        42
    ) == true
        and ManaService.get(subject) == 89,
    "interrupted C4 cast fixture must spend its initial MP"
)

ManaService.reset_player(subject)

check(
    ManaService.get(subject) == 100,
    "respawn reset must restore full Mana"
)

ManaService.remove_player(subject)

check(
    ManaService.get(subject) == 0,
    "removed owner must have no authoritative Mana record"
)

subject:Destroy()

print(
    string.format(
        "[Mana Service Tests] PASS: %d assertions.",
        assertions
    )
)
