# DungeonMMO v2.46 — C4 combat formula reference

Date: 24 September 2026.
Branch: `wip/phase-4-test-hud-integration-v1`.
Previous: [v2.45](
DungeonMMO_Roadmap_v2_45_C4_Derived_Stat_Engine_20260924.md).

The shared source layer now includes the reviewed Chronicle 4
physical damage, magical damage, instant-heal, normal attack delay,
skill cast-speed scaling, hit-chance table and magic level-resistance
arithmetic from the same pinned C4 server source.

This resolves the key ambiguity behind the user's request to keep
the same C4 skill values: **skill power is kept as skill power and
fed into the original formula**. It is not copied into direct Roblox
HP damage. For example, using the source naked level-30 Human
Warrior/Knight values, Power Smash-style power 90 produces 70 damage
before shots/random/vulnerability/item/passive modifiers. C4 magic
damage uses `91 * sqrt(MAtk) / MDef * skillPower`. Reviewed instant
heal effect power is direct heal amount in this C4 implementation,
with Spiritshot x1.3 or Blessed Spiritshot x1.5.

The module is deterministic and accepts the already-resolved
multipliers that the full C4 calculator would normally supply.
Equipment, armor/jewelry, mastery/buff calculator ordering, weapon
random range, elemental/race vulnerabilities, PvP modifiers and
server configuration caps are not guessed. They remain the next
source layer before live runtime switching.

Next implementation sequence:
1. C4 equipment and Calculator modifier ordering;
2. complete all current level<=30 skill source rows from C4
   `skill_trees.sql` and exact skill XML;
3. server-authoritative C4 character snapshot combining class,
   items, passives and buffs;
4. coherent profile/health/mana/CP/HUD migration;
5. swap each current skill to C4 source power/MP/effect semantics,
   then targeted and cross-class real client regressions.

No production damage or skill numbers changed in this reference
commit. No main merge, public publish or production save mutation.
