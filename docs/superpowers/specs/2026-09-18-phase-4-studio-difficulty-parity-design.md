# Phase 4 Studio Difficulty Parity - Design

**Date:** 18 September 2026
**Phase:** Phase 4 - Content Alpha
**Gate:** Studio Difficulty / Session Parity
**Baseline:** `5fb3491`
**Scope:** backend only

## Demonstrated blocker

Production dungeon creation already persists the selected DifficultyId through
TeleportCoordinator, DungeonSessionService and DungeonInstanceDirector.

StudioSessionFactory does not. It currently omits difficulty when:

- creating the Studio dungeon session;
- resolving InstanceState;
- returning synthetic routing data.

A future Studio Depth2+ run could therefore select a higher-depth environment
while creating a Depth1 session/encounter plan.

## Goal

Studio session creation must preserve the same selected difficulty identity as
production routing.

StudioSessionFactory will accept an optional difficulty_id and propagate it to:

- DungeonSessionService:create;
- DungeonInstanceDirector.resolve;
- returned teleport_data.

DungeonRuntime will pass the difficulty already resolved by
DungeonEnvironmentBootstrap.

## Compatibility

Omitting Studio difficulty continues to default through
DungeonDifficultyDefinitions to Depth1.

Production teleport/session behavior is unchanged.

No higher depth is enabled by this gate.

## Acceptance

Require RED -> GREEN proving an explicit Studio Depth2 request reaches the
session service, InstanceState and routing data, while existing Depth1/default
behavior remains green.
