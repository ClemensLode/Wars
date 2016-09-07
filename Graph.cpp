//Graph.cpp
#include "graph.h"
#include "engine.h"
#include "Welt.h"
#include "IO.h"
#include "path.h"
const ADDX=300;
const ADDY=100;
//extern Input input;
Engine_Graphics screen;
Pathfinding leut[ANZMANN];
haeuser_class haus[ANZHAUS];
pflanzen_class pflanz[ANZPFLANZ];
IDirectDrawSurface *spr;
unsigned int number;
extern unsigned int scrollx,scrolly,feinx,feiny;
extern long xx,yy,k;

void Welt::Minimap()
{
	for(xx=0;xx<=KARTEX;xx++) for(yy=0;yy<=KARTEY;yy++) 
	{
		if((area[xx+tab100[yy]].ObjektArt>0)&&(area[xx+tab100[yy]].ObjektArt!=HAUS))
		{
		 if((xx==input.KxPos)&&(yy==input.KyPos)) screen.SetColor(255,255,255);else
		 screen.SetColor(50,area[xx+tab100[yy]].ObjektArt*50+100,50);
		 for(k=0;k<ANZMANN;k++) if((leut[k].basic.vorhanden==1)&&(leut[k].basic.ax==xx)&&(leut[k].basic.ay==yy))
			 screen.SetColor(50,50,255);
		 screen.PutPixel(screen.BackBuffer,xx-yy+ADDX,((xx+yy)>>1)+ADDY);
		}
		else
		{
		 screen.SetColor(0,0,0);
		 screen.PutPixel(screen.BackBuffer,xx-yy+ADDX,((xx+yy)>>1)+ADDY);
		};
	}
};
		
void Welt::Paint_Objects(void)
{
//	char charbuf[20];
	int inhalt;
	screen.BufferClear(screen.BackBuffer,0,0,0);
	for(yy=3;yy<=KARTEY-3;yy++) for(xx=3;xx<=KARTEX-3;xx++) 
	//if(((xx!=input.KxPos)||(yy!=input.KyPos))&&(welt.area[xx+tab100[yy]].Besetzt==0))
	{
		inhalt=area[xx+tab100[yy]].Sprite;
		if(inhalt==15) graph.PutGelaende(area[xx+tab100[yy]].absx,area[xx+tab100[yy]].absy-8,inhalt); else graph.PutGelaende(area[xx+tab100[yy]].absx,area[xx+tab100[yy]].absy,inhalt);
	}
	for(xx=0;xx<ANZMANN;xx++) 
	if(leut[xx].basic.vorhanden==1)
	{
		leut[xx].basic.calculateXY();
		if(leut[xx].activ==1) graph.PutDrac(leut[xx].basic.absx+24,leut[xx].basic.absy+16,102);
		if(leut[xx].Stoff[BEEREN]>0) graph.PutDrac(leut[xx].basic.absx+28,leut[xx].basic.absy-5,101);
		if(leut[xx].Stoff[HOLZ]>0) graph.PutDrac(leut[xx].basic.absx+28,leut[xx].basic.absy-5,106);
		yy=leut[xx].phase+leut[xx].richtung*8+19;
		graph.PutDrac(leut[xx].basic.absx+24,leut[xx].basic.absy-5,yy);
		screen.SetColor(255,255,255);
		for(yy=0;yy<=(leut[xx].hunger/20);yy++) 
		{
		  screen.PutPixel(screen.BackBuffer,leut[xx].basic.absx+40,leut[xx].basic.absy-yy);
		  screen.PutPixel(screen.BackBuffer,leut[xx].basic.absx+41,leut[xx].basic.absy-yy);
		}	  
		screen.SetColor(0,0,0);
		for(yy=0;yy<=(leut[xx].alter/20);yy++) 
		{
		  screen.PutPixel(screen.BackBuffer,leut[xx].basic.absx+38,leut[xx].basic.absy-yy);
		  screen.PutPixel(screen.BackBuffer,leut[xx].basic.absx+39,leut[xx].basic.absy-yy);
		}	  
	}

	for(xx=0;xx<=ANZHAUS;xx++) if(haus[xx].basic.vorhanden==1)
	{
		if(haus[xx].Stoff[BEEREN]>0) for(yy=0;yy<haus[xx].Stoff[BEEREN];yy++) graph.PutDrac(haus[xx].basic.absx+4+yy*2,haus[xx].basic.absy,101);
		if(haus[xx].Stoff[HOLZ]>0) for(yy=0;yy<haus[xx].Stoff[HOLZ];yy++) graph.PutDrac(haus[xx].basic.absx+4+yy*2,haus[xx].basic.absy+5,106);
		graph.PutDrac(haus[xx].basic.absx+16,haus[xx].basic.absy+16,103);
	}

	for(xx=0;xx<=ANZPFLANZ;xx++) if(pflanz[xx].basic.vorhanden==1)
	{
		switch(pflanz[xx].Art)
		{
			case BEERENSTRAUCH:graph.PutDrac(pflanz[xx].basic.absx+21,pflanz[xx].basic.absy+6,100);break;
			case BAUM:if(pflanz[xx].Stoff[HOLZ]<10) graph.PutDrac(pflanz[xx].basic.absx+21,pflanz[xx].basic.absy+6,105); 
				else graph.PutDrac(pflanz[xx].basic.absx+21,pflanz[xx].basic.absy+6,104);break;
		}
		//if(pflanz[xx].Stoff[BEEREN]>0) for(yy=0;yy<pflanz[xx].Stoff[BEEREN]/2;yy++) graph.PutDrac(pflanz[xx].basic.absx+4+yy*2,pflanz[xx].basic.absy,101);
		//if(pflanz[xx].Stoff[HOLZ]>0) for(yy=0;yy<pflanz[xx].Stoff[HOLZ]/2;yy++) graph.PutDrac(pflanz[xx].basic.absx+4+yy*2,pflanz[xx].basic.absy+5,106);
	}
  	if(input.Rahmen==1)
	{
		screen.SetColor(50,200,50);
		screen.DrawRect(screen.BackBuffer,input.xPos,input.yPos,input.RStartX,input.RStartY,false);
	}
//	welt.Minimap();
//	graph.rahmen.DrawSprite(graph.Rahmen,0,0);
	screen.SetColor(255,255,255);
	screen.UpdateFrames();
	screen.ShowFrames(screen.BackBuffer,100,100);
	screen.Flip();
};

