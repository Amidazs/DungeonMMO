--!strict
-- Creative combat-charge names mapped to reviewed Chronicle 4 shot items.

local C4CreativeShotSourceMap = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"

local MAPPING = table.freeze({
    None = table.freeze({
        Soulshot = table.freeze({
            CreativeItemId = "kinetic_charge",
            SourceItemId = 1835,
        }),
        Spiritshot = table.freeze({
            CreativeItemId = "mystic_charge",
            SourceItemId = 2509,
        }),
        BlessedSpiritshot = table.freeze({
            CreativeItemId = "blessed_mystic_charge",
            SourceItemId = 3947,
        }),
    }),
    D = table.freeze({
        Soulshot = table.freeze({
            CreativeItemId = "d_grade_kinetic_charge",
            SourceItemId = 1463,
        }),
        Spiritshot = table.freeze({
            CreativeItemId = "d_grade_mystic_charge",
            SourceItemId = 2510,
        }),
        BlessedSpiritshot = table.freeze({
            CreativeItemId = "d_grade_blessed_mystic_charge",
            SourceItemId = 3948,
        }),
    }),
})

--[[
Returns the reviewed creative/source shot mapping for one weapon grade.

Args:
    grade (string): Reviewed source weapon grade, currently None or D.
    shot_kind (string): Soulshot, Spiritshot or BlessedSpiritshot.

Returns:
    (any?, string?): Immutable mapping or a strict unsupported reason.
]]
function C4CreativeShotSourceMap.get(
    grade: string,
    shot_kind: string
): (any?, string?)
    local grade_map = MAPPING[grade]
    if not grade_map then
        return nil, "UnsupportedOriginalShotGrade"
    end

    local mapping = grade_map[shot_kind]
    if not mapping then
        return nil, "UnsupportedOriginalShotKind"
    end

    return mapping, nil
end

--[[
Returns pinned provenance for the limited launch shot mapping.

Args:
    None.

Returns:
    any: Source commit and supported grade/shot mapping.
]]
function C4CreativeShotSourceMap.sources(): any
    return {
        SourceCommit = SOURCE_COMMIT,
        Mapping = MAPPING,
    }
end

return table.freeze(C4CreativeShotSourceMap)
