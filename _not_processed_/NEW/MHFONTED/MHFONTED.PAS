{$A+,B-,D+,E+,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,0}
{MSoft 2000
       Acest program este un editor de fonturi MSoft.
       Inca mai e mult de lucrat la el, deci nu te astepta sa faca ceva.}
program mhfonted;
uses dos,mtast,mouse,mhimg,mhpal,mhmem,tpkey;
const maxfx: byte=15;
      maxfy: byte=15;
type finfo=record
            nume: string[8];
            ext: string[3];
            marime: longint;
            tip: byte;
           end;
     codtasta=record
               citita,zero: boolean;
               cod: char;
              end;
const maxfiles=1000;
      tipdir: byte=0;
      tipfis: byte=1;
var mfx1,mfy1,mfx2,mfy2: byte;
    panou: array[1..maxfiles] of finfo;
    ppan,nrd,nrf,nre: integer;
    bloc1,bloc2: vp;
    cchar1,cchar2: integer;
    a,b: ^ecran;
    msx,msy: integer;
    epoz,dpoz: integer;
    general,dir2p,font1,font2,font3,iesire,selectat: boolean;
    size1,size2,size3: longint;
    maxmenu: byte;
    menustr: array[1..10] of string[25];
    menulim: array[1..10] of record
                              sx,sy,ex,ey: integer
                             end;
    maxsubmenu: array[1..10] of byte;
    submenustr: array[1..10,1..10] of string[25];
    submenulim: array[1..10,1..10] of record
                              sx,sy,ex,ey: integer
                             end;
    submenuprocs: array[1..10,1..10] of pointer;
    deschismenu: boolean;
    menupoz,submenupoz: integer;
    subminx,submaxx: integer;
    procschimb: procedure;
    fisiere: array[1..2] of record
                             nume: string;
                             salvat: boolean;
                             arenume: boolean;
                            end;
    tasta: codtasta;
    titlumain: string;

procedure golesctaste;
begin
 repeat
  if keypressed then readkey;
 until not keypressed;
end;

procedure citesctasta;
begin
 if tasta.citita then exit;
 if keypressed then
 begin
  tasta.citita:=true;
  tasta.zero:=false;
  tasta.cod:=readkey;
  if tasta.cod=#0 then
  begin
   tasta.zero:=true;
   tasta.cod:=readkey;
  end;
 end;
end;

procedure elimintasta;
begin
 tasta.citita:=false;
end;

procedure iesimdinprogram;
begin
 iesire:=true;
end;

procedure dummy;
begin
 closegr;
 initgr;
 setpal(normpal1);
end;

procedure miscsus;
begin
 epoz:=epoz-1;
 if epoz<1 then
 if dpoz<=0 then
 begin
  dpoz:=0;
  epoz:=1;
 end else
 begin
  dpoz:=dpoz-1;
  epoz:=1;
 end;
end;

procedure miscjos;
begin
 if nre<10 then
 begin
  if epoz<nre then epoz:=epoz+1;
 end else
 begin
  if epoz<10 then epoz:=epoz+1 else
  if dpoz<nre-10 then
  begin
   epoz:=10;
   dpoz:=dpoz+1;
  end;
 end;
end;

procedure miscpgdn;
begin
 for x:=1 to 10 do miscjos;
end;

procedure miscpgup;
begin
 for x:=1 to 10 do miscsus;
end;

procedure desenezmouse;
begin
 scolor(32*4+25);
 linie(b,msx,msy,msx,msy+5);
 linie(b,msx,msy,msx+6,msy+6);
 linie(b,msx,msy,msx+5,msy);
end;

function downcase(c: char): char;
var x: integer;
begin
 x:=ord(c);
 if (x<ord('A'))or(x>ord('Z')) then downcase:=c else
 begin
  x:=x-ord('A');
  downcase:=chr(x+ord('a'));
 end;
end;

function upcase(c: char): char;
var x: integer;
begin
 x:=ord(c);
 if (x<ord('a'))or(x>ord('z')) then upcase:=c else
 begin
  x:=x-ord('a');
  upcase:=chr(x+ord('A'));
 end;
