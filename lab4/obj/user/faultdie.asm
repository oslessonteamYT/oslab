
obj/user/faultdie：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 60 10 80 00       	push   $0x801060
  80004a:	e8 1e 01 00 00       	call   80016d <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 f3 0a 00 00       	call   800b47 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 aa 0a 00 00       	call   800b06 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 c3 0c 00 00       	call   800d34 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80008b:	e8 b7 0a 00 00       	call   800b47 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 33 0a 00 00       	call   800b06 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	74 09                	je     800100 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800100:	83 ec 08             	sub    $0x8,%esp
  800103:	68 ff 00 00 00       	push   $0xff
  800108:	8d 43 08             	lea    0x8(%ebx),%eax
  80010b:	50                   	push   %eax
  80010c:	e8 b8 09 00 00       	call   800ac9 <sys_cputs>
		b->idx = 0;
  800111:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800117:	83 c4 10             	add    $0x10,%esp
  80011a:	eb db                	jmp    8000f7 <putch+0x1f>

0080011c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800125:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012c:	00 00 00 
	b.cnt = 0;
  80012f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800136:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800139:	ff 75 0c             	pushl  0xc(%ebp)
  80013c:	ff 75 08             	pushl  0x8(%ebp)
  80013f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	68 d8 00 80 00       	push   $0x8000d8
  80014b:	e8 1a 01 00 00       	call   80026a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800150:	83 c4 08             	add    $0x8,%esp
  800153:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800159:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	e8 64 09 00 00       	call   800ac9 <sys_cputs>

	return b.cnt;
}
  800165:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800173:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800176:	50                   	push   %eax
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	e8 9d ff ff ff       	call   80011c <vcprintf>
	va_end(ap);

	return cnt;
}
  80017f:	c9                   	leave  
  800180:	c3                   	ret    

00800181 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 1c             	sub    $0x1c,%esp
  80018a:	89 c7                	mov    %eax,%edi
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	8b 55 0c             	mov    0xc(%ebp),%edx
  800194:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800197:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80019d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a8:	39 d3                	cmp    %edx,%ebx
  8001aa:	72 05                	jb     8001b1 <printnum+0x30>
  8001ac:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001af:	77 7a                	ja     80022b <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b1:	83 ec 0c             	sub    $0xc,%esp
  8001b4:	ff 75 18             	pushl  0x18(%ebp)
  8001b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ba:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001bd:	53                   	push   %ebx
  8001be:	ff 75 10             	pushl  0x10(%ebp)
  8001c1:	83 ec 08             	sub    $0x8,%esp
  8001c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ca:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cd:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d0:	e8 3b 0c 00 00       	call   800e10 <__udivdi3>
  8001d5:	83 c4 18             	add    $0x18,%esp
  8001d8:	52                   	push   %edx
  8001d9:	50                   	push   %eax
  8001da:	89 f2                	mov    %esi,%edx
  8001dc:	89 f8                	mov    %edi,%eax
  8001de:	e8 9e ff ff ff       	call   800181 <printnum>
  8001e3:	83 c4 20             	add    $0x20,%esp
  8001e6:	eb 13                	jmp    8001fb <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e8:	83 ec 08             	sub    $0x8,%esp
  8001eb:	56                   	push   %esi
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	ff d7                	call   *%edi
  8001f1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001f4:	83 eb 01             	sub    $0x1,%ebx
  8001f7:	85 db                	test   %ebx,%ebx
  8001f9:	7f ed                	jg     8001e8 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	56                   	push   %esi
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	ff 75 e4             	pushl  -0x1c(%ebp)
  800205:	ff 75 e0             	pushl  -0x20(%ebp)
  800208:	ff 75 dc             	pushl  -0x24(%ebp)
  80020b:	ff 75 d8             	pushl  -0x28(%ebp)
  80020e:	e8 1d 0d 00 00       	call   800f30 <__umoddi3>
  800213:	83 c4 14             	add    $0x14,%esp
  800216:	0f be 80 86 10 80 00 	movsbl 0x801086(%eax),%eax
  80021d:	50                   	push   %eax
  80021e:	ff d7                	call   *%edi
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5f                   	pop    %edi
  800229:	5d                   	pop    %ebp
  80022a:	c3                   	ret    
  80022b:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80022e:	eb c4                	jmp    8001f4 <printnum+0x73>

00800230 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800236:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80023a:	8b 10                	mov    (%eax),%edx
  80023c:	3b 50 04             	cmp    0x4(%eax),%edx
  80023f:	73 0a                	jae    80024b <sprintputch+0x1b>
		*b->buf++ = ch;
  800241:	8d 4a 01             	lea    0x1(%edx),%ecx
  800244:	89 08                	mov    %ecx,(%eax)
  800246:	8b 45 08             	mov    0x8(%ebp),%eax
  800249:	88 02                	mov    %al,(%edx)
}
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    

0080024d <printfmt>:
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800253:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800256:	50                   	push   %eax
  800257:	ff 75 10             	pushl  0x10(%ebp)
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	e8 05 00 00 00       	call   80026a <vprintfmt>
}
  800265:	83 c4 10             	add    $0x10,%esp
  800268:	c9                   	leave  
  800269:	c3                   	ret    

