#include "engine.h"
#include "wave.h"

BOOL Engine_Sound::InitDirectSound(BOOL CreatePrimary3D,int channels,int freq,int bits)
{
   if(!CreatePrimary3D)
   {
	   DirectSoundCreate( NULL, &info.lpDS, NULL );
       info.lpDS->SetCooperativeLevel( info.hwnd, DSSCL_NORMAL );
   }
   else
   {
	   DirectSoundCreate( NULL, &info.lpDS, NULL );
	   info.lpDS->SetCooperativeLevel( info.hwnd, DSSCL_PRIORITY );

       ZeroMemory( &dsbdesc, sizeof( DSBUFFERDESC ) );
       dsbdesc.dwSize = sizeof( DSBUFFERDESC );
       dsbdesc.dwFlags = DSBCAPS_CTRL3D | DSBCAPS_PRIMARYBUFFER;
       if ( FAILED( info.lpDS->CreateSoundBuffer( &dsbdesc, &Primaer, NULL ) ) )
            return FALSE;

	   memset( &wfm, 0, sizeof( WAVEFORMATEX ) ); 
       wfm.wFormatTag = WAVE_FORMAT_PCM; 
       wfm.nChannels = channels; 
       wfm.nSamplesPerSec = freq; 
       wfm.wBitsPerSample = bits; 
       wfm.nBlockAlign = wfm.wBitsPerSample / 8 * wfm.nChannels;
       wfm.nAvgBytesPerSec = wfm.nSamplesPerSec * wfm.nBlockAlign;

	   Primaer->SetFormat( &wfm ); 

       if ( FAILED( Primaer->QueryInterface( 
		      IID_IDirectSound3DListener,
              ( LPVOID * )&Listener ) ) )
	   {
		  Primaer->Release();  
		  return FALSE;
	   }
    
	   Primaer->Release();
   }
		
return TRUE;
}

void Engine_Sound::ReleaseObjects()
{
   RELEASE(this->Listener);
   RELEASE(info.lpDS);
}

void Engine_Sound::LoadStatic(LPDIRECTSOUNDBUFFER *buffer,char* filename)
{
	HMMIO wavefile;
	wavefile = mmioOpen(filename,0,MMIO_READ|MMIO_ALLOCBUF);
	if(wavefile==NULL) 
		return ;
	
	MMCKINFO parent;
	memset(&parent,0,sizeof(MMCKINFO));
	parent.fccType = mmioFOURCC('W','A','V','E');
	mmioDescend(wavefile,&parent,0,MMIO_FINDRIFF);

	MMCKINFO child;
	memset(&child,0,sizeof(MMCKINFO));
	child.fccType = mmioFOURCC('f','m','t',' ');
	mmioDescend(wavefile,&child,&parent,0);

	WAVEFORMATEX wavefmt;
	mmioRead(wavefile,(char*)&wavefmt,sizeof(wavefmt));
	if(wavefmt.wFormatTag != WAVE_FORMAT_PCM)
		return ;


	mmioAscend(wavefile,&child,0);
	child.ckid = mmioFOURCC('d','a','t','a');
	mmioDescend(wavefile,&child,&parent,MMIO_FINDCHUNK);


	DSBUFFERDESC bufdesc;
	memset(&bufdesc,0,sizeof(DSBUFFERDESC));
	bufdesc.dwSize = sizeof(DSBUFFERDESC);
	bufdesc.dwFlags = DSBCAPS_CTRLDEFAULT;
	bufdesc.dwBufferBytes = child.cksize;
	bufdesc.lpwfxFormat = &wavefmt;
	if(DS_OK != (info.lpDS->CreateSoundBuffer(&bufdesc,&(*buffer),NULL)))
		return ;
	
	void *write1=0,*write2=0;
	unsigned long length1,length2;
	(*buffer)->Lock(0,child.cksize,&write1,&length1,&write2,&length2,0);
	if(write1>0)
		mmioRead(wavefile,(char*)write1,length1);
	if(write2>0)
		mmioRead(wavefile,(char*)write2,length2);
	(*buffer)->Unlock(write1,length1,write2,length2);

	mmioClose(wavefile,0);
return ;
}

void Engine_Sound::PlayStatic(IDirectSoundBuffer *snd,BOOL loop)
{
   snd->SetCurrentPosition( 0 );
   if(!loop) 
	   snd->Play(0,0,0);   
   else
	   snd->Play(0,0,DSBPLAY_LOOPING);
}  

void Engine_Sound::PanMove(IDirectSoundBuffer *buffer,int dir)
{
	LONG pan;
	buffer->GetPan(&pan);
	if(dir==PANPLUS) 
		buffer->SetPan(pan+10);
    else
		buffer->SetPan(pan-10);
}

void Engine_Sound::VolumeMove(IDirectSoundBuffer *buffer,int dir)
{
	LONG vol;
	buffer->GetVolume(&vol);
	if(dir==VOLPLUS)
		buffer->SetVolume(vol+10);
	else
		buffer->SetVolume(vol-10);
}

void Engine_Sound::Stop(IDirectSoundBuffer *snd)
{
	snd->Stop();
}

void Engine_Sound::FreqMove(IDirectSoundBuffer *buffer,int dir)
{
	DWORD freq;
	buffer->GetFrequency(&freq);
	if(dir==FREQPLUS) 
		buffer->SetFrequency(freq+500);
    else
		buffer->SetFrequency(freq-500);
}

void Engine_Sound::TurnSound(IDirectSoundBuffer *buffer,int dir)
{
	DWORD pos;
	buffer->GetCurrentPosition(&pos,NULL);
	if(dir==TURNPLUS)
		buffer->SetCurrentPosition(pos+10);
	else
		buffer->SetCurrentPosition(pos-10);
}

BOOL Engine_Sound::LoadStreamBuffer(IDirectSoundBuffer *lpdsb,LPSTR lpzFileName )
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

    if ( WaveOpenFile( lpzFileName, &hmmio, &pwfx, &mmckinfoParent ) != 0 )
        return FALSE;
    if ( WaveStartDataRead( &hmmio, &mmckinfo, &mmckinfoParent ) != 0 )
        return FALSE;

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

BOOL Engine_Sound::PlayStreamBuffer(IDirectSoundBuffer *lpdsb)
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
	IDirectSound *dstemp;

	DirectSoundCreate(NULL,&dstemp,NULL);
	
	ds_dinf.HW_EMULDRIVER=FALSE;ds_dinf.HW_MSCERTIFIED=FALSE;ds_dinf.HW_PB16=FALSE;
	ds_dinf.HW_PB8=FALSE;ds_dinf.HW_PMONO=FALSE;ds_dinf.HW_PSTEREO=FALSE;ds_dinf.HW_SB16=FALSE;
	ds_dinf.HW_SB8=FALSE;ds_dinf.HW_SMONO=FALSE;ds_dinf.HW_SSTEREO=FALSE;

	dscaps.dwSize = sizeof(dscaps);
	dstemp->GetCaps(&dscaps);

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
    
	dstemp->Release();
}


