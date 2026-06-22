shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, depth_test_default, cull_front, diffuse_lambert, specular_schlick_ggx;


uniform sampler2D frensel_gradient_tex;
uniform float emission_strength = 2.0;

instance uniform float variation = 0.0;
instance uniform float scale_variation = 0.0;

void fragment(){
	//fresnel effect
	float facing = pow((1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0 )), 1);
	
	vec3 ramp_color = texture(frensel_gradient_tex, vec2(facing,0.5)).rgb;
	
	ALBEDO = ramp_color *emission_strength;


	
	//wave mask
	vec2 uv = UV - vec2(0.5);
	float d = length(uv);
	
	float wave = 0.5 +0.5 * sin(d*30.0 + (TIME*variation));
	
	//mask
	ALPHA = step(0.9+(scale_variation*0.01), wave);
	

}
