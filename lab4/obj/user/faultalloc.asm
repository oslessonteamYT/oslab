
obj/user/faultalloc：     文件格式 elf32-i386


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
  80002c:	e8 99 00 00 00       	call   8000ca <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003a:	8b 45 08             	mov    0x8(%ebp),%eax
  80003d:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80003f:	53                   	push   %ebx
  800040:	68 a0 10 80 00       	push   $0x8010a0
  800045:	e8 b3 01 00 00       	call   8001fd <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 b7 0b 00 00       	call   800c15 <sys_page_alloc>
  80005e:	83 c4 10             	add    $0x10,%esp
  800061:	85 c0                	test   %eax,%eax
  800063:	78 16                	js     80007b <handler+0x48>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800065:	53                   	push   %ebx
  800066:	68 ec 10 80 00       	push   $0x8010ec
  80006b:	6a 64                	push   $0x64
  80006d:	53                   	push   %ebx
  80006e:	e8 58 07 00 00       	call   8007cb <snprintf>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007b:	83 ec 0c             	sub    $0xc,%esp
  80007e:	50                   	push   %eax
  80007f:	53                   	push   %ebx
  800080:	68 c0 10 80 00       	push   $0x8010c0
  800085:	6a 0e                	push   $0xe
  800087:	68 aa 10 80 00       	push   $0x8010aa
  80008c:	e8 91 00 00 00       	call   800122 <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 23 0d 00 00       	call   800dc4 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	68 ef be ad de       	push   $0xdeadbeef
  8000a9:	68 bc 10 80 00       	push   $0x8010bc
  8000ae:	e8 4a 01 00 00       	call   8001fd <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000b3:	83 c4 08             	add    $0x8,%esp
  8000b6:	68 fe bf fe ca       	push   $0xcafebffe
  8000bb:	68 bc 10 80 00       	push   $0x8010bc
  8000c0:	e8 38 01 00 00       	call   8001fd <cprintf>
}
  8000c5:	83 c4 10             	add    $0x10,%esp
  8000c8:	c9                   	leave  
  8000c9:	c3                   	ret    

008000ca <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000d5:	e8 fd 0a 00 00       	call   800bd7 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000da:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000df:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e7:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ec:	85 db                	test   %ebx,%ebx
  8000ee:	7e 07                	jle    8000f7 <libmain+0x2d>
		binaryname = argv[0];
  8000f0:	8b 06                	mov    (%esi),%eax
  8000f2:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	56                   	push   %esi
  8000fb:	53                   	push   %ebx
  8000fc:	e8 90 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  800101:	e8 0a 00 00 00       	call   800110 <exit>
}
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5d                   	pop    %ebp
  80010f:	c3                   	ret    

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800116:	6a 00                	push   $0x0
  800118:	e8 79 0a 00 00       	call   800b96 <sys_env_destroy>
}
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	56                   	push   %esi
  800126:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800127:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80012a:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800130:	e8 a2 0a 00 00       	call   800bd7 <sys_getenvid>
  800135:	83 ec 0c             	sub    $0xc,%esp
  800138:	ff 75 0c             	pushl  0xc(%ebp)
  80013b:	ff 75 08             	pushl  0x8(%ebp)
  80013e:	56                   	push   %esi
  80013f:	50                   	push   %eax
  800140:	68 18 11 80 00       	push   $0x801118
  800145:	e8 b3 00 00 00       	call   8001fd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80014a:	83 c4 18             	add    $0x18,%esp
  80014d:	53                   	push   %ebx
  80014e:	ff 75 10             	pushl  0x10(%ebp)
  800151:	e8 56 00 00 00       	call   8001ac <vcprintf>
	cprintf("\n");
  800156:	c7 04 24 be 10 80 00 	movl   $0x8010be,(%esp)
  80015d:	e8 9b 00 00 00       	call   8001fd <cprintf>
  800162:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800165:	cc                   	int3   
  800166:	eb fd                	jmp    800165 <_panic+0x43>

00800168 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	53                   	push   %ebx
  80016c:	83 ec 04             	sub    $0x4,%esp
  80016f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800172:	8b 13                	mov    (%ebx),%edx
  800174:	8d 42 01             	lea    0x1(%edx),%eax
  800177:	89 03                	mov    %eax,(%ebx)
  800179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800180:	3d ff 00 00 00       	cmp    $0xff,%eax
  800185:	74 09                	je     800190 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018e:	c9                   	leave  
  80018f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800190:	83 ec 08             	sub    $0x8,%esp
  800193:	68 ff 00 00 00       	push   $0xff
  800198:	8d 43 08             	lea    0x8(%ebx),%eax
  80019b:	50                   	push   %eax
  80019c:	e8 b8 09 00 00       	call   800b59 <sys_cputs>
		b->idx = 0;
  8001a1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a7:	83 c4 10             	add    $0x10,%esp
  8001aa:	eb db                	jmp    800187 <putch+0x1f>

008001ac <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001bc:	00 00 00 
	b.cnt = 0;
  8001bf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c9:	ff 75 0c             	pushl  0xc(%ebp)
  8001cc:	ff 75 08             	pushl  0x8(%ebp)
  8001cf:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d5:	50                   	push   %eax
  8001d6:	68 68 01 80 00       	push   $0x800168
  8001db:	e8 1a 01 00 00       	call   8002fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e0:	83 c4 08             	add    $0x8,%esp
  8001e3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001e9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ef:	50                   	push   %eax
  8001f0:	e8 64 09 00 00       	call   800b59 <sys_cputs>

	return b.cnt;
}
  8001f5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001fb:	c9                   	leave  
  8001fc:	c3                   	ret    

008001fd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fd:	55                   	push   %ebp
  8001fe:	89 e5                	mov    %esp,%ebp
  800200:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800203:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800206:	50                   	push   %eax
  800207:	ff 75 08             	pushl  0x8(%ebp)
  80020a:	e8 9d ff ff ff       	call   8001ac <vcprintf>
	va_end(ap);

	return cnt;
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	57                   	push   %edi
  800215:	56                   	push   %esi
  800216:	53                   	push   %ebx
  800217:	83 ec 1c             	sub    $0x1c,%esp
  80021a:	89 c7                	mov    %eax,%edi
  80021c:	89 d6                	mov    %edx,%esi
  80021e:	8b 45 08             	mov    0x8(%ebp),%eax
  800221:	8b 55 0c             	mov    0xc(%ebp),%edx
  800224:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800227:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80022d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800232:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800235:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800238:	39 d3                	cmp    %edx,%ebx
  80023a:	72 05                	jb     800241 <printnum+0x30>
  80023c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80023f:	77 7a                	ja     8002bb <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800241:	83 ec 0c             	sub    $0xc,%esp
  800244:	ff 75 18             	pushl  0x18(%ebp)
  800247:	8b 45 14             	mov    0x14(%ebp),%eax
  80024a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80024d:	53                   	push   %ebx
  80024e:	ff 75 10             	pushl  0x10(%ebp)
  800251:	83 ec 08             	sub    $0x8,%esp
  800254:	ff 75 e4             	pushl  -0x1c(%ebp)
  800257:	ff 75 e0             	pushl  -0x20(%ebp)
  80025a:	ff 75 dc             	pushl  -0x24(%ebp)
  80025d:	ff 75 d8             	pushl  -0x28(%ebp)
  800260:	e8 fb 0b 00 00       	call   800e60 <__udivdi3>
  800265:	83 c4 18             	add    $0x18,%esp
  800268:	52                   	push   %edx
  800269:	50                   	push   %eax
  80026a:	89 f2                	mov    %esi,%edx
  80026c:	89 f8                	mov    %edi,%eax
  80026e:	e8 9e ff ff ff       	call   800211 <printnum>
  800273:	83 c4 20             	add    $0x20,%esp
  800276:	eb 13                	jmp    80028b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800278:	83 ec 08             	sub    $0x8,%esp
  80027b:	56                   	push   %esi
  80027c:	ff 75 18             	pushl  0x18(%ebp)
  80027f:	ff d7                	call   *%edi
  800281:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800284:	83 eb 01             	sub    $0x1,%ebx
  800287:	85 db                	test   %ebx,%ebx
  800289:	7f ed                	jg     800278 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80028b:	83 ec 08             	sub    $0x8,%esp
  80028e:	56                   	push   %esi
  80028f:	83 ec 04             	sub    $0x4,%esp
  800292:	ff 75 e4             	pushl  -0x1c(%ebp)
  800295:	ff 75 e0             	pushl  -0x20(%ebp)
  800298:	ff 75 dc             	pushl  -0x24(%ebp)
  80029b:	ff 75 d8             	pushl  -0x28(%ebp)
  80029e:	e8 dd 0c 00 00       	call   800f80 <__umoddi3>
  8002a3:	83 c4 14             	add    $0x14,%esp
  8002a6:	0f be 80 3b 11 80 00 	movsbl 0x80113b(%eax),%eax
  8002ad:	50                   	push   %eax
  8002ae:	ff d7                	call   *%edi
}
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    
  8002bb:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002be:	eb c4                	jmp    800284 <printnum+0x73>

