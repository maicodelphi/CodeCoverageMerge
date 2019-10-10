program spMesclarCC;

uses
  Forms,
  sysutils,
  classes,
  uFMesclarCC in 'uFMesclarCC.pas' {FMesclarCC};
//  uTeste in '..\GerarListaTests\uTeste.pas';

{$R *.RES}

var
 i: integer;
 sl: TStringList;
begin

  if ParamCount = 0 then
  begin
    Application.Initialize;
    Application.CreateForm(TFMesclarCC, FMesclarCC);
    Application.Run;
  end
  else
  begin
    sl := TStringList.Create;
    for i := 2 to ParamCount do
      sl.Add(ParamStr(i));
    TGerenciadorLinhasCodigo.MesclarCC(sl, ParamStr(1));
    FreeAndNil(sl);

  end;
end.

