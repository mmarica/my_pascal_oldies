{$A-,B-,D-,E-,F-,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}
{$M 1024,0,0} {stack=1600}
program MSoft_Commander_modulul_de_executie;
uses dos;
const inifile: string[12]='MC.INI';
      mainfile: string[12]='MCMAIN.EXE';
      tmpfile: string[12]='MC.TMP';
      cexec=22;
      ciesi=23;
var f: file;
    code,rezultat,citit: word;
    startdir: string;
    size: longint;
    iesire: boolean;
    execstr: string;
    comanda: byte;

procedure chdir(s: string);
begin
 rezultat:=ioresult;
 system.chdir(s);
 rezultat:=ioresult;
end;

procedure getdir(d: byte;var s: string);
begin
 rezultat:=ioresult;
 system.getdir(d,s);
 rezultat:=ioresult;
end;

procedure blockread(var f: file;var buf;count: word;var result: word);
begin
 rezultat:=ioresult;
 system.blockread(f,buf,count,result);
 rezultat:=ioresult;
end;

procedure blockwrite(var f: file;var buf;count: word;var result: word);
begin
 rezultat:=ioresult;
 system.blockwrite(f,buf,count,result);
 rezultat:=ioresult;
end;

procedure seek(var f: file;n: longint);
begin
 rezultat:=ioresult;
 system.seek(f,n);
 rezultat:=ioresult;
end;

procedure reset(var f: file;recsize: word);
begin
 rezultat:=ioresult;
 system.reset(f,recsize);
 rezultat:=ioresult;
end;

procedure rewrite(var f: file;recsize: word);
begin
 rezultat:=ioresult;
 system.rewrite(f,recsize);
 rezultat:=ioresult;
end;

procedure close(var f: file);
begin
 rezultat:=ioresult;
 system.close(f);
 rezultat:=ioresult;
end;

function filesize(var f: file): longint;
begin
 rezultat:=ioresult;
 filesize:=system.filesize(f);
 rezultat:=ioresult;
end;

procedure erase(var f: file);
begin
 rezultat:=ioresult;
 system.erase(f);
 rezultat:=ioresult;
end;

function getstartdir: string;
var dir: dirstr;
    name: namestr;
    ext: extstr;
    x: byte;
begin
 fsplit(paramstr(0),dir,name,ext);
 if length(dir)>3 then
 if dir[length(dir)]='\' then
 dir[0]:=chr(ord(dir[0])-1);
 for x:=1 to length(dir) do
 getstartdir:=dir;
end;

function directorcusles(dir: string): string;
begin
 if dir[length(dir)]<>'\' then
 if length(dir)>3 then dir:=dir+'\';
 directorcusles:=dir;
end;

begin
 writeln('MSoft Commander - 2000');
 writeln('Versiunea 1.0 - demo');
 startdir:=directorcusles(getstartdir);
 repeat
  iesire:=false;
  execstr:=startdir+mainfile;
  exec(getenv('COMSPEC'),'/C '+execstr);
  filemode:=2;
  assign(f,startdir+tmpfile);
  setfattr(f,0);
  reset(f,1);
  if rezultat<>0 then
  begin
   close(f);
   erase(f);
   halt;
  end;
  size:=filesize(f);
  if size<257 then
  begin
   close(f);
   erase(f);
   halt;
  end;
  blockread(f,comanda,1,citit);
  if comanda=cexec then
  begin
   if (lo(dosexitcode)=0) then
   begin
    blockread(f,execstr[0],256,citit);
    exec(getenv('COMSPEC'),'/C '+execstr);
   end;
  end else
  iesire:=true;
  close(f);
  erase(f);
 until iesire;
 writeln('MSoft Commander - 2000');
 writeln('La revedere!');
end.