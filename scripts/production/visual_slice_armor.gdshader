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
uniform float surface_role=0.0; // 0 painted armor, 1 dark mechanical/track, 2 exposed metal
uniform float authored_metallic=0.0;
uniform float authored_specular=0.5;
uniform sampler2D metal_texture : hint_default_white,filter_linear_mipmap_anisotropic;
uniform sampler2D ao_texture : hint_default_white,filter_linear_mipmap_anisotropic;
uniform bool has_metal_texture=false;
uniform bool has_ao=false;
uniform vec4 metal_channel=vec4(0.,0.,1.,0.);
uniform vec4 ao_channel=vec4(1.,0.,0.,0.);
uniform mat4 vehicle_inverse;

varying vec3 wp;
varying vec3 wn;
varying vec3 local_position;

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
 local_position=(vehicle_inverse*vec4(wp,1.)).xyz;
}

void fragment(){
 vec3 authored=texture(paint_texture,UV).rgb*paint_color.rgb;
 float authored_luma=dot(authored,vec3(.2126,.7152,.0722));
 float macro=n(wp*.34)*.58+n(wp*1.7)*.29+n(wp*10.5)*.13;
 float micro=n(wp*34.0);
 float height=max(0.0,wp.y-ground_y);
 float up=max(wn.y,0.0);

 // Preserve authored surface identity instead of forcing every Abrams surface
 // through the same olive paint response.
 vec3 painted=authored*mix(.76,.96,macro);
 vec3 mechanical=authored*mix(.60,.92,macro);
 vec3 exposed=authored*mix(.88,1.10,macro);

 vec3 base=painted;
 if(surface_role>1.5){base=exposed;}
 else if(surface_role>.5){base=mechanical;}

 // Dust accumulates on upward surfaces; wet mud remains concentrated low on the
 // running gear and lower hull instead of washing over the complete vehicle.
 float dust=smoothstep(.46,.73,n(local_position*2.15+vec3(2.1,0.0,1.7)))*mix(.025,.13,up);
 float mud_noise=n(wp*3.5)*.68+n(wp*17.0)*.32;
 float lower=1.-smoothstep(.22,1.42+mud_noise*.38,height);
 float mud=lower*mix(.38,.82,smoothstep(.28,.72,mud_noise));
 if(surface_role>1.5){mud*=.64;}

 // Fine directional grime and localized edge-like abrasion keep broad armor
 // panels from reading as one flat material.
 float streak=smoothstep(.62,.79,n(wp*vec3(18.,1.15,18.)+vec3(3.0,0.0,7.0)))*.13*(1.-up);
 float authored_rough=dot(texture(rough_texture,UV),rough_channel)*roughness_factor;
 float authored_metal=authored_metallic;
 if(has_metal_texture){authored_metal*=dot(texture(metal_texture,UV),metal_channel);}
 float wear=smoothstep(.62,.90,authored_metal)*(1.-smoothstep(.34,.72,authored_rough))*(1.-mud);

 base=mix(base,vec3(.235,.202,.128),dust);
 base*=1.-streak;
 base=mix(base,vec3(.18,.19,.17),wear*.20*(1.-step(.5,surface_role)));
 base=mix(base,mix(vec3(.035,.027,.016),vec3(.125,.088,.046),mud_noise),mud);

 ALBEDO=base;

 float base_rough=clamp(authored_rough,.46,.88);
 if(surface_role>.5 && surface_role<1.5){base_rough=max(base_rough,.84);}
 if(surface_role>1.5){base_rough=clamp(authored_rough,.29,.78);}
 float wet_mud=mud*(1.-smoothstep(.1,.62,height));
 ROUGHNESS=clamp(base_rough+dust*.12+mud*.12-wear*.12-wet_mud*.34,.18,.96);

 float metal=authored_metal;
 if(surface_role<.5){metal*=.28;}
 if(surface_role>.5 && surface_role<1.5){metal=0.;}
 if(surface_role>1.5){metal=max(metal,.5);}
 METALLIC=metal*(1.-mud*.82);
 SPECULAR=clamp(authored_specular+wear*.16,.25,.88);
 if(surface_role>2.5){
  ALBEDO=mix(authored,vec3(.024,.063,.072),.38);
  METALLIC=.22; ROUGHNESS=.16; SPECULAR=.72;
  CLEARCOAT=.62; CLEARCOAT_ROUGHNESS=.10;
 }
 if(has_ao){AO=dot(texture(ao_texture,UV),ao_channel);}

 if(has_normal){
  NORMAL_MAP=texture(normal_texture,UV).rgb;
  NORMAL_MAP_DEPTH=.95;
 }
}
