
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 a0 0f 80 00       	push   $0x800fa0
  800056:	e8 f2 00 00 00       	call   80014d <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80006b:	e8 b7 0a 00 00       	call   800b27 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
		binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000ac:	6a 00                	push   $0x0
  8000ae:	e8 33 0a 00 00       	call   800ae6 <sys_env_destroy>
}
  8000b3:	83 c4 10             	add    $0x10,%esp
  8000b6:	c9                   	leave  
  8000b7:	c3                   	ret    

008000b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	53                   	push   %ebx
  8000bc:	83 ec 04             	sub    $0x4,%esp
  8000bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c2:	8b 13                	mov    (%ebx),%edx
  8000c4:	8d 42 01             	lea    0x1(%edx),%eax
  8000c7:	89 03                	mov    %eax,(%ebx)
  8000c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d5:	74 09                	je     8000e0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e0:	83 ec 08             	sub    $0x8,%esp
  8000e3:	68 ff 00 00 00       	push   $0xff
  8000e8:	8d 43 08             	lea    0x8(%ebx),%eax
  8000eb:	50                   	push   %eax
  8000ec:	e8 b8 09 00 00       	call   800aa9 <sys_cputs>
		b->idx = 0;
  8000f1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	eb db                	jmp    8000d7 <putch+0x1f>

008000fc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800105:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010c:	00 00 00 
	b.cnt = 0;
  80010f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800116:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800119:	ff 75 0c             	pushl  0xc(%ebp)
  80011c:	ff 75 08             	pushl  0x8(%ebp)
  80011f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800125:	50                   	push   %eax
  800126:	68 b8 00 80 00       	push   $0x8000b8
  80012b:	e8 1a 01 00 00       	call   80024a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800130:	83 c4 08             	add    $0x8,%esp
  800133:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800139:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80013f:	50                   	push   %eax
  800140:	e8 64 09 00 00       	call   800aa9 <sys_cputs>

	return b.cnt;
}
  800145:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800153:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800156:	50                   	push   %eax
  800157:	ff 75 08             	pushl  0x8(%ebp)
  80015a:	e8 9d ff ff ff       	call   8000fc <vcprintf>
	va_end(ap);

	return cnt;
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	57                   	push   %edi
  800165:	56                   	push   %esi
  800166:	53                   	push   %ebx
  800167:	83 ec 1c             	sub    $0x1c,%esp
  80016a:	89 c7                	mov    %eax,%edi
  80016c:	89 d6                	mov    %edx,%esi
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	8b 55 0c             	mov    0xc(%ebp),%edx
  800174:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800177:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80017d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800182:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800185:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800188:	39 d3                	cmp    %edx,%ebx
  80018a:	72 05                	jb     800191 <printnum+0x30>
  80018c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80018f:	77 7a                	ja     80020b <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800191:	83 ec 0c             	sub    $0xc,%esp
  800194:	ff 75 18             	pushl  0x18(%ebp)
  800197:	8b 45 14             	mov    0x14(%ebp),%eax
  80019a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80019d:	53                   	push   %ebx
  80019e:	ff 75 10             	pushl  0x10(%ebp)
  8001a1:	83 ec 08             	sub    $0x8,%esp
  8001a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b0:	e8 ab 0b 00 00       	call   800d60 <__udivdi3>
  8001b5:	83 c4 18             	add    $0x18,%esp
  8001b8:	52                   	push   %edx
  8001b9:	50                   	push   %eax
  8001ba:	89 f2                	mov    %esi,%edx
  8001bc:	89 f8                	mov    %edi,%eax
  8001be:	e8 9e ff ff ff       	call   800161 <printnum>
  8001c3:	83 c4 20             	add    $0x20,%esp
  8001c6:	eb 13                	jmp    8001db <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	56                   	push   %esi
  8001cc:	ff 75 18             	pushl  0x18(%ebp)
  8001cf:	ff d7                	call   *%edi
  8001d1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001d4:	83 eb 01             	sub    $0x1,%ebx
  8001d7:	85 db                	test   %ebx,%ebx
  8001d9:	7f ed                	jg     8001c8 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	83 ec 04             	sub    $0x4,%esp
  8001e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ee:	e8 8d 0c 00 00       	call   800e80 <__umoddi3>
  8001f3:	83 c4 14             	add    $0x14,%esp
  8001f6:	0f be 80 b8 0f 80 00 	movsbl 0x800fb8(%eax),%eax
  8001fd:	50                   	push   %eax
  8001fe:	ff d7                	call   *%edi
}
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5f                   	pop    %edi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    
  80020b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80020e:	eb c4                	jmp    8001d4 <printnum+0x73>

00800210 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800216:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021a:	8b 10                	mov    (%eax),%edx
  80021c:	3b 50 04             	cmp    0x4(%eax),%edx
  80021f:	73 0a                	jae    80022b <sprintputch+0x1b>
		*b->buf++ = ch;
  800221:	8d 4a 01             	lea    0x1(%edx),%ecx
  800224:	89 08                	mov    %ecx,(%eax)
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	88 02                	mov    %al,(%edx)
}
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <printfmt>:
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800233:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800236:	50                   	push   %eax
  800237:	ff 75 10             	pushl  0x10(%ebp)
  80023a:	ff 75 0c             	pushl  0xc(%ebp)
  80023d:	ff 75 08             	pushl  0x8(%ebp)
  800240:	e8 05 00 00 00       	call   80024a <vprintfmt>
}
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	c9                   	leave  
  800249:	c3                   	ret    