008002c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cf:	73 0a                	jae    8002db <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d4:	89 08                	mov    %ecx,(%eax)
  8002d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d9:	88 02                	mov    %al,(%edx)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <printfmt>:
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e6:	50                   	push   %eax
  8002e7:	ff 75 10             	pushl  0x10(%ebp)
  8002ea:	ff 75 0c             	pushl  0xc(%ebp)
  8002ed:	ff 75 08             	pushl  0x8(%ebp)
  8002f0:	e8 05 00 00 00       	call   8002fa <vprintfmt>
}
  8002f5:	83 c4 10             	add    $0x10,%esp
  8002f8:	c9                   	leave  
  8002f9:	c3                   	ret    

008002fa <vprintfmt>:
{
  8002fa:	55                   	push   %ebp
  8002fb:	89 e5                	mov    %esp,%ebp
  8002fd:	57                   	push   %edi
  8002fe:	56                   	push   %esi
  8002ff:	53                   	push   %ebx
  800300:	83 ec 2c             	sub    $0x2c,%esp
  800303:	8b 75 08             	mov    0x8(%ebp),%esi
  800306:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800309:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030c:	e9 c1 03 00 00       	jmp    8006d2 <vprintfmt+0x3d8>
		padc = ' ';
  800311:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800315:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80031c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800323:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80032a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032f:	8d 47 01             	lea    0x1(%edi),%eax
  800332:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800335:	0f b6 17             	movzbl (%edi),%edx
  800338:	8d 42 dd             	lea    -0x23(%edx),%eax
  80033b:	3c 55                	cmp    $0x55,%al
  80033d:	0f 87 12 04 00 00    	ja     800755 <vprintfmt+0x45b>
  800343:	0f b6 c0             	movzbl %al,%eax
  800346:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800350:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800354:	eb d9                	jmp    80032f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800359:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80035d:	eb d0                	jmp    80032f <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80035f:	0f b6 d2             	movzbl %dl,%edx
  800362:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800365:	b8 00 00 00 00       	mov    $0x0,%eax
  80036a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80036d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800370:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800374:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800377:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80037a:	83 f9 09             	cmp    $0x9,%ecx
  80037d:	77 55                	ja     8003d4 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80037f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800382:	eb e9                	jmp    80036d <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800384:	8b 45 14             	mov    0x14(%ebp),%eax
  800387:	8b 00                	mov    (%eax),%eax
  800389:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80038c:	8b 45 14             	mov    0x14(%ebp),%eax
  80038f:	8d 40 04             	lea    0x4(%eax),%eax
  800392:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800398:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039c:	79 91                	jns    80032f <vprintfmt+0x35>
				width = precision, precision = -1;
  80039e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a4:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ab:	eb 82                	jmp    80032f <vprintfmt+0x35>
  8003ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b0:	85 c0                	test   %eax,%eax
  8003b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b7:	0f 49 d0             	cmovns %eax,%edx
  8003ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c0:	e9 6a ff ff ff       	jmp    80032f <vprintfmt+0x35>
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003cf:	e9 5b ff ff ff       	jmp    80032f <vprintfmt+0x35>
  8003d4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003da:	eb bc                	jmp    800398 <vprintfmt+0x9e>
			lflag++;
  8003dc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e2:	e9 48 ff ff ff       	jmp    80032f <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ea:	8d 78 04             	lea    0x4(%eax),%edi
  8003ed:	83 ec 08             	sub    $0x8,%esp
  8003f0:	53                   	push   %ebx
  8003f1:	ff 30                	pushl  (%eax)
  8003f3:	ff d6                	call   *%esi
			break;
  8003f5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003f8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003fb:	e9 cf 02 00 00       	jmp    8006cf <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 78 04             	lea    0x4(%eax),%edi
  800406:	8b 00                	mov    (%eax),%eax
  800408:	99                   	cltd   
  800409:	31 d0                	xor    %edx,%eax
  80040b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80040d:	83 f8 08             	cmp    $0x8,%eax
  800410:	7f 23                	jg     800435 <vprintfmt+0x13b>
  800412:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800419:	85 d2                	test   %edx,%edx
  80041b:	74 18                	je     800435 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80041d:	52                   	push   %edx
  80041e:	68 5c 11 80 00       	push   $0x80115c
  800423:	53                   	push   %ebx
  800424:	56                   	push   %esi
  800425:	e8 b3 fe ff ff       	call   8002dd <printfmt>
  80042a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80042d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800430:	e9 9a 02 00 00       	jmp    8006cf <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800435:	50                   	push   %eax
  800436:	68 53 11 80 00       	push   $0x801153
  80043b:	53                   	push   %ebx
  80043c:	56                   	push   %esi
  80043d:	e8 9b fe ff ff       	call   8002dd <printfmt>
  800442:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800445:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800448:	e9 82 02 00 00       	jmp    8006cf <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80044d:	8b 45 14             	mov    0x14(%ebp),%eax
  800450:	83 c0 04             	add    $0x4,%eax
  800453:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80045b:	85 ff                	test   %edi,%edi
  80045d:	b8 4c 11 80 00       	mov    $0x80114c,%eax
  800462:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800465:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800469:	0f 8e bd 00 00 00    	jle    80052c <vprintfmt+0x232>
  80046f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800473:	75 0e                	jne    800483 <vprintfmt+0x189>
  800475:	89 75 08             	mov    %esi,0x8(%ebp)
  800478:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80047b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80047e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800481:	eb 6d                	jmp    8004f0 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ec 08             	sub    $0x8,%esp
  800486:	ff 75 d0             	pushl  -0x30(%ebp)
  800489:	57                   	push   %edi
  80048a:	e8 6e 03 00 00       	call   8007fd <strnlen>
  80048f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800492:	29 c1                	sub    %eax,%ecx
  800494:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800497:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80049a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80049e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004a4:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	eb 0f                	jmp    8004b7 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	53                   	push   %ebx
  8004ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8004af:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b1:	83 ef 01             	sub    $0x1,%edi
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	7f ed                	jg     8004a8 <vprintfmt+0x1ae>
  8004bb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004be:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004c1:	85 c9                	test   %ecx,%ecx
  8004c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c8:	0f 49 c1             	cmovns %ecx,%eax
  8004cb:	29 c1                	sub    %eax,%ecx
  8004cd:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004d3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004d6:	89 cb                	mov    %ecx,%ebx
  8004d8:	eb 16                	jmp    8004f0 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004de:	75 31                	jne    800511 <vprintfmt+0x217>
					putch(ch, putdat);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	ff 75 0c             	pushl  0xc(%ebp)
  8004e6:	50                   	push   %eax
  8004e7:	ff 55 08             	call   *0x8(%ebp)
  8004ea:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ed:	83 eb 01             	sub    $0x1,%ebx
  8004f0:	83 c7 01             	add    $0x1,%edi
  8004f3:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004f7:	0f be c2             	movsbl %dl,%eax
  8004fa:	85 c0                	test   %eax,%eax
  8004fc:	74 59                	je     800557 <vprintfmt+0x25d>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	78 d8                	js     8004da <vprintfmt+0x1e0>
  800502:	83 ee 01             	sub    $0x1,%esi
  800505:	79 d3                	jns    8004da <vprintfmt+0x1e0>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	eb 37                	jmp    800548 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	0f be d2             	movsbl %dl,%edx
  800514:	83 ea 20             	sub    $0x20,%edx
  800517:	83 fa 5e             	cmp    $0x5e,%edx
  80051a:	76 c4                	jbe    8004e0 <vprintfmt+0x1e6>
					putch('?', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	ff 75 0c             	pushl  0xc(%ebp)
  800522:	6a 3f                	push   $0x3f
  800524:	ff 55 08             	call   *0x8(%ebp)
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb c1                	jmp    8004ed <vprintfmt+0x1f3>
  80052c:	89 75 08             	mov    %esi,0x8(%ebp)
  80052f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800532:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800535:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800538:	eb b6                	jmp    8004f0 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	53                   	push   %ebx
  80053e:	6a 20                	push   $0x20
  800540:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800542:	83 ef 01             	sub    $0x1,%edi
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	85 ff                	test   %edi,%edi
  80054a:	7f ee                	jg     80053a <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80054c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80054f:	89 45 14             	mov    %eax,0x14(%ebp)
  800552:	e9 78 01 00 00       	jmp    8006cf <vprintfmt+0x3d5>
  800557:	89 df                	mov    %ebx,%edi
  800559:	8b 75 08             	mov    0x8(%ebp),%esi
  80055c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80055f:	eb e7                	jmp    800548 <vprintfmt+0x24e>
	if (lflag >= 2)
  800561:	83 f9 01             	cmp    $0x1,%ecx
  800564:	7e 3f                	jle    8005a5 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 50 04             	mov    0x4(%eax),%edx
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 08             	lea    0x8(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80057d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800581:	79 5c                	jns    8005df <vprintfmt+0x2e5>
				putch('-', putdat);
  800583:	83 ec 08             	sub    $0x8,%esp
  800586:	53                   	push   %ebx
  800587:	6a 2d                	push   $0x2d
  800589:	ff d6                	call   *%esi
				num = -(long long) num;
  80058b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800591:	f7 da                	neg    %edx
  800593:	83 d1 00             	adc    $0x0,%ecx
  800596:	f7 d9                	neg    %ecx
  800598:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059b:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a0:	e9 10 01 00 00       	jmp    8006b5 <vprintfmt+0x3bb>
	else if (lflag)
  8005a5:	85 c9                	test   %ecx,%ecx
  8005a7:	75 1b                	jne    8005c4 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 00                	mov    (%eax),%eax
  8005ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b1:	89 c1                	mov    %eax,%ecx
  8005b3:	c1 f9 1f             	sar    $0x1f,%ecx
  8005b6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bc:	8d 40 04             	lea    0x4(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c2:	eb b9                	jmp    80057d <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8b 00                	mov    (%eax),%eax
  8005c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005cc:	89 c1                	mov    %eax,%ecx
  8005ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8005d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb 9e                	jmp    80057d <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005e5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ea:	e9 c6 00 00 00       	jmp    8006b5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005ef:	83 f9 01             	cmp    $0x1,%ecx
  8005f2:	7e 18                	jle    80060c <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fc:	8d 40 08             	lea    0x8(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 a9 00 00 00       	jmp    8006b5 <vprintfmt+0x3bb>
	else if (lflag)
  80060c:	85 c9                	test   %ecx,%ecx
  80060e:	75 1a                	jne    80062a <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8b 10                	mov    (%eax),%edx
  800615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061a:	8d 40 04             	lea    0x4(%eax),%eax
  80061d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
  800625:	e9 8b 00 00 00       	jmp    8006b5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8b 10                	mov    (%eax),%edx
  80062f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800634:	8d 40 04             	lea    0x4(%eax),%eax
  800637:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80063a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063f:	eb 74                	jmp    8006b5 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800641:	83 f9 01             	cmp    $0x1,%ecx
  800644:	7e 15                	jle    80065b <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	8b 48 04             	mov    0x4(%eax),%ecx
  80064e:	8d 40 08             	lea    0x8(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800654:	b8 08 00 00 00       	mov    $0x8,%eax
  800659:	eb 5a                	jmp    8006b5 <vprintfmt+0x3bb>
	else if (lflag)
  80065b:	85 c9                	test   %ecx,%ecx
  80065d:	75 17                	jne    800676 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 10                	mov    (%eax),%edx
  800664:	b9 00 00 00 00       	mov    $0x0,%ecx
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80066f:	b8 08 00 00 00       	mov    $0x8,%eax
  800674:	eb 3f                	jmp    8006b5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8b 10                	mov    (%eax),%edx
  80067b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800680:	8d 40 04             	lea    0x4(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800686:	b8 08 00 00 00       	mov    $0x8,%eax
  80068b:	eb 28                	jmp    8006b5 <vprintfmt+0x3bb>
			putch('0', putdat);
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	53                   	push   %ebx
  800691:	6a 30                	push   $0x30
  800693:	ff d6                	call   *%esi
			putch('x', putdat);
  800695:	83 c4 08             	add    $0x8,%esp
  800698:	53                   	push   %ebx
  800699:	6a 78                	push   $0x78
  80069b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006a7:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006aa:	8d 40 04             	lea    0x4(%eax),%eax
  8006ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b0:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006b5:	83 ec 0c             	sub    $0xc,%esp
  8006b8:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bc:	57                   	push   %edi
  8006bd:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c0:	50                   	push   %eax
  8006c1:	51                   	push   %ecx
  8006c2:	52                   	push   %edx
  8006c3:	89 da                	mov    %ebx,%edx
  8006c5:	89 f0                	mov    %esi,%eax
  8006c7:	e8 45 fb ff ff       	call   800211 <printnum>
			break;
  8006cc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d2:	83 c7 01             	add    $0x1,%edi
  8006d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d9:	83 f8 25             	cmp    $0x25,%eax
  8006dc:	0f 84 2f fc ff ff    	je     800311 <vprintfmt+0x17>
			if (ch == '\0')
  8006e2:	85 c0                	test   %eax,%eax
  8006e4:	0f 84 8b 00 00 00    	je     800775 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	53                   	push   %ebx
  8006ee:	50                   	push   %eax
  8006ef:	ff d6                	call   *%esi
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	eb dc                	jmp    8006d2 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006f6:	83 f9 01             	cmp    $0x1,%ecx
  8006f9:	7e 15                	jle    800710 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 10                	mov    (%eax),%edx
  800700:	8b 48 04             	mov    0x4(%eax),%ecx
  800703:	8d 40 08             	lea    0x8(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800709:	b8 10 00 00 00       	mov    $0x10,%eax
  80070e:	eb a5                	jmp    8006b5 <vprintfmt+0x3bb>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	75 17                	jne    80072b <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071e:	8d 40 04             	lea    0x4(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800724:	b8 10 00 00 00       	mov    $0x10,%eax
  800729:	eb 8a                	jmp    8006b5 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80072b:	8b 45 14             	mov    0x14(%ebp),%eax
  80072e:	8b 10                	mov    (%eax),%edx
  800730:	b9 00 00 00 00       	mov    $0x0,%ecx
  800735:	8d 40 04             	lea    0x4(%eax),%eax
  800738:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80073b:	b8 10 00 00 00       	mov    $0x10,%eax
  800740:	e9 70 ff ff ff       	jmp    8006b5 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	6a 25                	push   $0x25
  80074b:	ff d6                	call   *%esi
			break;
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	e9 7a ff ff ff       	jmp    8006cf <vprintfmt+0x3d5>
			putch('%', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	53                   	push   %ebx
  800759:	6a 25                	push   $0x25
  80075b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	89 f8                	mov    %edi,%eax
  800762:	eb 03                	jmp    800767 <vprintfmt+0x46d>
  800764:	83 e8 01             	sub    $0x1,%eax
  800767:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80076b:	75 f7                	jne    800764 <vprintfmt+0x46a>
  80076d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800770:	e9 5a ff ff ff       	jmp    8006cf <vprintfmt+0x3d5>
}
  800775:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800778:	5b                   	pop    %ebx
  800779:	5e                   	pop    %esi
  80077a:	5f                   	pop    %edi
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 18             	sub    $0x18,%esp
  800783:	8b 45 08             	mov    0x8(%ebp),%eax
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800789:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800790:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800793:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80079a:	85 c0                	test   %eax,%eax
  80079c:	74 26                	je     8007c4 <vsnprintf+0x47>
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	7e 22                	jle    8007c4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007a2:	ff 75 14             	pushl  0x14(%ebp)
  8007a5:	ff 75 10             	pushl  0x10(%ebp)
  8007a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ab:	50                   	push   %eax
  8007ac:	68 c0 02 80 00       	push   $0x8002c0
  8007b1:	e8 44 fb ff ff       	call   8002fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bf:	83 c4 10             	add    $0x10,%esp
}
  8007c2:	c9                   	leave  
  8007c3:	c3                   	ret    
		return -E_INVAL;
  8007c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c9:	eb f7                	jmp    8007c2 <vsnprintf+0x45>

008007cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007cb:	55                   	push   %ebp
  8007cc:	89 e5                	mov    %esp,%ebp
  8007ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d4:	50                   	push   %eax
  8007d5:	ff 75 10             	pushl  0x10(%ebp)
  8007d8:	ff 75 0c             	pushl  0xc(%ebp)
  8007db:	ff 75 08             	pushl  0x8(%ebp)
  8007de:	e8 9a ff ff ff       	call   80077d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e3:	c9                   	leave  
  8007e4:	c3                   	ret    

008007e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f0:	eb 03                	jmp    8007f5 <strlen+0x10>
		n++;
  8007f2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f9:	75 f7                	jne    8007f2 <strlen+0xd>
	return n;
}
  8007fb:	5d                   	pop    %ebp
  8007fc:	c3                   	ret    

008007fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	eb 03                	jmp    800810 <strnlen+0x13>
		n++;
  80080d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800810:	39 d0                	cmp    %edx,%eax
  800812:	74 06                	je     80081a <strnlen+0x1d>
  800814:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800818:	75 f3                	jne    80080d <strnlen+0x10>
	return n;
}
  80081a:	5d                   	pop    %ebp
  80081b:	c3                   	ret    

0080081c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	8b 45 08             	mov    0x8(%ebp),%eax
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800826:	89 c2                	mov    %eax,%edx
  800828:	83 c1 01             	add    $0x1,%ecx
  80082b:	83 c2 01             	add    $0x1,%edx
  80082e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800832:	88 5a ff             	mov    %bl,-0x1(%edx)
  800835:	84 db                	test   %bl,%bl
  800837:	75 ef                	jne    800828 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800839:	5b                   	pop    %ebx
  80083a:	5d                   	pop    %ebp
  80083b:	c3                   	ret    

0080083c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083c:	55                   	push   %ebp
  80083d:	89 e5                	mov    %esp,%ebp
  80083f:	53                   	push   %ebx
  800840:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800843:	53                   	push   %ebx
  800844:	e8 9c ff ff ff       	call   8007e5 <strlen>
  800849:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80084c:	ff 75 0c             	pushl  0xc(%ebp)
  80084f:	01 d8                	add    %ebx,%eax
  800851:	50                   	push   %eax
  800852:	e8 c5 ff ff ff       	call   80081c <strcpy>
	return dst;
}
  800857:	89 d8                	mov    %ebx,%eax
  800859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	56                   	push   %esi
  800862:	53                   	push   %ebx
  800863:	8b 75 08             	mov    0x8(%ebp),%esi
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800869:	89 f3                	mov    %esi,%ebx
  80086b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086e:	89 f2                	mov    %esi,%edx
  800870:	eb 0f                	jmp    800881 <strncpy+0x23>
		*dst++ = *src;
  800872:	83 c2 01             	add    $0x1,%edx
  800875:	0f b6 01             	movzbl (%ecx),%eax
  800878:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80087b:	80 39 01             	cmpb   $0x1,(%ecx)
  80087e:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800881:	39 da                	cmp    %ebx,%edx
  800883:	75 ed                	jne    800872 <strncpy+0x14>
	}
	return ret;
}
  800885:	89 f0                	mov    %esi,%eax
  800887:	5b                   	pop    %ebx
  800888:	5e                   	pop    %esi
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 75 08             	mov    0x8(%ebp),%esi
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
  800896:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800899:	89 f0                	mov    %esi,%eax
  80089b:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80089f:	85 c9                	test   %ecx,%ecx
  8008a1:	75 0b                	jne    8008ae <strlcpy+0x23>
  8008a3:	eb 17                	jmp    8008bc <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008a5:	83 c2 01             	add    $0x1,%edx
  8008a8:	83 c0 01             	add    $0x1,%eax
  8008ab:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008ae:	39 d8                	cmp    %ebx,%eax
  8008b0:	74 07                	je     8008b9 <strlcpy+0x2e>
  8008b2:	0f b6 0a             	movzbl (%edx),%ecx
  8008b5:	84 c9                	test   %cl,%cl
  8008b7:	75 ec                	jne    8008a5 <strlcpy+0x1a>
		*dst = '\0';
  8008b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008bc:	29 f0                	sub    %esi,%eax
}
  8008be:	5b                   	pop    %ebx
  8008bf:	5e                   	pop    %esi
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008cb:	eb 06                	jmp    8008d3 <strcmp+0x11>
		p++, q++;
  8008cd:	83 c1 01             	add    $0x1,%ecx
  8008d0:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008d3:	0f b6 01             	movzbl (%ecx),%eax
  8008d6:	84 c0                	test   %al,%al
  8008d8:	74 04                	je     8008de <strcmp+0x1c>
  8008da:	3a 02                	cmp    (%edx),%al
  8008dc:	74 ef                	je     8008cd <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008de:	0f b6 c0             	movzbl %al,%eax
  8008e1:	0f b6 12             	movzbl (%edx),%edx
  8008e4:	29 d0                	sub    %edx,%eax
}
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	53                   	push   %ebx
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f2:	89 c3                	mov    %eax,%ebx
  8008f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f7:	eb 06                	jmp    8008ff <strncmp+0x17>
		n--, p++, q++;
  8008f9:	83 c0 01             	add    $0x1,%eax
  8008fc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ff:	39 d8                	cmp    %ebx,%eax
  800901:	74 16                	je     800919 <strncmp+0x31>
  800903:	0f b6 08             	movzbl (%eax),%ecx
  800906:	84 c9                	test   %cl,%cl
  800908:	74 04                	je     80090e <strncmp+0x26>
  80090a:	3a 0a                	cmp    (%edx),%cl
  80090c:	74 eb                	je     8008f9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80090e:	0f b6 00             	movzbl (%eax),%eax
  800911:	0f b6 12             	movzbl (%edx),%edx
  800914:	29 d0                	sub    %edx,%eax
}
  800916:	5b                   	pop    %ebx
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    
		return 0;
  800919:	b8 00 00 00 00       	mov    $0x0,%eax
  80091e:	eb f6                	jmp    800916 <strncmp+0x2e>

