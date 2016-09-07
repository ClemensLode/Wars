uses crt,dos,variable;
var f:text;
ast:string;
begin
assign(f,'ta2.dat');
reset(f);
{for i:=1 to 71 do readln(f,a);}
readln(f,ast);      {Mut,Klugheit, etc.}
for j:=1 to 11 do readln(f,rassen[j].name);
for i:=1 to 83 do begin
readln(f,ast);      {Mut,Klugheit, etc.}
write(ast);
for j:=1 to 11 do readln(f,rassen[j].werte[i]);
end;
close(f);
readkey;
end.