0080024a <vprintfmt>:
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	57                   	push   %edi
  80024e:	56                   	push   %esi
  80024f:	53                   	push   %ebx
  800250:	83 ec 2c             	sub    $0x2c,%esp
  800253:	8b 75 08             	mov    0x8(%ebp),%esi
  800256:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800259:	8b 7d 10             	mov    0x10(%ebp),%edi
  80025c:	e9 c1 03 00 00       	jmp    800622 <vprintfmt+0x3d8>
		padc = ' ';
  800261:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800265:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80026c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800273:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80027a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80027f:	8d 47 01             	lea    0x1(%edi),%eax
  800282:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800285:	0f b6 17             	movzbl (%edi),%edx
  800288:	8d 42 dd             	lea    -0x23(%edx),%eax
  80028b:	3c 55                	cmp    $0x55,%al
  80028d:	0f 87 12 04 00 00    	ja     8006a5 <vprintfmt+0x45b>
  800293:	0f b6 c0             	movzbl %al,%eax
  800296:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  80029d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002a0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002a4:	eb d9                	jmp    80027f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002a9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002ad:	eb d0                	jmp    80027f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002af:	0f b6 d2             	movzbl %dl,%edx
  8002b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002bd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002c0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002c4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002c7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ca:	83 f9 09             	cmp    $0x9,%ecx
  8002cd:	77 55                	ja     800324 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002cf:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002d2:	eb e9                	jmp    8002bd <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002d7:	8b 00                	mov    (%eax),%eax
  8002d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002df:	8d 40 04             	lea    0x4(%eax),%eax
  8002e2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002e8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002ec:	79 91                	jns    80027f <vprintfmt+0x35>
				width = precision, precision = -1;
  8002ee:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8002f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002f4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002fb:	eb 82                	jmp    80027f <vprintfmt+0x35>
  8002fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800300:	85 c0                	test   %eax,%eax
  800302:	ba 00 00 00 00       	mov    $0x0,%edx
  800307:	0f 49 d0             	cmovns %eax,%edx
  80030a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80030d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800310:	e9 6a ff ff ff       	jmp    80027f <vprintfmt+0x35>
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800318:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80031f:	e9 5b ff ff ff       	jmp    80027f <vprintfmt+0x35>
  800324:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800327:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80032a:	eb bc                	jmp    8002e8 <vprintfmt+0x9e>
			lflag++;
  80032c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800332:	e9 48 ff ff ff       	jmp    80027f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8d 78 04             	lea    0x4(%eax),%edi
  80033d:	83 ec 08             	sub    $0x8,%esp
  800340:	53                   	push   %ebx
  800341:	ff 30                	pushl  (%eax)
  800343:	ff d6                	call   *%esi
			break;
  800345:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800348:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80034b:	e9 cf 02 00 00       	jmp    80061f <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800350:	8b 45 14             	mov    0x14(%ebp),%eax
  800353:	8d 78 04             	lea    0x4(%eax),%edi
  800356:	8b 00                	mov    (%eax),%eax
  800358:	99                   	cltd   
  800359:	31 d0                	xor    %edx,%eax
  80035b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80035d:	83 f8 08             	cmp    $0x8,%eax
  800360:	7f 23                	jg     800385 <vprintfmt+0x13b>
  800362:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  800369:	85 d2                	test   %edx,%edx
  80036b:	74 18                	je     800385 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80036d:	52                   	push   %edx
  80036e:	68 d9 0f 80 00       	push   $0x800fd9
  800373:	53                   	push   %ebx
  800374:	56                   	push   %esi
  800375:	e8 b3 fe ff ff       	call   80022d <printfmt>
  80037a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80037d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800380:	e9 9a 02 00 00       	jmp    80061f <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800385:	50                   	push   %eax
  800386:	68 d0 0f 80 00       	push   $0x800fd0
  80038b:	53                   	push   %ebx
  80038c:	56                   	push   %esi
  80038d:	e8 9b fe ff ff       	call   80022d <printfmt>
  800392:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800395:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800398:	e9 82 02 00 00       	jmp    80061f <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80039d:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a0:	83 c0 04             	add    $0x4,%eax
  8003a3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003ab:	85 ff                	test   %edi,%edi
  8003ad:	b8 c9 0f 80 00       	mov    $0x800fc9,%eax
  8003b2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003b5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b9:	0f 8e bd 00 00 00    	jle    80047c <vprintfmt+0x232>
  8003bf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003c3:	75 0e                	jne    8003d3 <vprintfmt+0x189>
  8003c5:	89 75 08             	mov    %esi,0x8(%ebp)
  8003c8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003cb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003ce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003d1:	eb 6d                	jmp    800440 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d3:	83 ec 08             	sub    $0x8,%esp
  8003d6:	ff 75 d0             	pushl  -0x30(%ebp)
  8003d9:	57                   	push   %edi
  8003da:	e8 6e 03 00 00       	call   80074d <strnlen>
  8003df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003e2:	29 c1                	sub    %eax,%ecx
  8003e4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003ea:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8003ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8003f4:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f6:	eb 0f                	jmp    800407 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8003f8:	83 ec 08             	sub    $0x8,%esp
  8003fb:	53                   	push   %ebx
  8003fc:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ff:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800401:	83 ef 01             	sub    $0x1,%edi
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	85 ff                	test   %edi,%edi
  800409:	7f ed                	jg     8003f8 <vprintfmt+0x1ae>
  80040b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80040e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800411:	85 c9                	test   %ecx,%ecx
  800413:	b8 00 00 00 00       	mov    $0x0,%eax
  800418:	0f 49 c1             	cmovns %ecx,%eax
  80041b:	29 c1                	sub    %eax,%ecx
  80041d:	89 75 08             	mov    %esi,0x8(%ebp)
  800420:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800423:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800426:	89 cb                	mov    %ecx,%ebx
  800428:	eb 16                	jmp    800440 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80042a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80042e:	75 31                	jne    800461 <vprintfmt+0x217>
					putch(ch, putdat);
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	ff 75 0c             	pushl  0xc(%ebp)
  800436:	50                   	push   %eax
  800437:	ff 55 08             	call   *0x8(%ebp)
  80043a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043d:	83 eb 01             	sub    $0x1,%ebx
  800440:	83 c7 01             	add    $0x1,%edi
  800443:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800447:	0f be c2             	movsbl %dl,%eax
  80044a:	85 c0                	test   %eax,%eax
  80044c:	74 59                	je     8004a7 <vprintfmt+0x25d>
  80044e:	85 f6                	test   %esi,%esi
  800450:	78 d8                	js     80042a <vprintfmt+0x1e0>
  800452:	83 ee 01             	sub    $0x1,%esi
  800455:	79 d3                	jns    80042a <vprintfmt+0x1e0>
  800457:	89 df                	mov    %ebx,%edi
  800459:	8b 75 08             	mov    0x8(%ebp),%esi
  80045c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045f:	eb 37                	jmp    800498 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800461:	0f be d2             	movsbl %dl,%edx
  800464:	83 ea 20             	sub    $0x20,%edx
  800467:	83 fa 5e             	cmp    $0x5e,%edx
  80046a:	76 c4                	jbe    800430 <vprintfmt+0x1e6>
					putch('?', putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	ff 75 0c             	pushl  0xc(%ebp)
  800472:	6a 3f                	push   $0x3f
  800474:	ff 55 08             	call   *0x8(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	eb c1                	jmp    80043d <vprintfmt+0x1f3>
  80047c:	89 75 08             	mov    %esi,0x8(%ebp)
  80047f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800482:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800485:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800488:	eb b6                	jmp    800440 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	53                   	push   %ebx
  80048e:	6a 20                	push   $0x20
  800490:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800492:	83 ef 01             	sub    $0x1,%edi
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 ff                	test   %edi,%edi
  80049a:	7f ee                	jg     80048a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80049c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049f:	89 45 14             	mov    %eax,0x14(%ebp)
  8004a2:	e9 78 01 00 00       	jmp    80061f <vprintfmt+0x3d5>
  8004a7:	89 df                	mov    %ebx,%edi
  8004a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004af:	eb e7                	jmp    800498 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004b1:	83 f9 01             	cmp    $0x1,%ecx
  8004b4:	7e 3f                	jle    8004f5 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8b 50 04             	mov    0x4(%eax),%edx
  8004bc:	8b 00                	mov    (%eax),%eax
  8004be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c7:	8d 40 08             	lea    0x8(%eax),%eax
  8004ca:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004d1:	79 5c                	jns    80052f <vprintfmt+0x2e5>
				putch('-', putdat);
  8004d3:	83 ec 08             	sub    $0x8,%esp
  8004d6:	53                   	push   %ebx
  8004d7:	6a 2d                	push   $0x2d
  8004d9:	ff d6                	call   *%esi
				num = -(long long) num;
  8004db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004de:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004e1:	f7 da                	neg    %edx
  8004e3:	83 d1 00             	adc    $0x0,%ecx
  8004e6:	f7 d9                	neg    %ecx
  8004e8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004f0:	e9 10 01 00 00       	jmp    800605 <vprintfmt+0x3bb>
	else if (lflag)
  8004f5:	85 c9                	test   %ecx,%ecx
  8004f7:	75 1b                	jne    800514 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8b 00                	mov    (%eax),%eax
  8004fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800501:	89 c1                	mov    %eax,%ecx
  800503:	c1 f9 1f             	sar    $0x1f,%ecx
  800506:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 40 04             	lea    0x4(%eax),%eax
  80050f:	89 45 14             	mov    %eax,0x14(%ebp)
  800512:	eb b9                	jmp    8004cd <vprintfmt+0x283>
		return va_arg(*ap, long);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051c:	89 c1                	mov    %eax,%ecx
  80051e:	c1 f9 1f             	sar    $0x1f,%ecx
  800521:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8d 40 04             	lea    0x4(%eax),%eax
  80052a:	89 45 14             	mov    %eax,0x14(%ebp)
  80052d:	eb 9e                	jmp    8004cd <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80052f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800532:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800535:	b8 0a 00 00 00       	mov    $0xa,%eax
  80053a:	e9 c6 00 00 00       	jmp    800605 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80053f:	83 f9 01             	cmp    $0x1,%ecx
  800542:	7e 18                	jle    80055c <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8b 10                	mov    (%eax),%edx
  800549:	8b 48 04             	mov    0x4(%eax),%ecx
  80054c:	8d 40 08             	lea    0x8(%eax),%eax
  80054f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800552:	b8 0a 00 00 00       	mov    $0xa,%eax
  800557:	e9 a9 00 00 00       	jmp    800605 <vprintfmt+0x3bb>
	else if (lflag)
  80055c:	85 c9                	test   %ecx,%ecx
  80055e:	75 1a                	jne    80057a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800560:	8b 45 14             	mov    0x14(%ebp),%eax
  800563:	8b 10                	mov    (%eax),%edx
  800565:	b9 00 00 00 00       	mov    $0x0,%ecx
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
  800575:	e9 8b 00 00 00       	jmp    800605 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 10                	mov    (%eax),%edx
  80057f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800584:	8d 40 04             	lea    0x4(%eax),%eax
  800587:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058f:	eb 74                	jmp    800605 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800591:	83 f9 01             	cmp    $0x1,%ecx
  800594:	7e 15                	jle    8005ab <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800596:	8b 45 14             	mov    0x14(%ebp),%eax
  800599:	8b 10                	mov    (%eax),%edx
  80059b:	8b 48 04             	mov    0x4(%eax),%ecx
  80059e:	8d 40 08             	lea    0x8(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005a9:	eb 5a                	jmp    800605 <vprintfmt+0x3bb>
	else if (lflag)
  8005ab:	85 c9                	test   %ecx,%ecx
  8005ad:	75 17                	jne    8005c6 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 10                	mov    (%eax),%edx
  8005b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b9:	8d 40 04             	lea    0x4(%eax),%eax
  8005bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005bf:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c4:	eb 3f                	jmp    800605 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005db:	eb 28                	jmp    800605 <vprintfmt+0x3bb>
			putch('0', putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	6a 30                	push   $0x30
  8005e3:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e5:	83 c4 08             	add    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 78                	push   $0x78
  8005eb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f0:	8b 10                	mov    (%eax),%edx
  8005f2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005f7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005fa:	8d 40 04             	lea    0x4(%eax),%eax
  8005fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800600:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800605:	83 ec 0c             	sub    $0xc,%esp
  800608:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80060c:	57                   	push   %edi
  80060d:	ff 75 e0             	pushl  -0x20(%ebp)
  800610:	50                   	push   %eax
  800611:	51                   	push   %ecx
  800612:	52                   	push   %edx
  800613:	89 da                	mov    %ebx,%edx
  800615:	89 f0                	mov    %esi,%eax
  800617:	e8 45 fb ff ff       	call   800161 <printnum>
			break;
  80061c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800622:	83 c7 01             	add    $0x1,%edi
  800625:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800629:	83 f8 25             	cmp    $0x25,%eax
  80062c:	0f 84 2f fc ff ff    	je     800261 <vprintfmt+0x17>
			if (ch == '\0')
  800632:	85 c0                	test   %eax,%eax
  800634:	0f 84 8b 00 00 00    	je     8006c5 <vprintfmt+0x47b>
			putch(ch, putdat);
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	53                   	push   %ebx
  80063e:	50                   	push   %eax
  80063f:	ff d6                	call   *%esi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	eb dc                	jmp    800622 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800646:	83 f9 01             	cmp    $0x1,%ecx
  800649:	7e 15                	jle    800660 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	8b 48 04             	mov    0x4(%eax),%ecx
  800653:	8d 40 08             	lea    0x8(%eax),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800659:	b8 10 00 00 00       	mov    $0x10,%eax
  80065e:	eb a5                	jmp    800605 <vprintfmt+0x3bb>
	else if (lflag)
  800660:	85 c9                	test   %ecx,%ecx
  800662:	75 17                	jne    80067b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 10                	mov    (%eax),%edx
  800669:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066e:	8d 40 04             	lea    0x4(%eax),%eax
  800671:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800674:	b8 10 00 00 00       	mov    $0x10,%eax
  800679:	eb 8a                	jmp    800605 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	b9 00 00 00 00       	mov    $0x0,%ecx
  800685:	8d 40 04             	lea    0x4(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068b:	b8 10 00 00 00       	mov    $0x10,%eax
  800690:	e9 70 ff ff ff       	jmp    800605 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800695:	83 ec 08             	sub    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 25                	push   $0x25
  80069b:	ff d6                	call   *%esi
			break;
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	e9 7a ff ff ff       	jmp    80061f <vprintfmt+0x3d5>
			putch('%', putdat);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	53                   	push   %ebx
  8006a9:	6a 25                	push   $0x25
  8006ab:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	89 f8                	mov    %edi,%eax
  8006b2:	eb 03                	jmp    8006b7 <vprintfmt+0x46d>
  8006b4:	83 e8 01             	sub    $0x1,%eax
  8006b7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006bb:	75 f7                	jne    8006b4 <vprintfmt+0x46a>
  8006bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006c0:	e9 5a ff ff ff       	jmp    80061f <vprintfmt+0x3d5>
}
  8006c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c8:	5b                   	pop    %ebx
  8006c9:	5e                   	pop    %esi
  8006ca:	5f                   	pop    %edi
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	83 ec 18             	sub    $0x18,%esp
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ea:	85 c0                	test   %eax,%eax
  8006ec:	74 26                	je     800714 <vsnprintf+0x47>
  8006ee:	85 d2                	test   %edx,%edx
  8006f0:	7e 22                	jle    800714 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f2:	ff 75 14             	pushl  0x14(%ebp)
  8006f5:	ff 75 10             	pushl  0x10(%ebp)
  8006f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fb:	50                   	push   %eax
  8006fc:	68 10 02 80 00       	push   $0x800210
  800701:	e8 44 fb ff ff       	call   80024a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800706:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800709:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070f:	83 c4 10             	add    $0x10,%esp
}
  800712:	c9                   	leave  
  800713:	c3                   	ret    
		return -E_INVAL;
  800714:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800719:	eb f7                	jmp    800712 <vsnprintf+0x45>

0080071b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800721:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800724:	50                   	push   %eax
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	ff 75 0c             	pushl  0xc(%ebp)
  80072b:	ff 75 08             	pushl  0x8(%ebp)
  80072e:	e8 9a ff ff ff       	call   8006cd <vsnprintf>
	va_end(ap);

	return rc;
}
  800733:	c9                   	leave  
  800734:	c3                   	ret    

00800735 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800735:	55                   	push   %ebp
  800736:	89 e5                	mov    %esp,%ebp
  800738:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073b:	b8 00 00 00 00       	mov    $0x0,%eax
  800740:	eb 03                	jmp    800745 <strlen+0x10>
		n++;
  800742:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800745:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800749:	75 f7                	jne    800742 <strlen+0xd>
	return n;
}
  80074b:	5d                   	pop    %ebp
  80074c:	c3                   	ret    

0080074d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	eb 03                	jmp    800760 <strnlen+0x13>
		n++;
  80075d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	39 d0                	cmp    %edx,%eax
  800762:	74 06                	je     80076a <strnlen+0x1d>
  800764:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800768:	75 f3                	jne    80075d <strnlen+0x10>
	return n;
}
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	53                   	push   %ebx
  800770:	8b 45 08             	mov    0x8(%ebp),%eax
  800773:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c1 01             	add    $0x1,%ecx
  80077b:	83 c2 01             	add    $0x1,%edx
  80077e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800782:	88 5a ff             	mov    %bl,-0x1(%edx)
  800785:	84 db                	test   %bl,%bl
  800787:	75 ef                	jne    800778 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800789:	5b                   	pop    %ebx
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800793:	53                   	push   %ebx
  800794:	e8 9c ff ff ff       	call   800735 <strlen>
  800799:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079c:	ff 75 0c             	pushl  0xc(%ebp)
  80079f:	01 d8                	add    %ebx,%eax
  8007a1:	50                   	push   %eax
  8007a2:	e8 c5 ff ff ff       	call   80076c <strcpy>
	return dst;
}
  8007a7:	89 d8                	mov    %ebx,%eax
  8007a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ac:	c9                   	leave  
  8007ad:	c3                   	ret    