00800920 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 45 08             	mov    0x8(%ebp),%eax
  800926:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80092a:	0f b6 10             	movzbl (%eax),%edx
  80092d:	84 d2                	test   %dl,%dl
  80092f:	74 09                	je     80093a <strchr+0x1a>
		if (*s == c)
  800931:	38 ca                	cmp    %cl,%dl
  800933:	74 0a                	je     80093f <strchr+0x1f>
	for (; *s; s++)
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	eb f0                	jmp    80092a <strchr+0xa>
			return (char *) s;
	return 0;
  80093a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	8b 45 08             	mov    0x8(%ebp),%eax
  800947:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094b:	eb 03                	jmp    800950 <strfind+0xf>
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800953:	38 ca                	cmp    %cl,%dl
  800955:	74 04                	je     80095b <strfind+0x1a>
  800957:	84 d2                	test   %dl,%dl
  800959:	75 f2                	jne    80094d <strfind+0xc>
			break;
	return (char *) s;
}
  80095b:	5d                   	pop    %ebp
  80095c:	c3                   	ret    

0080095d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	57                   	push   %edi
  800961:	56                   	push   %esi
  800962:	53                   	push   %ebx
  800963:	8b 7d 08             	mov    0x8(%ebp),%edi
  800966:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800969:	85 c9                	test   %ecx,%ecx
  80096b:	74 13                	je     800980 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80096d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800973:	75 05                	jne    80097a <memset+0x1d>
  800975:	f6 c1 03             	test   $0x3,%cl
  800978:	74 0d                	je     800987 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80097a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097d:	fc                   	cld    
  80097e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800980:	89 f8                	mov    %edi,%eax
  800982:	5b                   	pop    %ebx
  800983:	5e                   	pop    %esi
  800984:	5f                   	pop    %edi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    
		c &= 0xFF;
  800987:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80098b:	89 d3                	mov    %edx,%ebx
  80098d:	c1 e3 08             	shl    $0x8,%ebx
  800990:	89 d0                	mov    %edx,%eax
  800992:	c1 e0 18             	shl    $0x18,%eax
  800995:	89 d6                	mov    %edx,%esi
  800997:	c1 e6 10             	shl    $0x10,%esi
  80099a:	09 f0                	or     %esi,%eax
  80099c:	09 c2                	or     %eax,%edx
  80099e:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009a3:	89 d0                	mov    %edx,%eax
  8009a5:	fc                   	cld    
  8009a6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009a8:	eb d6                	jmp    800980 <memset+0x23>

