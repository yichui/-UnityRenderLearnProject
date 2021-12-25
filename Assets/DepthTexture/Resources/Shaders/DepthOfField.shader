/*������Ⱦһ��ģ����ͼ��Ȼ�������ͼ���ҵ��۽����Ӧ����ȣ�
	����ȸ�����ԭͼ�������ط�������ģ��ͼ,
	���ݽ��������ԭͼ��ɫ��ģ��ͼ��ɫ��
	*/
Shader "DepthTexture/DepthOfField"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FocusLevel("Focus Level", Float) = 3 //�۽��ĳ̶�
        _FocusDistance("Focus Distance", Range(0, 1)) = 0
        _FocusColor("Focus Color", Color) = (0.5,0,0,1)
    }
    SubShader
    {
        // No culling or depth
        ZTest Always Cull Off ZWrite Off

        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos: TEXCOORD1;

            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            sampler2D _BlurTexture;
            sampler2D _CameraDepthTexture;
            float _FocusDistance;
            float _FocusLevel;
            fixed4 _FocusColor;

            float4 AsComputeScreenPos(float4 pos)
            {
                float4 o = pos * 0.5f;
                o.xy = float2(o.x, o.y * _ProjectionParams.x) + o.w;
                o.zw = pos.zw;
                return o;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = float4(v.uv, v.uv);
                #if UNITY_UV_STARTS_AT_TOP
                if (_MainTex_TexelSize.y < 0)
                    o.uv.w = 1 - o.uv.w;
                #endif

                o.screenPos = AsComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                fixed4 blurCol = tex2D(_BlurTexture, i.uv.xy);
                float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                //float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                float linear01Depth = Linear01Depth(depth); //ת����[0,1]�ڵ����Ա仯���ֵ
                //float linearEyeDepth = LinearEyeDepth(depth); //ת����������ռ�
                float focusDensity = saturate(abs(linear01Depth - _FocusDistance) * _FocusLevel);
                fixed4 finalColor = lerp(col + _FocusColor, blurCol, focusDensity);
                return finalColor;
            }       
            ENDCG
        }
    }
}
