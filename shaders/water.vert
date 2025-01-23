#version 330

#extension GL_ARB_arrays_of_arrays: require

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;

uniform mat4 mvp;
uniform float[128][128] heightData;


void main()
{
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;



    gl_Position = mvp * vec4(vertexPosition, 1.0);

    // gl_Position.y = vertexPosition.y + rand(gl_Position.xyz);
    //  vertexPosition.y + rand(vertexPosition), vertexPosition.z 
}