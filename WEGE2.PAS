uses crt,vesa6,modexlib,gif;
const wegex=30;
rand=1;
hauses=20;
type eig=record
px,py,cx,cy,x,y,gx,gy:integer;
r,goha:byte;
bau:boolean;
aphase:shortint;
end;
haus=record
x,y,
bphase,aphase,
art:byte;
end;
var strasse:byte;
{maus:spritetyp;}
i,mp,mx,my:word;
leut:array[0..7,0..7] of spritetyp;
grass:array[0..3] of spritetyp;
s:array[1..21] of spritetyp;
leer:spritetyp;
a:char;
wahl,ccd:byte;
tax,tay:shortint;
tt:file;
ax,ay:integer;
spieler:array[1..4] of eig;
ttx,tty,j,k,zzz:word;
hauser:array[1..hauses] of haus;
karte:array[0..wegex+1,0..wegex+1] of record
s:byte;
haus:byte;
end;



{Noch machen : Merken wo schon gewesen!}



{Durch das Strassenwegsystem vereinfacht sich die Bewegung:

Eine eins oder hoeher in der Variable "Karte" bedeutet, dass dort eine Strasse steht.

1: Strasse nach oben/unten
2: Strasse nach links/rechts
3: Strasse gedreht unten/links
4: Strasse gedreht links/oben
5: Strasse gedreht oben/rechts
6: Strasse gedreht rechts/unten
7: Kreuzung unten/links/oben
8: Kreuzung links/oben/rechts
9: Kreuzung oben/rechts/unten
10:Kreuzung rechts/unten/links
11:Kreuzung unten/rechts/oben/links
12:Strassenanfang unten
13:Strassenanfang links
14:Strassenanfang oben
15:Strassenanfang rechts



Also in cx und cy stehen die Zielkoordinaten. In einem Strassensystem verfolgt
der Doerfler immer den moeglichst direkten Weg. In einem unuebersichtlichen
System mit vielen Sackgassen, werden sich die Bewohner nicht zurechtfinden.
Sobald der Doerfler bemerkt, dass er sich viel weiter von seinem Ziel entfernt,
wird er umkehren.
Der Doerfler aendert seine Richtung erst an Kreuzungen oder an Sackgassen.}

procedure bau;
begin
if karte[ttx,tty].s>0 then exit;
spieler[wahl].bau:=true;
spieler[wahl].cx:=ttx;
spieler[wahl].cy:=tty;
end;


procedure gotoxye(xx,yy:word);
begin
spieler[wahl].bau:=false;
spieler[wahl].cx:=xx;
spieler[wahl].cy:=yy;
{spieler[wahl].px:=16;
spieler[wahl].py:=8;}
end;



