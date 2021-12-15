using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

/// <summary>
/// ��������Ⱦ˳���Ƶ��������Ⱦ
/// </summary>
public class RenderPutAfterPostEffect : MonoBehaviour
{
    public Renderer _targetRenderer = null;

    CommandBuffer _commandBuffer = null;

    void OnEnable()
    {
        _targetRenderer = gameObject.GetComponentInChildren<Renderer>();
        if (_targetRenderer)
        {
            _commandBuffer = new CommandBuffer();
            //  Add a "draw renderer" command.
            _commandBuffer.DrawRenderer(_targetRenderer, _targetRenderer.sharedMaterial);
            //ֱ�Ӽ��������CommandBuffer�¼�������,�Ƶ����������ʾ
            Camera.main.AddCommandBuffer(CameraEvent.AfterImageEffects, _commandBuffer);

            //��������������������ȣ�ֻ������Ҫ����ǰ����������������
            _targetRenderer.enabled = false;
        }
    }

    private void OnDisable()
    {
        if (_targetRenderer)
        {
            //�Ƴ��¼���������Դ
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterImageEffects, _commandBuffer);
            _commandBuffer.Clear();
            _targetRenderer.enabled = true;
        }   

    }
}
