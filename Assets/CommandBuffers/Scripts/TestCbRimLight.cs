using System.Collections;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;


public class TestCbRimLight : PostEffectBase
{
    private CommandBuffer commandBuffer = null;
    private RenderTexture renderTexture = null;
    private Renderer targetRenderer = null;
    public GameObject targetObject = null;
    public Material replaceMaterial = null;

    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;//����
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;  //�Աȶ�
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;//���Ͷ�

    void OnEnable()
    {
        targetRenderer = targetObject.GetComponentInChildren<Renderer>();
        //����RT
        renderTexture = RenderTexture.GetTemporary(512, 512, 16, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Default, 4);
        commandBuffer = new CommandBuffer();
        //����Command Buffer��ȾĿ��Ϊ�����RT
        commandBuffer.SetRenderTarget(renderTexture);
        //��ʼ��ɫ����Ϊ��ɫ
        commandBuffer.ClearRenderTarget(true, true, Color.gray);
        //����Ŀ��������û���滻���ʣ������Լ��Ĳ���
        Material mat = replaceMaterial == null ? targetRenderer.sharedMaterial : replaceMaterial;
        commandBuffer.DrawRenderer(targetRenderer, mat);
        //Ȼ���������Ĳ���ʹ������RT��Ϊ������
        this.GetComponent<Renderer>().sharedMaterial.mainTexture = renderTexture;
        //targetRenderer.sharedMaterial.mainTexture = renderTexture;
        if (_Material)
        {
            //���Ǹ��Ƚ�Σ�յ�д����һ��RT����Ϊ��������Ϊ�������ĳЩ�Կ��Ͽ��ܲ�֧�֣������������ô���Ļ�...���Ƕ�������һ��RT
            commandBuffer.Blit(renderTexture, renderTexture, _Material);
        }
        //ֱ�Ӽ��������CommandBuffer�¼�������
        Camera.main.AddCommandBuffer(CameraEvent.BeforeForwardOpaque, commandBuffer);
    }

    void OnDisable()
    {
        //�Ƴ��¼���������Դ
        Camera.main.RemoveCommandBuffer(CameraEvent.BeforeForwardOpaque, commandBuffer);
        commandBuffer.Clear();
        //renderTexture.Release();
        RenderTexture.ReleaseTemporary(renderTexture);
    }

    //Ϊ�������������update������
    void Update()
    {
        _Material.SetFloat("_Brightness", brightness);
        _Material.SetFloat("_Saturation", saturation);
        _Material.SetFloat("_Contrast", contrast);

    }
    //Ҳ������OnPreRender��ֱ��ͨ��Graphicsִ��Command Buffer������OnPreRender��OnPostRenderֻ�ڹ�������Ľű��ϲ������ã�����
    //void OnPreRender()
    //{
    //    //����ʽ��Ⱦǰִ��Command Buffer
    //    Graphics.ExecuteCommandBuffer(commandBuffer);

        //}
    }
