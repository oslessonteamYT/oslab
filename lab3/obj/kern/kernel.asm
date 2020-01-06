
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
f010000b:	e4 66                	in     $0x66,%al

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
f0100034:	bc 00 90 11 f0       	mov    $0xf0119000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 b0 de 17 f0       	mov    $0xf017deb0,%eax
f010004b:	2d 9d cf 17 f0       	sub    $0xf017cf9d,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 9d cf 17 f0 	movl   $0xf017cf9d,(%esp)
f0100063:	e8 bf 4b 00 00       	call   f0104c27 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 b2 04 00 00       	call   f010051f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 c0 50 10 f0 	movl   $0xf01050c0,(%esp)
f010007c:	e8 76 36 00 00       	call   f01036f7 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 20 11 00 00       	call   f01011a6 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 2e 30 00 00       	call   f01030b9 <env_init>
	trap_init();
f010008b:	90                   	nop
f010008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100090:	e8 e8 36 00 00       	call   f010377d <trap_init>
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	//ENV_CREATE(user_hello, ENV_TYPE_USER);
	ENV_CREATE(user_divzero, ENV_TYPE_USER);
f0100095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010009c:	00 
f010009d:	c7 04 24 0c 0d 14 f0 	movl   $0xf0140d0c,(%esp)
f01000a4:	e8 e6 31 00 00       	call   f010328f <env_create>
	//ENV_CREATE(user_softint,ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a9:	a1 ec d1 17 f0       	mov    0xf017d1ec,%eax
f01000ae:	89 04 24             	mov    %eax,(%esp)
f01000b1:	e8 65 35 00 00       	call   f010361b <env_run>

f01000b6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b6:	55                   	push   %ebp
f01000b7:	89 e5                	mov    %esp,%ebp
f01000b9:	56                   	push   %esi
f01000ba:	53                   	push   %ebx
f01000bb:	83 ec 10             	sub    $0x10,%esp
f01000be:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000c1:	83 3d a0 de 17 f0 00 	cmpl   $0x0,0xf017dea0
f01000c8:	75 3d                	jne    f0100107 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000ca:	89 35 a0 de 17 f0    	mov    %esi,0xf017dea0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000d0:	fa                   	cli    
f01000d1:	fc                   	cld    

	va_start(ap, fmt);
f01000d2:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d5:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d8:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01000df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000e3:	c7 04 24 db 50 10 f0 	movl   $0xf01050db,(%esp)
f01000ea:	e8 08 36 00 00       	call   f01036f7 <cprintf>
	vcprintf(fmt, ap);
f01000ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000f3:	89 34 24             	mov    %esi,(%esp)
f01000f6:	e8 c9 35 00 00       	call   f01036c4 <vcprintf>
	cprintf("\n");
f01000fb:	c7 04 24 c9 53 10 f0 	movl   $0xf01053c9,(%esp)
f0100102:	e8 f0 35 00 00       	call   f01036f7 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100107:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010010e:	e8 13 07 00 00       	call   f0100826 <monitor>
f0100113:	eb f2                	jmp    f0100107 <_panic+0x51>

f0100115 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100115:	55                   	push   %ebp
f0100116:	89 e5                	mov    %esp,%ebp
f0100118:	53                   	push   %ebx
f0100119:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010011c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010011f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100122:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100126:	8b 45 08             	mov    0x8(%ebp),%eax
f0100129:	89 44 24 04          	mov    %eax,0x4(%esp)
f010012d:	c7 04 24 f3 50 10 f0 	movl   $0xf01050f3,(%esp)
f0100134:	e8 be 35 00 00       	call   f01036f7 <cprintf>
	vcprintf(fmt, ap);
f0100139:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010013d:	8b 45 10             	mov    0x10(%ebp),%eax
f0100140:	89 04 24             	mov    %eax,(%esp)
f0100143:	e8 7c 35 00 00       	call   f01036c4 <vcprintf>
	cprintf("\n");
f0100148:	c7 04 24 c9 53 10 f0 	movl   $0xf01053c9,(%esp)
f010014f:	e8 a3 35 00 00       	call   f01036f7 <cprintf>
	va_end(ap);
}
f0100154:	83 c4 14             	add    $0x14,%esp
f0100157:	5b                   	pop    %ebx
f0100158:	5d                   	pop    %ebp
f0100159:	c3                   	ret    
f010015a:	66 90                	xchg   %ax,%ax
f010015c:	66 90                	xchg   %ax,%ax
f010015e:	66 90                	xchg   %ax,%ax

f0100160 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100160:	55                   	push   %ebp
f0100161:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100163:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100168:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100169:	a8 01                	test   $0x1,%al
f010016b:	74 08                	je     f0100175 <serial_proc_data+0x15>
f010016d:	b2 f8                	mov    $0xf8,%dl
f010016f:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100170:	0f b6 c0             	movzbl %al,%eax
f0100173:	eb 05                	jmp    f010017a <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010017a:	5d                   	pop    %ebp
f010017b:	c3                   	ret    

f010017c <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010017c:	55                   	push   %ebp
f010017d:	89 e5                	mov    %esp,%ebp
f010017f:	53                   	push   %ebx
f0100180:	83 ec 04             	sub    $0x4,%esp
f0100183:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100185:	eb 2a                	jmp    f01001b1 <cons_intr+0x35>
		if (c == 0)
f0100187:	85 d2                	test   %edx,%edx
f0100189:	74 26                	je     f01001b1 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f010018b:	a1 c4 d1 17 f0       	mov    0xf017d1c4,%eax
f0100190:	8d 48 01             	lea    0x1(%eax),%ecx
f0100193:	89 0d c4 d1 17 f0    	mov    %ecx,0xf017d1c4
f0100199:	88 90 c0 cf 17 f0    	mov    %dl,-0xfe83040(%eax)
		if (cons.wpos == CONSBUFSIZE)
f010019f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001a5:	75 0a                	jne    f01001b1 <cons_intr+0x35>
			cons.wpos = 0;
f01001a7:	c7 05 c4 d1 17 f0 00 	movl   $0x0,0xf017d1c4
f01001ae:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001b1:	ff d3                	call   *%ebx
f01001b3:	89 c2                	mov    %eax,%edx
f01001b5:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001b8:	75 cd                	jne    f0100187 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001ba:	83 c4 04             	add    $0x4,%esp
f01001bd:	5b                   	pop    %ebx
f01001be:	5d                   	pop    %ebp
f01001bf:	c3                   	ret    

f01001c0 <kbd_proc_data>:
f01001c0:	ba 64 00 00 00       	mov    $0x64,%edx
f01001c5:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001c6:	a8 01                	test   $0x1,%al
f01001c8:	0f 84 ef 00 00 00    	je     f01002bd <kbd_proc_data+0xfd>
f01001ce:	b2 60                	mov    $0x60,%dl
f01001d0:	ec                   	in     (%dx),%al
f01001d1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001d3:	3c e0                	cmp    $0xe0,%al
f01001d5:	75 0d                	jne    f01001e4 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001d7:	83 0d a0 cf 17 f0 40 	orl    $0x40,0xf017cfa0
		return 0;
f01001de:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001e3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001e4:	55                   	push   %ebp
f01001e5:	89 e5                	mov    %esp,%ebp
f01001e7:	53                   	push   %ebx
f01001e8:	83 ec 14             	sub    $0x14,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001eb:	84 c0                	test   %al,%al
f01001ed:	79 37                	jns    f0100226 <kbd_proc_data+0x66>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001ef:	8b 0d a0 cf 17 f0    	mov    0xf017cfa0,%ecx
f01001f5:	89 cb                	mov    %ecx,%ebx
f01001f7:	83 e3 40             	and    $0x40,%ebx
f01001fa:	83 e0 7f             	and    $0x7f,%eax
f01001fd:	85 db                	test   %ebx,%ebx
f01001ff:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100202:	0f b6 d2             	movzbl %dl,%edx
f0100205:	0f b6 82 60 52 10 f0 	movzbl -0xfefada0(%edx),%eax
f010020c:	83 c8 40             	or     $0x40,%eax
f010020f:	0f b6 c0             	movzbl %al,%eax
f0100212:	f7 d0                	not    %eax
f0100214:	21 c1                	and    %eax,%ecx
f0100216:	89 0d a0 cf 17 f0    	mov    %ecx,0xf017cfa0
		return 0;
f010021c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100221:	e9 9d 00 00 00       	jmp    f01002c3 <kbd_proc_data+0x103>
	} else if (shift & E0ESC) {
f0100226:	8b 0d a0 cf 17 f0    	mov    0xf017cfa0,%ecx
f010022c:	f6 c1 40             	test   $0x40,%cl
f010022f:	74 0e                	je     f010023f <kbd_proc_data+0x7f>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100231:	83 c8 80             	or     $0xffffff80,%eax
f0100234:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100236:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100239:	89 0d a0 cf 17 f0    	mov    %ecx,0xf017cfa0
	}

	shift |= shiftcode[data];
f010023f:	0f b6 d2             	movzbl %dl,%edx
f0100242:	0f b6 82 60 52 10 f0 	movzbl -0xfefada0(%edx),%eax
f0100249:	0b 05 a0 cf 17 f0    	or     0xf017cfa0,%eax
	shift ^= togglecode[data];
f010024f:	0f b6 8a 60 51 10 f0 	movzbl -0xfefaea0(%edx),%ecx
f0100256:	31 c8                	xor    %ecx,%eax
f0100258:	a3 a0 cf 17 f0       	mov    %eax,0xf017cfa0

	c = charcode[shift & (CTL | SHIFT)][data];
f010025d:	89 c1                	mov    %eax,%ecx
f010025f:	83 e1 03             	and    $0x3,%ecx
f0100262:	8b 0c 8d 40 51 10 f0 	mov    -0xfefaec0(,%ecx,4),%ecx
f0100269:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010026d:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100270:	a8 08                	test   $0x8,%al
f0100272:	74 1b                	je     f010028f <kbd_proc_data+0xcf>
		if ('a' <= c && c <= 'z')
f0100274:	89 da                	mov    %ebx,%edx
f0100276:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100279:	83 f9 19             	cmp    $0x19,%ecx
f010027c:	77 05                	ja     f0100283 <kbd_proc_data+0xc3>
			c += 'A' - 'a';
f010027e:	83 eb 20             	sub    $0x20,%ebx
f0100281:	eb 0c                	jmp    f010028f <kbd_proc_data+0xcf>
		else if ('A' <= c && c <= 'Z')
f0100283:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100286:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100289:	83 fa 19             	cmp    $0x19,%edx
f010028c:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010028f:	f7 d0                	not    %eax
f0100291:	89 c2                	mov    %eax,%edx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100293:	89 d8                	mov    %ebx,%eax
			c += 'a' - 'A';
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100295:	f6 c2 06             	test   $0x6,%dl
f0100298:	75 29                	jne    f01002c3 <kbd_proc_data+0x103>
f010029a:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002a0:	75 21                	jne    f01002c3 <kbd_proc_data+0x103>
		cprintf("Rebooting!\n");
f01002a2:	c7 04 24 0d 51 10 f0 	movl   $0xf010510d,(%esp)
f01002a9:	e8 49 34 00 00       	call   f01036f7 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ae:	ba 92 00 00 00       	mov    $0x92,%edx
f01002b3:	b8 03 00 00 00       	mov    $0x3,%eax
f01002b8:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002b9:	89 d8                	mov    %ebx,%eax
f01002bb:	eb 06                	jmp    f01002c3 <kbd_proc_data+0x103>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002c2:	c3                   	ret    
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01002c3:	83 c4 14             	add    $0x14,%esp
f01002c6:	5b                   	pop    %ebx
f01002c7:	5d                   	pop    %ebp
f01002c8:	c3                   	ret    

f01002c9 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002c9:	55                   	push   %ebp
f01002ca:	89 e5                	mov    %esp,%ebp
f01002cc:	57                   	push   %edi
f01002cd:	56                   	push   %esi
f01002ce:	53                   	push   %ebx
f01002cf:	83 ec 1c             	sub    $0x1c,%esp
f01002d2:	89 c7                	mov    %eax,%edi
f01002d4:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d9:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002de:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e3:	eb 06                	jmp    f01002eb <cons_putc+0x22>
f01002e5:	89 ca                	mov    %ecx,%edx
f01002e7:	ec                   	in     (%dx),%al
f01002e8:	ec                   	in     (%dx),%al
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	89 f2                	mov    %esi,%edx
f01002ed:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ee:	a8 20                	test   $0x20,%al
f01002f0:	75 05                	jne    f01002f7 <cons_putc+0x2e>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002f2:	83 eb 01             	sub    $0x1,%ebx
f01002f5:	75 ee                	jne    f01002e5 <cons_putc+0x1c>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01002f7:	89 f8                	mov    %edi,%eax
f01002f9:	0f b6 c0             	movzbl %al,%eax
f01002fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100304:	ee                   	out    %al,(%dx)
f0100305:	bb 01 32 00 00       	mov    $0x3201,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010030a:	be 79 03 00 00       	mov    $0x379,%esi
f010030f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100314:	eb 06                	jmp    f010031c <cons_putc+0x53>
f0100316:	89 ca                	mov    %ecx,%edx
f0100318:	ec                   	in     (%dx),%al
f0100319:	ec                   	in     (%dx),%al
f010031a:	ec                   	in     (%dx),%al
f010031b:	ec                   	in     (%dx),%al
f010031c:	89 f2                	mov    %esi,%edx
f010031e:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010031f:	84 c0                	test   %al,%al
f0100321:	78 05                	js     f0100328 <cons_putc+0x5f>
f0100323:	83 eb 01             	sub    $0x1,%ebx
f0100326:	75 ee                	jne    f0100316 <cons_putc+0x4d>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100328:	ba 78 03 00 00       	mov    $0x378,%edx
f010032d:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
f0100331:	ee                   	out    %al,(%dx)
f0100332:	b2 7a                	mov    $0x7a,%dl
f0100334:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100339:	ee                   	out    %al,(%dx)
f010033a:	b8 08 00 00 00       	mov    $0x8,%eax
f010033f:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100340:	89 fa                	mov    %edi,%edx
f0100342:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100348:	89 f8                	mov    %edi,%eax
f010034a:	80 cc 07             	or     $0x7,%ah
f010034d:	85 d2                	test   %edx,%edx
f010034f:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100352:	89 f8                	mov    %edi,%eax
f0100354:	0f b6 c0             	movzbl %al,%eax
f0100357:	83 f8 09             	cmp    $0x9,%eax
f010035a:	74 76                	je     f01003d2 <cons_putc+0x109>
f010035c:	83 f8 09             	cmp    $0x9,%eax
f010035f:	7f 0a                	jg     f010036b <cons_putc+0xa2>
f0100361:	83 f8 08             	cmp    $0x8,%eax
f0100364:	74 16                	je     f010037c <cons_putc+0xb3>
f0100366:	e9 9b 00 00 00       	jmp    f0100406 <cons_putc+0x13d>
f010036b:	83 f8 0a             	cmp    $0xa,%eax
f010036e:	66 90                	xchg   %ax,%ax
f0100370:	74 3a                	je     f01003ac <cons_putc+0xe3>
f0100372:	83 f8 0d             	cmp    $0xd,%eax
f0100375:	74 3d                	je     f01003b4 <cons_putc+0xeb>
f0100377:	e9 8a 00 00 00       	jmp    f0100406 <cons_putc+0x13d>
	case '\b':
		if (crt_pos > 0) {
f010037c:	0f b7 05 c8 d1 17 f0 	movzwl 0xf017d1c8,%eax
f0100383:	66 85 c0             	test   %ax,%ax
f0100386:	0f 84 e5 00 00 00    	je     f0100471 <cons_putc+0x1a8>
			crt_pos--;
f010038c:	83 e8 01             	sub    $0x1,%eax
f010038f:	66 a3 c8 d1 17 f0    	mov    %ax,0xf017d1c8
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100395:	0f b7 c0             	movzwl %ax,%eax
f0100398:	66 81 e7 00 ff       	and    $0xff00,%di
f010039d:	83 cf 20             	or     $0x20,%edi
f01003a0:	8b 15 cc d1 17 f0    	mov    0xf017d1cc,%edx
f01003a6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003aa:	eb 78                	jmp    f0100424 <cons_putc+0x15b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ac:	66 83 05 c8 d1 17 f0 	addw   $0x50,0xf017d1c8
f01003b3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003b4:	0f b7 05 c8 d1 17 f0 	movzwl 0xf017d1c8,%eax
f01003bb:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003c1:	c1 e8 16             	shr    $0x16,%eax
f01003c4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003c7:	c1 e0 04             	shl    $0x4,%eax
f01003ca:	66 a3 c8 d1 17 f0    	mov    %ax,0xf017d1c8
f01003d0:	eb 52                	jmp    f0100424 <cons_putc+0x15b>
		break;
	case '\t':
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 ed fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e1:	e8 e3 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003e6:	b8 20 00 00 00       	mov    $0x20,%eax
f01003eb:	e8 d9 fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f5:	e8 cf fe ff ff       	call   f01002c9 <cons_putc>
		cons_putc(' ');
f01003fa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ff:	e8 c5 fe ff ff       	call   f01002c9 <cons_putc>
f0100404:	eb 1e                	jmp    f0100424 <cons_putc+0x15b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100406:	0f b7 05 c8 d1 17 f0 	movzwl 0xf017d1c8,%eax
f010040d:	8d 50 01             	lea    0x1(%eax),%edx
f0100410:	66 89 15 c8 d1 17 f0 	mov    %dx,0xf017d1c8
f0100417:	0f b7 c0             	movzwl %ax,%eax
f010041a:	8b 15 cc d1 17 f0    	mov    0xf017d1cc,%edx
f0100420:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100424:	66 81 3d c8 d1 17 f0 	cmpw   $0x7cf,0xf017d1c8
f010042b:	cf 07 
f010042d:	76 42                	jbe    f0100471 <cons_putc+0x1a8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010042f:	a1 cc d1 17 f0       	mov    0xf017d1cc,%eax
f0100434:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010043b:	00 
f010043c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100442:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100446:	89 04 24             	mov    %eax,(%esp)
f0100449:	e8 26 48 00 00       	call   f0104c74 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010044e:	8b 15 cc d1 17 f0    	mov    0xf017d1cc,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100454:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100459:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010045f:	83 c0 01             	add    $0x1,%eax
f0100462:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100467:	75 f0                	jne    f0100459 <cons_putc+0x190>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100469:	66 83 2d c8 d1 17 f0 	subw   $0x50,0xf017d1c8
f0100470:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100471:	8b 0d d0 d1 17 f0    	mov    0xf017d1d0,%ecx
f0100477:	b8 0e 00 00 00       	mov    $0xe,%eax
f010047c:	89 ca                	mov    %ecx,%edx
f010047e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010047f:	0f b7 1d c8 d1 17 f0 	movzwl 0xf017d1c8,%ebx
f0100486:	8d 71 01             	lea    0x1(%ecx),%esi
f0100489:	89 d8                	mov    %ebx,%eax
f010048b:	66 c1 e8 08          	shr    $0x8,%ax
f010048f:	89 f2                	mov    %esi,%edx
f0100491:	ee                   	out    %al,(%dx)
f0100492:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100497:	89 ca                	mov    %ecx,%edx
f0100499:	ee                   	out    %al,(%dx)
f010049a:	89 d8                	mov    %ebx,%eax
f010049c:	89 f2                	mov    %esi,%edx
f010049e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010049f:	83 c4 1c             	add    $0x1c,%esp
f01004a2:	5b                   	pop    %ebx
f01004a3:	5e                   	pop    %esi
f01004a4:	5f                   	pop    %edi
f01004a5:	5d                   	pop    %ebp
f01004a6:	c3                   	ret    

f01004a7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004a7:	80 3d d4 d1 17 f0 00 	cmpb   $0x0,0xf017d1d4
f01004ae:	74 11                	je     f01004c1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004b0:	55                   	push   %ebp
f01004b1:	89 e5                	mov    %esp,%ebp
f01004b3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004b6:	b8 60 01 10 f0       	mov    $0xf0100160,%eax
f01004bb:	e8 bc fc ff ff       	call   f010017c <cons_intr>
}
f01004c0:	c9                   	leave  
f01004c1:	f3 c3                	repz ret 

f01004c3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004c9:	b8 c0 01 10 f0       	mov    $0xf01001c0,%eax
f01004ce:	e8 a9 fc ff ff       	call   f010017c <cons_intr>
}
f01004d3:	c9                   	leave  
f01004d4:	c3                   	ret    

f01004d5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004d5:	55                   	push   %ebp
f01004d6:	89 e5                	mov    %esp,%ebp
f01004d8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004db:	e8 c7 ff ff ff       	call   f01004a7 <serial_intr>
	kbd_intr();
f01004e0:	e8 de ff ff ff       	call   f01004c3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004e5:	a1 c0 d1 17 f0       	mov    0xf017d1c0,%eax
f01004ea:	3b 05 c4 d1 17 f0    	cmp    0xf017d1c4,%eax
f01004f0:	74 26                	je     f0100518 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004f2:	8d 50 01             	lea    0x1(%eax),%edx
f01004f5:	89 15 c0 d1 17 f0    	mov    %edx,0xf017d1c0
f01004fb:	0f b6 88 c0 cf 17 f0 	movzbl -0xfe83040(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100502:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100504:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010050a:	75 11                	jne    f010051d <cons_getc+0x48>
			cons.rpos = 0;
f010050c:	c7 05 c0 d1 17 f0 00 	movl   $0x0,0xf017d1c0
f0100513:	00 00 00 
f0100516:	eb 05                	jmp    f010051d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100518:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010051d:	c9                   	leave  
f010051e:	c3                   	ret    

f010051f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010051f:	55                   	push   %ebp
f0100520:	89 e5                	mov    %esp,%ebp
f0100522:	57                   	push   %edi
f0100523:	56                   	push   %esi
f0100524:	53                   	push   %ebx
f0100525:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100528:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010052f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100536:	5a a5 
	if (*cp != 0xA55A) {
f0100538:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010053f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100543:	74 11                	je     f0100556 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100545:	c7 05 d0 d1 17 f0 b4 	movl   $0x3b4,0xf017d1d0
f010054c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010054f:	bf 00 00 0b f0       	mov    $0xf00b0000,%edi
f0100554:	eb 16                	jmp    f010056c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100556:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010055d:	c7 05 d0 d1 17 f0 d4 	movl   $0x3d4,0xf017d1d0
f0100564:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100567:	bf 00 80 0b f0       	mov    $0xf00b8000,%edi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010056c:	8b 0d d0 d1 17 f0    	mov    0xf017d1d0,%ecx
f0100572:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100577:	89 ca                	mov    %ecx,%edx
f0100579:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010057a:	8d 59 01             	lea    0x1(%ecx),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057d:	89 da                	mov    %ebx,%edx
f010057f:	ec                   	in     (%dx),%al
f0100580:	0f b6 f0             	movzbl %al,%esi
f0100583:	c1 e6 08             	shl    $0x8,%esi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100586:	b8 0f 00 00 00       	mov    $0xf,%eax
f010058b:	89 ca                	mov    %ecx,%edx
f010058d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010058e:	89 da                	mov    %ebx,%edx
f0100590:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100591:	89 3d cc d1 17 f0    	mov    %edi,0xf017d1cc

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f0100597:	0f b6 d8             	movzbl %al,%ebx
f010059a:	09 de                	or     %ebx,%esi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f010059c:	66 89 35 c8 d1 17 f0 	mov    %si,0xf017d1c8
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01005ad:	89 f2                	mov    %esi,%edx
f01005af:	ee                   	out    %al,(%dx)
f01005b0:	b2 fb                	mov    $0xfb,%dl
f01005b2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005b7:	ee                   	out    %al,(%dx)
f01005b8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005bd:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005c2:	89 da                	mov    %ebx,%edx
f01005c4:	ee                   	out    %al,(%dx)
f01005c5:	b2 f9                	mov    $0xf9,%dl
f01005c7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005cc:	ee                   	out    %al,(%dx)
f01005cd:	b2 fb                	mov    $0xfb,%dl
f01005cf:	b8 03 00 00 00       	mov    $0x3,%eax
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	b2 fc                	mov    $0xfc,%dl
f01005d7:	b8 00 00 00 00       	mov    $0x0,%eax
f01005dc:	ee                   	out    %al,(%dx)
f01005dd:	b2 f9                	mov    $0xf9,%dl
f01005df:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e5:	b2 fd                	mov    $0xfd,%dl
f01005e7:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e8:	3c ff                	cmp    $0xff,%al
f01005ea:	0f 95 c1             	setne  %cl
f01005ed:	88 0d d4 d1 17 f0    	mov    %cl,0xf017d1d4
f01005f3:	89 f2                	mov    %esi,%edx
f01005f5:	ec                   	in     (%dx),%al
f01005f6:	89 da                	mov    %ebx,%edx
f01005f8:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005f9:	84 c9                	test   %cl,%cl
f01005fb:	75 0c                	jne    f0100609 <cons_init+0xea>
		cprintf("Serial port does not exist!\n");
f01005fd:	c7 04 24 19 51 10 f0 	movl   $0xf0105119,(%esp)
f0100604:	e8 ee 30 00 00       	call   f01036f7 <cprintf>
}
f0100609:	83 c4 1c             	add    $0x1c,%esp
f010060c:	5b                   	pop    %ebx
f010060d:	5e                   	pop    %esi
f010060e:	5f                   	pop    %edi
f010060f:	5d                   	pop    %ebp
f0100610:	c3                   	ret    

f0100611 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100611:	55                   	push   %ebp
f0100612:	89 e5                	mov    %esp,%ebp
f0100614:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100617:	8b 45 08             	mov    0x8(%ebp),%eax
f010061a:	e8 aa fc ff ff       	call   f01002c9 <cons_putc>
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <getchar>:

int
getchar(void)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
f0100624:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100627:	e8 a9 fe ff ff       	call   f01004d5 <cons_getc>
f010062c:	85 c0                	test   %eax,%eax
f010062e:	74 f7                	je     f0100627 <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <iscons>:

int
iscons(int fdnum)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100635:	b8 01 00 00 00       	mov    $0x1,%eax
f010063a:	5d                   	pop    %ebp
f010063b:	c3                   	ret    
f010063c:	66 90                	xchg   %ax,%ax
f010063e:	66 90                	xchg   %ax,%ax

f0100640 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100646:	c7 44 24 08 60 53 10 	movl   $0xf0105360,0x8(%esp)
f010064d:	f0 
f010064e:	c7 44 24 04 7e 53 10 	movl   $0xf010537e,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 83 53 10 f0 	movl   $0xf0105383,(%esp)
f010065d:	e8 95 30 00 00       	call   f01036f7 <cprintf>
f0100662:	c7 44 24 08 1c 54 10 	movl   $0xf010541c,0x8(%esp)
f0100669:	f0 
f010066a:	c7 44 24 04 8c 53 10 	movl   $0xf010538c,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 83 53 10 f0 	movl   $0xf0105383,(%esp)
f0100679:	e8 79 30 00 00       	call   f01036f7 <cprintf>
f010067e:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0100685:	f0 
f0100686:	c7 44 24 04 95 53 10 	movl   $0xf0105395,0x4(%esp)
f010068d:	f0 
f010068e:	c7 04 24 83 53 10 f0 	movl   $0xf0105383,(%esp)
f0100695:	e8 5d 30 00 00       	call   f01036f7 <cprintf>
	return 0;
}
f010069a:	b8 00 00 00 00       	mov    $0x0,%eax
f010069f:	c9                   	leave  
f01006a0:	c3                   	ret    

f01006a1 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006a1:	55                   	push   %ebp
f01006a2:	89 e5                	mov    %esp,%ebp
f01006a4:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006a7:	c7 04 24 9f 53 10 f0 	movl   $0xf010539f,(%esp)
f01006ae:	e8 44 30 00 00       	call   f01036f7 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006b3:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01006ba:	00 
f01006bb:	c7 04 24 70 54 10 f0 	movl   $0xf0105470,(%esp)
f01006c2:	e8 30 30 00 00       	call   f01036f7 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006c7:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01006ce:	00 
f01006cf:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01006d6:	f0 
f01006d7:	c7 04 24 98 54 10 f0 	movl   $0xf0105498,(%esp)
f01006de:	e8 14 30 00 00       	call   f01036f7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006e3:	c7 44 24 08 b7 50 10 	movl   $0x1050b7,0x8(%esp)
f01006ea:	00 
f01006eb:	c7 44 24 04 b7 50 10 	movl   $0xf01050b7,0x4(%esp)
f01006f2:	f0 
f01006f3:	c7 04 24 bc 54 10 f0 	movl   $0xf01054bc,(%esp)
f01006fa:	e8 f8 2f 00 00       	call   f01036f7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006ff:	c7 44 24 08 9d cf 17 	movl   $0x17cf9d,0x8(%esp)
f0100706:	00 
f0100707:	c7 44 24 04 9d cf 17 	movl   $0xf017cf9d,0x4(%esp)
f010070e:	f0 
f010070f:	c7 04 24 e0 54 10 f0 	movl   $0xf01054e0,(%esp)
f0100716:	e8 dc 2f 00 00       	call   f01036f7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010071b:	c7 44 24 08 b0 de 17 	movl   $0x17deb0,0x8(%esp)
f0100722:	00 
f0100723:	c7 44 24 04 b0 de 17 	movl   $0xf017deb0,0x4(%esp)
f010072a:	f0 
f010072b:	c7 04 24 04 55 10 f0 	movl   $0xf0105504,(%esp)
f0100732:	e8 c0 2f 00 00       	call   f01036f7 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100737:	b8 af e2 17 f0       	mov    $0xf017e2af,%eax
f010073c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100741:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100746:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010074c:	85 c0                	test   %eax,%eax
f010074e:	0f 48 c2             	cmovs  %edx,%eax
f0100751:	c1 f8 0a             	sar    $0xa,%eax
f0100754:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100758:	c7 04 24 28 55 10 f0 	movl   $0xf0105528,(%esp)
f010075f:	e8 93 2f 00 00       	call   f01036f7 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100764:	b8 00 00 00 00       	mov    $0x0,%eax
f0100769:	c9                   	leave  
f010076a:	c3                   	ret    

f010076b <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010076b:	55                   	push   %ebp
f010076c:	89 e5                	mov    %esp,%ebp
f010076e:	56                   	push   %esi
f010076f:	53                   	push   %ebx
f0100770:	83 ec 40             	sub    $0x40,%esp
	// Your code here.
	cprintf("Stack backtrace:\r\n");
f0100773:	c7 04 24 b8 53 10 f0 	movl   $0xf01053b8,(%esp)
f010077a:	e8 78 2f 00 00       	call   f01036f7 <cprintf>

	uint32_t *ebp_pt=(uint32_t *)read_ebp();
f010077f:	89 eb                	mov    %ebp,%ebx
	while(ebp_pt!=0){
		
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\r\n",ebp_pt,*(ebp_pt+1),*(ebp_pt+2),*(ebp_pt+3),*(ebp_pt+4),*(ebp_pt+5),*(ebp_pt+6));

		struct Eipdebuginfo info;
		debuginfo_eip(*(ebp_pt+1),&info);
f0100781:	8d 75 e0             	lea    -0x20(%ebp),%esi
	// Your code here.
	cprintf("Stack backtrace:\r\n");

	uint32_t *ebp_pt=(uint32_t *)read_ebp();

	while(ebp_pt!=0){
f0100784:	e9 89 00 00 00       	jmp    f0100812 <mon_backtrace+0xa7>
		
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\r\n",ebp_pt,*(ebp_pt+1),*(ebp_pt+2),*(ebp_pt+3),*(ebp_pt+4),*(ebp_pt+5),*(ebp_pt+6));
f0100789:	8b 43 18             	mov    0x18(%ebx),%eax
f010078c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0100790:	8b 43 14             	mov    0x14(%ebx),%eax
f0100793:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100797:	8b 43 10             	mov    0x10(%ebx),%eax
f010079a:	89 44 24 14          	mov    %eax,0x14(%esp)
f010079e:	8b 43 0c             	mov    0xc(%ebx),%eax
f01007a1:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007a5:	8b 43 08             	mov    0x8(%ebx),%eax
f01007a8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007ac:	8b 43 04             	mov    0x4(%ebx),%eax
f01007af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01007b7:	c7 04 24 54 55 10 f0 	movl   $0xf0105554,(%esp)
f01007be:	e8 34 2f 00 00       	call   f01036f7 <cprintf>

		struct Eipdebuginfo info;
		debuginfo_eip(*(ebp_pt+1),&info);
f01007c3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01007c7:	8b 43 04             	mov    0x4(%ebx),%eax
f01007ca:	89 04 24             	mov    %eax,(%esp)
f01007cd:	e8 50 39 00 00       	call   f0104122 <debuginfo_eip>
		//if(record != 0){

			//cprintf("unable to get debuginfo for eip %x.\r\n", *(ebp_pt+1));
		//}
		//else{
		cprintf("\t%s:%d: %.*s+%d\r\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, *(ebp_pt+1)-info.eip_fn_addr);
f01007d2:	8b 43 04             	mov    0x4(%ebx),%eax
f01007d5:	2b 45 f0             	sub    -0x10(%ebp),%eax
f01007d8:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01007df:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01007e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01007ed:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01007f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007f8:	c7 04 24 cb 53 10 f0 	movl   $0xf01053cb,(%esp)
f01007ff:	e8 f3 2e 00 00       	call   f01036f7 <cprintf>
		//}
		cprintf("\n");
f0100804:	c7 04 24 c9 53 10 f0 	movl   $0xf01053c9,(%esp)
f010080b:	e8 e7 2e 00 00       	call   f01036f7 <cprintf>
		ebp_pt=(uint32_t *)*ebp_pt;
f0100810:	8b 1b                	mov    (%ebx),%ebx
	// Your code here.
	cprintf("Stack backtrace:\r\n");

	uint32_t *ebp_pt=(uint32_t *)read_ebp();

	while(ebp_pt!=0){
f0100812:	85 db                	test   %ebx,%ebx
f0100814:	0f 85 6f ff ff ff    	jne    f0100789 <mon_backtrace+0x1e>
		cprintf("\n");
		ebp_pt=(uint32_t *)*ebp_pt;
	}
	
	return 0;
}
f010081a:	b8 00 00 00 00       	mov    $0x0,%eax
f010081f:	83 c4 40             	add    $0x40,%esp
f0100822:	5b                   	pop    %ebx
f0100823:	5e                   	pop    %esi
f0100824:	5d                   	pop    %ebp
f0100825:	c3                   	ret    

f0100826 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100826:	55                   	push   %ebp
f0100827:	89 e5                	mov    %esp,%ebp
f0100829:	57                   	push   %edi
f010082a:	56                   	push   %esi
f010082b:	53                   	push   %ebx
f010082c:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010082f:	c7 04 24 8c 55 10 f0 	movl   $0xf010558c,(%esp)
f0100836:	e8 bc 2e 00 00       	call   f01036f7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010083b:	c7 04 24 b0 55 10 f0 	movl   $0xf01055b0,(%esp)
f0100842:	e8 b0 2e 00 00       	call   f01036f7 <cprintf>

	if (tf != NULL)
f0100847:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010084b:	74 0b                	je     f0100858 <monitor+0x32>
		print_trapframe(tf);
f010084d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100850:	89 04 24             	mov    %eax,(%esp)
f0100853:	e8 07 33 00 00       	call   f0103b5f <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100858:	c7 04 24 dd 53 10 f0 	movl   $0xf01053dd,(%esp)
f010085f:	e8 6c 41 00 00       	call   f01049d0 <readline>
f0100864:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100866:	85 c0                	test   %eax,%eax
f0100868:	74 ee                	je     f0100858 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010086a:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100871:	be 00 00 00 00       	mov    $0x0,%esi
f0100876:	eb 0a                	jmp    f0100882 <monitor+0x5c>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100878:	c6 03 00             	movb   $0x0,(%ebx)
f010087b:	89 f7                	mov    %esi,%edi
f010087d:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100880:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100882:	0f b6 03             	movzbl (%ebx),%eax
f0100885:	84 c0                	test   %al,%al
f0100887:	74 63                	je     f01008ec <monitor+0xc6>
f0100889:	0f be c0             	movsbl %al,%eax
f010088c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100890:	c7 04 24 e1 53 10 f0 	movl   $0xf01053e1,(%esp)
f0100897:	e8 4e 43 00 00       	call   f0104bea <strchr>
f010089c:	85 c0                	test   %eax,%eax
f010089e:	75 d8                	jne    f0100878 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f01008a0:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008a3:	74 47                	je     f01008ec <monitor+0xc6>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008a5:	83 fe 0f             	cmp    $0xf,%esi
f01008a8:	75 16                	jne    f01008c0 <monitor+0x9a>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008aa:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01008b1:	00 
f01008b2:	c7 04 24 e6 53 10 f0 	movl   $0xf01053e6,(%esp)
f01008b9:	e8 39 2e 00 00       	call   f01036f7 <cprintf>
f01008be:	eb 98                	jmp    f0100858 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f01008c0:	8d 7e 01             	lea    0x1(%esi),%edi
f01008c3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008c7:	eb 03                	jmp    f01008cc <monitor+0xa6>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008c9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008cc:	0f b6 03             	movzbl (%ebx),%eax
f01008cf:	84 c0                	test   %al,%al
f01008d1:	74 ad                	je     f0100880 <monitor+0x5a>
f01008d3:	0f be c0             	movsbl %al,%eax
f01008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008da:	c7 04 24 e1 53 10 f0 	movl   $0xf01053e1,(%esp)
f01008e1:	e8 04 43 00 00       	call   f0104bea <strchr>
f01008e6:	85 c0                	test   %eax,%eax
f01008e8:	74 df                	je     f01008c9 <monitor+0xa3>
f01008ea:	eb 94                	jmp    f0100880 <monitor+0x5a>
			buf++;
	}
	argv[argc] = 0;
f01008ec:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008f3:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008f4:	85 f6                	test   %esi,%esi
f01008f6:	0f 84 5c ff ff ff    	je     f0100858 <monitor+0x32>
f01008fc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100901:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100904:	8b 04 85 e0 55 10 f0 	mov    -0xfefaa20(,%eax,4),%eax
f010090b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090f:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100912:	89 04 24             	mov    %eax,(%esp)
f0100915:	e8 72 42 00 00       	call   f0104b8c <strcmp>
f010091a:	85 c0                	test   %eax,%eax
f010091c:	75 24                	jne    f0100942 <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f010091e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100921:	8b 55 08             	mov    0x8(%ebp),%edx
f0100924:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100928:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010092b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010092f:	89 34 24             	mov    %esi,(%esp)
f0100932:	ff 14 85 e8 55 10 f0 	call   *-0xfefaa18(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100939:	85 c0                	test   %eax,%eax
f010093b:	78 25                	js     f0100962 <monitor+0x13c>
f010093d:	e9 16 ff ff ff       	jmp    f0100858 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100942:	83 c3 01             	add    $0x1,%ebx
f0100945:	83 fb 03             	cmp    $0x3,%ebx
f0100948:	75 b7                	jne    f0100901 <monitor+0xdb>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010094a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010094d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100951:	c7 04 24 03 54 10 f0 	movl   $0xf0105403,(%esp)
f0100958:	e8 9a 2d 00 00       	call   f01036f7 <cprintf>
f010095d:	e9 f6 fe ff ff       	jmp    f0100858 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100962:	83 c4 5c             	add    $0x5c,%esp
f0100965:	5b                   	pop    %ebx
f0100966:	5e                   	pop    %esi
f0100967:	5f                   	pop    %edi
f0100968:	5d                   	pop    %ebp
f0100969:	c3                   	ret    
f010096a:	66 90                	xchg   %ax,%ax
f010096c:	66 90                	xchg   %ax,%ax
f010096e:	66 90                	xchg   %ax,%ax

f0100970 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100970:	55                   	push   %ebp
f0100971:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100973:	83 3d d8 d1 17 f0 00 	cmpl   $0x0,0xf017d1d8
f010097a:	75 11                	jne    f010098d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f010097c:	ba af ee 17 f0       	mov    $0xf017eeaf,%edx
f0100981:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100987:	89 15 d8 d1 17 f0    	mov    %edx,0xf017d1d8
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f010098d:	8b 15 d8 d1 17 f0    	mov    0xf017d1d8,%edx
	
	if(n > 0) nextfree += ROUNDUP(n, PGSIZE);
f0100993:	85 c0                	test   %eax,%eax
f0100995:	74 11                	je     f01009a8 <boot_alloc+0x38>
f0100997:	05 ff 0f 00 00       	add    $0xfff,%eax
f010099c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009a1:	01 d0                	add    %edx,%eax
f01009a3:	a3 d8 d1 17 f0       	mov    %eax,0xf017d1d8
	if((nextfree + n) > (char * )(0XFFFFFFFF)){
		panic("out of memory");
	}
	return result;
}
f01009a8:	89 d0                	mov    %edx,%eax
f01009aa:	5d                   	pop    %ebp
f01009ab:	c3                   	ret    

f01009ac <page2kva>:
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009ac:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f01009b2:	c1 f8 03             	sar    $0x3,%eax
f01009b5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009b8:	89 c2                	mov    %eax,%edx
f01009ba:	c1 ea 0c             	shr    $0xc,%edx
f01009bd:	3b 15 a4 de 17 f0    	cmp    0xf017dea4,%edx
f01009c3:	72 26                	jb     f01009eb <page2kva+0x3f>
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f01009c5:	55                   	push   %ebp
f01009c6:	89 e5                	mov    %esp,%ebp
f01009c8:	83 ec 18             	sub    $0x18,%esp

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01009cf:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f01009d6:	f0 
f01009d7:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01009de:	00 
f01009df:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f01009e6:	e8 cb f6 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f01009eb:	2d 00 00 00 10       	sub    $0x10000000,%eax

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
}
f01009f0:	c3                   	ret    

