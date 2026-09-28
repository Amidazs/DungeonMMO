--!strict
-- Player-facing Adventure dialogue kept separate from quest authority.

local Narratives = {}

local DEFINITIONS = table.freeze({
    WorldrootRelic = table.freeze({
        Speaker = "Worldroot Keeper",
        Start = table.freeze({
            "The roots beneath the village have gone restless.",
            "Something in the old Temple is answering them. "
                .. "Find what is buried there and bring back proof.",
        }),
        Progress = table.freeze({
            "The Temple still holds the answer. Follow the disturbance "
                .. "until you can return with proof.",
        }),
        Ready = table.freeze({
            "That relic carries the same pulse I felt beneath the tree.",
            "Keep it close. Whatever woke below us has only begun to stir.",
        }),
        Complete = table.freeze({
            "The Worldroot is calmer, but the disturbance has spread "
                .. "beyond the Temple.",
        }),
    }),

    ForestWolfBounty = table.freeze({
        Speaker = "Huntmaster",
        Start = table.freeze({
            "The wolves near the Worldroot are becoming too bold.",
            "Thin the pack before they start testing the village paths.",
        }),
        Progress = table.freeze({
            "Two wolves will be enough to break the pack's confidence.",
        }),
        Ready = table.freeze({
            "Good. The paths should be safer for a while.",
        }),
        Complete = table.freeze({
            "The pack has pulled back from the Worldroot.",
        }),
    }),

    MarauderCaptainBounty = table.freeze({
        Speaker = "Village Captain",
        Start = table.freeze({
            "The Temple raiders keep regrouping around their captain.",
            "Bring the captain down and their next attack will lose "
                .. "its teeth.",
        }),
        Progress = table.freeze({
            "The captain is still active inside the Temple.",
        }),
        Ready = table.freeze({
            "Their captain is gone. That buys the village breathing room.",
        }),
        Complete = table.freeze({
            "The Temple raiders are scattered for now.",
        }),
    }),

    HiddenWardDiscovery = table.freeze({
        Speaker = "Temple Archivist",
        Start = table.freeze({
            "Old survey notes mention a wall in the Temple that is not "
                .. "always a wall.",
            "Look for a faded stone panel after the first chamber. "
                .. "If it responds, search whatever lies behind it.",
        }),
        Progress = table.freeze({
            "The panel should reveal a concealed alcove. Anything hidden "
                .. "inside may explain why the Temple was sealed.",
        }),
        Ready = table.freeze({
            "A ward fragment. So the builders really did hide protected "
                .. "spaces behind the visible halls.",
            "Remember that. Not every wall in an old ruin is merely a wall.",
        }),
        Complete = table.freeze({
            "You now know to watch for hidden mechanisms in future ruins.",
        }),
    }),

    MineEchoes = table.freeze({
        Speaker = "Mine Warden",
        Start = table.freeze({
            "The abandoned mine has started carrying voices again.",
            "Clear a path through it and find out whether the trouble "
                .. "below is connected to the Temple.",
        }),
        Progress = table.freeze({
            "The lower mine is still unsafe. Finish the expedition "
                .. "before we send anyone else down there.",
        }),
        Ready = table.freeze({
            "So the Mine is disturbed too. Two ruins, one pattern.",
            "We need a proper survey before we decide what it means.",
        }),
        Complete = table.freeze({
            "The Mine route is open enough for a deeper investigation.",
        }),
    }),

    RuinSurvey = table.freeze({
        Speaker = "Expedition Pathfinder",
        Start = table.freeze({
            "We need more than stories from the entrance.",
            "Reach the inner approach of both the Temple and the Mine. "
                .. "Compare where the corruption becomes strongest.",
        }),
        Progress = table.freeze({
            "Survey both inner approaches. The pattern matters more "
                .. "than another body count.",
        }),
        Ready = table.freeze({
            "The disturbance strengthens at the same depth in both sites.",
            "That is too deliberate to be chance.",
        }),
        Complete = table.freeze({
            "The expedition now has a reliable map of the shared anomaly.",
        }),
    }),

    MineSurveyorEscort = table.freeze({
        Speaker = "Survey Corps",
        Start = table.freeze({
            "One of our surveyors was cut off beyond the first mine chamber.",
            "Find them and guide them forward. They know the route, "
                .. "but they will not survive it alone.",
        }),
        Progress = table.freeze({
            "Stay close enough that the surveyor can keep moving. "
                .. "They will wait before an unsafe chamber.",
        }),
        Ready = table.freeze({
            "The surveyor made it through. Their notes will save us "
                .. "from mapping those tunnels blind.",
        }),
        Complete = table.freeze({
            "The rescued surveyor has returned to the expedition roster.",
        }),
    }),

    CorruptedForemanBounty = table.freeze({
        Speaker = "Mine Warden",
        Start = table.freeze({
            "The corrupted foreman is still commanding the deepest crew.",
            "End that command before the mine becomes organised against us.",
        }),
        Progress = table.freeze({
            "The foreman still controls the deepest chamber.",
        }),
        Ready = table.freeze({
            "Without the foreman, the corruption has lost its organiser.",
        }),
        Complete = table.freeze({
            "The lower mine is quieter without its corrupted overseer.",
        }),
    }),

    TempleResonancePuzzle = table.freeze({
        Speaker = "Temple Archivist",
        Start = table.freeze({
            "The fragment you found was only part of the old warding system.",
            "Recover a resonance shard, then use it on the three sealed "
                .. "runes after the second chamber is secure.",
        }),
        Progress = table.freeze({
            "The old inscription gives the order: Moon, Root, Flame.",
            "A wrong attunement will reset the sequence.",
        }),
        Ready = table.freeze({
            "Moon, Root, Flame. The seal answered exactly as the archive "
                .. "described.",
            "Whatever built this place expected someone to know the order.",
        }),
        Complete = table.freeze({
            "The Resonant Seal has been restored and its pattern recorded.",
        }),
    }),

    FractureTrail = table.freeze({
        Speaker = "Temple Archivist",
        Start = table.freeze({
            "The restored seal exposed a fracture running beyond the Temple.",
            "Trace it through the inner approach, then clear the Mine again "
                .. "where the same resonance gathers.",
        }),
        Progress = table.freeze({
            "Follow the Temple fracture first, then purge its echo "
                .. "inside the Mine.",
        }),
        Ready = table.freeze({
            "The two sites are linked. The fracture is carrying resonance "
                .. "between them rather than forming independently.",
        }),
        Complete = table.freeze({
            "The expedition now treats the Temple and Mine as one mystery.",
        }),
    }),

    TempleWardDefense = table.freeze({
        Speaker = "Temple Archivist",
        Start = table.freeze({
            "The seal can be stabilised, but only while the next chamber "
                .. "is being secured.",
            "Hold the Resonance Ward. Do not abandon its field for long, "
                .. "or the attunement will collapse and must be restarted.",
        }),
        Progress = table.freeze({
            "Stay inside the ward while the chamber is contested. "
                .. "A brief step away is safe; leaving it too long is not.",
        }),
        Ready = table.freeze({
            "The ward held through the fighting. That is the first time "
                .. "we have stabilised the Temple instead of merely "
                .. "surviving it.",
        }),
        Complete = table.freeze({
            "The Resonance Ward is stable and the method can be repeated.",
        }),
    }),

    DungeonBossHunt = table.freeze({
        Speaker = "Village Captain",
        Start = table.freeze({
            "The Temple captain and the corrupted foreman are the two "
                .. "strongest organisers left in the released routes.",
            "Break both commands before they can coordinate another push.",
        }),
        Progress = table.freeze({
            "Both leaders must fall before the chain is truly broken.",
        }),
        Ready = table.freeze({
            "Both commands are broken. The expeditions finally have room "
                .. "to operate without an organised counterattack.",
        }),
        Complete = table.freeze({
            "The released routes are no longer under coordinated command.",
        }),
    }),

    ExpeditionProvisioning = table.freeze({
        Speaker = "Expedition Quartermaster",
        Start = table.freeze({
            "We are burning through supplies faster than the workshops "
                .. "can replace them.",
            "Complete both launch expeditions and bring back what the crews "
                .. "need for the next push.",
        }),
        Progress = table.freeze({
            "We still need a successful Temple run and a successful "
                .. "Mine run before the next expedition can leave.",
        }),
        Ready = table.freeze({
            "That will keep the next crews equipped. Take your share "
                .. "before the rest goes into expedition stores.",
        }),
        Complete = table.freeze({
            "The next expedition has enough supplies to depart.",
        }),
    }),
})

--[[
Returns one player-facing Adventure narrative.

Args:
    quest_id (string): Stable Adventure quest identifier.

Returns:
    any?: Frozen narrative definition when the quest has presentation text.
]]
function Narratives.get(quest_id: string): any?
    return DEFINITIONS[quest_id]
end

--[[
Returns every player-facing Adventure narrative.

Args:
    None.

Returns:
    any: Frozen quest-id keyed narrative catalogue.
]]
function Narratives.all(): any
    return DEFINITIONS
end

return table.freeze(Narratives)
