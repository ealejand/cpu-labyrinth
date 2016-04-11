

List FileKey 
----------------------------------------------------------------------
C1      C2      C3      C4    || C5
--------------------------------------------------------------
C1:  Address (decimal) of instruction in source file. 
C2:  Segment (code or data) and address (in code or data segment) 
       of inforation associated with current linte. Note that not all
       source lines will contain information in this field.  
C3:  Opcode bits (this field only appears for valid instructions.
C4:  Data field; lists data for labels and assorted directives. 
C5:  Raw line from source code.
----------------------------------------------------------------------


(0001)                            || ;- Created by:
(0002)                            || ;-		Emil Alejandria
(0003)                            || ;-		Megan Durante
(0004)                            || ;- For:
(0005)                            || ;-		CPE 233
(0006)                            || ;-		Fall 2013
(0007)                            || 
(0008)                            || ;- Labyrinth 1.00	Patch Notes
(0009)                            || ;-	Functional drawDisplay implementation
(0010)                            || ;-	Functional getByte implementation
(0011)                            || ;-	Functional collision detection.
(0012)                            || ;-	Expanded map memory location allocation
(0013)                            || 
(0014)                            || ;- Labyrinth 1.00a	Patch Notes
(0015)                            || ;-	Code optimization
(0016)                            || ;-	Comments added
(0017)                            || 
(0018)                            || ;- Labyrinth 1.00b	Patch Notes
(0019)                            || ;-	Moved current location storage to memory from registers
(0020)                            || 
(0021)                            || ;- Labyrinth 1.00c	Patch Notes
(0022)                            || ;-	Added a victory screen
(0023)                            || 
(0024)                            || ;- Labyrinth 1.01	Patch Notes
(0025)                            || ;-	Added functional keys and doors
(0026)                            || 
(0027)                            || ;- Labyrinth 1.02	Patch Notes
(0028)                            || ;-	Added almost functional mob.
(0029)                            || ;-		Spontaneously jumps two spaces periodically
(0030)                            || ;-		RNG for movement unsatisfactory
(0031)                            || 
(0032)                            || ;- Labyrinth 1.02a	Patch Notes
(0033)                            || ;-	Added a death screen
(0034)                            || 
(0035)                            || ;- Future changes
(0036)                            || ;-	Destructible blocks
(0037)                            || ;-	Bombs
(0038)                            || ;-	Mobs
(0039)                            || ;---- ^ Good luck
(0040)                            || ;-	Health
(0041)                            || ;-	Timer
(0042)                            || ;---- ^ Stop trying
(0043)                            || 
(0044)                            || ;--------------------------------------------------------------------
(0045)                            || ; I/O Port Constants
(0046)                            || ;--------------------------------------------------------------------
(0047)                       064  || .EQU LEDS		= 0x40     ; LED array
(0048)                       129  || .EQU SSEG		= 0x81     ; 7-segment decoder 
(0049)                            || 
(0050)                       068  || .EQU PS2_KEY_CODE	= 0x44     ; ps2 data register
(0051)                            || 
(0052)                       144  || .EQU VGA_HADD	= 0x90     ; high address register
(0053)                       145  || .EQU VGA_LADD	= 0x91     ; low address register
(0054)                       146  || .EQU VGA_COLOR	= 0x92     ; color value register
(0055)                            || ;--------------------------------------------------------------------
(0056)                            || 
(0057)                            || ;--------------------------------------------------------------------
(0058)                            || ; Key Constants
(0059)                            || ;--------------------------------------------------------------------
(0060)                       029  || .EQU W			= 0x1D
(0061)                       028  || .EQU A			= 0x1C
(0062)                       027  || .EQU S			= 0x1B
(0063)                       035  || .EQU D			= 0x23
(0064)                       041  || .EQU SPAAACE	= 0x29
(0065)                            || ;--------------------------------------------------------------------
(0066)                            || 
(0067)                            || ;--------------------------------------------------------------------
(0068)                            || ; Color constants
(0069)                            || ;--------------------------------------------------------------------
(0070)                       000  || .EQU BLACK		= 0x00
(0071)                       224  || .EQU CRIMSON	= 0xE0
(0072)                       003  || .EQU BLUE		= 0x03
(0073)                       028  || .EQU GREEN		= 0x1C
(0074)                       074  || .EQU GREY		= 0x4A
(0075)                       072  || .EQU YELLOW		= 0x48
(0076)                       069  || .EQU BROWN		= 0x45
(0077)                            || ;--------------------------------------------------------------------
(0078)                            || 
(0079)                            || ;--------------------------------------------------------------------
(0080)                            || ;- Register Usage
(0081)                            || ;--------------------------------------------------------------------
(0082)                            || ;- r20					; current map shift
(0083)                            || ;- r21					; current x location
(0084)                            || ;- r22					; current y location
(0085)                            || ;- r1					; byte being pointed to
(0086)                            || ;--------------------------------------------------------------------
(0087)                            || 
(0088)                            || ;--------------------------------------------------------------------
(0089)                            || ;- Memory Allocation
(0090)                            || ;--------------------------------------------------------------------
(0091)                            || ;- 0x00					; display shift
(0092)                            || ;- 0x01					; display x-location
(0093)                            || ;- 0x02					; display y-location
(0094)                            || ;- 0x30 to 0x8F			; Map
(0095)                            || ;--------------------------------------------------------------------
(0096)                            || .DSEG
(0097)                       000  || .ORG 0x00
(0098)  DS-0x000             001  || 			.DB		0x06
(0099)  DS-0x001             001  || 			.DB		0x06
(0100)  DS-0x002             001  || 			.DB		0x06
(0101)  DS-0x003             003  || 			.DB		0x01, 0x01, 0x01
(0102)  DS-0x006             003  || 			.DB		0x04, 0x14, 0x0C
(0103)                            || 
(0104)                            || .CSEG
(0105)                       293  || .ORG 0x125
(0106)                            || 
(0107)                     0x125  || initialize:
-------------------------------------------------------------------------------------------
-STUP-  CS-0x000  0x36006  0x006  ||              MOV     r0,0x06     ; write dseg data to reg
-STUP-  CS-0x001  0x3A000  0x000  ||              LD      r0,0x00     ; place reg data in mem 
-STUP-  CS-0x002  0x36006  0x006  ||              MOV     r0,0x06     ; write dseg data to reg
-STUP-  CS-0x003  0x3A001  0x001  ||              LD      r0,0x01     ; place reg data in mem 
-STUP-  CS-0x004  0x36006  0x006  ||              MOV     r0,0x06     ; write dseg data to reg
-STUP-  CS-0x005  0x3A002  0x002  ||              LD      r0,0x02     ; place reg data in mem 
-STUP-  CS-0x006  0x36001  0x001  ||              MOV     r0,0x01     ; write dseg data to reg
-STUP-  CS-0x007  0x3A003  0x003  ||              LD      r0,0x03     ; place reg data in mem 
-STUP-  CS-0x008  0x36001  0x001  ||              MOV     r0,0x01     ; write dseg data to reg
-STUP-  CS-0x009  0x3A004  0x004  ||              LD      r0,0x04     ; place reg data in mem 
-STUP-  CS-0x00A  0x36001  0x001  ||              MOV     r0,0x01     ; write dseg data to reg
-STUP-  CS-0x00B  0x3A005  0x005  ||              LD      r0,0x05     ; place reg data in mem 
-STUP-  CS-0x00C  0x36004  0x004  ||              MOV     r0,0x04     ; write dseg data to reg
-STUP-  CS-0x00D  0x3A006  0x006  ||              LD      r0,0x06     ; place reg data in mem 
-STUP-  CS-0x00E  0x36014  0x014  ||              MOV     r0,0x14     ; write dseg data to reg
-STUP-  CS-0x00F  0x3A007  0x007  ||              LD      r0,0x07     ; place reg data in mem 
-STUP-  CS-0x010  0x3600C  0x00C  ||              MOV     r0,0x0C     ; write dseg data to reg
-STUP-  CS-0x011  0x3A008  0x008  ||              LD      r0,0x08     ; place reg data in mem 
-STUP-  CS-0x012  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x013  0x3A030  0x030  ||              LD      r0,0x30     ; place reg data in mem 
-STUP-  CS-0x014  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x015  0x3A031  0x031  ||              LD      r0,0x31     ; place reg data in mem 
-STUP-  CS-0x016  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x017  0x3A032  0x032  ||              LD      r0,0x32     ; place reg data in mem 
-STUP-  CS-0x018  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x019  0x3A033  0x033  ||              LD      r0,0x33     ; place reg data in mem 
-STUP-  CS-0x01A  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x01B  0x3A034  0x034  ||              LD      r0,0x34     ; place reg data in mem 
-STUP-  CS-0x01C  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x01D  0x3A035  0x035  ||              LD      r0,0x35     ; place reg data in mem 
-STUP-  CS-0x01E  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x01F  0x3A036  0x036  ||              LD      r0,0x36     ; place reg data in mem 
-STUP-  CS-0x020  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x021  0x3A037  0x037  ||              LD      r0,0x37     ; place reg data in mem 
-STUP-  CS-0x022  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x023  0x3A038  0x038  ||              LD      r0,0x38     ; place reg data in mem 
-STUP-  CS-0x024  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x025  0x3A039  0x039  ||              LD      r0,0x39     ; place reg data in mem 
-STUP-  CS-0x026  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x027  0x3A03A  0x03A  ||              LD      r0,0x3A     ; place reg data in mem 
-STUP-  CS-0x028  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x029  0x3A03B  0x03B  ||              LD      r0,0x3B     ; place reg data in mem 
-STUP-  CS-0x02A  0x360EE  0x0EE  ||              MOV     r0,0xEE     ; write dseg data to reg
-STUP-  CS-0x02B  0x3A03C  0x03C  ||              LD      r0,0x3C     ; place reg data in mem 
-STUP-  CS-0x02C  0x36020  0x020  ||              MOV     r0,0x20     ; write dseg data to reg
-STUP-  CS-0x02D  0x3A03D  0x03D  ||              LD      r0,0x3D     ; place reg data in mem 
-STUP-  CS-0x02E  0x36078  0x078  ||              MOV     r0,0x78     ; write dseg data to reg
-STUP-  CS-0x02F  0x3A03E  0x03E  ||              LD      r0,0x3E     ; place reg data in mem 
-STUP-  CS-0x030  0x3600F  0x00F  ||              MOV     r0,0x0F     ; write dseg data to reg
-STUP-  CS-0x031  0x3A03F  0x03F  ||              LD      r0,0x3F     ; place reg data in mem 
-STUP-  CS-0x032  0x360E0  0x0E0  ||              MOV     r0,0xE0     ; write dseg data to reg
-STUP-  CS-0x033  0x3A040  0x040  ||              LD      r0,0x40     ; place reg data in mem 
-STUP-  CS-0x034  0x3608B  0x08B  ||              MOV     r0,0x8B     ; write dseg data to reg
-STUP-  CS-0x035  0x3A041  0x041  ||              LD      r0,0x41     ; place reg data in mem 
-STUP-  CS-0x036  0x36002  0x002  ||              MOV     r0,0x02     ; write dseg data to reg
-STUP-  CS-0x037  0x3A042  0x042  ||              LD      r0,0x42     ; place reg data in mem 
-STUP-  CS-0x038  0x360EF  0x0EF  ||              MOV     r0,0xEF     ; write dseg data to reg
-STUP-  CS-0x039  0x3A043  0x043  ||              LD      r0,0x43     ; place reg data in mem 
-STUP-  CS-0x03A  0x360EE  0x0EE  ||              MOV     r0,0xEE     ; write dseg data to reg
-STUP-  CS-0x03B  0x3A044  0x044  ||              LD      r0,0x44     ; place reg data in mem 
-STUP-  CS-0x03C  0x360BB  0x0BB  ||              MOV     r0,0xBB     ; write dseg data to reg
-STUP-  CS-0x03D  0x3A045  0x045  ||              LD      r0,0x45     ; place reg data in mem 
-STUP-  CS-0x03E  0x360EE  0x0EE  ||              MOV     r0,0xEE     ; write dseg data to reg
-STUP-  CS-0x03F  0x3A046  0x046  ||              LD      r0,0x46     ; place reg data in mem 
-STUP-  CS-0x040  0x3600F  0x00F  ||              MOV     r0,0x0F     ; write dseg data to reg
-STUP-  CS-0x041  0x3A047  0x047  ||              LD      r0,0x47     ; place reg data in mem 
-STUP-  CS-0x042  0x360E0  0x0E0  ||              MOV     r0,0xE0     ; write dseg data to reg
-STUP-  CS-0x043  0x3A048  0x048  ||              LD      r0,0x48     ; place reg data in mem 
-STUP-  CS-0x044  0x36002  0x002  ||              MOV     r0,0x02     ; write dseg data to reg
-STUP-  CS-0x045  0x3A049  0x049  ||              LD      r0,0x49     ; place reg data in mem 
-STUP-  CS-0x046  0x36022  0x022  ||              MOV     r0,0x22     ; write dseg data to reg
-STUP-  CS-0x047  0x3A04A  0x04A  ||              LD      r0,0x4A     ; place reg data in mem 
-STUP-  CS-0x048  0x360AF  0x0AF  ||              MOV     r0,0xAF     ; write dseg data to reg
-STUP-  CS-0x049  0x3A04B  0x04B  ||              LD      r0,0x4B     ; place reg data in mem 
-STUP-  CS-0x04A  0x360FD  0x0FD  ||              MOV     r0,0xFD     ; write dseg data to reg
-STUP-  CS-0x04B  0x3A04C  0x04C  ||              LD      r0,0x4C     ; place reg data in mem 
-STUP-  CS-0x04C  0x360FE  0x0FE  ||              MOV     r0,0xFE     ; write dseg data to reg
-STUP-  CS-0x04D  0x3A04D  0x04D  ||              LD      r0,0x4D     ; place reg data in mem 
-STUP-  CS-0x04E  0x360A8  0x0A8  ||              MOV     r0,0xA8     ; write dseg data to reg
-STUP-  CS-0x04F  0x3A04E  0x04E  ||              LD      r0,0x4E     ; place reg data in mem 
-STUP-  CS-0x050  0x3600F  0x00F  ||              MOV     r0,0x0F     ; write dseg data to reg
-STUP-  CS-0x051  0x3A04F  0x04F  ||              LD      r0,0x4F     ; place reg data in mem 
-STUP-  CS-0x052  0x360E7  0x0E7  ||              MOV     r0,0xE7     ; write dseg data to reg
-STUP-  CS-0x053  0x3A050  0x050  ||              LD      r0,0x50     ; place reg data in mem 
-STUP-  CS-0x054  0x36010  0x010  ||              MOV     r0,0x10     ; write dseg data to reg
-STUP-  CS-0x055  0x3A051  0x051  ||              LD      r0,0x51     ; place reg data in mem 
-STUP-  CS-0x056  0x360AD  0x0AD  ||              MOV     r0,0xAD     ; write dseg data to reg
-STUP-  CS-0x057  0x3A052  0x052  ||              LD      r0,0x52     ; place reg data in mem 
-STUP-  CS-0x058  0x3605F  0x05F  ||              MOV     r0,0x5F     ; write dseg data to reg
-STUP-  CS-0x059  0x3A053  0x053  ||              LD      r0,0x53     ; place reg data in mem 
-STUP-  CS-0x05A  0x360E0  0x0E0  ||              MOV     r0,0xE0     ; write dseg data to reg
-STUP-  CS-0x05B  0x3A054  0x054  ||              LD      r0,0x54     ; place reg data in mem 
-STUP-  CS-0x05C  0x36005  0x005  ||              MOV     r0,0x05     ; write dseg data to reg
-STUP-  CS-0x05D  0x3A055  0x055  ||              LD      r0,0x55     ; place reg data in mem 
-STUP-  CS-0x05E  0x360A8  0x0A8  ||              MOV     r0,0xA8     ; write dseg data to reg
-STUP-  CS-0x05F  0x3A056  0x056  ||              LD      r0,0x56     ; place reg data in mem 
-STUP-  CS-0x060  0x3600F  0x00F  ||              MOV     r0,0x0F     ; write dseg data to reg
-STUP-  CS-0x061  0x3A057  0x057  ||              LD      r0,0x57     ; place reg data in mem 
-STUP-  CS-0x062  0x360E7  0x0E7  ||              MOV     r0,0xE7     ; write dseg data to reg
-STUP-  CS-0x063  0x3A058  0x058  ||              LD      r0,0x58     ; place reg data in mem 
-STUP-  CS-0x064  0x36010  0x010  ||              MOV     r0,0x10     ; write dseg data to reg
-STUP-  CS-0x065  0x3A059  0x059  ||              LD      r0,0x59     ; place reg data in mem 
-STUP-  CS-0x066  0x3608A  0x08A  ||              MOV     r0,0x8A     ; write dseg data to reg
-STUP-  CS-0x067  0x3A05A  0x05A  ||              LD      r0,0x5A     ; place reg data in mem 
-STUP-  CS-0x068  0x360AF  0x0AF  ||              MOV     r0,0xAF     ; write dseg data to reg
-STUP-  CS-0x069  0x3A05B  0x05B  ||              LD      r0,0x5B     ; place reg data in mem 
-STUP-  CS-0x06A  0x360FD  0x0FD  ||              MOV     r0,0xFD     ; write dseg data to reg
-STUP-  CS-0x06B  0x3A05C  0x05C  ||              LD      r0,0x5C     ; place reg data in mem 
-STUP-  CS-0x06C  0x360BA  0x0BA  ||              MOV     r0,0xBA     ; write dseg data to reg
-STUP-  CS-0x06D  0x3A05D  0x05D  ||              LD      r0,0x5D     ; place reg data in mem 
-STUP-  CS-0x06E  0x360EA  0x0EA  ||              MOV     r0,0xEA     ; write dseg data to reg
-STUP-  CS-0x06F  0x3A05E  0x05E  ||              LD      r0,0x5E     ; place reg data in mem 
-STUP-  CS-0x070  0x360AF  0x0AF  ||              MOV     r0,0xAF     ; write dseg data to reg
-STUP-  CS-0x071  0x3A05F  0x05F  ||              LD      r0,0x5F     ; place reg data in mem 
-STUP-  CS-0x072  0x360E0  0x0E0  ||              MOV     r0,0xE0     ; write dseg data to reg
-STUP-  CS-0x073  0x3A060  0x060  ||              LD      r0,0x60     ; place reg data in mem 
-STUP-  CS-0x074  0x36002  0x002  ||              MOV     r0,0x02     ; write dseg data to reg
-STUP-  CS-0x075  0x3A061  0x061  ||              LD      r0,0x61     ; place reg data in mem 
-STUP-  CS-0x076  0x36022  0x022  ||              MOV     r0,0x22     ; write dseg data to reg
-STUP-  CS-0x077  0x3A062  0x062  ||              LD      r0,0x62     ; place reg data in mem 
-STUP-  CS-0x078  0x360AF  0x0AF  ||              MOV     r0,0xAF     ; write dseg data to reg
-STUP-  CS-0x079  0x3A063  0x063  ||              LD      r0,0x63     ; place reg data in mem 
-STUP-  CS-0x07A  0x360EB  0x0EB  ||              MOV     r0,0xEB     ; write dseg data to reg
-STUP-  CS-0x07B  0x3A064  0x064  ||              LD      r0,0x64     ; place reg data in mem 
-STUP-  CS-0x07C  0x360FB  0x0FB  ||              MOV     r0,0xFB     ; write dseg data to reg
-STUP-  CS-0x07D  0x3A065  0x065  ||              LD      r0,0x65     ; place reg data in mem 
-STUP-  CS-0x07E  0x360AA  0x0AA  ||              MOV     r0,0xAA     ; write dseg data to reg
-STUP-  CS-0x07F  0x3A066  0x066  ||              LD      r0,0x66     ; place reg data in mem 
-STUP-  CS-0x080  0x3608F  0x08F  ||              MOV     r0,0x8F     ; write dseg data to reg
-STUP-  CS-0x081  0x3A067  0x067  ||              LD      r0,0x67     ; place reg data in mem 
-STUP-  CS-0x082  0x360E8  0x0E8  ||              MOV     r0,0xE8     ; write dseg data to reg
-STUP-  CS-0x083  0x3A068  0x068  ||              LD      r0,0x68     ; place reg data in mem 
-STUP-  CS-0x084  0x3608A  0x08A  ||              MOV     r0,0x8A     ; write dseg data to reg
-STUP-  CS-0x085  0x3A069  0x069  ||              LD      r0,0x69     ; place reg data in mem 
-STUP-  CS-0x086  0x36020  0x020  ||              MOV     r0,0x20     ; write dseg data to reg
-STUP-  CS-0x087  0x3A06A  0x06A  ||              LD      r0,0x6A     ; place reg data in mem 
-STUP-  CS-0x088  0x360EF  0x0EF  ||              MOV     r0,0xEF     ; write dseg data to reg
-STUP-  CS-0x089  0x3A06B  0x06B  ||              LD      r0,0x6B     ; place reg data in mem 
-STUP-  CS-0x08A  0x360EE  0x0EE  ||              MOV     r0,0xEE     ; write dseg data to reg
-STUP-  CS-0x08B  0x3A06C  0x06C  ||              LD      r0,0x6C     ; place reg data in mem 
-STUP-  CS-0x08C  0x360A0  0x0A0  ||              MOV     r0,0xA0     ; write dseg data to reg
-STUP-  CS-0x08D  0x3A06D  0x06D  ||              LD      r0,0x6D     ; place reg data in mem 
-STUP-  CS-0x08E  0x36086  0x086  ||              MOV     r0,0x86     ; write dseg data to reg
-STUP-  CS-0x08F  0x3A06E  0x06E  ||              LD      r0,0x6E     ; place reg data in mem 
-STUP-  CS-0x090  0x3600F  0x00F  ||              MOV     r0,0x0F     ; write dseg data to reg
-STUP-  CS-0x091  0x3A06F  0x06F  ||              LD      r0,0x6F     ; place reg data in mem 
-STUP-  CS-0x092  0x360E0  0x0E0  ||              MOV     r0,0xE0     ; write dseg data to reg
-STUP-  CS-0x093  0x3A070  0x070  ||              LD      r0,0x70     ; place reg data in mem 
-STUP-  CS-0x094  0x3608A  0x08A  ||              MOV     r0,0x8A     ; write dseg data to reg
-STUP-  CS-0x095  0x3A071  0x071  ||              LD      r0,0x71     ; place reg data in mem 
-STUP-  CS-0x096  0x360D0  0x0D0  ||              MOV     r0,0xD0     ; write dseg data to reg
-STUP-  CS-0x097  0x3A072  0x072  ||              LD      r0,0x72     ; place reg data in mem 
-STUP-  CS-0x098  0x360EF  0x0EF  ||              MOV     r0,0xEF     ; write dseg data to reg
-STUP-  CS-0x099  0x3A073  0x073  ||              LD      r0,0x73     ; place reg data in mem 
-STUP-  CS-0x09A  0x360FE  0x0FE  ||              MOV     r0,0xFE     ; write dseg data to reg
-STUP-  CS-0x09B  0x3A074  0x074  ||              LD      r0,0x74     ; place reg data in mem 
-STUP-  CS-0x09C  0x360BA  0x0BA  ||              MOV     r0,0xBA     ; write dseg data to reg
-STUP-  CS-0x09D  0x3A075  0x075  ||              LD      r0,0x75     ; place reg data in mem 
-STUP-  CS-0x09E  0x36015  0x015  ||              MOV     r0,0x15     ; write dseg data to reg
-STUP-  CS-0x09F  0x3A076  0x076  ||              LD      r0,0x76     ; place reg data in mem 
-STUP-  CS-0x0A0  0x360EF  0x0EF  ||              MOV     r0,0xEF     ; write dseg data to reg
-STUP-  CS-0x0A1  0x3A077  0x077  ||              LD      r0,0x77     ; place reg data in mem 
-STUP-  CS-0x0A2  0x360E0  0x0E0  ||              MOV     r0,0xE0     ; write dseg data to reg
-STUP-  CS-0x0A3  0x3A078  0x078  ||              LD      r0,0x78     ; place reg data in mem 
-STUP-  CS-0x0A4  0x36013  0x013  ||              MOV     r0,0x13     ; write dseg data to reg
-STUP-  CS-0x0A5  0x3A079  0x079  ||              LD      r0,0x79     ; place reg data in mem 
-STUP-  CS-0x0A6  0x360D4  0x0D4  ||              MOV     r0,0xD4     ; write dseg data to reg
-STUP-  CS-0x0A7  0x3A07A  0x07A  ||              LD      r0,0x7A     ; place reg data in mem 
-STUP-  CS-0x0A8  0x3600F  0x00F  ||              MOV     r0,0x0F     ; write dseg data to reg
-STUP-  CS-0x0A9  0x3A07B  0x07B  ||              LD      r0,0x7B     ; place reg data in mem 
-STUP-  CS-0x0AA  0x360EA  0x0EA  ||              MOV     r0,0xEA     ; write dseg data to reg
-STUP-  CS-0x0AB  0x3A07C  0x07C  ||              LD      r0,0x7C     ; place reg data in mem 
-STUP-  CS-0x0AC  0x360D6  0x0D6  ||              MOV     r0,0xD6     ; write dseg data to reg
-STUP-  CS-0x0AD  0x3A07D  0x07D  ||              LD      r0,0x7D     ; place reg data in mem 
-STUP-  CS-0x0AE  0x36015  0x015  ||              MOV     r0,0x15     ; write dseg data to reg
-STUP-  CS-0x0AF  0x3A07E  0x07E  ||              LD      r0,0x7E     ; place reg data in mem 
-STUP-  CS-0x0B0  0x360EF  0x0EF  ||              MOV     r0,0xEF     ; write dseg data to reg
-STUP-  CS-0x0B1  0x3A07F  0x07F  ||              LD      r0,0x7F     ; place reg data in mem 
-STUP-  CS-0x0B2  0x360E2  0x0E2  ||              MOV     r0,0xE2     ; write dseg data to reg
-STUP-  CS-0x0B3  0x3A080  0x080  ||              LD      r0,0x80     ; place reg data in mem 
-STUP-  CS-0x0B4  0x36000  0x000  ||              MOV     r0,0x00     ; write dseg data to reg
-STUP-  CS-0x0B5  0x3A081  0x081  ||              LD      r0,0x81     ; place reg data in mem 
-STUP-  CS-0x0B6  0x360F0  0x0F0  ||              MOV     r0,0xF0     ; write dseg data to reg
-STUP-  CS-0x0B7  0x3A082  0x082  ||              LD      r0,0x82     ; place reg data in mem 
-STUP-  CS-0x0B8  0x3600F  0x00F  ||              MOV     r0,0x0F     ; write dseg data to reg
-STUP-  CS-0x0B9  0x3A083  0x083  ||              LD      r0,0x83     ; place reg data in mem 
-STUP-  CS-0x0BA  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0BB  0x3A084  0x084  ||              LD      r0,0x84     ; place reg data in mem 
-STUP-  CS-0x0BC  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0BD  0x3A085  0x085  ||              LD      r0,0x85     ; place reg data in mem 
-STUP-  CS-0x0BE  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0BF  0x3A086  0x086  ||              LD      r0,0x86     ; place reg data in mem 
-STUP-  CS-0x0C0  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0C1  0x3A087  0x087  ||              LD      r0,0x87     ; place reg data in mem 
-STUP-  CS-0x0C2  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0C3  0x3A088  0x088  ||              LD      r0,0x88     ; place reg data in mem 
-STUP-  CS-0x0C4  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0C5  0x3A089  0x089  ||              LD      r0,0x89     ; place reg data in mem 
-STUP-  CS-0x0C6  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0C7  0x3A08A  0x08A  ||              LD      r0,0x8A     ; place reg data in mem 
-STUP-  CS-0x0C8  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0C9  0x3A08B  0x08B  ||              LD      r0,0x8B     ; place reg data in mem 
-STUP-  CS-0x0CA  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0CB  0x3A08C  0x08C  ||              LD      r0,0x8C     ; place reg data in mem 
-STUP-  CS-0x0CC  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0CD  0x3A08D  0x08D  ||              LD      r0,0x8D     ; place reg data in mem 
-STUP-  CS-0x0CE  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0CF  0x3A08E  0x08E  ||              LD      r0,0x8E     ; place reg data in mem 
-STUP-  CS-0x0D0  0x360FF  0x0FF  ||              MOV     r0,0xFF     ; write dseg data to reg
-STUP-  CS-0x0D1  0x3A08F  0x08F  ||              LD      r0,0x8F     ; place reg data in mem 
-STUP-  CS-0x0D2  0x36005  0x005  ||              MOV     r0,0x05     ; write dseg data to reg
-STUP-  CS-0x0D3  0x3A090  0x090  ||              LD      r0,0x90     ; place reg data in mem 
-STUP-  CS-0x0D4  0x36075  0x075  ||              MOV     r0,0x75     ; write dseg data to reg
-STUP-  CS-0x0D5  0x3A091  0x091  ||              LD      r0,0x91     ; place reg data in mem 
-STUP-  CS-0x0D6  0x3602A  0x02A  ||              MOV     r0,0x2A     ; write dseg data to reg
-STUP-  CS-0x0D7  0x3A092  0x092  ||              LD      r0,0x92     ; place reg data in mem 
-STUP-  CS-0x0D8  0x360E9  0x0E9  ||              MOV     r0,0xE9     ; write dseg data to reg
-STUP-  CS-0x0D9  0x3A093  0x093  ||              LD      r0,0x93     ; place reg data in mem 
-STUP-  CS-0x0DA  0x36040  0x040  ||              MOV     r0,0x40     ; write dseg data to reg
-STUP-  CS-0x0DB  0x3A094  0x094  ||              LD      r0,0x94     ; place reg data in mem 
-STUP-  CS-0x0DC  0x36007  0x007  ||              MOV     r0,0x07     ; write dseg data to reg
-STUP-  CS-0x0DD  0x3A095  0x095  ||              LD      r0,0x95     ; place reg data in mem 
-STUP-  CS-0x0DE  0x36055  0x055  ||              MOV     r0,0x55     ; write dseg data to reg
-STUP-  CS-0x0DF  0x3A096  0x096  ||              LD      r0,0x96     ; place reg data in mem 
-STUP-  CS-0x0E0  0x3602A  0x02A  ||              MOV     r0,0x2A     ; write dseg data to reg
-STUP-  CS-0x0E1  0x3A097  0x097  ||              LD      r0,0x97     ; place reg data in mem 
-STUP-  CS-0x0E2  0x3604D  0x04D  ||              MOV     r0,0x4D     ; write dseg data to reg
-STUP-  CS-0x0E3  0x3A098  0x098  ||              LD      r0,0x98     ; place reg data in mem 
-STUP-  CS-0x0E4  0x36040  0x040  ||              MOV     r0,0x40     ; write dseg data to reg
-STUP-  CS-0x0E5  0x3A099  0x099  ||              LD      r0,0x99     ; place reg data in mem 
-STUP-  CS-0x0E6  0x36002  0x002  ||              MOV     r0,0x02     ; write dseg data to reg
-STUP-  CS-0x0E7  0x3A09A  0x09A  ||              LD      r0,0x9A     ; place reg data in mem 
-STUP-  CS-0x0E8  0x36055  0x055  ||              MOV     r0,0x55     ; write dseg data to reg
-STUP-  CS-0x0E9  0x3A09B  0x09B  ||              LD      r0,0x9B     ; place reg data in mem 
-STUP-  CS-0x0EA  0x3602A  0x02A  ||              MOV     r0,0x2A     ; write dseg data to reg
-STUP-  CS-0x0EB  0x3A09C  0x09C  ||              LD      r0,0x9C     ; place reg data in mem 
-STUP-  CS-0x0EC  0x3604B  0x04B  ||              MOV     r0,0x4B     ; write dseg data to reg
-STUP-  CS-0x0ED  0x3A09D  0x09D  ||              LD      r0,0x9D     ; place reg data in mem 
-STUP-  CS-0x0EE  0x36000  0x000  ||              MOV     r0,0x00     ; write dseg data to reg
-STUP-  CS-0x0EF  0x3A09E  0x09E  ||              LD      r0,0x9E     ; place reg data in mem 
-STUP-  CS-0x0F0  0x36002  0x002  ||              MOV     r0,0x02     ; write dseg data to reg
-STUP-  CS-0x0F1  0x3A09F  0x09F  ||              LD      r0,0x9F     ; place reg data in mem 
-STUP-  CS-0x0F2  0x36077  0x077  ||              MOV     r0,0x77     ; write dseg data to reg
-STUP-  CS-0x0F3  0x3A0A0  0x0A0  ||              LD      r0,0xA0     ; place reg data in mem 
-STUP-  CS-0x0F4  0x36014  0x014  ||              MOV     r0,0x14     ; write dseg data to reg
-STUP-  CS-0x0F5  0x3A0A1  0x0A1  ||              LD      r0,0xA1     ; place reg data in mem 
-STUP-  CS-0x0F6  0x360E9  0x0E9  ||              MOV     r0,0xE9     ; write dseg data to reg
-STUP-  CS-0x0F7  0x3A0A2  0x0A2  ||              LD      r0,0xA2     ; place reg data in mem 
-STUP-  CS-0x0F8  0x36040  0x040  ||              MOV     r0,0x40     ; write dseg data to reg
-STUP-  CS-0x0F9  0x3A0A3  0x0A3  ||              LD      r0,0xA3     ; place reg data in mem 
-STUP-  CS-0x0FA  0x36002  0x002  ||              MOV     r0,0x02     ; write dseg data to reg
-STUP-  CS-0x0FB  0x3A0A4  0x0A4  ||              LD      r0,0xA4     ; place reg data in mem 
-STUP-  CS-0x0FC  0x360BA  0x0BA  ||              MOV     r0,0xBA     ; write dseg data to reg
-STUP-  CS-0x0FD  0x3A0A5  0x0A5  ||              LD      r0,0xA5     ; place reg data in mem 
-STUP-  CS-0x0FE  0x36099  0x099  ||              MOV     r0,0x99     ; write dseg data to reg
-STUP-  CS-0x0FF  0x3A0A6  0x0A6  ||              LD      r0,0xA6     ; place reg data in mem 
-STUP-  CS-0x100  0x360DD  0x0DD  ||              MOV     r0,0xDD     ; write dseg data to reg
-STUP-  CS-0x101  0x3A0A7  0x0A7  ||              LD      r0,0xA7     ; place reg data in mem 
-STUP-  CS-0x102  0x36080  0x080  ||              MOV     r0,0x80     ; write dseg data to reg
-STUP-  CS-0x103  0x3A0A8  0x0A8  ||              LD      r0,0xA8     ; place reg data in mem 
-STUP-  CS-0x104  0x36003  0x003  ||              MOV     r0,0x03     ; write dseg data to reg
-STUP-  CS-0x105  0x3A0A9  0x0A9  ||              LD      r0,0xA9     ; place reg data in mem 
-STUP-  CS-0x106  0x360AA  0x0AA  ||              MOV     r0,0xAA     ; write dseg data to reg
-STUP-  CS-0x107  0x3A0AA  0x0AA  ||              LD      r0,0xAA     ; place reg data in mem 
-STUP-  CS-0x108  0x36094  0x094  ||              MOV     r0,0x94     ; write dseg data to reg
-STUP-  CS-0x109  0x3A0AB  0x0AB  ||              LD      r0,0xAB     ; place reg data in mem 
-STUP-  CS-0x10A  0x36099  0x099  ||              MOV     r0,0x99     ; write dseg data to reg
-STUP-  CS-0x10B  0x3A0AC  0x0AC  ||              LD      r0,0xAC     ; place reg data in mem 
-STUP-  CS-0x10C  0x36040  0x040  ||              MOV     r0,0x40     ; write dseg data to reg
-STUP-  CS-0x10D  0x3A0AD  0x0AD  ||              LD      r0,0xAD     ; place reg data in mem 
-STUP-  CS-0x10E  0x36001  0x001  ||              MOV     r0,0x01     ; write dseg data to reg
-STUP-  CS-0x10F  0x3A0AE  0x0AE  ||              LD      r0,0xAE     ; place reg data in mem 
-STUP-  CS-0x110  0x3602A  0x02A  ||              MOV     r0,0x2A     ; write dseg data to reg
-STUP-  CS-0x111  0x3A0AF  0x0AF  ||              LD      r0,0xAF     ; place reg data in mem 
-STUP-  CS-0x112  0x36094  0x094  ||              MOV     r0,0x94     ; write dseg data to reg
-STUP-  CS-0x113  0x3A0B0  0x0B0  ||              LD      r0,0xB0     ; place reg data in mem 
-STUP-  CS-0x114  0x36091  0x091  ||              MOV     r0,0x91     ; write dseg data to reg
-STUP-  CS-0x115  0x3A0B1  0x0B1  ||              LD      r0,0xB1     ; place reg data in mem 
-STUP-  CS-0x116  0x36040  0x040  ||              MOV     r0,0x40     ; write dseg data to reg
-STUP-  CS-0x117  0x3A0B2  0x0B2  ||              LD      r0,0xB2     ; place reg data in mem 
-STUP-  CS-0x118  0x36001  0x001  ||              MOV     r0,0x01     ; write dseg data to reg
-STUP-  CS-0x119  0x3A0B3  0x0B3  ||              LD      r0,0xB3     ; place reg data in mem 
-STUP-  CS-0x11A  0x3603B  0x03B  ||              MOV     r0,0x3B     ; write dseg data to reg
-STUP-  CS-0x11B  0x3A0B4  0x0B4  ||              LD      r0,0xB4     ; place reg data in mem 
-STUP-  CS-0x11C  0x36099  0x099  ||              MOV     r0,0x99     ; write dseg data to reg
-STUP-  CS-0x11D  0x3A0B5  0x0B5  ||              LD      r0,0xB5     ; place reg data in mem 
-STUP-  CS-0x11E  0x360DD  0x0DD  ||              MOV     r0,0xDD     ; write dseg data to reg
-STUP-  CS-0x11F  0x3A0B6  0x0B6  ||              LD      r0,0xB6     ; place reg data in mem 
-STUP-  CS-0x120  0x36080  0x080  ||              MOV     r0,0x80     ; write dseg data to reg
-STUP-  CS-0x121  0x3A0B7  0x0B7  ||              LD      r0,0xB7     ; place reg data in mem 
-STUP-  CS-0x122  0x08928  0x100  ||              BRN     0x125        ; jump to start of .cseg in program mem 
-------------------------------------------------------------------------------------------
(0108)  CS-0x125  0x097F1         || 			CALL 	generateMap
(0109)  CS-0x126  0x08F49         || 			CALL	drawFrame			
(0110)  CS-0x127  0x08C49         || 			CALL	drawDisplay
(0111)  CS-0x128  0x1A000         || 			SEI
(0112)                            || 
(0113)                     0x129  || main:
(0114)  CS-0x129  0x38129         || 			LD		r1,0x29
(0115)  CS-0x12A  0x30101         || 			CMP		r1,0x01
(0116)  CS-0x12B  0x0894A         || 			BREQ	main
(0117)  CS-0x12C  0x38110         || 			LD		r1,0x10
(0118)  CS-0x12D  0x28101         || 			ADD		r1,0x01
(0119)  CS-0x12E  0x3A110         || 			ST		r1,0x10
(0120)  CS-0x12F  0x301FF         || 			CMP		r1,0xFF
(0121)  CS-0x130  0x0894B         || 			BRNE	main
(0122)  CS-0x131  0x36100         || 			MOV		r1,0x00
(0123)  CS-0x132  0x3A110         || 			ST		r1,0x10
(0124)  CS-0x133  0x38111         || 			LD		r1,0x11
(0125)  CS-0x134  0x28101         || 			ADD		r1,0x01
(0126)  CS-0x135  0x3A111         || 			ST		r1,0x11
(0127)  CS-0x136  0x301FF         || 			CMP		r1,0xFF
(0128)  CS-0x137  0x0894B         || 			BRNE	main
(0129)  CS-0x138  0x36100         || 			MOV		r1,0x00
(0130)  CS-0x139  0x3A111         || 			ST		r1,0x11
(0131)  CS-0x13A  0x38112         || 			LD		r1,0x12
(0132)  CS-0x13B  0x28101         || 			ADD		r1,0x01
(0133)  CS-0x13C  0x3A112         || 			ST		r1,0x12
(0134)  CS-0x13D  0x301FF         || 			CMP		r1,0xFF
(0135)  CS-0x13E  0x0894B         || 			BRNE	main
(0136)  CS-0x13F  0x36100         || 			MOV		r1,0x00
(0137)  CS-0x140  0x3A112         || 			ST		r1,0x12
(0138)  CS-0x141  0x38113         || 			LD		r1,0x13
(0139)  CS-0x142  0x28101         || 			ADD		r1,0x01
(0140)  CS-0x143  0x3A113         || 			ST		r1,0x13
(0141)  CS-0x144  0x08A50         || 			BRN		moveMob
(0142)  CS-0x145  0x301FF         || 			CMP		r1,0xFF
(0143)  CS-0x146  0x0894B         || 			BRNE	main
(0144)  CS-0x147  0x36100         || 			MOV		r1,0x00
(0145)  CS-0x148  0x3A113         || 			ST		r1,0x13
(0146)  CS-0x149  0x08948         || 			BRN		main
(0147)                            || 
(0148)                     0x14A  || moveMob:
(0149)  CS-0x14A  0x1A001         || 			CLI
(0150)  CS-0x14B  0x39406         || 			LD		r20,0x06
(0151)  CS-0x14C  0x39507         || 			LD		r21,0x07
(0152)  CS-0x14D  0x39608         || 			LD		r22,0x08
(0153)                            || 
(0154)                     0x14E  || RNGLOLNO:
(0155)  CS-0x14E  0x38202         || 			LD		r2,0x02
(0156)  CS-0x14F  0x0021A         || 			EXOR	r2,r3
(0157)  CS-0x150  0x10201         || 			LSR		r2
(0158)  CS-0x151  0x0AB10         || 			BRCS	checkUp
(0159)  CS-0x152  0x10201         || 			LSR		r2
(0160)  CS-0x153  0x0AB80         || 			BRCS	checkRight
(0161)  CS-0x154  0x10201         || 			LSR		r2
(0162)  CS-0x155  0x0AB38         || 			BRCS	checkLeft
(0163)  CS-0x156  0x10201         || 			LSR		r2
(0164)  CS-0x157  0x0ABC8         || 			BRCS	checkDown
(0165)  CS-0x158  0x10201         || 			LSR		r2
(0166)  CS-0x159  0x0AB10         || 			BRCS	checkUp
(0167)  CS-0x15A  0x10201         || 			LSR		r2
(0168)  CS-0x15B  0x0AB80         || 			BRCS	checkRight
(0169)  CS-0x15C  0x10201         || 			LSR		r2
(0170)  CS-0x15D  0x0AB38         || 			BRCS	checkLeft
(0171)  CS-0x15E  0x10201         || 			LSR		r2
(0172)  CS-0x15F  0x0ABC8         || 			BRCS	checkDown
(0173)  CS-0x160  0x1A000         || 			SEI
(0174)  CS-0x161  0x08948         || 			BRN		main
(0175)                            || 
(0176)                     0x162  || checkUp:
(0177)  CS-0x162  0x2D601         || 			SUB		r22,0x01
(0178)  CS-0x163  0x092B1         || 			CALL	getByte
(0179)  CS-0x164  0x11F00         || 			LSL		r31
(0180)  CS-0x165  0x0AB38         || 			BRCS	checkLeft
(0181)  CS-0x166  0x08C18         || 			BRN		moveMobDone
(0182)                     0x167  || checkLeft:
(0183)  CS-0x167  0x29601         || 			ADD		r22,0x01
(0184)  CS-0x168  0x2D501         || 			SUB		r21,0x01
(0185)  CS-0x169  0x2D401         || 			SUB		r20,0x01
(0186)  CS-0x16A  0x0AB61         || 			BRCC	checkLeftCont
(0187)  CS-0x16B  0x37407         || 			MOV		r20,0x07
(0188)                     0x16C  || checkLeftCont:
(0189)  CS-0x16C  0x092B1         || 			CALL	getByte
(0190)  CS-0x16D  0x11F00         || 			LSL		r31
(0191)  CS-0x16E  0x0AB80         || 			BRCS	checkRight
(0192)  CS-0x16F  0x08C18         || 			BRN		moveMobDone
(0193)                     0x170  || checkRight:
(0194)  CS-0x170  0x29502         || 			ADD		r21,0x02
(0195)  CS-0x171  0x29402         || 			ADD		r20,0x02
(0196)  CS-0x172  0x2D408         || 			SUB		r20,0x08
(0197)  CS-0x173  0x0ABA9         || 			BRCC	checkRightCont
(0198)  CS-0x174  0x29408         || 			ADD		r20,0x08
(0199)                     0x175  || checkRightCont:
(0200)  CS-0x175  0x092B1         || 			CALL	getByte
(0201)  CS-0x176  0x11F00         || 			LSL		r31
(0202)  CS-0x177  0x0ABC8         || 			BRCS	checkDown
(0203)  CS-0x178  0x08C18         || 			BRN		moveMobDone
(0204)                     0x179  || checkDown:
(0205)  CS-0x179  0x2D501         || 			SUB		r21,0x01
(0206)  CS-0x17A  0x2D401         || 			SUB		r20,0x01
(0207)  CS-0x17B  0x0ABE9         || 			BRCC	checkDownCont
(0208)  CS-0x17C  0x37407         || 			MOV		r20,0x07
(0209)                     0x17D  || checkDownCont:
(0210)  CS-0x17D  0x29601         || 			ADD		r22,0x01
(0211)  CS-0x17E  0x092B1         || 			CALL	getByte
(0212)  CS-0x17F  0x11F00         || 			LSL		r31
(0213)  CS-0x180  0x0AC19         || 			BRCC	moveMobDone
(0214)  CS-0x181  0x1A000         || 			SEI
(0215)  CS-0x182  0x08948         || 			BRN		main
(0216)                            || 
(0217)                     0x183  || moveMobDone:
(0218)  CS-0x183  0x3B406         || 			ST		r20,0x06
(0219)  CS-0x184  0x3B507         || 			ST		r21,0x07
(0220)  CS-0x185  0x3B608         || 			ST		r22,0x08
(0221)  CS-0x186  0x08C49         || 			CALL	drawDisplay
(0222)  CS-0x187  0x1A000         || 			SEI
(0223)  CS-0x188  0x08948         || 			BRN		main
(0224)                            || 
(0225)                            || ;--------------------------------------------------------------------
(0226)                            || ;- Subroutine: drawDisplay
(0227)                            || ;-	This subroutine iterates through each line of the display area
(0228)                            || ;-	and displays a byte generated by getByte. It then adds the blit
(0229)                            || ;-	to show the user's location.
(0230)                            || 
(0231)                            || ;- Modified registers:
(0232)                            || ;-	r7, r8, r6
(0233)                            || ;-	r23, r24, r25, r26, r27, r28, r30, r31 (getByte)
(0234)                            || ;--------------------------------------------------------------------
(0235)                     0x189  || drawDisplay:
(0236)  CS-0x189  0x39400         || 			LD		r20,0x00
(0237)  CS-0x18A  0x39602         || 			LD		r22,0x02
(0238)  CS-0x18B  0x36704         || 			MOV		r7,0x04
(0239)                            || 
(0240)                     0x18C  || drawDisplayLine:
(0241)  CS-0x18C  0x39501         || 			LD		r21,0x01
(0242)  CS-0x18D  0x36801         || 			MOV		r8,0x01
(0243)  CS-0x18E  0x092B1         || 			CALL	getByte
(0244)  CS-0x18F  0x2D501         || 			SUB		r21,0x01
(0245)  CS-0x190  0x08CD1         || 			CALL	drawByte
(0246)                            || 
(0247)  CS-0x191  0x29601         || 			ADD		r22,0x01
(0248)  CS-0x192  0x28703         || 			ADD		r7,0x03
(0249)  CS-0x193  0x30719         || 			CMP		r7,0x19
(0250)  CS-0x194  0x08C63         || 			BRNE	drawDisplayLine
(0251)                            || 
(0252)                     0x195  || drawLocation:
(0253)  CS-0x195  0x366E0         || 			MOV		r6,CRIMSON
(0254)  CS-0x196  0x3670D         || 			MOV		r7,0x0D
(0255)  CS-0x197  0x3680D         || 			MOV		r8,0x0D
(0256)  CS-0x198  0x09039         || 			CALL	drawBlit
(0257)                            || 			
(0258)                     0x199  || drawDisplayComplete:
(0259)  CS-0x199  0x18002         || 			RET
(0260)                            || 
(0261)                            || ;--------------------------------------------------------------------
(0262)                     0x19A  || drawByte:
(0263)  CS-0x19A  0x29501         || 			ADD		r21,0x01
(0264)  CS-0x19B  0x28803         || 			ADD		r8,0x03
(0265)  CS-0x19C  0x3081C         || 			CMP		r8,0x1C
(0266)  CS-0x19D  0x08EF2         || 			BREQ	drawByteDone
(0267)  CS-0x19E  0x18000         || 			CLC
(0268)  CS-0x19F  0x11F00         || 			LSL		r31
(0269)  CS-0x1A0  0x0AD21         || 			BRCC	checkMobs
(0270)  CS-0x1A1  0x3664A         ||             MOV     r6,GREY
(0271)  CS-0x1A2  0x09039         ||             CALL    drawBlit
(0272)  CS-0x1A3  0x08CD0         ||             BRN     drawByte
(0273)                     0x1A4  || checkMobs:
(0274)  CS-0x1A4  0x39807         || 			LD		r24,0x07
(0275)  CS-0x1A5  0x055C0         || 			CMP		r21,r24
(0276)  CS-0x1A6  0x08D7B         || 			BRNE	checkKeys
(0277)  CS-0x1A7  0x39808         || 			LD		r24,0x08
(0278)  CS-0x1A8  0x056C0         || 			CMP		r22,r24
(0279)  CS-0x1A9  0x08D7B         || 			BRNE	checkKeys
(0280)  CS-0x1AA  0x3661C         || 			MOV		r6,GREEN
(0281)  CS-0x1AB  0x09039         || 			CALL	drawBlit
(0282)  CS-0x1AC  0x36600         || 			MOV		r6,BLACK
(0283)  CS-0x1AD  0x090F1         || 			CALL	drawDot
(0284)  CS-0x1AE  0x08CD0         || 			BRN		drawByte
(0285)                     0x1AF  || checkKeys:
(0286)  CS-0x1AF  0x39803         || 			LD		r24,0x03
(0287)  CS-0x1B0  0x31801         || 			CMP		r24,0x01
(0288)  CS-0x1B1  0x08DBB         || 			BRNE	checkKey2
(0289)  CS-0x1B2  0x31518         || 			CMP		r21,0x18
(0290)  CS-0x1B3  0x08DBB         || 			BRNE	checkKey2
(0291)  CS-0x1B4  0x31608         || 			CMP		r22,0x08
(0292)  CS-0x1B5  0x08DBB         || 			BRNE	checkKey2
(0293)  CS-0x1B6  0x08F20         || 			BRN		drawKey
(0294)                     0x1B7  || checkKey2:
(0295)  CS-0x1B7  0x39804         || 			LD		r24,0x04
(0296)  CS-0x1B8  0x31801         || 			CMP		r24,0x01
(0297)  CS-0x1B9  0x08DFB         || 			BRNE	checkKey3
(0298)  CS-0x1BA  0x31517         || 			CMP		r21,0x17
(0299)  CS-0x1BB  0x08DFB         || 			BRNE	checkKey3
(0300)  CS-0x1BC  0x3160F         || 			CMP		r22,0x0F
(0301)  CS-0x1BD  0x08DFB         || 			BRNE	checkKey3
(0302)  CS-0x1BE  0x08F20         || 			BRN		drawKey
(0303)                     0x1BF  || checkKey3:
(0304)  CS-0x1BF  0x39805         || 			LD		r24,0x05
(0305)  CS-0x1C0  0x31801         || 			CMP		r24,0x01
(0306)  CS-0x1C1  0x08E3B         || 			BRNE	checkDoors
(0307)  CS-0x1C2  0x31508         || 			CMP		r21,0x08
(0308)  CS-0x1C3  0x08E3B         || 			BRNE	checkDoors
(0309)  CS-0x1C4  0x31612         || 			CMP		r22,0x12
(0310)  CS-0x1C5  0x08E3B         || 			BRNE	checkDoors
(0311)  CS-0x1C6  0x08F20         || 			BRN		drawKey
(0312)                     0x1C7  || checkDoors:
(0313)  CS-0x1C7  0x31609         || 			CMP		r22,0x09
(0314)  CS-0x1C8  0x08EDB         || 			BRNE	wipeByte
(0315)  CS-0x1C9  0x39803         || 			LD		r24,0x03
(0316)  CS-0x1CA  0x31801         || 			CMP		r24,0x01
(0317)  CS-0x1CB  0x08E7B         || 			BRNE	checkDoor2
(0318)  CS-0x1CC  0x31507         || 			CMP		r21,0x07
(0319)  CS-0x1CD  0x08E7B         || 			BRNE	checkDoor2
(0320)  CS-0x1CE  0x08EF8         || 			BRN		drawDoor
(0321)                     0x1CF  || checkDoor2:
(0322)  CS-0x1CF  0x39804         || 			LD		r24,0x04
(0323)  CS-0x1D0  0x31801         || 			CMP		r24,0x01
(0324)  CS-0x1D1  0x08EAB         || 			BRNE	checkDoor3
(0325)  CS-0x1D2  0x31506         || 			CMP		r21,0x06
(0326)  CS-0x1D3  0x08EAB         || 			BRNE	checkDoor3
(0327)  CS-0x1D4  0x08EF8         || 			BRN		drawDoor
(0328)                     0x1D5  || checkDoor3:
(0329)  CS-0x1D5  0x39805         || 			LD		r24,0x05
(0330)  CS-0x1D6  0x31801         || 			CMP		r24,0x01
(0331)  CS-0x1D7  0x08EDB         || 			BRNE	wipeByte
(0332)  CS-0x1D8  0x31505         || 			CMP		r21,0x05
(0333)  CS-0x1D9  0x08EDB         || 			BRNE	wipeByte
(0334)  CS-0x1DA  0x08EF8         || 			BRN		drawDoor
(0335)                            || 
(0336)                     0x1DB  || wipeByte:
(0337)  CS-0x1DB  0x36600         || 			MOV		r6,BLACK
(0338)  CS-0x1DC  0x09039         || 			CALL	drawBlit
(0339)  CS-0x1DD  0x08CD0         || 			BRN		drawByte
(0340)                     0x1DE  || drawByteDone:
(0341)  CS-0x1DE  0x18002         || 			RET
(0342)                     0x1DF  || drawDoor:
(0343)  CS-0x1DF  0x36645         || 			MOV		r6,BROWN
(0344)  CS-0x1E0  0x09039         || 			CALL	drawBlit
(0345)  CS-0x1E1  0x36648         || 			MOV		r6,YELLOW
(0346)  CS-0x1E2  0x090F1         || 			CALL	drawDot
(0347)  CS-0x1E3  0x08CD0         || 			BRN		drawByte
(0348)                     0x1E4  || drawKey:
(0349)  CS-0x1E4  0x36600         || 			MOV		r6,BLACK
(0350)  CS-0x1E5  0x09039         || 			CALL	drawBlit
(0351)  CS-0x1E6  0x36648         || 			MOV		r6,YELLOW
(0352)  CS-0x1E7  0x090F1         || 			CALL	drawDot
(0353)  CS-0x1E8  0x08CD0         || 			BRN		drawByte
(0354)                            || 			
(0355)                            || ;--------------------------------------------------------------------
(0356)                            || 
(0357)                            || ;--------------------------------------------------------------------
(0358)                            || ;- Subroutine: drawFram
(0359)                            || ;-	This subroutine draws the frame to hold the display area for our labyrinth.
(0360)                            || ;-	It uses drawHLine and drawVLine to draw a rectangle on the screen from
(0361)                            || ;-	(0x02, 0x02) to (0x1B, 0x1B). The color of the frame is blue.
(0362)                            || 
(0363)                            || ;- Modified registers:
(0364)                            || ;-	r6, r7, r8, r9
(0365)                            || ;--------------------------------------------------------------------
(0366)                     0x1E9  || drawFrame:
(0367)  CS-0x1E9  0x36603         || 			MOV		r6,BLUE		; pick a color
(0368)                            || 
(0369)  CS-0x1EA  0x36702         || 			MOV		r7,0x02		; y-coordinate
(0370)  CS-0x1EB  0x36802         || 			MOV		r8,0x02		; x-coordinate low
(0371)  CS-0x1EC  0x3691B         || 			MOV		r9,0x1B		; x-coordinate high
(0372)  CS-0x1ED  0x08FD9         || 			CALL	drawHLine
(0373)  CS-0x1EE  0x36702         || 			MOV		r7,0x02		; x-coordinate
(0374)  CS-0x1EF  0x36802         || 			MOV		r8,0x02		; y-coordinate low
(0375)  CS-0x1F0  0x36918         || 			MOV		r9,0x18		; y-coordinate high
(0376)  CS-0x1F1  0x09009         || 			CALL	drawVLine
(0377)  CS-0x1F2  0x36702         || 			MOV		r7,0x02		; y-coordinate low
(0378)  CS-0x1F3  0x3681B         || 			MOV		r8,0x1B		; x-coordinate 
(0379)  CS-0x1F4  0x36918         || 			MOV		r9,0x18		; y-coordinate high
(0380)  CS-0x1F5  0x09009         || 			CALL	drawVLine
(0381)  CS-0x1F6  0x36718         || 			MOV		r7,0x18		; y-coordinate
(0382)  CS-0x1F7  0x36802         || 			MOV		r8,0x02		; x-coordinate low
(0383)  CS-0x1F8  0x3691B         || 			MOV		r9,0x1B		; x-coordinate high
(0384)  CS-0x1F9  0x08FD9         || 			CALL	drawHLine
(0385)                            || 
(0386)  CS-0x1FA  0x18002         || 			RET
(0387)                            || ;--------------------------------------------------------------------
(0388)                            || 
(0389)                            || ;--------------------------------------------------------------------
(0390)                            || ;-  Subroutine: drawHLine
(0391)                            || ;-
(0392)                            || ;-  Draws a horizontal line from (r8,r7) to (r9,r7) using color in r6
(0393)                            || ;-
(0394)                            || ;-  Parameters:
(0395)                            || ;-   r6  = color used for line
(0396)                            || ;-   r7  = y-coordinate
(0397)                            || ;-   r8  = starting x-coordinate
(0398)                            || ;-   r9  = ending x-coordinate
(0399)                            || ;- 
(0400)                            || ;- Tweaked registers: r8,r9
(0401)                            || ;--------------------------------------------------------------------
(0402)                     0x1FB  || drawHLine:
(0403)  CS-0x1FB  0x28901         ||         ADD    r9,0x01          ; go from r8 to r9 inclusive
(0404)                            || 
(0405)                     0x1FC  || drawHLoop:
(0406)  CS-0x1FC  0x090F1         ||         CALL   drawDot         ; draw tile
(0407)  CS-0x1FD  0x28801         ||         ADD    r8,0x01          ; increment column (X) count
(0408)  CS-0x1FE  0x04848         ||         CMP    r8,r9            ; see if there are more columns
(0409)  CS-0x1FF  0x08FE3         ||         BRNE   drawHLoop      ; branch if more columns
(0410)  CS-0x200  0x18002         ||         RET
(0411)                            || ;--------------------------------------------------------------------
(0412)                            || 
(0413)                            || 
(0414)                            || ;---------------------------------------------------------------------
(0415)                            || ;-  Subroutine: drawVLine
(0416)                            || ;-
(0417)                            || ;-  Draws a horizontal line from (r8,r7) to (r8,r9) using color in r6
(0418)                            || ;-
(0419)                            || ;-  Parameters:
(0420)                            || ;-   r6  = color used for line
(0421)                            || ;-   r7  = starting y-coordinate
(0422)                            || ;-   r8  = x-coordinate
(0423)                            || ;-   r9  = ending y-coordinate
(0424)                            || ;- 
(0425)                            || ;- Tweaked registers: r7,r9
(0426)                            || ;--------------------------------------------------------------------
(0427)                     0x201  || drawVLine:
(0428)  CS-0x201  0x28901         ||          ADD    r9,0x01         ; go from r7 to r9 inclusive
(0429)                            || 
(0430)                     0x202  || drawVLoop:          
(0431)  CS-0x202  0x090F1         ||          CALL   drawDot        ; draw tile
(0432)  CS-0x203  0x28701         ||          ADD    r7,0x01         ; increment row (y) count
(0433)  CS-0x204  0x04748         ||          CMP    r7,r9           ; see if there are more rows
(0434)  CS-0x205  0x09013         ||          BRNE   drawVLoop      ; branch if more rows
(0435)  CS-0x206  0x18002         ||          RET
(0436)                            || ;--------------------------------------------------------------------
(0437)                            || 
(0438)                            || ;--------------------------------------------------------------------
(0439)                            || ;- Subroutine: Draw_blit
(0440)                            || ;- 
(0441)                            || ;- The subroutine draws a 3x3 square centered at the
(0442)                            || ;- values in (r8,r7) <==> (x,y). The center of this
(0443)                            || ;- 3x3 is green; the outside edges are blue. 
(0444)                            || ;- 
(0445)                            || ;- Tweaked Registers:
(0446)                            || ;--------------------------------------------------------------------
(0447)                     0x207  || drawBlit: 
(0448)  CS-0x207  0x12701         ||          PUSH	r7       ; save current y location
(0449)  CS-0x208  0x12801         ||          PUSH	r8       ; save current x location
(0450)                            || 
(0451)  CS-0x209  0x090F1         ||          CALL  drawDot     ; draw center
(0452)                            || 
(0453)  CS-0x20A  0x2C701         ||          SUB   r7,0x01      ; adjust coordinates
(0454)  CS-0x20B  0x2C801         ||          SUB   r8,0x01
(0455)  CS-0x20C  0x090F1         ||          CALL  drawDot     ; NW pixel 
(0456)  CS-0x20D  0x28801         ||          ADD   r8,0x01      ; adjust coordinates
(0457)  CS-0x20E  0x090F1         ||          CALL  drawDot     ; N pixel
(0458)  CS-0x20F  0x28801         ||          ADD   r8,0x01      ; adjust coordinates
(0459)  CS-0x210  0x090F1         ||          CALL  drawDot     ; NE pixel
(0460)                            ||          
(0461)  CS-0x211  0x28701         ||          ADD   r7,0x01      ; adjust coordinates
(0462)  CS-0x212  0x090F1         ||          CALL  drawDot     ; E pixel
(0463)  CS-0x213  0x2C802         ||          SUB   r8,0x02      ; adjust coordinates
(0464)  CS-0x214  0x090F1         ||          CALL  drawDot     ; W pixel
(0465)                            || 
(0466)  CS-0x215  0x28701         ||          ADD   r7,0x01      ; adjust coordinates
(0467)  CS-0x216  0x090F1         ||          CALL  drawDot     ; SW pixel
(0468)  CS-0x217  0x28801         ||          ADD   r8,0x01      ; adjust coordinates
(0469)  CS-0x218  0x090F1         ||          CALL  drawDot     ; S pixel
(0470)  CS-0x219  0x28801         ||          ADD   r8,0x01      ; adjust coordinates
(0471)  CS-0x21A  0x090F1         ||          CALL  drawDot     ; SE pixel
(0472)                            || 
(0473)  CS-0x21B  0x12802         ||          POP	r8       ; restore current y location
(0474)  CS-0x21C  0x12702         ||          POP	r7       ; restore current x location
(0475)  CS-0x21D  0x18002         ||          RET                ; later dude
(0476)                            || ;--------------------------------------------------------------------
(0477)                            || 
(0478)                            || ;--------------------------------------------------------------------
(0479)                            || ;- Subrountine: drawDot
(0480)                            || ;- 
(0481)                            || ;- This subroutine draws a dot on the display the given coordinates: 
(0482)                            || ;- 
(0483)                            || ;- (X,Y) = (r8,r7)  with a color stored in r6  
(0484)                            || ;- 
(0485)                            || ;- Tweaked registers: r4,r5
(0486)                            || ;--------------------------------------------------------------------
(0487)                     0x21E  || drawDot: 
(0488)  CS-0x21E  0x04109         || 			MOV		r1,r1
(0489)  CS-0x21F  0x04439         ||            MOV	 r4,r7         ; copy Y coordinate
(0490)  CS-0x220  0x2041F         ||            AND   r4,0x1F       ; make sure top 3 bits cleared
(0491)                            || 
(0492)  CS-0x221  0x04541         ||            MOV	 r5,r8         ; copy X coordinate
(0493)  CS-0x222  0x2053F         ||            AND   r5,0x3F       ; make sure top 2 bits cleared
(0494)                            || 
(0495)  CS-0x223  0x10401         ||            LSR   r4            ; need to get the bot 2 bits of r4 into sA
(0496)  CS-0x224  0x0B158         ||            BRCS  dd_add40
(0497)                            || 
(0498)  CS-0x225  0x10401  0x225  || t1:        LSR   r4
(0499)  CS-0x226  0x0B170         ||            BRCS  dd_add80
(0500)                            || 
(0501)  CS-0x227  0x34591  0x227  || dd_out:    OUT   r5,VGA_LADD   ; write bot 8 address bits to register
(0502)  CS-0x228  0x34490         ||            OUT   r4,VGA_HADD   ; write top 3 address bits to register
(0503)  CS-0x229  0x34692         ||            OUT   r6,VGA_COLOR  ; write data to frame buffer
(0504)  CS-0x22A  0x18002         ||            RET
(0505)                            || 
(0506)  CS-0x22B  0x22540  0x22B  || dd_add40:  OR    r5,0x40       ; set bit if needed
(0507)  CS-0x22C  0x18000         ||            CLC                 ; freshen bit
(0508)  CS-0x22D  0x09128         ||            BRN   t1             
(0509)                            || 
(0510)  CS-0x22E  0x22580  0x22E  || dd_add80:  OR    r5,0x80       ; set bit if needed
(0511)  CS-0x22F  0x09138         ||            BRN   dd_out
(0512)                            || 
(0513)                            || ;--------------------------------------------------------------------
(0514)                            || 
(0515)                     0x230  || drawScreen:
(0516)  CS-0x230  0x366FF         || 		MOV		r6,0xFF
(0517)  CS-0x231  0x3670E         || 		MOV		r7,0x0E
(0518)  CS-0x232  0x368FF         || 		MOV		r8,0xFF
(0519)  CS-0x233  0x36A08         || 		MOV		r10,0x08
(0520)  CS-0x234  0x05FF2         || 		LD		r31,(r30)
(0521)                            || 
(0522)                     0x235  || drawWinLoop:
(0523)  CS-0x235  0x28801         || 		ADD		r8,0x01
(0524)  CS-0x236  0x2CA01         || 		SUB		r10,0x01
(0525)  CS-0x237  0x11F00         || 		LSL		r31
(0526)  CS-0x238  0x0B1D1         || 		BRCC	drawWinNext1
(0527)  CS-0x239  0x090F1         || 		CALL	drawDot
(0528)                            || 
(0529)                     0x23A  || drawWinNext1:	
(0530)  CS-0x23A  0x30A00         || 		CMP		r10,0x00
(0531)  CS-0x23B  0x091FB         || 		BRNE	drawWinNext2
(0532)  CS-0x23C  0x36A08         || 		MOV		r10,0x08
(0533)  CS-0x23D  0x29E01         || 		ADD		r30,0x01
(0534)  CS-0x23E  0x05FF2         || 		LD		r31,(r30)
(0535)                            || 
(0536)                     0x23F  || drawWinNext2:
(0537)  CS-0x23F  0x30827         || 		CMP		r8,0x27
(0538)  CS-0x240  0x091AB         || 		BRNE	drawWinLoop
(0539)  CS-0x241  0x28701         || 		ADD		r7,0x01
(0540)  CS-0x242  0x30712         || 		CMP		r7,0x12
(0541)  CS-0x243  0x09232         || 		BREQ	drawWinDone
(0542)  CS-0x244  0x368FF         || 		MOV		r8,0xFF
(0543)  CS-0x245  0x091A8         || 		BRN		drawWinLoop
(0544)                            || 
(0545)                     0x246  || drawWinDone:
(0546)  CS-0x246  0x1A001         || 		CLI
(0547)  CS-0x247  0x18002         || 		RET
(0548)                            || 
(0549)                            || ;---------------------------------------------------------------------
(0550)                            || ;-  Subroutine: draw_background
(0551)                            || ;-
(0552)                            || ;-  Fills the 30x40 grid with one color using successive calls to 
(0553)                            || ;-  draw_horizontal_line subroutine. 
(0554)                            || ;- 
(0555)                            || ;-  Tweaked registers: r13,r7,r8,r9
(0556)                            || ;---------------------------------------------------------------------
(0557)                     0x248  || clearScreen: 
(0558)  CS-0x248  0x12701         ||          PUSH  r7                       ; save registers
(0559)  CS-0x249  0x12801         ||          PUSH  r8
(0560)  CS-0x24A  0x36600         ||          MOV   r6,BLACK	                ; use default color
(0561)  CS-0x24B  0x36D00         ||          MOV   r13,0x00                 ; r13 keeps track of rows
(0562)  CS-0x24C  0x04769  0x24C  || start:   MOV   r7,r13                   ; load current row count 
(0563)  CS-0x24D  0x36800         ||          MOV   r8,0x00                  ; restart x coordinates
(0564)  CS-0x24E  0x36927         ||          MOV   r9,0x27 
(0565)                            ||  
(0566)  CS-0x24F  0x08FD9         ||          CALL  drawHLine		        ; draw a complete line
(0567)  CS-0x250  0x28D01         ||          ADD   r13,0x01                 ; increment row count
(0568)  CS-0x251  0x30D1E         ||          CMP   r13,0x1E                 ; see if more rows to draw
(0569)  CS-0x252  0x09263         ||          BRNE  start                    ; branch to draw more rows
(0570)  CS-0x253  0x12802         ||          POP   r8                       ; restore registers
(0571)  CS-0x254  0x12702         ||          POP   r7
(0572)  CS-0x255  0x18002         ||          RET
(0573)                            || ;---------------------------------------------------------------------
(0574)                            || 
(0575)                            || ;--------------------------------------------------------------------
(0576)                            || ;- Subroutine: getByte
(0577)                            || ;-	This subroutine takes the current location (r21, r22) and generates
(0578)                            || ;-	a byte to be displayed for that row. It pulls the byte at its
(0579)                            || ;-	current location (top left corner) and, if needed, shifts it. When
(0580)                            || ;-	shifting, it rotates the byte left, clearing the rightmost bit as it
(0581)                            || ;-  goes, until the shift counter is emptied. It then pulls the next byte
(0582)                            || ;-	to the right and shifts that one to the left, but clears the opposite
(0583)                            || ;-	bits. It then combines these half completed bytes and spits the whole 
(0584)                            || ;-	thing out.
(0585)                            || 
(0586)                            || ;- Used Registers
(0587)                            || ;-	r20, r21, r22, r26, r29, r30, r31
(0588)                            || ;- Modified registers:
(0589)                            || ;-	r26, r29, r30, r31
(0590)                            || ;--------------------------------------------------------------------
(0591)                     0x256  || getByte:
(0592)  CS-0x256  0x13401         || 			PUSH	r20
(0593)  CS-0x257  0x13501         || 			PUSH	r21
(0594)  CS-0x258  0x13601         || 			PUSH	r22
(0595)  CS-0x259  0x37AFF         || 			MOV		r26,0xFF		; counter for columns (underflow for DO-WHILE)
(0596)  CS-0x25A  0x37E30         || 			MOV		r30,0x30
(0597)                            || 	
(0598)                     0x25B  || findColumnLoop:
(0599)  CS-0x25B  0x29A01         || 			ADD		r26,0x01
(0600)  CS-0x25C  0x2D508         || 			SUB		r21,0x08
(0601)  CS-0x25D  0x0B2D9         || 			BRCC	findColumnLoop
(0602)  CS-0x25E  0x03ED0         || 			ADD		r30,r26			; move to the intended byte's column
(0603)  CS-0x25F  0x37AFC         || 			MOV		r26,0xFC		; counter for rows (underflow for DO-WHILE)
(0604)                            || 
(0605)                     0x260  || findRowLoop:
(0606)  CS-0x260  0x29A04         || 			ADD		r26,0x04
(0607)  CS-0x261  0x2D601         || 			SUB		r22,0x01
(0608)  CS-0x262  0x0B301         || 			BRCC 	findRowLoop
(0609)  CS-0x263  0x03ED0         || 			ADD		r30,r26			; move to the intended byte's row
(0610)  CS-0x264  0x05FF2         || 			LD		r31,(r30)		; pull that byte's data
(0611)                            || 
(0612)                     0x265  || shiftInit:
(0613)  CS-0x265  0x31400         || 			CMP		r20,0x00		; check if a shift is necessary
(0614)  CS-0x266  0x0939A         || 			BREQ	shiftByteDone
(0615)                     0x267  || shiftFirstByte:
(0616)  CS-0x267  0x37AFF         || 			MOV		r26,0xFF		; used to AND the shifted bytes
(0617)  CS-0x268  0x093B9         || 			CALL	shiftByte		; shift the byte
(0618)  CS-0x269  0x01FD0         || 			AND		r31,r26			; clear unnecessary bits
(0619)  CS-0x26A  0x05DF9         || 			MOV		r29,r31			; store our half-complete bit
(0620)                     0x26B  || shiftSecondByte:
(0621)  CS-0x26B  0x39400         || 			LD		r20,0x00		; reset counter
(0622)  CS-0x26C  0x37AFF         || 			MOV		r26,0xFF		; ^
(0623)  CS-0x26D  0x29E01         || 			ADD		r30,0x01		; grab the next byte
(0624)  CS-0x26E  0x05FF2         || 			LD		r31,(r30)		; ^
(0625)  CS-0x26F  0x093B9         || 			CALL	shiftByte		; shift dat shit
(0626)  CS-0x270  0x25AFF         || 			EXOR	r26,0xFF		; invert
(0627)  CS-0x271  0x01FD0         || 			AND		r31,r26			; clear unnecessary bits
(0628)  CS-0x272  0x01FE9         || 			OR		r31,r29			; add our earlier completed half
(0629)                     0x273  || shiftByteDone:
(0630)  CS-0x273  0x13602         || 			POP		r22
(0631)  CS-0x274  0x13502         || 			POP		r21
(0632)  CS-0x275  0x13402         || 			POP		r20
(0633)  CS-0x276  0x18002         || 			RET
(0634)                            || 
(0635)                     0x277  || shiftByte:
(0636)  CS-0x277  0x11A00         || 			LSL		r26
(0637)  CS-0x278  0x11F02         || 			ROL		r31
(0638)  CS-0x279  0x2D401         || 			SUB		r20,0x01
(0639)  CS-0x27A  0x31400         || 			CMP		r20,0x00
(0640)  CS-0x27B  0x093BB         || 			BRNE	shiftByte
(0641)  CS-0x27C  0x18002         || 			RET
(0642)                            || 
(0643)                            || ;--------------------------------------------------------------------
(0644)                            || ;- Subroutine: ISR (Interrupt Service Routine)
(0645)                            || ;-	This subroutine handles movement checking whenever a keyboard press is detected. 
(0646)                            || ;-	It disables interrupts, checks each key sequentially by verifying the key code,
(0647)                            || ;-	checks the validity of the move, then either cancels the move or adjusts the
(0648)                            || ;- 	current location appropriately.
(0649)                            || 
(0650)                            || ;- Modified registers
(0651)                            || ;-	r1, r20, r21, r22, r31
(0652)                            || ;--------------------------------------------------------------------
(0653)                     0x27D  || ISR:
(0654)  CS-0x27D  0x1A001         || 			CLI
(0655)  CS-0x27E  0x32144         || 			IN		r1,PS2_KEY_CODE
(0656)  CS-0x27F  0x39400         || 			LD		r20,0x00
(0657)  CS-0x280  0x39501         || 			LD		r21,0x01
(0658)  CS-0x281  0x39602         || 			LD		r22,0x02
(0659)                            || 
(0660)                     0x282  || checkW:
(0661)  CS-0x282  0x3011D         || 			CMP		r1,W				; Compare the key code to a 'w' press, move on
(0662)  CS-0x283  0x09463         || 			BRNE	checkA				; if they aren't equal.
(0663)                            || 
(0664)  CS-0x284  0x29602         || 			ADD		r22,0x02			; Adjust the pointer to the row above the
(0665)  CS-0x285  0x092B1         || 			CALL	getByte				; character, get that byte, and move the 
(0666)  CS-0x286  0x2D602         || 			SUB		r22,0x02			; pointer back.
(0667)                            || 
(0668)  CS-0x287  0x21F10         || 			AND		r31,0x10			; Empty all bits except the bit above the
(0669)  CS-0x288  0x31F10         || 			CMP		r31,0x10			; character then check if there's anything
(0670)  CS-0x289  0x0958A         || 			BREQ	done				; there. If so, end the ISR. If not, adjust
(0671)  CS-0x28A  0x2D601         || 			SUB		r22,0x01			; the current location then end the ISR.
(0672)  CS-0x28B  0x09588         || 			BRN		done
(0673)                            || 
(0674)                     0x28C  || checkA:
(0675)  CS-0x28C  0x3011C         || 			CMP		r1,A
(0676)  CS-0x28D  0x094D3         || 			BRNE	checkS
(0677)                            || 
(0678)  CS-0x28E  0x29603         || 			ADD		r22,0x03
(0679)  CS-0x28F  0x092B1         || 			CALL	getByte
(0680)  CS-0x290  0x2D603         || 			SUB		r22,0x03
(0681)                            || 		
(0682)  CS-0x291  0x21F20         || 			AND		r31,0x20
(0683)  CS-0x292  0x31F20         || 			CMP		r31,0x20
(0684)  CS-0x293  0x0958A         || 			BREQ	done
(0685)  CS-0x294  0x095B8         || 			BRN		checkADoors
(0686)                     0x295  || checkACont:
(0687)  CS-0x295  0x2D501         || 			SUB		r21,0x01
(0688)  CS-0x296  0x31400         || 			CMP		r20,0x00
(0689)  CS-0x297  0x0965A         || 			BREQ	checkAException
(0690)  CS-0x298  0x2D401         || 			SUB		r20,0x01
(0691)  CS-0x299  0x09588         || 			BRN		done		
(0692)                            || 
(0693)                     0x29A  || checkS:
(0694)  CS-0x29A  0x3011B         || 			CMP		r1,S
(0695)  CS-0x29B  0x09523         || 			BRNE	checkD
(0696)                            || 
(0697)  CS-0x29C  0x29604         || 			ADD		r22,0x04
(0698)  CS-0x29D  0x092B1         || 			CALL	getByte
(0699)  CS-0x29E  0x2D604         || 			SUB		r22,0x04
(0700)                            || 
(0701)  CS-0x29F  0x21F10         || 			AND		r31,0x10
(0702)  CS-0x2A0  0x31F10         || 			CMP		r31,0x10
(0703)  CS-0x2A1  0x0958A         || 			BREQ	done
(0704)  CS-0x2A2  0x29601         || 			ADD		r22,0x01
(0705)  CS-0x2A3  0x09588         || 			BRN		done
(0706)                            || 
(0707)                     0x2A4  || checkD:
(0708)  CS-0x2A4  0x30123         || 			CMP		r1,D
(0709)  CS-0x2A5  0x0958B         || 			BRNE	done
(0710)                            || 
(0711)  CS-0x2A6  0x29603         || 			ADD		r22,0x03
(0712)  CS-0x2A7  0x092B1         || 			CALL	getByte
(0713)  CS-0x2A8  0x2D603         || 			SUB		r22,0x03
(0714)                            || 		
(0715)  CS-0x2A9  0x21F08         || 			AND		r31,0x08
(0716)  CS-0x2AA  0x31F08         || 			CMP		r31,0x08
(0717)  CS-0x2AB  0x0958A         || 			BREQ	done
(0718)  CS-0x2AC  0x29501         || 			ADD		r21,0x01
(0719)  CS-0x2AD  0x31407         || 			CMP		r20,0x07
(0720)  CS-0x2AE  0x0966A         || 			BREQ	checkDException
(0721)  CS-0x2AF  0x29401         || 			ADD		r20,0x01
(0722)  CS-0x2B0  0x09588         || 			BRN		done
(0723)                            || 
(0724)                     0x2B1  || done:
(0725)  CS-0x2B1  0x3B400         || 			ST		r20,0x00
(0726)  CS-0x2B2  0x3B501         || 			ST		r21,0x01
(0727)  CS-0x2B3  0x3B602         || 			ST		r22,0x02
(0728)  CS-0x2B4  0x29503         || 			ADD		r21,0x03
(0729)  CS-0x2B5  0x29603         || 			ADD		r22,0x03
(0730)  CS-0x2B6  0x09678         || 			BRN		checkKeyGrab
(0731)                            || 
(0732)                     0x2B7  || checkADoors:
(0733)  CS-0x2B7  0x31606         || 			CMP		r22,0x06
(0734)  CS-0x2B8  0x094AB         || 			BRNE	checkACont
(0735)  CS-0x2B9  0x31505         || 			CMP		r21,0x05
(0736)  CS-0x2BA  0x095FB         || 			BRNE	checkADoors2
(0737)  CS-0x2BB  0x39803         || 			LD		r24,0x03
(0738)  CS-0x2BC  0x31801         || 			CMP		r24,0x01
(0739)  CS-0x2BD  0x0958A         || 			BREQ	done
(0740)  CS-0x2BE  0x094A8         || 			BRN		checkACont
(0741)                     0x2BF  || checkADoors2:
(0742)  CS-0x2BF  0x31504         || 			CMP		r21,0x04
(0743)  CS-0x2C0  0x0962B         || 			BRNE	checkADoors3
(0744)  CS-0x2C1  0x39804         || 			LD		r24,0x04
(0745)  CS-0x2C2  0x31801         || 			CMP		r24,0x01
(0746)  CS-0x2C3  0x0958A         || 			BREQ	done
(0747)  CS-0x2C4  0x094A8         || 			BRN		checkACont
(0748)                     0x2C5  || checkADoors3:
(0749)  CS-0x2C5  0x31503         || 			CMP		r21,0x03
(0750)  CS-0x2C6  0x094AB         || 			BRNE	checkACont
(0751)  CS-0x2C7  0x39805         || 			LD		r24,0x05
(0752)  CS-0x2C8  0x31801         || 			CMP		r24,0x01
(0753)  CS-0x2C9  0x0958A         || 			BREQ	done
(0754)  CS-0x2CA  0x094A8         || 			BRN		checkACont
(0755)                            || 			
(0756)                            || 
(0757)                     0x2CB  || checkAException:
(0758)  CS-0x2CB  0x37407         || 			MOV		r20,0x07
(0759)  CS-0x2CC  0x09588         || 			BRN 	done
(0760)                            || 
(0761)                     0x2CD  || checkDException:
(0762)  CS-0x2CD  0x37400         || 			MOV		r20,0x00
(0763)  CS-0x2CE  0x09588         || 			BRN		done
(0764)                            || 
(0765)                     0x2CF  || checkKeyGrab:
(0766)  CS-0x2CF  0x31518         || 			CMP		r21,0x18
(0767)  CS-0x2D0  0x096B3         || 			BRNE	checkKeyGrab2
(0768)  CS-0x2D1  0x31608         || 			CMP		r22,0x08
(0769)  CS-0x2D2  0x096B3         || 			BRNE	checkKeyGrab2
(0770)  CS-0x2D3  0x37800         || 			MOV		r24,0x00
(0771)  CS-0x2D4  0x3B803         || 			ST		r24,0x03
(0772)  CS-0x2D5  0x097E0         || 			BRN		notVictory
(0773)                     0x2D6  || checkKeyGrab2:
(0774)  CS-0x2D6  0x31517         || 			CMP		r21,0x17
(0775)  CS-0x2D7  0x096EB         || 			BRNE	checkKeyGrab3
(0776)  CS-0x2D8  0x3160F         || 			CMP		r22,0x0F
(0777)  CS-0x2D9  0x096EB         || 			BRNE	checkKeyGrab3
(0778)  CS-0x2DA  0x37800         || 			MOV		r24,0x00
(0779)  CS-0x2DB  0x3B804         || 			ST		r24,0x04
(0780)  CS-0x2DC  0x097E0         || 			BRN		notVictory
(0781)                     0x2DD  || checkKeyGrab3:
(0782)  CS-0x2DD  0x31508         || 			CMP		r21,0x08
(0783)  CS-0x2DE  0x09723         || 			BRNE	checkDeath
(0784)  CS-0x2DF  0x31612         || 			CMP		r22,0x12
(0785)  CS-0x2E0  0x09723         || 			BRNE	checkDeath
(0786)  CS-0x2E1  0x37800         || 			MOV		r24,0x00
(0787)  CS-0x2E2  0x3B805         || 			ST		r24,0x05
(0788)  CS-0x2E3  0x097E0         || 			BRN		notVictory
(0789)                     0x2E4  || checkDeath:
(0790)  CS-0x2E4  0x39807         || 			LD		r24,0x07
(0791)  CS-0x2E5  0x058A8         || 			CMP		r24,r21
(0792)  CS-0x2E6  0x09783         || 			BRNE	checkVictory
(0793)  CS-0x2E7  0x39808         || 			LD		r24,0x08
(0794)  CS-0x2E8  0x058B0         || 			CMP		r24,r22
(0795)  CS-0x2E9  0x09783         || 			BRNE	checkVictory
(0796)  CS-0x2EA  0x09241         || 			CALL	clearScreen
(0797)  CS-0x2EB  0x37EA4         || 			MOV		r30,0xA4
(0798)  CS-0x2EC  0x09181         || 			CALL	drawScreen
(0799)  CS-0x2ED  0x37D01         || 			MOV		r29,0x01
(0800)  CS-0x2EE  0x3BD29         || 			ST		r29,0x29
(0801)  CS-0x2EF  0x1A002         || 			RETID
(0802)                            || 
(0803)                     0x2F0  || checkVictory:
(0804)  CS-0x2F0  0x2D503         || 			SUB		r21,0x03
(0805)  CS-0x2F1  0x2D603         || 			SUB		r22,0x03
(0806)  CS-0x2F2  0x31500         || 			CMP		r21,0x00
(0807)  CS-0x2F3  0x097E3         || 			BRNE	notVictory
(0808)  CS-0x2F4  0x31606         || 			CMP		r22,0x06
(0809)  CS-0x2F5  0x097E3         || 			BRNE	notVictory
(0810)                            || 
(0811)  CS-0x2F6  0x09241         || 			CALL	clearScreen
(0812)  CS-0x2F7  0x37E90         || 			MOV		r30,0x90
(0813)  CS-0x2F8  0x09181         || 			CALL	drawScreen
(0814)  CS-0x2F9  0x37D01         || 			MOV		r29,0x01
(0815)  CS-0x2FA  0x3BD29         || 			ST		r29,0x29
(0816)  CS-0x2FB  0x1A002         || 			RETID
(0817)                            || 
(0818)                     0x2FC  || notVictory:
(0819)  CS-0x2FC  0x08C49         || 			CALL	drawDisplay
(0820)  CS-0x2FD  0x1A003         || 			RETIE
(0821)                            || ;--------------------------------------------------------------------
(0822)                            || 
(0823)                            || ;--------------------------------------------------------------------
(0824)                            || ;- Subroutine: generateMap
(0825)                            || ;-	This subroutine loads the predesigned level into the scratchRAM. The map occupies
(0826)                            || ;-	memory locations 0x30 through 0x8F, a total of 96 locations. If a bit exists in a
(0827)                            || ;-	location then the program will put a wall there, else it will remain open.
(0828)                            || 
(0829)                            || ;- Modified registers:
(0830)                            || ;-	None
(0831)                            || ;--------------------------------------------------------------------
(0832)                            || 
(0833)                     0x2FE  || generateMap:
(0834)                            || .DSEG
(0835)                       048  || .ORG	0x30
(0836)                            || 
(0837)  DS-0x030             004  || 			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x30 - 0x33
(0838)  DS-0x034             004  || 			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x34 - 0x37
(0839)  DS-0x038             004  || 			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x38 - 0x3B
(0840)  DS-0x03C             004  || 			.DB		0xEE, 0x20, 0x78, 0x0F	; 0x3C - 0x3F
(0841)  DS-0x040             004  || 			.DB		0xE0, 0x8B, 0x02, 0xEF	; 0x40 - 0x43
(0842)  DS-0x044             004  || 			.DB		0xEE, 0xBB, 0xEE, 0x0F	; 0x44 - 0x47
(0843)  DS-0x048             004  || 			.DB		0xE0, 0x02, 0x22, 0xAF	; 0x48 - 0x4B
(0844)  DS-0x04C             004  || 			.DB		0xFD, 0xFE, 0xA8, 0x0F	; 0x4C - 0x4F
(0845)  DS-0x050             004  || 			.DB		0xE7, 0x10, 0xAD, 0x5F	; 0x50 - 0x53
(0846)  DS-0x054             004  || 			.DB		0xE0, 0x05, 0xA8, 0x0F	; 0x54 - 0x57
(0847)  DS-0x058             004  || 			.DB		0xE7, 0x10, 0x8A, 0xAF	; 0x58 - 0x5B
(0848)  DS-0x05C             004  || 			.DB		0xFD, 0xBA, 0xEA, 0xAF	; 0x5C - 0x5F
(0849)  DS-0x060             004  || 			.DB		0xE0, 0x02, 0x22, 0xAF	; 0x60 - 0x63
(0850)  DS-0x064             004  || 			.DB		0xEB, 0xFB, 0xAA, 0x8F	; 0x64 - 0x67
(0851)  DS-0x068             004  || 			.DB		0xE8, 0x8A, 0x20, 0xEF	; 0x68 - 0x6B
(0852)  DS-0x06C             004  || 			.DB		0xEE, 0xA0, 0x86, 0x0F	; 0x6C - 0x6F
(0853)  DS-0x070             004  || 			.DB		0xE0, 0x8A, 0xD0, 0xEF	; 0x70 - 0x73
(0854)  DS-0x074             004  || 			.DB		0xFE, 0xBA, 0x15, 0xEF	; 0x74 - 0x77
(0855)  DS-0x078             004  || 			.DB		0xE0, 0x13, 0xD4, 0x0F	; 0x78 - 0x7B
(0856)  DS-0x07C             004  || 			.DB		0xEA, 0xD6, 0x15, 0xEF	; 0x7C - 0x7F
(0857)  DS-0x080             004  || 			.DB		0xE2, 0x00, 0xF0, 0x0F	; 0x80 - 0x83
(0858)  DS-0x084             004  || 			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x84 - 0x87
(0859)  DS-0x088             004  || 			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x88 - 0x8B
(0860)  DS-0x08C             004  || 			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x8C - 0x8F
(0861)  DS-0x090             005  || 			.DB		0x05, 0x75, 0x2A, 0xE9, 0x40	; 0x90 - 0x94
(0862)  DS-0x095             005  || 			.DB		0x07, 0x55, 0x2A, 0x4D, 0x40	; 0x95 - 0x99
(0863)  DS-0x09A             005  || 			.DB		0x02, 0x55, 0x2A, 0x4B, 0x00	; 0x9A - 0x9E
(0864)  DS-0x09F             005  || 			.DB		0x02, 0x77, 0x14, 0xE9, 0x40	; 0x9F - 0xA3
(0865)  DS-0x0A4             005  || 			.DB		0x02, 0xBA, 0x99, 0xDD, 0x80	; 0xA4
(0866)  DS-0x0A9             005  || 			.DB		0x03, 0xAA, 0x94, 0x99, 0x40
(0867)  DS-0x0AE             005  || 			.DB		0x01, 0x2A, 0x94, 0x91, 0x40
(0868)  DS-0x0B3             005  || 			.DB		0x01, 0x3B, 0x99, 0xDD, 0x80
(0869)                            || 
(0870)                            || ;			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x50 - 0x53
(0871)                            || ;			.DB		0x88, 0x0F, 0xFA, 0x01	; 0x54 - 0x57
(0872)                            || ;			.DB		0x83, 0xA0, 0x02, 0x3D	; 0x58 - 0x5B
(0873)                            || ;			.DB		0x88, 0xAE, 0xEA, 0xA9	; 0x5C - 0x5F
(0874)                            || ;			.DB		0xD8, 0x20, 0x28, 0x23	; 0x60 - 0x63
(0875)                            || ;			.DB		0xD0, 0xAF, 0xAB, 0x7B	; 0x64 - 0x67
(0876)                            || ;			.DB		0xD7, 0xA0, 0x08, 0x09	; 0x68 - 0x6B
(0877)                            || ;			.DB		0x84, 0x2F, 0xEF, 0xED	; 0x6C - 0x6F
(0878)                            || ;			.DB		0xBD, 0xA8, 0x02, 0x21	; 0x70 - 0x73
(0879)                            || ;			.DB		0xA1, 0xAA, 0xA8, 0xBF	; 0x74 - 0x77
(0880)                            || ;			.DB		0xB8, 0x0A, 0x02, 0x11	; 0x78 - 0x7B
(0881)                            || ;			.DB		0x83, 0x63, 0xDF, 0x55	; 0x7C - 0x7F
(0882)                            || ;			.DB		0xEE, 0x08, 0x40, 0x45	; 0x80 - 0x83
(0883)                            || ;			.DB		0x8A, 0x8F, 0x55, 0xD5	; 0x84 - 0x87
(0884)                            || ;			.DB		0xB8, 0x80, 0x40, 0x14	; 0x88 - 0x8B
(0885)                            || ;			.DB		0xFF, 0xFF, 0xFF, 0xFF	; 0x8C - 0x8F
(0886)                            || 
(0887)                            || .CSEG
(0888)                       1021  || .ORG	0x3FD
(0889)                            || 
(0890)  CS-0x3FD  0x18002         || 			RET
(0891)                            || ;--------------------------------------------------------------------
(0892)                            || 
(0893)                            || .CSEG
(0894)                       1023  || .ORG 0x3FF
(0895)  CS-0x3FF  0x093E8         || 			BRN		ISR





Symbol Table Key 
----------------------------------------------------------------------
C1             C2     C3      ||  C4+
-------------  ----   ----        -------
C1:  name of symbol
C2:  the value of symbol 
C3:  source code line number where symbol defined
C4+: source code line number of where symbol is referenced 
----------------------------------------------------------------------


-- Labels
------------------------------------------------------------ 
CHECKA         0x28C   (0674)  ||  0662 
CHECKACONT     0x295   (0686)  ||  0734 0740 0747 0750 0754 
CHECKADOORS    0x2B7   (0732)  ||  0685 
CHECKADOORS2   0x2BF   (0741)  ||  0736 
CHECKADOORS3   0x2C5   (0748)  ||  0743 
CHECKAEXCEPTION 0x2CB   (0757)  ||  0689 
CHECKD         0x2A4   (0707)  ||  0695 
CHECKDEATH     0x2E4   (0789)  ||  0783 0785 
CHECKDEXCEPTION 0x2CD   (0761)  ||  0720 
CHECKDOOR2     0x1CF   (0321)  ||  0317 0319 
CHECKDOOR3     0x1D5   (0328)  ||  0324 0326 
CHECKDOORS     0x1C7   (0312)  ||  0306 0308 0310 
CHECKDOWN      0x179   (0204)  ||  0164 0172 0202 
CHECKDOWNCONT  0x17D   (0209)  ||  0207 
CHECKKEY2      0x1B7   (0294)  ||  0288 0290 0292 
CHECKKEY3      0x1BF   (0303)  ||  0297 0299 0301 
CHECKKEYGRAB   0x2CF   (0765)  ||  0730 
CHECKKEYGRAB2  0x2D6   (0773)  ||  0767 0769 
CHECKKEYGRAB3  0x2DD   (0781)  ||  0775 0777 
CHECKKEYS      0x1AF   (0285)  ||  0276 0279 
CHECKLEFT      0x167   (0182)  ||  0162 0170 0180 
CHECKLEFTCONT  0x16C   (0188)  ||  0186 
CHECKMOBS      0x1A4   (0273)  ||  0269 
CHECKRIGHT     0x170   (0193)  ||  0160 0168 0191 
CHECKRIGHTCONT 0x175   (0199)  ||  0197 
CHECKS         0x29A   (0693)  ||  0676 
CHECKUP        0x162   (0176)  ||  0158 0166 
CHECKVICTORY   0x2F0   (0803)  ||  0792 0795 
CHECKW         0x282   (0660)  ||  
CLEARSCREEN    0x248   (0557)  ||  0796 0811 
DD_ADD40       0x22B   (0506)  ||  0496 
DD_ADD80       0x22E   (0510)  ||  0499 
DD_OUT         0x227   (0501)  ||  0511 
DONE           0x2B1   (0724)  ||  0670 0672 0684 0691 0703 0705 0709 0717 0722 0739 
                               ||  0746 0753 0759 0763 
DRAWBLIT       0x207   (0447)  ||  0256 0271 0281 0338 0344 0350 
DRAWBYTE       0x19A   (0262)  ||  0245 0272 0284 0339 0347 0353 
DRAWBYTEDONE   0x1DE   (0340)  ||  0266 
DRAWDISPLAY    0x189   (0235)  ||  0110 0221 0819 
DRAWDISPLAYCOMPLETE 0x199   (0258)  ||  
DRAWDISPLAYLINE 0x18C   (0240)  ||  0250 
DRAWDOOR       0x1DF   (0342)  ||  0320 0327 0334 
DRAWDOT        0x21E   (0487)  ||  0283 0346 0352 0406 0431 0451 0455 0457 0459 0462 
                               ||  0464 0467 0469 0471 0527 
DRAWFRAME      0x1E9   (0366)  ||  0109 
DRAWHLINE      0x1FB   (0402)  ||  0372 0384 0566 
DRAWHLOOP      0x1FC   (0405)  ||  0409 
DRAWKEY        0x1E4   (0348)  ||  0293 0302 0311 
DRAWLOCATION   0x195   (0252)  ||  
DRAWSCREEN     0x230   (0515)  ||  0798 0813 
DRAWVLINE      0x201   (0427)  ||  0376 0380 
DRAWVLOOP      0x202   (0430)  ||  0434 
DRAWWINDONE    0x246   (0545)  ||  0541 
DRAWWINLOOP    0x235   (0522)  ||  0538 0543 
DRAWWINNEXT1   0x23A   (0529)  ||  0526 
DRAWWINNEXT2   0x23F   (0536)  ||  0531 
FINDCOLUMNLOOP 0x25B   (0598)  ||  0601 
FINDROWLOOP    0x260   (0605)  ||  0608 
GENERATEMAP    0x2FE   (0833)  ||  0108 
GETBYTE        0x256   (0591)  ||  0178 0189 0200 0211 0243 0665 0679 0698 0712 
INITIALIZE     0x125   (0107)  ||  
ISR            0x27D   (0653)  ||  0895 
MAIN           0x129   (0113)  ||  0116 0121 0128 0135 0143 0146 0174 0215 0223 
MOVEMOB        0x14A   (0148)  ||  0141 
MOVEMOBDONE    0x183   (0217)  ||  0181 0192 0203 0213 
NOTVICTORY     0x2FC   (0818)  ||  0772 0780 0788 0807 0809 
RNGLOLNO       0x14E   (0154)  ||  
SHIFTBYTE      0x277   (0635)  ||  0617 0625 0640 
SHIFTBYTEDONE  0x273   (0629)  ||  0614 
SHIFTFIRSTBYTE 0x267   (0615)  ||  
SHIFTINIT      0x265   (0612)  ||  
SHIFTSECONDBYTE 0x26B   (0620)  ||  
START          0x24C   (0562)  ||  0569 
T1             0x225   (0498)  ||  0508 
WIPEBYTE       0x1DB   (0336)  ||  0314 0331 0333 


-- Directives: .BYTE
------------------------------------------------------------ 
--> No ".BYTE" directives used


-- Directives: .EQU
------------------------------------------------------------ 
A              0x01C   (0061)  ||  0675 
BLACK          0x000   (0070)  ||  0282 0337 0349 0560 
BLUE           0x003   (0072)  ||  0367 
BROWN          0x045   (0076)  ||  0343 
CRIMSON        0x0E0   (0071)  ||  0253 
D              0x023   (0063)  ||  0708 
GREEN          0x01C   (0073)  ||  0280 
GREY           0x04A   (0074)  ||  0270 
LEDS           0x040   (0047)  ||  
PS2_KEY_CODE   0x044   (0050)  ||  0655 
S              0x01B   (0062)  ||  0694 
SPAAACE        0x029   (0064)  ||  
SSEG           0x081   (0048)  ||  
VGA_COLOR      0x092   (0054)  ||  0503 
VGA_HADD       0x090   (0052)  ||  0502 
VGA_LADD       0x091   (0053)  ||  0501 
W              0x01D   (0060)  ||  0661 
YELLOW         0x048   (0075)  ||  0345 0351 


-- Directives: .DEF
------------------------------------------------------------ 
--> No ".DEF" directives used


-- Directives: .DB
------------------------------------------------------------ 
--> No ".DB" directives used
