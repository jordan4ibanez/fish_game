module graphics.model_manager;

import raylib;
import std.container;
import std.stdio;
import std.string;

static final const class ModelManager {
static:
private:

    Model*[string] database;
    bool[string] isCustomDatabase;

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
        isCustomDatabase[name] = true;
    }

    public void setModelTexture(string modelName, string textureName) {

        if (modelName !in database) {
            throw new Error(
                "[ModelManager]: Tried to set texture on non-existent model [" ~ modelName ~ "]");
        }

        Model* thisModel = database[modelName];

    }

    public void terminate() {
        foreach (key, thisModel; database) {

            // If we were using the D runtime to make this model, we'll customize
            // the way we free the items. This makes the GC auto clear.
            if (isCustomDatabase[key]) {
                Mesh thisMeshInModel = thisModel.meshes[0];
                thisMeshInModel.vertexCount = 0;
                thisMeshInModel.vertices = null;
                thisMeshInModel.texcoords = null;
                UnloadMesh(thisMeshInModel);
                thisModel.meshes = null;
                thisModel.meshCount = 0;
                UnloadModel(*thisModel);
            }
        }

        database.clear();
        isCustomDatabase.clear();
    }

    //* BEGIN INTERNAL API.

}
