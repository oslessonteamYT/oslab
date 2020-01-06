
obj/user/faultallocbad：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
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
  800045:	e8 9e 01 00 00       	call   8001e8 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004a:	83 c4 0c             	add    $0xc,%esp
  80004d:	6a 07                	push   $0x7
  80004f:	89 d8                	mov    %ebx,%eax
  800051:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800056:	50                   	push   %eax
  800057:	6a 00                	push   $0x0
  800059:	e8 a2 0b 00 00       	call   800c00 <sys_page_alloc>
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
  80006e:	e8 43 07 00 00       	call   8007b6 <snprintf>
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
  800085:	6a 0f                	push   $0xf
  800087:	68 aa 10 80 00       	push   $0x8010aa
  80008c:	e8 7c 00 00 00       	call   80010d <_panic>

00800091 <umain>:

void
umain(int argc, char **argv)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800097:	68 33 00 80 00       	push   $0x800033
  80009c:	e8 0e 0d 00 00       	call   800daf <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a1:	83 c4 08             	add    $0x8,%esp
  8000a4:	6a 04                	push   $0x4
  8000a6:	68 ef be ad de       	push   $0xdeadbeef
  8000ab:	e8 94 0a 00 00       	call   800b44 <sys_cputs>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000c0:	e8 fd 0a 00 00       	call   800bc2 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 a5 ff ff ff       	call   800091 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800101:	6a 00                	push   $0x0
  800103:	e8 79 0a 00 00       	call   800b81 <sys_env_destroy>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	56                   	push   %esi
  800111:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800112:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800115:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80011b:	e8 a2 0a 00 00       	call   800bc2 <sys_getenvid>
  800120:	83 ec 0c             	sub    $0xc,%esp
  800123:	ff 75 0c             	pushl  0xc(%ebp)
  800126:	ff 75 08             	pushl  0x8(%ebp)
  800129:	56                   	push   %esi
  80012a:	50                   	push   %eax
  80012b:	68 18 11 80 00       	push   $0x801118
  800130:	e8 b3 00 00 00       	call   8001e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800135:	83 c4 18             	add    $0x18,%esp
  800138:	53                   	push   %ebx
  800139:	ff 75 10             	pushl  0x10(%ebp)
  80013c:	e8 56 00 00 00       	call   800197 <vcprintf>
	cprintf("\n");
  800141:	c7 04 24 a8 10 80 00 	movl   $0x8010a8,(%esp)
  800148:	e8 9b 00 00 00       	call   8001e8 <cprintf>
  80014d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800150:	cc                   	int3   
  800151:	eb fd                	jmp    800150 <_panic+0x43>

00800153 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	53                   	push   %ebx
  800157:	83 ec 04             	sub    $0x4,%esp
  80015a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80015d:	8b 13                	mov    (%ebx),%edx
  80015f:	8d 42 01             	lea    0x1(%edx),%eax
  800162:	89 03                	mov    %eax,(%ebx)
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80016b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800170:	74 09                	je     80017b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800172:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800179:	c9                   	leave  
  80017a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80017b:	83 ec 08             	sub    $0x8,%esp
  80017e:	68 ff 00 00 00       	push   $0xff
  800183:	8d 43 08             	lea    0x8(%ebx),%eax
  800186:	50                   	push   %eax
  800187:	e8 b8 09 00 00       	call   800b44 <sys_cputs>
		b->idx = 0;
  80018c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	eb db                	jmp    800172 <putch+0x1f>

00800197 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001a7:	00 00 00 
	b.cnt = 0;
  8001aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001b4:	ff 75 0c             	pushl  0xc(%ebp)
  8001b7:	ff 75 08             	pushl  0x8(%ebp)
  8001ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	68 53 01 80 00       	push   $0x800153
  8001c6:	e8 1a 01 00 00       	call   8002e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001cb:	83 c4 08             	add    $0x8,%esp
  8001ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001da:	50                   	push   %eax
  8001db:	e8 64 09 00 00       	call   800b44 <sys_cputs>

	return b.cnt;
}
  8001e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001e6:	c9                   	leave  
  8001e7:	c3                   	ret    

008001e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001f1:	50                   	push   %eax
  8001f2:	ff 75 08             	pushl  0x8(%ebp)
  8001f5:	e8 9d ff ff ff       	call   800197 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001fa:	c9                   	leave  
  8001fb:	c3                   	ret    

008001fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	57                   	push   %edi
  800200:	56                   	push   %esi
  800201:	53                   	push   %ebx
  800202:	83 ec 1c             	sub    $0x1c,%esp
  800205:	89 c7                	mov    %eax,%edi
  800207:	89 d6                	mov    %edx,%esi
  800209:	8b 45 08             	mov    0x8(%ebp),%eax
  80020c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80020f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800212:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800215:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800218:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800220:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800223:	39 d3                	cmp    %edx,%ebx
  800225:	72 05                	jb     80022c <printnum+0x30>
  800227:	39 45 10             	cmp    %eax,0x10(%ebp)
  80022a:	77 7a                	ja     8002a6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	ff 75 18             	pushl  0x18(%ebp)
  800232:	8b 45 14             	mov    0x14(%ebp),%eax
  800235:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800238:	53                   	push   %ebx
  800239:	ff 75 10             	pushl  0x10(%ebp)
  80023c:	83 ec 08             	sub    $0x8,%esp
  80023f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800242:	ff 75 e0             	pushl  -0x20(%ebp)
  800245:	ff 75 dc             	pushl  -0x24(%ebp)
  800248:	ff 75 d8             	pushl  -0x28(%ebp)
  80024b:	e8 00 0c 00 00       	call   800e50 <__udivdi3>
  800250:	83 c4 18             	add    $0x18,%esp
  800253:	52                   	push   %edx
  800254:	50                   	push   %eax
  800255:	89 f2                	mov    %esi,%edx
  800257:	89 f8                	mov    %edi,%eax
  800259:	e8 9e ff ff ff       	call   8001fc <printnum>
  80025e:	83 c4 20             	add    $0x20,%esp
  800261:	eb 13                	jmp    800276 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	56                   	push   %esi
  800267:	ff 75 18             	pushl  0x18(%ebp)
  80026a:	ff d7                	call   *%edi
  80026c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80026f:	83 eb 01             	sub    $0x1,%ebx
  800272:	85 db                	test   %ebx,%ebx
  800274:	7f ed                	jg     800263 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800276:	83 ec 08             	sub    $0x8,%esp
  800279:	56                   	push   %esi
  80027a:	83 ec 04             	sub    $0x4,%esp
  80027d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800280:	ff 75 e0             	pushl  -0x20(%ebp)
  800283:	ff 75 dc             	pushl  -0x24(%ebp)
  800286:	ff 75 d8             	pushl  -0x28(%ebp)
  800289:	e8 e2 0c 00 00       	call   800f70 <__umoddi3>
  80028e:	83 c4 14             	add    $0x14,%esp
  800291:	0f be 80 3b 11 80 00 	movsbl 0x80113b(%eax),%eax
  800298:	50                   	push   %eax
  800299:	ff d7                	call   *%edi
}
  80029b:	83 c4 10             	add    $0x10,%esp
  80029e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a1:	5b                   	pop    %ebx
  8002a2:	5e                   	pop    %esi
  8002a3:	5f                   	pop    %edi
  8002a4:	5d                   	pop    %ebp
  8002a5:	c3                   	ret    
  8002a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a9:	eb c4                	jmp    80026f <printnum+0x73>

