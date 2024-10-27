shader_type canvas_item;

uniform vec4 lightning_color: source_color;

uniform float size: hint_range (0.,1.);
uniform float width: hint_range (0.,1.);
uniform float speed;
uniform float cycle;
uniform float ratio;
uniform float alpha;

float rand(float x){
	return fract(sin(x)*100000.0);
}

void fragment(){
	float bolt = abs(mod(UV.y * cycle + rand(TIME) * speed * -1., 0.5)-0.25)-0.125;
	bolt *= 4.0 * width;
	// why 4? 
	// Because we used mod 0.5, the value gets divided in half - and
	// then it gets subtracted by -0.25 for another halffor the abs function.
	
	// scale down at start and end
	bolt *=  (0.5 - abs(UV.y-0.5)) * 2.; 
	
	// turn to a line
	// center align line
	float wave = abs(UV.x - 0.5 + bolt);
	// invert and adjust size
	wave = 1. - step(size*.5, wave);
	
	float blink = step(rand(TIME)*ratio, .5);
	wave *= blink;
	
	vec4 display = lightning_color * vec4(wave);
	
	COLOR = display*alpha;
}
