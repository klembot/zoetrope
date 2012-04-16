extern number value;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	vec4 pixel = color * Texel(texture, texture_coords);

	//if (mod(pixel_coords[1], 2) == 0)
	{
		pixel.r = 1.0 - pixel.r;
		pixel.g = 1.0 - pixel.g;
		pixel.b = 1.0 - pixel.b;
	}

	return pixel;
}

