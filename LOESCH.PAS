uses gif,modexlib,crt,vesa6;
var hand:spritetyp;i:word;
begin
init_mode13;
loadgif('d:\wars\font168.gif');
show_pic13;
getsprite(85*320,20,20,hand);
aktab:=0;
initfont(0,0,6,8);
aktab:=1;
initfont(0,17,6,8);
aktab:=2;
initfont(0,108,12,16);
initschalt(0,33);
initvesa($101);
loadgif('d:\wars\drac5');
for i:=0 to anz do putpasc(i*6,0,zeichen[0,i]);
for i:=0 to anz do putpasc(i*6,8,zeichen[1,i]);
readln;
textmode(3);
end.
