using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;



/// <summary>
/// ���չٷ�commandbuff�����ӣ���BeforeForwardAlpha����Ⱦ˳��ǰ��ȡ����ǰ��Ļ��rt,
/// ����ģ��Ч����õ�һ��ģ��rt,����ŵ� Cube�����͸��shader�е�_GrabBlurTexture�У�
/// �ڰ�͸����Ⱦʱʹ�ã�ʹ����ǰ��Cube����������Ⱦģ��������Ч��
/// </summary>
public class TestCbBlurRefraction : MonoBehaviour
{
    private Camera m_Cam;
    public Shader m_Shader;
    private Material m_Material;

    private CameraEvent selectCameraEvent = CameraEvent.BeforeForwardAlpha;//CameraEvent.AfterSkybox ;

    private CommandBuffer _buf; 

   
   

    public void OnWillRenderObject()
    {
        bool isActive = gameObject.activeInHierarchy && enabled;
        if (!isActive)
        {
            Clear();
            return;
        }

        if (m_Shader == null)
            return;

        if (m_Material == null)
            m_Material = new Material(m_Shader);

        //if (m_Cam != null)
        //{
        //    return;
        //}

        m_Cam = Camera.current;

        if (m_Cam != null && _buf != null)
            m_Cam.RemoveCommandBuffers(selectCameraEvent);

        _buf = new CommandBuffer();
        _buf.name = "Grab cb test";

        //�ӵ�ǰ��Ļ����һ��tx
        int screenCopyID = Shader.PropertyToID("_ScreenCopyTexture");
        _buf.GetTemporaryRT(screenCopyID, -1, -1, 0, FilterMode.Bilinear);
        _buf.Blit(BuiltinRenderTextureType.CameraTarget, screenCopyID);

        // ��ȡ2�Ÿ�С����ͼ����ģ��
        int blurredID = Shader.PropertyToID("_Temp1");
        _buf.GetTemporaryRT(blurredID, -2, -2, 0, FilterMode.Bilinear);
        int blurredID2 = Shader.PropertyToID("_Temp2");
        _buf.GetTemporaryRT(blurredID2, -2, -2, 0, FilterMode.Bilinear);

        // �Ȳ���֮ǰ��������Ļrt�ŵ�blurredID��rt��
        //Ȼ���ͷŵ���Ļrt
        _buf.Blit(screenCopyID, blurredID);
        _buf.ReleaseTemporaryRT(screenCopyID);

        //�޸�SeparableBlur.shader��ȫ�ֲ���offsets,ʹ��������������ģ��Ч����������ǿЧ��
        // horizontal blur
        _buf.SetGlobalVector("offsets", new Vector4(2.0f / Screen.width, 0, 0, 0));
        _buf.Blit(blurredID, blurredID2, m_Material);
        // vertical blur
        _buf.SetGlobalVector("offsets", new Vector4(0, 2.0f / Screen.height, 0, 0));
        _buf.Blit(blurredID2, blurredID, m_Material);
        // horizontal blur
        _buf.SetGlobalVector("offsets", new Vector4(4.0f / Screen.width, 0, 0, 0));
        _buf.Blit(blurredID, blurredID2, m_Material);
        // vertical blur
        _buf.SetGlobalVector("offsets", new Vector4(0, 4.0f / Screen.height, 0, 0));
        _buf.Blit(blurredID2, blurredID, m_Material);

        //�õ�͸��Ч������󣬽��丳ֵ��GlassWithoutGrab.shader��_GrabBlurTexture��ϵõ�ģ��͸��
        _buf.SetGlobalTexture("_GrabBlurTexture", blurredID);

        _buf.ReleaseTemporaryRT(blurredID2);
        _buf.ReleaseTemporaryRT(blurredID);


        m_Cam.AddCommandBuffer(selectCameraEvent, _buf);

    }

    public void OnDisable()
    {
        Clear();
    }
    public void OnEnable()
    {
        Clear();
    }


    private void Clear()
    {
        if (m_Cam != null && _buf != null)
            m_Cam.RemoveCommandBuffer(selectCameraEvent, _buf);

        if (m_Material != null)
            Object.DestroyImmediate(m_Material);
    }
}
