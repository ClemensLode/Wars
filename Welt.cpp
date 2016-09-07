#include <stdlib.h>
#include <stdio.h>
#include "engine.h"
#include "Welt.h"
#include "path.h"
int feld[4];
unsigned int scrollx,scrolly,feinx,feiny;
long xx,yy,k;

void Welt::Reload_Area(void)
{
	int tx;
	for(tx=0;tx<KARTEMEM;tx++)
	{
		area[tx].ObjektNum=0;
		area[tx].ObjektArt=0;
	}
	for(tx=0;tx<ANZPFLANZ;tx++) if(pflanz[tx].basic.vorhanden==1)
	{
		area[pflanz[tx].basic.ax+tab100[pflanz[tx].basic.ay]].ObjektNum=tx;
		area[pflanz[tx].basic.ax+tab100[pflanz[tx].basic.ay]].ObjektArt=pflanz[tx].Art;
	}
	for(tx=0;tx<ANZHAUS;tx++) if(haus[tx].basic.vorhanden==1)
	{
		area[haus[tx].basic.ax+tab100[haus[tx].basic.ay]].ObjektNum=tx;
		area[haus[tx].basic.ax+tab100[haus[tx].basic.ay]].ObjektArt=HAUS;
	}
};

void Welt::Schaffe_Wasser(void)   // Es werde Wasser!	(Karte[x]=1)
{
	if(karte[0]==0) // Ist dies ein Neustart?
	{				// ja!
		for(xx=0;xx<=KARTEX;xx++) for(yy=0;yy<=KARTEY;yy++)
			karte[xx+tab100[yy]]=rand()%2; // Alles neufüllen (Land/Wasser)
	} else
	{
		for(xx=0;xx<=KARTEX;xx++) for(yy=0;yy<=KARTEY;yy++)
			if((karte[xx+tab100[yy]]>=12)&&(karte[xx+tab100[yy]]<=15)) karte[xx+tab100[yy]]=1; else 
				karte[xx+tab100[yy]]=0; //Nein? Dann Daten (Land/Wasser) aus aktueller Welt holen
	}
};

		


void Welt::Flut_Ebbe(void)  //Erstelle aus Nachbarwasser/landfeldern einen Durchschnitt, sodaß sich Wasser mit Wasser verbindet und Land mit Land
{
	for(xx=2;xx<KARTEX-1;xx++) for(yy=2;yy<KARTEY-1;yy++)
		tkarte[xx+tab100[yy]]=(
		karte[xx+2+tab100[yy+2]]+
		karte[xx+1+tab100[yy+2]]+
		karte[xx+tab100[yy+2]]+
		karte[xx-1+tab100[yy+2]]+
		karte[xx-2+tab100[yy+2]]+
		karte[xx+2+tab100[yy+1]]+
		karte[xx+1+tab100[yy+1]]+
		karte[xx+tab100[yy+1]]+
		karte[xx-1+tab100[yy+1]]+
		karte[xx-2+tab100[yy+1]]+
		karte[xx+2+tab100[yy]]+
		karte[xx+1+tab100[yy]]+
		karte[xx-1+tab100[yy]]+
		karte[xx-2+tab100[yy]]+
		karte[xx+2+tab100[yy-1]]+
		karte[xx+1+tab100[yy-1]]+
		karte[xx+tab100[yy-1]]+
		karte[xx-1+tab100[yy-1]]+
		karte[xx-2+tab100[yy-1]]+
		karte[xx+2+tab100[yy-2]]+
		karte[xx+1+tab100[yy-2]]+
		karte[xx+tab100[yy-2]]+
		karte[xx-1+tab100[yy-2]]+
		karte[xx-2+tab100[yy-2]])/24;
	MoveMemory(karte,tkarte,KARTEMEM);
}