f01009f1 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009f1:	89 d1                	mov    %edx,%ecx
f01009f3:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009f6:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009f9:	a8 01                	test   $0x1,%al
f01009fb:	74 5d                	je     f0100a5a <check_va2pa+0x69>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a02:	89 c1                	mov    %eax,%ecx
f0100a04:	c1 e9 0c             	shr    $0xc,%ecx
f0100a07:	3b 0d a4 de 17 f0    	cmp    0xf017dea4,%ecx
f0100a0d:	72 26                	jb     f0100a35 <check_va2pa+0x44>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a0f:	55                   	push   %ebp
f0100a10:	89 e5                	mov    %esp,%ebp
f0100a12:	83 ec 18             	sub    $0x18,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a15:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a19:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0100a20:	f0 
f0100a21:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0100a28:	00 
f0100a29:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100a30:	e8 81 f6 ff ff       	call   f01000b6 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a35:	c1 ea 0c             	shr    $0xc,%edx
f0100a38:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a3e:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a45:	89 c2                	mov    %eax,%edx
f0100a47:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a4f:	85 d2                	test   %edx,%edx
f0100a51:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a56:	0f 44 c2             	cmove  %edx,%eax
f0100a59:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a5f:	c3                   	ret    

f0100a60 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a60:	55                   	push   %ebp
f0100a61:	89 e5                	mov    %esp,%ebp
f0100a63:	57                   	push   %edi
f0100a64:	56                   	push   %esi
f0100a65:	53                   	push   %ebx
f0100a66:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a69:	84 c0                	test   %al,%al
f0100a6b:	0f 85 07 03 00 00    	jne    f0100d78 <check_page_free_list+0x318>
f0100a71:	e9 14 03 00 00       	jmp    f0100d8a <check_page_free_list+0x32a>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100a76:	c7 44 24 08 28 56 10 	movl   $0xf0105628,0x8(%esp)
f0100a7d:	f0 
f0100a7e:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f0100a85:	00 
f0100a86:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100a8d:	e8 24 f6 ff ff       	call   f01000b6 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a92:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100a95:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100a98:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100a9b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a9e:	89 c2                	mov    %eax,%edx
f0100aa0:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100aa6:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100aac:	0f 95 c2             	setne  %dl
f0100aaf:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100ab2:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ab6:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ab8:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100abc:	8b 00                	mov    (%eax),%eax
f0100abe:	85 c0                	test   %eax,%eax
f0100ac0:	75 dc                	jne    f0100a9e <check_page_free_list+0x3e>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ac2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ac5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100acb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ace:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ad1:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ad3:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ad6:	a3 e0 d1 17 f0       	mov    %eax,0xf017d1e0
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100adb:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ae0:	8b 1d e0 d1 17 f0    	mov    0xf017d1e0,%ebx
f0100ae6:	eb 63                	jmp    f0100b4b <check_page_free_list+0xeb>
f0100ae8:	89 d8                	mov    %ebx,%eax
f0100aea:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f0100af0:	c1 f8 03             	sar    $0x3,%eax
f0100af3:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100af6:	89 c2                	mov    %eax,%edx
f0100af8:	c1 ea 16             	shr    $0x16,%edx
f0100afb:	39 f2                	cmp    %esi,%edx
f0100afd:	73 4a                	jae    f0100b49 <check_page_free_list+0xe9>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100aff:	89 c2                	mov    %eax,%edx
f0100b01:	c1 ea 0c             	shr    $0xc,%edx
f0100b04:	3b 15 a4 de 17 f0    	cmp    0xf017dea4,%edx
f0100b0a:	72 20                	jb     f0100b2c <check_page_free_list+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b10:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0100b17:	f0 
f0100b18:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100b1f:	00 
f0100b20:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f0100b27:	e8 8a f5 ff ff       	call   f01000b6 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b2c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b33:	00 
f0100b34:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b3b:	00 
	return (void *)(pa + KERNBASE);
f0100b3c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b41:	89 04 24             	mov    %eax,(%esp)
f0100b44:	e8 de 40 00 00       	call   f0104c27 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b49:	8b 1b                	mov    (%ebx),%ebx
f0100b4b:	85 db                	test   %ebx,%ebx
f0100b4d:	75 99                	jne    f0100ae8 <check_page_free_list+0x88>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b54:	e8 17 fe ff ff       	call   f0100970 <boot_alloc>
f0100b59:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b5c:	8b 15 e0 d1 17 f0    	mov    0xf017d1e0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b62:	8b 0d ac de 17 f0    	mov    0xf017deac,%ecx
		assert(pp < pages + npages);
f0100b68:	a1 a4 de 17 f0       	mov    0xf017dea4,%eax
f0100b6d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0100b70:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b73:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b76:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b79:	bf 00 00 00 00       	mov    $0x0,%edi
f0100b7e:	89 5d cc             	mov    %ebx,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b81:	e9 97 01 00 00       	jmp    f0100d1d <check_page_free_list+0x2bd>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b86:	39 ca                	cmp    %ecx,%edx
f0100b88:	73 24                	jae    f0100bae <check_page_free_list+0x14e>
f0100b8a:	c7 44 24 0c db 5d 10 	movl   $0xf0105ddb,0xc(%esp)
f0100b91:	f0 
f0100b92:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100b99:	f0 
f0100b9a:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f0100ba1:	00 
f0100ba2:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100ba9:	e8 08 f5 ff ff       	call   f01000b6 <_panic>
		assert(pp < pages + npages);
f0100bae:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100bb1:	72 24                	jb     f0100bd7 <check_page_free_list+0x177>
f0100bb3:	c7 44 24 0c fc 5d 10 	movl   $0xf0105dfc,0xc(%esp)
f0100bba:	f0 
f0100bbb:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100bc2:	f0 
f0100bc3:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0100bca:	00 
f0100bcb:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100bd2:	e8 df f4 ff ff       	call   f01000b6 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bd7:	89 d0                	mov    %edx,%eax
f0100bd9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bdc:	a8 07                	test   $0x7,%al
f0100bde:	74 24                	je     f0100c04 <check_page_free_list+0x1a4>
f0100be0:	c7 44 24 0c 4c 56 10 	movl   $0xf010564c,0xc(%esp)
f0100be7:	f0 
f0100be8:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100bef:	f0 
f0100bf0:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0100bf7:	00 
f0100bf8:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100bff:	e8 b2 f4 ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c04:	c1 f8 03             	sar    $0x3,%eax
f0100c07:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c0a:	85 c0                	test   %eax,%eax
f0100c0c:	75 24                	jne    f0100c32 <check_page_free_list+0x1d2>
f0100c0e:	c7 44 24 0c 10 5e 10 	movl   $0xf0105e10,0xc(%esp)
f0100c15:	f0 
f0100c16:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100c1d:	f0 
f0100c1e:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0100c25:	00 
f0100c26:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100c2d:	e8 84 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c32:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c37:	75 24                	jne    f0100c5d <check_page_free_list+0x1fd>
f0100c39:	c7 44 24 0c 21 5e 10 	movl   $0xf0105e21,0xc(%esp)
f0100c40:	f0 
f0100c41:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100c48:	f0 
f0100c49:	c7 44 24 04 9c 02 00 	movl   $0x29c,0x4(%esp)
f0100c50:	00 
f0100c51:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100c58:	e8 59 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c5d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c62:	75 24                	jne    f0100c88 <check_page_free_list+0x228>
f0100c64:	c7 44 24 0c 80 56 10 	movl   $0xf0105680,0xc(%esp)
f0100c6b:	f0 
f0100c6c:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100c73:	f0 
f0100c74:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f0100c7b:	00 
f0100c7c:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100c83:	e8 2e f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c88:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c8d:	75 24                	jne    f0100cb3 <check_page_free_list+0x253>
f0100c8f:	c7 44 24 0c 3a 5e 10 	movl   $0xf0105e3a,0xc(%esp)
f0100c96:	f0 
f0100c97:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100c9e:	f0 
f0100c9f:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f0100ca6:	00 
f0100ca7:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100cae:	e8 03 f4 ff ff       	call   f01000b6 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cb3:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cb8:	76 58                	jbe    f0100d12 <check_page_free_list+0x2b2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cba:	89 c3                	mov    %eax,%ebx
f0100cbc:	c1 eb 0c             	shr    $0xc,%ebx
f0100cbf:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0100cc2:	77 20                	ja     f0100ce4 <check_page_free_list+0x284>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cc8:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0100ccf:	f0 
f0100cd0:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100cd7:	00 
f0100cd8:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f0100cdf:	e8 d2 f3 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0100ce4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ce9:	39 45 c8             	cmp    %eax,-0x38(%ebp)
f0100cec:	76 2a                	jbe    f0100d18 <check_page_free_list+0x2b8>
f0100cee:	c7 44 24 0c a4 56 10 	movl   $0xf01056a4,0xc(%esp)
f0100cf5:	f0 
f0100cf6:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100cfd:	f0 
f0100cfe:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f0100d05:	00 
f0100d06:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100d0d:	e8 a4 f3 ff ff       	call   f01000b6 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d12:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
f0100d16:	eb 03                	jmp    f0100d1b <check_page_free_list+0x2bb>
		else
			++nfree_extmem;
f0100d18:	83 c7 01             	add    $0x1,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d1b:	8b 12                	mov    (%edx),%edx
f0100d1d:	85 d2                	test   %edx,%edx
f0100d1f:	0f 85 61 fe ff ff    	jne    f0100b86 <check_page_free_list+0x126>
f0100d25:	8b 5d cc             	mov    -0x34(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d28:	85 db                	test   %ebx,%ebx
f0100d2a:	7f 24                	jg     f0100d50 <check_page_free_list+0x2f0>
f0100d2c:	c7 44 24 0c 54 5e 10 	movl   $0xf0105e54,0xc(%esp)
f0100d33:	f0 
f0100d34:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100d3b:	f0 
f0100d3c:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0100d43:	00 
f0100d44:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100d4b:	e8 66 f3 ff ff       	call   f01000b6 <_panic>
	assert(nfree_extmem > 0);
f0100d50:	85 ff                	test   %edi,%edi
f0100d52:	7f 4d                	jg     f0100da1 <check_page_free_list+0x341>
f0100d54:	c7 44 24 0c 66 5e 10 	movl   $0xf0105e66,0xc(%esp)
f0100d5b:	f0 
f0100d5c:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0100d63:	f0 
f0100d64:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
f0100d6b:	00 
f0100d6c:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100d73:	e8 3e f3 ff ff       	call   f01000b6 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d78:	a1 e0 d1 17 f0       	mov    0xf017d1e0,%eax
f0100d7d:	85 c0                	test   %eax,%eax
f0100d7f:	0f 85 0d fd ff ff    	jne    f0100a92 <check_page_free_list+0x32>
f0100d85:	e9 ec fc ff ff       	jmp    f0100a76 <check_page_free_list+0x16>
f0100d8a:	83 3d e0 d1 17 f0 00 	cmpl   $0x0,0xf017d1e0
f0100d91:	0f 84 df fc ff ff    	je     f0100a76 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d97:	be 00 04 00 00       	mov    $0x400,%esi
f0100d9c:	e9 3f fd ff ff       	jmp    f0100ae0 <check_page_free_list+0x80>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100da1:	83 c4 4c             	add    $0x4c,%esp
f0100da4:	5b                   	pop    %ebx
f0100da5:	5e                   	pop    %esi
f0100da6:	5f                   	pop    %edi
f0100da7:	5d                   	pop    %ebp
f0100da8:	c3                   	ret    

f0100da9 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100da9:	55                   	push   %ebp
f0100daa:	89 e5                	mov    %esp,%ebp
f0100dac:	57                   	push   %edi
f0100dad:	56                   	push   %esi
f0100dae:	53                   	push   %ebx
f0100daf:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	int num_alloc = (PADDR(boot_alloc(0))) / PGSIZE;
f0100db2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100db7:	e8 b4 fb ff ff       	call   f0100970 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100dbc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100dc1:	77 20                	ja     f0100de3 <page_init+0x3a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dc7:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f0100dce:	f0 
f0100dcf:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
f0100dd6:	00 
f0100dd7:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100dde:	e8 d3 f2 ff ff       	call   f01000b6 <_panic>
	int num_iohole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for(i =0; i < npages; i++){
		if(i == 0 || (i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)){
f0100de3:	8b 1d e4 d1 17 f0    	mov    0xf017d1e4,%ebx
	return (physaddr_t)kva - KERNBASE;
f0100de9:	05 00 00 00 10       	add    $0x10000000,%eax
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	
	int num_alloc = (PADDR(boot_alloc(0))) / PGSIZE;
f0100dee:	c1 e8 0c             	shr    $0xc,%eax
	int num_iohole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for(i =0; i < npages; i++){
		if(i == 0 || (i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)){
f0100df1:	8d 74 03 60          	lea    0x60(%ebx,%eax,1),%esi
f0100df5:	8b 0d e0 d1 17 f0    	mov    0xf017d1e0,%ecx
	// free pages!
	size_t i;
	
	int num_alloc = (PADDR(boot_alloc(0))) / PGSIZE;
	int num_iohole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for(i =0; i < npages; i++){
f0100dfb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e00:	eb 49                	jmp    f0100e4b <page_init+0xa2>
		if(i == 0 || (i >= npages_basemem && i < npages_basemem + num_iohole + num_alloc)){
f0100e02:	85 c0                	test   %eax,%eax
f0100e04:	74 0c                	je     f0100e12 <page_init+0x69>
f0100e06:	39 d8                	cmp    %ebx,%eax
f0100e08:	72 1f                	jb     f0100e29 <page_init+0x80>
f0100e0a:	39 f0                	cmp    %esi,%eax
f0100e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100e10:	73 17                	jae    f0100e29 <page_init+0x80>
			pages[i].pp_ref = 1;
f0100e12:	8b 15 ac de 17 f0    	mov    0xf017deac,%edx
f0100e18:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100e1b:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100e21:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0100e27:	eb 1f                	jmp    f0100e48 <page_init+0x9f>
f0100e29:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
		}
		else{
			pages[i].pp_ref = 0;
f0100e30:	89 d7                	mov    %edx,%edi
f0100e32:	03 3d ac de 17 f0    	add    0xf017deac,%edi
f0100e38:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
			pages[i].pp_link = page_free_list;
f0100e3e:	89 0f                	mov    %ecx,(%edi)
			page_free_list = &pages[i];
f0100e40:	89 d1                	mov    %edx,%ecx
f0100e42:	03 0d ac de 17 f0    	add    0xf017deac,%ecx
	// free pages!
	size_t i;
	
	int num_alloc = (PADDR(boot_alloc(0))) / PGSIZE;
	int num_iohole = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	for(i =0; i < npages; i++){
f0100e48:	83 c0 01             	add    $0x1,%eax
f0100e4b:	3b 05 a4 de 17 f0    	cmp    0xf017dea4,%eax
f0100e51:	72 af                	jb     f0100e02 <page_init+0x59>
f0100e53:	89 0d e0 d1 17 f0    	mov    %ecx,0xf017d1e0
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}*/
	
}
f0100e59:	83 c4 1c             	add    $0x1c,%esp
f0100e5c:	5b                   	pop    %ebx
f0100e5d:	5e                   	pop    %esi
f0100e5e:	5f                   	pop    %edi
f0100e5f:	5d                   	pop    %ebp
f0100e60:	c3                   	ret    

f0100e61 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e61:	55                   	push   %ebp
f0100e62:	89 e5                	mov    %esp,%ebp
f0100e64:	53                   	push   %ebx
f0100e65:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	if(page_free_list == NULL) return NULL;
f0100e68:	8b 1d e0 d1 17 f0    	mov    0xf017d1e0,%ebx
f0100e6e:	85 db                	test   %ebx,%ebx
f0100e70:	74 6f                	je     f0100ee1 <page_alloc+0x80>
	
	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
f0100e72:	8b 03                	mov    (%ebx),%eax
f0100e74:	a3 e0 d1 17 f0       	mov    %eax,0xf017d1e0
	page->pp_link = NULL;
f0100e79:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	
	if(alloc_flags & ALLOC_ZERO) memset(page2kva(page), 0, PGSIZE);

	return page;
f0100e7f:	89 d8                	mov    %ebx,%eax
	
	struct PageInfo* page = page_free_list;
	page_free_list = page->pp_link;
	page->pp_link = NULL;
	
	if(alloc_flags & ALLOC_ZERO) memset(page2kva(page), 0, PGSIZE);
f0100e81:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e85:	74 5f                	je     f0100ee6 <page_alloc+0x85>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e87:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f0100e8d:	c1 f8 03             	sar    $0x3,%eax
f0100e90:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e93:	89 c2                	mov    %eax,%edx
f0100e95:	c1 ea 0c             	shr    $0xc,%edx
f0100e98:	3b 15 a4 de 17 f0    	cmp    0xf017dea4,%edx
f0100e9e:	72 20                	jb     f0100ec0 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ea0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ea4:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0100eab:	f0 
f0100eac:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100eb3:	00 
f0100eb4:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f0100ebb:	e8 f6 f1 ff ff       	call   f01000b6 <_panic>
f0100ec0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ec7:	00 
f0100ec8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ecf:	00 
	return (void *)(pa + KERNBASE);
f0100ed0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ed5:	89 04 24             	mov    %eax,(%esp)
f0100ed8:	e8 4a 3d 00 00       	call   f0104c27 <memset>

	return page;
f0100edd:	89 d8                	mov    %ebx,%eax
f0100edf:	eb 05                	jmp    f0100ee6 <page_alloc+0x85>
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
	// Fill this function in
	if(page_free_list == NULL) return NULL;
f0100ee1:	b8 00 00 00 00       	mov    $0x0,%eax
	page->pp_link = NULL;
	
	if(alloc_flags & ALLOC_ZERO) memset(page2kva(page), 0, PGSIZE);

	return page;
}
f0100ee6:	83 c4 14             	add    $0x14,%esp
f0100ee9:	5b                   	pop    %ebx
f0100eea:	5d                   	pop    %ebp
f0100eeb:	c3                   	ret    

f0100eec <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100eec:	55                   	push   %ebp
f0100eed:	89 e5                	mov    %esp,%ebp
f0100eef:	83 ec 18             	sub    $0x18,%esp
f0100ef2:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if(pp->pp_link != NULL || pp->pp_ref != 0){
f0100ef5:	83 38 00             	cmpl   $0x0,(%eax)
f0100ef8:	75 07                	jne    f0100f01 <page_free+0x15>
f0100efa:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100eff:	74 1c                	je     f0100f1d <page_free+0x31>
		panic("fuck");
f0100f01:	c7 44 24 08 77 5e 10 	movl   $0xf0105e77,0x8(%esp)
f0100f08:	f0 
f0100f09:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0100f10:	00 
f0100f11:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100f18:	e8 99 f1 ff ff       	call   f01000b6 <_panic>
		//return ;
	}
	pp->pp_link = page_free_list;
f0100f1d:	8b 15 e0 d1 17 f0    	mov    0xf017d1e0,%edx
f0100f23:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f25:	a3 e0 d1 17 f0       	mov    %eax,0xf017d1e0
	//return;
}
f0100f2a:	c9                   	leave  
f0100f2b:	c3                   	ret    

f0100f2c <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f2c:	55                   	push   %ebp
f0100f2d:	89 e5                	mov    %esp,%ebp
f0100f2f:	83 ec 18             	sub    $0x18,%esp
f0100f32:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100f35:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f0100f39:	8d 51 ff             	lea    -0x1(%ecx),%edx
f0100f3c:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f40:	66 85 d2             	test   %dx,%dx
f0100f43:	75 08                	jne    f0100f4d <page_decref+0x21>
		page_free(pp);
f0100f45:	89 04 24             	mov    %eax,(%esp)
f0100f48:	e8 9f ff ff ff       	call   f0100eec <page_free>
}
f0100f4d:	c9                   	leave  
f0100f4e:	c3                   	ret    

f0100f4f <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f4f:	55                   	push   %ebp
f0100f50:	89 e5                	mov    %esp,%ebp
f0100f52:	56                   	push   %esi
f0100f53:	53                   	push   %ebx
f0100f54:	83 ec 10             	sub    $0x10,%esp
f0100f57:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	int pdeIndex = (unsigned int)va >> 22;
f0100f5a:	89 f3                	mov    %esi,%ebx
f0100f5c:	c1 eb 16             	shr    $0x16,%ebx
	if(pgdir[pdeIndex] == 0 && create ==0) return NULL;
f0100f5f:	c1 e3 02             	shl    $0x2,%ebx
f0100f62:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f65:	83 3b 00             	cmpl   $0x0,(%ebx)
f0100f68:	75 2c                	jne    f0100f96 <pgdir_walk+0x47>
f0100f6a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f6e:	74 6c                	je     f0100fdc <pgdir_walk+0x8d>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
f0100f70:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f77:	e8 e5 fe ff ff       	call   f0100e61 <page_alloc>
		if(page == NULL) return NULL;
f0100f7c:	85 c0                	test   %eax,%eax
f0100f7e:	74 63                	je     f0100fe3 <pgdir_walk+0x94>
		page->pp_ref++;
f0100f80:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f85:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f0100f8b:	c1 f8 03             	sar    $0x3,%eax
f0100f8e:	c1 e0 0c             	shl    $0xc,%eax
		pte_t pgAddress = page2pa(page);
		pgAddress |= PTE_U;
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
f0100f91:	83 c8 07             	or     $0x7,%eax
f0100f94:	89 03                	mov    %eax,(%ebx)
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
f0100f96:	8b 03                	mov    (%ebx),%eax
	pgAdd = pgAdd>>12<<12;
	int pteIndex = (pte_t)va>>12 & 0x3ff;
f0100f98:	c1 ee 0a             	shr    $0xa,%esi
	pte_t * pte = (pte_t *)pgAdd + pteIndex;
f0100f9b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
		pgAddress |= PTE_P;
		pgAddress |= PTE_W;
		pgdir[pdeIndex] = pgAddress;
	}
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd>>12<<12;
f0100fa1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	int pteIndex = (pte_t)va>>12 & 0x3ff;
	pte_t * pte = (pte_t *)pgAdd + pteIndex;
f0100fa6:	01 f0                	add    %esi,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fa8:	89 c2                	mov    %eax,%edx
f0100faa:	c1 ea 0c             	shr    $0xc,%edx
f0100fad:	3b 15 a4 de 17 f0    	cmp    0xf017dea4,%edx
f0100fb3:	72 20                	jb     f0100fd5 <pgdir_walk+0x86>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fb5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb9:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0100fc0:	f0 
f0100fc1:	c7 44 24 04 b1 01 00 	movl   $0x1b1,0x4(%esp)
f0100fc8:	00 
f0100fc9:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0100fd0:	e8 e1 f0 ff ff       	call   f01000b6 <_panic>
	return KADDR((pte_t)pte);
f0100fd5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fda:	eb 0c                	jmp    f0100fe8 <pgdir_walk+0x99>
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	int pdeIndex = (unsigned int)va >> 22;
	if(pgdir[pdeIndex] == 0 && create ==0) return NULL;
f0100fdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fe1:	eb 05                	jmp    f0100fe8 <pgdir_walk+0x99>
	if(pgdir[pdeIndex] == 0){
		struct PageInfo* page = page_alloc(1);
		if(page == NULL) return NULL;
f0100fe3:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pgAdd = pgdir[pdeIndex];
	pgAdd = pgAdd>>12<<12;
	int pteIndex = (pte_t)va>>12 & 0x3ff;
	pte_t * pte = (pte_t *)pgAdd + pteIndex;
	return KADDR((pte_t)pte);
}
f0100fe8:	83 c4 10             	add    $0x10,%esp
f0100feb:	5b                   	pop    %ebx
f0100fec:	5e                   	pop    %esi
f0100fed:	5d                   	pop    %ebp
f0100fee:	c3                   	ret    

f0100fef <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100fef:	55                   	push   %ebp
f0100ff0:	89 e5                	mov    %esp,%ebp
f0100ff2:	57                   	push   %edi
f0100ff3:	56                   	push   %esi
f0100ff4:	53                   	push   %ebx
f0100ff5:	83 ec 2c             	sub    $0x2c,%esp
f0100ff8:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ffb:	89 ce                	mov    %ecx,%esi
	// Fill this function in
	while(size){
f0100ffd:	89 d3                	mov    %edx,%ebx
f0100fff:	8b 45 08             	mov    0x8(%ebp),%eax
f0101002:	29 d0                	sub    %edx,%eax
f0101004:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		pte_t * pte = pgdir_walk(pgdir, (void *)va, 1);
		if(pte == NULL) return ;
		*pte = pa | perm | PTE_P;
f0101007:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100a:	83 c8 01             	or     $0x1,%eax
f010100d:	89 45 dc             	mov    %eax,-0x24(%ebp)
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size){
f0101010:	eb 2c                	jmp    f010103e <boot_map_region+0x4f>
		pte_t * pte = pgdir_walk(pgdir, (void *)va, 1);
f0101012:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101019:	00 
f010101a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010101e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101021:	89 04 24             	mov    %eax,(%esp)
f0101024:	e8 26 ff ff ff       	call   f0100f4f <pgdir_walk>
		if(pte == NULL) return ;
f0101029:	85 c0                	test   %eax,%eax
f010102b:	74 1b                	je     f0101048 <boot_map_region+0x59>
		*pte = pa | perm | PTE_P;
f010102d:	0b 7d dc             	or     -0x24(%ebp),%edi
f0101030:	89 38                	mov    %edi,(%eax)
		
		size -= PGSIZE;
f0101032:	81 ee 00 10 00 00    	sub    $0x1000,%esi
		pa += PGSIZE;
		va += PGSIZE;
f0101038:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010103e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101041:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	while(size){
f0101044:	85 f6                	test   %esi,%esi
f0101046:	75 ca                	jne    f0101012 <boot_map_region+0x23>
		
		size -= PGSIZE;
		pa += PGSIZE;
		va += PGSIZE;
	}
}
f0101048:	83 c4 2c             	add    $0x2c,%esp
f010104b:	5b                   	pop    %ebx
f010104c:	5e                   	pop    %esi
f010104d:	5f                   	pop    %edi
f010104e:	5d                   	pop    %ebp
f010104f:	c3                   	ret    

f0101050 <page_lookup>:
// Return NULL if there is no page mapped at va.
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store){
f0101050:	55                   	push   %ebp
f0101051:	89 e5                	mov    %esp,%ebp
f0101053:	53                   	push   %ebx
f0101054:	83 ec 14             	sub    $0x14,%esp
f0101057:	8b 5d 10             	mov    0x10(%ebp),%ebx

	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, 0);
f010105a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101061:	00 
f0101062:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101065:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101069:	8b 45 08             	mov    0x8(%ebp),%eax
f010106c:	89 04 24             	mov    %eax,(%esp)
f010106f:	e8 db fe ff ff       	call   f0100f4f <pgdir_walk>
	if(pte == NULL) return NULL;
f0101074:	85 c0                	test   %eax,%eax
f0101076:	74 42                	je     f01010ba <page_lookup+0x6a>
	pte_t pa = *pte>>12<<12;
f0101078:	8b 10                	mov    (%eax),%edx
f010107a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if(pte_store != 0) *pte_store = pte;
f0101080:	85 db                	test   %ebx,%ebx
f0101082:	74 02                	je     f0101086 <page_lookup+0x36>
f0101084:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101086:	89 d0                	mov    %edx,%eax
f0101088:	c1 e8 0c             	shr    $0xc,%eax
f010108b:	3b 05 a4 de 17 f0    	cmp    0xf017dea4,%eax
f0101091:	72 1c                	jb     f01010af <page_lookup+0x5f>
		panic("pa2page called with invalid pa");
f0101093:	c7 44 24 08 10 57 10 	movl   $0xf0105710,0x8(%esp)
f010109a:	f0 
f010109b:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01010a2:	00 
f01010a3:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f01010aa:	e8 07 f0 ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f01010af:	8b 15 ac de 17 f0    	mov    0xf017deac,%edx
f01010b5:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	return pa2page(pa);
f01010b8:	eb 05                	jmp    f01010bf <page_lookup+0x6f>
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store){

	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, 0);
	if(pte == NULL) return NULL;
f01010ba:	b8 00 00 00 00       	mov    $0x0,%eax
	pte_t pa = *pte>>12<<12;
	if(pte_store != 0) *pte_store = pte;
	return pa2page(pa);
}
f01010bf:	83 c4 14             	add    $0x14,%esp
f01010c2:	5b                   	pop    %ebx
f01010c3:	5d                   	pop    %ebp
f01010c4:	c3                   	ret    

f01010c5 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010c5:	55                   	push   %ebp
f01010c6:	89 e5                	mov    %esp,%ebp
f01010c8:	53                   	push   %ebx
f01010c9:	83 ec 24             	sub    $0x24,%esp
f01010cc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t * pte;
	struct PageInfo * page = page_lookup(pgdir, va , &pte);
f01010cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010da:	8b 45 08             	mov    0x8(%ebp),%eax
f01010dd:	89 04 24             	mov    %eax,(%esp)
f01010e0:	e8 6b ff ff ff       	call   f0101050 <page_lookup>
	if(page == 0) return;
f01010e5:	85 c0                	test   %eax,%eax
f01010e7:	74 24                	je     f010110d <page_remove+0x48>
	*pte = 0;
f01010e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01010ec:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	page->pp_ref--;
f01010f2:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
f01010f6:	8d 51 ff             	lea    -0x1(%ecx),%edx
f01010f9:	66 89 50 04          	mov    %dx,0x4(%eax)
	if(page->pp_ref == 0) page_free(page);
f01010fd:	66 85 d2             	test   %dx,%dx
f0101100:	75 08                	jne    f010110a <page_remove+0x45>
f0101102:	89 04 24             	mov    %eax,(%esp)
f0101105:	e8 e2 fd ff ff       	call   f0100eec <page_free>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010110a:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
}
f010110d:	83 c4 24             	add    $0x24,%esp
f0101110:	5b                   	pop    %ebx
f0101111:	5d                   	pop    %ebp
f0101112:	c3                   	ret    

f0101113 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101113:	55                   	push   %ebp
f0101114:	89 e5                	mov    %esp,%ebp
f0101116:	57                   	push   %edi
f0101117:	56                   	push   %esi
f0101118:	53                   	push   %ebx
f0101119:	83 ec 1c             	sub    $0x1c,%esp
f010111c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010111f:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, 1);
f0101122:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101129:	00 
f010112a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010112e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101131:	89 04 24             	mov    %eax,(%esp)
f0101134:	e8 16 fe ff ff       	call   f0100f4f <pgdir_walk>
f0101139:	89 c6                	mov    %eax,%esi
	if(pte == NULL) return -E_NO_MEM;
f010113b:	85 c0                	test   %eax,%eax
f010113d:	74 5a                	je     f0101199 <page_insert+0x86>

	if((pte[0] & ~0xfff) == page2pa(pp)) pp->pp_ref--;
f010113f:	8b 00                	mov    (%eax),%eax
f0101141:	89 c1                	mov    %eax,%ecx
f0101143:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101149:	89 da                	mov    %ebx,%edx
f010114b:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f0101151:	c1 fa 03             	sar    $0x3,%edx
f0101154:	c1 e2 0c             	shl    $0xc,%edx
f0101157:	39 d1                	cmp    %edx,%ecx
f0101159:	75 07                	jne    f0101162 <page_insert+0x4f>
f010115b:	66 83 6b 04 01       	subw   $0x1,0x4(%ebx)
f0101160:	eb 13                	jmp    f0101175 <page_insert+0x62>
	else if(*pte != 0) page_remove(pgdir, va);
f0101162:	85 c0                	test   %eax,%eax
f0101164:	74 0f                	je     f0101175 <page_insert+0x62>
f0101166:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010116a:	8b 45 08             	mov    0x8(%ebp),%eax
f010116d:	89 04 24             	mov    %eax,(%esp)
f0101170:	e8 50 ff ff ff       	call   f01010c5 <page_remove>
	
	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
f0101175:	8b 55 14             	mov    0x14(%ebp),%edx
f0101178:	83 ca 01             	or     $0x1,%edx
f010117b:	89 d8                	mov    %ebx,%eax
f010117d:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f0101183:	c1 f8 03             	sar    $0x3,%eax
f0101186:	c1 e0 0c             	shl    $0xc,%eax
f0101189:	09 d0                	or     %edx,%eax
f010118b:	89 06                	mov    %eax,(%esi)
	pp->pp_ref++;
f010118d:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	return 0;
f0101192:	b8 00 00 00 00       	mov    $0x0,%eax
f0101197:	eb 05                	jmp    f010119e <page_insert+0x8b>
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
	// Fill this function in
	pte_t * pte = pgdir_walk(pgdir, va, 1);
	if(pte == NULL) return -E_NO_MEM;
f0101199:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	else if(*pte != 0) page_remove(pgdir, va);
	
	*pte = (page2pa(pp) & ~0xfff) | perm | PTE_P;
	pp->pp_ref++;
	return 0;
}
f010119e:	83 c4 1c             	add    $0x1c,%esp
f01011a1:	5b                   	pop    %ebx
f01011a2:	5e                   	pop    %esi
f01011a3:	5f                   	pop    %edi
f01011a4:	5d                   	pop    %ebp
f01011a5:	c3                   	ret    

f01011a6 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01011a6:	55                   	push   %ebp
f01011a7:	89 e5                	mov    %esp,%ebp
f01011a9:	57                   	push   %edi
f01011aa:	56                   	push   %esi
f01011ab:	53                   	push   %ebx
f01011ac:	83 ec 4c             	sub    $0x4c,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01011af:	c7 04 24 15 00 00 00 	movl   $0x15,(%esp)
f01011b6:	e8 cc 24 00 00       	call   f0103687 <mc146818_read>
f01011bb:	89 c3                	mov    %eax,%ebx
f01011bd:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01011c4:	e8 be 24 00 00       	call   f0103687 <mc146818_read>
f01011c9:	c1 e0 08             	shl    $0x8,%eax
f01011cc:	09 c3                	or     %eax,%ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01011ce:	89 d8                	mov    %ebx,%eax
f01011d0:	c1 e0 0a             	shl    $0xa,%eax
f01011d3:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f01011d9:	85 c0                	test   %eax,%eax
f01011db:	0f 48 c2             	cmovs  %edx,%eax
f01011de:	c1 f8 0c             	sar    $0xc,%eax
f01011e1:	a3 e4 d1 17 f0       	mov    %eax,0xf017d1e4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01011e6:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01011ed:	e8 95 24 00 00       	call   f0103687 <mc146818_read>
f01011f2:	89 c3                	mov    %eax,%ebx
f01011f4:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01011fb:	e8 87 24 00 00       	call   f0103687 <mc146818_read>
f0101200:	c1 e0 08             	shl    $0x8,%eax
f0101203:	09 c3                	or     %eax,%ebx
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0101205:	89 d8                	mov    %ebx,%eax
f0101207:	c1 e0 0a             	shl    $0xa,%eax
f010120a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0101210:	85 c0                	test   %eax,%eax
f0101212:	0f 48 c2             	cmovs  %edx,%eax
f0101215:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0101218:	85 c0                	test   %eax,%eax
f010121a:	74 0e                	je     f010122a <mem_init+0x84>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f010121c:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0101222:	89 15 a4 de 17 f0    	mov    %edx,0xf017dea4
f0101228:	eb 0c                	jmp    f0101236 <mem_init+0x90>
	else
		npages = npages_basemem;
f010122a:	8b 15 e4 d1 17 f0    	mov    0xf017d1e4,%edx
f0101230:	89 15 a4 de 17 f0    	mov    %edx,0xf017dea4

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101236:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101239:	c1 e8 0a             	shr    $0xa,%eax
f010123c:	89 44 24 0c          	mov    %eax,0xc(%esp)
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0101240:	a1 e4 d1 17 f0       	mov    0xf017d1e4,%eax
f0101245:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101248:	c1 e8 0a             	shr    $0xa,%eax
f010124b:	89 44 24 08          	mov    %eax,0x8(%esp)
		npages * PGSIZE / 1024,
f010124f:	a1 a4 de 17 f0       	mov    0xf017dea4,%eax
f0101254:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101257:	c1 e8 0a             	shr    $0xa,%eax
f010125a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010125e:	c7 04 24 30 57 10 f0 	movl   $0xf0105730,(%esp)
f0101265:	e8 8d 24 00 00       	call   f01036f7 <cprintf>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010126a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010126f:	e8 fc f6 ff ff       	call   f0100970 <boot_alloc>
f0101274:	a3 a8 de 17 f0       	mov    %eax,0xf017dea8
	memset(kern_pgdir, 0, PGSIZE);
