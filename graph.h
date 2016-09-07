// Graph.h
#ifndef _GRAPH_H_
#define _GRAPH_H_
#include "engine.h"

class Graph
{
	void Set_Data(unsigned int x1,unsigned int y1,unsigned int height,unsigned int width);
public:
	void Fuelle_Daten(void);
	void Init_Sprites(void);
	void PutGelaende(int X,int Y,int texture);
	void PutDrac(int X,int Y,int texture);
	int randl,randr,randu,rando;
	struct
	{
		int X1,Y1,X2,Y2;
	} Daten[200];
	Image gelaende,leute,rahmen;
	RECT Gelaende,Leute,Rahmen;
};
extern Graph graph;
#endif