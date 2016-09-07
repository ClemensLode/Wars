#include "engine.h"
#include "resource.h"

LPGUID lpDevice,Device_GUID;
int iIndex;
BOOL ready;

Engine_Graphics device_engine;
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
	if (Fullscreen && ready == TRUE && graph_type==GRAPHICSTYPE_2D) 
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

	  this->Fullscreen = TRUE;

	}
	else if ( Fullscreen==FALSE && ready==TRUE && graph_type==GRAPHICSTYPE_2D) 
	{

      if ( FAILED( info.lpDD->SetCooperativeLevel( info.hwnd, DDSCL_NORMAL ) ) )
	  {
       return Fail( "Fehler beim Setzen der Kooperationsebene.\n" );
	  }

	  ZeroMemory(&ddsd,sizeof(ddsd));
      ddsd.dwSize = sizeof( ddsd );
      ddsd.dwFlags = DDSD_CAPS;
      ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;
  
      if ( FAILED( info.lpDD->CreateSurface( &ddsd, &Primaer, NULL ) ) )
	  {
        return Fail( "Fehler : Primaer(anlegen)(NORMAL)" );
	  }

      if(FAILED(Primaer->GetSurfaceDesc(&this->ddsd)))
	  {
		  return Fail("Primaer->GetSurfaceDesc (Z:118D:dd.cpp)");
	  }

	  if(ddsd.ddpfPixelFormat.dwRGBBitCount == 8)
	  {
		  return Fail("Sie muessen 16-Bit oder mehr auf ihrem Desktop eingestellt haben!");
	  }

      ZeroMemory(&ddsd,sizeof(ddsd));
      ddsd.dwSize=sizeof(ddsd);
	  
	  ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT |DDSD_WIDTH;
	  ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN|DDSCAPS_SYSTEMMEMORY;
      ddsd.dwWidth = x;
      ddsd.dwHeight = y;

	  if(FAILED(info.lpDD->CreateSurface(&ddsd, &this->BackBuffer, NULL)))
	  {
		  return Fail("Fehler beim Anlegen des gefaelschten Hintergrundbuffers!");
	  }
	  
	  if ( FAILED( info.lpDD->CreateClipper( 0, &Clipper, NULL ) ) )
	  {
        return Fail( "Fehler beim Anlegen des Clippers.\n" );
	  }

      if ( FAILED( Clipper->SetHWnd( 0, info.hwnd ) ) )
	  {
        return Fail("Fehler beim Einsetzen des Fensters.\n" );
	  }

	  if( FAILED( Primaer->SetClipper(this->Clipper)))
	  {
		  return Fail("Konnte keinen Clipper erzeugen !");
	  }

	  Clipper->Release();

      GetClientRect(info.hwnd,&this->client_area );
      ClientToScreen( info.hwnd, ( LPPOINT )&this->client_area );
      ClientToScreen( info.hwnd, ( LPPOINT )&this->client_area + 1 );

	  this->Fullscreen = FALSE;

	}
	//
    else if( Fullscreen==TRUE && ready==TRUE && graph_type==GRAPHICSTYPE_3DACCELRATED )
	{
       if(FAILED(this->info.lpDD->SetCooperativeLevel(info.hwnd,DDSCL_FULLSCREEN|DDSCL_EXCLUSIVE)))
	   {
		   return Fail("(D3D) SetCooperativeLevel");
	   }
		   
	   if(FAILED(this->info.lpDD->SetDisplayMode(x,y,bpp)))
	   {
		   return Fail("(D3D) SetDisplayMode");
	   }
	
	   ZeroMemory(&ddsd,sizeof(ddsd));
	   this->ddsd.dwSize = sizeof(ddsd);
	   this->ddsd.dwFlags = DDSD_CAPS;

	   this->ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;

	   if(FAILED(this->info.lpDD->CreateSurface(&this->ddsd,&this->Primaer,NULL)))
	   {
		   return Fail("(D3D) CreateSurface(Primary)");
	   }

	   ZeroMemory(&this->ddsd,sizeof(this->ddsd));

	   this->ddsd.dwSize = sizeof(ddsd);
	   this->ddsd.dwFlags = DDSD_CAPS | DDSD_WIDTH | DDSD_HEIGHT;
       this->ddsd.dwWidth = x;
	   this->ddsd.dwHeight = y;

	   this->ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN | DDSCAPS_3DDEVICE | DDSCAPS_VIDEOMEMORY;
	   
	   if(FAILED(info.lpDD->CreateSurface(&this->ddsd,&this->BackBuffer,NULL)))
	   {
		   return Fail("(D3D) CreateSurface(BackBuffer)");
	   }

	   if(FAILED(this->Primaer->AddAttachedSurface(this->BackBuffer)))
	   {
		   return Fail("(D3D) AddAttachedSurface");
	   }

	   if(FAILED(info.lpDD->QueryInterface(IID_IDirect3D2,(LPVOID*)&info.lpD3D)))
	   {
		   return Fail("(D3D) QueryInterface");
	   }
	

	    D3DFINDDEVICESEARCH search;
	    D3DFINDDEVICERESULT result;
		
	    ZeroMemory(&search,sizeof(search));
	    search.dwSize = sizeof(search);
	    search.dwFlags = D3DFDS_HARDWARE;

	    ZeroMemory(&result,sizeof(result));
	    result.dwSize = sizeof(result);

	    if((info.lpD3D->FindDevice(&search,&result))!= D3D_OK) { return Fail("FindDevice"); }

	    if((info.lpD3D->CreateDevice(result.guid,BackBuffer,&d3d_overhead.d3ddevice))!=D3D_OK) { return Fail("CreateDevice"); }

	    ZeroMemory(&d3d_overhead.view,sizeof(d3d_overhead.view));

	    d3d_overhead.view.dwSize = sizeof(d3d_overhead.view);
	    d3d_overhead.view.dwWidth = x;
	    d3d_overhead.view.dwHeight = y;
	    d3d_overhead.view.dvScaleX = x / 2;
	    d3d_overhead.view.dvScaleY = y / 2;
	    d3d_overhead.view.dvMaxX = D3DVAL(1.0);
	    d3d_overhead.view.dvMaxY = D3DVAL(1.0);

	    if(FAILED(info.lpD3D->CreateViewport(&d3d_overhead.viewport,NULL)))
		{
			return Fail("CreateViewport");
		}

	    if(FAILED(d3d_overhead.d3ddevice->AddViewport(d3d_overhead.viewport)))
		{
			return Fail("AddViewport");
		}
	    
		if(FAILED(d3d_overhead.viewport->SetViewport(&d3d_overhead.view)))
		{
			return Fail("SetViewport");
		}
	    
		if(FAILED(d3d_overhead.d3ddevice->SetCurrentViewport(d3d_overhead.viewport)))
		{
			return Fail("SetCurrentViewport");
		}
		
	    this->Fullscreen = TRUE;
	}