f0101279:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101280:	00 
f0101281:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101288:	00 
f0101289:	89 04 24             	mov    %eax,(%esp)
f010128c:	e8 96 39 00 00       	call   f0104c27 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101291:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101296:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010129b:	77 20                	ja     f01012bd <mem_init+0x117>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010129d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012a1:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f01012a8:	f0 
f01012a9:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f01012b0:	00 
f01012b1:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01012b8:	e8 f9 ed ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01012bd:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012c3:	83 ca 05             	or     $0x5,%edx
f01012c6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo * )boot_alloc(npages * sizeof(struct PageInfo));
f01012cc:	a1 a4 de 17 f0       	mov    0xf017dea4,%eax
f01012d1:	c1 e0 03             	shl    $0x3,%eax
f01012d4:	e8 97 f6 ff ff       	call   f0100970 <boot_alloc>
f01012d9:	a3 ac de 17 f0       	mov    %eax,0xf017deac
	memset(pages, 0, npages * sizeof(struct PageInfo));
f01012de:	8b 3d a4 de 17 f0    	mov    0xf017dea4,%edi
f01012e4:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01012eb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01012ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01012f6:	00 
f01012f7:	89 04 24             	mov    %eax,(%esp)
f01012fa:	e8 28 39 00 00       	call   f0104c27 <memset>
	
	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.

	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f01012ff:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101304:	e8 67 f6 ff ff       	call   f0100970 <boot_alloc>
f0101309:	a3 ec d1 17 f0       	mov    %eax,0xf017d1ec
	memset(envs, 0, NENV * sizeof(struct Env));
f010130e:	c7 44 24 08 00 80 01 	movl   $0x18000,0x8(%esp)
f0101315:	00 
f0101316:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010131d:	00 
f010131e:	89 04 24             	mov    %eax,(%esp)
f0101321:	e8 01 39 00 00       	call   f0104c27 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101326:	e8 7e fa ff ff       	call   f0100da9 <page_init>

	check_page_free_list(1);
f010132b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101330:	e8 2b f7 ff ff       	call   f0100a60 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101335:	83 3d ac de 17 f0 00 	cmpl   $0x0,0xf017deac
f010133c:	75 1c                	jne    f010135a <mem_init+0x1b4>
		panic("'pages' is a null pointer!");
f010133e:	c7 44 24 08 7c 5e 10 	movl   $0xf0105e7c,0x8(%esp)
f0101345:	f0 
f0101346:	c7 44 24 04 b9 02 00 	movl   $0x2b9,0x4(%esp)
f010134d:	00 
f010134e:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101355:	e8 5c ed ff ff       	call   f01000b6 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010135a:	a1 e0 d1 17 f0       	mov    0xf017d1e0,%eax
f010135f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101364:	eb 05                	jmp    f010136b <mem_init+0x1c5>
		++nfree;
f0101366:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101369:	8b 00                	mov    (%eax),%eax
f010136b:	85 c0                	test   %eax,%eax
f010136d:	75 f7                	jne    f0101366 <mem_init+0x1c0>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010136f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101376:	e8 e6 fa ff ff       	call   f0100e61 <page_alloc>
f010137b:	89 c7                	mov    %eax,%edi
f010137d:	85 c0                	test   %eax,%eax
f010137f:	75 24                	jne    f01013a5 <mem_init+0x1ff>
f0101381:	c7 44 24 0c 97 5e 10 	movl   $0xf0105e97,0xc(%esp)
f0101388:	f0 
f0101389:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101390:	f0 
f0101391:	c7 44 24 04 c1 02 00 	movl   $0x2c1,0x4(%esp)
f0101398:	00 
f0101399:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01013a0:	e8 11 ed ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f01013a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013ac:	e8 b0 fa ff ff       	call   f0100e61 <page_alloc>
f01013b1:	89 c6                	mov    %eax,%esi
f01013b3:	85 c0                	test   %eax,%eax
f01013b5:	75 24                	jne    f01013db <mem_init+0x235>
f01013b7:	c7 44 24 0c ad 5e 10 	movl   $0xf0105ead,0xc(%esp)
f01013be:	f0 
f01013bf:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01013c6:	f0 
f01013c7:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f01013ce:	00 
f01013cf:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01013d6:	e8 db ec ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f01013db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013e2:	e8 7a fa ff ff       	call   f0100e61 <page_alloc>
f01013e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013ea:	85 c0                	test   %eax,%eax
f01013ec:	75 24                	jne    f0101412 <mem_init+0x26c>
f01013ee:	c7 44 24 0c c3 5e 10 	movl   $0xf0105ec3,0xc(%esp)
f01013f5:	f0 
f01013f6:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01013fd:	f0 
f01013fe:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0101405:	00 
f0101406:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010140d:	e8 a4 ec ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101412:	39 f7                	cmp    %esi,%edi
f0101414:	75 24                	jne    f010143a <mem_init+0x294>
f0101416:	c7 44 24 0c d9 5e 10 	movl   $0xf0105ed9,0xc(%esp)
f010141d:	f0 
f010141e:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101425:	f0 
f0101426:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f010142d:	00 
f010142e:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101435:	e8 7c ec ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010143a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010143d:	39 c6                	cmp    %eax,%esi
f010143f:	74 04                	je     f0101445 <mem_init+0x29f>
f0101441:	39 c7                	cmp    %eax,%edi
f0101443:	75 24                	jne    f0101469 <mem_init+0x2c3>
f0101445:	c7 44 24 0c 6c 57 10 	movl   $0xf010576c,0xc(%esp)
f010144c:	f0 
f010144d:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101454:	f0 
f0101455:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f010145c:	00 
f010145d:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101464:	e8 4d ec ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101469:	8b 15 ac de 17 f0    	mov    0xf017deac,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f010146f:	a1 a4 de 17 f0       	mov    0xf017dea4,%eax
f0101474:	c1 e0 0c             	shl    $0xc,%eax
f0101477:	89 f9                	mov    %edi,%ecx
f0101479:	29 d1                	sub    %edx,%ecx
f010147b:	c1 f9 03             	sar    $0x3,%ecx
f010147e:	c1 e1 0c             	shl    $0xc,%ecx
f0101481:	39 c1                	cmp    %eax,%ecx
f0101483:	72 24                	jb     f01014a9 <mem_init+0x303>
f0101485:	c7 44 24 0c eb 5e 10 	movl   $0xf0105eeb,0xc(%esp)
f010148c:	f0 
f010148d:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101494:	f0 
f0101495:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
f010149c:	00 
f010149d:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01014a4:	e8 0d ec ff ff       	call   f01000b6 <_panic>
f01014a9:	89 f1                	mov    %esi,%ecx
f01014ab:	29 d1                	sub    %edx,%ecx
f01014ad:	c1 f9 03             	sar    $0x3,%ecx
f01014b0:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01014b3:	39 c8                	cmp    %ecx,%eax
f01014b5:	77 24                	ja     f01014db <mem_init+0x335>
f01014b7:	c7 44 24 0c 08 5f 10 	movl   $0xf0105f08,0xc(%esp)
f01014be:	f0 
f01014bf:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01014c6:	f0 
f01014c7:	c7 44 24 04 c9 02 00 	movl   $0x2c9,0x4(%esp)
f01014ce:	00 
f01014cf:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01014d6:	e8 db eb ff ff       	call   f01000b6 <_panic>
f01014db:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01014de:	29 d1                	sub    %edx,%ecx
f01014e0:	89 ca                	mov    %ecx,%edx
f01014e2:	c1 fa 03             	sar    $0x3,%edx
f01014e5:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01014e8:	39 d0                	cmp    %edx,%eax
f01014ea:	77 24                	ja     f0101510 <mem_init+0x36a>
f01014ec:	c7 44 24 0c 25 5f 10 	movl   $0xf0105f25,0xc(%esp)
f01014f3:	f0 
f01014f4:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01014fb:	f0 
f01014fc:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101503:	00 
f0101504:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010150b:	e8 a6 eb ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101510:	a1 e0 d1 17 f0       	mov    0xf017d1e0,%eax
f0101515:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101518:	c7 05 e0 d1 17 f0 00 	movl   $0x0,0xf017d1e0
f010151f:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101522:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101529:	e8 33 f9 ff ff       	call   f0100e61 <page_alloc>
f010152e:	85 c0                	test   %eax,%eax
f0101530:	74 24                	je     f0101556 <mem_init+0x3b0>
f0101532:	c7 44 24 0c 42 5f 10 	movl   $0xf0105f42,0xc(%esp)
f0101539:	f0 
f010153a:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101541:	f0 
f0101542:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101549:	00 
f010154a:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101551:	e8 60 eb ff ff       	call   f01000b6 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101556:	89 3c 24             	mov    %edi,(%esp)
f0101559:	e8 8e f9 ff ff       	call   f0100eec <page_free>
	page_free(pp1);
f010155e:	89 34 24             	mov    %esi,(%esp)
f0101561:	e8 86 f9 ff ff       	call   f0100eec <page_free>
	page_free(pp2);
f0101566:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101569:	89 04 24             	mov    %eax,(%esp)
f010156c:	e8 7b f9 ff ff       	call   f0100eec <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101571:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101578:	e8 e4 f8 ff ff       	call   f0100e61 <page_alloc>
f010157d:	89 c6                	mov    %eax,%esi
f010157f:	85 c0                	test   %eax,%eax
f0101581:	75 24                	jne    f01015a7 <mem_init+0x401>
f0101583:	c7 44 24 0c 97 5e 10 	movl   $0xf0105e97,0xc(%esp)
f010158a:	f0 
f010158b:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101592:	f0 
f0101593:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010159a:	00 
f010159b:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01015a2:	e8 0f eb ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f01015a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ae:	e8 ae f8 ff ff       	call   f0100e61 <page_alloc>
f01015b3:	89 c7                	mov    %eax,%edi
f01015b5:	85 c0                	test   %eax,%eax
f01015b7:	75 24                	jne    f01015dd <mem_init+0x437>
f01015b9:	c7 44 24 0c ad 5e 10 	movl   $0xf0105ead,0xc(%esp)
f01015c0:	f0 
f01015c1:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01015c8:	f0 
f01015c9:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f01015d0:	00 
f01015d1:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01015d8:	e8 d9 ea ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f01015dd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015e4:	e8 78 f8 ff ff       	call   f0100e61 <page_alloc>
f01015e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01015ec:	85 c0                	test   %eax,%eax
f01015ee:	75 24                	jne    f0101614 <mem_init+0x46e>
f01015f0:	c7 44 24 0c c3 5e 10 	movl   $0xf0105ec3,0xc(%esp)
f01015f7:	f0 
f01015f8:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01015ff:	f0 
f0101600:	c7 44 24 04 da 02 00 	movl   $0x2da,0x4(%esp)
f0101607:	00 
f0101608:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010160f:	e8 a2 ea ff ff       	call   f01000b6 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101614:	39 fe                	cmp    %edi,%esi
f0101616:	75 24                	jne    f010163c <mem_init+0x496>
f0101618:	c7 44 24 0c d9 5e 10 	movl   $0xf0105ed9,0xc(%esp)
f010161f:	f0 
f0101620:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101627:	f0 
f0101628:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f010162f:	00 
f0101630:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101637:	e8 7a ea ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010163c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010163f:	39 c7                	cmp    %eax,%edi
f0101641:	74 04                	je     f0101647 <mem_init+0x4a1>
f0101643:	39 c6                	cmp    %eax,%esi
f0101645:	75 24                	jne    f010166b <mem_init+0x4c5>
f0101647:	c7 44 24 0c 6c 57 10 	movl   $0xf010576c,0xc(%esp)
f010164e:	f0 
f010164f:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101656:	f0 
f0101657:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f010165e:	00 
f010165f:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101666:	e8 4b ea ff ff       	call   f01000b6 <_panic>
	assert(!page_alloc(0));
f010166b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101672:	e8 ea f7 ff ff       	call   f0100e61 <page_alloc>
f0101677:	85 c0                	test   %eax,%eax
f0101679:	74 24                	je     f010169f <mem_init+0x4f9>
f010167b:	c7 44 24 0c 42 5f 10 	movl   $0xf0105f42,0xc(%esp)
f0101682:	f0 
f0101683:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010168a:	f0 
f010168b:	c7 44 24 04 de 02 00 	movl   $0x2de,0x4(%esp)
f0101692:	00 
f0101693:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010169a:	e8 17 ea ff ff       	call   f01000b6 <_panic>
f010169f:	89 f0                	mov    %esi,%eax
f01016a1:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f01016a7:	c1 f8 03             	sar    $0x3,%eax
f01016aa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016ad:	89 c2                	mov    %eax,%edx
f01016af:	c1 ea 0c             	shr    $0xc,%edx
f01016b2:	3b 15 a4 de 17 f0    	cmp    0xf017dea4,%edx
f01016b8:	72 20                	jb     f01016da <mem_init+0x534>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016be:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f01016c5:	f0 
f01016c6:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01016cd:	00 
f01016ce:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f01016d5:	e8 dc e9 ff ff       	call   f01000b6 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01016da:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01016e1:	00 
f01016e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01016e9:	00 
	return (void *)(pa + KERNBASE);
f01016ea:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016ef:	89 04 24             	mov    %eax,(%esp)
f01016f2:	e8 30 35 00 00       	call   f0104c27 <memset>
	page_free(pp0);
f01016f7:	89 34 24             	mov    %esi,(%esp)
f01016fa:	e8 ed f7 ff ff       	call   f0100eec <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01016ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101706:	e8 56 f7 ff ff       	call   f0100e61 <page_alloc>
f010170b:	85 c0                	test   %eax,%eax
f010170d:	75 24                	jne    f0101733 <mem_init+0x58d>
f010170f:	c7 44 24 0c 51 5f 10 	movl   $0xf0105f51,0xc(%esp)
f0101716:	f0 
f0101717:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010171e:	f0 
f010171f:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0101726:	00 
f0101727:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010172e:	e8 83 e9 ff ff       	call   f01000b6 <_panic>
	assert(pp && pp0 == pp);
f0101733:	39 c6                	cmp    %eax,%esi
f0101735:	74 24                	je     f010175b <mem_init+0x5b5>
f0101737:	c7 44 24 0c 6f 5f 10 	movl   $0xf0105f6f,0xc(%esp)
f010173e:	f0 
f010173f:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101746:	f0 
f0101747:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f010174e:	00 
f010174f:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101756:	e8 5b e9 ff ff       	call   f01000b6 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010175b:	89 f0                	mov    %esi,%eax
f010175d:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f0101763:	c1 f8 03             	sar    $0x3,%eax
f0101766:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101769:	89 c2                	mov    %eax,%edx
f010176b:	c1 ea 0c             	shr    $0xc,%edx
f010176e:	3b 15 a4 de 17 f0    	cmp    0xf017dea4,%edx
f0101774:	72 20                	jb     f0101796 <mem_init+0x5f0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101776:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010177a:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0101781:	f0 
f0101782:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101789:	00 
f010178a:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f0101791:	e8 20 e9 ff ff       	call   f01000b6 <_panic>
f0101796:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010179c:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01017a2:	80 38 00             	cmpb   $0x0,(%eax)
f01017a5:	74 24                	je     f01017cb <mem_init+0x625>
f01017a7:	c7 44 24 0c 7f 5f 10 	movl   $0xf0105f7f,0xc(%esp)
f01017ae:	f0 
f01017af:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01017b6:	f0 
f01017b7:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f01017be:	00 
f01017bf:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01017c6:	e8 eb e8 ff ff       	call   f01000b6 <_panic>
f01017cb:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01017ce:	39 d0                	cmp    %edx,%eax
f01017d0:	75 d0                	jne    f01017a2 <mem_init+0x5fc>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01017d2:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01017d5:	a3 e0 d1 17 f0       	mov    %eax,0xf017d1e0

	// free the pages we took
	page_free(pp0);
f01017da:	89 34 24             	mov    %esi,(%esp)
f01017dd:	e8 0a f7 ff ff       	call   f0100eec <page_free>
	page_free(pp1);
f01017e2:	89 3c 24             	mov    %edi,(%esp)
f01017e5:	e8 02 f7 ff ff       	call   f0100eec <page_free>
	page_free(pp2);
f01017ea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017ed:	89 04 24             	mov    %eax,(%esp)
f01017f0:	e8 f7 f6 ff ff       	call   f0100eec <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017f5:	a1 e0 d1 17 f0       	mov    0xf017d1e0,%eax
f01017fa:	eb 05                	jmp    f0101801 <mem_init+0x65b>
		--nfree;
f01017fc:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01017ff:	8b 00                	mov    (%eax),%eax
f0101801:	85 c0                	test   %eax,%eax
f0101803:	75 f7                	jne    f01017fc <mem_init+0x656>
		--nfree;
	assert(nfree == 0);
f0101805:	85 db                	test   %ebx,%ebx
f0101807:	74 24                	je     f010182d <mem_init+0x687>
f0101809:	c7 44 24 0c 89 5f 10 	movl   $0xf0105f89,0xc(%esp)
f0101810:	f0 
f0101811:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101818:	f0 
f0101819:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0101820:	00 
f0101821:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101828:	e8 89 e8 ff ff       	call   f01000b6 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010182d:	c7 04 24 8c 57 10 f0 	movl   $0xf010578c,(%esp)
f0101834:	e8 be 1e 00 00       	call   f01036f7 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101839:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101840:	e8 1c f6 ff ff       	call   f0100e61 <page_alloc>
f0101845:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101848:	85 c0                	test   %eax,%eax
f010184a:	75 24                	jne    f0101870 <mem_init+0x6ca>
f010184c:	c7 44 24 0c 97 5e 10 	movl   $0xf0105e97,0xc(%esp)
f0101853:	f0 
f0101854:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010185b:	f0 
f010185c:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f0101863:	00 
f0101864:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010186b:	e8 46 e8 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f0101870:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101877:	e8 e5 f5 ff ff       	call   f0100e61 <page_alloc>
f010187c:	89 c3                	mov    %eax,%ebx
f010187e:	85 c0                	test   %eax,%eax
f0101880:	75 24                	jne    f01018a6 <mem_init+0x700>
f0101882:	c7 44 24 0c ad 5e 10 	movl   $0xf0105ead,0xc(%esp)
f0101889:	f0 
f010188a:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101891:	f0 
f0101892:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101899:	00 
f010189a:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01018a1:	e8 10 e8 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f01018a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018ad:	e8 af f5 ff ff       	call   f0100e61 <page_alloc>
f01018b2:	89 c6                	mov    %eax,%esi
f01018b4:	85 c0                	test   %eax,%eax
f01018b6:	75 24                	jne    f01018dc <mem_init+0x736>
f01018b8:	c7 44 24 0c c3 5e 10 	movl   $0xf0105ec3,0xc(%esp)
f01018bf:	f0 
f01018c0:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01018c7:	f0 
f01018c8:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01018cf:	00 
f01018d0:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01018d7:	e8 da e7 ff ff       	call   f01000b6 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01018dc:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01018df:	75 24                	jne    f0101905 <mem_init+0x75f>
f01018e1:	c7 44 24 0c d9 5e 10 	movl   $0xf0105ed9,0xc(%esp)
f01018e8:	f0 
f01018e9:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01018f0:	f0 
f01018f1:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f01018f8:	00 
f01018f9:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101900:	e8 b1 e7 ff ff       	call   f01000b6 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101905:	39 c3                	cmp    %eax,%ebx
f0101907:	74 05                	je     f010190e <mem_init+0x768>
f0101909:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010190c:	75 24                	jne    f0101932 <mem_init+0x78c>
f010190e:	c7 44 24 0c 6c 57 10 	movl   $0xf010576c,0xc(%esp)
f0101915:	f0 
f0101916:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010191d:	f0 
f010191e:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f0101925:	00 
f0101926:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010192d:	e8 84 e7 ff ff       	call   f01000b6 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101932:	a1 e0 d1 17 f0       	mov    0xf017d1e0,%eax
f0101937:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010193a:	c7 05 e0 d1 17 f0 00 	movl   $0x0,0xf017d1e0
f0101941:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101944:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010194b:	e8 11 f5 ff ff       	call   f0100e61 <page_alloc>
f0101950:	85 c0                	test   %eax,%eax
f0101952:	74 24                	je     f0101978 <mem_init+0x7d2>
f0101954:	c7 44 24 0c 42 5f 10 	movl   $0xf0105f42,0xc(%esp)
f010195b:	f0 
f010195c:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101963:	f0 
f0101964:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f010196b:	00 
f010196c:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101973:	e8 3e e7 ff ff       	call   f01000b6 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101978:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010197b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010197f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101986:	00 
f0101987:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010198c:	89 04 24             	mov    %eax,(%esp)
f010198f:	e8 bc f6 ff ff       	call   f0101050 <page_lookup>
f0101994:	85 c0                	test   %eax,%eax
f0101996:	74 24                	je     f01019bc <mem_init+0x816>
f0101998:	c7 44 24 0c ac 57 10 	movl   $0xf01057ac,0xc(%esp)
f010199f:	f0 
f01019a0:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01019a7:	f0 
f01019a8:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f01019af:	00 
f01019b0:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01019b7:	e8 fa e6 ff ff       	call   f01000b6 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01019bc:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01019c3:	00 
f01019c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01019cb:	00 
f01019cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019d0:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f01019d5:	89 04 24             	mov    %eax,(%esp)
f01019d8:	e8 36 f7 ff ff       	call   f0101113 <page_insert>
f01019dd:	85 c0                	test   %eax,%eax
f01019df:	78 24                	js     f0101a05 <mem_init+0x85f>
f01019e1:	c7 44 24 0c e4 57 10 	movl   $0xf01057e4,0xc(%esp)
f01019e8:	f0 
f01019e9:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01019f0:	f0 
f01019f1:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f01019f8:	00 
f01019f9:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101a00:	e8 b1 e6 ff ff       	call   f01000b6 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101a05:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a08:	89 04 24             	mov    %eax,(%esp)
f0101a0b:	e8 dc f4 ff ff       	call   f0100eec <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101a10:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a17:	00 
f0101a18:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a1f:	00 
f0101a20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a24:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101a29:	89 04 24             	mov    %eax,(%esp)
f0101a2c:	e8 e2 f6 ff ff       	call   f0101113 <page_insert>
f0101a31:	85 c0                	test   %eax,%eax
f0101a33:	74 24                	je     f0101a59 <mem_init+0x8b3>
f0101a35:	c7 44 24 0c 14 58 10 	movl   $0xf0105814,0xc(%esp)
f0101a3c:	f0 
f0101a3d:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101a44:	f0 
f0101a45:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0101a4c:	00 
f0101a4d:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101a54:	e8 5d e6 ff ff       	call   f01000b6 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101a59:	8b 3d a8 de 17 f0    	mov    0xf017dea8,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101a5f:	a1 ac de 17 f0       	mov    0xf017deac,%eax
f0101a64:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101a67:	8b 17                	mov    (%edi),%edx
f0101a69:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101a6f:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101a72:	29 c1                	sub    %eax,%ecx
f0101a74:	89 c8                	mov    %ecx,%eax
f0101a76:	c1 f8 03             	sar    $0x3,%eax
f0101a79:	c1 e0 0c             	shl    $0xc,%eax
f0101a7c:	39 c2                	cmp    %eax,%edx
f0101a7e:	74 24                	je     f0101aa4 <mem_init+0x8fe>
f0101a80:	c7 44 24 0c 44 58 10 	movl   $0xf0105844,0xc(%esp)
f0101a87:	f0 
f0101a88:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101a8f:	f0 
f0101a90:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101a97:	00 
f0101a98:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101a9f:	e8 12 e6 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101aa4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101aa9:	89 f8                	mov    %edi,%eax
f0101aab:	e8 41 ef ff ff       	call   f01009f1 <check_va2pa>
f0101ab0:	89 da                	mov    %ebx,%edx
f0101ab2:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101ab5:	c1 fa 03             	sar    $0x3,%edx
f0101ab8:	c1 e2 0c             	shl    $0xc,%edx
f0101abb:	39 d0                	cmp    %edx,%eax
f0101abd:	74 24                	je     f0101ae3 <mem_init+0x93d>
f0101abf:	c7 44 24 0c 6c 58 10 	movl   $0xf010586c,0xc(%esp)
f0101ac6:	f0 
f0101ac7:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101ace:	f0 
f0101acf:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0101ad6:	00 
f0101ad7:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101ade:	e8 d3 e5 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0101ae3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ae8:	74 24                	je     f0101b0e <mem_init+0x968>
f0101aea:	c7 44 24 0c 94 5f 10 	movl   $0xf0105f94,0xc(%esp)
f0101af1:	f0 
f0101af2:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101af9:	f0 
f0101afa:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0101b01:	00 
f0101b02:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101b09:	e8 a8 e5 ff ff       	call   f01000b6 <_panic>
	assert(pp0->pp_ref == 1);
f0101b0e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101b11:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101b16:	74 24                	je     f0101b3c <mem_init+0x996>
f0101b18:	c7 44 24 0c a5 5f 10 	movl   $0xf0105fa5,0xc(%esp)
f0101b1f:	f0 
f0101b20:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101b27:	f0 
f0101b28:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101b2f:	00 
f0101b30:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101b37:	e8 7a e5 ff ff       	call   f01000b6 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b3c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b43:	00 
f0101b44:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b4b:	00 
f0101b4c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b50:	89 3c 24             	mov    %edi,(%esp)
f0101b53:	e8 bb f5 ff ff       	call   f0101113 <page_insert>
f0101b58:	85 c0                	test   %eax,%eax
f0101b5a:	74 24                	je     f0101b80 <mem_init+0x9da>
f0101b5c:	c7 44 24 0c 9c 58 10 	movl   $0xf010589c,0xc(%esp)
f0101b63:	f0 
f0101b64:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101b6b:	f0 
f0101b6c:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0101b73:	00 
f0101b74:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101b7b:	e8 36 e5 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b80:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b85:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101b8a:	e8 62 ee ff ff       	call   f01009f1 <check_va2pa>
f0101b8f:	89 f2                	mov    %esi,%edx
f0101b91:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f0101b97:	c1 fa 03             	sar    $0x3,%edx
f0101b9a:	c1 e2 0c             	shl    $0xc,%edx
f0101b9d:	39 d0                	cmp    %edx,%eax
f0101b9f:	74 24                	je     f0101bc5 <mem_init+0xa1f>
f0101ba1:	c7 44 24 0c d8 58 10 	movl   $0xf01058d8,0xc(%esp)
f0101ba8:	f0 
f0101ba9:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101bb0:	f0 
f0101bb1:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0101bb8:	00 
f0101bb9:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101bc0:	e8 f1 e4 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101bc5:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bca:	74 24                	je     f0101bf0 <mem_init+0xa4a>
f0101bcc:	c7 44 24 0c b6 5f 10 	movl   $0xf0105fb6,0xc(%esp)
f0101bd3:	f0 
f0101bd4:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101bdb:	f0 
f0101bdc:	c7 44 24 04 72 03 00 	movl   $0x372,0x4(%esp)
f0101be3:	00 
f0101be4:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101beb:	e8 c6 e4 ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101bf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bf7:	e8 65 f2 ff ff       	call   f0100e61 <page_alloc>
f0101bfc:	85 c0                	test   %eax,%eax
f0101bfe:	74 24                	je     f0101c24 <mem_init+0xa7e>
f0101c00:	c7 44 24 0c 42 5f 10 	movl   $0xf0105f42,0xc(%esp)
f0101c07:	f0 
f0101c08:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101c0f:	f0 
f0101c10:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101c17:	00 
f0101c18:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101c1f:	e8 92 e4 ff ff       	call   f01000b6 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c24:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c2b:	00 
f0101c2c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c33:	00 
f0101c34:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101c38:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101c3d:	89 04 24             	mov    %eax,(%esp)
f0101c40:	e8 ce f4 ff ff       	call   f0101113 <page_insert>
f0101c45:	85 c0                	test   %eax,%eax
f0101c47:	74 24                	je     f0101c6d <mem_init+0xac7>
f0101c49:	c7 44 24 0c 9c 58 10 	movl   $0xf010589c,0xc(%esp)
f0101c50:	f0 
f0101c51:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101c58:	f0 
f0101c59:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0101c60:	00 
f0101c61:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101c68:	e8 49 e4 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c6d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c72:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101c77:	e8 75 ed ff ff       	call   f01009f1 <check_va2pa>
f0101c7c:	89 f2                	mov    %esi,%edx
f0101c7e:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f0101c84:	c1 fa 03             	sar    $0x3,%edx
f0101c87:	c1 e2 0c             	shl    $0xc,%edx
f0101c8a:	39 d0                	cmp    %edx,%eax
f0101c8c:	74 24                	je     f0101cb2 <mem_init+0xb0c>
f0101c8e:	c7 44 24 0c d8 58 10 	movl   $0xf01058d8,0xc(%esp)
f0101c95:	f0 
f0101c96:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101c9d:	f0 
f0101c9e:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0101ca5:	00 
f0101ca6:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101cad:	e8 04 e4 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101cb2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101cb7:	74 24                	je     f0101cdd <mem_init+0xb37>
f0101cb9:	c7 44 24 0c b6 5f 10 	movl   $0xf0105fb6,0xc(%esp)
f0101cc0:	f0 
f0101cc1:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101cc8:	f0 
f0101cc9:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101cd0:	00 
f0101cd1:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101cd8:	e8 d9 e3 ff ff       	call   f01000b6 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101cdd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ce4:	e8 78 f1 ff ff       	call   f0100e61 <page_alloc>
f0101ce9:	85 c0                	test   %eax,%eax
f0101ceb:	74 24                	je     f0101d11 <mem_init+0xb6b>
f0101ced:	c7 44 24 0c 42 5f 10 	movl   $0xf0105f42,0xc(%esp)
f0101cf4:	f0 
f0101cf5:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101cfc:	f0 
f0101cfd:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101d04:	00 
f0101d05:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101d0c:	e8 a5 e3 ff ff       	call   f01000b6 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101d11:	8b 15 a8 de 17 f0    	mov    0xf017dea8,%edx
f0101d17:	8b 02                	mov    (%edx),%eax
f0101d19:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101d1e:	89 c1                	mov    %eax,%ecx
f0101d20:	c1 e9 0c             	shr    $0xc,%ecx
f0101d23:	3b 0d a4 de 17 f0    	cmp    0xf017dea4,%ecx
f0101d29:	72 20                	jb     f0101d4b <mem_init+0xba5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101d2b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101d2f:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0101d36:	f0 
f0101d37:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101d3e:	00 
f0101d3f:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101d46:	e8 6b e3 ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0101d4b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101d50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101d53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d5a:	00 
f0101d5b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d62:	00 
f0101d63:	89 14 24             	mov    %edx,(%esp)
f0101d66:	e8 e4 f1 ff ff       	call   f0100f4f <pgdir_walk>
f0101d6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101d6e:	8d 57 04             	lea    0x4(%edi),%edx
f0101d71:	39 d0                	cmp    %edx,%eax
f0101d73:	74 24                	je     f0101d99 <mem_init+0xbf3>
f0101d75:	c7 44 24 0c 08 59 10 	movl   $0xf0105908,0xc(%esp)
f0101d7c:	f0 
f0101d7d:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101d84:	f0 
f0101d85:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101d8c:	00 
f0101d8d:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101d94:	e8 1d e3 ff ff       	call   f01000b6 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d99:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101da0:	00 
f0101da1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101da8:	00 
f0101da9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101dad:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101db2:	89 04 24             	mov    %eax,(%esp)
f0101db5:	e8 59 f3 ff ff       	call   f0101113 <page_insert>
f0101dba:	85 c0                	test   %eax,%eax
f0101dbc:	74 24                	je     f0101de2 <mem_init+0xc3c>
f0101dbe:	c7 44 24 0c 48 59 10 	movl   $0xf0105948,0xc(%esp)
f0101dc5:	f0 
f0101dc6:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101dcd:	f0 
f0101dce:	c7 44 24 04 85 03 00 	movl   $0x385,0x4(%esp)
f0101dd5:	00 
f0101dd6:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101ddd:	e8 d4 e2 ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101de2:	8b 3d a8 de 17 f0    	mov    0xf017dea8,%edi
f0101de8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ded:	89 f8                	mov    %edi,%eax
f0101def:	e8 fd eb ff ff       	call   f01009f1 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101df4:	89 f2                	mov    %esi,%edx
f0101df6:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f0101dfc:	c1 fa 03             	sar    $0x3,%edx
f0101dff:	c1 e2 0c             	shl    $0xc,%edx
f0101e02:	39 d0                	cmp    %edx,%eax
f0101e04:	74 24                	je     f0101e2a <mem_init+0xc84>
f0101e06:	c7 44 24 0c d8 58 10 	movl   $0xf01058d8,0xc(%esp)
f0101e0d:	f0 
f0101e0e:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101e15:	f0 
f0101e16:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101e1d:	00 
f0101e1e:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101e25:	e8 8c e2 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0101e2a:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101e2f:	74 24                	je     f0101e55 <mem_init+0xcaf>
f0101e31:	c7 44 24 0c b6 5f 10 	movl   $0xf0105fb6,0xc(%esp)
f0101e38:	f0 
f0101e39:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101e40:	f0 
f0101e41:	c7 44 24 04 87 03 00 	movl   $0x387,0x4(%esp)
f0101e48:	00 
f0101e49:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101e50:	e8 61 e2 ff ff       	call   f01000b6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101e55:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e5c:	00 
f0101e5d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e64:	00 
f0101e65:	89 3c 24             	mov    %edi,(%esp)
f0101e68:	e8 e2 f0 ff ff       	call   f0100f4f <pgdir_walk>
f0101e6d:	f6 00 04             	testb  $0x4,(%eax)
f0101e70:	75 24                	jne    f0101e96 <mem_init+0xcf0>
f0101e72:	c7 44 24 0c 88 59 10 	movl   $0xf0105988,0xc(%esp)
f0101e79:	f0 
f0101e7a:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101e81:	f0 
f0101e82:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101e89:	00 
f0101e8a:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101e91:	e8 20 e2 ff ff       	call   f01000b6 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e96:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101e9b:	f6 00 04             	testb  $0x4,(%eax)
f0101e9e:	75 24                	jne    f0101ec4 <mem_init+0xd1e>
f0101ea0:	c7 44 24 0c c7 5f 10 	movl   $0xf0105fc7,0xc(%esp)
f0101ea7:	f0 
f0101ea8:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101eaf:	f0 
f0101eb0:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101eb7:	00 
f0101eb8:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101ebf:	e8 f2 e1 ff ff       	call   f01000b6 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ec4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ecb:	00 
f0101ecc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ed3:	00 
f0101ed4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ed8:	89 04 24             	mov    %eax,(%esp)
f0101edb:	e8 33 f2 ff ff       	call   f0101113 <page_insert>
f0101ee0:	85 c0                	test   %eax,%eax
f0101ee2:	74 24                	je     f0101f08 <mem_init+0xd62>
f0101ee4:	c7 44 24 0c 9c 58 10 	movl   $0xf010589c,0xc(%esp)
f0101eeb:	f0 
f0101eec:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101ef3:	f0 
f0101ef4:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101efb:	00 
f0101efc:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101f03:	e8 ae e1 ff ff       	call   f01000b6 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101f08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f0f:	00 
f0101f10:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f17:	00 
f0101f18:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101f1d:	89 04 24             	mov    %eax,(%esp)
f0101f20:	e8 2a f0 ff ff       	call   f0100f4f <pgdir_walk>
f0101f25:	f6 00 02             	testb  $0x2,(%eax)
f0101f28:	75 24                	jne    f0101f4e <mem_init+0xda8>
f0101f2a:	c7 44 24 0c bc 59 10 	movl   $0xf01059bc,0xc(%esp)
f0101f31:	f0 
f0101f32:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101f39:	f0 
f0101f3a:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101f41:	00 
f0101f42:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101f49:	e8 68 e1 ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f55:	00 
f0101f56:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f5d:	00 
f0101f5e:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101f63:	89 04 24             	mov    %eax,(%esp)
f0101f66:	e8 e4 ef ff ff       	call   f0100f4f <pgdir_walk>
f0101f6b:	f6 00 04             	testb  $0x4,(%eax)
f0101f6e:	74 24                	je     f0101f94 <mem_init+0xdee>
f0101f70:	c7 44 24 0c f0 59 10 	movl   $0xf01059f0,0xc(%esp)
f0101f77:	f0 
f0101f78:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101f7f:	f0 
f0101f80:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f0101f87:	00 
f0101f88:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101f8f:	e8 22 e1 ff ff       	call   f01000b6 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f94:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f9b:	00 
f0101f9c:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101fa3:	00 
f0101fa4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fa7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101fab:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101fb0:	89 04 24             	mov    %eax,(%esp)
f0101fb3:	e8 5b f1 ff ff       	call   f0101113 <page_insert>
f0101fb8:	85 c0                	test   %eax,%eax
f0101fba:	78 24                	js     f0101fe0 <mem_init+0xe3a>
f0101fbc:	c7 44 24 0c 28 5a 10 	movl   $0xf0105a28,0xc(%esp)
f0101fc3:	f0 
f0101fc4:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0101fcb:	f0 
f0101fcc:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101fd3:	00 
f0101fd4:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0101fdb:	e8 d6 e0 ff ff       	call   f01000b6 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101fe0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fe7:	00 
f0101fe8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101fef:	00 
f0101ff0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ff4:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0101ff9:	89 04 24             	mov    %eax,(%esp)
f0101ffc:	e8 12 f1 ff ff       	call   f0101113 <page_insert>
f0102001:	85 c0                	test   %eax,%eax
f0102003:	74 24                	je     f0102029 <mem_init+0xe83>
f0102005:	c7 44 24 0c 60 5a 10 	movl   $0xf0105a60,0xc(%esp)
f010200c:	f0 
f010200d:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102014:	f0 
f0102015:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f010201c:	00 
f010201d:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102024:	e8 8d e0 ff ff       	call   f01000b6 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102029:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102030:	00 
f0102031:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102038:	00 
f0102039:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010203e:	89 04 24             	mov    %eax,(%esp)
f0102041:	e8 09 ef ff ff       	call   f0100f4f <pgdir_walk>
f0102046:	f6 00 04             	testb  $0x4,(%eax)
f0102049:	74 24                	je     f010206f <mem_init+0xec9>
f010204b:	c7 44 24 0c f0 59 10 	movl   $0xf01059f0,0xc(%esp)
f0102052:	f0 
f0102053:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010205a:	f0 
f010205b:	c7 44 24 04 95 03 00 	movl   $0x395,0x4(%esp)
f0102062:	00 
f0102063:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010206a:	e8 47 e0 ff ff       	call   f01000b6 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010206f:	8b 3d a8 de 17 f0    	mov    0xf017dea8,%edi
f0102075:	ba 00 00 00 00       	mov    $0x0,%edx
f010207a:	89 f8                	mov    %edi,%eax
f010207c:	e8 70 e9 ff ff       	call   f01009f1 <check_va2pa>
f0102081:	89 c1                	mov    %eax,%ecx
f0102083:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102086:	89 d8                	mov    %ebx,%eax
f0102088:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f010208e:	c1 f8 03             	sar    $0x3,%eax
f0102091:	c1 e0 0c             	shl    $0xc,%eax
f0102094:	39 c1                	cmp    %eax,%ecx
f0102096:	74 24                	je     f01020bc <mem_init+0xf16>
f0102098:	c7 44 24 0c 9c 5a 10 	movl   $0xf0105a9c,0xc(%esp)
f010209f:	f0 
f01020a0:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01020a7:	f0 
f01020a8:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f01020af:	00 
f01020b0:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01020b7:	e8 fa df ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020bc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020c1:	89 f8                	mov    %edi,%eax
f01020c3:	e8 29 e9 ff ff       	call   f01009f1 <check_va2pa>
f01020c8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f01020cb:	74 24                	je     f01020f1 <mem_init+0xf4b>
f01020cd:	c7 44 24 0c c8 5a 10 	movl   $0xf0105ac8,0xc(%esp)
f01020d4:	f0 
f01020d5:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01020dc:	f0 
f01020dd:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f01020e4:	00 
f01020e5:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01020ec:	e8 c5 df ff ff       	call   f01000b6 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f01020f1:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f01020f6:	74 24                	je     f010211c <mem_init+0xf76>
f01020f8:	c7 44 24 0c dd 5f 10 	movl   $0xf0105fdd,0xc(%esp)
f01020ff:	f0 
f0102100:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102107:	f0 
f0102108:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f010210f:	00 
f0102110:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102117:	e8 9a df ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f010211c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102121:	74 24                	je     f0102147 <mem_init+0xfa1>
f0102123:	c7 44 24 0c ee 5f 10 	movl   $0xf0105fee,0xc(%esp)
f010212a:	f0 
f010212b:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102132:	f0 
f0102133:	c7 44 24 04 9c 03 00 	movl   $0x39c,0x4(%esp)
f010213a:	00 
f010213b:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102142:	e8 6f df ff ff       	call   f01000b6 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010214e:	e8 0e ed ff ff       	call   f0100e61 <page_alloc>
f0102153:	85 c0                	test   %eax,%eax
f0102155:	74 04                	je     f010215b <mem_init+0xfb5>
f0102157:	39 c6                	cmp    %eax,%esi
f0102159:	74 24                	je     f010217f <mem_init+0xfd9>
f010215b:	c7 44 24 0c f8 5a 10 	movl   $0xf0105af8,0xc(%esp)
f0102162:	f0 
f0102163:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010216a:	f0 
f010216b:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102172:	00 
f0102173:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010217a:	e8 37 df ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010217f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102186:	00 
f0102187:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010218c:	89 04 24             	mov    %eax,(%esp)
f010218f:	e8 31 ef ff ff       	call   f01010c5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102194:	8b 3d a8 de 17 f0    	mov    0xf017dea8,%edi
f010219a:	ba 00 00 00 00       	mov    $0x0,%edx
f010219f:	89 f8                	mov    %edi,%eax
f01021a1:	e8 4b e8 ff ff       	call   f01009f1 <check_va2pa>
f01021a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021a9:	74 24                	je     f01021cf <mem_init+0x1029>
f01021ab:	c7 44 24 0c 1c 5b 10 	movl   $0xf0105b1c,0xc(%esp)
f01021b2:	f0 
f01021b3:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01021ba:	f0 
f01021bb:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f01021c2:	00 
f01021c3:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01021ca:	e8 e7 de ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021cf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021d4:	89 f8                	mov    %edi,%eax
f01021d6:	e8 16 e8 ff ff       	call   f01009f1 <check_va2pa>
f01021db:	89 da                	mov    %ebx,%edx
f01021dd:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f01021e3:	c1 fa 03             	sar    $0x3,%edx
f01021e6:	c1 e2 0c             	shl    $0xc,%edx
f01021e9:	39 d0                	cmp    %edx,%eax
f01021eb:	74 24                	je     f0102211 <mem_init+0x106b>
f01021ed:	c7 44 24 0c c8 5a 10 	movl   $0xf0105ac8,0xc(%esp)
f01021f4:	f0 
f01021f5:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01021fc:	f0 
f01021fd:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102204:	00 
f0102205:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010220c:	e8 a5 de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 1);
f0102211:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102216:	74 24                	je     f010223c <mem_init+0x1096>
f0102218:	c7 44 24 0c 94 5f 10 	movl   $0xf0105f94,0xc(%esp)
f010221f:	f0 
f0102220:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102227:	f0 
f0102228:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f010222f:	00 
f0102230:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102237:	e8 7a de ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f010223c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102241:	74 24                	je     f0102267 <mem_init+0x10c1>
f0102243:	c7 44 24 0c ee 5f 10 	movl   $0xf0105fee,0xc(%esp)
f010224a:	f0 
f010224b:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102252:	f0 
f0102253:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f010225a:	00 
f010225b:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102262:	e8 4f de ff ff       	call   f01000b6 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102267:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010226e:	00 
f010226f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102276:	00 
f0102277:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010227b:	89 3c 24             	mov    %edi,(%esp)
f010227e:	e8 90 ee ff ff       	call   f0101113 <page_insert>
f0102283:	85 c0                	test   %eax,%eax
f0102285:	74 24                	je     f01022ab <mem_init+0x1105>
f0102287:	c7 44 24 0c 40 5b 10 	movl   $0xf0105b40,0xc(%esp)
f010228e:	f0 
f010228f:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102296:	f0 
f0102297:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f010229e:	00 
f010229f:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01022a6:	e8 0b de ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref);
f01022ab:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022b0:	75 24                	jne    f01022d6 <mem_init+0x1130>
f01022b2:	c7 44 24 0c ff 5f 10 	movl   $0xf0105fff,0xc(%esp)
f01022b9:	f0 
f01022ba:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01022c1:	f0 
f01022c2:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f01022c9:	00 
f01022ca:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01022d1:	e8 e0 dd ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_link == NULL);
f01022d6:	83 3b 00             	cmpl   $0x0,(%ebx)
f01022d9:	74 24                	je     f01022ff <mem_init+0x1159>
f01022db:	c7 44 24 0c 0b 60 10 	movl   $0xf010600b,0xc(%esp)
f01022e2:	f0 
f01022e3:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01022ea:	f0 
f01022eb:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f01022f2:	00 
f01022f3:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01022fa:	e8 b7 dd ff ff       	call   f01000b6 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01022ff:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102306:	00 
f0102307:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010230c:	89 04 24             	mov    %eax,(%esp)
f010230f:	e8 b1 ed ff ff       	call   f01010c5 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102314:	8b 3d a8 de 17 f0    	mov    0xf017dea8,%edi
f010231a:	ba 00 00 00 00       	mov    $0x0,%edx
f010231f:	89 f8                	mov    %edi,%eax
f0102321:	e8 cb e6 ff ff       	call   f01009f1 <check_va2pa>
f0102326:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102329:	74 24                	je     f010234f <mem_init+0x11a9>
f010232b:	c7 44 24 0c 1c 5b 10 	movl   $0xf0105b1c,0xc(%esp)
f0102332:	f0 
f0102333:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010233a:	f0 
f010233b:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f0102342:	00 
f0102343:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010234a:	e8 67 dd ff ff       	call   f01000b6 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010234f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102354:	89 f8                	mov    %edi,%eax
f0102356:	e8 96 e6 ff ff       	call   f01009f1 <check_va2pa>
f010235b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010235e:	74 24                	je     f0102384 <mem_init+0x11de>
f0102360:	c7 44 24 0c 78 5b 10 	movl   $0xf0105b78,0xc(%esp)
f0102367:	f0 
f0102368:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010236f:	f0 
f0102370:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f0102377:	00 
f0102378:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010237f:	e8 32 dd ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f0102384:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102389:	74 24                	je     f01023af <mem_init+0x1209>
f010238b:	c7 44 24 0c 20 60 10 	movl   $0xf0106020,0xc(%esp)
f0102392:	f0 
f0102393:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010239a:	f0 
f010239b:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f01023a2:	00 
f01023a3:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01023aa:	e8 07 dd ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 0);
f01023af:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01023b4:	74 24                	je     f01023da <mem_init+0x1234>
f01023b6:	c7 44 24 0c ee 5f 10 	movl   $0xf0105fee,0xc(%esp)
f01023bd:	f0 
f01023be:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01023c5:	f0 
f01023c6:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f01023cd:	00 
f01023ce:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01023d5:	e8 dc dc ff ff       	call   f01000b6 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01023da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01023e1:	e8 7b ea ff ff       	call   f0100e61 <page_alloc>
f01023e6:	85 c0                	test   %eax,%eax
f01023e8:	74 04                	je     f01023ee <mem_init+0x1248>
f01023ea:	39 c3                	cmp    %eax,%ebx
f01023ec:	74 24                	je     f0102412 <mem_init+0x126c>
f01023ee:	c7 44 24 0c a0 5b 10 	movl   $0xf0105ba0,0xc(%esp)
f01023f5:	f0 
f01023f6:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01023fd:	f0 
f01023fe:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0102405:	00 
f0102406:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010240d:	e8 a4 dc ff ff       	call   f01000b6 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102412:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102419:	e8 43 ea ff ff       	call   f0100e61 <page_alloc>
f010241e:	85 c0                	test   %eax,%eax
f0102420:	74 24                	je     f0102446 <mem_init+0x12a0>
f0102422:	c7 44 24 0c 42 5f 10 	movl   $0xf0105f42,0xc(%esp)
f0102429:	f0 
f010242a:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102431:	f0 
f0102432:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0102439:	00 
f010243a:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102441:	e8 70 dc ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102446:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010244b:	8b 08                	mov    (%eax),%ecx
f010244d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102453:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102456:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f010245c:	c1 fa 03             	sar    $0x3,%edx
f010245f:	c1 e2 0c             	shl    $0xc,%edx
f0102462:	39 d1                	cmp    %edx,%ecx
f0102464:	74 24                	je     f010248a <mem_init+0x12e4>
f0102466:	c7 44 24 0c 44 58 10 	movl   $0xf0105844,0xc(%esp)
f010246d:	f0 
f010246e:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102475:	f0 
f0102476:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f010247d:	00 
f010247e:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102485:	e8 2c dc ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f010248a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102490:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102493:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0102498:	74 24                	je     f01024be <mem_init+0x1318>
f010249a:	c7 44 24 0c a5 5f 10 	movl   $0xf0105fa5,0xc(%esp)
f01024a1:	f0 
f01024a2:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01024a9:	f0 
f01024aa:	c7 44 24 04 bd 03 00 	movl   $0x3bd,0x4(%esp)
f01024b1:	00 
f01024b2:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01024b9:	e8 f8 db ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f01024be:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024c1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01024c7:	89 04 24             	mov    %eax,(%esp)
f01024ca:	e8 1d ea ff ff       	call   f0100eec <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01024cf:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01024d6:	00 
f01024d7:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01024de:	00 
f01024df:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f01024e4:	89 04 24             	mov    %eax,(%esp)
f01024e7:	e8 63 ea ff ff       	call   f0100f4f <pgdir_walk>
f01024ec:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01024ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01024f2:	8b 15 a8 de 17 f0    	mov    0xf017dea8,%edx
f01024f8:	8b 7a 04             	mov    0x4(%edx),%edi
f01024fb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102501:	8b 0d a4 de 17 f0    	mov    0xf017dea4,%ecx
f0102507:	89 f8                	mov    %edi,%eax
f0102509:	c1 e8 0c             	shr    $0xc,%eax
f010250c:	39 c8                	cmp    %ecx,%eax
f010250e:	72 20                	jb     f0102530 <mem_init+0x138a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102510:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102514:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f010251b:	f0 
f010251c:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0102523:	00 
f0102524:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010252b:	e8 86 db ff ff       	call   f01000b6 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102530:	81 ef fc ff ff 0f    	sub    $0xffffffc,%edi
f0102536:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0102539:	74 24                	je     f010255f <mem_init+0x13b9>
f010253b:	c7 44 24 0c 31 60 10 	movl   $0xf0106031,0xc(%esp)
f0102542:	f0 
f0102543:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010254a:	f0 
f010254b:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f0102552:	00 
f0102553:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010255a:	e8 57 db ff ff       	call   f01000b6 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010255f:	c7 42 04 00 00 00 00 	movl   $0x0,0x4(%edx)
	pp0->pp_ref = 0;
