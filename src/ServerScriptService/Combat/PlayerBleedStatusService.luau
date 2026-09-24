--!strict
-- Server-owned player bleed from a confirmed hostile Captain Slash.
-- Client-visible status attributes never authorize a cure or damage tick.
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local DamageService = require(script.Parent:WaitForChild("DamageService"))

local Bleed = {}
local TICK_COUNT = 3
local TICK_SECONDS = 1
local TICK_DAMAGE = 3
local TIER = 1

type BleedRecord = {
    serial: number,
    character: Model,
    player: Player,
    expires_at: number,
    enemy: Model,
    tier: number,
}

local records: {[Model]: BleedRecord} = {}
local next_serial = 0

--[[
Clears only the exact active bleed, leaving a later reapplication intact.

Args:
    character (Model): Server-owned affected player character.
    serial (number): Unique application generation being cleared.

Returns:
    nil: Cancels that generation and resets presentation attributes.
]]
local function clear_matching(character: Model, serial: number)
    local current = records[character]
    if not current or current.serial ~= serial then
        return
    end
    records[character] = nil
    if character.Parent then
        character:SetAttribute("C4PlayerBleedTier", 0)
        character:SetAttribute("C4PlayerBleedExpiresAt", 0)
    end
end

--[[
Checks one current actual world-spawned player rather than a copied avatar.

Args:
    record (BleedRecord): Server-minted status and original owner.

Returns:
    boolean: Only the connected, living exact avatar remains eligible.
]]
local function active_owner(record: BleedRecord): boolean
    local character = record.character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return record.player.Parent == Players
        and record.player.Character == character
        and character:IsDescendantOf(workspace)
        and humanoid ~= nil and humanoid.Health > 0
end

--[[
Reports an authentic nonexpired player bleed, not a replicated attribute.

Args:
    character (Model?): Player avatar under inspection.

Returns:
    boolean: True only for its current server status and living owner.
]]
function Bleed.is_bleeding(character: Model?): boolean
    local current = character and records[character]
    return current ~= nil and active_owner(current)
        and current.expires_at > os.clock()
end

--[[
Removes a status up to the earned curative tier without restoring HP.

Args:
    character (Model?): Authentic caster's actual active character.
    maximum_tier (number): Rank-resolved positive server spell tier.

Returns:
    boolean: Whether the actual current bleed was cleared.
]]
function Bleed.cure(
    character: Model?, maximum_tier: number
): boolean
    if not character or not Bleed.is_bleeding(character)
        or type(maximum_tier) ~= "number"
        or maximum_tier < 1 or maximum_tier ~= maximum_tier
    then
        return false
    end
    local current = records[character]
    if not current or current.tier > maximum_tier then
        return false
    end
    clear_matching(character, current.serial)
    return true
end

--[[
Applies the next nonstacking status tick through bounded damage authority.

Args:
    character (Model): Original status target.
    serial (number): Captured generation, invalidated by cure or refresh.
    remaining (number): Positive server-authored tick count.

Returns:
    nil: Harms only the original active avatar, then clears or reschedules.
]]
local function tick(
    character: Model, serial: number, remaining: number
)
    local current = records[character]
    if not current or current.serial ~= serial then
        return
    end
    if not active_owner(current)
        or current.expires_at <= os.clock()
    then
        clear_matching(character, serial)
        return
    end
    DamageService.apply_damage({
        attacker = nil,
        attacker_character = current.enemy,
        target = character,
        source_kind = "EnemyArea",
        source_id = "CaptainSlashBleed",
        attack_id = nil,
        base_damage = TICK_DAMAGE,
        multiplier = 1,
        blocked = false,
    })
    if remaining <= 1 then
        clear_matching(character, serial)
    else
        task.delay(TICK_SECONDS, function()
            tick(character, serial, remaining - 1)
        end)
    end
end

--[[
Starts bleed only after the trusted dungeon Captain's genuine HP hit.

This function is called by the server attack controller after its real
DefenseService and DamageService outcomes. It is not a client event.

Args:
    enemy (Model): Living actual registered Marauder Captain.
    character (Model): The hit player's exact active dungeon avatar.
    health_damage (number): Positive damage returned by DamageService.

Returns:
    boolean: Whether this permitted nonblocked hit applied the status.
]]
function Bleed.apply_from_captain(
    enemy: Model, character: Model, health_damage: number
): boolean
    if typeof(enemy) ~= "Instance" or not enemy:IsA("Model")
        or typeof(character) ~= "Instance"
        or not character:IsA("Model")
        or type(health_damage) ~= "number"
        or health_damage <= 0 or health_damage >= math.huge
        or not CollectionService:HasTag(
            enemy, "DungeonMarauderCaptain"
        )
        or not enemy:IsDescendantOf(workspace)
    then
        return false
    end
    local player = Players:GetPlayerFromCharacter(character)
    local enemy_humanoid = enemy:FindFirstChildOfClass("Humanoid")
    local encounter_id = enemy:GetAttribute("DungeonEncounterId")
    if not player or player.Character ~= character
        or not character:IsDescendantOf(workspace)
        or not enemy_humanoid or enemy_humanoid.Health <= 0
        or character:GetAttribute("DungeonRunParticipant") ~= true
        or type(encounter_id) ~= "string"
        or encounter_id == ""
        or character:GetAttribute("DungeonEncounterId") ~= encounter_id
    then
        return false
    end
    next_serial += 1
    local serial = next_serial
    local record: BleedRecord = {
        serial = serial,
        character = character,
        player = player,
        expires_at = os.clock() + (TICK_COUNT + 1) * TICK_SECONDS,
        enemy = enemy,
        tier = TIER,
    }
    if not active_owner(record) then
        return false
    end
    records[character] = record
    character:SetAttribute("C4PlayerBleedTier", TIER)
    character:SetAttribute(
        "C4PlayerBleedExpiresAt", record.expires_at
    )
    task.delay(TICK_SECONDS, function()
        tick(character, serial, TICK_COUNT)
    end)
    return true
end

return table.freeze(Bleed)
