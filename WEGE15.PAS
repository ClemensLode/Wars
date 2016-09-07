uses crt,vesa10,gif,dos,modexlib;

const
 max=25;
 anz=6;

type
 eig=record
  weglong,                      {Laenge des aktuellen Weges in Feldern}
  phase,                        {Phase fuer Bewegung der Sprites}
  richtung,                     {Richtung fuer Sprites}
  wegp,                         {Fortschritt auf dem berechneten Weg (<weglong)}
  wait          :byte;          {Restliche Wartezeit in Bewegungszyklen}
  px,py         :shortint;      {Feine Positionseinstellung zwischen den Feldern}
  sx,sy,                        {Startfeld des aktuellen Wegs}
  ax,ay,                        {Aktuelle Feldposition (Start)}
  cx,cy         :integer;       {Aktuelles Ziel}
  weg           :array[0..max*2] of record
                  kx,ky:shortint;  {Aenderung der Richtung in der jeweiligen Phase}
                 end;
 end;

var
 karte          :array[0..max,0..max] of record
                  ti,              {Temporaere Variable fuer Wegsuche}
                  i:byte;          {Inhalt des jeweiligen Landstrichs}
                  kx,ky:shortint;  {Temporaere Variable fuer Wegsuche}
                 end;
 fauna          :array[0..max,0..max] of byte; {Art des Gelaendes auf jeweiligem Feld}
 www,ow         :string;           {Temporaere Variable zur Konvertierung Zahl>String}
 leut           :array[0..7,0..7] of spritetyp;{Sprites der Einheiten}
 grass          :array[0..4] of spritetyp;     {5 verschiedene Gelaendetypen}
 leer,                                         {Schwarzes Sprite}
 hand,                                         {Mauscursor}
 grid:spritetyp;                               {rote Raute}
 ak:byte;                                      {aktuell aktive Einheit}
 x5,xx,yy,x2,y2,temp:integer;
 x3,y3:word;
 scrollx,scrolly,                               {Scrollkoordinaten}
 t1,t2,ttx,tty,x4,y4:longint;
 a:char;
 mp,mpx,sx,oox,ooy,omp:word;
 feinx,feiny,te2,tempus,ooo,ooogx,fx,fy,ox,oy,bax,bay:integer;
 spieler:array[1..anz] of eig;

 procedure stop(num6:byte); {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
  var
   num1:integer;

 begin
  num1:=num6 mod (anz+1);
  spieler[num1].cx:=spieler[num1].ax;spieler[num1].cy:=spieler[num1].ay;
  spieler[num1].sx:=spieler[num1].ax;spieler[num1].sy:=spieler[num1].ay;
  spieler[num1].px:=0;spieler[num1].py:=0;
  fillchar(spieler[num1].weg,sizeof(spieler[num1].weg),0);
  spieler[num1].weglong:=0;
  spieler[num1].wegp:=0;
  spieler[num1].phase:=0;
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
     -1:richtung:=3;
      1:richtung:=5;
     end;

   1:case goy of
     -1:richtung:=2;
      0:richtung:=1;
      1:richtung:=0;
     end;
   end;
 end;

 procedure fill;
  var
   kkk,yyy:word;

 begin
  fillchar(karte,sizeof(karte),0);
  for kkk:=1 to anz-1 do
   karte[spieler[kkk].ax,spieler[kkk].ay].i:=2; {Feld von Spieler besetzt}
  for yyy:=0 to max do
   for kkk:=0 to max do
    if fauna[yyy,kkk]=0 then karte[yyy,kkk].i:=1; {Feld von Hindernis besetzt}
 end;

 function findway(num7:byte):boolean;
 {Moegliche Optimierung: Annaehrung von Start und Ziel}
  var
   num2,mx,my,long,tx,ty,x,y,x1,y1,t3,t4:integer;

 begin
  num2:=num7 mod (anz+1);
  sound(1500);delay(10);nosound;

  for x:=0 to max do
   for y:=0 to max do
    karte[x,y].ti:=karte[x,y].i;

  karte[spieler[num2].cx,spieler[num2].cy].ti:=4; {Ziel}
  karte[spieler[num2].ax,spieler[num2].ay].ti:=3; {Start}

  for long:=0 to max*3 do begin
{#1}
   for x:=0 to max do
    for y:=0 to max do
     if karte[x,y].ti=10 then karte[x,y].ti:=3;

   for x:=0 to max do
{#2}for y:=0 to max do begin

{#3} if karte[x,y].ti=3 then begin

      for mx:=-1 to 1 do
       for my:=-1 to 1 do
{#4}    if (x+mx>=0) and (y+my>=0) and (x+mx<=max) and (y+my<=max) then begin

         if (karte[x+mx,y+my].ti=0) then begin
          karte[x+mx,y+my].ti:=10;
          karte[x+mx,y+my].kx:=mx;
          karte[x+mx,y+my].ky:=my;
         end;

{#5}  if (karte[x+mx,y+my].ti=4) then begin {Da!}
       karte[x+mx,y+my].kx:=mx;
       karte[x+mx,y+my].ky:=my;
       t3:=spieler[num2].cx;
       t4:=spieler[num2].cy;

       for tx:=long downto 0 do begin
        spieler[num2].weg[tx].kx:=karte[t3,t4].kx;
        spieler[num2].weg[tx].ky:=karte[t3,t4].ky;
        dec(t3,spieler[num2].weg[tx].kx);
        dec(t4,spieler[num2].weg[tx].ky);
       end;

       findway:=true;
       spieler[num2].weglong:=long;
       exit;
{@5}  end;

{@4} end;
     karte[x,y].ti:=1;

{@3}end;

   end;
{@2}
  end;
{@1}
  findway:=false;
 end;

 procedure error(num9:byte);

 begin
  wx:=851;
  wy:=10;
  case num9 of
   0:exit;
   1:writes('Weg nicht gefunden!');
   2:writes('Zielfeld blockiert!');
   3:writes('Ich bin schon dort!');
  end;
  sound(150);delay(150);nosound;
  sound(100);delay(250);nosound;
 end;

 procedure checkkey;

 begin
  a:=#0;
  if keypressed then begin
   a:=readkey;if a=#0 then a:=readkey;
   case a of
    '+':if ak>=anz then ak:=1 else inc(ak);
    '-':if ak<=1 then ak:=anz-1 else dec(ak);
    #77:begin if scrollx>-max then dec(scrollx);if scrolly<max then inc(scrolly);end;
    #75:begin if scrollx<max then inc(scrollx);if scrolly>-max then dec(scrolly);end;
    #80:begin if scrolly>-max then dec(scrolly);if scrollx>-max then dec(scrollx);end;
    #72:begin if scrolly<max then inc(scrolly);if scrollx<max then inc(scrollx);end;
   end;
  end;
 end;
begin
 init_mode13;

 loadgif('drac6');
 show_pic13;
 getsprite(170*320,120,27,leer);
 for x3:=0 to 7 do for y3:=0 to 4 do getsprite(x3*16+(y3*27)*320,16,27,leut[x3,y3]);
 for x3:=0 to 7 do for y3:=0 to 2 do getsprite(x3*16+(y3*27)*320+127,16,27,leut[x3,y3+5]);

 loadgif('ocean6');
 show_pic13;
 getsprite(0+ 0*320,32,16,grass[0]);
 getsprite(0+16*320,32,16,grass[1]);
 getsprite(0+32*320,32,16,grass[2]);
 getsprite(0+48*320,32,16,grass[3]);
 getsprite(64+16*320,32,16,grass[4]);
 getsprite(0+165*320,32,16,grid);

 loadgif('font168');
 show_pic13;
 getsprite(85*320,20,20,hand);
 initfont(0,0,6,8);

 initvesa($105);
 loadgif('ocean6'); {Palette laden!}
 randomize;

 asm mov ax,0;int $33;end;
 x2:=maxx[akmodus]-40;y2:=maxy[akmodus]-40;
 asm mov ax,7;mov cx,0;mov dx,x2;int $33;end;
 asm mov ax,8;mov cx,1;mov dx,y2;int $33;end;

 for x3:=0 to max do for y3:=0 to max do if random(2)=0 then fauna[x3,y3]:=0 else fauna[x3,y3]:=random(4)+1;
 for x3:=0 to max do fauna[x3,0]:=0;
 for x3:=0 to max do fauna[0,x3]:=0;
 for x3:=0 to max do fauna[max,x3]:=0;
 for x3:=0 to max do fauna[x3,max]:=0;
 for x5:=1 to anz-1 do begin
  spieler[x5].ax:=random(max);
  spieler[x5].ay:=random(max);
  spieler[x5].sx:=spieler[x5].ax;
  spieler[x5].sy:=spieler[x5].ay;
  spieler[x5].cx:=spieler[x5].ax;
  spieler[x5].cy:=spieler[x5].ay;
  fauna[spieler[x5].ax,spieler[x5].ay]:=random(4)+1;
  fauna[spieler[x5].cx,spieler[x5].cy]:=random(4)+1;
  stop(x5);
 end;

repeat
checkkey;
fill;
for xx:=0 to max do for yy:=0 to max do
begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
if (x4>=0) and (y4>=0) and (x4<950) and (y4<700) then begin
if (xx=0) or (xx=max) or (yy=0) or (yy=max) then
newput(x4,y4,grass[4]) else {begin}
if fauna[xx,yy]>0 then newput(x4,y4,grass[fauna[xx,yy]-1]) else
newput(x4,y4,grass[4]);
{newput(x4,y4,grid);
end;}
end;
end;

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
if ttx<1 then ttx:=1;
if tty<1 then tty:=1;
if ttx>max-1 then ttx:=max-1;
if tty>max-1 then tty:=max-1;
t1:=(ttx+scrollx)*16-(tty+scrolly)*16;
t2:=(ttx+scrollx)*8+(tty+scrolly)*8;
if (t1>=0) and (t2>=0) and (t1<950) and (t2<700) then newput(t1,t2,grid);
putimage(oox,ooy);
getimage(bax,bay-1);
newput(bax,bay,hand);
for x5:=1 to anz-1 do begin
if spieler[x5].wegp>spieler[x5].weglong+1 then begin
spieler[x5].wegp:=0;
spieler[x5].weglong:=0;
end;
if ((a=#32) or ((omp=0) and (mp=1))) and (ak=x5) and (ttx>0) and (ttx<max) and (tty>0) and (tty<max)
and ((ttx<>spieler[x5].cx) or (tty<>spieler[x5].cy)) {and ((ttx<>spieler.ax) or (tty<>spieler.ay))}
then
if (karte[ttx,tty].i=0) then begin
{if (t1>=0) and (t2>=0) and (t1<950) and (t2<700) then newput(t1,t2,grid);}
spieler[x5].cx:=ttx {div 32};
spieler[x5].cy:=tty {div 32};
{if spieler.weglong=0 then begin}
spieler[x5].wegp:=0;
fillchar(spieler[x5].weg,sizeof(spieler[x5].weg),0);
sound(100);delay(10);nosound;
if findway(x5)=false then begin
wx:=851;
wy:=10;
writes('Weg nicht gefunden!');
sound(150);delay(150);nosound;
sound(100);delay(250);nosound;
stop(x5);
end;
{end{ else
spieler.newgo:=true};

end else begin
newput(t1,t2,grass[2]);
{sound(100);delay(150);nosound;}end;



spieler[x5].richtung:=richtung(spieler[x5].weg[spieler[x5].wegp].kx,spieler[x5].weg[spieler[x5].wegp].ky);
x4:=(spieler[x5].ax+scrollx)*16-(spieler[x5].ay+scrolly)*16+spieler[x5].px;
y4:=(spieler[x5].ax+scrollx)*8+(spieler[x5].ay+scrolly)*8+spieler[x5].py;
if (x4>=-8) and (y4>=12) and (x4<950-8) and (y4<712) then begin
{newput(x4+,y4,grass[2]);}
if ak=x5 then newput(x4,y4,grid);
newput(x4+8,y4-16,leut[spieler[x5].phase mod 8,spieler[x5].richtung mod 8]);
end;
waitretrace;
if spieler[x5].weglong>0 then begin
{for yy:=0 to max do
begin
x4:=(xx+scrollx)*16-(yy+scrolly)*16;
y4:=(xx+scrollx)*8+(yy+scrolly)*8;
if (x4>=-) and (y4>=0) and (x4<950-) and (y4<700) then
if karte[xx,yy].i>0 then newput(x4-16+,y4-56,baum);
end;                                                   }
{if spieler.wait>0 then dec(spieler.wait) else begin}
inc(spieler[x5].px,(spieler[x5].weg[spieler[x5].wegp].kx-spieler[x5].weg[spieler[x5].wegp].ky)*4);
inc(spieler[x5].py,(spieler[x5].weg[spieler[x5].wegp].kx+spieler[x5].weg[spieler[x5].wegp].ky)*2);
inc(spieler[x5].phase);
if spieler[x5].phase>7 then spieler[x5].phase:=0;
if (abs(spieler[x5].px)+abs(spieler[x5].py)*2)>32 then begin
spieler[x5].px:=0;spieler[x5].py:=0;
inc(spieler[x5].ax,spieler[x5].weg[spieler[x5].wegp].kx);
inc(spieler[x5].ay,spieler[x5].weg[spieler[x5].wegp].ky);
{if spieler.newgo then begin
spieler.wegp:=0;
fillchar(weg,sizeof(weg),0);
if findway=false then halt;
end else}
inc(spieler[x5].wegp);
inc(spieler[x5].px,(spieler[x5].weg[spieler[x5].wegp].kx-spieler[x5].weg[spieler[x5].wegp].ky)*2);
inc(spieler[x5].py,(spieler[x5].weg[spieler[x5].wegp].kx+spieler[x5].weg[spieler[x5].wegp].ky)*1);
if (spieler[x5].ax=spieler[x5].cx) and (spieler[x5].ay=spieler[x5].cy) then begin
stop(x5);
end;
{end;}
end;
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