008007ae <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ae:	55                   	push   %ebp
  8007af:	89 e5                	mov    %esp,%ebp
  8007b1:	56                   	push   %esi
  8007b2:	53                   	push   %ebx
  8007b3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b9:	89 f3                	mov    %esi,%ebx
  8007bb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007be:	89 f2                	mov    %esi,%edx
  8007c0:	eb 0f                	jmp    8007d1 <strncpy+0x23>
		*dst++ = *src;
  8007c2:	83 c2 01             	add    $0x1,%edx
  8007c5:	0f b6 01             	movzbl (%ecx),%eax
  8007c8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007cb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ce:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007d1:	39 da                	cmp    %ebx,%edx
  8007d3:	75 ed                	jne    8007c2 <strncpy+0x14>
	}
	return ret;
}
  8007d5:	89 f0                	mov    %esi,%eax
  8007d7:	5b                   	pop    %ebx
  8007d8:	5e                   	pop    %esi
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8007e9:	89 f0                	mov    %esi,%eax
  8007eb:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ef:	85 c9                	test   %ecx,%ecx
  8007f1:	75 0b                	jne    8007fe <strlcpy+0x23>
  8007f3:	eb 17                	jmp    80080c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007f5:	83 c2 01             	add    $0x1,%edx
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8007fe:	39 d8                	cmp    %ebx,%eax
  800800:	74 07                	je     800809 <strlcpy+0x2e>
  800802:	0f b6 0a             	movzbl (%edx),%ecx
  800805:	84 c9                	test   %cl,%cl
  800807:	75 ec                	jne    8007f5 <strlcpy+0x1a>
		*dst = '\0';
  800809:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80080c:	29 f0                	sub    %esi,%eax
}
  80080e:	5b                   	pop    %ebx
  80080f:	5e                   	pop    %esi
  800810:	5d                   	pop    %ebp
  800811:	c3                   	ret    

