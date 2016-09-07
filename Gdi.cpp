#include "engine.h"


HBRUSH Farbe;

BOOL Engine_Graphics::DrawRect(IDirectDrawSurface *Oberflaeche,int x1,
			  int y1,int x2,int y2,BOOL filled)
{ 
	if (FAILED(Oberflaeche->GetDC(&info.hdc)))
	{
		return Fail("Engine::DrawRect = GetDC");
	}
    SetBkMode(info.hdc,TRANSPARENT);
	//Farbe = CreateSolidBrush(RGB(tR,tG,tB));
    //SetDCBrushColor(info.hdc,RGB(0,0,255));
	//SelectObject( info.hdc, GetStockObject(DC_BRUSH));
    Rectangle( info.hdc, x1, y1, x2, y2 );
    if (FAILED(Oberflaeche->ReleaseDC(info.hdc)))
	{
		return Fail("Engine::DrawRect = ReleaseDC");
	}

return TRUE;
}      

BOOL Engine_Graphics::DrawEllipse(IDirectDrawSurface *Oberflaeche, int x1,
				int y1,int x2,int y2)
{
	if (FAILED(Oberflaeche->GetDC(&info.hdc)))
	{
		return Fail("Engine::DrawEllipse = GetDC");
	}
	Farbe = CreateSolidBrush(RGB(tR,tG,tB));
	SelectObject( info.hdc, Farbe );
    Ellipse( info.hdc, x1, y1, x2, y2 );
	if (FAILED(Oberflaeche->ReleaseDC(info.hdc)))
	{
		return Fail("Engine::DrawEllipse = ReleaseDC");
	}
return TRUE;
}

void Engine_Graphics::SetColor(int R,int G,int B)
{
	tR = R;
    tG = G;
	tB = B;
}


void Engine_Graphics::SetBackgroundColor(int R,int G,int B)
{
	bR = R;
	bG = G;
	bB = B;
}

BOOL Engine_Graphics::DrawPolygon(IDirectDrawSurface *Oberflaeche,const POINT Ecken,int WievieleEcken)
{
	if (FAILED(Oberflaeche->GetDC(&info.hdc)))
	{
		return Fail("Engine::DrawEllipse = GetDC");
	}
	Farbe = CreateSolidBrush(RGB(tR,tG,tB));
	SelectObject( info.hdc, Farbe );
    Polygon(info.hdc,&Ecken,WievieleEcken);
	if (FAILED(Oberflaeche->ReleaseDC(info.hdc)))
	{
		return Fail("Engine::DrawEllipse = ReleaseDC");
	}
return TRUE;
}
