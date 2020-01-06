
obj/user/yield：     文件格式 elf32-i386


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
  80002c:	e8 69 00 00 00       	call   80009a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	50                   	push   %eax
  800043:	68 e0 0f 80 00       	push   $0x800fe0
  800048:	e8 3a 01 00 00       	call   800187 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800050:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800055:	e8 26 0b 00 00       	call   800b80 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005a:	a1 04 20 80 00       	mov    0x802004,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  80005f:	8b 40 48             	mov    0x48(%eax),%eax
  800062:	83 ec 04             	sub    $0x4,%esp
  800065:	53                   	push   %ebx
  800066:	50                   	push   %eax
  800067:	68 00 10 80 00       	push   $0x801000
  80006c:	e8 16 01 00 00       	call   800187 <cprintf>
	for (i = 0; i < 5; i++) {
  800071:	83 c3 01             	add    $0x1,%ebx
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	83 fb 05             	cmp    $0x5,%ebx
  80007a:	75 d9                	jne    800055 <umain+0x22>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  80007c:	a1 04 20 80 00       	mov    0x802004,%eax
  800081:	8b 40 48             	mov    0x48(%eax),%eax
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	50                   	push   %eax
  800088:	68 2c 10 80 00       	push   $0x80102c
  80008d:	e8 f5 00 00 00       	call   800187 <cprintf>
}
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000a5:	e8 b7 0a 00 00       	call   800b61 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000aa:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000af:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b7:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bc:	85 db                	test   %ebx,%ebx
  8000be:	7e 07                	jle    8000c7 <libmain+0x2d>
		binaryname = argv[0];
  8000c0:	8b 06                	mov    (%esi),%eax
  8000c2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000c7:	83 ec 08             	sub    $0x8,%esp
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
  8000cc:	e8 62 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000d1:	e8 0a 00 00 00       	call   8000e0 <exit>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000e6:	6a 00                	push   $0x0
  8000e8:	e8 33 0a 00 00       	call   800b20 <sys_env_destroy>
}
  8000ed:	83 c4 10             	add    $0x10,%esp
  8000f0:	c9                   	leave  
  8000f1:	c3                   	ret    

008000f2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f2:	55                   	push   %ebp
  8000f3:	89 e5                	mov    %esp,%ebp
  8000f5:	53                   	push   %ebx
  8000f6:	83 ec 04             	sub    $0x4,%esp
  8000f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000fc:	8b 13                	mov    (%ebx),%edx
  8000fe:	8d 42 01             	lea    0x1(%edx),%eax
  800101:	89 03                	mov    %eax,(%ebx)
  800103:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800106:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80010f:	74 09                	je     80011a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	68 ff 00 00 00       	push   $0xff
  800122:	8d 43 08             	lea    0x8(%ebx),%eax
  800125:	50                   	push   %eax
  800126:	e8 b8 09 00 00       	call   800ae3 <sys_cputs>
		b->idx = 0;
  80012b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800131:	83 c4 10             	add    $0x10,%esp
  800134:	eb db                	jmp    800111 <putch+0x1f>

00800136 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80013f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800146:	00 00 00 
	b.cnt = 0;
  800149:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800150:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800153:	ff 75 0c             	pushl  0xc(%ebp)
  800156:	ff 75 08             	pushl  0x8(%ebp)
  800159:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015f:	50                   	push   %eax
  800160:	68 f2 00 80 00       	push   $0x8000f2
  800165:	e8 1a 01 00 00       	call   800284 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016a:	83 c4 08             	add    $0x8,%esp
  80016d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800173:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	e8 64 09 00 00       	call   800ae3 <sys_cputs>

	return b.cnt;
}
  80017f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80018d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800190:	50                   	push   %eax
  800191:	ff 75 08             	pushl  0x8(%ebp)
  800194:	e8 9d ff ff ff       	call   800136 <vcprintf>
	va_end(ap);

	return cnt;
}
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	57                   	push   %edi
  80019f:	56                   	push   %esi
  8001a0:	53                   	push   %ebx
  8001a1:	83 ec 1c             	sub    $0x1c,%esp
  8001a4:	89 c7                	mov    %eax,%edi
  8001a6:	89 d6                	mov    %edx,%esi
  8001a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b1:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001bc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001bf:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001c2:	39 d3                	cmp    %edx,%ebx
  8001c4:	72 05                	jb     8001cb <printnum+0x30>
  8001c6:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001c9:	77 7a                	ja     800245 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001cb:	83 ec 0c             	sub    $0xc,%esp
  8001ce:	ff 75 18             	pushl  0x18(%ebp)
  8001d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8001d4:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001d7:	53                   	push   %ebx
  8001d8:	ff 75 10             	pushl  0x10(%ebp)
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e4:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e7:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ea:	e8 b1 0b 00 00       	call   800da0 <__udivdi3>
  8001ef:	83 c4 18             	add    $0x18,%esp
  8001f2:	52                   	push   %edx
  8001f3:	50                   	push   %eax
  8001f4:	89 f2                	mov    %esi,%edx
  8001f6:	89 f8                	mov    %edi,%eax
  8001f8:	e8 9e ff ff ff       	call   80019b <printnum>
  8001fd:	83 c4 20             	add    $0x20,%esp
  800200:	eb 13                	jmp    800215 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800202:	83 ec 08             	sub    $0x8,%esp
  800205:	56                   	push   %esi
  800206:	ff 75 18             	pushl  0x18(%ebp)
  800209:	ff d7                	call   *%edi
  80020b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80020e:	83 eb 01             	sub    $0x1,%ebx
  800211:	85 db                	test   %ebx,%ebx
  800213:	7f ed                	jg     800202 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800215:	83 ec 08             	sub    $0x8,%esp
  800218:	56                   	push   %esi
  800219:	83 ec 04             	sub    $0x4,%esp
  80021c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80021f:	ff 75 e0             	pushl  -0x20(%ebp)
  800222:	ff 75 dc             	pushl  -0x24(%ebp)
  800225:	ff 75 d8             	pushl  -0x28(%ebp)
  800228:	e8 93 0c 00 00       	call   800ec0 <__umoddi3>
  80022d:	83 c4 14             	add    $0x14,%esp
  800230:	0f be 80 55 10 80 00 	movsbl 0x801055(%eax),%eax
  800237:	50                   	push   %eax
  800238:	ff d7                	call   *%edi
}
  80023a:	83 c4 10             	add    $0x10,%esp
  80023d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800240:	5b                   	pop    %ebx
  800241:	5e                   	pop    %esi
  800242:	5f                   	pop    %edi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    
  800245:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800248:	eb c4                	jmp    80020e <printnum+0x73>