0080026a <vprintfmt>:
{
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	57                   	push   %edi
  80026e:	56                   	push   %esi
  80026f:	53                   	push   %ebx
  800270:	83 ec 2c             	sub    $0x2c,%esp
  800273:	8b 75 08             	mov    0x8(%ebp),%esi
  800276:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800279:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027c:	e9 c1 03 00 00       	jmp    800642 <vprintfmt+0x3d8>
		padc = ' ';
  800281:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800285:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80028c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800293:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80029a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80029f:	8d 47 01             	lea    0x1(%edi),%eax
  8002a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a5:	0f b6 17             	movzbl (%edi),%edx
  8002a8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ab:	3c 55                	cmp    $0x55,%al
  8002ad:	0f 87 12 04 00 00    	ja     8006c5 <vprintfmt+0x45b>
  8002b3:	0f b6 c0             	movzbl %al,%eax
  8002b6:	ff 24 85 40 11 80 00 	jmp    *0x801140(,%eax,4)
  8002bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c0:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002c4:	eb d9                	jmp    80029f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002c9:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002cd:	eb d0                	jmp    80029f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002cf:	0f b6 d2             	movzbl %dl,%edx
  8002d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002dd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ea:	83 f9 09             	cmp    $0x9,%ecx
  8002ed:	77 55                	ja     800344 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  8002ef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f2:	eb e9                	jmp    8002dd <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8002f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f7:	8b 00                	mov    (%eax),%eax
  8002f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ff:	8d 40 04             	lea    0x4(%eax),%eax
  800302:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800308:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030c:	79 91                	jns    80029f <vprintfmt+0x35>
				width = precision, precision = -1;
  80030e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800311:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800314:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80031b:	eb 82                	jmp    80029f <vprintfmt+0x35>
  80031d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800320:	85 c0                	test   %eax,%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	0f 49 d0             	cmovns %eax,%edx
  80032a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800330:	e9 6a ff ff ff       	jmp    80029f <vprintfmt+0x35>
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800338:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80033f:	e9 5b ff ff ff       	jmp    80029f <vprintfmt+0x35>
  800344:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800347:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80034a:	eb bc                	jmp    800308 <vprintfmt+0x9e>
			lflag++;
  80034c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800352:	e9 48 ff ff ff       	jmp    80029f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8d 78 04             	lea    0x4(%eax),%edi
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	53                   	push   %ebx
  800361:	ff 30                	pushl  (%eax)
  800363:	ff d6                	call   *%esi
			break;
  800365:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800368:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036b:	e9 cf 02 00 00       	jmp    80063f <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 78 04             	lea    0x4(%eax),%edi
  800376:	8b 00                	mov    (%eax),%eax
  800378:	99                   	cltd   
  800379:	31 d0                	xor    %edx,%eax
  80037b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037d:	83 f8 08             	cmp    $0x8,%eax
  800380:	7f 23                	jg     8003a5 <vprintfmt+0x13b>
  800382:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800389:	85 d2                	test   %edx,%edx
  80038b:	74 18                	je     8003a5 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80038d:	52                   	push   %edx
  80038e:	68 a7 10 80 00       	push   $0x8010a7
  800393:	53                   	push   %ebx
  800394:	56                   	push   %esi
  800395:	e8 b3 fe ff ff       	call   80024d <printfmt>
  80039a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a0:	e9 9a 02 00 00       	jmp    80063f <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003a5:	50                   	push   %eax
  8003a6:	68 9e 10 80 00       	push   $0x80109e
  8003ab:	53                   	push   %ebx
  8003ac:	56                   	push   %esi
  8003ad:	e8 9b fe ff ff       	call   80024d <printfmt>
  8003b2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b8:	e9 82 02 00 00       	jmp    80063f <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	83 c0 04             	add    $0x4,%eax
  8003c3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003cb:	85 ff                	test   %edi,%edi
  8003cd:	b8 97 10 80 00       	mov    $0x801097,%eax
  8003d2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d9:	0f 8e bd 00 00 00    	jle    80049c <vprintfmt+0x232>
  8003df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003e3:	75 0e                	jne    8003f3 <vprintfmt+0x189>
  8003e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8003e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8003eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8003ee:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8003f1:	eb 6d                	jmp    800460 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	ff 75 d0             	pushl  -0x30(%ebp)
  8003f9:	57                   	push   %edi
  8003fa:	e8 6e 03 00 00       	call   80076d <strnlen>
  8003ff:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800402:	29 c1                	sub    %eax,%ecx
  800404:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800407:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80040a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80040e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800411:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800414:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800416:	eb 0f                	jmp    800427 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800418:	83 ec 08             	sub    $0x8,%esp
  80041b:	53                   	push   %ebx
  80041c:	ff 75 e0             	pushl  -0x20(%ebp)
  80041f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800421:	83 ef 01             	sub    $0x1,%edi
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	85 ff                	test   %edi,%edi
  800429:	7f ed                	jg     800418 <vprintfmt+0x1ae>
  80042b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80042e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800431:	85 c9                	test   %ecx,%ecx
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	0f 49 c1             	cmovns %ecx,%eax
  80043b:	29 c1                	sub    %eax,%ecx
  80043d:	89 75 08             	mov    %esi,0x8(%ebp)
  800440:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800443:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800446:	89 cb                	mov    %ecx,%ebx
  800448:	eb 16                	jmp    800460 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  80044a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044e:	75 31                	jne    800481 <vprintfmt+0x217>
					putch(ch, putdat);
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	ff 75 0c             	pushl  0xc(%ebp)
  800456:	50                   	push   %eax
  800457:	ff 55 08             	call   *0x8(%ebp)
  80045a:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80045d:	83 eb 01             	sub    $0x1,%ebx
  800460:	83 c7 01             	add    $0x1,%edi
  800463:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800467:	0f be c2             	movsbl %dl,%eax
  80046a:	85 c0                	test   %eax,%eax
  80046c:	74 59                	je     8004c7 <vprintfmt+0x25d>
  80046e:	85 f6                	test   %esi,%esi
  800470:	78 d8                	js     80044a <vprintfmt+0x1e0>
  800472:	83 ee 01             	sub    $0x1,%esi
  800475:	79 d3                	jns    80044a <vprintfmt+0x1e0>
  800477:	89 df                	mov    %ebx,%edi
  800479:	8b 75 08             	mov    0x8(%ebp),%esi
  80047c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80047f:	eb 37                	jmp    8004b8 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800481:	0f be d2             	movsbl %dl,%edx
  800484:	83 ea 20             	sub    $0x20,%edx
  800487:	83 fa 5e             	cmp    $0x5e,%edx
  80048a:	76 c4                	jbe    800450 <vprintfmt+0x1e6>
					putch('?', putdat);
  80048c:	83 ec 08             	sub    $0x8,%esp
  80048f:	ff 75 0c             	pushl  0xc(%ebp)
  800492:	6a 3f                	push   $0x3f
  800494:	ff 55 08             	call   *0x8(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	eb c1                	jmp    80045d <vprintfmt+0x1f3>
  80049c:	89 75 08             	mov    %esi,0x8(%ebp)
  80049f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a8:	eb b6                	jmp    800460 <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	6a 20                	push   $0x20
  8004b0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	85 ff                	test   %edi,%edi
  8004ba:	7f ee                	jg     8004aa <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c2:	e9 78 01 00 00       	jmp    80063f <vprintfmt+0x3d5>
  8004c7:	89 df                	mov    %ebx,%edi
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004cf:	eb e7                	jmp    8004b8 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004d1:	83 f9 01             	cmp    $0x1,%ecx
  8004d4:	7e 3f                	jle    800515 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8b 50 04             	mov    0x4(%eax),%edx
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e7:	8d 40 08             	lea    0x8(%eax),%eax
  8004ea:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004ed:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8004f1:	79 5c                	jns    80054f <vprintfmt+0x2e5>
				putch('-', putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	6a 2d                	push   $0x2d
  8004f9:	ff d6                	call   *%esi
				num = -(long long) num;
  8004fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800501:	f7 da                	neg    %edx
  800503:	83 d1 00             	adc    $0x0,%ecx
  800506:	f7 d9                	neg    %ecx
  800508:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800510:	e9 10 01 00 00       	jmp    800625 <vprintfmt+0x3bb>
	else if (lflag)
  800515:	85 c9                	test   %ecx,%ecx
  800517:	75 1b                	jne    800534 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800521:	89 c1                	mov    %eax,%ecx
  800523:	c1 f9 1f             	sar    $0x1f,%ecx
  800526:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	8d 40 04             	lea    0x4(%eax),%eax
  80052f:	89 45 14             	mov    %eax,0x14(%ebp)
  800532:	eb b9                	jmp    8004ed <vprintfmt+0x283>
		return va_arg(*ap, long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 00                	mov    (%eax),%eax
  800539:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053c:	89 c1                	mov    %eax,%ecx
  80053e:	c1 f9 1f             	sar    $0x1f,%ecx
  800541:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800544:	8b 45 14             	mov    0x14(%ebp),%eax
  800547:	8d 40 04             	lea    0x4(%eax),%eax
  80054a:	89 45 14             	mov    %eax,0x14(%ebp)
  80054d:	eb 9e                	jmp    8004ed <vprintfmt+0x283>
			num = getint(&ap, lflag);
  80054f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800552:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800555:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055a:	e9 c6 00 00 00       	jmp    800625 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80055f:	83 f9 01             	cmp    $0x1,%ecx
  800562:	7e 18                	jle    80057c <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800564:	8b 45 14             	mov    0x14(%ebp),%eax
  800567:	8b 10                	mov    (%eax),%edx
  800569:	8b 48 04             	mov    0x4(%eax),%ecx
  80056c:	8d 40 08             	lea    0x8(%eax),%eax
  80056f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800572:	b8 0a 00 00 00       	mov    $0xa,%eax
  800577:	e9 a9 00 00 00       	jmp    800625 <vprintfmt+0x3bb>
	else if (lflag)
  80057c:	85 c9                	test   %ecx,%ecx
  80057e:	75 1a                	jne    80059a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 10                	mov    (%eax),%edx
  800585:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058a:	8d 40 04             	lea    0x4(%eax),%eax
  80058d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800590:	b8 0a 00 00 00       	mov    $0xa,%eax
  800595:	e9 8b 00 00 00       	jmp    800625 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 10                	mov    (%eax),%edx
  80059f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a4:	8d 40 04             	lea    0x4(%eax),%eax
  8005a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	eb 74                	jmp    800625 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005b1:	83 f9 01             	cmp    $0x1,%ecx
  8005b4:	7e 15                	jle    8005cb <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8b 10                	mov    (%eax),%edx
  8005bb:	8b 48 04             	mov    0x4(%eax),%ecx
  8005be:	8d 40 08             	lea    0x8(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005c4:	b8 08 00 00 00       	mov    $0x8,%eax
  8005c9:	eb 5a                	jmp    800625 <vprintfmt+0x3bb>
	else if (lflag)
  8005cb:	85 c9                	test   %ecx,%ecx
  8005cd:	75 17                	jne    8005e6 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d2:	8b 10                	mov    (%eax),%edx
  8005d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d9:	8d 40 04             	lea    0x4(%eax),%eax
  8005dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005df:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e4:	eb 3f                	jmp    800625 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 10                	mov    (%eax),%edx
  8005eb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f0:	8d 40 04             	lea    0x4(%eax),%eax
  8005f3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005f6:	b8 08 00 00 00       	mov    $0x8,%eax
  8005fb:	eb 28                	jmp    800625 <vprintfmt+0x3bb>
			putch('0', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	6a 30                	push   $0x30
  800603:	ff d6                	call   *%esi
			putch('x', putdat);
  800605:	83 c4 08             	add    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 78                	push   $0x78
  80060b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80060d:	8b 45 14             	mov    0x14(%ebp),%eax
  800610:	8b 10                	mov    (%eax),%edx
  800612:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800617:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80061a:	8d 40 04             	lea    0x4(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800620:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800625:	83 ec 0c             	sub    $0xc,%esp
  800628:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80062c:	57                   	push   %edi
  80062d:	ff 75 e0             	pushl  -0x20(%ebp)
  800630:	50                   	push   %eax
  800631:	51                   	push   %ecx
  800632:	52                   	push   %edx
  800633:	89 da                	mov    %ebx,%edx
  800635:	89 f0                	mov    %esi,%eax
  800637:	e8 45 fb ff ff       	call   800181 <printnum>
			break;
  80063c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80063f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800642:	83 c7 01             	add    $0x1,%edi
  800645:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800649:	83 f8 25             	cmp    $0x25,%eax
  80064c:	0f 84 2f fc ff ff    	je     800281 <vprintfmt+0x17>
			if (ch == '\0')
  800652:	85 c0                	test   %eax,%eax
  800654:	0f 84 8b 00 00 00    	je     8006e5 <vprintfmt+0x47b>
			putch(ch, putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	50                   	push   %eax
  80065f:	ff d6                	call   *%esi
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	eb dc                	jmp    800642 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800666:	83 f9 01             	cmp    $0x1,%ecx
  800669:	7e 15                	jle    800680 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 10                	mov    (%eax),%edx
  800670:	8b 48 04             	mov    0x4(%eax),%ecx
  800673:	8d 40 08             	lea    0x8(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800679:	b8 10 00 00 00       	mov    $0x10,%eax
  80067e:	eb a5                	jmp    800625 <vprintfmt+0x3bb>
	else if (lflag)
  800680:	85 c9                	test   %ecx,%ecx
  800682:	75 17                	jne    80069b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
  800689:	b9 00 00 00 00       	mov    $0x0,%ecx
  80068e:	8d 40 04             	lea    0x4(%eax),%eax
  800691:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800694:	b8 10 00 00 00       	mov    $0x10,%eax
  800699:	eb 8a                	jmp    800625 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80069b:	8b 45 14             	mov    0x14(%ebp),%eax
  80069e:	8b 10                	mov    (%eax),%edx
  8006a0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a5:	8d 40 04             	lea    0x4(%eax),%eax
  8006a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ab:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b0:	e9 70 ff ff ff       	jmp    800625 <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006b5:	83 ec 08             	sub    $0x8,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	6a 25                	push   $0x25
  8006bb:	ff d6                	call   *%esi
			break;
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	e9 7a ff ff ff       	jmp    80063f <vprintfmt+0x3d5>
			putch('%', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	53                   	push   %ebx
  8006c9:	6a 25                	push   $0x25
  8006cb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	89 f8                	mov    %edi,%eax
  8006d2:	eb 03                	jmp    8006d7 <vprintfmt+0x46d>
  8006d4:	83 e8 01             	sub    $0x1,%eax
  8006d7:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006db:	75 f7                	jne    8006d4 <vprintfmt+0x46a>
  8006dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e0:	e9 5a ff ff ff       	jmp    80063f <vprintfmt+0x3d5>
}
  8006e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e8:	5b                   	pop    %ebx
  8006e9:	5e                   	pop    %esi
  8006ea:	5f                   	pop    %edi
  8006eb:	5d                   	pop    %ebp
  8006ec:	c3                   	ret    

008006ed <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ed:	55                   	push   %ebp
  8006ee:	89 e5                	mov    %esp,%ebp
  8006f0:	83 ec 18             	sub    $0x18,%esp
  8006f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006fc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800700:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800703:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 26                	je     800734 <vsnprintf+0x47>
  80070e:	85 d2                	test   %edx,%edx
  800710:	7e 22                	jle    800734 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800712:	ff 75 14             	pushl  0x14(%ebp)
  800715:	ff 75 10             	pushl  0x10(%ebp)
  800718:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80071b:	50                   	push   %eax
  80071c:	68 30 02 80 00       	push   $0x800230
  800721:	e8 44 fb ff ff       	call   80026a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800726:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800729:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80072c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80072f:	83 c4 10             	add    $0x10,%esp
}
  800732:	c9                   	leave  
  800733:	c3                   	ret    
		return -E_INVAL;
  800734:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800739:	eb f7                	jmp    800732 <vsnprintf+0x45>

0080073b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800741:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800744:	50                   	push   %eax
  800745:	ff 75 10             	pushl  0x10(%ebp)
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	ff 75 08             	pushl  0x8(%ebp)
  80074e:	e8 9a ff ff ff       	call   8006ed <vsnprintf>
	va_end(ap);

	return rc;
}
  800753:	c9                   	leave  
  800754:	c3                   	ret    

00800755 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80075b:	b8 00 00 00 00       	mov    $0x0,%eax
  800760:	eb 03                	jmp    800765 <strlen+0x10>
		n++;
  800762:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800765:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800769:	75 f7                	jne    800762 <strlen+0xd>
	return n;
}
  80076b:	5d                   	pop    %ebp
  80076c:	c3                   	ret    

0080076d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800773:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	eb 03                	jmp    800780 <strnlen+0x13>
		n++;
  80077d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800780:	39 d0                	cmp    %edx,%eax
  800782:	74 06                	je     80078a <strnlen+0x1d>
  800784:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800788:	75 f3                	jne    80077d <strnlen+0x10>
	return n;
}
  80078a:	5d                   	pop    %ebp
  80078b:	c3                   	ret    

0080078c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	53                   	push   %ebx
  800790:	8b 45 08             	mov    0x8(%ebp),%eax
  800793:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800796:	89 c2                	mov    %eax,%edx
  800798:	83 c1 01             	add    $0x1,%ecx
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007a2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007a5:	84 db                	test   %bl,%bl
  8007a7:	75 ef                	jne    800798 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007a9:	5b                   	pop    %ebx
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007b3:	53                   	push   %ebx
  8007b4:	e8 9c ff ff ff       	call   800755 <strlen>
  8007b9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007bc:	ff 75 0c             	pushl  0xc(%ebp)
  8007bf:	01 d8                	add    %ebx,%eax
  8007c1:	50                   	push   %eax
  8007c2:	e8 c5 ff ff ff       	call   80078c <strcpy>
	return dst;
}
  8007c7:	89 d8                	mov    %ebx,%eax
  8007c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d9:	89 f3                	mov    %esi,%ebx
  8007db:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007de:	89 f2                	mov    %esi,%edx
  8007e0:	eb 0f                	jmp    8007f1 <strncpy+0x23>
		*dst++ = *src;
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	0f b6 01             	movzbl (%ecx),%eax
  8007e8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007eb:	80 39 01             	cmpb   $0x1,(%ecx)
  8007ee:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  8007f1:	39 da                	cmp    %ebx,%edx
  8007f3:	75 ed                	jne    8007e2 <strncpy+0x14>
	}
	return ret;
}
  8007f5:	89 f0                	mov    %esi,%eax
  8007f7:	5b                   	pop    %ebx
  8007f8:	5e                   	pop    %esi
  8007f9:	5d                   	pop    %ebp
  8007fa:	c3                   	ret    

008007fb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800809:	89 f0                	mov    %esi,%eax
  80080b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080f:	85 c9                	test   %ecx,%ecx
  800811:	75 0b                	jne    80081e <strlcpy+0x23>
  800813:	eb 17                	jmp    80082c <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800815:	83 c2 01             	add    $0x1,%edx
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  80081e:	39 d8                	cmp    %ebx,%eax
  800820:	74 07                	je     800829 <strlcpy+0x2e>
  800822:	0f b6 0a             	movzbl (%edx),%ecx
  800825:	84 c9                	test   %cl,%cl
  800827:	75 ec                	jne    800815 <strlcpy+0x1a>
		*dst = '\0';
  800829:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80082c:	29 f0                	sub    %esi,%eax
}
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    

00800832 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800832:	55                   	push   %ebp
  800833:	89 e5                	mov    %esp,%ebp
  800835:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80083b:	eb 06                	jmp    800843 <strcmp+0x11>
		p++, q++;
  80083d:	83 c1 01             	add    $0x1,%ecx
  800840:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800843:	0f b6 01             	movzbl (%ecx),%eax
  800846:	84 c0                	test   %al,%al
  800848:	74 04                	je     80084e <strcmp+0x1c>
  80084a:	3a 02                	cmp    (%edx),%al
  80084c:	74 ef                	je     80083d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084e:	0f b6 c0             	movzbl %al,%eax
  800851:	0f b6 12             	movzbl (%edx),%edx
  800854:	29 d0                	sub    %edx,%eax
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	8b 45 08             	mov    0x8(%ebp),%eax
  80085f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800862:	89 c3                	mov    %eax,%ebx
  800864:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800867:	eb 06                	jmp    80086f <strncmp+0x17>
		n--, p++, q++;
  800869:	83 c0 01             	add    $0x1,%eax
  80086c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80086f:	39 d8                	cmp    %ebx,%eax
  800871:	74 16                	je     800889 <strncmp+0x31>
  800873:	0f b6 08             	movzbl (%eax),%ecx
  800876:	84 c9                	test   %cl,%cl
  800878:	74 04                	je     80087e <strncmp+0x26>
  80087a:	3a 0a                	cmp    (%edx),%cl
  80087c:	74 eb                	je     800869 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 00             	movzbl (%eax),%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    
		return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
  80088e:	eb f6                	jmp    800886 <strncmp+0x2e>

00800890 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 45 08             	mov    0x8(%ebp),%eax
  800896:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089a:	0f b6 10             	movzbl (%eax),%edx
  80089d:	84 d2                	test   %dl,%dl
  80089f:	74 09                	je     8008aa <strchr+0x1a>
		if (*s == c)
  8008a1:	38 ca                	cmp    %cl,%dl
  8008a3:	74 0a                	je     8008af <strchr+0x1f>
	for (; *s; s++)
  8008a5:	83 c0 01             	add    $0x1,%eax
  8008a8:	eb f0                	jmp    80089a <strchr+0xa>
			return (char *) s;
	return 0;
  8008aa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b1:	55                   	push   %ebp
  8008b2:	89 e5                	mov    %esp,%ebp
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008bb:	eb 03                	jmp    8008c0 <strfind+0xf>
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c3:	38 ca                	cmp    %cl,%dl
  8008c5:	74 04                	je     8008cb <strfind+0x1a>
  8008c7:	84 d2                	test   %dl,%dl
  8008c9:	75 f2                	jne    8008bd <strfind+0xc>
			break;
	return (char *) s;
}
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	57                   	push   %edi
  8008d1:	56                   	push   %esi
  8008d2:	53                   	push   %ebx
  8008d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d9:	85 c9                	test   %ecx,%ecx
  8008db:	74 13                	je     8008f0 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008dd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008e3:	75 05                	jne    8008ea <memset+0x1d>
  8008e5:	f6 c1 03             	test   $0x3,%cl
  8008e8:	74 0d                	je     8008f7 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ed:	fc                   	cld    
  8008ee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008f0:	89 f8                	mov    %edi,%eax
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5f                   	pop    %edi
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    
		c &= 0xFF;
  8008f7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008fb:	89 d3                	mov    %edx,%ebx
  8008fd:	c1 e3 08             	shl    $0x8,%ebx
  800900:	89 d0                	mov    %edx,%eax
  800902:	c1 e0 18             	shl    $0x18,%eax
  800905:	89 d6                	mov    %edx,%esi
  800907:	c1 e6 10             	shl    $0x10,%esi
  80090a:	09 f0                	or     %esi,%eax
  80090c:	09 c2                	or     %eax,%edx
  80090e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800910:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800913:	89 d0                	mov    %edx,%eax
  800915:	fc                   	cld    
  800916:	f3 ab                	rep stos %eax,%es:(%edi)
  800918:	eb d6                	jmp    8008f0 <memset+0x23>

