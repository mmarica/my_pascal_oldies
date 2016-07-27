{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,I+}
unit mhmatem;
interface
var coss,sins: array[1..360] of real;

function rad(x: integer): real;
function cosv(u: integer): real;
function sinv(u: integer): real;
procedure initcossin;

implementation
var x: integer;
    init: boolean;

function rad(x: integer): real;
begin
  rad := pi*x/180;
end;

function cosv(u: integer): real;
begin
 if u>360 then
 repeat
  u:=u-360
 until u<=360;
 if u<1 then
 repeat
  u:=u+360
 until u>=1;
 cosv:=coss[u];
end;

function sinv(u: integer): real;
begin
 if u>360 then
 repeat
  u:=u-360
 until u<=360;
 if u<1 then
 repeat
  u:=u+360
 until u>=1;
 sinv:=sins[u];
end;

procedure initcossin;
begin
 if init then exit;
 for x:=1 to 360 do
 begin
  coss[x]:=cos(rad(x));
  sins[x]:=sin(rad(x));
 end;
 init:=true;
end;

begin
 initcossin;
end.