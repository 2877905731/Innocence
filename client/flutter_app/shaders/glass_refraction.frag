#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 uSceneSize;
uniform vec2 uOrigin;
uniform float uRadius;
uniform float uStrength;
uniform sampler2D uScene;
out vec4 fragColor;

vec3 lightAt(vec2 point) {
  vec2 uv = clamp(point / uSceneSize, vec2(0.0), vec2(1.0));
  // Picture.toImageSync is a render-target texture. Older Impeller GLES
  // stores it bottom-up; Canvas drawing compensates, raw texture() does not.
  // Flutter 3.47+ stores it top-down and defines this migration macro.
#if defined(IMPELLER_TARGET_OPENGLES) && !defined(IMPELLER_OPENGLES_UNFLIPPED_DEPRECATED)
  uv.y = 1.0 - uv.y;
#endif
  return texture(uScene, uv).rgb;
}

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec2 halfSize = uSize * 0.5;
  vec2 centered = p - halfSize;
  float radius = min(uRadius, min(halfSize.x, halfSize.y));
  vec2 q = abs(centered) - halfSize + radius;
  vec2 outside = max(q, vec2(0.0));
  float distance = length(outside) + min(max(q.x, q.y), 0.0) - radius;
  vec2 normal = length(outside) > 0.001
      ? normalize(outside) * sign(centered)
      : (q.x > q.y ? vec2(sign(centered.x), 0.0) : vec2(0.0, sign(centered.y)));

  // A domed center magnifies and shears the actual shared light field. The
  // curved rim bends it in the opposite direction, rather than blurring it.
  vec2 uv = centered / max(halfSize, vec2(1.0));
  float dome = max(0.0, 1.0 - dot(uv, uv) * 0.5);
  float rim = exp(-max(-distance, 0.0) / 11.0);
  vec2 bend = centered * (-0.16 * dome)
      + vec2(18.0, -12.0) * dome
      + normal * (23.0 * rim);
  vec2 source = uOrigin + p + bend * uStrength;
  vec2 dispersion = (normal * (2.8 * rim) + vec2(1.3, -0.9) * dome) * uStrength;
  vec3 color = vec3(lightAt(source + dispersion).r,
                    lightAt(source).g,
                    lightAt(source - dispersion).b);
  // Small multi-tap frost retains the beam's shape and bend.
  vec3 frost = (lightAt(source + vec2(4.0, 0.0))
             + lightAt(source - vec2(4.0, 0.0))
             + lightAt(source + vec2(0.0, 4.0))
             + lightAt(source - vec2(0.0, 4.0))) * 0.25;
  color = mix(color, frost, 0.16 * uStrength);
  float energy = max(color.r, max(color.g, color.b));
  color *= 1.0 + (0.20 * dome + 0.30 * rim) * uStrength;
  // Caustic brightness is driven by incident light: no painted rainbow or
  // moving white highlight when the background is dark.
  color += vec3(0.11, 0.095, 0.13) * rim * energy * uStrength;
  color = mix(color, vec3(0.60, 0.62, 0.68), 0.024 * uStrength);
  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
