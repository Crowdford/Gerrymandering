#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec2 texCoord3;
in vec4 normal;

out vec4 fragColor;

#define NODE_RADIUS (0.25)

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    
    switch(int(round(color.a * 255.0))) {
        case 254:
            color.a = 1.0;
        break;
        case 253:
            if(pow(texCoord3.x - 0.5, 2) + pow(texCoord3.y - 0.5, 2) < pow(NODE_RADIUS, 2)) {
                color.a = 1.0;
            } else {
                color.a = 0.0;
            }
        break;
    }
    
    color = color * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}
