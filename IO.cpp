// IO.cpp
#include "IO.h"
#include "Welt.h"
#include "graph.h"
#include "path.h"

Graph graph;
extern Pathfinding leut[ANZMANN];
extern haeuser_class haus[ANZHAUS];
extern pflanzen_class pflanz[ANZPFLANZ];
extern unsigned int scrollx,scrolly,feinx,feiny;
extern long xx,yy,k;

void Input::Scroll(char direction)
{
	switch(direction)
	{
		case UP:if(sy<0) sy=0;else sy=32;
				if(sx<0) sx=0;else sx=32;break;
		case DOWN:if(sy>0) sy=0;else sy=-32;
				  if(sx>0) sx=0;else sx=-32;break;		
		case LEFT:if(sy>0) sy=0;else sy=-32;
				  if(sx<0) sx=0;else sx=32;break;
		case RIGHT:if(sy<0) sy=0;else sy=32;
				   if(sx>0) sx=0;else sx=-32;break;
	}
};

void Input::Scroll_mouse()
{
	if(((xPos>=graph.randl+32)&&(xPos<=graph.randr-32)&&(yPos>=graph.rando+32)&&(yPos<=graph.randu-32))||((startsx!=0)||(startsy!=0))||(Rahmen==1))

		{
			if(sx>0) sx-=4; else if(sx<0) sx+=4;
			if(sy>0) sy-=4; else if(sy<0) sy+=4;
		} else
		{
			if(xPos<=graph.randl+32) Scroll(LEFT);
			else if(xPos>=graph.randr-32) Scroll(RIGHT);
			if(yPos<=graph.rando+32) Scroll(UP);
			else if(yPos>=graph.randu-32) Scroll(DOWN);
		}
		akfeinx+=(sx/8);akfeiny+=(sy/8);
		if(akfeinx<0) {akscrollx--;akfeinx=akfeinx+8;}
		if(akfeinx>8) {akscrollx++;akfeinx=akfeinx-8;}
		if(akfeiny<0) {akscrolly--;akfeiny=akfeiny+8;}
		if(akfeiny>8) {akscrolly++;akfeiny=akfeiny-8;}
};

void Input::Calculate_KPos(void)
{
int tex,tey,fx,fy;
	tex=xPos%64;tey=yPos%32;tex/=2;
	fx=0;fy=0;
	if((tey<16)&&(tex<16)) //links oben
	{
		if(tex+tey<16) fx=-1;
	} else
	if((tey>16)&&(tex<16)) //links unten
	{
		tey-=16;
		tey=16-tey;
		if(tex+tey<16) fy=1;
	} else
	if((tey>16)&&(tex>16)) //rechts unten
	{
		tex-=16;
		tey-=16;
		if(tex+tey>=16) fx=1;		
	} else
	if((tey<16)&&(tex>16)) //Rechts oben
	{
		tex-=16;
		tey=16-tey;
		if(tex+tey>=16) fy-=1;
	};
	KxPos=fx+xPos/64+yPos/32-scrollx;
	KyPos=fy-xPos/64+yPos/32-scrolly;
};

void Input::Move(unsigned int lParam)
{
	xPos=LOWORD(lParam);
	yPos=HIWORD(lParam);  
	if((startsx==0)&&(startsy==0))
	{
		if(xPos>graph.randr) xPos=graph.randr;
		else if(xPos<graph.randl) xPos=graph.randl;
		if(yPos<graph.rando) yPos=graph.rando;
		else if(yPos>graph.randu) yPos=graph.randu;
	}
	else
	{
		akfeinx=(-(xPos-startsx)/2-(yPos-startsy));
		akfeiny=((xPos-startsx)/2-(yPos-startsy));
		akscrollx=akfeinx/8+startscx;akfeinx=(akfeinx+startfx)%8;kjfgjz
		akscrolly=akfeiny/8+startscy;akfeiny=(akfeiny+startfy)%8;
	}
	Calculate_KPos();
};


void Input::Update_scroll()
{
		scrollx=akscrollx;
		scrolly=akscrolly;
		feinx=akfeinx;
		feiny=akfeiny;
};


void Input::LDown()
{
	if(Rahmen==0)
	{
		RStartX=xPos;
		RStartY=yPos;
		Rahmen=1;	
	}
	InAction=1;	
};
void Input::LUp()
{
	int tx,ty;
	Rahmen=0;
	for(xx=0;xx<ANZMANN;xx++) leut[xx].activ=0;
	tx=xPos;ty=yPos;
	if(xPos<RStartX)
	{
		tx=RStartX;RStartX=xPos;
	};
	if(yPos<RStartY)
	{
		ty=RStartY;RStartY=yPos;
	};
	if((tx!=RStartX)&&(ty!=RStartY))
	{
		for(xx=0;xx<ANZMANN;xx++) 
			if(leut[xx].basic.vorhanden==1)
			if((leut[xx].basic.absx+8>=RStartX)&&(leut[xx].basic.absx+8<=xPos)&&(leut[xx].basic.absy+14>=RStartY)&&(leut[xx].basic.absy-14<=yPos))
			leut[xx].activ=1;
	};
	InAction=0;	
};

void Input::MUp()
{
	char charbuf[20];
	for(xx=0;xx<ANZMANN;xx++) 
	if(leut[xx].activ==1)
	{
			screen.SetColor(210,210,255);
			switch(rand()%5)
			{
				case 0:sprintf(charbuf,"Schon dabei!");break;
				case 1:sprintf(charbuf,"Mmmh");break;
				case 2:sprintf(charbuf,"Okay!		  ");break;
				case 3:sprintf(charbuf,"Bin unterwegs!");break;
				case 4:sprintf(charbuf,"Na guut		  ");break;
			}
			screen.WriteS(screen.BackBuffer,30,500,charbuf,false);
			leut[xx].gotoxy(KxPos,KyPos);
	}
	InAction=0;	
};

void Input::RDown()
{
		startsx=xPos;startsy=yPos;
		startscx=akscrollx;startscy=akscrolly;
		startfx=akfeinx;startfy=akfeiny;
		InAction=1;
};
void Input::RUp()
{
	startsx=0;startsy=0;InAction=0;
};
