#version 330

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;
out float sheen;

uniform mat4 mvp;

uniform float waterHeight;
uniform float shimmerRoll;

void main()
{
    sheen = vertexPosition.y - waterHeight;
    sheen += shimmerRoll;

    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}