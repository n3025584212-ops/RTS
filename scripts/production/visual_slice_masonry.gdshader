shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// The generator exports all eight parts in one common building coordinate system.
// Object-space finish follows translation, rotation and scale without per-frame work.
uniform sampler2D plaster_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D plaster_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D brick_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D brick_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool exposed_brick = false;
uniform float weathering : hint_range(0.0, 1.0) = 0.72;
varying vec3 p;
varying vec3 local_normal;

float hash(vec3 q){q=fract(q*.1031);q+=dot(q,q.zyx+33.33);return fract((q.x+q.y)*q.z);}
float noise3(vec3 q){
 vec3 i=floor(q),f=fract(q);f=f*f*(3.-2.*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),
 mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
vec3 triplanar(sampler2D tex, vec3 pos, vec3 w){
 return texture(tex,pos.zy).rgb*w.x+texture(tex,pos.xz).rgb*w.y+texture(tex,pos.xy).rgb*w.z;
}
void vertex(){
 p=VERTEX;
 local_normal=normalize(NORMAL);
}
void fragment(){
 vec3 w=pow(abs(local_normal),vec3(8.)); w/=max(w.x+w.y+w.z,.0001);
 float broad=noise3(p*.42+vec3(4.7,2.,6.));
 float grain=noise3(p*13.3);
 vec3 scan=triplanar(plaster_color,p*.38,w);
 vec3 brick_scan=triplanar(brick_color,p*vec3(.53,.47,.53),w);
 // Continuous broken render edges expose courses below the lime plaster.
 float loss=noise3(p*1.62)*.64+noise3(p*5.2)*.24+grain*.12;
 float foot=1.-smoothstep(.2,1.38+noise3(p*2.)*.45,p.y);
 // Exposed masonry is selected by actual missing plaster geometry.
 float peeling=exposed_brick ? 1. : 0.;
 float flank=mix(p.x,p.z,w.x);
 float course=floor(p.y/.12);
 vec2 brick_uv=vec2(flank/.27+mod(course,2.)*.5,p.y/.12);
 vec2 cell=fract(brick_uv);
 float joint=(1.-smoothstep(.025,.08,cell.x))+(1.-smoothstep(.02,.085,cell.y));
 joint=clamp(joint,0.,1.);
 float variation=hash(vec3(floor(brick_uv),2.3));
 vec3 fired=brick_scan*mix(vec3(.34,.25,.18),vec3(.55,.43,.31),variation);
 fired=mix(fired,vec3(.16,.145,.115),joint*.8);
 vec3 lime=scan*mix(vec3(.77,.75,.67),vec3(.96,.91,.77),broad);
 float capillary=foot*(.25+noise3(p*3.)*.17);
 float streak=smoothstep(.58,.77,noise3(p*vec3(4.3,.14,4.3)))*weathering;
 float fine_streak=smoothstep(.66,.82,noise3(p*vec3(15.,.45,15.)))*.1;
 // Smoke staining follows the upper breached facade; damp dirt belongs at grade.
 float breach=exp(-pow((p.x-1.6)/2.8,2.))*smoothstep(2.8,4.8,p.y)*(1.-smoothstep(5.8,7.7,p.y))*smoothstep(3.3,4.2,p.z);
 lime*=1.-capillary-streak*.13-fine_streak-breach*weathering*.28;
 vec3 color=mix(lime,fired,peeling);
 float lip=0.; // Plaster lips and their shadows are exported mesh sidewalls.
 color*=1.-lip*.18*weathering;
 ALBEDO=color;
 ROUGHNESS=mix(.86,.98,peeling)-capillary*.13;
 SPECULAR=.28;
 AO=1.-peeling*joint*.18-lip*.1;
 // Screen-space differential bump preserves the actual face orientation on
 // gables, reveals and corners without inheriting per-box UV scale seams.
 vec3 micro=triplanar(plaster_normal,p*.38,w)*2.-1.;
 float relief=(1.-peeling)*.019+grain*.0025+(micro.x+micro.y)*.003-joint*peeling*.005;
 vec3 q0=dFdx(VERTEX),q1=dFdy(VERTEX);
 vec3 r0=cross(q1,NORMAL),r1=cross(NORMAL,q0);
 float det=dot(q0,r0);
 vec3 grad=(r0*dFdx(relief)+r1*dFdy(relief))*sign(det)/max(abs(det),.00001);
 NORMAL=normalize(NORMAL-grad);
}
