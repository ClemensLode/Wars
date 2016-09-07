  {Hier kommen alle Variablen und so rein}
unit VARIABLE;
 interface
  uses vesa2;
  const BKGR=4096;
  type
  dmaarray=array[0..7] of byte;
  schaften=array[1..84] of integer;
  Block=Array[0..99,0..319] of Byte;
  puffer=array[1..65500] of byte;
  puffer2=array[1..bkgr] of byte;
  sbconfig=record
   basis,
   irq,
   dma:integer;
  end;
  proc=procedure;
  pt=record
   ofs,segm:word;
  end;
{  Funktion:array[1..50,1..6] of record
  eingang:array[1..6] of byte;                  {Eingangsstoffe zum Verarbeiten (ohne Nahrung etc.)}
{  faktor:byte;                                  {Was wird mit dem Stoff gemacht? gelagert,verfeinert}
{  ausgang:array[1..4] of byte;                  {Ausgangsstoffe}
{  le:word;
  rs:byte;
  spezial:array[1..2] of byte;                  {Spezialfunktionen wie Heilung etc.}
   const

   DMA_Adress            : DMAarray = ($00,$02,$04,$06,$C0,$C4,$C8,$CC);
   DMA_Count             : DMAarray = ($01,$03,$05,$07,$C2,$C6,$CA,$CE);
   DMARead_status_Reg    : DMAarray = ($08,$08,$08,$08,$D0,$D0,$D0,$D0);
   DMAWrite_status_Reg   : DMAarray = ($08,$08,$08,$08,$D0,$D0,$D0,$D0);
   DMAWrite_requ_Reg     : DMAarray = ($09,$09,$09,$09,$D2,$D2,$D2,$D2);
   DMAWr_single_mask_Reg : DMAarray = ($0A,$0A,$0A,$0A,$D4,$D4,$D4,$D4);
   DMAWr_mode_Reg        : DMAarray = ($0B,$0B,$0B,$0B,$D6,$D6,$D6,$D6);
   DMAClear_Flipflop     : DMAarray = ($0C,$0C,$0C,$0C,$D8,$D8,$D8,$D8);
   DMARead_Temp_Reg      : DMAarray = ($0D,$0D,$0D,$0D,$DA,$DA,$DA,$DA);
   DMAMaster_Clear       : DMAarray = ($0D,$0D,$0D,$0D,$DA,$DA,$DA,$DA);
   DMA_Clear_Mask_Reg    : DMAarray = ($0E,$0E,$0E,$0E,$DC,$DC,$DC,$DC);
   DMA_Wr_All_Mask_Reg   : DMAarray = ($0F,$0F,$0F,$0F,$DE,$DE,$DE,$DE);
   DMA_Lower_Page        : DMAarray = ($87,$83,$81,$82,$00,$8B,$89,$8A);
   DMA_Higher_Page       : Array[0..7] of word = ($487,$483,$481,$482,$0,$48B,$489,$48A);

   reskosten:array[1..6] of record
    holz,stein,gold,stahl,ziegel,moertel,runden,glas,nahrung:byte;
   end=(
   (holz:7; stein:2; gold:0; stahl:5; ziegel:0; moertel:0;runden:1;glas:0;nahrung:5),
   (holz:12;stein:3; gold:5; stahl:10;ziegel:0; moertel:0;runden:1;glas:0;nahrung:10),
   (holz:20;stein:5; gold:10;stahl:15;ziegel:5; moertel:2;runden:2;glas:0;nahrung:20),
   (holz:27;stein:8; gold:25;stahl:25;ziegel:10;moertel:3;runden:2;glas:0;nahrung:30),
   (holz:40;stein:10;gold:50;stahl:35;ziegel:15;moertel:5;runden:3;glas:15;nahrung:45),
   (holz:45;stein:12;gold:75;stahl:50;ziegel:20;moertel:6;runden:3;glas:30;nahrung:60));

   waffen:array[1..6] of record
    Metall,Holz,Leder,runden:byte;     {Je Metall (Ausser Knochen) 1 SK zusaetzlich}
   end=(
   (metall:7; holz:2; leder:0; runden:5),
   (metall:7; holz:2; leder:0; runden:5),
   (metall:7; holz:2; leder:0; runden:5),
   (metall:7; holz:2; leder:0; runden:5),
   (metall:7; holz:2; leder:0; runden:5),
   (metall:7; holz:2; leder:0; runden:5));

   kosten:array[1..6] of record
    holz,stein,gold,stahl,ziegel,moertel,glas,prodfak,prodbon,runden,lang,breit:byte;le:word;rs:byte;
   end=(
   (holz:25; stein:20; gold:0;  stahl:5;  ziegel:0;  moertel:0; glas:0; prodfak:1; prodbon:0; runden:5; lang:2;breit:2;
   le:100; rs:5),
   (holz:40; stein:30; gold:10; stahl:10; ziegel:0;  moertel:0; glas:0; prodfak:3; prodbon:1; runden:10;lang:3;breit:2;
   le:300; rs:15),
   (holz:65; stein:50; gold:25; stahl:15; ziegel:25; moertel:15;glas:0; prodfak:5; prodbon:2; runden:16;lang:3;breit:3;
   le:1000;rs:30),
   (holz:90; stein:75; gold:50; stahl:50; ziegel:50; moertel:30;glas:0; prodfak:12;prodbon:3; runden:28;lang:3;breit:4;
   le:2000;rs:50),
   (holz:125;stein:100;gold:75; stahl:75; ziegel:75; moertel:45;glas:35;prodfak:28;prodbon:5; runden:42;lang:5;breit:4;
   le:3200;rs:75),
   (holz:150;stein:125;gold:100;stahl:100;ziegel:100;moertel:60;glas:70;prodfak:64;prodbon:10;runden:55;lang:6;breit:5;
   le:4800;rs:100));
   MAX=500;
   STRASSE=35;
   HAUSER=40;
   SOLDIER=10;
   MH=28;
   MR=15;
   KMX=50;
   KMY=50;
   STIMMEN=1;
{   haus:array[1..30,1..6] of record}
type
spieler=record
    waffen:array[0..50] of record
    prod,stuck:word;
   end;
   ruestungen:array[0..50] of record
    prod,stuck:word;
   end;
   vor:array[1..hauser,1..6] of boolean;
   fehler:array[1..25] of boolean;
   einheit:array[1..soldier] of record
    name:string[20];
    rasse:byte;
    werte:schaften;
    wait,da:boolean;
    rus:array[1..4] of byte;
    waf:array[1..4] of byte;
    ax,ay,cx,cy,x,y,f:integer;
   end;
   haus:ARRAY[1..max] of record
    rs,ak,xx,yy,art,stufe,baurunden:byte;
    le:word;
    imaufw,arb,hunger,nahrung:boolean;
   end;
   p:array[1..80] of longint;
   bauqua:word; {Bauqualitaet der zu Bauenden Haueser, also Lehmhuette und so}
   essen,wasser,temp,ya,z,maxw,maxl,maxe,k,bauen:word;
   prod,ch,ro,costs,rounds,steu,unruhe,rekrut,steuern:integer;
   akwa,akru,rustung,weapon,wissen,esse,dorf:longint;
   t:boolean;
   wissenzuprod:byte;           {Prozentsatz des Forschens}
   eigen:schaften;
   end;
   arbeitsnamen=array[1..hauser,1..6,false..true] of string[25];
var
   oldexit,temp,tempbuf,oldintvec:POINTER;
   oldproc:proc absolute oldintvec;
{   blk1,blk2:^puffer2;}
   sb:sbconfig;
   eigen:schaften;
{   Src_Frame,Dest_Frame:^Block;}
   hh,loose1,loose2,main,feld,fa,repeatet,last,last2,read1,read2,w,block2:BOOLEAN;
   rnd,stark,bb,pn,aaa,ydiv,poss,oo,segmen,offse,pr,yyy,hoehe2,blockgr,irq,dma,basis,y1,y1_dir,maske,i:WORD;
   zeit,pp,size:byte;
   ticker,m,ranzahl,wanzahl,le1,le2,line3,line2,x,y,k,l,j,wait,ii,sizei:INTEGER;
   seite,frequenz,gross,physpos:LONGINT;
   f:text;
   fil,h:FILE;
   a:CHAR;
   ast,name:string;
{   Sinus:Array[0..63] of Word; {Sinustabelle, wird spÑter gefÅllt}
{   bufinfo:array[1..6] of record
    start:pointer;
   end;
{   samples:array[1..16] of record
    adresse:pointer;
    laenge:longint;
    loop:boolean;
   end;
   playinfo:array[1..stimmen] of record
    fertig:boolean;
    nummer:byte;
    pos:longint;
   end;}
{   mm:array[1..bkgr] of byte;
   blk:array[1..stimmen] of ^puffer;}
   spr:array[0..41] of spritetyp;
   qua:array[0..6] of spritetyp;
   roh:array[0..21] of spritetyp;
   gel:array[0..142] of spritetyp;
   zus:array[0..18] of spritetyp;
   gel2:array[0..142] of spritetyp;
   regen:array[1..4,1..3] of spritetyp;
   karte:array[0..75,0..75] of record art,bon:byte;end;
   rassen:array[1..11] of record
    name:string[15];
    werte:schaften;
   end;
   talente:array[1..83] of string[25];
   waf:array[1..50] of record
    wava,wavp,reich,tp,boni,art:integer;
    s:string[25];
   end;
   rus:array[1..50] of record
    art,rs:byte;
    s:string[25];
   end;
   dat:array[1..5,1..5] of string[14];
   n:array[1..hauser,1..6] of string[22];
   help:array[1..25] of string[60];
   s:array[0..1] of ^spieler;
   arbeit:^arbeitsnamen;
implementation
begin
end.