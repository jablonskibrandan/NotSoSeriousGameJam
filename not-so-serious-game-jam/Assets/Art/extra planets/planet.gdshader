shader_type spatial;
uniform sampler2D planet_texture;
uniform vec3 glow : source_color = vec3(0.0, 0.0, 0.0);
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	
	vec3 tex = texture(planet_texture, UV).rgb;
	ALBEDO = tex;
	// Called for every pixel the material is visible on.
	EMISSION = glow;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
