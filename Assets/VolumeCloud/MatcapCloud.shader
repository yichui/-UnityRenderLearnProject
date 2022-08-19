Shader "Unlit/MatcapCloud"
{
	Properties
	{
		_LightColor("LightColor", color) = (1,1,1,1)
		//_OutLineColor ("OutLineColor", color) = (1,1,1,1)
		_CloudColor("CloudColor", color) = (1,1,1,1)
		_MainTex("Base(RGB) Trans (A)",2D) = "white" {}
		_EdgeIntensity("Edge Intensity", float) = 1
		_Lighting("Matcap Lit", 2D) = "white" {}
		_EdgeLit("Edge Lit", 2D) = "white" {}
		_InvFade("Soft Particles Factor", Range(0.001, 1)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "LightMode"="ForwardBase"}
        LOD 200
		//��Ⱦ�ⲿpass
		Pass
		{
			Blend One OneMinusSrcColor, One Zero
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_particles
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _Lighting_ST;
			sampler2D _Lighting;
			sampler2D _EdgeLit;
			float4 _EdgeLit_ST;
			fixed4 _EdgeIntensity;
			uniform fixed4 _MainTex_ST;
			fixed4 _CloudColor;
			//fixed4 _OutLineColor;

			fixed _InvFade;

			struct appdata
			{
				fixed2 texcoord : TEXCOORD0;
				float4 vertex : POSITION;
				float2 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float4 scrPos: TEXCOORD1;
				float4 color : COLOR;
				float3 texcoord1 : TEXCOORD2;
			};

		


			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.scrPos = ComputeScreenPos(o.vertex);
				//���㶥���������ľ���
				COMPUTE_EYEDEPTH(o.scrPos.z);
				o.color = v.color;
				return o;
			}
			fixed4 frag(v2f i) :COLOR{
				fixed4 col = tex2D(_MainTex,i.texcoord);
				col.rgb *= 0;
				col.a *= i.color.a;
				fixed4 edgeLit = tex2D(_EdgeLit, TRANSFORM_TEX(i.scrPos.xy, _EdgeLit));
				col.rgb = (edgeLit)*col.a * _EdgeIntensity;// *_OutLineColor;
				return col;
			}
			ENDCG
		}
		//��Ⱦ�ڲ�pass
        Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile_particles

            // make fog work

            #include "UnityCG.cginc"

			struct appdata
			{
				fixed2 texcoord : TEXCOORD0;
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				fixed4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				fixed2 cap : TEXCOORD1;
				float4 scrPos: TEXCOORD2;
				float4 color : COLOR;
				float3 texcoord1 : TEXCOORD4;
			};


			fixed4 _LightColor;
			fixed4 _CloudColor;

			sampler2D _MainTex;
			sampler2D _Lighting;
			sampler2D _EdgeLit;

			float4 _Lighting_ST;
			float4 _EdgeLit_ST;
			fixed4 _EdgeIntensity;
			uniform fixed4 _MainTex_ST;
			//fixed4 _OutLineColor;

			fixed _InvFade;

			v2f vert(appdata v) {
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);

				fixed2 capCoord;
				//���߱任��ת�������
				fixed3 worldNorm = UnityObjectToWorldNormal(v.normal);
				//ת�����ߵ��ӿռ�
				worldNorm = mul((fixed3x3)UNITY_MATRIX_V, worldNorm);

				o.cap.xy = worldNorm.xy*0.5 + 0.5;
				o.scrPos = ComputeScreenPos(o.vertex);
				//���㶥���������ľ���
				COMPUTE_EYEDEPTH(o.scrPos.z);
				o.color = v.color;
				return o;
			}
			fixed4 frag(v2f i) :COLOR{
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
				fixed4 mc = tex2D(_Lighting,i.cap)*_CloudColor;
				fixed4 col = tex2D(_MainTex, i.texcoord.xy);
				fixed4 edgeLit = tex2D(_EdgeLit, i.scrPos.xy/i.scrPos.w);
				 
				col.rgb *= lerp(i.color * (mc*2), col.rgb, edgeLit);
				col.a *= i.color.a;
				
				return col;
			}
            ENDCG
        }
    }
}
