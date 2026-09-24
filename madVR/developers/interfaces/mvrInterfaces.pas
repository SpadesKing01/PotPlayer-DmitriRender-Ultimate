// ***************************************************************
//  mvrInterfaces.pas         version: 1.0.9  ·  date: 2016-01-23
//  -------------------------------------------------------------
//  various interfaces exported by madVR
//  -------------------------------------------------------------
//  Copyright (C) 2011 - 2016 www.madshi.net, BSD license
// ***************************************************************

// 2016-01-23 1.0.9 added EC_VIDEO_SIZE_CHANGED "lParam" values
// 2015-06-21 1.0.8 added IMadVRCommand
// 2014-01-18 1.0.7 added IMadVRSettings2
// 2013-06-04 1.0.6 added IMadVRInfo
// 2013-01-23 1.0.5 added IMadVRSubclassReplacement
// 2012-11-18 1.0.4 added IMadVRExternalPixelShaders
// 2012-10-07 1.0.3 added IMadVRExclusiveModeCallback
// 2011-08-03 1.0.2 added IMadVRExclusiveModeControl
// 2011-07-17 1.0.1 added IMadVRRefreshRateInfo
// 2011-06-25 1.0.0 initial release

unit mvrInterfaces;

interface

uses Windows, Direct3D9;

// ---------------------------------------------------------------------------
// IMadVR
// ---------------------------------------------------------------------------

// use this CLSID to create a madVR instance

const CLSID_madVR : TGuid = '{E1A8B82A-32CE-4B0D-BE0D-AA68C772E423}';

// ---------------------------------------------------------------------------
// video size/position setup
// ---------------------------------------------------------------------------

// madVR supports "IVideoWindow" and "IBasicVideo". Both need to be used in
// a specific way to achieve the best results. You should always use
// IVideoWindow::SetWindowPosition() to make madVR cover the whole rendering
// client area of your media player's window.

// Some media players offer different zoom modes. Here's what madVR supports:
// 1) touchInside:
//    The video is zoomed, maintaining the correct AR (aspect ratio), in such
//    a way that the video is displayed as large as possible, without losing
//    any image content. There may be black bars, either left/right, or
//    top/bottom.
// 2) touchOutside:
//    The video is zoomed, maintaining the correct AR, in such a way that the
//    video is displayed as large as possible, without any black bars. Some
//    image content may be cut off.
// 3) stretch:
//    The video is zoomed and stretched to perfectly fill the rendering
//    client area. The AR might be distorted, but there will be no black bars.
// 4) 100% (or 50% or 200% or some other percent number):
//    The video is displayed at 100% (or 50% or ...) of the original size,
//    maintaining the correct AR.

// Some media players offers different X/Y video alignments/positions. Here's
// what madVR supports:
// 1) left/top:
//    The video is positioned left/top aligned.
// 2) center:
//    The video is rendered in centered positioned.
// 3) right/bottom:
//    The video is positioned right/bottom aligned.

// In addition to these zoom and alignment modes, some media players allow
// further fine tuning the zoom/position by increasing/decreasing the zoom
// factor, or by offsetting the image position. madVR supports that as well,
// of course.

// When using madVR, you have 3 options to setup zoom modes and positions:
// a) You can calculate a specific target rect for the video yourself and
//    tell madVR about it by calling IBasicVideo::SetDestinationPosition().
// b) You can use the "IMadVRCommand" interface (described in detail below)
//    to tell madVR which zoom & alignment modes to use.
// c) Don't do anything. In that case madVR will default to "touchInside"
//    and "center" zoom/alignment modes.

// In case of a) madVR will actually try to "understand" your target rect
// and map it internally to one of the supported zoom modes. This is done
// because madVR has complex options for the user to decide how zooming
// should be performed exactly. In order to process these options, madVR
// may have to dynamically adjust the target rect to things like screen
// masking, or detected hard coded subtitles in the black bars.

// Usually madVR's interpretation of your target rect works just fine. But
// there are situations when madVR has no way to know which zoom mode is really
// active in the media player. E.g. playing a 720p movie in a 720p window
// would match any of the available zoom or alignment modes. Because of that
// it is usually recommended to use options b) or c) described above.
// If you set a specific zoom mode (option b), madVR will ignore any calls
// to IBasicVideo::SetDestinationPosition().

// ---------------------------------------------------------------------------
// IMadVROsdServices
// ---------------------------------------------------------------------------

// this interface allows you to draw your own graphical OSD
// your OSD will work in both windowed + exclusive mode
// there are 2 different ways to draw your OSD:

// (1) using bitmaps
// you can create multiple OSD elements
// each OSD element gets a name, a bitmap and a position
// the bitmap must be 24bit or 32bit RGB(A)
// for transparency you can use a color key or an 8bit alpha channel

// (2) using render callbacks
// you can provide madVR with callbacks
// these callbacks are then called during rendering
// one callback will be called the rendering target was cleared
// another callback will be called after rendering was fully completed
// in your callbacks you can modify the render target any way you like

// ---------------------------------------------------------------------------

// when using the (1) bitmaps method, you can register a mouse callback
// this callback will be called whenever a mouse event occurs
// mouse pos (0, 0) is the left top corner of the OSD bitmap element
// return "true" if your callback has handled the mouse message and
// if you want the mouse message to be "eaten" (instead of passed on)
type
  OSDMOUSECALLBACK = procedure (name: PAnsiChar; context: pointer; msg: UINT; wParam: WPARAM; posX, posY: integer); stdcall;

// return values for IOsdRenderCallback::ClearBackground/RenderOsd callbacks
const CALLBACK_EMPTY             = 4306;   // the render callback didn't do anything at all
const CALLBACK_INFO_DISPLAY      = 0;      // info display, doesn't need low latency
const CALLBACK_USER_INTERFACE    = 77001;  // user interface, switches madVR into low latency mode

// when using the (2) render callbacks method, you need to provide
// madVR with an instance of the IOsdRenderCallback interface
// it contains three callbacks you have to provide
type
  IOsdRenderCallback = interface ['{57FBF6DC-3E5F-4641-935A-CB62F00C9958}']
    // "SetDevice" is called when you register the callbacks
    // it provides you with the IDirect3D9 device object used by madVR
    // when SetDevice is called with a "NULL" D3D device, you
    // *must* release all D3D resources you eventually allocated
    function SetDevice(device: IUnknown) : HRESULT; stdcall;

    // "ClearBackground" is called after madVR cleared the render target
    // "RenderOsd" is called after madVR is fully done with rendering
    // fullOutputRect  = for fullscreen drawing, this is the rect you want to stay in (left/top can be non-zero!)
    // activeVideoRect = active video rendering rect inside of fullOutputRect
    // background area = the part of fullOutputRect which isn't covered by activeVideoRect
    // possible return values: CALLBACK_EMPTY etc, see definitions above
    function ClearBackground(name: PAnsiChar; frameStart: int64; var fullOutputRect, activeVideoRect: TRect) : HRESULT; stdcall;
    function RenderOsd      (name: PAnsiChar; frameStart: int64; var fullOutputRect, activeVideoRect: TRect) : HRESULT; stdcall;
  end;

