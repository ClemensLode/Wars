uses crt,sprites,modexlib,gif;
const max=1;
var s:array[1..8] of spritetyp;
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
inc(i);
if i>8 then i:=1;
waitretrace;
delay(100);
clrx($1F);
putsprite(vpage,1,1,s[i]);
until keypressed;
textmode(3);
end.