shader_type spatial;
render_mode diffuse_burley,specular_schlick_ggx;
uniform sampler2D paint_texture : source_color,filter_linear_mipmap_anisotropic;
uniform sampler2D normal_texture : hint_normal,filter_linear_mipmap_anisotropic;
uniform sampler2D rough_texture : hint_default_white,filter_linear_mipmap_anisotropic;
uniform vec4 paint_color : source_color = vec4(1.);
uniform float roughness_factor=1.;
uniform float ground_y=0.;
uniform bool has_normal=false;
uniform vec4 rough_channel=vec4(0.,1.,0.,0.);
varying vec3 wp;
varying vec3 wn;
float h(vec3 p){p=fract(p*.1031);p+=dot(p,p.zyx+33.33);return fract((p.x+p.y)*p.z);}
float n(vec3 p){vec3 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(mix(h(i),h(i+vec3(1,0,0)),f.x),mix(h(i+vec3(0,1,0)),h(i+vec3(1,1,0)),f.x),f.y),mix(mix(h(i+vec3(0,0,1)),h(i+vec3(1,0,1)),f.x),mix(h(i+vec3(0,1,1)),h(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;wn=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec3 base=texture(paint_texture,UV).rgb*paint_color.rgb;
 float height=wp.y-ground_y;
 float dirt=n(wp*4.1)*.65+n(wp*19.2)*.35;
 float mud=(1.-smoothstep(.18,1.25+dirt*.32,height))*.86;
 float dust=smoothstep(.36,.76,n(wp*2.7))*mix(.07,.29,max(wn.y,0.));
 float streak=smoothstep(.61,.77,n(wp*vec3(20.,1.1,20.)))*.20;
 base=mix(base,vec3(.18,.147,.091),dust);
 base*=1.-streak;
 base=mix(base,mix(vec3(.043,.031,.017),vec3(.13,.097,.054),dirt),mud);
 ALBEDO=base;
 float authored=dot(texture(rough_texture,UV),rough_channel)*roughness_factor;
 ROUGHNESS=clamp(max(authored,.58)+mud*.22+dust*.15,.0,.98);
 METALLIC=0.;SPECULAR=.35;
 if(has_normal){NORMAL_MAP=texture(normal_texture,UV).rgb;NORMAL_MAP_DEPTH=.9;}
}