0080024a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800250:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800254:	8b 10                	mov    (%eax),%edx
  800256:	3b 50 04             	cmp    0x4(%eax),%edx
  800259:	73 0a                	jae    800265 <sprintputch+0x1b>
		*b->buf++ = ch;
  80025b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80025e:	89 08                	mov    %ecx,(%eax)
  800260:	8b 45 08             	mov    0x8(%ebp),%eax
  800263:	88 02                	mov    %al,(%edx)
}
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <printfmt>:
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80026d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800270:	50                   	push   %eax
  800271:	ff 75 10             	pushl  0x10(%ebp)
  800274:	ff 75 0c             	pushl  0xc(%ebp)
  800277:	ff 75 08             	pushl  0x8(%ebp)
  80027a:	e8 05 00 00 00       	call   800284 <vprintfmt>
}
  80027f:	83 c4 10             	add    $0x10,%esp
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <vprintfmt>:
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	57                   	push   %edi
  800288:	56                   	push   %esi
  800289:	53                   	push   %ebx
  80028a:	83 ec 2c             	sub    $0x2c,%esp
  80028d:	8b 75 08             	mov    0x8(%ebp),%esi
  800290:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800293:	8b 7d 10             	mov    0x10(%ebp),%edi
  800296:	e9 c1 03 00 00       	jmp    80065c <vprintfmt+0x3d8>
		padc = ' ';
  80029b:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80029f:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8002a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8002ad:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002b4:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002b9:	8d 47 01             	lea    0x1(%edi),%eax
  8002bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bf:	0f b6 17             	movzbl (%edi),%edx
  8002c2:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002c5:	3c 55                	cmp    $0x55,%al
  8002c7:	0f 87 12 04 00 00    	ja     8006df <vprintfmt+0x45b>
  8002cd:	0f b6 c0             	movzbl %al,%eax
  8002d0:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002da:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  8002de:	eb d9                	jmp    8002b9 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  8002e3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002e7:	eb d0                	jmp    8002b9 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  8002e9:	0f b6 d2             	movzbl %dl,%edx
  8002ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002f7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002fa:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002fe:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800301:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800304:	83 f9 09             	cmp    $0x9,%ecx
  800307:	77 55                	ja     80035e <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800309:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80030c:	eb e9                	jmp    8002f7 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80030e:	8b 45 14             	mov    0x14(%ebp),%eax
  800311:	8b 00                	mov    (%eax),%eax
  800313:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800316:	8b 45 14             	mov    0x14(%ebp),%eax
  800319:	8d 40 04             	lea    0x4(%eax),%eax
  80031c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800322:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800326:	79 91                	jns    8002b9 <vprintfmt+0x35>
				width = precision, precision = -1;
  800328:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80032b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80032e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800335:	eb 82                	jmp    8002b9 <vprintfmt+0x35>
  800337:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80033a:	85 c0                	test   %eax,%eax
  80033c:	ba 00 00 00 00       	mov    $0x0,%edx
  800341:	0f 49 d0             	cmovns %eax,%edx
  800344:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800347:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034a:	e9 6a ff ff ff       	jmp    8002b9 <vprintfmt+0x35>
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800352:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800359:	e9 5b ff ff ff       	jmp    8002b9 <vprintfmt+0x35>
  80035e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800361:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800364:	eb bc                	jmp    800322 <vprintfmt+0x9e>
			lflag++;
  800366:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80036c:	e9 48 ff ff ff       	jmp    8002b9 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800371:	8b 45 14             	mov    0x14(%ebp),%eax
  800374:	8d 78 04             	lea    0x4(%eax),%edi
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	53                   	push   %ebx
  80037b:	ff 30                	pushl  (%eax)
  80037d:	ff d6                	call   *%esi
			break;
  80037f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800382:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800385:	e9 cf 02 00 00       	jmp    800659 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80038a:	8b 45 14             	mov    0x14(%ebp),%eax
  80038d:	8d 78 04             	lea    0x4(%eax),%edi
  800390:	8b 00                	mov    (%eax),%eax
  800392:	99                   	cltd   
  800393:	31 d0                	xor    %edx,%eax
  800395:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800397:	83 f8 08             	cmp    $0x8,%eax
  80039a:	7f 23                	jg     8003bf <vprintfmt+0x13b>
  80039c:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  8003a3:	85 d2                	test   %edx,%edx
  8003a5:	74 18                	je     8003bf <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8003a7:	52                   	push   %edx
  8003a8:	68 76 10 80 00       	push   $0x801076
  8003ad:	53                   	push   %ebx
  8003ae:	56                   	push   %esi
  8003af:	e8 b3 fe ff ff       	call   800267 <printfmt>
  8003b4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003ba:	e9 9a 02 00 00       	jmp    800659 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  8003bf:	50                   	push   %eax
  8003c0:	68 6d 10 80 00       	push   $0x80106d
  8003c5:	53                   	push   %ebx
  8003c6:	56                   	push   %esi
  8003c7:	e8 9b fe ff ff       	call   800267 <printfmt>
  8003cc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003cf:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003d2:	e9 82 02 00 00       	jmp    800659 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  8003d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003da:	83 c0 04             	add    $0x4,%eax
  8003dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003e5:	85 ff                	test   %edi,%edi
  8003e7:	b8 66 10 80 00       	mov    $0x801066,%eax
  8003ec:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f3:	0f 8e bd 00 00 00    	jle    8004b6 <vprintfmt+0x232>
  8003f9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003fd:	75 0e                	jne    80040d <vprintfmt+0x189>
  8003ff:	89 75 08             	mov    %esi,0x8(%ebp)
  800402:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800405:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800408:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80040b:	eb 6d                	jmp    80047a <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	ff 75 d0             	pushl  -0x30(%ebp)
  800413:	57                   	push   %edi
  800414:	e8 6e 03 00 00       	call   800787 <strnlen>
  800419:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041c:	29 c1                	sub    %eax,%ecx
  80041e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800421:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800424:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80042e:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800430:	eb 0f                	jmp    800441 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800432:	83 ec 08             	sub    $0x8,%esp
  800435:	53                   	push   %ebx
  800436:	ff 75 e0             	pushl  -0x20(%ebp)
  800439:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80043b:	83 ef 01             	sub    $0x1,%edi
  80043e:	83 c4 10             	add    $0x10,%esp
  800441:	85 ff                	test   %edi,%edi
  800443:	7f ed                	jg     800432 <vprintfmt+0x1ae>
  800445:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800448:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80044b:	85 c9                	test   %ecx,%ecx
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	0f 49 c1             	cmovns %ecx,%eax
  800455:	29 c1                	sub    %eax,%ecx
  800457:	89 75 08             	mov    %esi,0x8(%ebp)
  80045a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80045d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800460:	89 cb                	mov    %ecx,%ebx
  800462:	eb 16                	jmp    80047a <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  800464:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800468:	75 31                	jne    80049b <vprintfmt+0x217>
					putch(ch, putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	ff 75 0c             	pushl  0xc(%ebp)
  800470:	50                   	push   %eax
  800471:	ff 55 08             	call   *0x8(%ebp)
  800474:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800481:	0f be c2             	movsbl %dl,%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	74 59                	je     8004e1 <vprintfmt+0x25d>
  800488:	85 f6                	test   %esi,%esi
  80048a:	78 d8                	js     800464 <vprintfmt+0x1e0>
  80048c:	83 ee 01             	sub    $0x1,%esi
  80048f:	79 d3                	jns    800464 <vprintfmt+0x1e0>
  800491:	89 df                	mov    %ebx,%edi
  800493:	8b 75 08             	mov    0x8(%ebp),%esi
  800496:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800499:	eb 37                	jmp    8004d2 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80049b:	0f be d2             	movsbl %dl,%edx
  80049e:	83 ea 20             	sub    $0x20,%edx
  8004a1:	83 fa 5e             	cmp    $0x5e,%edx
  8004a4:	76 c4                	jbe    80046a <vprintfmt+0x1e6>
					putch('?', putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	ff 75 0c             	pushl  0xc(%ebp)
  8004ac:	6a 3f                	push   $0x3f
  8004ae:	ff 55 08             	call   *0x8(%ebp)
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	eb c1                	jmp    800477 <vprintfmt+0x1f3>
  8004b6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004bc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004bf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004c2:	eb b6                	jmp    80047a <vprintfmt+0x1f6>
				putch(' ', putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	53                   	push   %ebx
  8004c8:	6a 20                	push   $0x20
  8004ca:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004cc:	83 ef 01             	sub    $0x1,%edi
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f ee                	jg     8004c4 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8004dc:	e9 78 01 00 00       	jmp    800659 <vprintfmt+0x3d5>
  8004e1:	89 df                	mov    %ebx,%edi
  8004e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e9:	eb e7                	jmp    8004d2 <vprintfmt+0x24e>
	if (lflag >= 2)
  8004eb:	83 f9 01             	cmp    $0x1,%ecx
  8004ee:	7e 3f                	jle    80052f <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  8004f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f3:	8b 50 04             	mov    0x4(%eax),%edx
  8004f6:	8b 00                	mov    (%eax),%eax
  8004f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800501:	8d 40 08             	lea    0x8(%eax),%eax
  800504:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800507:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80050b:	79 5c                	jns    800569 <vprintfmt+0x2e5>
				putch('-', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	53                   	push   %ebx
  800511:	6a 2d                	push   $0x2d
  800513:	ff d6                	call   *%esi
				num = -(long long) num;
  800515:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800518:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80051b:	f7 da                	neg    %edx
  80051d:	83 d1 00             	adc    $0x0,%ecx
  800520:	f7 d9                	neg    %ecx
  800522:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800525:	b8 0a 00 00 00       	mov    $0xa,%eax
  80052a:	e9 10 01 00 00       	jmp    80063f <vprintfmt+0x3bb>
	else if (lflag)
  80052f:	85 c9                	test   %ecx,%ecx
  800531:	75 1b                	jne    80054e <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8b 00                	mov    (%eax),%eax
  800538:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053b:	89 c1                	mov    %eax,%ecx
  80053d:	c1 f9 1f             	sar    $0x1f,%ecx
  800540:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 40 04             	lea    0x4(%eax),%eax
  800549:	89 45 14             	mov    %eax,0x14(%ebp)
  80054c:	eb b9                	jmp    800507 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 00                	mov    (%eax),%eax
  800553:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800556:	89 c1                	mov    %eax,%ecx
  800558:	c1 f9 1f             	sar    $0x1f,%ecx
  80055b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8d 40 04             	lea    0x4(%eax),%eax
  800564:	89 45 14             	mov    %eax,0x14(%ebp)
  800567:	eb 9e                	jmp    800507 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800569:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80056f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800574:	e9 c6 00 00 00       	jmp    80063f <vprintfmt+0x3bb>
	if (lflag >= 2)
  800579:	83 f9 01             	cmp    $0x1,%ecx
  80057c:	7e 18                	jle    800596 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8b 10                	mov    (%eax),%edx
  800583:	8b 48 04             	mov    0x4(%eax),%ecx
  800586:	8d 40 08             	lea    0x8(%eax),%eax
  800589:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80058c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800591:	e9 a9 00 00 00       	jmp    80063f <vprintfmt+0x3bb>
	else if (lflag)
  800596:	85 c9                	test   %ecx,%ecx
  800598:	75 1a                	jne    8005b4 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 10                	mov    (%eax),%edx
  80059f:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a4:	8d 40 04             	lea    0x4(%eax),%eax
  8005a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005aa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005af:	e9 8b 00 00 00       	jmp    80063f <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	eb 74                	jmp    80063f <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005cb:	83 f9 01             	cmp    $0x1,%ecx
  8005ce:	7e 15                	jle    8005e5 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  8005d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d3:	8b 10                	mov    (%eax),%edx
  8005d5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d8:	8d 40 08             	lea    0x8(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005de:	b8 08 00 00 00       	mov    $0x8,%eax
  8005e3:	eb 5a                	jmp    80063f <vprintfmt+0x3bb>
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	75 17                	jne    800600 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8005f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8005fe:	eb 3f                	jmp    80063f <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8b 10                	mov    (%eax),%edx
  800605:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060a:	8d 40 04             	lea    0x4(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800610:	b8 08 00 00 00       	mov    $0x8,%eax
  800615:	eb 28                	jmp    80063f <vprintfmt+0x3bb>
			putch('0', putdat);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	53                   	push   %ebx
  80061b:	6a 30                	push   $0x30
  80061d:	ff d6                	call   *%esi
			putch('x', putdat);
  80061f:	83 c4 08             	add    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 78                	push   $0x78
  800625:	ff d6                	call   *%esi
			num = (unsigned long long)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800631:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80063f:	83 ec 0c             	sub    $0xc,%esp
  800642:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800646:	57                   	push   %edi
  800647:	ff 75 e0             	pushl  -0x20(%ebp)
  80064a:	50                   	push   %eax
  80064b:	51                   	push   %ecx
  80064c:	52                   	push   %edx
  80064d:	89 da                	mov    %ebx,%edx
  80064f:	89 f0                	mov    %esi,%eax
  800651:	e8 45 fb ff ff       	call   80019b <printnum>
			break;
  800656:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80065c:	83 c7 01             	add    $0x1,%edi
  80065f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800663:	83 f8 25             	cmp    $0x25,%eax
  800666:	0f 84 2f fc ff ff    	je     80029b <vprintfmt+0x17>
			if (ch == '\0')
  80066c:	85 c0                	test   %eax,%eax
  80066e:	0f 84 8b 00 00 00    	je     8006ff <vprintfmt+0x47b>
			putch(ch, putdat);
  800674:	83 ec 08             	sub    $0x8,%esp
  800677:	53                   	push   %ebx
  800678:	50                   	push   %eax
  800679:	ff d6                	call   *%esi
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	eb dc                	jmp    80065c <vprintfmt+0x3d8>
	if (lflag >= 2)
  800680:	83 f9 01             	cmp    $0x1,%ecx
  800683:	7e 15                	jle    80069a <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800685:	8b 45 14             	mov    0x14(%ebp),%eax
  800688:	8b 10                	mov    (%eax),%edx
  80068a:	8b 48 04             	mov    0x4(%eax),%ecx
  80068d:	8d 40 08             	lea    0x8(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800693:	b8 10 00 00 00       	mov    $0x10,%eax
  800698:	eb a5                	jmp    80063f <vprintfmt+0x3bb>
	else if (lflag)
  80069a:	85 c9                	test   %ecx,%ecx
  80069c:	75 17                	jne    8006b5 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 10                	mov    (%eax),%edx
  8006a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a8:	8d 40 04             	lea    0x4(%eax),%eax
  8006ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ae:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b3:	eb 8a                	jmp    80063f <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8b 10                	mov    (%eax),%edx
  8006ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006bf:	8d 40 04             	lea    0x4(%eax),%eax
  8006c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c5:	b8 10 00 00 00       	mov    $0x10,%eax
  8006ca:	e9 70 ff ff ff       	jmp    80063f <vprintfmt+0x3bb>
			putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	6a 25                	push   $0x25
  8006d5:	ff d6                	call   *%esi
			break;
  8006d7:	83 c4 10             	add    $0x10,%esp
  8006da:	e9 7a ff ff ff       	jmp    800659 <vprintfmt+0x3d5>
			putch('%', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	6a 25                	push   $0x25
  8006e5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	89 f8                	mov    %edi,%eax
  8006ec:	eb 03                	jmp    8006f1 <vprintfmt+0x46d>
  8006ee:	83 e8 01             	sub    $0x1,%eax
  8006f1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006f5:	75 f7                	jne    8006ee <vprintfmt+0x46a>
  8006f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006fa:	e9 5a ff ff ff       	jmp    800659 <vprintfmt+0x3d5>
}
  8006ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800702:	5b                   	pop    %ebx
  800703:	5e                   	pop    %esi
  800704:	5f                   	pop    %edi
  800705:	5d                   	pop    %ebp
  800706:	c3                   	ret    

00800707 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	83 ec 18             	sub    $0x18,%esp
  80070d:	8b 45 08             	mov    0x8(%ebp),%eax
  800710:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800713:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800716:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80071d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 26                	je     80074e <vsnprintf+0x47>
  800728:	85 d2                	test   %edx,%edx
  80072a:	7e 22                	jle    80074e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80072c:	ff 75 14             	pushl  0x14(%ebp)
  80072f:	ff 75 10             	pushl  0x10(%ebp)
  800732:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	68 4a 02 80 00       	push   $0x80024a
  80073b:	e8 44 fb ff ff       	call   800284 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800740:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800743:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800749:	83 c4 10             	add    $0x10,%esp
}
  80074c:	c9                   	leave  
  80074d:	c3                   	ret    
		return -E_INVAL;
  80074e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800753:	eb f7                	jmp    80074c <vsnprintf+0x45>

00800755 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075e:	50                   	push   %eax
  80075f:	ff 75 10             	pushl  0x10(%ebp)
  800762:	ff 75 0c             	pushl  0xc(%ebp)
  800765:	ff 75 08             	pushl  0x8(%ebp)
  800768:	e8 9a ff ff ff       	call   800707 <vsnprintf>
	va_end(ap);

	return rc;
}
  80076d:	c9                   	leave  
  80076e:	c3                   	ret    

0080076f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	eb 03                	jmp    80077f <strlen+0x10>
		n++;
  80077c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80077f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800783:	75 f7                	jne    80077c <strlen+0xd>
	return n;
}
  800785:	5d                   	pop    %ebp
  800786:	c3                   	ret    

00800787 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
  800795:	eb 03                	jmp    80079a <strnlen+0x13>
		n++;
  800797:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079a:	39 d0                	cmp    %edx,%eax
  80079c:	74 06                	je     8007a4 <strnlen+0x1d>
  80079e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a2:	75 f3                	jne    800797 <strnlen+0x10>
	return n;
}
  8007a4:	5d                   	pop    %ebp
  8007a5:	c3                   	ret    

008007a6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	53                   	push   %ebx
  8007aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c1 01             	add    $0x1,%ecx
  8007b5:	83 c2 01             	add    $0x1,%edx
  8007b8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007bc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007bf:	84 db                	test   %bl,%bl
  8007c1:	75 ef                	jne    8007b2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c3:	5b                   	pop    %ebx
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007cd:	53                   	push   %ebx
  8007ce:	e8 9c ff ff ff       	call   80076f <strlen>
  8007d3:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007d6:	ff 75 0c             	pushl  0xc(%ebp)
  8007d9:	01 d8                	add    %ebx,%eax
  8007db:	50                   	push   %eax
  8007dc:	e8 c5 ff ff ff       	call   8007a6 <strcpy>
	return dst;
}
  8007e1:	89 d8                	mov    %ebx,%eax
  8007e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e6:	c9                   	leave  
  8007e7:	c3                   	ret    

008007e8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	56                   	push   %esi
  8007ec:	53                   	push   %ebx
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f3:	89 f3                	mov    %esi,%ebx
  8007f5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f8:	89 f2                	mov    %esi,%edx
  8007fa:	eb 0f                	jmp    80080b <strncpy+0x23>
		*dst++ = *src;
  8007fc:	83 c2 01             	add    $0x1,%edx
  8007ff:	0f b6 01             	movzbl (%ecx),%eax
  800802:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800805:	80 39 01             	cmpb   $0x1,(%ecx)
  800808:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80080b:	39 da                	cmp    %ebx,%edx
  80080d:	75 ed                	jne    8007fc <strncpy+0x14>
	}
	return ret;
}
  80080f:	89 f0                	mov    %esi,%eax
  800811:	5b                   	pop    %ebx
  800812:	5e                   	pop    %esi
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	8b 75 08             	mov    0x8(%ebp),%esi
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800820:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800823:	89 f0                	mov    %esi,%eax
  800825:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800829:	85 c9                	test   %ecx,%ecx
  80082b:	75 0b                	jne    800838 <strlcpy+0x23>
  80082d:	eb 17                	jmp    800846 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80082f:	83 c2 01             	add    $0x1,%edx
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800838:	39 d8                	cmp    %ebx,%eax
  80083a:	74 07                	je     800843 <strlcpy+0x2e>
  80083c:	0f b6 0a             	movzbl (%edx),%ecx
  80083f:	84 c9                	test   %cl,%cl
  800841:	75 ec                	jne    80082f <strlcpy+0x1a>
		*dst = '\0';
  800843:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800846:	29 f0                	sub    %esi,%eax
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800852:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800855:	eb 06                	jmp    80085d <strcmp+0x11>
		p++, q++;
  800857:	83 c1 01             	add    $0x1,%ecx
  80085a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80085d:	0f b6 01             	movzbl (%ecx),%eax
  800860:	84 c0                	test   %al,%al
  800862:	74 04                	je     800868 <strcmp+0x1c>
  800864:	3a 02                	cmp    (%edx),%al
  800866:	74 ef                	je     800857 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800868:	0f b6 c0             	movzbl %al,%eax
  80086b:	0f b6 12             	movzbl (%edx),%edx
  80086e:	29 d0                	sub    %edx,%eax
}
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	53                   	push   %ebx
  800876:	8b 45 08             	mov    0x8(%ebp),%eax
  800879:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087c:	89 c3                	mov    %eax,%ebx
  80087e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800881:	eb 06                	jmp    800889 <strncmp+0x17>
		n--, p++, q++;
  800883:	83 c0 01             	add    $0x1,%eax
  800886:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800889:	39 d8                	cmp    %ebx,%eax
  80088b:	74 16                	je     8008a3 <strncmp+0x31>
  80088d:	0f b6 08             	movzbl (%eax),%ecx
  800890:	84 c9                	test   %cl,%cl
  800892:	74 04                	je     800898 <strncmp+0x26>
  800894:	3a 0a                	cmp    (%edx),%cl
  800896:	74 eb                	je     800883 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800898:	0f b6 00             	movzbl (%eax),%eax
  80089b:	0f b6 12             	movzbl (%edx),%edx
  80089e:	29 d0                	sub    %edx,%eax
}
  8008a0:	5b                   	pop    %ebx
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    
		return 0;
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	eb f6                	jmp    8008a0 <strncmp+0x2e>

