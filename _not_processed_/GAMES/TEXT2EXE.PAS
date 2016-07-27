{$A+,B-,D+,E+,F+,G+,I-,L-,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,0}
program text2exe;
uses tpkey,mhstring,textgraf,dos,mhmem;
type exehdr=record
             semnat: array[1..2] of char;
             partpag: word;
             pagecnt: word;
             relocnt: word;
             hdrsize: word;
             minmem: word;
             maxmem: word;
             reloss: word;
             exesp: word;
             chksum: word;
             exeip: word;
             relocs: word;
             tableoff: word;
             overlay: word;
             dimexe: longint;
            end;
const bufmax=10000;
      ttab: byte=9;
      tins: byte=82;
      tesc: byte=27;
      tenter: byte=13;
      tdel=83;
      tf1: byte=59;
      tf2: byte=60;
      tf10: byte=68;
      tsus: byte=72;
      tjos: byte=80;
      tpgup: byte=73;
      tpgdn: byte=81;
      tstanga: byte=75;
      tdreapta: byte=77;
      thome: byte=71;
      tend: byte=79;
      tbsles: byte=92;
      tbkspace: byte=8;
      tctrla: byte=1;
      tctrln: byte=14;
      tctrlst: byte=115;
      tctrldr: byte=116;
      tctrlpgup: byte=119;
      tctrlpgdn: byte=117;
      maxlin=5000;
      spatecol: byte=0;
      fillcol: byte=8;
      scriscol: byte=14;
      copyright: string='MSoft - Mihai Marica - 2000 - Text autoafisabil';
var buf: array[1..bufmax] of char;
    ta,tb,tc: ^ecran80x25;
    texte: array[1..23] of array[1..80] of char;
    antet: exehdr;
    f1,f2: file;
    anuleaza,miscat,iesire: boolean;
    sizetot,sizeexe,sizetext,rezultat,fp,fpt: longint;
    ofsn,linn,pozn,mxpoz,mxlin,maxpoz,clinv,cpozv,clin,cpoz: longint;
    x,y,z,t,nrlin: longint;
    linii: array[1..maxlin] of record
                                offset,size: longint;
                               end;
    ofsetst,liniest,fisexe,numeexe,numeext: string;
    dir: dirstr;
    w: word;
    errinteger: integer;
    startline,offset: longint;
    name: namestr;
    ext: extstr;
    s1,s2,s3,s4: string;
    tasta: record
            citita,zero: boolean;
            cod: byte;
           end;

procedure citesctasta;
begin
 if tasta.citita then exit;
 tasta.zero:=false;
 if keypressed then
 begin
  tasta.cod:=ord(readkey);
  if tasta.cod=0 then
  begin
   tasta.cod:=ord(readkey);
   tasta.zero:=true;
  end;
  tasta.citita:=true;
 end;
end;

procedure elimintasta;
begin
 tasta.citita:=false;
end;

procedure repnokey;
begin
 while keypressed do readkey;
 elimintasta;
end;

procedure repkey;
begin
 while not keypressed do;
end;

procedure chdir(s: string);
begin
 system.chdir(s);
 rezultat:=ioresult;
end;

procedure getdir(d: byte;var s: string);
begin
 system.getdir(d,s);
 rezultat:=ioresult;
end;

procedure blockread(var f: file;var buf;count: word;var result: word);
begin
 system.blockread(f,buf,count,result);
 rezultat:=ioresult;
end;

procedure blockwrite(var f: file;var buf;count: word;var result: word);
begin
 system.blockwrite(f,buf,count,result);
 rezultat:=ioresult;
end;

procedure seek(var f: file;n: longint);
begin
 system.seek(f,n);
 rezultat:=ioresult;
end;

procedure reset(var f: file;recsize: word);
begin
 system.reset(f,recsize);
 rezultat:=ioresult;
end;

procedure rewrite(var f: file;recsize: word);
begin
 system.rewrite(f,recsize);
 rezultat:=ioresult;
end;

procedure close(var f: file);
begin
 system.close(f);
 rezultat:=ioresult;
end;

function filesize(var f: file): longint;
begin
 filesize:=system.filesize(f);
 rezultat:=ioresult;
end;

procedure erase(var f: file);
begin
 system.erase(f);
 rezultat:=ioresult;
end;

procedure nomem;
begin
 writeln('MSoft - Mihai Marica 2000 - TEXT2EXE');
 writeln('Nu e destula memorie! Acest program are nevoie dupa incarcare de 8K de memorie.');
 halt;
end;