// flags for IMadVROsdServices.OsdSetBitmap
const BITMAP_STRETCH_TO_OUTPUT = 1;    // stretch OSD bitmap to video/output rect
const BITMAP_INFO_DISPLAY      = 2;    // info display, doesn't need low latency
const BITMAP_USER_INTERFACE    = 4;    // user interface, switches madVR into low latency mode
const BITMAP_MASKING_AWARE     = 8;    // caller is aware of screen masking, bitmaps are positioned properly inside of "fullOutputRect"
const BITMAP_HDR_PQ            = $10;  // the bitmap has PQ transfer function (instead of gamma)
const BITMAP_2020_PRIMARIES    = $20;  // the bitmap has BT.2020 primaries    (instead of BT.709)

type
  // this is the main interface which madVR provides to you
  IMadVROsdServices = interface ['{3AE03A88-F613-4BBA-AD3E-EE236976BF9A}']
    // this API provides the (1) bitmap based method
    function OsdSetBitmap(
      name                   : PAnsiChar;                 // name of the OSD element, e.g. "YourMediaPlayer.SeekBar"
      leftEye                : HBITMAP          = 0;      // OSD bitmap, should be 24bit or 32bit, NULL deletes the OSD element
      rightEye               : HBITMAP          = 0;      // specify when your OSD is 3D, otherwise set to NULL
      colorKey               : COLORREF         = 0;      // transparency color key, set to 0 if your bitmap has an 8bit alpha channel
      posX                   : integer          = 0;      // where to draw the OSD element?
      posY                   : integer          = 0;      //
      posRelativeToVideoRect : boolean          = false;  // draw relative to TRUE: the active video rect; FALSE: the full output rect
      zOrder                 : integer          = 0;      // high zOrder OSD elements are drawn on top of those with smaller zOrder values
      duration               : dword            = 0;      // how many milliseconds shall the OSD element be shown (0 = infinite)?
      flags                  : dword            = 0;      // see definitions above
      callback               : OSDMOUSECALLBACK = nil;    // optional callback for mouse events
      callbackContext        : pointer          = nil;    // this context is passed to the callback
      reserved               : pointer          = nil     // undefined - set to NULL
    ) : HRESULT; stdcall;

    // this API allows you to ask the current video rectangles
    function OsdGetVideoRects(
      out fullOutputRect     : TRect;                     // for fullscreen drawing, this is the rect you want to stay in (left/top can be non-zero!)
      out activeVideoRect    : TRect                      // active video rendering rect inside of fullOutputRect
    ) : HRESULT; stdcall;

    // this API provides the (2) render callback based method
    function OsdSetRenderCallback(
      name                   : PAnsiChar;                 // name of the OSD callback, e.g. "YourMediaPlayer.OsdCallbacks"
      callback               : IOsdRenderCallback;        // OSD callback interface, set to NULL to unregister the callback
      reserved               : pointer = nil              // undefined - set to NULL
    ) : HRESULT; stdcall;

    // this API is obselete, calling it has no effect
    function OsdRedrawFrame : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRTextOsd
// ---------------------------------------------------------------------------

// This interface allows you to draw simple text messages.
// madVR uses it internally, too, for showing various messages to the user.
// The messages are shown in the top left corner of the video rendering window.
// The messages work in both windowed and fullscreen exclusive mode.
// There can always be only one message active at the same time, so basically
// the messages are overwriting each other.

type
  IMadVRTextOsd = interface ['{ABA34FDA-DD22-4E00-9AB4-4ABF927D0B0C}']
    function OsdDisplayMessage(text: PWideChar; milliseconds: dword) : HRESULT; stdcall;
    function OsdClearMessage : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRSubclassReplacement
// ---------------------------------------------------------------------------

// Normally madVR subclasses some parent of the madVR rendering window.
// If your media player gets into stability issues because of that, you can
// disable madVR's subclassing by using this interface. You should then
// manually forward the messages from your own WindowProc to madVR by calling
// this interface's "ParentWindowProc" method.
// If "ParentWindowProc" returns "TRUE", you should consider the message
// handled by madVR and *not* pass it on to the original WindowProc. If
// "ParentWindowProc" returns "FALSE", process the message as usual.
// When using the normal subclassing solution, madVR selects the parent window
// to subclass by using the following code:
// {
//   HWND parentWindow = madVRWindow;
//   while ((GetParent(parentWindow)) && (GetParent(parentWindow) == GetAncestor(parentWindow, GA_PARENT)))
//     parentWindow = GetParent(parentWindow);
// }
// If you use this interface, send the messages to madVR from the same window
// that madVR would otherwise have subclassed.

type
  IMadVRSubclassReplacement = interface ['{9B517604-2D86-4FA2-A20C-ECF88301B010}']
    function DisableSubclassReplacement() : HRESULT; stdcall;
    function ParentWindowProc(hwnd: HWND; uMsg: dword; var wParam, lParam: NativeUInt; var result: NativeUInt) : bool; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRExclusiveModeCallback
// ---------------------------------------------------------------------------

// allows you to be notified when exclusive mode is entered/left

const
  ExclusiveModeIsAboutToBeEntered = 1;
  ExclusiveModeWasJustEntered     = 2;
  ExclusiveModeIsAboutToBeLeft    = 3;
  ExclusiveModeWasJustLeft        = 4;

type
  TExclusiveModeCallback = procedure (context: pointer; event: integer); stdcall;

type
  IMadVRExclusiveModeCallback = interface ['{51CA9252-ACC5-4EC5-A02E-0F9F8C42B536}']
    function Register(exclusiveModeCallback: TExclusiveModeCallback; context: pointer) : HRESULT; stdcall;
    function Unregister(exclusiveModeCallback: TExclusiveModeCallback; context: pointer) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRExternalPixelShaders
// ---------------------------------------------------------------------------

// this interface allows you to activate external HLSL D3D9 pixel shaders

const ShaderStage_PreScale = 0;
      ShaderStage_PostScale = 1;

type
  IMadVRExternalPixelShaders = interface ['{B6A6D5D4-9637-4C7D-AAAE-BC0B36F5E433}']
    function ClearPixelShaders(stage: integer) : HRESULT; stdcall;
    function AddPixelShader(sourceCode, compileProfile: PAnsiChar; stage: integer; reserved: pointer = nil) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRInfo
// ---------------------------------------------------------------------------

// this interface allows you to get all kinds of information from madVR

type
  IMadVRInfo = interface ['{8FAB7F31-06EF-444C-A798-10314E185532}']
    // The memory for strings and binary data is allocated by the callee
    // by using LocalAlloc. It is the caller's responsibility to release the
    // memory by calling LocalFree.
    // Field names and LPWSTR values should be read case insensitive.
    function GetBool     (field: PAnsiChar; out value: boolean) : HRESULT; stdcall;
    function GetInt      (field: PAnsiChar; out value: integer) : HRESULT; stdcall;
    function GetSize     (field: PAnsiChar; out value: TSize  ) : HRESULT; stdcall;
    function GetRect     (field: PAnsiChar; out value: TRect  ) : HRESULT; stdcall;
    function GetUlonglong(field: PAnsiChar; out value: int64  ) : HRESULT; stdcall;
    function GetDouble   (field: PAnsiChar; out value: double ) : HRESULT; stdcall;
    function GetString   (field: PAnsiChar; out value: PWideChar; out chars: integer) : HRESULT; stdcall;
    function GetBin      (field: PAnsiChar; out value: pointer;   out size : integer) : HRESULT; stdcall;
  end;

