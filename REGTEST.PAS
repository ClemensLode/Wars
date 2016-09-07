uses variable,crt,gif,vesa2,modexlib;
var kar:array[1..25,1..18] of byte;
begin
init_mode13;
loadgif('felder.gif');
show_pic13;
for i:=0 to 3 do for m:=0 to 2 do getsprite(i*38+(m*38)*320,20,20,regen[i+1,m+1]);
readkey;
textmode(3);
initvesa($101);
randomize;
loadgif('felder.gif');
for i:=1 to 25 do for j:=1 to 18 do kar[i,j]:=random(4)+1;
repeat
for i:=1 to 25 do for j:=1 to 18 do putsprite(i*20,j*20,regen[kar[i,j],random(3)+1]);
until keypressed;
textmode(3);
end.