uses vesa10,modexlib,gif;
var s1,s2,s3,s4:spritetyp;
i:word;
begin
init_mode13;
loadgif('ocean6');
getsprite5(0,32,16,s1);
getsprite5(16*320,32,16,s2);
getsprite5(32*320,32,16,s3);
getsprite5(48*320,32,16,s4);
initvesa($105);
loadgif('ocean6');
{for i:=1 to 100 do }
rp(0,0,s1);
rp(0,0,s2);
rp(0,0,s3);
rp(0,0,s4);
readln;
end.