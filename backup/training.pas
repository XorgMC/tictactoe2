unit training;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math;

type
  TMyThread = class(TThread)
  private
    fStatusText: string;
    procedure ShowStatus;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: boolean);

  end;

implementation

uses Unit1;

constructor TMyThread.Create(CreateSuspended: boolean);
begin
  randomize();
  FreeOnTerminate := True;
  inherited Create(CreateSuspended);

end;

procedure TMyThread.ShowStatus;
// Diese Methode wird vom MainThread ausgeführt und kann deshalb auf alle GUI-Elemente zugreifen
begin
  Form1.Caption := fStatusText;
end;

procedure training;
var
  randomI: integer;
  SomeStr: string;
  prozent: double;

begin

  if spielFertig then
  begin
    Form1.resetGame();
    Inc(Form1.spiele);
    spielFertig := False;
  end
  else
  begin
    randomI :=Form1.GetQmove(Form1.Edit2.Text,false);//Form1.GetRandomMove();      //
    //Form1.DebugMsg(randomI.ToString);
    case randomI of
      0:
      begin
        if Form1.Button1.Caption <> '' then
        begin
          training;
        end
        else
        begin
          //Form1.DebugMsg(randomI.toString);
          Form1.Button1Click(Form1.Button1);
        end;
      end;
      1:
      begin
        if Form1.Button2.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button2);
        end;
      end;
      2:
      begin
        if Form1.Button3.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button3);
        end;
      end;
      3:
      begin
        if Form1.Button4.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button4);
        end;
      end;
      4:
      begin
        if Form1.Button5.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button5);
        end;
      end;
      5:
      begin
        if Form1.Button6.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button6);
        end;
      end;
      6:
      begin
        if Form1.Button7.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button7);
        end;
      end;
      7:
      begin
        if Form1.Button8.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button8);
        end;
      end;
      8:
      begin
        if Form1.Button9.Caption <> '' then
        begin
          training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button9);
        end;
      end;

    end;


    // ShowMessage((w+l+e).toString);
    if ((Form1.Wins + Form1.Loses + Form1.Equal) >= 10000) then

    begin
      if Form1.CheckBox1.Checked then
      begin

        SetLength(SomeStr, Length(Form1.Label4.Caption));
        SomeStr := Form1.Label4.Caption;
        SetLength(SomeStr, Length(SomeStr) - 1);
        Form1.Edit1.Text :=
          (RoundTo(100 - RoundTo(SomeStr.ToDouble(), -2), -2)).toString;
        //Epsilon:= RoundTo(100-RoundTo(prozent,-2),-2).toString;
      end;

      Form1.ListBox1.items.add(Form1.Label4.Caption + ' - Trainer: ' +
        Form1.Wins.toString + ' - Unentschieden: ' + Form1.Equal.toString +
        ' - KI: ' + Form1.Loses.toString);
      Form1.Wins := 0;
      Form1.Equal := 0;
      Form1.Loses := 0;
    end;
    if (Form1.Wins + Form1.Loses + Form1.Equal) = 0 then
      prozent := 0
    else
    begin
      prozent := ((Form1.Loses + Form1.Equal) / (Form1.Wins + Form1.Loses + Form1.Equal)) * 100;

    end;
    Form1.Label4.Caption := RoundTo(prozent, -2).toString + '%';
    Form1.Label5.Caption := Form1.spiele.ToString + ' Simulierte Spiele';
  end;
end;

procedure TMyThread.Execute;
var
  newStatus: string;
begin
  fStatusText := 'TMyThread Starting...';
  Synchronize(@Showstatus);
  fStatusText := 'TMyThread Running...';
  while (not Terminated) and (Form1.ToggleBox1.Checked) do
  begin
    training;
    //sleep(1000);

    if NewStatus <> fStatusText then
    begin
      fStatusText := newStatus;
      Synchronize(@Showstatus);
    end;
  end;
end;

end.
