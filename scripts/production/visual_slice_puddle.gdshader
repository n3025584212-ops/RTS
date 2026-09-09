shader_type spatial;
render_mode blend_mix,depth_draw_never,diffuse_burley,specular_schlick_ggx;
uniform sampler2D scene_depth : hint_depth_texture,filter_nearest,repeat_disable;
varying vec3 wp;
void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 // Forward+ reversed-Z depth reconstructs the solid basin underneath the water.
 // Fading at the shoreline exposes actual mud geometry instead of a hard disc.
 float depth=texture(scene_depth,SCREEN_UV).r;
 vec4 ground_view=INV_PROJECTION_MATRIX*vec4(SCREEN_UV*2.-1.,depth,1.);
 ground_view.xyz/=ground_view.w;
 float thickness=max(0.,-ground_view.z+VERTEX.z);
 ALBEDO=vec3(.033,.031,.023);
 METALLIC=0.;
 SPECULAR=.26; // Water's dielectric F0 is approximately .02.
 ROUGHNESS=.075;
 NORMAL_MAP=vec3(.5+sin(wp.x*4.1+wp.z*2.3)*.002,.5+sin(wp.z*3.7)*.002,1.);
 ALPHA=smoothstep(.002,.075,thickness)*.91;
}
