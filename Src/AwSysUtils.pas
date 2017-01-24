{*******************************************************}
{                                                       }
{           Aw. Delphi Runtime Library                  }
{                                                       }
{                                                       }
{*******************************************************}

unit AwSysUtils;

interface

uses
  Classes,
  SysUtils;

type
  TZipKind = (zkFile, zkDirectory);

function OccurrencesOfChar(const ContentString: string;
  const CharToCount: char): integer;
function GetFolderName(const IDStr: string): TStrings;
function ListFiles(const Folder: string): TStrings;
function GetFolder(const List: TStrings): string;
function Displayfiles(AListFolders: TStrings): boolean;
function IsZipKind(const AFileName: string): TZipKind;

implementation

function IsZipKind(const AFileName: string): TZipKind;
var
  extension: string;
begin
  result := zkDirectory;
  extension := ExtractFileExt(AFileName);
  if (Length(extension) = 4) then
    result := zkFile;
end;

function Displayfiles(AListFolders: TStrings): boolean;
var
  i: integer;
begin
  result := true;
  try
    writeln('  List of file.');
    for i := 0 to AListFolders.Count - 1 do
    begin
      writeln('  -' + AListFolders.Strings[i]);
    end;
    writeln('');
  except
    on exception do
    begin
      result := false;
    end;
  end;

end;

function GetFolder(const List: TStrings): string;
var
  i: word;
begin
  for i := 0 to List.Count - 2 do
    result := result + List.Strings[i] + '\';
end;

function ListFiles(const Folder: string): TStrings;
var
  Path: String;
  SR: TSearchRec;
begin
  Path := Folder;
  if Copy(Path, Length(Path), 1) <> '\' then
    Path := Path + '\';

  result := TStringList.Create;
{$WARN SYMBOL_PLATFORM OFF}
  if FindFirst(Path + '*.*', faArchive, SR) = 0 then
  begin
    repeat
      result.Add(SR.Name);
    until FindNext(SR) <> 0;
    FindClose(SR);
  end;
{$WARN SYMBOL_PLATFORM ON}
end;

function OccurrencesOfChar(const ContentString: string;
  const CharToCount: char): integer;
var
  i: word;
begin
  result := 0;
  for i := 1 to Length(ContentString) do
  begin
    if ContentString[i] = CharToCount then
      Inc(result);
  end;
end;

function GetFolderName(const IDStr: string): TStrings;
var
  Count, i: byte;
  tmpStr: string;
begin
  result := TStringList.Create;
  result.Clear;
  Count := OccurrencesOfChar(IDStr, '\');
  tmpStr := IDStr;
  for i := 1 to Count + 1 do
  begin
    if Pos('\', tmpStr) > 0 then
    begin
      result.Add(Copy(tmpStr, 1, (Pos('\', tmpStr) - 1)));
      tmpStr := Copy(tmpStr, Pos('\', tmpStr) + 1, Length(tmpStr));
    end
    else
      result.Add(tmpStr);
  end;
end;

end.
