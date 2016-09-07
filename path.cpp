#include "Welt.h"					   
#include "path.h"					   
#include "stdlib.h"
#include "stdio.h"
unsigned int tab100[KARTEY];	
extern unsigned int scrollx,scrolly,feinx,feiny;
extern long xx,yy,k;

void pflanzen_class::check()
{
	if(Stoff[BEEREN]==0) basic.vorhanden=0;
};

/*void haeuser_class::Neuer_Leut(int wo)
{
	int tx;
	for(tx=0;tx<ANZMANN;tx++) if(leut[tx].basic.vorhanden==0)
	{
		leut[tx].stop();
		leut[tx].basic.vorhanden=1;
		leut[tx].home=wo;
		leut[tx].Stoff[BEEREN]=0;
		leut[tx].basic.setxy(basic.ax+1,basic.ay);
		leut[tx].Find(BEEREN);
		tx=ANZMANN;
	}
};*/
void basics::setxy(int setx, int sety)
{
		ax=setx;
		ay=sety;
};

void basics::calculateXY()
{
	int tadder;
		tadder=welt.area[ax+tab100[ay]].Level;
		if(tadder>welt.area[ax-1+tab100[ay]].Level) tadder=welt.area[ax-1+tab100[ay]].Level;
		if(tadder>welt.area[ax+tab100[ay-1]].Level) tadder=welt.area[ax+tab100[ay-1]].Level;
		if(tadder>welt.area[ax-1+tab100[ay-1]].Level) tadder=welt.area[ax-1+tab100[ay-1]].Level;
		absx=(((ax+input.scrollx)<<5)+(input.feinx<<2)+px*2)-(((ay+input.scrolly)<<5)+py*2+(input.feiny<<2));
		absy=(((ax+input.scrollx)<<4)+(input.feinx<<1)+px)+(((ay+input.scrolly)<<4)+py+(input.feiny<<1))-(tadder<<3);
}
/*int Pathfinding::search_goal(int goal);
/*
		1:Nahrung
		2:...

{*/

void Pathfinding::besetzen(int wer)
{
		welt.area[basic.ax+tab100[basic.ay]].Besetzt=wer;
		if(wait==0)
		{
			if((welt.area[basic.ax+wegx[wegp]+tab100[basic.ay+wegy[wegp]]].Besetzt!=wer)&&(welt.area[basic.ax+wegx[wegp]+tab100[basic.ay+wegy[wegp]]].Besetzt>0))
			wait++;
			else
			 welt.area[basic.ax+wegx[wegp]+tab100[basic.ay+wegy[wegp]]].Besetzt=wer;
		}
};

/*void Besetzen()
{
	for(xx=0;xx<ANZHAUS;xx++)
		if((haus[xx].basic.ax>0)&&(haus[xx].basic.ay>0))
			besetzt[haus[xx].basic.ax+tab100[haus[xx].basic.ay]]=1;
} */





