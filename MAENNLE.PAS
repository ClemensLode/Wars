uses crt,vesa2,modexlib,gif;
var s:array[1..41] of spritetyp;
seite,i:word;
j,x:word;
y:byte;
begin
init_mode13;
loadgif('drac2.gif');
show_pic13;
for i:=1 to 8 do getsprite((i-1)*40,40,40,s[i]);
for i:=1 to 8 do getsprite((i-1)*40+40*320,40,40,s[i+8]);
for i:=1 to 8 do getsprite((i-1)*40+80*320,40,40,s[i+16]);
for i:=1 to 8 do getsprite((i-1)*40+120*320,40,40,s[i+24]);
for i:=1 to 8 do getsprite((i-1)*40+160*320,40,40,s[i+32]);
initvesa($101);
loadgif('drac2.gif');
repeat
inc(i);
if i>8 then i:=1;
for j:=0 to 15 do putsprite(
x+(j mod 18)*40+(i mod 8+1)*5
,y+(j div 16)*40+(i mod 8+1)*5,s[(i+j) mod 8+9]);
delay(50);
until keypressed;
textmode(3);
end.