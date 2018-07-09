unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, StrUtils, RegExpr, fpjson, jsonparser, Math;

type

  { TForm1 }

  TArrayBehindert = array of integer;

  TForm1 = class(TForm)
    Button10: TButton;
    grdB: TLabel;
    grdC: TLabel;
    Button1: TButton;
    cmdReset: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    GroupBox1: TGroupBox;
    grdA: TLabel;
    grd1: TLabel;
    grd2: TLabel;
    grd3: TLabel;
    GroupBox2: TGroupBox;
    logBox: TListBox;
    ToggleBox1: TToggleBox;
    procedure Button10Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cmdResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ToggleBox1Change(Sender: TObject);
  private
    function BoardToString(): string;
    function GetPossibleMoves(curState: string): TArrayBehindert;
    function ConsiderStateKey(state: string; pMark: String): TJSONObject;
    procedure LerneQ(pPos: integer; pMark: string);
    function BoardReward(state: string): Float;
    function IsBoardOver(state: string): boolean;
    function KeyMin(sKey: TJSONObject): Float;
    function KeyMax(sKey: TJSONObject): Float;
    function KeyMins(sKey: TJSONObject): integer;
    function KeyMaxs(sKey: TJSONObject): integer;
    procedure QMove(pMark: string);
    function OtherPlayer(pMark: String): String;
    procedure RandomMove();
    procedure InitQ();
    function GameStatus(): integer;
    function GetQMove(pMark: String): Integer;
    function GetRandomMove(): Integer;
    procedure HandleMov( cBtn: TButton; pMark: String );
  public

  end;

var
  Form1: TForm1;
  Q: TJSONObject;
  ALPHA: double;
  GAMMA: double;
  EPSILON: double;
  GRUN: boolean;
  rx, ro: TRegExpr;
  wx, wo, wn: integer;
  pH, pC: String;



implementation

{$R *.lfm}

{ TForm1 }

{
  Gibt den Spielfeldknopf nach Nummer zurück (0=oben links, 1=oben mitte)
}
function IntButton(i: integer): TButton;
begin
  with Form1 do
  begin
    case i of
      0:
        Result := Button1;
      1:
        Result := Button2;
      2:
        Result := Button3;
      3:
        Result := Button4;
      4:
        Result := Button5;
      5:
        Result := Button6;
      6:
        Result := Button7;
      7:
        Result := Button8;
      8:
        Result := Button9;
      else
        Result := nil;
    end;
  end;
end;

{
 Gibt das aktuelle Spielfeld als String zurück (X=X;O=O;[leer]=_)
}
function TForm1.BoardToString(): string;
var
  i: integer;
  s: string;
  l: string;
begin
  s := '';
  for i := 1 to 9 do
  begin
    l := TButton(Form1.FindComponent('Button' + i.ToString)).Caption;
    if Length(l) = 0 then
      s := s + '_'
    else
      s := s + l;
  end;
  Result := s;
end;

{
 Wandelt eine Spielfeldnummer in Koordinaten um
}
function NumToCoord(i: integer): string;
begin
  case i of
    0:
      Result := 'A1';
    1:
      Result := 'B1';
    2:
      Result := 'C1';
    3:
      Result := 'A2';
    4:
      Result := 'B2';
    5:
      Result := 'C2';
    6:
      Result := 'A3';
    7:
      Result := 'B3';
    8:
      Result := 'C3';
    else
      Result := 'Unknown';
  end;
end;

{
 (Veraltet) Führt einen Zug nach Q-Lernen aus
}
procedure TForm1.QMove(pMark: string);
var
  rv: Float;
  curState: string;
  curStateKey: TJSONObject;
  chMov,i: integer;
  chBtn: TButton;
begin
  rv := random(101) / 100;
  if rv < EPSILON then
  begin
    RandomMove();
  end
  else
  begin
    curState := BoardToString();
    curStateKey := ConsiderStateKey(curState, pMark);

    for i := 0 to curStateKey.Count - 1 do
    begin
      Writeln('Pos #', i, ' => ', FloatToStr(curStateKey.Items[i].AsFloat ));
    end;

    if pMark = 'X' then
      chMov := KeyMaxs(curStateKey)
    else
      chMov := KeyMins(curStateKey);

    LerneQ(chMov, 'O');

    chBtn := IntButton(chMov);

    if chBtn.Caption <> '' then
    begin
      ShowMessage('Irgendwie ist der Platz belegt');
    end
    else
    begin
      chBtn.Caption := pMark;
    end;


  end;

