#define GBUFFER_MARCHING_ITERATION       128
#define SHADOWCASTER_MARCHING_ITERATION  99
#define MOTIONVECTORS_MARCHING_ITERATION 99
#define MARCHING_ADAPTIVE_EPS_BASE 0.0001

// https://gam0022.net/blog/2019/06/25/unity-raymarching/
float dMenger(float3 z0, float3 offset, float scale) {
    float4 z = float4(z0, 1.0);
    for (int n = 0; n < 4; n++) {
        z = abs(z);

        if (z.x < z.y) z.xy = z.yx;
        if (z.x < z.z) z.xz = z.zx;
        if (z.y < z.z) z.yz = z.zy;

        z *= scale;
        z.xyz -= offset * (scale - 1.0);

        if (z.z < -0.5 * offset.z * (scale - 1.0))
            z.z += offset.z * (scale - 1.0);
    }
    return (length(max(abs(z.xyz) - float3(1.0, 1.0, 1.0), 0.0)) - 0.05) / z.w;
}

float distanceFunction(float3 p) {
    float3 pp = p;
    float scale = 20.0;
    p *= float3(scale, scale / 8.0, scale);
    float d = dMenger(p, float3(1.0, 1.0, 1.0), 3.0) / scale;
    return d;
}

DistanceFunctionSurfaceData getDistanceFunctionSurfaceData(float3 p) {
    DistanceFunctionSurfaceData surface = initDistanceFunctionSurfaceData();
    
    float3 positionWS = GetAbsolutePositionWS(p);
    surface.Position = p;
    surface.Normal   = normal(p, 0.00001);
    surface.Occlusion = ao(p, surface.Normal, 1.0) * max(smoothstep(-40.0, -20.0, positionWS.y), 0.3);
    // Normally BentNormal is the average direction of unoccluded ambient light, but AO * Normal is used instead because of high calculation load.
    surface.BentNormal = surface.Normal * surface.Occlusion;
    surface.Albedo = float3(1.0, 1.0, 1.0);
    surface.Smoothness = 0.8;
    surface.Metallic = 0.0;
    return surface;
}