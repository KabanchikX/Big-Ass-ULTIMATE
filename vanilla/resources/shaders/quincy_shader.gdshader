shader_type canvas_item;

// Настройки жесткой обводки
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 1.0;

// Настройки шума квинси
uniform sampler2D noise_texture : repeat_enable;
uniform vec4 noise_color : source_color = vec4(0.0, 0.6, 1.0, 1.0);     // Яркие волокна
uniform vec4 base_dark_color : source_color = vec4(0.0, 0.05, 0.2, 1.0); // Темная подложка
uniform vec2 scroll_direction = vec2(0.5, -0.5); 
uniform float scroll_speed = 0.5;

void fragment() {
	// 1. Создаем жесткую, рваную пульсацию от времени
	// TIME * 30.0 — чтобы ебашило на огромной скорости
	float glitch_pulse = (sin(TIME * 30.0) * cos(TIME * 17.0)) * 0.5 + 0.5;
	
	// 2. Берем оригинальный спрайт
	vec4 sprite_color = texture(TEXTURE, UV);
	
	// 3. Скроллинг шума + подмешиваем микро-дергание (глитч) от пульсации
	vec2 glitch_uv_offset = scroll_direction * glitch_pulse * 0.02; // Микро-сдвиг для хаоса
	vec2 scrolled_uv = UV + (scroll_direction * scroll_speed * TIME) + glitch_uv_offset;
	
	vec4 noise_pixel = texture(noise_texture, scrolled_uv);
	
	// Смешиваем цвета, делаем шум контрастнее в моменты вспышек
	vec4 dynamic_noise_color = mix(noise_color, noise_color * 1.5, glitch_pulse);
	vec4 final_noise_color = mix(base_dark_color, dynamic_noise_color, noise_pixel.r); 
	
	// 4. Считаем размер пикселя и динамическую толщину обводки
	// Сама обводка теперь тоже будет мелко дрожать в такт энергии
	float dynamic_width = outline_width * mix(0.7, 1.3, glitch_pulse);
	vec2 pixel_size = 1.0 / vec2(textureSize(TEXTURE, 0));
	
	float max_alpha = 0.0;
	max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, -pixel_size.y) * dynamic_width).a); // Вверх
	max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(0.0, pixel_size.y) * dynamic_width).a);  // Вниз
	max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(-pixel_size.x, 0.0) * dynamic_width).a); // Влево
	max_alpha = max(max_alpha, texture(TEXTURE, UV + vec2(pixel_size.x, 0.0) * dynamic_width).a);  // Вправо
	
	float outline_mask = max_alpha - sprite_color.a;
	
	// 5. Финальная сборка пикселя (ШУМ + ОБВОДКА поверх)
	vec4 final_color = mix(final_noise_color, outline_color, outline_mask);
	
	// Обрезаем строго по краям обводки
	final_color.a *= max_alpha; 
	
	COLOR = final_color;
}