008002ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ab:	55                   	push   %ebp
  8002ac:	89 e5                	mov    %esp,%ebp
  8002ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002b5:	8b 10                	mov    (%eax),%edx
  8002b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ba:	73 0a                	jae    8002c6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002bf:	89 08                	mov    %ecx,(%eax)
  8002c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c4:	88 02                	mov    %al,(%edx)
}
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    

008002c8 <printfmt>:
{
  8002c8:	55                   	push   %ebp
  8002c9:	89 e5                	mov    %esp,%ebp
  8002cb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002d1:	50                   	push   %eax
  8002d2:	ff 75 10             	pushl  0x10(%ebp)
  8002d5:	ff 75 0c             	pushl  0xc(%ebp)
  8002d8:	ff 75 08             	pushl  0x8(%ebp)
  8002db:	e8 05 00 00 00       	call   8002e5 <vprintfmt>
}
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	c9                   	leave  
  8002e4:	c3                   	ret    

008002e5 <vprintfmt>:
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	57                   	push   %edi
  8002e9:	56                   	push   %esi
  8002ea:	53                   	push   %ebx
  8002eb:	83 ec 2c             	sub    $0x2c,%esp
  8002ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8002f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002f4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002f7:	e9 c1 03 00 00       	jmp    8006bd <vprintfmt+0x3d8>
		padc = ' ';
  8002fc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800300:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800307:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80030e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800315:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80031a:	8d 47 01             	lea    0x1(%edi),%eax
  80031d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800320:	0f b6 17             	movzbl (%edi),%edx
  800323:	8d 42 dd             	lea    -0x23(%edx),%eax
  800326:	3c 55                	cmp    $0x55,%al
  800328:	0f 87 12 04 00 00    	ja     800740 <vprintfmt+0x45b>
  80032e:	0f b6 c0             	movzbl %al,%eax
  800331:	ff 24 85 00 12 80 00 	jmp    *0x801200(,%eax,4)
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80033b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80033f:	eb d9                	jmp    80031a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800344:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800348:	eb d0                	jmp    80031a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	0f b6 d2             	movzbl %dl,%edx
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800350:	b8 00 00 00 00       	mov    $0x0,%eax
  800355:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800358:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80035b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80035f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800362:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800365:	83 f9 09             	cmp    $0x9,%ecx
  800368:	77 55                	ja     8003bf <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80036a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80036d:	eb e9                	jmp    800358 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80036f:	8b 45 14             	mov    0x14(%ebp),%eax
  800372:	8b 00                	mov    (%eax),%eax
  800374:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800377:	8b 45 14             	mov    0x14(%ebp),%eax
  80037a:	8d 40 04             	lea    0x4(%eax),%eax
  80037d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800383:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800387:	79 91                	jns    80031a <vprintfmt+0x35>
				width = precision, precision = -1;
  800389:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80038c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800396:	eb 82                	jmp    80031a <vprintfmt+0x35>
  800398:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80039b:	85 c0                	test   %eax,%eax
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	0f 49 d0             	cmovns %eax,%edx
  8003a5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ab:	e9 6a ff ff ff       	jmp    80031a <vprintfmt+0x35>
  8003b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003ba:	e9 5b ff ff ff       	jmp    80031a <vprintfmt+0x35>
  8003bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003c5:	eb bc                	jmp    800383 <vprintfmt+0x9e>
			lflag++;
  8003c7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003cd:	e9 48 ff ff ff       	jmp    80031a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8d 78 04             	lea    0x4(%eax),%edi
  8003d8:	83 ec 08             	sub    $0x8,%esp
  8003db:	53                   	push   %ebx
  8003dc:	ff 30                	pushl  (%eax)
  8003de:	ff d6                	call   *%esi
			break;
  8003e0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003e3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003e6:	e9 cf 02 00 00       	jmp    8006ba <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	8d 78 04             	lea    0x4(%eax),%edi
  8003f1:	8b 00                	mov    (%eax),%eax
  8003f3:	99                   	cltd   
  8003f4:	31 d0                	xor    %edx,%eax
  8003f6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003f8:	83 f8 08             	cmp    $0x8,%eax
  8003fb:	7f 23                	jg     800420 <vprintfmt+0x13b>
  8003fd:	8b 14 85 60 13 80 00 	mov    0x801360(,%eax,4),%edx
  800404:	85 d2                	test   %edx,%edx
  800406:	74 18                	je     800420 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800408:	52                   	push   %edx
  800409:	68 5c 11 80 00       	push   $0x80115c
  80040e:	53                   	push   %ebx
  80040f:	56                   	push   %esi
  800410:	e8 b3 fe ff ff       	call   8002c8 <printfmt>
  800415:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800418:	89 7d 14             	mov    %edi,0x14(%ebp)
  80041b:	e9 9a 02 00 00       	jmp    8006ba <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800420:	50                   	push   %eax
  800421:	68 53 11 80 00       	push   $0x801153
  800426:	53                   	push   %ebx
  800427:	56                   	push   %esi
  800428:	e8 9b fe ff ff       	call   8002c8 <printfmt>
  80042d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800430:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800433:	e9 82 02 00 00       	jmp    8006ba <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	83 c0 04             	add    $0x4,%eax
  80043e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800446:	85 ff                	test   %edi,%edi
  800448:	b8 4c 11 80 00       	mov    $0x80114c,%eax
  80044d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800450:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800454:	0f 8e bd 00 00 00    	jle    800517 <vprintfmt+0x232>
  80045a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80045e:	75 0e                	jne    80046e <vprintfmt+0x189>
  800460:	89 75 08             	mov    %esi,0x8(%ebp)
  800463:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800466:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800469:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80046c:	eb 6d                	jmp    8004db <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046e:	83 ec 08             	sub    $0x8,%esp
  800471:	ff 75 d0             	pushl  -0x30(%ebp)
  800474:	57                   	push   %edi
  800475:	e8 6e 03 00 00       	call   8007e8 <strnlen>
  80047a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80047d:	29 c1                	sub    %eax,%ecx
  80047f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800482:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800485:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800489:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80048c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80048f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800491:	eb 0f                	jmp    8004a2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	53                   	push   %ebx
  800497:	ff 75 e0             	pushl  -0x20(%ebp)
  80049a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80049c:	83 ef 01             	sub    $0x1,%edi
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	85 ff                	test   %edi,%edi
  8004a4:	7f ed                	jg     800493 <vprintfmt+0x1ae>
  8004a6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004ac:	85 c9                	test   %ecx,%ecx
  8004ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b3:	0f 49 c1             	cmovns %ecx,%eax
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8004bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004c1:	89 cb                	mov    %ecx,%ebx
  8004c3:	eb 16                	jmp    8004db <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004c9:	75 31                	jne    8004fc <vprintfmt+0x217>
					putch(ch, putdat);
  8004cb:	83 ec 08             	sub    $0x8,%esp
  8004ce:	ff 75 0c             	pushl  0xc(%ebp)
  8004d1:	50                   	push   %eax
  8004d2:	ff 55 08             	call   *0x8(%ebp)
  8004d5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d8:	83 eb 01             	sub    $0x1,%ebx
  8004db:	83 c7 01             	add    $0x1,%edi
  8004de:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8004e2:	0f be c2             	movsbl %dl,%eax
  8004e5:	85 c0                	test   %eax,%eax
  8004e7:	74 59                	je     800542 <vprintfmt+0x25d>
  8004e9:	85 f6                	test   %esi,%esi
  8004eb:	78 d8                	js     8004c5 <vprintfmt+0x1e0>
  8004ed:	83 ee 01             	sub    $0x1,%esi
  8004f0:	79 d3                	jns    8004c5 <vprintfmt+0x1e0>
  8004f2:	89 df                	mov    %ebx,%edi
  8004f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fa:	eb 37                	jmp    800533 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004fc:	0f be d2             	movsbl %dl,%edx
  8004ff:	83 ea 20             	sub    $0x20,%edx
  800502:	83 fa 5e             	cmp    $0x5e,%edx
  800505:	76 c4                	jbe    8004cb <vprintfmt+0x1e6>
					putch('?', putdat);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	ff 75 0c             	pushl  0xc(%ebp)
  80050d:	6a 3f                	push   $0x3f
  80050f:	ff 55 08             	call   *0x8(%ebp)
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	eb c1                	jmp    8004d8 <vprintfmt+0x1f3>
  800517:	89 75 08             	mov    %esi,0x8(%ebp)
  80051a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80051d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800520:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800523:	eb b6                	jmp    8004db <vprintfmt+0x1f6>
				putch(' ', putdat);
  800525:	83 ec 08             	sub    $0x8,%esp
  800528:	53                   	push   %ebx
  800529:	6a 20                	push   $0x20
  80052b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80052d:	83 ef 01             	sub    $0x1,%edi
  800530:	83 c4 10             	add    $0x10,%esp
  800533:	85 ff                	test   %edi,%edi
  800535:	7f ee                	jg     800525 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80053a:	89 45 14             	mov    %eax,0x14(%ebp)
  80053d:	e9 78 01 00 00       	jmp    8006ba <vprintfmt+0x3d5>
  800542:	89 df                	mov    %ebx,%edi
  800544:	8b 75 08             	mov    0x8(%ebp),%esi
  800547:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80054a:	eb e7                	jmp    800533 <vprintfmt+0x24e>
	if (lflag >= 2)
  80054c:	83 f9 01             	cmp    $0x1,%ecx
  80054f:	7e 3f                	jle    800590 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8b 50 04             	mov    0x4(%eax),%edx
  800557:	8b 00                	mov    (%eax),%eax
  800559:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 40 08             	lea    0x8(%eax),%eax
  800565:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800568:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056c:	79 5c                	jns    8005ca <vprintfmt+0x2e5>
				putch('-', putdat);
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	53                   	push   %ebx
  800572:	6a 2d                	push   $0x2d
  800574:	ff d6                	call   *%esi
				num = -(long long) num;
  800576:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800579:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057c:	f7 da                	neg    %edx
  80057e:	83 d1 00             	adc    $0x0,%ecx
  800581:	f7 d9                	neg    %ecx
  800583:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058b:	e9 10 01 00 00       	jmp    8006a0 <vprintfmt+0x3bb>
	else if (lflag)
  800590:	85 c9                	test   %ecx,%ecx
  800592:	75 1b                	jne    8005af <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 00                	mov    (%eax),%eax
  800599:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80059c:	89 c1                	mov    %eax,%ecx
  80059e:	c1 f9 1f             	sar    $0x1f,%ecx
  8005a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a7:	8d 40 04             	lea    0x4(%eax),%eax
  8005aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ad:	eb b9                	jmp    800568 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005af:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b2:	8b 00                	mov    (%eax),%eax
  8005b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b7:	89 c1                	mov    %eax,%ecx
  8005b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c2:	8d 40 04             	lea    0x4(%eax),%eax
  8005c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c8:	eb 9e                	jmp    800568 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d5:	e9 c6 00 00 00       	jmp    8006a0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8005da:	83 f9 01             	cmp    $0x1,%ecx
  8005dd:	7e 18                	jle    8005f7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8b 10                	mov    (%eax),%edx
  8005e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e7:	8d 40 08             	lea    0x8(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f2:	e9 a9 00 00 00       	jmp    8006a0 <vprintfmt+0x3bb>
	else if (lflag)
  8005f7:	85 c9                	test   %ecx,%ecx
  8005f9:	75 1a                	jne    800615 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	b9 00 00 00 00       	mov    $0x0,%ecx
  800605:	8d 40 04             	lea    0x4(%eax),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80060b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800610:	e9 8b 00 00 00       	jmp    8006a0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80061f:	8d 40 04             	lea    0x4(%eax),%eax
  800622:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800625:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062a:	eb 74                	jmp    8006a0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80062c:	83 f9 01             	cmp    $0x1,%ecx
  80062f:	7e 15                	jle    800646 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	8b 48 04             	mov    0x4(%eax),%ecx
  800639:	8d 40 08             	lea    0x8(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80063f:	b8 08 00 00 00       	mov    $0x8,%eax
  800644:	eb 5a                	jmp    8006a0 <vprintfmt+0x3bb>
	else if (lflag)
  800646:	85 c9                	test   %ecx,%ecx
  800648:	75 17                	jne    800661 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065a:	b8 08 00 00 00       	mov    $0x8,%eax
  80065f:	eb 3f                	jmp    8006a0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800661:	8b 45 14             	mov    0x14(%ebp),%eax
  800664:	8b 10                	mov    (%eax),%edx
  800666:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066b:	8d 40 04             	lea    0x4(%eax),%eax
  80066e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800671:	b8 08 00 00 00       	mov    $0x8,%eax
  800676:	eb 28                	jmp    8006a0 <vprintfmt+0x3bb>
			putch('0', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 30                	push   $0x30
  80067e:	ff d6                	call   *%esi
			putch('x', putdat);
  800680:	83 c4 08             	add    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 78                	push   $0x78
  800686:	ff d6                	call   *%esi
			num = (unsigned long long)
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800692:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006a7:	57                   	push   %edi
  8006a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ab:	50                   	push   %eax
  8006ac:	51                   	push   %ecx
  8006ad:	52                   	push   %edx
  8006ae:	89 da                	mov    %ebx,%edx
  8006b0:	89 f0                	mov    %esi,%eax
  8006b2:	e8 45 fb ff ff       	call   8001fc <printnum>
			break;
  8006b7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006bd:	83 c7 01             	add    $0x1,%edi
  8006c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c4:	83 f8 25             	cmp    $0x25,%eax
  8006c7:	0f 84 2f fc ff ff    	je     8002fc <vprintfmt+0x17>
			if (ch == '\0')
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	0f 84 8b 00 00 00    	je     800760 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	53                   	push   %ebx
  8006d9:	50                   	push   %eax
  8006da:	ff d6                	call   *%esi
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	eb dc                	jmp    8006bd <vprintfmt+0x3d8>
	if (lflag >= 2)
  8006e1:	83 f9 01             	cmp    $0x1,%ecx
  8006e4:	7e 15                	jle    8006fb <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8006e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e9:	8b 10                	mov    (%eax),%edx
  8006eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ee:	8d 40 08             	lea    0x8(%eax),%eax
  8006f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006f9:	eb a5                	jmp    8006a0 <vprintfmt+0x3bb>
	else if (lflag)
  8006fb:	85 c9                	test   %ecx,%ecx
  8006fd:	75 17                	jne    800716 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	b9 00 00 00 00       	mov    $0x0,%ecx
  800709:	8d 40 04             	lea    0x4(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070f:	b8 10 00 00 00       	mov    $0x10,%eax
  800714:	eb 8a                	jmp    8006a0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8b 10                	mov    (%eax),%edx
  80071b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800720:	8d 40 04             	lea    0x4(%eax),%eax
  800723:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800726:	b8 10 00 00 00       	mov    $0x10,%eax
  80072b:	e9 70 ff ff ff       	jmp    8006a0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800730:	83 ec 08             	sub    $0x8,%esp
  800733:	53                   	push   %ebx
  800734:	6a 25                	push   $0x25
  800736:	ff d6                	call   *%esi
			break;
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	e9 7a ff ff ff       	jmp    8006ba <vprintfmt+0x3d5>
			putch('%', putdat);
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	53                   	push   %ebx
  800744:	6a 25                	push   $0x25
  800746:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	89 f8                	mov    %edi,%eax
  80074d:	eb 03                	jmp    800752 <vprintfmt+0x46d>
  80074f:	83 e8 01             	sub    $0x1,%eax
  800752:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800756:	75 f7                	jne    80074f <vprintfmt+0x46a>
  800758:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80075b:	e9 5a ff ff ff       	jmp    8006ba <vprintfmt+0x3d5>
}
  800760:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800763:	5b                   	pop    %ebx
  800764:	5e                   	pop    %esi
  800765:	5f                   	pop    %edi
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800768:	55                   	push   %ebp
  800769:	89 e5                	mov    %esp,%ebp
  80076b:	83 ec 18             	sub    $0x18,%esp
  80076e:	8b 45 08             	mov    0x8(%ebp),%eax
  800771:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800774:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800777:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80077b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80077e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800785:	85 c0                	test   %eax,%eax
  800787:	74 26                	je     8007af <vsnprintf+0x47>
  800789:	85 d2                	test   %edx,%edx
  80078b:	7e 22                	jle    8007af <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078d:	ff 75 14             	pushl  0x14(%ebp)
  800790:	ff 75 10             	pushl  0x10(%ebp)
  800793:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	68 ab 02 80 00       	push   $0x8002ab
  80079c:	e8 44 fb ff ff       	call   8002e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007aa:	83 c4 10             	add    $0x10,%esp
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    
		return -E_INVAL;
  8007af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b4:	eb f7                	jmp    8007ad <vsnprintf+0x45>

008007b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007bc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007bf:	50                   	push   %eax
  8007c0:	ff 75 10             	pushl  0x10(%ebp)
  8007c3:	ff 75 0c             	pushl  0xc(%ebp)
  8007c6:	ff 75 08             	pushl  0x8(%ebp)
  8007c9:	e8 9a ff ff ff       	call   800768 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	eb 03                	jmp    8007e0 <strlen+0x10>
		n++;
  8007dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e4:	75 f7                	jne    8007dd <strlen+0xd>
	return n;
}
  8007e6:	5d                   	pop    %ebp
  8007e7:	c3                   	ret    

008007e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f6:	eb 03                	jmp    8007fb <strnlen+0x13>
		n++;
  8007f8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 d0                	cmp    %edx,%eax
  8007fd:	74 06                	je     800805 <strnlen+0x1d>
  8007ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800803:	75 f3                	jne    8007f8 <strnlen+0x10>
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	89 c2                	mov    %eax,%edx
  800813:	83 c1 01             	add    $0x1,%ecx
  800816:	83 c2 01             	add    $0x1,%edx
  800819:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80081d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800820:	84 db                	test   %bl,%bl
  800822:	75 ef                	jne    800813 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	53                   	push   %ebx
  80082f:	e8 9c ff ff ff       	call   8007d0 <strlen>
  800834:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800837:	ff 75 0c             	pushl  0xc(%ebp)
  80083a:	01 d8                	add    %ebx,%eax
  80083c:	50                   	push   %eax
  80083d:	e8 c5 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800842:	89 d8                	mov    %ebx,%eax
  800844:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800847:	c9                   	leave  
  800848:	c3                   	ret    

00800849 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	56                   	push   %esi
  80084d:	53                   	push   %ebx
  80084e:	8b 75 08             	mov    0x8(%ebp),%esi
  800851:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800854:	89 f3                	mov    %esi,%ebx
  800856:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800859:	89 f2                	mov    %esi,%edx
  80085b:	eb 0f                	jmp    80086c <strncpy+0x23>
		*dst++ = *src;
  80085d:	83 c2 01             	add    $0x1,%edx
  800860:	0f b6 01             	movzbl (%ecx),%eax
  800863:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800866:	80 39 01             	cmpb   $0x1,(%ecx)
  800869:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  80086c:	39 da                	cmp    %ebx,%edx
  80086e:	75 ed                	jne    80085d <strncpy+0x14>
	}
	return ret;
}
  800870:	89 f0                	mov    %esi,%eax
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5d                   	pop    %ebp
  800875:	c3                   	ret    

