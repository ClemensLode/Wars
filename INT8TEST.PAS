uses dos,crt;
type proc=procedure;
var oldintvec:pointer;oldproc:proc absolute oldintvec;oldexit:pointer;
j,i:word;
po:array[1..10000] of ^longint;
procedure newintvec;interrupt;
begin
writeln(memavail);
asm pushf;end;
oldproc;
end;
procedure programexit;far;
begin
setintvec($08,oldintvec);
exitproc:=oldexit;
for j:=1 to i do freemem(po[j],4);
port[$20]:=$20;
end;
begin
randomize;
clrscr;
getintvec($08,oldintvec);
oldexit:=exitproc;
exitproc:=@programexit;
setintvec($08,@newintvec);
repeat
delay(100);
inc(i);
getmem(po[i],4);
until keypressed or (i>995);
end.
