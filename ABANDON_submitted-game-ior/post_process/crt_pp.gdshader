// CRT shader by Harrison Allen
// You are free to use this shader as you wish, including in commercial products
// Have fun!

shader_type canvas_item;

/**
	The texture that will have the CRT effect applied to it.
	The scanline count will equal this texture's vertical dimension, and
	Scanlines need multiple rows of on-screen pixels to be resolved without
	Moiré patterns. As such, I'd recommend a vertical resolution for this
	texture of 240 for 1080p monitors and 480 if you're using a 4K monitor.
	(Or just your screen's height divided by 2.25)
	*/
uniform sampler2D tex: filter_linear;

/**
	This texture should look like this for a desktop CRT shadowmask:
	🟥🟩🟦⬛
	⬛🟥🟩🟦
	Used with a mask_brightness of 0.25
	
	Alternatively, using a 2x1 texture that consists of one magenta (1,0,1) and
	one red pixel results in a patern perfect for an aperture grille (requires a
	mask_brightness of 0.5
	
	There's also another fun pattern that works great as a TV slotmask:
	(1,0,1) (0,1,0) (1,0,1) (0,1,0)
	(0,0,1) (0,1,0) (1,0,0) (0,0,0)
	(1,0,1) (0,1,0) (1,0,1) (0,1,0)
	(1,0,0) (0,0,0) (0,0,1) (0,1,0)
	Use a mask_brightness of 1.0/3.0
	You will need to use an input texture with about half the height, though.
	*/
uniform sampler2D mask_tex: filter_nearest, repeat_enable, hint_default_white;

/**
	This should be set as the apperent brightness of the mask texture.
	*/
uniform float mask_brightness : hint_range(0.25, 0.5) = 0.25;

uniform float curve : hint_range(0, 1) = 0.5;

/**
	If true, the image will be blurred horizontally. Fun with dithering.
	*/
uniform bool soft = true;

/**
	Use to offset color channels from each other.
	*/
uniform float color_offset : hint_range(-0.5, 0.5) = 0.0;

/**
	With a value of 1, the CRT effect should keep the image at close to the same
	brightness of the original image. At zero, the image will be way dimmer, but
	the CRT pattern will be maintained in highlights. 
	Using a value just under 1 works pretty well if you want the pattern to
	always be at least slightly visible.
	*/
uniform float brightness : hint_range(0, 1) = 1.0;

/**
	This should be the input texture's height divided by width
	*/
uniform float aspect : hint_range(0.5, 1.0) = 0.75;

vec2 square_warp(vec2 uv, float _aspect, float _curve)
{
	// Centralizes coordinates (0 is in the middle)
	uv -= 0.5;

	uv.x /= _aspect;

	// Squared distance from the middle
	float warp = dot(uv, uv) * _curve;

	// Compensate for shrinking
	warp -= _curve * 0.25;

	// Warp the coordinates
	uv /= 1.0 - warp;

	uv.x *= _aspect;

	// Decentralize the coordinates
	uv += 0.5;

	return uv;
}

vec3 linear_to_srgb(vec3 col)
{
	bvec3 cutoff = lessThan(col, vec3(0.0031308));
	vec3 higher = vec3(1.055) * pow(col, vec3(1.0 / 2.4)) - vec3(0.055);
	vec3 lower = col * 12.92;

	return mix(higher, lower, cutoff);
}

vec3 srgb_to_linear(vec3 col)
{
	bvec3 cutoff = lessThan(col, vec3(0.04045));
	vec3 higher = pow((col + vec3(0.055)) / 1.055, vec3(2.4));
	vec3 lower = col / 12.92;

	return mix(higher, lower, cutoff);
}

