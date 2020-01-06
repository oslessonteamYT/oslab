
obj/user/faultreadkernel：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 a0 0f 80 00       	push   $0x800fa0
  800044:	e8 f2 00 00 00       	call   80013b <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800059:	e8 b7 0a 00 00       	call   800b15 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 33 0a 00 00       	call   800ad4 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	53                   	push   %ebx
  8000aa:	83 ec 04             	sub    $0x4,%esp
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b0:	8b 13                	mov    (%ebx),%edx
  8000b2:	8d 42 01             	lea    0x1(%edx),%eax
  8000b5:	89 03                	mov    %eax,(%ebx)
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000c3:	74 09                	je     8000ce <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000cc:	c9                   	leave  
  8000cd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000ce:	83 ec 08             	sub    $0x8,%esp
  8000d1:	68 ff 00 00 00       	push   $0xff
  8000d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d9:	50                   	push   %eax
  8000da:	e8 b8 09 00 00       	call   800a97 <sys_cputs>
		b->idx = 0;
  8000df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	eb db                	jmp    8000c5 <putch+0x1f>

008000ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000fa:	00 00 00 
	b.cnt = 0;
  8000fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800104:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	ff 75 08             	pushl  0x8(%ebp)
  80010d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800113:	50                   	push   %eax
  800114:	68 a6 00 80 00       	push   $0x8000a6
  800119:	e8 1a 01 00 00       	call   800238 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80011e:	83 c4 08             	add    $0x8,%esp
  800121:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800127:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	e8 64 09 00 00       	call   800a97 <sys_cputs>

	return b.cnt;
}
  800133:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800141:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800144:	50                   	push   %eax
  800145:	ff 75 08             	pushl  0x8(%ebp)
  800148:	e8 9d ff ff ff       	call   8000ea <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	57                   	push   %edi
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 1c             	sub    $0x1c,%esp
  800158:	89 c7                	mov    %eax,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	8b 45 08             	mov    0x8(%ebp),%eax
  80015f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800162:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800165:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800168:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80016b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800170:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800173:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800176:	39 d3                	cmp    %edx,%ebx
  800178:	72 05                	jb     80017f <printnum+0x30>
  80017a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80017d:	77 7a                	ja     8001f9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 18             	pushl  0x18(%ebp)
  800185:	8b 45 14             	mov    0x14(%ebp),%eax
  800188:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80018b:	53                   	push   %ebx
  80018c:	ff 75 10             	pushl  0x10(%ebp)
  80018f:	83 ec 08             	sub    $0x8,%esp
  800192:	ff 75 e4             	pushl  -0x1c(%ebp)
  800195:	ff 75 e0             	pushl  -0x20(%ebp)
  800198:	ff 75 dc             	pushl  -0x24(%ebp)
  80019b:	ff 75 d8             	pushl  -0x28(%ebp)
  80019e:	e8 ad 0b 00 00       	call   800d50 <__udivdi3>
  8001a3:	83 c4 18             	add    $0x18,%esp
  8001a6:	52                   	push   %edx
  8001a7:	50                   	push   %eax
  8001a8:	89 f2                	mov    %esi,%edx
  8001aa:	89 f8                	mov    %edi,%eax
  8001ac:	e8 9e ff ff ff       	call   80014f <printnum>
  8001b1:	83 c4 20             	add    $0x20,%esp
  8001b4:	eb 13                	jmp    8001c9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001b6:	83 ec 08             	sub    $0x8,%esp
  8001b9:	56                   	push   %esi
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	ff d7                	call   *%edi
  8001bf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001c2:	83 eb 01             	sub    $0x1,%ebx
  8001c5:	85 db                	test   %ebx,%ebx
  8001c7:	7f ed                	jg     8001b6 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	56                   	push   %esi
  8001cd:	83 ec 04             	sub    $0x4,%esp
  8001d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8001dc:	e8 8f 0c 00 00       	call   800e70 <__umoddi3>
  8001e1:	83 c4 14             	add    $0x14,%esp
  8001e4:	0f be 80 d1 0f 80 00 	movsbl 0x800fd1(%eax),%eax
  8001eb:	50                   	push   %eax
  8001ec:	ff d7                	call   *%edi
}
  8001ee:	83 c4 10             	add    $0x10,%esp
  8001f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5e                   	pop    %esi
  8001f6:	5f                   	pop    %edi
  8001f7:	5d                   	pop    %ebp
  8001f8:	c3                   	ret    
  8001f9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001fc:	eb c4                	jmp    8001c2 <printnum+0x73>

008001fe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800204:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800208:	8b 10                	mov    (%eax),%edx
  80020a:	3b 50 04             	cmp    0x4(%eax),%edx
  80020d:	73 0a                	jae    800219 <sprintputch+0x1b>
		*b->buf++ = ch;
  80020f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800212:	89 08                	mov    %ecx,(%eax)
  800214:	8b 45 08             	mov    0x8(%ebp),%eax
  800217:	88 02                	mov    %al,(%edx)
}
  800219:	5d                   	pop    %ebp
  80021a:	c3                   	ret    

