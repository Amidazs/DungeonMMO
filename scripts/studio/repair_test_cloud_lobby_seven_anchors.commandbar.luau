--!strict
-- Guarded repair for seven missing anchors in the EXISTING authored TEST Lobby.
-- Roblox Studio COMMAND BAR, EDIT mode only. Never in Play/server runtime.
-- IMPORTANT: Save a rollback of the ACTUAL cloud place (File > Save to File)
-- before setting APPLY = true. Preview makes NO edits.
local APPLY = false

local PLACE_ID = 134132328219009
local UNIVERSE_ID = 10765241947
local RunService = game:GetService("RunService")
assert(game.PlaceId == PLACE_ID and game.GameId == UNIVERSE_ID,
    "Open the EXISTING cloud TEST Lobby, not a local file or Dungeon.")
assert(not RunService:IsRunning(), "Stop Play mode before repairing anchors.")

local Workspace = game:GetService("Workspace")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local CS = game:GetService("CollectionService")
local Shared = RS:WaitForChild("Core"):WaitForChild("Shared")
local defs = require(Shared:WaitForChild("EnvironmentAnchorDefinitions"))
local Environment = SSS:WaitForChild("Core"):WaitForChild("Environment")
local factory = require(Environment:WaitForChild("EnvironmentAnchorFactory"))
local resolver = require(Environment:WaitForChild("EnvironmentAnchorResolver"))
local placement = require(Environment:WaitForChild("CandidateAnchorPlacement"))

local expected = {
    ["Base.Trainer.Rogue"] = true,
    ["Base.Service.Bank"] = true,
    ["Base.Service.Travel"] = true,
    ["Base.Travel.Market"] = true,
    ["Base.Travel.Dwarves"] = true,
    ["Base.Travel.Portals"] = true,
    ["Base.Travel.Orcs"] = true,
}
local existing = {}
for _,obj in ipairs(CS:GetTagged(defs.TAG)) do
    if obj:IsA("BasePart") and obj:IsDescendantOf(Workspace)
        and obj:GetAttribute(defs.ENVIRONMENT_ATTRIBUTE) == "Base"
    then
        local id = obj:GetAttribute(defs.ANCHOR_ATTRIBUTE)
        if type(id) == "string" then
            existing[id] = existing[id] or {}
            table.insert(existing[id],obj)
        end
    end
