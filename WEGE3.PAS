uses crt,vesa6,modexlib,gif,dos;
const wegex=30;
rand=4;
hauses=5;
maxsch=5;
hg=11;
hfenstsize=450;
sfenstsize=370;
feldx:shortint=64;
feldy:shortint=32;
type eig=record
px,py,cx,cy,x,y,gx,gy:integer;
hunger:shortint;
r,goha:byte;
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
var ttt,strasse:byte;
hand:spritetyp;
klicked:array[0..maxsch,0..6,0..3] of record
name:string[17];
on:boolean;
end;
besx:array[0..5] of word;
fauna:array[0..wegex,0..wegex] of byte;
tx,ty:integer;
i,mp,mx,my:word;
{leer:spritetyp;}
leut:array[0..7,0..7] of spritetyp;
grass:array[0..3] of spritetyp;
s:array[1..21] of spritetyp;
a:char;
wahl,ccd:byte;
tax,tay:shortint;
tt:file;
vax,vay,ax,ay:integer;
lax,lay:longint;
temper:array[1..hauses] of byte;
spieler:array[1..4] of eig;
ttx,tty,j,k,zzz:word;
hauser:array[1..hauses] of haus;
karte:array[0..wegex+1,0..wegex+1] of record
hell:shortint;
s:byte;
haus:byte;
end;
mo,kl,lk,menuleiste:boolean;
ll,poskartex,poskartey:byte;
mpx,sx,oox,ooy,omp:word;
ooo,ooogx,fx,fy,ox,oy,bax,bay:integer;
di,zoom,det,fast:shortint;
done:byte;
procedure menu;
var t:byte;s:string;
begin
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
var t1,zeits:string;
h,m,s,hu:word;
begin
aktab:=2;
{wx:=fenstera[1].x+117;wy:=fenstera[1].y+75;}
gettime(h,m,s,hu);
str(h,t1);zeits:=t1+' ';
str(m,t1);zeits:=zeits+t1+' ';
str(s,t1);zeits:=zeits+t1;
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

procedure bau;
begin
if karte[ttx,tty].s>0 then exit;
spieler[wahl].bau:=true;
spieler[wahl].cx:=ttx;
spieler[wahl].cy:=tty;
end;

procedure bgohaus(num:byte;var spiel:eig);
begin
if num<=hauses then spiel.goha:=num else exit;
spiel.cx:=hauser[num].x;
spiel.cy:=hauser[num].y;
end;
procedure suchwasser(num:byte);
var hoch,wer,entf,entx,enty,zahl:byte;
{choose:array[1..3] of byte;}
begin
zahl:=0;
{Abchecken aller wasserfuehrenden Gebaeude/Plaetzen in der Naehe}
for i:=1 to hauses do with hauser[i] do begin
if vorrat>64 then begin inc(zahl);temper[zahl]:=i;end;
end;
for i:=1 to zahl do with hauser[i] do begin
if x>y then entf:=x+y div 4 else entf:=y+x div 4;
if entf<hoch then begin
wer:=i;
hoch:=entf;
end;
end;
if i<=hauses then spieler[num].goha:=i;
bgohaus(i,spieler[num]);
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
spieler[wahl].goha:=0;
spieler[wahl].bau:=false;
spieler[wahl].cx:=xx;
spieler[wahl].cy:=yy;
if xx>spieler[wahl].x then spieler[wahl].gx:=1;
if xx=spieler[wahl].x then spieler[wahl].gx:=0;
if xx<spieler[wahl].x then spieler[wahl].gx:=-1;
if yy>spieler[wahl].y then spieler[wahl].gy:=1;
if yy=spieler[wahl].y then spieler[wahl].gy:=0;
if yy>spieler[wahl].y then spieler[wahl].gy:=-1;
kreuzung(karte[spieler[wahl].x,spieler[wahl].y].s,spieler[wahl].x,spieler[wahl].y,spieler[wahl].gx,spieler[wahl].gy,
spieler[wahl].cx,spieler[wahl].cy,spieler[wahl].r);
{spieler[wahl].px:=16;
spieler[wahl].py:=8;}
end;


