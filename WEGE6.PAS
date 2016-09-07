uses crt,vesa10,modexlib,gif,dos;
const
randr=1001;
randu=600;
maxscroll=100;
anzspieler=12;
rand=2;
hauses=5;
staedtenamen:array[1..hauses] of string[12]=('Gareth','Thorwal','Punin','Anchopal','Winhall');
maxsch=5;
hg=11;
hfenstsize=450;
sfenstsize=370;
feldx:shortint=64;
feldy:shortint=32;
type eig=record
longw,wegp,dx,dy,px,py,cx,cy,x,y:integer;
gx,gy:shortint;
weg:array[1..100] of record
wx,wy:shortint;
end;
hunger:shortint;
oa,om,auge,mund,r,goha:byte;
dead,bau:boolean;
aphase:shortint;
rucksack:byte;
end;
haus=record
owner,vorrat,
x,y,
bphase,aphase,
art:byte;
end;
var zent,ttt,strasse:byte;
rain:array[0..7] of spritetyp;
pilze:array[0..3,0..3] of spritetyp;
tulpe:spritetyp;
blume:array[1..4] of spritetyp;
k1,k2,k3,k4,rahmoben,rahmunten,rahmlinks,rahmrechts:spritetyp;
paint:boolean;
scrollx,scrolly:word;
swx,swy:word;
race,tempus,te2:byte;
feinx,feiny:shortint;
filled:boolean;
mine:array[0..3,0..2] of spritetyp;
rahm:spritetyp;
mark:spritetyp;
hand:array[0..2,0..3] of spritetyp;
bar:array[0..22] of spritetyp;
klicked:array[0..maxsch,0..6,0..3] of record
name:string[17];
on:boolean;
end;
zufall:word;
besx:array[0..5] of word;
fauna:array[0..maxscroll+1,0..maxscroll+1] of byte;
ax,ay,tx,ty:integer;
i,mp,mx,my:word;
{leer:spritetyp;}
names:string;
leut:array[0..7,0..7] of spritetyp;
grass:array[0..3] of spritetyp;
s:array[1..21] of spritetyp;
ani:array[0..7] of spritetyp;
stemp,stemp2:string;
a:char;
pur,wahl,ccd:byte;
tax,tay:shortint;
tt:file;
ttx,tty,t1,t2,vax,vay:integer;
lax,lay:longint;
temper:array[1..hauses] of byte;
spieler:array[1..anzspieler] of ^eig;
j,k,zzz:word;
hauser:array[0..hauses] of haus;
karte:array[0..maxscroll+1,0..maxscroll+1] of record
s:byte;
haus:byte;
end;
marked:array[1..anzspieler] of byte;
mo,kl,lk,menuleiste:boolean;
ll,poskartex,poskartey:byte;
mpx,sx,oox,ooy,omp:word;
ooo,ooogx,fx,fy,ox,oy,bax,bay:integer;
di,zoom,det,fast:shortint;
done:byte;
t3:word;

procedure findway(num:word);
var long:word;
weg:array[1..100] of record
wx,wy:shortint;
end;
eweg:array[1..100] of record
wx,wy:shortint;
end;
zax,zay,ctax,ctay,tcx,tcy,ttax,ttay,tax,tay:integer;
ekarte:array[0..maxscroll+1,0..maxscroll+1] of record
wx,wy:shortint;
i:byte;
end;
begin
for tax:=0 to maxscroll+1 do for tay:=0 to maxscroll+1 do
if (fauna[tax,tay]<4) or (karte[tax,tay].haus>0) then ekarte[tax,tay].i:=1 else ekarte[tax,tay].i:=0;
zax:=spieler[num]^.x;
zay:=spieler[num]^.y;
ekarte[zax,zay].wx:=zax;
ekarte[zax,zay].wy:=zay;
tcx:=spieler[num]^.cx;
tcy:=spieler[num]^.cy;
ekarte[zax,zay].i:=3;
repeat
inc(long);
for tax:=1 to maxscroll do for tay:=1 to maxscroll do if ekarte[tax,tay].i=3 then begin
for ttax:=tax-1 to tax+1 do for ttay:=tay-1 to tay+1 do begin
if ekarte[ttax,ttay].i=0 then begin
ekarte[ttax,ttay].i:=4;
t1:=(ttax-scrollx)*16-(ttay-scrolly)*16;
t2:=(ttax-scrollx)*8+(ttay-scrolly)*8;
if (t1>=32) and (t2>=32) and (t1+32<randr) and (t2+32<randu) then
newput(t1,t2,leut[1,1]);
ekarte[ttax,ttay].wx:=tax;
ekarte[ttax,ttay].wy:=tay;
end;
end;
if (tcx=tax) and (tcy=tay) then begin
ctax:=tax;
ctay:=tay;
for tax:=long downto 1 do begin
ttax:=ekarte[ctax,ctay].wx;
ttay:=ekarte[ctax,ctay].wy;
weg[tax].wx:=ttax;
weg[tax].wy:=ttay;
ctax:=ttax;
ctay:=ttay;
end;
ttax:=weg[1].wx;ttay:=weg[1].wy;
for tax:=1 to long do begin eweg[tax].wx:=weg[tax].wx-weg[tax-1].wx;eweg[tax].wy:=weg[tax].wy-weg[tax-1].wy;end;
eweg[1].wx:=0;
eweg[1].wy:=0;
move(eweg,weg,100);
tax:=0;
spieler[num]^.gx:=weg[2].wx;
spieler[num]^.gy:=weg[2].wy;
spieler[num]^.wegp:=2;
move(weg,spieler[num]^.weg,sizeof(weg));
spieler[num]^.longw:=long;
exit;
end;
ekarte[tax,tay].i:=2;      {War schon da...}
end;
for tax:=1 to maxscroll do for tay:=1 to maxscroll do
if ekarte[tax,tay].i=4 then ekarte[tax,tay].i:=3; {Alle in neuaktiven in aktive verwandeln}
until long>(abs(tcx-zax)+abs(tcy-zay))*4;
spieler[num]^.longw:=0;
spieler[num]^.gx:=0;spieler[num]^.gy:=0;
fillchar(spieler[num]^.weg,sizeof(spieler[num]^.weg),0);
end;
procedure center(ex,ey:word);
begin
scrollx:=ex;
scrolly:=ey;
end;

