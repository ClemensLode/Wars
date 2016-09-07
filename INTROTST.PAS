uses crt,modexlib,gif;
var zahl:byte;a:char;
begin
asm mov ax,$13;int $10;end;
loadgif('2');
show_pic13;
randomize;
repeat
pal_rot(1,zahl mod 120);
if keypressed then begin
a:=readkey;
if a='+' then inc(zahl,25) else dec(zahl,25);
end;
setpal;
until a=#27;
textmode(3);
end.