procedure scanfile;
var bufpoz: integer;
    eoffile: boolean;
    fpoz: longint;
    ar: array[1..2] of char;

function readchar: char;
begin
 if bufpoz>bufmax then
 begin
  fillchar(buf,bufmax,0);
  blockread(f1,buf,bufmax,w);
  bufpoz:=1;
 end;
 readchar:=buf[bufpoz];
 bufpoz:=bufpoz+1;
 fpoz:=fpoz+1;
 if fpoz>sizetot then eoffile:=true;
 mxpoz:=linii[1].size;
end;

begin
 ar[1]:=#0;
 ar[2]:=#0;
 bufpoz:=sizeof(buf)+1;
 nrlin:=1;
 linii[1].offset:=sizeexe;
 linii[1].size:=0;
 seek(f1,sizeexe);
 eoffile:=false;
 fpoz:=sizeexe;
 repeat
  ar[1]:=ar[2];
  ar[2]:=readchar;
  linii[nrlin].size:=linii[nrlin].size+1;
  if(ar[1]=#13)and(ar[2]=#10) then
  begin
   linii[nrlin].size:=linii[nrlin].size-2;
   if nrlin>=maxlin then
   begin
    str(maxlin,s1);
    writeln('Prea multe linii de text (mai mult de '+s1+'). Ce e in plus se ignora!');
    writeln('Apasa o tasta...');
    repnokey;
    elimintasta;
    nrlin:=maxlin;
    break;
   end;
   nrlin:=nrlin+1;
   linii[nrlin].offset:=fpoz;
   linii[nrlin].size:=0;
   ar[1]:=#0;
   ar[2]:=#0;
  end;
 until eoffile;
 for x:=2 to nrlin do
 if mxpoz<linii[x].size then mxpoz:=linii[x].size;
end;

procedure rescan;
var flin,poz,maxim: longint;
begin
 for x:=1 to 23 do
 begin
  flin:=clin+x-1;
  if flin<=maxlin then
  begin
   maxim:=linii[flin].size-cpoz+1;
   if maxim>80 then maxim:=80;
   if maxim<0 then maxim:=0;
   poz:=linii[flin].offset+cpoz-1;
   if poz<sizeexe-1 then poz:=sizeexe-1;
   seek(f1,poz);
   fillchar(texte[x],80,32);
   blockread(f1,texte[x],maxim,w);
  end else
  fillchar(texte[x],80,32);
 end;
end;

procedure informezstatus(fis,sup: string;procent: byte);
var cat,x: integer;
    s: string;
begin
 setcharcolor(scriscol);
 setbaccolor(spatecol);
 setchar(' ');
 bara80x25(tb,1,1,80,25);
 setcharcolor(scriscol);
 setbaccolor(fillcol);
 ferg80x25(tb,3,2,78,5,'Informatii');
 writestring80x25(tb,1,3,'Acest program a fost creat de',false,false,true);
 writestring80x25(tb,1,4,'Mihai Marica in anul 2000',false,false,true);
 ferg80x25(tb,3,8,78,10,'Stare');
 writestring80x25(tb,1,9,sup,false,false,true);
 ferg80x25(tb,3,13,78,17,'Extragere fisier '+fis);
 s:=nrtost0(procent,3)+'%';
 writestring80x25(tb,1,16,s,false,false,true);
 s:='';
 for x:=1 to 50 do
 s:=s+#176;
 cat:=procent*50 div 100;
 for x:=1 to 50 do
 if x<=cat then
 s[x]:=#177;
 writestring80x25(tb,1,15,s,false,false,true);
 ferg80x25(tb,3,20,78,23,'Sfat de la Mihai');
 writestring80x25(tb,1,21,'Daca dureaza prea mult pot sa-ti sugerez alt '+
 'calculator?',false,false,true);
 writestring80x25(tb,1,22,'Zambeste! Ce daca ai o rabla?',false,false,true);
 ta^:=tb^;
end;

procedure extragefisier;
var maxim,procent,start,size,facut: longint;
    iesire: boolean;

procedure atentiespatiu(s: string);
begin
    repnokey;
    informezstatus(s,'Nu e destul spatiu pe disc! Apasa o tasta.',procent);
    repnokey;
    repkey;
    repnokey;
    elimintasta;
    filemode:=0;
    close(f2);
    erase(f2);
end;

begin
 start:=offset;
 if start<sizeexe then start:=sizeexe;
 size:=sizetot-offset;
 if size<1 then exit;
 facut:=0;
 iesire:=false;
 procent:=0;
 informezstatus(numeext,'- creez fisierul',procent);
 seek(f1,offset);
 filemode:=0;
 assign(f2,numeext);
 reset(f2,1);
 if rezultat=0 then
 begin
  informezstatus(numeext,'- fisierul exista. Suprascriu? (d/n)',procent);
  repeat
   elimintasta;
   citesctasta;
  until(tasta.citita)and(not tasta.zero)and((tasta.cod=ord('n'))or(tasta.cod=ord('N'))or
  (tasta.cod=ord('d'))or(tasta.cod=ord('D')));
  if(tasta.cod=ord('n'))or(tasta.cod=ord('N')) then
  begin
   elimintasta;
   repnokey;
   filemode:=0;
   exit;
  end;
 end;
 filemode:=2;
 assign(f2,numeext);
 rewrite(f2,1);
 if rezultat<>0 then
 begin
  informezstatus(numeext,'- nu pot crea fisierul! Apasa o tasta.',procent);
  repnokey;
  repkey;
  repnokey;
  elimintasta;
  filemode:=0;
  exit;
 end;
 repeat
  maxim:=size-facut;
  if maxim>bufmax then maxim:=bufmax;
  if maxim<0 then maxim:=0;
  blockread(f1,buf,maxim,w);
  blockwrite(f2,buf,maxim,w);
  if w<maxim then
  begin
   atentiespatiu(numeext);
   exit;
  end;
  facut:=facut+maxim;
  procent:=facut*100 div size;
  informezstatus(numeext,'-  scriu fisierul',procent);
  if facut>=size then
  begin
   close(f2);
   iesire:=true;
  end;
  elimintasta;
  citesctasta;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   close(f2);
   erase(f2);
   iesire:=true;
  end;
 until iesire;
 repnokey;
 elimintasta;
end;

procedure citescnume;
var vechi: string;
    poznv: integer;
    iesire: boolean;
begin
 cursor(true);
 anuleaza:=false;
 poznv:=pozn;
 vechi:=numeext;
 iesire:=false;
 anuleaza:=false;
 repeat
  elimintasta;
  citesctasta;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   pozn:=poznv;
   numeext:=vechi;
   anuleaza:=true;
   iesire:=true;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tstanga) then
  begin
   pozn:=pozn-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdreapta) then
  begin
   pozn:=pozn+1;
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tbkspace) then
  begin
   eliminlitera(numeext,pozn-1);
   pozn:=pozn-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdel) then
  begin
   eliminlitera(numeext,pozn);
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tenter) then
  iesire:=true;
  if(tasta.citita)and(not tasta.zero)and(not iesire) then
  begin
   inserezlitera(numeext,chr(tasta.cod),pozn);
   pozn:=pozn+1;
   elimintasta;
  end;
  if ord(numeext[0])>64 then numeext[0]:=#64;
  if pozn<1 then pozn:=1;
  if pozn>length(numeext)+1 then pozn:=length(numeext)+1;
  setbaccolor(fillcol);
  setcharcolor(scriscol);
  setchar(' ');
  ferg80x25(tb,2,11,79,13,'Da-mi numele pentru fisierul de iesire:');
  numeext:=upstring(numeext);
  s1:=numeext;
  setbaccolor(spatecol);
  for x:=length(s1)+1 to 64 do
  s1:=s1+#249;
  writestring80x25(tb,7,12,s1,false,false,false);
  gotoxy(6+pozn,12);
  ta^:=tb^;
 until iesire;
 cursor(false);