0080021b <printfmt>:
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800221:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800224:	50                   	push   %eax
  800225:	ff 75 10             	pushl  0x10(%ebp)
  800228:	ff 75 0c             	pushl  0xc(%ebp)
  80022b:	ff 75 08             	pushl  0x8(%ebp)
  80022e:	e8 05 00 00 00       	call   800238 <vprintfmt>
}
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <vprintfmt>:
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	57                   	push   %edi
  80023c:	56                   	push   %esi
  80023d:	53                   	push   %ebx
  80023e:	83 ec 2c             	sub    $0x2c,%esp
  800241:	8b 75 08             	mov    0x8(%ebp),%esi
  800244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800247:	8b 7d 10             	mov    0x10(%ebp),%edi
  80024a:	e9 c1 03 00 00       	jmp    800610 <vprintfmt+0x3d8>
		padc = ' ';
  80024f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800253:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80025a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800261:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800268:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80026d:	8d 47 01             	lea    0x1(%edi),%eax
  800270:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800273:	0f b6 17             	movzbl (%edi),%edx
  800276:	8d 42 dd             	lea    -0x23(%edx),%eax
  800279:	3c 55                	cmp    $0x55,%al
  80027b:	0f 87 12 04 00 00    	ja     800693 <vprintfmt+0x45b>
  800281:	0f b6 c0             	movzbl %al,%eax
  800284:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  80028b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80028e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800292:	eb d9                	jmp    80026d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800294:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800297:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80029b:	eb d0                	jmp    80026d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80029d:	0f b6 d2             	movzbl %dl,%edx
  8002a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8002a8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002ab:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ae:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002b2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002b5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002b8:	83 f9 09             	cmp    $0x9,%ecx
  8002bb:	77 55                	ja     800312 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002bd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002c0:	eb e9                	jmp    8002ab <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8002c5:	8b 00                	mov    (%eax),%eax
  8002c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8002cd:	8d 40 04             	lea    0x4(%eax),%eax
  8002d0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002d6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002da:	79 91                	jns    80026d <vprintfmt+0x35>
				width = precision, precision = -1;
  8002dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	eb 82                	jmp    80026d <vprintfmt+0x35>
  8002eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f5:	0f 49 d0             	cmovns %eax,%edx
  8002f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002fe:	e9 6a ff ff ff       	jmp    80026d <vprintfmt+0x35>
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800306:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80030d:	e9 5b ff ff ff       	jmp    80026d <vprintfmt+0x35>
  800312:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800315:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800318:	eb bc                	jmp    8002d6 <vprintfmt+0x9e>
			lflag++;
  80031a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800320:	e9 48 ff ff ff       	jmp    80026d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800325:	8b 45 14             	mov    0x14(%ebp),%eax
  800328:	8d 78 04             	lea    0x4(%eax),%edi
  80032b:	83 ec 08             	sub    $0x8,%esp
  80032e:	53                   	push   %ebx
  80032f:	ff 30                	pushl  (%eax)
  800331:	ff d6                	call   *%esi
			break;
  800333:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800336:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800339:	e9 cf 02 00 00       	jmp    80060d <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80033e:	8b 45 14             	mov    0x14(%ebp),%eax
  800341:	8d 78 04             	lea    0x4(%eax),%edi
  800344:	8b 00                	mov    (%eax),%eax
  800346:	99                   	cltd   
  800347:	31 d0                	xor    %edx,%eax
  800349:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80034b:	83 f8 08             	cmp    $0x8,%eax
  80034e:	7f 23                	jg     800373 <vprintfmt+0x13b>
  800350:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  800357:	85 d2                	test   %edx,%edx
  800359:	74 18                	je     800373 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80035b:	52                   	push   %edx
  80035c:	68 f2 0f 80 00       	push   $0x800ff2
  800361:	53                   	push   %ebx
  800362:	56                   	push   %esi
  800363:	e8 b3 fe ff ff       	call   80021b <printfmt>
  800368:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80036b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80036e:	e9 9a 02 00 00       	jmp    80060d <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800373:	50                   	push   %eax
  800374:	68 e9 0f 80 00       	push   $0x800fe9
  800379:	53                   	push   %ebx
  80037a:	56                   	push   %esi
  80037b:	e8 9b fe ff ff       	call   80021b <printfmt>
  800380:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800383:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800386:	e9 82 02 00 00       	jmp    80060d <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80038b:	8b 45 14             	mov    0x14(%ebp),%eax
  80038e:	83 c0 04             	add    $0x4,%eax
  800391:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800394:	8b 45 14             	mov    0x14(%ebp),%eax
  800397:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800399:	85 ff                	test   %edi,%edi
  80039b:	b8 e2 0f 80 00       	mov    $0x800fe2,%eax
  8003a0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003a3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003a7:	0f 8e bd 00 00 00    	jle    80046a <vprintfmt+0x232>
  8003ad:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003b1:	75 0e                	jne    8003c1 <vprintfmt+0x189>
  8003b3:	89 75 08             	mov    %esi,0x8(%ebp)
  8003b6:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003b9:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003bc:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003bf:	eb 6d                	jmp    80042e <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003c1:	83 ec 08             	sub    $0x8,%esp
  8003c4:	ff 75 d0             	pushl  -0x30(%ebp)
  8003c7:	57                   	push   %edi
  8003c8:	e8 6e 03 00 00       	call   80073b <strnlen>
  8003cd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003d0:	29 c1                	sub    %eax,%ecx
  8003d2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003d5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003d8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003df:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003e2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e4:	eb 0f                	jmp    8003f5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8003e6:	83 ec 08             	sub    $0x8,%esp
  8003e9:	53                   	push   %ebx
  8003ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ed:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003ef:	83 ef 01             	sub    $0x1,%edi
  8003f2:	83 c4 10             	add    $0x10,%esp
  8003f5:	85 ff                	test   %edi,%edi
  8003f7:	7f ed                	jg     8003e6 <vprintfmt+0x1ae>
  8003f9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8003fc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8003ff:	85 c9                	test   %ecx,%ecx
  800401:	b8 00 00 00 00       	mov    $0x0,%eax
  800406:	0f 49 c1             	cmovns %ecx,%eax
  800409:	29 c1                	sub    %eax,%ecx
  80040b:	89 75 08             	mov    %esi,0x8(%ebp)
  80040e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800411:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800414:	89 cb                	mov    %ecx,%ebx
  800416:	eb 16                	jmp    80042e <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800418:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80041c:	75 31                	jne    80044f <vprintfmt+0x217>
					putch(ch, putdat);
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	ff 75 0c             	pushl  0xc(%ebp)
  800424:	50                   	push   %eax
  800425:	ff 55 08             	call   *0x8(%ebp)
  800428:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80042b:	83 eb 01             	sub    $0x1,%ebx
  80042e:	83 c7 01             	add    $0x1,%edi
  800431:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800435:	0f be c2             	movsbl %dl,%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	74 59                	je     800495 <vprintfmt+0x25d>
  80043c:	85 f6                	test   %esi,%esi
  80043e:	78 d8                	js     800418 <vprintfmt+0x1e0>
  800440:	83 ee 01             	sub    $0x1,%esi
  800443:	79 d3                	jns    800418 <vprintfmt+0x1e0>
  800445:	89 df                	mov    %ebx,%edi
  800447:	8b 75 08             	mov    0x8(%ebp),%esi
  80044a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044d:	eb 37                	jmp    800486 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80044f:	0f be d2             	movsbl %dl,%edx
  800452:	83 ea 20             	sub    $0x20,%edx
  800455:	83 fa 5e             	cmp    $0x5e,%edx
  800458:	76 c4                	jbe    80041e <vprintfmt+0x1e6>
					putch('?', putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	ff 75 0c             	pushl  0xc(%ebp)
  800460:	6a 3f                	push   $0x3f
  800462:	ff 55 08             	call   *0x8(%ebp)
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	eb c1                	jmp    80042b <vprintfmt+0x1f3>
  80046a:	89 75 08             	mov    %esi,0x8(%ebp)
  80046d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800470:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800473:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800476:	eb b6                	jmp    80042e <vprintfmt+0x1f6>
				putch(' ', putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	6a 20                	push   $0x20
  80047e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800480:	83 ef 01             	sub    $0x1,%edi
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	85 ff                	test   %edi,%edi
  800488:	7f ee                	jg     800478 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80048a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80048d:	89 45 14             	mov    %eax,0x14(%ebp)
  800490:	e9 78 01 00 00       	jmp    80060d <vprintfmt+0x3d5>
  800495:	89 df                	mov    %ebx,%edi
  800497:	8b 75 08             	mov    0x8(%ebp),%esi
  80049a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80049d:	eb e7                	jmp    800486 <vprintfmt+0x24e>
	if (lflag >= 2)
  80049f:	83 f9 01             	cmp    $0x1,%ecx
  8004a2:	7e 3f                	jle    8004e3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a7:	8b 50 04             	mov    0x4(%eax),%edx
  8004aa:	8b 00                	mov    (%eax),%eax
  8004ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004af:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8d 40 08             	lea    0x8(%eax),%eax
  8004b8:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004bb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004bf:	79 5c                	jns    80051d <vprintfmt+0x2e5>
				putch('-', putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	53                   	push   %ebx
  8004c5:	6a 2d                	push   $0x2d
  8004c7:	ff d6                	call   *%esi
				num = -(long long) num;
  8004c9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004cc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004cf:	f7 da                	neg    %edx
  8004d1:	83 d1 00             	adc    $0x0,%ecx
  8004d4:	f7 d9                	neg    %ecx
  8004d6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004d9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004de:	e9 10 01 00 00       	jmp    8005f3 <vprintfmt+0x3bb>
	else if (lflag)
  8004e3:	85 c9                	test   %ecx,%ecx
  8004e5:	75 1b                	jne    800502 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ef:	89 c1                	mov    %eax,%ecx
  8004f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8004f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 40 04             	lea    0x4(%eax),%eax
  8004fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800500:	eb b9                	jmp    8004bb <vprintfmt+0x283>
		return va_arg(*ap, long);
  800502:	8b 45 14             	mov    0x14(%ebp),%eax
  800505:	8b 00                	mov    (%eax),%eax
  800507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050a:	89 c1                	mov    %eax,%ecx
  80050c:	c1 f9 1f             	sar    $0x1f,%ecx
  80050f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 40 04             	lea    0x4(%eax),%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
  80051b:	eb 9e                	jmp    8004bb <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80051d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800520:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800523:	b8 0a 00 00 00       	mov    $0xa,%eax
  800528:	e9 c6 00 00 00       	jmp    8005f3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80052d:	83 f9 01             	cmp    $0x1,%ecx
  800530:	7e 18                	jle    80054a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8b 10                	mov    (%eax),%edx
  800537:	8b 48 04             	mov    0x4(%eax),%ecx
  80053a:	8d 40 08             	lea    0x8(%eax),%eax
  80053d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800540:	b8 0a 00 00 00       	mov    $0xa,%eax
  800545:	e9 a9 00 00 00       	jmp    8005f3 <vprintfmt+0x3bb>
	else if (lflag)
  80054a:	85 c9                	test   %ecx,%ecx
  80054c:	75 1a                	jne    800568 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 10                	mov    (%eax),%edx
  800553:	b9 00 00 00 00       	mov    $0x0,%ecx
  800558:	8d 40 04             	lea    0x4(%eax),%eax
  80055b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800563:	e9 8b 00 00 00       	jmp    8005f3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 10                	mov    (%eax),%edx
  80056d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800572:	8d 40 04             	lea    0x4(%eax),%eax
  800575:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800578:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057d:	eb 74                	jmp    8005f3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80057f:	83 f9 01             	cmp    $0x1,%ecx
  800582:	7e 15                	jle    800599 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 10                	mov    (%eax),%edx
  800589:	8b 48 04             	mov    0x4(%eax),%ecx
  80058c:	8d 40 08             	lea    0x8(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800592:	b8 08 00 00 00       	mov    $0x8,%eax
  800597:	eb 5a                	jmp    8005f3 <vprintfmt+0x3bb>
	else if (lflag)
  800599:	85 c9                	test   %ecx,%ecx
  80059b:	75 17                	jne    8005b4 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a7:	8d 40 04             	lea    0x4(%eax),%eax
  8005aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005ad:	b8 08 00 00 00       	mov    $0x8,%eax
  8005b2:	eb 3f                	jmp    8005f3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c9:	eb 28                	jmp    8005f3 <vprintfmt+0x3bb>
			putch('0', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	53                   	push   %ebx
  8005cf:	6a 30                	push   $0x30
  8005d1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	53                   	push   %ebx
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8b 10                	mov    (%eax),%edx
  8005e0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005e8:	8d 40 04             	lea    0x4(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005ee:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8005fa:	57                   	push   %edi
  8005fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fe:	50                   	push   %eax
  8005ff:	51                   	push   %ecx
  800600:	52                   	push   %edx
  800601:	89 da                	mov    %ebx,%edx
  800603:	89 f0                	mov    %esi,%eax
  800605:	e8 45 fb ff ff       	call   80014f <printnum>
			break;
  80060a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80060d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800610:	83 c7 01             	add    $0x1,%edi
  800613:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800617:	83 f8 25             	cmp    $0x25,%eax
  80061a:	0f 84 2f fc ff ff    	je     80024f <vprintfmt+0x17>
			if (ch == '\0')
  800620:	85 c0                	test   %eax,%eax
  800622:	0f 84 8b 00 00 00    	je     8006b3 <vprintfmt+0x47b>
			putch(ch, putdat);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	50                   	push   %eax
  80062d:	ff d6                	call   *%esi
  80062f:	83 c4 10             	add    $0x10,%esp
  800632:	eb dc                	jmp    800610 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7e 15                	jle    80064e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800639:	8b 45 14             	mov    0x14(%ebp),%eax
  80063c:	8b 10                	mov    (%eax),%edx
  80063e:	8b 48 04             	mov    0x4(%eax),%ecx
  800641:	8d 40 08             	lea    0x8(%eax),%eax
  800644:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800647:	b8 10 00 00 00       	mov    $0x10,%eax
  80064c:	eb a5                	jmp    8005f3 <vprintfmt+0x3bb>
	else if (lflag)
  80064e:	85 c9                	test   %ecx,%ecx
  800650:	75 17                	jne    800669 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 10                	mov    (%eax),%edx
  800657:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065c:	8d 40 04             	lea    0x4(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800662:	b8 10 00 00 00       	mov    $0x10,%eax
  800667:	eb 8a                	jmp    8005f3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800679:	b8 10 00 00 00       	mov    $0x10,%eax
  80067e:	e9 70 ff ff ff       	jmp    8005f3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	6a 25                	push   $0x25
  800689:	ff d6                	call   *%esi
			break;
  80068b:	83 c4 10             	add    $0x10,%esp
  80068e:	e9 7a ff ff ff       	jmp    80060d <vprintfmt+0x3d5>
			putch('%', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 25                	push   $0x25
  800699:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	89 f8                	mov    %edi,%eax
  8006a0:	eb 03                	jmp    8006a5 <vprintfmt+0x46d>
  8006a2:	83 e8 01             	sub    $0x1,%eax
  8006a5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a9:	75 f7                	jne    8006a2 <vprintfmt+0x46a>
  8006ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ae:	e9 5a ff ff ff       	jmp    80060d <vprintfmt+0x3d5>
}
  8006b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b6:	5b                   	pop    %ebx
  8006b7:	5e                   	pop    %esi
  8006b8:	5f                   	pop    %edi
  8006b9:	5d                   	pop    %ebp
  8006ba:	c3                   	ret    

008006bb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006bb:	55                   	push   %ebp
  8006bc:	89 e5                	mov    %esp,%ebp
  8006be:	83 ec 18             	sub    $0x18,%esp
  8006c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ca:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ce:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	74 26                	je     800702 <vsnprintf+0x47>
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	7e 22                	jle    800702 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e0:	ff 75 14             	pushl  0x14(%ebp)
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e9:	50                   	push   %eax
  8006ea:	68 fe 01 80 00       	push   $0x8001fe
  8006ef:	e8 44 fb ff ff       	call   800238 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006fd:	83 c4 10             	add    $0x10,%esp
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    
		return -E_INVAL;
  800702:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800707:	eb f7                	jmp    800700 <vsnprintf+0x45>

00800709 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800709:	55                   	push   %ebp
  80070a:	89 e5                	mov    %esp,%ebp
  80070c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800712:	50                   	push   %eax
  800713:	ff 75 10             	pushl  0x10(%ebp)
  800716:	ff 75 0c             	pushl  0xc(%ebp)
  800719:	ff 75 08             	pushl  0x8(%ebp)
  80071c:	e8 9a ff ff ff       	call   8006bb <vsnprintf>
	va_end(ap);

	return rc;
}
  800721:	c9                   	leave  
  800722:	c3                   	ret    

00800723 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800729:	b8 00 00 00 00       	mov    $0x0,%eax
  80072e:	eb 03                	jmp    800733 <strlen+0x10>
		n++;
  800730:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800733:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800737:	75 f7                	jne    800730 <strlen+0xd>
	return n;
}
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800741:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 03                	jmp    80074e <strnlen+0x13>
		n++;
  80074b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074e:	39 d0                	cmp    %edx,%eax
  800750:	74 06                	je     800758 <strnlen+0x1d>
  800752:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800756:	75 f3                	jne    80074b <strnlen+0x10>
	return n;
}
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    

0080075a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075a:	55                   	push   %ebp
  80075b:	89 e5                	mov    %esp,%ebp
  80075d:	53                   	push   %ebx
  80075e:	8b 45 08             	mov    0x8(%ebp),%eax
  800761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800764:	89 c2                	mov    %eax,%edx
  800766:	83 c1 01             	add    $0x1,%ecx
  800769:	83 c2 01             	add    $0x1,%edx
  80076c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800770:	88 5a ff             	mov    %bl,-0x1(%edx)
  800773:	84 db                	test   %bl,%bl
  800775:	75 ef                	jne    800766 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800777:	5b                   	pop    %ebx
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800781:	53                   	push   %ebx
  800782:	e8 9c ff ff ff       	call   800723 <strlen>
  800787:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	01 d8                	add    %ebx,%eax
  80078f:	50                   	push   %eax
  800790:	e8 c5 ff ff ff       	call   80075a <strcpy>
	return dst;
}
  800795:	89 d8                	mov    %ebx,%eax
  800797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079a:	c9                   	leave  
  80079b:	c3                   	ret    

0080079c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80079c:	55                   	push   %ebp
  80079d:	89 e5                	mov    %esp,%ebp
  80079f:	56                   	push   %esi
  8007a0:	53                   	push   %ebx
  8007a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a7:	89 f3                	mov    %esi,%ebx
  8007a9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ac:	89 f2                	mov    %esi,%edx
  8007ae:	eb 0f                	jmp    8007bf <strncpy+0x23>
		*dst++ = *src;
  8007b0:	83 c2 01             	add    $0x1,%edx
  8007b3:	0f b6 01             	movzbl (%ecx),%eax
  8007b6:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b9:	80 39 01             	cmpb   $0x1,(%ecx)
  8007bc:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007bf:	39 da                	cmp    %ebx,%edx
  8007c1:	75 ed                	jne    8007b0 <strncpy+0x14>
	}
	return ret;
}
  8007c3:	89 f0                	mov    %esi,%eax
  8007c5:	5b                   	pop    %ebx
  8007c6:	5e                   	pop    %esi
  8007c7:	5d                   	pop    %ebp
  8007c8:	c3                   	ret    

008007c9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c9:	55                   	push   %ebp
  8007ca:	89 e5                	mov    %esp,%ebp
  8007cc:	56                   	push   %esi
  8007cd:	53                   	push   %ebx
  8007ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007d7:	89 f0                	mov    %esi,%eax
  8007d9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007dd:	85 c9                	test   %ecx,%ecx
  8007df:	75 0b                	jne    8007ec <strlcpy+0x23>
  8007e1:	eb 17                	jmp    8007fa <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	83 c0 01             	add    $0x1,%eax
  8007e9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007ec:	39 d8                	cmp    %ebx,%eax
  8007ee:	74 07                	je     8007f7 <strlcpy+0x2e>
  8007f0:	0f b6 0a             	movzbl (%edx),%ecx
  8007f3:	84 c9                	test   %cl,%cl
  8007f5:	75 ec                	jne    8007e3 <strlcpy+0x1a>
		*dst = '\0';
  8007f7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fa:	29 f0                	sub    %esi,%eax
}
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800809:	eb 06                	jmp    800811 <strcmp+0x11>
		p++, q++;
  80080b:	83 c1 01             	add    $0x1,%ecx
  80080e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	84 c0                	test   %al,%al
  800816:	74 04                	je     80081c <strcmp+0x1c>
  800818:	3a 02                	cmp    (%edx),%al
  80081a:	74 ef                	je     80080b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081c:	0f b6 c0             	movzbl %al,%eax
  80081f:	0f b6 12             	movzbl (%edx),%edx
  800822:	29 d0                	sub    %edx,%eax
}
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
  800829:	53                   	push   %ebx
  80082a:	8b 45 08             	mov    0x8(%ebp),%eax
  80082d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800830:	89 c3                	mov    %eax,%ebx
  800832:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800835:	eb 06                	jmp    80083d <strncmp+0x17>
		n--, p++, q++;
  800837:	83 c0 01             	add    $0x1,%eax
  80083a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80083d:	39 d8                	cmp    %ebx,%eax
  80083f:	74 16                	je     800857 <strncmp+0x31>
  800841:	0f b6 08             	movzbl (%eax),%ecx
  800844:	84 c9                	test   %cl,%cl
  800846:	74 04                	je     80084c <strncmp+0x26>
  800848:	3a 0a                	cmp    (%edx),%cl
  80084a:	74 eb                	je     800837 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084c:	0f b6 00             	movzbl (%eax),%eax
  80084f:	0f b6 12             	movzbl (%edx),%edx
  800852:	29 d0                	sub    %edx,%eax
}
  800854:	5b                   	pop    %ebx
  800855:	5d                   	pop    %ebp
  800856:	c3                   	ret    
		return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
  80085c:	eb f6                	jmp    800854 <strncmp+0x2e>

