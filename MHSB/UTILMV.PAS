unit utilmv;

interface
uses dos;
procedure setm(mode: byte);
procedure setmf(mode: byte);
function getm: byte;
procedure clip(on: boolean);
function MakeBinLong(s: string): longint;
function MakeHexWord(wordvariable: Word): string;
function bset (w: word; n: byte): word;
function bclear (w: word; n: byte): word;
function btest (w: word; n: byte): boolean;
function btestb (b: byte; n: byte): boolean;
function brol (w: word; n: byte): word;
function bror (w: word; n: byte): word;
procedure getdatem(var zi,luna,an,zis: integer);
procedure setdatem(var zi,luna,an: integer;var error: boolean);
procedure gettimem(var ora,minut,secunda,sutime: integer);
procedure settimem(var ora,minut,secunda,sutime: integer;var error: boolean);
procedure setverifym(on: boolean);
function getverifym: boolean;
procedure dosversionm(var vb,vs: byte;dos_oem: string);
function checkbreakm: boolean;
procedure setbreakm(on: boolean);
function sysorigdisk: char;
function indos: byte;
procedure getintvecm(intno:byte;var p: pointer);
procedure setintvecm(intno:byte;var p: pointer);
function mkdirm(s: string): byte;
function rmdirm(s: string): byte;
function chdirm(s: string): byte;
function getfattrm(s: string;var error: byte): byte;
function setfattrm(s: string;attr: byte): byte;
function erasem(s: string): byte;
function diskremov(disk: byte;var error: boolean): boolean;
procedure disklink(disk: byte;var subst,dist,diracc,error: boolean);
function dosreincdisk(nr: byte;wait: integer): byte;
function chdrive(drive: byte): byte;
function getcurdirm(drive: byte;error: boolean): string;
procedure biosinf(var mb,smb,rev: byte);
procedure soundm(hz: word);
procedure nosoundm;
procedure restart(test: boolean);
procedure cursor(afisare: boolean);

implementation

procedure setm;
var r: registers;
begin
 r.ah:=00;
 r.al:=mode;
 intr($10,r);
end;

procedure setmf;
var r: registers;
begin
 r.ah:=00;
 r.al:=mode+$80;
 intr($10,r);
end;

function getm;
var r: registers;
begin
 r.ah:=$0f;
 intr($10,r);
 getm:=r.al;
end;

procedure cursor(afisare: boolean);
var r: registers;
begin
 r.ah:=1;
 if afisare then
  begin
   r.ch:=6;
   r.cl:=7;
  end
 else
  begin
   r.ch:=32;
   r.cl:=7;
  end;
 intr($10,r);
end;

procedure clip;
var r: registers;
begin
 r.ah:=$10;
 r.al:=$03;
 if on then r.bl:=1 else r.bl:=0;
 intr($10,r);
end;

function MakeBinLong;
var n: longint;
    i, b, h: byte;
begin
n := 0;
b:=2;
for i := 1 to length(s) do
begin
 if s[i] <= '9'
  then h := ord(s[i]) - 48
  else h := ord(s[i]) - 55;
n := n * b + h;
end;
MakeBinLong:=n;
end;

function MakeHexWord(wordvariable: Word): string;
const
 hexChars: array [0..$F] of Char =
   '0123456789ABCDEF';
begin
 makehexword[1]:=hexChars[Hi(wordvariable) shr 4];
 makehexword[2]:=hexChars[Hi(wordvariable) and $F];
 makehexword[3]:=hexChars[Lo(wordvariable) shr 4];
 makehexword[4]:=hexChars[Lo(wordvariable) and $F];
 makehexword[0]:=#4;
end;

{Setarea bitului N al cuvantului W}
function bset;
var m: word;
begin
  m := 1 shl n;
  bset := w or m;
end;

{Stergerea bitului N al cuvantului W}
function bclear;
var m: word;
begin
  m := 1 shl n;
  bclear := w and (not m);
end;

{Testarea bitului N al cuvantului W. Daca acest bit este 1 atunci functia ia
valoarea true, altfel ia valoarea false}
function btest;
var m: word;
begin
  m := 1 shl n;
  btest := (w and m=m);
end;

function btestb;
var m: word;
begin
  m := 1 shl n;
  btestb := (b and m=m);
end;

{Rotirea cuvantului W cu N biti spre stanga}
function brol;
begin
  brol := (w shl n) or (w shr (16-n));
end;