00800812 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800818:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80081b:	eb 06                	jmp    800823 <strcmp+0x11>
		p++, q++;
  80081d:	83 c1 01             	add    $0x1,%ecx
  800820:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800823:	0f b6 01             	movzbl (%ecx),%eax
  800826:	84 c0                	test   %al,%al
  800828:	74 04                	je     80082e <strcmp+0x1c>
  80082a:	3a 02                	cmp    (%edx),%al
  80082c:	74 ef                	je     80081d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082e:	0f b6 c0             	movzbl %al,%eax
  800831:	0f b6 12             	movzbl (%edx),%edx
  800834:	29 d0                	sub    %edx,%eax
}
  800836:	5d                   	pop    %ebp
  800837:	c3                   	ret    

00800838 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	53                   	push   %ebx
  80083c:	8b 45 08             	mov    0x8(%ebp),%eax
  80083f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800842:	89 c3                	mov    %eax,%ebx
  800844:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800847:	eb 06                	jmp    80084f <strncmp+0x17>
		n--, p++, q++;
  800849:	83 c0 01             	add    $0x1,%eax
  80084c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80084f:	39 d8                	cmp    %ebx,%eax
  800851:	74 16                	je     800869 <strncmp+0x31>
  800853:	0f b6 08             	movzbl (%eax),%ecx
  800856:	84 c9                	test   %cl,%cl
  800858:	74 04                	je     80085e <strncmp+0x26>
  80085a:	3a 0a                	cmp    (%edx),%cl
  80085c:	74 eb                	je     800849 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085e:	0f b6 00             	movzbl (%eax),%eax
  800861:	0f b6 12             	movzbl (%edx),%edx
  800864:	29 d0                	sub    %edx,%eax
}
  800866:	5b                   	pop    %ebx
  800867:	5d                   	pop    %ebp
  800868:	c3                   	ret    
		return 0;
  800869:	b8 00 00 00 00       	mov    $0x0,%eax
  80086e:	eb f6                	jmp    800866 <strncmp+0x2e>

