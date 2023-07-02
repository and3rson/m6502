.export ACIA1_DATA = $00D100
.export ACIA1_STAT = $00D101
.export LCD1_CMD = $00D201
.export LCD1_DATA = $00D200
.export LCD_ROWS = $00E7CC
.export VIA1_DDRA = $00D003
.export VIA1_DDRB = $00D002
.export VIA1_IFR = $00D00D
.export VIA1_RA = $00D001
.export VIA1_RB = $00D000
.export _LCD_ROWS = $00E7CC
.export __STACK_FILEOFFS__ = $000000
.export __STACK_LAST__ = $007800
.export __STACK_SIZE__ = $000800
.export __STACK_START__ = $007800
.export __STARTUP__ = $009E52
.export __ctype = $009D94
.export __ctypeidx = $009D9F
.export __hextab = $009E1F
.export _abs = $008B82
.export _argc = $001000
.export _argv = $001001
.export _atoi = $0081BC
.export _atol = $0081BC
.export _bootsec = $000554
.export _buff = $00052B
.export _buffPos = $000553
.export _cgetc = $00E7A5
.export _clrscr = $00E820
.export _cluster = $000786
.export _cmd_ls = $009BAF
.export _cmd_peekpoke = $009CAD
.export _command = $001021
.export _cputc = $00E8B8
.export _data_sec = $000564
.export _dd = $00078C
.export _dir_offset = $000788
.export _dir_sec = $00078A
.export _f_parse_hex = $00EAFB
.export _f_parse_octet = $00EB23
.export _fat16_direntry = $009BA7
.export _fat16_init = $00967F
.export _fat16_open = $0098AF
.export _fat16_opendir = $009AA0
.export _fat16_read = $0099F1
.export _fat16_readdir = $009ABE
.export _fat_count = $000559
.export _fat_sec = $00055E
.export _fd = $000766
.export _getps = $00EBAE
.export _gotoxy = $00E91E
.export _i2c_addr = $00E3BC
.export _i2c_read = $00E3CC
.export _i2c_readreg = $00E3EF
.export _i2c_start = $00E2F7
.export _i2c_stop = $00E303
.export _i2c_write = $00E3C4
.export _i2c_writereg = $00E3DA
.export _igetch = $00E7B6
.export _itoa = $008308
.export _memcpy = $0082AE
.export _printhex = $00E903
.export _printword = $00E914
.export _puts = $00E927
.export _res_sec_count = $000557
.export _root_dir_entries = $00055A
.export _root_dir_sec = $000560
.export _root_dir_sec_count = $000562
.export _sdc_read_block_byte = $00E2AF
.export _sdc_read_block_end = $00E189
.export _sdc_read_block_start = $00E15B
.export _sdc_read_block_word = $00E17F
.export _sdc_read_sector = $00E128
.export _sdc_select_sector = $00E123
.export _sdcard2_test = $00EE77
.export _sec_per_clu = $000556
.export _sec_per_fat = $00055C
.export _sector = $000566
.export _strcasecmp = $00826B
.export _strchr = $00837E
.export _strcmp = $00841F
.export _strcpy = $008440
.export _strcspn = $0083F2
.export _stricmp = $00826B
.export _strlen = $0083DC
.export _strncasecmp = $008163
.export _strncmp = $0083A3
.export _strncpy = $00845F
.export _strnicmp = $008163
.export _system = $00938B
.export _uart_get = $00E018
.export _uart_has_data = $00E010
.export _uart_write = $00E02E
.export _urepl_main = $00926A
.export _utoa = $00834A
.export _wait16ms = $00EB88
.export _wait1ms = $00EB70
.export acia_write = $00EAEE
.export addeq0sp = $008A3D
.export addeqysp = $008A3F
.export addysp = $0089A3
.export addysp1 = $0089A2
.export along = $008B94
.export aslax1 = $008D90
.export aslax2 = $009191
.export aslax3 = $008D1B
.export aslax4 = $00855D
.export aslaxy = $008ECE
.export asleax1 = $008073
.export asleax2 = $008573
.export asleax3 = $0085ED
.export asleax4 = $00801B
.export asrax1 = $008B78
.export asrax2 = $008993
.export asrax3 = $008088
.export asrax4 = $008CB0
.export asraxy = $0091ED
.export asreax1 = $0090A6
.export asreax2 = $0090C8
.export asreax3 = $008834
.export asreax4 = $008CC9
.export aulong = $008B9A
.export axlong = $00916E
.export axulong = $009174
.export bcasta = $008AEC
.export bcastax = $008AE8
.export bcasteax = $008B69
.export bnega = $008A19
.export bnegax = $008A15
.export bnegeax = $008624
.export booleq = $0085C7
.export boolge = $0085D8
.export boolgt = $0085D6
.export boolle = $0085CE
.export boollt = $0085D0
.export boolne = $0085C1
.export booluge = $0085E8
.export boolugt = $0085E6
.export boolule = $0085DE
.export boolult = $0085E0
.export bpushbsp = $00893E
.export bpushbysp = $008940
.export callax = $008A9E
.export callptr4 = $00882A
.export complax = $008D9D
.export compleax = $008DD1
.export ctypemask = $00824D
.export ctypemaskdirect = $008251
.export decax1 = $008A97
.export decax2 = $008823
.export decax3 = $008BA1
.export decax4 = $008A90
.export decax5 = $0090C1
.export decax6 = $008C0D
.export decax7 = $00800A
.export decax8 = $008AE1
.export decaxy = $00807F
.export deceaxy = $008679
.export decsp1 = $008AC3
.export decsp2 = $00873B
.export decsp3 = $008CA3
.export decsp4 = $00908F
.export decsp5 = $008F04
.export decsp6 = $008EF7
.export decsp7 = $0091AF
.export decsp8 = $008A83
.export enter = $008F32
.export f_parse_hex = $00EAFB
.export f_parse_octet = $00EB23
.export getlop = $0088BA
.export getps = $00EBAE
.export i2c_init = $00E2F6
.export idiv32by16r16 = $008649
.export imul16x16r32 = $008DA6
.export imul8x8r16 = $009222
.export imul8x8r16m = $009224
.export incax1 = $0084C8
.export incax2 = $008DFC
.export incax3 = $00898E
.export incax4 = $0090B6
.export incax5 = $008E6C
.export incax6 = $009265
.export incax7 = $008000
.export incax8 = $008E7B
.export incaxy = $0090B8
.export inceaxy = $008FB2
.export incsp1 = $008D6F
.export incsp2 = $008E52
.export incsp3 = $0084A1
.export incsp4 = $00856E
.export incsp5 = $00805E
.export incsp6 = $008E76
.export incsp7 = $008E85
.export incsp8 = $0080D6
.export init = $00EBB1
.export init_jmpvec = $008961
.export initmainargs = $00853A
.export io_init = $00EAAB
.export irq = $00EDD9
.export jmpvec = $000528
.export kbd_init = $00E710
.export kbd_process = $00E719
.export laddeq = $00912C
.export laddeq0sp = $009013
.export laddeq1 = $009124
.export laddeqa = $009126
.export laddeqysp = $009015
.export lcd_init = $00E7CD
.export lcd_printchar = $00E8B8
.export lcd_printfz = $00E897
.export lcd_printhex = $00E903
.export lcd_printz = $00E927
.export ldaidx = $008A77
.export ldau00sp = $008DEC
.export ldau0ysp = $008DEE
.export ldaui0sp = $008729
.export ldauidx = $008607
.export ldauiysp = $00872B
.export ldax0sp = $0091DD
.export ldaxi = $008C14
.export ldaxidx = $008C16
.export ldaxysp = $0091DF
.export ldeax0sp = $00802C
.export ldeaxi = $008F11
.export ldeaxidx = $008F13
.export ldeaxysp = $00802E
.export leaa0sp = $00868E
.export leaaxsp = $008690
.export leave = $008F84
.export leave0 = $008F79
.export leave00 = $008F77
.export leavey = $008F81
.export leavey0 = $008F7F
.export leavey00 = $008F7D
.export lsubeq = $0087DC
.export lsubeq0sp = $0090FD
.export lsubeq1 = $0087D4
.export lsubeqa = $0087D6
.export lsubeqysp = $0090FF
.export memcpy_getparams = $0082D7
.export memcpy_upwards = $0082B1
.export mul8x16 = $00809E
.export mul8x16a = $0080A8
.export mulax10 = $008FE5
.export mulax3 = $00897D
.export mulax5 = $008610
.export mulax6 = $0080DB
.export mulax7 = $008D02
.export mulax9 = $0089B0
.export negax = $008B86
.export negeax = $008D29
.export nmi = $00EE0A
.export popa = $008F6D
.export popax = $008E4B
.export popeax = $008856
.export poplsargs = $008BA8
.export popptr1 = $0087B0
.export popsargsudiv16 = $008F92
.export popsreg = $00863A
.export ptr1 = $000008
.export ptr2 = $00000A
.export ptr3 = $00000C
.export ptr4 = $00000E
.export push0 = $0086E1
.export push0ax = $009153
.export push1 = $008D98
.export push2 = $008E80
.export push3 = $008D76
.export push4 = $008005
.export push5 = $008967
.export push6 = $00881E
.export push7 = $008635
.export pusha = $008D58
.export pusha0 = $0086E3
.export pusha0sp = $008D54
.export pushaFF = $00806E
.export pushax = $0086E5
.export pushaysp = $008D56
.export pushb = $009183
.export pushbidx = $00917B
.export pushbsp = $00882D
.export pushbysp = $00882F
.export pushc0 = $008D6A
.export pushc1 = $008E71
.export pushc2 = $008D7B
.export pusheax = $009157
.export pushl0 = $009150
.export pushlysp = $0087BE
.export pushptr1idx = $00874E
.export pushw = $008748
.export pushw0sp = $008922
.export pushwidx = $00874A
.export pushwysp = $008924
.export regbank = $000014
.export regsave = $000004
.export regswap = $008BFA
.export regswap1 = $0086D6
.export regswap2 = $00894B
.export resteax = $008F4D
.export return0 = $008F69
.export return1 = $00880A
.export saveeax = $008F40
.export sdc_ERR = $000020
.export sdc_SECTOR_DATA = $000300
.export sdc_init = $00E031
.export shlax1 = $008D90
.export shlax2 = $009191
.export shlax3 = $008D1B
.export shlax4 = $00855D
.export shlaxy = $008ECE
.export shleax1 = $008073
.export shleax2 = $008573
.export shleax3 = $0085ED
.export shleax4 = $00801B
.export shrax1 = $008056
.export shrax2 = $008063
.export shrax3 = $008C95
.export shrax4 = $008FD4
.export shraxy = $008769
.export shreax1 = $008B5D
.export shreax2 = $00919C
.export shreax3 = $008E03
.export shreax4 = $0089C7
.export sp = $000000
.export sreg = $000002
.export staspidx = $008895
.export stax0sp = $008757
.export staxspidx = $008A23
.export staxysp = $008759
.export steax0sp = $008FFE
.export steaxspidx = $00853B
.export steaxysp = $009000
.export subeq0sp = $008ACC
.export subeqysp = $008ACE
.export subysp = $008D47
.export swapstk = $0084B2
.export tmp1 = $000010
.export tmp2 = $000011
.export tmp3 = $000012
.export tmp4 = $000013
.export tosadd0ax = $008CDE
.export tosadda0 = $008A4E
.export tosaddax = $008A50
.export tosaddeax = $008CE4
.export tosand0ax = $0086AF
.export tosanda0 = $00880F
.export tosandax = $008811
.export tosandeax = $0086B3
.export tosaslax = $008EC7
.export tosasleax = $008796
.export tosasrax = $0091E6
.export tosasreax = $00851C
.export tosdiv0ax = $0090E1
.export tosdiva0 = $00869A
.export tosdivax = $00869C
.export tosdiveax = $0090E7
.export toseq00 = $008011
.export toseqa0 = $008013
.export toseqax = $008015
.export toseqeax = $008E66
.export tosge00 = $0084CD
.export tosgea0 = $0084CF
.export tosgeax = $0084D1
.export tosgeeax = $008C64
.export tosgt00 = $008F28
.export tosgta0 = $008F2A
.export tosgtax = $008F2C
.export tosgteax = $008D80
.export tosicmp = $0086FD
.export tosicmp0 = $0086FB
.export tosint = $008C21
.export toslcmp = $008586
.export tosle00 = $008E8A
.export toslea0 = $008E8C
.export tosleax = $008E8E
.export tosleeax = $0084AC
.export toslong = $00810C
.export toslt00 = $00909C
.export toslta0 = $00909E
.export tosltax = $0090A0
.export toslteax = $0084A6
.export tosmod0ax = $008AA5
.export tosmoda0 = $008A66
.export tosmodax = $008A68
.export tosmodeax = $008AA9
.export tosmul0ax = $009036
.export tosmula0 = $00809C
.export tosmulax = $0084D7
.export tosmuleax = $00903A
.export tosne00 = $008E41
.export tosnea0 = $008E43
.export tosneax = $008E45
.export tosneeax = $008945
.export tosor0ax = $0091BC
.export tosora0 = $00896C
.export tosorax = $00896E
.export tosoreax = $0091C0
.export tosrsub0ax = $008137
.export tosrsuba0 = $008C6A
.export tosrsubax = $008C6C
.export tosrsubeax = $00813B
.export tosshlax = $008EC7
.export tosshleax = $008796
.export tosshrax = $008762
.export tosshreax = $008B43
.export tossub0ax = $008E1D
.export tossuba0 = $008123
.export tossubax = $008125
.export tossubeax = $008E21
.export tosudiv0ax = $0088AB
.export tosudiva0 = $008AF4
.export tosudivax = $008AF6
.export tosudiveax = $0088AF
.export tosuge00 = $008D86
.export tosugea0 = $008D88
.export tosugeax = $008D8A
.export tosugeeax = $0086D0
.export tosugt00 = $008E9C
.export tosugta0 = $008E9E
.export tosugtax = $008EA0
.export tosugteax = $008E60
.export tosule00 = $008159
.export tosulea0 = $00815B
.export tosuleax = $00815D
.export tosuleeax = $008DE6
.export tosulong = $0080F1
.export tosult00 = $008F69
.export tosulta0 = $008E94
.export tosultax = $008E96
.export tosulteax = $008804
.export tosumod0ax = $00803F
.export tosumoda0 = $0089D8
.export tosumodax = $0089DA
.export tosumodeax = $008043
.export tosumul0ax = $009036
.export tosumula0 = $00809C
.export tosumulax = $0084D7
.export tosumuleax = $00903A
.export tosxor0ax = $008EA6
.export tosxora0 = $008FC3
.export tosxorax = $008FC5
.export tosxoreax = $008EAA
.export tsteax = $008F5A
.export uart_init = $00E000
.export uart_process = $00E005
.export udiv16 = $008B05
.export udiv32 = $0088DD
.export udiv32by16r16 = $008C33
.export udiv32by16r16m = $008C37
.export umul16x16r16 = $0089E9
.export umul16x16r16m = $0089ED
.export umul16x16r32 = $0089E9
.export umul16x16r32m = $0089ED
.export umul8x16r16 = $00886A
.export umul8x16r16m = $00886E
.export umul8x16r24 = $00886A
.export umul8x16r24m = $00886E
.export umul8x8r16 = $008C7C
.export umul8x8r16m = $008C7E
.export utsteax = $008F5A
.export vdelay = $00EE40
.export wait16ms = $00EB88
.export wait16us = $00EB58
.export wait2ms = $00EB7C
.export wait2us = $00EB40
.export wait32us = $00EB64
.export wait8us = $00EB4C
