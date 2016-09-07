uses crt,dos,modexlib,gif{fontes},vesa,tools;
type dmaarray=array[0..7] of byte;
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
 DMA_Higher_Page       : Array[0..7] of word
                            = ($487,$483,$481,$482,$0,$48B,$489,$48A);
max=500;
hauser=29;
soldier=10;
mh=28;
mr=15;
kmx=50;
kmy=50;
bkgr=4096;
stimmen=1;
reskosten:array[1..6] of record
holz,stein,gold,stahl,ziegel,moertel,runden,glas,nahrung:byte;
end=(
(holz:7; stein:2; gold:0; stahl:5; ziegel:0; moertel:0;runden:1;glas:0;nahrung:5),
(holz:12;stein:3; gold:5; stahl:10;ziegel:0; moertel:0;runden:1;glas:0;nahrung:10),
(holz:20;stein:5; gold:10;stahl:15;ziegel:5; moertel:2;runden:2;glas:0;nahrung:20),
(holz:27;stein:8; gold:25;stahl:25;ziegel:10;moertel:3;runden:2;glas:0;nahrung:30),
(holz:40;stein:10;gold:50;stahl:35;ziegel:15;moertel:5;runden:3;glas:15;nahrung:45),
(holz:45;stein:12;gold:75;stahl:50;ziegel:20;moertel:6;runden:3;glas:30;nahrung:60));
kosten:array[1..6] of record
holz,stein,gold,stahl,ziegel,moertel,glas,prodfak,prodbon,runden:byte;
end=(
(holz:25; stein:20; gold:0;  stahl:5;  ziegel:0;  moertel:0; glas:0; prodfak:1; prodbon:0; runden:5),
(holz:40; stein:30; gold:10; stahl:10; ziegel:0;  moertel:0; glas:0; prodfak:3; prodbon:1; runden:10),
(holz:65; stein:50; gold:25; stahl:15; ziegel:25; moertel:15;glas:0; prodfak:5; prodbon:2; runden:16),
(holz:90; stein:75; gold:50; stahl:50; ziegel:50; moertel:30;glas:0; prodfak:12;prodbon:3; runden:28),
(holz:125;stein:100;gold:75; stahl:75; ziegel:75; moertel:45;glas:35;prodfak:28;prodbon:5; runden:42),
(holz:150;stein:125;gold:100;stahl:100;ziegel:100;moertel:60;glas:70;prodfak:64;prodbon:10;runden:55));
type
 sbconfig=record
   basis,                    { Basisport                           }
   irq,                      { verwendeter IRQ                     }
   dma:integer;               { benutzter DMA-Kanal                 }
end;
schaften=array[1..69] of integer;
 Block=Array[0..99,0..319] of Byte;
  proc=procedure;
  pt=record
  ofs,segm:word;
  end;
  puffer=array[1..65500] of byte;
  puffer2=array[1..bkgr] of byte;
var
repeatet:boolean;
   sb:sbconfig;
   blockgr,irq,dma,basis:WORD;
   yyy,hoehe2:word;
   Src_Frame,                    {vorheriges Bild}
  Dest_Frame:^Block;            {aktuelles Bild}
y1,y1_dir,maske,i:word;size:byte;
    sizei:integer;
{    palette1,
    origpal,
    zielpal:Array[0..767] of Byte;}
   Sinus:Array[0..63] of Word; {Sinustabelle, wird spÑter gefÅllt}
  bufinfo:array[1..6] of record
   start:pointer;
  end;
  samples:array[1..16] of record {die 16 sind die Anzahl der Gesamtmoeglichen Stimmen!}
   adresse:pointer;
   laenge:longint;
   loop:boolean;
  end;
  playinfo:array[1..stimmen] of record
   fertig:boolean;
   nummer:byte;
   pos:longint;
  end;
  mm:array[1..bkgr] of byte;
  blk:array[1..stimmen] of ^puffer;
  blk1,blk2:^puffer2;
  oldexit,temp,tempbuf,oldintvec:pointer;
  aaa,ydiv,poss,oo,segmen,offse,pr:word;frequenz,gross,physpos:longint;
  zeit,pp:byte;
  wait,ii:integer;
  last,last2,read1,read2,w,block2:boolean;
  h:file;
  oldproc:proc absolute oldintvec;
  pn:word;
  a:char;
spr:array[0..40] of spritetyp;
qua:array[0..5] of spritetyp;
roh:array[0..20] of spritetyp;
gel:array[0..141] of spritetyp;
zus:array[0..8] of spritetyp;
gel2:array[0..141] of spritetyp;
m,ranzahl,wanzahl,le1,le2,line3,line2,x,y,k,l,j:integer;
karte:array[1..75,1..75] of record art,bon:byte;end;
fa:boolean;
rnd,stark,bb:word;
seite:longint;
f:text;fil:file;
rassen:array[1..10] of record
name:string[15];
werte:schaften;
end;
name:string;
hh,loose1,loose2,main,feld:boolean;
waf:array[1..50] of record
wava,wavp,reich,tp,boni,art:integer;
s:string[20];
end;
rus:array[1..50] of record
art,rs:byte;
s:string[20];
end;
dat:array[1..5,1..5] of string[14];
n:array[1..hauser,1..6] of string[22];
help:array[1..25] of string[60];
s:array[0..1] of record
waffen:array[0..50] of record
prod,stuck:word;end;
ruestungen:array[0..50] of record
prod,stuck:word;end;
akwa,akru,rustung,weapon,wissen,esse,dorf:longint;
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
eigen:schaften;
haus:ARRAY[1..max] of record
xx,yy,art,stufe:byte;
hunger,baurunden:byte;
ak,nahrung:boolean;
end;
p:array[1..25] of longint;
maxl,maxe,k,bauen:word;
prod,ch,ro,costs,rounds,steu,unruhe,rekrut,befehle,steuern:integer;
temp,ya,z:word;
t:boolean;
end;
procedure writes(sss:string);
begin
end;
procedure play(nummerp:byte);
var p:byte;
begin
for p:=1 to stimmen do if playinfo[p].fertig=true then begin
playinfo[p].fertig:=false;
playinfo[p].nummer:=nummerp;
playinfo[p].pos:=0;
exit;
end;
end;

 procedure mische;
  var mmm,divisor,ll,j:word;
 begin
  divisor:=0;
  for ll:=1 to stimmen do if playinfo[ll].fertig=false then inc(divisor);
  for j:=1 to bkgr do
  begin
   m:=0;
   for ll:=1 to stimmen do begin
   inc(playinfo[i].pos);
   if playinfo[ll].pos+blockgr>=samples[playinfo[ll].nummer].laenge then if samples[playinfo[ll].nummer].loop then
   playinfo[ll].pos:=0 else
   playinfo[ll].fertig:=true;
    if playinfo[ll].fertig=false then
     inc(m,blk[playinfo[ll].nummer]^[playinfo[ll].pos]-128);
   end;
   if divisor>0 then mm[j]:=m div divisor+128 else mm[j]:=128;
  end;
  if block2 then begin
  block2:=false;for j:=1 to bkgr do blk1^[j]:=mm[j];end else begin
  block2:=true;for j:=1 to bkgr do blk2^[j]:=mm[j];end;
 end;  {Buffer blk1 oder blk2 gefuellt!!!!}
procedure handler;interrupt;
begin
asm
   mov   dx,basis
   add   dx,$E
   in    al,dx
   sub   dx,2
@irq_bereit1:
   in    al,dx
   and   al,128
   jne   @irq_bereit1
   mov   al,14h
   out   dx,al
@irq_bereit2:
   in    al,dx
   and   al,128
   jne   @irq_bereit2
   mov   ax,blockgr
   out   dx,al
@irq_bereit3:
   in    al,dx
   and   al,128
   jne   @irq_bereit3
   mov   al,ah
   out   dx,al
end;
{If gross>3*blockgr then begin}
if block2 then begin
block2:=false;
if repeatet=false then read1:=true;
end else begin
block2:=true;
if repeatet=false then read2:=true;
end;
{end else
if (gross<=3*blockgr) then begin
close(f);
seek(h,0);
end;}
port[$20]:=$20;
end;
Procedure Scroll_Up;assembler;
{scrollt das Bild um eine Zeile nach oben und interpoliert}
asm
  push ds
  les di,Dest_Frame             {Zeiger auf Zielbild laden}
  lds si,Src_Frame              {Zeiger auf Quellbild}
  add si,320                    {im Quellbild auf Zeile 1}
  mov cx,320*98                 {99 Zeilen scrollen}
  xor bl,bl                     {wird als Dummy fÅr High-Byte benîtigt}
@lp1:
  xor ax,ax
  xor bx,bx
  mov al,[si-321]               {ersten Punkt holen}
  mov bl,[si-320]               {zweiten Punkt addieren}
  add ax,bx
  mov bl,[si-319]               {nÑchsten Punkt addieren}
  add ax,bx
  mov bl,[si-1]                 {usw...}
  add ax,bx
  mov bl,[si+1]
  add ax,bx
  mov bl,[si+319]
  add ax,bx
  mov bl,[si+320]
  adc ax,bx
  mov bl,[si+321]
  adc ax,bx
  shr ax,3
  or ax,ax                      {bereits 0 ?}
  je @null
  dec al                        {wenn nein, dann verringern}
@null:
  stosb                         {Wert ins Ziel}
  inc si                        {nÑchsten Punkt}
  dec cx                        {weitere Punkte ?}
  jne @lp1
  pop ds
End;

Procedure New_Line;             {baut die untersten Zeilen neu auf}
Var i,x:Word;
Begin
  For x:=1 to 319 do Begin      {untere 3 Zeilen mit zufÑlligen Werten fÅllen}
    Dest_Frame^[97,x]:=Random(rnd)+stark;
    Dest_Frame^[98,x]:=Random(rnd)+stark;
    Dest_Frame^[99,x]:=Random(rnd)+stark;
  End;
  For i:=0 to Random(35) do Begin {zuf. Anzahl Hotspots einfÅgen}
    x:=Random(size*2)+160-size;             {an zufÑllige Koordinaten}
    asm
      les di,Dest_Frame         {Zielbild adressieren}
      add di,97*320             {Zeile 98 (zweitunterste) bearbeiten}
      add di,x                  {x-Koordinate dazu}
      mov al,0ffh               {hellste Farbe}
      mov es:[di-321],al        {gro·en Hotspot erzeugen (9 Punkte)}
      mov es:[di-320],al
      mov es:[di-319],al
      mov es:[di-1],al
      mov es:[di],al
      mov es:[di+1],al
      mov es:[di+319],al
      mov es:[di+320],al
      mov es:[di+321],al
    End;
  End;
End;

Procedure Show_Screen;          {kopiert fertigen Bilschirm auf VGA}
Var temp:Pointer;               {zum Tauschen der Zeiger}
Begin
asm
  push ds
  lds si,Dest_Frame             {fertiges Bild als Quelle}
  mov ax,0a000h                 {VGA als Ziel}
  mov es,ax
  mov di,320*100                {ab Zeile 100}
  mov cx,320*100/4              {100 Zeilen als Dwords kopieren}
  db 66h                          {Operand Size Prefix (32 Bit)}
  rep movsw                     {kopieren}
  pop ds
End;
  temp:=Dest_Frame;             {Zeiger auf Quell- und Zielbild tauschen}
  Dest_Frame:=Src_Frame;
  Src_Frame:=temp;
