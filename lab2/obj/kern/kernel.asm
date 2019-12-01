
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
f0100015:	b8 00 90 11 00       	mov    $0x119000,%eax
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
f0100034:	bc 00 70 11 f0       	mov    $0xf0117000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 08             	sub    $0x8,%esp
f0100047:	e8 03 01 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010004c:	81 c3 c0 82 01 00    	add    $0x182c0,%ebx
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100052:	c7 c2 80 a0 11 f0    	mov    $0xf011a080,%edx
f0100058:	c7 c0 c0 a6 11 f0    	mov    $0xf011a6c0,%eax
f010005e:	29 d0                	sub    %edx,%eax
f0100060:	50                   	push   %eax
f0100061:	6a 00                	push   $0x0
f0100063:	52                   	push   %edx
f0100064:	e8 1b 3f 00 00       	call   f0103f84 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100069:	e8 36 05 00 00       	call   f01005a4 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006e:	83 c4 08             	add    $0x8,%esp
f0100071:	68 ac 1a 00 00       	push   $0x1aac
f0100076:	8d 83 b4 c0 fe ff    	lea    -0x13f4c(%ebx),%eax
f010007c:	50                   	push   %eax
f010007d:	e8 f1 32 00 00       	call   f0103373 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100082:	e8 55 15 00 00       	call   f01015dc <mem_init>
f0100087:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010008a:	83 ec 0c             	sub    $0xc,%esp
f010008d:	6a 00                	push   $0x0
f010008f:	e8 57 08 00 00       	call   f01008eb <monitor>
f0100094:	83 c4 10             	add    $0x10,%esp
f0100097:	eb f1                	jmp    f010008a <i386_init+0x4a>

f0100099 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100099:	55                   	push   %ebp
f010009a:	89 e5                	mov    %esp,%ebp
f010009c:	57                   	push   %edi
f010009d:	56                   	push   %esi
f010009e:	53                   	push   %ebx
f010009f:	83 ec 0c             	sub    $0xc,%esp
f01000a2:	e8 a8 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f01000a7:	81 c3 65 82 01 00    	add    $0x18265,%ebx
f01000ad:	8b 7d 10             	mov    0x10(%ebp),%edi
	va_list ap;

	if (panicstr)
f01000b0:	c7 c0 c4 a6 11 f0    	mov    $0xf011a6c4,%eax
f01000b6:	83 38 00             	cmpl   $0x0,(%eax)
f01000b9:	74 0f                	je     f01000ca <_panic+0x31>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000bb:	83 ec 0c             	sub    $0xc,%esp
f01000be:	6a 00                	push   $0x0
f01000c0:	e8 26 08 00 00       	call   f01008eb <monitor>
f01000c5:	83 c4 10             	add    $0x10,%esp
f01000c8:	eb f1                	jmp    f01000bb <_panic+0x22>
	panicstr = fmt;
f01000ca:	89 38                	mov    %edi,(%eax)
	asm volatile("cli; cld");
f01000cc:	fa                   	cli    
f01000cd:	fc                   	cld    
	va_start(ap, fmt);
f01000ce:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d1:	83 ec 04             	sub    $0x4,%esp
f01000d4:	ff 75 0c             	pushl  0xc(%ebp)
f01000d7:	ff 75 08             	pushl  0x8(%ebp)
f01000da:	8d 83 cf c0 fe ff    	lea    -0x13f31(%ebx),%eax
f01000e0:	50                   	push   %eax
f01000e1:	e8 8d 32 00 00       	call   f0103373 <cprintf>
	vcprintf(fmt, ap);
f01000e6:	83 c4 08             	add    $0x8,%esp
f01000e9:	56                   	push   %esi
f01000ea:	57                   	push   %edi
f01000eb:	e8 4c 32 00 00       	call   f010333c <vcprintf>
	cprintf("\n");
f01000f0:	8d 83 f2 d0 fe ff    	lea    -0x12f0e(%ebx),%eax
f01000f6:	89 04 24             	mov    %eax,(%esp)
f01000f9:	e8 75 32 00 00       	call   f0103373 <cprintf>
f01000fe:	83 c4 10             	add    $0x10,%esp
f0100101:	eb b8                	jmp    f01000bb <_panic+0x22>

f0100103 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100103:	55                   	push   %ebp
f0100104:	89 e5                	mov    %esp,%ebp
f0100106:	56                   	push   %esi
f0100107:	53                   	push   %ebx
f0100108:	e8 42 00 00 00       	call   f010014f <__x86.get_pc_thunk.bx>
f010010d:	81 c3 ff 81 01 00    	add    $0x181ff,%ebx
	va_list ap;

	va_start(ap, fmt);
f0100113:	8d 75 14             	lea    0x14(%ebp),%esi
	cprintf("kernel warning at %s:%d: ", file, line);
f0100116:	83 ec 04             	sub    $0x4,%esp
f0100119:	ff 75 0c             	pushl  0xc(%ebp)
f010011c:	ff 75 08             	pushl  0x8(%ebp)
f010011f:	8d 83 e7 c0 fe ff    	lea    -0x13f19(%ebx),%eax
f0100125:	50                   	push   %eax
f0100126:	e8 48 32 00 00       	call   f0103373 <cprintf>
	vcprintf(fmt, ap);
f010012b:	83 c4 08             	add    $0x8,%esp
f010012e:	56                   	push   %esi
f010012f:	ff 75 10             	pushl  0x10(%ebp)
f0100132:	e8 05 32 00 00       	call   f010333c <vcprintf>
	cprintf("\n");
f0100137:	8d 83 f2 d0 fe ff    	lea    -0x12f0e(%ebx),%eax
f010013d:	89 04 24             	mov    %eax,(%esp)
f0100140:	e8 2e 32 00 00       	call   f0103373 <cprintf>
	va_end(ap);
}
f0100145:	83 c4 10             	add    $0x10,%esp
f0100148:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010014b:	5b                   	pop    %ebx
f010014c:	5e                   	pop    %esi
f010014d:	5d                   	pop    %ebp
f010014e:	c3                   	ret    

f010014f <__x86.get_pc_thunk.bx>:
f010014f:	8b 1c 24             	mov    (%esp),%ebx
f0100152:	c3                   	ret    

f0100153 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100153:	55                   	push   %ebp
f0100154:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100156:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010015b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010015c:	a8 01                	test   $0x1,%al
f010015e:	74 0b                	je     f010016b <serial_proc_data+0x18>
f0100160:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100165:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100166:	0f b6 c0             	movzbl %al,%eax
}
f0100169:	5d                   	pop    %ebp
f010016a:	c3                   	ret    
		return -1;
f010016b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100170:	eb f7                	jmp    f0100169 <serial_proc_data+0x16>

f0100172 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100172:	55                   	push   %ebp
f0100173:	89 e5                	mov    %esp,%ebp
f0100175:	56                   	push   %esi
f0100176:	53                   	push   %ebx
f0100177:	e8 d3 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f010017c:	81 c3 90 81 01 00    	add    $0x18190,%ebx
f0100182:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
f0100184:	ff d6                	call   *%esi
f0100186:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100189:	74 2e                	je     f01001b9 <cons_intr+0x47>
		if (c == 0)
f010018b:	85 c0                	test   %eax,%eax
f010018d:	74 f5                	je     f0100184 <cons_intr+0x12>
			continue;
		cons.buf[cons.wpos++] = c;
f010018f:	8b 8b 98 1f 00 00    	mov    0x1f98(%ebx),%ecx
f0100195:	8d 51 01             	lea    0x1(%ecx),%edx
f0100198:	89 93 98 1f 00 00    	mov    %edx,0x1f98(%ebx)
f010019e:	88 84 0b 94 1d 00 00 	mov    %al,0x1d94(%ebx,%ecx,1)
		if (cons.wpos == CONSBUFSIZE)
f01001a5:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001ab:	75 d7                	jne    f0100184 <cons_intr+0x12>
			cons.wpos = 0;
f01001ad:	c7 83 98 1f 00 00 00 	movl   $0x0,0x1f98(%ebx)
f01001b4:	00 00 00 
f01001b7:	eb cb                	jmp    f0100184 <cons_intr+0x12>
	}
}
f01001b9:	5b                   	pop    %ebx
f01001ba:	5e                   	pop    %esi
f01001bb:	5d                   	pop    %ebp
f01001bc:	c3                   	ret    