procedure markx(ex,ey:word);
var marker:word;
begin
marker:=0;
for t3:=1 to anzspieler do marked[t3]:=0;
for t3:=1 to anzspieler do with spieler[t3] ^do begin
t1:=(x-scrollx)*16-(y-scrolly)*16+px+8;
t2:=(x-scrollx)*8+(y-scrolly)*8+py+2;
if ((ex-8<t1) and (ex+8>t1) and (ey-14<t2) and (ey+14>t2)) or
((t1-8<ex) and (t2-14<ey) and (t1+8>swx) and (t2+14>swy)) then {Im Rahmen}
begin
inc(marker);
marked[marker]:=t3;
end;
end;
end;

procedure menu;
var t:byte;s:string;
begin
 if filled=false then begin fill;filled:=true;end;
 case fast of
 -1:begin klicked[1,1,1].on:=true;klicked[1,1,3].on:=false;klicked[1,1,2].on:=false;end;
 0:begin klicked[1,1,2].on:=true;klicked[1,1,3].on:=false;klicked[1,1,1].on:=false;end;
 1:begin klicked[1,1,3].on:=true;klicked[1,1,2].on:=false;klicked[1,1,1].on:=false;end;
 end;
 case det of
 -1:begin klicked[1,2,1].on:=true;klicked[1,2,3].on:=false;klicked[1,2,2].on:=false;end;
 0:begin klicked[1,2,2].on:=true;klicked[1,2,3].on:=false;klicked[1,2,1].on:=false;end;
 1:begin klicked[1,2,3].on:=true;klicked[1,2,2].on:=false;klicked[1,2,1].on:=false;end;
 end;
 case zoom of
 -1:begin klicked[1,3,1].on:=true;klicked[1,3,3].on:=false;klicked[1,3,2].on:=false;end;
 0:begin klicked[1,3,2].on:=true;klicked[1,3,3].on:=false;klicked[1,3,1].on:=false;end;
 1:begin klicked[1,3,3].on:=true;klicked[1,3,2].on:=false;klicked[1,3,1].on:=false;end;
 end;
 k:=0;ll:=0;
 for j:=0 to maxsch do begin
 s:=klicked[j,0,0].name;
{  if ord(klicked[j,0].name[0])>9 then }sx:=schalt2x{ else sx:=schaltx};
{  tx:=besx[j];}
  ty:=25;
if klicked[j,0,0].on then begin
  if (bax>besx[j]) and (bax<besx[j]+sx) and (bay>ty) and (bay<ty+schalty) then begin
  if mpx=1 then begin klicked[j,0,0].on:=false;kl:=true;end;
  click(besx[j],ty,3,s);end else
  click(besx[j],ty,1,s);
  end else
  if (bax>besx[j]) and (bax<besx[j]+sx) and (bay>ty) and (bay<ty+schalty) then begin
   if (mpx=1) then begin
    click(besx[j],ty,3,s);
    for t:=0 to maxsch do klicked[t,0,0].on:=false;
    klicked[j,0,0].on:=true;kl:=true;
   end else
   click(besx[j],ty,2,s);
  end else click(besx[j],ty,0,s);
 end;

for j:=0 to maxsch do begin
 if klicked[j,0,0].on then
 for k:=1 to 6 do begin
  for ll:=0 to 3 do if (klicked[j,k,0].on) or (ll=0) then begin
   s:=klicked[j,k,ll].name;
   if s='' then continue;
   {if ord(klicked[j,k].name[0])>9 then }sx:=schalt2x{ else sx:=schaltx};
   ty:=(k)*schalty+25;
   if ll>0 then tx:=ll*sx+100 else tx:=0;
{   if ll=0 then tx:=besx[j] else tx:=besx[j]+100+ll*sx;}
   if klicked[j,k,ll].on then begin
    if (bax>besx[j]+tx) and (bax<besx[j]+sx+tx) and (bay>ty) and (bay<ty+schalty) then begin
     if mpx=1 then klicked[j,k,ll].on:=false;
     click(besx[j]+tx,ty,3,s);
    end else
    click(besx[j]+tx,ty,1,s);
   end else
   if (bax>besx[j]+tx) and (bax<besx[j]+tx+sx) and (bay>ty) and (bay<ty+schalty) then begin
    if (mpx=1) then begin
     click(besx[j]+tx,ty,3,s);
     klicked[j,k,ll].on:=true;
    end else
    click(besx[j]+tx,ty,2,s);
   end else click(besx[j]+tx,ty,0,s);
 {click(besx[j],(k+2)*schalty+25,0,klicked[j,k].name);}
end;
end;
end;
mpx:=0;
end;
procedure putzeit;
var zeits:string;
h,m,s,hu:word;
begin
aktab:=2;
{wx:=fenstera[1].x+117;wy:=fenstera[1].y+75;}
gettime(h,m,s,hu);
str(h,stemp);zeits:=stemp+' ';
str(m,stemp);zeits:=zeits+stemp+' ';
str(s,stemp);zeits:=zeits+stemp;
writes(zeits);
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

{procedure bau;
begin
if karte[ttx,tty].s>0 then exit;
spieler[wahl]^.bau:=true;
spieler[wahl]^.cx:=ttx;
spieler[wahl]^.cy:=tty;
end;}

