module graphics.model_manager;

import raylib;
import std.container;
import std.string;

static final const class ModelManager {
static:
private:

    Model*[string] database;

    //* BEGIN PUBLIC API.

    public void newModelFromMesh(string name, float[] vertices, float[] textureCoordinates) {

        if (name in database) {
            throw new Error(
                "[ModelManager]: Tried to overwrite mesh [" ~ name ~ "]. Delete it first.");
        }

        Mesh* thisMesh = new Mesh();

        thisMesh.vertexCount = cast(int) vertices.length / 3;
        thisMesh.triangleCount = thisMesh.vertexCount / 3;
        thisMesh.vertices = vertices.ptr;
        thisMesh.texcoords = textureCoordinates.ptr;

        UploadMesh(thisMesh, false);

        Model* thisModel = new Model();
        *thisModel = LoadModelFromMesh(*thisMesh);

        database[name] = thisModel;
    }

    public void setModelTexture(string modelName, string textureName) {

        if (modelName !in database) {
            throw new Error(
                "[ModelManager]: Tried to set texture on non-existent model [" ~ modelName ~ "]");
        }

        Model* thisModel = database[modelName];

    }

    //* BEGIN INTERNAL API.

}
