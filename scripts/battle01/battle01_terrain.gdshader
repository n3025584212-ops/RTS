shader_type spatial;
render_mode diffuse_burley,specular_schlick_ggx;

uniform sampler2D grass_color : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D soil_color : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D soil_normal : hint_normal,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D soil_roughness : filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D gravel_color : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D asphalt_color : source_color,filter_linear_mipmap_anisotropic,repeat_enable;

varying vec3 wp;

float h(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float n(vec2 p){
 vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
 return mix(mix(h(i),h(i+vec2(1,0)),f.x),mix(h(i+vec2(0,1)),h(i+vec2(1,1)),f.x),f.y);
}
float band(float value,float center,float half_width,float feather){
 return 1.-smoothstep(half_width,half_width+feather,abs(value-center));
}

void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}

void fragment(){
 vec2 p=wp.xz;
 float macro=n(p*.16);
 float broad=n(p*.045);
 float detail=n(p*.72);

 // Battle01 authoritative map is 32m x 18m in the 3D adapter.
 float main_road=band(p.y,9.0,.34,.30);
 float north_lane=band(p.y,6.5+.28*sin(p.x*.32),.30,.45);
 float south_lane=band(p.y,13.7+.38*sin(p.x*.21),.55,.62);
 float industrial= smoothstep(24.0,27.5,p.x);
 float river_bank=1.-smoothstep(1.20,2.30,abs(p.x-16.0));

 vec3 grass=texture(grass_color,p*.52).rgb*mix(vec3(.17,.21,.085),vec3(.39,.37,.18),broad);
 vec3 soil=texture(soil_color,p.yx*.31).rgb*vec3(.54,.43,.29);
 vec3 gravel=texture(gravel_color,p*.63).rgb*vec3(.47,.43,.34);
 vec3 asphalt=texture(asphalt_color,p*.40).rgb*vec3(.50,.49,.47);

 float churn=max(north_lane,south_lane)*mix(.66,1.0,detail);
 float damp=river_bank*(.25+.52*macro);
 vec3 col=mix(grass,soil,churn);
 col=mix(col,gravel,max(north_lane,south_lane)*.45);
 col=mix(col,asphalt,main_road);
 col=mix(col,soil*.52,damp);
 col=mix(col,gravel*.72,industrial*.16);
 col*=mix(.78,1.08,macro);

 ALBEDO=col;
 float soil_r=texture(soil_roughness,p.yx*.31).r;
 float rough=mix(.94,clamp(soil_r*.78,.30,.82),max(churn,damp));
 rough=mix(rough,.48,main_road);
 ROUGHNESS=rough;
 SPECULAR=mix(.28,.48,damp);
 NORMAL_MAP=texture(soil_normal,p.yx*.31).rgb;
 NORMAL_MAP_DEPTH=mix(.42,.72,max(churn,damp));
 AO=clamp(.96-damp*.11,0.,1.);
}