00800870 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 45 08             	mov    0x8(%ebp),%eax
  800876:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80087a:	0f b6 10             	movzbl (%eax),%edx
  80087d:	84 d2                	test   %dl,%dl
  80087f:	74 09                	je     80088a <strchr+0x1a>
		if (*s == c)
  800881:	38 ca                	cmp    %cl,%dl
  800883:	74 0a                	je     80088f <strchr+0x1f>
	for (; *s; s++)
  800885:	83 c0 01             	add    $0x1,%eax
  800888:	eb f0                	jmp    80087a <strchr+0xa>
			return (char *) s;
	return 0;
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089b:	eb 03                	jmp    8008a0 <strfind+0xf>
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008a3:	38 ca                	cmp    %cl,%dl
  8008a5:	74 04                	je     8008ab <strfind+0x1a>
  8008a7:	84 d2                	test   %dl,%dl
  8008a9:	75 f2                	jne    80089d <strfind+0xc>
			break;
	return (char *) s;
}
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	57                   	push   %edi
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
  8008b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b9:	85 c9                	test   %ecx,%ecx
  8008bb:	74 13                	je     8008d0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008bd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008c3:	75 05                	jne    8008ca <memset+0x1d>
  8008c5:	f6 c1 03             	test   $0x3,%cl
  8008c8:	74 0d                	je     8008d7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    
		c &= 0xFF;
  8008d7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008db:	89 d3                	mov    %edx,%ebx
  8008dd:	c1 e3 08             	shl    $0x8,%ebx
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	c1 e0 18             	shl    $0x18,%eax
  8008e5:	89 d6                	mov    %edx,%esi
  8008e7:	c1 e6 10             	shl    $0x10,%esi
  8008ea:	09 f0                	or     %esi,%eax
  8008ec:	09 c2                	or     %eax,%edx
  8008ee:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8008f0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008f3:	89 d0                	mov    %edx,%eax
  8008f5:	fc                   	cld    
  8008f6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f8:	eb d6                	jmp    8008d0 <memset+0x23>

