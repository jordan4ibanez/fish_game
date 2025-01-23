#version 330

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;
out float sheen;

uniform mat4 mvp;

uniform float waterHeight;


void main()
{
    // temporary just to ensure this thing loads.
    sheen = vertexPosition.y - waterHeight;
    

    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    gl_Position = mvp * vec4(vertexPosition, 1.0);
}