00800876 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800881:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800884:	89 f0                	mov    %esi,%eax
  800886:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80088a:	85 c9                	test   %ecx,%ecx
  80088c:	75 0b                	jne    800899 <strlcpy+0x23>
  80088e:	eb 17                	jmp    8008a7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	83 c0 01             	add    $0x1,%eax
  800896:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800899:	39 d8                	cmp    %ebx,%eax
  80089b:	74 07                	je     8008a4 <strlcpy+0x2e>
  80089d:	0f b6 0a             	movzbl (%edx),%ecx
  8008a0:	84 c9                	test   %cl,%cl
  8008a2:	75 ec                	jne    800890 <strlcpy+0x1a>
		*dst = '\0';
  8008a4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008a7:	29 f0                	sub    %esi,%eax
}
  8008a9:	5b                   	pop    %ebx
  8008aa:	5e                   	pop    %esi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b6:	eb 06                	jmp    8008be <strcmp+0x11>
		p++, q++;
  8008b8:	83 c1 01             	add    $0x1,%ecx
  8008bb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008be:	0f b6 01             	movzbl (%ecx),%eax
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 04                	je     8008c9 <strcmp+0x1c>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	74 ef                	je     8008b8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c9:	0f b6 c0             	movzbl %al,%eax
  8008cc:	0f b6 12             	movzbl (%edx),%edx
  8008cf:	29 d0                	sub    %edx,%eax
}
  8008d1:	5d                   	pop    %ebp
  8008d2:	c3                   	ret    

