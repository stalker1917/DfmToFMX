unit Translator;

interface

uses SysUtils
{$IFDEF ANDROID}
,FMX.Objects,System.IOUtils;
{$ELSE}
 ;
{$ENDIF}

type
   TText = Array of String;
   SNumber = Record
     S : WideString;
     N : Word;
     D : Boolean; //Блок отключён.
   End;
   VInteger = Record
     S : WideString;
     N : Integer;
   End;

var
 // Blocks    : Array of TBlock;
  Operators : TText;//array [0..30] of string; //Список опреаторов
  Input     : TText;
  CodBattle : TText;
  OutPut,OutPut2,Errlog  : TText;
  f         : System.text;
  //В сохранение
  CurrentBlock : Integer = 0;
  //Level        : Integer = 0; //Easy
  ScoreMan     : Integer = 0;
  ScoreBot     : Integer = 0;
  Variables    : Array of VInteger; // Объявляемые в коде перемеенные.  CurrentBlock - 0 , Level - 1;
 // FLImages     : Array [0..10] of TElement; //0- Form 1..5- Label 6..9 -Images
  CurrSound    : String = '';
  CurrImage    : String = '';

Procedure FileToText(S:String; var Dump:TText);
function FindStrWithOperator(var Dump : TText; Number : Integer) : Integer;
function FindOperator(S:String; Number:Integer; pos:Integer=1; LowerCaseFlag:Boolean=False) :Integer;
function FindLastOperator(S:String; Number:Integer; pos:Integer=-1) :Integer;
Function CheckVariable(S:String;j:Integer):Integer; overload;
function GetStringWithOperator(var S:String;Number:Integer;P:Integer=1):String;
Procedure AddTText(var T:TText; S:String);
function DeleteSpaceBars(S:String; Mode:Integer):String;
function FindVariable(S:String):Integer;
function Substitute(const S:String;N,M:Integer):String;
function ToCycle(var S:String;N:Integer):Integer;
function DowntoCycle(var S:String;N:Integer):Integer;
function FindSpaceBar(var S:String; Pos :Integer; Invert:Boolean=False):Integer;

implementation


Function CheckVariable(S:String;j:Integer):Integer;
begin
  Operators[37] := Variables[j].S;
  result := FindOperator(S,37);
end;

function FindOperator;
var i,High:Integer;
begin
  if LowerCaseFlag then S:=LowerCase(S);
  High := Length(s)-Length(Operators[Number])+1; //Точно ли +1?
  if Length(S)<2 then
    begin
      Result := -1;
      exit;
    end;
  for I := pos to High do
    if (s[i]=Operators[Number,1]) and (Copy(S,i,Length(Operators[Number]))=Operators[Number]) then
      begin
        Result := i;
        Break;
      end;
  if i>High then  Result := -1;
end;

function FindSpaceBar;
  begin
    if not Invert then result := ToCycle(S,Pos)
              else result := DownToCycle(S,Pos);
    if (result>Length(S))then result := -1;
  end;

function FindLastOperator;
var i,High:Integer;
begin
  High := Length(s)-Length(Operators[Number])+1;
  if Length(S)<2 then
    begin
      Result := -1;
      exit;
    end;
  if pos>High then pos := High;
  if pos<0 then pos := High;

  for I := pos downto 0 do
    if (s[i]=Operators[Number,1]) and (Copy(S,i,Length(Operators[Number]))=Operators[Number]) then
      begin
        Result := i;
        Break;
      end;
  if i<0 then  Result := -1;
end;

function FindStrWithOperator;
var i,a:Integer;
begin
  result := -1;
  for i := 0 to High(Dump) do
    begin
      a:=FindOperator(Dump[i],Number);
      if a>-1 then
        begin
          result := i;
          exit;
        end;
    end;
end;

function GetStringWithOperator;
var
Buf : String;
Pos : Integer;
begin
   Pos := FindOperator(S,Number,P);
   if Pos=-1 then result := ''
   else
     begin
       Buf := Copy(S,Pos+1,Length(S)-Pos);
       Pos := FindOperator(Buf,Number);
       if Pos=-1 then result := Buf
       else result:= Copy(Buf,1,Pos-1);
     end;
end;



Procedure FileToText(S:String;var Dump:TText);
var s1:Ansistring;
begin
  {$IFDEF ANDROID}
  S1:= TPath.GetPublicPath+'/'+s;
  Assignfile(f,s1); //Список операторов
  s1:='';
  {$ELSE}
  Assignfile(f,s); //Список операторов
  {$ENDIF}
  Reset(f);
  SetLength(Dump,0);
  while not eof(f) do
    begin
      readln(f,s1);
      SetLength(Dump,Length(Dump)+1);
      Dump[Length(Dump)-1] := UTF8ToWideString(s1);
    end;
 if Dump[0,1]=#$FEFF then Dump[0] := Copy(Dump[0],2,Length(Dump[0])-1);
 closeFile(f);
end;




Procedure AddTText;
begin
  SetLength(T,Length(T)+1);
  T[High(T)] := S;
end;

function ToCycle(var S:String;N:Integer):Integer;
var i:Integer;
begin
   if N=-1 then
     begin
       result := -1;
       N      :=  1;
     end
   else result := Length(S)+1;
   for I := N to Length(S) do
     if (S[i]<>' ') and (S[i]<>#9) xor (result>0) then
      begin
        result:=i;
        break;
      end;
end;

function DowntoCycle(var S:String;N:Integer):Integer;
var i:Integer;
begin
   result := -1;
   if N<0 then N:= Length(S)
          else result := 1;
   for I := N downto 1 do
     if (S[i]<>' ') and (S[i]<>#9) xor (result=1) then
      begin
        result:=i; // Было i+1 ,чтобы пробел не считать.
        break;
      end;
end;


function DeleteSpaceBars(S:String; Mode:Integer):String;// Удаляем проблемы
var a,b:Integer;
begin

   case Mode of
     0:      // ___Vasa_123__  ---->Vasa_123
       begin
         a := ToCycle(S,-1);
         b := DowntoCycle(S,-1);
       end;
     1:    // ___Vasa_123__  ---->Vasa
        begin
         a := ToCycle(S,-1);
         b := ToCycle(S,a)-1;
        end;
     2:      // ___Vasa_123__  ---->_123
       begin
         b := DownToCycle(S,-1);
         a := DownToCycle(S,b);
        end;
     else
       begin
         a := -1;
         b := -1;
       end;
   end;

 if (a<0) or (b<0) or (a>b) then result := ''
 else result := Copy(S,a,b-a+1);
end;

Function FindVariable;      //Найти переменную по строке
var i:Integer;
begin
  result := -1;
  for I := 0 to High(Variables) do
      if S = Variables[i].S then
         begin
           result := i;
           exit;
         end;
end;

function Substitute;
var
a,b : Integer;
begin
  a := FindOperator(S,N);
  b := Length(Operators[N]);
  if a>-1 then  result := Copy(S,1,a-1)+Operators[M]+Copy(S,a+b,Length(S)-a-b+1)
  else result := S;
end;


end.
