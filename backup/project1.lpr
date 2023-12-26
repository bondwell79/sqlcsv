program project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp,ODBCConn, sqldb, db, base64
  { you can add units after this };

type

  { sqlcsv }

  sqlcsv = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

{ sqlcsv }

procedure sqlcsv.DoRun;
var
  conexion1    : todbcconnection;
  transaccion1 : tsqltransaction;
  query1       : tsqlquery;
  fichero      : textfile;
  tcolumna     : word;
  registro     : string;
  driver1      : string;
  dsn1         : string;
  ip1          : string;
  usuario1     : string;
  ps1          : string;
  consulta1    : string;
  salidacsv    : string;
begin

  // parametros
  writeln('##################################################################');
  writeln(' SQLCSV version v0002 - Programado por Rubén Pastor Villarrubia');
  writeln;
  writeln(' Wasx Alpha Software 1984, 2023');
  writeln('##################################################################');
  writeln;

  if length(paramstr(1))>1 then driver1:=paramstr(1) else driver1:='';
  if length(paramstr(2))>1 then dsn1:=paramstr(2) else dsn1:='';
  if length(paramstr(3))>1 then ip1:=paramstr(3) else ip1:='';
  if length(paramstr(4))>1 then usuario1:=paramstr(4) else usuario1:='';
  if length(paramstr(5))>1 then ps1:=paramstr(5) else ps1:='';
  if length(paramstr(6))>1 then consulta1:=decodestringbase64(paramstr(6)) else consulta1:='';
  if length(paramstr(7))>1 then salidacsv:=paramstr(7) else salidacsv:='';

  if driver1='' then writeln('No se ha especificado controlador ODBC.');
  if dsn1='' then writeln('No se ha especificado DSN.');
  if ip1='' then writeln('No se ha especificado hosname.');
  if usuario1='' then writeln('No se ha especificado usuario.');
  if ps1='' then writeln('No se ha especificado contraseña.');
  if consulta1='' then writeln('No se ha indicado sentencia SQL a ejecutar.');
  if salidacsv='' then writeln('No se ha especificado un fichero de destino.');

  // mostramos valores
  writeln;
  writeln('DRIVER: ',driver1);
  writeln('DSN: ',dsn1);
  writeln('HOSTNAME: ',ip1);
  writeln('USER: ',usuario1);
  writeln('FICHERO: ',salidacsv);
  writeln;
  if (consulta1<>'') then
  begin

  // creamos objetos

  conexion1 := TODBCConnection.Create(nil);
  transaccion1 := TSQLTransaction.Create(nil);
  query1 :=TSQLQuery.Create(nil);

  //conexion

  conexion1.driver:=driver1;
  conexion1.databasename:=dsn1;
  conexion1.HostName:=ip1;
  conexion1.UserName:=usuario1;
  conexion1.Password:=ps1;
  conexion1.Connected:=true;
  conexion1.Transaction:=transaccion1;
  transaccion1.DataBase:=conexion1;

  query1.DataBase:=conexion1;
  query1.Transaction:=transaccion1;
  query1.ParseSQL:=true;
  query1.PacketRecords:=-1;
  query1.UniDirectional:=true;


    //hacemos el query
    writeln('Conectamos con servidor ...');
    query1.SQL.Text:=consulta1;

    query1.Open;

  writeln('Exportando registros ...');
  assignfile(fichero,salidacsv);
  rewrite(fichero);

    //columnas
  registro:=query1.Fields[0].FieldName;
  for tcolumna:=1 to query1.FieldCount-1 do registro:=registro+#9+'"'+query1.Fields[tcolumna].FieldName+'"';
  writeln(fichero,registro);
    //filas
    while not query1.eof do
          begin
          registro:='"'+query1.Fields[0].Text+'"';
          for tcolumna:=1 to query1.FieldCount-1 do registro:=registro+#9+'"'+query1.Fields[tcolumna].Text+'"';
          writeln(fichero,registro);
          query1.next;
          end;


  query1.close;
  closefile(fichero);
  writeln('Proceso terminado.');
  // stop program loop
  conexion1.Free;
  transaccion1.free;
  query1.free;

  end else
      begin
      writeln;
      writeln(' Uso: ');
      writeln(' sqlcsv {driver} {dsn} {hostname} {usuario} {contraseña} {consulta_sql} {fichero.csv}');
      writeln;
      writeln;
      writeln('        {driver}       : Definición de controlador ODBC (Obligatorio)');
      writeln('        {dsn}          : Nombre de DSN ODBC (opcional)');
      writeln('        {hostname}     : Hostname/IP del servidor (opcional)');
      writeln('        {usuario}      : Usuario (obligatorio)');
      writeln('        {contraseña}   : Contraseña (obligatorio)');
      writeln('        {consulta_sql} : Consulta SQL en base64 (obligatorio)');
      writeln('        {fichero.csv}  : Fichero de destino en formato CSV (obligatorio)');

      end;
  Terminate;
end;

constructor sqlcsv.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor sqlcsv.Destroy;
begin
  inherited Destroy;
end;



var
  Application: sqlcsv;
begin
  Application:=sqlcsv.Create(nil);
  Application.Title:='sqlcsv';
  Application.Run;
  Application.Free;
end.

