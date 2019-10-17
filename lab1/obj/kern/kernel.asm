
obj/kern/kernel：     文件格式 elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 68 00 00 00       	call   f01000a6 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	e8 72 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010004a:	81 c3 be 12 01 00    	add    $0x112be,%ebx
f0100050:	8b 75 08             	mov    0x8(%ebp),%esi
	cprintf("entering test_backtrace %d\n", x);
f0100053:	83 ec 08             	sub    $0x8,%esp
f0100056:	56                   	push   %esi
f0100057:	8d 83 78 08 ff ff    	lea    -0xf788(%ebx),%eax
f010005d:	50                   	push   %eax
f010005e:	e8 c4 0a 00 00       	call   f0100b27 <cprintf>
	if (x > 0)
f0100063:	83 c4 10             	add    $0x10,%esp
f0100066:	85 f6                	test   %esi,%esi
f0100068:	7f 2b                	jg     f0100095 <test_backtrace+0x55>
		test_backtrace(x-1);
	else
		mon_backtrace(0, 0, 0);
f010006a:	83 ec 04             	sub    $0x4,%esp
f010006d:	6a 00                	push   $0x0
f010006f:	6a 00                	push   $0x0
f0100071:	6a 00                	push   $0x0
f0100073:	e8 0b 08 00 00       	call   f0100883 <mon_backtrace>
f0100078:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007b:	83 ec 08             	sub    $0x8,%esp
f010007e:	56                   	push   %esi
f010007f:	8d 83 94 08 ff ff    	lea    -0xf76c(%ebx),%eax
f0100085:	50                   	push   %eax
f0100086:	e8 9c 0a 00 00       	call   f0100b27 <cprintf>
}
f010008b:	83 c4 10             	add    $0x10,%esp
f010008e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100091:	5b                   	pop    %ebx
f0100092:	5e                   	pop    %esi
f0100093:	5d                   	pop    %ebp
f0100094:	c3                   	ret    
		test_backtrace(x-1);
f0100095:	83 ec 0c             	sub    $0xc,%esp
f0100098:	8d 46 ff             	lea    -0x1(%esi),%eax
f010009b:	50                   	push   %eax
f010009c:	e8 9f ff ff ff       	call   f0100040 <test_backtrace>
f01000a1:	83 c4 10             	add    $0x10,%esp
f01000a4:	eb d5                	jmp    f010007b <test_backtrace+0x3b>

f01000a6 <i386_init>:

void
i386_init(void)
{
f01000a6:	55                   	push   %ebp
f01000a7:	89 e5                	mov    %esp,%ebp
f01000a9:	53                   	push   %ebx
f01000aa:	83 ec 08             	sub    $0x8,%esp
f01000ad:	e8 0a 01 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f01000b2:	81 c3 56 12 01 00    	add    $0x11256,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000b8:	c7 c2 60 30 11 f0    	mov    $0xf0113060,%edx
f01000be:	c7 c0 a0 36 11 f0    	mov    $0xf01136a0,%eax
f01000c4:	29 d0                	sub    %edx,%eax
f01000c6:	50                   	push   %eax
f01000c7:	6a 00                	push   $0x0
f01000c9:	52                   	push   %edx
f01000ca:	e8 6d 16 00 00       	call   f010173c <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000cf:	e8 3d 05 00 00       	call   f0100611 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000d4:	83 c4 08             	add    $0x8,%esp
f01000d7:	68 ac 1a 00 00       	push   $0x1aac
f01000dc:	8d 83 af 08 ff ff    	lea    -0xf751(%ebx),%eax
f01000e2:	50                   	push   %eax
f01000e3:	e8 3f 0a 00 00       	call   f0100b27 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000e8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000ef:	e8 4c ff ff ff       	call   f0100040 <test_backtrace>
f01000f4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000f7:	83 ec 0c             	sub    $0xc,%esp
f01000fa:	6a 00                	push   $0x0
f01000fc:	e8 59 08 00 00       	call   f010095a <monitor>
f0100101:	83 c4 10             	add    $0x10,%esp
f0100104:	eb f1                	jmp    f01000f7 <i386_init+0x51>

f0100106 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100106:	55                   	push   %ebp
f0100107:	89 e5                	mov    %esp,%ebp
f0100109:	57                   	push   %edi
f010010a:	56                   	push   %esi
f010010b:	53                   	push   %ebx
f010010c:	83 ec 0c             	sub    $0xc,%esp
f010010f:	e8 a8 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100114:	81 c3 f4 11 01 00    	add    $0x111f4,%ebx
f010011a:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f010011d:	c7 c0 a4 36 11 f0    	mov    $0xf01136a4,%eax
f0100123:	83 38 00             	cmpl   $0x0,(%eax)
f0100126:	74 0f                	je     f0100137 <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100128:	83 ec 0c             	sub    $0xc,%esp
f010012b:	6a 00                	push   $0x0
f010012d:	e8 28 08 00 00       	call   f010095a <monitor>
f0100132:	83 c4 10             	add    $0x10,%esp
f0100135:	eb f1                	jmp    f0100128 <_panic+0x22>
	panicstr = fmt;
f0100137:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    
	va_start(ap, fmt);
f010013b:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	8d 83 ca 08 ff ff    	lea    -0xf736(%ebx),%eax
f010014d:	50                   	push   %eax
f010014e:	e8 d4 09 00 00       	call   f0100b27 <cprintf>
	vcprintf(fmt, ap);
f0100153:	83 c4 08             	add    $0x8,%esp
f0100156:	56                   	push   %esi
f0100157:	57                   	push   %edi
f0100158:	e8 93 09 00 00       	call   f0100af0 <vcprintf>
	cprintf("\n");
f010015d:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f0100163:	89 04 24             	mov    %eax,(%esp)
f0100166:	e8 bc 09 00 00       	call   f0100b27 <cprintf>
f010016b:	83 c4 10             	add    $0x10,%esp
f010016e:	eb b8                	jmp    f0100128 <_panic+0x22>

f0100170 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100170:	55                   	push   %ebp
f0100171:	89 e5                	mov    %esp,%ebp
f0100173:	56                   	push   %esi
f0100174:	53                   	push   %ebx
f0100175:	e8 42 00 00 00       	call   f01001bc <__x86.get_pc_thunk.bx>
f010017a:	81 c3 8e 11 01 00    	add    $0x1118e,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	83 ec 04             	sub    $0x4,%esp
f0100186:	ff 75 0c             	pushl  0xc(%ebp)
f0100189:	ff 75 08             	pushl  0x8(%ebp)
f010018c:	8d 83 e2 08 ff ff    	lea    -0xf71e(%ebx),%eax
f0100192:	50                   	push   %eax
f0100193:	e8 8f 09 00 00       	call   f0100b27 <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	56                   	push   %esi
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 4c 09 00 00       	call   f0100af0 <vcprintf>
	cprintf("\n");
f01001a4:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f01001aa:	89 04 24             	mov    %eax,(%esp)
f01001ad:	e8 75 09 00 00       	call   f0100b27 <cprintf>
	va_end(ap);
}
f01001b2:	83 c4 10             	add    $0x10,%esp
f01001b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01001b8:	5b                   	pop    %ebx
f01001b9:	5e                   	pop    %esi
f01001ba:	5d                   	pop    %ebp
f01001bb:	c3                   	ret    

f01001bc <__x86.get_pc_thunk.bx>:
f01001bc:	8b 1c 24             	mov    (%esp),%ebx
f01001bf:	c3                   	ret    

f01001c0 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001c0:	55                   	push   %ebp
f01001c1:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c8:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c9:	a8 01                	test   $0x1,%al
f01001cb:	74 0b                	je     f01001d8 <serial_proc_data+0x18>
f01001cd:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d2:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001d3:	0f b6 c0             	movzbl %al,%eax
}
f01001d6:	5d                   	pop    %ebp
f01001d7:	c3                   	ret    
		return -1;
f01001d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01001dd:	eb f7                	jmp    f01001d6 <serial_proc_data+0x16>

f01001df <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001df:	55                   	push   %ebp
f01001e0:	89 e5                	mov    %esp,%ebp
f01001e2:	56                   	push   %esi
f01001e3:	53                   	push   %ebx
f01001e4:	e8 d3 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01001e9:	81 c3 1f 11 01 00    	add    $0x1111f,%ebx
f01001ef:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f01001f1:	ff d6                	call   *%esi
f01001f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001f6:	74 2e                	je     f0100226 <cons_intr+0x47>
		if (c == 0)
f01001f8:	85 c0                	test   %eax,%eax
f01001fa:	74 f5                	je     f01001f1 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f01001fc:	8b 8b 7c 1f 00 00    	mov    0x1f7c(%ebx),%ecx
f0100202:	8d 51 01             	lea    0x1(%ecx),%edx
f0100205:	89 93 7c 1f 00 00    	mov    %edx,0x1f7c(%ebx)
f010020b:	88 84 0b 78 1d 00 00 	mov    %al,0x1d78(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f0100212:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100218:	75 d7                	jne    f01001f1 <cons_intr+0x12>
			cons.wpos = 0;
f010021a:	c7 83 7c 1f 00 00 00 	movl   $0x0,0x1f7c(%ebx)
f0100221:	00 00 00 
f0100224:	eb cb                	jmp    f01001f1 <cons_intr+0x12>
	}
}
f0100226:	5b                   	pop    %ebx
f0100227:	5e                   	pop    %esi
f0100228:	5d                   	pop    %ebp
f0100229:	c3                   	ret    

f010022a <kbd_proc_data>:
{
f010022a:	55                   	push   %ebp
f010022b:	89 e5                	mov    %esp,%ebp
f010022d:	56                   	push   %esi
f010022e:	53                   	push   %ebx
f010022f:	e8 88 ff ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100234:	81 c3 d4 10 01 00    	add    $0x110d4,%ebx
f010023a:	ba 64 00 00 00       	mov    $0x64,%edx
f010023f:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f0100240:	a8 01                	test   $0x1,%al
f0100242:	0f 84 06 01 00 00    	je     f010034e <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f0100248:	a8 20                	test   $0x20,%al
f010024a:	0f 85 05 01 00 00    	jne    f0100355 <kbd_proc_data+0x12b>
f0100250:	ba 60 00 00 00       	mov    $0x60,%edx
f0100255:	ec                   	in     (%dx),%al
f0100256:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f0100258:	3c e0                	cmp    $0xe0,%al
f010025a:	0f 84 93 00 00 00    	je     f01002f3 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f0100260:	84 c0                	test   %al,%al
f0100262:	0f 88 a0 00 00 00    	js     f0100308 <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f0100268:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010026e:	f6 c1 40             	test   $0x40,%cl
f0100271:	74 0e                	je     f0100281 <kbd_proc_data+0x57>
		data |= 0x80;
f0100273:	83 c8 80             	or     $0xffffff80,%eax
f0100276:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100278:	83 e1 bf             	and    $0xffffffbf,%ecx
f010027b:	89 8b 58 1d 00 00    	mov    %ecx,0x1d58(%ebx)
	shift |= shiftcode[data];
f0100281:	0f b6 d2             	movzbl %dl,%edx
f0100284:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
f010028b:	ff 
f010028c:	0b 83 58 1d 00 00    	or     0x1d58(%ebx),%eax
	shift ^= togglecode[data];
f0100292:	0f b6 8c 13 38 09 ff 	movzbl -0xf6c8(%ebx,%edx,1),%ecx
f0100299:	ff 
f010029a:	31 c8                	xor    %ecx,%eax
f010029c:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f01002a2:	89 c1                	mov    %eax,%ecx
f01002a4:	83 e1 03             	and    $0x3,%ecx
f01002a7:	8b 8c 8b f8 1c 00 00 	mov    0x1cf8(%ebx,%ecx,4),%ecx
f01002ae:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002b2:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f01002b5:	a8 08                	test   $0x8,%al
f01002b7:	74 0d                	je     f01002c6 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f01002b9:	89 f2                	mov    %esi,%edx
f01002bb:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f01002be:	83 f9 19             	cmp    $0x19,%ecx
f01002c1:	77 7a                	ja     f010033d <kbd_proc_data+0x113>
			c += 'A' - 'a';
f01002c3:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002c6:	f7 d0                	not    %eax
f01002c8:	a8 06                	test   $0x6,%al
f01002ca:	75 33                	jne    f01002ff <kbd_proc_data+0xd5>
f01002cc:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f01002d2:	75 2b                	jne    f01002ff <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f01002d4:	83 ec 0c             	sub    $0xc,%esp
f01002d7:	8d 83 fc 08 ff ff    	lea    -0xf704(%ebx),%eax
f01002dd:	50                   	push   %eax
f01002de:	e8 44 08 00 00       	call   f0100b27 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002e8:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ed:	ee                   	out    %al,(%dx)
f01002ee:	83 c4 10             	add    $0x10,%esp
f01002f1:	eb 0c                	jmp    f01002ff <kbd_proc_data+0xd5>
		shift |= E0ESC;
f01002f3:	83 8b 58 1d 00 00 40 	orl    $0x40,0x1d58(%ebx)
		return 0;
f01002fa:	be 00 00 00 00       	mov    $0x0,%esi
}
f01002ff:	89 f0                	mov    %esi,%eax
f0100301:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100304:	5b                   	pop    %ebx
f0100305:	5e                   	pop    %esi
f0100306:	5d                   	pop    %ebp
f0100307:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100308:	8b 8b 58 1d 00 00    	mov    0x1d58(%ebx),%ecx
f010030e:	89 ce                	mov    %ecx,%esi
f0100310:	83 e6 40             	and    $0x40,%esi
f0100313:	83 e0 7f             	and    $0x7f,%eax
f0100316:	85 f6                	test   %esi,%esi
f0100318:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010031b:	0f b6 d2             	movzbl %dl,%edx
f010031e:	0f b6 84 13 38 0a ff 	movzbl -0xf5c8(%ebx,%edx,1),%eax
f0100325:	ff 
f0100326:	83 c8 40             	or     $0x40,%eax
f0100329:	0f b6 c0             	movzbl %al,%eax
f010032c:	f7 d0                	not    %eax
f010032e:	21 c8                	and    %ecx,%eax
f0100330:	89 83 58 1d 00 00    	mov    %eax,0x1d58(%ebx)
		return 0;
f0100336:	be 00 00 00 00       	mov    $0x0,%esi
f010033b:	eb c2                	jmp    f01002ff <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f010033d:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100340:	8d 4e 20             	lea    0x20(%esi),%ecx
f0100343:	83 fa 1a             	cmp    $0x1a,%edx
f0100346:	0f 42 f1             	cmovb  %ecx,%esi
f0100349:	e9 78 ff ff ff       	jmp    f01002c6 <kbd_proc_data+0x9c>
		return -1;
f010034e:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0100353:	eb aa                	jmp    f01002ff <kbd_proc_data+0xd5>
		return -1;
f0100355:	be ff ff ff ff       	mov    $0xffffffff,%esi
f010035a:	eb a3                	jmp    f01002ff <kbd_proc_data+0xd5>

f010035c <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010035c:	55                   	push   %ebp
f010035d:	89 e5                	mov    %esp,%ebp
f010035f:	57                   	push   %edi
f0100360:	56                   	push   %esi
f0100361:	53                   	push   %ebx
f0100362:	83 ec 1c             	sub    $0x1c,%esp
f0100365:	e8 52 fe ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010036a:	81 c3 9e 0f 01 00    	add    $0x10f9e,%ebx
f0100370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100373:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100378:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010037d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100382:	eb 09                	jmp    f010038d <cons_putc+0x31>
f0100384:	89 ca                	mov    %ecx,%edx
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	ec                   	in     (%dx),%al
	     i++)
