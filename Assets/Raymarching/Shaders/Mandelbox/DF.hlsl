#define GBUFFER_MARCHING_ITERATION       300
#define SHADOWCASTER_MARCHING_ITERATION  64
#define MOTIONVECTORS_MARCHING_ITERATION 64
#define MARCHING_ADAPTIVE_EPS_BASE 0.001

float dMandelFast(float3 p, float scale, int n) {
    float4 q0 = float4 (p, 1.);
    float4 q = q0;

    [loop]
    for ( int i = 0; i < n; i++ ) {
        q.xyz = clamp( q.xyz, -1.0, 1.0 ) * 2.0 - q.xyz;
        q = q * scale / clamp( dot( q.xyz, q.xyz ), 0.3, 1.0 ) + q0;
    }

    return length( q.xyz ) / abs( q.w );
 }

float _MandelScale = 2.9;

 float distanceFunction(float3 p) {
     float s = 20.0;
     p *= s;
     return dMandelFast(p, _MandelScale, 20) / s;
 }

DistanceFunctionSurfaceData getDistanceFunctionSurfaceData(float3 p) {
    DistanceFunctionSurfaceData surface = initDistanceFunctionSurfaceData();
    surface.Position = p;
    surface.Normal   = normal(p, 0.0000001);
    surface.Occlusion = ao(p, surface.Normal, 1.0);
    // Normally BentNormal is the average direction of unoccluded ambient light, but AO * Normal is used instead because of high calculation load.
    surface.BentNormal = surface.Normal * surface.Occlusion;
    surface.Albedo = _BaseColor;
    surface.Smoothness = _Smoothness;
    surface.Metallic = _Metallic;

    float3 positionOS = TransformWorldToObject(surface.Position);
    float distanceFromCenter = length(positionOS);
    surface.Emissive = _EmissiveColor;
    return surface;
}