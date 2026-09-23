"""Small vector and quaternion utilities, [w,x,y,z] convention."""
import math
def add(a,b):return [x+y for x,y in zip(a,b)]
def sub(a,b):return [x-y for x,y in zip(a,b)]
def mul(a,k):return [x*k for x in a]
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def norm(a):return math.sqrt(dot(a,a))
def unit(a):
    n=norm(a)
    if n<1e-12:raise ValueError("degenerate vector")
    return mul(a,1/n)
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def rotate(v,axis,angle):
    c,s=math.cos(angle),math.sin(angle)
    return add(add(mul(v,c),mul(cross(axis,v),s)),mul(axis,dot(axis,v)*(1-c)))
def qmul(a,b):
    w,x,y,z=a;v,i,j,k=b
    return [w*v-x*i-y*j-z*k,w*i+x*v+y*k-z*j,w*j-x*k+y*v+z*i,w*k+x*j-y*i+z*v]
def qslerp(a,b,t):
    a,b=unit(a),unit(b);d=dot(a,b)
    if d<0:b=mul(b,-1);d=-d
    if d>.9995:return unit(add(mul(a,1-t),mul(b,t)))
    angle=math.acos(max(-1,min(1,d)))
    return add(mul(a,math.sin((1-t)*angle)/math.sin(angle)),mul(b,math.sin(t*angle)/math.sin(angle)))
