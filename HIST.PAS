uses crt,modexlib,gif,vesa10;
var f:text;
a,b:char;
begin
init_mode13;
loadgif('font16');
show_pic13;
initfont(0,0,16,16);
format:=false;
initvesa($105);
loadgif('font32');
assign(f,'d:\l\WHIST.TXT');
reset(f);
wy:=0;
black:=false;
repeat
read(f,a);
{if a='.' then delay(200);
if a=',' then delay(50);}
writes('.');
{if (a<>#13) and (a<>#10) then writes(upcase(a)) else writes(a);
{delay(100);}
if wy>700 then begin wy:=0;end;
until eof(f) or keypressed;
close(F);
readln;
textmode(3);
end.