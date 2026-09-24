// ***************************************************************
//  madTPG.pas                version: 1.6.0  ·  date: 2017-09-12
//  -------------------------------------------------------------
//  madTPG remote controlling
//  -------------------------------------------------------------
//  Copyright (C) 2013 - 2017 www.madshi.net, BSD license
// ***************************************************************

// 2017-09-12 1.6.0 added various HDR related APIs
// 2015-07-19 1.5.0 (1) added IsFseModeEnabled API
//                  (2) added Enabled/DisableFseMode APIs
// 2015-06-28 1.4.0 (1) added IsLocal API
//                  (2) added Is/Enter/LeaveFullscreen APIs
//                  (3) added Get/SetWindowSize APIs
//                  (4) added (Is)Min/Maximize(d)/Restore(d) APIs
// 2015-01-03 1.3.0 (1) added GetVersion API
//                  (2) added Get/SetSelected3dlut APIs
// 2014-12-01 1.2.0 (1) added Connect, deprecated BindConnect and ConnectDialog
//                  (2) added APIs to get/set "stay on top"    button state
//                  (3) added APIs to get/set "use fullscreen" button state
//                  (4) added APIs to get/set "disable OSD"    button state
//                  (5) added Get/SetPatternConfig APIs
//                  (6) added ShowRGBEx API
//                  (7) added various 3dlut conversion and import APIs
// 2013-11-27 1.1.0 added madVR_GetBlackAndWhiteLevel
// 2013-06-15 1.0.0 initial version

unit madTPG;

interface

uses Windows, madTypes;

// ============================================================================
// I. THE EASY WAY
// ============================================================================

// ----------------------------------------------------------------------------
// connecting to madVR - two options

// (1) "madVR_Connect" is the recommended API to find a madTPG instance to
//     connect to. You can let this API search the local PC and/or the LAN for
//     already running madTPG instances, and/or if no instances are found in a
//     specific time interval, you can simply let the API start a new madTPG
//     instance for you on the local PC. Or you can let the API show a dialog
//     to the end user, allowing the end user to enter an IP address to locate
//     an already running madTPG instance.

const
  CM_ConnectToLocalInstance = 0;  // search for madTPG on the local PC, connect to the first found instance
  CM_ConnectToLanInstance   = 1;  // search for madTPG on the LAN,      connect to the first found instance
  CM_StartLocalInstance     = 2;  // start madTPG on the local PC and connect to it
  CM_ShowListDialog         = 3;  // search local PC and LAN, and let the user choose which instance to connect to
  CM_ShowIpAddrDialog       = 4;  // let the user enter the IP address of a PC which runs madTPG, then connect
  CM_Fail                   = 5;  // fail immediately

function madVR_Connect (method1: integer = CM_ConnectToLocalInstance; timeOut1: dword = 1000;
                        method2: integer = CM_ConnectToLanInstance;   timeOut2: dword = 3000;
                        method3: integer = CM_ShowListDialog;         timeOut3: dword = INFINITE;
                        method4: integer = CM_Fail;                   timeOut4: dword = 0;
                        parentWindow: HWND = 0) : boolean;

// (2) If you want to connect to a madVR instance running on a LAN PC with a
//     known IP address, "madVR_ConnectToIp" lets you do just that.
// "result=true"  means: A madVR instance was found and a connection opened.
// "result=false" means: No madVR instance found, or connection failed.
function madVR_ConnectToIp (const ipAddress: AnsiString; timeOut: dword = 1000) : boolean;

// ----------------------------------------------------------------------------
// remote controlling the connected madVR instance

// "madVR_GetVersion" reports the madVR version of the connected madTPG
// instance number as a hex number. E.g. version v0.87.12.0 is reported
// as $00871200. This format allows you to do a simple version check like
// "if (version >= $00871200)".
function madVR_GetVersion (out version: dword) : boolean;

// "madVR_IsLocal" reports whether the connected madTPG instance is running
// on the local PC or not.
function madVR_IsLocal () : boolean;

// "madVR_Enter/LeaveFullscreen" switches madTPG into/out of fullscreen mode.
// Calling this API has a similar effect to the user double clicking the
// madTPG window.
function madVR_IsFullscreen () : boolean;
function madVR_EnterFullscreen () : boolean;
function madVR_LeaveFullscreen () : boolean;

// "madVR_IsFseModeEnabled" allows you to ask whether madTPG will switch
// into (f)ull(s)creen (e)xclusive mode, when madTPG enters fullscreen
// mode. Only FSE mode supports native 10bit output.
// "madVR_En/DisableFseMode" overwrites the madVR user configuration to
// forcefully enable or disable FSE mode.
function madVR_IsFseModeEnabled () : boolean;
function madVR_EnableFseMode () : boolean;
function madVR_DisableFseMode () : boolean;

// "madVR_Get/SetWindowSize" reads/changes the size of the madTPG window.
function madVR_GetWindowSize (out windowSize: TRect) : boolean;
function madVR_SetWindowSize (const windowSize: TRect) : boolean;

// "madVR_IsMin/Maximized" and "madVR_Min/Maximize/Restore" read/change
// the state of the madTPG window (minimized, maximized, restored).
function madVR_IsMinimized () : boolean;
function madVR_IsMaximized () : boolean;
function madVR_IsRestored  () : boolean;
function madVR_Minimize () : boolean;
function madVR_Maximize () : boolean;
function madVR_Restore  () : boolean;

// The following functions allow you to read and set the "pressed" state
// of the "stay on top", "use fullscreen", "disable OSD" and "HDR" buttons.
function madVR_IsStayOnTopButtonPressed () : boolean;
function madVR_IsUseFullscreenButtonPressed () : boolean;
function madVR_IsDisableOsdButtonPressed () : boolean;
function madVR_IsHdrButtonPressed () : boolean;
function madVR_SetStayOnTopButton (pressed: boolean) : boolean;
function madVR_SetUseFullscreenButton (pressed: boolean) : boolean;
function madVR_SetDisableOsdButton (pressed: boolean) : boolean;
function madVR_SetHdrButton (pressed: boolean) : boolean;

// "madVR_SetHdrMetadata" allows you to define which SMPTE 2086 metadata
// is sent to the display when madTPG is in HDR mode.
// minLum, maxLum, madCLL and maxFALL are floating point Nits values.
function madVR_SetHdrMetadata(rx, ry, gx, gy, bx, by, wx, wy, minLum, maxLum, maxCLL, maxFALL: double) : boolean;