008008aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b4:	0f b6 10             	movzbl (%eax),%edx
  8008b7:	84 d2                	test   %dl,%dl
  8008b9:	74 09                	je     8008c4 <strchr+0x1a>
		if (*s == c)
  8008bb:	38 ca                	cmp    %cl,%dl
  8008bd:	74 0a                	je     8008c9 <strchr+0x1f>
	for (; *s; s++)
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	eb f0                	jmp    8008b4 <strchr+0xa>
			return (char *) s;
	return 0;
  8008c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c9:	5d                   	pop    %ebp
  8008ca:	c3                   	ret    

008008cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008cb:	55                   	push   %ebp
  8008cc:	89 e5                	mov    %esp,%ebp
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d5:	eb 03                	jmp    8008da <strfind+0xf>
  8008d7:	83 c0 01             	add    $0x1,%eax
  8008da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008dd:	38 ca                	cmp    %cl,%dl
  8008df:	74 04                	je     8008e5 <strfind+0x1a>
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f2                	jne    8008d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008f3:	85 c9                	test   %ecx,%ecx
  8008f5:	74 13                	je     80090a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008fd:	75 05                	jne    800904 <memset+0x1d>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	74 0d                	je     800911 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800904:	8b 45 0c             	mov    0xc(%ebp),%eax
  800907:	fc                   	cld    
  800908:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090a:	89 f8                	mov    %edi,%eax
  80090c:	5b                   	pop    %ebx
  80090d:	5e                   	pop    %esi
  80090e:	5f                   	pop    %edi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    
		c &= 0xFF;
  800911:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800915:	89 d3                	mov    %edx,%ebx
  800917:	c1 e3 08             	shl    $0x8,%ebx
  80091a:	89 d0                	mov    %edx,%eax
  80091c:	c1 e0 18             	shl    $0x18,%eax
  80091f:	89 d6                	mov    %edx,%esi
  800921:	c1 e6 10             	shl    $0x10,%esi
  800924:	09 f0                	or     %esi,%eax
  800926:	09 c2                	or     %eax,%edx
  800928:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80092a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80092d:	89 d0                	mov    %edx,%eax
  80092f:	fc                   	cld    
  800930:	f3 ab                	rep stos %eax,%es:(%edi)
  800932:	eb d6                	jmp    80090a <memset+0x23>