// available info fields:
// ----------------------
// version,                 string,    madVR version number
// originalVideoSize,       size,      size of the video before scaling and AR adjustments
// arAdjustedVideoSize,     size,      size of the video after AR adjustments
// videoCropRect,           rect,      crops "originalVideoSize" down, e.g. because of detected black bars
// videoOutputRect,         rect,      final pos/size of the video after all scaling operations
// croppedVideoOutputRect,  rect,      final pos/size of the "videoCropRect", after all scaling operations
// subtitleTargetRect,      rect,      consumer wish for where to place the subtitles
// fullscreenRect,          rect,      for fullscreen drawing, this is the rect you want to stay in (left/top can be non-zero!)
// rotation,                int,       current rotation of the video in degrees (0, 90, 180 or 270)
// frameRate,               ulonglong, frame rate of the video after deinterlacing (REFERENCE_TIME)
// refreshRate,             double,    display refresh rate (0, if unknown)
// displayModeSize,         size,      display mode width/height
// yuvMatrix,               string,    RGB Video: "None" (fullrange); YCbCr Video: "Levels.Matrix", Levels: TV|PC, Matrix: 601|709|240M|FCC|2020
// hdrOutput,               bool,      does madVR send the video in HDR/PQ transfer function to the display?
// exclusiveModeActive,     bool,      is madVR currently in exclusive mode?
// madVRSeekbarEnabled,     bool,      is the madVR exclusive mode seek bar currently enabled?
// dxvaDecodingActive,      bool,      is DXVA2 decoding      being used at the moment?
// dxvaDeinterlacingActive, bool,      is DXVA2 deinterlacing being used at the moment?
// dxvaScalingActive,       bool,      is DXVA2 scaling       being used at the moment?
// ivtcActive,              bool,      is madVR's IVTC algorithm active at the moment?
// osdLatency,              int,       how much milliseconds will pass for an OSD change to become visible?
// seekbarRect,             rect,      where exactly would (or does) madVR draw its seekbar?

// ---------------------------------------------------------------------------
// IMadVRCommand
// ---------------------------------------------------------------------------

// This interface allows you to give commands to madVR. These commands only
// affect the current madVR instance. They don't change permanent settings.

type
  IMadVRCommand = interface ['{5E9599D1-C5DB-4A84-98A9-09BC5F8F1B79}']
    // Command names and LPWSTR values are treated case insensitive.
    function SendCommand         (command: PAnsiChar) : HRESULT; stdcall;
    function SendCommandBool     (command: PAnsiChar; parameter: boolean  ) : HRESULT; stdcall;
    function SendCommandInt      (command: PAnsiChar; parameter: integer  ) : HRESULT; stdcall;
    function SendCommandSize     (command: PAnsiChar; parameter: TSize    ) : HRESULT; stdcall;
    function SendCommandRect     (command: PAnsiChar; parameter: TRect    ) : HRESULT; stdcall;
    function SendCommandUlonglong(command: PAnsiChar; parameter: int64    ) : HRESULT; stdcall;
    function SendCommandDouble   (command: PAnsiChar; parameter: double   ) : HRESULT; stdcall;
    function SendCommandString   (command: PAnsiChar; parameter: PWideChar) : HRESULT; stdcall;
    function SendCommandBin      (command: PAnsiChar; parameter: pointer;
                                                      size     : integer  ) : HRESULT; stdcall;
  end;

// available commands:
// -------------------
// disableSeekbar,          bool,      turn madVR's automatic exclusive mode on/off
// disableExclusiveMode,    bool,      turn madVR's automatic exclusive mode on/off
// keyPress                 int,       interpret as "BYTE keyPress[4]"; keyPress[0] = key code (e.g. VK_F1); keyPress[1-3] = BOOLEAN "shift/ctrl/menu" state
// setZoomMode,             LPWSTR,    video target size: "autoDetect|touchInside|touchOutside|stretch|100%|10%|20%|25%|30%|33%|40%|50%|60%|66%|70%|75%|80%|90%|110%|120%|125%|130%|140%|150%|160%|170%|175%|180%|190%|200%|225%|250%|300%|350%|400%|450%|500%|600%|700%|800%"
// setZoomFactorX,          double,    additional X zoom factor (applied after zoom mode), default/neutral = 1.0
// setZoomFactorY,          double,    additional Y zoom factor (applied after zoom mode), default/neutral = 1.0
// setZoomAlignX,           LPWSTR,    video X pos alignment: left|center|right
// setZoomAlignY,           LPWSTR,    video Y pos alignment: top|center|bottom
// setZoomOffsetX,          double,    additional X pos offset in percent, default/neutral = 0.0
// setZoomOffsetY,          double,    additional Y pos offset in percent, default/neutral = 0.0
// setArOverride,           double,    aspect ratio override (before cropping), default/neutral = 0.0
// rotate,                  int,       rotates the video by 90, 180 or 270 degrees (0 = no rotation)
// redraw,                             forces madVR to redraw the current frame (in paused mode)
// restoreDisplayModeNow,              makes madVR immediately restore the original display mode

// ---------------------------------------------------------------------------
// IMadVRSettings
// ---------------------------------------------------------------------------

// this interface allows you to read and write madVR settings

// For each folder and value there exists both a short ID and a long
// description. The short ID will never change. The long description may be
// modified in a future version. So it's preferable to use the ID, but you can
// also address settings by using the clear text description.

// The "path" parameter can simply be set to the ID or to the description of
// the setting value. Alternatively you can use a partial or full path to the
// setting value. E.g. the following calls will all return the same value:
// (1) GetBoolean('dontDither', boolVal);
// (2) GetBoolean('don''t use dithering', boolVal);
// (3) GetBoolean('dithering\dontDither', boolVal);
// (4) GetBoolean('rendering\dithering\dontDither', boolVal);

// Using the full path can make sense if you want to access a specific profile.
// If you don't specify a path, you automatically access the currently active
// profile.

