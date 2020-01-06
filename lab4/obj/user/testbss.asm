
obj/user/testbss：     文件格式 elf32-i386


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
  80002c:	e8 ab 00 00 00       	call   8000dc <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	68 20 10 80 00       	push   $0x801020
  80003e:	e8 cc 01 00 00       	call   80020f <cprintf>
  800043:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < ARRAYSIZE; i++)
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
  80004b:	83 3c 85 20 20 80 00 	cmpl   $0x0,0x802020(,%eax,4)
  800052:	00 
  800053:	75 63                	jne    8000b8 <umain+0x85>
	for (i = 0; i < ARRAYSIZE; i++)
  800055:	83 c0 01             	add    $0x1,%eax
  800058:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80005d:	75 ec                	jne    80004b <umain+0x18>
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  80005f:	b8 00 00 00 00       	mov    $0x0,%eax
		bigarray[i] = i;
  800064:	89 04 85 20 20 80 00 	mov    %eax,0x802020(,%eax,4)
	for (i = 0; i < ARRAYSIZE; i++)
  80006b:	83 c0 01             	add    $0x1,%eax
  80006e:	3d 00 00 10 00       	cmp    $0x100000,%eax
  800073:	75 ef                	jne    800064 <umain+0x31>
	for (i = 0; i < ARRAYSIZE; i++)
  800075:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != i)
  80007a:	39 04 85 20 20 80 00 	cmp    %eax,0x802020(,%eax,4)
  800081:	75 47                	jne    8000ca <umain+0x97>
	for (i = 0; i < ARRAYSIZE; i++)
  800083:	83 c0 01             	add    $0x1,%eax
  800086:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008b:	75 ed                	jne    80007a <umain+0x47>
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  80008d:	83 ec 0c             	sub    $0xc,%esp
  800090:	68 68 10 80 00       	push   $0x801068
  800095:	e8 75 01 00 00       	call   80020f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  80009a:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000a1:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	68 c7 10 80 00       	push   $0x8010c7
  8000ac:	6a 1a                	push   $0x1a
  8000ae:	68 b8 10 80 00       	push   $0x8010b8
  8000b3:	e8 7c 00 00 00       	call   800134 <_panic>
			panic("bigarray[%d] isn't cleared!\n", i);
  8000b8:	50                   	push   %eax
  8000b9:	68 9b 10 80 00       	push   $0x80109b
  8000be:	6a 11                	push   $0x11
  8000c0:	68 b8 10 80 00       	push   $0x8010b8
  8000c5:	e8 6a 00 00 00       	call   800134 <_panic>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000ca:	50                   	push   %eax
  8000cb:	68 40 10 80 00       	push   $0x801040
  8000d0:	6a 16                	push   $0x16
  8000d2:	68 b8 10 80 00       	push   $0x8010b8
  8000d7:	e8 58 00 00 00       	call   800134 <_panic>

008000dc <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e4:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000e7:	e8 fd 0a 00 00       	call   800be9 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8000ec:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f9:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fe:	85 db                	test   %ebx,%ebx
  800100:	7e 07                	jle    800109 <libmain+0x2d>
		binaryname = argv[0];
  800102:	8b 06                	mov    (%esi),%eax
  800104:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800109:	83 ec 08             	sub    $0x8,%esp
  80010c:	56                   	push   %esi
  80010d:	53                   	push   %ebx
  80010e:	e8 20 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800113:	e8 0a 00 00 00       	call   800122 <exit>
}
  800118:	83 c4 10             	add    $0x10,%esp
  80011b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011e:	5b                   	pop    %ebx
  80011f:	5e                   	pop    %esi
  800120:	5d                   	pop    %ebp
  800121:	c3                   	ret    

00800122 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800128:	6a 00                	push   $0x0
  80012a:	e8 79 0a 00 00       	call   800ba8 <sys_env_destroy>
}
  80012f:	83 c4 10             	add    $0x10,%esp
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800139:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80013c:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800142:	e8 a2 0a 00 00       	call   800be9 <sys_getenvid>
  800147:	83 ec 0c             	sub    $0xc,%esp
  80014a:	ff 75 0c             	pushl  0xc(%ebp)
  80014d:	ff 75 08             	pushl  0x8(%ebp)
  800150:	56                   	push   %esi
  800151:	50                   	push   %eax
  800152:	68 e8 10 80 00       	push   $0x8010e8
  800157:	e8 b3 00 00 00       	call   80020f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80015c:	83 c4 18             	add    $0x18,%esp
  80015f:	53                   	push   %ebx
  800160:	ff 75 10             	pushl  0x10(%ebp)
  800163:	e8 56 00 00 00       	call   8001be <vcprintf>
	cprintf("\n");
  800168:	c7 04 24 b6 10 80 00 	movl   $0x8010b6,(%esp)
  80016f:	e8 9b 00 00 00       	call   80020f <cprintf>
  800174:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800177:	cc                   	int3   
  800178:	eb fd                	jmp    800177 <_panic+0x43>

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 04             	sub    $0x4,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 13                	mov    (%ebx),%edx
  800186:	8d 42 01             	lea    0x1(%edx),%eax
  800189:	89 03                	mov    %eax,(%ebx)
  80018b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	74 09                	je     8001a2 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800199:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001a0:	c9                   	leave  
  8001a1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001a2:	83 ec 08             	sub    $0x8,%esp
  8001a5:	68 ff 00 00 00       	push   $0xff
  8001aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8001ad:	50                   	push   %eax
  8001ae:	e8 b8 09 00 00       	call   800b6b <sys_cputs>
		b->idx = 0;
  8001b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	eb db                	jmp    800199 <putch+0x1f>

008001be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ce:	00 00 00 
	b.cnt = 0;
  8001d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001db:	ff 75 0c             	pushl  0xc(%ebp)
  8001de:	ff 75 08             	pushl  0x8(%ebp)
  8001e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e7:	50                   	push   %eax
  8001e8:	68 7a 01 80 00       	push   $0x80017a
  8001ed:	e8 1a 01 00 00       	call   80030c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f2:	83 c4 08             	add    $0x8,%esp
  8001f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800201:	50                   	push   %eax
  800202:	e8 64 09 00 00       	call   800b6b <sys_cputs>

	return b.cnt;
}
  800207:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800215:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800218:	50                   	push   %eax
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 9d ff ff ff       	call   8001be <vcprintf>
	va_end(ap);

	return cnt;
}
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	57                   	push   %edi
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	83 ec 1c             	sub    $0x1c,%esp
  80022c:	89 c7                	mov    %eax,%edi
  80022e:	89 d6                	mov    %edx,%esi
  800230:	8b 45 08             	mov    0x8(%ebp),%eax
  800233:	8b 55 0c             	mov    0xc(%ebp),%edx
  800236:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800239:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80023f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800244:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800247:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80024a:	39 d3                	cmp    %edx,%ebx
  80024c:	72 05                	jb     800253 <printnum+0x30>
  80024e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800251:	77 7a                	ja     8002cd <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	ff 75 18             	pushl  0x18(%ebp)
  800259:	8b 45 14             	mov    0x14(%ebp),%eax
  80025c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80025f:	53                   	push   %ebx
  800260:	ff 75 10             	pushl  0x10(%ebp)
  800263:	83 ec 08             	sub    $0x8,%esp
  800266:	ff 75 e4             	pushl  -0x1c(%ebp)
  800269:	ff 75 e0             	pushl  -0x20(%ebp)
  80026c:	ff 75 dc             	pushl  -0x24(%ebp)
  80026f:	ff 75 d8             	pushl  -0x28(%ebp)
  800272:	e8 69 0b 00 00       	call   800de0 <__udivdi3>
  800277:	83 c4 18             	add    $0x18,%esp
  80027a:	52                   	push   %edx
  80027b:	50                   	push   %eax
  80027c:	89 f2                	mov    %esi,%edx
  80027e:	89 f8                	mov    %edi,%eax
  800280:	e8 9e ff ff ff       	call   800223 <printnum>
  800285:	83 c4 20             	add    $0x20,%esp
  800288:	eb 13                	jmp    80029d <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028a:	83 ec 08             	sub    $0x8,%esp
  80028d:	56                   	push   %esi
  80028e:	ff 75 18             	pushl  0x18(%ebp)
  800291:	ff d7                	call   *%edi
  800293:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800296:	83 eb 01             	sub    $0x1,%ebx
  800299:	85 db                	test   %ebx,%ebx
  80029b:	7f ed                	jg     80028a <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80029d:	83 ec 08             	sub    $0x8,%esp
  8002a0:	56                   	push   %esi
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8002aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b0:	e8 4b 0c 00 00       	call   800f00 <__umoddi3>
  8002b5:	83 c4 14             	add    $0x14,%esp
  8002b8:	0f be 80 0c 11 80 00 	movsbl 0x80110c(%eax),%eax
  8002bf:	50                   	push   %eax
  8002c0:	ff d7                	call   *%edi
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5f                   	pop    %edi
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	eb c4                	jmp    800296 <printnum+0x73>

