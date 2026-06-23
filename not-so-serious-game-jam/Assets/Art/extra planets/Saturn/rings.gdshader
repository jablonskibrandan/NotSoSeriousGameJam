shader_type spatial;
render_mode blend_mix, depth_draw_never, depth_test_default, cull_disabled, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D ring_texture;
uniform sampler2D alpha_texture;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 col = texture(ring_texture, UV).rgb;
	vec4 al = texture(alpha_texture, UV);
	
	float alpha = al.r;
	
	ALBEDO = col;
	ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
