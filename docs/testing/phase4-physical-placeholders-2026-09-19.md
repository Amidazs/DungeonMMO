# Phase 4 replaceable physical placeholders — 19 September 2026

Branch: wip/phase-4-event-secret-policy-v1
Authoring checkpoint: 9dd635d8bb9a699900aa69c12d9e2ba178afde84
Status: EDITOR-READY BLOCKOUTS; NOT PHYSICAL GAMEPLAY RELEASE.

## What is delivered

- **Editable Roblox Studio scene:** `content/placeholder/DungeonMMO_PhysicalBlockouts_v1.rbxlx`.
  Open this standalone .rbxlx locally in Studio to inspect or replace
  the placeholder Models; it is a geometry-only design/reference scene,
  not a playable dungeon or a published place.
- **Source-of-truth geometry builder:**
  `src/ServerScriptService/Dungeon/DungeonPlaceholderPhysicalContent.luau`.
  Both Temple (TestDungeon) and Abandoned Mine have separate EventArena
  and SecretArena Models with walkable floors, open entry walls, roof
  blockouts, four columns, a boss pedestal, and linked EventBridge and
  SecretBridge Models. Theme-specific placeholder colours/materials help
  differentiate the two.
- Each dungeon also has `Depth2_UNREGISTERED_PREVIEW`,
  `Depth3_UNREGISTERED_PREVIEW`, and
  `Depth4_UNREGISTERED_PREVIEW` folders with 4/5/6 walkable placeholder
  encounter rooms and connecting corridors; Depth4 includes miniboss
  pedestal locations. These preview floors are not registered as playable
  high-difficulty physical layouts.
- Every visible Part is anchored and organized under a separate Model.
  Names such as EventArena, SecretArena and their bridge models are
  intended as stable replacement boundaries when models/meshes arrive.
  Preserve the logical anchor IDs, scene scale and entrance relationships
  when substituting finished content.

## Using the blockouts

Open `content/placeholder/DungeonMMO_PhysicalBlockouts_v1.rbxlx`
in Roblox Studio. In Explorer expand
`Workspace > TestDungeon` or `Workspace > AbandonedMine` and then
`DungeonMMOPlaceholderPhysicalContent`. The editor scene includes
separate placeholder anchor marker Parts under
`DungeonMMOEnvironmentAnchors`; they are for visual reference only.

To preview how current *gameplay code* constructs a placeholder dungeon,
use the source-controlled TEMP-only scripts:
`scripts/studio/phase4_placeholder_physical_smoke.luau` (Edit),
`phase4_placeholder_live_preview.luau` (Play), and
`phase4_placeholder_verify_static_scene.luau` (static editor scene).
The bootstrap creates runtime placeholders only if synthetic mode, Studio
and Workspace attribute
`DungeonMMOPlaceholderPhysicalContentEnabled=true` are all present.
The source-control default remains disabled.

**Do not directly publish the standalone .rbxlx** as a playable dungeon:
it intentionally contains no live scripts, layout registrations or
serialized runtime CollectionService anchor bindings. When authoring a
real layout, replace the Model geometry and separately register correct
physical environment anchors/layout bindings through the regular
content-readiness review.

## Verification and rollout boundary

Fresh source-generated Temple and Mine placeholder live previews passed
with current Depth1 still functional and optional/higher-depth content
remaining locked (Studio logs 20260919T191020Z and 20260919T191256Z).
The edit-mode geometry smoke checked both dungeons, optional room/bridge
parts, anchor identity and continuously walkable bridge floors.
The repository .rbxlx was reconstructed from actual Studio-exported
geometry and validated in a fresh Studio static RunScript session:
330 editable Parts in 62 Models, both dungeon room sets and previews
verified. Static QA log:
`0.739.0.7390687_20260919T192913Z_Studio_6E1E7_last.log`.
The initial static QA failed because it counted unrelated Studio
Workspace parts; the corrected test counts only exported scene folders.
The repository XML contains zero gameplay scripts.

Both `OptionalBossRuntimeEnabled` flags remain false; higher-depth
physical layouts remain unregistered, and neither TEST nor PROD was
published or merged to main. Placeholder geometry is not final
art/content quality, combat balance or release acceptance.
