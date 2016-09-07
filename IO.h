//IO.h
#ifndef _IO_H_
#define _IO_H_

const UP=1;
const DOWN=2;
const LEFT=3;
const RIGHT=4;

class Input
{
	int sx,sy,startsx,startsy,startfx,startfy,startscx,startscy,akfeinx,akfeiny,akscrollx,akscrolly;
	void Calculate_KPos();
public:
	int InAction,RStartX,RStartY,scrollx,scrolly,xPos,yPos,feinx,feiny,KxPos,KyPos,Rahmen;;
	void Move(unsigned int lParam);
	void Update_scroll();
	void Scroll(char direction);
	void Scroll_mouse();
	void LDown();
	void LUp();
	void MUp();
	void RDown();
	void RUp();
}; 
extern Input input;
#endif
