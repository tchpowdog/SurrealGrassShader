

Shader "Custom/Surreal Grass Shader" {
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

			Tags{ "LightMode" = "Deferred" }

			CGPROGRAM
			#include "UnityCG.cginc"
			#include "UnityGBuffer.cginc"
			#include "UnityStandardUtils.cginc"
			#pragma target 4.0
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile_prepassfinal noshadowmask nodynlightmap nodirlightmap nolightmap


			sampler2D _Albedo1;
			sampler2D _Albedo2;
			sampler2D _Albedo3;
			sampler2D _Albedo1_ST;
			sampler2D _Albedo2_ST;
			sampler2D _Albedo3_ST;
			sampler2D _Normal1;
			sampler2D _Normal2;
			sampler2D _Normal3;
			sampler2D _Roughness1;
			sampler2D _Roughness2;
			sampler2D _Roughness3;
			float _Invert1;
			float _Invert2;
			float _Invert3;
			half _Glossiness;
			half _Metallic;
			float4 _SpecColor;
			sampler2D _OcclusionMap;
			float _OcclusionStrength;
			sampler2D _Noise;
			float4 _Noise_ST;
			float _Weight1;
			float _Weight2;
			float _Weight3;
			float4 _Tint1;
			float4 _Tint2;
			float4 _Tint3;
			float4 _RootTint;
			float _RootTintStart;
			float _RootTintSpread;
			half _GrassHeight;
			half _GrassWidth;
			half _Cutoff;
			half _WindStength;
			half _WindSpeed;
			float3 noise;

		struct v2g
		{
			float4 pos : POSITION;
			float3 norm : NORMAL;
			float2 uv : TEXCOORD0;
			float3 noise : TEXCOORD1;
		};

		struct g2f
		{
			float4 pos : POSITION;
			float3 norm : NORMAL;
			float2 uv : TEXCOORD0;
			float3 noise : TEXCOORD2;
			float4 tspace0 : TEXCOORD4;
			float4 tspace1 : TEXCOORD5;
			float4 tspace2 : TEXCOORD6;
			half3 ambient : TEXCOORD7;
		};

		struct Varyings
		{
			float4 position : SV_POSITION;
			float3 normal : NORMAL;
			float2 texcoord : TEXCOORD0;
			float4 tspace0 : TEXCOORD1;
			float4 tspace1 : TEXCOORD2;
			float4 tspace2 : TEXCOORD3;
			half3 ambient : TEXCOORD4;
			float3 noise : TEXCOORD5;
		};

		v2g vert(appdata_full v)
		{
			float3 v0 = v.vertex.xyz;

			v2g OUT;
			OUT.pos = v.vertex;
			OUT.norm = v.normal;
			OUT.uv = v.texcoord;

			float3 noise = tex2Dlod(_Noise, float4(v.vertex.xz * _Noise_ST.xy + _Noise_ST.zw, 0, 0)).xyz;
			noise = noise * 2 - 1;

			OUT.noise = noise;

			float noiseValue = noise.x;
			float totalWeight = _Weight1 + _Weight2 + _Weight3;
			float weight1Per = _Weight1 / (totalWeight);
			float weight2Per = _Weight2 / (totalWeight);

			float weight1Marker = weight1Per * 2.0;
			float weight2Marker = weight2Per * 2.0;
		
			return OUT;
		}

		float3 rotateVector(float3 vec, float ang)
		{
			return float3(vec.x * cos(ang) - vec.z * sin(ang), 0, vec.x * sin(ang) + vec.z * cos(ang));
		}

		Varyings VertexOutput(float4 wpos, half3 nrm, half4 wtan, float2 uv, float3 noise)
		{
			Varyings o;
			half3 bi = cross(nrm, wtan) * wtan.w * unity_WorldTransformParams.w;
			o.position = UnityObjectToClipPos(wpos);
			o.normal = nrm;
			o.texcoord = uv;
			o.tspace0 = float4(wtan.x, bi.x, nrm.x, wpos.x);
			o.tspace1 = float4(wtan.y, bi.y, nrm.y, wpos.y);
			o.tspace2 = float4(wtan.z, bi.z, nrm.z, wpos.z);
			o.ambient = ShadeSHPerVertex(nrm, 0);
			o.noise = noise;
			return o;
		}

		[maxvertexcount(12)]
		void geom(point v2g IN[1], inout TriangleStream<Varyings> triStream)
		{
			float3 lightPosition = _WorldSpaceLightPos0;

			float3 v0Norm = IN[0].norm;
			float3 noise = IN[0].noise;
			float3 pAngle = float3(1, 0, 0);
			pAngle = rotateVector(pAngle, ((noise.x + noise.z) * 360) * (3.14159 / 180));
			float3 faceNormal = cross(pAngle, v0Norm);

		
		
			float3 v0 = IN[0].pos.xyz;
			float3 v1 = v0 + (faceNormal * _GrassHeight * .05) + v0Norm * _GrassHeight * (0.333 - .05);
			float3 v2 = v0 + (faceNormal * _GrassHeight * .2) + v0Norm * _GrassHeight * (0.666 - .1);
			float3 v3 = v0 + (faceNormal * _GrassHeight * .45) + v0Norm * _GrassHeight * (1 - .15);

			float3 wind = float3(sin(_Time.x * _WindSpeed + v0.x) + sin(_Time.x * _WindSpeed + v0.z * 2) + sin(_Time.x * _WindSpeed * 0.1 + v0.x), 0,
				cos(_Time.x * _WindSpeed + v0.x * 2) + cos(_Time.x * _WindSpeed + v0.z));
			v1 += wind * _WindStength * .333;
			v2 += wind * _WindStength * .666;
			v3 += wind * _WindStength;

			/*float3 v0tov1Normal = cross(v1, pAngle);
			float3 v1tov2Normal = cross(v2, pAngle);
			float3 v2tov3Normal = cross(v3, pAngle);*/

			float3 v0tov1Normal = faceNormal;
			float3 v1tov2Normal = faceNormal;
			float3 v2tov3Normal = faceNormal;


			g2f OUT;

			// Quad 1
			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v0 + pAngle * 0.5 * _GrassWidth),
				            UnityObjectToWorldNormal(v0tov1Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
							float2(0, 0),
							noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v0 - pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v0tov1Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(1, 0),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v1 + pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v0tov1Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(0, .333),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v1 - pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v0tov1Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(1, .333),
				noise));
			triStream.RestartStrip();

			// Quad 2
			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v1 + pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v1tov2Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(0, .333),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v1 - pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v1tov2Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(1, .333),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v2 + pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v1tov2Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(0, .666),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v2 - pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v1tov2Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(1, .666),
				noise));
			triStream.RestartStrip();

			// Quad 3
			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v2 + pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v2tov3Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(0, .666),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v2 - pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v2tov3Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(1, .666),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v3 + pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v2tov3Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(0, 1),
				noise));

			triStream.Append(VertexOutput(mul(unity_ObjectToWorld, v3 - pAngle * 0.5 * _GrassWidth),
				UnityObjectToWorldNormal(v2tov3Normal),
				float4(UnityObjectToWorldDir(pAngle), 1),
				float2(1, 1),
				noise));
			triStream.RestartStrip();
		}

		void frag(Varyings IN,
			out half4 outGBuffer0 : SV_Target0,
			out half4 outGBuffer1 : SV_Target1,
			out half4 outGBuffer2 : SV_Target2,
			out half4 outEmission : SV_Target3)
		{

			float3 noise = IN.noise;

			float noiseValue = noise.x;

			float totalWeight = _Weight1 + _Weight2 + _Weight3;
			float weight1Per = _Weight1 / (totalWeight);
			float weight2Per = _Weight2 / (totalWeight);

			float weight1Marker = weight1Per * 2.0;
			float weight2Marker = weight2Per * 2.0;

			if (noiseValue > -1.0 && noiseValue <= (-1.0 + weight1Marker))
			{

				half4 normal = tex2D(_Normal1, IN.texcoord);
				normal.xyz = UnpackScaleNormal(normal, 1.0);
				float3 wn = normalize(float3(
					dot(IN.tspace0.xyz, normal),
					dot(IN.tspace1.xyz, normal),
					dot(IN.tspace2.xyz, normal)
					));



				fixed4 c = tex2D(_Albedo1, IN.texcoord) *_Tint1;
				c *= lerp(_RootTint, float4(1, 1, 1, 1), (IN.texcoord.y - _RootTintStart) / (_RootTintSpread - _RootTintStart));
				clip(c.a - _Cutoff);

				half occ = tex2D(_OcclusionMap, IN.texcoord).g;
				occ = LerpOneTo(occ, _OcclusionStrength);

				half3 c_diff, c_spec;
				half refl10;
				c_diff = DiffuseAndSpecularFromMetallic(
					c, _Metallic,
					c_spec, refl10
				);


				float roughness = tex2D(_Roughness1, IN.texcoord).a;
				if (_Invert1 > 0)
				{
					roughness *= -1;
				}
				//fixed4 c_spec = c * _SpecColor;
			
				UnityStandardData data;
				data.diffuseColor = c_diff;
				data.occlusion = occ; // data.occlusion = occ;
				data.specularColor = c_spec * _SpecColor;//data.specularColor = c_spec;
				data.smoothness = roughness;//data.smoothness = _Glossiness;
				data.normalWorld = wn;// float3(0,1,0);
				UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

				// Calculate ambient lighting and output to the emission buffer.
				float3 wp = float3(IN.tspace0.w, IN.tspace1.w, IN.tspace2.w);
				half3 sh = ShadeSHPerPixel(data.normalWorld, IN.ambient, wp);
				outEmission = half4(sh * c_diff, 1) * occ;
			}
			else if (noiseValue > (-1.0 + weight1Marker) && noiseValue <= (-1.0 + weight1Marker + weight2Marker))
			{
				half4 normal = tex2D(_Normal2, IN.texcoord);
				normal.xyz = UnpackScaleNormal(normal, 1.0);
				float3 wn = normalize(float3(
					dot(IN.tspace0.xyz, normal),
					dot(IN.tspace1.xyz, normal),
					dot(IN.tspace2.xyz, normal)
					));

				fixed4 c = tex2D(_Albedo2, IN.texcoord) *_Tint2;
				c *= lerp(_RootTint, float4(1, 1, 1, 1), (IN.texcoord.y - _RootTintStart) / (_RootTintSpread - _RootTintStart));
				clip(c.a - _Cutoff);

				half occ = tex2D(_OcclusionMap, IN.texcoord).g;
				occ = LerpOneTo(occ, _OcclusionStrength);

				half3 c_diff, c_spec;
				half refl10;
				c_diff = DiffuseAndSpecularFromMetallic(
					c, _Metallic,
					c_spec, refl10
				);

				float roughness = tex2D(_Roughness2, IN.texcoord).a;
				if (_Invert2 > 0)
				{
					roughness *= -1;
				}
				//fixed4 c_spec = c * _SpecColor;

				UnityStandardData data;
				data.diffuseColor = c_diff;
				data.occlusion = occ; // data.occlusion = occ;
				data.specularColor = c_spec * _SpecColor;//data.specularColor = c_spec;
				data.smoothness = roughness;//data.smoothness = _Glossiness;
				data.normalWorld = wn;// float3(0, 1, 0);
				UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

				// Calculate ambient lighting and output to the emission buffer.
				float3 wp = float3(IN.tspace0.w, IN.tspace1.w, IN.tspace2.w);
				half3 sh = ShadeSHPerPixel(data.normalWorld, IN.ambient, wp);
				outEmission = half4(sh * c_diff, 1) * occ;
			}
			else
			{
				half4 normal = tex2D(_Normal3, IN.texcoord);
				normal.xyz = UnpackScaleNormal(normal, 1.0);
				float3 wn = normalize(float3(
					dot(IN.tspace0.xyz, normal),
					dot(IN.tspace1.xyz, normal),
					dot(IN.tspace2.xyz, normal)
					));

				fixed4 c = tex2D(_Albedo3, IN.texcoord) *_Tint3;
				c *= lerp(_RootTint, float4(1, 1, 1, 1), (IN.texcoord.y - _RootTintStart) / (_RootTintSpread - _RootTintStart));
				clip(c.a - _Cutoff);

				half occ = tex2D(_OcclusionMap, IN.texcoord).g;
				occ = LerpOneTo(occ, _OcclusionStrength);

				half3 c_diff, c_spec;
				half refl10;
				c_diff = DiffuseAndSpecularFromMetallic(
					c, _Metallic,
					c_spec, refl10
				);

				float roughness = tex2D(_Roughness3, IN.texcoord).a;
				if (_Invert3 > 0)
				{
					roughness *= -1;
				}
				//fixed4 c_spec = c * _SpecColor;

				UnityStandardData data;
				data.diffuseColor = c_diff;
				data.occlusion = occ; // data.occlusion = occ;
				data.specularColor = c_spec * _SpecColor;//data.specularColor = c_spec;
				data.smoothness = roughness;//data.smoothness = _Glossiness;
				data.normalWorld = wn;// float3(0, 1, 0);
				UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

				// Calculate ambient lighting and output to the emission buffer.
				float3 wp = float3(IN.tspace0.w, IN.tspace1.w, IN.tspace2.w);
				half3 sh = ShadeSHPerPixel(data.normalWorld, IN.ambient, wp);
				outEmission = half4(sh * c_diff, 1) * occ;
			}
		}
			ENDCG

		}
	}
}