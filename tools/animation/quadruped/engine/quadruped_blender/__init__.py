"""Quadruped Studio Blender add-on."""
bl_info={"name":"DungeonMMO Quadruped Studio","author":"DungeonMMO","version":(0,1,0),"blender":(5,0,0),"location":"View3D > Sidebar > Quadruped","category":"Animation"}
def register():
    from . import ui
    ui.register()
def unregister():
    from . import ui
    ui.unregister()
