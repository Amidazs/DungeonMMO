--!strict
-- Playback only. No game authority, publishing or authoring dependency.
local Controller={}
Controller.__index=Controller
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
function Controller.new(animator,resolveClip,config)
    assert(animator:IsA("Animator"),"Animator required")
    return setmetatable({animator=animator,resolve=resolveClip,config=config,speed=1,layers={},tracks={},dead=false,disposed=false,paused=false},Controller)
end
function Controller:_alive() assert(not self.disposed,"Controller disposed") end
function Controller:play(state,fade)
    self:_alive()
    assert(not self.dead,"Death is terminal until reset")
    local entry=self.config.states[state];assert(entry,"Unknown animation state: "..tostring(state))
    fade=fade or self.config.fade or .2;assert(finite(fade) and fade>=0,"Invalid fade")
    local animation=self.resolve(entry.clip);assert(animation and animation:IsA("Animation"),"Missing clip")
    local track=self.animator:LoadAnimation(animation)
    track.Priority=Enum.AnimationPriority[entry.priority or "Movement"]
    track.Looped=entry.loop==true
    track:Play(fade,1,self.paused and 0 or self.speed*(entry.speed or 1))
    if self.current then self.current:Stop(fade) end
    self.current=track;self.state=state;self.entry=entry;table.insert(self.tracks,track)
    if state=="Death" then self.dead=true;for name in pairs(self.layers) do self:clearLayer(name) end end
    return track
end
function Controller:setSpeed(speed)
    self:_alive();assert(finite(speed) and speed>=0 and speed<=10,"Invalid playback speed")
    self.speed=speed
    if self.current then self.current:AdjustSpeed(self.paused and 0 or speed*(self.entry.speed or 1)) end
    for _,track in pairs(self.layers) do track:AdjustSpeed(self.paused and 0 or speed) end
end
function Controller:pause() self:_alive();self.paused=true;self:setSpeed(self.speed) end
function Controller:resume() self:_alive();self.paused=false;self:setSpeed(self.speed) end
function Controller:seek(seconds)
    self:_alive();assert(finite(seconds) and seconds>=0,"Invalid seek")
    if self.current then self.current.TimePosition=math.min(seconds,self.current.Length) end
end
function Controller:setLayer(name,animation,weight)
    self:_alive();assert(not self.dead,"Death blocks layers")
    assert(type(name)=="string" and name~="","Layer name required")
    assert(finite(weight) and weight>=0 and weight<=1,"Invalid layer weight")
    local track=self.animator:LoadAnimation(animation)
    track.Priority=Enum.AnimationPriority.Action
    track.Looped=true;track:Play(self.config.fade or .2,weight,self.paused and 0 or self.speed)
    self:clearLayer(name);self.layers[name]=track;table.insert(self.tracks,track)
end
function Controller:clearLayer(name)
    local t=self.layers[name];if t then t:Stop(self.config.fade or .2);self.layers[name]=nil end
end
function Controller:stop()
    for _,t in self.tracks do t:Stop(0);t:Destroy() end
    self.tracks={};self.layers={};self.current=nil;self.state=nil
end
function Controller:reset()
    self:_alive();self:stop();self.dead=false;self.paused=false;self.speed=1
    if self.config.reset then self.config.reset() end
end
function Controller:destroy() if self.disposed then return end;self:stop();self.disposed=true end
return Controller
