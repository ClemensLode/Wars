uses crt,sprites,modexlib,gif;
const max=1;
var s:array[1..5] of spritetyp;
seite,i:word;
e:array[1..max] of record
x:word;
ges,y,i:byte;
ri:shortint;
end;

begin
init_modex;
loadgif('drac.gif');
for i:=0 to 7 do getsprite(i*80,80,136,s[i+1]);
randomize;
for i:=1 to max do begin e[i].x:=random(300);e[i].y:=random(180);e[i].i:=random(4)+1;
e[i].ri:=random(2);if e[i].ri=0 then e[i].ri:=-1;
e[i].ges:=3;
end;
{getsprite(60,20,20,s[4]);}
repeat
for i:=1 to max do begin
{if (e[i].i=0) or (e[i].i=4) then e[i].ri:=-e[i].ri;}
inc(e[i].i{,e[i].ri});
if e[i].i>4 then e[i].i:=0;
{if e[i].i mod 5<>0 then inc(e[i].x,e[i].ges) {else inc(e[i].x)};
if e[i].x>=320 then begin e[i].y:=random(180);e[i].x:=0;end;
end;
{delay(1000);}
waitretrace;
delay(100);
clrx($1F);
for I:=1 to max do putsprite(vpage,e[i].x,e[i].y,s[e[i].i mod 5+1]);
until keypressed;
textmode(3);
end.