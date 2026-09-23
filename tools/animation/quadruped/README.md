# Quadruped animation engine — first development slice

Status: **source-authored, rig-independent foundation only.**
Nothing here has been accepted as a good wolf animation or added to
DungeonMMO runtime. The test Studio session was not open when this
slice was created. Full rig import and real playback are pending.

This is the quadruped counterpart to
[the humanoid authoring tools](../humanoid/README.md), **not a copy
of R15 movements with four legs attached**. Do not reuse the earlier
blocky, welded DungeonWolfFactory placeholder as the master rig:
its hind legs use `WeldConstraint` and cannot articulate.

## Canonical project files

- [QuadrupedMotionCore.luau](QuadrupedMotionCore.luau): pure
  gait-phase/stance/swing targets for Walk and Trot, plus a
  two-segment limb IK *position* solver. These are anatomical
  targets, **not animation clips or validated bone rotations**.
- [QuadrupedRigAudit.luau](QuadrupedRigAudit.luau): read-only
  inspection of an imported candidate's connected joints,
  animation controller, four limb role mappings and paw-height
  differences. A structural PASS does not verify skin weights,
  movement or visual quality.
- [Production and acceptance roadmap](
  ../../../docs/roadmap/DungeonMMO_Quadruped_Animation_Pipeline_20260923.md):
  staging, rig selection, motion authoring, visual proof and combat.

All files live in `tools/animation/quadruped/`, **outside**
the production Rojo `src/` folder. The helper libraries must
not be enabled as combat code or published just because they
parse or return mathematically valid positions.

## Rig family and required adaptation

Start with a real standing, four-legged, *properly skinned* and
editable canine rig. An independently animated shoulder/upper,
lower limb and paw must exist on each of four legs. The spine,
pelvis, neck/head, and ideally jaw/tail should be controllable;
the original mesh proportions, fur, colors and texture must be
preserved. One authoring rig family can serve compatible
canines (wolf/dog/fox) only after a measured retarget/deformation
test. Other quadruped families—horses, cats, bears, unusual
bosses—can share the **motion engine**, but need proportion,
limb-bend and gait profiles, sometimes another master skeleton.

Both Roblox Motor6D rigs and imported skinned Bone rigs may
work, but they require **different rig-specific adapters** for
applying computed joint poses. Do not treat Bone.Transform and
Motor6D.Transform as interchangeable; rest-space calibration,
rotation axes, and Animator support have to be established
separately on the chosen master. Do not regenerate or discard
the supplied original skinning just to fit the engine.

Map these 17 anatomical roles to **unique exact descendant names**
when using `QuadrupedRigAudit.inspect(candidate, roleNameMap)`:

`Root`, `Pelvis`, `Chest`, `Neck`, `Head`,
`FrontLeftUpper`, `FrontLeftLower`, `FrontLeftPaw`,
`FrontRightUpper`, `FrontRightLower`, `FrontRightPaw`,
`HindLeftUpper`, `HindLeftLower`, `HindLeftPaw`,
`HindRightUpper`, `HindRightLower`, `HindRightPaw`.

For each actual rig, explicitly record its forward/up axes,
upper and lower segment lengths, bend directions, paw contact
locators, stance height, foot size, joint limits, Animator and
root-motion convention. Do not guess those from names.

## Engine boundaries

`QuadrupedMotionCore.sample_gait(gait, phase, stride, lift,
stance_fraction)` returns four abstract local paw targets.
A future approved-rig adapter must transform those into world
goals and solve the legs against the measured hip positions;
it must **lock stance paws in world space** while the body
moves and release them along a smooth swing arc. The pure
two-bone solver returns a reachable knee and paw point; the
adapter must calculate anatomically correct joint rotations
without stretching/deforming the mesh.

Walking and trotting are only initial core choices.
Canter, gallop, turning in place, climbing/slopes, staggering,
lunges, bites, pounces, hit and death require separate
species-calibrated authoring, transitions and real playback.
Do not equate a phase offset or a numeric foot-drift check
with visually natural movement.

A boss attack is authored **on top of the master rig** with
distinctive anticipation, stance/weight shift, launch or bite,
contact, follow-through and recovery. Roblox animation
markers may coordinate local effects, but combat target
selection, warning area and damage remain server-owned
and are not implemented by these art tools.

## No-manual-user-work development procedure

1. The assistant selects/imports a candidate source wolf in an
   isolated unpublished Studio place, keeping an untouched
   backup. Do not use the existing welded wolf placeholder.
2. The assistant measures/matches the 17 role names and runs
   the read-only audit. A missing or deformed paw, floating
   rest stance or weak skin weights blocks approval regardless
   of the numeric audit result.
3. The assistant adds the correct rig adapter and authors
   **idle → one walk cycle → idle**. Visually check side, front,
   rear and in-game camera as well as foot/ground contact.
   Compare paw deformation and joint bending throughout.
4. Only after an approved walking cycle should it author
   trot/run, turn, basic bite, heavy lunge, hit, death and
   eventually mini-boss/boss-specific attacks. Save independent
   editable clips and retarget only to compatible canine rigs.
5. Test actual Studio Animator playback, save before/after
   previews and a reusable rig/profile/clip backup in GitHub
   (or source-controlled text) while keeping binary art in an
   approved asset location. **No publish and no live gameplay
   integration until the user accepts the motion.**

The user need only assess the video/GIF. Blender, bone posing,
script editing and rig calibration are the assistant's work.

## Known previous failure modes to block

Earlier Frostfang trials showed unnatural leg movement,
floating/clipping, a deformed front paw and rigs that merely
wiggled the body. A model exported without errors does **not**
demonstrate the four feet contacting the ground or the skin
weights following the paw correctly. Do not mark a quadruped
master as usable until a real idle/walk/turn/bite transition
on the original textured mesh has been reviewed in Studio.
