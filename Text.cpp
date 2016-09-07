#include "engine.h"
#include <string.h>
#include <math.h>

int tR,bR;
int tG,bG;
int tB,bB;

BOOL Engine_Graphics::WriteS(IDirectDrawSurface *Oberflaeche,int x,int y,char *txt,BOOL Transparent)
{

	if (FAILED(Oberflaeche->GetDC(&info.hdc)))
	{
		return Fail("Engine::WriteS = GetDC");
	}

	SetBkColor( info.hdc, RGB( bR, bG, bB ) );
	SetTextColor( info.hdc, RGB( tR, tG, tB ) );
	SetTextAlign( info.hdc, TA_CENTER );
	if (Transparent) 
	{
		SetBkMode(info.hdc,TRANSPARENT);
	}
	SelectObject(info.hdc,CreateFont(fntname,0,0,150,TRUE));
	TextOut( info.hdc, x, y, txt, lstrlen( txt ) );

    if (FAILED(Oberflaeche->ReleaseDC( info.hdc )))
	{
		return Fail("Engine::WriteS = ReleaseDC");
	}
return TRUE;
}

void Engine_Graphics::WriteSquick(IDirectDrawSurface *Oberflaeche,int x,int y,char *txt)
{
    Oberflaeche->GetDC(&info.hdc );
    SetTextColor(info.hdc ,RGB(tR,tG,tB));
	SetBkMode(info.hdc,TRANSPARENT);
	TextOut( info.hdc , x, y, txt, lstrlen( txt ) );
    Oberflaeche->ReleaseDC( info.hdc  );
}

HFONT Engine_Graphics::CreateFont (char * szFaceName, int iDeciPtHeight,
                    int iDeciPtWidth, int iAttributes, BOOL fLogRes)
     {
     FLOAT      cxDpi, cyDpi ;
     HFONT      hFont ;
     LOGFONT    lf ;
     POINT      pt ;
     TEXTMETRIC tm ;

     SaveDC (info.hdc) ;

     SetGraphicsMode (info.hdc, GM_ADVANCED) ;
     ModifyWorldTransform (info.hdc, NULL, MWT_IDENTITY) ;
     SetViewportOrgEx (info.hdc, 0, 0, NULL) ;
     SetWindowOrgEx   (info.hdc, 0, 0, NULL) ;

     if (fLogRes)
          {
          cxDpi = (FLOAT) GetDeviceCaps (info.hdc, LOGPIXELSX) ;
          cyDpi = (FLOAT) GetDeviceCaps (info.hdc, LOGPIXELSY) ;
          }
     else
          {
          cxDpi = (FLOAT) (25.4 * GetDeviceCaps (info.hdc , HORZRES) /
                                  GetDeviceCaps (info.hdc , HORZSIZE)) ;

          cyDpi = (FLOAT) (25.4 * GetDeviceCaps (info.hdc , VERTRES) /
                                  GetDeviceCaps (info.hdc , VERTSIZE)) ;
          }

     pt.x = (int) (iDeciPtWidth  * cxDpi / 72) ;
     pt.y = (int) (iDeciPtHeight * cyDpi / 72) ;

     DPtoLP (info.hdc, &pt, 1) ;

     lf.lfHeight         = - (int) (fabs (pt.y) / 10.0 + 0.5) ;
     lf.lfWidth          = 0 ;
     lf.lfEscapement     = 0 ;
     lf.lfOrientation    = 0 ;
     lf.lfWeight         = 0 ;
     lf.lfItalic         = 0 ;
     lf.lfUnderline      = 0 ;
     lf.lfStrikeOut      = 0 ;
     lf.lfCharSet        = 0 ;
     lf.lfOutPrecision   = 0 ;
     lf.lfClipPrecision  = 0 ;
     lf.lfQuality        = 0 ;
     lf.lfPitchAndFamily = 0 ;

     strcpy (lf.lfFaceName, szFaceName) ;

     hFont = CreateFontIndirect (&lf) ;

     if (iDeciPtWidth != 0)
          {
          hFont = (HFONT) SelectObject (info.hdc, hFont) ;

          GetTextMetrics (info.hdc, &tm) ;

          DeleteObject (SelectObject (info.hdc, hFont)) ;

          lf.lfWidth = (int) (tm.tmAveCharWidth *
                              fabs (pt.x) / fabs (pt.y) + 0.5) ;

          hFont = CreateFontIndirect (&lf) ;
          }

     RestoreDC (info.hdc, -1) ;

     return hFont ;
}

void Engine_Graphics::SetFontName(char*Fontname)
{
	fntname = Fontname;
}
