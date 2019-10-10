unit uFMesclarCC;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

type

  TspResumoClasse = class
  private
    procedure GerarResumoClasse;
  public
    sXML: string;
    sClasse: string;
    sArquivo: string;
    slLinhasCodigos: TStringList;
    nQtdeMetodosCobertosCLASSE: integer;
    nQtdeMetodosTotalCLASSE: integer;
    nQtdeLinhasCobertasCLASSE: integer;
    nQtdeLinhasNaoCobertasCLASSE: integer;
    nQtdeLinhasTotalCLASSE: integer;
    constructor Create;
    function toString: string;
    destructor Destroy; override;
    function Clonar: TspResumoClasse;
  end;

  TspResumoProjeto = class

  public
    sXML: string;
    slListaResumoClasse: TStringList;
    nQtdeClassesCobertosPROJETO: integer;
    nQtdeClassesTotalPROJETO: integer;
    nQtdeMetodosCobertosPROJETO: integer;
    nQtdeMetodosTotalPROJETO: integer;
    nQtdeLinhasCobertasPROJETO: integer;
    nQtdeLinhasNaoCobertasPROJETO: integer;
    nQtdeLinhasTotalPROJETO: integer;
    constructor Create;
    procedure GerarResumoProjeto;
    procedure SalvarXML(psArquivo: string);
    destructor Destroy; override;
  end;

  TGerenciadorLinhasCodigo = class
  private
    class function MesclarLinhas(poLinhasOrigem, poLinhasMescladas: TStringList): integer;
  public
    class procedure MesclarCC(poslCaminhoHTML: TStringList; psArquvioXMLDestino: string);
    class procedure ParserLinhas(psArquivo: string; poListaLinhas: TStringList);
    class function GerarMetodos(poListaLinhas: TStringList): TStringList;
    class function CalcularQtdeLinhasComCodigoGerado(poListaLinhas: TStringList): integer;
    class function CalcularQtdeLinhasCobertas(poListaLinhas: TStringList): integer;
    class function CalcularIntersecaoLinhasCobertas(poListaLinhasA,
      poListaLinhasB: TStringList): integer;
  end;

  TspResumoLinhaCodigo = class
  private
    fnNumero: string;
    fsClasse: string;
    fsMetodo: string;
    fsLinha: string;
    fbCoberta: boolean;
    fbCodigoGerado: boolean;
  public
    function toString: string;
    property spLinha: string read fsLinha write fsLinha;
    property spMetodo: string read fsMetodo write fsMetodo;
    property spClasse: string read fsClasse write fsClasse;
    property spCoberta: boolean read fbCoberta write fbCoberta;
    property spCodigoGerado: boolean read fbCodigoGerado write fbCodigoGerado;
    property spNumero: string read fnNumero write fnNumero;
    function Clonar: TspResumoLinhaCodigo;
  end;

  TFMesclarCC = class(TForm)
    pnl1: TPanel;
    btnMesclar: TButton;
    pnl2: TPanel;
    memoArqA: TMemo;
    memoArqB: TMemo;
    pnl3: TPanel;
    memoResumo: TMemo;
    memoResumo2: TMemo;
    memoArquivos: TMemo;
    procedure btnMesclarClick(Sender: TObject);
  private
  public
  end;

var
  slLog: TStringList;
  FMesclarCC: TFMesclarCC;

implementation


{$R *.DFM}

function BoolToString(pb: boolean): string;
begin
  if pb then
    result := 'V'
  else
    result := 'F';
end;

function PreencherEsquerda(psTexto: string; psCom: string; pnQtde: integer): string;
var
  i: integer;
begin
  result := psTexto;
  for i := length(psTexto) to pnQtde - 1 do
    result := psCom + result;
end;

function PreencherDireita(psTexto: string; psCom: string; pnQtde: integer): string;
var
  i: integer;
begin
  result := psTexto;
  for i := length(psTexto) to pnQtde - 1 do
    result := result + psCom;
end;

function Substituir(texto, old, new: string): string;
begin
  result := StringReplace(texto, old, new, [rfReplaceAll]);
end;

function ApagarAntes(texto, se: string; bInclusive: boolean = True): string;
var
  n: integer;