end;

function upstring(s: string): string;
var x: integer;
begin
 for x:=1 to length(s) do
 upstring[x]:=upcase(s[x]);
 upstring[0]:=s[0];
end;

function downstring(s: string): string;
var x: integer;
begin
 for x:=1 to length(s) do
 downstring[x]:=downcase(s[x]);
 downstring[0]:=s[0];
end;

procedure quicksortnume(l,r: integer);
procedure sort(l,r: integer);
var i,j: integer;
    x,y: finfo;
begin
  i:=l;j:=r;x:=panou[(l+r)div 2];
  repeat
    while panou[i].nume<x.nume do i:=i+1;
    while x.nume<panou[j].nume do j:=j-1;
    if i<=j then
    begin
      y:=panou[i];panou[i]:=panou[j];panou[j]:=y;
      i:=i+1;j:=j-1;
    end;
  until i>j;
  if l<j then Sort(l,j);
  if i<r then Sort(i,r);
end;
begin
 sort(l,r);
end;

procedure scandir;
var sr: searchrec;
    dirn: dirstr;
    namen: namestr;
    extn: extstr;
begin
 fillchar(panou,sizeof(panou),0);
 nrf:=0;nrd:=0;nre:=0;dir2p:=false;ppan:=0;
 findfirst('*.*',$3F-volumeid,sr);
 while (doserror=0)and(ppan<maxfiles) do
 begin
  if (sr.name<>'.')and((sr.attr and directory)<>0) then
  begin
   nrd:=nrd+1;
   ppan:=ppan+1;
   extn:='';
   if sr.name='..' then
   begin
    panou[ppan].tip:=tipdir;
    panou[ppan].nume:='..';
    dir2p:=true;
   end else
   begin
    fsplit(sr.name,dirn,namen,extn);
    panou[ppan].nume:=upstring(namen);
    if extn[1]='.' then
    begin
     for x:=1 to 3 do
     extn[x]:=extn[x+1];
     extn[0]:=chr(ord(extn[0])-1);
    end;
    panou[ppan].ext:=upstring(extn);
    panou[ppan].tip:=tipdir;
   end;
  end;
  findnext(sr);
 end;
 findfirst('*.*',$3F-volumeid,sr);
 while (doserror=0)and(ppan<maxfiles) do
 begin
  if (sr.attr and directory)=0 then
  begin
   ppan:=ppan+1;
   nrf:=nrf+1;
   if sr.size>0 then panou[ppan].marime:=trunc(sr.size/1024)+1 else
   panou[ppan].marime:=0;
   extn:='';
   fsplit(sr.name,dirn,namen,extn);
   panou[ppan].nume:=downstring(namen);
   if extn[1]='.' then
   begin
    for x:=1 to 3 do
    extn[x]:=extn[x+1];
    extn[0]:=chr(ord(extn[0])-1);
   end;
   panou[ppan].ext:=downstring(extn);
   panou[ppan].tip:=tipfis;
  end;
  findnext(sr);
 end;
 nre:=nrd+nrf;
 if nre>0 then
 begin
  if nrd>0 then quicksortnume(1,nrd);
  if nrf>0 then quicksortnume(nrd+1,nre);
 end;
end;

function fullstring(pozitie: integer): string;
var st1,st2: string;
begin
 st1:=panou[pozitie].nume;
 st2:=panou[pozitie].ext;
 if st2<>'' then st1:=st1+'.'+st2;
 fullstring:=st1;
end;

procedure selectarefisier(titlu: string;var fisier: string;var anulat: boolean);
var x,y,z,t: integer;
    scris,sus,jos,fsus,fjos,accept,anulez: record
                    sx,sy,ex,ey: integer;
                    mesaj: string[10];
                   end;
    ajunge,scriu,facut: boolean;
    st1,st2,filest: string;
    pozs: integer;
    sr: searchrec;