// Get scanlines from coordinates (returns in linear color)
vec3 scanlines(vec2 uv)
{
	uv *= vec2(textureSize(tex, 0));

	// The two vertical coordinates for the scanline samples
	int y = int(floor(uv.y + 0.5));
	int top_y = y - 1;

	float x = floor(uv.x + 0.5);

	// Horizontal coordinates for the texture samples
	float ax = x + 2.0;
	float bx = x + 1.0;
	float cx = x;
	float dx = x - 1.0;
	float ex = x - 2.0;
	float fx = x - 3.0;

	// Pixel positions
	float green = uv.x - 0.5;
	float blue = green + color_offset;
	float red = green - color_offset;

	vec3 upper_col = vec3(0);
	vec3 lower_col = vec3(0);

	if (soft)
	{
		// Sample the texture at various points
		vec2 upper_a = texelFetch(tex, ivec2(int(ax), top_y), 0).rb;
		vec3 upper_b = texelFetch(tex, ivec2(int(bx), top_y), 0).rgb;
		vec3 upper_c = texelFetch(tex, ivec2(int(cx), top_y), 0).rgb;
		vec3 upper_d = texelFetch(tex, ivec2(int(dx), top_y), 0).rgb;
		vec3 upper_e = texelFetch(tex, ivec2(int(ex), top_y), 0).rgb;
		vec2 upper_f = texelFetch(tex, ivec2(int(fx), top_y), 0).rb;

		vec2 lower_a = texelFetch(tex, ivec2(int(ax), y), 0).rb;
		vec3 lower_b = texelFetch(tex, ivec2(int(bx), y), 0).rgb;
		vec3 lower_c = texelFetch(tex, ivec2(int(cx), y), 0).rgb;
		vec3 lower_d = texelFetch(tex, ivec2(int(dx), y), 0).rgb;
		vec3 lower_e = texelFetch(tex, ivec2(int(ex), y), 0).rgb;
		vec2 lower_f = texelFetch(tex, ivec2(int(fx), y), 0).rb;

		// These will be used to weight the strength of each sample
		vec2 a_weight;
		vec3 b_weight;
		vec3 c_weight;
		vec3 d_weight;
		vec3 e_weight;
		vec2 f_weight;

		// Calculate green weight for each sample
		b_weight.g = smoothstep(1, 0, (bx - green) * 0.5);
		c_weight.g = smoothstep(1, 0, (cx - green) * 0.5);
		d_weight.g = smoothstep(1, 0, (green - dx) * 0.5);
		e_weight.g = smoothstep(1, 0, (green - ex) * 0.5);

		// Calculate blue weight for each sample
		a_weight.y = smoothstep(1, 0, (ax - blue) * 0.5);
		b_weight.b = smoothstep(1, 0, (bx - blue) * 0.5);
		c_weight.b = smoothstep(1, 0, abs(blue - cx) * 0.5);
		d_weight.b = smoothstep(1, 0, abs(blue - dx) * 0.5);
		e_weight.b = smoothstep(1, 0, (blue - ex) * 0.5);
		f_weight.y = smoothstep(1, 0, (blue - fx) * 0.5);

		// Calculate red weight for each sample
		a_weight.x = smoothstep(1, 0, (ax - red) * 0.5);
		b_weight.r = smoothstep(1, 0, (bx - red) * 0.5);
		c_weight.r = smoothstep(1, 0, abs(cx - red) * 0.5);
		d_weight.r = smoothstep(1, 0, abs(dx - red) * 0.5);
		e_weight.r = smoothstep(1, 0, (red - ex) * 0.5);
		f_weight.x = smoothstep(1, 0, (red - fx) * 0.5);

		// Mix the colors
		upper_col.rb += upper_a * a_weight;
		upper_col += upper_b * b_weight;
		upper_col += upper_c * c_weight;
		upper_col += upper_d * d_weight;
		upper_col += upper_e * e_weight;
		upper_col.rb += upper_f * f_weight;

		// Mix the colors
		lower_col.rb += lower_a * a_weight;
		lower_col += lower_b * b_weight;
		lower_col += lower_c * c_weight;
		lower_col += lower_d * d_weight;
		lower_col += lower_e * e_weight;
		lower_col.rb += lower_f * f_weight;

		// Correct brightness
		upper_col *= 0.5;
		lower_col *= 0.5;
	}
	else // Sharp
	{
		// Sample the texture at various points
		vec2 upper_b = texelFetch(tex, ivec2(int(bx), top_y), 0).rb;
		vec3 upper_c = texelFetch(tex, ivec2(int(cx), top_y), 0).rgb;
		vec3 upper_d = texelFetch(tex, ivec2(int(dx), top_y), 0).rgb;
		vec2 upper_e = texelFetch(tex, ivec2(int(ex), top_y), 0).rb;

		vec2 lower_b = texelFetch(tex, ivec2(int(bx), y), 0).rb;
		vec3 lower_c = texelFetch(tex, ivec2(int(cx), y), 0).rgb;
		vec3 lower_d = texelFetch(tex, ivec2(int(dx), y), 0).rgb;
		vec2 lower_e = texelFetch(tex, ivec2(int(ex), y), 0).rb;

		vec2 b_weight;
		vec3 c_weight;
		vec3 d_weight;
		vec2 e_weight;

		// Calculate blend weights
		c_weight.g = smoothstep(1, 0, cx - green);
		d_weight.g = smoothstep(1, 0, green - dx);

		b_weight.y = smoothstep(1, 0, bx - blue);
		c_weight.b = smoothstep(1, 0, abs(blue - cx));
		d_weight.b = smoothstep(1, 0, abs(blue - dx));
		e_weight.y = smoothstep(1, 0, blue - ex);

		b_weight.x = smoothstep(1, 0, bx - red);
		c_weight.r = smoothstep(1, 0, abs(cx - red));
		d_weight.r = smoothstep(1, 0, abs(dx - red));
		e_weight.x = smoothstep(1, 0, red - ex);

		// Blend the upper samples together
		upper_col.rb += upper_b * b_weight;
		upper_col += upper_c * c_weight;
		upper_col += upper_d * d_weight;
		upper_col.rb += upper_e * e_weight;

		// Blend the lower samples together
		lower_col.rb += lower_b * b_weight;
		lower_col += lower_c * c_weight;
		lower_col += lower_d * d_weight;
		lower_col.rb += lower_e * e_weight;
	}

	// Convert to linear color space
	upper_col = srgb_to_linear(upper_col);
	lower_col = srgb_to_linear(lower_col);

	// Scanline size (and roughly the apperent brightness of this line)
	vec3 upper_thickness = mix(vec3(0.5), vec3(1.0), upper_col);
	vec3 lower_thickness = mix(vec3(0.5), vec3(1.0), lower_col);

	float sawtooth = fract(uv.y + 0.5);

	vec3 upper_line = vec3(sawtooth) / upper_thickness;
	upper_line = smoothstep(1.0, 0.0, upper_line);

	vec3 lower_line = vec3(1.0 - sawtooth) / lower_thickness;
	lower_line = smoothstep(1.0, 0.0, lower_line);

	// Correct line brightness below 0.5
	upper_line *= upper_col / upper_thickness;
	lower_line *= lower_col / lower_thickness;

	// Combine the upper and lower scanlines
	vec3 combined = upper_line + lower_line;

	// Calculate dim version
	vec3 dark_upper_line = smoothstep(1.0, 0.0, vec3(sawtooth) * 2.0);
	dark_upper_line *= upper_col;

	vec3 dark_lower_line = smoothstep(1.0, 0.0, vec3(1.0 - sawtooth) * 2.0);
	dark_lower_line *= lower_col;

	vec3 dark_combined = dark_upper_line + dark_lower_line;

	// Mix bright and dim
	return mix(dark_combined, combined, brightness);
}

