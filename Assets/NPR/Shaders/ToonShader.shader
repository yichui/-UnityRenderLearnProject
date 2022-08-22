Shader "NPR/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Facetor("Facetor", float) = 0.5
        _OutLineWidth("OutLineWidth", float) = 0.5
        _OutLineColor("OutLineColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        pass
        {
           Tags {"LightMode" = "ForwardBase"}

            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                //float3 normal : NORMAL;
                //half4 vertColor: COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                //half3 vertColor: TEXCOORD1;
            };
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.vertColor.xyz = v.vertColor.rgb;
                return o;
            }

            half4 frag(v2f i) : SV_TARGET
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                //return col;
                return fixed4(1,1,1,1);
            }

            ENDCG
        }
        Pass
        {
            Cull Front
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                half4 vertColor: COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                half3 vertColor: TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Facetor;
            half _OutLineWidth;
            float4 _OutLineColor;

            v2f vert (appdata v)
            {
                v2f o;

                float3 pos = normalize(v.vertex.xyz);
                float3 normal = normalize(v.normal);

                //�����Ϊ��ȷ��������ڼ������ĵ�ָ���жϴ˴��Ķ�����λ��ģ�͵İ�������͹��
                float D = dot(pos, normal);
                //��������ķ���ֵ���ж��Ƿ�������
                pos *= sign(D);
                //���ߵĳ����ֵ��������ƫ���߷����Ƕ��㷽��
                pos = lerp(normal, pos, _Facetor);

                //�����㳯ָ���򼷳�
                v.vertex.xyz += pos * _OutLineWidth;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertColor.xyz = v.vertColor.rgb;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                i.vertColor = tex2D(_MainTex, i.uv).rgb;
                //fixed4 col = tex2D(_MainTex, i.uv);
                
                return fixed4(_OutLineColor*i.vertColor, 0);

            }
            ENDCG
        }
    }
}