end;

procedure citesclinie;
var vechi: string;
    linnv: integer;
    iesire: boolean;
begin
 str(nrlin,s2);
 cursor(true);
 anuleaza:=false;
 linnv:=linn;
 vechi:=liniest;
 iesire:=false;
 anuleaza:=false;
 repeat
  elimintasta;
  citesctasta;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   linn:=linnv;
   liniest:=vechi;
   anuleaza:=true;
   iesire:=true;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tstanga) then
  begin
   linn:=linn-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdreapta) then
  begin
   linn:=linn+1;
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tbkspace) then
  begin
   eliminlitera(liniest,linn-1);
   linn:=linn-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdel) then
  begin
   eliminlitera(liniest,linn);
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tenter) then
  iesire:=true;
  if(tasta.citita)and(not tasta.zero)and(not iesire) then
  begin
   inserezlitera(liniest,chr(tasta.cod),linn);
   linn:=linn+1;
   elimintasta;
  end;
  if ord(liniest[0])>64 then liniest[0]:=#64;
  if linn<1 then linn:=1;
  if linn>length(liniest)+1 then linn:=length(liniest)+1;
  setbaccolor(fillcol);
  setcharcolor(scriscol);
  setchar(' ');
  ferg80x25(tb,2,11,79,13,'Da-mi linia cu care voi incepe sa salvez (intre 1 si '+s2+'):');
  liniest:=upstring(liniest);
  s1:=liniest;
  setbaccolor(spatecol);
  for x:=length(s1)+1 to 64 do
  s1:=s1+#249;
  writestring80x25(tb,7,12,s1,false,false,false);
  gotoxy(6+linn,12);
  ta^:=tb^;
 until iesire;
 cursor(false);
 val(liniest,startline,errinteger);
