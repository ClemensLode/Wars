{Yeaa! Die newput procedure funktioniert!!!! Nun gehts ans Optimieren... ;-)}
unit baker;
interface
uses dos,crt,modexlib{,memory};
const
maxx:array[$101..$105] of longint=(640,640,800,800,1024);
maxy:array[$101..$105] of longint=(480,480,600,600,768);
anz=100;
schaltx=62;schalty=22;
schalt2x=96;
mal=2;
type mbuf=array[0..199] of word;
var
vp:pointer absolute $a000:0;
adr:pointer;
oldm:^mbuf;
sfenster:array[0..768] of word; {Y rein, Fenster raus}
screeny:array[0..768] of word;  {Y rein, Y raus (*1024)}
screeny2:array[0..768] of byte;  {Y rein, newY raus}
relgransize,gran,winsize:longint;
comp,akmodus,u,gross,wx,wy:word;
akw,beginx,beginy,endex,endey:word;
hoch:integer;
hell:shortint;
akems,aktab:byte;
black,g,format:boolean;
type
buf=array[0..64000] of byte;
spritetyp=record
adr:^buf;
dtx,dty:word;
komp:boolean;
end;
var zeichen:array[0..2,0..101] of spritetyp;
oldmaus:spritetyp;
zhb:array[0..2] of record dx,dy:byte;end;
{l:array[1..25] of emshandle;}
schalt:array[0..7] of spritetyp;
umhell:shortint;
procedure fenster(pos:word);
procedure fill;
procedure fenster2(pos:word);
procedure fehler(was:string);
procedure initvesa(modus:word);
procedure getimage(ox,oy:word);
procedure clear;
Procedure putimage(ox,oy:word);
procedure getsprite(offs:word;brei,hoc:word;var spr:spritetyp);
procedure getsprite2(offs:word;brei,hoc:word;var spr:spritetyp);
procedure getsprite3(offs:word;brei,hoc:word;var spr:spritetyp);
procedure getsprite_ems(offs:word;brei,hoc:word;var spr:spritetyp);
Procedure newput2(ox,oy:word;spr:spritetyp);
procedure wind(x1,x2,y1,y2:word);
function light(col:byte):byte;
procedure newput(ox,oy:word;spr:spritetyp);
procedure putpasc(ox,oy:word;spr:spritetyp);
procedure putit(ox,oy,dtx,dty:word;adr:pointer);
procedure putpasc2(ox,oy:word;spr:spritetyp);
procedure putpasc6(ox,oy:word;spr:spritetyp);
procedure putsprite(x,y:word;spr:spritetyp);
procedure putsprite3(x,y:word;spr:spritetyp);
procedure putsprite5(x,y:word;spr:spritetyp);
procedure rechteck(x1,y1,x2,y2:word);
procedure putsprite2(x,y:word;spr:spritetyp);
procedure putsprite_ems(x,y:word;spr:spritetyp;emsnum:byte);
procedure showpic;
procedure initfont(wox,woy:word;dx,dy:byte);
procedure schreib(x,y:word;c:byte);
procedure writes(was:string);
procedure click(x,y:word;on:byte;txt:string);
procedure initschalt(wox,woy:word);
implementation
var
temp:word;
gsx,gsy:word;
r:registers;
p:pointer;
vesabuf:array[0..255] of char;
infobuf:array[0..127] of WORD;
procedure fehler;
begin
writeln(' abgebrochen! Fehler : ',was);
halt;
end;