008009aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	57                   	push   %edi
  8009ae:	56                   	push   %esi
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009b8:	39 c6                	cmp    %eax,%esi
  8009ba:	73 35                	jae    8009f1 <memmove+0x47>
  8009bc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009bf:	39 c2                	cmp    %eax,%edx
  8009c1:	76 2e                	jbe    8009f1 <memmove+0x47>
		s += n;
		d += n;
  8009c3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c6:	89 d6                	mov    %edx,%esi
  8009c8:	09 fe                	or     %edi,%esi
  8009ca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d0:	74 0c                	je     8009de <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009d2:	83 ef 01             	sub    $0x1,%edi
  8009d5:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009d8:	fd                   	std    
  8009d9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009db:	fc                   	cld    
  8009dc:	eb 21                	jmp    8009ff <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009de:	f6 c1 03             	test   $0x3,%cl
  8009e1:	75 ef                	jne    8009d2 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009e3:	83 ef 04             	sub    $0x4,%edi
  8009e6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ef:	eb ea                	jmp    8009db <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f1:	89 f2                	mov    %esi,%edx
  8009f3:	09 c2                	or     %eax,%edx
  8009f5:	f6 c2 03             	test   $0x3,%dl
  8009f8:	74 09                	je     800a03 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009fa:	89 c7                	mov    %eax,%edi
  8009fc:	fc                   	cld    
  8009fd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ff:	5e                   	pop    %esi
  800a00:	5f                   	pop    %edi
  800a01:	5d                   	pop    %ebp
  800a02:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a03:	f6 c1 03             	test   $0x3,%cl
  800a06:	75 f2                	jne    8009fa <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a08:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a0b:	89 c7                	mov    %eax,%edi
  800a0d:	fc                   	cld    
  800a0e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a10:	eb ed                	jmp    8009ff <memmove+0x55>