008002d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	3b 50 04             	cmp    0x4(%eax),%edx
  8002e1:	73 0a                	jae    8002ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002e6:	89 08                	mov    %ecx,(%eax)
  8002e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8002eb:	88 02                	mov    %al,(%edx)
}
  8002ed:	5d                   	pop    %ebp
  8002ee:	c3                   	ret    

008002ef <printfmt>:
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002f8:	50                   	push   %eax
  8002f9:	ff 75 10             	pushl  0x10(%ebp)
  8002fc:	ff 75 0c             	pushl  0xc(%ebp)
  8002ff:	ff 75 08             	pushl  0x8(%ebp)
  800302:	e8 05 00 00 00       	call   80030c <vprintfmt>
}
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <vprintfmt>:
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 2c             	sub    $0x2c,%esp
  800315:	8b 75 08             	mov    0x8(%ebp),%esi
  800318:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80031b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80031e:	e9 c1 03 00 00       	jmp    8006e4 <vprintfmt+0x3d8>
		padc = ' ';
  800323:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800327:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80032e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800335:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8d 47 01             	lea    0x1(%edi),%eax
  800344:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800347:	0f b6 17             	movzbl (%edi),%edx
  80034a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034d:	3c 55                	cmp    $0x55,%al
  80034f:	0f 87 12 04 00 00    	ja     800767 <vprintfmt+0x45b>
  800355:	0f b6 c0             	movzbl %al,%eax
  800358:	ff 24 85 e0 11 80 00 	jmp    *0x8011e0(,%eax,4)
  80035f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800362:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800366:	eb d9                	jmp    800341 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80036b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80036f:	eb d0                	jmp    800341 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800371:	0f b6 d2             	movzbl %dl,%edx
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800377:	b8 00 00 00 00       	mov    $0x0,%eax
  80037c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80037f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800382:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800386:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038c:	83 f9 09             	cmp    $0x9,%ecx
  80038f:	77 55                	ja     8003e6 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800391:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800394:	eb e9                	jmp    80037f <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800396:	8b 45 14             	mov    0x14(%ebp),%eax
  800399:	8b 00                	mov    (%eax),%eax
  80039b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80039e:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a1:	8d 40 04             	lea    0x4(%eax),%eax
  8003a4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ae:	79 91                	jns    800341 <vprintfmt+0x35>
				width = precision, precision = -1;
  8003b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003bd:	eb 82                	jmp    800341 <vprintfmt+0x35>
  8003bf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c9:	0f 49 d0             	cmovns %eax,%edx
  8003cc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d2:	e9 6a ff ff ff       	jmp    800341 <vprintfmt+0x35>
  8003d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8003e1:	e9 5b ff ff ff       	jmp    800341 <vprintfmt+0x35>
  8003e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003ec:	eb bc                	jmp    8003aa <vprintfmt+0x9e>
			lflag++;
  8003ee:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f4:	e9 48 ff ff ff       	jmp    800341 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 78 04             	lea    0x4(%eax),%edi
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	53                   	push   %ebx
  800403:	ff 30                	pushl  (%eax)
  800405:	ff d6                	call   *%esi
			break;
  800407:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040d:	e9 cf 02 00 00       	jmp    8006e1 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800412:	8b 45 14             	mov    0x14(%ebp),%eax
  800415:	8d 78 04             	lea    0x4(%eax),%edi
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	99                   	cltd   
  80041b:	31 d0                	xor    %edx,%eax
  80041d:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80041f:	83 f8 08             	cmp    $0x8,%eax
  800422:	7f 23                	jg     800447 <vprintfmt+0x13b>
  800424:	8b 14 85 40 13 80 00 	mov    0x801340(,%eax,4),%edx
  80042b:	85 d2                	test   %edx,%edx
  80042d:	74 18                	je     800447 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80042f:	52                   	push   %edx
  800430:	68 2d 11 80 00       	push   $0x80112d
  800435:	53                   	push   %ebx
  800436:	56                   	push   %esi
  800437:	e8 b3 fe ff ff       	call   8002ef <printfmt>
  80043c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043f:	89 7d 14             	mov    %edi,0x14(%ebp)
  800442:	e9 9a 02 00 00       	jmp    8006e1 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800447:	50                   	push   %eax
  800448:	68 24 11 80 00       	push   $0x801124
  80044d:	53                   	push   %ebx
  80044e:	56                   	push   %esi
  80044f:	e8 9b fe ff ff       	call   8002ef <printfmt>
  800454:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800457:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045a:	e9 82 02 00 00       	jmp    8006e1 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80045f:	8b 45 14             	mov    0x14(%ebp),%eax
  800462:	83 c0 04             	add    $0x4,%eax
  800465:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800468:	8b 45 14             	mov    0x14(%ebp),%eax
  80046b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80046d:	85 ff                	test   %edi,%edi
  80046f:	b8 1d 11 80 00       	mov    $0x80111d,%eax
  800474:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800477:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80047b:	0f 8e bd 00 00 00    	jle    80053e <vprintfmt+0x232>
  800481:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800485:	75 0e                	jne    800495 <vprintfmt+0x189>
  800487:	89 75 08             	mov    %esi,0x8(%ebp)
  80048a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80048d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800490:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800493:	eb 6d                	jmp    800502 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	ff 75 d0             	pushl  -0x30(%ebp)
  80049b:	57                   	push   %edi
  80049c:	e8 6e 03 00 00       	call   80080f <strnlen>
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	29 c1                	sub    %eax,%ecx
  8004a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004b6:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b8:	eb 0f                	jmp    8004c9 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	83 ef 01             	sub    $0x1,%edi
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	85 ff                	test   %edi,%edi
  8004cb:	7f ed                	jg     8004ba <vprintfmt+0x1ae>
  8004cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8004d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8004d3:	85 c9                	test   %ecx,%ecx
  8004d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004da:	0f 49 c1             	cmovns %ecx,%eax
  8004dd:	29 c1                	sub    %eax,%ecx
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	89 cb                	mov    %ecx,%ebx
  8004ea:	eb 16                	jmp    800502 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f0:	75 31                	jne    800523 <vprintfmt+0x217>
					putch(ch, putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	ff 75 0c             	pushl  0xc(%ebp)
  8004f8:	50                   	push   %eax
  8004f9:	ff 55 08             	call   *0x8(%ebp)
  8004fc:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800509:	0f be c2             	movsbl %dl,%eax
  80050c:	85 c0                	test   %eax,%eax
  80050e:	74 59                	je     800569 <vprintfmt+0x25d>
  800510:	85 f6                	test   %esi,%esi
  800512:	78 d8                	js     8004ec <vprintfmt+0x1e0>
  800514:	83 ee 01             	sub    $0x1,%esi
  800517:	79 d3                	jns    8004ec <vprintfmt+0x1e0>
  800519:	89 df                	mov    %ebx,%edi
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800521:	eb 37                	jmp    80055a <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800523:	0f be d2             	movsbl %dl,%edx
  800526:	83 ea 20             	sub    $0x20,%edx
  800529:	83 fa 5e             	cmp    $0x5e,%edx
  80052c:	76 c4                	jbe    8004f2 <vprintfmt+0x1e6>
					putch('?', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	ff 75 0c             	pushl  0xc(%ebp)
  800534:	6a 3f                	push   $0x3f
  800536:	ff 55 08             	call   *0x8(%ebp)
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb c1                	jmp    8004ff <vprintfmt+0x1f3>
  80053e:	89 75 08             	mov    %esi,0x8(%ebp)
  800541:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800544:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800547:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054a:	eb b6                	jmp    800502 <vprintfmt+0x1f6>
				putch(' ', putdat);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	6a 20                	push   $0x20
  800552:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800554:	83 ef 01             	sub    $0x1,%edi
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	85 ff                	test   %edi,%edi
  80055c:	7f ee                	jg     80054c <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80055e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800561:	89 45 14             	mov    %eax,0x14(%ebp)
  800564:	e9 78 01 00 00       	jmp    8006e1 <vprintfmt+0x3d5>
  800569:	89 df                	mov    %ebx,%edi
  80056b:	8b 75 08             	mov    0x8(%ebp),%esi
  80056e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800571:	eb e7                	jmp    80055a <vprintfmt+0x24e>
	if (lflag >= 2)
  800573:	83 f9 01             	cmp    $0x1,%ecx
  800576:	7e 3f                	jle    8005b7 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 50 04             	mov    0x4(%eax),%edx
  80057e:	8b 00                	mov    (%eax),%eax
  800580:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800583:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8d 40 08             	lea    0x8(%eax),%eax
  80058c:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80058f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800593:	79 5c                	jns    8005f1 <vprintfmt+0x2e5>
				putch('-', putdat);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	53                   	push   %ebx
  800599:	6a 2d                	push   $0x2d
  80059b:	ff d6                	call   *%esi
				num = -(long long) num;
  80059d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a3:	f7 da                	neg    %edx
  8005a5:	83 d1 00             	adc    $0x0,%ecx
  8005a8:	f7 d9                	neg    %ecx
  8005aa:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b2:	e9 10 01 00 00       	jmp    8006c7 <vprintfmt+0x3bb>
	else if (lflag)
  8005b7:	85 c9                	test   %ecx,%ecx
  8005b9:	75 1b                	jne    8005d6 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 00                	mov    (%eax),%eax
  8005c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c3:	89 c1                	mov    %eax,%ecx
  8005c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8005c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 40 04             	lea    0x4(%eax),%eax
  8005d1:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d4:	eb b9                	jmp    80058f <vprintfmt+0x283>
		return va_arg(*ap, long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 00                	mov    (%eax),%eax
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	89 c1                	mov    %eax,%ecx
  8005e0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005e3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ef:	eb 9e                	jmp    80058f <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8005f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8005f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fc:	e9 c6 00 00 00       	jmp    8006c7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800601:	83 f9 01             	cmp    $0x1,%ecx
  800604:	7e 18                	jle    80061e <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8b 10                	mov    (%eax),%edx
  80060b:	8b 48 04             	mov    0x4(%eax),%ecx
  80060e:	8d 40 08             	lea    0x8(%eax),%eax
  800611:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800614:	b8 0a 00 00 00       	mov    $0xa,%eax
  800619:	e9 a9 00 00 00       	jmp    8006c7 <vprintfmt+0x3bb>
	else if (lflag)
  80061e:	85 c9                	test   %ecx,%ecx
  800620:	75 1a                	jne    80063c <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800622:	8b 45 14             	mov    0x14(%ebp),%eax
  800625:	8b 10                	mov    (%eax),%edx
  800627:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062c:	8d 40 04             	lea    0x4(%eax),%eax
  80062f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800632:	b8 0a 00 00 00       	mov    $0xa,%eax
  800637:	e9 8b 00 00 00       	jmp    8006c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8b 10                	mov    (%eax),%edx
  800641:	b9 00 00 00 00       	mov    $0x0,%ecx
  800646:	8d 40 04             	lea    0x4(%eax),%eax
  800649:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80064c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800651:	eb 74                	jmp    8006c7 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800653:	83 f9 01             	cmp    $0x1,%ecx
  800656:	7e 15                	jle    80066d <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	8b 48 04             	mov    0x4(%eax),%ecx
  800660:	8d 40 08             	lea    0x8(%eax),%eax
  800663:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800666:	b8 08 00 00 00       	mov    $0x8,%eax
  80066b:	eb 5a                	jmp    8006c7 <vprintfmt+0x3bb>
	else if (lflag)
  80066d:	85 c9                	test   %ecx,%ecx
  80066f:	75 17                	jne    800688 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 10                	mov    (%eax),%edx
  800676:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067b:	8d 40 04             	lea    0x4(%eax),%eax
  80067e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800681:	b8 08 00 00 00       	mov    $0x8,%eax
  800686:	eb 3f                	jmp    8006c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800698:	b8 08 00 00 00       	mov    $0x8,%eax
  80069d:	eb 28                	jmp    8006c7 <vprintfmt+0x3bb>
			putch('0', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	6a 30                	push   $0x30
  8006a5:	ff d6                	call   *%esi
			putch('x', putdat);
  8006a7:	83 c4 08             	add    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 78                	push   $0x78
  8006ad:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8b 10                	mov    (%eax),%edx
  8006b4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006b9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8006bc:	8d 40 04             	lea    0x4(%eax),%eax
  8006bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006ce:	57                   	push   %edi
  8006cf:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d2:	50                   	push   %eax
  8006d3:	51                   	push   %ecx
  8006d4:	52                   	push   %edx
  8006d5:	89 da                	mov    %ebx,%edx
  8006d7:	89 f0                	mov    %esi,%eax
  8006d9:	e8 45 fb ff ff       	call   800223 <printnum>
			break;
  8006de:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e4:	83 c7 01             	add    $0x1,%edi
  8006e7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006eb:	83 f8 25             	cmp    $0x25,%eax
  8006ee:	0f 84 2f fc ff ff    	je     800323 <vprintfmt+0x17>
			if (ch == '\0')
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	0f 84 8b 00 00 00    	je     800787 <vprintfmt+0x47b>
			putch(ch, putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	50                   	push   %eax
  800701:	ff d6                	call   *%esi
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	eb dc                	jmp    8006e4 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800708:	83 f9 01             	cmp    $0x1,%ecx
  80070b:	7e 15                	jle    800722 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  80070d:	8b 45 14             	mov    0x14(%ebp),%eax
  800710:	8b 10                	mov    (%eax),%edx
  800712:	8b 48 04             	mov    0x4(%eax),%ecx
  800715:	8d 40 08             	lea    0x8(%eax),%eax
  800718:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80071b:	b8 10 00 00 00       	mov    $0x10,%eax
  800720:	eb a5                	jmp    8006c7 <vprintfmt+0x3bb>
	else if (lflag)
  800722:	85 c9                	test   %ecx,%ecx
  800724:	75 17                	jne    80073d <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8b 10                	mov    (%eax),%edx
  80072b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800730:	8d 40 04             	lea    0x4(%eax),%eax
  800733:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800736:	b8 10 00 00 00       	mov    $0x10,%eax
  80073b:	eb 8a                	jmp    8006c7 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8b 10                	mov    (%eax),%edx
  800742:	b9 00 00 00 00       	mov    $0x0,%ecx
  800747:	8d 40 04             	lea    0x4(%eax),%eax
  80074a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80074d:	b8 10 00 00 00       	mov    $0x10,%eax
  800752:	e9 70 ff ff ff       	jmp    8006c7 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800757:	83 ec 08             	sub    $0x8,%esp
  80075a:	53                   	push   %ebx
  80075b:	6a 25                	push   $0x25
  80075d:	ff d6                	call   *%esi
			break;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	e9 7a ff ff ff       	jmp    8006e1 <vprintfmt+0x3d5>
			putch('%', putdat);
  800767:	83 ec 08             	sub    $0x8,%esp
  80076a:	53                   	push   %ebx
  80076b:	6a 25                	push   $0x25
  80076d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	89 f8                	mov    %edi,%eax
  800774:	eb 03                	jmp    800779 <vprintfmt+0x46d>
  800776:	83 e8 01             	sub    $0x1,%eax
  800779:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80077d:	75 f7                	jne    800776 <vprintfmt+0x46a>
  80077f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800782:	e9 5a ff ff ff       	jmp    8006e1 <vprintfmt+0x3d5>
}
  800787:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078a:	5b                   	pop    %ebx
  80078b:	5e                   	pop    %esi
  80078c:	5f                   	pop    %edi
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	83 ec 18             	sub    $0x18,%esp
  800795:	8b 45 08             	mov    0x8(%ebp),%eax
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ac:	85 c0                	test   %eax,%eax
  8007ae:	74 26                	je     8007d6 <vsnprintf+0x47>
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	7e 22                	jle    8007d6 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b4:	ff 75 14             	pushl  0x14(%ebp)
  8007b7:	ff 75 10             	pushl  0x10(%ebp)
  8007ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	68 d2 02 80 00       	push   $0x8002d2
  8007c3:	e8 44 fb ff ff       	call   80030c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007cb:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d1:	83 c4 10             	add    $0x10,%esp
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    
		return -E_INVAL;
  8007d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007db:	eb f7                	jmp    8007d4 <vsnprintf+0x45>

008007dd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007e6:	50                   	push   %eax
  8007e7:	ff 75 10             	pushl  0x10(%ebp)
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	ff 75 08             	pushl  0x8(%ebp)
  8007f0:	e8 9a ff ff ff       	call   80078f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
  800802:	eb 03                	jmp    800807 <strlen+0x10>
		n++;
  800804:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800807:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80080b:	75 f7                	jne    800804 <strlen+0xd>
	return n;
}
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800815:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800818:	b8 00 00 00 00       	mov    $0x0,%eax
  80081d:	eb 03                	jmp    800822 <strnlen+0x13>
		n++;
  80081f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800822:	39 d0                	cmp    %edx,%eax
  800824:	74 06                	je     80082c <strnlen+0x1d>
  800826:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80082a:	75 f3                	jne    80081f <strnlen+0x10>
	return n;
}
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	53                   	push   %ebx
  800832:	8b 45 08             	mov    0x8(%ebp),%eax
  800835:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	83 c2 01             	add    $0x1,%edx
  800840:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800844:	88 5a ff             	mov    %bl,-0x1(%edx)
  800847:	84 db                	test   %bl,%bl
  800849:	75 ef                	jne    80083a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80084b:	5b                   	pop    %ebx
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084e:	55                   	push   %ebp
  80084f:	89 e5                	mov    %esp,%ebp
  800851:	53                   	push   %ebx
  800852:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800855:	53                   	push   %ebx
  800856:	e8 9c ff ff ff       	call   8007f7 <strlen>
  80085b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80085e:	ff 75 0c             	pushl  0xc(%ebp)
  800861:	01 d8                	add    %ebx,%eax
  800863:	50                   	push   %eax
  800864:	e8 c5 ff ff ff       	call   80082e <strcpy>
	return dst;
}
  800869:	89 d8                	mov    %ebx,%eax
  80086b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086e:	c9                   	leave  
  80086f:	c3                   	ret    

00800870 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	56                   	push   %esi
  800874:	53                   	push   %ebx
  800875:	8b 75 08             	mov    0x8(%ebp),%esi
  800878:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80087b:	89 f3                	mov    %esi,%ebx
  80087d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800880:	89 f2                	mov    %esi,%edx
  800882:	eb 0f                	jmp    800893 <strncpy+0x23>
		*dst++ = *src;
  800884:	83 c2 01             	add    $0x1,%edx
  800887:	0f b6 01             	movzbl (%ecx),%eax
  80088a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80088d:	80 39 01             	cmpb   $0x1,(%ecx)
  800890:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800893:	39 da                	cmp    %ebx,%edx
  800895:	75 ed                	jne    800884 <strncpy+0x14>
	}
	return ret;
}
  800897:	89 f0                	mov    %esi,%eax
  800899:	5b                   	pop    %ebx
  80089a:	5e                   	pop    %esi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8008ab:	89 f0                	mov    %esi,%eax
  8008ad:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	75 0b                	jne    8008c0 <strlcpy+0x23>
  8008b5:	eb 17                	jmp    8008ce <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008b7:	83 c2 01             	add    $0x1,%edx
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  8008c0:	39 d8                	cmp    %ebx,%eax
  8008c2:	74 07                	je     8008cb <strlcpy+0x2e>
  8008c4:	0f b6 0a             	movzbl (%edx),%ecx
  8008c7:	84 c9                	test   %cl,%cl
  8008c9:	75 ec                	jne    8008b7 <strlcpy+0x1a>
		*dst = '\0';
  8008cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ce:	29 f0                	sub    %esi,%eax
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008dd:	eb 06                	jmp    8008e5 <strcmp+0x11>
		p++, q++;
  8008df:	83 c1 01             	add    $0x1,%ecx
  8008e2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008e5:	0f b6 01             	movzbl (%ecx),%eax
  8008e8:	84 c0                	test   %al,%al
  8008ea:	74 04                	je     8008f0 <strcmp+0x1c>
  8008ec:	3a 02                	cmp    (%edx),%al
  8008ee:	74 ef                	je     8008df <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008f0:	0f b6 c0             	movzbl %al,%eax
  8008f3:	0f b6 12             	movzbl (%edx),%edx
  8008f6:	29 d0                	sub    %edx,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800901:	8b 55 0c             	mov    0xc(%ebp),%edx
  800904:	89 c3                	mov    %eax,%ebx
  800906:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800909:	eb 06                	jmp    800911 <strncmp+0x17>
		n--, p++, q++;
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800911:	39 d8                	cmp    %ebx,%eax
  800913:	74 16                	je     80092b <strncmp+0x31>
  800915:	0f b6 08             	movzbl (%eax),%ecx
  800918:	84 c9                	test   %cl,%cl
  80091a:	74 04                	je     800920 <strncmp+0x26>
  80091c:	3a 0a                	cmp    (%edx),%cl
  80091e:	74 eb                	je     80090b <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800920:	0f b6 00             	movzbl (%eax),%eax
  800923:	0f b6 12             	movzbl (%edx),%edx
  800926:	29 d0                	sub    %edx,%eax
}
  800928:	5b                   	pop    %ebx
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    
		return 0;
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	eb f6                	jmp    800928 <strncmp+0x2e>