008008d3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	53                   	push   %ebx
  8008d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008dd:	89 c3                	mov    %eax,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008e2:	eb 06                	jmp    8008ea <strncmp+0x17>
		n--, p++, q++;
  8008e4:	83 c0 01             	add    $0x1,%eax
  8008e7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ea:	39 d8                	cmp    %ebx,%eax
  8008ec:	74 16                	je     800904 <strncmp+0x31>
  8008ee:	0f b6 08             	movzbl (%eax),%ecx
  8008f1:	84 c9                	test   %cl,%cl
  8008f3:	74 04                	je     8008f9 <strncmp+0x26>
  8008f5:	3a 0a                	cmp    (%edx),%cl
  8008f7:	74 eb                	je     8008e4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f9:	0f b6 00             	movzbl (%eax),%eax
  8008fc:	0f b6 12             	movzbl (%edx),%edx
  8008ff:	29 d0                	sub    %edx,%eax
}
  800901:	5b                   	pop    %ebx
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    
		return 0;
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
  800909:	eb f6                	jmp    800901 <strncmp+0x2e>

0080090b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800915:	0f b6 10             	movzbl (%eax),%edx
  800918:	84 d2                	test   %dl,%dl
  80091a:	74 09                	je     800925 <strchr+0x1a>
		if (*s == c)
  80091c:	38 ca                	cmp    %cl,%dl
  80091e:	74 0a                	je     80092a <strchr+0x1f>
	for (; *s; s++)
  800920:	83 c0 01             	add    $0x1,%eax
  800923:	eb f0                	jmp    800915 <strchr+0xa>
			return (char *) s;
	return 0;
  800925:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	8b 45 08             	mov    0x8(%ebp),%eax
  800932:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800936:	eb 03                	jmp    80093b <strfind+0xf>
  800938:	83 c0 01             	add    $0x1,%eax
  80093b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80093e:	38 ca                	cmp    %cl,%dl
  800940:	74 04                	je     800946 <strfind+0x1a>
  800942:	84 d2                	test   %dl,%dl
  800944:	75 f2                	jne    800938 <strfind+0xc>
			break;
	return (char *) s;
}
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800951:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 13                	je     80096b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800958:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80095e:	75 05                	jne    800965 <memset+0x1d>
  800960:	f6 c1 03             	test   $0x3,%cl
  800963:	74 0d                	je     800972 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
  800968:	fc                   	cld    
  800969:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096b:	89 f8                	mov    %edi,%eax
  80096d:	5b                   	pop    %ebx
  80096e:	5e                   	pop    %esi
  80096f:	5f                   	pop    %edi
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    
		c &= 0xFF;
  800972:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800976:	89 d3                	mov    %edx,%ebx
  800978:	c1 e3 08             	shl    $0x8,%ebx
  80097b:	89 d0                	mov    %edx,%eax
  80097d:	c1 e0 18             	shl    $0x18,%eax
  800980:	89 d6                	mov    %edx,%esi
  800982:	c1 e6 10             	shl    $0x10,%esi
  800985:	09 f0                	or     %esi,%eax
  800987:	09 c2                	or     %eax,%edx
  800989:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  80098b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80098e:	89 d0                	mov    %edx,%eax
  800990:	fc                   	cld    
  800991:	f3 ab                	rep stos %eax,%es:(%edi)
  800993:	eb d6                	jmp    80096b <memset+0x23>