type
  IMadVRSettings = interface ['{6F8A566C-4E19-439E-8F07-20E46ED06DEE}']
    // returns the revision number of the settings record
    // the revision number is increased by 1 every time a setting changes
    function SettingsGetRevision(out revision: int64) : BOOL; stdcall;

    // export the whole settings record to a binary data buffer
    // the buffer is allocated by mvrSettings_Export by using LocalAlloc
    // it's the caller's responsibility to free the buffer again by using LocalFree
    function SettingsExport(out buf: pointer; out size: integer) : BOOL; stdcall;
    // import the settings from a binary data buffer
    function SettingsImport(buf: pointer; size: integer) : BOOL; stdcall;

    // modify a specific value
    function SettingsSetString (path: PWideChar; value: PWideChar) : BOOL; stdcall;
    function SettingsSetInteger(path: PWideChar; value: integer  ) : BOOL; stdcall;
    function SettingsSetBoolean(path: PWideChar; value: BOOL     ) : BOOL; stdcall;

    // The buffer for SettingsGetString must be provided by the caller and
    // bufLenInChars set to the buffer's length (please note: 1 char -> 2 bytes).
    // If the buffer is too small, the API fails and GetLastError returns
    // ERROR_MORE_DATA. On return, bufLenInChars is set to the required buffer size.
    // The buffer for SettingsGetBinary is allocated by SettingsGetBinary.
    // The caller is responsible for freeing it by using LocalAlloc().
    function SettingsGetString (path: PWideChar;     value: PWideChar; var bufLenInChars: integer) : BOOL; stdcall;
    function SettingsGetInteger(path: PWideChar; out value: integer) : BOOL; stdcall;
    function SettingsGetBoolean(path: PWideChar; out value: BOOL   ) : BOOL; stdcall;
    function SettingsGetBinary (path: PWideChar;     value: pointer;   var bufLenInBytes: integer) : BOOL; stdcall;
  end;

  IMadVRSettings2 = interface (IMadVRSettings) ['{1C3E03D6-F422-4D31-9424-75936F663BF7}']
    // Enumerate the available settings stuff in the specified path.
    // Simply loop from enumIndex 0 to infinite, until the enumeration returns FALSE.
    // When enumeration is completed GetLastError returns ERROR_NO_MORE_ITEMS.
    // The buffers must be provided by the caller and ...LenInChars set to the
    // buffer's length (please note: 1 char -> 2 bytes). If the buffer is too small,
    // the API fails and GetLastError returns ERROR_MORE_DATA. On return,
    // ...LenInChars is set to the required buffer size.
    function SettingsEnumFolders      (path: PWideChar; enumIndex: integer; id, name, type_: PWideChar; var idLenInChars, nameLenInChars, typeLenInChars: integer) : BOOL; stdcall;
    function SettingsEnumValues       (path: PWideChar; enumIndex: integer; id, name, type_: PWideChar; var idLenInChars, nameLenInChars, typeLenInChars: integer) : BOOL; stdcall;
    function SettingsEnumProfileGroups(path: PWideChar; enumIndex: integer;     name:        PWideChar; var               nameLenInChars:                 integer) : BOOL; stdcall;
    function SettingsEnumProfiles     (path: PWideChar; enumIndex: integer;     name:        PWideChar; var               nameLenInChars:                 integer) : BOOL; stdcall;
    
    // Creates/deletes a profile group in the specified path.
    // Deleting a profile group works only if there's only one profile left in the group.
    // Example:
    // SettingsCreateProfileGroup('scalingParent', 'imageDoubling|lumaUp', 'upscaling profiles', 'SD 24fps');
    // SettingsDeleteProfileGroup('scalingParent\upscaling profiles');
    function SettingsCreateProfileGroup(path, settingsPageList, profileGroupName, firstProfileName: PWideChar) : BOOL; stdcall;
    function SettingsDeleteProfileGroup(path: PWideChar) : BOOL; stdcall;

    // SettingsAddProfile adds a new profile, using default parameters for all values.
    // SettingsDuplicateProfile duplicates/copies a profile with all parameters.
    // Deleting a profile works only if it isn't the only profile left in the group.
    // Example:
    // SettingsAddProfile('scalingParent\upscaling profiles', 'SD 60fps');
    // SettingsDuplicateProfile('scalingParent\upscaling profiles', 'SD 60fps', 'HD 24fps');
    // SettingsDeleteProfile('scalingParent\upscaling profiles', 'SD 60fps');
    function SettingsAddProfile      (path,                      newProfileName: PWideChar) : BOOL; stdcall;
    function SettingsDuplicateProfile(path, originalProfileName, newProfileName: PWideChar) : BOOL; stdcall;
    function SettingsDeleteProfile   (path,         profileName:                 PWideChar) : BOOL; stdcall;

    // SettingsActivateProfile activates the specified profile.
    // It also disables automatic (rule based) profile selection.
    // SettingsAutoselectProfile allows you to reactivate it.
    // Example:
    // if SettingsIsProfileActive('scalingParent\upscaling profiles', 'SD 24fps') then
    // begin
    //   SettingsActivateProfile('scalingParent\upscaling profiles', 'SD 60fps');
    //   [...]
    //   SettingsAutoselectProfile('scalingParent\upscaling profiles');
    function SettingsIsProfileActive(path, profileName: PWideChar) : BOOL; stdcall;
    function SettingsActivateProfile(path, profileName: PWideChar) : BOOL; stdcall;
    function SettingsIsProfileAutoselected(path: PWideChar) : BOOL; stdcall;
    function SettingsAutoselectProfile(path: PWideChar) : BOOL; stdcall;
  end;

