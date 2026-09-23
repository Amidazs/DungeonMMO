--!strict
-- Session-only IDs; no upload and no promise of persistent published IDs.
local Preview={}
function Preview.register(sequence)
    assert(game:GetService("RunService"):IsStudio(),"Local preview is Studio-only")
    local animation=Instance.new("Animation");animation.Name=sequence.Name
    animation.AnimationId=game:GetService("KeyframeSequenceProvider"):RegisterKeyframeSequence(sequence)
    return animation
end
return Preview