f0102566:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102569:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010256f:	2b 05 ac de 17 f0    	sub    0xf017deac,%eax
f0102575:	c1 f8 03             	sar    $0x3,%eax
f0102578:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010257b:	89 c2                	mov    %eax,%edx
f010257d:	c1 ea 0c             	shr    $0xc,%edx
f0102580:	39 d1                	cmp    %edx,%ecx
f0102582:	77 20                	ja     f01025a4 <mem_init+0x13fe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102584:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102588:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f010258f:	f0 
f0102590:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102597:	00 
f0102598:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f010259f:	e8 12 db ff ff       	call   f01000b6 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01025a4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01025ab:	00 
f01025ac:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01025b3:	00 
	return (void *)(pa + KERNBASE);
f01025b4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01025b9:	89 04 24             	mov    %eax,(%esp)
f01025bc:	e8 66 26 00 00       	call   f0104c27 <memset>
	page_free(pp0);
f01025c1:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01025c4:	89 3c 24             	mov    %edi,(%esp)
f01025c7:	e8 20 e9 ff ff       	call   f0100eec <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01025cc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025d3:	00 
f01025d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01025db:	00 
f01025dc:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f01025e1:	89 04 24             	mov    %eax,(%esp)
f01025e4:	e8 66 e9 ff ff       	call   f0100f4f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01025e9:	89 fa                	mov    %edi,%edx
f01025eb:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f01025f1:	c1 fa 03             	sar    $0x3,%edx
f01025f4:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01025f7:	89 d0                	mov    %edx,%eax
f01025f9:	c1 e8 0c             	shr    $0xc,%eax
f01025fc:	3b 05 a4 de 17 f0    	cmp    0xf017dea4,%eax
f0102602:	72 20                	jb     f0102624 <mem_init+0x147e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102604:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102608:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f010260f:	f0 
f0102610:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102617:	00 
f0102618:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f010261f:	e8 92 da ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f0102624:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010262a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010262d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102633:	f6 00 01             	testb  $0x1,(%eax)
f0102636:	74 24                	je     f010265c <mem_init+0x14b6>
f0102638:	c7 44 24 0c 49 60 10 	movl   $0xf0106049,0xc(%esp)
f010263f:	f0 
f0102640:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102647:	f0 
f0102648:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f010264f:	00 
f0102650:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102657:	e8 5a da ff ff       	call   f01000b6 <_panic>
f010265c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010265f:	39 d0                	cmp    %edx,%eax
f0102661:	75 d0                	jne    f0102633 <mem_init+0x148d>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102663:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102668:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010266e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102671:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102677:	8b 7d d0             	mov    -0x30(%ebp),%edi
f010267a:	89 3d e0 d1 17 f0    	mov    %edi,0xf017d1e0

	// free the pages we took
	page_free(pp0);
f0102680:	89 04 24             	mov    %eax,(%esp)
f0102683:	e8 64 e8 ff ff       	call   f0100eec <page_free>
	page_free(pp1);
f0102688:	89 1c 24             	mov    %ebx,(%esp)
f010268b:	e8 5c e8 ff ff       	call   f0100eec <page_free>
	page_free(pp2);
f0102690:	89 34 24             	mov    %esi,(%esp)
f0102693:	e8 54 e8 ff ff       	call   f0100eec <page_free>

	cprintf("check_page() succeeded!\n");
f0102698:	c7 04 24 60 60 10 f0 	movl   $0xf0106060,(%esp)
f010269f:	e8 53 10 00 00       	call   f01036f7 <cprintf>
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:

	int perm = PTE_U | PTE_P;
	int i = 0;
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f01026a4:	a1 a4 de 17 f0       	mov    0xf017dea4,%eax
f01026a9:	8d 34 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%esi
f01026b0:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for(i = 0; i < n; i += PGSIZE)
f01026b6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026bb:	e9 86 00 00 00       	jmp    f0102746 <mem_init+0x15a0>
f01026c0:	8d 8b 00 00 00 ef    	lea    -0x11000000(%ebx),%ecx
		page_insert(kern_pgdir, pa2page(PADDR(pages) + i), (void *)(UPAGES + i), perm);
f01026c6:	a1 ac de 17 f0       	mov    0xf017deac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026d0:	77 20                	ja     f01026f2 <mem_init+0x154c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026d6:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f01026dd:	f0 
f01026de:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f01026e5:	00 
f01026e6:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01026ed:	e8 c4 d9 ff ff       	call   f01000b6 <_panic>
f01026f2:	8d 94 10 00 00 00 10 	lea    0x10000000(%eax,%edx,1),%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026f9:	c1 ea 0c             	shr    $0xc,%edx
f01026fc:	3b 15 a4 de 17 f0    	cmp    0xf017dea4,%edx
f0102702:	72 1c                	jb     f0102720 <mem_init+0x157a>
		panic("pa2page called with invalid pa");
f0102704:	c7 44 24 08 10 57 10 	movl   $0xf0105710,0x8(%esp)
f010270b:	f0 
f010270c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0102713:	00 
f0102714:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f010271b:	e8 96 d9 ff ff       	call   f01000b6 <_panic>
f0102720:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0102727:	00 
f0102728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
	return &pages[PGNUM(pa)];
f010272c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010272f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102733:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102738:	89 04 24             	mov    %eax,(%esp)
f010273b:	e8 d3 e9 ff ff       	call   f0101113 <page_insert>
	// Your code goes here:

	int perm = PTE_U | PTE_P;
	int i = 0;
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
	for(i = 0; i < n; i += PGSIZE)
f0102740:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102746:	89 da                	mov    %ebx,%edx
f0102748:	39 de                	cmp    %ebx,%esi
f010274a:	0f 87 70 ff ff ff    	ja     f01026c0 <mem_init+0x151a>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.

	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U | PTE_P);
f0102750:	a1 ec d1 17 f0       	mov    0xf017d1ec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102755:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010275a:	77 20                	ja     f010277c <mem_init+0x15d6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010275c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102760:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f0102767:	f0 
f0102768:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f010276f:	00 
f0102770:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102777:	e8 3a d9 ff ff       	call   f01000b6 <_panic>
f010277c:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f0102783:	00 
	return (physaddr_t)kva - KERNBASE;
f0102784:	05 00 00 00 10       	add    $0x10000000,%eax
f0102789:	89 04 24             	mov    %eax,(%esp)
f010278c:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102791:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102796:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010279b:	e8 4f e8 ff ff       	call   f0100fef <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027a0:	bb 00 10 11 f0       	mov    $0xf0111000,%ebx
f01027a5:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01027ab:	77 20                	ja     f01027cd <mem_init+0x1627>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01027b1:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f01027b8:	f0 
f01027b9:	c7 44 24 04 d8 00 00 	movl   $0xd8,0x4(%esp)
f01027c0:	00 
f01027c1:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01027c8:	e8 e9 d8 ff ff       	call   f01000b6 <_panic>
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, ROUNDUP(KSTKSIZE, PGSIZE), PADDR(bootstack), perm);
f01027cd:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01027d4:	00 
f01027d5:	c7 04 24 00 10 11 00 	movl   $0x111000,(%esp)
f01027dc:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01027e1:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01027e6:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f01027eb:	e8 ff e7 ff ff       	call   f0100fef <boot_map_region>
	int size = ~0;
	size = size - KERNBASE + 1;
	size = ROUNDUP(size, PGSIZE);
	perm = 0;
	perm = PTE_P | PTE_W;
	boot_map_region(kern_pgdir, KERNBASE, size, 0, perm);
f01027f0:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f01027f7:	00 
f01027f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027ff:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102804:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102809:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010280e:	e8 dc e7 ff ff       	call   f0100fef <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102813:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102818:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010281b:	a1 a4 de 17 f0       	mov    0xf017dea4,%eax
f0102820:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102823:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010282a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010282f:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102832:	8b 3d ac de 17 f0    	mov    0xf017deac,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102838:	89 7d c8             	mov    %edi,-0x38(%ebp)
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f010283b:	8d 87 00 00 00 10    	lea    0x10000000(%edi),%eax
f0102841:	89 45 c4             	mov    %eax,-0x3c(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102844:	be 00 00 00 00       	mov    $0x0,%esi
f0102849:	eb 6b                	jmp    f01028b6 <mem_init+0x1710>
f010284b:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102851:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102854:	e8 98 e1 ff ff       	call   f01009f1 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102859:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f0102860:	77 20                	ja     f0102882 <mem_init+0x16dc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102862:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0102866:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f010286d:	f0 
f010286e:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0102875:	00 
f0102876:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010287d:	e8 34 d8 ff ff       	call   f01000b6 <_panic>
f0102882:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f0102885:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102888:	39 d0                	cmp    %edx,%eax
f010288a:	74 24                	je     f01028b0 <mem_init+0x170a>
f010288c:	c7 44 24 0c c4 5b 10 	movl   $0xf0105bc4,0xc(%esp)
f0102893:	f0 
f0102894:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010289b:	f0 
f010289c:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f01028a3:	00 
f01028a4:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01028ab:	e8 06 d8 ff ff       	call   f01000b6 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01028b0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01028b6:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f01028b9:	77 90                	ja     f010284b <mem_init+0x16a5>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028bb:	8b 35 ec d1 17 f0    	mov    0xf017d1ec,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028c1:	89 f7                	mov    %esi,%edi
f01028c3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01028c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028cb:	e8 21 e1 ff ff       	call   f01009f1 <check_va2pa>
f01028d0:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f01028d6:	77 20                	ja     f01028f8 <mem_init+0x1752>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028d8:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01028dc:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f01028e3:	f0 
f01028e4:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f01028eb:	00 
f01028ec:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01028f3:	e8 be d7 ff ff       	call   f01000b6 <_panic>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028f8:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f01028fd:	81 c7 00 00 40 21    	add    $0x21400000,%edi
f0102903:	8d 14 37             	lea    (%edi,%esi,1),%edx
f0102906:	39 c2                	cmp    %eax,%edx
f0102908:	74 24                	je     f010292e <mem_init+0x1788>
f010290a:	c7 44 24 0c f8 5b 10 	movl   $0xf0105bf8,0xc(%esp)
f0102911:	f0 
f0102912:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102919:	f0 
f010291a:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f0102921:	00 
f0102922:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102929:	e8 88 d7 ff ff       	call   f01000b6 <_panic>
f010292e:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102934:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f010293a:	0f 85 26 05 00 00    	jne    f0102e66 <mem_init+0x1cc0>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102940:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102943:	c1 e7 0c             	shl    $0xc,%edi
f0102946:	be 00 00 00 00       	mov    $0x0,%esi
f010294b:	eb 3c                	jmp    f0102989 <mem_init+0x17e3>
f010294d:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102953:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102956:	e8 96 e0 ff ff       	call   f01009f1 <check_va2pa>
f010295b:	39 c6                	cmp    %eax,%esi
f010295d:	74 24                	je     f0102983 <mem_init+0x17dd>
f010295f:	c7 44 24 0c 2c 5c 10 	movl   $0xf0105c2c,0xc(%esp)
f0102966:	f0 
f0102967:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f010296e:	f0 
f010296f:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f0102976:	00 
f0102977:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f010297e:	e8 33 d7 ff ff       	call   f01000b6 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102983:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102989:	39 fe                	cmp    %edi,%esi
f010298b:	72 c0                	jb     f010294d <mem_init+0x17a7>
f010298d:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102992:	81 c3 00 80 00 20    	add    $0x20008000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102998:	89 f2                	mov    %esi,%edx
f010299a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010299d:	e8 4f e0 ff ff       	call   f01009f1 <check_va2pa>
f01029a2:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01029a5:	39 d0                	cmp    %edx,%eax
f01029a7:	74 24                	je     f01029cd <mem_init+0x1827>
f01029a9:	c7 44 24 0c 54 5c 10 	movl   $0xf0105c54,0xc(%esp)
f01029b0:	f0 
f01029b1:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f01029b8:	f0 
f01029b9:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f01029c0:	00 
f01029c1:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f01029c8:	e8 e9 d6 ff ff       	call   f01000b6 <_panic>
f01029cd:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029d3:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01029d9:	75 bd                	jne    f0102998 <mem_init+0x17f2>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01029db:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01029e0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01029e3:	89 f8                	mov    %edi,%eax
f01029e5:	e8 07 e0 ff ff       	call   f01009f1 <check_va2pa>
f01029ea:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029ed:	75 0c                	jne    f01029fb <mem_init+0x1855>
f01029ef:	b8 00 00 00 00       	mov    $0x0,%eax
f01029f4:	89 fa                	mov    %edi,%edx
f01029f6:	e9 f0 00 00 00       	jmp    f0102aeb <mem_init+0x1945>
f01029fb:	c7 44 24 0c 9c 5c 10 	movl   $0xf0105c9c,0xc(%esp)
f0102a02:	f0 
f0102a03:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102a0a:	f0 
f0102a0b:	c7 44 24 04 1a 03 00 	movl   $0x31a,0x4(%esp)
f0102a12:	00 
f0102a13:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102a1a:	e8 97 d6 ff ff       	call   f01000b6 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102a1f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102a24:	72 3c                	jb     f0102a62 <mem_init+0x18bc>
f0102a26:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102a2b:	76 07                	jbe    f0102a34 <mem_init+0x188e>
f0102a2d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a32:	75 2e                	jne    f0102a62 <mem_init+0x18bc>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102a34:	f6 04 82 01          	testb  $0x1,(%edx,%eax,4)
f0102a38:	0f 85 aa 00 00 00    	jne    f0102ae8 <mem_init+0x1942>
f0102a3e:	c7 44 24 0c 79 60 10 	movl   $0xf0106079,0xc(%esp)
f0102a45:	f0 
f0102a46:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102a4d:	f0 
f0102a4e:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0102a55:	00 
f0102a56:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102a5d:	e8 54 d6 ff ff       	call   f01000b6 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102a62:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a67:	76 55                	jbe    f0102abe <mem_init+0x1918>
				assert(pgdir[i] & PTE_P);
f0102a69:	8b 0c 82             	mov    (%edx,%eax,4),%ecx
f0102a6c:	f6 c1 01             	test   $0x1,%cl
f0102a6f:	75 24                	jne    f0102a95 <mem_init+0x18ef>
f0102a71:	c7 44 24 0c 79 60 10 	movl   $0xf0106079,0xc(%esp)
f0102a78:	f0 
f0102a79:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102a80:	f0 
f0102a81:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0102a88:	00 
f0102a89:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102a90:	e8 21 d6 ff ff       	call   f01000b6 <_panic>
				assert(pgdir[i] & PTE_W);
f0102a95:	f6 c1 02             	test   $0x2,%cl
f0102a98:	75 4e                	jne    f0102ae8 <mem_init+0x1942>
f0102a9a:	c7 44 24 0c 8a 60 10 	movl   $0xf010608a,0xc(%esp)
f0102aa1:	f0 
f0102aa2:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102aa9:	f0 
f0102aaa:	c7 44 24 04 28 03 00 	movl   $0x328,0x4(%esp)
f0102ab1:	00 
f0102ab2:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102ab9:	e8 f8 d5 ff ff       	call   f01000b6 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102abe:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
f0102ac2:	74 24                	je     f0102ae8 <mem_init+0x1942>
f0102ac4:	c7 44 24 0c 9b 60 10 	movl   $0xf010609b,0xc(%esp)
f0102acb:	f0 
f0102acc:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102ad3:	f0 
f0102ad4:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0102adb:	00 
f0102adc:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102ae3:	e8 ce d5 ff ff       	call   f01000b6 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102ae8:	83 c0 01             	add    $0x1,%eax
f0102aeb:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102af0:	0f 85 29 ff ff ff    	jne    f0102a1f <mem_init+0x1879>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102af6:	c7 04 24 cc 5c 10 f0 	movl   $0xf0105ccc,(%esp)
f0102afd:	e8 f5 0b 00 00       	call   f01036f7 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102b02:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102b07:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b0c:	77 20                	ja     f0102b2e <mem_init+0x1988>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b12:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f0102b19:	f0 
f0102b1a:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
f0102b21:	00 
f0102b22:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102b29:	e8 88 d5 ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102b2e:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102b33:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102b36:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b3b:	e8 20 df ff ff       	call   f0100a60 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102b40:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b43:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b46:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0102b4b:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b55:	e8 07 e3 ff ff       	call   f0100e61 <page_alloc>
f0102b5a:	89 c3                	mov    %eax,%ebx
f0102b5c:	85 c0                	test   %eax,%eax
f0102b5e:	75 24                	jne    f0102b84 <mem_init+0x19de>
f0102b60:	c7 44 24 0c 97 5e 10 	movl   $0xf0105e97,0xc(%esp)
f0102b67:	f0 
f0102b68:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102b6f:	f0 
f0102b70:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0102b77:	00 
f0102b78:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102b7f:	e8 32 d5 ff ff       	call   f01000b6 <_panic>
	assert((pp1 = page_alloc(0)));
f0102b84:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b8b:	e8 d1 e2 ff ff       	call   f0100e61 <page_alloc>
f0102b90:	89 c7                	mov    %eax,%edi
f0102b92:	85 c0                	test   %eax,%eax
f0102b94:	75 24                	jne    f0102bba <mem_init+0x1a14>
f0102b96:	c7 44 24 0c ad 5e 10 	movl   $0xf0105ead,0xc(%esp)
f0102b9d:	f0 
f0102b9e:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102ba5:	f0 
f0102ba6:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0102bad:	00 
f0102bae:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102bb5:	e8 fc d4 ff ff       	call   f01000b6 <_panic>
	assert((pp2 = page_alloc(0)));
f0102bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bc1:	e8 9b e2 ff ff       	call   f0100e61 <page_alloc>
f0102bc6:	89 c6                	mov    %eax,%esi
f0102bc8:	85 c0                	test   %eax,%eax
f0102bca:	75 24                	jne    f0102bf0 <mem_init+0x1a4a>
f0102bcc:	c7 44 24 0c c3 5e 10 	movl   $0xf0105ec3,0xc(%esp)
f0102bd3:	f0 
f0102bd4:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102bdb:	f0 
f0102bdc:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102be3:	00 
f0102be4:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102beb:	e8 c6 d4 ff ff       	call   f01000b6 <_panic>
	page_free(pp0);
f0102bf0:	89 1c 24             	mov    %ebx,(%esp)
f0102bf3:	e8 f4 e2 ff ff       	call   f0100eec <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bf8:	89 f8                	mov    %edi,%eax
f0102bfa:	e8 ad dd ff ff       	call   f01009ac <page2kva>
f0102bff:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c06:	00 
f0102c07:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102c0e:	00 
f0102c0f:	89 04 24             	mov    %eax,(%esp)
f0102c12:	e8 10 20 00 00       	call   f0104c27 <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c17:	89 f0                	mov    %esi,%eax
f0102c19:	e8 8e dd ff ff       	call   f01009ac <page2kva>
f0102c1e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c25:	00 
f0102c26:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c2d:	00 
f0102c2e:	89 04 24             	mov    %eax,(%esp)
f0102c31:	e8 f1 1f 00 00       	call   f0104c27 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c36:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c3d:	00 
f0102c3e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c45:	00 
f0102c46:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102c4a:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102c4f:	89 04 24             	mov    %eax,(%esp)
f0102c52:	e8 bc e4 ff ff       	call   f0101113 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c57:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c5c:	74 24                	je     f0102c82 <mem_init+0x1adc>
f0102c5e:	c7 44 24 0c 94 5f 10 	movl   $0xf0105f94,0xc(%esp)
f0102c65:	f0 
f0102c66:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102c6d:	f0 
f0102c6e:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f0102c75:	00 
f0102c76:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102c7d:	e8 34 d4 ff ff       	call   f01000b6 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c82:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c89:	01 01 01 
f0102c8c:	74 24                	je     f0102cb2 <mem_init+0x1b0c>
f0102c8e:	c7 44 24 0c ec 5c 10 	movl   $0xf0105cec,0xc(%esp)
f0102c95:	f0 
f0102c96:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102c9d:	f0 
f0102c9e:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102ca5:	00 
f0102ca6:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102cad:	e8 04 d4 ff ff       	call   f01000b6 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102cb2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102cb9:	00 
f0102cba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102cc1:	00 
f0102cc2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102cc6:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102ccb:	89 04 24             	mov    %eax,(%esp)
f0102cce:	e8 40 e4 ff ff       	call   f0101113 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102cd3:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102cda:	02 02 02 
f0102cdd:	74 24                	je     f0102d03 <mem_init+0x1b5d>
f0102cdf:	c7 44 24 0c 10 5d 10 	movl   $0xf0105d10,0xc(%esp)
f0102ce6:	f0 
f0102ce7:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102cee:	f0 
f0102cef:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102cf6:	00 
f0102cf7:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102cfe:	e8 b3 d3 ff ff       	call   f01000b6 <_panic>
	assert(pp2->pp_ref == 1);
f0102d03:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d08:	74 24                	je     f0102d2e <mem_init+0x1b88>
f0102d0a:	c7 44 24 0c b6 5f 10 	movl   $0xf0105fb6,0xc(%esp)
f0102d11:	f0 
f0102d12:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102d19:	f0 
f0102d1a:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0102d21:	00 
f0102d22:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102d29:	e8 88 d3 ff ff       	call   f01000b6 <_panic>
	assert(pp1->pp_ref == 0);
f0102d2e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102d33:	74 24                	je     f0102d59 <mem_init+0x1bb3>
f0102d35:	c7 44 24 0c 20 60 10 	movl   $0xf0106020,0xc(%esp)
f0102d3c:	f0 
f0102d3d:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102d44:	f0 
f0102d45:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102d4c:	00 
f0102d4d:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102d54:	e8 5d d3 ff ff       	call   f01000b6 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102d59:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102d60:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d63:	89 f0                	mov    %esi,%eax
f0102d65:	e8 42 dc ff ff       	call   f01009ac <page2kva>
f0102d6a:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0102d70:	74 24                	je     f0102d96 <mem_init+0x1bf0>
f0102d72:	c7 44 24 0c 34 5d 10 	movl   $0xf0105d34,0xc(%esp)
f0102d79:	f0 
f0102d7a:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102d81:	f0 
f0102d82:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102d89:	00 
f0102d8a:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102d91:	e8 20 d3 ff ff       	call   f01000b6 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d96:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d9d:	00 
f0102d9e:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102da3:	89 04 24             	mov    %eax,(%esp)
f0102da6:	e8 1a e3 ff ff       	call   f01010c5 <page_remove>
	assert(pp2->pp_ref == 0);
f0102dab:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102db0:	74 24                	je     f0102dd6 <mem_init+0x1c30>
f0102db2:	c7 44 24 0c ee 5f 10 	movl   $0xf0105fee,0xc(%esp)
f0102db9:	f0 
f0102dba:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102dc1:	f0 
f0102dc2:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f0102dc9:	00 
f0102dca:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102dd1:	e8 e0 d2 ff ff       	call   f01000b6 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102dd6:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f0102ddb:	8b 08                	mov    (%eax),%ecx
f0102ddd:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102de3:	89 da                	mov    %ebx,%edx
f0102de5:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f0102deb:	c1 fa 03             	sar    $0x3,%edx
f0102dee:	c1 e2 0c             	shl    $0xc,%edx
f0102df1:	39 d1                	cmp    %edx,%ecx
f0102df3:	74 24                	je     f0102e19 <mem_init+0x1c73>
f0102df5:	c7 44 24 0c 44 58 10 	movl   $0xf0105844,0xc(%esp)
f0102dfc:	f0 
f0102dfd:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102e04:	f0 
f0102e05:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102e0c:	00 
f0102e0d:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102e14:	e8 9d d2 ff ff       	call   f01000b6 <_panic>
	kern_pgdir[0] = 0;
f0102e19:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102e1f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102e24:	74 24                	je     f0102e4a <mem_init+0x1ca4>
f0102e26:	c7 44 24 0c a5 5f 10 	movl   $0xf0105fa5,0xc(%esp)
f0102e2d:	f0 
f0102e2e:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0102e35:	f0 
f0102e36:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102e3d:	00 
f0102e3e:	c7 04 24 cf 5d 10 f0 	movl   $0xf0105dcf,(%esp)
f0102e45:	e8 6c d2 ff ff       	call   f01000b6 <_panic>
	pp0->pp_ref = 0;
f0102e4a:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102e50:	89 1c 24             	mov    %ebx,(%esp)
f0102e53:	e8 94 e0 ff ff       	call   f0100eec <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e58:	c7 04 24 60 5d 10 f0 	movl   $0xf0105d60,(%esp)
f0102e5f:	e8 93 08 00 00       	call   f01036f7 <cprintf>
f0102e64:	eb 0f                	jmp    f0102e75 <mem_init+0x1ccf>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102e66:	89 f2                	mov    %esi,%edx
f0102e68:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e6b:	e8 81 db ff ff       	call   f01009f1 <check_va2pa>
f0102e70:	e9 8e fa ff ff       	jmp    f0102903 <mem_init+0x175d>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e75:	83 c4 4c             	add    $0x4c,%esp
f0102e78:	5b                   	pop    %ebx
f0102e79:	5e                   	pop    %esi
f0102e7a:	5f                   	pop    %edi
f0102e7b:	5d                   	pop    %ebp
f0102e7c:	c3                   	ret    

f0102e7d <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102e7d:	55                   	push   %ebp
f0102e7e:	89 e5                	mov    %esp,%ebp
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102e80:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e83:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102e86:	5d                   	pop    %ebp
f0102e87:	c3                   	ret    

f0102e88 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e88:	55                   	push   %ebp
f0102e89:	89 e5                	mov    %esp,%ebp
f0102e8b:	57                   	push   %edi
f0102e8c:	56                   	push   %esi
f0102e8d:	53                   	push   %ebx
f0102e8e:	83 ec 1c             	sub    $0x1c,%esp
f0102e91:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102e94:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 3: Your code here.
	const void *i;
	for(i = va; (i - va) < len; i += PGSIZE){
f0102e97:	89 f0                	mov    %esi,%eax
		if((size_t)i > ULIM) user_mem_check_addr = (size_t)i;
		if(!user_mem_check_addr){
			pte_t *pte = pgdir_walk(env->env_pgdir, i, 0);
			if(!pte || !(*pte & (PTE_P | perm | PTE_U))) 
f0102e99:	8b 4d 14             	mov    0x14(%ebp),%ecx
f0102e9c:	83 c9 05             	or     $0x5,%ecx
f0102e9f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	const void *i;
	for(i = va; (i - va) < len; i += PGSIZE){
f0102ea2:	eb 57                	jmp    f0102efb <user_mem_check+0x73>
		if((size_t)i > ULIM) user_mem_check_addr = (size_t)i;
f0102ea4:	89 c3                	mov    %eax,%ebx
f0102ea6:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f0102eab:	76 05                	jbe    f0102eb2 <user_mem_check+0x2a>
f0102ead:	a3 dc d1 17 f0       	mov    %eax,0xf017d1dc
		if(!user_mem_check_addr){
f0102eb2:	83 3d dc d1 17 f0 00 	cmpl   $0x0,0xf017d1dc
f0102eb9:	75 4f                	jne    f0102f0a <user_mem_check+0x82>
			pte_t *pte = pgdir_walk(env->env_pgdir, i, 0);
f0102ebb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ec2:	00 
f0102ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ec7:	8b 45 08             	mov    0x8(%ebp),%eax
f0102eca:	8b 40 5c             	mov    0x5c(%eax),%eax
f0102ecd:	89 04 24             	mov    %eax,(%esp)
f0102ed0:	e8 7a e0 ff ff       	call   f0100f4f <pgdir_walk>
			if(!pte || !(*pte & (PTE_P | perm | PTE_U))) 
f0102ed5:	85 c0                	test   %eax,%eax
f0102ed7:	74 07                	je     f0102ee0 <user_mem_check+0x58>
f0102ed9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102edc:	85 08                	test   %ecx,(%eax)
f0102ede:	75 06                	jne    f0102ee6 <user_mem_check+0x5e>
				user_mem_check_addr = (size_t)i;
f0102ee0:	89 1d dc d1 17 f0    	mov    %ebx,0xf017d1dc
		}
		if(user_mem_check_addr) return -E_FAULT;
f0102ee6:	83 3d dc d1 17 f0 00 	cmpl   $0x0,0xf017d1dc
f0102eed:	75 22                	jne    f0102f11 <user_mem_check+0x89>
		i = ROUNDDOWN(i, PGSIZE);
f0102eef:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
	// LAB 3: Your code here.
	const void *i;
	for(i = va; (i - va) < len; i += PGSIZE){
f0102ef5:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102efb:	89 c2                	mov    %eax,%edx
f0102efd:	29 f2                	sub    %esi,%edx
f0102eff:	39 fa                	cmp    %edi,%edx
f0102f01:	72 a1                	jb     f0102ea4 <user_mem_check+0x1c>
				user_mem_check_addr = (size_t)i;
		}
		if(user_mem_check_addr) return -E_FAULT;
		i = ROUNDDOWN(i, PGSIZE);
	}
	return 0;
f0102f03:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f08:	eb 0c                	jmp    f0102f16 <user_mem_check+0x8e>
		if(!user_mem_check_addr){
			pte_t *pte = pgdir_walk(env->env_pgdir, i, 0);
			if(!pte || !(*pte & (PTE_P | perm | PTE_U))) 
				user_mem_check_addr = (size_t)i;
		}
		if(user_mem_check_addr) return -E_FAULT;
f0102f0a:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102f0f:	eb 05                	jmp    f0102f16 <user_mem_check+0x8e>
f0102f11:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
		i = ROUNDDOWN(i, PGSIZE);
	}
	return 0;
}
f0102f16:	83 c4 1c             	add    $0x1c,%esp
f0102f19:	5b                   	pop    %ebx
f0102f1a:	5e                   	pop    %esi
f0102f1b:	5f                   	pop    %edi
f0102f1c:	5d                   	pop    %ebp
f0102f1d:	c3                   	ret    

f0102f1e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102f1e:	55                   	push   %ebp
f0102f1f:	89 e5                	mov    %esp,%ebp
f0102f21:	53                   	push   %ebx
f0102f22:	83 ec 14             	sub    $0x14,%esp
f0102f25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f28:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f2b:	83 c8 04             	or     $0x4,%eax
f0102f2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f32:	8b 45 10             	mov    0x10(%ebp),%eax
f0102f35:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f39:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f40:	89 1c 24             	mov    %ebx,(%esp)
f0102f43:	e8 40 ff ff ff       	call   f0102e88 <user_mem_check>
f0102f48:	85 c0                	test   %eax,%eax
f0102f4a:	79 24                	jns    f0102f70 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f4c:	a1 dc d1 17 f0       	mov    0xf017d1dc,%eax
f0102f51:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102f55:	8b 43 48             	mov    0x48(%ebx),%eax
f0102f58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f5c:	c7 04 24 8c 5d 10 f0 	movl   $0xf0105d8c,(%esp)
f0102f63:	e8 8f 07 00 00       	call   f01036f7 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102f68:	89 1c 24             	mov    %ebx,(%esp)
f0102f6b:	e8 54 06 00 00       	call   f01035c4 <env_destroy>
	}
}
f0102f70:	83 c4 14             	add    $0x14,%esp
f0102f73:	5b                   	pop    %ebx
f0102f74:	5d                   	pop    %ebp
f0102f75:	c3                   	ret    