// "madVR_GetBlackAndWhiteLevel" reports the madVR output level setup.
// E.g. if madVR is setup to output TV levels, you'll get "blackLevel = 16" and
// "whiteLevel = 235" reported.
// The purpose of asking this information is that it allows you to avoid
// dithering, if you so prefer. Dithering will be automatically disabled by
// madVR if the final 8bit output value calculated by madVR ends up being a
// simple cardinal without any fractional part.
// E.g. if you use "madVR_ShowRGB(0.5, 0.5, 0.5)" with madVR configured to PC
// levels, the final 8bit value will be 127.5, which means that madVR has to
// use dithering to display the color correctly. If you want to avoid dithering,
// use "x / (whiteLevel - blackLevel)" values.
// Dithering in itself is not bad. It allows madVR to produce test pattern
// colors which would otherwise not be possible to display in 8bit. However,
// calibration quality might be ever so slightly improved if you choose
// measurement colors which don't need dithering to display correctly. It's
// your choice, though. Maybe some part of your calibration might even improve
// if you have the chance to measure colors with a bitdepth higher than 8bit.
function madVR_GetBlackAndWhiteLevel (out blackLevel, whiteLevel: integer) : boolean;

// "madVR_Get/SetSelected3dlut" allows you to ask/set which 3dlut is
// currently being used by madTPG (e.g. BT.709 vs EBU/PAL).
// Setting the 3dlut automatically enables the 3dlut (madVR_Enable3dlut).
// In HDR mode only BT.709, BT.2020 and DCI-P3 are supported.
// "thr3dlut" 0: BT.709; 1: SMPTE-C; 2: EBU/PAL; 3: BT.2020; 4: DCI-P3
function madVR_GetSelected3dlut (out thr3dlut: dword) : boolean;
function madVR_SetSelected3dlut (    thr3dlut: dword) : boolean;

// "madVR_En/Disable3dlut" en/disables 3dlut processing.
// The 3dlut stays en/disabled until the connection is closed.
// Disable the 3dlut if you want to calibrate/profile the display, or if you
// want to measure the display behaviour prior to calibration.
// Enable the 3dlut if you want to measure the final display after full
// calibration.
function madVR_Enable3dlut () : boolean;
function madVR_Disable3dlut () : boolean;

// "madVR_Get/SetDeviceGammaRamp" calls the win32 API "Get/SetDeviceGammaRamp"
// on the target PC / display. A "NULL" ramp sets a linear ramp.
// The original ramp is automatically restored when you close the connection.
function madVR_GetDeviceGammaRamp (ramp: pointer      ) : boolean;
function madVR_SetDeviceGammaRamp (ramp: pointer = nil) : boolean;

// "madVR_SetOsdText" shows a "text" on the top left of the video image.
function madVR_SetOsdText (const text: UnicodeString) : boolean;

// "madVR_Get/SetPatternConfig" lets you retrieve/define how much percent of
// the madVR rendering window is painted in the test pattern color, and how
// much is painted with a specific background color.
// Using a background color can make sense for plasma measurements.
// patternAreaInPercent:     1-100 (%)
// backgroundLevelInPercent: 0-100 (%)
// backgroundMode:           0 = constant gray; 1 = APL - gamma light; 2 = APL - linear light
// blackBorderWidth:         0-100 (pixels), default: 20
// When calling "madVR_SetPatternConfig", you can set all parameters that you
// don't want to change to "-1".
function madVR_GetPatternConfig (out patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth: integer) : boolean;
function madVR_SetPatternConfig (    patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth: integer) : boolean;

// "madVR_ShowProgressBar" initializes the madVR progress bar.
// It will progress one step with every "madVR_ShowRGB" call (see below).
function madVR_ShowProgressBar (numberOfRgbMeasurements: integer) : boolean;

// "madVR_SetProgressBarPos" sets the madVR progress bar to a specific pos.
// After calling this API, the progress bar will not automatically move
// forward after calls to "madVR_ShowRGB", anymore. Calling this API means
// you have to manually move the progress bar.
function madVR_SetProgressBarPos (currentPos, maxPos: integer) : boolean;

// "madVR_ShowRGB" shows a specific RGB color test pattern.
// Values are gamma corrected with "black = 0.0" and "white = 1.0". The values
// are automatically converted to TV or PC output levels by madTPG, depending
// on the end user's display device setup.
// You can go below 0.0 or above 1.0 for BTB/WTW, if you want. Of course a test
// pattern with BTB/WTW will only work if the connected madVR instance is
// configured to TV level output.
// "madVR_ShowRGB" blocks until the GPU has actually output the test pattern to
// the display. How fast the display will actually show the test pattern will
// depend on the display's input latency, which is outside of madVR's control.
function madVR_ShowRGB (const r, g, b: double) : boolean;

// "madVR_ShowRGBEx" works similar to "ShowRGB", but instead of letting
// madTPG calculate the background color, you can define it yourself.
function madVR_ShowRGBEx (const r, g, b, bgR, bgG, bgB: double) : boolean;

// ----------------------------------------------------------------------------
// 3dlut conversion & loading

type
  TEeColor3dlut = packed array [0.. 64] of packed array [0.. 64] of packed array [0.. 64] of packed array [0..2] of double;
  TMadVR3dlut   = packed array [0..255] of packed array [0..255] of packed array [0..255] of packed array [0..2] of word;

// "madVR_Convert3dlutFile" converts an existing eeColor 3dlut file to
// the madVR 3dlut file format. The 64^3 3dlut is internally interpolated to
// 256^3 by using a linear Mitchell filter.
// In HDR mode only BT.709, BT.2020 and DCI-P3 are supported.
// "gamut" 0: BT.709; 1: SMPTE-C; 2: EBU/PAL; 3: BT.2020; 4: DCI-P3
// "sdrOutput" true: 3dlut outputs Gamma; false: 3dlut outputs PQ
function madVR_Convert3dlutFile    (const eeColor3dlutFile, madVR3dlutFile: UnicodeString; gamut: integer) : boolean;
function madVR_ConvertHdr3dlutFile (const eeColor3dlutFile, madVR3dlutFile: UnicodeString; gamut: integer; outputSdr: boolean) : boolean;

