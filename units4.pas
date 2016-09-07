
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
  Begin
    fill_besetzt;
    size:=(kartex+1)*(kartey+1);
    error (0);
    GetMem (tempkart, Size shl 1);
    GetMem (behind, Size);
    spieler [num2].go := False;
    FillChar (tempkart^, Size shl 1, 0);
    FillChar (behind^, Size, 0);
    move(besetzt,behind^,size); {= 1 besetzt, 0 unbesetzt}

     Begin
       for long:=0 to 5 do begin
        actions[long].dauer:=0;
        FillChar (actions[long].weg, 200, 0);
       end;

        items[spieler[num2].ax+spieler[num2].weg[spieler[num2].wegp-1].kx,spieler[num2].ayweg[spieler[num2].wegp-1].ky]:=255; {Start}

        For long := 0 To 99 Do Begin
          {#1}
          For X := 0 To kartex Do
            For Y := 0 To kartey Do
              If items[x,y] = 254 Then itmes[x,y] := 255;

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
                    1..250:if actions[inhalt].dauer=0 then begin {Erste "Quelle" gefunden!}
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
                       {Alle Entfernungen und Wege gefunden... jetzt müssen die Prioritäten ausgerechnet werden...}
                       {Erstmal die Dauer der Aktion berechnen}
                 prio[1]:=actions[1].dauer*actions[1].dauer+8+spieler[num2].durst*spieler[num2].durst;{Wasser}
                 prio[2]:=actions[2].dauer*actions[2].dauer+32+spieler[num2].durst*spieler[num2].hunger;     {Nahrung}
                 prio[3]:=actions[3].dauer*actions[3].dauer+512+spieler[num2].durst*spieler[num2].muede;    {Haus}
                 prio[0]:=10000; {Nix tun!}
                 for long:=0 to 5 do if prio[long]>maxz then begin maxz:=prio[long];maxn:=long;end;
                 t3:=actions[maxn].cx;t4:=actions[maxn].cy;
                 if (spieler[num2].cx=t3) and (spieler[num2].cy=t4) then exit;
                 spieler[num2].cx:=t3;
                 spieler[num2].cy:=t4;
                 For tx := actions[maxn].dauer Downto 0 Do Begin
                   spieler [num2].weg [tx].kx := tempkart^ [t3, t4].kx;
                   spieler [num2].weg [tx].ky := tempkart^ [t3, t4].ky;
                   Dec (t3, spieler [num2].weg [tx].kx);
                   Dec (t4, spieler [num2].weg [tx].ky);
                 End;
                 spieler [num2].weglong := actions[maxn].dauer;
                 FreeMem (tempkart, Size shl 1);
                 FreeMem (behind, Size);
                 spieler [num2].go := True;
                 Exit;
                 {@5}
         {@2}
end;








for long:=0 to 99 do begin













for x:=0 to 99 do for y:=0 to 99 do begin
