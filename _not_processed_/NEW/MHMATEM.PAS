unit mhmatem;
interface
var coss,sins: array[1..360] of real;

function rad(x: integer): real;
function cosv(u: integer): real;
function sinv(u: integer): real;
{procedure initcossin;}

implementation
var x: integer;

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
 for x:=1 to 360 do
 begin
  coss[x]:=cos(rad(x));
  sins[x]:=sin(rad(x));
 end;
end;

begin
 initcossin;
end.