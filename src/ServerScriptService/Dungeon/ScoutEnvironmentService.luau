--!strict
-- Owns actual dungeon water breathing and world-landing fall injury.
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Rules = require(RS.Core.Shared.ScoutEnvironmentalRules)

local TICK_SECONDS = 0.25
local DROWNING_TICK_SECONDS = 1
local DROWNING_DAMAGE = 6
local ScoutEnvironmentService = {}
ScoutEnvironmentService.__index = ScoutEnvironmentService

--[[
Samples the server Terrain voxels at the character's physical head.

Args:
    head (BasePart): Real present player's server-world head part.

Returns:
    boolean: True only if the actual head voxel is occupied by water.
]]
local function head_in_terrain_water(head: BasePart): boolean
    local point = head.Position
    local region = Region3.new(
        point - Vector3.new(2, 2, 2),
        point + Vector3.new(2, 2, 2)
    ):ExpandToGrid(4)
    local materials, occupancy = workspace.Terrain:ReadVoxels(region, 4)
    local centre_material = materials[1]
        and materials[1][1] and materials[1][1][1]
    local centre_occupancy = occupancy[1]
        and occupancy[1][1] and occupancy[1][1][1]
    return centre_material == Enum.Material.Water
        and type(centre_occupancy) == "number"
        and centre_occupancy >= 0.5
end

--[[
Builds per-character environment tracking with a supplied profile owner.

Args:
    profiles (any): Authoritative Dungeon ProfileService for earned ranks.

Returns:
    any: Isolated service; no globally shared player state.
]]
function ScoutEnvironmentService.new(profiles: any): any
    assert(profiles)
    return setmetatable({
        _profiles = profiles,
        _characters = {},
    }, ScoutEnvironmentService)
end

--[[
Reads the same selected profile that owns the actual active avatar.

Args:
    record (any): Per-character verified Player record.

Returns:
    any?: Current selected server character or nil during session teardown.
]]
function ScoutEnvironmentService:_profile(record: any): any?
    if record.Player.Parent ~= Players
        or record.Player.Character ~= record.Character
    then
        return nil
    end
    return self._profiles:get_character(record.Player.UserId)
end

--[[
Applies one measured world-landing injury, never on an attack hit.

Args:
    record (any): Server-observed freefall speed and live Humanoid.

Returns:
    nil: Damages actual living avatar once after a sufficiently hard landing.
]]
function ScoutEnvironmentService:_landed(record: any)
    if not record.InFreefall then
        return
    end
    record.InFreefall = false
    local duration = os.clock() - record.FallStartedAt
    if duration < 0.35 or record.Humanoid.Health <= 0 then
        return
    end
    local character = self:_profile(record)
    if not character then
        return
    end
    local injury = Rules.fall_damage(
        character, record.MaxDownwardSpeed
    )
    if injury > 0 then
        record.Humanoid:TakeDamage(injury)
    end
end

--[[
Tracks actual Humanoid freefall-to-landed state transitions on the server.

Args:
    record (any): Bound original avatar and server-owned fall record.
    _previous (Enum.HumanoidStateType): Previous engine movement state.
    current (Enum.HumanoidStateType): Current engine movement state.

Returns:
    nil: Starts, resolves or cancels physical fall injury observation.
]]
function ScoutEnvironmentService:_state_changed(
    record: any, _previous: Enum.HumanoidStateType,
    current: Enum.HumanoidStateType
)
    if current == Enum.HumanoidStateType.Freefall then
        record.InFreefall = true
        record.FallStartedAt = os.clock()
        record.MaxDownwardSpeed = 0
    elseif current == Enum.HumanoidStateType.Landed then
        self:_landed(record)
    elseif current == Enum.HumanoidStateType.Dead
        or current == Enum.HumanoidStateType.Swimming
        or current == Enum.HumanoidStateType.Seated
    then
        record.InFreefall = false
    end
end