0080085e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800868:	0f b6 10             	movzbl (%eax),%edx
  80086b:	84 d2                	test   %dl,%dl
  80086d:	74 09                	je     800878 <strchr+0x1a>
		if (*s == c)
  80086f:	38 ca                	cmp    %cl,%dl
  800871:	74 0a                	je     80087d <strchr+0x1f>
	for (; *s; s++)
  800873:	83 c0 01             	add    $0x1,%eax
  800876:	eb f0                	jmp    800868 <strchr+0xa>
			return (char *) s;
	return 0;
  800878:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800889:	eb 03                	jmp    80088e <strfind+0xf>
  80088b:	83 c0 01             	add    $0x1,%eax
  80088e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800891:	38 ca                	cmp    %cl,%dl
  800893:	74 04                	je     800899 <strfind+0x1a>
  800895:	84 d2                	test   %dl,%dl
  800897:	75 f2                	jne    80088b <strfind+0xc>
			break;
	return (char *) s;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	57                   	push   %edi
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
  8008a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a7:	85 c9                	test   %ecx,%ecx
  8008a9:	74 13                	je     8008be <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ab:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b1:	75 05                	jne    8008b8 <memset+0x1d>
  8008b3:	f6 c1 03             	test   $0x3,%cl
  8008b6:	74 0d                	je     8008c5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008bb:	fc                   	cld    
  8008bc:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008be:	89 f8                	mov    %edi,%eax
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5f                   	pop    %edi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    
		c &= 0xFF;
  8008c5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c9:	89 d3                	mov    %edx,%ebx
  8008cb:	c1 e3 08             	shl    $0x8,%ebx
  8008ce:	89 d0                	mov    %edx,%eax
  8008d0:	c1 e0 18             	shl    $0x18,%eax
  8008d3:	89 d6                	mov    %edx,%esi
  8008d5:	c1 e6 10             	shl    $0x10,%esi
  8008d8:	09 f0                	or     %esi,%eax
  8008da:	09 c2                	or     %eax,%edx
  8008dc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008de:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008e1:	89 d0                	mov    %edx,%eax
  8008e3:	fc                   	cld    
  8008e4:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e6:	eb d6                	jmp    8008be <memset+0x23>