00800932 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80093c:	0f b6 10             	movzbl (%eax),%edx
  80093f:	84 d2                	test   %dl,%dl
  800941:	74 09                	je     80094c <strchr+0x1a>
		if (*s == c)
  800943:	38 ca                	cmp    %cl,%dl
  800945:	74 0a                	je     800951 <strchr+0x1f>
	for (; *s; s++)
  800947:	83 c0 01             	add    $0x1,%eax
  80094a:	eb f0                	jmp    80093c <strchr+0xa>
			return (char *) s;
	return 0;
  80094c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800951:	5d                   	pop    %ebp
  800952:	c3                   	ret    

00800953 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800953:	55                   	push   %ebp
  800954:	89 e5                	mov    %esp,%ebp
  800956:	8b 45 08             	mov    0x8(%ebp),%eax
  800959:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095d:	eb 03                	jmp    800962 <strfind+0xf>
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800965:	38 ca                	cmp    %cl,%dl
  800967:	74 04                	je     80096d <strfind+0x1a>
  800969:	84 d2                	test   %dl,%dl
  80096b:	75 f2                	jne    80095f <strfind+0xc>
			break;
	return (char *) s;
}
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	57                   	push   %edi
  800973:	56                   	push   %esi
  800974:	53                   	push   %ebx
  800975:	8b 7d 08             	mov    0x8(%ebp),%edi
  800978:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80097b:	85 c9                	test   %ecx,%ecx
  80097d:	74 13                	je     800992 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80097f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800985:	75 05                	jne    80098c <memset+0x1d>
  800987:	f6 c1 03             	test   $0x3,%cl
  80098a:	74 0d                	je     800999 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80098c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098f:	fc                   	cld    
  800990:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800992:	89 f8                	mov    %edi,%eax
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5f                   	pop    %edi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    
		c &= 0xFF;
  800999:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099d:	89 d3                	mov    %edx,%ebx
  80099f:	c1 e3 08             	shl    $0x8,%ebx
  8009a2:	89 d0                	mov    %edx,%eax
  8009a4:	c1 e0 18             	shl    $0x18,%eax
  8009a7:	89 d6                	mov    %edx,%esi
  8009a9:	c1 e6 10             	shl    $0x10,%esi
  8009ac:	09 f0                	or     %esi,%eax
  8009ae:	09 c2                	or     %eax,%edx
  8009b0:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009b5:	89 d0                	mov    %edx,%eax
  8009b7:	fc                   	cld    
  8009b8:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ba:	eb d6                	jmp    800992 <memset+0x23>

