#include "engine.h"
#include "resource.h"
//Engine_Graphics screen;
LPGUID lpDevice,Device_GUID;
int iIndex;
BOOL ready;

HWND en_hwnd;

LPGUID device;

LRESULT CALLBACK DeviceDlgProc( HWND , UINT , WPARAM , LPARAM );

BOOL Engine_Graphics::InitDirectDraw(DWORD x,DWORD y,DWORD bpp,BOOL Fullscreen,BOOL UseDevice)
{
en_hwnd = info.hwnd;
resx = x;
resy = y;
	if((Fullscreen)&&(bpp < 16))
	{
		return Fail("Palette im Vollbildmodus nicht moeglich");
	}

    if(UseDevice) 
	{
	   while(1)
	   {
		if(DeviceDialog()==TRUE)
		{
			DirectDrawCreate(Device_GUID,&info.lpDD,NULL);
			goto next;
		}
	   }
	}
	else
	{
       if ( FAILED( DirectDrawCreate( NULL, &info.lpDD, NULL ) ) )
	   {
		   return Fail("Fehler : DD-Objekt");
	   }
	   ready = TRUE;
	}
next:
	if (Fullscreen && ready == TRUE) 
	{
	  if FAILED( info.lpDD->SetCooperativeLevel( info.hwnd,
                        DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN ) )
	  {
	  	return Fail("Fehler : Kooperationsebene");
	  }

	  if ( FAILED( info.lpDD->SetDisplayMode( x, y, bpp ) ) )
	  {
        return Fail("Fehler : setzen des Videomodus'");
	  }

      ddsd.dwSize = sizeof( ddsd );
      ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
      ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE | DDSCAPS_FLIP |
		                  DDSCAPS_COMPLEX | DDSCAPS_VIDEOMEMORY ;
    
      ddsd.dwBackBufferCount = 1;
	  if ( FAILED( info.lpDD->CreateSurface( &ddsd, &Primaer, NULL ) ) )
	  {
		return Fail("Fehler : Prim.Surface (anlegen)");
	  }

      ddscaps.dwCaps = DDSCAPS_BACKBUFFER;
	  if (FAILED(Primaer->GetAttachedSurface(&ddscaps,&BackBuffer)))
	  {
		return Fail("Fehler : BackBuffer (anlegen)");
	  }
	  return TRUE;
	}
	else
	{

      if ( FAILED( info.lpDD->SetCooperativeLevel( info.hwnd, DDSCL_NORMAL ) ) )
	  {
       return Fail( "Fehler beim Setzen der Kooperationsebene.\n" );
	  }


      ddsd.dwSize = sizeof( ddsd );
      ddsd.dwFlags = DDSD_CAPS;
      ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;
  
      if ( FAILED( info.lpDD->CreateSurface( &ddsd, &Primaer, NULL ) ) )
	  {
        return Fail( "Fehler : Primaer(anlegen)(NORMAL)" );
	  }


      if ( FAILED( info.lpDD->CreateClipper( 0, &Clipper, NULL ) ) )
	  {
        return Fail( "Fehler beim Anlegen des Clippers.\n" );
	  }

      if ( FAILED( Clipper->SetHWnd( 0, info.hwnd ) ) )
	  {
        return Fail("Fehler beim Einsetzen des Fensters.\n" );
	  }


      Clipper->Release();

      ddpf.dwSize = sizeof( ddpf );
      if ( FAILED( Primaer->GetPixelFormat( &ddpf ) ) )
	  {
        return Fail( "Fehler bei der Abfrage des Pixelformats.\n" );
	  }

      if ( ddpf.dwFlags & DDPF_PALETTEINDEXED8 ) 
	  {
        if ( FAILED( Primaer->SetPalette( lpDDPalette ) ) )
		{
            return Fail( "Fehler beim Ermiteln/Setzen der Palette.\n" );
        }
	  }
	return TRUE;
	}
return TRUE;
}