00800a12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a12:	55                   	push   %ebp
  800a13:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a15:	ff 75 10             	pushl  0x10(%ebp)
  800a18:	ff 75 0c             	pushl  0xc(%ebp)
  800a1b:	ff 75 08             	pushl  0x8(%ebp)
  800a1e:	e8 87 ff ff ff       	call   8009aa <memmove>
}
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	56                   	push   %esi
  800a29:	53                   	push   %ebx
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a30:	89 c6                	mov    %eax,%esi
  800a32:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a35:	39 f0                	cmp    %esi,%eax
  800a37:	74 1c                	je     800a55 <memcmp+0x30>
		if (*s1 != *s2)
  800a39:	0f b6 08             	movzbl (%eax),%ecx
  800a3c:	0f b6 1a             	movzbl (%edx),%ebx
  800a3f:	38 d9                	cmp    %bl,%cl
  800a41:	75 08                	jne    800a4b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a43:	83 c0 01             	add    $0x1,%eax
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	eb ea                	jmp    800a35 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a4b:	0f b6 c1             	movzbl %cl,%eax
  800a4e:	0f b6 db             	movzbl %bl,%ebx
  800a51:	29 d8                	sub    %ebx,%eax
  800a53:	eb 05                	jmp    800a5a <memcmp+0x35>
	}

	return 0;
  800a55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a6c:	39 d0                	cmp    %edx,%eax
  800a6e:	73 09                	jae    800a79 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a70:	38 08                	cmp    %cl,(%eax)
  800a72:	74 05                	je     800a79 <memfind+0x1b>
	for (; s < ends; s++)
  800a74:	83 c0 01             	add    $0x1,%eax
  800a77:	eb f3                	jmp    800a6c <memfind+0xe>
			break;
	return (void *) s;
}
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	57                   	push   %edi
  800a7f:	56                   	push   %esi
  800a80:	53                   	push   %ebx
  800a81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a87:	eb 03                	jmp    800a8c <strtol+0x11>
		s++;
  800a89:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a8c:	0f b6 01             	movzbl (%ecx),%eax
  800a8f:	3c 20                	cmp    $0x20,%al
  800a91:	74 f6                	je     800a89 <strtol+0xe>
  800a93:	3c 09                	cmp    $0x9,%al
  800a95:	74 f2                	je     800a89 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a97:	3c 2b                	cmp    $0x2b,%al
  800a99:	74 2e                	je     800ac9 <strtol+0x4e>
	int neg = 0;
  800a9b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800aa0:	3c 2d                	cmp    $0x2d,%al
  800aa2:	74 2f                	je     800ad3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800aaa:	75 05                	jne    800ab1 <strtol+0x36>
  800aac:	80 39 30             	cmpb   $0x30,(%ecx)
  800aaf:	74 2c                	je     800add <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ab1:	85 db                	test   %ebx,%ebx
  800ab3:	75 0a                	jne    800abf <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ab5:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aba:	80 39 30             	cmpb   $0x30,(%ecx)
  800abd:	74 28                	je     800ae7 <strtol+0x6c>
		base = 10;
  800abf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ac7:	eb 50                	jmp    800b19 <strtol+0x9e>
		s++;
  800ac9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800acc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ad1:	eb d1                	jmp    800aa4 <strtol+0x29>
		s++, neg = 1;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	bf 01 00 00 00       	mov    $0x1,%edi
  800adb:	eb c7                	jmp    800aa4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800add:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ae1:	74 0e                	je     800af1 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ae3:	85 db                	test   %ebx,%ebx
  800ae5:	75 d8                	jne    800abf <strtol+0x44>
		s++, base = 8;
  800ae7:	83 c1 01             	add    $0x1,%ecx
  800aea:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aef:	eb ce                	jmp    800abf <strtol+0x44>
		s += 2, base = 16;
  800af1:	83 c1 02             	add    $0x2,%ecx
  800af4:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af9:	eb c4                	jmp    800abf <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800afb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800afe:	89 f3                	mov    %esi,%ebx
  800b00:	80 fb 19             	cmp    $0x19,%bl
  800b03:	77 29                	ja     800b2e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b05:	0f be d2             	movsbl %dl,%edx
  800b08:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b0e:	7d 30                	jge    800b40 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b10:	83 c1 01             	add    $0x1,%ecx
  800b13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b17:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b19:	0f b6 11             	movzbl (%ecx),%edx
  800b1c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1f:	89 f3                	mov    %esi,%ebx
  800b21:	80 fb 09             	cmp    $0x9,%bl
  800b24:	77 d5                	ja     800afb <strtol+0x80>
			dig = *s - '0';
  800b26:	0f be d2             	movsbl %dl,%edx
  800b29:	83 ea 30             	sub    $0x30,%edx
  800b2c:	eb dd                	jmp    800b0b <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b2e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b31:	89 f3                	mov    %esi,%ebx
  800b33:	80 fb 19             	cmp    $0x19,%bl
  800b36:	77 08                	ja     800b40 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b38:	0f be d2             	movsbl %dl,%edx
  800b3b:	83 ea 37             	sub    $0x37,%edx
  800b3e:	eb cb                	jmp    800b0b <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b44:	74 05                	je     800b4b <strtol+0xd0>
		*endptr = (char *) s;
  800b46:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b49:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	f7 da                	neg    %edx
  800b4f:	85 ff                	test   %edi,%edi
  800b51:	0f 45 c2             	cmovne %edx,%eax
}
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	57                   	push   %edi
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6a:	89 c3                	mov    %eax,%ebx
  800b6c:	89 c7                	mov    %eax,%edi
  800b6e:	89 c6                	mov    %eax,%esi
  800b70:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b72:	5b                   	pop    %ebx
  800b73:	5e                   	pop    %esi
  800b74:	5f                   	pop    %edi
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	57                   	push   %edi
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 01 00 00 00       	mov    $0x1,%eax
  800b87:	89 d1                	mov    %edx,%ecx
  800b89:	89 d3                	mov    %edx,%ebx
  800b8b:	89 d7                	mov    %edx,%edi
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b91:	5b                   	pop    %ebx
  800b92:	5e                   	pop    %esi
  800b93:	5f                   	pop    %edi
  800b94:	5d                   	pop    %ebp
  800b95:	c3                   	ret    