00800995 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009a3:	39 c6                	cmp    %eax,%esi
  8009a5:	73 35                	jae    8009dc <memmove+0x47>
  8009a7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009aa:	39 c2                	cmp    %eax,%edx
  8009ac:	76 2e                	jbe    8009dc <memmove+0x47>
		s += n;
		d += n;
  8009ae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b1:	89 d6                	mov    %edx,%esi
  8009b3:	09 fe                	or     %edi,%esi
  8009b5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bb:	74 0c                	je     8009c9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bd:	83 ef 01             	sub    $0x1,%edi
  8009c0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009c3:	fd                   	std    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c6:	fc                   	cld    
  8009c7:	eb 21                	jmp    8009ea <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c9:	f6 c1 03             	test   $0x3,%cl
  8009cc:	75 ef                	jne    8009bd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ce:	83 ef 04             	sub    $0x4,%edi
  8009d1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009d4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009d7:	fd                   	std    
  8009d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009da:	eb ea                	jmp    8009c6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009dc:	89 f2                	mov    %esi,%edx
  8009de:	09 c2                	or     %eax,%edx
  8009e0:	f6 c2 03             	test   $0x3,%dl
  8009e3:	74 09                	je     8009ee <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e5:	89 c7                	mov    %eax,%edi
  8009e7:	fc                   	cld    
  8009e8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ea:	5e                   	pop    %esi
  8009eb:	5f                   	pop    %edi
  8009ec:	5d                   	pop    %ebp
  8009ed:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ee:	f6 c1 03             	test   $0x3,%cl
  8009f1:	75 f2                	jne    8009e5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009f3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009f6:	89 c7                	mov    %eax,%edi
  8009f8:	fc                   	cld    
  8009f9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009fb:	eb ed                	jmp    8009ea <memmove+0x55>

008009fd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a00:	ff 75 10             	pushl  0x10(%ebp)
  800a03:	ff 75 0c             	pushl  0xc(%ebp)
  800a06:	ff 75 08             	pushl  0x8(%ebp)
  800a09:	e8 87 ff ff ff       	call   800995 <memmove>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	56                   	push   %esi
  800a14:	53                   	push   %ebx
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1b:	89 c6                	mov    %eax,%esi
  800a1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a20:	39 f0                	cmp    %esi,%eax
  800a22:	74 1c                	je     800a40 <memcmp+0x30>
		if (*s1 != *s2)
  800a24:	0f b6 08             	movzbl (%eax),%ecx
  800a27:	0f b6 1a             	movzbl (%edx),%ebx
  800a2a:	38 d9                	cmp    %bl,%cl
  800a2c:	75 08                	jne    800a36 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a2e:	83 c0 01             	add    $0x1,%eax
  800a31:	83 c2 01             	add    $0x1,%edx
  800a34:	eb ea                	jmp    800a20 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a36:	0f b6 c1             	movzbl %cl,%eax
  800a39:	0f b6 db             	movzbl %bl,%ebx
  800a3c:	29 d8                	sub    %ebx,%eax
  800a3e:	eb 05                	jmp    800a45 <memcmp+0x35>
	}

	return 0;
  800a40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a45:	5b                   	pop    %ebx
  800a46:	5e                   	pop    %esi
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a52:	89 c2                	mov    %eax,%edx
  800a54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a57:	39 d0                	cmp    %edx,%eax
  800a59:	73 09                	jae    800a64 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a5b:	38 08                	cmp    %cl,(%eax)
  800a5d:	74 05                	je     800a64 <memfind+0x1b>
	for (; s < ends; s++)
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	eb f3                	jmp    800a57 <memfind+0xe>
			break;
	return (void *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	57                   	push   %edi
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a72:	eb 03                	jmp    800a77 <strtol+0x11>
		s++;
  800a74:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a77:	0f b6 01             	movzbl (%ecx),%eax
  800a7a:	3c 20                	cmp    $0x20,%al
  800a7c:	74 f6                	je     800a74 <strtol+0xe>
  800a7e:	3c 09                	cmp    $0x9,%al
  800a80:	74 f2                	je     800a74 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a82:	3c 2b                	cmp    $0x2b,%al
  800a84:	74 2e                	je     800ab4 <strtol+0x4e>
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a8b:	3c 2d                	cmp    $0x2d,%al
  800a8d:	74 2f                	je     800abe <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a8f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a95:	75 05                	jne    800a9c <strtol+0x36>
  800a97:	80 39 30             	cmpb   $0x30,(%ecx)
  800a9a:	74 2c                	je     800ac8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a9c:	85 db                	test   %ebx,%ebx
  800a9e:	75 0a                	jne    800aaa <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aa0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800aa5:	80 39 30             	cmpb   $0x30,(%ecx)
  800aa8:	74 28                	je     800ad2 <strtol+0x6c>
		base = 10;
  800aaa:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ab2:	eb 50                	jmp    800b04 <strtol+0x9e>
		s++;
  800ab4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ab7:	bf 00 00 00 00       	mov    $0x0,%edi
  800abc:	eb d1                	jmp    800a8f <strtol+0x29>
		s++, neg = 1;
  800abe:	83 c1 01             	add    $0x1,%ecx
  800ac1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ac6:	eb c7                	jmp    800a8f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ac8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800acc:	74 0e                	je     800adc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ace:	85 db                	test   %ebx,%ebx
  800ad0:	75 d8                	jne    800aaa <strtol+0x44>
		s++, base = 8;
  800ad2:	83 c1 01             	add    $0x1,%ecx
  800ad5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ada:	eb ce                	jmp    800aaa <strtol+0x44>
		s += 2, base = 16;
  800adc:	83 c1 02             	add    $0x2,%ecx
  800adf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ae4:	eb c4                	jmp    800aaa <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ae6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae9:	89 f3                	mov    %esi,%ebx
  800aeb:	80 fb 19             	cmp    $0x19,%bl
  800aee:	77 29                	ja     800b19 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800af0:	0f be d2             	movsbl %dl,%edx
  800af3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800af6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800af9:	7d 30                	jge    800b2b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800afb:	83 c1 01             	add    $0x1,%ecx
  800afe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b02:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b04:	0f b6 11             	movzbl (%ecx),%edx
  800b07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b0a:	89 f3                	mov    %esi,%ebx
  800b0c:	80 fb 09             	cmp    $0x9,%bl
  800b0f:	77 d5                	ja     800ae6 <strtol+0x80>
			dig = *s - '0';
  800b11:	0f be d2             	movsbl %dl,%edx
  800b14:	83 ea 30             	sub    $0x30,%edx
  800b17:	eb dd                	jmp    800af6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b1c:	89 f3                	mov    %esi,%ebx
  800b1e:	80 fb 19             	cmp    $0x19,%bl
  800b21:	77 08                	ja     800b2b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b23:	0f be d2             	movsbl %dl,%edx
  800b26:	83 ea 37             	sub    $0x37,%edx
  800b29:	eb cb                	jmp    800af6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b2f:	74 05                	je     800b36 <strtol+0xd0>
		*endptr = (char *) s;
  800b31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b34:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	f7 da                	neg    %edx
  800b3a:	85 ff                	test   %edi,%edi
  800b3c:	0f 45 c2             	cmovne %edx,%eax
}
  800b3f:	5b                   	pop    %ebx
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	89 c7                	mov    %eax,%edi
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    

