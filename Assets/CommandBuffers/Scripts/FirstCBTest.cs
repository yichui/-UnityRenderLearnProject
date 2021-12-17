using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;


/// <summary>
/// �������
/// ��һ��renderer��material�ύ����camera��commandbuffer�б���л�����Ⱦ��
/// ����ȽϺ���⣬render�����񼸺����ݼ���material��shader��Ⱦ������൱���ύdrawcall�ˡ�
/// �е�����OnImageRender����Ļ������Чһ����ԭ��standard���ʵĻ�ɫ��Ⱦ�������־���commandbuffָ����material�������ɫ��
/// </summary>
public class FirstCBTest : MonoBehaviour
{
    public Shader shader;
    private void OnEnable()
    {
        CommandBuffer cmd = new CommandBuffer();

        cmd.DrawRenderer(GetComponent<Renderer>(), new Material(shader));

        Camera.main.AddCommandBuffer(CameraEvent.AfterForwardOpaque ,cmd);
    }
}
