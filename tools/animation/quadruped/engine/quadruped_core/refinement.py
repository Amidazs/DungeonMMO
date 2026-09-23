"""Continuous contacts and measured pole-directed foreleg IK.

Kept separate from the existing sampler so legacy presets retain their motion.
All lengths use the caller's calibrated units; no creature bone names.
"""
import math
from .math3 import add,sub,mul,dot,norm,unit
def smooth(x):
    x=max(0.,min(1.,x));return x*x*x*(10+x*(-15+6*x))
def timeline(time,idle=2.,cycles=4.,cadence=1.,ramp=.6):
    if cadence<=0 or cycles<=0 or ramp<=0:raise ValueError("invalid timeline")
    duration=cycles/cadence+ramp
    if duration<2*ramp:raise ValueError("ramp longer than walk")
    t=max(0.,min(duration,time-idle))
    def integral(x):return 2.5*x**4-3*x**5+x**6
    if t<ramp:q=cadence*ramp*integral(t/ramp);weight=smooth(t/ramp)
    elif t<=duration-ramp:q=cadence*(t-ramp/2);weight=1.
    else:
        x=(t-duration+ramp)/ramp
        q=cycles-cadence*ramp/2+cadence*ramp*(x-integral(x));weight=1-smooth(x)
    return dict(cycles=q,weight=weight,walk_end=idle+duration,finished=time>=idle+duration)
def contact(q,cfg):
    step=cfg["stride"];lift=cfg["lift"];stance=cfg["stance"];offset=cfg.get("offset",0)
    if step<=0 or lift<0 or not 0<stance<1 or not 0<=offset<1:raise ValueError("invalid contact settings")
    if q<=0:return dict(forward=0.,height=0.,planted=True,swing=0.,phase=offset)
    absolute=q+offset;cycle=math.floor(absolute);phase=absolute-cycle
    planted=phase<stance
    s=0.
    if planted:forward=cycle*step;height=0.
    else:
        s=(phase-stance)/(1-stance)
        # A leg already in swing at q=0 starts from its real balanced idle.
        if cycle==0 and offset>=stance:s=q/(1-offset)
        forward=(cycle+smooth(s))*step;height=lift*math.sin(math.pi*s)**2
    return dict(forward=forward,height=height,planted=planted,swing=s,phase=phase)
def two_bone(start,target,upper,lower,pole,max_angle=165.):
    if min(upper,lower)<=0 or not 0<max_angle<180:raise ValueError("invalid chain")
    direction=sub(target,start);requested=norm(direction)
    if requested<1e-10:raise ValueError("target at limb root")
    axis=unit(direction)
    max_reach=math.sqrt(upper**2+lower**2-2*upper*lower*math.cos(math.radians(max_angle)))
    d=max(abs(upper-lower)+1e-8,min(requested,max_reach))
    end=add(start,mul(axis,d))
    bend=sub(pole,mul(axis,dot(pole,axis)))
    if norm(bend)<1e-8:raise ValueError("pole parallel to chain")
    bend=unit(bend);along=(upper**2-lower**2+d*d)/(2*d)
    height=math.sqrt(max(0.,upper*upper-along*along))
    elbow=add(add(start,mul(axis,along)),mul(bend,height))
    angle=math.degrees(math.acos(max(-1,min(1,(upper*upper+lower*lower-d*d)/(2*upper*lower)))))
    return dict(elbow=elbow,end=end,angle=angle,residual=abs(requested-d))
