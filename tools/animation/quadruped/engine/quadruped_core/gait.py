"""Deterministic world-anchored contacts, independent of prior samples."""
import math
from .schema import validate, LIMBS
from .math3 import add,mul
def sample_gait(definition,calibration,time,ground_height=None):
    validate(definition,"animation")
    if not math.isfinite(time):raise ValueError("time must be finite")
    p=definition["parameters"];scale=calibration["scale"]
    stride=p.get("stride",.5)*scale;speed=p.get("speed",.5)*scale
    cadence=speed/stride if p.get("auto_cadence",True) else p.get("cadence",1.)
    if not p.get("auto_cadence",True):speed=cadence*stride
    if definition["type"] not in ("Walk","Run"):speed=cadence=0.
    forward=calibration["forward"];up=calibration["up"]
    root=mul(forward,speed*time)
    stance=p.get("stance",.65)
    phases=p.get("phases",dict(FrontLeft=0.,FrontRight=.5,HindLeft=.75,HindRight=.25))
    limbs={}
    for name in LIMBS:
        c=calibration["limbs"][name]["contact"]
        if cadence<=1e-12:
            world=list(c);phase=0.;planted=True
        else:
            shift=phases[name];absolute=time*cadence+shift
            cycle=math.floor(absolute);phase=absolute-cycle
            touchdown=(cycle-shift)*stride
            world=add(c,mul(forward,touchdown+stance*stride*.5))
            planted=phase<stance
            if not planted:
                s=(phase-stance)/(1-stance);ease=s*s*(3-2*s)
                world=add(world,mul(forward,stride*ease))
                world=add(world,mul(up,p.get("lift",.1)*scale*math.sin(math.pi*s)**2))
        if ground_height:
            world=add(world,mul(up,ground_height(world[0],world[1])))
        local=[world[i]-root[i] for i in range(3)]
        limbs[name]=dict(world=world,local=local,phase=phase,planted=planted)
    return dict(root=root,cadence=cadence,travelSpeed=speed,limbs=limbs)