begin
  n := pos(LowerCase(se), LowerCase(texto));
  if n <> 0 then
  begin
    if bInclusive then
      Delete(texto, 1, n + length(se) - 1)
    else
      Delete(texto, 1, n);
  end;
  result := texto;
end;

function ApagarDepois(texto, se: string; bInclusive: boolean = True): string;
var
  n: integer;
begin
  n := pos(LowerCase(se), LowerCase(texto));
  Delete(texto, n, length(texto) - n + 1);
  result := texto;
end;

function ProcurarTexto(subtexto, texto: string): boolean;
begin
  result := pos(LowerCase(subtexto), LowerCase(texto)) <> 0;
end;

function PegarListaArquivos(psCaminho: string; psFiltro: string): TStringList;
var
  bAchou: boolean;
  SearchRec: TSearchRec;
  sCaminho: string;
begin
  result := TStringList.Create; //PC_OK
  sCaminho := IncludeTrailingBackslash(psCaminho);

  bAchou := FindFirst(sCaminho + psFiltro, faAnyFile - faDirectory, SearchRec) = 0;
  while bAchou do
  begin
    result.Add(LowerCase(SearchRec.Name));
    bAchou := FindNext(SearchRec) = 0;
  end;
  FindClose(SearchRec);
end;

function TspResumoLinhaCodigo.Clonar: TspResumoLinhaCodigo;
begin
  result := TspResumoLinhaCodigo.Create;
  result.fnNumero := fnNumero;
  result.fsClasse := fsClasse;
  result.fsMetodo := fsMetodo;
  result.fsLinha := fsLinha;
  result.fbCoberta := fbCoberta;
  result.fbCodigoGerado := fbCodigoGerado;
end;

function TspResumoLinhaCodigo.toString: string;
begin
  result := 'fnNumero=' + PreencherDireita((fnNumero), ' ', 5) + ' fsClasse=' +
    fsClasse + ' fsMetodo=' + fsMetodo + ' fbCodigoGerado=' + BoolToString(fbCodigoGerado) +
    ' fbCoberta=' + BoolToString(fbCoberta) + ' fsLinha=' + fsLinha;
end;

destructor TspResumoClasse.Destroy;
var
  i: integer;
begin
  for i := 0 to slLinhasCodigos.Count - 1 do
    TspResumoLinhaCodigo(slLinhasCodigos.Objects[i]).Free;
  FreeAndNil(slLinhasCodigos); //PC_OK
end;

constructor TspResumoClasse.Create;
begin
  slLinhasCodigos := TStringList.Create; //PC_OK
  nQtdeMetodosCobertosCLASSE := 0;
  nQtdeMetodosTotalCLASSE := 0;
  nQtdeLinhasCobertasCLASSE := 0;
  nQtdeLinhasNaoCobertasCLASSE := 0;
  nQtdeLinhasTotalCLASSE := 0;
end;

destructor TspResumoProjeto.Destroy;
var
  i: integer;
begin
  for i := 0 to slListaResumoClasse.Count - 1 do
  begin
    TspResumoClasse(slListaResumoClasse.Objects[i]).Free;
  end;
  FreeAndNil(slListaResumoClasse); //PC_OK
end;

constructor TspResumoProjeto.Create; //PC_OK
begin
  slListaResumoClasse := TStringList.Create; //PC_OK
  nQtdeClassesTotalPROJETO := 0;
  nQtdeClassesCobertosPROJETO := 0;
  nQtdeMetodosCobertosPROJETO := 0;
  nQtdeMetodosTotalPROJETO := 0;
  nQtdeLinhasCobertasPROJETO := 0;
  nQtdeLinhasNaoCobertasPROJETO := 0;
  nQtdeLinhasTotalPROJETO := 0;
end;

class procedure TGerenciadorLinhasCodigo.ParserLinhas(psArquivo: string;
  poListaLinhas: TStringList);