0080091a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	57                   	push   %edi
  80091e:	56                   	push   %esi
  80091f:	8b 45 08             	mov    0x8(%ebp),%eax
  800922:	8b 75 0c             	mov    0xc(%ebp),%esi
  800925:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800928:	39 c6                	cmp    %eax,%esi
  80092a:	73 35                	jae    800961 <memmove+0x47>
  80092c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092f:	39 c2                	cmp    %eax,%edx
  800931:	76 2e                	jbe    800961 <memmove+0x47>
		s += n;
		d += n;
  800933:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800936:	89 d6                	mov    %edx,%esi
  800938:	09 fe                	or     %edi,%esi
  80093a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800940:	74 0c                	je     80094e <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800942:	83 ef 01             	sub    $0x1,%edi
  800945:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800948:	fd                   	std    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094b:	fc                   	cld    
  80094c:	eb 21                	jmp    80096f <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80094e:	f6 c1 03             	test   $0x3,%cl
  800951:	75 ef                	jne    800942 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800953:	83 ef 04             	sub    $0x4,%edi
  800956:	8d 72 fc             	lea    -0x4(%edx),%esi
  800959:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80095c:	fd                   	std    
  80095d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095f:	eb ea                	jmp    80094b <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800961:	89 f2                	mov    %esi,%edx
  800963:	09 c2                	or     %eax,%edx
  800965:	f6 c2 03             	test   $0x3,%dl
  800968:	74 09                	je     800973 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096f:	5e                   	pop    %esi
  800970:	5f                   	pop    %edi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800973:	f6 c1 03             	test   $0x3,%cl
  800976:	75 f2                	jne    80096a <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800978:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80097b:	89 c7                	mov    %eax,%edi
  80097d:	fc                   	cld    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb ed                	jmp    80096f <memmove+0x55>

