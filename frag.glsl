//referenced https://0fps.net/2012/11/19/conways-game-of-life-for-curved-surfaces-part-1/
#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;

// simulation texture state, swapped each frame
uniform sampler2D state;

uniform float time;

const float PI = 3.14159;

//Radius
const float iRadius = 1.0;
const float oRadius = 3.0 * iRadius;
//Area
float iArea = PI * iRadius * iRadius;
float oArea = PI * (oRadius * oRadius - iRadius * iRadius);

//Birth
float Bmax = 0.335;
float Bmin = 0.2;

//Death
float Dmax = 0.445;
float Dmin = 0.367;

//different alphas for different steps
float alpha_n = 0.03;
float alpha_m = 0.5;

//rim of width
float b = 1.0;

// look up individual cell values
float get(float x, float y) {
  return texture2D( state, (vec2(gl_FragCoord.xy) + vec2(x,y)) / resolution).r;
}

//equations taken from https://arxiv.org/pdf/1111.1567.pdf
//Sigmoid functions
float sigmoid1(float x, float a, float alpha){
    return 1.0 / (1.0 + exp(-(x - a) * 4. / alpha));
}

float sigmoid2(float x, float a, float b){
    return sigmoid1(x, a, alpha_n) * (1.0 - sigmoid1(x, b, alpha_n));
}

float sigmoidM(float x, float y, float m){
    return x * (1.0 - sigmoid1(m, 0.5, alpha_m)) + y * sigmoid1(m, 0.5, alpha_m);
}

//transition function
float s(float n, float m){
    return sigmoid2(n, sigmoidM(Bmin, Dmin, m), sigmoidM(Bmax, Dmax, m));
}

void main() {
  float inner = 0.0, outer = 0.0;

//go through every point within the radius
  for(float i = -oRadius; i <= oRadius; i++){
    for(float j = -oRadius; j <= oRadius; j++){
        float l = sqrt(j * j + i * i);
        float fval = get(i, j);

        //Inner circle
        if(l < iRadius - b/2.0){
            //take value as is
            inner += fval;
        } else if(l > iRadius + b/2.0){
            //take 0
            //inner += 0.02;
        } else{
            //The in between
            inner += fval * (iRadius + b/2.0 - l);
        }

        //check if inside the outer
        if(l < oRadius){
            //outer
            if(l < iRadius - b/2.0){
                //take value as is
                outer += fval;
            } else if (l > iRadius + b/2.0){
                //take 0
                //outer += 0.02;
            } else{
                //The in between
                outer += fval * (iRadius + b/2.0 - l);
            }
        }
    }
  }

  //Normalize
  float m = inner;
  float n = outer;

  float r = s(n, m) * 100000. + tan(time);
  float g = s(n, m) * 100000. + (1.0 - cos(time));
  float b = 1.0 - sin(g)/ sin(time);

   gl_FragColor = vec4(sin(r), sin(g), b, 1.);

  //gl_FragColor = vec4(0., 1., 0.,1.);
}