{Rotirea cuvantului W cu N biti spre dreapta}
function bror;
begin
  bror := (w shr n) or (w shl (16-n));
end;

procedure getdatem;
var r: registers;
begin
r.ah:=$2A;
intr($21,r);
zis:=r.al;
zi:=r.dl;
luna:=r.dh;
an:=r.cx;
end;

procedure setdatem;
var r: registers;
begin
r.ah:=$2B;
r.cx:=an;
r.dh:=luna;
r.dl:=zi;
if r.ah=$FF then error:=true;
end;

procedure gettimem;
var r: registers;
begin
r.ah:=$2C;
intr($21,r);
ora:=r.ch;
minut:=r.cl;
secunda:=r.dh;
sutime:=r.dl;
end;

procedure settimem;
var r: registers;
begin
r.ah:=$2D;
r.ch:=ora;
r.cl:=minut;
r.dh:=secunda;
r.dl:=sutime;
if r.ah=$FF then error:=true;
end;

procedure setverifym;
var r: registers;
begin
r.ah:=$2E;
if on then r.al:=$01 else r.al:=$00;
intr($21,r);
end;

function getverifym;
var r: registers;
begin
r.ah:=$54;
intr($21,r);
if r.al=0 then getverifym:=false else getverifym:=true;
end;

procedure dosversionm;
var r: registers;
    oem: byte;
begin
r.ah:=$30;
r.al:=$00;
intr($21,r);
vb:=r.al;
vs:=r.ah;
oem:=r.bh;
if oem=$00 then dos_oem:='IBM' else
if oem=$01 then dos_oem:='Compaq' else
if oem=$02 then dos_oem:='Chit Microsoft' else
if oem=$04 then dos_oem:='AT&T' else
if oem=$05 then dos_oem:='Zenith' else
if oem=$06 then dos_oem:='Hewlett-Packard' else
if oem=$0D then dos_oem:='Packard-Bell' else
if oem=$16 then dos_oem:='DEC' else
if oem=$23 then dos_oem:='Olivetti' else
if oem=$29 then dos_oem:='Toshiba' else
if oem=$33 then dos_oem:='Novell' else
if (oem=$34)or(oem=$35) then dos_oem:='Microsoft Multimedia Systems' else
if oem=$4D then dos_oem:='Hewlett-Packard' else
if oem=$66 then dos_oem:='PhysTechSoft' else
if oem=$99 then dos_oem:='General Software' else
if oem=$FF then dos_oem:='Microsoft, Phoenix' else
dos_oem:='unknown';
end;

function checkbreakm;
var r: registers;
begin
r.ah:=$33;
r.al:=$00;
intr($21,r);
if r.dl=0 then checkbreakm:=false else checkbreakm:=true;
end;

procedure setbreakm;
var r: registers;
begin
r.ah:=$33;
r.al:=$01;
if on then r.dl:=$01 else r.dl:=$00;
intr($21,r);
end;

function sysorigdisk;
var r: registers;
begin
r.ah:=$33;
r.al:=$05;
intr($21,r);
sysorigdisk:=chr(ord('A')-1+r.dl);
end;

function indos;
var r: registers;
begin
r.ah:=$34;
intr($21,r);
indos:=mem[r.es:r.bx];
end;

procedure getintvecm;
var r: registers;
begin
r.ah:=$35;
r.al:=intno;
intr($21,r);
p:=ptr(r.es,r.bx);
end;

procedure setintvecm;
var r: registers;
begin
r.ah:=$25;
r.al:=intno;
r.ds:=seg(p);
r.dx:=ofs(p);
intr($21,r);
end;

function mkdirm;
var r: registers;
begin
r.ah:=$39;
s:=s+#0;
r.ds:=seg(s);
r.dx:=ofs(s)+1;
intr($21,r);
if (r.flags and fcarry)<>0 then
begin
if r.ax=3 then mkdirm:=3;
if r.ax=5 then mkdirm:=5;
end else
mkdirm:=0;
end;

function rmdirm;
var r: registers;
begin
r.ah:=$3A;
s:=s+#0;
r.ds:=seg(s);
r.dx:=ofs(s)+1;
intr($21,r);
if (r.flags and fcarry)<>0 then
begin
if r.ax=3 then rmdirm:=3;
if r.ax=5 then rmdirm:=5;
if r.ax=6 then rmdirm:=6;
end else
rmdirm:=0;
end;

