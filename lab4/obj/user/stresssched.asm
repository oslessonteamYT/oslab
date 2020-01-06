
obj/user/stresssched：     文件格式 elf32-i386


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
  80002c:	e8 b7 00 00 00       	call   8000e8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800038:	e8 b8 0b 00 00       	call   800bf5 <sys_getenvid>
  80003d:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  80003f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800044:	e8 9b 0e 00 00       	call   800ee4 <fork>
  800049:	85 c0                	test   %eax,%eax
  80004b:	74 0f                	je     80005c <umain+0x29>
	for (i = 0; i < 20; i++)
  80004d:	83 c3 01             	add    $0x1,%ebx
  800050:	83 fb 14             	cmp    $0x14,%ebx
  800053:	75 ef                	jne    800044 <umain+0x11>
			break;
	if (i == 20) {
		sys_yield();
  800055:	e8 ba 0b 00 00       	call   800c14 <sys_yield>
		return;
  80005a:	eb 6e                	jmp    8000ca <umain+0x97>
	if (i == 20) {
  80005c:	83 fb 14             	cmp    $0x14,%ebx
  80005f:	74 f4                	je     800055 <umain+0x22>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800061:	89 f0                	mov    %esi,%eax
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	eb 02                	jmp    800074 <umain+0x41>
		asm volatile("pause");
  800072:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800074:	8b 50 54             	mov    0x54(%eax),%edx
  800077:	85 d2                	test   %edx,%edx
  800079:	75 f7                	jne    800072 <umain+0x3f>
  80007b:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  800080:	e8 8f 0b 00 00       	call   800c14 <sys_yield>
  800085:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  80008a:	a1 04 20 80 00       	mov    0x802004,%eax
  80008f:	83 c0 01             	add    $0x1,%eax
  800092:	a3 04 20 80 00       	mov    %eax,0x802004
		for (j = 0; j < 10000; j++)
  800097:	83 ea 01             	sub    $0x1,%edx
  80009a:	75 ee                	jne    80008a <umain+0x57>
	for (i = 0; i < 10; i++) {
  80009c:	83 eb 01             	sub    $0x1,%ebx
  80009f:	75 df                	jne    800080 <umain+0x4d>
	}

	if (counter != 10*10000)
  8000a1:	a1 04 20 80 00       	mov    0x802004,%eax
  8000a6:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000ab:	75 24                	jne    8000d1 <umain+0x9e>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ad:	a1 08 20 80 00       	mov    0x802008,%eax
  8000b2:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b5:	8b 40 48             	mov    0x48(%eax),%eax
  8000b8:	83 ec 04             	sub    $0x4,%esp
  8000bb:	52                   	push   %edx
  8000bc:	50                   	push   %eax
  8000bd:	68 bb 13 80 00       	push   $0x8013bb
  8000c2:	e8 54 01 00 00       	call   80021b <cprintf>
  8000c7:	83 c4 10             	add    $0x10,%esp

}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d1:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d6:	50                   	push   %eax
  8000d7:	68 80 13 80 00       	push   $0x801380
  8000dc:	6a 21                	push   $0x21
  8000de:	68 a8 13 80 00       	push   $0x8013a8
  8000e3:	e8 58 00 00 00       	call   800140 <_panic>

008000e8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000f3:	e8 fd 0a 00 00       	call   800bf5 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000f8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000fd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800100:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800105:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80010a:	85 db                	test   %ebx,%ebx
  80010c:	7e 07                	jle    800115 <libmain+0x2d>
		binaryname = argv[0];
  80010e:	8b 06                	mov    (%esi),%eax
  800110:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800115:	83 ec 08             	sub    $0x8,%esp
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
  80011a:	e8 14 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80011f:	e8 0a 00 00 00       	call   80012e <exit>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800134:	6a 00                	push   $0x0
  800136:	e8 79 0a 00 00       	call   800bb4 <sys_env_destroy>
}
  80013b:	83 c4 10             	add    $0x10,%esp
  80013e:	c9                   	leave  
  80013f:	c3                   	ret    

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800145:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800148:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80014e:	e8 a2 0a 00 00       	call   800bf5 <sys_getenvid>
  800153:	83 ec 0c             	sub    $0xc,%esp
  800156:	ff 75 0c             	pushl  0xc(%ebp)
  800159:	ff 75 08             	pushl  0x8(%ebp)
  80015c:	56                   	push   %esi
  80015d:	50                   	push   %eax
  80015e:	68 e4 13 80 00       	push   $0x8013e4
  800163:	e8 b3 00 00 00       	call   80021b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800168:	83 c4 18             	add    $0x18,%esp
  80016b:	53                   	push   %ebx
  80016c:	ff 75 10             	pushl  0x10(%ebp)
  80016f:	e8 56 00 00 00       	call   8001ca <vcprintf>
	cprintf("\n");
  800174:	c7 04 24 d7 13 80 00 	movl   $0x8013d7,(%esp)
  80017b:	e8 9b 00 00 00       	call   80021b <cprintf>
  800180:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800183:	cc                   	int3   
  800184:	eb fd                	jmp    800183 <_panic+0x43>

00800186 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	53                   	push   %ebx
  80018a:	83 ec 04             	sub    $0x4,%esp
  80018d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800190:	8b 13                	mov    (%ebx),%edx
  800192:	8d 42 01             	lea    0x1(%edx),%eax
  800195:	89 03                	mov    %eax,(%ebx)
  800197:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80019a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80019e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a3:	74 09                	je     8001ae <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001a5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001ac:	c9                   	leave  
  8001ad:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	68 ff 00 00 00       	push   $0xff
  8001b6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b9:	50                   	push   %eax
  8001ba:	e8 b8 09 00 00       	call   800b77 <sys_cputs>
		b->idx = 0;
  8001bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb db                	jmp    8001a5 <putch+0x1f>

008001ca <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001d3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001da:	00 00 00 
	b.cnt = 0;
  8001dd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001e7:	ff 75 0c             	pushl  0xc(%ebp)
  8001ea:	ff 75 08             	pushl  0x8(%ebp)
  8001ed:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001f3:	50                   	push   %eax
  8001f4:	68 86 01 80 00       	push   $0x800186
  8001f9:	e8 1a 01 00 00       	call   800318 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001fe:	83 c4 08             	add    $0x8,%esp
  800201:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800207:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80020d:	50                   	push   %eax
  80020e:	e8 64 09 00 00       	call   800b77 <sys_cputs>

	return b.cnt;
}
  800213:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800219:	c9                   	leave  
  80021a:	c3                   	ret    

0080021b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800221:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800224:	50                   	push   %eax
  800225:	ff 75 08             	pushl  0x8(%ebp)
  800228:	e8 9d ff ff ff       	call   8001ca <vcprintf>
	va_end(ap);

	return cnt;
}
  80022d:	c9                   	leave  
  80022e:	c3                   	ret    

0080022f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 1c             	sub    $0x1c,%esp
  800238:	89 c7                	mov    %eax,%edi
  80023a:	89 d6                	mov    %edx,%esi
  80023c:	8b 45 08             	mov    0x8(%ebp),%eax
  80023f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800242:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800245:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800248:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80024b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800250:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800253:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800256:	39 d3                	cmp    %edx,%ebx
  800258:	72 05                	jb     80025f <printnum+0x30>
  80025a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80025d:	77 7a                	ja     8002d9 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025f:	83 ec 0c             	sub    $0xc,%esp
  800262:	ff 75 18             	pushl  0x18(%ebp)
  800265:	8b 45 14             	mov    0x14(%ebp),%eax
  800268:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80026b:	53                   	push   %ebx
  80026c:	ff 75 10             	pushl  0x10(%ebp)
  80026f:	83 ec 08             	sub    $0x8,%esp
  800272:	ff 75 e4             	pushl  -0x1c(%ebp)
  800275:	ff 75 e0             	pushl  -0x20(%ebp)
  800278:	ff 75 dc             	pushl  -0x24(%ebp)
  80027b:	ff 75 d8             	pushl  -0x28(%ebp)
  80027e:	e8 bd 0e 00 00       	call   801140 <__udivdi3>
  800283:	83 c4 18             	add    $0x18,%esp
  800286:	52                   	push   %edx
  800287:	50                   	push   %eax
  800288:	89 f2                	mov    %esi,%edx
  80028a:	89 f8                	mov    %edi,%eax
  80028c:	e8 9e ff ff ff       	call   80022f <printnum>
  800291:	83 c4 20             	add    $0x20,%esp
  800294:	eb 13                	jmp    8002a9 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	ff 75 18             	pushl  0x18(%ebp)
  80029d:	ff d7                	call   *%edi
  80029f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002a2:	83 eb 01             	sub    $0x1,%ebx
  8002a5:	85 db                	test   %ebx,%ebx
  8002a7:	7f ed                	jg     800296 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	56                   	push   %esi
  8002ad:	83 ec 04             	sub    $0x4,%esp
  8002b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8002b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8002bc:	e8 9f 0f 00 00       	call   801260 <__umoddi3>
  8002c1:	83 c4 14             	add    $0x14,%esp
  8002c4:	0f be 80 07 14 80 00 	movsbl 0x801407(%eax),%eax
  8002cb:	50                   	push   %eax
  8002cc:	ff d7                	call   *%edi
}
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d4:	5b                   	pop    %ebx
  8002d5:	5e                   	pop    %esi
  8002d6:	5f                   	pop    %edi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    
  8002d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002dc:	eb c4                	jmp    8002a2 <printnum+0x73>