begin
 facut:=false;
 filest:='';
 scandir;
 dpoz:=0;
 epoz:=1;
 if nre>0 then filest:=fullstring(1);
 scriu:=false;
 ajunge:=false;
 anulat:=false;
 fisier:='';
 accept.mesaj:='Accept';
 anulez.mesaj:='Anulez';
 accept.sx:=250;
 accept.sy:=20;
 accept.ex:=accept.sx+(length(accept.mesaj)+4)*5;
 accept.ey:=accept.sy+30;
 anulez.sx:=250;
 anulez.sy:=60;
 anulez.ex:=anulez.sx+(length(anulez.mesaj)+4)*5;
 anulez.ey:=anulez.sy+30;
 fsus.sx:=210;
 fsus.sy:=20;
 fsus.ex:=fsus.sx+10;
 fsus.ey:=fsus.sy+10;
 sus.sx:=210;
 sus.sy:=35;
 sus.ex:=sus.sx+10;
 sus.ey:=sus.sy+10;
 fjos.sx:=210;
 fjos.sy:=175;
 fjos.ex:=fjos.sx+10;
 fjos.ey:=fjos.sy+10;
 jos.sx:=210;
 jos.sy:=160;
 jos.ex:=jos.sx+10;
 jos.ey:=jos.sy+10;
 scris.sx:=30;
 scris.sy:=50;
 scris.ex:=scris.sx+12*5;
 scris.ey:=scris.sy+10;
 repeat
  schimbmf(1);
  filest:=downstring(filest);
  facut:=false;
  citesctasta;
  readmouse;
  msx:=mousex div 2;
  msy:=mousey;
  if leftbuttonpressed then
  begin
   if (msx>=anulez.sx)and(msx<=anulez.ex)and(msy>=anulez.sy)and
   (msy<=anulez.ey) then
   begin
    anulat:=true;
    ajunge:=true;
   end;
   if (msx>=accept.sx)and(msx<=accept.ex)and(msy>=accept.sy)and
   (msy<=accept.ey) then
   if nre>0 then
   begin
    if filest=downstring(fullstring(epoz+dpoz)) then
    begin
     anulat:=false;
     if panou[dpoz+epoz].tip=tipfis then
     begin
      ajunge:=true;
      fisier:=downstring(fullstring(epoz+dpoz));
      anulat:=false;
     end;
     if panou[dpoz+epoz].tip=tipdir then
     begin
      st1:=fullstring(epoz+dpoz);
      {$I-}
      chdir(st1);
      {$I+}
      if ioresult<>0 then facut:=true;
      if not facut then
      begin
       scandir;
       dpoz:=0;
       epoz:=1;
       if nre>0 then
       begin
        filest:=fullstring(1);
        anulat:=false;
       end;
       facut:=true;
      end;
     end;
    end;
    if filest<>downstring(fullstring(epoz+dpoz)) then
    if not facut then
    begin
     if filest='..' then
     begin
      {$I-}
      chdir('..');
      {$I+}
      if ioresult<>0 then facut:=true;
      if not facut then
      begin
       scandir;
       dpoz:=0;
       epoz:=1;
       if nre>0 then filest:=fullstring(1);
       facut:=true;
      end;
     end;
     if not facut then
     begin
      st1:=fullstring(epoz+dpoz);
      findfirst(st1,$3f-volumeid,sr);
      if doserror<>0 then
      else
      begin
       if (sr.attr and directory)<>0 then
       begin
        {$I-}
        chdir(st1);
        {$I+}
        if ioresult<>0 then facut:=true;
        if not facut then
        begin
         scandir;
         dpoz:=0;
         epoz:=1;
         if nre>0 then filest:=fullstring(1);
         fisier:=filest;
         facut:=true;
         anulat:=false;
         exit;
        end;
        if not facut then
        if (sr.attr and directory=0) then
        begin
         facut:=true;
         ajunge:=true;
         fisier:=st1;
         exit;
        end;
       end;
      end;
      ajunge:=true;
      filest:=downstring(filest);
      fisier:=filest;
      anulat:=false;
     end;
    end;
   end;
   if nre>0 then
   for x:=1 to 10 do
   if dpoz+x<=nre then
   begin
    if (msx>=30)and(msx<=30+12*5)and(msy>=(x-1)*12+65)and(msy<=(x-1)*12+65+10) then
    begin
     epoz:=x;
     filest:=downstring(fullstring(epoz+dpoz));
    end;
   end;
   if (msx>=sus.sx)and(msx<=sus.ex)and(msy>=sus.sy)and(msy<=sus.ey) then
   begin
    miscsus;
    filest:=fullstring(epoz+dpoz);
   end;
   if (msx>=fsus.sx)and(msx<=fsus.ex)and(msy>=fsus.sy)and(msy<=fsus.ey) then
   begin
    miscpgup;
    filest:=fullstring(epoz+dpoz);
   end;
   if (msx>=jos.sx)and(msx<=jos.ex)and(msy>=jos.sy)and(msy<=jos.ey) then
   begin
    miscjos;
    filest:=fullstring(epoz+dpoz);
   end;
   if (msx>=fjos.sx)and(msx<=fjos.ex)and(msy>=fjos.sy)and(msy<=fjos.ey) then
   begin
    miscpgdn;
    filest:=fullstring(epoz+dpoz);
   end;
   if not scriu then
   if (msx>=scris.sx)and(msx<=scris.ex)and(msy>=scris.sy)and(msy<=scris.ey) then
   begin
    scriu:=true;
    pozs:=length(filest)+1;
   end;
   if scriu then
   if (msx<scris.sx)or(msx>scris.ex)or(msy<scris.sy)or(msy>scris.ey) then
   scriu:=false;
   repeat
    readmouse;
   until not leftbuttonpressed;
   end else
   golesctaste;
   if scriu then
   begin
    citesctasta;
    if tasta.citita then
    begin
     if (not tasta.zero)and(tasta.cod=#8) then
     if length(filest)>0 then filest[0]:=chr(ord(filest[0])-1);
     if (not tasta.zero)and(tasta.cod<>#8) then
     if length(filest)<12 then filest:=filest+tasta.cod;
     elimintasta;
    end;
  end;
  filest:=downstring(filest);
  fcolor(31);
  scolor(0);
  baram(b,0,0,319,199);
  fcolor(32*1+31);
  baram(b,0,0,319,12);
  x:=159-(length(titlu)+1)*5 div 2;
  scolor(31);
  mvtextxy2(b,x,0,titlu);
  fcolor(22);
  scolor(0);
  baram(b,accept.sx,accept.sy,accept.ex,accept.ey);
  baram(b,anulez.sx,anulez.sy,anulez.ex,anulez.ey);
  baram(b,fsus.sx,fsus.sy,fsus.ex,fsus.ey);
  baram(b,sus.sx,sus.sy,sus.ex,sus.ey);
  baram(b,fjos.sx,fjos.sy,fjos.ex,fjos.ey);
  baram(b,jos.sx,jos.sy,jos.ex,jos.ey);
  mvtextxy2(b,accept.sx+10,accept.sy+10,accept.mesaj);
  mvtextxy2(b,anulez.sx+10,anulez.sy+10,anulez.mesaj);
  begin
   linie(b,sus.sx+5,sus.sy+1,sus.sx+1,sus.sy+6);
   linie(b,sus.sx+5,sus.sy+1,sus.sx+9,sus.sy+6);
  end;
  begin
   linie(b,fsus.sx+5,fsus.sy+1,fsus.sx+1,fsus.sy+6);
   linie(b,fsus.sx+5,fsus.sy+1,fsus.sx+9,fsus.sy+6);
   linie(b,fsus.sx+5,fsus.sy+4,fsus.sx+1,fsus.sy+9);
   linie(b,fsus.sx+5,fsus.sy+4,fsus.sx+9,fsus.sy+9);
  end;
  begin
   linie(b,jos.sx+5,jos.sy+9,jos.sx+1,jos.sy+4);
   linie(b,jos.sx+5,jos.sy+9,jos.sx+9,jos.sy+4);
  end;
  begin
   linie(b,fjos.sx+5,fjos.sy+9,fjos.sx+1,fjos.sy+4);
   linie(b,fjos.sx+5,fjos.sy+9,fjos.sx+9,fjos.sy+4);
   linie(b,fjos.sx+5,fjos.sy+6,fjos.sx+1,fjos.sy+1);
   linie(b,fjos.sx+5,fjos.sy+6,fjos.sx+9,fjos.sy+1);
  end;
  fcolor(32*1+31);
  bara(b,28,(epoz-1)*12+65,90,(epoz-1)*12+76);
  scolor(0);
  for x:=1 to 10 do
  if dpoz+x<=nre then
  begin
   st1:=panou[dpoz+x].nume;
   st2:=panou[dpoz+x].ext;
   mvtextxy2(b,30,(x-1)*12+65,st1);
   mvtextxy2(b,30+45,(x-1)*12+65,st2);
  end;
  dreptunghi(b,scris.sx-2,scris.sy,scris.ex+2,scris.ey);
  mvtextxy2(b,scris.sx,scris.sy,filest);
  scolor(0);
  if scriu then
  linie(b,scris.sx+5*(length(filest)),scris.sy+8,scris.sx+5*(length(filest)+1),scris.sy+8);
  desenezmouse;
  a^:=b^;
 until ajunge;
end;

function intreabama(stg: string): boolean;
begin
end;

procedure fontdeschidere;
var numef: string;
    anulat: boolean;
    st: string;
    sx,ex: integer;
    f: file;
begin
 selectarefisier('Deschidere font',numef,anulat);
 if anulat then exit;
 if numef='' then exit;
 {$I-}
 assign(f,numef);
 reset(f,1);
 close(f);
 if ioresult<>0 then
 begin
  clearbuf(b,0);
  st:='Nu pot deschide fisierul '+numef+'!';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end else
 begin
  clearbuf(b,0);
  st:='Se poate deschide fisierul '+numef+'!';
  titlumain:='MSoft Font editor - ['+downstring(numef)+']';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end;
 {$I+}
end;

procedure fontdeschidajut;
var numef: string;
    anulat: boolean;
    st: string;
    sx,ex: integer;
    f: file;
begin
 selectarefisier('Deschidere font ajutator',numef,anulat);
 if anulat then exit;
 if numef='' then exit;
 {$I-}
 assign(f,numef);
 reset(f,1);
 close(f);
 if ioresult<>0 then
 begin
  clearbuf(b,0);
  st:='Nu pot deschide fisierul '+numef+'!';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end else
 begin
  clearbuf(b,0);
  st:='Se poate deschide fisierul '+numef+'!';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end;
 {$I+}
end;

procedure fontsalvare;
var numef: string;
    anulat: boolean;
    st: string;
    sx,ex: integer;
    f: file;
begin
 selectarefisier('Salvare font',numef,anulat);
 if anulat then exit;
 if numef='' then exit;
 {$I-}
 assign(f,numef);
 rewrite(f,1);
 close(f);
 erase(f);
 if ioresult<>0 then
 begin
  clearbuf(b,0);
  st:='Nu pot salva fisierul '+numef+'!';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end else
 begin
  clearbuf(b,0);
  general:=false;
  st:='Se poate salva fisierul '+numef+'!';
  titlumain:='MSoft Font editor - ['+downstring(numef)+']';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end;
 {$I+}
end;

procedure fontredenumire;
var numef: string;
    anulat: boolean;
    st: string;
    sx,ex: integer;
    f: file;
begin
 selectarefisier('Redenumire font',numef,anulat);
 if anulat then exit;
 if numef='' then exit;
 {$I-}
 assign(f,numef);
 rewrite(f,1);
 close(f);
 erase(f);
 if ioresult<>0 then
 begin
  clearbuf(b,0);
  st:='Nu pot redenumi fisierul '+numef+'!';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end else
 begin
  clearbuf(b,0);
  st:='Se poate redenumi fisierul '+numef+'!';
  sx:=159-(length(st)+1)*5 div 2;
  ex:=sx+5*length(st);
  fcolor(31);
  scolor(0);
  baram(b,sx-5,70,ex+5,90);
  scolor(0);
  mvtextxy2(b,sx,73,st);
  a^:=b^;
  repeat
   readmouse;
  until leftbuttonpressed;
  repeat
   readmouse;
  until not leftbuttonpressed;
 end;
 {$I+}
end;

procedure creezfont(mfx,mfy: integer);
begin
end;

procedure fontnou;
var scris1,scris2,sus1,jos1,sus2,jos2,accept,anulez: record
                    sx,sy,ex,ey: integer;
                    mesaj: string[10];
                   end;
    ajunge,anulat: boolean;
    mfx,mfy,marx1,mary1,marx2,mary2: integer;
    stg: array[1..4] of string[80];
    titlu: string[80];
    salvam: boolean;
begin
 salvam:=false;
 titlu:='MSoft font editor - Font nou';
 marx1:=3;
 mary1:=3;
 marx2:=15;
 mary2:=15;
 if not font1 then
 begin
  mfx:=6;
  mfy:=8;
 end else
 begin
  mfx:=mfx1;
  mfy:=mfy1;
 end;
 accept.mesaj:='Accept';
 anulez.mesaj:='Anulez';
 accept.sx:=250;
 accept.sy:=20;
 accept.ex:=accept.sx+(length(accept.mesaj)+4)*5;
 accept.ey:=accept.sy+30;
 anulez.sx:=250;
 anulez.sy:=60;
 anulez.ex:=anulez.sx+(length(anulez.mesaj)+4)*5;
 anulez.ey:=anulez.sy+30;
 ajunge:=false;
 anulat:=false;
 scris1.sx:=50;
 scris1.ex:=scris1.sx+40;
 scris1.sy:=50;
 scris1.ey:=scris1.sy+15;
 scris2.sx:=50;
 scris2.ex:=scris2.sx+40;
 scris2.sy:=100;
 scris2.ey:=scris2.sy+15;
 jos1.sx:=scris1.sx-20;
 jos1.ex:=jos1.sx+10;
 jos1.sy:=scris1.sy;
 jos1.ey:=scris1.ey;
 jos2.sx:=scris2.sx-20;
 jos2.ex:=jos2.sx+10;
 jos2.sy:=scris2.sy;
 jos2.ey:=scris2.ey;
 sus1.sx:=scris1.ex+10;
 sus1.ex:=sus1.sx+10;
 sus1.sy:=scris1.sy;
 sus1.ey:=scris1.ey;
 sus2.sx:=scris2.ex+10;
 sus2.ex:=sus2.sx+10;
 sus2.sy:=scris2.sy;
 sus2.ey:=scris2.ey;
 repeat
  readmouse;
  msx:=mousex div 2;
  msy:=mousey;
  if leftbuttonpressed then
  begin
   if (msx>=anulez.sx)and(msx<=anulez.ex)and(msy>=anulez.sy)and
   (msy<=anulez.ey) then
   begin
    anulat:=true;
    ajunge:=true;
   end;
   if (msx>=accept.sx)and(msx<=accept.ex)and(msy>=accept.sy)and
   (msy<=accept.ey) then
   begin
    ajunge:=true;
    anulat:=false;
   end;
   if (msx>=sus1.sx)and(msx<=sus1.ex)and(msy>=sus1.sy)and(msy<=sus1.ey) then
   begin
    mfx:=mfx+1;
    if mfx>marx2 then mfx:=marx2;
   end;
   if (msx>=jos1.sx)and(msx<=jos1.ex)and(msy>=jos1.sy)and(msy<=jos1.ey) then
   begin
    mfx:=mfx-1;
    if mfx<marx1 then mfx:=marx1;
   end;
   if (msx>=sus2.sx)and(msx<=sus2.ex)and(msy>=sus2.sy)and(msy<=sus2.ey) then
   begin
    mfy:=mfy+1;
    if mfy>mary2 then mfy:=mary2;
   end;
   if (msx>=jos2.sx)and(msx<=jos2.ex)and(msy>=jos2.sy)and(msy<=jos2.ey) then
   begin
    mfy:=mfy-1;
    if mfy<mary1 then mfy:=mary1;
   end;
   repeat
    readmouse;
   until not leftbuttonpressed;
  end;
  if rightbuttonpressed then ajunge:=true;
  fcolor(31);
  scolor(0);
  baram(b,0,0,319,199);
  fcolor(32*1+31);
  baram(b,0,0,319,12);
  x:=159-(length(titlu)+1)*5 div 2;
  scolor(31);
  mvtextxy2(b,x,0,titlu);
  fcolor(22);
  scolor(0);
  baram(b,accept.sx,accept.sy,accept.ex,accept.ey);
  baram(b,anulez.sx,anulez.sy,anulez.ex,anulez.ey);
  mvtextxy2(b,accept.sx+10,accept.sy+10,accept.mesaj);
  mvtextxy2(b,anulez.sx+10,anulez.sy+10,anulez.mesaj);
  scolor(0);
  dreptunghi(b,scris1.sx,scris1.sy,scris1.ex,scris1.ey);
  dreptunghi(b,scris2.sx,scris2.sy,scris2.ex,scris2.ey);
  scolor(0);
  fcolor(25);
  baram(b,jos1.sx,jos1.sy,jos1.ex,jos1.ey);
  mvtextxy2(b,jos1.sx+3,jos1.sy+3,'-');
  baram(b,jos2.sx,jos2.sy,jos2.ex,jos2.ey);
  mvtextxy2(b,jos2.sx+3,jos2.sy+3,'-');
  baram(b,sus1.sx,sus1.sy,sus1.ex,sus1.ey);
  mvtextxy2(b,sus1.sx+3,sus1.sy+3,'+');
  baram(b,sus2.sx,sus2.sy,sus2.ex,sus2.ey);
  mvtextxy2(b,sus2.sx+3,sus2.sy+3,'+');
  str(mfx,stg[1]);
  str(mfy,stg[2]);
  for x:=1 to 2 do
  if length(stg[x])<2 then
  repeat
   stg[x]:='0'+stg[x];
  until length(stg[x])>=2;
  scolor(0);
  mvtextxy2(b,scris1.sx+15,scris1.sy+3,stg[1]);
  mvtextxy2(b,scris2.sx+15,scris2.sy+3,stg[2]);
  desenezmouse;
  a^:=b^;
 until ajunge;
 if not anulat then
 begin
  general:=true;
  salvam:=intreabama('Font nou');
  fontsalvare;
  if general then exit;
  creezfont(mfx,mfy);
  if not font1 then titlumain:='MSoft Font editor - [nesalvat]';
 end;
end;

procedure initmenu;
var x,y,z,t: integer;
begin
 maxmenu:=3;
 menustr[1]:='Font';
 menustr[2]:='Editare';
 menustr[3]:='Optiuni';
 menulim[1].sx:=0;
 menulim[1].sy:=0;
 menulim[1].ex:=(length(menustr[1])+1)*5-1;
 menulim[1].ey:=10;
 for x:=2 to maxmenu do
 begin
  menulim[x].sx:=menulim[x-1].ex+1;
  menulim[x].sy:=0;
  menulim[x].ex:=menulim[x].sx+(length(menustr[x])+1)*5-1;
  menulim[x].ey:=10;
 end;
 maxsubmenu[1]:=6;
 submenustr[1,1]:='Nou';
 submenustr[1,2]:='Deschidere font';
 submenustr[1,3]:='Salvare font';
 submenustr[1,4]:='Redenumire font';
 submenustr[1,5]:='Deschidere font ajutator';
 submenustr[1,6]:='Iesire';
 maxsubmenu[2]:=1;
 submenustr[2,1]:='Nimic';
 maxsubmenu[3]:=1;
 submenustr[3,1]:='Mai nimic';
 for x:=1 to maxmenu do
 for y:=1 to maxsubmenu[x] do
 begin
  submenulim[x,y].sx:=menulim[x].sx;
  submenulim[x,y].sy:=menulim[x].sy+y*11;
  submenulim[x,y].ex:=menulim[x].sx+(length(submenustr[x,y])+1)*5-1;
  submenulim[x,y].ey:=menulim[x].sy+(y+1)*11;
 end;
 for x:=1 to maxmenu do
 for y:=1 to maxsubmenu[x] do
 submenuprocs[x,y]:=@dummy;
 submenuprocs[1,1]:=@fontnou;
 submenuprocs[1,2]:=@fontdeschidere;
 submenuprocs[1,3]:=@fontsalvare;
 submenuprocs[1,4]:=@fontredenumire;
 submenuprocs[1,5]:=@fontdeschidajut;
 submenuprocs[1,6]:=@iesimdinprogram;
end;

begin
 titlumain:='MSoft Font editor - [nesalvat]';
 dpoz:=0;
 epoz:=1;
 initmouse;
 if not mouseinstalled then
 begin
  closegr;
  writeln('MSoft: Aceasta aplicatie are nevoie de un mouse instalat!');
  writeln('Instaleaza mouse-ul si incearca iar.');
  halt;
 end;
 a:=ptr(sega000,0);
 b:=ptr(mhmemaloc(64000),0);
 if eraloc<>eranimic then
 begin
  closegr;
  writeln('Nu e destula memorie!');
  halt;
 end;
 initgr;
 setpal(normpal1);
 initmenu;
 repeat
  schimbmf(1);
  selectat:=false;
  clearbuf(b,0);
  fcolor(32*1+31);
  scolor(25);
  dreptunghi(b,0,11,319,199);
  scolor(0);
  baram(b,1,12,318,20);
  scolor(31);
  mvtextxy2(b,159-(length(titlumain)+1)*5 div 2,11,titlumain);
  readmouse;
  msx:=mousex div 2;
  msy:=mousey;
  for x:=1 to maxmenu do
  if (msx>=menulim[x].sx)and(msx<=menulim[x].ex)and(msy>=menulim[x].sy)
  and(msy<=menulim[x].ey)and(leftbuttonpressed) then
  begin
   deschismenu:=true;
   menupoz:=x;
   subminx:=submenulim[x,1].sx;
   submaxx:=menulim[x].ex;
   for y:=1 to maxsubmenu[x] do
   if submenulim[x,y].ex>submaxx then submaxx:=submenulim[x,y].ex;
  end;
  submenupoz:=0;
  if (deschismenu)and((msy>10)or(msx<subminx))and((msx>submaxx)or
  (msy>submenulim[menupoz,maxsubmenu[menupoz]].ey))and(leftbuttonpressed) then
  deschismenu:=false;
  if deschismenu then
  for y:=1 to maxsubmenu[menupoz] do
  if (msx>=submenulim[menupoz,y].sx)and(msx<=submaxx)and
  (msy>=submenulim[menupoz,y].sy)and(msy<=submenulim[menupoz,y].ey)then
  submenupoz:=y;
  fcolor(31);
  bara(b,0,0,319,10);
  if deschismenu then
  if maxsubmenu[menupoz]>0 then
  begin
   scolor(0);
   fcolor(31);
   baram(b,subminx,submenulim[menupoz,1].sy,submaxx,
   submenulim[menupoz,maxsubmenu[menupoz]].ey);
   fcolor(32*1+31);
   bara(b,menulim[menupoz].sx,menulim[menupoz].sy,menulim[menupoz].ex,
   menulim[menupoz].ey);
   if submenupoz>0 then
   bara(b,subminx+1,submenulim[menupoz,submenupoz].sy,
   submaxx-1,submenulim[menupoz,submenupoz].ey);
   for y:=1 to maxsubmenu[menupoz] do
   begin
    scolor(0);
    mvtextxy2(b,submenulim[menupoz,y].sx+3,submenulim[menupoz,y].sy,
    submenustr[menupoz,y]);
   end;
  end;
  if (deschismenu)and(leftbuttonpressed)and(submenupoz>0) then
  begin
   deschismenu:=false;
   selectat:=true;
   @procschimb:=submenuprocs[menupoz,submenupoz];
   procschimb;
  end;
  for x:=1 to maxmenu do
  begin
   scolor(0);
   mvtextxy2(b,menulim[x].sx+3,menulim[x].sy,menustr[x]);
  end;
  desenezmouse;
  a^:=b^;
  golesctaste;
 until iesire;
 iesimdinprogram;
 closegr;
 mhmemdealoc(seg(b^));
end.