00800b62 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b68:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b72:	89 d1                	mov    %edx,%ecx
  800b74:	89 d3                	mov    %edx,%ebx
  800b76:	89 d7                	mov    %edx,%edi
  800b78:	89 d6                	mov    %edx,%esi
  800b7a:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b92:	b8 03 00 00 00       	mov    $0x3,%eax
  800b97:	89 cb                	mov    %ecx,%ebx
  800b99:	89 cf                	mov    %ecx,%edi
  800b9b:	89 ce                	mov    %ecx,%esi
  800b9d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b9f:	85 c0                	test   %eax,%eax
  800ba1:	7f 08                	jg     800bab <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ba3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba6:	5b                   	pop    %ebx
  800ba7:	5e                   	pop    %esi
  800ba8:	5f                   	pop    %edi
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bab:	83 ec 0c             	sub    $0xc,%esp
  800bae:	50                   	push   %eax
  800baf:	6a 03                	push   $0x3
  800bb1:	68 84 13 80 00       	push   $0x801384
  800bb6:	6a 23                	push   $0x23
  800bb8:	68 a1 13 80 00       	push   $0x8013a1
  800bbd:	e8 4b f5 ff ff       	call   80010d <_panic>

00800bc2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd2:	89 d1                	mov    %edx,%ecx
  800bd4:	89 d3                	mov    %edx,%ebx
  800bd6:	89 d7                	mov    %edx,%edi
  800bd8:	89 d6                	mov    %edx,%esi
  800bda:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bdc:	5b                   	pop    %ebx
  800bdd:	5e                   	pop    %esi
  800bde:	5f                   	pop    %edi
  800bdf:	5d                   	pop    %ebp
  800be0:	c3                   	ret    

00800be1 <sys_yield>:

void
sys_yield(void)
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	57                   	push   %edi
  800be5:	56                   	push   %esi
  800be6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800be7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bf1:	89 d1                	mov    %edx,%ecx
  800bf3:	89 d3                	mov    %edx,%ebx
  800bf5:	89 d7                	mov    %edx,%edi
  800bf7:	89 d6                	mov    %edx,%esi
  800bf9:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	57                   	push   %edi
  800c04:	56                   	push   %esi
  800c05:	53                   	push   %ebx
  800c06:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c09:	be 00 00 00 00       	mov    $0x0,%esi
  800c0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c14:	b8 04 00 00 00       	mov    $0x4,%eax
  800c19:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c1c:	89 f7                	mov    %esi,%edi
  800c1e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c20:	85 c0                	test   %eax,%eax
  800c22:	7f 08                	jg     800c2c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c27:	5b                   	pop    %ebx
  800c28:	5e                   	pop    %esi
  800c29:	5f                   	pop    %edi
  800c2a:	5d                   	pop    %ebp
  800c2b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c2c:	83 ec 0c             	sub    $0xc,%esp
  800c2f:	50                   	push   %eax
  800c30:	6a 04                	push   $0x4
  800c32:	68 84 13 80 00       	push   $0x801384
  800c37:	6a 23                	push   $0x23
  800c39:	68 a1 13 80 00       	push   $0x8013a1
  800c3e:	e8 ca f4 ff ff       	call   80010d <_panic>

00800c43 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c52:	b8 05 00 00 00       	mov    $0x5,%eax
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c5a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c5d:	8b 75 18             	mov    0x18(%ebp),%esi
  800c60:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c62:	85 c0                	test   %eax,%eax
  800c64:	7f 08                	jg     800c6e <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c69:	5b                   	pop    %ebx
  800c6a:	5e                   	pop    %esi
  800c6b:	5f                   	pop    %edi
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6e:	83 ec 0c             	sub    $0xc,%esp
  800c71:	50                   	push   %eax
  800c72:	6a 05                	push   $0x5
  800c74:	68 84 13 80 00       	push   $0x801384
  800c79:	6a 23                	push   $0x23
  800c7b:	68 a1 13 80 00       	push   $0x8013a1
  800c80:	e8 88 f4 ff ff       	call   80010d <_panic>

00800c85 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7f 08                	jg     800cb0 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 06                	push   $0x6
  800cb6:	68 84 13 80 00       	push   $0x801384
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 a1 13 80 00       	push   $0x8013a1
  800cc2:	e8 46 f4 ff ff       	call   80010d <_panic>

00800cc7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	57                   	push   %edi
  800ccb:	56                   	push   %esi
  800ccc:	53                   	push   %ebx
  800ccd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce0:	89 df                	mov    %ebx,%edi
  800ce2:	89 de                	mov    %ebx,%esi
  800ce4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	7f 08                	jg     800cf2 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf2:	83 ec 0c             	sub    $0xc,%esp
  800cf5:	50                   	push   %eax
  800cf6:	6a 08                	push   $0x8
  800cf8:	68 84 13 80 00       	push   $0x801384
  800cfd:	6a 23                	push   $0x23
  800cff:	68 a1 13 80 00       	push   $0x8013a1
  800d04:	e8 04 f4 ff ff       	call   80010d <_panic>

00800d09 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	57                   	push   %edi
  800d0d:	56                   	push   %esi
  800d0e:	53                   	push   %ebx
  800d0f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d12:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800d22:	89 df                	mov    %ebx,%edi
  800d24:	89 de                	mov    %ebx,%esi
  800d26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7f 08                	jg     800d34 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 09                	push   $0x9
  800d3a:	68 84 13 80 00       	push   $0x801384
  800d3f:	6a 23                	push   $0x23
  800d41:	68 a1 13 80 00       	push   $0x8013a1
  800d46:	e8 c2 f3 ff ff       	call   80010d <_panic>

