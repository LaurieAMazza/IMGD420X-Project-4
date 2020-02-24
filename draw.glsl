#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D state;
uniform vec2 resolution;

void main() {
  gl_FragColor = vec4( texture2D( state, gl_FragCoord.xy / resolution ).rgb, 1. );
}