object FMesclarCC: TFMesclarCC
  Left = 244
  Top = 170
  ActiveControl = btnMesclar
  Caption = 'Mesclar Arquivos HTML CC'
  ClientHeight = 634
  ClientWidth = 1073
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Visible = True
  PixelsPerInch = 96
  TextHeight = 13
  object pnl1: TPanel
    Left = 0
    Top = 0
    Width = 1073
    Height = 75
    Align = alTop
    TabOrder = 0
    object btnMesclar: TButton
      Left = 10
      Top = 6
      Width = 106
      Height = 30
      Caption = '&Mesclar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -19
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnMesclarClick
    end
    object memoArquivos: TMemo
      Left = 123
      Top = 4
      Width = 556
      Height = 64
      TabOrder = 1
    end
  end
  object pnl2: TPanel
    Left = 0
    Top = 75
    Width = 1073
    Height = 200
    Align = alTop
    TabOrder = 1
    Visible = False
    object memoArqA: TMemo
      Left = 1
      Top = 1
      Width = 500
      Height = 198
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      WordWrap = False
    end
    object memoArqB: TMemo
      Left = 501
      Top = 1
      Width = 571
      Height = 198
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Lines.Strings = (
        
          'function TfaipCadHistoricoParte.TestarPodeEncerrarControlePena(v' +
          'ar psComplMsg: string): boolean;'
        #9
        
          ' function TestarClone(poClone: TspClientDataSet; psFilter, psCom' +
          'plMensagem: string): boolean;'
        #9'  var'
        #9'    oClone: TspClientDataSet;'
        #9'  begin'
        #9'    result := True;'
        #9'    oClone := TspClientDataSet.Create(nil);'
        #9'    try'
        #9'      oClone.CloneCursor(poClone, True, True);'
        #9'      if not oClone.isEmpty then'
        #9'      begin'
        #9'        oClone.Filter := psFilter;'
        #9'        oClone.Filtered := True;'
        #9'        if not oClone.IsEmpty then'
        #9'        begin'
        #9'          result := False;'
        #9'          psComplMsg := psComplMensagem;'
        #9'        end;'
        #9'      end;'
        #9'    finally'
        #9'      FreeAndNil(oClone);'
        #9'    end;'
        #9'  end;'
        #9
        #9'begin'
        #9'  result := True;'
        #9'  if assigned(faipFrmDadosPrisao) then'
        #9'  begin'
        #9'    // 24/05/2012 - Fischer - SALT: 97053/1'
        
          #9'    result := TestarClone(TspClientDataSet(faipFrmDadosPrisao.e' +
          'aipDadosPrisao),'
        
          #9'      '#39'dtTermino is null and flPrisaoOutroJuizo = '#39#39'N'#39#39#39', '#39'pris' +
          #227'o'#39');'
        #9'  end;'
        #9'  if Assigned(faipFrmAcompLivCond) then'
        #9'  begin'
        
          #9'    result := TestarClone(TspClientDataSet(faipFrmAcompLivCond.' +
          'dsAcompHist.DataSet),'
        
          #9'      '#39'dtRealizada is null and flSituacao <> '#39#39'I'#39#39#39', '#39'livrament' +
          'o condicional'#39');'
        #9'  end'
        #9'  else'
        #9'  if Assigned(faipFrmAcompRestritiva) then'
        #9'  begin'
        
          #9'    result := TestarClone(TspClientDataSet(faipFrmAcompRestriti' +
          'va.dsAcompHist.DataSet),'
        
          #9'      '#39'dtRealizada is null and flSituacao <> '#39#39'I'#39#39#39', '#39'pena rest' +
          'ritiva'#39');'
        ' end;'
        'end;')
      ParentFont = False
      TabOrder = 1
      WordWrap = False
    end
  end
  object pnl3: TPanel
    Left = 0
    Top = 275
    Width = 1073
    Height = 359
    Align = alClient
    TabOrder = 2
    object memoResumo: TMemo
      Left = 1
      Top = 1
      Width = 501
      Height = 357
      Align = alLeft
      Font.Charset = ANSI_CHARSET
      Font.Color = clBackground
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      WordWrap = False
    end
    object memoResumo2: TMemo
      Left = 502
      Top = 1
      Width = 570
      Height = 357
      Align = alClient
      Font.Charset = ANSI_CHARSET
      Font.Color = clBackground
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      WordWrap = False
    end
  end
end
