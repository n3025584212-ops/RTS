"""Structural replacement for the local hero house (Blender metres, Z up).

The same corner failure cuts the roof, gable, eave and upper floor. UVs are
assigned in component coordinates before batching, so timber grain follows beams.
No gameplay destruction is introduced: this is an authored static ruin variant.
"""
import math
import random
from mathutils import Vector, Matrix


def roof_cut(x, y):
    # Failure occupies the front-right bay; back slope and chimney stay supported.
    return x > 1.65 + .22*math.sin(y*3.7) and y < -.65 + .15*math.sin(x*4.1)


def build_structure(face, box, beam, noise, width, depth, eave, ridge, seed):
    rng = random.Random(seed + 4081)
    half = depth/2 + .35
    pitch = (ridge-eave)/half

    def timber(a,b,w=.16,d=.20):
        beam('wood',a,b,w,d)

    def broken_timber(a,b,w=.16,d=.20):
        # A solid end with a toothed fracture, not an empty tube or a flat cutoff.
        a,b=Vector(a),Vector(b)
        direction=b-a
        rotation=direction.to_track_quat('Z','Y').to_matrix()
        length=direction.length
        ring=[(-w/2,-d/2), (w/2,-d/2), (w/2,d/2), (-w/2,d/2)]
        verts=[a+rotation@Vector((x,y,0)) for x,y in ring]
        verts += [a+rotation@Vector((x,y,length+rng.uniform(-.14,.06))) for x,y in ring]
        uvs=[(y/1.5, .062+x*.20) for x,y in [(0,0),(w,0),(w,0),(0,0),(0,length),(w,length),(w,length),(0,length)]]
        face('wood',verts,[(3,2,1,0),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7),(4,5,6,7)],uvs)

    # Actual floorboards over the load-bearing joists; the destroyed bay is open.
    box('interior',(0,0,.40),(width-.44,depth-.44,.16))
    for i in range(45):
        x=-width/2+.28+i*.248
        start=-depth/2+.22
        if x>2.25:
            start=-1.45+.38*math.sin(i*1.9)
        # Stairwell is a real opening in the upper floor.
        segments=[(start,depth/2-.22)]
        if -1.7<x<-.35:
            segments=[(start,.15),(3.62,depth/2-.22)]
        for a,b in segments:
            if b-a>.10:
                box('wood',(x,(a+b)/2,3.46),(.239,b-a,.065))
    for y in [-3.85,-2.95,-2.05,-1.15,-.25,.65,3.85]:
        right=width/2-.2 if y>-.9 else 2.45+.18*math.sin(y*3)
        broken_timber((-width/2+.16,y,3.24),(right,y,3.24),.18,.27)
    for x in [-1.83,-.22]:
        timber((x,.05,3.25),(x,3.76,3.25),.18,.26)
    timber((-1.83,.05,3.25),(-.22,.05,3.25),.18,.26)
    timber((-1.83,3.76,3.25),(-.22,3.76,3.25),.18,.26)
    for i in range(16):
        y=.25+i*.207
        z=.57+i*.181
        box('wood',(-1.02,y,z),(1.31,.255,.065))
    for x in [-1.7,-.36]:
        timber((x,.13,.40),(x,3.61,3.32),.13,.21)
        timber((x,.28,1.42),(x,3.50,4.31),.055,.075)
        for i in range(0,16,3):
            y=.25+i*.207;z=.57+i*.181
            timber((x,y,z),(x,y,z+.92),.036,.04)

    # An interior partition with a full-height doorway separates the rooms.
    for z in [.5,3.50]:
        height=2.8
        box('interior',(.70,-2.60,z+height/2),(.16,2.72,height))
        box('interior',(.70,2.30,z+height/2),(.16,3.25,height))
        box('interior',(.70,-.28,z+2.53),(.16,1.91,.54))
        for y in [-1.23,.66]:
            box('wood',(.70,y,z+1.12),(.22,.065,2.24))
        box('wood',(.70,-.28,z+2.25),(.22,1.96,.085))
        # Baseboards give depth and a readable wall/floor joint.
        for y in [-3.97,3.97]:
            box('wood',(0,y,z+.09),(width-.40,.04,.16))

    # Gable fracture uses a clipped masonry section, including its thickness.
    def clip(poly,field):
        if not poly:return []
        result=[];a=poly[-1];da=field(*a)
        for b in poly:
            db=field(*b)
            if (da>=0)!=(db>=0):
                t=da/(da-db);result.append((a[0]+(b[0]-a[0])*t,a[1]+(b[1]-a[1])*t))
            if db>=0:result.append(b)
            a,da=b,db
        return result
    for side in [-1,1]:
        x=side*width/2
        for i in range(48):
            y0=-depth/2+i*depth/48;y1=y0+depth/48
            for j in range(18):
                z0=eave+j*(ridge-eave)/18;z1=z0+(ridge-eave)/18
                poly=clip([(y0,z0),(y1,z0),(y1,z1),(y0,z1)],lambda y,z:ridge-abs(y)*(ridge-eave)/(depth/2)-z)
                if side>0:poly=clip(poly,lambda y,z:y+.76-.22*math.sin(z*4.8)-.12*math.sin(z*11.))
                poly=[point for k,point in enumerate(poly) if math.dist(point,poly[k-1])>1e-7]
                if len(poly)<3:continue
                area=abs(sum(poly[k-1][0]*point[1]-point[0]*poly[k-1][1] for k,point in enumerate(poly)))*.5
                if area<1e-9:continue
                order=tuple(range(len(poly)))
                face('plaster',[(x+side*.16,y,z) for y,z in poly],[order if side>0 else order[::-1]])
                face('interior',[(x-side*.16,y,z) for y,z in poly],[order[::-1] if side>0 else order])
                for k in range(len(poly)):
                    a=poly[k];b=poly[(k+1)%len(poly)]
                    on_cell=(abs(a[0]-b[0])<1e-6 and (abs(a[0]-y0)<1e-6 or abs(a[0]-y1)<1e-6)) or (abs(a[1]-b[1])<1e-6 and (abs(a[1]-z0)<1e-6 or abs(a[1]-z1)<1e-6))
                    if not on_cell:
                        face('brick',[(x-.16,*a),(x+.16,*a),(x+.16,*b),(x-.16,*b)],[(0,1,2,3)])

    # Complete trusses in surviving bays; purlins support the remaining roof.
    for x in [-4.7,-1.7,1.05,4.75]:
        broken_timber((x,depth/2-.1,6.32),(x,-.50 if x>1.65 else -depth/2+.1,6.32),.22,.28)
        timber((x,0,6.30),(x,0,ridge-.13),.19,.21)
        for sign in [-1,1]:
            if roof_cut(x,sign*2.3):continue
            timber((x,0,6.42),(x,sign*2.4,7.82),.14,.17)
    timber((-6.0,0,9.28),(6.0,0,9.28),.19,.24)
    for sign in [-1,1]:
        for yabs in [1.65,3.40]:
            y=sign*yabs;right=1.50 if sign<0 else 6.0
            broken_timber((-6,y,ridge-yabs*pitch-.23),(right,y,ridge-yabs*pitch-.23),.19,.23)
    for i in range(20):
        x=-6.04+i*12.08/19
        for sign in [-1,1]:
            if sign<0 and x>1.65:
                end_y=-.60-rng.uniform(0,.27)
                broken_timber((x,0,ridge-.12),(x,end_y,ridge-abs(end_y)*pitch-.12),.125,.18)
            else:
                timber((x,0,ridge-.12),(x,sign*half,eave-.12),.125,.18)
    for sign in [-1,1]:
        for row in range(19):
            y=sign*(row*.245+.10);z=ridge-abs(y)*pitch-.015
            end=1.52+.18*math.sin(y*3.7) if sign<0 and y<-.65 else 6.13
            broken_timber((-6.13,y,z),(end,y,z),.055,.07)

    # Individually UV-mapped clay tiles. Each samples ONE photographed tile face.
    patches=[(.090,.044,.125,.132),(.275,.205,.308,.292),(.455,.520,.485,.604),
             (.535,.205,.565,.292),(.785,.670,.816,.756),(.365,.828,.394,.910)]
    def tile(center_x,center_y,row,col,sign,fallen=False,rotation=None):
        verts=[]
        uv=[]
        patch=patches[(col*7+row*3)%len(patches)]
        jitter=rng.uniform(-.008,.008)
        for v in [0,1]:
            for u in range(5):
                xx=center_x+(u/4-.5)*.265
                yy=center_y+sign*(v-.5)*.325
                zz=ridge-abs(yy)*pitch+.028+.018*math.sin(u/4*math.pi)+v*.038+jitter
                verts.append(Vector((xx,yy,zz)))
                uv.append((patch[0]+(patch[2]-patch[0])*u/4,patch[1]+(patch[3]-patch[1])*v))
        if fallen:
            pivot=Vector((center_x,center_y,ridge-abs(center_y)*pitch))
            verts=[rotation@(p-pivot)+Vector((center_x,center_y,.36)) for p in verts]
        surface=[(i,i+1,i+6,i+5) if sign==1 else (i+5,i+6,i+1,i) for i in range(4)]
        face('roof',verts,surface,uv)
        lower=[p-Vector((0,0,.018)) for p in verts]
        face('roof',lower,[tuple(reversed(f)) for f in surface],uv)
        edge=[0,1,2,3,4,9,8,7,6,5]
        for a,b in zip(edge,edge[1:]+edge[:1]):
            face('roof',[verts[a],verts[b],lower[b],lower[a]],[(0,1,2,3)],[uv[a],uv[b],uv[b],uv[a]])
    for sign in [-1,1]:
        for row in range(19):
            yy=sign*(.12+row*.245)
            for col in range(46):
                xx=-6.13+(col+.5)*.267+(row%2)*.03
                if roof_cut(xx,yy):continue
                # A few local losses beside the failure, rather than holes everywhere.
                if sign<0 and 1.05<xx<1.70 and row in [3,4,8,12,13]:continue
                tile(xx,yy,row,col,sign)
        right=1.52 if sign<0 else 6.22
        # Eave fascia follows the surviving roof. Broken front drain falls below it.
        timber((-6.20,sign*(half+.02),eave-.18),(right,sign*(half+.02),eave-.18),.13,.22)
        beam('metal',(-6.2,sign*(half+.13),eave-.2),(right,sign*(half+.13),eave-.2),.13,.13)
    broken_timber((1.48,-half-.05,eave-.2),(2.45,-half-.38,4.87),.13,.18)
    # Curved ridge caps are physical half cylinders, with closed thickness.
    for i in range(36):
        x=-6.18+i*.34
        verts=[];uv=[]
        for end in [0,1]:
            for j in range(9):
                a=j*math.pi/8
                verts.append((x+end*.36,math.cos(a)*.23,ridge-.12+math.sin(a)*.22))
                uv.append((.09+j*.004,.045+end*.07))
        face('roof',verts,[(j,j+1,j+10,j+9) for j in range(8)],uv)
        inner=[(vx,vy*.89,vz-.020) for vx,vy,vz in verts]
        face('roof',inner,[(j+9,j+10,j+1,j) for j in range(8)],uv)
        for end in [0,9]:
            for j in range(8):
                a=end+j;b=a+1
                face('roof',[verts[a],verts[b],inner[b],inner[a]],[(0,1,2,3)],[uv[a],uv[b],uv[b],uv[a]])
        for a,b in [(0,9),(8,17)]:
            face('roof',[verts[a],verts[b],inner[b],inner[a]],[(0,1,2,3)],[uv[a],uv[b],uv[b],uv[a]])

    # Collapsed timbers land in the destroyed floor bay and just outside it.
    dropped_rafters=[]
    for i in range(4):
        x=2.35+i*.70
        a=Vector((x,-.70,5.85-i*.29));b=Vector((x+rng.uniform(-.38,.45),-3.70+rng.uniform(-.35,.45),3.56+i*.09))
        broken_timber(a,b,.125,.18);dropped_rafters.append((a,b))
    for t in [.21,.46,.71]:
        for i in range(3):
            if i==2 and t==.46:continue
            a,b=dropped_rafters[i];c,d=dropped_rafters[i+1]
            timber(a.lerp(b,t)+Vector((0,0,.10)),c.lerp(d,t)+Vector((0,0,.10)),.055,.07)
    for i in range(6):
        x=2.35+i*.48
        broken_timber((x,-1.35,3.22),(x+.25,-4.12,.65+i*.075),.16,.22)
    # Floorboards stay attached to part of the dropped joist section.
    for i in range(10):
        t=.16+i*.065
        y=-1.35+(-4.12+1.35)*t;z=3.22+(.85-3.22)*t+.10
        left=2.4+rng.uniform(0,.40);right=4.92-rng.uniform(0,.55)
        timber((left,y,z),(right,y,z),.16,.048)
    for i in range(7):
        x=2.7+rng.uniform(-.4,2.8);y=-4.8-rng.uniform(.0,1.9)
        broken_timber((x-.55,y,.28),(x+.75,y+.38,.52),.13,.15)

    # A few broken wall slabs have a masonry body and a separate plaster skin.
    for i in range(11):
        x=3.3+rng.uniform(-.9,2.3);y=-4.8-rng.uniform(0,1.3)
        rotation=Matrix.Rotation(rng.uniform(-.42,.42),3,'X')@Matrix.Rotation(rng.uniform(-2,2),3,'Z')
        size=(rng.uniform(.42,.78),rng.uniform(.32,.61),rng.uniform(.12,.22))
        box('brick',(x,y,.20),size,rotation)
        box('plaster',Vector((x,y,.20))+rotation@Vector((0,0,size[2]/2+.018)),(size[0]*.91,size[1]*.88,.032),rotation)

    # Furniture helps read scale and room depth through the breach, without lights.
    box('wood',(3.70,1.8,4.25),(1.55,.78,.065))
    for x in [3.08,4.32]:
        for y in [1.50,2.10]:box('wood',(x,y,3.84),(.065,.065,.75))
    box('wood',(4.75,3.70,4.25),(1.2,.48,1.50))
    for z in [3.57,4.05,4.53,4.98]:box('wood',(4.75,3.40,z),(1.20,.06,.065))
