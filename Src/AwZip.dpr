{*******************************************************}
{                                                       }
{    Utility for creating and extracting Zip Files      }
{                                                       }
{                                                       }
{*******************************************************}
program AwZip;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  System.Classes,
  System.Zip,
  AwSysUtils in 'AwSysUtils.pas';

const
  NEWLINE = #13#0;
  ZIPMODE = '-Z';
  UNZIPMODE = '-U';

var
  FileDirName, ArchiveName: string;

  FoundFile, FoundDir, FoundZip: Boolean;
  i: integer;
  Mode, h: string;
  pCount: byte;
  ProcessSuccess, FoundArchiveFile, FoundPath: Boolean;
  userParamStr: array [0 .. 3] of string;
  ZipKind: TZipKind;

procedure Help;
begin
  writeln(' ---------------------------' + NEWLINE);
  writeln('            Help' + NEWLINE);
  writeln(' ---------------------------' + NEWLINE);
  writeln(' Author: Samrid Somboon' + NEWLINE);
  writeln(' Email : samrids@gmail.com' + NEWLINE);
  writeln(' ---------------------------' + NEWLINE);
  writeln(' How to use program.');
  writeln('');
  writeln(' d:\AwZip.exe -h -z -u zip dest' + NEWLINE);
  writeln(' when' + NEWLINE);
  writeln('  -h    :Show help.');
  writeln('  -z    :Zip file or directory.');
  writeln('  -u    :Unzip file.');
  writeln('   zip  :Zip file' + NEWLINE);
  writeln('   dest :Destination direcotry.' + NEWLINE);
  writeln('');
  writeln(' Sample.' + NEWLINE);
  writeln(' 1.Zip file/directory.' + NEWLINE);
  writeln('   1.1.Zip file' + NEWLINE);
  writeln('       d:\Awzip.exe -z c:\temp\example\sample.txt c:\temp\example\example.zip'
    + NEWLINE);
  writeln('   1.2.Zip directory.' + NEWLINE);
  writeln('       d:\Awzip.exe -z c:\temp\example\sampledir c:\temp\example\samp.zip'
    + NEWLINE);
  writeln('');
  writeln(' 2.Unzip file.' + NEWLINE);
  writeln('   d:\AwZip.exe -u c:\temp\example.zip c:\temp\example' + NEWLINE);
  writeln('');
  writeln(' 3.Show help.' + NEWLINE);
  writeln('   d:\AwZip.exe -h' + NEWLINE);

end;

procedure InvalidParamStr;
begin
  writeln('');
  writeln(' Invalid parameters');
  writeln('');
  Help;
end;

function ZipDirectory(const Folder: string; const ArchiveName: string): Boolean;
var
  Zip: TZipFile;
  i: integer;
  AListFolders: TStrings;
begin
  Zip := TZipFile.Create;
  try
    try
      if FileExists(ArchiveName) then
        DeleteFile(ArchiveName);
      Zip.Open(ArchiveName, zmWrite);
      AListFolders := ListFiles(Folder);
      Displayfiles(AListFolders);
      for i := 0 to AListFolders.Count - 1 do
        Zip.Add(Folder + '\' + Trim(AListFolders.Strings[i]));
      Zip.Close;
      result := true;
    except
      result := false;
    end;
  finally
    FreeAndNil(Zip);
    FreeAndNil(AListFolders);
  end;
end;

function ZipFile(const FileName: String; const ArchiveName: string): Boolean;
var
  Zip: TZipFile;
begin
  Zip := TZipFile.Create;
  try
    try
      if FileExists(ArchiveName) then
        DeleteFile(ArchiveName);
      Zip.Open(ArchiveName, zmWrite);
      Zip.Add(FileName);
      Zip.Close;
      result := true;
    except
      result := false;
    end;
  finally
    FreeAndNil(Zip);
  end;
end;

function UnZipFile(ArchiveName, Path: String): Boolean;
var
  Zip: TZipFile;
begin
  Zip := TZipFile.Create;
  try
    try
      Zip.Open(ArchiveName, zmRead);
      Zip.ExtractAll(Path);
      Zip.Close;
      result := true;
    except
      result := false;
    end;
  finally
    Zip.Free;
  end;
end;

begin
  pCount := ParamCount;
  for i := 1 to ParamCount do
  begin
    userParamStr[i] := ParamStr(i);
  end;

  case pCount of
    1:
      begin
        h := userParamStr[1];
        if UpperCase(h) = '-H' then
          Help
        else
          InvalidParamStr;
      end;
    2:
      begin
        InvalidParamStr;
      end;
    3:
      begin
        Mode := UpperCase(userParamStr[1]);

        // Zip = -Z
        if (Mode = ZIPMODE) then
        begin

          FileDirName := userParamStr[2];
          ArchiveName := userParamStr[3];

          ZipKind := IsZipKind(FileDirName);
          case ZipKind of
            zkFile:
              begin
                writeln('zkfile');
                FoundFile := FileExists(FileDirName);
                FoundZip := FileExists(ArchiveName);

                if ((FoundFile = true) and (FoundZip = false)) then
                begin
                  if ZipFile(FileDirName, ArchiveName) then
                    writeln(format('  Zip to...%s', [ArchiveName]));
                end
                else
                begin
                  case FoundFile of
                    false:
                      writeln(' File does not exist !!!');
                    true:
                      writeln(' File is OK.');
                  end;
                  case FoundZip of
                    false:
                      writeln(' Archive is Ok!!!');
                    true:
                      writeln(' Can not overwrite Archive !!!');
                  end;
                end;
              end;
            zkDirectory:
              begin
                FoundDir := DirectoryExists(FileDirName);
                FoundZip := FileExists(ArchiveName);

                if ((FoundDir = true) and (FoundZip = false)) then
                begin
                  if ZipDirectory(FileDirName, ArchiveName) then
                    writeln(format('  Zip to...%s', [ArchiveName]));
                end
                else
                begin
                  case FoundDir of
                    false:
                      writeln(' Directory does not exist !!!');
                    true:
                      writeln(' Directory is OK.');
                  end;
                  case FoundZip of
                    false:
                      writeln(' Archive is Ok!!!');
                    true:
                      writeln(' Can not overwrite Archive !!!');
                  end;
                end;
              end;
          end;
        end

        // Unzip = -U
        else if (Mode = UNZIPMODE) then
        begin
          ArchiveName := userParamStr[2];
          FileDirName := userParamStr[3];

          FoundArchiveFile := FileExists(ArchiveName);
          FoundPath := DirectoryExists(FileDirName);

          writeln('');
          case FoundArchiveFile of
            true:
              writeln(' Archive is OK');
            false:
              writeln(' Zip file does not exist. !!!');
          end;

          case FoundPath of
            true:
              writeln(' Destination folder is OK');
            false:
              writeln(' Folder does not exist. !!!');
          end;

          // process when archivefile ok and Foder destination is ok
          if (FoundArchiveFile and FoundPath) then
          begin
            writeln('');
            writeln(format('Start extract zip file: %s.', [ArchiveName]));
            writeln(' Please wait...');
            ProcessSuccess := UnZipFile(ArchiveName, FileDirName);
            if ProcessSuccess then
              writeln(format(' Extract %s to %s successful.',
                [ArchiveName, FileDirName]))
            else
              writeln(format(' Extract zip file to %s un-successful.',
                [FileDirName]))
          end;
        end
        else
          InvalidParamStr;
      end;
  else
    begin
      InvalidParamStr;
    end;
  end;

  // readln;
end.
