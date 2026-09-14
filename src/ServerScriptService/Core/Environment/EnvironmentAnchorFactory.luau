--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Definitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("EnvironmentAnchorDefinitions")
)

local EnvironmentAnchorFactory = {}

local FOLDER_NAME = "DungeonMMOEnvironmentAnchors"

local function ensure_folder(parent: Instance): Folder
    if parent:IsA("Folder") and parent.Name == FOLDER_NAME then
        return parent
    end

    local existing = parent:FindFirstChild(FOLDER_NAME)
    if existing and existing:IsA("Folder") then
        return existing
    end

    local folder = Instance.new("Folder")
    folder.Name = FOLDER_NAME
    folder.Parent = parent
    return folder
end

function EnvironmentAnchorFactory.create(
    parent: Instance,
    environment_id: string,
    anchor_id: string,
    cframe: CFrame,
    size: Vector3?,
    role: string?
): BasePart
    local folder = ensure_folder(parent)

    local anchor = Instance.new("Part")
    anchor.Name = string.gsub(anchor_id, "[^%w_%-]", "_")
    anchor.Anchored = true
    anchor.Transparency = 1
    anchor.Size = size or Vector3.new(2, 2, 2)
    anchor.CFrame = cframe
    anchor.CanCollide = false
    anchor.CanTouch = false
    anchor.CanQuery = true
    anchor.CastShadow = false
    anchor:SetAttribute(
        Definitions.ENVIRONMENT_ATTRIBUTE,
        environment_id
    )
    anchor:SetAttribute(
        Definitions.ANCHOR_ATTRIBUTE,
        anchor_id
    )
    anchor:SetAttribute(
        Definitions.ROLE_ATTRIBUTE,
        role or "SemanticAnchor"
    )
    anchor:SetAttribute(
        Definitions.VERSION_ATTRIBUTE,
        1
    )
    CollectionService:AddTag(anchor, Definitions.TAG)
    anchor.Parent = folder
    return anchor
end

function EnvironmentAnchorFactory.clear_generated(parent: Instance)
    local folder = parent:FindFirstChild(FOLDER_NAME)
    if folder and folder:IsA("Folder") then
        folder:Destroy()
    end
end

return table.freeze(EnvironmentAnchorFactory)