void Graph::Set_Data(unsigned int x1,unsigned int y1,unsigned int width,unsigned int height)
{
	Daten[number].X1=x1;
	Daten[number].Y1=y1;
	Daten[number].X2=x1+width;
	Daten[number].Y2=y1+height;
	number++;
};

void Graph::Fuelle_Daten(void)
{
// Gelaendeerhebungen
	for(xx=0;xx<=3;xx++) for(yy=0;yy<=3;yy++)
			Set_Data(xx*64+xx+1,yy*48+yy+1,64,48);
	
	for(yy=0;yy<=2;yy++) 
		Set_Data(4*64+5,yy*48+yy+1,64,48);
// Leute

	for(yy=0;yy<=4;yy++) for(xx=0;xx<=7;xx++)
		Set_Data(xx*16,yy*27,16,27);
	for(yy=0;yy<=2;yy++) for(xx=0;xx<=7;xx++) 
		Set_Data(xx*16+127,yy*27,16,27);
	number=100;
	Set_Data(0,187,20,20);//KirschenStrauch 100
	Set_Data(0,249,20,20);//Kirschen		101
	Set_Data(0,140,16,10);//Auswahlfeld		102
	Set_Data(0,214,68,32);//Haus			103
	Set_Data(0,269,19,28);//ganzer Baum		104
	Set_Data(0,297,40,28);//Baumstumpf		105
	Set_Data(0,341,15,17);//Baumstamm		106
	// Kueste	
/*	for(xx=0;xx<=8;xx++)
		if((xx%2)==0) for(yy=0;yy<=2;yy++)
				Set_Data(20+(xx/2)*4+3,xx*64+1+xx,yy*48+yy+1,32,16);
		else Set_Data(20+(xx/2)*4,xx*64+1+xx,35,32,16);
	
	for(xx=0;xx<=6;xx++)
		if((xx%2)==1) for(yy=0;yy<=2;yy++)
				Set_Data(29+(xx/2)*4+3,xx*64+1+xx,52,32,16);
		else Set_Data(29+(xx/2)*4,xx*64+1+xx,86,32,16);*/
};

void Graph::Init_Sprites()
{
	graph.randl=50;
	graph.randr=749;
	graph.randu=549;
	graph.rando=50;
// Rahmen
/*	rahmen.En_Graph=screen;
	rahmen.szImage = "rahmen.bmp";
	rahmen.Quelle  = spr;
	rahmen.Ziel    = screen.BackBuffer;
    rahmen.SetColorKey(0,0,0);
	rahmen.CreateSprite(800,600);
//Rahmen setzen. Braucht man ja nur an einer Stelle
	SetRect(&Rahmen,0,0,799,599);				   */
// Gelaende
	gelaende.En_Graph=screen;
	gelaende.szImage = "3d.bmp";
	gelaende.Quelle  = spr;
	gelaende.Ziel    = screen.BackBuffer;
    gelaende.SetColorKey(0,0,0);
	gelaende.CreateSprite(640,480,true);
//	Leute
	leute.En_Graph=screen;
	leute.szImage = "drac.bmp";
	leute.Quelle  = spr;
	leute.Ziel    = screen.BackBuffer;
	leute.SetColorKey(0,0,0);
	leute.CreateSprite(640,480,true);
};

void Graph::PutGelaende(int X,int Y,int texture)
{
	if((X>=randl)&&(X<randr-64)&&(Y>=rando)&&(Y<randu-32))
		{
			SetRect(&Gelaende,Daten[texture].X1,Daten[texture].Y1,Daten[texture].X2,Daten[texture].Y2);
			gelaende.DrawSprite(Gelaende,X,Y);
		}
	else if((X>randl-64)&&(X<=randr)&&(Y>rando-32)&&(Y<=randu))
		{
		signed int tX1=0,tX2=0,tY1=0,tY2=0;
			if(X>=randr-64) tX2=X-(randr-64);
			if(Y>=randu-32) tY2=Y-(randu-32);
			if(X<randl) {tX1=X-randl;X=randl;}
			if(Y<rando) {tY1=Y-rando;Y=rando;}
			SetRect(&Gelaende,Daten[texture].X1-tX1,Daten[texture].Y1-tY1,Daten[texture].X2-tX2,Daten[texture].Y2-tY2);
			gelaende.DrawSprite(Gelaende,X,Y);
		} 
};

void Graph::PutDrac(int X,int Y,int texture)
{
	if((X>=randl)&&(X<randr-Daten[texture].X2+Daten[texture].X1)&&(Y>=rando)&&(Y<randu-Daten[texture].Y2+Daten[texture].Y1))
		{
			SetRect(&Leute,Daten[texture].X1,Daten[texture].Y1,Daten[texture].X2,Daten[texture].Y2);
			leute.DrawSprite(Leute,X,Y);
		}
};
