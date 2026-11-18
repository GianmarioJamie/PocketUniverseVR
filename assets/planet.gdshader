shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(0.3,0.6,1.0,1.0);
uniform int kind = 0;
float pattern(vec3 p) {
 return sin(p.x*9.0 + sin(p.z*7.0))*sin(p.y*12.0 + p.z*4.0)+0.4*sin(p.x*22.0+p.z*19.0);
}
void fragment() {
 vec3 p = vec3(sin(UV.x*6.283)*sin(UV.y*3.1416), cos(UV.y*3.1416),cos(UV.x*6.283)*sin(UV.y*3.1416));
 float n = pattern(p);
 vec3 c = base_color.rgb;
 if (kind == 2) {
  c = mix(vec3(0.025,0.18,0.36),vec3(0.22,0.48,0.27),smoothstep(0.15,0.3,n));
  c = mix(c,vec3(0.85,0.94,0.97),smoothstep(0.86,0.98,abs(p.y)));
  float clouds = smoothstep(0.82,1.2,pattern(p*1.5+vec3(0.3)));
  c = mix(c,vec3(0.85,0.91,0.95),clouds*0.65);
 } else if (kind == 4 || kind == 5) {
  float bands = sin(p.y*65.0 + sin(p.x*7.0+p.z*9.0)*0.8);
  c *= 0.77+0.23*bands;
 } else {
  c *= 0.85 + 0.13*n;
 }
 ALBEDO = c;
 ROUGHNESS = 0.85;
 EMISSION = c * 0.08;
}