void Welt::Kueste_verkalkulieren(void)
 {
	 for(xx=1;xx<KARTEX;xx++)
		 for(yy=1;yy<KARTEY;yy++)
/*			 if(karte[xx+tab100[yy]]==1)
			 {
				 if(karte[xx-1+tab100[yy]]==1) //oben!
				 {
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+0]=0;
					 else
					 if((karte[xx-1+tab100[yy]]==0)&&(karte[xx-1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+0]=1;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+0]=2;
					 else
					 if((karte[xx-1+tab100[yy]]==0)&&(karte[xx-1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+0]=3;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+0]=4;
					 else
					 if((karte[xx-1+tab100[yy]]==0)&&(karte[xx-1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+0]=5;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+0]=6;
					 else
					 if((karte[xx-1+tab100[yy]]==0)&&(karte[xx-1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+0]=7;
				 }
				 
				 if(karte[xx-1+tab100[yy]]==1) //unten!
				 {
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]>0))
						 wasserk[(xx+tab100[yy])*4+1]=0;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]>0))
						 wasserk[(xx+tab100[yy])*4+1]=1;
					 else
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]>0))
						 wasserk[(xx+tab100[yy])*4+1]=2;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]>0))
						 wasserk[(xx+tab100[yy])*4+1]=3;
					 else
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+1]=4;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+1]=5;
					 else
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+1]=6;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+1]=7;
				 }
				 
				 if(karte[xx-1+tab100[yy]]==1) //links!
				 {
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=0;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=1;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=2;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=3;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=4;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]>0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=5;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=6;
					 else
					 if((karte[xx-1+tab100[yy]]>0)&&(karte[xx-1+tab100[yy+1]]==0)&&(karte[xx+tab100[yy+1]]==0))
						 wasserk[(xx+tab100[yy])*4+2]=7;
				 }
       
				 if(karte[xx-1+tab100[yy]]==1) //rechts!
				 {
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+3]=0;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+3]=1;
					 else
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+3]=2;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]>0))
						 wasserk[(xx+tab100[yy])*4+3]=3;
					 else
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+3]=4;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy-1]]>0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+3]=5;
					 else
					 if((karte[xx+1+tab100[yy]]>0)&&(karte[xx+1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+3]=6;
					 else
					 if((karte[xx+1+tab100[yy]]==0)&&(karte[xx+1+tab100[yy-1]]==0)&&(karte[xx+tab100[yy-1]]==0))
						 wasserk[(xx+tab100[yy])*4+3]=7;
				}
				 tkarte[xx+tab100[yy]]=12;

				} else*/
				tkarte[xx+tab100[yy]]=4+rand()%4;
				MoveMemory(karte,tkarte,KARTEMEM);
 }

 void Welt::Rendern(void)  // Höhen und Geländesprites errechnen
{
	int inhalt;
	for(inhalt=0;inhalt<KARTEMEM;inhalt++) temper[inhalt]=rand()%3;
	inhalt=0;
	for(xx=0;xx<=KARTEX;xx++) for(yy=0;yy<=KARTEY;yy++)
	{
		if(gebirge[xx+tab100[yy]]>0) area[xx+tab100[yy]].Level=2+rand()%3;
		inhalt=karte[xx+tab100[yy]];
/*		if((inhalt>=12)&&(inhalt<=15)) // Wasser? Dann Umgebung absenken
		{
			area[xx-1+tab100[yy]].Level=0;
			area[xx+tab100[yy-1]].Level=0;
			area[xx-1+tab100[yy-1]].Level=0;
			area[xx+tab100[yy]].Level=0;
		}*/
	}
	for(xx=0;xx<=ANZHAUS;xx++)
		if(haus[xx].basic.vorhanden==1)
	{
		area[haus[xx].basic.ax+tab100[haus[xx].basic.ay]].Level=8;
		area[haus[xx].basic.ax+1+tab100[haus[xx].basic.ay]].Level=8;
		area[haus[xx].basic.ax+2+tab100[haus[xx].basic.ay]].Level=8;
		area[haus[xx].basic.ax+tab100[haus[xx].basic.ay+1]].Level=8;
		area[haus[xx].basic.ax+1+tab100[haus[xx].basic.ay+1]].Level=8;
		area[haus[xx].basic.ax+2+tab100[haus[xx].basic.ay+1]].Level=8;
	};

	for(k=0;k<=20;k++) for(xx=2;xx<=KARTEX-2;xx++) for(yy=2;yy<=KARTEY-2;yy++) 
		// Absenken des Geländes. Wenn ein Feld niedriger als das anliegende, das Anliegende
		//senken
	{
		feld[0]=karte[xx+tab100[yy]];
		if((feld[0]>=12)&&(feld[0]<=15)) continue;
		feld[0]=area[xx-1+tab100[yy]].Level;
		feld[1]=area[xx-1+tab100[yy-1]].Level;
		feld[2]=area[xx+tab100[yy]].Level;
		feld[3]=area[xx+tab100[yy-1]].Level;
		if((feld[2]-feld[1])<-2) area[xx-1+tab100[yy-1]].Level=feld[1]-1;
		if((feld[2]-feld[1])>2) area[xx+tab100[yy]].Level=feld[2]-1;
		if((feld[2]-feld[0])<-1) area[xx-1+tab100[yy]].Level=feld[0]-1;
		if((feld[2]-feld[0])>1) area[xx+tab100[yy]].Level=feld[2]-1;
		if((feld[2]-feld[3])<-1) area[xx+tab100[yy-1]].Level=feld[3]-1;
		if((feld[2]-feld[3])>1) area[xx+tab100[yy]].Level=feld[2]-1;
		if((feld[3]-feld[1])<-1) area[xx+tab100[yy-1]].Level=feld[1]-1;
		if((feld[3]-feld[1])>1) area[xx+tab100[yy-1]].Level=feld[3]-1;
		if((feld[3]-feld[0])<-2) area[xx-1+tab100[yy]].Level=feld[0]-1;
		if((feld[3]-feld[0])>2) area[xx+tab100[yy-1]].Level=feld[3]-1;
		if((feld[1]-feld[0])<-1) area[xx-1+tab100[yy]].Level=feld[0]-1;
		if((feld[1]-feld[0])>1) area[xx-1+tab100[yy-1]].Level=feld[1]-1;
	}	
	for(xx=2;xx<KARTEX-2;xx++) for(yy=2;yy<KARTEY-2;yy++)
	// Image auswählen
	{
		feld[0]=area[xx-1+tab100[yy]].Level;
		feld[1]=area[xx+tab100[yy]].Level;
		feld[2]=area[xx+tab100[yy-1]].Level;
		feld[3]=area[xx-1+tab100[yy-1]].Level;
		if((feld[0]==feld[3]+1)&&(feld[1]==feld[2])&&(feld[2]==feld[3])) temper[xx+tab100[yy]]=0; else
		if((feld[3]==feld[0]+1)&&(feld[1]==feld[2])&&(feld[2]==feld[0])) temper[xx+tab100[yy]]=1; else
		if((feld[2]==feld[3]+1)&&(feld[1]==feld[0])&&(feld[3]==feld[1])) temper[xx+tab100[yy]]=2; else
		if((feld[1]==feld[0]+1)&&(feld[3]==feld[2])&&(feld[2]==feld[0])) temper[xx+tab100[yy]]=3; else
		if((feld[0]==feld[1]+1)&&(feld[2]==feld[3]+1)&&(feld[3]==feld[1])) temper[xx+tab100[yy]]=4; else
		if((feld[3]==feld[0]+1)&&(feld[1]==feld[2]+1)&&(feld[2]==feld[0])) temper[xx+tab100[yy]]=5; else
		if((feld[0]==feld[3])&&(feld[1]==feld[2])&&(feld[3]==feld[2]+1)) temper[xx+tab100[yy]]=6; else
		if((feld[3]==feld[0]+1)&&(feld[1]==feld[2])&&(feld[2]==feld[3])) temper[xx+tab100[yy]]=7; else
		if((feld[0]==feld[3]+1)&&(feld[1]==feld[2])&&(feld[2]==feld[0])) temper[xx+tab100[yy]]=8; else
		if((feld[3]==feld[2]+1)&&(feld[1]==feld[0])&&(feld[0]==feld[3])) temper[xx+tab100[yy]]=9; else
		if((feld[0]==feld[1]+1)&&(feld[3]==feld[2])&&(feld[2]==feld[0])) temper[xx+tab100[yy]]=10; else
		if((feld[0]==feld[3])&&(feld[2]==feld[1])&&(feld[2]==feld[0]+1)) temper[xx+tab100[yy]]=11; else
		if((feld[0]==feld[1])&&(feld[3]==feld[2])&&(feld[0]==feld[3]+1)) temper[xx+tab100[yy]]=12; else
		if((feld[0]==feld[1])&&(feld[3]==feld[2])&&(feld[3]==feld[0]+1)) temper[xx+tab100[yy]]=13; else
		if((feld[3]==feld[1])&&(feld[2]==feld[1]+1)&&(feld[3]==feld[0]+1)) temper[xx+tab100[yy]]=14; else
		if((feld[0]==feld[2])&&(feld[3]==feld[2]+1)&&(feld[2]==feld[1]+1)) temper[xx+tab100[yy]]=15; else
		if((feld[0]==feld[3]+1)&&(feld[3]==feld[1])&&(feld[1]==feld[2]+1)) temper[xx+tab100[yy]]=16; else
		if((feld[0]==feld[3]+1)&&(feld[0]==feld[2])&&(feld[1]==feld[2]+1)) temper[xx+tab100[yy]]=17; else
			temper[xx+tab100[yy]]=18;
	}
	for(xx=0;xx<KARTEMEM;xx++) area[xx].Sprite=temper[xx];
}

