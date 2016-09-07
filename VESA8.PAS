unit vesa8;
interface
uses dos,crt,modexlib,memory;
const
maxx:array[$101..$105] of longint=(640,640,800,800,1024);
maxy:array[$101..$105] of longint=(480,480,600,600,768);
anz=100;
schaltx=61;schalty=22;
schalt2x=94;
mal=2;
var
ytab:array[0..768] of longint;
relgransize,gran,winsize:longint;
comp,akmodus,u,gross,wx,wy:word;
beginx,beginy,endex,endey:word;
hoch,hell:integer;
akw,akems,aktab:byte;
g,format:boolean;
type
buf=array[0..64000] of byte;
spritetyp=record
adr:pointer;
dtx,dty:byte;
end;
var zeichen:array[0..2,0..101] of spritetyp;
zhb:array[0..2] of record dx,dy:byte;end;
point:pointer;
l:array[1..25] of emshandle;
{schalt:array[0..7] of spritetyp;             }
procedure put(x,y:word;spr:spritetyp);
procedure fenster(pos:word);
procedure fenster2(pos:word);
procedure fehler(was:string);
procedure initvesa(modus:word);
procedure getsprite(offs:word;brei,hoc:word;var spr:spritetyp);
procedure getsprite_ems(offs:word;brei,hoc:word;var spr:spritetyp);
procedure wind(x1,x2,y1,y2:word);
{procedure putsprite(x,y:word;spr:spritetyp);}
procedure putsprite3(x,y:word;spr:spritetyp);
{procedure putsprite2(x,y:word;spr:spritetyp);}
procedure putsprite_ems(x,y:word;spr:spritetyp;emsnum:byte);
procedure showpic;
{procedure initfont(wox,woy:word;dx,dy:byte);
procedure schreib(x,y:word;c:byte);
procedure writes(was:string);
procedure click(x,y:word;on:byte;text:string);
procedure initschalt(wox,woy:word);}
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
gran:=(infobuf[2])*1024;
if gran=0 then gran:=65535;
writeln('Granularity : ',gran);
writeln(infobuf[3]);
winsize:=65535{(infobuf[6]+infobuf[7]*256)*1024};
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
akmodus:=modus;
for hoch:=0 to 767 do ytab[hoch]:=hoch*maxx[akmodus];
hoch:=0;
intr($10,r);
end;
procedure fenster2;
assembler;asm
mov ax,pos
cmp al,akw
je @nothing
mov akw,al
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
cmp al,akw
je @nothing
mov akw,al
mov AH,$4F
mov AL,5
xor bx,bx
mov dx,pos
int $10
@nothing:
end;
procedure getsprite(offs:word;brei,hoc:word;var spr:spritetyp);
begin
getmem(spr.adr,hoc*brei);
spr.dtx:=brei;
spr.dty:=hoc;
{
asm
@loop1:
inc bx
cmp bx,brei
je @ende1
 @loop2:
 inc di
 inc cx
 cmp cx,hoc
 je @ende2
 imul ax,cx,320
 add ax,cx
 mov si,ax
 mov dl,$a000[si]
 mov byte ptr spr[di],10
 jmp @loop2
 @ende2:
 xor cx,cx
 @ende1:
end;}
temp:=1;
for gsx:=0 to HOC-1 do for gsy:=0 to BREI-1 do begin
inc(temp);mem[seg(spr.adr^):ofs(spr.adr^)+temp]:=gsx{mem[$a000:offs+gsx+gsy*320];}
end;
end;
procedure getsprite_ems;
var tte:^buf;
begin
getmem(tte,hoc*brei);
spr.dtx:=brei;
spr.dty:=hoc;
temp:=1;
for gsy:=0 to hoc-1 do for gsx:=0 to brei-1 do begin
inc(temp);tte^[temp]:=mem[$a000:offs+gsx+gsy*320];
end;
ram_2_ems(tte,l[akems],hoc*brei);
inc(akems);
freemem(tte,hoc*brei);
end;
{procedure putsprite2;
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
    temp3:=temp shr 16 shl 4; {eben temp div 65536 aber schneller!
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
end;}
{procedure putsprite2;
var tey,temp4,temp:longint;
my,temp2,temp3:word;
begin
  temp2:=1;
  temp4:=x+y*maxx[akmodus];
  my:=0;
  for gsy:=0 to spr.dty-1 do begin
   if (y+gsy>maxy[akmodus]) then exit;
   tey:=gsy*maxx[akmodus]+temp4;{ytab[gsy-my]+temp4{*maxx[akmodus];}
{   for gsx:=0 to spr.dtx-1 do begin
    inc(temp2);
    if (x+gsx>=maxx[akmodus]) or (x+gsx<0) or (spr.adr^[temp2]=0) then continue;
    if spr.adr^[temp2{+my*spr.dtx]=0 then continue;                }
{    temp:=gsx+tey;
    temp3:=temp shr 16 shl 4; {eben temp div 65536 aber schneller!}
{    asm
     mov ax,temp3
     cmp al,akw
     je @nothing
     mov akw,al
     mov dx,ax
     mov AH,$4F
     mov AL,5
     xor bx,bx
call p
     @nothing:
    end;
{    if hell=0 then mem[$a000:temp]:=spr.adr^[temp2+my*spr.dtx] else}
{    mem[$a000:temp]:=spr.adr^[temp2{+my*spr.dtx}{+hell}

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
{   end;
 end;
end;}
procedure wind(x1,x2,y1,y2:word);
begin
beginx:=x1;
beginy:=y1;
if x2-64>beginx then endex:=x2-64 else endex:=beginx;
if y2-32>beginy then endey:=y2-32 else endey:=beginy;
end;
procedure put(x,y:word;spr:spritetyp);
var y2:word;
begin
asm
{in ax wird y verwaltet, in cx wird x verwaltet}
   mov ax,y
   mov bx,ax
   and ax,64
   sub bx,ax
   mov y2,bx            {Nun ist in y2 der "Ueberschuss"}
   mov al,spr.dty
   @loopy:
    mov cl,spr.dtx
    @loopx:
     mov dl,byte ptr spr.adr[si]
     mov bx,ax
     add bx,cx
     mov byte ptr $a000[bx],100
     inc si
     dec cx
     jnz @loopx
    dec ax
    jnz @loopy
end;
end;
procedure putsprite3;
var blobb:word;
begin
{  if (y>endey) or (x>endex) or (y<beginy) or (x<beginx) then exit;}
    asm
{     pushf;
     pusha;
{     mov di,word ptr spr.adr+2
{     mov ds,word ptr $a000}  {Auf Datensegment nicht zugreifbar??? (Globale Variablen)}
     xor cx,cx
     xor si,si
{     xor ax,ax
     mov cl,spr.dtx
     add ax,cx
     mov cl,spr.dty
     mul ax,bx
     mov di,ax}
     mov cl,spr.dty             {Zaehler fuer y initialisieren}
{     dec cl
     {mov dx,y                   {Y-Wert in dx. Schneller!}
     @loop1:
     add cx,y                  {Ueberpruefung, ob noch im Fenster}
     mov ax,cx
     shr ax,6
     cmp al,akw
     je @nothing
     mov akw,al
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
     mov bl,spr.dtx
     add ax,x
     add bx,ax
     mov comp,ax{     sub ax,x
 {    dec bx}
     @loop2:
     push cx
     @loop3:
     push cx
     pop cx
     push cx
     pop cx
     push cx
     pop cx
     loop @loop3
     pop cx
     inc blobb
     push si
     mov si,blobb
     mov dl,byte ptr [spr.adr[si]]
     pop si
     {or dl,dl
     jz @loop2}
     mov ax,$a000
     mov es,ax
     dec bx
     cmp bx,comp
     je @ende1
     mov byte ptr es:[bx],dl
     jmp @loop2
     @ende1:
     sub cx,y
    sub bx,x
{     dec bx}
     dec cx
     jz @endeende                   {Fertig?}
     jmp @loop1
     @endeende:
    end;
end;
procedure putsprite_ems;
var tey,temp4,temp:longint;
tey2,temp2,temp3:word;
tte:^buf;
begin
  if (y>endey) or (x>endex) or (y<beginy) or (x<beginx) then exit;
  temp4:=x+ytab[y];
{  if ((y+spr.dty)>maxy[akmodus]) or ((x+spr.dtx)>maxx[akmodus]) or (y<0) or (x<0) then exit;}
  temp2:=1;
  getmem(tte,spr.dtx*spr.dty);
  ems_2_ram(tte,l[emsnum],spr.dtx*spr.dty);
  for gsy:=0 to spr.dty-1 do begin
{   if (y+gsy>maxy[akmodus]) then exit;}
   tey:=ytab[gsy]+temp4;
   temp3:=tey shr 16 shl 4;{eben temp div 65536 aber schneller!}
{   tey2:=tey mod 65536;}
     asm
     mov ax,temp3
     cmp al,akw
     je @nothing
     mov akw,al
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
{procedure initfont;
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
end;
procedure schreib(x,y:word;c:byte);
begin
 if c>0 then putsprite(x,y,zeichen[aktab,c-1]);
end;
procedure writes(was:string);
begin
 for temp:=1 to ord(was[0]) do begin
  if format=false then begin if ord(was[temp])<=anz then schreib(wx,wy,ord(was[temp])-32) else schreib(wx,wy,0);end else
  case was[temp] of
   #0..#32:schreib(wx,wy,0);
   #33..#90:schreib(wx,wy,ord(was[temp])-32);
   #91..#96:schreib(wx,wy,0);
   #97..#122:schreib(wx,wy,ord(was[temp])-32);
   #123..#255:schreib(wx,wy,0);
  end;
   inc(wx,zhb[aktab].dx);if wx+zhb[aktab].dx>maxx[akmodus] then begin wx:=0;inc(wy,zhb[aktab].dy);end;
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


procedure click(x,y:word;on:byte;text:string);
begin
g:=false;gross:=0;
if ord(text[0])>9 then begin g:=true;gross:=4;end;
if g=false then begin wx:=x+schaltx div 2-(ord(text[0])*3);wy:=y+schalty div 2-4;end else
begin wx:=x+schalt2x div 2-(ord(text[0])*3);wy:=y+schalty div 2-4;end;
if (on=3) or (on=1) then begin
inc(wx);inc(wy);
end;
putsprite(x,y,schalt[on+gross]);
if on>1 then aktab:=1 else aktab:=on;
writes(text);
end;}
begin
akems:=1;
end.
procedure putsprite;
var tey,temp4,temp:longint;
tey2,temp2,temp3:word;
begin
  if (y>endey) or (x>endex) or (y<beginy) or (x<beginx) then exit;
  temp4:=x+ytab[y];
{  if ((y+spr.dty)>maxy[akmodus]) or ((x+spr.dtx)>maxx[akmodus]) or (y<0) or (x<0) then exit;}
  temp2:=1;
  for gsy:=0 to spr.dty-1 do begin
{   if (y+gsy>maxy[akmodus]) then exit;}
   tey:=ytab[gsy]+temp4;
   temp3:=tey shr 16 shl 4;{eben temp div 65536 aber schneller!}
{   tey2:=tey mod 65536;}
     asm
     mov ax,temp3
     cmp al,akw
     je @nothing
     mov akw,al
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
