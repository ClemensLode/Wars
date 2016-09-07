/* 
    WEngine V 0.8

neue Features:
- Fullscreen-Video
- voller Window-Support (ideal zum Debuggen)  
- anfaenglicher 3D-Sound
- Frequency-Streaming
- Framerate-Anzeige
- korrektes Pan-Streaming
- TurnSound-Methode zum Spulen von Sounds
- ...

neue lib : amstrmid.lib
*/

#define D3D_OVERLOADS
#define DIRECTPLAY2_OR_GREATER

#include <d3d.h>
#include <dplay.h>
#include <d3dtypes.h>
#include <windows.h>
#include <windowsx.h>
#include <windef.h>
#include <ddraw.h>
//#include <dsound.h>
#include <wingdi.h>
#include <mmsystem.h>
#include <stdio.h>
#include <dinput.h>
#include <mmstream.h>
#include <amstream.h>
#include <ddstream.h>

#ifndef _ENGINE_H_
#define _ENGINE_H_

#define GRAPHICSTYPE_3DACCELRATED  1
#define GRAPHICSTYPE_2D            2
#define PANPLUS                    1
#define PANMINUS				   2
#define MAXSPRITESONMAP            20
#define VOLPLUS                    1
#define VOLMINUS				   2
#define FREQPLUS                   1
#define FREQMINUS				   2
#define TURNPLUS				   1
#define TURNMINUS				   2

#define RELEASE(x) if (x != NULL) {x->Release(); x = NULL;}

char *CheckDXError(HRESULT error);

/*typedef struct
{
	IDirectSoundBuffer *buffer2d;
	IDirectSound3DBuffer *buffer3d;
} SOUND3D;*/

typedef struct
{
	D3DVIEWPORT view;
	IDirect3DViewport2 *viewport;
	IDirect3DDevice2 *d3ddevice; 
} D3D_Overhead;

typedef struct
{
	BOOL MHORIZONTAL;	
	BOOL MVERTIKAL;    
	BOOL ROTATION;
	BOOL NORMAL;
	DWORD RotationAngle;
	BOOL STRETCHING;
}EFFECTS;

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
    IDirect3D2   *lpD3D;
    IDirectDraw  *lpDD;
//	IDirectSound *lpDS;
	IDirectInput *lpDI;
	IDirectPlay3 *lpDP;
	HWND hwnd;
	HDC  hdc;
	BOOL DoWindowStuffFullscreen(HINSTANCE hInstance,WNDPROC WindowProc,int nCmdShow);
	BOOL DoWindowStuff(HINSTANCE hInstance,WNDPROC WindowProc,int nCmdShow,LPCSTR Menu);
	HINSTANCE hInstance;
    void EndApp();
};