begin
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
klicked[1,6,0].name:='';

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
loadgif('d:\wars\drac5');
show_pic13;
{getsprite(1+0*52+(2+0*62)*320,51,61,leut[0,1]);
getsprite(1+0*52+(1+1*62)*320,51,61,leut[1,1]);
getsprite(1+0*52+(1+2*62)*320,51,61,leut[2,1]);
getsprite(1+1*52+(1+0*62)*320,51,61,leut[3,1]);
getsprite(1+1*52+(1+1*62)*320,51,61,leut[4,1]);
getsprite(1+1*52+(1+2*62)*320,51,61,leut[5,1]);
getsprite(1+2*52+(1+0*62)*320,51,61,leut[6,1]);}
for lax:=0 to 7 do for lay:=0 to 4 do getsprite(lax*16+(lay*27)*320,16,27,leut[lax,lay]);
for lax:=0 to 7 do for lay:=0 to 2 do getsprite(lax*16+(lay*27)*320+127,16,27,leut[lax,lay+5]);
{getsprite(160*320,120,27,leer);}
loadgif('ocean6');
show_pic13;
getsprite(0+ 0*320,32,16,grass[0]);
getsprite(0+16*320,32,16,grass[1]);
getsprite(0+32*320,32,16,grass[2]);
getsprite(0+48*320,32,16,grass[3]);

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
loadgif('d:\wars\mhaus!.gif');
show_pic13;
getsprite(0+0*320,70,50,s[20]);
loadgif('d:\wars\font168.gif');
show_pic13;
getsprite(85*320,20,20,hand);
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
initvesa($105);
loadgif('d:\wars\drac5');
for i:=0 to anz do putpasc(i*6,0,zeichen[0,i]);
for i:=0 to anz do putpasc(i*6,8,zeichen[1,i]);
wahl:=1;
randomize;
{repeat
inc(ax);putpasc(random(1024),random(768),schalt[random(7)]);
until ax=10000;}