f01001bd <kbd_proc_data>:
{
f01001bd:	55                   	push   %ebp
f01001be:	89 e5                	mov    %esp,%ebp
f01001c0:	56                   	push   %esi
f01001c1:	53                   	push   %ebx
f01001c2:	e8 88 ff ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01001c7:	81 c3 45 81 01 00    	add    $0x18145,%ebx
f01001cd:	ba 64 00 00 00       	mov    $0x64,%edx
f01001d2:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01001d3:	a8 01                	test   $0x1,%al
f01001d5:	0f 84 06 01 00 00    	je     f01002e1 <kbd_proc_data+0x124>
	if (stat & KBS_TERR)
f01001db:	a8 20                	test   $0x20,%al
f01001dd:	0f 85 05 01 00 00    	jne    f01002e8 <kbd_proc_data+0x12b>
f01001e3:	ba 60 00 00 00       	mov    $0x60,%edx
f01001e8:	ec                   	in     (%dx),%al
f01001e9:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01001eb:	3c e0                	cmp    $0xe0,%al
f01001ed:	0f 84 93 00 00 00    	je     f0100286 <kbd_proc_data+0xc9>
	} else if (data & 0x80) {
f01001f3:	84 c0                	test   %al,%al
f01001f5:	0f 88 a0 00 00 00    	js     f010029b <kbd_proc_data+0xde>
	} else if (shift & E0ESC) {
f01001fb:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f0100201:	f6 c1 40             	test   $0x40,%cl
f0100204:	74 0e                	je     f0100214 <kbd_proc_data+0x57>
		data |= 0x80;
f0100206:	83 c8 80             	or     $0xffffff80,%eax
f0100209:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010020b:	83 e1 bf             	and    $0xffffffbf,%ecx
f010020e:	89 8b 74 1d 00 00    	mov    %ecx,0x1d74(%ebx)
	shift |= shiftcode[data];
f0100214:	0f b6 d2             	movzbl %dl,%edx
f0100217:	0f b6 84 13 34 c2 fe 	movzbl -0x13dcc(%ebx,%edx,1),%eax
f010021e:	ff 
f010021f:	0b 83 74 1d 00 00    	or     0x1d74(%ebx),%eax
	shift ^= togglecode[data];
f0100225:	0f b6 8c 13 34 c1 fe 	movzbl -0x13ecc(%ebx,%edx,1),%ecx
f010022c:	ff 
f010022d:	31 c8                	xor    %ecx,%eax
f010022f:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
	c = charcode[shift & (CTL | SHIFT)][data];
f0100235:	89 c1                	mov    %eax,%ecx
f0100237:	83 e1 03             	and    $0x3,%ecx
f010023a:	8b 8c 8b f4 1c 00 00 	mov    0x1cf4(%ebx,%ecx,4),%ecx
f0100241:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100245:	0f b6 f2             	movzbl %dl,%esi
	if (shift & CAPSLOCK) {
f0100248:	a8 08                	test   $0x8,%al
f010024a:	74 0d                	je     f0100259 <kbd_proc_data+0x9c>
		if ('a' <= c && c <= 'z')
f010024c:	89 f2                	mov    %esi,%edx
f010024e:	8d 4e 9f             	lea    -0x61(%esi),%ecx
f0100251:	83 f9 19             	cmp    $0x19,%ecx
f0100254:	77 7a                	ja     f01002d0 <kbd_proc_data+0x113>
			c += 'A' - 'a';
f0100256:	83 ee 20             	sub    $0x20,%esi
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100259:	f7 d0                	not    %eax
f010025b:	a8 06                	test   $0x6,%al
f010025d:	75 33                	jne    f0100292 <kbd_proc_data+0xd5>
f010025f:	81 fe e9 00 00 00    	cmp    $0xe9,%esi
f0100265:	75 2b                	jne    f0100292 <kbd_proc_data+0xd5>
		cprintf("Rebooting!\n");
f0100267:	83 ec 0c             	sub    $0xc,%esp
f010026a:	8d 83 01 c1 fe ff    	lea    -0x13eff(%ebx),%eax
f0100270:	50                   	push   %eax
f0100271:	e8 fd 30 00 00       	call   f0103373 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100276:	b8 03 00 00 00       	mov    $0x3,%eax
f010027b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100280:	ee                   	out    %al,(%dx)
f0100281:	83 c4 10             	add    $0x10,%esp
f0100284:	eb 0c                	jmp    f0100292 <kbd_proc_data+0xd5>
		shift |= E0ESC;
f0100286:	83 8b 74 1d 00 00 40 	orl    $0x40,0x1d74(%ebx)
		return 0;
f010028d:	be 00 00 00 00       	mov    $0x0,%esi
}
f0100292:	89 f0                	mov    %esi,%eax
f0100294:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100297:	5b                   	pop    %ebx
f0100298:	5e                   	pop    %esi
f0100299:	5d                   	pop    %ebp
f010029a:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010029b:	8b 8b 74 1d 00 00    	mov    0x1d74(%ebx),%ecx
f01002a1:	89 ce                	mov    %ecx,%esi
f01002a3:	83 e6 40             	and    $0x40,%esi
f01002a6:	83 e0 7f             	and    $0x7f,%eax
f01002a9:	85 f6                	test   %esi,%esi
f01002ab:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01002ae:	0f b6 d2             	movzbl %dl,%edx
f01002b1:	0f b6 84 13 34 c2 fe 	movzbl -0x13dcc(%ebx,%edx,1),%eax
f01002b8:	ff 
f01002b9:	83 c8 40             	or     $0x40,%eax
f01002bc:	0f b6 c0             	movzbl %al,%eax
f01002bf:	f7 d0                	not    %eax
f01002c1:	21 c8                	and    %ecx,%eax
f01002c3:	89 83 74 1d 00 00    	mov    %eax,0x1d74(%ebx)
		return 0;
f01002c9:	be 00 00 00 00       	mov    $0x0,%esi
f01002ce:	eb c2                	jmp    f0100292 <kbd_proc_data+0xd5>
		else if ('A' <= c && c <= 'Z')
f01002d0:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002d3:	8d 4e 20             	lea    0x20(%esi),%ecx
f01002d6:	83 fa 1a             	cmp    $0x1a,%edx
f01002d9:	0f 42 f1             	cmovb  %ecx,%esi
f01002dc:	e9 78 ff ff ff       	jmp    f0100259 <kbd_proc_data+0x9c>
		return -1;
f01002e1:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002e6:	eb aa                	jmp    f0100292 <kbd_proc_data+0xd5>
		return -1;
f01002e8:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01002ed:	eb a3                	jmp    f0100292 <kbd_proc_data+0xd5>

f01002ef <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ef:	55                   	push   %ebp
f01002f0:	89 e5                	mov    %esp,%ebp
f01002f2:	57                   	push   %edi
f01002f3:	56                   	push   %esi
f01002f4:	53                   	push   %ebx
f01002f5:	83 ec 1c             	sub    $0x1c,%esp
f01002f8:	e8 52 fe ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01002fd:	81 c3 0f 80 01 00    	add    $0x1800f,%ebx
f0100303:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for (i = 0;
f0100306:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030b:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100310:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100315:	eb 09                	jmp    f0100320 <cons_putc+0x31>
f0100317:	89 ca                	mov    %ecx,%edx
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	ec                   	in     (%dx),%al
	     i++)
f010031d:	83 c6 01             	add    $0x1,%esi
f0100320:	89 fa                	mov    %edi,%edx
f0100322:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100323:	a8 20                	test   $0x20,%al
f0100325:	75 08                	jne    f010032f <cons_putc+0x40>
f0100327:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010032d:	7e e8                	jle    f0100317 <cons_putc+0x28>
	outb(COM1 + COM_TX, c);
f010032f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100332:	89 f8                	mov    %edi,%eax
f0100334:	88 45 e3             	mov    %al,-0x1d(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100337:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010033c:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010033d:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100342:	bf 79 03 00 00       	mov    $0x379,%edi
f0100347:	b9 84 00 00 00       	mov    $0x84,%ecx
f010034c:	eb 09                	jmp    f0100357 <cons_putc+0x68>
f010034e:	89 ca                	mov    %ecx,%edx
f0100350:	ec                   	in     (%dx),%al
f0100351:	ec                   	in     (%dx),%al
f0100352:	ec                   	in     (%dx),%al
f0100353:	ec                   	in     (%dx),%al
f0100354:	83 c6 01             	add    $0x1,%esi
f0100357:	89 fa                	mov    %edi,%edx
f0100359:	ec                   	in     (%dx),%al
f010035a:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f0100360:	7f 04                	jg     f0100366 <cons_putc+0x77>
f0100362:	84 c0                	test   %al,%al
f0100364:	79 e8                	jns    f010034e <cons_putc+0x5f>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100366:	ba 78 03 00 00       	mov    $0x378,%edx
f010036b:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
f010036f:	ee                   	out    %al,(%dx)
f0100370:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100375:	b8 0d 00 00 00       	mov    $0xd,%eax
f010037a:	ee                   	out    %al,(%dx)
f010037b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100380:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100384:	89 fa                	mov    %edi,%edx
f0100386:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0500;
f010038c:	89 f8                	mov    %edi,%eax
f010038e:	80 cc 05             	or     $0x5,%ah
f0100391:	85 d2                	test   %edx,%edx
f0100393:	0f 45 c7             	cmovne %edi,%eax
f0100396:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	switch (c & 0xff) {
f0100399:	0f b6 c0             	movzbl %al,%eax
f010039c:	83 f8 09             	cmp    $0x9,%eax
f010039f:	0f 84 b9 00 00 00    	je     f010045e <cons_putc+0x16f>
f01003a5:	83 f8 09             	cmp    $0x9,%eax
f01003a8:	7e 74                	jle    f010041e <cons_putc+0x12f>
f01003aa:	83 f8 0a             	cmp    $0xa,%eax
f01003ad:	0f 84 9e 00 00 00    	je     f0100451 <cons_putc+0x162>
f01003b3:	83 f8 0d             	cmp    $0xd,%eax
f01003b6:	0f 85 d9 00 00 00    	jne    f0100495 <cons_putc+0x1a6>
		crt_pos -= (crt_pos % CRT_COLS);
f01003bc:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f01003c3:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c9:	c1 e8 16             	shr    $0x16,%eax
f01003cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003cf:	c1 e0 04             	shl    $0x4,%eax
f01003d2:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
	if (crt_pos >= CRT_SIZE) {
f01003d9:	66 81 bb 9c 1f 00 00 	cmpw   $0x7cf,0x1f9c(%ebx)
f01003e0:	cf 07 
f01003e2:	0f 87 d4 00 00 00    	ja     f01004bc <cons_putc+0x1cd>
	outb(addr_6845, 14);
f01003e8:	8b 8b a4 1f 00 00    	mov    0x1fa4(%ebx),%ecx
f01003ee:	b8 0e 00 00 00       	mov    $0xe,%eax
f01003f3:	89 ca                	mov    %ecx,%edx
f01003f5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01003f6:	0f b7 9b 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%ebx
f01003fd:	8d 71 01             	lea    0x1(%ecx),%esi
f0100400:	89 d8                	mov    %ebx,%eax
f0100402:	66 c1 e8 08          	shr    $0x8,%ax
f0100406:	89 f2                	mov    %esi,%edx
f0100408:	ee                   	out    %al,(%dx)
f0100409:	b8 0f 00 00 00       	mov    $0xf,%eax
f010040e:	89 ca                	mov    %ecx,%edx
f0100410:	ee                   	out    %al,(%dx)
f0100411:	89 d8                	mov    %ebx,%eax
f0100413:	89 f2                	mov    %esi,%edx
f0100415:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100416:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100419:	5b                   	pop    %ebx
f010041a:	5e                   	pop    %esi
f010041b:	5f                   	pop    %edi
f010041c:	5d                   	pop    %ebp
f010041d:	c3                   	ret    
	switch (c & 0xff) {
f010041e:	83 f8 08             	cmp    $0x8,%eax
f0100421:	75 72                	jne    f0100495 <cons_putc+0x1a6>
		if (crt_pos > 0) {
f0100423:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f010042a:	66 85 c0             	test   %ax,%ax
f010042d:	74 b9                	je     f01003e8 <cons_putc+0xf9>
			crt_pos--;
f010042f:	83 e8 01             	sub    $0x1,%eax
f0100432:	66 89 83 9c 1f 00 00 	mov    %ax,0x1f9c(%ebx)
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100439:	0f b7 c0             	movzwl %ax,%eax
f010043c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
f0100440:	b2 00                	mov    $0x0,%dl
f0100442:	83 ca 20             	or     $0x20,%edx
f0100445:	8b 8b a0 1f 00 00    	mov    0x1fa0(%ebx),%ecx
f010044b:	66 89 14 41          	mov    %dx,(%ecx,%eax,2)
f010044f:	eb 88                	jmp    f01003d9 <cons_putc+0xea>
		crt_pos += CRT_COLS;
f0100451:	66 83 83 9c 1f 00 00 	addw   $0x50,0x1f9c(%ebx)
f0100458:	50 
f0100459:	e9 5e ff ff ff       	jmp    f01003bc <cons_putc+0xcd>
		cons_putc(' ');
f010045e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100463:	e8 87 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100468:	b8 20 00 00 00       	mov    $0x20,%eax
f010046d:	e8 7d fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100472:	b8 20 00 00 00       	mov    $0x20,%eax
f0100477:	e8 73 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f010047c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100481:	e8 69 fe ff ff       	call   f01002ef <cons_putc>
		cons_putc(' ');
f0100486:	b8 20 00 00 00       	mov    $0x20,%eax
f010048b:	e8 5f fe ff ff       	call   f01002ef <cons_putc>
f0100490:	e9 44 ff ff ff       	jmp    f01003d9 <cons_putc+0xea>
		crt_buf[crt_pos++] = c;		/* write the character */
f0100495:	0f b7 83 9c 1f 00 00 	movzwl 0x1f9c(%ebx),%eax
f010049c:	8d 50 01             	lea    0x1(%eax),%edx
f010049f:	66 89 93 9c 1f 00 00 	mov    %dx,0x1f9c(%ebx)
f01004a6:	0f b7 c0             	movzwl %ax,%eax
f01004a9:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f01004af:	0f b7 7d e4          	movzwl -0x1c(%ebp),%edi
f01004b3:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004b7:	e9 1d ff ff ff       	jmp    f01003d9 <cons_putc+0xea>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004bc:	8b 83 a0 1f 00 00    	mov    0x1fa0(%ebx),%eax
f01004c2:	83 ec 04             	sub    $0x4,%esp
f01004c5:	68 00 0f 00 00       	push   $0xf00
f01004ca:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004d0:	52                   	push   %edx
f01004d1:	50                   	push   %eax
f01004d2:	e8 fa 3a 00 00       	call   f0103fd1 <memmove>
			crt_buf[i] = 0x0700 | ' ';
f01004d7:	8b 93 a0 1f 00 00    	mov    0x1fa0(%ebx),%edx
f01004dd:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004e3:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004e9:	83 c4 10             	add    $0x10,%esp
f01004ec:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004f1:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004f4:	39 d0                	cmp    %edx,%eax
f01004f6:	75 f4                	jne    f01004ec <cons_putc+0x1fd>
		crt_pos -= CRT_COLS;
f01004f8:	66 83 ab 9c 1f 00 00 	subw   $0x50,0x1f9c(%ebx)
f01004ff:	50 
f0100500:	e9 e3 fe ff ff       	jmp    f01003e8 <cons_putc+0xf9>

f0100505 <serial_intr>:
{
f0100505:	e8 e7 01 00 00       	call   f01006f1 <__x86.get_pc_thunk.ax>
f010050a:	05 02 7e 01 00       	add    $0x17e02,%eax
	if (serial_exists)
f010050f:	80 b8 a8 1f 00 00 00 	cmpb   $0x0,0x1fa8(%eax)
f0100516:	75 02                	jne    f010051a <serial_intr+0x15>
f0100518:	f3 c3                	repz ret 
{
f010051a:	55                   	push   %ebp
f010051b:	89 e5                	mov    %esp,%ebp
f010051d:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f0100520:	8d 80 47 7e fe ff    	lea    -0x181b9(%eax),%eax
f0100526:	e8 47 fc ff ff       	call   f0100172 <cons_intr>
}
f010052b:	c9                   	leave  
f010052c:	c3                   	ret    

f010052d <kbd_intr>:
{
f010052d:	55                   	push   %ebp
f010052e:	89 e5                	mov    %esp,%ebp
f0100530:	83 ec 08             	sub    $0x8,%esp
f0100533:	e8 b9 01 00 00       	call   f01006f1 <__x86.get_pc_thunk.ax>
f0100538:	05 d4 7d 01 00       	add    $0x17dd4,%eax
	cons_intr(kbd_proc_data);
f010053d:	8d 80 b1 7e fe ff    	lea    -0x1814f(%eax),%eax
f0100543:	e8 2a fc ff ff       	call   f0100172 <cons_intr>
}
f0100548:	c9                   	leave  
f0100549:	c3                   	ret    

f010054a <cons_getc>:
{
f010054a:	55                   	push   %ebp
f010054b:	89 e5                	mov    %esp,%ebp
f010054d:	53                   	push   %ebx
f010054e:	83 ec 04             	sub    $0x4,%esp
f0100551:	e8 f9 fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100556:	81 c3 b6 7d 01 00    	add    $0x17db6,%ebx
	serial_intr();
f010055c:	e8 a4 ff ff ff       	call   f0100505 <serial_intr>
	kbd_intr();
f0100561:	e8 c7 ff ff ff       	call   f010052d <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100566:	8b 93 94 1f 00 00    	mov    0x1f94(%ebx),%edx
	return 0;
f010056c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100571:	3b 93 98 1f 00 00    	cmp    0x1f98(%ebx),%edx
f0100577:	74 19                	je     f0100592 <cons_getc+0x48>
		c = cons.buf[cons.rpos++];
f0100579:	8d 4a 01             	lea    0x1(%edx),%ecx
f010057c:	89 8b 94 1f 00 00    	mov    %ecx,0x1f94(%ebx)
f0100582:	0f b6 84 13 94 1d 00 	movzbl 0x1d94(%ebx,%edx,1),%eax
f0100589:	00 
		if (cons.rpos == CONSBUFSIZE)
f010058a:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100590:	74 06                	je     f0100598 <cons_getc+0x4e>
}
f0100592:	83 c4 04             	add    $0x4,%esp
f0100595:	5b                   	pop    %ebx
f0100596:	5d                   	pop    %ebp
f0100597:	c3                   	ret    
			cons.rpos = 0;
f0100598:	c7 83 94 1f 00 00 00 	movl   $0x0,0x1f94(%ebx)
f010059f:	00 00 00 
f01005a2:	eb ee                	jmp    f0100592 <cons_getc+0x48>

f01005a4 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f01005a4:	55                   	push   %ebp
f01005a5:	89 e5                	mov    %esp,%ebp
f01005a7:	57                   	push   %edi
f01005a8:	56                   	push   %esi
f01005a9:	53                   	push   %ebx
f01005aa:	83 ec 1c             	sub    $0x1c,%esp
f01005ad:	e8 9d fb ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01005b2:	81 c3 5a 7d 01 00    	add    $0x17d5a,%ebx
	was = *cp;
f01005b8:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005bf:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005c6:	5a a5 
	if (*cp != 0xA55A) {
f01005c8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005cf:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005d3:	0f 84 bc 00 00 00    	je     f0100695 <cons_init+0xf1>
		addr_6845 = MONO_BASE;
f01005d9:	c7 83 a4 1f 00 00 b4 	movl   $0x3b4,0x1fa4(%ebx)
f01005e0:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005e3:	c7 45 e4 00 00 0b f0 	movl   $0xf00b0000,-0x1c(%ebp)
	outb(addr_6845, 14);
f01005ea:	8b bb a4 1f 00 00    	mov    0x1fa4(%ebx),%edi
f01005f0:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005f5:	89 fa                	mov    %edi,%edx
f01005f7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005f8:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fb:	89 ca                	mov    %ecx,%edx
f01005fd:	ec                   	in     (%dx),%al
f01005fe:	0f b6 f0             	movzbl %al,%esi
f0100601:	c1 e6 08             	shl    $0x8,%esi
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100604:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100609:	89 fa                	mov    %edi,%edx
f010060b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010060c:	89 ca                	mov    %ecx,%edx
f010060e:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f010060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100612:	89 bb a0 1f 00 00    	mov    %edi,0x1fa0(%ebx)
	pos |= inb(addr_6845 + 1);
f0100618:	0f b6 c0             	movzbl %al,%eax
f010061b:	09 c6                	or     %eax,%esi
	crt_pos = pos;
f010061d:	66 89 b3 9c 1f 00 00 	mov    %si,0x1f9c(%ebx)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100624:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100629:	89 c8                	mov    %ecx,%eax
f010062b:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100630:	ee                   	out    %al,(%dx)
f0100631:	bf fb 03 00 00       	mov    $0x3fb,%edi
f0100636:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010063b:	89 fa                	mov    %edi,%edx
f010063d:	ee                   	out    %al,(%dx)
f010063e:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100643:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100648:	ee                   	out    %al,(%dx)
f0100649:	be f9 03 00 00       	mov    $0x3f9,%esi
f010064e:	89 c8                	mov    %ecx,%eax
f0100650:	89 f2                	mov    %esi,%edx
f0100652:	ee                   	out    %al,(%dx)
f0100653:	b8 03 00 00 00       	mov    $0x3,%eax
f0100658:	89 fa                	mov    %edi,%edx
f010065a:	ee                   	out    %al,(%dx)
f010065b:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100660:	89 c8                	mov    %ecx,%eax
f0100662:	ee                   	out    %al,(%dx)
f0100663:	b8 01 00 00 00       	mov    $0x1,%eax
f0100668:	89 f2                	mov    %esi,%edx
f010066a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010066b:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100670:	ec                   	in     (%dx),%al
f0100671:	89 c1                	mov    %eax,%ecx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100673:	3c ff                	cmp    $0xff,%al
f0100675:	0f 95 83 a8 1f 00 00 	setne  0x1fa8(%ebx)
f010067c:	ba fa 03 00 00       	mov    $0x3fa,%edx
f0100681:	ec                   	in     (%dx),%al
f0100682:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100687:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100688:	80 f9 ff             	cmp    $0xff,%cl
f010068b:	74 25                	je     f01006b2 <cons_init+0x10e>
		cprintf("Serial port does not exist!\n");
}
f010068d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100690:	5b                   	pop    %ebx
f0100691:	5e                   	pop    %esi
f0100692:	5f                   	pop    %edi
f0100693:	5d                   	pop    %ebp
f0100694:	c3                   	ret    
		*cp = was;
f0100695:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069c:	c7 83 a4 1f 00 00 d4 	movl   $0x3d4,0x1fa4(%ebx)
f01006a3:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a6:	c7 45 e4 00 80 0b f0 	movl   $0xf00b8000,-0x1c(%ebp)
f01006ad:	e9 38 ff ff ff       	jmp    f01005ea <cons_init+0x46>
		cprintf("Serial port does not exist!\n");
f01006b2:	83 ec 0c             	sub    $0xc,%esp
f01006b5:	8d 83 0d c1 fe ff    	lea    -0x13ef3(%ebx),%eax
f01006bb:	50                   	push   %eax
f01006bc:	e8 b2 2c 00 00       	call   f0103373 <cprintf>
f01006c1:	83 c4 10             	add    $0x10,%esp
}
f01006c4:	eb c7                	jmp    f010068d <cons_init+0xe9>

f01006c6 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01006c6:	55                   	push   %ebp
f01006c7:	89 e5                	mov    %esp,%ebp
f01006c9:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01006cf:	e8 1b fc ff ff       	call   f01002ef <cons_putc>
}
f01006d4:	c9                   	leave  
f01006d5:	c3                   	ret    

f01006d6 <getchar>:

int
getchar(void)
{
f01006d6:	55                   	push   %ebp
f01006d7:	89 e5                	mov    %esp,%ebp
f01006d9:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006dc:	e8 69 fe ff ff       	call   f010054a <cons_getc>
f01006e1:	85 c0                	test   %eax,%eax
f01006e3:	74 f7                	je     f01006dc <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006e5:	c9                   	leave  
f01006e6:	c3                   	ret    

f01006e7 <iscons>:

int
iscons(int fdnum)
{
f01006e7:	55                   	push   %ebp
f01006e8:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006ea:	b8 01 00 00 00       	mov    $0x1,%eax
f01006ef:	5d                   	pop    %ebp
f01006f0:	c3                   	ret    

f01006f1 <__x86.get_pc_thunk.ax>:
f01006f1:	8b 04 24             	mov    (%esp),%eax
f01006f4:	c3                   	ret    

f01006f5 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006f5:	55                   	push   %ebp
f01006f6:	89 e5                	mov    %esp,%ebp
f01006f8:	57                   	push   %edi
f01006f9:	56                   	push   %esi
f01006fa:	53                   	push   %ebx
f01006fb:	83 ec 0c             	sub    $0xc,%esp
f01006fe:	e8 4c fa ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100703:	81 c3 09 7c 01 00    	add    $0x17c09,%ebx
f0100709:	be 00 00 00 00       	mov    $0x0,%esi
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010070e:	8d bb 34 c3 fe ff    	lea    -0x13ccc(%ebx),%edi
f0100714:	83 ec 04             	sub    $0x4,%esp
f0100717:	ff b4 1e 18 1d 00 00 	pushl  0x1d18(%esi,%ebx,1)
f010071e:	ff b4 1e 14 1d 00 00 	pushl  0x1d14(%esi,%ebx,1)
f0100725:	57                   	push   %edi
f0100726:	e8 48 2c 00 00       	call   f0103373 <cprintf>
f010072b:	83 c6 0c             	add    $0xc,%esi
	for (i = 0; i < ARRAY_SIZE(commands); i++)
f010072e:	83 c4 10             	add    $0x10,%esp
f0100731:	83 fe 3c             	cmp    $0x3c,%esi
f0100734:	75 de                	jne    f0100714 <mon_help+0x1f>
	return 0;
}
f0100736:	b8 00 00 00 00       	mov    $0x0,%eax
f010073b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010073e:	5b                   	pop    %ebx
f010073f:	5e                   	pop    %esi
f0100740:	5f                   	pop    %edi
f0100741:	5d                   	pop    %ebp
f0100742:	c3                   	ret    

f0100743 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100743:	55                   	push   %ebp
f0100744:	89 e5                	mov    %esp,%ebp
f0100746:	57                   	push   %edi
f0100747:	56                   	push   %esi
f0100748:	53                   	push   %ebx
f0100749:	83 ec 18             	sub    $0x18,%esp
f010074c:	e8 fe f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100751:	81 c3 bb 7b 01 00    	add    $0x17bbb,%ebx
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100757:	8d 83 3d c3 fe ff    	lea    -0x13cc3(%ebx),%eax
f010075d:	50                   	push   %eax
f010075e:	e8 10 2c 00 00       	call   f0103373 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100763:	83 c4 08             	add    $0x8,%esp
f0100766:	ff b3 f4 ff ff ff    	pushl  -0xc(%ebx)
f010076c:	8d 83 a8 c4 fe ff    	lea    -0x13b58(%ebx),%eax
f0100772:	50                   	push   %eax
f0100773:	e8 fb 2b 00 00       	call   f0103373 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100778:	83 c4 0c             	add    $0xc,%esp
f010077b:	c7 c7 0c 00 10 f0    	mov    $0xf010000c,%edi
f0100781:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0100787:	50                   	push   %eax
f0100788:	57                   	push   %edi
f0100789:	8d 83 d0 c4 fe ff    	lea    -0x13b30(%ebx),%eax
f010078f:	50                   	push   %eax
f0100790:	e8 de 2b 00 00       	call   f0103373 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100795:	83 c4 0c             	add    $0xc,%esp
f0100798:	c7 c0 b9 43 10 f0    	mov    $0xf01043b9,%eax
f010079e:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007a4:	52                   	push   %edx
f01007a5:	50                   	push   %eax
f01007a6:	8d 83 f4 c4 fe ff    	lea    -0x13b0c(%ebx),%eax
f01007ac:	50                   	push   %eax
f01007ad:	e8 c1 2b 00 00       	call   f0103373 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007b2:	83 c4 0c             	add    $0xc,%esp
f01007b5:	c7 c0 80 a0 11 f0    	mov    $0xf011a080,%eax
f01007bb:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01007c1:	52                   	push   %edx
f01007c2:	50                   	push   %eax
f01007c3:	8d 83 18 c5 fe ff    	lea    -0x13ae8(%ebx),%eax
f01007c9:	50                   	push   %eax
f01007ca:	e8 a4 2b 00 00       	call   f0103373 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007cf:	83 c4 0c             	add    $0xc,%esp
f01007d2:	c7 c6 c0 a6 11 f0    	mov    $0xf011a6c0,%esi
f01007d8:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f01007de:	50                   	push   %eax
f01007df:	56                   	push   %esi
f01007e0:	8d 83 3c c5 fe ff    	lea    -0x13ac4(%ebx),%eax
f01007e6:	50                   	push   %eax
f01007e7:	e8 87 2b 00 00       	call   f0103373 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007ec:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f01007ef:	81 c6 ff 03 00 00    	add    $0x3ff,%esi
f01007f5:	29 fe                	sub    %edi,%esi
	cprintf("Kernel executable memory footprint: %dKB\n",
f01007f7:	c1 fe 0a             	sar    $0xa,%esi
f01007fa:	56                   	push   %esi
f01007fb:	8d 83 60 c5 fe ff    	lea    -0x13aa0(%ebx),%eax
f0100801:	50                   	push   %eax
f0100802:	e8 6c 2b 00 00       	call   f0103373 <cprintf>
	return 0;
}
f0100807:	b8 00 00 00 00       	mov    $0x0,%eax
f010080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010080f:	5b                   	pop    %ebx
f0100810:	5e                   	pop    %esi
f0100811:	5f                   	pop    %edi
f0100812:	5d                   	pop    %ebp
f0100813:	c3                   	ret    

f0100814 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100814:	55                   	push   %ebp
f0100815:	89 e5                	mov    %esp,%ebp
f0100817:	57                   	push   %edi
f0100818:	56                   	push   %esi
f0100819:	53                   	push   %ebx
f010081a:	83 ec 58             	sub    $0x58,%esp
f010081d:	e8 2d f9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100822:	81 c3 ea 7a 01 00    	add    $0x17aea,%ebx
	// Your code here.
	cprintf("Stack backtrace:\n");
f0100828:	8d 83 56 c3 fe ff    	lea    -0x13caa(%ebx),%eax
f010082e:	50                   	push   %eax
f010082f:	e8 3f 2b 00 00       	call   f0103373 <cprintf>

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100834:	89 e8                	mov    %ebp,%eax
f0100836:	89 c7                	mov    %eax,%edi
	unsigned int ebp, esp, eip;
	ebp=read_ebp();
	while(ebp){
f0100838:	83 c4 10             	add    $0x10,%esp
		eip=*((unsigned int*)(ebp+4));
		esp=ebp+4;
		struct Eipdebuginfo info;
		debuginfo_eip(eip,&info);
f010083b:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010083e:	89 45 b8             	mov    %eax,-0x48(%ebp)
		cprintf("   ebp %08x  eip %08x args",ebp,eip);
f0100841:	8d 83 68 c3 fe ff    	lea    -0x13c98(%ebx),%eax
f0100847:	89 45 b4             	mov    %eax,-0x4c(%ebp)
	while(ebp){
f010084a:	e9 87 00 00 00       	jmp    f01008d6 <mon_backtrace+0xc2>
		eip=*((unsigned int*)(ebp+4));
f010084f:	8d 77 04             	lea    0x4(%edi),%esi
f0100852:	8b 47 04             	mov    0x4(%edi),%eax
		debuginfo_eip(eip,&info);
f0100855:	83 ec 08             	sub    $0x8,%esp
f0100858:	ff 75 b8             	pushl  -0x48(%ebp)
f010085b:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010085e:	50                   	push   %eax
f010085f:	e8 13 2c 00 00       	call   f0103477 <debuginfo_eip>
		cprintf("   ebp %08x  eip %08x args",ebp,eip);
f0100864:	83 c4 0c             	add    $0xc,%esp
f0100867:	ff 75 c0             	pushl  -0x40(%ebp)
f010086a:	57                   	push   %edi
f010086b:	ff 75 b4             	pushl  -0x4c(%ebp)
f010086e:	e8 00 2b 00 00       	call   f0103373 <cprintf>
f0100873:	8d 47 18             	lea    0x18(%edi),%eax
f0100876:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100879:	83 c4 10             	add    $0x10,%esp

		for(int i=0;i<5;i++){
			esp+=4;
			cprintf(" %08x", *(unsigned int*)esp);
f010087c:	8d 83 83 c3 fe ff    	lea    -0x13c7d(%ebx),%eax
f0100882:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0100885:	89 c7                	mov    %eax,%edi
			esp+=4;
f0100887:	83 c6 04             	add    $0x4,%esi
			cprintf(" %08x", *(unsigned int*)esp);
f010088a:	83 ec 08             	sub    $0x8,%esp
f010088d:	ff 36                	pushl  (%esi)
f010088f:	57                   	push   %edi
f0100890:	e8 de 2a 00 00       	call   f0103373 <cprintf>
		for(int i=0;i<5;i++){
f0100895:	83 c4 10             	add    $0x10,%esp
f0100898:	39 75 c4             	cmp    %esi,-0x3c(%ebp)
f010089b:	75 ea                	jne    f0100887 <mon_backtrace+0x73>
f010089d:	8b 7d bc             	mov    -0x44(%ebp),%edi
		}
		cprintf("\t%s:%d: %.*s+%d",info.eip_file, info.eip_line,  info.eip_fn_namelen, info.eip_fn_name, eip-info.eip_fn_addr);
f01008a0:	83 ec 08             	sub    $0x8,%esp
f01008a3:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01008a6:	2b 45 e0             	sub    -0x20(%ebp),%eax
f01008a9:	50                   	push   %eax
f01008aa:	ff 75 d8             	pushl  -0x28(%ebp)
f01008ad:	ff 75 dc             	pushl  -0x24(%ebp)
f01008b0:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008b3:	ff 75 d0             	pushl  -0x30(%ebp)
f01008b6:	8d 83 89 c3 fe ff    	lea    -0x13c77(%ebx),%eax
f01008bc:	50                   	push   %eax
f01008bd:	e8 b1 2a 00 00       	call   f0103373 <cprintf>
		cprintf("\n");
f01008c2:	83 c4 14             	add    $0x14,%esp
f01008c5:	8d 83 f2 d0 fe ff    	lea    -0x12f0e(%ebx),%eax
f01008cb:	50                   	push   %eax
f01008cc:	e8 a2 2a 00 00       	call   f0103373 <cprintf>
		ebp=*((unsigned int*)ebp);
f01008d1:	8b 3f                	mov    (%edi),%edi
f01008d3:	83 c4 10             	add    $0x10,%esp
	while(ebp){
f01008d6:	85 ff                	test   %edi,%edi
f01008d8:	0f 85 71 ff ff ff    	jne    f010084f <mon_backtrace+0x3b>
	}
	return 0;
}
f01008de:	b8 00 00 00 00       	mov    $0x0,%eax
f01008e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01008e6:	5b                   	pop    %ebx
f01008e7:	5e                   	pop    %esi
f01008e8:	5f                   	pop    %edi
f01008e9:	5d                   	pop    %ebp
f01008ea:	c3                   	ret    

f01008eb <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008eb:	55                   	push   %ebp
f01008ec:	89 e5                	mov    %esp,%ebp
f01008ee:	57                   	push   %edi
f01008ef:	56                   	push   %esi
f01008f0:	53                   	push   %ebx
f01008f1:	83 ec 68             	sub    $0x68,%esp
f01008f4:	e8 56 f8 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01008f9:	81 c3 13 7a 01 00    	add    $0x17a13,%ebx
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008ff:	8d 83 8c c5 fe ff    	lea    -0x13a74(%ebx),%eax
f0100905:	50                   	push   %eax
f0100906:	e8 68 2a 00 00       	call   f0103373 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010090b:	8d 83 b0 c5 fe ff    	lea    -0x13a50(%ebx),%eax
f0100911:	89 04 24             	mov    %eax,(%esp)
f0100914:	e8 5a 2a 00 00       	call   f0103373 <cprintf>
f0100919:	83 c4 10             	add    $0x10,%esp
		while (*buf && strchr(WHITESPACE, *buf))
f010091c:	8d bb 9d c3 fe ff    	lea    -0x13c63(%ebx),%edi
f0100922:	eb 4a                	jmp    f010096e <monitor+0x83>
f0100924:	83 ec 08             	sub    $0x8,%esp
f0100927:	0f be c0             	movsbl %al,%eax
f010092a:	50                   	push   %eax
f010092b:	57                   	push   %edi
f010092c:	e8 16 36 00 00       	call   f0103f47 <strchr>
f0100931:	83 c4 10             	add    $0x10,%esp
f0100934:	85 c0                	test   %eax,%eax
f0100936:	74 08                	je     f0100940 <monitor+0x55>
			*buf++ = 0;
f0100938:	c6 06 00             	movb   $0x0,(%esi)
f010093b:	8d 76 01             	lea    0x1(%esi),%esi
f010093e:	eb 79                	jmp    f01009b9 <monitor+0xce>
		if (*buf == 0)
f0100940:	80 3e 00             	cmpb   $0x0,(%esi)
f0100943:	74 7f                	je     f01009c4 <monitor+0xd9>
		if (argc == MAXARGS-1) {
f0100945:	83 7d a4 0f          	cmpl   $0xf,-0x5c(%ebp)
f0100949:	74 0f                	je     f010095a <monitor+0x6f>
		argv[argc++] = buf;
f010094b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f010094e:	8d 48 01             	lea    0x1(%eax),%ecx
f0100951:	89 4d a4             	mov    %ecx,-0x5c(%ebp)
f0100954:	89 74 85 a8          	mov    %esi,-0x58(%ebp,%eax,4)
f0100958:	eb 44                	jmp    f010099e <monitor+0xb3>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010095a:	83 ec 08             	sub    $0x8,%esp
f010095d:	6a 10                	push   $0x10
f010095f:	8d 83 a2 c3 fe ff    	lea    -0x13c5e(%ebx),%eax
f0100965:	50                   	push   %eax
f0100966:	e8 08 2a 00 00       	call   f0103373 <cprintf>
f010096b:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010096e:	8d 83 99 c3 fe ff    	lea    -0x13c67(%ebx),%eax
f0100974:	89 45 a4             	mov    %eax,-0x5c(%ebp)
f0100977:	83 ec 0c             	sub    $0xc,%esp
f010097a:	ff 75 a4             	pushl  -0x5c(%ebp)
f010097d:	e8 8d 33 00 00       	call   f0103d0f <readline>
f0100982:	89 c6                	mov    %eax,%esi
		if (buf != NULL)
f0100984:	83 c4 10             	add    $0x10,%esp
f0100987:	85 c0                	test   %eax,%eax
f0100989:	74 ec                	je     f0100977 <monitor+0x8c>
	argv[argc] = 0;
f010098b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100992:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
f0100999:	eb 1e                	jmp    f01009b9 <monitor+0xce>
			buf++;
f010099b:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f010099e:	0f b6 06             	movzbl (%esi),%eax
f01009a1:	84 c0                	test   %al,%al
f01009a3:	74 14                	je     f01009b9 <monitor+0xce>
f01009a5:	83 ec 08             	sub    $0x8,%esp
f01009a8:	0f be c0             	movsbl %al,%eax
f01009ab:	50                   	push   %eax
f01009ac:	57                   	push   %edi
f01009ad:	e8 95 35 00 00       	call   f0103f47 <strchr>
f01009b2:	83 c4 10             	add    $0x10,%esp
f01009b5:	85 c0                	test   %eax,%eax
f01009b7:	74 e2                	je     f010099b <monitor+0xb0>
		while (*buf && strchr(WHITESPACE, *buf))
f01009b9:	0f b6 06             	movzbl (%esi),%eax
f01009bc:	84 c0                	test   %al,%al
f01009be:	0f 85 60 ff ff ff    	jne    f0100924 <monitor+0x39>
	argv[argc] = 0;
f01009c4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
f01009c7:	c7 44 85 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%eax,4)
f01009ce:	00 
	if (argc == 0)
f01009cf:	85 c0                	test   %eax,%eax
f01009d1:	74 9b                	je     f010096e <monitor+0x83>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009d3:	be 00 00 00 00       	mov    $0x0,%esi
		if (strcmp(argv[0], commands[i].name) == 0)
f01009d8:	83 ec 08             	sub    $0x8,%esp
f01009db:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009de:	ff b4 83 14 1d 00 00 	pushl  0x1d14(%ebx,%eax,4)
f01009e5:	ff 75 a8             	pushl  -0x58(%ebp)
f01009e8:	e8 fc 34 00 00       	call   f0103ee9 <strcmp>
f01009ed:	83 c4 10             	add    $0x10,%esp
f01009f0:	85 c0                	test   %eax,%eax
f01009f2:	74 22                	je     f0100a16 <monitor+0x12b>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009f4:	83 c6 01             	add    $0x1,%esi
f01009f7:	83 fe 05             	cmp    $0x5,%esi
f01009fa:	75 dc                	jne    f01009d8 <monitor+0xed>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009fc:	83 ec 08             	sub    $0x8,%esp
f01009ff:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a02:	8d 83 bf c3 fe ff    	lea    -0x13c41(%ebx),%eax
f0100a08:	50                   	push   %eax
f0100a09:	e8 65 29 00 00       	call   f0103373 <cprintf>
f0100a0e:	83 c4 10             	add    $0x10,%esp
f0100a11:	e9 58 ff ff ff       	jmp    f010096e <monitor+0x83>
			return commands[i].func(argc, argv, tf);
f0100a16:	83 ec 04             	sub    $0x4,%esp
f0100a19:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a1c:	ff 75 08             	pushl  0x8(%ebp)
f0100a1f:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a22:	52                   	push   %edx
f0100a23:	ff 75 a4             	pushl  -0x5c(%ebp)
f0100a26:	ff 94 83 1c 1d 00 00 	call   *0x1d1c(%ebx,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a2d:	83 c4 10             	add    $0x10,%esp
f0100a30:	85 c0                	test   %eax,%eax
f0100a32:	0f 89 36 ff ff ff    	jns    f010096e <monitor+0x83>
				break;
	}
}
f0100a38:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a3b:	5b                   	pop    %ebx
f0100a3c:	5e                   	pop    %esi
f0100a3d:	5f                   	pop    %edi
f0100a3e:	5d                   	pop    %ebp
f0100a3f:	c3                   	ret    

f0100a40 <xtoi>:

uint32_t xtoi(char* buf) {
f0100a40:	55                   	push   %ebp
f0100a41:	89 e5                	mov    %esp,%ebp
	uint32_t res = 0;
	buf += 2; //0x...
f0100a43:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a46:	8d 50 02             	lea    0x2(%eax),%edx
	uint32_t res = 0;
f0100a49:	b8 00 00 00 00       	mov    $0x0,%eax
	while (*buf) { 
f0100a4e:	eb 0d                	jmp    f0100a5d <xtoi+0x1d>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
		res = res*16 + *buf - '0';
f0100a50:	c1 e0 04             	shl    $0x4,%eax
f0100a53:	0f be 0a             	movsbl (%edx),%ecx
f0100a56:	8d 44 08 d0          	lea    -0x30(%eax,%ecx,1),%eax
		++buf;
f0100a5a:	83 c2 01             	add    $0x1,%edx
	while (*buf) { 
f0100a5d:	0f b6 0a             	movzbl (%edx),%ecx
f0100a60:	84 c9                	test   %cl,%cl
f0100a62:	74 0c                	je     f0100a70 <xtoi+0x30>
		if (*buf >= 'a') *buf = *buf-'a'+'0'+10;//aha
f0100a64:	80 f9 60             	cmp    $0x60,%cl
f0100a67:	7e e7                	jle    f0100a50 <xtoi+0x10>
f0100a69:	83 e9 27             	sub    $0x27,%ecx
f0100a6c:	88 0a                	mov    %cl,(%edx)
f0100a6e:	eb e0                	jmp    f0100a50 <xtoi+0x10>
	}
	return res;
}
f0100a70:	5d                   	pop    %ebp
f0100a71:	c3                   	ret    

f0100a72 <showvm>:
	pprint(pte);
	return 0;
}

int
showvm(int argc, char **argv, struct Trapframe *tf) {
f0100a72:	55                   	push   %ebp
f0100a73:	89 e5                	mov    %esp,%ebp
f0100a75:	57                   	push   %edi
f0100a76:	56                   	push   %esi
f0100a77:	53                   	push   %ebx
f0100a78:	83 ec 1c             	sub    $0x1c,%esp
f0100a7b:	e8 cf f6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100a80:	81 c3 8c 78 01 00    	add    $0x1788c,%ebx
f0100a86:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if (argc == 1) {
f0100a89:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100a8d:	74 29                	je     f0100ab8 <showvm+0x46>
		cprintf("Usage: showvm 0xaddr 0xn\n");
		return 0;
	}
	void** addr = (void**) xtoi(argv[1]);
f0100a8f:	83 ec 0c             	sub    $0xc,%esp
f0100a92:	ff 77 04             	pushl  0x4(%edi)
f0100a95:	e8 a6 ff ff ff       	call   f0100a40 <xtoi>
f0100a9a:	89 c6                	mov    %eax,%esi
	uint32_t n = xtoi(argv[2]);
f0100a9c:	83 c4 04             	add    $0x4,%esp
f0100a9f:	ff 77 08             	pushl  0x8(%edi)
f0100aa2:	e8 99 ff ff ff       	call   f0100a40 <xtoi>
f0100aa7:	8d 04 86             	lea    (%esi,%eax,4),%eax
f0100aaa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	int i;
	for (i = 0; i < n; ++i)
f0100aad:	83 c4 10             	add    $0x10,%esp
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100ab0:	8d bb ef c3 fe ff    	lea    -0x13c11(%ebx),%edi
	for (i = 0; i < n; ++i)
f0100ab6:	eb 26                	jmp    f0100ade <showvm+0x6c>
		cprintf("Usage: showvm 0xaddr 0xn\n");
f0100ab8:	83 ec 0c             	sub    $0xc,%esp
f0100abb:	8d 83 d5 c3 fe ff    	lea    -0x13c2b(%ebx),%eax
f0100ac1:	50                   	push   %eax
f0100ac2:	e8 ac 28 00 00       	call   f0103373 <cprintf>
		return 0;
f0100ac7:	83 c4 10             	add    $0x10,%esp
f0100aca:	eb 17                	jmp    f0100ae3 <showvm+0x71>
		cprintf("VM at %x is %x\n", addr+i, addr[i]);
f0100acc:	83 ec 04             	sub    $0x4,%esp
f0100acf:	ff 36                	pushl  (%esi)
f0100ad1:	56                   	push   %esi
f0100ad2:	57                   	push   %edi
f0100ad3:	e8 9b 28 00 00       	call   f0103373 <cprintf>
f0100ad8:	83 c6 04             	add    $0x4,%esi
f0100adb:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; ++i)
f0100ade:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100ae1:	75 e9                	jne    f0100acc <showvm+0x5a>
	return 0;
}
f0100ae3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100aeb:	5b                   	pop    %ebx
f0100aec:	5e                   	pop    %esi
f0100aed:	5f                   	pop    %edi
f0100aee:	5d                   	pop    %ebp
f0100aef:	c3                   	ret    

f0100af0 <pprint>:
void pprint(pte_t *pte) {
f0100af0:	55                   	push   %ebp
f0100af1:	89 e5                	mov    %esp,%ebp
f0100af3:	53                   	push   %ebx
f0100af4:	83 ec 04             	sub    $0x4,%esp
f0100af7:	e8 53 f6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100afc:	81 c3 10 78 01 00    	add    $0x17810,%ebx
		*pte&PTE_P, *pte&PTE_W, *pte&PTE_U);
f0100b02:	8b 45 08             	mov    0x8(%ebp),%eax
f0100b05:	8b 00                	mov    (%eax),%eax
	cprintf("PTE_P: %x, PTE_W: %x, PTE_U: %x\n", 
f0100b07:	89 c2                	mov    %eax,%edx
f0100b09:	83 e2 04             	and    $0x4,%edx
f0100b0c:	52                   	push   %edx
f0100b0d:	89 c2                	mov    %eax,%edx
f0100b0f:	83 e2 02             	and    $0x2,%edx
f0100b12:	52                   	push   %edx
f0100b13:	83 e0 01             	and    $0x1,%eax
f0100b16:	50                   	push   %eax
f0100b17:	8d 83 d8 c5 fe ff    	lea    -0x13a28(%ebx),%eax
f0100b1d:	50                   	push   %eax
f0100b1e:	e8 50 28 00 00       	call   f0103373 <cprintf>
}
f0100b23:	83 c4 10             	add    $0x10,%esp
f0100b26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100b29:	c9                   	leave  
f0100b2a:	c3                   	ret    

f0100b2b <showmappings>:
{
f0100b2b:	55                   	push   %ebp
f0100b2c:	89 e5                	mov    %esp,%ebp
f0100b2e:	57                   	push   %edi
f0100b2f:	56                   	push   %esi
f0100b30:	53                   	push   %ebx
f0100b31:	83 ec 1c             	sub    $0x1c,%esp
f0100b34:	e8 16 f6 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100b39:	81 c3 d3 77 01 00    	add    $0x177d3,%ebx
f0100b3f:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (argc == 1) {
f0100b42:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100b46:	74 43                	je     f0100b8b <showmappings+0x60>
	uint32_t begin = xtoi(argv[1]), end = xtoi(argv[2]);
f0100b48:	83 ec 0c             	sub    $0xc,%esp
f0100b4b:	ff 76 04             	pushl  0x4(%esi)
f0100b4e:	e8 ed fe ff ff       	call   f0100a40 <xtoi>
f0100b53:	89 c7                	mov    %eax,%edi
f0100b55:	83 c4 04             	add    $0x4,%esp
f0100b58:	ff 76 08             	pushl  0x8(%esi)
f0100b5b:	e8 e0 fe ff ff       	call   f0100a40 <xtoi>
f0100b60:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	cprintf("begin: %x, end: %x\n", begin, end);
f0100b63:	83 c4 0c             	add    $0xc,%esp
f0100b66:	50                   	push   %eax
f0100b67:	57                   	push   %edi
f0100b68:	8d 83 ff c3 fe ff    	lea    -0x13c01(%ebx),%eax
f0100b6e:	50                   	push   %eax
f0100b6f:	e8 ff 27 00 00       	call   f0103373 <cprintf>
	for (; begin <= end; begin += PGSIZE) {
f0100b74:	83 c4 10             	add    $0x10,%esp
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100b77:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0100b7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		} else cprintf("page not exist: %x\n", begin);
f0100b80:	8d 83 30 c4 fe ff    	lea    -0x13bd0(%ebx),%eax
f0100b86:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (; begin <= end; begin += PGSIZE) {
f0100b89:	eb 4f                	jmp    f0100bda <showmappings+0xaf>
		cprintf("Usage: showmappings 0xbegin_addr 0xend_addr\n");
f0100b8b:	83 ec 0c             	sub    $0xc,%esp
f0100b8e:	8d 83 fc c5 fe ff    	lea    -0x13a04(%ebx),%eax
f0100b94:	50                   	push   %eax
f0100b95:	e8 d9 27 00 00       	call   f0103373 <cprintf>
		return 0;
f0100b9a:	83 c4 10             	add    $0x10,%esp
}
f0100b9d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100ba5:	5b                   	pop    %ebx
f0100ba6:	5e                   	pop    %esi
f0100ba7:	5f                   	pop    %edi
f0100ba8:	5d                   	pop    %ebp
f0100ba9:	c3                   	ret    
		if (!pte) panic("boot_map_region panic, out of memory");
f0100baa:	83 ec 04             	sub    $0x4,%esp
f0100bad:	8d 83 2c c6 fe ff    	lea    -0x139d4(%ebx),%eax
f0100bb3:	50                   	push   %eax
f0100bb4:	68 ae 00 00 00       	push   $0xae
f0100bb9:	8d 83 13 c4 fe ff    	lea    -0x13bed(%ebx),%eax
f0100bbf:	50                   	push   %eax
f0100bc0:	e8 d4 f4 ff ff       	call   f0100099 <_panic>
		} else cprintf("page not exist: %x\n", begin);
f0100bc5:	83 ec 08             	sub    $0x8,%esp
f0100bc8:	57                   	push   %edi
f0100bc9:	ff 75 dc             	pushl  -0x24(%ebp)
f0100bcc:	e8 a2 27 00 00       	call   f0103373 <cprintf>
f0100bd1:	83 c4 10             	add    $0x10,%esp
	for (; begin <= end; begin += PGSIZE) {
f0100bd4:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0100bda:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0100bdd:	77 be                	ja     f0100b9d <showmappings+0x72>
		pte_t *pte = pgdir_walk(kern_pgdir, (void *) begin, 1);	//create
f0100bdf:	83 ec 04             	sub    $0x4,%esp
f0100be2:	6a 01                	push   $0x1
f0100be4:	57                   	push   %edi
f0100be5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100be8:	ff 30                	pushl  (%eax)
f0100bea:	e8 7a 07 00 00       	call   f0101369 <pgdir_walk>
f0100bef:	89 c6                	mov    %eax,%esi
		if (!pte) panic("boot_map_region panic, out of memory");
f0100bf1:	83 c4 10             	add    $0x10,%esp
f0100bf4:	85 c0                	test   %eax,%eax
f0100bf6:	74 b2                	je     f0100baa <showmappings+0x7f>
		if (*pte & PTE_P) {
f0100bf8:	f6 00 01             	testb  $0x1,(%eax)
f0100bfb:	74 c8                	je     f0100bc5 <showmappings+0x9a>
			cprintf("page %x with ", begin);
f0100bfd:	83 ec 08             	sub    $0x8,%esp
f0100c00:	57                   	push   %edi
f0100c01:	8d 83 22 c4 fe ff    	lea    -0x13bde(%ebx),%eax
f0100c07:	50                   	push   %eax
f0100c08:	e8 66 27 00 00       	call   f0103373 <cprintf>
			pprint(pte);
f0100c0d:	89 34 24             	mov    %esi,(%esp)
f0100c10:	e8 db fe ff ff       	call   f0100af0 <pprint>
f0100c15:	83 c4 10             	add    $0x10,%esp
f0100c18:	eb ba                	jmp    f0100bd4 <showmappings+0xa9>

f0100c1a <setm>:
setm(int argc, char **argv, struct Trapframe *tf) {
f0100c1a:	55                   	push   %ebp
f0100c1b:	89 e5                	mov    %esp,%ebp
f0100c1d:	57                   	push   %edi
f0100c1e:	56                   	push   %esi
f0100c1f:	53                   	push   %ebx
f0100c20:	83 ec 0c             	sub    $0xc,%esp
f0100c23:	e8 27 f5 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100c28:	81 c3 e4 76 01 00    	add    $0x176e4,%ebx
	if (argc == 1) {
f0100c2e:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
f0100c32:	0f 84 92 00 00 00    	je     f0100cca <setm+0xb0>
	uint32_t addr = xtoi(argv[1]);
f0100c38:	83 ec 0c             	sub    $0xc,%esp
f0100c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c3e:	ff 70 04             	pushl  0x4(%eax)
f0100c41:	e8 fa fd ff ff       	call   f0100a40 <xtoi>
f0100c46:	89 c7                	mov    %eax,%edi
	pte_t *pte = pgdir_walk(kern_pgdir, (void *)addr, 1);
f0100c48:	83 c4 0c             	add    $0xc,%esp
f0100c4b:	6a 01                	push   $0x1
f0100c4d:	50                   	push   %eax
f0100c4e:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0100c54:	ff 30                	pushl  (%eax)
f0100c56:	e8 0e 07 00 00       	call   f0101369 <pgdir_walk>
f0100c5b:	89 c6                	mov    %eax,%esi
	cprintf("%x before setm: ", addr);
f0100c5d:	83 c4 08             	add    $0x8,%esp
f0100c60:	57                   	push   %edi
f0100c61:	8d 83 44 c4 fe ff    	lea    -0x13bbc(%ebx),%eax
f0100c67:	50                   	push   %eax
f0100c68:	e8 06 27 00 00       	call   f0103373 <cprintf>
	pprint(pte);
f0100c6d:	89 34 24             	mov    %esi,(%esp)
f0100c70:	e8 7b fe ff ff       	call   f0100af0 <pprint>
	if (argv[3][0] == 'P') perm = PTE_P;
f0100c75:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c78:	8b 40 0c             	mov    0xc(%eax),%eax
f0100c7b:	0f b6 10             	movzbl (%eax),%edx
	if (argv[3][0] == 'W') perm = PTE_W;
f0100c7e:	83 c4 10             	add    $0x10,%esp
f0100c81:	b8 02 00 00 00       	mov    $0x2,%eax
f0100c86:	80 fa 57             	cmp    $0x57,%dl
f0100c89:	74 0a                	je     f0100c95 <setm+0x7b>
	if (argv[3][0] == 'U') perm = PTE_U;
f0100c8b:	b8 04 00 00 00       	mov    $0x4,%eax
f0100c90:	80 fa 55             	cmp    $0x55,%dl
f0100c93:	75 49                	jne    f0100cde <setm+0xc4>
	if (argv[2][0] == '0') 	//clear
f0100c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0100c98:	8b 51 08             	mov    0x8(%ecx),%edx
f0100c9b:	80 3a 30             	cmpb   $0x30,(%edx)
f0100c9e:	74 49                	je     f0100ce9 <setm+0xcf>
		*pte = *pte | perm;
f0100ca0:	09 06                	or     %eax,(%esi)
	cprintf("%x after  setm: ", addr);
f0100ca2:	83 ec 08             	sub    $0x8,%esp
f0100ca5:	57                   	push   %edi
f0100ca6:	8d 83 55 c4 fe ff    	lea    -0x13bab(%ebx),%eax
f0100cac:	50                   	push   %eax
f0100cad:	e8 c1 26 00 00       	call   f0103373 <cprintf>
	pprint(pte);
f0100cb2:	89 34 24             	mov    %esi,(%esp)
f0100cb5:	e8 36 fe ff ff       	call   f0100af0 <pprint>
	return 0;
f0100cba:	83 c4 10             	add    $0x10,%esp
}
f0100cbd:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cc5:	5b                   	pop    %ebx
f0100cc6:	5e                   	pop    %esi
f0100cc7:	5f                   	pop    %edi
f0100cc8:	5d                   	pop    %ebp
f0100cc9:	c3                   	ret    
		cprintf("Usage: setm 0xaddr [0|1 :clear or set] [P|W|U]\n");
f0100cca:	83 ec 0c             	sub    $0xc,%esp
f0100ccd:	8d 83 54 c6 fe ff    	lea    -0x139ac(%ebx),%eax
f0100cd3:	50                   	push   %eax
f0100cd4:	e8 9a 26 00 00       	call   f0103373 <cprintf>
		return 0;
f0100cd9:	83 c4 10             	add    $0x10,%esp
f0100cdc:	eb df                	jmp    f0100cbd <setm+0xa3>
	if (argv[3][0] == 'P') perm = PTE_P;
f0100cde:	80 fa 50             	cmp    $0x50,%dl
f0100ce1:	0f 94 c0             	sete   %al
f0100ce4:	0f b6 c0             	movzbl %al,%eax
f0100ce7:	eb ac                	jmp    f0100c95 <setm+0x7b>
		*pte = *pte & ~perm;
f0100ce9:	f7 d0                	not    %eax
f0100ceb:	21 06                	and    %eax,(%esi)
f0100ced:	eb b3                	jmp    f0100ca2 <setm+0x88>

f0100cef <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100cef:	55                   	push   %ebp
f0100cf0:	89 e5                	mov    %esp,%ebp
f0100cf2:	53                   	push   %ebx
f0100cf3:	e8 e8 25 00 00       	call   f01032e0 <__x86.get_pc_thunk.dx>
f0100cf8:	81 c2 14 76 01 00    	add    $0x17614,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100cfe:	83 ba ac 1f 00 00 00 	cmpl   $0x0,0x1fac(%edx)
f0100d05:	74 1e                	je     f0100d25 <boot_alloc+0x36>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100d07:	8b 9a ac 1f 00 00    	mov    0x1fac(%edx),%ebx
	nextfree = ROUNDUP(nextfree+n, PGSIZE);
f0100d0d:	8d 8c 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%ecx
f0100d14:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100d1a:	89 8a ac 1f 00 00    	mov    %ecx,0x1fac(%edx)
	return result;
}
f0100d20:	89 d8                	mov    %ebx,%eax
f0100d22:	5b                   	pop    %ebx
f0100d23:	5d                   	pop    %ebp
f0100d24:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100d25:	c7 c1 c0 a6 11 f0    	mov    $0xf011a6c0,%ecx
f0100d2b:	81 c1 ff 0f 00 00    	add    $0xfff,%ecx
f0100d31:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100d37:	89 8a ac 1f 00 00    	mov    %ecx,0x1fac(%edx)
f0100d3d:	eb c8                	jmp    f0100d07 <boot_alloc+0x18>

f0100d3f <nvram_read>:
{
f0100d3f:	55                   	push   %ebp
f0100d40:	89 e5                	mov    %esp,%ebp
f0100d42:	57                   	push   %edi
f0100d43:	56                   	push   %esi
f0100d44:	53                   	push   %ebx
f0100d45:	83 ec 18             	sub    $0x18,%esp
f0100d48:	e8 02 f4 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0100d4d:	81 c3 bf 75 01 00    	add    $0x175bf,%ebx
f0100d53:	89 c7                	mov    %eax,%edi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100d55:	50                   	push   %eax
f0100d56:	e8 91 25 00 00       	call   f01032ec <mc146818_read>
f0100d5b:	89 c6                	mov    %eax,%esi
f0100d5d:	83 c7 01             	add    $0x1,%edi
f0100d60:	89 3c 24             	mov    %edi,(%esp)
f0100d63:	e8 84 25 00 00       	call   f01032ec <mc146818_read>
f0100d68:	c1 e0 08             	shl    $0x8,%eax
f0100d6b:	09 f0                	or     %esi,%eax
}
f0100d6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d70:	5b                   	pop    %ebx
f0100d71:	5e                   	pop    %esi
f0100d72:	5f                   	pop    %edi
f0100d73:	5d                   	pop    %ebp
f0100d74:	c3                   	ret    

f0100d75 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100d75:	55                   	push   %ebp
f0100d76:	89 e5                	mov    %esp,%ebp
f0100d78:	56                   	push   %esi
f0100d79:	53                   	push   %ebx
f0100d7a:	e8 65 25 00 00       	call   f01032e4 <__x86.get_pc_thunk.cx>
f0100d7f:	81 c1 8d 75 01 00    	add    $0x1758d,%ecx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100d85:	89 d3                	mov    %edx,%ebx
f0100d87:	c1 eb 16             	shr    $0x16,%ebx
	if (!(*pgdir & PTE_P))
f0100d8a:	8b 04 98             	mov    (%eax,%ebx,4),%eax
f0100d8d:	a8 01                	test   $0x1,%al
f0100d8f:	74 5a                	je     f0100deb <check_va2pa+0x76>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100d91:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d96:	89 c6                	mov    %eax,%esi
f0100d98:	c1 ee 0c             	shr    $0xc,%esi
f0100d9b:	c7 c3 c8 a6 11 f0    	mov    $0xf011a6c8,%ebx
f0100da1:	3b 33                	cmp    (%ebx),%esi
f0100da3:	73 2b                	jae    f0100dd0 <check_va2pa+0x5b>
	if (!(p[PTX(va)] & PTE_P))
f0100da5:	c1 ea 0c             	shr    $0xc,%edx
f0100da8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100dae:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100db5:	89 c2                	mov    %eax,%edx
f0100db7:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100dba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100dbf:	85 d2                	test   %edx,%edx
f0100dc1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100dc6:	0f 44 c2             	cmove  %edx,%eax
}
f0100dc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100dcc:	5b                   	pop    %ebx
f0100dcd:	5e                   	pop    %esi
f0100dce:	5d                   	pop    %ebp
f0100dcf:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100dd0:	50                   	push   %eax
f0100dd1:	8d 81 ac c6 fe ff    	lea    -0x13954(%ecx),%eax
f0100dd7:	50                   	push   %eax
f0100dd8:	68 d2 02 00 00       	push   $0x2d2
f0100ddd:	8d 81 24 ce fe ff    	lea    -0x131dc(%ecx),%eax
f0100de3:	50                   	push   %eax
f0100de4:	89 cb                	mov    %ecx,%ebx
f0100de6:	e8 ae f2 ff ff       	call   f0100099 <_panic>
		return ~0;
f0100deb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100df0:	eb d7                	jmp    f0100dc9 <check_va2pa+0x54>

f0100df2 <check_page_free_list>:
{
f0100df2:	55                   	push   %ebp
f0100df3:	89 e5                	mov    %esp,%ebp
f0100df5:	57                   	push   %edi
f0100df6:	56                   	push   %esi
f0100df7:	53                   	push   %ebx
f0100df8:	83 ec 3c             	sub    $0x3c,%esp
f0100dfb:	e8 e8 24 00 00       	call   f01032e8 <__x86.get_pc_thunk.di>
f0100e00:	81 c7 0c 75 01 00    	add    $0x1750c,%edi
f0100e06:	89 7d c4             	mov    %edi,-0x3c(%ebp)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e09:	84 c0                	test   %al,%al
f0100e0b:	0f 85 dd 02 00 00    	jne    f01010ee <check_page_free_list+0x2fc>
	if (!page_free_list)
f0100e11:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100e14:	83 b8 b0 1f 00 00 00 	cmpl   $0x0,0x1fb0(%eax)
f0100e1b:	74 0c                	je     f0100e29 <check_page_free_list+0x37>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e1d:	c7 45 d4 00 04 00 00 	movl   $0x400,-0x2c(%ebp)
f0100e24:	e9 2f 03 00 00       	jmp    f0101158 <check_page_free_list+0x366>
		panic("'page_free_list' is a null pointer!");
f0100e29:	83 ec 04             	sub    $0x4,%esp
f0100e2c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e2f:	8d 83 d0 c6 fe ff    	lea    -0x13930(%ebx),%eax
f0100e35:	50                   	push   %eax
f0100e36:	68 13 02 00 00       	push   $0x213
f0100e3b:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100e41:	50                   	push   %eax
f0100e42:	e8 52 f2 ff ff       	call   f0100099 <_panic>
f0100e47:	50                   	push   %eax
f0100e48:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e4b:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0100e51:	50                   	push   %eax
f0100e52:	6a 52                	push   $0x52
f0100e54:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0100e5a:	50                   	push   %eax
f0100e5b:	e8 39 f2 ff ff       	call   f0100099 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e60:	8b 36                	mov    (%esi),%esi
f0100e62:	85 f6                	test   %esi,%esi
f0100e64:	74 40                	je     f0100ea6 <check_page_free_list+0xb4>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e66:	89 f0                	mov    %esi,%eax
f0100e68:	2b 07                	sub    (%edi),%eax
f0100e6a:	c1 f8 03             	sar    $0x3,%eax
f0100e6d:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e70:	89 c2                	mov    %eax,%edx
f0100e72:	c1 ea 16             	shr    $0x16,%edx
f0100e75:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100e78:	73 e6                	jae    f0100e60 <check_page_free_list+0x6e>
	if (PGNUM(pa) >= npages)
f0100e7a:	89 c2                	mov    %eax,%edx
f0100e7c:	c1 ea 0c             	shr    $0xc,%edx
f0100e7f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0100e82:	3b 11                	cmp    (%ecx),%edx
f0100e84:	73 c1                	jae    f0100e47 <check_page_free_list+0x55>
			memset(page2kva(pp), 0x97, 128);
f0100e86:	83 ec 04             	sub    $0x4,%esp
f0100e89:	68 80 00 00 00       	push   $0x80
f0100e8e:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100e93:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e98:	50                   	push   %eax
f0100e99:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100e9c:	e8 e3 30 00 00       	call   f0103f84 <memset>
f0100ea1:	83 c4 10             	add    $0x10,%esp
f0100ea4:	eb ba                	jmp    f0100e60 <check_page_free_list+0x6e>
	first_free_page = (char *) boot_alloc(0);
f0100ea6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eab:	e8 3f fe ff ff       	call   f0100cef <boot_alloc>
f0100eb0:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100eb3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100eb6:	8b 97 b0 1f 00 00    	mov    0x1fb0(%edi),%edx
		assert(pp >= pages);
f0100ebc:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0100ec2:	8b 08                	mov    (%eax),%ecx
		assert(pp < pages + npages);
f0100ec4:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f0100eca:	8b 00                	mov    (%eax),%eax
f0100ecc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100ecf:	8d 1c c1             	lea    (%ecx,%eax,8),%ebx
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ed2:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ed5:	bf 00 00 00 00       	mov    $0x0,%edi
f0100eda:	89 75 d0             	mov    %esi,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100edd:	e9 08 01 00 00       	jmp    f0100fea <check_page_free_list+0x1f8>
		assert(pp >= pages);
f0100ee2:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100ee5:	8d 83 3e ce fe ff    	lea    -0x131c2(%ebx),%eax
f0100eeb:	50                   	push   %eax
f0100eec:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0100ef2:	50                   	push   %eax
f0100ef3:	68 2d 02 00 00       	push   $0x22d
f0100ef8:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100efe:	50                   	push   %eax
f0100eff:	e8 95 f1 ff ff       	call   f0100099 <_panic>
		assert(pp < pages + npages);
f0100f04:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f07:	8d 83 5f ce fe ff    	lea    -0x131a1(%ebx),%eax
f0100f0d:	50                   	push   %eax
f0100f0e:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0100f14:	50                   	push   %eax
f0100f15:	68 2e 02 00 00       	push   $0x22e
f0100f1a:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100f20:	50                   	push   %eax
f0100f21:	e8 73 f1 ff ff       	call   f0100099 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f26:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f29:	8d 83 f4 c6 fe ff    	lea    -0x1390c(%ebx),%eax
f0100f2f:	50                   	push   %eax
f0100f30:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0100f36:	50                   	push   %eax
f0100f37:	68 2f 02 00 00       	push   $0x22f
f0100f3c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100f42:	50                   	push   %eax
f0100f43:	e8 51 f1 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != 0);
f0100f48:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f4b:	8d 83 73 ce fe ff    	lea    -0x1318d(%ebx),%eax
f0100f51:	50                   	push   %eax
f0100f52:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0100f58:	50                   	push   %eax
f0100f59:	68 32 02 00 00       	push   $0x232
f0100f5e:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100f64:	50                   	push   %eax
f0100f65:	e8 2f f1 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f6a:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f6d:	8d 83 84 ce fe ff    	lea    -0x1317c(%ebx),%eax
f0100f73:	50                   	push   %eax
f0100f74:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0100f7a:	50                   	push   %eax
f0100f7b:	68 33 02 00 00       	push   $0x233
f0100f80:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100f86:	50                   	push   %eax
f0100f87:	e8 0d f1 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100f8c:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100f8f:	8d 83 28 c7 fe ff    	lea    -0x138d8(%ebx),%eax
f0100f95:	50                   	push   %eax
f0100f96:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0100f9c:	50                   	push   %eax
f0100f9d:	68 34 02 00 00       	push   $0x234
f0100fa2:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100fa8:	50                   	push   %eax
f0100fa9:	e8 eb f0 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100fae:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0100fb1:	8d 83 9d ce fe ff    	lea    -0x13163(%ebx),%eax
f0100fb7:	50                   	push   %eax
f0100fb8:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0100fbe:	50                   	push   %eax
f0100fbf:	68 35 02 00 00       	push   $0x235
f0100fc4:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0100fca:	50                   	push   %eax
f0100fcb:	e8 c9 f0 ff ff       	call   f0100099 <_panic>
	if (PGNUM(pa) >= npages)
f0100fd0:	89 c6                	mov    %eax,%esi
f0100fd2:	c1 ee 0c             	shr    $0xc,%esi
f0100fd5:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0100fd8:	76 70                	jbe    f010104a <check_page_free_list+0x258>
	return (void *)(pa + KERNBASE);
f0100fda:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100fdf:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100fe2:	77 7f                	ja     f0101063 <check_page_free_list+0x271>
			++nfree_extmem;
f0100fe4:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100fe8:	8b 12                	mov    (%edx),%edx
f0100fea:	85 d2                	test   %edx,%edx
f0100fec:	0f 84 93 00 00 00    	je     f0101085 <check_page_free_list+0x293>
		assert(pp >= pages);
f0100ff2:	39 d1                	cmp    %edx,%ecx
f0100ff4:	0f 87 e8 fe ff ff    	ja     f0100ee2 <check_page_free_list+0xf0>
		assert(pp < pages + npages);
f0100ffa:	39 d3                	cmp    %edx,%ebx
f0100ffc:	0f 86 02 ff ff ff    	jbe    f0100f04 <check_page_free_list+0x112>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0101002:	89 d0                	mov    %edx,%eax
f0101004:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0101007:	a8 07                	test   $0x7,%al
f0101009:	0f 85 17 ff ff ff    	jne    f0100f26 <check_page_free_list+0x134>
	return (pp - pages) << PGSHIFT;
f010100f:	c1 f8 03             	sar    $0x3,%eax
f0101012:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0101015:	85 c0                	test   %eax,%eax
f0101017:	0f 84 2b ff ff ff    	je     f0100f48 <check_page_free_list+0x156>
		assert(page2pa(pp) != IOPHYSMEM);
f010101d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0101022:	0f 84 42 ff ff ff    	je     f0100f6a <check_page_free_list+0x178>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0101028:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f010102d:	0f 84 59 ff ff ff    	je     f0100f8c <check_page_free_list+0x19a>
		assert(page2pa(pp) != EXTPHYSMEM);
f0101033:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0101038:	0f 84 70 ff ff ff    	je     f0100fae <check_page_free_list+0x1bc>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f010103e:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101043:	77 8b                	ja     f0100fd0 <check_page_free_list+0x1de>
			++nfree_basemem;
f0101045:	83 c7 01             	add    $0x1,%edi
f0101048:	eb 9e                	jmp    f0100fe8 <check_page_free_list+0x1f6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010104a:	50                   	push   %eax
f010104b:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f010104e:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0101054:	50                   	push   %eax
f0101055:	6a 52                	push   $0x52
f0101057:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f010105d:	50                   	push   %eax
f010105e:	e8 36 f0 ff ff       	call   f0100099 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101063:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101066:	8d 83 4c c7 fe ff    	lea    -0x138b4(%ebx),%eax
f010106c:	50                   	push   %eax
f010106d:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101073:	50                   	push   %eax
f0101074:	68 36 02 00 00       	push   $0x236
f0101079:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010107f:	50                   	push   %eax
f0101080:	e8 14 f0 ff ff       	call   f0100099 <_panic>
f0101085:	8b 75 d0             	mov    -0x30(%ebp),%esi
	assert(nfree_basemem > 0);
f0101088:	85 ff                	test   %edi,%edi
f010108a:	7e 1e                	jle    f01010aa <check_page_free_list+0x2b8>
	assert(nfree_extmem > 0);
f010108c:	85 f6                	test   %esi,%esi
f010108e:	7e 3c                	jle    f01010cc <check_page_free_list+0x2da>
	cprintf("check_page_free_list() succeeded!\n");
f0101090:	83 ec 0c             	sub    $0xc,%esp
f0101093:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f0101096:	8d 83 94 c7 fe ff    	lea    -0x1386c(%ebx),%eax
f010109c:	50                   	push   %eax
f010109d:	e8 d1 22 00 00       	call   f0103373 <cprintf>
}
f01010a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010a5:	5b                   	pop    %ebx
f01010a6:	5e                   	pop    %esi
f01010a7:	5f                   	pop    %edi
f01010a8:	5d                   	pop    %ebp
f01010a9:	c3                   	ret    
	assert(nfree_basemem > 0);
f01010aa:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01010ad:	8d 83 b7 ce fe ff    	lea    -0x13149(%ebx),%eax
f01010b3:	50                   	push   %eax
f01010b4:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01010ba:	50                   	push   %eax
f01010bb:	68 3e 02 00 00       	push   $0x23e
f01010c0:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01010c6:	50                   	push   %eax
f01010c7:	e8 cd ef ff ff       	call   f0100099 <_panic>
	assert(nfree_extmem > 0);
f01010cc:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
f01010cf:	8d 83 c9 ce fe ff    	lea    -0x13137(%ebx),%eax
f01010d5:	50                   	push   %eax
f01010d6:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01010dc:	50                   	push   %eax
f01010dd:	68 3f 02 00 00       	push   $0x23f
f01010e2:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01010e8:	50                   	push   %eax
f01010e9:	e8 ab ef ff ff       	call   f0100099 <_panic>
	if (!page_free_list)
f01010ee:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01010f1:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
f01010f7:	85 c0                	test   %eax,%eax
f01010f9:	0f 84 2a fd ff ff    	je     f0100e29 <check_page_free_list+0x37>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01010ff:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0101102:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0101105:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101108:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	return (pp - pages) << PGSHIFT;
f010110b:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010110e:	c7 c3 d0 a6 11 f0    	mov    $0xf011a6d0,%ebx
f0101114:	89 c2                	mov    %eax,%edx
f0101116:	2b 13                	sub    (%ebx),%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0101118:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010111e:	0f 95 c2             	setne  %dl
f0101121:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0101124:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0101128:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f010112a:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010112e:	8b 00                	mov    (%eax),%eax
f0101130:	85 c0                	test   %eax,%eax
f0101132:	75 e0                	jne    f0101114 <check_page_free_list+0x322>
		*tp[1] = 0;
f0101134:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101137:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010113d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101140:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101143:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0101145:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101148:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f010114b:	89 87 b0 1f 00 00    	mov    %eax,0x1fb0(%edi)
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0101151:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101158:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010115b:	8b b0 b0 1f 00 00    	mov    0x1fb0(%eax),%esi
f0101161:	c7 c7 d0 a6 11 f0    	mov    $0xf011a6d0,%edi
	if (PGNUM(pa) >= npages)
f0101167:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f010116d:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101170:	e9 ed fc ff ff       	jmp    f0100e62 <check_page_free_list+0x70>

f0101175 <page_init>:
{
f0101175:	55                   	push   %ebp
f0101176:	89 e5                	mov    %esp,%ebp
f0101178:	57                   	push   %edi
f0101179:	56                   	push   %esi
f010117a:	53                   	push   %ebx
f010117b:	83 ec 2c             	sub    $0x2c,%esp
f010117e:	e8 cc ef ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101183:	81 c3 89 71 01 00    	add    $0x17189,%ebx
    size_t kernel_end_page = PADDR(boot_alloc(0)) / PGSIZE;     //这里调了半天，boot_alloc返回的是虚拟地址，需要转为物理地址
f0101189:	b8 00 00 00 00       	mov    $0x0,%eax
f010118e:	e8 5c fb ff ff       	call   f0100cef <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0101193:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101198:	76 35                	jbe    f01011cf <page_init+0x5a>
	return (physaddr_t)kva - KERNBASE;
f010119a:	05 00 00 00 10       	add    $0x10000000,%eax
f010119f:	c1 e8 0c             	shr    $0xc,%eax
f01011a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01011a5:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f01011ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for (i = 0; i < npages; i++) {
f01011ae:	be 00 00 00 00       	mov    $0x0,%esi
f01011b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01011b8:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
            pages[i].pp_ref = 0;
f01011be:	c7 c7 d0 a6 11 f0    	mov    $0xf011a6d0,%edi
f01011c4:	89 7d dc             	mov    %edi,-0x24(%ebp)
            pages[i].pp_ref = 1;
f01011c7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
            pages[i].pp_ref = 1;
f01011ca:	89 7d e0             	mov    %edi,-0x20(%ebp)
    for (i = 0; i < npages; i++) {
f01011cd:	eb 3c                	jmp    f010120b <page_init+0x96>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011cf:	50                   	push   %eax
f01011d0:	8d 83 b8 c7 fe ff    	lea    -0x13848(%ebx),%eax
f01011d6:	50                   	push   %eax
f01011d7:	68 06 01 00 00       	push   $0x106
f01011dc:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01011e2:	50                   	push   %eax
f01011e3:	e8 b1 ee ff ff       	call   f0100099 <_panic>
        } else if (i >= io_hole_start_page && i < kernel_end_page) {
f01011e8:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f01011ed:	76 37                	jbe    f0101226 <page_init+0xb1>
f01011ef:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f01011f2:	73 32                	jae    f0101226 <page_init+0xb1>
            pages[i].pp_ref = 1;
f01011f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01011f7:	8b 0f                	mov    (%edi),%ecx
f01011f9:	8d 0c c1             	lea    (%ecx,%eax,8),%ecx
f01011fc:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f0101202:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
    for (i = 0; i < npages; i++) {
f0101208:	83 c0 01             	add    $0x1,%eax
f010120b:	39 02                	cmp    %eax,(%edx)
f010120d:	76 41                	jbe    f0101250 <page_init+0xdb>
        if (i == 0) {
f010120f:	85 c0                	test   %eax,%eax
f0101211:	75 d5                	jne    f01011e8 <page_init+0x73>
            pages[i].pp_ref = 1;
f0101213:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0101216:	8b 0f                	mov    (%edi),%ecx
f0101218:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
            pages[i].pp_link = NULL;
f010121e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
f0101224:	eb e2                	jmp    f0101208 <page_init+0x93>
f0101226:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
            pages[i].pp_ref = 0;
f010122d:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101230:	89 cf                	mov    %ecx,%edi
f0101232:	03 3e                	add    (%esi),%edi
f0101234:	89 fe                	mov    %edi,%esi
f0101236:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
            pages[i].pp_link = page_free_list;
f010123c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010123f:	89 3e                	mov    %edi,(%esi)
            page_free_list = &pages[i];
f0101241:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0101244:	03 0e                	add    (%esi),%ecx
f0101246:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101249:	be 01 00 00 00       	mov    $0x1,%esi
f010124e:	eb b8                	jmp    f0101208 <page_init+0x93>
f0101250:	89 f0                	mov    %esi,%eax
f0101252:	84 c0                	test   %al,%al
f0101254:	75 08                	jne    f010125e <page_init+0xe9>
}
f0101256:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101259:	5b                   	pop    %ebx
f010125a:	5e                   	pop    %esi
f010125b:	5f                   	pop    %edi
f010125c:	5d                   	pop    %ebp
f010125d:	c3                   	ret    
f010125e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101261:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
f0101267:	eb ed                	jmp    f0101256 <page_init+0xe1>

f0101269 <page_alloc>:
{
f0101269:	55                   	push   %ebp
f010126a:	89 e5                	mov    %esp,%ebp
f010126c:	56                   	push   %esi
f010126d:	53                   	push   %ebx
f010126e:	e8 dc ee ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101273:	81 c3 99 70 01 00    	add    $0x17099,%ebx
	if(page_free_list == NULL)
f0101279:	8b b3 b0 1f 00 00    	mov    0x1fb0(%ebx),%esi
f010127f:	85 f6                	test   %esi,%esi
f0101281:	74 14                	je     f0101297 <page_alloc+0x2e>
	page_free_list = one->pp_link;
f0101283:	8b 06                	mov    (%esi),%eax
f0101285:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
	one->pp_link = NULL;
f010128b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if(alloc_flags & ALLOC_ZERO)
f0101291:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0101295:	75 09                	jne    f01012a0 <page_alloc+0x37>
}
f0101297:	89 f0                	mov    %esi,%eax
f0101299:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010129c:	5b                   	pop    %ebx
f010129d:	5e                   	pop    %esi
f010129e:	5d                   	pop    %ebp
f010129f:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f01012a0:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01012a6:	89 f2                	mov    %esi,%edx
f01012a8:	2b 10                	sub    (%eax),%edx
f01012aa:	89 d0                	mov    %edx,%eax
f01012ac:	c1 f8 03             	sar    $0x3,%eax
f01012af:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01012b2:	89 c1                	mov    %eax,%ecx
f01012b4:	c1 e9 0c             	shr    $0xc,%ecx
f01012b7:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01012bd:	3b 0a                	cmp    (%edx),%ecx
f01012bf:	73 1a                	jae    f01012db <page_alloc+0x72>
		memset(page2kva(one), 0, PGSIZE);
f01012c1:	83 ec 04             	sub    $0x4,%esp
f01012c4:	68 00 10 00 00       	push   $0x1000
f01012c9:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f01012cb:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012d0:	50                   	push   %eax
f01012d1:	e8 ae 2c 00 00       	call   f0103f84 <memset>
f01012d6:	83 c4 10             	add    $0x10,%esp
f01012d9:	eb bc                	jmp    f0101297 <page_alloc+0x2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012db:	50                   	push   %eax
f01012dc:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f01012e2:	50                   	push   %eax
f01012e3:	6a 52                	push   $0x52
f01012e5:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f01012eb:	50                   	push   %eax
f01012ec:	e8 a8 ed ff ff       	call   f0100099 <_panic>

f01012f1 <page_free>:
{
f01012f1:	55                   	push   %ebp
f01012f2:	89 e5                	mov    %esp,%ebp
f01012f4:	53                   	push   %ebx
f01012f5:	83 ec 04             	sub    $0x4,%esp
f01012f8:	e8 52 ee ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01012fd:	81 c3 0f 70 01 00    	add    $0x1700f,%ebx
f0101303:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_ref == 0 && pp->pp_link == NULL){
f0101306:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f010130b:	75 18                	jne    f0101325 <page_free+0x34>
f010130d:	83 38 00             	cmpl   $0x0,(%eax)
f0101310:	75 13                	jne    f0101325 <page_free+0x34>
		pp->pp_link = page_free_list;
f0101312:	8b 8b b0 1f 00 00    	mov    0x1fb0(%ebx),%ecx
f0101318:	89 08                	mov    %ecx,(%eax)
		page_free_list =pp;
f010131a:	89 83 b0 1f 00 00    	mov    %eax,0x1fb0(%ebx)
}
f0101320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101323:	c9                   	leave  
f0101324:	c3                   	ret    
		panic("This oage can't be free\n");
f0101325:	83 ec 04             	sub    $0x4,%esp
f0101328:	8d 83 da ce fe ff    	lea    -0x13126(%ebx),%eax
f010132e:	50                   	push   %eax
f010132f:	68 42 01 00 00       	push   $0x142
f0101334:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010133a:	50                   	push   %eax
f010133b:	e8 59 ed ff ff       	call   f0100099 <_panic>

f0101340 <page_decref>:
{
f0101340:	55                   	push   %ebp
f0101341:	89 e5                	mov    %esp,%ebp
f0101343:	83 ec 08             	sub    $0x8,%esp
f0101346:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0101349:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010134d:	83 e8 01             	sub    $0x1,%eax
f0101350:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101354:	66 85 c0             	test   %ax,%ax
f0101357:	74 02                	je     f010135b <page_decref+0x1b>
}
f0101359:	c9                   	leave  
f010135a:	c3                   	ret    
		page_free(pp);
f010135b:	83 ec 0c             	sub    $0xc,%esp
f010135e:	52                   	push   %edx
f010135f:	e8 8d ff ff ff       	call   f01012f1 <page_free>
f0101364:	83 c4 10             	add    $0x10,%esp
}
f0101367:	eb f0                	jmp    f0101359 <page_decref+0x19>

f0101369 <pgdir_walk>:
{
f0101369:	55                   	push   %ebp
f010136a:	89 e5                	mov    %esp,%ebp
f010136c:	57                   	push   %edi
f010136d:	56                   	push   %esi
f010136e:	53                   	push   %ebx
f010136f:	83 ec 0c             	sub    $0xc,%esp
f0101372:	e8 d8 ed ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0101377:	81 c3 95 6f 01 00    	add    $0x16f95,%ebx
f010137d:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t pte_num = PTX(va);
f0101380:	89 f7                	mov    %esi,%edi
f0101382:	c1 ef 0c             	shr    $0xc,%edi
f0101385:	81 e7 ff 03 00 00    	and    $0x3ff,%edi
	pde_t pde_num = PDX(va);
f010138b:	c1 ee 16             	shr    $0x16,%esi
	pde_t *pde = pgdir + pde_num;
f010138e:	c1 e6 02             	shl    $0x2,%esi
f0101391:	03 75 08             	add    0x8(%ebp),%esi
	if(((*pde) & PTE_P) == 0){
f0101394:	f6 06 01             	testb  $0x1,(%esi)
f0101397:	75 31                	jne    f01013ca <pgdir_walk+0x61>
		if(create == 0)
f0101399:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010139d:	74 69                	je     f0101408 <pgdir_walk+0x9f>
		new_PT = page_alloc(1);
f010139f:	83 ec 0c             	sub    $0xc,%esp
f01013a2:	6a 01                	push   $0x1
f01013a4:	e8 c0 fe ff ff       	call   f0101269 <page_alloc>
		if(new_PT == NULL)
f01013a9:	83 c4 10             	add    $0x10,%esp
f01013ac:	85 c0                	test   %eax,%eax
f01013ae:	74 5f                	je     f010140f <pgdir_walk+0xa6>
	new_PT->pp_ref++;
f01013b0:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f01013b5:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f01013bb:	2b 02                	sub    (%edx),%eax
f01013bd:	c1 f8 03             	sar    $0x3,%eax
f01013c0:	c1 e0 0c             	shl    $0xc,%eax
	*pde = page2pa(new_PT) | PTE_P | PTE_U | PTE_W | PTE_AVAIL;
f01013c3:	0d 07 0e 00 00       	or     $0xe07,%eax
f01013c8:	89 06                	mov    %eax,(%esi)
	pte = (pte_t *)KADDR(PTE_ADDR(*pde));
f01013ca:	8b 06                	mov    (%esi),%eax
f01013cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f01013d1:	89 c1                	mov    %eax,%ecx
f01013d3:	c1 e9 0c             	shr    $0xc,%ecx
f01013d6:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01013dc:	3b 0a                	cmp    (%edx),%ecx
f01013de:	73 0f                	jae    f01013ef <pgdir_walk+0x86>
	return &pte[pte_num];
f01013e0:	8d 84 b8 00 00 00 f0 	lea    -0x10000000(%eax,%edi,4),%eax
}
f01013e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01013ea:	5b                   	pop    %ebx
f01013eb:	5e                   	pop    %esi
f01013ec:	5f                   	pop    %edi
f01013ed:	5d                   	pop    %ebp
f01013ee:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013ef:	50                   	push   %eax
f01013f0:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f01013f6:	50                   	push   %eax
f01013f7:	68 7b 01 00 00       	push   $0x17b
f01013fc:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101402:	50                   	push   %eax
f0101403:	e8 91 ec ff ff       	call   f0100099 <_panic>
			return NULL;
f0101408:	b8 00 00 00 00       	mov    $0x0,%eax
f010140d:	eb d8                	jmp    f01013e7 <pgdir_walk+0x7e>
			return NULL;
f010140f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101414:	eb d1                	jmp    f01013e7 <pgdir_walk+0x7e>

f0101416 <boot_map_region>:
{
f0101416:	55                   	push   %ebp
f0101417:	89 e5                	mov    %esp,%ebp
f0101419:	57                   	push   %edi
f010141a:	56                   	push   %esi
f010141b:	53                   	push   %ebx
f010141c:	83 ec 1c             	sub    $0x1c,%esp
f010141f:	e8 c4 1e 00 00       	call   f01032e8 <__x86.get_pc_thunk.di>
f0101424:	81 c7 e8 6e 01 00    	add    $0x16ee8,%edi
f010142a:	89 7d dc             	mov    %edi,-0x24(%ebp)
f010142d:	89 c7                	mov    %eax,%edi
f010142f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	for(size_t i = 0; i*PGSIZE<size; i++){
f0101432:	8b 5d 08             	mov    0x8(%ebp),%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f0101435:	89 d6                	mov    %edx,%esi
f0101437:	29 de                	sub    %ebx,%esi
		*pte = pa | perm |PTE_P;
f0101439:	8b 45 0c             	mov    0xc(%ebp),%eax
f010143c:	83 c8 01             	or     $0x1,%eax
f010143f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for(size_t i = 0; i*PGSIZE<size; i++){
f0101442:	89 d8                	mov    %ebx,%eax
f0101444:	2b 45 08             	sub    0x8(%ebp),%eax
f0101447:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
f010144a:	73 47                	jae    f0101493 <boot_map_region+0x7d>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f010144c:	83 ec 04             	sub    $0x4,%esp
f010144f:	6a 01                	push   $0x1
f0101451:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
f0101454:	50                   	push   %eax
f0101455:	57                   	push   %edi
f0101456:	e8 0e ff ff ff       	call   f0101369 <pgdir_walk>
		assert(pte);
f010145b:	83 c4 10             	add    $0x10,%esp
f010145e:	85 c0                	test   %eax,%eax
f0101460:	74 0f                	je     f0101471 <boot_map_region+0x5b>
		*pte = pa | perm |PTE_P;
f0101462:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0101465:	09 da                	or     %ebx,%edx
f0101467:	89 10                	mov    %edx,(%eax)
		pa+=PGSIZE;
f0101469:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010146f:	eb d1                	jmp    f0101442 <boot_map_region+0x2c>
		assert(pte);
f0101471:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0101474:	8d 83 f3 ce fe ff    	lea    -0x1310d(%ebx),%eax
f010147a:	50                   	push   %eax
f010147b:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101481:	50                   	push   %eax
f0101482:	68 90 01 00 00       	push   $0x190
f0101487:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010148d:	50                   	push   %eax
f010148e:	e8 06 ec ff ff       	call   f0100099 <_panic>
}
f0101493:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101496:	5b                   	pop    %ebx
f0101497:	5e                   	pop    %esi
f0101498:	5f                   	pop    %edi
f0101499:	5d                   	pop    %ebp
f010149a:	c3                   	ret    

f010149b <page_lookup>:
{
f010149b:	55                   	push   %ebp
f010149c:	89 e5                	mov    %esp,%ebp
f010149e:	56                   	push   %esi
f010149f:	53                   	push   %ebx
f01014a0:	e8 aa ec ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f01014a5:	81 c3 67 6e 01 00    	add    $0x16e67,%ebx
f01014ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ae:	8b 55 0c             	mov    0xc(%ebp),%edx
f01014b1:	8b 75 10             	mov    0x10(%ebp),%esi
	pde_t pde_num = PDX(va);
f01014b4:	89 d1                	mov    %edx,%ecx
f01014b6:	c1 e9 16             	shr    $0x16,%ecx
	if(((*pde) & PTE_P) == 0)
f01014b9:	f6 04 88 01          	testb  $0x1,(%eax,%ecx,4)
f01014bd:	74 52                	je     f0101511 <page_lookup+0x76>
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f01014bf:	83 ec 04             	sub    $0x4,%esp
f01014c2:	6a 00                	push   $0x0
f01014c4:	52                   	push   %edx
f01014c5:	50                   	push   %eax
f01014c6:	e8 9e fe ff ff       	call   f0101369 <pgdir_walk>
	if(!pte)
f01014cb:	83 c4 10             	add    $0x10,%esp
f01014ce:	85 c0                	test   %eax,%eax
f01014d0:	74 46                	je     f0101518 <page_lookup+0x7d>
	if(pte_store != 0)
f01014d2:	85 f6                	test   %esi,%esi
f01014d4:	74 02                	je     f01014d8 <page_lookup+0x3d>
		*pte_store = pte;
f01014d6:	89 06                	mov    %eax,(%esi)
f01014d8:	8b 00                	mov    (%eax),%eax
f01014da:	c1 e8 0c             	shr    $0xc,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014dd:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01014e3:	39 02                	cmp    %eax,(%edx)
f01014e5:	76 12                	jbe    f01014f9 <page_lookup+0x5e>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01014e7:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f01014ed:	8b 12                	mov    (%edx),%edx
f01014ef:	8d 04 c2             	lea    (%edx,%eax,8),%eax
}
f01014f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01014f5:	5b                   	pop    %ebx
f01014f6:	5e                   	pop    %esi
f01014f7:	5d                   	pop    %ebp
f01014f8:	c3                   	ret    
		panic("pa2page called with invalid pa");
f01014f9:	83 ec 04             	sub    $0x4,%esp
f01014fc:	8d 83 dc c7 fe ff    	lea    -0x13824(%ebx),%eax
f0101502:	50                   	push   %eax
f0101503:	6a 4b                	push   $0x4b
f0101505:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f010150b:	50                   	push   %eax
f010150c:	e8 88 eb ff ff       	call   f0100099 <_panic>
		return NULL;
f0101511:	b8 00 00 00 00       	mov    $0x0,%eax
f0101516:	eb da                	jmp    f01014f2 <page_lookup+0x57>
		return NULL;
f0101518:	b8 00 00 00 00       	mov    $0x0,%eax
f010151d:	eb d3                	jmp    f01014f2 <page_lookup+0x57>

f010151f <page_remove>:
{
f010151f:	55                   	push   %ebp
f0101520:	89 e5                	mov    %esp,%ebp
f0101522:	53                   	push   %ebx
f0101523:	83 ec 18             	sub    $0x18,%esp
f0101526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *un_page =page_lookup(pgdir, va, &pte);
f0101529:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010152c:	50                   	push   %eax
f010152d:	53                   	push   %ebx
f010152e:	ff 75 08             	pushl  0x8(%ebp)
f0101531:	e8 65 ff ff ff       	call   f010149b <page_lookup>
	if(un_page && (*pte & PTE_P)){
f0101536:	83 c4 10             	add    $0x10,%esp
f0101539:	85 c0                	test   %eax,%eax
f010153b:	74 08                	je     f0101545 <page_remove+0x26>
f010153d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101540:	f6 02 01             	testb  $0x1,(%edx)
f0101543:	75 05                	jne    f010154a <page_remove+0x2b>
}
f0101545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101548:	c9                   	leave  
f0101549:	c3                   	ret    
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010154a:	0f 01 3b             	invlpg (%ebx)
		*pte = 0;
f010154d:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101550:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		page_decref(un_page);
f0101556:	83 ec 0c             	sub    $0xc,%esp
f0101559:	50                   	push   %eax
f010155a:	e8 e1 fd ff ff       	call   f0101340 <page_decref>
f010155f:	83 c4 10             	add    $0x10,%esp
}
f0101562:	eb e1                	jmp    f0101545 <page_remove+0x26>

f0101564 <page_insert>:
{
f0101564:	55                   	push   %ebp
f0101565:	89 e5                	mov    %esp,%ebp
f0101567:	57                   	push   %edi
f0101568:	56                   	push   %esi
f0101569:	53                   	push   %ebx
f010156a:	83 ec 10             	sub    $0x10,%esp
f010156d:	e8 76 1d 00 00       	call   f01032e8 <__x86.get_pc_thunk.di>
f0101572:	81 c7 9a 6d 01 00    	add    $0x16d9a,%edi
f0101578:	8b 75 0c             	mov    0xc(%ebp),%esi
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f010157b:	6a 01                	push   $0x1
f010157d:	ff 75 10             	pushl  0x10(%ebp)
f0101580:	ff 75 08             	pushl  0x8(%ebp)
f0101583:	e8 e1 fd ff ff       	call   f0101369 <pgdir_walk>
	if(!pte)
f0101588:	83 c4 10             	add    $0x10,%esp
f010158b:	85 c0                	test   %eax,%eax
f010158d:	74 46                	je     f01015d5 <page_insert+0x71>
f010158f:	89 c3                	mov    %eax,%ebx
	pp->pp_ref++;
f0101591:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	if(*pte & PTE_P)
f0101596:	f6 00 01             	testb  $0x1,(%eax)
f0101599:	75 27                	jne    f01015c2 <page_insert+0x5e>
	return (pp - pages) << PGSHIFT;
f010159b:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01015a1:	2b 30                	sub    (%eax),%esi
f01015a3:	89 f0                	mov    %esi,%eax
f01015a5:	c1 f8 03             	sar    $0x3,%eax
f01015a8:	c1 e0 0c             	shl    $0xc,%eax
	*pte = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f01015ab:	8b 55 14             	mov    0x14(%ebp),%edx
f01015ae:	83 ca 01             	or     $0x1,%edx
f01015b1:	09 d0                	or     %edx,%eax
f01015b3:	89 03                	mov    %eax,(%ebx)
	return 0;
f01015b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01015ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01015bd:	5b                   	pop    %ebx
f01015be:	5e                   	pop    %esi
f01015bf:	5f                   	pop    %edi
f01015c0:	5d                   	pop    %ebp
f01015c1:	c3                   	ret    
		page_remove(pgdir, va);
f01015c2:	83 ec 08             	sub    $0x8,%esp
f01015c5:	ff 75 10             	pushl  0x10(%ebp)
f01015c8:	ff 75 08             	pushl  0x8(%ebp)
f01015cb:	e8 4f ff ff ff       	call   f010151f <page_remove>
f01015d0:	83 c4 10             	add    $0x10,%esp
f01015d3:	eb c6                	jmp    f010159b <page_insert+0x37>
		return -E_NO_MEM;
f01015d5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01015da:	eb de                	jmp    f01015ba <page_insert+0x56>

f01015dc <mem_init>:
{
f01015dc:	55                   	push   %ebp
f01015dd:	89 e5                	mov    %esp,%ebp
f01015df:	57                   	push   %edi
f01015e0:	56                   	push   %esi
f01015e1:	53                   	push   %ebx
f01015e2:	83 ec 3c             	sub    $0x3c,%esp
f01015e5:	e8 07 f1 ff ff       	call   f01006f1 <__x86.get_pc_thunk.ax>
f01015ea:	05 22 6d 01 00       	add    $0x16d22,%eax
f01015ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	basemem = nvram_read(NVRAM_BASELO);
f01015f2:	b8 15 00 00 00       	mov    $0x15,%eax
f01015f7:	e8 43 f7 ff ff       	call   f0100d3f <nvram_read>
f01015fc:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01015fe:	b8 17 00 00 00       	mov    $0x17,%eax
f0101603:	e8 37 f7 ff ff       	call   f0100d3f <nvram_read>
f0101608:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010160a:	b8 34 00 00 00       	mov    $0x34,%eax
f010160f:	e8 2b f7 ff ff       	call   f0100d3f <nvram_read>
f0101614:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f0101617:	85 c0                	test   %eax,%eax
f0101619:	0f 85 c2 00 00 00    	jne    f01016e1 <mem_init+0x105>
		totalmem = 1 * 1024 + extmem;
f010161f:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101625:	85 f6                	test   %esi,%esi
f0101627:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f010162a:	89 c1                	mov    %eax,%ecx
f010162c:	c1 e9 02             	shr    $0x2,%ecx
f010162f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101632:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f0101638:	89 0a                	mov    %ecx,(%edx)
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010163a:	89 c2                	mov    %eax,%edx
f010163c:	29 da                	sub    %ebx,%edx
f010163e:	52                   	push   %edx
f010163f:	53                   	push   %ebx
f0101640:	50                   	push   %eax
f0101641:	8d 87 fc c7 fe ff    	lea    -0x13804(%edi),%eax
f0101647:	50                   	push   %eax
f0101648:	89 fb                	mov    %edi,%ebx
f010164a:	e8 24 1d 00 00       	call   f0103373 <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010164f:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101654:	e8 96 f6 ff ff       	call   f0100cef <boot_alloc>
f0101659:	c7 c6 cc a6 11 f0    	mov    $0xf011a6cc,%esi
f010165f:	89 06                	mov    %eax,(%esi)
	memset(kern_pgdir, 0, PGSIZE);
f0101661:	83 c4 0c             	add    $0xc,%esp
f0101664:	68 00 10 00 00       	push   $0x1000
f0101669:	6a 00                	push   $0x0
f010166b:	50                   	push   %eax
f010166c:	e8 13 29 00 00       	call   f0103f84 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101671:	8b 06                	mov    (%esi),%eax
	if ((uint32_t)kva < KERNBASE)
f0101673:	83 c4 10             	add    $0x10,%esp
f0101676:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010167b:	76 6e                	jbe    f01016eb <mem_init+0x10f>
	return (physaddr_t)kva - KERNBASE;
f010167d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101683:	83 ca 05             	or     $0x5,%edx
f0101686:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(npages * sizeof(struct PageInfo));
f010168c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010168f:	c7 c3 c8 a6 11 f0    	mov    $0xf011a6c8,%ebx
f0101695:	8b 03                	mov    (%ebx),%eax
f0101697:	c1 e0 03             	shl    $0x3,%eax
f010169a:	e8 50 f6 ff ff       	call   f0100cef <boot_alloc>
f010169f:	c7 c6 d0 a6 11 f0    	mov    $0xf011a6d0,%esi
f01016a5:	89 06                	mov    %eax,(%esi)
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01016a7:	83 ec 04             	sub    $0x4,%esp
f01016aa:	8b 13                	mov    (%ebx),%edx
f01016ac:	c1 e2 03             	shl    $0x3,%edx
f01016af:	52                   	push   %edx
f01016b0:	6a 00                	push   $0x0
f01016b2:	50                   	push   %eax
f01016b3:	89 fb                	mov    %edi,%ebx
f01016b5:	e8 ca 28 00 00       	call   f0103f84 <memset>
	page_init();
f01016ba:	e8 b6 fa ff ff       	call   f0101175 <page_init>
	check_page_free_list(1);
f01016bf:	b8 01 00 00 00       	mov    $0x1,%eax
f01016c4:	e8 29 f7 ff ff       	call   f0100df2 <check_page_free_list>
	if (!pages)
f01016c9:	83 c4 10             	add    $0x10,%esp
f01016cc:	83 3e 00             	cmpl   $0x0,(%esi)
f01016cf:	74 36                	je     f0101707 <mem_init+0x12b>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01016d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016d4:	8b 80 b0 1f 00 00    	mov    0x1fb0(%eax),%eax
f01016da:	be 00 00 00 00       	mov    $0x0,%esi
f01016df:	eb 49                	jmp    f010172a <mem_init+0x14e>
		totalmem = 16 * 1024 + ext16mem;
f01016e1:	05 00 40 00 00       	add    $0x4000,%eax
f01016e6:	e9 3f ff ff ff       	jmp    f010162a <mem_init+0x4e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01016eb:	50                   	push   %eax
f01016ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01016ef:	8d 83 b8 c7 fe ff    	lea    -0x13848(%ebx),%eax
f01016f5:	50                   	push   %eax
f01016f6:	68 8f 00 00 00       	push   $0x8f
f01016fb:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101701:	50                   	push   %eax
f0101702:	e8 92 e9 ff ff       	call   f0100099 <_panic>
		panic("'pages' is a null pointer!");
f0101707:	83 ec 04             	sub    $0x4,%esp
f010170a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010170d:	8d 83 f7 ce fe ff    	lea    -0x13109(%ebx),%eax
f0101713:	50                   	push   %eax
f0101714:	68 52 02 00 00       	push   $0x252
f0101719:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010171f:	50                   	push   %eax
f0101720:	e8 74 e9 ff ff       	call   f0100099 <_panic>
		++nfree;
f0101725:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101728:	8b 00                	mov    (%eax),%eax
f010172a:	85 c0                	test   %eax,%eax
f010172c:	75 f7                	jne    f0101725 <mem_init+0x149>
	assert((pp0 = page_alloc(0)));
f010172e:	83 ec 0c             	sub    $0xc,%esp
f0101731:	6a 00                	push   $0x0
f0101733:	e8 31 fb ff ff       	call   f0101269 <page_alloc>
f0101738:	89 c3                	mov    %eax,%ebx
f010173a:	83 c4 10             	add    $0x10,%esp
f010173d:	85 c0                	test   %eax,%eax
f010173f:	0f 84 3b 02 00 00    	je     f0101980 <mem_init+0x3a4>
	assert((pp1 = page_alloc(0)));
f0101745:	83 ec 0c             	sub    $0xc,%esp
f0101748:	6a 00                	push   $0x0
f010174a:	e8 1a fb ff ff       	call   f0101269 <page_alloc>
f010174f:	89 c7                	mov    %eax,%edi
f0101751:	83 c4 10             	add    $0x10,%esp
f0101754:	85 c0                	test   %eax,%eax
f0101756:	0f 84 46 02 00 00    	je     f01019a2 <mem_init+0x3c6>
	assert((pp2 = page_alloc(0)));
f010175c:	83 ec 0c             	sub    $0xc,%esp
f010175f:	6a 00                	push   $0x0
f0101761:	e8 03 fb ff ff       	call   f0101269 <page_alloc>
f0101766:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101769:	83 c4 10             	add    $0x10,%esp
f010176c:	85 c0                	test   %eax,%eax
f010176e:	0f 84 50 02 00 00    	je     f01019c4 <mem_init+0x3e8>
	assert(pp1 && pp1 != pp0);
f0101774:	39 fb                	cmp    %edi,%ebx
f0101776:	0f 84 6a 02 00 00    	je     f01019e6 <mem_init+0x40a>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010177c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010177f:	39 c3                	cmp    %eax,%ebx
f0101781:	0f 84 81 02 00 00    	je     f0101a08 <mem_init+0x42c>
f0101787:	39 c7                	cmp    %eax,%edi
f0101789:	0f 84 79 02 00 00    	je     f0101a08 <mem_init+0x42c>
	return (pp - pages) << PGSHIFT;
f010178f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101792:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101798:	8b 08                	mov    (%eax),%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010179a:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f01017a0:	8b 10                	mov    (%eax),%edx
f01017a2:	c1 e2 0c             	shl    $0xc,%edx
f01017a5:	89 d8                	mov    %ebx,%eax
f01017a7:	29 c8                	sub    %ecx,%eax
f01017a9:	c1 f8 03             	sar    $0x3,%eax
f01017ac:	c1 e0 0c             	shl    $0xc,%eax
f01017af:	39 d0                	cmp    %edx,%eax
f01017b1:	0f 83 73 02 00 00    	jae    f0101a2a <mem_init+0x44e>
f01017b7:	89 f8                	mov    %edi,%eax
f01017b9:	29 c8                	sub    %ecx,%eax
f01017bb:	c1 f8 03             	sar    $0x3,%eax
f01017be:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01017c1:	39 c2                	cmp    %eax,%edx
f01017c3:	0f 86 83 02 00 00    	jbe    f0101a4c <mem_init+0x470>
f01017c9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017cc:	29 c8                	sub    %ecx,%eax
f01017ce:	c1 f8 03             	sar    $0x3,%eax
f01017d1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01017d4:	39 c2                	cmp    %eax,%edx
f01017d6:	0f 86 92 02 00 00    	jbe    f0101a6e <mem_init+0x492>
	fl = page_free_list;
f01017dc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017df:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f01017e5:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f01017e8:	c7 80 b0 1f 00 00 00 	movl   $0x0,0x1fb0(%eax)
f01017ef:	00 00 00 
	assert(!page_alloc(0));
f01017f2:	83 ec 0c             	sub    $0xc,%esp
f01017f5:	6a 00                	push   $0x0
f01017f7:	e8 6d fa ff ff       	call   f0101269 <page_alloc>
f01017fc:	83 c4 10             	add    $0x10,%esp
f01017ff:	85 c0                	test   %eax,%eax
f0101801:	0f 85 89 02 00 00    	jne    f0101a90 <mem_init+0x4b4>
	page_free(pp0);
f0101807:	83 ec 0c             	sub    $0xc,%esp
f010180a:	53                   	push   %ebx
f010180b:	e8 e1 fa ff ff       	call   f01012f1 <page_free>
	page_free(pp1);
f0101810:	89 3c 24             	mov    %edi,(%esp)
f0101813:	e8 d9 fa ff ff       	call   f01012f1 <page_free>
	page_free(pp2);
f0101818:	83 c4 04             	add    $0x4,%esp
f010181b:	ff 75 d0             	pushl  -0x30(%ebp)
f010181e:	e8 ce fa ff ff       	call   f01012f1 <page_free>
	assert((pp0 = page_alloc(0)));
f0101823:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010182a:	e8 3a fa ff ff       	call   f0101269 <page_alloc>
f010182f:	89 c7                	mov    %eax,%edi
f0101831:	83 c4 10             	add    $0x10,%esp
f0101834:	85 c0                	test   %eax,%eax
f0101836:	0f 84 76 02 00 00    	je     f0101ab2 <mem_init+0x4d6>
	assert((pp1 = page_alloc(0)));
f010183c:	83 ec 0c             	sub    $0xc,%esp
f010183f:	6a 00                	push   $0x0
f0101841:	e8 23 fa ff ff       	call   f0101269 <page_alloc>
f0101846:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101849:	83 c4 10             	add    $0x10,%esp
f010184c:	85 c0                	test   %eax,%eax
f010184e:	0f 84 80 02 00 00    	je     f0101ad4 <mem_init+0x4f8>
	assert((pp2 = page_alloc(0)));
f0101854:	83 ec 0c             	sub    $0xc,%esp
f0101857:	6a 00                	push   $0x0
f0101859:	e8 0b fa ff ff       	call   f0101269 <page_alloc>
f010185e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101861:	83 c4 10             	add    $0x10,%esp
f0101864:	85 c0                	test   %eax,%eax
f0101866:	0f 84 8a 02 00 00    	je     f0101af6 <mem_init+0x51a>
	assert(pp1 && pp1 != pp0);
f010186c:	3b 7d d0             	cmp    -0x30(%ebp),%edi
f010186f:	0f 84 a3 02 00 00    	je     f0101b18 <mem_init+0x53c>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101875:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101878:	39 c7                	cmp    %eax,%edi
f010187a:	0f 84 ba 02 00 00    	je     f0101b3a <mem_init+0x55e>
f0101880:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101883:	0f 84 b1 02 00 00    	je     f0101b3a <mem_init+0x55e>
	assert(!page_alloc(0));
f0101889:	83 ec 0c             	sub    $0xc,%esp
f010188c:	6a 00                	push   $0x0
f010188e:	e8 d6 f9 ff ff       	call   f0101269 <page_alloc>
f0101893:	83 c4 10             	add    $0x10,%esp
f0101896:	85 c0                	test   %eax,%eax
f0101898:	0f 85 be 02 00 00    	jne    f0101b5c <mem_init+0x580>
f010189e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018a1:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01018a7:	89 f9                	mov    %edi,%ecx
f01018a9:	2b 08                	sub    (%eax),%ecx
f01018ab:	89 c8                	mov    %ecx,%eax
f01018ad:	c1 f8 03             	sar    $0x3,%eax
f01018b0:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f01018b3:	89 c1                	mov    %eax,%ecx
f01018b5:	c1 e9 0c             	shr    $0xc,%ecx
f01018b8:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f01018be:	3b 0a                	cmp    (%edx),%ecx
f01018c0:	0f 83 b8 02 00 00    	jae    f0101b7e <mem_init+0x5a2>
	memset(page2kva(pp0), 1, PGSIZE);
f01018c6:	83 ec 04             	sub    $0x4,%esp
f01018c9:	68 00 10 00 00       	push   $0x1000
f01018ce:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01018d0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018d5:	50                   	push   %eax
f01018d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01018d9:	e8 a6 26 00 00       	call   f0103f84 <memset>
	page_free(pp0);
f01018de:	89 3c 24             	mov    %edi,(%esp)
f01018e1:	e8 0b fa ff ff       	call   f01012f1 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01018e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01018ed:	e8 77 f9 ff ff       	call   f0101269 <page_alloc>
f01018f2:	83 c4 10             	add    $0x10,%esp
f01018f5:	85 c0                	test   %eax,%eax
f01018f7:	0f 84 97 02 00 00    	je     f0101b94 <mem_init+0x5b8>
	assert(pp && pp0 == pp);
f01018fd:	39 c7                	cmp    %eax,%edi
f01018ff:	0f 85 b1 02 00 00    	jne    f0101bb6 <mem_init+0x5da>
	return (pp - pages) << PGSHIFT;
f0101905:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101908:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010190e:	89 fa                	mov    %edi,%edx
f0101910:	2b 10                	sub    (%eax),%edx
f0101912:	c1 fa 03             	sar    $0x3,%edx
f0101915:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101918:	89 d1                	mov    %edx,%ecx
f010191a:	c1 e9 0c             	shr    $0xc,%ecx
f010191d:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f0101923:	3b 08                	cmp    (%eax),%ecx
f0101925:	0f 83 ad 02 00 00    	jae    f0101bd8 <mem_init+0x5fc>
	return (void *)(pa + KERNBASE);
f010192b:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0101931:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f0101937:	80 38 00             	cmpb   $0x0,(%eax)
f010193a:	0f 85 ae 02 00 00    	jne    f0101bee <mem_init+0x612>
f0101940:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101943:	39 d0                	cmp    %edx,%eax
f0101945:	75 f0                	jne    f0101937 <mem_init+0x35b>
	page_free_list = fl;
f0101947:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010194a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f010194d:	89 8b b0 1f 00 00    	mov    %ecx,0x1fb0(%ebx)
	page_free(pp0);
f0101953:	83 ec 0c             	sub    $0xc,%esp
f0101956:	57                   	push   %edi
f0101957:	e8 95 f9 ff ff       	call   f01012f1 <page_free>
	page_free(pp1);
f010195c:	83 c4 04             	add    $0x4,%esp
f010195f:	ff 75 d0             	pushl  -0x30(%ebp)
f0101962:	e8 8a f9 ff ff       	call   f01012f1 <page_free>
	page_free(pp2);
f0101967:	83 c4 04             	add    $0x4,%esp
f010196a:	ff 75 cc             	pushl  -0x34(%ebp)
f010196d:	e8 7f f9 ff ff       	call   f01012f1 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101972:	8b 83 b0 1f 00 00    	mov    0x1fb0(%ebx),%eax
f0101978:	83 c4 10             	add    $0x10,%esp
f010197b:	e9 95 02 00 00       	jmp    f0101c15 <mem_init+0x639>
	assert((pp0 = page_alloc(0)));
f0101980:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101983:	8d 83 12 cf fe ff    	lea    -0x130ee(%ebx),%eax
f0101989:	50                   	push   %eax
f010198a:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101990:	50                   	push   %eax
f0101991:	68 5a 02 00 00       	push   $0x25a
f0101996:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010199c:	50                   	push   %eax
f010199d:	e8 f7 e6 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01019a2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019a5:	8d 83 28 cf fe ff    	lea    -0x130d8(%ebx),%eax
f01019ab:	50                   	push   %eax
f01019ac:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01019b2:	50                   	push   %eax
f01019b3:	68 5b 02 00 00       	push   $0x25b
f01019b8:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01019be:	50                   	push   %eax
f01019bf:	e8 d5 e6 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f01019c4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019c7:	8d 83 3e cf fe ff    	lea    -0x130c2(%ebx),%eax
f01019cd:	50                   	push   %eax
f01019ce:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01019d4:	50                   	push   %eax
f01019d5:	68 5c 02 00 00       	push   $0x25c
f01019da:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01019e0:	50                   	push   %eax
f01019e1:	e8 b3 e6 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01019e6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01019e9:	8d 83 54 cf fe ff    	lea    -0x130ac(%ebx),%eax
f01019ef:	50                   	push   %eax
f01019f0:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01019f6:	50                   	push   %eax
f01019f7:	68 5f 02 00 00       	push   $0x25f
f01019fc:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101a02:	50                   	push   %eax
f0101a03:	e8 91 e6 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a08:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a0b:	8d 83 38 c8 fe ff    	lea    -0x137c8(%ebx),%eax
f0101a11:	50                   	push   %eax
f0101a12:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101a18:	50                   	push   %eax
f0101a19:	68 60 02 00 00       	push   $0x260
f0101a1e:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101a24:	50                   	push   %eax
f0101a25:	e8 6f e6 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101a2a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a2d:	8d 83 66 cf fe ff    	lea    -0x1309a(%ebx),%eax
f0101a33:	50                   	push   %eax
f0101a34:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101a3a:	50                   	push   %eax
f0101a3b:	68 61 02 00 00       	push   $0x261
f0101a40:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101a46:	50                   	push   %eax
f0101a47:	e8 4d e6 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101a4c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a4f:	8d 83 83 cf fe ff    	lea    -0x1307d(%ebx),%eax
f0101a55:	50                   	push   %eax
f0101a56:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101a5c:	50                   	push   %eax
f0101a5d:	68 62 02 00 00       	push   $0x262
f0101a62:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101a68:	50                   	push   %eax
f0101a69:	e8 2b e6 ff ff       	call   f0100099 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101a6e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a71:	8d 83 a0 cf fe ff    	lea    -0x13060(%ebx),%eax
f0101a77:	50                   	push   %eax
f0101a78:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101a7e:	50                   	push   %eax
f0101a7f:	68 63 02 00 00       	push   $0x263
f0101a84:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101a8a:	50                   	push   %eax
f0101a8b:	e8 09 e6 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0101a90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101a93:	8d 83 bd cf fe ff    	lea    -0x13043(%ebx),%eax
f0101a99:	50                   	push   %eax
f0101a9a:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101aa0:	50                   	push   %eax
f0101aa1:	68 6a 02 00 00       	push   $0x26a
f0101aa6:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101aac:	50                   	push   %eax
f0101aad:	e8 e7 e5 ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0101ab2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ab5:	8d 83 12 cf fe ff    	lea    -0x130ee(%ebx),%eax
f0101abb:	50                   	push   %eax
f0101abc:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101ac2:	50                   	push   %eax
f0101ac3:	68 71 02 00 00       	push   $0x271
f0101ac8:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101ace:	50                   	push   %eax
f0101acf:	e8 c5 e5 ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f0101ad4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101ad7:	8d 83 28 cf fe ff    	lea    -0x130d8(%ebx),%eax
f0101add:	50                   	push   %eax
f0101ade:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101ae4:	50                   	push   %eax
f0101ae5:	68 72 02 00 00       	push   $0x272
f0101aea:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101af0:	50                   	push   %eax
f0101af1:	e8 a3 e5 ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f0101af6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101af9:	8d 83 3e cf fe ff    	lea    -0x130c2(%ebx),%eax
f0101aff:	50                   	push   %eax
f0101b00:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101b06:	50                   	push   %eax
f0101b07:	68 73 02 00 00       	push   $0x273
f0101b0c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101b12:	50                   	push   %eax
f0101b13:	e8 81 e5 ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f0101b18:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b1b:	8d 83 54 cf fe ff    	lea    -0x130ac(%ebx),%eax
f0101b21:	50                   	push   %eax
f0101b22:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101b28:	50                   	push   %eax
f0101b29:	68 75 02 00 00       	push   $0x275
f0101b2e:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101b34:	50                   	push   %eax
f0101b35:	e8 5f e5 ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b3a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b3d:	8d 83 38 c8 fe ff    	lea    -0x137c8(%ebx),%eax
f0101b43:	50                   	push   %eax
f0101b44:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101b4a:	50                   	push   %eax
f0101b4b:	68 76 02 00 00       	push   $0x276
f0101b50:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101b56:	50                   	push   %eax
f0101b57:	e8 3d e5 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0101b5c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b5f:	8d 83 bd cf fe ff    	lea    -0x13043(%ebx),%eax
f0101b65:	50                   	push   %eax
f0101b66:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101b6c:	50                   	push   %eax
f0101b6d:	68 77 02 00 00       	push   $0x277
f0101b72:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101b78:	50                   	push   %eax
f0101b79:	e8 1b e5 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b7e:	50                   	push   %eax
f0101b7f:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0101b85:	50                   	push   %eax
f0101b86:	6a 52                	push   $0x52
f0101b88:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0101b8e:	50                   	push   %eax
f0101b8f:	e8 05 e5 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101b94:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101b97:	8d 83 cc cf fe ff    	lea    -0x13034(%ebx),%eax
f0101b9d:	50                   	push   %eax
f0101b9e:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101ba4:	50                   	push   %eax
f0101ba5:	68 7c 02 00 00       	push   $0x27c
f0101baa:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101bb0:	50                   	push   %eax
f0101bb1:	e8 e3 e4 ff ff       	call   f0100099 <_panic>
	assert(pp && pp0 == pp);
f0101bb6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bb9:	8d 83 ea cf fe ff    	lea    -0x13016(%ebx),%eax
f0101bbf:	50                   	push   %eax
f0101bc0:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101bc6:	50                   	push   %eax
f0101bc7:	68 7d 02 00 00       	push   $0x27d
f0101bcc:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101bd2:	50                   	push   %eax
f0101bd3:	e8 c1 e4 ff ff       	call   f0100099 <_panic>
f0101bd8:	52                   	push   %edx
f0101bd9:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0101bdf:	50                   	push   %eax
f0101be0:	6a 52                	push   $0x52
f0101be2:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0101be8:	50                   	push   %eax
f0101be9:	e8 ab e4 ff ff       	call   f0100099 <_panic>
		assert(c[i] == 0);
f0101bee:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101bf1:	8d 83 fa cf fe ff    	lea    -0x13006(%ebx),%eax
f0101bf7:	50                   	push   %eax
f0101bf8:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0101bfe:	50                   	push   %eax
f0101bff:	68 80 02 00 00       	push   $0x280
f0101c04:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0101c0a:	50                   	push   %eax
f0101c0b:	e8 89 e4 ff ff       	call   f0100099 <_panic>
		--nfree;
f0101c10:	83 ee 01             	sub    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101c13:	8b 00                	mov    (%eax),%eax
f0101c15:	85 c0                	test   %eax,%eax
f0101c17:	75 f7                	jne    f0101c10 <mem_init+0x634>
	assert(nfree == 0);
f0101c19:	85 f6                	test   %esi,%esi
f0101c1b:	0f 85 55 08 00 00    	jne    f0102476 <mem_init+0xe9a>
	cprintf("check_page_alloc() succeeded!\n");
f0101c21:	83 ec 0c             	sub    $0xc,%esp
f0101c24:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101c27:	8d 83 58 c8 fe ff    	lea    -0x137a8(%ebx),%eax
f0101c2d:	50                   	push   %eax
f0101c2e:	e8 40 17 00 00       	call   f0103373 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101c33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c3a:	e8 2a f6 ff ff       	call   f0101269 <page_alloc>
f0101c3f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101c42:	83 c4 10             	add    $0x10,%esp
f0101c45:	85 c0                	test   %eax,%eax
f0101c47:	0f 84 4b 08 00 00    	je     f0102498 <mem_init+0xebc>
	assert((pp1 = page_alloc(0)));
f0101c4d:	83 ec 0c             	sub    $0xc,%esp
f0101c50:	6a 00                	push   $0x0
f0101c52:	e8 12 f6 ff ff       	call   f0101269 <page_alloc>
f0101c57:	89 c7                	mov    %eax,%edi
f0101c59:	83 c4 10             	add    $0x10,%esp
f0101c5c:	85 c0                	test   %eax,%eax
f0101c5e:	0f 84 56 08 00 00    	je     f01024ba <mem_init+0xede>
	assert((pp2 = page_alloc(0)));
f0101c64:	83 ec 0c             	sub    $0xc,%esp
f0101c67:	6a 00                	push   $0x0
f0101c69:	e8 fb f5 ff ff       	call   f0101269 <page_alloc>
f0101c6e:	89 c6                	mov    %eax,%esi
f0101c70:	83 c4 10             	add    $0x10,%esp
f0101c73:	85 c0                	test   %eax,%eax
f0101c75:	0f 84 61 08 00 00    	je     f01024dc <mem_init+0xf00>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101c7b:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0101c7e:	0f 84 7a 08 00 00    	je     f01024fe <mem_init+0xf22>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101c84:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101c87:	0f 84 93 08 00 00    	je     f0102520 <mem_init+0xf44>
f0101c8d:	39 c7                	cmp    %eax,%edi
f0101c8f:	0f 84 8b 08 00 00    	je     f0102520 <mem_init+0xf44>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c98:	8b 88 b0 1f 00 00    	mov    0x1fb0(%eax),%ecx
f0101c9e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
	page_free_list = 0;
f0101ca1:	c7 80 b0 1f 00 00 00 	movl   $0x0,0x1fb0(%eax)
f0101ca8:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101cab:	83 ec 0c             	sub    $0xc,%esp
f0101cae:	6a 00                	push   $0x0
f0101cb0:	e8 b4 f5 ff ff       	call   f0101269 <page_alloc>
f0101cb5:	83 c4 10             	add    $0x10,%esp
f0101cb8:	85 c0                	test   %eax,%eax
f0101cba:	0f 85 82 08 00 00    	jne    f0102542 <mem_init+0xf66>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101cc0:	83 ec 04             	sub    $0x4,%esp
f0101cc3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101cc6:	50                   	push   %eax
f0101cc7:	6a 00                	push   $0x0
f0101cc9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ccc:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101cd2:	ff 30                	pushl  (%eax)
f0101cd4:	e8 c2 f7 ff ff       	call   f010149b <page_lookup>
f0101cd9:	83 c4 10             	add    $0x10,%esp
f0101cdc:	85 c0                	test   %eax,%eax
f0101cde:	0f 85 80 08 00 00    	jne    f0102564 <mem_init+0xf88>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101ce4:	6a 02                	push   $0x2
f0101ce6:	6a 00                	push   $0x0
f0101ce8:	57                   	push   %edi
f0101ce9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101cec:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101cf2:	ff 30                	pushl  (%eax)
f0101cf4:	e8 6b f8 ff ff       	call   f0101564 <page_insert>
f0101cf9:	83 c4 10             	add    $0x10,%esp
f0101cfc:	85 c0                	test   %eax,%eax
f0101cfe:	0f 89 82 08 00 00    	jns    f0102586 <mem_init+0xfaa>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101d04:	83 ec 0c             	sub    $0xc,%esp
f0101d07:	ff 75 d0             	pushl  -0x30(%ebp)
f0101d0a:	e8 e2 f5 ff ff       	call   f01012f1 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101d0f:	6a 02                	push   $0x2
f0101d11:	6a 00                	push   $0x0
f0101d13:	57                   	push   %edi
f0101d14:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d17:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101d1d:	ff 30                	pushl  (%eax)
f0101d1f:	e8 40 f8 ff ff       	call   f0101564 <page_insert>
f0101d24:	83 c4 20             	add    $0x20,%esp
f0101d27:	85 c0                	test   %eax,%eax
f0101d29:	0f 85 79 08 00 00    	jne    f01025a8 <mem_init+0xfcc>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d2f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101d32:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101d38:	8b 18                	mov    (%eax),%ebx
	return (pp - pages) << PGSHIFT;
f0101d3a:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0101d40:	8b 08                	mov    (%eax),%ecx
f0101d42:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101d45:	8b 13                	mov    (%ebx),%edx
f0101d47:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d4d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d50:	29 c8                	sub    %ecx,%eax
f0101d52:	c1 f8 03             	sar    $0x3,%eax
f0101d55:	c1 e0 0c             	shl    $0xc,%eax
f0101d58:	39 c2                	cmp    %eax,%edx
f0101d5a:	0f 85 6a 08 00 00    	jne    f01025ca <mem_init+0xfee>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101d60:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d65:	89 d8                	mov    %ebx,%eax
f0101d67:	e8 09 f0 ff ff       	call   f0100d75 <check_va2pa>
f0101d6c:	89 fa                	mov    %edi,%edx
f0101d6e:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101d71:	c1 fa 03             	sar    $0x3,%edx
f0101d74:	c1 e2 0c             	shl    $0xc,%edx
f0101d77:	39 d0                	cmp    %edx,%eax
f0101d79:	0f 85 6d 08 00 00    	jne    f01025ec <mem_init+0x1010>
	assert(pp1->pp_ref == 1);
f0101d7f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d84:	0f 85 84 08 00 00    	jne    f010260e <mem_init+0x1032>
	assert(pp0->pp_ref == 1);
f0101d8a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101d8d:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d92:	0f 85 98 08 00 00    	jne    f0102630 <mem_init+0x1054>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d98:	6a 02                	push   $0x2
f0101d9a:	68 00 10 00 00       	push   $0x1000
f0101d9f:	56                   	push   %esi
f0101da0:	53                   	push   %ebx
f0101da1:	e8 be f7 ff ff       	call   f0101564 <page_insert>
f0101da6:	83 c4 10             	add    $0x10,%esp
f0101da9:	85 c0                	test   %eax,%eax
f0101dab:	0f 85 a1 08 00 00    	jne    f0102652 <mem_init+0x1076>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101db1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101db6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101db9:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101dbf:	8b 00                	mov    (%eax),%eax
f0101dc1:	e8 af ef ff ff       	call   f0100d75 <check_va2pa>
f0101dc6:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f0101dcc:	89 f1                	mov    %esi,%ecx
f0101dce:	2b 0a                	sub    (%edx),%ecx
f0101dd0:	89 ca                	mov    %ecx,%edx
f0101dd2:	c1 fa 03             	sar    $0x3,%edx
f0101dd5:	c1 e2 0c             	shl    $0xc,%edx
f0101dd8:	39 d0                	cmp    %edx,%eax
f0101dda:	0f 85 94 08 00 00    	jne    f0102674 <mem_init+0x1098>
	assert(pp2->pp_ref == 1);
f0101de0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101de5:	0f 85 ab 08 00 00    	jne    f0102696 <mem_init+0x10ba>

	// should be no free memory
	assert(!page_alloc(0));
f0101deb:	83 ec 0c             	sub    $0xc,%esp
f0101dee:	6a 00                	push   $0x0
f0101df0:	e8 74 f4 ff ff       	call   f0101269 <page_alloc>
f0101df5:	83 c4 10             	add    $0x10,%esp
f0101df8:	85 c0                	test   %eax,%eax
f0101dfa:	0f 85 b8 08 00 00    	jne    f01026b8 <mem_init+0x10dc>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e00:	6a 02                	push   $0x2
f0101e02:	68 00 10 00 00       	push   $0x1000
f0101e07:	56                   	push   %esi
f0101e08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e0b:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101e11:	ff 30                	pushl  (%eax)
f0101e13:	e8 4c f7 ff ff       	call   f0101564 <page_insert>
f0101e18:	83 c4 10             	add    $0x10,%esp
f0101e1b:	85 c0                	test   %eax,%eax
f0101e1d:	0f 85 b7 08 00 00    	jne    f01026da <mem_init+0x10fe>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101e23:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e28:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0101e2b:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101e31:	8b 00                	mov    (%eax),%eax
f0101e33:	e8 3d ef ff ff       	call   f0100d75 <check_va2pa>
f0101e38:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f0101e3e:	89 f1                	mov    %esi,%ecx
f0101e40:	2b 0a                	sub    (%edx),%ecx
f0101e42:	89 ca                	mov    %ecx,%edx
f0101e44:	c1 fa 03             	sar    $0x3,%edx
f0101e47:	c1 e2 0c             	shl    $0xc,%edx
f0101e4a:	39 d0                	cmp    %edx,%eax
f0101e4c:	0f 85 aa 08 00 00    	jne    f01026fc <mem_init+0x1120>
	assert(pp2->pp_ref == 1);
f0101e52:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e57:	0f 85 c1 08 00 00    	jne    f010271e <mem_init+0x1142>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e5d:	83 ec 0c             	sub    $0xc,%esp
f0101e60:	6a 00                	push   $0x0
f0101e62:	e8 02 f4 ff ff       	call   f0101269 <page_alloc>
f0101e67:	83 c4 10             	add    $0x10,%esp
f0101e6a:	85 c0                	test   %eax,%eax
f0101e6c:	0f 85 ce 08 00 00    	jne    f0102740 <mem_init+0x1164>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e72:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101e75:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101e7b:	8b 10                	mov    (%eax),%edx
f0101e7d:	8b 02                	mov    (%edx),%eax
f0101e7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101e84:	89 c3                	mov    %eax,%ebx
f0101e86:	c1 eb 0c             	shr    $0xc,%ebx
f0101e89:	c7 c1 c8 a6 11 f0    	mov    $0xf011a6c8,%ecx
f0101e8f:	3b 19                	cmp    (%ecx),%ebx
f0101e91:	0f 83 cb 08 00 00    	jae    f0102762 <mem_init+0x1186>
	return (void *)(pa + KERNBASE);
f0101e97:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e9f:	83 ec 04             	sub    $0x4,%esp
f0101ea2:	6a 00                	push   $0x0
f0101ea4:	68 00 10 00 00       	push   $0x1000
f0101ea9:	52                   	push   %edx
f0101eaa:	e8 ba f4 ff ff       	call   f0101369 <pgdir_walk>
f0101eaf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101eb2:	8d 51 04             	lea    0x4(%ecx),%edx
f0101eb5:	83 c4 10             	add    $0x10,%esp
f0101eb8:	39 d0                	cmp    %edx,%eax
f0101eba:	0f 85 be 08 00 00    	jne    f010277e <mem_init+0x11a2>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101ec0:	6a 06                	push   $0x6
f0101ec2:	68 00 10 00 00       	push   $0x1000
f0101ec7:	56                   	push   %esi
f0101ec8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ecb:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101ed1:	ff 30                	pushl  (%eax)
f0101ed3:	e8 8c f6 ff ff       	call   f0101564 <page_insert>
f0101ed8:	83 c4 10             	add    $0x10,%esp
f0101edb:	85 c0                	test   %eax,%eax
f0101edd:	0f 85 bd 08 00 00    	jne    f01027a0 <mem_init+0x11c4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ee3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ee6:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101eec:	8b 18                	mov    (%eax),%ebx
f0101eee:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ef3:	89 d8                	mov    %ebx,%eax
f0101ef5:	e8 7b ee ff ff       	call   f0100d75 <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101efa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101efd:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f0101f03:	89 f1                	mov    %esi,%ecx
f0101f05:	2b 0a                	sub    (%edx),%ecx
f0101f07:	89 ca                	mov    %ecx,%edx
f0101f09:	c1 fa 03             	sar    $0x3,%edx
f0101f0c:	c1 e2 0c             	shl    $0xc,%edx
f0101f0f:	39 d0                	cmp    %edx,%eax
f0101f11:	0f 85 ab 08 00 00    	jne    f01027c2 <mem_init+0x11e6>
	assert(pp2->pp_ref == 1);
f0101f17:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f1c:	0f 85 c2 08 00 00    	jne    f01027e4 <mem_init+0x1208>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f22:	83 ec 04             	sub    $0x4,%esp
f0101f25:	6a 00                	push   $0x0
f0101f27:	68 00 10 00 00       	push   $0x1000
f0101f2c:	53                   	push   %ebx
f0101f2d:	e8 37 f4 ff ff       	call   f0101369 <pgdir_walk>
f0101f32:	83 c4 10             	add    $0x10,%esp
f0101f35:	f6 00 04             	testb  $0x4,(%eax)
f0101f38:	0f 84 c8 08 00 00    	je     f0102806 <mem_init+0x122a>
	assert(kern_pgdir[0] & PTE_U);
f0101f3e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f41:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101f47:	8b 00                	mov    (%eax),%eax
f0101f49:	f6 00 04             	testb  $0x4,(%eax)
f0101f4c:	0f 84 d6 08 00 00    	je     f0102828 <mem_init+0x124c>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101f52:	6a 02                	push   $0x2
f0101f54:	68 00 10 00 00       	push   $0x1000
f0101f59:	56                   	push   %esi
f0101f5a:	50                   	push   %eax
f0101f5b:	e8 04 f6 ff ff       	call   f0101564 <page_insert>
f0101f60:	83 c4 10             	add    $0x10,%esp
f0101f63:	85 c0                	test   %eax,%eax
f0101f65:	0f 85 df 08 00 00    	jne    f010284a <mem_init+0x126e>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f6b:	83 ec 04             	sub    $0x4,%esp
f0101f6e:	6a 00                	push   $0x0
f0101f70:	68 00 10 00 00       	push   $0x1000
f0101f75:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f78:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101f7e:	ff 30                	pushl  (%eax)
f0101f80:	e8 e4 f3 ff ff       	call   f0101369 <pgdir_walk>
f0101f85:	83 c4 10             	add    $0x10,%esp
f0101f88:	f6 00 02             	testb  $0x2,(%eax)
f0101f8b:	0f 84 db 08 00 00    	je     f010286c <mem_init+0x1290>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f91:	83 ec 04             	sub    $0x4,%esp
f0101f94:	6a 00                	push   $0x0
f0101f96:	68 00 10 00 00       	push   $0x1000
f0101f9b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f9e:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101fa4:	ff 30                	pushl  (%eax)
f0101fa6:	e8 be f3 ff ff       	call   f0101369 <pgdir_walk>
f0101fab:	83 c4 10             	add    $0x10,%esp
f0101fae:	f6 00 04             	testb  $0x4,(%eax)
f0101fb1:	0f 85 d7 08 00 00    	jne    f010288e <mem_init+0x12b2>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101fb7:	6a 02                	push   $0x2
f0101fb9:	68 00 00 40 00       	push   $0x400000
f0101fbe:	ff 75 d0             	pushl  -0x30(%ebp)
f0101fc1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fc4:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101fca:	ff 30                	pushl  (%eax)
f0101fcc:	e8 93 f5 ff ff       	call   f0101564 <page_insert>
f0101fd1:	83 c4 10             	add    $0x10,%esp
f0101fd4:	85 c0                	test   %eax,%eax
f0101fd6:	0f 89 d4 08 00 00    	jns    f01028b0 <mem_init+0x12d4>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fdc:	6a 02                	push   $0x2
f0101fde:	68 00 10 00 00       	push   $0x1000
f0101fe3:	57                   	push   %edi
f0101fe4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe7:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0101fed:	ff 30                	pushl  (%eax)
f0101fef:	e8 70 f5 ff ff       	call   f0101564 <page_insert>
f0101ff4:	83 c4 10             	add    $0x10,%esp
f0101ff7:	85 c0                	test   %eax,%eax
f0101ff9:	0f 85 d3 08 00 00    	jne    f01028d2 <mem_init+0x12f6>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101fff:	83 ec 04             	sub    $0x4,%esp
f0102002:	6a 00                	push   $0x0
f0102004:	68 00 10 00 00       	push   $0x1000
f0102009:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010200c:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102012:	ff 30                	pushl  (%eax)
f0102014:	e8 50 f3 ff ff       	call   f0101369 <pgdir_walk>
f0102019:	83 c4 10             	add    $0x10,%esp
f010201c:	f6 00 04             	testb  $0x4,(%eax)
f010201f:	0f 85 cf 08 00 00    	jne    f01028f4 <mem_init+0x1318>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102025:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102028:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010202e:	8b 18                	mov    (%eax),%ebx
f0102030:	ba 00 00 00 00       	mov    $0x0,%edx
f0102035:	89 d8                	mov    %ebx,%eax
f0102037:	e8 39 ed ff ff       	call   f0100d75 <check_va2pa>
f010203c:	89 c2                	mov    %eax,%edx
f010203e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102041:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102044:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010204a:	89 f9                	mov    %edi,%ecx
f010204c:	2b 08                	sub    (%eax),%ecx
f010204e:	89 c8                	mov    %ecx,%eax
f0102050:	c1 f8 03             	sar    $0x3,%eax
f0102053:	c1 e0 0c             	shl    $0xc,%eax
f0102056:	39 c2                	cmp    %eax,%edx
f0102058:	0f 85 b8 08 00 00    	jne    f0102916 <mem_init+0x133a>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010205e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102063:	89 d8                	mov    %ebx,%eax
f0102065:	e8 0b ed ff ff       	call   f0100d75 <check_va2pa>
f010206a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f010206d:	0f 85 c5 08 00 00    	jne    f0102938 <mem_init+0x135c>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102073:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0102078:	0f 85 dc 08 00 00    	jne    f010295a <mem_init+0x137e>
	assert(pp2->pp_ref == 0);
f010207e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102083:	0f 85 f3 08 00 00    	jne    f010297c <mem_init+0x13a0>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102089:	83 ec 0c             	sub    $0xc,%esp
f010208c:	6a 00                	push   $0x0
f010208e:	e8 d6 f1 ff ff       	call   f0101269 <page_alloc>
f0102093:	83 c4 10             	add    $0x10,%esp
f0102096:	39 c6                	cmp    %eax,%esi
f0102098:	0f 85 00 09 00 00    	jne    f010299e <mem_init+0x13c2>
f010209e:	85 c0                	test   %eax,%eax
f01020a0:	0f 84 f8 08 00 00    	je     f010299e <mem_init+0x13c2>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020a6:	83 ec 08             	sub    $0x8,%esp
f01020a9:	6a 00                	push   $0x0
f01020ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ae:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f01020b4:	ff 33                	pushl  (%ebx)
f01020b6:	e8 64 f4 ff ff       	call   f010151f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020bb:	8b 1b                	mov    (%ebx),%ebx
f01020bd:	ba 00 00 00 00       	mov    $0x0,%edx
f01020c2:	89 d8                	mov    %ebx,%eax
f01020c4:	e8 ac ec ff ff       	call   f0100d75 <check_va2pa>
f01020c9:	83 c4 10             	add    $0x10,%esp
f01020cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020cf:	0f 85 eb 08 00 00    	jne    f01029c0 <mem_init+0x13e4>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020d5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020da:	89 d8                	mov    %ebx,%eax
f01020dc:	e8 94 ec ff ff       	call   f0100d75 <check_va2pa>
f01020e1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01020e4:	c7 c2 d0 a6 11 f0    	mov    $0xf011a6d0,%edx
f01020ea:	89 f9                	mov    %edi,%ecx
f01020ec:	2b 0a                	sub    (%edx),%ecx
f01020ee:	89 ca                	mov    %ecx,%edx
f01020f0:	c1 fa 03             	sar    $0x3,%edx
f01020f3:	c1 e2 0c             	shl    $0xc,%edx
f01020f6:	39 d0                	cmp    %edx,%eax
f01020f8:	0f 85 e4 08 00 00    	jne    f01029e2 <mem_init+0x1406>
	assert(pp1->pp_ref == 1);
f01020fe:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102103:	0f 85 fb 08 00 00    	jne    f0102a04 <mem_init+0x1428>
	assert(pp2->pp_ref == 0);
f0102109:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010210e:	0f 85 12 09 00 00    	jne    f0102a26 <mem_init+0x144a>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102114:	6a 00                	push   $0x0
f0102116:	68 00 10 00 00       	push   $0x1000
f010211b:	57                   	push   %edi
f010211c:	53                   	push   %ebx
f010211d:	e8 42 f4 ff ff       	call   f0101564 <page_insert>
f0102122:	83 c4 10             	add    $0x10,%esp
f0102125:	85 c0                	test   %eax,%eax
f0102127:	0f 85 1b 09 00 00    	jne    f0102a48 <mem_init+0x146c>
	assert(pp1->pp_ref);
f010212d:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102132:	0f 84 32 09 00 00    	je     f0102a6a <mem_init+0x148e>
	assert(pp1->pp_link == NULL);
f0102138:	83 3f 00             	cmpl   $0x0,(%edi)
f010213b:	0f 85 4b 09 00 00    	jne    f0102a8c <mem_init+0x14b0>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102141:	83 ec 08             	sub    $0x8,%esp
f0102144:	68 00 10 00 00       	push   $0x1000
f0102149:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010214c:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f0102152:	ff 33                	pushl  (%ebx)
f0102154:	e8 c6 f3 ff ff       	call   f010151f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102159:	8b 1b                	mov    (%ebx),%ebx
f010215b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102160:	89 d8                	mov    %ebx,%eax
f0102162:	e8 0e ec ff ff       	call   f0100d75 <check_va2pa>
f0102167:	83 c4 10             	add    $0x10,%esp
f010216a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010216d:	0f 85 3b 09 00 00    	jne    f0102aae <mem_init+0x14d2>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102173:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102178:	89 d8                	mov    %ebx,%eax
f010217a:	e8 f6 eb ff ff       	call   f0100d75 <check_va2pa>
f010217f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102182:	0f 85 48 09 00 00    	jne    f0102ad0 <mem_init+0x14f4>
	assert(pp1->pp_ref == 0);
f0102188:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010218d:	0f 85 5f 09 00 00    	jne    f0102af2 <mem_init+0x1516>
	assert(pp2->pp_ref == 0);
f0102193:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102198:	0f 85 76 09 00 00    	jne    f0102b14 <mem_init+0x1538>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010219e:	83 ec 0c             	sub    $0xc,%esp
f01021a1:	6a 00                	push   $0x0
f01021a3:	e8 c1 f0 ff ff       	call   f0101269 <page_alloc>
f01021a8:	83 c4 10             	add    $0x10,%esp
f01021ab:	39 c7                	cmp    %eax,%edi
f01021ad:	0f 85 83 09 00 00    	jne    f0102b36 <mem_init+0x155a>
f01021b3:	85 c0                	test   %eax,%eax
f01021b5:	0f 84 7b 09 00 00    	je     f0102b36 <mem_init+0x155a>

	// should be no free memory
	assert(!page_alloc(0));
f01021bb:	83 ec 0c             	sub    $0xc,%esp
f01021be:	6a 00                	push   $0x0
f01021c0:	e8 a4 f0 ff ff       	call   f0101269 <page_alloc>
f01021c5:	83 c4 10             	add    $0x10,%esp
f01021c8:	85 c0                	test   %eax,%eax
f01021ca:	0f 85 88 09 00 00    	jne    f0102b58 <mem_init+0x157c>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01021d0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01021d3:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01021d9:	8b 08                	mov    (%eax),%ecx
f01021db:	8b 11                	mov    (%ecx),%edx
f01021dd:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01021e3:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01021e9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01021ec:	2b 18                	sub    (%eax),%ebx
f01021ee:	89 d8                	mov    %ebx,%eax
f01021f0:	c1 f8 03             	sar    $0x3,%eax
f01021f3:	c1 e0 0c             	shl    $0xc,%eax
f01021f6:	39 c2                	cmp    %eax,%edx
f01021f8:	0f 85 7c 09 00 00    	jne    f0102b7a <mem_init+0x159e>
	kern_pgdir[0] = 0;
f01021fe:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102204:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102207:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010220c:	0f 85 8a 09 00 00    	jne    f0102b9c <mem_init+0x15c0>
	pp0->pp_ref = 0;
f0102212:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102215:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010221b:	83 ec 0c             	sub    $0xc,%esp
f010221e:	50                   	push   %eax
f010221f:	e8 cd f0 ff ff       	call   f01012f1 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102224:	83 c4 0c             	add    $0xc,%esp
f0102227:	6a 01                	push   $0x1
f0102229:	68 00 10 40 00       	push   $0x401000
f010222e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102231:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f0102237:	ff 33                	pushl  (%ebx)
f0102239:	e8 2b f1 ff ff       	call   f0101369 <pgdir_walk>
f010223e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102241:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102244:	8b 1b                	mov    (%ebx),%ebx
f0102246:	8b 53 04             	mov    0x4(%ebx),%edx
f0102249:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f010224f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102252:	c7 c1 c8 a6 11 f0    	mov    $0xf011a6c8,%ecx
f0102258:	8b 09                	mov    (%ecx),%ecx
f010225a:	89 d0                	mov    %edx,%eax
f010225c:	c1 e8 0c             	shr    $0xc,%eax
f010225f:	83 c4 10             	add    $0x10,%esp
f0102262:	39 c8                	cmp    %ecx,%eax
f0102264:	0f 83 54 09 00 00    	jae    f0102bbe <mem_init+0x15e2>
	assert(ptep == ptep1 + PTX(va));
f010226a:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102270:	39 55 cc             	cmp    %edx,-0x34(%ebp)
f0102273:	0f 85 61 09 00 00    	jne    f0102bda <mem_init+0x15fe>
	kern_pgdir[PDX(va)] = 0;
f0102279:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	pp0->pp_ref = 0;
f0102280:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102283:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
	return (pp - pages) << PGSHIFT;
f0102289:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010228c:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0102292:	2b 18                	sub    (%eax),%ebx
f0102294:	89 d8                	mov    %ebx,%eax
f0102296:	c1 f8 03             	sar    $0x3,%eax
f0102299:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010229c:	89 c2                	mov    %eax,%edx
f010229e:	c1 ea 0c             	shr    $0xc,%edx
f01022a1:	39 d1                	cmp    %edx,%ecx
f01022a3:	0f 86 53 09 00 00    	jbe    f0102bfc <mem_init+0x1620>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01022a9:	83 ec 04             	sub    $0x4,%esp
f01022ac:	68 00 10 00 00       	push   $0x1000
f01022b1:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f01022b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01022bb:	50                   	push   %eax
f01022bc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022bf:	e8 c0 1c 00 00       	call   f0103f84 <memset>
	page_free(pp0);
f01022c4:	83 c4 04             	add    $0x4,%esp
f01022c7:	ff 75 d0             	pushl  -0x30(%ebp)
f01022ca:	e8 22 f0 ff ff       	call   f01012f1 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01022cf:	83 c4 0c             	add    $0xc,%esp
f01022d2:	6a 01                	push   $0x1
f01022d4:	6a 00                	push   $0x0
f01022d6:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01022d9:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01022df:	ff 30                	pushl  (%eax)
f01022e1:	e8 83 f0 ff ff       	call   f0101369 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f01022e6:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f01022ec:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01022ef:	2b 10                	sub    (%eax),%edx
f01022f1:	c1 fa 03             	sar    $0x3,%edx
f01022f4:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01022f7:	89 d1                	mov    %edx,%ecx
f01022f9:	c1 e9 0c             	shr    $0xc,%ecx
f01022fc:	83 c4 10             	add    $0x10,%esp
f01022ff:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f0102305:	3b 08                	cmp    (%eax),%ecx
f0102307:	0f 83 08 09 00 00    	jae    f0102c15 <mem_init+0x1639>
	return (void *)(pa + KERNBASE);
f010230d:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102313:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102316:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010231c:	f6 00 01             	testb  $0x1,(%eax)
f010231f:	0f 85 09 09 00 00    	jne    f0102c2e <mem_init+0x1652>
f0102325:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0102328:	39 d0                	cmp    %edx,%eax
f010232a:	75 f0                	jne    f010231c <mem_init+0xd40>
	kern_pgdir[0] = 0;
f010232c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010232f:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102335:	8b 00                	mov    (%eax),%eax
f0102337:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010233d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102340:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102346:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102349:	89 93 b0 1f 00 00    	mov    %edx,0x1fb0(%ebx)

	// free the pages we took
	page_free(pp0);
f010234f:	83 ec 0c             	sub    $0xc,%esp
f0102352:	50                   	push   %eax
f0102353:	e8 99 ef ff ff       	call   f01012f1 <page_free>
	page_free(pp1);
f0102358:	89 3c 24             	mov    %edi,(%esp)
f010235b:	e8 91 ef ff ff       	call   f01012f1 <page_free>
	page_free(pp2);
f0102360:	89 34 24             	mov    %esi,(%esp)
f0102363:	e8 89 ef ff ff       	call   f01012f1 <page_free>

	cprintf("check_page() succeeded!\n");
f0102368:	8d 83 db d0 fe ff    	lea    -0x12f25(%ebx),%eax
f010236e:	89 04 24             	mov    %eax,(%esp)
f0102371:	e8 fd 0f 00 00       	call   f0103373 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U|PTE_P);
f0102376:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010237c:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010237e:	83 c4 10             	add    $0x10,%esp
f0102381:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102386:	0f 86 c4 08 00 00    	jbe    f0102c50 <mem_init+0x1674>
f010238c:	83 ec 08             	sub    $0x8,%esp
f010238f:	6a 05                	push   $0x5
	return (physaddr_t)kva - KERNBASE;
f0102391:	05 00 00 00 10       	add    $0x10000000,%eax
f0102396:	50                   	push   %eax
f0102397:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010239c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01023a1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01023a4:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f01023aa:	8b 00                	mov    (%eax),%eax
f01023ac:	e8 65 f0 ff ff       	call   f0101416 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f01023b1:	c7 c0 00 f0 10 f0    	mov    $0xf010f000,%eax
f01023b7:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01023ba:	83 c4 10             	add    $0x10,%esp
f01023bd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023c2:	0f 86 a4 08 00 00    	jbe    f0102c6c <mem_init+0x1690>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W|PTE_P);
f01023c8:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01023cb:	c7 c3 cc a6 11 f0    	mov    $0xf011a6cc,%ebx
f01023d1:	83 ec 08             	sub    $0x8,%esp
f01023d4:	6a 03                	push   $0x3
	return (physaddr_t)kva - KERNBASE;
f01023d6:	8b 45 c8             	mov    -0x38(%ebp),%eax
f01023d9:	05 00 00 00 10       	add    $0x10000000,%eax
f01023de:	50                   	push   %eax
f01023df:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01023e4:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01023e9:	8b 03                	mov    (%ebx),%eax
f01023eb:	e8 26 f0 ff ff       	call   f0101416 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0x100000000-KERNBASE, 0, PTE_W|PTE_P);
f01023f0:	83 c4 08             	add    $0x8,%esp
f01023f3:	6a 03                	push   $0x3
f01023f5:	6a 00                	push   $0x0
f01023f7:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01023fc:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102401:	8b 03                	mov    (%ebx),%eax
f0102403:	e8 0e f0 ff ff       	call   f0101416 <boot_map_region>
	pgdir = kern_pgdir;
f0102408:	8b 33                	mov    (%ebx),%esi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010240a:	c7 c0 c8 a6 11 f0    	mov    $0xf011a6c8,%eax
f0102410:	8b 00                	mov    (%eax),%eax
f0102412:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102415:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010241c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102421:	89 45 d0             	mov    %eax,-0x30(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102424:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010242a:	8b 00                	mov    (%eax),%eax
f010242c:	89 45 c0             	mov    %eax,-0x40(%ebp)
	if ((uint32_t)kva < KERNBASE)
f010242f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102432:	8d 98 00 00 00 10    	lea    0x10000000(%eax),%ebx
f0102438:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < n; i += PGSIZE)
f010243b:	bf 00 00 00 00       	mov    $0x0,%edi
f0102440:	39 7d d0             	cmp    %edi,-0x30(%ebp)
f0102443:	0f 86 84 08 00 00    	jbe    f0102ccd <mem_init+0x16f1>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102449:	8d 97 00 00 00 ef    	lea    -0x11000000(%edi),%edx
f010244f:	89 f0                	mov    %esi,%eax
f0102451:	e8 1f e9 ff ff       	call   f0100d75 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f0102456:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010245d:	0f 86 2a 08 00 00    	jbe    f0102c8d <mem_init+0x16b1>
f0102463:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102466:	39 c2                	cmp    %eax,%edx
f0102468:	0f 85 3d 08 00 00    	jne    f0102cab <mem_init+0x16cf>
	for (i = 0; i < n; i += PGSIZE)
f010246e:	81 c7 00 10 00 00    	add    $0x1000,%edi
f0102474:	eb ca                	jmp    f0102440 <mem_init+0xe64>
	assert(nfree == 0);
f0102476:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102479:	8d 83 04 d0 fe ff    	lea    -0x12ffc(%ebx),%eax
f010247f:	50                   	push   %eax
f0102480:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102486:	50                   	push   %eax
f0102487:	68 8d 02 00 00       	push   $0x28d
f010248c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102492:	50                   	push   %eax
f0102493:	e8 01 dc ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f0102498:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010249b:	8d 83 12 cf fe ff    	lea    -0x130ee(%ebx),%eax
f01024a1:	50                   	push   %eax
f01024a2:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01024a8:	50                   	push   %eax
f01024a9:	68 e6 02 00 00       	push   $0x2e6
f01024ae:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01024b4:	50                   	push   %eax
f01024b5:	e8 df db ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f01024ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024bd:	8d 83 28 cf fe ff    	lea    -0x130d8(%ebx),%eax
f01024c3:	50                   	push   %eax
f01024c4:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01024ca:	50                   	push   %eax
f01024cb:	68 e7 02 00 00       	push   $0x2e7
f01024d0:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01024d6:	50                   	push   %eax
f01024d7:	e8 bd db ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f01024dc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01024df:	8d 83 3e cf fe ff    	lea    -0x130c2(%ebx),%eax
f01024e5:	50                   	push   %eax
f01024e6:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01024ec:	50                   	push   %eax
f01024ed:	68 e8 02 00 00       	push   $0x2e8
f01024f2:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01024f8:	50                   	push   %eax
f01024f9:	e8 9b db ff ff       	call   f0100099 <_panic>
	assert(pp1 && pp1 != pp0);
f01024fe:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102501:	8d 83 54 cf fe ff    	lea    -0x130ac(%ebx),%eax
f0102507:	50                   	push   %eax
f0102508:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010250e:	50                   	push   %eax
f010250f:	68 eb 02 00 00       	push   $0x2eb
f0102514:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010251a:	50                   	push   %eax
f010251b:	e8 79 db ff ff       	call   f0100099 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102520:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102523:	8d 83 38 c8 fe ff    	lea    -0x137c8(%ebx),%eax
f0102529:	50                   	push   %eax
f010252a:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102530:	50                   	push   %eax
f0102531:	68 ec 02 00 00       	push   $0x2ec
f0102536:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010253c:	50                   	push   %eax
f010253d:	e8 57 db ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102542:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102545:	8d 83 bd cf fe ff    	lea    -0x13043(%ebx),%eax
f010254b:	50                   	push   %eax
f010254c:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102552:	50                   	push   %eax
f0102553:	68 f3 02 00 00       	push   $0x2f3
f0102558:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010255e:	50                   	push   %eax
f010255f:	e8 35 db ff ff       	call   f0100099 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102564:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102567:	8d 83 78 c8 fe ff    	lea    -0x13788(%ebx),%eax
f010256d:	50                   	push   %eax
f010256e:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102574:	50                   	push   %eax
f0102575:	68 f6 02 00 00       	push   $0x2f6
f010257a:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102580:	50                   	push   %eax
f0102581:	e8 13 db ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102586:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102589:	8d 83 b0 c8 fe ff    	lea    -0x13750(%ebx),%eax
f010258f:	50                   	push   %eax
f0102590:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102596:	50                   	push   %eax
f0102597:	68 f9 02 00 00       	push   $0x2f9
f010259c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01025a2:	50                   	push   %eax
f01025a3:	e8 f1 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01025a8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ab:	8d 83 e0 c8 fe ff    	lea    -0x13720(%ebx),%eax
f01025b1:	50                   	push   %eax
f01025b2:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01025b8:	50                   	push   %eax
f01025b9:	68 fd 02 00 00       	push   $0x2fd
f01025be:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01025c4:	50                   	push   %eax
f01025c5:	e8 cf da ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025cd:	8d 83 10 c9 fe ff    	lea    -0x136f0(%ebx),%eax
f01025d3:	50                   	push   %eax
f01025d4:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01025da:	50                   	push   %eax
f01025db:	68 fe 02 00 00       	push   $0x2fe
f01025e0:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01025e6:	50                   	push   %eax
f01025e7:	e8 ad da ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01025ec:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01025ef:	8d 83 38 c9 fe ff    	lea    -0x136c8(%ebx),%eax
f01025f5:	50                   	push   %eax
f01025f6:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01025fc:	50                   	push   %eax
f01025fd:	68 ff 02 00 00       	push   $0x2ff
f0102602:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102608:	50                   	push   %eax
f0102609:	e8 8b da ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f010260e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102611:	8d 83 0f d0 fe ff    	lea    -0x12ff1(%ebx),%eax
f0102617:	50                   	push   %eax
f0102618:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010261e:	50                   	push   %eax
f010261f:	68 00 03 00 00       	push   $0x300
f0102624:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010262a:	50                   	push   %eax
f010262b:	e8 69 da ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f0102630:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102633:	8d 83 20 d0 fe ff    	lea    -0x12fe0(%ebx),%eax
f0102639:	50                   	push   %eax
f010263a:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102640:	50                   	push   %eax
f0102641:	68 01 03 00 00       	push   $0x301
f0102646:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010264c:	50                   	push   %eax
f010264d:	e8 47 da ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102652:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102655:	8d 83 68 c9 fe ff    	lea    -0x13698(%ebx),%eax
f010265b:	50                   	push   %eax
f010265c:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102662:	50                   	push   %eax
f0102663:	68 04 03 00 00       	push   $0x304
f0102668:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010266e:	50                   	push   %eax
f010266f:	e8 25 da ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102674:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102677:	8d 83 a4 c9 fe ff    	lea    -0x1365c(%ebx),%eax
f010267d:	50                   	push   %eax
f010267e:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102684:	50                   	push   %eax
f0102685:	68 05 03 00 00       	push   $0x305
f010268a:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102690:	50                   	push   %eax
f0102691:	e8 03 da ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f0102696:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102699:	8d 83 31 d0 fe ff    	lea    -0x12fcf(%ebx),%eax
f010269f:	50                   	push   %eax
f01026a0:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01026a6:	50                   	push   %eax
f01026a7:	68 06 03 00 00       	push   $0x306
f01026ac:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01026b2:	50                   	push   %eax
f01026b3:	e8 e1 d9 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f01026b8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026bb:	8d 83 bd cf fe ff    	lea    -0x13043(%ebx),%eax
f01026c1:	50                   	push   %eax
f01026c2:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01026c8:	50                   	push   %eax
f01026c9:	68 09 03 00 00       	push   $0x309
f01026ce:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01026d4:	50                   	push   %eax
f01026d5:	e8 bf d9 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01026da:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026dd:	8d 83 68 c9 fe ff    	lea    -0x13698(%ebx),%eax
f01026e3:	50                   	push   %eax
f01026e4:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01026ea:	50                   	push   %eax
f01026eb:	68 0c 03 00 00       	push   $0x30c
f01026f0:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01026f6:	50                   	push   %eax
f01026f7:	e8 9d d9 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01026fc:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01026ff:	8d 83 a4 c9 fe ff    	lea    -0x1365c(%ebx),%eax
f0102705:	50                   	push   %eax
f0102706:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010270c:	50                   	push   %eax
f010270d:	68 0d 03 00 00       	push   $0x30d
f0102712:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102718:	50                   	push   %eax
f0102719:	e8 7b d9 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f010271e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102721:	8d 83 31 d0 fe ff    	lea    -0x12fcf(%ebx),%eax
f0102727:	50                   	push   %eax
f0102728:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010272e:	50                   	push   %eax
f010272f:	68 0e 03 00 00       	push   $0x30e
f0102734:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010273a:	50                   	push   %eax
f010273b:	e8 59 d9 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102740:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102743:	8d 83 bd cf fe ff    	lea    -0x13043(%ebx),%eax
f0102749:	50                   	push   %eax
f010274a:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102750:	50                   	push   %eax
f0102751:	68 12 03 00 00       	push   $0x312
f0102756:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010275c:	50                   	push   %eax
f010275d:	e8 37 d9 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102762:	50                   	push   %eax
f0102763:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102766:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f010276c:	50                   	push   %eax
f010276d:	68 15 03 00 00       	push   $0x315
f0102772:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102778:	50                   	push   %eax
f0102779:	e8 1b d9 ff ff       	call   f0100099 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010277e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102781:	8d 83 d4 c9 fe ff    	lea    -0x1362c(%ebx),%eax
f0102787:	50                   	push   %eax
f0102788:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010278e:	50                   	push   %eax
f010278f:	68 16 03 00 00       	push   $0x316
f0102794:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010279a:	50                   	push   %eax
f010279b:	e8 f9 d8 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01027a0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027a3:	8d 83 14 ca fe ff    	lea    -0x135ec(%ebx),%eax
f01027a9:	50                   	push   %eax
f01027aa:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01027b0:	50                   	push   %eax
f01027b1:	68 19 03 00 00       	push   $0x319
f01027b6:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01027bc:	50                   	push   %eax
f01027bd:	e8 d7 d8 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01027c2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027c5:	8d 83 a4 c9 fe ff    	lea    -0x1365c(%ebx),%eax
f01027cb:	50                   	push   %eax
f01027cc:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01027d2:	50                   	push   %eax
f01027d3:	68 1a 03 00 00       	push   $0x31a
f01027d8:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01027de:	50                   	push   %eax
f01027df:	e8 b5 d8 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01027e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01027e7:	8d 83 31 d0 fe ff    	lea    -0x12fcf(%ebx),%eax
f01027ed:	50                   	push   %eax
f01027ee:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01027f4:	50                   	push   %eax
f01027f5:	68 1b 03 00 00       	push   $0x31b
f01027fa:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102800:	50                   	push   %eax
f0102801:	e8 93 d8 ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102806:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102809:	8d 83 54 ca fe ff    	lea    -0x135ac(%ebx),%eax
f010280f:	50                   	push   %eax
f0102810:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102816:	50                   	push   %eax
f0102817:	68 1c 03 00 00       	push   $0x31c
f010281c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102822:	50                   	push   %eax
f0102823:	e8 71 d8 ff ff       	call   f0100099 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102828:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010282b:	8d 83 42 d0 fe ff    	lea    -0x12fbe(%ebx),%eax
f0102831:	50                   	push   %eax
f0102832:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102838:	50                   	push   %eax
f0102839:	68 1d 03 00 00       	push   $0x31d
f010283e:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102844:	50                   	push   %eax
f0102845:	e8 4f d8 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010284a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010284d:	8d 83 68 c9 fe ff    	lea    -0x13698(%ebx),%eax
f0102853:	50                   	push   %eax
f0102854:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010285a:	50                   	push   %eax
f010285b:	68 20 03 00 00       	push   $0x320
f0102860:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102866:	50                   	push   %eax
f0102867:	e8 2d d8 ff ff       	call   f0100099 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010286c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010286f:	8d 83 88 ca fe ff    	lea    -0x13578(%ebx),%eax
f0102875:	50                   	push   %eax
f0102876:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010287c:	50                   	push   %eax
f010287d:	68 21 03 00 00       	push   $0x321
f0102882:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102888:	50                   	push   %eax
f0102889:	e8 0b d8 ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010288e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102891:	8d 83 bc ca fe ff    	lea    -0x13544(%ebx),%eax
f0102897:	50                   	push   %eax
f0102898:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010289e:	50                   	push   %eax
f010289f:	68 22 03 00 00       	push   $0x322
f01028a4:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01028aa:	50                   	push   %eax
f01028ab:	e8 e9 d7 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01028b0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028b3:	8d 83 f4 ca fe ff    	lea    -0x1350c(%ebx),%eax
f01028b9:	50                   	push   %eax
f01028ba:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01028c0:	50                   	push   %eax
f01028c1:	68 25 03 00 00       	push   $0x325
f01028c6:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01028cc:	50                   	push   %eax
f01028cd:	e8 c7 d7 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01028d2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028d5:	8d 83 2c cb fe ff    	lea    -0x134d4(%ebx),%eax
f01028db:	50                   	push   %eax
f01028dc:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01028e2:	50                   	push   %eax
f01028e3:	68 28 03 00 00       	push   $0x328
f01028e8:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01028ee:	50                   	push   %eax
f01028ef:	e8 a5 d7 ff ff       	call   f0100099 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01028f4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01028f7:	8d 83 bc ca fe ff    	lea    -0x13544(%ebx),%eax
f01028fd:	50                   	push   %eax
f01028fe:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102904:	50                   	push   %eax
f0102905:	68 29 03 00 00       	push   $0x329
f010290a:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102910:	50                   	push   %eax
f0102911:	e8 83 d7 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102916:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102919:	8d 83 68 cb fe ff    	lea    -0x13498(%ebx),%eax
f010291f:	50                   	push   %eax
f0102920:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102926:	50                   	push   %eax
f0102927:	68 2c 03 00 00       	push   $0x32c
f010292c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102932:	50                   	push   %eax
f0102933:	e8 61 d7 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102938:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010293b:	8d 83 94 cb fe ff    	lea    -0x1346c(%ebx),%eax
f0102941:	50                   	push   %eax
f0102942:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102948:	50                   	push   %eax
f0102949:	68 2d 03 00 00       	push   $0x32d
f010294e:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102954:	50                   	push   %eax
f0102955:	e8 3f d7 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 2);
f010295a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010295d:	8d 83 58 d0 fe ff    	lea    -0x12fa8(%ebx),%eax
f0102963:	50                   	push   %eax
f0102964:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010296a:	50                   	push   %eax
f010296b:	68 2f 03 00 00       	push   $0x32f
f0102970:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102976:	50                   	push   %eax
f0102977:	e8 1d d7 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f010297c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010297f:	8d 83 69 d0 fe ff    	lea    -0x12f97(%ebx),%eax
f0102985:	50                   	push   %eax
f0102986:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010298c:	50                   	push   %eax
f010298d:	68 30 03 00 00       	push   $0x330
f0102992:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102998:	50                   	push   %eax
f0102999:	e8 fb d6 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f010299e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029a1:	8d 83 c4 cb fe ff    	lea    -0x1343c(%ebx),%eax
f01029a7:	50                   	push   %eax
f01029a8:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01029ae:	50                   	push   %eax
f01029af:	68 33 03 00 00       	push   $0x333
f01029b4:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01029ba:	50                   	push   %eax
f01029bb:	e8 d9 d6 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029c0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029c3:	8d 83 e8 cb fe ff    	lea    -0x13418(%ebx),%eax
f01029c9:	50                   	push   %eax
f01029ca:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01029d0:	50                   	push   %eax
f01029d1:	68 37 03 00 00       	push   $0x337
f01029d6:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01029dc:	50                   	push   %eax
f01029dd:	e8 b7 d6 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01029e2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01029e5:	8d 83 94 cb fe ff    	lea    -0x1346c(%ebx),%eax
f01029eb:	50                   	push   %eax
f01029ec:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01029f2:	50                   	push   %eax
f01029f3:	68 38 03 00 00       	push   $0x338
f01029f8:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01029fe:	50                   	push   %eax
f01029ff:	e8 95 d6 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f0102a04:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a07:	8d 83 0f d0 fe ff    	lea    -0x12ff1(%ebx),%eax
f0102a0d:	50                   	push   %eax
f0102a0e:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102a14:	50                   	push   %eax
f0102a15:	68 39 03 00 00       	push   $0x339
f0102a1a:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102a20:	50                   	push   %eax
f0102a21:	e8 73 d6 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102a26:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a29:	8d 83 69 d0 fe ff    	lea    -0x12f97(%ebx),%eax
f0102a2f:	50                   	push   %eax
f0102a30:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102a36:	50                   	push   %eax
f0102a37:	68 3a 03 00 00       	push   $0x33a
f0102a3c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102a42:	50                   	push   %eax
f0102a43:	e8 51 d6 ff ff       	call   f0100099 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102a48:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a4b:	8d 83 0c cc fe ff    	lea    -0x133f4(%ebx),%eax
f0102a51:	50                   	push   %eax
f0102a52:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102a58:	50                   	push   %eax
f0102a59:	68 3d 03 00 00       	push   $0x33d
f0102a5e:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102a64:	50                   	push   %eax
f0102a65:	e8 2f d6 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref);
f0102a6a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a6d:	8d 83 7a d0 fe ff    	lea    -0x12f86(%ebx),%eax
f0102a73:	50                   	push   %eax
f0102a74:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102a7a:	50                   	push   %eax
f0102a7b:	68 3e 03 00 00       	push   $0x33e
f0102a80:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102a86:	50                   	push   %eax
f0102a87:	e8 0d d6 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_link == NULL);
f0102a8c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102a8f:	8d 83 86 d0 fe ff    	lea    -0x12f7a(%ebx),%eax
f0102a95:	50                   	push   %eax
f0102a96:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102a9c:	50                   	push   %eax
f0102a9d:	68 3f 03 00 00       	push   $0x33f
f0102aa2:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102aa8:	50                   	push   %eax
f0102aa9:	e8 eb d5 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102aae:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ab1:	8d 83 e8 cb fe ff    	lea    -0x13418(%ebx),%eax
f0102ab7:	50                   	push   %eax
f0102ab8:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102abe:	50                   	push   %eax
f0102abf:	68 43 03 00 00       	push   $0x343
f0102ac4:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102aca:	50                   	push   %eax
f0102acb:	e8 c9 d5 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102ad0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ad3:	8d 83 44 cc fe ff    	lea    -0x133bc(%ebx),%eax
f0102ad9:	50                   	push   %eax
f0102ada:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102ae0:	50                   	push   %eax
f0102ae1:	68 44 03 00 00       	push   $0x344
f0102ae6:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102aec:	50                   	push   %eax
f0102aed:	e8 a7 d5 ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f0102af2:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102af5:	8d 83 9b d0 fe ff    	lea    -0x12f65(%ebx),%eax
f0102afb:	50                   	push   %eax
f0102afc:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102b02:	50                   	push   %eax
f0102b03:	68 45 03 00 00       	push   $0x345
f0102b08:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102b0e:	50                   	push   %eax
f0102b0f:	e8 85 d5 ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f0102b14:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b17:	8d 83 69 d0 fe ff    	lea    -0x12f97(%ebx),%eax
f0102b1d:	50                   	push   %eax
f0102b1e:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102b24:	50                   	push   %eax
f0102b25:	68 46 03 00 00       	push   $0x346
f0102b2a:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102b30:	50                   	push   %eax
f0102b31:	e8 63 d5 ff ff       	call   f0100099 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102b36:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b39:	8d 83 6c cc fe ff    	lea    -0x13394(%ebx),%eax
f0102b3f:	50                   	push   %eax
f0102b40:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102b46:	50                   	push   %eax
f0102b47:	68 49 03 00 00       	push   $0x349
f0102b4c:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102b52:	50                   	push   %eax
f0102b53:	e8 41 d5 ff ff       	call   f0100099 <_panic>
	assert(!page_alloc(0));
f0102b58:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b5b:	8d 83 bd cf fe ff    	lea    -0x13043(%ebx),%eax
f0102b61:	50                   	push   %eax
f0102b62:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102b68:	50                   	push   %eax
f0102b69:	68 4c 03 00 00       	push   $0x34c
f0102b6e:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102b74:	50                   	push   %eax
f0102b75:	e8 1f d5 ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b7a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b7d:	8d 83 10 c9 fe ff    	lea    -0x136f0(%ebx),%eax
f0102b83:	50                   	push   %eax
f0102b84:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102b8a:	50                   	push   %eax
f0102b8b:	68 4f 03 00 00       	push   $0x34f
f0102b90:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102b96:	50                   	push   %eax
f0102b97:	e8 fd d4 ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f0102b9c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102b9f:	8d 83 20 d0 fe ff    	lea    -0x12fe0(%ebx),%eax
f0102ba5:	50                   	push   %eax
f0102ba6:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102bac:	50                   	push   %eax
f0102bad:	68 51 03 00 00       	push   $0x351
f0102bb2:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102bb8:	50                   	push   %eax
f0102bb9:	e8 db d4 ff ff       	call   f0100099 <_panic>
f0102bbe:	52                   	push   %edx
f0102bbf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bc2:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0102bc8:	50                   	push   %eax
f0102bc9:	68 58 03 00 00       	push   $0x358
f0102bce:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102bd4:	50                   	push   %eax
f0102bd5:	e8 bf d4 ff ff       	call   f0100099 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102bda:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102bdd:	8d 83 ac d0 fe ff    	lea    -0x12f54(%ebx),%eax
f0102be3:	50                   	push   %eax
f0102be4:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102bea:	50                   	push   %eax
f0102beb:	68 59 03 00 00       	push   $0x359
f0102bf0:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102bf6:	50                   	push   %eax
f0102bf7:	e8 9d d4 ff ff       	call   f0100099 <_panic>
f0102bfc:	50                   	push   %eax
f0102bfd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c00:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0102c06:	50                   	push   %eax
f0102c07:	6a 52                	push   $0x52
f0102c09:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0102c0f:	50                   	push   %eax
f0102c10:	e8 84 d4 ff ff       	call   f0100099 <_panic>
f0102c15:	52                   	push   %edx
f0102c16:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c19:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0102c1f:	50                   	push   %eax
f0102c20:	6a 52                	push   $0x52
f0102c22:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0102c28:	50                   	push   %eax
f0102c29:	e8 6b d4 ff ff       	call   f0100099 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102c2e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c31:	8d 83 c4 d0 fe ff    	lea    -0x12f3c(%ebx),%eax
f0102c37:	50                   	push   %eax
f0102c38:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102c3e:	50                   	push   %eax
f0102c3f:	68 63 03 00 00       	push   $0x363
f0102c44:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102c4a:	50                   	push   %eax
f0102c4b:	e8 49 d4 ff ff       	call   f0100099 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c50:	50                   	push   %eax
f0102c51:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c54:	8d 83 b8 c7 fe ff    	lea    -0x13848(%ebx),%eax
f0102c5a:	50                   	push   %eax
f0102c5b:	68 b1 00 00 00       	push   $0xb1
f0102c60:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102c66:	50                   	push   %eax
f0102c67:	e8 2d d4 ff ff       	call   f0100099 <_panic>
f0102c6c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c6f:	ff b3 fc ff ff ff    	pushl  -0x4(%ebx)
f0102c75:	8d 83 b8 c7 fe ff    	lea    -0x13848(%ebx),%eax
f0102c7b:	50                   	push   %eax
f0102c7c:	68 b3 00 00 00       	push   $0xb3
f0102c81:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102c87:	50                   	push   %eax
f0102c88:	e8 0c d4 ff ff       	call   f0100099 <_panic>
f0102c8d:	ff 75 c0             	pushl  -0x40(%ebp)
f0102c90:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102c93:	8d 83 b8 c7 fe ff    	lea    -0x13848(%ebx),%eax
f0102c99:	50                   	push   %eax
f0102c9a:	68 a5 02 00 00       	push   $0x2a5
f0102c9f:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102ca5:	50                   	push   %eax
f0102ca6:	e8 ee d3 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102cab:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102cae:	8d 83 90 cc fe ff    	lea    -0x13370(%ebx),%eax
f0102cb4:	50                   	push   %eax
f0102cb5:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102cbb:	50                   	push   %eax
f0102cbc:	68 a5 02 00 00       	push   $0x2a5
f0102cc1:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102cc7:	50                   	push   %eax
f0102cc8:	e8 cc d3 ff ff       	call   f0100099 <_panic>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ccd:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0102cd0:	c1 e7 0c             	shl    $0xc,%edi
f0102cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102cd8:	eb 17                	jmp    f0102cf1 <mem_init+0x1715>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102cda:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102ce0:	89 f0                	mov    %esi,%eax
f0102ce2:	e8 8e e0 ff ff       	call   f0100d75 <check_va2pa>
f0102ce7:	39 c3                	cmp    %eax,%ebx
f0102ce9:	75 51                	jne    f0102d3c <mem_init+0x1760>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102ceb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102cf1:	39 fb                	cmp    %edi,%ebx
f0102cf3:	72 e5                	jb     f0102cda <mem_init+0x16fe>
f0102cf5:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102cfa:	8b 7d c8             	mov    -0x38(%ebp),%edi
f0102cfd:	81 c7 00 80 00 20    	add    $0x20008000,%edi
f0102d03:	89 da                	mov    %ebx,%edx
f0102d05:	89 f0                	mov    %esi,%eax
f0102d07:	e8 69 e0 ff ff       	call   f0100d75 <check_va2pa>
f0102d0c:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102d0f:	39 c2                	cmp    %eax,%edx
f0102d11:	75 4b                	jne    f0102d5e <mem_init+0x1782>
f0102d13:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102d19:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102d1f:	75 e2                	jne    f0102d03 <mem_init+0x1727>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102d21:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102d26:	89 f0                	mov    %esi,%eax
f0102d28:	e8 48 e0 ff ff       	call   f0100d75 <check_va2pa>
f0102d2d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102d30:	75 4e                	jne    f0102d80 <mem_init+0x17a4>
	for (i = 0; i < NPDENTRIES; i++) {
f0102d32:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d37:	e9 8f 00 00 00       	jmp    f0102dcb <mem_init+0x17ef>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d3c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d3f:	8d 83 c4 cc fe ff    	lea    -0x1333c(%ebx),%eax
f0102d45:	50                   	push   %eax
f0102d46:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102d4c:	50                   	push   %eax
f0102d4d:	68 aa 02 00 00       	push   $0x2aa
f0102d52:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102d58:	50                   	push   %eax
f0102d59:	e8 3b d3 ff ff       	call   f0100099 <_panic>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102d5e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d61:	8d 83 ec cc fe ff    	lea    -0x13314(%ebx),%eax
f0102d67:	50                   	push   %eax
f0102d68:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102d6e:	50                   	push   %eax
f0102d6f:	68 ae 02 00 00       	push   $0x2ae
f0102d74:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102d7a:	50                   	push   %eax
f0102d7b:	e8 19 d3 ff ff       	call   f0100099 <_panic>
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102d80:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102d83:	8d 83 34 cd fe ff    	lea    -0x132cc(%ebx),%eax
f0102d89:	50                   	push   %eax
f0102d8a:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102d90:	50                   	push   %eax
f0102d91:	68 af 02 00 00       	push   $0x2af
f0102d96:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102d9c:	50                   	push   %eax
f0102d9d:	e8 f7 d2 ff ff       	call   f0100099 <_panic>
			assert(pgdir[i] & PTE_P);
f0102da2:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f0102da6:	74 52                	je     f0102dfa <mem_init+0x181e>
	for (i = 0; i < NPDENTRIES; i++) {
f0102da8:	83 c0 01             	add    $0x1,%eax
f0102dab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102db0:	0f 87 bb 00 00 00    	ja     f0102e71 <mem_init+0x1895>
		switch (i) {
f0102db6:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102dbb:	72 0e                	jb     f0102dcb <mem_init+0x17ef>
f0102dbd:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102dc2:	76 de                	jbe    f0102da2 <mem_init+0x17c6>
f0102dc4:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102dc9:	74 d7                	je     f0102da2 <mem_init+0x17c6>
			if (i >= PDX(KERNBASE)) {
f0102dcb:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102dd0:	77 4a                	ja     f0102e1c <mem_init+0x1840>
				assert(pgdir[i] == 0);
f0102dd2:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102dd6:	74 d0                	je     f0102da8 <mem_init+0x17cc>
f0102dd8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102ddb:	8d 83 16 d1 fe ff    	lea    -0x12eea(%ebx),%eax
f0102de1:	50                   	push   %eax
f0102de2:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102de8:	50                   	push   %eax
f0102de9:	68 be 02 00 00       	push   $0x2be
f0102dee:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102df4:	50                   	push   %eax
f0102df5:	e8 9f d2 ff ff       	call   f0100099 <_panic>
			assert(pgdir[i] & PTE_P);
f0102dfa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102dfd:	8d 83 f4 d0 fe ff    	lea    -0x12f0c(%ebx),%eax
f0102e03:	50                   	push   %eax
f0102e04:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102e0a:	50                   	push   %eax
f0102e0b:	68 b7 02 00 00       	push   $0x2b7
f0102e10:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102e16:	50                   	push   %eax
f0102e17:	e8 7d d2 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102e1c:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0102e1f:	f6 c2 01             	test   $0x1,%dl
f0102e22:	74 2b                	je     f0102e4f <mem_init+0x1873>
				assert(pgdir[i] & PTE_W);
f0102e24:	f6 c2 02             	test   $0x2,%dl
f0102e27:	0f 85 7b ff ff ff    	jne    f0102da8 <mem_init+0x17cc>
f0102e2d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e30:	8d 83 05 d1 fe ff    	lea    -0x12efb(%ebx),%eax
f0102e36:	50                   	push   %eax
f0102e37:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102e3d:	50                   	push   %eax
f0102e3e:	68 bc 02 00 00       	push   $0x2bc
f0102e43:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102e49:	50                   	push   %eax
f0102e4a:	e8 4a d2 ff ff       	call   f0100099 <_panic>
				assert(pgdir[i] & PTE_P);
f0102e4f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e52:	8d 83 f4 d0 fe ff    	lea    -0x12f0c(%ebx),%eax
f0102e58:	50                   	push   %eax
f0102e59:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0102e5f:	50                   	push   %eax
f0102e60:	68 bb 02 00 00       	push   $0x2bb
f0102e65:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0102e6b:	50                   	push   %eax
f0102e6c:	e8 28 d2 ff ff       	call   f0100099 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102e71:	83 ec 0c             	sub    $0xc,%esp
f0102e74:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102e77:	8d 87 64 cd fe ff    	lea    -0x1329c(%edi),%eax
f0102e7d:	50                   	push   %eax
f0102e7e:	89 fb                	mov    %edi,%ebx
f0102e80:	e8 ee 04 00 00       	call   f0103373 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102e85:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102e8b:	8b 00                	mov    (%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f0102e8d:	83 c4 10             	add    $0x10,%esp
f0102e90:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e95:	0f 86 44 02 00 00    	jbe    f01030df <mem_init+0x1b03>
	return (physaddr_t)kva - KERNBASE;
f0102e9b:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ea0:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102ea3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ea8:	e8 45 df ff ff       	call   f0100df2 <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102ead:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102eb0:	83 e0 f3             	and    $0xfffffff3,%eax
f0102eb3:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102eb8:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102ebb:	83 ec 0c             	sub    $0xc,%esp
f0102ebe:	6a 00                	push   $0x0
f0102ec0:	e8 a4 e3 ff ff       	call   f0101269 <page_alloc>
f0102ec5:	89 c6                	mov    %eax,%esi
f0102ec7:	83 c4 10             	add    $0x10,%esp
f0102eca:	85 c0                	test   %eax,%eax
f0102ecc:	0f 84 29 02 00 00    	je     f01030fb <mem_init+0x1b1f>
	assert((pp1 = page_alloc(0)));
f0102ed2:	83 ec 0c             	sub    $0xc,%esp
f0102ed5:	6a 00                	push   $0x0
f0102ed7:	e8 8d e3 ff ff       	call   f0101269 <page_alloc>
f0102edc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102edf:	83 c4 10             	add    $0x10,%esp
f0102ee2:	85 c0                	test   %eax,%eax
f0102ee4:	0f 84 33 02 00 00    	je     f010311d <mem_init+0x1b41>
	assert((pp2 = page_alloc(0)));
f0102eea:	83 ec 0c             	sub    $0xc,%esp
f0102eed:	6a 00                	push   $0x0
f0102eef:	e8 75 e3 ff ff       	call   f0101269 <page_alloc>
f0102ef4:	89 c7                	mov    %eax,%edi
f0102ef6:	83 c4 10             	add    $0x10,%esp
f0102ef9:	85 c0                	test   %eax,%eax
f0102efb:	0f 84 3e 02 00 00    	je     f010313f <mem_init+0x1b63>
	page_free(pp0);
f0102f01:	83 ec 0c             	sub    $0xc,%esp
f0102f04:	56                   	push   %esi
f0102f05:	e8 e7 e3 ff ff       	call   f01012f1 <page_free>
	return (pp - pages) << PGSHIFT;
f0102f0a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f0d:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0102f13:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102f16:	2b 08                	sub    (%eax),%ecx
f0102f18:	89 c8                	mov    %ecx,%eax
f0102f1a:	c1 f8 03             	sar    $0x3,%eax
f0102f1d:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f20:	89 c1                	mov    %eax,%ecx
f0102f22:	c1 e9 0c             	shr    $0xc,%ecx
f0102f25:	83 c4 10             	add    $0x10,%esp
f0102f28:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f0102f2e:	3b 0a                	cmp    (%edx),%ecx
f0102f30:	0f 83 2b 02 00 00    	jae    f0103161 <mem_init+0x1b85>
	memset(page2kva(pp1), 1, PGSIZE);
f0102f36:	83 ec 04             	sub    $0x4,%esp
f0102f39:	68 00 10 00 00       	push   $0x1000
f0102f3e:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102f40:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f45:	50                   	push   %eax
f0102f46:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f49:	e8 36 10 00 00       	call   f0103f84 <memset>
	return (pp - pages) << PGSHIFT;
f0102f4e:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f51:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0102f57:	89 f9                	mov    %edi,%ecx
f0102f59:	2b 08                	sub    (%eax),%ecx
f0102f5b:	89 c8                	mov    %ecx,%eax
f0102f5d:	c1 f8 03             	sar    $0x3,%eax
f0102f60:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102f63:	89 c1                	mov    %eax,%ecx
f0102f65:	c1 e9 0c             	shr    $0xc,%ecx
f0102f68:	83 c4 10             	add    $0x10,%esp
f0102f6b:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f0102f71:	3b 0a                	cmp    (%edx),%ecx
f0102f73:	0f 83 fe 01 00 00    	jae    f0103177 <mem_init+0x1b9b>
	memset(page2kva(pp2), 2, PGSIZE);
f0102f79:	83 ec 04             	sub    $0x4,%esp
f0102f7c:	68 00 10 00 00       	push   $0x1000
f0102f81:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102f83:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102f88:	50                   	push   %eax
f0102f89:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102f8c:	e8 f3 0f 00 00       	call   f0103f84 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102f91:	6a 02                	push   $0x2
f0102f93:	68 00 10 00 00       	push   $0x1000
f0102f98:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0102f9b:	53                   	push   %ebx
f0102f9c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f9f:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102fa5:	ff 30                	pushl  (%eax)
f0102fa7:	e8 b8 e5 ff ff       	call   f0101564 <page_insert>
	assert(pp1->pp_ref == 1);
f0102fac:	83 c4 20             	add    $0x20,%esp
f0102faf:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102fb4:	0f 85 d3 01 00 00    	jne    f010318d <mem_init+0x1bb1>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102fba:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102fc1:	01 01 01 
f0102fc4:	0f 85 e5 01 00 00    	jne    f01031af <mem_init+0x1bd3>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102fca:	6a 02                	push   $0x2
f0102fcc:	68 00 10 00 00       	push   $0x1000
f0102fd1:	57                   	push   %edi
f0102fd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fd5:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0102fdb:	ff 30                	pushl  (%eax)
f0102fdd:	e8 82 e5 ff ff       	call   f0101564 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102fe2:	83 c4 10             	add    $0x10,%esp
f0102fe5:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102fec:	02 02 02 
f0102fef:	0f 85 dc 01 00 00    	jne    f01031d1 <mem_init+0x1bf5>
	assert(pp2->pp_ref == 1);
f0102ff5:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102ffa:	0f 85 f3 01 00 00    	jne    f01031f3 <mem_init+0x1c17>
	assert(pp1->pp_ref == 0);
f0103000:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103003:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0103008:	0f 85 07 02 00 00    	jne    f0103215 <mem_init+0x1c39>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010300e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103015:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0103018:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010301b:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f0103021:	89 f9                	mov    %edi,%ecx
f0103023:	2b 08                	sub    (%eax),%ecx
f0103025:	89 c8                	mov    %ecx,%eax
f0103027:	c1 f8 03             	sar    $0x3,%eax
f010302a:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f010302d:	89 c1                	mov    %eax,%ecx
f010302f:	c1 e9 0c             	shr    $0xc,%ecx
f0103032:	c7 c2 c8 a6 11 f0    	mov    $0xf011a6c8,%edx
f0103038:	3b 0a                	cmp    (%edx),%ecx
f010303a:	0f 83 f7 01 00 00    	jae    f0103237 <mem_init+0x1c5b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103040:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103047:	03 03 03 
f010304a:	0f 85 fd 01 00 00    	jne    f010324d <mem_init+0x1c71>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0103050:	83 ec 08             	sub    $0x8,%esp
f0103053:	68 00 10 00 00       	push   $0x1000
f0103058:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010305b:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f0103061:	ff 30                	pushl  (%eax)
f0103063:	e8 b7 e4 ff ff       	call   f010151f <page_remove>
	assert(pp2->pp_ref == 0);
f0103068:	83 c4 10             	add    $0x10,%esp
f010306b:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0103070:	0f 85 f9 01 00 00    	jne    f010326f <mem_init+0x1c93>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103076:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103079:	c7 c0 cc a6 11 f0    	mov    $0xf011a6cc,%eax
f010307f:	8b 08                	mov    (%eax),%ecx
f0103081:	8b 11                	mov    (%ecx),%edx
f0103083:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0103089:	c7 c0 d0 a6 11 f0    	mov    $0xf011a6d0,%eax
f010308f:	89 f7                	mov    %esi,%edi
f0103091:	2b 38                	sub    (%eax),%edi
f0103093:	89 f8                	mov    %edi,%eax
f0103095:	c1 f8 03             	sar    $0x3,%eax
f0103098:	c1 e0 0c             	shl    $0xc,%eax
f010309b:	39 c2                	cmp    %eax,%edx
f010309d:	0f 85 ee 01 00 00    	jne    f0103291 <mem_init+0x1cb5>
	kern_pgdir[0] = 0;
f01030a3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01030a9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01030ae:	0f 85 ff 01 00 00    	jne    f01032b3 <mem_init+0x1cd7>
	pp0->pp_ref = 0;
f01030b4:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f01030ba:	83 ec 0c             	sub    $0xc,%esp
f01030bd:	56                   	push   %esi
f01030be:	e8 2e e2 ff ff       	call   f01012f1 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01030c3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030c6:	8d 83 f8 cd fe ff    	lea    -0x13208(%ebx),%eax
f01030cc:	89 04 24             	mov    %eax,(%esp)
f01030cf:	e8 9f 02 00 00       	call   f0103373 <cprintf>
}
f01030d4:	83 c4 10             	add    $0x10,%esp
f01030d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030da:	5b                   	pop    %ebx
f01030db:	5e                   	pop    %esi
f01030dc:	5f                   	pop    %edi
f01030dd:	5d                   	pop    %ebp
f01030de:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030df:	50                   	push   %eax
f01030e0:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030e3:	8d 83 b8 c7 fe ff    	lea    -0x13848(%ebx),%eax
f01030e9:	50                   	push   %eax
f01030ea:	68 d5 00 00 00       	push   $0xd5
f01030ef:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01030f5:	50                   	push   %eax
f01030f6:	e8 9e cf ff ff       	call   f0100099 <_panic>
	assert((pp0 = page_alloc(0)));
f01030fb:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01030fe:	8d 83 12 cf fe ff    	lea    -0x130ee(%ebx),%eax
f0103104:	50                   	push   %eax
f0103105:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010310b:	50                   	push   %eax
f010310c:	68 7e 03 00 00       	push   $0x37e
f0103111:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0103117:	50                   	push   %eax
f0103118:	e8 7c cf ff ff       	call   f0100099 <_panic>
	assert((pp1 = page_alloc(0)));
f010311d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103120:	8d 83 28 cf fe ff    	lea    -0x130d8(%ebx),%eax
f0103126:	50                   	push   %eax
f0103127:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010312d:	50                   	push   %eax
f010312e:	68 7f 03 00 00       	push   $0x37f
f0103133:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0103139:	50                   	push   %eax
f010313a:	e8 5a cf ff ff       	call   f0100099 <_panic>
	assert((pp2 = page_alloc(0)));
f010313f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103142:	8d 83 3e cf fe ff    	lea    -0x130c2(%ebx),%eax
f0103148:	50                   	push   %eax
f0103149:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010314f:	50                   	push   %eax
f0103150:	68 80 03 00 00       	push   $0x380
f0103155:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010315b:	50                   	push   %eax
f010315c:	e8 38 cf ff ff       	call   f0100099 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103161:	50                   	push   %eax
f0103162:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f0103168:	50                   	push   %eax
f0103169:	6a 52                	push   $0x52
f010316b:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0103171:	50                   	push   %eax
f0103172:	e8 22 cf ff ff       	call   f0100099 <_panic>
f0103177:	50                   	push   %eax
f0103178:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f010317e:	50                   	push   %eax
f010317f:	6a 52                	push   $0x52
f0103181:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0103187:	50                   	push   %eax
f0103188:	e8 0c cf ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 1);
f010318d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103190:	8d 83 0f d0 fe ff    	lea    -0x12ff1(%ebx),%eax
f0103196:	50                   	push   %eax
f0103197:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010319d:	50                   	push   %eax
f010319e:	68 85 03 00 00       	push   $0x385
f01031a3:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01031a9:	50                   	push   %eax
f01031aa:	e8 ea ce ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01031af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031b2:	8d 83 84 cd fe ff    	lea    -0x1327c(%ebx),%eax
f01031b8:	50                   	push   %eax
f01031b9:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01031bf:	50                   	push   %eax
f01031c0:	68 86 03 00 00       	push   $0x386
f01031c5:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01031cb:	50                   	push   %eax
f01031cc:	e8 c8 ce ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031d1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031d4:	8d 83 a8 cd fe ff    	lea    -0x13258(%ebx),%eax
f01031da:	50                   	push   %eax
f01031db:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01031e1:	50                   	push   %eax
f01031e2:	68 88 03 00 00       	push   $0x388
f01031e7:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01031ed:	50                   	push   %eax
f01031ee:	e8 a6 ce ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 1);
f01031f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01031f6:	8d 83 31 d0 fe ff    	lea    -0x12fcf(%ebx),%eax
f01031fc:	50                   	push   %eax
f01031fd:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0103203:	50                   	push   %eax
f0103204:	68 89 03 00 00       	push   $0x389
f0103209:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010320f:	50                   	push   %eax
f0103210:	e8 84 ce ff ff       	call   f0100099 <_panic>
	assert(pp1->pp_ref == 0);
f0103215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103218:	8d 83 9b d0 fe ff    	lea    -0x12f65(%ebx),%eax
f010321e:	50                   	push   %eax
f010321f:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f0103225:	50                   	push   %eax
f0103226:	68 8a 03 00 00       	push   $0x38a
f010322b:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0103231:	50                   	push   %eax
f0103232:	e8 62 ce ff ff       	call   f0100099 <_panic>
f0103237:	50                   	push   %eax
f0103238:	8d 83 ac c6 fe ff    	lea    -0x13954(%ebx),%eax
f010323e:	50                   	push   %eax
f010323f:	6a 52                	push   $0x52
f0103241:	8d 83 30 ce fe ff    	lea    -0x131d0(%ebx),%eax
f0103247:	50                   	push   %eax
f0103248:	e8 4c ce ff ff       	call   f0100099 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010324d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103250:	8d 83 cc cd fe ff    	lea    -0x13234(%ebx),%eax
f0103256:	50                   	push   %eax
f0103257:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010325d:	50                   	push   %eax
f010325e:	68 8c 03 00 00       	push   $0x38c
f0103263:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f0103269:	50                   	push   %eax
f010326a:	e8 2a ce ff ff       	call   f0100099 <_panic>
	assert(pp2->pp_ref == 0);
f010326f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103272:	8d 83 69 d0 fe ff    	lea    -0x12f97(%ebx),%eax
f0103278:	50                   	push   %eax
f0103279:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f010327f:	50                   	push   %eax
f0103280:	68 8e 03 00 00       	push   $0x38e
f0103285:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f010328b:	50                   	push   %eax
f010328c:	e8 08 ce ff ff       	call   f0100099 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0103291:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103294:	8d 83 10 c9 fe ff    	lea    -0x136f0(%ebx),%eax
f010329a:	50                   	push   %eax
f010329b:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01032a1:	50                   	push   %eax
f01032a2:	68 91 03 00 00       	push   $0x391
f01032a7:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01032ad:	50                   	push   %eax
f01032ae:	e8 e6 cd ff ff       	call   f0100099 <_panic>
	assert(pp0->pp_ref == 1);
f01032b3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01032b6:	8d 83 20 d0 fe ff    	lea    -0x12fe0(%ebx),%eax
f01032bc:	50                   	push   %eax
f01032bd:	8d 83 4a ce fe ff    	lea    -0x131b6(%ebx),%eax
f01032c3:	50                   	push   %eax
f01032c4:	68 93 03 00 00       	push   $0x393
f01032c9:	8d 83 24 ce fe ff    	lea    -0x131dc(%ebx),%eax
f01032cf:	50                   	push   %eax
f01032d0:	e8 c4 cd ff ff       	call   f0100099 <_panic>

f01032d5 <tlb_invalidate>:
{
f01032d5:	55                   	push   %ebp
f01032d6:	89 e5                	mov    %esp,%ebp
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01032d8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032db:	0f 01 38             	invlpg (%eax)
}
f01032de:	5d                   	pop    %ebp
f01032df:	c3                   	ret    

f01032e0 <__x86.get_pc_thunk.dx>:
f01032e0:	8b 14 24             	mov    (%esp),%edx
f01032e3:	c3                   	ret    

f01032e4 <__x86.get_pc_thunk.cx>:
f01032e4:	8b 0c 24             	mov    (%esp),%ecx
f01032e7:	c3                   	ret    

f01032e8 <__x86.get_pc_thunk.di>:
f01032e8:	8b 3c 24             	mov    (%esp),%edi
f01032eb:	c3                   	ret    

f01032ec <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01032ec:	55                   	push   %ebp
f01032ed:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01032ef:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f2:	ba 70 00 00 00       	mov    $0x70,%edx
f01032f7:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01032f8:	ba 71 00 00 00       	mov    $0x71,%edx
f01032fd:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f01032fe:	0f b6 c0             	movzbl %al,%eax
}
f0103301:	5d                   	pop    %ebp
f0103302:	c3                   	ret    

f0103303 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103303:	55                   	push   %ebp
f0103304:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103306:	8b 45 08             	mov    0x8(%ebp),%eax
f0103309:	ba 70 00 00 00       	mov    $0x70,%edx
f010330e:	ee                   	out    %al,(%dx)
f010330f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103312:	ba 71 00 00 00       	mov    $0x71,%edx
f0103317:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103318:	5d                   	pop    %ebp
f0103319:	c3                   	ret    

f010331a <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010331a:	55                   	push   %ebp
f010331b:	89 e5                	mov    %esp,%ebp
f010331d:	53                   	push   %ebx
f010331e:	83 ec 10             	sub    $0x10,%esp
f0103321:	e8 29 ce ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103326:	81 c3 e6 4f 01 00    	add    $0x14fe6,%ebx
	cputchar(ch);
f010332c:	ff 75 08             	pushl  0x8(%ebp)
f010332f:	e8 92 d3 ff ff       	call   f01006c6 <cputchar>
	*cnt++;
}
f0103334:	83 c4 10             	add    $0x10,%esp
f0103337:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010333a:	c9                   	leave  
f010333b:	c3                   	ret    

f010333c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010333c:	55                   	push   %ebp
f010333d:	89 e5                	mov    %esp,%ebp
f010333f:	53                   	push   %ebx
f0103340:	83 ec 14             	sub    $0x14,%esp
f0103343:	e8 07 ce ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103348:	81 c3 c4 4f 01 00    	add    $0x14fc4,%ebx
	int cnt = 0;
f010334e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103355:	ff 75 0c             	pushl  0xc(%ebp)
f0103358:	ff 75 08             	pushl  0x8(%ebp)
f010335b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010335e:	50                   	push   %eax
f010335f:	8d 83 0e b0 fe ff    	lea    -0x14ff2(%ebx),%eax
f0103365:	50                   	push   %eax
f0103366:	e8 98 04 00 00       	call   f0103803 <vprintfmt>
	return cnt;
}
f010336b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010336e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103371:	c9                   	leave  
f0103372:	c3                   	ret    

f0103373 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103373:	55                   	push   %ebp
f0103374:	89 e5                	mov    %esp,%ebp
f0103376:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103379:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010337c:	50                   	push   %eax
f010337d:	ff 75 08             	pushl  0x8(%ebp)
f0103380:	e8 b7 ff ff ff       	call   f010333c <vcprintf>
	va_end(ap);

	return cnt;
}
f0103385:	c9                   	leave  
f0103386:	c3                   	ret    

f0103387 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103387:	55                   	push   %ebp
f0103388:	89 e5                	mov    %esp,%ebp
f010338a:	57                   	push   %edi
f010338b:	56                   	push   %esi
f010338c:	53                   	push   %ebx
f010338d:	83 ec 14             	sub    $0x14,%esp
f0103390:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103393:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103396:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103399:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010339c:	8b 32                	mov    (%edx),%esi
f010339e:	8b 01                	mov    (%ecx),%eax
f01033a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01033a3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01033aa:	eb 2f                	jmp    f01033db <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f01033ac:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f01033af:	39 c6                	cmp    %eax,%esi
f01033b1:	7f 49                	jg     f01033fc <stab_binsearch+0x75>
f01033b3:	0f b6 0a             	movzbl (%edx),%ecx
f01033b6:	83 ea 0c             	sub    $0xc,%edx
f01033b9:	39 f9                	cmp    %edi,%ecx
f01033bb:	75 ef                	jne    f01033ac <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01033bd:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01033c0:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01033c3:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01033c7:	3b 55 0c             	cmp    0xc(%ebp),%edx
f01033ca:	73 35                	jae    f0103401 <stab_binsearch+0x7a>
			*region_left = m;
f01033cc:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01033cf:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f01033d1:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f01033d4:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f01033db:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f01033de:	7f 4e                	jg     f010342e <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f01033e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01033e3:	01 f0                	add    %esi,%eax
f01033e5:	89 c3                	mov    %eax,%ebx
f01033e7:	c1 eb 1f             	shr    $0x1f,%ebx
f01033ea:	01 c3                	add    %eax,%ebx
f01033ec:	d1 fb                	sar    %ebx
f01033ee:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01033f1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01033f4:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f01033f8:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f01033fa:	eb b3                	jmp    f01033af <stab_binsearch+0x28>
			l = true_m + 1;
f01033fc:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f01033ff:	eb da                	jmp    f01033db <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0103401:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0103404:	76 14                	jbe    f010341a <stab_binsearch+0x93>
			*region_right = m - 1;
f0103406:	83 e8 01             	sub    $0x1,%eax
f0103409:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010340c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010340f:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0103411:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103418:	eb c1                	jmp    f01033db <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010341a:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010341d:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010341f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103423:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0103425:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010342c:	eb ad                	jmp    f01033db <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f010342e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103432:	74 16                	je     f010344a <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103434:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103437:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0103439:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010343c:	8b 0e                	mov    (%esi),%ecx
f010343e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103441:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0103444:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0103448:	eb 12                	jmp    f010345c <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f010344a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010344d:	8b 00                	mov    (%eax),%eax
f010344f:	83 e8 01             	sub    $0x1,%eax
f0103452:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103455:	89 07                	mov    %eax,(%edi)
f0103457:	eb 16                	jmp    f010346f <stab_binsearch+0xe8>
		     l--)
f0103459:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f010345c:	39 c1                	cmp    %eax,%ecx
f010345e:	7d 0a                	jge    f010346a <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0103460:	0f b6 1a             	movzbl (%edx),%ebx
f0103463:	83 ea 0c             	sub    $0xc,%edx
f0103466:	39 fb                	cmp    %edi,%ebx
f0103468:	75 ef                	jne    f0103459 <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f010346a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010346d:	89 07                	mov    %eax,(%edi)
	}
}
f010346f:	83 c4 14             	add    $0x14,%esp
f0103472:	5b                   	pop    %ebx
f0103473:	5e                   	pop    %esi
f0103474:	5f                   	pop    %edi
f0103475:	5d                   	pop    %ebp
f0103476:	c3                   	ret    

f0103477 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103477:	55                   	push   %ebp
f0103478:	89 e5                	mov    %esp,%ebp
f010347a:	57                   	push   %edi
f010347b:	56                   	push   %esi
f010347c:	53                   	push   %ebx
f010347d:	83 ec 3c             	sub    $0x3c,%esp
f0103480:	e8 ca cc ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103485:	81 c3 87 4e 01 00    	add    $0x14e87,%ebx
f010348b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010348e:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103491:	8d 83 24 d1 fe ff    	lea    -0x12edc(%ebx),%eax
f0103497:	89 06                	mov    %eax,(%esi)
	info->eip_line = 0;
f0103499:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01034a0:	89 46 08             	mov    %eax,0x8(%esi)
	info->eip_fn_namelen = 9;
f01034a3:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01034aa:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01034ad:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01034b4:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01034ba:	0f 86 37 01 00 00    	jbe    f01035f7 <debuginfo_eip+0x180>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01034c0:	c7 c0 4d c4 10 f0    	mov    $0xf010c44d,%eax
f01034c6:	39 83 f8 ff ff ff    	cmp    %eax,-0x8(%ebx)
f01034cc:	0f 86 04 02 00 00    	jbe    f01036d6 <debuginfo_eip+0x25f>
f01034d2:	c7 c0 4e e3 10 f0    	mov    $0xf010e34e,%eax
f01034d8:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f01034dc:	0f 85 fb 01 00 00    	jne    f01036dd <debuginfo_eip+0x266>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01034e2:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01034e9:	c7 c0 48 56 10 f0    	mov    $0xf0105648,%eax
f01034ef:	c7 c2 4c c4 10 f0    	mov    $0xf010c44c,%edx
f01034f5:	29 c2                	sub    %eax,%edx
f01034f7:	c1 fa 02             	sar    $0x2,%edx
f01034fa:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f0103500:	83 ea 01             	sub    $0x1,%edx
f0103503:	89 55 e0             	mov    %edx,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103506:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0103509:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010350c:	83 ec 08             	sub    $0x8,%esp
f010350f:	57                   	push   %edi
f0103510:	6a 64                	push   $0x64
f0103512:	e8 70 fe ff ff       	call   f0103387 <stab_binsearch>
	if (lfile == 0)
f0103517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010351a:	83 c4 10             	add    $0x10,%esp
f010351d:	85 c0                	test   %eax,%eax
f010351f:	0f 84 bf 01 00 00    	je     f01036e4 <debuginfo_eip+0x26d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103525:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103528:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010352b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010352e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0103531:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0103534:	83 ec 08             	sub    $0x8,%esp
f0103537:	57                   	push   %edi
f0103538:	6a 24                	push   $0x24
f010353a:	c7 c0 48 56 10 f0    	mov    $0xf0105648,%eax
f0103540:	e8 42 fe ff ff       	call   f0103387 <stab_binsearch>

	if (lfun <= rfun) {
f0103545:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103548:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010354b:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f010354e:	83 c4 10             	add    $0x10,%esp
f0103551:	39 c8                	cmp    %ecx,%eax
f0103553:	0f 8f b6 00 00 00    	jg     f010360f <debuginfo_eip+0x198>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103559:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010355c:	c7 c1 48 56 10 f0    	mov    $0xf0105648,%ecx
f0103562:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0103565:	8b 11                	mov    (%ecx),%edx
f0103567:	89 55 c0             	mov    %edx,-0x40(%ebp)
f010356a:	c7 c2 4e e3 10 f0    	mov    $0xf010e34e,%edx
f0103570:	81 ea 4d c4 10 f0    	sub    $0xf010c44d,%edx
f0103576:	39 55 c0             	cmp    %edx,-0x40(%ebp)
f0103579:	73 0c                	jae    f0103587 <debuginfo_eip+0x110>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010357b:	8b 55 c0             	mov    -0x40(%ebp),%edx
f010357e:	81 c2 4d c4 10 f0    	add    $0xf010c44d,%edx
f0103584:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103587:	8b 51 08             	mov    0x8(%ecx),%edx
f010358a:	89 56 10             	mov    %edx,0x10(%esi)
		addr -= info->eip_fn_addr;
f010358d:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f010358f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0103592:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103595:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103598:	83 ec 08             	sub    $0x8,%esp
f010359b:	6a 3a                	push   $0x3a
f010359d:	ff 76 08             	pushl  0x8(%esi)
f01035a0:	e8 c3 09 00 00       	call   f0103f68 <strfind>
f01035a5:	2b 46 08             	sub    0x8(%esi),%eax
f01035a8:	89 46 0c             	mov    %eax,0xc(%esi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01035ab:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01035ae:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01035b1:	83 c4 08             	add    $0x8,%esp
f01035b4:	57                   	push   %edi
f01035b5:	6a 44                	push   $0x44
f01035b7:	c7 c0 48 56 10 f0    	mov    $0xf0105648,%eax
f01035bd:	e8 c5 fd ff ff       	call   f0103387 <stab_binsearch>
	if(lline>rline){
f01035c2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01035c5:	83 c4 10             	add    $0x10,%esp
f01035c8:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f01035cb:	0f 8f 1a 01 00 00    	jg     f01036eb <debuginfo_eip+0x274>
		return -1;
	}
	else{
		info->eip_line=stabs[lline].n_desc;
f01035d1:	89 d0                	mov    %edx,%eax
f01035d3:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01035d6:	c1 e2 02             	shl    $0x2,%edx
f01035d9:	c7 c1 48 56 10 f0    	mov    $0xf0105648,%ecx
f01035df:	0f b7 7c 0a 06       	movzwl 0x6(%edx,%ecx,1),%edi
f01035e4:	89 7e 04             	mov    %edi,0x4(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01035e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01035ea:	8d 54 0a 04          	lea    0x4(%edx,%ecx,1),%edx
f01035ee:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f01035f2:	89 75 0c             	mov    %esi,0xc(%ebp)
f01035f5:	eb 36                	jmp    f010362d <debuginfo_eip+0x1b6>
  	        panic("User address");
f01035f7:	83 ec 04             	sub    $0x4,%esp
f01035fa:	8d 83 2e d1 fe ff    	lea    -0x12ed2(%ebx),%eax
f0103600:	50                   	push   %eax
f0103601:	6a 7f                	push   $0x7f
f0103603:	8d 83 3b d1 fe ff    	lea    -0x12ec5(%ebx),%eax
f0103609:	50                   	push   %eax
f010360a:	e8 8a ca ff ff       	call   f0100099 <_panic>
		info->eip_fn_addr = addr;
f010360f:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0103612:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103615:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0103618:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010361b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010361e:	e9 75 ff ff ff       	jmp    f0103598 <debuginfo_eip+0x121>
f0103623:	83 e8 01             	sub    $0x1,%eax
f0103626:	83 ea 0c             	sub    $0xc,%edx
f0103629:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f010362d:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0103630:	39 c7                	cmp    %eax,%edi
f0103632:	7f 24                	jg     f0103658 <debuginfo_eip+0x1e1>
	       && stabs[lline].n_type != N_SOL
f0103634:	0f b6 0a             	movzbl (%edx),%ecx
f0103637:	80 f9 84             	cmp    $0x84,%cl
f010363a:	74 46                	je     f0103682 <debuginfo_eip+0x20b>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010363c:	80 f9 64             	cmp    $0x64,%cl
f010363f:	75 e2                	jne    f0103623 <debuginfo_eip+0x1ac>
f0103641:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0103645:	74 dc                	je     f0103623 <debuginfo_eip+0x1ac>
f0103647:	8b 75 0c             	mov    0xc(%ebp),%esi
f010364a:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010364e:	74 3b                	je     f010368b <debuginfo_eip+0x214>
f0103650:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103653:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103656:	eb 33                	jmp    f010368b <debuginfo_eip+0x214>
f0103658:	8b 75 0c             	mov    0xc(%ebp),%esi
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010365b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010365e:	8b 7d d8             	mov    -0x28(%ebp),%edi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103661:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0103666:	39 fa                	cmp    %edi,%edx
f0103668:	0f 8d 89 00 00 00    	jge    f01036f7 <debuginfo_eip+0x280>
		for (lline = lfun + 1;
f010366e:	83 c2 01             	add    $0x1,%edx
f0103671:	89 d0                	mov    %edx,%eax
f0103673:	8d 0c 52             	lea    (%edx,%edx,2),%ecx
f0103676:	c7 c2 48 56 10 f0    	mov    $0xf0105648,%edx
f010367c:	8d 54 8a 04          	lea    0x4(%edx,%ecx,4),%edx
f0103680:	eb 3b                	jmp    f01036bd <debuginfo_eip+0x246>
f0103682:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103685:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0103689:	75 26                	jne    f01036b1 <debuginfo_eip+0x23a>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010368b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010368e:	c7 c0 48 56 10 f0    	mov    $0xf0105648,%eax
f0103694:	8b 14 90             	mov    (%eax,%edx,4),%edx
f0103697:	c7 c0 4e e3 10 f0    	mov    $0xf010e34e,%eax
f010369d:	81 e8 4d c4 10 f0    	sub    $0xf010c44d,%eax
f01036a3:	39 c2                	cmp    %eax,%edx
f01036a5:	73 b4                	jae    f010365b <debuginfo_eip+0x1e4>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01036a7:	81 c2 4d c4 10 f0    	add    $0xf010c44d,%edx
f01036ad:	89 16                	mov    %edx,(%esi)
f01036af:	eb aa                	jmp    f010365b <debuginfo_eip+0x1e4>
f01036b1:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01036b4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01036b7:	eb d2                	jmp    f010368b <debuginfo_eip+0x214>
			info->eip_fn_narg++;
f01036b9:	83 46 14 01          	addl   $0x1,0x14(%esi)
		for (lline = lfun + 1;
f01036bd:	39 c7                	cmp    %eax,%edi
f01036bf:	7e 31                	jle    f01036f2 <debuginfo_eip+0x27b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01036c1:	0f b6 0a             	movzbl (%edx),%ecx
f01036c4:	83 c0 01             	add    $0x1,%eax
f01036c7:	83 c2 0c             	add    $0xc,%edx
f01036ca:	80 f9 a0             	cmp    $0xa0,%cl
f01036cd:	74 ea                	je     f01036b9 <debuginfo_eip+0x242>
	return 0;
f01036cf:	b8 00 00 00 00       	mov    $0x0,%eax
f01036d4:	eb 21                	jmp    f01036f7 <debuginfo_eip+0x280>
		return -1;
f01036d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01036db:	eb 1a                	jmp    f01036f7 <debuginfo_eip+0x280>
f01036dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01036e2:	eb 13                	jmp    f01036f7 <debuginfo_eip+0x280>
		return -1;
f01036e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01036e9:	eb 0c                	jmp    f01036f7 <debuginfo_eip+0x280>
		return -1;
f01036eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01036f0:	eb 05                	jmp    f01036f7 <debuginfo_eip+0x280>
	return 0;
f01036f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01036fa:	5b                   	pop    %ebx
f01036fb:	5e                   	pop    %esi
f01036fc:	5f                   	pop    %edi
f01036fd:	5d                   	pop    %ebp
f01036fe:	c3                   	ret    

f01036ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01036ff:	55                   	push   %ebp
f0103700:	89 e5                	mov    %esp,%ebp
f0103702:	57                   	push   %edi
f0103703:	56                   	push   %esi
f0103704:	53                   	push   %ebx
f0103705:	83 ec 2c             	sub    $0x2c,%esp
f0103708:	e8 d7 fb ff ff       	call   f01032e4 <__x86.get_pc_thunk.cx>
f010370d:	81 c1 ff 4b 01 00    	add    $0x14bff,%ecx
f0103713:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0103716:	89 c7                	mov    %eax,%edi
f0103718:	89 d6                	mov    %edx,%esi
f010371a:	8b 45 08             	mov    0x8(%ebp),%eax
f010371d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103720:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103723:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103726:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103729:	bb 00 00 00 00       	mov    $0x0,%ebx
f010372e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
f0103731:	89 5d dc             	mov    %ebx,-0x24(%ebp)
f0103734:	39 d3                	cmp    %edx,%ebx
f0103736:	72 09                	jb     f0103741 <printnum+0x42>
f0103738:	39 45 10             	cmp    %eax,0x10(%ebp)
f010373b:	0f 87 83 00 00 00    	ja     f01037c4 <printnum+0xc5>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103741:	83 ec 0c             	sub    $0xc,%esp
f0103744:	ff 75 18             	pushl  0x18(%ebp)
f0103747:	8b 45 14             	mov    0x14(%ebp),%eax
f010374a:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010374d:	53                   	push   %ebx
f010374e:	ff 75 10             	pushl  0x10(%ebp)
f0103751:	83 ec 08             	sub    $0x8,%esp
f0103754:	ff 75 dc             	pushl  -0x24(%ebp)
f0103757:	ff 75 d8             	pushl  -0x28(%ebp)
f010375a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010375d:	ff 75 d0             	pushl  -0x30(%ebp)
f0103760:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103763:	e8 18 0a 00 00       	call   f0104180 <__udivdi3>
f0103768:	83 c4 18             	add    $0x18,%esp
f010376b:	52                   	push   %edx
f010376c:	50                   	push   %eax
f010376d:	89 f2                	mov    %esi,%edx
f010376f:	89 f8                	mov    %edi,%eax
f0103771:	e8 89 ff ff ff       	call   f01036ff <printnum>
f0103776:	83 c4 20             	add    $0x20,%esp
f0103779:	eb 13                	jmp    f010378e <printnum+0x8f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010377b:	83 ec 08             	sub    $0x8,%esp
f010377e:	56                   	push   %esi
f010377f:	ff 75 18             	pushl  0x18(%ebp)
f0103782:	ff d7                	call   *%edi
f0103784:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0103787:	83 eb 01             	sub    $0x1,%ebx
f010378a:	85 db                	test   %ebx,%ebx
f010378c:	7f ed                	jg     f010377b <printnum+0x7c>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f010378e:	83 ec 08             	sub    $0x8,%esp
f0103791:	56                   	push   %esi
f0103792:	83 ec 04             	sub    $0x4,%esp
f0103795:	ff 75 dc             	pushl  -0x24(%ebp)
f0103798:	ff 75 d8             	pushl  -0x28(%ebp)
f010379b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010379e:	ff 75 d0             	pushl  -0x30(%ebp)
f01037a1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01037a4:	89 f3                	mov    %esi,%ebx
f01037a6:	e8 f5 0a 00 00       	call   f01042a0 <__umoddi3>
f01037ab:	83 c4 14             	add    $0x14,%esp
f01037ae:	0f be 84 06 49 d1 fe 	movsbl -0x12eb7(%esi,%eax,1),%eax
f01037b5:	ff 
f01037b6:	50                   	push   %eax
f01037b7:	ff d7                	call   *%edi
}
f01037b9:	83 c4 10             	add    $0x10,%esp
f01037bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01037bf:	5b                   	pop    %ebx
f01037c0:	5e                   	pop    %esi
f01037c1:	5f                   	pop    %edi
f01037c2:	5d                   	pop    %ebp
f01037c3:	c3                   	ret    
f01037c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
f01037c7:	eb be                	jmp    f0103787 <printnum+0x88>

f01037c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01037c9:	55                   	push   %ebp
f01037ca:	89 e5                	mov    %esp,%ebp
f01037cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01037cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01037d3:	8b 10                	mov    (%eax),%edx
f01037d5:	3b 50 04             	cmp    0x4(%eax),%edx
f01037d8:	73 0a                	jae    f01037e4 <sprintputch+0x1b>
		*b->buf++ = ch;
f01037da:	8d 4a 01             	lea    0x1(%edx),%ecx
f01037dd:	89 08                	mov    %ecx,(%eax)
f01037df:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e2:	88 02                	mov    %al,(%edx)
}
f01037e4:	5d                   	pop    %ebp
f01037e5:	c3                   	ret    

f01037e6 <printfmt>:
{
f01037e6:	55                   	push   %ebp
f01037e7:	89 e5                	mov    %esp,%ebp
f01037e9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01037ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01037ef:	50                   	push   %eax
f01037f0:	ff 75 10             	pushl  0x10(%ebp)
f01037f3:	ff 75 0c             	pushl  0xc(%ebp)
f01037f6:	ff 75 08             	pushl  0x8(%ebp)
f01037f9:	e8 05 00 00 00       	call   f0103803 <vprintfmt>
}
f01037fe:	83 c4 10             	add    $0x10,%esp
f0103801:	c9                   	leave  
f0103802:	c3                   	ret    

f0103803 <vprintfmt>:
{
f0103803:	55                   	push   %ebp
f0103804:	89 e5                	mov    %esp,%ebp
f0103806:	57                   	push   %edi
f0103807:	56                   	push   %esi
f0103808:	53                   	push   %ebx
f0103809:	83 ec 2c             	sub    $0x2c,%esp
f010380c:	e8 3e c9 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103811:	81 c3 fb 4a 01 00    	add    $0x14afb,%ebx
f0103817:	8b 75 0c             	mov    0xc(%ebp),%esi
f010381a:	8b 7d 10             	mov    0x10(%ebp),%edi
f010381d:	e9 c3 03 00 00       	jmp    f0103be5 <.L35+0x48>
		padc = ' ';
f0103822:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0103826:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f010382d:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
		width = -1;
f0103834:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010383b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103840:	89 4d d0             	mov    %ecx,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0103843:	8d 47 01             	lea    0x1(%edi),%eax
f0103846:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103849:	0f b6 17             	movzbl (%edi),%edx
f010384c:	8d 42 dd             	lea    -0x23(%edx),%eax
f010384f:	3c 55                	cmp    $0x55,%al
f0103851:	0f 87 16 04 00 00    	ja     f0103c6d <.L22>
f0103857:	0f b6 c0             	movzbl %al,%eax
f010385a:	89 d9                	mov    %ebx,%ecx
f010385c:	03 8c 83 d4 d1 fe ff 	add    -0x12e2c(%ebx,%eax,4),%ecx
f0103863:	ff e1                	jmp    *%ecx

f0103865 <.L69>:
f0103865:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0103868:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f010386c:	eb d5                	jmp    f0103843 <vprintfmt+0x40>

f010386e <.L28>:
		switch (ch = *(unsigned char *) fmt++) {
f010386e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0103871:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103875:	eb cc                	jmp    f0103843 <vprintfmt+0x40>

f0103877 <.L29>:
		switch (ch = *(unsigned char *) fmt++) {
f0103877:	0f b6 d2             	movzbl %dl,%edx
f010387a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f010387d:	b8 00 00 00 00       	mov    $0x0,%eax
				precision = precision * 10 + ch - '0';
f0103882:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103885:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103889:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010388c:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010388f:	83 f9 09             	cmp    $0x9,%ecx
f0103892:	77 55                	ja     f01038e9 <.L23+0xf>
			for (precision = 0; ; ++fmt) {
f0103894:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0103897:	eb e9                	jmp    f0103882 <.L29+0xb>

f0103899 <.L26>:
			precision = va_arg(ap, int);
f0103899:	8b 45 14             	mov    0x14(%ebp),%eax
f010389c:	8b 00                	mov    (%eax),%eax
f010389e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01038a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01038a4:	8d 40 04             	lea    0x4(%eax),%eax
f01038a7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01038aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f01038ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f01038b1:	79 90                	jns    f0103843 <vprintfmt+0x40>
				width = precision, precision = -1;
f01038b3:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01038b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01038b9:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f01038c0:	eb 81                	jmp    f0103843 <vprintfmt+0x40>

f01038c2 <.L27>:
f01038c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038c5:	85 c0                	test   %eax,%eax
f01038c7:	ba 00 00 00 00       	mov    $0x0,%edx
f01038cc:	0f 49 d0             	cmovns %eax,%edx
f01038cf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01038d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01038d5:	e9 69 ff ff ff       	jmp    f0103843 <vprintfmt+0x40>

f01038da <.L23>:
f01038da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01038dd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f01038e4:	e9 5a ff ff ff       	jmp    f0103843 <vprintfmt+0x40>
f01038e9:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01038ec:	eb bf                	jmp    f01038ad <.L26+0x14>

f01038ee <.L33>:
			lflag++;
f01038ee:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01038f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01038f5:	e9 49 ff ff ff       	jmp    f0103843 <vprintfmt+0x40>

f01038fa <.L30>:
			putch(va_arg(ap, int), putdat);
f01038fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01038fd:	8d 78 04             	lea    0x4(%eax),%edi
f0103900:	83 ec 08             	sub    $0x8,%esp
f0103903:	56                   	push   %esi
f0103904:	ff 30                	pushl  (%eax)
f0103906:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103909:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f010390c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f010390f:	e9 ce 02 00 00       	jmp    f0103be2 <.L35+0x45>

f0103914 <.L32>:
			err = va_arg(ap, int);
f0103914:	8b 45 14             	mov    0x14(%ebp),%eax
f0103917:	8d 78 04             	lea    0x4(%eax),%edi
f010391a:	8b 00                	mov    (%eax),%eax
f010391c:	99                   	cltd   
f010391d:	31 d0                	xor    %edx,%eax
f010391f:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103921:	83 f8 06             	cmp    $0x6,%eax
f0103924:	7f 27                	jg     f010394d <.L32+0x39>
f0103926:	8b 94 83 50 1d 00 00 	mov    0x1d50(%ebx,%eax,4),%edx
f010392d:	85 d2                	test   %edx,%edx
f010392f:	74 1c                	je     f010394d <.L32+0x39>
				printfmt(putch, putdat, "%s", p);
f0103931:	52                   	push   %edx
f0103932:	8d 83 5c ce fe ff    	lea    -0x131a4(%ebx),%eax
f0103938:	50                   	push   %eax
f0103939:	56                   	push   %esi
f010393a:	ff 75 08             	pushl  0x8(%ebp)
f010393d:	e8 a4 fe ff ff       	call   f01037e6 <printfmt>
f0103942:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103945:	89 7d 14             	mov    %edi,0x14(%ebp)
f0103948:	e9 95 02 00 00       	jmp    f0103be2 <.L35+0x45>
				printfmt(putch, putdat, "error %d", err);
f010394d:	50                   	push   %eax
f010394e:	8d 83 61 d1 fe ff    	lea    -0x12e9f(%ebx),%eax
f0103954:	50                   	push   %eax
f0103955:	56                   	push   %esi
f0103956:	ff 75 08             	pushl  0x8(%ebp)
f0103959:	e8 88 fe ff ff       	call   f01037e6 <printfmt>
f010395e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0103961:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0103964:	e9 79 02 00 00       	jmp    f0103be2 <.L35+0x45>

f0103969 <.L36>:
			if ((p = va_arg(ap, char *)) == NULL)
f0103969:	8b 45 14             	mov    0x14(%ebp),%eax
f010396c:	83 c0 04             	add    $0x4,%eax
f010396f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103972:	8b 45 14             	mov    0x14(%ebp),%eax
f0103975:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103977:	85 ff                	test   %edi,%edi
f0103979:	8d 83 5a d1 fe ff    	lea    -0x12ea6(%ebx),%eax
f010397f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103982:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103986:	0f 8e b5 00 00 00    	jle    f0103a41 <.L36+0xd8>
f010398c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103990:	75 08                	jne    f010399a <.L36+0x31>
f0103992:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103995:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103998:	eb 6d                	jmp    f0103a07 <.L36+0x9e>
				for (width -= strnlen(p, precision); width > 0; width--)
f010399a:	83 ec 08             	sub    $0x8,%esp
f010399d:	ff 75 cc             	pushl  -0x34(%ebp)
f01039a0:	57                   	push   %edi
f01039a1:	e8 7e 04 00 00       	call   f0103e24 <strnlen>
f01039a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01039a9:	29 c2                	sub    %eax,%edx
f01039ab:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01039ae:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f01039b1:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f01039b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01039b8:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01039bb:	89 d7                	mov    %edx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f01039bd:	eb 10                	jmp    f01039cf <.L36+0x66>
					putch(padc, putdat);
f01039bf:	83 ec 08             	sub    $0x8,%esp
f01039c2:	56                   	push   %esi
f01039c3:	ff 75 e0             	pushl  -0x20(%ebp)
f01039c6:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01039c9:	83 ef 01             	sub    $0x1,%edi
f01039cc:	83 c4 10             	add    $0x10,%esp
f01039cf:	85 ff                	test   %edi,%edi
f01039d1:	7f ec                	jg     f01039bf <.L36+0x56>
f01039d3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01039d6:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01039d9:	85 d2                	test   %edx,%edx
f01039db:	b8 00 00 00 00       	mov    $0x0,%eax
f01039e0:	0f 49 c2             	cmovns %edx,%eax
f01039e3:	29 c2                	sub    %eax,%edx
f01039e5:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01039e8:	89 75 0c             	mov    %esi,0xc(%ebp)
f01039eb:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01039ee:	eb 17                	jmp    f0103a07 <.L36+0x9e>
				if (altflag && (ch < ' ' || ch > '~'))
f01039f0:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01039f4:	75 30                	jne    f0103a26 <.L36+0xbd>
					putch(ch, putdat);
f01039f6:	83 ec 08             	sub    $0x8,%esp
f01039f9:	ff 75 0c             	pushl  0xc(%ebp)
f01039fc:	50                   	push   %eax
f01039fd:	ff 55 08             	call   *0x8(%ebp)
f0103a00:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103a03:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
f0103a07:	83 c7 01             	add    $0x1,%edi
f0103a0a:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f0103a0e:	0f be c2             	movsbl %dl,%eax
f0103a11:	85 c0                	test   %eax,%eax
f0103a13:	74 52                	je     f0103a67 <.L36+0xfe>
f0103a15:	85 f6                	test   %esi,%esi
f0103a17:	78 d7                	js     f01039f0 <.L36+0x87>
f0103a19:	83 ee 01             	sub    $0x1,%esi
f0103a1c:	79 d2                	jns    f01039f0 <.L36+0x87>
f0103a1e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103a21:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103a24:	eb 32                	jmp    f0103a58 <.L36+0xef>
				if (altflag && (ch < ' ' || ch > '~'))
f0103a26:	0f be d2             	movsbl %dl,%edx
f0103a29:	83 ea 20             	sub    $0x20,%edx
f0103a2c:	83 fa 5e             	cmp    $0x5e,%edx
f0103a2f:	76 c5                	jbe    f01039f6 <.L36+0x8d>
					putch('?', putdat);
f0103a31:	83 ec 08             	sub    $0x8,%esp
f0103a34:	ff 75 0c             	pushl  0xc(%ebp)
f0103a37:	6a 3f                	push   $0x3f
f0103a39:	ff 55 08             	call   *0x8(%ebp)
f0103a3c:	83 c4 10             	add    $0x10,%esp
f0103a3f:	eb c2                	jmp    f0103a03 <.L36+0x9a>
f0103a41:	89 75 0c             	mov    %esi,0xc(%ebp)
f0103a44:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0103a47:	eb be                	jmp    f0103a07 <.L36+0x9e>
				putch(' ', putdat);
f0103a49:	83 ec 08             	sub    $0x8,%esp
f0103a4c:	56                   	push   %esi
f0103a4d:	6a 20                	push   $0x20
f0103a4f:	ff 55 08             	call   *0x8(%ebp)
			for (; width > 0; width--)
f0103a52:	83 ef 01             	sub    $0x1,%edi
f0103a55:	83 c4 10             	add    $0x10,%esp
f0103a58:	85 ff                	test   %edi,%edi
f0103a5a:	7f ed                	jg     f0103a49 <.L36+0xe0>
			if ((p = va_arg(ap, char *)) == NULL)
f0103a5c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103a5f:	89 45 14             	mov    %eax,0x14(%ebp)
f0103a62:	e9 7b 01 00 00       	jmp    f0103be2 <.L35+0x45>
f0103a67:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0103a6a:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103a6d:	eb e9                	jmp    f0103a58 <.L36+0xef>

f0103a6f <.L31>:
f0103a6f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103a72:	83 f9 01             	cmp    $0x1,%ecx
f0103a75:	7e 40                	jle    f0103ab7 <.L31+0x48>
		return va_arg(*ap, long long);
f0103a77:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a7a:	8b 50 04             	mov    0x4(%eax),%edx
f0103a7d:	8b 00                	mov    (%eax),%eax
f0103a7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a82:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103a85:	8b 45 14             	mov    0x14(%ebp),%eax
f0103a88:	8d 40 08             	lea    0x8(%eax),%eax
f0103a8b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0103a8e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103a92:	79 55                	jns    f0103ae9 <.L31+0x7a>
				putch('-', putdat);
f0103a94:	83 ec 08             	sub    $0x8,%esp
f0103a97:	56                   	push   %esi
f0103a98:	6a 2d                	push   $0x2d
f0103a9a:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103a9d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103aa0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103aa3:	f7 da                	neg    %edx
f0103aa5:	83 d1 00             	adc    $0x0,%ecx
f0103aa8:	f7 d9                	neg    %ecx
f0103aaa:	83 c4 10             	add    $0x10,%esp
			base = 10;
f0103aad:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ab2:	e9 10 01 00 00       	jmp    f0103bc7 <.L35+0x2a>
	else if (lflag)
f0103ab7:	85 c9                	test   %ecx,%ecx
f0103ab9:	75 17                	jne    f0103ad2 <.L31+0x63>
		return va_arg(*ap, int);
f0103abb:	8b 45 14             	mov    0x14(%ebp),%eax
f0103abe:	8b 00                	mov    (%eax),%eax
f0103ac0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ac3:	99                   	cltd   
f0103ac4:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103ac7:	8b 45 14             	mov    0x14(%ebp),%eax
f0103aca:	8d 40 04             	lea    0x4(%eax),%eax
f0103acd:	89 45 14             	mov    %eax,0x14(%ebp)
f0103ad0:	eb bc                	jmp    f0103a8e <.L31+0x1f>
		return va_arg(*ap, long);
f0103ad2:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ad5:	8b 00                	mov    (%eax),%eax
f0103ad7:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103ada:	99                   	cltd   
f0103adb:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103ade:	8b 45 14             	mov    0x14(%ebp),%eax
f0103ae1:	8d 40 04             	lea    0x4(%eax),%eax
f0103ae4:	89 45 14             	mov    %eax,0x14(%ebp)
f0103ae7:	eb a5                	jmp    f0103a8e <.L31+0x1f>
			num = getint(&ap, lflag);
f0103ae9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103aec:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0103aef:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103af4:	e9 ce 00 00 00       	jmp    f0103bc7 <.L35+0x2a>

f0103af9 <.L37>:
f0103af9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103afc:	83 f9 01             	cmp    $0x1,%ecx
f0103aff:	7e 18                	jle    f0103b19 <.L37+0x20>
		return va_arg(*ap, unsigned long long);
f0103b01:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b04:	8b 10                	mov    (%eax),%edx
f0103b06:	8b 48 04             	mov    0x4(%eax),%ecx
f0103b09:	8d 40 08             	lea    0x8(%eax),%eax
f0103b0c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103b0f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103b14:	e9 ae 00 00 00       	jmp    f0103bc7 <.L35+0x2a>
	else if (lflag)
f0103b19:	85 c9                	test   %ecx,%ecx
f0103b1b:	75 1a                	jne    f0103b37 <.L37+0x3e>
		return va_arg(*ap, unsigned int);
f0103b1d:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b20:	8b 10                	mov    (%eax),%edx
f0103b22:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103b27:	8d 40 04             	lea    0x4(%eax),%eax
f0103b2a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103b2d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103b32:	e9 90 00 00 00       	jmp    f0103bc7 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0103b37:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b3a:	8b 10                	mov    (%eax),%edx
f0103b3c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103b41:	8d 40 04             	lea    0x4(%eax),%eax
f0103b44:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0103b47:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103b4c:	eb 79                	jmp    f0103bc7 <.L35+0x2a>

f0103b4e <.L34>:
f0103b4e:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103b51:	83 f9 01             	cmp    $0x1,%ecx
f0103b54:	7e 15                	jle    f0103b6b <.L34+0x1d>
		return va_arg(*ap, unsigned long long);
f0103b56:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b59:	8b 10                	mov    (%eax),%edx
f0103b5b:	8b 48 04             	mov    0x4(%eax),%ecx
f0103b5e:	8d 40 08             	lea    0x8(%eax),%eax
f0103b61:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103b64:	b8 08 00 00 00       	mov    $0x8,%eax
f0103b69:	eb 5c                	jmp    f0103bc7 <.L35+0x2a>
	else if (lflag)
f0103b6b:	85 c9                	test   %ecx,%ecx
f0103b6d:	75 17                	jne    f0103b86 <.L34+0x38>
		return va_arg(*ap, unsigned int);
f0103b6f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b72:	8b 10                	mov    (%eax),%edx
f0103b74:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103b79:	8d 40 04             	lea    0x4(%eax),%eax
f0103b7c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103b7f:	b8 08 00 00 00       	mov    $0x8,%eax
f0103b84:	eb 41                	jmp    f0103bc7 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0103b86:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b89:	8b 10                	mov    (%eax),%edx
f0103b8b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103b90:	8d 40 04             	lea    0x4(%eax),%eax
f0103b93:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0103b96:	b8 08 00 00 00       	mov    $0x8,%eax
f0103b9b:	eb 2a                	jmp    f0103bc7 <.L35+0x2a>

f0103b9d <.L35>:
			putch('0', putdat);
f0103b9d:	83 ec 08             	sub    $0x8,%esp
f0103ba0:	56                   	push   %esi
f0103ba1:	6a 30                	push   $0x30
f0103ba3:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103ba6:	83 c4 08             	add    $0x8,%esp
f0103ba9:	56                   	push   %esi
f0103baa:	6a 78                	push   $0x78
f0103bac:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
f0103baf:	8b 45 14             	mov    0x14(%ebp),%eax
f0103bb2:	8b 10                	mov    (%eax),%edx
f0103bb4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0103bb9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0103bbc:	8d 40 04             	lea    0x4(%eax),%eax
f0103bbf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103bc2:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0103bc7:	83 ec 0c             	sub    $0xc,%esp
f0103bca:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103bce:	57                   	push   %edi
f0103bcf:	ff 75 e0             	pushl  -0x20(%ebp)
f0103bd2:	50                   	push   %eax
f0103bd3:	51                   	push   %ecx
f0103bd4:	52                   	push   %edx
f0103bd5:	89 f2                	mov    %esi,%edx
f0103bd7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bda:	e8 20 fb ff ff       	call   f01036ff <printnum>
			break;
f0103bdf:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f0103be2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103be5:	83 c7 01             	add    $0x1,%edi
f0103be8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103bec:	83 f8 25             	cmp    $0x25,%eax
f0103bef:	0f 84 2d fc ff ff    	je     f0103822 <vprintfmt+0x1f>
			if (ch == '\0')
f0103bf5:	85 c0                	test   %eax,%eax
f0103bf7:	0f 84 91 00 00 00    	je     f0103c8e <.L22+0x21>
			putch(ch, putdat);
f0103bfd:	83 ec 08             	sub    $0x8,%esp
f0103c00:	56                   	push   %esi
f0103c01:	50                   	push   %eax
f0103c02:	ff 55 08             	call   *0x8(%ebp)
f0103c05:	83 c4 10             	add    $0x10,%esp
f0103c08:	eb db                	jmp    f0103be5 <.L35+0x48>

f0103c0a <.L38>:
f0103c0a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
	if (lflag >= 2)
f0103c0d:	83 f9 01             	cmp    $0x1,%ecx
f0103c10:	7e 15                	jle    f0103c27 <.L38+0x1d>
		return va_arg(*ap, unsigned long long);
f0103c12:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c15:	8b 10                	mov    (%eax),%edx
f0103c17:	8b 48 04             	mov    0x4(%eax),%ecx
f0103c1a:	8d 40 08             	lea    0x8(%eax),%eax
f0103c1d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103c20:	b8 10 00 00 00       	mov    $0x10,%eax
f0103c25:	eb a0                	jmp    f0103bc7 <.L35+0x2a>
	else if (lflag)
f0103c27:	85 c9                	test   %ecx,%ecx
f0103c29:	75 17                	jne    f0103c42 <.L38+0x38>
		return va_arg(*ap, unsigned int);
f0103c2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c2e:	8b 10                	mov    (%eax),%edx
f0103c30:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103c35:	8d 40 04             	lea    0x4(%eax),%eax
f0103c38:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103c3b:	b8 10 00 00 00       	mov    $0x10,%eax
f0103c40:	eb 85                	jmp    f0103bc7 <.L35+0x2a>
		return va_arg(*ap, unsigned long);
f0103c42:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c45:	8b 10                	mov    (%eax),%edx
f0103c47:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103c4c:	8d 40 04             	lea    0x4(%eax),%eax
f0103c4f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103c52:	b8 10 00 00 00       	mov    $0x10,%eax
f0103c57:	e9 6b ff ff ff       	jmp    f0103bc7 <.L35+0x2a>

f0103c5c <.L25>:
			putch(ch, putdat);
f0103c5c:	83 ec 08             	sub    $0x8,%esp
f0103c5f:	56                   	push   %esi
f0103c60:	6a 25                	push   $0x25
f0103c62:	ff 55 08             	call   *0x8(%ebp)
			break;
f0103c65:	83 c4 10             	add    $0x10,%esp
f0103c68:	e9 75 ff ff ff       	jmp    f0103be2 <.L35+0x45>

f0103c6d <.L22>:
			putch('%', putdat);
f0103c6d:	83 ec 08             	sub    $0x8,%esp
f0103c70:	56                   	push   %esi
f0103c71:	6a 25                	push   $0x25
f0103c73:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103c76:	83 c4 10             	add    $0x10,%esp
f0103c79:	89 f8                	mov    %edi,%eax
f0103c7b:	eb 03                	jmp    f0103c80 <.L22+0x13>
f0103c7d:	83 e8 01             	sub    $0x1,%eax
f0103c80:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0103c84:	75 f7                	jne    f0103c7d <.L22+0x10>
f0103c86:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103c89:	e9 54 ff ff ff       	jmp    f0103be2 <.L35+0x45>
}
f0103c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103c91:	5b                   	pop    %ebx
f0103c92:	5e                   	pop    %esi
f0103c93:	5f                   	pop    %edi
f0103c94:	5d                   	pop    %ebp
f0103c95:	c3                   	ret    

f0103c96 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103c96:	55                   	push   %ebp
f0103c97:	89 e5                	mov    %esp,%ebp
f0103c99:	53                   	push   %ebx
f0103c9a:	83 ec 14             	sub    $0x14,%esp
f0103c9d:	e8 ad c4 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103ca2:	81 c3 6a 46 01 00    	add    $0x1466a,%ebx
f0103ca8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cab:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103cae:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103cb1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103cb5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103cb8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103cbf:	85 c0                	test   %eax,%eax
f0103cc1:	74 2b                	je     f0103cee <vsnprintf+0x58>
f0103cc3:	85 d2                	test   %edx,%edx
f0103cc5:	7e 27                	jle    f0103cee <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103cc7:	ff 75 14             	pushl  0x14(%ebp)
f0103cca:	ff 75 10             	pushl  0x10(%ebp)
f0103ccd:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103cd0:	50                   	push   %eax
f0103cd1:	8d 83 bd b4 fe ff    	lea    -0x14b43(%ebx),%eax
f0103cd7:	50                   	push   %eax
f0103cd8:	e8 26 fb ff ff       	call   f0103803 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103cdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103ce0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ce6:	83 c4 10             	add    $0x10,%esp
}
f0103ce9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103cec:	c9                   	leave  
f0103ced:	c3                   	ret    
		return -E_INVAL;
f0103cee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103cf3:	eb f4                	jmp    f0103ce9 <vsnprintf+0x53>

f0103cf5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103cf5:	55                   	push   %ebp
f0103cf6:	89 e5                	mov    %esp,%ebp
f0103cf8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103cfb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103cfe:	50                   	push   %eax
f0103cff:	ff 75 10             	pushl  0x10(%ebp)
f0103d02:	ff 75 0c             	pushl  0xc(%ebp)
f0103d05:	ff 75 08             	pushl  0x8(%ebp)
f0103d08:	e8 89 ff ff ff       	call   f0103c96 <vsnprintf>
	va_end(ap);

	return rc;
}
f0103d0d:	c9                   	leave  
f0103d0e:	c3                   	ret    

f0103d0f <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103d0f:	55                   	push   %ebp
f0103d10:	89 e5                	mov    %esp,%ebp
f0103d12:	57                   	push   %edi
f0103d13:	56                   	push   %esi
f0103d14:	53                   	push   %ebx
f0103d15:	83 ec 1c             	sub    $0x1c,%esp
f0103d18:	e8 32 c4 ff ff       	call   f010014f <__x86.get_pc_thunk.bx>
f0103d1d:	81 c3 ef 45 01 00    	add    $0x145ef,%ebx
f0103d23:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103d26:	85 c0                	test   %eax,%eax
f0103d28:	74 13                	je     f0103d3d <readline+0x2e>
		cprintf("%s", prompt);
f0103d2a:	83 ec 08             	sub    $0x8,%esp
f0103d2d:	50                   	push   %eax
f0103d2e:	8d 83 5c ce fe ff    	lea    -0x131a4(%ebx),%eax
f0103d34:	50                   	push   %eax
f0103d35:	e8 39 f6 ff ff       	call   f0103373 <cprintf>
f0103d3a:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103d3d:	83 ec 0c             	sub    $0xc,%esp
f0103d40:	6a 00                	push   $0x0
f0103d42:	e8 a0 c9 ff ff       	call   f01006e7 <iscons>
f0103d47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103d4a:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0103d4d:	bf 00 00 00 00       	mov    $0x0,%edi
f0103d52:	eb 46                	jmp    f0103d9a <readline+0x8b>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f0103d54:	83 ec 08             	sub    $0x8,%esp
f0103d57:	50                   	push   %eax
f0103d58:	8d 83 2c d3 fe ff    	lea    -0x12cd4(%ebx),%eax
f0103d5e:	50                   	push   %eax
f0103d5f:	e8 0f f6 ff ff       	call   f0103373 <cprintf>
			return NULL;
f0103d64:	83 c4 10             	add    $0x10,%esp
f0103d67:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0103d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103d6f:	5b                   	pop    %ebx
f0103d70:	5e                   	pop    %esi
f0103d71:	5f                   	pop    %edi
f0103d72:	5d                   	pop    %ebp
f0103d73:	c3                   	ret    
			if (echoing)
f0103d74:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103d78:	75 05                	jne    f0103d7f <readline+0x70>
			i--;
f0103d7a:	83 ef 01             	sub    $0x1,%edi
f0103d7d:	eb 1b                	jmp    f0103d9a <readline+0x8b>
				cputchar('\b');
f0103d7f:	83 ec 0c             	sub    $0xc,%esp
f0103d82:	6a 08                	push   $0x8
f0103d84:	e8 3d c9 ff ff       	call   f01006c6 <cputchar>
f0103d89:	83 c4 10             	add    $0x10,%esp
f0103d8c:	eb ec                	jmp    f0103d7a <readline+0x6b>
			buf[i++] = c;
f0103d8e:	89 f0                	mov    %esi,%eax
f0103d90:	88 84 3b b4 1f 00 00 	mov    %al,0x1fb4(%ebx,%edi,1)
f0103d97:	8d 7f 01             	lea    0x1(%edi),%edi
		c = getchar();
f0103d9a:	e8 37 c9 ff ff       	call   f01006d6 <getchar>
f0103d9f:	89 c6                	mov    %eax,%esi
		if (c < 0) {
f0103da1:	85 c0                	test   %eax,%eax
f0103da3:	78 af                	js     f0103d54 <readline+0x45>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103da5:	83 f8 08             	cmp    $0x8,%eax
f0103da8:	0f 94 c2             	sete   %dl
f0103dab:	83 f8 7f             	cmp    $0x7f,%eax
f0103dae:	0f 94 c0             	sete   %al
f0103db1:	08 c2                	or     %al,%dl
f0103db3:	74 04                	je     f0103db9 <readline+0xaa>
f0103db5:	85 ff                	test   %edi,%edi
f0103db7:	7f bb                	jg     f0103d74 <readline+0x65>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103db9:	83 fe 1f             	cmp    $0x1f,%esi
f0103dbc:	7e 1c                	jle    f0103dda <readline+0xcb>
f0103dbe:	81 ff fe 03 00 00    	cmp    $0x3fe,%edi
f0103dc4:	7f 14                	jg     f0103dda <readline+0xcb>
			if (echoing)
f0103dc6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103dca:	74 c2                	je     f0103d8e <readline+0x7f>
				cputchar(c);
f0103dcc:	83 ec 0c             	sub    $0xc,%esp
f0103dcf:	56                   	push   %esi
f0103dd0:	e8 f1 c8 ff ff       	call   f01006c6 <cputchar>
f0103dd5:	83 c4 10             	add    $0x10,%esp
f0103dd8:	eb b4                	jmp    f0103d8e <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
f0103dda:	83 fe 0a             	cmp    $0xa,%esi
f0103ddd:	74 05                	je     f0103de4 <readline+0xd5>
f0103ddf:	83 fe 0d             	cmp    $0xd,%esi
f0103de2:	75 b6                	jne    f0103d9a <readline+0x8b>
			if (echoing)
f0103de4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103de8:	75 13                	jne    f0103dfd <readline+0xee>
			buf[i] = 0;
f0103dea:	c6 84 3b b4 1f 00 00 	movb   $0x0,0x1fb4(%ebx,%edi,1)
f0103df1:	00 
			return buf;
f0103df2:	8d 83 b4 1f 00 00    	lea    0x1fb4(%ebx),%eax
f0103df8:	e9 6f ff ff ff       	jmp    f0103d6c <readline+0x5d>
				cputchar('\n');
f0103dfd:	83 ec 0c             	sub    $0xc,%esp
f0103e00:	6a 0a                	push   $0xa
f0103e02:	e8 bf c8 ff ff       	call   f01006c6 <cputchar>
f0103e07:	83 c4 10             	add    $0x10,%esp
f0103e0a:	eb de                	jmp    f0103dea <readline+0xdb>

f0103e0c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103e0c:	55                   	push   %ebp
f0103e0d:	89 e5                	mov    %esp,%ebp
f0103e0f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103e12:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e17:	eb 03                	jmp    f0103e1c <strlen+0x10>
		n++;
f0103e19:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f0103e1c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103e20:	75 f7                	jne    f0103e19 <strlen+0xd>
	return n;
}
f0103e22:	5d                   	pop    %ebp
f0103e23:	c3                   	ret    

f0103e24 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103e24:	55                   	push   %ebp
f0103e25:	89 e5                	mov    %esp,%ebp
f0103e27:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103e2a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103e2d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103e32:	eb 03                	jmp    f0103e37 <strnlen+0x13>
		n++;
f0103e34:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103e37:	39 d0                	cmp    %edx,%eax
f0103e39:	74 06                	je     f0103e41 <strnlen+0x1d>
f0103e3b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0103e3f:	75 f3                	jne    f0103e34 <strnlen+0x10>
	return n;
}
f0103e41:	5d                   	pop    %ebp
f0103e42:	c3                   	ret    

f0103e43 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103e43:	55                   	push   %ebp
f0103e44:	89 e5                	mov    %esp,%ebp
f0103e46:	53                   	push   %ebx
f0103e47:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103e4d:	89 c2                	mov    %eax,%edx
f0103e4f:	83 c1 01             	add    $0x1,%ecx
f0103e52:	83 c2 01             	add    $0x1,%edx
f0103e55:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103e59:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103e5c:	84 db                	test   %bl,%bl
f0103e5e:	75 ef                	jne    f0103e4f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103e60:	5b                   	pop    %ebx
f0103e61:	5d                   	pop    %ebp
f0103e62:	c3                   	ret    

f0103e63 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103e63:	55                   	push   %ebp
f0103e64:	89 e5                	mov    %esp,%ebp
f0103e66:	53                   	push   %ebx
f0103e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103e6a:	53                   	push   %ebx
f0103e6b:	e8 9c ff ff ff       	call   f0103e0c <strlen>
f0103e70:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103e73:	ff 75 0c             	pushl  0xc(%ebp)
f0103e76:	01 d8                	add    %ebx,%eax
f0103e78:	50                   	push   %eax
f0103e79:	e8 c5 ff ff ff       	call   f0103e43 <strcpy>
	return dst;
}
f0103e7e:	89 d8                	mov    %ebx,%eax
f0103e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103e83:	c9                   	leave  
f0103e84:	c3                   	ret    

f0103e85 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103e85:	55                   	push   %ebp
f0103e86:	89 e5                	mov    %esp,%ebp
f0103e88:	56                   	push   %esi
f0103e89:	53                   	push   %ebx
f0103e8a:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103e90:	89 f3                	mov    %esi,%ebx
f0103e92:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103e95:	89 f2                	mov    %esi,%edx
f0103e97:	eb 0f                	jmp    f0103ea8 <strncpy+0x23>
		*dst++ = *src;
f0103e99:	83 c2 01             	add    $0x1,%edx
f0103e9c:	0f b6 01             	movzbl (%ecx),%eax
f0103e9f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103ea2:	80 39 01             	cmpb   $0x1,(%ecx)
f0103ea5:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0103ea8:	39 da                	cmp    %ebx,%edx
f0103eaa:	75 ed                	jne    f0103e99 <strncpy+0x14>
	}
	return ret;
}
f0103eac:	89 f0                	mov    %esi,%eax
f0103eae:	5b                   	pop    %ebx
f0103eaf:	5e                   	pop    %esi
f0103eb0:	5d                   	pop    %ebp
f0103eb1:	c3                   	ret    

f0103eb2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103eb2:	55                   	push   %ebp
f0103eb3:	89 e5                	mov    %esp,%ebp
f0103eb5:	56                   	push   %esi
f0103eb6:	53                   	push   %ebx
f0103eb7:	8b 75 08             	mov    0x8(%ebp),%esi
f0103eba:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103ebd:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103ec0:	89 f0                	mov    %esi,%eax
f0103ec2:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103ec6:	85 c9                	test   %ecx,%ecx
f0103ec8:	75 0b                	jne    f0103ed5 <strlcpy+0x23>
f0103eca:	eb 17                	jmp    f0103ee3 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103ecc:	83 c2 01             	add    $0x1,%edx
f0103ecf:	83 c0 01             	add    $0x1,%eax
f0103ed2:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0103ed5:	39 d8                	cmp    %ebx,%eax
f0103ed7:	74 07                	je     f0103ee0 <strlcpy+0x2e>
f0103ed9:	0f b6 0a             	movzbl (%edx),%ecx
f0103edc:	84 c9                	test   %cl,%cl
f0103ede:	75 ec                	jne    f0103ecc <strlcpy+0x1a>
		*dst = '\0';
f0103ee0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0103ee3:	29 f0                	sub    %esi,%eax
}
f0103ee5:	5b                   	pop    %ebx
f0103ee6:	5e                   	pop    %esi
f0103ee7:	5d                   	pop    %ebp
f0103ee8:	c3                   	ret    

f0103ee9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103ee9:	55                   	push   %ebp
f0103eea:	89 e5                	mov    %esp,%ebp
f0103eec:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103eef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103ef2:	eb 06                	jmp    f0103efa <strcmp+0x11>
		p++, q++;
f0103ef4:	83 c1 01             	add    $0x1,%ecx
f0103ef7:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f0103efa:	0f b6 01             	movzbl (%ecx),%eax
f0103efd:	84 c0                	test   %al,%al
f0103eff:	74 04                	je     f0103f05 <strcmp+0x1c>
f0103f01:	3a 02                	cmp    (%edx),%al
f0103f03:	74 ef                	je     f0103ef4 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103f05:	0f b6 c0             	movzbl %al,%eax
f0103f08:	0f b6 12             	movzbl (%edx),%edx
f0103f0b:	29 d0                	sub    %edx,%eax
}
f0103f0d:	5d                   	pop    %ebp
f0103f0e:	c3                   	ret    

f0103f0f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103f0f:	55                   	push   %ebp
f0103f10:	89 e5                	mov    %esp,%ebp
f0103f12:	53                   	push   %ebx
f0103f13:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f16:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103f19:	89 c3                	mov    %eax,%ebx
f0103f1b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0103f1e:	eb 06                	jmp    f0103f26 <strncmp+0x17>
		n--, p++, q++;
f0103f20:	83 c0 01             	add    $0x1,%eax
f0103f23:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0103f26:	39 d8                	cmp    %ebx,%eax
f0103f28:	74 16                	je     f0103f40 <strncmp+0x31>
f0103f2a:	0f b6 08             	movzbl (%eax),%ecx
f0103f2d:	84 c9                	test   %cl,%cl
f0103f2f:	74 04                	je     f0103f35 <strncmp+0x26>
f0103f31:	3a 0a                	cmp    (%edx),%cl
f0103f33:	74 eb                	je     f0103f20 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103f35:	0f b6 00             	movzbl (%eax),%eax
f0103f38:	0f b6 12             	movzbl (%edx),%edx
f0103f3b:	29 d0                	sub    %edx,%eax
}
f0103f3d:	5b                   	pop    %ebx
f0103f3e:	5d                   	pop    %ebp
f0103f3f:	c3                   	ret    
		return 0;
f0103f40:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f45:	eb f6                	jmp    f0103f3d <strncmp+0x2e>

f0103f47 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103f47:	55                   	push   %ebp
f0103f48:	89 e5                	mov    %esp,%ebp
f0103f4a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f4d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103f51:	0f b6 10             	movzbl (%eax),%edx
f0103f54:	84 d2                	test   %dl,%dl
f0103f56:	74 09                	je     f0103f61 <strchr+0x1a>
		if (*s == c)
f0103f58:	38 ca                	cmp    %cl,%dl
f0103f5a:	74 0a                	je     f0103f66 <strchr+0x1f>
	for (; *s; s++)
f0103f5c:	83 c0 01             	add    $0x1,%eax
f0103f5f:	eb f0                	jmp    f0103f51 <strchr+0xa>
			return (char *) s;
	return 0;
f0103f61:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103f66:	5d                   	pop    %ebp
f0103f67:	c3                   	ret    

f0103f68 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103f68:	55                   	push   %ebp
f0103f69:	89 e5                	mov    %esp,%ebp
f0103f6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f6e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103f72:	eb 03                	jmp    f0103f77 <strfind+0xf>
f0103f74:	83 c0 01             	add    $0x1,%eax
f0103f77:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0103f7a:	38 ca                	cmp    %cl,%dl
f0103f7c:	74 04                	je     f0103f82 <strfind+0x1a>
f0103f7e:	84 d2                	test   %dl,%dl
f0103f80:	75 f2                	jne    f0103f74 <strfind+0xc>
			break;
	return (char *) s;
}
f0103f82:	5d                   	pop    %ebp
f0103f83:	c3                   	ret    

f0103f84 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103f84:	55                   	push   %ebp
f0103f85:	89 e5                	mov    %esp,%ebp
f0103f87:	57                   	push   %edi
f0103f88:	56                   	push   %esi
f0103f89:	53                   	push   %ebx
f0103f8a:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103f8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103f90:	85 c9                	test   %ecx,%ecx
f0103f92:	74 13                	je     f0103fa7 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103f94:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103f9a:	75 05                	jne    f0103fa1 <memset+0x1d>
f0103f9c:	f6 c1 03             	test   $0x3,%cl
f0103f9f:	74 0d                	je     f0103fae <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103fa1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103fa4:	fc                   	cld    
f0103fa5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103fa7:	89 f8                	mov    %edi,%eax
f0103fa9:	5b                   	pop    %ebx
f0103faa:	5e                   	pop    %esi
f0103fab:	5f                   	pop    %edi
f0103fac:	5d                   	pop    %ebp
f0103fad:	c3                   	ret    
		c &= 0xFF;
f0103fae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103fb2:	89 d3                	mov    %edx,%ebx
f0103fb4:	c1 e3 08             	shl    $0x8,%ebx
f0103fb7:	89 d0                	mov    %edx,%eax
f0103fb9:	c1 e0 18             	shl    $0x18,%eax
f0103fbc:	89 d6                	mov    %edx,%esi
f0103fbe:	c1 e6 10             	shl    $0x10,%esi
f0103fc1:	09 f0                	or     %esi,%eax
f0103fc3:	09 c2                	or     %eax,%edx
f0103fc5:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0103fc7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0103fca:	89 d0                	mov    %edx,%eax
f0103fcc:	fc                   	cld    
f0103fcd:	f3 ab                	rep stos %eax,%es:(%edi)
f0103fcf:	eb d6                	jmp    f0103fa7 <memset+0x23>

f0103fd1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103fd1:	55                   	push   %ebp
f0103fd2:	89 e5                	mov    %esp,%ebp
f0103fd4:	57                   	push   %edi
f0103fd5:	56                   	push   %esi
f0103fd6:	8b 45 08             	mov    0x8(%ebp),%eax
f0103fd9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103fdc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103fdf:	39 c6                	cmp    %eax,%esi
f0103fe1:	73 35                	jae    f0104018 <memmove+0x47>
f0103fe3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103fe6:	39 c2                	cmp    %eax,%edx
f0103fe8:	76 2e                	jbe    f0104018 <memmove+0x47>
		s += n;
		d += n;
f0103fea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103fed:	89 d6                	mov    %edx,%esi
f0103fef:	09 fe                	or     %edi,%esi
f0103ff1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103ff7:	74 0c                	je     f0104005 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103ff9:	83 ef 01             	sub    $0x1,%edi
f0103ffc:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0103fff:	fd                   	std    
f0104000:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104002:	fc                   	cld    
f0104003:	eb 21                	jmp    f0104026 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104005:	f6 c1 03             	test   $0x3,%cl
f0104008:	75 ef                	jne    f0103ff9 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010400a:	83 ef 04             	sub    $0x4,%edi
f010400d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104010:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0104013:	fd                   	std    
f0104014:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104016:	eb ea                	jmp    f0104002 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104018:	89 f2                	mov    %esi,%edx
f010401a:	09 c2                	or     %eax,%edx
f010401c:	f6 c2 03             	test   $0x3,%dl
f010401f:	74 09                	je     f010402a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104021:	89 c7                	mov    %eax,%edi
f0104023:	fc                   	cld    
f0104024:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104026:	5e                   	pop    %esi
f0104027:	5f                   	pop    %edi
f0104028:	5d                   	pop    %ebp
f0104029:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010402a:	f6 c1 03             	test   $0x3,%cl
f010402d:	75 f2                	jne    f0104021 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010402f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0104032:	89 c7                	mov    %eax,%edi
f0104034:	fc                   	cld    
f0104035:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104037:	eb ed                	jmp    f0104026 <memmove+0x55>

f0104039 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104039:	55                   	push   %ebp
f010403a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010403c:	ff 75 10             	pushl  0x10(%ebp)
f010403f:	ff 75 0c             	pushl  0xc(%ebp)
f0104042:	ff 75 08             	pushl  0x8(%ebp)
f0104045:	e8 87 ff ff ff       	call   f0103fd1 <memmove>
}
f010404a:	c9                   	leave  
f010404b:	c3                   	ret    

