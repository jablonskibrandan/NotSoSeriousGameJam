shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform float aberration_amount : hint_range(0.0, 0.1) = 0.0;
uniform float grain_amount : hint_range(0.0, 0.1) = 0.02;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;
uniform bool use_pulse = false;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	
	// Combined Blur and Aberration
	vec3 color = vec3(0.0);
	float weight_total = 0.0;
	
	for (float x = -2.0; x <= 2.0; x++) {
		for (float y = -2.0; y <= 2.0; y++) {
			vec2 offset = vec2(x, y) * blur_amount * SCREEN_PIXEL_SIZE;
			float r = texture(SCREEN_TEXTURE, uv + offset + vec2(aberration_amount, 0.0)).r;
			float g = texture(SCREEN_TEXTURE, uv + offset).g;
			float b = texture(SCREEN_TEXTURE, uv + offset - vec2(aberration_amount, 0.0)).b;
			
			color += vec3(r, g, b);
			weight_total += 1.0;
		}
	}
	color /= weight_total;
	
	// Vignette
	float d = distance(uv, vec2(0.5));
	float v = vignette_intensity;
	if (use_pulse) {
		v += sin(TIME * pulse_speed) * 0.05;
	}
	float vignette = smoothstep(0.8, 0.8 - v, d);
	color.rgb = mix(color.rgb, color.rgb * vignette, vignette_opacity);
	
	// Film Grain
	float noise = (fract(sin(dot(uv, vec2(12.9898, 78.233) * TIME)) * 43758.5453) - 0.5) * grain_amount;
	color.rgb += noise;
	
	COLOR = vec4(color, 1.0);
}
