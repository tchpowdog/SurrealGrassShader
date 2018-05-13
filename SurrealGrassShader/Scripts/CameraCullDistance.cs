using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CameraCullDistance : MonoBehaviour {

    public Camera camera;
    public bool updateCamera = false;
    public bool updateOnStart = false;
    public float[] layerCullDistances;

    private void Start()
    {
        if (layerCullDistances.Length == 0)
            layerCullDistances = camera.layerCullDistances;
        camera.layerCullDistances = layerCullDistances;
    }
    
    void Update () {
        if (updateCamera == true)
        {
            updateCamera = false;
            camera.layerCullDistances = layerCullDistances;
        }
        
	}
}