BOOL Welt::Fail(char *szMsg)
{
	OutputDebugString( szMsg );
	MessageBox(screen.info.hwnd, szMsg, screen.info.AppName, MB_OK);
    DestroyWindow( screen.info.hwnd );
    return FALSE;
}

void Welt::Plaziere_Objekte()
{
	for(xx=0;xx<STARTHAEUSER;xx++)
	haus[xx].basic.setxy((rand()%(KARTEX-10))+5,(rand()%(KARTEY-10))+5);	
	// Haus Koordinaten gesetzt
	for(xx=0;xx<ANZPFLANZ;xx++)
	{
		pflanz[xx].basic.setxy((rand()%(KARTEX-10))+5,(rand()%(KARTEY-10))+5);
		switch(rand()%2)
		{
		case 0:pflanz[xx].Art=BEERENSTRAUCH;pflanz[xx].Stoff[BEEREN]=20;pflanz[xx].Stoff[HOLZ]=0;break;//Beerenstrauch
		case 1:pflanz[xx].Art=BAUM;pflanz[xx].Stoff[HOLZ]=10;pflanz[xx].Stoff[BEEREN]=0;break; //Baum
		}
		pflanz[xx].basic.vorhanden=1;
		pflanz[xx].basic.calculateXY();
		area[pflanz[xx].basic.ax+tab100[pflanz[xx].basic.ay]].ObjektArt=pflanz[xx].Art;
		area[pflanz[xx].basic.ax+tab100[pflanz[xx].basic.ay]].ObjektNum=xx;
	}
	// Pflanzen sprießen aus dem Boden *plopp*
	for(xx=0;xx<STARTHAEUSER;xx++)
	{
		leut[xx].stop();
		leut[xx].basic.setxy(haus[xx].basic.ax+1,haus[xx].basic.ay);
		leut[xx].basic.calculateXY();
		leut[xx].home=xx;
		leut[xx].Stoff[BEEREN]=0;
		leut[xx].Stoff[HOLZ]=0;
		leut[xx].basic.vorhanden=1;
		leut[xx].alter=10;
		haus[xx].basic.vorhanden=1;
 		haus[xx].Stoff[BEEREN]=0;
		haus[xx].Stoff[HOLZ]=100;
		haus[xx].basic.calculateXY();
		area[haus[xx].basic.ax+tab100[haus[xx].basic.ay]].ObjektArt=HAUS;
		area[haus[xx].basic.ax+tab100[haus[xx].basic.ay]].ObjektNum=xx;
		leut[xx].hunger=0;
	}
	//Leute zufällig plaziert, Früchte verteilt
};