int Pathfinding::suche()
{
		signed char * kartex;
		signed char * kartey;
		unsigned char * items;
		//vom Start her:
		// 0: frei, 1: besetzt (z.B. Haeuser), 2:nächste Runde aktiv,
		// 3: aktiv 4:schon geprüft 5 Ziel
		//	6: Diagonale Warteschleife
		int x,y,j,ziel;
		unsigned int lx;
		signed char mx,my;
		int kk=0;

		if((kartex = (signed char *) malloc(KARTEMEM))==NULL) exit(1);
		if((kartey = (signed char *) malloc(KARTEMEM))==NULL) exit(1);
		if((items = (unsigned char *) malloc(KARTEMEM))==NULL) exit(1);

		for(lx=0;lx<KARTEMEM;lx++){items[lx]=0;kartex[lx]=0;kartey[lx]=0;}
		//for(x=0;x<ANZDORF;x++) items[haus[x].basic.ax+tab100[haus[x].basic.ay]]=1;
		items[basic.ax+tab100[basic.ay]]=255;
		items[cx+tab100[cy]]=253;
		x=basic.ax;
		y=basic.ay;
		for(j=0;kk==0;j++) //Direkter Weg vorhanden?					    
		{
		  mx=0;my=0;
		  if(x>cx) mx=-1;
		  else if(x<cx) mx=1;
		  if(y>cy) my=-1;
		  else if(y<cy) my=1;
		  if(j>KARTEX) kk=1;
		  if(welt.area[x+mx+tab100[y+my]].Besetzt==1) //besetzt
			{
			  kk=1;
			  if((abs(mx)==1)&&(abs(my)==1))
			  {
				if(welt.area[x+tab100[y+my]].Besetzt==0) mx=0;
				else if(welt.area[x+mx+tab100[y]].Besetzt==0) my=0;

			  }
			 else if(abs(mx)==1)
			  {
				if(welt.area[x+mx+tab100[y+1]].Besetzt==0) my=1;
				else if(welt.area[x+mx+tab100[y-1]].Besetzt==0) my=-1;
			  }
			 else if(abs(my)==1)
			  {
				if(welt.area[x+1+tab100[y+my]].Besetzt==0) mx=1;
				else if(welt.area[x-1+tab100[y+my]].Besetzt==0) mx=-1;
			  };
			 }
		  if(welt.area[x+mx+tab100[y+my]].Besetzt==1) //immer noch besetzt? Dann andere Suchmaschine...
			  kk=1;
		  x+=mx;
		  y+=my;
		  wegx[j]=mx;
		  wegy[j]=my;
		  if((x==cx)&&(y==cy))
			{
			laenge=j;
			return 0;
			}
		 }


		kk=0;		

		for(j=0;kk==0;j++)  //X Felder Reichweite
		{
		  for(lx=0;lx<KARTEMEM;lx++) if(items[lx]==254) items[lx]=255;
		   // Inaktive in Aktive umgewandelt 
 
		  // Optimierung, Ueberprueft wird maximale Reichweite
		  for(x=basic.ax-j;x<basic.ax+j;x++)
		  for(y=basic.ay-j;y<basic.ay+j;y++)
			 {
				 if(y>=KARTEY-1) break;if(y<=1) y=1;
				 if(x>=KARTEX-1) break;if(x<=1) x=1;

				 if(items[x+tab100[y]]==255) //Aktives Feld?
				 {
					for(mx=-1;mx<=1;mx++)
					 for(my=-1;my<=1;my++)
					  {
						ziel=mx+x+tab100[my+y];
						switch(items[ziel])
						{
						 case 0: //leer
							 if(welt.area[ziel].Besetzt==0)
						{
//						  if(abs(mx)+abs(my)==2) items[ziel]=6;else
						  items[ziel]=254;
						  kartex[ziel]=mx;kartey[ziel]=my;
						} else
						 {
							items[ziel]=250; // Besetzt
							kartex[ziel]=0;kartey[ziel]=0;
						}  

						 break;
						 case 253: //Ziel!
						 {
						  laenge=j;
						  kartex[ziel]=mx;kartey[ziel]=my;
						  kk=1;
						  break;
						 } //Zielweg gefunden, Schleife beenden
//						 case 6:{ j--;				 // Schräglaufen halb so schnell
//						  items[ziel]=2;
//						  }
						}
					  }
					 items[x+tab100[y]]=250; // Feld fertig überprüft.
					}
				  }
				 if(j>=REICHWEITE) kk=1;
				 }
				if(laenge==0)
				{
				 free(kartex);
				 free(kartey);
				 free(items);
				 return 1; //Leider kein Weg gefunden
				}

				laenge--;
				x=cx; //Jetzt Weg vom Ziel zurückverfolgen
				y=cy;
				for(j=laenge;j>0;j--)
				{
				  wegx[j]=kartex[x+tab100[y]];
				  wegy[j]=kartey[x+tab100[y]];
				  x=x-wegx[j];
				  y=y-wegy[j];
				 } //"weg" jetzt mit dem Weg gefüllt
			 wegx[0]=kartex[x+tab100[y]];
			 wegy[0]=kartey[x+tab100[y]];
			 free(kartex);
			 free(kartey);
			 free(items);
			 return 0;
		  }



void Pathfinding::stop(void)
{
		int xxx;
		basic.px=0;basic.py=0;
		gx=0;gy=0;
		for(xxx=0;xxx<REICHWEITE;xxx++) wegx[xxx]=0;
		for(xxx=0;xxx<REICHWEITE;xxx++) wegy[xxx]=0;
		laenge=0;
		wegp=0;
		phase=0;
		richtung=0;
};

void Pathfinding::gotoxy(int gox, int goy)
{
	cx=gox;
	cy=goy;
	if((basic.px!=0)||(basic.py!=0)) newgo=1;
		else
		{
			stop();
			suche();
			basic.px=wegx[0];
			basic.py=wegy[0];
			wegp=0;
			gx=basic.px;
			gy=basic.py;
			richtung=kompass();
		}
};

unsigned char Pathfinding::kompass()
{
	switch(gx)
	{
	case -1:switch(gy)
			{
				case -1:return 4;break;
				case 0:return 7;break;
				case 1:return 6;break;
			};break;
	case 0:switch(gy)
		   {
				case -1:return 3;break;
				case 1:return 5;break;
		   };break;
	case 1:switch(gy)
		   {
				case -1:return 2;break;
				case 0:return 1;break;
				case 1:return 0;break;
		   };break;
	}
return 7;
}
	
void Pathfinding::feld(int wer)
{
	basic.ax+=gx;
	basic.ay+=gy;
	if(newgo==1)
	{
		stop();
		suche();
		basic.px=wegx[0];
		basic.py=wegy[0];
		wegp=0;
		gx=basic.px;
		gy=basic.py;
		richtung=kompass();
		newgo=0;
	}
	else 
	{
		basic.px=wegx[wegp+1];
		basic.py=wegy[wegp+1];
		wegp++;
		gx=wegx[wegp];
		gy=wegy[wegp];
		richtung=kompass();
		//if((welt.Besetzt[basic.ax+gx+tab100[basic.ay+gy]]!=wer)&&(welt.Besetzt[basic.ax+gx+tab100[basic.ay+gy]]>0)) wait=64;
		if(wegp>laenge) stop();
	}
};


