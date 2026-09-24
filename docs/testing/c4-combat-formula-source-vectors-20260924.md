# C4 combat formula source vectors — v2.46

Pinned source:
`Neco-spain/l2jadmins_C4-Scions-of-Destiny@07f85363`,
principally `Formulas.java` and `EffectHeal.java`.

The focused deterministic vectors verify:
- physical skill: `70 * (PAtk + skillPower) / PDef` in the reviewed
  no-shot/non-critical path;
- Soulshot doubles P.Atk after source skill power is added;
- default physical critical arithmetic, shield defence branch and
  perfect-shield one-damage result;
- magic: `91 * sqrt(MAtk) / MDef * skillPower`, with shot order,
  x4 magic critical and resisted-one-damage branch;
- reviewed instant heal power, ordinary Spiritshot x1.3 and blessed
  x1.5;
- `470000 / PAtkSpd` normal attack delay;
- attack/cast-speed skill-time scaling;
- exact source hit-chance delta table and magic level threshold.

These are source formula tests. Current Roblox DamageService and
skill executors have not been switched yet.
