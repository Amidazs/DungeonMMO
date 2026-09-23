"""Localized skin transition smoothing; geometry and rest bones remain unchanged."""
import numpy as np
def smooth_transition(mesh,config):
    names={g.index:g.name for g in mesh.vertex_groups}
    count=len(mesh.data.vertices);groups=len(names)
    original=np.zeros((count,groups),dtype=np.float64)
    coords=np.array([list(v.co) for v in mesh.data.vertices])
    for v in mesh.data.vertices:
        for g in v.groups:original[v.index,g.group]=g.weight
    affected=[i for i,n in names.items() if n.startswith(("DEF_shoulder.","DEF_front_thigh."))]
    selected=(original[:,affected].sum(axis=1)>.05)
    y=coords[:,1];z=coords[:,2]
    selected &= (y>config["y_min"]) & (y<config["y_max"]) & (z>config["z_min"]) & (z<config["z_max"])
    # Fade the edit at its anatomical boundary.
    fade=np.minimum.reduce([(y-config["y_min"])/.04,(config["y_max"]-y)/.04,(z-config["z_min"])/.06,(config["z_max"]-z)/.06,np.ones(count)])
    factor=np.clip(fade,0,1)*selected*config.get("strength",.5)
    edges=np.array([list(e.vertices) for e in mesh.data.edges])
    distance=np.linalg.norm(coords[edges[:,0]]-coords[edges[:,1]],axis=1)
    edges=edges[distance<.035]
    a=edges[:,0];b=edges[:,1];degree=np.bincount(np.concatenate((a,b)),minlength=count).clip(1)
    weights=original.copy()
    for _ in range(config.get("iterations",8)):
        sums=np.zeros_like(weights)
        np.add.at(sums,a,weights[b]);np.add.at(sums,b,weights[a])
        weights=weights*(1-factor[:,None])+sums/degree[:,None]*factor[:,None]
    indices=np.where(selected)[0]
    changed=0
    for index in indices:
        row=weights[index];top=np.argsort(row)[-4:];row2=np.zeros(groups);row2[top]=row[top];row2/=row2.sum()
        if np.max(np.abs(row2-original[index]))<1e-7:continue
        changed+=1
        for group in mesh.vertex_groups:
            if original[index,group.index]>0:group.remove([int(index)])
        for i in top:
            if row2[i]>1e-8:mesh.vertex_groups[int(i)].add([int(index)],float(row2[i]),"REPLACE")
    return dict(changed_vertices=changed,iterations=config.get("iterations",8),max_influences=4,region=config)
