#define GBUFFER_MARCHING_ITERATION       300
#define SHADOWCASTER_MARCHING_ITERATION  99
#define MOTIONVECTORS_MARCHING_ITERATION 99

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
    float scale = 100.0;
    float3 scale3 = float3(scale, scale*2.0, scale);
    p *= scale3;
    float distanceFromOrigin = length(p);

    float r = 2.75;
    p.xz = rep(p.xz, r);
    p.y = lerp(p.y, rep(p.y, r), step(p.y, 0.0));

    // Spooky animation of the field
    float3 offset = float3(1.9 + sin(_Time.y*2.0 + p.x) * 0.02 + sin(distanceFromOrigin) * 0.2,
                           1.0 + sin(_Time.y*6.0 + p.z) * 0.01 + cos(distanceFromOrigin) * 0.2,
                           1.9 + sin(_Time.y*3.0 + p.z) * 0.02 + sin(distanceFromOrigin) * 0.2);
    float d = dMenger(p, offset, 3.0) / (scale3.y);
    return d * 0.8;
}

DistanceFunctionSurfaceData getDistanceFunctionSurfaceData(float3 p) {
    DistanceFunctionSurfaceData surface = initDistanceFunctionSurfaceData();

    float3 positionWS = GetAbsolutePositionWS(p);
    surface.Position = p;
    surface.Normal   = normal(p, 0.000001);

    // Ambient light is attenuated deeper underground.
    surface.Occlusion = ao(p, surface.Normal, 1.0) * smoothstep(-60.0, -40.0, positionWS.y);
    // Normally BentNormal is the average direction of unoccluded ambient light, but AO * Normal is used instead because of high calculation load.
    surface.BentNormal = surface.Normal * surface.Occlusion;
    surface.Albedo = lerp(float3(1.0, 1.0, 1.0), float3(0.7, 0.1, 0.05), smoothstep(-23.0, -35.0, positionWS.y));
    surface.Smoothness = lerp(0.4, 0.8, smoothstep(-23.0, -35.0, positionWS.y));
    surface.Metallic = 0.0;

    float distanceFromOrigin = length(positionWS);

    // https://github.com/FMS-Cat/type
    float edge = saturate( pow( length( surface.Normal - normal( surface.Position, 0.000008 ) ) * 2.0, 2.0 ) );
    surface.Emissive = float3(20000.0, 2000., 200.) * edge * saturate(sin(_Time.y + distanceFromOrigin)) * smoothstep(-40.0, -60.0, positionWS.y);

    return surface;
}