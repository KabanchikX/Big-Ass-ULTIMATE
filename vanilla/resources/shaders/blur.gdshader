shader_type canvas_item;
// Включаем правильный режим смешивания для HDR в 2D
render_mode blend_premul_alpha;

// ВОТ СЮДА теперь можно спокойно ставить HDR-значения (3.0, 5.0 и т.д.) в RAW режиме!
uniform vec4 glow_color : source_color = vec4(3.0, 2.0, 0.0, 1.0);
uniform float glow_radius : hint_range(0.0, 40.0) = 15.0;
uniform float glow_falloff : hint_range(0.1, 5.0) = 1.5;
uniform float glow_intensity : hint_range(0.0, 10.0) = 2.0;

varying vec4 custom_modulate;

void vertex() {
    custom_modulate = COLOR;
}

void fragment() {
    // Получаем чистый цвет спрайта с учетом modulate из инспектора
    vec4 src_color = texture(TEXTURE, UV) * custom_modulate;
    
    if (glow_radius == 0.0) {
        // Для правильного blend_premul_alpha нужно умножить RGB на Alpha
        COLOR = vec4(src_color.rgb * src_color.a, src_color.a);
    } else {
        vec2 pixel_size = TEXTURE_PIXEL_SIZE;
        float max_distance = 0.0;
        
        int steps = 24; 
        for (int i = 0; i < steps; i++) {
            float angle = float(i) * (6.283185 / float(steps));
            vec2 direction = vec2(cos(angle), sin(angle));
            
            for (float d = 1.0; d <= glow_radius; d += 1.0) {
                float sample_alpha = texture(TEXTURE, UV + direction * pixel_size * d).a * custom_modulate.a;
                if (sample_alpha > 0.0) {
                    max_distance = max(max_distance, 1.0 - (d / glow_radius));
                    break;
                }
            }
        }
        
        // Считаем альфу свечения
        float smooth_glow = pow(max_distance, glow_falloff);
        float final_glow_alpha = clamp(smooth_glow - texture(TEXTURE, UV).a, 0.0, 1.0) * custom_modulate.a;
        
        // Формируем честный HDR-цвет свечения (не смешивая его с альфой в кашу)
        vec3 glow_rgb = glow_color.rgb * glow_intensity * final_glow_alpha;
        
        // Переводим цвет самого спрайта в pre-multiplied формат
        vec3 sprite_rgb = src_color.rgb * src_color.a;
        
        // Просто складываем их! Теперь видеокарта не обрежет HDR яркость на краях
        vec3 final_rgb = sprite_rgb + glow_rgb;
        float final_a = max(src_color.a, final_glow_alpha * glow_color.a);
        
        COLOR = vec4(final_rgb, final_a);
    }
}