f010404c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010404c:	55                   	push   %ebp
f010404d:	89 e5                	mov    %esp,%ebp
f010404f:	56                   	push   %esi
f0104050:	53                   	push   %ebx
f0104051:	8b 45 08             	mov    0x8(%ebp),%eax
f0104054:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104057:	89 c6                	mov    %eax,%esi
f0104059:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010405c:	39 f0                	cmp    %esi,%eax
f010405e:	74 1c                	je     f010407c <memcmp+0x30>
		if (*s1 != *s2)
f0104060:	0f b6 08             	movzbl (%eax),%ecx
f0104063:	0f b6 1a             	movzbl (%edx),%ebx
f0104066:	38 d9                	cmp    %bl,%cl
f0104068:	75 08                	jne    f0104072 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f010406a:	83 c0 01             	add    $0x1,%eax
f010406d:	83 c2 01             	add    $0x1,%edx
f0104070:	eb ea                	jmp    f010405c <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f0104072:	0f b6 c1             	movzbl %cl,%eax
f0104075:	0f b6 db             	movzbl %bl,%ebx
f0104078:	29 d8                	sub    %ebx,%eax
f010407a:	eb 05                	jmp    f0104081 <memcmp+0x35>
	}

	return 0;
f010407c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104081:	5b                   	pop    %ebx
f0104082:	5e                   	pop    %esi
f0104083:	5d                   	pop    %ebp
f0104084:	c3                   	ret    

