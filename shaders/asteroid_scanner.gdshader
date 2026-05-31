shader_type spatial;
render_mode blend_mix, depth_draw_never, depth_test_disabled, unshaded;

uniform vec4 ore_color    : source_color = vec4(1.00, 0.82, 0.10, 1.0);
uniform vec4 damage_color : source_color = vec4(1.00, 0.15, 0.10, 1.0);

uniform float highlight_mix : hint_range(0.0, 1.0) = 0.65;
uniform float pulse_speed = 2.5;

uniform vec3 scan_origin = vec3(32.0, 32.0, 32.0);
uniform float scan_radius = -9999.0;
uniform float scan_band_width = 4.0;

varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	bool is_ore     = COLOR.r > 0.5;
	bool is_damaged = COLOR.g > 0.5;

	if (!is_ore && !is_damaged) {
		discard;
	}

	float dist = distance(local_pos, scan_origin);

	float scan_delta = abs(dist - scan_radius);

	if (scan_delta > scan_band_width) {
		discard;
	}

	float edge =
		1.0 -
		smoothstep(
			0.0,
			scan_band_width,
			scan_delta
		);

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

	vec3 colour;

	if (is_ore && is_damaged) {
		colour = mix(
			ore_color.rgb,
			damage_color.rgb,
			pulse
		);
	}
	else if (is_ore) {
		colour = ore_color.rgb;
	}
	else {
		colour = damage_color.rgb;
	}

	ALBEDO = colour + edge;

	ALPHA =
		highlight_mix *
		edge *
		(0.6 + 0.4 * pulse);
}