008009bc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	57                   	push   %edi
  8009c0:	56                   	push   %esi
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009c7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009ca:	39 c6                	cmp    %eax,%esi
  8009cc:	73 35                	jae    800a03 <memmove+0x47>
  8009ce:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009d1:	39 c2                	cmp    %eax,%edx
  8009d3:	76 2e                	jbe    800a03 <memmove+0x47>
		s += n;
		d += n;
  8009d5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009d8:	89 d6                	mov    %edx,%esi
  8009da:	09 fe                	or     %edi,%esi
  8009dc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009e2:	74 0c                	je     8009f0 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e4:	83 ef 01             	sub    $0x1,%edi
  8009e7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ea:	fd                   	std    
  8009eb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ed:	fc                   	cld    
  8009ee:	eb 21                	jmp    800a11 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f0:	f6 c1 03             	test   $0x3,%cl
  8009f3:	75 ef                	jne    8009e4 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009f5:	83 ef 04             	sub    $0x4,%edi
  8009f8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009fe:	fd                   	std    
  8009ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a01:	eb ea                	jmp    8009ed <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a03:	89 f2                	mov    %esi,%edx
  800a05:	09 c2                	or     %eax,%edx
  800a07:	f6 c2 03             	test   $0x3,%dl
  800a0a:	74 09                	je     800a15 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a0c:	89 c7                	mov    %eax,%edi
  800a0e:	fc                   	cld    
  800a0f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a11:	5e                   	pop    %esi
  800a12:	5f                   	pop    %edi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a15:	f6 c1 03             	test   $0x3,%cl
  800a18:	75 f2                	jne    800a0c <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a1a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a1d:	89 c7                	mov    %eax,%edi
  800a1f:	fc                   	cld    
  800a20:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a22:	eb ed                	jmp    800a11 <memmove+0x55>

