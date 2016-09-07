{Fehlt noch:
Reagieren auf besetztes Feld >> 2 Runden abwarten.
Keine Veraenderung >> Neuen Weg suchen
}

uses crt,vesa10,gif,dos,modexlib,go;
var
www,ow:string;
fauna:array[0..max,0..max] of byte;
leut:array[0..7,0..7] of spritetyp;
grass:array[0..4] of spritetyp;
leer,{baum,}hand,grid:spritetyp;
a:char;
ak,ts:byte;
ttx,tty:integer;
fx,fy,mp,mpx,sx,oox,ooy,omp:word;
feinx,feiny,te2,tempus,ooo,ooogx,ox,oy,bax,bay:longint;
t1,t2,x4,y4:longint;
begin
chdir('d:\wars');
init_mode13;
loadgif('drac5');
show_pic13;
for x3:=0 to 7 do for y3:=0 to 4 do getsprite(x3*16+(y3*27)*320,16,27,leut[x3,y3]);
for x3:=0 to 7 do for y3:=0 to 2 do getsprite(x3*16+(y3*27)*320+127,16,27,leut[x3,y3+5]);
getsprite(171*320,120,27,leer);
loadgif('ocean7');
show_pic13;
{getsprite(0+64*320,64,64,baum);}
getsprite(0+ 0*320,32,16,grass[0]);
getsprite(0+16*320,32,16,grass[1]);
getsprite(0+32*320,32,16,grass[2]);
getsprite(0+48*320,32,16,grass[3]);
getsprite(32+0*320,32,16,grass[4]);
getsprite(0+165*320,32,16,grid);
loadgif('font168');
show_pic13;
getsprite(85*320,20,20,hand);
initfont(0,0,6,8);
initvesa($105);
asm mov ax,0;int $33;end;
x2:=maxx[akmodus]-40;y2:=maxy[akmodus]-40;
asm mov ax,7;mov cx,0;mov dx,x2;int $33;end;
asm mov ax,8;mov cx,1;mov dx,y2;int $33;end;
loadgif('ocean6');
randomize;
for x3:=0 to max do for y3:=0 to max do fauna[x3,y3]:=random(4);
for temp:=1 to max*max div 2 do karte[random(max),random(max)].i:=0;
{for x3:=0 to max do karte[x3,0].i:=1;
for x3:=0 to max do karte[0,x3].i:=1;
for x3:=0 to max do karte[max,x3].i:=1;
for x3:=0 to max do karte[x3,max].i:=1;}
for x3:=0 to anzspieler do begin
spieler[x3]^.ax:=random(max);
spieler[x3]^.ay:=random(max);
spieler[x3]^.cx:=spieler[x3]^.ax;
spieler[x3]^.cy:=spieler[x3]^.ay;
x4:=random(max);
y4:=random(max);
karte[spieler[x3]^.ax,spieler[x3]^.ay].i:=0;
karte[x4,y4].i:=0;
stop(x3);
{if gotoxye(x3,x4,y4) then;}
test;
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
if spieler[ak]^.wegp>spieler[ak]^.weglong+1 then begin
spieler[ak]^.wegp:=0;
spieler[ak]^.weglong:=0;
end;
a:=#0;
if keypressed then a:=readkey;
case a of
'+':if ak<anzspieler then inc(ak) else ak:=0;
'-':if ak>0 then dec(ak) else ak:=anzspieler;
#77:begin if scrollx>-max then dec(scrollx);if scrolly<max then inc(scrolly);end;
#75:begin if scrollx<max then inc(scrollx);if scrolly>-max then dec(scrolly);end;
#80:begin if scrolly>-max then dec(scrolly);if scrollx>-max then dec(scrollx);end;
#72:begin if scrolly<max then inc(scrolly);if scrollx<max then inc(scrollx);end;
#13:stop(ak);
end;

if ((a=#32) or ((omp=0) and (mp=1))) then
if gotoxye(ak,ttx,tty)=false then begin
stop(ak);
sound(100);delay(100);nosound;
end;
for xx:=0 to max do for yy:=0 to max do
begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
if (x4>=0) and (y4>=0) and (x4<950) and (y4<700) then begin
if (xx=0) or (xx=max) or (yy=0) or (yy=max) then
newput(x4,y4,grass[4]) else {begin}
newput(x4,y4,grass[fauna[xx,yy]]);
if karte[xx,yy].i>0 then newput(x4,y4,grass[4]);
{newput(x4,y4,grid);
end;}
end;
end;
newput(850,0,leer);
str(spieler[ak]^.ax,www);
www:=www+'   ';
str(spieler[ak]^.ay,ow);
www:=www+ow;
wx:=900;
wy:=1;
writes(www);
newput(850,9,leer);
str(spieler[ak]^.px,www);
www:=www+'   ';
str(spieler[ak]^.py,ow);
www:=www+ow;
wx:=900;
wy:=10;
writes(www);
newput(850,18,leer);
str(spieler[ak]^.cx,www);
www:=www+'   ';
str(spieler[ak]^.cy,ow);
www:=www+ow;
wx:=900;
wy:=19;
writes(www);
newput(850,28,leer);
str(spieler[ak]^.wegp,www);
www:=www+'   ';
str(spieler[ak]^.phase,ow);
www:=www+ow;
wx:=900;
wy:=29;
writes(www);
for ts:=0 to anzspieler do begin
{spieler[ts]^.richtung:=richtung(spieler[ts]^.weg[spieler[ts]^.wegp].kx,spieler[ts]^.weg[spieler[ts]^.wegp].ky);}
x4:=(spieler[ts]^.ax+scrollx)*16-(spieler[ts]^.ay+scrolly)*16+spieler[ts]^.px;
y4:=(spieler[ts]^.ax+scrollx)*8+(spieler[ts]^.ay+scrolly)*8+spieler[ts]^.py;
if (x4>-8) and (y4>12) and (x4<950-8) and (y4<712) then
newput(x4+8,y4-12,leut[1{spieler[ts]^.phase mod 8},1{spieler[ts]^.richtung mod 8}]);
if spieler[ts]^.weglong>0 then schritt(ts);
end;
until (a=#27) or ende;
a:=readkey;
textmode(3);
for x3:=0 to anzspieler do begin
a:=readkey;
clrscr;
for y3:=0 to spieler[x3]^.weglong do writeln(spieler[x3]^.weg[y3].kx,'          ',spieler[x3]^.weg[y3].ky);
writeln(spieler[x3]^.weglong);
end;
readln;
end.