00800d4b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d51:	8b 55 08             	mov    0x8(%ebp),%edx
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5c:	be 00 00 00 00       	mov    $0x0,%esi
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d67:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d69:	5b                   	pop    %ebx
  800d6a:	5e                   	pop    %esi
  800d6b:	5f                   	pop    %edi
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	57                   	push   %edi
  800d72:	56                   	push   %esi
  800d73:	53                   	push   %ebx
  800d74:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d77:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d84:	89 cb                	mov    %ecx,%ebx
  800d86:	89 cf                	mov    %ecx,%edi
  800d88:	89 ce                	mov    %ecx,%esi
  800d8a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	7f 08                	jg     800d98 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d93:	5b                   	pop    %ebx
  800d94:	5e                   	pop    %esi
  800d95:	5f                   	pop    %edi
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d98:	83 ec 0c             	sub    $0xc,%esp
  800d9b:	50                   	push   %eax
  800d9c:	6a 0c                	push   $0xc
  800d9e:	68 84 13 80 00       	push   $0x801384
  800da3:	6a 23                	push   $0x23
  800da5:	68 a1 13 80 00       	push   $0x8013a1
  800daa:	e8 5e f3 ff ff       	call   80010d <_panic>

00800daf <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800db5:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800dbc:	74 20                	je     800dde <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	a3 08 20 80 00       	mov    %eax,0x802008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800dc6:	83 ec 08             	sub    $0x8,%esp
  800dc9:	68 1e 0e 80 00       	push   $0x800e1e
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 34 ff ff ff       	call   800d09 <sys_env_set_pgfault_upcall>
  800dd5:	83 c4 10             	add    $0x10,%esp
  800dd8:	85 c0                	test   %eax,%eax
  800dda:	78 2e                	js     800e0a <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800dde:	83 ec 04             	sub    $0x4,%esp
  800de1:	6a 07                	push   $0x7
  800de3:	68 00 f0 bf ee       	push   $0xeebff000
  800de8:	6a 00                	push   $0x0
  800dea:	e8 11 fe ff ff       	call   800c00 <sys_page_alloc>
  800def:	83 c4 10             	add    $0x10,%esp
  800df2:	85 c0                	test   %eax,%eax
  800df4:	79 c8                	jns    800dbe <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800df6:	83 ec 04             	sub    $0x4,%esp
  800df9:	68 b0 13 80 00       	push   $0x8013b0
  800dfe:	6a 21                	push   $0x21
  800e00:	68 14 14 80 00       	push   $0x801414
  800e05:	e8 03 f3 ff ff       	call   80010d <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800e0a:	83 ec 04             	sub    $0x4,%esp
  800e0d:	68 dc 13 80 00       	push   $0x8013dc
  800e12:	6a 27                	push   $0x27
  800e14:	68 14 14 80 00       	push   $0x801414
  800e19:	e8 ef f2 ff ff       	call   80010d <_panic>

00800e1e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e1e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e1f:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800e24:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e26:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800e29:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800e2d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800e30:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  800e34:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800e38:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800e3a:	83 c4 08             	add    $0x8,%esp
	popal
  800e3d:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800e3e:	83 c4 04             	add    $0x4,%esp
	popfl
  800e41:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e42:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e43:	c3                   	ret    
  800e44:	66 90                	xchg   %ax,%ax
  800e46:	66 90                	xchg   %ax,%ax
  800e48:	66 90                	xchg   %ax,%ax
  800e4a:	66 90                	xchg   %ax,%ax
  800e4c:	66 90                	xchg   %ax,%ax
  800e4e:	66 90                	xchg   %ax,%ax

00800e50 <__udivdi3>:
  800e50:	55                   	push   %ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 1c             	sub    $0x1c,%esp
  800e57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e67:	85 d2                	test   %edx,%edx
  800e69:	75 35                	jne    800ea0 <__udivdi3+0x50>
  800e6b:	39 f3                	cmp    %esi,%ebx
  800e6d:	0f 87 bd 00 00 00    	ja     800f30 <__udivdi3+0xe0>
  800e73:	85 db                	test   %ebx,%ebx
  800e75:	89 d9                	mov    %ebx,%ecx
  800e77:	75 0b                	jne    800e84 <__udivdi3+0x34>
  800e79:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7e:	31 d2                	xor    %edx,%edx
  800e80:	f7 f3                	div    %ebx
  800e82:	89 c1                	mov    %eax,%ecx
  800e84:	31 d2                	xor    %edx,%edx
  800e86:	89 f0                	mov    %esi,%eax
  800e88:	f7 f1                	div    %ecx
  800e8a:	89 c6                	mov    %eax,%esi
  800e8c:	89 e8                	mov    %ebp,%eax
  800e8e:	89 f7                	mov    %esi,%edi
  800e90:	f7 f1                	div    %ecx
  800e92:	89 fa                	mov    %edi,%edx
  800e94:	83 c4 1c             	add    $0x1c,%esp
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
  800e9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	39 f2                	cmp    %esi,%edx
  800ea2:	77 7c                	ja     800f20 <__udivdi3+0xd0>
  800ea4:	0f bd fa             	bsr    %edx,%edi
  800ea7:	83 f7 1f             	xor    $0x1f,%edi
  800eaa:	0f 84 98 00 00 00    	je     800f48 <__udivdi3+0xf8>
  800eb0:	89 f9                	mov    %edi,%ecx
  800eb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb7:	29 f8                	sub    %edi,%eax
  800eb9:	d3 e2                	shl    %cl,%edx
  800ebb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	89 da                	mov    %ebx,%edx
  800ec3:	d3 ea                	shr    %cl,%edx
  800ec5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ec9:	09 d1                	or     %edx,%ecx
  800ecb:	89 f2                	mov    %esi,%edx
  800ecd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ed1:	89 f9                	mov    %edi,%ecx
  800ed3:	d3 e3                	shl    %cl,%ebx
  800ed5:	89 c1                	mov    %eax,%ecx
  800ed7:	d3 ea                	shr    %cl,%edx
  800ed9:	89 f9                	mov    %edi,%ecx
  800edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800edf:	d3 e6                	shl    %cl,%esi
  800ee1:	89 eb                	mov    %ebp,%ebx
  800ee3:	89 c1                	mov    %eax,%ecx
  800ee5:	d3 eb                	shr    %cl,%ebx
  800ee7:	09 de                	or     %ebx,%esi
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	f7 74 24 08          	divl   0x8(%esp)
  800eef:	89 d6                	mov    %edx,%esi
  800ef1:	89 c3                	mov    %eax,%ebx
  800ef3:	f7 64 24 0c          	mull   0xc(%esp)
  800ef7:	39 d6                	cmp    %edx,%esi
  800ef9:	72 0c                	jb     800f07 <__udivdi3+0xb7>
  800efb:	89 f9                	mov    %edi,%ecx
  800efd:	d3 e5                	shl    %cl,%ebp
  800eff:	39 c5                	cmp    %eax,%ebp
  800f01:	73 5d                	jae    800f60 <__udivdi3+0x110>
  800f03:	39 d6                	cmp    %edx,%esi
  800f05:	75 59                	jne    800f60 <__udivdi3+0x110>
  800f07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f0a:	31 ff                	xor    %edi,%edi
  800f0c:	89 fa                	mov    %edi,%edx
  800f0e:	83 c4 1c             	add    $0x1c,%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    
  800f16:	8d 76 00             	lea    0x0(%esi),%esi
  800f19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800f20:	31 ff                	xor    %edi,%edi
  800f22:	31 c0                	xor    %eax,%eax
  800f24:	89 fa                	mov    %edi,%edx
  800f26:	83 c4 1c             	add    $0x1c,%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    
  800f2e:	66 90                	xchg   %ax,%ax
  800f30:	31 ff                	xor    %edi,%edi
  800f32:	89 e8                	mov    %ebp,%eax
  800f34:	89 f2                	mov    %esi,%edx
  800f36:	f7 f3                	div    %ebx
  800f38:	89 fa                	mov    %edi,%edx
  800f3a:	83 c4 1c             	add    $0x1c,%esp
  800f3d:	5b                   	pop    %ebx
  800f3e:	5e                   	pop    %esi
  800f3f:	5f                   	pop    %edi
  800f40:	5d                   	pop    %ebp
  800f41:	c3                   	ret    
  800f42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	72 06                	jb     800f52 <__udivdi3+0x102>
  800f4c:	31 c0                	xor    %eax,%eax
  800f4e:	39 eb                	cmp    %ebp,%ebx
  800f50:	77 d2                	ja     800f24 <__udivdi3+0xd4>
  800f52:	b8 01 00 00 00       	mov    $0x1,%eax
  800f57:	eb cb                	jmp    800f24 <__udivdi3+0xd4>
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	89 d8                	mov    %ebx,%eax
  800f62:	31 ff                	xor    %edi,%edi
  800f64:	eb be                	jmp    800f24 <__udivdi3+0xd4>
  800f66:	66 90                	xchg   %ax,%ax
  800f68:	66 90                	xchg   %ax,%ax
  800f6a:	66 90                	xchg   %ax,%ax
  800f6c:	66 90                	xchg   %ax,%ax
  800f6e:	66 90                	xchg   %ax,%ax

