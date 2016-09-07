{Problem:

Mit einem einzigen Spieler klappts wunderbar
mit mehr aber nicht.
Grund:Routinen des einen Spielers veraendern auch Variablen anderer Spieler!!

}
unit GO;
interface
uses crt;
const max=10;
anzspieler=1;
type eig=record
wait,wegp,phase,richtung,px,py,weglong,ax,ay,cx,cy:longint;
weg:array[0..max*3] of record
kx,ky:shortint;
end;
end;
var karte:array[0..max,0..max] of record
ti,i:byte;
kx,ky:shortint;
end;
xx,yy,x2,y2,temp:integer;
x3,y3:word;
scrollx,scrolly:longint;
ende:boolean;
spieler:array[0..anzspieler] of ^eig;
function findway(num1:longint):boolean;  {Veraendert Inhalt der Variable spieler[num]}
function richtung(ggox,ggoy:shortint):byte;{Konvertiert einen Vektor in eine Richtung}
procedure stop(num2:byte); {Setzt alle Laufvariablen von spieler[num] auf 0}
procedure schritt(num3:byte); {Erhoeht die die Laufvariablen von spieler[num]}
function gotoxye(num4:byte;gox,goy:integer):boolean;
procedure test;
implementation
procedure test;
var bui,hui:longint;
begin
for bui:=0 to anzspieler do for hui:=0 to spieler[bui]^.weglong do
if not ((spieler[bui]^.weg[hui].kx>=-1) and (spieler[bui]^.weg[hui].kx<=1) and
(spieler[bui]^.weg[hui].ky>=-1) and (spieler[bui]^.weg[hui].ky<=1)) then begin
sound(200);delay(500);nosound;
ende:=true;
end;
end;
function findway(num1:longint):boolean;
var mx,my,long,tx,ty,x,y,x1,y1,t3,t4:integer;
begin
for x:=0 to max do for y:=0 to max do begin
karte[x,y].ti:=0{karte[x,y].i};
karte[x,y].kx:=0;
karte[x,y].ky:=0;
end;
karte[spieler[num1]^.cx,spieler[num1]^.cy].ti:=4;
karte[spieler[num1]^.ax,spieler[num1]^.ay].ti:=3;
for long:=0 to max*3 do begin
for x:=0 to max do for y:=0 to max do if karte[x,y].ti=10 then karte[x,y].ti:=3;
for x:=0 to max do for y:=0 to max do begin
if karte[x,y].ti=3 then begin
for mx:=-1 to 1 do for my:=-1 to 1 do if (x+mx>=0) and (y+my>=0) and (x+mx<=max) and (y+my<=max)
then begin
if (karte[x+mx,y+my].ti=0) then begin
karte[x+mx,y+my].ti:=10;
karte[x+mx,y+my].kx:=mx;
karte[x+mx,y+my].ky:=my;
end;
if (karte[x+mx,y+my].ti=4) then begin {Da!}
karte[x+mx,y+my].kx:=mx;
karte[x+mx,y+my].ky:=my;
t3:=spieler[num1]^.cx;
t4:=spieler[num1]^.cy;
for tx:=long downto 0 do begin
spieler[num1]^.weg[tx].kx:=karte[t3,t4].kx;
spieler[num1]^.weg[tx].ky:=karte[t3,t4].ky;
dec(t3,spieler[num1]^.weg[tx].kx);
dec(t4,spieler[num1]^.weg[tx].ky);
end;
spieler[num1]^.weglong:=long;
findway:=true;
test;
exit;
end;
end;
karte[x,y].ti:=1;
end;
end;
end;
findway:=false;
end;

function richtung(ggox,ggoy:shortint):byte;
var point:byte;
begin
point:=0;
case ggox of
-1:case ggoy of
   -1:point:=4;
    0:point:=7;
    1:point:=6;
   end;
 0:case ggoy of
   -1:point:=5;
    1:point:=3;
   end;
 1:case ggoy of
   -1:point:=2;
    0:point:=1;
    1:point:=0;
   end;
end;
richtung:=point;
end;

procedure stop(num2:byte);
var tx:word;
begin
spieler[num2]^.cx:=spieler[num2]^.ax;
spieler[num2]^.cy:=spieler[num2]^.ay;
for tx:=0 to max*3 do begin
spieler[num2]^.weg[tx].kx:=0;
spieler[num2]^.weg[tx].ky:=0;
end;
spieler[num2]^.weglong:=0;
spieler[num2]^.wegp:=0;
spieler[num2]^.px:=0;
spieler[num2]^.py:=0;
spieler[num2]^.phase:=0;
end;

procedure schritt(num3:byte);
begin
inc(spieler[num3]^.px,(spieler[num3]^.weg[spieler[num3]^.wegp].kx-spieler[num3]^.weg[spieler[num3]^.wegp].ky)*2);
inc(spieler[num3]^.py,(spieler[num3]^.weg[spieler[num3]^.wegp].kx+spieler[num3]^.weg[spieler[num3]^.wegp].ky)*1);
inc(spieler[num3]^.phase);
if spieler[num3]^.phase>7 then spieler[num3]^.phase:=0;
if (abs(spieler[num3]^.px)+abs(spieler[num3]^.py)*2)>32 then begin
spieler[num3]^.px:=0;spieler[num3]^.py:=0;
inc(spieler[num3]^.ax,spieler[num3]^.weg[spieler[num3]^.wegp].kx);
inc(spieler[num3]^.ay,spieler[num3]^.weg[spieler[num3]^.wegp].ky);
inc(spieler[num3]^.wegp);
inc(spieler[num3]^.px,(spieler[num3]^.weg[spieler[num3]^.wegp].kx-spieler[num3]^.weg[spieler[num3]^.wegp].ky)*2);
inc(spieler[num3]^.py,(spieler[num3]^.weg[spieler[num3]^.wegp].kx+spieler[num3]^.weg[spieler[num3]^.wegp].ky)*1);
if (spieler[num3]^.ax=spieler[num3]^.cx) and (spieler[num3]^.ay=spieler[num3]^.cy) then stop(num3);
end;
end;

function gotoxye(num4:byte;gox,goy:integer):boolean;
begin
if (gox>0) and (gox<max) and (goy>0) and (goy<max) and ((gox<>spieler[num4]^.cx) or (goy<>spieler[num4]^.cy))
and (karte[gox,goy].i=0) then begin
stop(num4);
spieler[num4]^.cx:=gox;
spieler[num4]^.cy:=goy;
gotoxye:=findway(num4);
end else gotoxye:=false;
end;


begin
for x3:=0 to anzspieler do getmem(spieler[x3],sizeof(spieler[x3]));
end.