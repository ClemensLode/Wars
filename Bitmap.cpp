#include "engine.h"


BOOL Engine_Graphics::LoadBitmap(IDirectDrawSurface *lpDDS, LPSTR szImage )
{ 

HBITMAP         hbm;
HDC             hdcText;
HDC             hdcImage = NULL;
HDC             hdcSurf  = NULL;
BOOL            bReturn  = FALSE;
    ZeroMemory( &ddsd, sizeof( ddsd ) );
    ddsd.dwSize = sizeof( ddsd );

    if ( FAILED( lpDDS->GetSurfaceDesc( &ddsd ) ) )
	{
        return Fail("GetSurfaceDesc");
		goto Exit;
    }


    if ( ( ddsd.ddpfPixelFormat.dwFlags != DDPF_RGB ) ||
         ( ddsd.ddpfPixelFormat.dwRGBBitCount < 16 ) )

    {
        OutputDebugString( "Palettenfreier RGB-Modus vorausgesetzt.\n" );
        return Fail("Pallette");
		goto Exit;        
    }


    hbm = ( HBITMAP )LoadImage( NULL, szImage, 
            IMAGE_BITMAP, ddsd.dwWidth, 
            ddsd.dwHeight, LR_LOADFROMFILE | LR_CREATEDIBSECTION);

    if ( hbm == NULL ) 
	{
        OutputDebugString("Bilddatei nicht gefunden.\n" );
		return Fail("Keine Bilddatei!");
		goto Exit;
    }


    hdcImage = CreateCompatibleDC( NULL );
    SelectObject( hdcImage, hbm );
   

    if ( FAILED( lpDDS->GetDC( &hdcSurf ) ) )
	{
        OutputDebugString( "Kein Gerätekontext!\n" );
        return Fail("Kein DC");
		goto Exit;
    }
    

    if ( BitBlt( hdcSurf, 0, 0, ddsd.dwWidth, ddsd.dwHeight, 
                 hdcImage, 0, 0, SRCCOPY ) == FALSE ) 
	{
        OutputDebugString( "Fehler bei BitBlt.\n" );
        return Fail("BitBlt");
		goto Exit;
    }


        hdcText = CreateCompatibleDC( NULL );
        SelectObject( hdcImage, hbm );

	    lpDDS->GetDC( &hdcText );

        


    bReturn = TRUE;
    
Exit:

    if ( hdcSurf )
        lpDDS->ReleaseDC( hdcSurf );
    if ( hdcImage )
        DeleteDC( hdcImage );
    if ( hbm )
        DeleteObject( hbm );

    return bReturn;
}