// "madVR_Create3dlutFileFromArray65/256" creates a madVR 3dlut file from
// an array which is sorted in the same way as an eeColor 3dlut text file.
// The 64^3 dlut is internally interpolated to 256^3 by using a linear
// Mitchell filter.
// In HDR mode only BT.709, BT.2020 and DCI-P3 are supported.
// "gamut" 0: BT.709; 1: SMPTE-C; 2: EBU/PAL; 3: BT.2020; 4: DCI-P3
// "sdrOutput" true: 3dlut outputs Gamma; false: 3dlut outputs PQ
function madVR_Create3dlutFileFromArray65     (var lutData: TEeColor3dlut; const madVR3dlutFile: UnicodeString; gamut: integer) : boolean;
function madVR_Create3dlutFileFromArray256    (var lutData:   TMadVR3dlut; const madVR3dlutFile: UnicodeString; gamut: integer) : boolean;
function madVR_CreateHdr3dlutFileFromArray65  (var lutData: TEeColor3dlut; const madVR3dlutFile: UnicodeString; gamut: integer; outputSdr: boolean) : boolean;
function madVR_CreateHdr3dlutFileFromArray256 (var lutData:   TMadVR3dlut; const madVR3dlutFile: UnicodeString; gamut: integer; outputSdr: boolean) : boolean;

// "madVR_Load3dlutFile" loads a 3dlut (can be either eeColor or madVR
// file format) into the connected madTPG instance.
// In HDR mode only BT.709, BT.2020 and DCI-P3 are supported.
// "saveToSettings=false" means: the 3dlut only stays loaded until madTPG is closed; "gamut" is ignored
// "saveToSettings=true"  means: the 3dlut is permanently written to the madVR settings, to the "gamut" slot
// "gamut" 0: BT.709; 1: SMPTE-C; 2: EBU/PAL; 3: BT.2020; 4: DCI-P3
// "sdrOutput" true: 3dlut outputs Gamma; false: 3dlut outputs PQ
function madVR_Load3dlutFile    (const lutFile: UnicodeString; saveToSettings: boolean; gamut: integer) : boolean;
function madVR_LoadHdr3dlutFile (const lutFile: UnicodeString; saveToSettings: boolean; gamut: integer; outputSdr: boolean) : boolean;

// "madVR_Load3dlutFromArray65/256" loads a 3dlut into the connected
// madTPG instance.
// In HDR mode only BT.709, BT.2020 and DCI-P3 are supported.
// "saveToSettings=false" means: the 3dlut only stays loaded until madTPG is closed; "gamut" is ignored
// "saveToSettings=true"  means: the 3dlut is permanently written to the madVR settings, to the "gamut" slot
// "gamut" 0: BT.709; 1: SMPTE-C; 2: EBU/PAL; 3: BT.2020; 4: DCI-P3
// "sdrOutput" true: 3dlut outputs Gamma; false: 3dlut outputs PQ
function madVR_Load3dlutFromArray65     (var lutData: TEeColor3dlut; saveToSettings: boolean; gamut: integer) : boolean;
function madVR_Load3dlutFromArray256    (var lutData:   TMadVR3dlut; saveToSettings: boolean; gamut: integer) : boolean;
function madVR_LoadHdr3dlutFromArray65  (var lutData: TEeColor3dlut; saveToSettings: boolean; gamut: integer; outputSdr: boolean) : boolean;
function madVR_LoadHdr3dlutFromArray256 (var lutData:   TMadVR3dlut; saveToSettings: boolean; gamut: integer; outputSdr: boolean) : boolean;

// ----------------------------------------------------------------------------
// disconnecting from madVR

// "madVR_Disconnect" closes the current connection to madVR.
function madVR_Disconnect : boolean;

// "madVR_Quit" closes the madTPG instance we're connected to.
function madVR_Quit : boolean;

// ----------------------------------------------------------------------------
// checking madVR availability

// "madVR_IsAvailable" checks whether the madHcNet32.dll can be found.
// It must either be in the current directory, or in the search path.
// Or alternatively it will also work if madVR is installed on the current PC.
function madVR_IsAvailable : boolean;

// ----------------------------------------------------------------------------


// ============================================================================
// II. THE HARD WAY
// ============================================================================

// ----------------------------------------------------------------------------
// finding / enumerating madVR instances on the LAN

// The following APIs let you automatically locate madVR instances running
// anywhere on either the local PC or remote PCs connected via LAN.
// For every found madVR instance this full information record is returned:

type
  TMadVRInstance = packed record   // Example:
    handle       : THandle;        // 1
    instance     : int64;          // 0x40001000
    ipAddress    : PAnsiChar;      // "192.168.1.1"
    computerName : PWideChar;      // "HTPC"
    userName     : PWideChar;      // "Walter"
    os           : PWideChar;      // "Windows 8.1"
    processId    : NativeUInt;     // 248
    processName  : PWideChar;      // "madVR Test Pattern Generator"
    exeFile      : PWideChar;      // "madTPG.exe"
    exeVersion   : PWideChar;      // 1.0.0.0
    madVRVersion : PWideChar;      // 0.87.11.0
    gpuName      : PWideChar;      // "GeForce 750"
    monitorName  : PWideChar;      // "JVC HD-350"
  end;
  PMadVRInstance = ^TMadVRInstance;

// Normally, a network search returns all running madVR instances in less than
// a second. But under specific circumstances, the search can take several
// seconds. because of that there are different ways to perform a search:

// (1) synchronous search
// Calling "madVR_Find" (see below) with a timeout means that madVR_Find will
// perform a network search and only return when the search is complete, or
// when the timeout is over.

// (2) asynchronous search I
// You can call "madVR_Find" with a timeout value of "0" to start the search.
// madVR_Find will return at once, but it will start a search in the background.
// Later, when you see fit, you can call madVR_Find another time (with or
// without a timeout value) to pick up the search results.

// (3) asynchronous search II
// Call madVR_Find_Async (see below) to start a background network search.
// Whenever a new madVR instance is found (and also when a madVR instance is
// closed), a message will be sent to a window of your choice.
// When that message arrives, you can call madVR_Find with a 0 timeout value
// to fetch the updated list of found madVR instances.

type
  TMadVRInstances = record
    count : int64;
    items : array [0..0] of TMadVRInstance;
  end;
  PMadVRInstances = ^TMadVRInstances;

// Returns information records about all madVR instances found in the network
// The memory is allocated by madVR, don't allocate nor free it.
// The memory is only valid until the next madVR_Find call.
function madVR_Find (timeOut: dword = 1000) : PMadVRInstances;

