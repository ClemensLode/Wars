{Function Findway machen!!}
uses crt,vesa10,gif,dos,modexlib;
const max=23;
plus=500;
type eig=record
weglong,ax,ay,cx,cy,gx,gy:integer;
end;
var karte:array[0..max,0..max] of record
ti,i:byte;
kx,ky:shortint;
end;
grass:array[0..3] of spritetyp;
grid:spritetyp;
x2,y2,temp:integer;
weg:array[0..max] of record
kx,ky:shortint;
end;
spieler:eig;
function findway:boolean;
var mx,my,long,tx,ty,x,y,x1,y1,t1,t2:integer;
begin
for x:=0 to max do for y:=0 to max do karte[x,y].ti:=karte[x,y].i;
karte[spieler.cx,spieler.cy].ti:=4;
karte[spieler.ax,spieler.ay].ti:=3;
for long:=0 to max do begin
readkey;
for x:=0 to max do for y:=0 to max do begin
if karte[x,y].ti=10 then karte[x,y].ti:=3;
t1:=x*16-y*16;
t2:=x*8+y*8;
if (t1>=-plus) and (t2>=0) and (t1<950-plus) and (t2<700) then
if karte[x,y].ti>0 then newput(t1+plus,t2,grass[karte[x,y].ti mod 4]);
newput(t1+plus,t2,grid);
fenster2(0);
mem[$a000:x+y*1024]:=karte[x,y].ti;
end;
{for x:=0 to 199 do for y:=0 to 99 do begin
if karte[x,y].i=10 then karte[x,y].i:=3;
mem[$a000:x+y*320]:=karte[x,y].i;
end;}
sound(100);delay(10);nosound;
for x:=0 to max do for y:=0 to max do begin
if karte[x,y].ti=3 then begin
for mx:=-1 to 1 do for my:=-1 to 1 do if (x+mx>=0) and (y+my>=0) and (x+mx<=max) and (y+my<=max)
then begin
{mem[$a000:x+mx+(y+my)*320]:=5;}
if (karte[x+mx,y+my].ti=0) then begin
karte[x+mx,y+my].ti:=10;
karte[x+mx,y+my].kx:=mx;
karte[x+mx,y+my].ky:=my;
end;
if (karte[x+mx,y+my].ti=4) then begin {Da!}
karte[x+mx,y+my].kx:=mx;
karte[x+mx,y+my].ky:=my;
sound(1000);delay(50);nosound;
sound(750);delay(50);nosound;
sound(500);delay(50);nosound;
t1:=spieler.cx;
t2:=spieler.cy;
for tx:=long-1 downto 0 do begin
x1:=t1*16-t2*16;
y1:=t1*8+t2*8;
if (x1>=-plus) and (y1>=0) and (x1<950-plus) and (y1<700) then newput(x1+plus,y1,grass[2]);
weg[tx].kx:=karte[t1,t2].kx;
weg[tx].ky:=karte[t1,t2].ky;
dec(t1,weg[tx].kx);
dec(t2,weg[tx].ky);
end;
findway:=true;
spieler.weglong:=long;
readkey;
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
spieler.cx:=random(max);
spieler.cy:=random(max);
for temp:=1 to max*max div 2 do karte[random(max),random(max)].i:=1;
{karte[ax,ay].i:=3;
karte[cx,cy].i:=4;}
if findway=false then halt;
{repeat
inc(long);
for x:=0 to max do for y:=0 to max do begin
if karte[x,y].i=10 then karte[x,y].i:=3;
t1:=x*16-y*16;
t2:=x*8+y*8;
if (t1>=-plus) and (t2>=0) and (t1<950-plus) and (t2<700) then
if karte[x,y].i>0 then newput(t1+plus,t2,grass[karte[x,y].i mod 4]);
newput(t1+plus,t2,grid);
fenster2(0);
mem[$a000:x+y*1024]:=karte[x,y].i;
end;
{for x:=0 to 199 do for y:=0 to 99 do begin
if karte[x,y].i=10 then karte[x,y].i:=3;
mem[$a000:x+y*320]:=karte[x,y].i;
end;}
{sound(100);delay(10);nosound;
for x:=0 to max do for y:=0 to max do begin
if karte[x,y].i=3 then begin
for mx:=-1 to 1 do for my:=-1 to 1 do if (x+mx>=0) and (y+my>=0) and (x+mx<=max) and (y+my<=max)
then begin
{mem[$a000:x+mx+(y+my)*320]:=5;}
{if (karte[x+mx,y+my].i=0) then begin
karte[x+mx,y+my].i:=10;
karte[x+mx,y+my].kx:=mx;
karte[x+mx,y+my].ky:=my;
end;
if (karte[x+mx,y+my].i=4) then begin {Da!}
{fertig:=true;
karte[x+mx,y+my].kx:=mx;
karte[x+mx,y+my].ky:=my;
sound(1000);delay(50);nosound;
sound(750);delay(50);nosound;
sound(500);delay(50);nosound;
t1:=cx;
t2:=cy;
for tx:=long-1 downto 0 do begin
x1:=t1*16-t2*16;
y1:=t1*8+t2*8;
if (x1>=-plus) and (y1>=0) and (x1<950-plus) and (y1<700) then newput(x1+plus,y1,grass[2]);
weg[tx].kx:=karte[t1,t2].kx;
weg[tx].ky:=karte[t1,t2].ky;
dec(t1,weg[tx].kx);
dec(t2,weg[tx].ky);
end;
end;
end;
karte[ax,ay].i:=2;
end;
end;
until (readkey=#27) or fertig;}
textmode(3);
clrscr;
writeln('Start X :     ',spieler.ax:3,' Start Y : ',spieler.ay:3);
x2:=spieler.ax;
y2:=spieler.ay;
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