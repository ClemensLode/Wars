

#include <windows.h>
#include <windowsx.h>
#include <windef.h>
#include <ddraw.h>
#include <wingdi.h>
#include <mmsystem.h>
#include <stdio.h>
#include <dinput.h>

#ifndef _ENGINE_H_
#define _ENGINE_H_


typedef struct 
{
	BOOL HW_BLT;
	BOOL HW_CAN3D;
	BOOL HW_CANALPHA;
	BOOL HW_BLTSTRETCH;
	BOOL HW_CANOVRLAY;
	BOOL HW_STEREO;
	BOOL HW_ZBLIT;
	BOOL HW_COLORKEY;
	BOOL HW_HARDWARE;
	BOOL HW_CLIP;
}DD_DRIVERINFO;

typedef struct 
{
	BOOL HW_MSCERTIFIED;
	BOOL HW_PB8;
	BOOL HW_PB16;
	BOOL HW_SB8;
	BOOL HW_SB16;
    BOOL HW_PMONO;
	BOOL HW_PSTEREO;
	BOOL HW_SMONO;
	BOOL HW_SSTEREO;
	BOOL HW_EMULDRIVER;
}DS_DRIVERINFO;

class Engine_Info
{
public:
	LPSTR AppName;

	LPSTR WindowTitle;

	IDirectDraw *lpDD;
	
	IDirectInput *lpDI;
	
	HWND hwnd;
	
	HDC  hdc;
	
	BOOL DoWindowStuffFullscreen(HINSTANCE hInstance,WNDPROC WindowProc,int nCmdShow);

	BOOL DoWindowStuff(HINSTANCE hInstance,WNDPROC WindowProc,int nCmdShow,LPCSTR Menu);

	HINSTANCE hInstance;

    void EndApp();
};


typedef struct
{
	BOOL MHORIZONTAL;
	
	BOOL MVERTIKAL;
    
	BOOL ROTATION;
	
	BOOL NORMAL;
	
	DWORD RotationAngle;
}EFFECTS;

class Engine_Graphics
{
public :

Engine_Info info;

LPDIRECTDRAWSURFACE Primaer;

LPDIRECTDRAWSURFACE BackBuffer;

DDSURFACEDESC ddsd;

LPDIRECTDRAWCLIPPER Clipper;

BOOL LoadBitmap(LPDIRECTDRAWSURFACE lpDDS, LPSTR szImage);

BOOL Flip();

BOOL InitDirectDraw(DWORD x,DWORD y,DWORD bpp,BOOL Fullscreen,BOOL UseDevice);

void ReleaseObjects();

BOOL Fail(char *szMsg);

BOOL NewDisplayMode(int x,int y,int bpp);

BOOL WriteS(IDirectDrawSurface *Oberflaeche,int x,int y,char*txt,BOOL Transparent);

void WriteSquick(IDirectDrawSurface *Oberflaeche,int x,int y,char *txt);

void SetBackgroundColor(int R,int G,int B);

void SetColor(int R,int G,int B);

BOOL DrawRect(IDirectDrawSurface *Oberflaeche,int x1,int y1,int x2,int y2);

BOOL DrawEllipse(IDirectDrawSurface *Oberflaeche,int x1,int y1,int x2,int y2);

void PutPixel(IDirectDrawSurface *Oberflaeche, int x,int y);

BOOL DrawPolygon(IDirectDrawSurface *Oberflaeche,const POINT Ecken,int WievieleEcken);

void BufferClear(IDirectDrawSurface *surf,int r,int g,int b);

void SetFontName(char*FontName);
    int resx,resy;
BOOL CreateSurface(IDirectDrawSurface *,DWORD width,DWORD height);

BOOL DeviceDialog();

void CopySurface(DWORD width,DWORD height,IDirectDrawSurface *Source,
								  IDirectDrawSurface *Target);
void CheckHardware(DD_DRIVERINFO dd_dinf);

protected:
    GUID device_guid;

	DDCAPS ddcaps;

	DDSCAPS ddscaps;
	
	DDBLTFX ddbltfx;
	
	DDPIXELFORMAT ddpf;
	
	WNDCLASS       wc;
    
	char*fntname;
	
	int tR;
    
	int tG;
    
	int tB;
	
	int bR;
	
	int bG;
	
	int bB;
HFONT CreateFont (char *szFaceName, int iDeciPtHeight,
                  int iDeciPtWidth, int iAttributes, BOOL fLogRes) ;
LPDIRECTDRAWPALETTE lpDDPalette;
    Engine_Info inf;
};

class Image
{
public:
	
	Engine_Graphics En_Graph;

	LPSTR szImage;
	
	IDirectDrawSurface *Quelle;
	
	IDirectDrawSurface *Ziel;
	
	int xPos;
	
	int yPos;
    
	BOOL DrawSprite(RECT QuellPosition,int x,int y);
    
	BOOL DrawSpriteFX(RECT QuellPosition,RECT ZielPosition,EFFECTS effects);
	
	BOOL CreateSprite(DWORD Breite,DWORD Hoehe);
	
	void SetColorKey(int r,int g,int b);
    
	void ReleaseSprite();
    
	BOOL PrepareForTranslucent();
    
	BOOL DrawSpriteTranslucent(RECT QuellPosition, DWORD x,DWORD y);
protected:
	
	DDBLTFX ddbltfx;
	
	DWORD trans_height,trans_width;
	
	DWORD dwGreen;
    
	DWORD dwBlue;
	
	DDCAPS         ddcaps;
    
	DDPIXELFORMAT  ddpf;
    
	DDSURFACEDESC  ddsd;
    
	BOOL LoadSprite(LPDIRECTDRAWSURFACE lpDDS, LPSTR szImage);
    
	BOOL Fail(char *szMsg);
    HWND spr_hwnd; 
    
	LPDIRECTDRAW spr_dd;
	
	int c_r,c_g,c_b;
    
	IDirectDrawSurface *trans_surf;
	
	RECT pix_pos,copy_rect;

	void DrawArray1(int y);

	void DrawArray2(int y);
};



class Engine_Input
{
public:
	
	Engine_Info info;
	
	BOOL InitDirectInput();
	
	BOOL InstallKeyboard();
	
	BOOL InstallMouse();

	void ReleaseObjects();

    char CheckKeyPressed();

	IDirectInputDevice2 *CreateDevice2(GUID *pguid);

    IDirectInputDevice2 *Keyboard;

	IDirectInputDevice2 *Mouse;
};

class Engine_CDAudio
{
public:

	void Open();

	void Play(int Track);

	void Stop();
};
extern Engine_Graphics screen;
#endif
