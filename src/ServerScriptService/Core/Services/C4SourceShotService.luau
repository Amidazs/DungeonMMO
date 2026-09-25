--!strict
-- Server-authoritative C4 shot charging and one-use charge state.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local ShotMap = require(Shared.C4CreativeShotSourceMap)
local SourceItems = require(Shared.C4SourceItemReference)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4SourceShotService = {}
C4SourceShotService.__index = C4SourceShotService

local SHOT_COUNT_FIELD = table.freeze({
    Soulshot = "SoulShotCount",
    Spiritshot = "SpiritShotCount",
    BlessedSpiritshot = "SpiritShotCount",
})

--[[
Returns the default authenticated source-boundary provider.

Args:
    user_id (number): Server-authoritative player user ID.

Returns:
    (any?, string?): Current source migration boundary or denial reason.
]]
local function default_boundary_provider(
    user_id: number
): (any?, string?)
    return Runtime.get_c4_resource_migration_boundary(user_id)
end

--[[
Returns the mutable charge record for one owner.

Args:
    service (any): C4SourceShotService instance.
    user_id (number): Authoritative player user ID.

Returns:
    any: Existing or newly-created private charge record.
]]
local function charge_record(service: any, user_id: number): any
    local record = service._charges[user_id]
    if not record then
        record = {
            Soulshot = false,
            Spiritshot = false,
            BlessedSpiritshot = false,
        }
        service._charges[user_id] = record
    end
    return record
end

--[[
Resolves exact source weapon/shot consumption requirements.

Args:
    boundary (any): Authenticated source-ready character boundary.
    shot_kind (string): Source shot family being charged.

Returns:
    (any?, string?): Required creative item/count/source evidence.
]]
local function resolve_requirement(
    boundary: any,
    shot_kind: string
): (any?, string?)
    local count_field = SHOT_COUNT_FIELD[shot_kind]
    if not count_field then
        return nil, "UnsupportedOriginalShotKind"
    end

    local source_ids = boundary.ReviewedSourceItemIds
    local weapon_id = type(source_ids) == "table"
        and source_ids.Weapon
        or nil
    if type(weapon_id) ~= "number" then
        return nil, "OriginalShotWeaponUnavailable"
    end

    local weapon = SourceItems.get(weapon_id)
    if not weapon or weapon.Slot ~= "Weapon" then
        return nil, "OriginalShotWeaponUnavailable"
    end

    local required = weapon[count_field]
    if type(required) ~= "number"
        or required % 1 ~= 0
        or required <= 0
    then
        return nil, "OriginalWeaponShotCountUnavailable"
    end

    local mapping, reason = ShotMap.get(
        weapon.Grade or "None",
        shot_kind
    )
    if not mapping then
        return nil, reason
    end

    return {
        ShotKind = shot_kind,
        CreativeItemId = mapping.CreativeItemId,
        SourceItemId = mapping.SourceItemId,
        SourceWeaponId = weapon_id,
        SourceWeaponGrade = weapon.Grade or "None",
        RequiredCount = required,
    }, nil
end

--[[
Creates the server-authoritative shot service.

Args:
    inventory_service (any): Inventory authority exposing consume_item.
    boundary_provider (any?): Injectable source-boundary provider for tests.

Returns:
    any: New private shot service instance.
]]
function C4SourceShotService.new(
    inventory_service: any,
    boundary_provider: any?
): any
    assert(
        type(inventory_service) == "table"
            and type(inventory_service.consume_item) == "function",
        "C4 shot service requires InventoryService authority"
    )

    return setmetatable({
        _inventory = inventory_service,
        _boundary_provider =
            boundary_provider or default_boundary_provider,
        _charges = {},
    }, C4SourceShotService)
end

--[[
Consumes exact source-equivalent inventory and charges one shot family.

Charging an already charged family is idempotent and consumes nothing,
matching the reviewed C4 item handlers.

Args:
    user_id (number): Authoritative player user ID.
    shot_kind (string): Soulshot, Spiritshot or BlessedSpiritshot.

Returns:
    any: Stable charge result with source weapon/item evidence.
]]
function C4SourceShotService:charge(
    user_id: number,
    shot_kind: string
): any
    local record = charge_record(self, user_id)
    if record[shot_kind] == true then
        return {
            ok = true,
            AlreadyCharged = true,
            ShotKind = shot_kind,
        }
    end

    local boundary, boundary_reason =
        self._boundary_provider(user_id)
    if not boundary then
        return {ok = false, reason = boundary_reason}
    end

    local requirement, requirement_reason =
        resolve_requirement(boundary, shot_kind)
    if not requirement then
        return {ok = false, reason = requirement_reason}
    end

    local consumed = self._inventory:consume_item(
        user_id,
        requirement.CreativeItemId,
        requirement.RequiredCount
    )
    if type(consumed) ~= "table" or consumed.ok ~= true then
        return {
            ok = false,
            reason = "NotEnoughSourceShots",
            InventoryReason = if type(consumed) == "table"
                then consumed.reason
                else nil,
        }
    end

    record[shot_kind] = true

    return {
        ok = true,
        AlreadyCharged = false,
        ShotKind = shot_kind,
        CreativeItemId = requirement.CreativeItemId,
        SourceItemId = requirement.SourceItemId,
        SourceWeaponId = requirement.SourceWeaponId,
        SourceWeaponGrade = requirement.SourceWeaponGrade,
        ConsumedCount = requirement.RequiredCount,
    }
end

--[[
Consumes one charged Soulshot state for a physical action.

Args:
    user_id (number): Authoritative player user ID.

Returns:
    any: Detached one-use physical shot state.
]]
function C4SourceShotService:consume_physical(
    user_id: number
): any
    local record = charge_record(self, user_id)
    local charged = record.Soulshot == true
    record.Soulshot = false

    return {
        Soulshot = charged,
    }
end

--[[
Consumes one charged magical shot with Blessed priority.

The reviewed MDAM/buff handlers prefer Blessed Spiritshot when both magical
families are charged and clear only the selected family.

Args:
    user_id (number): Authoritative player user ID.

Returns:
    any: Detached magical shot state for one action.
]]
function C4SourceShotService:consume_magic(
    user_id: number
): any
    local record = charge_record(self, user_id)

    if record.BlessedSpiritshot == true then
        record.BlessedSpiritshot = false
        return {
            Spiritshot = false,
            BlessedSpiritshot = true,
        }
    end

    local spiritshot = record.Spiritshot == true
    record.Spiritshot = false

    return {
        Spiritshot = spiritshot,
        BlessedSpiritshot = false,
    }
end

--[[
Returns a detached private charge snapshot for tests/diagnostics.

Args:
    user_id (number): Authoritative player user ID.

Returns:
    any: Independent charge-state copy.
]]
function C4SourceShotService:snapshot(user_id: number): any
    local record = charge_record(self, user_id)
    return table.clone(record)
end

--[[
Clears all ephemeral shot charges when an owner leaves.

Args:
    user_id (number): Departing player user ID.

Returns:
    nil: Removes only private server charge state.
]]
function C4SourceShotService:remove_player(user_id: number)
    self._charges[user_id] = nil
end

return C4SourceShotService
