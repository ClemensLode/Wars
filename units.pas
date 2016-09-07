Unit units;
Interface
Uses crt, wars, vesa103, newfrontier;

Const anzmann = 10;
  
Type
  eig = Record
          weglong,                      {Laenge des aktuellen Weges in Feldern}
          phase,                        {Phase fuer Bewegung der Sprites}
          richtung,                     {Richtung fuer Sprites}
          wegp,                         {Fortschritt auf dem berechneten Weg (<weglong)}
          wait          : Byte;          {Restliche Wartezeit in Bewegungszyklen}
          px, py         : ShortInt;      {Feine Positionseinstellung zwischen den Feldern}
          sx, sy,                        {Startfeld des aktuellen Wegs}
          AX, ay,                        {Aktuelle Feldposition (Start)}
          CX, cy         : Integer;       {Aktuelles Ziel}
          blocker,go: Boolean;
          weg           : Array [0..99] Of Record
                                             kx, ky: ShortInt;  {Aenderung der Richtung in der jeweiligen Phase}
                                           End;
          material: Array [0..100] Of Byte;               {Art und Menge des gerade transportierten Stoffes}

        End;

Var spieler: Array [0..anzmann] Of eig;
  i: Word;
  errornum: String;

Procedure stop (num1: LongInt); {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
 Function kompass (gox, goy: Integer): Byte;
 Procedure gotoxye (gox, goy, num7: LongInt);
Procedure weiter_schritt;

Implementation

 Procedure stop (num1: LongInt); {sofortiger Stop;Kann nur nach px>=33 gestartet werden}
 Begin
   spieler [num1].go := False;
   spieler [num1].CX := spieler [num1].AX; spieler [num1].cy := spieler [num1].ay;
   spieler [num1].sx := spieler [num1].AX; spieler [num1].sy := spieler [num1].ay;
   spieler [num1].px := 0; spieler [num1].py := 0;
   FillChar (spieler [num1].weg, SizeOf (spieler [num1].weg), 0);
   spieler [num1].weglong := 0;
   spieler [num1].wegp := 0;
   spieler [num1].phase := 0;
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
   Case num Of
     0: errornum := 'Alles OK!';
     1: errornum := 'Weg nicht gefunden';
     2: errornum := 'Zielfeld blockiert';
     3: errornum := '';
     4: errornum := 'Ziel bereits gesetzt';
   End;
 End;
 Function findway (gox, goy, num2: LongInt): Integer;
 {Moegliche Optimierung: Annaehrung von Start und Ziel}
  Type
    tempkarttyp = Array [0..99, 0..99] Of Record
                                            kx, ky: ShortInt; ti: Byte;
                                          End;
  Var
    num7, yyy, kkk, mx, my, long, tx, ty, X, Y, X1, Y1, t3, t4: Integer;
    erfolg: Boolean;
    tempkart:^tempkarttyp;
  Begin
    error (0);
    GetMem (tempkart, SizeOf (tempkarttyp) );
    spieler [num2].go := False;
    FillChar (tempkart^, SizeOf (tempkarttyp), 0);
    {  for kkk:=1 to anz-1 do tempkart^[spieler[kkk].ax,spieler[kkk].ay].ti:=2; {Feld von Spieler besetzt}

    For yyy := 0 To 99 Do
      For kkk := 0 To 99 Do Begin
        num7 := readmem32b (Ptr48 (karte, kkk + screeny100 [yyy] ) );
        If (num7 < 4) Or (num7 > 7) Or (readmem32b (Ptr48 (gebirge, kkk + screeny100 [yyy] ) ) > 0) Then
          tempkart^ [kkk, yyy].ti := 1;
      End;

    {  for yyy:=1 to hanz do begin
    tempkart^[haus[yyy].x,haus[yyy].y].ti:=yyy+20;
    tempkart^[haus[yyy].x+1,haus[yyy].y].ti:=yyy+20;
    end;}
    If ( (gox = spieler [num2].CX) And (goy = spieler [num2].cy) ) Then error (4)
    Else
      If (tempkart^ [gox, goy].ti > 0) And (tempkart^ [gox, goy].ti < 3) Then error (2)
      Else
      Begin
        spieler [num2].CX := gox;
        spieler [num2].cy := goy;
        spieler [num2].wegp := 0;
        FillChar (spieler [num2].weg, SizeOf (spieler [num2].weg), 0);
        If (Abs (spieler [num2].CX - spieler [num2].AX) <= 1) And (Abs (spieler [num2].cy - spieler [num2].ay) <= 1) Then
        Begin {Ziel nur 1 Feld entfernt...}
          spieler [num2].weglong := 0;
          spieler [num2].go := True;
          spieler [num2].weg [0].kx := spieler [num2].CX - spieler [num2].AX;
          spieler [num2].weg [0].ky := spieler [num2].cy - spieler [num2].ay;
          FreeMem (tempkart, SizeOf (tempkarttyp) );
          Exit;
        End;
        {  for x:=0 to maxx do
        for y:=0 to maxy do
        if (tempkart^[x,y].ti<3) and (tempkart^[x,y].ti>0) then tempkart^[x,y].ti:=1;}

        tempkart^ [spieler [num2].CX, spieler [num2].cy].ti := 4; {Ziel}
        tempkart^ [spieler [num2].AX, spieler [num2].ay].ti := 3; {Start}

        For long := 0 To 99 Do Begin
          {#1}
          erfolg := False;
          For X := 0 To 99 Do
            For Y := 0 To 99 Do
              If tempkart^ [X, Y].ti = 10 Then Begin
              erfolg := True;
              tempkart^ [X, Y].ti := 3;
              End;

          For X := 0 To 99 Do
            {#2} For Y := 0 To 99 Do Begin
              {#3} If tempkart^ [X, Y].ti = 3 Then Begin
                For mx := - 1 To 1 Do
                  For my := - 1 To 1 Do
                    {#4}    If (X + mx >= 0) And (Y + my >= 0) And (X + mx <= 99) And (Y + my <= 99) Then Begin

                      If (tempkart^ [X + mx, Y + my].ti = 0) Then Begin
                        tempkart^ [X + mx, Y + my].ti := 10;
                        tempkart^ [X + mx, Y + my].kx := mx;
                        tempkart^ [X + mx, Y + my].ky := my;
                      End;

                      {#5}  If (tempkart^ [X + mx, Y + my].ti = 4) Then Begin {Da!}
                        tempkart^ [X + mx, Y + my].kx := mx;
                        tempkart^ [X + mx, Y + my].ky := my;
                        t3 := spieler [num2].CX;
                        t4 := spieler [num2].cy;

                        For tx := long Downto 0 Do Begin
                          spieler [num2].weg [tx].kx := tempkart^ [t3, t4].kx;
                          spieler [num2].weg [tx].ky := tempkart^ [t3, t4].ky;
                          Dec (t3, spieler [num2].weg [tx].kx);
                          Dec (t4, spieler [num2].weg [tx].ky);
                        End;
                        spieler [num2].weglong := long;
                        FreeMem (tempkart, SizeOf (tempkarttyp) );
                        spieler [num2].go := True;
                        Exit;
                        {@5}  
                      End;
                      
                      {@4} 
                    End;
                tempkart^ [X, Y].ti := 1;
                
                {@3} 
              End;
              
            End;
          {@2}
          If (erfolg = False) And (long > 98) Then Begin
            error (1);
            stop (num2);
            FreeMem (tempkart, SizeOf (tempkarttyp) );
            Exit;
          End;
        End;
        {@1}
        error (1); stop (num2);
      End;
  End;

 Procedure gotoxye (gox, goy, num7: LongInt);
  Var r, rx, ry, rx1, ry1: LongInt;
  Begin
    stop (num7);
    If (gox <= 0) Or (gox >= 99) Or (goy <= 0) Or (goy >= 99) Or (num7 < 0) Or (num7 > anzmann) Then Exit;
    findway (gox, goy, num7);
    With spieler [num7] Do Begin
      px := 0;
      py := 0;
      richtung := kompass (weg [wegp].kx, weg [wegp].ky);
      rx := AX; ry := ay;
    End;
  End;
Procedure weiter_feld (num1: LongInt);
Begin
  With spieler [num1] Do Begin
    px := weg [wegp + 1].kx;
    py := weg [wegp + 1].ky;
    Inc (AX, weg [wegp].kx);
    Inc (ay, weg [wegp].ky);
    Inc (wegp);
    If wegp > weglong Then Begin stop (num1); Exit; End;
    richtung := kompass (weg [wegp].kx, weg [wegp].ky);
  End;
End;

Procedure weiter_schritt;
var xx,yy:word;
Begin
  For xx := 0 To anzmann Do If spieler [xx].go Then With spieler [xx] Do
    If (Abs (px) < 16) And (Abs (py) < 16) Then Begin
      if readmem32b(ptr48(hoehe,ax+screeny100[ay]))<>8 then begin
       if blocker then blocker:=false else blocker:=true;
      end else blocker:=false;
      if blocker=false then begin
      Inc (phase); If phase > 7 Then phase := 0;
      Inc (px, weg [wegp].kx); Inc (py, weg [wegp].ky);
      end;
    End
  Else weiter_feld (xx);
End;

Begin
  error (0);
End.