00800a24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a27:	ff 75 10             	pushl  0x10(%ebp)
  800a2a:	ff 75 0c             	pushl  0xc(%ebp)
  800a2d:	ff 75 08             	pushl  0x8(%ebp)
  800a30:	e8 87 ff ff ff       	call   8009bc <memmove>
}
  800a35:	c9                   	leave  
  800a36:	c3                   	ret    

00800a37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a42:	89 c6                	mov    %eax,%esi
  800a44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a47:	39 f0                	cmp    %esi,%eax
  800a49:	74 1c                	je     800a67 <memcmp+0x30>
		if (*s1 != *s2)
  800a4b:	0f b6 08             	movzbl (%eax),%ecx
  800a4e:	0f b6 1a             	movzbl (%edx),%ebx
  800a51:	38 d9                	cmp    %bl,%cl
  800a53:	75 08                	jne    800a5d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	83 c2 01             	add    $0x1,%edx
  800a5b:	eb ea                	jmp    800a47 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800a5d:	0f b6 c1             	movzbl %cl,%eax
  800a60:	0f b6 db             	movzbl %bl,%ebx
  800a63:	29 d8                	sub    %ebx,%eax
  800a65:	eb 05                	jmp    800a6c <memcmp+0x35>
	}

	return 0;
  800a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a79:	89 c2                	mov    %eax,%edx
  800a7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7e:	39 d0                	cmp    %edx,%eax
  800a80:	73 09                	jae    800a8b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a82:	38 08                	cmp    %cl,(%eax)
  800a84:	74 05                	je     800a8b <memfind+0x1b>
	for (; s < ends; s++)
  800a86:	83 c0 01             	add    $0x1,%eax
  800a89:	eb f3                	jmp    800a7e <memfind+0xe>
			break;
	return (void *) s;
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	57                   	push   %edi
  800a91:	56                   	push   %esi
  800a92:	53                   	push   %ebx
  800a93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a99:	eb 03                	jmp    800a9e <strtol+0x11>
		s++;
  800a9b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a9e:	0f b6 01             	movzbl (%ecx),%eax
  800aa1:	3c 20                	cmp    $0x20,%al
  800aa3:	74 f6                	je     800a9b <strtol+0xe>
  800aa5:	3c 09                	cmp    $0x9,%al
  800aa7:	74 f2                	je     800a9b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800aa9:	3c 2b                	cmp    $0x2b,%al
  800aab:	74 2e                	je     800adb <strtol+0x4e>
	int neg = 0;
  800aad:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab2:	3c 2d                	cmp    $0x2d,%al
  800ab4:	74 2f                	je     800ae5 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abc:	75 05                	jne    800ac3 <strtol+0x36>
  800abe:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac1:	74 2c                	je     800aef <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ac3:	85 db                	test   %ebx,%ebx
  800ac5:	75 0a                	jne    800ad1 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac7:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800acc:	80 39 30             	cmpb   $0x30,(%ecx)
  800acf:	74 28                	je     800af9 <strtol+0x6c>
		base = 10;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad6:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad9:	eb 50                	jmp    800b2b <strtol+0x9e>
		s++;
  800adb:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ade:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae3:	eb d1                	jmp    800ab6 <strtol+0x29>
		s++, neg = 1;
  800ae5:	83 c1 01             	add    $0x1,%ecx
  800ae8:	bf 01 00 00 00       	mov    $0x1,%edi
  800aed:	eb c7                	jmp    800ab6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aef:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af3:	74 0e                	je     800b03 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af5:	85 db                	test   %ebx,%ebx
  800af7:	75 d8                	jne    800ad1 <strtol+0x44>
		s++, base = 8;
  800af9:	83 c1 01             	add    $0x1,%ecx
  800afc:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b01:	eb ce                	jmp    800ad1 <strtol+0x44>
		s += 2, base = 16;
  800b03:	83 c1 02             	add    $0x2,%ecx
  800b06:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b0b:	eb c4                	jmp    800ad1 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800b0d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b10:	89 f3                	mov    %esi,%ebx
  800b12:	80 fb 19             	cmp    $0x19,%bl
  800b15:	77 29                	ja     800b40 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b17:	0f be d2             	movsbl %dl,%edx
  800b1a:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b1d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b20:	7d 30                	jge    800b52 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b22:	83 c1 01             	add    $0x1,%ecx
  800b25:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b29:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b2b:	0f b6 11             	movzbl (%ecx),%edx
  800b2e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b31:	89 f3                	mov    %esi,%ebx
  800b33:	80 fb 09             	cmp    $0x9,%bl
  800b36:	77 d5                	ja     800b0d <strtol+0x80>
			dig = *s - '0';
  800b38:	0f be d2             	movsbl %dl,%edx
  800b3b:	83 ea 30             	sub    $0x30,%edx
  800b3e:	eb dd                	jmp    800b1d <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800b40:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b43:	89 f3                	mov    %esi,%ebx
  800b45:	80 fb 19             	cmp    $0x19,%bl
  800b48:	77 08                	ja     800b52 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b4a:	0f be d2             	movsbl %dl,%edx
  800b4d:	83 ea 37             	sub    $0x37,%edx
  800b50:	eb cb                	jmp    800b1d <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b56:	74 05                	je     800b5d <strtol+0xd0>
		*endptr = (char *) s;
  800b58:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	f7 da                	neg    %edx
  800b61:	85 ff                	test   %edi,%edi
  800b63:	0f 45 c2             	cmovne %edx,%eax
}
  800b66:	5b                   	pop    %ebx
  800b67:	5e                   	pop    %esi
  800b68:	5f                   	pop    %edi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b71:	b8 00 00 00 00       	mov    $0x0,%eax
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7c:	89 c3                	mov    %eax,%ebx
  800b7e:	89 c7                	mov    %eax,%edi
  800b80:	89 c6                	mov    %eax,%esi
  800b82:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 01 00 00 00       	mov    $0x1,%eax
  800b99:	89 d1                	mov    %edx,%ecx
  800b9b:	89 d3                	mov    %edx,%ebx
  800b9d:	89 d7                	mov    %edx,%edi
  800b9f:	89 d6                	mov    %edx,%esi
  800ba1:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ba3:	5b                   	pop    %ebx
  800ba4:	5e                   	pop    %esi
  800ba5:	5f                   	pop    %edi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
  800bae:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbe:	89 cb                	mov    %ecx,%ebx
  800bc0:	89 cf                	mov    %ecx,%edi
  800bc2:	89 ce                	mov    %ecx,%esi
  800bc4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc6:	85 c0                	test   %eax,%eax
  800bc8:	7f 08                	jg     800bd2 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5f                   	pop    %edi
  800bd0:	5d                   	pop    %ebp
  800bd1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd2:	83 ec 0c             	sub    $0xc,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 03                	push   $0x3
  800bd8:	68 64 13 80 00       	push   $0x801364
  800bdd:	6a 23                	push   $0x23
  800bdf:	68 81 13 80 00       	push   $0x801381
  800be4:	e8 4b f5 ff ff       	call   800134 <_panic>