008008fa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800902:	8b 75 0c             	mov    0xc(%ebp),%esi
  800905:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800908:	39 c6                	cmp    %eax,%esi
  80090a:	73 35                	jae    800941 <memmove+0x47>
  80090c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090f:	39 c2                	cmp    %eax,%edx
  800911:	76 2e                	jbe    800941 <memmove+0x47>
		s += n;
		d += n;
  800913:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800916:	89 d6                	mov    %edx,%esi
  800918:	09 fe                	or     %edi,%esi
  80091a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800920:	74 0c                	je     80092e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800922:	83 ef 01             	sub    $0x1,%edi
  800925:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800928:	fd                   	std    
  800929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092b:	fc                   	cld    
  80092c:	eb 21                	jmp    80094f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	f6 c1 03             	test   $0x3,%cl
  800931:	75 ef                	jne    800922 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800933:	83 ef 04             	sub    $0x4,%edi
  800936:	8d 72 fc             	lea    -0x4(%edx),%esi
  800939:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80093c:	fd                   	std    
  80093d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093f:	eb ea                	jmp    80092b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800941:	89 f2                	mov    %esi,%edx
  800943:	09 c2                	or     %eax,%edx
  800945:	f6 c2 03             	test   $0x3,%dl
  800948:	74 09                	je     800953 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80094a:	89 c7                	mov    %eax,%edi
  80094c:	fc                   	cld    
  80094d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094f:	5e                   	pop    %esi
  800950:	5f                   	pop    %edi
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800953:	f6 c1 03             	test   $0x3,%cl
  800956:	75 f2                	jne    80094a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800958:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80095b:	89 c7                	mov    %eax,%edi
  80095d:	fc                   	cld    
  80095e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800960:	eb ed                	jmp    80094f <memmove+0x55>

00800962 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800965:	ff 75 10             	pushl  0x10(%ebp)
  800968:	ff 75 0c             	pushl  0xc(%ebp)
  80096b:	ff 75 08             	pushl  0x8(%ebp)
  80096e:	e8 87 ff ff ff       	call   8008fa <memmove>
}
  800973:	c9                   	leave  
  800974:	c3                   	ret    