end;

procedure citescoffset;
var vechi: string;
    ofsnv: integer;
    iesire: boolean;
begin
 str(sizetext,s2);
 cursor(true);
 anuleaza:=false;
 ofsnv:=ofsn;
 vechi:=ofsetst;
 iesire:=false;
 anuleaza:=false;
 repeat
  elimintasta;
  citesctasta;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then
  begin
   ofsn:=ofsnv;
   ofsetst:=vechi;
   anuleaza:=true;
   iesire:=true;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tstanga) then
  begin
   ofsn:=ofsn-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdreapta) then
  begin
   ofsn:=ofsn+1;
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tbkspace) then
  begin
   eliminlitera(ofsetst,ofsn-1);
   ofsn:=ofsn-1;
   elimintasta;
  end;
  if(tasta.citita)and(tasta.zero)and(tasta.cod=tdel) then
  begin
   eliminlitera(ofsetst,ofsn);
   elimintasta;
  end;
  if(tasta.citita)and(not tasta.zero)and(tasta.cod=tenter) then
  iesire:=true;
  if(tasta.citita)and(not tasta.zero)and(not iesire) then
  begin
   inserezlitera(ofsetst,chr(tasta.cod),ofsn);
   ofsn:=ofsn+1;
   elimintasta;
  end;
  if ord(ofsetst[0])>64 then ofsetst[0]:=#64;
  if ofsn<1 then ofsn:=1;
  if ofsn>length(ofsetst)+1 then ofsn:=length(ofsetst)+1;
  setbaccolor(fillcol);
  setcharcolor(scriscol);
  setchar(' ');
  ferg80x25(tb,2,11,79,13,'Da-mi deplasare cu care voi incepe sa salvez (intre 1 si '+s2+'):');
  ofsetst:=upstring(ofsetst);
  s1:=ofsetst;
  setbaccolor(spatecol);
  for x:=length(s1)+1 to 64 do
  s1:=s1+#249;
  writestring80x25(tb,7,12,s1,false,false,false);
  gotoxy(6+ofsn,12);
  ta^:=tb^;
 until iesire;
 cursor(false);
 val(ofsetst,offset,errinteger);
end;

