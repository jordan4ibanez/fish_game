#version 330

in vec2 fragTexCoord;
in vec4 fragColor;
in float sheen;

out vec4 finalColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;

void main() {
    vec4 texelColor = texture(texture0, fragTexCoord);

    if (texelColor.a <= 0.1) {
        discard;
    }

    finalColor = texelColor * colDiffuse * fragColor;
}