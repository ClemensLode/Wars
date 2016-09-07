unit vesa2;
interface
uses dos,crt,modexlib;
var
relgransize,gran,winsize,maxx,maxy,akmodus:longint;
akw:word;
type
buf=array[0..10000] of byte;
spritetyp=record
adr:^buf;
dtx,dty:byte;
end;
procedure fenster(pos:word);
procedure fenster2(pos:word);
procedure fehler(was:string);
procedure initvesa(modus:word);
procedure getsprite(offs:word;breit,hoch:byte;var spr:spritetyp);
procedure putsprite(x,y:word;spr:spritetyp);
implementation
var
temp:word;
gsx,gsy:word;
r:registers;
p:pointer;
vesabuf:array[0..255] of char;
infobuf:array[0..255] of byte;
procedure fehler;
begin
writeln(' abgebrochen! Fehler : ',was);
halt;
end;

procedure initvesa;
begin
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
if (r.al<>$4F) or ((infobuf[0]+infobuf[1]*256) and 1=0) then
fehler('3, Verlangter Modus wird NICHT von der Grafikkarte unterstuetzt!');
gran:=(infobuf[4]+infobuf[5]*256)*1024;
if gran=0 then gran:=65535;
writeln('Granularity : ',gran);
writeln(infobuf[6]);
writeln(infobuf[7]);
winsize:=65535{(infobuf[6]+infobuf[7]*256)*1024};
if winsize=0 then winsize:=65535;
writeln('Groesse der Fenster : ',winsize);
relgransize:=winsize div gran;
p:=ptr(infobuf[$0C]+infobuf[$0D]*256,infobuf[$0E]+infobuf[$0F]*256);
writeln('PAGING-Routine befindet sich ab Speicherstelle ',seg(p),':',ofs(p));
for temp:=1 to 500 do if mem[seg(p):ofs(p)+temp]<>7 then write(chr(mem[seg(p):ofs(p)+temp]));
writeln('Stelle Videomodus ',modus,' jetzt ein. Sollte der Monitor stark flimmern, neustarten!');
readkey;
r.ah:=$4F;
r.al:=$02;
r.bx:=modus;
akmodus:=modus;
case modus of
$101:begin maxx:=640;maxy:=480;end;
$103:begin maxx:=800;maxy:=600;end;
$105:begin maxx:=1024;maxy:=768;end;
end;
intr($10,r);
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
getmem(spr.adr,hoch*breit);
spr.dtx:=breit;
spr.dty:=hoch;
temp:=0;
for gsy:=0 to hoch-1 do for gsx:=0 to breit-1 do begin
inc(temp);spr.adr^[temp]:=mem[$a000:offs+gsx+gsy*320];
end;
end;
procedure putsprite;
var temp4,temp:longint;
temp2,temp3:word;
s1,s2:byte;
begin
temp2:=0;
temp4:=x+y*maxx;
for gsy:=0 to spr.dty-1 do for gsx:=0 to spr.dtx-1 do begin
inc(temp2);
if spr.adr^[temp2]=0 then continue;
temp:=gsx+temp4+gsy*maxx;
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
int $10
@nothing:
end;
mem[$a000:temp]:=spr.adr^[temp2]{mem[seg(spr.adr^):ofs(spr.adr^)+temp2]};
end;
end;
begin
end.






