// Array mit Objekten erstellen (mit Arraynummern!)


#ifndef _PATH_H_
#define _PATH_H_

#include "Welt.h"

class basics
{
public:
		void setxy(int setx, int sety);
		void calculateXY(void);
		int px,py,ax,ay,absx,absy,vorhanden;
};
class haeuser_class
{
public:
		//void Neuer_Leut(int wo);
		basics basic;
		int Stoff[5];
};

class pflanzen_class
{
public:
		basics basic;
		int Art;
		void check(void);
		int Stoff[5];
};

class Pathfinding
{
		int suche(void);
		void feld(int wer);
		unsigned char kompass(void);
public:
		signed char wegx[REICHWEITE];
		signed char wegy[REICHWEITE];
		int activ,newgo,wegp,laenge,cx,cy,gx,gy,wait,phase,richtung; //aktuelle Koordinaten und Ziel
		int home;
		int Stoff[5];
		void stop(void);
		void gotoxy(int gox, int goy);
		void Next_action(void);
		void schritt(int wer);
		void action(void);
		void besetzen(int wer);
		int Find(int was);
		basics basic;
};

extern Pathfinding leut[ANZMANN];
extern haeuser_class haus[ANZHAUS];
extern pflanzen_class pflanz[ANZPFLANZ];
#endif