f0104085 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104085:	55                   	push   %ebp
f0104086:	89 e5                	mov    %esp,%ebp
f0104088:	8b 45 08             	mov    0x8(%ebp),%eax
f010408b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010408e:	89 c2                	mov    %eax,%edx
f0104090:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104093:	39 d0                	cmp    %edx,%eax
f0104095:	73 09                	jae    f01040a0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104097:	38 08                	cmp    %cl,(%eax)
f0104099:	74 05                	je     f01040a0 <memfind+0x1b>
	for (; s < ends; s++)
f010409b:	83 c0 01             	add    $0x1,%eax
f010409e:	eb f3                	jmp    f0104093 <memfind+0xe>
			break;
	return (void *) s;
}
f01040a0:	5d                   	pop    %ebp
f01040a1:	c3                   	ret    

f01040a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01040a2:	55                   	push   %ebp
f01040a3:	89 e5                	mov    %esp,%ebp
f01040a5:	57                   	push   %edi
f01040a6:	56                   	push   %esi
f01040a7:	53                   	push   %ebx
f01040a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01040ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01040ae:	eb 03                	jmp    f01040b3 <strtol+0x11>
		s++;
f01040b0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f01040b3:	0f b6 01             	movzbl (%ecx),%eax
f01040b6:	3c 20                	cmp    $0x20,%al
f01040b8:	74 f6                	je     f01040b0 <strtol+0xe>
f01040ba:	3c 09                	cmp    $0x9,%al
f01040bc:	74 f2                	je     f01040b0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f01040be:	3c 2b                	cmp    $0x2b,%al
f01040c0:	74 2e                	je     f01040f0 <strtol+0x4e>
	int neg = 0;