008002de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002e8:	8b 10                	mov    (%eax),%edx
  8002ea:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ed:	73 0a                	jae    8002f9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002ef:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002f2:	89 08                	mov    %ecx,(%eax)
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	88 02                	mov    %al,(%edx)
}
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <printfmt>:
{
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800301:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800304:	50                   	push   %eax
  800305:	ff 75 10             	pushl  0x10(%ebp)
  800308:	ff 75 0c             	pushl  0xc(%ebp)
  80030b:	ff 75 08             	pushl  0x8(%ebp)
  80030e:	e8 05 00 00 00       	call   800318 <vprintfmt>
}
  800313:	83 c4 10             	add    $0x10,%esp
  800316:	c9                   	leave  
  800317:	c3                   	ret    

00800318 <vprintfmt>:
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	57                   	push   %edi
  80031c:	56                   	push   %esi
  80031d:	53                   	push   %ebx
  80031e:	83 ec 2c             	sub    $0x2c,%esp
  800321:	8b 75 08             	mov    0x8(%ebp),%esi
  800324:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800327:	8b 7d 10             	mov    0x10(%ebp),%edi
  80032a:	e9 c1 03 00 00       	jmp    8006f0 <vprintfmt+0x3d8>
		padc = ' ';
  80032f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800333:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80033a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800341:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800348:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8d 47 01             	lea    0x1(%edi),%eax
  800350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800353:	0f b6 17             	movzbl (%edi),%edx
  800356:	8d 42 dd             	lea    -0x23(%edx),%eax
  800359:	3c 55                	cmp    $0x55,%al
  80035b:	0f 87 12 04 00 00    	ja     800773 <vprintfmt+0x45b>
  800361:	0f b6 c0             	movzbl %al,%eax
  800364:	ff 24 85 c0 14 80 00 	jmp    *0x8014c0(,%eax,4)
  80036b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80036e:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800372:	eb d9                	jmp    80034d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800377:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80037b:	eb d0                	jmp    80034d <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	0f b6 d2             	movzbl %dl,%edx
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800383:	b8 00 00 00 00       	mov    $0x0,%eax
  800388:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80038b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80038e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800392:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800395:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800398:	83 f9 09             	cmp    $0x9,%ecx
  80039b:	77 55                	ja     8003f2 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80039d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a0:	eb e9                	jmp    80038b <vprintfmt+0x73>
			precision = va_arg(ap, int);
  8003a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a5:	8b 00                	mov    (%eax),%eax
  8003a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ad:	8d 40 04             	lea    0x4(%eax),%eax
  8003b0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ba:	79 91                	jns    80034d <vprintfmt+0x35>
				width = precision, precision = -1;
  8003bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003c9:	eb 82                	jmp    80034d <vprintfmt+0x35>
  8003cb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ce:	85 c0                	test   %eax,%eax
  8003d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d5:	0f 49 d0             	cmovns %eax,%edx
  8003d8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003de:	e9 6a ff ff ff       	jmp    80034d <vprintfmt+0x35>
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003e6:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ed:	e9 5b ff ff ff       	jmp    80034d <vprintfmt+0x35>
  8003f2:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003f8:	eb bc                	jmp    8003b6 <vprintfmt+0x9e>
			lflag++;
  8003fa:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800400:	e9 48 ff ff ff       	jmp    80034d <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800405:	8b 45 14             	mov    0x14(%ebp),%eax
  800408:	8d 78 04             	lea    0x4(%eax),%edi
  80040b:	83 ec 08             	sub    $0x8,%esp
  80040e:	53                   	push   %ebx
  80040f:	ff 30                	pushl  (%eax)
  800411:	ff d6                	call   *%esi
			break;
  800413:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800416:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800419:	e9 cf 02 00 00       	jmp    8006ed <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 78 04             	lea    0x4(%eax),%edi
  800424:	8b 00                	mov    (%eax),%eax
  800426:	99                   	cltd   
  800427:	31 d0                	xor    %edx,%eax
  800429:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80042b:	83 f8 08             	cmp    $0x8,%eax
  80042e:	7f 23                	jg     800453 <vprintfmt+0x13b>
  800430:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  800437:	85 d2                	test   %edx,%edx
  800439:	74 18                	je     800453 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80043b:	52                   	push   %edx
  80043c:	68 28 14 80 00       	push   $0x801428
  800441:	53                   	push   %ebx
  800442:	56                   	push   %esi
  800443:	e8 b3 fe ff ff       	call   8002fb <printfmt>
  800448:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80044e:	e9 9a 02 00 00       	jmp    8006ed <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800453:	50                   	push   %eax
  800454:	68 1f 14 80 00       	push   $0x80141f
  800459:	53                   	push   %ebx
  80045a:	56                   	push   %esi
  80045b:	e8 9b fe ff ff       	call   8002fb <printfmt>
  800460:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800463:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800466:	e9 82 02 00 00       	jmp    8006ed <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80046b:	8b 45 14             	mov    0x14(%ebp),%eax
  80046e:	83 c0 04             	add    $0x4,%eax
  800471:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800479:	85 ff                	test   %edi,%edi
  80047b:	b8 18 14 80 00       	mov    $0x801418,%eax
  800480:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800483:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800487:	0f 8e bd 00 00 00    	jle    80054a <vprintfmt+0x232>
  80048d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800491:	75 0e                	jne    8004a1 <vprintfmt+0x189>
  800493:	89 75 08             	mov    %esi,0x8(%ebp)
  800496:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049f:	eb 6d                	jmp    80050e <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	ff 75 d0             	pushl  -0x30(%ebp)
  8004a7:	57                   	push   %edi
  8004a8:	e8 6e 03 00 00       	call   80081b <strnlen>
  8004ad:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b0:	29 c1                	sub    %eax,%ecx
  8004b2:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004b5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004b8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004bf:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004c2:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	eb 0f                	jmp    8004d5 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004c6:	83 ec 08             	sub    $0x8,%esp
  8004c9:	53                   	push   %ebx
  8004ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8004cd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cf:	83 ef 01             	sub    $0x1,%edi
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	85 ff                	test   %edi,%edi
  8004d7:	7f ed                	jg     8004c6 <vprintfmt+0x1ae>
  8004d9:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004dc:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004df:	85 c9                	test   %ecx,%ecx
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	0f 49 c1             	cmovns %ecx,%eax
  8004e9:	29 c1                	sub    %eax,%ecx
  8004eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8004ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f4:	89 cb                	mov    %ecx,%ebx
  8004f6:	eb 16                	jmp    80050e <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004f8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004fc:	75 31                	jne    80052f <vprintfmt+0x217>
					putch(ch, putdat);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	50                   	push   %eax
  800505:	ff 55 08             	call   *0x8(%ebp)
  800508:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050b:	83 eb 01             	sub    $0x1,%ebx
  80050e:	83 c7 01             	add    $0x1,%edi
  800511:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800515:	0f be c2             	movsbl %dl,%eax
  800518:	85 c0                	test   %eax,%eax
  80051a:	74 59                	je     800575 <vprintfmt+0x25d>
  80051c:	85 f6                	test   %esi,%esi
  80051e:	78 d8                	js     8004f8 <vprintfmt+0x1e0>
  800520:	83 ee 01             	sub    $0x1,%esi
  800523:	79 d3                	jns    8004f8 <vprintfmt+0x1e0>
  800525:	89 df                	mov    %ebx,%edi
  800527:	8b 75 08             	mov    0x8(%ebp),%esi
  80052a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80052d:	eb 37                	jmp    800566 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80052f:	0f be d2             	movsbl %dl,%edx
  800532:	83 ea 20             	sub    $0x20,%edx
  800535:	83 fa 5e             	cmp    $0x5e,%edx
  800538:	76 c4                	jbe    8004fe <vprintfmt+0x1e6>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	ff 75 0c             	pushl  0xc(%ebp)
  800540:	6a 3f                	push   $0x3f
  800542:	ff 55 08             	call   *0x8(%ebp)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb c1                	jmp    80050b <vprintfmt+0x1f3>
  80054a:	89 75 08             	mov    %esi,0x8(%ebp)
  80054d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800550:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800553:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800556:	eb b6                	jmp    80050e <vprintfmt+0x1f6>
				putch(' ', putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	53                   	push   %ebx
  80055c:	6a 20                	push   $0x20
  80055e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800560:	83 ef 01             	sub    $0x1,%edi
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	85 ff                	test   %edi,%edi
  800568:	7f ee                	jg     800558 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80056a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
  800570:	e9 78 01 00 00       	jmp    8006ed <vprintfmt+0x3d5>
  800575:	89 df                	mov    %ebx,%edi
  800577:	8b 75 08             	mov    0x8(%ebp),%esi
  80057a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80057d:	eb e7                	jmp    800566 <vprintfmt+0x24e>
	if (lflag >= 2)
  80057f:	83 f9 01             	cmp    $0x1,%ecx
  800582:	7e 3f                	jle    8005c3 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 50 04             	mov    0x4(%eax),%edx
  80058a:	8b 00                	mov    (%eax),%eax
  80058c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 40 08             	lea    0x8(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80059b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059f:	79 5c                	jns    8005fd <vprintfmt+0x2e5>
				putch('-', putdat);
  8005a1:	83 ec 08             	sub    $0x8,%esp
  8005a4:	53                   	push   %ebx
  8005a5:	6a 2d                	push   $0x2d
  8005a7:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005af:	f7 da                	neg    %edx
  8005b1:	83 d1 00             	adc    $0x0,%ecx
  8005b4:	f7 d9                	neg    %ecx
  8005b6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005be:	e9 10 01 00 00       	jmp    8006d3 <vprintfmt+0x3bb>
	else if (lflag)
  8005c3:	85 c9                	test   %ecx,%ecx
  8005c5:	75 1b                	jne    8005e2 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cf:	89 c1                	mov    %eax,%ecx
  8005d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb b9                	jmp    80059b <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ea:	89 c1                	mov    %eax,%ecx
  8005ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
  8005fb:	eb 9e                	jmp    80059b <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800600:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800603:	b8 0a 00 00 00       	mov    $0xa,%eax
  800608:	e9 c6 00 00 00       	jmp    8006d3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80060d:	83 f9 01             	cmp    $0x1,%ecx
  800610:	7e 18                	jle    80062a <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8b 10                	mov    (%eax),%edx
  800617:	8b 48 04             	mov    0x4(%eax),%ecx
  80061a:	8d 40 08             	lea    0x8(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
  800625:	e9 a9 00 00 00       	jmp    8006d3 <vprintfmt+0x3bb>
	else if (lflag)
  80062a:	85 c9                	test   %ecx,%ecx
  80062c:	75 1a                	jne    800648 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8b 10                	mov    (%eax),%edx
  800633:	b9 00 00 00 00       	mov    $0x0,%ecx
  800638:	8d 40 04             	lea    0x4(%eax),%eax
  80063b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 8b 00 00 00       	jmp    8006d3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800658:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065d:	eb 74                	jmp    8006d3 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80065f:	83 f9 01             	cmp    $0x1,%ecx
  800662:	7e 15                	jle    800679 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800664:	8b 45 14             	mov    0x14(%ebp),%eax
  800667:	8b 10                	mov    (%eax),%edx
  800669:	8b 48 04             	mov    0x4(%eax),%ecx
  80066c:	8d 40 08             	lea    0x8(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800672:	b8 08 00 00 00       	mov    $0x8,%eax
  800677:	eb 5a                	jmp    8006d3 <vprintfmt+0x3bb>
	else if (lflag)
  800679:	85 c9                	test   %ecx,%ecx
  80067b:	75 17                	jne    800694 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 10                	mov    (%eax),%edx
  800682:	b9 00 00 00 00       	mov    $0x0,%ecx
  800687:	8d 40 04             	lea    0x4(%eax),%eax
  80068a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80068d:	b8 08 00 00 00       	mov    $0x8,%eax
  800692:	eb 3f                	jmp    8006d3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069e:	8d 40 04             	lea    0x4(%eax),%eax
  8006a1:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8006a9:	eb 28                	jmp    8006d3 <vprintfmt+0x3bb>
			putch('0', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 30                	push   $0x30
  8006b1:	ff d6                	call   *%esi
			putch('x', putdat);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 78                	push   $0x78
  8006b9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8b 10                	mov    (%eax),%edx
  8006c0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006c5:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006c8:	8d 40 04             	lea    0x4(%eax),%eax
  8006cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006d3:	83 ec 0c             	sub    $0xc,%esp
  8006d6:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006da:	57                   	push   %edi
  8006db:	ff 75 e0             	pushl  -0x20(%ebp)
  8006de:	50                   	push   %eax
  8006df:	51                   	push   %ecx
  8006e0:	52                   	push   %edx
  8006e1:	89 da                	mov    %ebx,%edx
  8006e3:	89 f0                	mov    %esi,%eax
  8006e5:	e8 45 fb ff ff       	call   80022f <printnum>
			break;
  8006ea:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f0:	83 c7 01             	add    $0x1,%edi
  8006f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006f7:	83 f8 25             	cmp    $0x25,%eax
  8006fa:	0f 84 2f fc ff ff    	je     80032f <vprintfmt+0x17>
			if (ch == '\0')
  800700:	85 c0                	test   %eax,%eax
  800702:	0f 84 8b 00 00 00    	je     800793 <vprintfmt+0x47b>
			putch(ch, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	50                   	push   %eax
  80070d:	ff d6                	call   *%esi
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	eb dc                	jmp    8006f0 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800714:	83 f9 01             	cmp    $0x1,%ecx
  800717:	7e 15                	jle    80072e <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800719:	8b 45 14             	mov    0x14(%ebp),%eax
  80071c:	8b 10                	mov    (%eax),%edx
  80071e:	8b 48 04             	mov    0x4(%eax),%ecx
  800721:	8d 40 08             	lea    0x8(%eax),%eax
  800724:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800727:	b8 10 00 00 00       	mov    $0x10,%eax
  80072c:	eb a5                	jmp    8006d3 <vprintfmt+0x3bb>
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	75 17                	jne    800749 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800742:	b8 10 00 00 00       	mov    $0x10,%eax
  800747:	eb 8a                	jmp    8006d3 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800753:	8d 40 04             	lea    0x4(%eax),%eax
  800756:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800759:	b8 10 00 00 00       	mov    $0x10,%eax
  80075e:	e9 70 ff ff ff       	jmp    8006d3 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	53                   	push   %ebx
  800767:	6a 25                	push   $0x25
  800769:	ff d6                	call   *%esi
			break;
  80076b:	83 c4 10             	add    $0x10,%esp
  80076e:	e9 7a ff ff ff       	jmp    8006ed <vprintfmt+0x3d5>
			putch('%', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 25                	push   $0x25
  800779:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	89 f8                	mov    %edi,%eax
  800780:	eb 03                	jmp    800785 <vprintfmt+0x46d>
  800782:	83 e8 01             	sub    $0x1,%eax
  800785:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800789:	75 f7                	jne    800782 <vprintfmt+0x46a>
  80078b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80078e:	e9 5a ff ff ff       	jmp    8006ed <vprintfmt+0x3d5>
}
  800793:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800796:	5b                   	pop    %ebx
  800797:	5e                   	pop    %esi
  800798:	5f                   	pop    %edi
  800799:	5d                   	pop    %ebp
  80079a:	c3                   	ret    

0080079b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80079b:	55                   	push   %ebp
  80079c:	89 e5                	mov    %esp,%ebp
  80079e:	83 ec 18             	sub    $0x18,%esp
  8007a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007aa:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007ae:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b8:	85 c0                	test   %eax,%eax
  8007ba:	74 26                	je     8007e2 <vsnprintf+0x47>
  8007bc:	85 d2                	test   %edx,%edx
  8007be:	7e 22                	jle    8007e2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007c0:	ff 75 14             	pushl  0x14(%ebp)
  8007c3:	ff 75 10             	pushl  0x10(%ebp)
  8007c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c9:	50                   	push   %eax
  8007ca:	68 de 02 80 00       	push   $0x8002de
  8007cf:	e8 44 fb ff ff       	call   800318 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dd:	83 c4 10             	add    $0x10,%esp
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    
		return -E_INVAL;
  8007e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e7:	eb f7                	jmp    8007e0 <vsnprintf+0x45>

008007e9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007ef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 10             	pushl  0x10(%ebp)
  8007f6:	ff 75 0c             	pushl  0xc(%ebp)
  8007f9:	ff 75 08             	pushl  0x8(%ebp)
  8007fc:	e8 9a ff ff ff       	call   80079b <vsnprintf>
	va_end(ap);

	return rc;
}
  800801:	c9                   	leave  
  800802:	c3                   	ret    

00800803 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800809:	b8 00 00 00 00       	mov    $0x0,%eax
  80080e:	eb 03                	jmp    800813 <strlen+0x10>
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800813:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800817:	75 f7                	jne    800810 <strlen+0xd>
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800821:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800824:	b8 00 00 00 00       	mov    $0x0,%eax
  800829:	eb 03                	jmp    80082e <strnlen+0x13>
		n++;
  80082b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80082e:	39 d0                	cmp    %edx,%eax
  800830:	74 06                	je     800838 <strnlen+0x1d>
  800832:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800836:	75 f3                	jne    80082b <strnlen+0x10>
	return n;
}
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	8b 45 08             	mov    0x8(%ebp),%eax
  800841:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800844:	89 c2                	mov    %eax,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	83 c2 01             	add    $0x1,%edx
  80084c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800850:	88 5a ff             	mov    %bl,-0x1(%edx)
  800853:	84 db                	test   %bl,%bl
  800855:	75 ef                	jne    800846 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800861:	53                   	push   %ebx
  800862:	e8 9c ff ff ff       	call   800803 <strlen>
  800867:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	01 d8                	add    %ebx,%eax
  80086f:	50                   	push   %eax
  800870:	e8 c5 ff ff ff       	call   80083a <strcpy>
	return dst;
}
  800875:	89 d8                	mov    %ebx,%eax
  800877:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800887:	89 f3                	mov    %esi,%ebx
  800889:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088c:	89 f2                	mov    %esi,%edx
  80088e:	eb 0f                	jmp    80089f <strncpy+0x23>
		*dst++ = *src;
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	0f b6 01             	movzbl (%ecx),%eax
  800896:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800899:	80 39 01             	cmpb   $0x1,(%ecx)
  80089c:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80089f:	39 da                	cmp    %ebx,%edx
  8008a1:	75 ed                	jne    800890 <strncpy+0x14>
	}
	return ret;
}
  8008a3:	89 f0                	mov    %esi,%eax
  8008a5:	5b                   	pop    %ebx
  8008a6:	5e                   	pop    %esi
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	56                   	push   %esi
  8008ad:	53                   	push   %ebx
  8008ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008b7:	89 f0                	mov    %esi,%eax
  8008b9:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bd:	85 c9                	test   %ecx,%ecx
  8008bf:	75 0b                	jne    8008cc <strlcpy+0x23>
  8008c1:	eb 17                	jmp    8008da <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c3:	83 c2 01             	add    $0x1,%edx
  8008c6:	83 c0 01             	add    $0x1,%eax
  8008c9:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008cc:	39 d8                	cmp    %ebx,%eax
  8008ce:	74 07                	je     8008d7 <strlcpy+0x2e>
  8008d0:	0f b6 0a             	movzbl (%edx),%ecx
  8008d3:	84 c9                	test   %cl,%cl
  8008d5:	75 ec                	jne    8008c3 <strlcpy+0x1a>
		*dst = '\0';
  8008d7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008da:	29 f0                	sub    %esi,%eax
}
  8008dc:	5b                   	pop    %ebx
  8008dd:	5e                   	pop    %esi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e9:	eb 06                	jmp    8008f1 <strcmp+0x11>
		p++, q++;
  8008eb:	83 c1 01             	add    $0x1,%ecx
  8008ee:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008f1:	0f b6 01             	movzbl (%ecx),%eax
  8008f4:	84 c0                	test   %al,%al
  8008f6:	74 04                	je     8008fc <strcmp+0x1c>
  8008f8:	3a 02                	cmp    (%edx),%al
  8008fa:	74 ef                	je     8008eb <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fc:	0f b6 c0             	movzbl %al,%eax
  8008ff:	0f b6 12             	movzbl (%edx),%edx
  800902:	29 d0                	sub    %edx,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	53                   	push   %ebx
  80090a:	8b 45 08             	mov    0x8(%ebp),%eax
  80090d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800910:	89 c3                	mov    %eax,%ebx
  800912:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800915:	eb 06                	jmp    80091d <strncmp+0x17>
		n--, p++, q++;
  800917:	83 c0 01             	add    $0x1,%eax
  80091a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80091d:	39 d8                	cmp    %ebx,%eax
  80091f:	74 16                	je     800937 <strncmp+0x31>
  800921:	0f b6 08             	movzbl (%eax),%ecx
  800924:	84 c9                	test   %cl,%cl
  800926:	74 04                	je     80092c <strncmp+0x26>
  800928:	3a 0a                	cmp    (%edx),%cl
  80092a:	74 eb                	je     800917 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092c:	0f b6 00             	movzbl (%eax),%eax
  80092f:	0f b6 12             	movzbl (%edx),%edx
  800932:	29 d0                	sub    %edx,%eax
}
  800934:	5b                   	pop    %ebx
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    
		return 0;
  800937:	b8 00 00 00 00       	mov    $0x0,%eax
  80093c:	eb f6                	jmp    800934 <strncmp+0x2e>

