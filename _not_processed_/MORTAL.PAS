{$A+,B-,D+,E+,F+,G+,I+,L+,N+,O+,P+,Q+,R+,S+,T+,V+,X+}
{$M 16384,0,0}
program alege_mortal;
uses mhstring,mhmem,textgraf,tpkey;
const ttab: byte=9;
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
      spatecol: byte=14;
      scriscol: byte=4;
      fillcol: byte=1;
      copyright: string[80]='MSoft - Mortal Kombat - Alegatorul de meciuri';
      string2: string[80]='ENTER - Recalculare  ESC - Iesire';
      ajutor: string[80]='Introdu numarul de meciuri: ';
var jucatori: array[1..2,1..12] of record
                               nume: string[20];
                               ales: boolean;
                              end;
    s2,nrstr: string[2];
    ta,tb: ^ecran80x25;
    x,y,z,t,nrm: integer;
    iesire,gata: boolean;
    alesi: array[1..2,1..12] of string[20];
    tasta: record
            citita,zero: boolean;
            cod: byte;
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

procedure recalculez;
begin
 for y:=1 to 2 do
 for x:=1 to 12 do
 jucatori[y,x].ales:=false;
 for y:=1 to 2 do
 for x:=1 to nrm do
 begin
  repeat
   t:=random(12)+1;
  until not jucatori[y,t].ales;
  jucatori[y,t].ales:=true;
  alesi[y,x]:=jucatori[y,t].nume;
 end;
end;

begin
 nrstr:='12';
 randomize;
 nrm:=12;
 ta:=ptr($B800,0);
 tb:=ptr(mhmemaloc(sizeof(tb^)),0);
 if eraloc<>eranimic then
 begin
  writeln('Nu e memorie suficienta!');
  halt;
 end;
 inittext80x25;
 cursor(true);
 clipire(false);
 for y:=1 to 2 do
 for x:=1 to 12 do
 with jucatori[y,x] do
 begin
  case x of
   1: nume:='Liu Kang';
   2: nume:='Kung Lao';
   3: nume:='Johny Cage';
   4: nume:='Reptile';
   5: nume:='Sub Zero';
   6: nume:='Shang Tsung';
   7: nume:='Kitana';
   8: nume:='Jax Briggs';
   9: nume:='Mileena';
   10: nume:='Baraka';
   11: nume:='Scorpion';
   12: nume:='Raiden';
  end;
  ales:=false;
 end;
 for y:=1 to 2 do
 for x:=1 to 12 do
 alesi[y,x]:=jucatori[y,x].nume;
 repeat
  elimintasta;
  citesctasta;
  if tasta.citita then
  begin
   if tasta.zero then
   begin
    elimintasta;
   end else
   begin
    if tasta.cod=tesc then
    begin
     iesire:=true;
     elimintasta;
    end;
    if tasta.cod=tbkspace then
    begin
     eliminlitera(nrstr,length(nrstr));
     elimintasta;
    end;
    if tasta.citita then
    if(tasta.cod>=ord('0'))and(tasta.cod<=ord('9')) then
    nrstr:=nrstr+chr(tasta.cod);
    if tasta.cod=tenter then
    begin
     val(nrstr,t,z);
     if(t>=1)and(t<=12) then
     begin
      nrm:=t;
      recalculez;
     end;
     elimintasta;
    end;
   end;
  end;
  setchar(' ');
  setcharcolor(scriscol);
  setbaccolor(fillcol);
  bara80x25(tb,1,1,80,1);
  writestring80x25(tb,1,1,copyright,false,false,true);
  bara80x25(tb,1,25,80,25);
  str(nrm,s2);
  writestring80x25(tb,1,25,string2+' - Numar de meciuri: '+s2,false,false,true);
  setbaccolor(spatecol);
  bara80x25(tb,1,2,80,24);
  writestring80x25(tb,1,24,ajutor+nrstr,false,false,false);
  cursorto80x25(length(ajutor)+1+length(nrstr),24);
  for y:=1 to 2 do
  for x:=1 to nrm do
  writestring80x25(tb,(y-1)*35+5,x+5,alesi[y,x],false,false,false);
  ta^:=tb^;
 until iesire;
 inittext80x25;
end.