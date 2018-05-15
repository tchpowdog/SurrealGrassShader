using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System;

public class SurrealGrassCreator : EditorWindow {

    [MenuItem("Tools/Surreal Grass Creator")]
    public static void ShowWindow()
    {
        GetWindow<SurrealGrassCreator>("SG Creator");
    }


    public GameObject targetObject;
    public Texture2D densityMap;
    public int cellDivisions;
    public int grassSamples;
    public Material grassMaterial;
    //public Camera camera;
    //public float cullDistance;

    public Vector2 scrollPosition;

    public int originalLayer;
    //public string[] layers;
    public GUIContent[] layers;
    public int selectedLayer;

    private void OnGUI()
    {
        GUILayout.Label("Surreal Grass Creator", EditorStyles.boldLabel);

        scrollPosition = GUILayout.BeginScrollView(scrollPosition, false, false);
        //camera = (Camera)EditorGUILayout.ObjectField(new GUIContent("1. Camera"), camera, typeof(Camera));
        targetObject = (GameObject)EditorGUILayout.ObjectField(new GUIContent("1. Target GameObject"), targetObject, typeof(GameObject));
        if (GUILayout.Button("Auto-Assign Cell Division and Grass Density"))
        {
            if (targetObject == null)
            {
                ShowNotification(new GUIContent("You must select a Target Object before auto-assigning cell division and grass density."));
                return;
            }
            else
            {
                Bounds objectBounds = new Bounds();
                if (targetObject.GetComponent<Terrain>() != null)
                {
                    objectBounds = targetObject.GetComponent<Terrain>().terrainData.bounds;
                }
                else if (targetObject.GetComponent<MeshRenderer>() != null)
                {
                    objectBounds = targetObject.GetComponent<MeshRenderer>().bounds;

                }
                else
                {
                    ShowNotification(new GUIContent("Please select a valid Target GameObject"));
                    return;
                }

                float boundX = objectBounds.extents.x * 2;
                float boundZ = objectBounds.extents.z * 2;

                float cellDivSuggestion = 0;
                if (boundX < boundZ)
                    cellDivSuggestion = boundX / 10;
                else
                    cellDivSuggestion = boundZ / 10;

                //if (cellDivSuggestion < 1f)
                //    cellDivisions = 1f;
                //else
                    cellDivisions = Convert.ToInt32(Math.Ceiling(cellDivSuggestion));

                float size = objectBounds.extents.x > objectBounds.extents.z ? objectBounds.extents.x * 2 / (float)cellDivisions : objectBounds.extents.z * 2 / (float)cellDivisions;
                if (size >= 10)
                    grassSamples = 60000;
                else
                    grassSamples = Convert.ToInt32(Math.Ceiling(size / (float)10 * (float)60000));


            }
        }

        List<GUIContent> tempLayerList = new List<GUIContent>();
        for (int i = 0; i <= 31; i++)
        {
            var layer = LayerMask.LayerToName(i);
            if (layer.Length > 0)
            {
                if (FindGameObjectsWithLayer(layer) == null)
                {
                    tempLayerList.Add(new GUIContent(layer));
                }
            }
        }
        layers = tempLayerList.ToArray();

        selectedLayer = EditorGUILayout.Popup(new GUIContent("2. Empty Layer"), selectedLayer, layers);
        densityMap = (Texture2D)EditorGUILayout.ObjectField(new GUIContent("3. Grass Density Map"), densityMap, typeof(Texture2D));
        cellDivisions = EditorGUILayout.IntSlider(new GUIContent("4. Cell Divisions"), cellDivisions, 1, 1000);
        grassSamples = EditorGUILayout.IntSlider(new GUIContent("5. Cell Grass Density"), grassSamples, 0, 60000);
        //cullDistance = EditorGUILayout.FloatField(new GUIContent("7. Cull Distance"), cullDistance);
        grassMaterial = (Material)EditorGUILayout.ObjectField(new GUIContent("6. Grass Material"), grassMaterial, typeof(Material));

        GUILayout.Space(15.0f);
        GUILayout.Label("How To Use", EditorStyles.boldLabel);
        string descriptionString = "Surreal Grass works by creating a grid of cells over your entire target terrain or mesh, each cell then gets populated with " +
                                   "a specified number of grass blades.  This editor will generate all of the cells for you and pack them into one object " +
                                   " in your scene.";
        GUILayout.Label(descriptionString, EditorStyles.wordWrappedLabel);

        GUILayout.Label("*** Disclaimer ***", EditorStyles.boldLabel);
        GUILayout.Label("Surreal Grass will create a new layer in your scene and temporarily move the Target Object to that layer.  After the tools runs, it will move your Target Object back to its original layer.", EditorStyles.wordWrappedLabel);
        GUILayout.Space(15.0f);
        GUILayout.Label("Step 1:  You can run this tool multiple times to have grass spawn on different objects, just select a new Target GameObject each time you run the tool. (this setting cannot be changed after creating Grass objects)", EditorStyles.wordWrappedLabel);
        GUILayout.Space(15.0f);
        GUILayout.Label("Step 2:  You must create and assign an empty layer to the Surreal Grass Creator to do it's thing on.  This layer can be deleted after the tool runs or it can be reused for running the tool multiple times as long as it stays empty.", EditorStyles.wordWrappedLabel);
        GUILayout.Space(15.0f);
        GUILayout.Label("Step 3:  This is the density map that will be applied to your target object to determine where grass is rendered.  BLACK = rendered, WHITE = not rendered (this setting cannot be changed after creating Grass objects)", EditorStyles.wordWrappedLabel);
        GUILayout.Space(15.0f);
        GUILayout.Label("Step 4:  This figure determines the size of each cell.  e.g. A value of \"10\" will calculate 10 divisions in the X direction and 10 divisions in the Z direction resulting in 100 total cells.  A good grass density is about 60,000 blades per 10m square.  So it's good to make sure that your cell divisions figure results in a cell size of around 10m.  If your mesh/terrain is smaller than 10m square, then just use a division of \"1\".  The higher the number of divisions, the longer this tool takes to run.  (this setting cannot be changed after creating Grass objects)", EditorStyles.wordWrappedLabel);
        GUILayout.Space(15.0f);
        GUILayout.Label("Step 5:  Surreal Grass allows up to 60,000 blades of grass per cell. (this setting cannot be changed after creating Grass objects)", EditorStyles.wordWrappedLabel);
        GUILayout.Space(15.0f);
        GUILayout.Label("Step 6:  Multiple grass materials can be created using the SurrealGrassShader, select the grass material you want to use for this Target object.  The selected material DOES NOT replace the material on the object itself.  If none is selected, the creator will use the \"SurrealDefaultGrassMat\" material", EditorStyles.wordWrappedLabel);

        

        GUILayout.EndScrollView();

        if (GUILayout.Button("Generate Grass Objects"))
        {
            if (targetObject == null)
            {
                ShowNotification(new GUIContent("You must select a Target Object before generating grass objects."));
                return;
            }
            else
            {
                Bounds objectBounds = new Bounds();
                
                int targetObjectType = 0;
                if (targetObject.GetComponent<Terrain>() != null)
                {
                    objectBounds = targetObject.GetComponent<Terrain>().terrainData.bounds;
                    targetObjectType = 1;
                }
                else if (targetObject.GetComponent<MeshRenderer>() != null)
                {
                    objectBounds = targetObject.GetComponent<MeshRenderer>().bounds;
                    targetObjectType = 2;
                }
                else
                {
                    ShowNotification(new GUIContent("Please select a valid Target GameObject"));
                    return;
                }

                float size = objectBounds.extents.x > objectBounds.extents.z ? objectBounds.extents.x * 2 / cellDivisions : objectBounds.extents.z * 2 / cellDivisions;

                float destYPosition = (objectBounds.extents.y * 2) + 100f;

                float srcXPosition = targetObject.transform.position.x - (targetObjectType == 2 ? objectBounds.extents.x : 0f);
                float srcZPosition = targetObject.transform.position.z - (targetObjectType == 2 ? objectBounds.extents.z : 0f);

                float destXorigin = srcXPosition;
                float destZorigin = srcZPosition;
                float destXPosition = srcXPosition;
                float destZPosition = srcZPosition;

                LayerMask layerMask = new LayerMask();
                layerMask.value = LayerMask.NameToLayer(layers[selectedLayer].text);

                originalLayer = targetObject.layer;
                targetObject.layer = layerMask.value;

                GameObject parentEmpty = new GameObject(targetObject.name + "_SGRenderer");
                parentEmpty.transform.position = new Vector3(srcXPosition, targetObject.transform.position.y, srcZPosition);

                

                for (int x = 0; x < cellDivisions; x++)
                {
                    destZPosition = destZorigin;
                    destXPosition = destXorigin + (x * size);
                    for (int z = 0; z < cellDivisions; z++)
                    {
                        destZPosition = destZorigin + (z * size);

                        GameObject empty = new GameObject(targetObject.name + "_SGRenderer_" + x.ToString() + "_" + z.ToString());
                        MeshFilter filter = empty.AddComponent<MeshFilter>();
                        MeshRenderer renderer = empty.AddComponent<MeshRenderer>();
                        //filter.name = targetObject.name + "_SGMeshFilter";
                        Mesh mesh = new Mesh();
                        empty.layer = layerMask.value;

                        empty.transform.position = new Vector3(srcXPosition, targetObject.transform.position.y, srcZPosition);

                        List<Vector3> positions = new List<Vector3>();
                        List<int> indicies = new List<int>();
                        List<Vector3> normals = new List<Vector3>();
                        int hitCount = 0;
                        for (int i = 0; i < grassSamples; i++)
                        {
                            Vector3 origin = new Vector3(destXPosition, destYPosition, destZPosition);
                            origin.x += size * UnityEngine.Random.Range(0.0f, 1f);
                            origin.z += size * UnityEngine.Random.Range(0.0f, 1f);
                            Ray ray = new Ray(origin, Vector3.down);
                            
                            RaycastHit hit;
                            if (Physics.Raycast(ray, out hit, 1000f, 1 << layerMask.value))
                            {
                                bool record = true;
                                if (densityMap != null)
                                {
                                    record = false;
                                    Vector2 uvCoord = hit.textureCoord;
                                    Color color = densityMap.GetPixel(Convert.ToInt32(uvCoord.x * densityMap.width), Convert.ToInt32(uvCoord.y * densityMap.height));
                                    if (color.grayscale < 0.5f)
                                        record = true;
                                }

                                if (record)
                                {
                                    origin.x -= empty.transform.position.x;
                                    origin.z -= empty.transform.position.z;
                                    positions.Add(hit.point);
                                    indicies.Add(hitCount);
                                    normals.Add(hit.normal);
                                    hitCount += 1;
                                }
                            }
                        }
                        if (hitCount > 1)
                        {
                            mesh.SetVertices(positions);
                            mesh.SetIndices(indicies.ToArray(), MeshTopology.Points, 0);
                            mesh.SetNormals(normals);
                            filter.mesh = mesh;
                            filter.transform.position = new Vector3(0, 0, 0);

                            if (grassMaterial != null)
                                renderer.material = grassMaterial;

                            parentEmpty.layer = layerMask.value;
                            empty.layer = layerMask.value;
                            empty.transform.SetParent(parentEmpty.transform, true);
                        }
                        else
                        {
                            DestroyImmediate(empty);
                        }
                    }
                }
                targetObject.layer = originalLayer;
            }
        }
    }

    public List<GameObject> FindGameObjectsWithLayer(string l) {
        var goArray = FindObjectsOfType(typeof(GameObject)) as GameObject[];
        List<GameObject> goFound = new List<GameObject>();
        foreach (GameObject go in goArray)
        {
            if (LayerMask.LayerToName(go.layer) == l)
            {
                goFound.Add(go);
            }
        }
        
        if (goFound.Count == 0) {
            return null;
        }
        return goFound;
    }

}
