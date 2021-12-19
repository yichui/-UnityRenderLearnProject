/*���Ũ���������ֵ������������ٽ��е�ԭͼ��ɫ������ɫ�Ĳ�ֵ��*/
Shader "DepthTexture/ScanlineDepthTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScanLineWidth ("ScanLine Width", Range(0, 0.08)) = 0.01
        _ScanLineColor ("ScanLine Color", Color) = (1,1,1,1)
        _ScanValue("Scan Value", Range(0, 0.9)) = 0
    }
    SubShader
    {
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
            fixed4 _ScanLineColor;
            float _ScanLineWidth;
            float  _ScanValue;
            sampler2D _CameraDepthTexture;

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
                float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                //float depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                float linear01Depth = Linear01Depth(depth); //ת����[0,1]�ڵ����Ա仯���ֵ
                //float linearEyeDepth = LinearEyeDepth(depth); //ת����������ռ�


                float near = smoothstep(_ScanValue, linear01Depth, _ScanValue - _ScanLineWidth); // _ScanValue ���� ����ֵ, �� [0, 1] ����
                float far = smoothstep(_ScanValue, linear01Depth, _ScanValue + _ScanLineWidth);
                fixed4 scanlineClr = _ScanLineColor * saturate((near + far));
                return col + scanlineClr;
               
                //float halfWidth = _ScanLineWidth / 2;
                //float v = saturate(abs(_ScanValue - linear01Depth) / halfWidth); //���ڷ���(0, 1)�����ⷵ��1
                //float4 finalCol = lerp(_ScanLineColor, col, v);
               
                //return  finalCol;
            }       
            ENDCG
        }
    }
}