f01040c2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f01040c7:	3c 2d                	cmp    $0x2d,%al
f01040c9:	74 2f                	je     f01040fa <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01040cb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01040d1:	75 05                	jne    f01040d8 <strtol+0x36>
f01040d3:	80 39 30             	cmpb   $0x30,(%ecx)
f01040d6:	74 2c                	je     f0104104 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01040d8:	85 db                	test   %ebx,%ebx
f01040da:	75 0a                	jne    f01040e6 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01040dc:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f01040e1:	80 39 30             	cmpb   $0x30,(%ecx)
f01040e4:	74 28                	je     f010410e <strtol+0x6c>
		base = 10;
f01040e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01040eb:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01040ee:	eb 50                	jmp    f0104140 <strtol+0x9e>
		s++;
f01040f0:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f01040f3:	bf 00 00 00 00       	mov    $0x0,%edi
f01040f8:	eb d1                	jmp    f01040cb <strtol+0x29>
		s++, neg = 1;
f01040fa:	83 c1 01             	add    $0x1,%ecx
f01040fd:	bf 01 00 00 00       	mov    $0x1,%edi
f0104102:	eb c7                	jmp    f01040cb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104104:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0104108:	74 0e                	je     f0104118 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f010410a:	85 db                	test   %ebx,%ebx
f010410c:	75 d8                	jne    f01040e6 <strtol+0x44>
		s++, base = 8;
