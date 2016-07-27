uses crt;
begin
 repeat
  writeln(port[$60]);
  delay(100);
 until port[$60]=1;
end.