f010038a:	83 c6 01             	add    $0x1,%esi
f010038d:	89 fa                	mov    %edi,%edx
f010038f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100390:	a8 20                	test   $0x20,%al
f0100392:	75 08                	jne    f010039c <cons_putc+0x40>
f0100394:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010039a:	7e e8                	jle    f0100384 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010039c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010039f:	89 f8                	mov    %edi,%eax
f01003a1:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003a4:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01003a9:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01003aa:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003af:	bf 79 03 00 00       	mov    $0x379,%edi
f01003b4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003b9:	eb 09                	jmp    f01003c4 <cons_putc+0x68>
f01003bb:	89 ca                	mov    %ecx,%edx
f01003bd:	ec                   	in     (%dx),%al
f01003be:	ec                   	in     (%dx),%al
f01003bf:	ec                   	in     (%dx),%al
f01003c0:	ec                   	in     (%dx),%al
f01003c1:	83 c6 01             	add    $0x1,%esi
f01003c4:	89 fa                	mov    %edi,%edx
f01003c6:	ec                   	in     (%dx),%al
f01003c7:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003cd:	7f 04                	jg     f01003d3 <cons_putc+0x77>
f01003cf:	84 c0                	test   %al,%al
f01003d1:	79 e8                	jns    f01003bb <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d3:	ba 78 03 00 00       	mov    $0x378,%edx
f01003d8:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f01003dc:	ee                   	out    %al,(%dx)
f01003dd:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003e2:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003e7:	ee                   	out    %al,(%dx)
f01003e8:	b8 08 00 00 00       	mov    $0x8,%eax
f01003ed:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f01003ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0500;
f01003f9:	89 f8                	mov    %edi,%eax
f01003fb:	80 cc 05             	or     $0x5,%ah
f01003fe:	85 d2                	test   %edx,%edx
f0100400:	0f 45 c7             	cmovne %edi,%eax
f0100403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100406:	0f b6 c0             	movzbl %al,%eax
f0100409:	83 f8 09             	cmp    $0x9,%eax
f010040c:	0f 84 b9 00 00 00    	je     f01004cb <cons_putc+0x16f>
f0100412:	83 f8 09             	cmp    $0x9,%eax
f0100415:	7e 74                	jle    f010048b <cons_putc+0x12f>
f0100417:	83 f8 0a             	cmp    $0xa,%eax
f010041a:	0f 84 9e 00 00 00    	je     f01004be <cons_putc+0x162>
f0100420:	83 f8 0d             	cmp    $0xd,%eax
f0100423:	0f 85 d9 00 00 00    	jne    f0100502 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f0100429:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100430:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100436:	c1 e8 16             	shr    $0x16,%eax
f0100439:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043c:	c1 e0 04             	shl    $0x4,%eax
f010043f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
	if (crt_pos >= CRT_SIZE) {
f0100446:	66 81 bb 80 1f 00 00 	cmpw   $0x7cf,0x1f80(%ebx)
f010044d:	cf 07 
f010044f:	0f 87 d4 00 00 00    	ja     f0100529 <cons_putc+0x1cd>
	outb(addr_6845, 14);
f0100455:	8b 8b 88 1f 00 00    	mov    0x1f88(%ebx),%ecx
f010045b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100460:	89 ca                	mov    %ecx,%edx
f0100462:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100463:	0f b7 9b 80 1f 00 00 	movzwl 0x1f80(%ebx),%ebx
f010046a:	8d 71 01             	lea    0x1(%ecx),%esi
f010046d:	89 d8                	mov    %ebx,%eax
f010046f:	66 c1 e8 08          	shr    $0x8,%ax
f0100473:	89 f2                	mov    %esi,%edx
f0100475:	ee                   	out    %al,(%dx)
f0100476:	b8 0f 00 00 00       	mov    $0xf,%eax
f010047b:	89 ca                	mov    %ecx,%edx
f010047d:	ee                   	out    %al,(%dx)
f010047e:	89 d8                	mov    %ebx,%eax
f0100480:	89 f2                	mov    %esi,%edx
f0100482:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100483:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5e                   	pop    %esi
f0100488:	5f                   	pop    %edi
f0100489:	5d                   	pop    %ebp
f010048a:	c3                   	ret    
	switch (c & 0xff) {
f010048b:	83 f8 08             	cmp    $0x8,%eax
f010048e:	75 72                	jne    f0100502 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100490:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100497:	66 85 c0             	test   %ax,%ax
f010049a:	74 b9                	je     f0100455 <cons_putc+0xf9>
			crt_pos--;
f010049c:	83 e8 01             	sub    $0x1,%eax
f010049f:	66 89 83 80 1f 00 00 	mov    %ax,0x1f80(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f01004ad:	b2 00                	mov    $0x0,%dl
f01004af:	83 ca 20             	or     $0x20,%edx
f01004b2:	8b 8b 84 1f 00 00    	mov    0x1f84(%ebx),%ecx
f01004b8:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f01004bc:	eb 88                	jmp    f0100446 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f01004be:	66 83 83 80 1f 00 00 	addw   $0x50,0x1f80(%ebx)
f01004c5:	50 
f01004c6:	e9 5e ff ff ff       	jmp    f0100429 <cons_putc+0xcd>
		cons_putc(' ');
f01004cb:	b8 20 00 00 00       	mov    $0x20,%eax
f01004d0:	e8 87 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004d5:	b8 20 00 00 00       	mov    $0x20,%eax
f01004da:	e8 7d fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004df:	b8 20 00 00 00       	mov    $0x20,%eax
f01004e4:	e8 73 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004e9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ee:	e8 69 fe ff ff       	call   f010035c <cons_putc>
		cons_putc(' ');
f01004f3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f8:	e8 5f fe ff ff       	call   f010035c <cons_putc>
f01004fd:	e9 44 ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100502:	0f b7 83 80 1f 00 00 	movzwl 0x1f80(%ebx),%eax
f0100509:	8d 50 01             	lea    0x1(%eax),%edx
f010050c:	66 89 93 80 1f 00 00 	mov    %dx,0x1f80(%ebx)
f0100513:	0f b7 c0             	movzwl %ax,%eax
f0100516:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010051c:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f0100520:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100524:	e9 1d ff ff ff       	jmp    f0100446 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100529:	8b 83 84 1f 00 00    	mov    0x1f84(%ebx),%eax
f010052f:	83 ec 04             	sub    $0x4,%esp
f0100532:	68 00 0f 00 00       	push   $0xf00
f0100537:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010053d:	52                   	push   %edx
f010053e:	50                   	push   %eax
f010053f:	e8 45 12 00 00       	call   f0101789 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f0100544:	8b 93 84 1f 00 00    	mov    0x1f84(%ebx),%edx
f010054a:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100550:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100556:	83 c4 10             	add    $0x10,%esp
f0100559:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010055e:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100561:	39 d0                	cmp    %edx,%eax
f0100563:	75 f4                	jne    f0100559 <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f0100565:	66 83 ab 80 1f 00 00 	subw   $0x50,0x1f80(%ebx)
f010056c:	50 
f010056d:	e9 e3 fe ff ff       	jmp    f0100455 <cons_putc+0xf9>

f0100572 <serial_intr>:
{
f0100572:	e8 e7 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f0100577:	05 91 0d 01 00       	add    $0x10d91,%eax
	if (serial_exists)
f010057c:	80 b8 8c 1f 00 00 00 	cmpb   $0x0,0x1f8c(%eax)
f0100583:	75 02                	jne    f0100587 <serial_intr+0x15>
f0100585:	f3 c3                	repz ret 
{
f0100587:	55                   	push   %ebp
f0100588:	89 e5                	mov    %esp,%ebp
f010058a:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f010058d:	8d 80 b8 ee fe ff    	lea    -0x11148(%eax),%eax
f0100593:	e8 47 fc ff ff       	call   f01001df <cons_intr>
}
f0100598:	c9                   	leave  
f0100599:	c3                   	ret    

f010059a <kbd_intr>:
{
f010059a:	55                   	push   %ebp
f010059b:	89 e5                	mov    %esp,%ebp
f010059d:	83 ec 08             	sub    $0x8,%esp
f01005a0:	e8 b9 01 00 00       	call   f010075e <__x86.get_pc_thunk.ax>
f01005a5:	05 63 0d 01 00       	add    $0x10d63,%eax
	cons_intr(kbd_proc_data);
f01005aa:	8d 80 22 ef fe ff    	lea    -0x110de(%eax),%eax
f01005b0:	e8 2a fc ff ff       	call   f01001df <cons_intr>
}
f01005b5:	c9                   	leave  
f01005b6:	c3                   	ret    

f01005b7 <cons_getc>:
{
f01005b7:	55                   	push   %ebp
f01005b8:	89 e5                	mov    %esp,%ebp
f01005ba:	53                   	push   %ebx
f01005bb:	83 ec 04             	sub    $0x4,%esp
f01005be:	e8 f9 fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01005c3:	81 c3 45 0d 01 00    	add    $0x10d45,%ebx
	serial_intr();
f01005c9:	e8 a4 ff ff ff       	call   f0100572 <serial_intr>
	kbd_intr();
f01005ce:	e8 c7 ff ff ff       	call   f010059a <kbd_intr>
	if (cons.rpos != cons.wpos) {
f01005d3:	8b 93 78 1f 00 00    	mov    0x1f78(%ebx),%edx
	return 0;
f01005d9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f01005de:	3b 93 7c 1f 00 00    	cmp    0x1f7c(%ebx),%edx
f01005e4:	74 19                	je     f01005ff <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f01005e6:	8d 4a 01             	lea    0x1(%edx),%ecx
f01005e9:	89 8b 78 1f 00 00    	mov    %ecx,0x1f78(%ebx)
f01005ef:	0f b6 84 13 78 1d 00 	movzbl 0x1d78(%ebx,%edx,1),%eax
f01005f6:	00 
		if (cons.rpos == CONSBUFSIZE)
f01005f7:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01005fd:	74 06                	je     f0100605 <cons_getc+0x4e>
}
f01005ff:	83 c4 04             	add    $0x4,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    
			cons.rpos = 0;
f0100605:	c7 83 78 1f 00 00 00 	movl   $0x0,0x1f78(%ebx)
f010060c:	00 00 00 
f010060f:	eb ee                	jmp    f01005ff <cons_getc+0x48>

f0100611 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	57                   	push   %edi
f0100615:	56                   	push   %esi
f0100616:	53                   	push   %ebx
f0100617:	83 ec 1c             	sub    $0x1c,%esp
f010061a:	e8 9d fb ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010061f:	81 c3 e9 0c 01 00    	add    $0x10ce9,%ebx
	was = *cp;
f0100625:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010062c:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100633:	5a a5 
	if (*cp != 0xA55A) {
f0100635:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010063c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100640:	0f 84 bc 00 00 00    	je     f0100702 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f0100646:	c7 83 88 1f 00 00 b4 	movl   $0x3b4,0x1f88(%ebx)
f010064d:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100650:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f0100657:	8b bb 88 1f 00 00    	mov    0x1f88(%ebx),%edi
f010065d:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100662:	89 fa                	mov    %edi,%edx
f0100664:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100665:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	89 ca                	mov    %ecx,%edx
f010066a:	ec                   	in     (%dx),%al
f010066b:	0f b6 f0             	movzbl %al,%esi
f010066e:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100671:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100676:	89 fa                	mov    %edi,%edx
f0100678:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100679:	89 ca                	mov    %ecx,%edx
f010067b:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010067f:	89 bb 84 1f 00 00    	mov    %edi,0x1f84(%ebx)
	pos |= inb(addr_6845 + 1);
f0100685:	0f b6 c0             	movzbl %al,%eax
f0100688:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010068a:	66 89 b3 80 1f 00 00 	mov    %si,0x1f80(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100691:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100696:	89 c8                	mov    %ecx,%eax
f0100698:	ba fa 03 00 00       	mov    $0x3fa,%edx
f010069d:	ee                   	out    %al,(%dx)
f010069e:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006a3:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006a8:	89 fa                	mov    %edi,%edx
f01006aa:	ee                   	out    %al,(%dx)
f01006ab:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006b0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006b5:	ee                   	out    %al,(%dx)
f01006b6:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006bb:	89 c8                	mov    %ecx,%eax
f01006bd:	89 f2                	mov    %esi,%edx
f01006bf:	ee                   	out    %al,(%dx)
f01006c0:	b8 03 00 00 00       	mov    $0x3,%eax
f01006c5:	89 fa                	mov    %edi,%edx
f01006c7:	ee                   	out    %al,(%dx)
f01006c8:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01006cd:	89 c8                	mov    %ecx,%eax
f01006cf:	ee                   	out    %al,(%dx)
f01006d0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006d5:	89 f2                	mov    %esi,%edx
f01006d7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d8:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01006dd:	ec                   	in     (%dx),%al
f01006de:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01006e0:	3c ff                	cmp    $0xff,%al
f01006e2:	0f 95 83 8c 1f 00 00 	setne  0x1f8c(%ebx)
f01006e9:	ba fa 03 00 00       	mov    $0x3fa,%edx
f01006ee:	ec                   	in     (%dx),%al
f01006ef:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f4:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01006f5:	80 f9 ff             	cmp    $0xff,%cl
f01006f8:	74 25                	je     f010071f <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f01006fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01006fd:	5b                   	pop    %ebx
f01006fe:	5e                   	pop    %esi
f01006ff:	5f                   	pop    %edi
f0100700:	5d                   	pop    %ebp
f0100701:	c3                   	ret    
		*cp = was;
f0100702:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100709:	c7 83 88 1f 00 00 d4 	movl   $0x3d4,0x1f88(%ebx)
f0100710:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100713:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f010071a:	e9 38 ff ff ff       	jmp    f0100657 <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f010071f:	83 ec 0c             	sub    $0xc,%esp
f0100722:	8d 83 08 09 ff ff    	lea    -0xf6f8(%ebx),%eax
f0100728:	50                   	push   %eax
f0100729:	e8 f9 03 00 00       	call   f0100b27 <cprintf>
f010072e:	83 c4 10             	add    $0x10,%esp
}
f0100731:	eb c7                	jmp    f01006fa <cons_init+0xe9>

f0100733 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100733:	55                   	push   %ebp
f0100734:	89 e5                	mov    %esp,%ebp
f0100736:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100739:	8b 45 08             	mov    0x8(%ebp),%eax
f010073c:	e8 1b fc ff ff       	call   f010035c <cons_putc>
}
f0100741:	c9                   	leave  
f0100742:	c3                   	ret    

f0100743 <getchar>:

int
getchar(void)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100749:	e8 69 fe ff ff       	call   f01005b7 <cons_getc>
f010074e:	85 c0                	test   %eax,%eax
f0100750:	74 f7                	je     f0100749 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100752:	c9                   	leave  
f0100753:	c3                   	ret    

f0100754 <iscons>:

int
iscons(int fdnum)
{
f0100754:	55                   	push   %ebp
f0100755:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100757:	b8 01 00 00 00       	mov    $0x1,%eax
f010075c:	5d                   	pop    %ebp
f010075d:	c3                   	ret    

f010075e <__x86.get_pc_thunk.ax>:
f010075e:	8b 04 24             	mov    (%esp),%eax
f0100761:	c3                   	ret    

f0100762 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100762:	55                   	push   %ebp
f0100763:	89 e5                	mov    %esp,%ebp
f0100765:	56                   	push   %esi
f0100766:	53                   	push   %ebx
f0100767:	e8 50 fa ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f010076c:	81 c3 9c 0b 01 00    	add    $0x10b9c,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100772:	83 ec 04             	sub    $0x4,%esp
f0100775:	8d 83 38 0b ff ff    	lea    -0xf4c8(%ebx),%eax
f010077b:	50                   	push   %eax
f010077c:	8d 83 56 0b ff ff    	lea    -0xf4aa(%ebx),%eax
f0100782:	50                   	push   %eax
f0100783:	8d b3 5b 0b ff ff    	lea    -0xf4a5(%ebx),%esi
f0100789:	56                   	push   %esi
f010078a:	e8 98 03 00 00       	call   f0100b27 <cprintf>
f010078f:	83 c4 0c             	add    $0xc,%esp
f0100792:	8d 83 10 0c ff ff    	lea    -0xf3f0(%ebx),%eax
f0100798:	50                   	push   %eax
f0100799:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f010079f:	50                   	push   %eax
f01007a0:	56                   	push   %esi
f01007a1:	e8 81 03 00 00       	call   f0100b27 <cprintf>
	return 0;
}
f01007a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01007ae:	5b                   	pop    %ebx
f01007af:	5e                   	pop    %esi
f01007b0:	5d                   	pop    %ebp
f01007b1:	c3                   	ret    

f01007b2 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b2:	55                   	push   %ebp
f01007b3:	89 e5                	mov    %esp,%ebp
f01007b5:	57                   	push   %edi
f01007b6:	56                   	push   %esi
f01007b7:	53                   	push   %ebx
f01007b8:	83 ec 18             	sub    $0x18,%esp
f01007bb:	e8 fc f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01007c0:	81 c3 48 0b 01 00    	add    $0x10b48,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007c6:	8d 83 6d 0b ff ff    	lea    -0xf493(%ebx),%eax
f01007cc:	50                   	push   %eax
f01007cd:	e8 55 03 00 00       	call   f0100b27 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d2:	83 c4 08             	add    $0x8,%esp
f01007d5:	ff b3 f8 ff ff ff    	pushl  -0x8(%ebx)
f01007db:	8d 83 38 0c ff ff    	lea    -0xf3c8(%ebx),%eax
f01007e1:	50                   	push   %eax
f01007e2:	e8 40 03 00 00       	call   f0100b27 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e7:	83 c4 0c             	add    $0xc,%esp
f01007ea:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f01007f0:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f01007f6:	50                   	push   %eax
f01007f7:	57                   	push   %edi
f01007f8:	8d 83 60 0c ff ff    	lea    -0xf3a0(%ebx),%eax
f01007fe:	50                   	push   %eax
f01007ff:	e8 23 03 00 00       	call   f0100b27 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100804:	83 c4 0c             	add    $0xc,%esp
f0100807:	c7 c0 79 1b 10 f0    	mov    $0xf0101b79,%eax
f010080d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100813:	52                   	push   %edx
f0100814:	50                   	push   %eax
f0100815:	8d 83 84 0c ff ff    	lea    -0xf37c(%ebx),%eax
f010081b:	50                   	push   %eax
f010081c:	e8 06 03 00 00       	call   f0100b27 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	c7 c0 60 30 11 f0    	mov    $0xf0113060,%eax
f010082a:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100830:	52                   	push   %edx
f0100831:	50                   	push   %eax
f0100832:	8d 83 a8 0c ff ff    	lea    -0xf358(%ebx),%eax
f0100838:	50                   	push   %eax
f0100839:	e8 e9 02 00 00       	call   f0100b27 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010083e:	83 c4 0c             	add    $0xc,%esp
f0100841:	c7 c6 a0 36 11 f0    	mov    $0xf01136a0,%esi
f0100847:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010084d:	50                   	push   %eax
f010084e:	56                   	push   %esi
f010084f:	8d 83 cc 0c ff ff    	lea    -0xf334(%ebx),%eax
f0100855:	50                   	push   %eax
f0100856:	e8 cc 02 00 00       	call   f0100b27 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010085e:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f0100864:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100866:	c1 fe 0a             	sar    $0xa,%esi
f0100869:	56                   	push   %esi
f010086a:	8d 83 f0 0c ff ff    	lea    -0xf310(%ebx),%eax
f0100870:	50                   	push   %eax
f0100871:	e8 b1 02 00 00       	call   f0100b27 <cprintf>
	return 0;
}
f0100876:	b8 00 00 00 00       	mov    $0x0,%eax
f010087b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010087e:	5b                   	pop    %ebx
f010087f:	5e                   	pop    %esi
f0100880:	5f                   	pop    %edi
f0100881:	5d                   	pop    %ebp
f0100882:	c3                   	ret    

f0100883 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
f0100886:	57                   	push   %edi
f0100887:	56                   	push   %esi
f0100888:	53                   	push   %ebx
f0100889:	83 ec 58             	sub    $0x58,%esp
f010088c:	e8 2b f9 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100891:	81 c3 77 0a 01 00    	add    $0x10a77,%ebx
	// Your code here.
	cprintf("Stack backtrace:\n");
f0100897:	8d 83 86 0b ff ff    	lea    -0xf47a(%ebx),%eax
f010089d:	50                   	push   %eax
f010089e:	e8 84 02 00 00       	call   f0100b27 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008a3:	89 e8                	mov    %ebp,%eax
f01008a5:	89 c7                	mov    %eax,%edi
	unsigned int ebp, esp, eip;
	ebp=read_ebp();
	while(ebp){
f01008a7:	83 c4 10             	add    $0x10,%esp
		eip=*((unsigned int*)(ebp+4));
		esp=ebp+4;
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f01008aa:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008ad:	89 45 b8             	mov    %eax,-0x48(%ebp)
		cprintf("   ebp %08x  eip %08x args",ebp,eip);
f01008b0:	8d 83 98 0b ff ff    	lea    -0xf468(%ebx),%eax
f01008b6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	while(ebp){
f01008b9:	e9 87 00 00 00       	jmp    f0100945 <mon_backtrace+0xc2>
		eip=*((unsigned int*)(ebp+4));
f01008be:	8d 77 04             	lea    0x4(%edi),%esi
f01008c1:	8b 47 04             	mov    0x4(%edi),%eax
		debuginfo_eip(eip,&info);
f01008c4:	83 ec 08             	sub    $0x8,%esp
f01008c7:	ff 75 b8             	pushl  -0x48(%ebp)
f01008ca:	89 45 c0             	mov    %eax,-0x40(%ebp)
f01008cd:	50                   	push   %eax
f01008ce:	e8 58 03 00 00       	call   f0100c2b <debuginfo_eip>
		cprintf("   ebp %08x  eip %08x args",ebp,eip);
f01008d3:	83 c4 0c             	add    $0xc,%esp
f01008d6:	ff 75 c0             	pushl  -0x40(%ebp)
f01008d9:	57                   	push   %edi
f01008da:	ff 75 b4             	pushl  -0x4c(%ebp)
f01008dd:	e8 45 02 00 00       	call   f0100b27 <cprintf>
f01008e2:	8d 47 18             	lea    0x18(%edi),%eax
f01008e5:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f01008e8:	83 c4 10             	add    $0x10,%esp

		for(int i=0;i<5;i++){
			esp+=4;
			cprintf(" %08x", *(unsigned int*)esp);
f01008eb:	8d 83 b3 0b ff ff    	lea    -0xf44d(%ebx),%eax
f01008f1:	89 7d bc             	mov    %edi,-0x44(%ebp)
f01008f4:	89 c7                	mov    %eax,%edi
			esp+=4;
f01008f6:	83 c6 04             	add    $0x4,%esi
			cprintf(" %08x", *(unsigned int*)esp);
f01008f9:	83 ec 08             	sub    $0x8,%esp
f01008fc:	ff 36                	pushl  (%esi)
f01008fe:	57                   	push   %edi
f01008ff:	e8 23 02 00 00       	call   f0100b27 <cprintf>
		for(int i=0;i<5;i++){
f0100904:	83 c4 10             	add    $0x10,%esp
f0100907:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f010090a:	75 ea                	jne    f01008f6 <mon_backtrace+0x73>
f010090c:	8b 7d bc             	mov    -0x44(%ebp),%edi
		}
		cprintf("\t%s:%d: %.*s+%d",info.eip_file, info.eip_line,  info.eip_fn_namelen, info.eip_fn_name, eip-info.eip_fn_addr);
f010090f:	83 ec 08             	sub    $0x8,%esp
f0100912:	8b 45 c0             	mov    -0x40(%ebp),%eax
f0100915:	2b 45 e0             	sub    -0x20(%ebp),%eax
f0100918:	50                   	push   %eax
f0100919:	ff 75 d8             	pushl  -0x28(%ebp)
f010091c:	ff 75 dc             	pushl  -0x24(%ebp)
f010091f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100922:	ff 75 d0             	pushl  -0x30(%ebp)
f0100925:	8d 83 b9 0b ff ff    	lea    -0xf447(%ebx),%eax
f010092b:	50                   	push   %eax
f010092c:	e8 f6 01 00 00       	call   f0100b27 <cprintf>
		cprintf("\n");
f0100931:	83 c4 14             	add    $0x14,%esp
f0100934:	8d 83 06 09 ff ff    	lea    -0xf6fa(%ebx),%eax
f010093a:	50                   	push   %eax
f010093b:	e8 e7 01 00 00       	call   f0100b27 <cprintf>
		ebp=*((unsigned int*)ebp);
f0100940:	8b 3f                	mov    (%edi),%edi
f0100942:	83 c4 10             	add    $0x10,%esp
	while(ebp){
f0100945:	85 ff                	test   %edi,%edi
f0100947:	0f 85 71 ff ff ff    	jne    f01008be <mon_backtrace+0x3b>
	}
	return 0;
}
f010094d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100952:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100955:	5b                   	pop    %ebx
f0100956:	5e                   	pop    %esi
f0100957:	5f                   	pop    %edi
f0100958:	5d                   	pop    %ebp
f0100959:	c3                   	ret    

f010095a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010095a:	55                   	push   %ebp
f010095b:	89 e5                	mov    %esp,%ebp
f010095d:	57                   	push   %edi
f010095e:	56                   	push   %esi
f010095f:	53                   	push   %ebx
f0100960:	83 ec 68             	sub    $0x68,%esp
f0100963:	e8 54 f8 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100968:	81 c3 a0 09 01 00    	add    $0x109a0,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010096e:	8d 83 1c 0d ff ff    	lea    -0xf2e4(%ebx),%eax
f0100974:	50                   	push   %eax
f0100975:	e8 ad 01 00 00       	call   f0100b27 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010097a:	8d 83 40 0d ff ff    	lea    -0xf2c0(%ebx),%eax
f0100980:	89 04 24             	mov    %eax,(%esp)
f0100983:	e8 9f 01 00 00       	call   f0100b27 <cprintf>
	cprintf("x=%d y=%d", 3);
f0100988:	83 c4 08             	add    $0x8,%esp
f010098b:	6a 03                	push   $0x3
f010098d:	8d 83 c9 0b ff ff    	lea    -0xf437(%ebx),%eax
f0100993:	50                   	push   %eax
f0100994:	e8 8e 01 00 00       	call   f0100b27 <cprintf>
f0100999:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010099c:	8d bb d7 0b ff ff    	lea    -0xf429(%ebx),%edi
f01009a2:	eb 4a                	jmp    f01009ee <monitor+0x94>
f01009a4:	83 ec 08             	sub    $0x8,%esp
f01009a7:	0f be c0             	movsbl %al,%eax
f01009aa:	50                   	push   %eax
f01009ab:	57                   	push   %edi
f01009ac:	e8 4e 0d 00 00       	call   f01016ff <strchr>
f01009b1:	83 c4 10             	add    $0x10,%esp
f01009b4:	85 c0                	test   %eax,%eax
f01009b6:	74 08                	je     f01009c0 <monitor+0x66>
			*buf++ = 0;
f01009b8:	c6 06 00             	movb   $0x0,(%esi)
f01009bb:	8d 76 01             	lea    0x1(%esi),%esi
f01009be:	eb 79                	jmp    f0100a39 <monitor+0xdf>
		if (*buf == 0)
f01009c0:	80 3e 00             	cmpb   $0x0,(%esi)
f01009c3:	74 7f                	je     f0100a44 <monitor+0xea>
		if (argc == MAXARGS-1) {
f01009c5:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f01009c9:	74 0f                	je     f01009da <monitor+0x80>
		argv[argc++] = buf;
f01009cb:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009ce:	8d 48 01             	lea    0x1(%eax),%ecx
f01009d1:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f01009d4:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f01009d8:	eb 44                	jmp    f0100a1e <monitor+0xc4>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009da:	83 ec 08             	sub    $0x8,%esp
f01009dd:	6a 10                	push   $0x10
f01009df:	8d 83 dc 0b ff ff    	lea    -0xf424(%ebx),%eax
f01009e5:	50                   	push   %eax
f01009e6:	e8 3c 01 00 00       	call   f0100b27 <cprintf>
f01009eb:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f01009ee:	8d 83 d3 0b ff ff    	lea    -0xf42d(%ebx),%eax
f01009f4:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f01009f7:	83 ec 0c             	sub    $0xc,%esp
f01009fa:	ff 75 a4             	pushl  -0x5c(%ebp)
f01009fd:	e8 c5 0a 00 00       	call   f01014c7 <readline>
f0100a02:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100a04:	83 c4 10             	add    $0x10,%esp
f0100a07:	85 c0                	test   %eax,%eax
f0100a09:	74 ec                	je     f01009f7 <monitor+0x9d>
	argv[argc] = 0;
f0100a0b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a12:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100a19:	eb 1e                	jmp    f0100a39 <monitor+0xdf>
			buf++;
f0100a1b:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f0100a1e:	0f b6 06             	movzbl (%esi),%eax
f0100a21:	84 c0                	test   %al,%al
f0100a23:	74 14                	je     f0100a39 <monitor+0xdf>
f0100a25:	83 ec 08             	sub    $0x8,%esp
f0100a28:	0f be c0             	movsbl %al,%eax
f0100a2b:	50                   	push   %eax
f0100a2c:	57                   	push   %edi
f0100a2d:	e8 cd 0c 00 00       	call   f01016ff <strchr>
f0100a32:	83 c4 10             	add    $0x10,%esp
f0100a35:	85 c0                	test   %eax,%eax
f0100a37:	74 e2                	je     f0100a1b <monitor+0xc1>
		while (*buf && strchr(WHITESPACE, *buf))
f0100a39:	0f b6 06             	movzbl (%esi),%eax
f0100a3c:	84 c0                	test   %al,%al
f0100a3e:	0f 85 60 ff ff ff    	jne    f01009a4 <monitor+0x4a>
	argv[argc] = 0;
f0100a44:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f0100a47:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f0100a4e:	00 
	if (argc == 0)
f0100a4f:	85 c0                	test   %eax,%eax
f0100a51:	74 9b                	je     f01009ee <monitor+0x94>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a53:	83 ec 08             	sub    $0x8,%esp
f0100a56:	8d 83 56 0b ff ff    	lea    -0xf4aa(%ebx),%eax
f0100a5c:	50                   	push   %eax
f0100a5d:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a60:	e8 3c 0c 00 00       	call   f01016a1 <strcmp>
f0100a65:	83 c4 10             	add    $0x10,%esp
f0100a68:	85 c0                	test   %eax,%eax
f0100a6a:	74 38                	je     f0100aa4 <monitor+0x14a>
f0100a6c:	83 ec 08             	sub    $0x8,%esp
f0100a6f:	8d 83 64 0b ff ff    	lea    -0xf49c(%ebx),%eax
f0100a75:	50                   	push   %eax
f0100a76:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a79:	e8 23 0c 00 00       	call   f01016a1 <strcmp>
f0100a7e:	83 c4 10             	add    $0x10,%esp
f0100a81:	85 c0                	test   %eax,%eax
f0100a83:	74 1a                	je     f0100a9f <monitor+0x145>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a85:	83 ec 08             	sub    $0x8,%esp
f0100a88:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a8b:	8d 83 f9 0b ff ff    	lea    -0xf407(%ebx),%eax
f0100a91:	50                   	push   %eax
f0100a92:	e8 90 00 00 00       	call   f0100b27 <cprintf>
f0100a97:	83 c4 10             	add    $0x10,%esp
f0100a9a:	e9 4f ff ff ff       	jmp    f01009ee <monitor+0x94>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a9f:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100aa4:	83 ec 04             	sub    $0x4,%esp
f0100aa7:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100aaa:	ff 75 08             	pushl  0x8(%ebp)
f0100aad:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100ab0:	52                   	push   %edx
f0100ab1:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100ab4:	ff 94 83 10 1d 00 00 	call   *0x1d10(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100abb:	83 c4 10             	add    $0x10,%esp
f0100abe:	85 c0                	test   %eax,%eax
f0100ac0:	0f 89 28 ff ff ff    	jns    f01009ee <monitor+0x94>
				break;
	}
}
f0100ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ac9:	5b                   	pop    %ebx
f0100aca:	5e                   	pop    %esi
f0100acb:	5f                   	pop    %edi
f0100acc:	5d                   	pop    %ebp
f0100acd:	c3                   	ret    

f0100ace <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100ace:	55                   	push   %ebp
f0100acf:	89 e5                	mov    %esp,%ebp
f0100ad1:	53                   	push   %ebx
f0100ad2:	83 ec 10             	sub    $0x10,%esp
f0100ad5:	e8 e2 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100ada:	81 c3 2e 08 01 00    	add    $0x1082e,%ebx
	cputchar(ch);
f0100ae0:	ff 75 08             	pushl  0x8(%ebp)
f0100ae3:	e8 4b fc ff ff       	call   f0100733 <cputchar>
	*cnt++;
}
f0100ae8:	83 c4 10             	add    $0x10,%esp
f0100aeb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100aee:	c9                   	leave  
f0100aef:	c3                   	ret    

f0100af0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100af0:	55                   	push   %ebp
f0100af1:	89 e5                	mov    %esp,%ebp
f0100af3:	53                   	push   %ebx
f0100af4:	83 ec 14             	sub    $0x14,%esp
f0100af7:	e8 c0 f6 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100afc:	81 c3 0c 08 01 00    	add    $0x1080c,%ebx
	int cnt = 0;
f0100b02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100b09:	ff 75 0c             	pushl  0xc(%ebp)
f0100b0c:	ff 75 08             	pushl  0x8(%ebp)
f0100b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100b12:	50                   	push   %eax
f0100b13:	8d 83 c6 f7 fe ff    	lea    -0x1083a(%ebx),%eax
f0100b19:	50                   	push   %eax
f0100b1a:	e8 98 04 00 00       	call   f0100fb7 <vprintfmt>
	return cnt;
}
f0100b1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0100b22:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b25:	c9                   	leave  
f0100b26:	c3                   	ret    

f0100b27 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100b27:	55                   	push   %ebp
f0100b28:	89 e5                	mov    %esp,%ebp
f0100b2a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100b2d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100b30:	50                   	push   %eax
f0100b31:	ff 75 08             	pushl  0x8(%ebp)
f0100b34:	e8 b7 ff ff ff       	call   f0100af0 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100b39:	c9                   	leave  
f0100b3a:	c3                   	ret    

f0100b3b <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100b3b:	55                   	push   %ebp
f0100b3c:	89 e5                	mov    %esp,%ebp
f0100b3e:	57                   	push   %edi
f0100b3f:	56                   	push   %esi
f0100b40:	53                   	push   %ebx
f0100b41:	83 ec 14             	sub    $0x14,%esp
f0100b44:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100b47:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100b4a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100b4d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100b50:	8b 32                	mov    (%edx),%esi
f0100b52:	8b 01                	mov    (%ecx),%eax
f0100b54:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100b57:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100b5e:	eb 2f                	jmp    f0100b8f <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0100b60:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0100b63:	39 c6                	cmp    %eax,%esi
f0100b65:	7f 49                	jg     f0100bb0 <stab_binsearch+0x75>
f0100b67:	0f b6 0a             	movzbl (%edx),%ecx
f0100b6a:	83 ea 0c             	sub    $0xc,%edx
f0100b6d:	39 f9                	cmp    %edi,%ecx
f0100b6f:	75 ef                	jne    f0100b60 <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100b71:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100b74:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100b77:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100b7b:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100b7e:	73 35                	jae    f0100bb5 <stab_binsearch+0x7a>
			*region_left = m;
f0100b80:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100b83:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0100b85:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0100b88:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0100b8f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0100b92:	7f 4e                	jg     f0100be2 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0100b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100b97:	01 f0                	add    %esi,%eax
f0100b99:	89 c3                	mov    %eax,%ebx
f0100b9b:	c1 eb 1f             	shr    $0x1f,%ebx
f0100b9e:	01 c3                	add    %eax,%ebx
f0100ba0:	d1 fb                	sar    %ebx
f0100ba2:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100ba5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100ba8:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0100bac:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0100bae:	eb b3                	jmp    f0100b63 <stab_binsearch+0x28>
			l = true_m + 1;
f0100bb0:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0100bb3:	eb da                	jmp    f0100b8f <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0100bb5:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0100bb8:	76 14                	jbe    f0100bce <stab_binsearch+0x93>
			*region_right = m - 1;
f0100bba:	83 e8 01             	sub    $0x1,%eax
f0100bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100bc0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0100bc3:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0100bc5:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100bcc:	eb c1                	jmp    f0100b8f <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100bce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bd1:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100bd3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100bd7:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0100bd9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100be0:	eb ad                	jmp    f0100b8f <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0100be2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100be6:	74 16                	je     f0100bfe <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100be8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100beb:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100bed:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100bf0:	8b 0e                	mov    (%esi),%ecx
f0100bf2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100bf5:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100bf8:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0100bfc:	eb 12                	jmp    f0100c10 <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0100bfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c01:	8b 00                	mov    (%eax),%eax
f0100c03:	83 e8 01             	sub    $0x1,%eax
f0100c06:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0100c09:	89 07                	mov    %eax,(%edi)
f0100c0b:	eb 16                	jmp    f0100c23 <stab_binsearch+0xe8>
		     l--)
f0100c0d:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0100c10:	39 c1                	cmp    %eax,%ecx
f0100c12:	7d 0a                	jge    f0100c1e <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0100c14:	0f b6 1a             	movzbl (%edx),%ebx
f0100c17:	83 ea 0c             	sub    $0xc,%edx
f0100c1a:	39 fb                	cmp    %edi,%ebx
f0100c1c:	75 ef                	jne    f0100c0d <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0100c1e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100c21:	89 07                	mov    %eax,(%edi)
	}
}
f0100c23:	83 c4 14             	add    $0x14,%esp
f0100c26:	5b                   	pop    %ebx
f0100c27:	5e                   	pop    %esi
f0100c28:	5f                   	pop    %edi
f0100c29:	5d                   	pop    %ebp
f0100c2a:	c3                   	ret    

f0100c2b <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100c2b:	55                   	push   %ebp
f0100c2c:	89 e5                	mov    %esp,%ebp
f0100c2e:	57                   	push   %edi
f0100c2f:	56                   	push   %esi
f0100c30:	53                   	push   %ebx
f0100c31:	83 ec 3c             	sub    $0x3c,%esp
f0100c34:	e8 83 f5 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100c39:	81 c3 cf 06 01 00    	add    $0x106cf,%ebx
f0100c3f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100c42:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100c45:	8d 83 68 0d ff ff    	lea    -0xf298(%ebx),%eax
f0100c4b:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0100c4d:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0100c54:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f0100c57:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0100c5e:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f0100c61:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100c68:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0100c6e:	0f 86 37 01 00 00    	jbe    f0100dab <debuginfo_eip+0x180>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100c74:	c7 c0 3d 60 10 f0    	mov    $0xf010603d,%eax
f0100c7a:	39 83 fc ff ff ff    	cmp    %eax,-0x4(%ebx)
f0100c80:	0f 86 04 02 00 00    	jbe    f0100e8a <debuginfo_eip+0x25f>
f0100c86:	c7 c0 c8 79 10 f0    	mov    $0xf01079c8,%eax
f0100c8c:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f0100c90:	0f 85 fb 01 00 00    	jne    f0100e91 <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100c96:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100c9d:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100ca3:	c7 c2 3c 60 10 f0    	mov    $0xf010603c,%edx
f0100ca9:	29 c2                	sub    %eax,%edx
f0100cab:	c1 fa 02             	sar    $0x2,%edx
f0100cae:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0100cb4:	83 ea 01             	sub    $0x1,%edx
f0100cb7:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100cba:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100cbd:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100cc0:	83 ec 08             	sub    $0x8,%esp
f0100cc3:	57                   	push   %edi
f0100cc4:	6a 64                	push   $0x64
f0100cc6:	e8 70 fe ff ff       	call   f0100b3b <stab_binsearch>
	if (lfile == 0)
f0100ccb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cce:	83 c4 10             	add    $0x10,%esp
f0100cd1:	85 c0                	test   %eax,%eax
f0100cd3:	0f 84 bf 01 00 00    	je     f0100e98 <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100cd9:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100cdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cdf:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100ce2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100ce5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ce8:	83 ec 08             	sub    $0x8,%esp
f0100ceb:	57                   	push   %edi
f0100cec:	6a 24                	push   $0x24
f0100cee:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100cf4:	e8 42 fe ff ff       	call   f0100b3b <stab_binsearch>

	if (lfun <= rfun) {
f0100cf9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cfc:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0100cff:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0100d02:	83 c4 10             	add    $0x10,%esp
f0100d05:	39 c8                	cmp    %ecx,%eax
f0100d07:	0f 8f b6 00 00 00    	jg     f0100dc3 <debuginfo_eip+0x198>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100d0d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100d10:	c7 c1 8c 22 10 f0    	mov    $0xf010228c,%ecx
f0100d16:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0100d19:	8b 11                	mov    (%ecx),%edx
f0100d1b:	89 55 c0             	mov    %edx,-0x40(%ebp)
f0100d1e:	c7 c2 c8 79 10 f0    	mov    $0xf01079c8,%edx
f0100d24:	81 ea 3d 60 10 f0    	sub    $0xf010603d,%edx
f0100d2a:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0100d2d:	73 0c                	jae    f0100d3b <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100d2f:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0100d32:	81 c2 3d 60 10 f0    	add    $0xf010603d,%edx
f0100d38:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100d3b:	8b 51 08             	mov    0x8(%ecx),%edx
f0100d3e:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f0100d41:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0100d43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100d46:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100d49:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100d4c:	83 ec 08             	sub    $0x8,%esp
f0100d4f:	6a 3a                	push   $0x3a
f0100d51:	ff 76 08             	pushl  0x8(%esi)
f0100d54:	e8 c7 09 00 00       	call   f0101720 <strfind>
f0100d59:	2b 46 08             	sub    0x8(%esi),%eax
f0100d5c:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100d5f:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100d62:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100d65:	83 c4 08             	add    $0x8,%esp
f0100d68:	57                   	push   %edi
f0100d69:	6a 44                	push   $0x44
f0100d6b:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100d71:	e8 c5 fd ff ff       	call   f0100b3b <stab_binsearch>
	if(lline>rline){
f0100d76:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100d79:	83 c4 10             	add    $0x10,%esp
f0100d7c:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100d7f:	0f 8f 1a 01 00 00    	jg     f0100e9f <debuginfo_eip+0x274>
		return -1;
	}
	else{
		info->eip_line=stabs[lline].n_desc;
f0100d85:	89 d0                	mov    %edx,%eax
f0100d87:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100d8a:	c1 e2 02             	shl    $0x2,%edx
f0100d8d:	c7 c1 8c 22 10 f0    	mov    $0xf010228c,%ecx
f0100d93:	0f b7 7c 0a 06       	movzwl 0x6(%edx,%ecx,1),%edi
f0100d98:	89 7e 04             	mov    %edi,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100d9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100d9e:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f0100da2:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0100da6:	89 75 0c             	mov    %esi,0xc(%ebp)
f0100da9:	eb 36                	jmp    f0100de1 <debuginfo_eip+0x1b6>
  	        panic("User address");
f0100dab:	83 ec 04             	sub    $0x4,%esp
f0100dae:	8d 83 72 0d ff ff    	lea    -0xf28e(%ebx),%eax
f0100db4:	50                   	push   %eax
f0100db5:	6a 7f                	push   $0x7f
f0100db7:	8d 83 7f 0d ff ff    	lea    -0xf281(%ebx),%eax
f0100dbd:	50                   	push   %eax
f0100dbe:	e8 43 f3 ff ff       	call   f0100106 <_panic>
		info->eip_fn_addr = addr;
f0100dc3:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0100dc6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100dc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100dcc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100dcf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100dd2:	e9 75 ff ff ff       	jmp    f0100d4c <debuginfo_eip+0x121>
f0100dd7:	83 e8 01             	sub    $0x1,%eax
f0100dda:	83 ea 0c             	sub    $0xc,%edx
f0100ddd:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f0100de1:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0100de4:	39 c7                	cmp    %eax,%edi
f0100de6:	7f 24                	jg     f0100e0c <debuginfo_eip+0x1e1>
	       && stabs[lline].n_type != N_SOL
f0100de8:	0f b6 0a             	movzbl (%edx),%ecx
f0100deb:	80 f9 84             	cmp    $0x84,%cl
f0100dee:	74 46                	je     f0100e36 <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100df0:	80 f9 64             	cmp    $0x64,%cl
f0100df3:	75 e2                	jne    f0100dd7 <debuginfo_eip+0x1ac>
f0100df5:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0100df9:	74 dc                	je     f0100dd7 <debuginfo_eip+0x1ac>
f0100dfb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100dfe:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e02:	74 3b                	je     f0100e3f <debuginfo_eip+0x214>
f0100e04:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e07:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e0a:	eb 33                	jmp    f0100e3f <debuginfo_eip+0x214>
f0100e0c:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100e0f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e12:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100e15:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0100e1a:	39 fa                	cmp    %edi,%edx
f0100e1c:	0f 8d 89 00 00 00    	jge    f0100eab <debuginfo_eip+0x280>
		for (lline = lfun + 1;
f0100e22:	83 c2 01             	add    $0x1,%edx
f0100e25:	89 d0                	mov    %edx,%eax
f0100e27:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0100e2a:	c7 c2 8c 22 10 f0    	mov    $0xf010228c,%edx
f0100e30:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0100e34:	eb 3b                	jmp    f0100e71 <debuginfo_eip+0x246>
f0100e36:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100e39:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0100e3d:	75 26                	jne    f0100e65 <debuginfo_eip+0x23a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100e3f:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100e42:	c7 c0 8c 22 10 f0    	mov    $0xf010228c,%eax
f0100e48:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0100e4b:	c7 c0 c8 79 10 f0    	mov    $0xf01079c8,%eax
f0100e51:	81 e8 3d 60 10 f0    	sub    $0xf010603d,%eax
f0100e57:	39 c2                	cmp    %eax,%edx
f0100e59:	73 b4                	jae    f0100e0f <debuginfo_eip+0x1e4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100e5b:	81 c2 3d 60 10 f0    	add    $0xf010603d,%edx
f0100e61:	89 16                	mov    %edx,(%esi)
f0100e63:	eb aa                	jmp    f0100e0f <debuginfo_eip+0x1e4>
f0100e65:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0100e68:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100e6b:	eb d2                	jmp    f0100e3f <debuginfo_eip+0x214>
			info->eip_fn_narg++;
f0100e6d:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f0100e71:	39 c7                	cmp    %eax,%edi
f0100e73:	7e 31                	jle    f0100ea6 <debuginfo_eip+0x27b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100e75:	0f b6 0a             	movzbl (%edx),%ecx
f0100e78:	83 c0 01             	add    $0x1,%eax
f0100e7b:	83 c2 0c             	add    $0xc,%edx
f0100e7e:	80 f9 a0             	cmp    $0xa0,%cl
f0100e81:	74 ea                	je     f0100e6d <debuginfo_eip+0x242>
	return 0;
f0100e83:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e88:	eb 21                	jmp    f0100eab <debuginfo_eip+0x280>
		return -1;
f0100e8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e8f:	eb 1a                	jmp    f0100eab <debuginfo_eip+0x280>
f0100e91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e96:	eb 13                	jmp    f0100eab <debuginfo_eip+0x280>
		return -1;
f0100e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100e9d:	eb 0c                	jmp    f0100eab <debuginfo_eip+0x280>
		return -1;
f0100e9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ea4:	eb 05                	jmp    f0100eab <debuginfo_eip+0x280>
	return 0;
f0100ea6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eae:	5b                   	pop    %ebx
f0100eaf:	5e                   	pop    %esi
f0100eb0:	5f                   	pop    %edi
f0100eb1:	5d                   	pop    %ebp
f0100eb2:	c3                   	ret    

f0100eb3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100eb3:	55                   	push   %ebp
f0100eb4:	89 e5                	mov    %esp,%ebp
f0100eb6:	57                   	push   %edi
f0100eb7:	56                   	push   %esi
f0100eb8:	53                   	push   %ebx
f0100eb9:	83 ec 2c             	sub    $0x2c,%esp
f0100ebc:	e8 02 06 00 00       	call   f01014c3 <__x86.get_pc_thunk.cx>
f0100ec1:	81 c1 47 04 01 00    	add    $0x10447,%ecx
f0100ec7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0100eca:	89 c7                	mov    %eax,%edi
f0100ecc:	89 d6                	mov    %edx,%esi
f0100ece:	8b 45 08             	mov    0x8(%ebp),%eax
f0100ed1:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100ed4:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100ed7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100eda:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100edd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ee2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0100ee5:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0100ee8:	39 d3                	cmp    %edx,%ebx
f0100eea:	72 09                	jb     f0100ef5 <printnum+0x42>
f0100eec:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100eef:	0f 87 83 00 00 00    	ja     f0100f78 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100ef5:	83 ec 0c             	sub    $0xc,%esp
f0100ef8:	ff 75 18             	pushl  0x18(%ebp)
f0100efb:	8b 45 14             	mov    0x14(%ebp),%eax
f0100efe:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100f01:	53                   	push   %ebx
f0100f02:	ff 75 10             	pushl  0x10(%ebp)
f0100f05:	83 ec 08             	sub    $0x8,%esp
f0100f08:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f0b:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f0e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f11:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f14:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100f17:	e8 24 0a 00 00       	call   f0101940 <__udivdi3>
f0100f1c:	83 c4 18             	add    $0x18,%esp
f0100f1f:	52                   	push   %edx
f0100f20:	50                   	push   %eax
f0100f21:	89 f2                	mov    %esi,%edx
f0100f23:	89 f8                	mov    %edi,%eax
f0100f25:	e8 89 ff ff ff       	call   f0100eb3 <printnum>
f0100f2a:	83 c4 20             	add    $0x20,%esp
f0100f2d:	eb 13                	jmp    f0100f42 <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100f2f:	83 ec 08             	sub    $0x8,%esp
f0100f32:	56                   	push   %esi
f0100f33:	ff 75 18             	pushl  0x18(%ebp)
f0100f36:	ff d7                	call   *%edi
f0100f38:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0100f3b:	83 eb 01             	sub    $0x1,%ebx
f0100f3e:	85 db                	test   %ebx,%ebx
f0100f40:	7f ed                	jg     f0100f2f <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100f42:	83 ec 08             	sub    $0x8,%esp
f0100f45:	56                   	push   %esi
f0100f46:	83 ec 04             	sub    $0x4,%esp
f0100f49:	ff 75 dc             	pushl  -0x24(%ebp)
f0100f4c:	ff 75 d8             	pushl  -0x28(%ebp)
f0100f4f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100f52:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f55:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100f58:	89 f3                	mov    %esi,%ebx
f0100f5a:	e8 01 0b 00 00       	call   f0101a60 <__umoddi3>
f0100f5f:	83 c4 14             	add    $0x14,%esp
f0100f62:	0f be 84 06 8d 0d ff 	movsbl -0xf273(%esi,%eax,1),%eax
f0100f69:	ff 
f0100f6a:	50                   	push   %eax
f0100f6b:	ff d7                	call   *%edi
}
f0100f6d:	83 c4 10             	add    $0x10,%esp
f0100f70:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100f73:	5b                   	pop    %ebx
f0100f74:	5e                   	pop    %esi
f0100f75:	5f                   	pop    %edi
f0100f76:	5d                   	pop    %ebp
f0100f77:	c3                   	ret    
f0100f78:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100f7b:	eb be                	jmp    f0100f3b <printnum+0x88>

f0100f7d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100f7d:	55                   	push   %ebp
f0100f7e:	89 e5                	mov    %esp,%ebp
f0100f80:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100f83:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100f87:	8b 10                	mov    (%eax),%edx
f0100f89:	3b 50 04             	cmp    0x4(%eax),%edx
f0100f8c:	73 0a                	jae    f0100f98 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100f8e:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100f91:	89 08                	mov    %ecx,(%eax)
f0100f93:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f96:	88 02                	mov    %al,(%edx)
}
f0100f98:	5d                   	pop    %ebp
f0100f99:	c3                   	ret    

f0100f9a <printfmt>:
{
f0100f9a:	55                   	push   %ebp
f0100f9b:	89 e5                	mov    %esp,%ebp
f0100f9d:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0100fa0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100fa3:	50                   	push   %eax
f0100fa4:	ff 75 10             	pushl  0x10(%ebp)
f0100fa7:	ff 75 0c             	pushl  0xc(%ebp)
f0100faa:	ff 75 08             	pushl  0x8(%ebp)
f0100fad:	e8 05 00 00 00       	call   f0100fb7 <vprintfmt>
}
f0100fb2:	83 c4 10             	add    $0x10,%esp
f0100fb5:	c9                   	leave  
f0100fb6:	c3                   	ret    

f0100fb7 <vprintfmt>:
{
f0100fb7:	55                   	push   %ebp
f0100fb8:	89 e5                	mov    %esp,%ebp
f0100fba:	57                   	push   %edi
f0100fbb:	56                   	push   %esi
f0100fbc:	53                   	push   %ebx
f0100fbd:	83 ec 2c             	sub    $0x2c,%esp
f0100fc0:	e8 f7 f1 ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0100fc5:	81 c3 43 03 01 00    	add    $0x10343,%ebx
f0100fcb:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fce:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100fd1:	e9 c3 03 00 00       	jmp    f0101399 <.L35+0x48>
		padc = ' ';
f0100fd6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0100fda:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0100fe1:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0100fe8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0100fef:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ff4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0100ff7:	8d 47 01             	lea    0x1(%edi),%eax
f0100ffa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100ffd:	0f b6 17             	movzbl (%edi),%edx
f0101000:	8d 42 dd             	lea    -0x23(%edx),%eax
f0101003:	3c 55                	cmp    $0x55,%al
f0101005:	0f 87 16 04 00 00    	ja     f0101421 <.L22>
f010100b:	0f b6 c0             	movzbl %al,%eax
f010100e:	89 d9                	mov    %ebx,%ecx
f0101010:	03 8c 83 1c 0e ff ff 	add    -0xf1e4(%ebx,%eax,4),%ecx
f0101017:	ff e1                	jmp    *%ecx

f0101019 <.L69>:
f0101019:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f010101c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0101020:	eb d5                	jmp    f0100ff7 <vprintfmt+0x40>

f0101022 <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f0101022:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0101025:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101029:	eb cc                	jmp    f0100ff7 <vprintfmt+0x40>

f010102b <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f010102b:	0f b6 d2             	movzbl %dl,%edx
f010102e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0101031:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0101036:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101039:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f010103d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0101040:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0101043:	83 f9 09             	cmp    $0x9,%ecx
f0101046:	77 55                	ja     f010109d <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0101048:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f010104b:	eb e9                	jmp    f0101036 <.L29+0xb>

f010104d <.L26>:
			precision = va_arg(ap, int);
f010104d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101050:	8b 00                	mov    (%eax),%eax
f0101052:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101055:	8b 45 14             	mov    0x14(%ebp),%eax
f0101058:	8d 40 04             	lea    0x4(%eax),%eax
f010105b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f010105e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0101061:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101065:	79 90                	jns    f0100ff7 <vprintfmt+0x40>
				width = precision, precision = -1;
f0101067:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010106a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010106d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f0101074:	eb 81                	jmp    f0100ff7 <vprintfmt+0x40>

f0101076 <.L27>:
f0101076:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101079:	85 c0                	test   %eax,%eax
f010107b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101080:	0f 49 d0             	cmovns %eax,%edx
f0101083:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0101086:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101089:	e9 69 ff ff ff       	jmp    f0100ff7 <vprintfmt+0x40>

f010108e <.L23>:
f010108e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0101091:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101098:	e9 5a ff ff ff       	jmp    f0100ff7 <vprintfmt+0x40>
f010109d:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01010a0:	eb bf                	jmp    f0101061 <.L26+0x14>

f01010a2 <.L33>:
			lflag++;
f01010a2:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01010a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01010a9:	e9 49 ff ff ff       	jmp    f0100ff7 <vprintfmt+0x40>

f01010ae <.L30>:
			putch(va_arg(ap, int), putdat);
f01010ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01010b1:	8d 78 04             	lea    0x4(%eax),%edi
f01010b4:	83 ec 08             	sub    $0x8,%esp
f01010b7:	56                   	push   %esi
f01010b8:	ff 30                	pushl  (%eax)
f01010ba:	ff 55 08             	call   *0x8(%ebp)
			break;
f01010bd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01010c0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01010c3:	e9 ce 02 00 00       	jmp    f0101396 <.L35+0x45>

f01010c8 <.L32>:
			err = va_arg(ap, int);
f01010c8:	8b 45 14             	mov    0x14(%ebp),%eax
f01010cb:	8d 78 04             	lea    0x4(%eax),%edi
f01010ce:	8b 00                	mov    (%eax),%eax
f01010d0:	99                   	cltd   
f01010d1:	31 d0                	xor    %edx,%eax
f01010d3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01010d5:	83 f8 06             	cmp    $0x6,%eax
f01010d8:	7f 27                	jg     f0101101 <.L32+0x39>
f01010da:	8b 94 83 20 1d 00 00 	mov    0x1d20(%ebx,%eax,4),%edx
f01010e1:	85 d2                	test   %edx,%edx
f01010e3:	74 1c                	je     f0101101 <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f01010e5:	52                   	push   %edx
f01010e6:	8d 83 ae 0d ff ff    	lea    -0xf252(%ebx),%eax
f01010ec:	50                   	push   %eax
f01010ed:	56                   	push   %esi
f01010ee:	ff 75 08             	pushl  0x8(%ebp)
f01010f1:	e8 a4 fe ff ff       	call   f0100f9a <printfmt>
f01010f6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f01010f9:	89 7d 14             	mov    %edi,0x14(%ebp)
f01010fc:	e9 95 02 00 00       	jmp    f0101396 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f0101101:	50                   	push   %eax
f0101102:	8d 83 a5 0d ff ff    	lea    -0xf25b(%ebx),%eax
f0101108:	50                   	push   %eax
f0101109:	56                   	push   %esi
f010110a:	ff 75 08             	pushl  0x8(%ebp)
f010110d:	e8 88 fe ff ff       	call   f0100f9a <printfmt>
f0101112:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0101115:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0101118:	e9 79 02 00 00       	jmp    f0101396 <.L35+0x45>

f010111d <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f010111d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101120:	83 c0 04             	add    $0x4,%eax
f0101123:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101126:	8b 45 14             	mov    0x14(%ebp),%eax
f0101129:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010112b:	85 ff                	test   %edi,%edi
f010112d:	8d 83 9e 0d ff ff    	lea    -0xf262(%ebx),%eax
f0101133:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101136:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010113a:	0f 8e b5 00 00 00    	jle    f01011f5 <.L36+0xd8>
f0101140:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101144:	75 08                	jne    f010114e <.L36+0x31>
f0101146:	89 75 0c             	mov    %esi,0xc(%ebp)
f0101149:	8b 75 cc             	mov    -0x34(%ebp),%esi
f010114c:	eb 6d                	jmp    f01011bb <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010114e:	83 ec 08             	sub    $0x8,%esp
f0101151:	ff 75 cc             	pushl  -0x34(%ebp)
f0101154:	57                   	push   %edi
f0101155:	e8 82 04 00 00       	call   f01015dc <strnlen>
f010115a:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010115d:	29 c2                	sub    %eax,%edx
f010115f:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0101162:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101165:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101169:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010116c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010116f:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0101171:	eb 10                	jmp    f0101183 <.L36+0x66>
					putch(padc, putdat);
f0101173:	83 ec 08             	sub    $0x8,%esp
f0101176:	56                   	push   %esi
f0101177:	ff 75 e0             	pushl  -0x20(%ebp)
f010117a:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f010117d:	83 ef 01             	sub    $0x1,%edi
f0101180:	83 c4 10             	add    $0x10,%esp
f0101183:	85 ff                	test   %edi,%edi
f0101185:	7f ec                	jg     f0101173 <.L36+0x56>
f0101187:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010118a:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010118d:	85 d2                	test   %edx,%edx
f010118f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101194:	0f 49 c2             	cmovns %edx,%eax
f0101197:	29 c2                	sub    %eax,%edx
f0101199:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010119c:	89 75 0c             	mov    %esi,0xc(%ebp)
f010119f:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011a2:	eb 17                	jmp    f01011bb <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01011a4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01011a8:	75 30                	jne    f01011da <.L36+0xbd>
					putch(ch, putdat);
f01011aa:	83 ec 08             	sub    $0x8,%esp
f01011ad:	ff 75 0c             	pushl  0xc(%ebp)
f01011b0:	50                   	push   %eax
f01011b1:	ff 55 08             	call   *0x8(%ebp)
f01011b4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01011b7:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f01011bb:	83 c7 01             	add    $0x1,%edi
f01011be:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01011c2:	0f be c2             	movsbl %dl,%eax
f01011c5:	85 c0                	test   %eax,%eax
f01011c7:	74 52                	je     f010121b <.L36+0xfe>
f01011c9:	85 f6                	test   %esi,%esi
f01011cb:	78 d7                	js     f01011a4 <.L36+0x87>
f01011cd:	83 ee 01             	sub    $0x1,%esi
f01011d0:	79 d2                	jns    f01011a4 <.L36+0x87>
f01011d2:	8b 75 0c             	mov    0xc(%ebp),%esi
f01011d5:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01011d8:	eb 32                	jmp    f010120c <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f01011da:	0f be d2             	movsbl %dl,%edx
f01011dd:	83 ea 20             	sub    $0x20,%edx
f01011e0:	83 fa 5e             	cmp    $0x5e,%edx
f01011e3:	76 c5                	jbe    f01011aa <.L36+0x8d>
					putch('?', putdat);
f01011e5:	83 ec 08             	sub    $0x8,%esp
f01011e8:	ff 75 0c             	pushl  0xc(%ebp)
f01011eb:	6a 3f                	push   $0x3f
f01011ed:	ff 55 08             	call   *0x8(%ebp)
f01011f0:	83 c4 10             	add    $0x10,%esp
f01011f3:	eb c2                	jmp    f01011b7 <.L36+0x9a>
f01011f5:	89 75 0c             	mov    %esi,0xc(%ebp)
f01011f8:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01011fb:	eb be                	jmp    f01011bb <.L36+0x9e>
				putch(' ', putdat);
f01011fd:	83 ec 08             	sub    $0x8,%esp
f0101200:	56                   	push   %esi
f0101201:	6a 20                	push   $0x20
f0101203:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0101206:	83 ef 01             	sub    $0x1,%edi
f0101209:	83 c4 10             	add    $0x10,%esp
f010120c:	85 ff                	test   %edi,%edi
f010120e:	7f ed                	jg     f01011fd <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0101210:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101213:	89 45 14             	mov    %eax,0x14(%ebp)
f0101216:	e9 7b 01 00 00       	jmp    f0101396 <.L35+0x45>
f010121b:	8b 7d e0             	mov    -0x20(%ebp),%edi
f010121e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101221:	eb e9                	jmp    f010120c <.L36+0xef>

f0101223 <.L31>:
f0101223:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101226:	83 f9 01             	cmp    $0x1,%ecx
f0101229:	7e 40                	jle    f010126b <.L31+0x48>
		return va_arg(*ap, long long);
f010122b:	8b 45 14             	mov    0x14(%ebp),%eax
f010122e:	8b 50 04             	mov    0x4(%eax),%edx
f0101231:	8b 00                	mov    (%eax),%eax
f0101233:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101236:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101239:	8b 45 14             	mov    0x14(%ebp),%eax
f010123c:	8d 40 08             	lea    0x8(%eax),%eax
f010123f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0101242:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101246:	79 55                	jns    f010129d <.L31+0x7a>
				putch('-', putdat);
f0101248:	83 ec 08             	sub    $0x8,%esp
f010124b:	56                   	push   %esi
f010124c:	6a 2d                	push   $0x2d
f010124e:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0101251:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101254:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101257:	f7 da                	neg    %edx
f0101259:	83 d1 00             	adc    $0x0,%ecx
f010125c:	f7 d9                	neg    %ecx
f010125e:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0101261:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101266:	e9 10 01 00 00       	jmp    f010137b <.L35+0x2a>
	else if (lflag)
f010126b:	85 c9                	test   %ecx,%ecx
f010126d:	75 17                	jne    f0101286 <.L31+0x63>
		return va_arg(*ap, int);
f010126f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101272:	8b 00                	mov    (%eax),%eax
f0101274:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101277:	99                   	cltd   
f0101278:	89 55 dc             	mov    %edx,-0x24(%ebp)
f010127b:	8b 45 14             	mov    0x14(%ebp),%eax
f010127e:	8d 40 04             	lea    0x4(%eax),%eax
f0101281:	89 45 14             	mov    %eax,0x14(%ebp)
f0101284:	eb bc                	jmp    f0101242 <.L31+0x1f>
		return va_arg(*ap, long);
f0101286:	8b 45 14             	mov    0x14(%ebp),%eax
f0101289:	8b 00                	mov    (%eax),%eax
f010128b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010128e:	99                   	cltd   
f010128f:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101292:	8b 45 14             	mov    0x14(%ebp),%eax
f0101295:	8d 40 04             	lea    0x4(%eax),%eax
f0101298:	89 45 14             	mov    %eax,0x14(%ebp)
f010129b:	eb a5                	jmp    f0101242 <.L31+0x1f>
			num = getint(&ap, lflag);
f010129d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01012a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01012a3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012a8:	e9 ce 00 00 00       	jmp    f010137b <.L35+0x2a>

f01012ad <.L37>:
f01012ad:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01012b0:	83 f9 01             	cmp    $0x1,%ecx
f01012b3:	7e 18                	jle    f01012cd <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f01012b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b8:	8b 10                	mov    (%eax),%edx
f01012ba:	8b 48 04             	mov    0x4(%eax),%ecx
f01012bd:	8d 40 08             	lea    0x8(%eax),%eax
f01012c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012c3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012c8:	e9 ae 00 00 00       	jmp    f010137b <.L35+0x2a>
	else if (lflag)
f01012cd:	85 c9                	test   %ecx,%ecx
f01012cf:	75 1a                	jne    f01012eb <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f01012d1:	8b 45 14             	mov    0x14(%ebp),%eax
f01012d4:	8b 10                	mov    (%eax),%edx
f01012d6:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012db:	8d 40 04             	lea    0x4(%eax),%eax
f01012de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012e1:	b8 0a 00 00 00       	mov    $0xa,%eax
f01012e6:	e9 90 00 00 00       	jmp    f010137b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01012eb:	8b 45 14             	mov    0x14(%ebp),%eax
f01012ee:	8b 10                	mov    (%eax),%edx
f01012f0:	b9 00 00 00 00       	mov    $0x0,%ecx
f01012f5:	8d 40 04             	lea    0x4(%eax),%eax
f01012f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01012fb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101300:	eb 79                	jmp    f010137b <.L35+0x2a>

f0101302 <.L34>:
f0101302:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0101305:	83 f9 01             	cmp    $0x1,%ecx
f0101308:	7e 15                	jle    f010131f <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f010130a:	8b 45 14             	mov    0x14(%ebp),%eax
f010130d:	8b 10                	mov    (%eax),%edx
f010130f:	8b 48 04             	mov    0x4(%eax),%ecx
f0101312:	8d 40 08             	lea    0x8(%eax),%eax
f0101315:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101318:	b8 08 00 00 00       	mov    $0x8,%eax
f010131d:	eb 5c                	jmp    f010137b <.L35+0x2a>
	else if (lflag)
f010131f:	85 c9                	test   %ecx,%ecx
f0101321:	75 17                	jne    f010133a <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0101323:	8b 45 14             	mov    0x14(%ebp),%eax
f0101326:	8b 10                	mov    (%eax),%edx
f0101328:	b9 00 00 00 00       	mov    $0x0,%ecx
f010132d:	8d 40 04             	lea    0x4(%eax),%eax
f0101330:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0101333:	b8 08 00 00 00       	mov    $0x8,%eax
f0101338:	eb 41                	jmp    f010137b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f010133a:	8b 45 14             	mov    0x14(%ebp),%eax
f010133d:	8b 10                	mov    (%eax),%edx
f010133f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101344:	8d 40 04             	lea    0x4(%eax),%eax
f0101347:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010134a:	b8 08 00 00 00       	mov    $0x8,%eax
f010134f:	eb 2a                	jmp    f010137b <.L35+0x2a>

f0101351 <.L35>:
			putch('0', putdat);
f0101351:	83 ec 08             	sub    $0x8,%esp
f0101354:	56                   	push   %esi
f0101355:	6a 30                	push   $0x30
f0101357:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f010135a:	83 c4 08             	add    $0x8,%esp
f010135d:	56                   	push   %esi
f010135e:	6a 78                	push   $0x78
f0101360:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0101363:	8b 45 14             	mov    0x14(%ebp),%eax
f0101366:	8b 10                	mov    (%eax),%edx
f0101368:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f010136d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0101370:	8d 40 04             	lea    0x4(%eax),%eax
f0101373:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101376:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f010137b:	83 ec 0c             	sub    $0xc,%esp
f010137e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101382:	57                   	push   %edi
f0101383:	ff 75 e0             	pushl  -0x20(%ebp)
f0101386:	50                   	push   %eax
f0101387:	51                   	push   %ecx
f0101388:	52                   	push   %edx
f0101389:	89 f2                	mov    %esi,%edx
f010138b:	8b 45 08             	mov    0x8(%ebp),%eax
f010138e:	e8 20 fb ff ff       	call   f0100eb3 <printnum>
			break;
f0101393:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0101396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101399:	83 c7 01             	add    $0x1,%edi
f010139c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01013a0:	83 f8 25             	cmp    $0x25,%eax
f01013a3:	0f 84 2d fc ff ff    	je     f0100fd6 <vprintfmt+0x1f>
			if (ch == '\0')
f01013a9:	85 c0                	test   %eax,%eax
f01013ab:	0f 84 91 00 00 00    	je     f0101442 <.L22+0x21>
			putch(ch, putdat);
f01013b1:	83 ec 08             	sub    $0x8,%esp
f01013b4:	56                   	push   %esi
f01013b5:	50                   	push   %eax
f01013b6:	ff 55 08             	call   *0x8(%ebp)
f01013b9:	83 c4 10             	add    $0x10,%esp
f01013bc:	eb db                	jmp    f0101399 <.L35+0x48>

f01013be <.L38>:
f01013be:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f01013c1:	83 f9 01             	cmp    $0x1,%ecx
f01013c4:	7e 15                	jle    f01013db <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f01013c6:	8b 45 14             	mov    0x14(%ebp),%eax
f01013c9:	8b 10                	mov    (%eax),%edx
f01013cb:	8b 48 04             	mov    0x4(%eax),%ecx
f01013ce:	8d 40 08             	lea    0x8(%eax),%eax
f01013d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013d4:	b8 10 00 00 00       	mov    $0x10,%eax
f01013d9:	eb a0                	jmp    f010137b <.L35+0x2a>
	else if (lflag)
f01013db:	85 c9                	test   %ecx,%ecx
f01013dd:	75 17                	jne    f01013f6 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f01013df:	8b 45 14             	mov    0x14(%ebp),%eax
f01013e2:	8b 10                	mov    (%eax),%edx
f01013e4:	b9 00 00 00 00       	mov    $0x0,%ecx
f01013e9:	8d 40 04             	lea    0x4(%eax),%eax
f01013ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01013ef:	b8 10 00 00 00       	mov    $0x10,%eax
f01013f4:	eb 85                	jmp    f010137b <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f01013f6:	8b 45 14             	mov    0x14(%ebp),%eax
f01013f9:	8b 10                	mov    (%eax),%edx
f01013fb:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101400:	8d 40 04             	lea    0x4(%eax),%eax
f0101403:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0101406:	b8 10 00 00 00       	mov    $0x10,%eax
f010140b:	e9 6b ff ff ff       	jmp    f010137b <.L35+0x2a>

f0101410 <.L25>:
			putch(ch, putdat);
f0101410:	83 ec 08             	sub    $0x8,%esp
f0101413:	56                   	push   %esi
f0101414:	6a 25                	push   $0x25
f0101416:	ff 55 08             	call   *0x8(%ebp)
			break;
f0101419:	83 c4 10             	add    $0x10,%esp
f010141c:	e9 75 ff ff ff       	jmp    f0101396 <.L35+0x45>

f0101421 <.L22>:
			putch('%', putdat);
f0101421:	83 ec 08             	sub    $0x8,%esp
f0101424:	56                   	push   %esi
f0101425:	6a 25                	push   $0x25
f0101427:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f010142a:	83 c4 10             	add    $0x10,%esp
f010142d:	89 f8                	mov    %edi,%eax
f010142f:	eb 03                	jmp    f0101434 <.L22+0x13>
f0101431:	83 e8 01             	sub    $0x1,%eax
f0101434:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0101438:	75 f7                	jne    f0101431 <.L22+0x10>
f010143a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010143d:	e9 54 ff ff ff       	jmp    f0101396 <.L35+0x45>
}
f0101442:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101445:	5b                   	pop    %ebx
f0101446:	5e                   	pop    %esi
f0101447:	5f                   	pop    %edi
f0101448:	5d                   	pop    %ebp
f0101449:	c3                   	ret    

f010144a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010144a:	55                   	push   %ebp
f010144b:	89 e5                	mov    %esp,%ebp
f010144d:	53                   	push   %ebx
f010144e:	83 ec 14             	sub    $0x14,%esp
f0101451:	e8 66 ed ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f0101456:	81 c3 b2 fe 00 00    	add    $0xfeb2,%ebx
f010145c:	8b 45 08             	mov    0x8(%ebp),%eax
f010145f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101462:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101465:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101469:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010146c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101473:	85 c0                	test   %eax,%eax
f0101475:	74 2b                	je     f01014a2 <vsnprintf+0x58>
f0101477:	85 d2                	test   %edx,%edx
f0101479:	7e 27                	jle    f01014a2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010147b:	ff 75 14             	pushl  0x14(%ebp)
f010147e:	ff 75 10             	pushl  0x10(%ebp)
f0101481:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101484:	50                   	push   %eax
f0101485:	8d 83 75 fc fe ff    	lea    -0x1038b(%ebx),%eax
f010148b:	50                   	push   %eax
f010148c:	e8 26 fb ff ff       	call   f0100fb7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101491:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101494:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101497:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010149a:	83 c4 10             	add    $0x10,%esp
}
f010149d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01014a0:	c9                   	leave  
f01014a1:	c3                   	ret    
		return -E_INVAL;
f01014a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01014a7:	eb f4                	jmp    f010149d <vsnprintf+0x53>

f01014a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01014a9:	55                   	push   %ebp
f01014aa:	89 e5                	mov    %esp,%ebp
f01014ac:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01014af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01014b2:	50                   	push   %eax
f01014b3:	ff 75 10             	pushl  0x10(%ebp)
f01014b6:	ff 75 0c             	pushl  0xc(%ebp)
f01014b9:	ff 75 08             	pushl  0x8(%ebp)
f01014bc:	e8 89 ff ff ff       	call   f010144a <vsnprintf>
	va_end(ap);

	return rc;
}
f01014c1:	c9                   	leave  
f01014c2:	c3                   	ret    