00800982 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800985:	ff 75 10             	pushl  0x10(%ebp)
  800988:	ff 75 0c             	pushl  0xc(%ebp)
  80098b:	ff 75 08             	pushl  0x8(%ebp)
  80098e:	e8 87 ff ff ff       	call   80091a <memmove>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 c6                	mov    %eax,%esi
  8009a2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a5:	39 f0                	cmp    %esi,%eax
  8009a7:	74 1c                	je     8009c5 <memcmp+0x30>
		if (*s1 != *s2)
  8009a9:	0f b6 08             	movzbl (%eax),%ecx
  8009ac:	0f b6 1a             	movzbl (%edx),%ebx
  8009af:	38 d9                	cmp    %bl,%cl
  8009b1:	75 08                	jne    8009bb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b3:	83 c0 01             	add    $0x1,%eax
  8009b6:	83 c2 01             	add    $0x1,%edx
  8009b9:	eb ea                	jmp    8009a5 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009bb:	0f b6 c1             	movzbl %cl,%eax
  8009be:	0f b6 db             	movzbl %bl,%ebx
  8009c1:	29 d8                	sub    %ebx,%eax
  8009c3:	eb 05                	jmp    8009ca <memcmp+0x35>
	}

	return 0;
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5e                   	pop    %esi
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009d7:	89 c2                	mov    %eax,%edx
  8009d9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009dc:	39 d0                	cmp    %edx,%eax
  8009de:	73 09                	jae    8009e9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e0:	38 08                	cmp    %cl,(%eax)
  8009e2:	74 05                	je     8009e9 <memfind+0x1b>
	for (; s < ends; s++)
  8009e4:	83 c0 01             	add    $0x1,%eax
  8009e7:	eb f3                	jmp    8009dc <memfind+0xe>
			break;
	return (void *) s;
}
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	57                   	push   %edi
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f7:	eb 03                	jmp    8009fc <strtol+0x11>
		s++;
  8009f9:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009fc:	0f b6 01             	movzbl (%ecx),%eax
  8009ff:	3c 20                	cmp    $0x20,%al
  800a01:	74 f6                	je     8009f9 <strtol+0xe>
  800a03:	3c 09                	cmp    $0x9,%al
  800a05:	74 f2                	je     8009f9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a07:	3c 2b                	cmp    $0x2b,%al
  800a09:	74 2e                	je     800a39 <strtol+0x4e>
	int neg = 0;
  800a0b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a10:	3c 2d                	cmp    $0x2d,%al
  800a12:	74 2f                	je     800a43 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a14:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a1a:	75 05                	jne    800a21 <strtol+0x36>
  800a1c:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1f:	74 2c                	je     800a4d <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a21:	85 db                	test   %ebx,%ebx
  800a23:	75 0a                	jne    800a2f <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a25:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a2d:	74 28                	je     800a57 <strtol+0x6c>
		base = 10;
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a34:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a37:	eb 50                	jmp    800a89 <strtol+0x9e>
		s++;
  800a39:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a3c:	bf 00 00 00 00       	mov    $0x0,%edi
  800a41:	eb d1                	jmp    800a14 <strtol+0x29>
		s++, neg = 1;
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	bf 01 00 00 00       	mov    $0x1,%edi
  800a4b:	eb c7                	jmp    800a14 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a4d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a51:	74 0e                	je     800a61 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a53:	85 db                	test   %ebx,%ebx
  800a55:	75 d8                	jne    800a2f <strtol+0x44>
		s++, base = 8;
  800a57:	83 c1 01             	add    $0x1,%ecx
  800a5a:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a5f:	eb ce                	jmp    800a2f <strtol+0x44>
		s += 2, base = 16;
  800a61:	83 c1 02             	add    $0x2,%ecx
  800a64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a69:	eb c4                	jmp    800a2f <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 19             	cmp    $0x19,%bl
  800a73:	77 29                	ja     800a9e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a7b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a7e:	7d 30                	jge    800ab0 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a80:	83 c1 01             	add    $0x1,%ecx
  800a83:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a87:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a89:	0f b6 11             	movzbl (%ecx),%edx
  800a8c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8f:	89 f3                	mov    %esi,%ebx
  800a91:	80 fb 09             	cmp    $0x9,%bl
  800a94:	77 d5                	ja     800a6b <strtol+0x80>
			dig = *s - '0';
  800a96:	0f be d2             	movsbl %dl,%edx
  800a99:	83 ea 30             	sub    $0x30,%edx
  800a9c:	eb dd                	jmp    800a7b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800a9e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa1:	89 f3                	mov    %esi,%ebx
  800aa3:	80 fb 19             	cmp    $0x19,%bl
  800aa6:	77 08                	ja     800ab0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aa8:	0f be d2             	movsbl %dl,%edx
  800aab:	83 ea 37             	sub    $0x37,%edx
  800aae:	eb cb                	jmp    800a7b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab4:	74 05                	je     800abb <strtol+0xd0>
		*endptr = (char *) s;
  800ab6:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab9:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800abb:	89 c2                	mov    %eax,%edx
  800abd:	f7 da                	neg    %edx
  800abf:	85 ff                	test   %edi,%edi
  800ac1:	0f 45 c2             	cmovne %edx,%eax
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
	asm volatile("int %1\n"
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ad7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ada:	89 c3                	mov    %eax,%ebx
  800adc:	89 c7                	mov    %eax,%edi
  800ade:	89 c6                	mov    %eax,%esi
  800ae0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ae2:	5b                   	pop    %ebx
  800ae3:	5e                   	pop    %esi
  800ae4:	5f                   	pop    %edi
  800ae5:	5d                   	pop    %ebp
  800ae6:	c3                   	ret    

00800ae7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	57                   	push   %edi
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
	asm volatile("int %1\n"
  800aed:	ba 00 00 00 00       	mov    $0x0,%edx
  800af2:	b8 01 00 00 00       	mov    $0x1,%eax
  800af7:	89 d1                	mov    %edx,%ecx
  800af9:	89 d3                	mov    %edx,%ebx
  800afb:	89 d7                	mov    %edx,%edi
  800afd:	89 d6                	mov    %edx,%esi
  800aff:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	b8 03 00 00 00       	mov    $0x3,%eax
  800b1c:	89 cb                	mov    %ecx,%ebx
  800b1e:	89 cf                	mov    %ecx,%edi
  800b20:	89 ce                	mov    %ecx,%esi
  800b22:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b24:	85 c0                	test   %eax,%eax
  800b26:	7f 08                	jg     800b30 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b30:	83 ec 0c             	sub    $0xc,%esp
  800b33:	50                   	push   %eax
  800b34:	6a 03                	push   $0x3
  800b36:	68 c4 12 80 00       	push   $0x8012c4
  800b3b:	6a 23                	push   $0x23
  800b3d:	68 e1 12 80 00       	push   $0x8012e1
  800b42:	e8 82 02 00 00       	call   800dc9 <_panic>

00800b47 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 02 00 00 00       	mov    $0x2,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_yield>:

void
sys_yield(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b76:	89 d1                	mov    %edx,%ecx
  800b78:	89 d3                	mov    %edx,%ebx
  800b7a:	89 d7                	mov    %edx,%edi
  800b7c:	89 d6                	mov    %edx,%esi
  800b7e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	53                   	push   %ebx
  800b8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8e:	be 00 00 00 00       	mov    $0x0,%esi
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b99:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba1:	89 f7                	mov    %esi,%edi
  800ba3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ba5:	85 c0                	test   %eax,%eax
  800ba7:	7f 08                	jg     800bb1 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	50                   	push   %eax
  800bb5:	6a 04                	push   $0x4
  800bb7:	68 c4 12 80 00       	push   $0x8012c4
  800bbc:	6a 23                	push   $0x23
  800bbe:	68 e1 12 80 00       	push   $0x8012e1
  800bc3:	e8 01 02 00 00       	call   800dc9 <_panic>

00800bc8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	57                   	push   %edi
  800bcc:	56                   	push   %esi
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd7:	b8 05 00 00 00       	mov    $0x5,%eax
  800bdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bdf:	8b 7d 14             	mov    0x14(%ebp),%edi
  800be2:	8b 75 18             	mov    0x18(%ebp),%esi
  800be5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800be7:	85 c0                	test   %eax,%eax
  800be9:	7f 08                	jg     800bf3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bee:	5b                   	pop    %ebx
  800bef:	5e                   	pop    %esi
  800bf0:	5f                   	pop    %edi
  800bf1:	5d                   	pop    %ebp
  800bf2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	50                   	push   %eax
  800bf7:	6a 05                	push   $0x5
  800bf9:	68 c4 12 80 00       	push   $0x8012c4
  800bfe:	6a 23                	push   $0x23
  800c00:	68 e1 12 80 00       	push   $0x8012e1
  800c05:	e8 bf 01 00 00       	call   800dc9 <_panic>

00800c0a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	57                   	push   %edi
  800c0e:	56                   	push   %esi
  800c0f:	53                   	push   %ebx
  800c10:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c1e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c23:	89 df                	mov    %ebx,%edi
  800c25:	89 de                	mov    %ebx,%esi
  800c27:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c29:	85 c0                	test   %eax,%eax
  800c2b:	7f 08                	jg     800c35 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c35:	83 ec 0c             	sub    $0xc,%esp
  800c38:	50                   	push   %eax
  800c39:	6a 06                	push   $0x6
  800c3b:	68 c4 12 80 00       	push   $0x8012c4
  800c40:	6a 23                	push   $0x23
  800c42:	68 e1 12 80 00       	push   $0x8012e1
  800c47:	e8 7d 01 00 00       	call   800dc9 <_panic>

00800c4c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	b8 08 00 00 00       	mov    $0x8,%eax
  800c65:	89 df                	mov    %ebx,%edi
  800c67:	89 de                	mov    %ebx,%esi
  800c69:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6b:	85 c0                	test   %eax,%eax
  800c6d:	7f 08                	jg     800c77 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c72:	5b                   	pop    %ebx
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c77:	83 ec 0c             	sub    $0xc,%esp
  800c7a:	50                   	push   %eax
  800c7b:	6a 08                	push   $0x8
  800c7d:	68 c4 12 80 00       	push   $0x8012c4
  800c82:	6a 23                	push   $0x23
  800c84:	68 e1 12 80 00       	push   $0x8012e1
  800c89:	e8 3b 01 00 00       	call   800dc9 <_panic>

00800c8e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
  800c94:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c97:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca2:	b8 09 00 00 00       	mov    $0x9,%eax
  800ca7:	89 df                	mov    %ebx,%edi
  800ca9:	89 de                	mov    %ebx,%esi
  800cab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cad:	85 c0                	test   %eax,%eax
  800caf:	7f 08                	jg     800cb9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 09                	push   $0x9
  800cbf:	68 c4 12 80 00       	push   $0x8012c4
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 e1 12 80 00       	push   $0x8012e1
  800ccb:	e8 f9 00 00 00       	call   800dc9 <_panic>

00800cd0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	57                   	push   %edi
  800cd4:	56                   	push   %esi
  800cd5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce1:	be 00 00 00 00       	mov    $0x0,%esi
  800ce6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ce9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cec:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    

00800cf3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	57                   	push   %edi
  800cf7:	56                   	push   %esi
  800cf8:	53                   	push   %ebx
  800cf9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cfc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d01:	8b 55 08             	mov    0x8(%ebp),%edx
  800d04:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d09:	89 cb                	mov    %ecx,%ebx
  800d0b:	89 cf                	mov    %ecx,%edi
  800d0d:	89 ce                	mov    %ecx,%esi
  800d0f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	7f 08                	jg     800d1d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 0c                	push   $0xc
  800d23:	68 c4 12 80 00       	push   $0x8012c4
  800d28:	6a 23                	push   $0x23
  800d2a:	68 e1 12 80 00       	push   $0x8012e1
  800d2f:	e8 95 00 00 00       	call   800dc9 <_panic>

00800d34 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
  800d37:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d3a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d41:	74 20                	je     800d63 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d43:	8b 45 08             	mov    0x8(%ebp),%eax
  800d46:	a3 08 20 80 00       	mov    %eax,0x802008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d4b:	83 ec 08             	sub    $0x8,%esp
  800d4e:	68 a3 0d 80 00       	push   $0x800da3
  800d53:	6a 00                	push   $0x0
  800d55:	e8 34 ff ff ff       	call   800c8e <sys_env_set_pgfault_upcall>
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	78 2e                	js     800d8f <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  800d61:	c9                   	leave  
  800d62:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800d63:	83 ec 04             	sub    $0x4,%esp
  800d66:	6a 07                	push   $0x7
  800d68:	68 00 f0 bf ee       	push   $0xeebff000
  800d6d:	6a 00                	push   $0x0
  800d6f:	e8 11 fe ff ff       	call   800b85 <sys_page_alloc>
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	79 c8                	jns    800d43 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	68 f0 12 80 00       	push   $0x8012f0
  800d83:	6a 21                	push   $0x21
  800d85:	68 52 13 80 00       	push   $0x801352
  800d8a:	e8 3a 00 00 00       	call   800dc9 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800d8f:	83 ec 04             	sub    $0x4,%esp
  800d92:	68 1c 13 80 00       	push   $0x80131c
  800d97:	6a 27                	push   $0x27
  800d99:	68 52 13 80 00       	push   $0x801352
  800d9e:	e8 26 00 00 00       	call   800dc9 <_panic>

00800da3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800da3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800da4:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800da9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dab:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800dae:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800db2:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800db5:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  800db9:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800dbd:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800dbf:	83 c4 08             	add    $0x8,%esp
	popal
  800dc2:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800dc3:	83 c4 04             	add    $0x4,%esp
	popfl
  800dc6:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800dc7:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dc8:	c3                   	ret    

00800dc9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dce:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dd1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dd7:	e8 6b fd ff ff       	call   800b47 <sys_getenvid>
  800ddc:	83 ec 0c             	sub    $0xc,%esp
  800ddf:	ff 75 0c             	pushl  0xc(%ebp)
  800de2:	ff 75 08             	pushl  0x8(%ebp)
  800de5:	56                   	push   %esi
  800de6:	50                   	push   %eax
  800de7:	68 60 13 80 00       	push   $0x801360
  800dec:	e8 7c f3 ff ff       	call   80016d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800df1:	83 c4 18             	add    $0x18,%esp
  800df4:	53                   	push   %ebx
  800df5:	ff 75 10             	pushl  0x10(%ebp)
  800df8:	e8 1f f3 ff ff       	call   80011c <vcprintf>
	cprintf("\n");
  800dfd:	c7 04 24 7a 10 80 00 	movl   $0x80107a,(%esp)
  800e04:	e8 64 f3 ff ff       	call   80016d <cprintf>
  800e09:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800e0c:	cc                   	int3   
  800e0d:	eb fd                	jmp    800e0c <_panic+0x43>
  800e0f:	90                   	nop

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e1b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e1f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e23:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e27:	85 d2                	test   %edx,%edx
  800e29:	75 35                	jne    800e60 <__udivdi3+0x50>
  800e2b:	39 f3                	cmp    %esi,%ebx
  800e2d:	0f 87 bd 00 00 00    	ja     800ef0 <__udivdi3+0xe0>
  800e33:	85 db                	test   %ebx,%ebx
  800e35:	89 d9                	mov    %ebx,%ecx
  800e37:	75 0b                	jne    800e44 <__udivdi3+0x34>
  800e39:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3e:	31 d2                	xor    %edx,%edx
  800e40:	f7 f3                	div    %ebx
  800e42:	89 c1                	mov    %eax,%ecx
  800e44:	31 d2                	xor    %edx,%edx
  800e46:	89 f0                	mov    %esi,%eax
  800e48:	f7 f1                	div    %ecx
  800e4a:	89 c6                	mov    %eax,%esi
  800e4c:	89 e8                	mov    %ebp,%eax
  800e4e:	89 f7                	mov    %esi,%edi
  800e50:	f7 f1                	div    %ecx
  800e52:	89 fa                	mov    %edi,%edx
  800e54:	83 c4 1c             	add    $0x1c,%esp
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    
  800e5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e60:	39 f2                	cmp    %esi,%edx
  800e62:	77 7c                	ja     800ee0 <__udivdi3+0xd0>
  800e64:	0f bd fa             	bsr    %edx,%edi
  800e67:	83 f7 1f             	xor    $0x1f,%edi
  800e6a:	0f 84 98 00 00 00    	je     800f08 <__udivdi3+0xf8>
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	d3 e6                	shl    %cl,%esi
  800ea1:	89 eb                	mov    %ebp,%ebx
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 0c                	jb     800ec7 <__udivdi3+0xb7>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 5d                	jae    800f20 <__udivdi3+0x110>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	75 59                	jne    800f20 <__udivdi3+0x110>
  800ec7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eca:	31 ff                	xor    %edi,%edi
  800ecc:	89 fa                	mov    %edi,%edx
  800ece:	83 c4 1c             	add    $0x1c,%esp
  800ed1:	5b                   	pop    %ebx
  800ed2:	5e                   	pop    %esi
  800ed3:	5f                   	pop    %edi
  800ed4:	5d                   	pop    %ebp
  800ed5:	c3                   	ret    
  800ed6:	8d 76 00             	lea    0x0(%esi),%esi
  800ed9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ee0:	31 ff                	xor    %edi,%edi
  800ee2:	31 c0                	xor    %eax,%eax
  800ee4:	89 fa                	mov    %edi,%edx
  800ee6:	83 c4 1c             	add    $0x1c,%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    
  800eee:	66 90                	xchg   %ax,%ax
  800ef0:	31 ff                	xor    %edi,%edi
  800ef2:	89 e8                	mov    %ebp,%eax
  800ef4:	89 f2                	mov    %esi,%edx
  800ef6:	f7 f3                	div    %ebx
  800ef8:	89 fa                	mov    %edi,%edx
  800efa:	83 c4 1c             	add    $0x1c,%esp
  800efd:	5b                   	pop    %ebx
  800efe:	5e                   	pop    %esi
  800eff:	5f                   	pop    %edi
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    
  800f02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f08:	39 f2                	cmp    %esi,%edx
  800f0a:	72 06                	jb     800f12 <__udivdi3+0x102>
  800f0c:	31 c0                	xor    %eax,%eax
  800f0e:	39 eb                	cmp    %ebp,%ebx
  800f10:	77 d2                	ja     800ee4 <__udivdi3+0xd4>
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
  800f17:	eb cb                	jmp    800ee4 <__udivdi3+0xd4>
  800f19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f20:	89 d8                	mov    %ebx,%eax
  800f22:	31 ff                	xor    %edi,%edi
  800f24:	eb be                	jmp    800ee4 <__udivdi3+0xd4>
  800f26:	66 90                	xchg   %ax,%ax
  800f28:	66 90                	xchg   %ax,%ax
  800f2a:	66 90                	xchg   %ax,%ax
  800f2c:	66 90                	xchg   %ax,%ax
  800f2e:	66 90                	xchg   %ax,%ax

00800f30 <__umoddi3>:
  800f30:	55                   	push   %ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 1c             	sub    $0x1c,%esp
  800f37:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f47:	85 ed                	test   %ebp,%ebp
  800f49:	89 f0                	mov    %esi,%eax
  800f4b:	89 da                	mov    %ebx,%edx
  800f4d:	75 19                	jne    800f68 <__umoddi3+0x38>
  800f4f:	39 df                	cmp    %ebx,%edi
  800f51:	0f 86 b1 00 00 00    	jbe    801008 <__umoddi3+0xd8>
  800f57:	f7 f7                	div    %edi
  800f59:	89 d0                	mov    %edx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	83 c4 1c             	add    $0x1c,%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    
  800f65:	8d 76 00             	lea    0x0(%esi),%esi
  800f68:	39 dd                	cmp    %ebx,%ebp
  800f6a:	77 f1                	ja     800f5d <__umoddi3+0x2d>
  800f6c:	0f bd cd             	bsr    %ebp,%ecx
  800f6f:	83 f1 1f             	xor    $0x1f,%ecx
  800f72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f76:	0f 84 b4 00 00 00    	je     801030 <__umoddi3+0x100>
  800f7c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f81:	89 c2                	mov    %eax,%edx
  800f83:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f87:	29 c2                	sub    %eax,%edx
  800f89:	89 c1                	mov    %eax,%ecx
  800f8b:	89 f8                	mov    %edi,%eax
  800f8d:	d3 e5                	shl    %cl,%ebp
  800f8f:	89 d1                	mov    %edx,%ecx
  800f91:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f95:	d3 e8                	shr    %cl,%eax
  800f97:	09 c5                	or     %eax,%ebp
  800f99:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f9d:	89 c1                	mov    %eax,%ecx
  800f9f:	d3 e7                	shl    %cl,%edi
  800fa1:	89 d1                	mov    %edx,%ecx
  800fa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fa7:	89 df                	mov    %ebx,%edi
  800fa9:	d3 ef                	shr    %cl,%edi
  800fab:	89 c1                	mov    %eax,%ecx
  800fad:	89 f0                	mov    %esi,%eax
  800faf:	d3 e3                	shl    %cl,%ebx
  800fb1:	89 d1                	mov    %edx,%ecx
  800fb3:	89 fa                	mov    %edi,%edx
  800fb5:	d3 e8                	shr    %cl,%eax
  800fb7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fbc:	09 d8                	or     %ebx,%eax
  800fbe:	f7 f5                	div    %ebp
  800fc0:	d3 e6                	shl    %cl,%esi
  800fc2:	89 d1                	mov    %edx,%ecx
  800fc4:	f7 64 24 08          	mull   0x8(%esp)
  800fc8:	39 d1                	cmp    %edx,%ecx
  800fca:	89 c3                	mov    %eax,%ebx
  800fcc:	89 d7                	mov    %edx,%edi
  800fce:	72 06                	jb     800fd6 <__umoddi3+0xa6>
  800fd0:	75 0e                	jne    800fe0 <__umoddi3+0xb0>
  800fd2:	39 c6                	cmp    %eax,%esi
  800fd4:	73 0a                	jae    800fe0 <__umoddi3+0xb0>
  800fd6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fda:	19 ea                	sbb    %ebp,%edx
  800fdc:	89 d7                	mov    %edx,%edi
  800fde:	89 c3                	mov    %eax,%ebx
  800fe0:	89 ca                	mov    %ecx,%edx
  800fe2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fe7:	29 de                	sub    %ebx,%esi
  800fe9:	19 fa                	sbb    %edi,%edx
  800feb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fef:	89 d0                	mov    %edx,%eax
  800ff1:	d3 e0                	shl    %cl,%eax
  800ff3:	89 d9                	mov    %ebx,%ecx
  800ff5:	d3 ee                	shr    %cl,%esi
  800ff7:	d3 ea                	shr    %cl,%edx
  800ff9:	09 f0                	or     %esi,%eax
  800ffb:	83 c4 1c             	add    $0x1c,%esp
  800ffe:	5b                   	pop    %ebx
  800fff:	5e                   	pop    %esi
  801000:	5f                   	pop    %edi
  801001:	5d                   	pop    %ebp
  801002:	c3                   	ret    
  801003:	90                   	nop
  801004:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801008:	85 ff                	test   %edi,%edi
  80100a:	89 f9                	mov    %edi,%ecx
  80100c:	75 0b                	jne    801019 <__umoddi3+0xe9>
  80100e:	b8 01 00 00 00       	mov    $0x1,%eax
  801013:	31 d2                	xor    %edx,%edx
  801015:	f7 f7                	div    %edi
  801017:	89 c1                	mov    %eax,%ecx
  801019:	89 d8                	mov    %ebx,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	f7 f1                	div    %ecx
  80101f:	89 f0                	mov    %esi,%eax
  801021:	f7 f1                	div    %ecx
  801023:	e9 31 ff ff ff       	jmp    800f59 <__umoddi3+0x29>
  801028:	90                   	nop
  801029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801030:	39 dd                	cmp    %ebx,%ebp
  801032:	72 08                	jb     80103c <__umoddi3+0x10c>
  801034:	39 f7                	cmp    %esi,%edi
  801036:	0f 87 21 ff ff ff    	ja     800f5d <__umoddi3+0x2d>
  80103c:	89 da                	mov    %ebx,%edx
  80103e:	89 f0                	mov    %esi,%eax
  801040:	29 f8                	sub    %edi,%eax
  801042:	19 ea                	sbb    %ebp,%edx
  801044:	e9 14 ff ff ff       	jmp    800f5d <__umoddi3+0x2d>
