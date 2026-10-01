shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.3, 0.6, 1.0, 1.0);
uniform float glow_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	vec3 glowing = tex.rgb + glow_color.rgb * glow_amount;  
	COLOR = vec4(glowing, tex.a);
}