0080093e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 45 08             	mov    0x8(%ebp),%eax
  800944:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800948:	0f b6 10             	movzbl (%eax),%edx
  80094b:	84 d2                	test   %dl,%dl
  80094d:	74 09                	je     800958 <strchr+0x1a>
		if (*s == c)
  80094f:	38 ca                	cmp    %cl,%dl
  800951:	74 0a                	je     80095d <strchr+0x1f>
	for (; *s; s++)
  800953:	83 c0 01             	add    $0x1,%eax
  800956:	eb f0                	jmp    800948 <strchr+0xa>
			return (char *) s;
	return 0;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800969:	eb 03                	jmp    80096e <strfind+0xf>
  80096b:	83 c0 01             	add    $0x1,%eax
  80096e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800971:	38 ca                	cmp    %cl,%dl
  800973:	74 04                	je     800979 <strfind+0x1a>
  800975:	84 d2                	test   %dl,%dl
  800977:	75 f2                	jne    80096b <strfind+0xc>
			break;
	return (char *) s;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	57                   	push   %edi
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 7d 08             	mov    0x8(%ebp),%edi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800987:	85 c9                	test   %ecx,%ecx
  800989:	74 13                	je     80099e <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800991:	75 05                	jne    800998 <memset+0x1d>
  800993:	f6 c1 03             	test   $0x3,%cl
  800996:	74 0d                	je     8009a5 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800998:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099b:	fc                   	cld    
  80099c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80099e:	89 f8                	mov    %edi,%eax
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5f                   	pop    %edi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    
		c &= 0xFF;
  8009a5:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009a9:	89 d3                	mov    %edx,%ebx
  8009ab:	c1 e3 08             	shl    $0x8,%ebx
  8009ae:	89 d0                	mov    %edx,%eax
  8009b0:	c1 e0 18             	shl    $0x18,%eax
  8009b3:	89 d6                	mov    %edx,%esi
  8009b5:	c1 e6 10             	shl    $0x10,%esi
  8009b8:	09 f0                	or     %esi,%eax
  8009ba:	09 c2                	or     %eax,%edx
  8009bc:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009be:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009c1:	89 d0                	mov    %edx,%eax
  8009c3:	fc                   	cld    
  8009c4:	f3 ab                	rep stos %eax,%es:(%edi)
  8009c6:	eb d6                	jmp    80099e <memset+0x23>

