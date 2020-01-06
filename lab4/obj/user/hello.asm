
obj/user/hello：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 a0 0f 80 00       	push   $0x800fa0
  80003e:	e8 08 01 00 00       	call   80014b <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 20 80 00       	mov    0x802004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ae 0f 80 00       	push   $0x800fae
  800054:	e8 f2 00 00 00       	call   80014b <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800069:	e8 b7 0a 00 00       	call   800b25 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 33 0a 00 00       	call   800ae4 <sys_env_destroy>
}
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	c9                   	leave  
  8000b5:	c3                   	ret    

008000b6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	53                   	push   %ebx
  8000ba:	83 ec 04             	sub    $0x4,%esp
  8000bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c0:	8b 13                	mov    (%ebx),%edx
  8000c2:	8d 42 01             	lea    0x1(%edx),%eax
  8000c5:	89 03                	mov    %eax,(%ebx)
  8000c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ca:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000ce:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d3:	74 09                	je     8000de <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000dc:	c9                   	leave  
  8000dd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000de:	83 ec 08             	sub    $0x8,%esp
  8000e1:	68 ff 00 00 00       	push   $0xff
  8000e6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e9:	50                   	push   %eax
  8000ea:	e8 b8 09 00 00       	call   800aa7 <sys_cputs>
		b->idx = 0;
  8000ef:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	eb db                	jmp    8000d5 <putch+0x1f>

008000fa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800103:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010a:	00 00 00 
	b.cnt = 0;
  80010d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800114:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	ff 75 08             	pushl  0x8(%ebp)
  80011d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800123:	50                   	push   %eax
  800124:	68 b6 00 80 00       	push   $0x8000b6
  800129:	e8 1a 01 00 00       	call   800248 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80012e:	83 c4 08             	add    $0x8,%esp
  800131:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800137:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 64 09 00 00       	call   800aa7 <sys_cputs>

	return b.cnt;
}
  800143:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800149:	c9                   	leave  
  80014a:	c3                   	ret    

0080014b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800151:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800154:	50                   	push   %eax
  800155:	ff 75 08             	pushl  0x8(%ebp)
  800158:	e8 9d ff ff ff       	call   8000fa <vcprintf>
	va_end(ap);

	return cnt;
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	57                   	push   %edi
  800163:	56                   	push   %esi
  800164:	53                   	push   %ebx
  800165:	83 ec 1c             	sub    $0x1c,%esp
  800168:	89 c7                	mov    %eax,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	8b 45 08             	mov    0x8(%ebp),%eax
  80016f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800172:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800175:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800178:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800180:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800183:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800186:	39 d3                	cmp    %edx,%ebx
  800188:	72 05                	jb     80018f <printnum+0x30>
  80018a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018d:	77 7a                	ja     800209 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80018f:	83 ec 0c             	sub    $0xc,%esp
  800192:	ff 75 18             	pushl  0x18(%ebp)
  800195:	8b 45 14             	mov    0x14(%ebp),%eax
  800198:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019b:	53                   	push   %ebx
  80019c:	ff 75 10             	pushl  0x10(%ebp)
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001a8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ab:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ae:	e8 ad 0b 00 00       	call   800d60 <__udivdi3>
  8001b3:	83 c4 18             	add    $0x18,%esp
  8001b6:	52                   	push   %edx
  8001b7:	50                   	push   %eax
  8001b8:	89 f2                	mov    %esi,%edx
  8001ba:	89 f8                	mov    %edi,%eax
  8001bc:	e8 9e ff ff ff       	call   80015f <printnum>
  8001c1:	83 c4 20             	add    $0x20,%esp
  8001c4:	eb 13                	jmp    8001d9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c6:	83 ec 08             	sub    $0x8,%esp
  8001c9:	56                   	push   %esi
  8001ca:	ff 75 18             	pushl  0x18(%ebp)
  8001cd:	ff d7                	call   *%edi
  8001cf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d2:	83 eb 01             	sub    $0x1,%ebx
  8001d5:	85 db                	test   %ebx,%ebx
  8001d7:	7f ed                	jg     8001c6 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d9:	83 ec 08             	sub    $0x8,%esp
  8001dc:	56                   	push   %esi
  8001dd:	83 ec 04             	sub    $0x4,%esp
  8001e0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ec:	e8 8f 0c 00 00       	call   800e80 <__umoddi3>
  8001f1:	83 c4 14             	add    $0x14,%esp
  8001f4:	0f be 80 cf 0f 80 00 	movsbl 0x800fcf(%eax),%eax
  8001fb:	50                   	push   %eax
  8001fc:	ff d7                	call   *%edi
}
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    
  800209:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020c:	eb c4                	jmp    8001d2 <printnum+0x73>

0080020e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800214:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800218:	8b 10                	mov    (%eax),%edx
  80021a:	3b 50 04             	cmp    0x4(%eax),%edx
  80021d:	73 0a                	jae    800229 <sprintputch+0x1b>
		*b->buf++ = ch;
  80021f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800222:	89 08                	mov    %ecx,(%eax)
  800224:	8b 45 08             	mov    0x8(%ebp),%eax
  800227:	88 02                	mov    %al,(%edx)
}
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    

