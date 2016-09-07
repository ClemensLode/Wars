uses crt,dos;
type
  RealRegs = record
    EDI: Longint;
    ESI: Longint;
    EBP: Longint;
    Reserved: Longint;
    EBX: Longint;
    EDX: Longint;
    ECX: Longint;
    EAX: Longint;
    Flags: Word;
    ES: Word;
    DS: Word;
    FS: Word;
    GS: Word;
    IP: Word;
    CS: Word;
    SP: Word;
    SS: Word;
  end;
var sel,i:word;
feh,interupt:byte;selekes,Offsdi,stack:word;
r:realregs;
r2:registers;
function Getselector(segment:word):word;
var help:word;
begin
asm mov ax,2;mov bx,segment;int $31;mov help,ax;end;getselector:=help;
end;
function inter(nummer:byte):byte;
var fehler:byte;
begin
fehler:=0;
asm
mov ax,$0300;
mov bh,0;
mov bl,nummer
mov es,selekes
mov di,offsdi
int $31
jnc @001
mov fehler,1
@001:nop;
end;
inter:=fehler;
end;
begin
writeln(maxavail div 1024,' KB Speicher verfuegbar !!!');
readkey;
asm
mov ax,$13;
int $10;
end;
for i:=1 to 64000 do memw[sega000:i]:=i;
readkey;
textmode(3);
end.
