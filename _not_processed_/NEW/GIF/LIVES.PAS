uses crt;
type pers = record
       nume : string;
       lives : byte;
       time  : byte;
     end;
var f : file of char;
    ch : char;
    p  : array[0..9] of pers;
    posf,i : longint;
    OK    : boolean;
begin
   repeat
   TextBackGround(Black);
   TextColor(LightGray);
   ClrScr;
   WriteLn('                   Infinite lives and time for PRINCE OF PERSIA 2');
   WriteLn('                                by I.P.SoftWare');
   WriteLn;
   WriteLn;
   WriteLn(' Select one position :');
   Assign(f,'PRINCE.SAV');
   Reset(f);
   for i:=0 to 9 do
       begin
          posf:=2+i*25;
          Seek(f, posf);
          ch:='A';  p[i].nume:='';
          while (Ord(ch)<>0) do
             begin
                Read(f, ch);
                if Ord(ch)<>0 then
                   p[i].nume:=p[i].nume+ch;
             end;
       end;
   for i:=0 to 9 do
       begin
          posf:=261+i*9623;
          Seek(f, posf);
          Read(f, ch);
          p[i].lives:=Ord(ch);
       end;
   for i:=0 to 9 do
       begin
          posf:=256+i*9623;
          Seek(f, posf);
          Read(f, ch);
          p[i].time:=Ord(ch);
       end;
   WriteLn;
   for i:=0 to 9 do
       begin
          GoToXY(2, WhereY); Write(i, '.');
          GoToXY(5, WhereY); Write(p[i].nume);
          GoToXY(20, WhereY); Write(p[i].lives, ' lives');
          GoToXY(30, WhereY); WriteLn(p[i].time, ' minutes');
       end;
   OK:=false;
   repeat
      ch:=ReadKey;
      if Ord(ch) = 27 then
         begin
            Close(f);
            ClrScr;
            WriteLn(' Good DOS . . .');
            Halt(0);
         end;
      if ch in ['0'..'9'] then
         OK:=true else
         begin
            Sound(700);
            Delay(70);
            NoSound;
         end;
   until OK;
   i:=Ord(ch)-Ord('0');
   GoToXY(2, 18); ClrEol;
   WriteLn(' How many lives do you want for ', p[i].nume, ' ?');
   ReadLn(p[i].lives);
   Seek(f, 261+9623*i);
   ch:=Chr(p[i].lives);
   Write(f, ch);
   WriteLn(' How many minutes do you want for ', p[i].nume, ' ?');
   ReadLn(p[i].time);
   Seek(f, 256+9623*i);
   ch:=Chr(p[i].time);
   Write(f, ch);
   Close(f);
   until false;
end.