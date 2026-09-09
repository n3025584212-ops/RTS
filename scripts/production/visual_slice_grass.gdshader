shader_type spatial;
render_mode cull_disabled, diffuse_burley, alpha_to_coverage;
uniform sampler2D color_texture : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D alpha_texture : filter_linear_mipmap_anisotropic;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap_anisotropic;
varying vec3 world_position;
void vertex() { world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    float variation = sin(world_position.x * .51 + sin(world_position.z * .74)) * .5 + .5;
    ALBEDO = texture(color_texture, UV).rgb * mix(vec3(.52, .55, .32), vec3(.78, .73, .44), variation);
    ALPHA = texture(alpha_texture, UV).r;
    ALPHA_SCISSOR_THRESHOLD = .35;
    ALPHA_ANTIALIASING_EDGE = .3;
    ALPHA_TEXTURE_COORDINATE = UV * vec2(textureSize(alpha_texture, 0));
    NORMAL_MAP = texture(normal_texture, UV).rgb;
    NORMAL_MAP_DEPTH = .6;
    ROUGHNESS = .92;
    SPECULAR = .2;
    BACKLIGHT = ALBEDO * .12;
}
