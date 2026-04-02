shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 10.0) = 0.0;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 pixel_size = blur_amount / vec2(textureSize(TEXTURE, 0));
    
    vec4 color = vec4(0.0);
    int samples = 0;
    
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * pixel_size;
            color += texture(TEXTURE, UV + offset);
            samples++;
        }
    }
    
    COLOR = (color / float(samples)) * tint;
}