// available settings: id, name, type, valid values
// ------------------------------------------------
// devices, devices
//   %monitorId%, %monitorName%
//     %id%, identification
//       edid,                      edid,                                                               binary
//       monitorName,               monitor name,                                                       string
//       deviceId,                  device id,                                                          string
//       outputDevice,              output device,                                                      string
//     properties, properties
//       levels,                    levels,                                                             string,  TV Levels|PC Levels|Custom
//       black,                     black,                                                              integer, 0..48
//       white,                     white,                                                              integer, 200..255
//       displayBitdepth,           native display bitdepth,                                            integer, 3..10
//     calibration, calibration
//       calibrate,                 calibrate display,                                                  string,  disable calibration controls for this display|this display is already calibrated|calibrate this display by using yCMS|calibrate this display by using an external 3dlut file
//       disableGpuGammaRamps,      disable GPU gamma ramps,                                            boolean
//       external3dlutFile709,      external 3dlut file (BT.709),                                       string
//       external3dlutFileNtsc,     external 3dlut file (SMPTE C),                                      string
//       external3dlutFilePal,      external 3dlut file (EBU/PAL),                                      string
//       external3dlutFile2020,     external 3dlut file (BT.2020),                                      string
//       external3dlutFileDci,      external 3dlut file (DCI-P3),                                       string
//       gamutMeasurements,         gamut measurements,                                                 string
//       gammaMeasurements,         gamma measurements,                                                 string
//       displayPrimaries,          display primaries,                                                  string,  BT.709 (HD)|BT.601 (SD)|PAL|something else
//       displayGammaCurve,         display gamma curve,                                                string,  pure power curve|BT.709/601 curve|something else
//       displayGammaValue,         display gamma value,                                                string,  1.80|1.85|1.90|1.95|2.00|2.05|2.10|2.15|2.20|2.25|2.30|2.35|2.40|2.45|2.50|2.55|2.60|2.65|2.70|2.75|2.80
//     displayModes, display modes
//       enableDisplayModeChanger,  switch to matching display mode...,                                 boolean
//       changeDisplayModeOnPlay,   ... when playback starts,                                           boolean
//       restoreDisplayMode,        restore original display mode...,                                   boolean
//       restoreDisplayModeOnClose, ... when media player is closed,                                    boolean
//       slowdown,                  treat 25p movies as 24p  (requires Reclock),                        boolean
//       displayModesData,          display modes data,                                                 binary
//     colorGamma, color & gamma
//       brightness,                brightness,                                                         integer, -100..+100
//       contrast,                  contrast,                                                           integer, -100..+100
//       saturation,                saturation,                                                         integer, -100..+100
//       hue,                       hue,                                                                integer, -180..+180
//       enableGammaProcessing,     enable gamma processing,                                            boolean
//       currentGammaCurve,         current gamma curve,                                                string,  pure power curve|BT.709/601 curve
//       currentGammaValue,         current gamma value,                                                string,  1.80|1.85|1.90|1.95|2.00|2.05|2.10|2.15|2.20|2.25|2.30|2.35|2.40|2.45|2.50|2.55|2.60|2.65|2.70|2.75|2.80
// processing, processing
//   deinterlacing, deinterlacing
//     autoActivateDeinterlacing,   automatically activate deinterlacing when needed,                   boolean
//     ifInDoubtDeinterlace,        if in doubt, activate deinterlacing,                                boolean
//     contentType,                 source type,                                                        string,  auto|film|video
//     scanPartialFrame,            only look at pixels in the frame center,                            boolean
//     deinterlaceThread,           perform deinterlacing in separate thread,                           boolean
//   artifactRemoval, artifact removal
//     debandActive,                reduce banding artifacts,                                           boolean
//     debandLevel,                 default debanding strength,                                         integer, 0..2
//     debandFadeLevel,             strength during fade in/out,                                        integer, 0..2
// scalingParent, scaling algorithms
//   chromaUp, chroma upscaling
//     chromaUp,                    chroma upsampling,                                                  string,  Nearest Neighbor|Bilinear|Mitchell-Netravali|Catmull-Rom|Bicubic50|Bicubic60|Bicubic75|Bicubic100|SoftCubic50|SoftCubic60|SoftCubic70|SoftCubic80|SoftCubic100|Lanczos3|Lanczos4|Lanczos8|Spline36|Spline64|Jinc3|Jinc4|Jinc8|Nnedi16|Nnedi32|Nnedi64|Nnedi128|Nnedi256
//     chromaAntiRinging,           activate anti-ringing filter for chroma upsampling,                 boolean
//   imageDoubling, image doubling
//     nnediDLEnable,               use NNEDI3 to double Luma resolution,                               boolean
//     nnediDCEnable,               use NNEDI3 to double Chroma resolution,                             boolean
//     nnediQLEnable,               use NNEDI3 to quadruple Luma resolution,                            boolean
//     nnediQCEnable,               use NNEDI3 to quadruple Chroma resolution,                          boolean
//     nnediDLScalingFactor,        when to use NNEDI3 to double Luma resolution,                       string,  1.2x|1.5x|2.0x|always
//     nnediDCScalingFactor,        when to use NNEDI3 to double Chroma resolution,                     string,  1.2x|1.5x|2.0x|always
//     nnediQLScalingFactor,        when to use NNEDI3 to quadruple Luma resolution,                    string,  1.2x|1.5x|2.0x|always
//     nnediQCScalingFactor,        when to use NNEDI3 to quadruple Chroma resolution,                  string,  1.2x|1.5x|2.0x|always
//     nnediDLQuality,              NNEDI3 double Luma quality,                                         integer, 0..4
//     nnediDLQuality,              NNEDI3 double Chroma quality,                                       integer, 0..4
//     nnediDLQuality,              NNEDI3 quadruple Luma quality,                                      integer, 0..4
//     nnediDLQuality,              NNEDI3 quadruple Chroma quality,                                    integer, 0..4
//     amdInteropHack,              use alternative interop hack (not recommended, AMD only),           boolean
//   lumaUp, image upscaling
//     lumaUp,                      image upscaling,                                                    string,  Nearest Neighbor|Bilinear|Dxva|Mitchell-Netravali|Catmull-Rom|Bicubic50|Bicubic60|Bicubic75|Bicubic100|SoftCubic50|SoftCubic60|SoftCubic70|SoftCubic80|SoftCubic100|Lanczos3|Lanczos4|Lanczos8|Spline36|Spline64|Jinc3|Jinc4|Jinc8
//     lumaUpAntiRinging,           activate anti-ringing filter for luma upsampling,                   boolean
//     lumaUpLinear,                upscale luma in linear light,                                       boolean
//   lumaDown, image downscaling
//     lumaDown,                    image downscaling,                                                  string,  Nearest Neighbor|Bilinear|Dxva|Mitchell-Netravali|Catmull-Rom|Bicubic50|Bicubic60|Bicubic75|Bicubic100|SoftCubic50|SoftCubic60|SoftCubic70|SoftCubic80|SoftCubic100|Lanczos3|Lanczos4|Lanczos8|Spline36|Spline64
//     lumaDownAntiRinging,         activate anti-ringing filter for luma downsampling,                 boolean
//     lumaDownLinear,              downscale luma in linear light,                                     boolean
// rendering, rendering
//   basicRendering, general settings
//     uploadInRenderThread,        upload frames in render thread,                                     boolean
//     delayPlaybackStart2,         delay playback start until render queue is full,                    boolean
//     delaySeek,                   delay playback start after seeking, too,                            boolean
//     enableOverlay,               enable windowed overlay (Windows 7 and newer),                      boolean
//     enableExclusive,             enable automatic fullscreen exclusive mode,                         boolean
//     disableAero,                 disable desktop composition (Vista and newer),                      boolean
//     disableAeroCfg,              disable desktop composition configuration,                          string,  during exclusive - windowed mode switch|while madVR is in exclusive mode|while media player is in fullscreen mode|always
//     separateDevice,              use a separate device for presentation (Vista and newer),           boolean
//     useD3d11,                    use D3D11 for presentation,                                         boolean
//     dxvaDevice,                  use separate device for DXVA processing (Vista and newer),          boolean
//     cpuQueueSize,                CPU queue size,                                                     integer, 4..32
//     gpuQueueSize,                GPU queue size,                                                     integer, 4..24
//   windowedTweaks, windowed mode settings
//     backbufferCount,             no of backbuffers,                                                  integer, 1..8
//     flushAfterRenderSteps,       after render steps,                                                 string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//     flushAfterLastStep,          after last step,                                                    string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//     flushAfterBackbuffer,        after backbuffer,                                                   string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//     flushAfterPresent,           after present,                                                      string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//     oldWindowedPath,             use old windowed rendering path,                                    boolean
//     preRenderFramesWindowed,     no of pre-presented frames,                                         integer, 1..16
//   exclusiveSettings, exclusive mode settings
//     enableSeekbar,               show seek bar,                                                      boolean
//     exclusiveDelay,              delay switch to exclusive mode by 3 seconds,                        boolean
//     oldExclusivePath,            use old fse rendering path,                                         boolean
//     presentThread,               run presentation in a separate thread,                              boolean
//     preRenderFrames,             no of pre-presented frames,                                         integer, 1..16
//     backbufferCountExcl,         no of backbuffers,                                                  integer, 1..8
//     flushAfterRenderStepsExcl,   after render steps,                                                 string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//     flushAfterLastStepExcl,      after last step,                                                    string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//     flushAfterBackbufferExcl,    after backbuffer,                                                   string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//     flushAfterPresentExcl,       after present,                                                      string,  don''t flush|flush|flush & wait (sleep)|flush & wait (loop)
//   smoothMotion, smooth motion
//     smoothMotionEnabled,         enable smooth motion frame rate conversion,                         boolean
//     smoothMotionMode,            smooth motion mode,                                                 string,  avoidJudder|almostAlways|always
//   dithering, dithering
//     ditheringAlgo,               dithering algorithm,                                                string,  random|ordered|errorDifLowNoise|errorDifMedNoise
//     dontDither,                  don't use dithering,                                                boolean
//     coloredDither,               use colored noise,                                                  boolean
//     dynamicDither,               change dither for every frame,                                      boolean
//   tradeQuality, trade quality for performance
//     fastSubtitles,               optimize subtitles for performance instead of quality,              boolean
//     dxvaChromaWhenDecode,        use DXVA chroma upscaling when doing native DXVA decoding           boolean
//     dxvaChromaWhenDeint,         use DXVA chroma upscaling when doing DXVA deinterlacing             boolean
//     mayLoseBtb,                  lose BTB and WTW if it improves performance                         boolean
//     customShaders16f,            store custom pixel shader results in 16bit buffer instead of 32bit, boolean
//     gammaDithering,              don't use linear light for dithering,                               boolean
//     noGradientAngles,            don't analyze gradient angles for debanding,                        boolean
//     dontRerenderFades,           don't rerender frames when fade in/out is detected,                 boolean
//     gammaBlending,               don't use linear light for smooth motion frame blending,            boolean
//     10bitChroma,                 use 10bit chroma buffer instead of 16bit,                           boolean
//     10bitLuma,                   use 10bit image buffer instead of 16bit,                            boolean
//     customShadersTv,             run custom pixel shaders in video levels instead of PC levels,      boolean
//     3dlutLowerBitdepth,          use lower bitdepth for yCMS 3dlut calibration,                      boolean
//     3dlutBitdepth,               3dlut bitdepth,                                                     integer, 6..7
//     halfDxvaDeintFramerate,      use half frame rate for DXVA deinterlacing,                         boolean
// ui, user interface
//   keys, keyboard shortcuts
//     keysOnlyIfFocused,           use only if media player has keyboard focus,                        boolean
//     keyDebugOsd,                 debug OSD - toggle on/off,                                          string
//     keyResetStats,               debug OSD - reset statistics,                                       string
//     keyFreezeReport,             create freeze report,                                               string
//     keyOutputLevels,             output levels - toggle,                                             string
//     keySourceLevels,             source levels - toggle,                                             string
//     keySourceBlackInc,           source black level - increase,                                      string
//     keySourceBlackDec,           source black level - decrease,                                      string
//     keySourceWhiteInc,           source white level - increase,                                      string
//     keySourceWhiteDec,           source white level - decrease,                                      string
//     keySourceBrightnessInc,      source brightness - increase,                                       string
//     keySourceBrightnessDec,      source brightness - decrease,                                       string
//     keySourceContrastInc,        source contrast - increase,                                         string
//     keySourceContrastDec,        source contrast - decrease,                                         string
//     keySourceSaturationInc,      source saturation - increase,                                       string
//     keySourceSaturationDec,      source saturation - decrease,                                       string
//     keySourceHueInc,             source hue - increase,                                              string
//     keySourceHueDec,             source hue - decrease,                                              string
//     keySourceColorControlReset,  source color control - reset,                                       string
//     keyMatrix,                   source decoding matrix - toggle,                                    string
//     keyPrimaries,                source primaries - toggle,                                          string
//     keyPrimariesEbu,             source primaries - set to "EBU/PAL",                                string
//     keyPrimaries709,             source primaries - set to "BT.709",                                 string
//     keyPrimariesSmpteC,          source primaries - set to "SMPTE C",                                string
//     keyPrimaries2020,            source primaries - set to "BT.2020",                                string
//     keyPrimariesDci,             source primaries - set to "DCI-P3",                                 string
//     keyDeint,                    deinterlacing - toggle,                                             string
//     keyDeintFieldOrder,          deinterlacing field order - toggle,                                 string
//     keyDeintContentType,         deinterlacing content type - toggle,                                string
//     keyDeintContentTypeFilm,     deinterlacing content type - set to "film",                         string
//     keyDeintContentTypeVideo,    deinterlacing content type - set to "video",                        string
//     keyDeintContentTypeAuto,     deinterlacing content type - set to "auto detect",                  string
//     keyDeband,                   debanding - toggle,                                                 string
//     keyDebandCustom,             debanding custom settings - toggle,                                 string
//     keyDesiredGammaCurve,        desired display gamma curve - toggle,                               string
//     keyDesiredGammaValueInc,     desired display gamma value - increase,                             string
//     keyDesiredGammaValueDec,     desired display gamma value - decrease,                             string
//     keyFseEnable,                automatic fullscreen exclusive mode - enable,                       string
//     keyFseDisable,               automatic fullscreen exclusive mode - disable,                      string
//     keyFseDisable10,             automatic fullscreen exclusive mode - disable for 10 seconds,       string
//     keyEnableSmoothMotion,       enable smooth motion frame rate conversion,                         string
//     keyDisableSmoothMotion,      disable smooth motion frame rate conversion,                        string
//     keyChromaAlgo,               chroma upscaling algorithm - toggle,                                string
//     keyChromaAlgoNearest,        chroma upscaling algorithm - set to "Nearest Neighbor",             string
//     keyChromaAlgoBilinear,       chroma upscaling algorithm - set to "Bilinear",                     string
//     keyChromaAlgoMitchell,       chroma upscaling algorithm - set to "Mitchell-Netravali",           string
//     keyChromaAlgoCatmull,        chroma upscaling algorithm - set to "Catmull-Rom",                  string
//     keyChromaAlgoBicubic,        chroma upscaling algorithm - set to "Bicubic",                      string
//     keyChromaAlgoSoftCubic,      chroma upscaling algorithm - set to "SoftCubic",                    string
//     keyChromaAlgoLanczos,        chroma upscaling algorithm - set to "Lanczos",                      string
//     keyChromaAlgoSpline,         chroma upscaling algorithm - set to "Spline",                       string
//     keyChromaAlgoJinc,           chroma upscaling algorithm - set to "Jinc",                         string
//     keyChromaAlgoParamInc,       chroma upscaling algorithm parameter - increase,                    string
//     keyChromaAlgoParamDec,       chroma upscaling algorithm parameter - decrease,                    string
//     keyChromaAntiRing,           chroma upscaling anti-ringing filter - toggle on/off,               string
//     keyImageUpAlgo,              image upscaling algorithm - toggle,                                 string
//     keyImageUpAlgoNearest,       image upscaling algorithm - set to "Nearest Neighbor",              string
//     keyImageUpAlgoBilinear,      image upscaling algorithm - set to "Bilinear",                      string
//     keyImageUpAlgoDxva,          image upscaling algorithm - set to "DXVA2",                         string
//     keyImageUpAlgoMitchell,      image upscaling algorithm - set to "Mitchell-Netravali",            string
//     keyImageUpAlgoCatmull,       image upscaling algorithm - set to "Catmull-Rom",                   string
//     keyImageUpAlgoBicubic,       image upscaling algorithm - set to "Bicubic",                       string
//     keyImageUpAlgoSoftCubic,     image upscaling algorithm - set to "SoftCubic",                     string
//     keyImageUpAlgoLanczos,       image upscaling algorithm - set to "Lanczos",                       string
//     keyImageUpAlgoSpline,        image upscaling algorithm - set to "Spline",                        string
//     keyImageUpAlgoJinc,          image upscaling algorithm - set to "Jinc",                          string
//     keyImageUpAlgoParamInc,      image upscaling algorithm parameter - increase,                     string
//     keyImageUpAlgoParamDec,      image upscaling algorithm parameter - decrease,                     string
//     keyImageUpAntiRing,          image upscaling anti-ringing filter - toggle on/off,                string
//     keyImageUpLinear,            image upscaling in linear light - toggle on/off,                    string
//     keyImageDownAlgo,            image downscaling algorithm - toggle,                               string
//     keyImageDownAlgoNearest,     image downscaling algorithm - set to "Nearest Neighbor",            string
//     keyImageDownAlgoBilinear,    image downscaling algorithm - set to "Bilinear",                    string
//     keyImageDownAlgoDxva,        image downscaling algorithm - set to "DXVA2",                       string
//     keyImageDownAlgoMitchell,    image downscaling algorithm - set to "Mitchell-Netravali",          string
//     keyImageDownAlgoCatmull,     image downscaling algorithm - set to "Catmull-Rom",                 string
//     keyImageDownAlgoBicubic,     image downscaling algorithm - set to "Bicubic",                     string
//     keyImageDownAlgoSoftCubic,   image downscaling algorithm - set to "SoftCubic",                   string
//     keyImageDownAlgoLanczos,     image downscaling algorithm - set to "Lanczos",                     string
//     keyImageDownAlgoSpline,      image downscaling algorithm - set to "Spline",                      string
//     keyImageDownAlgoParamInc,    image downscaling algorithm parameter - increase,                   string
//     keyImageDownAlgoParamDec,    image downscaling algorithm parameter - decrease,                   string
//     keyImageDownAntiRing,        image downscaling anti-ringing filter - toggle on/off,              string
//     keyImageDownLinear,          image downscaling in linear light - toggle on/off,                  string
//     keyDisplayModeChanger,       display mode switcher - toggle on/off,                              string
//     keyDisplayBitdepth,          display bitdepth - toggle,                                          string
//     keyDithering,                dithering - toggle on/off,                                          string
//     key3dlutSplitScreen,         3dlut split screen - toggle on,                                     string