008009c8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	57                   	push   %edi
  8009cc:	56                   	push   %esi
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d6:	39 c6                	cmp    %eax,%esi
  8009d8:	73 35                	jae    800a0f <memmove+0x47>
  8009da:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dd:	39 c2                	cmp    %eax,%edx
  8009df:	76 2e                	jbe    800a0f <memmove+0x47>
		s += n;
		d += n;
  8009e1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e4:	89 d6                	mov    %edx,%esi
  8009e6:	09 fe                	or     %edi,%esi
  8009e8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ee:	74 0c                	je     8009fc <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009f0:	83 ef 01             	sub    $0x1,%edi
  8009f3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009f6:	fd                   	std    
  8009f7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f9:	fc                   	cld    
  8009fa:	eb 21                	jmp    800a1d <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 ef                	jne    8009f0 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a01:	83 ef 04             	sub    $0x4,%edi
  800a04:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a07:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a0a:	fd                   	std    
  800a0b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a0d:	eb ea                	jmp    8009f9 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0f:	89 f2                	mov    %esi,%edx
  800a11:	09 c2                	or     %eax,%edx
  800a13:	f6 c2 03             	test   $0x3,%dl
  800a16:	74 09                	je     800a21 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a18:	89 c7                	mov    %eax,%edi
  800a1a:	fc                   	cld    
  800a1b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a1d:	5e                   	pop    %esi
  800a1e:	5f                   	pop    %edi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a21:	f6 c1 03             	test   $0x3,%cl
  800a24:	75 f2                	jne    800a18 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a26:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a29:	89 c7                	mov    %eax,%edi
  800a2b:	fc                   	cld    
  800a2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a2e:	eb ed                	jmp    800a1d <memmove+0x55>

