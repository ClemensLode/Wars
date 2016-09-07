//Welt.h
//Schnittstelle zwischen Hauptprogramm und Funktionen

#ifndef _WELT_H_
#define _WELT_H_
#include "engine.h"
#include "IO.h"
#include "graph.h"

extern unsigned int scrollx,scrolly,feinx,feiny;
extern long xx,yy,k;
// Alle Konstanten
const KARTEX=50;
const KARTEY=50;
const KARTEMEM=KARTEX*KARTEY;
const REICHWEITE=KARTEX;
const ANZMANN=100;
const ANZHAUS=100;
const ANZPFLANZ=100;
const STARTHAEUSER=4;
const BEEREN=2;//IDs der Objekte
const HOLZ=1;
const BAUM=1;  
const BEERENSTRAUCH=2;
const HAUS=3;
const WOHNKAPAZITAET=3; //Standart grün/braun-Pixel-Haus 

class Welt
{
public:
	int temper[KARTEMEM];
	int tkarte[KARTEMEM];
	//int wasserk[KARTEMEM*4];
	int gebirge[KARTEMEM];
//	unsigned char _3DDAT[KARTEMEM];
	int karte[KARTEMEM];
//	unsigned int objekt[KARTEMEM];
//	unsigned int besetzt[KARTEMEM];
	void calculateXY(void);
	struct Area
	{
		int Level,Besetzt,ObjektArt,ObjektNum,Sprite,absx,absy;
	} area[KARTEMEM];
	BOOL Fail(char *szMsg);	
	void Minimap();    // Kleine verschiebbare Minimap malen
	void Berechne_tab100();
	void Paint_Objects();	 // Puffer löschen, Puffer mit Welt füllen, Mit Flip auf den Bildschirm bringen
	void Schaffe_Wasser();		 
	void Flut_Ebbe();
	void Plaziere_Objekte();
	void Kueste_verkalkulieren();
	void Rendern();
	void Es_werde_Licht();
	void Reload_Area();
};

extern unsigned int number;
extern IDirectDrawSurface *spr;
extern Welt welt;
extern unsigned int tab100[KARTEY];	
#endif