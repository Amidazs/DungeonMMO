"""Ordered rest-relative local pose composition with explicit masks."""
import copy
from .schema import validate, number
from .math3 import qmul, qslerp, add, mul
def compose_pose(base,layers):
    out=copy.deepcopy(base)
    for layer in layers:
        p=validate(layer["pose"],"pose");w=number(layer.get("weight",1.),"weight",0,1)
        for name in p["mask"]:
            src=p["channels"][name]
            old=out.get(name,dict(rotation=[1,0,0,0],translation=[0,0,0]))
            out[name]=dict(rotation=qmul(old["rotation"],qslerp([1,0,0,0],src["rotation"],w)),
              translation=add(old["translation"],mul(src["translation"],w)))
    return out
