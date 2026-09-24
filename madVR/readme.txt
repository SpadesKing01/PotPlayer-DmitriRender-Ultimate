madVR - DirectShow video renderer
http://madVR.madshi.net
http://madVR.bugs.madshi.net


======================================================================


INSTALL
----------------------------------------------------------------------
 (1) Unzip "madVR.zip" and copy the folder to a suitable place (e.g.
     Program Files).

 (2) Run "install.bat". (with admin rights!)

 (3) Do not delete the madVR folder after installation.


UNINSTALL
----------------------------------------------------------------------
 Run "uninstall.bat". (with admin rights!)


USAGE
----------------------------------------------------------------------
 Use MPC HC or any other media player which supports madVR. Select
 madVR as the preferred renderer in the media player's settings.


REQUIREMENTS
----------------------------------------------------------------------
 You will need a graphics card with full Direct3D9 hardware support.


CHANGES
----------------------------------------------------------------------
 See "changelog.txt".


BUG TRACKER
----------------------------------------------------------------------
 http://madVR.bugs.madshi.net


LICENSE
----------------------------------------------------------------------
 See "license.txt".


CONTRIBUTIONS & THANKS
----------------------------------------------------------------------
 Thanks to Nicolas Robidoux for his help during madVR scaling
 development, and for introducing the concept of doing linear 1-pass
 2D Jinc resampling.

 Thanks to tritical for creating NNEDI3 and for allowing me to use
 the GPL weights in madVR:
 http://forum.doom9.org/showthread.php?t=147695

 Thanks to SEt for creating a well optimized OpenCL NNEDI3 kernel,
 and for making it available under LGPL, so I could use it in madVR:
 http://forum.doom9.org/showthread.php?t=169766

 Thanks to Shiandow for his dithering ideas (e.g. gamma correction),
 and for his various HLSL algorithms, including NEDI, Super(Chroma)Res,
 Bilateral chroma upscaling and SSIM downscaling:
 https://github.com/Shiandow/RenderScripts

 Thanks to Didée for his FineSharp AviSynth script, and to -Vit- for
 porting it to HLSL:
 http://forum.doom9.org/showthread.php?p=1569035
 http://forum.doom9.org/showthread.php?t=171346

 Thanks to Didée once more, for many good ideas in various of his
 AviSynth scripts, which I've partially used for the "sharpen edges",
 "crispen edges" and "enhance detail" algorithms.

 Thanks to CeeJay.dk for porting the LumaSharpen script to a video
 player compatible format:
 http://forum.doom9.org/showthread.php?t=170357

 Thanks to Hyllian for his super-xbr scaling algorithm, and for
 generously changing the license to MIT:
 https://github.com/libretro/common-shaders/tree/master/xbr/super-xbr

 Thanks to bacondither for his AdaptiveSharpen algorithm, and for
 making it available under BSD license:
 http://forum.doom9.org/showthread.php?t=172131

 Thanks to igv for improving AdaptiveSharpen's image quality:
 https://gist.github.com/igv

 Thanks to feisty2 for writing the Chroma Reconstructor, and for
 helping me porting it to madVR:
 http://forum.doom9.org/showthread.php?t=173005

 Thanks to hannes69 for his help with developing madVR's "custom
 mode" feature.

 Thanks to Florian Höch for developing DisplayCAL, for sharing
 his improved tone mapping color handling algorithm, and for
 his help in improving madVR's pixel shader tone mapping:
 https://displaycal.net/
