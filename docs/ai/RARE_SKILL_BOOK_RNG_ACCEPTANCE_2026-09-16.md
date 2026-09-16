# Rare Skill Book RNG Acceptance

**Date:** 16 September 2026
**Gate:** RNG Rare Skill Book acquisition
**Status:** ACCEPTED

## Accepted gameplay

The real Roblox Studio gameplay proof was completed successfully:

- A supported dungeon boss produced the forced personal RNG bonus drop.
- Server output reported the rare Skill Book boss source.
- The player inventory received the named `Arc Slash Skill Book`.
- Dungeon completion independently produced the Skill Book bonus roll.
- Server output reported the completion Skill Book source.
- Normal completion Gold and ordinary personal loot were still granted.
- The Studio local-server synthetic negative UserId session path was fixed and the dungeon admitted the test player correctly.

## Accepted rules

- Skill Books are RNG loot rather than targeted/guaranteed acquisition.
- Drops are named immediately.
- Normal dungeon parties use personal loot.
- Any class may receive any class's Skill Book.
- Books are tradable.
- A known skill does not remove its book from the drop pool.
- Learning remains class-restricted.
- Boss and completion rolls are independent bonus opportunities.
- Arc Slash is no longer a guaranteed first-clear reward.
- Legacy bound Arc Slash books remain compatible.
- Shared Need/Greed-style loot is deferred to later raid/world-boss systems.
- Secret bosses may later define their own rare/unique Skill Book pools.

## Initial proof tuning

- Supported bosses: 2% personal Skill Book chance.
- Supported dungeon completion: 1% personal Skill Book chance.
- Initial production book pool: `Arc Slash Skill Book`.

The percentages are configuration/balance data and may be tuned later.

## Deferred

- player-to-player trading implementation;
- auction house/market;
- raid/world-boss shared loot rolls;
- secret-boss implementation;
- additional class Skill Books;
- final economy/drop-rate balancing.
