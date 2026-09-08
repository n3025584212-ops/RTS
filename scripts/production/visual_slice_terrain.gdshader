shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;
uniform sampler2D grass_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D gravel_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D asphalt_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
varying vec3 world;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){world=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec2 p=world.xz;float n=noise(p*.21);float macro=noise(p*.024);
 float route=p.x-(-1.0+0.12*p.y+1.2*sin(p.y*.045));
 float mud=1.-smoothstep(3.0,6.4+n*2.,abs(route));
 float road=1.-smoothstep(3.0,4.3,abs(p.y+19.-sin(p.x*.04)*2.0)+n*.65);
 vec3 grass=texture(grass_color,p*.32).rgb*mix(vec3(.15,.19,.07),vec3(.35,.34,.17),macro);
 vec3 soil=texture(soil_color,p.yx*.10).rgb*vec3(.52,.42,.30);
 vec3 gravel=texture(gravel_color,p*.43).rgb*vec3(.42,.39,.31);
 vec3 asphalt=texture(asphalt_color,p*.2).rgb*vec3(.48,.46,.43);
 vec3 col=mix(grass,soil,mud);col=mix(col,gravel,road);col=mix(col,asphalt,1.-smoothstep(2.55,3.05,abs(p.y+19.-sin(p.x*.04)*2.)+n*.5));
 float rut=1.-smoothstep(.29,.62,min(abs(route-1.30),abs(route+1.30)));
 col*=mix(1.,.62,rut*mud); col*=mix(.78,1.06,noise(p*.057));
 ALBEDO=col;ROUGHNESS=mix(.94,.53,mud);SPECULAR=.3;
 NORMAL_MAP=texture(soil_normal,p.yx*.10).rgb;NORMAL_MAP_DEPTH=.5;
}
