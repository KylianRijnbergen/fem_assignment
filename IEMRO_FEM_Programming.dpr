program IEMRO_FEM_Programming;

uses
  Vcl.Forms,
  Main in 'Main.pas' {MainView},
  Assignment in 'Assignment.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainView, MainView);
  Application.Run;
end.