// "madVR_Find_Async" starts a search for madVR instances, but instead of
// returning information directly, it will send a message to the specified
// "window" for every found madVR instance.
// After the search is complete, "madVR_Find_Async" will keep an eye open for
// newly started and closed down madVR instances and automatically report them
// to your "window", as well.
// In order to stop notification, call "madVR_Find_Async" with NULL parameters.
// wParam: 0 = a new madVR instance was detected
//         1 = a known madVR instance closed down
// lParam: "PMadVRInstance" of the new/closed madVR instance
//         do not free the PMadVRInstance, the memory is managed by madVR
function madVR_Find_Async (window: HWND; msg: dword) : boolean;

// ----------------------------------------------------------------------------
// connection to a specific madVR instance

// "madVR_Connect" connects you to the specified madVR instance.
// If a previous connection exists, it will be closed automatically.
// The "handle" and "instance" originate from a "madVR_Find(_Async)" search.
function madVR_ConnectToInstance (handle: THandle; instance: int64) : boolean;

// ----------------------------------------------------------------------------


// ============================================================================
// III. GUI LOCALIZATION
// ============================================================================

// Localize/customize all texts used by madVR_ConnectDialog.
procedure Localize_ConnectDialog (const title     : UnicodeString;   // madTPG selection...
                                  const text      : UnicodeString;   // Please make sure that madTPG is running on the target computer and then select it here:
                                  const columns   : UnicodeString;   // ip address|computer|pid|process|gpu|monitor|os
                                  const notListed : UnicodeString;   // The madTPG instance I'm looking for is not listed
                                  const select    : UnicodeString;   // Select
                                  const cancel    : UnicodeString    // Cancel
                                 );

// Localize/customize all texts used by madVR_IpAddressDialog.
// This is a dialog used internally by madVR_ConnectDialog.
procedure Localize_IpAddressDialog (const title        : UnicodeString;   // find madTPG instance...
                                    const text         : UnicodeString;   // Please enter the IP address of the computer on which madTPG is running:
                                    const connect      : UnicodeString;   // Connect
                                    const cancel       : UnicodeString;   // Cancel
                                    const warningTitle : UnicodeString;   // Warning...
                                    const warningText1 : UnicodeString;   // There doesn't seem to be any madTPG instance running on that computer.
                                    const warningText2 : UnicodeString    // The target computer does not react.\n\n
                                   );                                     // Please check if it's turned on and connected to the LAN.\n
                                                                          // You may also want to double check your firewall settings.


// ============================================================================
// deprecated APIs
// ============================================================================

function madVR_ConnectDialog (searchLan: boolean = true; parentWindow: HWND = 0) : boolean;
function madVR_BlindConnect (searchLan: boolean = true; timeOut: dword = 3000) : boolean;

// ----------------------------------------------------------------------------

implementation

// ----------------------------------------------------------------------------

var
  HcNetDll : HMODULE = 0;
  InitDone : boolean = false;
  InitSuccess : boolean = false;

var
  ConnectDialog                  : function (searchLan: bool; parentWindow: HWND) : bool; stdcall = nil;
  BlindConnect                   : function (searchLan: bool; timeOut: dword) : bool; stdcall = nil;
  ConnectToIp                    : function (ipAddress: PAnsiChar; timeOut: dword) : bool; stdcall = nil;
  ConnectEx                      : function (method1: integer; timeOut1: dword; method2: integer; timeOut2: dword; method3: integer; timeOut3: dword; method4: integer; timeOut4: dword; parentWindow: HWND) : bool; stdcall = nil;
  GetVersion                     : function (out version: dword) : bool; stdcall = nil;
  IsLocal                        : function () : bool; stdcall = nil;
  IsFullscreen                   : function () : bool; stdcall = nil;
  EnterFullscreen                : function () : bool; stdcall = nil;
  LeaveFullscreen                : function () : bool; stdcall = nil;
  IsFseModeEnabled               : function () : bool; stdcall = nil;
  EnableFseMode                  : function () : bool; stdcall = nil;
  DisableFseMode                 : function () : bool; stdcall = nil;
  GetWindowSize                  : function (out windowSize: TRect) : bool; stdcall = nil;
  SetWindowSize                  : function (const windowSize: TRect) : bool; stdcall = nil;
  IsMinimized                    : function () : bool; stdcall = nil;
  IsMaximized                    : function () : bool; stdcall = nil;
  IsRestored                     : function () : bool; stdcall = nil;
  Minimize                       : function () : bool; stdcall = nil;
  Maximize                       : function () : bool; stdcall = nil;
  Restore                        : function () : bool; stdcall = nil;
  IsStayOnTopButtonPressed       : function () : bool; stdcall = nil;
  IsUseFullscreenButtonPressed   : function () : bool; stdcall = nil;
  IsDisableOsdButtonPressed      : function () : bool; stdcall = nil;
  IsHdrButtonPressed             : function () : bool; stdcall = nil;
  SetStayOnTopButton             : function (pressed: bool) : bool; stdcall = nil;
  SetUseFullscreenButton         : function (pressed: bool) : bool; stdcall = nil;
  SetDisableOsdButton            : function (pressed: bool) : bool; stdcall = nil;
  SetHdrButton                   : function (pressed: bool) : bool; stdcall = nil;
  SetHdrMetadata                 : function (rx, ry, gx, gy, bx, by, wx, wy, minLum, maxLum, maxCLL, maxFALL: double) : bool; stdcall = nil;
  GetBlackAndWhiteLevel          : function (out blackLevel, whiteLevel: integer) : bool; stdcall = nil;
  GetSelected3dlut               : function (out thr3dlut: dword) : bool; stdcall = nil;
  SetSelected3dlut               : function (    thr3dlut: dword) : bool; stdcall = nil;
  Enable3dlut                    : function () : bool; stdcall = nil;
  Disable3dlut                   : function () : bool; stdcall = nil;
  GetDeviceGammaRamp             : function (ramp: pointer) : bool; stdcall = nil;
  SetDeviceGammaRamp             : function (ramp: pointer) : bool; stdcall = nil;
  SetOsdText                     : function (text: PWideChar) : bool; stdcall = nil;
  GetPatternConfig               : function (out patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth: integer) : bool; stdcall = nil;
  SetPatternConfig               : function (    patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth: integer) : bool; stdcall = nil;
  ShowProgressBar                : function (numberOfRgbMeasurements: integer) : bool; stdcall = nil;
  SetProgressBarPos              : function (currentPos, maxPos: integer) : bool; stdcall = nil;
  ShowRGB                        : function (r, g, b: double) : bool; stdcall = nil;
  ShowRGBEx                      : function (r, g, b, bgR, bgG, bgB: double) : bool; stdcall = nil;
  Convert3dlutFile               : function (eeColor3dlutFile, madVR3dlutFile: PWideChar; gamut: integer) : bool; stdcall = nil;
  ConvertHdr3dlutFile            : function (eeColor3dlutFile, madVR3dlutFile: PWideChar; gamut: integer; outputSdr: bool) : bool; stdcall = nil;
  Create3dlutFileFromArray65     : function (var lutData: TEeColor3dlut; madVR3dlutFile: PWideChar; gamut: integer) : bool; stdcall = nil;
  Create3dlutFileFromArray256    : function (var lutData:   TMadVR3dlut; madVR3dlutFile: PWideChar; gamut: integer) : bool; stdcall = nil;
  CreateHdr3dlutFileFromArray65  : function (var lutData: TEeColor3dlut; madVR3dlutFile: PWideChar; gamut: integer; outputSdr: bool) : bool; stdcall = nil;
  CreateHdr3dlutFileFromArray256 : function (var lutData:   TMadVR3dlut; madVR3dlutFile: PWideChar; gamut: integer; outputSdr: bool) : bool; stdcall = nil;
  Load3dlutFile                  : function (lutFile: PWideChar; saveToSettings: bool; gamut: integer) : bool; stdcall = nil;
  LoadHdr3dlutFile               : function (lutFile: PWideChar; saveToSettings: bool; gamut: integer; outputSdr: bool) : bool; stdcall = nil;
  Load3dlutFromArray65           : function (var lutData: TEeColor3dlut; saveToSettings: bool; gamut: integer) : bool; stdcall = nil;
  Load3dlutFromArray256          : function (var lutData:   TMadVR3dlut; saveToSettings: bool; gamut: integer) : bool; stdcall = nil;
  LoadHdr3dlutFromArray65        : function (var lutData: TEeColor3dlut; saveToSettings: bool; gamut: integer; outputSdr: bool) : bool; stdcall = nil;
  LoadHdr3dlutFromArray256       : function (var lutData:   TMadVR3dlut; saveToSettings: bool; gamut: integer; outputSdr: bool) : bool; stdcall = nil;
  Disconnect                     : function : bool; stdcall = nil;
  Quit                           : function : bool; stdcall = nil;
  Find                           : function (timeOut: dword = 3000) : PMadVRInstances; stdcall = nil;
  Find_Async                     : function (window: HWND; msg: dword) : bool; stdcall = nil;
  ConnectToInstance              : function (handle: THandle; instance: int64) : bool; stdcall = nil;
  LocConnectDialog               : procedure (title, text, columns, notListed, select, cancel: PWideChar); stdcall = nil;
  LocIpAddressDialog             : procedure (title, text, connect, cancel, warningTitle, warningText1, warningText2: PWideChar); stdcall = nil;

