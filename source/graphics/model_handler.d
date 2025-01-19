module graphics.model_handler;

import graphics.texture_manager;
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
        Texture2D* thisTexture = TextureManager.getTexturePointer(textureName);
        thisModel.materials[0].maps[MATERIAL_MAP_DIFFUSE].texture = *thisTexture;
    }

    public void destroy(string modelName) {
        if (modelName !in database) {
            throw new Error("[ModelManager]: Tried to destroy non-existent model. " ~ modelName);
        }

        Model* thisModel = database[modelName];

        destroyModel(modelName, thisModel);

        database.remove(modelName);
        isCustomDatabase.remove(modelName);
    }

    public void terminate() {
        foreach (modelName, thisModel; database) {
            destroyModel(modelName, thisModel);
        }
        database.clear();
        isCustomDatabase.clear();
    }

    //* BEGIN INTERNAL API.

    void destroyModel(string modelName, Model* thisModel) {
        // If we were using the D runtime to make this model, we'll customize
        // the way we free the items. This makes the GC auto clear.
        if (isCustomDatabase[modelName]) {
            Mesh thisMeshInModel = thisModel.meshes[0];
            thisMeshInModel.vertexCount = 0;
            thisMeshInModel.vertices = null;
            thisMeshInModel.texcoords = null;
            UnloadMesh(thisMeshInModel);
            thisModel.meshes = null;
            thisModel.meshCount = 0;
            UnloadModel(*thisModel);
        } else {
            UnloadModel(*thisModel);
        }
    }

}