rgb2dword = CreateSurface(1,1);
return TRUE;
}

void Engine_Graphics::ReleaseObjects()
{
   info.lpDD->RestoreDisplayMode();
   	RELEASE(this->d3d_overhead.viewport);
	RELEASE(this->d3d_overhead.d3ddevice);
	RELEASE(this->rgb2dword);
	RELEASE(this->BackBuffer);
	RELEASE(this->Primaer);
	RELEASE(this->info.lpD3D);
	RELEASE(this->info.lpDD);
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
  if(this->Fullscreen)
  {
   if(FAILED(Primaer->Flip(NULL,DDFLIP_WAIT)))
   {
	   return Fail("Engine_Graphics::Flip()");
   }
  }
  else
  {
   if(FAILED(Primaer->Blt(&this->client_area,this->BackBuffer,NULL,DDBLT_WAIT,NULL)))
   {
	   return Fail("Engine_Graphics::Flip(windowed)");
   }
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

IDirectDrawSurface *Engine_Graphics::CreateSurface(DWORD width,DWORD height)
{

	IDirectDrawSurface *surf;
	ZeroMemory(&ddsd,sizeof(ddsd));
	ddsd.dwSize = sizeof( ddsd );

    ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT | 
		           DDSD_WIDTH; 

    ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN; 
    ddsd.dwHeight = height; 
    ddsd.dwWidth = width;
    info.lpDD->CreateSurface( &ddsd, &surf, NULL );

return surf;
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

void Engine_Graphics::PutPixel2(IDirectDrawSurface *Oberflaeche,int x,int y)
{

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

void Engine_Graphics::SetGraphicsType(int type)
{
	if(type==GRAPHICSTYPE_3DACCELRATED) { graph_type=GRAPHICSTYPE_3DACCELRATED; }
	else { graph_type=GRAPHICSTYPE_2D; }
}

char *CheckDXError(HRESULT error)
{
  switch(error)
  {
    case DD_OK:
      return "No error.\0";
    case DDERR_ALREADYINITIALIZED:
      return "This object is already initialized.\0";
    case DDERR_BLTFASTCANTCLIP:
      return "Return if a clipper object is attached to the source surface passed into a BltFast call.\0";
    case DDERR_CANNOTATTACHSURFACE:
      return "This surface can not be attached to the requested surface.\0";
    case DDERR_CANNOTDETACHSURFACE:
      return "This surface can not be detached from the requested surface.\0";
    case DDERR_CANTCREATEDC:
      return "Windows can not create any more DCs.\0";
    case DDERR_CANTDUPLICATE:
      return "Can't duplicate primary & 3D surfaces, or surfaces that are implicitly created.\0";
    case DDERR_CLIPPERISUSINGHWND:
      return "An attempt was made to set a cliplist for a clipper object that is already monitoring an hwnd.\0";
    case DDERR_COLORKEYNOTSET:
      return "No src color key specified for this operation.\0";
    case DDERR_CURRENTLYNOTAVAIL:
      return "Support is currently not available.\0";
    case DDERR_DIRECTDRAWALREADYCREATED:
      return "A DirectDraw object representing this driver has already been created for this process.\0";
    case DDERR_EXCEPTION:
      return "An exception was encountered while performing the requested operation.\0";
    case DDERR_EXCLUSIVEMODEALREADYSET:
      return "An attempt was made to set the cooperative level when it was already set to exclusive.\0";
    case DDERR_GENERIC:
      return "Generic failure.\0";
    case DDERR_HEIGHTALIGN:
      return "Height of rectangle provided is not a multiple of reqd alignment.\0";
    case DDERR_HWNDALREADYSET:
      return "The CooperativeLevel HWND has already been set. It can not be reset while the process has surfaces or palettes created.\0";
    case DDERR_HWNDSUBCLASSED:
      return "HWND used by DirectDraw CooperativeLevel has been subclassed, this prevents DirectDraw from restoring state.\0";
    case DDERR_IMPLICITLYCREATED:
      return "This surface can not be restored because it is an implicitly created surface.\0";
    case DDERR_INCOMPATIBLEPRIMARY:
      return "Unable to match primary surface creation request with existing primary surface.\0";
    case DDERR_INVALIDCAPS:
      return "One or more of the caps bits passed to the callback are incorrect.\0";
    case DDERR_INVALIDCLIPLIST:
      return "DirectDraw does not support the provided cliplist.\0";
    case DDERR_INVALIDDIRECTDRAWGUID:
      return "The GUID passed to DirectDrawCreate is not a valid DirectDraw driver identifier.\0";
    case DDERR_INVALIDMODE:
      return "DirectDraw does not support the requested mode.\0";
    case DDERR_INVALIDOBJECT:
      return "DirectDraw received a pointer that was an invalid DIRECTDRAW object.\0";
    case DDERR_INVALIDPARAMS:
      return "One or more of the parameters passed to the function are incorrect.\0";
    case DDERR_INVALIDPIXELFORMAT:
      return "The pixel format was invalid as specified.\0";
    case DDERR_INVALIDPOSITION:
      return "Returned when the position of the overlay on the destination is no longer legal for that destination.\0";
    case DDERR_INVALIDRECT:
      return "Rectangle provided was invalid.\0";
    case DDERR_LOCKEDSURFACES:
      return "Operation could not be carried out because one or more surfaces are locked.\0";
    case DDERR_NO3D:
      return "There is no 3D present.\0";
    case DDERR_NOALPHAHW:
      return "Operation could not be carried out because there is no alpha accleration hardware present or available.\0";
    case DDERR_NOBLTHW:
      return "No blitter hardware present.\0";
    case DDERR_NOCLIPLIST:
      return "No cliplist available.\0";
    case DDERR_NOCLIPPERATTACHED:
      return "No clipper object attached to surface object.\0";
    case DDERR_NOCOLORCONVHW:
      return "Operation could not be carried out because there is no color conversion hardware present or available.\0";
    case DDERR_NOCOLORKEY:
      return "Surface doesn't currently have a color key\0";
    case DDERR_NOCOLORKEYHW:
      return "Operation could not be carried out because there is no hardware support of the destination color key.\0";
    case DDERR_NOCOOPERATIVELEVELSET:
      return "Create function called without DirectDraw object method SetCooperativeLevel being called.\0";
    case DDERR_NODC:
      return "No DC was ever created for this surface.\0";
    case DDERR_NODDROPSHW:
      return "No DirectDraw ROP hardware.\0";
    case DDERR_NODIRECTDRAWHW:
      return "A hardware-only DirectDraw object creation was attempted but the driver did not support any hardware.\0";
    case DDERR_NOEMULATION:
      return "Software emulation not available.\0";
    case DDERR_NOEXCLUSIVEMODE:
      return "Operation requires the application to have exclusive mode but the application does not have exclusive mode.\0";
    case DDERR_NOFLIPHW:
      return "Flipping visible surfaces is not supported.\0";
    case DDERR_NOGDI:
      return "There is no GDI present.\0";
    case DDERR_NOHWND:
      return "Clipper notification requires an HWND or no HWND has previously been set as the CooperativeLevel HWND.\0";
    case DDERR_NOMIRRORHW:
      return "Operation could not be carried out because there is no hardware present or available.\0";
    case DDERR_NOOVERLAYDEST:
      return "Returned when GetOverlayPosition is called on an overlay that UpdateOverlay has never been called on to establish a destination.\0";
    case DDERR_NOOVERLAYHW:
      return "Operation could not be carried out because there is no overlay hardware present or available.\0";
    case DDERR_NOPALETTEATTACHED:
      return "No palette object attached to this surface.\0";
    case DDERR_NOPALETTEHW:
      return "No hardware support for 16 or 256 color palettes.\0";
    case DDERR_NORASTEROPHW:
      return "Operation could not be carried out because there is no appropriate raster op hardware present or available.\0";
    case DDERR_NOROTATIONHW:
      return "Operation could not be carried out because there is no rotation hardware present or available.\0";
    case DDERR_NOSTRETCHHW:
      return "Operation could not be carried out because there is no hardware support for stretching.\0";
    case DDERR_NOT4BITCOLOR:
      return "DirectDrawSurface is not in 4 bit color palette and the requested operation requires 4 bit color palette.\0";
    case DDERR_NOT4BITCOLORINDEX:
      return "DirectDrawSurface is not in 4 bit color index palette and the requested operation requires 4 bit color index palette.\0";
    case DDERR_NOT8BITCOLOR:
      return "DirectDrawSurface is not in 8 bit color mode and the requested operation requires 8 bit color.\0";
    case DDERR_NOTAOVERLAYSURFACE:
      return "Returned when an overlay member is called for a non-overlay surface.\0";
    case DDERR_NOTEXTUREHW:
      return "Operation could not be carried out because there is no texture mapping hardware present or available.\0";
    case DDERR_NOTFLIPPABLE:
      return "An attempt has been made to flip a surface that is not flippable.\0";
    case DDERR_NOTFOUND:
      return "Requested item was not found.\0";
    case DDERR_NOTLOCKED:
      return "Surface was not locked.  An attempt to unlock a surface that was not locked at all, or by this process, has been attempted.\0";
    case DDERR_NOTPALETTIZED:
      return "The surface being used is not a palette-based surface.\0";
    case DDERR_NOVSYNCHW:
      return "Operation could not be carried out because there is no hardware support for vertical blank synchronized operations.\0";
    case DDERR_NOZBUFFERHW:
      return "Operation could not be carried out because there is no hardware support for zbuffer blitting.\0";
    case DDERR_NOZOVERLAYHW:
      return "Overlay surfaces could not be z layered based on their BltOrder because the hardware does not support z layering of overlays.\0";
    case DDERR_OUTOFCAPS:
      return "The hardware needed for the requested operation has already been allocated.\0";
    case DDERR_OUTOFMEMORY:
      return "DirectDraw does not have enough memory to perform the operation.\0";
    case DDERR_OUTOFVIDEOMEMORY:
      return "DirectDraw does not have enough memory to perform the operation.\0";
    case DDERR_OVERLAYCANTCLIP:
      return "The hardware does not support clipped overlays.\0";
    case DDERR_OVERLAYCOLORKEYONLYONEACTIVE:
      return "Can only have ony color key active at one time for overlays.\0";
    case DDERR_OVERLAYNOTVISIBLE:
      return "Returned when GetOverlayPosition is called on a hidden overlay.\0";
    case DDERR_PALETTEBUSY:
      return "Access to this palette is being refused because the palette is already locked by another thread.\0";
    case DDERR_PRIMARYSURFACEALREADYEXISTS:
      return "This process already has created a primary surface.\0";
    case DDERR_REGIONTOOSMALL:
      return "Region passed to Clipper::GetClipList is too small.\0";
    case DDERR_SURFACEALREADYATTACHED:
      return "This surface is already attached to the surface it is being attached to.\0";
    case DDERR_SURFACEALREADYDEPENDENT:
      return "This surface is already a dependency of the surface it is being made a dependency of.\0";
    case DDERR_SURFACEBUSY:
      return "Access to this surface is being refused because the surface is already locked by another thread.\0";
    case DDERR_SURFACEISOBSCURED:
      return "Access to surface refused because the surface is obscured.\0";
    case DDERR_SURFACELOST:
      return "Access to this surface is being refused because the surface memory is gone. The DirectDrawSurface object representing this surface should have Restore called on it.\0";
    case DDERR_SURFACENOTATTACHED:
      return "The requested surface is not attached.\0";
    case DDERR_TOOBIGHEIGHT:
      return "Height requested by DirectDraw is too large.\0";
    case DDERR_TOOBIGSIZE:
      return "Size requested by DirectDraw is too large, but the individual height and width are OK.\0";
    case DDERR_TOOBIGWIDTH:
      return "Width requested by DirectDraw is too large.\0";
    case DDERR_UNSUPPORTED:
      return "Action not supported.\0";
    case DDERR_UNSUPPORTEDFORMAT:
      return "FOURCC format requested is unsupported by DirectDraw.\0";
    case DDERR_UNSUPPORTEDMASK:
      return "Bitmask in the pixel format requested is unsupported by DirectDraw.\0";
    case DDERR_VERTICALBLANKINPROGRESS:
      return "Vertical blank is in progress.\0";
    case DDERR_WASSTILLDRAWING:
      return "Informs DirectDraw that the previous Blt which is transfering information to or from this Surface is incomplete.\0";
    case DDERR_WRONGMODE:
      return "This surface can not be restored because it was created in a different mode.\0";
    case DDERR_XALIGN:
      return "Rectangle provided was not horizontally aligned on required boundary.\0";
    case D3DERR_BADMAJORVERSION:
      return "D3DERR_BADMAJORVERSION\0";
    case D3DERR_BADMINORVERSION:
      return "D3DERR_BADMINORVERSION\0";
    case D3DERR_EXECUTE_LOCKED:
      return "D3DERR_EXECUTE_LOCKED\0";
    case D3DERR_EXECUTE_NOT_LOCKED:
      return "D3DERR_EXECUTE_NOT_LOCKED\0";
    case D3DERR_EXECUTE_CREATE_FAILED:
      return "D3DERR_EXECUTE_CREATE_FAILED\0";
    case D3DERR_EXECUTE_DESTROY_FAILED:
      return "D3DERR_EXECUTE_DESTROY_FAILED\0";
    case D3DERR_EXECUTE_LOCK_FAILED:
      return "D3DERR_EXECUTE_LOCK_FAILED\0";
    case D3DERR_EXECUTE_UNLOCK_FAILED:
      return "D3DERR_EXECUTE_UNLOCK_FAILED\0";
    case D3DERR_EXECUTE_FAILED:
      return "D3DERR_EXECUTE_FAILED\0";
    case D3DERR_EXECUTE_CLIPPED_FAILED:
      return "D3DERR_EXECUTE_CLIPPED_FAILED\0";
    case D3DERR_TEXTURE_NO_SUPPORT:
      return "D3DERR_TEXTURE_NO_SUPPORT\0";
    case D3DERR_TEXTURE_NOT_LOCKED:
      return "D3DERR_TEXTURE_NOT_LOCKED\0";
    case D3DERR_TEXTURE_LOCKED:
      return "D3DERR_TEXTURELOCKED\0";
    case D3DERR_TEXTURE_CREATE_FAILED:
      return "D3DERR_TEXTURE_CREATE_FAILED\0";
    case D3DERR_TEXTURE_DESTROY_FAILED:
      return "D3DERR_TEXTURE_DESTROY_FAILED\0";
    case D3DERR_TEXTURE_LOCK_FAILED:
      return "D3DERR_TEXTURE_LOCK_FAILED\0";
    case D3DERR_TEXTURE_UNLOCK_FAILED:
      return "D3DERR_TEXTURE_UNLOCK_FAILED\0";
    case D3DERR_TEXTURE_LOAD_FAILED:
      return "D3DERR_TEXTURE_LOAD_FAILED\0";
    case D3DERR_MATRIX_CREATE_FAILED:
      return "D3DERR_MATRIX_CREATE_FAILED\0";
    case D3DERR_MATRIX_DESTROY_FAILED:
      return "D3DERR_MATRIX_DESTROY_FAILED\0";
    case D3DERR_MATRIX_SETDATA_FAILED:
      return "D3DERR_MATRIX_SETDATA_FAILED\0";
    case D3DERR_SETVIEWPORTDATA_FAILED:
      return "D3DERR_SETVIEWPORTDATA_FAILED\0";
    case D3DERR_MATERIAL_CREATE_FAILED:
      return "D3DERR_MATERIAL_CREATE_FAILED\0";
    case D3DERR_MATERIAL_DESTROY_FAILED:
      return "D3DERR_MATERIAL_DESTROY_FAILED\0";
    case D3DERR_MATERIAL_SETDATA_FAILED:
      return "D3DERR_MATERIAL_SETDATA_FAILED\0";
    case D3DERR_LIGHT_SET_FAILED:
      return "D3DERR_LIGHT_SET_FAILED\0";
    default:
      return "Unrecognized error value.\0";
  }
}

DWORD Engine_Graphics::ConvertRGB2DWORD(COLORREF rgb)
{
	COLORREF rgbT;
    HDC hdc;
    DWORD dw = CLR_INVALID;
    DDSURFACEDESC ddsd;
    HRESULT hres;

    if (rgb != CLR_INVALID && rgb2dword->GetDC(&hdc) == DD_OK)
    {
	rgbT = GetPixel(hdc, 0, 0);             
	SetPixel(hdc, 0, 0, rgb);               
	rgb2dword->ReleaseDC(hdc);
    }

    ddsd.dwSize = sizeof(ddsd);
    while ((hres = rgb2dword->Lock(NULL, &ddsd, 0, NULL)) == DDERR_WASSTILLDRAWING);

    if (hres == DD_OK)
    {
	dw  = *(DWORD *)ddsd.lpSurface;                     
        if(ddsd.ddpfPixelFormat.dwRGBBitCount < 32)
            dw &= (1 << ddsd.ddpfPixelFormat.dwRGBBitCount)-1; 
	rgb2dword->Unlock(NULL);
    }

    if (rgb != CLR_INVALID && rgb2dword->GetDC(&hdc) == DD_OK)
    {
	SetPixel(hdc, 0, 0, rgbT);
	rgb2dword->ReleaseDC(hdc);
    }

    return dw;
}

void Engine_Graphics::UpdateClientArea()
{
   GetClientRect(info.hwnd,&this->client_area );
   ClientToScreen( info.hwnd, ( LPPOINT )&this->client_area );
   ClientToScreen( info.hwnd, ( LPPOINT )&this->client_area + 1 );
}

void Engine_Graphics::GetAccessGDI(IDirectDrawSurface *surf)
{
	surf->GetDC(&info.hdc);
}

void Engine_Graphics::CloseAccessGDI(IDirectDrawSurface *surf)
{
	surf->ReleaseDC(info.hdc);
}

DDSURFACEDESC Engine_Graphics::GetAccess(IDirectDrawSurface *surf)
{
	DDSURFACEDESC temp_ddsd;
	surf->Lock(NULL,&temp_ddsd,DDLOCK_WAIT,NULL);
	return temp_ddsd;
}

void Engine_Graphics::CloseAccess(IDirectDrawSurface *surf)
{
	surf->Unlock(NULL);
}

void Engine_Graphics::StartFrameTimer()
{
	this->dwFrameTime = timeGetTime();
}

void Engine_Graphics::UpdateFrames()
{
    dwFrameCount++;
    dwTime = timeGetTime() - dwFrameTime;
    if ( dwTime > 1000 )
    {
        dwFrames = ( dwFrameCount*1000 )/dwTime;
        dwFrameTime = timeGetTime();
        dwFrameCount = 0;
    }
}

void Engine_Graphics::ShowFrames(IDirectDrawSurface *surf,int x,int y)
{
	char frames[30];
	wsprintf(frames,"Frames : %d",this->dwFrames);
	this->WriteSquick(surf,x,y,frames);
}

DWORD Engine_Graphics::GetFrameRate()
{
	return this->dwFrames;
}