// profile settings: id, name, type, valid values
// ----------------------------------------------
// Profile Group 1
//   keyToggleProfiles,             keyboard shortcut to toggle profiles,                               string
//   autoselectRules,               profile auto select rules,                                          string
//   Profile 1
//     keyActivateProfile,          keyboard shortcut to activate this profile,                         string
//     activateCmdline,             command line to execute when this profile is activated,             string
//     deactivateCmdline,           command line to execute when this profile is deactivated,           string

// ---------------------------------------------------------------------------
// IMadVRFrameGrabber
// ---------------------------------------------------------------------------

// the "IMadVRFrameGrabber" interface can be used to get an 8bit RGB grab
// of the currently shown video frame

// the resulting DIB Image is allocated by madVR using LocalAlloc
// it's the caller's duty to free the buffer when it's no longer needed

// values for IMadVRFrameGrabber::GrabFrame's "zoom" parameter
const
  ZOOM_PLAYBACK_SIZE : integer = 0;     // the exact size/zoom used in current playback
  ZOOM_ENCODED_SIZE  : integer = 1;     // the video in its encoded size (e.g. DVD 720x480), *without* aspect ratio correction
  ZOOM_25_PERCENT    : integer = 25;    // the video zoomed down to 25% of its original size, with AR correction
  ZOOM_50_PERCENT    : integer = 50;    // the video zoomed down to 50%
  ZOOM_100_PERCENT   : integer = 100;   // the video in its original size
  ZOOM_200_PERCENT   : integer = 200;   // the video zoomed up to 200%
  ZOOM_300_PERCENT   : integer = 300;   // the video zoomed up to 300%
  ZOOM_400_PERCENT   : integer = 400;   // the video zoomed up to 400%
  ZOOM_800_PERCENT   : integer = 800;   // the video zoomed up to 800%
  ZOOM_1280x720      : integer = 720;   // the video centered with "touch from inside" in a 1280x720 rect
  ZOOM_1920x1080     : integer = 1080;  // the video centered with "touch from inside" in a 1920x1080 rect
  ZOOM_3840x2160     : integer = 2160;  // the video centered with "touch from inside" in a 3840x2160 rect

