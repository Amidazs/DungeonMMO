--!strict
-- Server-authoritative C4 shot charging, inventory and one-use regression.

local ServerScriptService = game:GetService("ServerScriptService")

local ShotService = require(
    ServerScriptService.Core.Services.C4SourceShotService
)

local SWORD_ID = 948201
local TRIDENT_ID = 948202
local NETI_BOW_ID = 948203
local SHORT_NETI_ID = 948204
local UNARMED_ID = 948205

local checks = 0
local counts = {
    [SWORD_ID] = {
        kinetic_charge = 10,
        mystic_charge = 5,
        blessed_mystic_charge = 5,
    },
    [TRIDENT_ID] = {
        d_grade_kinetic_charge = 4,
        d_grade_mystic_charge = 4,
        d_grade_blessed_mystic_charge = 4,
    },
    [NETI_BOW_ID] = {
        kinetic_charge = 10,
    },
    [SHORT_NETI_ID] = {
        kinetic_charge = 6,
    },
}

local InventoryAuthority = {}

--[[
Consumes a quantity from the disposable authoritative inventory.

Args:
    user_id (number): Test inventory owner.
    item_id (string): Creative charge item.
    quantity (number?): Positive amount to consume.

Returns:
    any: InventoryService-compatible result.
]]
function InventoryAuthority:consume_item(
    user_id: number,
    item_id: string,
    quantity: number?
): any
    local amount = quantity or 1
    local inventory = counts[user_id] or {}
    local available = inventory[item_id] or 0

    if available < amount then
        return {
            ok = false,
            reason = "ItemNotOwned",
        }
    end

    inventory[item_id] = available - amount
    counts[user_id] = inventory

    return {
        ok = true,
        item_id = item_id,
        quantity_removed = amount,
        total_quantity = inventory[item_id],
    }
end

--[[
Returns a minimal authenticated source-equipment boundary for each test owner.

Args:
    user_id (number): Test owner whose reviewed weapon is requested.

Returns:
    (any?, string?): Boundary or strict test denial reason.
]]
local function boundary_provider(
    user_id: number
): (any?, string?)
    local weapon_by_user = {
        [SWORD_ID] = 1,
        [TRIDENT_ID] = 291,
        [NETI_BOW_ID] = 1181,
        [SHORT_NETI_ID] = 1181,
    }

    if user_id == UNARMED_ID then
        return {
            ReviewedSourceItemIds = {},
        }, nil
    end

    local weapon_id = weapon_by_user[user_id]
    if not weapon_id then
        return nil, "OriginalCharacterIdentityNotVerified"
    end

    return {
        ReviewedSourceItemIds = {
            Weapon = weapon_id,
        },
    }, nil
end

--[[
Counts one shot-authority assertion.

Args:
    valid (boolean): Expected source shot behaviour.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Source Shots] " .. label)
end

--[[
Runs exact grade, quantity, idempotence and one-use charge checks.

Args:
    None.

Returns:
    nil: Prints the bounded source-shot acceptance marker.
]]
local function main()
    local service = ShotService.new(
        InventoryAuthority,
        boundary_provider
    )

    local sword = service:charge(SWORD_ID, "Soulshot")
    check(
        sword.ok
            and sword.SourceItemId == 1835
            and sword.ConsumedCount == 1
            and counts[SWORD_ID].kinetic_charge == 9,
        "no-grade sword consumes one mapped physical charge"
    )

    local repeated = service:charge(SWORD_ID, "Soulshot")
    check(
        repeated.ok
            and repeated.AlreadyCharged
            and counts[SWORD_ID].kinetic_charge == 9,
        "recharging an active source shot consumes nothing"
    )

    check(
        service:consume_physical(SWORD_ID).Soulshot
            and not service:consume_physical(SWORD_ID).Soulshot,
        "physical shot charge is one-use"
    )

    local spirit = service:charge(SWORD_ID, "Spiritshot")
    local blessed = service:charge(
        SWORD_ID,
        "BlessedSpiritshot"
    )
    check(
        spirit.ok
            and spirit.SourceItemId == 2509
            and blessed.ok
            and blessed.SourceItemId == 3947,
        "no-grade magical charges use exact source item mapping"
    )

    local first_magic = service:consume_magic(SWORD_ID)
    check(
        first_magic.BlessedSpiritshot
            and not first_magic.Spiritshot
            and service:snapshot(SWORD_ID).Spiritshot,
        "Blessed source charge has priority without clearing Spiritshot"
    )

    local second_magic = service:consume_magic(SWORD_ID)
    check(
        second_magic.Spiritshot
            and not second_magic.BlessedSpiritshot,
        "remaining Spiritshot is consumed by the next magic action"
    )

    local trident = service:charge(TRIDENT_ID, "Soulshot")
    check(
        trident.ok
            and trident.SourceWeaponGrade == "D"
            and trident.SourceItemId == 1463
            and trident.ConsumedCount == 2
            and counts[TRIDENT_ID].d_grade_kinetic_charge == 2,
        "D-grade Trident consumes exact two-shot source requirement"
    )

    local neti = service:charge(NETI_BOW_ID, "Soulshot")
    check(
        neti.ok
            and neti.SourceWeaponId == 1181
            and neti.ConsumedCount == 7
            and counts[NETI_BOW_ID].kinetic_charge == 3,
        "Neti source bow consumes its exact seven physical shots"
    )

    local short = service:charge(SHORT_NETI_ID, "Soulshot")
    check(
        not short.ok
            and short.reason == "NotEnoughSourceShots"
            and counts[SHORT_NETI_ID].kinetic_charge == 6,
        "insufficient exact source shot quantity fails atomically"
    )

    local unarmed = service:charge(UNARMED_ID, "Soulshot")
    check(
        not unarmed.ok
            and unarmed.reason == "OriginalShotWeaponUnavailable",
        "unarmed source character cannot charge weapon shots"
    )

    service:remove_player(SWORD_ID)
    local cleared = service:snapshot(SWORD_ID)
    check(
        not cleared.Soulshot
            and not cleared.Spiritshot
            and not cleared.BlessedSpiritshot,
        "player removal clears ephemeral source charge state"
    )

    print((
        "[C4 Source Shots] SOURCE_SHOT_PASS: %d assertions "
        .. "inventory=true grade=true one_use=true"
    ):format(checks))
end

main()
