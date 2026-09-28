--!strict
-- Shared copy for lightweight new-player tutorial presentation.

local TutorialDefinitions = {}

TutorialDefinitions.FIRST_ADVENTURE_ID = "WorldrootRelic"

TutorialDefinitions.BASE_STEPS = table.freeze({
    table.freeze({
        Id = "Welcome",
        Title = "Welcome to DungeonMMO",
        Text = "Move with WASD, jump with Space, and use the mouse to look "
            .. "around. This tutorial will guide you to your first Adventure.",
        ButtonText = "Continue",
    }),
    table.freeze({
        Id = "WorldrootKeeper",
        Title = "Find the Worldroot Keeper",
        Text = "Quest givers are spread around the hub. Follow the tutorial "
            .. "marker to the Worldroot Keeper and use the Talk prompt.",
        ButtonText = "I found them",
    }),
    table.freeze({
        Id = "AcceptAdventure",
        Title = "Accept your first Adventure",
        Text = "Read the quest conversation, then choose Accept Quest. "
            .. "Adventure progress and rewards are verified by the server.",
        ButtonText = "Waiting for quest",
    }),
    table.freeze({
        Id = "PartyAndPortal",
        Title = "Party up, then enter the Temple",
        Text = "Follow the shimmering trail to the Temple entrance. Choose Create Party, invite your "
            .. "friend, and have them Accept. Both players should press Ready. "
            .. "The party leader selects Depth 1 and starts the dungeon. "
            .. "You can also enter solo.",
        ButtonText = "Continue",
    }),
    table.freeze({
        Id = "CombatAndHud",
        Title = "Combat and HUD",
        Text = "LMB: attack  |  RMB: block/parry  |  Left Shift: dodge\n"
            .. "Left Ctrl: view lock  |  1-6: skills\n"
            .. "I: inventory  |  K: skills  |  J: guild\n\n"
            .. "Stay together, watch world prompts, and check suspicious "
            .. "walls: hidden rooms can exist.",
        ButtonText = "Finish Tutorial",
    }),
})

TutorialDefinitions.DUNGEON_TITLE = "First Expedition"

TutorialDefinitions.DUNGEON_TEXT =
    "Stay together and clear each room before moving on.\n\n"
    .. "LMB attack  |  RMB block/parry  |  Left Shift dodge\n"
    .. "Left Ctrl view lock  |  1-6 skills\n\n"
    .. "Room clears update checkpoints. A living teammate can keep the run "
    .. "alive while the other recovers. Watch world prompts and objective "
    .. "feedback: some ruins contain hidden mechanisms and secret spaces."

return table.freeze(TutorialDefinitions)
