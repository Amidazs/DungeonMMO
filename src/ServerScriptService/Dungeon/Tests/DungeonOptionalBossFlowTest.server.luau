--!strict
local Dungeon = game:GetService("ServerScriptService")
    :WaitForChild("Dungeon")
local Flow = require(Dungeon:WaitForChild("DungeonEncounterFlow"))
local count = 0

-- Checks a Secret-boss flow invariant.
-- Args: condition (boolean): Expected behaviour.
--       message (string): Failure explanation.
-- Returns: nil: Raises on failure.
local function check(condition: boolean, message: string)
    count += 1
    assert(condition, "[Optional Boss Flow Tests] " .. message)
end

local secret = {
    PlanEncounterId = "SecretEncounter",
    RoomSlotId = "SecretArena",
    Kind = "SecretBoss",
}
local final = {
    PlanEncounterId = "FinalBoss",
    RoomSlotId = "Room3",
    Kind = "Boss",
}
local bindings = {
    ok = true,
    by_slot = {SecretArena = secret, Room3 = final},
    by_encounter = {SecretEncounter = secret, FinalBoss = final},
    by_runtime = {SecretEncounter = secret, FinalBoss = final},
    ordered = {secret, final},
}

local controller = {
    next_encounter = "SecretEncounter",
    required = false,
    skip_count = 0,
}

-- Returns the pending encounter from the synthetic authoritative controller.
-- Args: None.
-- Returns: string: Next encounter ID.
function controller:next_id(): string
    return self.next_encounter
end

-- Returns the persisted descriptor for one requested encounter.
-- Args: encounter_id (string): Requested encounter identity.
-- Returns: any: Encounter descriptor or nil.
function controller:get(encounter_id: string): any
    if encounter_id ~= "SecretEncounter" then
        return nil
    end
    return {CompletionRequired = self.required}
end

-- Simulates the sequencer's persisted optional skip.
-- Args: encounter_id (string): Encounter to skip.
-- Returns: any: Success result with next encounter.
function controller:skip(encounter_id: string): any
    check(encounter_id == "SecretEncounter",
        "Only the pending secret may be skipped")
    self.skip_count += 1
    self.next_encounter = "FinalBoss"
    return {ok = true, next_encounter_id = "FinalBoss"}
end

local flow = Flow.new(controller, bindings)
check(flow:skip_secret_before("Room1").reason
    == "SecretSuccessorMismatch",
    "An unrelated physical trigger must not bypass the secret")
check(controller.skip_count == 0,
    "Rejected trigger must not mutate encounter progression")

controller.required = true
check(flow:skip_secret_before("Room3").reason
    == "SecretEncounterRequired",
    "A required secret encounter may not be skipped")
controller.required = false
local success = flow:skip_secret_before("Room3")
check(success.ok == true and success.next_binding == final,
    "Direct successor must advance past optional secret")
check(controller.skip_count == 1
    and controller.next_encounter == "FinalBoss",
    "Optional skip must be persisted only once")
check(flow:skip_secret_before("Room3").reason
    == "NoOptionalSecretToSkip",
    "Ordinary final boss progression must remain untouched")
check(controller.skip_count == 1,
    "Repeated trigger cannot double-skip a secret")

controller.next_encounter = "SecretEncounter"
secret.Kind = "EventBoss"
check(flow:skip_secret_before("Room3").reason
    == "NoOptionalSecretToSkip",
    "A required Event boss must never be bypassed as a secret")

print(string.format(
    "[Optional Boss Flow Tests] PASS: %d assertions.", count
))