f0102f76 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f76:	55                   	push   %ebp
f0102f77:	89 e5                	mov    %esp,%ebp
f0102f79:	57                   	push   %edi
f0102f7a:	56                   	push   %esi
f0102f7b:	53                   	push   %ebx
f0102f7c:	83 ec 1c             	sub    $0x1c,%esp
f0102f7f:	89 c7                	mov    %eax,%edi
	}
	*/
	
	void *i;
	int r;
	for(i = (void *)ROUNDDOWN(va, PGSIZE); i < (void *)ROUNDUP(va + len, PGSIZE); i += PGSIZE){
f0102f81:	89 d3                	mov    %edx,%ebx
f0102f83:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f89:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f90:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
f0102f96:	eb 6d                	jmp    f0103005 <region_alloc+0x8f>
		struct PageInfo * page = (struct PageInfo *)page_alloc(1);
f0102f98:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102f9f:	e8 bd de ff ff       	call   f0100e61 <page_alloc>
		if(page == NULL) panic("memory used out!");
f0102fa4:	85 c0                	test   %eax,%eax
f0102fa6:	75 1c                	jne    f0102fc4 <region_alloc+0x4e>
f0102fa8:	c7 44 24 08 a9 60 10 	movl   $0xf01060a9,0x8(%esp)
f0102faf:	f0 
f0102fb0:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f0102fb7:	00 
f0102fb8:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f0102fbf:	e8 f2 d0 ff ff       	call   f01000b6 <_panic>
		r = page_insert(e->env_pgdir, page, i, PTE_W | PTE_U);
f0102fc4:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102fcb:	00 
f0102fcc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fd4:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102fd7:	89 04 24             	mov    %eax,(%esp)
f0102fda:	e8 34 e1 ff ff       	call   f0101113 <page_insert>
		if(r != 0) panic("region alloc error!");
f0102fdf:	85 c0                	test   %eax,%eax
f0102fe1:	74 1c                	je     f0102fff <region_alloc+0x89>
f0102fe3:	c7 44 24 08 c5 60 10 	movl   $0xf01060c5,0x8(%esp)
f0102fea:	f0 
f0102feb:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
f0102ff2:	00 
f0102ff3:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f0102ffa:	e8 b7 d0 ff ff       	call   f01000b6 <_panic>
	}
	*/
	
	void *i;
	int r;
	for(i = (void *)ROUNDDOWN(va, PGSIZE); i < (void *)ROUNDUP(va + len, PGSIZE); i += PGSIZE){
f0102fff:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103005:	39 f3                	cmp    %esi,%ebx
f0103007:	72 8f                	jb     f0102f98 <region_alloc+0x22>
		struct PageInfo * page = (struct PageInfo *)page_alloc(1);
		if(page == NULL) panic("memory used out!");
		r = page_insert(e->env_pgdir, page, i, PTE_W | PTE_U);
		if(r != 0) panic("region alloc error!");
	}
}
f0103009:	83 c4 1c             	add    $0x1c,%esp
f010300c:	5b                   	pop    %ebx
f010300d:	5e                   	pop    %esi
f010300e:	5f                   	pop    %edi
f010300f:	5d                   	pop    %ebp
f0103010:	c3                   	ret    

f0103011 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103011:	55                   	push   %ebp
f0103012:	89 e5                	mov    %esp,%ebp
f0103014:	8b 45 08             	mov    0x8(%ebp),%eax
f0103017:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010301a:	85 c0                	test   %eax,%eax
f010301c:	75 11                	jne    f010302f <envid2env+0x1e>
		*env_store = curenv;
f010301e:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103023:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103026:	89 01                	mov    %eax,(%ecx)
		return 0;
f0103028:	b8 00 00 00 00       	mov    $0x0,%eax
f010302d:	eb 5e                	jmp    f010308d <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010302f:	89 c2                	mov    %eax,%edx
f0103031:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0103037:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010303a:	c1 e2 05             	shl    $0x5,%edx
f010303d:	03 15 ec d1 17 f0    	add    0xf017d1ec,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103043:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0103047:	74 05                	je     f010304e <envid2env+0x3d>
f0103049:	39 42 48             	cmp    %eax,0x48(%edx)
f010304c:	74 10                	je     f010305e <envid2env+0x4d>
		*env_store = 0;
f010304e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103051:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103057:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010305c:	eb 2f                	jmp    f010308d <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010305e:	84 c9                	test   %cl,%cl
f0103060:	74 21                	je     f0103083 <envid2env+0x72>
f0103062:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103067:	39 c2                	cmp    %eax,%edx
f0103069:	74 18                	je     f0103083 <envid2env+0x72>
f010306b:	8b 40 48             	mov    0x48(%eax),%eax
f010306e:	39 42 4c             	cmp    %eax,0x4c(%edx)
f0103071:	74 10                	je     f0103083 <envid2env+0x72>
		*env_store = 0;
f0103073:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103076:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010307c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103081:	eb 0a                	jmp    f010308d <envid2env+0x7c>
	}

	*env_store = e;
f0103083:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103086:	89 10                	mov    %edx,(%eax)
	return 0;
f0103088:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010308d:	5d                   	pop    %ebp
f010308e:	c3                   	ret    

f010308f <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010308f:	55                   	push   %ebp
f0103090:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103092:	b8 00 b3 11 f0       	mov    $0xf011b300,%eax
f0103097:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010309a:	b8 23 00 00 00       	mov    $0x23,%eax
f010309f:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f01030a1:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f01030a3:	b0 10                	mov    $0x10,%al
f01030a5:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f01030a7:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f01030a9:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f01030ab:	ea b2 30 10 f0 08 00 	ljmp   $0x8,$0xf01030b2
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01030b2:	b0 00                	mov    $0x0,%al
f01030b4:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01030b7:	5d                   	pop    %ebp
f01030b8:	c3                   	ret    

f01030b9 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01030b9:	55                   	push   %ebp
f01030ba:	89 e5                	mov    %esp,%ebp
f01030bc:	56                   	push   %esi
f01030bd:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for(i = NENV-1; i >= 0; i--){
		envs[i].env_id = 0;
f01030be:	8b 35 ec d1 17 f0    	mov    0xf017d1ec,%esi
f01030c4:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f01030ca:	ba 00 04 00 00       	mov    $0x400,%edx
f01030cf:	b9 00 00 00 00       	mov    $0x0,%ecx
f01030d4:	89 c3                	mov    %eax,%ebx
f01030d6:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030dd:	89 48 44             	mov    %ecx,0x44(%eax)
f01030e0:	83 e8 60             	sub    $0x60,%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	env_free_list = NULL;
	for(i = NENV-1; i >= 0; i--){
f01030e3:	83 ea 01             	sub    $0x1,%edx
f01030e6:	74 04                	je     f01030ec <env_init+0x33>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f01030e8:	89 d9                	mov    %ebx,%ecx
f01030ea:	eb e8                	jmp    f01030d4 <env_init+0x1b>
f01030ec:	89 35 f0 d1 17 f0    	mov    %esi,0xf017d1f0
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01030f2:	e8 98 ff ff ff       	call   f010308f <env_init_percpu>
}
f01030f7:	5b                   	pop    %ebx
f01030f8:	5e                   	pop    %esi
f01030f9:	5d                   	pop    %ebp
f01030fa:	c3                   	ret    

f01030fb <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01030fb:	55                   	push   %ebp
f01030fc:	89 e5                	mov    %esp,%ebp
f01030fe:	53                   	push   %ebx
f01030ff:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103102:	8b 1d f0 d1 17 f0    	mov    0xf017d1f0,%ebx
f0103108:	85 db                	test   %ebx,%ebx
f010310a:	0f 84 6d 01 00 00    	je     f010327d <env_alloc+0x182>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103110:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103117:	e8 45 dd ff ff       	call   f0100e61 <page_alloc>
f010311c:	85 c0                	test   %eax,%eax
f010311e:	0f 84 60 01 00 00    	je     f0103284 <env_alloc+0x189>
f0103124:	89 c2                	mov    %eax,%edx
f0103126:	2b 15 ac de 17 f0    	sub    0xf017deac,%edx
f010312c:	c1 fa 03             	sar    $0x3,%edx
f010312f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103132:	89 d1                	mov    %edx,%ecx
f0103134:	c1 e9 0c             	shr    $0xc,%ecx
f0103137:	3b 0d a4 de 17 f0    	cmp    0xf017dea4,%ecx
f010313d:	72 20                	jb     f010315f <env_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010313f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103143:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f010314a:	f0 
f010314b:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0103152:	00 
f0103153:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f010315a:	e8 57 cf ff ff       	call   f01000b6 <_panic>
	return (void *)(pa + KERNBASE);
f010315f:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0103165:	89 53 5c             	mov    %edx,0x5c(%ebx)
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.

	e->env_pgdir = (pde_t *)page2kva(p);
	p->pp_ref += 1;
f0103168:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f010316d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103174:	00 
f0103175:	a1 a8 de 17 f0       	mov    0xf017dea8,%eax
f010317a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010317e:	8b 43 5c             	mov    0x5c(%ebx),%eax
f0103181:	89 04 24             	mov    %eax,(%esp)
f0103184:	e8 53 1b 00 00       	call   f0104cdc <memcpy>
	for(i = PDX(UTOP); i < NPDENTRIES; i++) e->env_pgdir[i] = kern_pgdir[i];	*/


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103189:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010318c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103191:	77 20                	ja     f01031b3 <env_alloc+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103193:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103197:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f010319e:	f0 
f010319f:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
f01031a6:	00 
f01031a7:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f01031ae:	e8 03 cf ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01031b3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01031b9:	83 ca 05             	or     $0x5,%edx
f01031bc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01031c2:	8b 43 48             	mov    0x48(%ebx),%eax
f01031c5:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01031ca:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f01031cf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031d4:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031d7:	89 da                	mov    %ebx,%edx
f01031d9:	2b 15 ec d1 17 f0    	sub    0xf017d1ec,%edx
f01031df:	c1 fa 05             	sar    $0x5,%edx
f01031e2:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01031e8:	09 d0                	or     %edx,%eax
f01031ea:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01031ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031f0:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031f3:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031fa:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103201:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103208:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010320f:	00 
f0103210:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103217:	00 
f0103218:	89 1c 24             	mov    %ebx,(%esp)
f010321b:	e8 07 1a 00 00       	call   f0104c27 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103220:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103226:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010322c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103232:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103239:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f010323f:	8b 43 44             	mov    0x44(%ebx),%eax
f0103242:	a3 f0 d1 17 f0       	mov    %eax,0xf017d1f0
	*newenv_store = e;
f0103247:	8b 45 08             	mov    0x8(%ebp),%eax
f010324a:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010324c:	8b 53 48             	mov    0x48(%ebx),%edx
f010324f:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103254:	85 c0                	test   %eax,%eax
f0103256:	74 05                	je     f010325d <env_alloc+0x162>
f0103258:	8b 40 48             	mov    0x48(%eax),%eax
f010325b:	eb 05                	jmp    f0103262 <env_alloc+0x167>
f010325d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103262:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103266:	89 44 24 04          	mov    %eax,0x4(%esp)
f010326a:	c7 04 24 d9 60 10 f0 	movl   $0xf01060d9,(%esp)
f0103271:	e8 81 04 00 00       	call   f01036f7 <cprintf>
	return 0;
f0103276:	b8 00 00 00 00       	mov    $0x0,%eax
f010327b:	eb 0c                	jmp    f0103289 <env_alloc+0x18e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010327d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103282:	eb 05                	jmp    f0103289 <env_alloc+0x18e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103284:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103289:	83 c4 14             	add    $0x14,%esp
f010328c:	5b                   	pop    %ebx
f010328d:	5d                   	pop    %ebp
f010328e:	c3                   	ret    

f010328f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f010328f:	55                   	push   %ebp
f0103290:	89 e5                	mov    %esp,%ebp
f0103292:	57                   	push   %edi
f0103293:	56                   	push   %esi
f0103294:	53                   	push   %ebx
f0103295:	83 ec 2c             	sub    $0x2c,%esp
	// LAB 3: Your code here.
	struct Env *env;
	if(env_alloc(&env ,0) == 0){
f0103298:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010329f:	00 
f01032a0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032a3:	89 04 24             	mov    %eax,(%esp)
f01032a6:	e8 50 fe ff ff       	call   f01030fb <env_alloc>
f01032ab:	85 c0                	test   %eax,%eax
f01032ad:	0f 85 05 01 00 00    	jne    f01033b8 <env_create+0x129>
		env->env_type = type;
f01032b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01032b6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032b9:	89 47 50             	mov    %eax,0x50(%edi)

	//lcr3(PADDR(e->env_pgdir));
	struct Elf *ELFHDR = (struct Elf *)binary;
	struct Proghdr *ph, *eph;
	// is this a valid ELF?
	if(ELFHDR->e_magic != ELF_MAGIC) panic("ELF invalid!");
f01032bc:	8b 45 08             	mov    0x8(%ebp),%eax
f01032bf:	81 38 7f 45 4c 46    	cmpl   $0x464c457f,(%eax)
f01032c5:	74 1c                	je     f01032e3 <env_create+0x54>
f01032c7:	c7 44 24 08 ee 60 10 	movl   $0xf01060ee,0x8(%esp)
f01032ce:	f0 
f01032cf:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
f01032d6:	00 
f01032d7:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f01032de:	e8 d3 cd ff ff       	call   f01000b6 <_panic>

	if(ELFHDR->e_entry == 0) panic("ELF file can't be executed");	
f01032e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032e6:	8b 40 18             	mov    0x18(%eax),%eax
f01032e9:	85 c0                	test   %eax,%eax
f01032eb:	75 1c                	jne    f0103309 <env_create+0x7a>
f01032ed:	c7 44 24 08 fb 60 10 	movl   $0xf01060fb,0x8(%esp)
f01032f4:	f0 
f01032f5:	c7 44 24 04 72 01 00 	movl   $0x172,0x4(%esp)
f01032fc:	00 
f01032fd:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f0103304:	e8 ad cd ff ff       	call   f01000b6 <_panic>

	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103309:	89 47 30             	mov    %eax,0x30(%edi)
	lcr3(PADDR(e->env_pgdir));
f010330c:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010330f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103314:	77 20                	ja     f0103336 <env_create+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103316:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010331a:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f0103321:	f0 
f0103322:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
f0103329:	00 
f010332a:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f0103331:	e8 80 cd ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103336:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010333b:	0f 22 d8             	mov    %eax,%cr3

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
f010333e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103341:	89 c3                	mov    %eax,%ebx
f0103343:	03 58 1c             	add    0x1c(%eax),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103346:	0f b7 70 2c          	movzwl 0x2c(%eax),%esi
f010334a:	c1 e6 05             	shl    $0x5,%esi
f010334d:	01 de                	add    %ebx,%esi
f010334f:	eb 50                	jmp    f01033a1 <env_create+0x112>

	for(;ph < eph; ph++){
		//p_pa is the load address of this segment
		//(as well as the physical address)
		if(ph->p_type == ELF_PROG_LOAD){
f0103351:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103354:	75 48                	jne    f010339e <env_create+0x10f>
			if(ph->p_memsz - ph->p_filesz < 0){
				panic("p_memsz < p_filesz.\n");
			}
			region_alloc(e,(void *)ph->p_va,ph->p_memsz);
f0103356:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103359:	8b 53 08             	mov    0x8(%ebx),%edx
f010335c:	89 f8                	mov    %edi,%eax
f010335e:	e8 13 fc ff ff       	call   f0102f76 <region_alloc>
			memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103363:	8b 43 10             	mov    0x10(%ebx),%eax
f0103366:	89 44 24 08          	mov    %eax,0x8(%esp)
f010336a:	8b 45 08             	mov    0x8(%ebp),%eax
f010336d:	03 43 04             	add    0x4(%ebx),%eax
f0103370:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103374:	8b 43 08             	mov    0x8(%ebx),%eax
f0103377:	89 04 24             	mov    %eax,(%esp)
f010337a:	e8 f5 18 00 00       	call   f0104c74 <memmove>
			memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f010337f:	8b 43 10             	mov    0x10(%ebx),%eax
f0103382:	8b 53 14             	mov    0x14(%ebx),%edx
f0103385:	29 c2                	sub    %eax,%edx
f0103387:	89 54 24 08          	mov    %edx,0x8(%esp)
f010338b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103392:	00 
f0103393:	03 43 08             	add    0x8(%ebx),%eax
f0103396:	89 04 24             	mov    %eax,(%esp)
f0103399:	e8 89 18 00 00       	call   f0104c27 <memset>

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *)((uint8_t *)ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;

	for(;ph < eph; ph++){
f010339e:	83 c3 20             	add    $0x20,%ebx
f01033a1:	39 de                	cmp    %ebx,%esi
f01033a3:	77 ac                	ja     f0103351 <env_create+0xc2>

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f01033a5:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033aa:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033af:	89 f8                	mov    %edi,%eax
f01033b1:	e8 c0 fb ff ff       	call   f0102f76 <region_alloc>
f01033b6:	eb 1c                	jmp    f01033d4 <env_create+0x145>
	if(env_alloc(&env ,0) == 0){
		env->env_type = type;
		load_icode(env, binary);
	}
	else{
		panic("env_create failed: env_alloc failed.\n");
f01033b8:	c7 44 24 08 38 61 10 	movl   $0xf0106138,0x8(%esp)
f01033bf:	f0 
f01033c0:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
f01033c7:	00 
f01033c8:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f01033cf:	e8 e2 cc ff ff       	call   f01000b6 <_panic>
	}
}
f01033d4:	83 c4 2c             	add    $0x2c,%esp
f01033d7:	5b                   	pop    %ebx
f01033d8:	5e                   	pop    %esi
f01033d9:	5f                   	pop    %edi
f01033da:	5d                   	pop    %ebp
f01033db:	c3                   	ret    

f01033dc <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033dc:	55                   	push   %ebp
f01033dd:	89 e5                	mov    %esp,%ebp
f01033df:	57                   	push   %edi
f01033e0:	56                   	push   %esi
f01033e1:	53                   	push   %ebx
f01033e2:	83 ec 2c             	sub    $0x2c,%esp
f01033e5:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033e8:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f01033ed:	39 c7                	cmp    %eax,%edi
f01033ef:	75 37                	jne    f0103428 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f01033f1:	8b 15 a8 de 17 f0    	mov    0xf017dea8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033f7:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01033fd:	77 20                	ja     f010341f <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033ff:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103403:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f010340a:	f0 
f010340b:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f0103412:	00 
f0103413:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f010341a:	e8 97 cc ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010341f:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103425:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103428:	8b 57 48             	mov    0x48(%edi),%edx
f010342b:	85 c0                	test   %eax,%eax
f010342d:	74 05                	je     f0103434 <env_free+0x58>
f010342f:	8b 40 48             	mov    0x48(%eax),%eax
f0103432:	eb 05                	jmp    f0103439 <env_free+0x5d>
f0103434:	b8 00 00 00 00       	mov    $0x0,%eax
f0103439:	89 54 24 08          	mov    %edx,0x8(%esp)
f010343d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103441:	c7 04 24 16 61 10 f0 	movl   $0xf0106116,(%esp)
f0103448:	e8 aa 02 00 00       	call   f01036f7 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010344d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103454:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103457:	89 c8                	mov    %ecx,%eax
f0103459:	c1 e0 02             	shl    $0x2,%eax
f010345c:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010345f:	8b 47 5c             	mov    0x5c(%edi),%eax
f0103462:	8b 34 88             	mov    (%eax,%ecx,4),%esi
f0103465:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010346b:	0f 84 b7 00 00 00    	je     f0103528 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103471:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103477:	89 f0                	mov    %esi,%eax
f0103479:	c1 e8 0c             	shr    $0xc,%eax
f010347c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010347f:	3b 05 a4 de 17 f0    	cmp    0xf017dea4,%eax
f0103485:	72 20                	jb     f01034a7 <env_free+0xcb>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103487:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010348b:	c7 44 24 08 04 56 10 	movl   $0xf0105604,0x8(%esp)
f0103492:	f0 
f0103493:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f010349a:	00 
f010349b:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f01034a2:	e8 0f cc ff ff       	call   f01000b6 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034aa:	c1 e0 16             	shl    $0x16,%eax
f01034ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034b0:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01034b5:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01034bc:	01 
f01034bd:	74 17                	je     f01034d6 <env_free+0xfa>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034bf:	89 d8                	mov    %ebx,%eax
f01034c1:	c1 e0 0c             	shl    $0xc,%eax
f01034c4:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034cb:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034ce:	89 04 24             	mov    %eax,(%esp)
f01034d1:	e8 ef db ff ff       	call   f01010c5 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034d6:	83 c3 01             	add    $0x1,%ebx
f01034d9:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034df:	75 d4                	jne    f01034b5 <env_free+0xd9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034e1:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034e7:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034ee:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034f1:	3b 05 a4 de 17 f0    	cmp    0xf017dea4,%eax
f01034f7:	72 1c                	jb     f0103515 <env_free+0x139>
		panic("pa2page called with invalid pa");
f01034f9:	c7 44 24 08 10 57 10 	movl   $0xf0105710,0x8(%esp)
f0103500:	f0 
f0103501:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103508:	00 
f0103509:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f0103510:	e8 a1 cb ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0103515:	a1 ac de 17 f0       	mov    0xf017deac,%eax
f010351a:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010351d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
		page_decref(pa2page(pa));
f0103520:	89 04 24             	mov    %eax,(%esp)
f0103523:	e8 04 da ff ff       	call   f0100f2c <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103528:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f010352c:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103533:	0f 85 1b ff ff ff    	jne    f0103454 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103539:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010353c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103541:	77 20                	ja     f0103563 <env_free+0x187>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103543:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103547:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f010354e:	f0 
f010354f:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103556:	00 
f0103557:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f010355e:	e8 53 cb ff ff       	call   f01000b6 <_panic>
	e->env_pgdir = 0;
f0103563:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f010356a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010356f:	c1 e8 0c             	shr    $0xc,%eax
f0103572:	3b 05 a4 de 17 f0    	cmp    0xf017dea4,%eax
f0103578:	72 1c                	jb     f0103596 <env_free+0x1ba>
		panic("pa2page called with invalid pa");
f010357a:	c7 44 24 08 10 57 10 	movl   $0xf0105710,0x8(%esp)
f0103581:	f0 
f0103582:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103589:	00 
f010358a:	c7 04 24 c1 5d 10 f0 	movl   $0xf0105dc1,(%esp)
f0103591:	e8 20 cb ff ff       	call   f01000b6 <_panic>
	return &pages[PGNUM(pa)];
f0103596:	8b 15 ac de 17 f0    	mov    0xf017deac,%edx
f010359c:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	page_decref(pa2page(pa));
f010359f:	89 04 24             	mov    %eax,(%esp)
f01035a2:	e8 85 d9 ff ff       	call   f0100f2c <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01035a7:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01035ae:	a1 f0 d1 17 f0       	mov    0xf017d1f0,%eax
f01035b3:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01035b6:	89 3d f0 d1 17 f0    	mov    %edi,0xf017d1f0
}
f01035bc:	83 c4 2c             	add    $0x2c,%esp
f01035bf:	5b                   	pop    %ebx
f01035c0:	5e                   	pop    %esi
f01035c1:	5f                   	pop    %edi
f01035c2:	5d                   	pop    %ebp
f01035c3:	c3                   	ret    

f01035c4 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01035c4:	55                   	push   %ebp
f01035c5:	89 e5                	mov    %esp,%ebp
f01035c7:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01035ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01035cd:	89 04 24             	mov    %eax,(%esp)
f01035d0:	e8 07 fe ff ff       	call   f01033dc <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01035d5:	c7 04 24 60 61 10 f0 	movl   $0xf0106160,(%esp)
f01035dc:	e8 16 01 00 00       	call   f01036f7 <cprintf>
	while (1)
		monitor(NULL);
f01035e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035e8:	e8 39 d2 ff ff       	call   f0100826 <monitor>
f01035ed:	eb f2                	jmp    f01035e1 <env_destroy+0x1d>

f01035ef <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035ef:	55                   	push   %ebp
f01035f0:	89 e5                	mov    %esp,%ebp
f01035f2:	83 ec 18             	sub    $0x18,%esp
	__asm __volatile("movl %0,%%esp\n"
f01035f5:	8b 65 08             	mov    0x8(%ebp),%esp
f01035f8:	61                   	popa   
f01035f9:	07                   	pop    %es
f01035fa:	1f                   	pop    %ds
f01035fb:	83 c4 08             	add    $0x8,%esp
f01035fe:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035ff:	c7 44 24 08 2c 61 10 	movl   $0xf010612c,0x8(%esp)
f0103606:	f0 
f0103607:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
f010360e:	00 
f010360f:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f0103616:	e8 9b ca ff ff       	call   f01000b6 <_panic>

f010361b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010361b:	55                   	push   %ebp
f010361c:	89 e5                	mov    %esp,%ebp
f010361e:	83 ec 18             	sub    $0x18,%esp
f0103621:	8b 45 08             	mov    0x8(%ebp),%eax
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	
	if(curenv != NULL && curenv->env_status == ENV_RUNNING){
f0103624:	8b 15 e8 d1 17 f0    	mov    0xf017d1e8,%edx
f010362a:	85 d2                	test   %edx,%edx
f010362c:	74 0d                	je     f010363b <env_run+0x20>
f010362e:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103632:	75 07                	jne    f010363b <env_run+0x20>
		curenv->env_status = ENV_RUNNABLE;
f0103634:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	}
	curenv = e;
f010363b:	a3 e8 d1 17 f0       	mov    %eax,0xf017d1e8
	e->env_status = ENV_RUNNING;
f0103640:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++;
f0103647:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e->env_pgdir));
f010364b:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010364e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103654:	77 20                	ja     f0103676 <env_run+0x5b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103656:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010365a:	c7 44 24 08 ec 56 10 	movl   $0xf01056ec,0x8(%esp)
f0103661:	f0 
f0103662:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
f0103669:	00 
f010366a:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f0103671:	e8 40 ca ff ff       	call   f01000b6 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103676:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f010367c:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&e->env_tf);
f010367f:	89 04 24             	mov    %eax,(%esp)
f0103682:	e8 68 ff ff ff       	call   f01035ef <env_pop_tf>

f0103687 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103687:	55                   	push   %ebp
f0103688:	89 e5                	mov    %esp,%ebp
f010368a:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010368e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103693:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103694:	b2 71                	mov    $0x71,%dl
f0103696:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103697:	0f b6 c0             	movzbl %al,%eax
}
f010369a:	5d                   	pop    %ebp
f010369b:	c3                   	ret    

f010369c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010369c:	55                   	push   %ebp
f010369d:	89 e5                	mov    %esp,%ebp
f010369f:	0f b6 45 08          	movzbl 0x8(%ebp),%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01036a3:	ba 70 00 00 00       	mov    $0x70,%edx
f01036a8:	ee                   	out    %al,(%dx)
f01036a9:	b2 71                	mov    $0x71,%dl
f01036ab:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036ae:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f01036af:	5d                   	pop    %ebp
f01036b0:	c3                   	ret    

f01036b1 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01036b1:	55                   	push   %ebp
f01036b2:	89 e5                	mov    %esp,%ebp
f01036b4:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f01036b7:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ba:	89 04 24             	mov    %eax,(%esp)
f01036bd:	e8 4f cf ff ff       	call   f0100611 <cputchar>
	*cnt++;
}
f01036c2:	c9                   	leave  
f01036c3:	c3                   	ret    

f01036c4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01036c4:	55                   	push   %ebp
f01036c5:	89 e5                	mov    %esp,%ebp
f01036c7:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f01036ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01036d1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036d8:	8b 45 08             	mov    0x8(%ebp),%eax
f01036db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01036df:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01036e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036e6:	c7 04 24 b1 36 10 f0 	movl   $0xf01036b1,(%esp)
f01036ed:	e8 7c 0e 00 00       	call   f010456e <vprintfmt>
	return cnt;
}
f01036f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036f5:	c9                   	leave  
f01036f6:	c3                   	ret    

f01036f7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036f7:	55                   	push   %ebp
f01036f8:	89 e5                	mov    %esp,%ebp
f01036fa:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036fd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103700:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103704:	8b 45 08             	mov    0x8(%ebp),%eax
f0103707:	89 04 24             	mov    %eax,(%esp)
f010370a:	e8 b5 ff ff ff       	call   f01036c4 <vcprintf>
	va_end(ap);

	return cnt;
}
f010370f:	c9                   	leave  
f0103710:	c3                   	ret    
f0103711:	66 90                	xchg   %ax,%ax
f0103713:	66 90                	xchg   %ax,%ax
f0103715:	66 90                	xchg   %ax,%ax
f0103717:	66 90                	xchg   %ax,%ax
f0103719:	66 90                	xchg   %ax,%ax
f010371b:	66 90                	xchg   %ax,%ax
f010371d:	66 90                	xchg   %ax,%ax
f010371f:	90                   	nop

f0103720 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103720:	55                   	push   %ebp
f0103721:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103723:	c7 05 24 da 17 f0 00 	movl   $0xf0000000,0xf017da24
f010372a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010372d:	66 c7 05 28 da 17 f0 	movw   $0x10,0xf017da28
f0103734:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103736:	66 c7 05 48 b3 11 f0 	movw   $0x67,0xf011b348
f010373d:	67 00 
f010373f:	b8 20 da 17 f0       	mov    $0xf017da20,%eax
f0103744:	66 a3 4a b3 11 f0    	mov    %ax,0xf011b34a
f010374a:	89 c2                	mov    %eax,%edx
f010374c:	c1 ea 10             	shr    $0x10,%edx
f010374f:	88 15 4c b3 11 f0    	mov    %dl,0xf011b34c
f0103755:	c6 05 4e b3 11 f0 40 	movb   $0x40,0xf011b34e
f010375c:	c1 e8 18             	shr    $0x18,%eax
f010375f:	a2 4f b3 11 f0       	mov    %al,0xf011b34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103764:	c6 05 4d b3 11 f0 89 	movb   $0x89,0xf011b34d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f010376b:	b8 28 00 00 00       	mov    $0x28,%eax
f0103770:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103773:	b8 50 b3 11 f0       	mov    $0xf011b350,%eax
f0103778:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f010377b:	5d                   	pop    %ebp
f010377c:	c3                   	ret    

f010377d <trap_init>:
}


void
trap_init(void)
{
f010377d:	55                   	push   %ebp
f010377e:	89 e5                	mov    %esp,%ebp
	void T_FPERR_handler();
	void T_ALIGN_handler();
	void T_MCHK_handler();
	void T_SIMDERR_handler();
	void T_SYSCALL_handler();
	SETGATE(idt[T_DIVIDE], 0, GD_KT, T_DIVIDE_handler, 0);
f0103780:	b8 b2 3e 10 f0       	mov    $0xf0103eb2,%eax
f0103785:	66 a3 00 d2 17 f0    	mov    %ax,0xf017d200
f010378b:	66 c7 05 02 d2 17 f0 	movw   $0x8,0xf017d202
f0103792:	08 00 
f0103794:	c6 05 04 d2 17 f0 00 	movb   $0x0,0xf017d204
f010379b:	c6 05 05 d2 17 f0 8e 	movb   $0x8e,0xf017d205
f01037a2:	c1 e8 10             	shr    $0x10,%eax
f01037a5:	66 a3 06 d2 17 f0    	mov    %ax,0xf017d206
	SETGATE(idt[T_DEBUG], 0, GD_KT, T_DEBUG_handler, 0);
f01037ab:	b8 b8 3e 10 f0       	mov    $0xf0103eb8,%eax
f01037b0:	66 a3 08 d2 17 f0    	mov    %ax,0xf017d208
f01037b6:	66 c7 05 0a d2 17 f0 	movw   $0x8,0xf017d20a
f01037bd:	08 00 
f01037bf:	c6 05 0c d2 17 f0 00 	movb   $0x0,0xf017d20c
f01037c6:	c6 05 0d d2 17 f0 8e 	movb   $0x8e,0xf017d20d
f01037cd:	c1 e8 10             	shr    $0x10,%eax
f01037d0:	66 a3 0e d2 17 f0    	mov    %ax,0xf017d20e
	SETGATE(idt[T_NMI], 0, GD_KT, T_NMI_handler, 0);
f01037d6:	b8 be 3e 10 f0       	mov    $0xf0103ebe,%eax
f01037db:	66 a3 10 d2 17 f0    	mov    %ax,0xf017d210
f01037e1:	66 c7 05 12 d2 17 f0 	movw   $0x8,0xf017d212
f01037e8:	08 00 
f01037ea:	c6 05 14 d2 17 f0 00 	movb   $0x0,0xf017d214
f01037f1:	c6 05 15 d2 17 f0 8e 	movb   $0x8e,0xf017d215
f01037f8:	c1 e8 10             	shr    $0x10,%eax
f01037fb:	66 a3 16 d2 17 f0    	mov    %ax,0xf017d216
	SETGATE(idt[T_BRKPT], 1, GD_KT, T_BRKPT_handler, 3);
f0103801:	b8 c4 3e 10 f0       	mov    $0xf0103ec4,%eax
f0103806:	66 a3 18 d2 17 f0    	mov    %ax,0xf017d218
f010380c:	66 c7 05 1a d2 17 f0 	movw   $0x8,0xf017d21a
f0103813:	08 00 
f0103815:	c6 05 1c d2 17 f0 00 	movb   $0x0,0xf017d21c
f010381c:	c6 05 1d d2 17 f0 ef 	movb   $0xef,0xf017d21d
f0103823:	c1 e8 10             	shr    $0x10,%eax
f0103826:	66 a3 1e d2 17 f0    	mov    %ax,0xf017d21e
	SETGATE(idt[T_OFLOW], 1, GD_KT, T_OFLOW_handler, 0);
f010382c:	b8 ca 3e 10 f0       	mov    $0xf0103eca,%eax
f0103831:	66 a3 20 d2 17 f0    	mov    %ax,0xf017d220
f0103837:	66 c7 05 22 d2 17 f0 	movw   $0x8,0xf017d222
f010383e:	08 00 
f0103840:	c6 05 24 d2 17 f0 00 	movb   $0x0,0xf017d224
f0103847:	c6 05 25 d2 17 f0 8f 	movb   $0x8f,0xf017d225
f010384e:	c1 e8 10             	shr    $0x10,%eax
f0103851:	66 a3 26 d2 17 f0    	mov    %ax,0xf017d226
	SETGATE(idt[T_BOUND], 0, GD_KT, T_BOUND_handler, 0);
f0103857:	b8 d0 3e 10 f0       	mov    $0xf0103ed0,%eax
f010385c:	66 a3 28 d2 17 f0    	mov    %ax,0xf017d228
f0103862:	66 c7 05 2a d2 17 f0 	movw   $0x8,0xf017d22a
f0103869:	08 00 
f010386b:	c6 05 2c d2 17 f0 00 	movb   $0x0,0xf017d22c
f0103872:	c6 05 2d d2 17 f0 8e 	movb   $0x8e,0xf017d22d
f0103879:	c1 e8 10             	shr    $0x10,%eax
f010387c:	66 a3 2e d2 17 f0    	mov    %ax,0xf017d22e
	SETGATE(idt[T_ILLOP], 0, GD_KT, T_ILLOP_handler, 0);
f0103882:	b8 d6 3e 10 f0       	mov    $0xf0103ed6,%eax
f0103887:	66 a3 30 d2 17 f0    	mov    %ax,0xf017d230
f010388d:	66 c7 05 32 d2 17 f0 	movw   $0x8,0xf017d232
f0103894:	08 00 
f0103896:	c6 05 34 d2 17 f0 00 	movb   $0x0,0xf017d234
f010389d:	c6 05 35 d2 17 f0 8e 	movb   $0x8e,0xf017d235
f01038a4:	c1 e8 10             	shr    $0x10,%eax
f01038a7:	66 a3 36 d2 17 f0    	mov    %ax,0xf017d236
	SETGATE(idt[T_DEVICE], 0, GD_KT, T_DEVICE_handler, 0);
f01038ad:	b8 dc 3e 10 f0       	mov    $0xf0103edc,%eax
f01038b2:	66 a3 38 d2 17 f0    	mov    %ax,0xf017d238
f01038b8:	66 c7 05 3a d2 17 f0 	movw   $0x8,0xf017d23a
f01038bf:	08 00 
f01038c1:	c6 05 3c d2 17 f0 00 	movb   $0x0,0xf017d23c
f01038c8:	c6 05 3d d2 17 f0 8e 	movb   $0x8e,0xf017d23d
f01038cf:	c1 e8 10             	shr    $0x10,%eax
f01038d2:	66 a3 3e d2 17 f0    	mov    %ax,0xf017d23e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, T_DBLFLT_handler, 0);
f01038d8:	b8 e2 3e 10 f0       	mov    $0xf0103ee2,%eax
f01038dd:	66 a3 40 d2 17 f0    	mov    %ax,0xf017d240
f01038e3:	66 c7 05 42 d2 17 f0 	movw   $0x8,0xf017d242
f01038ea:	08 00 
f01038ec:	c6 05 44 d2 17 f0 00 	movb   $0x0,0xf017d244
f01038f3:	c6 05 45 d2 17 f0 8e 	movb   $0x8e,0xf017d245
f01038fa:	c1 e8 10             	shr    $0x10,%eax
f01038fd:	66 a3 46 d2 17 f0    	mov    %ax,0xf017d246
	SETGATE(idt[T_TSS], 0, GD_KT, T_TSS_handler, 0);