End;

Procedure Prep_Pal;             {Palette auf Flames vorbereiten}
Var i:Word;
Begin
  FillChar(Palette,80*3,0);     {Grundlage: alles schwarz}
  For i:=0 to 7 do Begin
    Palette[i*3+2]:=i*2;        {Farbe 0-7: Anstieg Blau}
    Palette[(i+8)*3+2]:=16-i*2; {Farbe 0-7: abfallendes Blau}
  End;
  For i:=8 to 31 do             {Farbe 8 -31: Anstieg Rot}
    Palette[i*3]:=(i-8)*63 div 23;
  For i:=32 to 55 do Begin      {Farbe 32-55: Anstieg GrÅn, Rot konstant}
    Palette[i*3]:=63;
    Palette[i*3+1]:=(i-32)*63 div 23;
  End;
  For i:=56 to 79 do Begin      {Farbe 56-79: Anstieg Blau,Rot u. Blau konst.}
    Palette[i*3]:=63;
    Palette[i*3+1]:=63;
    Palette[i*3+2]:=(i-56)*63 div 23;
  End;
  FillChar(Palette[80*3],176*3,63);  {Rest wei·}
  SetPal;                       {fertige Palette setzen}
End;
 procedure writedsp(b:byte);assembler;
  asm
   mov dx,basis
   add dx,$C;
   @warten:
   in al,dx;
   test al,$80;
   jne @warten;
   mov al,b;
   out dx,al;
 end;
 function readdsp:byte;
  var t:byte;
 begin
  asm
   mov dx,basis
   add dx,$E;
   @warten:
   in al,dx;
   test al,$80;
   je @warten;
   sub dl,4;
   in al,dx;
   mov t,al;
  end;
  readdsp:=t;
 end;
  procedure programexit;far;
   begin
    freemem(blk1,bkgr);
    freemem(blk2,bkgr);
    for i:=1 to stimmen do if samples[i].laenge>0 then freemem(blk[i],samples[i].laenge);
    exitproc:=oldexit;
    writedsp($D3);
    writedsp($DA);
    writedsp($D0);
    port[$6+basis]:=1;
    for i:=1 to 256 do;
    port[$6+basis]:=0;
    asm
     cli
     push  es
     push  di
     mov   dx,irq
     mov   al,0d0h
     out   dx,al
     mov   ax,[WORD PTR oldintvec+0]
     mov   dx,[WORD PTR oldintvec+2]
     xor   di,di
     mov   es,di
     mov   di,irq
     shl   di,2
     add   di,20h
     mov   WORD PTR es:[di+0],ax
     mov   WORD PTR es:[di+2],dx
     mov   es,pn
     mov   ah,49h
     int   21h
     mov   dx,irq
     mov   al,0d3h
     out   dx,al
     pop   di
     pop   es
     sti
    end;
    port[$20]:=$20;
   end;
   procedure initsb;
    var dir:searchrec;
    begin
     write('Hole Daten aus CONFIG.WRS ... ');
     findfirst('CONFIG.WRS',archive,dir);
     if doserror<>0 then begin writeln('nicht gefunden! SETUP.EXE ausfuehren!');halt;end;
     assign(h,'config.wrs');
     reset(h,1);
     blockread(h,sb,sizeof(sb));
     close(h);
     basis:=sb.basis;irq:=sb.irq;dma:=sb.dma;
     writeln('Initialisiere DSP ...');
     port[$6+basis]:=1;
     for i:=1 to 256 do;
     port[$6+basis]:=0;
     if readdsp<>$AA then begin
      writeln('Soundblaster oder kompatible wurden nicht gefunden! SETUP.EXE erneut versuchen.');
      halt;
     end;
     writedsp($E1);
     writeln('DSP-Versionsnummer: ',readdsp,'.',readdsp);
     writeln('Aktiviere Lautsprecher ...');
     writedsp($d1);
    end;
   procedure initdma(buf:pointer;size2:word);
    begin
     physpos:=16*longint(pt(buf).segm)+pt(buf).ofs;
     pn:=pt(physpos).segm;
     offse:=pt(physpos).ofs;
     port[dmawr_single_mask_reg[dma]]:=5;
     port[dmawr_mode_reg[dma]]:=1 or $58;
     port[dma_adress[dma]]:=lo(offse);
     port[dma_adress[dma]]:=hi(offse);
     port[dma_lower_page[dma]]:=lo(pn);
     port[dma_higher_page[dma]]:=hi(pn);
     port[dmaclear_flipflop[dma]]:=0;
     port[dma_count[dma]]:=lo(size2*2-1);
     port[dma_count[dma]]:=hi(size2*2-1);
     writedsp($40);
     writedsp(256-1000000 div frequenz);
     writedsp($14);
     writedsp(lo(size2-1));
     writedsp(hi(size2-1));
     asm
      cli
      mov di,irq
      mov cx,di
      in al,$21
      mov bl,1
      shl bl,cl
      not bl
      and al,bl
      out $21,al
      mov ax,offset handler
      xor dx,dx
      mov es,dx
      mov dx,cs
      shl di,2
      add di,$20
      xchg ax,word ptr es:[di+0]
      xchg dx,word ptr es:[di+2]
      mov [word ptr oldintvec+0],ax
      mov [word ptr oldintvec+2],dx
      mov dx,basis
      add dx,$C
      sub dx,8
      mov al,$0e
      out dx,al
      inc dx
      in al,dx
      or al,2
      out dx,al
      sti
     end;
     port[dmawr_single_mask_reg[dma]]:=1;
    end;

function anzahl(art:word):word;
begin
 s[m].temp:=0;
 for j:=1 to max do begin
  if s[m].haus[j].art=art then inc(s[m].temp);
 end;
 anzahl:=s[m].temp;
end;
function artzusprite(nummer:byte):byte;
var temp:byte;
begin
temp:=nummer;
case nummer of
3:temp:=17;
5:temp:=3;
6:temp:=5;
7:temp:=8;
8:temp:=18;
9:temp:=19;
10:temp:=20;
11:temp:=7;
12:temp:=11;
13:temp:=11;
14:temp:=13;
15:temp:=16;
16:temp:=15;
17:temp:=16;
18:temp:=16;
19:temp:=16;
20:temp:=16;
21:temp:=14;
22:temp:=16;
23:temp:=9;
24:temp:=6;
25:temp:=16;
26:temp:=16;
27:temp:=12;
28:temp:=16;
29:temp:=10;
end;
artzusprite:=temp;
end;
function g(h:word):word;
begin
case h of
1:g:=1;
2:g:=2;
3:g:=3;
4:g:=5;
5:g:=7;
6:g:=10;
end;
end;
procedure baueweiter;
var nummer:word;
begin
for nummer:=1 to max do if (s[m].haus[nummer].baurunden>0) and (s[m].bauen>0) then begin
dec(s[m].bauen);
dec(s[m].haus[nummer].baurunden);
if s[m].haus[nummer].baurunden=0 then begin
s[m].haus[nummer].ak:=true;s[m].haus[nummer].xx:=x;
s[m].haus[nummer].yy:=y;nummer:=max;exit;
end;
end;
end;


