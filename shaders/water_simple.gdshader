shader_type spatial;

//basic
uniform vec3 color_depth: source_color = vec3(0.0, 0.05, 0.1);
uniform vec3 color_surface: source_color = vec3(0.0, 0.05, 0.1);
uniform float roughness: hint_range(0.0, 1.0) = 0.15;
uniform float fresnel_amount: hint_range(0.0, 10.0, 0.1) = 3.0;

//normals
uniform sampler2D normalmap_a: hint_normal;
uniform sampler2D normalmap_b: hint_normal;
uniform float normalmap_a_strength: hint_range(0.0, 1.0, 0.01) = 0.75;
uniform float normalmap_b_strength: hint_range(0.0, 1.0, 0.01) = 0.65;

//movement
uniform vec2 movement_direction = vec2(-0.2, -0.1);
uniform float movement_strength: hint_range(0.0, 1.0, 0.01) = 0.04;
uniform float uv_scale: hint_range(0.0, 10.0, .1) = 3.0;

//depth
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D depth_texture: hint_depth_texture, repeat_disable, filter_nearest;
uniform float depth_distance: hint_range(0.0, 20.0, 0.1) = 4.0;
uniform float beers_law: hint_range(0.0, 20.0, 0.1) = 8.0;
uniform float water_transparency: hint_range(0.0, 1.0, 0.01) = 0.05;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment() {
	//fresnel 
	float basic_fresnel = fresnel(fresnel_amount, NORMAL, VIEW);
	
	//mesh to obj depth testing in world space coords
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 screen = texture(screen_texture, SCREEN_UV).rgb;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float depth_texture_y = world.y / world.w;
	float vertex_y = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	
	//movement
	vec2 uv = UV * uv_scale;
	vec2 uv_movement = TIME * movement_direction * movement_strength;
	
	//normals
	vec3 normalmap = texture(normalmap_a, uv + uv_movement).rgb * normalmap_a_strength;
	normalmap += texture(normalmap_b, uv - uv_movement).rgb * normalmap_b_strength;
	
	//depth
	float depth_blend = clamp((vertex_y - depth_texture_y) / depth_distance, 0.0, 1.0);
	depth_blend = exp(-depth_blend * beers_law);
	
	//color
	vec3 depth_color = mix(color_surface, color_depth, depth_blend);
	vec3 final_color = mix(depth_color, screen, water_transparency);
	
	//assign textures
	ALBEDO = mix(final_color, screen, depth_blend * (1.0 - basic_fresnel));
	ROUGHNESS = roughness * (1.0 - basic_fresnel);
	NORMAL_MAP = normalmap;
}