--[[
Applies actual elapsed underwater breathing time and drowning damage.

Args:
    record (any): Authenticated real avatar and accumulated server time.
    delta_seconds (number): Actual bounded time since previous water sample.

Returns:
    nil: Updates replicated oxygen and damages only truly submerged avatars.
]]
function ScoutEnvironmentService:_breathe(
    record: any, delta_seconds: number
)
    local character = self:_profile(record)
    if not character or record.Humanoid.Health <= 0 then
        return
    end
    local head = record.Character:FindFirstChild("Head")
    -- Only physical server Terrain at the actual head can remove air.
    -- Humanoid swimming state is not a prerequisite: underwater avatars
    -- may briefly still report Freefall when entering flooded caverns.
    local submerged = head and head:IsA("BasePart")
        and head_in_terrain_water(head)
    record.Oxygen = Rules.next_oxygen(
        record.Oxygen, delta_seconds, submerged == true, character
    )
    record.Character:SetAttribute(
        "DungeonMMOOxygenSeconds", record.Oxygen
    )
    if submerged and record.Oxygen <= 0 then
        record.DrowningElapsed += delta_seconds
        if record.DrowningElapsed >= DROWNING_TICK_SECONDS then
            record.DrowningElapsed -= DROWNING_TICK_SECONDS
            record.Humanoid:TakeDamage(DROWNING_DAMAGE)
        end
    else
        record.DrowningElapsed = 0
    end
end

--[[
Samples authentic vertical velocity and fixed-interval real-world air.

Args:
    record (any): Server-bound original player character.
    delta_seconds (number): Engine Heartbeat elapsed time.

Returns:
    nil: Tracks a single freefall and air reserve without client requests.
]]
function ScoutEnvironmentService:_heartbeat(
    record: any, delta_seconds: number
)
    if self._characters[record.Player] ~= record
        or record.Player.Character ~= record.Character
        or record.Humanoid.Health <= 0
    then
        return
    end
    if record.InFreefall then
        record.MaxDownwardSpeed = math.max(
            record.MaxDownwardSpeed,
            -record.Root.AssemblyLinearVelocity.Y
        )
    end
    record.WaterElapsed += math.clamp(delta_seconds, 0, 1)
    if record.WaterElapsed >= TICK_SECONDS then
        local elapsed = record.WaterElapsed
        record.WaterElapsed = 0
        self:_breathe(record, elapsed)
    end
end

--[[
Binds a live player avatar exactly once, tearing down its old event hooks.

Args:
    player (Player): Real admitted Dungeon participant.
    character (Model): Original server-owned avatar on CharacterAdded.

Returns:
    nil: Monitors live Humanoid impacts and actual terrain water exposure.
]]
function ScoutEnvironmentService:bind(
    player: Player, character: Model
)
    self:remove(player)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root or not root:IsA("BasePart") then
        return
    end
    local current = self._profiles:get_character(player.UserId)
    if not current then
        return
    end
    local record = {
        Player = player, Character = character,
        Humanoid = humanoid, Root = root,
        InFreefall = false, FallStartedAt = 0,
        MaxDownwardSpeed = 0, WaterElapsed = 0,
        DrowningElapsed = 0,
        Oxygen = Rules.max_oxygen(current),
        Connections = {},
    }
    self._characters[player] = record
    character:SetAttribute(
        "DungeonMMOOxygenSeconds", record.Oxygen
    )
    table.insert(record.Connections, humanoid.StateChanged:Connect(
        function(previous, next_state)
            self:_state_changed(record, previous, next_state)
        end
    ))
    table.insert(record.Connections, RunService.Heartbeat:Connect(
        function(delta_seconds)
            self:_heartbeat(record, delta_seconds)
        end
    ))
end

--[[
Releases the original avatar and all per-character event connections.

Args:
    player (Player): Authenticated departing or respawning player.

Returns:
    nil: Prevents stale avatar fall, drowning or lingering heartbeat work.
]]
function ScoutEnvironmentService:remove(player: Player)
    local record = self._characters[player]
    if not record then
        return
    end
    self._characters[player] = nil
    for _, connection in ipairs(record.Connections) do
        connection:Disconnect()
    end
end

return table.freeze(ScoutEnvironmentService)