00800934 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	57                   	push   %edi
  800938:	56                   	push   %esi
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800942:	39 c6                	cmp    %eax,%esi
  800944:	73 35                	jae    80097b <memmove+0x47>
  800946:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800949:	39 c2                	cmp    %eax,%edx
  80094b:	76 2e                	jbe    80097b <memmove+0x47>
		s += n;
		d += n;
  80094d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	89 d6                	mov    %edx,%esi
  800952:	09 fe                	or     %edi,%esi
  800954:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095a:	74 0c                	je     800968 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095c:	83 ef 01             	sub    $0x1,%edi
  80095f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800962:	fd                   	std    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800965:	fc                   	cld    
  800966:	eb 21                	jmp    800989 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800968:	f6 c1 03             	test   $0x3,%cl
  80096b:	75 ef                	jne    80095c <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80096d:	83 ef 04             	sub    $0x4,%edi
  800970:	8d 72 fc             	lea    -0x4(%edx),%esi
  800973:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800976:	fd                   	std    
  800977:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800979:	eb ea                	jmp    800965 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097b:	89 f2                	mov    %esi,%edx
  80097d:	09 c2                	or     %eax,%edx
  80097f:	f6 c2 03             	test   $0x3,%dl
  800982:	74 09                	je     80098d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800984:	89 c7                	mov    %eax,%edi
  800986:	fc                   	cld    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800989:	5e                   	pop    %esi
  80098a:	5f                   	pop    %edi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098d:	f6 c1 03             	test   $0x3,%cl
  800990:	75 f2                	jne    800984 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800992:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800995:	89 c7                	mov    %eax,%edi
  800997:	fc                   	cld    
  800998:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099a:	eb ed                	jmp    800989 <memmove+0x55>