f01014c3 <__x86.get_pc_thunk.cx>:
f01014c3:	8b 0c 24             	mov    (%esp),%ecx
f01014c6:	c3                   	ret    

f01014c7 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01014c7:	55                   	push   %ebp
f01014c8:	89 e5                	mov    %esp,%ebp
f01014ca:	57                   	push   %edi
f01014cb:	56                   	push   %esi
f01014cc:	53                   	push   %ebx
f01014cd:	83 ec 1c             	sub    $0x1c,%esp
f01014d0:	e8 e7 ec ff ff       	call   f01001bc <__x86.get_pc_thunk.bx>
f01014d5:	81 c3 33 fe 00 00    	add    $0xfe33,%ebx
f01014db:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01014de:	85 c0                	test   %eax,%eax
f01014e0:	74 13                	je     f01014f5 <readline+0x2e>
		cprintf("%s", prompt);
f01014e2:	83 ec 08             	sub    $0x8,%esp
f01014e5:	50                   	push   %eax
f01014e6:	8d 83 ae 0d ff ff    	lea    -0xf252(%ebx),%eax
f01014ec:	50                   	push   %eax
f01014ed:	e8 35 f6 ff ff       	call   f0100b27 <cprintf>
f01014f2:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01014f5:	83 ec 0c             	sub    $0xc,%esp
f01014f8:	6a 00                	push   $0x0
f01014fa:	e8 55 f2 ff ff       	call   f0100754 <iscons>
f01014ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101502:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0101505:	bf 00 00 00 00       	mov    $0x0,%edi
f010150a:	eb 46                	jmp    f0101552 <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010150c:	83 ec 08             	sub    $0x8,%esp
f010150f:	50                   	push   %eax
f0101510:	8d 83 74 0f ff ff    	lea    -0xf08c(%ebx),%eax
f0101516:	50                   	push   %eax
f0101517:	e8 0b f6 ff ff       	call   f0100b27 <cprintf>
			return NULL;