008008e8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f6:	39 c6                	cmp    %eax,%esi
  8008f8:	73 35                	jae    80092f <memmove+0x47>
  8008fa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fd:	39 c2                	cmp    %eax,%edx
  8008ff:	76 2e                	jbe    80092f <memmove+0x47>
		s += n;
		d += n;
  800901:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800904:	89 d6                	mov    %edx,%esi
  800906:	09 fe                	or     %edi,%esi
  800908:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090e:	74 0c                	je     80091c <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800910:	83 ef 01             	sub    $0x1,%edi
  800913:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800916:	fd                   	std    
  800917:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800919:	fc                   	cld    
  80091a:	eb 21                	jmp    80093d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091c:	f6 c1 03             	test   $0x3,%cl
  80091f:	75 ef                	jne    800910 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800921:	83 ef 04             	sub    $0x4,%edi
  800924:	8d 72 fc             	lea    -0x4(%edx),%esi
  800927:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80092a:	fd                   	std    
  80092b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092d:	eb ea                	jmp    800919 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092f:	89 f2                	mov    %esi,%edx
  800931:	09 c2                	or     %eax,%edx
  800933:	f6 c2 03             	test   $0x3,%dl
  800936:	74 09                	je     800941 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800938:	89 c7                	mov    %eax,%edi
  80093a:	fc                   	cld    
  80093b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093d:	5e                   	pop    %esi
  80093e:	5f                   	pop    %edi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 f2                	jne    800938 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800946:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800949:	89 c7                	mov    %eax,%edi
  80094b:	fc                   	cld    
  80094c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094e:	eb ed                	jmp    80093d <memmove+0x55>

