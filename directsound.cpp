#include "engine.h"
#include "wave.h"

BOOL Engine_Sound::InitDirectSound(int channels,int khz,int bits)
{

    if ( FAILED( hr = DirectSoundCreate( NULL, &info.lpDS, NULL ) ) )
        return FALSE;

    if ( FAILED( hr = info.lpDS->SetCooperativeLevel( info.hwnd, DSSCL_PRIORITY ) ) )
        return FALSE;

    dscaps.dwSize = sizeof( DSCAPS );
    hr = info.lpDS->GetCaps( &dscaps );

    memset(&dsbdesc,0,sizeof( DSBUFFERDESC ));
    dsbdesc.dwSize = sizeof( DSBUFFERDESC );
	dsbdesc.dwFlags = DSBCAPS_PRIMARYBUFFER;
	dsbdesc.dwBufferBytes = 0;
	dsbdesc.lpwfxFormat = NULL;

	memset( &wfm,0,sizeof( WAVEFORMATEX ));
	wfm.wFormatTag = WAVE_FORMAT_PCM;
	wfm.nChannels = channels;
	wfm.nSamplesPerSec = khz;
	wfm.wBitsPerSample = bits;
	wfm.nBlockAlign = wfm.wBitsPerSample / 8 * wfm.nChannels ;
	wfm.nAvgBytesPerSec = wfm.nSamplesPerSec * wfm.nBlockAlign ;

    hr = info.lpDS->CreateSoundBuffer( &dsbdesc,&Primaer,NULL);

	if (SUCCEEDED(hr))
	{
		hr = Primaer->SetFormat( &wfm );
	}

	return TRUE;
}

void Engine_Sound::ReleaseObjects()
{
    if ( info.lpDS != NULL )
    {
        if ( Primaer != NULL )
        {
            Primaer->Release();
            Primaer = NULL;
        }         
		info.lpDS->Release();
        info.lpDS = NULL;
	}
}

BOOL Engine_Sound::LoadStatic(LPSTR lpzFileName)
{
	WAVEFORMATEX  *pwfx;         
	HMMIO         hmmio;          
	MMCKINFO      mmckinfo;      
	MMCKINFO      mmckinfoParent; 

    if ( WaveOpenFile( lpzFileName, &hmmio, &pwfx, &mmckinfoParent ) != 0 )
        return FALSE;
 
    if ( WaveStartDataRead( &hmmio, &mmckinfo, &mmckinfoParent ) != 0 )
        return FALSE;

 
 
    DSBUFFERDESC         dsbdesc;


    if ( Static == NULL )
    {
        memset( &dsbdesc, 0, sizeof( DSBUFFERDESC ) ); 
        dsbdesc.dwSize = sizeof( DSBUFFERDESC ); 
        dsbdesc.dwFlags = DSBCAPS_STATIC; 
        dsbdesc.dwBufferBytes = mmckinfo.cksize;  
        dsbdesc.lpwfxFormat = pwfx; 
 
        if ( FAILED( info.lpDS->CreateSoundBuffer( 
                &dsbdesc, &Static, NULL ) ) )
        {
            WaveCloseReadFile( &hmmio, &pwfx );
            return FALSE; 
        }
    }

    LPVOID lpvAudio1;
    DWORD  dwBytes1;

	if ( FAILED( Static->Lock(
        0,           
        0,            
        &lpvAudio1,      
                       
        &dwBytes1,     
        NULL,            
                      
        NULL,         
        DSBLOCK_ENTIREBUFFER ) ) )  
    {
      
        WaveCloseReadFile( &hmmio, &pwfx );
        return FALSE;
    }
 
    UINT cbBytesRead;
 
	if ( WaveReadFile( hmmio,    
		    dwBytes1,            
			( BYTE * )lpvAudio1,  
			&mmckinfo,            
			&cbBytesRead ) )     
                              
    {
       
        WaveCloseReadFile( &hmmio, &pwfx );
        return FALSE;
    }

    Static->Unlock( lpvAudio1, dwBytes1, NULL, 0 );

    WaveCloseReadFile( &hmmio, &pwfx );

    return TRUE;
    this->datei = lpzFileName;
}

