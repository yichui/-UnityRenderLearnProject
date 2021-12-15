// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CommandBufferTest/ColorAdjustEffect"
{
	//���Կ飬shader�õ������ԣ�����ֱ����Inspector������
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Brightness("Brightness", Float) = 1
		_Saturation("Saturation", Float) = 1
		_Contrast("Contrast", Float) = 1
	}

	//ÿ��shader����Subshaer������subshaer֮����ƽ�й�ϵ��ֻ��������һ��subshader����Ҫ��Բ�ͬӲ��
	SubShader
	{
		//�����ɻ�ľ���Pass�ˣ�һ��shader�п����в�ͬ��pass������ִ�ж��pass
		Pass
		{
			//����һЩ��Ⱦ״̬���˴��Ȳ���ϸ����
			ZTest Always Cull Off ZWrite Off

			CGPROGRAM
			//��Properties�е�����ֻ�Ǹ�Inspector���ʹ�ã����������ڴ˴���ע��������һ����
			sampler2D _MainTex;
			half _Brightness;
			half _Saturation;
			half _Contrast;

			//vert��frag����
			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			//��vertex shader����pixel shader�Ĳ���
			struct v2f
			{
				float4 pos : SV_POSITION; //����λ��
				half2  uv : TEXCOORD0;	  //UV����
			};

			//vertex shader
			//appdata_img������λ�ú�һ����������Ķ�����ɫ������
			v2f vert(appdata_img v)
			{
				v2f o;
				//������ռ�ת��ͶӰ�ռ�
				o.pos = UnityObjectToClipPos(v.vertex);
				//uv���긳ֵ��output
				o.uv = v.texcoord;
				return o;
			}

			//fragment shader
			fixed4 frag(v2f i) : SV_Target
			{
				//��_MainTex�и���uv������в���
				fixed4 renderTex = tex2D(_MainTex, i.uv);
				//brigtness����ֱ�ӳ���һ��ϵ����Ҳ����RGB�������ţ���������
				fixed3 finalColor = renderTex * _Brightness;
				//saturation���Ͷȣ����ȸ��ݹ�ʽ����ͬ����������±��Ͷ���͵�ֵ��
				fixed gray = 0.2125 * renderTex.r + 0.7154 * renderTex.g + 0.0721 * renderTex.b;
				fixed3 grayColor = fixed3(gray, gray, gray);
				//����Saturation�ڱ��Ͷ���͵�ͼ���ԭͼ֮���ֵ
				finalColor = lerp(grayColor, finalColor, _Saturation);
				//contrast�Աȶȣ����ȼ���Աȶ���͵�ֵ
				fixed3 avgColor = fixed3(0.5, 0.5, 0.5);
				//����Contrast�ڶԱȶ���͵�ͼ���ԭͼ֮���ֵ
				finalColor = lerp(avgColor, finalColor, _Contrast);
				//���ؽ����alphaͨ������
				return fixed4(finalColor, renderTex.a);
			}
			ENDCG
		}
	}
	//��ֹshaderʧЧ�ı��ϴ�ʩ
	FallBack Off
}
