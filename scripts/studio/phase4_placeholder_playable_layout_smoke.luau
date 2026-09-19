--!strict
-- Source-only invariant check on an unpublished TEMP Dungeon build.
-- Never changes release toggles or turns the runtime on in production.
assert(game.PlaceId == 0 and game.GameId == 0, "TEMP place only")
local W = game:GetService("Workspace")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Catalog = require(RS.Core.Shared.DungeonRuntimeContentCatalog)
local Layouts = require(SSS.Dungeon.DungeonRoomLayoutDefinitions)
local Difficulties = require(RS.Core.Shared.DungeonDifficultyDefinitions)
local defs = require(RS.Core.Shared.DungeonDefinitions)
local function must(ok, label)
    assert(ok, "[Phase4 Playable Layout] " .. label)
end
-- Existing locked behavior remains intact without all three opt-in flags.
for _, id in ipairs({"TestDungeon","AbandonedMine"}) do
    must(defs.get(id).OptionalBossRuntimeEnabled == false,
        id .. " production optional release lock")
    for depth = 2, 4 do
        local layout_id = "Depth" .. depth
        must(Catalog.get_layout(id,layout_id)==nil,
            id.." production high-depth catalog must remain unregistered")
        must(Layouts.get(id,layout_id)==nil,
            id.." high-depth must fail closed without opt-in")
        must(Difficulties.get(id,layout_id).RuntimeReleaseEnabled==false,
            id.." higher depth difficulty must remain locked")
    end
end
W:SetAttribute("DungeonMMOEnvironmentMode","Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled",true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled",true)
for _,id in ipairs({"TestDungeon","AbandonedMine"}) do
    local d1 = Layouts.get(id,"Depth1")
    must(d1 and d1.Slots.EventArena==nil and d1.Slots.SecretArena==nil,
        id.." optional encounters remain dormant without distinct opt-in")
    W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled",true)
    d1=Layouts.get(id,"Depth1")
    must(d1.Slots.EventArena.SupportsBoss==true
        and d1.Slots.SecretArena.SupportsBoss==true,
        id.." optional boss physical anchors missing")
    W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled",false)
    for depth=2,4 do
        local difficulty_id="Depth"..depth
        local layout=Layouts.get(id,difficulty_id)
        local difficulty=Difficulties.get(id,difficulty_id)
        must(layout and layout.Id==difficulty.LayoutId,
            id.." missing "..difficulty_id.." placeholder layout")
        local count=0
        for slot_id,room in pairs(layout.Slots) do
            count+=1
            must(type(room.TriggerAnchor)=="string"
                and type(room.CheckpointAnchor)=="string",
                id.." "..difficulty_id.." "..slot_id.." missing anchors")
        end
        must(count==depth+2
            and #difficulty.EncounterSequence==count,
            id.." "..difficulty_id.." room count mismatch")
        for _,encounter in ipairs(difficulty.EncounterSequence) do
            local slot=layout.Slots[encounter.RoomSlotId]
            must(slot~=nil,id.." missing encounter physical slot")
            must((encounter.ExecutorId=="Boss" and slot.SupportsBoss)
                or (encounter.ExecutorId=="CombatPack" and slot.SupportsCombat),
                id.." "..encounter.Id.." physical capability mismatch")
        end
        if depth==4 then
            for _,index in ipairs({2,4,5,6}) do
                must(layout.Slots["Room"..index].SupportsBoss,
                    id.." Depth4 missing legacy/final boss location")
            end
        end
        print("[Phase4 Playable Layout] PASS "..id.." "..difficulty_id
            .." rooms="..count)
    end
end
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled",false)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled",false)
for _,id in ipairs({"TestDungeon","AbandonedMine"}) do
    must(Layouts.get(id,"Depth4")==nil,
        id.." placeholder physical layout leaked after opt-out")
end
print("[Phase4 Playable Layout] PASS explicit TEMP opt-in and release isolation")
