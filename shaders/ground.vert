#version 330

in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec4 vertexColor;

out vec2 fragTexCoord;
out vec4 fragColor;
out float sheen;

uniform mat4 mvp;

uniform float waterHeight;
uniform float groundScale;
uniform float shimmerRoll;

void main()
{
    // The ground will gradually darken as the water gets deeper.
    if (vertexPosition.y >= waterHeight) {
        sheen = 1.0;
    } else {
        // Divide by two because the heightmap scales from -0.5 to 0.5;
        float maxDistance = (waterHeight + (groundScale / 2));
        float zeroedPosition = vertexPosition.y + maxDistance;
        sheen = clamp(zeroedPosition / maxDistance , 0.0, 1.0);
        sheen *= sheen;

        float shimmerStrenght = 1.0 - sheen;

    }

    sheen += shimmerRoll;

    fragTexCoord = vertexTexCoord;
    fragColor = vertexColor;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}