// flags for IMadVRFrameGrabber::GrabFrame's "flags" parameter
const
  FLAGS_RENDER_OSD               : integer = 1;    // *do* include the OSD in the frame grab
  FLAGS_APPLY_CALIBRATION        : integer = 2;    // *do* perform calibration stuff (3dlut, color & gamma changes etc)
  FLAGS_NO_SUBTITLES             : integer = 4;    // don't include subtitles in the frame grab
  FLAGS_NO_ARTIFACT_REMOVAL      : integer = 8;    // don't apply the user selected artifact removal algorithms
  FLAGS_NO_IMAGE_ENHANCEMENTS    : integer = $10;  // don't apply the user selected image enhancement algorithms
  FLAGS_NO_UPSCALING_REFINEMENTS : integer = $20;  // don't apply the user selected image upscaling refinement algorithms
  FLAGS_NO_HDR_SDR_CONVERSION    : integer = $40;  // don't perform HDR -> SDR conversion
  FLAGS_NO_CUSTOM_SHADERS        : integer = $80;  // don't execute custom shaders

// flags for IMadVRFrameGrabber::GrabFrame's "chromaUpscaling" parameter
const
  CHROMA_UPSCALING_USER_SELECTED : integer = 0;  // use the user selected chroma upscaling algorithm
  CHROMA_UPSCALING_BILINEAR      : integer = 1;  // use fast "bilinear" chroma upscaling
  CHROMA_UPSCALING_NGU_AA        : integer = 2;  // use slow but high quality NGU Anti-Alias chroma upscaling

// flags for IMadVRFrameGrabber::GrabFrame's "imageDownscaling" parameter
const
  IMAGE_DOWNSCALING_USER_SELECTED : integer = 0;  // use the user selected image downscaling algorithm
  IMAGE_DOWNSCALING_BILINEAR      : integer = 1;  // use fast "bilinear" image downscaling
  IMAGE_DOWNSCALING_SSIM1D100     : integer = 2;  // use slow but high quality SSIM-1D "100" image downscaling

// flags for IMadVRFrameGrabber::GrabFrame's "imageUpscaling" parameter
const
  IMAGE_UPSCALING_USER_SELECTED      : integer = 0;  // use the user selected image upscaling algorithm
  IMAGE_UPSCALING_BILINEAR           : integer = 1;  // use fast "bilinear" image upscaling
  IMAGE_UPSCALING_NGU_AA             : integer = 2;  // use NGU Anti-Alias image upscaling
  IMAGE_UPSCALING_NGU_STANDARD       : integer = 3;  // use NGU Standard image upscaling
  IMAGE_UPSCALING_NGU_SHARP          : integer = 4;  // use NGU Sharp image upscaling
  IMAGE_UPSCALING_NGU_AA_GRAIN       : integer = 5;  // use NGU Anti-Alias image upscaling, with a bit of added grain
  IMAGE_UPSCALING_NGU_STANDARD_GRAIN : integer = 6;  // use NGU Standard image upscaling, with a bit of added grain
  IMAGE_UPSCALING_NGU_SHARP_GRAIN    : integer = 7;  // use NGU Sharp image upscaling, with a bit of added grain