f010151c:	83 c4 10             	add    $0x10,%esp
f010151f:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0101524:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101527:	5b                   	pop    %ebx
f0101528:	5e                   	pop    %esi
f0101529:	5f                   	pop    %edi
f010152a:	5d                   	pop    %ebp
f010152b:	c3                   	ret    
			if (echoing)
f010152c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101530:	75 05                	jne    f0101537 <readline+0x70>
			i--;
f0101532:	83 ef 01             	sub    $0x1,%edi
f0101535:	eb 1b                	jmp    f0101552 <readline+0x8b>
				cputchar('\b');
f0101537:	83 ec 0c             	sub    $0xc,%esp
f010153a:	6a 08                	push   $0x8
f010153c:	e8 f2 f1 ff ff       	call   f0100733 <cputchar>
f0101541:	83 c4 10             	add    $0x10,%esp
f0101544:	eb ec                	jmp    f0101532 <readline+0x6b>
			buf[i++] = c;
f0101546:	89 f0                	mov    %esi,%eax
f0101548:	88 84 3b 98 1f 00 00 	mov    %al,0x1f98(%ebx,%edi,1)
f010154f:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0101552:	e8 ec f1 ff ff       	call   f0100743 <getchar>
f0101557:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0101559:	85 c0                	test   %eax,%eax
f010155b:	78 af                	js     f010150c <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010155d:	83 f8 08             	cmp    $0x8,%eax
f0101560:	0f 94 c2             	sete   %dl
f0101563:	83 f8 7f             	cmp    $0x7f,%eax
f0101566:	0f 94 c0             	sete   %al
f0101569:	08 c2                	or     %al,%dl
f010156b:	74 04                	je     f0101571 <readline+0xaa>
f010156d:	85 ff                	test   %edi,%edi
f010156f:	7f bb                	jg     f010152c <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101571:	83 fe 1f             	cmp    $0x1f,%esi
f0101574:	7e 1c                	jle    f0101592 <readline+0xcb>
f0101576:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f010157c:	7f 14                	jg     f0101592 <readline+0xcb>
			if (echoing)