procedure initvesa;
var longp:longint;
begin
textmode(3);
r.ah:=$4F;
r.al:=$00;
r.es:=seg(vesabuf);
r.di:=ofs(vesabuf);
write('Grafikkartencheck ...');
intr($10,r);
if (vesabuf[0]+vesabuf[1]+vesabuf[2]+vesabuf[3]<>'VESA') or (r.ah<>$00) then
fehler('1, die vorhandene Grafikkarte ist nicht VESA kompatibel!');
if r.al<>$4F then fehler('2, Ein nicht zuzuordnender Fehler mit der Grafikkarte ist aufgetreten. ');
writeln(' OK!');
writeln(vesabuf[0]+vesabuf[1]+vesabuf[2]+vesabuf[3],' wird unterstuetzt');
writeln('Version : ',ord(ord(vesabuf[4])),'.',ord(vesabuf[5]));
writeln('Hole Informationen ueber Modus ',modus,' ...');
r.ah:=$4F;
r.al:=$01;
r.cx:=modus;
r.es:=seg(infobuf);
r.di:=ofs(infobuf);
intr($10,r);
if (r.al<>$4F) or (infobuf[0] and 1=0) then
fehler('3, Verlangter Modus wird NICHT von der Grafikkarte unterstuetzt!');
gran:=infobuf[2]*1024;
if gran=0 then gran:=65536;
writeln('Granularity : ',gran);
writeln(infobuf[3]);
winsize:=(infobuf[7]+infobuf[6]*256)*1024;
if winsize=0 then winsize:=65535;
writeln('Groesse der Fenster : ',winsize);
relgransize:=winsize div gran;
writeln('PAGING-Routine befindet sich ab Speicherstelle ',infobuf[$6],':',infobuf[$7]);
P:=PTR(infobuf[7],infobuf[6]);
for temp:=0 to 127 do if infobuf[temp]<>7 then write(infobuf[temp]);
writeln('Stelle Videomodus ',modus,' jetzt ein. Sollte der Monitor stark flimmern, neustarten!');
readln;
r.ah:=$4F;
r.al:=$02;
r.bx:=modus;
intr($10,r);
akmodus:=modus;
for hoch:=0 to 768 do begin
sfenster[hoch]:=((hoch*maxx[akmodus]) div winsize*winsize div gran); {Fenster ausgerechnet}
screeny[hoch]:=((hoch*maxx[akmodus])-((hoch*maxx[akmodus]) div winsize)*winsize)-sfenster[hoch] div 16;
{ytab[hoch].xwo:=ytab[hoch].fenster*gran-((ytab[hoch].fenster*gran) div maxx[akmodus])*maxx[akmodus];}
end;
hoch:=0;
end;
procedure fenster2;
assembler;asm
mov ax,pos
cmp ax,akw
je @nothing
mov akw,ax
mov AH,$4F
mov AL,5
xor bx,bx
mov dx,pos
call p;
@nothing:
end;
procedure fenster;
assembler;
asm
mov ax,pos
cmp ax,akw
je @nothing
mov akw,ax
mov AH,$4F
mov AL,5
xor bx,bx
mov dx,pos
int $10
@nothing:
end;
procedure getsprite;
begin
getmem(spr.adr,hoc*brei);
spr.dtx:=brei div 2;
spr.dty:=hoc;
temp:=0;
for gsy:=0 to hoc-1 do for gsx:=0 to brei-1 do begin
spr.adr^[temp]:=mem[$a000:offs+gsx+gsy*320];inc(temp);
end;
end;
procedure rechteck;
var recover:word;
begin
asm
  push ds
  mov ax,$a000                 {VGA als Ziel}
  mov es,ax

  mov di,x1
  mov bx,y1
  shl bx,1
  mov ax,word ptr screeny[bx]
  add di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter3
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  @weiter3:
  mov cx,x2
  mov ax,x1
  sub cx,ax
  mov al,175
  rep stosb

  mov di,x1
  mov bx,y2
  shl bx,1
  mov ax,word ptr screeny[bx]
  add di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter4
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  @weiter4:
  mov cx,x2
  mov ax,x1
  sub cx,ax
  mov al,175
  rep stosb

  mov ax,y1
  mov cx,y2
  sub cx,ax
  @loop1:
  mov di,x1
  mov bx,y1
  add bx,cx
  shl bx,1
  mov ax,word ptr screeny[bx]
  add di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter5
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  @weiter5:
  push cx
  mov cx,x2
  mov ax,x1
  sub cx,ax
  mov al,175
  mov es:[di],al
  add di,x2
  sub di,x1
  mov es:[di],al
  pop cx
  dec cx
  jnz @loop1
end;
end;
procedure fill;
var rec:word;
begin
asm
  push ds
  mov ax,$a000                 {VGA als Ziel}
  xor cx,cx
  mov ds,ax
  xor al,al
  xor si,si
  @loop1:
  mov [si],al
  add si,2
  jnz @loop1
  mov dx,cx
  mov AH,$4F
  mov AL,5
  xor bx,bx
  mov rec,ds
  pop ds
  call p
  push ds
  mov ds,rec
  xor al,al
  add cx,16
  cmp cx,192
  jb @loop1
  pop ds
end;
end;
procedure clear;
var rec:word;
begin
asm
  push ds
  mov ax,$a000                 {VGA als Ziel}
  mov es,ax
  xor dx,dx
  @loop1:
  mov cx,$FFFE
  xor di,di
  xor ax,ax
  rep stosb
  mov AH,$4F
  mov AL,5
  xor bx,bx
  mov rec,ds
  pop ds
  call p
  push ds
  mov ds,rec
  add dx,16
  cmp dx,12*16
  jb @loop1
  pop ds
end;
end;

procedure getimage;
var temp2:word;
begin
temp:=0;
for gsy:=0 to 19 do begin
temp2:=oy+gsy;
if (sfenster[temp2]<>akw) then begin
akw:=sfenster[temp2];
asm
 xor ax,ax
 mov ax,akw
 mov dx,ax
 mov AH,$4F
 mov AL,5
 xor bx,bx
 call p
