using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenCameraDepth : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;//���_��ǰ���C��ȈD
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