0080099c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80099f:	ff 75 10             	pushl  0x10(%ebp)
  8009a2:	ff 75 0c             	pushl  0xc(%ebp)
  8009a5:	ff 75 08             	pushl  0x8(%ebp)
  8009a8:	e8 87 ff ff ff       	call   800934 <memmove>
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ba:	89 c6                	mov    %eax,%esi
  8009bc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009bf:	39 f0                	cmp    %esi,%eax
  8009c1:	74 1c                	je     8009df <memcmp+0x30>
		if (*s1 != *s2)
  8009c3:	0f b6 08             	movzbl (%eax),%ecx
  8009c6:	0f b6 1a             	movzbl (%edx),%ebx
  8009c9:	38 d9                	cmp    %bl,%cl
  8009cb:	75 08                	jne    8009d5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	eb ea                	jmp    8009bf <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c1             	movzbl %cl,%eax
  8009d8:	0f b6 db             	movzbl %bl,%ebx
  8009db:	29 d8                	sub    %ebx,%eax
  8009dd:	eb 05                	jmp    8009e4 <memcmp+0x35>
	}

	return 0;
  8009df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e4:	5b                   	pop    %ebx
  8009e5:	5e                   	pop    %esi
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009f1:	89 c2                	mov    %eax,%edx
  8009f3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f6:	39 d0                	cmp    %edx,%eax
  8009f8:	73 09                	jae    800a03 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fa:	38 08                	cmp    %cl,(%eax)
  8009fc:	74 05                	je     800a03 <memfind+0x1b>
	for (; s < ends; s++)
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	eb f3                	jmp    8009f6 <memfind+0xe>
			break;
	return (void *) s;
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	57                   	push   %edi
  800a09:	56                   	push   %esi
  800a0a:	53                   	push   %ebx
  800a0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a11:	eb 03                	jmp    800a16 <strtol+0x11>
		s++;
  800a13:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a16:	0f b6 01             	movzbl (%ecx),%eax
  800a19:	3c 20                	cmp    $0x20,%al
  800a1b:	74 f6                	je     800a13 <strtol+0xe>
  800a1d:	3c 09                	cmp    $0x9,%al
  800a1f:	74 f2                	je     800a13 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a21:	3c 2b                	cmp    $0x2b,%al
  800a23:	74 2e                	je     800a53 <strtol+0x4e>
	int neg = 0;
  800a25:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a2a:	3c 2d                	cmp    $0x2d,%al
  800a2c:	74 2f                	je     800a5d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a34:	75 05                	jne    800a3b <strtol+0x36>
  800a36:	80 39 30             	cmpb   $0x30,(%ecx)
  800a39:	74 2c                	je     800a67 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a3b:	85 db                	test   %ebx,%ebx
  800a3d:	75 0a                	jne    800a49 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3f:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800a44:	80 39 30             	cmpb   $0x30,(%ecx)
  800a47:	74 28                	je     800a71 <strtol+0x6c>
		base = 10;
  800a49:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a51:	eb 50                	jmp    800aa3 <strtol+0x9e>
		s++;
  800a53:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a56:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5b:	eb d1                	jmp    800a2e <strtol+0x29>
		s++, neg = 1;
  800a5d:	83 c1 01             	add    $0x1,%ecx
  800a60:	bf 01 00 00 00       	mov    $0x1,%edi
  800a65:	eb c7                	jmp    800a2e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a67:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6b:	74 0e                	je     800a7b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	75 d8                	jne    800a49 <strtol+0x44>
		s++, base = 8;
  800a71:	83 c1 01             	add    $0x1,%ecx
  800a74:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a79:	eb ce                	jmp    800a49 <strtol+0x44>
		s += 2, base = 16;
  800a7b:	83 c1 02             	add    $0x2,%ecx
  800a7e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a83:	eb c4                	jmp    800a49 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800a85:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a88:	89 f3                	mov    %esi,%ebx
  800a8a:	80 fb 19             	cmp    $0x19,%bl
  800a8d:	77 29                	ja     800ab8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a8f:	0f be d2             	movsbl %dl,%edx
  800a92:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a95:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a98:	7d 30                	jge    800aca <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a9a:	83 c1 01             	add    $0x1,%ecx
  800a9d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa3:	0f b6 11             	movzbl (%ecx),%edx
  800aa6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aa9:	89 f3                	mov    %esi,%ebx
  800aab:	80 fb 09             	cmp    $0x9,%bl
  800aae:	77 d5                	ja     800a85 <strtol+0x80>
			dig = *s - '0';
  800ab0:	0f be d2             	movsbl %dl,%edx
  800ab3:	83 ea 30             	sub    $0x30,%edx
  800ab6:	eb dd                	jmp    800a95 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800ab8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abb:	89 f3                	mov    %esi,%ebx
  800abd:	80 fb 19             	cmp    $0x19,%bl
  800ac0:	77 08                	ja     800aca <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ac2:	0f be d2             	movsbl %dl,%edx
  800ac5:	83 ea 37             	sub    $0x37,%edx
  800ac8:	eb cb                	jmp    800a95 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ace:	74 05                	je     800ad5 <strtol+0xd0>
		*endptr = (char *) s;
  800ad0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ad3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad5:	89 c2                	mov    %eax,%edx
  800ad7:	f7 da                	neg    %edx
  800ad9:	85 ff                	test   %edi,%edi
  800adb:	0f 45 c2             	cmovne %edx,%eax
}
  800ade:	5b                   	pop    %ebx
  800adf:	5e                   	pop    %esi
  800ae0:	5f                   	pop    %edi
  800ae1:	5d                   	pop    %ebp
  800ae2:	c3                   	ret    

