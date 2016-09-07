 
#include "engine.h"
#include <stdio.h>

BOOL Done = FALSE;
Engine_Info     info;
Engine_Graphics graph;
Engine_Input input;
Engine_Sound sound;

long FAR PASCAL WindowProc( HWND hWnd, UINT message, 
                            WPARAM wParam, LPARAM lParam )
{
	switch ( message )
    {	
	case WM_SIZE:
	case WM_MOVE:
		graph.UpdateClientArea();
		break;
	case WM_KEYDOWN:
			switch ( wParam )
			{
			case VK_ESCAPE:
				PostMessage ( hWnd, WM_CLOSE, 0, 0 );
            break;
			}
	break;

	case WM_DESTROY:
		input.ReleaseObjects();
       // sound.ReleaseObjects();
		graph.ReleaseObjects();
		PostQuitMessage( 0 );
    break;
            
	}
    return DefWindowProc( hWnd, message, wParam, lParam);
}

int PASCAL WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    LPSTR lpCmdLine, int nCmdShow )
{
    MSG         msg;

    lpCmdLine = lpCmdLine;
    hPrevInstance = hPrevInstance;

	info.AppName = "WARS!";
	info.WindowTitle = "WARS!";
	info.DoWindowStuffFullscreen(hInstance,WindowProc,nCmdShow);

	graph.info = info;
	graph.SetGraphicsType(GRAPHICSTYPE_2D);
	graph.InitDirectDraw(640,480,16,TRUE,FALSE);

	Engine_AVIStream avi;
	avi.En_Graph=graph;
	avi.Load("we08.avi");
	avi.PlayOnSurface(graph.Primaer,TRUE);
	    
	    while(1)
    	{
		if(PeekMessage(&msg, NULL,0,0,PM_NOREMOVE))
		{
			if(!GetMessage (&msg, NULL, 0, 0)) return msg.wParam;
			TranslateMessage (&msg);
			DispatchMessage (&msg);        
		}
		else 
		{ 

		}
		}

return msg.wParam;
}