procedure bgohaus(num:byte;var spiel:eig);
begin
spiel.cx:=hauser[num].x;
spiel.cy:=hauser[num].y;
spiel.goha:=num;
end;
procedure kreuzung(strasse:byte;var x,y,gx,gy,cx,cy:integer;r:byte);
begin
if (x=cx) and (y=cy) then begin gx:=0;gy:=0;exit;end;
case strasse of
1:begin gx:=0;if gy=0 then if y>cy then gy:=-1 else gy:=1;end;
2:begin gy:=0;if gx=0 then if x>cx then gx:=-1 else gx:=1;end;
3:if gx=1  then begin gx:=0;gy:=1;end
  else  if gy=-1 then begin gy:=0;gx:=-1;end;{ else begin

                            {Fehler ?!}
4:if gx=1  then begin gx:=0;gy:=-1;end
  else  if gy=1 then begin gy:=0;gx:=-1;end;
5:if gy=1  then begin gy:=0;gx:=1;end
  else  if gx=-1 then begin gy:=-1;gx:=0;end;
6:if gx=-1  then begin gx:=0;gy:=1;end
  else  if gy=-1 then begin gy:=0;gx:=1;end;
7:if x<cx then begin
if (gy=0) and (gx=1) then begin gx:=0;if (y<cy) then gy:=1 else gy:=-1;end;end else
if (gy=-1) and (gx=0) then begin gx:=-1;gy:=0;end else
if (x>cx) and (gx=0) then begin gx:=-1;gy:=0;end else begin gx:=0;if y<cy then gy:=1 else gy:=-1;end;
8:if x<cx then begin
if (gy=1) and (gx=0) then begin gy:=0;gx:=1;end else if gx=-1 then begin gx:=0;gy:=-1;end;
end else if x>cx then begin
if (gy=1) and (gx=0) then begin gy:=0;gx:=-1;end else if gx=-1 then begin gx:=0;gy:=-1;end;
end;
9:if x<=cx then begin
if (gy=0) and (gx=-1) then begin gx:=0;if y<cy then gy:=1 else gy:=-1;end;end else
if (x>cx) and (gx=0) then begin gy:=0;gx:=1;end else if (gx=-1) then begin gx:=0;if y<cy then gy:=1 else gy:=-1;end;
10:if x<cx then begin
if (gy=1) and (gx=0) then begin gy:=0;gx:=1;end else if gx=-1 then begin gx:=0;gy:=1;end;
end else if x>cx then begin
if (gy=1) and (gx=0) then begin gy:=0;gx:=-1;end else if gx=-1 then begin gx:=0;gy:=1;end;
end;
11:if x>cx then gx:=-1 else if x<cx then gx:=1 else begin gx:=0;if y>cy then gy:=-1 else gy:=1;end;
{if (x<cx) and (gx=-1) then begin gx:=0;if (y<cy) then gy:=1 else gy:=-1;end else
if (x<cx) and (gx=0) then begin gy:=0;gx:=1;end else
if (x>cx) and (gx=1) then begin gx:=0;if (y<cy) then gy:=1 else gy:=-1;end else
if (x>cx) and (gx=0) then begin gy:=0;gx:=-1;end;
{if x<cx then begin
if (gy=0) and (gx=1) then begin gx:=0;if y<cy then gy:=1 else gy:=-1;end else
if (x>cx) and (gx=0) then gx:=-1 else begin gx:=0;if y<cy then gy:=1 else gy:=-1;end;
end;}
12:begin gx:=0;gy:=1;end;
13:begin gy:=0;gx:=-1;end;
14:begin gx:=0;gy:=-1;end;
15:begin gy:=0;gx:=1;end;
end;
end;


begin
init_mode13;
loadgif('d:\wars\drac5');
show_pic13;
{getsprite(1+0*52+(2+0*62)*320,51,61,leut[0,1]);
getsprite(1+0*52+(1+1*62)*320,51,61,leut[1,1]);
getsprite(1+0*52+(1+2*62)*320,51,61,leut[2,1]);
getsprite(1+1*52+(1+0*62)*320,51,61,leut[3,1]);
getsprite(1+1*52+(1+1*62)*320,51,61,leut[4,1]);
getsprite(1+1*52+(1+2*62)*320,51,61,leut[5,1]);
getsprite(1+2*52+(1+0*62)*320,51,61,leut[6,1]);}
for ax:=0 to 7 do for ay:=0 to 4 do getsprite(ax*16+(ay*27)*320,16,27,leut[ax,ay]);
for ax:=0 to 7 do for ay:=0 to 2 do getsprite(ax*16+(ay*27)*320+127,16,27,leut[ax,ay+5]);
getsprite(280,16,27,leer);
loadgif('ocean4');
show_pic13;
getsprite(128+ 0*320,64,32,grass[0]);
getsprite(128+32*320,64,32,grass[1]);
getsprite(128+64*320,64,32,grass[2]);
getsprite(128+96*320,64,32,grass[3]);

loadgif('kwege5');
show_pic13;
getsprite(0+0*320,32,16,s[7]);
getsprite(0+16*320,32,16,s[8]);
getsprite(0+32*320,32,16,s[9]);
getsprite(0+48*320,32,16,s[10]);
getsprite(32+0*320,32,16,s[11]);
getsprite(64+0*320,32,16,s[2]);
getsprite(64+16*320,32,16,s[1]);
getsprite(96+0*320,32,16,s[14]);
getsprite(96+16*320,32,16,s[15]);
getsprite(96+32*320,32,16,s[13]);
getsprite(96+48*320,32,16,s[12]);
getsprite(128+0*320,32,16,s[3]);
getsprite(128+16*320,32,16,s[4]);
getsprite(128+32*320,32,16,s[5]);
getsprite(128+48*320,32,16,s[6]);
getsprite(160+0*320,32,16,s[16]);
getsprite(160+16*320,32,16,s[17]);
getsprite(160+32*320,32,16,s[18]);
getsprite(160+48*320,32,16,s[19]);
getsprite(0+112*320,32,16,s[21]);
spieler[1].goha:=10;
{loadgif('d:\wars\baums4.gif');
show_pic13;
getsprite(0+0*320,32,70,s[20]);}
{loadgif('d:\wars\mhaus!.gif');
show_pic13;
getsprite(0+0*320,70,50,s[20]);}
{loadgif('font168.gif');
show_pic13;
getsprite(0+85*320,20,20,maus);}
initvesa($105);
loadgif('d:\wars\drac4');
repeat
inc(i);
for ax:=0 to 7 do begin putpasc(ax*16,0,leer);waitretrace;putpasc(ax*16,0,leut[i mod 8,ax]);end;
until keypressed;
randomize;
spieler[1].cx:=wegex;spieler[1].cy:=wegex;
spieler[1].gx:=1;spieler[1].gy:=0;
spieler[1].x:=rand;spieler[1].y:=rand;

spieler[2].cx:=wegex;spieler[2].cy:=rand;
spieler[2].gx:=0;spieler[2].gy:=-1;
spieler[2].x:=rand;spieler[2].y:=wegex-rand;

spieler[3].cx:=rand;spieler[3].cy:=wegex;
spieler[3].gx:=0;spieler[3].gy:=1;
spieler[3].x:=wegex-rand;spieler[3].y:=rand;

spieler[4].cx:=rand;spieler[4].cy:=rand;
spieler[4].gx:=-1;spieler[4].gy:=0;
spieler[4].x:=wegex-rand;spieler[4].y:=wegex-rand;

for ax:=1 to hauses do begin
hauser[ax].x:=ax;
hauser[ax].y:=ax;
end;

for ax:=1 to hauses do karte[hauser[ax].x,hauser[ax].y].haus:=0;
for ax:=1 to wegex do for ay:=1 to wegex do if karte[ax,ay].haus=2 then begin
karte[ax+1,ay].haus:=1;karte[ax,ay+1].haus:=1;
karte[ax,ay].haus:=1;karte[ax+1,ay+1].haus:=1;
end;
for ax:=1 to wegex do for ay:=1 to wegex do if random(2)=0 then karte[ax,ay].s:=1 else karte[ax,ay].s:=random(2);
for ax:=1 to wegex do for ay:=1 to wegex do begin
if karte[ax,ay].haus>0 then karte[ax,ay].s:=0;
if karte[ax,ay].s>0 then begin
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=11 else
if (karte[ax+1,ay].s=0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=7 else
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s=0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=8 else
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s=0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=9 else
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s=0) then karte[ax,ay].s:=10 else
if (karte[ax+1,ay].s=0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s=0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=1 else
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s=0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s=0) then karte[ax,ay].s:=2 else
if (karte[ax+1,ay].s=0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s=0) then karte[ax,ay].s:=3 else
if (karte[ax+1,ay].s=0) and (karte[ax,ay+1].s=0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=4 else
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s=0) and (karte[ax-1,ay].s=0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=5 else
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s=0) and (karte[ax,ay-1].s=0) then karte[ax,ay].s:=6 else
if (karte[ax+1,ay].s=0) and (karte[ax,ay+1].s>0) and (karte[ax-1,ay].s=0) and (karte[ax,ay-1].s=0) then karte[ax,ay].s:=12 else
if (karte[ax+1,ay].s=0) and (karte[ax,ay+1].s=0) and (karte[ax-1,ay].s>0) and (karte[ax,ay-1].s=0) then karte[ax,ay].s:=13 else
if (karte[ax+1,ay].s=0) and (karte[ax,ay+1].s=0) and (karte[ax-1,ay].s=0) and (karte[ax,ay-1].s>0) then karte[ax,ay].s:=14 else
if (karte[ax+1,ay].s>0) and (karte[ax,ay+1].s=0) and (karte[ax-1,ay].s=0) and (karte[ax,ay-1].s=0) then karte[ax,ay].s:=15 else
karte[ax,ay].s:=0;
end;
end;
for ax:=0 to wegex do for ay:=0 to wegex do begin
putpasc(maxx[akmodus] shr 1+ax*32-ay*32,maxy[akmodus] shr 2+ax*16+ay*16,grass[random(4)]);
if karte[ax,ay].s>0 then
putpasc(maxx[akmodus] shr 1+ax*16-ay*16,maxy[akmodus] shr 2+ax*8+ay*8,s[karte[ax,ay].s]);
if (karte[ax,ay].haus=1) and (karte[ax+1,ay].haus=1) and (karte[ax,ay+1].haus=1) and (karte[ax+1,ay+1].haus=1) then begin
karte[ax,ay].haus:=2;karte[ax+1,ay].haus:=2;
karte[ax,ay+1].haus:=2;karte[ax+1,ay+1].haus:=2;
putpasc(-19+maxx[akmodus] shr 1+ax*16-ay*16,-17+maxy[akmodus] shr 2+ax*8+ay*8,s[20]);
end;
end;
{asm mov ax,0;int $33;end;
j:=maxx[akmodus];k:=maxy[akmodus];
asm mov ax,7;mov cx,0;mov dx,j;int $33;end;
asm mov ax,8;mov cx,0;mov dx,k;int $33;end;}
{for tax:=1 to wegex do for tay:=1 to wegex do begin
putpasc(maxx[akmodus] shr 1+tax*16-tay*16,maxy[akmodus] shr 2+tax*8+tay*8,
grass[random(4)]);
if karte[tax,tay].s>0 then
putpasc(maxx[akmodus] shr 1+tax*16-tay*16,maxy[akmodus] shr 2+tax*8+tay*8,
s[karte[tax,tay].s]);
end;}
repeat
delay(100);
{for ax:=1 to wegex do for ay:=1 to wegex do
if karte[ax,ay]>0 then
putpasc(maxx[akmodus] shr 1+ax*16-ay*16,maxy[akmodus] shr 2+ax*8+ay*8,s[karte[ax,ay]]);}
{case karte[ax,ay] of
1:write(#179);
2:write(#196);
3:write(#191);
4:write(#217);
5:write(#192);
6:write(#218);
7:write(#180);
8:write(#193);
9:write(#195);
10:write(#194);
11:write(#197);
12:write(#24);
13:write(#26);
14:write(#25);
15:write(#27);
end;
end;}
for ax:=1 to 4 do begin
if spieler[ax].gx=1 then spieler[ax].r:=1;
if spieler[ax].gy=-1 then spieler[ax].r:=3;
if spieler[ax].gx=-1 then spieler[ax].r:=7;
if spieler[ax].gy=1 then spieler[ax].r:=5;
{inc(spieler[ax].px,spieler[ax].gx);inc(spieler[ax].py,spieler[ax].gy);}
{if karte[spieler[ax].x,spieler[ax].y].s>0 then
putpasc(maxx[akmodus] shr 1+spieler[ax].x*16-spieler[ax].y*16,maxy[akmodus] shr 2+spieler[ax].x*8+spieler[ax].y*8,
s[karte[spieler[ax].x,spieler[ax].y].s]);}
if (spieler[ax].x<>spieler[ax].cx) or (spieler[ax].y<>spieler[ax].cy) then begin
inc(spieler[ax].aphase);
if spieler[ax].aphase>7 then spieler[ax].aphase:=0;
end;
{kreuzung(karte[spieler[ax].x,spieler[ax].y].s,spieler[ax].x,spieler[ax].y,spieler[ax].gx,
spieler[ax].gy,spieler[ax].cx,spieler[ax].cy,spieler[ax].r);}
{spieler[ax].r:=1;spieler[ax].gx:=1;spieler[ax].gy:=0;

{inc(spieler[ax].px,spieler[ax].gx*2-spieler[ax].gy*2);
inc(spieler[ax].py,spieler[ax].gy+spieler[ax].gx);}
{spieler[ax].px:=
(spieler[ax].aphase)*spieler[ax].gx*2-
(spieler[ax].aphase)*spieler[ax].gy*2+8;
spieler[ax].py:=
(spieler[ax].aphase)*spieler[ax].gy+
(spieler[ax].aphase)*spieler[ax].gx-19;}
{kreuzung(karte[spieler[ax].x,spieler[ax].y].s,spieler[ax].x,spieler[ax].y,spieler[ax].gx,
spieler[ax].gy,spieler[ax].cx,spieler[ax].cy,spieler[ax].r);}

inc(spieler[ax].px,spieler[ax].gx*2-spieler[ax].gy*2);
inc(spieler[ax].py,spieler[ax].gx+spieler[ax].gy);

putpasc(maxx[akmodus] shr 1+spieler[ax].x*16-spieler[ax].y*16+spieler[ax].px+8,spieler[ax].py+
maxy[akmodus] shr 2+spieler[ax].x*8+spieler[ax].y*8-19,leut[abs(spieler[ax].aphase),spieler[ax].r]);

if (abs(spieler[ax].px)>=16) or (abs(spieler[ax].py)>=8) then begin
if (spieler[ax].x<wegex) and (spieler[ax].x>0) then inc(spieler[ax].x,spieler[ax].gx);
if (spieler[ax].y<wegex) and (spieler[ax].y>0) then inc(spieler[ax].y,spieler[ax].gy);
kreuzung(karte[spieler[ax].x,spieler[ax].y].s,spieler[ax].x,spieler[ax].y,spieler[ax].gx,
spieler[ax].gy,spieler[ax].cx,spieler[ax].cy,spieler[ax].r);
spieler[ax].px:=-spieler[ax].gx*16;spieler[ax].py:=-spieler[ax].gy*8;
end;

{inc(spieler[ax].py,spieler[ax].gx+spieler[ax].gy);
inc(spieler[ax].px,spieler[ax].gx*2-spieler[ax].gy*2);
putpasc(maxx[akmodus] shr 1+spieler[ax].x*16-spieler[ax].y*16+spieler[ax].px+8,spieler[ax].py+
maxy[akmodus] shr 2+spieler[ax].x*8+spieler[ax].y*8-19,
leut[abs(spieler[ax].aphase+3),spieler[ax].r]);
if spieler[ax].aphase>3 then begin
spieler[ax].px:=16*spieler[ax].gy+16*spieler[ax].gx-16;
spieler[ax].py:=8*spieler[ax].gy-8*spieler[ax].gx-8;
spieler[ax].aphase:=-4;
if spieler[ax].x<wegex then inc(spieler[ax].x,spieler[ax].gx);
if spieler[ax].y<wegex then inc(spieler[ax].y,spieler[ax].gy);
kreuzung(karte[spieler[ax].x,spieler[ax].y].s,spieler[ax].x,spieler[ax].y,spieler[ax].gx,
spieler[ax].gy,spieler[ax].cx,spieler[ax].cy,spieler[ax].r);
{if karte[spieler[ax].x,spieler[ax].y].s>0 then
{putpasc(maxx[akmodus] shr 1+spieler[ax].x*16-spieler[ax].y*16,maxy[akmodus] shr 2+spieler[ax].x*8+spieler[ax].y*8,
s[karte[spieler[ax].x,spieler[ax].y].s]);}
if (spieler[ax].x=spieler[ax].cx) and (spieler[ax].y=spieler[ax].cy) then begin
spieler[ax].gx:=0;spieler[ax].gy:=0;
spieler[ax].px:=16;spieler[ax].py:=8;
{for zzz:=1 to ax do begin sound(zzz*100);delay(10);nosound;end;}
end;
if spieler[ax].bau then begin
if (spieler[ax].x+2>spieler[ax].cx) and (spieler[ax].x-2<spieler[ax].cx) and
   (spieler[ax].y+2>spieler[ax].cy) and (spieler[ax].y-2<spieler[ax].cy) then begin
karte[ttx,ay].s:=1;
for tax:=-1 to 1 do for tay:=-1 to 1 do begin
if karte[ttx+tax,tty+tay].s>0 then begin
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=11 else
if (karte[ttx+tax+1,tty+tay].s=0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=7 else
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s=0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=8 else
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s=0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=9 else
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s=0) then karte[ttx+tax,tty+tay].s:=10 else
if (karte[ttx+tax+1,tty+tay].s=0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s=0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=1 else
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s=0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s=0) then karte[ttx+tax,tty+tay].s:=2 else
if (karte[ttx+tax+1,tty+tay].s=0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s=0) then karte[ttx+tax,tty+tay].s:=3 else
if (karte[ttx+tax+1,tty+tay].s=0) and (karte[ttx+tax,tty+tay+1].s=0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=4 else
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s=0) and (karte[ttx+tax-1,tty+tay].s=0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=5 else
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s=0) and
(karte[ttx+tax,tty+tay-1].s=0) then karte[ttx+tax,tty+tay].s:=6 else
if (karte[ttx+tax+1,tty+tay].s=0) and (karte[ttx+tax,tty+tay+1].s>0) and (karte[ttx+tax-1,tty+tay].s=0) and
(karte[ttx+tax,tty+tay-1].s=0) then karte[ttx+tax,tty+tay].s:=12 else
if (karte[ttx+tax+1,tty+tay].s=0) and (karte[ttx+tax,tty+tay+1].s=0) and (karte[ttx+tax-1,tty+tay].s>0) and
(karte[ttx+tax,tty+tay-1].s=0) then karte[ttx+tax,tty+tay].s:=13 else
if (karte[ttx+tax+1,tty+tay].s=0) and (karte[ttx+tax,tty+tay+1].s=0) and (karte[ttx+tax-1,tty+tay].s=0) and
(karte[ttx+tax,tty+tay-1].s>0) then karte[ttx+tax,tty+tay].s:=14 else
if (karte[ttx+tax+1,tty+tay].s>0) and (karte[ttx+tax,tty+tay+1].s=0) and (karte[ttx+tax-1,tty+tay].s=0) and
(karte[ttx+tax,tty+tay-1].s=0) then karte[ttx+tax,tty+tay].s:=15 else
karte[ttx+tax,tty+tay].s:=0;
end;
end;

spieler[ax].bau:=false;
spieler[ax].cx:=spieler[ax].x;spieler[ax].cy:=spieler[ax].y;


end;
end;
{spieler[ax].old[6].x:=spieler[ax].old[5].x;
spieler[ax].old[6].y:=spieler[ax].old[5].y;
spieler[ax].old[5].x:=spieler[ax].old[4].x;
spieler[ax].old[5].y:=spieler[ax].old[4].y;
spieler[ax].old[4].x:=spieler[ax].old[3].x;
spieler[ax].old[4].y:=spieler[ax].old[3].y;
spieler[ax].old[3].x:=spieler[ax].old[2].x;
spieler[ax].old[3].y:=spieler[ax].old[2].y;
spieler[ax].old[2].x:=spieler[ax].old[1].x;
spieler[ax].old[2].y:=spieler[ax].old[1].y;
spieler[ax].old[1].x:=spieler[ax].x;
spieler[ax].old[1].y:=spieler[ax].y;}
{end;}
end;
if keypressed then begin a:=readkey;if a=#0 then a:=readkey;
case a of
'+':bgohaus(spieler[wahl].goha+1,spieler[wahl]);
'-':bgohaus(spieler[wahl].goha-1,spieler[wahl]);
#75:dec(ttx);
#77:inc(ttx);
#72:dec(tty);
#80:inc(tty);
#13:bau;
'q':begin if wahl>1 then dec(wahl) else wahl:=4;putpasc(0,0,s[wahl+15]);end;
'w':begin if wahl<4 then inc(wahl) else wahl:=1;putpasc(0,0,s[wahl+15]);end;
end;
{asm mov ax,3;int $33;mov mx,cx;mov my,dx;mov mp,bx;end;
{putpasc(mx,my,maus);
{if mp>0 then begin mp:=0;}
{ttx:=-((mx-maxx[akmodus] shr 1) div 16)+(my-maxx[akmodus] shr 2) div 8;
=tty:=(mx-maxx[akmodus] shr 1) div 16+(my-maxx[akmodus] shr 2) div 8;}
end;
if a=#32 then begin gotoxye(ttx,tty);
{kreuzung(karte[spieler[ax].x,spieler[ax].y].s,spieler[ax].x,spieler[ax].y,spieler[ax].gx,
spieler[ax].gy,spieler[ax].cx,spieler[ax].cy,spieler[ax].r);}
end;
a:=#0;

putpasc(maxx[akmodus] shr 1+ttx*16-tty*16,maxy[akmodus] shr 2+ttx*8+tty*8,s[21]);
until a=#27;
end.