00800be9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bef:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf4:	b8 02 00 00 00       	mov    $0x2,%eax
  800bf9:	89 d1                	mov    %edx,%ecx
  800bfb:	89 d3                	mov    %edx,%ebx
  800bfd:	89 d7                	mov    %edx,%edi
  800bff:	89 d6                	mov    %edx,%esi
  800c01:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <sys_yield>:

void
sys_yield(void)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c13:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c18:	89 d1                	mov    %edx,%ecx
  800c1a:	89 d3                	mov    %edx,%ebx
  800c1c:	89 d7                	mov    %edx,%edi
  800c1e:	89 d6                	mov    %edx,%esi
  800c20:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c22:	5b                   	pop    %ebx
  800c23:	5e                   	pop    %esi
  800c24:	5f                   	pop    %edi
  800c25:	5d                   	pop    %ebp
  800c26:	c3                   	ret    

00800c27 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	57                   	push   %edi
  800c2b:	56                   	push   %esi
  800c2c:	53                   	push   %ebx
  800c2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c30:	be 00 00 00 00       	mov    $0x0,%esi
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c3b:	b8 04 00 00 00       	mov    $0x4,%eax
  800c40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c43:	89 f7                	mov    %esi,%edi
  800c45:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c47:	85 c0                	test   %eax,%eax
  800c49:	7f 08                	jg     800c53 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	83 ec 0c             	sub    $0xc,%esp
  800c56:	50                   	push   %eax
  800c57:	6a 04                	push   $0x4
  800c59:	68 64 13 80 00       	push   $0x801364
  800c5e:	6a 23                	push   $0x23
  800c60:	68 81 13 80 00       	push   $0x801381
  800c65:	e8 ca f4 ff ff       	call   800134 <_panic>

00800c6a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c73:	8b 55 08             	mov    0x8(%ebp),%edx
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	b8 05 00 00 00       	mov    $0x5,%eax
  800c7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c84:	8b 75 18             	mov    0x18(%ebp),%esi
  800c87:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c89:	85 c0                	test   %eax,%eax
  800c8b:	7f 08                	jg     800c95 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5f                   	pop    %edi
  800c93:	5d                   	pop    %ebp
  800c94:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c95:	83 ec 0c             	sub    $0xc,%esp
  800c98:	50                   	push   %eax
  800c99:	6a 05                	push   $0x5
  800c9b:	68 64 13 80 00       	push   $0x801364
  800ca0:	6a 23                	push   $0x23
  800ca2:	68 81 13 80 00       	push   $0x801381
  800ca7:	e8 88 f4 ff ff       	call   800134 <_panic>