void Engine_Graphics::ReleaseObjects()
{
    if ( info.lpDD != NULL )
    {
        if ( Primaer != NULL )
        {
            Primaer->Release();
            Primaer = NULL;
        }
        info.lpDD->RestoreDisplayMode();
		info.lpDD->Release();
        info.lpDD = NULL;
	}
}

BOOL Engine_Graphics::Fail( char *szMsg)
{
    ReleaseObjects();
	OutputDebugString( szMsg );

	MessageBox(info.hwnd, szMsg, info.AppName, MB_OK);
    DestroyWindow( info.hwnd );
    return FALSE;
}


BOOL Engine_Graphics::NewDisplayMode(int x,int y,int bpp)
{
	
	if(FAILED(info.lpDD->SetDisplayMode(x,y,bpp))) 
	{
		return Fail("Engine::NewDisplayMode");
	}
return TRUE;
}

BOOL Engine_Graphics::Flip()
{
   if(FAILED(Primaer->Flip(NULL,DDFLIP_WAIT)))
   {
	   return Fail("Engine_Graphics::Flip()");
   }
return TRUE;
}

void Engine_Graphics::BufferClear(IDirectDrawSurface *surf,int r,int g,int b)
{
	ZeroMemory( &ddbltfx,sizeof( ddbltfx ));
	ddbltfx.dwSize = sizeof(ddbltfx);
	ddbltfx.dwFillColor = RGB(r,g,b);
	surf->Blt(NULL,NULL,NULL,DDBLT_COLORFILL | DDBLT_WAIT,&ddbltfx);
}

BOOL Engine_Graphics::CreateSurface(IDirectDrawSurface *surf,DWORD width,DWORD height)
{

	ddsd.dwSize = sizeof( ddsd );

    ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT | 
		           DDSD_WIDTH; 

    ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN; 
    ddsd.dwHeight = height; 
    ddsd.dwWidth = width;

    if ( FAILED( info.lpDD->CreateSurface( &ddsd, &surf, NULL ) ) )
	{
		return Fail("SPRITE = CreateSurface" );
	}
return TRUE;
}

BOOL Engine_Graphics::DeviceDialog()
{
	DialogBox((HINSTANCE)info.hInstance,(LPCTSTR)IDD_CHDEVICE,info.hwnd,(DLGPROC)DeviceDlgProc);
	while(1)
	{
		if(ready==TRUE)
		{
           return TRUE;
		}
	}
}

BOOL WINAPI EnumDDrawDevice( GUID FAR *lpGUID,           
                             LPSTR lpDriverDescription,  
                             LPSTR lpDriverName,         
                             LPVOID lpContext )
{
    LONG    iIndex;
    HWND    hWnd = ( HWND )lpContext;
    LPVOID  lpDevice = NULL;

    iIndex = SendMessage( hWnd, CB_ADDSTRING, 0, 
                          ( LPARAM )lpDriverDescription );

    if ( iIndex != LB_ERR )
    {

       if ( lpGUID == NULL ) 
		{
            lpDevice = NULL;
        }
        else
        {
            lpDevice = ( LPGUID )malloc( sizeof( GUID ) );
            if ( !lpDevice ) return FALSE;
            memcpy( lpDevice, lpGUID, sizeof( GUID ) );
        }

        SendMessage( hWnd, CB_SETITEMDATA, iIndex, 
                     ( LPARAM )lpDevice );
    }
    else 
    {
        return DDENUMRET_CANCEL;
    }

    return DDENUMRET_OK;
}