f010157e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0101582:	74 c2                	je     f0101546 <readline+0x7f>
				cputchar(c);
f0101584:	83 ec 0c             	sub    $0xc,%esp
f0101587:	56                   	push   %esi
f0101588:	e8 a6 f1 ff ff       	call   f0100733 <cputchar>
f010158d:	83 c4 10             	add    $0x10,%esp
f0101590:	eb b4                	jmp    f0101546 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0101592:	83 fe 0a             	cmp    $0xa,%esi
f0101595:	74 05                	je     f010159c <readline+0xd5>
f0101597:	83 fe 0d             	cmp    $0xd,%esi
f010159a:	75 b6                	jne    f0101552 <readline+0x8b>
			if (echoing)
f010159c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01015a0:	75 13                	jne    f01015b5 <readline+0xee>
			buf[i] = 0;
f01015a2:	c6 84 3b 98 1f 00 00 	movb   $0x0,0x1f98(%ebx,%edi,1)
f01015a9:	00 
			return buf;
f01015aa:	8d 83 98 1f 00 00    	lea    0x1f98(%ebx),%eax
f01015b0:	e9 6f ff ff ff       	jmp    f0101524 <readline+0x5d>
				cputchar('\n');
f01015b5:	83 ec 0c             	sub    $0xc,%esp
f01015b8:	6a 0a                	push   $0xa
f01015ba:	e8 74 f1 ff ff       	call   f0100733 <cputchar>
f01015bf:	83 c4 10             	add    $0x10,%esp
f01015c2:	eb de                	jmp    f01015a2 <readline+0xdb>

