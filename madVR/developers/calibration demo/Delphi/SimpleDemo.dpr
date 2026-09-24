program SimpleDemo;

uses
  Windows,
  SysUtils,
  madTPG in '..\..\interfaces\madTPG.pas';

{$R *.res}

var GrayRamp : array [0..10] of double = (0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0);

procedure MeasureTestPattern;
begin
  // replace "Sleep()" with your measurement code
  Sleep(3000);
end;

var i1    : integer;
    black : integer;
    white : integer;
    gray  : double;
begin
  if not madVR_IsAvailable then
    MessageBox(0, 'madVR network dll not found.', 'Error', MB_ICONERROR)
  else
    if madVR_Connect then
    begin
      if madVR_IsLocal then
      begin
        // If the madTPG instance is running on our own PC, the user might
        // have minimized the madTPG window, in order to access/start the
        // calibration software. So we restore the madTPG window, just to be
        // safe.
        madVR_Restore;
        Sleep(500);
      end;
      madVR_SetDeviceGammaRamp();
      madVR_Disable3dlut();
      madVR_SetOsdText('measuring display, please wait...');
      madVR_ShowProgressBar(length(GrayRamp));
      madVR_GetBlackAndWhiteLevel(black, white);
      for i1 := 0 to high(GrayRamp) do
      begin
        // We round the measure points to the output range to make sure madTPG
        // doesn't dither. This isn't strictly needed, but measuring
        // non-dithered test patterns might produce slightly better results.
        gray := round(GrayRamp[i1] * (white - black)) / (white - black);
        if not madVR_ShowRGB(gray, gray, gray) then
        begin
          MessageBox(0, 'Test pattern failure.', 'Error', MB_ICONERROR);
          break;
        end;
        // sleep a bit to work around display input latency
        Sleep(50);
        MeasureTestPattern;
      end;
      madVR_Disconnect;
    end
    else
      MessageBox(0, 'No madTPG instance found.', 'Error', MB_ICONERROR);
end.