void Welt::Berechne_tab100() // Tab100 mit jeweils den Vielfachen von KARTEX füllen
{
	for(xx=0;xx<=KARTEY;xx++) tab100[xx]=xx*KARTEX; 
}

void Welt::calculateXY(void)
{
	int tadder;
	for(xx=0;xx<KARTEX;xx++) for(yy=0;yy<KARTEY;yy++)
	{
	tadder=area[xx+tab100[yy]].Level;
	if(tadder>area[xx-1+tab100[yy]].Level) tadder=area[xx-1+tab100[yy]].Level;
	if(tadder>area[xx+tab100[yy-1]].Level) tadder=area[xx+tab100[yy-1]].Level;
	if(tadder>area[xx-1+tab100[yy-1]].Level) tadder=area[xx-1+tab100[yy-1]].Level;
   	area[xx+tab100[yy]].absx=(((xx+input.scrollx)<<5)+(input.feinx<<2))-(((yy+input.scrolly)<<5)+(input.feiny<<2));
	area[xx+tab100[yy]].absy=(((xx+input.scrollx)<<4)+(input.feinx<<1))+(((yy+input.scrolly)<<4)+(input.feiny<<1))-(tadder<<3);
	}
	for(xx=0;xx<ANZHAUS;xx++) if(haus[xx].basic.vorhanden==1) haus[xx].basic.calculateXY();
	for(xx=0;xx<ANZMANN;xx++) if(leut[xx].basic.vorhanden==1) leut[xx].basic.calculateXY();
	for(xx=0;xx<ANZPFLANZ;xx++) if(pflanz[xx].basic.vorhanden==1) pflanz[xx].basic.calculateXY();
};

