Unit units3;
Interface
Uses crt, wars2, vesa107, newfrontier;

Const anzmann = 3;

Type
  eig = Record
          weglong,                      {Laenge des aktuellen Weges in Feldern}
          phase,                        {Phase fuer Bewegung der Sprites}
          richtung,                     {Richtung fuer Sprites}
          wegp,                         {Fortschritt auf dem berechneten Weg (<weglong)}
          muede,hunger,durst,wait          : Byte;          {Restliche Wartezeit in Bewegungszyklen}
          gx,gy,px, py         : ShortInt;      {temporäre Richtung,Feine Positionseinstellung zwischen den Feldern}
          eatx,eaty,eatziel,sx, sy,                        {Startfeld des aktuellen Wegs}
          gotox,gotoy,                    {Letzter Befehl}
          AX, ay,                        {Aktuelle Feldposition (Start)}
          CX, cy         : Integer;       {Aktuelles Ziel}
          goback,goeat,blocker,go: Boolean;
          weg           : Array [0..99] Of Record
                                             kx, ky: ShortInt;  {Aenderung der Richtung in der jeweiligen Phase}
                                           End;
          material: Array [0..100] Of Byte;               {Art und Menge des gerade transportierten Stoffes}
          prio:array[0..5] of longint;
        End;

Var spieler: Array [0..anzmann] Of eig;
  i: Word;
  errornum: String;
  besetzt:array[0..kartex,0..kartey] of byte;
  items:array[0..kartex,0..kartey] of byte;
  xx,yy:word;
  tinhalt:byte;