function r(gart:word):integer;
var s:byte;
begin
s:=1;
repeat
if s<6 then begin
if n[gart,s]='-' then inc(s) else begin r:=s;exit;end;
end;
until s=6;
r:=0;
end;
procedure Dorfgrafik;
var xx:word;
begin
for xx:=1 to max do begin
gotoxy(s[m].haus[xx].xx,s[m].haus[xx].yy);
textcolor(s[m].haus[xx].art);textbackground(s[m].haus[xx].stufe);write(chr(s[m].haus[xx].art+13));
end;
textcolor(2);textbackground(0);gotoxy(x,y);write(#1);
end;
procedure Feldinfo;
 var o:word;ok:boolean;
begin
 ok:=true;
 for o:=1 to max do if (s[m].haus[o].xx=x) and (s[m].haus[o].yy=y) then begin
  writeln('Rounds To Built: ',s[m].haus[o].baurunden);
  writeln('Art    : ',n[s[m].haus[o].art,s[m].haus[o].stufe]:20,' Holzbretter : ',s[m].p[1]:5);
  writeln('Stufe  : ',chr(s[m].haus[o].stufe+64):20,' Granit      : ',s[m].p[2]:5);
  writeln('Nahrung: ',s[m].haus[o].nahrung:20,' Stahl       : ',s[m].p[9]:5);
  writeln('X      : ',s[m].haus[o].xx:20,' Ziegel      : ',s[m].p[4]:5);
  writeln('Y      : ',s[m].haus[o].yy:20,' Lehm        : ',s[m].p[3]:5);
  writeln('Arbeit : ',s[m].haus[o].ak:20,' Kohle       : ',s[m].p[7]:5);
  writeln('         ':29,' Eisenerz    : ',s[m].p[8]:5);
  writeln('         ':29,' Golderz     : ',s[m].p[10]:5);
  writeln('         ':29,' Leder       : ',s[m].p[6]:5);
  writeln('         ':29,' Goldmuenzen : ',s[m].p[11]:5);
  writeln('         ':29,' Nahrung     : ',s[m].p[14]:5);
  writeln('         ':29,' Wasser      : ',s[m].p[15]:5);
  writeln('         ':29,' Waffe       : ',s[m].p[17]:5);
  writeln('         ':29,' Ruestung    : ',s[m].p[18]:5);
  writeln('         ':29,' Einheiten   : ',s[m].p[12]:5);
  writeln('         ':29,' Diamanten   : ',s[m].p[13]:5);
  ok:=false;
  break;
 end;
 if ok  then begin
  writeln('Rounds To Built: ',s[m].haus[o].baurunden);
  writeln('Art    : ',n[s[m].haus[o].art,s[m].haus[o].stufe]:20,' Holzbretter : ',s[m].p[1]:5);
  writeln('Stufe  : ','A':20,' Granit      : ',s[m].p[2]:5);
  writeln('Nahrung: ',s[m].haus[o].nahrung:20,' Stahl       : ',s[m].p[9]:5);
  writeln('X      : ',x:20,' Ziegel      : ',s[m].p[4]:5);
  writeln('Y      : ',y:20,' Lehm        : ',s[m].p[3]:5);
  writeln('Arbeit : ',s[m].haus[o].ak:20,' Kohle       : ',s[m].p[7]:5);
  writeln('         ':29,' Eisenerz    : ',s[m].p[8]:5);
  writeln('         ':29,' Golderz     : ',s[m].p[10]:5);
  writeln('         ':29,' Leder       : ',s[m].p[6]:5);
  writeln('         ':29,' Goldmuenzen : ',s[m].p[11]:5);
  writeln('         ':29,' Nahrung     : ',s[m].p[14]:5);
  writeln('         ':29,' Wasser      : ',s[m].p[15]:5);
  writeln('         ':29,' Waffe       : ',s[m].p[17]:5);
  writeln('         ':29,' Ruestung    : ',s[m].p[18]:5);
  writeln('         ':29,' Einheiten   : ',s[m].p[12]:5);
  writeln('         ':29,' Diamanten   : ',s[m].p[13]:5);
 end;
end;
procedure MainInfo;
begin
 writeln('Hauptrohstoffe:');
 writeln('Holz     : ',s[m].p[1]);
 writeln('Granit   : ',s[m].p[2]);
 writeln('Ziegel   : ',s[m].p[4]);
 writeln('Stahl    : ',s[m].p[9]);
 writeln('Nahrung  : ',s[m].p[14]);
 writeln('Wasser   : ',s[m].p[15]);
 writeln('Gold     : ',s[m].p[11]);
 writeln('Kohle    : ',s[m].p[7]);
 writeln('Noch ',s[m].befehle,' Befehle ausfuerbar!');
 writeln('Noch ',s[m].bauen,' Gebaeude bauen!');
 writeln('Wissenstand: ',s[m].wissen);
 writeln('Steuern   : ',s[m].steu,' %');
 writeln('Verteilung: ',s[m].Steuern,' % Gold ',100-s[m].steuern,' % Nahrung');
 writeln('Dorf: ',s[m].dorf,' Einwohner (',s[m].DORF DIV 100,'N u. T)');
 writeln('Unruhe im Dorf :',round(s[m].dorf/100*s[m].unruhe));
 writeln('Ruestungsart : ',rus[s[m].rustung].s:20,':',s[m].ruestungen[s[m].rustung].prod);
 writeln('Waffenart    : ',waf[s[m].weapon].s:20,':',s[m].waffen[s[m].weapon].prod);
 if s[m].ch=1 then s[m].temp:=hauser else s[m].temp:=s[m].ch-1;
 write('  Art: ',n[s[m].temp,r(s[m].temp)]:20,'   ',chr(r(s[m].temp)+64));
 textcolor(s[m].temp);textbackground(r(s[m].temp));writeln(chr(s[m].temp+13));
 textcolor(2);textbackground(0);
 s[m].temp:=s[m].ch;
 write('>>Art: ',n[s[m].ch,r(s[m].temp)]:20,'   ',chr(r(s[m].temp)+64));
 textcolor(s[m].temp);textbackground(r(s[m].temp));writeln(chr(s[m].temp+13));
 textcolor(2);textbackground(0);
 if s[m].ch>=hauser then s[m].temp:=1 else s[m].temp:=s[m].ch+1;
 write('  Art: ',n[s[m].temp,r(s[m].temp)]:20,'   ',chr(r(s[m].temp)+64));
 textcolor(s[m].temp);textbackground(r(s[m].temp));writeln(chr(s[m].temp+13));
 textcolor(2);textbackground(0);
end;
procedure fenster;
begin
for i:=1 to 25 do if s[m].fehler[i] then begin clrscr;s[m].fehler[i]:=false;writeln(help[i]);readkey;end;
end;
procedure screen;
begin
window(1,1,80,25);
clrscr;
if fa then exit;
textbackground(0);
window(1,2,25,25);
clrscr;
Dorfgrafik;
window(1,20,25,25);
fenster;
window(26,2,80,25);
if main then Maininfo;
if feld then Feldinfo;
textbackground(0);
window(1,1,80,25);
end;
{procedure choose(sp:byte);
begin
repeat
case readkey of
#80:if reihe>1 then dec(reihe) else reihe:=max;
#72:if reihe<max then inc(reihe) else reihe:=1;
#13:}
{procedure Datei;
var spalte:byte;
begin
repeat
case readkey of
#72:
#80:
#13:begin clrscr;case spalte of
1:Save;
2:Load;
3:Exit;
end;
#27:begin clrscr;exit;end;


until false;
end;
procedure menu;
var spalte:byte;
begin
textbackground(lightgray);
writeln;
gotoxy(1,1);
spalte:=1;
repeat
gotoxy(1,1);
if spalte=1 then textbackground(blue) else textbackground(lightgray);
write('Datei':14);
if spalte=2 then textbackground(blue) else textbackground(lightgray);
write('Regierung':14);
if spalte=3 then textbackground(blue) else textbackground(lightgray);
write('Rohstoffe':14);
if spalte=4 then textbackground(blue) else textbackground(lightgray);
write('Herstellung':14);
case readkey of
#75:if spalte>1 then dec(spalte) else spalte:=4;
#77:if spalte<4 then inc(spalte) else spalte:=1;
#27:begin textbackground(0);clrscr;screen;exit;end;
#13:begin clrscr;case spalte of
1:Datei;
2:Regie;
3:Rohst;
4:Herst;
end;end;
end;
until false;
end;}
procedure gener;
var line:byte;ready:boolean;
begin
clrscr;
line:=2;
repeat
clrscr;
writeln('Mut                  :',s[m].eigen[1]);
writeln('Klugheit             :',s[m].eigen[2]);
writeln('Charisma             :',s[m].eigen[3]);
writeln('Intuition            :',s[m].eigen[4]);
writeln('Fingerfertigkeit     :',s[m].eigen[5]);
writeln('Gewandtheit          :',s[m].eigen[6]);
writeln('Koerperkraft         :',s[m].eigen[7]);
writeln('Lebensenergie        :',s[m].eigen[8]);
writeln('Astralenergie        :',s[m].eigen[9]);
writeln('Waffenlos            :',s[m].eigen[10]);
writeln('Speere, Staebe       :',s[m].eigen[11]);
writeln('Stichwaffen          :',s[m].eigen[12]);
writeln('Aexte, Beile         :',s[m].eigen[13]);
writeln('stumpfe Hiebwaffen   :',s[m].eigen[14]);
writeln('scharfe Hiebwaffen   :',s[m].eigen[15]);
writeln('Schwerter            :',s[m].eigen[16]);
writeln('Zweihaender          :',s[m].eigen[17]);
writeln('Infanteriewaffen     :',s[m].eigen[18]);
writeln('Wurfwaffen           :',s[m].eigen[19]);
writeln('Schusswaffen         :',s[m].eigen[20]);
writeln('Produziere ... Stueck:',s[m].prod);
    s[m].einheit[line2].werte[21]:=(s[m].einheit[line2].werte[10]-10) div 2+1+(s[m].einheit[line2].werte[1]+
    s[m].einheit[line2].werte[7]+s[m].einheit[line2].werte[6]) div 5;
    s[m].einheit[line2].werte[22]:=(s[m].einheit[line2].werte[10]-10) div 2+1+(s[m].einheit[line2].werte[2]+
    s[m].einheit[line2].werte[4]+s[m].einheit[line2].werte[6]) div 5;
writeln('Attacke              :',s[m].einheit[line2].werte[21]);
writeln('Parade               :',s[m].einheit[line2].werte[22]);
{writeln('Kosten in Gold       :',s[m].costs/100:4:4);}
writeln('Kosten in Runden     :',s[m].rounds/10:4:4);
gotoxy(35,line);
write('<<<');
case readkey of
#72:if line>1 then dec(line);
#80:if line<21 then inc(line);
'+':case line of
1..7:if s[m].eigen[line]<20 then begin inc(s[m].costs,s[m].eigen[line]+1);inc(s[m].eigen[line]);inc(s[m].rounds
,s[m].einheit[line2].werte[line]);end;
8..9:if s[m].eigen[line]<100 then begin inc(s[m].costs,s[m].eigen[line]+5);inc(s[m].eigen[line],5);inc(s[m].rounds
,s[m].einheit[line2].werte[line] div 4);end;
10..20:if s[m].eigen[line]<28 then begin inc(s[m].costs,s[m].eigen[line]+1);inc(s[m].eigen[line]);inc(s[m].rounds
,s[m].einheit[line2].werte[line] div 2);end;
21:if s[m].prod<soldier then inc(s[m].prod);
end;
'-':case line of
1..7:if s[m].eigen[line]>0 then begin dec(s[m].costs,s[m].eigen[line]);dec(s[m].eigen[line]);dec(s[m].rounds);end;
8..9:if s[m].eigen[line]>0 then begin dec(s[m].costs,s[m].eigen[line]);dec(s[m].eigen[line],5);dec(s[m].rounds);end;
10..20:if s[m].eigen[line]>0 then begin dec(s[m].costs,s[m].eigen[line]);dec(s[m].eigen[line]);dec(s[m].rounds);end;
21:if s[m].prod>0 then dec(s[m].prod);
end;
#27:begin s[m].rounds:=s[m].rounds div 10;s[m].costs:=s[m].costs div 100;clrscr;screen;exit;end;
end;
until (a=#27);
clrscr;
screen;
end;
procedure aufw;
var o:word;d,b:boolean;
begin
hh:=false;
b:=false;
for o:=1 to max do if (s[m].haus[o].xx=x) and (s[m].haus[o].yy=y) and
(n[s[m].haus[o].art,s[m].haus[o].stufe+1][1]<>'-')
and (s[m].haus[o].stufe<6) and (s[m].wissen>=g(s[m].haus[o].stufe)*100) and (s[m].bauen>0) and (s[m].befehle>0) then begin
case s[m].haus[o].stufe+1 of
1:if (s[m].p[1]>1) and (s[m].p[2]>1) then begin dec(s[m].p[1],2);dec(s[m].p[2],2);b:=true;d:=true;end;
2:if (s[m].p[1]>2) and (s[m].p[2]>2) then begin dec(s[m].p[1],3);dec(s[m].p[2],3);b:=true;d:=true;end;
3:if (s[m].p[4]>1) and (s[m].p[1]>3) and (s[m].p[2]>3) then begin dec(s[m].p[1],4);dec(s[m].p[2],4);
dec(s[m].p[4],2);b:=true;d:=true;end;
4:if (s[m].p[9]>1) and (s[m].p[4]>3) and (s[m].p[1]>5) and (s[m].p[2]>5) then begin dec(s[m].p[9],2);dec(s[m].p[1],6);
dec(s[m].p[2],6);dec(s[m].p[4],4);b:=true;d:=true;end;
5:if (s[m].p[9]>4) and (s[m].p[4]>5) and (s[m].p[1]>7) and (s[m].p[2]>7) then begin dec(s[m].p[9],5);dec(s[m].p[1],8);
dec(s[m].p[2],8);dec(s[m].p[4],6);b:=true;d:=true;end;
6:if (s[m].p[9]>9) and (s[m].p[4]>9) and (s[m].p[1]>9) and (s[m].p[2]>9) then begin dec(s[m].p[9],10);
dec(s[m].p[1],10);dec(s[m].p[2],10);dec(s[m].p[4],10);b:=true;d:=true;end;
end;
if b then begin
hh:=false;
inc(s[m].haus[o].stufe);
dec(s[m].bauen);
dec(s[m].befehle);
dec(s[m].dorf,g(s[m].haus[o].stufe)-g(s[m].haus[o].stufe-1));b:=false;{screen};exit;
end else begin
hh:=false;
if (s[m].haus[o].xx<>x) or (s[m].haus[o].yy<>y) then begin hh:=true;s[m].fehler[11]:=true;end;
if (s[m].haus[o].stufe>=6) then begin hh:=true;s[m].fehler[12]:=true;end;
if (s[m].wissen<g(s[m].haus[o].stufe)*100) then begin hh:=true;s[m].fehler[8]:=true;end;
if s[m].bauen<=0 then begin hh:=true;s[m].fehler[9]:=true;end;
if s[m].befehle<=0 then begin hh:=true;s[m].fehler[10]:=true;end;
if d=false then begin hh:=true;s[m].fehler[6]:=true;end;
end;
end;
{screen;}
end;
procedure built(zahl,z2:word);
 var d,q,b:boolean;
begin
 if s[m].t then begin
  q:=false;
  i:=0;
  b:=false;
  repeat
   inc(i);
   if ((s[m].haus[i].xx+1=x) and (s[m].haus[i].yy+1=y)) or ((s[m].haus[i].xx+1=x) and
   (s[m].haus[i].yy=y)) or ((s[m].haus[i].xx+1=x) and (s[m].haus[i].yy-1=y))
   or ((s[m].haus[i].xx=x) and (s[m].haus[i].yy+1=y)) or ((s[m].haus[i].xx=x)
   and (s[m].haus[i].yy-1=y))
   or ((s[m].haus[i].xx-1=x) and (s[m].haus[i].yy+1=y)) or ((s[m].haus[i].xx-1=x)
   and (s[m].haus[i].yy=y)) or ((s[m].haus[i].xx-1=x)
   and (s[m].haus[i].yy-1=y)) and (i<>max) and (s[m].haus[i].art=24) then q:=false else q:=true;
  until ((s[m].haus[i].art=24) and (q=false)) or (i>=max);
  if (i>=max) or (s[m].haus[i].art<>24) then begin s[m].fehler[1]:=true;s[m].fehler[5]:=true;exit;end;
  for i:=1 to max do if (s[m].haus[i].xx=x) and (s[m].haus[i].yy=y) then
  begin s[m].fehler[1]:=true;s[m].fehler[22]:=true;exit;end;
 end;
 for i:=1 to max do begin
  b:=false;
  if (s[m].wissen>=g(z2)*100) and (s[m].haus[i].art=0) and  ((zahl=24) or
  (s[m].dorf-g(z2)>0)) then begin
   d:=false;
   if (s[m].p[11]>=kosten[z2].gold) and (s[m].p[1]>=kosten[z2].holz) and
   (s[m].p[2]>=kosten[z2].stein) and (s[m].p[19]>=kosten[z2].moertel) and
   (s[m].p[9]>=kosten[z2].stahl) and (s[m].p[4]>kosten[z2].ziegel) and
   (s[m].p[20]>kosten[z2].glas) then begin
   dec(s[m].p[11],kosten[z2].gold);dec(s[m].p[1],kosten[z2].holz);
   dec(s[m].p[2],kosten[z2].stein);dec(s[m].p[19],kosten[z2].moertel);
   dec(s[m].p[9],kosten[z2].stahl);dec(s[m].p[4],kosten[z2].ziegel);
   dec(s[m].p[20],kosten[z2].glas);
   s[m].haus[i].hunger:=0;s[m].haus[i].nahrung:=true;
   dec(s[m].dorf,g(z2));b:=true;d:=true;
    end;
{    1:if (s[m].p[1]>1) and (s[m].p[2]>1) then begin dec(s[m].p[1],2);dec(s[m].p[2],2);b:=true;d:=true;end;
    2:if (s[m].p[1]>2) and (s[m].p[2]>2) then begin dec(s[m].p[1],3);dec(s[m].p[2],3);b:=true;d:=true;end;
    3:if (s[m].p[4]>1) and (s[m].p[1]>3) and (s[m].p[2]>3) then
    begin dec(s[m].p[1],4);dec(s[m].p[2],4);dec(s[m].p[4],2);b:=true;d:=true;end;
    4:if (s[m].p[9]>1) and (s[m].p[4]>3) and (s[m].p[1]>5) and (s[m].p[2]>5) then begin dec(s[m].p[9],2);
    dec(s[m].p[1],6);dec(s[m].p[2],6);dec(s[m].p[4],4);b:=true;d:=true;end;
    5:if (s[m].p[9]>4) and (s[m].p[4]>5) and (s[m].p[1]>7) and (s[m].p[2]>7) then begin dec(s[m].p[9],5);
    dec(s[m].p[1],8);dec(s[m].p[2],8);dec(s[m].p[4],6);b:=true;d:=true;end;
    6:if (s[m].p[9]>9) and (s[m].p[4]>9) and (s[m].p[1]>9) and (s[m].p[2]>9) then begin dec(s[m].p[9],10);
    dec(s[m].p[1],10);dec(s[m].p[2],10);dec(s[m].p[4],10);b:=true;d:=true;end;
   end;                                                                       }
   if b then begin
   s[m].haus[i].stufe:=z2;s[m].haus[i].art:=zahl;
   s[m].haus[i].baurunden:=kosten[z2].runden;
   end;
   end;
  end;
  if b=false then begin
   s[m].fehler[1]:=true;
   if (s[m].wissen<g(z2)*100) then s[m].fehler[8]:=true;
   if s[m].bauen<=0 then s[m].fehler[9]:=true;
   if s[m].befehle<=0 then s[m].fehler[10]:=true;
   if (s[m].dorf-g(z2)<=0) then s[m].fehler[7]:=true;
   if d=false then s[m].fehler[6]:=true;
  end;
 end;
 {screen;}


procedure Versorgung;
 var mul,go,es,tr,ii:word;
begin
 for i:=1 to max do begin
  if (s[m].haus[i].art>0) and (s[m].haus[i].ak) and (s[m].haus[i].hunger>=40) then begin
   mul:=s[m].haus[i].stufe;
   {if haus[i].art=5 then inc(s[m].p[14],mul);
   if haus[i].art=8 then inc(s[m].p[11],mul);
   if haus[i].art=10 then inc(s[m].p[14],mul);
   if haus[i].art=11 then inc(s[m].p[15],mul);
   if haus[i].art=24 then begin inc(s[m].p[11],mul);inc(s[m].p[14],mul);inc(s[m].p[15],mul);end;}
{   if s[m].haus[i].art=24 then mul:=0;
   if s[m].haus[i].art=3 then mul:=mul*4;
   if s[m].haus[i].art=22 then mul:=mul*2;
   if s[m].haus[i].art=16 then mul:=mul*2;
   if s[m].haus[i].art=6 then mul:=mul*2;
   if s[m].haus[i].art=29 then mul:=mul*8;}
   if (s[m].p[14]>=reskosten[mul].nahrung) and (s[m].p[11]>=reskosten[mul].gold) and
   (s[m].p[15]>=reskosten[mul].nahrung) and (s[m].p[1]>=reskosten[mul].holz) and
   (s[m].p[2]>=reskosten[mul].stein) and (s[m].p[19]>=reskosten[mul].moertel) and
   (s[m].p[9]>=reskosten[mul].stahl) and (s[m].p[4]>reskosten[mul].ziegel) and
   (s[m].p[20]>reskosten[mul].glas) then begin
   dec(s[m].p[14],reskosten[mul].nahrung);dec(s[m].p[11],reskosten[mul].gold);
   dec(s[m].p[15],reskosten[mul].nahrung);dec(s[m].p[1],reskosten[mul].holz);
   dec(s[m].p[2],reskosten[mul].stein);dec(s[m].p[19],reskosten[mul].moertel);
   dec(s[m].p[9],reskosten[mul].stahl);dec(s[m].p[4],reskosten[mul].ziegel);
   dec(s[m].p[20],reskosten[mul].glas);
   s[m].haus[i].hunger:=0;s[m].haus[i].nahrung:=true;
   end else s[m].haus[i].nahrung:=false;
  end;
 end;
{ if (s[m].p[14]-s[m].p[12] div 2>=0) and (s[m].p[15]-s[m].p[12] div 2>=0) and (s[m].p[11]-s[m].p[12] div 2>=0) then begin
  dec(s[m].p[14],s[m].p[12] div 2);dec(s[m].p[15],s[m].p[12] div 2);dec(s[m].p[11],s[m].p[12] div 2);
 end else dec(s[m].p[12],s[m].p[12] div 10);}
 if (s[m].p[14]<50) or (s[m].p[15]<50) then s[m].fehler[19]:=true;
 if s[m].p[11]<50 then s[m].fehler[18]:=true;
 if s[m].dorf<50 then s[m].fehler[21]:=true;
 if (s[m].p[1]<20) or (s[m].p[2]<20) then s[m].fehler[20]:=true;
 for i:=1 to soldier do if s[m].einheit[i].da then if (s[m].p[15]>0) and (s[m].p[14]>0) and (s[m].p[11]>0) then begin
  dec(s[m].p[11]);dec(s[m].p[14]);dec(s[m].p[15]);
 end else s[m].einheit[i].da:=false;
end;
procedure fight2;
var map:array[1..32,1..20] of record sold,own:byte;end;
marks,marko,tx,ty,vx,vy,pr,ox,oy,xx,yy,xxx,yyy:word;
tab:array[1..8] of record
x,y:shortint;
end;
begin
tab[1].x:=1;tab[2].x:=0;tab[3].x:=-1;tab[4].x:=-1;tab[5].x:=-1;tab[6].x:=0;tab[7].x:=1;tab[8].x:=1;
tab[1].y:=-1;tab[2].y:=-1;tab[3].y:=-1;tab[4].y:=0;tab[5].y:=1;tab[6].y:=1;tab[7].y:=1;tab[8].y:=0;
{initvesa($101);}
asm mov ax,0;int $33;end;
for i:=1 to 32 do for j:=1 to 200 do mem[$a000:i*10+j*320]:=1;
for i:=1 to 320 do for j:=1 to 20 do mem[$a000:i+j*3200]:=1;
for i:=1 to 320 do for j:=1 to 200 do mem[$a000:i+j*320]:=0;
for i:=1 to 32 do for j:=1 to 20 do map[i,j].own:=0;
for i:=1 to soldier do for j:=0 to 1 do begin
s[j].einheit[i].x:=i mod 4+j*26+2;
s[j].einheit[i].y:=i mod 18+2;
if s[j].einheit[i].da then begin
map[s[j].einheit[i].x,s[j].einheit[i].y].sold:=i;
map[s[j].einheit[i].x,s[j].einheit[i].y].own:=j+1;end;
s[j].einheit[i].ax:=5;
s[j].einheit[i].ay:=i mod 18+1;
{s[j].einheit[i].phase:=0;
s[j].einheit[i].r:=0;                 }
end;
repeat
for i:=1 to 32 do for j:=1 to 20 do mem[$a000:i*10+j*3200]:=map[i,j].own;
for j:=0 to 1 do for i:=1 to soldier do with s[j].einheit[i] do if da then begin
if wait then wait:=false else begin
map[ax,ay].own:=0;
map[ax,ay].sold:=0;
tx:=ax;ty:=ay;
if (ax>cx) then dec(tx);
if (ax<cx) then inc(tx);
if (ay<cy) then inc(ty);
if (ay>cy) then dec(ty);
if map[tx,ty].sold=0 then begin ax:=tx;ay:=ty;end else
if map[ax+(tx-ax),ay].sold=0 then ax:=tx else
if map[ax,ay+(ty-ay)].sold=0 then ay:=ty else wait:=true;
map[ax,ay].sold:=i;
map[ax,ay].own:=j+1;
mem[$a000:ax*10+ay*3200]:=1;
mem[$a000:xx+yy*320]:=4;
end;
asm mov ax,3;int $33;mov xx,cx;mov yy,dx;end;
if xx>=320 then xx:=319;
if yy>=200 then yy:=199;
cx:=xx div 10;cy:=yy div 10;
end;
{asm mov ax,$3;int $33;mov pr,bx;mov xx,cx;mov yy,dx;end;
if xx>319 then xx:=319;
if yy>199 then yy:=199;
if xx<10 then xx:=10;
if yy<10 then yy:=10;
if (xx div 10*10<>ox) or (yy div 10*10<>oy) then begin
ox:=xx div 10*10;oy:=yy div 10*10;
for i:=1 to 32 do for j:=1 to 200 do mem[$a000:i*10+j*320]:=marks;
for i:=1 to 320 do for j:=1 to 20 do mem[$a000:i+j*3200]:=marko;
xxx:=xx div 10*10;yyy:=yy div 10*10;
for i:=0 to 10 do mem[$a000:xxx+i+yyy*320]:=4;
for i:=1 to 10 do mem[$a000:xxx+i+(yyy+10)*320]:=4;
for i:=1 to 10 do mem[$a000:xxx+(yyy+i)*320]:=4;
for i:=1 to 10 do mem[$a000:xxx+10+(yyy+i)*320]:=4;
for i:=1 to 32 do for j:=1 to 20 do mem[$a000:i*10+5+j*3200+5*320]:=map[i,j].own;
mem[$a000:s[marko].einheit[marks].x*10+5+s[marko].einheit[marks].y*3200+5*320]:=yellow;
end;
xxx:=xxx div 10;yyy:=yyy div 10;
if (pr=2) and (marks>0) then begin
pr:=0;
mem[$a000:11+11*320]:=random(255);
vx:=xxx;vy:=yyy;
i:=0;
while (map[vx,vy].own>0) and (i<9) do begin
inc(i);
vx:=xxx+tab[i].x;vy:=yyy+tab[i].y;
end;
s[marko].einheit[marks].ax:=vx;
s[marko].einheit[marks].ay:=vy;
end;
if (pr=1) and (map[xxx,yyy].sold>0) then begin
marks:=map[xxx,yyy].sold;marko:=map[xxx,yyy].own;
pr:=0;
end;
mem[$a000:s[marko].einheit[marks].x*10+5+s[marko].einheit[marks].y*3200+5*320]:=yellow;
for i:=1 to soldier do for j:=0 to 1 do begin
map[s[j].einheit[i].x,s[j].einheit[i].y].sold:=0;
map[s[j].einheit[i].x,s[j].einheit[i].y].own:=0;
if s[j].einheit[i].x>s[j].einheit[i].ax then dec(s[j].einheit[i].x);
if s[j].einheit[i].x<s[j].einheit[i].ax then inc(s[j].einheit[i].x);
if s[j].einheit[i].y>s[j].einheit[i].ay then dec(s[j].einheit[i].y);
if s[j].einheit[i].y<s[j].einheit[i].ay then inc(s[j].einheit[i].y);
map[s[j].einheit[i].x,s[j].einheit[i].y].sold:=i;
map[s[j].einheit[i].x,s[j].einheit[i].y].own:=j+1;
end;
delay(100);}
until keypressed;
textmode(3);
end;
procedure fight;
var kk,e1,e2:word;
map:array[1..32,1..20] of byte;
wisch,arg:boolean;
ll:longint;
tta,ttp:integer;
begin
clrscr;
writeln('Kampfmodus: Willst du mit deinen Kaempfern wirklich angreifen?');
if upcase(readkey)='J' then begin
le1:=1;le2:=1;e1:=1;e2:=1;
for i:=1 to soldier do if s[0].einheit[i].da then inc(e1);
for i:=1 to soldier do if s[1].einheit[i].da then inc(e2);
for i:=1 to soldier do if s[0].einheit[i].da then inc(le1,s[0].einheit[i].werte[8]);
for i:=1 to soldier do if s[1].einheit[i].da then inc(le2,s[1].einheit[i].werte[8]);
clrscr;
writeln('Player 1 Einheiten      : ',e1:5,'            Player 2 Einheiten      : ',e2:5);
writeln('Player 1 Lebensenergie  : ',le1:5,'            Player 2 Lebensenergie  : ',le2:5);
writeln('Player 1 Le pro Einheit : ',le1 div e1:5,'            Player 2 Le pro Einheit : ',le2 div e2:5);
readkey;
kk:=0;
for i:=1 to soldier do begin s[0].einheit[i].x:=random(310)+1;s[0].einheit[i].y:=i+50;

ll:=0;
repeat
inc(ll);
inc(kk);
if kk>soldier then kk:=1;
until s[1].einheit[kk].da or (ll>soldier*soldier);
if (ll<soldier*soldier) then s[0].einheit[i].f:=kk;end;
kk:=0;
for i:=1 to soldier do begin s[1].einheit[i].x:=random(310)+1;s[1].einheit[i].y:=i+50;

ll:=0;
repeat
inc(ll);
inc(kk);
if kk>soldier then kk:=1;
until s[0].einheit[kk].da or (ll>soldier*soldier);
s[1].einheit[i].f:=kk;end;
{initvesa($101);}
repeat
{wisch:=not wisch;}
for bb:=1 to 64000 do mem[$a000:bb]:=0;
kk:=0;
with s[0] do begin
for i:=1 to soldier do if einheit[i].da then begin
if (abs(einheit[i].x-s[1].einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich) and
(abs(einheit[i].y-s[1].einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich) then begin
if (einheit[i].x<s[1].einheit[einheit[i].f].x) and (einheit[i].y<s[1].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y+1*320]=0) then begin inc(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[1].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[1].einheit[einheit[i].f].x) and (einheit[i].y<s[1].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y+1*320]=0) then begin dec(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);;until s[1].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x<s[1].einheit[einheit[i].f].x) and (einheit[i].y>s[1].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y-1*320]=0) then begin inc(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);;until s[1].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[1].einheit[einheit[i].f].x) and (einheit[i].y>s[1].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y-1*320]=0) then begin dec(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);;until s[1].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
end;
if abs(einheit[i].x-s[1].einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].x<s[1].einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].x>s[1].einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
end;
if abs(einheit[i].y-s[1].einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].y<s[1].einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);
if (einheit[i].y>s[1].einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
end;
{if (einheit[i].x-s[1].einheit[einheit[i].f].x>waf[einheit[i].waf[1]].reich) and
(mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
if (-(einheit[i].x-s[1].einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].y-s[1].einheit[einheit[i].f].y>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
if (-(einheit[i].y-s[1].einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);}
mem[$a000:einheit[i].x+einheit[i].y*320]:=einheit[i].werte[8];
if (einheit[i].x+waf[einheit[i].waf[1]].reich>=s[1].einheit[einheit[i].f].x) and
(einheit[i].x-waf[einheit[i].waf[1]].reich<=s[1].einheit[einheit[i].f].x) and
(einheit[i].y+waf[einheit[i].waf[1]].reich>=s[1].einheit[einheit[i].f].y) and
(einheit[i].y-waf[einheit[i].waf[1]].reich<=s[1].einheit[einheit[i].f].y) then begin
if waf[einheit[i].waf[1]].wava-waf[s[1].einheit[einheit[i].f].waf[1]].wavp<0 then tta:=einheit[i].werte[21]+
waf[einheit[i].waf[1]].wava-waf[s[1].einheit[einheit[i].f].waf[1]].wavp else
if waf[einheit[i].waf[1]].wava-waf[s[1].einheit[einheit[i].f].waf[1]].wavp>0 then ttp:=s[1].einheit[einheit[i].f].werte[21]-
waf[einheit[i].waf[1]].wava+waf[s[1].einheit[einheit[i].f].waf[1]].wavp else begin tta:=einheit[i].werte[21];ttp:=
s[1].einheit[einheit[i].f].werte[22];END;
if random(20)+1<=tta then begin
if (einheit[i].waf[1]>21) or (random(20)+1>ttp) then
dec(s[1].einheit[einheit[i].f].werte[8],waf[einheit[i].waf[1]].tp*(random(6)+1)+waf[s[0].einheit[i].waf[1]].tp
-rus[s[1].einheit[einheit[i].f].rus[1]].rs);
if s[1].einheit[einheit[i].f].werte[8]<=0 then begin
s[1].einheit[einheit[i].f].da:=false;s[1].einheit[einheit[i].f].werte[8]:=0;
LL:=0;
repeat
inc(kk);
INC(LL);
if kk>soldier then kk:=1;
until s[1].einheit[kk].da OR (LL>SOLDIER*SOLDIER);
if (ll<soldier*soldier) then einheit[i].f:=kk;end;
end;
end;end;end;
kk:=0;
with s[1] do begin
for i:=1 to soldier do if einheit[i].da then begin
if (abs(einheit[i].x-s[0].einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich) and
(abs(einheit[i].y-s[0].einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich) then begin
if (einheit[i].x<s[0].einheit[einheit[i].f].x) and (einheit[i].y<s[0].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y+1*320]=0) then begin inc(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[0].einheit[einheit[i].f].x) and (einheit[i].y<s[0].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y+1*320]=0) then begin dec(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x<s[0].einheit[einheit[i].f].x) and (einheit[i].y>s[0].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y-1*320]=0) then begin inc(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[0].einheit[einheit[i].f].x) and (einheit[i].y>s[0].einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y-1*320]=0) then begin dec(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0].einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
end;
if abs(einheit[i].x-s[0].einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].x<s[0].einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].x>s[0].einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
end;
if abs(einheit[i].y-s[0].einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].y<s[0].einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);
if (einheit[i].y>s[0].einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
end;
{(mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
if (-(einheit[i].x-s[0].einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].y-s[0].einheit[einheit[i].f].y>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
if (-(einheit[i].y-s[0].einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);}
{if (einheit[i].x-s[0].einheit[einheit[i].f].x>waf[einheit[i].waf[1]].reich) and
(mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
if (-(einheit[i].x-s[0].einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].y-s[0].einheit[einheit[i].f].y>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
if (-(einheit[i].y-s[0].einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);}
mem[$a000:einheit[i].x+einheit[i].y*320]:=einheit[i].werte[8]+100;
if (einheit[i].x+waf[einheit[i].waf[1]].reich>=s[0].einheit[einheit[i].f].x) and
(einheit[i].x-waf[einheit[i].waf[1]].reich<=s[0].einheit[einheit[i].f].x) and
(einheit[i].y+waf[einheit[i].waf[1]].reich>=s[0].einheit[einheit[i].f].y) and
(einheit[i].y-waf[einheit[i].waf[1]].reich<=s[0].einheit[einheit[i].f].y) then begin
if waf[einheit[i].waf[1]].wava-waf[s[0].einheit[einheit[i].f].waf[1]].wavp<0 then tta:=einheit[i].werte[21]+
waf[einheit[i].waf[1]].wava-waf[s[0].einheit[einheit[i].f].waf[1]].wavp else
if waf[einheit[i].waf[1]].wava-waf[s[0].einheit[einheit[i].f].waf[1]].wavp>0 then ttp:=s[0].einheit[einheit[i].f].werte[21]-
waf[einheit[i].waf[1]].wava+waf[s[0].einheit[einheit[i].f].waf[1]].wavp else
begin tta:=einheit[i].werte[21];ttp:=s[0].einheit[einheit[i].f].werte[22];END;
if random(20)+1<=tta then begin
if (einheit[i].waf[1]>21) or (random(20)+1>ttp) then
dec(s[0].einheit[einheit[i].f].werte[8],waf[einheit[i].waf[1]].tp*(random(6)+1)+waf[s[1].einheit[i].waf[1]].tp
-rus[s[0].einheit[einheit[i].f].rus[1]].rs);
if s[0].einheit[einheit[i].f].werte[8]<=0 then begin
s[0].einheit[einheit[i].f].da:=false;s[0].einheit[einheit[i].f].werte[8]:=0;
ll:=0;
kk:=0;
repeat
inc(kk);
inc(ll);
if kk>soldier then kk:=1;
until s[0].einheit[kk].da or (ll>soldier*soldier);
s[1].einheit[i].f:=kk;end;
end;
end;end;end;
e1:=0;
e2:=0;
le1:=0;
le2:=0;
for i:=1 to soldier do if s[0].einheit[i].da then inc(e1);
for i:=1 to soldier do if s[1].einheit[i].da then inc(e2);
for i:=1 to soldier do if s[0].einheit[i].da then inc(le1,s[0].einheit[i].werte[8]);
for i:=1 to soldier do if s[1].einheit[i].da then inc(le2,s[1].einheit[i].werte[8]);
{for i:=1 to soldier do if s[0].einheit[i].da then mem[$a000:s[0].einheit[i].x+s[0].einheit[i].y*320]:=s[0].einheit[i].
werte[8]+1;
for i:=1 to soldier do if s[1].einheit[i].da then mem[$a000:s[1].einheit[i].x+s[1].einheit[i].y*320]:=s[1].einheit[i].
werte[8]+1;}
until (le1<=0) or (le2<=0) or keypressed;
readkey;
textmode(3);
if (le1<=5) and (m=1) then loose1:=true else loose1:=false;
if (le2<=5) and (m=0) then loose2:=true else loose2:=false;
clrscr;
end;
end;
procedure produziere;
var bon,mul,ii:word;hep:boolean;
begin
s[m].MAXE:=2500;
s[m].maxl:=2500;
s[m].unruhe:=s[m].steu;
 for i:=1 to max do begin
   if (s[m].haus[i].art>0) and (s[m].haus[i].ak=true) and (s[m].haus[i].nahrung=true) then begin
    mul:=kosten[s[m].haus[i].stufe].prodfak*2;
    bon:=kosten[s[m].haus[i].stufe].prodbon*2;
    case s[m].haus[i].art of
     1:inc(s[m].p[1],mul+bon);
     2:inc(s[m].p[2],mul+bon);
     3:inc(s[m].wissen,mul+bon);
     4:if s[m].p[3]>0 then begin dec(s[m].p[3],mul);inc(s[m].p[4],mul+bon);end;
     5:begin inc(s[m].p[6],mul+bon);inc(s[m].p[14],mul+bon);end;
     6:begin inc(s[m].p[3],mul+bon);inc(s[m].p[7],mul+bon);inc(s[m].p[8],mul+bon);inc(s[m].p[10],mul+bon);end;
     7:if (s[m].p[7]>mul) and (s[m].p[8]>mul) then begin dec(s[m].p[7],mul);dec(s[m].p[8],mul);inc(s[m].p[9],mul+bon);end;
     8:if (s[m].p[7]>mul) and (s[m].p[10]>mul) then begin dec(s[m].p[7],mul);dec(s[m].p[10],mul);inc(s[m].p[11],mul+bon);end;
     10:inc(s[m].p[14],10*(mul+bon));
    11:inc(s[m].p[15],10*(mul+bon));
    12:if (s[m].p[9]>mul) and (s[m].p[7]>mul) then begin dec(s[m].p[7],mul);dec(s[m].p[9],mul);for i:=1 to wanzahl do
    if s[m].waffen[i].prod>0 then begin
    dec(s[m].waffen[i].prod);inc(s[m].waffen[i].stuck);
    end;end;
    13:if (s[m].p[9]>mul) and (s[m].p[7]>mul) then begin dec(s[m].p[7],mul);dec(s[m].p[9],mul);for i:=1 to ranzahl do
    if s[m].ruestungen[i].prod>0 then begin
    dec(s[m].ruestungen[i].prod);inc(s[m].ruestungen[i].stuck);
    end;end;
    14:inc(s[m].maxe,mul*2500);
{??}15:if s[m].prod>0 then begin
       inc(s[m].ro,mul);if (s[m].ro>=s[m].rounds) and (s[m].dorf>10) {and (s[m].p[11]>s[m].costs)} then begin s[m].ro:=0;
       dec(s[m].p[11],mul);dec(s[m].dorf,mul);
       hep:=false;
       for i:=1 to soldier do begin hep:=false;if s[m].einheit[i].da=false then begin
       hep:=true;dec(s[m].prod);s[m].einheit[i].da:=true;for j:=1 to 25 do s[m].einheit[i].werte[j]:=s[m].eigen[j];end;
       if hep then begin i:=soldier;break;end;end;end;end;
    16:s[m].bauen:=(mul+bon) div 4;
{    21:s[m].befehle:=mul;}
    28:inc(s[m].maxl,mul*2500);
    29:if s[m].unruhe>=mul then dec(s[m].unruhe,mul) else s[m].unruhe:=0;
    end;
   end;
  end;
screen;
end;
procedure showb;
var mmm,te,ykky,xkkx,posx,posy,mp,phase,nx,ny,kx,ky,mn,kxx:word;mm:string;
npaint:boolean;
begin
fa:=true;
initvesa($101);
loadgif('grass6.gif');
for kxx:=1 to max do begin
mn:=artzusprite(s[m].haus[kxx].art);
if (mn>0) and (mn<29) then begin
end;
end;
kx:=5;ky:=5;
{wx:=560;}
{page:=48000;}
for kx:=1 to kmx do for ky:=1 to kmy do karte[kx,ky].art:=random(2);
for kx:=1 to kmx do for ky:=1 to kmy do begin
mmm:=0;
mmm:=karte[kx,ky+1].art+karte[kx,ky-1].art+karte[kx+1,ky+1].art+karte[kx+1,ky-1].art+karte[kx-1,ky+1].art+
karte[kx-1,ky-1].art+karte[kx+1,ky].art+karte[kx-1,ky].art;
if mmm>5 then karte[kx,ky].bon:=random(16) else if mmm<4 then karte[kx,ky].bon:=17 else begin if karte[kx,ky].art=0 then
karte[kx,ky].bon:=17 else karte[kx,ky].bon:=random(16);end;
end;
for kx:=1 to kmx do for ky:=1 to kmy do karte[kx,ky].art:=karte[kx,ky].bon;
for kx:=1 to kmx do for ky:=1 to kmy do begin
if karte[kx,ky].art>15 then begin
te:=16;
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx+1,ky].art<te) and (karte[kx,ky+1].art<te)) then
karte[kx,ky].art:=te+18 else
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+4 else
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx,ky+1].art<te)) then karte[kx,ky].art:=te+5 else
if ((karte[kx,ky+1].art<te) and (karte[kx-1,ky].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+6 else
if ((karte[kx+1,ky].art<te) and (karte[kx,ky-1].art<te) and (karte[kx,ky+1].art<te)) then karte[kx,ky].art:=te+7 else
if ((karte[kx+1,ky].art<te) and (karte[kx-1,ky].art<te)) then karte[kx,ky].art:=te+8 else
if ((karte[kx,ky+1].art<te) and (karte[kx,ky-1].art<te)) then karte[kx,ky].art:=te+9 else
if ((karte[kx,ky-1].art<te) and (karte[kx-1,ky].art<te)) then karte[kx,ky].art:=te+10 else
if ((karte[kx,ky+1].art<te) and (karte[kx-1,ky].art<te)) then karte[kx,ky].art:=te+11 else
if ((karte[kx,ky+1].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+12 else
if ((karte[kx,ky-1].art<te) and (karte[kx+1,ky].art<te)) then karte[kx,ky].art:=te+13 else
if (karte[kx-1,ky].art<te) then karte[kx,ky].art:=te+14 else
if (karte[kx+1,ky].art<te) then karte[kx,ky].art:=te+15 else
if (karte[kx,ky-1].art<te) then karte[kx,ky].art:=te+16 else
if (karte[kx,ky+1].art<te) then karte[kx,ky].art:=te+17 else
karte[kx,ky].art:=random(4)+16;
end;
end;
posx:=0;posy:=0;
npaint:=true;
kx:=5;ky:=5;
repeat
if npaint then begin for ykky:=0 to 20 do for xkkx:=0 to 20 do begin
putsprite(xkkx*20,ykky*20,gel[karte[xkkx+1+posx,ykky+1+posy].art]);
npaint:=false;
end;end;
asm mov ax,3;int $33;mov x,cx;mov y,dx;mov mp,bx;end;
if kx>639 then kx:=639;if ky>479 then ky:=479;
inc(phase);if phase>39 then phase:=0;
{case a of
#75:if ax>1 then dec(ax) else ax:=1;
#77:if ax<31 then inc(ax) else ax:=31;
#72:if ay>1 then dec(ay) else ay:=1;
#80:if ay<19 then inc(ay) else ay:=19;
end;}
{waitretrace;
setstart(seite);
if seite=0 then seite:=16000 else seite:=0;}
for i:=1 to 12 do begin
putsprite(540,i*20,roh[i]);{wy:=i*20+6;}str(s[m].p[i]*10,mm);writes(mm);
end;
putsprite(540,360,spr[artzusprite(s[m].ch)]);
for kxx:=1 to max do begin
mn:=artzusprite(s[m].haus[kxx].art);
if (mn>0) and (mn<29) then begin
putsprite(s[m].haus[kxx].xx*20,s[m].haus[kxx].yy*20,spr[mn-1]);
putsprite(s[m].haus[kxx].xx*20+6,s[m].haus[kxx].yy*20+5,qua[s[m].haus[kxx].stufe-1]);
end;
end;
putsprite(x,y,zus[3]);
if x<5 then if posx>0 then begin npaint:=true;dec(posx);end;
if y<5 then if posy>0 then begin npaint:=true;dec(posy);end;
if x>635 then if posx<kmx-26 then begin npaint:=true;inc(posx);end;
if y>475 then if posy<kmy-21 then begin npaint:=true;inc(posy);end;
x:=round(x/20);
y:=round(y/20);
if y>45 then y:=45;
if x>50 then x:=50;
putsprite(x*20,y*20,zus[phase mod 8 div 2+4]);
if keypressed then begin
a:=readkey;
case a of
'a':if s[m].ch<hauser then inc(s[m].ch) else s[m].ch:=1;
'y':if s[m].ch>1 then dec(s[m].ch) else s[m].ch:=hauser;
    '+':if s[m].steuern<100 then inc(s[m].steuern);
    '-':if s[m].steuern>0 then dec(s[m].steuern);
    's':if s[m].steu<100 then inc(s[m].steu);
    'x':if s[m].steu>0 then dec(s[m].steu);
    #32:built(s[m].ch,r(s[m].ch));
    #13:aufw;
#75:begin npaint:=true;if posx>0 then dec(posx);end;
#77:begin npaint:=true;if posx<kmx-26 then inc(posx);end;
#72:begin npaint:=true;if posy>0 then dec(posy);end;
#80:begin npaint:=true;if posy<kmy-21 then inc(posy);end;
end;end;
{showscreen;}
until keypressed;
textmode(3);
fa:=false;
end;
begin
  chdir('d:\wars');
  clrscr;
  Randomize;
{assign(f,'werte.dat');
reset(f);
for i:=1 to 71 do readln(f,a);
for j:=1 to 10 do begin
{readln(f,rassen[j].name);}
{for i:=1 to 68 do begin
readln(f,name);
writeln(i,'   ',name);
val(name,rassen[j].werte[i],sizei);
if sizei<>0 then begin writeln('Error ',sizei);readkey;halt;end;
end;
end;
close(f);}
assign(f,'builtdat.dat');
reset(f);
for i:=1 to hauser do begin readln(f,n[i,1]);readln(f,n[i,2]);readln(f,n[i,3]);readln(f,n[i,4]);readln(f,n[i,5]);
readln(f,n[i,6]);end;
close(f);
assign(f,'help.dat');
reset(f);
for i:=1 to 25 do readln(f,help[i]);
close(F);
assign(f,'waffrues.dat');
reset(f);
close(f);
{readln(f,wanzahl);
readln(f,ranzahl);
for i:=1 to wanzahl do begin
readln(f,waf[i].s);
readln(f,waf[i].art);
readln(f,waf[i].tp);
readln(f,waf[i].boni);
readln(f,waf[i].reich);
readln(f,waf[i].wava);
readln(f,waf[i].wavp);
end;
for i:=1 to ranzahl do begin
readln(f,rus[i].s);
readln(f,rus[i].art);
readln(f,rus[i].rs);
end;
close(F);}
{assign(f,'rassen.dat');
reset(f);
for i:=1 to 8 do for j:=1 to 21 do readln(f,rassen[i][j]);}
for i:=1 to 25 do s[m].fehler[i]:=false;
{if paramcount>0 then begin
assign(fil,paramstr(1));
reset(fil,1);
blockread(fil,s,sizeof(s));
close(fil);
end else }
for m:=0 to 1 do begin
s[m].esse:=1;
s[m].ch:=2;s[m].dorf:=250;
for i:=1 to hauser do s[m].vor[i,1]:=true;
for i:=1 to soldier do for j:=1 to 25 do s[m].einheit[i].werte[j]:=0;
for i:=1 to hauser do for j:=1 to 5 do if (n[i,j][1]='-') and (n[i,j+1]<>'-') then
begin s[m].vor[i,j+1]:=true;s[m].vor[i,j]:=false;end;
 for i:=1 to 25 do s[m].p[i]:=2500;
{ s[m].p[12]:=0;}
 for i:=1 to max do begin s[m].haus[i].ak:=false;s[m].haus[i].nahrung:=false;s[m].haus[i].art:=0;s[m].haus[i].stufe:=0;end;
 x:=14;
 y:=14;
 s[m].weapon:=1;
 s[m].akwa:=1;
 s[m].akru:=1;
 s[m].rustung:=1;
 s[m].befehle:=10;
 s[m].bauen:=10;
 s[m].wissen:=1001;
 s[m].t:=false;
 built(16,3);
 y:=15;x:=15;
 built(21,4);
 y:=13;x:=14;
 built(24,1);
 y:=15;x:=14;
 built(24,1);
 y:=5;x:=4;
 built(15,3);
 y:=14;x:=13;
 built(24,1);
 y:=14;x:=15;
 built(24,1);
 s[m].t:=true;
 s[m].wissen:=101;
main:=true;
for i:=1 to soldier do begin s[0].einheit[i].da:=false;for j:=1 to 4 do begin s[0].einheit[i].waf[j]:=1;
s[0].einheit[i].rus[j]:=1;end;end;
for i:=1 to soldier do begin s[1].einheit[i].da:=false;for j:=1 to 4 do begin s[1].einheit[i].waf[j]:=1;
s[1].einheit[i].rus[j]:=1;end;end;
for i:=1 to soldier do begin s[1].einheit[i].da:=true;s[1].einheit[i].werte[8]:=40;s[1].einheit[i].werte[21]:=4;
s[1].einheit[i].waf[1]:=1;s[1].einheit[i].rus[2]:=1;s[1].einheit[i].werte[22]:=12;end;
for i:=1 to soldier do begin s[0].einheit[i].da:=true;s[0].einheit[i].werte[8]:=40;s[0].einheit[i].werte[21]:=4;
s[0].einheit[i].waf[1]:=1;s[0].einheit[i].rus[1]:=1;s[0].einheit[i].werte[22]:=12;end;
{for i:=1 to 15 do begin s[m].waffen[i].stuck:=4;s[m].ruestungen[i].stuck:=4;end;      }
end;
m:=0;
x:=14;
y:=14;
line2:=3;
fa:=false;
clrscr;
writeln('WARS! Version 0.00019 W. Give it to all your friends...');
writeln('Verfuegbarer konventioneller Speicher : ',maxavail);
writeln('Moege die Soundkarte SB kombatibel sein und an INT 5 DMA 1 angeschlossen sein');
initsb;
writeln('Im Intro auf ENDE gehen (Pfeiltasten) und dann im Textspiel ''b'' druecken.');
writeln('Abbruch des Grafikmodus mit Taste...');
writeln('Daten initialisiert ... Taste (NICHT ''anykey'' !!!)');
blockgr:=bkgr;
getmem(temp,blockgr);
getmem(tempbuf,$1FFF-ofs(temp^));
getmem(blk1,blockgr);
getmem(blk2,blockgr);
freemem(tempbuf,$FFFF-ofs(temp^));
freemem(temp,blockgr);
writeln('Block 1:',seg(blk1^),':',ofs(blk1^),'   Block 2:',seg(blk2^),':',ofs(blk2^));
readkey;
  screen_off;
  init_mode13;
{  loadone('rost5.gif',7,20);}
  loadgif('rost.gif');
  for i:=0 to mh-1 do getsprite(i*10+10*320,10,10,spr[i]);
  for i:=0 to 5 do getsprite(i*4+30*320,4,5,qua[i]);
  for i:=1 to 15 do getsprite(i*10-10,10,10,roh[i]);
  for i:=0 to 12 do getsprite(i*10+20*320,10,10,zus[i]);
  for i:=0 to 10 do getsprite(i*10+40*320,10,10,gel[i]);
  for i:=13 to 17 do getsprite((i-13)*10+50*320,10,10,zus[i]);
  for i:=11 to 40 do getsprite((i-11)*10+60*320,10,10,gel[i]);
  loadgif('rost5.gif');
  show_pic13;
  for i:=1 to 15 do getsprite(i*20-20,20,20,roh[i]);
  loadgif('grass6.gif');
  show_pic13;
   for i:=0 to 25 do getsprite(i*20+17*320,20,20,gel[i+20]);
  for i:=0 to 25 do getsprite(i*20+17*320,20,20,gel[i+20]);
for i:=0 to 25 do getsprite(i*20+17*320,20,20,gel[i+20]);
getsprite(178*320,20,20,zus[3]);
getsprite(180*320+20,20,20,zus[4]);
getsprite(180*320+40,20,20,zus[5]);
getsprite(180*320+60,20,20,zus[6]);
getsprite(180*320+80,20,20,zus[7]);
for i:=0 to 3 do getsprite(i*20+97*320,20,20,gel[i]);
for i:=0 to 3 do getsprite(i*20+117*320,20,20,gel[i+4]);
for i:=0 to 3 do getsprite(i*20+137*320,20,20,gel[i+8]);
for i:=0 to 3 do getsprite(i*20+157*320,20,20,gel[i+12]);
for i:=0 to 3 do getsprite(i*20+77*320,20,20,gel[i+16]);
  GetMem(Src_Frame,320*100);    {Speicher fÅr Quellbild holen und lîschen}
  FillChar(Src_Frame^,320*100,0);
  GetMem(Dest_Frame,320*100);   {Speicher fÅr Ziellbild holen und lîschen}
  FillChar(Dest_Frame^,320*100,0);
  Prep_Pal;                     {Palette vorbereiten}
  getpal;
{  move(zielpal,palette,768);
  fillchar(palette1,768,0);}
  size:=160;
  sizei:=0;
frequenz:=22050;
block2:=true;
chdir('d:\wars\sound');
name:='5001.raw';
assign(h,name);
reset(h,1);
repeatet:=false;
{getmem(temp,blockgr);
getmem(tempbuf,$1FFF-ofs(temp));
getmem(blk1,blockgr);
getmem(blk2,blockgr);
freemem(tempbuf,$FFFF-ofs(temp));
freemem(temp,blockgr);}
blockread(h,blk1^,blockgr);
blockread(h,blk2^,blockgr);
oldexit:=exitproc;
exitproc:=@programexit;
main:=false;initdma(blk1,blockgr);
read1:=false;
read2:=false;
gross:=filesize(h);
last:=false;
last2:=false;
i:=60;
rnd:=0;
stark:=0;
main:=true;
fillchar(mem[$a000:0],64000,0);
screen_on;
wait:=0;
Repeat
if main then inc(i);
if i=100 then begin rnd:=5;stark:=5;loadgif('claw');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=300 then begin rnd:=10;stark:=15;loadgif('present');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=500 then begin rnd:=35;stark:=30;sizei:=1;loadgif('wars');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=700 then begin main:=false;i:=801;loadgif('opa3');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=800 then begin i:=801;loadgif('opnew2');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=900 then begin i:=901;loadgif('opopo');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if i=1000 then begin i:=1001;loadgif('opend2');Move(Vscreen^,Ptr($a000,0)^,32000);end;
if keypressed and (main=true) then if readkey='q' then i:=2000;
    if keypressed and (main=false) then begin
    case readkey of
    #80:if i<1000 then inc(i,99) else i:=800;
    #72:if i>801 then dec(i,101) else i:=1000;
    #27:i:=2000;
    #13:if i=1001 then i:=2000;
    end;
    end;
    Scroll_Up;                  {Flammen nach oben}
    Show_Screen;                {fertigen Bildschirm zeigen}
    New_Line;                   {unten neue Linie anfÅgen}
if (wait=0) and (read1=true) and (last=false) then begin
read1:=false;blockread(h,blk1^,blockgr);dec(gross,blockgr);
end;
if (wait=0) and (read2=true) and (last=false) then begin
read2:=false;blockread(h,blk2^,blockgr);dec(gross,blockgr);
end;
Until i=2000;
TextMode(3);
textcolor(2);textbackground(0);
programexit;
{assign(h,'loops.sam');
reset(h,1);
frequenz:=12050;
block2:=true;
read1:=false;
read2:=false;
repeatet:=true;
last:=false;
last2:=false;
{writeln('Nach Initialisierung sind noch ',maxavail,' Bytes uebrig!');
blockread(h,blk1^,blockgr);
blockread(h,blk2^,blockgr);
gross:=filesize(h);
initdma(blk1,blockgr);
{   assign(h,paramstr(1));
   reset(h,1);
   gross:=filesize(h);
   if gross>65500 then gross:=65500;
   i:=1
  getmem(blk[i],gross);
  bufinfo[i].start:=blk[i];
  blockread(h,blk[i]^,gross);
  samples[i].adresse:=blk[i];
  samples[i].laenge:=gross;
  playinfo[i].fertig:=false;
  samples[i].loop:=true;
  playinfo[i].nummer:=i;
  close(h);
  poss:=0;
  block2:=true;
  main:=true;
  mische;
  mische;}
screen;
{initsb;
initdma(blk1,bkgr);}
 repeat
  fa:=false;
  a:=#0;
  s[m].z:=0;
    screen;
  produziere;
  baueweiter;
  inc(zeit);if zeit>=40 then begin zeit:=0;versorgung;end;
    inc(s[m].p[11],round((s[m].dorf/2500)*s[m].steuern*s[m].steu));
    inc(s[m].p[14],round((s[m].dorf/2500)*(100-s[m].steuern)*s[m].steu));
    inc(s[m].p[15],round((s[m].dorf/2500)*(100-s[m].steuern)*s[m].steu));
    s[m].temp:=s[m].unruhe*s[m].dorf div 25;
    s[m].dorf:=s[m].dorf-s[m].temp;
    inc(s[m].dorf,s[m].dorf div 10-(s[m].dorf+s[m].temp) div 150);
    s[m].dorf:=s[m].dorf+s[m].temp;
    for k:=1 to 13 do if s[m].p[k]>s[m].maxl then s[m].p[k]:=s[m].maxl;
    for k:=16 to 25 do if s[m].p[k]>s[m].maxl then s[m].p[k]:=s[m].maxl;
    if s[m].p[14]>s[m].maxe then s[m].p[14]:=s[m].maxe;
    if s[m].p[15]>s[m].maxe then s[m].p[15]:=s[m].maxe;
  repeat
   if keypressed then begin
    for i:=1 to 25 do s[m].fehler[i]:=false;
    a:=readkey;
    case a of
    'a':if s[m].ch<hauser then inc(s[m].ch) else s[m].ch:=1;
    'z':if s[m].ch>1 then dec(s[m].ch) else s[m].ch:=hauser;
    #72:if y>1 then dec(y);
    #80:if y<20 then inc(y);
    #75:if x>1 then dec(x);
    #77:if x<25 then inc(x);
    #83:begin for l:=1 to max do if (s[m].haus[l].xx=x) and
    (s[m].haus[l].yy=y) and (s[m].bauen>0) and (s[m].befehle>0) then begin
        dec(s[m].befehle);s[m].haus[l].art:=0;s[m].haus[l].stufe:=0;s[m].haus[l].xx:=0;
        s[m].haus[l].yy:=0;s[m].haus[l].nahrung:=false;
        inc(s[m].p[1],1);inc(s[m].p[2],1);end;end;
    'e':begin
    clrscr;
    repeat
    clrscr;
    window(1,1,80,25);
    writeln('Nummer            :',line2);
    writeln('Name              :',s[m].einheit[line2].name);
    writeln('Ruestung A        :',rus[s[m].einheit[line2].rus[1]].s);
    writeln('Ruestung B        :',rus[s[m].einheit[line2].rus[2]].s);
    writeln('Ruestung C        :',rus[s[m].einheit[line2].rus[3]].s);
    writeln('Ruestung D        :',rus[s[m].einheit[line2].rus[4]].s);
    writeln('Waffe A           :',waf[s[m].einheit[line2].waf[1]].s);
    writeln('Waffe B           :',waf[s[m].einheit[line2].waf[2]].s);
    writeln('Waffe C           :',waf[s[m].einheit[line2].waf[3]].s);
    writeln('Waffe D           :',waf[s[m].einheit[line2].waf[4]].s);
    writeln('Aktuelle Waffe    :',waf[s[m].akwa].s:17,':',s[m].waffen[s[m].akwa].stuck);
    writeln('Aktuelle Ruestung :',rus[s[m].akru].s:17,':',s[m].ruestungen[s[m].akru].stuck);
    window(41,1,80,25);
    writeln('Mut               :',s[m].einheit[line2].werte[1]);
    writeln('Klugheit          :',s[m].einheit[line2].werte[2]);
    writeln('Charisma          :',s[m].einheit[line2].werte[3]);
    writeln('Intuition         :',s[m].einheit[line2].werte[4]);
    writeln('Fingerfertigkeit  :',s[m].einheit[line2].werte[5]);
    writeln('Gewandtheit       :',s[m].einheit[line2].werte[6]);
    writeln('Koerperkraft      :',s[m].einheit[line2].werte[7]);
    writeln('Lebensenergie     :',s[m].einheit[line2].werte[8]);
    writeln('Astralenergie     :',s[m].einheit[line2].werte[9]);
    writeln('Waffenlos         :',s[m].einheit[line2].werte[10]);
    writeln('Speere, Staebe    :',s[m].einheit[line2].werte[11]);
    writeln('Stichwaffen       :',s[m].einheit[line2].werte[12]);
    writeln('Aexte, Beile      :',s[m].einheit[line2].werte[13]);
    writeln('stumpfe Hiebwaffen:',s[m].einheit[line2].werte[14]);
    writeln('scharfe Hiebwaffen:',s[m].einheit[line2].werte[15]);
    writeln('Schwerter         :',s[m].einheit[line2].werte[16]);
    writeln('Zweihaender       :',s[m].einheit[line2].werte[17]);
    writeln('Infanteriewaffen  :',s[m].einheit[line2].werte[18]);
    writeln('Wurfwaffen        :',s[m].einheit[line2].werte[19]);
    writeln('Schusswaffen      :',s[m].einheit[line2].werte[20]);
s[m].einheit[line2].werte[21]:=(s[m].einheit[line2].werte[waf[s[m].einheit[line2].waf[1]].art+9]-10) div 2+
1+(s[m].einheit[line2].werte[1]+
s[m].einheit[line2].werte[7]+s[m].einheit[line2].werte[6]) div 5;
s[m].einheit[line2].werte[22]:=(s[m].einheit[line2].werte[waf[s[m].einheit[line2].waf[1]].art+9]-10) div 2+
1+(s[m].einheit[line2].werte[2]+
s[m].einheit[line2].werte[4]+s[m].einheit[line2].werte[6]) div 5;
    writeln('Attacke              :',s[m].einheit[line2].werte[21]);
    writeln('Parade               :',s[m].einheit[line2].werte[22]);
    window(1,1,80,25);
    gotoxy(39,line3+1);write('<');
    case readkey of
    '+':begin if line2>=soldier then line2:=1 else inc(line2);s[m].akwa:=1;s[m].akru:=1;end;
    '-':begin if line2<=1 then line2:=soldier else dec(line2);s[m].akwa:=1;s[m].akru:=1;end;
    'a':if s[m].akwa>=wanzahl then s[m].akwa:=1 else inc(s[m].akwa);
    'z':if s[m].akru>=ranzahl then s[m].akru:=1 else inc(s[m].akru);
    #72:if line3>1 then dec(line3);
    #80:if line3<9 then inc(line3);
    #13:if line3=1 then begin
    gotoxy(23,2);readln(s[m].einheit[line2].name);
    end else if (line3>1) and (line3<6) then begin
    if s[m].akru<>1 then begin
    if rus[s[m].akru].art=line3-1 then begin
    if s[m].ruestungen[s[m].akru].stuck>0 then begin
    dec(s[m].ruestungen[s[m].akru].stuck);inc(s[m].ruestungen[s[m].einheit[line2].rus[line3-1]].stuck);
    s[m].einheit[line2].rus[line3-1]:=s[m].akru;end;end;end else begin
    if s[m].einheit[line2].rus[line3-1]<>1 then inc(s[m].ruestungen[s[m].einheit[line2].rus[line3-1]].stuck);
    s[m].einheit[line2].rus[line3-1]:=s[m].akru;end;end
    else if (line3>5) then begin
    if s[m].akwa<>1 then begin
    if s[m].waffen[s[m].akwa].stuck>0 then begin
    dec(s[m].waffen[s[m].akwa].stuck);inc(s[m].waffen[s[m].einheit[line2].waf[line3-5]].stuck);
    s[m].einheit[line2].waf[line3-5]:=s[m].akwa;end;end else begin
    if s[m].einheit[line2].waf[line3-5]<>1 then inc(s[m].waffen[s[m].einheit[line2].waf[line3-5]].stuck);
    s[m].einheit[line2].waf[line3-5]:=s[m].akwa;end;end;
    #27:a:=#27;
    end;
    until a=#27;
    clrscr;
    a:=#255;
    END;
    #73:begin feld:=true;main:=false;end;
    #81:begin feld:=false;main:=true;end;
    #27:halt;
    '+':if s[m].steuern<100 then inc(s[m].steuern);
    '-':if s[m].steuern>0 then dec(s[m].steuern);
    's':if s[m].steu<100 then inc(s[m].steu);
    'x':if s[m].steu>0 then dec(s[m].steu);
    'g':gener;
    #32:built(s[m].ch,r(s[m].ch));
    #9:for l:=1 to max do if (s[m].haus[l].xx=x) and (s[m].haus[l].yy=y) and (s[m].befehle>0) then
    begin dec(s[m].befehle);s[m].haus[l].ak:=not s[m].haus[l].ak;end;
    #59:if m=0 then begin
    write('Speichern unter :');readln(name);assign(fil,name);rewrite(fil,1);blockwrite(fil,s,sizeof(s));close(fil);clrscr;end;
{    #68:menu;}
    'm':if s[m].waffen[s[m].weapon].prod<20 then inc(s[m].waffen[s[m].weapon].prod) else s[m].waffen[s[m].weapon].prod:=0;
    'n':if s[m].ruestungen[s[m].rustung].prod<20 then inc(s[m].ruestungen[s[m].rustung].prod) else
    s[m].ruestungen[s[m].rustung].prod:=0;
    'W':if s[m].weapon<wanzahl then inc(s[m].weapon) else s[m].weapon:=0;
    'R':if s[m].Rustung<ranzahl then inc(s[m].rustung) else s[m].rustung:=0;
    #13:aufw;
    'f':FIGHT2;
    'b':showb;
    'w':begin
    if m=0 then m:=1 else m:=0;
    for i:=1 to 25 do s[m].fehler[i]:=false;
    inc(s[m].p[11],round((s[m].dorf/2500)*s[m].steuern*s[m].steu));
    inc(s[m].p[14],round((s[m].dorf/2500)*(100-s[m].steuern)*s[m].steu));
    inc(s[m].p[15],round((s[m].dorf/2500)*(100-s[m].steuern)*s[m].steu));
    s[m].bauen:=0;
    s[m].befehle:=1;
    {if esse=0 then dec(dorf,dorf div 100) else inc(dorf,dorf div 100+esse);}
    produziere;versorgung;
    s[m].temp:=s[m].unruhe*s[m].dorf div 25;
    s[m].dorf:=s[m].dorf-s[m].temp;
    inc(s[m].dorf,s[m].dorf div 100-(s[m].dorf+s[m].temp) div 150);
    s[m].dorf:=s[m].dorf+s[m].temp;
    for k:=1 to 13 do if s[m].p[k]>s[m].maxl then s[m].p[k]:=s[m].maxl;
    for k:=16 to 25 do if s[m].p[k]>s[m].maxl then s[m].p[k]:=s[m].maxl;
    if s[m].p[14]>s[m].maxe then s[m].p[14]:=s[m].maxe;
    if s[m].p[15]>s[m].maxe then s[m].p[15]:=s[m].maxe;
    screen;
    gotoxy(1,1);
    writeln('Get Ready, Player ',m+1);
    for i:=1 to 25 do s[m].fehler[i]:=false;
    if loose2 then begin
    writeln('Congratulations Player 1!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');readkey;exit;end;
    if loose1 then begin
    writeln('Congratulations Player 2!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');readkey;exit;end;
    end;
    end;
    screen;
    end;
  until loose2 or loose1;
 until loose2 or loose1;
clrscr;
if loose2 then begin writeln(le1);
writeln('Congratulations Player 1!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');end;
if loose1 then begin writeln(le2);
writeln('Congratulations Player 2!Yippey!Hooray!You destroyed the enemy village!Kauft mehr Wars!');end;
readln;
end.
