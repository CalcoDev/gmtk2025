shader_type canvas_item;

uniform float u_speed : hint_range(0.0, 10.0) = 0.666;

vec3 rgb2hsv(vec3 c)
{
    vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
    return c.z * mix(k.xxx, clamp(p - k.xxx, 0.0, 1.0), c.y);
}

float saturate(float x)
{
    return clamp(x, 0.0, 1.0);
}

vec2 hash21(float p)
{
    vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.xx + p3.yz) * p3.zy) * 2.0 - 1.0;
}

vec2 rotateUV(vec2 uv, float rotation)
{
    return vec2(
        cos(rotation) * uv.x + sin(rotation) * uv.y,
        cos(rotation) * uv.y - sin(rotation) * uv.x
    );
}

vec3 drawflare(vec2 p, float intensity, float rnd, float speed, int id)
{
    float flarehueoffset = (1.0 / 32.0) * float(id) * 0.1;
    float lingrad = distance(vec2(0.0), p);
    float expgrad = 1.0 / exp(lingrad * (fract(rnd) * 0.66 + 0.33));
    vec3 colgrad = hsv2rgb(vec3(fract((expgrad * 8.0) + speed + flarehueoffset), pow(1.0 - abs(expgrad * 2.0 - 1.0), 0.45), 20.0 * expgrad * intensity));
    float blades = length(p * sin(3.0 * atan(p.x, p.y)));
    float comp = pow(1.0 - saturate(blades), 12.0);
    comp += saturate(expgrad - 0.9) * 3.0;
    comp = pow(comp * expgrad, 8.0 + (1.0 - intensity) * 5.0);
    return vec3(comp) * colgrad;
}

float dist(vec3 a, vec3 b)
{
    return abs(a.x - b.x) + abs(a.y - b.y) + abs(a.z - b.z);
}

vec3 saturate(vec3 x)
{
    return clamp(x, vec3(0.0), vec3(1.0));
}

void fragment()
{
    float t = TIME * u_speed;
    vec2 uv = UV;
    vec2 p = uv * 2.0 - 1.0;
    p.x *= TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x; // Aspect ratio correction
    vec3 color = vec3(0.0);

    for (int i = 0; i < 32; ++i)
    {
        float intensity = smoothstep(0.99, 1.0, saturate(sin(t + float(i))));
        intensity += smoothstep(0.994, 1.0, saturate(sin(t + float(i) + 0.3))) * 0.1;

        if (intensity > 0.0)
        {
            vec2 randomoffset = hash21(float(i) * 3.21);
            vec2 prot = rotateUV(p + randomoffset * vec2(TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x, 1.0), (t * 0.5));
            float rnd = float(i) * 1.337;
            color += drawflare(prot, intensity, rnd, t, i);
        }
    }

    COLOR = vec4(color, 1.0);
}