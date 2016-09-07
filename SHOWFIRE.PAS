uses vesa2,crt,gif,modexlib;
var s:array[1..100] of spritetyp;
j,i:longint;
ge:spritetyp;
z:byte;
begin

init_mode13;
loadgif('d:\wars\font168.gif');
aktab:=0;
show_pic13;
initfont(0,0,6,8);
initfont(0,16,6,8);
initschalt(1,33);
{getsprite(0+31*320,61,22,click[3]);
getsprite(0+63*320,61,22,click[4]);}
loadgif('d:\wars\fire.gif');
show_pic13;
for i:=0 to 12 do getsprite(i*23,23,23,s[i+1]);
for i:=0 to 12 do getsprite(i*23+23*320,23,23,s[i+24]);
for i:=0 to 12 do getsprite(i*23+46*320,23,23,s[i+47]);
for i:=0 to 9 do getsprite(i*23+69*320,23,23,s[i+14]);
for i:=0 to 9 do getsprite(i*23+92*320,23,23,s[i+37]);
loadgif('d:\grafik\bilds\gesicht.gif');
show_pic13;
getsprite(0,32,32,ge);
initvesa($105);
loadgif('d:\wars\fire.gif');
randomize;
for i:=1 to 10000 do begin
for j:=0 to 209 do if i mod 2=0 then click((j mod 10)*schaltx,(j div 10)*schalty,1,'SCHALTER') else
click((j mod 10)*schaltx,(j div 10)*schalty,0,'SCHALTER');
if keypressed then i:=10000;
delay(250);end;
readkey;
{for i:=1 to 23 do for j:=0 to 13 do begin {putsprite((j mod 32)*32,(j div 32)*32,ge);}{putsprite((j mod 32)*32+5,(j div 32)
{*32+8,s[i]);end;
if keypressed then exit;
for i:=1 to 46 do for j:=0 to 13 do begin {putsprite((j mod 32)*32,(j div 32)*32,ge);}{putsprite((j mod 32)*32+5,(j div 32)
{*32+8,s[i mod 23+24]);end;
if keypressed then exit;
for i:=1 to 13 do for j:=0 to 13 do begin {putsprite((j mod 32)*32,(j div 32)*32,ge);}{putsprite((j mod 32)*32+5,(j div 32)
{*32+8,s[i+46]);end;
readkey;
readkey;}
textmode(3);
end.

