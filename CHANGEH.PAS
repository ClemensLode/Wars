uses crt,dos;
var f,z:text;
a:char;
i:longint;
begin
assign(f,'e:\homam2\maps\brokena.mp2');
reset(f);
assign(z,'e:\homam2\maps\broken.mp2');
rewrite(z);
randomize;
i:=0;
for i:=1 to 50000 do begin
read(f,a);
write(z,a);
end;
repeat
gotoxy(1,1);
inc(i);
writeln(i);
read(f,a);
if random(100)=0 then inc(a) else if random(100)=1 then dec(a);
write(z,a);
until i=110000;
for i:=1 to 29387 do begin
read(f,a);
write(z,a);
end;
close(z);
close(f);
end.