void Welt::Es_werde_Licht(void)	  // Erstellung der kompletten Welt
{
  
  Berechne_tab100();
  Schaffe_Wasser();			// Land teilen in Wasser und Land
  for(k=0;k<2;k++) Flut_Ebbe(); // 2x das Land fluten oder das Wasser verebben (kommt auf Variable "see" drauf an)
  Kueste_verkalkulieren();	// Küstenverlauf berechnen (für Sprites)
//  ZeroMemory(gebirge,KARTEMEM); // Reset des Arrays der Gebirgesprites
//  ZeroMemory(temper,KARTEMEM);
  for(xx=0;xx<KARTEMEM;xx++) area[xx].Sprite=0;
  for(xx=0;xx<KARTEX;xx++) 
	  for(yy=0;yy<KARTEY;yy++) 
		  if((rand()%10==0)&&(karte[xx+tab100[yy]]<12)) temper[xx+tab100[yy]]=10;
		  // Zufällige Gebirgslandschaft errechnen

  for(k=0;k<=2;k++) //Hoehenausgleich um Hoehenspruenge zu vermeiden
  {
	  for(xx=2;xx<=KARTEX-2;xx++) for(yy=2;yy<=KARTEY-2;yy++) if(karte[xx+tab100[yy]]<12)
		  gebirge[xx+tab100[yy]]=(//Mittelwert bilden ...Gebirge dient als temporärer Speicher
		  temper[xx+2+tab100[yy+2]]+
		  temper[xx+1+tab100[yy+2]]+
		  temper[xx+tab100[yy+2]]+
		  temper[xx-1+tab100[yy+2]]+
		  temper[xx-2+tab100[yy+2]]+
		  temper[xx+2+tab100[yy+1]]+
		  temper[xx+1+tab100[yy+1]]+
		  temper[xx+tab100[yy+1]]+
		  temper[xx-1+tab100[yy+1]]+
		  temper[xx-2+tab100[yy+1]]+
		  temper[xx+2+tab100[yy]]+
		  temper[xx+1+tab100[yy]]+
		  temper[xx-1+tab100[yy]]+
		  temper[xx-2+tab100[yy]]+
		  temper[xx+2+tab100[yy-1]]+
		  temper[xx+1+tab100[yy-1]]+
		  temper[xx+tab100[yy-1]]+
		  temper[xx-1+tab100[yy-1]]+
		  temper[xx-2+tab100[yy-1]]+
		  temper[xx+2+tab100[yy-2]]+
		  temper[xx+1+tab100[yy-2]]+
		  temper[xx+tab100[yy-2]]+
		  temper[xx-1+tab100[yy-2]]+
		  temper[xx-2+tab100[yy-2]])/24;
		  else gebirge[xx+tab100[yy]]=0;
		  MoveMemory(temper,gebirge,KARTEMEM); // Und übertragen. 
}
  
  for(xx=1;xx<=KARTEX-1;xx++) for(yy=1;yy<=KARTEY-1;yy++) //Gebirge errechnen
	  if(temper[xx+tab100[yy]]>0) // Über Meeresspiegel?
	  {
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=1;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=2;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=3;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=4;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=5;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=6;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=7;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=8;
		  else
		  if((temper[xx-1+tab100[yy]]>0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=9;
		  else
		  if((temper[xx-1+tab100[yy]]>0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=10;
		  else
		  if((temper[xx-1+tab100[yy]]>0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=11;
		  else
		  if((temper[xx-1+tab100[yy]]>0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]==0))
			  gebirge[xx+tab100[yy]]=12;
		  else
		  if((temper[xx-1+tab100[yy]]>0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=13;
		  else
		  if((temper[xx-1+tab100[yy]]>0)&&(temper[xx+1+tab100[yy]]==0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=14;
		  else
		  if((temper[xx-1+tab100[yy]]==0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]==0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=15;
		  else
		  if((temper[xx-1+tab100[yy]]>0)&&(temper[xx+1+tab100[yy]]>0)&&(temper[xx+tab100[yy-1]]>0)&&(temper[xx+tab100[yy+1]]>0))
			  gebirge[xx+tab100[yy]]=16;
	  } // Gebirgssprites jetzt in "gebirge" eingetragen
	  Plaziere_Objekte(); // Diverse Startwerte für Figuren
	  Rendern(); // Aus Höhenangaben Geländesprites errechnen
	  calculateXY();//Absolute Koordinaten errechnen
} // Welt startbereit. Sie können eintreten