function Init : boolean;
var hk1  : HKEY;
    size : dword;
    us1  : UnicodeString;
    i1   : integer;
begin
  if not InitDone then begin
    {$ifdef WIN64}
      HcNetDll := LoadLibraryW('madHcNet64.dll');
    {$else}
      HcNetDll := LoadLibraryW('madHcNet32.dll');
    {$endif}
    if (HcNetDll = 0) and (RegOpenKeyExW(HKEY_CLASSES_ROOT, 'CLSID\{E1A8B82A-32CE-4B0D-BE0D-AA68C772E423}\InprocServer32', 0, KEY_QUERY_VALUE or $200 (*KEY_WOW64_32KEY*), hk1) = ERROR_SUCCESS) then begin
      size := MAX_PATH * 2 + 2;
      SetLength(us1, MAX_PATH);
      i1 := RegQueryValueExW(hk1, nil, nil, nil, pointer(us1), @size);
      if i1 = ERROR_MORE_DATA then begin
        SetLength(us1, size div 2 + 1);
        i1 := RegQueryValueExW(hk1, nil, nil, nil, pointer(us1), @size);
      end;
      if i1 = ERROR_SUCCESS then begin
        us1 := PWideChar(us1);
        for i1 := Length(us1) downto 1 do
          if us1[i1] = '\' then begin
            Delete(us1, i1 + 1, maxInt);
            break;
          end;
        {$ifdef WIN64}
          HcNetDll := LoadLibraryW(PWideChar(us1 + 'madHcNet64.dll'));
        {$else}
          HcNetDll := LoadLibraryW(PWideChar(us1 + 'madHcNet32.dll'));
        {$endif}
      end;
      RegCloseKey(hk1);
    end;
    ConnectDialog                  := GetProcAddress(HcNetDll, 'madVR_ConnectDialog'                 );
    BlindConnect                   := GetProcAddress(HcNetDll, 'madVR_BlindConnect'                  );
    ConnectToIp                    := GetProcAddress(HcNetDll, 'madVR_ConnectToIp'                   );
    ConnectEx                      := GetProcAddress(HcNetDll, 'madVR_ConnectEx'                     );
    GetVersion                     := GetProcAddress(HcNetDll, 'madVR_GetVersion'                    );
    IsLocal                        := GetProcAddress(HcNetDll, 'madVR_IsLocal'                       );
    IsFullscreen                   := GetProcAddress(HcNetDll, 'madVR_IsFullscreen'                  );
    EnterFullscreen                := GetProcAddress(HcNetDll, 'madVR_EnterFullscreen'               );
    LeaveFullscreen                := GetProcAddress(HcNetDll, 'madVR_LeaveFullscreen'               );
    IsFseModeEnabled               := GetProcAddress(HcNetDll, 'madVR_IsFseModeEnabled'              );
    EnableFseMode                  := GetProcAddress(HcNetDll, 'madVR_EnableFseMode'                 );
    DisableFseMode                 := GetProcAddress(HcNetDll, 'madVR_DisableFseMode'                );
    GetWindowSize                  := GetProcAddress(HcNetDll, 'madVR_GetWindowSize'                 );
    SetWindowSize                  := GetProcAddress(HcNetDll, 'madVR_SetWindowSize'                 );
    IsMinimized                    := GetProcAddress(HcNetDll, 'madVR_IsMinimized'                   );
    IsMaximized                    := GetProcAddress(HcNetDll, 'madVR_IsMaximized'                   );
    IsRestored                     := GetProcAddress(HcNetDll, 'madVR_IsRestored'                    );
    Minimize                       := GetProcAddress(HcNetDll, 'madVR_Minimize'                      );
    Maximize                       := GetProcAddress(HcNetDll, 'madVR_Maximize'                      );
    Restore                        := GetProcAddress(HcNetDll, 'madVR_Restore'                       );
    IsStayOnTopButtonPressed       := GetProcAddress(HcNetDll, 'madVR_IsStayOnTopButtonPressed'      );
    IsUseFullscreenButtonPressed   := GetProcAddress(HcNetDll, 'madVR_IsUseFullscreenButtonPressed'  );
    IsDisableOsdButtonPressed      := GetProcAddress(HcNetDll, 'madVR_IsDisableOsdButtonPressed'     );
    IsHdrButtonPressed             := GetProcAddress(HcNetDll, 'madVR_IsHdrButtonPressed'            );
    SetStayOnTopButton             := GetProcAddress(HcNetDll, 'madVR_SetStayOnTopButton'            );
    SetUseFullscreenButton         := GetProcAddress(HcNetDll, 'madVR_SetUseFullscreenButton'        );
    SetDisableOsdButton            := GetProcAddress(HcNetDll, 'madVR_SetDisableOsdButton'           );
    SetHdrButton                   := GetProcAddress(HcNetDll, 'madVR_SetHdrButton'                  );
    SetHdrMetadata                 := GetProcAddress(HcNetDll, 'madVR_SetHdrMetadata'                );
    GetBlackAndWhiteLevel          := GetProcAddress(HcNetDll, 'madVR_GetBlackAndWhiteLevel'         );
    GetSelected3dlut               := GetProcAddress(HcNetDll, 'madVR_GetSelected3dlut'              );
    SetSelected3dlut               := GetProcAddress(HcNetDll, 'madVR_SetSelected3dlut'              );
    Enable3dlut                    := GetProcAddress(HcNetDll, 'madVR_Enable3dlut'                   );
    Disable3dlut                   := GetProcAddress(HcNetDll, 'madVR_Disable3dlut'                  );
    GetDeviceGammaRamp             := GetProcAddress(HcNetDll, 'madVR_GetDeviceGammaRamp'            );
    SetDeviceGammaRamp             := GetProcAddress(HcNetDll, 'madVR_SetDeviceGammaRamp'            );
    SetOsdText                     := GetProcAddress(HcNetDll, 'madVR_SetOsdText'                    );
    GetPatternConfig               := GetProcAddress(HcNetDll, 'madVR_GetPatternConfig'              );
    SetPatternConfig               := GetProcAddress(HcNetDll, 'madVR_SetPatternConfig'              );
    ShowProgressBar                := GetProcAddress(HcNetDll, 'madVR_ShowProgressBar'               );
    SetProgressBarPos              := GetProcAddress(HcNetDll, 'madVR_SetProgressBarPos'             );
    ShowRGB                        := GetProcAddress(HcNetDll, 'madVR_ShowRGB'                       );
    ShowRGBEx                      := GetProcAddress(HcNetDll, 'madVR_ShowRGBEx'                     );
    Convert3dlutFile               := GetProcAddress(HcNetDll, 'madVR_Convert3dlutFile'              );
    ConvertHdr3dlutFile            := GetProcAddress(HcNetDll, 'madVR_ConvertHdr3dlutFile'           );
    Create3dlutFileFromArray65     := GetProcAddress(HcNetDll, 'madVR_Create3dlutFileFromArray65'    );
    Create3dlutFileFromArray256    := GetProcAddress(HcNetDll, 'madVR_Create3dlutFileFromArray256'   );
    CreateHdr3dlutFileFromArray65  := GetProcAddress(HcNetDll, 'madVR_CreateHdr3dlutFileFromArray65' );
    CreateHdr3dlutFileFromArray256 := GetProcAddress(HcNetDll, 'madVR_CreateHdr3dlutFileFromArray256');
    Load3dlutFile                  := GetProcAddress(HcNetDll, 'madVR_Load3dlutFile'                 );
    LoadHdr3dlutFile               := GetProcAddress(HcNetDll, 'madVR_LoadHdr3dlutFile'              );
    Load3dlutFromArray65           := GetProcAddress(HcNetDll, 'madVR_Load3dlutFromArray65'          );
    Load3dlutFromArray256          := GetProcAddress(HcNetDll, 'madVR_Load3dlutFromArray256'         );
    LoadHdr3dlutFromArray65        := GetProcAddress(HcNetDll, 'madVR_LoadHdr3dlutFromArray65'       );
    LoadHdr3dlutFromArray256       := GetProcAddress(HcNetDll, 'madVR_LoadHdr3dlutFromArray256'      );
    Disconnect                     := GetProcAddress(HcNetDll, 'madVR_Disconnect'                    );
    Quit                           := GetProcAddress(HcNetDll, 'madVR_Quit'                          );
    Find                           := GetProcAddress(HcNetDll, 'madVR_Find'                          );
    Find_Async                     := GetProcAddress(HcNetDll, 'madVR_Find_Async'                    );
    ConnectToInstance              := GetProcAddress(HcNetDll, 'madVR_ConnectToInstance'             );
    LocConnectDialog               := GetProcAddress(HcNetDll, 'Localize_ConnectDialog'              );
    LocIpAddressDialog             := GetProcAddress(HcNetDll, 'Localize_IpAddressDialog'            );
    InitSuccess := (@ConnectDialog      <> nil) and
                   (@BlindConnect       <> nil) and
                   (@ConnectToIp        <> nil) and
                   (@Disable3dlut       <> nil) and
                   (@SetDeviceGammaRamp <> nil) and
                   (@SetOsdText         <> nil) and
                   (@ShowProgressBar    <> nil) and
                   (@ShowRGB            <> nil) and
                   (@Disconnect         <> nil) and
                   (@Find_Async         <> nil) and
                   (@LocConnectDialog   <> nil) and
                   (@LocIpAddressDialog <> nil);
    InitDone := true;
  end;
  result := InitSuccess;
