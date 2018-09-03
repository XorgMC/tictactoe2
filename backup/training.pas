unit training;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Math;

Type
   TMyThread = class(TThread)
   private
     fStatusText : string;
     procedure ShowStatus;
   protected
     procedure Execute; override;
   public
     Constructor Create(CreateSuspended : boolean);
   end;
 implementation
        uses Unit1;
 constructor TMyThread.Create(CreateSuspended : boolean);
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
Var randomI:Integer;
  prozent:double;
begin
  randomI:=random(9)+1;
  //ShowMessage(randomI.ToString());
  if spielFertig then
  begin
       Form1.resetGame();
       spielFertig:=false;
  end
  else
  begin
  case randomI of
  1:begin
        if Form1.Button1.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button1);
        end;
  end;
  2:begin
        if Form1.Button2.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button2);
        end;
  end;
  3:begin
        if Form1.Button3.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button3);
        end;
  end;
  4:begin
        if Form1.Button4.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button4);
        end;
  end;
  5:begin
        if Form1.Button5.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button5);
        end;
  end;
  6:begin
        if Form1.Button6.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button6);
        end;
  end;
  7:begin
        if Form1.Button7.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button7);
        end;
  end;
  8:begin
        if Form1.Button8.Caption <> '' then
        begin
             training;
        end
        else
        begin
          Form1.Button1Click(Form1.Button8);
        end;
  end;
  9:begin
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
  if ((Form1.Wins+Form1.Loses+Form1.Equal) <= 10000) then
  begin
       Form1.Wins:=0;
       Form1.Equal:=0;
       Form1.Loses:=0;
  end;
   if (Form1.Wins+Form1.Loses+Form1.Equal)=0 then prozent:=0
   else
   begin
  prozent:= ((Form1.Loses+Form1.Equal) / (Form1.Wins+Form1.Loses+Form1.Equal))* 100;

   end;
  Form1.Label4.Caption:=RoundTo(prozent,-2).toString + '%';
  end;
 end;
 procedure TMyThread.Execute;
 var
   newStatus : string;
 begin
   fStatusText := 'TMyThread Starting...';
   Synchronize(@Showstatus);
   fStatusText := 'TMyThread Running...';
   while (not Terminated) and (Form1.ToggleBox1.Checked) do
     begin
        training;
       if NewStatus <> fStatusText then
         begin
           fStatusText := newStatus;
           Synchronize(@Showstatus);
         end;
     end;
 end;

end.

