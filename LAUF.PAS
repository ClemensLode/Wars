uses crt,modexlib,gif,vesa4;
var g:array[1..4] of spritetyp;
x:byte;
begin
init_mode13;
loadgif('d:\wars\lauf2.gif');
show_pic13;
for x:=0 to 3 do getsprite(x*32,32,100,g[x+1]);
initvesa($101);
loadgif('d:\wars\lauf2.gif');
for x:=0 to 255 do begin delay(4);putsprite(x*5,100,g[x mod 4+1]);end;
end.