00800950 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800953:	ff 75 10             	pushl  0x10(%ebp)
  800956:	ff 75 0c             	pushl  0xc(%ebp)
  800959:	ff 75 08             	pushl  0x8(%ebp)
  80095c:	e8 87 ff ff ff       	call   8008e8 <memmove>
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	56                   	push   %esi
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c6                	mov    %eax,%esi
  800970:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800973:	39 f0                	cmp    %esi,%eax
  800975:	74 1c                	je     800993 <memcmp+0x30>
		if (*s1 != *s2)
  800977:	0f b6 08             	movzbl (%eax),%ecx
  80097a:	0f b6 1a             	movzbl (%edx),%ebx
  80097d:	38 d9                	cmp    %bl,%cl
  80097f:	75 08                	jne    800989 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800981:	83 c0 01             	add    $0x1,%eax
  800984:	83 c2 01             	add    $0x1,%edx
  800987:	eb ea                	jmp    800973 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800989:	0f b6 c1             	movzbl %cl,%eax
  80098c:	0f b6 db             	movzbl %bl,%ebx
  80098f:	29 d8                	sub    %ebx,%eax
  800991:	eb 05                	jmp    800998 <memcmp+0x35>
	}

	return 0;
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800998:	5b                   	pop    %ebx
  800999:	5e                   	pop    %esi
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009a5:	89 c2                	mov    %eax,%edx
  8009a7:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009aa:	39 d0                	cmp    %edx,%eax
  8009ac:	73 09                	jae    8009b7 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ae:	38 08                	cmp    %cl,(%eax)
  8009b0:	74 05                	je     8009b7 <memfind+0x1b>
	for (; s < ends; s++)
  8009b2:	83 c0 01             	add    $0x1,%eax
  8009b5:	eb f3                	jmp    8009aa <memfind+0xe>
			break;
	return (void *) s;
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	57                   	push   %edi
  8009bd:	56                   	push   %esi
  8009be:	53                   	push   %ebx
  8009bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009c5:	eb 03                	jmp    8009ca <strtol+0x11>
		s++;
  8009c7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009ca:	0f b6 01             	movzbl (%ecx),%eax
  8009cd:	3c 20                	cmp    $0x20,%al
  8009cf:	74 f6                	je     8009c7 <strtol+0xe>
  8009d1:	3c 09                	cmp    $0x9,%al
  8009d3:	74 f2                	je     8009c7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009d5:	3c 2b                	cmp    $0x2b,%al
  8009d7:	74 2e                	je     800a07 <strtol+0x4e>
	int neg = 0;
  8009d9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009de:	3c 2d                	cmp    $0x2d,%al
  8009e0:	74 2f                	je     800a11 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009e8:	75 05                	jne    8009ef <strtol+0x36>
  8009ea:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ed:	74 2c                	je     800a1b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8009ef:	85 db                	test   %ebx,%ebx
  8009f1:	75 0a                	jne    8009fd <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009f3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  8009f8:	80 39 30             	cmpb   $0x30,(%ecx)
  8009fb:	74 28                	je     800a25 <strtol+0x6c>
		base = 10;
  8009fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800a02:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a05:	eb 50                	jmp    800a57 <strtol+0x9e>
		s++;
  800a07:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a0f:	eb d1                	jmp    8009e2 <strtol+0x29>
		s++, neg = 1;
  800a11:	83 c1 01             	add    $0x1,%ecx
  800a14:	bf 01 00 00 00       	mov    $0x1,%edi
  800a19:	eb c7                	jmp    8009e2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a1f:	74 0e                	je     800a2f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a21:	85 db                	test   %ebx,%ebx
  800a23:	75 d8                	jne    8009fd <strtol+0x44>
		s++, base = 8;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a2d:	eb ce                	jmp    8009fd <strtol+0x44>
		s += 2, base = 16;
  800a2f:	83 c1 02             	add    $0x2,%ecx
  800a32:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a37:	eb c4                	jmp    8009fd <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a39:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 19             	cmp    $0x19,%bl
  800a41:	77 29                	ja     800a6c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a49:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a4c:	7d 30                	jge    800a7e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a4e:	83 c1 01             	add    $0x1,%ecx
  800a51:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a55:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a57:	0f b6 11             	movzbl (%ecx),%edx
  800a5a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5d:	89 f3                	mov    %esi,%ebx
  800a5f:	80 fb 09             	cmp    $0x9,%bl
  800a62:	77 d5                	ja     800a39 <strtol+0x80>
			dig = *s - '0';
  800a64:	0f be d2             	movsbl %dl,%edx
  800a67:	83 ea 30             	sub    $0x30,%edx
  800a6a:	eb dd                	jmp    800a49 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a6c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a6f:	89 f3                	mov    %esi,%ebx
  800a71:	80 fb 19             	cmp    $0x19,%bl
  800a74:	77 08                	ja     800a7e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a76:	0f be d2             	movsbl %dl,%edx
  800a79:	83 ea 37             	sub    $0x37,%edx
  800a7c:	eb cb                	jmp    800a49 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a7e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a82:	74 05                	je     800a89 <strtol+0xd0>
		*endptr = (char *) s;
  800a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a87:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a89:	89 c2                	mov    %eax,%edx
  800a8b:	f7 da                	neg    %edx
  800a8d:	85 ff                	test   %edi,%edi
  800a8f:	0f 45 c2             	cmovne %edx,%eax
}
  800a92:	5b                   	pop    %ebx
  800a93:	5e                   	pop    %esi
  800a94:	5f                   	pop    %edi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	57                   	push   %edi
  800a9b:	56                   	push   %esi
  800a9c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800aa5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	89 c7                	mov    %eax,%edi
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5f                   	pop    %edi
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	57                   	push   %edi
  800ab9:	56                   	push   %esi
  800aba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800abb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ac5:	89 d1                	mov    %edx,%ecx
  800ac7:	89 d3                	mov    %edx,%ebx
  800ac9:	89 d7                	mov    %edx,%edi
  800acb:	89 d6                	mov    %edx,%esi
  800acd:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
  800ada:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800add:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae5:	b8 03 00 00 00       	mov    $0x3,%eax
  800aea:	89 cb                	mov    %ecx,%ebx
  800aec:	89 cf                	mov    %ecx,%edi
  800aee:	89 ce                	mov    %ecx,%esi
  800af0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800af2:	85 c0                	test   %eax,%eax
  800af4:	7f 08                	jg     800afe <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800af6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	50                   	push   %eax
  800b02:	6a 03                	push   $0x3
  800b04:	68 24 12 80 00       	push   $0x801224
  800b09:	6a 23                	push   $0x23
  800b0b:	68 41 12 80 00       	push   $0x801241
  800b10:	e8 ed 01 00 00       	call   800d02 <_panic>

