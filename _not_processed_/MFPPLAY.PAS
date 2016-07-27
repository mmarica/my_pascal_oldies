uses mhpal,mhimg,tpkey;
var a: ^ecran;
    pal: mvpal;
    fv,nrframe,frame: longint;
    w: word;
    f: file;
    numef: string;
    inapoi,stop: boolean;
    viteza: byte;

begin
 viteza:=1;
 a:=ptr($A000,0);
 assign(f,paramstr(1));
 reset(f,1);
 nrframe:=trunc((filesize(f)-8)/64768);
 seek(f,8);
 initgr;
 frame:=0;
 repeat
  if frame<=nrframe then
  begin
   if port[$60]=77 then frame:=frame+viteza;
   if port[$60]=75 then frame:=frame-viteza;
   if port[$60]=13 then
   begin
    viteza:=viteza+1;
    repeat
    until port[$60]<>13;
   end;
   if port[$60]=12 then
   begin
    viteza:=viteza-1;
    repeat
    until port[$60]<>1;
   end;
   if viteza<1 then viteza:=1;
   if viteza>200 then viteza:=200;
   if port[$60]=81 then frame:=frame+100;
   if port[$60]=73 then frame:=frame-100;
   if port[$60]=25 then
   begin
    if stop then stop:=false else stop:=true;
    repeat
    until port[$60]<>25;
   end;
   if port[$60]=48 then
   begin
    if inapoi then inapoi:=false else inapoi:=true;
    repeat
    until port[$60]<>48;
   end;
   if not stop then
   begin
    if not inapoi then frame:=frame+viteza else frame:=frame-viteza;
   end;
   if frame<1 then frame:=1;
   if frame>nrframe then
   if stop then frame:=nrframe;
   if frame<>fv then
   begin
    seek(f,8+(frame-1)*64768);
    blockread(f,pal,768,w);
    blockread(f,a^,64000,w);
    setpal(pal);
   end;
   delay(55);
  end;
  while keypressed do readkey;
  fv:=frame;
 until (frame>nrframe)or(port[$60]=1);
 close(f);
 closegr;
end.