0080022b <printfmt>:
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800231:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800234:	50                   	push   %eax
  800235:	ff 75 10             	pushl  0x10(%ebp)
  800238:	ff 75 0c             	pushl  0xc(%ebp)
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 05 00 00 00       	call   800248 <vprintfmt>
}
  800243:	83 c4 10             	add    $0x10,%esp
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <vprintfmt>:
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 2c             	sub    $0x2c,%esp
  800251:	8b 75 08             	mov    0x8(%ebp),%esi
  800254:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800257:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025a:	e9 c1 03 00 00       	jmp    800620 <vprintfmt+0x3d8>
		padc = ' ';
  80025f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800263:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80026a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800271:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800278:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80027d:	8d 47 01             	lea    0x1(%edi),%eax
  800280:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800283:	0f b6 17             	movzbl (%edi),%edx
  800286:	8d 42 dd             	lea    -0x23(%edx),%eax
  800289:	3c 55                	cmp    $0x55,%al
  80028b:	0f 87 12 04 00 00    	ja     8006a3 <vprintfmt+0x45b>
  800291:	0f b6 c0             	movzbl %al,%eax
  800294:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  80029b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80029e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002a2:	eb d9                	jmp    80027d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002a7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ab:	eb d0                	jmp    80027d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002ad:	0f b6 d2             	movzbl %dl,%edx
  8002b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8002b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002be:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002c2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002c5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002c8:	83 f9 09             	cmp    $0x9,%ecx
  8002cb:	77 55                	ja     800322 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002d0:	eb e9                	jmp    8002bb <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d5:	8b 00                	mov    (%eax),%eax
  8002d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002da:	8b 45 14             	mov    0x14(%ebp),%eax
  8002dd:	8d 40 04             	lea    0x4(%eax),%eax
  8002e0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002ea:	79 91                	jns    80027d <vprintfmt+0x35>
				width = precision, precision = -1;
  8002ec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f9:	eb 82                	jmp    80027d <vprintfmt+0x35>
  8002fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002fe:	85 c0                	test   %eax,%eax
  800300:	ba 00 00 00 00       	mov    $0x0,%edx
  800305:	0f 49 d0             	cmovns %eax,%edx
  800308:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030e:	e9 6a ff ff ff       	jmp    80027d <vprintfmt+0x35>
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800316:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80031d:	e9 5b ff ff ff       	jmp    80027d <vprintfmt+0x35>
  800322:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800325:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800328:	eb bc                	jmp    8002e6 <vprintfmt+0x9e>
			lflag++;
  80032a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800330:	e9 48 ff ff ff       	jmp    80027d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800335:	8b 45 14             	mov    0x14(%ebp),%eax
  800338:	8d 78 04             	lea    0x4(%eax),%edi
  80033b:	83 ec 08             	sub    $0x8,%esp
  80033e:	53                   	push   %ebx
  80033f:	ff 30                	pushl  (%eax)
  800341:	ff d6                	call   *%esi
			break;
  800343:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800346:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800349:	e9 cf 02 00 00       	jmp    80061d <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80034e:	8b 45 14             	mov    0x14(%ebp),%eax
  800351:	8d 78 04             	lea    0x4(%eax),%edi
  800354:	8b 00                	mov    (%eax),%eax
  800356:	99                   	cltd   
  800357:	31 d0                	xor    %edx,%eax
  800359:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80035b:	83 f8 08             	cmp    $0x8,%eax
  80035e:	7f 23                	jg     800383 <vprintfmt+0x13b>
  800360:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800367:	85 d2                	test   %edx,%edx
  800369:	74 18                	je     800383 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80036b:	52                   	push   %edx
  80036c:	68 f0 0f 80 00       	push   $0x800ff0
  800371:	53                   	push   %ebx
  800372:	56                   	push   %esi
  800373:	e8 b3 fe ff ff       	call   80022b <printfmt>
  800378:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80037b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80037e:	e9 9a 02 00 00       	jmp    80061d <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800383:	50                   	push   %eax
  800384:	68 e7 0f 80 00       	push   $0x800fe7
  800389:	53                   	push   %ebx
  80038a:	56                   	push   %esi
  80038b:	e8 9b fe ff ff       	call   80022b <printfmt>
  800390:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800393:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800396:	e9 82 02 00 00       	jmp    80061d <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	83 c0 04             	add    $0x4,%eax
  8003a1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003a9:	85 ff                	test   %edi,%edi
  8003ab:	b8 e0 0f 80 00       	mov    $0x800fe0,%eax
  8003b0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b7:	0f 8e bd 00 00 00    	jle    80047a <vprintfmt+0x232>
  8003bd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003c1:	75 0e                	jne    8003d1 <vprintfmt+0x189>
  8003c3:	89 75 08             	mov    %esi,0x8(%ebp)
  8003c6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003c9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003cc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003cf:	eb 6d                	jmp    80043e <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d1:	83 ec 08             	sub    $0x8,%esp
  8003d4:	ff 75 d0             	pushl  -0x30(%ebp)
  8003d7:	57                   	push   %edi
  8003d8:	e8 6e 03 00 00       	call   80074b <strnlen>
  8003dd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003e0:	29 c1                	sub    %eax,%ecx
  8003e2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003e8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ef:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003f2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f4:	eb 0f                	jmp    800405 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8003f6:	83 ec 08             	sub    $0x8,%esp
  8003f9:	53                   	push   %ebx
  8003fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8003fd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ff:	83 ef 01             	sub    $0x1,%edi
  800402:	83 c4 10             	add    $0x10,%esp
  800405:	85 ff                	test   %edi,%edi
  800407:	7f ed                	jg     8003f6 <vprintfmt+0x1ae>
  800409:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80040c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80040f:	85 c9                	test   %ecx,%ecx
  800411:	b8 00 00 00 00       	mov    $0x0,%eax
  800416:	0f 49 c1             	cmovns %ecx,%eax
  800419:	29 c1                	sub    %eax,%ecx
  80041b:	89 75 08             	mov    %esi,0x8(%ebp)
  80041e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800421:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800424:	89 cb                	mov    %ecx,%ebx
  800426:	eb 16                	jmp    80043e <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800428:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80042c:	75 31                	jne    80045f <vprintfmt+0x217>
					putch(ch, putdat);
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	ff 75 0c             	pushl  0xc(%ebp)
  800434:	50                   	push   %eax
  800435:	ff 55 08             	call   *0x8(%ebp)
  800438:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043b:	83 eb 01             	sub    $0x1,%ebx
  80043e:	83 c7 01             	add    $0x1,%edi
  800441:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800445:	0f be c2             	movsbl %dl,%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	74 59                	je     8004a5 <vprintfmt+0x25d>
  80044c:	85 f6                	test   %esi,%esi
  80044e:	78 d8                	js     800428 <vprintfmt+0x1e0>
  800450:	83 ee 01             	sub    $0x1,%esi
  800453:	79 d3                	jns    800428 <vprintfmt+0x1e0>
  800455:	89 df                	mov    %ebx,%edi
  800457:	8b 75 08             	mov    0x8(%ebp),%esi
  80045a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045d:	eb 37                	jmp    800496 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80045f:	0f be d2             	movsbl %dl,%edx
  800462:	83 ea 20             	sub    $0x20,%edx
  800465:	83 fa 5e             	cmp    $0x5e,%edx
  800468:	76 c4                	jbe    80042e <vprintfmt+0x1e6>
					putch('?', putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 0c             	pushl  0xc(%ebp)
  800470:	6a 3f                	push   $0x3f
  800472:	ff 55 08             	call   *0x8(%ebp)
  800475:	83 c4 10             	add    $0x10,%esp
  800478:	eb c1                	jmp    80043b <vprintfmt+0x1f3>
  80047a:	89 75 08             	mov    %esi,0x8(%ebp)
  80047d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800483:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800486:	eb b6                	jmp    80043e <vprintfmt+0x1f6>
				putch(' ', putdat);
  800488:	83 ec 08             	sub    $0x8,%esp
  80048b:	53                   	push   %ebx
  80048c:	6a 20                	push   $0x20
  80048e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800490:	83 ef 01             	sub    $0x1,%edi
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	85 ff                	test   %edi,%edi
  800498:	7f ee                	jg     800488 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80049a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049d:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a0:	e9 78 01 00 00       	jmp    80061d <vprintfmt+0x3d5>
  8004a5:	89 df                	mov    %ebx,%edi
  8004a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8004aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ad:	eb e7                	jmp    800496 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004af:	83 f9 01             	cmp    $0x1,%ecx
  8004b2:	7e 3f                	jle    8004f3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8b 50 04             	mov    0x4(%eax),%edx
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004bf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c5:	8d 40 08             	lea    0x8(%eax),%eax
  8004c8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004cb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004cf:	79 5c                	jns    80052d <vprintfmt+0x2e5>
				putch('-', putdat);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	53                   	push   %ebx
  8004d5:	6a 2d                	push   $0x2d
  8004d7:	ff d6                	call   *%esi
				num = -(long long) num;
  8004d9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004dc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004df:	f7 da                	neg    %edx
  8004e1:	83 d1 00             	adc    $0x0,%ecx
  8004e4:	f7 d9                	neg    %ecx
  8004e6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004ee:	e9 10 01 00 00       	jmp    800603 <vprintfmt+0x3bb>
	else if (lflag)
  8004f3:	85 c9                	test   %ecx,%ecx
  8004f5:	75 1b                	jne    800512 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ff:	89 c1                	mov    %eax,%ecx
  800501:	c1 f9 1f             	sar    $0x1f,%ecx
  800504:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 40 04             	lea    0x4(%eax),%eax
  80050d:	89 45 14             	mov    %eax,0x14(%ebp)
  800510:	eb b9                	jmp    8004cb <vprintfmt+0x283>
		return va_arg(*ap, long);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8b 00                	mov    (%eax),%eax
  800517:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051a:	89 c1                	mov    %eax,%ecx
  80051c:	c1 f9 1f             	sar    $0x1f,%ecx
  80051f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 40 04             	lea    0x4(%eax),%eax
  800528:	89 45 14             	mov    %eax,0x14(%ebp)
  80052b:	eb 9e                	jmp    8004cb <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80052d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800530:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800533:	b8 0a 00 00 00       	mov    $0xa,%eax
  800538:	e9 c6 00 00 00       	jmp    800603 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80053d:	83 f9 01             	cmp    $0x1,%ecx
  800540:	7e 18                	jle    80055a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800542:	8b 45 14             	mov    0x14(%ebp),%eax
  800545:	8b 10                	mov    (%eax),%edx
  800547:	8b 48 04             	mov    0x4(%eax),%ecx
  80054a:	8d 40 08             	lea    0x8(%eax),%eax
  80054d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800550:	b8 0a 00 00 00       	mov    $0xa,%eax
  800555:	e9 a9 00 00 00       	jmp    800603 <vprintfmt+0x3bb>
	else if (lflag)
  80055a:	85 c9                	test   %ecx,%ecx
  80055c:	75 1a                	jne    800578 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8b 10                	mov    (%eax),%edx
  800563:	b9 00 00 00 00       	mov    $0x0,%ecx
  800568:	8d 40 04             	lea    0x4(%eax),%eax
  80056b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80056e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800573:	e9 8b 00 00 00       	jmp    800603 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 10                	mov    (%eax),%edx
  80057d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800582:	8d 40 04             	lea    0x4(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800588:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058d:	eb 74                	jmp    800603 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80058f:	83 f9 01             	cmp    $0x1,%ecx
  800592:	7e 15                	jle    8005a9 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 10                	mov    (%eax),%edx
  800599:	8b 48 04             	mov    0x4(%eax),%ecx
  80059c:	8d 40 08             	lea    0x8(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005a2:	b8 08 00 00 00       	mov    $0x8,%eax
  8005a7:	eb 5a                	jmp    800603 <vprintfmt+0x3bb>
	else if (lflag)
  8005a9:	85 c9                	test   %ecx,%ecx
  8005ab:	75 17                	jne    8005c4 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 10                	mov    (%eax),%edx
  8005b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ba:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005bd:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c2:	eb 3f                	jmp    800603 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8b 10                	mov    (%eax),%edx
  8005c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ce:	8d 40 04             	lea    0x4(%eax),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005d9:	eb 28                	jmp    800603 <vprintfmt+0x3bb>
			putch('0', putdat);
  8005db:	83 ec 08             	sub    $0x8,%esp
  8005de:	53                   	push   %ebx
  8005df:	6a 30                	push   $0x30
  8005e1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e3:	83 c4 08             	add    $0x8,%esp
  8005e6:	53                   	push   %ebx
  8005e7:	6a 78                	push   $0x78
  8005e9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005f5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005fe:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800603:	83 ec 0c             	sub    $0xc,%esp
  800606:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80060a:	57                   	push   %edi
  80060b:	ff 75 e0             	pushl  -0x20(%ebp)
  80060e:	50                   	push   %eax
  80060f:	51                   	push   %ecx
  800610:	52                   	push   %edx
  800611:	89 da                	mov    %ebx,%edx
  800613:	89 f0                	mov    %esi,%eax
  800615:	e8 45 fb ff ff       	call   80015f <printnum>
			break;
  80061a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80061d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800620:	83 c7 01             	add    $0x1,%edi
  800623:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800627:	83 f8 25             	cmp    $0x25,%eax
  80062a:	0f 84 2f fc ff ff    	je     80025f <vprintfmt+0x17>
			if (ch == '\0')
  800630:	85 c0                	test   %eax,%eax
  800632:	0f 84 8b 00 00 00    	je     8006c3 <vprintfmt+0x47b>
			putch(ch, putdat);
  800638:	83 ec 08             	sub    $0x8,%esp
  80063b:	53                   	push   %ebx
  80063c:	50                   	push   %eax
  80063d:	ff d6                	call   *%esi
  80063f:	83 c4 10             	add    $0x10,%esp
  800642:	eb dc                	jmp    800620 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7e 15                	jle    80065e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 10                	mov    (%eax),%edx
  80064e:	8b 48 04             	mov    0x4(%eax),%ecx
  800651:	8d 40 08             	lea    0x8(%eax),%eax
  800654:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800657:	b8 10 00 00 00       	mov    $0x10,%eax
  80065c:	eb a5                	jmp    800603 <vprintfmt+0x3bb>
	else if (lflag)
  80065e:	85 c9                	test   %ecx,%ecx
  800660:	75 17                	jne    800679 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 10                	mov    (%eax),%edx
  800667:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800672:	b8 10 00 00 00       	mov    $0x10,%eax
  800677:	eb 8a                	jmp    800603 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800679:	8b 45 14             	mov    0x14(%ebp),%eax
  80067c:	8b 10                	mov    (%eax),%edx
  80067e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800683:	8d 40 04             	lea    0x4(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800689:	b8 10 00 00 00       	mov    $0x10,%eax
  80068e:	e9 70 ff ff ff       	jmp    800603 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 25                	push   $0x25
  800699:	ff d6                	call   *%esi
			break;
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	e9 7a ff ff ff       	jmp    80061d <vprintfmt+0x3d5>
			putch('%', putdat);
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	53                   	push   %ebx
  8006a7:	6a 25                	push   $0x25
  8006a9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	89 f8                	mov    %edi,%eax
  8006b0:	eb 03                	jmp    8006b5 <vprintfmt+0x46d>
  8006b2:	83 e8 01             	sub    $0x1,%eax
  8006b5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b9:	75 f7                	jne    8006b2 <vprintfmt+0x46a>
  8006bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006be:	e9 5a ff ff ff       	jmp    80061d <vprintfmt+0x3d5>
}
  8006c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c6:	5b                   	pop    %ebx
  8006c7:	5e                   	pop    %esi
  8006c8:	5f                   	pop    %edi
  8006c9:	5d                   	pop    %ebp
  8006ca:	c3                   	ret    

008006cb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 18             	sub    $0x18,%esp
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 26                	je     800712 <vsnprintf+0x47>
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	7e 22                	jle    800712 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f0:	ff 75 14             	pushl  0x14(%ebp)
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	68 0e 02 80 00       	push   $0x80020e
  8006ff:	e8 44 fb ff ff       	call   800248 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	83 c4 10             	add    $0x10,%esp
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    
		return -E_INVAL;
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800717:	eb f7                	jmp    800710 <vsnprintf+0x45>

00800719 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800719:	55                   	push   %ebp
  80071a:	89 e5                	mov    %esp,%ebp
  80071c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800722:	50                   	push   %eax
  800723:	ff 75 10             	pushl  0x10(%ebp)
  800726:	ff 75 0c             	pushl  0xc(%ebp)
  800729:	ff 75 08             	pushl  0x8(%ebp)
  80072c:	e8 9a ff ff ff       	call   8006cb <vsnprintf>
	va_end(ap);

	return rc;
}
  800731:	c9                   	leave  
  800732:	c3                   	ret    

00800733 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800733:	55                   	push   %ebp
  800734:	89 e5                	mov    %esp,%ebp
  800736:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800739:	b8 00 00 00 00       	mov    $0x0,%eax
  80073e:	eb 03                	jmp    800743 <strlen+0x10>
		n++;
  800740:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800743:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800747:	75 f7                	jne    800740 <strlen+0xd>
	return n;
}
  800749:	5d                   	pop    %ebp
  80074a:	c3                   	ret    

0080074b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800751:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800754:	b8 00 00 00 00       	mov    $0x0,%eax
  800759:	eb 03                	jmp    80075e <strnlen+0x13>
		n++;
  80075b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075e:	39 d0                	cmp    %edx,%eax
  800760:	74 06                	je     800768 <strnlen+0x1d>
  800762:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800766:	75 f3                	jne    80075b <strnlen+0x10>
	return n;
}
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	53                   	push   %ebx
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800774:	89 c2                	mov    %eax,%edx
  800776:	83 c1 01             	add    $0x1,%ecx
  800779:	83 c2 01             	add    $0x1,%edx
  80077c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800780:	88 5a ff             	mov    %bl,-0x1(%edx)
  800783:	84 db                	test   %bl,%bl
  800785:	75 ef                	jne    800776 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800787:	5b                   	pop    %ebx
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    

