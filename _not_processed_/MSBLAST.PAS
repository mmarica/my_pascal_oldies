{$A+,B-,D+,E+,F+,G+,I+,L+,N-,O+,P+,Q+,R+,S+,T-,V+,X+,Y+}
{MSoft - Mihai Marica 2000
       Unit pentru Sound Blaster}
unit msblast;
interface
type threebit=0..7;
     nibble=0..15;
     inputsource=0..3;
     filterselect=0..7;
     voicemode=0..1;
const inpmicdefault=0;
      inpcdaudio=1;
      inpmicrophone=2;
      inplinein=3;
      lowfilter=0;
      highfilter=1;
      nofilter=4;
      mono=0;
      stereo=1;
      cmddirectdac=$10;
      cmddirectadc=$20;
      cmdspeakeron=$D1;
      cmdspeakeroff=$D3;
var baseaddrport: word;
    mixeraddrport: word;{baseaddrport+4}
    mixerdataport: word;{baseaddrport+5}
    resetport: word;{baseaddrport+6}
    readport: word;{baseaddrport+$A}
    writeport: word;{baseaddrport+$C}
    pollport: word;{baseaddrport+$E}
    sbirq: byte;
    sbdma: byte;
    sbdmacomplete: boolean; {True cand s-a terminat transferul DMA}

function readdsp: byte;
inline
(
 $BA/>pollport/         {MOV   DX, pollport  (constant)  }
 $EC/                   {IN    AL, DX                    }
 $24/$80/               {AND   AL, 80h                   }
 $74/$FB/               {JZ    -05                       }
 $BA/>readport/         {MOV   DX, readport  (constant)  }
 $EC                    {IN    AL,DX                     }
);
procedure writedsp(value: byte);
inline
(
 $BA/>writeport/        {MOV   DX, writeport (constant)  }
 $EC/                   {IN    AL, DX                    }
 $24/$80/               {AND   AL, 80h                   }
 $75/$FB/               {JNZ   -05                       }
 $58/                   {POP   AX                        }
 $BA/>writeport/        {MOV   DX, writeport (constant)  }
 $EE                    {OUT   DX, AL                    }
);
function resetdsp: boolean;
procedure turnspeakeron;
procedure turnspeakeroff;
function getsample: byte;
procedure outputsample(sample: byte);
procedure resetmixer;
procedure setmicvolume(volume: threebit);
procedure setinputsettings(source: inputsource;filter: filterselect);
procedure setoutputsettings(dnfi: boolean;mode: voicemode);
procedure setmastervolume(left,right: nibble);
procedure setvoicevolume(left,right: nibble);
procedure setfmvolume(left,right: nibble);
procedure setcdvolume(left,right: nibble);
procedure setlineinvolume(left,right: nibble);
procedure sbsetbaseaddrport(port: word);
procedure sbdetectbase(var baseaddr: word);
procedure sbsetirq(irq: byte);
procedure sbsetdmachannel(dma: byte);
procedure sbsamplebyte(var inbyte: byte);
procedure sbplaybyte(outbyte: byte);
procedure sbmakedmabuffer(var buffer: pointer;size: word);
procedure sbfreedmabuffer(buffer: pointer;size : word);
procedure sbinitdspdma(toggle: byte;rate: integer;datalength: word);
procedure sbsetinthandler;
procedure sbresetinthandler;
procedure sbplaydma(buffer: pointer;rate: word;length: word);
procedure sbsampledma(buffer: pointer;rate: word;length: word);
procedure sbstopdma;
procedure detectsbenv;

implementation
uses tpkey,memory,dos;
var sbint: byte;
    dmachannel: byte;
    oldinthandler: pointer;

function resetdsp: boolean;
var i: byte;
begin
 port[resetport]:=1;
 delay(1);
 port[resetport]:=0;
 i:=0;
 repeat
  inc(i);
 until (readdsp=$AA)or(i=100);
 if i<100 then resetdsp:=true else
 resetdsp:=false;
end;

procedure turnspeakeron;
begin
 writedsp(cmdspeakeron);
end;

procedure turnspeakeroff;
begin
 writedsp(cmdspeakeroff);
end;

function getsample: byte;
begin
 writedsp(cmddirectadc);
 getsample := Readdsp;
