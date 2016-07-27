unit mhdisk;
interface
uses dos;
type fattype=record
              sec_clust: byte;
              byte_sec: word;
              nrclust: word;
              identif: byte;
              valid: boolean;
             end;
const drv_a=1;
      drv_b=2;
      drv_c=3;
      drv_d=4;
      drv_e=5;
      drv_f=6;
      drv_g=7;
      drv_h=8;
      drv_i=9;
      drv_j=10;
      drv_k=11;
      drv_l=12;
      drv_m=13;
      drv_n=14;
      drv_o=15;
      drv_p=16;
      drv_q=17;
      drv_r=18;
      drv_s=19;
      drv_t=20;
      drv_u=21;
      drv_v=22;
      drv_w=23;
      drv_x=24;
      drv_y=25;
      drv_z=26;
      dskf_0=0;
      dskf_1=1;
      dskf_2=2;
      dskf_3=3;
      dskh_0=$80;
      dskh_1=$81;
      dskh_2=$82;
      dskh_3=$83;

function chdrive(drive: byte): byte;
function validdrive(drive: byte): boolean;
function getcurentdrive: byte;
function getsysdrive: byte;
function driveremov(drive: byte): boolean;
procedure getfatinf(drive: byte;var param: fattype);

implementation

function chdrive(drive: byte): byte;
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

function validdrive(drive: byte): boolean;
var r: registers;
begin
 validdrive:=false;
 r.ah:=$44;
 r.al:=$0e;
 r.bl:=drive;
 intr($21,r);
 if ((r.flags and fcarry)=0)and(r.al=0) then validdrive:=true else
 if ((r.flags and fcarry)=0)and(r.al>0)and(r.al=drive) then validdrive:=true;
end;

function getcurentdrive: byte;
var r: registers;
begin
 r.ah:=$19;
 intr($21,r);
 getcurentdrive:=r.al+1;
end;

function getsysdrive: byte;
var r: registers;
begin
 r.ah:=$33;
 r.al:=$05;
 intr($21,r);
 getsysdrive:=r.dl;
end;

function driveremov(drive: byte): boolean;
var r: registers;
begin
 driveremov:=false;
 r.ah:=$44;
 r.al:=$08;
 r.bl:=drive;
 intr($21,r);
 if ((r.flags and fcarry)=0)and(r.ax=0) then driveremov:=true;
end;

procedure getfatinf(drive: byte;var param: fattype);
var r: registers;
begin
 param.valid:=true;
 r.ah:=$1c;
 r.dl:=drive;
 intr($21,r);
 param.sec_clust:=r.al;
 param.byte_sec:=r.cx;
 param.nrclust:=r.dx;
 param.identif:=mem[r.ds:r.bx];
 if param.sec_clust=$ff then param.valid:=false;
end;

end.