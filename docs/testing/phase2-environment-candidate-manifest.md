# Phase 2 Environment Candidate Manifest

These files are replaceable visual test candidates. Gameplay code must not rely
on their binary identity, hierarchy, or fixed coordinates.

- Base candidate: `LobbyScene_001_V3_1_P11_SurfaceArchitecture(1).glb`
  - SHA-256: `F624C96AF9F67BB374FE36752331A26B59C4C7E7AA8B228223AE4C04919E981B`
  - Size: `40,984,352` bytes
- Dungeon candidate: `Temple.rbxl`
  - SHA-256: `A3039361882632E857228411A0F36BBA9086A22A37080FA2034CE2B25921BB32`
  - Size: `13,622,440` bytes

Integration authority comes from `DungeonMMOEnvironmentAnchor` semantic anchors,
not from these filenames or hashes. A later Lobby/Temple revision may replace
either candidate by supplying the same anchor contract.

## Calibration evidence

The current candidate profiles were calibrated from the supplied files on
14 September 2026. Lobby landmark selectors remain isolated to
`BaseCandidateAnchorProfile.luau`. Temple world CFrames remain isolated to
`TempleCandidateAnchorProfile.luau`.

No candidate binary is part of the gameplay source boundary.
