#include <flutter/runtime_effect.glsl>

uniform vec2  uResolution;
uniform float uTime;
uniform float uMode;

uniform float uEnableScanlines;
uniform float uEnablePhosphorGlow;
uniform float uEnableCurvature;
uniform float uEnableChromaticAberration;
uniform float uEnableFlicker;
uniform float uEnableBloom;
uniform float uEnableVhsJitter;
uniform float uEnablePixelGrid;
uniform float uEnableNoise;
uniform float uEnableDithering;

uniform float uScanlineOpacity;
uniform float uScanlineSpacing;
uniform float uGlowRadius;
uniform vec3  uGlowColor;
uniform float uCurvatureStrength;
uniform float uAberrationOffset;
uniform float uFlickerIntensity;
uniform float uBloomIntensity;
uniform float uBloomRadius;
uniform vec3  uBloomColor;
uniform float uJitterIntensity;
uniform float uPixelGridSize;
uniform float uPixelGridOpacity;
uniform float uNoiseOpacity;
uniform float uNoiseDensity;
uniform float uDitheringStrength;
uniform float uDitheringPatternSize;

uniform sampler2D uTexture;

out vec4 fragColor;

float hash21(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float hash31(vec3 p) {
  return fract(sin(dot(p, vec3(127.1, 311.7, 74.7))) * 43758.5453123);
}

bool on(float f) {
  return f > 0.5;
}

float bayer4x4(int x, int y) {
  int xx = int(mod(float(x), 4.0));
  int yy = int(mod(float(y), 4.0));

  int idx = yy * 4 + xx;

  if (idx == 0) return 0.0;
  if (idx == 1) return 8.0;
  if (idx == 2) return 2.0;
  if (idx == 3) return 10.0;
  if (idx == 4) return 12.0;
  if (idx == 5) return 4.0;
  if (idx == 6) return 14.0;
  if (idx == 7) return 6.0;
  if (idx == 8) return 3.0;
  if (idx == 9) return 11.0;
  if (idx == 10) return 1.0;
  if (idx == 11) return 9.0;
  if (idx == 12) return 15.0;
  if (idx == 13) return 7.0;
  if (idx == 14) return 13.0;

  return 5.0;
}

vec3 phosphorGlow(vec2 uv, float radius) {
  vec2 texel = 1.0 / uResolution;
  float r = radius * 0.5;

  vec3 acc = vec3(0.0);

  acc += texture(uTexture, uv).rgb * 0.36;
  acc += texture(uTexture, uv + vec2( r, 0.0) * texel).rgb * 0.12;
  acc += texture(uTexture, uv + vec2(-r, 0.0) * texel).rgb * 0.12;
  acc += texture(uTexture, uv + vec2(0.0,  r) * texel).rgb * 0.12;
  acc += texture(uTexture, uv + vec2(0.0, -r) * texel).rgb * 0.12;

  float lum = dot(acc, vec3(0.299, 0.587, 0.114));

  return acc + uGlowColor * lum * 0.6;
}

vec3 bloomPass(vec2 uv, float radius, float intensity) {
  vec2 texel = 1.0 / uResolution;

  vec3 acc = vec3(0.0);

  for (int dx = -2; dx <= 2; dx++) {
    for (int dy = -2; dy <= 2; dy++) {
      vec2 offset = vec2(float(dx), float(dy)) * radius * texel;

      vec3 s = texture(uTexture, uv + offset).rgb;

      float brightness = dot(s, vec3(0.2126, 0.7152, 0.0722));

      acc += s * max(brightness - 0.4, 0.0);
    }
  }

  return (acc / 25.0) * intensity * 2.5;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;

  vec2 uv = fragCoord / uResolution;

  vec2 centered = uv * 2.0 - 1.0;
  centered.x *= uResolution.x / uResolution.y;

  // VHS Jitter

  if (on(uEnableVhsJitter)) {
    float ph = floor(uTime * 20.0);

    float jx =
        (hash21(vec2(ph, 0.0)) * 2.0 - 1.0)
        * uJitterIntensity
        / uResolution.x;

    uv += vec2(jx, 0.0);
  }

  // Curvature

  vec2 curvedUv = uv;
  float vignette = 1.0;

  if (on(uEnableCurvature)) {
    float r2 = dot(centered, centered);

    curvedUv =
        (centered * (1.0 + uCurvatureStrength * 0.3 * r2))
        / vec2(uResolution.x / uResolution.y, 1.0)
        * 0.5
        + 0.5;

    vignette = 1.0 - uCurvatureStrength * 0.7 * r2;
  }

  vec2 sampleUv = on(uEnableCurvature) ? curvedUv : uv;

  vec3 uiColor;

  // Chromatic Aberration

  if (on(uEnableChromaticAberration)) {
    float ab = uAberrationOffset / uResolution.x;

    uiColor = vec3(
      texture(uTexture, sampleUv + vec2(ab, 0.0)).r,
      texture(uTexture, sampleUv).g,
      texture(uTexture, sampleUv - vec2(ab, 0.0)).b
    );
  } else {
    uiColor = texture(uTexture, sampleUv).rgb;
  }

  uiColor *= vignette;

  // Glow

  if (on(uEnablePhosphorGlow)) {
    uiColor = mix(
      uiColor,
      phosphorGlow(sampleUv, uGlowRadius),
      0.7
    );
  }

  // Bloom

  if (on(uEnableBloom)) {
    uiColor +=
        bloomPass(
          sampleUv,
          uBloomRadius,
          uBloomIntensity
        ) * uBloomColor;
  }

  // Scanlines

  if (on(uEnableScanlines)) {
    float lp = mod(fragCoord.y, uScanlineSpacing);

    uiColor = mix(
      uiColor,
      vec3(0.0),
      (1.0 - smoothstep(0.0, 1.0, lp))
      * uScanlineOpacity
    );
  }

  // Pixel Grid

  if (on(uEnablePixelGrid)) {
    vec2 gp = mod(fragCoord, vec2(uPixelGridSize));

    float gx = smoothstep(
      uPixelGridSize - 1.0,
      uPixelGridSize - 0.5,
      gp.x
    );

    float gy = smoothstep(
      uPixelGridSize - 1.0,
      uPixelGridSize - 0.5,
      gp.y
    );

    uiColor = mix(
      uiColor,
      vec3(0.0),
      max(gx, gy) * uPixelGridOpacity * 0.5
    );
  }

  // Noise

  if (on(uEnableNoise)) {
    float ns = floor(uTime * 20.0);

    float n = hash31(
      vec3(fragCoord / uNoiseDensity + ns, 0.0)
    );

    uiColor = mix(
      uiColor,
      vec3(1.0),
      n * uNoiseOpacity * 0.2
    );
  }

  // Flicker

  if (on(uEnableFlicker)) {
    float flicker =
        1.0 - uFlickerIntensity *
        (sin(uTime * 8.0) * 0.5 + 0.5);

    uiColor *= flicker;
  }

  fragColor = vec4(uiColor, 1.0);
}