00800a30 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a33:	ff 75 10             	pushl  0x10(%ebp)
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	ff 75 08             	pushl  0x8(%ebp)
  800a3c:	e8 87 ff ff ff       	call   8009c8 <memmove>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4e:	89 c6                	mov    %eax,%esi
  800a50:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a53:	39 f0                	cmp    %esi,%eax
  800a55:	74 1c                	je     800a73 <memcmp+0x30>
		if (*s1 != *s2)
  800a57:	0f b6 08             	movzbl (%eax),%ecx
  800a5a:	0f b6 1a             	movzbl (%edx),%ebx
  800a5d:	38 d9                	cmp    %bl,%cl
  800a5f:	75 08                	jne    800a69 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	83 c2 01             	add    $0x1,%edx
  800a67:	eb ea                	jmp    800a53 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a69:	0f b6 c1             	movzbl %cl,%eax
  800a6c:	0f b6 db             	movzbl %bl,%ebx
  800a6f:	29 d8                	sub    %ebx,%eax
  800a71:	eb 05                	jmp    800a78 <memcmp+0x35>
	}

	return 0;
  800a73:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a78:	5b                   	pop    %ebx
  800a79:	5e                   	pop    %esi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a85:	89 c2                	mov    %eax,%edx
  800a87:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a8a:	39 d0                	cmp    %edx,%eax
  800a8c:	73 09                	jae    800a97 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8e:	38 08                	cmp    %cl,(%eax)
  800a90:	74 05                	je     800a97 <memfind+0x1b>
	for (; s < ends; s++)
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	eb f3                	jmp    800a8a <memfind+0xe>
			break;
	return (void *) s;
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aa5:	eb 03                	jmp    800aaa <strtol+0x11>
		s++;
  800aa7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aaa:	0f b6 01             	movzbl (%ecx),%eax
  800aad:	3c 20                	cmp    $0x20,%al
  800aaf:	74 f6                	je     800aa7 <strtol+0xe>
  800ab1:	3c 09                	cmp    $0x9,%al
  800ab3:	74 f2                	je     800aa7 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ab5:	3c 2b                	cmp    $0x2b,%al
  800ab7:	74 2e                	je     800ae7 <strtol+0x4e>
	int neg = 0;
  800ab9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800abe:	3c 2d                	cmp    $0x2d,%al
  800ac0:	74 2f                	je     800af1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ac8:	75 05                	jne    800acf <strtol+0x36>
  800aca:	80 39 30             	cmpb   $0x30,(%ecx)
  800acd:	74 2c                	je     800afb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800acf:	85 db                	test   %ebx,%ebx
  800ad1:	75 0a                	jne    800add <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ad3:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ad8:	80 39 30             	cmpb   $0x30,(%ecx)
  800adb:	74 28                	je     800b05 <strtol+0x6c>
		base = 10;
  800add:	b8 00 00 00 00       	mov    $0x0,%eax
  800ae2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ae5:	eb 50                	jmp    800b37 <strtol+0x9e>
		s++;
  800ae7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800aea:	bf 00 00 00 00       	mov    $0x0,%edi
  800aef:	eb d1                	jmp    800ac2 <strtol+0x29>
		s++, neg = 1;
  800af1:	83 c1 01             	add    $0x1,%ecx
  800af4:	bf 01 00 00 00       	mov    $0x1,%edi
  800af9:	eb c7                	jmp    800ac2 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800afb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aff:	74 0e                	je     800b0f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b01:	85 db                	test   %ebx,%ebx
  800b03:	75 d8                	jne    800add <strtol+0x44>
		s++, base = 8;
  800b05:	83 c1 01             	add    $0x1,%ecx
  800b08:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b0d:	eb ce                	jmp    800add <strtol+0x44>
		s += 2, base = 16;
  800b0f:	83 c1 02             	add    $0x2,%ecx
  800b12:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b17:	eb c4                	jmp    800add <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b19:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 19             	cmp    $0x19,%bl
  800b21:	77 29                	ja     800b4c <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b29:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b2c:	7d 30                	jge    800b5e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b2e:	83 c1 01             	add    $0x1,%ecx
  800b31:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b35:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b37:	0f b6 11             	movzbl (%ecx),%edx
  800b3a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b3d:	89 f3                	mov    %esi,%ebx
  800b3f:	80 fb 09             	cmp    $0x9,%bl
  800b42:	77 d5                	ja     800b19 <strtol+0x80>
			dig = *s - '0';
  800b44:	0f be d2             	movsbl %dl,%edx
  800b47:	83 ea 30             	sub    $0x30,%edx
  800b4a:	eb dd                	jmp    800b29 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b4c:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b4f:	89 f3                	mov    %esi,%ebx
  800b51:	80 fb 19             	cmp    $0x19,%bl
  800b54:	77 08                	ja     800b5e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b56:	0f be d2             	movsbl %dl,%edx
  800b59:	83 ea 37             	sub    $0x37,%edx
  800b5c:	eb cb                	jmp    800b29 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b5e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b62:	74 05                	je     800b69 <strtol+0xd0>
		*endptr = (char *) s;
  800b64:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b67:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b69:	89 c2                	mov    %eax,%edx
  800b6b:	f7 da                	neg    %edx
  800b6d:	85 ff                	test   %edi,%edi
  800b6f:	0f 45 c2             	cmovne %edx,%eax
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b82:	8b 55 08             	mov    0x8(%ebp),%edx
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b88:	89 c3                	mov    %eax,%ebx
  800b8a:	89 c7                	mov    %eax,%edi
  800b8c:	89 c6                	mov    %eax,%esi
  800b8e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba0:	b8 01 00 00 00       	mov    $0x1,%eax
  800ba5:	89 d1                	mov    %edx,%ecx
  800ba7:	89 d3                	mov    %edx,%ebx
  800ba9:	89 d7                	mov    %edx,%edi
  800bab:	89 d6                	mov    %edx,%esi
  800bad:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800baf:	5b                   	pop    %ebx
  800bb0:	5e                   	pop    %esi
  800bb1:	5f                   	pop    %edi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	57                   	push   %edi
  800bb8:	56                   	push   %esi
  800bb9:	53                   	push   %ebx
  800bba:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bbd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc5:	b8 03 00 00 00       	mov    $0x3,%eax
  800bca:	89 cb                	mov    %ecx,%ebx
  800bcc:	89 cf                	mov    %ecx,%edi
  800bce:	89 ce                	mov    %ecx,%esi
  800bd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	7f 08                	jg     800bde <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 03                	push   $0x3
  800be4:	68 44 16 80 00       	push   $0x801644
  800be9:	6a 23                	push   $0x23
  800beb:	68 61 16 80 00       	push   $0x801661
  800bf0:	e8 4b f5 ff ff       	call   800140 <_panic>

00800bf5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfb:	ba 00 00 00 00       	mov    $0x0,%edx
  800c00:	b8 02 00 00 00       	mov    $0x2,%eax
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 d3                	mov    %edx,%ebx
  800c09:	89 d7                	mov    %edx,%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <sys_yield>:

void
sys_yield(void)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c24:	89 d1                	mov    %edx,%ecx
  800c26:	89 d3                	mov    %edx,%ebx
  800c28:	89 d7                	mov    %edx,%edi
  800c2a:	89 d6                	mov    %edx,%esi
  800c2c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	be 00 00 00 00       	mov    $0x0,%esi
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4f:	89 f7                	mov    %esi,%edi
  800c51:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7f 08                	jg     800c5f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5f:	83 ec 0c             	sub    $0xc,%esp
  800c62:	50                   	push   %eax
  800c63:	6a 04                	push   $0x4
  800c65:	68 44 16 80 00       	push   $0x801644
  800c6a:	6a 23                	push   $0x23
  800c6c:	68 61 16 80 00       	push   $0x801661
  800c71:	e8 ca f4 ff ff       	call   800140 <_panic>

00800c76 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	b8 05 00 00 00       	mov    $0x5,%eax
  800c8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c8d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c90:	8b 75 18             	mov    0x18(%ebp),%esi
  800c93:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7f 08                	jg     800ca1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c99:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5f                   	pop    %edi
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	50                   	push   %eax
  800ca5:	6a 05                	push   $0x5
  800ca7:	68 44 16 80 00       	push   $0x801644
  800cac:	6a 23                	push   $0x23
  800cae:	68 61 16 80 00       	push   $0x801661
  800cb3:	e8 88 f4 ff ff       	call   800140 <_panic>

00800cb8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccc:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7f 08                	jg     800ce3 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5f                   	pop    %edi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	50                   	push   %eax
  800ce7:	6a 06                	push   $0x6
  800ce9:	68 44 16 80 00       	push   $0x801644
  800cee:	6a 23                	push   $0x23
  800cf0:	68 61 16 80 00       	push   $0x801661
  800cf5:	e8 46 f4 ff ff       	call   800140 <_panic>

00800cfa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7f 08                	jg     800d25 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d25:	83 ec 0c             	sub    $0xc,%esp
  800d28:	50                   	push   %eax
  800d29:	6a 08                	push   $0x8
  800d2b:	68 44 16 80 00       	push   $0x801644
  800d30:	6a 23                	push   $0x23
  800d32:	68 61 16 80 00       	push   $0x801661
  800d37:	e8 04 f4 ff ff       	call   800140 <_panic>

00800d3c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
  800d42:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d50:	b8 09 00 00 00       	mov    $0x9,%eax
  800d55:	89 df                	mov    %ebx,%edi
  800d57:	89 de                	mov    %ebx,%esi
  800d59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7f 08                	jg     800d67 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	50                   	push   %eax
  800d6b:	6a 09                	push   $0x9
  800d6d:	68 44 16 80 00       	push   $0x801644
  800d72:	6a 23                	push   $0x23
  800d74:	68 61 16 80 00       	push   $0x801661
  800d79:	e8 c2 f3 ff ff       	call   800140 <_panic>

00800d7e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d84:	8b 55 08             	mov    0x8(%ebp),%edx
  800d87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d8a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d8f:	be 00 00 00 00       	mov    $0x0,%esi
  800d94:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d9a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5f                   	pop    %edi
  800d9f:	5d                   	pop    %ebp
  800da0:	c3                   	ret    

