﻿Shader "VotanicXR/OnTop" {
	Properties{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_OnTopAlpha("OnTopAlpha", float) = 0.5
		[Toggle(IS_TEXT)] _Text("Text", int) = 0
		[Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 0
	}

	SubShader{
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		Cull [_Cull]
		Blend SrcAlpha OneMinusSrcAlpha

	// Include functions common to both passes
	CGINCLUDE
		struct appdata_t {
			float4 vertex : POSITION;
			fixed4 color : COLOR;
			float2 texcoord : TEXCOORD0;
		};
		struct v2f {
			float4 vertex : SV_POSITION;
			fixed4 color : COLOR;
			half2 texcoord : TEXCOORD0;
		};

		#pragma vertex vert
		#pragma fragment frag
		#pragma shader_feature IS_TEXT

		#include "UnityCG.cginc"
		sampler2D _MainTex;
		float4 _MainTex_ST;
		float4 _Color;
		float _OnTopAlpha;
		bool _Text;

		v2f vert(appdata_t v)
		{
			v2f o;
			o.vertex = UnityObjectToClipPos(v.vertex);
			o.color = v.color * _Color;
			o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			return o;
		}
	ENDCG

		// Pass for fully visible parts of the object
		Pass {
			ZTest LEqual
			ZWrite Off
			CGPROGRAM
				fixed4 frag(v2f i) : COLOR
				{
					fixed4 col;
#ifdef IS_TEXT
					col = i.color;
					col.a *= tex2D(_MainTex, i.texcoord).a;
#else
					col = tex2D(_MainTex, i.texcoord) * i.color;
#endif
					clip(col.a - 0.01);
					return col;
				}
			ENDCG
		}

		// Pass for obscured parts of the object
		Pass {
			ZTest Greater
			ZWrite Off
			CGPROGRAM
				fixed4 frag(v2f i) : COLOR
				{
					fixed4 col;
#ifdef IS_TEXT
					col = i.color;
					col.a *= tex2D(_MainTex, i.texcoord).a;
#else
					col = tex2D(_MainTex, i.texcoord) * i.color;
#endif
					col.a *= _OnTopAlpha;
					clip(col.a - 0.01);
					return col;
				}
			ENDCG
		}
	}
}