00800ae3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	57                   	push   %edi
  800ae7:	56                   	push   %esi
  800ae8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ae9:	b8 00 00 00 00       	mov    $0x0,%eax
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af4:	89 c3                	mov    %eax,%ebx
  800af6:	89 c7                	mov    %eax,%edi
  800af8:	89 c6                	mov    %eax,%esi
  800afa:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afc:	5b                   	pop    %ebx
  800afd:	5e                   	pop    %esi
  800afe:	5f                   	pop    %edi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b07:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b11:	89 d1                	mov    %edx,%ecx
  800b13:	89 d3                	mov    %edx,%ebx
  800b15:	89 d7                	mov    %edx,%edi
  800b17:	89 d6                	mov    %edx,%esi
  800b19:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
  800b26:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	b8 03 00 00 00       	mov    $0x3,%eax
  800b36:	89 cb                	mov    %ecx,%ebx
  800b38:	89 cf                	mov    %ecx,%edi
  800b3a:	89 ce                	mov    %ecx,%esi
  800b3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	7f 08                	jg     800b4a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b45:	5b                   	pop    %ebx
  800b46:	5e                   	pop    %esi
  800b47:	5f                   	pop    %edi
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	50                   	push   %eax
  800b4e:	6a 03                	push   $0x3
  800b50:	68 a4 12 80 00       	push   $0x8012a4
  800b55:	6a 23                	push   $0x23
  800b57:	68 c1 12 80 00       	push   $0x8012c1
  800b5c:	e8 ed 01 00 00       	call   800d4e <_panic>

00800b61 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	57                   	push   %edi
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b71:	89 d1                	mov    %edx,%ecx
  800b73:	89 d3                	mov    %edx,%ebx
  800b75:	89 d7                	mov    %edx,%edi
  800b77:	89 d6                	mov    %edx,%esi
  800b79:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <sys_yield>:

void
sys_yield(void)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b86:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b90:	89 d1                	mov    %edx,%ecx
  800b92:	89 d3                	mov    %edx,%ebx
  800b94:	89 d7                	mov    %edx,%edi
  800b96:	89 d6                	mov    %edx,%esi
  800b98:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b9a:	5b                   	pop    %ebx
  800b9b:	5e                   	pop    %esi
  800b9c:	5f                   	pop    %edi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	57                   	push   %edi
  800ba3:	56                   	push   %esi
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ba8:	be 00 00 00 00       	mov    $0x0,%esi
  800bad:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbb:	89 f7                	mov    %esi,%edi
  800bbd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bbf:	85 c0                	test   %eax,%eax
  800bc1:	7f 08                	jg     800bcb <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc6:	5b                   	pop    %ebx
  800bc7:	5e                   	pop    %esi
  800bc8:	5f                   	pop    %edi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	50                   	push   %eax
  800bcf:	6a 04                	push   $0x4
  800bd1:	68 a4 12 80 00       	push   $0x8012a4
  800bd6:	6a 23                	push   $0x23
  800bd8:	68 c1 12 80 00       	push   $0x8012c1
  800bdd:	e8 6c 01 00 00       	call   800d4e <_panic>

00800be2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800beb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf1:	b8 05 00 00 00       	mov    $0x5,%eax
  800bf6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bfc:	8b 75 18             	mov    0x18(%ebp),%esi
  800bff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c01:	85 c0                	test   %eax,%eax
  800c03:	7f 08                	jg     800c0d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	50                   	push   %eax
  800c11:	6a 05                	push   $0x5
  800c13:	68 a4 12 80 00       	push   $0x8012a4
  800c18:	6a 23                	push   $0x23
  800c1a:	68 c1 12 80 00       	push   $0x8012c1
  800c1f:	e8 2a 01 00 00       	call   800d4e <_panic>

00800c24 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	57                   	push   %edi
  800c28:	56                   	push   %esi
  800c29:	53                   	push   %ebx
  800c2a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c32:	8b 55 08             	mov    0x8(%ebp),%edx
  800c35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c38:	b8 06 00 00 00       	mov    $0x6,%eax
  800c3d:	89 df                	mov    %ebx,%edi
  800c3f:	89 de                	mov    %ebx,%esi
  800c41:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c43:	85 c0                	test   %eax,%eax
  800c45:	7f 08                	jg     800c4f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4a:	5b                   	pop    %ebx
  800c4b:	5e                   	pop    %esi
  800c4c:	5f                   	pop    %edi
  800c4d:	5d                   	pop    %ebp
  800c4e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4f:	83 ec 0c             	sub    $0xc,%esp
  800c52:	50                   	push   %eax
  800c53:	6a 06                	push   $0x6
  800c55:	68 a4 12 80 00       	push   $0x8012a4
  800c5a:	6a 23                	push   $0x23
  800c5c:	68 c1 12 80 00       	push   $0x8012c1
  800c61:	e8 e8 00 00 00       	call   800d4e <_panic>