0080078a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	53                   	push   %ebx
  80078e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800791:	53                   	push   %ebx
  800792:	e8 9c ff ff ff       	call   800733 <strlen>
  800797:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079a:	ff 75 0c             	pushl  0xc(%ebp)
  80079d:	01 d8                	add    %ebx,%eax
  80079f:	50                   	push   %eax
  8007a0:	e8 c5 ff ff ff       	call   80076a <strcpy>
	return dst;
}
  8007a5:	89 d8                	mov    %ebx,%eax
  8007a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007aa:	c9                   	leave  
  8007ab:	c3                   	ret    

008007ac <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	56                   	push   %esi
  8007b0:	53                   	push   %ebx
  8007b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b7:	89 f3                	mov    %esi,%ebx
  8007b9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bc:	89 f2                	mov    %esi,%edx
  8007be:	eb 0f                	jmp    8007cf <strncpy+0x23>
		*dst++ = *src;
  8007c0:	83 c2 01             	add    $0x1,%edx
  8007c3:	0f b6 01             	movzbl (%ecx),%eax
  8007c6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007cc:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007cf:	39 da                	cmp    %ebx,%edx
  8007d1:	75 ed                	jne    8007c0 <strncpy+0x14>
	}
	return ret;
}
  8007d3:	89 f0                	mov    %esi,%eax
  8007d5:	5b                   	pop    %ebx
  8007d6:	5e                   	pop    %esi
  8007d7:	5d                   	pop    %ebp
  8007d8:	c3                   	ret    

