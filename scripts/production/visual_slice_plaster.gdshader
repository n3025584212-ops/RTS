shader_type spatial;
uniform sampler2D color_texture : source_color,filter_linear_mipmap_anisotropic,repeat_enable;
uniform sampler2D normal_texture : hint_normal,filter_linear_mipmap_anisotropic,repeat_enable;
varying vec3 wp;
float h(vec3 p){p=fract(p*.1031);p+=dot(p,p.zyx+33.33);return fract((p.x+p.y)*p.z);}
float n(vec3 p){vec3 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(mix(h(i),h(i+vec3(1,0,0)),f.x),mix(h(i+vec3(0,1,0)),h(i+vec3(1,1,0)),f.x),f.y),mix(mix(h(i+vec3(0,0,1)),h(i+vec3(1,0,1)),f.x),mix(h(i+vec3(0,1,1)),h(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 vec3 scan=texture(color_texture,UV*.8).rgb;
 vec3 color=mix(vec3(.43,.405,.346),scan,.30);
 float stains=smoothstep(.50,.72,n(wp*vec3(1.7,.09,1.7)))*.23;
 float damp=(1.-smoothstep(.15,1.9,wp.y))*.32;
 ALBEDO=color*(1.-stains-damp);
 ROUGHNESS=.94;
 NORMAL_MAP=texture(normal_texture,UV*.8).rgb;NORMAL_MAP_DEPTH=.42;
}
