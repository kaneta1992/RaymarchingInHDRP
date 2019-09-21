#define GBUFFER_MARCHING_ITERATION       99
#define SHADOWCASTER_MARCHING_ITERATION  64
#define MOTIONVECTORS_MARCHING_ITERATION 64
#define MARCHING_ADAPTIVE_EPS_BASE 0.0001

// https://gam0022.net/blog/2019/06/25/unity-raymarching/
float dMenger(float3 z0, float3 offset, float scale) {
    float4 z = float4(z0, 1.0);
    for (int n = 0; n < 2; n++) {
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
    float scale = 6.0;
    p *= scale;
    p.yx = pmod(p.yx, (sin(_Time.y) * 0.5 + 0.5) * 4.0 + 4.0);
    return dMenger(p, float3((sin(_Time.y) * 0.5 + 0.5) + 1.0, (sin(_Time.y*0.7) * 0.5 + 0.5) + 1.0, (sin(_Time.y*0.4) * 0.5 + 0.5) + 1.0), 3.0) / scale;
}

DistanceFunctionSurfaceData getDistanceFunctionSurfaceData(float3 p) {
    DistanceFunctionSurfaceData surface = initDistanceFunctionSurfaceData();
    surface.Position = p;
    surface.Normal   = normal(p, 0.0001);
    surface.Occlusion = ao(p, surface.Normal, 1.0);
    // Normally BentNormal is the average direction of unoccluded ambient light, but AO * Normal is used instead because of high calculation load.
    surface.BentNormal = surface.Normal * surface.Occlusion;
    surface.Albedo = float3(1.0, 1.0, 1.0);
    surface.Smoothness = 0.6;
    surface.Metallic = 0.0;

    float3 positionOS = TransformWorldToObject(surface.Position);
    float distanceFromCenter = length(positionOS);

    // https://github.com/FMS-Cat/type
    float emissive = saturate(sin(-_Time.y * 6.0 + distanceFromCenter * 15.0));
    float edge = saturate( pow( length( surface.Normal - normal( surface.Position, 0.005 ) ) * 2.0, 2.0 ) );
    surface.Emissive = float3(80000.0, 8000., 800.) * edge * saturate(emissive);
    return surface;
}