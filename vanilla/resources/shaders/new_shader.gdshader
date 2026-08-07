shader_type canvas_item;

// Сюда кидаем FastNoiseLite (в настройках шума обязательно Seamless = true)
uniform sampler2D noise_texture : repeat_enable, filter_nearest;

uniform float speed = 2.0;

// Сила искажения (начни с 0.01 и плавно настраивай)
uniform float strength = 0.02;

// Считываем снимок экрана, сделанный нодой BackBufferCopy
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

void fragment() {
    // Двигаем шум вверх по локальным координатам (чтобы масштабировался с зумом)
    vec2 noise_uv = UV;
    noise_uv.y -= TIME * speed;
    
    // Берем значение шума
    float noise = texture(noise_texture, noise_uv).r;
    
    // Вычисляем локальный сдвиг
    vec2 distortion = vec2(noise - 0.5) * strength;
    
    // Мягко тушим эффект к краям плашки, чтобы не было видно квадратных границ
    float edge_fade = sin(UV.x * PI) * sin(UV.y * PI);
    
    // Сдвигаем экран за счет локально просчитанного искажения
    COLOR = texture(screen_texture, SCREEN_UV + (distortion * edge_fade));
}