#include "engine.h"

BOOL Engine_Input::InitDirectInput()
{
	DirectInputCreate(info.hInstance,DIRECTINPUT_VERSION,&info.lpDI,NULL);
return TRUE;
}

IDirectInputDevice2 *Engine_Input::CreateDevice2(GUID *pguid)
{
	HRESULT hr,hr2;

	LPDIRECTINPUTDEVICE lpdid1;
	LPDIRECTINPUTDEVICE2 lpdid2;

	hr = info.lpDI->CreateDevice(*pguid,&lpdid1,NULL);

	if (SUCCEEDED(hr))
	{
		hr2 = lpdid1->QueryInterface(IID_IDirectInputDevice2,(void**)&lpdid2);
		lpdid1->Release();
	}
	else
	{
		OutputDebugString("Engine_Input::CreateDevice(QueryInterface)");
		return NULL;
	}
	if (FAILED(hr2))
	{
		OutputDebugString("Keine DID2-Schnittstelle");
		return NULL;
	}
return lpdid2;
}

BOOL Engine_Input::InstallKeyboard()
{
	DIPROPDWORD dipdw;
    Keyboard = this->CreateDevice2((GUID*)&GUID_SysKeyboard);

	Keyboard->SetDataFormat( &c_dfDIKeyboard );
	
	Keyboard->SetCooperativeLevel(info.hwnd,DISCL_NONEXCLUSIVE |
		                          DISCL_FOREGROUND );

    dipdw.diph.dwSize = sizeof( DIPROPDWORD );
	dipdw.diph.dwHeaderSize = sizeof( DIPROPHEADER );
	dipdw.diph.dwSize = 0;
	dipdw.diph.dwHow = DIPH_DEVICE;
	dipdw.dwData = 0;
    Keyboard->SetProperty( DIPROP_BUFFERSIZE, &dipdw.diph );
	this->Keyboard->Acquire();
return TRUE;
}

BOOL Engine_Input::InstallMouse()
{
	DIPROPDWORD dipdw;
	Mouse = CreateDevice2((GUID*)&GUID_SysMouse);

   	Mouse->SetDataFormat( &c_dfDIMouse );
	Mouse->SetCooperativeLevel(info.hwnd,DISCL_NONEXCLUSIVE |
		                          DISCL_BACKGROUND ); 

    dipdw.diph.dwSize = sizeof( DIPROPDWORD );
	dipdw.diph.dwHeaderSize = sizeof( DIPROPHEADER );
	dipdw.diph.dwSize = 0;
	dipdw.diph.dwHow = DIPH_DEVICE;
	dipdw.dwData = 0;

	Mouse->SetProperty( DIPROP_BUFFERSIZE, &dipdw.diph );
	
return TRUE;
}

void Engine_Input::ReleaseObjects()
{
    if ( Keyboard != NULL ) 
    {
        Keyboard->Unacquire();
		Keyboard->Release();
        Keyboard = NULL;
    }

    if ( Mouse != NULL ) 
    {
        Mouse->Unacquire();
		Mouse->Release();
        Mouse = NULL;
    }

    if ( info.lpDI != NULL )
    { 
        info.lpDI->Release();
        info.lpDI = NULL;
    }
}


