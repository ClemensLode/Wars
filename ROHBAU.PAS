unit rohbau;
interface
function anzahl(art:word):word;
function artzusprite(nummer:byte):byte;
function g(h:word):word;
procedure baueweiter;
function r(gart:word):integer;
procedure Dorfgrafik;
procedure Feldinfo;
procedure MainInfo;
procedure fenster;
{procedure choose(sp:byte);
begin
repeat
case readkey of
#80:if reihe>1 then dec(reihe) else reihe:=max;
#72:if reihe<max then inc(reihe) else reihe:=1;
#13:}
{procedure Datei;
var spalte:byte;
begin
repeat
case readkey of
#72:
#80:
#13:begin clrscr;case spalte of
1:Save;
2:Load;
3:Exit;
end;
#27:begin clrscr;exit;end;


until false;
end;
procedure menu;
var spalte:byte;
begin
textbackground(lightgray);
writeln;
gotoxy(1,1);
spalte:=1;
repeat
gotoxy(1,1);
if spalte=1 then textbackground(blue) else textbackground(lightgray);
write('Datei':14);
if spalte=2 then textbackground(blue) else textbackground(lightgray);
write('Regierung':14);
if spalte=3 then textbackground(blue) else textbackground(lightgray);
write('Rohstoffe':14);
if spalte=4 then textbackground(blue) else textbackground(lightgray);
write('Herstellung':14);
case readkey of
#75:if spalte>1 then dec(spalte) else spalte:=4;
#77:if spalte<4 then inc(spalte) else spalte:=1;
#27:begin textbackground(0);clrscr;screen;exit;end;
#13:begin clrscr;case spalte of
1:Datei;
2:Regie;
3:Rohst;
4:Herst;
end;end;
end;
until false;
end;}
procedure gener;
procedure aufw;
procedure built(zahl,z2:word);
procedure Versorgung;
procedure fight2;
procedure fight;
procedure produziere;
procedure screen;
implementation
uses variable,crt;
function anzahl(art:word):word;
begin
 s[m]^.temp:=0;
 for j:=1 to max do begin
  if s[m]^.haus[j].art=art then inc(s[m]^.temp);
 end;
 anzahl:=s[m]^.temp;
end;
function artzusprite(nummer:byte):byte;
var temp:byte;
begin
temp:=nummer;
case nummer of
3:temp:=17;
5:temp:=3;
6:temp:=5;
7:temp:=8;
8:temp:=18;
9:temp:=19;
10:temp:=20;
11:temp:=7;
12:temp:=11;
13:temp:=11;
14:temp:=13;
15:temp:=16;
16:temp:=15;
17:temp:=16;
18:temp:=16;
19:temp:=16;
20:temp:=16;
21:temp:=14;
22:temp:=16;
23:temp:=9;
24:temp:=6;
25:temp:=16;
26:temp:=16;
27:temp:=12;
28:temp:=16;
29:temp:=10;
end;
artzusprite:=temp;
end;
function g(h:word):word;
begin
case h of
1:g:=1;
2:g:=3;
3:g:=6;
4:g:=11;
5:g:=21;
6:g:=42;
end;
end;
procedure baueweiter;
var nummer:word;
begin
for nummer:=1 to max do if (s[m]^.haus[nummer].baurunden>0) and (s[m]^.bauen>0) then begin
dec(s[m]^.bauen);
dec(s[m]^.haus[nummer].baurunden);
if s[m]^.haus[nummer].baurunden=0 then begin
if s[m]^.haus[nummer].imaufw then inc(s[m]^.haus[nummer].stufe);
s[m]^.haus[nummer].arb:=true;
s[m]^.haus[nummer].le:=kosten[s[m]^.haus[nummer].stufe].le;
s[m]^.haus[nummer].rs:=kosten[s[m]^.haus[nummer].stufe].rs;
nummer:=max;exit;
end;
end;
end;


function r(gart:word):integer;
var s:byte;
begin
s:=1;
repeat
if s<6 then begin
if n[gart,s]='-' then inc(s) else begin r:=s;exit;end;
end;
until s=6;
r:=0;
end;
procedure Dorfgrafik;
var xx:word;
begin
for xx:=1 to max do begin
gotoxy(s[m]^.haus[xx].xx,s[m]^.haus[xx].yy);
textcolor(s[m]^.haus[xx].art);textbackground(s[m]^.haus[xx].stufe);write(chr(s[m]^.haus[xx].art+13));
end;
textcolor(2);textbackground(0);gotoxy(x,y);write(#1);
end;
procedure Feldinfo;
 var o:word;ok:boolean;
begin
 ok:=true;
 for o:=1 to max do if (s[m]^.haus[o].xx=x) and (s[m]^.haus[o].yy=y) then begin
  writeln('Rounds To Built: ',s[m]^.haus[o].baurunden);
  writeln('Art    : ',n[s[m]^.haus[o].art,s[m]^.haus[o].stufe]:20,' Holzbretter : ',s[m]^.p[6]:5);
  writeln('Stufe  : ',chr(s[m]^.haus[o].stufe+64):20,' Granit      : ',s[m]^.p[8]:5);
  writeln('Nahrung: ',s[m]^.haus[o].nahrung:20,' Stahl       : ',s[m]^.p[9]:5);
  writeln('X      : ',s[m]^.haus[o].xx:20,' Ziegel      : ',s[m]^.p[11]:5);
  writeln('Y      : ',s[m]^.haus[o].yy:20,' Lehm        : ',s[m]^.p[9]:5);
  writeln('Arbeit : ',s[m]^.haus[o].ak:20,' Kohle       : ',s[m]^.p[26]:5);
  writeln({arbeit^[s[m]^.haus[o].art,s[m]^.haus[o].stufe,s[m]^.haus[o].arb]}' ':29,' Eisenerz    : ',s[m]^.p[27]:5);
  writeln('Lebensenergie : ',s[m]^.haus[o].le:14,' Golderz     : ',s[m]^.p[28]:5);
  writeln('Ruestungsschutz : ',s[m]^.haus[o].rs:12,' Leder       : ',s[m]^.p[17]:5);
  writeln('         ':29,' Goldmuenzen : ',s[m]^.p[20]:5);
  writeln('         ':29,' Nahrung     : ',s[m]^.p[14]:5);
  writeln('         ':29,' Wasser      : ',s[m]^.p[3]:5);
  writeln('         ':29,' Waffe       : ',s[m]^.p[22]:5);
  writeln('         ':29,' Ruestung    : ',s[m]^.p[23]:5);
  writeln('         ':29,' Einheiten   : ',s[m]^.p[12]:5);
  writeln('         ':29,' Diamanten   : ',s[m]^.p[13]:5);
  ok:=false;
  break;
 end;
 if ok  then begin
  writeln('Rounds To Built: ',s[m]^.haus[o].baurunden);
  writeln('Art    : ',n[s[m]^.haus[o].art,s[m]^.haus[o].stufe]:20,' Holzbretter : ',s[m]^.p[6]:5);
  writeln('Stufe  : ','A':20,' Granit      : ',s[m]^.p[8]:5);
  writeln('Nahrung: ',s[m]^.haus[o].nahrung:20,' Stahl       : ',s[m]^.p[9]:5);
  writeln('X      : ',x:20,' Ziegel      : ',s[m]^.p[11]:5);
  writeln('Y      : ',y:20,' Lehm        : ',s[m]^.p[9]:5);
  writeln('Arbeit : ',s[m]^.haus[o].ak:20,' Kohle       : ',s[m]^.p[26]:5);
  writeln('Lebensenergie : ',s[m]^.haus[o].le:14,' Eisenerz    : ',s[m]^.p[27]:5);
  writeln('Ruestungsschutz : ',s[m]^.haus[o].rs:12,' Golderz     : ',s[m]^.p[28]:5);
  writeln('         ':29,' Leder       : ',s[m]^.p[17]:5);
  writeln('         ':29,' Goldmuenzen : ',s[m]^.p[20]:5);
  writeln('         ':29,' Nahrung     : ',s[m]^.p[14]:5);
  writeln('         ':29,' Wasser      : ',s[m]^.p[3]:5);
  writeln('         ':29,' Waffe       : ',s[m]^.p[22]:5);
  writeln('         ':29,' Ruestung    : ',s[m]^.p[23]:5);
  writeln('         ':29,' Einheiten   : ',s[m]^.p[12]:5);
  writeln('         ':29,' Diamanten   : ',s[m]^.p[13]:5);
 end;
end;
procedure MainInfo;
begin
 writeln('Hauptrohstoffe:');
 writeln('Holz     : ',s[m]^.p[6]);
 writeln('Granit   : ',s[m]^.p[8]);
 writeln('Ziegel   : ',s[m]^.p[11]);
 writeln('Stahl    : ',s[m]^.p[9]);
 writeln('Nahrung  : ',s[m]^.p[14]);
 writeln('Wasser   : ',s[m]^.p[3]);
 writeln('Gold     : ',s[m]^.p[20]);
 writeln('Kohle    : ',s[m]^.p[26]);
 writeln('Noch ',s[m]^.bauen,' Gebaeude bauen!');
 writeln('Wissenstand: ',s[m]^.wissen);
 writeln('Steuern   : ',s[m]^.steu,' %');
 writeln('Verteilung: ',s[m]^.Steuern,' % Gold ',100-s[m]^.steuern,' % Nahrung');
 writeln('Dorf: ',s[m]^.dorf,' Einwohner (',s[m]^.DORF DIV 100,'N u. T)');
 writeln('Unruhe im Dorf :',round(s[m]^.dorf/100*s[m]^.unruhe));
 writeln('Ruestungsart : ',rus[s[m]^.rustung].s:20,':',s[m]^.ruestungen[s[m]^.rustung].prod);
 writeln('Waffenart    : ',waf[s[m]^.weapon].s:20,':',s[m]^.waffen[s[m]^.weapon].prod);
 if s[m]^.ch=1 then s[m]^.temp:=hauser else s[m]^.temp:=s[m]^.ch-1;
 write('  Art: ',n[s[m]^.temp,r(s[m]^.temp)]:20,'   ',chr(r(s[m]^.temp)+64));
 textcolor(s[m]^.temp);textbackground(r(s[m]^.temp));writeln(chr(s[m]^.temp+13));
 textcolor(2);textbackground(0);
 s[m]^.temp:=s[m]^.ch;
 write('>>Art: ',n[s[m]^.ch,r(s[m]^.temp)]:20,'   ',chr(r(s[m]^.temp)+64));
 textcolor(s[m]^.temp);textbackground(r(s[m]^.temp));write(chr(s[m]^.temp+13));
 textcolor(2);textbackground(0);writeln('   ',s[m]^.temp);
 if s[m]^.ch>=hauser then s[m]^.temp:=1 else s[m]^.temp:=s[m]^.ch+1;
 write('  Art: ',n[s[m]^.temp,r(s[m]^.temp)]:20,'   ',chr(r(s[m]^.temp)+64));
 textcolor(s[m]^.temp);textbackground(r(s[m]^.temp));writeln(chr(s[m]^.temp+13));
 textcolor(2);textbackground(0);
end;
procedure fenster;
begin
for i:=1 to 25 do if s[m]^.fehler[i] then begin clrscr;s[m]^.fehler[i]:=false;writeln(help[i]);readkey;end;
end;
procedure screen;
begin
window(1,1,80,25);
clrscr;
if fa then exit;
textbackground(0);
window(1,2,25,25);
clrscr;
Dorfgrafik;
window(1,20,25,25);
fenster;
window(26,2,80,25);
if main then Maininfo;
if feld then Feldinfo;
textbackground(0);
window(1,1,80,25);
end;
{procedure choose(sp:byte);
begin
repeat
case readkey of
#80:if reihe>1 then dec(reihe) else reihe:=max;
#72:if reihe<max then inc(reihe) else reihe:=1;
#13:}
{procedure Datei;
var spalte:byte;
begin
repeat
case readkey of
#72:
#80:
#13:begin clrscr;case spalte of
1:Save;
2:Load;
3:Exit;
end;
#27:begin clrscr;exit;end;


until false;
end;
procedure menu;
var spalte:byte;
begin
textbackground(lightgray);
writeln;
gotoxy(1,1);
spalte:=1;
repeat
gotoxy(1,1);
if spalte=1 then textbackground(blue) else textbackground(lightgray);
write('Datei':14);
if spalte=2 then textbackground(blue) else textbackground(lightgray);
write('Regierung':14);
if spalte=3 then textbackground(blue) else textbackground(lightgray);
write('Rohstoffe':14);
if spalte=4 then textbackground(blue) else textbackground(lightgray);
write('Herstellung':14);
case readkey of
#75:if spalte>1 then dec(spalte) else spalte:=4;
#77:if spalte<4 then inc(spalte) else spalte:=1;
#27:begin textbackground(0);clrscr;screen;exit;end;
#13:begin clrscr;case spalte of
1:Datei;
2:Regie;
3:Rohst;
4:Herst;
end;end;
end;
until false;
end;}
procedure gener;
var line:byte;ready:boolean;
begin
clrscr;
line:=2;
repeat
clrscr;
writeln('Mut                  :',s[m]^.eigen[1]);
writeln('Klugheit             :',s[m]^.eigen[2]);
writeln('Charisma             :',s[m]^.eigen[3]);
writeln('Intuition            :',s[m]^.eigen[4]);
writeln('Fingerfertigkeit     :',s[m]^.eigen[5]);
writeln('Gewandtheit          :',s[m]^.eigen[6]);
writeln('Koerperkraft         :',s[m]^.eigen[7]);
writeln('Lebensenergie        :',s[m]^.eigen[8]);
writeln('Astralenergie        :',s[m]^.eigen[9]);
writeln('Waffenlos            :',s[m]^.eigen[10]);
writeln('Speere, Staebe       :',s[m]^.eigen[11]);
writeln('Stichwaffen          :',s[m]^.eigen[12]);
writeln('Aexte, Beile         :',s[m]^.eigen[13]);
writeln('stumpfe Hiebwaffen   :',s[m]^.eigen[14]);
writeln('scharfe Hiebwaffen   :',s[m]^.eigen[15]);
writeln('Schwerter            :',s[m]^.eigen[16]);
writeln('Zweihaender          :',s[m]^.eigen[17]);
writeln('Infanteriewaffen     :',s[m]^.eigen[18]);
writeln('Wurfwaffen           :',s[m]^.eigen[19]);
writeln('Schusswaffen         :',s[m]^.eigen[20]);
writeln('Produziere ... Stueck:',s[m]^.prod);
    s[m]^.einheit[line2].werte[21]:=(s[m]^.einheit[line2].werte[10]-10) div 2+1+(s[m]^.einheit[line2].werte[1]+
    s[m]^.einheit[line2].werte[7]+s[m]^.einheit[line2].werte[6]) div 5;
    s[m]^.einheit[line2].werte[22]:=(s[m]^.einheit[line2].werte[10]-10) div 2+1+(s[m]^.einheit[line2].werte[2]+
    s[m]^.einheit[line2].werte[4]+s[m]^.einheit[line2].werte[6]) div 5;
writeln('Attacke              :',s[m]^.einheit[line2].werte[21]);
writeln('Parade               :',s[m]^.einheit[line2].werte[22]);
{writeln('Kosten in Gold       :',s[m]^.costs/100:4:4);}
writeln('Kosten in Runden     :',s[m]^.rounds/10:4:4);
gotoxy(35,line);
write('<<<');
case readkey of
#72:if line>1 then dec(line);
#80:if line<21 then inc(line);
'+':case line of
1..7:if s[m]^.eigen[line]<20 then begin inc(s[m]^.costs,s[m]^.eigen[line]+1);inc(s[m]^.eigen[line]);inc(s[m]^.rounds
,s[m]^.einheit[line2].werte[line]);end;
8..9:if s[m]^.eigen[line]<100 then begin inc(s[m]^.costs,s[m]^.eigen[line]+5);inc(s[m]^.eigen[line],5);inc(s[m]^.rounds
,s[m]^.einheit[line2].werte[line] div 4);end;
10..20:if s[m]^.eigen[line]<28 then begin inc(s[m]^.costs,s[m]^.eigen[line]+1);inc(s[m]^.eigen[line]);inc(s[m]^.rounds
,s[m]^.einheit[line2].werte[line] div 2);end;
21:if s[m]^.prod<soldier then inc(s[m]^.prod);
end;
'-':case line of
1..7:if s[m]^.eigen[line]>0 then begin dec(s[m]^.costs,s[m]^.eigen[line]);dec(s[m]^.eigen[line]);dec(s[m]^.rounds);end;
8..9:if s[m]^.eigen[line]>0 then begin dec(s[m]^.costs,s[m]^.eigen[line]);dec(s[m]^.eigen[line],5);dec(s[m]^.rounds);end;
10..20:if s[m]^.eigen[line]>0 then begin dec(s[m]^.costs,s[m]^.eigen[line]);dec(s[m]^.eigen[line]);dec(s[m]^.rounds);end;
21:if s[m]^.prod>0 then dec(s[m]^.prod);
end;
#27:begin s[m]^.rounds:=s[m]^.rounds div 10;s[m]^.costs:=s[m]^.costs div 100;clrscr;screen;exit;end;
end;
until (a=#27);
clrscr;
screen;
end;
procedure aufw;
var o:word;d,b:boolean;
begin
hh:=false;
b:=false;
for o:=1 to max do if (s[m]^.haus[o].xx=x) and (s[m]^.haus[o].yy=y) and
(n[s[m]^.haus[o].art,s[m]^.haus[o].stufe+1][1]<>'-')
and (s[m]^.haus[o].stufe<6) {and (s[m]^.wissen>=g(s[m]^.haus[o].stufe)*100)} then begin
   if (s[m]^.p[44]>=kosten[z2].gold) and (s[m]^.p[]>=kosten[z2].holz) and
   (s[m]^.p[8]>=kosten[z2].stein) and (s[m]^.p[19]>=kosten[z2].moertel) and
   (s[m]^.p[9]>=kosten[z2].stahl) and (s[m]^.p[11]>kosten[z2].ziegel) and
   (s[m]^.p[20]>kosten[z2].glas) then begin
   dec(s[m]^.p[20],kosten[z2].gold);dec(s[m]^.p[6],kosten[z2].holz);
   dec(s[m]^.p[8],kosten[z2].stein);dec(s[m]^.p[19],kosten[z2].moertel);
   dec(s[m]^.p[9],kosten[z2].stahl);dec(s[m]^.p[11],kosten[z2].ziegel);
   dec(s[m]^.p[20],kosten[z2].glas);
   s[m]^.haus[i].hunger:=false;s[m]^.haus[i].nahrung:=true;
   dec(s[m]^.dorf,g(z2));b:=true;d:=true;
    end;



if kosten[s[m]^.haus[o].stufe].
1:if (s[m]^.p[6]>1) and (s[m]^.p[8]>1) then begin dec(s[m]^.p[6],2);dec(s[m]^.p[8],2);b:=true;d:=true;end;
2:if (s[m]^.p[6]>2) and (s[m]^.p[8]>2) then begin dec(s[m]^.p[6],3);dec(s[m]^.p[8],3);b:=true;d:=true;end;
3:if (s[m]^.p[11]>1) and (s[m]^.p[6]>3) and (s[m]^.p[8]>3) then begin dec(s[m]^.p[6],4);dec(s[m]^.p[8],4);
dec(s[m]^.p[11],2);b:=true;d:=true;end;
4:if (s[m]^.p[9]>1) and (s[m]^.p[11]>3) and (s[m]^.p[6]>5) and (s[m]^.p[8]>5) then begin dec(s[m]^.p[9],2);dec(s[m]^.p[6],6);
dec(s[m]^.p[8],6);dec(s[m]^.p[11],4);b:=true;d:=true;end;
5:if (s[m]^.p[9]>4) and (s[m]^.p[11]>5) and (s[m]^.p[6]>7) and (s[m]^.p[8]>7) then begin dec(s[m]^.p[9],5);dec(s[m]^.p[6],8);
dec(s[m]^.p[8],8);dec(s[m]^.p[11],6);b:=true;d:=true;end;
6:if (s[m]^.p[9]>9) and (s[m]^.p[11]>9) and (s[m]^.p[6]>9) and (s[m]^.p[8]>9) then begin dec(s[m]^.p[9],10);
dec(s[m]^.p[6],10);dec(s[m]^.p[8],10);dec(s[m]^.p[11],10);b:=true;d:=true;end;
end;
if b then begin
hh:=false;
inc(s[m]^.haus[o].stufe);
s[m]^.haus[o].imaufw:=true;s[m]^.haus[o].baurunden:=kosten[s[m]^.haus[o].stufe].runden;
b:=false;{screen};exit;
end else begin
hh:=false;
if (s[m]^.haus[o].xx<>x) or (s[m]^.haus[o].yy<>y) then begin hh:=true;s[m]^.fehler[11]:=true;end;
if (s[m]^.haus[o].stufe>=6) then begin hh:=true;s[m]^.fehler[12]:=true;end;
if (s[m]^.wissen<g(s[m]^.haus[o].stufe)*100) then begin hh:=true;s[m]^.fehler[8]:=true;end;
if s[m]^.bauen<=0 then begin hh:=true;s[m]^.fehler[9]:=true;end;
if d=false then begin hh:=true;s[m]^.fehler[6]:=true;end;
end;
end;
{screen;}
end;
procedure built(zahl,z2:word);
 var d,q,b:boolean;
begin
  q:=false;
  i:=0;
  b:=false;
  {Pruefen ob bereits Gebaeude auf dem Feld}
  for i:=1 to max do if (s[m]^.haus[i].xx=x) and (s[m]^.haus[i].yy=y) then
  begin s[m]^.fehler[1]:=true;s[m]^.fehler[22]:=true;exit;end;
  {Pruefen ob Strasse in der Naehe}
{  if zahl<>strasse then begin
  repeat
   inc(i);
   if ((s[m]^.haus[i].xx+1=x) and (s[m]^.haus[i].yy+1=y)) or ((s[m]^.haus[i].xx+1=x) and
   (s[m]^.haus[i].yy=y)) or ((s[m]^.haus[i].xx+1=x) and (s[m]^.haus[i].yy-1=y))
   or ((s[m]^.haus[i].xx=x) and (s[m]^.haus[i].yy+1=y)) or ((s[m]^.haus[i].xx=x)
   and (s[m]^.haus[i].yy-1=y))
   or ((s[m]^.haus[i].xx-1=x) and (s[m]^.haus[i].yy+1=y)) or ((s[m]^.haus[i].xx-1=x)
   and (s[m]^.haus[i].yy=y)) or ((s[m]^.haus[i].xx-1=x)
   and (s[m]^.haus[i].yy-1=y)) and (i<>max) and (s[m]^.haus[i].art=strasse) then q:=false else q:=true;
  until ((s[m]^.haus[i].art=strasse) and (q=false)) or (i>=max);
  if (i>=max) or (s[m]^.haus[i].art<>strasse) then begin s[m]^.fehler[1]:=true;s[m]^.fehler[5]:=true;exit;end;
     {Fehler! Keine Strasse in der Naehe}
{ end;}
  for i:=1 to max do begin
  b:=false;
  if {(s[m]^.wissen>=g(z2)*100) and}(s[m]^.haus[i].art=0) and  ((zahl=strasse) or
  (s[m]^.dorf-g(z2)>0)) then begin
   d:=false;
   if (s[m]^.p[20]>=kosten[z2].gold) and (s[m]^.p[6]>=kosten[z2].holz) and
   (s[m]^.p[8]>=kosten[z2].stein) and (s[m]^.p[19]>=kosten[z2].moertel) and
   (s[m]^.p[9]>=kosten[z2].stahl) and (s[m]^.p[11]>kosten[z2].ziegel) and
   (s[m]^.p[20]>kosten[z2].glas) then begin
   dec(s[m]^.p[20],kosten[z2].gold);dec(s[m]^.p[6],kosten[z2].holz);
   dec(s[m]^.p[8],kosten[z2].stein);dec(s[m]^.p[19],kosten[z2].moertel);
   dec(s[m]^.p[9],kosten[z2].stahl);dec(s[m]^.p[11],kosten[z2].ziegel);
   dec(s[m]^.p[20],kosten[z2].glas);
   s[m]^.haus[i].hunger:=false;s[m]^.haus[i].nahrung:=true;
   dec(s[m]^.dorf,g(z2));b:=true;d:=true;
    end;
{    1:if (s[m]^.p[6]>1) and (s[m]^.p[8]>1) then begin dec(s[m]^.p[6],2);dec(s[m]^.p[8],2);b:=true;d:=true;end;
    2:if (s[m]^.p[6]>2) and (s[m]^.p[8]>2) then begin dec(s[m]^.p[6],3);dec(s[m]^.p[8],3);b:=true;d:=true;end;
    3:if (s[m]^.p[11]>1) and (s[m]^.p[6]>3) and (s[m]^.p[8]>3) then
    begin dec(s[m]^.p[6],4);dec(s[m]^.p[8],4);dec(s[m]^.p[11],2);b:=true;d:=true;end;
    4:if (s[m]^.p[9]>1) and (s[m]^.p[11]>3) and (s[m]^.p[6]>5) and (s[m]^.p[8]>5) then begin dec(s[m]^.p[9],2);
    dec(s[m]^.p[6],6);dec(s[m]^.p[8],6);dec(s[m]^.p[11],4);b:=true;d:=true;end;
    5:if (s[m]^.p[9]>4) and (s[m]^.p[11]>5) and (s[m]^.p[6]>7) and (s[m]^.p[8]>7) then begin dec(s[m]^.p[9],5);
    dec(s[m]^.p[6],8);dec(s[m]^.p[8],8);dec(s[m]^.p[11],6);b:=true;d:=true;end;
    6:if (s[m]^.p[9]>9) and (s[m]^.p[11]>9) and (s[m]^.p[6]>9) and (s[m]^.p[8]>9) then begin dec(s[m]^.p[9],10);
    dec(s[m]^.p[6],10);dec(s[m]^.p[8],10);dec(s[m]^.p[11],10);b:=true;d:=true;end;
   end;                                                                       }
   if b then begin
   s[m]^.haus[i].stufe:=z2;s[m]^.haus[i].art:=zahl;
   s[m]^.haus[i].baurunden:=kosten[z2].runden;
   s[m]^.haus[i].xx:=x;s[m]^.haus[i].yy:=y;
   exit;
   end;
   end;
  end;
  if b=false then begin
   s[m]^.fehler[1]:=true;
   if (s[m]^.wissen<g(z2)*100) then s[m]^.fehler[8]:=true;
   if s[m]^.bauen<=0 then s[m]^.fehler[9]:=true;
   if (s[m]^.dorf-g(z2)<=0) then s[m]^.fehler[7]:=true;
   if d=false then s[m]^.fehler[6]:=true;
  end;
 end;
 {screen;}


procedure Versorgung;
 var mul,go,es,tr,ii:word;
begin
 for i:=1 to max do begin
  if (s[m]^.haus[i].art>0) and (s[m]^.haus[i].arb) then begin
   mul:=s[m]^.haus[i].stufe;
   {if haus[i].art=5 then inc(s[m]^.p[14],mul);
   if haus[i].art=8 then inc(s[m]^.p[20],mul);
   if haus[i].art=10 then inc(s[m]^.p[14],mul);
   if haus[i].art=11 then inc(s[m]^.p[3],mul);
   if haus[i].art=strasse then begin inc(s[m]^.p[20],mul);inc(s[m]^.p[14],mul);inc(s[m]^.p[3],mul);end;}
{   if s[m]^.haus[i].art=strasse then mul:=0;
   if s[m]^.haus[i].art=3 then mul:=mul*4;
   if s[m]^.haus[i].art=22 then mul:=mul*2;
   if s[m]^.haus[i].art=16 then mul:=mul*2;
   if s[m]^.haus[i].art=6 then mul:=mul*2;
   if s[m]^.haus[i].art=29 then mul:=mul*8;}
   if (s[m]^.p[14]>=reskosten[mul].nahrung) and (s[m]^.p[20]>=reskosten[mul].gold) and
   (s[m]^.p[3]>=reskosten[mul].nahrung) and (s[m]^.p[6]>=reskosten[mul].holz) and
   (s[m]^.p[8]>=reskosten[mul].stein) and (s[m]^.p[19]>=reskosten[mul].moertel) and
   (s[m]^.p[9]>=reskosten[mul].stahl) and (s[m]^.p[11]>reskosten[mul].ziegel) and
   (s[m]^.p[20]>reskosten[mul].glas) then begin
   dec(s[m]^.p[14],reskosten[mul].nahrung);dec(s[m]^.p[20],reskosten[mul].gold);
   dec(s[m]^.p[3],reskosten[mul].nahrung);dec(s[m]^.p[6],reskosten[mul].holz);
   dec(s[m]^.p[8],reskosten[mul].stein);dec(s[m]^.p[19],reskosten[mul].moertel);
   dec(s[m]^.p[9],reskosten[mul].stahl);dec(s[m]^.p[11],reskosten[mul].ziegel);
   dec(s[m]^.p[20],reskosten[mul].glas);
   s[m]^.haus[i].hunger:=false;inc(s[m]^.haus[i].le,s[m]^.haus[i].le div 10);s[m]^.haus[i].nahrung:=true;
   end else s[m]^.haus[i].nahrung:=false;
  end;
 end;
{ if (s[m]^.p[14]-s[m]^.p[12] div 2>=0) and (s[m]^.p[3]-s[m]^.p[12] div 2>=0) and (s[m]^.p[20]-s[m]^.p[12] div 2>=0)
then begin
  dec(s[m]^.p[14],s[m]^.p[12] div 2);dec(s[m]^.p[3],s[m]^.p[12] div 2);dec(s[m]^.p[20],s[m]^.p[12] div 2);
 end else dec(s[m]^.p[12],s[m]^.p[12] div 10);}
 if (s[m]^.p[14]<50) or (s[m]^.p[3]<50) then s[m]^.fehler[19]:=true;
 if s[m]^.p[20]<50 then s[m]^.fehler[18]:=true;
 if s[m]^.dorf<50 then s[m]^.fehler[21]:=true;
 if (s[m]^.p[6]<20) or (s[m]^.p[8]<20) then s[m]^.fehler[20]:=true;
 for i:=1 to soldier do if s[m]^.einheit[i].da then if (s[m]^.p[3]>0) and (s[m]^.p[14]>0) and (s[m]^.p[20]>0) then begin
  dec(s[m]^.p[20]);dec(s[m]^.p[14]);dec(s[m]^.p[3]);
 end else s[m]^.einheit[i].da:=false;
end;
procedure fight2;
var map:array[1..32,1..20] of record sold,own:byte;end;
marks,marko,tx,ty,vx,vy,pr,ox,oy,xx,yy,xxx,yyy:word;
tab:array[1..8] of record
x,y:shortint;
end;
begin
tab[1].x:=1;tab[2].x:=0;tab[3].x:=-1;tab[4].x:=-1;tab[5].x:=-1;tab[6].x:=0;tab[7].x:=1;tab[8].x:=1;
tab[1].y:=-1;tab[2].y:=-1;tab[3].y:=-1;tab[4].y:=0;tab[5].y:=1;tab[6].y:=1;tab[7].y:=1;tab[8].y:=0;
{initvesa($101);}
asm mov ax,0;int $33;end;
for i:=1 to 32 do for j:=1 to 200 do mem[$a000:i*10+j*320]:=1;
for i:=1 to 320 do for j:=1 to 20 do mem[$a000:i+j*3200]:=1;
for i:=1 to 320 do for j:=1 to 200 do mem[$a000:i+j*320]:=0;
for i:=1 to 32 do for j:=1 to 20 do map[i,j].own:=0;
for i:=1 to soldier do for j:=0 to 1 do begin
s[j]^.einheit[i].x:=i mod 4+j*26+2;
s[j]^.einheit[i].y:=i mod 18+2;
if s[j]^.einheit[i].da then begin
map[s[j]^.einheit[i].x,s[j]^.einheit[i].y].sold:=i;
map[s[j]^.einheit[i].x,s[j]^.einheit[i].y].own:=j+1;end;
s[j]^.einheit[i].ax:=5;
s[j]^.einheit[i].ay:=i mod 18+1;
{s[j]^.einheit[i].phase:=0;
s[j]^.einheit[i].r:=0;                 }
end;
repeat
for i:=1 to 32 do for j:=1 to 20 do mem[$a000:i*10+j*3200]:=map[i,j].own;
for j:=0 to 1 do for i:=1 to soldier do with s[j]^.einheit[i] do if da then begin
if wait then wait:=false else begin
map[ax,ay].own:=0;
map[ax,ay].sold:=0;
tx:=ax;ty:=ay;
if (ax>cx) then dec(tx);
if (ax<cx) then inc(tx);
if (ay<cy) then inc(ty);
if (ay>cy) then dec(ty);
if map[tx,ty].sold=0 then begin ax:=tx;ay:=ty;end else
if map[ax+(tx-ax),ay].sold=0 then ax:=tx else
if map[ax,ay+(ty-ay)].sold=0 then ay:=ty else wait:=true;
map[ax,ay].sold:=i;
map[ax,ay].own:=j+1;
mem[$a000:ax*10+ay*3200]:=1;
mem[$a000:xx+yy*320]:=4;
end;
asm mov ax,3;int $33;mov xx,cx;mov yy,dx;end;
if xx>=320 then xx:=319;
if yy>=200 then yy:=199;
cx:=xx div 10;cy:=yy div 10;
end;
{asm mov ax,$3;int $33;mov pr,bx;mov xx,cx;mov yy,dx;end;
if xx>319 then xx:=319;
if yy>199 then yy:=199;
if xx<10 then xx:=10;
if yy<10 then yy:=10;
if (xx div 10*10<>ox) or (yy div 10*10<>oy) then begin
ox:=xx div 10*10;oy:=yy div 10*10;
for i:=1 to 32 do for j:=1 to 200 do mem[$a000:i*10+j*320]:=marks;
for i:=1 to 320 do for j:=1 to 20 do mem[$a000:i+j*3200]:=marko;
xxx:=xx div 10*10;yyy:=yy div 10*10;
for i:=0 to 10 do mem[$a000:xxx+i+yyy*320]:=4;
for i:=1 to 10 do mem[$a000:xxx+i+(yyy+10)*320]:=4;
for i:=1 to 10 do mem[$a000:xxx+(yyy+i)*320]:=4;
for i:=1 to 10 do mem[$a000:xxx+10+(yyy+i)*320]:=4;
for i:=1 to 32 do for j:=1 to 20 do mem[$a000:i*10+5+j*3200+5*320]:=map[i,j].own;
mem[$a000:s[marko].einheit[marks].x*10+5+s[marko].einheit[marks].y*3200+5*320]:=yellow;
end;
xxx:=xxx div 10;yyy:=yyy div 10;
if (pr=2) and (marks>0) then begin
pr:=0;
mem[$a000:11+11*320]:=random(255);
vx:=xxx;vy:=yyy;
i:=0;
while (map[vx,vy].own>0) and (i<9) do begin
inc(i);
vx:=xxx+tab[i].x;vy:=yyy+tab[i].y;
end;
s[marko].einheit[marks].ax:=vx;
s[marko].einheit[marks].ay:=vy;
end;
if (pr=1) and (map[xxx,yyy].sold>0) then begin
marks:=map[xxx,yyy].sold;marko:=map[xxx,yyy].own;
pr:=0;
end;
mem[$a000:s[marko].einheit[marks].x*10+5+s[marko].einheit[marks].y*3200+5*320]:=yellow;
for i:=1 to soldier do for j:=0 to 1 do begin
map[s[j]^.einheit[i].x,s[j]^.einheit[i].y].sold:=0;
map[s[j]^.einheit[i].x,s[j]^.einheit[i].y].own:=0;
if s[j]^.einheit[i].x>s[j]^.einheit[i].ax then dec(s[j]^.einheit[i].x);
if s[j]^.einheit[i].x<s[j]^.einheit[i].ax then inc(s[j]^.einheit[i].x);
if s[j]^.einheit[i].y>s[j]^.einheit[i].ay then dec(s[j]^.einheit[i].y);
if s[j]^.einheit[i].y<s[j]^.einheit[i].ay then inc(s[j]^.einheit[i].y);
map[s[j]^.einheit[i].x,s[j]^.einheit[i].y].sold:=i;
map[s[j]^.einheit[i].x,s[j]^.einheit[i].y].own:=j+1;
end;
delay(100);}
until keypressed;
textmode(3);
end;
procedure fight;
var kk,e1,e2:word;
map:array[1..32,1..20] of byte;
wisch,arg:boolean;
ll:longint;
tta,ttp:integer;
begin
clrscr;
writeln('Kampfmodus: Willst du mit deinen Kaempfern wirklich angreifen?');
if upcase(readkey)='J' then begin
le1:=1;le2:=1;e1:=1;e2:=1;
for i:=1 to soldier do if s[0]^.einheit[i].da then inc(e1);
for i:=1 to soldier do if s[1]^.einheit[i].da then inc(e2);
for i:=1 to soldier do if s[0]^.einheit[i].da then inc(le1,s[0]^.einheit[i].werte[8]);
for i:=1 to soldier do if s[1]^.einheit[i].da then inc(le2,s[1]^.einheit[i].werte[8]);
clrscr;
writeln('Player 1 Einheiten      : ',e1:5,'            Player 2 Einheiten      : ',e2:5);
writeln('Player 1 Lebensenergie  : ',le1:5,'            Player 2 Lebensenergie  : ',le2:5);
writeln('Player 1 Le pro Einheit : ',le1 div e1:5,'            Player 2 Le pro Einheit : ',le2 div e2:5);
readkey;
kk:=0;
for i:=1 to soldier do begin s[0]^.einheit[i].x:=random(310)+1;s[0]^.einheit[i].y:=i+50;

ll:=0;
repeat
inc(ll);
inc(kk);
if kk>soldier then kk:=1;
until s[1]^.einheit[kk].da or (ll>soldier*soldier);
if (ll<soldier*soldier) then s[0]^.einheit[i].f:=kk;end;
kk:=0;
for i:=1 to soldier do begin s[1]^.einheit[i].x:=random(310)+1;s[1]^.einheit[i].y:=i+50;

ll:=0;
repeat
inc(ll);
inc(kk);
if kk>soldier then kk:=1;
until s[0]^.einheit[kk].da or (ll>soldier*soldier);
s[1]^.einheit[i].f:=kk;end;
{initvesa($101);}
repeat
{wisch:=not wisch;}
for bb:=1 to 64000 do mem[$a000:bb]:=0;
kk:=0;
with s[0]^ do begin
for i:=1 to soldier do if einheit[i].da then begin
if (abs(einheit[i].x-s[1]^.einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich) and
(abs(einheit[i].y-s[1]^.einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich) then begin
if (einheit[i].x<s[1]^.einheit[einheit[i].f].x) and (einheit[i].y<s[1]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y+1*320]=0) then begin inc(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[1]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[1]^.einheit[einheit[i].f].x) and (einheit[i].y<s[1]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y+1*320]=0) then begin dec(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);;until s[1]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x<s[1]^.einheit[einheit[i].f].x) and (einheit[i].y>s[1]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y-1*320]=0) then begin inc(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);;until s[1]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[1]^.einheit[einheit[i].f].x) and (einheit[i].y>s[1]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y-1*320]=0) then begin dec(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);;until s[1]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
end;
if abs(einheit[i].x-s[1]^.einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].x<s[1]^.einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].x>s[1]^.einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
end;
if abs(einheit[i].y-s[1]^.einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].y<s[1]^.einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);
if (einheit[i].y>s[1]^.einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
end;
{if (einheit[i].x-s[1]^.einheit[einheit[i].f].x>waf[einheit[i].waf[1]].reich) and
(mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
if (-(einheit[i].x-s[1]^.einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].y-s[1]^.einheit[einheit[i].f].y>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
if (-(einheit[i].y-s[1]^.einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);}
mem[$a000:einheit[i].x+einheit[i].y*320]:=einheit[i].werte[8];
if (einheit[i].x+waf[einheit[i].waf[1]].reich>=s[1]^.einheit[einheit[i].f].x) and
(einheit[i].x-waf[einheit[i].waf[1]].reich<=s[1]^.einheit[einheit[i].f].x) and
(einheit[i].y+waf[einheit[i].waf[1]].reich>=s[1]^.einheit[einheit[i].f].y) and
(einheit[i].y-waf[einheit[i].waf[1]].reich<=s[1]^.einheit[einheit[i].f].y) then begin
if waf[einheit[i].waf[1]].wava-waf[s[1]^.einheit[einheit[i].f].waf[1]].wavp<0 then tta:=einheit[i].werte[21]+
waf[einheit[i].waf[1]].wava-waf[s[1]^.einheit[einheit[i].f].waf[1]].wavp else
if waf[einheit[i].waf[1]].wava-waf[s[1]^.einheit[einheit[i].f].waf[1]].wavp>0 then ttp:=s[1]^.einheit[einheit[i].f].werte[21]-
waf[einheit[i].waf[1]].wava+waf[s[1]^.einheit[einheit[i].f].waf[1]].wavp else begin tta:=einheit[i].werte[21];ttp:=
s[1]^.einheit[einheit[i].f].werte[22];END;
if random(20)+1<=tta then begin
if (einheit[i].waf[1]>21) or (random(20)+1>ttp) then
dec(s[1]^.einheit[einheit[i].f].werte[8],waf[einheit[i].waf[1]].tp*(random(6)+1)+waf[s[0]^.einheit[i].waf[1]].tp
-rus[s[1]^.einheit[einheit[i].f].rus[1]].rs);
if s[1]^.einheit[einheit[i].f].werte[8]<=0 then begin
s[1]^.einheit[einheit[i].f].da:=false;s[1]^.einheit[einheit[i].f].werte[8]:=0;
LL:=0;
repeat
inc(kk);
INC(LL);
if kk>soldier then kk:=1;
until s[1]^.einheit[kk].da OR (LL>SOLDIER*SOLDIER);
if (ll<soldier*soldier) then einheit[i].f:=kk;end;
end;
end;end;end;
kk:=0;
with s[1]^ do begin
for i:=1 to soldier do if einheit[i].da then begin
if (abs(einheit[i].x-s[0]^.einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich) and
(abs(einheit[i].y-s[0]^.einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich) then begin
if (einheit[i].x<s[0]^.einheit[einheit[i].f].x) and (einheit[i].y<s[0]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y+1*320]=0) then begin inc(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[0]^.einheit[einheit[i].f].x) and (einheit[i].y<s[0]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y+1*320]=0) then begin dec(einheit[i].x);inc(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x<s[0]^.einheit[einheit[i].f].x) and (einheit[i].y>s[0]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x+1+einheit[i].y-1*320]=0) then begin inc(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
if (einheit[i].x>s[0]^.einheit[einheit[i].f].x) and (einheit[i].y>s[0]^.einheit[einheit[i].f].y) then
if (mem[$a000:einheit[i].x-1+einheit[i].y-1*320]=0) then begin dec(einheit[i].x);dec(einheit[i].y);end else begin
ll:=0;repeat inc(ll);kk:=random(soldier);until s[0]^.einheit[kk].da or (ll>soldier*soldier);
einheit[i].f:=kk;end;
end;
if abs(einheit[i].x-s[0]^.einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].x<s[0]^.einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].x>s[0]^.einheit[einheit[i].f].x) and (mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
end;
if abs(einheit[i].y-s[0]^.einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich then begin
if (einheit[i].y<s[0]^.einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);
if (einheit[i].y>s[0]^.einheit[einheit[i].f].y) and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
end;
{(mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
if (-(einheit[i].x-s[0]^.einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].y-s[0]^.einheit[einheit[i].f].y>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
if (-(einheit[i].y-s[0]^.einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);}
{if (einheit[i].x-s[0]^.einheit[einheit[i].f].x>waf[einheit[i].waf[1]].reich) and
(mem[$a000:einheit[i].x-1+einheit[i].y*320]=0) then dec(einheit[i].x);
if (-(einheit[i].x-s[0]^.einheit[einheit[i].f].x)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+1+einheit[i].y*320]=0) then inc(einheit[i].x);
if (einheit[i].y-s[0]^.einheit[einheit[i].f].y>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y-1)*320]=0) then dec(einheit[i].y);
if (-(einheit[i].y-s[0]^.einheit[einheit[i].f].y)>waf[einheit[i].waf[1]].reich)
and (mem[$a000:einheit[i].x+(einheit[i].y+1)*320]=0) then inc(einheit[i].y);}
mem[$a000:einheit[i].x+einheit[i].y*320]:=einheit[i].werte[8]+100;
if (einheit[i].x+waf[einheit[i].waf[1]].reich>=s[0]^.einheit[einheit[i].f].x) and
(einheit[i].x-waf[einheit[i].waf[1]].reich<=s[0]^.einheit[einheit[i].f].x) and
(einheit[i].y+waf[einheit[i].waf[1]].reich>=s[0]^.einheit[einheit[i].f].y) and
(einheit[i].y-waf[einheit[i].waf[1]].reich<=s[0]^.einheit[einheit[i].f].y) then begin
if waf[einheit[i].waf[1]].wava-waf[s[0]^.einheit[einheit[i].f].waf[1]].wavp<0 then tta:=einheit[i].werte[21]+
waf[einheit[i].waf[1]].wava-waf[s[0]^.einheit[einheit[i].f].waf[1]].wavp else
if waf[einheit[i].waf[1]].wava-waf[s[0]^.einheit[einheit[i].f].waf[1]].wavp>0 then ttp:=s[0]^.einheit[einheit[i].f].werte[21]-
waf[einheit[i].waf[1]].wava+waf[s[0]^.einheit[einheit[i].f].waf[1]].wavp else
begin tta:=einheit[i].werte[21];ttp:=s[0]^.einheit[einheit[i].f].werte[22];END;
if random(20)+1<=tta then begin
if (einheit[i].waf[1]>21) or (random(20)+1>ttp) then
dec(s[0]^.einheit[einheit[i].f].werte[8],waf[einheit[i].waf[1]].tp*(random(6)+1)+waf[s[1]^.einheit[i].waf[1]].tp
-rus[s[0]^.einheit[einheit[i].f].rus[1]].rs);
if s[0]^.einheit[einheit[i].f].werte[8]<=0 then begin
s[0]^.einheit[einheit[i].f].da:=false;s[0]^.einheit[einheit[i].f].werte[8]:=0;
ll:=0;
kk:=0;
repeat
inc(kk);
inc(ll);
if kk>soldier then kk:=1;
until s[0]^.einheit[kk].da or (ll>soldier*soldier);
s[1]^.einheit[i].f:=kk;end;
end;
end;end;end;
e1:=0;
e2:=0;
le1:=0;
le2:=0;
for i:=1 to soldier do if s[0]^.einheit[i].da then inc(e1);
for i:=1 to soldier do if s[1]^.einheit[i].da then inc(e2);
for i:=1 to soldier do if s[0]^.einheit[i].da then inc(le1,s[0]^.einheit[i].werte[8]);
for i:=1 to soldier do if s[1]^.einheit[i].da then inc(le2,s[1]^.einheit[i].werte[8]);
{for i:=1 to soldier do if s[0]^.einheit[i].da then mem[$a000:s[0]^.einheit[i].x+s[0]^.einheit[i].y*320]:=s[0]^.einheit[i].
werte[8]+1;
for i:=1 to soldier do if s[1]^.einheit[i].da then mem[$a000:s[1]^.einheit[i].x+s[1]^.einheit[i].y*320]:=s[1]^.einheit[i].
werte[8]+1;}
until (le1<=0) or (le2<=0) or keypressed;
readkey;
textmode(3);
if (le1<=5) and (m=1) then loose1:=true else loose1:=false;
if (le2<=5) and (m=0) then loose2:=true else loose2:=false;
clrscr;
end;
end;
procedure produziere;
var bon,mul,ii:word;hep:boolean;
begin
s[m]^.MAXE:=2500;
s[m]^.maxl:=2500;
s[m]^.maxw:=100;
s[m]^.essen:=0;
s[m]^.wasser:=0;
s[m]^.unruhe:=s[m]^.steu;
s[m]^.bauen:=0;
 for i:=1 to max do begin
   if (s[m]^.haus[i].art>0) and (s[m]^.haus[i].arb=true) and (s[m]^.haus[i].nahrung=true) then begin
if s[m]^.haus[i].le>0 then mul:=round(kosten[s[m]^.haus[i].stufe].prodfak*(1/(kosten[mul].le/s[m]^.haus[i].le+1))) else
mul:=0;
if s[m]^.haus[i].le>0 then bon:=round(kosten[s[m]^.haus[i].stufe].prodbon*(1/(kosten[mul].le/s[m]^.haus[i].le+1))) else
bon:=0;
    case s[m]^.haus[i].art of
     1:begin if s[m]^.haus[i].ak=1 then inc(s[m]^.essen,mul+bon) else
             if s[m]^.haus[i].ak>1 then inc(s[m]^.p[s[m]^.haus[i].ak-1],10*(mul+bon));
       end;  {Bauernhof}
     2:begin if s[m]^.haus[i].ak=1 then inc(s[m]^.wasser,mul+bon) else
             if s[m]^.haus[i].ak=2 then inc(s[m]^.p[12],10*(mul+bon));
       end;
        {Wasserloch}
     3:inc(s[m]^.p[13],10*(mul+bon));{Saline}
     4:begin if s[m]^.haus[i].ak=1 then inc(s[m]^.p[14],10*(mul+bon)) else
             if (s[m]^.haus[i].ak=2) and (s[m]^.p[16]>mul*10) then begin
             inc(s[m]^.p[76],10*(mul+bon));dec(s[m]^.p[16],mul*10);end else
             if (s[m]^.haus[i].ak=3) and (s[m]^.p[17]>mul*5) then begin
             inc(s[m]^.p[77],10*(mul+bon));dec(s[m]^.p[17],mul*5);end;
       end;{Fischerzunft}
     5:begin case s[m]^.haus[i].ak of
             1:inc(s[m]^.p[15],10*(mul+bon));                              {Bruchholz einklauben}
             2:if s[m]^.haus[i].stufe>1 then inc(s[m]^.p[16],10*(mul+bon));{Birkenholz schlagen}
             3:if s[m]^.haus[i].stufe>2 then inc(s[m]^.p[17],10*(mul+bon));{Steineichenholz schlagen}
             4:if s[m]^.p[15]>10*mul then begin inc(s[m]^.p[18],10*(mul+bon));dec(s[m]^.p[15],10*mul);end;
             {Stelle Holzkohle aus Bruchholz her}
             5:if s[m]^.p[16]>10*mul then begin inc(s[m]^.p[18],20*(mul+bon));dec(s[m]^.p[16],10*mul);end;
             {Stelle Holzkohle aus Birkenholz her}
             6:if s[m]^.p[17]>10*mul then begin inc(s[m]^.p[18],40*(mul+bon));dec(s[m]^.p[17],10*mul);end;
             {Stelle Holzkohle aus Steineichenholz her}
             end;
        end;{Koehler}
     6:begin case s[m]^.haus[i].ak of
             1:inc(s[m]^.p[19],10*(mul+bon));                              {Sandstein abschlagen}
             2:if s[m]^.haus[i].stufe>1 then inc(s[m]^.p[20],10*(mul+bon));{Granit abschagen}
             3:if s[m]^.haus[i].stufe>2 then inc(s[m]^.p[21],10*(mul+bon));{Basalt abschlagen}
             end;
          end;{Steinmetze}
     7:begin case s[m]^.haus[i].ak of
             1:inc(s[m]^.p[22],10*(mul+bon));                              {Lehm abbauen}
             2:if s[m]^.haus[i].stufe>3 then inc(s[m]^.p[23],10*(mul+bon));{Zement abbauen}
             3:if (s[m]^.haus[i].stufe>2) and (s[m]^.p[22]>10*mul) and (s[m]^.p[29]>10*mul) and (s[m]^.p[12]>10*mul) and
             (s[m]^.p[18]>10*mul) then begin inc(s[m]^.p[24],10*(mul+bon));dec(s[m]^.p[22],10*mul);dec(s[m]^.p[29],10*mul);
             dec(s[m]^.p[12],10*mul);dec(s[m]^.p[18],10*mul);end;{Stelle Lehmziegel aus Lehm her}
             4:if (s[m]^.haus[i].stufe>3) and (s[m]^.p[23]>10*mul) and (s[m]^.p[27]>10*mul) and (s[m]^.p[1]>10*mul) then
             begin inc(s[m]^.p[25],10*(mul+bon));dec(s[m]^.p[23],10*mul);dec(s[m]^.p[27],10*mul);dec(s[m]^.p[1],10*mul);end;
             {Stelle Beton aus Zement her}
             end;
        end;{Lehmgrube}
     8:begin case s[m]^.haus[i].ak of
             1:inc(s[m]^.p[26],10*(mul+bon));                              {Kalk abbauen}
             2:if (s[m]^.haus[i].stufe>2) and (s[m]^.p[12]>10*mul) and (s[m]^.p[29]>10*mul) and (s[m]^.p[26]>10*mul)
             then begin inc(s[m]^.p[27],10*(mul+bon));dec(s[m]^.p[12],10*mul);dec(s[m]^.p[29],10*mul);
             dec(s[m]^.p[26],10*mul);end;{Stelle Moertel aus Kalk her}
        end;
        end;{Kalkgrube}

     9:begin case s[m]^.haus[i].ak of
             1:inc(s[m]^.p[28],10*(mul+bon));                              {Schwefel abbauen}
             end;
        end;{Schwefelgrube}

     10:begin case s[m]^.haus[i].ak of
             1:inc(s[m]^.p[29],10*(mul+bon));                              {Sand abbauen}
             2:if s[m]^.haus[i].stufe>2 then inc(s[m]^.p[23],10*(mul+bon));{Quarzsand abbauen}
             3:if (s[m]^.haus[i].stufe>2) and (s[m]^.p[30]>10*mul) and (s[m]^.p[50]>20*mul) then begin
             inc(s[m]^.p[31],10*(mul+bon));dec(s[m]^.p[30],10*mul);dec(s[m]^.p[50],10*mul);
             end;{Stelle Glas aus Quarzsand her}
             end;
        end;{Sandsammler}
     11:begin case s[m]^.haus[i].ak of
             1:begin
             case random(100)+mul+bon of                 {Durch Zufall festellen welches Tier geschossen wurde}
             0..80:begin inc(s[m]^.p[78],5+bon);inc(s[m]^.p[36],5+bon);inc(s[m]^.p[35],5+bon);end;{Hase}
             81..120:begin inc(s[m]^.p[78],40+bon);inc(s[m]^.p[37],10+bon);inc(s[m]^.p[35],20+bon);end;{Reh}
             121..300:begin inc(s[m]^.p[78],100+bon);inc(s[m]^.p[38],20+bon);inc(s[m]^.p[35],50+bon);end;{Karen}
             end;
             end;
             2:if (s[m]^.haus[i].stufe>2) and (s[m]^.p[36]>10*mul) then begin inc(s[m]^.p[32],10*(mul+bon));dec(s[m]^.p[36],
             10*mul);end;{Gerbe leichtes Fell zu Leichtleder}
             3:if (s[m]^.haus[i].stufe>2) and (s[m]^.p[37]>10*mul) then begin inc(s[m]^.p[33],10*(mul+bon));dec(s[m]^.p[37],
             10*mul);end;{Gerbe normales Fell zu normalem Leder}
             4:if (s[m]^.haus[i].stufe>2) and (s[m]^.p[38]>10*mul) then begin inc(s[m]^.p[34],10*(mul+bon));dec(s[m]^.p[38],
             10*mul);end;{Gerbe dichtes Fell zu Schwerleder}
             end;
        end;{Jaegerzunft}
     12:inc(s[m]^.maxw,(mul+bon)*5);    {Geschichtenerzaehler}
     13:begin case s[m]^.haus[i].ak of
             1:if s[m]^.p[55]>0 then begin inc(s[m]^.p[78]);inc(s[m]^.p[39],5);dec(s[m]^.p[55]);end;{schlachte Huhn}
             2:if s[m]^.p[56]>0 then begin inc(s[m]^.p[78],3);inc(s[m]^.p[39],15);dec(s[m]^.p[56]);end;{schlachte Gans}
             3:if s[m]^.p[60]>0 then begin inc(s[m]^.p[78],100);inc(s[m]^.p[36],25);inc(s[m]^.p[35],25);dec(s[m]^.p[60]);end;
             {schlachte Schwein}
             4:if s[m]^.p[61]>0 then begin inc(s[m]^.p[78],75);inc(s[m]^.p[35],25);dec(s[m]^.p[61]);end;{schlachte Schaf}
             5:if s[m]^.p[62]>0 then begin inc(s[m]^.p[78],25);inc(s[m]^.p[35],15);inc(s[m]^.p[37],15);dec(s[m]^.p[62]);end;
             {schlachte Ziege}
             6:if s[m]^.p[57]>0 then begin inc(s[m]^.p[78],100);inc(s[m]^.p[38],25);inc(s[m]^.p[35],40);dec(s[m]^.p[57]);end;
             {schlachte Kuh}
             7:if s[m]^.p[58]>0 then begin inc(s[m]^.p[78],150);inc(s[m]^.p[37],25);inc(s[m]^.p[35],50);dec(s[m]^.p[58]);end;
             {schlachte Ochse}
             8:if s[m]^.p[59]>0 then begin inc(s[m]^.p[78],75);inc(s[m]^.p[38],50);inc(s[m]^.p[35],50);dec(s[m]^.p[59]);end;
             {schlachte Wildrind}
             9:if (s[m]^.p[78]>10*mul) and (s[m]^.p[13]>2*mul) and (s[m]^.p[6]>2*mul) then begin
               inc(s[m]^.p[40],10*(mul+bon));dec(s[m]^.p[78],10*mul);dec(s[m]^.p[13],2*mul);dec(s[m]^.p[6],2*mul);end;
               {Produziere Wurst}
             end;
        end;{Fleischer, Jagbares Wild?}
        {14:Mueller}
     15:begin inc(s[m]^.maxl,(mul+bon)*2500);inc(s[m]^.maxe,(mul+bon)*2500);end; {Kornspeicher}
     16:if s[m]^.prod>0 then begin
       inc(s[m]^.ro,(mul+bon)*10);if (s[m]^.ro>=s[m]^.rounds) and (s[m]^.dorf>10) {and (s[m]^.p[20]>s[m]^.costs)} then begin
       s[m]^.ro:=0;dec(s[m]^.p[20],(mul+bon)*10);dec(s[m]^.dorf,(mul+bon)*10);
       hep:=false;
       for i:=1 to soldier do begin hep:=false;if s[m]^.einheit[i].da=false then begin
       hep:=true;dec(s[m]^.prod);s[m]^.einheit[i].da:=true;for j:=1 to 25 do s[m]^.einheit[i].werte[j]:=s[m]^.eigen[j];end;
       if hep then begin i:=soldier;break;end;end;end;end;{Kaserne, noch mal anschauen!}
     17:if s[m]^.unruhe>=mul+bon then dec(s[m]^.unruhe,mul+bon) else s[m]^.unruhe:=0;
     {18:Stallungen}
     19:begin
     case s[m]^.haus[i].ak of
     1:if (s[m]^.p[53]>10*mul) and (s[m]^.p[50]>10*mul) then begin dec(s[m]^.p[53],mul*10);dec(s[m]^.p[50],
     mul*10);inc(s[m]^.p[44],10*(mul+bon));end;
     2:if (s[m]^.p[54]>10*mul) and (s[m]^.haus[i].stufe=6) then begin dec(s[m]^.p[54],mul*10);
     inc(s[m]^.p[79],10*(mul+bon));end;
     end;
     end;{Goldschmelze}
     20:inc(s[m]^.bauen,(mul+bon) div 3);{Zimmerei}
     {21:Werkzeugmacher}
     22:begin case s[m]^.haus[i].ak of
             1:if (s[m]^.p[52]>10*mul) and (s[m]^.p[50]>10*mul) then begin inc(s[m]^.p[45],10*(mul+bon));dec(s[m]^.p[50],
             10*mul);dec(s[m]^.p[52],10*mul);end;{Schmelze Eisenerz zu Eisen}
             2:if (s[m]^.p[45]>10*mul) and (s[m]^.p[50]>20*mul) then begin inc(s[m]^.p[46],10*(mul+bon));dec(s[m]^.p[50],
             20*mul);dec(s[m]^.p[45],10*mul);end;{Schmelze Eisen zu Stahl}
        end;
        end;{Eisenschmelze}
     23:if (s[m]^.p[9]>mul+bon) and (s[m]^.p[26]>mul+bon) then begin dec(s[m]^.p[26],(mul+bon)*10);dec(s[m]^.p[9],
     (mul+bon)*10);for i:=1 to ranzahl do
    if s[m]^.ruestungen[i].prod>0 then begin
    dec(s[m]^.ruestungen[i].prod);inc(s[m]^.ruestungen[i].stuck);
    end;end; {Schmiede}
     24:if (s[m]^.p[9]>mul+bon) and (s[m]^.p[26]>mul+bon) then begin dec(s[m]^.p[26],(mul+bon)*10);dec(s[m]^.p[9],
     (mul+bon)*10);for i:=1 to wanzahl do
    if s[m]^.waffen[i].prod>0 then begin
    dec(s[m]^.waffen[i].prod);inc(s[m]^.waffen[i].stuck);
    end;end; {Harnischmacher}
     {25:Bogner}
     {26:Park}
     {27:Tuchmacher}
     {28:Erfinderstatt}
     29:begin inc(s[m]^.p[50],(mul+bon)*10);inc(s[m]^.p[51],(mul+bon)*10);inc(s[m]^.p[52],(mul+bon)*10);inc(s[m]^.p[53],
     (mul+bon)*10);end;
     {Bergwerk,     nochmal anschauen}
     {30:Bergarbeiterzunft}
     {31:Viehzuechter}
     {32:Knochenflicker}
     {33:Haupthaus}
     {34:Wachhaus}
     {35:Strasse}
     {36:Handelsstation}
     {37:Faehrtenleser}
     {38:Hexenkreis}
     {39:Oelbohrturm}
     {40:Winzer}

     {3:
     3:inc(s[m]^.wissen,(mul+bon)*10);
     4:if s[m]^.p[9]>0 then begin dec(s[m]^.p[9],(mul+bon)*10);inc(s[m]^.p[11],(mul+bon)*10);end;
     5:
     6:
     7:
     8:if (s[m]^.p[26]>(mul+bon)*10) and (s[m]^.p[28]>(mul+bon)*10) then begin dec(s[m]^.p[26],(mul+bon)*10);dec(s[m]^.p[28],
     (mul+bon)*10);inc(s[m]^.p[20],
     mul+bon);
     end;
10:
    11:
    12:
    13:
    14:inc(s[m]^.maxe,mul*2500);
{soldiers15:
    16:s[m]^.bauen:=(mul+bon) div 4;
{    21:s[m]^.befehle:=mul;
      29:                  }
    end;
   end;
  end;
screen;
end;
begin
end.