#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

float packColor(vec3 color) {
    return color.b * 255.0 + color.g * 255.0 * 256.0 + color.r * 255.0 * 256.0 * 256.0;
}

#define LIGHT0_DIRECTION vec3(0.2, 1.0, -0.7) // Default light 0 direction everywhere except in inventory
#define LIGHT1_DIRECTION vec3(-0.2, 1.0, 0.7) // Default light 1 direction everywhere except in nether and inventory
mat3 getWorldMat(vec3 light0, vec3 light1) {
    mat3 V = mat3(normalize(LIGHT0_DIRECTION), normalize(LIGHT1_DIRECTION), normalize(cross(LIGHT0_DIRECTION, LIGHT1_DIRECTION)));
    mat3 W = mat3(normalize(light0), normalize(light1), normalize(cross(light0, light1)));
    return W * inverse(V);
}

void main() {
    
    float decColor = packColor(Color.rgb);
    float lengthX = mod(decColor, 256) - 128;
    float lengthY = mod(floor(decColor / 256), 256) - 128;
    
    mat3 WorldMat = getWorldMat(Light0_Direction, Light1_Direction);
    
    vec3 pos = inverse(WorldMat) * Position;
    
    switch(gl_VertexID % 4) {
        case 0:
            pos.x = pos.x + (lengthX / 2.0) * 0.1;
            pos.z = pos.z + (lengthY / 2.0) * 0.1;
        break;
        case 1:
            pos.x = pos.x + (lengthX / 2.0) * 0.1;
            pos.z = pos.z - (lengthY / 2.0) * 0.1;
        break;
        case 2:
            pos.x = pos.x - (lengthX / 2.0) * 0.1;
            pos.z = pos.z - (lengthY / 2.0) * 0.1;
        break;
        case 3:
            pos.x = pos.x - (lengthX / 2.0) * 0.1;
            pos.z = pos.z + (lengthY / 2.0) * 0.1;
        break;
    }

    
    gl_Position = ProjMat * ModelViewMat * vec4(WorldMat * pos, 1.0);
    
    

    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
}
