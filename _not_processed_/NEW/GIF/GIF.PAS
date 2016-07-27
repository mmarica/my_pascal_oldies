program Gif;
{ GifUtil sample program
	(c)Copyright 1993 Sean Wenzel
	Users are given the right to freely use and distibute the source code at
	will as long a credit is given where due }

uses GifUtil, CRT, Dos;

var
	A: string;
	TheGif: PGif;
	Hours, Minutes, Seconds, Sec100: word;
	H, M, S, S100: word;
begin
	Writeln('Sample program for using GIFUTIL.PAS unit');
	Writeln('(c) Copyright 1993 Sean Wenzel');
	Writeln('');

	if ParamCount <> 1 then
	begin
		Writeln('use: C:>gif <gifname>[.gif] to run...');
		Exit;
	end;
	TheGif := New(PGif, Init(paramstr(1)));

	GetTime(Hours, Minutes, Seconds, Sec100);
	TheGif^.Decode(True);
	GetTime(H, M, S, S100);
	Readln(A);
	Dispose(TheGif, Done);

	Writeln('Start: ',Hours,':',Minutes,':',Seconds,':',Sec100);
	Writeln(' Stop: ',H,':',M,':',S,':',S100);
	while not(KeyPressed) do;

	writeln('"The Graphics Interchange Format(c) is the Copyright property of');
	writeln('CompuServe Incorporated. GIF(sm) is a Service Mark property of ');
	writeln('CompuServe Incorporated."');
end.