f010410e:	83 c1 01             	add    $0x1,%ecx
f0104111:	bb 08 00 00 00       	mov    $0x8,%ebx
f0104116:	eb ce                	jmp    f01040e6 <strtol+0x44>
		s += 2, base = 16;
f0104118:	83 c1 02             	add    $0x2,%ecx
f010411b:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104120:	eb c4                	jmp    f01040e6 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104122:	8d 72 9f             	lea    -0x61(%edx),%esi
f0104125:	89 f3                	mov    %esi,%ebx
f0104127:	80 fb 19             	cmp    $0x19,%bl
f010412a:	77 29                	ja     f0104155 <strtol+0xb3>
			dig = *s - 'a' + 10;
f010412c:	0f be d2             	movsbl %dl,%edx
f010412f:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104132:	3b 55 10             	cmp    0x10(%ebp),%edx
f0104135:	7d 30                	jge    f0104167 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0104137:	83 c1 01             	add    $0x1,%ecx
f010413a:	0f af 45 10          	imul   0x10(%ebp),%eax
f010413e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0104140:	0f b6 11             	movzbl (%ecx),%edx
f0104143:	8d 72 d0             	lea    -0x30(%edx),%esi
f0104146:	89 f3                	mov    %esi,%ebx
f0104148:	80 fb 09             	cmp    $0x9,%bl
f010414b:	77 d5                	ja     f0104122 <strtol+0x80>
			dig = *s - '0';