f0103903:	b8 e6 3e 10 f0       	mov    $0xf0103ee6,%eax
f0103908:	66 a3 50 d2 17 f0    	mov    %ax,0xf017d250
f010390e:	66 c7 05 52 d2 17 f0 	movw   $0x8,0xf017d252
f0103915:	08 00 
f0103917:	c6 05 54 d2 17 f0 00 	movb   $0x0,0xf017d254
f010391e:	c6 05 55 d2 17 f0 8e 	movb   $0x8e,0xf017d255
f0103925:	c1 e8 10             	shr    $0x10,%eax
f0103928:	66 a3 56 d2 17 f0    	mov    %ax,0xf017d256
	SETGATE(idt[T_SEGNP], 0, GD_KT, T_SEGNP_handler, 0);
f010392e:	b8 ea 3e 10 f0       	mov    $0xf0103eea,%eax
f0103933:	66 a3 58 d2 17 f0    	mov    %ax,0xf017d258
f0103939:	66 c7 05 5a d2 17 f0 	movw   $0x8,0xf017d25a
f0103940:	08 00 
f0103942:	c6 05 5c d2 17 f0 00 	movb   $0x0,0xf017d25c
f0103949:	c6 05 5d d2 17 f0 8e 	movb   $0x8e,0xf017d25d
f0103950:	c1 e8 10             	shr    $0x10,%eax
f0103953:	66 a3 5e d2 17 f0    	mov    %ax,0xf017d25e
	SETGATE(idt[T_STACK], 0, GD_KT, T_STACK_handler, 0);
f0103959:	b8 ee 3e 10 f0       	mov    $0xf0103eee,%eax
f010395e:	66 a3 60 d2 17 f0    	mov    %ax,0xf017d260
f0103964:	66 c7 05 62 d2 17 f0 	movw   $0x8,0xf017d262
f010396b:	08 00 
f010396d:	c6 05 64 d2 17 f0 00 	movb   $0x0,0xf017d264
f0103974:	c6 05 65 d2 17 f0 8e 	movb   $0x8e,0xf017d265
f010397b:	c1 e8 10             	shr    $0x10,%eax
f010397e:	66 a3 66 d2 17 f0    	mov    %ax,0xf017d266
	SETGATE(idt[T_GPFLT], 0, GD_KT, T_GPFLT_handler, 0);
f0103984:	b8 f2 3e 10 f0       	mov    $0xf0103ef2,%eax
f0103989:	66 a3 68 d2 17 f0    	mov    %ax,0xf017d268
f010398f:	66 c7 05 6a d2 17 f0 	movw   $0x8,0xf017d26a
f0103996:	08 00 
f0103998:	c6 05 6c d2 17 f0 00 	movb   $0x0,0xf017d26c
f010399f:	c6 05 6d d2 17 f0 8e 	movb   $0x8e,0xf017d26d
f01039a6:	c1 e8 10             	shr    $0x10,%eax
f01039a9:	66 a3 6e d2 17 f0    	mov    %ax,0xf017d26e
	SETGATE(idt[T_PGFLT], 0, GD_KT, T_PGFLT_handler, 3);
f01039af:	b8 f6 3e 10 f0       	mov    $0xf0103ef6,%eax
f01039b4:	66 a3 70 d2 17 f0    	mov    %ax,0xf017d270
f01039ba:	66 c7 05 72 d2 17 f0 	movw   $0x8,0xf017d272
f01039c1:	08 00 
f01039c3:	c6 05 74 d2 17 f0 00 	movb   $0x0,0xf017d274
f01039ca:	c6 05 75 d2 17 f0 ee 	movb   $0xee,0xf017d275
f01039d1:	c1 e8 10             	shr    $0x10,%eax
f01039d4:	66 a3 76 d2 17 f0    	mov    %ax,0xf017d276
	SETGATE(idt[T_FPERR], 0, GD_KT, T_FPERR_handler, 0);
f01039da:	b8 fa 3e 10 f0       	mov    $0xf0103efa,%eax
f01039df:	66 a3 80 d2 17 f0    	mov    %ax,0xf017d280
f01039e5:	66 c7 05 82 d2 17 f0 	movw   $0x8,0xf017d282
f01039ec:	08 00 
f01039ee:	c6 05 84 d2 17 f0 00 	movb   $0x0,0xf017d284
f01039f5:	c6 05 85 d2 17 f0 8e 	movb   $0x8e,0xf017d285
f01039fc:	c1 e8 10             	shr    $0x10,%eax
f01039ff:	66 a3 86 d2 17 f0    	mov    %ax,0xf017d286
	SETGATE(idt[T_ALIGN], 0, GD_KT, T_ALIGN_handler, 0);
f0103a05:	b8 00 3f 10 f0       	mov    $0xf0103f00,%eax
f0103a0a:	66 a3 88 d2 17 f0    	mov    %ax,0xf017d288
f0103a10:	66 c7 05 8a d2 17 f0 	movw   $0x8,0xf017d28a
f0103a17:	08 00 
f0103a19:	c6 05 8c d2 17 f0 00 	movb   $0x0,0xf017d28c
f0103a20:	c6 05 8d d2 17 f0 8e 	movb   $0x8e,0xf017d28d
f0103a27:	c1 e8 10             	shr    $0x10,%eax
f0103a2a:	66 a3 8e d2 17 f0    	mov    %ax,0xf017d28e
	SETGATE(idt[T_MCHK], 0, GD_KT, T_MCHK_handler, 0);
f0103a30:	b8 04 3f 10 f0       	mov    $0xf0103f04,%eax
f0103a35:	66 a3 90 d2 17 f0    	mov    %ax,0xf017d290
f0103a3b:	66 c7 05 92 d2 17 f0 	movw   $0x8,0xf017d292
f0103a42:	08 00 
f0103a44:	c6 05 94 d2 17 f0 00 	movb   $0x0,0xf017d294
f0103a4b:	c6 05 95 d2 17 f0 8e 	movb   $0x8e,0xf017d295
f0103a52:	c1 e8 10             	shr    $0x10,%eax
f0103a55:	66 a3 96 d2 17 f0    	mov    %ax,0xf017d296
	SETGATE(idt[T_SIMDERR], 0, GD_KT, T_SIMDERR_handler, 0);
f0103a5b:	b8 0a 3f 10 f0       	mov    $0xf0103f0a,%eax
f0103a60:	66 a3 98 d2 17 f0    	mov    %ax,0xf017d298
f0103a66:	66 c7 05 9a d2 17 f0 	movw   $0x8,0xf017d29a
f0103a6d:	08 00 
f0103a6f:	c6 05 9c d2 17 f0 00 	movb   $0x0,0xf017d29c
f0103a76:	c6 05 9d d2 17 f0 8e 	movb   $0x8e,0xf017d29d
f0103a7d:	c1 e8 10             	shr    $0x10,%eax
f0103a80:	66 a3 9e d2 17 f0    	mov    %ax,0xf017d29e
	SETGATE(idt[T_SYSCALL], 1, GD_KT, T_SYSCALL_handler, 3);
f0103a86:	b8 10 3f 10 f0       	mov    $0xf0103f10,%eax
f0103a8b:	66 a3 80 d3 17 f0    	mov    %ax,0xf017d380
f0103a91:	66 c7 05 82 d3 17 f0 	movw   $0x8,0xf017d382
f0103a98:	08 00 
f0103a9a:	c6 05 84 d3 17 f0 00 	movb   $0x0,0xf017d384
f0103aa1:	c6 05 85 d3 17 f0 ef 	movb   $0xef,0xf017d385
f0103aa8:	c1 e8 10             	shr    $0x10,%eax
f0103aab:	66 a3 86 d3 17 f0    	mov    %ax,0xf017d386
	// Per-CPU setup 
	trap_init_percpu();
f0103ab1:	e8 6a fc ff ff       	call   f0103720 <trap_init_percpu>
}
f0103ab6:	5d                   	pop    %ebp
f0103ab7:	c3                   	ret    

f0103ab8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103ab8:	55                   	push   %ebp
f0103ab9:	89 e5                	mov    %esp,%ebp
f0103abb:	53                   	push   %ebx
f0103abc:	83 ec 14             	sub    $0x14,%esp
f0103abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103ac2:	8b 03                	mov    (%ebx),%eax
f0103ac4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ac8:	c7 04 24 96 61 10 f0 	movl   $0xf0106196,(%esp)
f0103acf:	e8 23 fc ff ff       	call   f01036f7 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103ad4:	8b 43 04             	mov    0x4(%ebx),%eax
f0103ad7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103adb:	c7 04 24 a5 61 10 f0 	movl   $0xf01061a5,(%esp)
f0103ae2:	e8 10 fc ff ff       	call   f01036f7 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103ae7:	8b 43 08             	mov    0x8(%ebx),%eax
f0103aea:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aee:	c7 04 24 b4 61 10 f0 	movl   $0xf01061b4,(%esp)
f0103af5:	e8 fd fb ff ff       	call   f01036f7 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103afa:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103afd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b01:	c7 04 24 c3 61 10 f0 	movl   $0xf01061c3,(%esp)
f0103b08:	e8 ea fb ff ff       	call   f01036f7 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103b0d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103b10:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b14:	c7 04 24 d2 61 10 f0 	movl   $0xf01061d2,(%esp)
f0103b1b:	e8 d7 fb ff ff       	call   f01036f7 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103b20:	8b 43 14             	mov    0x14(%ebx),%eax
f0103b23:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b27:	c7 04 24 e1 61 10 f0 	movl   $0xf01061e1,(%esp)
f0103b2e:	e8 c4 fb ff ff       	call   f01036f7 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103b33:	8b 43 18             	mov    0x18(%ebx),%eax
f0103b36:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b3a:	c7 04 24 f0 61 10 f0 	movl   $0xf01061f0,(%esp)
f0103b41:	e8 b1 fb ff ff       	call   f01036f7 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103b46:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103b49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b4d:	c7 04 24 ff 61 10 f0 	movl   $0xf01061ff,(%esp)
f0103b54:	e8 9e fb ff ff       	call   f01036f7 <cprintf>
}
f0103b59:	83 c4 14             	add    $0x14,%esp
f0103b5c:	5b                   	pop    %ebx
f0103b5d:	5d                   	pop    %ebp
f0103b5e:	c3                   	ret    

f0103b5f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103b5f:	55                   	push   %ebp
f0103b60:	89 e5                	mov    %esp,%ebp
f0103b62:	56                   	push   %esi
f0103b63:	53                   	push   %ebx
f0103b64:	83 ec 10             	sub    $0x10,%esp
f0103b67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103b6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b6e:	c7 04 24 4f 63 10 f0 	movl   $0xf010634f,(%esp)
f0103b75:	e8 7d fb ff ff       	call   f01036f7 <cprintf>
	print_regs(&tf->tf_regs);
f0103b7a:	89 1c 24             	mov    %ebx,(%esp)
f0103b7d:	e8 36 ff ff ff       	call   f0103ab8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103b82:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103b86:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b8a:	c7 04 24 50 62 10 f0 	movl   $0xf0106250,(%esp)
f0103b91:	e8 61 fb ff ff       	call   f01036f7 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103b96:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103b9a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b9e:	c7 04 24 63 62 10 f0 	movl   $0xf0106263,(%esp)
f0103ba5:	e8 4d fb ff ff       	call   f01036f7 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103baa:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103bad:	83 f8 13             	cmp    $0x13,%eax
f0103bb0:	77 09                	ja     f0103bbb <print_trapframe+0x5c>
		return excnames[trapno];
f0103bb2:	8b 14 85 20 65 10 f0 	mov    -0xfef9ae0(,%eax,4),%edx
f0103bb9:	eb 10                	jmp    f0103bcb <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
		return "System call";
f0103bbb:	83 f8 30             	cmp    $0x30,%eax
f0103bbe:	ba 0e 62 10 f0       	mov    $0xf010620e,%edx
f0103bc3:	b9 1a 62 10 f0       	mov    $0xf010621a,%ecx
f0103bc8:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103bcb:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bd3:	c7 04 24 76 62 10 f0 	movl   $0xf0106276,(%esp)
f0103bda:	e8 18 fb ff ff       	call   f01036f7 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103bdf:	3b 1d 00 da 17 f0    	cmp    0xf017da00,%ebx
f0103be5:	75 19                	jne    f0103c00 <print_trapframe+0xa1>
f0103be7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103beb:	75 13                	jne    f0103c00 <print_trapframe+0xa1>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103bed:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103bf0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bf4:	c7 04 24 88 62 10 f0 	movl   $0xf0106288,(%esp)
f0103bfb:	e8 f7 fa ff ff       	call   f01036f7 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103c00:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103c03:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c07:	c7 04 24 97 62 10 f0 	movl   $0xf0106297,(%esp)
f0103c0e:	e8 e4 fa ff ff       	call   f01036f7 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103c13:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c17:	75 51                	jne    f0103c6a <print_trapframe+0x10b>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103c19:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103c1c:	89 c2                	mov    %eax,%edx
f0103c1e:	83 e2 01             	and    $0x1,%edx
f0103c21:	ba 29 62 10 f0       	mov    $0xf0106229,%edx
f0103c26:	b9 34 62 10 f0       	mov    $0xf0106234,%ecx
f0103c2b:	0f 45 ca             	cmovne %edx,%ecx
f0103c2e:	89 c2                	mov    %eax,%edx
f0103c30:	83 e2 02             	and    $0x2,%edx
f0103c33:	ba 40 62 10 f0       	mov    $0xf0106240,%edx
f0103c38:	be 46 62 10 f0       	mov    $0xf0106246,%esi
f0103c3d:	0f 44 d6             	cmove  %esi,%edx
f0103c40:	83 e0 04             	and    $0x4,%eax
f0103c43:	b8 4b 62 10 f0       	mov    $0xf010624b,%eax
f0103c48:	be 7a 63 10 f0       	mov    $0xf010637a,%esi
f0103c4d:	0f 44 c6             	cmove  %esi,%eax
f0103c50:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103c54:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103c58:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c5c:	c7 04 24 a5 62 10 f0 	movl   $0xf01062a5,(%esp)
f0103c63:	e8 8f fa ff ff       	call   f01036f7 <cprintf>
f0103c68:	eb 0c                	jmp    f0103c76 <print_trapframe+0x117>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103c6a:	c7 04 24 c9 53 10 f0 	movl   $0xf01053c9,(%esp)
f0103c71:	e8 81 fa ff ff       	call   f01036f7 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103c76:	8b 43 30             	mov    0x30(%ebx),%eax
f0103c79:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c7d:	c7 04 24 b4 62 10 f0 	movl   $0xf01062b4,(%esp)
f0103c84:	e8 6e fa ff ff       	call   f01036f7 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103c89:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c91:	c7 04 24 c3 62 10 f0 	movl   $0xf01062c3,(%esp)
f0103c98:	e8 5a fa ff ff       	call   f01036f7 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103c9d:	8b 43 38             	mov    0x38(%ebx),%eax
f0103ca0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ca4:	c7 04 24 d6 62 10 f0 	movl   $0xf01062d6,(%esp)
f0103cab:	e8 47 fa ff ff       	call   f01036f7 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103cb0:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103cb4:	74 27                	je     f0103cdd <print_trapframe+0x17e>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103cb6:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103cb9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cbd:	c7 04 24 e5 62 10 f0 	movl   $0xf01062e5,(%esp)
f0103cc4:	e8 2e fa ff ff       	call   f01036f7 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103cc9:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ccd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cd1:	c7 04 24 f4 62 10 f0 	movl   $0xf01062f4,(%esp)
f0103cd8:	e8 1a fa ff ff       	call   f01036f7 <cprintf>
	}
}
f0103cdd:	83 c4 10             	add    $0x10,%esp
f0103ce0:	5b                   	pop    %ebx
f0103ce1:	5e                   	pop    %esi
f0103ce2:	5d                   	pop    %ebp
f0103ce3:	c3                   	ret    

f0103ce4 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103ce4:	55                   	push   %ebp
f0103ce5:	89 e5                	mov    %esp,%ebp
f0103ce7:	53                   	push   %ebx
f0103ce8:	83 ec 14             	sub    $0x14,%esp
f0103ceb:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103cee:	0f 20 d0             	mov    %cr2,%eax

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.

	if((tf->tf_cs & 3) ==0) panic("page fault in kernel-mode");
f0103cf1:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103cf5:	75 1c                	jne    f0103d13 <page_fault_handler+0x2f>
f0103cf7:	c7 44 24 08 07 63 10 	movl   $0xf0106307,0x8(%esp)
f0103cfe:	f0 
f0103cff:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
f0103d06:	00 
f0103d07:	c7 04 24 21 63 10 f0 	movl   $0xf0106321,(%esp)
f0103d0e:	e8 a3 c3 ff ff       	call   f01000b6 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103d13:	8b 53 30             	mov    0x30(%ebx),%edx
f0103d16:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103d1a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d1e:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103d23:	8b 40 48             	mov    0x48(%eax),%eax
f0103d26:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d2a:	c7 04 24 c4 64 10 f0 	movl   $0xf01064c4,(%esp)
f0103d31:	e8 c1 f9 ff ff       	call   f01036f7 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103d36:	89 1c 24             	mov    %ebx,(%esp)
f0103d39:	e8 21 fe ff ff       	call   f0103b5f <print_trapframe>
	env_destroy(curenv);
f0103d3e:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103d43:	89 04 24             	mov    %eax,(%esp)
f0103d46:	e8 79 f8 ff ff       	call   f01035c4 <env_destroy>
}
f0103d4b:	83 c4 14             	add    $0x14,%esp
f0103d4e:	5b                   	pop    %ebx
f0103d4f:	5d                   	pop    %ebp
f0103d50:	c3                   	ret    

f0103d51 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103d51:	55                   	push   %ebp
f0103d52:	89 e5                	mov    %esp,%ebp
f0103d54:	57                   	push   %edi
f0103d55:	56                   	push   %esi
f0103d56:	83 ec 20             	sub    $0x20,%esp
f0103d59:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103d5c:	fc                   	cld    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103d5d:	9c                   	pushf  
f0103d5e:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103d5f:	f6 c4 02             	test   $0x2,%ah
f0103d62:	74 24                	je     f0103d88 <trap+0x37>
f0103d64:	c7 44 24 0c 2d 63 10 	movl   $0xf010632d,0xc(%esp)
f0103d6b:	f0 
f0103d6c:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0103d73:	f0 
f0103d74:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
f0103d7b:	00 
f0103d7c:	c7 04 24 21 63 10 f0 	movl   $0xf0106321,(%esp)
f0103d83:	e8 2e c3 ff ff       	call   f01000b6 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103d88:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d8c:	c7 04 24 46 63 10 f0 	movl   $0xf0106346,(%esp)
f0103d93:	e8 5f f9 ff ff       	call   f01036f7 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103d98:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103d9c:	83 e0 03             	and    $0x3,%eax
f0103d9f:	66 83 f8 03          	cmp    $0x3,%ax
f0103da3:	75 3c                	jne    f0103de1 <trap+0x90>
		// Trapped from user mode.
		assert(curenv);