00800b15 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b20:	b8 02 00 00 00       	mov    $0x2,%eax
  800b25:	89 d1                	mov    %edx,%ecx
  800b27:	89 d3                	mov    %edx,%ebx
  800b29:	89 d7                	mov    %edx,%edi
  800b2b:	89 d6                	mov    %edx,%esi
  800b2d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_yield>:

void
sys_yield(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
  800b59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b5c:	be 00 00 00 00       	mov    $0x0,%esi
  800b61:	8b 55 08             	mov    0x8(%ebp),%edx
  800b64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b67:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b6f:	89 f7                	mov    %esi,%edi
  800b71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b73:	85 c0                	test   %eax,%eax
  800b75:	7f 08                	jg     800b7f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b7a:	5b                   	pop    %ebx
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7f:	83 ec 0c             	sub    $0xc,%esp
  800b82:	50                   	push   %eax
  800b83:	6a 04                	push   $0x4
  800b85:	68 24 12 80 00       	push   $0x801224
  800b8a:	6a 23                	push   $0x23
  800b8c:	68 41 12 80 00       	push   $0x801241
  800b91:	e8 6c 01 00 00       	call   800d02 <_panic>

00800b96 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba5:	b8 05 00 00 00       	mov    $0x5,%eax
  800baa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bad:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb0:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb5:	85 c0                	test   %eax,%eax
  800bb7:	7f 08                	jg     800bc1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbc:	5b                   	pop    %ebx
  800bbd:	5e                   	pop    %esi
  800bbe:	5f                   	pop    %edi
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc1:	83 ec 0c             	sub    $0xc,%esp
  800bc4:	50                   	push   %eax
  800bc5:	6a 05                	push   $0x5
  800bc7:	68 24 12 80 00       	push   $0x801224
  800bcc:	6a 23                	push   $0x23
  800bce:	68 41 12 80 00       	push   $0x801241
  800bd3:	e8 2a 01 00 00       	call   800d02 <_panic>

00800bd8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
  800bde:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf1:	89 df                	mov    %ebx,%edi
  800bf3:	89 de                	mov    %ebx,%esi
  800bf5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	7f 08                	jg     800c03 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	50                   	push   %eax
  800c07:	6a 06                	push   $0x6
  800c09:	68 24 12 80 00       	push   $0x801224
  800c0e:	6a 23                	push   $0x23
  800c10:	68 41 12 80 00       	push   $0x801241
  800c15:	e8 e8 00 00 00       	call   800d02 <_panic>

00800c1a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c23:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800c33:	89 df                	mov    %ebx,%edi
  800c35:	89 de                	mov    %ebx,%esi
  800c37:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7f 08                	jg     800c45 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	50                   	push   %eax
  800c49:	6a 08                	push   $0x8
  800c4b:	68 24 12 80 00       	push   $0x801224
  800c50:	6a 23                	push   $0x23
  800c52:	68 41 12 80 00       	push   $0x801241
  800c57:	e8 a6 00 00 00       	call   800d02 <_panic>

00800c5c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
  800c62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c70:	b8 09 00 00 00       	mov    $0x9,%eax
  800c75:	89 df                	mov    %ebx,%edi
  800c77:	89 de                	mov    %ebx,%esi
  800c79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7f 08                	jg     800c87 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 09                	push   $0x9
  800c8d:	68 24 12 80 00       	push   $0x801224
  800c92:	6a 23                	push   $0x23
  800c94:	68 41 12 80 00       	push   $0x801241
  800c99:	e8 64 00 00 00       	call   800d02 <_panic>

00800c9e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800caa:	b8 0b 00 00 00       	mov    $0xb,%eax
  800caf:	be 00 00 00 00       	mov    $0x0,%esi
  800cb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cba:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cca:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cd7:	89 cb                	mov    %ecx,%ebx
  800cd9:	89 cf                	mov    %ecx,%edi
  800cdb:	89 ce                	mov    %ecx,%esi
  800cdd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	7f 08                	jg     800ceb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ce3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce6:	5b                   	pop    %ebx
  800ce7:	5e                   	pop    %esi
  800ce8:	5f                   	pop    %edi
  800ce9:	5d                   	pop    %ebp
  800cea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ceb:	83 ec 0c             	sub    $0xc,%esp
  800cee:	50                   	push   %eax
  800cef:	6a 0c                	push   $0xc
  800cf1:	68 24 12 80 00       	push   $0x801224
  800cf6:	6a 23                	push   $0x23
  800cf8:	68 41 12 80 00       	push   $0x801241
  800cfd:	e8 00 00 00 00       	call   800d02 <_panic>

00800d02 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d07:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d0a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d10:	e8 00 fe ff ff       	call   800b15 <sys_getenvid>
  800d15:	83 ec 0c             	sub    $0xc,%esp
  800d18:	ff 75 0c             	pushl  0xc(%ebp)
  800d1b:	ff 75 08             	pushl  0x8(%ebp)
  800d1e:	56                   	push   %esi
  800d1f:	50                   	push   %eax
  800d20:	68 50 12 80 00       	push   $0x801250
  800d25:	e8 11 f4 ff ff       	call   80013b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d2a:	83 c4 18             	add    $0x18,%esp
  800d2d:	53                   	push   %ebx
  800d2e:	ff 75 10             	pushl  0x10(%ebp)
  800d31:	e8 b4 f3 ff ff       	call   8000ea <vcprintf>
	cprintf("\n");
  800d36:	c7 04 24 74 12 80 00 	movl   $0x801274,(%esp)
  800d3d:	e8 f9 f3 ff ff       	call   80013b <cprintf>
  800d42:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d45:	cc                   	int3   
  800d46:	eb fd                	jmp    800d45 <_panic+0x43>
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__udivdi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d67:	85 d2                	test   %edx,%edx
  800d69:	75 35                	jne    800da0 <__udivdi3+0x50>
  800d6b:	39 f3                	cmp    %esi,%ebx
  800d6d:	0f 87 bd 00 00 00    	ja     800e30 <__udivdi3+0xe0>
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	89 d9                	mov    %ebx,%ecx
  800d77:	75 0b                	jne    800d84 <__udivdi3+0x34>
  800d79:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f3                	div    %ebx
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	31 d2                	xor    %edx,%edx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	f7 f1                	div    %ecx
  800d8a:	89 c6                	mov    %eax,%esi
  800d8c:	89 e8                	mov    %ebp,%eax
  800d8e:	89 f7                	mov    %esi,%edi
  800d90:	f7 f1                	div    %ecx
  800d92:	89 fa                	mov    %edi,%edx
  800d94:	83 c4 1c             	add    $0x1c,%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
  800d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 f2                	cmp    %esi,%edx
  800da2:	77 7c                	ja     800e20 <__udivdi3+0xd0>
  800da4:	0f bd fa             	bsr    %edx,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0xf8>
  800db0:	89 f9                	mov    %edi,%ecx
  800db2:	b8 20 00 00 00       	mov    $0x20,%eax
  800db7:	29 f8                	sub    %edi,%eax
  800db9:	d3 e2                	shl    %cl,%edx
  800dbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	89 da                	mov    %ebx,%edx
  800dc3:	d3 ea                	shr    %cl,%edx
  800dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc9:	09 d1                	or     %edx,%ecx
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e3                	shl    %cl,%ebx
  800dd5:	89 c1                	mov    %eax,%ecx
  800dd7:	d3 ea                	shr    %cl,%edx
  800dd9:	89 f9                	mov    %edi,%ecx
  800ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ddf:	d3 e6                	shl    %cl,%esi
  800de1:	89 eb                	mov    %ebp,%ebx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	d3 eb                	shr    %cl,%ebx
  800de7:	09 de                	or     %ebx,%esi
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	f7 74 24 08          	divl   0x8(%esp)
  800def:	89 d6                	mov    %edx,%esi
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	f7 64 24 0c          	mull   0xc(%esp)
  800df7:	39 d6                	cmp    %edx,%esi
  800df9:	72 0c                	jb     800e07 <__udivdi3+0xb7>
  800dfb:	89 f9                	mov    %edi,%ecx
  800dfd:	d3 e5                	shl    %cl,%ebp
  800dff:	39 c5                	cmp    %eax,%ebp
  800e01:	73 5d                	jae    800e60 <__udivdi3+0x110>
  800e03:	39 d6                	cmp    %edx,%esi
  800e05:	75 59                	jne    800e60 <__udivdi3+0x110>
  800e07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e0a:	31 ff                	xor    %edi,%edi
  800e0c:	89 fa                	mov    %edi,%edx
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	8d 76 00             	lea    0x0(%esi),%esi
  800e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	31 c0                	xor    %eax,%eax
  800e24:	89 fa                	mov    %edi,%edx
  800e26:	83 c4 1c             	add    $0x1c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
  800e2e:	66 90                	xchg   %ax,%ax
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	89 e8                	mov    %ebp,%eax
  800e34:	89 f2                	mov    %esi,%edx
  800e36:	f7 f3                	div    %ebx
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x102>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 d2                	ja     800e24 <__udivdi3+0xd4>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb cb                	jmp    800e24 <__udivdi3+0xd4>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d8                	mov    %ebx,%eax
  800e62:	31 ff                	xor    %edi,%edi
  800e64:	eb be                	jmp    800e24 <__udivdi3+0xd4>
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 ed                	test   %ebp,%ebp
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	89 da                	mov    %ebx,%edx
  800e8d:	75 19                	jne    800ea8 <__umoddi3+0x38>
  800e8f:	39 df                	cmp    %ebx,%edi
  800e91:	0f 86 b1 00 00 00    	jbe    800f48 <__umoddi3+0xd8>
  800e97:	f7 f7                	div    %edi
  800e99:	89 d0                	mov    %edx,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	83 c4 1c             	add    $0x1c,%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	39 dd                	cmp    %ebx,%ebp
  800eaa:	77 f1                	ja     800e9d <__umoddi3+0x2d>
  800eac:	0f bd cd             	bsr    %ebp,%ecx
  800eaf:	83 f1 1f             	xor    $0x1f,%ecx
  800eb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800eb6:	0f 84 b4 00 00 00    	je     800f70 <__umoddi3+0x100>
  800ebc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ec7:	29 c2                	sub    %eax,%edx
  800ec9:	89 c1                	mov    %eax,%ecx
  800ecb:	89 f8                	mov    %edi,%eax
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	89 d1                	mov    %edx,%ecx
  800ed1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed5:	d3 e8                	shr    %cl,%eax
  800ed7:	09 c5                	or     %eax,%ebp
  800ed9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edd:	89 c1                	mov    %eax,%ecx
  800edf:	d3 e7                	shl    %cl,%edi
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ee7:	89 df                	mov    %ebx,%edi
  800ee9:	d3 ef                	shr    %cl,%edi
  800eeb:	89 c1                	mov    %eax,%ecx
  800eed:	89 f0                	mov    %esi,%eax
  800eef:	d3 e3                	shl    %cl,%ebx
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 fa                	mov    %edi,%edx
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800efc:	09 d8                	or     %ebx,%eax
  800efe:	f7 f5                	div    %ebp
  800f00:	d3 e6                	shl    %cl,%esi
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	f7 64 24 08          	mull   0x8(%esp)
  800f08:	39 d1                	cmp    %edx,%ecx
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	72 06                	jb     800f16 <__umoddi3+0xa6>
  800f10:	75 0e                	jne    800f20 <__umoddi3+0xb0>
  800f12:	39 c6                	cmp    %eax,%esi
  800f14:	73 0a                	jae    800f20 <__umoddi3+0xb0>
  800f16:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f1a:	19 ea                	sbb    %ebp,%edx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	89 ca                	mov    %ecx,%edx
  800f22:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f27:	29 de                	sub    %ebx,%esi
  800f29:	19 fa                	sbb    %edi,%edx
  800f2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f2f:	89 d0                	mov    %edx,%eax
  800f31:	d3 e0                	shl    %cl,%eax
  800f33:	89 d9                	mov    %ebx,%ecx
  800f35:	d3 ee                	shr    %cl,%esi
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	09 f0                	or     %esi,%eax
  800f3b:	83 c4 1c             	add    $0x1c,%esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
  800f43:	90                   	nop
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	85 ff                	test   %edi,%edi
  800f4a:	89 f9                	mov    %edi,%ecx
  800f4c:	75 0b                	jne    800f59 <__umoddi3+0xe9>
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f7                	div    %edi
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f1                	div    %ecx
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	f7 f1                	div    %ecx
  800f63:	e9 31 ff ff ff       	jmp    800e99 <__umoddi3+0x29>
  800f68:	90                   	nop
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	39 dd                	cmp    %ebx,%ebp
  800f72:	72 08                	jb     800f7c <__umoddi3+0x10c>
  800f74:	39 f7                	cmp    %esi,%edi
  800f76:	0f 87 21 ff ff ff    	ja     800e9d <__umoddi3+0x2d>
  800f7c:	89 da                	mov    %ebx,%edx
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	29 f8                	sub    %edi,%eax
  800f82:	19 ea                	sbb    %ebp,%edx
  800f84:	e9 14 ff ff ff       	jmp    800e9d <__umoddi3+0x2d>