var
  i: integer;
  sl: TStringList;
  oLinhaCodigo: TspResumoLinhaCodigo;
  bCoberta: boolean;
  bCodigoGerado: boolean;
  sLinha: string;
  sUltMetodo: string;
  sNomeUnit: string;
  nImplementation: integer;

  function PegarMetodo(poLinhaCodigo: TspResumoLinhaCodigo): boolean;
  var
    sLinha: string;
  begin
    result := False;
    sLinha := Trim(poLinhaCodigo.spLinha);
    sLinha := ApagarDepois(sLinha, '//', True);
    sLinha := ApagarDepois(sLinha, '{', True);

    if ProcurarTexto('initialization', sLinha) then
    begin
      oLinhaCodigo.spMetodo := '_DelphiInitialization';
      result := True;
    end
    else
    if ProcurarTexto('constructor', sLinha) or ProcurarTexto('destructor', sLinha) or
      ProcurarTexto('function', sLinha) or ProcurarTexto('procedure', sLinha) then
    begin

      //      if not ProcurarTexto('.', sLinha) then
      //      memoArqA.Lines.Add(sLinha);

      sLinha := ApagarAntes(sLinha, ' ', True);
      sLinha := ApagarAntes(sLinha, '.', True);
      sLinha := ApagarDepois(sLinha, ';', True);
      sLinha := ApagarDepois(sLinha, ':', True);
      sLinha := ApagarDepois(sLinha, '(', True);
      oLinhaCodigo.spMetodo := trim(sLinha);
      result := True;
    end;

  end;

  function PegarLinhaImplementation: integer;
  var
    i: integer;
    s: string;
  begin
    result := -1;
    for i := 0 to sl.Count - 1 do
    begin
      s := Trim(sl[i]);
      s := ApagarDepois(s, '//', True);
      s := ApagarDepois(s, '{', True);
      if ProcurarTexto('implementation', s) then
      begin
        result := i;
        exit;
      end;
    end;
  end;

  function PegarNomeUnit: string;
  var
    i: integer;
    s: string;
  begin
    result := '';
    for i := 0 to sl.Count - 1 do
    begin
      s := sl[i];
      if ProcurarTexto('<p>Coverage report for <strong>', s) then
      begin
        while ProcurarTexto('\', s) do
          s := ApagarAntes(s, '\', True);
        s := ApagarDepois(s, '.pas', True);
        result := Trim(s);

        if ProcurarTexto(' ', result) or ProcurarTexto('&', result) then
          ShowMessage('Parser errado: ' + sl[i]);

        exit;
      end;
    end;

    if result = '' then
      ShowMessage('Não achou o nome da Unit ' + psArquivo + #13+#10 + 'arquivo=' + sl.text);

  end;

begin
  sl := TStringList.Create;
  try
    sUltMetodo := '';
    sl.LoadFromFile(psArquivo);
    bCoberta := False;
    bCodigoGerado := False;

    sNomeUnit := PegarNomeUnit;

    nImplementation := PegarLinhaImplementation;
    if nImplementation = -1 then
      ShowMessage('Não achou Implementation ' + psArquivo);

    for i := nImplementation * 0 + 1 to sl.Count - 1 do
    begin
      sLinha := Trim(sl[i]);

      if ProcurarTexto('<tr class="nocodegen">', sLinha) then
      begin
        bCodigoGerado := False;
        bCoberta := False;
      end
      else
      if ProcurarTexto('<tr class="covered">', sLinha) then
      begin
        bCodigoGerado := True;
        bCoberta := True;
      end
      else
      if ProcurarTexto('<tr class="notcovered">', sLinha) then
      begin
        bCodigoGerado := True;
        bCoberta := False;
      end
      else
      begin
        continue;
      end;

      oLinhaCodigo := TspResumoLinhaCodigo.Create; //PC_OK
      oLinhaCodigo.spCoberta := bCoberta;
      oLinhaCodigo.spCodigoGerado := bCodigoGerado;
      oLinhaCodigo.spClasse := sNomeUnit;

      oLinhaCodigo.spNumero := trim(sl[i + 1]);
      oLinhaCodigo.spNumero := ApagarAntes(oLinhaCodigo.spNumero, '>');
      oLinhaCodigo.spNumero := ApagarAntes(oLinhaCodigo.spNumero, '<strong>');
      oLinhaCodigo.spNumero := ApagarDepois(oLinhaCodigo.spNumero, '<');

      oLinhaCodigo.spLinha := trim(sl[i + 2]);
      oLinhaCodigo.spLinha := ApagarAntes(oLinhaCodigo.spLinha, '>', True);
      oLinhaCodigo.spLinha := ApagarAntes(oLinhaCodigo.spLinha, '>', True);
      oLinhaCodigo.spLinha := ApagarDepois(oLinhaCodigo.spLinha, '</pre></td>', True);
      oLinhaCodigo.spLinha := Substituir(oLinhaCodigo.spLinha, '&nbsp;', ' ');

      {if PegarMetodo(oLinhaCodigo) then
        sUltMetodo := oLinhaCodigo.spMetodo
      else
        oLinhaCodigo.spMetodo := sUltMetodo; }
      oLinhaCodigo.spMetodo := 'MetodoGeral';
      sUltMetodo := oLinhaCodigo.spMetodo;

      poListaLinhas.AddObject(oLinhaCodigo.spMetodo + ' ' + PreencherEsquerda(
        (oLinhaCodigo.spNumero), '0', 6), oLinhaCodigo);
    end;
    poListaLinhas.Sort;

    //poListaLinhas.savetofile('c:\mescla.txt');

  finally
    FreeAndNil(sl);
  end;
end;

class procedure TGerenciadorLinhasCodigo.MesclarCC(poslCaminhoHTML: TStringList;
  psArquvioXMLDestino: string);
var
  i, nArquivo, nProjeto: integer;
  sCaminhoHTML: string;
  oResumoClasse: TspResumoClasse;
  oResumoClasseCompleto: TspResumoClasse;
  oResumoProjeto: TspResumoProjeto;
  oResumoProjetoCompleto: TspResumoProjeto;
  slArquivos: TStringList;
  slListaResumoProjeto: TStringList;
begin
  try
    slListaResumoProjeto := TStringList.Create;

    if slLog = nil then
      slLog := TStringList.Create  //PC_OK
    else
      slLog.Clear;

    //projetos
    for nProjeto := 0 to poslCaminhoHTML.Count - 1 do
    begin
      oResumoProjeto := TspResumoProjeto.Create;

      sCaminhoHTML := IncludeTrailingBackslash(poslCaminhoHTML[nProjeto]);
      slArquivos := PegarListaArquivos(sCaminhoHTML, '*.html');

      i := slArquivos.IndexOf(LowerCase('Codecoverage_summary.html'));
      if i <> -1 then
        slArquivos.Delete(i);
      slArquivos.Sort;

      //arquivos html
      for nArquivo := 0 to slArquivos.Count - 1 do
      begin
        oResumoClasse := TspResumoClasse.Create; //PC_OK
        oResumoClasse.sArquivo := slArquivos[nArquivo];
        TGerenciadorLinhasCodigo.ParserLinhas(sCaminhoHTML + oResumoClasse.sArquivo,
          oResumoClasse.slLinhasCodigos);
        oResumoProjeto.slListaResumoClasse.AddObject(oResumoClasse.sArquivo, oResumoClasse);
      end;

      slListaResumoProjeto.AddObject('', oResumoProjeto);
    end;

    //interseccao projetos
    oResumoProjetoCompleto := TspResumoProjeto.Create; //PC_OK
    for nProjeto := 0 to slListaResumoProjeto.Count - 1 do
    begin
      oResumoProjeto := TspResumoProjeto(slListaResumoProjeto.Objects[nProjeto]);

      for nArquivo := 0 to oResumoProjeto.slListaResumoClasse.Count - 1 do
      begin
        oResumoClasse := TspResumoClasse(oResumoProjeto.slListaResumoClasse.Objects[nArquivo]);
        i := oResumoProjetoCompleto.slListaResumoClasse.IndexOf(oResumoClasse.sArquivo);
        if i = -1 then
        begin
          oResumoClasseCompleto := oResumoClasse.Clonar;
          oResumoProjetoCompleto.slListaResumoClasse.AddObject(oResumoClasseCompleto.sArquivo,
            oResumoClasseCompleto);
        end
        else
        begin
          oResumoClasseCompleto :=
            TspResumoClasse(oResumoProjetoCompleto.slListaResumoClasse.Objects[i]);
          TGerenciadorLinhasCodigo.MesclarLinhas(oResumoClasse.slLinhasCodigos,
            oResumoClasseCompleto.slLinhasCodigos);
        end;
      end;
    end;

    //gerar XML
    oResumoProjetoCompleto.GerarResumoProjeto;
    oResumoProjetoCompleto.SalvarXML(psArquvioXMLDestino);
  finally
    FreeAndNil(oResumoProjetoCompleto);
    FreeAndNil(slArquivos); //PC_OK
    for i := 0 to slListaResumoProjeto.Count - 1 do
      TspResumoProjeto(slListaResumoProjeto.Objects[i]).Free;
    FreeAndNil(slListaResumoProjeto);
  end;
end;

procedure TFMesclarCC.btnMesclarClick(Sender: TObject);
var
  slCaminhoHTML: TStringList;
  sDestino: string;
begin
  slCaminhoHTML := TStringList.Create;
  try
    memoArquivos.Lines.add('D:\DUnit\MesclarCC\CodeCoverage\c');
    slCaminhoHTML.Text := memoArquivos.Text;
    sDestino := slCaminhoHTML[0] + '\saida.xml';
    TGerenciadorLinhasCodigo.MesclarCC(slCaminhoHTML, sDestino);
    memoResumo.Lines.LoadFromFile(sDestino);
    memoResumo2.Lines.Text := slLog.Text;
  finally
    FreeAndNil(slCaminhoHTML);
  end;
end;

class function TGerenciadorLinhasCodigo.CalcularIntersecaoLinhasCobertas(
  poListaLinhasA, poListaLinhasB: TStringList): integer;

var
  i, j: integer;
  oLinhaCodigoA: TspResumoLinhaCodigo;
  oLinhaCodigoB: TspResumoLinhaCodigo;
begin
  result := 0;
  for i := 0 to poListaLinhasA.Count - 1 do
  begin
    oLinhaCodigoA := TspResumoLinhaCodigo(poListaLinhasA.Objects[i]);
    if (not oLinhaCodigoA.fbCodigoGerado) or (not oLinhaCodigoA.fbCoberta) then
      continue;

    for j := 0 to poListaLinhasB.Count - 1 do
    begin
      oLinhaCodigoB := TspResumoLinhaCodigo(poListaLinhasB.Objects[j]);
      if (not oLinhaCodigoB.fbCodigoGerado) or (not oLinhaCodigoB.fbCoberta) then
        continue;

      if oLinhaCodigoA.fsLinha = oLinhaCodigoB.fsLinha then
      begin
        Inc(result);
        break;
      end;
    end;

  end;
end;

class function TGerenciadorLinhasCodigo.MesclarLinhas(poLinhasOrigem,
  poLinhasMescladas: TStringList): integer;

var
  i: integer;
  oLinhaCodigoOrigem: TspResumoLinhaCodigo;
  oLinhaCodigoMesclada: TspResumoLinhaCodigo;
  bMostrouMensagem: boolean;
begin
  result := 0;
  bMostrouMensagem := false;
  for i := 0 to poLinhasMescladas.Count - 1 do
  begin
    oLinhaCodigoMesclada := TspResumoLinhaCodigo(poLinhasMescladas.Objects[i]);
    if not oLinhaCodigoMesclada.fbCoberta then
    begin
      if i > poLinhasOrigem.Count - 1 then
        continue;
      oLinhaCodigoOrigem := TspResumoLinhaCodigo(poLinhasOrigem.Objects[i]);

      if oLinhaCodigoOrigem.spLinha <> oLinhaCodigoMesclada.spLinha then
      begin
        if not bMostrouMensagem then
        begin
          ShowMessage('Códigos fontes diferentes: ' + oLinhaCodigoOrigem.toString + '<>' +
            oLinhaCodigoMesclada.toString);
          bMostrouMensagem := true;
        end;
      end;

      if oLinhaCodigoOrigem.fbCodigoGerado then
        oLinhaCodigoMesclada.fbCodigoGerado := True;

      if oLinhaCodigoOrigem.fbCoberta then
        oLinhaCodigoMesclada.fbCoberta := True;
    end;
  end;
end;

class function TGerenciadorLinhasCodigo.CalcularQtdeLinhasCobertas(
  poListaLinhas: TStringList): integer;
var
  i: integer;
  oLinhaCodigo: TspResumoLinhaCodigo;
begin
  result := 0;
  for i := 0 to poListaLinhas.Count - 1 do
  begin
    oLinhaCodigo := TspResumoLinhaCodigo(poListaLinhas.Objects[i]);
    if oLinhaCodigo.fbCoberta then
      Inc(result);
  end;
end;

class function TGerenciadorLinhasCodigo.CalcularQtdeLinhasComCodigoGerado(
  poListaLinhas: TStringList): integer;
var
  i: integer;
  oLinhaCodigo: TspResumoLinhaCodigo;
begin
  result := 0;
  for i := 0 to poListaLinhas.Count - 1 do
  begin
    oLinhaCodigo := TspResumoLinhaCodigo(poListaLinhas.Objects[i]);
    if oLinhaCodigo.fbCodigoGerado then
      Inc(result);
  end;
end;

class function TGerenciadorLinhasCodigo.GerarMetodos(poListaLinhas: TStringList): TStringList;
var
  i: integer;
  oLinhaCodigo: TspResumoLinhaCodigo;
  sl: TStringList;
begin
  sl := TStringList.Create; //PC_OK
  for i := 0 to poListaLinhas.Count - 1 do
  begin
    oLinhaCodigo := TspResumoLinhaCodigo(poListaLinhas.Objects[i]);
    if (oLinhaCodigo.spMetodo <> '') and (sl.IndexOf(oLinhaCodigo.spMetodo) = -1) then
      sl.Add(oLinhaCodigo.spMetodo);
  end;
  result := sl;
end;

procedure TspResumoClasse.GerarResumoClasse;
var
  i: integer;
  sLinhaLog: string;
  oLinhaCodigo: TspResumoLinhaCodigo;
  sl: TStringList;
  slMetodo: TStringList;

  nQtdeLinhasCobertasMETODO: integer;
  nQtdeLinhasNaoCobertasMETODO: integer;
  nQtdeLinhasTotalMETODO: integer;

  sUltMetodo: string;
  sUltClasse: string;

  procedure classe;
  var
    nClasse: integer;
    i: integer;
  begin
    if nQtdeLinhasCobertasCLASSE > 0 then
      nClasse := 1
    else
      nClasse := 0;

    for i := 1 to 3 do
    begin
      if i = 1 then
        sl.Add(Format('<package name="%s">', [sUltClasse]))
      else if i = 2 then
        sl.Add(Format('<srcfile name="%s">', [sUltClasse]))
      else
        sl.Add(Format('<class name="%s">', [sUltClasse]));

      sl.Add(Format('  <coverage type="class, %%" value="%d%% (%d/1)"/>',
        [nClasse * 100, nClasse]));
      sl.Add(Format('  <coverage type="method, %%" value="%d%% (%d/%d)"/>',
        [round(nQtdeMetodosCobertosCLASSE / nQtdeMetodosTotalCLASSE * 100),
        nQtdeMetodosCobertosCLASSE, nQtdeMetodosTotalCLASSE]));
      sl.Add(Format('  <coverage type="block, %%" value="%d%% (%d/%d)"/>',
        [round(nQtdeLinhasCobertasCLASSE / nQtdeLinhasTotalCLASSE * 100),
        nQtdeLinhasCobertasCLASSE, nQtdeLinhasTotalCLASSE]));
      sl.Add(Format('  <coverage type="line, %%" value="%d%% (%d/%d)"/>',
        [round(nQtdeLinhasCobertasCLASSE / nQtdeLinhasTotalCLASSE * 100),
        nQtdeLinhasCobertasCLASSE, nQtdeLinhasTotalCLASSE]));
    end;

    sl.AddStrings(slMetodo);
    sl.Add('</class>');
    sl.Add('</srcfile>');
    sl.Add('</package>');

    slMetodo.Clear;
  end;

  procedure method();
  var
    nMetodo: integer;
  begin
    Inc(nQtdeMetodosTotalCLASSE);
    if nQtdeLinhasCobertasMETODO > 0 then
    begin
      Inc(nQtdeMetodosCobertosCLASSE);
      nMetodo := 1;
    end
    else
      nMetodo := 0;

    slMetodo.Add(Format('  <method name="%s">', [sUltMetodo]));
    slMetodo.Add(Format('    <coverage type="method, %%" value="%d%% (%d/1)"/>',
      [nMetodo * 100, nMetodo]));
    slMetodo.Add(Format('    <coverage type="block, %%" value="%d%% (%d/%d)"/>',
      [round(nQtdeLinhasCobertasMETODO / nQtdeLinhasTotalMETODO * 100),
      nQtdeLinhasCobertasMETODO, nQtdeLinhasTotalMETODO]));
    slMetodo.Add(Format('    <coverage type="line, %%" value="%d%% (%d/%d)"/>',
      [round(nQtdeLinhasCobertasMETODO / nQtdeLinhasTotalMETODO * 100),
      nQtdeLinhasCobertasMETODO, nQtdeLinhasTotalMETODO]));
    slMetodo.Add('  </method>');

    nQtdeLinhasCobertasMETODO := 0;
    nQtdeLinhasNaoCobertasMETODO := 0;
    nQtdeLinhasTotalMETODO := 0;

    if sUltClasse <> oLinhaCodigo.spClasse then
    begin
      if sUltClasse <> '' then
        classe;
      sUltClasse := oLinhaCodigo.fsClasse;
    end;
  end;

begin
  sl := TStringList.Create;
  slMetodo := TStringList.Create;
  try
    nQtdeLinhasCobertasMETODO := 0;
    nQtdeLinhasNaoCobertasMETODO := 0;
    nQtdeLinhasTotalMETODO := 0;

    {for i := 0 to poListaLinhas.Count - 1 do
    begin
      oLinhaCodigo := TspResumoLinhaCodigo(poListaLinhas.Objects[i]);
      //if oLinhaCodigo.fbCodigoGerado and (not oLinhaCodigo.fbCoberta) then
      sl.Add(oLinhaCodigo.toString);
    end;
    sl.SaveToFile('c:\mescla.txt');
    sl.Clear;}

    sUltMetodo := '';
    sUltClasse := '';

    for i := 0 to slLinhasCodigos.Count - 1 do
    begin
      oLinhaCodigo := TspResumoLinhaCodigo(slLinhasCodigos.Objects[i]);
      if i = 0 then
        sClasse := oLinhaCodigo.fsClasse;

      if oLinhaCodigo.fbCodigoGerado then
      begin
        if sUltMetodo <> oLinhaCodigo.fsMetodo then
        begin
          if sUltMetodo <> '' then
            method();
          sUltMetodo := oLinhaCodigo.fsMetodo;
        end;

        if oLinhaCodigo.fbCoberta then
        begin
          Inc(nQtdeLinhasCobertasMETODO);
          Inc(nQtdeLinhasCobertasCLASSE);
        end
        else
        begin
          Inc(nQtdeLinhasNaoCobertasMETODO);
          Inc(nQtdeLinhasNaoCobertasCLASSE);
        end;
        nQtdeLinhasTotalMETODO := nQtdeLinhasCobertasMETODO + nQtdeLinhasNaoCobertasMETODO;
        nQtdeLinhasTotalCLASSE := nQtdeLinhasCobertasCLASSE + nQtdeLinhasNaoCobertasCLASSE;

      end;

    end;

    if sUltMetodo <> '' then
      method();
    classe;

    sXML := sl.Text;

    sLinhaLog := PreencherDireita(sClasse, ' ', 45) + '|';
    sLinhaLog := sLinhaLog + toString;
    slLog.Add(sLinhaLog);

  finally
    FreeAndNil(sl);
    FreeAndNil(slMetodo);
  end;
end;

procedure TspResumoProjeto.SalvarXML(psArquivo: string);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Text := sXML;
    if FileExists(psArquivo) then
      CopyFile(PChar(psArquivo), PChar(ApagarDepois(psArquivo, '.xml') + 'ORIGINAL.xml'), False);
    sl.SaveToFile(psArquivo);
  finally
    FreeAndNil(sl);
  end;
end;

function TspResumoClasse.toString: string;
begin
  result := '';
  result := result + PreencherDireita(IntToStr(nQtdeLinhasCobertasCLASSE), ' ', 6) + '|';
  result := result + PreencherDireita(IntToStr(nQtdeLinhasTotalCLASSE), ' ', 6) + '|';
  result := result + IntToStr(round(100 * nQtdeLinhasCobertasCLASSE /
    nQtdeLinhasTotalCLASSE)) + '%';
end;

procedure TspResumoProjeto.GerarResumoProjeto;
var
  i: integer;
  sl: TStringList;
  oResumoClasse: TspResumoClasse;

begin
  sl := TStringList.Create; //PC_OK
  try
    for i := 0 to slListaResumoClasse.Count - 1 do
    begin
      oResumoClasse := TspResumoClasse(slListaResumoClasse.Objects[i]);

      oResumoClasse.GerarResumoClasse;

      //linhas
      nQtdeLinhasTotalPROJETO := nQtdeLinhasTotalPROJETO + oResumoClasse.nQtdeLinhasTotalCLASSE;
      nQtdeLinhasCobertasPROJETO :=
        nQtdeLinhasCobertasPROJETO + oResumoClasse.nQtdeLinhasCobertasCLASSE;

      //métodos
      nQtdeMetodosTotalPROJETO := nQtdeMetodosTotalPROJETO + oResumoClasse.nQtdeMetodosTotalCLASSE;
      nQtdeMetodosCobertosPROJETO := nQtdeMetodosCobertosPROJETO +
        oResumoClasse.nQtdeMetodosCobertosCLASSE;

      //classes
      Inc(nQtdeClassesTotalPROJETO);
      if oResumoClasse.nQtdeMetodosCobertosCLASSE > 0 then
        Inc(nQtdeClassesCobertosPROJETO);

      sl.Add(oResumoClasse.sXML);
    end;

    sl.Insert(0, '<?xml version="1.0" encoding="Windows-1252" standalone="no"?>');
    sl.Insert(1, '<report>');
    sl.Insert(2, '<data>');
    sl.Insert(3, '<all name="all classes">');

    sl.Insert(4, Format('  <coverage type="class, %%" value="%d%% (%d/%d)"/>',
      [round(nQtdeClassesCobertosPROJETO / nQtdeClassesTotalPROJETO * 100),
      nQtdeClassesCobertosPROJETO, nQtdeClassesTotalPROJETO]));

    sl.Insert(5, Format('  <coverage type="method, %%" value="%d%% (%d/%d)"/>',
      [round(nQtdeMetodosCobertosPROJETO / nQtdeMetodosTotalPROJETO * 100),
      nQtdeMetodosCobertosPROJETO, nQtdeMetodosTotalPROJETO]));

    sl.Insert(6, Format('  <coverage type="block, %%" value="%d%% (%d/%d)"/>',
      [round(nQtdeLinhasCobertasPROJETO / nQtdeLinhasTotalPROJETO * 100),
      nQtdeLinhasCobertasPROJETO, nQtdeLinhasTotalPROJETO]));

    sl.Insert(7, Format('  <coverage type="line, %%" value="%d%% (%d/%d)"/>',
      [round(nQtdeLinhasCobertasPROJETO / nQtdeLinhasTotalPROJETO * 100),
      nQtdeLinhasCobertasPROJETO, nQtdeLinhasTotalPROJETO]));

    sl.Insert(8, '');

    sl.Add('</all>');
    sl.Add('</data>');
    sl.Add('</report>');
    sXML := sl.Text;
  finally
    FreeAndNil(sl);
  end;
end;

function TspResumoClasse.Clonar: TspResumoClasse;
var
  i: integer;
  oLinhaCodigo: TspResumoLinhaCodigo;
begin
  result := TspResumoClasse.Create;
  result.sXML := sXML;
  result.sArquivo := sArquivo;
  for i := 0 to slLinhasCodigos.Count - 1 do
  begin
    oLinhaCodigo := TspResumoLinhaCodigo(slLinhasCodigos.Objects[i]).Clonar;
    result.slLinhasCodigos.AddObject(oLinhaCodigo.spMetodo, oLinhaCodigo);
  end;
end;

end.