00800b96 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b96:	55                   	push   %ebp
  800b97:	89 e5                	mov    %esp,%ebp
  800b99:	57                   	push   %edi
  800b9a:	56                   	push   %esi
  800b9b:	53                   	push   %ebx
  800b9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bac:	89 cb                	mov    %ecx,%ebx
  800bae:	89 cf                	mov    %ecx,%edi
  800bb0:	89 ce                	mov    %ecx,%esi
  800bb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bb4:	85 c0                	test   %eax,%eax
  800bb6:	7f 08                	jg     800bc0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 03                	push   $0x3
  800bc6:	68 84 13 80 00       	push   $0x801384
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 a1 13 80 00       	push   $0x8013a1
  800bd2:	e8 4b f5 ff ff       	call   800122 <_panic>

00800bd7 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800be2:	b8 02 00 00 00       	mov    $0x2,%eax
  800be7:	89 d1                	mov    %edx,%ecx
  800be9:	89 d3                	mov    %edx,%ebx
  800beb:	89 d7                	mov    %edx,%edi
  800bed:	89 d6                	mov    %edx,%esi
  800bef:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_yield>:

void
sys_yield(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	57                   	push   %edi
  800c19:	56                   	push   %esi
  800c1a:	53                   	push   %ebx
  800c1b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1e:	be 00 00 00 00       	mov    $0x0,%esi
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	b8 04 00 00 00       	mov    $0x4,%eax
  800c2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c31:	89 f7                	mov    %esi,%edi
  800c33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c35:	85 c0                	test   %eax,%eax
  800c37:	7f 08                	jg     800c41 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	50                   	push   %eax
  800c45:	6a 04                	push   $0x4
  800c47:	68 84 13 80 00       	push   $0x801384
  800c4c:	6a 23                	push   $0x23
  800c4e:	68 a1 13 80 00       	push   $0x8013a1
  800c53:	e8 ca f4 ff ff       	call   800122 <_panic>

00800c58 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 05 00 00 00       	mov    $0x5,%eax
  800c6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c6f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c72:	8b 75 18             	mov    0x18(%ebp),%esi
  800c75:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c77:	85 c0                	test   %eax,%eax
  800c79:	7f 08                	jg     800c83 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c83:	83 ec 0c             	sub    $0xc,%esp
  800c86:	50                   	push   %eax
  800c87:	6a 05                	push   $0x5
  800c89:	68 84 13 80 00       	push   $0x801384
  800c8e:	6a 23                	push   $0x23
  800c90:	68 a1 13 80 00       	push   $0x8013a1
  800c95:	e8 88 f4 ff ff       	call   800122 <_panic>

00800c9a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	b8 06 00 00 00       	mov    $0x6,%eax
  800cb3:	89 df                	mov    %ebx,%edi
  800cb5:	89 de                	mov    %ebx,%esi
  800cb7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb9:	85 c0                	test   %eax,%eax
  800cbb:	7f 08                	jg     800cc5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc5:	83 ec 0c             	sub    $0xc,%esp
  800cc8:	50                   	push   %eax
  800cc9:	6a 06                	push   $0x6
  800ccb:	68 84 13 80 00       	push   $0x801384
  800cd0:	6a 23                	push   $0x23
  800cd2:	68 a1 13 80 00       	push   $0x8013a1
  800cd7:	e8 46 f4 ff ff       	call   800122 <_panic>

00800cdc <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cf5:	89 df                	mov    %ebx,%edi
  800cf7:	89 de                	mov    %ebx,%esi
  800cf9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7f 08                	jg     800d07 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d07:	83 ec 0c             	sub    $0xc,%esp
  800d0a:	50                   	push   %eax
  800d0b:	6a 08                	push   $0x8
  800d0d:	68 84 13 80 00       	push   $0x801384
  800d12:	6a 23                	push   $0x23
  800d14:	68 a1 13 80 00       	push   $0x8013a1
  800d19:	e8 04 f4 ff ff       	call   800122 <_panic>

00800d1e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	57                   	push   %edi
  800d22:	56                   	push   %esi
  800d23:	53                   	push   %ebx
  800d24:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d27:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	b8 09 00 00 00       	mov    $0x9,%eax
  800d37:	89 df                	mov    %ebx,%edi
  800d39:	89 de                	mov    %ebx,%esi
  800d3b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	7f 08                	jg     800d49 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d49:	83 ec 0c             	sub    $0xc,%esp
  800d4c:	50                   	push   %eax
  800d4d:	6a 09                	push   $0x9
  800d4f:	68 84 13 80 00       	push   $0x801384
  800d54:	6a 23                	push   $0x23
  800d56:	68 a1 13 80 00       	push   $0x8013a1
  800d5b:	e8 c2 f3 ff ff       	call   800122 <_panic>

00800d60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	57                   	push   %edi
  800d64:	56                   	push   %esi
  800d65:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d66:	8b 55 08             	mov    0x8(%ebp),%edx
  800d69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d71:	be 00 00 00 00       	mov    $0x0,%esi
  800d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d79:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d99:	89 cb                	mov    %ecx,%ebx
  800d9b:	89 cf                	mov    %ecx,%edi
  800d9d:	89 ce                	mov    %ecx,%esi
  800d9f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da1:	85 c0                	test   %eax,%eax
  800da3:	7f 08                	jg     800dad <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da8:	5b                   	pop    %ebx
  800da9:	5e                   	pop    %esi
  800daa:	5f                   	pop    %edi
  800dab:	5d                   	pop    %ebp
  800dac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	50                   	push   %eax
  800db1:	6a 0c                	push   $0xc
  800db3:	68 84 13 80 00       	push   $0x801384
  800db8:	6a 23                	push   $0x23
  800dba:	68 a1 13 80 00       	push   $0x8013a1
  800dbf:	e8 5e f3 ff ff       	call   800122 <_panic>

00800dc4 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800dca:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dd1:	74 20                	je     800df3 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd6:	a3 08 20 80 00       	mov    %eax,0x802008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800ddb:	83 ec 08             	sub    $0x8,%esp
  800dde:	68 33 0e 80 00       	push   $0x800e33
  800de3:	6a 00                	push   $0x0
  800de5:	e8 34 ff ff ff       	call   800d1e <sys_env_set_pgfault_upcall>
  800dea:	83 c4 10             	add    $0x10,%esp
  800ded:	85 c0                	test   %eax,%eax
  800def:	78 2e                	js     800e1f <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  800df1:	c9                   	leave  
  800df2:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800df3:	83 ec 04             	sub    $0x4,%esp
  800df6:	6a 07                	push   $0x7
  800df8:	68 00 f0 bf ee       	push   $0xeebff000
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 11 fe ff ff       	call   800c15 <sys_page_alloc>
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	79 c8                	jns    800dd3 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	68 b0 13 80 00       	push   $0x8013b0
  800e13:	6a 21                	push   $0x21
  800e15:	68 14 14 80 00       	push   $0x801414
  800e1a:	e8 03 f3 ff ff       	call   800122 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800e1f:	83 ec 04             	sub    $0x4,%esp
  800e22:	68 dc 13 80 00       	push   $0x8013dc
  800e27:	6a 27                	push   $0x27
  800e29:	68 14 14 80 00       	push   $0x801414
  800e2e:	e8 ef f2 ff ff       	call   800122 <_panic>

00800e33 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e33:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e34:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e39:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e3b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800e3e:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800e42:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e45:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  800e49:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e4d:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e4f:	83 c4 08             	add    $0x8,%esp
	popal
  800e52:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800e53:	83 c4 04             	add    $0x4,%esp
	popfl
  800e56:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e57:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e58:	c3                   	ret    
  800e59:	66 90                	xchg   %ax,%ax
  800e5b:	66 90                	xchg   %ax,%ax
  800e5d:	66 90                	xchg   %ax,%ax
  800e5f:	90                   	nop

00800e60 <__udivdi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e6b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e73:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e77:	85 d2                	test   %edx,%edx
  800e79:	75 35                	jne    800eb0 <__udivdi3+0x50>
  800e7b:	39 f3                	cmp    %esi,%ebx
  800e7d:	0f 87 bd 00 00 00    	ja     800f40 <__udivdi3+0xe0>
  800e83:	85 db                	test   %ebx,%ebx
  800e85:	89 d9                	mov    %ebx,%ecx
  800e87:	75 0b                	jne    800e94 <__udivdi3+0x34>
  800e89:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8e:	31 d2                	xor    %edx,%edx
  800e90:	f7 f3                	div    %ebx
  800e92:	89 c1                	mov    %eax,%ecx
  800e94:	31 d2                	xor    %edx,%edx
  800e96:	89 f0                	mov    %esi,%eax
  800e98:	f7 f1                	div    %ecx
  800e9a:	89 c6                	mov    %eax,%esi
  800e9c:	89 e8                	mov    %ebp,%eax
  800e9e:	89 f7                	mov    %esi,%edi
  800ea0:	f7 f1                	div    %ecx
  800ea2:	89 fa                	mov    %edi,%edx
  800ea4:	83 c4 1c             	add    $0x1c,%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    
  800eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	39 f2                	cmp    %esi,%edx
  800eb2:	77 7c                	ja     800f30 <__udivdi3+0xd0>
  800eb4:	0f bd fa             	bsr    %edx,%edi
  800eb7:	83 f7 1f             	xor    $0x1f,%edi
  800eba:	0f 84 98 00 00 00    	je     800f58 <__udivdi3+0xf8>
  800ec0:	89 f9                	mov    %edi,%ecx
  800ec2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec7:	29 f8                	sub    %edi,%eax
  800ec9:	d3 e2                	shl    %cl,%edx
  800ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ecf:	89 c1                	mov    %eax,%ecx
  800ed1:	89 da                	mov    %ebx,%edx
  800ed3:	d3 ea                	shr    %cl,%edx
  800ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ed9:	09 d1                	or     %edx,%ecx
  800edb:	89 f2                	mov    %esi,%edx
  800edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ee1:	89 f9                	mov    %edi,%ecx
  800ee3:	d3 e3                	shl    %cl,%ebx
  800ee5:	89 c1                	mov    %eax,%ecx
  800ee7:	d3 ea                	shr    %cl,%edx
  800ee9:	89 f9                	mov    %edi,%ecx
  800eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800eef:	d3 e6                	shl    %cl,%esi
  800ef1:	89 eb                	mov    %ebp,%ebx
  800ef3:	89 c1                	mov    %eax,%ecx
  800ef5:	d3 eb                	shr    %cl,%ebx
  800ef7:	09 de                	or     %ebx,%esi
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	f7 74 24 08          	divl   0x8(%esp)
  800eff:	89 d6                	mov    %edx,%esi
  800f01:	89 c3                	mov    %eax,%ebx
  800f03:	f7 64 24 0c          	mull   0xc(%esp)
  800f07:	39 d6                	cmp    %edx,%esi
  800f09:	72 0c                	jb     800f17 <__udivdi3+0xb7>
  800f0b:	89 f9                	mov    %edi,%ecx
  800f0d:	d3 e5                	shl    %cl,%ebp
  800f0f:	39 c5                	cmp    %eax,%ebp
  800f11:	73 5d                	jae    800f70 <__udivdi3+0x110>
  800f13:	39 d6                	cmp    %edx,%esi
  800f15:	75 59                	jne    800f70 <__udivdi3+0x110>
  800f17:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f1a:	31 ff                	xor    %edi,%edi
  800f1c:	89 fa                	mov    %edi,%edx
  800f1e:	83 c4 1c             	add    $0x1c,%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    
  800f26:	8d 76 00             	lea    0x0(%esi),%esi
  800f29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f30:	31 ff                	xor    %edi,%edi
  800f32:	31 c0                	xor    %eax,%eax
  800f34:	89 fa                	mov    %edi,%edx
  800f36:	83 c4 1c             	add    $0x1c,%esp
  800f39:	5b                   	pop    %ebx
  800f3a:	5e                   	pop    %esi
  800f3b:	5f                   	pop    %edi
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    
  800f3e:	66 90                	xchg   %ax,%ax
  800f40:	31 ff                	xor    %edi,%edi
  800f42:	89 e8                	mov    %ebp,%eax
  800f44:	89 f2                	mov    %esi,%edx
  800f46:	f7 f3                	div    %ebx
  800f48:	89 fa                	mov    %edi,%edx
  800f4a:	83 c4 1c             	add    $0x1c,%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    
  800f52:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f58:	39 f2                	cmp    %esi,%edx
  800f5a:	72 06                	jb     800f62 <__udivdi3+0x102>
  800f5c:	31 c0                	xor    %eax,%eax
  800f5e:	39 eb                	cmp    %ebp,%ebx
  800f60:	77 d2                	ja     800f34 <__udivdi3+0xd4>
  800f62:	b8 01 00 00 00       	mov    $0x1,%eax
  800f67:	eb cb                	jmp    800f34 <__udivdi3+0xd4>
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	89 d8                	mov    %ebx,%eax
  800f72:	31 ff                	xor    %edi,%edi
  800f74:	eb be                	jmp    800f34 <__udivdi3+0xd4>
  800f76:	66 90                	xchg   %ax,%ax
  800f78:	66 90                	xchg   %ax,%ax
  800f7a:	66 90                	xchg   %ax,%ax
  800f7c:	66 90                	xchg   %ax,%ax
  800f7e:	66 90                	xchg   %ax,%ax

00800f80 <__umoddi3>:
  800f80:	55                   	push   %ebp
  800f81:	57                   	push   %edi
  800f82:	56                   	push   %esi
  800f83:	53                   	push   %ebx
  800f84:	83 ec 1c             	sub    $0x1c,%esp
  800f87:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f8b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f8f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f97:	85 ed                	test   %ebp,%ebp
  800f99:	89 f0                	mov    %esi,%eax
  800f9b:	89 da                	mov    %ebx,%edx
  800f9d:	75 19                	jne    800fb8 <__umoddi3+0x38>
  800f9f:	39 df                	cmp    %ebx,%edi
  800fa1:	0f 86 b1 00 00 00    	jbe    801058 <__umoddi3+0xd8>
  800fa7:	f7 f7                	div    %edi
  800fa9:	89 d0                	mov    %edx,%eax
  800fab:	31 d2                	xor    %edx,%edx
  800fad:	83 c4 1c             	add    $0x1c,%esp
  800fb0:	5b                   	pop    %ebx
  800fb1:	5e                   	pop    %esi
  800fb2:	5f                   	pop    %edi
  800fb3:	5d                   	pop    %ebp
  800fb4:	c3                   	ret    
  800fb5:	8d 76 00             	lea    0x0(%esi),%esi
  800fb8:	39 dd                	cmp    %ebx,%ebp
  800fba:	77 f1                	ja     800fad <__umoddi3+0x2d>
  800fbc:	0f bd cd             	bsr    %ebp,%ecx
  800fbf:	83 f1 1f             	xor    $0x1f,%ecx
  800fc2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fc6:	0f 84 b4 00 00 00    	je     801080 <__umoddi3+0x100>
  800fcc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fd1:	89 c2                	mov    %eax,%edx
  800fd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fd7:	29 c2                	sub    %eax,%edx
  800fd9:	89 c1                	mov    %eax,%ecx
  800fdb:	89 f8                	mov    %edi,%eax
  800fdd:	d3 e5                	shl    %cl,%ebp
  800fdf:	89 d1                	mov    %edx,%ecx
  800fe1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fe5:	d3 e8                	shr    %cl,%eax
  800fe7:	09 c5                	or     %eax,%ebp
  800fe9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fed:	89 c1                	mov    %eax,%ecx
  800fef:	d3 e7                	shl    %cl,%edi
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ff7:	89 df                	mov    %ebx,%edi
  800ff9:	d3 ef                	shr    %cl,%edi
  800ffb:	89 c1                	mov    %eax,%ecx
  800ffd:	89 f0                	mov    %esi,%eax
  800fff:	d3 e3                	shl    %cl,%ebx
  801001:	89 d1                	mov    %edx,%ecx
  801003:	89 fa                	mov    %edi,%edx
  801005:	d3 e8                	shr    %cl,%eax
  801007:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	f7 f5                	div    %ebp
  801010:	d3 e6                	shl    %cl,%esi
  801012:	89 d1                	mov    %edx,%ecx
  801014:	f7 64 24 08          	mull   0x8(%esp)
  801018:	39 d1                	cmp    %edx,%ecx
  80101a:	89 c3                	mov    %eax,%ebx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	72 06                	jb     801026 <__umoddi3+0xa6>
  801020:	75 0e                	jne    801030 <__umoddi3+0xb0>
  801022:	39 c6                	cmp    %eax,%esi
  801024:	73 0a                	jae    801030 <__umoddi3+0xb0>
  801026:	2b 44 24 08          	sub    0x8(%esp),%eax
  80102a:	19 ea                	sbb    %ebp,%edx
  80102c:	89 d7                	mov    %edx,%edi
  80102e:	89 c3                	mov    %eax,%ebx
  801030:	89 ca                	mov    %ecx,%edx
  801032:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801037:	29 de                	sub    %ebx,%esi
  801039:	19 fa                	sbb    %edi,%edx
  80103b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80103f:	89 d0                	mov    %edx,%eax
  801041:	d3 e0                	shl    %cl,%eax
  801043:	89 d9                	mov    %ebx,%ecx
  801045:	d3 ee                	shr    %cl,%esi
  801047:	d3 ea                	shr    %cl,%edx
  801049:	09 f0                	or     %esi,%eax
  80104b:	83 c4 1c             	add    $0x1c,%esp
  80104e:	5b                   	pop    %ebx
  80104f:	5e                   	pop    %esi
  801050:	5f                   	pop    %edi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    
  801053:	90                   	nop
  801054:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801058:	85 ff                	test   %edi,%edi
  80105a:	89 f9                	mov    %edi,%ecx
  80105c:	75 0b                	jne    801069 <__umoddi3+0xe9>
  80105e:	b8 01 00 00 00       	mov    $0x1,%eax
  801063:	31 d2                	xor    %edx,%edx
  801065:	f7 f7                	div    %edi
  801067:	89 c1                	mov    %eax,%ecx
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	31 d2                	xor    %edx,%edx
  80106d:	f7 f1                	div    %ecx
  80106f:	89 f0                	mov    %esi,%eax
  801071:	f7 f1                	div    %ecx
  801073:	e9 31 ff ff ff       	jmp    800fa9 <__umoddi3+0x29>
  801078:	90                   	nop
  801079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801080:	39 dd                	cmp    %ebx,%ebp
  801082:	72 08                	jb     80108c <__umoddi3+0x10c>
  801084:	39 f7                	cmp    %esi,%edi
  801086:	0f 87 21 ff ff ff    	ja     800fad <__umoddi3+0x2d>
  80108c:	89 da                	mov    %ebx,%edx
  80108e:	89 f0                	mov    %esi,%eax
  801090:	29 f8                	sub    %edi,%eax
  801092:	19 ea                	sbb    %ebp,%edx
  801094:	e9 14 ff ff ff       	jmp    800fad <__umoddi3+0x2d>