f010414d:	0f be d2             	movsbl %dl,%edx
f0104150:	83 ea 30             	sub    $0x30,%edx
f0104153:	eb dd                	jmp    f0104132 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0104155:	8d 72 bf             	lea    -0x41(%edx),%esi
f0104158:	89 f3                	mov    %esi,%ebx
f010415a:	80 fb 19             	cmp    $0x19,%bl
f010415d:	77 08                	ja     f0104167 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010415f:	0f be d2             	movsbl %dl,%edx
f0104162:	83 ea 37             	sub    $0x37,%edx
f0104165:	eb cb                	jmp    f0104132 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0104167:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010416b:	74 05                	je     f0104172 <strtol+0xd0>
		*endptr = (char *) s;
f010416d:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104170:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0104172:	89 c2                	mov    %eax,%edx
f0104174:	f7 da                	neg    %edx
f0104176:	85 ff                	test   %edi,%edi
f0104178:	0f 45 c2             	cmovne %edx,%eax
}
f010417b:	5b                   	pop    %ebx
f010417c:	5e                   	pop    %esi
f010417d:	5f                   	pop    %edi
f010417e:	5d                   	pop    %ebp
f010417f:	c3                   	ret    

f0104180 <__udivdi3>:
f0104180:	55                   	push   %ebp
f0104181:	57                   	push   %edi
f0104182:	56                   	push   %esi
f0104183:	53                   	push   %ebx
f0104184:	83 ec 1c             	sub    $0x1c,%esp
f0104187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010418b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010418f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104193:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0104197:	85 d2                	test   %edx,%edx
f0104199:	75 35                	jne    f01041d0 <__udivdi3+0x50>
f010419b:	39 f3                	cmp    %esi,%ebx
f010419d:	0f 87 bd 00 00 00    	ja     f0104260 <__udivdi3+0xe0>
f01041a3:	85 db                	test   %ebx,%ebx
f01041a5:	89 d9                	mov    %ebx,%ecx
f01041a7:	75 0b                	jne    f01041b4 <__udivdi3+0x34>
f01041a9:	b8 01 00 00 00       	mov    $0x1,%eax
f01041ae:	31 d2                	xor    %edx,%edx
f01041b0:	f7 f3                	div    %ebx
f01041b2:	89 c1                	mov    %eax,%ecx
f01041b4:	31 d2                	xor    %edx,%edx
f01041b6:	89 f0                	mov    %esi,%eax
f01041b8:	f7 f1                	div    %ecx
f01041ba:	89 c6                	mov    %eax,%esi
f01041bc:	89 e8                	mov    %ebp,%eax
f01041be:	89 f7                	mov    %esi,%edi
f01041c0:	f7 f1                	div    %ecx
f01041c2:	89 fa                	mov    %edi,%edx
f01041c4:	83 c4 1c             	add    $0x1c,%esp
f01041c7:	5b                   	pop    %ebx
f01041c8:	5e                   	pop    %esi
f01041c9:	5f                   	pop    %edi
f01041ca:	5d                   	pop    %ebp
f01041cb:	c3                   	ret    
f01041cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01041d0:	39 f2                	cmp    %esi,%edx
f01041d2:	77 7c                	ja     f0104250 <__udivdi3+0xd0>
f01041d4:	0f bd fa             	bsr    %edx,%edi
f01041d7:	83 f7 1f             	xor    $0x1f,%edi
f01041da:	0f 84 98 00 00 00    	je     f0104278 <__udivdi3+0xf8>
f01041e0:	89 f9                	mov    %edi,%ecx
f01041e2:	b8 20 00 00 00       	mov    $0x20,%eax
f01041e7:	29 f8                	sub    %edi,%eax
f01041e9:	d3 e2                	shl    %cl,%edx
f01041eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01041ef:	89 c1                	mov    %eax,%ecx
f01041f1:	89 da                	mov    %ebx,%edx
f01041f3:	d3 ea                	shr    %cl,%edx
f01041f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01041f9:	09 d1                	or     %edx,%ecx
f01041fb:	89 f2                	mov    %esi,%edx
f01041fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104201:	89 f9                	mov    %edi,%ecx
f0104203:	d3 e3                	shl    %cl,%ebx
f0104205:	89 c1                	mov    %eax,%ecx
f0104207:	d3 ea                	shr    %cl,%edx
f0104209:	89 f9                	mov    %edi,%ecx
f010420b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010420f:	d3 e6                	shl    %cl,%esi
f0104211:	89 eb                	mov    %ebp,%ebx
f0104213:	89 c1                	mov    %eax,%ecx
f0104215:	d3 eb                	shr    %cl,%ebx
f0104217:	09 de                	or     %ebx,%esi
f0104219:	89 f0                	mov    %esi,%eax
f010421b:	f7 74 24 08          	divl   0x8(%esp)
f010421f:	89 d6                	mov    %edx,%esi
f0104221:	89 c3                	mov    %eax,%ebx
f0104223:	f7 64 24 0c          	mull   0xc(%esp)
f0104227:	39 d6                	cmp    %edx,%esi
f0104229:	72 0c                	jb     f0104237 <__udivdi3+0xb7>
f010422b:	89 f9                	mov    %edi,%ecx
f010422d:	d3 e5                	shl    %cl,%ebp
f010422f:	39 c5                	cmp    %eax,%ebp
f0104231:	73 5d                	jae    f0104290 <__udivdi3+0x110>
f0104233:	39 d6                	cmp    %edx,%esi
f0104235:	75 59                	jne    f0104290 <__udivdi3+0x110>
f0104237:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010423a:	31 ff                	xor    %edi,%edi
f010423c:	89 fa                	mov    %edi,%edx
f010423e:	83 c4 1c             	add    $0x1c,%esp
f0104241:	5b                   	pop    %ebx
f0104242:	5e                   	pop    %esi
f0104243:	5f                   	pop    %edi
f0104244:	5d                   	pop    %ebp
f0104245:	c3                   	ret    
f0104246:	8d 76 00             	lea    0x0(%esi),%esi
f0104249:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0104250:	31 ff                	xor    %edi,%edi
f0104252:	31 c0                	xor    %eax,%eax
f0104254:	89 fa                	mov    %edi,%edx
f0104256:	83 c4 1c             	add    $0x1c,%esp
f0104259:	5b                   	pop    %ebx
f010425a:	5e                   	pop    %esi
f010425b:	5f                   	pop    %edi
f010425c:	5d                   	pop    %ebp
f010425d:	c3                   	ret    
f010425e:	66 90                	xchg   %ax,%ax
f0104260:	31 ff                	xor    %edi,%edi
f0104262:	89 e8                	mov    %ebp,%eax
f0104264:	89 f2                	mov    %esi,%edx
f0104266:	f7 f3                	div    %ebx
f0104268:	89 fa                	mov    %edi,%edx
f010426a:	83 c4 1c             	add    $0x1c,%esp
f010426d:	5b                   	pop    %ebx
f010426e:	5e                   	pop    %esi
f010426f:	5f                   	pop    %edi
f0104270:	5d                   	pop    %ebp
f0104271:	c3                   	ret    
f0104272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104278:	39 f2                	cmp    %esi,%edx
f010427a:	72 06                	jb     f0104282 <__udivdi3+0x102>
f010427c:	31 c0                	xor    %eax,%eax
f010427e:	39 eb                	cmp    %ebp,%ebx
f0104280:	77 d2                	ja     f0104254 <__udivdi3+0xd4>
f0104282:	b8 01 00 00 00       	mov    $0x1,%eax
f0104287:	eb cb                	jmp    f0104254 <__udivdi3+0xd4>
f0104289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104290:	89 d8                	mov    %ebx,%eax
f0104292:	31 ff                	xor    %edi,%edi
f0104294:	eb be                	jmp    f0104254 <__udivdi3+0xd4>
f0104296:	66 90                	xchg   %ax,%ax
f0104298:	66 90                	xchg   %ax,%ax
f010429a:	66 90                	xchg   %ax,%ax
f010429c:	66 90                	xchg   %ax,%ax
f010429e:	66 90                	xchg   %ax,%ax