f01015c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01015c4:	55                   	push   %ebp
f01015c5:	89 e5                	mov    %esp,%ebp
f01015c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01015ca:	b8 00 00 00 00       	mov    $0x0,%eax
f01015cf:	eb 03                	jmp    f01015d4 <strlen+0x10>
		n++;
f01015d1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01015d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01015d8:	75 f7                	jne    f01015d1 <strlen+0xd>
	return n;
}
f01015da:	5d                   	pop    %ebp
f01015db:	c3                   	ret    

f01015dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01015dc:	55                   	push   %ebp
f01015dd:	89 e5                	mov    %esp,%ebp
f01015df:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015e5:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ea:	eb 03                	jmp    f01015ef <strnlen+0x13>
		n++;
f01015ec:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01015ef:	39 d0                	cmp    %edx,%eax
f01015f1:	74 06                	je     f01015f9 <strnlen+0x1d>
f01015f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01015f7:	75 f3                	jne    f01015ec <strnlen+0x10>
	return n;
}
f01015f9:	5d                   	pop    %ebp
f01015fa:	c3                   	ret    

f01015fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01015fb:	55                   	push   %ebp
f01015fc:	89 e5                	mov    %esp,%ebp
f01015fe:	53                   	push   %ebx
f01015ff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101602:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101605:	89 c2                	mov    %eax,%edx
f0101607:	83 c1 01             	add    $0x1,%ecx
f010160a:	83 c2 01             	add    $0x1,%edx
f010160d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101611:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101614:	84 db                	test   %bl,%bl
f0101616:	75 ef                	jne    f0101607 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101618:	5b                   	pop    %ebx
f0101619:	5d                   	pop    %ebp
f010161a:	c3                   	ret    

