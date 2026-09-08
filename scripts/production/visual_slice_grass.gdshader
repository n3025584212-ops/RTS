shader_type spatial;
render_mode cull_disabled, diffuse_burley;
varying vec3 w;
void vertex(){w=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
void fragment(){
 float n=sin(w.x*.71+sin(w.z*.31))*sin(w.z*.57);
 vec3 base=mix(vec3(.020,.038,.007),vec3(.080,.077,.023),n*.5+.5);
 ALBEDO=mix(base*.45,base*1.3,UV.y)*COLOR.rgb;
 ROUGHNESS=.94;BACKLIGHT=vec3(.02,.022,.006);NORMAL=normalize(NORMAL+vec3(0,.2,0));
}