end;

{
 Gibt einen Zug (Feld) nach Q-Lernen zurück
}
function TForm1.GetQMove(pMark: string): integer;
var
  rv: Float;
  curState: string;
  curStateKey: TJSONObject;
  chMov,i: integer;
  chBtn: TButton;
begin
  rv := random(101) / 100;
  if rv < EPSILON then
  begin
    Result := GetRandomMove();
  end
  else
  begin
    curState := BoardToString();
    curStateKey := ConsiderStateKey(curState, pMark);

    for i := 0 to curStateKey.Count - 1 do
    begin
      Writeln('Pos #', i, ' => ', FloatToStr(curStateKey.Items[i].AsFloat ));
    end;

    if pMark = 'X' then
      chMov := KeyMaxs(curStateKey)
    else
      chMov := KeyMins(curStateKey);

    Result := chMov;
  end;

end;

{
 Gibt einen zufälligen Zug (Feld) zurück
}
function TForm1.GetRandomMove(): integer;
var
  f: integer;
  b: TButton;
  m: array of integer;
  i: integer;
begin
  f := Random(9);
  b := IntButton(f);
  if b.Caption <> '' then
  begin
    Form1.logBox.Items.Add('Gewähltes Feld ' + NumToCoord(f) +
      ' ist belegt, suche anderes');
    Result := GetRandomMove();
  end
  else
  begin
    Form1.logBox.Items.Add('Wähle Feld ' + NumToCoord(f));
    Result := f;
  end;
end;

{
 (Veraltet) Führt einen zufälligen Zug aus
}
procedure TForm1.RandomMove();
var
  f: integer;
  b: TButton;
  m: array of integer;
  i: integer;
begin
  m := Form1.GetPossibleMoves(Form1.BoardToString());
  for i := 0 to Length(m) - 1 do
  begin
    Form1.logBox.Items.Add('Ist frei: ' + IntToStr(m[i]));
  end;
  f := Random(9);
  b := IntButton(f);
  if b.Caption <> '' then
  begin
    Form1.logBox.Items.Add('Gewähltes Feld ' + NumToCoord(f) +
      ' ist belegt, suche anderes');
    RandomMove();
  end
  else
  begin
    Form1.logBox.Items.Add('Wähle Feld ' + NumToCoord(f));
    b.Caption := 'O';
  end;
end;

{
 (Veraltet)
}
procedure DoPcMove();
begin
  //RandomMove();
  ShowMessage('Dis works');
  Form1.QMove('O');
end;

{
 Gibt den Spielstatus zurück
 1 = X gewonnen
 2 = O gewonnen
 3 = Unentschieden
 0 = Spiel läuft
}
function TForm1.GameStatus(): Integer;
var BS: String;
  GS: Integer;
begin
  BS := Form1.BoardToString();
  GS := 0;
  if rx.Exec(BS) then
    begin
      GRUN := False;
      Inc(wx);
      GS := 1;
    end
    else if ro.Exec(BS) then
    begin
      GRUN := False;
      Inc(wo);
      GS := 2;
    end
    else
    begin
      if not AnsiContainsStr(BS, '_') then
      begin
        GRUN := False;
        Inc(wn);
        GS := 3;
      end;
    end;
    Result := GS;
end;

{
 Gibt die Nummer eines Feldes nach TButton zurück
}
function FindButton(O: TObject): integer;
begin
  with Form1 do
  begin
    if O.Equals(Button1) then
      Result := 0
    else if O.Equals(Button2) then
      Result := 1
    else if O.Equals(Button3) then
      Result := 2
    else if O.Equals(Button4) then
      Result := 3
    else if O.Equals(Button5) then
      Result := 4
    else if O.Equals(Button6) then
      Result := 5
    else if O.Equals(Button7) then
      Result := 6
    else if O.Equals(Button8) then
      Result := 7
    else if O.Equals(Button9) then
      Result := 8
    else
      Result := 0;
  end;
end;

procedure TForm1.Button10Click(Sender: TObject);
var
  i, j, PM: Integer;
  c: TJSONObject;

