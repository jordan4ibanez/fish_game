module graphics.model_handler;

import graphics.shader_handler;
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

        // Have to jump through some hoops to rotate the model correctly.
        Quaternion quat = QuaternionFromEuler(rotation.x, rotation.y, rotation.z);
        Vector3 axisRotation;
        float angle;
        QuaternionToAxisAngle(quat, &axisRotation, &angle);

        DrawModelEx(*thisModel, position, axisRotation, RAD2DEG * angle, Vector3(scale, scale, scale), color);
    }

    public void newModelFromMesh(string modelName, float[] vertices, float[] textureCoordinates, bool dynamic = false) {

        if (modelName in database) {
            throw new Error(
                "[ModelManager]: Tried to overwrite mesh [" ~ modelName ~ "]. Delete it first.");
        }

        Mesh* thisMesh = new Mesh();

        thisMesh.vertexCount = cast(int) vertices.length / 3;
        thisMesh.triangleCount = thisMesh.vertexCount / 3;
        thisMesh.vertices = vertices.ptr;
        thisMesh.texcoords = textureCoordinates.ptr;

        UploadMesh(thisMesh, dynamic);

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

        foreach (index; 0 .. thisModel.materialCount) {
            thisModel.materials[index].maps[MATERIAL_MAP_DIFFUSE].texture = *thisTexture;
        }
    }

    public void setModelShader(string modelName, string shaderName) {

        if (modelName !in database) {
            throw new Error(
                "[ModelManager]: Tried to set shader on non-existent model [" ~ modelName ~ "]");
        }

        Model* thisModel = database[modelName];
        Shader* thisShader = ShaderHandler.getShaderPointer(shaderName);
        thisModel.materials[0].shader = *thisShader;
    }

    public Model* getModelPointer(string modelName) {
        if (modelName !in database) {
            throw new Error(
                "[ModelManager]: Tried to set get non-existent model pointer [" ~ modelName ~ "]");
        }

        return database[modelName];
    }

    public void updateModelPositionsInGPU(string modelName) {
        if (modelName !in database) {
            throw new Error(
                "[ModelManager]: Tried to update non-existent model [" ~ modelName ~ "]");
        }

        const Model* thisModel = database[modelName];

        /*
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION    0
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD    1
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL      2
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR       3
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT     4
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2   5
#define RL_DEFAULT_SHADER_ATTRIB_LOCATION_INDICES     6
        */

        foreach (i, thisMesh; thisModel.meshes[0 .. thisModel.meshCount]) {
            UpdateMeshBuffer(cast(Mesh) thisMesh, 0, &thisMesh.vertices[0], cast(int)(
                    thisMesh.vertexCount * 3 * float.sizeof), 0);
        }
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