end;

procedure outputsample(sample: byte);
begin
 writedsp(cmddirectdac);
 writedsp(sample);
end;

procedure writemixer(register: byte;value: byte);
begin
 port[mixeraddrport]:=register;
 delay(1);
 port[mixerdataport]:=value;
 delay(1);
end;
function readmixer(register: byte): byte;
begin
 port[mixeraddrport]:=register;
 delay(1);
 readmixer:=port[mixerdataport];
 delay(1);
end;

procedure resetmixer;
begin
 writemixer($00,$FF);
 delay(10);
end;

procedure setmicvolume(volume: threebit);
begin
 writemixer($0A,volume);
end;

procedure setinputsettings(source: inputsource;filter: filterselect);
begin
 writemixer($0C,(source shl 1)+(filter shl 3));
end;

procedure setoutputsettings(dnfi: boolean;mode: voicemode);
var out: byte;
begin
 out:=0;
 if dnfi then out:=out+32;
 out:=out+(mode shl 1);
 writemixer($0E,out);
end;

procedure setmastervolume(left,right: nibble);
begin
 writemixer($22,(left shl 4)+right);
end;

procedure setvoicevolume(left,right: nibble);
begin
 writemixer($04,(left shl 4)+right);
end;

procedure setfmvolume(left,right: nibble);
begin
 writemixer($26,(left shl 4)+right);
end;

procedure setcdvolume(left,right: nibble);
begin
 writemixer($28,(left shl 4)+right);
end;

procedure setlineinvolume(left,right: nibble);
begin
 writemixer($2E,(left shl 4)+right);
end;

procedure sbsetbaseaddrport(port: word);
begin
 baseaddrport:=port;
 mixeraddrport:=baseaddrport+4;
 mixerdataport:=baseaddrport+5;
 resetport:=baseaddrport+6;
 readport:=baseaddrport+$A;
 writeport:=baseaddrport+$C;
 pollport:=baseaddrport+$E;
end;

procedure sbdetectbase(var baseaddr: word);
begin
 baseaddr:=$210;
 while ((baseaddr<$270)and(not(resetdsp))) do
 begin
  inc(baseaddr,$10);
  baseaddrport:=baseaddr;
 end;
 if (baseaddr=$270) then
 begin
  baseaddr:=0;
  baseaddrport:=0;
 end;
 sbsetbaseaddrport(baseaddrport);
end;

procedure sbsetirq(irq: byte);
begin
 sbint:=sbirq+8;
 sbirq:=irq;
end;

procedure sbsetdmachannel(dma: byte);
begin
 dmachannel:=sbdma;
 sbdma:=dma;
end;

procedure sbsamplebyte(var inbyte: byte);
{ Samples a single byte from the microphone input and returns it to InByte. }
{ *Note: The Sound Blaster speaker must be turned OFF for any data to be    }
{        sampled.                                                           }
{ Procedure to sample a byte of data :                                                              }
{     1. Standard poll to see if the Blaster is ready to receive data -     }
{        read the Write Buffer Status port (2xCh) until the MSB is 0.       }
{     2. Send 20h ("Read" command) to DSP Write Command port (2xCh).        }
{     3. Read the DSP Data Available port (2xEh) until MSB (bit 7) is set.  }
{        *Note how this differs from the standard SB ready polling.         }
{     4. The sampled byte is then ready. Read it from the DSP Read Data     }
{        port (2xAh).                                                       }
begin
 { Loop until SB ready to receive data. }
 repeat
 until ((port[writeport]and $80)=0);
 port[writeport]:=$20;          { Send 20h to port 2xCh.             }
 { Loop until bit 7 of port 2xEh is set. }
 repeat
 until ((port[pollport]and $80)>0);
 inbyte:=port[readport];        { Read data byte from port 2xAh.     }
end;