type
  IMadVRFrameGrabber = interface ['{B0F34BA5-5EFD-4762-A07F-FF9046B4566C}']
    function GrabFrame(
      zoom             : dword;    // which resolution to create the frame grab in?
      flags            : dword;    // various flags/options
      chromaUpscaling  : dword;    // which chroma upscaling algorithm to use?
      lumaDownscaling  : dword;    // which luma downscaling algorithm to use?
      lumaUpscaling    : dword;    // which luma upscaling algorithm to use?
      reserved1        : dword;    // reserved for future flags/options, set to 0
      out dibImage     : pointer;  // output: DIB Image = BITMAPINFOHEADER + pixels
      reserved2        : pointer   // reserved for future use, set to NULL
    ) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// ISubRender
// ---------------------------------------------------------------------------

// the "ISubRender" interface is used by the internal subtitle rendering
// engine in MPC-HC and PotPlayer for communication with madVR and with the
// Haali Video Renderer

type
  ISubRenderCallback = interface;  // forward

  // interface exported by madVR
  ISubRender = interface ['{9CC7F9F7-3ED1-493c-AF65-527EA1D9947F}']
    function SetCallback(callback: ISubRenderCallback) : HRESULT; stdcall;
  end;

  // callback interfaces can provide madVR with
  ISubRenderCallback = interface ['{CD6D2AA5-20D3-4ebe-A8A9-34D3B00CC253}']
    function SetDevice(device: IUnknown) : HRESULT; stdcall;
    function Render(frameStart: int64; left, top, right, bottom, width, height: integer) : HRESULT; stdcall;
  end;
  ISubRenderCallback2 = interface (ISubRenderCallback) ['{E602585E-C05A-4828-AC69-AF92997F2E0C}']
    function RenderEx(frameStart, frameStop, avgTimePerFrame: int64; left, top, right, bottom, width, height: integer) : HRESULT; stdcall;
  end;
  ISubRenderCallback3 = interface (ISubRenderCallback2) ['{BAC4273A-3EAD-47F5-9710-8488E52AC618}']
    function RenderEx2(frameStart, frameStop, avgTimePerFrame: int64; croppedVideoRect, originalVideoRect, viewportRect: TRect; const videoStretchFactor: double = 1.0) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// EC_VIDEO_SIZE_CHANGED "lParam2" values sent by madVR
// ---------------------------------------------------------------------------

const
  VIDEO_SIZE_CHANGED_INITIAL_SIZE                = 777;  // initial size information
  VIDEO_SIZE_CHANGED_MEDIA_TYPE_CHANGED          = 778;  // mediatype has changed
  VIDEO_SIZE_CHANGED_BLACK_BAR_DETECTION_CHANGED = 779;  // black bar detection has changed
  VIDEO_SIZE_CHANGED_DVD_AR_CHANGED              = 780;  // DVD metadata caused an AR change
  VIDEO_SIZE_CHANGED_AR_OVERRIDE_CHANGED         = 781;  // media player called SendCommandDouble("setArOverride")
  VIDEO_SIZE_CHANGED_ROTATION_CHANGED_KEY        = 782;  // rotation changed - user pressed madVR keyboard shortcut
  VIDEO_SIZE_CHANGED_ROTATION_CHANGED_API        = 783;  // rotation changed - media player called SendCommandInt("rotate")

// ---------------------------------------------------------------------------
// IMadVRExclusiveModeInfo (obsolete)
// ---------------------------------------------------------------------------

// CAUTION: This interface is obsolete. Use IMadVRInfo instead:
// IMadVRInfo::InfoGetBoolean("ExclusiveModeActive")
// IMadVRInfo::InfoGetBoolean("MadVRSeekbarEnabled")

// this interface allows you to ask...
// ... whether madVR is currently in exclusive mode
// ... whether the madVR exclusive mode seek bar is currently enabled

// If madVR is in fullscreen exclusive mode, you should be careful with
// which GUI you show, because showing any window based GUI will make madVR
// automatically switch back to windowed mode. That's ok if that's what you
// really want, just be aware of that. A good alternative is to use the
// graphical or text base OSD interfaces (see above). Using them instead of
// a window based GUI means that madVR can stay in exclusive mode all the
// time.

// Since madVR has its own seek bar (which is only shown in fullscreen
// exclusive mode, though), before showing your own seek bar you should
// check whether madVR is in fullscreen exclusive mode and whether the
// user has enabled madVR's own seek bar. If so, you should probably not
// show your own seek bar. If the user, however, has the madVR seek bar
// disabled, you should still show your own seek bar, because otherwise
// the user will have no way to seek at all.

type
  IMadVRExclusiveModeInfo = interface ['{D6EE8031-214E-4E9E-A3A7-458925F933AB}']
    function IsExclusiveModeActive : BOOL; stdcall;
    function IsMadVRSeekbarEnabled : BOOL; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRRefreshRateInfo (obsolete)
// ---------------------------------------------------------------------------

// CAUTION: This interface is obsolete. Use IMadVRInfo instead:
// IMadVRInfo::GetDouble("RefreshRate")

// this interface allows you to ask madVR about the detected refresh rate

type
  IMadVRRefreshRateInfo = interface ['{3F6580E8-8DE9-48D0-8E4E-1F26FE02413E}']
    function GetRefreshRate(out refreshRate: double) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRSeekbarControl (obsolete)
// ---------------------------------------------------------------------------

// CAUTION: This interface is obsolete. Use IMadVRCommand instead:
// IMadVRCommand::SendCommandBool("disableSeekbar", true)

type
  IMadVRSeekbarControl = interface ['{D2D3A520-7CFA-46EB-BA3B-6194A028781C}']
    function DisableSeekbar(disable: BOOL) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRExclusiveModeControl (obsolete)
// ---------------------------------------------------------------------------

// CAUTION: This interface is obsolete. Use IMadVRCommand instead:
// IMadVRCommand::SendCommandBool("disableExclusiveMode", true)

type
  IMadVRExclusiveModeControl = interface ['{88A69329-3CD3-47D6-ADEF-89FA23AFC7F3}']
    function DisableExclusiveMode(disable: BOOL) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------
// IMadVRDirect3D9Manager
// ---------------------------------------------------------------------------

// CAUTION: This interface is obsolete. Instead use texture/surface sharing,
// so that both media player and madVR can render to their own devices. You
// can then blend the media player's GUI on top of madVR's rendered video
// frames in madVR's OSD callback function.

type
  IMadVRDirect3D9Manager = interface ['{1CAEE23B-D14B-4DB4-8AEA-F3528CB78922}']
    function UseTheseDevices(const scanlineReading, rendering, presentation: IDirect3DDevice9) : HRESULT; stdcall;
    function ConfigureDisplayModeChanger(allowResolutionChanges, allowRefreshRateChanges: BOOL) : HRESULT; stdcall;
  end;

// ---------------------------------------------------------------------------

implementation

end.