00800cac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cac:	55                   	push   %ebp
  800cad:	89 e5                	mov    %esp,%ebp
  800caf:	57                   	push   %edi
  800cb0:	56                   	push   %esi
  800cb1:	53                   	push   %ebx
  800cb2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc0:	b8 06 00 00 00       	mov    $0x6,%eax
  800cc5:	89 df                	mov    %ebx,%edi
  800cc7:	89 de                	mov    %ebx,%esi
  800cc9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7f 08                	jg     800cd7 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ccf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd2:	5b                   	pop    %ebx
  800cd3:	5e                   	pop    %esi
  800cd4:	5f                   	pop    %edi
  800cd5:	5d                   	pop    %ebp
  800cd6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd7:	83 ec 0c             	sub    $0xc,%esp
  800cda:	50                   	push   %eax
  800cdb:	6a 06                	push   $0x6
  800cdd:	68 64 13 80 00       	push   $0x801364
  800ce2:	6a 23                	push   $0x23
  800ce4:	68 81 13 80 00       	push   $0x801381
  800ce9:	e8 46 f4 ff ff       	call   800134 <_panic>

00800cee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d02:	b8 08 00 00 00       	mov    $0x8,%eax
  800d07:	89 df                	mov    %ebx,%edi
  800d09:	89 de                	mov    %ebx,%esi
  800d0b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d0d:	85 c0                	test   %eax,%eax
  800d0f:	7f 08                	jg     800d19 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d14:	5b                   	pop    %ebx
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d19:	83 ec 0c             	sub    $0xc,%esp
  800d1c:	50                   	push   %eax
  800d1d:	6a 08                	push   $0x8
  800d1f:	68 64 13 80 00       	push   $0x801364
  800d24:	6a 23                	push   $0x23
  800d26:	68 81 13 80 00       	push   $0x801381
  800d2b:	e8 04 f4 ff ff       	call   800134 <_panic>

00800d30 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	57                   	push   %edi
  800d34:	56                   	push   %esi
  800d35:	53                   	push   %ebx
  800d36:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	b8 09 00 00 00       	mov    $0x9,%eax
  800d49:	89 df                	mov    %ebx,%edi
  800d4b:	89 de                	mov    %ebx,%esi
  800d4d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	7f 08                	jg     800d5b <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d56:	5b                   	pop    %ebx
  800d57:	5e                   	pop    %esi
  800d58:	5f                   	pop    %edi
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5b:	83 ec 0c             	sub    $0xc,%esp
  800d5e:	50                   	push   %eax
  800d5f:	6a 09                	push   $0x9
  800d61:	68 64 13 80 00       	push   $0x801364
  800d66:	6a 23                	push   $0x23
  800d68:	68 81 13 80 00       	push   $0x801381
  800d6d:	e8 c2 f3 ff ff       	call   800134 <_panic>

00800d72 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d83:	be 00 00 00 00       	mov    $0x0,%esi
  800d88:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8e:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d90:	5b                   	pop    %ebx
  800d91:	5e                   	pop    %esi
  800d92:	5f                   	pop    %edi
  800d93:	5d                   	pop    %ebp
  800d94:	c3                   	ret    

00800d95 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	57                   	push   %edi
  800d99:	56                   	push   %esi
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da3:	8b 55 08             	mov    0x8(%ebp),%edx
  800da6:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dab:	89 cb                	mov    %ecx,%ebx
  800dad:	89 cf                	mov    %ecx,%edi
  800daf:	89 ce                	mov    %ecx,%esi
  800db1:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db3:	85 c0                	test   %eax,%eax
  800db5:	7f 08                	jg     800dbf <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbf:	83 ec 0c             	sub    $0xc,%esp
  800dc2:	50                   	push   %eax
  800dc3:	6a 0c                	push   $0xc
  800dc5:	68 64 13 80 00       	push   $0x801364
  800dca:	6a 23                	push   $0x23
  800dcc:	68 81 13 80 00       	push   $0x801381
  800dd1:	e8 5e f3 ff ff       	call   800134 <_panic>
  800dd6:	66 90                	xchg   %ax,%ax
  800dd8:	66 90                	xchg   %ax,%ax
  800dda:	66 90                	xchg   %ax,%ax
  800ddc:	66 90                	xchg   %ax,%ax
  800dde:	66 90                	xchg   %ax,%ax