00800c66 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c74:	8b 55 08             	mov    0x8(%ebp),%edx
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800c7f:	89 df                	mov    %ebx,%edi
  800c81:	89 de                	mov    %ebx,%esi
  800c83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7f 08                	jg     800c91 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8c:	5b                   	pop    %ebx
  800c8d:	5e                   	pop    %esi
  800c8e:	5f                   	pop    %edi
  800c8f:	5d                   	pop    %ebp
  800c90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	6a 08                	push   $0x8
  800c97:	68 a4 12 80 00       	push   $0x8012a4
  800c9c:	6a 23                	push   $0x23
  800c9e:	68 c1 12 80 00       	push   $0x8012c1
  800ca3:	e8 a6 00 00 00       	call   800d4e <_panic>

00800ca8 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	57                   	push   %edi
  800cac:	56                   	push   %esi
  800cad:	53                   	push   %ebx
  800cae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc1:	89 df                	mov    %ebx,%edi
  800cc3:	89 de                	mov    %ebx,%esi
  800cc5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	7f 08                	jg     800cd3 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ccb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cce:	5b                   	pop    %ebx
  800ccf:	5e                   	pop    %esi
  800cd0:	5f                   	pop    %edi
  800cd1:	5d                   	pop    %ebp
  800cd2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	50                   	push   %eax
  800cd7:	6a 09                	push   $0x9
  800cd9:	68 a4 12 80 00       	push   $0x8012a4
  800cde:	6a 23                	push   $0x23
  800ce0:	68 c1 12 80 00       	push   $0x8012c1
  800ce5:	e8 64 00 00 00       	call   800d4e <_panic>

00800cea <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	57                   	push   %edi
  800cee:	56                   	push   %esi
  800cef:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cfb:	be 00 00 00 00       	mov    $0x0,%esi
  800d00:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d03:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d06:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
  800d13:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d23:	89 cb                	mov    %ecx,%ebx
  800d25:	89 cf                	mov    %ecx,%edi
  800d27:	89 ce                	mov    %ecx,%esi
  800d29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7f 08                	jg     800d37 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d32:	5b                   	pop    %ebx
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d37:	83 ec 0c             	sub    $0xc,%esp
  800d3a:	50                   	push   %eax
  800d3b:	6a 0c                	push   $0xc
  800d3d:	68 a4 12 80 00       	push   $0x8012a4
  800d42:	6a 23                	push   $0x23
  800d44:	68 c1 12 80 00       	push   $0x8012c1
  800d49:	e8 00 00 00 00       	call   800d4e <_panic>

00800d4e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d53:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d56:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d5c:	e8 00 fe ff ff       	call   800b61 <sys_getenvid>
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	ff 75 0c             	pushl  0xc(%ebp)
  800d67:	ff 75 08             	pushl  0x8(%ebp)
  800d6a:	56                   	push   %esi
  800d6b:	50                   	push   %eax
  800d6c:	68 d0 12 80 00       	push   $0x8012d0
  800d71:	e8 11 f4 ff ff       	call   800187 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d76:	83 c4 18             	add    $0x18,%esp
  800d79:	53                   	push   %ebx
  800d7a:	ff 75 10             	pushl  0x10(%ebp)
  800d7d:	e8 b4 f3 ff ff       	call   800136 <vcprintf>
	cprintf("\n");
  800d82:	c7 04 24 f4 12 80 00 	movl   $0x8012f4,(%esp)
  800d89:	e8 f9 f3 ff ff       	call   800187 <cprintf>
  800d8e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800d91:	cc                   	int3   
  800d92:	eb fd                	jmp    800d91 <_panic+0x43>
  800d94:	66 90                	xchg   %ax,%ax
  800d96:	66 90                	xchg   %ax,%ax
  800d98:	66 90                	xchg   %ax,%ax
  800d9a:	66 90                	xchg   %ax,%ax
  800d9c:	66 90                	xchg   %ax,%ax
  800d9e:	66 90                	xchg   %ax,%ax

00800da0 <__udivdi3>:
  800da0:	55                   	push   %ebp
  800da1:	57                   	push   %edi
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	83 ec 1c             	sub    $0x1c,%esp
  800da7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dab:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800daf:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800db7:	85 d2                	test   %edx,%edx
  800db9:	75 35                	jne    800df0 <__udivdi3+0x50>
  800dbb:	39 f3                	cmp    %esi,%ebx
  800dbd:	0f 87 bd 00 00 00    	ja     800e80 <__udivdi3+0xe0>
  800dc3:	85 db                	test   %ebx,%ebx
  800dc5:	89 d9                	mov    %ebx,%ecx
  800dc7:	75 0b                	jne    800dd4 <__udivdi3+0x34>
  800dc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dce:	31 d2                	xor    %edx,%edx
  800dd0:	f7 f3                	div    %ebx
  800dd2:	89 c1                	mov    %eax,%ecx
  800dd4:	31 d2                	xor    %edx,%edx
  800dd6:	89 f0                	mov    %esi,%eax
  800dd8:	f7 f1                	div    %ecx
  800dda:	89 c6                	mov    %eax,%esi
  800ddc:	89 e8                	mov    %ebp,%eax
  800dde:	89 f7                	mov    %esi,%edi
  800de0:	f7 f1                	div    %ecx
  800de2:	89 fa                	mov    %edi,%edx
  800de4:	83 c4 1c             	add    $0x1c,%esp
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    
  800dec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df0:	39 f2                	cmp    %esi,%edx
  800df2:	77 7c                	ja     800e70 <__udivdi3+0xd0>
  800df4:	0f bd fa             	bsr    %edx,%edi
  800df7:	83 f7 1f             	xor    $0x1f,%edi
  800dfa:	0f 84 98 00 00 00    	je     800e98 <__udivdi3+0xf8>
  800e00:	89 f9                	mov    %edi,%ecx
  800e02:	b8 20 00 00 00       	mov    $0x20,%eax
  800e07:	29 f8                	sub    %edi,%eax
  800e09:	d3 e2                	shl    %cl,%edx
  800e0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e0f:	89 c1                	mov    %eax,%ecx
  800e11:	89 da                	mov    %ebx,%edx
  800e13:	d3 ea                	shr    %cl,%edx
  800e15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e19:	09 d1                	or     %edx,%ecx
  800e1b:	89 f2                	mov    %esi,%edx
  800e1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e21:	89 f9                	mov    %edi,%ecx
  800e23:	d3 e3                	shl    %cl,%ebx
  800e25:	89 c1                	mov    %eax,%ecx
  800e27:	d3 ea                	shr    %cl,%edx
  800e29:	89 f9                	mov    %edi,%ecx
  800e2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e2f:	d3 e6                	shl    %cl,%esi
  800e31:	89 eb                	mov    %ebp,%ebx
  800e33:	89 c1                	mov    %eax,%ecx
  800e35:	d3 eb                	shr    %cl,%ebx
  800e37:	09 de                	or     %ebx,%esi
  800e39:	89 f0                	mov    %esi,%eax
  800e3b:	f7 74 24 08          	divl   0x8(%esp)
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	89 c3                	mov    %eax,%ebx
  800e43:	f7 64 24 0c          	mull   0xc(%esp)
  800e47:	39 d6                	cmp    %edx,%esi
  800e49:	72 0c                	jb     800e57 <__udivdi3+0xb7>
  800e4b:	89 f9                	mov    %edi,%ecx
  800e4d:	d3 e5                	shl    %cl,%ebp
  800e4f:	39 c5                	cmp    %eax,%ebp
  800e51:	73 5d                	jae    800eb0 <__udivdi3+0x110>
  800e53:	39 d6                	cmp    %edx,%esi
  800e55:	75 59                	jne    800eb0 <__udivdi3+0x110>
  800e57:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e5a:	31 ff                	xor    %edi,%edi
  800e5c:	89 fa                	mov    %edi,%edx
  800e5e:	83 c4 1c             	add    $0x1c,%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    
  800e66:	8d 76 00             	lea    0x0(%esi),%esi
  800e69:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e70:	31 ff                	xor    %edi,%edi
  800e72:	31 c0                	xor    %eax,%eax
  800e74:	89 fa                	mov    %edi,%edx
  800e76:	83 c4 1c             	add    $0x1c,%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    
  800e7e:	66 90                	xchg   %ax,%ax
  800e80:	31 ff                	xor    %edi,%edi
  800e82:	89 e8                	mov    %ebp,%eax
  800e84:	89 f2                	mov    %esi,%edx
  800e86:	f7 f3                	div    %ebx
  800e88:	89 fa                	mov    %edi,%edx
  800e8a:	83 c4 1c             	add    $0x1c,%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    
  800e92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e98:	39 f2                	cmp    %esi,%edx
  800e9a:	72 06                	jb     800ea2 <__udivdi3+0x102>
  800e9c:	31 c0                	xor    %eax,%eax
  800e9e:	39 eb                	cmp    %ebp,%ebx
  800ea0:	77 d2                	ja     800e74 <__udivdi3+0xd4>
  800ea2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ea7:	eb cb                	jmp    800e74 <__udivdi3+0xd4>
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	89 d8                	mov    %ebx,%eax
  800eb2:	31 ff                	xor    %edi,%edi
  800eb4:	eb be                	jmp    800e74 <__udivdi3+0xd4>
  800eb6:	66 90                	xchg   %ax,%ax
  800eb8:	66 90                	xchg   %ax,%ax
  800eba:	66 90                	xchg   %ax,%ax
  800ebc:	66 90                	xchg   %ax,%ax
  800ebe:	66 90                	xchg   %ax,%ax

