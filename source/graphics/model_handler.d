module graphics.model_handler;

import graphics.texture_handler;
import raylib;
import std.container;
import std.stdio;
import std.string;

static final const class ModelHandler {
static:
private:

    Model*[string] database;
    bool[string] isCustomDatabase;

    //* BEGIN PUBLIC API.

    public void draw(
        string modelName, Vector3 position, Vector3 rotation = Vector3(0, 0, 0),
        float scale = 1.0, Color color = Colors.WHITE) {

        if (modelName !in database) {
            throw new Error("[ModelManager]: Cannot draw model that does not exist. " ~ modelName);
        }

        Model* thisModel = database[modelName];

        DrawModelEx(*thisModel, position, rotation, 1, Vector3(scale, scale, scale), color);
    }

    public void newModelFromMesh(string modelName, float[] vertices, float[] textureCoordinates) {

        if (modelName in database) {
            throw new Error(
                "[ModelManager]: Tried to overwrite mesh [" ~ modelName ~ "]. Delete it first.");
        }

        Mesh* thisMesh = new Mesh();

        thisMesh.vertexCount = cast(int) vertices.length / 3;
        thisMesh.triangleCount = thisMesh.vertexCount / 3;
        thisMesh.vertices = vertices.ptr;
        thisMesh.texcoords = textureCoordinates.ptr;

        UploadMesh(thisMesh, false);

        Model* thisModel = new Model();
        *thisModel = LoadModelFromMesh(*thisMesh);

        if (!IsModelValid(*thisModel)) {
            throw new Error("[ModelHandler]: Invalid model loaded from mesh. " ~ modelName);
        }

        database[modelName] = thisModel;
        isCustomDatabase[modelName] = true;
    }

    public void loadModelFromFile(string location) {
        Model* thisModel = new Model();

        // Extract the file name from the location.
        string fileName = () {
            string[] items = location.split("/");
            int len = cast(int) items.length;
            if (len <= 1) {
                throw new Error("[ModelManager]: Model must not be in root directory.");
            }
            string outputFileName = items[len - 1];
            return outputFileName;
        }();

        *thisModel = LoadModel(toStringz(location));

        if (!IsModelValid(*thisModel)) {
            throw new Error("[ModelHandler]: Invalid model loaded from file. " ~ location);
        }

        database[fileName] = thisModel;
        isCustomDatabase[fileName] = false;
    }

    public void setModelTexture(string modelName, string textureName) {

        if (modelName !in database) {
            throw new Error(
                "[ModelManager]: Tried to set texture on non-existent model [" ~ modelName ~ "]");
        }

        Model* thisModel = database[modelName];
        Texture2D* thisTexture = TextureHandler.getTexturePointer(textureName);
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
