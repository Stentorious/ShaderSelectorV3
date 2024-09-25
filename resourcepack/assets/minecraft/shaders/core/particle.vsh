#version 150

#moj_import <minecraft:fog.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec2 texCoord0;
out vec4 vertexColor;

// ShaderSelector
#moj_import <shader_selector:marker_settings.glsl>

uniform vec2 ScreenSize;

flat out int isMarker;
flat out ivec4 iColor;

vec2[] corners = vec2[](
    vec2(0.0, 1.0),
    vec2(0.0, 0.0),
    vec2(1.0, 0.0),
    vec2(1.0, 1.0)
);

void main() {
    // ShaderSelector
    iColor = ivec4(round(Color * 255.));
    isMarker = int(
        iColor.r == MARKER_RED
     && iColor.g >= MARKER_GREEN_MIN
     && iColor.g <= MARKER_GREEN_MAX
     && iColor.a == MARKER_ALPHA
    );
    ivec2 markerPos = ivec2(0, 0);
    if (isMarker == 1) {
        isMarker = 0;
        #define ADD_MARKER(row, coords, green, op, rate) if (green == iColor.g) {isMarker = 1; markerPos = coords;}
        LIST_MARKERS
    }
    if (isMarker == 1 && (markerPos.x+markerPos.y)%2 == 0) {
        vec2 markerSize = 2.0 / ScreenSize;

        gl_Position = vec4(-1 + (vec2(markerPos) + corners[gl_VertexID % 4]) * markerSize, 0.0, 1.0);

        vertexDistance = 0.0;
        texCoord0 = vec2(0.0);
        vertexColor = vec4(0.0);
        return;
    }
    // Vanilla code
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    texCoord0 = UV0;
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
}