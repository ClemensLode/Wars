uses vesa6,modexlib,gif,crt;
var h:array[1..4] of spritetyp;
i:word;
a:char;
begin
init_mode13;
loadgif('d:\wars\house1');
show_pic13;
getsprite(0,320,200,h[1]);
loadgif('d:\wars\house2');
show_pic13;
getsprite(0,320,200,h[2]);
loadgif('d:\wars\house3');
show_pic13;
getsprite(0,320,200,h[3]);
loadgif('d:\wars\house4');
show_pic13;
getsprite(0,320,200,h[4]);
initvesa($105);
loadgif('d:\wars\house4');
repeat
if keypressed then begin a:=readkey;if a=#0 then a:=readkey;
case a of
'+':inc(hell);
'-':dec(hell);
end;
putpasc(0,0,h[1]);
putpasc(320,0,h[2]);
putpasc(0,200,h[3]);
putpasc(320,200,h[4]);
end;

until a=#27;
textmode(3);
end.