f01042a0 <__umoddi3>:
f01042a0:	55                   	push   %ebp
f01042a1:	57                   	push   %edi
f01042a2:	56                   	push   %esi
f01042a3:	53                   	push   %ebx
f01042a4:	83 ec 1c             	sub    $0x1c,%esp
f01042a7:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01042ab:	8b 74 24 30          	mov    0x30(%esp),%esi
f01042af:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01042b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01042b7:	85 ed                	test   %ebp,%ebp
f01042b9:	89 f0                	mov    %esi,%eax
f01042bb:	89 da                	mov    %ebx,%edx
f01042bd:	75 19                	jne    f01042d8 <__umoddi3+0x38>
f01042bf:	39 df                	cmp    %ebx,%edi
f01042c1:	0f 86 b1 00 00 00    	jbe    f0104378 <__umoddi3+0xd8>
f01042c7:	f7 f7                	div    %edi
f01042c9:	89 d0                	mov    %edx,%eax
f01042cb:	31 d2                	xor    %edx,%edx
f01042cd:	83 c4 1c             	add    $0x1c,%esp
f01042d0:	5b                   	pop    %ebx
f01042d1:	5e                   	pop    %esi
f01042d2:	5f                   	pop    %edi
f01042d3:	5d                   	pop    %ebp
f01042d4:	c3                   	ret    
f01042d5:	8d 76 00             	lea    0x0(%esi),%esi
f01042d8:	39 dd                	cmp    %ebx,%ebp
f01042da:	77 f1                	ja     f01042cd <__umoddi3+0x2d>
f01042dc:	0f bd cd             	bsr    %ebp,%ecx
f01042df:	83 f1 1f             	xor    $0x1f,%ecx
f01042e2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01042e6:	0f 84 b4 00 00 00    	je     f01043a0 <__umoddi3+0x100>
f01042ec:	b8 20 00 00 00       	mov    $0x20,%eax
f01042f1:	89 c2                	mov    %eax,%edx
f01042f3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01042f7:	29 c2                	sub    %eax,%edx
f01042f9:	89 c1                	mov    %eax,%ecx
f01042fb:	89 f8                	mov    %edi,%eax
f01042fd:	d3 e5                	shl    %cl,%ebp
f01042ff:	89 d1                	mov    %edx,%ecx
f0104301:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0104305:	d3 e8                	shr    %cl,%eax
f0104307:	09 c5                	or     %eax,%ebp
f0104309:	8b 44 24 04          	mov    0x4(%esp),%eax
f010430d:	89 c1                	mov    %eax,%ecx
f010430f:	d3 e7                	shl    %cl,%edi
f0104311:	89 d1                	mov    %edx,%ecx
f0104313:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104317:	89 df                	mov    %ebx,%edi
f0104319:	d3 ef                	shr    %cl,%edi
f010431b:	89 c1                	mov    %eax,%ecx
f010431d:	89 f0                	mov    %esi,%eax
f010431f:	d3 e3                	shl    %cl,%ebx
f0104321:	89 d1                	mov    %edx,%ecx
f0104323:	89 fa                	mov    %edi,%edx
f0104325:	d3 e8                	shr    %cl,%eax
f0104327:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f010432c:	09 d8                	or     %ebx,%eax
f010432e:	f7 f5                	div    %ebp
f0104330:	d3 e6                	shl    %cl,%esi
f0104332:	89 d1                	mov    %edx,%ecx
f0104334:	f7 64 24 08          	mull   0x8(%esp)
f0104338:	39 d1                	cmp    %edx,%ecx
f010433a:	89 c3                	mov    %eax,%ebx
f010433c:	89 d7                	mov    %edx,%edi
f010433e:	72 06                	jb     f0104346 <__umoddi3+0xa6>
f0104340:	75 0e                	jne    f0104350 <__umoddi3+0xb0>
f0104342:	39 c6                	cmp    %eax,%esi
f0104344:	73 0a                	jae    f0104350 <__umoddi3+0xb0>
f0104346:	2b 44 24 08          	sub    0x8(%esp),%eax
f010434a:	19 ea                	sbb    %ebp,%edx
f010434c:	89 d7                	mov    %edx,%edi
f010434e:	89 c3                	mov    %eax,%ebx
f0104350:	89 ca                	mov    %ecx,%edx
f0104352:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0104357:	29 de                	sub    %ebx,%esi
f0104359:	19 fa                	sbb    %edi,%edx
f010435b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010435f:	89 d0                	mov    %edx,%eax
f0104361:	d3 e0                	shl    %cl,%eax
f0104363:	89 d9                	mov    %ebx,%ecx
f0104365:	d3 ee                	shr    %cl,%esi
f0104367:	d3 ea                	shr    %cl,%edx
f0104369:	09 f0                	or     %esi,%eax
f010436b:	83 c4 1c             	add    $0x1c,%esp
f010436e:	5b                   	pop    %ebx
f010436f:	5e                   	pop    %esi
f0104370:	5f                   	pop    %edi
f0104371:	5d                   	pop    %ebp
f0104372:	c3                   	ret    
f0104373:	90                   	nop
f0104374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104378:	85 ff                	test   %edi,%edi
f010437a:	89 f9                	mov    %edi,%ecx
f010437c:	75 0b                	jne    f0104389 <__umoddi3+0xe9>
f010437e:	b8 01 00 00 00       	mov    $0x1,%eax
f0104383:	31 d2                	xor    %edx,%edx
f0104385:	f7 f7                	div    %edi
f0104387:	89 c1                	mov    %eax,%ecx
f0104389:	89 d8                	mov    %ebx,%eax
f010438b:	31 d2                	xor    %edx,%edx
f010438d:	f7 f1                	div    %ecx
f010438f:	89 f0                	mov    %esi,%eax
f0104391:	f7 f1                	div    %ecx
f0104393:	e9 31 ff ff ff       	jmp    f01042c9 <__umoddi3+0x29>
f0104398:	90                   	nop
f0104399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01043a0:	39 dd                	cmp    %ebx,%ebp
f01043a2:	72 08                	jb     f01043ac <__umoddi3+0x10c>
f01043a4:	39 f7                	cmp    %esi,%edi
f01043a6:	0f 87 21 ff ff ff    	ja     f01042cd <__umoddi3+0x2d>
f01043ac:	89 da                	mov    %ebx,%edx
f01043ae:	89 f0                	mov    %esi,%eax
f01043b0:	29 f8                	sub    %edi,%eax
f01043b2:	19 ea                	sbb    %ebp,%edx
f01043b4:	e9 14 ff ff ff       	jmp    f01042cd <__umoddi3+0x2d>
