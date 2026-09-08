"""Authored dimensional architecture: open window reveals, roof structure and damage.
Blender produces reusable meshes; no gameplay or screenshot data is generated.
"""
import bpy,math,random
from mathutils import Vector,Matrix
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/visual_slice';OUT.mkdir(parents=True,exist_ok=True)

def build(name,damaged=False,seed=13):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    rng=random.Random(seed); batches={}
    colors={'plaster':(.57,.55,.47,1),'brick':(.28,.17,.11,1),'roof':(.25,.13,.085,1),'wood':(.10,.075,.05,1),'trim':(.30,.29,.25,1),'glass':(.045,.065,.067,1),'metal':(.11,.13,.13,1),'interior':(.16,.15,.12,1)}
    def face(mat,verts,faces):
        v,f=batches.setdefault(mat,([],[]));o=len(v);v.extend(verts);f.extend([tuple(o+i for i in ff) for ff in faces])
    def box(mat,c,s,rot=None):
        vs=[Vector((x*s[0]/2,y*s[1]/2,z*s[2]/2)) for x,y,z in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
        if rot is not None:vs=[rot@v for v in vs]
        face(mat,[Vector(c)+v for v in vs],[(3,2,1,0),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)])
    def beam(mat,a,b,width,depth=None):
        a,b=Vector(a),Vector(b);d=b-a
        box(mat,(a+b)/2,(width,depth or width,d.length),d.to_track_quat('Z','Y').to_matrix())
    # Dimensions are metres: 11.6 x 8.4, two 3.15 m storeys.
    w,dep,eave,ridge=11.6,8.4,6.5,9.5
    box('brick',(0,0,.18),(w+.15,dep+.15,.36))
    for z in [.42,3.45]:box('interior',(0,0,z),(w-.45,dep-.45,.19))
    # Each facade is a thick wall with real openings, rendered inside and outside.
    for side in range(4):
        length=w if side%2==0 else dep
        centers=[-length*.33,0,length*.33] if side%2==0 else [-dep*.25,dep*.25]
        opens=[]
        for level in [0,1]:
            for j,x in enumerate(centers):
                door=side==0 and level==0 and j==1
                opens.append((x-.68,x+.68,.4 if door else 1.05+level*3.15,2.82+level*3.15,door))
        xs=sorted(set([-length/2,length/2]+[q for o in opens for q in o[:2]]))
        zs=sorted(set([.36,eave]+[q for o in opens for q in o[2:4]]))
        ang=side*math.pi/2
        rotate=Matrix.Rotation(ang,3,'Z')
        depth=dep/2 if side%2==0 else w/2
        def pos(x,y,z):return rotate@Vector((x,y-depth,z))
        def part(mat,x,y,z,sx,sy,sz):box(mat,pos(x,y,z),(sx,sy,sz),rotate)
        for a,b in zip(xs,xs[1:]):
            for lo,hi in zip(zs,zs[1:]):
                cx,cz=(a+b)/2,(lo+hi)/2
                if any(o[0]<cx<o[1] and o[2]<cz<o[3] for o in opens):continue
                if damaged and side==0 and cx<-3.7 and cz>3.3:continue
                part('plaster',cx,0,cz,b-a,.32,hi-lo)
        for j,o in enumerate(opens):
            a,b,lo,hi,door=o;cx=(a+b)/2;cz=(lo+hi)/2
            if damaged and side==0 and cx<-3.7 and cz>3.3:continue
            for xx in [a+.06,b-.06]:part('wood',xx,.05,cz,.1,.12,hi-lo)
            for zz in [lo+.05,hi-.05]:part('wood',cx,.05,zz,b-a,.12,.1)
            part('trim',cx,-.06,lo-.07,b-a+.24,.58,.14)
            part('trim',cx,-.035,hi+.08,b-a+.2,.37,.15)
            if door:
                part('wood',cx,.20,cz,b-a-.15,.08,hi-lo-.14)
                for zz in [1,1.75,2.45]:part('trim',cx,.135,zz,b-a-.32,.035,.08)
            else:
                if not damaged or rng.random()>.26:part('glass',cx,.19,cz,b-a-.16,.025,hi-lo-.18)
                part('wood',cx,.075,cz,.05,.09,hi-lo-.15)
                part('wood',cx,.075,cz,b-a-.15,.09,.055)
                # Shutters have slats and offset hinges, rather than painted rectangles.
                if j%2==0:
                    for sign in [-1,1]:
                        xx=cx+sign*.99
                        for t in range(12):part('wood',xx,-.22,lo+.09+t*(hi-lo-.18)/12,.48,.07,.095)
                        for dx in [-.23,.23]:part('wood',xx+dx,-.21,cz,.065,.085,hi-lo)
        # Chipped plaster islands expose masonry on the exterior.
        for k in range(155 if damaged else 12):
            xx=rng.uniform(-length/2+.3,length/2-.3);zz=rng.uniform(.55,eave-.2)
            if any(o[0]-.15<xx<o[1]+.15 and o[2]-.15<zz<o[3]+.15 for o in opens):continue
            if damaged and side==0 and xx<-3.7 and zz>3.3:continue
            radius=rng.uniform(.018,.10)*(2.1 if damaged and k%13==0 else 1)
            vs=[pos(xx,-.169,zz)]+[pos(xx+math.cos(a)*radius*rng.uniform(.65,1.3),-.171,zz+math.sin(a)*radius*.7*rng.uniform(.6,1.4)) for a in [i*math.tau/7 for i in range(7)]]
            face('brick',vs,[(0,i+1,(i+1)%7+1) for i in range(7)])
        part('trim',0,-.03,3.43,length+.05,.40,.095)
    # Solid gable ends, ridge along X; pitched roof has separate rafters and battens.
    for x in [-w/2,w/2]:
        face('plaster',[(x,-dep/2,eave),(x,dep/2,eave),(x,0,ridge)],[(0,1,2),(2,1,0)])
    for i in range(17):
        x=-w/2-.25+i*(w+.5)/16
        for sign in [-1,1]:
            if damaged and sign==-1 and i in [3,5,12]:
                beam('wood',(x+(.30 if i%2 else -.12),sign*2.6,ridge-1.92),(x,sign*(dep/2+.32),eave-.16),.15,.18)
            else:beam('wood',(x,0,ridge-.08),(x,sign*(dep/2+.32),eave-.16),.15,.18)
    pitch=(ridge-eave)/(dep/2+.35)
    for sign in [-1,1]:
        for row in range(15):
            y=sign*(row*.32+.1);z=ridge-abs(y)*pitch
            beam('wood',(-w/2-.3,y,z-.05),(w/2+.3,y,z-.05),.065,.065)
        for row in range(17):
            yy=(row+.55)*(dep/2+.35)/17
            for col in range(38):
                xx=-w/2-.34+(col+.5)*(w+.68)/38
                missing=damaged and ((sign==-1 and (((xx+2.5)/1.65)**2+((yy-.8)/3.0)**2<1+rng.uniform(-.25,.25) or ((xx-3.8)/1.65)**2+(yy/2.4)**2<1)) or (sign==1 and ((xx+1.2)/1.6)**2+(yy/2.9)**2<1+rng.uniform(-.2,.2)))
                if missing or (damaged and rng.random()<.055):continue
                verts=[]
                for v in [0,1]:
                    for u in range(5):
                        x=xx+(u/4-.5)*.36;y=sign*(yy+(v-.5)*.33)
                        z=ridge-abs(y)*pitch+.055+.024*math.sin(u/4*math.pi)+rng.uniform(-.004,.004)
                        verts.append((x,y,z))
                face('roof',verts,[(i,i+1,i+6,i+5) if sign==1 else (i+5,i+6,i+1,i) for i in range(4)])
        beam('metal',(-w/2-.4,sign*(dep/2+.4),eave-.14),(w/2+.4,sign*(dep/2+.4),eave-.14),.14,.15)
    for x in [-w/2+.08,w/2-.08]:beam('metal',(x,-dep/2-.4,eave-.15),(x,-dep/2-.4,.4),.095)
    # Chimney crown and inset black flue.
    box('brick',(3,1.1,8.85),(.86,.95,2.5));box('trim',(3,1.1,10.12),(1.05,1.12,.18));box('interior',(3,1.1,10.22),(.60,.69,.04))
    # Fracture edge made of offset exposed courses, the interior remains visible.
    if damaged:
        for row in range(23):
            z=3.5+row*.13
            for j in range(2+(row%3)):
                x=-3.67-j*.23+rng.uniform(-.035,.04)
                box('brick',(x,-dep/2,z),(.22,.39,.115))
        for i in range(190):
            a=rng.uniform(0,math.tau);rad=rng.uniform(0,3.5)
            x=-4+math.cos(a)*rad;y=-dep/2-.25-abs(math.sin(a))*rad
            z=.1+max(0,1-rad/2.7)*rng.uniform(.1,.55)
            box('brick' if i%3 else 'plaster',(x,y,z),(rng.uniform(.12,.38),rng.uniform(.13,.40),rng.uniform(.1,.24)),Matrix.Rotation(rng.uniform(-1,1),3,'X')@Matrix.Rotation(a,3,'Z'))
    # Porch: structural columns, door surround and individual broken slats.
    box('trim',(0,-dep/2-1.0,.18),(3.8,2.3,.3))
    for x in [-1.6,1.6]:box('plaster',(x,-dep/2-1.8,1.65),(.28,.28,3.0))
    for i in range(18):
        if damaged and i in [1,3,9,12]:continue
        box('wood',(-1.9+i*.22,-dep/2-.85,3.25),(.21,2.1,.095),Matrix.Rotation(.10,3,'X'))
    for mat,(verts,faces) in batches.items():
        me=bpy.data.meshes.new(mat);me.from_pydata(verts,[],faces);me.update()
        ob=bpy.data.objects.new(mat,me);bpy.context.collection.objects.link(ob)
        m=bpy.data.materials.new(mat);m.diffuse_color=colors[mat];m.use_nodes=True
        bs=m.node_tree.nodes.get('Principled BSDF');bs.inputs['Base Color'].default_value=colors[mat];bs.inputs['Roughness'].default_value=.84 if mat!='glass' else .24
        ob.data.materials.append(m)
        uv=me.uv_layers.new(name='UVMap')
        for poly in me.polygons:
            axis=max(range(3),key=lambda i:abs(poly.normal[i]));a,b=[i for i in range(3) if i!=axis]
            for li in poly.loop_indices:
                co=me.vertices[me.loops[li].vertex_index].co;uv.data[li].uv=(co[a]/3,co[b]/3)
    bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',export_animations=False,export_tangents=True)
    print('HOUSE_KIT_READY',name,flush=True)
build('house_damaged',True)
build('house_intact',False)
