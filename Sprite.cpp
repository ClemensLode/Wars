#include "engine.h"

BOOL Image::DrawSprite(RECT QuellPosition,int x,int y)
{
    
	if(FAILED(Ziel->BltFast(x,y,Quelle,&QuellPosition,DDBLTFAST_WAIT | DDBLTFAST_SRCCOLORKEY)))
	{
		return Fail("Sprite::DrawSprite");
	}
	xPos = x;
	yPos = y;
	return TRUE;
}

BOOL Image::DrawSpriteFX(RECT QuellPosition,RECT ZielPosition,EFFECTS effects)
{
    
	ZeroMemory(&ddbltfx,sizeof( ddbltfx ));
    ddbltfx.dwSize = sizeof( ddbltfx);
	
	if(!effects.STRETCHING)
	{
	 if ( effects.ROTATION == TRUE )
	 {
	     ddcaps.dwFXCaps = DDFXCAPS_BLTROTATION;
   		 ddbltfx.dwRotationAngle = effects.RotationAngle;
     }
	 if ( effects.MHORIZONTAL == TRUE )
	 {
 		 ddbltfx.dwDDFX = DDBLTFX_MIRRORUPDOWN;
	 }
	 if ( effects.MVERTIKAL == TRUE )
	 {
		 ddbltfx.dwDDFX |= DDBLTFX_MIRRORLEFTRIGHT;
	 }

	 if ( effects.NORMAL == TRUE )
	 {
	   if(FAILED(Ziel->Blt(&ZielPosition,Quelle,&QuellPosition, DDBLT_KEYSRC |
												DDBLT_ASYNC , NULL )))
	   {
	   	 return Fail("Sprite::DrawSpriteFX");
	   }
	 }
	
	 if (effects.NORMAL = FALSE) 
	 {
	   if(FAILED(Ziel->Blt(&ZielPosition,Quelle,&QuellPosition,DDBLT_DDFX | DDBLT_KEYSRC |
												DDBLT_ASYNC , &ddbltfx )))
	   {
	   	return Fail("Sprite::DrawSpriteFX");
	   }
	 }
	}
    else
	{
	 if( effects.STRETCHING==TRUE)
	 {
       Ziel->Blt( NULL, Quelle, NULL,DDBLT_WAIT, NULL );
	 }
	}

	return TRUE;
}


BOOL Image::CreateSprite(DWORD Breite,DWORD Hoehe,BOOL AndTranslucent)
{
    
    trans_height = Hoehe;
	trans_width = Breite;

    ddcaps.dwSize = sizeof( ddcaps );
    if ( FAILED( En_Graph.info.lpDD->GetCaps( &ddcaps, NULL ) ) )
	{
        return Fail("Couldn't get caps.\n" );
    }


    ddsd.dwSize = sizeof( ddsd );

    ddpf.dwSize = sizeof( ddpf );

	if ( FAILED( Ziel->GetPixelFormat( &ddpf ) ) )
	{
		return Fail("Fehler bei der Abfrage des Pixelformats.\n" );
	}

    dwGreen = ddpf.dwGBitMask;
    dwBlue = ddpf.dwBBitMask;
    

    ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT | 
		           DDSD_WIDTH | DDSD_CKSRCBLT; 

    ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN; 
    ddsd.dwHeight = Hoehe; 
    ddsd.dwWidth = Breite;
	
	ddsd.ddckCKSrcBlt.dwColorSpaceLowValue = 0;//En_Graph.ConvertRGB2DWORD(RGB(c_r,c_g,c_b));
    ddsd.ddckCKSrcBlt.dwColorSpaceHighValue = 0;//En_Graph.ConvertRGB2DWORD(RGB(c_r,c_g,c_b));


    if ( FAILED( En_Graph.info.lpDD->CreateSurface( &ddsd, &Quelle, NULL ) ) )
	{
		return Fail("SPRITE = CreateSurface" );
	}

    if(AndTranslucent)
	{
	 if ( FAILED( En_Graph.info.lpDD->CreateSurface( &ddsd, &trans_surf, NULL ) ) )
	 {
		return Fail("SPRITE = CreateSurface" );
	 }
	}

	LoadSprite(Quelle,szImage);
	if(AndTranslucent){ LoadSprite(trans_surf,szImage); }

	return TRUE;

}

void Image::ReleaseSprite()
{

if ( Quelle != NULL )
{

	Quelle->Release();
	Quelle = NULL;
	
}
if ( trans_surf != NULL )
{

	trans_surf->Release();
	trans_surf = NULL;
	
}
}

BOOL Image::LoadSprite(IDirectDrawSurface *lpDDS, LPSTR szImage )
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
        return Fail("Keine Bilddatei !");
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

BOOL Image::Fail( char *szMsg)
{
    ReleaseSprite();
	OutputDebugString( szMsg );

	MessageBox(En_Graph.info.hwnd, szMsg, En_Graph.info.AppName, MB_OK);
    DestroyWindow( En_Graph.info.hwnd );
    return FALSE;
}

void Image::SetColorKey(int r,int g,int b)
{
  c_r = r;
  c_g = g;
  c_b = b;
}

BOOL Image::PrepareForTranslucent()
{
    DWORD y;

	for (y=0;y<trans_width;y+=2)
	{
		DrawArray1(y);
	}
    for (y=1;y<(trans_width-1);y+=2)
	{
		DrawArray2(y);
	}
	
return TRUE;
}

BOOL Image::DrawSpriteTranslucent(RECT QuellPosition,DWORD x,DWORD y)
{
	if(FAILED(Ziel->BltFast(x,y,trans_surf,&QuellPosition,DDBLTFAST_WAIT | DDBLTFAST_SRCCOLORKEY)))
	{
		return Fail("Sprite::DrawSpriteTranslucent");
	}
return TRUE;
}

void Image::DrawArray1(int y)
{
	for (DWORD i=0;i<trans_width;i+=2)
	{
		En_Graph.PutPixel(trans_surf,i,y);
	}
}

void Image::DrawArray2(int y)
{
	for (DWORD i=1;i<trans_width;i+=2)
	{
		En_Graph.PutPixel(trans_surf,i,y);
	}
}

void Image::SetSpriteMap(RECT s[MAXSPRITESONMAP])
{
	CopyMemory(sprites,s,sizeof(s));
}

BOOL Image::DrawSpriteMap(int x,int y,int number)
{
    
	if(FAILED(Ziel->BltFast(x,y,Quelle,&sprites[number],DDBLTFAST_WAIT | DDBLTFAST_SRCCOLORKEY)))
	{
		return Fail("Sprite::DrawSprite");
	}
	xPos = x;
	yPos = y;
	return TRUE;
}