008007d9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	56                   	push   %esi
  8007dd:	53                   	push   %ebx
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007e7:	89 f0                	mov    %esi,%eax
  8007e9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ed:	85 c9                	test   %ecx,%ecx
  8007ef:	75 0b                	jne    8007fc <strlcpy+0x23>
  8007f1:	eb 17                	jmp    80080a <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f3:	83 c2 01             	add    $0x1,%edx
  8007f6:	83 c0 01             	add    $0x1,%eax
  8007f9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007fc:	39 d8                	cmp    %ebx,%eax
  8007fe:	74 07                	je     800807 <strlcpy+0x2e>
  800800:	0f b6 0a             	movzbl (%edx),%ecx
  800803:	84 c9                	test   %cl,%cl
  800805:	75 ec                	jne    8007f3 <strlcpy+0x1a>
		*dst = '\0';
  800807:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80080a:	29 f0                	sub    %esi,%eax
}
  80080c:	5b                   	pop    %ebx
  80080d:	5e                   	pop    %esi
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800816:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800819:	eb 06                	jmp    800821 <strcmp+0x11>
		p++, q++;
  80081b:	83 c1 01             	add    $0x1,%ecx
  80081e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800821:	0f b6 01             	movzbl (%ecx),%eax
  800824:	84 c0                	test   %al,%al
  800826:	74 04                	je     80082c <strcmp+0x1c>
  800828:	3a 02                	cmp    (%edx),%al
  80082a:	74 ef                	je     80081b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082c:	0f b6 c0             	movzbl %al,%eax
  80082f:	0f b6 12             	movzbl (%edx),%edx
  800832:	29 d0                	sub    %edx,%eax
}
  800834:	5d                   	pop    %ebp
  800835:	c3                   	ret    

00800836 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800836:	55                   	push   %ebp
  800837:	89 e5                	mov    %esp,%ebp
  800839:	53                   	push   %ebx
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800840:	89 c3                	mov    %eax,%ebx
  800842:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800845:	eb 06                	jmp    80084d <strncmp+0x17>
		n--, p++, q++;
  800847:	83 c0 01             	add    $0x1,%eax
  80084a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80084d:	39 d8                	cmp    %ebx,%eax
  80084f:	74 16                	je     800867 <strncmp+0x31>
  800851:	0f b6 08             	movzbl (%eax),%ecx
  800854:	84 c9                	test   %cl,%cl
  800856:	74 04                	je     80085c <strncmp+0x26>
  800858:	3a 0a                	cmp    (%edx),%cl
  80085a:	74 eb                	je     800847 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085c:	0f b6 00             	movzbl (%eax),%eax
  80085f:	0f b6 12             	movzbl (%edx),%edx
  800862:	29 d0                	sub    %edx,%eax
}
  800864:	5b                   	pop    %ebx
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    
		return 0;
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
  80086c:	eb f6                	jmp    800864 <strncmp+0x2e>

