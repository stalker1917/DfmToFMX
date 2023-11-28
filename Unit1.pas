unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Vcl.ExtCtrls,Translator,JPEG{,Unit2,Unit3},
  Vcl.Imaging.pngimage,Math;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    //procedure StartTranslate;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
   // procedure Image1Click(Sender: TObject);
    //procedure Button6Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
//TDices = Array[0..5] of Byte;
const
  XY:Array [0..1] of String = ('X','Y');
var
  Form1: TForm1;
  TextParMode : Boolean;
  OutF : Text;


implementation

{$R *.dfm}

  {
procedure TForm1.Button6Click(Sender: TObject);
begin

end;   }

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   {$I-}
 // CloseFile(FileLog);
   {$I+}
end;


procedure TForm1.FormCreate(Sender: TObject);
var i,j,k,a,b,c,NumBlock:Integer;
S,Name:WideString;
Delact:Boolean;
PanelCount:Word;
begin
  FileToText('operators.txt',Operators);
  FileToText('input.txt',Input);
  PanelCount := 0;
  AddTText(OutPut2,'procedure TForm1.FormResize(Sender: TObject);');
  AddTText(OutPut2,'var ScaleX,ScaleY:Integer;');
  AddTText(OutPut2,'begin');
  AddTText(OutPut2,'{$IFDEF ANDROID}');
  AddTText(OutPut2,'ScaleX := ClientWidth/EtalonWidth;');
  AddTText(OutPut2,'ScaleY := ClientHeight/EtalonHeigth;');
  NumBlock:=0;
  for I := 0 to High(Input) do
    begin
      if i<=NumBlock then continue;
      if (PanelCount>0) and ((FindOperator(Input[i],9)>-1)) then
        begin
          dec(PanelCount);
          if PanelCount=0 then  AddTText(OutPut,Input[i]);
          continue;
        end;
      c := FindOperator(Input[i],0);
      if c>-1 then
        begin
          a := 0;
          for j := 20 to 32 do
            begin
              b := FindOperator(Input[i],j);
              if b>-1 then a := j;
            end;
          if a>0 then
            begin
              j := 0;
              AddTText(OutPut,Input[i]);
              b := FindSpaceBar(Input[i],c);
              c := FindOperator(Input[i],2);
              if (b>-1) and (c>b) then  Name := Copy(Input[i],b+1,c-b-1)
                                  else  Name := '';

              case a of
                20: //TMemo
                  begin
                    AddTText(OutPut,'Touch.InteractiveGestures = [Pan, LongTap, DoubleTap]');
                    AddTText(OutPut,'DataDetectorTypes = []');
                  end;
                21:
                  begin
                     AddTText(OutPut,'StyledSettings = []');//TLabel
                     AddTText(OutPut,'HitTest = True');
                  end;
                22:  AddTText(OutPut,'Touch.InteractiveGestures = [LongTap, DoubleTap]'); //TEdit
                25:  AddTText(OutPut,'HitTest = True');
              end;
              repeat
                if (a=23) and (FindOperator(Input[i+j+1],0)>-1) then
                  begin
                    inc(PanelCount);
                    break;
                  end;
                if (a=25) then
                    if (FindOperator(Input[i+j+1],4)>-1) then
                      repeat
                        inc(j);
                      until (FindOperator(Input[i+j],6)>-1);  //}
                inc(j);
                S := Input[i+j];


                if (a=21) or (a=20) then
                  for k := 7 to 8 do
                    begin
                      b:= FindOperator(S,k);
                      if b>-1 then
                        S:=Substitute(S,k,k+26);
                    end;
                if (a=25) then
                  for k := 39 to 40 do
                    if FindOperator(S,k)>-1 then
                      S:=Substitute(S,k,k+2);
                if (a=27) then      //TrackBar
                  begin
                    b:= FindOperator(S,37);
                    if b>-1 then
                        S:=Substitute(S,37,38);
                  end;
                for k := 10 to 14 do
                  begin
                    b:= FindOperator(S,k);
                    c:= FindOperator(S,3); //=
                    if (b>-1) and (b<c) then
                      begin
                        if (k<=11) and (Name<>'') then
                          AddTText(OutPut2,Name+'.'+Operators[k+5]+' = EtalonTo'+XY[k-10]+'('+Copy(S,c+1,Length(S)-c)+');');
                        S:= Substitute(S,k,k+5);
                        break;
                      end;
                  end;
                AddTText(OutPut,S);
              until (FindOperator(Input[i+j],9)>-1);
              if (Name<>'') then
                begin
                  AddTText(OutPut2,Name+'.'+'Scale.X = ScaleX;');
                  AddTText(OutPut2,Name+'.'+'Scale.Y = ScaleY;');
                end;
              NumBlock := i+j;
            end
          else
            if PanelCount>0 then inc(PanelCount);
        end;
    end;
   AddTText(OutPut2,'{$ENDIF}');
   AddTText(OutPut2,'end;');
 //--------Записываем выходной файл---------
  AssignFile(OutF,'output.txt');
  Rewrite(OutF);
  for I := 0 to High(OutPut) do Writeln(OutF,OutPut[i]);
  CloseFile(OutF);

   //--------Записываем выходной файл---------
  AssignFile(OutF,'output2.txt');
  Rewrite(OutF);
  for I := 0 to High(OutPut2) do Writeln(OutF,OutPut2[i]);
  CloseFile(OutF);
 //-------Записываем лог ошибок------------
  AssignFile(OutF,'errlog.txt');
  Rewrite(OutF);
  for I := 0 to High(Errlog) do Writeln(OutF,Errlog[i]);
  CloseFile(OutF);
  Close;
end;



end.
