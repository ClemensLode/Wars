{ttx, tty geht von "-max div 2" bis "max div 2"}
uses crt,vesa10,gif,dos,modexlib;
const max=40;
type eig=record
wait,wegp,phase,richtung,px,py,sx,sy,weglong,ax,ay,cx,cy,gx,gy:integer;
{newgo:boolean;}
end;
var karte:array[0..max,0..max] of record
ti,i:byte;
kx,ky:shortint;
end;
fauna:array[0..max,0..max] of byte;
www,ow:string;
leut:array[0..7,0..7] of spritetyp;
grass:array[0..4] of spritetyp;
leer,{baum,}hand,grid:spritetyp;
xx,yy,x2,y2,temp:integer;
x3,y3:word;
scrollx,scrolly,t1,t2,ttx,tty,x4,y4:longint;
weg:array[0..max*3] of record
kx,ky:shortint;
end;
a:char;
mp,mpx,sx,oox,ooy,omp:word;
feinx,feiny,te2,tempus,ooo,ooogx,fx,fy,ox,oy,bax,bay:integer;
spieler:eig;
procedure stop; {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
begin
spieler.cx:=spieler.ax;
spieler.cy:=spieler.ay;
spieler.sx:=spieler.ax;
spieler.sy:=spieler.ay;
fillchar(weg,sizeof(weg),0);
spieler.weglong:=0;
spieler.wegp:=0;
spieler.px:=0;
spieler.py:=0;
spieler.phase:=0;
end;
procedure stopgo;
begin
spieler.wait:=12;
end;
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
sound(1500);delay(10);nosound;
for x:=0 to max do for y:=0 to max do karte[x,y].ti:=karte[x,y].i;
karte[spieler.cx,spieler.cy].ti:=4;
karte[spieler.ax,spieler.ay].ti:=3;
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
getsprite(170*320,120,27,leer);
for x3:=0 to 7 do for y3:=0 to 4 do getsprite(x3*16+(y3*27)*320,16,27,leut[x3,y3]);
for x3:=0 to 7 do for y3:=0 to 2 do getsprite(x3*16+(y3*27)*320+127,16,27,leut[x3,y3+5]);
loadgif('d:\wars\ocean7');
show_pic13;
{getsprite(0+64*320,64,64,baum);}
getsprite(0+ 0*320,32,16,grass[0]);
getsprite(0+16*320,32,16,grass[1]);
getsprite(0+32*320,32,16,grass[2]);
getsprite(0+48*320,32,16,grass[3]);
getsprite(32+0*320,32,16,grass[4]);
getsprite(0+165*320,32,16,grid);
loadgif('d:\wars\font168.gif');
show_pic13;
getsprite(85*320,20,20,hand);
initfont(0,0,6,8);
initvesa($105);
asm mov ax,0;int $33;end;
x2:=maxx[akmodus]-40;y2:=maxy[akmodus]-40;
asm mov ax,7;mov cx,0;mov dx,x2;int $33;end;
asm mov ax,8;mov cx,1;mov dx,y2;int $33;end;
loadgif('d:\wars\ocean6');
randomize;
for x3:=0 to max do for y3:=0 to max do fauna[x3,y3]:=random(4);
spieler.ax:=random(max);
spieler.ay:=random(max);
spieler.sx:=spieler.ax;
spieler.sy:=spieler.ay;
spieler.cx:=random(max);
spieler.cy:=random(max);
for temp:=1 to max*30 do karte[random(max),random(max)].i:=0;
if findway=false then halt;
for xx:=0 to max do for yy:=0 to max do begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
if (x4>0) and (y4>=0) and (x4<950) and (y4<700) then begin
{if karte[xx,yy].i>0 then newput(x4+,y4,grass[karte[xx,yy].i mod 4]);}
{newput(x4,y4,grid);}
end;
end;
{x4:=spieler.ax*16-spieler.ay*16;
y4:=spieler.ax*8+spieler.ay*8;
newput(x4+,y4,grass[0]);
x4:=spieler.cx*16-spieler.cy*16;
y4:=spieler.cx*8+spieler.cy*8;
newput(x4+,y4,grass[0]);}
spieler.wegp:=0;
for xx:=0 to max do for yy:=0 to max do begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
if (x4>=0) and (y4>=0) and (x4<950) and (y4<700) then {begin}
newput(x4,y4,grass[random(4){fauna[xx,yy]]}]);
{newput(x4,y4,grid);
end;}
end;
for xx:=0 to max do for yy:=0 to max do begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
{if (x4>=-) and (y4>=0) and (x4<950-) and (y4<700) then
if karte[xx,yy].i>0 then newput(x4-16+,y4-56,baum);}
end;
repeat
oox:=bax;ooy:=bay;
ox:=fx;oy:=fy;
omp:=mp;
asm mov ax,3;int $33;mov fx,cx;mov fy,dx;mov mp,bx;end;
inc(bax,fx-ox);
inc(bay,fy-oy);

