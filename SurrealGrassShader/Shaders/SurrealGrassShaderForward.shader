

Shader "Custom/Surreal Grass Shader(Forward)" {
	Properties{
		[Header(Grass Blade 1)]
		_Albedo1("Albedo", 2D) = "white" {}
		_Normal1("Normal", 2D) = "bump" {}
		_Roughness1("Roughness", 2D) = "white" {}
		[Toggle] _Invert1("Invert Smoothness?", Float) = 0
		_Weight1("Distribution Weight", Range(0.0, 1.0)) = 0.5
		_Tint1("Tint", Color) = (1,1,1,0)

		[Space]
		[Space]
		[Space]

		[Header(Grass Blade 2)]
		_Albedo2("Albedo", 2D) = "white" {}
		_Normal2("Normal", 2D) = "bump" {}
		_Roughness2("Roughness", 2D) = "white" {}
		[Toggle] _Invert2("Invert Smoothness?", Float) = 0
		_Weight2("Distribution Weight", Range(0.0, 1.0)) = 0.5
		_Tint2("Tint", Color) = (1,1,1,0)

		[Space]
		[Space]
		[Space]

		[Header(Grass Blade 3)]
		_Albedo3("Albedo", 2D) = "white" {}
		_Normal3("Normal", 2D) = "bump" {}
		_Roughness3("Roughness", 2D) = "white" {}
		[Toggle] _Invert3("Invert Smoothness?", Float) = 0
		_Weight3("Distribution Weight", Range(0.0, 1.0)) = 0.5
		_Tint3("Tint", Color) = (1,1,1,0)

		[Space]
		[Space]
		[Space]

		[Header(Root Settings)]
		_RootTint("Tint", Color) = (1,1,1,0)
		_RootTintStart("Tint Start Height", Range(0.1, 1.0)) = 0.2
		_RootTintSpread("Tint Spread", Range(0.2, 1.0)) = 0.8

		[Space]
		[Space]
		[Space]

		[Header(PBR Settings)]
		//_Glossiness("Smoothness", Range(0, 1)) = 0.5
		[Gamma] _Metallic("Metallic", Range(0, 1)) = 0
		_SpecColor("Specular Tint", Color) = (1,1,1,0)
		_OcclusionMap("Occlusion Map", 2D) = "white" {}
		_OcclusionStrength("Strength", Range(0, 1)) = 1

		[Space]
		[Space]
		[Space]

		[Header(Advanced Grass Settings)]
		_Cutoff("Cutoff", Range(0,1)) = 0.25
		_GrassHeight("Grass Height", Float) = 0.25
		_GrassWidth("Grass Width", Float) = 0.25
		_WindSpeed("Wind Speed", Float) = 100
		_WindStength("Wind Strength", Float) = 0.05
		_Noise("Noise", 2D) = "white" {}
	}
	SubShader{
		Tags{ "Queue" = "AlphaTest" "RenderType" = "TransparentCutout" "IgnoreProjector" = "True" }
		LOD 200

		Pass
		{
			CULL OFF
			Blend Off
			Lighting On

			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
//#include "UnityCG.cginc"
//#include "Lighting.cginc"
//#include "AutoLight.cginc"
			#include "GrassInclude.cginc"

			#pragma target 4.0
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_prepassfinal noshadowmask nodynlightmap nodirlightmap nolightmap


			ENDCG

		}
		Pass
	{
		CULL OFF
		Blend Off
		Lighting On

		Tags{ "LightMode" = "ShadowCaster" }

		CGPROGRAM
		//#include "UnityCG.cginc"
		//#include "Lighting.cginc"
		//#include "AutoLight.cginc"
#include "GrassInclude.cginc"

#pragma target 4.0
#pragma vertex vert
#pragma geometry geom
#pragma fragment frag
#pragma multi_compile_fwdbase
#pragma multi_compile_shadowcaster noshadowmask nodynlightmap nodirlightmap nolightmap
#define UNITY_PASS_SHADOWCASTER

		ENDCG

	}
	
	}
}