00800f70 <__umoddi3>:
  800f70:	55                   	push   %ebp
  800f71:	57                   	push   %edi
  800f72:	56                   	push   %esi
  800f73:	53                   	push   %ebx
  800f74:	83 ec 1c             	sub    $0x1c,%esp
  800f77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f87:	85 ed                	test   %ebp,%ebp
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	89 da                	mov    %ebx,%edx
  800f8d:	75 19                	jne    800fa8 <__umoddi3+0x38>
  800f8f:	39 df                	cmp    %ebx,%edi
  800f91:	0f 86 b1 00 00 00    	jbe    801048 <__umoddi3+0xd8>
  800f97:	f7 f7                	div    %edi
  800f99:	89 d0                	mov    %edx,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	83 c4 1c             	add    $0x1c,%esp
  800fa0:	5b                   	pop    %ebx
  800fa1:	5e                   	pop    %esi
  800fa2:	5f                   	pop    %edi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    
  800fa5:	8d 76 00             	lea    0x0(%esi),%esi
  800fa8:	39 dd                	cmp    %ebx,%ebp
  800faa:	77 f1                	ja     800f9d <__umoddi3+0x2d>
  800fac:	0f bd cd             	bsr    %ebp,%ecx
  800faf:	83 f1 1f             	xor    $0x1f,%ecx
  800fb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800fb6:	0f 84 b4 00 00 00    	je     801070 <__umoddi3+0x100>
  800fbc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc1:	89 c2                	mov    %eax,%edx
  800fc3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fc7:	29 c2                	sub    %eax,%edx
  800fc9:	89 c1                	mov    %eax,%ecx
  800fcb:	89 f8                	mov    %edi,%eax
  800fcd:	d3 e5                	shl    %cl,%ebp
  800fcf:	89 d1                	mov    %edx,%ecx
  800fd1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fd5:	d3 e8                	shr    %cl,%eax
  800fd7:	09 c5                	or     %eax,%ebp
  800fd9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800fdd:	89 c1                	mov    %eax,%ecx
  800fdf:	d3 e7                	shl    %cl,%edi
  800fe1:	89 d1                	mov    %edx,%ecx
  800fe3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800fe7:	89 df                	mov    %ebx,%edi
  800fe9:	d3 ef                	shr    %cl,%edi
  800feb:	89 c1                	mov    %eax,%ecx
  800fed:	89 f0                	mov    %esi,%eax
  800fef:	d3 e3                	shl    %cl,%ebx
  800ff1:	89 d1                	mov    %edx,%ecx
  800ff3:	89 fa                	mov    %edi,%edx
  800ff5:	d3 e8                	shr    %cl,%eax
  800ff7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffc:	09 d8                	or     %ebx,%eax
  800ffe:	f7 f5                	div    %ebp
  801000:	d3 e6                	shl    %cl,%esi
  801002:	89 d1                	mov    %edx,%ecx
  801004:	f7 64 24 08          	mull   0x8(%esp)
  801008:	39 d1                	cmp    %edx,%ecx
  80100a:	89 c3                	mov    %eax,%ebx
  80100c:	89 d7                	mov    %edx,%edi
  80100e:	72 06                	jb     801016 <__umoddi3+0xa6>
  801010:	75 0e                	jne    801020 <__umoddi3+0xb0>
  801012:	39 c6                	cmp    %eax,%esi
  801014:	73 0a                	jae    801020 <__umoddi3+0xb0>
  801016:	2b 44 24 08          	sub    0x8(%esp),%eax
  80101a:	19 ea                	sbb    %ebp,%edx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	89 c3                	mov    %eax,%ebx
  801020:	89 ca                	mov    %ecx,%edx
  801022:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801027:	29 de                	sub    %ebx,%esi
  801029:	19 fa                	sbb    %edi,%edx
  80102b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80102f:	89 d0                	mov    %edx,%eax
  801031:	d3 e0                	shl    %cl,%eax
  801033:	89 d9                	mov    %ebx,%ecx
  801035:	d3 ee                	shr    %cl,%esi
  801037:	d3 ea                	shr    %cl,%edx
  801039:	09 f0                	or     %esi,%eax
  80103b:	83 c4 1c             	add    $0x1c,%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5f                   	pop    %edi
  801041:	5d                   	pop    %ebp
  801042:	c3                   	ret    
  801043:	90                   	nop
  801044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801048:	85 ff                	test   %edi,%edi
  80104a:	89 f9                	mov    %edi,%ecx
  80104c:	75 0b                	jne    801059 <__umoddi3+0xe9>
  80104e:	b8 01 00 00 00       	mov    $0x1,%eax
  801053:	31 d2                	xor    %edx,%edx
  801055:	f7 f7                	div    %edi
  801057:	89 c1                	mov    %eax,%ecx
  801059:	89 d8                	mov    %ebx,%eax
  80105b:	31 d2                	xor    %edx,%edx
  80105d:	f7 f1                	div    %ecx
  80105f:	89 f0                	mov    %esi,%eax
  801061:	f7 f1                	div    %ecx
  801063:	e9 31 ff ff ff       	jmp    800f99 <__umoddi3+0x29>
  801068:	90                   	nop
  801069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801070:	39 dd                	cmp    %ebx,%ebp
  801072:	72 08                	jb     80107c <__umoddi3+0x10c>
  801074:	39 f7                	cmp    %esi,%edi
  801076:	0f 87 21 ff ff ff    	ja     800f9d <__umoddi3+0x2d>
  80107c:	89 da                	mov    %ebx,%edx
  80107e:	89 f0                	mov    %esi,%eax
  801080:	29 f8                	sub    %edi,%eax
  801082:	19 ea                	sbb    %ebp,%edx
  801084:	e9 14 ff ff ff       	jmp    800f9d <__umoddi3+0x2d>