00800da1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	57                   	push   %edi
  800da5:	56                   	push   %esi
  800da6:	53                   	push   %ebx
  800da7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800daa:	b9 00 00 00 00       	mov    $0x0,%ecx
  800daf:	8b 55 08             	mov    0x8(%ebp),%edx
  800db2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800db7:	89 cb                	mov    %ecx,%ebx
  800db9:	89 cf                	mov    %ecx,%edi
  800dbb:	89 ce                	mov    %ecx,%esi
  800dbd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7f 08                	jg     800dcb <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcb:	83 ec 0c             	sub    $0xc,%esp
  800dce:	50                   	push   %eax
  800dcf:	6a 0c                	push   $0xc
  800dd1:	68 44 16 80 00       	push   $0x801644
  800dd6:	6a 23                	push   $0x23
  800dd8:	68 61 16 80 00       	push   $0x801661
  800ddd:	e8 5e f3 ff ff       	call   800140 <_panic>

00800de2 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	53                   	push   %ebx
  800de6:	83 ec 04             	sub    $0x4,%esp
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  800dec:	8b 02                	mov    (%edx),%eax
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if (!((err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)))
  800dee:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800df2:	0f 84 9c 00 00 00    	je     800e94 <pgfault+0xb2>
  800df8:	89 c2                	mov    %eax,%edx
  800dfa:	c1 ea 16             	shr    $0x16,%edx
  800dfd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e04:	f6 c2 01             	test   $0x1,%dl
  800e07:	0f 84 87 00 00 00    	je     800e94 <pgfault+0xb2>
  800e0d:	89 c2                	mov    %eax,%edx
  800e0f:	c1 ea 0c             	shr    $0xc,%edx
  800e12:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
  800e19:	f6 c1 01             	test   $0x1,%cl
  800e1c:	74 76                	je     800e94 <pgfault+0xb2>
  800e1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e25:	f6 c6 08             	test   $0x8,%dh
  800e28:	74 6a                	je     800e94 <pgfault+0xb2>
		panic("not copy-on-write");
	addr = ROUNDDOWN(addr, PGSIZE);
  800e2a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e2f:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800e31:	83 ec 04             	sub    $0x4,%esp
  800e34:	6a 07                	push   $0x7
  800e36:	68 00 f0 7f 00       	push   $0x7ff000
  800e3b:	6a 00                	push   $0x0
  800e3d:	e8 f1 fd ff ff       	call   800c33 <sys_page_alloc>
  800e42:	83 c4 10             	add    $0x10,%esp
  800e45:	85 c0                	test   %eax,%eax
  800e47:	78 5f                	js     800ea8 <pgfault+0xc6>
		panic("sys_page_alloc");
	memcpy(PFTEMP, addr, PGSIZE);
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	68 00 10 00 00       	push   $0x1000
  800e51:	53                   	push   %ebx
  800e52:	68 00 f0 7f 00       	push   $0x7ff000
  800e57:	e8 d4 fb ff ff       	call   800a30 <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800e5c:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e63:	53                   	push   %ebx
  800e64:	6a 00                	push   $0x0
  800e66:	68 00 f0 7f 00       	push   $0x7ff000
  800e6b:	6a 00                	push   $0x0
  800e6d:	e8 04 fe ff ff       	call   800c76 <sys_page_map>
  800e72:	83 c4 20             	add    $0x20,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 43                	js     800ebc <pgfault+0xda>
		panic("sys_page_map");
	if (sys_page_unmap(0, PFTEMP) < 0)
  800e79:	83 ec 08             	sub    $0x8,%esp
  800e7c:	68 00 f0 7f 00       	push   $0x7ff000
  800e81:	6a 00                	push   $0x0
  800e83:	e8 30 fe ff ff       	call   800cb8 <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	85 c0                	test   %eax,%eax
  800e8d:	78 41                	js     800ed0 <pgfault+0xee>
		panic("sys_page_unmap");
	return;
}
  800e8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    
		panic("not copy-on-write");
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	68 6f 16 80 00       	push   $0x80166f
  800e9c:	6a 25                	push   $0x25
  800e9e:	68 81 16 80 00       	push   $0x801681
  800ea3:	e8 98 f2 ff ff       	call   800140 <_panic>
		panic("sys_page_alloc");
  800ea8:	83 ec 04             	sub    $0x4,%esp
  800eab:	68 8c 16 80 00       	push   $0x80168c
  800eb0:	6a 28                	push   $0x28
  800eb2:	68 81 16 80 00       	push   $0x801681
  800eb7:	e8 84 f2 ff ff       	call   800140 <_panic>
		panic("sys_page_map");
  800ebc:	83 ec 04             	sub    $0x4,%esp
  800ebf:	68 9b 16 80 00       	push   $0x80169b
  800ec4:	6a 2b                	push   $0x2b
  800ec6:	68 81 16 80 00       	push   $0x801681
  800ecb:	e8 70 f2 ff ff       	call   800140 <_panic>
		panic("sys_page_unmap");
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	68 a8 16 80 00       	push   $0x8016a8
  800ed8:	6a 2d                	push   $0x2d
  800eda:	68 81 16 80 00       	push   $0x801681
  800edf:	e8 5c f2 ff ff       	call   800140 <_panic>

