shader_type fog;
uniform sampler3D volume_noise : repeat_enable, filter_linear;
uniform float opacity = .11;
void fog(){
 vec3 p=UVW;
 vec3 drift=vec3((p.y-.2)*.20,0.,sin(p.y*6.)*.055);
 float radius=mix(.10,.48,smoothstep(0.,.75,p.y));
 float edge=1.-smoothstep(radius*.4,radius,length(p.xz-vec2(.5)-drift.xz));
 float n=texture(volume_noise,UVW*vec3(1.8,3.8,1.8)).r;
 float detail=texture(volume_noise,UVW*8.+vec3(.2,.7,.1)).r;
 float plume=smoothstep(.24,.67,n*.8+detail*.2);
 DENSITY=opacity*edge*plume*smoothstep(0.,.08,p.y)*(1.-smoothstep(.65,1.,p.y));
 ALBEDO=vec3(.16,.17,.17);
}
