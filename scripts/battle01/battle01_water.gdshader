shader_type spatial;
render_mode diffuse_burley,specular_schlick_ggx;

varying vec3 wp;

float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n(vec2 p){
 vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
 return mix(mix(h(i),h(i+vec2(1,0)),f.x),mix(h(i+vec2(0,1)),h(i+vec2(1,1)),f.x),f.y);
}

void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}

void fragment(){
 float broad=n(wp.xz*.22);
 float fine=n(wp.xz*2.4);
 vec3 deep=vec3(.018,.050,.060);
 vec3 silt=vec3(.072,.083,.061);
 ALBEDO=mix(deep,silt,broad*.36+fine*.06);
 ROUGHNESS=mix(.16,.29,fine);
 METALLIC=0.0;
 SPECULAR=.72;
 vec2 ripple=vec2(
  sin(wp.x*1.9+wp.z*.48)+sin(wp.z*3.1),
  cos(wp.z*1.7-wp.x*.43)+sin(wp.x*2.6)
 )*.022;
 NORMAL_MAP=vec3(.5+ripple.x,.5+ripple.y,1.0);
 NORMAL_MAP_DEPTH=.42;
}
