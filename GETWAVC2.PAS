uses dos;
type puf=array[1..65535] of byte;
var mix,ziel:file;
gross,akb:longint;
datei:byte;
buf:^puf;
begin
getmem(buf,65535);
assign(mix,'e:\c2\redalert.mix');
reset(mix,1);
assign(ziel,'file1.mix');
rewrite(ziel,1);
gross:=filesize(mix);
akb:=0;
datei:=1;
while akb+65536<gross do begin
blockread(mix,buf^,65535);
blockwrite(ziel,buf^,65535);
inc(akb,65535);
if akb>=GROSS div 4*datei then begin
inc(datei);close(ziel);assign(ziel,'file'+chr(datei+64)+'.mix');
rewrite(ziel,1);
end;
end;
close(ziel);
close(mix);
freemem(buf,65535);
end.
