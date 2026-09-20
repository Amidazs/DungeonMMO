--!strict
-- Source-only inspection of the actual unpublished TEST build DataModel.
-- Run via Studio RunScript against the Temple publish or Base sync build;
-- never publishes, modifies release flags or connects to a DataStore.
assert(game.PlaceId==0 and game.GameId==0,
    "HUD composition check must run only in an unpublished local place.")
local RS=game:GetService("ReplicatedStorage")
local SSS=game:GetService("ServerScriptService")
local SPS=game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local shared=RS.Core.Shared
for _,name in ipairs({"UiTheme","UiComponents","UiOrnament",
    "DungeonTestPlaceholderRelease","DungeonTestPlaceholderLayouts"}) do
    assert(shared:FindFirstChild(name),
        "Missing shared HUD or TEST layout module: "..name)
end
local core=SPS:WaitForChild("Core")
for _,name in ipairs({"ProfileHud","HudCommandMenu",
    "HudWindowController","InventoryPanel","SkillsMenu",
    "CoreGuiPresentation"}) do
    assert(core:FindFirstChild(name),
        "Missing restored shared HUD code: "..name)
end
local is_dungeon=SSS:FindFirstChild("Dungeon")~=nil
local is_base=SSS:FindFirstChild("Base")~=nil
assert(is_dungeon~=is_base,"Expected exactly one gameplay server root")
if is_dungeon then
    local dungeon=SPS:FindFirstChild("Dungeon")
    local combat=SPS:FindFirstChild("Combat")
    assert(dungeon and dungeon:FindFirstChild("DungeonUi")
        and combat and combat:FindFirstChild("CombatHotbar"),
        "TEST Temple lost redesigned dungeon UI or six-slot combat hotbar")
    assert(SSS:GetAttribute("DungeonMMOEnvironment")=="TEST",
        "TEST Temple lost TEST DataStore environment")
    assert(SSS.Dungeon:FindFirstChild("DungeonPlaceholderPhysicalContent"),
        "TEST Temple lost physical placeholder builder")
    print("[Phase4 Restored HUD Composition] TEMPLE_HUD_AND_DEPTH_CONTENT_PASS")
else
    local base=SPS:FindFirstChild("Base")
    assert(base and base:FindFirstChild("BaseUi")
        and base:FindFirstChild("GuildPanel")
        and base:FindFirstChild("MarketPanel"),
        "TEST Base lost expedition, guild or market UI")
    assert(not SPS:FindFirstChild("Combat"),
        "Lobby sync must not inject Dungeon-only combat client scripts")
    local skill_data=RS:FindFirstChild("Combat")
    skill_data=skill_data and skill_data:FindFirstChild("Shared")
    assert(skill_data and skill_data:FindFirstChild("SkillDefinitions"),
        "Lobby sync lacks Combat.Shared.SkillDefinitions for SkillsMenu")
    print("[Phase4 Restored HUD Composition] LOBBY_COMBAT_SKILL_DEFINITIONS_PASS")
    print("[Phase4 Restored HUD Composition] LOBBY_HUD_SYNC_ONLY_PASS")
end
print("[Phase4 Restored HUD Composition] RESTORED_HUD_SOURCE_PASS")