f0103da5:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103daa:	85 c0                	test   %eax,%eax
f0103dac:	75 24                	jne    f0103dd2 <trap+0x81>
f0103dae:	c7 44 24 0c 61 63 10 	movl   $0xf0106361,0xc(%esp)
f0103db5:	f0 
f0103db6:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0103dbd:	f0 
f0103dbe:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
f0103dc5:	00 
f0103dc6:	c7 04 24 21 63 10 f0 	movl   $0xf0106321,(%esp)
f0103dcd:	e8 e4 c2 ff ff       	call   f01000b6 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103dd2:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103dd7:	89 c7                	mov    %eax,%edi
f0103dd9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103ddb:	8b 35 e8 d1 17 f0    	mov    0xf017d1e8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103de1:	89 35 00 da 17 f0    	mov    %esi,0xf017da00
static void
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	if(tf->tf_trapno == T_PGFLT){
f0103de7:	8b 46 28             	mov    0x28(%esi),%eax
f0103dea:	83 f8 0e             	cmp    $0xe,%eax
f0103ded:	75 0a                	jne    f0103df9 <trap+0xa8>
		page_fault_handler(tf);
f0103def:	89 34 24             	mov    %esi,(%esp)
f0103df2:	e8 ed fe ff ff       	call   f0103ce4 <page_fault_handler>
f0103df7:	eb 7e                	jmp    f0103e77 <trap+0x126>
		return;
	}
	if(tf->tf_trapno == T_BRKPT){
f0103df9:	83 f8 03             	cmp    $0x3,%eax
f0103dfc:	75 0a                	jne    f0103e08 <trap+0xb7>
		monitor(tf);
f0103dfe:	89 34 24             	mov    %esi,(%esp)
f0103e01:	e8 20 ca ff ff       	call   f0100826 <monitor>
f0103e06:	eb 6f                	jmp    f0103e77 <trap+0x126>
		return;
	}
	if(tf->tf_trapno == T_SYSCALL){
f0103e08:	83 f8 30             	cmp    $0x30,%eax
f0103e0b:	75 32                	jne    f0103e3f <trap+0xee>
		tf->tf_regs.reg_eax = syscall(
f0103e0d:	8b 46 04             	mov    0x4(%esi),%eax
f0103e10:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103e14:	8b 06                	mov    (%esi),%eax
f0103e16:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103e1a:	8b 46 10             	mov    0x10(%esi),%eax
f0103e1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e21:	8b 46 18             	mov    0x18(%esi),%eax
f0103e24:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e28:	8b 46 14             	mov    0x14(%esi),%eax
f0103e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e2f:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103e32:	89 04 24             	mov    %eax,(%esp)
f0103e35:	e8 f6 00 00 00       	call   f0103f30 <syscall>
f0103e3a:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103e3d:	eb 38                	jmp    f0103e77 <trap+0x126>
			tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103e3f:	89 34 24             	mov    %esi,(%esp)
f0103e42:	e8 18 fd ff ff       	call   f0103b5f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103e47:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103e4c:	75 1c                	jne    f0103e6a <trap+0x119>
		panic("unhandled trap in kernel");
f0103e4e:	c7 44 24 08 68 63 10 	movl   $0xf0106368,0x8(%esp)
f0103e55:	f0 
f0103e56:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0103e5d:	00 
f0103e5e:	c7 04 24 21 63 10 f0 	movl   $0xf0106321,(%esp)
f0103e65:	e8 4c c2 ff ff       	call   f01000b6 <_panic>
	else {
		env_destroy(curenv);
f0103e6a:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103e6f:	89 04 24             	mov    %eax,(%esp)
f0103e72:	e8 4d f7 ff ff       	call   f01035c4 <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103e77:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103e7c:	85 c0                	test   %eax,%eax
f0103e7e:	74 06                	je     f0103e86 <trap+0x135>
f0103e80:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103e84:	74 24                	je     f0103eaa <trap+0x159>
f0103e86:	c7 44 24 0c e8 64 10 	movl   $0xf01064e8,0xc(%esp)
f0103e8d:	f0 
f0103e8e:	c7 44 24 08 e7 5d 10 	movl   $0xf0105de7,0x8(%esp)
f0103e95:	f0 
f0103e96:	c7 44 24 04 f3 00 00 	movl   $0xf3,0x4(%esp)
f0103e9d:	00 
f0103e9e:	c7 04 24 21 63 10 f0 	movl   $0xf0106321,(%esp)
f0103ea5:	e8 0c c2 ff ff       	call   f01000b6 <_panic>
	env_run(curenv);
f0103eaa:	89 04 24             	mov    %eax,(%esp)
f0103ead:	e8 69 f7 ff ff       	call   f010361b <env_run>

f0103eb2 <T_DIVIDE_handler>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(T_DIVIDE_handler, T_DIVIDE)
f0103eb2:	6a 00                	push   $0x0
f0103eb4:	6a 00                	push   $0x0
f0103eb6:	eb 5e                	jmp    f0103f16 <_alltraps>

f0103eb8 <T_DEBUG_handler>:
TRAPHANDLER_NOEC(T_DEBUG_handler, T_DEBUG)
f0103eb8:	6a 00                	push   $0x0
f0103eba:	6a 01                	push   $0x1
f0103ebc:	eb 58                	jmp    f0103f16 <_alltraps>

f0103ebe <T_NMI_handler>:
TRAPHANDLER_NOEC(T_NMI_handler, T_NMI)
f0103ebe:	6a 00                	push   $0x0
f0103ec0:	6a 02                	push   $0x2
f0103ec2:	eb 52                	jmp    f0103f16 <_alltraps>

f0103ec4 <T_BRKPT_handler>:
TRAPHANDLER_NOEC(T_BRKPT_handler, T_BRKPT)
f0103ec4:	6a 00                	push   $0x0
f0103ec6:	6a 03                	push   $0x3
f0103ec8:	eb 4c                	jmp    f0103f16 <_alltraps>

f0103eca <T_OFLOW_handler>:
TRAPHANDLER_NOEC(T_OFLOW_handler, T_OFLOW)
f0103eca:	6a 00                	push   $0x0
f0103ecc:	6a 04                	push   $0x4
f0103ece:	eb 46                	jmp    f0103f16 <_alltraps>

f0103ed0 <T_BOUND_handler>:
TRAPHANDLER_NOEC(T_BOUND_handler, T_BOUND)
f0103ed0:	6a 00                	push   $0x0
f0103ed2:	6a 05                	push   $0x5
f0103ed4:	eb 40                	jmp    f0103f16 <_alltraps>

f0103ed6 <T_ILLOP_handler>:
TRAPHANDLER_NOEC(T_ILLOP_handler, T_ILLOP)
f0103ed6:	6a 00                	push   $0x0
f0103ed8:	6a 06                	push   $0x6
f0103eda:	eb 3a                	jmp    f0103f16 <_alltraps>

f0103edc <T_DEVICE_handler>:
TRAPHANDLER_NOEC(T_DEVICE_handler, T_DEVICE)
f0103edc:	6a 00                	push   $0x0
f0103ede:	6a 07                	push   $0x7
f0103ee0:	eb 34                	jmp    f0103f16 <_alltraps>

f0103ee2 <T_DBLFLT_handler>:
TRAPHANDLER(T_DBLFLT_handler, T_DBLFLT)
f0103ee2:	6a 08                	push   $0x8
f0103ee4:	eb 30                	jmp    f0103f16 <_alltraps>

f0103ee6 <T_TSS_handler>:
TRAPHANDLER(T_TSS_handler, T_TSS)
f0103ee6:	6a 0a                	push   $0xa
f0103ee8:	eb 2c                	jmp    f0103f16 <_alltraps>

f0103eea <T_SEGNP_handler>:
TRAPHANDLER(T_SEGNP_handler, T_SEGNP)
f0103eea:	6a 0b                	push   $0xb
f0103eec:	eb 28                	jmp    f0103f16 <_alltraps>

f0103eee <T_STACK_handler>:
TRAPHANDLER(T_STACK_handler, T_STACK)
f0103eee:	6a 0c                	push   $0xc
f0103ef0:	eb 24                	jmp    f0103f16 <_alltraps>

f0103ef2 <T_GPFLT_handler>:
TRAPHANDLER(T_GPFLT_handler, T_GPFLT)
f0103ef2:	6a 0d                	push   $0xd
f0103ef4:	eb 20                	jmp    f0103f16 <_alltraps>

f0103ef6 <T_PGFLT_handler>:
TRAPHANDLER(T_PGFLT_handler, T_PGFLT)
f0103ef6:	6a 0e                	push   $0xe
f0103ef8:	eb 1c                	jmp    f0103f16 <_alltraps>

f0103efa <T_FPERR_handler>:
TRAPHANDLER_NOEC(T_FPERR_handler, T_FPERR)
f0103efa:	6a 00                	push   $0x0
f0103efc:	6a 10                	push   $0x10
f0103efe:	eb 16                	jmp    f0103f16 <_alltraps>

f0103f00 <T_ALIGN_handler>:
TRAPHANDLER(T_ALIGN_handler, T_ALIGN)
f0103f00:	6a 11                	push   $0x11
f0103f02:	eb 12                	jmp    f0103f16 <_alltraps>

f0103f04 <T_MCHK_handler>:
TRAPHANDLER_NOEC(T_MCHK_handler, T_MCHK)
f0103f04:	6a 00                	push   $0x0
f0103f06:	6a 12                	push   $0x12
f0103f08:	eb 0c                	jmp    f0103f16 <_alltraps>

f0103f0a <T_SIMDERR_handler>:
TRAPHANDLER_NOEC(T_SIMDERR_handler, T_SIMDERR)
f0103f0a:	6a 00                	push   $0x0
f0103f0c:	6a 13                	push   $0x13
f0103f0e:	eb 06                	jmp    f0103f16 <_alltraps>

f0103f10 <T_SYSCALL_handler>:
TRAPHANDLER_NOEC(T_SYSCALL_handler, T_SYSCALL)
f0103f10:	6a 00                	push   $0x0
f0103f12:	6a 30                	push   $0x30
f0103f14:	eb 00                	jmp    f0103f16 <_alltraps>

f0103f16 <_alltraps>:
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	// build Trapframe
	pushl %ds
f0103f16:	1e                   	push   %ds
	pushl %es
f0103f17:	06                   	push   %es
	pushal
f0103f18:	60                   	pusha  

	// point to kernel data segment
	movw $GD_KD, %ax
f0103f19:	66 b8 10 00          	mov    $0x10,%ax
	movw %ax, %ds
f0103f1d:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103f1f:	8e c0                	mov    %eax,%es

	// call trap() in C
	pushl %esp
f0103f21:	54                   	push   %esp
	call trap
f0103f22:	e8 2a fe ff ff       	call   f0103d51 <trap>
f0103f27:	66 90                	xchg   %ax,%ax
f0103f29:	66 90                	xchg   %ax,%ax
f0103f2b:	66 90                	xchg   %ax,%ax
f0103f2d:	66 90                	xchg   %ax,%ax
f0103f2f:	90                   	nop

f0103f30 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103f30:	55                   	push   %ebp
f0103f31:	89 e5                	mov    %esp,%ebp
f0103f33:	83 ec 28             	sub    $0x28,%esp
f0103f36:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
f0103f39:	83 f8 01             	cmp    $0x1,%eax
f0103f3c:	74 54                	je     f0103f92 <syscall+0x62>
f0103f3e:	83 f8 01             	cmp    $0x1,%eax
f0103f41:	72 12                	jb     f0103f55 <syscall+0x25>
f0103f43:	83 f8 02             	cmp    $0x2,%eax
f0103f46:	74 54                	je     f0103f9c <syscall+0x6c>
f0103f48:	83 f8 03             	cmp    $0x3,%eax
f0103f4b:	74 59                	je     f0103fa6 <syscall+0x76>
f0103f4d:	8d 76 00             	lea    0x0(%esi),%esi
f0103f50:	e9 c2 00 00 00       	jmp    f0104017 <syscall+0xe7>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_P | PTE_U);
f0103f55:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
f0103f5c:	00 
f0103f5d:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f60:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f64:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f6b:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103f70:	89 04 24             	mov    %eax,(%esp)
f0103f73:	e8 a6 ef ff ff       	call   f0102f1e <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103f78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f7f:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f82:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f86:	c7 04 24 70 65 10 f0 	movl   $0xf0106570,(%esp)
f0103f8d:	e8 65 f7 ff ff       	call   f01036f7 <cprintf>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103f92:	e8 3e c5 ff ff       	call   f01004d5 <cons_getc>
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
		case SYS_cputs: sys_cputs((char *)a1, (size_t)a2);
		case SYS_cgetc: return sys_cgetc();
f0103f97:	e9 80 00 00 00       	jmp    f010401c <syscall+0xec>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103f9c:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0103fa1:	8b 40 48             	mov    0x48(%eax),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.
	switch(syscallno){
		case SYS_cputs: sys_cputs((char *)a1, (size_t)a2);
		case SYS_cgetc: return sys_cgetc();
		case SYS_getenvid: return sys_getenvid();
f0103fa4:	eb 76                	jmp    f010401c <syscall+0xec>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103fa6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103fad:	00 
f0103fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103fb1:	89 44 24 04          	mov    %eax,0x4(%esp)

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103fb5:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103fba:	8b 40 48             	mov    0x48(%eax),%eax
f0103fbd:	89 04 24             	mov    %eax,(%esp)
f0103fc0:	e8 4c f0 ff ff       	call   f0103011 <envid2env>
f0103fc5:	85 c0                	test   %eax,%eax
f0103fc7:	78 53                	js     f010401c <syscall+0xec>
		return r;
	if (e == curenv)
f0103fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fcc:	8b 15 e8 d1 17 f0    	mov    0xf017d1e8,%edx
f0103fd2:	39 d0                	cmp    %edx,%eax
f0103fd4:	75 15                	jne    f0103feb <syscall+0xbb>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103fd6:	8b 40 48             	mov    0x48(%eax),%eax
f0103fd9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fdd:	c7 04 24 75 65 10 f0 	movl   $0xf0106575,(%esp)
f0103fe4:	e8 0e f7 ff ff       	call   f01036f7 <cprintf>
f0103fe9:	eb 1a                	jmp    f0104005 <syscall+0xd5>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103feb:	8b 40 48             	mov    0x48(%eax),%eax
f0103fee:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ff2:	8b 42 48             	mov    0x48(%edx),%eax
f0103ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ff9:	c7 04 24 90 65 10 f0 	movl   $0xf0106590,(%esp)
f0104000:	e8 f2 f6 ff ff       	call   f01036f7 <cprintf>
	env_destroy(e);
f0104005:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104008:	89 04 24             	mov    %eax,(%esp)
f010400b:	e8 b4 f5 ff ff       	call   f01035c4 <env_destroy>
	return 0;
f0104010:	b8 00 00 00 00       	mov    $0x0,%eax
f0104015:	eb 05                	jmp    f010401c <syscall+0xec>
	switch(syscallno){
		case SYS_cputs: sys_cputs((char *)a1, (size_t)a2);
		case SYS_cgetc: return sys_cgetc();
		case SYS_getenvid: return sys_getenvid();
		case SYS_env_destroy: return sys_env_destroy(sys_getenvid());
		default: return -E_NO_SYS;
f0104017:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	}

	//panic("syscall not implemented");
}
f010401c:	c9                   	leave  
f010401d:	c3                   	ret    
f010401e:	66 90                	xchg   %ax,%ax

f0104020 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104020:	55                   	push   %ebp
f0104021:	89 e5                	mov    %esp,%ebp
f0104023:	57                   	push   %edi
f0104024:	56                   	push   %esi
f0104025:	53                   	push   %ebx
f0104026:	83 ec 14             	sub    $0x14,%esp
f0104029:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010402c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010402f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104032:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104035:	8b 1a                	mov    (%edx),%ebx
f0104037:	8b 01                	mov    (%ecx),%eax
f0104039:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010403c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104043:	e9 88 00 00 00       	jmp    f01040d0 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f0104048:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010404b:	01 d8                	add    %ebx,%eax
f010404d:	89 c7                	mov    %eax,%edi
f010404f:	c1 ef 1f             	shr    $0x1f,%edi
f0104052:	01 c7                	add    %eax,%edi
f0104054:	d1 ff                	sar    %edi
f0104056:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104059:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010405c:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010405f:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104061:	eb 03                	jmp    f0104066 <stab_binsearch+0x46>
			m--;
f0104063:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104066:	39 c3                	cmp    %eax,%ebx
f0104068:	7f 1f                	jg     f0104089 <stab_binsearch+0x69>
f010406a:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010406e:	83 ea 0c             	sub    $0xc,%edx
f0104071:	39 f1                	cmp    %esi,%ecx
f0104073:	75 ee                	jne    f0104063 <stab_binsearch+0x43>
f0104075:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104078:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010407b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010407e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104082:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104085:	76 18                	jbe    f010409f <stab_binsearch+0x7f>
f0104087:	eb 05                	jmp    f010408e <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104089:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010408c:	eb 42                	jmp    f01040d0 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010408e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104091:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104093:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104096:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010409d:	eb 31                	jmp    f01040d0 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010409f:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01040a2:	73 17                	jae    f01040bb <stab_binsearch+0x9b>
			*region_right = m - 1;
f01040a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01040a7:	83 e8 01             	sub    $0x1,%eax
f01040aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01040ad:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01040b0:	89 07                	mov    %eax,(%edi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01040b2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01040b9:	eb 15                	jmp    f01040d0 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01040bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01040be:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f01040c1:	89 1f                	mov    %ebx,(%edi)
			l = m;
			addr++;
f01040c3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f01040c7:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01040c9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f01040d0:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f01040d3:	0f 8e 6f ff ff ff    	jle    f0104048 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01040d9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f01040dd:	75 0f                	jne    f01040ee <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f01040df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01040e2:	8b 00                	mov    (%eax),%eax
f01040e4:	83 e8 01             	sub    $0x1,%eax
f01040e7:	8b 7d e0             	mov    -0x20(%ebp),%edi
f01040ea:	89 07                	mov    %eax,(%edi)
f01040ec:	eb 2c                	jmp    f010411a <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01040ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01040f1:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01040f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01040f6:	8b 0f                	mov    (%edi),%ecx
f01040f8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01040fb:	8b 7d ec             	mov    -0x14(%ebp),%edi
f01040fe:	8d 14 97             	lea    (%edi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104101:	eb 03                	jmp    f0104106 <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104103:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104106:	39 c8                	cmp    %ecx,%eax
f0104108:	7e 0b                	jle    f0104115 <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f010410a:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010410e:	83 ea 0c             	sub    $0xc,%edx
f0104111:	39 f3                	cmp    %esi,%ebx
f0104113:	75 ee                	jne    f0104103 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104115:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104118:	89 07                	mov    %eax,(%edi)
	}
}
f010411a:	83 c4 14             	add    $0x14,%esp
f010411d:	5b                   	pop    %ebx
f010411e:	5e                   	pop    %esi
f010411f:	5f                   	pop    %edi
f0104120:	5d                   	pop    %ebp
f0104121:	c3                   	ret    

f0104122 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104122:	55                   	push   %ebp
f0104123:	89 e5                	mov    %esp,%ebp
f0104125:	57                   	push   %edi
f0104126:	56                   	push   %esi
f0104127:	53                   	push   %ebx
f0104128:	83 ec 4c             	sub    $0x4c,%esp
f010412b:	8b 75 08             	mov    0x8(%ebp),%esi
f010412e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104131:	c7 07 a8 65 10 f0    	movl   $0xf01065a8,(%edi)
	info->eip_line = 0;
f0104137:	c7 47 04 00 00 00 00 	movl   $0x0,0x4(%edi)
	info->eip_fn_name = "<unknown>";
f010413e:	c7 47 08 a8 65 10 f0 	movl   $0xf01065a8,0x8(%edi)
	info->eip_fn_namelen = 9;
f0104145:	c7 47 0c 09 00 00 00 	movl   $0x9,0xc(%edi)
	info->eip_fn_addr = addr;
f010414c:	89 77 10             	mov    %esi,0x10(%edi)
	info->eip_fn_narg = 0;
f010414f:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104156:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010415c:	77 7f                	ja     f01041dd <debuginfo_eip+0xbb>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f010415e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104165:	00 
f0104166:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f010416d:	00 
f010416e:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0104175:	00 
f0104176:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f010417b:	89 04 24             	mov    %eax,(%esp)
f010417e:	e8 05 ed ff ff       	call   f0102e88 <user_mem_check>
f0104183:	85 c0                	test   %eax,%eax
f0104185:	0f 88 35 02 00 00    	js     f01043c0 <debuginfo_eip+0x29e>

		stabs = usd->stabs;
f010418b:	a1 00 00 20 00       	mov    0x200000,%eax
f0104190:	89 c1                	mov    %eax,%ecx
f0104192:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stab_end = usd->stab_end;
f0104195:	a1 04 00 20 00       	mov    0x200004,%eax
f010419a:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stabstr = usd->stabstr;
f010419d:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f01041a3:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
		stabstr_end = usd->stabstr_end;
f01041a6:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)stabs, stab_end - stabs, PTE_U) < 0) return -1;
f01041ac:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01041b3:	00 
f01041b4:	29 c8                	sub    %ecx,%eax
f01041b6:	c1 f8 02             	sar    $0x2,%eax
f01041b9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01041bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01041c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01041c7:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f01041cc:	89 04 24             	mov    %eax,(%esp)
f01041cf:	e8 b4 ec ff ff       	call   f0102e88 <user_mem_check>
f01041d4:	85 c0                	test   %eax,%eax
f01041d6:	79 1f                	jns    f01041f7 <debuginfo_eip+0xd5>
f01041d8:	e9 ea 01 00 00       	jmp    f01043c7 <debuginfo_eip+0x2a5>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01041dd:	bb d8 0e 11 f0       	mov    $0xf0110ed8,%ebx

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01041e2:	c7 45 c4 a5 e4 10 f0 	movl   $0xf010e4a5,-0x3c(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01041e9:	c7 45 bc a4 e4 10 f0 	movl   $0xf010e4a4,-0x44(%ebp)
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01041f0:	c7 45 c0 d0 67 10 f0 	movl   $0xf01067d0,-0x40(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)stabs, stab_end - stabs, PTE_U) < 0) return -1;
	}
		if(user_mem_check(curenv, (void *)stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f01041f7:	89 d8                	mov    %ebx,%eax
f01041f9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01041fc:	29 c8                	sub    %ecx,%eax
f01041fe:	89 45 b8             	mov    %eax,-0x48(%ebp)
f0104201:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104208:	00 
f0104209:	89 44 24 08          	mov    %eax,0x8(%esp)
f010420d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104211:	a1 e8 d1 17 f0       	mov    0xf017d1e8,%eax
f0104216:	89 04 24             	mov    %eax,(%esp)
f0104219:	e8 6a ec ff ff       	call   f0102e88 <user_mem_check>
f010421e:	85 c0                	test   %eax,%eax
f0104220:	0f 88 a8 01 00 00    	js     f01043ce <debuginfo_eip+0x2ac>

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104226:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f0104229:	0f 83 a6 01 00 00    	jae    f01043d5 <debuginfo_eip+0x2b3>
f010422f:	80 7b ff 00          	cmpb   $0x0,-0x1(%ebx)
f0104233:	0f 85 a3 01 00 00    	jne    f01043dc <debuginfo_eip+0x2ba>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104239:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104240:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104243:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f0104246:	29 d8                	sub    %ebx,%eax
f0104248:	c1 f8 02             	sar    $0x2,%eax
f010424b:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104251:	83 e8 01             	sub    $0x1,%eax
f0104254:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104257:	89 74 24 04          	mov    %esi,0x4(%esp)
f010425b:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104262:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104265:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104268:	89 d8                	mov    %ebx,%eax
f010426a:	e8 b1 fd ff ff       	call   f0104020 <stab_binsearch>
	if (lfile == 0)
f010426f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104272:	85 c0                	test   %eax,%eax
f0104274:	0f 84 69 01 00 00    	je     f01043e3 <debuginfo_eip+0x2c1>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010427a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010427d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104280:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104283:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104287:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010428e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104291:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104294:	89 d8                	mov    %ebx,%eax
f0104296:	e8 85 fd ff ff       	call   f0104020 <stab_binsearch>

	if (lfun <= rfun) {
f010429b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010429e:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01042a1:	39 d0                	cmp    %edx,%eax
f01042a3:	7f 26                	jg     f01042cb <debuginfo_eip+0x1a9>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01042a5:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01042a8:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01042ab:	8d 0c 8b             	lea    (%ebx,%ecx,4),%ecx
f01042ae:	8b 19                	mov    (%ecx),%ebx
f01042b0:	39 5d b8             	cmp    %ebx,-0x48(%ebp)
f01042b3:	76 06                	jbe    f01042bb <debuginfo_eip+0x199>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01042b5:	03 5d c4             	add    -0x3c(%ebp),%ebx
f01042b8:	89 5f 08             	mov    %ebx,0x8(%edi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01042bb:	8b 49 08             	mov    0x8(%ecx),%ecx
f01042be:	89 4f 10             	mov    %ecx,0x10(%edi)
		addr -= info->eip_fn_addr;
f01042c1:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01042c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01042c6:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01042c9:	eb 0f                	jmp    f01042da <debuginfo_eip+0x1b8>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01042cb:	89 77 10             	mov    %esi,0x10(%edi)
		lline = lfile;
f01042ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01042d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01042d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01042da:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01042e1:	00 
f01042e2:	8b 47 08             	mov    0x8(%edi),%eax
f01042e5:	89 04 24             	mov    %eax,(%esp)
f01042e8:	e8 1e 09 00 00       	call   f0104c0b <strfind>
f01042ed:	2b 47 08             	sub    0x8(%edi),%eax
f01042f0:	89 47 0c             	mov    %eax,0xc(%edi)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01042f3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01042f7:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f01042fe:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104301:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104304:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104307:	89 f0                	mov    %esi,%eax
f0104309:	e8 12 fd ff ff       	call   f0104020 <stab_binsearch>
	if(lline <= rline){
f010430e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104311:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104314:	0f 8f d0 00 00 00    	jg     f01043ea <debuginfo_eip+0x2c8>
		info->eip_line = stabs[lline].n_desc;}
f010431a:	8d 04 40             	lea    (%eax,%eax,2),%eax
f010431d:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104322:	89 47 04             	mov    %eax,0x4(%edi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104325:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104328:	89 c3                	mov    %eax,%ebx
f010432a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010432d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104330:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104333:	89 7d 0c             	mov    %edi,0xc(%ebp)
f0104336:	89 df                	mov    %ebx,%edi
f0104338:	eb 06                	jmp    f0104340 <debuginfo_eip+0x21e>
f010433a:	83 e8 01             	sub    $0x1,%eax
f010433d:	83 ea 0c             	sub    $0xc,%edx
f0104340:	89 c6                	mov    %eax,%esi
f0104342:	39 c7                	cmp    %eax,%edi
f0104344:	7f 37                	jg     f010437d <debuginfo_eip+0x25b>
	       && stabs[lline].n_type != N_SOL
f0104346:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010434a:	80 f9 84             	cmp    $0x84,%cl
f010434d:	75 08                	jne    f0104357 <debuginfo_eip+0x235>
f010434f:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104352:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104355:	eb 11                	jmp    f0104368 <debuginfo_eip+0x246>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104357:	80 f9 64             	cmp    $0x64,%cl
f010435a:	75 de                	jne    f010433a <debuginfo_eip+0x218>
f010435c:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104360:	74 d8                	je     f010433a <debuginfo_eip+0x218>
f0104362:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104365:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104368:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010436b:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010436e:	8b 04 86             	mov    (%esi,%eax,4),%eax
f0104371:	39 45 b8             	cmp    %eax,-0x48(%ebp)
f0104374:	76 0a                	jbe    f0104380 <debuginfo_eip+0x25e>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104376:	03 45 c4             	add    -0x3c(%ebp),%eax
f0104379:	89 07                	mov    %eax,(%edi)
f010437b:	eb 03                	jmp    f0104380 <debuginfo_eip+0x25e>
f010437d:	8b 7d 0c             	mov    0xc(%ebp),%edi


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104380:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104383:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104386:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010438b:	39 da                	cmp    %ebx,%edx
f010438d:	7d 67                	jge    f01043f6 <debuginfo_eip+0x2d4>
		for (lline = lfun + 1;
f010438f:	83 c2 01             	add    $0x1,%edx
f0104392:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104395:	89 d0                	mov    %edx,%eax
f0104397:	8d 14 52             	lea    (%edx,%edx,2),%edx
f010439a:	8b 75 c0             	mov    -0x40(%ebp),%esi
f010439d:	8d 14 96             	lea    (%esi,%edx,4),%edx
f01043a0:	eb 04                	jmp    f01043a6 <debuginfo_eip+0x284>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01043a2:	83 47 14 01          	addl   $0x1,0x14(%edi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01043a6:	39 c3                	cmp    %eax,%ebx
f01043a8:	7e 47                	jle    f01043f1 <debuginfo_eip+0x2cf>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01043aa:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01043ae:	83 c0 01             	add    $0x1,%eax
f01043b1:	83 c2 0c             	add    $0xc,%edx
f01043b4:	80 f9 a0             	cmp    $0xa0,%cl
f01043b7:	74 e9                	je     f01043a2 <debuginfo_eip+0x280>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01043b9:	b8 00 00 00 00       	mov    $0x0,%eax
f01043be:	eb 36                	jmp    f01043f6 <debuginfo_eip+0x2d4>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)usd, sizeof(struct UserStabData), PTE_U) < 0) return -1;
f01043c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043c5:	eb 2f                	jmp    f01043f6 <debuginfo_eip+0x2d4>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if(user_mem_check(curenv, (void *)stabs, stab_end - stabs, PTE_U) < 0) return -1;
f01043c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043cc:	eb 28                	jmp    f01043f6 <debuginfo_eip+0x2d4>
	}
		if(user_mem_check(curenv, (void *)stabstr, stabstr_end - stabstr, PTE_U) < 0) return -1;
f01043ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043d3:	eb 21                	jmp    f01043f6 <debuginfo_eip+0x2d4>

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01043d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043da:	eb 1a                	jmp    f01043f6 <debuginfo_eip+0x2d4>
f01043dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043e1:	eb 13                	jmp    f01043f6 <debuginfo_eip+0x2d4>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01043e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043e8:	eb 0c                	jmp    f01043f6 <debuginfo_eip+0x2d4>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if(lline <= rline){
		info->eip_line = stabs[lline].n_desc;}
	else{
		return -1;
f01043ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01043ef:	eb 05                	jmp    f01043f6 <debuginfo_eip+0x2d4>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01043f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01043f6:	83 c4 4c             	add    $0x4c,%esp
f01043f9:	5b                   	pop    %ebx
f01043fa:	5e                   	pop    %esi
f01043fb:	5f                   	pop    %edi
f01043fc:	5d                   	pop    %ebp
f01043fd:	c3                   	ret    
f01043fe:	66 90                	xchg   %ax,%ax

f0104400 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104400:	55                   	push   %ebp
f0104401:	89 e5                	mov    %esp,%ebp
f0104403:	57                   	push   %edi
f0104404:	56                   	push   %esi
f0104405:	53                   	push   %ebx
f0104406:	83 ec 3c             	sub    $0x3c,%esp
f0104409:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010440c:	89 d7                	mov    %edx,%edi
f010440e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104411:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104414:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104417:	89 c3                	mov    %eax,%ebx
f0104419:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010441c:	8b 45 10             	mov    0x10(%ebp),%eax
f010441f:	8b 75 14             	mov    0x14(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104422:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104427:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010442a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010442d:	39 d9                	cmp    %ebx,%ecx
f010442f:	72 05                	jb     f0104436 <printnum+0x36>
f0104431:	3b 45 e0             	cmp    -0x20(%ebp),%eax
f0104434:	77 69                	ja     f010449f <printnum+0x9f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104436:	8b 4d 18             	mov    0x18(%ebp),%ecx
f0104439:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f010443d:	83 ee 01             	sub    $0x1,%esi
f0104440:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0104444:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104448:	8b 44 24 08          	mov    0x8(%esp),%eax
f010444c:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104450:	89 c3                	mov    %eax,%ebx
f0104452:	89 d6                	mov    %edx,%esi
f0104454:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104457:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010445a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010445e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104462:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104465:	89 04 24             	mov    %eax,(%esp)
f0104468:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010446b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010446f:	e8 bc 09 00 00       	call   f0104e30 <__udivdi3>
f0104474:	89 d9                	mov    %ebx,%ecx
f0104476:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010447a:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010447e:	89 04 24             	mov    %eax,(%esp)
f0104481:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104485:	89 fa                	mov    %edi,%edx
f0104487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010448a:	e8 71 ff ff ff       	call   f0104400 <printnum>
f010448f:	eb 1b                	jmp    f01044ac <printnum+0xac>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104491:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104495:	8b 45 18             	mov    0x18(%ebp),%eax
f0104498:	89 04 24             	mov    %eax,(%esp)
f010449b:	ff d3                	call   *%ebx
f010449d:	eb 03                	jmp    f01044a2 <printnum+0xa2>
f010449f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01044a2:	83 ee 01             	sub    $0x1,%esi
f01044a5:	85 f6                	test   %esi,%esi
f01044a7:	7f e8                	jg     f0104491 <printnum+0x91>
f01044a9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01044ac:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01044b0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01044b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01044b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01044ba:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044be:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01044c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044c5:	89 04 24             	mov    %eax,(%esp)
f01044c8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01044cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044cf:	e8 8c 0a 00 00       	call   f0104f60 <__umoddi3>
f01044d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01044d8:	0f be 80 b2 65 10 f0 	movsbl -0xfef9a4e(%eax),%eax
f01044df:	89 04 24             	mov    %eax,(%esp)
f01044e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044e5:	ff d0                	call   *%eax
}
f01044e7:	83 c4 3c             	add    $0x3c,%esp
f01044ea:	5b                   	pop    %ebx
f01044eb:	5e                   	pop    %esi
f01044ec:	5f                   	pop    %edi
f01044ed:	5d                   	pop    %ebp
f01044ee:	c3                   	ret    

f01044ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01044ef:	55                   	push   %ebp
f01044f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01044f2:	83 fa 01             	cmp    $0x1,%edx
f01044f5:	7e 0e                	jle    f0104505 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01044f7:	8b 10                	mov    (%eax),%edx
f01044f9:	8d 4a 08             	lea    0x8(%edx),%ecx
f01044fc:	89 08                	mov    %ecx,(%eax)
f01044fe:	8b 02                	mov    (%edx),%eax
f0104500:	8b 52 04             	mov    0x4(%edx),%edx
f0104503:	eb 22                	jmp    f0104527 <getuint+0x38>
	else if (lflag)
f0104505:	85 d2                	test   %edx,%edx
f0104507:	74 10                	je     f0104519 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104509:	8b 10                	mov    (%eax),%edx
f010450b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010450e:	89 08                	mov    %ecx,(%eax)
f0104510:	8b 02                	mov    (%edx),%eax
f0104512:	ba 00 00 00 00       	mov    $0x0,%edx
f0104517:	eb 0e                	jmp    f0104527 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104519:	8b 10                	mov    (%eax),%edx
f010451b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010451e:	89 08                	mov    %ecx,(%eax)
f0104520:	8b 02                	mov    (%edx),%eax
f0104522:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104527:	5d                   	pop    %ebp
f0104528:	c3                   	ret    

f0104529 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104529:	55                   	push   %ebp
f010452a:	89 e5                	mov    %esp,%ebp
f010452c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010452f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104533:	8b 10                	mov    (%eax),%edx
f0104535:	3b 50 04             	cmp    0x4(%eax),%edx
f0104538:	73 0a                	jae    f0104544 <sprintputch+0x1b>
		*b->buf++ = ch;
f010453a:	8d 4a 01             	lea    0x1(%edx),%ecx
f010453d:	89 08                	mov    %ecx,(%eax)
f010453f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104542:	88 02                	mov    %al,(%edx)
}
f0104544:	5d                   	pop    %ebp
f0104545:	c3                   	ret    

f0104546 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104546:	55                   	push   %ebp
f0104547:	89 e5                	mov    %esp,%ebp
f0104549:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010454c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010454f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104553:	8b 45 10             	mov    0x10(%ebp),%eax
f0104556:	89 44 24 08          	mov    %eax,0x8(%esp)
f010455a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010455d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104561:	8b 45 08             	mov    0x8(%ebp),%eax
f0104564:	89 04 24             	mov    %eax,(%esp)
f0104567:	e8 02 00 00 00       	call   f010456e <vprintfmt>
	va_end(ap);
}
f010456c:	c9                   	leave  
f010456d:	c3                   	ret    

f010456e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010456e:	55                   	push   %ebp
f010456f:	89 e5                	mov    %esp,%ebp
f0104571:	57                   	push   %edi
f0104572:	56                   	push   %esi
f0104573:	53                   	push   %ebx
f0104574:	83 ec 3c             	sub    $0x3c,%esp
f0104577:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010457a:	8b 5d 10             	mov    0x10(%ebp),%ebx
f010457d:	eb 14                	jmp    f0104593 <vprintfmt+0x25>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010457f:	85 c0                	test   %eax,%eax
f0104581:	0f 84 b3 03 00 00    	je     f010493a <vprintfmt+0x3cc>
				return;
			putch(ch, putdat);
f0104587:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010458b:	89 04 24             	mov    %eax,(%esp)
f010458e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104591:	89 f3                	mov    %esi,%ebx
f0104593:	8d 73 01             	lea    0x1(%ebx),%esi
f0104596:	0f b6 03             	movzbl (%ebx),%eax
f0104599:	83 f8 25             	cmp    $0x25,%eax
f010459c:	75 e1                	jne    f010457f <vprintfmt+0x11>
f010459e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01045a2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01045a9:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
f01045b0:	c7 45 dc ff ff ff ff 	movl   $0xffffffff,-0x24(%ebp)
f01045b7:	ba 00 00 00 00       	mov    $0x0,%edx
f01045bc:	eb 1d                	jmp    f01045db <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045be:	89 de                	mov    %ebx,%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01045c0:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01045c4:	eb 15                	jmp    f01045db <vprintfmt+0x6d>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045c6:	89 de                	mov    %ebx,%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01045c8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01045cc:	eb 0d                	jmp    f01045db <vprintfmt+0x6d>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01045ce:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01045d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01045d4:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045db:	8d 5e 01             	lea    0x1(%esi),%ebx
f01045de:	0f b6 0e             	movzbl (%esi),%ecx
f01045e1:	0f b6 c1             	movzbl %cl,%eax
f01045e4:	83 e9 23             	sub    $0x23,%ecx
f01045e7:	80 f9 55             	cmp    $0x55,%cl
f01045ea:	0f 87 2a 03 00 00    	ja     f010491a <vprintfmt+0x3ac>
f01045f0:	0f b6 c9             	movzbl %cl,%ecx
f01045f3:	ff 24 8d 40 66 10 f0 	jmp    *-0xfef99c0(,%ecx,4)
f01045fa:	89 de                	mov    %ebx,%esi
f01045fc:	b9 00 00 00 00       	mov    $0x0,%ecx
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104601:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0104604:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
				ch = *fmt;
f0104608:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010460b:	8d 58 d0             	lea    -0x30(%eax),%ebx
f010460e:	83 fb 09             	cmp    $0x9,%ebx
f0104611:	77 36                	ja     f0104649 <vprintfmt+0xdb>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104613:	83 c6 01             	add    $0x1,%esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104616:	eb e9                	jmp    f0104601 <vprintfmt+0x93>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104618:	8b 45 14             	mov    0x14(%ebp),%eax
f010461b:	8d 48 04             	lea    0x4(%eax),%ecx
f010461e:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104621:	8b 00                	mov    (%eax),%eax
f0104623:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104626:	89 de                	mov    %ebx,%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104628:	eb 22                	jmp    f010464c <vprintfmt+0xde>
f010462a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010462d:	85 c9                	test   %ecx,%ecx
f010462f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104634:	0f 49 c1             	cmovns %ecx,%eax
f0104637:	89 45 dc             	mov    %eax,-0x24(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010463a:	89 de                	mov    %ebx,%esi
f010463c:	eb 9d                	jmp    f01045db <vprintfmt+0x6d>
f010463e:	89 de                	mov    %ebx,%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104640:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
			goto reswitch;
f0104647:	eb 92                	jmp    f01045db <vprintfmt+0x6d>
f0104649:	89 4d d4             	mov    %ecx,-0x2c(%ebp)

		process_precision:
			if (width < 0)
f010464c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104650:	79 89                	jns    f01045db <vprintfmt+0x6d>
f0104652:	e9 77 ff ff ff       	jmp    f01045ce <vprintfmt+0x60>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104657:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010465a:	89 de                	mov    %ebx,%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010465c:	e9 7a ff ff ff       	jmp    f01045db <vprintfmt+0x6d>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104661:	8b 45 14             	mov    0x14(%ebp),%eax
f0104664:	8d 50 04             	lea    0x4(%eax),%edx
f0104667:	89 55 14             	mov    %edx,0x14(%ebp)
f010466a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010466e:	8b 00                	mov    (%eax),%eax
f0104670:	89 04 24             	mov    %eax,(%esp)
f0104673:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104676:	e9 18 ff ff ff       	jmp    f0104593 <vprintfmt+0x25>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010467b:	8b 45 14             	mov    0x14(%ebp),%eax
f010467e:	8d 50 04             	lea    0x4(%eax),%edx
f0104681:	89 55 14             	mov    %edx,0x14(%ebp)
f0104684:	8b 00                	mov    (%eax),%eax
f0104686:	99                   	cltd   
f0104687:	31 d0                	xor    %edx,%eax
f0104689:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010468b:	83 f8 07             	cmp    $0x7,%eax
f010468e:	7f 0b                	jg     f010469b <vprintfmt+0x12d>
f0104690:	8b 14 85 a0 67 10 f0 	mov    -0xfef9860(,%eax,4),%edx
f0104697:	85 d2                	test   %edx,%edx
f0104699:	75 20                	jne    f01046bb <vprintfmt+0x14d>
				printfmt(putch, putdat, "error %d", err);
f010469b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010469f:	c7 44 24 08 ca 65 10 	movl   $0xf01065ca,0x8(%esp)
f01046a6:	f0 
f01046a7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01046ae:	89 04 24             	mov    %eax,(%esp)
f01046b1:	e8 90 fe ff ff       	call   f0104546 <printfmt>
f01046b6:	e9 d8 fe ff ff       	jmp    f0104593 <vprintfmt+0x25>
			else
				printfmt(putch, putdat, "%s", p);
f01046bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01046bf:	c7 44 24 08 f9 5d 10 	movl   $0xf0105df9,0x8(%esp)
f01046c6:	f0 
f01046c7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01046ce:	89 04 24             	mov    %eax,(%esp)
f01046d1:	e8 70 fe ff ff       	call   f0104546 <printfmt>
f01046d6:	e9 b8 fe ff ff       	jmp    f0104593 <vprintfmt+0x25>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046db:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01046de:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01046e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01046e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01046e7:	8d 50 04             	lea    0x4(%eax),%edx
f01046ea:	89 55 14             	mov    %edx,0x14(%ebp)
f01046ed:	8b 30                	mov    (%eax),%esi
				p = "(null)";
f01046ef:	85 f6                	test   %esi,%esi
f01046f1:	b8 c3 65 10 f0       	mov    $0xf01065c3,%eax
f01046f6:	0f 44 f0             	cmove  %eax,%esi
			if (width > 0 && padc != '-')
f01046f9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01046fd:	0f 84 97 00 00 00    	je     f010479a <vprintfmt+0x22c>
f0104703:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0104707:	0f 8e 9b 00 00 00    	jle    f01047a8 <vprintfmt+0x23a>
				for (width -= strnlen(p, precision); width > 0; width--)
f010470d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104711:	89 34 24             	mov    %esi,(%esp)
f0104714:	e8 9f 03 00 00       	call   f0104ab8 <strnlen>
f0104719:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010471c:	29 c2                	sub    %eax,%edx
f010471e:	89 55 d0             	mov    %edx,-0x30(%ebp)
					putch(padc, putdat);
f0104721:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0104725:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104728:	89 75 d8             	mov    %esi,-0x28(%ebp)
f010472b:	8b 75 08             	mov    0x8(%ebp),%esi
f010472e:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0104731:	89 d3                	mov    %edx,%ebx
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104733:	eb 0f                	jmp    f0104744 <vprintfmt+0x1d6>
					putch(padc, putdat);
f0104735:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104739:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010473c:	89 04 24             	mov    %eax,(%esp)
f010473f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104741:	83 eb 01             	sub    $0x1,%ebx
f0104744:	85 db                	test   %ebx,%ebx
f0104746:	7f ed                	jg     f0104735 <vprintfmt+0x1c7>
f0104748:	8b 75 d8             	mov    -0x28(%ebp),%esi
f010474b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010474e:	85 d2                	test   %edx,%edx
f0104750:	b8 00 00 00 00       	mov    $0x0,%eax
f0104755:	0f 49 c2             	cmovns %edx,%eax
f0104758:	29 c2                	sub    %eax,%edx
f010475a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010475d:	89 d7                	mov    %edx,%edi
f010475f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104762:	eb 50                	jmp    f01047b4 <vprintfmt+0x246>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104764:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104768:	74 1e                	je     f0104788 <vprintfmt+0x21a>
f010476a:	0f be d2             	movsbl %dl,%edx
f010476d:	83 ea 20             	sub    $0x20,%edx
f0104770:	83 fa 5e             	cmp    $0x5e,%edx
f0104773:	76 13                	jbe    f0104788 <vprintfmt+0x21a>
					putch('?', putdat);
f0104775:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104778:	89 44 24 04          	mov    %eax,0x4(%esp)
f010477c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0104783:	ff 55 08             	call   *0x8(%ebp)
f0104786:	eb 0d                	jmp    f0104795 <vprintfmt+0x227>
				else
					putch(ch, putdat);
f0104788:	8b 55 0c             	mov    0xc(%ebp),%edx
f010478b:	89 54 24 04          	mov    %edx,0x4(%esp)
f010478f:	89 04 24             	mov    %eax,(%esp)
f0104792:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104795:	83 ef 01             	sub    $0x1,%edi
f0104798:	eb 1a                	jmp    f01047b4 <vprintfmt+0x246>
f010479a:	89 7d 0c             	mov    %edi,0xc(%ebp)
f010479d:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01047a0:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01047a3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01047a6:	eb 0c                	jmp    f01047b4 <vprintfmt+0x246>
f01047a8:	89 7d 0c             	mov    %edi,0xc(%ebp)
f01047ab:	8b 7d dc             	mov    -0x24(%ebp),%edi
f01047ae:	89 5d 10             	mov    %ebx,0x10(%ebp)
f01047b1:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01047b4:	83 c6 01             	add    $0x1,%esi
f01047b7:	0f b6 56 ff          	movzbl -0x1(%esi),%edx
f01047bb:	0f be c2             	movsbl %dl,%eax
f01047be:	85 c0                	test   %eax,%eax
f01047c0:	74 27                	je     f01047e9 <vprintfmt+0x27b>
f01047c2:	85 db                	test   %ebx,%ebx
f01047c4:	78 9e                	js     f0104764 <vprintfmt+0x1f6>
f01047c6:	83 eb 01             	sub    $0x1,%ebx
f01047c9:	79 99                	jns    f0104764 <vprintfmt+0x1f6>
f01047cb:	89 f8                	mov    %edi,%eax
f01047cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01047d0:	8b 75 08             	mov    0x8(%ebp),%esi
f01047d3:	89 c3                	mov    %eax,%ebx
f01047d5:	eb 1a                	jmp    f01047f1 <vprintfmt+0x283>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01047d7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01047db:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01047e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01047e4:	83 eb 01             	sub    $0x1,%ebx
f01047e7:	eb 08                	jmp    f01047f1 <vprintfmt+0x283>
f01047e9:	89 fb                	mov    %edi,%ebx
f01047eb:	8b 75 08             	mov    0x8(%ebp),%esi
f01047ee:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01047f1:	85 db                	test   %ebx,%ebx
f01047f3:	7f e2                	jg     f01047d7 <vprintfmt+0x269>
f01047f5:	89 75 08             	mov    %esi,0x8(%ebp)
f01047f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
f01047fb:	e9 93 fd ff ff       	jmp    f0104593 <vprintfmt+0x25>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104800:	83 fa 01             	cmp    $0x1,%edx
f0104803:	7e 16                	jle    f010481b <vprintfmt+0x2ad>
		return va_arg(*ap, long long);
f0104805:	8b 45 14             	mov    0x14(%ebp),%eax
f0104808:	8d 50 08             	lea    0x8(%eax),%edx
f010480b:	89 55 14             	mov    %edx,0x14(%ebp)
f010480e:	8b 50 04             	mov    0x4(%eax),%edx
f0104811:	8b 00                	mov    (%eax),%eax
f0104813:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104816:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104819:	eb 32                	jmp    f010484d <vprintfmt+0x2df>
	else if (lflag)
f010481b:	85 d2                	test   %edx,%edx
f010481d:	74 18                	je     f0104837 <vprintfmt+0x2c9>
		return va_arg(*ap, long);
f010481f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104822:	8d 50 04             	lea    0x4(%eax),%edx
f0104825:	89 55 14             	mov    %edx,0x14(%ebp)
f0104828:	8b 30                	mov    (%eax),%esi
f010482a:	89 75 e0             	mov    %esi,-0x20(%ebp)
f010482d:	89 f0                	mov    %esi,%eax
f010482f:	c1 f8 1f             	sar    $0x1f,%eax
f0104832:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104835:	eb 16                	jmp    f010484d <vprintfmt+0x2df>
	else
		return va_arg(*ap, int);
f0104837:	8b 45 14             	mov    0x14(%ebp),%eax
f010483a:	8d 50 04             	lea    0x4(%eax),%edx
f010483d:	89 55 14             	mov    %edx,0x14(%ebp)
f0104840:	8b 30                	mov    (%eax),%esi
f0104842:	89 75 e0             	mov    %esi,-0x20(%ebp)
f0104845:	89 f0                	mov    %esi,%eax
f0104847:	c1 f8 1f             	sar    $0x1f,%eax
f010484a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f010484d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104850:	8b 55 e4             	mov    -0x1c(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104853:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104858:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010485c:	0f 89 80 00 00 00    	jns    f01048e2 <vprintfmt+0x374>
				putch('-', putdat);
f0104862:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104866:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010486d:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0104870:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104873:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104876:	f7 d8                	neg    %eax
f0104878:	83 d2 00             	adc    $0x0,%edx
f010487b:	f7 da                	neg    %edx
			}
			base = 10;
f010487d:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104882:	eb 5e                	jmp    f01048e2 <vprintfmt+0x374>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104884:	8d 45 14             	lea    0x14(%ebp),%eax
f0104887:	e8 63 fc ff ff       	call   f01044ef <getuint>
			base = 10;
f010488c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0104891:	eb 4f                	jmp    f01048e2 <vprintfmt+0x374>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0104893:	8d 45 14             	lea    0x14(%ebp),%eax
f0104896:	e8 54 fc ff ff       	call   f01044ef <getuint>
			base = 8;
f010489b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f01048a0:	eb 40                	jmp    f01048e2 <vprintfmt+0x374>

		// pointer
		case 'p':
			putch('0', putdat);
f01048a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01048a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01048ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01048b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01048b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01048bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01048be:	8b 45 14             	mov    0x14(%ebp),%eax
f01048c1:	8d 50 04             	lea    0x4(%eax),%edx
f01048c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01048c7:	8b 00                	mov    (%eax),%eax
f01048c9:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01048ce:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f01048d3:	eb 0d                	jmp    f01048e2 <vprintfmt+0x374>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01048d5:	8d 45 14             	lea    0x14(%ebp),%eax
f01048d8:	e8 12 fc ff ff       	call   f01044ef <getuint>
			base = 16;
f01048dd:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f01048e2:	0f be 75 d8          	movsbl -0x28(%ebp),%esi
f01048e6:	89 74 24 10          	mov    %esi,0x10(%esp)
f01048ea:	8b 75 dc             	mov    -0x24(%ebp),%esi
f01048ed:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01048f1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01048f5:	89 04 24             	mov    %eax,(%esp)
f01048f8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01048fc:	89 fa                	mov    %edi,%edx
f01048fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0104901:	e8 fa fa ff ff       	call   f0104400 <printnum>
			break;
f0104906:	e9 88 fc ff ff       	jmp    f0104593 <vprintfmt+0x25>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010490b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010490f:	89 04 24             	mov    %eax,(%esp)
f0104912:	ff 55 08             	call   *0x8(%ebp)
			break;
f0104915:	e9 79 fc ff ff       	jmp    f0104593 <vprintfmt+0x25>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010491a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010491e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104925:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104928:	89 f3                	mov    %esi,%ebx
f010492a:	eb 03                	jmp    f010492f <vprintfmt+0x3c1>
f010492c:	83 eb 01             	sub    $0x1,%ebx
f010492f:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0104933:	75 f7                	jne    f010492c <vprintfmt+0x3be>
f0104935:	e9 59 fc ff ff       	jmp    f0104593 <vprintfmt+0x25>
				/* do nothing */;
			break;
		}
	}
}
f010493a:	83 c4 3c             	add    $0x3c,%esp
f010493d:	5b                   	pop    %ebx
f010493e:	5e                   	pop    %esi
f010493f:	5f                   	pop    %edi
f0104940:	5d                   	pop    %ebp
f0104941:	c3                   	ret    

f0104942 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104942:	55                   	push   %ebp
f0104943:	89 e5                	mov    %esp,%ebp
f0104945:	83 ec 28             	sub    $0x28,%esp
f0104948:	8b 45 08             	mov    0x8(%ebp),%eax
f010494b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010494e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104951:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104955:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104958:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010495f:	85 c0                	test   %eax,%eax
f0104961:	74 30                	je     f0104993 <vsnprintf+0x51>
f0104963:	85 d2                	test   %edx,%edx
f0104965:	7e 2c                	jle    f0104993 <vsnprintf+0x51>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104967:	8b 45 14             	mov    0x14(%ebp),%eax
f010496a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010496e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104971:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104975:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104978:	89 44 24 04          	mov    %eax,0x4(%esp)
f010497c:	c7 04 24 29 45 10 f0 	movl   $0xf0104529,(%esp)
f0104983:	e8 e6 fb ff ff       	call   f010456e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104988:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010498b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010498e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104991:	eb 05                	jmp    f0104998 <vsnprintf+0x56>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104993:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104998:	c9                   	leave  
f0104999:	c3                   	ret    

f010499a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010499a:	55                   	push   %ebp
f010499b:	89 e5                	mov    %esp,%ebp
f010499d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01049a0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01049a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01049a7:	8b 45 10             	mov    0x10(%ebp),%eax
f01049aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01049ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01049b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01049b8:	89 04 24             	mov    %eax,(%esp)
f01049bb:	e8 82 ff ff ff       	call   f0104942 <vsnprintf>
	va_end(ap);

	return rc;
}
f01049c0:	c9                   	leave  
f01049c1:	c3                   	ret    
f01049c2:	66 90                	xchg   %ax,%ax
f01049c4:	66 90                	xchg   %ax,%ax
f01049c6:	66 90                	xchg   %ax,%ax
f01049c8:	66 90                	xchg   %ax,%ax
f01049ca:	66 90                	xchg   %ax,%ax
f01049cc:	66 90                	xchg   %ax,%ax
f01049ce:	66 90                	xchg   %ax,%ax

f01049d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01049d0:	55                   	push   %ebp
f01049d1:	89 e5                	mov    %esp,%ebp
f01049d3:	57                   	push   %edi
f01049d4:	56                   	push   %esi
f01049d5:	53                   	push   %ebx
f01049d6:	83 ec 1c             	sub    $0x1c,%esp
f01049d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01049dc:	85 c0                	test   %eax,%eax
f01049de:	74 10                	je     f01049f0 <readline+0x20>
		cprintf("%s", prompt);
f01049e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01049e4:	c7 04 24 f9 5d 10 f0 	movl   $0xf0105df9,(%esp)
f01049eb:	e8 07 ed ff ff       	call   f01036f7 <cprintf>

	i = 0;
	echoing = iscons(0);
f01049f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01049f7:	e8 36 bc ff ff       	call   f0100632 <iscons>
f01049fc:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01049fe:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104a03:	e8 19 bc ff ff       	call   f0100621 <getchar>
f0104a08:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104a0a:	85 c0                	test   %eax,%eax
f0104a0c:	79 17                	jns    f0104a25 <readline+0x55>
			cprintf("read error: %e\n", c);
f0104a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a12:	c7 04 24 c0 67 10 f0 	movl   $0xf01067c0,(%esp)
f0104a19:	e8 d9 ec ff ff       	call   f01036f7 <cprintf>
			return NULL;
