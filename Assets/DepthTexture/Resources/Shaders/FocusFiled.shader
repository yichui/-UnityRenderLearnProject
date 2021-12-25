//1. Transparent
//2. Rim
//3. Intersection Highlight
Shader "DepthTexture/FocusFiled"
{
    Properties
    {
        _MainColor ("MainColor", Color) = (1,1,1,1)
        //_MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("NoiseTexture", 2D) = "white" {}
        _RimStrength("RimStrength",Range(0, 1)) = 1
        _IntersectPower("IntersectPower", Range(0, 1)) = 0.5
        //_IntersectionColor("_IntersectionColor", Color) = (1,1,1,1)
    }
    SubShader
    {

        Tags {"Queue" = "Transparent" "RenderType" = "Transparent" }

        Pass
        {
            //Cull Off
            ZWrite Off

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldViewDir : TEXCOORD1;
                //float2 uv : TEXCOORD2;

                float4 screenPos: TEXCOORD2;
                float eyeZ : TEXCOORD3;
            };
       


           /* sampler2D _MainTex;
            float4 _MainTex_ST;*/
            float4 _MainColor;
            sampler2D _CameraDepthTexture;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float _IntersectPower;
            float _RimStrength;

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
               /* o.uv = TRANSFORM_TEX(v.uv, _MainTex);*/

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldNormal = UnityObjectToWorldDir(v.normal);
                o.worldViewDir = UnityWorldSpaceViewDir(worldPos);

                o.screenPos = AsComputeScreenPos(o.vertex);

                COMPUTE_EYEDEPTH(o.eyeZ);//���㶥��������ռ����ȣ�����ü�ƽ��ľ��룬���Ա仯��


                return o;
            }

          

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv.xy);
               
                float3 worldNormal = normalize(i.worldNormal);
                float3 worldViewDir = normalize(i.worldViewDir);

                float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                
                //float linear01Depth = Linear01Depth(depth); //ת����[0,1]�ڵ����Ա仯���ֵ
                float linearEyeDepth = LinearEyeDepth(depth); //ת����������ռ�

                //�ཻ��������
                //float halfWidth = _IntersectionWidth / 2;
                //float diff = saturate(abs(i.eyeZ - screenZ) / halfWidth);
                //fixed4 finalColor = lerp(_IntersectionColor, col, diff);


          
               
                float rim = 1 - saturate(dot(worldNormal, worldViewDir)) * _RimStrength;//�����Ե
                float intersect = (1 - (linearEyeDepth - i.eyeZ)) * _IntersectPower;
                float v = max(rim, intersect);

               
                return _MainColor * v;

            }
            ENDCG
        }
    }
}
