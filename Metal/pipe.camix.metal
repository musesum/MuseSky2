#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

kernel void camix
(
 texture2d<float, access::read>   inTex  [[ texture(0) ]],
 texture2d<float, access::write>  outTex [[ texture(1) ]],
 texture2d<float>                 camTex [[ texture(2) ]],
 constant float&                  mix    [[ buffer(0)  ]], // mix real/fake
 constant float4&                 frame  [[ buffer(1)  ]],
 sampler                          samplr [[ sampler(0) ]],
 uint2 gid [[ thread_position_in_grid ]])
{
    float x = frame[0]; // x offset 0...n
    float y = frame[1]; // y offset 0...n
    float w = frame[2]; // width 0...n
    float h = frame[3]; // height 0...n

    float ww = w - 2*x; // in fill width 0...n
    float wf = ww / w;  // in fill fraction of total 0...1
    float xx = x / ww;  // in offset 0...1

    float hh = h - 2*y; // in height 0...n - 2y
    float hf = hh / h;  // in height factor < 0...1
    float yy = y / hh;  // in y offset 0...1

    float2 norm = float2(gid) / float2(outTex.get_width(),
                                       outTex.get_height());
    float2 camOut = (x > y
                     ? float2(norm.x * wf + xx, norm.y * hf + yy)
                     : float2(norm.x * hf + yy, norm.y * wf + xx));

    float4 camItem = camTex.sample(samplr, camOut);
    float4 inItem = inTex.read(gid);
    float4 mixItem = camItem * mix + inItem * (1 - mix);
    outTex.write(mixItem, gid);
}