0080086e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800878:	0f b6 10             	movzbl (%eax),%edx
  80087b:	84 d2                	test   %dl,%dl
  80087d:	74 09                	je     800888 <strchr+0x1a>
		if (*s == c)
  80087f:	38 ca                	cmp    %cl,%dl
  800881:	74 0a                	je     80088d <strchr+0x1f>
	for (; *s; s++)
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	eb f0                	jmp    800878 <strchr+0xa>
			return (char *) s;
	return 0;
  800888:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088d:	5d                   	pop    %ebp
  80088e:	c3                   	ret    

0080088f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088f:	55                   	push   %ebp
  800890:	89 e5                	mov    %esp,%ebp
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800899:	eb 03                	jmp    80089e <strfind+0xf>
  80089b:	83 c0 01             	add    $0x1,%eax
  80089e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a1:	38 ca                	cmp    %cl,%dl
  8008a3:	74 04                	je     8008a9 <strfind+0x1a>
  8008a5:	84 d2                	test   %dl,%dl
  8008a7:	75 f2                	jne    80089b <strfind+0xc>
			break;
	return (char *) s;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	57                   	push   %edi
  8008af:	56                   	push   %esi
  8008b0:	53                   	push   %ebx
  8008b1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b7:	85 c9                	test   %ecx,%ecx
  8008b9:	74 13                	je     8008ce <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c1:	75 05                	jne    8008c8 <memset+0x1d>
  8008c3:	f6 c1 03             	test   $0x3,%cl
  8008c6:	74 0d                	je     8008d5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cb:	fc                   	cld    
  8008cc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ce:	89 f8                	mov    %edi,%eax
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5f                   	pop    %edi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    
		c &= 0xFF;
  8008d5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d9:	89 d3                	mov    %edx,%ebx
  8008db:	c1 e3 08             	shl    $0x8,%ebx
  8008de:	89 d0                	mov    %edx,%eax
  8008e0:	c1 e0 18             	shl    $0x18,%eax
  8008e3:	89 d6                	mov    %edx,%esi
  8008e5:	c1 e6 10             	shl    $0x10,%esi
  8008e8:	09 f0                	or     %esi,%eax
  8008ea:	09 c2                	or     %eax,%edx
  8008ec:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008ee:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	fc                   	cld    
  8008f4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f6:	eb d6                	jmp    8008ce <memset+0x23>

008008f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	57                   	push   %edi
  8008fc:	56                   	push   %esi
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8b 75 0c             	mov    0xc(%ebp),%esi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800906:	39 c6                	cmp    %eax,%esi
  800908:	73 35                	jae    80093f <memmove+0x47>
  80090a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090d:	39 c2                	cmp    %eax,%edx
  80090f:	76 2e                	jbe    80093f <memmove+0x47>
		s += n;
		d += n;
  800911:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800914:	89 d6                	mov    %edx,%esi
  800916:	09 fe                	or     %edi,%esi
  800918:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091e:	74 0c                	je     80092c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800920:	83 ef 01             	sub    $0x1,%edi
  800923:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800926:	fd                   	std    
  800927:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800929:	fc                   	cld    
  80092a:	eb 21                	jmp    80094d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092c:	f6 c1 03             	test   $0x3,%cl
  80092f:	75 ef                	jne    800920 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800931:	83 ef 04             	sub    $0x4,%edi
  800934:	8d 72 fc             	lea    -0x4(%edx),%esi
  800937:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80093a:	fd                   	std    
  80093b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093d:	eb ea                	jmp    800929 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093f:	89 f2                	mov    %esi,%edx
  800941:	09 c2                	or     %eax,%edx
  800943:	f6 c2 03             	test   $0x3,%dl
  800946:	74 09                	je     800951 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800948:	89 c7                	mov    %eax,%edi
  80094a:	fc                   	cld    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 f2                	jne    800948 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800956:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800959:	89 c7                	mov    %eax,%edi
  80095b:	fc                   	cld    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb ed                	jmp    80094d <memmove+0x55>

00800960 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800963:	ff 75 10             	pushl  0x10(%ebp)
  800966:	ff 75 0c             	pushl  0xc(%ebp)
  800969:	ff 75 08             	pushl  0x8(%ebp)
  80096c:	e8 87 ff ff ff       	call   8008f8 <memmove>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097e:	89 c6                	mov    %eax,%esi
  800980:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800983:	39 f0                	cmp    %esi,%eax
  800985:	74 1c                	je     8009a3 <memcmp+0x30>
		if (*s1 != *s2)
  800987:	0f b6 08             	movzbl (%eax),%ecx
  80098a:	0f b6 1a             	movzbl (%edx),%ebx
  80098d:	38 d9                	cmp    %bl,%cl
  80098f:	75 08                	jne    800999 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800991:	83 c0 01             	add    $0x1,%eax
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	eb ea                	jmp    800983 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800999:	0f b6 c1             	movzbl %cl,%eax
  80099c:	0f b6 db             	movzbl %bl,%ebx
  80099f:	29 d8                	sub    %ebx,%eax
  8009a1:	eb 05                	jmp    8009a8 <memcmp+0x35>
	}

	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b5:	89 c2                	mov    %eax,%edx
  8009b7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009ba:	39 d0                	cmp    %edx,%eax
  8009bc:	73 09                	jae    8009c7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009be:	38 08                	cmp    %cl,(%eax)
  8009c0:	74 05                	je     8009c7 <memfind+0x1b>
	for (; s < ends; s++)
  8009c2:	83 c0 01             	add    $0x1,%eax
  8009c5:	eb f3                	jmp    8009ba <memfind+0xe>
			break;
	return (void *) s;
}
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	57                   	push   %edi
  8009cd:	56                   	push   %esi
  8009ce:	53                   	push   %ebx
  8009cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d5:	eb 03                	jmp    8009da <strtol+0x11>
		s++;
  8009d7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009da:	0f b6 01             	movzbl (%ecx),%eax
  8009dd:	3c 20                	cmp    $0x20,%al
  8009df:	74 f6                	je     8009d7 <strtol+0xe>
  8009e1:	3c 09                	cmp    $0x9,%al
  8009e3:	74 f2                	je     8009d7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009e5:	3c 2b                	cmp    $0x2b,%al
  8009e7:	74 2e                	je     800a17 <strtol+0x4e>
	int neg = 0;
  8009e9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009ee:	3c 2d                	cmp    $0x2d,%al
  8009f0:	74 2f                	je     800a21 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009f8:	75 05                	jne    8009ff <strtol+0x36>
  8009fa:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fd:	74 2c                	je     800a2b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ff:	85 db                	test   %ebx,%ebx
  800a01:	75 0a                	jne    800a0d <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a03:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a08:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0b:	74 28                	je     800a35 <strtol+0x6c>
		base = 10;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a12:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a15:	eb 50                	jmp    800a67 <strtol+0x9e>
		s++;
  800a17:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a1f:	eb d1                	jmp    8009f2 <strtol+0x29>
		s++, neg = 1;
  800a21:	83 c1 01             	add    $0x1,%ecx
  800a24:	bf 01 00 00 00       	mov    $0x1,%edi
  800a29:	eb c7                	jmp    8009f2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2f:	74 0e                	je     800a3f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a31:	85 db                	test   %ebx,%ebx
  800a33:	75 d8                	jne    800a0d <strtol+0x44>
		s++, base = 8;
  800a35:	83 c1 01             	add    $0x1,%ecx
  800a38:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a3d:	eb ce                	jmp    800a0d <strtol+0x44>
		s += 2, base = 16;
  800a3f:	83 c1 02             	add    $0x2,%ecx
  800a42:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a47:	eb c4                	jmp    800a0d <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	80 fb 19             	cmp    $0x19,%bl
  800a51:	77 29                	ja     800a7c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a53:	0f be d2             	movsbl %dl,%edx
  800a56:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a59:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5c:	7d 30                	jge    800a8e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a65:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a67:	0f b6 11             	movzbl (%ecx),%edx
  800a6a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 09             	cmp    $0x9,%bl
  800a72:	77 d5                	ja     800a49 <strtol+0x80>
			dig = *s - '0';
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 30             	sub    $0x30,%edx
  800a7a:	eb dd                	jmp    800a59 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a7c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a7f:	89 f3                	mov    %esi,%ebx
  800a81:	80 fb 19             	cmp    $0x19,%bl
  800a84:	77 08                	ja     800a8e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a86:	0f be d2             	movsbl %dl,%edx
  800a89:	83 ea 37             	sub    $0x37,%edx
  800a8c:	eb cb                	jmp    800a59 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a92:	74 05                	je     800a99 <strtol+0xd0>
		*endptr = (char *) s;
  800a94:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a97:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a99:	89 c2                	mov    %eax,%edx
  800a9b:	f7 da                	neg    %edx
  800a9d:	85 ff                	test   %edi,%edi
  800a9f:	0f 45 c2             	cmovne %edx,%eax
}
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5f                   	pop    %edi
  800aa5:	5d                   	pop    %ebp
  800aa6:	c3                   	ret    

