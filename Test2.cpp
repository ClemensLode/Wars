#define NAME "Pre-WARS! Entwicklungsversion"
#define TITLE "WARS!"
#define WIN32_LEAN_AND_MEAN
#include "engine.h"
#include <stdio.h>
#include "path.h"
#include "Welt.h"
#include "graph.h"
#include "IO.h"

Input input;
extern Graph graph;
Welt welt;
extern Engine_Graphics screen;

#define TIMER_ID     1  // Timer Identifier
#define TIMER_RATE 100  // Timerintervall

Engine_Info     info;
BOOL            Done;

BOOL doInit( HINSTANCE , int  );


long FAR PASCAL WindowProc( HWND hWnd, UINT message, 
                            WPARAM wParam, LPARAM lParam )
{
	int tx;
	switch ( message )
    {
	case WM_CREATE:
		break;
	case WM_MOUSEMOVE:input.Move(lParam);break;
	case WM_LBUTTONDOWN:input.LDown();break;
	case WM_LBUTTONUP:input.LUp();break;
	case WM_MBUTTONUP:input.MUp();break;
	case WM_RBUTTONDOWN:input.RDown();break;
	case WM_RBUTTONUP:input.RUp();break;
	case WM_TIMER: // was tun , wenn der Timer sich meldet ?
  		for(tx=0;tx<KARTEMEM;tx++) welt.area[tx].Besetzt=0;
		for(tx=0;tx<ANZMANN;tx++) if(leut[tx].basic.vorhanden==1)
		{
			leut[tx].schritt(tx);
			if(leut[tx].laenge==0) leut[tx].action();
		};
/*		for(tx=0;tx<ANZHAUS;tx++) if(haus[tx].basic.vorhanden==1)
		{
			if(haus[tx].Stoff[BEEREN]>10) 
			{
				haus[tx].Stoff[BEEREN]-=10;
				haus[tx].Neuer_Leut(tx);
			}
		};*/
		input.Scroll_mouse();
		input.Update_scroll();
		welt.calculateXY();
   		welt.On_screen();
		break;
	case WM_KEYDOWN:
			switch ( wParam )
			{
			
			case VK_DOWN:input.Scroll(DOWN);break;
			case VK_UP:input.Scroll(UP);break;
			case VK_LEFT:input.Scroll(LEFT);break;
			case VK_RIGHT:input.Scroll(RIGHT);break;		
			
			case VK_ESCAPE:
				PostMessage ( hWnd, WM_CLOSE, 0, 0 );
			break;
			}
	break;

	case WM_DESTROY:
		 screen.ReleaseObjects();
  		 KillTimer(info.hwnd,TIMER_ID);
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
	screen.info = info;
	screen.InitDirectDraw(800,600,16,TRUE,TRUE);
	graph.Init_Sprites();
/*	sound.hwnd = hwnd;
	sound.InitDirectSound(2,22050,8);           // initialisiere DirectSound (Kanäle,Kilohertz,Bits)
	sound.LoadStatic(".wav");              // lade statischen (kurzen) sound
    sound.LoadStreamBuffer("priv_001.wav");      // lade einen streambaren (langen) sound*/
    screen.BufferClear(screen.BackBuffer,0,0,0);
    SetTimer(info.hwnd,TIMER_ID,TIMER_RATE,NULL); // Timersetzung
    welt.Es_werde_Licht();
	graph.Fuelle_Daten();
  	welt.Plaziere_Objekte();
    while ( !Done )
    {
        while ( PeekMessage( &msg, NULL, 0, 0, PM_REMOVE ) ) 
        {
            if ( msg.message == WM_QUIT ) 
            {
                Done = TRUE;
            } 
            else
            {
                TranslateMessage( &msg );
                DispatchMessage( &msg );
            }
        }
    }

return msg.wParam;
}