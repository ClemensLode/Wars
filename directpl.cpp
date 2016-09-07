#include "engine.h"
#include "resource.h"

LRESULT CALLBACK DPDialog(HWND,UINT,WPARAM,LPARAM);
LPDIRECTPLAY3 dp;
HWND hwnd;

BOOL Engine_Multiplayer::InitDirectPlay()
{
	CoInitialize(NULL);

	if(FAILED(CoCreateInstance(CLSID_DirectPlay,NULL,CLSCTX_ALL,
		                       IID_IDirectPlay3A,(LPVOID*)&info.lpDP)))
	{
		return Fail("Fehler beim Anlegen von DirectPlay");
	}
return TRUE;
}

void Engine_Multiplayer::ChooseConnection(void)
{
	dp = (IDirectPlay3*)info.lpDP;
	hwnd = (HWND)info.hwnd;
	DialogBox((HINSTANCE)info.hInstance,(LPCTSTR)IDD_CHCONNECTION,info.hwnd,
		       (DLGPROC)DPDialog);
}

BOOL Engine_Multiplayer::Fail( char *szMsg)
{
    ReleaseObjects();
	OutputDebugString( szMsg );

	MessageBox(info.hwnd, szMsg, info.AppName, MB_OK);
    DestroyWindow( info.hwnd );
    return FALSE;
}
		
BOOL WINAPI EnumConnection( LPCGUID lpguidSP,
                            LPVOID lpConnection, DWORD dwSize,
                            LPDPNAME lpName, DWORD dwFlags, 
                            LPVOID lpContext )
{
    LONG            iIndex;
    HWND hWnd       = ( HWND ) lpContext;
    LPVOID          lpOurConnection = NULL;
    LPDIRECTPLAY3   lpDPTemp;

    if FAILED( CoCreateInstance( CLSID_DirectPlay,
                NULL, CLSCTX_ALL, IID_IDirectPlay3A,
                ( LPVOID* ) &lpDPTemp ) )
    {
        return( FALSE );
    }

    if FAILED( lpDPTemp->InitializeConnection( lpConnection, 0 ) )
    {
        lpDPTemp->Release();
        return( TRUE );
    }
    lpDPTemp->Release();

    iIndex = SendMessage( hWnd, CB_ADDSTRING, 0, 
                            (LPARAM) lpName->lpszShortNameA );


    if ( iIndex != LB_ERR )
    {
        lpOurConnection = malloc( dwSize );
        if ( !lpOurConnection ) return FALSE;

        memcpy( lpOurConnection, lpConnection, dwSize );

        SendMessage( hWnd, CB_SETITEMDATA, iIndex, 
                            ( LPARAM ) lpOurConnection );
    }
    else 
    {
        return FALSE;
    }

    return( TRUE );
}

void Engine_Multiplayer::ReleaseObjects(void)
{
	RELEASE(info.lpDP);
}

LRESULT CALLBACK DPDialog( HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch( message )
	{
		case WM_INITDIALOG:	
		dp->EnumConnections(NULL,(LPDPENUMCONNECTIONSCALLBACK)EnumConnection,
		       (LPVOID)GetDlgItem(hwnd,IDC_CONNECTIONS),0);
			return TRUE;

		case WM_COMMAND:
			if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL) 
			{
				EndDialog(hDlg, LOWORD(wParam));
				return TRUE;
			}
			break;
	}
    return FALSE;
}
