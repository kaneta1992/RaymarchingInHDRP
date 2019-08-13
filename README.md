![](https://raw.githubusercontent.com/kaneta1992/RaymarchingInHDRP/master/Images/image01.png)

Created for HDRP learning. Changes may occur frequently.

## Getting Started
Clone this repository.

```
git clone git@github.com:kaneta1992/RaymarchingInHDRP.git
```


Go to repository directory and configure Submodule.

```
cd path/to/RaymarchingInHDRP
git submodule init
git submodule update
```

Open the project and have fun!

![](https://raw.githubusercontent.com/kaneta1992/RaymarchingInHDRP/master/Images/image02.png)
## Unity and HDRP Version
- Unity 2019.2.0f1
- HDRP 6.9.0-preview([Just a little custom](https://github.com/kaneta1992/ScriptableRenderPipeline/commit/acabb5b954a1f3c6317f50d1dc8b1f5cee33cab9))

## Supported Passes
The following passes are supported.

- GBuffer Pass
- ShadowCaster Pass
- MotionVectors Pass(Affected by move camera and deformation by model matrix, but formula animation is not suported)