begin
  pC := 'X';
  pH := 'O';
  PM := GetQMove(pC);
       Writeln(PM);
       HandleMov( IntButton(PM), pC);
  //ConsiderStateKey('_________');
  //x := 'X';
  //a := '__O__O__O';
  //b := a;
  //b[2] := x.Chars[0];
  //ShowMessage(Q.FormatJSON());
end;

{
 Event-Handler für "Zug fertig"
 -> Trainiert nach Q-Lernen
 -> Setzt Marke
 -> Zeigt Spielende an
}
procedure TForm1.HandleMov(cBtn: TButton; pMark: String);
var GS: integer;
begin
  LerneQ(FindButton(cBtn), pMark);
  cBtn.Caption := pMark;
  GS := GameStatus();
  if GS <> 0 then
     ShowMessage('Spielende');
end;

{
 Event-Handler "Feld angeklickt"
}
procedure TForm1.Button1Click(Sender: TObject);
var
  BS: string;
  PM: Integer;
begin
  if GRUN then //Wenn Spiel noch läuft (TODO: durch GS ersetzen)
  begin
    HandleMov(TButton(Sender), pH);
    if GameStatus() = 0 then
    begin
       PM := GetQMove(pC);
       Writeln('K', PM);
       HandleMov( IntButton(PM), pC);
    end;
  end;
  //BS:=BoardToString();
  //ShowMessage(CheckResult(BS));
  //if NOT hasGameEnded(BS) then RandomMove();
  //ShowMessage(IntToStr(FindButton(Sender)));
end;

procedure TForm1.cmdResetClick(Sender: TObject);
var
  i: integer;
begin
  for i := 1 to 9 do
  begin
    TButton(Form1.FindComponent('Button' + i.ToString)).Caption := '';
  end;
  GRUN := True;
  logBox.Items.Add('---------------------');
  logBox.Items.Add('Neues Spiel gestartet');
end;

procedure TForm1.InitQ();
var jf: TextFile;
  js,t: String;
begin
  AssignFile(jf, 'game.json');

  try
    Reset(jf);
    while not EOF(jf) do
    begin
      readln(jf,t);
      js := js + t;
    end;

    CloseFile(jf);

    Q := TJSONObject(GetJSON(js));
  except
    on E: EInOutError do
       ShowMessage('I/O Fehler!');
  end;

end;

procedure InitGame();
begin
  ALPHA := 0.3;
  GAMMA := 0.9;
  pH := 'X';
  pC := 'O';
  //Q := TJSONObject.Create;
  Form1.InitQ();
  randomize();
  ro := TRegExpr.Create;
  rx := TRegExpr.Create;
  rx.Expression :=
    '(XXX......)|(...XXX...)|(......XXX)|(X..X..X..)|(.X..X..X.)|(..X..X..X)|(X...X...X)|(..X.X.X..)';
  ro.Expression :=
    '(OOO......)|(...OOO...)|(......OOO)|(O..O..O..)|(.O..O..O.)|(..O..O..O)|(O...O...O)|(..O.O.O..)';
  GRUN := True;
  wx := 0;
  wo := 0;
end;

function TForm1.ConsiderStateKey(state: string; pMark: String): TJSONObject;
var
  dVals,e: TJSONObject;
  i: integer;
  s: String;
begin
  e := TJSONObject.Create;
  s := state + pMark;
  Writeln('S: ', state, pMark);
  if Q.Find(s) = nil then
  begin
    Writeln('Statekey ', state, pMark, ' existiert nicht');
    dVals := TJSONObject.Create;
    for i := 0 to 8 do
    begin
      if state[i + 1] = '_' then
      begin
        dVals.Add(i.ToString, 1.0);
      end;
    end;
    Q.Add(s, dVals);
    Result := dVals;
  end
  else
  begin
    Result := Q.Get(s, e);
  end;
end;

function TForm1.BoardReward(state: string): Float;
begin
  if not AnsiContainsStr(state, '_') then
  begin
    if rx.Exec(state) then
      Result := 1.0
    else
    begin
      if ro.Exec(state) then
        Result := -1.0
      else
        Result := 0.5;
    end;
  end
  else
    Result := 0.0;
end;

function TForm1.IsBoardOver(state: string): boolean;
begin
  Result := not AnsiContainsStr(state, '_');
end;

function TForm1.KeyMin(sKey: TJSONObject): Float;
var
  i: integer;
  v: Float;
begin
  v := sKey.Items[0].AsFloat;
  for i := 1 to sKey.Count - 1 do
  begin
    if sKey.Items[i].AsFloat < v then
      v := sKey.Items[i].AsFloat;
  end;
  Result := v;
