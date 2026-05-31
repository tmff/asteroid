shader_type spatial;
render_mode blend_mix, depth_draw_never, depth_test_disabled, unshaded;

uniform vec4  ore_color    : source_color = vec4(1.00, 0.82, 0.10, 1.0);
uniform vec4  damage_color : source_color = vec4(1.00, 0.15, 0.10, 1.0);
uniform float highlight_mix : hint_range(0.0, 1.0) = 0.65;
uniform float pulse_speed                           = 2.5;
uniform bool  scan_active = false;

void fragment() {
	if (!scan_active) {
		discard;
	}

	bool is_ore     = COLOR.r > 0.5;
	bool is_damaged = COLOR.g > 0.5;

	if (!is_ore && !is_damaged) {
		discard;
	}

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

	if (is_ore && is_damaged) {
		ALBEDO = mix(ore_color.rgb, damage_color.rgb, pulse);
	} else if (is_ore) {
		ALBEDO = ore_color.rgb;
	} else {
		ALBEDO = damage_color.rgb;
	}

	ALPHA = highlight_mix * (0.6 + 0.4 * pulse);
}