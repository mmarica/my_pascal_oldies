unit mhmem;
interface
uses dos;
const eranimic: byte=0;
      era0: byte=1;
      eramult: byte=2;
      erainsuf: byte=3;
      erdnimic: byte=0;
      erdincor: byte=1;
type vp=word;
var eraloc,erdealoc: byte;

function mhmemaloc(marime: longint): word;
procedure mhmemdealoc(poz: vp);

implementation

function mhmemaloc(marime: longint): word;
var r: registers;
    i,n: longint;
    w: word;
    fl: byte;
begin
 eraloc:=eranimic;
 if marime<=0 then
 begin
  eraloc:=era0;
  mhmemaloc:=0;
  exit;
 end;
 if marime>65536 then
 begin
  eraloc:=eramult;
  mhmemaloc:=0;
  exit;
 end;
 i:=trunc(marime/16);
 n:=marime mod 16;
 if n<>0 then i:=i+1;
 w:=i;
 r.ah:=$48;
 r.bx:=w;
 intr($21,r);
 if (r.flags and fcarry)<>0 then
 begin
  eraloc:=erainsuf;
  mhmemaloc:=0;
  exit;
 end;
 mhmemaloc:=r.ax;
end;

procedure mhmemdealoc(poz: vp);
var r: registers;
begin
 erdealoc:=erdnimic;
 r.ah:=$49;
 r.es:=poz;
 intr($21,r);
 if (r.flags and fcarry)<>0 then erdealoc:=erdincor;
end;

begin
end.