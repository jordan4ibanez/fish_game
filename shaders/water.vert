#version 330

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;

uniform mat4 mvp;

float rand(vec3 pos){
    return fract(sin(dot(pos, vec3(12.9898, 34.18232, 78.233))) * 43758.5453);
}

void main()
{
    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;

    vec4 temp = mvp * vec4(vertexPosition, 1.0);

    temp.y += rand(vec3(temp.xyz));

    gl_Position = temp;

    // gl_Position.y = vertexPosition.y + rand(gl_Position.xyz);
    //  vertexPosition.y + rand(vertexPosition), vertexPosition.z 
}