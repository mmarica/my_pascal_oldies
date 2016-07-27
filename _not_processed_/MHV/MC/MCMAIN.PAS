{$A+,B-,D+,E+,F+,G+,I-,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
{$M 16384,0,0}
program MSoft_Commander_modulul_principal;
uses mhdos,dos,mhmem,mhstring,textgraf,tpkey;
const maxfiles=2965; {maxim 2965}
      anistr: string[78]='MSoft Commander 1.0';
      char1: char=#204;
      char2: char=#205;
      char3: char=#185;
      ttab: byte=9;
      tins: byte=82;
      tesc: byte=27;
      tenter: byte=13;
      tdel=83;
      tf1: byte=59;
      tf2: byte=60;
      tf7: byte=65;
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
      tctrlbkspace: byte=127;
      tctrlenter: byte=10;
      tctrla: byte=1;
      tctrln: byte=14;
      tctrlo: byte=15;
      tctrlsls: byte=28;
      tstel: byte=42;
      spatecol: byte=11;
      speccol: byte=3;
      selectcol: byte=14;
      fillcol: byte=1;
      scriscol: byte=11;
      inifile: string='MC.INI';
      tempfile: string='MC.TMP';
      selectfile: string='MC.RLD';
      cexec: byte=22;
      ciesi: byte=23;
      baradefunctii: array[1..10] of string[6]=('Ajutor','FacFis','Vizu..',
                                  'Edit..','Copiat','Mutat ','FacDir','Sters ',
                                  'Reboot','Iesire');
      alturi: array[1..26] of byte=(30,48,46,32,18,33,34,35,23,36,37,38,50,49,
              24,15,16,19,31,20,22,47,17,45,21,44);
type finfo=record
            nume: string[8];
            ext: string[3];
            timp,marime: longint;
            attr: byte;
           end;
     selinfo=record
              nume: string[8];
              ext: string[3];
              attr: byte;
             end;
     panou=record
            fil: array[1..maxfiles] of finfo;
            nrfiles,nrdirs: integer;
            vizibil,tomany,dir2p: boolean;
            cdir: string;
            nrsel,dev,dpv,de,dp: integer;
            disklib,disktot,sizesel: longint;
           end;
     panouscris=array[1..21] of string[36];
     selectpan=array[1..maxfiles] of boolean;
     cautare=record
              nume: string[8];
              extensie: string[3];
              attr: byte;
              da: boolean;
             end;
     bufferpentrucopiere=array[1..64000] of char;
     attrtype=record
               l: char;
               nr: byte;
              end;
var panouri: array[1..2] of ^panou;
    anix,anidir: integer;
    dirs: array[1..100] of string;
    tempsel: selinfo;
    startdir: string;
    atr: array[1..4] of attrtype;
    scrispan: array[1..2] of ^panouscris;
    copybuf: ^bufferpentrucopiere;
    selectat: array[1..2] of selectpan;
    sortare: (ascendenta,descendenta);
    panfs,panos,panvs,pansx,pansy: integer;
    curentdir: string;
    cpan: byte;
    ta,tb,tc,td: ^ecran80x25;
    nom: boolean;
    xt,vcx,vcy: integer;
    old1c,oldexit: pointer;
    x,y,z,t: longint;
    mono,iesire: boolean;
    dir: dirstr;
    name: namestr;
    ext: extstr;
    cauta: cautare;
    cautari: array[1..2] of cautare;
    scris,maxsort,sortcnt,rezultat,contor: word;
    procsort: procedure(pan,start,stop: integer);
    sortptr: array[1..5] of pointer;
    comline: string[79];
    scrmax,scrcnt,anicnt: longint;
    tasta: record
            citita,zero: boolean;
            cod: byte;
           end;

function eselectat(pan: byte;poz: integer): boolean;
var bit: byte;
    b: ^byte;
    byt: integer;
begin
 eselectat:=false;
 with panouri[pan]^ do
 if(pan<1)or(pan>2)or(poz<1)or(poz>nrdirs+nrfiles) then exit;
 eselectat:=selectat[pan][poz];
end;

procedure selecteaza(pan: byte;poz: integer;da: boolean);
begin
 with panouri[pan]^ do
 if(pan<1)or(pan>2)or(poz<1)or(poz>nrdirs+nrfiles) then exit;
 if da then
 begin
  if(panouri[pan]^.fil[poz].nume='..') then exit;
  selectat[pan][poz]:=true;
 end else
 selectat[pan][poz]:=false;
end;

procedure golescsel(pan: byte);
var x: integer;
begin
 if(pan<1)or(pan>2) then exit;
 with panouri[pan]^ do
 begin
  for x:=1 to nrdirs+nrfiles do
  selecteaza(pan,x,false);
  sizesel:=0;
  nrsel:=0;
 end;
end;

function getm: byte;
var r: registers;
begin
 r.ah:=$0f;
 intr($10,r);
 getm:=r.al;
end;

procedure treci80x25;
var r: registers;
begin
end;

procedure treci80x50;
var r: registers;
begin
  r.ax:=$1202;
  r.bl:=$30;
  intr($10,r);
  r.ax:=$1112;
  r.bl:=0;
  intr($10,r);
end;

function duteindirector(nrdirs: integer): boolean;
var x: integer;
begin
 duteindirector:=true;
 for x:=1 to nrdirs do
 begin
  chdir(dirs[x]);
  if rezultat<>0 then
  begin
   duteindirector:=false;
   exit;
  end;
 end;
end;

procedure animatie(p: pointer);
var te: ^ecran80x25;
    s1,s2: string;
begin
 s1:=nrtost0(trunc(scrcnt/18/60),2);
 s2:=nrtost0(trunc(scrcnt/18),2);
 s1:=s1+':'+s2;
 s1:=anistr+'  '+s1;
 if anicnt>1 then
 begin
  anicnt:=0;
  if anidir=0 then anix:=anix-1 else
  anix:=anix+1;
  if anix<1 then
  begin
   anidir:=1;
   anix:=2;
  end;
  if anix>40-length(s1) then
  begin
   anidir:=0;
   anix:=40-length(s1)-1;
  end;
 end;
 te:=p;
 setchar(' ');
 setcharcolor(scriscol);
 setbaccolor(0);
 bara80x25(te,1,1,80,1);
 setcharcolor(scriscol);
 if panouri[1]^.tomany then
 setcharcolor(speccol);
 writestring80x25(te,anix,1,s1,false,false,false);
 setcharcolor(scriscol);
 if panouri[2]^.tomany then
 setcharcolor(speccol);
 writestring80x25(te,41+40-anix-length(s1),1,s1,false,false,false);
end;

function shift: boolean;
begin
 if (mem[0:$417] and 3)<>0 then shift:=true else
 shift:=false;
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

procedure quicksortext(pan,start,stop: integer);
procedure sort(pan,l,r: integer);
var i,j: integer;
    x,y: finfo;
begin
 with panouri[pan]^ do
 begin
  if sortare=ascendenta then
  begin
   i:=l;j:=r;x:=fil[(l+r) div 2];
   repeat
    while fil[i].ext<x.ext do i:=i+1;
    while x.ext<fil[j].ext do j:=j-1;
    if i<=j then
    begin
     if i<>j then
     begin
      y:=fil[i];fil[i]:=fil[j];fil[j]:=y;
     end;
     i:=i+1;j:=j-1;
    end;
   until i>j;
   if l<j then sort(pan,l,j);
   if i<r then sort(pan,i,r);
  end else
  if sortare=ascendenta then
  begin
   i:=l;j:=r;x:=fil[(l+r) div 2];
   repeat
    while fil[i].ext>x.ext do i:=i+1;
    while x.ext>fil[j].ext do j:=j-1;
    if i>=j then
    begin
     if i<>j then
     begin
      y:=fil[i];fil[i]:=fil[j];fil[j]:=y;
     end;
     i:=i+1;j:=j-1;
    end;
   until i<j;
   if l<j then sort(pan,l,j);
   if i<r then sort(pan,i,r);
  end;
 end;
end;
begin
 if(pan<1)or(pan>2) then exit;
 sort(pan,start,stop);
 sortcnt:=sortcnt+1;
 if sortcnt>maxsort then exit;
 @procsort:=sortptr[sortcnt];
 procsort(pan,start,stop);
 sortcnt:=sortcnt-1;
end;

procedure quicksortnume(pan,start,stop: integer);
procedure sort(pan,l,r: integer);
var i,j: integer;
    x,y: finfo;
begin
 with panouri[pan]^ do
 begin
  if sortare=ascendenta then
  begin
   i:=l;j:=r;x:=fil[(l+r) div 2];
   repeat
    while fil[i].nume<x.nume do i:=i+1;
    while x.nume<fil[j].nume do j:=j-1;
    if i<=j then
    begin
     y:=fil[i];fil[i]:=fil[j];fil[j]:=y;
     i:=i+1;j:=j-1;
    end;
   until i>j;
   if l<j then sort(pan,l,j);
   if i<r then sort(pan,i,r);
  end else
  if sortare=ascendenta then
  begin
   i:=l;j:=r;x:=fil[(l+r) div 2];
   repeat
    while fil[i].nume>x.nume do i:=i+1;
    while x.nume>fil[j].nume do j:=j-1;
    if i>=j then
    begin
     y:=fil[i];fil[i]:=fil[j];fil[j]:=y;
     i:=i+1;j:=j-1;
    end;
   until i<j;
   if l<j then sort(pan,l,j);
   if i<r then sort(pan,i,r);
  end;
 end;
end;
var strt,stp,st,nr: integer;
    curent: string;
begin
 if(pan<1)or(pan>2) then exit;
 sort(pan,start,stop);
 strt:=start;
 stp:=strt;
 st:=strt;
 nr:=1;
 with panouri[pan]^ do
 begin
  curent:=fil[strt].nume;
  if strt<stop then
  repeat
   strt:=strt+1;
   if upstring(fil[start].nume)=upstring(curent) then nr:=nr+1 else
   begin
    stp:=strt-1;
    st:=strt;
    if nr>1 then
    begin
     sortcnt:=sortcnt+1;
     if sortcnt>maxsort then exit;
     @procsort:=sortptr[sortcnt];
     procsort(pan,st,stp);
     sortcnt:=sortcnt-1;
    end;
    curent:=fil[strt].nume;
    nr:=1;
   end;
  until strt>=stop;
  if nr>1 then
  begin
   stp:=strt;
   sortcnt:=sortcnt+1;
   if sortcnt>maxsort then exit;
   @procsort:=sortptr[sortcnt];
   procsort(pan,st,stp);
   sortcnt:=sortcnt-1;
   curent:=fil[strt].nume;
   nr:=1;
  end;
 end;
end;

procedure quicksort(pan,start,stop: integer);
begin
 if(pan<1)or(pan>2) then exit;
 sortcnt:=1;
 @procsort:=sortptr[sortcnt];
 if sortcnt>maxsort then exit;
 procsort(pan,start,stop);
end;

procedure scriuliniadecomanda(p: pointer);
var te: ^ecran80x25;
begin
 te:=p;
 setbaccolor(spatecol);
 setcharcolor(scriscol);
 writestring80x25(te,1,24,comline,false,false,false);
end;

procedure verificpozitia;
var z,t: integer;
begin
 for z:=1 to 2 do
 for t:=1 to 2 do
 with panouri[t]^ do
 begin
  if dp>nrfiles+nrdirs-panfs then
  begin
   de:=de+dp-nrfiles-nrdirs+panfs;
   dp:=nrfiles+nrdirs-panfs;
  end;
  if de>panfs-1 then
  begin
   dp:=dp+de-panfs+1;
   de:=panfs-1;
  end;
  if de+dp>=nrfiles+nrdirs-1 then de:=nrfiles+nrdirs-1-dp;
  if de<0 then
  begin
   dp:=dp+de;
   de:=0;
  end;
  if dp<0 then
  begin
   de:=de+dp;
   dp:=0;
  end;
  if de+dp<0 then
  begin
   de:=0;
   dp:=0;
  end;
 end;
end;

procedure golescfer(p: pointer;x1,y1,x2,y2: integer);
var te: ^ecran80x25;
begin
 te:=p;
 setchar(' ');
 setcharcolor(scriscol);
 setbaccolor(0);
 bara80x25(te,x1,y1,x2,y2);
end;

procedure desenezpanou(p: pointer;pan: byte);
var te: ^ecran80x25;
    x: integer;
    s1: string;
begin
 te:=p;
 if(pan<1)or(pan>2) then exit;
 setbaccolor(fillcol);
 setcharcolor(scriscol);
 if pan=cpan then
 setcharcolor(speccol);
 s1:=panouri[pan]^.cdir;
 if length(s1)>38 then
 begin
  for x:=1 to 18 do
  s1[20+x]:=s1[length(s1)-18+x];
  s1[18]:='.';
  s1[19]:='.';
  s1[20]:='.';
  s1[0]:=#38;
 end;
 ferg80x25(te,pansx+(pan-1)*panos,pansy,(pan-1)*panos+pansx-1+panos,pansy+panvs+1,s1);
 s1:=char1;
 for x:=length(s1)+1 to panos-1 do
 s1:=s1+char2;
 s1:=s1+char3;
 for x:=1 to 2 do
 writestring80x25(te,1+(x-1)*panos,1+panvs,s1,false,false,false);
 for x:=1 to 10 do
 begin
  setcharcolor(speccol);
  setbaccolor(0);
  str(x:2,s1);
  writestring80x25(te,1+(x-1)*8,25,s1,false,false,false);
  setcharcolor(scriscol);
  setbaccolor(fillcol);
  writestring80x25(te,3+(x-1)*8,25,baradefunctii[x],false,false,false);
 end;
end;

procedure calculezpanou(pan: byte);
var x: integer;
    s1,s2,s3,s4: string[38];
begin
 fillchar(scrispan[pan]^,sizeof(scrispan[pan]^),0);
 if(pan<1)or(pan>2) then exit;
 with panouri[pan]^ do
 if nrdirs+nrfiles>0 then
 for z:=1 to panfs do
 if (z+dp<=nrdirs+nrfiles)and(z+dp>=1) then
 begin
  s1:=fil[dp+z].nume;
  s2:=fil[dp+z].ext;
  for t:=length(s1)+1 to 8 do s1:=s1+' ';
  for t:=length(s2)+1 to 3 do s2:=s2+' ';
  s1:=s1+' '+s2;
  str(fil[z+dp].marime:10,s2);
  if(fil[z+dp].attr and directory)<>0 then s2:='  DIRECTOR';
  s1:=s1+' '+s2;
  if (fil[z+dp].attr and directory)<>0 then s1:=upstring(s1) else s1:=downstring(s1);
  s2:='';
  for t:=1 to 4 do
  if(fil[z+dp].attr and atr[t].nr)<>0 then s2:=s2+atr[t].l else s2:=s2+'-';
  s1:=s1+' '+s2;
  for t:=length(s1)+1 to 36 do
  s1:=s1+' ';
  scrispan[pan]^[z]:=s1;
 end;
end;

procedure scriupanou(p: pointer;pan: byte);
var te: ^ecran80x25;
    x,z,start: integer;
    s1,s2,s3,s4: string;
begin
 te:=p;
 if(pan<1)or(pan>2) then exit;
 setchar(' ');
 setbaccolor(fillcol);
 setcharcolor(scriscol);
 if pan=cpan then
 setcharcolor(speccol);
 start:=3+(pan-1)*panos;
 with panouri[pan]^ do
 if nrdirs+nrfiles>0 then
 for z:=1 to panfs do
 if (z+dp<=nrdirs+nrfiles)and(z+dp>=1) then
 begin
  setbaccolor(fillcol);
  setcharcolor(scriscol);
  if z=de+1 then
  if pan=cpan then
  begin
   setbaccolor(spatecol);
   setcharcolor(fillcol);
  end;
  if selectat[pan][z+dp] then
  setcharcolor(selectcol);
  writestring80x25(te,start,z+pansy,scrispan[pan]^[z],false,false,false);
 end;
 setbaccolor(fillcol);
 setcharcolor(scriscol);
 with panouri[pan]^ do
 if nrfiles+nrdirs>0 then
 begin
  if nrsel>0 then
  begin
   s1:='Selectate: ';
   str(nrsel,s2);
   s1:=s1+s2+' fisiere, ';
   str(sizesel,s2);
   s1:=s1+s2;
   writestring80x25(te,3+(pan-1)*panos,pansy+panfs+2,s1,false,false,false);
  end else
  begin
   writestring80x25(te,3+(pan-1)*panos,pansy+panfs+2,scrispan[pan]^[de+1],false,false,false);
  end;
 end;
end;

procedure scanezspate;
begin
 td^:=ta^;
 vcx:=wherex80x25;
 vcy:=wherey80x25;
end;

procedure scriuspate;
begin
 ta^:=td^;
 cursorto80x25(vcx,vcy);
end;

procedure repkey;
begin
 while not keypressed do;
end;

procedure repnokey;
begin
 while keypressed do readkey;
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

procedure elibmem;
begin
 mhmemdealoc(seg(tb^));
 mhmemdealoc(seg(tc^));
 mhmemdealoc(seg(td^));
 mhmemdealoc(seg(panouri[1]^));
 mhmemdealoc(seg(panouri[2]^));
 mhmemdealoc(seg(scrispan[1]^));
 mhmemdealoc(seg(scrispan[2]^));
 mhmemdealoc(seg(copybuf^));
 ta:=nil;
 tb:=nil;
 tc:=nil;
 panouri[1]:=nil;
 panouri[2]:=nil;
 scrispan[1]:=nil;
 scrispan[2]:=nil;
 copybuf:=nil;
 setintvec($1c,old1c);
end;

procedure scandir(pan: byte;dir: string);
var swap: finfo;
    sr: searchrec;
    vdir: string;
    dirn: dirstr;
    namen: namestr;
    extn: extstr;
    ppan,x: integer;
    minidir: string[3];
begin
 ppan:=0;
 if(pan<1)or(pan>2) then exit;
 with panouri[pan]^ do
 begin
  imparteindirectoare(cdir,dirs,xt);
  if not duteindirector(xt) then exit;
  if dir<>'' then
  begin
   chdir(dir);
  end;
  getdir(0,cdir);
  vdir:=cdir;
  fillchar(panouri[pan]^,sizeof(panouri[pan]^),0);
  cdir:=vdir;
  if length(cdir)>3 then
  if cdir[length(cdir)]='\' then cdir[0]:=chr(ord(cdir[0])-1);
  cdir:=upstring(cdir);
  dir2p:=false;
  tomany:=false;
  nrfiles:=0;
  nrdirs:=0;
  de:=0;
  dp:=0;
  findfirst('*.*',$3F-volumeid,sr);
  while (doserror=0) do
  begin
   if (sr.name<>'.')and((sr.attr and directory)<>0) then
   begin
    ppan:=ppan+1;
    if ppan>maxfiles then
    begin
     tomany:=true;
     ppan:=ppan-1;
     break;
    end;
    nrdirs:=nrdirs+1;
    extn:='';
    if sr.name='..' then
    begin
     fil[ppan].nume:='..';
     dir2p:=true;
    end else
    begin
     fsplit(sr.name,dirn,namen,extn);
     fil[ppan].nume:=upstring(namen);
     if extn[1]='.' then
     begin
      for x:=1 to 3 do
      extn[x]:=extn[x+1];
      extn[0]:=chr(ord(extn[0])-1);
     end;
     fil[ppan].ext:=upstring(extn);
    end;
    fil[ppan].attr:=sr.attr;
    fil[ppan].marime:=sr.size;
    fil[ppan].timp:=sr.time;
   end;
   findnext(sr);
  end;
  findfirst('*.*',$3F-directory-volumeid,sr);
  while (doserror=0) do
  begin
   if (sr.name<>'.')and((sr.attr and directory)=0) then
   begin
    ppan:=ppan+1;
    if ppan>maxfiles then
    begin
     tomany:=true;
     ppan:=ppan-1;
     break;
    end;
    nrfiles:=nrfiles+1;
    extn:='';
    fsplit(sr.name,dirn,namen,extn);
    fil[ppan].nume:=upstring(namen);
    if extn[1]='.' then
    begin
     for x:=1 to 3 do
     extn[x]:=extn[x+1];
     extn[0]:=chr(ord(extn[0])-1);
    end;
    fil[ppan].ext:=upstring(extn);
    fil[ppan].attr:=sr.attr;
    fil[ppan].marime:=sr.size;
    fil[ppan].timp:=sr.time;
   end;
   fil[ppan].nume:=upstring(fil[ppan].nume);
   fil[ppan].ext:=upstring(fil[ppan].ext);
   findnext(sr);
  end;
  if nrdirs>1 then
  begin
   if dir2p then quicksort(pan,2,nrdirs) else
   quicksort(pan,1,nrdirs);
  end;
  if nrfiles>1 then
  quicksort(pan,nrdirs+1,nrdirs+nrfiles);
 end;
 panouri[pan]^.disklib:=diskfree(0);
 panouri[pan]^.disktot:=disksize(0);
 golescsel(pan);
end;

procedure loadrld;
const semnat: array[1..51] of char='MSoft - Fisier temporar facut de MSoft Commander!!!';
var antet: array[1..51] of char;
    f: file;
    size: longint;
    x: integer;
begin
 assign(f,directorcusles(startdir)+selectfile);
 setfattr(f,0);
 reset(f,1);
 size:=filesize(f);
 blockread(f,antet,51,contor);
 if antet=semnat then
 begin
  if size>=52 then
  blockread(f,cpan,1,contor);
  if cpan<1 then cpan:=1;
  if cpan>2 then cpan:=2;
  for x:=1 to 2 do
  with panouri[x]^ do
  begin
   if size>=52+x*256 then
   blockread(f,cdir[0],256,contor);
  end;
  for x:=1 to 2 do
  begin
   if size>=52+512+x*sizeof(cautari[x]) then
   blockread(f,cautari[x],sizeof(cautari[x]),contor);
  end;
 end else
 begin
  panouri[1]^.cdir:='c:\';
  panouri[2]^.cdir:='c:\';
 end;
 close(f);
 assign(f,directorcusles(startdir)+selectfile);
 erase(f);
end;

procedure saverld;
var antet: array[1..51] of char;
    f: file;
    caut: cautare;
begin
 antet:='MSoft - Fisier temporar facut de MSoft Commander!!!';
 assign(f,directorcusles(startdir)+selectfile);
 setfattr(f,0);
 rewrite(f,1);
 if rezultat<>0 then exit;
 blockwrite(f,antet,51,contor);
 blockwrite(f,cpan,1,contor);
 for x:=1 to 2 do
 with panouri[x]^ do
 blockwrite(f,cdir[0],256,contor);
 for x:=1 to 2 do
 with panouri[x]^ do
 begin
  if nrfiles+nrdirs>0 then caut.da:=true else caut.da:=false;
  caut.nume:=fil[de+dp+1].nume;
  caut.extensie:=fil[de+dp+1].ext;
  if(fil[de+dp+1].attr and directory)<>0 then caut.attr:=0 else caut.attr:=1;
  blockwrite(f,caut,sizeof(caut),contor);
 end;
 close(f);
end;

procedure mcexit;
var f: file;
begin
 exitproc:=oldexit;
 if nom then iesire:=true;
 filemode:=2;
 assign(f,startdir+tempfile);
 setfattr(f,0);
 rewrite(f,1);
 if rezultat=0 then
 begin
  if iesire then blockwrite(f,ciesi,1,scris) else
  blockwrite(f,cexec,1,scris);
  blockwrite(f,comline[0],256,scris);
 end;
 close(f);
 if getm<>3 then
 begin
  writeln('Apasa ENTER pentru a continua....');
  readln;
  inittext80x25;
 end;
 cursor(true);
 clipire(false);
 if nom then
 begin
  writeln('Memorie insuficienta!');
 end else
 begin
  scriuspate;
  if not iesire then
  writeln(comline);
  saverld;
  with panouri[cpan]^ do
  imparteindirectoare(cdir,dirs,xt);
  elibmem;
  duteindirector(xt);
 end;
end;

procedure nomem;
begin
 nom:=true;
 halt(1);
end;

procedure int1c; interrupt;
begin
 scrcnt:=scrcnt-1;
 if scrcnt<0 then scrcnt:=0;
 anicnt:=anicnt+1;
end;

procedure initmem;
var x: longint;
begin
 getintvec($1c,old1c);
 setintvec($1c,@int1c);
 nom:=false;
 ta:=ptr($B800,0);
 tb:=ptr(mhmemaloc(sizeof(tb^)),0);
 if eraloc<>eranimic then nomem;
 tc:=ptr(mhmemaloc(sizeof(tc^)),0);
 if eraloc<>eranimic then nomem;
 td:=ptr(mhmemaloc(sizeof(td^)),0);
 if eraloc<>eranimic then nomem;
 panouri[1]:=ptr(mhmemaloc(sizeof(panouri[1]^)),0);
 if eraloc<>eranimic then nomem;
 panouri[2]:=ptr(mhmemaloc(sizeof(panouri[2]^)),0);
 if eraloc<>eranimic then nomem;
 scrispan[1]:=ptr(mhmemaloc(sizeof(scrispan[1]^)),0);
 if eraloc<>eranimic then nomem;
 scrispan[2]:=ptr(mhmemaloc(sizeof(scrispan[2]^)),0);
 if eraloc<>eranimic then nomem;
 copybuf:=ptr(mhmemaloc(sizeof(copybuf^)),0);
 if eraloc<>eranimic then nomem;
end;

procedure vezidacagasesti(pan: byte);
var x,start,stop: integer;
begin
 if(pan<1)or(pan>2) then exit;
 if cauta.attr=0 then
 with panouri[pan]^ do
 begin
  if nrdirs>0 then
  begin
   start:=1;
   stop:=nrdirs;
  end;
 end else
 with panouri[pan]^ do
 begin
  if nrfiles>0 then
  begin
   start:=nrdirs+1;
   stop:=nrdirs+nrfiles;
  end;
 end;
 if cauta.da then
 for x:=start to stop do
 with panouri[pan]^ do
 if(upstring(fil[x].nume)=upstring(cauta.nume))and(upstring(fil[x].ext)=
 upstring(cauta.extensie)) then
 begin
  dp:=0;
  de:=x-1;
  exit;
 end;
 cauta.da:=false;
end;

procedure iesidindirector(pan: byte);
var x: integer;
begin
 if(pan<1)or(pan>2) then exit;
 with panouri[cpan]^ do
 begin
  fsplit(cdir,dir,name,ext);
  cauta.da:=true;
  if name='' then cauta.da:=false;
  cauta.nume:=name;
  if (length(ext)>0)and(ext[1]='.') then
  begin
   for x:=1 to length(ext)-1 do
   ext[x]:=ext[x+1];
   ext[0]:=chr(ord(ext[0])-1);
  end;
  cauta.extensie:=ext;
  cauta.attr:=0;
  scandir(pan,'..');
  calculezpanou(pan);
  de:=0;
  dp:=0;
  vezidacagasesti(pan);
 end;
end;

procedure enterpefisier;
var poz: integer;
begin
 if comline<>'' then
 begin
  scriuspate;
  halt;
 end;
 with panouri[cpan]^ do
 if(de+dp<nrfiles+nrdirs) then
 begin
  poz:=de+dp+1;
  if(fil[poz].attr and directory=0) then
  begin
   if(upstring(fil[poz].ext)='EXE')or(upstring(fil[poz].ext)='COM')or
   (upstring(fil[poz].ext)='BAT') then
   begin
    scriuspate;
    comline:=downstring(fullstring(fil[poz].nume,fil[poz].ext));
    halt;
   end;
  end else
  begin
   if(fil[poz].nume='..') then iesidindirector(cpan) else
   begin
    de:=0;
    dp:=0;
    scandir(cpan,fullstring(fil[poz].nume,fil[poz].ext));
    calculezpanou(cpan);
   end;
  end;
 end;
end;

procedure dutenradacina(pan: byte);
begin
 if(pan<1)or(pan>2) then exit;
 with panouri[pan]^ do
 begin
  getdir(0,cdir);
  if length(cdir)>3 then cdir[0]:=#3;
  scandir(pan,cdir);
  desenezpanou(tb,pan);
  calculezpanou(pan);
  de:=0;
  dp:=0;
 end;
end;

procedure initializare;
var x,y: integer;
begin
 ta:=nil;
 tb:=nil;
 tc:=nil;
 panouri[1]:=nil;
 panouri[2]:=nil;
 scrispan[1]:=nil;
 scrispan[2]:=nil;
 copybuf:=nil;
 scrmax:=18*60;
 scrcnt:=scrmax;
 startdir:=directorcusles(getstartdir);
 atr[1].l:='A';
 atr[2].l:='R';
 atr[3].l:='S';
 atr[4].l:='H';
 atr[1].nr:=archive;
 atr[2].nr:=readonly;
 atr[3].nr:=sysfile;
 atr[4].nr:=hidden;
 comline:='';
 sortptr[2]:=@quicksortext;
 sortptr[1]:=@quicksortnume;
 maxsort:=1;
 sortare:=ascendenta;
 for x:=1 to 2 do
 panouri[x]^.vizibil:=true;
 panos:=40;
 panvs:=20;
 panfs:=18;
 pansx:=1;
 pansy:=2;
 cpan:=2;
 oldexit:=exitproc;
 exitproc:=@mcexit;
 initmem;
 scanezspate;
 golescfer(tb,1,1,80,25);
 loadrld;
 with panouri[cpan]^ do
 begin
  getdir(0,curentdir);
  if upstring(cdir)<>upstring(curentdir) then cautari[cpan].da:=false;
  cdir:=curentdir;
 end;
 with panouri[3-cpan]^ do
 begin
  imparteindirectoare(cdir,dirs,xt);
  if not duteindirector(xt) then
  with panouri[3-cpan]^ do
  begin
   getdir(0,cdir);
   cautari[3-cpan].da:=false;
  end;
 end;
 for x:=1 to 2 do
 with panouri[x]^ do
 begin
  scandir(x,'');
  desenezpanou(tb,x);
  calculezpanou(x);
  cauta:=cautari[x];
  vezidacagasesti(x);
 end;
 if getm<>3 then
 begin
  writeln('Apasa ENTER pentru a continua....');
  readln;
  inittext80x25;
 end;
 treci80x25;
 cursor(true);
 clipire(false);
 if mono then
 begin
  spatecol:=0;
  speccol:=0;
  selectcol:=0;
  fillcol:=0;
  scriscol:=0;
 end else
 begin
 end;
end;

procedure invertsel(pan: byte);
var x: integer;
begin
 if(pan<1)or(pan>2) then exit;
 with panouri[pan]^ do
 for x:=1 to nrfiles+nrdirs do
 begin
  if fil[x].nume<>'..' then
  if eselectat(pan,x) then
  begin
   selecteaza(pan,x,false);
   nrsel:=nrsel-1;
   sizesel:=sizesel-fil[x].marime;
  end else
  begin
   selecteaza(pan,x,true);
   nrsel:=nrsel+1;
   sizesel:=sizesel+fil[x].marime;
  end;
 end;
end;

procedure screensaver;
var s: string;
begin
 comline:=upstring(getenv('COMSPEC')+'/C '+directorcusles(startdir)+'STARS.EXE');
 halt;
end;

procedure facdir;
var gata,fac: boolean;
    s1,full: string;
    strpoz: integer;
    name: namestr;
    ext: extstr;
    dir: dirstr;
begin
 gata:=false;
 fac:=false;
 strpoz:=0;
 full:='';
 repeat
  elimintasta;
  citesctasta;
  if tasta.citita then
  begin
   if tasta.zero then
   begin
    if tasta.cod=tend then strpoz:=length(full) else
    if tasta.cod=thome then strpoz:=0 else
    if tasta.cod=tpgup then strpoz:=strpoz-5 else
    if tasta.cod=tpgdn then strpoz:=strpoz+5 else
    if tasta.cod=tstanga then strpoz:=strpoz-1 else
    if tasta.cod=tdreapta then strpoz:=strpoz+1 else
    if tasta.cod=tdel then
    begin
     eliminlitera(full,strpoz+1);
    end;
    if strpoz<0 then strpoz:=0;
    if strpoz>length(full) then strpoz:=length(full);
   end else
   begin
    if tasta.cod=tenter then
    begin
     gata:=true;
     fac:=true;
    end else
    if tasta.cod=tesc then gata:=true else
    if tasta.cod=tbkspace then
    begin
     eliminlitera(full,strpoz);
     strpoz:=strpoz-1;
     if strpoz<0 then strpoz:=0;
    end else
    begin
     inserezlitera(full,chr(tasta.cod),strpoz+1);
     strpoz:=strpoz+1;
    end;
    if length(full)>70 then
    begin
     full[0]:=#70;
     strpoz:=70;
    end;
   end;
  end;
  fsplit(full,dir,name,ext);
  if length(ext)>0 then if ext[1]='.' then
  begin
   s1:=ext;
   eliminlitera(s1,1);
   ext:=s1;
  end;
  dir:=upstring(dir);
  ext:=upstring(ext);
  name:=upstring(name);
  setchar(#32);
  setbaccolor(fillcol);
  setcharcolor(scriscol);
  ferg80x25(tb,4,10,77,14,'Introdu numele directorului:');
  setbaccolor(0);
  s1:=full;
  for x:=length(s1)+1 to 70 do
  s1:=s1+#249;
  writestring80x25(tb,6,11,s1,false,false,false);
  setbaccolor(fillcol);
  s1:=dir;
  for x:=length(s1)+1 to 70 do
  s1:=s1+#249;
  writestring80x25(tb,6,12,s1,false,false,false);
  s1:=name;
  for x:=length(s1)+1 to 8 do
  s1:=s1+#249;
  writestring80x25(tb,6,13,s1,false,false,false);
  s1:=ext;
  for x:=length(s1)+1 to 3 do
  s1:=s1+#249;
  writestring80x25(tb,73,13,s1,false,false,false);
  animatie(tb);
  ta^:=tb^;
  cursorto80x25(6+strpoz,11);
 until gata;
 elimintasta;
end;

begin
 initializare;
 repeat
  for x:=1 to 2 do
  with panouri[x]^ do
  begin
   dev:=de;
   dpv:=dp;
  end;
  iesire:=false;
  elimintasta;
  citesctasta;
  if(tasta.citita) then
  begin
   scrcnt:=scrmax;
   if(not tasta.zero) then
   begin
    if(tasta.cod=ttab) then
    begin
     if cpan=1 then cpan:=2 else cpan:=1;
     elimintasta;
    end;
    if(tasta.cod=tctrlbkspace) then
    begin
     iesidindirector(cpan);
     elimintasta;
    end;
    if(tasta.cod=tenter) then
    begin
     enterpefisier;
     elimintasta;
    end;
    if(tasta.cod=tesc) then
    begin
     comline:='';
     elimintasta;
    end;
    if(tasta.cod=tctrlsls) then
    begin
     dutenradacina(cpan);
     elimintasta;
    end;
    if(tasta.cod=tstel) then
    if not shift then
    begin
     invertsel(cpan);
     elimintasta;
    end;
    if(tasta.cod=tctrlo) then
    begin
     scriuspate;
     repnokey;
     repkey;
     repnokey;
     elimintasta;
    end;
    if(tasta.cod=tctrlenter) then
    with panouri[cpan]^ do
    if nrfiles+nrdirs>0 then
    begin
     if(fil[de+dp+1].attr and directory)<>0 then
     comline:=comline+upstring(fullstring(fil[de+dp+1].nume,fil[de+dp+1].ext))+' ' else
     comline:=comline+downstring(fullstring(fil[de+dp+1].nume,fil[de+dp+1].ext))+' ';
     elimintasta;
    end;
    if(tasta.citita) then
    begin
     if(tasta.cod=tbkspace) then
     begin
      if length(comline)>0 then comline[0]:=chr(ord(comline[0])-1);
     end else comline:=comline+chr(tasta.cod);
    end;
   end else
   begin
    if(tasta.cod=tf7) then facdir;
    if(tasta.cod=tf10) then iesire:=true;
    if(tasta.cod=tjos) then
    with panouri[cpan]^ do de:=de+1;
    if(tasta.cod=tsus) then
    with panouri[cpan]^ do de:=de-1;
    if(tasta.cod=tpgdn)or(tasta.cod=tdreapta) then
    with panouri[cpan]^ do dp:=dp+panfs;
    if(tasta.cod=tpgup)or(tasta.cod=tstanga) then
    with panouri[cpan]^ do dp:=dp-panfs;
    if(tasta.cod=thome) then
    with panouri[cpan]^ do
    begin
     dp:=0;
     de:=0;
    end;
    if(tasta.cod=tend) then
    with panouri[cpan]^ do
    begin
     dp:=nrfiles+nrdirs-21;
     de:=20;
    end;
    if(tasta.cod=tins) then
    with panouri[cpan]^ do
    begin
     if fil[dp+de+1].nume<>'..' then
     if eselectat(cpan,de+dp+1) then
     begin
      selecteaza(cpan,dp+de+1,false);
      nrsel:=nrsel-1;
      sizesel:=sizesel-fil[dp+de+1].marime;
     end else
     begin
      selecteaza(cpan,dp+de+1,true);
      nrsel:=nrsel+1;
      sizesel:=sizesel+fil[dp+de+1].marime;
     end;
     de:=de+1;
    end;
   end;
  end;
  verificpozitia;
  golescfer(tb,1,1,80,25);
  for x:=1 to 2 do
  with panouri[x]^ do
  begin
   if(dp<>dpv) then calculezpanou(x);
   desenezpanou(tb,x);
   scriupanou(tb,x);
  end;
  scriuliniadecomanda(tb);
  animatie(tb);
  ta^:=tb^;
  cursorto80x25(length(comline)+1,24);
  if scrcnt<=0 then
  begin
   screensaver;
   scrcnt:=scrmax;
  end;
 until iesire;
end.