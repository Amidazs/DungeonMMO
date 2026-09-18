--!strict
local DungeonBossSpawnGuard = {}

local CLAIMS_FOLDER_NAME = "DungeonBossSpawnClaims"
local LEGACY_ENCOUNTER_ID = "__LegacyBoss"

local function claim_folder(root: Instance): Folder
    local existing = root:FindFirstChild(CLAIMS_FOLDER_NAME)
    if existing and existing:IsA("Folder") then
        return existing
    end

    if existing then
        existing:Destroy()
    end

    local folder = Instance.new("Folder")
    folder.Name = CLAIMS_FOLDER_NAME
    folder.Parent = root
    return folder
end

local function normalized_encounter_id(encounter_id: string?): string
    if type(encounter_id) == "string" and encounter_id ~= "" then
        return encounter_id
    end
    return LEGACY_ENCOUNTER_ID
end

function DungeonBossSpawnGuard.claim(
    root: Instance,
    session_id: string,
    encounter_id: string?
): boolean
    if session_id == "" then
        return false
    end

    local id = normalized_encounter_id(encounter_id)
    local folder = claim_folder(root)
    local existing = folder:FindFirstChild(id)

    if existing and existing:IsA("StringValue") then
        if existing.Value == session_id then
            return false
        end

        existing.Value = session_id
        return true
    end

    if existing then
        existing:Destroy()
    end

    local claim = Instance.new("StringValue")
    claim.Name = id
    claim.Value = session_id
    claim.Parent = folder
    return true
end

function DungeonBossSpawnGuard.release(
    root: Instance,
    session_id: string,
    encounter_id: string?
): boolean
    local folder = root:FindFirstChild(CLAIMS_FOLDER_NAME)
    if not folder or not folder:IsA("Folder") then
        return false
    end

    local id = normalized_encounter_id(encounter_id)
    local claim = folder:FindFirstChild(id)
    if not claim or not claim:IsA("StringValue") then
        return false
    end

    if claim.Value ~= session_id then
        return false
    end

    claim:Destroy()
    return true
end

return table.freeze(DungeonBossSpawnGuard)
