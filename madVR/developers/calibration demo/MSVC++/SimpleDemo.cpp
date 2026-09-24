#include <windows.h>
#include "..\\..\\interfaces\\madTPG.h"

// ***************************************************************

double GrayRamp[11] = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};

void MeasureTestPattern()
{
  // replace "Sleep()" with your measurement code
  Sleep(1000);
}

int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
  if (!madVR_IsAvailable())
    MessageBox(0, "madVR network dll not found.", "Error", MB_ICONERROR);
  else
    if (madVR_Connect())
    {
      if (madVR_IsLocal())
      {
        // If the madTPG instance is running on our own PC, the user might
        // have minimized the madTPG window, in order to access/start the
        // calibration software. So we restore the madTPG window, just to be
        // safe.
        madVR_Restore();
        Sleep(500);
      }
      madVR_SetDeviceGammaRamp();
      madVR_Disable3dlut();
      madVR_SetOsdText(L"measuring display, please wait...");
      madVR_ShowProgressBar(_countof(GrayRamp));
      int black, white;
      madVR_GetBlackAndWhiteLevel(&black, &white);
      for (int i1 = 0; i1 < _countof(GrayRamp); i1++)
      {
        // We round the measure points to the output range to make sure madTPG
        // doesn't dither. This isn't strictly needed, but measuring
        // non-dithered test patterns might produce slightly better results.
        double gray = (double) ((int) (GrayRamp[i1] * (white - black) + 0.5)) / (white - black);
        if (!madVR_ShowRGB(gray, gray, gray))
        {
          MessageBox(0, "Test pattern failure.", "Error", MB_ICONERROR);
          break;
        }
        // sleep a bit to work around display input latency
        Sleep(50);
        MeasureTestPattern();
      }
      madVR_Disconnect();
    }
    else
      MessageBox(0, "No madTPG instance found.", "Error", MB_ICONERROR);

  return true;
}
