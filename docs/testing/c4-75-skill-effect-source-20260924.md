# C4 75-skill effect source evidence — v2.48

Pinned source:
`Neco-spain/l2jadmins_C4-Scions-of-Destiny@07f8536384e799f128d44198dd7ab23519660eea`.

C4 XML ranges used:
0000-0099, 0100-0199, 0200-0299, 0300-0399,
1000-1099, 1100-1199, 1200-1299 and 1300-1399.

Only skill IDs present in the v2.47 nine-path level<=30 learning
inventory are retained. Rank-resolved values are transformed into
structured source facts rather than copying XML documents wholesale.

Coverage:
- source skill IDs: 75;
- unique source skill/rank pairs required by the nine paths:
  272;
- class-scoped learning rows using those pairs: 476.

Representative test vectors include Power Strike rank1 active fields,
Warrior Stun Attack rank3 power/status fields, Scout Bow Mastery
weapon-conditioned P.Atk modifier, Expertise D, Create Common Item
and Elven Elemental Heal rank4 MP.

Passing the source test means every learning row has historical
effect metadata. It does not mean the current creative skill executes
those values yet.