end
local missing = {}
for _,id in ipairs(defs.BASE.Required) do
    local matches = existing[id] or {}
    assert(#matches <= 1, "[Seven Anchor Repair] Duplicate required: "..id)
    if #matches == 0 then
        assert(expected[id], "[Seven Anchor Repair] Unexpected missing anchor "
            ..id.."; no changes were made.")
        table.insert(missing,id)
    end
end
table.sort(missing)
local function single_anchor(id: string): BasePart
    local list = existing[id]
    assert(list and #list == 1,
        "[Seven Anchor Repair] Expected exactly one existing "..id)
    return list[1]
end
local function named_object(name: string): Instance
    local scene=Workspace:FindFirstChild("Scene")
    assert(scene, "[Seven Anchor Repair] Authored Scene not found")
    local matches={}
    for _,obj in ipairs(scene:GetDescendants()) do
        if obj.Name==name and (obj:IsA("Model") or obj:IsA("BasePart")) then
            table.insert(matches,obj)
        end
    end
    assert(#matches==1,
        "[Seven Anchor Repair] Landmark "..name.." must be unique; found "
        ..#matches..". No changes made.")
    return matches[1]
end
local function bottom_or_top(landmark: Instance, on_top: boolean): CFrame
    local cf,size
    if landmark:IsA("Model") then
        cf,size=landmark:GetBoundingBox()
    else
        cf,size=landmark.CFrame,landmark.Size
    end
    -- Positions from GEOMETRY bounds, never the often-misleading model pivot.
    local local_y = (if on_top then 0.5 else -0.5) * size.Y
    local world = cf * CFrame.new(0,local_y,0)
    return world + Vector3.new(0,if on_top then 1 else 2,0)
end
local locations = {}
local sources = {}
local roles = {
    ["Base.Trainer.Rogue"] = "Trainer",
    ["Base.Service.Bank"] = "Service",
    ["Base.Service.Travel"] = "Service",
    ["Base.Travel.Market"] = "TravelDestination",
    ["Base.Travel.Dwarves"] = "TravelDestination",
    ["Base.Travel.Portals"] = "TravelDestination",
    ["Base.Travel.Orcs"] = "TravelDestination",
}
local function plan(id: string, cf: CFrame, source: string)
    assert(typeof(cf)=="CFrame", "Invalid placement for "..id)
    locations[id]=cf
    sources[id]=source
end
local function horizontal(a: Vector3,b: Vector3): number
    local d=a-b
    return Vector3.new(d.X,0,d.Z).Magnitude
end

-- Calculate everything before editing even one anchor. Existing labelled
-- placeholders are preserved; the new canonical bank/travel anchors coexist.
if expected["Base.Trainer.Rogue"] and #((existing["Base.Trainer.Rogue"]) or {}) == 0 then
    local training=single_anchor("Base.TrainingArea")
    plan("Base.Trainer.Rogue",training.CFrame * CFrame.new(6,2,0),
        training:GetFullName().." + (6,2,0)")
end
if #((existing["Base.Service.Bank"]) or {}) == 0 then
    local obj=single_anchor("Base.Service.BankPlaceholder")
    plan("Base.Service.Bank",obj.CFrame,obj:GetFullName())
end
if #((existing["Base.Service.Travel"]) or {}) == 0 then
    local obj=single_anchor("Base.Service.TravelPlaceholder")
    plan("Base.Service.Travel",obj.CFrame,obj:GetFullName())
end
if #((existing["Base.Travel.Market"]) or {}) == 0 then
    -- The current authored arrival marker is in the central market.
    -- Verify it is close to the REAL market furniture geometry.
    local arrival=single_anchor("Base.ArrivalFromTemple")
    local furniture=named_object("Market_SocialFurniture")
    local furniture_cf=bottom_or_top(furniture,false)
    assert(horizontal(arrival.Position,furniture_cf.Position)<=65,
        "[Seven Anchor Repair] Arrival not near real Market geometry; "
        .."review location instead of blindly creating the destination.")
    plan("Base.Travel.Market",arrival.CFrame,
        arrival:GetFullName().." (near "..furniture:GetFullName()..")")
end
if #((existing["Base.Travel.Dwarves"]) or {}) == 0 then
    local obj=named_object("FastTravel_Dwarf_Surface_Mine_dais")
    plan("Base.Travel.Dwarves",bottom_or_top(obj,true),obj:GetFullName())
end
if #((existing["Base.Travel.Orcs"]) or {}) == 0 then
    local obj=named_object("FastTravel_Orc_Farm_dais")
    plan("Base.Travel.Orcs",bottom_or_top(obj,true),obj:GetFullName())
end
if #((existing["Base.Travel.Portals"]) or {}) == 0 then
    local portal=named_object("Portal_02")
    -- Retain the existing candidate profile's 10-stud offset from portal;
    -- its bounds give the real elevated portal location, not model pivot.
    local cf=placement.resolve(portal,{
        UseBounds=true,HeightFraction=0.55,Offset=CFrame.new(0,0,10),
    })
    assert(cf,"[Seven Anchor Repair] Portal bounds unavailable")
    assert(horizontal(cf.Position,single_anchor("Base.TemplePortal").Position)<40,
        "[Seven Anchor Repair] New portal landing far from existing Temple portal")
    plan("Base.Travel.Portals",cf,portal:GetFullName().." bounds +10 studs")
end

print("[Seven Anchor Repair] Missing required anchors: "
    .. (#missing==0 and "none" or table.concat(missing,", ")))
print("[Seven Anchor Repair] Mode: "..(if APPLY then "APPLY" else "PREVIEW"))
for _,id in ipairs(missing) do
    local cf=assert(locations[id],"Unplanned missing anchor: "..id)
    print("[Seven Anchor Repair] "..id.." @ "
        ..tostring(cf.Position).." from "..sources[id])
end
if not APPLY then
    print("[Seven Anchor Repair] PREVIEW_COMPLETE — ZERO CHANGES.")
    print("[Seven Anchor Repair] Inspect the printed locations; save the "
        .."EXISTING cloud Lobby to a dated .rbxl BEFORE changing APPLY=true.")
else
    -- A failed preflight raises above, before entering this branch.
    local created={}
    local ok,reason=pcall(function()
        for _,id in ipairs(missing) do
            local part=factory.create(Workspace,"Base",id,
                locations[id],Vector3.new(3,5,3),roles[id])
            table.insert(created,part)
            print("[Seven Anchor Repair] CREATED "..id.." "
                ..part:GetFullName())
        end
        local result=resolver.resolve(Workspace,defs.BASE)
        assert(result.ok,"Required contract still invalid: "
            ..tostring(result.reason)..":"..tostring(result.anchor_id))
    end)
    if not ok then
        for _,part in ipairs(created) do
            part:Destroy()
        end
        error("[Seven Anchor Repair] Validation failed; only the new "
            .."anchors from THIS invocation were rolled back: "..tostring(reason))
    end
    print("[Seven Anchor Repair] ALL_REQUIRED_BASE_ANCHORS_VALID")
    print("[Seven Anchor Repair] Created "..#created
        .." missing markers; rerunning is safe and makes no duplicates.")
    local combat=RS:FindFirstChild("Combat")
    local shared=combat and combat:FindFirstChild("Shared")
    if shared and shared:FindFirstChild("SkillDefinitions") then
        print("[Seven Anchor Repair] COMBAT_SKILLS_PRESENT")
    else
        warn("[Seven Anchor Repair] Missing Combat.Shared.SkillDefinitions; "
            .."sync the updated test-lobby-sync.project.json before publishing.")
    end
    print("[Seven Anchor Repair] Stop here: TEST in Studio Play and "
        .."inspect travel destinations before publishing existing cloud Lobby.")
end
