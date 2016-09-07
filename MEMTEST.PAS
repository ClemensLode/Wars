uses crt;
var I:longint;
temp:word;
function mem32(i:longint):word;external;
{$L mem32}
begin
clrscr;
write('Testing Byte ');
for i:=1 to 8000000 do begin
gotoxy(15,1);writeln(i);
temp:=mem32(i);
write(temp);
end;
end.