procedure bgohaus(num:byte;var spiel:eig);
begin
if num<=hauses then spiel.goha:=num else exit;
spiel.dx:=spiel.cx;spiel.dy:=spiel.cy;
spiel.cx:=hauser[num].x;
spiel.cy:=hauser[num].y;
end;
procedure suchwasser(num:byte);
var hoch,wer,entf,entx,enty,zahl:byte;
{choose:array[1..3] of byte;}
begin
{zahl:=0;
{Abchecken aller wasserfuehrenden Gebaeude/Plaetzen in der Naehe}
{if (spieler[num].goha>0) or (spieler[num].hunger>0) then exit;}
{for i:=1 to hauses do with hauser[i] do begin
if vorrat>2 then begin inc(zahl);temper[zahl]:=i;end;
end;}
for i:=1 to hauses do with hauser[i] do begin
if x>y then entf:=x+y div 4 else entf:=y+x div 4;
if entf<hoch then begin
wer:=i;
hoch:=entf;
end;
end;
spieler[num]^.goha:=i;
spieler[num]^.cx:=hauser[i].x;
spieler[num]^.cy:=hauser[i].y;
findway(num);
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
if (gy=-1) and (gx=0) then begin if x>cx then begin gy:=0;gx:=-1;end;end else
if (gy=1) and (gx=0) then begin if x>cx then begin  gy:=0;gx:=-1;end;end else
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
if (gy=-1) and (gx=0) then begin gy:=0;gx:=1;end else if gx=-1 then begin gx:=0;gy:=1;end;
end else if x>cx then begin
if (gy=-1) and (gx=0) then begin gy:=0;gx:=-1;end else if gx=-1 then begin gx:=0;gy:=1;end;
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
if (abs(gx)>0) and (abs(gy)>0) then begin gx:=0;gy:=0;end;
end;
procedure gotoxye(xx,yy:word);
begin
for t3:=1 to anzspieler do if marked[t3]>0 then with spieler[marked[t3]]^ do begin
cx:=xx;cy:=yy;
findway(marked[t3]);
end;

{if karte[xx,yy].haus>0 then bgohaus(karte[xx,yy].haus,spieler[marked[t3]]^);
goha:=0;
bau:=false;
cx:=xx;
cy:=yy;
if xx>x then gx:=1;
if xx=x then gx:=0;
if xx<x then gx:=-1;
if yy>y then gy:=1;
if yy=y then gy:=0;
if yy>y then gy:=-1;
kreuzung(karte[x,y].s,x,y,gx,gy,cx,cy,r);
{spieler[wahl].px:=16;
spieler[wahl].py:=8;
end;}
end;
var y1,                         {y-Position Copper 1}
    y1_dir:integer;                     {y-Richtung Copper 1}
    Maske:Word;                 {Overlay-Maske, fÅr öberlagerung der Copper}

Procedure MakeCopper(y_pos1,y_pos2,overlay_maske:word);external;
{$l copper}

begin
  y1:=Port[$3da];               {ATC in Index-Mode schalten}
  Port[$3c0]:=$11 or 32;        {Register 11h wÑhlen}
  Port[$3c0]:=255;              {Rahmenfarbe 255}
  y1:=0;                        {Start am oberen Bildschirmrand}
  y1_dir:=5;                    {Bewegung zunÑchst nach unten}
  Maske:=$0000;                 {zunÑchst Copper 1 (rot) im Vordergrund}
clrscr;
textcolor(green);
write('                       Willkommen zur Demo von ');textcolor(yellow+blink);writeln('WARS!');
textcolor(green);
writeln;
writeln(' Diese Version darf frei weitergegeben werden, wobei jedoch darauf zu achten');
writeln(' ist, dass das Programm im vollen Umfang und unveraendert weitergegeben');
writeln(' wird.');
writeln;
writeln(' Um dieses Programm auszufuehren benoetigen sie eine VESA- kompatible');
writeln(' Grafikkarte, eine Maus, eine Tastatur und einen schnellen PC. Um die maximale');
write(' Performance zu erreichen, sollte das Programm ');
textcolor(red+blink);write('NICHT');textcolor(green);writeln(' unter Windows95(TM) laufen!');
writeln;
writeln(' Nun aber der Worte genug! Im Spiel mit kann man mit <SHIFT>+<A> das Menue');
writeln(' aktivieren.');
writeln(' Viel Spass beim Testen!');
writeln;
textcolor(white);
writeln(' Neue Demos zu WARS! finden Sie unter HTTP://HOME.ALLGAEU.ORG/CLODE');
textcolor(yellow+blink);
writeln(' Taste...');
chdir('d:\wars');
    repeat
    Inc(y1,y1_dir);If (y1<=0) or (y1>=300) then y1_dir:=-y1_dir;
    MakeCopper(y1,300-y1,maske);{Copper zeichnen}
  Until KeyPressed;
readkey;
for i:=1 to anzspieler do getmem(spieler[i],sizeof(spieler[i]));
besx[0]:=25;
besx[1]:=25+schalt2x;
besx[2]:=25+2*schalt2x;
besx[3]:=25+3*schalt2x;
besx[4]:=25+4*schalt2x;
besx[5]:=25+5*schalt2x;

klicked[0,0,0].name:='Diskette';
klicked[0,1,0].name:='Speichern';
klicked[0,2,0].name:='Laden';
klicked[0,3,0].name:='Ende';
klicked[0,3,1].name:='Aufgabe';
klicked[0,3,2].name:='Hauptmenue';
klicked[0,3,3].name:='DOS';
klicked[0,4,0].name:='';
klicked[0,5,0].name:='';
klicked[0,6,0].name:='';

klicked[1,0,0].name:='Spiel';
klicked[1,1,0].name:='Geschwindigkeit';
klicked[1,1,1].name:='Sehr langsam';
klicked[1,1,2].name:='normale Ges.';
klicked[1,1,3].name:='Sehr Schnell';
klicked[1,2,0].name:='Detailstufe';
klicked[1,2,1].name:='Keine Details';
klicked[1,2,2].name:='Wenige Details';
klicked[1,2,3].name:='Alle Details';
klicked[1,3,0].name:='Zoomstufe';
klicked[1,3,1].name:='Nah';
klicked[1,3,2].name:='Normale Zoomstufe';
klicked[1,3,3].name:='Fern';
klicked[1,4,0].name:='Musik';
klicked[1,5,0].name:='Punkteuebersicht';
klicked[1,6,0].name:='Rasse';
klicked[1,6,1].name:='Mensch';
klicked[1,6,2].name:='Ork';
klicked[1,6,3].name:='Echse';

klicked[2,0,0].name:='Computer';
klicked[2,1,0].name:='Lautstaerke';
klicked[2,1,1].name:='aus';
klicked[2,1,2].name:='normal';
klicked[2,1,3].name:='laut';
klicked[2,2,0].name:='Helligkeit';
klicked[2,2,1].name:='hell';
klicked[2,2,2].name:='normal';
klicked[2,2,3].name:='dunkel';
klicked[2,3,0].name:='Grafikaufloesung';
klicked[2,3,1].name:='640*480';
klicked[2,3,2].name:='800*600';
klicked[2,3,3].name:='1024*768';
klicked[2,4,0].name:='Fenstergroesse';
klicked[2,4,1].name:='320*200';
klicked[2,4,2].name:='640*400';
klicked[2,4,3].name:='800*600';
klicked[2,5,0].name:='';
klicked[2,6,0].name:='';

klicked[3,0,0].name:='Staedte';
klicked[3,1,0].name:='Stadtuebersicht';
klicked[3,2,0].name:='Stadt finden';
klicked[3,2,1].name:='Nummer ';
klicked[3,3,0].name:='Feindstaedte';
klicked[3,4,0].name:='';
klicked[3,5,0].name:='';
klicked[3,6,0].name:='';

klicked[4,0,0].name:='Wirtschaft';
klicked[4,1,0].name:='Karawanen';
klicked[4,2,0].name:='Handel';
klicked[4,3,0].name:='Transporte';
klicked[4,4,0].name:='Steuern';
klicked[4,5,0].name:='';
klicked[4,6,0].name:='';

klicked[5,0,0].name:='Rohstoffe';
klicked[5,1,0].name:='Rohstofflagerung';
klicked[5,2,0].name:='Rohstoffvorkommen';
klicked[5,3,0].name:='Rohstoffgebaeude';
klicked[5,4,0].name:='';
klicked[5,5,0].name:='';
klicked[5,6,0].name:='';
init_mode13;
loadgif('pilze4');
show_pic13;
for lax:=0 to 3 do getsprite(lax*16,32,16,pilze[lax,0]);
for lax:=0 to 3 do getsprite(lax*16+16*320,32,16,pilze[lax,1]);
for lax:=0 to 3 do getsprite(lax*16+32*320,32,16,pilze[lax,2]);
for lax:=0 to 3 do getsprite(lax*16+48*320,32,16,pilze[lax,3]);
loadgif('drac5');
show_pic13;
for lax:=0 to 7 do for lay:=0 to 4 do getsprite(lax*16+(lay*27)*320,16,27,leut[lax,lay]);
for lax:=0 to 7 do for lay:=0 to 2 do getsprite(lax*16+(lay*27)*320+127,16,27,leut[lax,lay+5]);
for lax:=0 to 22 do getsprite(lax+lax*4+140*320+20,4,23,bar[22-lax]);
getsprite(140*320,18,28,mark);

{loadgif('d:\wars\!drac1');show_pic13;
for lax:=0 to 7 do for lay:=0 to 2 do getsprite(lax*40+(lay*60)*320,40,64,leut[lax,lay]);
loadgif('d:\wars\!drac2');show_pic13;
for lax:=0 to 7 do for lay:=0 to 2 do getsprite(lax*16+(lay*27)*320,4027,leut[lax,lay+3]);
loadgif('d:\wars\!drac3');show_pic13;
for lax:=0 to 7 do getsprite(lax*40+(lay*60)*320,40,60,leut[lax,7]);}

{getsprite(160*320,120,27,leer);}
{loadgif('ocean6');
show_pic13;
getsprite(32+ 0*320,32,16,grass[0]);
getsprite(32+16*320,32,16,grass[1]);
getsprite(32+32*320,32,16,grass[2]);
getsprite(32+48*320,32,16,grass[3]);}
loadgif('ocean6');
show_pic13;
getsprite(0+ 0*320,32,16,grass[0]);
getsprite(0+16*320,32,16,grass[1]);
getsprite(0+32*320,32,16,grass[2]);
getsprite(0+48*320,32,16,grass[3]);
getsprite(0+64*320,64,64,blume[1]);
getsprite(64+64*320,64,64,blume[2]);
getsprite(128+64*320,64,64,blume[3]);
getsprite(192+64*320,64,64,blume[4]);
getsprite(320*136,5,5,tulpe);
for lax:=0 to 7 do getsprite(256+(lax mod 2)*32+((lax div 2)*16)*320,32,16,rain[lax]);

loadgif('mine');
show_pic13;
for lax:=0 to 3 do for lay:=0 to 2 do
getsprite(lax*32+lay*32*320,32,32,mine[lax,lay]);
getsprite(148*320,52,52,rahm);
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
{loadgif('d:\wars\baums4.gif');
show_pic13;
getsprite(0+0*320,32,70,s[20]);}
loadgif('mhaus!.gif');
show_pic13;
getsprite(0+0*320,70,50,s[20]);
loadgif('font169.gif');
show_pic13;
for ax:=0 to 7 do getsprite(ax*33+33+182*320,32,16,ani[ax]);

getsprite(85*320,20,20,hand[0,0]);
getsprite(20+85*320,20,20,hand[0,1]);
getsprite(40+85*320,20,20,hand[0,2]);
getsprite(60+85*320,20,20,hand[0,3]);

getsprite(80+85*320,20,20,hand[1,0]);
getsprite(100+85*320,20,20,hand[1,1]);
getsprite(120+85*320,20,20,hand[1,2]);
getsprite(140+85*320,20,20,hand[1,3]);

getsprite(160+85*320,20,20,hand[2,0]);
getsprite(180+85*320,20,20,hand[2,1]);
getsprite(200+85*320,20,20,hand[2,2]);
getsprite(220+85*320,20,20,hand[2,3]);
aktab:=0;
poskartex:=30;poskartey:=30;
initfont(0,0,6,8);
aktab:=1;
initfont(0,17,6,8);
aktab:=2;
initfont(0,108,12,16);
initschalt(0,33);
{loadgif('font168.gif');
show_pic13;
getsprite(0+85*320,20,20,maus);}
loadgif('rahm10');
show_pic13;
getsprite(32,248,16,rahmoben);
getsprite(32+15*320,248,16,rahmunten);
getsprite(0+32*320,16,98,rahmlinks);
getsprite(16+32*320,16,98,rahmrechts);
getsprite(0,16,16,k1);
getsprite(16,16,16,k2);
getsprite(16*320,16,16,k3);
getsprite(16+16*320,16,16,k4);
initvesa($105);
loadgif('drac5');
for i:=1 to anzspieler do marked[i]:=0;
{wahl:=1;}
randomize;
{repeat
inc(ax);newput(random(1024),random(768),schalt[random(7)]);
until ax=10000;}

{repeat
inc(i);
for ax:=0 to 7 do begin {newput(ax*16,0,leer);waitretrace;newput(ax*16,0,leut[i mod 8,ax]);end;
until keypressed;}
asm mov ax,0;int $33;end;
j:=maxx[akmodus]-41;k:=maxy[akmodus]-41;
asm mov ax,7;mov cx,0;mov dx,j;int $33;end;
asm mov ax,8;mov cx,1;mov dx,k;int $33;end;
for ax:=1 to anzspieler do with spieler[ax] ^do begin
cx:=random(maxscroll-2*rand)+rand;cy:=random(maxscroll-2*rand)+rand;
x:=maxscroll div 2;y:=maxscroll div 2;
{
x:=random(maxscroll-2*rand)+rand;y:=random(maxscroll-2*rand)+rand;}
gx:=0;gy:=0;
dead:=false;
spieler[ax]^.hunger:=120;
auge:=random(3);
mund:=random(4);
end;
umhell:=-4;
{for ax:=1 to hauses-1 do begin
hauser[ax].x:=spieler[ax]^.x;
hauser[ax].y:=spieler[ax]^.y;
hauser[ax].vorrat:=255;
end;
ax:=hauses;
hauser[ax].x:=maxscroll div 2;
hauser[ax].y:=maxscroll div 2;
hauser[ax].vorrat:=200;}

for ax:=1 to hauses do karte[hauser[ax].x,hauser[ax].y].haus:=1;
for ax:=1 to maxscroll do for ay:=1 to maxscroll do if karte[ax,ay].haus=2 then begin
karte[ax+1,ay].haus:=1;karte[ax,ay+1].haus:=1;
karte[ax,ay].haus:=1;karte[ax+1,ay+1].haus:=1;
end;

for ax:=1 to maxscroll do for ay:=1 to maxscroll do karte[ax,ay].s:=random(2);{(ay mod 2)+(ax mod 2)-random(2)+random(
2)-random(2)+random(2);}
karte[maxscroll div 2-4,maxscroll div 2-3].s:=1;
karte[maxscroll div 2-4,maxscroll div 2-4].s:=1;
karte[maxscroll div 2-3,maxscroll div 2-3].s:=1;
karte[maxscroll div 2-3,maxscroll div 2-4].s:=1;
{if random(2)=0 then karte[ax,ay].s:=1 else }
for ax:=1 to maxscroll do for ay:=1 to maxscroll do begin
if karte[ax,ay].haus>0 then karte[ax,ay].s:=1;
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

for ax:=1 to maxscroll do for ay:=1 to maxscroll do begin
zufall:=0;
if (fauna[ax+1,ay]>3) then inc(zufall);
if (fauna[ax+1,ay+1]>3) then inc(zufall);
if (fauna[ax,ay+1]>3) then inc(zufall);
if (fauna[ax+1,ay-1]>3) then inc(zufall);
if (fauna[ax-1,ay+1]>3) then inc(zufall);
if (fauna[ax-1,ay-1]>3) then inc(zufall);
if (fauna[ax-1,ay]>3) then inc(zufall);
if (fauna[ax,ay-1]>3) then inc(zufall);

if (random(15)=0) or (zufall>2) then fauna[ax,ay]:=random(24) else
if (random(5)=0) then fauna[ax,ay]:=random(4)+20 else
fauna[ax,ay]:=random(4);
ax:=ax-scrollx;ay:=ay-scrolly;
t1:=ax*16-ay*16;
t2:=ax*8+ay*8;
if (t1>=0) and (t2>=0) and (t1<randr) and (t2<randu) then begin
{karte[ax,ay].hell:=0{(wegex-(abs(ax-wegex div 2)+abs(ay-wegex div 2))) div 2-5};
{hell:=karte[ax,ay].hell;}
{newput(t1,t2,grass[fauna[ax,ay]]);
if karte[ax,ay].s>0 then
newput(t1,t2,s[karte[ax,ay].s]);}
if (karte[ax,ay].haus=1) and (karte[ax+1,ay].haus=1) and (karte[ax,ay+1].haus=1) and (karte[ax+1,ay+1].haus=1) then begin
karte[ax,ay].haus:=2;karte[ax+1,ay].haus:=2;
karte[ax,ay+1].haus:=2;karte[ax+1,ay+1].haus:=2;
{newput(t1-19,t2-17,s[20]);}
end;
end;
ax:=ax+scrollx;ay:=ay+scrolly;
end;
format:=true;
{asm mov ax,0;int $33;end;
j:=maxx[akmodus]-;k:=maxy[akmodus];
asm mov ax,7;mov cx,0;mov dx,j;int $33;end;
asm mov ax,8;mov cx,0;mov dx,k;int $33;end;}
ooo:=0;
ooogx:=1;
hell:=0;
race:=1;

for ax:=1 to anzspieler do with spieler[ax]^ do if (dead=false) then begin
wx:=ax*52-52+10;
if ax>19 then wx:=10+(ax-19)*52-52;wy:=660+52*(ax div 20-1);
om:=mund;
mund:=random(4);
oa:=auge;
if auge=2 then auge:=random(2) else
if auge=1 then begin if random(2)=0 then auge:=0 else auge:=2;end else
auge:=random(3);
newput(wx-10,wy,rahm);

for t3:=1 to anzspieler do if marked[t3]=ax then begin
{newput(wx,wy+32,mine[mund,auge]);
newput(wx+30,wy+32,bar[(hunger+128) div 11]);}
format:=true;aktab:=2;
{t1:=(spieler[ax].x-scrollx)*16-(spieler[ax].y-scrolly)*16+px+4;
t2:=(wx-scrollx)*8+(wy-scrolly)*8+py-19;
if (t1>=0) and (t2>=0) and (t1<randr) and (t2<randu) then newput(t1,t2,mark);}
end
else begin
{newput(wx,wy,mine[0,auge]);}
format:=true;aktab:=0;
end;
end;

scrollx:=maxscroll div 2-20;
scrolly:=maxscroll div 2-10;
paint:=true;

repeat
if paint then begin
paint:=false;
for ax:=0 to maxscroll do for ay:=0 to maxscroll do begin
{if (ax>=scrollx) and (ay>=scrolly) and (ax<=scrollx+wegex)
and (ay<=scrolly+wegex) then begin}
{karte[ax,ay].hell:=0{(wegex-(abs(ax-wegex div 2)+abs(ay-wegex div 2))) div 2-5};
{hell:=karte[ax,ay].hell;}
t1:=(ax-scrollx)*16-(ay-scrolly)*16;
t2:=(ax-scrollx)*8+(ay-scrolly)*8;
if (t1>=0) and (t2>=0) and (t1<randr) and (t2<randu) then begin
{rp(0,0,grass[fauna[ax,ay]]);}
newput(t1,t2,grass[fauna[ax,ay] mod 4]);
if karte[ax,ay].s>0 then newput(t1,t2,s[karte[ax,ay].s]);
{newput(t1,t2,rain[(fauna[ax,ay] mod 4+random(8)) mod 8]);
{if fauna[ax,ay]>4 then newput(t1,t2,blume[fauna[ax,ay] div 4]);}
end;
end;
for ax:=1 to maxscroll do for ay:=1 to maxscroll do begin
t1:=(ax-scrollx)*16-(ay-scrolly)*16;
t2:=(ax-scrollx)*8+(ay-scrolly)*8;
if (t1>=16) and (t2>=48) and (t1<randr) and (t2<randu) then begin
if (fauna[ax,ay]>4) and (fauna[ax,ay]<20) then
newput(t1-16,t2-48,blume[fauna[ax,ay] div 4]) else
if fauna[ax,ay]>4 then newput(t1+14,t2+5,tulpe)
end;
end;
{for ttt:=1 to hauses do with hauser[ttt] do begin
t1:=(x-scrollx)*16-(y-scrolly)*16;
t2:=(x-scrollx)*8+(y-scrolly)*8;
if ((t1>=19) and (t2>=17)) and ((t1<=randr) and (t2<=randu)) then begin
wx:=t1;
wy:=t2;
newput(-19+wx,-17+wy,s[20]);
{aktab:=(pur+ttt) mod 2;
writes(staedtenamen[ttt]);
end;
end;}

newput(0,0,k1);newput(1008,0,k2);newput(0,592,k3);newput(1008,592,k4);
for t1:=0 to 3 do newput(16+t1*248,0,rahmoben);
for t1:=0 to 3 do newput(16+t1*248,randu-8,rahmunten);
for t1:=0 to 5 do newput(0,15+t1*96,rahmlinks);
for t1:=0 to 5 do newput(randr+6,15+t1*96,rahmrechts);

for ax:=1 to anzspieler do with spieler[ax]^ do if (dead=false) then begin
wx:=ax*52-52+10;
if ax>19 then wx:=10+(ax-19)*52-52;wy:=660+52*(ax div 20-1);
if random(20)=0 then begin
om:=mund;
mund:=random(4);
oa:=auge;
if auge=2 then auge:=random(2) else
if auge=1 then begin if random(2)=0 then auge:=0 else auge:=2;end else
auge:=random(3);
end;
newput(wx-10,wy,rahm);
end;
end;
inc(pur);
a:=#0;
{inc(ooo,ooogx);
if abs(ooo)>10 then ooogx:=-ooogx;}
{for tax:=1 to wegex do for tay:=1 to wegex do begin
{newput(maxx[akmodus] shr 1+tax*16-tay*16,maxy[akmodus] shr 2+tax*8+tay*8,
grass[random(4)]);}
{if karte[tax,tay].s>0 then
newput(maxx[akmodus] shr 1+tax*16-tay*16,maxy[akmodus] shr 2+tax*8+tay*8,
s[karte[tax,tay].s]);
end;
{for ax:=1 to wegex do for ay:=1 to wegex do
if karte[ax,ay]>0 then
newput(maxx[akmodus] shr 1+ax*16-ay*16,maxy[akmodus] shr 2+ax*8+ay*8,s[karte[ax,ay]]);}
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

{for ax:=0 to wegex do for ay:=0 to wegex do karte[ax,ay].hell:=0;}
{if abs(karte[ax,ay].hell)>0 then begin
if karte[ax,ay].hell>0 then dec(karte[ax,ay].hell);
if karte[ax,ay].hell<0 then inc(karte[ax,ay].hell);
end;}

for ax:=1 to anzspieler do with spieler[ax]^ do if (dead=false) and (menuleiste=false) then begin
wx:=ax*52-52+10;
if ax>19 then wx:=10+(ax-19)*52-52;wy:=660+52*(ax div 20-1);
if random(10)=0 then begin
mund:=random(4);
if auge=2 then auge:=random(2) else
if auge=1 then begin if random(2)=0 then auge:=0 else auge:=2;end else
auge:=random(3);
end;

for t3:=1 to anzspieler do if (marked[t3]=ax) then begin
if (mund<>om) or (auge<>oa) then newput(wx,wy+12,mine[mund,auge]);
newput(wx+28,wy+12,bar[(hunger+128) div 11]);
format:=true;aktab:=2;
t1:=(x-scrollx)*16-(y-scrolly)*16+px+4;
t2:=(x-scrollx)*8+(y-scrolly)*8+py-19;
if (t1>=0) and (t2>=0) and (t1<randr) and (t2<randu) then newput(t1,t2,mark);
{aktab:=0;
wy:=wy+44;
str(gx,stemp);
str(gy,stemp2);
writes(stemp+':'+stemp2);}
end else if marked[t3]<>ax then begin
if oa<>auge then newput(wx,wy+12,mine[0,auge]);
newput(wx+28,wy+12,bar[(hunger+128) div 11]);
format:=true;aktab:=0;
end;

{for vax:=0 to wegex do for vay:=0 to wegex do begin
if (wegex-(abs(vax-x)+abs(vay-y))) div 2-8>0 then karte[vax,vay].hell:=karte[vax,vay].hell+(wegex-(abs(vax-x)+abs(vay-y)))
div 2-8;
end;}
{for tx:=-2 to 2 do for ty:=-2 to 2 do
if (x+tx>0) and (y+ty>0) and (x+tx<wegex) and (y+ty<wegex) then begin
hell:=karte[x+tx,y+ty].hell;
newput(maxx[akmodus] shr 1+(x+tx)*16-(y+ty)*16,maxy[akmodus] shr 2+(x+tx)*8+(y+ty)*8,grass[fauna[x+tx,y+ty]]);
if karte[x+tx,y+ty].s>0 then
newput(maxx[akmodus] shr 1+(x+tx)*16-(y+ty)*16,maxy[akmodus] shr 2+(x+tx)*8+(y+ty)*8,s[karte[(x+tx),(y+ty)].s]);
end;}

if goha>0 then newput(maxx[akmodus] shr 1+hauser[goha].x*16-hauser[goha].y*16,maxy[akmodus] shr 2+hauser[goha].x*8+
hauser[goha].y*8,s[ax mod 4+15]);
if gx=1 then r:=1;
if gy=-1 then r:=3;
if gx=-1 then r:=7;
if gy=1 then r:=5;
{inc(px,gx);inc(py,gy);}
{if karte[x,y].s>0 then
newput(maxx[akmodus] shr 1+x*16-y*16,maxy[akmodus] shr 2+x*8+y*8,
s[karte[x,y].s]);}
if (x<>cx) or (y<>cy) then begin
inc(aphase);
if aphase>7 then aphase:=0;
end else aphase:=0;
{kreuzung(karte[x,y].s,x,y,gx,
gy,cx,cy,r);}
{r:=1;gx:=1;gy:=0;

{inc(px,gx*2-gy*2);
inc(py,gy+gx);}
{px:=
(aphase)*gx*2-
(aphase)*gy*2+8;
py:=
(aphase)*gy+
(aphase)*gx-19;}
{kreuzung(karte[x,y].s,x,y,gx,
gy,cx,cy,r);}
if (gx=0) and (gy=0) then begin
findway(ax);
end;
inc(px,(gx-gy)*2);
inc(py,gx+gy);

if (abs(px)>=16) or (abs(py)>=8) then begin
if (gx=0) and (gy=0) then begin
aphase:=0;
if (goha>0) and (cx=x) and (cy=y) then begin
gx:=0;gy:=0;
if dx>0 then cx:=dx;
if dy>0 then cy:=dy;
dx:=0;dy:=0;
{if hunger<0 then begin dec(hauser[goha].vorrat,2);hunger:=127;end;}
if rucksack<255 then begin dec(hauser[goha].vorrat,2);rucksack:=255;end;
goha:=0;
end;
{gx:=0;gy:=0;}
end;
if hunger>-126 then dec(hunger);
{if hunger<-120 then dead:=true;}
if (hunger<0) and (goha=0) then begin
{if rucksack>=64 then begin
dec(rucksack,64);inc(hunger,64);
end else}
{suchwasser(ax);}
{if hauser[ax].vorrat>64 then bgohaus(ax,spieler[ax]) else }
end;
inc(wegp);
if wegp>=99 then wegp:=2;
gx:=weg[wegp].wx;
gy:=weg[wegp].wy;
{if (x+gx<maxscroll -rand) and (x+gx>rand) then inc(x,gx);
if (y+gy<maxscroll -rand) and (y+gy>rand) then inc(y,gy);}
px:=0{-gx*16};py:=0{-gy*8;{-gx*16;py:=-gy*8;};
{findway(ax);}
end;
{hell:=karte[x,y].hell;}
t1:=(x-scrollx)*16-(y-scrolly)*16+px+6;
t2:=(x-scrollx)*8+(y-scrolly)*8+py-19;
if (t1>=0) and (t2>=0) and (t1<randr) and (t2<randu-50) then newput(t1,t2,leut[abs(aphase),r]);
{newput(maxx[akmodus] shr 1+x*16-y*16+px+16,py+maxy[akmodus] shr 2+x*8+y*8-18,bar[(hunger+128) DIV 52]);}

{waitretrace;}

{inc(py,gx+gy);
inc(px,gx*2-gy*2);
newput(maxx[akmodus] shr 1+x*16-y*16+px+8,py+
maxy[akmodus] shr 2+x*8+y*8-19,
leut[abs(aphase+3),r]);
if aphase>3 then begin
px:=16*gy+16*gx-16;
py:=8*gy-8*gx-8;
aphase:=-4;
if x<wegex then inc(x,gx);
if y<wegex then inc(y,gy);
kreuzung(karte[x,y].s,x,y,gx,
gy,cx,cy,r);}
{px:=16;py:=8;

{if bau then begin
if (x+2>cx) and (x-2<cx) and
   (y+2>cy) and (y-2<cy) then begin
karte[ttx+scrollx,tty+scrolly].s:=1;
for tax:=-2+scrollx to 2+scrollx do for tay:=-2+scrolly to 2+scrollx do if (tty+tay>0) and (tty+tay<maxscroll) and
(ttx+tax>0) and (ttx+tax<maxscroll) then begin
if karte[ttx+tax,tty+tay].s>0 then begin
ttx:=ttx+tax;tty:=tty+tay;
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=11 else
if (karte[ttx+1,tty].s=0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=7 else
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s=0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=8 else
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s=0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=9 else
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s=0) then karte[ttx,tty].s:=10 else
if (karte[ttx+1,tty].s=0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s=0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=1 else
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s=0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s=0) then karte[ttx,tty].s:=2 else
if (karte[ttx+1,tty].s=0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s=0) then karte[ttx,tty].s:=3 else
if (karte[ttx+1,tty].s=0) and (karte[ttx,tty+1].s=0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=4 else
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s=0) and (karte[ttx-1,tty].s=0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=5 else
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s=0) and
(karte[ttx,tty-1].s=0) then karte[ttx,tty].s:=6 else
if (karte[ttx+1,tty].s=0) and (karte[ttx,tty+1].s>0) and (karte[ttx-1,tty].s=0) and
(karte[ttx,tty-1].s=0) then karte[ttx,tty].s:=12 else
if (karte[ttx+1,tty].s=0) and (karte[ttx,tty+1].s=0) and (karte[ttx-1,tty].s>0) and
(karte[ttx,tty-1].s=0) then karte[ttx,tty].s:=13 else
if (karte[ttx+1,tty].s=0) and (karte[ttx,tty+1].s=0) and (karte[ttx-1,tty].s=0) and
(karte[ttx,tty-1].s>0) then karte[ttx,tty].s:=14 else
if (karte[ttx+1,tty].s>0) and (karte[ttx,tty+1].s=0) and (karte[ttx-1,tty].s=0) and
(karte[ttx,tty-1].s=0) then karte[ttx,tty].s:=15 else
karte[ttx,tty].s:=0;
ttx:=ttx-tax;tty:=tty-tay;
end;
end;

bau:=false;
cx:=x;cy:=y;


end;
end;}
{old[6].x:=old[5].x;
old[6].y:=old[5].y;
old[5].x:=old[4].x;
old[5].y:=old[4].y;
old[4].x:=old[3].x;
old[4].y:=old[3].y;
old[3].x:=old[2].x;
old[3].y:=old[2].y;
old[2].x:=old[1].x;
old[2].y:=old[1].y;
old[1].x:=x;
old[1].y:=y;}
{end;}
end;
hell:=0;
if keypressed then begin a:=readkey;if a=#0 then a:=readkey;
if (a<>'s') and (((a='A') and (menuleiste)) or ((a<>'A') and (menuleiste=false))) then paint:=true;
case a of
's':for hell:=1 to anzspieler do if marked[hell]>0 then begin
        spieler[marked[hell]]^.gx:=0;spieler[marked[hell]]^.cx:=spieler[marked[hell]]^.x;spieler[marked[hell]]^.aphase:=0;
        spieler[marked[hell]]^.gy:=0;spieler[marked[hell]]^.cy:=spieler[marked[hell]]^.y;
        spieler[marked[hell]]^.dx:=spieler[marked[hell]]^.x;spieler[marked[hell]]^.dy:=spieler[marked[hell]]^.y;
        end;
'+':bgohaus(spieler[wahl]^.goha+1,spieler[wahl]^);
'-':bgohaus(spieler[wahl]^.goha-1,spieler[wahl]^);
#75:if scrollx>1 then dec(scrollx);
#77:if scrollx<maxscroll then inc(scrollx);
#72:if scrolly>1 then dec(scrolly);
#80:if scrolly<maxscroll  then inc(scrolly);
{#13:bau;}
'q':begin if wahl>1 then dec(wahl) else wahl:=anzspieler;marked[1]:=wahl;for t3:=2 to anzspieler do marked[t3]:=0;
          center(spieler[wahl]^.x,spieler[wahl]^.y);end;
'w':begin if wahl<anzspieler then inc(wahl) else wahl:=1;marked[1]:=wahl;for t3:=2 to anzspieler do marked[t3]:=0;
          center(spieler[wahl]^.x,spieler[wahl]^.y);end;
'A':menuleiste:=not menuleiste;
end;

{if mp>0 then begin mp:=0;}
{ttx:=-((mx-maxx[akmodus] shr 1) div 16)+(my-maxx[akmodus] shr 2) div 8;
=tty:=(mx-maxx[akmodus] shr 1) div 16+(my-maxx[akmodus] shr 2) div 8;}
end;
if (a=#32) or (mpx>0) then begin gotoxye(ttx+scrollx,tty+scrolly);
{kreuzung(karte[x,y].s,x,y,gx,
gy,cx,cy,r);}
end;
oox:=bax;ooy:=bay;
ox:=fx;oy:=fy;omp:=mp;
asm mov ax,3;int $33;mov fx,cx;mov fy,dx;mov mp,bx;end;
inc(bax,fx-ox);
inc(bay,fy-oy);
if (omp=1) and (mp=0) then mpx:=1 else mpx:=0;
if menuleiste=false then begin
if (omp=0) and (mp=2) then begin swx:=bax;swy:=bay;end;
if (omp=2) and (mp=0) then begin markx(bax,bay);swx:=0;swy:=0;end;
if (swx>0) and (swy>0) then begin
if (swx<bax) and (swy<bay) then rechteck(swx,swy,bax,bay) else
if (swx<bax) and (swy>bay) then rechteck(swx,bay,bax,swy) else
if (swx>bax) and (swy<bay) then rechteck(bax,swy,swx,bay) else
if (swx>bax) and (swy>bay) then rechteck(bax,bay,swx,swy);
end;
if (mp=0) and (omp=0) then begin swx:=0;swy:=0;end;
end;
{ Wenn maus nach unten dann ttx erhoehen, tty erhoehen}
tempus:=bax mod 32;
te2:=bay mod 16+1;
feinx:=0;feiny:=0;
if te2<8 then begin
if tempus<te2*2 then feinx:=-1 else if tempus>32-te2*2 then feiny:=-1;
end else if te2>8 then begin
dec(te2,8);
if tempus<te2*2 then feiny:=1 else if tempus>32-te2*2 then feinx:=1;
end;

ttx:=feinx+bax div 32+bay div 16;
tty:=feiny+bax div 32+bay div 16;
{a:=#0;}
{newput(0,0,leer);newput(0,50,leer);newput(0,100,leer);newput(0,150,leer);}
t1:=ttx*16-tty*16;
t2:=ttx*8+tty*8;
{if (t1>=0) and (t2>=0) and (t1<randr) and (t2<randu) then }{newput(t1,t2,ani[pur mod 7]);}
{if (bax>=0) and (bay>=0) then }
putimage(oox,ooy);
getimage(bax,bay-1);
newput(bax,bay,hand[race,mp]);

{for i:=1 to (spieler[1].hunger+128) div 8 do newput(i*3,0,leut[0,i mod 8]);
for i:=1 to (spieler[2].hunger+128) div 8 do newput(i*3,50,leut[1,i mod 8]);
for i:=1 to (spieler[3].hunger+128) div 8 do newput(i*3,100,leut[2,i mod 8]);
for i:=1 to (spieler[4].hunger+128) div 8 do newput(i*3,150,leut[3,i mod 8]);}
if menuleiste then begin if klicked[2,3,1].on then begin klicked[2,3,1].on:=false;initvesa($101);
loadgif('drac5.gif');end;
if klicked[3,2,1].on then begin
klicked[3,2,1].on:=false;if zent<hauses then inc(zent) else zent:=1;
klicked[3,2,1].name:=staedtenamen[zent];
center(hauser[zent].x,hauser[zent].y);
paint:=true;{menuleiste:=false;}
end;
if klicked[2,3,2].on then begin klicked[2,3,2].on:=false;initvesa($103);loadgif('drac5.gif');end;
if klicked[2,3,3].on then begin klicked[2,3,3].on:=false;initvesa($105);loadgif('drac5.gif');end;
if klicked[2,2,1].on then begin klicked[2,2,1].on:=false;inc(hell);end;
if klicked[2,2,2].on then begin klicked[2,2,2].on:=false;hell:=0;end;
if klicked[2,2,3].on then begin klicked[2,2,3].on:=false;dec(hell);end;
if klicked[1,1,1].on and (fast>-1) then fast:=-1 else
if klicked[1,1,2].on and (fast<>0) then fast:=0 else
if klicked[1,1,3].on and (fast<1)  then fast:=1;
if klicked[1,2,1].on and (det>-1) then det:=-1 else
if klicked[1,2,2].on and (det<>0) then det:=0 else
if klicked[1,2,3].on and (det<1)  then det:=1;
if klicked[1,3,1].on and (zoom>-1) then zoom:=-1 else
if klicked[1,3,2].on and (zoom<>0) then zoom:=0 else
if klicked[1,3,3].on and (zoom<1)  then zoom:=1;
if klicked[1,6,1].on then begin klicked[1,6,1].on:=false;race:=0;end;
if klicked[1,6,2].on then begin klicked[1,6,2].on:=false;race:=1;end;
if klicked[1,6,3].on then begin klicked[1,6,3].on:=false;race:=2;end;
menu;
end else begin filled:=false;

{if done>3 then begin}
done:=0;
{for ax:=0 to wegex do for ay:=0 to wegex do begin
{newput(maxx[akmodus] shr 1+ax*16-ay*16,maxy[akmodus] shr 2+ax*8+ay*8,grass[fauna[ax,ay]]);
if karte[ax,ay].s>0 then newput(maxx[akmodus] shr 1+ax*16-ay*16,maxy[akmodus] shr 2+ax*8+ay*8,s[karte[ax,ay].s]);}
{end;}
{for ttt:=1 to hauses do if hauser[ttt].x>0 then begin
wx:=maxx[akmodus] shr 1+hauser[ttt].x*16-hauser[ttt].y*16;
wy:=maxy[akmodus] shr 2+hauser[ttt].x*8+hauser[ttt].y*8;
newput(-19+wx,-17+wy,s[20]);
str(ttt,names);
aktab:=(pur+ttt) mod 2;
writes('Stadt Nummer '+names);
end;
{end else inc(done)}
end;
until (a=#27) or (klicked[0,3,3].on);
textmode(3);
writeln(' Und? Wie fanden Sie es? Schicken Sie mir Verbesserungsvorschlaege, Bilder, etc.');
writeln(' Wertvolle Einsendungen werden auf jeden Fall mit einem Link auf meiner');
writeln(' HomePage praemiert!');
writeln;
writeln(' Rueckantwort an : CLEMENS.LODE@ALLGAEU.ORG');
writeln;
writeln('WARS! - You will never win!');
readkey;
for i:=1 to anzspieler do freemem(spieler[i],sizeof(spieler[i]));
end.

