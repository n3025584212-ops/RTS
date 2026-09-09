shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform sampler2D grass_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D gravel_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D asphalt_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_height : filter_linear_mipmap_anisotropic, repeat_enable;

varying vec3 world;
varying vec3 world_normal;

float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){
 vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);
}

void vertex(){
 world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;
 world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);
}

void fragment(){
 vec2 p=world.xz;
 float n1=noise(p*.21);
 float n2=noise(p*.73);
 float macro=noise(p*.024);

 float route=p.x-(1.3+0.12*p.y+1.2*sin(p.y*.045));
 float lane_distance=abs(route);
 float mud=1.-smoothstep(2.8,6.3+n1*2.2,lane_distance);
 float crossroad=abs(p.y+19.-sin(p.x*.04)*2.0);
 float road=1.-smoothstep(3.0,4.4,crossroad+n1*.62);
 float asphalt_core=1.-smoothstep(2.45,3.02,crossroad+n1*.46);

 vec3 grass=texture(grass_color,p*.34).rgb*mix(vec3(.14,.18,.065),vec3(.36,.35,.17),macro);
 vec3 soil=texture(soil_color,p.yx*.105).rgb*vec3(.62,.49,.33);
 vec3 gravel=texture(gravel_color,p*.46).rgb*vec3(.43,.395,.305);
 vec3 asphalt=texture(asphalt_color,p*.22).rgb*vec3(.47,.455,.43);

 // Patchy shoulders and churned margins prevent a clean mathematical strip.
 float shoulder=noise(p*.11+vec2(5.7,2.3));
 float churn=mud*mix(.68,1.0,smoothstep(.28,.76,shoulder+n2*.25));
 vec3 col=mix(grass,soil,churn);
 col=mix(col,gravel,road);
 col=mix(col,asphalt,asphalt_core);

 float rut_center=min(abs(route-1.30),abs(route+1.30));
 float rut=1.-smoothstep(.24,.67,rut_center);
 float wet_noise=smoothstep(.42,.75,noise(p*.38+vec2(12.1,3.2)));
 float relief=texture(soil_height,p.yx*.10).r;
 float low_pockets=1.-smoothstep(.34,.60,relief);
 float wet=rut*mud*(.14+.86*wet_noise)*mix(.32,1.,low_pockets);
 float damp_margin=mud*(1.-rut)*smoothstep(.61,.82,n2)*.28;

 col*=mix(1.,.68,rut*mud);
 col=mix(col,vec3(.035,.026,.016),wet*.58+damp_margin*.20);
 float dry_ridge=smoothstep(.52,.69,relief)*(1.-wet)*mud;
 col*=1.+dry_ridge*.22;
 col*=mix(.80,1.05,noise(p*.057));

 ALBEDO=col;

 float soil_r=texture(soil_roughness,p.yx*.105).r;
 float rough=mix(.94,clamp(soil_r*.40+.48,.58,.94),mud);
 rough=mix(rough,.14,wet);
 rough=mix(rough,.46,asphalt_core);
 ROUGHNESS=clamp(rough,.16,.97);
 SPECULAR=mix(.28,.72,wet);

 NORMAL_MAP=texture(soil_normal,p.yx*.105).rgb;
 NORMAL_MAP_DEPTH=mix(.44,.72,mud);
 AO=clamp(.92-rut*mud*.18,0.,1.);
}