begin
 writeln('MSoft - Mihai Marica - 2000 - TEXT2EXE');
 writeln('Telefon 044/271667');
 fp:=0;
 clin:=1;
 cpoz:=1;
 numeexe:=upstring(paramstr(0));
 fisexe:=numeexe;
 fsplit(numeexe,dir,name,ext);
 numeexe:=upstring(name+ext);
 filemode:=0;
 assign(f1,fisexe);
 reset(f1,1);
 if rezultat<>0 then
 begin
  writeln('MSoft - Mihai Marica 2000 - TEXT2EXE');
  writeln('Nu pot deschide fisierul ''',numeexe,'''!');
  halt;
 end;
 sizetot:=filesize(f1);
 blockread(f1,antet,sizeof(antet),w);
 sizeexe:=(antet.pagecnt-1)*512+antet.partpag;
 sizetext:=sizetot-sizeexe;
 if sizetext<0 then
 begin
  writeln('MSoft - Mihai Marica 2000 - TEXT2EXE');
  writeln('Executabilul ''',numeexe,''' a fost corupt!');
  halt;
 end;
 if sizetext=0 then
 begin
  writeln('MSoft - Mihai Marica 2000 - TEXT2EXE');
  writeln('In fisierul ''',numeexe,''' nu e nici un text de afisat!');
  halt;
 end;
 writeln('Procesez textul...');
 scanfile;
 mxlin:=nrlin-22;
 if mxlin<1 then mxlin:=1;
 maxpoz:=linii[1].size-79;
 for x:=2 to nrlin do
 if maxpoz<linii[x].size-79 then maxpoz:=linii[x].size-79;
 if maxpoz<1 then maxpoz:=1;
 repnokey;
 ta:=ptr($B800,0);
 tb:=ptr(mhmemaloc(sizeof(tb^)),0);
 if eraloc<>eranimic then nomem;
 tc:=ptr(mhmemaloc(sizeof(tc^)),0);
 if eraloc<>eranimic then nomem;
 setchar(#32);
 setbaccolor(spatecol);
 setcharcolor(scriscol);
 bara80x25(tc,1,1,80,25);
 writestring80x25(tc,1,1,copyright+' in fisierul '+numeexe,false,false,true);
 setbaccolor(fillcol);
 setcharcolor(scriscol);
 bara80x25(tc,1,2,80,24);
 rescan;
 inittext80x25;
 cursor(false);
 clipire(false);
 repeat
  tb^:=tc^;
  miscat:=false;
  if clin<1 then clin:=1;
  if clin>mxlin then clin:=mxlin;
  if cpoz<1 then cpoz:=1;
  if cpoz>maxpoz then cpoz:=maxpoz;
  setchar(#32);
  setbaccolor(spatecol);
  setcharcolor(scriscol);
  str(clin,s2);
  str(nrlin,s3);
  s1:='Linia: '+s2+'/'+s3;
  for x:=length(s1)+1 to 20 do
  s1:=s1+' ';
  str(cpoz,s2);
  str(mxpoz,s3);
  s1:=s1+'Coloana: '+s2+'/'+s3;
  for x:=length(s1)+1 to 20 do
  s1:=s1+' ';
  writestring80x25(tb,2,25,s1,false,false,false);
  if(cpoz<>cpozv)or(clin<>clinv) then rescan;
  for x:=1 to 23 do
  begin
   s1[0]:=#80;
   move(texte[x],s1[1],80);
   setbaccolor(fillcol);
   setcharcolor(scriscol);
   writestring80x25(tb,1,1+x,s1,false,false,false);
  end;
  repeat
   elimintasta;
   citesctasta;
   if(tasta.citita)and(not tasta.zero)and(tasta.cod=tesc) then iesire:=true;
   if(tasta.citita)and(not tasta.zero)and(upcase(chr(tasta.cod))='E') then
   begin
    repnokey;
    elimintasta;
    citescnume;
    repnokey;
    elimintasta;
    if not anuleaza then
    begin
     offset:=linii[1].offset;
     extragefisier;
    end;
   end;
   if(tasta.citita)and(not tasta.zero)and(upcase(chr(tasta.cod))='L') then
   begin
    repnokey;
    elimintasta;
    citescnume;
    repnokey;
    elimintasta;
    if not anuleaza then
    begin
     repnokey;
     elimintasta;
     citesclinie;
     repnokey;
     elimintasta;
    end;
    if not anuleaza then
    if startline>0 then
    if startline<=nrlin then
    begin
     offset:=linii[startline].offset;
     extragefisier;
    end;
   end;
   if(tasta.citita)and(not tasta.zero)and(upcase(chr(tasta.cod))='D') then
   begin
    repnokey;
    elimintasta;
    citescnume;
    repnokey;
    elimintasta;
    if not anuleaza then
    begin
     repnokey;
     elimintasta;
     citescoffset;
     repnokey;
     elimintasta;
    end;
    if not anuleaza then
    if offset>0 then
    if offset<=sizetext then
    begin
     offset:=offset+sizeexe-1;
     extragefisier;
    end;
   end;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tsus) then clin:=clin-1;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tjos) then clin:=clin+1;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tpgup) then clin:=clin-23;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tpgdn) then clin:=clin+23;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tstanga) then cpoz:=cpoz-1;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tdreapta) then cpoz:=cpoz+1;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tctrlst) then cpoz:=cpoz-80;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tctrldr) then cpoz:=cpoz+80;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tctrlpgup) then
   begin
    clin:=1;
    cpoz:=1;
   end;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tctrlpgdn) then
   begin
    clin:=maxlin;
    cpoz:=maxpoz;
   end;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=thome) then cpoz:=1;
   if(tasta.citita)and(tasta.zero)and(tasta.cod=tend) then cpoz:=maxpoz;
  until(not tasta.citita)or iesire;
  ta^:=tb^;
  clinv:=clin;
  cpozv:=cpoz;
 until iesire;
 close(f1);
 repnokey;
 inittext80x25;
 cursor(true);
 clipire(true);
 mhmemdealoc(seg(tb^));
 mhmemdealoc(seg(tc^));
 writeln('MSoft - Mihai Marica - 2000 - TEXT2EXE');
 writeln('Telefon 044/271667');
end.