procedure sbplaybyte(outbyte: byte);
{ Sends OutByte through the Sound Blaster DAC.                              }
{ *Note: The sound blaster speaker must be turned ON for any sound to be    }
{        heard - this is done through the SBSpeaker procedure.             }
{ Procedure to output a byte of data :                                      }
{     1. Standard poll to see if the Blaster is ready to receive data -     }
{        read the Write Buffer Status port (2xCh) until the MSB is 0.       }
{     2. Write 10h ("Write" command) to DSP Write Command port (2xCh).      }
{     3. Poll again, same as in step 1, to wait to send data.               }
{     4. Send the data byte to the DSP Write Data port (2xCh).              }
begin
 { Loop until SB ready to receive data. }
 repeat
 until ((port[writeport]and $80)=0);
 port[writeport]:=$10;          { Send 10h to port 2xCh.             }
 { Loop until SB ready to receive data. }
 repeat
 until ((port[writeport]and $80)=0);
 port[writeport]:=outbyte;      { Send data byte to port 2xCh.       }
end;

procedure sbmakedmabuffer(var buffer: pointer;size: word);
{ Creates a buffer of Size paragraphs which does not cross a page boundary  }
{ and assigns Buffer to the start. If the required amount of memory is not  }
{ available, Buffer is assigned nil.                                        }
{ This uses MemAllocSeg instead of MemAlloc to make calculations simpler,   }
{ sacrificing a possible 15 bytes.                                          }
{ Theory: The DMA controller cannot transfer over memory page boundaries;   }
{ ie. It is limited to 0000:0000 - 0000:FFFF (page 0),1000:0000 - 1000:FFFF }
{ (page 1), etc. To avoid unnecessary hardship in the transfer routines,    }
{ the DMA buffer should be in a single page. This procedure finds the most  }
{ efficient location of that buffer.                                        }
{  (* DMAPORTS.TXT states DMA pages are 128k rather than 64k; I disagree.)  }
{                                                                           }
{ *Warning: The pointer returned is not static. If used in memory moves,    }
{           for example, segment and offset may be altered and it cannot be }
{           used properly. It might be a good idea to do something like:    }
{                 SBMakeDMABuffer(Buff,$800);                              }
{                 BuffSeg := Seg(Buff);                                     }
{                 BuffOfs := Ofs(Buff);                                     }
{  Before using:  Buff := Ptr(BuffSeg,BuffOfs);                             }
var beginseg,endseg: word;
    extramem: word;
    bufferext: pointer;
