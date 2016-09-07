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
	char *err;

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
		wsprintf(err,"%S nicht gefunden!",szImage);
		return Fail(err);
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

BOOL  Engine_Graphics::ScreenShot(IDirectDrawSurface *surf,char *file)
{
 HANDLE file_out;

  file_out = CreateFile(file, GENERIC_WRITE, FILE_SHARE_WRITE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
  if(file_out == INVALID_HANDLE_VALUE)
  {
     return Fail("Die Screenshotdatei existiert nicht!");
  }
  SaveBMPToFile(surf,this->Primaer, file_out);
  CloseHandle(file_out);

 return TRUE;
}

BOOL Engine_Graphics::SaveBMPToFile (LPDIRECTDRAWSURFACE SaveSurface,LPDIRECTDRAWSURFACE FrontBuffer, HANDLE file_out)
{
 HRESULT           rval;
 DWORD             numwrite;
 BITMAPFILEHEADER  fh;
 BITMAPINFOHEADER  bi;
 DWORD             outpixel;
 int               outbyte, loop, loop2, BufferIndex;
 BYTE              *WriteBuffer; 
 DDSURFACEDESC     ddsd;
 int              Width, Height, Pitch;

  //First we need a ddsdription of the surface
  ZeroMemory(&ddsd,sizeof(ddsd));
  ddsd.dwSize=sizeof(ddsd);
  rval = SaveSurface -> GetSurfaceDesc (&ddsd);
  if (rval != DD_OK)
  {
          return Fail("Couldn't get surface ddsd for bitmap save"); 
  }

  //Setup output buffer stuff, since Windows has paging and we're in flat mode, I just made
  //it as big as the bitmap 
  BufferIndex = 0;
  Width = ddsd.dwWidth;
  Height = ddsd.dwHeight;
  Pitch = ddsd.lPitch;
  WriteBuffer = new BYTE [Width* Height * 3];  //width*height*24-bit

  //Write the file header
  ((char *)&(fh . bfType))[0] = 'B';
  ((char *)&(fh . bfType))[1] = 'M';
  fh . bfSize = (long)(sizeof (BITMAPINFOHEADER)+sizeof (BITMAPFILEHEADER)+Width*Height*3); //Size in BYTES
  fh . bfReserved1 = 0;
  fh . bfReserved2 = 0;
  fh . bfOffBits = sizeof (BITMAPINFOHEADER)+sizeof (BITMAPFILEHEADER);
  bi . biSize = sizeof (BITMAPINFOHEADER);
  bi . biWidth =Width;
  bi . biHeight =Height;
  bi . biPlanes = 1;
  bi . biBitCount = 24;
  bi . biCompression = BI_RGB;
  bi . biSizeImage = 0;
  bi . biXPelsPerMeter = 10000;
  bi . biYPelsPerMeter = 10000;
  bi . biClrUsed = 0;
  bi . biClrImportant = 0;

  WriteFile (file_out, (char *) &fh,sizeof (BITMAPFILEHEADER),&numwrite,NULL);
  WriteFile (file_out, (char *) &bi,sizeof (BITMAPINFOHEADER),&numwrite,NULL);
  if (ddsd.ddpfPixelFormat.dwRGBBitCount==32)    //16 bit surfaces
  {

                          //lock the surface and start filling the output
                          //buffer
                                ZeroMemory(&ddsd,sizeof(ddsd));
								ddsd.dwSize=sizeof(ddsd);
                                rval = SaveSurface -> Lock(NULL,&ddsd, DDLOCK_WAIT,NULL);
                                if (rval != DD_OK)
                                {
                                    delete [] WriteBuffer;
									return Fail("Couldn't lock source");
                                }

                                BYTE *Bitmap_in = (BYTE*)ddsd.lpSurface;


                                         for (loop =Height-1;loop>=0;loop--)    //Loop bottom up
                                         for (loop2=0;loop2<Width;loop2++)
                                          {

                                           outpixel = *((DWORD *)(Bitmap_in+loop2*4 + loop * Pitch)); //Load a word


                                           //Load up the Blue component and output it
                                           
                                           outbyte = (((outpixel)&0x000000ff));//blue
                                           WriteBuffer [BufferIndex++] = outbyte;

                                           //Load up the green component and output it 

                                           outbyte = (((outpixel>>8)&0x000000ff)); 
                                                WriteBuffer [BufferIndex++] = outbyte;

                                           //Load up the red component and output it 

                                           outbyte = (((outpixel>>16)&0x000000ff));
                                           WriteBuffer [BufferIndex++] = outbyte;
                                          }


                                 //At this point the buffer should be full, so just write it out

                                        WriteFile (file_out, WriteBuffer,BufferIndex,&numwrite,NULL);

                                //Now unlock the surface and we're done

                                        SaveSurface -> Unlock(NULL);

 }
 if (ddsd.ddpfPixelFormat.dwRGBBitCount==24)    //24 bit surfaces
 {
                  //So easy just lock the surface and output

                          //lock the surface and start filling the output
                          //buffer

                                ZeroMemory(&ddsd,sizeof(ddsd));
								ddsd.dwSize=sizeof(ddsd);
                                rval = SaveSurface -> Lock(NULL,&ddsd, DDLOCK_WAIT,NULL);
                                if (rval != DD_OK)
                                {
                                        delete [] WriteBuffer;
                                        return Fail("Couldn't lock source");
                                }

                                BYTE *Bitmap_in = (BYTE*)ddsd.lpSurface;

                                 for (loop =Height-1;loop>=0;loop--)    //Loop bottom up
                                 for (loop2=0;loop2<Width;loop2++)
                                  {

                                   //Load up the Blue component and output it
                                   
                                   WriteBuffer [BufferIndex++] = *(Bitmap_in+loop2*3+2 + loop * Pitch); //Bug fix 6-5

                                   //Load up the green component and output it 

                                   WriteBuffer [BufferIndex++] = *(Bitmap_in+loop2*3+ 1 + loop * Pitch); //Bug fix 6-5

                                   //Load up the red component and output it 

                                   WriteBuffer [BufferIndex++] = *(Bitmap_in+loop2*3 + loop * Pitch);
                                  }
                                    
                                 //At this point the buffer should be full, so just write it out

                                        WriteFile (file_out, WriteBuffer,BufferIndex,&numwrite,NULL);

                                //Now unlock the surface and we're done

                                        SaveSurface -> Unlock(NULL);


 }
 else if (ddsd.ddpfPixelFormat.dwRGBBitCount==16)       //16 bit surfaces
 {

                          //lock the surface and start filling the output
                          //buffer

                                ZeroMemory(&ddsd,sizeof(ddsd));
								ddsd.dwSize=sizeof(ddsd);
                                rval = SaveSurface -> Lock(NULL,&ddsd, DDLOCK_WAIT,NULL);
                                if (rval != DD_OK)
                                {
                                        delete [] WriteBuffer;
                                        return Fail("Couldn't lock source");
                                }

                                BYTE *Bitmap_in = (BYTE*)ddsd.lpSurface;


                          /*

                          According to DirectX docs, dwRGBBitCount is 2,4,8,16,24,32, BUT what about 15-bit surfaces
                          (5,5,5) I don't really know if its needed but here we check the green bitmask to see
                          if 5 or 6 bits are used for green.
                          
                          If the green bitmask equals 565 mode, do 16-bit mode, otherwise do 15-bit mode
                          NOTE: We are reversing the component order (ie. BGR instead of RGB)
                                and we are outputting it bottom up because BMP files are backwards and upside down.

                          */

                                if (ddsd .ddpfPixelFormat . dwGBitMask ==  0x07E0)
                                  {
                                         for (loop =Height-1;loop>=0;loop--)    //Loop bottom up
                                         for (loop2=0;loop2<Width;loop2++)
                                          {

                                           outpixel = *((WORD *)(Bitmap_in+loop2*2 + loop * Pitch)); //Load a word


                                           //Load up the Blue component and output it
                                           
                                           outbyte = (8*((outpixel)&0x001f));//blue
                                           WriteBuffer [BufferIndex++] = outbyte;

                                           //Load up the green component and output it 

                                           outbyte = (4*((outpixel>>5)&0x003f)); 
                                                WriteBuffer [BufferIndex++] = outbyte;

                                           //Load up the red component and output it 

                                           outbyte = (8*((outpixel>>11)&0x001f));
                                           WriteBuffer [BufferIndex++] = outbyte;
                                          }
                                    
                                   }
                                 else //Assume 555 mode. 15-bit mode
                                   {
                                         for (loop =Height-1;loop>=0;loop--)    //Loop bottom up
                                         for (loop2=0;loop2<Width;loop2++)
                                          {

                                           outpixel = *((WORD *)(Bitmap_in+loop2*2 + loop * Pitch)); //Load a word

                                           //Load up the Blue component and output it
                                           
                                           outbyte = (8*((outpixel)&0x001f));//blue
                                           WriteBuffer [BufferIndex++] = outbyte;

                                           //Load up the green component and output it 

                                           outbyte = (8*((outpixel>>5)&0x001f)); 
                                                WriteBuffer [BufferIndex++] = outbyte;

                                           //Load up the red component and output it 

                                           outbyte = (8*((outpixel>>10)&0x001f));  //BUG FIX here
                                           WriteBuffer [BufferIndex++] = outbyte;
                                          }
                                 }

                                 //At this point the buffer should be full, so just write it out

                                        WriteFile (file_out, WriteBuffer,BufferIndex,&numwrite,NULL);

                                //Now unlock the surface and we're done

                                        SaveSurface -> Unlock(NULL);

 }
 else  if (ddsd.ddpfPixelFormat.dwRGBBitCount==8) //8 bit surfaces
 {
        //Get the system palette so we can index each pixel to its corresponding color, this
        //is what the frontbuffer parameter is needed for

                        if (FrontBuffer == NULL)
                        {
                                delete [] WriteBuffer;
                                return Fail("No Front Buffer for 8-bit BMP save");

                        }

                        LPDIRECTDRAWPALETTE Pal;
                        char bytepal [256*4];

                        rval = FrontBuffer -> GetPalette(&Pal);
                        if (rval != DD_OK)
                        {
                                delete [] WriteBuffer;
                                 return Fail("Surface - Couldn't get palette for 8-bit Bitmap Save");
                        }

                        Pal -> GetEntries (0,0,256,(tagPALETTEENTRY *)&(bytepal[0]));
                        Pal -> Release();

          //lock the surface and start filling the output
          //buffer

                        ZeroMemory(&ddsd,sizeof(ddsd));
						ddsd.dwSize=sizeof(ddsd);
                        rval = SaveSurface -> Lock(NULL,&ddsd, DDLOCK_WAIT,NULL);
                        if (rval != DD_OK)
                        {
                                delete [] WriteBuffer;
                                return Fail("Couldn't lock source");
                        }

                        BYTE *Bitmap_in = (BYTE*)ddsd.lpSurface;

         //Ok, now that we've got the palette and the 24-bit entries, we just look up the color and output it
         //NOTE: At the same time we are reversing the component order (ie. BGR instead of RGB)
         //      and we are outputting it bottom up. 

                         for (loop =Height-1;loop>=0;loop--)    //Loop bottom up
                         for (loop2=0;loop2<Width;loop2++)
                          {
                           outpixel = *(Bitmap_in+loop2 + loop * Pitch); //Load a byte from the surface

                           //Load up the Blue component and output it

                           outbyte = bytepal[outpixel*4+2];//blue
                           WriteBuffer [BufferIndex++] = outbyte;

                           //Load up the Green component and output it

                           outbyte = bytepal[outpixel*4+1];//green
                                WriteBuffer [BufferIndex++] = outbyte;

                           //Load up the Red component and output it

                           outbyte = bytepal[outpixel*4];//red
                                WriteBuffer [BufferIndex++] = outbyte;
                          }

                                 //At this point the buffer should be full, so just write it out

                                        WriteFile (file_out, WriteBuffer,BufferIndex,&numwrite,NULL);

                                //Now unlock the surface and we're done

                                        SaveSurface -> Unlock(NULL);
  }

  delete [] WriteBuffer;

 return TRUE;
}