end;
end;
for gsx:=0 to 9 do begin
oldm^[temp]:=memw[$a000:ox+gsx shl 1+screeny[temp2]];inc(temp);
end;
end;
end;
procedure getsprite2;
begin
getmem(spr.adr,(hoc+1)*brei);
spr.dtx:=brei;
spr.dty:=hoc+1;
temp:=0;
for gsy:=0 to hoc-1 do for gsx:=0 to brei-1 do begin
spr.adr^[temp]:=mem[$a000:offs+gsx+gsy*320];inc(temp);
end;
for gsx:=0 to brei-1 do begin spr.adr^[temp]:=0;inc(temp);end;
end;

procedure getsprite3;
var temp3,temp2:byte;
temp4:^buf;
begin
getmem(temp4,64000);
spr.dtx:=brei div 2;
spr.dty:=hoc;
temp:=0;
for gsy:=0 to hoc-1 do for gsx:=0 to brei-1 do begin
temp2:=mem[$a000:offs+gsx+gsy*320];
if temp2>0 then begin temp4^[temp]:=temp2;inc(temp);end else begin
temp3:=1;
while (mem[$a000:offs+gsx+gsy*320+temp3]=0) and (gsx+temp3<brei-1) do inc(temp3);
temp4^[temp]:=0;temp4^[temp+1]:=temp3;
inc(temp,2);inc(gsx,temp3);
end;
end;
getmem(spr.adr,temp-1);
move(temp4^,spr.adr^,temp-1);
freemem(temp4,64000);
end;

procedure getsprite_ems;
begin
getmem(spr.adr,hoc*brei);
spr.dtx:=brei;
spr.dty:=hoc;
temp:=1;

for gsy:=0 to hoc-1 do for gsx:=0 to brei-1 do begin
inc(temp);spr.adr^[temp]:=mem[$a000:offs+gsx+gsy*320];
end;
{ram_2_ems(spr.adr,l[akems],hoc*brei);}
inc(akems);
freemem(spr.adr,hoc*brei);
end;
procedure putsprite5;
var tey,temp4,temp:longint;
my,temp2,temp3:word;
begin
  temp2:=1;
  temp4:=x+y*maxx[akmodus];
  my:=0;
  for gsy:=0 to spr.dty-1 do begin
     tey:=(gsy-my)*maxx[akmodus];
   for gsx:=0 to spr.dtx-1 do begin
    inc(temp2);
    if spr.adr^[temp2+my*spr.dtx]=0 then continue;
    temp:=gsx+temp4+tey;
    temp3:=temp shr 16 shl 4; {eben temp div 65536 aber schneller!}
    asm
     mov ax,temp3
     cmp ax,akw
     je @nothing
     mov akw,ax
     mov dx,ax
     mov AH,$4F
     mov AL,5
     xor bx,bx
call p;
     @nothing:
    end;
    if hell=0 then mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx] else
    if hell>0 then begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16<spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell+1) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end else
    begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16>spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell+1) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end;
   end;
 end;
end;

procedure putsprite2;
var tey,temp4,temp:longint;
my,temp2,temp3:word;
begin
  temp2:=1;
  temp4:=x+y*maxx[akmodus];
  my:=0;
  for gsy:=0 to spr.dty-1 do begin
   if (y+gsy>maxy[akmodus]) then exit;
   tey:=gsy*maxx[akmodus]+temp4;{ytab[gsy-my]+temp4{*maxx[akmodus];};
   for gsx:=0 to spr.dtx-1 do begin
    inc(temp2);
    if (x+gsx>=maxx[akmodus]) or (x+gsx<0) or (spr.adr^[temp2]=0) then continue;
    if spr.adr^[temp2{+my*spr.dtx}]=0 then continue;
    temp:=gsx+tey;
    temp3:=temp shr 16 shl 4; {eben temp div 65536 aber schneller!}
    asm
     mov ax,temp3
     cmp ax,akw
     je @nothing
     mov akw,ax
     mov dx,ax
     mov AH,$4F
     mov AL,5
     xor bx,bx
call p
     @nothing:
    end;
{    if hell=0 then mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx] else}
    mem[$a000:temp]:=spr.adr^[temp2{+my*spr.dtx}]{+hell};

{    if hell>0 then begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16<spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end else
    begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16>spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end;}
   end;
 end;
