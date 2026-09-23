"""Versioned editable data validation. No host or filesystem side effects."""
import math
import copy

LIMBS=("FrontLeft","FrontRight","HindLeft","HindRight")
def _finite(value):
    if isinstance(value,float) and not math.isfinite(value):raise ValueError("nonfinite number")
    if isinstance(value,dict):
        for v in value.values():_finite(v)
    if isinstance(value,list):
        for v in value:_finite(v)
def number(v,name,minimum=None,maximum=None):
    if isinstance(v,bool) or not isinstance(v,(int,float)) or not math.isfinite(v):raise ValueError(name+" must be finite")
    if minimum is not None and v<minimum:raise ValueError(name+" below minimum")
    if maximum is not None and v>maximum:raise ValueError(name+" above maximum")
    return v
def vector(v,n,name):
    if not isinstance(v,list) or len(v)!=n:raise ValueError(name+" vector size")
    for x in v:number(x,name)
def validate(data,expected_kind):
    if not isinstance(data,dict):raise ValueError("expected object")
    _finite(data)
    if data.get("version")!=1:raise ValueError("unsupported version")
    if data.get("kind")!=expected_kind:raise ValueError("incorrect kind")
    if not isinstance(data.get("id"),str) or not data["id"].strip():raise ValueError("id required")
    if expected_kind=="pose":
        if not isinstance(data.get("channels"),dict) or not isinstance(data.get("mask"),list):raise ValueError("pose channels/mask required")
        for name,c in data["channels"].items():
            if not isinstance(name,str) or not isinstance(c,dict):raise ValueError("invalid pose channel")
            vector(c.get("rotation"),4,"rotation");vector(c.get("translation"),3,"translation")
            if sum(x*x for x in c["rotation"])<1e-12:raise ValueError("zero quaternion")
        if any(n not in data["channels"] for n in data["mask"]):raise ValueError("mask references absent channel")
    elif expected_kind=="animation":
        if data.get("type") not in ("Idle","Walk","Run","Look","Tail","Custom"):raise ValueError("unsupported animation type")
        number(data.get("duration"),"duration",.05,120)
        number(data.get("fps"),"fps",1,120)
        if data.get("rootMotion") not in ("in_place","translate"):raise ValueError("invalid rootMotion")
        p=data.get("parameters",{})
        for key,default,lo,hi in (("speed",.5,0,20),("stride",.5,.001,3),("lift",.1,0,1),("cadence",1,.01,20),("stance",.65,.05,.95)):
            number(p.get(key,default),key,lo,hi)
        if "phases" in p:
            if set(p["phases"])!=set(LIMBS):raise ValueError("four limb phases required")
            for x in p["phases"].values():number(x,"phase",0,1)
        if not isinstance(data.get("layers",[]),list):raise ValueError("layers must be list")
        for layer in data.get("layers",[]):
            validate(layer["pose"],"pose");number(layer.get("weight",1),"weight",0,1)
    elif expected_kind=="profile":
        roles=data.get("roles",{});groups=data.get("groups",{});limbs=data.get("limbs",{})
        if not all(roles.get(n) for n in ("Root","Pelvis","Chest","Head")):raise ValueError("required body roles missing")
        if set(limbs)!=set(LIMBS):raise ValueError("four limbs required")
        seen=set()
        for name,limb in limbs.items():
            chain=limb.get("chain",[])
            if len(chain)<2 or len(set(chain))!=len(chain):raise ValueError("invalid chain "+name)
            if seen.intersection(chain):raise ValueError("duplicate limb ownership")
            seen.update(chain)
            if limb.get("anatomy") not in ("front","hind"):raise ValueError("limb anatomy required")
            if len(limb.get("limits",[]))!=len(chain):raise ValueError("one limit per joint")
            for pair in limb["limits"]:
                vector(pair,2,"limit")
                if pair[0]>0 or pair[1]<0 or pair[0]>pair[1]:raise ValueError("limits must include neutral")
        for name,chain in groups.items():
            if not isinstance(chain,list) or len(set(chain))!=len(chain):raise ValueError("invalid body group")
        for key in ("forward","up"):vector(data.get(key),3,key)
    elif expected_kind!="runtime":raise ValueError("unknown kind")
    return copy.deepcopy(data)