00800aa7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	57                   	push   %edi
  800aab:	56                   	push   %esi
  800aac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aad:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab8:	89 c3                	mov    %eax,%ebx
  800aba:	89 c7                	mov    %eax,%edi
  800abc:	89 c6                	mov    %eax,%esi
  800abe:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac0:	5b                   	pop    %ebx
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
	asm volatile("int %1\n"
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad5:	89 d1                	mov    %edx,%ecx
  800ad7:	89 d3                	mov    %edx,%ebx
  800ad9:	89 d7                	mov    %edx,%edi
  800adb:	89 d6                	mov    %edx,%esi
  800add:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800adf:	5b                   	pop    %ebx
  800ae0:	5e                   	pop    %esi
  800ae1:	5f                   	pop    %edi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	57                   	push   %edi
  800ae8:	56                   	push   %esi
  800ae9:	53                   	push   %ebx
  800aea:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af2:	8b 55 08             	mov    0x8(%ebp),%edx
  800af5:	b8 03 00 00 00       	mov    $0x3,%eax
  800afa:	89 cb                	mov    %ecx,%ebx
  800afc:	89 cf                	mov    %ecx,%edi
  800afe:	89 ce                	mov    %ecx,%esi
  800b00:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b02:	85 c0                	test   %eax,%eax
  800b04:	7f 08                	jg     800b0e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0e:	83 ec 0c             	sub    $0xc,%esp
  800b11:	50                   	push   %eax
  800b12:	6a 03                	push   $0x3
  800b14:	68 24 12 80 00       	push   $0x801224
  800b19:	6a 23                	push   $0x23
  800b1b:	68 41 12 80 00       	push   $0x801241
  800b20:	e8 ed 01 00 00       	call   800d12 <_panic>

00800b25 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b30:	b8 02 00 00 00       	mov    $0x2,%eax
  800b35:	89 d1                	mov    %edx,%ecx
  800b37:	89 d3                	mov    %edx,%ebx
  800b39:	89 d7                	mov    %edx,%edi
  800b3b:	89 d6                	mov    %edx,%esi
  800b3d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_yield>:

void
sys_yield(void)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b54:	89 d1                	mov    %edx,%ecx
  800b56:	89 d3                	mov    %edx,%ebx
  800b58:	89 d7                	mov    %edx,%edi
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b5e:	5b                   	pop    %ebx
  800b5f:	5e                   	pop    %esi
  800b60:	5f                   	pop    %edi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    

00800b63 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6c:	be 00 00 00 00       	mov    $0x0,%esi
  800b71:	8b 55 08             	mov    0x8(%ebp),%edx
  800b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b77:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b7f:	89 f7                	mov    %esi,%edi
  800b81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b83:	85 c0                	test   %eax,%eax
  800b85:	7f 08                	jg     800b8f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8f:	83 ec 0c             	sub    $0xc,%esp
  800b92:	50                   	push   %eax
  800b93:	6a 04                	push   $0x4
  800b95:	68 24 12 80 00       	push   $0x801224
  800b9a:	6a 23                	push   $0x23
  800b9c:	68 41 12 80 00       	push   $0x801241
  800ba1:	e8 6c 01 00 00       	call   800d12 <_panic>

00800ba6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800baf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb5:	b8 05 00 00 00       	mov    $0x5,%eax
  800bba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc0:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc5:	85 c0                	test   %eax,%eax
  800bc7:	7f 08                	jg     800bd1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	50                   	push   %eax
  800bd5:	6a 05                	push   $0x5
  800bd7:	68 24 12 80 00       	push   $0x801224
  800bdc:	6a 23                	push   $0x23
  800bde:	68 41 12 80 00       	push   $0x801241
  800be3:	e8 2a 01 00 00       	call   800d12 <_panic>

00800be8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	57                   	push   %edi
  800bec:	56                   	push   %esi
  800bed:	53                   	push   %ebx
  800bee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfc:	b8 06 00 00 00       	mov    $0x6,%eax
  800c01:	89 df                	mov    %ebx,%edi
  800c03:	89 de                	mov    %ebx,%esi
  800c05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c07:	85 c0                	test   %eax,%eax
  800c09:	7f 08                	jg     800c13 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0e:	5b                   	pop    %ebx
  800c0f:	5e                   	pop    %esi
  800c10:	5f                   	pop    %edi
  800c11:	5d                   	pop    %ebp
  800c12:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	50                   	push   %eax
  800c17:	6a 06                	push   $0x6
  800c19:	68 24 12 80 00       	push   $0x801224
  800c1e:	6a 23                	push   $0x23
  800c20:	68 41 12 80 00       	push   $0x801241
  800c25:	e8 e8 00 00 00       	call   800d12 <_panic>

00800c2a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	57                   	push   %edi
  800c2e:	56                   	push   %esi
  800c2f:	53                   	push   %ebx
  800c30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c38:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c43:	89 df                	mov    %ebx,%edi
  800c45:	89 de                	mov    %ebx,%esi
  800c47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c49:	85 c0                	test   %eax,%eax
  800c4b:	7f 08                	jg     800c55 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c55:	83 ec 0c             	sub    $0xc,%esp
  800c58:	50                   	push   %eax
  800c59:	6a 08                	push   $0x8
  800c5b:	68 24 12 80 00       	push   $0x801224
  800c60:	6a 23                	push   $0x23
  800c62:	68 41 12 80 00       	push   $0x801241
  800c67:	e8 a6 00 00 00       	call   800d12 <_panic>

00800c6c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	57                   	push   %edi
  800c70:	56                   	push   %esi
  800c71:	53                   	push   %ebx
  800c72:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c80:	b8 09 00 00 00       	mov    $0x9,%eax
  800c85:	89 df                	mov    %ebx,%edi
  800c87:	89 de                	mov    %ebx,%esi
  800c89:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7f 08                	jg     800c97 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c97:	83 ec 0c             	sub    $0xc,%esp
  800c9a:	50                   	push   %eax
  800c9b:	6a 09                	push   $0x9
  800c9d:	68 24 12 80 00       	push   $0x801224
  800ca2:	6a 23                	push   $0x23
  800ca4:	68 41 12 80 00       	push   $0x801241
  800ca9:	e8 64 00 00 00       	call   800d12 <_panic>

00800cae <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cae:	55                   	push   %ebp
  800caf:	89 e5                	mov    %esp,%ebp
  800cb1:	57                   	push   %edi
  800cb2:	56                   	push   %esi
  800cb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cbf:	be 00 00 00 00       	mov    $0x0,%esi
  800cc4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cca:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce7:	89 cb                	mov    %ecx,%ebx
  800ce9:	89 cf                	mov    %ecx,%edi
  800ceb:	89 ce                	mov    %ecx,%esi
  800ced:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	7f 08                	jg     800cfb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	50                   	push   %eax
  800cff:	6a 0c                	push   $0xc
  800d01:	68 24 12 80 00       	push   $0x801224
  800d06:	6a 23                	push   $0x23
  800d08:	68 41 12 80 00       	push   $0x801241
  800d0d:	e8 00 00 00 00       	call   800d12 <_panic>

00800d12 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d17:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d1a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d20:	e8 00 fe ff ff       	call   800b25 <sys_getenvid>
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	ff 75 0c             	pushl  0xc(%ebp)
  800d2b:	ff 75 08             	pushl  0x8(%ebp)
  800d2e:	56                   	push   %esi
  800d2f:	50                   	push   %eax
  800d30:	68 50 12 80 00       	push   $0x801250
  800d35:	e8 11 f4 ff ff       	call   80014b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d3a:	83 c4 18             	add    $0x18,%esp
  800d3d:	53                   	push   %ebx
  800d3e:	ff 75 10             	pushl  0x10(%ebp)
  800d41:	e8 b4 f3 ff ff       	call   8000fa <vcprintf>
	cprintf("\n");
  800d46:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  800d4d:	e8 f9 f3 ff ff       	call   80014b <cprintf>
  800d52:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d55:	cc                   	int3   
  800d56:	eb fd                	jmp    800d55 <_panic+0x43>
  800d58:	66 90                	xchg   %ax,%ax
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	66 90                	xchg   %ax,%ax
  800d5e:	66 90                	xchg   %ax,%ax

00800d60 <__udivdi3>:
  800d60:	55                   	push   %ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 1c             	sub    $0x1c,%esp
  800d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d77:	85 d2                	test   %edx,%edx
  800d79:	75 35                	jne    800db0 <__udivdi3+0x50>
  800d7b:	39 f3                	cmp    %esi,%ebx
  800d7d:	0f 87 bd 00 00 00    	ja     800e40 <__udivdi3+0xe0>
  800d83:	85 db                	test   %ebx,%ebx
  800d85:	89 d9                	mov    %ebx,%ecx
  800d87:	75 0b                	jne    800d94 <__udivdi3+0x34>
  800d89:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8e:	31 d2                	xor    %edx,%edx
  800d90:	f7 f3                	div    %ebx
  800d92:	89 c1                	mov    %eax,%ecx
  800d94:	31 d2                	xor    %edx,%edx
  800d96:	89 f0                	mov    %esi,%eax
  800d98:	f7 f1                	div    %ecx
  800d9a:	89 c6                	mov    %eax,%esi
  800d9c:	89 e8                	mov    %ebp,%eax
  800d9e:	89 f7                	mov    %esi,%edi
  800da0:	f7 f1                	div    %ecx
  800da2:	89 fa                	mov    %edi,%edx
  800da4:	83 c4 1c             	add    $0x1c,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    
  800dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800db0:	39 f2                	cmp    %esi,%edx
  800db2:	77 7c                	ja     800e30 <__udivdi3+0xd0>
  800db4:	0f bd fa             	bsr    %edx,%edi
  800db7:	83 f7 1f             	xor    $0x1f,%edi
  800dba:	0f 84 98 00 00 00    	je     800e58 <__udivdi3+0xf8>
  800dc0:	89 f9                	mov    %edi,%ecx
  800dc2:	b8 20 00 00 00       	mov    $0x20,%eax
  800dc7:	29 f8                	sub    %edi,%eax
  800dc9:	d3 e2                	shl    %cl,%edx
  800dcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dcf:	89 c1                	mov    %eax,%ecx
  800dd1:	89 da                	mov    %ebx,%edx
  800dd3:	d3 ea                	shr    %cl,%edx
  800dd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dd9:	09 d1                	or     %edx,%ecx
  800ddb:	89 f2                	mov    %esi,%edx
  800ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e3                	shl    %cl,%ebx
  800de5:	89 c1                	mov    %eax,%ecx
  800de7:	d3 ea                	shr    %cl,%edx
  800de9:	89 f9                	mov    %edi,%ecx
  800deb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800def:	d3 e6                	shl    %cl,%esi
  800df1:	89 eb                	mov    %ebp,%ebx
  800df3:	89 c1                	mov    %eax,%ecx
  800df5:	d3 eb                	shr    %cl,%ebx
  800df7:	09 de                	or     %ebx,%esi
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	f7 74 24 08          	divl   0x8(%esp)
  800dff:	89 d6                	mov    %edx,%esi
  800e01:	89 c3                	mov    %eax,%ebx
  800e03:	f7 64 24 0c          	mull   0xc(%esp)
  800e07:	39 d6                	cmp    %edx,%esi
  800e09:	72 0c                	jb     800e17 <__udivdi3+0xb7>
  800e0b:	89 f9                	mov    %edi,%ecx
  800e0d:	d3 e5                	shl    %cl,%ebp
  800e0f:	39 c5                	cmp    %eax,%ebp
  800e11:	73 5d                	jae    800e70 <__udivdi3+0x110>
  800e13:	39 d6                	cmp    %edx,%esi
  800e15:	75 59                	jne    800e70 <__udivdi3+0x110>
  800e17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e1a:	31 ff                	xor    %edi,%edi
  800e1c:	89 fa                	mov    %edi,%edx
  800e1e:	83 c4 1c             	add    $0x1c,%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
  800e26:	8d 76 00             	lea    0x0(%esi),%esi
  800e29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	31 c0                	xor    %eax,%eax
  800e34:	89 fa                	mov    %edi,%edx
  800e36:	83 c4 1c             	add    $0x1c,%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    
  800e3e:	66 90                	xchg   %ax,%ax
  800e40:	31 ff                	xor    %edi,%edi
  800e42:	89 e8                	mov    %ebp,%eax
  800e44:	89 f2                	mov    %esi,%edx
  800e46:	f7 f3                	div    %ebx
  800e48:	89 fa                	mov    %edi,%edx
  800e4a:	83 c4 1c             	add    $0x1c,%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
  800e52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	72 06                	jb     800e62 <__udivdi3+0x102>
  800e5c:	31 c0                	xor    %eax,%eax
  800e5e:	39 eb                	cmp    %ebp,%ebx
  800e60:	77 d2                	ja     800e34 <__udivdi3+0xd4>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	eb cb                	jmp    800e34 <__udivdi3+0xd4>
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 d8                	mov    %ebx,%eax
  800e72:	31 ff                	xor    %edi,%edi
  800e74:	eb be                	jmp    800e34 <__udivdi3+0xd4>
  800e76:	66 90                	xchg   %ax,%ax
  800e78:	66 90                	xchg   %ax,%ax
  800e7a:	66 90                	xchg   %ax,%ax
  800e7c:	66 90                	xchg   %ax,%ax
  800e7e:	66 90                	xchg   %ax,%ax

00800e80 <__umoddi3>:
  800e80:	55                   	push   %ebp
  800e81:	57                   	push   %edi
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	83 ec 1c             	sub    $0x1c,%esp
  800e87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e97:	85 ed                	test   %ebp,%ebp
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	89 da                	mov    %ebx,%edx
  800e9d:	75 19                	jne    800eb8 <__umoddi3+0x38>
  800e9f:	39 df                	cmp    %ebx,%edi
  800ea1:	0f 86 b1 00 00 00    	jbe    800f58 <__umoddi3+0xd8>
  800ea7:	f7 f7                	div    %edi
  800ea9:	89 d0                	mov    %edx,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	83 c4 1c             	add    $0x1c,%esp
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    
  800eb5:	8d 76 00             	lea    0x0(%esi),%esi
  800eb8:	39 dd                	cmp    %ebx,%ebp
  800eba:	77 f1                	ja     800ead <__umoddi3+0x2d>
  800ebc:	0f bd cd             	bsr    %ebp,%ecx
  800ebf:	83 f1 1f             	xor    $0x1f,%ecx
  800ec2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ec6:	0f 84 b4 00 00 00    	je     800f80 <__umoddi3+0x100>
  800ecc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ed1:	89 c2                	mov    %eax,%edx
  800ed3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ed7:	29 c2                	sub    %eax,%edx
  800ed9:	89 c1                	mov    %eax,%ecx
  800edb:	89 f8                	mov    %edi,%eax
  800edd:	d3 e5                	shl    %cl,%ebp
  800edf:	89 d1                	mov    %edx,%ecx
  800ee1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ee5:	d3 e8                	shr    %cl,%eax
  800ee7:	09 c5                	or     %eax,%ebp
  800ee9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eed:	89 c1                	mov    %eax,%ecx
  800eef:	d3 e7                	shl    %cl,%edi
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ef7:	89 df                	mov    %ebx,%edi
  800ef9:	d3 ef                	shr    %cl,%edi
  800efb:	89 c1                	mov    %eax,%ecx
  800efd:	89 f0                	mov    %esi,%eax
  800eff:	d3 e3                	shl    %cl,%ebx
  800f01:	89 d1                	mov    %edx,%ecx
  800f03:	89 fa                	mov    %edi,%edx
  800f05:	d3 e8                	shr    %cl,%eax
  800f07:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f0c:	09 d8                	or     %ebx,%eax
  800f0e:	f7 f5                	div    %ebp
  800f10:	d3 e6                	shl    %cl,%esi
  800f12:	89 d1                	mov    %edx,%ecx
  800f14:	f7 64 24 08          	mull   0x8(%esp)
  800f18:	39 d1                	cmp    %edx,%ecx
  800f1a:	89 c3                	mov    %eax,%ebx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	72 06                	jb     800f26 <__umoddi3+0xa6>
  800f20:	75 0e                	jne    800f30 <__umoddi3+0xb0>
  800f22:	39 c6                	cmp    %eax,%esi
  800f24:	73 0a                	jae    800f30 <__umoddi3+0xb0>
  800f26:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f2a:	19 ea                	sbb    %ebp,%edx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	89 c3                	mov    %eax,%ebx
  800f30:	89 ca                	mov    %ecx,%edx
  800f32:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f37:	29 de                	sub    %ebx,%esi
  800f39:	19 fa                	sbb    %edi,%edx
  800f3b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f3f:	89 d0                	mov    %edx,%eax
  800f41:	d3 e0                	shl    %cl,%eax
  800f43:	89 d9                	mov    %ebx,%ecx
  800f45:	d3 ee                	shr    %cl,%esi
  800f47:	d3 ea                	shr    %cl,%edx
  800f49:	09 f0                	or     %esi,%eax
  800f4b:	83 c4 1c             	add    $0x1c,%esp
  800f4e:	5b                   	pop    %ebx
  800f4f:	5e                   	pop    %esi
  800f50:	5f                   	pop    %edi
  800f51:	5d                   	pop    %ebp
  800f52:	c3                   	ret    
  800f53:	90                   	nop
  800f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f58:	85 ff                	test   %edi,%edi
  800f5a:	89 f9                	mov    %edi,%ecx
  800f5c:	75 0b                	jne    800f69 <__umoddi3+0xe9>
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f7                	div    %edi
  800f67:	89 c1                	mov    %eax,%ecx
  800f69:	89 d8                	mov    %ebx,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f1                	div    %ecx
  800f6f:	89 f0                	mov    %esi,%eax
  800f71:	f7 f1                	div    %ecx
  800f73:	e9 31 ff ff ff       	jmp    800ea9 <__umoddi3+0x29>
  800f78:	90                   	nop
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	39 dd                	cmp    %ebx,%ebp
  800f82:	72 08                	jb     800f8c <__umoddi3+0x10c>
  800f84:	39 f7                	cmp    %esi,%edi
  800f86:	0f 87 21 ff ff ff    	ja     800ead <__umoddi3+0x2d>
  800f8c:	89 da                	mov    %ebx,%edx
  800f8e:	89 f0                	mov    %esi,%eax
  800f90:	29 f8                	sub    %edi,%eax
  800f92:	19 ea                	sbb    %ebp,%edx
  800f94:	e9 14 ff ff ff       	jmp    800ead <__umoddi3+0x2d>