function chdirm;
var r: registers;
begin
r.ah:=$3B;
s:=s+#0;
r.ds:=seg(s);
r.dx:=ofs(s)+1;
intr($21,r);
if (r.flags and fcarry)<>0 then
chdirm:=3 else chdirm:=0;
end;

function getfattrm;
var r: registers;
begin
r.ah:=$43;
r.al:=$00;
s:=s+#0;
r.ds:=seg(s);
r.dx:=ofs(s)+1;
intr($21,r);
getfattrm:=r.cx;
if (r.flags and fcarry)<>0 then
begin
if r.ax=1 then error:=1;
if r.ax=2 then error:=2;
if r.ax=3 then error:=3;
end else
error:=0;
end;

function setfattrm;
var r: registers;
begin
r.ah:=$43;
r.al:=$01;
s:=s+#0;
r.ds:=seg(s);
r.dx:=ofs(s)+1;
r.cx:=attr;
intr($21,r);
if (r.flags and fcarry)<>0 then
begin
if r.ax=1 then setfattrm:=1;
if r.ax=2 then setfattrm:=2;
if r.ax=3 then setfattrm:=3;
if r.ax=5 then setfattrm:=5;
end else
begin
setfattrm:=0;
end;
end;

function erasem;
var r: registers;
begin
setfattrm(s,$00);
r.ah:=$41;
s:=s+#0;
r.ds:=seg(s);
r.dx:=ofs(s)+1;
r.cx:=$00;
intr($21,r);
if (r.flags and fcarry)<>0 then
begin
if r.ax=2 then erasem:=2;
if r.ax=3 then erasem:=3;
if r.ax=5 then erasem:=5;
end else erasem:=0;
end;

function diskremov;
var r: registers;
    d: byte;
begin
if (disk<0)or(disk>26) then d:=0 else d:=disk;
r.ah:=$44;
r.al:=$08;
r.bl:=d;
intr($21,r);
if (r.flags and fcarry)<>0 then
error:=true
else error:=false;
if r.ax=$00 then diskremov:=true else diskremov:=false;
end;

procedure disklink;
var r: registers;
    d: byte;
begin
if (disk<0)or(disk>26) then d:=0 else d:=disk;
r.ah:=$44;
r.al:=$09;
r.bl:=d;
intr($21,r);
if (r.flags and fcarry)<>0 then
error:=true
else error:=false;
if btest(r.dx,15) then subst:=true else subst:=false;
if btest(r.dx,12) then dist:=true else dist:=false;
if btest(r.dx,9) then diracc:=false else diracc:=true;
end;

function dosreincdisk;
var r: registers;
begin
r.ah:=$44;
r.al:=$0B;
r.dx:=nr;
r.cx:=wait;
intr($21,r);
if (r.flags and fcarry)<>0 then
dosreincdisk:=1
else dosreincdisk:=0;
end;

function chdrive;
var r: registers;
    d: byte;
begin
if (drive<0)or(drive>26) then d:=0 else d:=drive;
r.ah:=$44;
r.al:=$0F;
r.bl:=d;
intr($21,r);
if (r.flags and fcarry)<>0 then
chdrive:=1
else chdrive:=0;
end;

function getcurdirm;
var r: registers;
    s: string;
    d: byte;
begin
if (drive<0)or(drive>26) then d:=0 else d:=drive;
r.ah:=$47;
r.dl:=d;
r.ds:=seg(s);
r.si:=ofs(s);
intr($21,r);
if (r.flags and fcarry)<>0 then
error:=true else error:=false;
getcurdirm:=s;
end;

procedure biosinf;
var r: registers;
begin
r.ah:=$C0;
intr($15,r);
mb:=mem[r.es:r.bx];
smb:=mem[r.es:r.bx+1];
rev:=mem[r.es:r.bx+2];
end;

procedure soundm;
var i: word;
begin
{port[67]:=$B6;
port[66]:=lo(hz);
port[66]:=hi(hz);
i:=port[97];
i:=i or 3;
port[97]:=i;}
end;

procedure nosoundm;
var i: word;
begin
i:=port[97];
i:=i and $FC;
port[97]:=i;
end;

procedure restart;
var l: longint;
    r: registers;
begin
r.ah:=0;
r.al:=3;
intr($10,r);
l:=$FFFF0000;
if not test then memw[seg0040:$0072]:=$1234 else memw[seg0040:$0072]:=$12;
asm
jmp l
end;
end;

end.