begin
 { Allocate required memory. (Size paragraphs=Size*10h bytes) }
 buffer:=memallocseg(size*$10);
 { Don't continue if MemAlloc was unable to allocate the memory. }
 if not(buffer=nil) then
 begin
  { Find the beginning and ending segments and offsets. }
  beginseg:=seg(buffer^);
  endseg:=beginseg+size;
  { Now - two possibilities: }
  {   1. The allocated memory lies entirely in the same page.  }
  {   2. The allocated memory crossed a page boundary.         }
  if ((beginseg and $1000)=(endseg and $1000)) then
  { Same page - no need to do anything more. }
  else  { Different pages - attempt to fix. }
  begin
   { Try to fix as follows:                            }
   {   1. Find out how much of the buffer lies in the  }
   {      first page.                                  }
   {   2. Allocate that much memory at the end of the  }
   {      buffer.                                      }
   {   3. It's possible that it was not allocated      }
   {      immediately after - admit defeat.            }
   {   4. If immediately after, assign the buffer to   }
   {      start of the second page.                    }
   extramem:=((endseg and $F000)-beginseg);
   bufferext:=memallocseg(extramem*$10);
   if (seg(bufferext^)=endseg)
   then  { Immediately after. }
   begin
    { A note about the next line - it frees   }
    { the unused memory in the first page.    }
    { This leaves a "hole" in memory and      }
    { subsequent calls may fail to allocate   }
    { a contiguous buffer because added       }
    { memory, if small enough, will fit in    }
    { the "hole". With very small or very     }
    { large buffers, it can be used (maximum  }
    { wasted memory is < 64K - not critical.) }
    { FreeMem(Buffer,ExtraMem*$10);  }
    buffer:=ptr((endseg and $F000),0);
   end else  { Somewhere else - return nil. }
   buffer := nil;
   { This really doesn't happen very often. If   }
   { desired, this portion could contain a       }
   { complex routine to find another contiguous  }
   { part of memory - too much trouble, I say.   }
   { Better to just use smaller buffers, or just }
   { avoid disposing of memory until the end     }
   { (to eliminate small "holes").               }
  end;
 end;
end;

procedure sbfreedmabuffer(buffer: pointer;size : word);
{ Releases Size paragraphs of memory referenced by Buffer.                  }
{ Make sure the value of Size is the exact amount used for SBMakeDMABuffer.}
{ Theory: Very simple. Use FreeMem to release the required amount of memory.}
{ (Size is in paragraphs, so adjust to a byte value in FreeMem.)            }
begin
 { Deallocate memory. (Size paragraphs=Size*10h bytes.) }
 freemem(buffer,size*$10);
 buffer := nil;
end;

procedure sbinitdma(toggle: byte;buffer: pointer;datalength: word);
{ Initializes the DMA controller for a transfer.                            }
{ Toggle=0 is record, else Toggle is play.                                  }
{ This procedure is not public and is called internally by SBPlayDMA and   }
{ SBSampleDMA.                                                             }
{ Refer to included file DMAPORTS.TXT for some details on initializing the  }
{ DMA ports.                                                                }
var dmapage: word;
    dmaofs: longint;
begin
 { Calculate what DMA page the buffer lies in. 1000:0000-1000:FFFF is  }
 { page 1, etc.                                                        }
 dmapage:=word(ofs(buffer^)shr 4);
 dmapage:=seg(buffer^)+dmapage;
 dmapage:=word(hi(dmapage)shr 4);
 { Calculate the offset within the DMA page.                           }
 dmaofs:=(seg(buffer^)and $0FFF)shl 4;
 dmaofs:=dmaofs+ofs(buffer^);
 dmaofs:=dmaofs mod $10000;
 port[$0A]:=dmachannel+4;          { Mask out DMA channel.           }
 port[$0C]:=0;                     { Clear byte pointer.             }
 if (toggle=0) then
 { Write function:                 }
 port[$0B] := $44+dmachannel   { Record.                         }
 else port[$0B] := $48+dmachannel;  { Play.                           }
 { Send low, then high byte of page offset. }
 port[(dmachannel shl 1)]:=byte(dmaofs and $00FF);
 port[(dmachannel shl 1)]:=byte(dmaofs shr 8);
 { Write DMA page. }
 case dmachannel of
  0: port[$87]:=byte(dmapage);
  1: port[$83]:=byte(dmapage);
  2: port[$81]:=byte(dmapage);
  3: port[$82]:=byte(dmapage);
 end;
 { Write the length-1 in low, high byte order. }
 port[(dmachannel shl 1)+1]:=lo(datalength-1);
 port[(dmachannel shl 1)+1]:=hi(datalength-1);
 port[$0A]:=dmachannel;            { Enable DMA channel.             }
end;

procedure sbinitdspdma(toggle: byte;rate: integer;datalength: word);
{ Initializes the Sound Blaster for a DMA transfer. Sampling or playback    }
{ starts immediately after this procedure.                                  }
{ Toggle=0 is record, otherwise play.                                       }
begin
 { All these Repeat-Until loops do a standard check to wait until the  }
 { Blaster is ready to receive a byte.                                 }
 repeat
 until ((port[writeport]and $80)=0);
 { Set the time constant. }
 port[writeport]:=$40;
 repeat
 until ((port[writeport]and $80)=0);
 { Write time constant = 256 - (1000000 / SamplingRate) }
 port[writeport]:=byte(trunc(256-(1000000/rate)));
 repeat
 until ((port[writeport]and $80)=0);
 if (toggle=0)               { Set card function:                    }
 then port[writeport]:=$24  { Record.                               }
 else port[writeport]:=$14; { Play.                                 }
 repeat
 until ((port[writeport]and $80)=0);
 { Low byte of length-1. }
 port[writeport]:=lo(datalength-1);
 repeat
 until ((port[writeport]and $80)=0);
 { High byte of length-1. }
 port[writeport]:=hi(datalength-1);
 { Sound Blaster DMA function starts now. When finished transfer, an   }
 { interrupt occurs.                                                   }
end;

{$F+}
procedure sbinthandler; interrupt;
{ Quick & dirty interrupt handler. When the DMA transfer completes, this    }
{ routine acknowledges the interrupt and sets the SBDMAComplete flag.      }
{ The interrupt handler must:                                               }
{     1. Preserve machine status (done automatically in Pascal).            }
{     2. Acknowledge the interrupt by reading from port 2xEh.               }
{     3. Carry out desired function (a flag is set in this example).        }
{     4. Reset interrupt controller (send 20h to port 20h).                 }
{     5. Restore machine status (again, done automatically by Pascal).      }
{     6. Terminated by an "IRET" instruction (handled by Pascal).           }
var inbyte: byte;
begin
 { Clear interrupt flag. Sometimes not necessary; take no chances.     }
 inline($FA);  { "cli" }
 inbyte:=port[pollport];        { Acknowledge interrupt (from 2xEh). }
 sbdmacomplete:=true;          { Set a flag to indicate DMA done.   }
 port[$20]:=$20;                { Reset interrupt controller.        }
 inline($FB);  { "sti" }
end;
{$F-}

procedure sbsetinthandler;
{ Replaces the interrupt corresponding to the Sound Blaster IRQ.            }
begin
 getintvec(sbint,oldinthandler);       { Save old handler.            }
 setintvec(sbint,@sbinthandler);      { Replace with custom handler. }
 sbdmacomplete:=false;
end;

procedure sbresetinthandler;
{ Sets the Sound Blaster interrupt back to its previous handler.            }
begin
 setintvec(sbint,oldinthandler);
end;

procedure sbplaydma(buffer: pointer;rate: word;length: word);
{ Output a buffer of data (of given Length) to the Sound Blaster using DMA  }
{ at Rate (in Hz).                                                          }
begin
 { Enable Sound Blaster IRQ on interrupt controller. }
 port[$21]:=port[$21] and not(1 shl(sbint-8));
 { Initialize the DMA controller. }
 sbinitdma(1,buffer,length);
 { Initialize Blaster for DMA transfer. }
 sbinitdspdma(1,rate,length);
 { Reset flag. }
 sbdmacomplete:=false;
end;

procedure sbsampledma(buffer: pointer;rate: word;length: word);
{ Read in a buffer of data (of given Length) from the Sound Blaster using   }
{ DMA at Rate (in Hz).                                                      }
{ ************** This procedure doesn't seem to work. Sorry. ************** }
{ The technique is probably wrong; nothing I can do about that.             }
begin
 { Enable Sound Blaster IRQ on interrupt controller. }
 port[$21]:=port[$21] and not(1 shl(sbint-8));
 { Initialize the DMA controller. }
 sbinitdma(0,buffer,length);
 { Initialize Blaster for DMA transfer. }
 sbinitdspdma(0,rate,length);
 { Reset flag. }
 sbdmacomplete:=false;
end;

procedure sbstopdma;
{ Stops the DMA transfer immediately.                                       }
begin
 port[$0A]:=4+dmachannel;
 port[$0C]:=0;
 port[$0A]:=0;
end;

procedure detectsbenv;
var envblast,temp: string;
    error,x: integer;
    dma,irq: byte;
    base: word;
begin
 envblast:=getenv('BLASTER');
 if envblast='' then exit;
 while envblast[0]<>#0 do
 begin
  while (envblast[1]=' ')and(envblast[0]<>#0) do
  delete(envblast,1,1);
  temp:='';
  while (envblast[1]<>' ')and(envblast[0]<>#0) do
  begin
   temp:=temp+envblast[1];
   delete(envblast,1,1);
  end;
  if temp[0]<>#0 then
  begin
   if (temp[1]='A')or(temp[1]='a') then
   begin
    delete(temp,1,1);
    temp:='$'+temp;
    val(temp,base,error);
    if error<>0 then base:=0;
   end;
   if (temp[1]='I')or(temp[1]='i') then
   begin
    delete(temp,1,1);
    val(temp,irq,error);
    if error<>0 then irq:=0;
   end;
   if (temp[1]='D')or(temp[1]='d') then
   begin
    delete(temp,1,1);
    val(temp,dma,error);
    if error<>0 then dma:=0;
   end;
  end;
 end;
 sbsetbaseaddrport(base);
 sbsetirq(irq);
 sbsetdmachannel(dma);
end;

begin
 sbdetectbase(baseaddrport);
 detectsbenv;
 sbsetirq(5);
 sbsetdmachannel(1);
 sbdmacomplete:=false;
end.