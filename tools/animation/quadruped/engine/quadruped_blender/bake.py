"""Bake evaluated motion into a separate editable deformation-only action."""
import bpy
def bake(rig,action,frame_start,frame_end):
    scene=bpy.context.scene;old_frame=scene.frame_current
    rig.animation_data_create();old_action=rig.animation_data.action
    samples=[]
    try:
        rig.animation_data.action=action
        for frame in range(frame_start,frame_end+1):
            scene.frame_set(frame);bpy.context.view_layer.update()
            evaluated=rig.evaluated_get(bpy.context.evaluated_depsgraph_get())
            samples.append((frame,{b.name:b.matrix.copy() for b in evaluated.pose.bones}))
        baked=bpy.data.actions.new(action.name+"_FK");baked.use_fake_user=True
        rig.animation_data.action=baked
        for frame,matrices in samples:
            scene.frame_set(frame)
            for b in rig.pose.bones:
                b.rotation_mode="QUATERNION";b.matrix=matrices[b.name]
                bpy.context.view_layer.update()
                for prop in ("location","rotation_quaternion","scale"):b.keyframe_insert(prop,frame=frame,group=b.name)
        for key in action.keys():baked[key]=action[key]
        baked.use_frame_range=True;baked.frame_start=frame_start;baked.frame_end=frame_end
        return baked
    finally:
        rig.animation_data.action=old_action;scene.frame_set(old_frame)
