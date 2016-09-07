unit GO2;
interface
const max=50;
type eig=record
wait,wegp,phase,richtung,px,py,sx,sy,weglong,ax,ay,cx,cy,gx,gy:integer;
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
spieler:^eig;
function findway(num:byte):boolean;  {Veraendert Inhalt der Variable spieler[num]}
function richtung(gox,goy:shortint):byte;{Konvertiert einen Vektor in eine Richtung}
procedure stop(num:byte); {Setzt alle Laufvariablen von spieler[num] auf 0}
procedure schritt(num:byte); {Erhoeht die die Laufvariablen von spieler[num]}
function gotoxye(num,gox,goy:byte):boolean; {Versucht das Ziel von spieler[num] auf gox,goy zu setzen}
implementation
function findway(num:byte):boolean;
var mx,my,long,tx,ty,x,y,x1,y1,t3,t4:integer;
begin
for x:=0 to max do for y:=0 to max do karte[x,y].ti:=karte[x,y].i;
karte[spieler^.cx,spieler^.cy].ti:=4;
karte[spieler^.ax,spieler^.ay].ti:=3;
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
t3:=spieler^.cx;
t4:=spieler^.cy;
for tx:=long downto 0 do begin
spieler^.weg[tx].kx:=karte[t3,t4].kx;
spieler^.weg[tx].ky:=karte[t3,t4].ky;
dec(t3,spieler^.weg[tx].kx);
dec(t4,spieler^.weg[tx].ky);
end;
findway:=true;
spieler^.weglong:=long;
exit;
end;
end;
karte[x,y].ti:=1;
end;
end;
end;
findway:=false;
end;

function richtung(gox,goy:shortint):byte;
begin
case gox of
-1:case goy of
   -1:richtung:=4;
    0:richtung:=7;
    1:richtung:=6;
   end;
 0:case goy of
   -1:richtung:=5;
    1:richtung:=3;
   end;
 1:case goy of
   -1:richtung:=2;
    0:richtung:=1;
    1:richtung:=0;
   end;
end;
end;

procedure stop(num:byte);
begin
spieler^.cx:=spieler^.ax;
spieler^.cy:=spieler^.ay;
spieler^.sx:=spieler^.ax;
spieler^.sy:=spieler^.ay;
fillchar(spieler^.weg,sizeof(spieler^.weg),0);
spieler^.weglong:=0;
spieler^.wegp:=0;
spieler^.px:=0;
spieler^.py:=0;
spieler^.phase:=0;
end;

procedure schritt(num:byte);
begin
inc(spieler^.px,(spieler^.weg[spieler^.wegp].kx-spieler^.weg[spieler^.wegp].ky)*2);
inc(spieler^.py,(spieler^.weg[spieler^.wegp].kx+spieler^.weg[spieler^.wegp].ky)*1);
inc(spieler^.phase);
if spieler^.phase>7 then spieler^.phase:=0;
if (abs(spieler^.px)+abs(spieler^.py)*2)>32 then begin
spieler^.px:=0;spieler^.py:=0;
inc(spieler^.ax,spieler^.weg[spieler^.wegp].kx);
inc(spieler^.ay,spieler^.weg[spieler^.wegp].ky);
inc(spieler^.wegp);
inc(spieler^.px,(spieler^.weg[spieler^.wegp].kx-spieler^.weg[spieler^.wegp].ky)*2);
inc(spieler^.py,(spieler^.weg[spieler^.wegp].kx+spieler^.weg[spieler^.wegp].ky)*1);
if (spieler^.ax=spieler^.cx) and (spieler^.ay=spieler^.cy) then stop(num);
end;
end;

function gotoxye(num,gox,goy:byte):boolean;
begin
if (gox>0) and (gox<max) and (goy>0) and (goy<max) and ((gox<>spieler^.cx) or (goy<>spieler^.cy))
and (karte[gox,goy].i=0) then begin
stop(num);
spieler^.cx:=gox;
spieler^.cy:=goy;
if findway(num)=false then stop(num);
end;
end;


begin
getmem(spieler,sizeof(spieler));
end.