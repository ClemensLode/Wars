unit eat2;
interface
uses units3,wars2;
var xx,yy,eatx,eaty:word;
counter2:longint;
procedure verdauen;

implementation

procedure eatit(wer,was:word);
begin
 if pflanzen[was].beeren>10 then begin
  spieler[wer].hunger:=0;
  dec(pflanzen[was].beeren,10);
  spieler[wer].goeat:=false;
 end;
end;


procedure verdauen;
var ziel:word;
hoch:byte;
begin
inc(counter2);
if counter2 mod 10=0 then for i:=0 to 100 do if pflanzen[i].beeren<255 then inc(pflanzen[i].beeren);
for i:=0 to anzmann do begin
 if counter2 mod 8=0 then inc(spieler[i].hunger);
 if counter2 mod 4=0 then inc(spieler[i].durst);
 if counter2 mod 16=0 then inc(spieler[i].muede);
 suche(i);
end;
end;

begin
for i:=0 to 100 do begin
pflanzen[i].beeren:=1;
pflanzen[i].x:=random(kartex-6)+3;
pflanzen[i].y:=random(kartey-6)+3;
end;
end.