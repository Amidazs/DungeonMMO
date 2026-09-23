import unittest,math,json,copy
from pathlib import Path
from quadruped_core.refinement import two_bone, timeline, contact, validate_config
class RefinementTests(unittest.TestCase):
    def test_reject_bad_configuration_before_authoring(self):
        config=json.loads((Path(__file__).parents[1]/"profiles/frostfang_v16_refinement.json").read_text())
        validate_config(config)
        for path,value in [(("timeline","cadence"),0),(("front","stride"),0),(("front","lift"),float("nan")),(("hind","stance"),1),(("timeline","ramp"),float("inf")),(("settle",),0)]:
            bad=copy.deepcopy(config);target=bad
            for key in path[:-1]:target=target[key]
            target[path[-1]]=value
            with self.assertRaises(ValueError):validate_config(bad)
    def test_measured_elbow_plane_and_lengths(self):
        a=[0,0,.6];b=[0,.02,.34];c=[0,-.02,.10]
        for y in [-.12,-.02,.08]:
            r=two_bone(a,[0,y,.1],math.dist(a,b),math.dist(b,c),[0,1,0],165)
            self.assertAlmostEqual(math.dist(a,r["elbow"]),math.dist(a,b),places=7)
            self.assertAlmostEqual(math.dist(r["elbow"],r["end"]),math.dist(b,c),places=7)
            self.assertLessEqual(r["angle"],165.0001)
            self.assertGreater(r["elbow"][1],min(a[1],r["end"][1]))
    def test_stance_does_not_slide(self):
        cfg=dict(stride=.07,lift=.02,stance=.67,offset=0)
        a=contact(.1,cfg);b=contact(.2,cfg)
        self.assertTrue(a["planted"] and b["planted"])
        self.assertEqual(a["forward"],b["forward"])
    def test_independent_limb_parameters(self):
        cfg=dict(stride=.07,lift=.02,stance=.67,offset=0)
        a=contact(.8,cfg);b=contact(.8,dict(cfg,lift=.04))
        self.assertGreater(b["height"],a["height"])
        self.assertAlmostEqual(a["forward"],b["forward"])
    def test_transition_timeline(self):
        self.assertEqual(timeline(1.9,2,4,1,.6)["cycles"],0)
        end=timeline(10,2,4,1,.6)
        self.assertAlmostEqual(end["cycles"],4)
        self.assertEqual(end["weight"],0)
        values=[timeline(i/240,2,4,1,.6)["cycles"] for i in range(2400)]
        self.assertTrue(all(a<=b for a,b in zip(values,values[1:])))
    def test_swing_contact_seam(self):
        cfg=dict(stride=.07,lift=.02,stance=.67,offset=.5)
        for q in [.17,.5,1.17,1.5]:
            a=contact(q-1e-7,cfg);b=contact(q+1e-7,cfg)
            self.assertLess(abs(a["forward"]-b["forward"]),1e-6)
            self.assertLess(abs(a["height"]-b["height"]),1e-6)
if __name__=="__main__":unittest.main()
