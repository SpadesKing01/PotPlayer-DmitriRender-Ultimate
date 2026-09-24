This is the FineSharp avisynth script by Didée converted to MPC-HC shaders. It was written for madVR (need the 16-bit accuracy in the shader chain), but also works in MPDN.

FineSharp is designed to sharpen clean HD sources. I find it gives an nice clarity boost to clean 720p material when upscaling to 1080p. Works very well together with NNEDI3 luma doubling, if your GPU has the power for that. 
The sharpener makes no attempt to filter noise or source artefacts and will sharpen those too. So denoise/clean your source first if necessary. Probably won't work very well on a really old GPU, the weakest I have tried is a GTX 560 at 1080p 60fps with no problems.


Installation
------------

There are a collection of shaders in the attached zip file, import them all into MPC-HC. How to do that depends on the version of MPC-HC. In the older versions you paste the code into the shader editor, type a name and select ps_3_0. In the recent versions (1.71+ I think) you can save all the shaders in a folder and add them all at once (Play->Shaders->Select Shaders...). Search the web for detailed instructions. 
Unfortunately, the newer versions of MPC-HC don't let you easily toggle the shaders, which isn't very useful for this kind of thing. So I still use an older version, 1.70 (toggle pre-resize with Ctrl-P and post-resize with Ctrl+Alt+P).

When you have imported the shaders they must be selected in the correct order (again check the web for details if you don't know how):

ToYUV
RemoveGrain11
RemoveGrain4
FineSharpA
FineSharpB
FineSharpC
ToRGB

You can select them as "pre-resize shaders" or "post-resize shaders", or both if you wish. 


Controls
--------

In MPC-HC 1.70 and below, toggle pre-resize shaders with Ctrl-P and post-resize shaders with Ctrl+Alt+P
Pre-resize shaders have a stronger effect when upscaling (e.g. showing 720p on 1080p monitor), post-resize shaders are stronger when downscaling. Sharpening in both stages is too strong for my liking, but you could do this if you find the sharpening too delicate - this works best when NNEDI3 luma doubling is enabled.

The script settings are in the FineSharpA and FineSharpC files. They mirror the original script settings exactly. 
The main sharpness control is "sstr" in FineSharpA, use it to control the sharpness more precisely than just toggling pre or post shaders. When you change sstr, you should also change cstr - suggested values are in the script.
I also added an extra feature my own "xrep", which helps reduce artefacts from the second pass of sharpening.


Notes
-----

The shaders are not compatible with the MadVR setting: "run custom pixel shaders in video levels instead of PC levels".

V1.1 - Optimised sorts and medians for a good speed-up. Fixed a bug in the second sharpening pass & tweaked xrep range. Removed a couple of unnecessary files.
v1.0 - First release


-Vit-
