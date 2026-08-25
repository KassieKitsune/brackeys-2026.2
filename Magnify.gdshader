shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float magFactor = 2.0;
varying vec2 center;

void vertex(){
	center = (CANVAS_MATRIX * MODEL_MATRIX[3]).xy;
}

void fragment( )
{
	vec2 centerUV = center * SCREEN_PIXEL_SIZE;
	COLOR = texture(SCREEN_TEXTURE, (SCREEN_UV - centerUV) / magFactor + centerUV); //Grab a pixel from the screen at an offset by the shiftvec.
}