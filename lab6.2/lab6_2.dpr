program lab6_2;

uses
  Vcl.Forms,
  main in 'main.pas' {FMain},
  DGLUT in 'DGLUT.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.Run;
end.
