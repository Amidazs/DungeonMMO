import copy, json, math, tempfile, unittest
from pathlib import Path
from quadruped_core.schema import validate
from quadruped_core.storage import load, save
from quadruped_core.gait import sample_gait
from quadruped_core.pose import compose_pose
from quadruped_core.ik import solve_chain

def pose():
    return dict(version=1,kind="pose",id="alert",family="canine",channels={"Head":{"rotation":[1,0,0,0],"translation":[0,0,0]}},mask=["Head"])
def definition():
    return dict(version=1,kind="animation",id="walk",type="Walk",duration=2.,fps=30,loop=True,rootMotion="translate",
      parameters=dict(speed=0.5,stride=0.5,lift=0.1,cadence=1.,auto_cadence=True,stance=0.65,
        phases=dict(FrontLeft=0.,FrontRight=0.5,HindLeft=0.75,HindRight=0.25)),layers=[],markers=[])
def calibration():
    return dict(scale=1.,forward=[0,1,0],up=[0,0,1],limbs={n:dict(contact=[x,y,0.],length=1.) for n,x,y in
      [("FrontLeft",.2,.4),("FrontRight",-.2,.4),("HindLeft",.2,-.4),("HindRight",-.2,-.4)]})
class CoreTests(unittest.TestCase):
    def test_versions_and_finite(self):
        for bad in [dict(pose(),version=99),dict(pose(),kind="profile")]:
            with self.assertRaises(ValueError): validate(bad,"pose")
        bad=pose();bad["channels"]["Head"]["translation"][0]=float("nan")
        with self.assertRaises(ValueError):validate(bad,"pose")
    def test_zero_quaternion_rejected(self):
        p=pose();p["channels"]["Head"]["rotation"]=[0]*4
        with self.assertRaises(ValueError):validate(p,"pose")
    def test_atomic_roundtrip_and_overwrite(self):
        with tempfile.TemporaryDirectory() as d:
            path=Path(d)/"pose.json";save(path,pose());old=path.read_bytes()
            changed=pose();changed["id"]="edited"
            with self.assertRaises(FileExistsError):save(path,changed)
            self.assertEqual(old,path.read_bytes())
            save(path,changed,overwrite=True);self.assertEqual(load(path,"pose"),changed)
            path.write_text('{"version":')
            with self.assertRaises(ValueError):load(path,"pose")
    def test_stance_world_lock_and_scrub(self):
        d,c=definition(),calibration()
        a=sample_gait(d,c,.1);b=sample_gait(d,c,.2)
        self.assertTrue(a["limbs"]["FrontLeft"]["planted"])
        self.assertLess(math.dist(a["limbs"]["FrontLeft"]["world"],b["limbs"]["FrontLeft"]["world"]),1e-9)
        sample_gait(d,c,31)
        self.assertEqual(a,sample_gait(d,c,.1))
        self.assertTrue(all(math.isfinite(v) for v in sample_gait(d,c,-.2)["root"]))
    def test_parameters_and_seams(self):
        d,c=definition(),calibration()
        a=sample_gait(d,c,.8)
        e=copy.deepcopy(d);e["parameters"]["lift"]=.3
        b=sample_gait(e,c,.8)
        self.assertGreater(b["limbs"]["FrontLeft"]["world"][2],a["limbs"]["FrontLeft"]["world"][2])
        for t in [.65,1.]:
            a=sample_gait(d,c,t-1e-8)["limbs"]["FrontLeft"]["world"]
            b=sample_gait(d,c,t+1e-8)["limbs"]["FrontLeft"]["world"]
            self.assertLess(math.dist(a,b),1e-6)
    def test_speed_and_idle(self):
        d,c=definition(),calibration();d["parameters"]["speed"]=1.
        self.assertAlmostEqual(sample_gait(d,c,.1)["cadence"],2.)
        d["parameters"]["speed"]=0
        self.assertEqual(sample_gait(d,c,10)["root"],[0.,0.,0.])
    def test_pose_mask_and_quaternion_sign(self):
        p=pose();p["channels"]["Head"]["rotation"]=[-1,0,0,0]
        result=compose_pose({},[dict(pose=p,weight=.5)])
        self.assertAlmostEqual(abs(result["Head"]["rotation"][0]),1.)
        p["mask"]=[]
        self.assertEqual(compose_pose({},[dict(pose=p,weight=1.)]),{})
    def test_ik_lengths_reach_limits(self):
        rest=dict(points=[[0,0,0],[0,0,1],[0,.3,1.8]],axis=[1,0,0])
        for target in [[0,.5,1.5],[0,5,5]]:
            result=solve_chain(rest,target,dict(limits=[[-1.5,1.5],[-1.5,1.5]],iterations=150))
            for i in range(2):
                self.assertAlmostEqual(math.dist(result["points"][i],result["points"][i+1]),math.dist(rest["points"][i],rest["points"][i+1]),places=6)
                self.assertLessEqual(abs(result["angles"][i]),1.500001)
            if target[1]==5:self.assertGreater(result["residual"],1)
        result=solve_chain(rest,[0,.5,1.5],dict(enabled=False))
        self.assertEqual(result["points"],rest["points"])
    def test_invalid_gait(self):
        d=definition();d["parameters"]["stance"]=1.
        with self.assertRaises(ValueError):sample_gait(d,calibration(),0)
if __name__=="__main__":unittest.main()
