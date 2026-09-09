shader_type spatial;
render_mode diffuse_burley,specular_schlick_ggx;

uniform sampler2D color_texture : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D normal_texture : hint_normal,filter_linear_mipmap_anisotropic,repeat_enable;

varying vec3 wp;
varying vec3 wn;

float h(vec3 p){p=fract(p*.1031);p+=dot(p,p.zyx+33.33);return fract((p.x+p.y)*p.z);}
float n(vec3 p){
 vec3 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
 return mix(
  mix(mix(h(i),h(i+vec3(1,0,0)),f.x),mix(h(i+vec3(0,1,0)),h(i+vec3(1,1,0)),f.x),f.y),
  mix(mix(h(i+vec3(0,0,1)),h(i+vec3(1,0,1)),f.x),mix(h(i+vec3(0,1,1)),h(i+vec3(1,1,1)),f.x),f.y),f.z
 );
}

void vertex(){
 wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;
 wn=normalize(MODEL_NORMAL_MATRIX*NORMAL);
}

void fragment(){
 vec3 scan=texture(color_texture,UV*.92).rgb;
 float broad=n(wp*.22);
 float mids=n(wp*1.35+vec3(7.,2.,3.));
 float fine=n(wp*9.0);

 // Keep the scanned plaster visible while adding long-term surface history.
 vec3 warm_lime=mix(vec3(.255,.247,.218),vec3(.43,.405,.342),broad);
 vec3 color=mix(warm_lime,scan*.82,.70);

 float ground_damp=(1.-smoothstep(.18,1.75,wp.y))*(.30+.28*mids);
 float rain_streak=smoothstep(.56,.80,n(wp*vec3(1.35,.075,1.35)+vec3(4.,0.,1.)))*.22;
 float soot=smoothstep(.69,.86,n(wp*.72+vec3(19.,4.,11.)))*smoothstep(.12,.82,1.-abs(wn.y))*.18;
 float mineral=smoothstep(.70,.88,fine)*.12;

 color*=1.-ground_damp-rain_streak-soot;
 color=mix(color,vec3(.51,.48,.39),mineral);

 ALBEDO=color;
 ROUGHNESS=clamp(.82+ground_damp*.12+rain_streak*.07-mineral*.05,.64,.97);
 SPECULAR=.28;
 NORMAL_MAP=texture(normal_texture,UV*.92).rgb;
 NORMAL_MAP_DEPTH=.92;
}