class Engine_Graphics
{
public :
    Engine_Info info;
    D3D_Overhead d3d_overhead;
	void SetGraphicsType(int type);
	IDirectDrawSurface *Primaer;
	IDirectDrawSurface *BackBuffer;
	DDSURFACEDESC ddsd;
	IDirectDrawClipper *Clipper;
	RECT client_area;
	BOOL Fullscreen;
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
	BOOL DrawRect(IDirectDrawSurface *Oberflaeche,int x1,int y1,int x2,int y2,BOOL filled);
	BOOL DrawEllipse(IDirectDrawSurface *Oberflaeche,int x1,int y1,int x2,int y2);
	void PutPixel(IDirectDrawSurface *Oberflaeche, int x,int y);
	void PutPixel2(IDirectDrawSurface *Oberflaeche, int x,int y); // attrappe
	BOOL DrawPolygon(IDirectDrawSurface *Oberflaeche,const POINT Ecken,int WievieleEcken);
	void BufferClear(IDirectDrawSurface *surf,int r,int g,int b);
	void SetFontName(char*FontName);
    int resx,resy;
	IDirectDrawSurface *CreateSurface(DWORD width,DWORD height);
    BOOL DeviceDialog();
	void CopySurface(DWORD width,DWORD height,IDirectDrawSurface *Source,
								  IDirectDrawSurface *Target);
	void CheckHardware(DD_DRIVERINFO dd_dinf);
	BOOL ScreenShot(IDirectDrawSurface *surf,char *file);
	DWORD ConvertRGB2DWORD(COLORREF rgb);
	void BuildDWTable(DWORD dw[255][255][255]);
    void UpdateClientArea();
	void GetAccessGDI(IDirectDrawSurface *surf);
	void CloseAccessGDI(IDirectDrawSurface *surf);
	DDSURFACEDESC GetAccess(IDirectDrawSurface *surf);
    void CloseAccess(IDirectDrawSurface *surf);
	void StartFrameTimer();
	void UpdateFrames();
	void ShowFrames(IDirectDrawSurface *suf,int x,int y);
	DWORD GetFrameRate();
private:
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
	IDirectDrawSurface *rgb2dword;
	DWORD    dwFrameTime;   
	DWORD    dwFrames;    
	DWORD    dwFrameCount;
	DWORD    dwTime;
    HFONT CreateFont (char *szFaceName, int iDeciPtHeight,
                  int iDeciPtWidth, int iAttributes, BOOL fLogRes) ;
    Engine_Info inf;
	COLORREF tcolor;
	int graph_type;
	BOOL SaveBMPToFile(LPDIRECTDRAWSURFACE SaveSurface,
		LPDIRECTDRAWSURFACE FrontBuffer, HANDLE file_out);
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
	BOOL DrawSpriteMap(int x,int y,int id);
	BOOL CreateSprite(DWORD Breite,DWORD Hoehe,BOOL AndTranslucent);
	void SetColorKey(int r,int g,int b);
    void ReleaseSprite();
    BOOL PrepareForTranslucent();
    BOOL DrawSpriteTranslucent(RECT QuellPosition, DWORD x,DWORD y);
	void SetSpriteMap(RECT s[MAXSPRITESONMAP]);
private:
	DDBLTFX ddbltfx;
	DWORD trans_height,trans_width;
	DWORD dwGreen;
    DWORD dwBlue;
	DDCAPS         ddcaps;
    DDPIXELFORMAT  ddpf;
    DDSURFACEDESC  ddsd;
    BOOL LoadSprite(IDirectDrawSurface *lpDDS, LPSTR szImage);
    BOOL Fail(char *szMsg);
    HWND spr_hwnd; 
    LPDIRECTDRAW spr_dd;
	int c_r,c_g,c_b;
    IDirectDrawSurface *trans_surf;
	RECT pix_pos,copy_rect;
	void DrawArray1(int y);
	void DrawArray2(int y);
	RECT sprites[MAXSPRITESONMAP];
};	


/*class Engine_Sound
{
public:
	Engine_Info info;
	HWND hwnd;
/*	IDirectSoundBuffer *Primaer;
	IDirectSound3DListener *Listener;
	void PlayStatic(IDirectSoundBuffer *snd,BOOL loop);
	void Stop(IDirectSoundBuffer *snd);
	void PanMove(IDirectSoundBuffer *buffer,int dir);
	void LoadStatic(LPDIRECTSOUNDBUFFER *buffer,char *filename);
    BOOL LoadStreamBuffer(IDirectSoundBuffer *lpdsb,LPSTR lpzFileName);
	BOOL PlayStreamBuffer(IDirectSoundBuffer *lpdsb);
	BOOL InitDirectSound(BOOL CreatePrimary3D,int channels,int freq,int bits);
    //void ReleaseObjects();
	void CheckHardware(DS_DRIVERINFO ds_dinf);
	void VolumeMove(IDirectSoundBuffer *buffer,int dir);
	void FreqMove(IDirectSoundBuffer *buffer,int dir);
	void TurnSound(IDirectSoundBuffer *buffer,int dir);
private:
    HRESULT             hr;
    DSCAPS              dscaps;
	DSBUFFERDESC        dsbdesc;
    WAVEFORMATEX        wfm;
	LPSTR               datei;
    WAVEFORMATEX        *pwfx;
    HMMIO               hmmio;
    MMCKINFO            mmckinfo, mmckinfoParent;
    DWORD               dwMidBuffer;
    FillBufferWithSilence( IDirectSoundBuffer *lpDsb );
};	*/

class Engine_Input
{
public:
	Engine_Info info;
	BOOL InitDirectInput();
	BOOL InstallKeyboard();
	BOOL InstallMouse();
	void ReleaseObjects();
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
	void PlayFromTo(int start,int end);
};

class Engine_Multiplayer
{
public:
	Engine_Info info;
	BOOL InitDirectPlay();
	BOOL Fail(char*Msg);
	void ChooseConnection(void);
	void ReleaseObjects(void);
};

class Engine_AVIStream
{
public:
	Engine_Graphics En_Graph;
	IMultiMediaStream *MMStream;
	void Load(char*strfile);
	void PlayOnSurface(IDirectDrawSurface *surf,BOOL stretch);
};
extern Engine_Graphics screen;
#endif