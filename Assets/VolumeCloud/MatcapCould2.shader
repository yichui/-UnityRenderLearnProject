Shader "Unlit/MatcapCloud2"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_MatCapLight("MatCapLight", 2D) = "white" {}
		_EdgeLight("EdgeLight", 2D) = "white" {}
		_EdgeStrength("EdgeStrength", Float) = 0.0
		//	_CloudColor("CloudColor",Color) = 
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" }
			LOD 100

			//Pass
			//{
			//	CGPROGRAM
			//	#pragma vertex vert
			//	#pragma fragment frag
			//	// make fog work

			//	#include "UnityCG.cginc"

			//	struct appdata
			//	{
			//		float4 vertex : POSITION;
			//		float2 uv : TEXCOORD0;
			//		float4 color : TEXCOORD1;
			//	};

			//	struct v2f
			//	{
			//		float2 uv : TEXCOORD0;
			//		float4 pos : SV_POSITION;
			//		float4 scrPos: TEXCOORD1;
			//		float4 color : TEXCOORD2;
			//	};

			//	sampler2D _MainTex;
			//	float4 _MainTex_ST;
			//	sampler2D _EdgeLight;
			//	float _EdgeStrength;


			//	v2f vert(appdata v) {
			//		v2f o;
			//		o.pos = UnityObjectToClipPos(v.vertex);
			//		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
			//		o.scrPos = ComputeScreenPos(o.pos);
			//		o.color = v.color;
			//		return o;
			//	}
			//	fixed4 frag(v2f i) :SV_Target{
			//		fixed4 col = tex2D(_MainTex,i.uv);
			//		col.rgb *= 0;
			//		col.a *= i.color.a;
			//		fixed4 edgeCol = tex2D(_EdgeLight,i.scrPos.xy / i.scrPos.w);
			//		col.rgb = (edgeCol)*col.a * _EdgeStrength;
			//		return col;
			//	}
			//	ENDCG
			//}

			Pass
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				// make fog work

				#include "UnityCG.cginc"

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv : TEXCOORD0;
					float4 texcoord : TEXCOORD1;
					float3 normal : NORMAL;
					float4 color : COLOR;
				};

				struct v2f
				{
					float2 uv : TEXCOORD0;
					float4 pos : SV_POSITION;
					float4 cap :TEXCOORD1;
					float4 scrPos : TEXCOORD2;
					float4 color  : COLOR;
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _MatCapLight;

				v2f vert(appdata v) {
					v2f o;
					o.pos = UnityObjectToClipPos(v.vertex);
					o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
					//���߱任��ת�������
					fixed3 worldNormal = normalize(unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z);
					//ת�����ߵ��ӿռ�
					worldNormal = mul((fixed3x3)UNITY_MATRIX_V, worldNormal);
					o.cap.xyz = worldNormal * 0.5 + 0.5;
					//���㶥������Ļ�ռ��λ�ã�δ��һ��
					o.scrPos = ComputeScreenPos(o.pos);
					//���ʹ��������Ч��,�����ӿռ��µ����ֵ�������볡�����ֵ���Ƚ�
	//#ifdef SOFTPARTICLES_ON
	//				COMPUTE_EYEDEPTH(o.scrPos.z);
	//#endif
					o.color = v.color;

					return o;
				}
				fixed4 frag(v2f i) :SV_Target{
					//���ʹ��������Ч����ͨ�����ֵ�Ƚϣ������Ʋ�������壬�Ʋ�͸���ȸ�
					//#ifdef SOFTPARTICLES_ON
					////������������������������δ��һ����srcPos�������ڲ���srcPos.xy/srcPos.w͸�ӳ������õ��ӿ����꣩
					////ͨ��LinearEyeDepth����ת�����ӿռ��µ����
					//fixed sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture,UNITY_PROJ_COORD(i.scrPos)));
					////�����i.scrPos.z���� COMPUTE_EYEDEPTH(o.scrPos.z) �Ѿ��洢�����ӿռ�������
					//fixed partZ = i.scrPos.z;
					//fixed fade = saturate(_ParticleFade * (sceneZ - partZ));
					//i.color.a *= fade;
					//#endif

					//�����������
					fixed4 mc = tex2D(_MatCapLight,i.cap);// *_CloudColor;
					mc.a = 1;
					//���������
					fixed4 col = tex2D(_MainTex,i.uv);
					

					col.rgb *= i.color * mc * 3;
					col.a *= i.color.a;


					return col;
				}
				ENDCG
			}
		}
}
