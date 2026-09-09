shader_type spatial;
render_mode diffuse_burley,specular_schlick_ggx;

varying vec3 wp;

float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){
 vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}

void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}

void fragment(){
 float broad=noise(wp.xz*.055);
 float ripple=noise(wp.xz*1.7);
 vec3 shallow=vec3(.080,.070,.046);
 vec3 deep=vec3(.038,.052,.052);
 ALBEDO=mix(deep,shallow,broad*.46+ripple*.08);
 ROUGHNESS=mix(.10,.28,ripple);
 METALLIC=0.0;
 SPECULAR=.88;
 // Tangent-space micro ripples; large shapes come from reflected environment.
 vec2 wave=vec2(
  sin(wp.x*.82+wp.z*.31)+sin(wp.z*1.73),
  cos(wp.z*.77-wp.x*.28)+sin(wp.x*1.41)
 )*.035;
 NORMAL_MAP=vec3(.5+wave.x,.5+wave.y,1.0);
 NORMAL_MAP_DEPTH=.58;
}