void Engine_Sound::PlayStatic(void)
{
    HRESULT hr;

    if ( Static == NULL ) return;

    Static->SetCurrentPosition( 0 );
    hr = Static->Play( 0, 0, 0 );   
    if ( hr == DSERR_BUFFERLOST )
    {
        if ( SUCCEEDED( Static->Restore() ) )
        {
           if ( LoadStatic( datei ) )
                Static->Play( 0, 0, 0 );
        }
    }
}

BOOL Engine_Sound::LoadStreamBuffer(LPSTR lpzFileName )
{
    DSBUFFERDESC    dsbdesc;
    HRESULT         hr;
    
	if ( lpdsb != NULL )
         lpdsb->Stop();
	
	WaveCloseReadFile( &hmmio, &pwfx );
    if ( lpdsb != NULL )
    {
        lpdsb->Release();
        lpdsb = NULL;
    }

    // Datei öffnen, Datenformat lesen und weiter bis zum data-Chunk
    if ( WaveOpenFile( lpzFileName, &hmmio, &pwfx, &mmckinfoParent ) != 0 )
        return FALSE;
    if ( WaveStartDataRead( &hmmio, &mmckinfo, &mmckinfoParent ) != 0 )
        return FALSE;

    // Sekundären Puffer mit 2 Sekunden Spieldauer anlegen
    memset( &dsbdesc, 0, sizeof( DSBUFFERDESC ) ); 
    dsbdesc.dwSize = sizeof( DSBUFFERDESC ); 
    dsbdesc.dwFlags = DSBCAPS_GETCURRENTPOSITION2 
                    | DSBCAPS_GLOBALFOCUS
                    | DSBCAPS_CTRLPAN; 
    dsbdesc.dwBufferBytes = pwfx->nAvgBytesPerSec * 2;  
    dsbdesc.lpwfxFormat = pwfx; 
 
    if ( FAILED( hr = info.lpDS->CreateSoundBuffer( &dsbdesc, &lpdsb, NULL ) ) )
    {
        WaveCloseReadFile( &hmmio, &pwfx );
        return FALSE; 
    }

    FillBufferWithSilence( lpdsb );
    hr = lpdsb->Play( 0, 0, DSBPLAY_LOOPING );

    dwMidBuffer = dsbdesc.dwBufferBytes / 2;

    return TRUE;
}

BOOL Engine_Sound::PlayStreamBuffer(void)
{
	HRESULT         hr;
    DWORD           dwPlay;
    DWORD           dwStartOfs;
    static DWORD    dwLastPlayPos;
    VOID            *lpvData;
    DWORD           dwBytesLocked;
    UINT            cbBytesRead;

    if ( lpdsb == NULL ) return FALSE;

    if ( FAILED( lpdsb->GetCurrentPosition( &dwPlay, NULL ) ) ) 
		return FALSE;

    // Wenn der Abspielcursor gerade von der ersten in die zweite Hälfte
    // des Puffers gewechselt hat oder umgekehrt, dann können wir die jeweils
    // andere Hälfte des Puffers mit neuen Daten füllen
    if ( ( ( dwPlay >= dwMidBuffer ) && ( dwLastPlayPos < dwMidBuffer ) )
        || ( dwPlay < dwLastPlayPos ) )
    {
        dwStartOfs = ( dwPlay >= dwMidBuffer ) ? 0 : dwMidBuffer;

        hr = lpdsb->Lock( dwStartOfs,  // Start = 0 oder Mitte des Puffers
                    dwMidBuffer,       // Größe = halber Puffer
                    &lpvData,          // Zeiger auf den Puffer, wird gesetzt
                    &dwBytesLocked,    // Anzahl gesperrter Bytes, dito
                    NULL,              // kein zweiter Bereichsstart
                    NULL,              // keine zweite Bereichsgröße
                    0 );               // keine speziellen Flags
  
        WaveReadFile( hmmio,             // Handle der WAV-Datei
                      dwBytesLocked,     // zu lesen = Größe d. Sperrbereichs
                      ( BYTE * )lpvData, // Zieladresse
                      &mmckinfo,         // data-Chunk
                      &cbBytesRead );    // Anzahl gelesener Bytes

        if ( cbBytesRead < dwBytesLocked )  // Dateiende erreicht?
        {
            if ( WaveStartDataRead( &hmmio, &mmckinfo, &mmckinfoParent ) 
				 != 0 )
            {
               OutputDebugString( "Fehler bei Repositionierung " \
                      "auf Dateianfang.\n" );

            }
            else
            {   // die noch fehlenden Bytes einlesen
                WaveReadFile( hmmio,          
                              dwBytesLocked - cbBytesRead,
                              ( BYTE * )lpvData + cbBytesRead, 
                              &mmckinfo,      
                              &cbBytesRead );    
            }
        }

        lpdsb->Unlock( lpvData, dwBytesLocked, NULL, 0 );
    }

    dwLastPlayPos = dwPlay;
    return TRUE;
} 