Procedure stop (num1: LongInt); {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
Function kompass (gox, goy: Integer): Byte;
Procedure gotoxye (gox, goy, num7: LongInt);
procedure suche(num2:longint);
Procedure weiter_schritt;
procedure fill_besetzt;

Implementation

 Procedure stop (num1: LongInt); {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
 Begin
   spieler [num1].go := False;
   spieler [num1].CX := spieler [num1].AX;
   spieler [num1].cy := spieler [num1].ay;
   spieler [num1].sx := spieler [num1].AX;
   spieler [num1].sy := spieler [num1].ay;
   spieler [num1].px := 0; spieler [num1].py := 0;
   FillChar (spieler [num1].weg, 200, 0);
   spieler [num1].weglong := 0;
   spieler [num1].wegp := 0;
   spieler [num1].phase := 0;
   spieler[num1].goback:=false;
   spieler[num1].goeat:=false;
   spieler[num1].wait:=0;
   spieler[num1].blocker:=false;
   spieler[num1].eatx:=0;
   spieler[num1].eaty:=0;
   spieler[num1].eatziel:=0;
 End;

 Function kompass (gox, goy: Integer): Byte;
 Begin
   Case gox Of
     - 1: Case goy Of
       - 1: kompass := 4;
       0: kompass := 7;
       1: kompass := 6;
     End;

     0: Case goy Of
       - 1: kompass := 3;
       1: kompass := 5;
     End;

     1: Case goy Of
       - 1: kompass := 2;
       0: kompass := 1;
       1: kompass := 0;
     End;
   End;
 End;
 Procedure error (num: Byte);
 Begin
   if num>0 then errornum:='Unbekannter Fehler!';
   Case num Of
     0: errornum := 'Alles OK!';
     1: errornum := 'Weg nicht gefunden';
     2: errornum := 'Zielfeld blockiert';
     3: errornum := '';
     4: errornum := 'Ziel bereits gesetzt';
   End;
 End;




 Procedure suche (num2: LongInt);
 {Moegliche Optimierung: Annaehrung von Start und Ziel}
  Type
    tempkarttyp = Array [0..kartex, 0..kartey] Of Record
                                            kx, ky: ShortInt;
                                          End;
    behinderung = array[0..kartex,0..kartey] of byte;

   Var
   actions:array[0..5] of record
    cx,cy,dauer:word;
    weg           : Array [0..99] Of Record
                          kx, ky: ShortInt;  {Aenderung der Richtung in der jeweiligen Phase}
                    End;
    end;
    inhalt:word;
    maxn,maxz:longint;
    num7, yyy, kkk, mx, my, long, tx, ty, X, Y, X1, Y1, t3, t4: Integer;
    erfolg: Boolean;
    tempkart:^tempkarttyp;
    behind:^behinderung;
    size:longint;
    err:array[0..5] of byte;
  Begin
    fill_besetzt;
    size:=(kartex+1)*(kartey+1);
    GetMem (tempkart, Size shl 1);
    GetMem (behind, Size);
    spieler [num2].go := False;
    FillChar (tempkart^, Size shl 1, 0);
    FillChar (behind^, Size, 0);
    move(besetzt,behind^,size); {= 1 besetzt, 0 unbesetzt}
       for long:=0 to 5 do begin
        err[long]:=0;
        actions[long].dauer:=0;
        FillChar (actions[long].weg, 200, 0);
       end;

        items[spieler[num2].ax+spieler[num2].gx,spieler[num2].ay+spieler[num2].gy]:=255;
        if (spieler[num2].ax<>spieler[num2].gotox) or (spieler[num2].ay<>spieler[num2].gotoy) then
         items[spieler[num2].gotox,spieler[num2].gotoy]:=5;
        {Start}

        For long := 0 To 11 Do Begin            {Bis auf 100 Felder vom Startpunkt testen}
          {#1}
          For X := 0 To kartex Do
            For Y := 0 To kartey Do
              If items[x,y] = 254 Then items[x,y] := 255;

          For X := 1 To kartex-1 Do
            {#2} For Y := 1 To kartey-1 Do Begin

              {#3} If items[x,y] = 255 Then Begin
                For mx := - 1 To 1 Do
                  For my := - 1 To 1 Do begin

                   inhalt:=items[x+mx,y+my];
                   case inhalt of
                    0:begin  {leer}
                        items[X + mx, Y + my] := 254;
                        tempkart^ [X + mx, Y + my].kx := mx;
                        tempkart^ [X + mx, Y + my].ky := my;
                      end;

                    1..50:if actions[inhalt].dauer=0 then begin {Erste "Quelle" gefunden!}
                       err[inhalt]:=1;
                       items[X + mx, Y + my] := 254;
                       actions[inhalt].dauer:=long;
                       actions[inhalt].cx:=x+mx;
                       actions[inhalt].cy:=y+my;
                       tempkart^ [X + mx, Y + my].kx := mx;
                       tempkart^ [X + mx, Y + my].ky := my;
                      end;
                    end;
                   end;
                   items[x,y]:=253;
                  end;
                 end;
                end;

                       {Alle Entfernungen und Wege gefunden... jetzt müssen die Prioritäten ausgerechnet werden...}
                       {Erstmal die Dauer der Aktion berechnen}
                 with spieler[num2] do begin
                 prio[1]:=actions[1].dauer*actions[1].dauer+8+durst*spieler[num2].durst;{Wasser}
                 prio[2]:=actions[2].dauer*actions[2].dauer+32+spieler[num2].durst*spieler[num2].hunger;     {Nahrung}
                 prio[3]:=actions[3].dauer*actions[3].dauer+512+spieler[num2].durst*spieler[num2].muede;    {Haus}
                 prio[4]:=0;
                 if (spieler[num2].ax<>spieler[num2].gotox) or (spieler[num2].ay<>spieler[num2].gotoy)
                  then prio[5]:=actions[5].dauer+11000{+moral} else prio[5]:=0; {Befehl}
                 prio[0]:=10000; {Nix tun!}
                 maxz:=0;
                 maxn:=0;
                 for long:=0 to 5 do if (prio[long]>maxz) and (err[long]=1) then begin maxz:=prio[long];maxn:=long;end;
                 if maxn=0 then begin stop(num2);exit;end;
                 t3:=actions[maxn].cx;
                 t4:=actions[maxn].cy;
                 if ((cx=t3) and (cy=t4)) or ((ax=t3) and (ay=t4)) then exit;
                 cx:=t3;cy:=t4;
                 For tx := actions[maxn].dauer Downto 0 Do Begin
                   weg [tx].kx := tempkart^ [t3, t4].kx;
                   weg [tx].ky := tempkart^ [t3, t4].ky;
                   Dec (t3, weg [tx].kx);
                   Dec (t4, weg [tx].ky);
                 End;
                 weglong := actions[maxn].dauer;
                 gx:=weg[0].kx;
                 gy:=weg[0].ky;
                 FreeMem (tempkart, Size shl 1);
                 FreeMem (behind, Size);
                 spieler [num2].go := True;
                 Exit;
     end;
                 {@5}
         {@2}
end;


Procedure gotoxye (gox, goy, num7: LongInt);
   Var r, rx, ry, rx1, ry1: LongInt;
  Begin
{    stop (num7,false);}
    If (gox <= 0) Or (gox >= kartex) Or (goy <= 0) Or (goy >= kartey) Or (num7 < 0) Or (num7 > anzmann) Then Exit;
    With spieler [num7] Do Begin
      gotox:=gox;
      gotoy:=goy;
{     richtung := kompass (weg [wegp].kx, weg [wegp].ky);
      rx := AX; ry := ay;                                 }
    End;
  End;


procedure fill_besetzt;
var kkk:integer;
begin
fillchar(besetzt,(kartex+1)*(kartey+1),0);
fillchar(items,(kartex+1)*(kartey+1),0);
for kkk:=0 to anzmann do with spieler[kkk] do if (ax>0) and (ay>0) then begin
 besetzt[ax,ay]:=1;
 items[ax,ay]:=2;
 if wait=0 then begin
  items[ax+weg[wegp].kx,ay+weg[wegp].ky]:=2;
  besetzt[ax+weg[wegp].kx,ay+weg[wegp].ky]:=1;
 end;
end;
for kkk:=0 to anzdorf do begin
besetzt[dorfs[kkk].x,dorfs[kkk].y+1]:=1;
besetzt[dorfs[kkk].x+1,dorfs[kkk].y+1]:=1;
besetzt[dorfs[kkk].x+2,dorfs[kkk].y+1]:=1;
besetzt[dorfs[kkk].x,dorfs[kkk].y]:=1;
besetzt[dorfs[kkk].x+1,dorfs[kkk].y]:=1;
items[dorfs[kkk].x+2,dorfs[kkk].y]:=3;
end;
for xx:=0 to kartex do for yy:=0 to kartey do begin
 tinhalt:=readmem32b(ptr48(karte,xx+screeny100[yy]));
 if (tinhalt>=12) and (tinhalt<=15) then begin
  besetzt[xx,yy]:=1; {Wasser}
  items[xx,yy]:=1;
 end;
end;

end;

procedure waitnow(num1:longint);
begin
 spieler[num1].wait:=64;
end;

Procedure weiter_feld (num1: LongInt);
Begin
  With spieler [num1] Do Begin
    px := weg [wegp + 1].kx;
    py := weg [wegp + 1].ky;
    if (gotox=ax) and (gotoy=ay) then begin
     gotox:=gx+ax;
     gotoy:=gy+ay;
    end;
    Inc (AX, gx);
    Inc (ay, gy);
    Inc (wegp);
    gx:=weg[wegp].kx;
    gy:=weg[wegp].ky;
    richtung:=kompass(gx,gy);
    If wegp > weglong Then Begin
     {if goeat then gotoxye(sx,sy,num1) else }stop(num1);
     Exit;
    End;
    richtung := kompass (weg [wegp].kx, weg [wegp].ky);
    if besetzt[ax+px,ay+py]>0 then waitnow(num1);
  End;
End;

Procedure weiter_schritt;
Begin
  For xx := 0 To anzmann Do If spieler [xx].go Then With spieler [xx] Do
    If (Abs (px) < 16) And (Abs (py) < 16) Then Begin
     if wait>0 then begin
      if wait>1 then begin if besetzt[ax+gx,ay+gy]>0 then dec(wait) else wait:=0;end else begin
      wait:=0;
      if besetzt[ax+gx,ay+gy]>0 then gotoxye(cx,cy,xx);
      end;
      end else begin
      {      if (readmem32b(ptr48(hoehe,ax+screeny100[ay]))=18) or (readmem32b(ptr48(hoehe,ax+screeny100[ay]))=38) then begin
      if blocker then blocker:=false else blocker:=true;
      end else blocker:=false;
      if blocker=false then begin}
      Inc (phase); If phase > 7 Then phase := 0;
      Inc (px, gx); Inc (py, gy);
      end;
    End
  Else weiter_feld (xx);
End;

Begin
  error (0);
End.