end;
procedure wind(x1,x2,y1,y2:word);
begin
beginx:=x1;
beginy:=y1;
if x2-64>beginx then endex:=x2-64 else endex:=beginx;
if y2-32>beginy then endey:=y2-32 else endey:=beginy;
end;
procedure putsprite;
var tey,temp4,temp:longint;
tey2,temp2,temp3:word;
begin
{  if (y>endey) or (x>endex) or (y<beginy) or (x<beginx) then exit;}
{  temp4:=x+ytab[y];
{  if ((y+spr.dty)>maxy[akmodus]) or ((x+spr.dtx)>maxx[akmodus]) or (y<0) or (x<0) then exit;}
  temp2:=1;
  for gsy:=0 to spr.dty-1 do begin
{   if (y+gsy>maxy[akmodus]) then exit;}
{   tey:=ytab[gsy]+temp4;
   temp3:=tey shr 16 shl 4;{eben temp div 65536 aber schneller!}
{   tey2:=tey mod 65536;}
     asm
     mov ax,temp3
     cmp ax,akw
     je @nothing
     mov akw,ax
     mov dx,ax
     mov AH,$4F
     mov AL,5
     xor bx,bx
     call p
     @nothing:
    end;
{   move(spr.adr^[temp2],mem[$a000:tey],spr.dtx);}
   for gsx:=0 to spr.dtx-1 do begin
   if spr.adr^[temp2+gsx]>0 then
   mem[$a000:word(tey+gsx)]:=
   spr.adr^[temp2+gsx];end;
{move(spr.adr^[temp2],mem[$a000:tey],spr.dtx);}
inc(temp2,spr.dtx);
{    if (x+gsx>=maxx[akmodus]) or (x+gsx<0) or (spr.adr^[temp2]=0) then continue;}
{    temp:=gsx+tey;}
{    inc(temp2);
{    if hell=0 then mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx] else}
{    mem[$a000:gsx+tey]:=spr.adr^[temp2{+my*spr.dtx]{+hell};
{    if hell>0 then begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16<spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end else
    begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16>spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end;}
{   end;}
 end;
end;
function light(col:byte):byte;
var tempc:byte;
begin
if (col<16) or ((col<208) and (col>159)) or (col>239) then begin light:=col;exit;end;
tempc:=col+hell;
case col of
16..31:begin
if (tempc>31) then begin light:=31;exit;end;
if (tempc<16) then begin light:=16;exit;end;
end;
32..47:begin
if (tempc>47) then begin light:=47;exit;end;
if (tempc<32) then begin light:=32;exit;end;
end;
48..79:begin
if (tempc>79) then begin light:=79;exit;end;
if (tempc<48) then begin light:=48;exit;end;
end;
80..111:begin
if (tempc>111) then begin light:=111;exit;end;
if (tempc<80) then begin light:=80;exit;end;
end;
112..159:begin
if (tempc>159) then begin light:=159;exit;end;
if (tempc<112) then begin light:=112;exit;end;
end;
208..223:begin
if (tempc>223) then begin light:=223;exit;end;
if (tempc<208) then begin light:=208;exit;end;
end;
224..239:begin
if (tempc>239) then begin light:=239;exit;end;
if (tempc<224) then begin light:=224;exit;end;
end;
end;
light:=tempc;
end;
{  les DI, Screen.Buffer
  add DI, X
  mov BX, Y       { Y is an index into the ScreenY array        }
{  add BX, BX      { Multipy by two because each entry is a word }
{  add DI, DS:[BX+OFFSET Screen.YTable]

  mov AL, Color
  mov ES:[DI], AL}

Procedure putit;assembler;
{scrollt das Bild um eine Zeile nach oben und interpoliert}
asm
  push ds
  les di,vp             {Zeiger auf Zielbild laden}
  lds si,adr              {Zeiger auf Quellbild}
  add di,ox                    {im Quellbild auf uebergebene XY Koordinaten dazuzaehlen}
  mov BX, oy       { Y is an index into the ScreenY array        }
  add BX, BX      { Multipy by two because each entry is a word }
  add DI, DS:[BX+OFFSET Screeny]
  mov ax,dty                 {spr.dty Zeilen bearbeiten}
  xor bl,bl                     {wird als Dummy fr High-Byte ben”tigt}
@lp1:
  mov cx,dtx              {Zeilen als Dwords kopieren}
  shr cx,4
  db 66h                          {Operand Size Prefix (32 Bit)}
  rep movsw                     {kopieren}
  add si,dtx
  add di,dtx
  dec ax
  jnz @lp1;
  pop ds
End;


procedure putpasc;
var thell,temp,temp2,ggx,ggy:word;t:word;
begin
{if (ox>maxx[akmodus]-2*spr.dtx) or (ox<2*spr.dtx) or (oy>maxy[akmodus]-2*spr.dty) or (oy<2*spr.dty) then exit;}
t:=0;
{asm
mov al,spr.dty
mov ggy,ax
@loopy:
dec ggy
jz @fertig
mov ax,oy
add ax,ggy
lea di,ytab[ax]}
for ggy:=0 to spr.dty-1 do begin
temp2:=oy+ggy;
if (sfenster[temp2]<>akw) then begin
akw:=sfenster[temp2];
asm
 xor ax,ax
 mov ax,akw
 mov dx,ax
 mov AH,$4F
 mov AL,5
 xor bx,bx
 call p
end;
end;
{asm
les di,spr.adr
add di,t
mov cx,ggx
@loopx:
dec cx
jz @endex
add di,cx}
for ggx:=0 to spr.dtx div 2-1 do begin
{if ox+ggx>ytab[oy+ggy].xwo then decx:=ytab[oy+ggy].xwo else decx:=0;}
temp:=memw[seg(spr.adr^):ofs(spr.adr^)+t];
temp:=light(lo(temp){,hell+umhell})+256*light(hi(temp){,hell+umhell});
if (lo(temp)>0) and (hi(temp)>0) then memw[$a000:ox+screeny[temp2]+ggx*2]:=temp else begin
if (lo(temp)=0) and (hi(temp)>0) then mem[$a000:ox+screeny[temp2]+ggx*2+1]:=hi(temp) else
if (hi(temp)=0) and (lo(temp)>0) then mem[$a000:ox+screeny[temp2]+ggx*2]:=lo(temp);
end;
inc(t,2);
end;
end;
end;
Procedure newput(ox,oy:word;spr:spritetyp);
var recover:word;
begin
asm
  push ds
  lds si,spr.adr             {fertiges Bild als Quelle}
  mov ax,$a000                 {VGA als Ziel}
  mov es,ax
  xor bx,bx
  add bx,oy
  mov cx,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter3
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter3:
  shr bx,1
  push ds
  mov ds,cx
  sub bx,oy
  add di,ox
  @loop1:
  mov ax,spr.dtx
{  shr ax,1     Optimierung}
  mov cx,ax        {100 Zeilen als Dwords kopieren}
  @loop2:

{  pop ds
  xor ax,ax
  mov al,hell
  push ds
  mov ds,recover}
  mov dx,[si]
{  add dx,ax
  mov ax,dx

  mov dx,ax}
  or dx,dx
  jz @loop3

  or dl,dl
  jz @point1

  or dh,dh
  jz @point2

  mov es:[di],dx
  jmp @loop3
  @point1:
  mov es:[di+1],dh
  jmp @loop3
  @point2:
  mov es:[di],dl
  @loop3:
  add di,2
  add si,2
  dec cx
  jz @endex
jmp @loop2
  @endex:
{  db 66h                          {Operand Size Prefix (32 Bit)}
{ rep movsw                     {kopieren}
  add bx,oy
  mov cx,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter2
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter2:
  shr bx,1
  sub bx,oy
  push ds
  mov ds,cx
  add di,ox
  inc bx
  cmp bx,spr.dty
  jne @loop1
  pop ds
End;
end;
Procedure Buxstabe(ox,oy:word;spr:spritetyp);
var recover:word;
begin
asm
  push ds
  lds si,spr.adr             {fertiges Bild als Quelle}
  mov ax,$a000                 {VGA als Ziel}
  mov es,ax
  xor bx,bx
  add bx,oy
  mov cx,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter3
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter3:
  shr bx,1
  push ds
  mov ds,cx
  sub bx,oy
  add di,ox
  @loop1:
  mov ax,spr.dtx
  shr ax,1
  mov cx,ax        {100 Zeilen als Dwords kopieren}
  db 66h
  rep movsw
  @endex:
{  db 66h                          {Operand Size Prefix (32 Bit)}
{ rep movsw                     {kopieren}
  add bx,oy
  mov cx,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter2
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter2:
  shr bx,1
  sub bx,oy
  push ds
  mov ds,cx
  add di,ox
  inc bx
  cmp bx,spr.dty
  jne @loop1
  pop ds
End;
end;
Procedure putimage(ox,oy:word);
var recover:word;
begin
asm
  push ds
  lds si,oldm             {fertiges Bild als Quelle}
  mov ax,$a000                 {VGA als Ziel}
  mov es,ax
  xor bx,bx
  add bx,oy
  mov recover,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter3
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter3:
  shr bx,1
  push ds
  mov ds,recover
  sub bx,oy
  add di,ox
  @loop1:
  mov ax,10
{  shr ax,1     Optimierung}
  mov cx,ax        {100 Zeilen als Dwords kopieren}
  @loop2:

{  pop ds
  xor ax,ax
  mov al,hell
  push ds
  mov ds,recover}
  mov dx,[si]
{  add dx,ax
  mov ax,dx

  mov dx,ax}
  mov es:[di],dx
  add di,2
  add si,2
  dec cx
  jz @endex
jmp @loop2
  @endex:
{  db 66h                          {Operand Size Prefix (32 Bit)}
{ rep movsw                     {kopieren}
  add bx,oy
  mov recover,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter2
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter2:
  shr bx,1
  sub bx,oy
  push ds
  mov ds,recover
  add di,ox
  inc bx
  cmp bx,20
  jne @loop1
  pop ds
End;
end;
Procedure newput2(ox,oy:word;spr:spritetyp);
var recover:word;
begin
asm
  push ds
  lds si,spr.adr             {fertiges Bild als Quelle}
  mov ax,$a000                 {VGA als Ziel}
  mov es,ax
  xor bx,bx
  add bx,oy
  mov recover,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter3
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter3:
  shr bx,1
  push ds
  mov ds,recover
  sub bx,oy
  add di,ox
  @loop1:
  mov ax,spr.dtx
{  shr ax,1     Optimierung}
  mov cx,ax        {100 Zeilen als Dwords kopieren}
  @loop2:

{  pop ds
  xor ax,ax
  mov al,hell
  push ds
  mov ds,recover}
  mov dx,[si]
{  add dx,ax
  mov ax,dx

  mov dx,ax}
{  or dx,dx     Fall ausschliessen, da das NIE vorkommen KANN
  jz @loop3}

  or dl,dl
  jz @point1

  or dh,dh
  jz @point2

  mov es:[di],dx
  add di,2
  jmp @loop3

  @point1:
  push cx
  mov cx,[si+1]
  xor al,al
  rep stosb
  pop cx
  add cx,[si+1]
{  mov es:[di+1],dh}
  jmp @loop3

  @point2:
  mov es:[di],dl
  inc di
  inc si
  push cx
  mov cx,[si+1]
  xor al,al
  rep stosb
  pop cx
  add cx,[si+1]
  @loop3:

  add si,2
  dec cx
  jz @endex
  jmp @loop2
  @endex:
{  db 66h                          {Operand Size Prefix (32 Bit)}
{ rep movsw                     {kopieren}
  add bx,oy
  mov recover,ds
  pop ds
  shl bx,1
  mov ax,word ptr screeny[bx]
  mov di,ax
  mov ax,word ptr sfenster[bx]
  cmp ax,akw
  je @weiter2
  mov akw,ax
  mov dx,ax
  mov AH,$4F
  mov AL,5
  push bx
  xor bx,bx
  call p
  pop bx
  @weiter2:
  shr bx,1
  sub bx,oy
  push ds
  mov ds,recover
  add di,ox
  inc bx
  cmp bx,spr.dty
  jne @loop1
  pop ds
End;
end;
procedure putpasc6;
var temp:word;ggy:word;t:word;
begin
if (ox>maxx[akmodus]) or (ox<0) or (oy>maxy[akmodus]) or (oy<0) then exit;
t:=0;
asm
lea si,[spr.adr]    {DS:SI -> 16-bit input block           }
mov ax, $a000          {ES:DI -> 16-bit output block          }
mov es, ax
mov ax,spr.dty
mov ggy,ax
lea si,[spr.adr]    {DS:SI -> 16-bit input block           }
@copyy:
dec ggy
jz @ende
mov ax,ggy
add ax,oy
mov bx,ax
mov ax,word ptr sfenster[bx]
mov dx,word ptr screeny[bx]
cmp ax,akw
je @weiter
mov akw,ax
mov dx,ax
mov AH,$4F
mov AL,5
xor bx,bx
call p
@weiter:
mov cx, spr.dtx
mov di,dx
add di,ox
{add di,spr.dtx}
@Copyx:
mov ax, $a000          {ES:DI -> 16-bit output block          }
mov es, ax
mov   ax, 1                {Load a sample from the mixing block   }
add   di, 2                   {Increment destination pointer         }
add   si, 2                   {Increment source pointer              }
mov   es:[di-2], ax           {Store sample in output block          }
dec   cx                      {Process the next sample               }
jnz   @Copyx
jmp @copyy
@ende:
end;
end;

{


mov al,spr.dty
mov ggy,=al
@yloop:
xor bh,bh
dec ggy
jz @ende
mov bl,ggy
add bx,oy
mov temp,bx
mov al,akw
cmp byte ptr sfenster[bx],al
je @notchange
mov al,byte ptr sfenster[bx]
mov akw,al
mov dx,ax
mov AH,$4F
mov AL,5
xor bx,bx
call p
@notchange:
xor ax,ax
mov al,spr.dtx
@loopx:
inc cx
dec ax
jz @yloop
mov bx,seg spr.adr
mov es,bx
mov bx,offset spr.adr
mov bx,cx
mov di,bx
mov dl,[es:[di]]
{es:[di]
cmp dl,0
jz @yloop
mov bx,$a000
mov es,bx
xor bx,bx
mov bl,ggy
mov di,oy
add di,bx
xor bx,bx
add bx,word ptr screeny[di]
add bx,ax
add bx,ox
mov di,bx
mov es:[di],dl
jmp @loopx
@ende:
end;
end;}
procedure putpasc2;
var temp,temp2,decx,xx,ggx,ggy:word;t:word;
begin
if (ox>maxx[akmodus]) or (ox<0) or (oy>maxy[akmodus]) or (oy<0) then exit;
t:=0;
for ggy:=0 to spr.dty-1 do begin
temp2:=oy+ggy;
asm
xor ax,ax
{mov al,byte ptr [ytab[temp2]]}
cmp ax,akw
je @weiter
mov akw,ax
mov dx,ax
mov AH,$4F
mov AL,5
xor bx,bx
call p
@weiter:
end;
for ggx:=0 to spr.dtx-1 do begin
{if ox+ggx>ytab[oy+ggy].xwo then decx:=ytab[oy+ggy].xwo else }decx:=0;
temp:=mem[seg(spr.adr^):ofs(spr.adr^)+t];
if temp>0 then mem[$a000:ox+screeny[temp2]+ggx+decx]:=temp+hell;
inc(t);
end;
end;
end;
procedure putsprite3;
begin
{  if (y>endey) or (x>endex) or (y<beginy) or (x<beginx) then exit;}
    asm
{     pushf;
     pusha;
{     mov di,word ptr spr.adr+2
{     mov ds,word ptr $a000}  {Auf Datensegment nicht zugreifbar??? (Globale Variablen)}
     xor cx,cx
{     xor ax,ax
     mov cl,spr.dtx
     add ax,cx
     mov cl,spr.dty
     mul ax,bx
     mov di,ax}
     mov cx,spr.dty             {Zaehler fuer y initialisieren}
{     dec cl
     {mov dx,y                   {Y-Wert in dx. Schneller!}
     @loop1:
     dec cl
     jz @endeende                   {Fertig?}
     add cx,y                  {Ueberpruefung, ob noch im Fenster}
     mov al,cl
     shr al,6
     cmp ax,akw
     je @nothing
     mov akw,ax
     shl ax,4
     xor dx,dx
     mov dl,al
     mov AH,$4F
     mov AL,5
     xor bx,bx
     call p
     @nothing:
     mov bx,cx                  {Tatsaechliche Y-Koordinate "errechnet"}
     and bx,64
{     shr bx,6
     shl bx,6                   {Runden}
     mov ax,cx
     sub ax,bx                  {Position des Fensters abziehen. Nun in ax entgueltige Y-Koordinate}
     shl ax,10
     xor bx,bx
     mov bx,spr.dtx
     add bx,ax
     add bx,x
     mov comp,ax
 {    dec bx}
     @loop2:
     inc di
     dec bx
     cmp bx,comp
     jbe @ende1
{     push di
{     mov di,bx
{     mov ax,seg spr.adr
     mov es,ax
     mov dl,byte ptr es:[di]}
     mov dl,byte ptr spr.adr[di]
 {    pop di}
     or dl,dl
     jz @loop2
     mov ax,$a000
     mov es,ax
     mov byte ptr es:[bx],dl
     jmp @loop2
     @ende1:
     sub cx,y
     sub bx,x
     jmp @loop1
     @endeende:
 {   popa;
    popf;}
    end;
end;
procedure putsprite_ems;
var tey,temp4,temp:longint;
tey2,temp2,temp3:word;
tte:^buf;
begin
  if (y>endey) or (x>endex) or (y<beginy) or (x<beginx) then exit;
{  temp4:=x+ytab[y];
{  if ((y+spr.dty)>maxy[akmodus]) or ((x+spr.dtx)>maxx[akmodus]) or (y<0) or (x<0) then exit;}
  temp2:=1;
  getmem(tte,spr.dtx*spr.dty);
{  ems_2_ram(tte,l[emsnum],spr.dtx*spr.dty);}
  for gsy:=0 to spr.dty-1 do begin
{   if (y+gsy>maxy[akmodus]) then exit;}
{   tey:=ytab[gsy]+temp4;
   temp3:=tey shr 16 shl 4;{eben temp div 65536 aber schneller!}
{   tey2:=tey mod 65536;}
     asm
     mov ax,temp3
     cmp ax,akw
     je @nothing
     mov akw,ax
     mov dx,ax
     mov AH,$4F
     mov AL,5
     xor bx,bx
     call p
     @nothing:
    end;
{   move(spr.adr^[temp2],mem[$a000:tey],spr.dtx);}
   for gsx:=0 to spr.dtx-1 do begin
   if tte^[temp2+gsx]>0 then
   mem[$a000:word(tey+gsx)]:=
   tte^[temp2+gsx];end;

{move(spr.adr^[temp2],mem[$a000:tey],spr.dtx);}
inc(temp2,spr.dtx);
{    if (x+gsx>=maxx[akmodus]) or (x+gsx<0) or (spr.adr^[temp2]=0) then continue;}
{    temp:=gsx+tey;}
{    inc(temp2);
{    if hell=0 then mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx] else}
{    mem[$a000:gsx+tey]:=spr.adr^[temp2{+my*spr.dtx]{+hell};
{    if hell>0 then begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16<spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end else
    begin
     if (spr.adr^[temp2+my*spr.dtx]+hell) mod 16>spr.adr^[temp2+my*spr.dtx] mod 16 then
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell-(spr.adr^[temp2+my*spr.dtx]+hell) mod 16 else
     mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx]+hell;
    end;}
{   end;}
 end;
freemem(tte,spr.dtx*spr.dty);
end;
procedure showpic;
var s2,seiten:longint;
begin
s2:=maxy[akmodus]*maxx[akmodus];
seiten:=s2;
fenster(0);
while seiten>=65535 do begin
move(mem[seg(vscreen^)+(s2-seiten) div 16:ofs(vscreen^)],mem[$a000:0],65535);
dec(seiten,65535);
fenster(round((s2-seiten)/65535*16));
end;
if seiten>0 then move(vscreen,mem[$a000:0],seiten);
end;
procedure initfont;
var temp8:byte;
begin
 zhb[aktab].dx:=dx;
 zhb[aktab].dy:=dy;
 wx:=wox;
 wy:=woy;
 for temp8:=0 to anz do begin
  inc(wx,zhb[aktab].dx);if wx+zhb[aktab].dx>320 then begin wx:=0;inc(wy,zhb[aktab].dy);end;
  getsprite(wx+wy*320,zhb[aktab].dx,zhb[aktab].dy,zeichen[aktab,temp8]);
 end;
 getsprite(0,dx,dy,zeichen[0,0]);
end;
procedure schreib(x,y:word;c:byte);
begin
 if c>0 then begin if black then buxstabe(x,y,zeichen[aktab,c-1]) else
                                 newput(x,y,zeichen[aktab,c-1]);end else
             begin if black then buxstabe(x,y,zeichen[aktab,0]) else
                                 newput(x,y,zeichen[aktab,0]);end;

end;
procedure writes(was:string);
var zzz:word;
begin
 for temp:=1 to ord(was[0]) do begin
  if (ord(was[temp])=0) then exit;
  if (ord(was[temp])=13) then begin
  for zzz:=1 to (1024-wx) div 32 do schreib(wx+zzz*32,wy,0);
  inc(wy,zhb[aktab].dy);exit;end;
  if (ord(was[temp])=10) then begin wx:=0;exit;end;
  if format=false then begin
   if (ord(was[temp])-32<=anz) and (ord(was[temp])-32>=0) then schreib(wx,wy,ord(was[temp])-32) else schreib(wx,wy,0);

  end else
  case was[temp] of
{   #0..#32:schreib(wx,wy,1);}
   #33..#90:schreib(wx,wy,ord(was[temp])-32);
{   #91..#96:schreib(wx,wy,1);}
   #97..#122:schreib(wx,wy,ord(was[temp])-32);
{   #123..#255:schreib(wx,wy,1);}
  end;
   if (ord(was[temp])>0) then inc(wx,zhb[aktab].dx);if wx+zhb[aktab].dx>maxx[akmodus] then
   begin wx:=0;inc(wy,zhb[aktab].dy);end;
 end;
end;
procedure initschalt(wox,woy:word);
begin
 getsprite(wox+woy*320,schaltx,schalty,schalt[0]);
 getsprite(wox+(woy+schalty)*320,schaltx,schalty,schalt[1]);
 getsprite(wox+schaltx+woy*320,schaltx,schalty,schalt[2]);
 getsprite(wox+schaltx+(woy+schalty)*320,schaltx,schalty,schalt[3]);
 getsprite(wox+2*schaltx+woy*320,schalt2x,schalty,schalt[4]);
 getsprite(wox+2*schaltx+(woy+schalty)*320,schalt2x,schalty,schalt[5]);
 getsprite(wox+2*schaltx+schalt2x+woy*320,schalt2x,schalty,schalt[6]);
 getsprite(wox+2*schaltx+schalt2x+(woy+schalty)*320,schalt2x,schalty,schalt[7]);
end;


procedure click(x,y:word;on:byte;txt:string);
begin
g:=false;gross:=0;
if ord(txt[0])>9 then begin g:=true;gross:=4;end;
if g=false then begin wx:=x+schaltx div 2-(ord(txt[0])*3);wy:=y+schalty div 2-4;end else
begin wx:=x+schalt2x div 2-(ord(txt[0])*3);wy:=y+schalty div 2-4;end;
if (on=3) or (on=1) then begin
inc(wx);inc(wy);
end;
newput(x,y,schalt[on+gross]);
if on>1 then aktab:=1 else aktab:=on;
writes(txt);
end;
begin
getmem(oldm,400);
akems:=1;
end.