00800ec0 <__umoddi3>:
  800ec0:	55                   	push   %ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	83 ec 1c             	sub    $0x1c,%esp
  800ec7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800ecb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ecf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ed3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ed7:	85 ed                	test   %ebp,%ebp
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	89 da                	mov    %ebx,%edx
  800edd:	75 19                	jne    800ef8 <__umoddi3+0x38>
  800edf:	39 df                	cmp    %ebx,%edi
  800ee1:	0f 86 b1 00 00 00    	jbe    800f98 <__umoddi3+0xd8>
  800ee7:	f7 f7                	div    %edi
  800ee9:	89 d0                	mov    %edx,%eax
  800eeb:	31 d2                	xor    %edx,%edx
  800eed:	83 c4 1c             	add    $0x1c,%esp
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    
  800ef5:	8d 76 00             	lea    0x0(%esi),%esi
  800ef8:	39 dd                	cmp    %ebx,%ebp
  800efa:	77 f1                	ja     800eed <__umoddi3+0x2d>
  800efc:	0f bd cd             	bsr    %ebp,%ecx
  800eff:	83 f1 1f             	xor    $0x1f,%ecx
  800f02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f06:	0f 84 b4 00 00 00    	je     800fc0 <__umoddi3+0x100>
  800f0c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f11:	89 c2                	mov    %eax,%edx
  800f13:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f17:	29 c2                	sub    %eax,%edx
  800f19:	89 c1                	mov    %eax,%ecx
  800f1b:	89 f8                	mov    %edi,%eax
  800f1d:	d3 e5                	shl    %cl,%ebp
  800f1f:	89 d1                	mov    %edx,%ecx
  800f21:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f25:	d3 e8                	shr    %cl,%eax
  800f27:	09 c5                	or     %eax,%ebp
  800f29:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f2d:	89 c1                	mov    %eax,%ecx
  800f2f:	d3 e7                	shl    %cl,%edi
  800f31:	89 d1                	mov    %edx,%ecx
  800f33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f37:	89 df                	mov    %ebx,%edi
  800f39:	d3 ef                	shr    %cl,%edi
  800f3b:	89 c1                	mov    %eax,%ecx
  800f3d:	89 f0                	mov    %esi,%eax
  800f3f:	d3 e3                	shl    %cl,%ebx
  800f41:	89 d1                	mov    %edx,%ecx
  800f43:	89 fa                	mov    %edi,%edx
  800f45:	d3 e8                	shr    %cl,%eax
  800f47:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f4c:	09 d8                	or     %ebx,%eax
  800f4e:	f7 f5                	div    %ebp
  800f50:	d3 e6                	shl    %cl,%esi
  800f52:	89 d1                	mov    %edx,%ecx
  800f54:	f7 64 24 08          	mull   0x8(%esp)
  800f58:	39 d1                	cmp    %edx,%ecx
  800f5a:	89 c3                	mov    %eax,%ebx
  800f5c:	89 d7                	mov    %edx,%edi
  800f5e:	72 06                	jb     800f66 <__umoddi3+0xa6>
  800f60:	75 0e                	jne    800f70 <__umoddi3+0xb0>
  800f62:	39 c6                	cmp    %eax,%esi
  800f64:	73 0a                	jae    800f70 <__umoddi3+0xb0>
  800f66:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f6a:	19 ea                	sbb    %ebp,%edx
  800f6c:	89 d7                	mov    %edx,%edi
  800f6e:	89 c3                	mov    %eax,%ebx
  800f70:	89 ca                	mov    %ecx,%edx
  800f72:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f77:	29 de                	sub    %ebx,%esi
  800f79:	19 fa                	sbb    %edi,%edx
  800f7b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f7f:	89 d0                	mov    %edx,%eax
  800f81:	d3 e0                	shl    %cl,%eax
  800f83:	89 d9                	mov    %ebx,%ecx
  800f85:	d3 ee                	shr    %cl,%esi
  800f87:	d3 ea                	shr    %cl,%edx
  800f89:	09 f0                	or     %esi,%eax
  800f8b:	83 c4 1c             	add    $0x1c,%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    
  800f93:	90                   	nop
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	85 ff                	test   %edi,%edi
  800f9a:	89 f9                	mov    %edi,%ecx
  800f9c:	75 0b                	jne    800fa9 <__umoddi3+0xe9>
  800f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f7                	div    %edi
  800fa7:	89 c1                	mov    %eax,%ecx
  800fa9:	89 d8                	mov    %ebx,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	f7 f1                	div    %ecx
  800faf:	89 f0                	mov    %esi,%eax
  800fb1:	f7 f1                	div    %ecx
  800fb3:	e9 31 ff ff ff       	jmp    800ee9 <__umoddi3+0x29>
  800fb8:	90                   	nop
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	39 dd                	cmp    %ebx,%ebp
  800fc2:	72 08                	jb     800fcc <__umoddi3+0x10c>
  800fc4:	39 f7                	cmp    %esi,%edi
  800fc6:	0f 87 21 ff ff ff    	ja     800eed <__umoddi3+0x2d>
  800fcc:	89 da                	mov    %ebx,%edx
  800fce:	89 f0                	mov    %esi,%eax
  800fd0:	29 f8                	sub    %edi,%eax
  800fd2:	19 ea                	sbb    %ebp,%edx
  800fd4:	e9 14 ff ff ff       	jmp    800eed <__umoddi3+0x2d>
