module graphics.shader_handler;

import raylib;
import std.string;

static final const class ShaderHandler {
static:
private:

    Shader*[string] database;

    //* BEGIN PUBLIC API.

    public void newShader(string shaderName, string vertCodeLocation, string fragCodeLocation) {

        if (shaderName in database) {
            throw new Error("[ShaderHandler]: Tried to overwrite shader " ~ shaderName);
        }

        Shader* thisShader = new Shader();
        *thisShader = LoadShader(toStringz(vertCodeLocation), toStringz(fragCodeLocation));

        if (!IsShaderValid(*thisShader)) {
            throw new Error("[ShaderHandler]: Invalid shader. " ~ shaderName);
        }

        database[shaderName] = thisShader;

    }

    public Shader* getShaderPointer(string shaderName) {
        if (shaderName !in database) {
            throw new Error(
                "[ShaderHandler]: Tried to get non-existent shader pointer. " ~ shaderName);
        }
        return database[shaderName];
    }

    public void terminate() {
        foreach (shaderName, thisShader; database) {
            UnloadShader(*thisShader);
        }

        database.clear();
    }

    //* BEGIN INTERNAL API.
}