f010161b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010161b:	55                   	push   %ebp
f010161c:	89 e5                	mov    %esp,%ebp
f010161e:	53                   	push   %ebx
f010161f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101622:	53                   	push   %ebx
f0101623:	e8 9c ff ff ff       	call   f01015c4 <strlen>
f0101628:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010162b:	ff 75 0c             	pushl  0xc(%ebp)
f010162e:	01 d8                	add    %ebx,%eax
f0101630:	50                   	push   %eax
f0101631:	e8 c5 ff ff ff       	call   f01015fb <strcpy>
	return dst;
}
f0101636:	89 d8                	mov    %ebx,%eax
f0101638:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010163b:	c9                   	leave  
f010163c:	c3                   	ret    

f010163d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010163d:	55                   	push   %ebp
f010163e:	89 e5                	mov    %esp,%ebp
f0101640:	56                   	push   %esi
f0101641:	53                   	push   %ebx
f0101642:	8b 75 08             	mov    0x8(%ebp),%esi
f0101645:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101648:	89 f3                	mov    %esi,%ebx
f010164a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010164d:	89 f2                	mov    %esi,%edx
f010164f:	eb 0f                	jmp    f0101660 <strncpy+0x23>
		*dst++ = *src;
f0101651:	83 c2 01             	add    $0x1,%edx
f0101654:	0f b6 01             	movzbl (%ecx),%eax
f0101657:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010165a:	80 39 01             	cmpb   $0x1,(%ecx)
f010165d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0101660:	39 da                	cmp    %ebx,%edx
f0101662:	75 ed                	jne    f0101651 <strncpy+0x14>
	}
	return ret;
}
f0101664:	89 f0                	mov    %esi,%eax
f0101666:	5b                   	pop    %ebx
f0101667:	5e                   	pop    %esi
f0101668:	5d                   	pop    %ebp
f0101669:	c3                   	ret    

f010166a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010166a:	55                   	push   %ebp
f010166b:	89 e5                	mov    %esp,%ebp
f010166d:	56                   	push   %esi
f010166e:	53                   	push   %ebx
f010166f:	8b 75 08             	mov    0x8(%ebp),%esi
f0101672:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101675:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101678:	89 f0                	mov    %esi,%eax
f010167a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010167e:	85 c9                	test   %ecx,%ecx
f0101680:	75 0b                	jne    f010168d <strlcpy+0x23>
f0101682:	eb 17                	jmp    f010169b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101684:	83 c2 01             	add    $0x1,%edx
f0101687:	83 c0 01             	add    $0x1,%eax
f010168a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f010168d:	39 d8                	cmp    %ebx,%eax
f010168f:	74 07                	je     f0101698 <strlcpy+0x2e>
f0101691:	0f b6 0a             	movzbl (%edx),%ecx
f0101694:	84 c9                	test   %cl,%cl
f0101696:	75 ec                	jne    f0101684 <strlcpy+0x1a>
		*dst = '\0';
f0101698:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010169b:	29 f0                	sub    %esi,%eax
}
f010169d:	5b                   	pop    %ebx
f010169e:	5e                   	pop    %esi
f010169f:	5d                   	pop    %ebp
f01016a0:	c3                   	ret    

f01016a1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01016a1:	55                   	push   %ebp
f01016a2:	89 e5                	mov    %esp,%ebp
f01016a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01016a7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01016aa:	eb 06                	jmp    f01016b2 <strcmp+0x11>
		p++, q++;
f01016ac:	83 c1 01             	add    $0x1,%ecx
f01016af:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01016b2:	0f b6 01             	movzbl (%ecx),%eax
f01016b5:	84 c0                	test   %al,%al
f01016b7:	74 04                	je     f01016bd <strcmp+0x1c>
f01016b9:	3a 02                	cmp    (%edx),%al
f01016bb:	74 ef                	je     f01016ac <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01016bd:	0f b6 c0             	movzbl %al,%eax
f01016c0:	0f b6 12             	movzbl (%edx),%edx
f01016c3:	29 d0                	sub    %edx,%eax
}
f01016c5:	5d                   	pop    %ebp
f01016c6:	c3                   	ret    

f01016c7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01016c7:	55                   	push   %ebp
f01016c8:	89 e5                	mov    %esp,%ebp
f01016ca:	53                   	push   %ebx
f01016cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01016ce:	8b 55 0c             	mov    0xc(%ebp),%edx
f01016d1:	89 c3                	mov    %eax,%ebx
f01016d3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01016d6:	eb 06                	jmp    f01016de <strncmp+0x17>
		n--, p++, q++;
f01016d8:	83 c0 01             	add    $0x1,%eax
f01016db:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01016de:	39 d8                	cmp    %ebx,%eax
f01016e0:	74 16                	je     f01016f8 <strncmp+0x31>
f01016e2:	0f b6 08             	movzbl (%eax),%ecx
f01016e5:	84 c9                	test   %cl,%cl
f01016e7:	74 04                	je     f01016ed <strncmp+0x26>
f01016e9:	3a 0a                	cmp    (%edx),%cl
f01016eb:	74 eb                	je     f01016d8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01016ed:	0f b6 00             	movzbl (%eax),%eax
f01016f0:	0f b6 12             	movzbl (%edx),%edx
f01016f3:	29 d0                	sub    %edx,%eax
}
f01016f5:	5b                   	pop    %ebx
f01016f6:	5d                   	pop    %ebp
f01016f7:	c3                   	ret    
		return 0;
f01016f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01016fd:	eb f6                	jmp    f01016f5 <strncmp+0x2e>

f01016ff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01016ff:	55                   	push   %ebp
f0101700:	89 e5                	mov    %esp,%ebp
f0101702:	8b 45 08             	mov    0x8(%ebp),%eax
f0101705:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101709:	0f b6 10             	movzbl (%eax),%edx
f010170c:	84 d2                	test   %dl,%dl
f010170e:	74 09                	je     f0101719 <strchr+0x1a>
		if (*s == c)
f0101710:	38 ca                	cmp    %cl,%dl
f0101712:	74 0a                	je     f010171e <strchr+0x1f>
	for (; *s; s++)
f0101714:	83 c0 01             	add    $0x1,%eax
f0101717:	eb f0                	jmp    f0101709 <strchr+0xa>
			return (char *) s;
	return 0;
f0101719:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010171e:	5d                   	pop    %ebp
f010171f:	c3                   	ret    

f0101720 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101720:	55                   	push   %ebp
f0101721:	89 e5                	mov    %esp,%ebp
f0101723:	8b 45 08             	mov    0x8(%ebp),%eax
f0101726:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010172a:	eb 03                	jmp    f010172f <strfind+0xf>
f010172c:	83 c0 01             	add    $0x1,%eax
f010172f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101732:	38 ca                	cmp    %cl,%dl
f0101734:	74 04                	je     f010173a <strfind+0x1a>
f0101736:	84 d2                	test   %dl,%dl
f0101738:	75 f2                	jne    f010172c <strfind+0xc>
			break;
	return (char *) s;
}
f010173a:	5d                   	pop    %ebp
f010173b:	c3                   	ret    

f010173c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010173c:	55                   	push   %ebp
f010173d:	89 e5                	mov    %esp,%ebp
f010173f:	57                   	push   %edi
f0101740:	56                   	push   %esi
f0101741:	53                   	push   %ebx
f0101742:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101745:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101748:	85 c9                	test   %ecx,%ecx
f010174a:	74 13                	je     f010175f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f010174c:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101752:	75 05                	jne    f0101759 <memset+0x1d>
f0101754:	f6 c1 03             	test   $0x3,%cl
f0101757:	74 0d                	je     f0101766 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101759:	8b 45 0c             	mov    0xc(%ebp),%eax
f010175c:	fc                   	cld    
f010175d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010175f:	89 f8                	mov    %edi,%eax
f0101761:	5b                   	pop    %ebx
f0101762:	5e                   	pop    %esi
f0101763:	5f                   	pop    %edi
f0101764:	5d                   	pop    %ebp
f0101765:	c3                   	ret    
		c &= 0xFF;
f0101766:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010176a:	89 d3                	mov    %edx,%ebx
f010176c:	c1 e3 08             	shl    $0x8,%ebx
f010176f:	89 d0                	mov    %edx,%eax
f0101771:	c1 e0 18             	shl    $0x18,%eax
f0101774:	89 d6                	mov    %edx,%esi
f0101776:	c1 e6 10             	shl    $0x10,%esi
f0101779:	09 f0                	or     %esi,%eax
f010177b:	09 c2                	or     %eax,%edx
f010177d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f010177f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0101782:	89 d0                	mov    %edx,%eax
f0101784:	fc                   	cld    
f0101785:	f3 ab                	rep stos %eax,%es:(%edi)
f0101787:	eb d6                	jmp    f010175f <memset+0x23>

f0101789 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101789:	55                   	push   %ebp
f010178a:	89 e5                	mov    %esp,%ebp
f010178c:	57                   	push   %edi
f010178d:	56                   	push   %esi
f010178e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101791:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101794:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101797:	39 c6                	cmp    %eax,%esi
f0101799:	73 35                	jae    f01017d0 <memmove+0x47>
f010179b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010179e:	39 c2                	cmp    %eax,%edx
f01017a0:	76 2e                	jbe    f01017d0 <memmove+0x47>
		s += n;
		d += n;
f01017a2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017a5:	89 d6                	mov    %edx,%esi
f01017a7:	09 fe                	or     %edi,%esi
f01017a9:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01017af:	74 0c                	je     f01017bd <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01017b1:	83 ef 01             	sub    $0x1,%edi
f01017b4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01017b7:	fd                   	std    
f01017b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01017ba:	fc                   	cld    
f01017bb:	eb 21                	jmp    f01017de <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017bd:	f6 c1 03             	test   $0x3,%cl
f01017c0:	75 ef                	jne    f01017b1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01017c2:	83 ef 04             	sub    $0x4,%edi
f01017c5:	8d 72 fc             	lea    -0x4(%edx),%esi
f01017c8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01017cb:	fd                   	std    
f01017cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017ce:	eb ea                	jmp    f01017ba <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017d0:	89 f2                	mov    %esi,%edx
f01017d2:	09 c2                	or     %eax,%edx
f01017d4:	f6 c2 03             	test   $0x3,%dl
f01017d7:	74 09                	je     f01017e2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01017d9:	89 c7                	mov    %eax,%edi
f01017db:	fc                   	cld    
f01017dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01017de:	5e                   	pop    %esi
f01017df:	5f                   	pop    %edi
f01017e0:	5d                   	pop    %ebp
f01017e1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01017e2:	f6 c1 03             	test   $0x3,%cl
f01017e5:	75 f2                	jne    f01017d9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01017e7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01017ea:	89 c7                	mov    %eax,%edi
f01017ec:	fc                   	cld    
f01017ed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01017ef:	eb ed                	jmp    f01017de <memmove+0x55>

f01017f1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01017f1:	55                   	push   %ebp
f01017f2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01017f4:	ff 75 10             	pushl  0x10(%ebp)
f01017f7:	ff 75 0c             	pushl  0xc(%ebp)
f01017fa:	ff 75 08             	pushl  0x8(%ebp)
f01017fd:	e8 87 ff ff ff       	call   f0101789 <memmove>
}
f0101802:	c9                   	leave  
f0101803:	c3                   	ret    

f0101804 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101804:	55                   	push   %ebp
f0101805:	89 e5                	mov    %esp,%ebp
f0101807:	56                   	push   %esi
f0101808:	53                   	push   %ebx
f0101809:	8b 45 08             	mov    0x8(%ebp),%eax
f010180c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010180f:	89 c6                	mov    %eax,%esi
f0101811:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101814:	39 f0                	cmp    %esi,%eax
f0101816:	74 1c                	je     f0101834 <memcmp+0x30>
		if (*s1 != *s2)
f0101818:	0f b6 08             	movzbl (%eax),%ecx
f010181b:	0f b6 1a             	movzbl (%edx),%ebx
f010181e:	38 d9                	cmp    %bl,%cl
f0101820:	75 08                	jne    f010182a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0101822:	83 c0 01             	add    $0x1,%eax
f0101825:	83 c2 01             	add    $0x1,%edx
f0101828:	eb ea                	jmp    f0101814 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010182a:	0f b6 c1             	movzbl %cl,%eax
f010182d:	0f b6 db             	movzbl %bl,%ebx
f0101830:	29 d8                	sub    %ebx,%eax
f0101832:	eb 05                	jmp    f0101839 <memcmp+0x35>
	}

	return 0;
f0101834:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101839:	5b                   	pop    %ebx
f010183a:	5e                   	pop    %esi
f010183b:	5d                   	pop    %ebp
f010183c:	c3                   	ret    

f010183d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010183d:	55                   	push   %ebp
f010183e:	89 e5                	mov    %esp,%ebp
f0101840:	8b 45 08             	mov    0x8(%ebp),%eax
f0101843:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101846:	89 c2                	mov    %eax,%edx
f0101848:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010184b:	39 d0                	cmp    %edx,%eax
f010184d:	73 09                	jae    f0101858 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f010184f:	38 08                	cmp    %cl,(%eax)
f0101851:	74 05                	je     f0101858 <memfind+0x1b>
	for (; s < ends; s++)
f0101853:	83 c0 01             	add    $0x1,%eax
f0101856:	eb f3                	jmp    f010184b <memfind+0xe>
			break;
	return (void *) s;
}
f0101858:	5d                   	pop    %ebp
f0101859:	c3                   	ret    

f010185a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010185a:	55                   	push   %ebp
f010185b:	89 e5                	mov    %esp,%ebp
f010185d:	57                   	push   %edi
f010185e:	56                   	push   %esi
f010185f:	53                   	push   %ebx
f0101860:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101863:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101866:	eb 03                	jmp    f010186b <strtol+0x11>
		s++;
f0101868:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010186b:	0f b6 01             	movzbl (%ecx),%eax
f010186e:	3c 20                	cmp    $0x20,%al
f0101870:	74 f6                	je     f0101868 <strtol+0xe>
f0101872:	3c 09                	cmp    $0x9,%al
f0101874:	74 f2                	je     f0101868 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f0101876:	3c 2b                	cmp    $0x2b,%al
f0101878:	74 2e                	je     f01018a8 <strtol+0x4e>
	int neg = 0;
f010187a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f010187f:	3c 2d                	cmp    $0x2d,%al
f0101881:	74 2f                	je     f01018b2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101883:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101889:	75 05                	jne    f0101890 <strtol+0x36>
f010188b:	80 39 30             	cmpb   $0x30,(%ecx)
f010188e:	74 2c                	je     f01018bc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101890:	85 db                	test   %ebx,%ebx
f0101892:	75 0a                	jne    f010189e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101894:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f0101899:	80 39 30             	cmpb   $0x30,(%ecx)
f010189c:	74 28                	je     f01018c6 <strtol+0x6c>
		base = 10;
f010189e:	b8 00 00 00 00       	mov    $0x0,%eax
f01018a3:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01018a6:	eb 50                	jmp    f01018f8 <strtol+0x9e>
		s++;
f01018a8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01018ab:	bf 00 00 00 00       	mov    $0x0,%edi
f01018b0:	eb d1                	jmp    f0101883 <strtol+0x29>
		s++, neg = 1;
f01018b2:	83 c1 01             	add    $0x1,%ecx
f01018b5:	bf 01 00 00 00       	mov    $0x1,%edi
f01018ba:	eb c7                	jmp    f0101883 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01018bc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01018c0:	74 0e                	je     f01018d0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01018c2:	85 db                	test   %ebx,%ebx
f01018c4:	75 d8                	jne    f010189e <strtol+0x44>
		s++, base = 8;
