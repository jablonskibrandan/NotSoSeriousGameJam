shader_type spatial;
render_mode blend_mix, depth_draw_never, depth_test_default, cull_disabled, diffuse_lambert, specular_schlick_ggx;

uniform float IOR = 0.00227;
uniform float emission_strength = 4.0;
uniform vec3 atmosphere_color : source_color = vec3(0.5019607843, 0.8980392157, 1.0);

uniform float stretch_x = 0.5;
uniform float stretch_y = 0.5;
uniform float stretch_z = 0.5;

uniform float speed = 0.5;

uniform vec3 min_bounds = vec3(-1.0);
uniform vec3 max_bounds = vec3(1.0);

void fragment(){
	//fresnel effect
	float NdotV = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);

	float facing = IOR + (1.0 - IOR) * pow(1.0 - NdotV, 5.0);
	
	facing /= 0.5;
	
	EMISSION = atmosphere_color * emission_strength;
	
	//mask
	ALPHA = facing;
	}
	
void vertex() {
	
	vec3 pos = VERTEX;
	
	float tx = clamp((pos.x - min_bounds.x) / (max_bounds.x - min_bounds.x), 0.0, 1.0);
	float ty = clamp((pos.y - min_bounds.y) / (max_bounds.y - min_bounds.y), 0.0, 1.0);
	float tz = clamp((pos.z - min_bounds.z) / (max_bounds.z - min_bounds.z), 0.0, 1.0);
	
	tx = mix (-0.1, 0.1, tx);
	ty = mix (-0.1, 0.1, ty);
	tz = mix (-0.1, 0.1, tz);

	float t1 = sin(TIME*1.1*speed);
	float t2 = sin(TIME*1.0*speed);
	float t3 = sin(TIME*0.9*speed);

	pos.yz *= (1.0 + tx * stretch_x*t1);
	pos.xz *= (1.0 + ty * stretch_y*t2);
	pos.xy *= (1.0 + tz * stretch_z*t3);
	
	VERTEX = pos;
}