00800975 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	56                   	push   %esi
  800979:	53                   	push   %ebx
  80097a:	8b 45 08             	mov    0x8(%ebp),%eax
  80097d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800980:	89 c6                	mov    %eax,%esi
  800982:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800985:	39 f0                	cmp    %esi,%eax
  800987:	74 1c                	je     8009a5 <memcmp+0x30>
		if (*s1 != *s2)
  800989:	0f b6 08             	movzbl (%eax),%ecx
  80098c:	0f b6 1a             	movzbl (%edx),%ebx
  80098f:	38 d9                	cmp    %bl,%cl
  800991:	75 08                	jne    80099b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800993:	83 c0 01             	add    $0x1,%eax
  800996:	83 c2 01             	add    $0x1,%edx
  800999:	eb ea                	jmp    800985 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  80099b:	0f b6 c1             	movzbl %cl,%eax
  80099e:	0f b6 db             	movzbl %bl,%ebx
  8009a1:	29 d8                	sub    %ebx,%eax
  8009a3:	eb 05                	jmp    8009aa <memcmp+0x35>
	}

	return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5e                   	pop    %esi
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b7:	89 c2                	mov    %eax,%edx
  8009b9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009bc:	39 d0                	cmp    %edx,%eax
  8009be:	73 09                	jae    8009c9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c0:	38 08                	cmp    %cl,(%eax)
  8009c2:	74 05                	je     8009c9 <memfind+0x1b>
	for (; s < ends; s++)
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	eb f3                	jmp    8009bc <memfind+0xe>
			break;
	return (void *) s;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	57                   	push   %edi
  8009cf:	56                   	push   %esi
  8009d0:	53                   	push   %ebx
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d7:	eb 03                	jmp    8009dc <strtol+0x11>
		s++;
  8009d9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009dc:	0f b6 01             	movzbl (%ecx),%eax
  8009df:	3c 20                	cmp    $0x20,%al
  8009e1:	74 f6                	je     8009d9 <strtol+0xe>
  8009e3:	3c 09                	cmp    $0x9,%al
  8009e5:	74 f2                	je     8009d9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  8009e7:	3c 2b                	cmp    $0x2b,%al
  8009e9:	74 2e                	je     800a19 <strtol+0x4e>
	int neg = 0;
  8009eb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f0:	3c 2d                	cmp    $0x2d,%al
  8009f2:	74 2f                	je     800a23 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009fa:	75 05                	jne    800a01 <strtol+0x36>
  8009fc:	80 39 30             	cmpb   $0x30,(%ecx)
  8009ff:	74 2c                	je     800a2d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a01:	85 db                	test   %ebx,%ebx
  800a03:	75 0a                	jne    800a0f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a05:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a0a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a0d:	74 28                	je     800a37 <strtol+0x6c>
		base = 10;
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a14:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a17:	eb 50                	jmp    800a69 <strtol+0x9e>
		s++;
  800a19:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a1c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a21:	eb d1                	jmp    8009f4 <strtol+0x29>
		s++, neg = 1;
  800a23:	83 c1 01             	add    $0x1,%ecx
  800a26:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2b:	eb c7                	jmp    8009f4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a31:	74 0e                	je     800a41 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a33:	85 db                	test   %ebx,%ebx
  800a35:	75 d8                	jne    800a0f <strtol+0x44>
		s++, base = 8;
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a3f:	eb ce                	jmp    800a0f <strtol+0x44>
		s += 2, base = 16;
  800a41:	83 c1 02             	add    $0x2,%ecx
  800a44:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a49:	eb c4                	jmp    800a0f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a4b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 29                	ja     800a7e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5e:	7d 30                	jge    800a90 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a67:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a69:	0f b6 11             	movzbl (%ecx),%edx
  800a6c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a6f:	89 f3                	mov    %esi,%ebx
  800a71:	80 fb 09             	cmp    $0x9,%bl
  800a74:	77 d5                	ja     800a4b <strtol+0x80>
			dig = *s - '0';
  800a76:	0f be d2             	movsbl %dl,%edx
  800a79:	83 ea 30             	sub    $0x30,%edx
  800a7c:	eb dd                	jmp    800a5b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a7e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a81:	89 f3                	mov    %esi,%ebx
  800a83:	80 fb 19             	cmp    $0x19,%bl
  800a86:	77 08                	ja     800a90 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a88:	0f be d2             	movsbl %dl,%edx
  800a8b:	83 ea 37             	sub    $0x37,%edx
  800a8e:	eb cb                	jmp    800a5b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a90:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a94:	74 05                	je     800a9b <strtol+0xd0>
		*endptr = (char *) s;
  800a96:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a99:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a9b:	89 c2                	mov    %eax,%edx
  800a9d:	f7 da                	neg    %edx
  800a9f:	85 ff                	test   %edi,%edi
  800aa1:	0f 45 c2             	cmovne %edx,%eax
}
  800aa4:	5b                   	pop    %ebx
  800aa5:	5e                   	pop    %esi
  800aa6:	5f                   	pop    %edi
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	57                   	push   %edi
  800aad:	56                   	push   %esi
  800aae:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ab7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aba:	89 c3                	mov    %eax,%ebx
  800abc:	89 c7                	mov    %eax,%edi
  800abe:	89 c6                	mov    %eax,%esi
  800ac0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac2:	5b                   	pop    %ebx
  800ac3:	5e                   	pop    %esi
  800ac4:	5f                   	pop    %edi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800acd:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad7:	89 d1                	mov    %edx,%ecx
  800ad9:	89 d3                	mov    %edx,%ebx
  800adb:	89 d7                	mov    %edx,%edi
  800add:	89 d6                	mov    %edx,%esi
  800adf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae1:	5b                   	pop    %ebx
  800ae2:	5e                   	pop    %esi
  800ae3:	5f                   	pop    %edi
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	57                   	push   %edi
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800aef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af4:	8b 55 08             	mov    0x8(%ebp),%edx
  800af7:	b8 03 00 00 00       	mov    $0x3,%eax
  800afc:	89 cb                	mov    %ecx,%ebx
  800afe:	89 cf                	mov    %ecx,%edi
  800b00:	89 ce                	mov    %ecx,%esi
  800b02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b04:	85 c0                	test   %eax,%eax
  800b06:	7f 08                	jg     800b10 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	50                   	push   %eax
  800b14:	6a 03                	push   $0x3
  800b16:	68 04 12 80 00       	push   $0x801204
  800b1b:	6a 23                	push   $0x23
  800b1d:	68 21 12 80 00       	push   $0x801221
  800b22:	e8 ed 01 00 00       	call   800d14 <_panic>

00800b27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 02 00 00 00       	mov    $0x2,%eax
  800b37:	89 d1                	mov    %edx,%ecx
  800b39:	89 d3                	mov    %edx,%ebx
  800b3b:	89 d7                	mov    %edx,%edi
  800b3d:	89 d6                	mov    %edx,%esi
  800b3f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <sys_yield>:

