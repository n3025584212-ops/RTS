shader_type sky;
// DirectionalLight3D supplies direct sunlight. Bound the panorama's solar disk
// in all passes, including camera views rendered by ReflectionProbe.
uniform sampler2D panorama : filter_linear_mipmap, repeat_enable;
uniform float background_energy = .8;
uniform float illumination_limit = 2.0;
void sky() {
    vec3 radiance = textureLod(panorama, SKY_COORDS, 0.0).rgb * background_energy;
    float peak = max(radiance.r, max(radiance.g, radiance.b));
    radiance *= min(1.0, illumination_limit / max(peak, .0001));
    COLOR = radiance;
}
