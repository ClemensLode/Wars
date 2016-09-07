#include "engine.h"

void Engine_CDAudio::Open()
{
	mciSendString("open cdaudio",NULL,NULL,NULL);
    mciSendString("set cdaudio time format tmsf",NULL,NULL,NULL);
}

void Engine_CDAudio::Play(int Track)
{
	char cmd[30];
	wsprintf(cmd,"play cdaudio from %d to %d",Track,(Track+1));
	mciSendString(cmd,NULL,NULL,NULL);
}

void Engine_CDAudio::Stop()
{
	mciSendString("stop all",NULL,NULL,NULL);
}

