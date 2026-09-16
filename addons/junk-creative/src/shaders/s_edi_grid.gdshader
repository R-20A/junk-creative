shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_disabled, shadows_disabled;

uniform vec4 GridColor: source_color = vec4(vec3(1.0), 0.5);
uniform float GridSize = 0.5;
uniform float LineThickness = 0.05;

varying vec3 v;

void vertex() {
	// Called for every vertex the material is visible on.
	
	v = VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	vec2 grid_uv = (GridSize/2.0) + v.xz * 1.0;
	
    // Calculate distance to the nearest grid line
    vec2 grid = abs(fract(grid_uv / GridSize - 0.5) - 0.5) / (LineThickness);
    float line = min(grid.x, grid.y);
    
    // Draw the grid line smoothly
    float alpha = 1.0 - min(line, 1.0);
	
    ALBEDO = GridColor.rgb;
    ALPHA = alpha * GridColor.a;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
