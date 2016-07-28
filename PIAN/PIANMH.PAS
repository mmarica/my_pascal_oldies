program pianmh;
uses crt,mtast,mhpal,mhimg,mhmem;
var f: file;
    numef: string;
    nnote,nparams: integer;
    size: longint;
    params: array[1..100] of string;
    gasita,fselect,recordorplay: boolean;
    nota,x,y,z,t: integer;
    sunet,w,w1,w2: word;
    buf: array[1..1000] of char;
    note1: array[1..26] of record
                            tasta: byte;
                            nota: word;
                           end;
    terminat,gata: boolean;
    ctm,ct1: integer;
    p1c: pointer;

procedure inittast;
begin
 nnote:=26;
 note1[1].tasta:=tsq;
 note1[2].tasta:=tsw;
 note1[3].tasta:=tse;
 note1[4].tasta:=tsr;
 note1[5].tasta:=tst;
 note1[6].tasta:=tsy;
 note1[7].tasta:=tsu;
 note1[8].tasta:=tsi;
 note1[9].tasta:=tso;
 note1[10].tasta:=tsp;
 note1[11].tasta:=tsa;
 note1[12].tasta:=tss;
 note1[13].tasta:=tsd;
 note1[14].tasta:=tsf;
 note1[15].tasta:=tsg;
 note1[16].tasta:=tsh;
 note1[17].tasta:=tsj;
 note1[18].tasta:=tsk;
 note1[19].tasta:=tsl;
 note1[20].tasta:=tsz;
 note1[21].tasta:=tsx;
 note1[22].tasta:=tsc;
 note1[23].tasta:=tsv;
 note1[24].tasta:=tsb;
 note1[25].tasta:=tsn;
 note1[26].tasta:=tsm;
 for x:=1 to nnote do
 note1[x].nota:=100+40*x;
end;

procedure checkparams;
begin
 nparams:=paramcount;
 for x:=1 to nparams do
 params[x]:=paramstr(x);
 for x:=1 to nparams do
 begin
  if (params[x]='/r')or(params[x]='/R') then recordorplay:=false else
  if (params[x]='/p')or(params[x]='/P') then recordorplay:=true else
  begin
   if not fselect then
   begin
    numef:=params[x];
    fselect:=true;
   end;
  end;
 end;
end;

begin
 size:=0;
 nosound;
 closegr;
 fselect:=false;
 recordorplay:=false;
 checkparams;
 if not fselect then
 begin
  writeln('MSoft - Simulatorul de pian v1.0 ');
  writeln('Sintaxa PIANMH [/R|/r|/P|/p] <numef>');
  writeln('Exemplu PIANMH /R test.pin');
  writeln('   numef=numele fisierului din care sa cante sau in care sa inregistreze');
  writeln('   /r|/R=inregistrare');
  writeln('   /p|/P=reproducere');
  halt;
 end;
 if not recordorplay then
 begin
  {$I-}
  assign(f,numef);
  rewrite(f,1);
  if ioresult<>0 then
  begin
   writeln('Eroare la crearea fisierului ''',numef,'''!');
   halt;
  end;
  buf[1]:='M';buf[2]:='S';buf[3]:='P';buf[4]:='N';
  blockwrite(f,buf,4,w);
  if (ioresult<>0)or(w<4) then
  begin
   writeln('Eroare la scriere in fisierul ''',numef,'''!');
   writeln('Probabil ca nu e destul spatiu pe disc.');
   halt;
  end;
  {$I+}
 end else
 begin
  {$I-}
  assign(f,numef);
  reset(f,1);
  size:=filesize(f);
  if ioresult<>0 then
  begin
   writeln('Eroare la deschiderea fisierului ''',numef,'''!');
   halt;
  end;
  blockread(f,buf,4,w);
  if (buf[1]<>'M')or(buf[2]<>'S')or(buf[3]<>'P')or(buf[4]<>'N')or(w<4) then
  begin
   writeln('''',numef,''' nu este un fisier de pian MSoft!');
   halt;
  end;
  writeln('Marimea fisierului: ',size);
  size:=trunc((size-4)/2);
  writeln('Secunde: ',size/18:0:2);
  {$I+}
 end;
 inittast;
 initscankey;
 repeat
  nota:=0;
  terminat:=false;
  sunet:=0;
  gasita:=false;
  if not recordorplay then
  begin
   if not gasita then
   for x:=1 to nnote do
   if key[note1[x].tasta] then
   begin
    sunet:=note1[x].nota;
    gasita:=true;
    nota:=x;
   end;
  end else
  begin
   blockread(f,sunet,2,w);
   if w<2 then terminat:=true;
   if (sunet>0)and(sunet<=nnote) then
   begin
    gasita:=true;
    sunet:=note1[sunet].nota;
   end;
  end;
  if gasita then
  begin
   sound(sunet);
   if not recordorplay then
   begin
    w1:=nota;
    blockwrite(f,w1,2,w);
    if w<2 then terminat:=true;
   end;
  end else
  begin
   nosound;
   if not recordorplay then
   begin
    w1:=0;
    blockwrite(f,w1,2,w);
    if w<2 then terminat:=true;
   end;
  end;
  delay(55);
  size:=size+1;
 until key[tsesc]or terminat;
 if terminat then
 begin
  if recordorplay then writeln('Fisierul pe care l-am interpretat s-a terminat!') else
  begin
   writeln('Nu mai e spatiu pe disc! Oprim inregistrarea.');
   writeln('Secunde inregistrate: ',size/18:0:2);
   writeln('Marimea fisierului: ',size*2+4);
  end;
 end;
 if not terminat then
 begin
  if recordorplay then
  begin
   writeln('Oprim interpretarea!')
  end else
  begin
   writeln('Oprim inregistrarea.');
   writeln('Secunde inregistrate: ',size/18:0:2);
   writeln('Marimea fisierului: ',size*2+4);
  end;
 end;
 disabscankey;
 close(f);
 nosound;
end.