00800ee4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ee4:	55                   	push   %ebp
  800ee5:	89 e5                	mov    %esp,%ebp
  800ee7:	57                   	push   %edi
  800ee8:	56                   	push   %esi
  800ee9:	53                   	push   %ebx
  800eea:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	set_pgfault_handler(pgfault);
  800eed:	68 e2 0d 80 00       	push   $0x800de2
  800ef2:	e8 b4 01 00 00       	call   8010ab <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ef7:	b8 07 00 00 00       	mov    $0x7,%eax
  800efc:	cd 30                	int    $0x30
  800efe:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  800f01:	83 c4 10             	add    $0x10,%esp
  800f04:	85 c0                	test   %eax,%eax
  800f06:	74 0f                	je     800f17 <fork+0x33>
  800f08:	89 c7                	mov    %eax,%edi
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	if (envid < 0)
  800f0a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f0e:	78 23                	js     800f33 <fork+0x4f>
		panic("sys_exofork: %e", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f15:	eb 7d                	jmp    800f94 <fork+0xb0>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f17:	e8 d9 fc ff ff       	call   800bf5 <sys_getenvid>
  800f1c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f21:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f24:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f29:	a3 08 20 80 00       	mov    %eax,0x802008
		return 0;
  800f2e:	e9 2b 01 00 00       	jmp    80105e <fork+0x17a>
		panic("sys_exofork: %e", envid);
  800f33:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f36:	68 b7 16 80 00       	push   $0x8016b7
  800f3b:	6a 6b                	push   $0x6b
  800f3d:	68 81 16 80 00       	push   $0x801681
  800f42:	e8 f9 f1 ff ff       	call   800140 <_panic>
		if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f47:	83 ec 0c             	sub    $0xc,%esp
  800f4a:	68 05 08 00 00       	push   $0x805
  800f4f:	56                   	push   %esi
  800f50:	57                   	push   %edi
  800f51:	56                   	push   %esi
  800f52:	6a 00                	push   $0x0
  800f54:	e8 1d fd ff ff       	call   800c76 <sys_page_map>
  800f59:	83 c4 20             	add    $0x20,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	0f 88 96 00 00 00    	js     800ffa <fork+0x116>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  800f64:	83 ec 0c             	sub    $0xc,%esp
  800f67:	68 05 08 00 00       	push   $0x805
  800f6c:	56                   	push   %esi
  800f6d:	6a 00                	push   $0x0
  800f6f:	56                   	push   %esi
  800f70:	6a 00                	push   $0x0
  800f72:	e8 ff fc ff ff       	call   800c76 <sys_page_map>
  800f77:	83 c4 20             	add    $0x20,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	0f 88 8c 00 00 00    	js     80100e <fork+0x12a>
	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  800f82:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f88:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f8e:	0f 84 8e 00 00 00    	je     801022 <fork+0x13e>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  800f94:	89 d8                	mov    %ebx,%eax
  800f96:	c1 e8 16             	shr    $0x16,%eax
  800f99:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa0:	a8 01                	test   $0x1,%al
  800fa2:	74 de                	je     800f82 <fork+0x9e>
  800fa4:	89 d8                	mov    %ebx,%eax
  800fa6:	c1 e8 0c             	shr    $0xc,%eax
  800fa9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb0:	f6 c2 01             	test   $0x1,%dl
  800fb3:	74 cd                	je     800f82 <fork+0x9e>
			&& (uvpt[PGNUM(addr)] & PTE_U)) {
  800fb5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fbc:	f6 c2 04             	test   $0x4,%dl
  800fbf:	74 c1                	je     800f82 <fork+0x9e>
	void *addr = (void*) (pn*PGSIZE);
  800fc1:	89 c6                	mov    %eax,%esi
  800fc3:	c1 e6 0c             	shl    $0xc,%esi
	if ((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)) {
  800fc6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fcd:	f6 c2 02             	test   $0x2,%dl
  800fd0:	0f 85 71 ff ff ff    	jne    800f47 <fork+0x63>
  800fd6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fdd:	f6 c4 08             	test   $0x8,%ah
  800fe0:	0f 85 61 ff ff ff    	jne    800f47 <fork+0x63>
		sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  800fe6:	83 ec 0c             	sub    $0xc,%esp
  800fe9:	6a 05                	push   $0x5
  800feb:	56                   	push   %esi
  800fec:	57                   	push   %edi
  800fed:	56                   	push   %esi
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 81 fc ff ff       	call   800c76 <sys_page_map>
  800ff5:	83 c4 20             	add    $0x20,%esp
  800ff8:	eb 88                	jmp    800f82 <fork+0x9e>
			panic("2");
  800ffa:	83 ec 04             	sub    $0x4,%esp
  800ffd:	68 c7 16 80 00       	push   $0x8016c7
  801002:	6a 45                	push   $0x45
  801004:	68 81 16 80 00       	push   $0x801681
  801009:	e8 32 f1 ff ff       	call   800140 <_panic>
			panic("3");
  80100e:	83 ec 04             	sub    $0x4,%esp
  801011:	68 c9 16 80 00       	push   $0x8016c9
  801016:	6a 47                	push   $0x47
  801018:	68 81 16 80 00       	push   $0x801681
  80101d:	e8 1e f1 ff ff       	call   800140 <_panic>
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	6a 07                	push   $0x7
  801027:	68 00 f0 bf ee       	push   $0xeebff000
  80102c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80102f:	e8 ff fb ff ff       	call   800c33 <sys_page_alloc>
  801034:	83 c4 10             	add    $0x10,%esp
  801037:	85 c0                	test   %eax,%eax
  801039:	78 2e                	js     801069 <fork+0x185>
		panic("1");
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80103b:	83 ec 08             	sub    $0x8,%esp
  80103e:	68 1a 11 80 00       	push   $0x80111a
  801043:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801046:	57                   	push   %edi
  801047:	e8 f0 fc ff ff       	call   800d3c <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	6a 02                	push   $0x2
  801051:	57                   	push   %edi
  801052:	e8 a3 fc ff ff       	call   800cfa <sys_env_set_status>
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 1f                	js     80107d <fork+0x199>
		panic("sys_env_set_status");

	return envid;
	panic("fork not implemented");
}
  80105e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801061:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801064:	5b                   	pop    %ebx
  801065:	5e                   	pop    %esi
  801066:	5f                   	pop    %edi
  801067:	5d                   	pop    %ebp
  801068:	c3                   	ret    
		panic("1");
  801069:	83 ec 04             	sub    $0x4,%esp
  80106c:	68 cb 16 80 00       	push   $0x8016cb
  801071:	6a 74                	push   $0x74
  801073:	68 81 16 80 00       	push   $0x801681
  801078:	e8 c3 f0 ff ff       	call   800140 <_panic>
		panic("sys_env_set_status");
  80107d:	83 ec 04             	sub    $0x4,%esp
  801080:	68 cd 16 80 00       	push   $0x8016cd
  801085:	6a 79                	push   $0x79
  801087:	68 81 16 80 00       	push   $0x801681
  80108c:	e8 af f0 ff ff       	call   800140 <_panic>

00801091 <sfork>:

// Challenge!
int
sfork(void)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801097:	68 e0 16 80 00       	push   $0x8016e0
  80109c:	68 83 00 00 00       	push   $0x83
  8010a1:	68 81 16 80 00       	push   $0x801681
  8010a6:	e8 95 f0 ff ff       	call   800140 <_panic>

008010ab <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8010b1:	83 3d 0c 20 80 00 00 	cmpl   $0x0,0x80200c
  8010b8:	74 20                	je     8010da <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bd:	a3 0c 20 80 00       	mov    %eax,0x80200c
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8010c2:	83 ec 08             	sub    $0x8,%esp
  8010c5:	68 1a 11 80 00       	push   $0x80111a
  8010ca:	6a 00                	push   $0x0
  8010cc:	e8 6b fc ff ff       	call   800d3c <sys_env_set_pgfault_upcall>
  8010d1:	83 c4 10             	add    $0x10,%esp
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	78 2e                	js     801106 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  8010d8:	c9                   	leave  
  8010d9:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	6a 07                	push   $0x7
  8010df:	68 00 f0 bf ee       	push   $0xeebff000
  8010e4:	6a 00                	push   $0x0
  8010e6:	e8 48 fb ff ff       	call   800c33 <sys_page_alloc>
  8010eb:	83 c4 10             	add    $0x10,%esp
  8010ee:	85 c0                	test   %eax,%eax
  8010f0:	79 c8                	jns    8010ba <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  8010f2:	83 ec 04             	sub    $0x4,%esp
  8010f5:	68 f8 16 80 00       	push   $0x8016f8
  8010fa:	6a 21                	push   $0x21
  8010fc:	68 5c 17 80 00       	push   $0x80175c
  801101:	e8 3a f0 ff ff       	call   800140 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801106:	83 ec 04             	sub    $0x4,%esp
  801109:	68 24 17 80 00       	push   $0x801724
  80110e:	6a 27                	push   $0x27
  801110:	68 5c 17 80 00       	push   $0x80175c
  801115:	e8 26 f0 ff ff       	call   800140 <_panic>

0080111a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80111a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80111b:	a1 0c 20 80 00       	mov    0x80200c,%eax
	call *%eax
  801120:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801122:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801125:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801129:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80112c:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  801130:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801134:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801136:	83 c4 08             	add    $0x8,%esp
	popal
  801139:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  80113a:	83 c4 04             	add    $0x4,%esp
	popfl
  80113d:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80113e:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80113f:	c3                   	ret    

00801140 <__udivdi3>:
  801140:	55                   	push   %ebp
  801141:	57                   	push   %edi
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 1c             	sub    $0x1c,%esp
  801147:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80114b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80114f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801153:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801157:	85 d2                	test   %edx,%edx
  801159:	75 35                	jne    801190 <__udivdi3+0x50>
  80115b:	39 f3                	cmp    %esi,%ebx
  80115d:	0f 87 bd 00 00 00    	ja     801220 <__udivdi3+0xe0>
  801163:	85 db                	test   %ebx,%ebx
  801165:	89 d9                	mov    %ebx,%ecx
  801167:	75 0b                	jne    801174 <__udivdi3+0x34>
  801169:	b8 01 00 00 00       	mov    $0x1,%eax
  80116e:	31 d2                	xor    %edx,%edx
  801170:	f7 f3                	div    %ebx
  801172:	89 c1                	mov    %eax,%ecx
  801174:	31 d2                	xor    %edx,%edx
  801176:	89 f0                	mov    %esi,%eax
  801178:	f7 f1                	div    %ecx
  80117a:	89 c6                	mov    %eax,%esi
  80117c:	89 e8                	mov    %ebp,%eax
  80117e:	89 f7                	mov    %esi,%edi
  801180:	f7 f1                	div    %ecx
  801182:	89 fa                	mov    %edi,%edx
  801184:	83 c4 1c             	add    $0x1c,%esp
  801187:	5b                   	pop    %ebx
  801188:	5e                   	pop    %esi
  801189:	5f                   	pop    %edi
  80118a:	5d                   	pop    %ebp
  80118b:	c3                   	ret    
  80118c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801190:	39 f2                	cmp    %esi,%edx
  801192:	77 7c                	ja     801210 <__udivdi3+0xd0>
  801194:	0f bd fa             	bsr    %edx,%edi
  801197:	83 f7 1f             	xor    $0x1f,%edi
  80119a:	0f 84 98 00 00 00    	je     801238 <__udivdi3+0xf8>
  8011a0:	89 f9                	mov    %edi,%ecx
  8011a2:	b8 20 00 00 00       	mov    $0x20,%eax
  8011a7:	29 f8                	sub    %edi,%eax
  8011a9:	d3 e2                	shl    %cl,%edx
  8011ab:	89 54 24 08          	mov    %edx,0x8(%esp)
  8011af:	89 c1                	mov    %eax,%ecx
  8011b1:	89 da                	mov    %ebx,%edx
  8011b3:	d3 ea                	shr    %cl,%edx
  8011b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8011b9:	09 d1                	or     %edx,%ecx
  8011bb:	89 f2                	mov    %esi,%edx
  8011bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011c1:	89 f9                	mov    %edi,%ecx
  8011c3:	d3 e3                	shl    %cl,%ebx
  8011c5:	89 c1                	mov    %eax,%ecx
  8011c7:	d3 ea                	shr    %cl,%edx
  8011c9:	89 f9                	mov    %edi,%ecx
  8011cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8011cf:	d3 e6                	shl    %cl,%esi
  8011d1:	89 eb                	mov    %ebp,%ebx
  8011d3:	89 c1                	mov    %eax,%ecx
  8011d5:	d3 eb                	shr    %cl,%ebx
  8011d7:	09 de                	or     %ebx,%esi
  8011d9:	89 f0                	mov    %esi,%eax
  8011db:	f7 74 24 08          	divl   0x8(%esp)
  8011df:	89 d6                	mov    %edx,%esi
  8011e1:	89 c3                	mov    %eax,%ebx
  8011e3:	f7 64 24 0c          	mull   0xc(%esp)
  8011e7:	39 d6                	cmp    %edx,%esi
  8011e9:	72 0c                	jb     8011f7 <__udivdi3+0xb7>
  8011eb:	89 f9                	mov    %edi,%ecx
  8011ed:	d3 e5                	shl    %cl,%ebp
  8011ef:	39 c5                	cmp    %eax,%ebp
  8011f1:	73 5d                	jae    801250 <__udivdi3+0x110>
  8011f3:	39 d6                	cmp    %edx,%esi
  8011f5:	75 59                	jne    801250 <__udivdi3+0x110>
  8011f7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8011fa:	31 ff                	xor    %edi,%edi
  8011fc:	89 fa                	mov    %edi,%edx
  8011fe:	83 c4 1c             	add    $0x1c,%esp
  801201:	5b                   	pop    %ebx
  801202:	5e                   	pop    %esi
  801203:	5f                   	pop    %edi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    
  801206:	8d 76 00             	lea    0x0(%esi),%esi
  801209:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801210:	31 ff                	xor    %edi,%edi
  801212:	31 c0                	xor    %eax,%eax
  801214:	89 fa                	mov    %edi,%edx
  801216:	83 c4 1c             	add    $0x1c,%esp
  801219:	5b                   	pop    %ebx
  80121a:	5e                   	pop    %esi
  80121b:	5f                   	pop    %edi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    
  80121e:	66 90                	xchg   %ax,%ax
  801220:	31 ff                	xor    %edi,%edi
  801222:	89 e8                	mov    %ebp,%eax
  801224:	89 f2                	mov    %esi,%edx
  801226:	f7 f3                	div    %ebx
  801228:	89 fa                	mov    %edi,%edx
  80122a:	83 c4 1c             	add    $0x1c,%esp
  80122d:	5b                   	pop    %ebx
  80122e:	5e                   	pop    %esi
  80122f:	5f                   	pop    %edi
  801230:	5d                   	pop    %ebp
  801231:	c3                   	ret    
  801232:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801238:	39 f2                	cmp    %esi,%edx
  80123a:	72 06                	jb     801242 <__udivdi3+0x102>
  80123c:	31 c0                	xor    %eax,%eax
  80123e:	39 eb                	cmp    %ebp,%ebx
  801240:	77 d2                	ja     801214 <__udivdi3+0xd4>
  801242:	b8 01 00 00 00       	mov    $0x1,%eax
  801247:	eb cb                	jmp    801214 <__udivdi3+0xd4>
  801249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 d8                	mov    %ebx,%eax
  801252:	31 ff                	xor    %edi,%edi
  801254:	eb be                	jmp    801214 <__udivdi3+0xd4>
  801256:	66 90                	xchg   %ax,%ax
  801258:	66 90                	xchg   %ax,%ax
  80125a:	66 90                	xchg   %ax,%ax
  80125c:	66 90                	xchg   %ax,%ax
  80125e:	66 90                	xchg   %ax,%ax

00801260 <__umoddi3>:
  801260:	55                   	push   %ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 1c             	sub    $0x1c,%esp
  801267:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80126b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80126f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801273:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801277:	85 ed                	test   %ebp,%ebp
  801279:	89 f0                	mov    %esi,%eax
  80127b:	89 da                	mov    %ebx,%edx
  80127d:	75 19                	jne    801298 <__umoddi3+0x38>
  80127f:	39 df                	cmp    %ebx,%edi
  801281:	0f 86 b1 00 00 00    	jbe    801338 <__umoddi3+0xd8>
  801287:	f7 f7                	div    %edi
  801289:	89 d0                	mov    %edx,%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	83 c4 1c             	add    $0x1c,%esp
  801290:	5b                   	pop    %ebx
  801291:	5e                   	pop    %esi
  801292:	5f                   	pop    %edi
  801293:	5d                   	pop    %ebp
  801294:	c3                   	ret    
  801295:	8d 76 00             	lea    0x0(%esi),%esi
  801298:	39 dd                	cmp    %ebx,%ebp
  80129a:	77 f1                	ja     80128d <__umoddi3+0x2d>
  80129c:	0f bd cd             	bsr    %ebp,%ecx
  80129f:	83 f1 1f             	xor    $0x1f,%ecx
  8012a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8012a6:	0f 84 b4 00 00 00    	je     801360 <__umoddi3+0x100>
  8012ac:	b8 20 00 00 00       	mov    $0x20,%eax
  8012b1:	89 c2                	mov    %eax,%edx
  8012b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012b7:	29 c2                	sub    %eax,%edx
  8012b9:	89 c1                	mov    %eax,%ecx
  8012bb:	89 f8                	mov    %edi,%eax
  8012bd:	d3 e5                	shl    %cl,%ebp
  8012bf:	89 d1                	mov    %edx,%ecx
  8012c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8012c5:	d3 e8                	shr    %cl,%eax
  8012c7:	09 c5                	or     %eax,%ebp
  8012c9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8012cd:	89 c1                	mov    %eax,%ecx
  8012cf:	d3 e7                	shl    %cl,%edi
  8012d1:	89 d1                	mov    %edx,%ecx
  8012d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012d7:	89 df                	mov    %ebx,%edi
  8012d9:	d3 ef                	shr    %cl,%edi
  8012db:	89 c1                	mov    %eax,%ecx
  8012dd:	89 f0                	mov    %esi,%eax
  8012df:	d3 e3                	shl    %cl,%ebx
  8012e1:	89 d1                	mov    %edx,%ecx
  8012e3:	89 fa                	mov    %edi,%edx
  8012e5:	d3 e8                	shr    %cl,%eax
  8012e7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8012ec:	09 d8                	or     %ebx,%eax
  8012ee:	f7 f5                	div    %ebp
  8012f0:	d3 e6                	shl    %cl,%esi
  8012f2:	89 d1                	mov    %edx,%ecx
  8012f4:	f7 64 24 08          	mull   0x8(%esp)
  8012f8:	39 d1                	cmp    %edx,%ecx
  8012fa:	89 c3                	mov    %eax,%ebx
  8012fc:	89 d7                	mov    %edx,%edi
  8012fe:	72 06                	jb     801306 <__umoddi3+0xa6>
  801300:	75 0e                	jne    801310 <__umoddi3+0xb0>
  801302:	39 c6                	cmp    %eax,%esi
  801304:	73 0a                	jae    801310 <__umoddi3+0xb0>
  801306:	2b 44 24 08          	sub    0x8(%esp),%eax
  80130a:	19 ea                	sbb    %ebp,%edx
  80130c:	89 d7                	mov    %edx,%edi
  80130e:	89 c3                	mov    %eax,%ebx
  801310:	89 ca                	mov    %ecx,%edx
  801312:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801317:	29 de                	sub    %ebx,%esi
  801319:	19 fa                	sbb    %edi,%edx
  80131b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80131f:	89 d0                	mov    %edx,%eax
  801321:	d3 e0                	shl    %cl,%eax
  801323:	89 d9                	mov    %ebx,%ecx
  801325:	d3 ee                	shr    %cl,%esi
  801327:	d3 ea                	shr    %cl,%edx
  801329:	09 f0                	or     %esi,%eax
  80132b:	83 c4 1c             	add    $0x1c,%esp
  80132e:	5b                   	pop    %ebx
  80132f:	5e                   	pop    %esi
  801330:	5f                   	pop    %edi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    
  801333:	90                   	nop
  801334:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801338:	85 ff                	test   %edi,%edi
  80133a:	89 f9                	mov    %edi,%ecx
  80133c:	75 0b                	jne    801349 <__umoddi3+0xe9>
  80133e:	b8 01 00 00 00       	mov    $0x1,%eax
  801343:	31 d2                	xor    %edx,%edx
  801345:	f7 f7                	div    %edi
  801347:	89 c1                	mov    %eax,%ecx
  801349:	89 d8                	mov    %ebx,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f1                	div    %ecx
  80134f:	89 f0                	mov    %esi,%eax
  801351:	f7 f1                	div    %ecx
  801353:	e9 31 ff ff ff       	jmp    801289 <__umoddi3+0x29>
  801358:	90                   	nop
  801359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801360:	39 dd                	cmp    %ebx,%ebp
  801362:	72 08                	jb     80136c <__umoddi3+0x10c>
  801364:	39 f7                	cmp    %esi,%edi
  801366:	0f 87 21 ff ff ff    	ja     80128d <__umoddi3+0x2d>
  80136c:	89 da                	mov    %ebx,%edx
  80136e:	89 f0                	mov    %esi,%eax
  801370:	29 f8                	sub    %edi,%eax
  801372:	19 ea                	sbb    %ebp,%edx
  801374:	e9 14 ff ff ff       	jmp    80128d <__umoddi3+0x2d>
