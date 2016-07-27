program mhbview;
uses dos,crt,mvbutilv,getpal1;
var a,b: ^ecran;
    f: file;
    c: char;
    sx,sy,x,y: integer;
    buf: array[1..33000] of char;
    an,ant: array[1..4] of char;
    n: namestr;
    ex: extstr;
    dir: dirstr;
    s: string;
    w: word;
    ar: array[1..2] of char;
    p: mvpal;

begin
 initgr;
 ant:='MHB6';
 if paramcount<>1 then
 begin
  closegr;
  writeln('MiValSoft MVB viewer');
  writeln('MHPVIEW <FISIER.MHP>');
  halt;
 end;
 {$I-}
 assign(f,paramstr(1));
 reset(f,1);
 if ioresult<>0 then
 begin
  closegr;
  writeln('Nu pot deschide fisierul ''',paramstr(1),'''!');
  halt;
 end;
 blockread(f,an,4,w);
 if an<>ant then
 begin
  closegr;
  writeln('Antet incorect!');
  halt;
 end;
 a:=ptr($A000,0);
 getmem(b,64000);
 blockread(f,sx,2,w);
 blockread(f,sy,2,w);
 if sx>320 then sx:=320;
 if sy>200 then sy:=200;
 setpal(normpal1);
 for y:=0 to sy-1 do
 begin
  blockread(f,b^[y,0],sx,w);
 end;
 close(f);
 copymvb(addr(b^),addr(a^),0,0,sx,sy,0,0);
 readkey;
 closegr;
 freemem(b,64000);
 writeln(sx,'X',sy,'X256');
 {$I+}
end.