uses crt,vesa10,gif,dos,modexlib;
const max=30;
plus=500;
type eig=record
phase,richtung,px,py,sx,sy,weglong,ax,ay,cx,cy,gx,gy:integer;
end;
var karte:array[0..max,0..max] of record
ti,i:byte;
kx,ky:shortint;
end;
leut:array[0..7,0..7] of spritetyp;
grass:array[0..3] of spritetyp;
grid:spritetyp;
xx,yy,x2,y2,temp:integer;
weg:array[0..max] of record
kx,ky:shortint;
end;
spieler:eig;
function richtung(gox,goy:integer):byte;
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
function findway:boolean;
var mx,my,long,tx,ty,x,y,x1,y1,t1,t2:integer;
begin
for x:=0 to max do for y:=0 to max do karte[x,y].ti:=karte[x,y].i;
karte[spieler.cx,spieler.cy].ti:=4;

karte[spieler.ax,spieler.ay].ti:=3;
for long:=0 to max do begin
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
t1:=spieler.cx;
t2:=spieler.cy;
for tx:=long downto 0 do begin
weg[tx].kx:=karte[t1,t2].kx;
weg[tx].ky:=karte[t1,t2].ky;
dec(t1,weg[tx].kx);
dec(t2,weg[tx].ky);
end;
findway:=true;
spieler.weglong:=long;
exit;
end;
end;
karte[x,y].ti:=1;
end;
end;
end;
findway:=false;
end;
begin
init_mode13;
loadgif('d:\wars\drac5');
show_pic13;
 for x2:=0 to 7 do for y2:=0 to 4 do getsprite(x2*16+(y2*27)*320,16,27,leut[x2,y2]);
for x2:=0 to 7 do for y2:=0 to 2 do getsprite(x2*16+(y2*27)*320+127,16,27,leut[x2,y2+5]);
loadgif('d:\wars\ocean6');
show_pic13;
getsprite(0+ 0*320,32,16,grass[0]);
getsprite(32+0*320,32,16,grass[1]);
getsprite(64+0*320,32,16,grass[2]);
getsprite(0+48*320,32,16,grass[3]);
getsprite(0+165*320,32,16,grid);
initvesa($105);
loadgif('d:\wars\ocean6');
randomize;
spieler.ax:=random(max);
spieler.ay:=random(max);
spieler.sx:=spieler.ax;
spieler.sy:=spieler.ay;
spieler.cx:=random(max);
spieler.cy:=random(max);
for temp:=1 to max*max div 2 do karte[random(max),random(max)].i:=1;
if findway=false then halt;
for xx:=0 to max do for yy:=0 to max do begin
x2:=xx*16-yy*16;
y2:=xx*8+yy*8;
if (x2>=-plus) and (y2>=0) and (x2<950-plus) and (y2<700) then
if karte[xx,yy].i>0 then newput(x2+plus,y2,grass[karte[xx,yy].i mod 4]);
newput(x2+plus,y2,grid);
end;
{x2:=spieler.ax*16-spieler.ay*16;
y2:=spieler.ax*8+spieler.ay*8;
newput(x2+plus,y2,grass[0]);
x2:=spieler.cx*16-spieler.cy*16;
y2:=spieler.cx*8+spieler.cy*8;
newput(x2+plus,y2,grass[0]);}
temp:=0;
repeat
for xx:=0 to max do for yy:=0 to max do begin
x2:=xx*16-yy*16;
y2:=xx*8+yy*8;
if (x2>=-plus) and (y2>=0) and (x2<950-plus) and (y2<700) then
if karte[xx,yy].i>0 then newput(x2+plus,y2,grass[0]) else newput(x2+plus,y2,grass[1]);
newput(x2+plus,y2,grid);
end;
spieler.richtung:=richtung(weg[temp].kx,weg[temp].ky);
x2:=spieler.ax*16-spieler.ay*16+spieler.px;
y2:=spieler.ax*8+spieler.ay*8+spieler.py;
newput(x2+plus+8,y2-9,leut[spieler.phase,spieler.richtung]);
inc(spieler.px,(weg[temp].kx-weg[temp].ky)*2);
inc(spieler.py,(weg[temp].kx+weg[temp].ky)*1);
inc(spieler.phase);
if spieler.phase>7 then spieler.phase:=0;
if (abs(spieler.px)+abs(spieler.py)*2)>=32 then begin
spieler.px:=0;spieler.py:=0;
inc(spieler.ax,weg[temp].kx);
inc(spieler.ay,weg[temp].ky);
inc(temp);
end;
{readkey;}
until temp>spieler.weglong;
readkey;
textmode(3);
clrscr;
writeln('Start X :     ',spieler.sx:3,' Start Y : ',spieler.sy:3);
x2:=spieler.sx;
y2:=spieler.sy;
for temp:=0 to spieler.weglong do begin
inc(x2,weg[temp].kx);
inc(y2,weg[temp].ky);
write('Weg ',temp:3,' : ');
if weg[temp].kx>0 then write('+',weg[temp].kx:2,' ',x2:3,'      ') else write(weg[temp].kx:3,'  ',x2:3,'      ');
if weg[temp].ky>0 then writeln('+',weg[temp].ky:2,' ',y2:3) else writeln(weg[temp].ky:3,'  ',y2:3);
end;
writeln('Ziel  X :     ',spieler.cx:3,' Ziel  Y : ',spieler.cy:3);
readln;
end.