LRESULT CALLBACK DeviceDlgProc( HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam )
{
	switch( message )
	{
	    case WM_INITDIALOG:
		
		if ( FAILED( DirectDrawEnumerate( ( LPDDENUMCALLBACK )EnumDDrawDevice,  
                         ( LPVOID )GetDlgItem( hDlg, IDC_DEVICES ) ) ) )
		{
              return FALSE;
		}
		SendDlgItemMessage(hDlg, IDC_DEVICES, CB_SETCURSEL, 0, 0L );
		return TRUE;

		case WM_COMMAND:
             switch(LOWORD(wParam))
			 {
			 case IDCANCEL:
				 EndDialog(hDlg, LOWORD(wParam));
				 DestroyWindow(en_hwnd);
			     PostQuitMessage( 0 );				 
				 break;
			 case IDOK:
                 iIndex = SendDlgItemMessage( hDlg, IDC_DEVICES, 
                                              CB_GETCURSEL, 0, 0L );
                 lpDevice = ( LPGUID )SendDlgItemMessage( 
                                      hDlg, IDC_DEVICES, 
                                      CB_GETITEMDATA, iIndex, 0 );
				 Device_GUID = lpDevice; 
				 ready = TRUE;
				 EndDialog(hDlg, LOWORD(wParam));
				 break;
			 }
        break;
	}
    return FALSE;
}

void Engine_Graphics::PutPixel(IDirectDrawSurface *Oberflaeche,int x,int y)
{
	ZeroMemory(&ddbltfx,sizeof( ddbltfx ));
    ddbltfx.dwSize = sizeof( ddbltfx);
	ddbltfx.dwFillColor = RGB(tR,tG,tB);
	RECT pix={x,y,(x+1),(y+1)};
	Oberflaeche->Blt(&pix,NULL,NULL,DDBLT_WAIT|DDBLT_COLORFILL,&ddbltfx);
}

void Engine_Graphics::CopySurface(DWORD width,DWORD height,IDirectDrawSurface *Source,
								  IDirectDrawSurface *Target)
{
	RECT copy_rect={0,0,width,height};
	Target->BltFast(0,0,Source,&copy_rect,DDBLTFAST_NOCOLORKEY | DDBLTFAST_WAIT);
}

void Engine_Graphics::CheckHardware(DD_DRIVERINFO dd_dinf)
{
    dd_dinf.HW_BLT=FALSE;dd_dinf.HW_BLTSTRETCH=FALSE;dd_dinf.HW_CAN3D=FALSE;
	dd_dinf.HW_CANALPHA=FALSE;dd_dinf.HW_CANOVRLAY=FALSE;dd_dinf.HW_CLIP=FALSE;
	dd_dinf.HW_CLIP=FALSE;dd_dinf.HW_COLORKEY=FALSE;dd_dinf.HW_HARDWARE=FALSE;
	dd_dinf.HW_STEREO=FALSE;dd_dinf.HW_ZBLIT=FALSE;
	
	ddcaps.dwSize = sizeof(ddcaps);

	info.lpDD->GetCaps(&ddcaps,NULL);
	
	if(ddcaps.dwCaps & DDCAPS_3D) dd_dinf.HW_CAN3D = TRUE;
	if(ddcaps.dwCaps & DDCAPS_BLT) dd_dinf.HW_BLT = TRUE;
    if(ddcaps.dwCaps & DDCAPS_ALPHA) dd_dinf.HW_CANALPHA = TRUE;
	if(ddcaps.dwCaps & DDCAPS_COLORKEY) dd_dinf.HW_COLORKEY = TRUE;
	if(ddcaps.dwCaps & DDCAPS_OVERLAY) dd_dinf.HW_CANOVRLAY = TRUE;
	if(ddcaps.dwCaps & DDCAPS_STEREOVIEW) dd_dinf.HW_STEREO = TRUE;
	if(ddcaps.dwCaps & DDCAPS_CANCLIP) dd_dinf.HW_CLIP = TRUE;
    if(!(ddcaps.dwCaps & DDCAPS_NOHARDWARE)) dd_dinf.HW_HARDWARE = TRUE;
	if(ddcaps.dwCaps & DDCAPS_BLTSTRETCH) dd_dinf.HW_BLTSTRETCH = TRUE;
    if(ddcaps.dwCaps & DDCAPS_ZBLTS) dd_dinf.HW_ZBLIT = TRUE;
}