BOOL Engine_Sound::FillBufferWithSilence( IDirectSoundBuffer *lpDsb )
{
    WAVEFORMATEX    wfx;
    DWORD           dwSizeWritten;

    PBYTE   pb1;
    DWORD   cb1;

    if ( FAILED( lpDsb->GetFormat( &wfx, sizeof( WAVEFORMATEX ), &dwSizeWritten ) ) )
        return FALSE;

    if ( SUCCEEDED( lpDsb->Lock( 0, 0, 
                         ( LPVOID * )&pb1, &cb1, 
                         NULL, NULL, DSBLOCK_ENTIREBUFFER ) ) )
    {
        FillMemory( pb1, cb1, ( wfx.wBitsPerSample == 8 ) ? 128 : 0 );

        lpDsb->Unlock( pb1, cb1, NULL, 0 );
        return TRUE;
    }

    return FALSE;
}


void Engine_Sound::CheckHardware(DS_DRIVERINFO ds_dinf)
{
	ds_dinf.HW_EMULDRIVER=FALSE;ds_dinf.HW_MSCERTIFIED=FALSE;ds_dinf.HW_PB16=FALSE;
	ds_dinf.HW_PB8=FALSE;ds_dinf.HW_PMONO=FALSE;ds_dinf.HW_PSTEREO=FALSE;ds_dinf.HW_SB16=FALSE;
	ds_dinf.HW_SB8=FALSE;ds_dinf.HW_SMONO=FALSE;ds_dinf.HW_SSTEREO=FALSE;

	dscaps.dwSize = sizeof(dscaps);
	info.lpDS->GetCaps(&dscaps);

	if(dscaps.dwFlags & DSCAPS_CERTIFIED) ds_dinf.HW_MSCERTIFIED = TRUE;
	if(dscaps.dwFlags & DSCAPS_EMULDRIVER) ds_dinf.HW_EMULDRIVER = TRUE;
	if(dscaps.dwFlags & DSCAPS_PRIMARY16BIT) ds_dinf.HW_PB16 = TRUE;
	if(dscaps.dwFlags & DSCAPS_PRIMARY8BIT) ds_dinf.HW_PB8 = TRUE;
	if(dscaps.dwFlags & DSCAPS_PRIMARYMONO) ds_dinf.HW_PMONO = TRUE;
	if(dscaps.dwFlags & DSCAPS_PRIMARYSTEREO) ds_dinf.HW_PSTEREO = TRUE;
	if(dscaps.dwFlags & DSCAPS_SECONDARY16BIT) ds_dinf.HW_SB16 = TRUE;
	if(dscaps.dwFlags & DSCAPS_SECONDARY8BIT) ds_dinf.HW_SB8 = TRUE;
	if(dscaps.dwFlags & DSCAPS_SECONDARYMONO) ds_dinf.HW_SMONO = TRUE;
	if(dscaps.dwFlags & DSCAPS_SECONDARYSTEREO) ds_dinf.HW_SSTEREO = TRUE;
}