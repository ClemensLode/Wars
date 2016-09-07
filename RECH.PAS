uses crt;
var r:extended;
begin
textmode(3);
clrscr;
r:=1;
repeat

write(r,'       ');
r:=1/(1+r);
writeln(r);
until readkey=#27;
end.