end;

// ----------------------------------------------------------------------------

function madVR_ConnectDialog(searchLan: boolean = true; parentWindow: HWND = 0) : boolean;
begin
  result := Init and ConnectDialog(searchLan, parentWindow);
end;

function madVR_BlindConnect(searchLan: boolean = true; timeOut: dword = 3000) : boolean;
begin
  result := Init and BlindConnect(searchLan, timeOut);
end;

function madVR_ConnectToIp(const ipAddress: AnsiString; timeOut: dword = 1000) : boolean;
begin
  result := Init and ConnectToIp(PAnsiChar(ipAddress), timeOut);
end;

function madVR_Connect(method1: integer = CM_ConnectToLocalInstance; timeOut1: dword = 1000;
                       method2: integer = CM_ConnectToLanInstance;   timeOut2: dword = 3000;
                       method3: integer = CM_ShowListDialog;         timeOut3: dword = INFINITE;
                       method4: integer = CM_Fail;                   timeOut4: dword = 0;
                       parentWindow: HWND = 0) : boolean;
begin
  result := Init and (@ConnectEx <> nil) and ConnectEx(method1, timeOut1, method2, timeOut2, method3, timeOut3, method4, timeOut4, parentWindow);
end;

function madVR_GetVersion(out version: dword) : boolean;
begin
  result := Init and (@GetVersion <> nil) and GetVersion(version);
