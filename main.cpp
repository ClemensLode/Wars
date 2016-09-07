#define NAME "Pre-WARS! Entwicklungsversion"
#define TITLE "WARS!"
#define WIN32_LEAN_AND_MEAN
#include "engine.h"
#include <stdio.h>
#include "path.h"
#include "Welt.h"
#include "graph.h"
#include "IO.h"
BOOL Done = FALSE;
Input input;
Engine_Input DXinput;
extern Graph graph;
Welt welt;
extern Engine_Graphics screen;

#define TIMER_ID_SCHRITT  1  //Timer für Fortbewegung
#define TIMER_ID_OBJECTS 2  //Timer für neuen Bildaufbau
#define TIMER_ID_AREA 3  //Timer für neuen Bildaufbau
#define TIMER_ID_ACTION 4  //Timer für Aktionen
#define TIMER_RATE_SCHRITT 50  // Timerintervall Schritte
#define TIMER_RATE_OBJECTS 300  //Timer für neuen Bildaufbau
#define TIMER_RATE_AREA 5000  //Timer für neuen Bildaufbau
#define TIMER_RATE_ACTION 200  // Timerintervall Aktionen

Engine_Info     info;


BOOL doInit( HINSTANCE , int  );


long FAR PASCAL WindowProc( HWND hWnd, UINT message, 
                            WPARAM wParam, LPARAM lParam )
{
	int ux;
	switch ( message )
    {
	case WM_CREATE:
		break;
	case WM_MOVE:
		screen.UpdateClientArea();
		break;	
	case WM_MOUSEMOVE:input.Move(lParam);break;
	case WM_LBUTTONDOWN:input.LDown();break;
	case WM_LBUTTONUP:input.LUp();break;
	case WM_MBUTTONUP:input.MUp();break;
	case WM_RBUTTONDOWN:input.RDown();break;
	case WM_RBUTTONUP:input.RUp();break;
	case WM_TIMER: // was tun , wenn der Timer sich meldet ?
  		switch(wParam)
		{
	case TIMER_ID_SCHRITT:
		welt.Reload_Area();
		for(ux=0;ux<KARTEMEM;ux++) welt.area[ux].Besetzt=0;
		for(ux=0;ux<ANZMANN;ux++) if(leut[ux].basic.vorhanden==1) leut[ux].schritt(ux);
		input.Scroll_mouse();
		input.Update_scroll();
		break;

	case TIMER_ID_ACTION:
		for(ux=0;ux<ANZPFLANZ;ux++) pflanz[ux].grow();
		for(ux=0;ux<ANZMANN;ux++) if((leut[ux].basic.vorhanden==1)&&(leut[ux].laenge==0)) leut[ux].action();
		for(ux=1;ux<ANZHAUS;ux++) if(haus[ux].basic.vorhanden==1)
		{
			if(haus[ux].Stoff[BEEREN]>=20) //Erstmal: Genügend Nahrung da? (10+ Vorrat von 10)
			{
				if(haus[ux].bewohner<=WOHNKAPAZITAET) // Noch Platz im Haus? dann keinen Pionier ausbilden
				haus[ux].Neuer_Leut(2,ux); //nur neuen Bewohner schaffen
				else
				if(haus[ux].Stoff[HOLZ]>=10) haus[ux].Neuer_Leut(1,ux);//Pionier (mit Holz) ausbilden
			}
		};	 
		break;

	case TIMER_ID_OBJECTS:
		welt.calculateXY();
   		welt.Paint_Objects();
		break;
		}
		break;
	case WM_KEYDOWN:
			switch ( wParam )
			{
			
			case VK_DOWN:input.Scroll(DOWN);break;
			case VK_UP:input.Scroll(UP);break;
			case VK_LEFT:input.Scroll(LEFT);break;
			case VK_RIGHT:input.Scroll(RIGHT);break;		
			case VK_SPACE:for(ux=0;ux<ANZHAUS;ux++) {haus[ux].Stoff[BEEREN]+=10;haus[ux].Stoff[HOLZ]+=10;}break; //Cheat!			
			case VK_ESCAPE:
				PostMessage ( hWnd, WM_CLOSE, 0, 0 );
			break;
			}
	break;

	case WM_DESTROY:
		 DXinput.ReleaseObjects(); 
		 screen.ReleaseObjects();
  		 KillTimer(info.hwnd,TIMER_ID_SCHRITT);
  		 KillTimer(info.hwnd,TIMER_ID_OBJECTS);
  		 KillTimer(info.hwnd,TIMER_ID_AREA);
  		 KillTimer(info.hwnd,TIMER_ID_ACTION);
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
	screen.SetGraphicsType(GRAPHICSTYPE_2D);
	screen.InitDirectDraw(800,600,16,FALSE,FALSE);
	graph.Init_Sprites();
    SetTimer(info.hwnd,TIMER_ID_SCHRITT,TIMER_RATE_SCHRITT,NULL); // Timersetzung
    SetTimer(info.hwnd,TIMER_ID_OBJECTS,TIMER_RATE_OBJECTS,NULL); 
    SetTimer(info.hwnd,TIMER_ID_AREA,TIMER_RATE_AREA,NULL); 
    SetTimer(info.hwnd,TIMER_ID_ACTION,TIMER_RATE_ACTION,NULL); 
    welt.Es_werde_Licht();
	graph.Fuelle_Daten();
  	welt.Plaziere_Objekte();
	screen.StartFrameTimer();
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