void Pathfinding::action()
{
int ty;
	switch(welt.area[basic.ax+tab100[basic.ay]].ObjektArt)
		{
			case BAUM:Stoff[HOLZ]++;
				pflanz[welt.area[basic.ax+tab100[basic.ay]].ObjektNum].Stoff[HOLZ]--;
				gotoxy(haus[home].basic.ax,haus[home].basic.ay);break;
			case BEERENSTRAUCH:Stoff[BEEREN]++;gotoxy(haus[home].basic.ax,haus[home].basic.ay);break;
 			case HAUS:for(ty=0;ty<3;ty++)
					   if(Stoff[ty]>0)
					   {haus[home].Stoff[ty]+=Stoff[ty];Stoff[ty]=0;if(haus[home].Stoff[ty]<20) Find(ty);};break;
		}
};

void Pathfinding::Next_action()
{
int ty,min,best;
	min=10;
	best=255;
	for(ty=0;ty<2;ty++)
		if(haus[home].Stoff[ty]<min) {min=haus[home].Stoff[ty];best=ty;}
	if(best==255) wait=64; else Find(best);
};


/*	switch(welt.objekt[basic.ax+tab100[basic.ay]])
		{
			case 15:Stoff[HOLZ]++;gotoxy(haus[home].basic.ax,haus[home].basic.ay);break;
			case 5:Stoff[BEEREN]++;gotoxy(haus[home].basic.ax,haus[home].basic.ay);break;
 			case 2:for(ty=0;ty<2;ty++)
					   if(Stoff[ty]>0)
					   {haus[home].Stoff[ty]+=Stoff[ty];Stoff[ty]=0;};break;
		}
};*/

int Pathfinding::Find(int was)
{
		int items[KARTEMEM];
		//vom Start her:
		// 0: frei, 1: besetzt (z.B. Haeuser), 2:nächste Runde aktiv,
		// 3: aktiv 4:schon geprüft 5 Ziel
		//	6: Diagonale Warteschleife
		int j,ziel,x,y,lx,zielx,ziely;
		signed char mx,my;
		int kk=0;
		zielx=0;ziely=0;
		//if((items = (int *) malloc(KARTEMEM))==NULL) exit(1);
		//for(x=0;x<ANZDORF;x++) items[haus[x].basic.ax+tab100[haus[x].basic.ay]]=1;
		for(x=0;x<KARTEMEM;x++) items[x]=welt.area[x].ObjektArt;
		items[basic.ax+tab100[basic.ay]]=255;
		x=basic.ax;
		y=basic.ay;
		kk=0;		
		for(j=0;kk==0;j++)  //X Felder Reichweite
		{
		  for(lx=0;lx<KARTEMEM;lx++) if(items[lx]==254) items[lx]=255;
		   // Inaktive in Aktive umgewandelt 
 
		  // Optimierung, Ueberprueft wird maximale Reichweite
		  for(x=basic.ax-j;x<basic.ax+j;x++)
		  for(y=basic.ay-j;y<basic.ay+j;y++)
			 {
				 if(y>=KARTEY-1) break;if(y<=1) y=1;
				 if(x>=KARTEX-1) break;if(x<=1) x=1;

				 if(items[x+tab100[y]]==255) //Aktives Feld?
				 {
					for(mx=-1;mx<=1;mx++)
					 for(my=-1;my<=1;my++)
					  {
						ziel=mx+x+tab100[my+y];
						if(items[ziel]==0) items[ziel]=254;
						else if(items[ziel]==was) 
						 {
						  zielx=mx+x;
						  ziely=my+y;
						  laenge=j;
						  kk=1;
						  break;
						 }
					  }
					 items[x+tab100[y]]=250; // Feld fertig überprüft.
					}
				  }
				 if(j>=REICHWEITE) kk=1;
				 }
				if(laenge==0)
				{
//				 free(items);
				 return 1; //Leider kein Weg gefunden
				}
			if((zielx==0)&&(ziely==0)) {/*free(items);*/return 1;}
			 gotoxy(zielx,ziely);
//			 free(items);
			 return 0;
		  }


void Pathfinding::schritt(int wer)
{
	if((abs(basic.px)<16)&&(abs(basic.py)<16))
		{
			if((welt.area[basic.ax+wegx[wegp]+tab100[basic.ay+wegy[wegp]]].Besetzt!=wer)
			&&(welt.area[basic.ax+wegx[wegp]+tab100[basic.ay+wegy[wegp]]].Besetzt>0))
			{
			if(leut[welt.area[basic.ax+gx+tab100[basic.ay+gy]].Besetzt].laenge>0) /*gotoxy(cx,cy)*/ // Steht das Ziel still?
			 wait++;
			} else wait=0;
			if(wait==0)
			{
			
			 if((gx!=0)||(gy!=0))
			{
				phase++;
				if(phase>7) phase=0;
				basic.px+=gx;
				basic.py+=gy;
			}
			} else if(wait>60) stop();
	}
		else feld(wer);
			besetzen(wer);
};
  