end;

function madVR_IsLocal() : boolean;
begin
  result := Init and (@IsLocal <> nil) and IsLocal();
end;

function madVR_IsFullscreen : boolean;
begin
  result := Init and (@IsFullscreen <> nil) and IsFullscreen();
end;

function madVR_EnterFullscreen() : boolean;
begin
  result := Init and (@EnterFullscreen <> nil) and EnterFullscreen;
end;

function madVR_LeaveFullscreen() : boolean;
begin
  result := Init and (@LeaveFullscreen <> nil) and LeaveFullscreen;
end;

function madVR_IsFseModeEnabled () : boolean;
begin
  result := Init and (@IsFseModeEnabled <> nil) and IsFseModeEnabled;
end;

function madVR_EnableFseMode () : boolean;
begin
  result := Init and (@EnableFseMode <> nil) and EnableFseMode;
end;

function madVR_DisableFseMode () : boolean;
begin
  result := Init and (@DisableFseMode <> nil) and DisableFseMode;
end;

function madVR_GetWindowSize(out windowSize: TRect) : boolean;
begin
  result := Init and (@GetWindowSize <> nil) and GetWindowSize(windowSize);
end;

function madVR_SetWindowSize(const windowSize: TRect) : boolean;
begin
  result := Init and (@SetWindowSize <> nil) and SetWindowSize(windowSize);
end;

function madVR_IsMinimized : boolean;
begin
  result := Init and (@IsMinimized <> nil) and IsMinimized();
end;

function madVR_IsMaximized : boolean;
begin
  result := Init and (@IsMaximized <> nil) and IsMaximized();
end;

function madVR_IsRestored : boolean;
begin
  result := Init and (@IsRestored <> nil) and IsRestored();
end;

function madVR_Minimize() : boolean;
begin
  result := Init and (@Minimize <> nil) and Minimize;
end;

function madVR_Maximize() : boolean;
begin
  result := Init and (@Maximize <> nil) and Maximize;
end;

function madVR_Restore() : boolean;
begin
  result := Init and (@Restore <> nil) and Restore;
end;

function madVR_IsStayOnTopButtonPressed() : boolean;
begin
  result := Init and (@IsStayOnTopButtonPressed <> nil) and IsStayOnTopButtonPressed;
end;

function madVR_IsUseFullscreenButtonPressed() : boolean;
begin
  result := Init and (@IsUseFullscreenButtonPressed <> nil) and IsUseFullscreenButtonPressed;
end;

function madVR_IsDisableOsdButtonPressed() : boolean;
begin
  result := Init and (@IsDisableOsdButtonPressed <> nil) and IsDisableOsdButtonPressed;
end;

function madVR_IsHdrButtonPressed() : boolean;
begin
  result := Init and (@IsHdrButtonPressed <> nil) and IsHdrButtonPressed;
end;

function madVR_SetStayOnTopButton(pressed: boolean) : boolean;
begin
  result := Init and (@SetStayOnTopButton <> nil) and SetStayOnTopButton(pressed);
end;

function madVR_SetUseFullscreenButton(pressed: boolean) : boolean;
begin
  result := Init and (@SetUseFullscreenButton <> nil) and SetUseFullscreenButton(pressed);
end;

function madVR_SetDisableOsdButton(pressed: boolean) : boolean;
begin
  result := Init and (@SetDisableOsdButton <> nil) and SetDisableOsdButton(pressed);
end;

function madVR_SetHdrButton(pressed: boolean) : boolean;
begin
  result := Init and (@SetHdrButton <> nil) and SetHdrButton(pressed);
end;

function madVR_SetHdrMetadata(rx, ry, gx, gy, bx, by, wx, wy, minLum, maxLum, maxCLL, maxFALL: double) : boolean;
begin
  result := Init and (@SetHdrMetadata <> nil) and SetHdrMetadata(rx, ry, gx, gy, bx, by, wx, wy, minLum, maxLum, maxCLL, maxFALL);
end;

function madVR_GetBlackAndWhiteLevel(out blackLevel, whiteLevel: integer) : boolean;
begin
  result := Init and (@GetBlackAndWhiteLevel <> nil) and GetBlackAndWhiteLevel(blackLevel, whiteLevel);
  if (not result) or (blackLevel >= whiteLevel) then
  begin
    blackLevel := 0;
    whiteLevel := 255;
  end;
end;

function madVR_GetSelected3dlut(out thr3dlut: dword) : boolean;
begin
  result := Init and (@GetSelected3dlut <> nil) and GetSelected3dlut(thr3dlut);
end;

function madVR_SetSelected3dlut(thr3dlut: dword) : boolean;
begin
  result := Init and (@SetSelected3dlut <> nil) and SetSelected3dlut(thr3dlut);
end;

function madVR_Enable3dlut() : boolean;
begin
  result := Init and Enable3dlut;
end;

function madVR_Disable3dlut() : boolean;
begin
  result := Init and Disable3dlut;
end;

function madVR_GetDeviceGammaRamp(ramp: pointer) : boolean;
begin
  result := Init and (@GetDeviceGammaRamp <> nil) and GetDeviceGammaRamp(ramp);
end;

function madVR_SetDeviceGammaRamp(ramp: pointer) : boolean;
begin
  result := Init and SetDeviceGammaRamp(ramp);
end;

function madVR_SetOsdText(const text: UnicodeString) : boolean;
begin
  result := Init and SetOsdText(PWideChar(text));
end;

function madVR_GetPatternConfig(out patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth: integer) : boolean;
begin
  result := Init and (@GetPatternConfig <> nil) and GetPatternConfig(patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth);
end;

function madVR_SetPatternConfig(patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth: integer) : boolean;
begin
  result := Init and (@SetPatternConfig <> nil) and SetPatternConfig(patternAreaInPercent, backgroundLevelInPercent, backgroundMode, blackBorderWidth);
end;