f01018c6:	83 c1 01             	add    $0x1,%ecx
f01018c9:	bb 08 00 00 00       	mov    $0x8,%ebx
f01018ce:	eb ce                	jmp    f010189e <strtol+0x44>
		s += 2, base = 16;
f01018d0:	83 c1 02             	add    $0x2,%ecx
f01018d3:	bb 10 00 00 00       	mov    $0x10,%ebx
f01018d8:	eb c4                	jmp    f010189e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01018da:	8d 72 9f             	lea    -0x61(%edx),%esi
f01018dd:	89 f3                	mov    %esi,%ebx
f01018df:	80 fb 19             	cmp    $0x19,%bl
f01018e2:	77 29                	ja     f010190d <strtol+0xb3>
			dig = *s - 'a' + 10;
f01018e4:	0f be d2             	movsbl %dl,%edx
f01018e7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01018ea:	3b 55 10             	cmp    0x10(%ebp),%edx
f01018ed:	7d 30                	jge    f010191f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01018ef:	83 c1 01             	add    $0x1,%ecx
f01018f2:	0f af 45 10          	imul   0x10(%ebp),%eax
f01018f6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01018f8:	0f b6 11             	movzbl (%ecx),%edx
f01018fb:	8d 72 d0             	lea    -0x30(%edx),%esi
f01018fe:	89 f3                	mov    %esi,%ebx
f0101900:	80 fb 09             	cmp    $0x9,%bl
f0101903:	77 d5                	ja     f01018da <strtol+0x80>
			dig = *s - '0';
f0101905:	0f be d2             	movsbl %dl,%edx
f0101908:	83 ea 30             	sub    $0x30,%edx
f010190b:	eb dd                	jmp    f01018ea <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f010190d:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101910:	89 f3                	mov    %esi,%ebx
f0101912:	80 fb 19             	cmp    $0x19,%bl
f0101915:	77 08                	ja     f010191f <strtol+0xc5>
			dig = *s - 'A' + 10;
f0101917:	0f be d2             	movsbl %dl,%edx
f010191a:	83 ea 37             	sub    $0x37,%edx
f010191d:	eb cb                	jmp    f01018ea <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f010191f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101923:	74 05                	je     f010192a <strtol+0xd0>
		*endptr = (char *) s;
f0101925:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101928:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010192a:	89 c2                	mov    %eax,%edx
f010192c:	f7 da                	neg    %edx
f010192e:	85 ff                	test   %edi,%edi
f0101930:	0f 45 c2             	cmovne %edx,%eax
}
f0101933:	5b                   	pop    %ebx
f0101934:	5e                   	pop    %esi
f0101935:	5f                   	pop    %edi
f0101936:	5d                   	pop    %ebp
f0101937:	c3                   	ret    
f0101938:	66 90                	xchg   %ax,%ax
f010193a:	66 90                	xchg   %ax,%ax
f010193c:	66 90                	xchg   %ax,%ax
f010193e:	66 90                	xchg   %ax,%ax

f0101940 <__udivdi3>:
f0101940:	55                   	push   %ebp
f0101941:	57                   	push   %edi
f0101942:	56                   	push   %esi
f0101943:	53                   	push   %ebx
f0101944:	83 ec 1c             	sub    $0x1c,%esp
f0101947:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010194b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010194f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101953:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101957:	85 d2                	test   %edx,%edx
f0101959:	75 35                	jne    f0101990 <__udivdi3+0x50>
f010195b:	39 f3                	cmp    %esi,%ebx
f010195d:	0f 87 bd 00 00 00    	ja     f0101a20 <__udivdi3+0xe0>
f0101963:	85 db                	test   %ebx,%ebx
f0101965:	89 d9                	mov    %ebx,%ecx
f0101967:	75 0b                	jne    f0101974 <__udivdi3+0x34>
f0101969:	b8 01 00 00 00       	mov    $0x1,%eax
f010196e:	31 d2                	xor    %edx,%edx
f0101970:	f7 f3                	div    %ebx
f0101972:	89 c1                	mov    %eax,%ecx
f0101974:	31 d2                	xor    %edx,%edx
f0101976:	89 f0                	mov    %esi,%eax
f0101978:	f7 f1                	div    %ecx
f010197a:	89 c6                	mov    %eax,%esi
f010197c:	89 e8                	mov    %ebp,%eax
f010197e:	89 f7                	mov    %esi,%edi
f0101980:	f7 f1                	div    %ecx
f0101982:	89 fa                	mov    %edi,%edx
f0101984:	83 c4 1c             	add    $0x1c,%esp
f0101987:	5b                   	pop    %ebx
f0101988:	5e                   	pop    %esi
f0101989:	5f                   	pop    %edi
f010198a:	5d                   	pop    %ebp
f010198b:	c3                   	ret    
f010198c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101990:	39 f2                	cmp    %esi,%edx
f0101992:	77 7c                	ja     f0101a10 <__udivdi3+0xd0>
f0101994:	0f bd fa             	bsr    %edx,%edi
f0101997:	83 f7 1f             	xor    $0x1f,%edi
f010199a:	0f 84 98 00 00 00    	je     f0101a38 <__udivdi3+0xf8>
f01019a0:	89 f9                	mov    %edi,%ecx
f01019a2:	b8 20 00 00 00       	mov    $0x20,%eax
f01019a7:	29 f8                	sub    %edi,%eax
f01019a9:	d3 e2                	shl    %cl,%edx
f01019ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01019af:	89 c1                	mov    %eax,%ecx
f01019b1:	89 da                	mov    %ebx,%edx
f01019b3:	d3 ea                	shr    %cl,%edx
f01019b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01019b9:	09 d1                	or     %edx,%ecx
f01019bb:	89 f2                	mov    %esi,%edx
f01019bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01019c1:	89 f9                	mov    %edi,%ecx
f01019c3:	d3 e3                	shl    %cl,%ebx
f01019c5:	89 c1                	mov    %eax,%ecx
f01019c7:	d3 ea                	shr    %cl,%edx
f01019c9:	89 f9                	mov    %edi,%ecx
f01019cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01019cf:	d3 e6                	shl    %cl,%esi
f01019d1:	89 eb                	mov    %ebp,%ebx
f01019d3:	89 c1                	mov    %eax,%ecx
f01019d5:	d3 eb                	shr    %cl,%ebx
f01019d7:	09 de                	or     %ebx,%esi
f01019d9:	89 f0                	mov    %esi,%eax
f01019db:	f7 74 24 08          	divl   0x8(%esp)
f01019df:	89 d6                	mov    %edx,%esi
f01019e1:	89 c3                	mov    %eax,%ebx
f01019e3:	f7 64 24 0c          	mull   0xc(%esp)
f01019e7:	39 d6                	cmp    %edx,%esi
f01019e9:	72 0c                	jb     f01019f7 <__udivdi3+0xb7>
f01019eb:	89 f9                	mov    %edi,%ecx
f01019ed:	d3 e5                	shl    %cl,%ebp
f01019ef:	39 c5                	cmp    %eax,%ebp
f01019f1:	73 5d                	jae    f0101a50 <__udivdi3+0x110>
f01019f3:	39 d6                	cmp    %edx,%esi
f01019f5:	75 59                	jne    f0101a50 <__udivdi3+0x110>
f01019f7:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01019fa:	31 ff                	xor    %edi,%edi
f01019fc:	89 fa                	mov    %edi,%edx
f01019fe:	83 c4 1c             	add    $0x1c,%esp
f0101a01:	5b                   	pop    %ebx
f0101a02:	5e                   	pop    %esi
f0101a03:	5f                   	pop    %edi
f0101a04:	5d                   	pop    %ebp
f0101a05:	c3                   	ret    
f0101a06:	8d 76 00             	lea    0x0(%esi),%esi
f0101a09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0101a10:	31 ff                	xor    %edi,%edi
f0101a12:	31 c0                	xor    %eax,%eax
f0101a14:	89 fa                	mov    %edi,%edx
f0101a16:	83 c4 1c             	add    $0x1c,%esp
f0101a19:	5b                   	pop    %ebx
f0101a1a:	5e                   	pop    %esi
f0101a1b:	5f                   	pop    %edi
f0101a1c:	5d                   	pop    %ebp
f0101a1d:	c3                   	ret    
f0101a1e:	66 90                	xchg   %ax,%ax
f0101a20:	31 ff                	xor    %edi,%edi
f0101a22:	89 e8                	mov    %ebp,%eax
f0101a24:	89 f2                	mov    %esi,%edx
f0101a26:	f7 f3                	div    %ebx
f0101a28:	89 fa                	mov    %edi,%edx
f0101a2a:	83 c4 1c             	add    $0x1c,%esp
f0101a2d:	5b                   	pop    %ebx
f0101a2e:	5e                   	pop    %esi
f0101a2f:	5f                   	pop    %edi
f0101a30:	5d                   	pop    %ebp
f0101a31:	c3                   	ret    
f0101a32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101a38:	39 f2                	cmp    %esi,%edx
f0101a3a:	72 06                	jb     f0101a42 <__udivdi3+0x102>
f0101a3c:	31 c0                	xor    %eax,%eax
f0101a3e:	39 eb                	cmp    %ebp,%ebx
f0101a40:	77 d2                	ja     f0101a14 <__udivdi3+0xd4>
f0101a42:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a47:	eb cb                	jmp    f0101a14 <__udivdi3+0xd4>
f0101a49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101a50:	89 d8                	mov    %ebx,%eax
f0101a52:	31 ff                	xor    %edi,%edi
f0101a54:	eb be                	jmp    f0101a14 <__udivdi3+0xd4>
f0101a56:	66 90                	xchg   %ax,%ax
f0101a58:	66 90                	xchg   %ax,%ax
f0101a5a:	66 90                	xchg   %ax,%ax
f0101a5c:	66 90                	xchg   %ax,%ax
f0101a5e:	66 90                	xchg   %ax,%ax

f0101a60 <__umoddi3>:
f0101a60:	55                   	push   %ebp
f0101a61:	57                   	push   %edi
f0101a62:	56                   	push   %esi
f0101a63:	53                   	push   %ebx
f0101a64:	83 ec 1c             	sub    $0x1c,%esp
f0101a67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101a6b:	8b 74 24 30          	mov    0x30(%esp),%esi
f0101a6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0101a73:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101a77:	85 ed                	test   %ebp,%ebp
f0101a79:	89 f0                	mov    %esi,%eax
f0101a7b:	89 da                	mov    %ebx,%edx
f0101a7d:	75 19                	jne    f0101a98 <__umoddi3+0x38>
f0101a7f:	39 df                	cmp    %ebx,%edi
f0101a81:	0f 86 b1 00 00 00    	jbe    f0101b38 <__umoddi3+0xd8>
f0101a87:	f7 f7                	div    %edi
f0101a89:	89 d0                	mov    %edx,%eax
f0101a8b:	31 d2                	xor    %edx,%edx
f0101a8d:	83 c4 1c             	add    $0x1c,%esp
f0101a90:	5b                   	pop    %ebx
f0101a91:	5e                   	pop    %esi
f0101a92:	5f                   	pop    %edi
f0101a93:	5d                   	pop    %ebp
f0101a94:	c3                   	ret    
f0101a95:	8d 76 00             	lea    0x0(%esi),%esi
f0101a98:	39 dd                	cmp    %ebx,%ebp
f0101a9a:	77 f1                	ja     f0101a8d <__umoddi3+0x2d>
f0101a9c:	0f bd cd             	bsr    %ebp,%ecx
f0101a9f:	83 f1 1f             	xor    $0x1f,%ecx
f0101aa2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101aa6:	0f 84 b4 00 00 00    	je     f0101b60 <__umoddi3+0x100>
f0101aac:	b8 20 00 00 00       	mov    $0x20,%eax
f0101ab1:	89 c2                	mov    %eax,%edx
f0101ab3:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101ab7:	29 c2                	sub    %eax,%edx
f0101ab9:	89 c1                	mov    %eax,%ecx
f0101abb:	89 f8                	mov    %edi,%eax
f0101abd:	d3 e5                	shl    %cl,%ebp
f0101abf:	89 d1                	mov    %edx,%ecx
f0101ac1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101ac5:	d3 e8                	shr    %cl,%eax
f0101ac7:	09 c5                	or     %eax,%ebp
f0101ac9:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101acd:	89 c1                	mov    %eax,%ecx
f0101acf:	d3 e7                	shl    %cl,%edi
f0101ad1:	89 d1                	mov    %edx,%ecx
f0101ad3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0101ad7:	89 df                	mov    %ebx,%edi
f0101ad9:	d3 ef                	shr    %cl,%edi
f0101adb:	89 c1                	mov    %eax,%ecx
f0101add:	89 f0                	mov    %esi,%eax
f0101adf:	d3 e3                	shl    %cl,%ebx
f0101ae1:	89 d1                	mov    %edx,%ecx
f0101ae3:	89 fa                	mov    %edi,%edx
f0101ae5:	d3 e8                	shr    %cl,%eax
f0101ae7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f0101aec:	09 d8                	or     %ebx,%eax
f0101aee:	f7 f5                	div    %ebp
f0101af0:	d3 e6                	shl    %cl,%esi
f0101af2:	89 d1                	mov    %edx,%ecx
f0101af4:	f7 64 24 08          	mull   0x8(%esp)
f0101af8:	39 d1                	cmp    %edx,%ecx
f0101afa:	89 c3                	mov    %eax,%ebx
f0101afc:	89 d7                	mov    %edx,%edi
f0101afe:	72 06                	jb     f0101b06 <__umoddi3+0xa6>
f0101b00:	75 0e                	jne    f0101b10 <__umoddi3+0xb0>
f0101b02:	39 c6                	cmp    %eax,%esi
f0101b04:	73 0a                	jae    f0101b10 <__umoddi3+0xb0>
f0101b06:	2b 44 24 08          	sub    0x8(%esp),%eax
f0101b0a:	19 ea                	sbb    %ebp,%edx
f0101b0c:	89 d7                	mov    %edx,%edi
f0101b0e:	89 c3                	mov    %eax,%ebx
f0101b10:	89 ca                	mov    %ecx,%edx
f0101b12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0101b17:	29 de                	sub    %ebx,%esi
f0101b19:	19 fa                	sbb    %edi,%edx
f0101b1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f0101b1f:	89 d0                	mov    %edx,%eax
f0101b21:	d3 e0                	shl    %cl,%eax
f0101b23:	89 d9                	mov    %ebx,%ecx
f0101b25:	d3 ee                	shr    %cl,%esi
f0101b27:	d3 ea                	shr    %cl,%edx
f0101b29:	09 f0                	or     %esi,%eax
f0101b2b:	83 c4 1c             	add    $0x1c,%esp
f0101b2e:	5b                   	pop    %ebx
f0101b2f:	5e                   	pop    %esi
f0101b30:	5f                   	pop    %edi
f0101b31:	5d                   	pop    %ebp
f0101b32:	c3                   	ret    
f0101b33:	90                   	nop
f0101b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101b38:	85 ff                	test   %edi,%edi
f0101b3a:	89 f9                	mov    %edi,%ecx
f0101b3c:	75 0b                	jne    f0101b49 <__umoddi3+0xe9>
f0101b3e:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b43:	31 d2                	xor    %edx,%edx
f0101b45:	f7 f7                	div    %edi
f0101b47:	89 c1                	mov    %eax,%ecx
f0101b49:	89 d8                	mov    %ebx,%eax
f0101b4b:	31 d2                	xor    %edx,%edx
f0101b4d:	f7 f1                	div    %ecx
f0101b4f:	89 f0                	mov    %esi,%eax
f0101b51:	f7 f1                	div    %ecx
f0101b53:	e9 31 ff ff ff       	jmp    f0101a89 <__umoddi3+0x29>
f0101b58:	90                   	nop
f0101b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101b60:	39 dd                	cmp    %ebx,%ebp
f0101b62:	72 08                	jb     f0101b6c <__umoddi3+0x10c>
f0101b64:	39 f7                	cmp    %esi,%edi
f0101b66:	0f 87 21 ff ff ff    	ja     f0101a8d <__umoddi3+0x2d>
f0101b6c:	89 da                	mov    %ebx,%edx
f0101b6e:	89 f0                	mov    %esi,%eax
f0101b70:	29 f8                	sub    %edi,%eax
f0101b72:	19 ea                	sbb    %ebp,%edx
f0101b74:	e9 14 ff ff ff       	jmp    f0101a8d <__umoddi3+0x2d>
