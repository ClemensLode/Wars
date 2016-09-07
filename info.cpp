#include "engine.h"

BOOL Engine_Info::DoWindowStuffFullscreen(HINSTANCE hInstance,WNDPROC WindowProc,int nCmdShow)
{
    WNDCLASS            wc;

    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc = WindowProc;
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hInstance = hInstance;
	this->hInstance = hInstance;
    wc.hIcon = LoadIcon( hInstance, IDI_APPLICATION );
    wc.hCursor = LoadCursor( NULL, IDC_ARROW );
    wc.hbrBackground = NULL;
    wc.lpszMenuName = AppName;
    wc.lpszClassName = AppName;
    RegisterClass( &wc );
    

    hwnd = CreateWindowEx(
        WS_EX_TOPMOST,
        AppName,
        WindowTitle,
        WS_POPUP,
        0, 0,
        GetSystemMetrics( SM_CXSCREEN ),
        GetSystemMetrics( SM_CYSCREEN ),
        NULL,
        NULL,
        hInstance,
        NULL );

    if ( !hwnd )
    {
        return FALSE;
    }
    ShowWindow( hwnd, nCmdShow );
    UpdateWindow( hwnd );

return TRUE;
}
BOOL Engine_Info::DoWindowStuff(HINSTANCE hInstance,WNDPROC WindowProc,int nCmdShow,LPCSTR Menu)
{
     WNDCLASSEX  wndclass ;
	 
     wndclass.cbSize        = sizeof (wndclass) ;
     wndclass.style         = CS_HREDRAW | CS_VREDRAW ;
     wndclass.lpfnWndProc   = WindowProc ;
     wndclass.cbClsExtra    = 0 ;
     wndclass.cbWndExtra    = 0 ;
     wndclass.hInstance     = hInstance ;
     this->hInstance = hInstance;
	 wndclass.hIcon         = LoadIcon (NULL, IDI_APPLICATION) ;
     wndclass.hCursor       = LoadCursor (NULL, IDC_ARROW) ;
     wndclass.hbrBackground = (HBRUSH) GetStockObject (WHITE_BRUSH) ;
     wndclass.lpszMenuName  = Menu;
     wndclass.lpszClassName = AppName ;
     wndclass.hIconSm       = LoadIcon (NULL, IDI_APPLICATION) ;

     RegisterClassEx (&wndclass) ;

     hwnd = CreateWindow (AppName,         
		            WindowTitle,     
                    WS_OVERLAPPEDWINDOW,     
                    CW_USEDEFAULT,           
                    CW_USEDEFAULT,           
                    CW_USEDEFAULT,           
                    CW_USEDEFAULT,           
                    NULL,                   
                    NULL,                    
                    hInstance,               
		            NULL) ;		             

     if ( !hwnd )
    {
        return FALSE;
    }
	 
	 ShowWindow (hwnd, nCmdShow) ;
     UpdateWindow (hwnd) ;

return TRUE;
}

void Engine_Info::EndApp()
{
	DestroyWindow(this->hwnd);
}