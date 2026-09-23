-- Real Animator contract; run inside the isolated QA place in Play.
return function(modules)
    local Controller=require(modules.Controller)
    local ClipImport=require(modules.ClipImport)
    local Preview=require(modules.LocalPreview)
    local rig=Instance.new("Model");rig.Name="QAE_RuntimeFixture";rig.Parent=workspace
    local root=Instance.new("MeshPart");root.Name="RootPart";root.Anchored=true;root.Transparency=1;root.Parent=rig
    local bone=Instance.new("Bone");bone.Name="TestBone";bone.Parent=root
    local ac=Instance.new("AnimationController");ac.Parent=rig
    local animator=Instance.new("Animator");animator.Parent=ac
    local manifest={id="fixture",loop=true,bones={{name="TestBone"}},frames={
      {time=0,poses={TestBone={0,0,0,1,0,0,0,1,0,0,0,1}}},
      {time=.5,poses={TestBone={0,0,0,1,0,0,0,0,-1,0,1,0}}},
      {time=1,poses={TestBone={0,0,0,1,0,0,0,1,0,0,0,1}}}}}
    local sequence=ClipImport.build(rig,manifest)
    local animation=Preview.register(sequence)
    local config={states={Idle={clip="idle",loop=true,priority="Idle"},Walk={clip="walk",loop=true,priority="Movement"},Death={clip="death",loop=false,priority="Action4"}},fade=.1}
    local c=Controller.new(animator,function(id) if id=="missing" then error("missing clip") end return animation end,config)
    local checks=0
    local function expect(ok,label) assert(ok,label);checks+=1 end
    c:play("Idle");task.wait(.2)
    expect(c.current.IsPlaying,"native track plays")
    c:play("Walk",.1);task.wait(.2)
    expect(c.state=="Walk" and c.current.IsPlaying,"transition plays")
    c:setSpeed(.5);expect(c.current.Speed==.5,"native speed")
    c:pause();expect(c.current.Speed==0,"pause")
    c:resume();expect(c.current.Speed==.5,"resume speed")
    c:seek(.4);expect(math.abs(c.current.TimePosition-.4)<.1,"scrub")
    c:setLayer("Head",animation,.5);expect(c.layers.Head.IsPlaying,"layer")
    c:clearLayer("Head");expect(c.layers.Head==nil,"remove layer")
    local before=c.current;expect(not pcall(function() c:play("Unknown") end),"unknown rejected")
    expect(c.current==before and before.IsPlaying,"failed state preserves current")
    c:play("Death");expect(not pcall(function() c:play("Walk") end),"death lock")
    c:reset();bone.Transform=CFrame.identity
    expect(c.current==nil and next(c.layers)==nil,"reset")
    c:destroy();expect(not pcall(function() c:play("Idle") end),"disposed rejected")
    sequence:Destroy();animation:Destroy();rig:Destroy()
    print("QAE_RUNTIME_PASS",checks)
    return checks
end