// Add phosphor mask/grill
vec3 mask(vec3 linear_color, vec2 fragcoord)
{
	// This is how bright the mask would need to be to maintain 100% brightness
	vec3 target_color = linear_color / mask_brightness;

	// Clamp values over 1
	vec3 primary_color = clamp(target_color, 0.0, 1.0);

	// This calculates how bright the secondary subpixels will need to be
	vec3 highlights = target_color - primary_color;
	highlights /= 1.0 / mask_brightness - 1.0;

	// sample the CRT mask pattern
	vec2 mask_coords = fragcoord / vec2(textureSize(mask_tex, 0));
	vec3 mask = textureLod(mask_tex, mask_coords, 0.0).rgb;

	primary_color *= mask;

	// Add the secondary subpixels
	primary_color += highlights * (1.0 - mask);

	primary_color = mix(linear_color * mask, primary_color, brightness);

	return primary_color;
}

void fragment()
{
	// Warp UV coordinates
	vec2 warped_coords = square_warp(UV, aspect, curve * 0.5);

	// Sample the scanlines
	vec3 col = scanlines(warped_coords);

	// Apply phosphor mask
	col = mask(col, FRAGCOORD.xy);

	// convert to linear color space
	col = linear_to_srgb(col);

	COLOR.rgb = col;
}