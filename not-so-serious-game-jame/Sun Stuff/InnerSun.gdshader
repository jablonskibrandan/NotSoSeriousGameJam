shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, depth_test_default, cull_back, diffuse_lambert, specular_schlick_ggx;


uniform sampler2D frensel_gradient_tex;
uniform float emission_strength = 1.0;

instance uniform float variation = 0.0;

void fragment(){
	//fresnel effect
	float facing = pow((1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0 )), 1);
	
	vec3 ramp_color = texture(frensel_gradient_tex, vec2(facing,0.5)).rgb;
	
	ALBEDO = ramp_color *emission_strength;

	float rot_rand = variation * 360.0;
	
	float scale_rand = variation * 1.22;
	

}
