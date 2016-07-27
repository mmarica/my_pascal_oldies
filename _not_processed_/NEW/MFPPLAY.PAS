uses mhpal,mhimg,crt;
var a: ^ecran;
    pal: mvpal;
    w: word;
    f: file;
    numef: string;

begin
 a:=ptr($A000,0);
 assign(f,paramstr(1));
 reset(f,1);
 seek(f,8);
 initgr;
 repeat
  blockread(f,pal,768,w);
  blockread(f,a^,64000,w);
  setpal(pal);
 until eof(f) or keypressed;
 close(f);
 closegr;
end.