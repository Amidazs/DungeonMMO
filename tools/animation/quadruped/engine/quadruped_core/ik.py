"""Bounded anatomical-plane CCD. Limits are offsets from measured rest angles.

Out-of-plane targets are reported as residual; never stretch or invent a
different anatomy. Blender authoring uses this result and measured rest roll.
"""
import math,copy
from .math3 import sub,add,mul,dot,cross,norm,unit,rotate
def solve_chain(rest,target,settings):
    points=copy.deepcopy(rest["points"]);n=len(points)-1
    if n<2 or any(norm(sub(points[i+1],points[i]))<1e-8 for i in range(n)):raise ValueError("invalid limb lengths")
    axis=unit(rest["axis"]);limits=settings.get("limits",[[-math.pi,math.pi] for _ in range(n)])
    if len(limits)!=n:raise ValueError("joint limit count")
    angles=[0.]*n
    if settings.get("enabled",True):
        for _ in range(settings.get("iterations",100)):
            if norm(sub(points[-1],target))<settings.get("tolerance",1e-6):break
            for i in reversed(range(n)):
                a=sub(points[-1],points[i]);b=sub(target,points[i])
                a=sub(a,mul(axis,dot(a,axis)));b=sub(b,mul(axis,dot(b,axis)))
                if norm(a)<1e-10 or norm(b)<1e-10:continue
                delta=math.atan2(dot(axis,cross(a,b)),dot(a,b))
                new=max(limits[i][0],min(limits[i][1],angles[i]+delta))
                delta=new-angles[i];angles[i]=new
                for j in range(i+1,n+1):points[j]=add(points[i],rotate(sub(points[j],points[i]),axis,delta))
    error=norm(sub(points[-1],target))
    return dict(points=points,angles=angles,residual=error,converged=error<settings.get("tolerance",1e-6))