00800de0 <__udivdi3>:
  800de0:	55                   	push   %ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
  800de4:	83 ec 1c             	sub    $0x1c,%esp
  800de7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800deb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800def:	8b 74 24 34          	mov    0x34(%esp),%esi
  800df3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800df7:	85 d2                	test   %edx,%edx
  800df9:	75 35                	jne    800e30 <__udivdi3+0x50>
  800dfb:	39 f3                	cmp    %esi,%ebx
  800dfd:	0f 87 bd 00 00 00    	ja     800ec0 <__udivdi3+0xe0>
  800e03:	85 db                	test   %ebx,%ebx
  800e05:	89 d9                	mov    %ebx,%ecx
  800e07:	75 0b                	jne    800e14 <__udivdi3+0x34>
  800e09:	b8 01 00 00 00       	mov    $0x1,%eax
  800e0e:	31 d2                	xor    %edx,%edx
  800e10:	f7 f3                	div    %ebx
  800e12:	89 c1                	mov    %eax,%ecx
  800e14:	31 d2                	xor    %edx,%edx
  800e16:	89 f0                	mov    %esi,%eax
  800e18:	f7 f1                	div    %ecx
  800e1a:	89 c6                	mov    %eax,%esi
  800e1c:	89 e8                	mov    %ebp,%eax
  800e1e:	89 f7                	mov    %esi,%edi
  800e20:	f7 f1                	div    %ecx
  800e22:	89 fa                	mov    %edi,%edx
  800e24:	83 c4 1c             	add    $0x1c,%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5f                   	pop    %edi
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    
  800e2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e30:	39 f2                	cmp    %esi,%edx
  800e32:	77 7c                	ja     800eb0 <__udivdi3+0xd0>
  800e34:	0f bd fa             	bsr    %edx,%edi
  800e37:	83 f7 1f             	xor    $0x1f,%edi
  800e3a:	0f 84 98 00 00 00    	je     800ed8 <__udivdi3+0xf8>
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	b8 20 00 00 00       	mov    $0x20,%eax
  800e47:	29 f8                	sub    %edi,%eax
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 c1                	mov    %eax,%ecx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	d3 e6                	shl    %cl,%esi
  800e71:	89 eb                	mov    %ebp,%ebx
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 de                	or     %ebx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	f7 74 24 08          	divl   0x8(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	f7 64 24 0c          	mull   0xc(%esp)
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 0c                	jb     800e97 <__udivdi3+0xb7>
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	39 c5                	cmp    %eax,%ebp
  800e91:	73 5d                	jae    800ef0 <__udivdi3+0x110>
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	75 59                	jne    800ef0 <__udivdi3+0x110>
  800e97:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e9a:	31 ff                	xor    %edi,%edi
  800e9c:	89 fa                	mov    %edi,%edx
  800e9e:	83 c4 1c             	add    $0x1c,%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5f                   	pop    %edi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    
  800ea6:	8d 76 00             	lea    0x0(%esi),%esi
  800ea9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800eb0:	31 ff                	xor    %edi,%edi
  800eb2:	31 c0                	xor    %eax,%eax
  800eb4:	89 fa                	mov    %edi,%edx
  800eb6:	83 c4 1c             	add    $0x1c,%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    
  800ebe:	66 90                	xchg   %ax,%ax
  800ec0:	31 ff                	xor    %edi,%edi
  800ec2:	89 e8                	mov    %ebp,%eax
  800ec4:	89 f2                	mov    %esi,%edx
  800ec6:	f7 f3                	div    %ebx
  800ec8:	89 fa                	mov    %edi,%edx
  800eca:	83 c4 1c             	add    $0x1c,%esp
  800ecd:	5b                   	pop    %ebx
  800ece:	5e                   	pop    %esi
  800ecf:	5f                   	pop    %edi
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    
  800ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ed8:	39 f2                	cmp    %esi,%edx
  800eda:	72 06                	jb     800ee2 <__udivdi3+0x102>
  800edc:	31 c0                	xor    %eax,%eax
  800ede:	39 eb                	cmp    %ebp,%ebx
  800ee0:	77 d2                	ja     800eb4 <__udivdi3+0xd4>
  800ee2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ee7:	eb cb                	jmp    800eb4 <__udivdi3+0xd4>
  800ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ef0:	89 d8                	mov    %ebx,%eax
  800ef2:	31 ff                	xor    %edi,%edi
  800ef4:	eb be                	jmp    800eb4 <__udivdi3+0xd4>
  800ef6:	66 90                	xchg   %ax,%ax
  800ef8:	66 90                	xchg   %ax,%ax
  800efa:	66 90                	xchg   %ax,%ax
  800efc:	66 90                	xchg   %ax,%ax
  800efe:	66 90                	xchg   %ax,%ax

00800f00 <__umoddi3>:
  800f00:	55                   	push   %ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 1c             	sub    $0x1c,%esp
  800f07:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f0b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f0f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f17:	85 ed                	test   %ebp,%ebp
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	89 da                	mov    %ebx,%edx
  800f1d:	75 19                	jne    800f38 <__umoddi3+0x38>
  800f1f:	39 df                	cmp    %ebx,%edi
  800f21:	0f 86 b1 00 00 00    	jbe    800fd8 <__umoddi3+0xd8>
  800f27:	f7 f7                	div    %edi
  800f29:	89 d0                	mov    %edx,%eax
  800f2b:	31 d2                	xor    %edx,%edx
  800f2d:	83 c4 1c             	add    $0x1c,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5e                   	pop    %esi
  800f32:	5f                   	pop    %edi
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    
  800f35:	8d 76 00             	lea    0x0(%esi),%esi
  800f38:	39 dd                	cmp    %ebx,%ebp
  800f3a:	77 f1                	ja     800f2d <__umoddi3+0x2d>
  800f3c:	0f bd cd             	bsr    %ebp,%ecx
  800f3f:	83 f1 1f             	xor    $0x1f,%ecx
  800f42:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f46:	0f 84 b4 00 00 00    	je     801000 <__umoddi3+0x100>
  800f4c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f51:	89 c2                	mov    %eax,%edx
  800f53:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f57:	29 c2                	sub    %eax,%edx
  800f59:	89 c1                	mov    %eax,%ecx
  800f5b:	89 f8                	mov    %edi,%eax
  800f5d:	d3 e5                	shl    %cl,%ebp
  800f5f:	89 d1                	mov    %edx,%ecx
  800f61:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f65:	d3 e8                	shr    %cl,%eax
  800f67:	09 c5                	or     %eax,%ebp
  800f69:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f6d:	89 c1                	mov    %eax,%ecx
  800f6f:	d3 e7                	shl    %cl,%edi
  800f71:	89 d1                	mov    %edx,%ecx
  800f73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f77:	89 df                	mov    %ebx,%edi
  800f79:	d3 ef                	shr    %cl,%edi
  800f7b:	89 c1                	mov    %eax,%ecx
  800f7d:	89 f0                	mov    %esi,%eax
  800f7f:	d3 e3                	shl    %cl,%ebx
  800f81:	89 d1                	mov    %edx,%ecx
  800f83:	89 fa                	mov    %edi,%edx
  800f85:	d3 e8                	shr    %cl,%eax
  800f87:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f8c:	09 d8                	or     %ebx,%eax
  800f8e:	f7 f5                	div    %ebp
  800f90:	d3 e6                	shl    %cl,%esi
  800f92:	89 d1                	mov    %edx,%ecx
  800f94:	f7 64 24 08          	mull   0x8(%esp)
  800f98:	39 d1                	cmp    %edx,%ecx
  800f9a:	89 c3                	mov    %eax,%ebx
  800f9c:	89 d7                	mov    %edx,%edi
  800f9e:	72 06                	jb     800fa6 <__umoddi3+0xa6>
  800fa0:	75 0e                	jne    800fb0 <__umoddi3+0xb0>
  800fa2:	39 c6                	cmp    %eax,%esi
  800fa4:	73 0a                	jae    800fb0 <__umoddi3+0xb0>
  800fa6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800faa:	19 ea                	sbb    %ebp,%edx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	89 c3                	mov    %eax,%ebx
  800fb0:	89 ca                	mov    %ecx,%edx
  800fb2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fb7:	29 de                	sub    %ebx,%esi
  800fb9:	19 fa                	sbb    %edi,%edx
  800fbb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fbf:	89 d0                	mov    %edx,%eax
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 d9                	mov    %ebx,%ecx
  800fc5:	d3 ee                	shr    %cl,%esi
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	09 f0                	or     %esi,%eax
  800fcb:	83 c4 1c             	add    $0x1c,%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    
  800fd3:	90                   	nop
  800fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fd8:	85 ff                	test   %edi,%edi
  800fda:	89 f9                	mov    %edi,%ecx
  800fdc:	75 0b                	jne    800fe9 <__umoddi3+0xe9>
  800fde:	b8 01 00 00 00       	mov    $0x1,%eax
  800fe3:	31 d2                	xor    %edx,%edx
  800fe5:	f7 f7                	div    %edi
  800fe7:	89 c1                	mov    %eax,%ecx
  800fe9:	89 d8                	mov    %ebx,%eax
  800feb:	31 d2                	xor    %edx,%edx
  800fed:	f7 f1                	div    %ecx
  800fef:	89 f0                	mov    %esi,%eax
  800ff1:	f7 f1                	div    %ecx
  800ff3:	e9 31 ff ff ff       	jmp    800f29 <__umoddi3+0x29>
  800ff8:	90                   	nop
  800ff9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801000:	39 dd                	cmp    %ebx,%ebp
  801002:	72 08                	jb     80100c <__umoddi3+0x10c>
  801004:	39 f7                	cmp    %esi,%edi
  801006:	0f 87 21 ff ff ff    	ja     800f2d <__umoddi3+0x2d>
  80100c:	89 da                	mov    %ebx,%edx
  80100e:	89 f0                	mov    %esi,%eax
  801010:	29 f8                	sub    %edi,%eax
  801012:	19 ea                	sbb    %ebp,%edx
  801014:	e9 14 ff ff ff       	jmp    800f2d <__umoddi3+0x2d>
