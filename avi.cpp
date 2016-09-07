#include "engine.h"

BOOL OpenMMStream(const char *, IDirectDraw *, IMultiMediaStream **);
HRESULT RenderStreamToSurface(IDirectDraw *,IDirectDrawSurface *,IMultiMediaStream *,BOOL);

void Engine_AVIStream::Load(char *strfile)
{
	OpenMMStream(strfile,this->En_Graph.info.lpDD, &MMStream);
}

void Engine_AVIStream::PlayOnSurface(IDirectDrawSurface *surf,BOOL stretch)
{
	RenderStreamToSurface(this->En_Graph.info.lpDD,surf,MMStream,stretch);
}

BOOL OpenMMStream(const char * pszFileName, IDirectDraw *pDD, IMultiMediaStream **ppMMStream)
{
	CoInitialize(NULL);
	*ppMMStream = NULL;
    IAMMultiMediaStream *pAMStream;
    HRESULT hr;

    CoCreateInstance(CLSID_AMMultiMediaStream, NULL, CLSCTX_INPROC_SERVER,
				 IID_IAMMultiMediaStream, (void **)&pAMStream);
    
	pAMStream->Initialize(STREAMTYPE_READ, 0, NULL);
    pAMStream->AddMediaStream(pDD, &MSPID_PrimaryVideo, 0, NULL);
    pAMStream->AddMediaStream(NULL, &MSPID_PrimaryAudio, AMMSF_ADDDEFAULTRENDERER, NULL);

    WCHAR       wPath[MAX_PATH];
    MultiByteToWideChar(CP_ACP, 0, pszFileName, -1, wPath, sizeof(wPath)/sizeof(wPath[0]));

    pAMStream->OpenFile(wPath, 0);

    *ppMMStream = pAMStream;
    pAMStream->AddRef();

Exit:
    if (pAMStream == NULL) {
		return FALSE;
    }
    RELEASE(pAMStream);
    CoUninitialize();
	return hr;
}

HRESULT RenderStreamToSurface(IDirectDraw *pDD, IDirectDrawSurface *pPrimary,
			      IMultiMediaStream *pMMStream,BOOL stretch)
{

    HRESULT hr;
    IMediaStream *pPrimaryVidStream = NULL;
    IDirectDrawMediaStream *pDDStream = NULL;
    IDirectDrawSurface *pSurface = NULL;
    IDirectDrawStreamSample *pSample = NULL;

    RECT rect;

    pMMStream->GetMediaStream(MSPID_PrimaryVideo, &pPrimaryVidStream);
    pPrimaryVidStream->QueryInterface(IID_IDirectDrawMediaStream, (void **)&pDDStream);

    pDDStream->CreateSample(NULL, NULL, 0, &pSample);
    pSample->GetSurface(&pSurface, &rect);
    
    pMMStream->SetState(STREAMSTATE_RUN);

    while (true) {
	if (pSample->Update(0, NULL, NULL, 0) != S_OK) {
	    break;
	}
	if(stretch)
		pPrimary->Blt(NULL,pSurface,NULL,DDBLT_WAIT,NULL);
    else
		pPrimary->Blt(&rect,pSurface,&rect,DDBLT_WAIT,NULL);
	}

Exit:
    RELEASE(pPrimaryVidStream);
    RELEASE(pDDStream);
    RELEASE(pSample);
    RELEASE(pSurface);

    return hr;
}