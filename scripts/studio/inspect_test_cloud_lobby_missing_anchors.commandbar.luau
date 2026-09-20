--!strict
-- READ ONLY. Run in Command Bar, Edit mode, existing TEST Lobby cloud place.
-- No Instances, tags, properties, scripts, profiles or DataStores are changed.
assert(game.PlaceId == 134132328219009 and game.GameId == 10765241947,
    "Open the existing TEST Lobby cloud place, not a local or Dungeon build.")
assert(not game:GetService("RunService"):IsRunning(),
    "Stop Play mode before inspecting the authored cloud lobby.")
local CS=game:GetService("CollectionService")
local RS=game:GetService("ReplicatedStorage")
local defs=require(RS:WaitForChild("Core"):WaitForChild("Shared")
    :WaitForChild("EnvironmentAnchorDefinitions"))
local relevant={
    ["Base.Trainer.Rogue"]=true, ["Base.TrainingArea"]=true,
    ["Base.Service.Bank"]=true, ["Base.Service.Travel"]=true,
    ["Base.Service.Progression"]=true, ["Base.TemplePortal"]=true,
    ["Base.Travel.Market"]=true, ["Base.Travel.Dwarves"]=true,
    ["Base.Travel.Portals"]=true, ["Base.Travel.Orcs"]=true,
}
print("[Lobby Location Audit] ===== CURRENT SEMANTIC ANCHORS =====")
for _,part in ipairs(CS:GetTagged(defs.TAG)) do
    if part:IsA("BasePart") and part:IsDescendantOf(workspace)
        and part:GetAttribute(defs.ENVIRONMENT_ATTRIBUTE)=="Base" then
        local id=part:GetAttribute(defs.ANCHOR_ATTRIBUTE)
        if relevant[id] or (type(id)=="string"
            and (string.find(id,"Bank",1,true)
                or string.find(id,"Travel",1,true)
                or string.find(id,"Trainer",1,true))) then
            print("[Lobby Location Audit] ANCHOR "..tostring(id)
                .." pos="..tostring(part.Position)
                .." path="..part:GetFullName())
        end
    end
end
print("[Lobby Location Audit] ===== BANK PLACEHOLDER AND TRAVEL/PORTAL/MARKET OBJECTS =====")
local wanted={
    "bankplaceholder", "rogue", "trainer", "trainingarea", "fasttravel",
    "travelgem", "travel_gem", "portal_", "portal hub", "portals",
    "market_social", "marketstall", "market_square", "marketplaza",
    "auction", "orc_farm", "dwarf_surface", "dwarfsurface",
    "dwarf_cavern", "dwarfcavern",
}
local candidates={}
for _,obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") or obj:IsA("BasePart") then
        local name=string.lower(obj.Name)
        local matches=false
        for _,word in ipairs(wanted) do
            if string.find(name,word,1,true) then
                matches=true
                break
            end
        end
        if matches then
            -- Only report named root models and standalone parts; exclude
            -- meshes beneath the same named model and collision duplicates.
            local parent=obj.Parent
            local named_parent=parent and parent:IsA("Model")
                and string.find(string.lower(parent.Name),name,1,true)
            local collision=string.find(obj:GetFullName(),"LobbyCollision",1,true)
            if not collision and not named_parent then
                table.insert(candidates,obj)
            end
        end
    end
end
table.sort(candidates,function(a,b)
    return a:GetFullName()<b:GetFullName()
end)
local total=0
for _,obj in ipairs(candidates) do
    if total>=65 then
        print("[Lobby Location Audit] LIMIT REACHED: "
            ..tostring(#candidates-65).." remaining candidates omitted")
        break
    end
    local center,size
    if obj:IsA("Model") then
        local ok,cframe,extent=pcall(function()
            return obj:GetBoundingBox()
        end)
        if ok then center=cframe.Position;size=extent end
    else
        center=obj.Position
        size=obj.Size
    end
    if center then
        print("[Lobby Location Audit] OBJECT "
            ..obj:GetFullName()
            .." geometry_center="..tostring(center)
            .." bounds="..tostring(size))
        total+=1
    end
end
print("[Lobby Location Audit] READ_ONLY_COMPLETE. "
    .."Send the ANCHOR and OBJECT lines; no map changes were made.")