void
sys_yield(void)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	57                   	push   %edi
  800b4a:	56                   	push   %esi
  800b4b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b56:	89 d1                	mov    %edx,%ecx
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	89 d7                	mov    %edx,%edi
  800b5c:	89 d6                	mov    %edx,%esi
  800b5e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b60:	5b                   	pop    %ebx
  800b61:	5e                   	pop    %esi
  800b62:	5f                   	pop    %edi
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	57                   	push   %edi
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b6e:	be 00 00 00 00       	mov    $0x0,%esi
  800b73:	8b 55 08             	mov    0x8(%ebp),%edx
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b79:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b81:	89 f7                	mov    %esi,%edi
  800b83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b85:	85 c0                	test   %eax,%eax
  800b87:	7f 08                	jg     800b91 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5f                   	pop    %edi
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b91:	83 ec 0c             	sub    $0xc,%esp
  800b94:	50                   	push   %eax
  800b95:	6a 04                	push   $0x4
  800b97:	68 04 12 80 00       	push   $0x801204
  800b9c:	6a 23                	push   $0x23
  800b9e:	68 21 12 80 00       	push   $0x801221
  800ba3:	e8 6c 01 00 00       	call   800d14 <_panic>

00800ba8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc2:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc7:	85 c0                	test   %eax,%eax
  800bc9:	7f 08                	jg     800bd3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bce:	5b                   	pop    %ebx
  800bcf:	5e                   	pop    %esi
  800bd0:	5f                   	pop    %edi
  800bd1:	5d                   	pop    %ebp
  800bd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 05                	push   $0x5
  800bd9:	68 04 12 80 00       	push   $0x801204
  800bde:	6a 23                	push   $0x23
  800be0:	68 21 12 80 00       	push   $0x801221
  800be5:	e8 2a 01 00 00       	call   800d14 <_panic>

00800bea <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	57                   	push   %edi
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bf3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bfe:	b8 06 00 00 00       	mov    $0x6,%eax
  800c03:	89 df                	mov    %ebx,%edi
  800c05:	89 de                	mov    %ebx,%esi
  800c07:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c09:	85 c0                	test   %eax,%eax
  800c0b:	7f 08                	jg     800c15 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 06                	push   $0x6
  800c1b:	68 04 12 80 00       	push   $0x801204
  800c20:	6a 23                	push   $0x23
  800c22:	68 21 12 80 00       	push   $0x801221
  800c27:	e8 e8 00 00 00       	call   800d14 <_panic>

00800c2c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2c:	55                   	push   %ebp
  800c2d:	89 e5                	mov    %esp,%ebp
  800c2f:	57                   	push   %edi
  800c30:	56                   	push   %esi
  800c31:	53                   	push   %ebx
  800c32:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c40:	b8 08 00 00 00       	mov    $0x8,%eax
  800c45:	89 df                	mov    %ebx,%edi
  800c47:	89 de                	mov    %ebx,%esi
  800c49:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	7f 08                	jg     800c57 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c52:	5b                   	pop    %ebx
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 08                	push   $0x8
  800c5d:	68 04 12 80 00       	push   $0x801204
  800c62:	6a 23                	push   $0x23
  800c64:	68 21 12 80 00       	push   $0x801221
  800c69:	e8 a6 00 00 00       	call   800d14 <_panic>

00800c6e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	57                   	push   %edi
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c77:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	b8 09 00 00 00       	mov    $0x9,%eax
  800c87:	89 df                	mov    %ebx,%edi
  800c89:	89 de                	mov    %ebx,%esi
  800c8b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c8d:	85 c0                	test   %eax,%eax
  800c8f:	7f 08                	jg     800c99 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 09                	push   $0x9
  800c9f:	68 04 12 80 00       	push   $0x801204
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 21 12 80 00       	push   $0x801221
  800cab:	e8 64 00 00 00       	call   800d14 <_panic>

00800cb0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	57                   	push   %edi
  800cb4:	56                   	push   %esi
  800cb5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ccc:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    

00800cd3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	57                   	push   %edi
  800cd7:	56                   	push   %esi
  800cd8:	53                   	push   %ebx
  800cd9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce4:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce9:	89 cb                	mov    %ecx,%ebx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	89 ce                	mov    %ecx,%esi
  800cef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	7f 08                	jg     800cfd <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf8:	5b                   	pop    %ebx
  800cf9:	5e                   	pop    %esi
  800cfa:	5f                   	pop    %edi
  800cfb:	5d                   	pop    %ebp
  800cfc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 0c                	push   $0xc
  800d03:	68 04 12 80 00       	push   $0x801204
  800d08:	6a 23                	push   $0x23
  800d0a:	68 21 12 80 00       	push   $0x801221
  800d0f:	e8 00 00 00 00       	call   800d14 <_panic>

00800d14 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d19:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d1c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d22:	e8 00 fe ff ff       	call   800b27 <sys_getenvid>
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	ff 75 0c             	pushl  0xc(%ebp)
  800d2d:	ff 75 08             	pushl  0x8(%ebp)
  800d30:	56                   	push   %esi
  800d31:	50                   	push   %eax
  800d32:	68 30 12 80 00       	push   $0x801230
  800d37:	e8 11 f4 ff ff       	call   80014d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d3c:	83 c4 18             	add    $0x18,%esp
  800d3f:	53                   	push   %ebx
  800d40:	ff 75 10             	pushl  0x10(%ebp)
  800d43:	e8 b4 f3 ff ff       	call   8000fc <vcprintf>
	cprintf("\n");
  800d48:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  800d4f:	e8 f9 f3 ff ff       	call   80014d <cprintf>
  800d54:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d57:	cc                   	int3   
  800d58:	eb fd                	jmp    800d57 <_panic+0x43>
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