f0104a1e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104a23:	eb 6d                	jmp    f0104a92 <readline+0xc2>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104a25:	83 f8 7f             	cmp    $0x7f,%eax
f0104a28:	74 05                	je     f0104a2f <readline+0x5f>
f0104a2a:	83 f8 08             	cmp    $0x8,%eax
f0104a2d:	75 19                	jne    f0104a48 <readline+0x78>
f0104a2f:	85 f6                	test   %esi,%esi
f0104a31:	7e 15                	jle    f0104a48 <readline+0x78>
			if (echoing)
f0104a33:	85 ff                	test   %edi,%edi
f0104a35:	74 0c                	je     f0104a43 <readline+0x73>
				cputchar('\b');
f0104a37:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104a3e:	e8 ce bb ff ff       	call   f0100611 <cputchar>
			i--;
f0104a43:	83 ee 01             	sub    $0x1,%esi
f0104a46:	eb bb                	jmp    f0104a03 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104a48:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104a4e:	7f 1c                	jg     f0104a6c <readline+0x9c>
f0104a50:	83 fb 1f             	cmp    $0x1f,%ebx
f0104a53:	7e 17                	jle    f0104a6c <readline+0x9c>
			if (echoing)
f0104a55:	85 ff                	test   %edi,%edi
f0104a57:	74 08                	je     f0104a61 <readline+0x91>
				cputchar(c);
f0104a59:	89 1c 24             	mov    %ebx,(%esp)
f0104a5c:	e8 b0 bb ff ff       	call   f0100611 <cputchar>
			buf[i++] = c;
f0104a61:	88 9e a0 da 17 f0    	mov    %bl,-0xfe82560(%esi)
f0104a67:	8d 76 01             	lea    0x1(%esi),%esi
f0104a6a:	eb 97                	jmp    f0104a03 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104a6c:	83 fb 0d             	cmp    $0xd,%ebx
f0104a6f:	74 05                	je     f0104a76 <readline+0xa6>
f0104a71:	83 fb 0a             	cmp    $0xa,%ebx
f0104a74:	75 8d                	jne    f0104a03 <readline+0x33>
			if (echoing)
f0104a76:	85 ff                	test   %edi,%edi
f0104a78:	74 0c                	je     f0104a86 <readline+0xb6>
				cputchar('\n');
f0104a7a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104a81:	e8 8b bb ff ff       	call   f0100611 <cputchar>
			buf[i] = 0;
f0104a86:	c6 86 a0 da 17 f0 00 	movb   $0x0,-0xfe82560(%esi)
			return buf;
f0104a8d:	b8 a0 da 17 f0       	mov    $0xf017daa0,%eax
		}
	}
}
f0104a92:	83 c4 1c             	add    $0x1c,%esp
f0104a95:	5b                   	pop    %ebx
f0104a96:	5e                   	pop    %esi
f0104a97:	5f                   	pop    %edi
f0104a98:	5d                   	pop    %ebp
f0104a99:	c3                   	ret    
f0104a9a:	66 90                	xchg   %ax,%ax
f0104a9c:	66 90                	xchg   %ax,%ax
f0104a9e:	66 90                	xchg   %ax,%ax

f0104aa0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104aa0:	55                   	push   %ebp
f0104aa1:	89 e5                	mov    %esp,%ebp
f0104aa3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104aa6:	b8 00 00 00 00       	mov    $0x0,%eax
f0104aab:	eb 03                	jmp    f0104ab0 <strlen+0x10>
		n++;
f0104aad:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104ab0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104ab4:	75 f7                	jne    f0104aad <strlen+0xd>
		n++;
	return n;
}
f0104ab6:	5d                   	pop    %ebp
f0104ab7:	c3                   	ret    

f0104ab8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104ab8:	55                   	push   %ebp
f0104ab9:	89 e5                	mov    %esp,%ebp
f0104abb:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104abe:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ac1:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ac6:	eb 03                	jmp    f0104acb <strnlen+0x13>
		n++;
f0104ac8:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104acb:	39 d0                	cmp    %edx,%eax
f0104acd:	74 06                	je     f0104ad5 <strnlen+0x1d>
f0104acf:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0104ad3:	75 f3                	jne    f0104ac8 <strnlen+0x10>
		n++;
	return n;
}
f0104ad5:	5d                   	pop    %ebp
f0104ad6:	c3                   	ret    

f0104ad7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104ad7:	55                   	push   %ebp
f0104ad8:	89 e5                	mov    %esp,%ebp
f0104ada:	53                   	push   %ebx
f0104adb:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ade:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104ae1:	89 c2                	mov    %eax,%edx
f0104ae3:	83 c2 01             	add    $0x1,%edx
f0104ae6:	83 c1 01             	add    $0x1,%ecx
f0104ae9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0104aed:	88 5a ff             	mov    %bl,-0x1(%edx)
f0104af0:	84 db                	test   %bl,%bl
f0104af2:	75 ef                	jne    f0104ae3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104af4:	5b                   	pop    %ebx
f0104af5:	5d                   	pop    %ebp
f0104af6:	c3                   	ret    

f0104af7 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104af7:	55                   	push   %ebp
f0104af8:	89 e5                	mov    %esp,%ebp
f0104afa:	53                   	push   %ebx
f0104afb:	83 ec 08             	sub    $0x8,%esp
f0104afe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0104b01:	89 1c 24             	mov    %ebx,(%esp)
f0104b04:	e8 97 ff ff ff       	call   f0104aa0 <strlen>
	strcpy(dst + len, src);
f0104b09:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b0c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104b10:	01 d8                	add    %ebx,%eax
f0104b12:	89 04 24             	mov    %eax,(%esp)
f0104b15:	e8 bd ff ff ff       	call   f0104ad7 <strcpy>
	return dst;
}
f0104b1a:	89 d8                	mov    %ebx,%eax
f0104b1c:	83 c4 08             	add    $0x8,%esp
f0104b1f:	5b                   	pop    %ebx
f0104b20:	5d                   	pop    %ebp
f0104b21:	c3                   	ret    

f0104b22 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0104b22:	55                   	push   %ebp
f0104b23:	89 e5                	mov    %esp,%ebp
f0104b25:	56                   	push   %esi
f0104b26:	53                   	push   %ebx
f0104b27:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104b2d:	89 f3                	mov    %esi,%ebx
f0104b2f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b32:	89 f2                	mov    %esi,%edx
f0104b34:	eb 0f                	jmp    f0104b45 <strncpy+0x23>
		*dst++ = *src;
f0104b36:	83 c2 01             	add    $0x1,%edx
f0104b39:	0f b6 01             	movzbl (%ecx),%eax
f0104b3c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104b3f:	80 39 01             	cmpb   $0x1,(%ecx)
f0104b42:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104b45:	39 da                	cmp    %ebx,%edx
f0104b47:	75 ed                	jne    f0104b36 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104b49:	89 f0                	mov    %esi,%eax
f0104b4b:	5b                   	pop    %ebx
f0104b4c:	5e                   	pop    %esi
f0104b4d:	5d                   	pop    %ebp
f0104b4e:	c3                   	ret    

f0104b4f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104b4f:	55                   	push   %ebp
f0104b50:	89 e5                	mov    %esp,%ebp
f0104b52:	56                   	push   %esi
f0104b53:	53                   	push   %ebx
f0104b54:	8b 75 08             	mov    0x8(%ebp),%esi
f0104b57:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104b5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104b5d:	89 f0                	mov    %esi,%eax
f0104b5f:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104b63:	85 c9                	test   %ecx,%ecx
f0104b65:	75 0b                	jne    f0104b72 <strlcpy+0x23>
f0104b67:	eb 1d                	jmp    f0104b86 <strlcpy+0x37>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104b69:	83 c0 01             	add    $0x1,%eax
f0104b6c:	83 c2 01             	add    $0x1,%edx
f0104b6f:	88 48 ff             	mov    %cl,-0x1(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0104b72:	39 d8                	cmp    %ebx,%eax
f0104b74:	74 0b                	je     f0104b81 <strlcpy+0x32>
f0104b76:	0f b6 0a             	movzbl (%edx),%ecx
f0104b79:	84 c9                	test   %cl,%cl
f0104b7b:	75 ec                	jne    f0104b69 <strlcpy+0x1a>
f0104b7d:	89 c2                	mov    %eax,%edx
f0104b7f:	eb 02                	jmp    f0104b83 <strlcpy+0x34>
f0104b81:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104b83:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104b86:	29 f0                	sub    %esi,%eax
}
f0104b88:	5b                   	pop    %ebx
f0104b89:	5e                   	pop    %esi
f0104b8a:	5d                   	pop    %ebp
f0104b8b:	c3                   	ret    

f0104b8c <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104b8c:	55                   	push   %ebp
f0104b8d:	89 e5                	mov    %esp,%ebp
f0104b8f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104b92:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104b95:	eb 06                	jmp    f0104b9d <strcmp+0x11>
		p++, q++;
f0104b97:	83 c1 01             	add    $0x1,%ecx
f0104b9a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104b9d:	0f b6 01             	movzbl (%ecx),%eax
f0104ba0:	84 c0                	test   %al,%al
f0104ba2:	74 04                	je     f0104ba8 <strcmp+0x1c>
f0104ba4:	3a 02                	cmp    (%edx),%al
f0104ba6:	74 ef                	je     f0104b97 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104ba8:	0f b6 c0             	movzbl %al,%eax
f0104bab:	0f b6 12             	movzbl (%edx),%edx
f0104bae:	29 d0                	sub    %edx,%eax
}
f0104bb0:	5d                   	pop    %ebp
f0104bb1:	c3                   	ret    

f0104bb2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104bb2:	55                   	push   %ebp
f0104bb3:	89 e5                	mov    %esp,%ebp
f0104bb5:	53                   	push   %ebx
f0104bb6:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bb9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bbc:	89 c3                	mov    %eax,%ebx
f0104bbe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104bc1:	eb 06                	jmp    f0104bc9 <strncmp+0x17>
		n--, p++, q++;
f0104bc3:	83 c0 01             	add    $0x1,%eax
f0104bc6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104bc9:	39 d8                	cmp    %ebx,%eax
f0104bcb:	74 15                	je     f0104be2 <strncmp+0x30>
f0104bcd:	0f b6 08             	movzbl (%eax),%ecx
f0104bd0:	84 c9                	test   %cl,%cl
f0104bd2:	74 04                	je     f0104bd8 <strncmp+0x26>
f0104bd4:	3a 0a                	cmp    (%edx),%cl
f0104bd6:	74 eb                	je     f0104bc3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104bd8:	0f b6 00             	movzbl (%eax),%eax
f0104bdb:	0f b6 12             	movzbl (%edx),%edx
f0104bde:	29 d0                	sub    %edx,%eax
f0104be0:	eb 05                	jmp    f0104be7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104be2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104be7:	5b                   	pop    %ebx
f0104be8:	5d                   	pop    %ebp
f0104be9:	c3                   	ret    

f0104bea <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104bea:	55                   	push   %ebp
f0104beb:	89 e5                	mov    %esp,%ebp
f0104bed:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104bf4:	eb 07                	jmp    f0104bfd <strchr+0x13>
		if (*s == c)
f0104bf6:	38 ca                	cmp    %cl,%dl
f0104bf8:	74 0f                	je     f0104c09 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104bfa:	83 c0 01             	add    $0x1,%eax
f0104bfd:	0f b6 10             	movzbl (%eax),%edx
f0104c00:	84 d2                	test   %dl,%dl
f0104c02:	75 f2                	jne    f0104bf6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104c04:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104c09:	5d                   	pop    %ebp
f0104c0a:	c3                   	ret    

f0104c0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104c0b:	55                   	push   %ebp
f0104c0c:	89 e5                	mov    %esp,%ebp
f0104c0e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104c15:	eb 07                	jmp    f0104c1e <strfind+0x13>
		if (*s == c)
f0104c17:	38 ca                	cmp    %cl,%dl
f0104c19:	74 0a                	je     f0104c25 <strfind+0x1a>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104c1b:	83 c0 01             	add    $0x1,%eax
f0104c1e:	0f b6 10             	movzbl (%eax),%edx
f0104c21:	84 d2                	test   %dl,%dl
f0104c23:	75 f2                	jne    f0104c17 <strfind+0xc>
		if (*s == c)
			break;
	return (char *) s;
}
f0104c25:	5d                   	pop    %ebp
f0104c26:	c3                   	ret    

f0104c27 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104c27:	55                   	push   %ebp
f0104c28:	89 e5                	mov    %esp,%ebp
f0104c2a:	57                   	push   %edi
f0104c2b:	56                   	push   %esi
f0104c2c:	53                   	push   %ebx
f0104c2d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104c30:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104c33:	85 c9                	test   %ecx,%ecx
f0104c35:	74 36                	je     f0104c6d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104c37:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104c3d:	75 28                	jne    f0104c67 <memset+0x40>
f0104c3f:	f6 c1 03             	test   $0x3,%cl
f0104c42:	75 23                	jne    f0104c67 <memset+0x40>
		c &= 0xFF;
f0104c44:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104c48:	89 d3                	mov    %edx,%ebx
f0104c4a:	c1 e3 08             	shl    $0x8,%ebx
f0104c4d:	89 d6                	mov    %edx,%esi
f0104c4f:	c1 e6 18             	shl    $0x18,%esi
f0104c52:	89 d0                	mov    %edx,%eax
f0104c54:	c1 e0 10             	shl    $0x10,%eax
f0104c57:	09 f0                	or     %esi,%eax
f0104c59:	09 c2                	or     %eax,%edx
f0104c5b:	89 d0                	mov    %edx,%eax
f0104c5d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104c5f:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104c62:	fc                   	cld    
f0104c63:	f3 ab                	rep stos %eax,%es:(%edi)
f0104c65:	eb 06                	jmp    f0104c6d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104c67:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104c6a:	fc                   	cld    
f0104c6b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104c6d:	89 f8                	mov    %edi,%eax
f0104c6f:	5b                   	pop    %ebx
f0104c70:	5e                   	pop    %esi
f0104c71:	5f                   	pop    %edi
f0104c72:	5d                   	pop    %ebp
f0104c73:	c3                   	ret    

f0104c74 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104c74:	55                   	push   %ebp
f0104c75:	89 e5                	mov    %esp,%ebp
f0104c77:	57                   	push   %edi
f0104c78:	56                   	push   %esi
f0104c79:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c7c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104c82:	39 c6                	cmp    %eax,%esi
f0104c84:	73 35                	jae    f0104cbb <memmove+0x47>
f0104c86:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104c89:	39 d0                	cmp    %edx,%eax
f0104c8b:	73 2e                	jae    f0104cbb <memmove+0x47>
		s += n;
		d += n;
f0104c8d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f0104c90:	89 d6                	mov    %edx,%esi
f0104c92:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104c94:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104c9a:	75 13                	jne    f0104caf <memmove+0x3b>
f0104c9c:	f6 c1 03             	test   $0x3,%cl
f0104c9f:	75 0e                	jne    f0104caf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104ca1:	83 ef 04             	sub    $0x4,%edi
f0104ca4:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104ca7:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104caa:	fd                   	std    
f0104cab:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104cad:	eb 09                	jmp    f0104cb8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104caf:	83 ef 01             	sub    $0x1,%edi
f0104cb2:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104cb5:	fd                   	std    
f0104cb6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104cb8:	fc                   	cld    
f0104cb9:	eb 1d                	jmp    f0104cd8 <memmove+0x64>
f0104cbb:	89 f2                	mov    %esi,%edx
f0104cbd:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104cbf:	f6 c2 03             	test   $0x3,%dl
f0104cc2:	75 0f                	jne    f0104cd3 <memmove+0x5f>
f0104cc4:	f6 c1 03             	test   $0x3,%cl
f0104cc7:	75 0a                	jne    f0104cd3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104cc9:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104ccc:	89 c7                	mov    %eax,%edi
f0104cce:	fc                   	cld    
f0104ccf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104cd1:	eb 05                	jmp    f0104cd8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104cd3:	89 c7                	mov    %eax,%edi
f0104cd5:	fc                   	cld    
f0104cd6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104cd8:	5e                   	pop    %esi
f0104cd9:	5f                   	pop    %edi
f0104cda:	5d                   	pop    %ebp
f0104cdb:	c3                   	ret    

f0104cdc <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104cdc:	55                   	push   %ebp
f0104cdd:	89 e5                	mov    %esp,%ebp
f0104cdf:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104ce2:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ce5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104cec:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cf3:	89 04 24             	mov    %eax,(%esp)
f0104cf6:	e8 79 ff ff ff       	call   f0104c74 <memmove>
}
f0104cfb:	c9                   	leave  
f0104cfc:	c3                   	ret    

f0104cfd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104cfd:	55                   	push   %ebp
f0104cfe:	89 e5                	mov    %esp,%ebp
f0104d00:	56                   	push   %esi
f0104d01:	53                   	push   %ebx
f0104d02:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104d08:	89 d6                	mov    %edx,%esi
f0104d0a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d0d:	eb 1a                	jmp    f0104d29 <memcmp+0x2c>
		if (*s1 != *s2)
f0104d0f:	0f b6 02             	movzbl (%edx),%eax
f0104d12:	0f b6 19             	movzbl (%ecx),%ebx
f0104d15:	38 d8                	cmp    %bl,%al
f0104d17:	74 0a                	je     f0104d23 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0104d19:	0f b6 c0             	movzbl %al,%eax
f0104d1c:	0f b6 db             	movzbl %bl,%ebx
f0104d1f:	29 d8                	sub    %ebx,%eax
f0104d21:	eb 0f                	jmp    f0104d32 <memcmp+0x35>
		s1++, s2++;
f0104d23:	83 c2 01             	add    $0x1,%edx
f0104d26:	83 c1 01             	add    $0x1,%ecx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104d29:	39 f2                	cmp    %esi,%edx
f0104d2b:	75 e2                	jne    f0104d0f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104d2d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104d32:	5b                   	pop    %ebx
f0104d33:	5e                   	pop    %esi
f0104d34:	5d                   	pop    %ebp
f0104d35:	c3                   	ret    

f0104d36 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104d36:	55                   	push   %ebp
f0104d37:	89 e5                	mov    %esp,%ebp
f0104d39:	8b 45 08             	mov    0x8(%ebp),%eax
f0104d3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104d3f:	89 c2                	mov    %eax,%edx
f0104d41:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104d44:	eb 07                	jmp    f0104d4d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104d46:	38 08                	cmp    %cl,(%eax)
f0104d48:	74 07                	je     f0104d51 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104d4a:	83 c0 01             	add    $0x1,%eax
f0104d4d:	39 d0                	cmp    %edx,%eax
f0104d4f:	72 f5                	jb     f0104d46 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104d51:	5d                   	pop    %ebp
f0104d52:	c3                   	ret    

f0104d53 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104d53:	55                   	push   %ebp
f0104d54:	89 e5                	mov    %esp,%ebp
f0104d56:	57                   	push   %edi
f0104d57:	56                   	push   %esi
f0104d58:	53                   	push   %ebx
f0104d59:	8b 55 08             	mov    0x8(%ebp),%edx
f0104d5c:	8b 45 10             	mov    0x10(%ebp),%eax
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d5f:	eb 03                	jmp    f0104d64 <strtol+0x11>
		s++;
f0104d61:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104d64:	0f b6 0a             	movzbl (%edx),%ecx
f0104d67:	80 f9 09             	cmp    $0x9,%cl
f0104d6a:	74 f5                	je     f0104d61 <strtol+0xe>
f0104d6c:	80 f9 20             	cmp    $0x20,%cl
f0104d6f:	74 f0                	je     f0104d61 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104d71:	80 f9 2b             	cmp    $0x2b,%cl
f0104d74:	75 0a                	jne    f0104d80 <strtol+0x2d>
		s++;
f0104d76:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104d79:	bf 00 00 00 00       	mov    $0x0,%edi
f0104d7e:	eb 11                	jmp    f0104d91 <strtol+0x3e>
f0104d80:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104d85:	80 f9 2d             	cmp    $0x2d,%cl
f0104d88:	75 07                	jne    f0104d91 <strtol+0x3e>
		s++, neg = 1;
f0104d8a:	8d 52 01             	lea    0x1(%edx),%edx
f0104d8d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104d91:	a9 ef ff ff ff       	test   $0xffffffef,%eax
f0104d96:	75 15                	jne    f0104dad <strtol+0x5a>
f0104d98:	80 3a 30             	cmpb   $0x30,(%edx)
f0104d9b:	75 10                	jne    f0104dad <strtol+0x5a>
f0104d9d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104da1:	75 0a                	jne    f0104dad <strtol+0x5a>
		s += 2, base = 16;
f0104da3:	83 c2 02             	add    $0x2,%edx
f0104da6:	b8 10 00 00 00       	mov    $0x10,%eax
f0104dab:	eb 10                	jmp    f0104dbd <strtol+0x6a>
	else if (base == 0 && s[0] == '0')
f0104dad:	85 c0                	test   %eax,%eax
f0104daf:	75 0c                	jne    f0104dbd <strtol+0x6a>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0104db1:	b0 0a                	mov    $0xa,%al
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104db3:	80 3a 30             	cmpb   $0x30,(%edx)
f0104db6:	75 05                	jne    f0104dbd <strtol+0x6a>
		s++, base = 8;
f0104db8:	83 c2 01             	add    $0x1,%edx
f0104dbb:	b0 08                	mov    $0x8,%al
	else if (base == 0)
		base = 10;
f0104dbd:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104dc2:	89 45 10             	mov    %eax,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104dc5:	0f b6 0a             	movzbl (%edx),%ecx
f0104dc8:	8d 71 d0             	lea    -0x30(%ecx),%esi
f0104dcb:	89 f0                	mov    %esi,%eax
f0104dcd:	3c 09                	cmp    $0x9,%al
f0104dcf:	77 08                	ja     f0104dd9 <strtol+0x86>
			dig = *s - '0';
f0104dd1:	0f be c9             	movsbl %cl,%ecx
f0104dd4:	83 e9 30             	sub    $0x30,%ecx
f0104dd7:	eb 20                	jmp    f0104df9 <strtol+0xa6>
		else if (*s >= 'a' && *s <= 'z')
f0104dd9:	8d 71 9f             	lea    -0x61(%ecx),%esi
f0104ddc:	89 f0                	mov    %esi,%eax
f0104dde:	3c 19                	cmp    $0x19,%al
f0104de0:	77 08                	ja     f0104dea <strtol+0x97>
			dig = *s - 'a' + 10;
f0104de2:	0f be c9             	movsbl %cl,%ecx
f0104de5:	83 e9 57             	sub    $0x57,%ecx
f0104de8:	eb 0f                	jmp    f0104df9 <strtol+0xa6>
		else if (*s >= 'A' && *s <= 'Z')
f0104dea:	8d 71 bf             	lea    -0x41(%ecx),%esi
f0104ded:	89 f0                	mov    %esi,%eax
f0104def:	3c 19                	cmp    $0x19,%al
f0104df1:	77 16                	ja     f0104e09 <strtol+0xb6>
			dig = *s - 'A' + 10;
f0104df3:	0f be c9             	movsbl %cl,%ecx
f0104df6:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104df9:	3b 4d 10             	cmp    0x10(%ebp),%ecx
f0104dfc:	7d 0f                	jge    f0104e0d <strtol+0xba>
			break;
		s++, val = (val * base) + dig;
f0104dfe:	83 c2 01             	add    $0x1,%edx
f0104e01:	0f af 5d 10          	imul   0x10(%ebp),%ebx
f0104e05:	01 cb                	add    %ecx,%ebx
		// we don't properly detect overflow!
	}
f0104e07:	eb bc                	jmp    f0104dc5 <strtol+0x72>
f0104e09:	89 d8                	mov    %ebx,%eax
f0104e0b:	eb 02                	jmp    f0104e0f <strtol+0xbc>
f0104e0d:	89 d8                	mov    %ebx,%eax

	if (endptr)
f0104e0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104e13:	74 05                	je     f0104e1a <strtol+0xc7>
		*endptr = (char *) s;
f0104e15:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104e18:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0104e1a:	f7 d8                	neg    %eax
f0104e1c:	85 ff                	test   %edi,%edi
f0104e1e:	0f 44 c3             	cmove  %ebx,%eax
}
f0104e21:	5b                   	pop    %ebx
f0104e22:	5e                   	pop    %esi
f0104e23:	5f                   	pop    %edi
f0104e24:	5d                   	pop    %ebp
f0104e25:	c3                   	ret    
f0104e26:	66 90                	xchg   %ax,%ax
f0104e28:	66 90                	xchg   %ax,%ax
f0104e2a:	66 90                	xchg   %ax,%ax
f0104e2c:	66 90                	xchg   %ax,%ax
f0104e2e:	66 90                	xchg   %ax,%ax

f0104e30 <__udivdi3>:
f0104e30:	55                   	push   %ebp
f0104e31:	57                   	push   %edi
f0104e32:	56                   	push   %esi
f0104e33:	83 ec 0c             	sub    $0xc,%esp
f0104e36:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104e3a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
f0104e3e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
f0104e42:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104e46:	85 c0                	test   %eax,%eax
f0104e48:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104e4c:	89 ea                	mov    %ebp,%edx
f0104e4e:	89 0c 24             	mov    %ecx,(%esp)
f0104e51:	75 2d                	jne    f0104e80 <__udivdi3+0x50>
f0104e53:	39 e9                	cmp    %ebp,%ecx
f0104e55:	77 61                	ja     f0104eb8 <__udivdi3+0x88>
f0104e57:	85 c9                	test   %ecx,%ecx
f0104e59:	89 ce                	mov    %ecx,%esi
f0104e5b:	75 0b                	jne    f0104e68 <__udivdi3+0x38>
f0104e5d:	b8 01 00 00 00       	mov    $0x1,%eax
f0104e62:	31 d2                	xor    %edx,%edx
f0104e64:	f7 f1                	div    %ecx
f0104e66:	89 c6                	mov    %eax,%esi
f0104e68:	31 d2                	xor    %edx,%edx
f0104e6a:	89 e8                	mov    %ebp,%eax
f0104e6c:	f7 f6                	div    %esi
f0104e6e:	89 c5                	mov    %eax,%ebp
f0104e70:	89 f8                	mov    %edi,%eax
f0104e72:	f7 f6                	div    %esi
f0104e74:	89 ea                	mov    %ebp,%edx
f0104e76:	83 c4 0c             	add    $0xc,%esp
f0104e79:	5e                   	pop    %esi
f0104e7a:	5f                   	pop    %edi
f0104e7b:	5d                   	pop    %ebp
f0104e7c:	c3                   	ret    
f0104e7d:	8d 76 00             	lea    0x0(%esi),%esi
f0104e80:	39 e8                	cmp    %ebp,%eax
f0104e82:	77 24                	ja     f0104ea8 <__udivdi3+0x78>
f0104e84:	0f bd e8             	bsr    %eax,%ebp
f0104e87:	83 f5 1f             	xor    $0x1f,%ebp
f0104e8a:	75 3c                	jne    f0104ec8 <__udivdi3+0x98>
f0104e8c:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104e90:	39 34 24             	cmp    %esi,(%esp)
f0104e93:	0f 86 9f 00 00 00    	jbe    f0104f38 <__udivdi3+0x108>
f0104e99:	39 d0                	cmp    %edx,%eax
f0104e9b:	0f 82 97 00 00 00    	jb     f0104f38 <__udivdi3+0x108>
f0104ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104ea8:	31 d2                	xor    %edx,%edx
f0104eaa:	31 c0                	xor    %eax,%eax
f0104eac:	83 c4 0c             	add    $0xc,%esp
f0104eaf:	5e                   	pop    %esi
f0104eb0:	5f                   	pop    %edi
f0104eb1:	5d                   	pop    %ebp
f0104eb2:	c3                   	ret    
f0104eb3:	90                   	nop
f0104eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104eb8:	89 f8                	mov    %edi,%eax
f0104eba:	f7 f1                	div    %ecx
f0104ebc:	31 d2                	xor    %edx,%edx
f0104ebe:	83 c4 0c             	add    $0xc,%esp
f0104ec1:	5e                   	pop    %esi
f0104ec2:	5f                   	pop    %edi
f0104ec3:	5d                   	pop    %ebp
f0104ec4:	c3                   	ret    
f0104ec5:	8d 76 00             	lea    0x0(%esi),%esi
f0104ec8:	89 e9                	mov    %ebp,%ecx
f0104eca:	8b 3c 24             	mov    (%esp),%edi
f0104ecd:	d3 e0                	shl    %cl,%eax
f0104ecf:	89 c6                	mov    %eax,%esi
f0104ed1:	b8 20 00 00 00       	mov    $0x20,%eax
f0104ed6:	29 e8                	sub    %ebp,%eax
f0104ed8:	89 c1                	mov    %eax,%ecx
f0104eda:	d3 ef                	shr    %cl,%edi
f0104edc:	89 e9                	mov    %ebp,%ecx
f0104ede:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0104ee2:	8b 3c 24             	mov    (%esp),%edi
f0104ee5:	09 74 24 08          	or     %esi,0x8(%esp)
f0104ee9:	89 d6                	mov    %edx,%esi
f0104eeb:	d3 e7                	shl    %cl,%edi
f0104eed:	89 c1                	mov    %eax,%ecx
f0104eef:	89 3c 24             	mov    %edi,(%esp)
f0104ef2:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104ef6:	d3 ee                	shr    %cl,%esi
f0104ef8:	89 e9                	mov    %ebp,%ecx
f0104efa:	d3 e2                	shl    %cl,%edx
f0104efc:	89 c1                	mov    %eax,%ecx
f0104efe:	d3 ef                	shr    %cl,%edi
f0104f00:	09 d7                	or     %edx,%edi
f0104f02:	89 f2                	mov    %esi,%edx
f0104f04:	89 f8                	mov    %edi,%eax
f0104f06:	f7 74 24 08          	divl   0x8(%esp)
f0104f0a:	89 d6                	mov    %edx,%esi
f0104f0c:	89 c7                	mov    %eax,%edi
f0104f0e:	f7 24 24             	mull   (%esp)
f0104f11:	39 d6                	cmp    %edx,%esi
f0104f13:	89 14 24             	mov    %edx,(%esp)
f0104f16:	72 30                	jb     f0104f48 <__udivdi3+0x118>
f0104f18:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104f1c:	89 e9                	mov    %ebp,%ecx
f0104f1e:	d3 e2                	shl    %cl,%edx
f0104f20:	39 c2                	cmp    %eax,%edx
f0104f22:	73 05                	jae    f0104f29 <__udivdi3+0xf9>
f0104f24:	3b 34 24             	cmp    (%esp),%esi
f0104f27:	74 1f                	je     f0104f48 <__udivdi3+0x118>
f0104f29:	89 f8                	mov    %edi,%eax
f0104f2b:	31 d2                	xor    %edx,%edx
f0104f2d:	e9 7a ff ff ff       	jmp    f0104eac <__udivdi3+0x7c>
f0104f32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104f38:	31 d2                	xor    %edx,%edx
f0104f3a:	b8 01 00 00 00       	mov    $0x1,%eax
f0104f3f:	e9 68 ff ff ff       	jmp    f0104eac <__udivdi3+0x7c>
f0104f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104f48:	8d 47 ff             	lea    -0x1(%edi),%eax
f0104f4b:	31 d2                	xor    %edx,%edx
f0104f4d:	83 c4 0c             	add    $0xc,%esp
f0104f50:	5e                   	pop    %esi
f0104f51:	5f                   	pop    %edi
f0104f52:	5d                   	pop    %ebp
f0104f53:	c3                   	ret    
f0104f54:	66 90                	xchg   %ax,%ax
f0104f56:	66 90                	xchg   %ax,%ax
f0104f58:	66 90                	xchg   %ax,%ax
f0104f5a:	66 90                	xchg   %ax,%ax
f0104f5c:	66 90                	xchg   %ax,%ax
f0104f5e:	66 90                	xchg   %ax,%ax

f0104f60 <__umoddi3>:
f0104f60:	55                   	push   %ebp
f0104f61:	57                   	push   %edi
f0104f62:	56                   	push   %esi
f0104f63:	83 ec 14             	sub    $0x14,%esp
f0104f66:	8b 44 24 28          	mov    0x28(%esp),%eax
f0104f6a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0104f6e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
f0104f72:	89 c7                	mov    %eax,%edi
f0104f74:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f78:	8b 44 24 30          	mov    0x30(%esp),%eax
f0104f7c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0104f80:	89 34 24             	mov    %esi,(%esp)
f0104f83:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104f87:	85 c0                	test   %eax,%eax
f0104f89:	89 c2                	mov    %eax,%edx
f0104f8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104f8f:	75 17                	jne    f0104fa8 <__umoddi3+0x48>
f0104f91:	39 fe                	cmp    %edi,%esi
f0104f93:	76 4b                	jbe    f0104fe0 <__umoddi3+0x80>
f0104f95:	89 c8                	mov    %ecx,%eax
f0104f97:	89 fa                	mov    %edi,%edx
f0104f99:	f7 f6                	div    %esi
f0104f9b:	89 d0                	mov    %edx,%eax
f0104f9d:	31 d2                	xor    %edx,%edx
f0104f9f:	83 c4 14             	add    $0x14,%esp
f0104fa2:	5e                   	pop    %esi
f0104fa3:	5f                   	pop    %edi
f0104fa4:	5d                   	pop    %ebp
f0104fa5:	c3                   	ret    
f0104fa6:	66 90                	xchg   %ax,%ax
f0104fa8:	39 f8                	cmp    %edi,%eax
f0104faa:	77 54                	ja     f0105000 <__umoddi3+0xa0>
f0104fac:	0f bd e8             	bsr    %eax,%ebp
f0104faf:	83 f5 1f             	xor    $0x1f,%ebp
f0104fb2:	75 5c                	jne    f0105010 <__umoddi3+0xb0>
f0104fb4:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0104fb8:	39 3c 24             	cmp    %edi,(%esp)
f0104fbb:	0f 87 e7 00 00 00    	ja     f01050a8 <__umoddi3+0x148>
f0104fc1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104fc5:	29 f1                	sub    %esi,%ecx
f0104fc7:	19 c7                	sbb    %eax,%edi
f0104fc9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104fcd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104fd1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104fd5:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0104fd9:	83 c4 14             	add    $0x14,%esp
f0104fdc:	5e                   	pop    %esi
f0104fdd:	5f                   	pop    %edi
f0104fde:	5d                   	pop    %ebp
f0104fdf:	c3                   	ret    
f0104fe0:	85 f6                	test   %esi,%esi
f0104fe2:	89 f5                	mov    %esi,%ebp
f0104fe4:	75 0b                	jne    f0104ff1 <__umoddi3+0x91>
f0104fe6:	b8 01 00 00 00       	mov    $0x1,%eax
f0104feb:	31 d2                	xor    %edx,%edx
f0104fed:	f7 f6                	div    %esi
f0104fef:	89 c5                	mov    %eax,%ebp
f0104ff1:	8b 44 24 04          	mov    0x4(%esp),%eax
f0104ff5:	31 d2                	xor    %edx,%edx
f0104ff7:	f7 f5                	div    %ebp
f0104ff9:	89 c8                	mov    %ecx,%eax
f0104ffb:	f7 f5                	div    %ebp
f0104ffd:	eb 9c                	jmp    f0104f9b <__umoddi3+0x3b>
f0104fff:	90                   	nop
f0105000:	89 c8                	mov    %ecx,%eax
f0105002:	89 fa                	mov    %edi,%edx
f0105004:	83 c4 14             	add    $0x14,%esp
f0105007:	5e                   	pop    %esi
f0105008:	5f                   	pop    %edi
f0105009:	5d                   	pop    %ebp
f010500a:	c3                   	ret    
f010500b:	90                   	nop
f010500c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105010:	8b 04 24             	mov    (%esp),%eax
f0105013:	be 20 00 00 00       	mov    $0x20,%esi
f0105018:	89 e9                	mov    %ebp,%ecx
f010501a:	29 ee                	sub    %ebp,%esi
f010501c:	d3 e2                	shl    %cl,%edx
f010501e:	89 f1                	mov    %esi,%ecx
f0105020:	d3 e8                	shr    %cl,%eax
f0105022:	89 e9                	mov    %ebp,%ecx
f0105024:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105028:	8b 04 24             	mov    (%esp),%eax
f010502b:	09 54 24 04          	or     %edx,0x4(%esp)
f010502f:	89 fa                	mov    %edi,%edx
f0105031:	d3 e0                	shl    %cl,%eax
f0105033:	89 f1                	mov    %esi,%ecx
f0105035:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105039:	8b 44 24 10          	mov    0x10(%esp),%eax
f010503d:	d3 ea                	shr    %cl,%edx
f010503f:	89 e9                	mov    %ebp,%ecx
f0105041:	d3 e7                	shl    %cl,%edi
f0105043:	89 f1                	mov    %esi,%ecx
f0105045:	d3 e8                	shr    %cl,%eax
f0105047:	89 e9                	mov    %ebp,%ecx
f0105049:	09 f8                	or     %edi,%eax
f010504b:	8b 7c 24 10          	mov    0x10(%esp),%edi
f010504f:	f7 74 24 04          	divl   0x4(%esp)
f0105053:	d3 e7                	shl    %cl,%edi
f0105055:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105059:	89 d7                	mov    %edx,%edi
f010505b:	f7 64 24 08          	mull   0x8(%esp)
f010505f:	39 d7                	cmp    %edx,%edi
f0105061:	89 c1                	mov    %eax,%ecx
f0105063:	89 14 24             	mov    %edx,(%esp)
f0105066:	72 2c                	jb     f0105094 <__umoddi3+0x134>
f0105068:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010506c:	72 22                	jb     f0105090 <__umoddi3+0x130>
f010506e:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0105072:	29 c8                	sub    %ecx,%eax
f0105074:	19 d7                	sbb    %edx,%edi
f0105076:	89 e9                	mov    %ebp,%ecx
f0105078:	89 fa                	mov    %edi,%edx
f010507a:	d3 e8                	shr    %cl,%eax
f010507c:	89 f1                	mov    %esi,%ecx
f010507e:	d3 e2                	shl    %cl,%edx
f0105080:	89 e9                	mov    %ebp,%ecx
f0105082:	d3 ef                	shr    %cl,%edi
f0105084:	09 d0                	or     %edx,%eax
f0105086:	89 fa                	mov    %edi,%edx
f0105088:	83 c4 14             	add    $0x14,%esp
f010508b:	5e                   	pop    %esi
f010508c:	5f                   	pop    %edi
f010508d:	5d                   	pop    %ebp
f010508e:	c3                   	ret    
f010508f:	90                   	nop
f0105090:	39 d7                	cmp    %edx,%edi
f0105092:	75 da                	jne    f010506e <__umoddi3+0x10e>
f0105094:	8b 14 24             	mov    (%esp),%edx
f0105097:	89 c1                	mov    %eax,%ecx
f0105099:	2b 4c 24 08          	sub    0x8(%esp),%ecx
f010509d:	1b 54 24 04          	sbb    0x4(%esp),%edx
f01050a1:	eb cb                	jmp    f010506e <__umoddi3+0x10e>
f01050a3:	90                   	nop
f01050a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01050a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
f01050ac:	0f 82 0f ff ff ff    	jb     f0104fc1 <__umoddi3+0x61>
f01050b2:	e9 1a ff ff ff       	jmp    f0104fd1 <__umoddi3+0x71>