end;

function TForm1.KeyMins(sKey: TJSONObject): integer;
var
  i, rv: integer;
  v: Float;
  p: TJSONArray;
begin
  p := TJSONArray.Create;
  v := sKey.Items[0].AsFloat;
  for i := 1 to sKey.Count - 1 do
  begin
    Writeln(FloatToStr(sKey.Items[i].AsFloat), ' vs ', FloatToStr(v));
    if sKey.Items[i].AsFloat < v then
    begin
      Writeln('Smaller');
      v := sKey.Items[i].AsFloat;
      p.Clear;
      p.Add(i);
    end
    else if sKey.Items[i].AsFloat = v then
    begin
        Writeln('Same');
      p.Add(i);
    end;
  end;

  if p.Count = 0 then
     p.Add(0);

  Writeln('KMins :: pCount=', p.Count);

  rv := Random(p.Count); //Funzt das?

  Writeln('KMins :: rv=', rv);

  Result := StrToInt(sKey.Names[p.Integers[rv]]);
end;

function TForm1.KeyMax(sKey: TJSONObject): Float;
var
  i: integer;
  v: Float;
begin
  v := sKey.Items[0].AsFloat;
  for i := 1 to sKey.Count - 1 do
  begin
    if sKey.Items[i].AsFloat > v then
      v := sKey.Items[i].AsFloat;
  end;
  Result := v;
end;

function TForm1.KeyMaxs(sKey: TJSONObject): integer;
var
  i, rv: integer;
  v: Float;
  p: TJSONArray;
begin
  Writeln('KeyMaxs!');
  p := TJSONArray.Create;
  v := sKey.Items[0].AsFloat;
  for i := 1 to sKey.Count - 1 do
  begin
    if sKey.Items[i].AsFloat > v then
    begin
      v := sKey.Items[i].AsFloat;
      p.Clear;
      p.Add(i);
    end
    else if sKey.Items[i].AsFloat = v then
    begin
      p.Add(i);
    end;
  end;

  if p.Count = 0 then
    p.Add(0);

  rv := Random(p.Count);
  Result := StrToInt(sKey.Names[p.Integers[rv]]);
end;

function TForm1.OtherPlayer(pMark: String): String;
begin
  if LowerCase(pMark) = 'x' then
     Result := 'O'
  else
      Result := 'X';
end;

procedure TForm1.LerneQ(pPos: integer; pMark: string);
var
  curState, nxtState: string;
  curStateKey, nxtStateKey: TJSONObject;
  reward, expected, change: Float;
  i: Integer;
begin
  curState := BoardToString();
  curStateKey := ConsiderStateKey(curState, pMark);
  nxtState := curState;
  nxtState[pPos + 1] := pMark.Chars[0];
  reward := BoardReward(nxtState);
  nxtStateKey := ConsiderStateKey(nxtState, OtherPlayer(pMark));
  if IsBoardOver(nxtState) then
    expected := reward
  else
  begin
    if pMark = 'X' then
      expected := reward + (GAMMA * KeyMin(nxtStateKey))
    else if pMark = 'O' then
      expected := reward + (GAMMA * KeyMax(nxtStateKey));
  end;
//  ShowMessage(curStateKey.Floats[pPos.ToString].ToString);
  change := ALPHA * (expected - curStateKey.Floats[pPos.ToString]);
  curStateKey.Floats[pPos.ToString] := curStateKey.Floats[pPos.ToString] + change;
//  ShowMessage('Kappa');
end;

function TForm1.GetPossibleMoves(curState: string): TArrayBehindert;
var
  x: array of integer;
  i: integer;
begin
  SetLength(x, 0);
  for i := 1 to Length(curState) do
  begin
    if curState[i] = '_' then
    begin
      SetLength(x, Length(x) + 1);
      x[Length(x) - 1] := i;
      //ShowMessage(IntToStr(i));
    end;
  end;
  Result := x;
end;

procedure UninitGame();
begin
  rx.Free;
  ro.Free;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitGame();
end;

procedure TForm1.ToggleBox1Change(Sender: TObject);
begin
  if ToggleBox1.Checked then
  begin
     ToggleBox1.Color:=clLime;
  end
  else
  begin
    ToggleBox1.Color := clRed;
  end;
end;

end.