{repeat
inc(i);
for ax:=0 to 7 do begin {putpasc(ax*16,0,leer);waitretrace;putpasc(ax*16,0,leut[i mod 8,ax]);end;
until keypressed;}
asm mov ax,0;int $33;end;
j:=maxx[akmodus]-40;k:=maxy[akmodus]-40;
asm mov ax,7;mov cx,0;mov dx,j;int $33;end;
asm mov ax,8;mov cx,0;mov dx,k;int $33;end;
spieler[1].cx:=wegex;spieler[1].cy:=wegex;
spieler[1].gx:=1;spieler[1].gy:=0;
spieler[1].x:=rand;spieler[1].y:=rand;
spieler[1].dead:=false;

spieler[2].cx:=wegex;spieler[2].cy:=rand;
spieler[2].gx:=0;spieler[2].gy:=-1;
spieler[2].x:=rand;spieler[2].y:=wegex-rand;
spieler[2].dead:=true;

spieler[3].cx:=rand;spieler[3].cy:=wegex;
spieler[3].gx:=0;spieler[3].gy:=1;
spieler[3].x:=wegex-rand;spieler[3].y:=rand;
spieler[3].dead:=true;

spieler[4].cx:=rand;spieler[4].cy:=rand;
spieler[4].gx:=-1;spieler[4].gy:=0;
spieler[4].x:=wegex div 2-3;spieler[4].y:=wegex div 2-3;
spieler[4].dead:=true;
umhell:=-4;
for ax:=1 to hauses-1 do begin
spieler[ax].hunger:=random(50)+70;
hauser[ax].x:=spieler[ax].x;
hauser[ax].y:=spieler[ax].y;
hauser[ax].vorrat:=255;
end;
ax:=hauses;
hauser[ax].x:=wegex div 2;
hauser[ax].y:=wegex div 2;
hauser[ax].vorrat:=200;

for ax:=1 to hauses do karte[hauser[ax].x,hauser[ax].y].haus:=1;
for ax:=1 to wegex do for ay:=1 to wegex do if karte[ax,ay].haus=2 then begin
karte[ax+1,ay].haus:=1;karte[ax,ay+1].haus:=1;
karte[ax,ay].haus:=1;karte[ax+1,ay+1].haus:=1;
end;
for ax:=1 to wegex do for ay:=1 to wegex do karte[ax,ay].s:=1;{random(2);{(ay mod 2)+(ax mod 2)-random(2)+random(
2)-random(2)+random(2);}
karte[wegex div 2-4,wegex div 2-3].s:=1;
karte[wegex div 2-4,wegex div 2-4].s:=1;
karte[wegex div 2-3,wegex div 2-3].s:=1;
karte[wegex div 2-3,wegex div 2-4].s:=1;
{if random(2)=0 then karte[ax,ay].s:=1 else }
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
fauna[ax,ay]:=random(4);
karte[ax,ay].hell:=0{(wegex-(abs(ax-wegex div 2)+abs(ay-wegex div 2))) div 2-5};
hell:=karte[ax,ay].hell;
putpasc(maxx[akmodus] shr 1+ax*16-ay*16,maxy[akmodus] shr 2+ax*8+ay*8,grass[fauna[ax,ay]]);
if karte[ax,ay].s>0 then begin
putpasc(maxx[akmodus] shr 1+ax*16-ay*16,maxy[akmodus] shr 2+ax*8+ay*8,s[karte[ax,ay].s]);
end;
if (karte[ax,ay].haus=1) and (karte[ax+1,ay].haus=1) and (karte[ax,ay+1].haus=1) and (karte[ax+1,ay+1].haus=1) then begin
karte[ax,ay].haus:=2;karte[ax+1,ay].haus:=2;
karte[ax,ay+1].haus:=2;karte[ax+1,ay+1].haus:=2;
putpasc(-19+maxx[akmodus] shr 1+ax*16-ay*16,-17+maxy[akmodus] shr 2+ax*8+ay*8,s[20]);
end;
end;
format:=true;
{asm mov ax,0;int $33;end;
j:=maxx[akmodus]-;k:=maxy[akmodus];
asm mov ax,7;mov cx,0;mov dx,j;int $33;end;
asm mov ax,8;mov cx,0;mov dx,k;int $33;end;}
ooo:=0;
ooogx:=1;
repeat
a:=#0;
{inc(ooo,ooogx);
if abs(ooo)>10 then ooogx:=-ooogx;}
{for tax:=1 to wegex do for tay:=1 to wegex do begin
{putpasc(maxx[akmodus] shr 1+tax*16-tay*16,maxy[akmodus] shr 2+tax*8+tay*8,
grass[random(4)]);}
{if karte[tax,tay].s>0 then
putpasc(maxx[akmodus] shr 1+tax*16-tay*16,maxy[akmodus] shr 2+tax*8+tay*8,
s[karte[tax,tay].s]);
end;
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
for ax:=0 to wegex do for ay:=0 to wegex do karte[ax,ay].hell:=0;
{if abs(karte[ax,ay].hell)>0 then begin
if karte[ax,ay].hell>0 then dec(karte[ax,ay].hell);
if karte[ax,ay].hell<0 then inc(karte[ax,ay].hell);
end;}

for ax:=1 to 4 do with spieler[ax] do if dead=false then begin
for vax:=0 to wegex do for vay:=0 to wegex do begin
if (wegex-(abs(vax-x)+abs(vay-y))) div 2-8>0 then karte[vax,vay].hell:=karte[vax,vay].hell+(wegex-(abs(vax-x)+abs(vay-y)))
div 2-8;
end;
{for tx:=-2 to 2 do for ty:=-2 to 2 do
if (x+tx>0) and (y+ty>0) and (x+tx<wegex) and (y+ty<wegex) then begin
hell:=karte[x+tx,y+ty].hell;
putpasc(maxx[akmodus] shr 1+(x+tx)*16-(y+ty)*16,maxy[akmodus] shr 2+(x+tx)*8+(y+ty)*8,grass[fauna[x+tx,y+ty]]);
if karte[x+tx,y+ty].s>0 then
putpasc(maxx[akmodus] shr 1+(x+tx)*16-(y+ty)*16,maxy[akmodus] shr 2+(x+tx)*8+(y+ty)*8,s[karte[(x+tx),(y+ty)].s]);
end;}
{for ttt:=1 to hauses do if hauser[ttt].x>0 then
putpasc(-19+maxx[akmodus] shr 1+hauser[ttt].x*16-hauser[ttt].y*16,-17+maxy[akmodus] shr 2+hauser[ttt].x*8+hauser[ttt].
y*8,s[20]);}
if goha>0 then putpasc(maxx[akmodus] shr 1+hauser[goha].x*16-hauser[goha].y*16,maxy[akmodus] shr 2+hauser[goha].x*8+
hauser[goha].y*8,s[ax+15]);
if gx=1 then r:=1;
if gy=-1 then r:=3;
if gx=-1 then r:=7;
if gy=1 then r:=5;
{inc(px,gx);inc(py,gy);}
{if karte[x,y].s>0 then
putpasc(maxx[akmodus] shr 1+x*16-y*16,maxy[akmodus] shr 2+x*8+y*8,
s[karte[x,y].s]);}
if (x<>cx) or (y<>cy) then begin
inc(aphase);
if aphase>7 then aphase:=0;
end;
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
if x>cx then gx:=-1;if x<cx then gx:=1;
if y>cy then gy:=-1;if y<cy then gx:=1;
kreuzung(karte[x,y].s,x,y,gx,gy,cx,cy,r);
end;
inc(px,(gx-gy)*2);
inc(py,gx+gy);

if (abs(px)>=16) or (abs(py)>=8) then begin
if done=0 then begin
done:=0;
for vax:=0 to wegex do for vay:=0 to wegex do begin
hell:=karte[vax,vay].hell;
if hell>0 then begin
putpasc(maxx[akmodus] shr 1+vax*16-vay*16,maxy[akmodus] shr 2+vax*8+vay*8,grass[fauna[vax,vay]]);
if karte[vax,vay].s>0 then begin
putpasc(maxx[akmodus] shr 1+vax*16-vay*16,maxy[akmodus] shr 2+vax*8+vay*8,s[karte[vax,vay].s]);
end;
end;
end;
end else inc(done);
dec(hunger,4);
{if hunger<-120 then dead:=true;}
if (hunger<0) and (goha=0) then begin
if rucksack>=64 then begin
dec(rucksack,64);inc(hunger,64);
end else
{if hauser[ax].vorrat>64 then bgohaus(ax,spieler[ax]) else }
suchwasser(ax);
end;
if (x<wegex) and (x>0) then inc(x,gx);
if (y<wegex) and (y>0) then inc(y,gy);
px:=0{-gx*16};py:=0{-gy*8;{-gx*16;py:=-gy*8;};
kreuzung(karte[x,y].s,x,y,gx,
gy,cx,cy,r);
end;
hell:=karte[x,y].hell;
putpasc(maxx[akmodus] shr 1+x*16-y*16+px+6,py+maxy[akmodus] shr 2+x*8+y*8-19,leut[abs(aphase),r]);
{waitretrace;}

{inc(py,gx+gy);
inc(px,gx*2-gy*2);
putpasc(maxx[akmodus] shr 1+x*16-y*16+px+8,py+
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
if (x=cx) and (y=cy) and (px=16) and (py=8) then begin
{if goha>0 then begin}
if (hunger<0) then begin dec(hauser[goha].vorrat,2);inc(hunger,128);end;
if rucksack<190 then begin dec(hauser[goha].vorrat);inc(rucksack,64);
{end;}

end;
gx:=0;gy:=0;
{px:=16;py:=8;
{for zzz:=1 to ax do begin sound(zzz*100);delay(10);nosound;end;}
end;
if bau then begin
{if (x+2>cx) and (x-2<cx) and
   (y+2>cy) and (y-2<cy) then }begin
karte[ttx,tty].s:=1;
for tax:=-2 to 2 do for tay:=-2 to 2 do if (tty+tay>0) and (tty+tay<wegex) and (ttx+tax>0) and (ttx+tax<wegex) then begin
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

bau:=false;
cx:=x;cy:=y;


end;
end;
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
'A':menuleiste:=not menuleiste;
end;
{if mp>0 then begin mp:=0;}
{ttx:=-((mx-maxx[akmodus] shr 1) div 16)+(my-maxx[akmodus] shr 2) div 8;
=tty:=(mx-maxx[akmodus] shr 1) div 16+(my-maxx[akmodus] shr 2) div 8;}
end;
if a=#32 then begin gotoxye(ttx,tty);
{kreuzung(karte[x,y].s,x,y,gx,
gy,cx,cy,r);}
end;
oox:=bax;ooy:=bay;
ox:=fx;oy:=fy;omp:=mp;
asm mov ax,3;int $33;mov fx,cx;mov fy,dx;mov mpx,bx;end;
inc(bax,fx-ox);
inc(bay,fy-oy);
{if (bax>=0) and (bay>=0) then }putpasc(bax,bay,hand);
{a:=#0;}
{putpasc(0,0,leer);putpasc(0,50,leer);putpasc(0,100,leer);putpasc(0,150,leer);}
putpasc(maxx[akmodus] shr 1+ttx*16-tty*16,maxy[akmodus] shr 2+ttx*8+tty*8,s[21]);
{for i:=1 to (spieler[1].hunger+128) div 8 do putpasc(i*3,0,leut[0,i mod 8]);
for i:=1 to (spieler[2].hunger+128) div 8 do putpasc(i*3,50,leut[1,i mod 8]);
for i:=1 to (spieler[3].hunger+128) div 8 do putpasc(i*3,100,leut[2,i mod 8]);
for i:=1 to (spieler[4].hunger+128) div 8 do putpasc(i*3,150,leut[3,i mod 8]);}
if menuleiste then begin
if klicked[2,3,1].on then begin klicked[2,3,1].on:=false;initvesa($101);loadgif('d:\wars\fire.gif');end;
if klicked[2,3,2].on then begin klicked[2,3,2].on:=false;initvesa($103);loadgif('d:\wars\fire.gif');end;
if klicked[2,3,3].on then begin klicked[2,3,3].on:=false;initvesa($105);loadgif('d:\wars\fire.gif');end;
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
menu;
end;
until a=#27;
end.