function madVR_ShowProgressBar(numberOfRgbMeasurements: integer) : boolean;
begin
  result := Init and ShowProgressBar(numberOfRgbMeasurements);
end;

function madVR_SetProgressBarPos(currentPos, maxPos: integer) : boolean;
begin
  result := Init and (@SetProgressBarPos <> nil) and SetProgressBarPos(currentPos, maxPos);
end;

function madVR_ShowRGB(const r, g, b: double) : boolean;
begin
  result := Init and ShowRGB(r, g, b);
end;

function madVR_ShowRGBEx(const r, g, b, bgR, bgG, bgB: double) : boolean;
begin
  result := Init and
            ( ((@ShowRGBEx <> nil) and ShowRGBEx(r, g, b, bgR, bgG, bgB)) or
              ((@ShowRGBEx =  nil) and ShowRGB  (r, g, b)) );
end;

function madVR_Convert3dlutFile(const eeColor3dlutFile, madVR3dlutFile: UnicodeString; gamut: integer) : boolean;
begin
  result := Init and (@Convert3dlutFile <> nil) and Convert3dlutFile(PWideChar(eeColor3dlutFile), PWideChar(madVR3dlutFile), gamut);
end;

function madVR_ConvertHdr3dlutFile(const eeColor3dlutFile, madVR3dlutFile: UnicodeString; gamut: integer; outputSdr: boolean) : boolean;
begin
  result := Init and (@ConvertHdr3dlutFile <> nil) and ConvertHdr3dlutFile(PWideChar(eeColor3dlutFile), PWideChar(madVR3dlutFile), gamut, outputSdr);
end;

function madVR_Create3dlutFileFromArray65(var lutData: TEeColor3dlut; const madVR3dlutFile: UnicodeString; gamut: integer) : boolean;
begin
  result := Init and (@Create3dlutFileFromArray65 <> nil) and Create3dlutFileFromArray65(lutData, PWideChar(madVR3dlutFile), gamut);
end;

function madVR_Create3dlutFileFromArray256(var lutData: TMadVR3dlut; const madVR3dlutFile: UnicodeString; gamut: integer) : boolean;
begin
  result := Init and (@Create3dlutFileFromArray256 <> nil) and Create3dlutFileFromArray256(lutData, PWideChar(madVR3dlutFile), gamut);
end;

function madVR_CreateHdr3dlutFileFromArray65(var lutData: TEeColor3dlut; const madVR3dlutFile: UnicodeString; gamut: integer; outputSdr: boolean) : boolean;
begin
  result := Init and (@CreateHdr3dlutFileFromArray65 <> nil) and CreateHdr3dlutFileFromArray65(lutData, PWideChar(madVR3dlutFile), gamut, outputSdr);
end;

function madVR_CreateHdr3dlutFileFromArray256(var lutData: TMadVR3dlut; const madVR3dlutFile: UnicodeString; gamut: integer; outputSdr: boolean) : boolean;
begin
  result := Init and (@CreateHdr3dlutFileFromArray256 <> nil) and CreateHdr3dlutFileFromArray256(lutData, PWideChar(madVR3dlutFile), gamut, outputSdr);
end;

function madVR_Load3dlutFile(const lutFile: UnicodeString; saveToSettings: boolean; gamut: integer) : boolean;
begin
  result := Init and (@Load3dlutFile <> nil) and Load3dlutFile(PWideChar(lutFile), saveToSettings, gamut);
end;

function madVR_LoadHdr3dlutFile(const lutFile: UnicodeString; saveToSettings: boolean; gamut: integer; outputSdr: boolean) : boolean;
begin
  result := Init and (@LoadHdr3dlutFile <> nil) and LoadHdr3dlutFile(PWideChar(lutFile), saveToSettings, gamut, outputSdr);
end;

function madVR_Load3dlutFromArray65(var lutData: TEeColor3dlut; saveToSettings: boolean; gamut: integer) : boolean;
begin
  result := Init and (@Load3dlutFromArray65 <> nil) and Load3dlutFromArray65(lutData, saveToSettings, gamut);
end;

function madVR_Load3dlutFromArray256(var lutData: TMadVR3dlut; saveToSettings: boolean; gamut: integer) : boolean;
begin
  result := Init and (@Load3dlutFromArray256 <> nil) and Load3dlutFromArray256(lutData, saveToSettings, gamut);
end;

function madVR_LoadHdr3dlutFromArray65(var lutData: TEeColor3dlut; saveToSettings: boolean; gamut: integer; outputSdr: boolean) : boolean;
begin
  result := Init and (@LoadHdr3dlutFromArray65 <> nil) and LoadHdr3dlutFromArray65(lutData, saveToSettings, gamut, outputSdr);
end;

function madVR_LoadHdr3dlutFromArray256(var lutData: TMadVR3dlut; saveToSettings: boolean; gamut: integer; outputSdr: boolean) : boolean;
begin
  result := Init and (@LoadHdr3dlutFromArray256 <> nil) and LoadHdr3dlutFromArray256(lutData, saveToSettings, gamut, outputSdr);
end;

function madVR_Disconnect : boolean;
begin
  result := Init and Disconnect;
end;

function madVR_Quit : boolean;
begin
  result := Init and (@Quit <> nil) and Quit;
  if not result then
    madVR_Disconnect;
end;

function madVR_Find(timeOut: dword = 1000) : PMadVRInstances;
begin
  if Init and (@Find <> nil) then
    result := Find(timeOut)
  else
    result := nil;
end;

function madVR_Find_Async(window: HWND; msg: dword) : boolean;
begin
  result := Init and Find_Async(window, msg);
end;

function madVR_ConnectToInstance(handle: THandle; instance: int64) : boolean;
begin
  result := Init and (@ConnectToInstance <> nil) and ConnectToInstance(handle, instance);
end;

function madVR_IsAvailable : boolean;
begin
  result := Init;
end;                                                 

procedure Localize_ConnectDialog(const title, text, columns, notListed, select, cancel: UnicodeString);
begin
  if Init then
    LocConnectDialog(PWideChar(title), PWideChar(text), PWideChar(columns), PWideChar(notListed), PWideChar(select), PWideChar(cancel));
end;

procedure Localize_IpAddressDialog(const title, text, connect, cancel, warningTitle, warningText1, warningText2: UnicodeString);
begin
  if Init then
    LocIpAddressDialog(PWideChar(title), PWideChar(text), PWideChar(connect), PWideChar(cancel), PWideChar(warningTitle), PWideChar(warningText1), PWideChar(warningText2));
end;

// ----------------------------------------------------------------------------

end.
