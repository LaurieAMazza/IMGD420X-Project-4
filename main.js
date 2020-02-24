var glslify = require('glslify')
var shell     = require('gl-now')()
var fbo     = require('gl-fbo')
var ndarray = require("ndarray")
var fill = require("ndarray-fill")
var fillScreen = require('a-big-triangle')
var createShader = require('gl-shader')

var draw = glslify('./draw.glsl'),
    vert = glslify('./vert.glsl'),
    gol  = glslify('./frag.glsl')

//var simShader = glslify({frag: gol, vert: vert})
//var drawShader = glslify({frag: draw, vert: vert})

var dShader, upShader, state, current = 0, time = 0

shell.on("gl-init", function () {
    var gl = shell.gl
    const w = 512
    const h = 512

    gl.disable(gl.DEPTH_TEST)

    upShader = createShader(gl, vert, gol)
    dShader = createShader(gl, vert, draw)

    state = [fbo( gl, [w,h] ), fbo( gl, [w,h] )]

    //Initialize state buffer
    var initial_conditions = new Float32Array(w*h*4)
    state[0].color[0].bind()
    for( let i = 0; i < h * w; i++ ) {
        for( let j = 0; j < 4; j++ ) {
            initial_conditions[ (i * 4) + j ] = Math.random()
        }
    }
    gl.texSubImage2D(
        gl.TEXTURE_2D, 0, 0, 0, w, h, gl.RGBA, gl.FLOAT, initial_conditions
    )

    //Set up vertex pointers
    dShader.attributes.a_position.location = upShader.attributes.a_position.location = 0
})

shell.on("tick", function() {
    var gl = shell.gl
    var prevState = state[current]
    var curState = state[current ^= 1]

    curState.bind() // fbo

    upShader.bind()
    upShader.uniforms.state = prevState.color[0].bind()
    upShader.uniforms.resolution = prevState.shape
    console.log(current)

    fillScreen(gl)
})

shell.on("gl-render", function(t) {
    var gl = shell.gl

    dShader.bind()
    dShader.uniforms.state = state[ current ].color[0].bind()
    dShader.uniforms.resolution = state[current].shape
    dShader.uniforms.time = time++
    fillScreen(gl)
})