tempus:=bax mod 32;
te2:=bay mod 16+1;
feinx:=0;feiny:=0;
if te2<8 then begin
if tempus<te2*2 then feinx:=-1 else if tempus>32-te2*2 then feiny:=-1;
end else if te2>8 then begin
dec(te2,8);
if tempus<te2*2 then feiny:=1 else if tempus>32-te2*2 then feinx:=1;
end;
ttx:=feinx+bax div 32+bay div 16-scrollx;
tty:=feiny-bax div 32+bay div 16-scrolly;
{if ttx<scrollx then ttx:=scrollx;
if tty<scrolly then tty:=scrolly;
if ttx>max+scrollx then ttx:=max+scrollx;
if tty>max+scrolly then tty:=max+scrolly;}
t1:=(ttx+scrollx)*16-(tty+scrolly)*16;
t2:=(ttx+scrollx)*8+(tty+scrolly)*8;
if (t1>=0) and (t2>=0) and (t1<950) and (t2<700) then newput(t1,t2,grid);
putimage(oox,ooy);
getimage(bax,bay-1);
newput(bax,bay,hand);
if spieler.wegp>spieler.weglong+1 then begin
spieler.wegp:=0;
spieler.weglong:=0;
end;
a:=#0;
if keypressed then a:=readkey;
case a of
#13:stopgo;
#77:begin if scrollx>-max then dec(scrollx);if scrolly<max then inc(scrolly);end;
#75:begin if scrollx<max then inc(scrollx);if scrolly>-max then dec(scrolly);end;
#80:begin if scrolly>-max then dec(scrolly);if scrollx>-max then dec(scrollx);end;
#72:begin if scrolly<max then inc(scrolly);if scrollx<max then inc(scrollx);end;
end;
if ((a=#32) or ((omp=0) and (mp=1))) and (ttx>0) and (ttx<max) and (tty>0) and (tty<max)
and ((ttx<>spieler.cx) or (tty<>spieler.cy)) {and ((ttx<>spieler.ax) or (tty<>spieler.ay))}
then
if (karte[ttx,tty].i=0) then begin
{if (t1>=0) and (t2>=0) and (t1<950) and (t2<700) then newput(t1,t2,grid);}
sound(100);delay(150);nosound;
spieler.cx:=ttx {div 32};
spieler.cy:=tty {div 32};
{if spieler.weglong=0 then begin}
spieler.wegp:=0;
fillchar(weg,sizeof(weg),0);
sound(100);delay(10);nosound;
if findway=false then halt;
{end{ else
spieler.newgo:=true};

end else begin
newput(t1,t2,grass[2]);
{sound(100);delay(150);nosound;}end;


for xx:=0 to max do for yy:=0 to max do
begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
if (x4>=0) and (y4>=0) and (x4<950) and (y4<700) then begin
if (xx=0) or (xx=max) or (yy=0) or (yy=max) then
newput(x4,y4,grass[4]) else {begin}
newput(x4,y4,grass[fauna[xx,yy]]);
{if karte[xx,yy].i>0 then newput(x4+,y4,grass[random(4)]);}
{newput(x4,y4,grid);
end;}
end;
end;

spieler.richtung:=richtung(weg[spieler.wegp].kx,weg[spieler.wegp].ky);
x4:=(spieler.ax+scrollx)*16-(spieler.ay+scrolly)*16+spieler.px;
y4:=(spieler.ax+scrollx)*8+(spieler.ay+scrolly)*8+spieler.py;
if (x4>=-8) and (y4>=12) and (x4<950-8) and (y4<712) then begin
{newput(x4+,y4,grass[2]);}
newput(x4+8,y4-12,leut[spieler.phase mod 8,spieler.richtung mod 8]);
end;
waitretrace;
if spieler.weglong>0 then begin
{for xx:=0 to max do for yy:=0 to max do
begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
if (x4>=-) and (y4>=0) and (x4<950-) and (y4<700) then
if karte[xx,yy].i>0 then newput(x4-16+,y4-56,baum);
end;                                                   }
{if spieler.wait>0 then dec(spieler.wait) else begin}
inc(spieler.px,(weg[spieler.wegp].kx-weg[spieler.wegp].ky)*2);
inc(spieler.py,(weg[spieler.wegp].kx+weg[spieler.wegp].ky)*1);
inc(spieler.phase);
if spieler.phase>7 then spieler.phase:=0;
if (abs(spieler.px)+abs(spieler.py)*2)>32 then begin
spieler.px:=0;spieler.py:=0;
inc(spieler.ax,weg[spieler.wegp].kx);
inc(spieler.ay,weg[spieler.wegp].ky);
{if spieler.newgo then begin
spieler.wegp:=0;
fillchar(weg,sizeof(weg),0);
if findway=false then halt;
end else}
inc(spieler.wegp);
inc(spieler.px,(weg[spieler.wegp].kx-weg[spieler.wegp].ky)*2);
inc(spieler.py,(weg[spieler.wegp].kx+weg[spieler.wegp].ky)*1);
if (spieler.ax=spieler.cx) and (spieler.ay=spieler.cy) then begin
stop;
end;
{end;}
end;
end;
{readkey;}
newput(850,1,leer);
str(ttx,www);
www:=www+'   ';
str(tty,ow);
www:=www+ow;
wx:=900;
wy:=1;
writes(www);
until a=#27{keypressed;{temp>spieler.weglong};
readkey;
textmode(3);
end.