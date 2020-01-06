
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
f0100015:	b8 00 f0 11 00       	mov    $0x11f000,%eax
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
f0100034:	bc 00 f0 11 f0       	mov    $0xf011f000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5e 00 00 00       	call   f010009c <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 4e 23 f0 00 	cmpl   $0x0,0xf0234e80
f010004f:	74 0f                	je     f0100060 <_panic+0x20>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100051:	83 ec 0c             	sub    $0xc,%esp
f0100054:	6a 00                	push   $0x0
f0100056:	e8 da 08 00 00       	call   f0100935 <monitor>
f010005b:	83 c4 10             	add    $0x10,%esp
f010005e:	eb f1                	jmp    f0100051 <_panic+0x11>
	panicstr = fmt;
f0100060:	89 35 80 4e 23 f0    	mov    %esi,0xf0234e80
	asm volatile("cli; cld");
f0100066:	fa                   	cli    
f0100067:	fc                   	cld    
	va_start(ap, fmt);
f0100068:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006b:	e8 e3 5b 00 00       	call   f0105c53 <cpunum>
f0100070:	ff 75 0c             	pushl  0xc(%ebp)
f0100073:	ff 75 08             	pushl  0x8(%ebp)
f0100076:	50                   	push   %eax
f0100077:	68 a0 62 10 f0       	push   $0xf01062a0
f010007c:	e8 5c 38 00 00       	call   f01038dd <cprintf>
	vcprintf(fmt, ap);
f0100081:	83 c4 08             	add    $0x8,%esp
f0100084:	53                   	push   %ebx
f0100085:	56                   	push   %esi
f0100086:	e8 2c 38 00 00       	call   f01038b7 <vcprintf>
	cprintf("\n");
f010008b:	c7 04 24 49 74 10 f0 	movl   $0xf0107449,(%esp)
f0100092:	e8 46 38 00 00       	call   f01038dd <cprintf>
f0100097:	83 c4 10             	add    $0x10,%esp
f010009a:	eb b5                	jmp    f0100051 <_panic+0x11>

f010009c <i386_init>:
{
f010009c:	55                   	push   %ebp
f010009d:	89 e5                	mov    %esp,%ebp
f010009f:	53                   	push   %ebx
f01000a0:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000a3:	e8 9a 05 00 00       	call   f0100642 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000a8:	83 ec 08             	sub    $0x8,%esp
f01000ab:	68 ac 1a 00 00       	push   $0x1aac
f01000b0:	68 0c 63 10 f0       	push   $0xf010630c
f01000b5:	e8 23 38 00 00       	call   f01038dd <cprintf>
	mem_init();
f01000ba:	e8 09 12 00 00       	call   f01012c8 <mem_init>
	env_init();
f01000bf:	e8 14 30 00 00       	call   f01030d8 <env_init>
	trap_init();
f01000c4:	e8 e7 38 00 00       	call   f01039b0 <trap_init>
	mp_init();
f01000c9:	e8 73 58 00 00       	call   f0105941 <mp_init>
	lapic_init();
f01000ce:	e8 9a 5b 00 00       	call   f0105c6d <lapic_init>
	pic_init();
f01000d3:	e8 28 37 00 00       	call   f0103800 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000d8:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f01000df:	e8 df 5d 00 00       	call   f0105ec3 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000e4:	83 c4 10             	add    $0x10,%esp
f01000e7:	83 3d 88 4e 23 f0 07 	cmpl   $0x7,0xf0234e88
f01000ee:	76 27                	jbe    f0100117 <i386_init+0x7b>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f0:	83 ec 04             	sub    $0x4,%esp
f01000f3:	b8 a6 58 10 f0       	mov    $0xf01058a6,%eax
f01000f8:	2d 2c 58 10 f0       	sub    $0xf010582c,%eax
f01000fd:	50                   	push   %eax
f01000fe:	68 2c 58 10 f0       	push   $0xf010582c
f0100103:	68 00 70 00 f0       	push   $0xf0007000
f0100108:	e8 70 55 00 00       	call   f010567d <memmove>
f010010d:	83 c4 10             	add    $0x10,%esp
	for (c = cpus; c < cpus + ncpu; c++) {
f0100110:	bb 20 50 23 f0       	mov    $0xf0235020,%ebx
f0100115:	eb 19                	jmp    f0100130 <i386_init+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100117:	68 00 70 00 00       	push   $0x7000
f010011c:	68 c4 62 10 f0       	push   $0xf01062c4
f0100121:	6a 4f                	push   $0x4f
f0100123:	68 27 63 10 f0       	push   $0xf0106327
f0100128:	e8 13 ff ff ff       	call   f0100040 <_panic>
f010012d:	83 c3 74             	add    $0x74,%ebx
f0100130:	6b 05 c4 53 23 f0 74 	imul   $0x74,0xf02353c4,%eax
f0100137:	05 20 50 23 f0       	add    $0xf0235020,%eax
f010013c:	39 c3                	cmp    %eax,%ebx
f010013e:	73 4c                	jae    f010018c <i386_init+0xf0>
		if (c == cpus + cpunum())  // We've started already.
f0100140:	e8 0e 5b 00 00       	call   f0105c53 <cpunum>
f0100145:	6b c0 74             	imul   $0x74,%eax,%eax
f0100148:	05 20 50 23 f0       	add    $0xf0235020,%eax
f010014d:	39 c3                	cmp    %eax,%ebx
f010014f:	74 dc                	je     f010012d <i386_init+0x91>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100151:	89 d8                	mov    %ebx,%eax
f0100153:	2d 20 50 23 f0       	sub    $0xf0235020,%eax
f0100158:	c1 f8 02             	sar    $0x2,%eax
f010015b:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100161:	c1 e0 0f             	shl    $0xf,%eax
f0100164:	05 00 e0 23 f0       	add    $0xf023e000,%eax
f0100169:	a3 84 4e 23 f0       	mov    %eax,0xf0234e84
		lapic_startap(c->cpu_id, PADDR(code));
f010016e:	83 ec 08             	sub    $0x8,%esp
f0100171:	68 00 70 00 00       	push   $0x7000
f0100176:	0f b6 03             	movzbl (%ebx),%eax
f0100179:	50                   	push   %eax
f010017a:	e8 3f 5c 00 00       	call   f0105dbe <lapic_startap>
f010017f:	83 c4 10             	add    $0x10,%esp
		while(c->cpu_status != CPU_STARTED)
f0100182:	8b 43 04             	mov    0x4(%ebx),%eax
f0100185:	83 f8 01             	cmp    $0x1,%eax
f0100188:	75 f8                	jne    f0100182 <i386_init+0xe6>
f010018a:	eb a1                	jmp    f010012d <i386_init+0x91>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010018c:	83 ec 08             	sub    $0x8,%esp
f010018f:	6a 00                	push   $0x0
f0100191:	68 fc 9b 22 f0       	push   $0xf0229bfc
f0100196:	e8 36 31 00 00       	call   f01032d1 <env_create>
	sched_yield();
f010019b:	e8 cf 42 00 00       	call   f010446f <sched_yield>

f01001a0 <mp_main>:
{
f01001a0:	55                   	push   %ebp
f01001a1:	89 e5                	mov    %esp,%ebp
f01001a3:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001a6:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001ab:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001b0:	77 12                	ja     f01001c4 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001b2:	50                   	push   %eax
f01001b3:	68 e8 62 10 f0       	push   $0xf01062e8
f01001b8:	6a 66                	push   $0x66
f01001ba:	68 27 63 10 f0       	push   $0xf0106327
f01001bf:	e8 7c fe ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01001c4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c9:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001cc:	e8 82 5a 00 00       	call   f0105c53 <cpunum>
f01001d1:	83 ec 08             	sub    $0x8,%esp
f01001d4:	50                   	push   %eax
f01001d5:	68 33 63 10 f0       	push   $0xf0106333
f01001da:	e8 fe 36 00 00       	call   f01038dd <cprintf>
	lapic_init();
f01001df:	e8 89 5a 00 00       	call   f0105c6d <lapic_init>
	env_init_percpu();
f01001e4:	e8 bf 2e 00 00       	call   f01030a8 <env_init_percpu>
	trap_init_percpu();
f01001e9:	e8 03 37 00 00       	call   f01038f1 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001ee:	e8 60 5a 00 00       	call   f0105c53 <cpunum>
f01001f3:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f6:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f9:	b8 01 00 00 00       	mov    $0x1,%eax
f01001fe:	f0 87 82 20 50 23 f0 	lock xchg %eax,-0xfdcafe0(%edx)
f0100205:	c7 04 24 c0 13 12 f0 	movl   $0xf01213c0,(%esp)
f010020c:	e8 b2 5c 00 00       	call   f0105ec3 <spin_lock>
	sched_yield();
f0100211:	e8 59 42 00 00       	call   f010446f <sched_yield>

f0100216 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100216:	55                   	push   %ebp
f0100217:	89 e5                	mov    %esp,%ebp
f0100219:	53                   	push   %ebx
f010021a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010021d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100220:	ff 75 0c             	pushl  0xc(%ebp)
f0100223:	ff 75 08             	pushl  0x8(%ebp)
f0100226:	68 49 63 10 f0       	push   $0xf0106349
f010022b:	e8 ad 36 00 00       	call   f01038dd <cprintf>
	vcprintf(fmt, ap);
f0100230:	83 c4 08             	add    $0x8,%esp
f0100233:	53                   	push   %ebx
f0100234:	ff 75 10             	pushl  0x10(%ebp)
f0100237:	e8 7b 36 00 00       	call   f01038b7 <vcprintf>
	cprintf("\n");
f010023c:	c7 04 24 49 74 10 f0 	movl   $0xf0107449,(%esp)
f0100243:	e8 95 36 00 00       	call   f01038dd <cprintf>
	va_end(ap);
}
f0100248:	83 c4 10             	add    $0x10,%esp
f010024b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010024e:	c9                   	leave  
f010024f:	c3                   	ret    

f0100250 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100250:	55                   	push   %ebp
f0100251:	89 e5                	mov    %esp,%ebp
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100253:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100258:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100259:	a8 01                	test   $0x1,%al
f010025b:	74 0b                	je     f0100268 <serial_proc_data+0x18>
f010025d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100262:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100263:	0f b6 c0             	movzbl %al,%eax
}
f0100266:	5d                   	pop    %ebp
f0100267:	c3                   	ret    
		return -1;
f0100268:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010026d:	eb f7                	jmp    f0100266 <serial_proc_data+0x16>

f010026f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010026f:	55                   	push   %ebp
f0100270:	89 e5                	mov    %esp,%ebp
f0100272:	53                   	push   %ebx
f0100273:	83 ec 04             	sub    $0x4,%esp
f0100276:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100278:	ff d3                	call   *%ebx
f010027a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010027d:	74 2d                	je     f01002ac <cons_intr+0x3d>
		if (c == 0)
f010027f:	85 c0                	test   %eax,%eax
f0100281:	74 f5                	je     f0100278 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100283:	8b 0d 24 42 23 f0    	mov    0xf0234224,%ecx
f0100289:	8d 51 01             	lea    0x1(%ecx),%edx
f010028c:	89 15 24 42 23 f0    	mov    %edx,0xf0234224
f0100292:	88 81 20 40 23 f0    	mov    %al,-0xfdcbfe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100298:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010029e:	75 d8                	jne    f0100278 <cons_intr+0x9>
			cons.wpos = 0;
f01002a0:	c7 05 24 42 23 f0 00 	movl   $0x0,0xf0234224
f01002a7:	00 00 00 
f01002aa:	eb cc                	jmp    f0100278 <cons_intr+0x9>
	}
}
f01002ac:	83 c4 04             	add    $0x4,%esp
f01002af:	5b                   	pop    %ebx
f01002b0:	5d                   	pop    %ebp
f01002b1:	c3                   	ret    

f01002b2 <kbd_proc_data>:
{
f01002b2:	55                   	push   %ebp
f01002b3:	89 e5                	mov    %esp,%ebp
f01002b5:	53                   	push   %ebx
f01002b6:	83 ec 04             	sub    $0x4,%esp
f01002b9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002be:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002bf:	a8 01                	test   $0x1,%al
f01002c1:	0f 84 fa 00 00 00    	je     f01003c1 <kbd_proc_data+0x10f>
	if (stat & KBS_TERR)
f01002c7:	a8 20                	test   $0x20,%al
f01002c9:	0f 85 f9 00 00 00    	jne    f01003c8 <kbd_proc_data+0x116>
f01002cf:	ba 60 00 00 00       	mov    $0x60,%edx
f01002d4:	ec                   	in     (%dx),%al
f01002d5:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002d7:	3c e0                	cmp    $0xe0,%al
f01002d9:	0f 84 8e 00 00 00    	je     f010036d <kbd_proc_data+0xbb>
	} else if (data & 0x80) {
f01002df:	84 c0                	test   %al,%al
f01002e1:	0f 88 99 00 00 00    	js     f0100380 <kbd_proc_data+0xce>
	} else if (shift & E0ESC) {
f01002e7:	8b 0d 00 40 23 f0    	mov    0xf0234000,%ecx
f01002ed:	f6 c1 40             	test   $0x40,%cl
f01002f0:	74 0e                	je     f0100300 <kbd_proc_data+0x4e>
		data |= 0x80;
f01002f2:	83 c8 80             	or     $0xffffff80,%eax
f01002f5:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002f7:	83 e1 bf             	and    $0xffffffbf,%ecx
f01002fa:	89 0d 00 40 23 f0    	mov    %ecx,0xf0234000
	shift |= shiftcode[data];
f0100300:	0f b6 d2             	movzbl %dl,%edx
f0100303:	0f b6 82 c0 64 10 f0 	movzbl -0xfef9b40(%edx),%eax
f010030a:	0b 05 00 40 23 f0    	or     0xf0234000,%eax
	shift ^= togglecode[data];
f0100310:	0f b6 8a c0 63 10 f0 	movzbl -0xfef9c40(%edx),%ecx
f0100317:	31 c8                	xor    %ecx,%eax
f0100319:	a3 00 40 23 f0       	mov    %eax,0xf0234000
	c = charcode[shift & (CTL | SHIFT)][data];
f010031e:	89 c1                	mov    %eax,%ecx
f0100320:	83 e1 03             	and    $0x3,%ecx
f0100323:	8b 0c 8d a0 63 10 f0 	mov    -0xfef9c60(,%ecx,4),%ecx
f010032a:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010032e:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100331:	a8 08                	test   $0x8,%al
f0100333:	74 0d                	je     f0100342 <kbd_proc_data+0x90>
		if ('a' <= c && c <= 'z')
f0100335:	89 da                	mov    %ebx,%edx
f0100337:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010033a:	83 f9 19             	cmp    $0x19,%ecx
f010033d:	77 74                	ja     f01003b3 <kbd_proc_data+0x101>
			c += 'A' - 'a';
f010033f:	83 eb 20             	sub    $0x20,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100342:	f7 d0                	not    %eax
f0100344:	a8 06                	test   $0x6,%al
f0100346:	75 31                	jne    f0100379 <kbd_proc_data+0xc7>
f0100348:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010034e:	75 29                	jne    f0100379 <kbd_proc_data+0xc7>
		cprintf("Rebooting!\n");
f0100350:	83 ec 0c             	sub    $0xc,%esp
f0100353:	68 63 63 10 f0       	push   $0xf0106363
f0100358:	e8 80 35 00 00       	call   f01038dd <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010035d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100362:	ba 92 00 00 00       	mov    $0x92,%edx
f0100367:	ee                   	out    %al,(%dx)
f0100368:	83 c4 10             	add    $0x10,%esp
f010036b:	eb 0c                	jmp    f0100379 <kbd_proc_data+0xc7>
		shift |= E0ESC;
f010036d:	83 0d 00 40 23 f0 40 	orl    $0x40,0xf0234000
		return 0;
f0100374:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100379:	89 d8                	mov    %ebx,%eax
f010037b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010037e:	c9                   	leave  
f010037f:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f0100380:	8b 0d 00 40 23 f0    	mov    0xf0234000,%ecx
f0100386:	89 cb                	mov    %ecx,%ebx
f0100388:	83 e3 40             	and    $0x40,%ebx
f010038b:	83 e0 7f             	and    $0x7f,%eax
f010038e:	85 db                	test   %ebx,%ebx
f0100390:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100393:	0f b6 d2             	movzbl %dl,%edx
f0100396:	0f b6 82 c0 64 10 f0 	movzbl -0xfef9b40(%edx),%eax
f010039d:	83 c8 40             	or     $0x40,%eax
f01003a0:	0f b6 c0             	movzbl %al,%eax
f01003a3:	f7 d0                	not    %eax
f01003a5:	21 c8                	and    %ecx,%eax
f01003a7:	a3 00 40 23 f0       	mov    %eax,0xf0234000
		return 0;
f01003ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b1:	eb c6                	jmp    f0100379 <kbd_proc_data+0xc7>
		else if ('A' <= c && c <= 'Z')
f01003b3:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003b6:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003b9:	83 fa 1a             	cmp    $0x1a,%edx
f01003bc:	0f 42 d9             	cmovb  %ecx,%ebx
f01003bf:	eb 81                	jmp    f0100342 <kbd_proc_data+0x90>
		return -1;
f01003c1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003c6:	eb b1                	jmp    f0100379 <kbd_proc_data+0xc7>
		return -1;
f01003c8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003cd:	eb aa                	jmp    f0100379 <kbd_proc_data+0xc7>

f01003cf <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003cf:	55                   	push   %ebp
f01003d0:	89 e5                	mov    %esp,%ebp
f01003d2:	57                   	push   %edi
f01003d3:	56                   	push   %esi
f01003d4:	53                   	push   %ebx
f01003d5:	83 ec 1c             	sub    $0x1c,%esp
f01003d8:	89 c7                	mov    %eax,%edi
	for (i = 0;
f01003da:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003df:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003e4:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003e9:	eb 09                	jmp    f01003f4 <cons_putc+0x25>
f01003eb:	89 ca                	mov    %ecx,%edx
f01003ed:	ec                   	in     (%dx),%al
f01003ee:	ec                   	in     (%dx),%al
f01003ef:	ec                   	in     (%dx),%al
f01003f0:	ec                   	in     (%dx),%al
	     i++)
f01003f1:	83 c3 01             	add    $0x1,%ebx
f01003f4:	89 f2                	mov    %esi,%edx
f01003f6:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f7:	a8 20                	test   $0x20,%al
f01003f9:	75 08                	jne    f0100403 <cons_putc+0x34>
f01003fb:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100401:	7e e8                	jle    f01003eb <cons_putc+0x1c>
	outb(COM1 + COM_TX, c);
f0100403:	89 f8                	mov    %edi,%eax
f0100405:	88 45 e7             	mov    %al,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100408:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040d:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010040e:	bb 00 00 00 00       	mov    $0x0,%ebx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100413:	be 79 03 00 00       	mov    $0x379,%esi
f0100418:	b9 84 00 00 00       	mov    $0x84,%ecx
f010041d:	eb 09                	jmp    f0100428 <cons_putc+0x59>
f010041f:	89 ca                	mov    %ecx,%edx
f0100421:	ec                   	in     (%dx),%al
f0100422:	ec                   	in     (%dx),%al
f0100423:	ec                   	in     (%dx),%al
f0100424:	ec                   	in     (%dx),%al
f0100425:	83 c3 01             	add    $0x1,%ebx
f0100428:	89 f2                	mov    %esi,%edx
f010042a:	ec                   	in     (%dx),%al
f010042b:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100431:	7f 04                	jg     f0100437 <cons_putc+0x68>
f0100433:	84 c0                	test   %al,%al
f0100435:	79 e8                	jns    f010041f <cons_putc+0x50>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100437:	ba 78 03 00 00       	mov    $0x378,%edx
f010043c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100440:	ee                   	out    %al,(%dx)
f0100441:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100446:	b8 0d 00 00 00       	mov    $0xd,%eax
f010044b:	ee                   	out    %al,(%dx)
f010044c:	b8 08 00 00 00       	mov    $0x8,%eax
f0100451:	ee                   	out    %al,(%dx)
	if (!(c & ~0xFF))
f0100452:	89 fa                	mov    %edi,%edx
f0100454:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010045a:	89 f8                	mov    %edi,%eax
f010045c:	80 cc 07             	or     $0x7,%ah
f010045f:	85 d2                	test   %edx,%edx
f0100461:	0f 44 f8             	cmove  %eax,%edi
	switch (c & 0xff) {
f0100464:	89 f8                	mov    %edi,%eax
f0100466:	0f b6 c0             	movzbl %al,%eax
f0100469:	83 f8 09             	cmp    $0x9,%eax
f010046c:	0f 84 b6 00 00 00    	je     f0100528 <cons_putc+0x159>
f0100472:	83 f8 09             	cmp    $0x9,%eax
f0100475:	7e 73                	jle    f01004ea <cons_putc+0x11b>
f0100477:	83 f8 0a             	cmp    $0xa,%eax
f010047a:	0f 84 9b 00 00 00    	je     f010051b <cons_putc+0x14c>
f0100480:	83 f8 0d             	cmp    $0xd,%eax
f0100483:	0f 85 d6 00 00 00    	jne    f010055f <cons_putc+0x190>
		crt_pos -= (crt_pos % CRT_COLS);
f0100489:	0f b7 05 28 42 23 f0 	movzwl 0xf0234228,%eax
f0100490:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100496:	c1 e8 16             	shr    $0x16,%eax
f0100499:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010049c:	c1 e0 04             	shl    $0x4,%eax
f010049f:	66 a3 28 42 23 f0    	mov    %ax,0xf0234228
	if (crt_pos >= CRT_SIZE) {
f01004a5:	66 81 3d 28 42 23 f0 	cmpw   $0x7cf,0xf0234228
f01004ac:	cf 07 
f01004ae:	0f 87 ce 00 00 00    	ja     f0100582 <cons_putc+0x1b3>
	outb(addr_6845, 14);
f01004b4:	8b 0d 30 42 23 f0    	mov    0xf0234230,%ecx
f01004ba:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004bf:	89 ca                	mov    %ecx,%edx
f01004c1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004c2:	0f b7 1d 28 42 23 f0 	movzwl 0xf0234228,%ebx
f01004c9:	8d 71 01             	lea    0x1(%ecx),%esi
f01004cc:	89 d8                	mov    %ebx,%eax
f01004ce:	66 c1 e8 08          	shr    $0x8,%ax
f01004d2:	89 f2                	mov    %esi,%edx
f01004d4:	ee                   	out    %al,(%dx)
f01004d5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004da:	89 ca                	mov    %ecx,%edx
f01004dc:	ee                   	out    %al,(%dx)
f01004dd:	89 d8                	mov    %ebx,%eax
f01004df:	89 f2                	mov    %esi,%edx
f01004e1:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004e5:	5b                   	pop    %ebx
f01004e6:	5e                   	pop    %esi
f01004e7:	5f                   	pop    %edi
f01004e8:	5d                   	pop    %ebp
f01004e9:	c3                   	ret    
	switch (c & 0xff) {
f01004ea:	83 f8 08             	cmp    $0x8,%eax
f01004ed:	75 70                	jne    f010055f <cons_putc+0x190>
		if (crt_pos > 0) {
f01004ef:	0f b7 05 28 42 23 f0 	movzwl 0xf0234228,%eax
f01004f6:	66 85 c0             	test   %ax,%ax
f01004f9:	74 b9                	je     f01004b4 <cons_putc+0xe5>
			crt_pos--;
f01004fb:	83 e8 01             	sub    $0x1,%eax
f01004fe:	66 a3 28 42 23 f0    	mov    %ax,0xf0234228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100504:	0f b7 c0             	movzwl %ax,%eax
f0100507:	66 81 e7 00 ff       	and    $0xff00,%di
f010050c:	83 cf 20             	or     $0x20,%edi
f010050f:	8b 15 2c 42 23 f0    	mov    0xf023422c,%edx
f0100515:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100519:	eb 8a                	jmp    f01004a5 <cons_putc+0xd6>
		crt_pos += CRT_COLS;
f010051b:	66 83 05 28 42 23 f0 	addw   $0x50,0xf0234228
f0100522:	50 
f0100523:	e9 61 ff ff ff       	jmp    f0100489 <cons_putc+0xba>
		cons_putc(' ');
f0100528:	b8 20 00 00 00       	mov    $0x20,%eax
f010052d:	e8 9d fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f0100532:	b8 20 00 00 00       	mov    $0x20,%eax
f0100537:	e8 93 fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f010053c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100541:	e8 89 fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f0100546:	b8 20 00 00 00       	mov    $0x20,%eax
f010054b:	e8 7f fe ff ff       	call   f01003cf <cons_putc>
		cons_putc(' ');
f0100550:	b8 20 00 00 00       	mov    $0x20,%eax
f0100555:	e8 75 fe ff ff       	call   f01003cf <cons_putc>
f010055a:	e9 46 ff ff ff       	jmp    f01004a5 <cons_putc+0xd6>
		crt_buf[crt_pos++] = c;		/* write the character */
f010055f:	0f b7 05 28 42 23 f0 	movzwl 0xf0234228,%eax
f0100566:	8d 50 01             	lea    0x1(%eax),%edx
f0100569:	66 89 15 28 42 23 f0 	mov    %dx,0xf0234228
f0100570:	0f b7 c0             	movzwl %ax,%eax
f0100573:	8b 15 2c 42 23 f0    	mov    0xf023422c,%edx
f0100579:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010057d:	e9 23 ff ff ff       	jmp    f01004a5 <cons_putc+0xd6>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100582:	a1 2c 42 23 f0       	mov    0xf023422c,%eax
f0100587:	83 ec 04             	sub    $0x4,%esp
f010058a:	68 00 0f 00 00       	push   $0xf00
f010058f:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100595:	52                   	push   %edx
f0100596:	50                   	push   %eax
f0100597:	e8 e1 50 00 00       	call   f010567d <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059c:	8b 15 2c 42 23 f0    	mov    0xf023422c,%edx
f01005a2:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005a8:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005ae:	83 c4 10             	add    $0x10,%esp
f01005b1:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005b6:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b9:	39 d0                	cmp    %edx,%eax
f01005bb:	75 f4                	jne    f01005b1 <cons_putc+0x1e2>
		crt_pos -= CRT_COLS;
f01005bd:	66 83 2d 28 42 23 f0 	subw   $0x50,0xf0234228
f01005c4:	50 
f01005c5:	e9 ea fe ff ff       	jmp    f01004b4 <cons_putc+0xe5>

f01005ca <serial_intr>:
	if (serial_exists)
f01005ca:	80 3d 34 42 23 f0 00 	cmpb   $0x0,0xf0234234
f01005d1:	75 02                	jne    f01005d5 <serial_intr+0xb>
f01005d3:	f3 c3                	repz ret 
{
f01005d5:	55                   	push   %ebp
f01005d6:	89 e5                	mov    %esp,%ebp
f01005d8:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005db:	b8 50 02 10 f0       	mov    $0xf0100250,%eax
f01005e0:	e8 8a fc ff ff       	call   f010026f <cons_intr>
}
f01005e5:	c9                   	leave  
f01005e6:	c3                   	ret    

f01005e7 <kbd_intr>:
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005ed:	b8 b2 02 10 f0       	mov    $0xf01002b2,%eax
f01005f2:	e8 78 fc ff ff       	call   f010026f <cons_intr>
}
f01005f7:	c9                   	leave  
f01005f8:	c3                   	ret    

f01005f9 <cons_getc>:
{
f01005f9:	55                   	push   %ebp
f01005fa:	89 e5                	mov    %esp,%ebp
f01005fc:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f01005ff:	e8 c6 ff ff ff       	call   f01005ca <serial_intr>
	kbd_intr();
f0100604:	e8 de ff ff ff       	call   f01005e7 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100609:	8b 15 20 42 23 f0    	mov    0xf0234220,%edx
	return 0;
f010060f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (cons.rpos != cons.wpos) {
f0100614:	3b 15 24 42 23 f0    	cmp    0xf0234224,%edx
f010061a:	74 18                	je     f0100634 <cons_getc+0x3b>
		c = cons.buf[cons.rpos++];
f010061c:	8d 4a 01             	lea    0x1(%edx),%ecx
f010061f:	89 0d 20 42 23 f0    	mov    %ecx,0xf0234220
f0100625:	0f b6 82 20 40 23 f0 	movzbl -0xfdcbfe0(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
f010062c:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100632:	74 02                	je     f0100636 <cons_getc+0x3d>
}
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    
			cons.rpos = 0;
f0100636:	c7 05 20 42 23 f0 00 	movl   $0x0,0xf0234220
f010063d:	00 00 00 
f0100640:	eb f2                	jmp    f0100634 <cons_getc+0x3b>

f0100642 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100642:	55                   	push   %ebp
f0100643:	89 e5                	mov    %esp,%ebp
f0100645:	57                   	push   %edi
f0100646:	56                   	push   %esi
f0100647:	53                   	push   %ebx
f0100648:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f010064b:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100652:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100659:	5a a5 
	if (*cp != 0xA55A) {
f010065b:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100662:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100666:	0f 84 d4 00 00 00    	je     f0100740 <cons_init+0xfe>
		addr_6845 = MONO_BASE;
f010066c:	c7 05 30 42 23 f0 b4 	movl   $0x3b4,0xf0234230
f0100673:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100676:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f010067b:	8b 3d 30 42 23 f0    	mov    0xf0234230,%edi
f0100681:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100686:	89 fa                	mov    %edi,%edx
f0100688:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100689:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010068c:	89 ca                	mov    %ecx,%edx
f010068e:	ec                   	in     (%dx),%al
f010068f:	0f b6 c0             	movzbl %al,%eax
f0100692:	c1 e0 08             	shl    $0x8,%eax
f0100695:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100697:	b8 0f 00 00 00       	mov    $0xf,%eax
f010069c:	89 fa                	mov    %edi,%edx
f010069e:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069f:	89 ca                	mov    %ecx,%edx
f01006a1:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006a2:	89 35 2c 42 23 f0    	mov    %esi,0xf023422c
	pos |= inb(addr_6845 + 1);
f01006a8:	0f b6 c0             	movzbl %al,%eax
f01006ab:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006ad:	66 a3 28 42 23 f0    	mov    %ax,0xf0234228
	kbd_intr();
f01006b3:	e8 2f ff ff ff       	call   f01005e7 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006b8:	83 ec 0c             	sub    $0xc,%esp
f01006bb:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f01006c2:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006c7:	50                   	push   %eax
f01006c8:	e8 b5 30 00 00       	call   f0103782 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006cd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006d2:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006d7:	89 d8                	mov    %ebx,%eax
f01006d9:	89 ca                	mov    %ecx,%edx
f01006db:	ee                   	out    %al,(%dx)
f01006dc:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006e1:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006e6:	89 fa                	mov    %edi,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006ee:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006f3:	ee                   	out    %al,(%dx)
f01006f4:	be f9 03 00 00       	mov    $0x3f9,%esi
f01006f9:	89 d8                	mov    %ebx,%eax
f01006fb:	89 f2                	mov    %esi,%edx
f01006fd:	ee                   	out    %al,(%dx)
f01006fe:	b8 03 00 00 00       	mov    $0x3,%eax
f0100703:	89 fa                	mov    %edi,%edx
f0100705:	ee                   	out    %al,(%dx)
f0100706:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010070b:	89 d8                	mov    %ebx,%eax
f010070d:	ee                   	out    %al,(%dx)
f010070e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100713:	89 f2                	mov    %esi,%edx
f0100715:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100716:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010071b:	ec                   	in     (%dx),%al
f010071c:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010071e:	83 c4 10             	add    $0x10,%esp
f0100721:	3c ff                	cmp    $0xff,%al
f0100723:	0f 95 05 34 42 23 f0 	setne  0xf0234234
f010072a:	89 ca                	mov    %ecx,%edx
f010072c:	ec                   	in     (%dx),%al
f010072d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100732:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100733:	80 fb ff             	cmp    $0xff,%bl
f0100736:	74 23                	je     f010075b <cons_init+0x119>
		cprintf("Serial port does not exist!\n");
}
f0100738:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010073b:	5b                   	pop    %ebx
f010073c:	5e                   	pop    %esi
f010073d:	5f                   	pop    %edi
f010073e:	5d                   	pop    %ebp
f010073f:	c3                   	ret    
		*cp = was;
f0100740:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100747:	c7 05 30 42 23 f0 d4 	movl   $0x3d4,0xf0234230
f010074e:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100751:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f0100756:	e9 20 ff ff ff       	jmp    f010067b <cons_init+0x39>
		cprintf("Serial port does not exist!\n");
f010075b:	83 ec 0c             	sub    $0xc,%esp
f010075e:	68 6f 63 10 f0       	push   $0xf010636f
f0100763:	e8 75 31 00 00       	call   f01038dd <cprintf>
f0100768:	83 c4 10             	add    $0x10,%esp
}
f010076b:	eb cb                	jmp    f0100738 <cons_init+0xf6>

f010076d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010076d:	55                   	push   %ebp
f010076e:	89 e5                	mov    %esp,%ebp
f0100770:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100773:	8b 45 08             	mov    0x8(%ebp),%eax
f0100776:	e8 54 fc ff ff       	call   f01003cf <cons_putc>
}
f010077b:	c9                   	leave  
f010077c:	c3                   	ret    

f010077d <getchar>:

int
getchar(void)
{
f010077d:	55                   	push   %ebp
f010077e:	89 e5                	mov    %esp,%ebp
f0100780:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100783:	e8 71 fe ff ff       	call   f01005f9 <cons_getc>
f0100788:	85 c0                	test   %eax,%eax
f010078a:	74 f7                	je     f0100783 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010078c:	c9                   	leave  
f010078d:	c3                   	ret    

f010078e <iscons>:

int
iscons(int fdnum)
{
f010078e:	55                   	push   %ebp
f010078f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100791:	b8 01 00 00 00       	mov    $0x1,%eax
f0100796:	5d                   	pop    %ebp
f0100797:	c3                   	ret    

f0100798 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100798:	55                   	push   %ebp
f0100799:	89 e5                	mov    %esp,%ebp
f010079b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010079e:	68 c0 65 10 f0       	push   $0xf01065c0
f01007a3:	68 de 65 10 f0       	push   $0xf01065de
f01007a8:	68 e3 65 10 f0       	push   $0xf01065e3
f01007ad:	e8 2b 31 00 00       	call   f01038dd <cprintf>
f01007b2:	83 c4 0c             	add    $0xc,%esp
f01007b5:	68 8c 66 10 f0       	push   $0xf010668c
f01007ba:	68 ec 65 10 f0       	push   $0xf01065ec
f01007bf:	68 e3 65 10 f0       	push   $0xf01065e3
f01007c4:	e8 14 31 00 00       	call   f01038dd <cprintf>
	return 0;
}
f01007c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01007ce:	c9                   	leave  
f01007cf:	c3                   	ret    

f01007d0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007d0:	55                   	push   %ebp
f01007d1:	89 e5                	mov    %esp,%ebp
f01007d3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007d6:	68 f5 65 10 f0       	push   $0xf01065f5
f01007db:	e8 fd 30 00 00       	call   f01038dd <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007e0:	83 c4 08             	add    $0x8,%esp
f01007e3:	68 0c 00 10 00       	push   $0x10000c
f01007e8:	68 b4 66 10 f0       	push   $0xf01066b4
f01007ed:	e8 eb 30 00 00       	call   f01038dd <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007f2:	83 c4 0c             	add    $0xc,%esp
f01007f5:	68 0c 00 10 00       	push   $0x10000c
f01007fa:	68 0c 00 10 f0       	push   $0xf010000c
f01007ff:	68 dc 66 10 f0       	push   $0xf01066dc
f0100804:	e8 d4 30 00 00       	call   f01038dd <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100809:	83 c4 0c             	add    $0xc,%esp
f010080c:	68 89 62 10 00       	push   $0x106289
f0100811:	68 89 62 10 f0       	push   $0xf0106289
f0100816:	68 00 67 10 f0       	push   $0xf0106700
f010081b:	e8 bd 30 00 00       	call   f01038dd <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 00 40 23 00       	push   $0x234000
f0100828:	68 00 40 23 f0       	push   $0xf0234000
f010082d:	68 24 67 10 f0       	push   $0xf0106724
f0100832:	e8 a6 30 00 00       	call   f01038dd <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 08 60 27 00       	push   $0x276008
f010083f:	68 08 60 27 f0       	push   $0xf0276008
f0100844:	68 48 67 10 f0       	push   $0xf0106748
f0100849:	e8 8f 30 00 00       	call   f01038dd <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084e:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f0100851:	b8 07 64 27 f0       	mov    $0xf0276407,%eax
f0100856:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085b:	c1 f8 0a             	sar    $0xa,%eax
f010085e:	50                   	push   %eax
f010085f:	68 6c 67 10 f0       	push   $0xf010676c
f0100864:	e8 74 30 00 00       	call   f01038dd <cprintf>
	return 0;
}
f0100869:	b8 00 00 00 00       	mov    $0x0,%eax
f010086e:	c9                   	leave  
f010086f:	c3                   	ret    

f0100870 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100870:	55                   	push   %ebp
f0100871:	89 e5                	mov    %esp,%ebp
f0100873:	56                   	push   %esi
f0100874:	53                   	push   %ebx
f0100875:	83 ec 2c             	sub    $0x2c,%esp
	// Your code here.
	struct Eipdebuginfo info;
	cprintf("Stack backtrace:\n");
f0100878:	68 0e 66 10 f0       	push   $0xf010660e
f010087d:	e8 5b 30 00 00       	call   f01038dd <cprintf>
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100882:	89 eb                	mov    %ebp,%ebx
	uint32_t *  ebp=(uint32_t *)read_ebp();
	while(ebp!=0x0){
f0100884:	83 c4 10             	add    $0x10,%esp
	debuginfo_eip(*(ebp+1),&info);
f0100887:	8d 75 e0             	lea    -0x20(%ebp),%esi
	while(ebp!=0x0){
f010088a:	e9 92 00 00 00       	jmp    f0100921 <mon_backtrace+0xb1>
	debuginfo_eip(*(ebp+1),&info);
f010088f:	83 ec 08             	sub    $0x8,%esp
f0100892:	56                   	push   %esi
f0100893:	ff 73 04             	pushl  0x4(%ebx)
f0100896:	e8 1f 43 00 00       	call   f0104bba <debuginfo_eip>
	cprintf("ebp %08x eip %08x",ebp,*(ebp+1));
f010089b:	83 c4 0c             	add    $0xc,%esp
f010089e:	ff 73 04             	pushl  0x4(%ebx)
f01008a1:	53                   	push   %ebx
f01008a2:	68 20 66 10 f0       	push   $0xf0106620
f01008a7:	e8 31 30 00 00       	call   f01038dd <cprintf>
	cprintf(" args %08x",*(ebp+2));
f01008ac:	83 c4 08             	add    $0x8,%esp
f01008af:	ff 73 08             	pushl  0x8(%ebx)
f01008b2:	68 32 66 10 f0       	push   $0xf0106632
f01008b7:	e8 21 30 00 00       	call   f01038dd <cprintf>
	cprintf(" %08x",*(ebp+3));
f01008bc:	83 c4 08             	add    $0x8,%esp
f01008bf:	ff 73 0c             	pushl  0xc(%ebx)
f01008c2:	68 2c 66 10 f0       	push   $0xf010662c
f01008c7:	e8 11 30 00 00       	call   f01038dd <cprintf>
	cprintf(" %08x",*(ebp+4));
f01008cc:	83 c4 08             	add    $0x8,%esp
f01008cf:	ff 73 10             	pushl  0x10(%ebx)
f01008d2:	68 2c 66 10 f0       	push   $0xf010662c
f01008d7:	e8 01 30 00 00       	call   f01038dd <cprintf>
	cprintf(" %08x",*(ebp+5));
f01008dc:	83 c4 08             	add    $0x8,%esp
f01008df:	ff 73 14             	pushl  0x14(%ebx)
f01008e2:	68 2c 66 10 f0       	push   $0xf010662c
f01008e7:	e8 f1 2f 00 00       	call   f01038dd <cprintf>
	cprintf(" %08x\n",*(ebp+6));
f01008ec:	83 c4 08             	add    $0x8,%esp
f01008ef:	ff 73 18             	pushl  0x18(%ebx)
f01008f2:	68 14 7f 10 f0       	push   $0xf0107f14
f01008f7:	e8 e1 2f 00 00       	call   f01038dd <cprintf>
	cprintf("%s:%d: %.*s+%d\n",info.eip_file,info.eip_line,info.eip_fn_namelen,info.eip_fn_name,*(ebp+1)-info.eip_fn_addr);
f01008fc:	83 c4 08             	add    $0x8,%esp
f01008ff:	8b 43 04             	mov    0x4(%ebx),%eax
f0100902:	2b 45 f0             	sub    -0x10(%ebp),%eax
f0100905:	50                   	push   %eax
f0100906:	ff 75 e8             	pushl  -0x18(%ebp)
f0100909:	ff 75 ec             	pushl  -0x14(%ebp)
f010090c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010090f:	ff 75 e0             	pushl  -0x20(%ebp)
f0100912:	68 3d 66 10 f0       	push   $0xf010663d
f0100917:	e8 c1 2f 00 00       	call   f01038dd <cprintf>
	ebp=(uint32_t *) *(ebp);
f010091c:	8b 1b                	mov    (%ebx),%ebx
f010091e:	83 c4 20             	add    $0x20,%esp
	while(ebp!=0x0){
f0100921:	85 db                	test   %ebx,%ebx
f0100923:	0f 85 66 ff ff ff    	jne    f010088f <mon_backtrace+0x1f>
	}
 
	return 0;
}
f0100929:	b8 00 00 00 00       	mov    $0x0,%eax
f010092e:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100931:	5b                   	pop    %ebx
f0100932:	5e                   	pop    %esi
f0100933:	5d                   	pop    %ebp
f0100934:	c3                   	ret    

f0100935 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100935:	55                   	push   %ebp
f0100936:	89 e5                	mov    %esp,%ebp
f0100938:	57                   	push   %edi
f0100939:	56                   	push   %esi
f010093a:	53                   	push   %ebx
f010093b:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010093e:	68 98 67 10 f0       	push   $0xf0106798
f0100943:	e8 95 2f 00 00       	call   f01038dd <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100948:	c7 04 24 bc 67 10 f0 	movl   $0xf01067bc,(%esp)
f010094f:	e8 89 2f 00 00       	call   f01038dd <cprintf>

	if (tf != NULL)
f0100954:	83 c4 10             	add    $0x10,%esp
f0100957:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010095b:	74 57                	je     f01009b4 <monitor+0x7f>
		print_trapframe(tf);
f010095d:	83 ec 0c             	sub    $0xc,%esp
f0100960:	ff 75 08             	pushl  0x8(%ebp)
f0100963:	e8 95 34 00 00       	call   f0103dfd <print_trapframe>
f0100968:	83 c4 10             	add    $0x10,%esp
f010096b:	eb 47                	jmp    f01009b4 <monitor+0x7f>
		while (*buf && strchr(WHITESPACE, *buf))
f010096d:	83 ec 08             	sub    $0x8,%esp
f0100970:	0f be c0             	movsbl %al,%eax
f0100973:	50                   	push   %eax
f0100974:	68 51 66 10 f0       	push   $0xf0106651
f0100979:	e8 75 4c 00 00       	call   f01055f3 <strchr>
f010097e:	83 c4 10             	add    $0x10,%esp
f0100981:	85 c0                	test   %eax,%eax
f0100983:	74 0a                	je     f010098f <monitor+0x5a>
			*buf++ = 0;
f0100985:	c6 03 00             	movb   $0x0,(%ebx)
f0100988:	89 f7                	mov    %esi,%edi
f010098a:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010098d:	eb 6b                	jmp    f01009fa <monitor+0xc5>
		if (*buf == 0)
f010098f:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100992:	74 73                	je     f0100a07 <monitor+0xd2>
		if (argc == MAXARGS-1) {
f0100994:	83 fe 0f             	cmp    $0xf,%esi
f0100997:	74 09                	je     f01009a2 <monitor+0x6d>
		argv[argc++] = buf;
f0100999:	8d 7e 01             	lea    0x1(%esi),%edi
f010099c:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009a0:	eb 39                	jmp    f01009db <monitor+0xa6>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009a2:	83 ec 08             	sub    $0x8,%esp
f01009a5:	6a 10                	push   $0x10
f01009a7:	68 56 66 10 f0       	push   $0xf0106656
f01009ac:	e8 2c 2f 00 00       	call   f01038dd <cprintf>
f01009b1:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01009b4:	83 ec 0c             	sub    $0xc,%esp
f01009b7:	68 4d 66 10 f0       	push   $0xf010664d
f01009bc:	e8 15 4a 00 00       	call   f01053d6 <readline>
f01009c1:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01009c3:	83 c4 10             	add    $0x10,%esp
f01009c6:	85 c0                	test   %eax,%eax
f01009c8:	74 ea                	je     f01009b4 <monitor+0x7f>
	argv[argc] = 0;
f01009ca:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f01009d1:	be 00 00 00 00       	mov    $0x0,%esi
f01009d6:	eb 24                	jmp    f01009fc <monitor+0xc7>
			buf++;
f01009d8:	83 c3 01             	add    $0x1,%ebx
		while (*buf && !strchr(WHITESPACE, *buf))
f01009db:	0f b6 03             	movzbl (%ebx),%eax
f01009de:	84 c0                	test   %al,%al
f01009e0:	74 18                	je     f01009fa <monitor+0xc5>
f01009e2:	83 ec 08             	sub    $0x8,%esp
f01009e5:	0f be c0             	movsbl %al,%eax
f01009e8:	50                   	push   %eax
f01009e9:	68 51 66 10 f0       	push   $0xf0106651
f01009ee:	e8 00 4c 00 00       	call   f01055f3 <strchr>
f01009f3:	83 c4 10             	add    $0x10,%esp
f01009f6:	85 c0                	test   %eax,%eax
f01009f8:	74 de                	je     f01009d8 <monitor+0xa3>
			*buf++ = 0;
f01009fa:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f01009fc:	0f b6 03             	movzbl (%ebx),%eax
f01009ff:	84 c0                	test   %al,%al
f0100a01:	0f 85 66 ff ff ff    	jne    f010096d <monitor+0x38>
	argv[argc] = 0;
f0100a07:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100a0e:	00 
	if (argc == 0)
f0100a0f:	85 f6                	test   %esi,%esi
f0100a11:	74 a1                	je     f01009b4 <monitor+0x7f>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a13:	83 ec 08             	sub    $0x8,%esp
f0100a16:	68 de 65 10 f0       	push   $0xf01065de
f0100a1b:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a1e:	e8 72 4b 00 00       	call   f0105595 <strcmp>
f0100a23:	83 c4 10             	add    $0x10,%esp
f0100a26:	85 c0                	test   %eax,%eax
f0100a28:	74 34                	je     f0100a5e <monitor+0x129>
f0100a2a:	83 ec 08             	sub    $0x8,%esp
f0100a2d:	68 ec 65 10 f0       	push   $0xf01065ec
f0100a32:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a35:	e8 5b 4b 00 00       	call   f0105595 <strcmp>
f0100a3a:	83 c4 10             	add    $0x10,%esp
f0100a3d:	85 c0                	test   %eax,%eax
f0100a3f:	74 18                	je     f0100a59 <monitor+0x124>
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a41:	83 ec 08             	sub    $0x8,%esp
f0100a44:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a47:	68 73 66 10 f0       	push   $0xf0106673
f0100a4c:	e8 8c 2e 00 00       	call   f01038dd <cprintf>
f0100a51:	83 c4 10             	add    $0x10,%esp
f0100a54:	e9 5b ff ff ff       	jmp    f01009b4 <monitor+0x7f>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100a59:	b8 01 00 00 00       	mov    $0x1,%eax
			return commands[i].func(argc, argv, tf);
f0100a5e:	83 ec 04             	sub    $0x4,%esp
f0100a61:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0100a64:	ff 75 08             	pushl  0x8(%ebp)
f0100a67:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a6a:	52                   	push   %edx
f0100a6b:	56                   	push   %esi
f0100a6c:	ff 14 85 ec 67 10 f0 	call   *-0xfef9814(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a73:	83 c4 10             	add    $0x10,%esp
f0100a76:	85 c0                	test   %eax,%eax
f0100a78:	0f 89 36 ff ff ff    	jns    f01009b4 <monitor+0x7f>
				break;
	}
}
f0100a7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a81:	5b                   	pop    %ebx
f0100a82:	5e                   	pop    %esi
f0100a83:	5f                   	pop    %edi
f0100a84:	5d                   	pop    %ebp
f0100a85:	c3                   	ret    

f0100a86 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a86:	55                   	push   %ebp
f0100a87:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a89:	83 3d 38 42 23 f0 00 	cmpl   $0x0,0xf0234238
f0100a90:	74 1d                	je     f0100aaf <boot_alloc+0x29>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a92:	8b 0d 38 42 23 f0    	mov    0xf0234238,%ecx
	nextfree = ROUNDUP((char *)result + n, PGSIZE);
f0100a98:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100a9f:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aa5:	89 15 38 42 23 f0    	mov    %edx,0xf0234238
	return result;
}
f0100aab:	89 c8                	mov    %ecx,%eax
f0100aad:	5d                   	pop    %ebp
f0100aae:	c3                   	ret    
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100aaf:	ba 07 70 27 f0       	mov    $0xf0277007,%edx
f0100ab4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100aba:	89 15 38 42 23 f0    	mov    %edx,0xf0234238
f0100ac0:	eb d0                	jmp    f0100a92 <boot_alloc+0xc>

f0100ac2 <nvram_read>:
{
f0100ac2:	55                   	push   %ebp
f0100ac3:	89 e5                	mov    %esp,%ebp
f0100ac5:	56                   	push   %esi
f0100ac6:	53                   	push   %ebx
f0100ac7:	89 c6                	mov    %eax,%esi
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100ac9:	83 ec 0c             	sub    $0xc,%esp
f0100acc:	50                   	push   %eax
f0100acd:	e8 82 2c 00 00       	call   f0103754 <mc146818_read>
f0100ad2:	89 c3                	mov    %eax,%ebx
f0100ad4:	83 c6 01             	add    $0x1,%esi
f0100ad7:	89 34 24             	mov    %esi,(%esp)
f0100ada:	e8 75 2c 00 00       	call   f0103754 <mc146818_read>
f0100adf:	c1 e0 08             	shl    $0x8,%eax
f0100ae2:	09 d8                	or     %ebx,%eax
}
f0100ae4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ae7:	5b                   	pop    %ebx
f0100ae8:	5e                   	pop    %esi
f0100ae9:	5d                   	pop    %ebp
f0100aea:	c3                   	ret    

f0100aeb <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100aeb:	89 d1                	mov    %edx,%ecx
f0100aed:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100af0:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100af3:	a8 01                	test   $0x1,%al
f0100af5:	74 52                	je     f0100b49 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100af7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0100afc:	89 c1                	mov    %eax,%ecx
f0100afe:	c1 e9 0c             	shr    $0xc,%ecx
f0100b01:	3b 0d 88 4e 23 f0    	cmp    0xf0234e88,%ecx
f0100b07:	73 25                	jae    f0100b2e <check_va2pa+0x43>
	if (!(p[PTX(va)] & PTE_P))
f0100b09:	c1 ea 0c             	shr    $0xc,%edx
f0100b0c:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b12:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b19:	89 c2                	mov    %eax,%edx
f0100b1b:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b1e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b23:	85 d2                	test   %edx,%edx
f0100b25:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b2a:	0f 44 c2             	cmove  %edx,%eax
f0100b2d:	c3                   	ret    
{
f0100b2e:	55                   	push   %ebp
f0100b2f:	89 e5                	mov    %esp,%ebp
f0100b31:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b34:	50                   	push   %eax
f0100b35:	68 c4 62 10 f0       	push   $0xf01062c4
f0100b3a:	68 85 03 00 00       	push   $0x385
f0100b3f:	68 41 71 10 f0       	push   $0xf0107141
f0100b44:	e8 f7 f4 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b4e:	c3                   	ret    

f0100b4f <check_page_free_list>:
{
f0100b4f:	55                   	push   %ebp
f0100b50:	89 e5                	mov    %esp,%ebp
f0100b52:	57                   	push   %edi
f0100b53:	56                   	push   %esi
f0100b54:	53                   	push   %ebx
f0100b55:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b58:	84 c0                	test   %al,%al
f0100b5a:	0f 85 86 02 00 00    	jne    f0100de6 <check_page_free_list+0x297>
	if (!page_free_list)
f0100b60:	83 3d 40 42 23 f0 00 	cmpl   $0x0,0xf0234240
f0100b67:	74 0a                	je     f0100b73 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b69:	be 00 04 00 00       	mov    $0x400,%esi
f0100b6e:	e9 ce 02 00 00       	jmp    f0100e41 <check_page_free_list+0x2f2>
		panic("'page_free_list' is a null pointer!");
f0100b73:	83 ec 04             	sub    $0x4,%esp
f0100b76:	68 fc 67 10 f0       	push   $0xf01067fc
f0100b7b:	68 b8 02 00 00       	push   $0x2b8
f0100b80:	68 41 71 10 f0       	push   $0xf0107141
f0100b85:	e8 b6 f4 ff ff       	call   f0100040 <_panic>
f0100b8a:	50                   	push   %eax
f0100b8b:	68 c4 62 10 f0       	push   $0xf01062c4
f0100b90:	6a 58                	push   $0x58
f0100b92:	68 4d 71 10 f0       	push   $0xf010714d
f0100b97:	e8 a4 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b9c:	8b 1b                	mov    (%ebx),%ebx
f0100b9e:	85 db                	test   %ebx,%ebx
f0100ba0:	74 41                	je     f0100be3 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ba2:	89 d8                	mov    %ebx,%eax
f0100ba4:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0100baa:	c1 f8 03             	sar    $0x3,%eax
f0100bad:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bb0:	89 c2                	mov    %eax,%edx
f0100bb2:	c1 ea 16             	shr    $0x16,%edx
f0100bb5:	39 f2                	cmp    %esi,%edx
f0100bb7:	73 e3                	jae    f0100b9c <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100bb9:	89 c2                	mov    %eax,%edx
f0100bbb:	c1 ea 0c             	shr    $0xc,%edx
f0100bbe:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0100bc4:	73 c4                	jae    f0100b8a <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100bc6:	83 ec 04             	sub    $0x4,%esp
f0100bc9:	68 80 00 00 00       	push   $0x80
f0100bce:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bd3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bd8:	50                   	push   %eax
f0100bd9:	e8 52 4a 00 00       	call   f0105630 <memset>
f0100bde:	83 c4 10             	add    $0x10,%esp
f0100be1:	eb b9                	jmp    f0100b9c <check_page_free_list+0x4d>
	first_free_page = (char *) boot_alloc(0);
f0100be3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100be8:	e8 99 fe ff ff       	call   f0100a86 <boot_alloc>
f0100bed:	89 45 c8             	mov    %eax,-0x38(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bf0:	8b 15 40 42 23 f0    	mov    0xf0234240,%edx
		assert(pp >= pages);
f0100bf6:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
		assert(pp < pages + npages);
f0100bfc:	a1 88 4e 23 f0       	mov    0xf0234e88,%eax
f0100c01:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0100c04:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c0a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c0d:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c12:	e9 04 01 00 00       	jmp    f0100d1b <check_page_free_list+0x1cc>
		assert(pp >= pages);
f0100c17:	68 5b 71 10 f0       	push   $0xf010715b
f0100c1c:	68 67 71 10 f0       	push   $0xf0107167
f0100c21:	68 d2 02 00 00       	push   $0x2d2
f0100c26:	68 41 71 10 f0       	push   $0xf0107141
f0100c2b:	e8 10 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c30:	68 7c 71 10 f0       	push   $0xf010717c
f0100c35:	68 67 71 10 f0       	push   $0xf0107167
f0100c3a:	68 d3 02 00 00       	push   $0x2d3
f0100c3f:	68 41 71 10 f0       	push   $0xf0107141
f0100c44:	e8 f7 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c49:	68 20 68 10 f0       	push   $0xf0106820
f0100c4e:	68 67 71 10 f0       	push   $0xf0107167
f0100c53:	68 d4 02 00 00       	push   $0x2d4
f0100c58:	68 41 71 10 f0       	push   $0xf0107141
f0100c5d:	e8 de f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c62:	68 90 71 10 f0       	push   $0xf0107190
f0100c67:	68 67 71 10 f0       	push   $0xf0107167
f0100c6c:	68 d7 02 00 00       	push   $0x2d7
f0100c71:	68 41 71 10 f0       	push   $0xf0107141
f0100c76:	e8 c5 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c7b:	68 a1 71 10 f0       	push   $0xf01071a1
f0100c80:	68 67 71 10 f0       	push   $0xf0107167
f0100c85:	68 d8 02 00 00       	push   $0x2d8
f0100c8a:	68 41 71 10 f0       	push   $0xf0107141
f0100c8f:	e8 ac f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c94:	68 54 68 10 f0       	push   $0xf0106854
f0100c99:	68 67 71 10 f0       	push   $0xf0107167
f0100c9e:	68 d9 02 00 00       	push   $0x2d9
f0100ca3:	68 41 71 10 f0       	push   $0xf0107141
f0100ca8:	e8 93 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100cad:	68 ba 71 10 f0       	push   $0xf01071ba
f0100cb2:	68 67 71 10 f0       	push   $0xf0107167
f0100cb7:	68 da 02 00 00       	push   $0x2da
f0100cbc:	68 41 71 10 f0       	push   $0xf0107141
f0100cc1:	e8 7a f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100cc6:	89 c7                	mov    %eax,%edi
f0100cc8:	c1 ef 0c             	shr    $0xc,%edi
f0100ccb:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100cce:	76 1b                	jbe    f0100ceb <check_page_free_list+0x19c>
	return (void *)(pa + KERNBASE);
f0100cd0:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cd6:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100cd9:	77 22                	ja     f0100cfd <check_page_free_list+0x1ae>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100cdb:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100ce0:	0f 84 98 00 00 00    	je     f0100d7e <check_page_free_list+0x22f>
			++nfree_extmem;
f0100ce6:	83 c3 01             	add    $0x1,%ebx
f0100ce9:	eb 2e                	jmp    f0100d19 <check_page_free_list+0x1ca>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ceb:	50                   	push   %eax
f0100cec:	68 c4 62 10 f0       	push   $0xf01062c4
f0100cf1:	6a 58                	push   $0x58
f0100cf3:	68 4d 71 10 f0       	push   $0xf010714d
f0100cf8:	e8 43 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cfd:	68 78 68 10 f0       	push   $0xf0106878
f0100d02:	68 67 71 10 f0       	push   $0xf0107167
f0100d07:	68 db 02 00 00       	push   $0x2db
f0100d0c:	68 41 71 10 f0       	push   $0xf0107141
f0100d11:	e8 2a f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100d16:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d19:	8b 12                	mov    (%edx),%edx
f0100d1b:	85 d2                	test   %edx,%edx
f0100d1d:	74 78                	je     f0100d97 <check_page_free_list+0x248>
		assert(pp >= pages);
f0100d1f:	39 d1                	cmp    %edx,%ecx
f0100d21:	0f 87 f0 fe ff ff    	ja     f0100c17 <check_page_free_list+0xc8>
		assert(pp < pages + npages);
f0100d27:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0100d2a:	0f 86 00 ff ff ff    	jbe    f0100c30 <check_page_free_list+0xe1>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100d30:	89 d0                	mov    %edx,%eax
f0100d32:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100d35:	a8 07                	test   $0x7,%al
f0100d37:	0f 85 0c ff ff ff    	jne    f0100c49 <check_page_free_list+0xfa>
	return (pp - pages) << PGSHIFT;
f0100d3d:	c1 f8 03             	sar    $0x3,%eax
f0100d40:	c1 e0 0c             	shl    $0xc,%eax
		assert(page2pa(pp) != 0);
f0100d43:	85 c0                	test   %eax,%eax
f0100d45:	0f 84 17 ff ff ff    	je     f0100c62 <check_page_free_list+0x113>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d4b:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d50:	0f 84 25 ff ff ff    	je     f0100c7b <check_page_free_list+0x12c>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d56:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d5b:	0f 84 33 ff ff ff    	je     f0100c94 <check_page_free_list+0x145>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d61:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d66:	0f 84 41 ff ff ff    	je     f0100cad <check_page_free_list+0x15e>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d6c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d71:	0f 87 4f ff ff ff    	ja     f0100cc6 <check_page_free_list+0x177>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d77:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d7c:	75 98                	jne    f0100d16 <check_page_free_list+0x1c7>
f0100d7e:	68 d4 71 10 f0       	push   $0xf01071d4
f0100d83:	68 67 71 10 f0       	push   $0xf0107167
f0100d88:	68 dd 02 00 00       	push   $0x2dd
f0100d8d:	68 41 71 10 f0       	push   $0xf0107141
f0100d92:	e8 a9 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_basemem > 0);
f0100d97:	85 f6                	test   %esi,%esi
f0100d99:	7e 19                	jle    f0100db4 <check_page_free_list+0x265>
	assert(nfree_extmem > 0);
f0100d9b:	85 db                	test   %ebx,%ebx
f0100d9d:	7e 2e                	jle    f0100dcd <check_page_free_list+0x27e>
	cprintf("check_page_free_list() succeeded!\n");
f0100d9f:	83 ec 0c             	sub    $0xc,%esp
f0100da2:	68 c0 68 10 f0       	push   $0xf01068c0
f0100da7:	e8 31 2b 00 00       	call   f01038dd <cprintf>
}
f0100dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100daf:	5b                   	pop    %ebx
f0100db0:	5e                   	pop    %esi
f0100db1:	5f                   	pop    %edi
f0100db2:	5d                   	pop    %ebp
f0100db3:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100db4:	68 f1 71 10 f0       	push   $0xf01071f1
f0100db9:	68 67 71 10 f0       	push   $0xf0107167
f0100dbe:	68 e5 02 00 00       	push   $0x2e5
f0100dc3:	68 41 71 10 f0       	push   $0xf0107141
f0100dc8:	e8 73 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100dcd:	68 03 72 10 f0       	push   $0xf0107203
f0100dd2:	68 67 71 10 f0       	push   $0xf0107167
f0100dd7:	68 e6 02 00 00       	push   $0x2e6
f0100ddc:	68 41 71 10 f0       	push   $0xf0107141
f0100de1:	e8 5a f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100de6:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f0100deb:	85 c0                	test   %eax,%eax
f0100ded:	0f 84 80 fd ff ff    	je     f0100b73 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100df3:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100df6:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100df9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dfc:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100dff:	89 c2                	mov    %eax,%edx
f0100e01:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e07:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100e0d:	0f 95 c2             	setne  %dl
f0100e10:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100e13:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100e17:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100e19:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e1d:	8b 00                	mov    (%eax),%eax
f0100e1f:	85 c0                	test   %eax,%eax
f0100e21:	75 dc                	jne    f0100dff <check_page_free_list+0x2b0>
		*tp[1] = 0;
f0100e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100e26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e2c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e32:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e34:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e37:	a3 40 42 23 f0       	mov    %eax,0xf0234240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e3c:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e41:	8b 1d 40 42 23 f0    	mov    0xf0234240,%ebx
f0100e47:	e9 52 fd ff ff       	jmp    f0100b9e <check_page_free_list+0x4f>

f0100e4c <page_init>:
{
f0100e4c:	55                   	push   %ebp
f0100e4d:	89 e5                	mov    %esp,%ebp
f0100e4f:	53                   	push   %ebx
f0100e50:	83 ec 04             	sub    $0x4,%esp
	for (i = 0; i < npages; i++) {
f0100e53:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100e58:	eb 3c                	jmp    f0100e96 <page_init+0x4a>
		else if(i>=IOPHYSMEM/PGSIZE && i< PADDR(boot_alloc(0))/PGSIZE)
f0100e5a:	81 fb 9f 00 00 00    	cmp    $0x9f,%ebx
f0100e60:	77 53                	ja     f0100eb5 <page_init+0x69>
		else if (i == MPENTRY_PADDR / PGSIZE) {
f0100e62:	83 fb 07             	cmp    $0x7,%ebx
f0100e65:	0f 84 92 00 00 00    	je     f0100efd <page_init+0xb1>
f0100e6b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
			pages[i].pp_ref = 0;
f0100e72:	89 c2                	mov    %eax,%edx
f0100e74:	03 15 90 4e 23 f0    	add    0xf0234e90,%edx
f0100e7a:	66 c7 42 04 00 00    	movw   $0x0,0x4(%edx)
			pages[i].pp_link = page_free_list;
f0100e80:	8b 0d 40 42 23 f0    	mov    0xf0234240,%ecx
f0100e86:	89 0a                	mov    %ecx,(%edx)
			page_free_list = &pages[i];
f0100e88:	03 05 90 4e 23 f0    	add    0xf0234e90,%eax
f0100e8e:	a3 40 42 23 f0       	mov    %eax,0xf0234240
	for (i = 0; i < npages; i++) {
f0100e93:	83 c3 01             	add    $0x1,%ebx
f0100e96:	39 1d 88 4e 23 f0    	cmp    %ebx,0xf0234e88
f0100e9c:	76 73                	jbe    f0100f11 <page_init+0xc5>
		if(i == 0)
f0100e9e:	85 db                	test   %ebx,%ebx
f0100ea0:	75 b8                	jne    f0100e5a <page_init+0xe>
			pages[i].pp_ref = 1;
f0100ea2:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f0100ea7:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ead:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100eb3:	eb de                	jmp    f0100e93 <page_init+0x47>
		else if(i>=IOPHYSMEM/PGSIZE && i< PADDR(boot_alloc(0))/PGSIZE)
f0100eb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100eba:	e8 c7 fb ff ff       	call   f0100a86 <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100ebf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100ec4:	76 22                	jbe    f0100ee8 <page_init+0x9c>
	return (physaddr_t)kva - KERNBASE;
f0100ec6:	05 00 00 00 10       	add    $0x10000000,%eax
f0100ecb:	c1 e8 0c             	shr    $0xc,%eax
f0100ece:	39 d8                	cmp    %ebx,%eax
f0100ed0:	76 90                	jbe    f0100e62 <page_init+0x16>
			pages[i].pp_ref = 1;
f0100ed2:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f0100ed7:	8d 04 d8             	lea    (%eax,%ebx,8),%eax
f0100eda:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
			pages[i].pp_link = NULL;
f0100ee0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100ee6:	eb ab                	jmp    f0100e93 <page_init+0x47>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ee8:	50                   	push   %eax
f0100ee9:	68 e8 62 10 f0       	push   $0xf01062e8
f0100eee:	68 41 01 00 00       	push   $0x141
f0100ef3:	68 41 71 10 f0       	push   $0xf0107141
f0100ef8:	e8 43 f1 ff ff       	call   f0100040 <_panic>
			pages[i].pp_ref = 1;
f0100efd:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f0100f02:	66 c7 40 3c 01 00    	movw   $0x1,0x3c(%eax)
			pages[i].pp_link = NULL;
f0100f08:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
f0100f0f:	eb 82                	jmp    f0100e93 <page_init+0x47>
}
f0100f11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f14:	c9                   	leave  
f0100f15:	c3                   	ret    

f0100f16 <page_alloc>:
{
f0100f16:	55                   	push   %ebp
f0100f17:	89 e5                	mov    %esp,%ebp
f0100f19:	53                   	push   %ebx
f0100f1a:	83 ec 04             	sub    $0x4,%esp
	if(page_free_list == NULL)
f0100f1d:	8b 1d 40 42 23 f0    	mov    0xf0234240,%ebx
f0100f23:	85 db                	test   %ebx,%ebx
f0100f25:	74 13                	je     f0100f3a <page_alloc+0x24>
	page_free_list = page->pp_link;
f0100f27:	8b 03                	mov    (%ebx),%eax
f0100f29:	a3 40 42 23 f0       	mov    %eax,0xf0234240
	page->pp_link = 0;
f0100f2e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if(alloc_flags & ALLOC_ZERO)
f0100f34:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f38:	75 07                	jne    f0100f41 <page_alloc+0x2b>
}
f0100f3a:	89 d8                	mov    %ebx,%eax
f0100f3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f3f:	c9                   	leave  
f0100f40:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f41:	89 d8                	mov    %ebx,%eax
f0100f43:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0100f49:	c1 f8 03             	sar    $0x3,%eax
f0100f4c:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0100f4f:	89 c2                	mov    %eax,%edx
f0100f51:	c1 ea 0c             	shr    $0xc,%edx
f0100f54:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0100f5a:	73 1a                	jae    f0100f76 <page_alloc+0x60>
		memset(page2kva(page), 0, PGSIZE);
f0100f5c:	83 ec 04             	sub    $0x4,%esp
f0100f5f:	68 00 10 00 00       	push   $0x1000
f0100f64:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f66:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100f6b:	50                   	push   %eax
f0100f6c:	e8 bf 46 00 00       	call   f0105630 <memset>
f0100f71:	83 c4 10             	add    $0x10,%esp
f0100f74:	eb c4                	jmp    f0100f3a <page_alloc+0x24>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f76:	50                   	push   %eax
f0100f77:	68 c4 62 10 f0       	push   $0xf01062c4
f0100f7c:	6a 58                	push   $0x58
f0100f7e:	68 4d 71 10 f0       	push   $0xf010714d
f0100f83:	e8 b8 f0 ff ff       	call   f0100040 <_panic>

f0100f88 <page_free>:
{
f0100f88:	55                   	push   %ebp
f0100f89:	89 e5                	mov    %esp,%ebp
f0100f8b:	83 ec 08             	sub    $0x8,%esp
f0100f8e:	8b 45 08             	mov    0x8(%ebp),%eax
	if(pp->pp_link != NULL  || pp->pp_ref != 0)
f0100f91:	83 38 00             	cmpl   $0x0,(%eax)
f0100f94:	75 16                	jne    f0100fac <page_free+0x24>
f0100f96:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f9b:	75 0f                	jne    f0100fac <page_free+0x24>
	pp->pp_link = page_free_list;
f0100f9d:	8b 15 40 42 23 f0    	mov    0xf0234240,%edx
f0100fa3:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100fa5:	a3 40 42 23 f0       	mov    %eax,0xf0234240
}
f0100faa:	c9                   	leave  
f0100fab:	c3                   	ret    
		panic("page_free is not right");
f0100fac:	83 ec 04             	sub    $0x4,%esp
f0100faf:	68 14 72 10 f0       	push   $0xf0107214
f0100fb4:	68 79 01 00 00       	push   $0x179
f0100fb9:	68 41 71 10 f0       	push   $0xf0107141
f0100fbe:	e8 7d f0 ff ff       	call   f0100040 <_panic>

f0100fc3 <page_decref>:
{
f0100fc3:	55                   	push   %ebp
f0100fc4:	89 e5                	mov    %esp,%ebp
f0100fc6:	83 ec 08             	sub    $0x8,%esp
f0100fc9:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fcc:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fd0:	83 e8 01             	sub    $0x1,%eax
f0100fd3:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fd7:	66 85 c0             	test   %ax,%ax
f0100fda:	74 02                	je     f0100fde <page_decref+0x1b>
}
f0100fdc:	c9                   	leave  
f0100fdd:	c3                   	ret    
		page_free(pp);
f0100fde:	83 ec 0c             	sub    $0xc,%esp
f0100fe1:	52                   	push   %edx
f0100fe2:	e8 a1 ff ff ff       	call   f0100f88 <page_free>
f0100fe7:	83 c4 10             	add    $0x10,%esp
}
f0100fea:	eb f0                	jmp    f0100fdc <page_decref+0x19>

f0100fec <pgdir_walk>:
{
f0100fec:	55                   	push   %ebp
f0100fed:	89 e5                	mov    %esp,%ebp
f0100fef:	56                   	push   %esi
f0100ff0:	53                   	push   %ebx
f0100ff1:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t* pde_ptr = pgdir + PDX(va);
f0100ff4:	89 f3                	mov    %esi,%ebx
f0100ff6:	c1 eb 16             	shr    $0x16,%ebx
f0100ff9:	c1 e3 02             	shl    $0x2,%ebx
f0100ffc:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde_ptr & PTE_P)){
f0100fff:	f6 03 01             	testb  $0x1,(%ebx)
f0101002:	75 2d                	jne    f0101031 <pgdir_walk+0x45>
		if (create) {
f0101004:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101008:	74 67                	je     f0101071 <pgdir_walk+0x85>
			struct PageInfo *pp = page_alloc(1);
f010100a:	83 ec 0c             	sub    $0xc,%esp
f010100d:	6a 01                	push   $0x1
f010100f:	e8 02 ff ff ff       	call   f0100f16 <page_alloc>
			if (pp == NULL) {
f0101014:	83 c4 10             	add    $0x10,%esp
f0101017:	85 c0                	test   %eax,%eax
f0101019:	74 5d                	je     f0101078 <pgdir_walk+0x8c>
			pp->pp_ref++;
f010101b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101020:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101026:	c1 f8 03             	sar    $0x3,%eax
f0101029:	c1 e0 0c             	shl    $0xc,%eax
			*pde_ptr = (page2pa(pp)) | PTE_P | PTE_U | PTE_W;	
f010102c:	83 c8 07             	or     $0x7,%eax
f010102f:	89 03                	mov    %eax,(%ebx)
	return (pte_t *)KADDR(PTE_ADDR(*pde_ptr)) + PTX(va);
f0101031:	8b 03                	mov    (%ebx),%eax
f0101033:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101038:	89 c2                	mov    %eax,%edx
f010103a:	c1 ea 0c             	shr    $0xc,%edx
f010103d:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0101043:	73 17                	jae    f010105c <pgdir_walk+0x70>
f0101045:	c1 ee 0a             	shr    $0xa,%esi
f0101048:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010104e:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
}
f0101055:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101058:	5b                   	pop    %ebx
f0101059:	5e                   	pop    %esi
f010105a:	5d                   	pop    %ebp
f010105b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010105c:	50                   	push   %eax
f010105d:	68 c4 62 10 f0       	push   $0xf01062c4
f0101062:	68 b1 01 00 00       	push   $0x1b1
f0101067:	68 41 71 10 f0       	push   $0xf0107141
f010106c:	e8 cf ef ff ff       	call   f0100040 <_panic>
			return NULL;
f0101071:	b8 00 00 00 00       	mov    $0x0,%eax
f0101076:	eb dd                	jmp    f0101055 <pgdir_walk+0x69>
				return NULL;
f0101078:	b8 00 00 00 00       	mov    $0x0,%eax
f010107d:	eb d6                	jmp    f0101055 <pgdir_walk+0x69>

f010107f <boot_map_region>:
{
f010107f:	55                   	push   %ebp
f0101080:	89 e5                	mov    %esp,%ebp
f0101082:	57                   	push   %edi
f0101083:	56                   	push   %esi
f0101084:	53                   	push   %ebx
f0101085:	83 ec 1c             	sub    $0x1c,%esp
f0101088:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010108b:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t pgs = size / PGSIZE;
f010108e:	89 cb                	mov    %ecx,%ebx
f0101090:	c1 eb 0c             	shr    $0xc,%ebx
	if (size % PGSIZE != 0) {
f0101093:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
		pgs++;
f0101099:	83 f9 01             	cmp    $0x1,%ecx
f010109c:	83 db ff             	sbb    $0xffffffff,%ebx
f010109f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (int i = 0; i < pgs; i++) {
f01010a2:	89 c3                	mov    %eax,%ebx
f01010a4:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010a9:	89 d7                	mov    %edx,%edi
f01010ab:	29 c7                	sub    %eax,%edi
		*pte = pa | PTE_P | perm;
f01010ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010b0:	83 c8 01             	or     $0x1,%eax
f01010b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	for (int i = 0; i < pgs; i++) {
f01010b6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
f01010b9:	74 41                	je     f01010fc <boot_map_region+0x7d>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010bb:	83 ec 04             	sub    $0x4,%esp
f01010be:	6a 01                	push   $0x1
f01010c0:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010c3:	50                   	push   %eax
f01010c4:	ff 75 e0             	pushl  -0x20(%ebp)
f01010c7:	e8 20 ff ff ff       	call   f0100fec <pgdir_walk>
		if (pte == NULL) {
f01010cc:	83 c4 10             	add    $0x10,%esp
f01010cf:	85 c0                	test   %eax,%eax
f01010d1:	74 12                	je     f01010e5 <boot_map_region+0x66>
		*pte = pa | PTE_P | perm;
f01010d3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010d6:	09 da                	or     %ebx,%edx
f01010d8:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f01010da:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (int i = 0; i < pgs; i++) {
f01010e0:	83 c6 01             	add    $0x1,%esi
f01010e3:	eb d1                	jmp    f01010b6 <boot_map_region+0x37>
			panic("boot_map_region(): out of memory\n");
f01010e5:	83 ec 04             	sub    $0x4,%esp
f01010e8:	68 e4 68 10 f0       	push   $0xf01068e4
f01010ed:	68 ca 01 00 00       	push   $0x1ca
f01010f2:	68 41 71 10 f0       	push   $0xf0107141
f01010f7:	e8 44 ef ff ff       	call   f0100040 <_panic>
}
f01010fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010ff:	5b                   	pop    %ebx
f0101100:	5e                   	pop    %esi
f0101101:	5f                   	pop    %edi
f0101102:	5d                   	pop    %ebp
f0101103:	c3                   	ret    

f0101104 <page_lookup>:
{
f0101104:	55                   	push   %ebp
f0101105:	89 e5                	mov    %esp,%ebp
f0101107:	53                   	push   %ebx
f0101108:	83 ec 08             	sub    $0x8,%esp
f010110b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte =  pgdir_walk(pgdir, va, 0);
f010110e:	6a 00                	push   $0x0
f0101110:	ff 75 0c             	pushl  0xc(%ebp)
f0101113:	ff 75 08             	pushl  0x8(%ebp)
f0101116:	e8 d1 fe ff ff       	call   f0100fec <pgdir_walk>
	if (pte == NULL) {
f010111b:	83 c4 10             	add    $0x10,%esp
f010111e:	85 c0                	test   %eax,%eax
f0101120:	74 3a                	je     f010115c <page_lookup+0x58>
f0101122:	89 c1                	mov    %eax,%ecx
	if (!(*pte) & PTE_P) {
f0101124:	8b 10                	mov    (%eax),%edx
f0101126:	85 d2                	test   %edx,%edx
f0101128:	74 39                	je     f0101163 <page_lookup+0x5f>
f010112a:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010112d:	39 15 88 4e 23 f0    	cmp    %edx,0xf0234e88
f0101133:	76 13                	jbe    f0101148 <page_lookup+0x44>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101135:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f010113a:	8d 04 d0             	lea    (%eax,%edx,8),%eax
	if (pte_store != NULL) {
f010113d:	85 db                	test   %ebx,%ebx
f010113f:	74 02                	je     f0101143 <page_lookup+0x3f>
		*pte_store = pte;
f0101141:	89 0b                	mov    %ecx,(%ebx)
}
f0101143:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101146:	c9                   	leave  
f0101147:	c3                   	ret    
		panic("pa2page called with invalid pa");
f0101148:	83 ec 04             	sub    $0x4,%esp
f010114b:	68 08 69 10 f0       	push   $0xf0106908
f0101150:	6a 51                	push   $0x51
f0101152:	68 4d 71 10 f0       	push   $0xf010714d
f0101157:	e8 e4 ee ff ff       	call   f0100040 <_panic>
		return NULL;
f010115c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101161:	eb e0                	jmp    f0101143 <page_lookup+0x3f>
		return NULL;
f0101163:	b8 00 00 00 00       	mov    $0x0,%eax
f0101168:	eb d9                	jmp    f0101143 <page_lookup+0x3f>

f010116a <tlb_invalidate>:
{
f010116a:	55                   	push   %ebp
f010116b:	89 e5                	mov    %esp,%ebp
f010116d:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101170:	e8 de 4a 00 00       	call   f0105c53 <cpunum>
f0101175:	6b c0 74             	imul   $0x74,%eax,%eax
f0101178:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f010117f:	74 16                	je     f0101197 <tlb_invalidate+0x2d>
f0101181:	e8 cd 4a 00 00       	call   f0105c53 <cpunum>
f0101186:	6b c0 74             	imul   $0x74,%eax,%eax
f0101189:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010118f:	8b 55 08             	mov    0x8(%ebp),%edx
f0101192:	39 50 60             	cmp    %edx,0x60(%eax)
f0101195:	75 06                	jne    f010119d <tlb_invalidate+0x33>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101197:	8b 45 0c             	mov    0xc(%ebp),%eax
f010119a:	0f 01 38             	invlpg (%eax)
}
f010119d:	c9                   	leave  
f010119e:	c3                   	ret    

f010119f <page_remove>:
{
f010119f:	55                   	push   %ebp
f01011a0:	89 e5                	mov    %esp,%ebp
f01011a2:	56                   	push   %esi
f01011a3:	53                   	push   %ebx
f01011a4:	83 ec 14             	sub    $0x14,%esp
f01011a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo* page = page_lookup(pgdir, va, &pte);
f01011ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011b0:	50                   	push   %eax
f01011b1:	56                   	push   %esi
f01011b2:	53                   	push   %ebx
f01011b3:	e8 4c ff ff ff       	call   f0101104 <page_lookup>
	if(page == NULL)
f01011b8:	83 c4 10             	add    $0x10,%esp
f01011bb:	85 c0                	test   %eax,%eax
f01011bd:	75 07                	jne    f01011c6 <page_remove+0x27>
}
f01011bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011c2:	5b                   	pop    %ebx
f01011c3:	5e                   	pop    %esi
f01011c4:	5d                   	pop    %ebp
f01011c5:	c3                   	ret    
	page_decref(page);
f01011c6:	83 ec 0c             	sub    $0xc,%esp
f01011c9:	50                   	push   %eax
f01011ca:	e8 f4 fd ff ff       	call   f0100fc3 <page_decref>
	*pte = 0;
f01011cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011d2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01011d8:	83 c4 08             	add    $0x8,%esp
f01011db:	56                   	push   %esi
f01011dc:	53                   	push   %ebx
f01011dd:	e8 88 ff ff ff       	call   f010116a <tlb_invalidate>
f01011e2:	83 c4 10             	add    $0x10,%esp
f01011e5:	eb d8                	jmp    f01011bf <page_remove+0x20>

f01011e7 <page_insert>:
{
f01011e7:	55                   	push   %ebp
f01011e8:	89 e5                	mov    %esp,%ebp
f01011ea:	57                   	push   %edi
f01011eb:	56                   	push   %esi
f01011ec:	53                   	push   %ebx
f01011ed:	83 ec 10             	sub    $0x10,%esp
f01011f0:	8b 75 08             	mov    0x8(%ebp),%esi
f01011f3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t* pte = pgdir_walk(pgdir, va, 1);
f01011f6:	6a 01                	push   $0x1
f01011f8:	ff 75 10             	pushl  0x10(%ebp)
f01011fb:	56                   	push   %esi
f01011fc:	e8 eb fd ff ff       	call   f0100fec <pgdir_walk>
	if(pte == NULL)
f0101201:	83 c4 10             	add    $0x10,%esp
f0101204:	85 c0                	test   %eax,%eax
f0101206:	74 4c                	je     f0101254 <page_insert+0x6d>
f0101208:	89 c7                	mov    %eax,%edi
	pp->pp_ref++;
f010120a:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if ((*pte) & PTE_P){
f010120f:	f6 00 01             	testb  $0x1,(%eax)
f0101212:	75 2f                	jne    f0101243 <page_insert+0x5c>
	return (pp - pages) << PGSHIFT;
f0101214:	2b 1d 90 4e 23 f0    	sub    0xf0234e90,%ebx
f010121a:	c1 fb 03             	sar    $0x3,%ebx
f010121d:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = pa | perm | PTE_P;
f0101220:	8b 45 14             	mov    0x14(%ebp),%eax
f0101223:	83 c8 01             	or     $0x1,%eax
f0101226:	09 c3                	or     %eax,%ebx
f0101228:	89 1f                	mov    %ebx,(%edi)
	pgdir[PDX(va)] |= perm;
f010122a:	8b 45 10             	mov    0x10(%ebp),%eax
f010122d:	c1 e8 16             	shr    $0x16,%eax
f0101230:	8b 55 14             	mov    0x14(%ebp),%edx
f0101233:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f0101236:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010123b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010123e:	5b                   	pop    %ebx
f010123f:	5e                   	pop    %esi
f0101240:	5f                   	pop    %edi
f0101241:	5d                   	pop    %ebp
f0101242:	c3                   	ret    
		page_remove(pgdir, va);
f0101243:	83 ec 08             	sub    $0x8,%esp
f0101246:	ff 75 10             	pushl  0x10(%ebp)
f0101249:	56                   	push   %esi
f010124a:	e8 50 ff ff ff       	call   f010119f <page_remove>
f010124f:	83 c4 10             	add    $0x10,%esp
f0101252:	eb c0                	jmp    f0101214 <page_insert+0x2d>
		return -E_NO_MEM;
f0101254:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101259:	eb e0                	jmp    f010123b <page_insert+0x54>

f010125b <mmio_map_region>:
{
f010125b:	55                   	push   %ebp
f010125c:	89 e5                	mov    %esp,%ebp
f010125e:	53                   	push   %ebx
f010125f:	83 ec 04             	sub    $0x4,%esp
f0101262:	8b 45 08             	mov    0x8(%ebp),%eax
	size = ROUNDUP(pa+size, PGSIZE);
f0101265:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101268:	8d 9c 10 ff 0f 00 00 	lea    0xfff(%eax,%edx,1),%ebx
f010126f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	pa = ROUNDDOWN(pa,PGSIZE);
f0101275:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	size = size-pa;
f010127a:	29 c3                	sub    %eax,%ebx
	if(base + size > MMIOLIM) 
f010127c:	8b 15 00 13 12 f0    	mov    0xf0121300,%edx
f0101282:	8d 0c 1a             	lea    (%edx,%ebx,1),%ecx
f0101285:	81 f9 00 00 c0 ef    	cmp    $0xefc00000,%ecx
f010128b:	77 24                	ja     f01012b1 <mmio_map_region+0x56>
	boot_map_region(kern_pgdir, base, size, pa, PTE_W|PTE_PCD|PTE_PWT);
f010128d:	83 ec 08             	sub    $0x8,%esp
f0101290:	6a 1a                	push   $0x1a
f0101292:	50                   	push   %eax
f0101293:	89 d9                	mov    %ebx,%ecx
f0101295:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f010129a:	e8 e0 fd ff ff       	call   f010107f <boot_map_region>
	uintptr_t res = base;
f010129f:	a1 00 13 12 f0       	mov    0xf0121300,%eax
	base +=size;
f01012a4:	01 c3                	add    %eax,%ebx
f01012a6:	89 1d 00 13 12 f0    	mov    %ebx,0xf0121300
}
f01012ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01012af:	c9                   	leave  
f01012b0:	c3                   	ret    
		panic("overflow MMIOLIM");
f01012b1:	83 ec 04             	sub    $0x4,%esp
f01012b4:	68 2b 72 10 f0       	push   $0xf010722b
f01012b9:	68 68 02 00 00       	push   $0x268
f01012be:	68 41 71 10 f0       	push   $0xf0107141
f01012c3:	e8 78 ed ff ff       	call   f0100040 <_panic>

f01012c8 <mem_init>:
{
f01012c8:	55                   	push   %ebp
f01012c9:	89 e5                	mov    %esp,%ebp
f01012cb:	57                   	push   %edi
f01012cc:	56                   	push   %esi
f01012cd:	53                   	push   %ebx
f01012ce:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01012d1:	b8 15 00 00 00       	mov    $0x15,%eax
f01012d6:	e8 e7 f7 ff ff       	call   f0100ac2 <nvram_read>
f01012db:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012dd:	b8 17 00 00 00       	mov    $0x17,%eax
f01012e2:	e8 db f7 ff ff       	call   f0100ac2 <nvram_read>
f01012e7:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01012e9:	b8 34 00 00 00       	mov    $0x34,%eax
f01012ee:	e8 cf f7 ff ff       	call   f0100ac2 <nvram_read>
f01012f3:	c1 e0 06             	shl    $0x6,%eax
	if (ext16mem)
f01012f6:	85 c0                	test   %eax,%eax
f01012f8:	0f 85 d9 00 00 00    	jne    f01013d7 <mem_init+0x10f>
		totalmem = 1 * 1024 + extmem;
f01012fe:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101304:	85 f6                	test   %esi,%esi
f0101306:	0f 44 c3             	cmove  %ebx,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101309:	89 c2                	mov    %eax,%edx
f010130b:	c1 ea 02             	shr    $0x2,%edx
f010130e:	89 15 88 4e 23 f0    	mov    %edx,0xf0234e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101314:	89 c2                	mov    %eax,%edx
f0101316:	29 da                	sub    %ebx,%edx
f0101318:	52                   	push   %edx
f0101319:	53                   	push   %ebx
f010131a:	50                   	push   %eax
f010131b:	68 28 69 10 f0       	push   $0xf0106928
f0101320:	e8 b8 25 00 00       	call   f01038dd <cprintf>
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101325:	b8 00 10 00 00       	mov    $0x1000,%eax
f010132a:	e8 57 f7 ff ff       	call   f0100a86 <boot_alloc>
f010132f:	a3 8c 4e 23 f0       	mov    %eax,0xf0234e8c
	memset(kern_pgdir, 0, PGSIZE);
f0101334:	83 c4 0c             	add    $0xc,%esp
f0101337:	68 00 10 00 00       	push   $0x1000
f010133c:	6a 00                	push   $0x0
f010133e:	50                   	push   %eax
f010133f:	e8 ec 42 00 00       	call   f0105630 <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101344:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101349:	83 c4 10             	add    $0x10,%esp
f010134c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101351:	0f 86 8a 00 00 00    	jbe    f01013e1 <mem_init+0x119>
	return (physaddr_t)kva - KERNBASE;
f0101357:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010135d:	83 ca 05             	or     $0x5,%edx
f0101360:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo*)boot_alloc(sizeof(struct PageInfo) * npages);
f0101366:	a1 88 4e 23 f0       	mov    0xf0234e88,%eax
f010136b:	c1 e0 03             	shl    $0x3,%eax
f010136e:	e8 13 f7 ff ff       	call   f0100a86 <boot_alloc>
f0101373:	a3 90 4e 23 f0       	mov    %eax,0xf0234e90
	memset(pages, 0, npages*sizeof(struct PageInfo));
f0101378:	83 ec 04             	sub    $0x4,%esp
f010137b:	8b 0d 88 4e 23 f0    	mov    0xf0234e88,%ecx
f0101381:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101388:	52                   	push   %edx
f0101389:	6a 00                	push   $0x0
f010138b:	50                   	push   %eax
f010138c:	e8 9f 42 00 00       	call   f0105630 <memset>
	envs = (struct Env*)boot_alloc(sizeof(struct Env) * NENV);
f0101391:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101396:	e8 eb f6 ff ff       	call   f0100a86 <boot_alloc>
f010139b:	a3 44 42 23 f0       	mov    %eax,0xf0234244
	memset(envs, 0, NENV * sizeof(struct Env));
f01013a0:	83 c4 0c             	add    $0xc,%esp
f01013a3:	68 00 f0 01 00       	push   $0x1f000
f01013a8:	6a 00                	push   $0x0
f01013aa:	50                   	push   %eax
f01013ab:	e8 80 42 00 00       	call   f0105630 <memset>
	page_init();
f01013b0:	e8 97 fa ff ff       	call   f0100e4c <page_init>
	check_page_free_list(1);
f01013b5:	b8 01 00 00 00       	mov    $0x1,%eax
f01013ba:	e8 90 f7 ff ff       	call   f0100b4f <check_page_free_list>
	if (!pages)
f01013bf:	83 c4 10             	add    $0x10,%esp
f01013c2:	83 3d 90 4e 23 f0 00 	cmpl   $0x0,0xf0234e90
f01013c9:	74 2b                	je     f01013f6 <mem_init+0x12e>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013cb:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f01013d0:	bb 00 00 00 00       	mov    $0x0,%ebx
f01013d5:	eb 3b                	jmp    f0101412 <mem_init+0x14a>
		totalmem = 16 * 1024 + ext16mem;
f01013d7:	05 00 40 00 00       	add    $0x4000,%eax
f01013dc:	e9 28 ff ff ff       	jmp    f0101309 <mem_init+0x41>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013e1:	50                   	push   %eax
f01013e2:	68 e8 62 10 f0       	push   $0xf01062e8
f01013e7:	68 91 00 00 00       	push   $0x91
f01013ec:	68 41 71 10 f0       	push   $0xf0107141
f01013f1:	e8 4a ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f01013f6:	83 ec 04             	sub    $0x4,%esp
f01013f9:	68 3c 72 10 f0       	push   $0xf010723c
f01013fe:	68 f9 02 00 00       	push   $0x2f9
f0101403:	68 41 71 10 f0       	push   $0xf0107141
f0101408:	e8 33 ec ff ff       	call   f0100040 <_panic>
		++nfree;
f010140d:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101410:	8b 00                	mov    (%eax),%eax
f0101412:	85 c0                	test   %eax,%eax
f0101414:	75 f7                	jne    f010140d <mem_init+0x145>
	assert((pp0 = page_alloc(0)));
f0101416:	83 ec 0c             	sub    $0xc,%esp
f0101419:	6a 00                	push   $0x0
f010141b:	e8 f6 fa ff ff       	call   f0100f16 <page_alloc>
f0101420:	89 c7                	mov    %eax,%edi
f0101422:	83 c4 10             	add    $0x10,%esp
f0101425:	85 c0                	test   %eax,%eax
f0101427:	0f 84 12 02 00 00    	je     f010163f <mem_init+0x377>
	assert((pp1 = page_alloc(0)));
f010142d:	83 ec 0c             	sub    $0xc,%esp
f0101430:	6a 00                	push   $0x0
f0101432:	e8 df fa ff ff       	call   f0100f16 <page_alloc>
f0101437:	89 c6                	mov    %eax,%esi
f0101439:	83 c4 10             	add    $0x10,%esp
f010143c:	85 c0                	test   %eax,%eax
f010143e:	0f 84 14 02 00 00    	je     f0101658 <mem_init+0x390>
	assert((pp2 = page_alloc(0)));
f0101444:	83 ec 0c             	sub    $0xc,%esp
f0101447:	6a 00                	push   $0x0
f0101449:	e8 c8 fa ff ff       	call   f0100f16 <page_alloc>
f010144e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101451:	83 c4 10             	add    $0x10,%esp
f0101454:	85 c0                	test   %eax,%eax
f0101456:	0f 84 15 02 00 00    	je     f0101671 <mem_init+0x3a9>
	assert(pp1 && pp1 != pp0);
f010145c:	39 f7                	cmp    %esi,%edi
f010145e:	0f 84 26 02 00 00    	je     f010168a <mem_init+0x3c2>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101464:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101467:	39 c7                	cmp    %eax,%edi
f0101469:	0f 84 34 02 00 00    	je     f01016a3 <mem_init+0x3db>
f010146f:	39 c6                	cmp    %eax,%esi
f0101471:	0f 84 2c 02 00 00    	je     f01016a3 <mem_init+0x3db>
	return (pp - pages) << PGSHIFT;
f0101477:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010147d:	8b 15 88 4e 23 f0    	mov    0xf0234e88,%edx
f0101483:	c1 e2 0c             	shl    $0xc,%edx
f0101486:	89 f8                	mov    %edi,%eax
f0101488:	29 c8                	sub    %ecx,%eax
f010148a:	c1 f8 03             	sar    $0x3,%eax
f010148d:	c1 e0 0c             	shl    $0xc,%eax
f0101490:	39 d0                	cmp    %edx,%eax
f0101492:	0f 83 24 02 00 00    	jae    f01016bc <mem_init+0x3f4>
f0101498:	89 f0                	mov    %esi,%eax
f010149a:	29 c8                	sub    %ecx,%eax
f010149c:	c1 f8 03             	sar    $0x3,%eax
f010149f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f01014a2:	39 c2                	cmp    %eax,%edx
f01014a4:	0f 86 2b 02 00 00    	jbe    f01016d5 <mem_init+0x40d>
f01014aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014ad:	29 c8                	sub    %ecx,%eax
f01014af:	c1 f8 03             	sar    $0x3,%eax
f01014b2:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f01014b5:	39 c2                	cmp    %eax,%edx
f01014b7:	0f 86 31 02 00 00    	jbe    f01016ee <mem_init+0x426>
	fl = page_free_list;
f01014bd:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f01014c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014c5:	c7 05 40 42 23 f0 00 	movl   $0x0,0xf0234240
f01014cc:	00 00 00 
	assert(!page_alloc(0));
f01014cf:	83 ec 0c             	sub    $0xc,%esp
f01014d2:	6a 00                	push   $0x0
f01014d4:	e8 3d fa ff ff       	call   f0100f16 <page_alloc>
f01014d9:	83 c4 10             	add    $0x10,%esp
f01014dc:	85 c0                	test   %eax,%eax
f01014de:	0f 85 23 02 00 00    	jne    f0101707 <mem_init+0x43f>
	page_free(pp0);
f01014e4:	83 ec 0c             	sub    $0xc,%esp
f01014e7:	57                   	push   %edi
f01014e8:	e8 9b fa ff ff       	call   f0100f88 <page_free>
	page_free(pp1);
f01014ed:	89 34 24             	mov    %esi,(%esp)
f01014f0:	e8 93 fa ff ff       	call   f0100f88 <page_free>
	page_free(pp2);
f01014f5:	83 c4 04             	add    $0x4,%esp
f01014f8:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014fb:	e8 88 fa ff ff       	call   f0100f88 <page_free>
	assert((pp0 = page_alloc(0)));
f0101500:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101507:	e8 0a fa ff ff       	call   f0100f16 <page_alloc>
f010150c:	89 c6                	mov    %eax,%esi
f010150e:	83 c4 10             	add    $0x10,%esp
f0101511:	85 c0                	test   %eax,%eax
f0101513:	0f 84 07 02 00 00    	je     f0101720 <mem_init+0x458>
	assert((pp1 = page_alloc(0)));
f0101519:	83 ec 0c             	sub    $0xc,%esp
f010151c:	6a 00                	push   $0x0
f010151e:	e8 f3 f9 ff ff       	call   f0100f16 <page_alloc>
f0101523:	89 c7                	mov    %eax,%edi
f0101525:	83 c4 10             	add    $0x10,%esp
f0101528:	85 c0                	test   %eax,%eax
f010152a:	0f 84 09 02 00 00    	je     f0101739 <mem_init+0x471>
	assert((pp2 = page_alloc(0)));
f0101530:	83 ec 0c             	sub    $0xc,%esp
f0101533:	6a 00                	push   $0x0
f0101535:	e8 dc f9 ff ff       	call   f0100f16 <page_alloc>
f010153a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010153d:	83 c4 10             	add    $0x10,%esp
f0101540:	85 c0                	test   %eax,%eax
f0101542:	0f 84 0a 02 00 00    	je     f0101752 <mem_init+0x48a>
	assert(pp1 && pp1 != pp0);
f0101548:	39 fe                	cmp    %edi,%esi
f010154a:	0f 84 1b 02 00 00    	je     f010176b <mem_init+0x4a3>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101550:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101553:	39 c7                	cmp    %eax,%edi
f0101555:	0f 84 29 02 00 00    	je     f0101784 <mem_init+0x4bc>
f010155b:	39 c6                	cmp    %eax,%esi
f010155d:	0f 84 21 02 00 00    	je     f0101784 <mem_init+0x4bc>
	assert(!page_alloc(0));
f0101563:	83 ec 0c             	sub    $0xc,%esp
f0101566:	6a 00                	push   $0x0
f0101568:	e8 a9 f9 ff ff       	call   f0100f16 <page_alloc>
f010156d:	83 c4 10             	add    $0x10,%esp
f0101570:	85 c0                	test   %eax,%eax
f0101572:	0f 85 25 02 00 00    	jne    f010179d <mem_init+0x4d5>
f0101578:	89 f0                	mov    %esi,%eax
f010157a:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101580:	c1 f8 03             	sar    $0x3,%eax
f0101583:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101586:	89 c2                	mov    %eax,%edx
f0101588:	c1 ea 0c             	shr    $0xc,%edx
f010158b:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0101591:	0f 83 1f 02 00 00    	jae    f01017b6 <mem_init+0x4ee>
	memset(page2kva(pp0), 1, PGSIZE);
f0101597:	83 ec 04             	sub    $0x4,%esp
f010159a:	68 00 10 00 00       	push   $0x1000
f010159f:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015a1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015a6:	50                   	push   %eax
f01015a7:	e8 84 40 00 00       	call   f0105630 <memset>
	page_free(pp0);
f01015ac:	89 34 24             	mov    %esi,(%esp)
f01015af:	e8 d4 f9 ff ff       	call   f0100f88 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015bb:	e8 56 f9 ff ff       	call   f0100f16 <page_alloc>
f01015c0:	83 c4 10             	add    $0x10,%esp
f01015c3:	85 c0                	test   %eax,%eax
f01015c5:	0f 84 fd 01 00 00    	je     f01017c8 <mem_init+0x500>
	assert(pp && pp0 == pp);
f01015cb:	39 c6                	cmp    %eax,%esi
f01015cd:	0f 85 0e 02 00 00    	jne    f01017e1 <mem_init+0x519>
	return (pp - pages) << PGSHIFT;
f01015d3:	89 f2                	mov    %esi,%edx
f01015d5:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f01015db:	c1 fa 03             	sar    $0x3,%edx
f01015de:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015e1:	89 d0                	mov    %edx,%eax
f01015e3:	c1 e8 0c             	shr    $0xc,%eax
f01015e6:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f01015ec:	0f 83 08 02 00 00    	jae    f01017fa <mem_init+0x532>
	return (void *)(pa + KERNBASE);
f01015f2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015f8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015fe:	80 38 00             	cmpb   $0x0,(%eax)
f0101601:	0f 85 05 02 00 00    	jne    f010180c <mem_init+0x544>
f0101607:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f010160a:	39 d0                	cmp    %edx,%eax
f010160c:	75 f0                	jne    f01015fe <mem_init+0x336>
	page_free_list = fl;
f010160e:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101611:	a3 40 42 23 f0       	mov    %eax,0xf0234240
	page_free(pp0);
f0101616:	83 ec 0c             	sub    $0xc,%esp
f0101619:	56                   	push   %esi
f010161a:	e8 69 f9 ff ff       	call   f0100f88 <page_free>
	page_free(pp1);
f010161f:	89 3c 24             	mov    %edi,(%esp)
f0101622:	e8 61 f9 ff ff       	call   f0100f88 <page_free>
	page_free(pp2);
f0101627:	83 c4 04             	add    $0x4,%esp
f010162a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010162d:	e8 56 f9 ff ff       	call   f0100f88 <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101632:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f0101637:	83 c4 10             	add    $0x10,%esp
f010163a:	e9 eb 01 00 00       	jmp    f010182a <mem_init+0x562>
	assert((pp0 = page_alloc(0)));
f010163f:	68 57 72 10 f0       	push   $0xf0107257
f0101644:	68 67 71 10 f0       	push   $0xf0107167
f0101649:	68 01 03 00 00       	push   $0x301
f010164e:	68 41 71 10 f0       	push   $0xf0107141
f0101653:	e8 e8 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101658:	68 6d 72 10 f0       	push   $0xf010726d
f010165d:	68 67 71 10 f0       	push   $0xf0107167
f0101662:	68 02 03 00 00       	push   $0x302
f0101667:	68 41 71 10 f0       	push   $0xf0107141
f010166c:	e8 cf e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101671:	68 83 72 10 f0       	push   $0xf0107283
f0101676:	68 67 71 10 f0       	push   $0xf0107167
f010167b:	68 03 03 00 00       	push   $0x303
f0101680:	68 41 71 10 f0       	push   $0xf0107141
f0101685:	e8 b6 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010168a:	68 99 72 10 f0       	push   $0xf0107299
f010168f:	68 67 71 10 f0       	push   $0xf0107167
f0101694:	68 06 03 00 00       	push   $0x306
f0101699:	68 41 71 10 f0       	push   $0xf0107141
f010169e:	e8 9d e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a3:	68 64 69 10 f0       	push   $0xf0106964
f01016a8:	68 67 71 10 f0       	push   $0xf0107167
f01016ad:	68 07 03 00 00       	push   $0x307
f01016b2:	68 41 71 10 f0       	push   $0xf0107141
f01016b7:	e8 84 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages*PGSIZE);
f01016bc:	68 ab 72 10 f0       	push   $0xf01072ab
f01016c1:	68 67 71 10 f0       	push   $0xf0107167
f01016c6:	68 08 03 00 00       	push   $0x308
f01016cb:	68 41 71 10 f0       	push   $0xf0107141
f01016d0:	e8 6b e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01016d5:	68 c8 72 10 f0       	push   $0xf01072c8
f01016da:	68 67 71 10 f0       	push   $0xf0107167
f01016df:	68 09 03 00 00       	push   $0x309
f01016e4:	68 41 71 10 f0       	push   $0xf0107141
f01016e9:	e8 52 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01016ee:	68 e5 72 10 f0       	push   $0xf01072e5
f01016f3:	68 67 71 10 f0       	push   $0xf0107167
f01016f8:	68 0a 03 00 00       	push   $0x30a
f01016fd:	68 41 71 10 f0       	push   $0xf0107141
f0101702:	e8 39 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101707:	68 02 73 10 f0       	push   $0xf0107302
f010170c:	68 67 71 10 f0       	push   $0xf0107167
f0101711:	68 11 03 00 00       	push   $0x311
f0101716:	68 41 71 10 f0       	push   $0xf0107141
f010171b:	e8 20 e9 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101720:	68 57 72 10 f0       	push   $0xf0107257
f0101725:	68 67 71 10 f0       	push   $0xf0107167
f010172a:	68 18 03 00 00       	push   $0x318
f010172f:	68 41 71 10 f0       	push   $0xf0107141
f0101734:	e8 07 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101739:	68 6d 72 10 f0       	push   $0xf010726d
f010173e:	68 67 71 10 f0       	push   $0xf0107167
f0101743:	68 19 03 00 00       	push   $0x319
f0101748:	68 41 71 10 f0       	push   $0xf0107141
f010174d:	e8 ee e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101752:	68 83 72 10 f0       	push   $0xf0107283
f0101757:	68 67 71 10 f0       	push   $0xf0107167
f010175c:	68 1a 03 00 00       	push   $0x31a
f0101761:	68 41 71 10 f0       	push   $0xf0107141
f0101766:	e8 d5 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010176b:	68 99 72 10 f0       	push   $0xf0107299
f0101770:	68 67 71 10 f0       	push   $0xf0107167
f0101775:	68 1c 03 00 00       	push   $0x31c
f010177a:	68 41 71 10 f0       	push   $0xf0107141
f010177f:	e8 bc e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101784:	68 64 69 10 f0       	push   $0xf0106964
f0101789:	68 67 71 10 f0       	push   $0xf0107167
f010178e:	68 1d 03 00 00       	push   $0x31d
f0101793:	68 41 71 10 f0       	push   $0xf0107141
f0101798:	e8 a3 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010179d:	68 02 73 10 f0       	push   $0xf0107302
f01017a2:	68 67 71 10 f0       	push   $0xf0107167
f01017a7:	68 1e 03 00 00       	push   $0x31e
f01017ac:	68 41 71 10 f0       	push   $0xf0107141
f01017b1:	e8 8a e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017b6:	50                   	push   %eax
f01017b7:	68 c4 62 10 f0       	push   $0xf01062c4
f01017bc:	6a 58                	push   $0x58
f01017be:	68 4d 71 10 f0       	push   $0xf010714d
f01017c3:	e8 78 e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017c8:	68 11 73 10 f0       	push   $0xf0107311
f01017cd:	68 67 71 10 f0       	push   $0xf0107167
f01017d2:	68 23 03 00 00       	push   $0x323
f01017d7:	68 41 71 10 f0       	push   $0xf0107141
f01017dc:	e8 5f e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017e1:	68 2f 73 10 f0       	push   $0xf010732f
f01017e6:	68 67 71 10 f0       	push   $0xf0107167
f01017eb:	68 24 03 00 00       	push   $0x324
f01017f0:	68 41 71 10 f0       	push   $0xf0107141
f01017f5:	e8 46 e8 ff ff       	call   f0100040 <_panic>
f01017fa:	52                   	push   %edx
f01017fb:	68 c4 62 10 f0       	push   $0xf01062c4
f0101800:	6a 58                	push   $0x58
f0101802:	68 4d 71 10 f0       	push   $0xf010714d
f0101807:	e8 34 e8 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f010180c:	68 3f 73 10 f0       	push   $0xf010733f
f0101811:	68 67 71 10 f0       	push   $0xf0107167
f0101816:	68 27 03 00 00       	push   $0x327
f010181b:	68 41 71 10 f0       	push   $0xf0107141
f0101820:	e8 1b e8 ff ff       	call   f0100040 <_panic>
		--nfree;
f0101825:	83 eb 01             	sub    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101828:	8b 00                	mov    (%eax),%eax
f010182a:	85 c0                	test   %eax,%eax
f010182c:	75 f7                	jne    f0101825 <mem_init+0x55d>
	assert(nfree == 0);
f010182e:	85 db                	test   %ebx,%ebx
f0101830:	0f 85 64 09 00 00    	jne    f010219a <mem_init+0xed2>
	cprintf("check_page_alloc() succeeded!\n");
f0101836:	83 ec 0c             	sub    $0xc,%esp
f0101839:	68 84 69 10 f0       	push   $0xf0106984
f010183e:	e8 9a 20 00 00       	call   f01038dd <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101843:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010184a:	e8 c7 f6 ff ff       	call   f0100f16 <page_alloc>
f010184f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101852:	83 c4 10             	add    $0x10,%esp
f0101855:	85 c0                	test   %eax,%eax
f0101857:	0f 84 56 09 00 00    	je     f01021b3 <mem_init+0xeeb>
	assert((pp1 = page_alloc(0)));
f010185d:	83 ec 0c             	sub    $0xc,%esp
f0101860:	6a 00                	push   $0x0
f0101862:	e8 af f6 ff ff       	call   f0100f16 <page_alloc>
f0101867:	89 c3                	mov    %eax,%ebx
f0101869:	83 c4 10             	add    $0x10,%esp
f010186c:	85 c0                	test   %eax,%eax
f010186e:	0f 84 58 09 00 00    	je     f01021cc <mem_init+0xf04>
	assert((pp2 = page_alloc(0)));
f0101874:	83 ec 0c             	sub    $0xc,%esp
f0101877:	6a 00                	push   $0x0
f0101879:	e8 98 f6 ff ff       	call   f0100f16 <page_alloc>
f010187e:	89 c6                	mov    %eax,%esi
f0101880:	83 c4 10             	add    $0x10,%esp
f0101883:	85 c0                	test   %eax,%eax
f0101885:	0f 84 5a 09 00 00    	je     f01021e5 <mem_init+0xf1d>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010188b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010188e:	0f 84 6a 09 00 00    	je     f01021fe <mem_init+0xf36>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101894:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101897:	0f 84 7a 09 00 00    	je     f0102217 <mem_init+0xf4f>
f010189d:	39 c3                	cmp    %eax,%ebx
f010189f:	0f 84 72 09 00 00    	je     f0102217 <mem_init+0xf4f>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018a5:	a1 40 42 23 f0       	mov    0xf0234240,%eax
f01018aa:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018ad:	c7 05 40 42 23 f0 00 	movl   $0x0,0xf0234240
f01018b4:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018b7:	83 ec 0c             	sub    $0xc,%esp
f01018ba:	6a 00                	push   $0x0
f01018bc:	e8 55 f6 ff ff       	call   f0100f16 <page_alloc>
f01018c1:	83 c4 10             	add    $0x10,%esp
f01018c4:	85 c0                	test   %eax,%eax
f01018c6:	0f 85 64 09 00 00    	jne    f0102230 <mem_init+0xf68>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018cc:	83 ec 04             	sub    $0x4,%esp
f01018cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018d2:	50                   	push   %eax
f01018d3:	6a 00                	push   $0x0
f01018d5:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f01018db:	e8 24 f8 ff ff       	call   f0101104 <page_lookup>
f01018e0:	83 c4 10             	add    $0x10,%esp
f01018e3:	85 c0                	test   %eax,%eax
f01018e5:	0f 85 5e 09 00 00    	jne    f0102249 <mem_init+0xf81>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018eb:	6a 02                	push   $0x2
f01018ed:	6a 00                	push   $0x0
f01018ef:	53                   	push   %ebx
f01018f0:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f01018f6:	e8 ec f8 ff ff       	call   f01011e7 <page_insert>
f01018fb:	83 c4 10             	add    $0x10,%esp
f01018fe:	85 c0                	test   %eax,%eax
f0101900:	0f 89 5c 09 00 00    	jns    f0102262 <mem_init+0xf9a>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101906:	83 ec 0c             	sub    $0xc,%esp
f0101909:	ff 75 d4             	pushl  -0x2c(%ebp)
f010190c:	e8 77 f6 ff ff       	call   f0100f88 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101911:	6a 02                	push   $0x2
f0101913:	6a 00                	push   $0x0
f0101915:	53                   	push   %ebx
f0101916:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f010191c:	e8 c6 f8 ff ff       	call   f01011e7 <page_insert>
f0101921:	83 c4 20             	add    $0x20,%esp
f0101924:	85 c0                	test   %eax,%eax
f0101926:	0f 85 4f 09 00 00    	jne    f010227b <mem_init+0xfb3>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010192c:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
	return (pp - pages) << PGSHIFT;
f0101932:	8b 0d 90 4e 23 f0    	mov    0xf0234e90,%ecx
f0101938:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f010193b:	8b 17                	mov    (%edi),%edx
f010193d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101943:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101946:	29 c8                	sub    %ecx,%eax
f0101948:	c1 f8 03             	sar    $0x3,%eax
f010194b:	c1 e0 0c             	shl    $0xc,%eax
f010194e:	39 c2                	cmp    %eax,%edx
f0101950:	0f 85 3e 09 00 00    	jne    f0102294 <mem_init+0xfcc>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101956:	ba 00 00 00 00       	mov    $0x0,%edx
f010195b:	89 f8                	mov    %edi,%eax
f010195d:	e8 89 f1 ff ff       	call   f0100aeb <check_va2pa>
f0101962:	89 da                	mov    %ebx,%edx
f0101964:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101967:	c1 fa 03             	sar    $0x3,%edx
f010196a:	c1 e2 0c             	shl    $0xc,%edx
f010196d:	39 d0                	cmp    %edx,%eax
f010196f:	0f 85 38 09 00 00    	jne    f01022ad <mem_init+0xfe5>
	assert(pp1->pp_ref == 1);
f0101975:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010197a:	0f 85 46 09 00 00    	jne    f01022c6 <mem_init+0xffe>
	assert(pp0->pp_ref == 1);
f0101980:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101983:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101988:	0f 85 51 09 00 00    	jne    f01022df <mem_init+0x1017>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010198e:	6a 02                	push   $0x2
f0101990:	68 00 10 00 00       	push   $0x1000
f0101995:	56                   	push   %esi
f0101996:	57                   	push   %edi
f0101997:	e8 4b f8 ff ff       	call   f01011e7 <page_insert>
f010199c:	83 c4 10             	add    $0x10,%esp
f010199f:	85 c0                	test   %eax,%eax
f01019a1:	0f 85 51 09 00 00    	jne    f01022f8 <mem_init+0x1030>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019a7:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019ac:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f01019b1:	e8 35 f1 ff ff       	call   f0100aeb <check_va2pa>
f01019b6:	89 f2                	mov    %esi,%edx
f01019b8:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f01019be:	c1 fa 03             	sar    $0x3,%edx
f01019c1:	c1 e2 0c             	shl    $0xc,%edx
f01019c4:	39 d0                	cmp    %edx,%eax
f01019c6:	0f 85 45 09 00 00    	jne    f0102311 <mem_init+0x1049>
	assert(pp2->pp_ref == 1);
f01019cc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019d1:	0f 85 53 09 00 00    	jne    f010232a <mem_init+0x1062>

	// should be no free memory
	assert(!page_alloc(0));
f01019d7:	83 ec 0c             	sub    $0xc,%esp
f01019da:	6a 00                	push   $0x0
f01019dc:	e8 35 f5 ff ff       	call   f0100f16 <page_alloc>
f01019e1:	83 c4 10             	add    $0x10,%esp
f01019e4:	85 c0                	test   %eax,%eax
f01019e6:	0f 85 57 09 00 00    	jne    f0102343 <mem_init+0x107b>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019ec:	6a 02                	push   $0x2
f01019ee:	68 00 10 00 00       	push   $0x1000
f01019f3:	56                   	push   %esi
f01019f4:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f01019fa:	e8 e8 f7 ff ff       	call   f01011e7 <page_insert>
f01019ff:	83 c4 10             	add    $0x10,%esp
f0101a02:	85 c0                	test   %eax,%eax
f0101a04:	0f 85 52 09 00 00    	jne    f010235c <mem_init+0x1094>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a0f:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101a14:	e8 d2 f0 ff ff       	call   f0100aeb <check_va2pa>
f0101a19:	89 f2                	mov    %esi,%edx
f0101a1b:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101a21:	c1 fa 03             	sar    $0x3,%edx
f0101a24:	c1 e2 0c             	shl    $0xc,%edx
f0101a27:	39 d0                	cmp    %edx,%eax
f0101a29:	0f 85 46 09 00 00    	jne    f0102375 <mem_init+0x10ad>
	assert(pp2->pp_ref == 1);
f0101a2f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a34:	0f 85 54 09 00 00    	jne    f010238e <mem_init+0x10c6>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a3a:	83 ec 0c             	sub    $0xc,%esp
f0101a3d:	6a 00                	push   $0x0
f0101a3f:	e8 d2 f4 ff ff       	call   f0100f16 <page_alloc>
f0101a44:	83 c4 10             	add    $0x10,%esp
f0101a47:	85 c0                	test   %eax,%eax
f0101a49:	0f 85 58 09 00 00    	jne    f01023a7 <mem_init+0x10df>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a4f:	8b 15 8c 4e 23 f0    	mov    0xf0234e8c,%edx
f0101a55:	8b 02                	mov    (%edx),%eax
f0101a57:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101a5c:	89 c1                	mov    %eax,%ecx
f0101a5e:	c1 e9 0c             	shr    $0xc,%ecx
f0101a61:	3b 0d 88 4e 23 f0    	cmp    0xf0234e88,%ecx
f0101a67:	0f 83 53 09 00 00    	jae    f01023c0 <mem_init+0x10f8>
	return (void *)(pa + KERNBASE);
f0101a6d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101a72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a75:	83 ec 04             	sub    $0x4,%esp
f0101a78:	6a 00                	push   $0x0
f0101a7a:	68 00 10 00 00       	push   $0x1000
f0101a7f:	52                   	push   %edx
f0101a80:	e8 67 f5 ff ff       	call   f0100fec <pgdir_walk>
f0101a85:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101a88:	8d 51 04             	lea    0x4(%ecx),%edx
f0101a8b:	83 c4 10             	add    $0x10,%esp
f0101a8e:	39 d0                	cmp    %edx,%eax
f0101a90:	0f 85 3f 09 00 00    	jne    f01023d5 <mem_init+0x110d>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a96:	6a 06                	push   $0x6
f0101a98:	68 00 10 00 00       	push   $0x1000
f0101a9d:	56                   	push   %esi
f0101a9e:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101aa4:	e8 3e f7 ff ff       	call   f01011e7 <page_insert>
f0101aa9:	83 c4 10             	add    $0x10,%esp
f0101aac:	85 c0                	test   %eax,%eax
f0101aae:	0f 85 3a 09 00 00    	jne    f01023ee <mem_init+0x1126>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ab4:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101aba:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101abf:	89 f8                	mov    %edi,%eax
f0101ac1:	e8 25 f0 ff ff       	call   f0100aeb <check_va2pa>
	return (pp - pages) << PGSHIFT;
f0101ac6:	89 f2                	mov    %esi,%edx
f0101ac8:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101ace:	c1 fa 03             	sar    $0x3,%edx
f0101ad1:	c1 e2 0c             	shl    $0xc,%edx
f0101ad4:	39 d0                	cmp    %edx,%eax
f0101ad6:	0f 85 2b 09 00 00    	jne    f0102407 <mem_init+0x113f>
	assert(pp2->pp_ref == 1);
f0101adc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ae1:	0f 85 39 09 00 00    	jne    f0102420 <mem_init+0x1158>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101ae7:	83 ec 04             	sub    $0x4,%esp
f0101aea:	6a 00                	push   $0x0
f0101aec:	68 00 10 00 00       	push   $0x1000
f0101af1:	57                   	push   %edi
f0101af2:	e8 f5 f4 ff ff       	call   f0100fec <pgdir_walk>
f0101af7:	83 c4 10             	add    $0x10,%esp
f0101afa:	f6 00 04             	testb  $0x4,(%eax)
f0101afd:	0f 84 36 09 00 00    	je     f0102439 <mem_init+0x1171>
	assert(kern_pgdir[0] & PTE_U);
f0101b03:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101b08:	f6 00 04             	testb  $0x4,(%eax)
f0101b0b:	0f 84 41 09 00 00    	je     f0102452 <mem_init+0x118a>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b11:	6a 02                	push   $0x2
f0101b13:	68 00 10 00 00       	push   $0x1000
f0101b18:	56                   	push   %esi
f0101b19:	50                   	push   %eax
f0101b1a:	e8 c8 f6 ff ff       	call   f01011e7 <page_insert>
f0101b1f:	83 c4 10             	add    $0x10,%esp
f0101b22:	85 c0                	test   %eax,%eax
f0101b24:	0f 85 41 09 00 00    	jne    f010246b <mem_init+0x11a3>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101b2a:	83 ec 04             	sub    $0x4,%esp
f0101b2d:	6a 00                	push   $0x0
f0101b2f:	68 00 10 00 00       	push   $0x1000
f0101b34:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101b3a:	e8 ad f4 ff ff       	call   f0100fec <pgdir_walk>
f0101b3f:	83 c4 10             	add    $0x10,%esp
f0101b42:	f6 00 02             	testb  $0x2,(%eax)
f0101b45:	0f 84 39 09 00 00    	je     f0102484 <mem_init+0x11bc>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b4b:	83 ec 04             	sub    $0x4,%esp
f0101b4e:	6a 00                	push   $0x0
f0101b50:	68 00 10 00 00       	push   $0x1000
f0101b55:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101b5b:	e8 8c f4 ff ff       	call   f0100fec <pgdir_walk>
f0101b60:	83 c4 10             	add    $0x10,%esp
f0101b63:	f6 00 04             	testb  $0x4,(%eax)
f0101b66:	0f 85 31 09 00 00    	jne    f010249d <mem_init+0x11d5>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b6c:	6a 02                	push   $0x2
f0101b6e:	68 00 00 40 00       	push   $0x400000
f0101b73:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b76:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101b7c:	e8 66 f6 ff ff       	call   f01011e7 <page_insert>
f0101b81:	83 c4 10             	add    $0x10,%esp
f0101b84:	85 c0                	test   %eax,%eax
f0101b86:	0f 89 2a 09 00 00    	jns    f01024b6 <mem_init+0x11ee>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b8c:	6a 02                	push   $0x2
f0101b8e:	68 00 10 00 00       	push   $0x1000
f0101b93:	53                   	push   %ebx
f0101b94:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101b9a:	e8 48 f6 ff ff       	call   f01011e7 <page_insert>
f0101b9f:	83 c4 10             	add    $0x10,%esp
f0101ba2:	85 c0                	test   %eax,%eax
f0101ba4:	0f 85 25 09 00 00    	jne    f01024cf <mem_init+0x1207>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101baa:	83 ec 04             	sub    $0x4,%esp
f0101bad:	6a 00                	push   $0x0
f0101baf:	68 00 10 00 00       	push   $0x1000
f0101bb4:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101bba:	e8 2d f4 ff ff       	call   f0100fec <pgdir_walk>
f0101bbf:	83 c4 10             	add    $0x10,%esp
f0101bc2:	f6 00 04             	testb  $0x4,(%eax)
f0101bc5:	0f 85 1d 09 00 00    	jne    f01024e8 <mem_init+0x1220>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bcb:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101bd1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bd6:	89 f8                	mov    %edi,%eax
f0101bd8:	e8 0e ef ff ff       	call   f0100aeb <check_va2pa>
f0101bdd:	89 c1                	mov    %eax,%ecx
f0101bdf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101be2:	89 d8                	mov    %ebx,%eax
f0101be4:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101bea:	c1 f8 03             	sar    $0x3,%eax
f0101bed:	c1 e0 0c             	shl    $0xc,%eax
f0101bf0:	39 c1                	cmp    %eax,%ecx
f0101bf2:	0f 85 09 09 00 00    	jne    f0102501 <mem_init+0x1239>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bf8:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bfd:	89 f8                	mov    %edi,%eax
f0101bff:	e8 e7 ee ff ff       	call   f0100aeb <check_va2pa>
f0101c04:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101c07:	0f 85 0d 09 00 00    	jne    f010251a <mem_init+0x1252>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c0d:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101c12:	0f 85 1b 09 00 00    	jne    f0102533 <mem_init+0x126b>
	assert(pp2->pp_ref == 0);
f0101c18:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c1d:	0f 85 29 09 00 00    	jne    f010254c <mem_init+0x1284>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c23:	83 ec 0c             	sub    $0xc,%esp
f0101c26:	6a 00                	push   $0x0
f0101c28:	e8 e9 f2 ff ff       	call   f0100f16 <page_alloc>
f0101c2d:	83 c4 10             	add    $0x10,%esp
f0101c30:	39 c6                	cmp    %eax,%esi
f0101c32:	0f 85 2d 09 00 00    	jne    f0102565 <mem_init+0x129d>
f0101c38:	85 c0                	test   %eax,%eax
f0101c3a:	0f 84 25 09 00 00    	je     f0102565 <mem_init+0x129d>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c40:	83 ec 08             	sub    $0x8,%esp
f0101c43:	6a 00                	push   $0x0
f0101c45:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101c4b:	e8 4f f5 ff ff       	call   f010119f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c50:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101c56:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c5b:	89 f8                	mov    %edi,%eax
f0101c5d:	e8 89 ee ff ff       	call   f0100aeb <check_va2pa>
f0101c62:	83 c4 10             	add    $0x10,%esp
f0101c65:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c68:	0f 85 10 09 00 00    	jne    f010257e <mem_init+0x12b6>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c6e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c73:	89 f8                	mov    %edi,%eax
f0101c75:	e8 71 ee ff ff       	call   f0100aeb <check_va2pa>
f0101c7a:	89 da                	mov    %ebx,%edx
f0101c7c:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101c82:	c1 fa 03             	sar    $0x3,%edx
f0101c85:	c1 e2 0c             	shl    $0xc,%edx
f0101c88:	39 d0                	cmp    %edx,%eax
f0101c8a:	0f 85 07 09 00 00    	jne    f0102597 <mem_init+0x12cf>
	assert(pp1->pp_ref == 1);
f0101c90:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c95:	0f 85 15 09 00 00    	jne    f01025b0 <mem_init+0x12e8>
	assert(pp2->pp_ref == 0);
f0101c9b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ca0:	0f 85 23 09 00 00    	jne    f01025c9 <mem_init+0x1301>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ca6:	6a 00                	push   $0x0
f0101ca8:	68 00 10 00 00       	push   $0x1000
f0101cad:	53                   	push   %ebx
f0101cae:	57                   	push   %edi
f0101caf:	e8 33 f5 ff ff       	call   f01011e7 <page_insert>
f0101cb4:	83 c4 10             	add    $0x10,%esp
f0101cb7:	85 c0                	test   %eax,%eax
f0101cb9:	0f 85 23 09 00 00    	jne    f01025e2 <mem_init+0x131a>
	assert(pp1->pp_ref);
f0101cbf:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cc4:	0f 84 31 09 00 00    	je     f01025fb <mem_init+0x1333>
	assert(pp1->pp_link == NULL);
f0101cca:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101ccd:	0f 85 41 09 00 00    	jne    f0102614 <mem_init+0x134c>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101cd3:	83 ec 08             	sub    $0x8,%esp
f0101cd6:	68 00 10 00 00       	push   $0x1000
f0101cdb:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101ce1:	e8 b9 f4 ff ff       	call   f010119f <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ce6:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101cec:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cf1:	89 f8                	mov    %edi,%eax
f0101cf3:	e8 f3 ed ff ff       	call   f0100aeb <check_va2pa>
f0101cf8:	83 c4 10             	add    $0x10,%esp
f0101cfb:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cfe:	0f 85 29 09 00 00    	jne    f010262d <mem_init+0x1365>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d04:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d09:	89 f8                	mov    %edi,%eax
f0101d0b:	e8 db ed ff ff       	call   f0100aeb <check_va2pa>
f0101d10:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d13:	0f 85 2d 09 00 00    	jne    f0102646 <mem_init+0x137e>
	assert(pp1->pp_ref == 0);
f0101d19:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d1e:	0f 85 3b 09 00 00    	jne    f010265f <mem_init+0x1397>
	assert(pp2->pp_ref == 0);
f0101d24:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101d29:	0f 85 49 09 00 00    	jne    f0102678 <mem_init+0x13b0>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d2f:	83 ec 0c             	sub    $0xc,%esp
f0101d32:	6a 00                	push   $0x0
f0101d34:	e8 dd f1 ff ff       	call   f0100f16 <page_alloc>
f0101d39:	83 c4 10             	add    $0x10,%esp
f0101d3c:	85 c0                	test   %eax,%eax
f0101d3e:	0f 84 4d 09 00 00    	je     f0102691 <mem_init+0x13c9>
f0101d44:	39 c3                	cmp    %eax,%ebx
f0101d46:	0f 85 45 09 00 00    	jne    f0102691 <mem_init+0x13c9>

	// should be no free memory
	assert(!page_alloc(0));
f0101d4c:	83 ec 0c             	sub    $0xc,%esp
f0101d4f:	6a 00                	push   $0x0
f0101d51:	e8 c0 f1 ff ff       	call   f0100f16 <page_alloc>
f0101d56:	83 c4 10             	add    $0x10,%esp
f0101d59:	85 c0                	test   %eax,%eax
f0101d5b:	0f 85 49 09 00 00    	jne    f01026aa <mem_init+0x13e2>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d61:	8b 0d 8c 4e 23 f0    	mov    0xf0234e8c,%ecx
f0101d67:	8b 11                	mov    (%ecx),%edx
f0101d69:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d6f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d72:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101d78:	c1 f8 03             	sar    $0x3,%eax
f0101d7b:	c1 e0 0c             	shl    $0xc,%eax
f0101d7e:	39 c2                	cmp    %eax,%edx
f0101d80:	0f 85 3d 09 00 00    	jne    f01026c3 <mem_init+0x13fb>
	kern_pgdir[0] = 0;
f0101d86:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d8c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d8f:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d94:	0f 85 42 09 00 00    	jne    f01026dc <mem_init+0x1414>
	pp0->pp_ref = 0;
f0101d9a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d9d:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101da3:	83 ec 0c             	sub    $0xc,%esp
f0101da6:	50                   	push   %eax
f0101da7:	e8 dc f1 ff ff       	call   f0100f88 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101dac:	83 c4 0c             	add    $0xc,%esp
f0101daf:	6a 01                	push   $0x1
f0101db1:	68 00 10 40 00       	push   $0x401000
f0101db6:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101dbc:	e8 2b f2 ff ff       	call   f0100fec <pgdir_walk>
f0101dc1:	89 c7                	mov    %eax,%edi
f0101dc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101dc6:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101dcb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dce:	8b 40 04             	mov    0x4(%eax),%eax
f0101dd1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0101dd6:	8b 0d 88 4e 23 f0    	mov    0xf0234e88,%ecx
f0101ddc:	89 c2                	mov    %eax,%edx
f0101dde:	c1 ea 0c             	shr    $0xc,%edx
f0101de1:	83 c4 10             	add    $0x10,%esp
f0101de4:	39 ca                	cmp    %ecx,%edx
f0101de6:	0f 83 09 09 00 00    	jae    f01026f5 <mem_init+0x142d>
	assert(ptep == ptep1 + PTX(va));
f0101dec:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101df1:	39 c7                	cmp    %eax,%edi
f0101df3:	0f 85 11 09 00 00    	jne    f010270a <mem_init+0x1442>
	kern_pgdir[PDX(va)] = 0;
f0101df9:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101dfc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101e03:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e06:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e0c:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0101e12:	c1 f8 03             	sar    $0x3,%eax
f0101e15:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0101e18:	89 c2                	mov    %eax,%edx
f0101e1a:	c1 ea 0c             	shr    $0xc,%edx
f0101e1d:	39 d1                	cmp    %edx,%ecx
f0101e1f:	0f 86 fe 08 00 00    	jbe    f0102723 <mem_init+0x145b>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e25:	83 ec 04             	sub    $0x4,%esp
f0101e28:	68 00 10 00 00       	push   $0x1000
f0101e2d:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e32:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e37:	50                   	push   %eax
f0101e38:	e8 f3 37 00 00       	call   f0105630 <memset>
	page_free(pp0);
f0101e3d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101e40:	89 3c 24             	mov    %edi,(%esp)
f0101e43:	e8 40 f1 ff ff       	call   f0100f88 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e48:	83 c4 0c             	add    $0xc,%esp
f0101e4b:	6a 01                	push   $0x1
f0101e4d:	6a 00                	push   $0x0
f0101e4f:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101e55:	e8 92 f1 ff ff       	call   f0100fec <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e5a:	89 fa                	mov    %edi,%edx
f0101e5c:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f0101e62:	c1 fa 03             	sar    $0x3,%edx
f0101e65:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e68:	89 d0                	mov    %edx,%eax
f0101e6a:	c1 e8 0c             	shr    $0xc,%eax
f0101e6d:	83 c4 10             	add    $0x10,%esp
f0101e70:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f0101e76:	0f 83 b9 08 00 00    	jae    f0102735 <mem_init+0x146d>
	return (void *)(pa + KERNBASE);
f0101e7c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101e82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101e85:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e8b:	f6 00 01             	testb  $0x1,(%eax)
f0101e8e:	0f 85 b3 08 00 00    	jne    f0102747 <mem_init+0x147f>
f0101e94:	83 c0 04             	add    $0x4,%eax
	for(i=0; i<NPTENTRIES; i++)
f0101e97:	39 d0                	cmp    %edx,%eax
f0101e99:	75 f0                	jne    f0101e8b <mem_init+0xbc3>
	kern_pgdir[0] = 0;
f0101e9b:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0101ea0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101ea6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ea9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101eaf:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101eb2:	89 0d 40 42 23 f0    	mov    %ecx,0xf0234240

	// free the pages we took
	page_free(pp0);
f0101eb8:	83 ec 0c             	sub    $0xc,%esp
f0101ebb:	50                   	push   %eax
f0101ebc:	e8 c7 f0 ff ff       	call   f0100f88 <page_free>
	page_free(pp1);
f0101ec1:	89 1c 24             	mov    %ebx,(%esp)
f0101ec4:	e8 bf f0 ff ff       	call   f0100f88 <page_free>
	page_free(pp2);
f0101ec9:	89 34 24             	mov    %esi,(%esp)
f0101ecc:	e8 b7 f0 ff ff       	call   f0100f88 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0101ed1:	83 c4 08             	add    $0x8,%esp
f0101ed4:	68 01 10 00 00       	push   $0x1001
f0101ed9:	6a 00                	push   $0x0
f0101edb:	e8 7b f3 ff ff       	call   f010125b <mmio_map_region>
f0101ee0:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0101ee2:	83 c4 08             	add    $0x8,%esp
f0101ee5:	68 00 10 00 00       	push   $0x1000
f0101eea:	6a 00                	push   $0x0
f0101eec:	e8 6a f3 ff ff       	call   f010125b <mmio_map_region>
f0101ef1:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101ef3:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101ef9:	83 c4 10             	add    $0x10,%esp
f0101efc:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f02:	0f 86 58 08 00 00    	jbe    f0102760 <mem_init+0x1498>
f0101f08:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f0d:	0f 87 4d 08 00 00    	ja     f0102760 <mem_init+0x1498>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f13:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f19:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f1f:	0f 87 54 08 00 00    	ja     f0102779 <mem_init+0x14b1>
f0101f25:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f2b:	0f 86 48 08 00 00    	jbe    f0102779 <mem_init+0x14b1>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f31:	89 da                	mov    %ebx,%edx
f0101f33:	09 f2                	or     %esi,%edx
f0101f35:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f3b:	0f 85 51 08 00 00    	jne    f0102792 <mem_init+0x14ca>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f41:	39 c6                	cmp    %eax,%esi
f0101f43:	0f 82 62 08 00 00    	jb     f01027ab <mem_init+0x14e3>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f49:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
f0101f4f:	89 da                	mov    %ebx,%edx
f0101f51:	89 f8                	mov    %edi,%eax
f0101f53:	e8 93 eb ff ff       	call   f0100aeb <check_va2pa>
f0101f58:	85 c0                	test   %eax,%eax
f0101f5a:	0f 85 64 08 00 00    	jne    f01027c4 <mem_init+0x14fc>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0101f60:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f66:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f69:	89 c2                	mov    %eax,%edx
f0101f6b:	89 f8                	mov    %edi,%eax
f0101f6d:	e8 79 eb ff ff       	call   f0100aeb <check_va2pa>
f0101f72:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f77:	0f 85 60 08 00 00    	jne    f01027dd <mem_init+0x1515>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f7d:	89 f2                	mov    %esi,%edx
f0101f7f:	89 f8                	mov    %edi,%eax
f0101f81:	e8 65 eb ff ff       	call   f0100aeb <check_va2pa>
f0101f86:	85 c0                	test   %eax,%eax
f0101f88:	0f 85 68 08 00 00    	jne    f01027f6 <mem_init+0x152e>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0101f8e:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101f94:	89 f8                	mov    %edi,%eax
f0101f96:	e8 50 eb ff ff       	call   f0100aeb <check_va2pa>
f0101f9b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f9e:	0f 85 6b 08 00 00    	jne    f010280f <mem_init+0x1547>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0101fa4:	83 ec 04             	sub    $0x4,%esp
f0101fa7:	6a 00                	push   $0x0
f0101fa9:	53                   	push   %ebx
f0101faa:	57                   	push   %edi
f0101fab:	e8 3c f0 ff ff       	call   f0100fec <pgdir_walk>
f0101fb0:	83 c4 10             	add    $0x10,%esp
f0101fb3:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fb6:	0f 84 6c 08 00 00    	je     f0102828 <mem_init+0x1560>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0101fbc:	83 ec 04             	sub    $0x4,%esp
f0101fbf:	6a 00                	push   $0x0
f0101fc1:	53                   	push   %ebx
f0101fc2:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101fc8:	e8 1f f0 ff ff       	call   f0100fec <pgdir_walk>
f0101fcd:	83 c4 10             	add    $0x10,%esp
f0101fd0:	f6 00 04             	testb  $0x4,(%eax)
f0101fd3:	0f 85 68 08 00 00    	jne    f0102841 <mem_init+0x1579>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0101fd9:	83 ec 04             	sub    $0x4,%esp
f0101fdc:	6a 00                	push   $0x0
f0101fde:	53                   	push   %ebx
f0101fdf:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101fe5:	e8 02 f0 ff ff       	call   f0100fec <pgdir_walk>
f0101fea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0101ff0:	83 c4 0c             	add    $0xc,%esp
f0101ff3:	6a 00                	push   $0x0
f0101ff5:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101ff8:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0101ffe:	e8 e9 ef ff ff       	call   f0100fec <pgdir_walk>
f0102003:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102009:	83 c4 0c             	add    $0xc,%esp
f010200c:	6a 00                	push   $0x0
f010200e:	56                   	push   %esi
f010200f:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102015:	e8 d2 ef ff ff       	call   f0100fec <pgdir_walk>
f010201a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102020:	c7 04 24 32 74 10 f0 	movl   $0xf0107432,(%esp)
f0102027:	e8 b1 18 00 00       	call   f01038dd <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010202c:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
	if ((uint32_t)kva < KERNBASE)
f0102031:	83 c4 10             	add    $0x10,%esp
f0102034:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102039:	0f 86 1b 08 00 00    	jbe    f010285a <mem_init+0x1592>
f010203f:	83 ec 08             	sub    $0x8,%esp
f0102042:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102044:	05 00 00 00 10       	add    $0x10000000,%eax
f0102049:	50                   	push   %eax
f010204a:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010204f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102054:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0102059:	e8 21 f0 ff ff       	call   f010107f <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010205e:	a1 44 42 23 f0       	mov    0xf0234244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102063:	83 c4 10             	add    $0x10,%esp
f0102066:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010206b:	0f 86 fe 07 00 00    	jbe    f010286f <mem_init+0x15a7>
f0102071:	83 ec 08             	sub    $0x8,%esp
f0102074:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102076:	05 00 00 00 10       	add    $0x10000000,%eax
f010207b:	50                   	push   %eax
f010207c:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102081:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102086:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f010208b:	e8 ef ef ff ff       	call   f010107f <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f0102090:	83 c4 10             	add    $0x10,%esp
f0102093:	b8 00 70 11 f0       	mov    $0xf0117000,%eax
f0102098:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010209d:	0f 86 e1 07 00 00    	jbe    f0102884 <mem_init+0x15bc>
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020a3:	83 ec 08             	sub    $0x8,%esp
f01020a6:	6a 02                	push   $0x2
f01020a8:	68 00 70 11 00       	push   $0x117000
f01020ad:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020b2:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020b7:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f01020bc:	e8 be ef ff ff       	call   f010107f <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f01020c1:	83 c4 08             	add    $0x8,%esp
f01020c4:	6a 02                	push   $0x2
f01020c6:	6a 00                	push   $0x0
f01020c8:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01020cd:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020d2:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f01020d7:	e8 a3 ef ff ff       	call   f010107f <boot_map_region>
f01020dc:	c7 45 cc 00 60 23 f0 	movl   $0xf0236000,-0x34(%ebp)
f01020e3:	bf 00 60 27 f0       	mov    $0xf0276000,%edi
f01020e8:	83 c4 10             	add    $0x10,%esp
f01020eb:	bb 00 60 23 f0       	mov    $0xf0236000,%ebx
f01020f0:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01020f5:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01020fb:	0f 86 98 07 00 00    	jbe    f0102899 <mem_init+0x15d1>
		boot_map_region(kern_pgdir, 
f0102101:	83 ec 08             	sub    $0x8,%esp
f0102104:	6a 02                	push   $0x2
f0102106:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010210c:	50                   	push   %eax
f010210d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102112:	89 f2                	mov    %esi,%edx
f0102114:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
f0102119:	e8 61 ef ff ff       	call   f010107f <boot_map_region>
f010211e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102124:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (i = 0; i < NCPU; ++i) {
f010212a:	83 c4 10             	add    $0x10,%esp
f010212d:	39 fb                	cmp    %edi,%ebx
f010212f:	75 c4                	jne    f01020f5 <mem_init+0xe2d>
	pgdir = kern_pgdir;
f0102131:	8b 3d 8c 4e 23 f0    	mov    0xf0234e8c,%edi
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102137:	a1 88 4e 23 f0       	mov    0xf0234e88,%eax
f010213c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f010213f:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102146:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010214b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010214e:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f0102153:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102156:	89 45 d0             	mov    %eax,-0x30(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102159:	8d b0 00 00 00 10    	lea    0x10000000(%eax),%esi
	for (i = 0; i < n; i += PGSIZE)
f010215f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102164:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102167:	0f 86 71 07 00 00    	jbe    f01028de <mem_init+0x1616>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010216d:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102173:	89 f8                	mov    %edi,%eax
f0102175:	e8 71 e9 ff ff       	call   f0100aeb <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f010217a:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102181:	0f 86 27 07 00 00    	jbe    f01028ae <mem_init+0x15e6>
f0102187:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f010218a:	39 d0                	cmp    %edx,%eax
f010218c:	0f 85 33 07 00 00    	jne    f01028c5 <mem_init+0x15fd>
	for (i = 0; i < n; i += PGSIZE)
f0102192:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102198:	eb ca                	jmp    f0102164 <mem_init+0xe9c>
	assert(nfree == 0);
f010219a:	68 49 73 10 f0       	push   $0xf0107349
f010219f:	68 67 71 10 f0       	push   $0xf0107167
f01021a4:	68 34 03 00 00       	push   $0x334
f01021a9:	68 41 71 10 f0       	push   $0xf0107141
f01021ae:	e8 8d de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f01021b3:	68 57 72 10 f0       	push   $0xf0107257
f01021b8:	68 67 71 10 f0       	push   $0xf0107167
f01021bd:	68 9a 03 00 00       	push   $0x39a
f01021c2:	68 41 71 10 f0       	push   $0xf0107141
f01021c7:	e8 74 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021cc:	68 6d 72 10 f0       	push   $0xf010726d
f01021d1:	68 67 71 10 f0       	push   $0xf0107167
f01021d6:	68 9b 03 00 00       	push   $0x39b
f01021db:	68 41 71 10 f0       	push   $0xf0107141
f01021e0:	e8 5b de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021e5:	68 83 72 10 f0       	push   $0xf0107283
f01021ea:	68 67 71 10 f0       	push   $0xf0107167
f01021ef:	68 9c 03 00 00       	push   $0x39c
f01021f4:	68 41 71 10 f0       	push   $0xf0107141
f01021f9:	e8 42 de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01021fe:	68 99 72 10 f0       	push   $0xf0107299
f0102203:	68 67 71 10 f0       	push   $0xf0107167
f0102208:	68 9f 03 00 00       	push   $0x39f
f010220d:	68 41 71 10 f0       	push   $0xf0107141
f0102212:	e8 29 de ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0102217:	68 64 69 10 f0       	push   $0xf0106964
f010221c:	68 67 71 10 f0       	push   $0xf0107167
f0102221:	68 a0 03 00 00       	push   $0x3a0
f0102226:	68 41 71 10 f0       	push   $0xf0107141
f010222b:	e8 10 de ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102230:	68 02 73 10 f0       	push   $0xf0107302
f0102235:	68 67 71 10 f0       	push   $0xf0107167
f010223a:	68 a7 03 00 00       	push   $0x3a7
f010223f:	68 41 71 10 f0       	push   $0xf0107141
f0102244:	e8 f7 dd ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0102249:	68 a4 69 10 f0       	push   $0xf01069a4
f010224e:	68 67 71 10 f0       	push   $0xf0107167
f0102253:	68 aa 03 00 00       	push   $0x3aa
f0102258:	68 41 71 10 f0       	push   $0xf0107141
f010225d:	e8 de dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102262:	68 dc 69 10 f0       	push   $0xf01069dc
f0102267:	68 67 71 10 f0       	push   $0xf0107167
f010226c:	68 ad 03 00 00       	push   $0x3ad
f0102271:	68 41 71 10 f0       	push   $0xf0107141
f0102276:	e8 c5 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010227b:	68 0c 6a 10 f0       	push   $0xf0106a0c
f0102280:	68 67 71 10 f0       	push   $0xf0107167
f0102285:	68 b1 03 00 00       	push   $0x3b1
f010228a:	68 41 71 10 f0       	push   $0xf0107141
f010228f:	e8 ac dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102294:	68 3c 6a 10 f0       	push   $0xf0106a3c
f0102299:	68 67 71 10 f0       	push   $0xf0107167
f010229e:	68 b2 03 00 00       	push   $0x3b2
f01022a3:	68 41 71 10 f0       	push   $0xf0107141
f01022a8:	e8 93 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01022ad:	68 64 6a 10 f0       	push   $0xf0106a64
f01022b2:	68 67 71 10 f0       	push   $0xf0107167
f01022b7:	68 b3 03 00 00       	push   $0x3b3
f01022bc:	68 41 71 10 f0       	push   $0xf0107141
f01022c1:	e8 7a dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022c6:	68 54 73 10 f0       	push   $0xf0107354
f01022cb:	68 67 71 10 f0       	push   $0xf0107167
f01022d0:	68 b4 03 00 00       	push   $0x3b4
f01022d5:	68 41 71 10 f0       	push   $0xf0107141
f01022da:	e8 61 dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01022df:	68 65 73 10 f0       	push   $0xf0107365
f01022e4:	68 67 71 10 f0       	push   $0xf0107167
f01022e9:	68 b5 03 00 00       	push   $0x3b5
f01022ee:	68 41 71 10 f0       	push   $0xf0107141
f01022f3:	e8 48 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01022f8:	68 94 6a 10 f0       	push   $0xf0106a94
f01022fd:	68 67 71 10 f0       	push   $0xf0107167
f0102302:	68 b8 03 00 00       	push   $0x3b8
f0102307:	68 41 71 10 f0       	push   $0xf0107141
f010230c:	e8 2f dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102311:	68 d0 6a 10 f0       	push   $0xf0106ad0
f0102316:	68 67 71 10 f0       	push   $0xf0107167
f010231b:	68 b9 03 00 00       	push   $0x3b9
f0102320:	68 41 71 10 f0       	push   $0xf0107141
f0102325:	e8 16 dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010232a:	68 76 73 10 f0       	push   $0xf0107376
f010232f:	68 67 71 10 f0       	push   $0xf0107167
f0102334:	68 ba 03 00 00       	push   $0x3ba
f0102339:	68 41 71 10 f0       	push   $0xf0107141
f010233e:	e8 fd dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102343:	68 02 73 10 f0       	push   $0xf0107302
f0102348:	68 67 71 10 f0       	push   $0xf0107167
f010234d:	68 bd 03 00 00       	push   $0x3bd
f0102352:	68 41 71 10 f0       	push   $0xf0107141
f0102357:	e8 e4 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010235c:	68 94 6a 10 f0       	push   $0xf0106a94
f0102361:	68 67 71 10 f0       	push   $0xf0107167
f0102366:	68 c0 03 00 00       	push   $0x3c0
f010236b:	68 41 71 10 f0       	push   $0xf0107141
f0102370:	e8 cb dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102375:	68 d0 6a 10 f0       	push   $0xf0106ad0
f010237a:	68 67 71 10 f0       	push   $0xf0107167
f010237f:	68 c1 03 00 00       	push   $0x3c1
f0102384:	68 41 71 10 f0       	push   $0xf0107141
f0102389:	e8 b2 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f010238e:	68 76 73 10 f0       	push   $0xf0107376
f0102393:	68 67 71 10 f0       	push   $0xf0107167
f0102398:	68 c2 03 00 00       	push   $0x3c2
f010239d:	68 41 71 10 f0       	push   $0xf0107141
f01023a2:	e8 99 dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01023a7:	68 02 73 10 f0       	push   $0xf0107302
f01023ac:	68 67 71 10 f0       	push   $0xf0107167
f01023b1:	68 c6 03 00 00       	push   $0x3c6
f01023b6:	68 41 71 10 f0       	push   $0xf0107141
f01023bb:	e8 80 dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023c0:	50                   	push   %eax
f01023c1:	68 c4 62 10 f0       	push   $0xf01062c4
f01023c6:	68 c9 03 00 00       	push   $0x3c9
f01023cb:	68 41 71 10 f0       	push   $0xf0107141
f01023d0:	e8 6b dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01023d5:	68 00 6b 10 f0       	push   $0xf0106b00
f01023da:	68 67 71 10 f0       	push   $0xf0107167
f01023df:	68 ca 03 00 00       	push   $0x3ca
f01023e4:	68 41 71 10 f0       	push   $0xf0107141
f01023e9:	e8 52 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01023ee:	68 40 6b 10 f0       	push   $0xf0106b40
f01023f3:	68 67 71 10 f0       	push   $0xf0107167
f01023f8:	68 cd 03 00 00       	push   $0x3cd
f01023fd:	68 41 71 10 f0       	push   $0xf0107141
f0102402:	e8 39 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102407:	68 d0 6a 10 f0       	push   $0xf0106ad0
f010240c:	68 67 71 10 f0       	push   $0xf0107167
f0102411:	68 ce 03 00 00       	push   $0x3ce
f0102416:	68 41 71 10 f0       	push   $0xf0107141
f010241b:	e8 20 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102420:	68 76 73 10 f0       	push   $0xf0107376
f0102425:	68 67 71 10 f0       	push   $0xf0107167
f010242a:	68 cf 03 00 00       	push   $0x3cf
f010242f:	68 41 71 10 f0       	push   $0xf0107141
f0102434:	e8 07 dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0102439:	68 80 6b 10 f0       	push   $0xf0106b80
f010243e:	68 67 71 10 f0       	push   $0xf0107167
f0102443:	68 d0 03 00 00       	push   $0x3d0
f0102448:	68 41 71 10 f0       	push   $0xf0107141
f010244d:	e8 ee db ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0102452:	68 87 73 10 f0       	push   $0xf0107387
f0102457:	68 67 71 10 f0       	push   $0xf0107167
f010245c:	68 d1 03 00 00       	push   $0x3d1
f0102461:	68 41 71 10 f0       	push   $0xf0107141
f0102466:	e8 d5 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010246b:	68 94 6a 10 f0       	push   $0xf0106a94
f0102470:	68 67 71 10 f0       	push   $0xf0107167
f0102475:	68 d4 03 00 00       	push   $0x3d4
f010247a:	68 41 71 10 f0       	push   $0xf0107141
f010247f:	e8 bc db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102484:	68 b4 6b 10 f0       	push   $0xf0106bb4
f0102489:	68 67 71 10 f0       	push   $0xf0107167
f010248e:	68 d5 03 00 00       	push   $0x3d5
f0102493:	68 41 71 10 f0       	push   $0xf0107141
f0102498:	e8 a3 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010249d:	68 e8 6b 10 f0       	push   $0xf0106be8
f01024a2:	68 67 71 10 f0       	push   $0xf0107167
f01024a7:	68 d6 03 00 00       	push   $0x3d6
f01024ac:	68 41 71 10 f0       	push   $0xf0107141
f01024b1:	e8 8a db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01024b6:	68 20 6c 10 f0       	push   $0xf0106c20
f01024bb:	68 67 71 10 f0       	push   $0xf0107167
f01024c0:	68 d9 03 00 00       	push   $0x3d9
f01024c5:	68 41 71 10 f0       	push   $0xf0107141
f01024ca:	e8 71 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01024cf:	68 58 6c 10 f0       	push   $0xf0106c58
f01024d4:	68 67 71 10 f0       	push   $0xf0107167
f01024d9:	68 dc 03 00 00       	push   $0x3dc
f01024de:	68 41 71 10 f0       	push   $0xf0107141
f01024e3:	e8 58 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01024e8:	68 e8 6b 10 f0       	push   $0xf0106be8
f01024ed:	68 67 71 10 f0       	push   $0xf0107167
f01024f2:	68 dd 03 00 00       	push   $0x3dd
f01024f7:	68 41 71 10 f0       	push   $0xf0107141
f01024fc:	e8 3f db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102501:	68 94 6c 10 f0       	push   $0xf0106c94
f0102506:	68 67 71 10 f0       	push   $0xf0107167
f010250b:	68 e0 03 00 00       	push   $0x3e0
f0102510:	68 41 71 10 f0       	push   $0xf0107141
f0102515:	e8 26 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010251a:	68 c0 6c 10 f0       	push   $0xf0106cc0
f010251f:	68 67 71 10 f0       	push   $0xf0107167
f0102524:	68 e1 03 00 00       	push   $0x3e1
f0102529:	68 41 71 10 f0       	push   $0xf0107141
f010252e:	e8 0d db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f0102533:	68 9d 73 10 f0       	push   $0xf010739d
f0102538:	68 67 71 10 f0       	push   $0xf0107167
f010253d:	68 e3 03 00 00       	push   $0x3e3
f0102542:	68 41 71 10 f0       	push   $0xf0107141
f0102547:	e8 f4 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010254c:	68 ae 73 10 f0       	push   $0xf01073ae
f0102551:	68 67 71 10 f0       	push   $0xf0107167
f0102556:	68 e4 03 00 00       	push   $0x3e4
f010255b:	68 41 71 10 f0       	push   $0xf0107141
f0102560:	e8 db da ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102565:	68 f0 6c 10 f0       	push   $0xf0106cf0
f010256a:	68 67 71 10 f0       	push   $0xf0107167
f010256f:	68 e7 03 00 00       	push   $0x3e7
f0102574:	68 41 71 10 f0       	push   $0xf0107141
f0102579:	e8 c2 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010257e:	68 14 6d 10 f0       	push   $0xf0106d14
f0102583:	68 67 71 10 f0       	push   $0xf0107167
f0102588:	68 eb 03 00 00       	push   $0x3eb
f010258d:	68 41 71 10 f0       	push   $0xf0107141
f0102592:	e8 a9 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102597:	68 c0 6c 10 f0       	push   $0xf0106cc0
f010259c:	68 67 71 10 f0       	push   $0xf0107167
f01025a1:	68 ec 03 00 00       	push   $0x3ec
f01025a6:	68 41 71 10 f0       	push   $0xf0107141
f01025ab:	e8 90 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01025b0:	68 54 73 10 f0       	push   $0xf0107354
f01025b5:	68 67 71 10 f0       	push   $0xf0107167
f01025ba:	68 ed 03 00 00       	push   $0x3ed
f01025bf:	68 41 71 10 f0       	push   $0xf0107141
f01025c4:	e8 77 da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025c9:	68 ae 73 10 f0       	push   $0xf01073ae
f01025ce:	68 67 71 10 f0       	push   $0xf0107167
f01025d3:	68 ee 03 00 00       	push   $0x3ee
f01025d8:	68 41 71 10 f0       	push   $0xf0107141
f01025dd:	e8 5e da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01025e2:	68 38 6d 10 f0       	push   $0xf0106d38
f01025e7:	68 67 71 10 f0       	push   $0xf0107167
f01025ec:	68 f1 03 00 00       	push   $0x3f1
f01025f1:	68 41 71 10 f0       	push   $0xf0107141
f01025f6:	e8 45 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025fb:	68 bf 73 10 f0       	push   $0xf01073bf
f0102600:	68 67 71 10 f0       	push   $0xf0107167
f0102605:	68 f2 03 00 00       	push   $0x3f2
f010260a:	68 41 71 10 f0       	push   $0xf0107141
f010260f:	e8 2c da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102614:	68 cb 73 10 f0       	push   $0xf01073cb
f0102619:	68 67 71 10 f0       	push   $0xf0107167
f010261e:	68 f3 03 00 00       	push   $0x3f3
f0102623:	68 41 71 10 f0       	push   $0xf0107141
f0102628:	e8 13 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010262d:	68 14 6d 10 f0       	push   $0xf0106d14
f0102632:	68 67 71 10 f0       	push   $0xf0107167
f0102637:	68 f7 03 00 00       	push   $0x3f7
f010263c:	68 41 71 10 f0       	push   $0xf0107141
f0102641:	e8 fa d9 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102646:	68 70 6d 10 f0       	push   $0xf0106d70
f010264b:	68 67 71 10 f0       	push   $0xf0107167
f0102650:	68 f8 03 00 00       	push   $0x3f8
f0102655:	68 41 71 10 f0       	push   $0xf0107141
f010265a:	e8 e1 d9 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010265f:	68 e0 73 10 f0       	push   $0xf01073e0
f0102664:	68 67 71 10 f0       	push   $0xf0107167
f0102669:	68 f9 03 00 00       	push   $0x3f9
f010266e:	68 41 71 10 f0       	push   $0xf0107141
f0102673:	e8 c8 d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102678:	68 ae 73 10 f0       	push   $0xf01073ae
f010267d:	68 67 71 10 f0       	push   $0xf0107167
f0102682:	68 fa 03 00 00       	push   $0x3fa
f0102687:	68 41 71 10 f0       	push   $0xf0107141
f010268c:	e8 af d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f0102691:	68 98 6d 10 f0       	push   $0xf0106d98
f0102696:	68 67 71 10 f0       	push   $0xf0107167
f010269b:	68 fd 03 00 00       	push   $0x3fd
f01026a0:	68 41 71 10 f0       	push   $0xf0107141
f01026a5:	e8 96 d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01026aa:	68 02 73 10 f0       	push   $0xf0107302
f01026af:	68 67 71 10 f0       	push   $0xf0107167
f01026b4:	68 00 04 00 00       	push   $0x400
f01026b9:	68 41 71 10 f0       	push   $0xf0107141
f01026be:	e8 7d d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01026c3:	68 3c 6a 10 f0       	push   $0xf0106a3c
f01026c8:	68 67 71 10 f0       	push   $0xf0107167
f01026cd:	68 03 04 00 00       	push   $0x403
f01026d2:	68 41 71 10 f0       	push   $0xf0107141
f01026d7:	e8 64 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026dc:	68 65 73 10 f0       	push   $0xf0107365
f01026e1:	68 67 71 10 f0       	push   $0xf0107167
f01026e6:	68 05 04 00 00       	push   $0x405
f01026eb:	68 41 71 10 f0       	push   $0xf0107141
f01026f0:	e8 4b d9 ff ff       	call   f0100040 <_panic>
f01026f5:	50                   	push   %eax
f01026f6:	68 c4 62 10 f0       	push   $0xf01062c4
f01026fb:	68 0c 04 00 00       	push   $0x40c
f0102700:	68 41 71 10 f0       	push   $0xf0107141
f0102705:	e8 36 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f010270a:	68 f1 73 10 f0       	push   $0xf01073f1
f010270f:	68 67 71 10 f0       	push   $0xf0107167
f0102714:	68 0d 04 00 00       	push   $0x40d
f0102719:	68 41 71 10 f0       	push   $0xf0107141
f010271e:	e8 1d d9 ff ff       	call   f0100040 <_panic>
f0102723:	50                   	push   %eax
f0102724:	68 c4 62 10 f0       	push   $0xf01062c4
f0102729:	6a 58                	push   $0x58
f010272b:	68 4d 71 10 f0       	push   $0xf010714d
f0102730:	e8 0b d9 ff ff       	call   f0100040 <_panic>
f0102735:	52                   	push   %edx
f0102736:	68 c4 62 10 f0       	push   $0xf01062c4
f010273b:	6a 58                	push   $0x58
f010273d:	68 4d 71 10 f0       	push   $0xf010714d
f0102742:	e8 f9 d8 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102747:	68 09 74 10 f0       	push   $0xf0107409
f010274c:	68 67 71 10 f0       	push   $0xf0107167
f0102751:	68 17 04 00 00       	push   $0x417
f0102756:	68 41 71 10 f0       	push   $0xf0107141
f010275b:	e8 e0 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102760:	68 bc 6d 10 f0       	push   $0xf0106dbc
f0102765:	68 67 71 10 f0       	push   $0xf0107167
f010276a:	68 27 04 00 00       	push   $0x427
f010276f:	68 41 71 10 f0       	push   $0xf0107141
f0102774:	e8 c7 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102779:	68 e4 6d 10 f0       	push   $0xf0106de4
f010277e:	68 67 71 10 f0       	push   $0xf0107167
f0102783:	68 28 04 00 00       	push   $0x428
f0102788:	68 41 71 10 f0       	push   $0xf0107141
f010278d:	e8 ae d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102792:	68 0c 6e 10 f0       	push   $0xf0106e0c
f0102797:	68 67 71 10 f0       	push   $0xf0107167
f010279c:	68 2a 04 00 00       	push   $0x42a
f01027a1:	68 41 71 10 f0       	push   $0xf0107141
f01027a6:	e8 95 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f01027ab:	68 20 74 10 f0       	push   $0xf0107420
f01027b0:	68 67 71 10 f0       	push   $0xf0107167
f01027b5:	68 2c 04 00 00       	push   $0x42c
f01027ba:	68 41 71 10 f0       	push   $0xf0107141
f01027bf:	e8 7c d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01027c4:	68 34 6e 10 f0       	push   $0xf0106e34
f01027c9:	68 67 71 10 f0       	push   $0xf0107167
f01027ce:	68 2e 04 00 00       	push   $0x42e
f01027d3:	68 41 71 10 f0       	push   $0xf0107141
f01027d8:	e8 63 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01027dd:	68 58 6e 10 f0       	push   $0xf0106e58
f01027e2:	68 67 71 10 f0       	push   $0xf0107167
f01027e7:	68 2f 04 00 00       	push   $0x42f
f01027ec:	68 41 71 10 f0       	push   $0xf0107141
f01027f1:	e8 4a d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027f6:	68 88 6e 10 f0       	push   $0xf0106e88
f01027fb:	68 67 71 10 f0       	push   $0xf0107167
f0102800:	68 30 04 00 00       	push   $0x430
f0102805:	68 41 71 10 f0       	push   $0xf0107141
f010280a:	e8 31 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010280f:	68 ac 6e 10 f0       	push   $0xf0106eac
f0102814:	68 67 71 10 f0       	push   $0xf0107167
f0102819:	68 31 04 00 00       	push   $0x431
f010281e:	68 41 71 10 f0       	push   $0xf0107141
f0102823:	e8 18 d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102828:	68 d8 6e 10 f0       	push   $0xf0106ed8
f010282d:	68 67 71 10 f0       	push   $0xf0107167
f0102832:	68 33 04 00 00       	push   $0x433
f0102837:	68 41 71 10 f0       	push   $0xf0107141
f010283c:	e8 ff d7 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102841:	68 1c 6f 10 f0       	push   $0xf0106f1c
f0102846:	68 67 71 10 f0       	push   $0xf0107167
f010284b:	68 34 04 00 00       	push   $0x434
f0102850:	68 41 71 10 f0       	push   $0xf0107141
f0102855:	e8 e6 d7 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010285a:	50                   	push   %eax
f010285b:	68 e8 62 10 f0       	push   $0xf01062e8
f0102860:	68 b8 00 00 00       	push   $0xb8
f0102865:	68 41 71 10 f0       	push   $0xf0107141
f010286a:	e8 d1 d7 ff ff       	call   f0100040 <_panic>
f010286f:	50                   	push   %eax
f0102870:	68 e8 62 10 f0       	push   $0xf01062e8
f0102875:	68 c1 00 00 00       	push   $0xc1
f010287a:	68 41 71 10 f0       	push   $0xf0107141
f010287f:	e8 bc d7 ff ff       	call   f0100040 <_panic>
f0102884:	50                   	push   %eax
f0102885:	68 e8 62 10 f0       	push   $0xf01062e8
f010288a:	68 ce 00 00 00       	push   $0xce
f010288f:	68 41 71 10 f0       	push   $0xf0107141
f0102894:	e8 a7 d7 ff ff       	call   f0100040 <_panic>
f0102899:	53                   	push   %ebx
f010289a:	68 e8 62 10 f0       	push   $0xf01062e8
f010289f:	68 11 01 00 00       	push   $0x111
f01028a4:	68 41 71 10 f0       	push   $0xf0107141
f01028a9:	e8 92 d7 ff ff       	call   f0100040 <_panic>
f01028ae:	ff 75 c4             	pushl  -0x3c(%ebp)
f01028b1:	68 e8 62 10 f0       	push   $0xf01062e8
f01028b6:	68 4c 03 00 00       	push   $0x34c
f01028bb:	68 41 71 10 f0       	push   $0xf0107141
f01028c0:	e8 7b d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028c5:	68 50 6f 10 f0       	push   $0xf0106f50
f01028ca:	68 67 71 10 f0       	push   $0xf0107167
f01028cf:	68 4c 03 00 00       	push   $0x34c
f01028d4:	68 41 71 10 f0       	push   $0xf0107141
f01028d9:	e8 62 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028de:	a1 44 42 23 f0       	mov    0xf0234244,%eax
f01028e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((uint32_t)kva < KERNBASE)
f01028e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028e9:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028ee:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f01028f4:	89 da                	mov    %ebx,%edx
f01028f6:	89 f8                	mov    %edi,%eax
f01028f8:	e8 ee e1 ff ff       	call   f0100aeb <check_va2pa>
f01028fd:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102904:	76 22                	jbe    f0102928 <mem_init+0x1660>
f0102906:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f0102909:	39 d0                	cmp    %edx,%eax
f010290b:	75 32                	jne    f010293f <mem_init+0x1677>
f010290d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102913:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f0102919:	75 d9                	jne    f01028f4 <mem_init+0x162c>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010291b:	8b 75 c8             	mov    -0x38(%ebp),%esi
f010291e:	c1 e6 0c             	shl    $0xc,%esi
f0102921:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102926:	eb 4b                	jmp    f0102973 <mem_init+0x16ab>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102928:	ff 75 d0             	pushl  -0x30(%ebp)
f010292b:	68 e8 62 10 f0       	push   $0xf01062e8
f0102930:	68 51 03 00 00       	push   $0x351
f0102935:	68 41 71 10 f0       	push   $0xf0107141
f010293a:	e8 01 d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010293f:	68 84 6f 10 f0       	push   $0xf0106f84
f0102944:	68 67 71 10 f0       	push   $0xf0107167
f0102949:	68 51 03 00 00       	push   $0x351
f010294e:	68 41 71 10 f0       	push   $0xf0107141
f0102953:	e8 e8 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102958:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010295e:	89 f8                	mov    %edi,%eax
f0102960:	e8 86 e1 ff ff       	call   f0100aeb <check_va2pa>
f0102965:	39 c3                	cmp    %eax,%ebx
f0102967:	0f 85 f9 00 00 00    	jne    f0102a66 <mem_init+0x179e>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010296d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102973:	39 f3                	cmp    %esi,%ebx
f0102975:	72 e1                	jb     f0102958 <mem_init+0x1690>
f0102977:	c7 45 d4 00 60 23 f0 	movl   $0xf0236000,-0x2c(%ebp)
f010297e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102983:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102986:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f0102989:	8d 86 00 80 00 00    	lea    0x8000(%esi),%eax
f010298f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102992:	89 f3                	mov    %esi,%ebx
f0102994:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102997:	05 00 80 00 20       	add    $0x20008000,%eax
f010299c:	89 75 c8             	mov    %esi,-0x38(%ebp)
f010299f:	89 c6                	mov    %eax,%esi
f01029a1:	89 da                	mov    %ebx,%edx
f01029a3:	89 f8                	mov    %edi,%eax
f01029a5:	e8 41 e1 ff ff       	call   f0100aeb <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029aa:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01029b1:	0f 86 c8 00 00 00    	jbe    f0102a7f <mem_init+0x17b7>
f01029b7:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f01029ba:	39 d0                	cmp    %edx,%eax
f01029bc:	0f 85 d4 00 00 00    	jne    f0102a96 <mem_init+0x17ce>
f01029c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029c8:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f01029cb:	75 d4                	jne    f01029a1 <mem_init+0x16d9>
f01029cd:	8b 75 c8             	mov    -0x38(%ebp),%esi
f01029d0:	8d 9e 00 80 ff ff    	lea    -0x8000(%esi),%ebx
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029d6:	89 da                	mov    %ebx,%edx
f01029d8:	89 f8                	mov    %edi,%eax
f01029da:	e8 0c e1 ff ff       	call   f0100aeb <check_va2pa>
f01029df:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029e2:	0f 85 c7 00 00 00    	jne    f0102aaf <mem_init+0x17e7>
f01029e8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029ee:	39 f3                	cmp    %esi,%ebx
f01029f0:	75 e4                	jne    f01029d6 <mem_init+0x170e>
f01029f2:	81 ee 00 00 01 00    	sub    $0x10000,%esi
f01029f8:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
f01029ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102a02:	81 45 d4 00 80 00 00 	addl   $0x8000,-0x2c(%ebp)
	for (n = 0; n < NCPU; n++) {
f0102a09:	3d 00 60 2f f0       	cmp    $0xf02f6000,%eax
f0102a0e:	0f 85 6f ff ff ff    	jne    f0102983 <mem_init+0x16bb>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a14:	b8 00 00 00 00       	mov    $0x0,%eax
			if (i >= PDX(KERNBASE)) {
f0102a19:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102a1e:	0f 87 a4 00 00 00    	ja     f0102ac8 <mem_init+0x1800>
				assert(pgdir[i] == 0);
f0102a24:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102a28:	0f 85 dd 00 00 00    	jne    f0102b0b <mem_init+0x1843>
	for (i = 0; i < NPDENTRIES; i++) {
f0102a2e:	83 c0 01             	add    $0x1,%eax
f0102a31:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102a36:	0f 87 e8 00 00 00    	ja     f0102b24 <mem_init+0x185c>
		switch (i) {
f0102a3c:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102a42:	83 fa 04             	cmp    $0x4,%edx
f0102a45:	77 d2                	ja     f0102a19 <mem_init+0x1751>
			assert(pgdir[i] & PTE_P);
f0102a47:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102a4b:	75 e1                	jne    f0102a2e <mem_init+0x1766>
f0102a4d:	68 4b 74 10 f0       	push   $0xf010744b
f0102a52:	68 67 71 10 f0       	push   $0xf0107167
f0102a57:	68 6a 03 00 00       	push   $0x36a
f0102a5c:	68 41 71 10 f0       	push   $0xf0107141
f0102a61:	e8 da d5 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102a66:	68 b8 6f 10 f0       	push   $0xf0106fb8
f0102a6b:	68 67 71 10 f0       	push   $0xf0107167
f0102a70:	68 55 03 00 00       	push   $0x355
f0102a75:	68 41 71 10 f0       	push   $0xf0107141
f0102a7a:	e8 c1 d5 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a7f:	ff 75 c4             	pushl  -0x3c(%ebp)
f0102a82:	68 e8 62 10 f0       	push   $0xf01062e8
f0102a87:	68 5d 03 00 00       	push   $0x35d
f0102a8c:	68 41 71 10 f0       	push   $0xf0107141
f0102a91:	e8 aa d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102a96:	68 e0 6f 10 f0       	push   $0xf0106fe0
f0102a9b:	68 67 71 10 f0       	push   $0xf0107167
f0102aa0:	68 5d 03 00 00       	push   $0x35d
f0102aa5:	68 41 71 10 f0       	push   $0xf0107141
f0102aaa:	e8 91 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102aaf:	68 28 70 10 f0       	push   $0xf0107028
f0102ab4:	68 67 71 10 f0       	push   $0xf0107167
f0102ab9:	68 5f 03 00 00       	push   $0x35f
f0102abe:	68 41 71 10 f0       	push   $0xf0107141
f0102ac3:	e8 78 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102ac8:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102acb:	f6 c2 01             	test   $0x1,%dl
f0102ace:	74 22                	je     f0102af2 <mem_init+0x182a>
				assert(pgdir[i] & PTE_W);
f0102ad0:	f6 c2 02             	test   $0x2,%dl
f0102ad3:	0f 85 55 ff ff ff    	jne    f0102a2e <mem_init+0x1766>
f0102ad9:	68 5c 74 10 f0       	push   $0xf010745c
f0102ade:	68 67 71 10 f0       	push   $0xf0107167
f0102ae3:	68 6f 03 00 00       	push   $0x36f
f0102ae8:	68 41 71 10 f0       	push   $0xf0107141
f0102aed:	e8 4e d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102af2:	68 4b 74 10 f0       	push   $0xf010744b
f0102af7:	68 67 71 10 f0       	push   $0xf0107167
f0102afc:	68 6e 03 00 00       	push   $0x36e
f0102b01:	68 41 71 10 f0       	push   $0xf0107141
f0102b06:	e8 35 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b0b:	68 6d 74 10 f0       	push   $0xf010746d
f0102b10:	68 67 71 10 f0       	push   $0xf0107167
f0102b15:	68 71 03 00 00       	push   $0x371
f0102b1a:	68 41 71 10 f0       	push   $0xf0107141
f0102b1f:	e8 1c d5 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b24:	83 ec 0c             	sub    $0xc,%esp
f0102b27:	68 4c 70 10 f0       	push   $0xf010704c
f0102b2c:	e8 ac 0d 00 00       	call   f01038dd <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b31:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b36:	83 c4 10             	add    $0x10,%esp
f0102b39:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b3e:	0f 86 fe 01 00 00    	jbe    f0102d42 <mem_init+0x1a7a>
	return (physaddr_t)kva - KERNBASE;
f0102b44:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b49:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b4c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b51:	e8 f9 df ff ff       	call   f0100b4f <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b56:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102b59:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b5c:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b61:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b64:	83 ec 0c             	sub    $0xc,%esp
f0102b67:	6a 00                	push   $0x0
f0102b69:	e8 a8 e3 ff ff       	call   f0100f16 <page_alloc>
f0102b6e:	89 c3                	mov    %eax,%ebx
f0102b70:	83 c4 10             	add    $0x10,%esp
f0102b73:	85 c0                	test   %eax,%eax
f0102b75:	0f 84 dc 01 00 00    	je     f0102d57 <mem_init+0x1a8f>
	assert((pp1 = page_alloc(0)));
f0102b7b:	83 ec 0c             	sub    $0xc,%esp
f0102b7e:	6a 00                	push   $0x0
f0102b80:	e8 91 e3 ff ff       	call   f0100f16 <page_alloc>
f0102b85:	89 c7                	mov    %eax,%edi
f0102b87:	83 c4 10             	add    $0x10,%esp
f0102b8a:	85 c0                	test   %eax,%eax
f0102b8c:	0f 84 de 01 00 00    	je     f0102d70 <mem_init+0x1aa8>
	assert((pp2 = page_alloc(0)));
f0102b92:	83 ec 0c             	sub    $0xc,%esp
f0102b95:	6a 00                	push   $0x0
f0102b97:	e8 7a e3 ff ff       	call   f0100f16 <page_alloc>
f0102b9c:	89 c6                	mov    %eax,%esi
f0102b9e:	83 c4 10             	add    $0x10,%esp
f0102ba1:	85 c0                	test   %eax,%eax
f0102ba3:	0f 84 e0 01 00 00    	je     f0102d89 <mem_init+0x1ac1>
	page_free(pp0);
f0102ba9:	83 ec 0c             	sub    $0xc,%esp
f0102bac:	53                   	push   %ebx
f0102bad:	e8 d6 e3 ff ff       	call   f0100f88 <page_free>
	return (pp - pages) << PGSHIFT;
f0102bb2:	89 f8                	mov    %edi,%eax
f0102bb4:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102bba:	c1 f8 03             	sar    $0x3,%eax
f0102bbd:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bc0:	89 c2                	mov    %eax,%edx
f0102bc2:	c1 ea 0c             	shr    $0xc,%edx
f0102bc5:	83 c4 10             	add    $0x10,%esp
f0102bc8:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0102bce:	0f 83 ce 01 00 00    	jae    f0102da2 <mem_init+0x1ada>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bd4:	83 ec 04             	sub    $0x4,%esp
f0102bd7:	68 00 10 00 00       	push   $0x1000
f0102bdc:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102bde:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102be3:	50                   	push   %eax
f0102be4:	e8 47 2a 00 00       	call   f0105630 <memset>
	return (pp - pages) << PGSHIFT;
f0102be9:	89 f0                	mov    %esi,%eax
f0102beb:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102bf1:	c1 f8 03             	sar    $0x3,%eax
f0102bf4:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102bf7:	89 c2                	mov    %eax,%edx
f0102bf9:	c1 ea 0c             	shr    $0xc,%edx
f0102bfc:	83 c4 10             	add    $0x10,%esp
f0102bff:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0102c05:	0f 83 a9 01 00 00    	jae    f0102db4 <mem_init+0x1aec>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c0b:	83 ec 04             	sub    $0x4,%esp
f0102c0e:	68 00 10 00 00       	push   $0x1000
f0102c13:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c15:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c1a:	50                   	push   %eax
f0102c1b:	e8 10 2a 00 00       	call   f0105630 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102c20:	6a 02                	push   $0x2
f0102c22:	68 00 10 00 00       	push   $0x1000
f0102c27:	57                   	push   %edi
f0102c28:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102c2e:	e8 b4 e5 ff ff       	call   f01011e7 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c33:	83 c4 20             	add    $0x20,%esp
f0102c36:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c3b:	0f 85 85 01 00 00    	jne    f0102dc6 <mem_init+0x1afe>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c41:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c48:	01 01 01 
f0102c4b:	0f 85 8e 01 00 00    	jne    f0102ddf <mem_init+0x1b17>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c51:	6a 02                	push   $0x2
f0102c53:	68 00 10 00 00       	push   $0x1000
f0102c58:	56                   	push   %esi
f0102c59:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102c5f:	e8 83 e5 ff ff       	call   f01011e7 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c64:	83 c4 10             	add    $0x10,%esp
f0102c67:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c6e:	02 02 02 
f0102c71:	0f 85 81 01 00 00    	jne    f0102df8 <mem_init+0x1b30>
	assert(pp2->pp_ref == 1);
f0102c77:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c7c:	0f 85 8f 01 00 00    	jne    f0102e11 <mem_init+0x1b49>
	assert(pp1->pp_ref == 0);
f0102c82:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c87:	0f 85 9d 01 00 00    	jne    f0102e2a <mem_init+0x1b62>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c8d:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c94:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c97:	89 f0                	mov    %esi,%eax
f0102c99:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102c9f:	c1 f8 03             	sar    $0x3,%eax
f0102ca2:	c1 e0 0c             	shl    $0xc,%eax
	if (PGNUM(pa) >= npages)
f0102ca5:	89 c2                	mov    %eax,%edx
f0102ca7:	c1 ea 0c             	shr    $0xc,%edx
f0102caa:	3b 15 88 4e 23 f0    	cmp    0xf0234e88,%edx
f0102cb0:	0f 83 8d 01 00 00    	jae    f0102e43 <mem_init+0x1b7b>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cb6:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102cbd:	03 03 03 
f0102cc0:	0f 85 8f 01 00 00    	jne    f0102e55 <mem_init+0x1b8d>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cc6:	83 ec 08             	sub    $0x8,%esp
f0102cc9:	68 00 10 00 00       	push   $0x1000
f0102cce:	ff 35 8c 4e 23 f0    	pushl  0xf0234e8c
f0102cd4:	e8 c6 e4 ff ff       	call   f010119f <page_remove>
	assert(pp2->pp_ref == 0);
f0102cd9:	83 c4 10             	add    $0x10,%esp
f0102cdc:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102ce1:	0f 85 87 01 00 00    	jne    f0102e6e <mem_init+0x1ba6>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ce7:	8b 0d 8c 4e 23 f0    	mov    0xf0234e8c,%ecx
f0102ced:	8b 11                	mov    (%ecx),%edx
f0102cef:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102cf5:	89 d8                	mov    %ebx,%eax
f0102cf7:	2b 05 90 4e 23 f0    	sub    0xf0234e90,%eax
f0102cfd:	c1 f8 03             	sar    $0x3,%eax
f0102d00:	c1 e0 0c             	shl    $0xc,%eax
f0102d03:	39 c2                	cmp    %eax,%edx
f0102d05:	0f 85 7c 01 00 00    	jne    f0102e87 <mem_init+0x1bbf>
	kern_pgdir[0] = 0;
f0102d0b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d11:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102d16:	0f 85 84 01 00 00    	jne    f0102ea0 <mem_init+0x1bd8>
	pp0->pp_ref = 0;
f0102d1c:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102d22:	83 ec 0c             	sub    $0xc,%esp
f0102d25:	53                   	push   %ebx
f0102d26:	e8 5d e2 ff ff       	call   f0100f88 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d2b:	c7 04 24 e0 70 10 f0 	movl   $0xf01070e0,(%esp)
f0102d32:	e8 a6 0b 00 00       	call   f01038dd <cprintf>
}
f0102d37:	83 c4 10             	add    $0x10,%esp
f0102d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d3d:	5b                   	pop    %ebx
f0102d3e:	5e                   	pop    %esi
f0102d3f:	5f                   	pop    %edi
f0102d40:	5d                   	pop    %ebp
f0102d41:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d42:	50                   	push   %eax
f0102d43:	68 e8 62 10 f0       	push   $0xf01062e8
f0102d48:	68 e7 00 00 00       	push   $0xe7
f0102d4d:	68 41 71 10 f0       	push   $0xf0107141
f0102d52:	e8 e9 d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d57:	68 57 72 10 f0       	push   $0xf0107257
f0102d5c:	68 67 71 10 f0       	push   $0xf0107167
f0102d61:	68 49 04 00 00       	push   $0x449
f0102d66:	68 41 71 10 f0       	push   $0xf0107141
f0102d6b:	e8 d0 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d70:	68 6d 72 10 f0       	push   $0xf010726d
f0102d75:	68 67 71 10 f0       	push   $0xf0107167
f0102d7a:	68 4a 04 00 00       	push   $0x44a
f0102d7f:	68 41 71 10 f0       	push   $0xf0107141
f0102d84:	e8 b7 d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d89:	68 83 72 10 f0       	push   $0xf0107283
f0102d8e:	68 67 71 10 f0       	push   $0xf0107167
f0102d93:	68 4b 04 00 00       	push   $0x44b
f0102d98:	68 41 71 10 f0       	push   $0xf0107141
f0102d9d:	e8 9e d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102da2:	50                   	push   %eax
f0102da3:	68 c4 62 10 f0       	push   $0xf01062c4
f0102da8:	6a 58                	push   $0x58
f0102daa:	68 4d 71 10 f0       	push   $0xf010714d
f0102daf:	e8 8c d2 ff ff       	call   f0100040 <_panic>
f0102db4:	50                   	push   %eax
f0102db5:	68 c4 62 10 f0       	push   $0xf01062c4
f0102dba:	6a 58                	push   $0x58
f0102dbc:	68 4d 71 10 f0       	push   $0xf010714d
f0102dc1:	e8 7a d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102dc6:	68 54 73 10 f0       	push   $0xf0107354
f0102dcb:	68 67 71 10 f0       	push   $0xf0107167
f0102dd0:	68 50 04 00 00       	push   $0x450
f0102dd5:	68 41 71 10 f0       	push   $0xf0107141
f0102dda:	e8 61 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ddf:	68 6c 70 10 f0       	push   $0xf010706c
f0102de4:	68 67 71 10 f0       	push   $0xf0107167
f0102de9:	68 51 04 00 00       	push   $0x451
f0102dee:	68 41 71 10 f0       	push   $0xf0107141
f0102df3:	e8 48 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102df8:	68 90 70 10 f0       	push   $0xf0107090
f0102dfd:	68 67 71 10 f0       	push   $0xf0107167
f0102e02:	68 53 04 00 00       	push   $0x453
f0102e07:	68 41 71 10 f0       	push   $0xf0107141
f0102e0c:	e8 2f d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e11:	68 76 73 10 f0       	push   $0xf0107376
f0102e16:	68 67 71 10 f0       	push   $0xf0107167
f0102e1b:	68 54 04 00 00       	push   $0x454
f0102e20:	68 41 71 10 f0       	push   $0xf0107141
f0102e25:	e8 16 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e2a:	68 e0 73 10 f0       	push   $0xf01073e0
f0102e2f:	68 67 71 10 f0       	push   $0xf0107167
f0102e34:	68 55 04 00 00       	push   $0x455
f0102e39:	68 41 71 10 f0       	push   $0xf0107141
f0102e3e:	e8 fd d1 ff ff       	call   f0100040 <_panic>
f0102e43:	50                   	push   %eax
f0102e44:	68 c4 62 10 f0       	push   $0xf01062c4
f0102e49:	6a 58                	push   $0x58
f0102e4b:	68 4d 71 10 f0       	push   $0xf010714d
f0102e50:	e8 eb d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e55:	68 b4 70 10 f0       	push   $0xf01070b4
f0102e5a:	68 67 71 10 f0       	push   $0xf0107167
f0102e5f:	68 57 04 00 00       	push   $0x457
f0102e64:	68 41 71 10 f0       	push   $0xf0107141
f0102e69:	e8 d2 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102e6e:	68 ae 73 10 f0       	push   $0xf01073ae
f0102e73:	68 67 71 10 f0       	push   $0xf0107167
f0102e78:	68 59 04 00 00       	push   $0x459
f0102e7d:	68 41 71 10 f0       	push   $0xf0107141
f0102e82:	e8 b9 d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e87:	68 3c 6a 10 f0       	push   $0xf0106a3c
f0102e8c:	68 67 71 10 f0       	push   $0xf0107167
f0102e91:	68 5c 04 00 00       	push   $0x45c
f0102e96:	68 41 71 10 f0       	push   $0xf0107141
f0102e9b:	e8 a0 d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102ea0:	68 65 73 10 f0       	push   $0xf0107365
f0102ea5:	68 67 71 10 f0       	push   $0xf0107167
f0102eaa:	68 5e 04 00 00       	push   $0x45e
f0102eaf:	68 41 71 10 f0       	push   $0xf0107141
f0102eb4:	e8 87 d1 ff ff       	call   f0100040 <_panic>

f0102eb9 <user_mem_check>:
{
f0102eb9:	55                   	push   %ebp
f0102eba:	89 e5                	mov    %esp,%ebp
f0102ebc:	57                   	push   %edi
f0102ebd:	56                   	push   %esi
f0102ebe:	53                   	push   %ebx
f0102ebf:	83 ec 0c             	sub    $0xc,%esp
f0102ec2:	8b 75 14             	mov    0x14(%ebp),%esi
    	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f0102ec5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ec8:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	uint32_t end = (uint32_t) ROUNDUP(va+len, PGSIZE);
f0102ece:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102ed1:	03 7d 10             	add    0x10(%ebp),%edi
f0102ed4:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102eda:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    	for (i = (uint32_t)begin; i < end; i += PGSIZE) {
f0102ee0:	39 fb                	cmp    %edi,%ebx
f0102ee2:	73 4e                	jae    f0102f32 <user_mem_check+0x79>
        	pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f0102ee4:	83 ec 04             	sub    $0x4,%esp
f0102ee7:	6a 00                	push   $0x0
f0102ee9:	53                   	push   %ebx
f0102eea:	8b 45 08             	mov    0x8(%ebp),%eax
f0102eed:	ff 70 60             	pushl  0x60(%eax)
f0102ef0:	e8 f7 e0 ff ff       	call   f0100fec <pgdir_walk>
        	if ((i >= ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {        
f0102ef5:	83 c4 10             	add    $0x10,%esp
f0102ef8:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102efe:	77 18                	ja     f0102f18 <user_mem_check+0x5f>
f0102f00:	85 c0                	test   %eax,%eax
f0102f02:	74 14                	je     f0102f18 <user_mem_check+0x5f>
f0102f04:	8b 00                	mov    (%eax),%eax
f0102f06:	a8 01                	test   $0x1,%al
f0102f08:	74 0e                	je     f0102f18 <user_mem_check+0x5f>
f0102f0a:	21 f0                	and    %esi,%eax
f0102f0c:	39 c6                	cmp    %eax,%esi
f0102f0e:	75 08                	jne    f0102f18 <user_mem_check+0x5f>
    	for (i = (uint32_t)begin; i < end; i += PGSIZE) {
f0102f10:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f16:	eb c8                	jmp    f0102ee0 <user_mem_check+0x27>
            		user_mem_check_addr = (i < (uint32_t)va ? (uint32_t)va : i);
f0102f18:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102f1b:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102f1f:	89 1d 3c 42 23 f0    	mov    %ebx,0xf023423c
            	return -E_FAULT;
f0102f25:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f2d:	5b                   	pop    %ebx
f0102f2e:	5e                   	pop    %esi
f0102f2f:	5f                   	pop    %edi
f0102f30:	5d                   	pop    %ebp
f0102f31:	c3                   	ret    
	return 0;
f0102f32:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f37:	eb f1                	jmp    f0102f2a <user_mem_check+0x71>

f0102f39 <user_mem_assert>:
{
f0102f39:	55                   	push   %ebp
f0102f3a:	89 e5                	mov    %esp,%ebp
f0102f3c:	53                   	push   %ebx
f0102f3d:	83 ec 04             	sub    $0x4,%esp
f0102f40:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102f43:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f46:	83 c8 04             	or     $0x4,%eax
f0102f49:	50                   	push   %eax
f0102f4a:	ff 75 10             	pushl  0x10(%ebp)
f0102f4d:	ff 75 0c             	pushl  0xc(%ebp)
f0102f50:	53                   	push   %ebx
f0102f51:	e8 63 ff ff ff       	call   f0102eb9 <user_mem_check>
f0102f56:	83 c4 10             	add    $0x10,%esp
f0102f59:	85 c0                	test   %eax,%eax
f0102f5b:	78 05                	js     f0102f62 <user_mem_assert+0x29>
}
f0102f5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f60:	c9                   	leave  
f0102f61:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f62:	83 ec 04             	sub    $0x4,%esp
f0102f65:	ff 35 3c 42 23 f0    	pushl  0xf023423c
f0102f6b:	ff 73 48             	pushl  0x48(%ebx)
f0102f6e:	68 0c 71 10 f0       	push   $0xf010710c
f0102f73:	e8 65 09 00 00       	call   f01038dd <cprintf>
		env_destroy(env);	// may not return
f0102f78:	89 1c 24             	mov    %ebx,(%esp)
f0102f7b:	e8 61 06 00 00       	call   f01035e1 <env_destroy>
f0102f80:	83 c4 10             	add    $0x10,%esp
}
f0102f83:	eb d8                	jmp    f0102f5d <user_mem_assert+0x24>

f0102f85 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f85:	55                   	push   %ebp
f0102f86:	89 e5                	mov    %esp,%ebp
f0102f88:	57                   	push   %edi
f0102f89:	56                   	push   %esi
f0102f8a:	53                   	push   %ebx
f0102f8b:	83 ec 0c             	sub    $0xc,%esp
f0102f8e:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void* start = (void *)ROUNDDOWN((uint32_t)va, PGSIZE);
f0102f90:	89 d3                	mov    %edx,%ebx
f0102f92:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    	void* end = (void *)ROUNDUP((uint32_t)va+len, PGSIZE);
f0102f98:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102f9f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    	struct PageInfo *p = NULL;
    	void* i;
    	int r;
    	for(i = start; i < end; i += PGSIZE){
f0102fa5:	39 f3                	cmp    %esi,%ebx
f0102fa7:	73 5a                	jae    f0103003 <region_alloc+0x7e>
        	p = page_alloc(0);
f0102fa9:	83 ec 0c             	sub    $0xc,%esp
f0102fac:	6a 00                	push   $0x0
f0102fae:	e8 63 df ff ff       	call   f0100f16 <page_alloc>
        	if(p == NULL)
f0102fb3:	83 c4 10             	add    $0x10,%esp
f0102fb6:	85 c0                	test   %eax,%eax
f0102fb8:	74 1b                	je     f0102fd5 <region_alloc+0x50>
           		panic(" region alloc failed: allocation failed.\n");

        	r = page_insert(e->env_pgdir, p, i, PTE_W | PTE_U);
f0102fba:	6a 06                	push   $0x6
f0102fbc:	53                   	push   %ebx
f0102fbd:	50                   	push   %eax
f0102fbe:	ff 77 60             	pushl  0x60(%edi)
f0102fc1:	e8 21 e2 ff ff       	call   f01011e7 <page_insert>
        	if(r != 0)
f0102fc6:	83 c4 10             	add    $0x10,%esp
f0102fc9:	85 c0                	test   %eax,%eax
f0102fcb:	75 1f                	jne    f0102fec <region_alloc+0x67>
    	for(i = start; i < end; i += PGSIZE){
f0102fcd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fd3:	eb d0                	jmp    f0102fa5 <region_alloc+0x20>
           		panic(" region alloc failed: allocation failed.\n");
f0102fd5:	83 ec 04             	sub    $0x4,%esp
f0102fd8:	68 7c 74 10 f0       	push   $0xf010747c
f0102fdd:	68 2f 01 00 00       	push   $0x12f
f0102fe2:	68 38 75 10 f0       	push   $0xf0107538
f0102fe7:	e8 54 d0 ff ff       	call   f0100040 <_panic>
            		panic("region alloc failed.\n");
f0102fec:	83 ec 04             	sub    $0x4,%esp
f0102fef:	68 43 75 10 f0       	push   $0xf0107543
f0102ff4:	68 33 01 00 00       	push   $0x133
f0102ff9:	68 38 75 10 f0       	push   $0xf0107538
f0102ffe:	e8 3d d0 ff ff       	call   f0100040 <_panic>
    	}
}
f0103003:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103006:	5b                   	pop    %ebx
f0103007:	5e                   	pop    %esi
f0103008:	5f                   	pop    %edi
f0103009:	5d                   	pop    %ebp
f010300a:	c3                   	ret    

f010300b <envid2env>:
{
f010300b:	55                   	push   %ebp
f010300c:	89 e5                	mov    %esp,%ebp
f010300e:	56                   	push   %esi
f010300f:	53                   	push   %ebx
f0103010:	8b 45 08             	mov    0x8(%ebp),%eax
f0103013:	8b 55 10             	mov    0x10(%ebp),%edx
	if (envid == 0) {
f0103016:	85 c0                	test   %eax,%eax
f0103018:	74 2e                	je     f0103048 <envid2env+0x3d>
	e = &envs[ENVX(envid)];
f010301a:	89 c3                	mov    %eax,%ebx
f010301c:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103022:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103025:	03 1d 44 42 23 f0    	add    0xf0234244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010302b:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010302f:	74 31                	je     f0103062 <envid2env+0x57>
f0103031:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103034:	75 2c                	jne    f0103062 <envid2env+0x57>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103036:	84 d2                	test   %dl,%dl
f0103038:	75 38                	jne    f0103072 <envid2env+0x67>
	*env_store = e;
f010303a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010303d:	89 18                	mov    %ebx,(%eax)
	return 0;
f010303f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103044:	5b                   	pop    %ebx
f0103045:	5e                   	pop    %esi
f0103046:	5d                   	pop    %ebp
f0103047:	c3                   	ret    
		*env_store = curenv;
f0103048:	e8 06 2c 00 00       	call   f0105c53 <cpunum>
f010304d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103050:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103056:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103059:	89 01                	mov    %eax,(%ecx)
		return 0;
f010305b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103060:	eb e2                	jmp    f0103044 <envid2env+0x39>
		*env_store = 0;
f0103062:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103065:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010306b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103070:	eb d2                	jmp    f0103044 <envid2env+0x39>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103072:	e8 dc 2b 00 00       	call   f0105c53 <cpunum>
f0103077:	6b c0 74             	imul   $0x74,%eax,%eax
f010307a:	39 98 28 50 23 f0    	cmp    %ebx,-0xfdcafd8(%eax)
f0103080:	74 b8                	je     f010303a <envid2env+0x2f>
f0103082:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103085:	e8 c9 2b 00 00       	call   f0105c53 <cpunum>
f010308a:	6b c0 74             	imul   $0x74,%eax,%eax
f010308d:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103093:	3b 70 48             	cmp    0x48(%eax),%esi
f0103096:	74 a2                	je     f010303a <envid2env+0x2f>
		*env_store = 0;
f0103098:	8b 45 0c             	mov    0xc(%ebp),%eax
f010309b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f01030a1:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01030a6:	eb 9c                	jmp    f0103044 <envid2env+0x39>

f01030a8 <env_init_percpu>:
{
f01030a8:	55                   	push   %ebp
f01030a9:	89 e5                	mov    %esp,%ebp
	asm volatile("lgdt (%0)" : : "r" (p));
f01030ab:	b8 20 13 12 f0       	mov    $0xf0121320,%eax
f01030b0:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030b3:	b8 23 00 00 00       	mov    $0x23,%eax
f01030b8:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030ba:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030bc:	b8 10 00 00 00       	mov    $0x10,%eax
f01030c1:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030c3:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030c5:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030c7:	ea ce 30 10 f0 08 00 	ljmp   $0x8,$0xf01030ce
	asm volatile("lldt %0" : : "r" (sel));
f01030ce:	b8 00 00 00 00       	mov    $0x0,%eax
f01030d3:	0f 00 d0             	lldt   %ax
}
f01030d6:	5d                   	pop    %ebp
f01030d7:	c3                   	ret    

f01030d8 <env_init>:
{
f01030d8:	55                   	push   %ebp
f01030d9:	89 e5                	mov    %esp,%ebp
f01030db:	56                   	push   %esi
f01030dc:	53                   	push   %ebx
        	envs[i].env_id = 0;
f01030dd:	8b 35 44 42 23 f0    	mov    0xf0234244,%esi
f01030e3:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f01030e9:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f01030ec:	ba 00 00 00 00       	mov    $0x0,%edx
f01030f1:	89 c1                	mov    %eax,%ecx
f01030f3:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
        	envs[i].env_status = ENV_FREE;
f01030fa:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
        	envs[i].env_link = env_free_list;
f0103101:	89 50 44             	mov    %edx,0x44(%eax)
f0103104:	83 e8 7c             	sub    $0x7c,%eax
        	env_free_list = &envs[i];
f0103107:	89 ca                	mov    %ecx,%edx
    	for (i=NENV-1; i>=0; i--){
f0103109:	39 d8                	cmp    %ebx,%eax
f010310b:	75 e4                	jne    f01030f1 <env_init+0x19>
f010310d:	89 35 48 42 23 f0    	mov    %esi,0xf0234248
	env_init_percpu();
f0103113:	e8 90 ff ff ff       	call   f01030a8 <env_init_percpu>
}
f0103118:	5b                   	pop    %ebx
f0103119:	5e                   	pop    %esi
f010311a:	5d                   	pop    %ebp
f010311b:	c3                   	ret    

f010311c <env_alloc>:
{
f010311c:	55                   	push   %ebp
f010311d:	89 e5                	mov    %esp,%ebp
f010311f:	53                   	push   %ebx
f0103120:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103123:	8b 1d 48 42 23 f0    	mov    0xf0234248,%ebx
f0103129:	85 db                	test   %ebx,%ebx
f010312b:	0f 84 92 01 00 00    	je     f01032c3 <env_alloc+0x1a7>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103131:	83 ec 0c             	sub    $0xc,%esp
f0103134:	6a 01                	push   $0x1
f0103136:	e8 db dd ff ff       	call   f0100f16 <page_alloc>
f010313b:	83 c4 10             	add    $0x10,%esp
f010313e:	85 c0                	test   %eax,%eax
f0103140:	0f 84 84 01 00 00    	je     f01032ca <env_alloc+0x1ae>
	return (pp - pages) << PGSHIFT;
f0103146:	89 c2                	mov    %eax,%edx
f0103148:	2b 15 90 4e 23 f0    	sub    0xf0234e90,%edx
f010314e:	c1 fa 03             	sar    $0x3,%edx
f0103151:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103154:	89 d1                	mov    %edx,%ecx
f0103156:	c1 e9 0c             	shr    $0xc,%ecx
f0103159:	3b 0d 88 4e 23 f0    	cmp    0xf0234e88,%ecx
f010315f:	0f 83 37 01 00 00    	jae    f010329c <env_alloc+0x180>
	return (void *)(pa + KERNBASE);
f0103165:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010316b:	89 53 60             	mov    %edx,0x60(%ebx)
     	p->pp_ref++;
f010316e:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0103173:	b8 00 00 00 00       	mov    $0x0,%eax
         	e->env_pgdir[i] = 0; 
f0103178:	8b 53 60             	mov    0x60(%ebx),%edx
f010317b:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
f0103182:	83 c0 04             	add    $0x4,%eax
     	for (i = 0; i < PDX(UTOP); i++)
f0103185:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f010318a:	75 ec                	jne    f0103178 <env_alloc+0x5c>
         	e->env_pgdir[i] = kern_pgdir[i];
f010318c:	8b 15 8c 4e 23 f0    	mov    0xf0234e8c,%edx
f0103192:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0103195:	8b 53 60             	mov    0x60(%ebx),%edx
f0103198:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f010319b:	83 c0 04             	add    $0x4,%eax
	for (i = PDX(UTOP); i < NPDENTRIES; i++) {
f010319e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f01031a3:	75 e7                	jne    f010318c <env_alloc+0x70>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01031a5:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01031a8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01031ad:	0f 86 fb 00 00 00    	jbe    f01032ae <env_alloc+0x192>
	return (physaddr_t)kva - KERNBASE;
f01031b3:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01031b9:	83 ca 05             	or     $0x5,%edx
f01031bc:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
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
f01031d9:	2b 15 44 42 23 f0    	sub    0xf0234244,%edx
f01031df:	c1 fa 02             	sar    $0x2,%edx
f01031e2:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f01031e8:	09 d0                	or     %edx,%eax
f01031ea:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01031ed:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031f0:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031f3:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031fa:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103201:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103208:	83 ec 04             	sub    $0x4,%esp
f010320b:	6a 44                	push   $0x44
f010320d:	6a 00                	push   $0x0
f010320f:	53                   	push   %ebx
f0103210:	e8 1b 24 00 00       	call   f0105630 <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f0103215:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010321b:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103221:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103227:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010322e:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
        e->env_tf.tf_eflags |= FL_IF;
f0103234:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f010323b:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103242:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f0103246:	8b 43 44             	mov    0x44(%ebx),%eax
f0103249:	a3 48 42 23 f0       	mov    %eax,0xf0234248
	*newenv_store = e;
f010324e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103251:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103253:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103256:	e8 f8 29 00 00       	call   f0105c53 <cpunum>
f010325b:	6b c0 74             	imul   $0x74,%eax,%eax
f010325e:	83 c4 10             	add    $0x10,%esp
f0103261:	ba 00 00 00 00       	mov    $0x0,%edx
f0103266:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f010326d:	74 11                	je     f0103280 <env_alloc+0x164>
f010326f:	e8 df 29 00 00       	call   f0105c53 <cpunum>
f0103274:	6b c0 74             	imul   $0x74,%eax,%eax
f0103277:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010327d:	8b 50 48             	mov    0x48(%eax),%edx
f0103280:	83 ec 04             	sub    $0x4,%esp
f0103283:	53                   	push   %ebx
f0103284:	52                   	push   %edx
f0103285:	68 59 75 10 f0       	push   $0xf0107559
f010328a:	e8 4e 06 00 00       	call   f01038dd <cprintf>
	return 0;
f010328f:	83 c4 10             	add    $0x10,%esp
f0103292:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103297:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010329a:	c9                   	leave  
f010329b:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010329c:	52                   	push   %edx
f010329d:	68 c4 62 10 f0       	push   $0xf01062c4
f01032a2:	6a 58                	push   $0x58
f01032a4:	68 4d 71 10 f0       	push   $0xf010714d
f01032a9:	e8 92 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01032ae:	50                   	push   %eax
f01032af:	68 e8 62 10 f0       	push   $0xf01062e8
f01032b4:	68 c9 00 00 00       	push   $0xc9
f01032b9:	68 38 75 10 f0       	push   $0xf0107538
f01032be:	e8 7d cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01032c3:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032c8:	eb cd                	jmp    f0103297 <env_alloc+0x17b>
		return -E_NO_MEM;
f01032ca:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01032cf:	eb c6                	jmp    f0103297 <env_alloc+0x17b>

f01032d1 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01032d1:	55                   	push   %ebp
f01032d2:	89 e5                	mov    %esp,%ebp
f01032d4:	57                   	push   %edi
f01032d5:	56                   	push   %esi
f01032d6:	53                   	push   %ebx
f01032d7:	83 ec 34             	sub    $0x34,%esp
f01032da:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
    	int rc;
    	if ((rc = env_alloc(&e, 0)) != 0)
f01032dd:	6a 00                	push   $0x0
f01032df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032e2:	50                   	push   %eax
f01032e3:	e8 34 fe ff ff       	call   f010311c <env_alloc>
f01032e8:	83 c4 10             	add    $0x10,%esp
f01032eb:	85 c0                	test   %eax,%eax
f01032ed:	75 3d                	jne    f010332c <env_create+0x5b>
          	panic("env_create failed: env_alloc failed.\n");

     	load_icode(e, binary);
f01032ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    	if (header->e_magic != ELF_MAGIC) 
f01032f5:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f01032fb:	75 46                	jne    f0103343 <env_create+0x72>
    	if (header->e_entry == 0)
f01032fd:	8b 47 18             	mov    0x18(%edi),%eax
f0103300:	85 c0                	test   %eax,%eax
f0103302:	74 56                	je     f010335a <env_create+0x89>
   	e->env_tf.tf_eip = header->e_entry;
f0103304:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103307:	89 41 30             	mov    %eax,0x30(%ecx)
   	lcr3(PADDR(e->env_pgdir));   //load user pgdir
f010330a:	8b 41 60             	mov    0x60(%ecx),%eax
	if ((uint32_t)kva < KERNBASE)
f010330d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103312:	76 5d                	jbe    f0103371 <env_create+0xa0>
	return (physaddr_t)kva - KERNBASE;
f0103314:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103319:	0f 22 d8             	mov    %eax,%cr3
   	ph = (struct Proghdr* )((uint8_t *)header + header->e_phoff);
f010331c:	89 fb                	mov    %edi,%ebx
f010331e:	03 5f 1c             	add    0x1c(%edi),%ebx
   	eph = ph + header->e_phnum;
f0103321:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103325:	c1 e6 05             	shl    $0x5,%esi
f0103328:	01 de                	add    %ebx,%esi
f010332a:	eb 5d                	jmp    f0103389 <env_create+0xb8>
          	panic("env_create failed: env_alloc failed.\n");
f010332c:	83 ec 04             	sub    $0x4,%esp
f010332f:	68 a8 74 10 f0       	push   $0xf01074a8
f0103334:	68 9b 01 00 00       	push   $0x19b
f0103339:	68 38 75 10 f0       	push   $0xf0107538
f010333e:	e8 fd cc ff ff       	call   f0100040 <_panic>
        	panic("load_icode failed: The binary we load is not elf.\n");
f0103343:	83 ec 04             	sub    $0x4,%esp
f0103346:	68 d0 74 10 f0       	push   $0xf01074d0
f010334b:	68 70 01 00 00       	push   $0x170
f0103350:	68 38 75 10 f0       	push   $0xf0107538
f0103355:	e8 e6 cc ff ff       	call   f0100040 <_panic>
        	panic("load_icode failed: The elf file can't be excuterd.\n");
f010335a:	83 ec 04             	sub    $0x4,%esp
f010335d:	68 04 75 10 f0       	push   $0xf0107504
f0103362:	68 73 01 00 00       	push   $0x173
f0103367:	68 38 75 10 f0       	push   $0xf0107538
f010336c:	e8 cf cc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103371:	50                   	push   %eax
f0103372:	68 e8 62 10 f0       	push   $0xf01062e8
f0103377:	68 77 01 00 00       	push   $0x177
f010337c:	68 38 75 10 f0       	push   $0xf0107538
f0103381:	e8 ba cc ff ff       	call   f0100040 <_panic>
    	for(; ph < eph; ph++) {
f0103386:	83 c3 20             	add    $0x20,%ebx
f0103389:	39 de                	cmp    %ebx,%esi
f010338b:	76 43                	jbe    f01033d0 <env_create+0xff>
        	if(ph->p_type == ELF_PROG_LOAD) {
f010338d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103390:	75 f4                	jne    f0103386 <env_create+0xb5>
           		region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0103392:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103395:	8b 53 08             	mov    0x8(%ebx),%edx
f0103398:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010339b:	e8 e5 fb ff ff       	call   f0102f85 <region_alloc>
            		memmove((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f01033a0:	83 ec 04             	sub    $0x4,%esp
f01033a3:	ff 73 10             	pushl  0x10(%ebx)
f01033a6:	89 f8                	mov    %edi,%eax
f01033a8:	03 43 04             	add    0x4(%ebx),%eax
f01033ab:	50                   	push   %eax
f01033ac:	ff 73 08             	pushl  0x8(%ebx)
f01033af:	e8 c9 22 00 00       	call   f010567d <memmove>
            		memset((void *)(ph->p_va + ph->p_filesz), 0, ph->p_memsz - ph->p_filesz);
f01033b4:	8b 43 10             	mov    0x10(%ebx),%eax
f01033b7:	83 c4 0c             	add    $0xc,%esp
f01033ba:	8b 53 14             	mov    0x14(%ebx),%edx
f01033bd:	29 c2                	sub    %eax,%edx
f01033bf:	52                   	push   %edx
f01033c0:	6a 00                	push   $0x0
f01033c2:	03 43 08             	add    0x8(%ebx),%eax
f01033c5:	50                   	push   %eax
f01033c6:	e8 65 22 00 00       	call   f0105630 <memset>
f01033cb:	83 c4 10             	add    $0x10,%esp
f01033ce:	eb b6                	jmp    f0103386 <env_create+0xb5>
	region_alloc(e,(void *)(USTACKTOP-PGSIZE), PGSIZE);
f01033d0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033d5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033da:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01033dd:	e8 a3 fb ff ff       	call   f0102f85 <region_alloc>
     	e->env_type = type;
f01033e2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033e8:	89 50 50             	mov    %edx,0x50(%eax)
}
f01033eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033ee:	5b                   	pop    %ebx
f01033ef:	5e                   	pop    %esi
f01033f0:	5f                   	pop    %edi
f01033f1:	5d                   	pop    %ebp
f01033f2:	c3                   	ret    

f01033f3 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033f3:	55                   	push   %ebp
f01033f4:	89 e5                	mov    %esp,%ebp
f01033f6:	57                   	push   %edi
f01033f7:	56                   	push   %esi
f01033f8:	53                   	push   %ebx
f01033f9:	83 ec 1c             	sub    $0x1c,%esp
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033fc:	e8 52 28 00 00       	call   f0105c53 <cpunum>
f0103401:	6b c0 74             	imul   $0x74,%eax,%eax
f0103404:	8b 55 08             	mov    0x8(%ebp),%edx
f0103407:	39 90 28 50 23 f0    	cmp    %edx,-0xfdcafd8(%eax)
f010340d:	75 14                	jne    f0103423 <env_free+0x30>
		lcr3(PADDR(kern_pgdir));
f010340f:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103414:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103419:	76 56                	jbe    f0103471 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f010341b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103420:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103423:	8b 45 08             	mov    0x8(%ebp),%eax
f0103426:	8b 58 48             	mov    0x48(%eax),%ebx
f0103429:	e8 25 28 00 00       	call   f0105c53 <cpunum>
f010342e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103431:	ba 00 00 00 00       	mov    $0x0,%edx
f0103436:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f010343d:	74 11                	je     f0103450 <env_free+0x5d>
f010343f:	e8 0f 28 00 00       	call   f0105c53 <cpunum>
f0103444:	6b c0 74             	imul   $0x74,%eax,%eax
f0103447:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010344d:	8b 50 48             	mov    0x48(%eax),%edx
f0103450:	83 ec 04             	sub    $0x4,%esp
f0103453:	53                   	push   %ebx
f0103454:	52                   	push   %edx
f0103455:	68 6e 75 10 f0       	push   $0xf010756e
f010345a:	e8 7e 04 00 00       	call   f01038dd <cprintf>
f010345f:	83 c4 10             	add    $0x10,%esp
f0103462:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103469:	8b 7d 08             	mov    0x8(%ebp),%edi
f010346c:	e9 8f 00 00 00       	jmp    f0103500 <env_free+0x10d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103471:	50                   	push   %eax
f0103472:	68 e8 62 10 f0       	push   $0xf01062e8
f0103477:	68 af 01 00 00       	push   $0x1af
f010347c:	68 38 75 10 f0       	push   $0xf0107538
f0103481:	e8 ba cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103486:	50                   	push   %eax
f0103487:	68 c4 62 10 f0       	push   $0xf01062c4
f010348c:	68 be 01 00 00       	push   $0x1be
f0103491:	68 38 75 10 f0       	push   $0xf0107538
f0103496:	e8 a5 cb ff ff       	call   f0100040 <_panic>
f010349b:	83 c3 04             	add    $0x4,%ebx
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010349e:	39 f3                	cmp    %esi,%ebx
f01034a0:	74 21                	je     f01034c3 <env_free+0xd0>
			if (pt[pteno] & PTE_P)
f01034a2:	f6 03 01             	testb  $0x1,(%ebx)
f01034a5:	74 f4                	je     f010349b <env_free+0xa8>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01034a7:	83 ec 08             	sub    $0x8,%esp
f01034aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01034ad:	01 d8                	add    %ebx,%eax
f01034af:	c1 e0 0a             	shl    $0xa,%eax
f01034b2:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01034b5:	50                   	push   %eax
f01034b6:	ff 77 60             	pushl  0x60(%edi)
f01034b9:	e8 e1 dc ff ff       	call   f010119f <page_remove>
f01034be:	83 c4 10             	add    $0x10,%esp
f01034c1:	eb d8                	jmp    f010349b <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034c3:	8b 47 60             	mov    0x60(%edi),%eax
f01034c6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034c9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01034d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034d3:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f01034d9:	73 6a                	jae    f0103545 <env_free+0x152>
		page_decref(pa2page(pa));
f01034db:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034de:	a1 90 4e 23 f0       	mov    0xf0234e90,%eax
f01034e3:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01034e6:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034e9:	50                   	push   %eax
f01034ea:	e8 d4 da ff ff       	call   f0100fc3 <page_decref>
f01034ef:	83 c4 10             	add    $0x10,%esp
f01034f2:	83 45 dc 04          	addl   $0x4,-0x24(%ebp)
f01034f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034f9:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034fe:	74 59                	je     f0103559 <env_free+0x166>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103500:	8b 47 60             	mov    0x60(%edi),%eax
f0103503:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103506:	8b 04 10             	mov    (%eax,%edx,1),%eax
f0103509:	a8 01                	test   $0x1,%al
f010350b:	74 e5                	je     f01034f2 <env_free+0xff>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010350d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
	if (PGNUM(pa) >= npages)
f0103512:	89 c2                	mov    %eax,%edx
f0103514:	c1 ea 0c             	shr    $0xc,%edx
f0103517:	89 55 d8             	mov    %edx,-0x28(%ebp)
f010351a:	39 15 88 4e 23 f0    	cmp    %edx,0xf0234e88
f0103520:	0f 86 60 ff ff ff    	jbe    f0103486 <env_free+0x93>
	return (void *)(pa + KERNBASE);
f0103526:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010352c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010352f:	c1 e2 14             	shl    $0x14,%edx
f0103532:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103535:	8d b0 00 10 00 f0    	lea    -0xffff000(%eax),%esi
f010353b:	f7 d8                	neg    %eax
f010353d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103540:	e9 5d ff ff ff       	jmp    f01034a2 <env_free+0xaf>
		panic("pa2page called with invalid pa");
f0103545:	83 ec 04             	sub    $0x4,%esp
f0103548:	68 08 69 10 f0       	push   $0xf0106908
f010354d:	6a 51                	push   $0x51
f010354f:	68 4d 71 10 f0       	push   $0xf010714d
f0103554:	e8 e7 ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103559:	8b 45 08             	mov    0x8(%ebp),%eax
f010355c:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f010355f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103564:	76 52                	jbe    f01035b8 <env_free+0x1c5>
	e->env_pgdir = 0;
f0103566:	8b 55 08             	mov    0x8(%ebp),%edx
f0103569:	c7 42 60 00 00 00 00 	movl   $0x0,0x60(%edx)
	return (physaddr_t)kva - KERNBASE;
f0103570:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103575:	c1 e8 0c             	shr    $0xc,%eax
f0103578:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f010357e:	73 4d                	jae    f01035cd <env_free+0x1da>
	page_decref(pa2page(pa));
f0103580:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0103583:	8b 15 90 4e 23 f0    	mov    0xf0234e90,%edx
f0103589:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010358c:	50                   	push   %eax
f010358d:	e8 31 da ff ff       	call   f0100fc3 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103592:	8b 45 08             	mov    0x8(%ebp),%eax
f0103595:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
	e->env_link = env_free_list;
f010359c:	a1 48 42 23 f0       	mov    0xf0234248,%eax
f01035a1:	8b 55 08             	mov    0x8(%ebp),%edx
f01035a4:	89 42 44             	mov    %eax,0x44(%edx)
	env_free_list = e;
f01035a7:	89 15 48 42 23 f0    	mov    %edx,0xf0234248
}
f01035ad:	83 c4 10             	add    $0x10,%esp
f01035b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01035b3:	5b                   	pop    %ebx
f01035b4:	5e                   	pop    %esi
f01035b5:	5f                   	pop    %edi
f01035b6:	5d                   	pop    %ebp
f01035b7:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01035b8:	50                   	push   %eax
f01035b9:	68 e8 62 10 f0       	push   $0xf01062e8
f01035be:	68 cc 01 00 00       	push   $0x1cc
f01035c3:	68 38 75 10 f0       	push   $0xf0107538
f01035c8:	e8 73 ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01035cd:	83 ec 04             	sub    $0x4,%esp
f01035d0:	68 08 69 10 f0       	push   $0xf0106908
f01035d5:	6a 51                	push   $0x51
f01035d7:	68 4d 71 10 f0       	push   $0xf010714d
f01035dc:	e8 5f ca ff ff       	call   f0100040 <_panic>

f01035e1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035e1:	55                   	push   %ebp
f01035e2:	89 e5                	mov    %esp,%ebp
f01035e4:	53                   	push   %ebx
f01035e5:	83 ec 04             	sub    $0x4,%esp
f01035e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035eb:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035ef:	74 21                	je     f0103612 <env_destroy+0x31>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01035f1:	83 ec 0c             	sub    $0xc,%esp
f01035f4:	53                   	push   %ebx
f01035f5:	e8 f9 fd ff ff       	call   f01033f3 <env_free>

	if (curenv == e) {
f01035fa:	e8 54 26 00 00       	call   f0105c53 <cpunum>
f01035ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103602:	83 c4 10             	add    $0x10,%esp
f0103605:	39 98 28 50 23 f0    	cmp    %ebx,-0xfdcafd8(%eax)
f010360b:	74 1e                	je     f010362b <env_destroy+0x4a>
		curenv = NULL;
		sched_yield();
	}
}
f010360d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103610:	c9                   	leave  
f0103611:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103612:	e8 3c 26 00 00       	call   f0105c53 <cpunum>
f0103617:	6b c0 74             	imul   $0x74,%eax,%eax
f010361a:	39 98 28 50 23 f0    	cmp    %ebx,-0xfdcafd8(%eax)
f0103620:	74 cf                	je     f01035f1 <env_destroy+0x10>
		e->env_status = ENV_DYING;
f0103622:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103629:	eb e2                	jmp    f010360d <env_destroy+0x2c>
		curenv = NULL;
f010362b:	e8 23 26 00 00       	call   f0105c53 <cpunum>
f0103630:	6b c0 74             	imul   $0x74,%eax,%eax
f0103633:	c7 80 28 50 23 f0 00 	movl   $0x0,-0xfdcafd8(%eax)
f010363a:	00 00 00 
		sched_yield();
f010363d:	e8 2d 0e 00 00       	call   f010446f <sched_yield>

f0103642 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103642:	55                   	push   %ebp
f0103643:	89 e5                	mov    %esp,%ebp
f0103645:	53                   	push   %ebx
f0103646:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103649:	e8 05 26 00 00       	call   f0105c53 <cpunum>
f010364e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103651:	8b 98 28 50 23 f0    	mov    -0xfdcafd8(%eax),%ebx
f0103657:	e8 f7 25 00 00       	call   f0105c53 <cpunum>
f010365c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010365f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103662:	61                   	popa   
f0103663:	07                   	pop    %es
f0103664:	1f                   	pop    %ds
f0103665:	83 c4 08             	add    $0x8,%esp
f0103668:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103669:	83 ec 04             	sub    $0x4,%esp
f010366c:	68 84 75 10 f0       	push   $0xf0107584
f0103671:	68 03 02 00 00       	push   $0x203
f0103676:	68 38 75 10 f0       	push   $0xf0107538
f010367b:	e8 c0 c9 ff ff       	call   f0100040 <_panic>

f0103680 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103680:	55                   	push   %ebp
f0103681:	89 e5                	mov    %esp,%ebp
f0103683:	83 ec 08             	sub    $0x8,%esp
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if(curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103686:	e8 c8 25 00 00       	call   f0105c53 <cpunum>
f010368b:	6b c0 74             	imul   $0x74,%eax,%eax
f010368e:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f0103695:	74 14                	je     f01036ab <env_run+0x2b>
f0103697:	e8 b7 25 00 00       	call   f0105c53 <cpunum>
f010369c:	6b c0 74             	imul   $0x74,%eax,%eax
f010369f:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01036a5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01036a9:	74 65                	je     f0103710 <env_run+0x90>
        	curenv->env_status = ENV_RUNNABLE;

    	curenv = e;    
f01036ab:	e8 a3 25 00 00       	call   f0105c53 <cpunum>
f01036b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01036b3:	8b 55 08             	mov    0x8(%ebp),%edx
f01036b6:	89 90 28 50 23 f0    	mov    %edx,-0xfdcafd8(%eax)
    	curenv->env_status = ENV_RUNNING;
f01036bc:	e8 92 25 00 00       	call   f0105c53 <cpunum>
f01036c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c4:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01036ca:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
    	curenv->env_runs++;
f01036d1:	e8 7d 25 00 00       	call   f0105c53 <cpunum>
f01036d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01036d9:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01036df:	83 40 58 01          	addl   $0x1,0x58(%eax)
    	lcr3(PADDR(curenv->env_pgdir));
f01036e3:	e8 6b 25 00 00       	call   f0105c53 <cpunum>
f01036e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01036eb:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01036f1:	8b 40 60             	mov    0x60(%eax),%eax
	if ((uint32_t)kva < KERNBASE)
f01036f4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036f9:	77 2c                	ja     f0103727 <env_run+0xa7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036fb:	50                   	push   %eax
f01036fc:	68 e8 62 10 f0       	push   $0xf01062e8
f0103701:	68 27 02 00 00       	push   $0x227
f0103706:	68 38 75 10 f0       	push   $0xf0107538
f010370b:	e8 30 c9 ff ff       	call   f0100040 <_panic>
        	curenv->env_status = ENV_RUNNABLE;
f0103710:	e8 3e 25 00 00       	call   f0105c53 <cpunum>
f0103715:	6b c0 74             	imul   $0x74,%eax,%eax
f0103718:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010371e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f0103725:	eb 84                	jmp    f01036ab <env_run+0x2b>
	return (physaddr_t)kva - KERNBASE;
f0103727:	05 00 00 00 10       	add    $0x10000000,%eax
f010372c:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010372f:	83 ec 0c             	sub    $0xc,%esp
f0103732:	68 c0 13 12 f0       	push   $0xf01213c0
f0103737:	e8 24 28 00 00       	call   f0105f60 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010373c:	f3 90                	pause  

	unlock_kernel();

    	env_pop_tf(&curenv->env_tf);
f010373e:	e8 10 25 00 00       	call   f0105c53 <cpunum>
f0103743:	83 c4 04             	add    $0x4,%esp
f0103746:	6b c0 74             	imul   $0x74,%eax,%eax
f0103749:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f010374f:	e8 ee fe ff ff       	call   f0103642 <env_pop_tf>

f0103754 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103754:	55                   	push   %ebp
f0103755:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103757:	8b 45 08             	mov    0x8(%ebp),%eax
f010375a:	ba 70 00 00 00       	mov    $0x70,%edx
f010375f:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103760:	ba 71 00 00 00       	mov    $0x71,%edx
f0103765:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103766:	0f b6 c0             	movzbl %al,%eax
}
f0103769:	5d                   	pop    %ebp
f010376a:	c3                   	ret    

f010376b <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010376b:	55                   	push   %ebp
f010376c:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010376e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103771:	ba 70 00 00 00       	mov    $0x70,%edx
f0103776:	ee                   	out    %al,(%dx)
f0103777:	8b 45 0c             	mov    0xc(%ebp),%eax
f010377a:	ba 71 00 00 00       	mov    $0x71,%edx
f010377f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103780:	5d                   	pop    %ebp
f0103781:	c3                   	ret    

f0103782 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103782:	55                   	push   %ebp
f0103783:	89 e5                	mov    %esp,%ebp
f0103785:	56                   	push   %esi
f0103786:	53                   	push   %ebx
f0103787:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010378a:	66 a3 a8 13 12 f0    	mov    %ax,0xf01213a8
	if (!didinit)
f0103790:	80 3d 4c 42 23 f0 00 	cmpb   $0x0,0xf023424c
f0103797:	75 07                	jne    f01037a0 <irq_setmask_8259A+0x1e>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f0103799:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010379c:	5b                   	pop    %ebx
f010379d:	5e                   	pop    %esi
f010379e:	5d                   	pop    %ebp
f010379f:	c3                   	ret    
f01037a0:	89 c6                	mov    %eax,%esi
f01037a2:	ba 21 00 00 00       	mov    $0x21,%edx
f01037a7:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f01037a8:	66 c1 e8 08          	shr    $0x8,%ax
f01037ac:	ba a1 00 00 00       	mov    $0xa1,%edx
f01037b1:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f01037b2:	83 ec 0c             	sub    $0xc,%esp
f01037b5:	68 90 75 10 f0       	push   $0xf0107590
f01037ba:	e8 1e 01 00 00       	call   f01038dd <cprintf>
f01037bf:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037c2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f01037c7:	0f b7 f6             	movzwl %si,%esi
f01037ca:	f7 d6                	not    %esi
f01037cc:	eb 08                	jmp    f01037d6 <irq_setmask_8259A+0x54>
	for (i = 0; i < 16; i++)
f01037ce:	83 c3 01             	add    $0x1,%ebx
f01037d1:	83 fb 10             	cmp    $0x10,%ebx
f01037d4:	74 18                	je     f01037ee <irq_setmask_8259A+0x6c>
		if (~mask & (1<<i))
f01037d6:	0f a3 de             	bt     %ebx,%esi
f01037d9:	73 f3                	jae    f01037ce <irq_setmask_8259A+0x4c>
			cprintf(" %d", i);
f01037db:	83 ec 08             	sub    $0x8,%esp
f01037de:	53                   	push   %ebx
f01037df:	68 7b 7a 10 f0       	push   $0xf0107a7b
f01037e4:	e8 f4 00 00 00       	call   f01038dd <cprintf>
f01037e9:	83 c4 10             	add    $0x10,%esp
f01037ec:	eb e0                	jmp    f01037ce <irq_setmask_8259A+0x4c>
	cprintf("\n");
f01037ee:	83 ec 0c             	sub    $0xc,%esp
f01037f1:	68 49 74 10 f0       	push   $0xf0107449
f01037f6:	e8 e2 00 00 00       	call   f01038dd <cprintf>
f01037fb:	83 c4 10             	add    $0x10,%esp
f01037fe:	eb 99                	jmp    f0103799 <irq_setmask_8259A+0x17>

f0103800 <pic_init>:
{
f0103800:	55                   	push   %ebp
f0103801:	89 e5                	mov    %esp,%ebp
f0103803:	57                   	push   %edi
f0103804:	56                   	push   %esi
f0103805:	53                   	push   %ebx
f0103806:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f0103809:	c6 05 4c 42 23 f0 01 	movb   $0x1,0xf023424c
f0103810:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103815:	bb 21 00 00 00       	mov    $0x21,%ebx
f010381a:	89 da                	mov    %ebx,%edx
f010381c:	ee                   	out    %al,(%dx)
f010381d:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f0103822:	89 ca                	mov    %ecx,%edx
f0103824:	ee                   	out    %al,(%dx)
f0103825:	bf 11 00 00 00       	mov    $0x11,%edi
f010382a:	be 20 00 00 00       	mov    $0x20,%esi
f010382f:	89 f8                	mov    %edi,%eax
f0103831:	89 f2                	mov    %esi,%edx
f0103833:	ee                   	out    %al,(%dx)
f0103834:	b8 20 00 00 00       	mov    $0x20,%eax
f0103839:	89 da                	mov    %ebx,%edx
f010383b:	ee                   	out    %al,(%dx)
f010383c:	b8 04 00 00 00       	mov    $0x4,%eax
f0103841:	ee                   	out    %al,(%dx)
f0103842:	b8 03 00 00 00       	mov    $0x3,%eax
f0103847:	ee                   	out    %al,(%dx)
f0103848:	bb a0 00 00 00       	mov    $0xa0,%ebx
f010384d:	89 f8                	mov    %edi,%eax
f010384f:	89 da                	mov    %ebx,%edx
f0103851:	ee                   	out    %al,(%dx)
f0103852:	b8 28 00 00 00       	mov    $0x28,%eax
f0103857:	89 ca                	mov    %ecx,%edx
f0103859:	ee                   	out    %al,(%dx)
f010385a:	b8 02 00 00 00       	mov    $0x2,%eax
f010385f:	ee                   	out    %al,(%dx)
f0103860:	b8 01 00 00 00       	mov    $0x1,%eax
f0103865:	ee                   	out    %al,(%dx)
f0103866:	bf 68 00 00 00       	mov    $0x68,%edi
f010386b:	89 f8                	mov    %edi,%eax
f010386d:	89 f2                	mov    %esi,%edx
f010386f:	ee                   	out    %al,(%dx)
f0103870:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0103875:	89 c8                	mov    %ecx,%eax
f0103877:	ee                   	out    %al,(%dx)
f0103878:	89 f8                	mov    %edi,%eax
f010387a:	89 da                	mov    %ebx,%edx
f010387c:	ee                   	out    %al,(%dx)
f010387d:	89 c8                	mov    %ecx,%eax
f010387f:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f0103880:	0f b7 05 a8 13 12 f0 	movzwl 0xf01213a8,%eax
f0103887:	66 83 f8 ff          	cmp    $0xffff,%ax
f010388b:	74 0f                	je     f010389c <pic_init+0x9c>
		irq_setmask_8259A(irq_mask_8259A);
f010388d:	83 ec 0c             	sub    $0xc,%esp
f0103890:	0f b7 c0             	movzwl %ax,%eax
f0103893:	50                   	push   %eax
f0103894:	e8 e9 fe ff ff       	call   f0103782 <irq_setmask_8259A>
f0103899:	83 c4 10             	add    $0x10,%esp
}
f010389c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010389f:	5b                   	pop    %ebx
f01038a0:	5e                   	pop    %esi
f01038a1:	5f                   	pop    %edi
f01038a2:	5d                   	pop    %ebp
f01038a3:	c3                   	ret    

f01038a4 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01038a4:	55                   	push   %ebp
f01038a5:	89 e5                	mov    %esp,%ebp
f01038a7:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01038aa:	ff 75 08             	pushl  0x8(%ebp)
f01038ad:	e8 bb ce ff ff       	call   f010076d <cputchar>
	*cnt++;
}
f01038b2:	83 c4 10             	add    $0x10,%esp
f01038b5:	c9                   	leave  
f01038b6:	c3                   	ret    

f01038b7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01038b7:	55                   	push   %ebp
f01038b8:	89 e5                	mov    %esp,%ebp
f01038ba:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01038bd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01038c4:	ff 75 0c             	pushl  0xc(%ebp)
f01038c7:	ff 75 08             	pushl  0x8(%ebp)
f01038ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01038cd:	50                   	push   %eax
f01038ce:	68 a4 38 10 f0       	push   $0xf01038a4
f01038d3:	e8 13 16 00 00       	call   f0104eeb <vprintfmt>
	return cnt;
}
f01038d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038db:	c9                   	leave  
f01038dc:	c3                   	ret    

f01038dd <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038dd:	55                   	push   %ebp
f01038de:	89 e5                	mov    %esp,%ebp
f01038e0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01038e3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01038e6:	50                   	push   %eax
f01038e7:	ff 75 08             	pushl  0x8(%ebp)
f01038ea:	e8 c8 ff ff ff       	call   f01038b7 <vcprintf>
	va_end(ap);

	return cnt;
}
f01038ef:	c9                   	leave  
f01038f0:	c3                   	ret    

f01038f1 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01038f1:	55                   	push   %ebp
f01038f2:	89 e5                	mov    %esp,%ebp
f01038f4:	57                   	push   %edi
f01038f5:	56                   	push   %esi
f01038f6:	53                   	push   %ebx
f01038f7:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f01038fa:	e8 54 23 00 00       	call   f0105c53 <cpunum>
f01038ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0103902:	0f b6 98 20 50 23 f0 	movzbl -0xfdcafe0(%eax),%ebx
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f0103909:	e8 45 23 00 00       	call   f0105c53 <cpunum>
f010390e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103911:	89 d9                	mov    %ebx,%ecx
f0103913:	c1 e1 10             	shl    $0x10,%ecx
f0103916:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010391b:	29 ca                	sub    %ecx,%edx
f010391d:	89 90 30 50 23 f0    	mov    %edx,-0xfdcafd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103923:	e8 2b 23 00 00       	call   f0105c53 <cpunum>
f0103928:	6b c0 74             	imul   $0x74,%eax,%eax
f010392b:	66 c7 80 34 50 23 f0 	movw   $0x10,-0xfdcafcc(%eax)
f0103932:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3)+cid] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103934:	83 c3 05             	add    $0x5,%ebx
f0103937:	e8 17 23 00 00       	call   f0105c53 <cpunum>
f010393c:	89 c7                	mov    %eax,%edi
f010393e:	e8 10 23 00 00       	call   f0105c53 <cpunum>
f0103943:	89 c6                	mov    %eax,%esi
f0103945:	e8 09 23 00 00       	call   f0105c53 <cpunum>
f010394a:	66 c7 04 dd 40 13 12 	movw   $0x68,-0xfedecc0(,%ebx,8)
f0103951:	f0 68 00 
f0103954:	6b ff 74             	imul   $0x74,%edi,%edi
f0103957:	81 c7 2c 50 23 f0    	add    $0xf023502c,%edi
f010395d:	66 89 3c dd 42 13 12 	mov    %di,-0xfedecbe(,%ebx,8)
f0103964:	f0 
f0103965:	6b d6 74             	imul   $0x74,%esi,%edx
f0103968:	81 c2 2c 50 23 f0    	add    $0xf023502c,%edx
f010396e:	c1 ea 10             	shr    $0x10,%edx
f0103971:	88 14 dd 44 13 12 f0 	mov    %dl,-0xfedecbc(,%ebx,8)
f0103978:	c6 04 dd 46 13 12 f0 	movb   $0x40,-0xfedecba(,%ebx,8)
f010397f:	40 
f0103980:	6b c0 74             	imul   $0x74,%eax,%eax
f0103983:	05 2c 50 23 f0       	add    $0xf023502c,%eax
f0103988:	c1 e8 18             	shr    $0x18,%eax
f010398b:	88 04 dd 47 13 12 f0 	mov    %al,-0xfedecb9(,%ebx,8)
					sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3)+cid].sd_s = 0;
f0103992:	c6 04 dd 45 13 12 f0 	movb   $0x89,-0xfedecbb(,%ebx,8)
f0103999:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0+8*cid);
f010399a:	c1 e3 03             	shl    $0x3,%ebx
	asm volatile("ltr %0" : : "r" (sel));
f010399d:	0f 00 db             	ltr    %bx
	asm volatile("lidt (%0)" : : "r" (p));
f01039a0:	b8 ac 13 12 f0       	mov    $0xf01213ac,%eax
f01039a5:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f01039a8:	83 c4 0c             	add    $0xc,%esp
f01039ab:	5b                   	pop    %ebx
f01039ac:	5e                   	pop    %esi
f01039ad:	5f                   	pop    %edi
f01039ae:	5d                   	pop    %ebp
f01039af:	c3                   	ret    

f01039b0 <trap_init>:
{
f01039b0:	55                   	push   %ebp
f01039b1:	89 e5                	mov    %esp,%ebp
f01039b3:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[0], 0, GD_KT, th0, 0);
f01039b6:	b8 16 43 10 f0       	mov    $0xf0104316,%eax
f01039bb:	66 a3 60 42 23 f0    	mov    %ax,0xf0234260
f01039c1:	66 c7 05 62 42 23 f0 	movw   $0x8,0xf0234262
f01039c8:	08 00 
f01039ca:	c6 05 64 42 23 f0 00 	movb   $0x0,0xf0234264
f01039d1:	c6 05 65 42 23 f0 8e 	movb   $0x8e,0xf0234265
f01039d8:	c1 e8 10             	shr    $0x10,%eax
f01039db:	66 a3 66 42 23 f0    	mov    %ax,0xf0234266
	SETGATE(idt[1], 0, GD_KT, th1, 0);
f01039e1:	b8 1c 43 10 f0       	mov    $0xf010431c,%eax
f01039e6:	66 a3 68 42 23 f0    	mov    %ax,0xf0234268
f01039ec:	66 c7 05 6a 42 23 f0 	movw   $0x8,0xf023426a
f01039f3:	08 00 
f01039f5:	c6 05 6c 42 23 f0 00 	movb   $0x0,0xf023426c
f01039fc:	c6 05 6d 42 23 f0 8e 	movb   $0x8e,0xf023426d
f0103a03:	c1 e8 10             	shr    $0x10,%eax
f0103a06:	66 a3 6e 42 23 f0    	mov    %ax,0xf023426e
	SETGATE(idt[3], 0, GD_KT, th3, 3);
f0103a0c:	b8 22 43 10 f0       	mov    $0xf0104322,%eax
f0103a11:	66 a3 78 42 23 f0    	mov    %ax,0xf0234278
f0103a17:	66 c7 05 7a 42 23 f0 	movw   $0x8,0xf023427a
f0103a1e:	08 00 
f0103a20:	c6 05 7c 42 23 f0 00 	movb   $0x0,0xf023427c
f0103a27:	c6 05 7d 42 23 f0 ee 	movb   $0xee,0xf023427d
f0103a2e:	c1 e8 10             	shr    $0x10,%eax
f0103a31:	66 a3 7e 42 23 f0    	mov    %ax,0xf023427e
	SETGATE(idt[4], 0, GD_KT, th4, 0);
f0103a37:	b8 28 43 10 f0       	mov    $0xf0104328,%eax
f0103a3c:	66 a3 80 42 23 f0    	mov    %ax,0xf0234280
f0103a42:	66 c7 05 82 42 23 f0 	movw   $0x8,0xf0234282
f0103a49:	08 00 
f0103a4b:	c6 05 84 42 23 f0 00 	movb   $0x0,0xf0234284
f0103a52:	c6 05 85 42 23 f0 8e 	movb   $0x8e,0xf0234285
f0103a59:	c1 e8 10             	shr    $0x10,%eax
f0103a5c:	66 a3 86 42 23 f0    	mov    %ax,0xf0234286
	SETGATE(idt[5], 0, GD_KT, th5, 0);
f0103a62:	b8 2e 43 10 f0       	mov    $0xf010432e,%eax
f0103a67:	66 a3 88 42 23 f0    	mov    %ax,0xf0234288
f0103a6d:	66 c7 05 8a 42 23 f0 	movw   $0x8,0xf023428a
f0103a74:	08 00 
f0103a76:	c6 05 8c 42 23 f0 00 	movb   $0x0,0xf023428c
f0103a7d:	c6 05 8d 42 23 f0 8e 	movb   $0x8e,0xf023428d
f0103a84:	c1 e8 10             	shr    $0x10,%eax
f0103a87:	66 a3 8e 42 23 f0    	mov    %ax,0xf023428e
	SETGATE(idt[6], 0, GD_KT, th6, 0);
f0103a8d:	b8 34 43 10 f0       	mov    $0xf0104334,%eax
f0103a92:	66 a3 90 42 23 f0    	mov    %ax,0xf0234290
f0103a98:	66 c7 05 92 42 23 f0 	movw   $0x8,0xf0234292
f0103a9f:	08 00 
f0103aa1:	c6 05 94 42 23 f0 00 	movb   $0x0,0xf0234294
f0103aa8:	c6 05 95 42 23 f0 8e 	movb   $0x8e,0xf0234295
f0103aaf:	c1 e8 10             	shr    $0x10,%eax
f0103ab2:	66 a3 96 42 23 f0    	mov    %ax,0xf0234296
	SETGATE(idt[7], 0, GD_KT, th7, 0);
f0103ab8:	b8 3a 43 10 f0       	mov    $0xf010433a,%eax
f0103abd:	66 a3 98 42 23 f0    	mov    %ax,0xf0234298
f0103ac3:	66 c7 05 9a 42 23 f0 	movw   $0x8,0xf023429a
f0103aca:	08 00 
f0103acc:	c6 05 9c 42 23 f0 00 	movb   $0x0,0xf023429c
f0103ad3:	c6 05 9d 42 23 f0 8e 	movb   $0x8e,0xf023429d
f0103ada:	c1 e8 10             	shr    $0x10,%eax
f0103add:	66 a3 9e 42 23 f0    	mov    %ax,0xf023429e
	SETGATE(idt[8], 0, GD_KT, th8, 0);
f0103ae3:	b8 40 43 10 f0       	mov    $0xf0104340,%eax
f0103ae8:	66 a3 a0 42 23 f0    	mov    %ax,0xf02342a0
f0103aee:	66 c7 05 a2 42 23 f0 	movw   $0x8,0xf02342a2
f0103af5:	08 00 
f0103af7:	c6 05 a4 42 23 f0 00 	movb   $0x0,0xf02342a4
f0103afe:	c6 05 a5 42 23 f0 8e 	movb   $0x8e,0xf02342a5
f0103b05:	c1 e8 10             	shr    $0x10,%eax
f0103b08:	66 a3 a6 42 23 f0    	mov    %ax,0xf02342a6
	SETGATE(idt[9], 0, GD_KT, th9, 0);
f0103b0e:	b8 44 43 10 f0       	mov    $0xf0104344,%eax
f0103b13:	66 a3 a8 42 23 f0    	mov    %ax,0xf02342a8
f0103b19:	66 c7 05 aa 42 23 f0 	movw   $0x8,0xf02342aa
f0103b20:	08 00 
f0103b22:	c6 05 ac 42 23 f0 00 	movb   $0x0,0xf02342ac
f0103b29:	c6 05 ad 42 23 f0 8e 	movb   $0x8e,0xf02342ad
f0103b30:	c1 e8 10             	shr    $0x10,%eax
f0103b33:	66 a3 ae 42 23 f0    	mov    %ax,0xf02342ae
	SETGATE(idt[10], 0, GD_KT, th10, 0);
f0103b39:	b8 4a 43 10 f0       	mov    $0xf010434a,%eax
f0103b3e:	66 a3 b0 42 23 f0    	mov    %ax,0xf02342b0
f0103b44:	66 c7 05 b2 42 23 f0 	movw   $0x8,0xf02342b2
f0103b4b:	08 00 
f0103b4d:	c6 05 b4 42 23 f0 00 	movb   $0x0,0xf02342b4
f0103b54:	c6 05 b5 42 23 f0 8e 	movb   $0x8e,0xf02342b5
f0103b5b:	c1 e8 10             	shr    $0x10,%eax
f0103b5e:	66 a3 b6 42 23 f0    	mov    %ax,0xf02342b6
	SETGATE(idt[11], 0, GD_KT, th11, 0);
f0103b64:	b8 4e 43 10 f0       	mov    $0xf010434e,%eax
f0103b69:	66 a3 b8 42 23 f0    	mov    %ax,0xf02342b8
f0103b6f:	66 c7 05 ba 42 23 f0 	movw   $0x8,0xf02342ba
f0103b76:	08 00 
f0103b78:	c6 05 bc 42 23 f0 00 	movb   $0x0,0xf02342bc
f0103b7f:	c6 05 bd 42 23 f0 8e 	movb   $0x8e,0xf02342bd
f0103b86:	c1 e8 10             	shr    $0x10,%eax
f0103b89:	66 a3 be 42 23 f0    	mov    %ax,0xf02342be
	SETGATE(idt[12], 0, GD_KT, th12, 0);
f0103b8f:	b8 52 43 10 f0       	mov    $0xf0104352,%eax
f0103b94:	66 a3 c0 42 23 f0    	mov    %ax,0xf02342c0
f0103b9a:	66 c7 05 c2 42 23 f0 	movw   $0x8,0xf02342c2
f0103ba1:	08 00 
f0103ba3:	c6 05 c4 42 23 f0 00 	movb   $0x0,0xf02342c4
f0103baa:	c6 05 c5 42 23 f0 8e 	movb   $0x8e,0xf02342c5
f0103bb1:	c1 e8 10             	shr    $0x10,%eax
f0103bb4:	66 a3 c6 42 23 f0    	mov    %ax,0xf02342c6
	SETGATE(idt[13], 0, GD_KT, th13, 0);
f0103bba:	b8 56 43 10 f0       	mov    $0xf0104356,%eax
f0103bbf:	66 a3 c8 42 23 f0    	mov    %ax,0xf02342c8
f0103bc5:	66 c7 05 ca 42 23 f0 	movw   $0x8,0xf02342ca
f0103bcc:	08 00 
f0103bce:	c6 05 cc 42 23 f0 00 	movb   $0x0,0xf02342cc
f0103bd5:	c6 05 cd 42 23 f0 8e 	movb   $0x8e,0xf02342cd
f0103bdc:	c1 e8 10             	shr    $0x10,%eax
f0103bdf:	66 a3 ce 42 23 f0    	mov    %ax,0xf02342ce
	SETGATE(idt[14], 0, GD_KT, th14, 0);
f0103be5:	b8 5a 43 10 f0       	mov    $0xf010435a,%eax
f0103bea:	66 a3 d0 42 23 f0    	mov    %ax,0xf02342d0
f0103bf0:	66 c7 05 d2 42 23 f0 	movw   $0x8,0xf02342d2
f0103bf7:	08 00 
f0103bf9:	c6 05 d4 42 23 f0 00 	movb   $0x0,0xf02342d4
f0103c00:	c6 05 d5 42 23 f0 8e 	movb   $0x8e,0xf02342d5
f0103c07:	c1 e8 10             	shr    $0x10,%eax
f0103c0a:	66 a3 d6 42 23 f0    	mov    %ax,0xf02342d6
	SETGATE(idt[16], 0, GD_KT, th16, 0);
f0103c10:	b8 5e 43 10 f0       	mov    $0xf010435e,%eax
f0103c15:	66 a3 e0 42 23 f0    	mov    %ax,0xf02342e0
f0103c1b:	66 c7 05 e2 42 23 f0 	movw   $0x8,0xf02342e2
f0103c22:	08 00 
f0103c24:	c6 05 e4 42 23 f0 00 	movb   $0x0,0xf02342e4
f0103c2b:	c6 05 e5 42 23 f0 8e 	movb   $0x8e,0xf02342e5
f0103c32:	c1 e8 10             	shr    $0x10,%eax
f0103c35:	66 a3 e6 42 23 f0    	mov    %ax,0xf02342e6
	SETGATE(idt[T_SYSCALL], 0, GD_KT, th_syscall, 3);
f0103c3b:	b8 64 43 10 f0       	mov    $0xf0104364,%eax
f0103c40:	66 a3 e0 43 23 f0    	mov    %ax,0xf02343e0
f0103c46:	66 c7 05 e2 43 23 f0 	movw   $0x8,0xf02343e2
f0103c4d:	08 00 
f0103c4f:	c6 05 e4 43 23 f0 00 	movb   $0x0,0xf02343e4
f0103c56:	c6 05 e5 43 23 f0 ee 	movb   $0xee,0xf02343e5
f0103c5d:	c1 e8 10             	shr    $0x10,%eax
f0103c60:	66 a3 e6 43 23 f0    	mov    %ax,0xf02343e6
    	SETGATE(idt[IRQ_OFFSET + IRQ_TIMER], 0, GD_KT, irqtimer_handler, 0);
f0103c66:	b8 6a 43 10 f0       	mov    $0xf010436a,%eax
f0103c6b:	66 a3 60 43 23 f0    	mov    %ax,0xf0234360
f0103c71:	66 c7 05 62 43 23 f0 	movw   $0x8,0xf0234362
f0103c78:	08 00 
f0103c7a:	c6 05 64 43 23 f0 00 	movb   $0x0,0xf0234364
f0103c81:	c6 05 65 43 23 f0 8e 	movb   $0x8e,0xf0234365
f0103c88:	c1 e8 10             	shr    $0x10,%eax
f0103c8b:	66 a3 66 43 23 f0    	mov    %ax,0xf0234366
    	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, irqkbd_handler, 0);
f0103c91:	b8 70 43 10 f0       	mov    $0xf0104370,%eax
f0103c96:	66 a3 68 43 23 f0    	mov    %ax,0xf0234368
f0103c9c:	66 c7 05 6a 43 23 f0 	movw   $0x8,0xf023436a
f0103ca3:	08 00 
f0103ca5:	c6 05 6c 43 23 f0 00 	movb   $0x0,0xf023436c
f0103cac:	c6 05 6d 43 23 f0 8e 	movb   $0x8e,0xf023436d
f0103cb3:	c1 e8 10             	shr    $0x10,%eax
f0103cb6:	66 a3 6e 43 23 f0    	mov    %ax,0xf023436e
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, irqserial_handler, 0);
f0103cbc:	b8 76 43 10 f0       	mov    $0xf0104376,%eax
f0103cc1:	66 a3 80 43 23 f0    	mov    %ax,0xf0234380
f0103cc7:	66 c7 05 82 43 23 f0 	movw   $0x8,0xf0234382
f0103cce:	08 00 
f0103cd0:	c6 05 84 43 23 f0 00 	movb   $0x0,0xf0234384
f0103cd7:	c6 05 85 43 23 f0 8e 	movb   $0x8e,0xf0234385
f0103cde:	c1 e8 10             	shr    $0x10,%eax
f0103ce1:	66 a3 86 43 23 f0    	mov    %ax,0xf0234386
	SETGATE(idt[IRQ_OFFSET + IRQ_SPURIOUS], 0, GD_KT, irqspurious_handler, 0);
f0103ce7:	b8 7c 43 10 f0       	mov    $0xf010437c,%eax
f0103cec:	66 a3 98 43 23 f0    	mov    %ax,0xf0234398
f0103cf2:	66 c7 05 9a 43 23 f0 	movw   $0x8,0xf023439a
f0103cf9:	08 00 
f0103cfb:	c6 05 9c 43 23 f0 00 	movb   $0x0,0xf023439c
f0103d02:	c6 05 9d 43 23 f0 8e 	movb   $0x8e,0xf023439d
f0103d09:	c1 e8 10             	shr    $0x10,%eax
f0103d0c:	66 a3 9e 43 23 f0    	mov    %ax,0xf023439e
	SETGATE(idt[IRQ_OFFSET + IRQ_IDE], 0, GD_KT, irqide_handler, 0);
f0103d12:	b8 82 43 10 f0       	mov    $0xf0104382,%eax
f0103d17:	66 a3 d0 43 23 f0    	mov    %ax,0xf02343d0
f0103d1d:	66 c7 05 d2 43 23 f0 	movw   $0x8,0xf02343d2
f0103d24:	08 00 
f0103d26:	c6 05 d4 43 23 f0 00 	movb   $0x0,0xf02343d4
f0103d2d:	c6 05 d5 43 23 f0 8e 	movb   $0x8e,0xf02343d5
f0103d34:	c1 e8 10             	shr    $0x10,%eax
f0103d37:	66 a3 d6 43 23 f0    	mov    %ax,0xf02343d6
	SETGATE(idt[IRQ_OFFSET + IRQ_ERROR], 0, GD_KT, irqerror_handler, 0);
f0103d3d:	b8 88 43 10 f0       	mov    $0xf0104388,%eax
f0103d42:	66 a3 f8 43 23 f0    	mov    %ax,0xf02343f8
f0103d48:	66 c7 05 fa 43 23 f0 	movw   $0x8,0xf02343fa
f0103d4f:	08 00 
f0103d51:	c6 05 fc 43 23 f0 00 	movb   $0x0,0xf02343fc
f0103d58:	c6 05 fd 43 23 f0 8e 	movb   $0x8e,0xf02343fd
f0103d5f:	c1 e8 10             	shr    $0x10,%eax
f0103d62:	66 a3 fe 43 23 f0    	mov    %ax,0xf02343fe
	trap_init_percpu();
f0103d68:	e8 84 fb ff ff       	call   f01038f1 <trap_init_percpu>
}
f0103d6d:	c9                   	leave  
f0103d6e:	c3                   	ret    

f0103d6f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103d6f:	55                   	push   %ebp
f0103d70:	89 e5                	mov    %esp,%ebp
f0103d72:	53                   	push   %ebx
f0103d73:	83 ec 0c             	sub    $0xc,%esp
f0103d76:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103d79:	ff 33                	pushl  (%ebx)
f0103d7b:	68 a4 75 10 f0       	push   $0xf01075a4
f0103d80:	e8 58 fb ff ff       	call   f01038dd <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103d85:	83 c4 08             	add    $0x8,%esp
f0103d88:	ff 73 04             	pushl  0x4(%ebx)
f0103d8b:	68 b3 75 10 f0       	push   $0xf01075b3
f0103d90:	e8 48 fb ff ff       	call   f01038dd <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103d95:	83 c4 08             	add    $0x8,%esp
f0103d98:	ff 73 08             	pushl  0x8(%ebx)
f0103d9b:	68 c2 75 10 f0       	push   $0xf01075c2
f0103da0:	e8 38 fb ff ff       	call   f01038dd <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103da5:	83 c4 08             	add    $0x8,%esp
f0103da8:	ff 73 0c             	pushl  0xc(%ebx)
f0103dab:	68 d1 75 10 f0       	push   $0xf01075d1
f0103db0:	e8 28 fb ff ff       	call   f01038dd <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103db5:	83 c4 08             	add    $0x8,%esp
f0103db8:	ff 73 10             	pushl  0x10(%ebx)
f0103dbb:	68 e0 75 10 f0       	push   $0xf01075e0
f0103dc0:	e8 18 fb ff ff       	call   f01038dd <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103dc5:	83 c4 08             	add    $0x8,%esp
f0103dc8:	ff 73 14             	pushl  0x14(%ebx)
f0103dcb:	68 ef 75 10 f0       	push   $0xf01075ef
f0103dd0:	e8 08 fb ff ff       	call   f01038dd <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103dd5:	83 c4 08             	add    $0x8,%esp
f0103dd8:	ff 73 18             	pushl  0x18(%ebx)
f0103ddb:	68 fe 75 10 f0       	push   $0xf01075fe
f0103de0:	e8 f8 fa ff ff       	call   f01038dd <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103de5:	83 c4 08             	add    $0x8,%esp
f0103de8:	ff 73 1c             	pushl  0x1c(%ebx)
f0103deb:	68 0d 76 10 f0       	push   $0xf010760d
f0103df0:	e8 e8 fa ff ff       	call   f01038dd <cprintf>
}
f0103df5:	83 c4 10             	add    $0x10,%esp
f0103df8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103dfb:	c9                   	leave  
f0103dfc:	c3                   	ret    

f0103dfd <print_trapframe>:
{
f0103dfd:	55                   	push   %ebp
f0103dfe:	89 e5                	mov    %esp,%ebp
f0103e00:	56                   	push   %esi
f0103e01:	53                   	push   %ebx
f0103e02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103e05:	e8 49 1e 00 00       	call   f0105c53 <cpunum>
f0103e0a:	83 ec 04             	sub    $0x4,%esp
f0103e0d:	50                   	push   %eax
f0103e0e:	53                   	push   %ebx
f0103e0f:	68 71 76 10 f0       	push   $0xf0107671
f0103e14:	e8 c4 fa ff ff       	call   f01038dd <cprintf>
	print_regs(&tf->tf_regs);
f0103e19:	89 1c 24             	mov    %ebx,(%esp)
f0103e1c:	e8 4e ff ff ff       	call   f0103d6f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103e21:	83 c4 08             	add    $0x8,%esp
f0103e24:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103e28:	50                   	push   %eax
f0103e29:	68 8f 76 10 f0       	push   $0xf010768f
f0103e2e:	e8 aa fa ff ff       	call   f01038dd <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103e33:	83 c4 08             	add    $0x8,%esp
f0103e36:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103e3a:	50                   	push   %eax
f0103e3b:	68 a2 76 10 f0       	push   $0xf01076a2
f0103e40:	e8 98 fa ff ff       	call   f01038dd <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e45:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0103e48:	83 c4 10             	add    $0x10,%esp
f0103e4b:	83 f8 13             	cmp    $0x13,%eax
f0103e4e:	76 1f                	jbe    f0103e6f <print_trapframe+0x72>
		return "System call";
f0103e50:	ba 1c 76 10 f0       	mov    $0xf010761c,%edx
	if (trapno == T_SYSCALL)
f0103e55:	83 f8 30             	cmp    $0x30,%eax
f0103e58:	74 1c                	je     f0103e76 <print_trapframe+0x79>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103e5a:	8d 50 e0             	lea    -0x20(%eax),%edx
	return "(unknown trap)";
f0103e5d:	83 fa 10             	cmp    $0x10,%edx
f0103e60:	ba 28 76 10 f0       	mov    $0xf0107628,%edx
f0103e65:	b9 3b 76 10 f0       	mov    $0xf010763b,%ecx
f0103e6a:	0f 43 d1             	cmovae %ecx,%edx
f0103e6d:	eb 07                	jmp    f0103e76 <print_trapframe+0x79>
		return excnames[trapno];
f0103e6f:	8b 14 85 60 79 10 f0 	mov    -0xfef86a0(,%eax,4),%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103e76:	83 ec 04             	sub    $0x4,%esp
f0103e79:	52                   	push   %edx
f0103e7a:	50                   	push   %eax
f0103e7b:	68 b5 76 10 f0       	push   $0xf01076b5
f0103e80:	e8 58 fa ff ff       	call   f01038dd <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103e85:	83 c4 10             	add    $0x10,%esp
f0103e88:	39 1d 60 4a 23 f0    	cmp    %ebx,0xf0234a60
f0103e8e:	0f 84 a6 00 00 00    	je     f0103f3a <print_trapframe+0x13d>
	cprintf("  err  0x%08x", tf->tf_err);
f0103e94:	83 ec 08             	sub    $0x8,%esp
f0103e97:	ff 73 2c             	pushl  0x2c(%ebx)
f0103e9a:	68 d6 76 10 f0       	push   $0xf01076d6
f0103e9f:	e8 39 fa ff ff       	call   f01038dd <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0103ea4:	83 c4 10             	add    $0x10,%esp
f0103ea7:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103eab:	0f 85 ac 00 00 00    	jne    f0103f5d <print_trapframe+0x160>
			tf->tf_err & 1 ? "protection" : "not-present");
f0103eb1:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0103eb4:	89 c2                	mov    %eax,%edx
f0103eb6:	83 e2 01             	and    $0x1,%edx
f0103eb9:	b9 4a 76 10 f0       	mov    $0xf010764a,%ecx
f0103ebe:	ba 55 76 10 f0       	mov    $0xf0107655,%edx
f0103ec3:	0f 44 ca             	cmove  %edx,%ecx
f0103ec6:	89 c2                	mov    %eax,%edx
f0103ec8:	83 e2 02             	and    $0x2,%edx
f0103ecb:	be 61 76 10 f0       	mov    $0xf0107661,%esi
f0103ed0:	ba 67 76 10 f0       	mov    $0xf0107667,%edx
f0103ed5:	0f 45 d6             	cmovne %esi,%edx
f0103ed8:	83 e0 04             	and    $0x4,%eax
f0103edb:	b8 6c 76 10 f0       	mov    $0xf010766c,%eax
f0103ee0:	be a1 77 10 f0       	mov    $0xf01077a1,%esi
f0103ee5:	0f 44 c6             	cmove  %esi,%eax
f0103ee8:	51                   	push   %ecx
f0103ee9:	52                   	push   %edx
f0103eea:	50                   	push   %eax
f0103eeb:	68 e4 76 10 f0       	push   $0xf01076e4
f0103ef0:	e8 e8 f9 ff ff       	call   f01038dd <cprintf>
f0103ef5:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103ef8:	83 ec 08             	sub    $0x8,%esp
f0103efb:	ff 73 30             	pushl  0x30(%ebx)
f0103efe:	68 f3 76 10 f0       	push   $0xf01076f3
f0103f03:	e8 d5 f9 ff ff       	call   f01038dd <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103f08:	83 c4 08             	add    $0x8,%esp
f0103f0b:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103f0f:	50                   	push   %eax
f0103f10:	68 02 77 10 f0       	push   $0xf0107702
f0103f15:	e8 c3 f9 ff ff       	call   f01038dd <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103f1a:	83 c4 08             	add    $0x8,%esp
f0103f1d:	ff 73 38             	pushl  0x38(%ebx)
f0103f20:	68 15 77 10 f0       	push   $0xf0107715
f0103f25:	e8 b3 f9 ff ff       	call   f01038dd <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103f2a:	83 c4 10             	add    $0x10,%esp
f0103f2d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103f31:	75 3c                	jne    f0103f6f <print_trapframe+0x172>
}
f0103f33:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103f36:	5b                   	pop    %ebx
f0103f37:	5e                   	pop    %esi
f0103f38:	5d                   	pop    %ebp
f0103f39:	c3                   	ret    
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103f3a:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103f3e:	0f 85 50 ff ff ff    	jne    f0103e94 <print_trapframe+0x97>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103f44:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103f47:	83 ec 08             	sub    $0x8,%esp
f0103f4a:	50                   	push   %eax
f0103f4b:	68 c7 76 10 f0       	push   $0xf01076c7
f0103f50:	e8 88 f9 ff ff       	call   f01038dd <cprintf>
f0103f55:	83 c4 10             	add    $0x10,%esp
f0103f58:	e9 37 ff ff ff       	jmp    f0103e94 <print_trapframe+0x97>
		cprintf("\n");
f0103f5d:	83 ec 0c             	sub    $0xc,%esp
f0103f60:	68 49 74 10 f0       	push   $0xf0107449
f0103f65:	e8 73 f9 ff ff       	call   f01038dd <cprintf>
f0103f6a:	83 c4 10             	add    $0x10,%esp
f0103f6d:	eb 89                	jmp    f0103ef8 <print_trapframe+0xfb>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103f6f:	83 ec 08             	sub    $0x8,%esp
f0103f72:	ff 73 3c             	pushl  0x3c(%ebx)
f0103f75:	68 24 77 10 f0       	push   $0xf0107724
f0103f7a:	e8 5e f9 ff ff       	call   f01038dd <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103f7f:	83 c4 08             	add    $0x8,%esp
f0103f82:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103f86:	50                   	push   %eax
f0103f87:	68 33 77 10 f0       	push   $0xf0107733
f0103f8c:	e8 4c f9 ff ff       	call   f01038dd <cprintf>
f0103f91:	83 c4 10             	add    $0x10,%esp
}
f0103f94:	eb 9d                	jmp    f0103f33 <print_trapframe+0x136>

f0103f96 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103f96:	55                   	push   %ebp
f0103f97:	89 e5                	mov    %esp,%ebp
f0103f99:	57                   	push   %edi
f0103f9a:	56                   	push   %esi
f0103f9b:	53                   	push   %ebx
f0103f9c:	83 ec 0c             	sub    $0xc,%esp
f0103f9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103fa2:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
    	if ((tf->tf_cs & 3) == 0)
f0103fa5:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103fa9:	74 5d                	je     f0104008 <page_fault_handler+0x72>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103fab:	e8 a3 1c 00 00       	call   f0105c53 <cpunum>
f0103fb0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fb3:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103fb9:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103fbd:	75 60                	jne    f010401f <page_fault_handler+0x89>
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
		curenv->env_tf.tf_esp = utf_addr;
		env_run(curenv);
	}
		// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",curenv->env_id, fault_va, tf->tf_eip);
f0103fbf:	8b 7b 30             	mov    0x30(%ebx),%edi
f0103fc2:	e8 8c 1c 00 00       	call   f0105c53 <cpunum>
f0103fc7:	57                   	push   %edi
f0103fc8:	56                   	push   %esi
f0103fc9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fcc:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0103fd2:	ff 70 48             	pushl  0x48(%eax)
f0103fd5:	68 20 79 10 f0       	push   $0xf0107920
f0103fda:	e8 fe f8 ff ff       	call   f01038dd <cprintf>
	print_trapframe(tf);
f0103fdf:	89 1c 24             	mov    %ebx,(%esp)
f0103fe2:	e8 16 fe ff ff       	call   f0103dfd <print_trapframe>
	env_destroy(curenv);
f0103fe7:	e8 67 1c 00 00       	call   f0105c53 <cpunum>
f0103fec:	83 c4 04             	add    $0x4,%esp
f0103fef:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ff2:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0103ff8:	e8 e4 f5 ff ff       	call   f01035e1 <env_destroy>
}
f0103ffd:	83 c4 10             	add    $0x10,%esp
f0104000:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104003:	5b                   	pop    %ebx
f0104004:	5e                   	pop    %esi
f0104005:	5f                   	pop    %edi
f0104006:	5d                   	pop    %ebp
f0104007:	c3                   	ret    
        	panic("page_fault_handler():page fault in kernel mode!\n");
f0104008:	83 ec 04             	sub    $0x4,%esp
f010400b:	68 ec 78 10 f0       	push   $0xf01078ec
f0104010:	68 50 01 00 00       	push   $0x150
f0104015:	68 46 77 10 f0       	push   $0xf0107746
f010401a:	e8 21 c0 ff ff       	call   f0100040 <_panic>
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f010401f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104022:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
f0104028:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f010402d:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0104033:	77 05                	ja     f010403a <page_fault_handler+0xa4>
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0104035:	83 e8 38             	sub    $0x38,%eax
f0104038:	89 c7                	mov    %eax,%edi
		user_mem_assert(curenv, (void*)utf_addr, 1, PTE_W);//1 is enough
f010403a:	e8 14 1c 00 00       	call   f0105c53 <cpunum>
f010403f:	6a 02                	push   $0x2
f0104041:	6a 01                	push   $0x1
f0104043:	57                   	push   %edi
f0104044:	6b c0 74             	imul   $0x74,%eax,%eax
f0104047:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f010404d:	e8 e7 ee ff ff       	call   f0102f39 <user_mem_assert>
		utf->utf_fault_va = fault_va;
f0104052:	89 fa                	mov    %edi,%edx
f0104054:	89 37                	mov    %esi,(%edi)
		utf->utf_err = tf->tf_err;
f0104056:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104059:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs = tf->tf_regs;
f010405c:	8d 7f 08             	lea    0x8(%edi),%edi
f010405f:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104064:	89 de                	mov    %ebx,%esi
f0104066:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip = tf->tf_eip;
f0104068:	8b 43 30             	mov    0x30(%ebx),%eax
f010406b:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags = tf->tf_eflags;
f010406e:	8b 43 38             	mov    0x38(%ebx),%eax
f0104071:	89 d7                	mov    %edx,%edi
f0104073:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp = tf->tf_esp;
f0104076:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104079:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f010407c:	e8 d2 1b 00 00       	call   f0105c53 <cpunum>
f0104081:	6b c0 74             	imul   $0x74,%eax,%eax
f0104084:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010408a:	8b 58 64             	mov    0x64(%eax),%ebx
f010408d:	e8 c1 1b 00 00       	call   f0105c53 <cpunum>
f0104092:	6b c0 74             	imul   $0x74,%eax,%eax
f0104095:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010409b:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = utf_addr;
f010409e:	e8 b0 1b 00 00       	call   f0105c53 <cpunum>
f01040a3:	6b c0 74             	imul   $0x74,%eax,%eax
f01040a6:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01040ac:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f01040af:	e8 9f 1b 00 00       	call   f0105c53 <cpunum>
f01040b4:	83 c4 04             	add    $0x4,%esp
f01040b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040ba:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f01040c0:	e8 bb f5 ff ff       	call   f0103680 <env_run>

f01040c5 <trap>:
{
f01040c5:	55                   	push   %ebp
f01040c6:	89 e5                	mov    %esp,%ebp
f01040c8:	57                   	push   %edi
f01040c9:	56                   	push   %esi
f01040ca:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::: "cc");
f01040cd:	fc                   	cld    
	if (panicstr)
f01040ce:	83 3d 80 4e 23 f0 00 	cmpl   $0x0,0xf0234e80
f01040d5:	74 01                	je     f01040d8 <trap+0x13>
		asm volatile("hlt");
f01040d7:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01040d8:	e8 76 1b 00 00       	call   f0105c53 <cpunum>
f01040dd:	6b d0 74             	imul   $0x74,%eax,%edx
f01040e0:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01040e3:	b8 01 00 00 00       	mov    $0x1,%eax
f01040e8:	f0 87 82 20 50 23 f0 	lock xchg %eax,-0xfdcafe0(%edx)
f01040ef:	83 f8 02             	cmp    $0x2,%eax
f01040f2:	0f 84 b0 00 00 00    	je     f01041a8 <trap+0xe3>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01040f8:	9c                   	pushf  
f01040f9:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01040fa:	f6 c4 02             	test   $0x2,%ah
f01040fd:	0f 85 ba 00 00 00    	jne    f01041bd <trap+0xf8>
	if ((tf->tf_cs & 3) == 3) {
f0104103:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104107:	83 e0 03             	and    $0x3,%eax
f010410a:	66 83 f8 03          	cmp    $0x3,%ax
f010410e:	0f 84 c2 00 00 00    	je     f01041d6 <trap+0x111>
	last_tf = tf;
f0104114:	89 35 60 4a 23 f0    	mov    %esi,0xf0234a60
	if (tf->tf_trapno == T_PGFLT) {
f010411a:	8b 46 28             	mov    0x28(%esi),%eax
f010411d:	83 f8 0e             	cmp    $0xe,%eax
f0104120:	0f 84 55 01 00 00    	je     f010427b <trap+0x1b6>
	if (tf->tf_trapno == T_BRKPT) {
f0104126:	83 f8 03             	cmp    $0x3,%eax
f0104129:	0f 84 5d 01 00 00    	je     f010428c <trap+0x1c7>
	if (tf->tf_trapno == T_SYSCALL) {
f010412f:	83 f8 30             	cmp    $0x30,%eax
f0104132:	0f 84 65 01 00 00    	je     f010429d <trap+0x1d8>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104138:	83 f8 27             	cmp    $0x27,%eax
f010413b:	0f 84 80 01 00 00    	je     f01042c1 <trap+0x1fc>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104141:	83 f8 20             	cmp    $0x20,%eax
f0104144:	0f 84 94 01 00 00    	je     f01042de <trap+0x219>
	print_trapframe(tf);
f010414a:	83 ec 0c             	sub    $0xc,%esp
f010414d:	56                   	push   %esi
f010414e:	e8 aa fc ff ff       	call   f0103dfd <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104153:	83 c4 10             	add    $0x10,%esp
f0104156:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010415b:	0f 84 87 01 00 00    	je     f01042e8 <trap+0x223>
		env_destroy(curenv);
f0104161:	e8 ed 1a 00 00       	call   f0105c53 <cpunum>
f0104166:	83 ec 0c             	sub    $0xc,%esp
f0104169:	6b c0 74             	imul   $0x74,%eax,%eax
f010416c:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104172:	e8 6a f4 ff ff       	call   f01035e1 <env_destroy>
f0104177:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010417a:	e8 d4 1a 00 00       	call   f0105c53 <cpunum>
f010417f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104182:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f0104189:	74 18                	je     f01041a3 <trap+0xde>
f010418b:	e8 c3 1a 00 00       	call   f0105c53 <cpunum>
f0104190:	6b c0 74             	imul   $0x74,%eax,%eax
f0104193:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104199:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010419d:	0f 84 5c 01 00 00    	je     f01042ff <trap+0x23a>
		sched_yield();
f01041a3:	e8 c7 02 00 00       	call   f010446f <sched_yield>
	spin_lock(&kernel_lock);
f01041a8:	83 ec 0c             	sub    $0xc,%esp
f01041ab:	68 c0 13 12 f0       	push   $0xf01213c0
f01041b0:	e8 0e 1d 00 00       	call   f0105ec3 <spin_lock>
f01041b5:	83 c4 10             	add    $0x10,%esp
f01041b8:	e9 3b ff ff ff       	jmp    f01040f8 <trap+0x33>
	assert(!(read_eflags() & FL_IF));
f01041bd:	68 52 77 10 f0       	push   $0xf0107752
f01041c2:	68 67 71 10 f0       	push   $0xf0107167
f01041c7:	68 19 01 00 00       	push   $0x119
f01041cc:	68 46 77 10 f0       	push   $0xf0107746
f01041d1:	e8 6a be ff ff       	call   f0100040 <_panic>
f01041d6:	83 ec 0c             	sub    $0xc,%esp
f01041d9:	68 c0 13 12 f0       	push   $0xf01213c0
f01041de:	e8 e0 1c 00 00       	call   f0105ec3 <spin_lock>
		assert(curenv);
f01041e3:	e8 6b 1a 00 00       	call   f0105c53 <cpunum>
f01041e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01041eb:	83 c4 10             	add    $0x10,%esp
f01041ee:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f01041f5:	74 3e                	je     f0104235 <trap+0x170>
		if (curenv->env_status == ENV_DYING) {
f01041f7:	e8 57 1a 00 00       	call   f0105c53 <cpunum>
f01041fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ff:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104205:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104209:	74 43                	je     f010424e <trap+0x189>
		curenv->env_tf = *tf;
f010420b:	e8 43 1a 00 00       	call   f0105c53 <cpunum>
f0104210:	6b c0 74             	imul   $0x74,%eax,%eax
f0104213:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104219:	b9 11 00 00 00       	mov    $0x11,%ecx
f010421e:	89 c7                	mov    %eax,%edi
f0104220:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f0104222:	e8 2c 1a 00 00       	call   f0105c53 <cpunum>
f0104227:	6b c0 74             	imul   $0x74,%eax,%eax
f010422a:	8b b0 28 50 23 f0    	mov    -0xfdcafd8(%eax),%esi
f0104230:	e9 df fe ff ff       	jmp    f0104114 <trap+0x4f>
		assert(curenv);
f0104235:	68 6b 77 10 f0       	push   $0xf010776b
f010423a:	68 67 71 10 f0       	push   $0xf0107167
f010423f:	68 22 01 00 00       	push   $0x122
f0104244:	68 46 77 10 f0       	push   $0xf0107746
f0104249:	e8 f2 bd ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f010424e:	e8 00 1a 00 00       	call   f0105c53 <cpunum>
f0104253:	83 ec 0c             	sub    $0xc,%esp
f0104256:	6b c0 74             	imul   $0x74,%eax,%eax
f0104259:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f010425f:	e8 8f f1 ff ff       	call   f01033f3 <env_free>
			curenv = NULL;
f0104264:	e8 ea 19 00 00       	call   f0105c53 <cpunum>
f0104269:	6b c0 74             	imul   $0x74,%eax,%eax
f010426c:	c7 80 28 50 23 f0 00 	movl   $0x0,-0xfdcafd8(%eax)
f0104273:	00 00 00 
			sched_yield();
f0104276:	e8 f4 01 00 00       	call   f010446f <sched_yield>
		page_fault_handler(tf);
f010427b:	83 ec 0c             	sub    $0xc,%esp
f010427e:	56                   	push   %esi
f010427f:	e8 12 fd ff ff       	call   f0103f96 <page_fault_handler>
f0104284:	83 c4 10             	add    $0x10,%esp
f0104287:	e9 ee fe ff ff       	jmp    f010417a <trap+0xb5>
		monitor(tf);
f010428c:	83 ec 0c             	sub    $0xc,%esp
f010428f:	56                   	push   %esi
f0104290:	e8 a0 c6 ff ff       	call   f0100935 <monitor>
f0104295:	83 c4 10             	add    $0x10,%esp
f0104298:	e9 dd fe ff ff       	jmp    f010417a <trap+0xb5>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010429d:	83 ec 08             	sub    $0x8,%esp
f01042a0:	ff 76 04             	pushl  0x4(%esi)
f01042a3:	ff 36                	pushl  (%esi)
f01042a5:	ff 76 10             	pushl  0x10(%esi)
f01042a8:	ff 76 18             	pushl  0x18(%esi)
f01042ab:	ff 76 14             	pushl  0x14(%esi)
f01042ae:	ff 76 1c             	pushl  0x1c(%esi)
f01042b1:	e8 70 02 00 00       	call   f0104526 <syscall>
		tf->tf_regs.reg_eax = 
f01042b6:	89 46 1c             	mov    %eax,0x1c(%esi)
f01042b9:	83 c4 20             	add    $0x20,%esp
f01042bc:	e9 b9 fe ff ff       	jmp    f010417a <trap+0xb5>
		cprintf("Spurious interrupt on irq 7\n");
f01042c1:	83 ec 0c             	sub    $0xc,%esp
f01042c4:	68 72 77 10 f0       	push   $0xf0107772
f01042c9:	e8 0f f6 ff ff       	call   f01038dd <cprintf>
		print_trapframe(tf);
f01042ce:	89 34 24             	mov    %esi,(%esp)
f01042d1:	e8 27 fb ff ff       	call   f0103dfd <print_trapframe>
f01042d6:	83 c4 10             	add    $0x10,%esp
f01042d9:	e9 9c fe ff ff       	jmp    f010417a <trap+0xb5>
                lapic_eoi();
f01042de:	e8 bc 1a 00 00       	call   f0105d9f <lapic_eoi>
                sched_yield();
f01042e3:	e8 87 01 00 00       	call   f010446f <sched_yield>
		panic("unhandled trap in kernel");
f01042e8:	83 ec 04             	sub    $0x4,%esp
f01042eb:	68 8f 77 10 f0       	push   $0xf010778f
f01042f0:	68 ff 00 00 00       	push   $0xff
f01042f5:	68 46 77 10 f0       	push   $0xf0107746
f01042fa:	e8 41 bd ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f01042ff:	e8 4f 19 00 00       	call   f0105c53 <cpunum>
f0104304:	83 ec 0c             	sub    $0xc,%esp
f0104307:	6b c0 74             	imul   $0x74,%eax,%eax
f010430a:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104310:	e8 6b f3 ff ff       	call   f0103680 <env_run>
f0104315:	90                   	nop

f0104316 <th0>:
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
	TRAPHANDLER_NOEC(th0, 0)
f0104316:	6a 00                	push   $0x0
f0104318:	6a 00                	push   $0x0
f010431a:	eb 72                	jmp    f010438e <_alltraps>

f010431c <th1>:
	TRAPHANDLER_NOEC(th1, 1)
f010431c:	6a 00                	push   $0x0
f010431e:	6a 01                	push   $0x1
f0104320:	eb 6c                	jmp    f010438e <_alltraps>

f0104322 <th3>:
	TRAPHANDLER_NOEC(th3, 3)
f0104322:	6a 00                	push   $0x0
f0104324:	6a 03                	push   $0x3
f0104326:	eb 66                	jmp    f010438e <_alltraps>

f0104328 <th4>:
	TRAPHANDLER_NOEC(th4, 4)
f0104328:	6a 00                	push   $0x0
f010432a:	6a 04                	push   $0x4
f010432c:	eb 60                	jmp    f010438e <_alltraps>

f010432e <th5>:
	TRAPHANDLER_NOEC(th5, 5)
f010432e:	6a 00                	push   $0x0
f0104330:	6a 05                	push   $0x5
f0104332:	eb 5a                	jmp    f010438e <_alltraps>

f0104334 <th6>:
	TRAPHANDLER_NOEC(th6, 6)
f0104334:	6a 00                	push   $0x0
f0104336:	6a 06                	push   $0x6
f0104338:	eb 54                	jmp    f010438e <_alltraps>

f010433a <th7>:
	TRAPHANDLER_NOEC(th7, 7)
f010433a:	6a 00                	push   $0x0
f010433c:	6a 07                	push   $0x7
f010433e:	eb 4e                	jmp    f010438e <_alltraps>

f0104340 <th8>:
	TRAPHANDLER(th8, 8)
f0104340:	6a 08                	push   $0x8
f0104342:	eb 4a                	jmp    f010438e <_alltraps>

f0104344 <th9>:
	TRAPHANDLER_NOEC(th9, 9)
f0104344:	6a 00                	push   $0x0
f0104346:	6a 09                	push   $0x9
f0104348:	eb 44                	jmp    f010438e <_alltraps>

f010434a <th10>:
	TRAPHANDLER(th10, 10)
f010434a:	6a 0a                	push   $0xa
f010434c:	eb 40                	jmp    f010438e <_alltraps>

f010434e <th11>:
	TRAPHANDLER(th11, 11)
f010434e:	6a 0b                	push   $0xb
f0104350:	eb 3c                	jmp    f010438e <_alltraps>

f0104352 <th12>:
	TRAPHANDLER(th12, 12)
f0104352:	6a 0c                	push   $0xc
f0104354:	eb 38                	jmp    f010438e <_alltraps>

f0104356 <th13>:
	TRAPHANDLER(th13, 13)
f0104356:	6a 0d                	push   $0xd
f0104358:	eb 34                	jmp    f010438e <_alltraps>

f010435a <th14>:
	TRAPHANDLER(th14, 14)
f010435a:	6a 0e                	push   $0xe
f010435c:	eb 30                	jmp    f010438e <_alltraps>

f010435e <th16>:
	TRAPHANDLER_NOEC(th16, 16)
f010435e:	6a 00                	push   $0x0
f0104360:	6a 10                	push   $0x10
f0104362:	eb 2a                	jmp    f010438e <_alltraps>

f0104364 <th_syscall>:
	TRAPHANDLER_NOEC(th_syscall, T_SYSCALL)
f0104364:	6a 00                	push   $0x0
f0104366:	6a 30                	push   $0x30
f0104368:	eb 24                	jmp    f010438e <_alltraps>

f010436a <irqtimer_handler>:
	TRAPHANDLER_NOEC(irqtimer_handler, IRQ_OFFSET + IRQ_TIMER)
f010436a:	6a 00                	push   $0x0
f010436c:	6a 20                	push   $0x20
f010436e:	eb 1e                	jmp    f010438e <_alltraps>

f0104370 <irqkbd_handler>:
	TRAPHANDLER_NOEC(irqkbd_handler, IRQ_OFFSET + IRQ_KBD)
f0104370:	6a 00                	push   $0x0
f0104372:	6a 21                	push   $0x21
f0104374:	eb 18                	jmp    f010438e <_alltraps>

f0104376 <irqserial_handler>:
	TRAPHANDLER_NOEC(irqserial_handler, IRQ_OFFSET + IRQ_SERIAL)
f0104376:	6a 00                	push   $0x0
f0104378:	6a 24                	push   $0x24
f010437a:	eb 12                	jmp    f010438e <_alltraps>

f010437c <irqspurious_handler>:
	TRAPHANDLER_NOEC(irqspurious_handler, IRQ_OFFSET + IRQ_SPURIOUS)
f010437c:	6a 00                	push   $0x0
f010437e:	6a 27                	push   $0x27
f0104380:	eb 0c                	jmp    f010438e <_alltraps>

f0104382 <irqide_handler>:
	TRAPHANDLER_NOEC(irqide_handler, IRQ_OFFSET + IRQ_IDE)
f0104382:	6a 00                	push   $0x0
f0104384:	6a 2e                	push   $0x2e
f0104386:	eb 06                	jmp    f010438e <_alltraps>

f0104388 <irqerror_handler>:
	TRAPHANDLER_NOEC(irqerror_handler, IRQ_OFFSET + IRQ_ERROR)
f0104388:	6a 00                	push   $0x0
f010438a:	6a 33                	push   $0x33
f010438c:	eb 00                	jmp    f010438e <_alltraps>

f010438e <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
	pushl %ds
f010438e:	1e                   	push   %ds
	pushl %es
f010438f:	06                   	push   %es
	pushal
f0104390:	60                   	pusha  
	pushl $GD_KD
f0104391:	6a 10                	push   $0x10
	popl %ds
f0104393:	1f                   	pop    %ds
	pushl $GD_KD
f0104394:	6a 10                	push   $0x10
	popl %es
f0104396:	07                   	pop    %es
	pushl %esp
f0104397:	54                   	push   %esp
	call trap
f0104398:	e8 28 fd ff ff       	call   f01040c5 <trap>

f010439d <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f010439d:	55                   	push   %ebp
f010439e:	89 e5                	mov    %esp,%ebp
f01043a0:	83 ec 08             	sub    $0x8,%esp
f01043a3:	a1 44 42 23 f0       	mov    0xf0234244,%eax
f01043a8:	83 c0 54             	add    $0x54,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01043ab:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01043b0:	8b 10                	mov    (%eax),%edx
f01043b2:	83 ea 01             	sub    $0x1,%edx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01043b5:	83 fa 02             	cmp    $0x2,%edx
f01043b8:	76 2d                	jbe    f01043e7 <sched_halt+0x4a>
	for (i = 0; i < NENV; i++) {
f01043ba:	83 c1 01             	add    $0x1,%ecx
f01043bd:	83 c0 7c             	add    $0x7c,%eax
f01043c0:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043c6:	75 e8                	jne    f01043b0 <sched_halt+0x13>
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
		cprintf("No runnable environments in the system!\n");
f01043c8:	83 ec 0c             	sub    $0xc,%esp
f01043cb:	68 b0 79 10 f0       	push   $0xf01079b0
f01043d0:	e8 08 f5 ff ff       	call   f01038dd <cprintf>
f01043d5:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01043d8:	83 ec 0c             	sub    $0xc,%esp
f01043db:	6a 00                	push   $0x0
f01043dd:	e8 53 c5 ff ff       	call   f0100935 <monitor>
f01043e2:	83 c4 10             	add    $0x10,%esp
f01043e5:	eb f1                	jmp    f01043d8 <sched_halt+0x3b>
	if (i == NENV) {
f01043e7:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01043ed:	74 d9                	je     f01043c8 <sched_halt+0x2b>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01043ef:	e8 5f 18 00 00       	call   f0105c53 <cpunum>
f01043f4:	6b c0 74             	imul   $0x74,%eax,%eax
f01043f7:	c7 80 28 50 23 f0 00 	movl   $0x0,-0xfdcafd8(%eax)
f01043fe:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104401:	a1 8c 4e 23 f0       	mov    0xf0234e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104406:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010440b:	76 50                	jbe    f010445d <sched_halt+0xc0>
	return (physaddr_t)kva - KERNBASE;
f010440d:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104412:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104415:	e8 39 18 00 00       	call   f0105c53 <cpunum>
f010441a:	6b d0 74             	imul   $0x74,%eax,%edx
f010441d:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104420:	b8 02 00 00 00       	mov    $0x2,%eax
f0104425:	f0 87 82 20 50 23 f0 	lock xchg %eax,-0xfdcafe0(%edx)
	spin_unlock(&kernel_lock);
f010442c:	83 ec 0c             	sub    $0xc,%esp
f010442f:	68 c0 13 12 f0       	push   $0xf01213c0
f0104434:	e8 27 1b 00 00       	call   f0105f60 <spin_unlock>
	asm volatile("pause");
f0104439:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010443b:	e8 13 18 00 00       	call   f0105c53 <cpunum>
f0104440:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile (
f0104443:	8b 80 30 50 23 f0    	mov    -0xfdcafd0(%eax),%eax
f0104449:	bd 00 00 00 00       	mov    $0x0,%ebp
f010444e:	89 c4                	mov    %eax,%esp
f0104450:	6a 00                	push   $0x0
f0104452:	6a 00                	push   $0x0
f0104454:	fb                   	sti    
f0104455:	f4                   	hlt    
f0104456:	eb fd                	jmp    f0104455 <sched_halt+0xb8>
}
f0104458:	83 c4 10             	add    $0x10,%esp
f010445b:	c9                   	leave  
f010445c:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010445d:	50                   	push   %eax
f010445e:	68 e8 62 10 f0       	push   $0xf01062e8
f0104463:	6a 46                	push   $0x46
f0104465:	68 d9 79 10 f0       	push   $0xf01079d9
f010446a:	e8 d1 bb ff ff       	call   f0100040 <_panic>

f010446f <sched_yield>:
{
f010446f:	55                   	push   %ebp
f0104470:	89 e5                	mov    %esp,%ebp
f0104472:	56                   	push   %esi
f0104473:	53                   	push   %ebx
	if (curenv) cur=ENVX(curenv->env_id)+1;
f0104474:	e8 da 17 00 00       	call   f0105c53 <cpunum>
f0104479:	6b c0 74             	imul   $0x74,%eax,%eax
	int i, cur=0;
f010447c:	b9 00 00 00 00       	mov    $0x0,%ecx
	if (curenv) cur=ENVX(curenv->env_id)+1;
f0104481:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f0104488:	74 1a                	je     f01044a4 <sched_yield+0x35>
f010448a:	e8 c4 17 00 00       	call   f0105c53 <cpunum>
f010448f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104492:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104498:	8b 48 48             	mov    0x48(%eax),%ecx
f010449b:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01044a1:	83 c1 01             	add    $0x1,%ecx
		if (envs[j].env_status == ENV_RUNNABLE) {
f01044a4:	8b 1d 44 42 23 f0    	mov    0xf0234244,%ebx
f01044aa:	89 ca                	mov    %ecx,%edx
f01044ac:	81 c1 00 04 00 00    	add    $0x400,%ecx
		int j = (cur+i) % NENV;
f01044b2:	89 d6                	mov    %edx,%esi
f01044b4:	c1 fe 1f             	sar    $0x1f,%esi
f01044b7:	c1 ee 16             	shr    $0x16,%esi
f01044ba:	8d 04 32             	lea    (%edx,%esi,1),%eax
f01044bd:	25 ff 03 00 00       	and    $0x3ff,%eax
f01044c2:	29 f0                	sub    %esi,%eax
		if (envs[j].env_status == ENV_RUNNABLE) {
f01044c4:	6b c0 7c             	imul   $0x7c,%eax,%eax
f01044c7:	01 d8                	add    %ebx,%eax
f01044c9:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f01044cd:	74 38                	je     f0104507 <sched_yield+0x98>
f01044cf:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < NENV; i++) {
f01044d2:	39 ca                	cmp    %ecx,%edx
f01044d4:	75 dc                	jne    f01044b2 <sched_yield+0x43>
	if (curenv && curenv->env_status == ENV_RUNNING)
f01044d6:	e8 78 17 00 00       	call   f0105c53 <cpunum>
f01044db:	6b c0 74             	imul   $0x74,%eax,%eax
f01044de:	83 b8 28 50 23 f0 00 	cmpl   $0x0,-0xfdcafd8(%eax)
f01044e5:	74 14                	je     f01044fb <sched_yield+0x8c>
f01044e7:	e8 67 17 00 00       	call   f0105c53 <cpunum>
f01044ec:	6b c0 74             	imul   $0x74,%eax,%eax
f01044ef:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01044f5:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01044f9:	74 15                	je     f0104510 <sched_yield+0xa1>
	sched_halt();
f01044fb:	e8 9d fe ff ff       	call   f010439d <sched_halt>
}
f0104500:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104503:	5b                   	pop    %ebx
f0104504:	5e                   	pop    %esi
f0104505:	5d                   	pop    %ebp
f0104506:	c3                   	ret    
			env_run(envs + j);
f0104507:	83 ec 0c             	sub    $0xc,%esp
f010450a:	50                   	push   %eax
f010450b:	e8 70 f1 ff ff       	call   f0103680 <env_run>
		env_run(curenv);
f0104510:	e8 3e 17 00 00       	call   f0105c53 <cpunum>
f0104515:	83 ec 0c             	sub    $0xc,%esp
f0104518:	6b c0 74             	imul   $0x74,%eax,%eax
f010451b:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104521:	e8 5a f1 ff ff       	call   f0103680 <env_run>

f0104526 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104526:	55                   	push   %ebp
f0104527:	89 e5                	mov    %esp,%ebp
f0104529:	57                   	push   %edi
f010452a:	56                   	push   %esi
f010452b:	53                   	push   %ebx
f010452c:	83 ec 1c             	sub    $0x1c,%esp
f010452f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int ret = 0;
	switch (syscallno) {
f0104532:	83 f8 0c             	cmp    $0xc,%eax
f0104535:	0f 87 85 05 00 00    	ja     f0104ac0 <syscall+0x59a>
f010453b:	ff 24 85 20 7a 10 f0 	jmp    *-0xfef85e0(,%eax,4)
	user_mem_assert(curenv, s, len, 0);
f0104542:	e8 0c 17 00 00       	call   f0105c53 <cpunum>
f0104547:	6a 00                	push   $0x0
f0104549:	ff 75 10             	pushl  0x10(%ebp)
f010454c:	ff 75 0c             	pushl  0xc(%ebp)
f010454f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104552:	ff b0 28 50 23 f0    	pushl  -0xfdcafd8(%eax)
f0104558:	e8 dc e9 ff ff       	call   f0102f39 <user_mem_assert>
	cprintf("%.*s", len, s);
f010455d:	83 c4 0c             	add    $0xc,%esp
f0104560:	ff 75 0c             	pushl  0xc(%ebp)
f0104563:	ff 75 10             	pushl  0x10(%ebp)
f0104566:	68 e6 79 10 f0       	push   $0xf01079e6
f010456b:	e8 6d f3 ff ff       	call   f01038dd <cprintf>
f0104570:	83 c4 10             	add    $0x10,%esp
		case SYS_cputs: 
			sys_cputs((char*)a1, a2);
			ret = 0;
f0104573:	bb 00 00 00 00       	mov    $0x0,%ebx
		default:
			ret = -E_INVAL;
	}
	return ret;	
	panic("syscall not implemented");
}
f0104578:	89 d8                	mov    %ebx,%eax
f010457a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010457d:	5b                   	pop    %ebx
f010457e:	5e                   	pop    %esi
f010457f:	5f                   	pop    %edi
f0104580:	5d                   	pop    %ebp
f0104581:	c3                   	ret    
	return cons_getc();
f0104582:	e8 72 c0 ff ff       	call   f01005f9 <cons_getc>
f0104587:	89 c3                	mov    %eax,%ebx
			break;
f0104589:	eb ed                	jmp    f0104578 <syscall+0x52>
	return curenv->env_id;
f010458b:	e8 c3 16 00 00       	call   f0105c53 <cpunum>
f0104590:	6b c0 74             	imul   $0x74,%eax,%eax
f0104593:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104599:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f010459c:	eb da                	jmp    f0104578 <syscall+0x52>
	if ((r = envid2env(envid, &e, 1)) < 0)
f010459e:	83 ec 04             	sub    $0x4,%esp
f01045a1:	6a 01                	push   $0x1
f01045a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045a6:	50                   	push   %eax
f01045a7:	ff 75 0c             	pushl  0xc(%ebp)
f01045aa:	e8 5c ea ff ff       	call   f010300b <envid2env>
f01045af:	83 c4 10             	add    $0x10,%esp
f01045b2:	85 c0                	test   %eax,%eax
f01045b4:	78 46                	js     f01045fc <syscall+0xd6>
	if (e == curenv)
f01045b6:	e8 98 16 00 00       	call   f0105c53 <cpunum>
f01045bb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01045be:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c1:	39 90 28 50 23 f0    	cmp    %edx,-0xfdcafd8(%eax)
f01045c7:	74 3d                	je     f0104606 <syscall+0xe0>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01045c9:	8b 5a 48             	mov    0x48(%edx),%ebx
f01045cc:	e8 82 16 00 00       	call   f0105c53 <cpunum>
f01045d1:	83 ec 04             	sub    $0x4,%esp
f01045d4:	53                   	push   %ebx
f01045d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01045d8:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f01045de:	ff 70 48             	pushl  0x48(%eax)
f01045e1:	68 06 7a 10 f0       	push   $0xf0107a06
f01045e6:	e8 f2 f2 ff ff       	call   f01038dd <cprintf>
f01045eb:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01045ee:	83 ec 0c             	sub    $0xc,%esp
f01045f1:	ff 75 e4             	pushl  -0x1c(%ebp)
f01045f4:	e8 e8 ef ff ff       	call   f01035e1 <env_destroy>
f01045f9:	83 c4 10             	add    $0x10,%esp
			ret = 0;
f01045fc:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104601:	e9 72 ff ff ff       	jmp    f0104578 <syscall+0x52>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104606:	e8 48 16 00 00       	call   f0105c53 <cpunum>
f010460b:	83 ec 08             	sub    $0x8,%esp
f010460e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104611:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104617:	ff 70 48             	pushl  0x48(%eax)
f010461a:	68 eb 79 10 f0       	push   $0xf01079eb
f010461f:	e8 b9 f2 ff ff       	call   f01038dd <cprintf>
f0104624:	83 c4 10             	add    $0x10,%esp
f0104627:	eb c5                	jmp    f01045ee <syscall+0xc8>
	sched_yield();
f0104629:	e8 41 fe ff ff       	call   f010446f <sched_yield>
	return curenv->env_id;
f010462e:	e8 20 16 00 00       	call   f0105c53 <cpunum>
        if ((ret = env_alloc(&env, sys_getenvid())) < 0)
f0104633:	83 ec 08             	sub    $0x8,%esp
	return curenv->env_id;
f0104636:	6b c0 74             	imul   $0x74,%eax,%eax
f0104639:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
        if ((ret = env_alloc(&env, sys_getenvid())) < 0)
f010463f:	ff 70 48             	pushl  0x48(%eax)
f0104642:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104645:	50                   	push   %eax
f0104646:	e8 d1 ea ff ff       	call   f010311c <env_alloc>
f010464b:	89 c3                	mov    %eax,%ebx
f010464d:	83 c4 10             	add    $0x10,%esp
f0104650:	85 c0                	test   %eax,%eax
f0104652:	0f 88 20 ff ff ff    	js     f0104578 <syscall+0x52>
        env->env_status = ENV_NOT_RUNNABLE;
f0104658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010465b:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
        env->env_tf = curenv->env_tf;
f0104662:	e8 ec 15 00 00       	call   f0105c53 <cpunum>
f0104667:	6b c0 74             	imul   $0x74,%eax,%eax
f010466a:	8b b0 28 50 23 f0    	mov    -0xfdcafd8(%eax),%esi
f0104670:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104675:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104678:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        env->env_tf.tf_regs.reg_eax = 0;
f010467a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010467d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
        return env->env_id;
f0104684:	8b 58 48             	mov    0x48(%eax),%ebx
        		break;
f0104687:	e9 ec fe ff ff       	jmp    f0104578 <syscall+0x52>
	if(status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE) 
f010468c:	8b 45 10             	mov    0x10(%ebp),%eax
f010468f:	83 e8 02             	sub    $0x2,%eax
f0104692:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104697:	75 2b                	jne    f01046c4 <syscall+0x19e>
	if(envid2env(envid,&e,1)<0) 
f0104699:	83 ec 04             	sub    $0x4,%esp
f010469c:	6a 01                	push   $0x1
f010469e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046a1:	50                   	push   %eax
f01046a2:	ff 75 0c             	pushl  0xc(%ebp)
f01046a5:	e8 61 e9 ff ff       	call   f010300b <envid2env>
f01046aa:	83 c4 10             	add    $0x10,%esp
f01046ad:	85 c0                	test   %eax,%eax
f01046af:	78 1d                	js     f01046ce <syscall+0x1a8>
	e->env_status = status;
f01046b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01046b4:	8b 7d 10             	mov    0x10(%ebp),%edi
f01046b7:	89 78 54             	mov    %edi,0x54(%eax)
	return 0;
f01046ba:	bb 00 00 00 00       	mov    $0x0,%ebx
f01046bf:	e9 b4 fe ff ff       	jmp    f0104578 <syscall+0x52>
		return -E_INVAL;
f01046c4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01046c9:	e9 aa fe ff ff       	jmp    f0104578 <syscall+0x52>
		return -E_BAD_ENV;
f01046ce:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
			break;
f01046d3:	e9 a0 fe ff ff       	jmp    f0104578 <syscall+0x52>
        if (envid2env(envid, &env, 1) < 0)
f01046d8:	83 ec 04             	sub    $0x4,%esp
f01046db:	6a 01                	push   $0x1
f01046dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01046e0:	50                   	push   %eax
f01046e1:	ff 75 0c             	pushl  0xc(%ebp)
f01046e4:	e8 22 e9 ff ff       	call   f010300b <envid2env>
f01046e9:	83 c4 10             	add    $0x10,%esp
f01046ec:	85 c0                	test   %eax,%eax
f01046ee:	78 6e                	js     f010475e <syscall+0x238>
        if ((uintptr_t)va >= UTOP || PGOFF(va))
f01046f0:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01046f7:	77 6f                	ja     f0104768 <syscall+0x242>
f01046f9:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104700:	75 70                	jne    f0104772 <syscall+0x24c>
        if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0)
f0104702:	8b 45 14             	mov    0x14(%ebp),%eax
f0104705:	83 e0 05             	and    $0x5,%eax
f0104708:	83 f8 05             	cmp    $0x5,%eax
f010470b:	75 6f                	jne    f010477c <syscall+0x256>
        if ((perm & ~(PTE_U | PTE_P | PTE_W | PTE_AVAIL)) != 0)
f010470d:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104710:	81 e3 f8 f1 ff ff    	and    $0xfffff1f8,%ebx
f0104716:	75 6e                	jne    f0104786 <syscall+0x260>
        if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f0104718:	83 ec 0c             	sub    $0xc,%esp
f010471b:	6a 01                	push   $0x1
f010471d:	e8 f4 c7 ff ff       	call   f0100f16 <page_alloc>
f0104722:	89 c6                	mov    %eax,%esi
f0104724:	83 c4 10             	add    $0x10,%esp
f0104727:	85 c0                	test   %eax,%eax
f0104729:	74 65                	je     f0104790 <syscall+0x26a>
        if (page_insert(env->env_pgdir, pp, va, perm) < 0) {
f010472b:	ff 75 14             	pushl  0x14(%ebp)
f010472e:	ff 75 10             	pushl  0x10(%ebp)
f0104731:	50                   	push   %eax
f0104732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104735:	ff 70 60             	pushl  0x60(%eax)
f0104738:	e8 aa ca ff ff       	call   f01011e7 <page_insert>
f010473d:	83 c4 10             	add    $0x10,%esp
f0104740:	85 c0                	test   %eax,%eax
f0104742:	0f 89 30 fe ff ff    	jns    f0104578 <syscall+0x52>
                page_free(pp);
f0104748:	83 ec 0c             	sub    $0xc,%esp
f010474b:	56                   	push   %esi
f010474c:	e8 37 c8 ff ff       	call   f0100f88 <page_free>
f0104751:	83 c4 10             	add    $0x10,%esp
                return -E_NO_MEM;
f0104754:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104759:	e9 1a fe ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_BAD_ENV;
f010475e:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104763:	e9 10 fe ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f0104768:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010476d:	e9 06 fe ff ff       	jmp    f0104578 <syscall+0x52>
f0104772:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104777:	e9 fc fd ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f010477c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104781:	e9 f2 fd ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f0104786:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010478b:	e9 e8 fd ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_NO_MEM;
f0104790:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
        		break;
f0104795:	e9 de fd ff ff       	jmp    f0104578 <syscall+0x52>
        if (envid2env(srcenvid, &srcenv, 1) < 0 || envid2env(dstenvid, &dstenv, 1) < 0)
f010479a:	83 ec 04             	sub    $0x4,%esp
f010479d:	6a 01                	push   $0x1
f010479f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01047a2:	50                   	push   %eax
f01047a3:	ff 75 0c             	pushl  0xc(%ebp)
f01047a6:	e8 60 e8 ff ff       	call   f010300b <envid2env>
f01047ab:	83 c4 10             	add    $0x10,%esp
f01047ae:	85 c0                	test   %eax,%eax
f01047b0:	0f 88 a9 00 00 00    	js     f010485f <syscall+0x339>
f01047b6:	83 ec 04             	sub    $0x4,%esp
f01047b9:	6a 01                	push   $0x1
f01047bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01047be:	50                   	push   %eax
f01047bf:	ff 75 14             	pushl  0x14(%ebp)
f01047c2:	e8 44 e8 ff ff       	call   f010300b <envid2env>
f01047c7:	83 c4 10             	add    $0x10,%esp
f01047ca:	85 c0                	test   %eax,%eax
f01047cc:	0f 88 97 00 00 00    	js     f0104869 <syscall+0x343>
        if ((uintptr_t)srcva >= UTOP || PGOFF(srcva) || (uintptr_t)dstva >= UTOP || PGOFF(dstva))
f01047d2:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01047d9:	0f 87 94 00 00 00    	ja     f0104873 <syscall+0x34d>
f01047df:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01047e6:	0f 85 91 00 00 00    	jne    f010487d <syscall+0x357>
f01047ec:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01047f3:	0f 87 84 00 00 00    	ja     f010487d <syscall+0x357>
f01047f9:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104800:	0f 85 81 00 00 00    	jne    f0104887 <syscall+0x361>
        if ((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0)
f0104806:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104809:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010480e:	83 f8 05             	cmp    $0x5,%eax
f0104811:	75 7e                	jne    f0104891 <syscall+0x36b>
        if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f0104813:	83 ec 04             	sub    $0x4,%esp
f0104816:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104819:	50                   	push   %eax
f010481a:	ff 75 10             	pushl  0x10(%ebp)
f010481d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104820:	ff 70 60             	pushl  0x60(%eax)
f0104823:	e8 dc c8 ff ff       	call   f0101104 <page_lookup>
f0104828:	83 c4 10             	add    $0x10,%esp
f010482b:	85 c0                	test   %eax,%eax
f010482d:	74 6c                	je     f010489b <syscall+0x375>
        if ((perm & PTE_W) && (*pte & PTE_W) == 0)
f010482f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104833:	74 08                	je     f010483d <syscall+0x317>
f0104835:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104838:	f6 02 02             	testb  $0x2,(%edx)
f010483b:	74 68                	je     f01048a5 <syscall+0x37f>
        if (page_insert(dstenv->env_pgdir, pp, dstva, perm) < 0)
f010483d:	ff 75 1c             	pushl  0x1c(%ebp)
f0104840:	ff 75 18             	pushl  0x18(%ebp)
f0104843:	50                   	push   %eax
f0104844:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104847:	ff 70 60             	pushl  0x60(%eax)
f010484a:	e8 98 c9 ff ff       	call   f01011e7 <page_insert>
f010484f:	83 c4 10             	add    $0x10,%esp
        return 0;
f0104852:	c1 f8 1f             	sar    $0x1f,%eax
f0104855:	89 c3                	mov    %eax,%ebx
f0104857:	83 e3 fc             	and    $0xfffffffc,%ebx
f010485a:	e9 19 fd ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_BAD_ENV;
f010485f:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104864:	e9 0f fd ff ff       	jmp    f0104578 <syscall+0x52>
f0104869:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f010486e:	e9 05 fd ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f0104873:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104878:	e9 fb fc ff ff       	jmp    f0104578 <syscall+0x52>
f010487d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104882:	e9 f1 fc ff ff       	jmp    f0104578 <syscall+0x52>
f0104887:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010488c:	e9 e7 fc ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f0104891:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104896:	e9 dd fc ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f010489b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048a0:	e9 d3 fc ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f01048a5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01048aa:	e9 c9 fc ff ff       	jmp    f0104578 <syscall+0x52>
        if (envid2env(envid, &env, 1) < 0)
f01048af:	83 ec 04             	sub    $0x4,%esp
f01048b2:	6a 01                	push   $0x1
f01048b4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01048b7:	50                   	push   %eax
f01048b8:	ff 75 0c             	pushl  0xc(%ebp)
f01048bb:	e8 4b e7 ff ff       	call   f010300b <envid2env>
f01048c0:	83 c4 10             	add    $0x10,%esp
f01048c3:	85 c0                	test   %eax,%eax
f01048c5:	78 30                	js     f01048f7 <syscall+0x3d1>
        if ((uintptr_t)va >= UTOP || PGOFF(va))
f01048c7:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01048ce:	77 31                	ja     f0104901 <syscall+0x3db>
f01048d0:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01048d7:	75 32                	jne    f010490b <syscall+0x3e5>
        page_remove(env->env_pgdir, va);
f01048d9:	83 ec 08             	sub    $0x8,%esp
f01048dc:	ff 75 10             	pushl  0x10(%ebp)
f01048df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01048e2:	ff 70 60             	pushl  0x60(%eax)
f01048e5:	e8 b5 c8 ff ff       	call   f010119f <page_remove>
f01048ea:	83 c4 10             	add    $0x10,%esp
        return 0;
f01048ed:	bb 00 00 00 00       	mov    $0x0,%ebx
f01048f2:	e9 81 fc ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_BAD_ENV;
f01048f7:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01048fc:	e9 77 fc ff ff       	jmp    f0104578 <syscall+0x52>
                return -E_INVAL;
f0104901:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104906:	e9 6d fc ff ff       	jmp    f0104578 <syscall+0x52>
f010490b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f0104910:	e9 63 fc ff ff       	jmp    f0104578 <syscall+0x52>
	int ret = envid2env(envid, &e, 1);
f0104915:	83 ec 04             	sub    $0x4,%esp
f0104918:	6a 01                	push   $0x1
f010491a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010491d:	50                   	push   %eax
f010491e:	ff 75 0c             	pushl  0xc(%ebp)
f0104921:	e8 e5 e6 ff ff       	call   f010300b <envid2env>
f0104926:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f0104928:	83 c4 10             	add    $0x10,%esp
f010492b:	85 c0                	test   %eax,%eax
f010492d:	0f 85 45 fc ff ff    	jne    f0104578 <syscall+0x52>
	e->env_pgfault_upcall = func;
f0104933:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104936:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104939:	89 48 64             	mov    %ecx,0x64(%eax)
			break;
f010493c:	e9 37 fc ff ff       	jmp    f0104578 <syscall+0x52>
	int ret = envid2env(envid, &e, 0);
f0104941:	83 ec 04             	sub    $0x4,%esp
f0104944:	6a 00                	push   $0x0
f0104946:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104949:	50                   	push   %eax
f010494a:	ff 75 0c             	pushl  0xc(%ebp)
f010494d:	e8 b9 e6 ff ff       	call   f010300b <envid2env>
f0104952:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;//bad env
f0104954:	83 c4 10             	add    $0x10,%esp
f0104957:	85 c0                	test   %eax,%eax
f0104959:	0f 85 19 fc ff ff    	jne    f0104578 <syscall+0x52>
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f010495f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104962:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104966:	0f 84 ee 00 00 00    	je     f0104a5a <syscall+0x534>
	if (srcva < (void*)UTOP) {
f010496c:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104973:	77 74                	ja     f01049e9 <syscall+0x4c3>
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104975:	e8 d9 12 00 00       	call   f0105c53 <cpunum>
f010497a:	83 ec 04             	sub    $0x4,%esp
f010497d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104980:	52                   	push   %edx
f0104981:	ff 75 14             	pushl  0x14(%ebp)
f0104984:	6b c0 74             	imul   $0x74,%eax,%eax
f0104987:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f010498d:	ff 70 60             	pushl  0x60(%eax)
f0104990:	e8 6f c7 ff ff       	call   f0101104 <page_lookup>
		if (!pg) return -E_INVAL;
f0104995:	83 c4 10             	add    $0x10,%esp
f0104998:	85 c0                	test   %eax,%eax
f010499a:	0f 84 9f 00 00 00    	je     f0104a3f <syscall+0x519>
		if ((*pte & perm) != perm) return -E_INVAL;
f01049a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01049a3:	8b 12                	mov    (%edx),%edx
f01049a5:	89 d1                	mov    %edx,%ecx
f01049a7:	23 4d 18             	and    0x18(%ebp),%ecx
f01049aa:	39 4d 18             	cmp    %ecx,0x18(%ebp)
f01049ad:	74 0a                	je     f01049b9 <syscall+0x493>
f01049af:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049b4:	e9 bf fb ff ff       	jmp    f0104578 <syscall+0x52>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f01049b9:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01049bd:	74 09                	je     f01049c8 <syscall+0x4a2>
f01049bf:	f6 c2 02             	test   $0x2,%dl
f01049c2:	0f 84 81 00 00 00    	je     f0104a49 <syscall+0x523>
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;
f01049c8:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01049cf:	74 0a                	je     f01049db <syscall+0x4b5>
f01049d1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01049d6:	e9 9d fb ff ff       	jmp    f0104578 <syscall+0x52>
		if (e->env_ipc_dstva < (void*)UTOP) {
f01049db:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01049de:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01049e1:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01049e7:	76 37                	jbe    f0104a20 <syscall+0x4fa>
	e->env_ipc_recving = 0;
f01049e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049ec:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	e->env_ipc_from = curenv->env_id;
f01049f0:	e8 5e 12 00 00       	call   f0105c53 <cpunum>
f01049f5:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01049f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01049fb:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104a01:	8b 40 48             	mov    0x48(%eax),%eax
f0104a04:	89 42 74             	mov    %eax,0x74(%edx)
	e->env_ipc_value = value; 
f0104a07:	8b 45 10             	mov    0x10(%ebp),%eax
f0104a0a:	89 42 70             	mov    %eax,0x70(%edx)
	e->env_status = ENV_RUNNABLE;
f0104a0d:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	e->env_tf.tf_regs.reg_eax = 0;
f0104a14:	c7 42 1c 00 00 00 00 	movl   $0x0,0x1c(%edx)
f0104a1b:	e9 58 fb ff ff       	jmp    f0104578 <syscall+0x52>
			ret = page_insert(e->env_pgdir, pg, e->env_ipc_dstva, perm);
f0104a20:	ff 75 18             	pushl  0x18(%ebp)
f0104a23:	51                   	push   %ecx
f0104a24:	50                   	push   %eax
f0104a25:	ff 72 60             	pushl  0x60(%edx)
f0104a28:	e8 ba c7 ff ff       	call   f01011e7 <page_insert>
			if (ret) return ret;
f0104a2d:	83 c4 10             	add    $0x10,%esp
f0104a30:	85 c0                	test   %eax,%eax
f0104a32:	75 1f                	jne    f0104a53 <syscall+0x52d>
			e->env_ipc_perm = perm;
f0104a34:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a37:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104a3a:	89 78 78             	mov    %edi,0x78(%eax)
f0104a3d:	eb aa                	jmp    f01049e9 <syscall+0x4c3>
		if (!pg) return -E_INVAL;
f0104a3f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a44:	e9 2f fb ff ff       	jmp    f0104578 <syscall+0x52>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;
f0104a49:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104a4e:	e9 25 fb ff ff       	jmp    f0104578 <syscall+0x52>
			if (ret) return ret;
f0104a53:	89 c3                	mov    %eax,%ebx
f0104a55:	e9 1e fb ff ff       	jmp    f0104578 <syscall+0x52>
	if (!e->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104a5a:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
        		break;
f0104a5f:	e9 14 fb ff ff       	jmp    f0104578 <syscall+0x52>
	if (dstva < (void*)UTOP) 
f0104a64:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104a6b:	77 13                	ja     f0104a80 <syscall+0x55a>
		if (dstva != ROUNDDOWN(dstva, PGSIZE)) 
f0104a6d:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104a74:	74 0a                	je     f0104a80 <syscall+0x55a>
        		ret = sys_ipc_recv((void *)a1);
f0104a76:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	return ret;	
f0104a7b:	e9 f8 fa ff ff       	jmp    f0104578 <syscall+0x52>
	curenv->env_ipc_recving = 1;
f0104a80:	e8 ce 11 00 00       	call   f0105c53 <cpunum>
f0104a85:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a88:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104a8e:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104a92:	e8 bc 11 00 00       	call   f0105c53 <cpunum>
f0104a97:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a9a:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104aa0:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104aa7:	e8 a7 11 00 00       	call   f0105c53 <cpunum>
f0104aac:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aaf:	8b 80 28 50 23 f0    	mov    -0xfdcafd8(%eax),%eax
f0104ab5:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104ab8:	89 78 6c             	mov    %edi,0x6c(%eax)
	sched_yield();
f0104abb:	e8 af f9 ff ff       	call   f010446f <sched_yield>
			ret = -E_INVAL;
f0104ac0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104ac5:	e9 ae fa ff ff       	jmp    f0104578 <syscall+0x52>

f0104aca <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104aca:	55                   	push   %ebp
f0104acb:	89 e5                	mov    %esp,%ebp
f0104acd:	57                   	push   %edi
f0104ace:	56                   	push   %esi
f0104acf:	53                   	push   %ebx
f0104ad0:	83 ec 14             	sub    $0x14,%esp
f0104ad3:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ad6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104ad9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104adc:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104adf:	8b 32                	mov    (%edx),%esi
f0104ae1:	8b 01                	mov    (%ecx),%eax
f0104ae3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104ae6:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104aed:	eb 2f                	jmp    f0104b1e <stab_binsearch+0x54>
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
f0104aef:	83 e8 01             	sub    $0x1,%eax
		while (m >= l && stabs[m].n_type != type)
f0104af2:	39 c6                	cmp    %eax,%esi
f0104af4:	7f 49                	jg     f0104b3f <stab_binsearch+0x75>
f0104af6:	0f b6 0a             	movzbl (%edx),%ecx
f0104af9:	83 ea 0c             	sub    $0xc,%edx
f0104afc:	39 f9                	cmp    %edi,%ecx
f0104afe:	75 ef                	jne    f0104aef <stab_binsearch+0x25>
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104b00:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b03:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b06:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104b0a:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104b0d:	73 35                	jae    f0104b44 <stab_binsearch+0x7a>
			*region_left = m;
f0104b0f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b12:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
f0104b14:	8d 73 01             	lea    0x1(%ebx),%esi
		any_matches = 1;
f0104b17:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f0104b1e:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0104b21:	7f 4e                	jg     f0104b71 <stab_binsearch+0xa7>
		int true_m = (l + r) / 2, m = true_m;
f0104b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104b26:	01 f0                	add    %esi,%eax
f0104b28:	89 c3                	mov    %eax,%ebx
f0104b2a:	c1 eb 1f             	shr    $0x1f,%ebx
f0104b2d:	01 c3                	add    %eax,%ebx
f0104b2f:	d1 fb                	sar    %ebx
f0104b31:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104b34:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104b37:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f0104b3b:	89 d8                	mov    %ebx,%eax
		while (m >= l && stabs[m].n_type != type)
f0104b3d:	eb b3                	jmp    f0104af2 <stab_binsearch+0x28>
			l = true_m + 1;
f0104b3f:	8d 73 01             	lea    0x1(%ebx),%esi
			continue;
f0104b42:	eb da                	jmp    f0104b1e <stab_binsearch+0x54>
		} else if (stabs[m].n_value > addr) {
f0104b44:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104b47:	76 14                	jbe    f0104b5d <stab_binsearch+0x93>
			*region_right = m - 1;
f0104b49:	83 e8 01             	sub    $0x1,%eax
f0104b4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104b4f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104b52:	89 03                	mov    %eax,(%ebx)
		any_matches = 1;
f0104b54:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b5b:	eb c1                	jmp    f0104b1e <stab_binsearch+0x54>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104b5d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b60:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104b62:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b66:	89 c6                	mov    %eax,%esi
		any_matches = 1;
f0104b68:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104b6f:	eb ad                	jmp    f0104b1e <stab_binsearch+0x54>
		}
	}

	if (!any_matches)
f0104b71:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104b75:	74 16                	je     f0104b8d <stab_binsearch+0xc3>
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b77:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b7a:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b7c:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104b7f:	8b 0e                	mov    (%esi),%ecx
f0104b81:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b84:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104b87:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
		for (l = *region_right;
f0104b8b:	eb 12                	jmp    f0104b9f <stab_binsearch+0xd5>
		*region_right = *region_left - 1;
f0104b8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104b90:	8b 00                	mov    (%eax),%eax
f0104b92:	83 e8 01             	sub    $0x1,%eax
f0104b95:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0104b98:	89 07                	mov    %eax,(%edi)
f0104b9a:	eb 16                	jmp    f0104bb2 <stab_binsearch+0xe8>
		     l--)
f0104b9c:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f0104b9f:	39 c1                	cmp    %eax,%ecx
f0104ba1:	7d 0a                	jge    f0104bad <stab_binsearch+0xe3>
		     l > *region_left && stabs[l].n_type != type;
f0104ba3:	0f b6 1a             	movzbl (%edx),%ebx
f0104ba6:	83 ea 0c             	sub    $0xc,%edx
f0104ba9:	39 fb                	cmp    %edi,%ebx
f0104bab:	75 ef                	jne    f0104b9c <stab_binsearch+0xd2>
			/* do nothing */;
		*region_left = l;
f0104bad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bb0:	89 07                	mov    %eax,(%edi)
	}
}
f0104bb2:	83 c4 14             	add    $0x14,%esp
f0104bb5:	5b                   	pop    %ebx
f0104bb6:	5e                   	pop    %esi
f0104bb7:	5f                   	pop    %edi
f0104bb8:	5d                   	pop    %ebp
f0104bb9:	c3                   	ret    

f0104bba <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104bba:	55                   	push   %ebp
f0104bbb:	89 e5                	mov    %esp,%ebp
f0104bbd:	57                   	push   %edi
f0104bbe:	56                   	push   %esi
f0104bbf:	53                   	push   %ebx
f0104bc0:	83 ec 4c             	sub    $0x4c,%esp
f0104bc3:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104bc9:	c7 03 54 7a 10 f0    	movl   $0xf0107a54,(%ebx)
	info->eip_line = 0;
f0104bcf:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104bd6:	c7 43 08 54 7a 10 f0 	movl   $0xf0107a54,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104bdd:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104be4:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104be7:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104bee:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104bf4:	77 21                	ja     f0104c17 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104bf6:	a1 00 00 20 00       	mov    0x200000,%eax
f0104bfb:	89 45 b8             	mov    %eax,-0x48(%ebp)
		stab_end = usd->stab_end;
f0104bfe:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0104c03:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104c09:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104c0c:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0104c12:	89 7d bc             	mov    %edi,-0x44(%ebp)
f0104c15:	eb 1a                	jmp    f0104c31 <debuginfo_eip+0x77>
		stabstr_end = __STABSTR_END__;
f0104c17:	c7 45 bc bd 6b 11 f0 	movl   $0xf0116bbd,-0x44(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0104c1e:	c7 45 b4 49 34 11 f0 	movl   $0xf0113449,-0x4c(%ebp)
		stab_end = __STAB_END__;
f0104c25:	b8 48 34 11 f0       	mov    $0xf0113448,%eax
		stabs = __STAB_BEGIN__;
f0104c2a:	c7 45 b8 34 7f 10 f0 	movl   $0xf0107f34,-0x48(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104c31:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104c34:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0104c37:	0f 83 a3 01 00 00    	jae    f0104de0 <debuginfo_eip+0x226>
f0104c3d:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104c41:	0f 85 a0 01 00 00    	jne    f0104de7 <debuginfo_eip+0x22d>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104c47:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104c4e:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104c51:	29 f8                	sub    %edi,%eax
f0104c53:	c1 f8 02             	sar    $0x2,%eax
f0104c56:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104c5c:	83 e8 01             	sub    $0x1,%eax
f0104c5f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104c62:	56                   	push   %esi
f0104c63:	6a 64                	push   $0x64
f0104c65:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104c68:	89 c1                	mov    %eax,%ecx
f0104c6a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104c6d:	89 f8                	mov    %edi,%eax
f0104c6f:	e8 56 fe ff ff       	call   f0104aca <stab_binsearch>
	if (lfile == 0)
f0104c74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c77:	83 c4 08             	add    $0x8,%esp
f0104c7a:	85 c0                	test   %eax,%eax
f0104c7c:	0f 84 6c 01 00 00    	je     f0104dee <debuginfo_eip+0x234>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104c82:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104c85:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104c88:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104c8b:	56                   	push   %esi
f0104c8c:	6a 24                	push   $0x24
f0104c8e:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104c91:	89 c1                	mov    %eax,%ecx
f0104c93:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104c96:	89 f8                	mov    %edi,%eax
f0104c98:	e8 2d fe ff ff       	call   f0104aca <stab_binsearch>

	if (lfun <= rfun) {
f0104c9d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ca0:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104ca3:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0104ca6:	83 c4 08             	add    $0x8,%esp
f0104ca9:	39 c8                	cmp    %ecx,%eax
f0104cab:	7f 7b                	jg     f0104d28 <debuginfo_eip+0x16e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104cad:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104cb0:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f0104cb3:	8b 11                	mov    (%ecx),%edx
f0104cb5:	8b 7d bc             	mov    -0x44(%ebp),%edi
f0104cb8:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f0104cbb:	39 fa                	cmp    %edi,%edx
f0104cbd:	73 06                	jae    f0104cc5 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104cbf:	03 55 b4             	add    -0x4c(%ebp),%edx
f0104cc2:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104cc5:	8b 51 08             	mov    0x8(%ecx),%edx
f0104cc8:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104ccb:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104ccd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104cd0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0104cd3:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104cd6:	83 ec 08             	sub    $0x8,%esp
f0104cd9:	6a 3a                	push   $0x3a
f0104cdb:	ff 73 08             	pushl  0x8(%ebx)
f0104cde:	e8 31 09 00 00       	call   f0105614 <strfind>
f0104ce3:	2b 43 08             	sub    0x8(%ebx),%eax
f0104ce6:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104ce9:	83 c4 08             	add    $0x8,%esp
f0104cec:	56                   	push   %esi
f0104ced:	6a 44                	push   $0x44
f0104cef:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104cf2:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104cf5:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104cf8:	89 f0                	mov    %esi,%eax
f0104cfa:	e8 cb fd ff ff       	call   f0104aca <stab_binsearch>
	info->eip_line = stabs[lline].n_desc;
f0104cff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104d02:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104d05:	c1 e2 02             	shl    $0x2,%edx
f0104d08:	0f b7 4c 16 06       	movzwl 0x6(%esi,%edx,1),%ecx
f0104d0d:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104d10:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d13:	8d 54 16 04          	lea    0x4(%esi,%edx,1),%edx
f0104d17:	83 c4 10             	add    $0x10,%esp
f0104d1a:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f0104d1e:	be 01 00 00 00       	mov    $0x1,%esi
f0104d23:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104d26:	eb 1c                	jmp    f0104d44 <debuginfo_eip+0x18a>
		info->eip_fn_addr = addr;
f0104d28:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104d2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d2e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d34:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104d37:	eb 9d                	jmp    f0104cd6 <debuginfo_eip+0x11c>
f0104d39:	83 e8 01             	sub    $0x1,%eax
f0104d3c:	83 ea 0c             	sub    $0xc,%edx
f0104d3f:	89 f3                	mov    %esi,%ebx
f0104d41:	88 5d c4             	mov    %bl,-0x3c(%ebp)
f0104d44:	89 45 c0             	mov    %eax,-0x40(%ebp)
	while (lline >= lfile
f0104d47:	39 c7                	cmp    %eax,%edi
f0104d49:	7f 24                	jg     f0104d6f <debuginfo_eip+0x1b5>
	       && stabs[lline].n_type != N_SOL
f0104d4b:	0f b6 0a             	movzbl (%edx),%ecx
f0104d4e:	80 f9 84             	cmp    $0x84,%cl
f0104d51:	74 42                	je     f0104d95 <debuginfo_eip+0x1db>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104d53:	80 f9 64             	cmp    $0x64,%cl
f0104d56:	75 e1                	jne    f0104d39 <debuginfo_eip+0x17f>
f0104d58:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0104d5c:	74 db                	je     f0104d39 <debuginfo_eip+0x17f>
f0104d5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d61:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d65:	74 37                	je     f0104d9e <debuginfo_eip+0x1e4>
f0104d67:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104d6a:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104d6d:	eb 2f                	jmp    f0104d9e <debuginfo_eip+0x1e4>
f0104d6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104d72:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d75:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104d78:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lfun < rfun)
f0104d7d:	39 f2                	cmp    %esi,%edx
f0104d7f:	7d 79                	jge    f0104dfa <debuginfo_eip+0x240>
		for (lline = lfun + 1;
f0104d81:	83 c2 01             	add    $0x1,%edx
f0104d84:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104d87:	89 d0                	mov    %edx,%eax
f0104d89:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104d8c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f0104d8f:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f0104d93:	eb 32                	jmp    f0104dc7 <debuginfo_eip+0x20d>
f0104d95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d98:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0104d9c:	75 1d                	jne    f0104dbb <debuginfo_eip+0x201>
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104d9e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104da1:	8b 75 b8             	mov    -0x48(%ebp),%esi
f0104da4:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0104da7:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104daa:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f0104dad:	29 f8                	sub    %edi,%eax
f0104daf:	39 c2                	cmp    %eax,%edx
f0104db1:	73 bf                	jae    f0104d72 <debuginfo_eip+0x1b8>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104db3:	89 f8                	mov    %edi,%eax
f0104db5:	01 d0                	add    %edx,%eax
f0104db7:	89 03                	mov    %eax,(%ebx)
f0104db9:	eb b7                	jmp    f0104d72 <debuginfo_eip+0x1b8>
f0104dbb:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0104dbe:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0104dc1:	eb db                	jmp    f0104d9e <debuginfo_eip+0x1e4>
			info->eip_fn_narg++;
f0104dc3:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f0104dc7:	39 c6                	cmp    %eax,%esi
f0104dc9:	7e 2a                	jle    f0104df5 <debuginfo_eip+0x23b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104dcb:	0f b6 0a             	movzbl (%edx),%ecx
f0104dce:	83 c0 01             	add    $0x1,%eax
f0104dd1:	83 c2 0c             	add    $0xc,%edx
f0104dd4:	80 f9 a0             	cmp    $0xa0,%cl
f0104dd7:	74 ea                	je     f0104dc3 <debuginfo_eip+0x209>
	return 0;
f0104dd9:	b8 00 00 00 00       	mov    $0x0,%eax
f0104dde:	eb 1a                	jmp    f0104dfa <debuginfo_eip+0x240>
		return -1;
f0104de0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104de5:	eb 13                	jmp    f0104dfa <debuginfo_eip+0x240>
f0104de7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104dec:	eb 0c                	jmp    f0104dfa <debuginfo_eip+0x240>
		return -1;
f0104dee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104df3:	eb 05                	jmp    f0104dfa <debuginfo_eip+0x240>
	return 0;
f0104df5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104dfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104dfd:	5b                   	pop    %ebx
f0104dfe:	5e                   	pop    %esi
f0104dff:	5f                   	pop    %edi
f0104e00:	5d                   	pop    %ebp
f0104e01:	c3                   	ret    

f0104e02 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e02:	55                   	push   %ebp
f0104e03:	89 e5                	mov    %esp,%ebp
f0104e05:	57                   	push   %edi
f0104e06:	56                   	push   %esi
f0104e07:	53                   	push   %ebx
f0104e08:	83 ec 1c             	sub    $0x1c,%esp
f0104e0b:	89 c7                	mov    %eax,%edi
f0104e0d:	89 d6                	mov    %edx,%esi
f0104e0f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e12:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104e15:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104e18:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104e1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104e1e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104e23:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104e26:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104e29:	39 d3                	cmp    %edx,%ebx
f0104e2b:	72 05                	jb     f0104e32 <printnum+0x30>
f0104e2d:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104e30:	77 7a                	ja     f0104eac <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104e32:	83 ec 0c             	sub    $0xc,%esp
f0104e35:	ff 75 18             	pushl  0x18(%ebp)
f0104e38:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e3b:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0104e3e:	53                   	push   %ebx
f0104e3f:	ff 75 10             	pushl  0x10(%ebp)
f0104e42:	83 ec 08             	sub    $0x8,%esp
f0104e45:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e48:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e4b:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e4e:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e51:	e8 fa 11 00 00       	call   f0106050 <__udivdi3>
f0104e56:	83 c4 18             	add    $0x18,%esp
f0104e59:	52                   	push   %edx
f0104e5a:	50                   	push   %eax
f0104e5b:	89 f2                	mov    %esi,%edx
f0104e5d:	89 f8                	mov    %edi,%eax
f0104e5f:	e8 9e ff ff ff       	call   f0104e02 <printnum>
f0104e64:	83 c4 20             	add    $0x20,%esp
f0104e67:	eb 13                	jmp    f0104e7c <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104e69:	83 ec 08             	sub    $0x8,%esp
f0104e6c:	56                   	push   %esi
f0104e6d:	ff 75 18             	pushl  0x18(%ebp)
f0104e70:	ff d7                	call   *%edi
f0104e72:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f0104e75:	83 eb 01             	sub    $0x1,%ebx
f0104e78:	85 db                	test   %ebx,%ebx
f0104e7a:	7f ed                	jg     f0104e69 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104e7c:	83 ec 08             	sub    $0x8,%esp
f0104e7f:	56                   	push   %esi
f0104e80:	83 ec 04             	sub    $0x4,%esp
f0104e83:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104e86:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e89:	ff 75 dc             	pushl  -0x24(%ebp)
f0104e8c:	ff 75 d8             	pushl  -0x28(%ebp)
f0104e8f:	e8 dc 12 00 00       	call   f0106170 <__umoddi3>
f0104e94:	83 c4 14             	add    $0x14,%esp
f0104e97:	0f be 80 5e 7a 10 f0 	movsbl -0xfef85a2(%eax),%eax
f0104e9e:	50                   	push   %eax
f0104e9f:	ff d7                	call   *%edi
}
f0104ea1:	83 c4 10             	add    $0x10,%esp
f0104ea4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104ea7:	5b                   	pop    %ebx
f0104ea8:	5e                   	pop    %esi
f0104ea9:	5f                   	pop    %edi
f0104eaa:	5d                   	pop    %ebp
f0104eab:	c3                   	ret    
f0104eac:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104eaf:	eb c4                	jmp    f0104e75 <printnum+0x73>

f0104eb1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104eb1:	55                   	push   %ebp
f0104eb2:	89 e5                	mov    %esp,%ebp
f0104eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104eb7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104ebb:	8b 10                	mov    (%eax),%edx
f0104ebd:	3b 50 04             	cmp    0x4(%eax),%edx
f0104ec0:	73 0a                	jae    f0104ecc <sprintputch+0x1b>
		*b->buf++ = ch;
f0104ec2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104ec5:	89 08                	mov    %ecx,(%eax)
f0104ec7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104eca:	88 02                	mov    %al,(%edx)
}
f0104ecc:	5d                   	pop    %ebp
f0104ecd:	c3                   	ret    

f0104ece <printfmt>:
{
f0104ece:	55                   	push   %ebp
f0104ecf:	89 e5                	mov    %esp,%ebp
f0104ed1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f0104ed4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104ed7:	50                   	push   %eax
f0104ed8:	ff 75 10             	pushl  0x10(%ebp)
f0104edb:	ff 75 0c             	pushl  0xc(%ebp)
f0104ede:	ff 75 08             	pushl  0x8(%ebp)
f0104ee1:	e8 05 00 00 00       	call   f0104eeb <vprintfmt>
}
f0104ee6:	83 c4 10             	add    $0x10,%esp
f0104ee9:	c9                   	leave  
f0104eea:	c3                   	ret    

f0104eeb <vprintfmt>:
{
f0104eeb:	55                   	push   %ebp
f0104eec:	89 e5                	mov    %esp,%ebp
f0104eee:	57                   	push   %edi
f0104eef:	56                   	push   %esi
f0104ef0:	53                   	push   %ebx
f0104ef1:	83 ec 2c             	sub    $0x2c,%esp
f0104ef4:	8b 75 08             	mov    0x8(%ebp),%esi
f0104ef7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104efa:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104efd:	e9 c1 03 00 00       	jmp    f01052c3 <vprintfmt+0x3d8>
		padc = ' ';
f0104f02:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
f0104f06:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
f0104f0d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
f0104f14:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f0104f1b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104f20:	8d 47 01             	lea    0x1(%edi),%eax
f0104f23:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104f26:	0f b6 17             	movzbl (%edi),%edx
f0104f29:	8d 42 dd             	lea    -0x23(%edx),%eax
f0104f2c:	3c 55                	cmp    $0x55,%al
f0104f2e:	0f 87 12 04 00 00    	ja     f0105346 <vprintfmt+0x45b>
f0104f34:	0f b6 c0             	movzbl %al,%eax
f0104f37:	ff 24 85 20 7b 10 f0 	jmp    *-0xfef84e0(,%eax,4)
f0104f3e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0104f41:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
f0104f45:	eb d9                	jmp    f0104f20 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0104f47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
f0104f4a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104f4e:	eb d0                	jmp    f0104f20 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
f0104f50:	0f b6 d2             	movzbl %dl,%edx
f0104f53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0104f56:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f5b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0104f5e:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104f61:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104f65:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104f68:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104f6b:	83 f9 09             	cmp    $0x9,%ecx
f0104f6e:	77 55                	ja     f0104fc5 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
f0104f70:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0104f73:	eb e9                	jmp    f0104f5e <vprintfmt+0x73>
			precision = va_arg(ap, int);
f0104f75:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f78:	8b 00                	mov    (%eax),%eax
f0104f7a:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104f7d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f80:	8d 40 04             	lea    0x4(%eax),%eax
f0104f83:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104f86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f0104f89:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104f8d:	79 91                	jns    f0104f20 <vprintfmt+0x35>
				width = precision, precision = -1;
f0104f8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104f92:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104f95:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104f9c:	eb 82                	jmp    f0104f20 <vprintfmt+0x35>
f0104f9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104fa1:	85 c0                	test   %eax,%eax
f0104fa3:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fa8:	0f 49 d0             	cmovns %eax,%edx
f0104fab:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0104fae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104fb1:	e9 6a ff ff ff       	jmp    f0104f20 <vprintfmt+0x35>
f0104fb6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f0104fb9:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104fc0:	e9 5b ff ff ff       	jmp    f0104f20 <vprintfmt+0x35>
f0104fc5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104fc8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104fcb:	eb bc                	jmp    f0104f89 <vprintfmt+0x9e>
			lflag++;
f0104fcd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0104fd0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f0104fd3:	e9 48 ff ff ff       	jmp    f0104f20 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
f0104fd8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fdb:	8d 78 04             	lea    0x4(%eax),%edi
f0104fde:	83 ec 08             	sub    $0x8,%esp
f0104fe1:	53                   	push   %ebx
f0104fe2:	ff 30                	pushl  (%eax)
f0104fe4:	ff d6                	call   *%esi
			break;
f0104fe6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f0104fe9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f0104fec:	e9 cf 02 00 00       	jmp    f01052c0 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
f0104ff1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ff4:	8d 78 04             	lea    0x4(%eax),%edi
f0104ff7:	8b 00                	mov    (%eax),%eax
f0104ff9:	99                   	cltd   
f0104ffa:	31 d0                	xor    %edx,%eax
f0104ffc:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104ffe:	83 f8 08             	cmp    $0x8,%eax
f0105001:	7f 23                	jg     f0105026 <vprintfmt+0x13b>
f0105003:	8b 14 85 80 7c 10 f0 	mov    -0xfef8380(,%eax,4),%edx
f010500a:	85 d2                	test   %edx,%edx
f010500c:	74 18                	je     f0105026 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
f010500e:	52                   	push   %edx
f010500f:	68 79 71 10 f0       	push   $0xf0107179
f0105014:	53                   	push   %ebx
f0105015:	56                   	push   %esi
f0105016:	e8 b3 fe ff ff       	call   f0104ece <printfmt>
f010501b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f010501e:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105021:	e9 9a 02 00 00       	jmp    f01052c0 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
f0105026:	50                   	push   %eax
f0105027:	68 76 7a 10 f0       	push   $0xf0107a76
f010502c:	53                   	push   %ebx
f010502d:	56                   	push   %esi
f010502e:	e8 9b fe ff ff       	call   f0104ece <printfmt>
f0105033:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105036:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f0105039:	e9 82 02 00 00       	jmp    f01052c0 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
f010503e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105041:	83 c0 04             	add    $0x4,%eax
f0105044:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0105047:	8b 45 14             	mov    0x14(%ebp),%eax
f010504a:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f010504c:	85 ff                	test   %edi,%edi
f010504e:	b8 6f 7a 10 f0       	mov    $0xf0107a6f,%eax
f0105053:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0105056:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010505a:	0f 8e bd 00 00 00    	jle    f010511d <vprintfmt+0x232>
f0105060:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0105064:	75 0e                	jne    f0105074 <vprintfmt+0x189>
f0105066:	89 75 08             	mov    %esi,0x8(%ebp)
f0105069:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010506c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f010506f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105072:	eb 6d                	jmp    f01050e1 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105074:	83 ec 08             	sub    $0x8,%esp
f0105077:	ff 75 d0             	pushl  -0x30(%ebp)
f010507a:	57                   	push   %edi
f010507b:	e8 50 04 00 00       	call   f01054d0 <strnlen>
f0105080:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105083:	29 c1                	sub    %eax,%ecx
f0105085:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0105088:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f010508b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f010508f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105092:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0105095:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
f0105097:	eb 0f                	jmp    f01050a8 <vprintfmt+0x1bd>
					putch(padc, putdat);
f0105099:	83 ec 08             	sub    $0x8,%esp
f010509c:	53                   	push   %ebx
f010509d:	ff 75 e0             	pushl  -0x20(%ebp)
f01050a0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01050a2:	83 ef 01             	sub    $0x1,%edi
f01050a5:	83 c4 10             	add    $0x10,%esp
f01050a8:	85 ff                	test   %edi,%edi
f01050aa:	7f ed                	jg     f0105099 <vprintfmt+0x1ae>
f01050ac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01050af:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01050b2:	85 c9                	test   %ecx,%ecx
f01050b4:	b8 00 00 00 00       	mov    $0x0,%eax
f01050b9:	0f 49 c1             	cmovns %ecx,%eax
f01050bc:	29 c1                	sub    %eax,%ecx
f01050be:	89 75 08             	mov    %esi,0x8(%ebp)
f01050c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
f01050c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f01050c7:	89 cb                	mov    %ecx,%ebx
f01050c9:	eb 16                	jmp    f01050e1 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
f01050cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01050cf:	75 31                	jne    f0105102 <vprintfmt+0x217>
					putch(ch, putdat);
f01050d1:	83 ec 08             	sub    $0x8,%esp
f01050d4:	ff 75 0c             	pushl  0xc(%ebp)
f01050d7:	50                   	push   %eax
f01050d8:	ff 55 08             	call   *0x8(%ebp)
f01050db:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01050de:	83 eb 01             	sub    $0x1,%ebx
f01050e1:	83 c7 01             	add    $0x1,%edi
f01050e4:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
f01050e8:	0f be c2             	movsbl %dl,%eax
f01050eb:	85 c0                	test   %eax,%eax
f01050ed:	74 59                	je     f0105148 <vprintfmt+0x25d>
f01050ef:	85 f6                	test   %esi,%esi
f01050f1:	78 d8                	js     f01050cb <vprintfmt+0x1e0>
f01050f3:	83 ee 01             	sub    $0x1,%esi
f01050f6:	79 d3                	jns    f01050cb <vprintfmt+0x1e0>
f01050f8:	89 df                	mov    %ebx,%edi
f01050fa:	8b 75 08             	mov    0x8(%ebp),%esi
f01050fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105100:	eb 37                	jmp    f0105139 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
f0105102:	0f be d2             	movsbl %dl,%edx
f0105105:	83 ea 20             	sub    $0x20,%edx
f0105108:	83 fa 5e             	cmp    $0x5e,%edx
f010510b:	76 c4                	jbe    f01050d1 <vprintfmt+0x1e6>
					putch('?', putdat);
f010510d:	83 ec 08             	sub    $0x8,%esp
f0105110:	ff 75 0c             	pushl  0xc(%ebp)
f0105113:	6a 3f                	push   $0x3f
f0105115:	ff 55 08             	call   *0x8(%ebp)
f0105118:	83 c4 10             	add    $0x10,%esp
f010511b:	eb c1                	jmp    f01050de <vprintfmt+0x1f3>
f010511d:	89 75 08             	mov    %esi,0x8(%ebp)
f0105120:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105123:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0105126:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0105129:	eb b6                	jmp    f01050e1 <vprintfmt+0x1f6>
				putch(' ', putdat);
f010512b:	83 ec 08             	sub    $0x8,%esp
f010512e:	53                   	push   %ebx
f010512f:	6a 20                	push   $0x20
f0105131:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105133:	83 ef 01             	sub    $0x1,%edi
f0105136:	83 c4 10             	add    $0x10,%esp
f0105139:	85 ff                	test   %edi,%edi
f010513b:	7f ee                	jg     f010512b <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
f010513d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0105140:	89 45 14             	mov    %eax,0x14(%ebp)
f0105143:	e9 78 01 00 00       	jmp    f01052c0 <vprintfmt+0x3d5>
f0105148:	89 df                	mov    %ebx,%edi
f010514a:	8b 75 08             	mov    0x8(%ebp),%esi
f010514d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105150:	eb e7                	jmp    f0105139 <vprintfmt+0x24e>
	if (lflag >= 2)
f0105152:	83 f9 01             	cmp    $0x1,%ecx
f0105155:	7e 3f                	jle    f0105196 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
f0105157:	8b 45 14             	mov    0x14(%ebp),%eax
f010515a:	8b 50 04             	mov    0x4(%eax),%edx
f010515d:	8b 00                	mov    (%eax),%eax
f010515f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105162:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105165:	8b 45 14             	mov    0x14(%ebp),%eax
f0105168:	8d 40 08             	lea    0x8(%eax),%eax
f010516b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f010516e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105172:	79 5c                	jns    f01051d0 <vprintfmt+0x2e5>
				putch('-', putdat);
f0105174:	83 ec 08             	sub    $0x8,%esp
f0105177:	53                   	push   %ebx
f0105178:	6a 2d                	push   $0x2d
f010517a:	ff d6                	call   *%esi
				num = -(long long) num;
f010517c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010517f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105182:	f7 da                	neg    %edx
f0105184:	83 d1 00             	adc    $0x0,%ecx
f0105187:	f7 d9                	neg    %ecx
f0105189:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010518c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105191:	e9 10 01 00 00       	jmp    f01052a6 <vprintfmt+0x3bb>
	else if (lflag)
f0105196:	85 c9                	test   %ecx,%ecx
f0105198:	75 1b                	jne    f01051b5 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
f010519a:	8b 45 14             	mov    0x14(%ebp),%eax
f010519d:	8b 00                	mov    (%eax),%eax
f010519f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051a2:	89 c1                	mov    %eax,%ecx
f01051a4:	c1 f9 1f             	sar    $0x1f,%ecx
f01051a7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051aa:	8b 45 14             	mov    0x14(%ebp),%eax
f01051ad:	8d 40 04             	lea    0x4(%eax),%eax
f01051b0:	89 45 14             	mov    %eax,0x14(%ebp)
f01051b3:	eb b9                	jmp    f010516e <vprintfmt+0x283>
		return va_arg(*ap, long);
f01051b5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051b8:	8b 00                	mov    (%eax),%eax
f01051ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01051bd:	89 c1                	mov    %eax,%ecx
f01051bf:	c1 f9 1f             	sar    $0x1f,%ecx
f01051c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051c5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051c8:	8d 40 04             	lea    0x4(%eax),%eax
f01051cb:	89 45 14             	mov    %eax,0x14(%ebp)
f01051ce:	eb 9e                	jmp    f010516e <vprintfmt+0x283>
			num = getint(&ap, lflag);
f01051d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01051d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f01051d6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051db:	e9 c6 00 00 00       	jmp    f01052a6 <vprintfmt+0x3bb>
	if (lflag >= 2)
f01051e0:	83 f9 01             	cmp    $0x1,%ecx
f01051e3:	7e 18                	jle    f01051fd <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
f01051e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01051e8:	8b 10                	mov    (%eax),%edx
f01051ea:	8b 48 04             	mov    0x4(%eax),%ecx
f01051ed:	8d 40 08             	lea    0x8(%eax),%eax
f01051f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01051f3:	b8 0a 00 00 00       	mov    $0xa,%eax
f01051f8:	e9 a9 00 00 00       	jmp    f01052a6 <vprintfmt+0x3bb>
	else if (lflag)
f01051fd:	85 c9                	test   %ecx,%ecx
f01051ff:	75 1a                	jne    f010521b <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
f0105201:	8b 45 14             	mov    0x14(%ebp),%eax
f0105204:	8b 10                	mov    (%eax),%edx
f0105206:	b9 00 00 00 00       	mov    $0x0,%ecx
f010520b:	8d 40 04             	lea    0x4(%eax),%eax
f010520e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105211:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105216:	e9 8b 00 00 00       	jmp    f01052a6 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f010521b:	8b 45 14             	mov    0x14(%ebp),%eax
f010521e:	8b 10                	mov    (%eax),%edx
f0105220:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105225:	8d 40 04             	lea    0x4(%eax),%eax
f0105228:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f010522b:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105230:	eb 74                	jmp    f01052a6 <vprintfmt+0x3bb>
	if (lflag >= 2)
f0105232:	83 f9 01             	cmp    $0x1,%ecx
f0105235:	7e 15                	jle    f010524c <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
f0105237:	8b 45 14             	mov    0x14(%ebp),%eax
f010523a:	8b 10                	mov    (%eax),%edx
f010523c:	8b 48 04             	mov    0x4(%eax),%ecx
f010523f:	8d 40 08             	lea    0x8(%eax),%eax
f0105242:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105245:	b8 08 00 00 00       	mov    $0x8,%eax
f010524a:	eb 5a                	jmp    f01052a6 <vprintfmt+0x3bb>
	else if (lflag)
f010524c:	85 c9                	test   %ecx,%ecx
f010524e:	75 17                	jne    f0105267 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
f0105250:	8b 45 14             	mov    0x14(%ebp),%eax
f0105253:	8b 10                	mov    (%eax),%edx
f0105255:	b9 00 00 00 00       	mov    $0x0,%ecx
f010525a:	8d 40 04             	lea    0x4(%eax),%eax
f010525d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105260:	b8 08 00 00 00       	mov    $0x8,%eax
f0105265:	eb 3f                	jmp    f01052a6 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f0105267:	8b 45 14             	mov    0x14(%ebp),%eax
f010526a:	8b 10                	mov    (%eax),%edx
f010526c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105271:	8d 40 04             	lea    0x4(%eax),%eax
f0105274:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
f0105277:	b8 08 00 00 00       	mov    $0x8,%eax
f010527c:	eb 28                	jmp    f01052a6 <vprintfmt+0x3bb>
			putch('0', putdat);
f010527e:	83 ec 08             	sub    $0x8,%esp
f0105281:	53                   	push   %ebx
f0105282:	6a 30                	push   $0x30
f0105284:	ff d6                	call   *%esi
			putch('x', putdat);
f0105286:	83 c4 08             	add    $0x8,%esp
f0105289:	53                   	push   %ebx
f010528a:	6a 78                	push   $0x78
f010528c:	ff d6                	call   *%esi
			num = (unsigned long long)
f010528e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105291:	8b 10                	mov    (%eax),%edx
f0105293:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105298:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f010529b:	8d 40 04             	lea    0x4(%eax),%eax
f010529e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01052a1:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f01052a6:	83 ec 0c             	sub    $0xc,%esp
f01052a9:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f01052ad:	57                   	push   %edi
f01052ae:	ff 75 e0             	pushl  -0x20(%ebp)
f01052b1:	50                   	push   %eax
f01052b2:	51                   	push   %ecx
f01052b3:	52                   	push   %edx
f01052b4:	89 da                	mov    %ebx,%edx
f01052b6:	89 f0                	mov    %esi,%eax
f01052b8:	e8 45 fb ff ff       	call   f0104e02 <printnum>
			break;
f01052bd:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
f01052c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01052c3:	83 c7 01             	add    $0x1,%edi
f01052c6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01052ca:	83 f8 25             	cmp    $0x25,%eax
f01052cd:	0f 84 2f fc ff ff    	je     f0104f02 <vprintfmt+0x17>
			if (ch == '\0')
f01052d3:	85 c0                	test   %eax,%eax
f01052d5:	0f 84 8b 00 00 00    	je     f0105366 <vprintfmt+0x47b>
			putch(ch, putdat);
f01052db:	83 ec 08             	sub    $0x8,%esp
f01052de:	53                   	push   %ebx
f01052df:	50                   	push   %eax
f01052e0:	ff d6                	call   *%esi
f01052e2:	83 c4 10             	add    $0x10,%esp
f01052e5:	eb dc                	jmp    f01052c3 <vprintfmt+0x3d8>
	if (lflag >= 2)
f01052e7:	83 f9 01             	cmp    $0x1,%ecx
f01052ea:	7e 15                	jle    f0105301 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
f01052ec:	8b 45 14             	mov    0x14(%ebp),%eax
f01052ef:	8b 10                	mov    (%eax),%edx
f01052f1:	8b 48 04             	mov    0x4(%eax),%ecx
f01052f4:	8d 40 08             	lea    0x8(%eax),%eax
f01052f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01052fa:	b8 10 00 00 00       	mov    $0x10,%eax
f01052ff:	eb a5                	jmp    f01052a6 <vprintfmt+0x3bb>
	else if (lflag)
f0105301:	85 c9                	test   %ecx,%ecx
f0105303:	75 17                	jne    f010531c <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
f0105305:	8b 45 14             	mov    0x14(%ebp),%eax
f0105308:	8b 10                	mov    (%eax),%edx
f010530a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010530f:	8d 40 04             	lea    0x4(%eax),%eax
f0105312:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0105315:	b8 10 00 00 00       	mov    $0x10,%eax
f010531a:	eb 8a                	jmp    f01052a6 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
f010531c:	8b 45 14             	mov    0x14(%ebp),%eax
f010531f:	8b 10                	mov    (%eax),%edx
f0105321:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105326:	8d 40 04             	lea    0x4(%eax),%eax
f0105329:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010532c:	b8 10 00 00 00       	mov    $0x10,%eax
f0105331:	e9 70 ff ff ff       	jmp    f01052a6 <vprintfmt+0x3bb>
			putch(ch, putdat);
f0105336:	83 ec 08             	sub    $0x8,%esp
f0105339:	53                   	push   %ebx
f010533a:	6a 25                	push   $0x25
f010533c:	ff d6                	call   *%esi
			break;
f010533e:	83 c4 10             	add    $0x10,%esp
f0105341:	e9 7a ff ff ff       	jmp    f01052c0 <vprintfmt+0x3d5>
			putch('%', putdat);
f0105346:	83 ec 08             	sub    $0x8,%esp
f0105349:	53                   	push   %ebx
f010534a:	6a 25                	push   $0x25
f010534c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010534e:	83 c4 10             	add    $0x10,%esp
f0105351:	89 f8                	mov    %edi,%eax
f0105353:	eb 03                	jmp    f0105358 <vprintfmt+0x46d>
f0105355:	83 e8 01             	sub    $0x1,%eax
f0105358:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f010535c:	75 f7                	jne    f0105355 <vprintfmt+0x46a>
f010535e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105361:	e9 5a ff ff ff       	jmp    f01052c0 <vprintfmt+0x3d5>
}
f0105366:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105369:	5b                   	pop    %ebx
f010536a:	5e                   	pop    %esi
f010536b:	5f                   	pop    %edi
f010536c:	5d                   	pop    %ebp
f010536d:	c3                   	ret    

f010536e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010536e:	55                   	push   %ebp
f010536f:	89 e5                	mov    %esp,%ebp
f0105371:	83 ec 18             	sub    $0x18,%esp
f0105374:	8b 45 08             	mov    0x8(%ebp),%eax
f0105377:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010537a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010537d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105381:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105384:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010538b:	85 c0                	test   %eax,%eax
f010538d:	74 26                	je     f01053b5 <vsnprintf+0x47>
f010538f:	85 d2                	test   %edx,%edx
f0105391:	7e 22                	jle    f01053b5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105393:	ff 75 14             	pushl  0x14(%ebp)
f0105396:	ff 75 10             	pushl  0x10(%ebp)
f0105399:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010539c:	50                   	push   %eax
f010539d:	68 b1 4e 10 f0       	push   $0xf0104eb1
f01053a2:	e8 44 fb ff ff       	call   f0104eeb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01053a7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01053aa:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01053ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01053b0:	83 c4 10             	add    $0x10,%esp
}
f01053b3:	c9                   	leave  
f01053b4:	c3                   	ret    
		return -E_INVAL;
f01053b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01053ba:	eb f7                	jmp    f01053b3 <vsnprintf+0x45>

f01053bc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01053bc:	55                   	push   %ebp
f01053bd:	89 e5                	mov    %esp,%ebp
f01053bf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01053c2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01053c5:	50                   	push   %eax
f01053c6:	ff 75 10             	pushl  0x10(%ebp)
f01053c9:	ff 75 0c             	pushl  0xc(%ebp)
f01053cc:	ff 75 08             	pushl  0x8(%ebp)
f01053cf:	e8 9a ff ff ff       	call   f010536e <vsnprintf>
	va_end(ap);

	return rc;
}
f01053d4:	c9                   	leave  
f01053d5:	c3                   	ret    

f01053d6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01053d6:	55                   	push   %ebp
f01053d7:	89 e5                	mov    %esp,%ebp
f01053d9:	57                   	push   %edi
f01053da:	56                   	push   %esi
f01053db:	53                   	push   %ebx
f01053dc:	83 ec 0c             	sub    $0xc,%esp
f01053df:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01053e2:	85 c0                	test   %eax,%eax
f01053e4:	74 11                	je     f01053f7 <readline+0x21>
		cprintf("%s", prompt);
f01053e6:	83 ec 08             	sub    $0x8,%esp
f01053e9:	50                   	push   %eax
f01053ea:	68 79 71 10 f0       	push   $0xf0107179
f01053ef:	e8 e9 e4 ff ff       	call   f01038dd <cprintf>
f01053f4:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01053f7:	83 ec 0c             	sub    $0xc,%esp
f01053fa:	6a 00                	push   $0x0
f01053fc:	e8 8d b3 ff ff       	call   f010078e <iscons>
f0105401:	89 c7                	mov    %eax,%edi
f0105403:	83 c4 10             	add    $0x10,%esp
	i = 0;
f0105406:	be 00 00 00 00       	mov    $0x0,%esi
f010540b:	eb 3f                	jmp    f010544c <readline+0x76>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f010540d:	83 ec 08             	sub    $0x8,%esp
f0105410:	50                   	push   %eax
f0105411:	68 a4 7c 10 f0       	push   $0xf0107ca4
f0105416:	e8 c2 e4 ff ff       	call   f01038dd <cprintf>
			return NULL;
f010541b:	83 c4 10             	add    $0x10,%esp
f010541e:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105423:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105426:	5b                   	pop    %ebx
f0105427:	5e                   	pop    %esi
f0105428:	5f                   	pop    %edi
f0105429:	5d                   	pop    %ebp
f010542a:	c3                   	ret    
			if (echoing)
f010542b:	85 ff                	test   %edi,%edi
f010542d:	75 05                	jne    f0105434 <readline+0x5e>
			i--;
f010542f:	83 ee 01             	sub    $0x1,%esi
f0105432:	eb 18                	jmp    f010544c <readline+0x76>
				cputchar('\b');
f0105434:	83 ec 0c             	sub    $0xc,%esp
f0105437:	6a 08                	push   $0x8
f0105439:	e8 2f b3 ff ff       	call   f010076d <cputchar>
f010543e:	83 c4 10             	add    $0x10,%esp
f0105441:	eb ec                	jmp    f010542f <readline+0x59>
			buf[i++] = c;
f0105443:	88 9e 80 4a 23 f0    	mov    %bl,-0xfdcb580(%esi)
f0105449:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f010544c:	e8 2c b3 ff ff       	call   f010077d <getchar>
f0105451:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105453:	85 c0                	test   %eax,%eax
f0105455:	78 b6                	js     f010540d <readline+0x37>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105457:	83 f8 08             	cmp    $0x8,%eax
f010545a:	0f 94 c2             	sete   %dl
f010545d:	83 f8 7f             	cmp    $0x7f,%eax
f0105460:	0f 94 c0             	sete   %al
f0105463:	08 c2                	or     %al,%dl
f0105465:	74 04                	je     f010546b <readline+0x95>
f0105467:	85 f6                	test   %esi,%esi
f0105469:	7f c0                	jg     f010542b <readline+0x55>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010546b:	83 fb 1f             	cmp    $0x1f,%ebx
f010546e:	7e 1a                	jle    f010548a <readline+0xb4>
f0105470:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105476:	7f 12                	jg     f010548a <readline+0xb4>
			if (echoing)
f0105478:	85 ff                	test   %edi,%edi
f010547a:	74 c7                	je     f0105443 <readline+0x6d>
				cputchar(c);
f010547c:	83 ec 0c             	sub    $0xc,%esp
f010547f:	53                   	push   %ebx
f0105480:	e8 e8 b2 ff ff       	call   f010076d <cputchar>
f0105485:	83 c4 10             	add    $0x10,%esp
f0105488:	eb b9                	jmp    f0105443 <readline+0x6d>
		} else if (c == '\n' || c == '\r') {
f010548a:	83 fb 0a             	cmp    $0xa,%ebx
f010548d:	74 05                	je     f0105494 <readline+0xbe>
f010548f:	83 fb 0d             	cmp    $0xd,%ebx
f0105492:	75 b8                	jne    f010544c <readline+0x76>
			if (echoing)
f0105494:	85 ff                	test   %edi,%edi
f0105496:	75 11                	jne    f01054a9 <readline+0xd3>
			buf[i] = 0;
f0105498:	c6 86 80 4a 23 f0 00 	movb   $0x0,-0xfdcb580(%esi)
			return buf;
f010549f:	b8 80 4a 23 f0       	mov    $0xf0234a80,%eax
f01054a4:	e9 7a ff ff ff       	jmp    f0105423 <readline+0x4d>
				cputchar('\n');
f01054a9:	83 ec 0c             	sub    $0xc,%esp
f01054ac:	6a 0a                	push   $0xa
f01054ae:	e8 ba b2 ff ff       	call   f010076d <cputchar>
f01054b3:	83 c4 10             	add    $0x10,%esp
f01054b6:	eb e0                	jmp    f0105498 <readline+0xc2>

f01054b8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01054b8:	55                   	push   %ebp
f01054b9:	89 e5                	mov    %esp,%ebp
f01054bb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01054be:	b8 00 00 00 00       	mov    $0x0,%eax
f01054c3:	eb 03                	jmp    f01054c8 <strlen+0x10>
		n++;
f01054c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
f01054c8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01054cc:	75 f7                	jne    f01054c5 <strlen+0xd>
	return n;
}
f01054ce:	5d                   	pop    %ebp
f01054cf:	c3                   	ret    

f01054d0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01054d0:	55                   	push   %ebp
f01054d1:	89 e5                	mov    %esp,%ebp
f01054d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054d6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054d9:	b8 00 00 00 00       	mov    $0x0,%eax
f01054de:	eb 03                	jmp    f01054e3 <strnlen+0x13>
		n++;
f01054e0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01054e3:	39 d0                	cmp    %edx,%eax
f01054e5:	74 06                	je     f01054ed <strnlen+0x1d>
f01054e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01054eb:	75 f3                	jne    f01054e0 <strnlen+0x10>
	return n;
}
f01054ed:	5d                   	pop    %ebp
f01054ee:	c3                   	ret    

f01054ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01054ef:	55                   	push   %ebp
f01054f0:	89 e5                	mov    %esp,%ebp
f01054f2:	53                   	push   %ebx
f01054f3:	8b 45 08             	mov    0x8(%ebp),%eax
f01054f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01054f9:	89 c2                	mov    %eax,%edx
f01054fb:	83 c1 01             	add    $0x1,%ecx
f01054fe:	83 c2 01             	add    $0x1,%edx
f0105501:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105505:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105508:	84 db                	test   %bl,%bl
f010550a:	75 ef                	jne    f01054fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010550c:	5b                   	pop    %ebx
f010550d:	5d                   	pop    %ebp
f010550e:	c3                   	ret    

f010550f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010550f:	55                   	push   %ebp
f0105510:	89 e5                	mov    %esp,%ebp
f0105512:	53                   	push   %ebx
f0105513:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105516:	53                   	push   %ebx
f0105517:	e8 9c ff ff ff       	call   f01054b8 <strlen>
f010551c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010551f:	ff 75 0c             	pushl  0xc(%ebp)
f0105522:	01 d8                	add    %ebx,%eax
f0105524:	50                   	push   %eax
f0105525:	e8 c5 ff ff ff       	call   f01054ef <strcpy>
	return dst;
}
f010552a:	89 d8                	mov    %ebx,%eax
f010552c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010552f:	c9                   	leave  
f0105530:	c3                   	ret    

f0105531 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105531:	55                   	push   %ebp
f0105532:	89 e5                	mov    %esp,%ebp
f0105534:	56                   	push   %esi
f0105535:	53                   	push   %ebx
f0105536:	8b 75 08             	mov    0x8(%ebp),%esi
f0105539:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010553c:	89 f3                	mov    %esi,%ebx
f010553e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105541:	89 f2                	mov    %esi,%edx
f0105543:	eb 0f                	jmp    f0105554 <strncpy+0x23>
		*dst++ = *src;
f0105545:	83 c2 01             	add    $0x1,%edx
f0105548:	0f b6 01             	movzbl (%ecx),%eax
f010554b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010554e:	80 39 01             	cmpb   $0x1,(%ecx)
f0105551:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
f0105554:	39 da                	cmp    %ebx,%edx
f0105556:	75 ed                	jne    f0105545 <strncpy+0x14>
	}
	return ret;
}
f0105558:	89 f0                	mov    %esi,%eax
f010555a:	5b                   	pop    %ebx
f010555b:	5e                   	pop    %esi
f010555c:	5d                   	pop    %ebp
f010555d:	c3                   	ret    

f010555e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010555e:	55                   	push   %ebp
f010555f:	89 e5                	mov    %esp,%ebp
f0105561:	56                   	push   %esi
f0105562:	53                   	push   %ebx
f0105563:	8b 75 08             	mov    0x8(%ebp),%esi
f0105566:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105569:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010556c:	89 f0                	mov    %esi,%eax
f010556e:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105572:	85 c9                	test   %ecx,%ecx
f0105574:	75 0b                	jne    f0105581 <strlcpy+0x23>
f0105576:	eb 17                	jmp    f010558f <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105578:	83 c2 01             	add    $0x1,%edx
f010557b:	83 c0 01             	add    $0x1,%eax
f010557e:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
f0105581:	39 d8                	cmp    %ebx,%eax
f0105583:	74 07                	je     f010558c <strlcpy+0x2e>
f0105585:	0f b6 0a             	movzbl (%edx),%ecx
f0105588:	84 c9                	test   %cl,%cl
f010558a:	75 ec                	jne    f0105578 <strlcpy+0x1a>
		*dst = '\0';
f010558c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010558f:	29 f0                	sub    %esi,%eax
}
f0105591:	5b                   	pop    %ebx
f0105592:	5e                   	pop    %esi
f0105593:	5d                   	pop    %ebp
f0105594:	c3                   	ret    

f0105595 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105595:	55                   	push   %ebp
f0105596:	89 e5                	mov    %esp,%ebp
f0105598:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010559b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010559e:	eb 06                	jmp    f01055a6 <strcmp+0x11>
		p++, q++;
f01055a0:	83 c1 01             	add    $0x1,%ecx
f01055a3:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
f01055a6:	0f b6 01             	movzbl (%ecx),%eax
f01055a9:	84 c0                	test   %al,%al
f01055ab:	74 04                	je     f01055b1 <strcmp+0x1c>
f01055ad:	3a 02                	cmp    (%edx),%al
f01055af:	74 ef                	je     f01055a0 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01055b1:	0f b6 c0             	movzbl %al,%eax
f01055b4:	0f b6 12             	movzbl (%edx),%edx
f01055b7:	29 d0                	sub    %edx,%eax
}
f01055b9:	5d                   	pop    %ebp
f01055ba:	c3                   	ret    

f01055bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01055bb:	55                   	push   %ebp
f01055bc:	89 e5                	mov    %esp,%ebp
f01055be:	53                   	push   %ebx
f01055bf:	8b 45 08             	mov    0x8(%ebp),%eax
f01055c2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01055c5:	89 c3                	mov    %eax,%ebx
f01055c7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01055ca:	eb 06                	jmp    f01055d2 <strncmp+0x17>
		n--, p++, q++;
f01055cc:	83 c0 01             	add    $0x1,%eax
f01055cf:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f01055d2:	39 d8                	cmp    %ebx,%eax
f01055d4:	74 16                	je     f01055ec <strncmp+0x31>
f01055d6:	0f b6 08             	movzbl (%eax),%ecx
f01055d9:	84 c9                	test   %cl,%cl
f01055db:	74 04                	je     f01055e1 <strncmp+0x26>
f01055dd:	3a 0a                	cmp    (%edx),%cl
f01055df:	74 eb                	je     f01055cc <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01055e1:	0f b6 00             	movzbl (%eax),%eax
f01055e4:	0f b6 12             	movzbl (%edx),%edx
f01055e7:	29 d0                	sub    %edx,%eax
}
f01055e9:	5b                   	pop    %ebx
f01055ea:	5d                   	pop    %ebp
f01055eb:	c3                   	ret    
		return 0;
f01055ec:	b8 00 00 00 00       	mov    $0x0,%eax
f01055f1:	eb f6                	jmp    f01055e9 <strncmp+0x2e>

f01055f3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01055f3:	55                   	push   %ebp
f01055f4:	89 e5                	mov    %esp,%ebp
f01055f6:	8b 45 08             	mov    0x8(%ebp),%eax
f01055f9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f01055fd:	0f b6 10             	movzbl (%eax),%edx
f0105600:	84 d2                	test   %dl,%dl
f0105602:	74 09                	je     f010560d <strchr+0x1a>
		if (*s == c)
f0105604:	38 ca                	cmp    %cl,%dl
f0105606:	74 0a                	je     f0105612 <strchr+0x1f>
	for (; *s; s++)
f0105608:	83 c0 01             	add    $0x1,%eax
f010560b:	eb f0                	jmp    f01055fd <strchr+0xa>
			return (char *) s;
	return 0;
f010560d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105612:	5d                   	pop    %ebp
f0105613:	c3                   	ret    

f0105614 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105614:	55                   	push   %ebp
f0105615:	89 e5                	mov    %esp,%ebp
f0105617:	8b 45 08             	mov    0x8(%ebp),%eax
f010561a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010561e:	eb 03                	jmp    f0105623 <strfind+0xf>
f0105620:	83 c0 01             	add    $0x1,%eax
f0105623:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105626:	38 ca                	cmp    %cl,%dl
f0105628:	74 04                	je     f010562e <strfind+0x1a>
f010562a:	84 d2                	test   %dl,%dl
f010562c:	75 f2                	jne    f0105620 <strfind+0xc>
			break;
	return (char *) s;
}
f010562e:	5d                   	pop    %ebp
f010562f:	c3                   	ret    

f0105630 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105630:	55                   	push   %ebp
f0105631:	89 e5                	mov    %esp,%ebp
f0105633:	57                   	push   %edi
f0105634:	56                   	push   %esi
f0105635:	53                   	push   %ebx
f0105636:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105639:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010563c:	85 c9                	test   %ecx,%ecx
f010563e:	74 13                	je     f0105653 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105640:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105646:	75 05                	jne    f010564d <memset+0x1d>
f0105648:	f6 c1 03             	test   $0x3,%cl
f010564b:	74 0d                	je     f010565a <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010564d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105650:	fc                   	cld    
f0105651:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105653:	89 f8                	mov    %edi,%eax
f0105655:	5b                   	pop    %ebx
f0105656:	5e                   	pop    %esi
f0105657:	5f                   	pop    %edi
f0105658:	5d                   	pop    %ebp
f0105659:	c3                   	ret    
		c &= 0xFF;
f010565a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010565e:	89 d3                	mov    %edx,%ebx
f0105660:	c1 e3 08             	shl    $0x8,%ebx
f0105663:	89 d0                	mov    %edx,%eax
f0105665:	c1 e0 18             	shl    $0x18,%eax
f0105668:	89 d6                	mov    %edx,%esi
f010566a:	c1 e6 10             	shl    $0x10,%esi
f010566d:	09 f0                	or     %esi,%eax
f010566f:	09 c2                	or     %eax,%edx
f0105671:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
f0105673:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105676:	89 d0                	mov    %edx,%eax
f0105678:	fc                   	cld    
f0105679:	f3 ab                	rep stos %eax,%es:(%edi)
f010567b:	eb d6                	jmp    f0105653 <memset+0x23>

f010567d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010567d:	55                   	push   %ebp
f010567e:	89 e5                	mov    %esp,%ebp
f0105680:	57                   	push   %edi
f0105681:	56                   	push   %esi
f0105682:	8b 45 08             	mov    0x8(%ebp),%eax
f0105685:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105688:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010568b:	39 c6                	cmp    %eax,%esi
f010568d:	73 35                	jae    f01056c4 <memmove+0x47>
f010568f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105692:	39 c2                	cmp    %eax,%edx
f0105694:	76 2e                	jbe    f01056c4 <memmove+0x47>
		s += n;
		d += n;
f0105696:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105699:	89 d6                	mov    %edx,%esi
f010569b:	09 fe                	or     %edi,%esi
f010569d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01056a3:	74 0c                	je     f01056b1 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01056a5:	83 ef 01             	sub    $0x1,%edi
f01056a8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f01056ab:	fd                   	std    
f01056ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01056ae:	fc                   	cld    
f01056af:	eb 21                	jmp    f01056d2 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01056b1:	f6 c1 03             	test   $0x3,%cl
f01056b4:	75 ef                	jne    f01056a5 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01056b6:	83 ef 04             	sub    $0x4,%edi
f01056b9:	8d 72 fc             	lea    -0x4(%edx),%esi
f01056bc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f01056bf:	fd                   	std    
f01056c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01056c2:	eb ea                	jmp    f01056ae <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01056c4:	89 f2                	mov    %esi,%edx
f01056c6:	09 c2                	or     %eax,%edx
f01056c8:	f6 c2 03             	test   $0x3,%dl
f01056cb:	74 09                	je     f01056d6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01056cd:	89 c7                	mov    %eax,%edi
f01056cf:	fc                   	cld    
f01056d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01056d2:	5e                   	pop    %esi
f01056d3:	5f                   	pop    %edi
f01056d4:	5d                   	pop    %ebp
f01056d5:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01056d6:	f6 c1 03             	test   $0x3,%cl
f01056d9:	75 f2                	jne    f01056cd <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01056db:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f01056de:	89 c7                	mov    %eax,%edi
f01056e0:	fc                   	cld    
f01056e1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01056e3:	eb ed                	jmp    f01056d2 <memmove+0x55>

f01056e5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01056e5:	55                   	push   %ebp
f01056e6:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f01056e8:	ff 75 10             	pushl  0x10(%ebp)
f01056eb:	ff 75 0c             	pushl  0xc(%ebp)
f01056ee:	ff 75 08             	pushl  0x8(%ebp)
f01056f1:	e8 87 ff ff ff       	call   f010567d <memmove>
}
f01056f6:	c9                   	leave  
f01056f7:	c3                   	ret    

f01056f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01056f8:	55                   	push   %ebp
f01056f9:	89 e5                	mov    %esp,%ebp
f01056fb:	56                   	push   %esi
f01056fc:	53                   	push   %ebx
f01056fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0105700:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105703:	89 c6                	mov    %eax,%esi
f0105705:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105708:	39 f0                	cmp    %esi,%eax
f010570a:	74 1c                	je     f0105728 <memcmp+0x30>
		if (*s1 != *s2)
f010570c:	0f b6 08             	movzbl (%eax),%ecx
f010570f:	0f b6 1a             	movzbl (%edx),%ebx
f0105712:	38 d9                	cmp    %bl,%cl
f0105714:	75 08                	jne    f010571e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105716:	83 c0 01             	add    $0x1,%eax
f0105719:	83 c2 01             	add    $0x1,%edx
f010571c:	eb ea                	jmp    f0105708 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
f010571e:	0f b6 c1             	movzbl %cl,%eax
f0105721:	0f b6 db             	movzbl %bl,%ebx
f0105724:	29 d8                	sub    %ebx,%eax
f0105726:	eb 05                	jmp    f010572d <memcmp+0x35>
	}

	return 0;
f0105728:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010572d:	5b                   	pop    %ebx
f010572e:	5e                   	pop    %esi
f010572f:	5d                   	pop    %ebp
f0105730:	c3                   	ret    

f0105731 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105731:	55                   	push   %ebp
f0105732:	89 e5                	mov    %esp,%ebp
f0105734:	8b 45 08             	mov    0x8(%ebp),%eax
f0105737:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010573a:	89 c2                	mov    %eax,%edx
f010573c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010573f:	39 d0                	cmp    %edx,%eax
f0105741:	73 09                	jae    f010574c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105743:	38 08                	cmp    %cl,(%eax)
f0105745:	74 05                	je     f010574c <memfind+0x1b>
	for (; s < ends; s++)
f0105747:	83 c0 01             	add    $0x1,%eax
f010574a:	eb f3                	jmp    f010573f <memfind+0xe>
			break;
	return (void *) s;
}
f010574c:	5d                   	pop    %ebp
f010574d:	c3                   	ret    

f010574e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010574e:	55                   	push   %ebp
f010574f:	89 e5                	mov    %esp,%ebp
f0105751:	57                   	push   %edi
f0105752:	56                   	push   %esi
f0105753:	53                   	push   %ebx
f0105754:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105757:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010575a:	eb 03                	jmp    f010575f <strtol+0x11>
		s++;
f010575c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f010575f:	0f b6 01             	movzbl (%ecx),%eax
f0105762:	3c 20                	cmp    $0x20,%al
f0105764:	74 f6                	je     f010575c <strtol+0xe>
f0105766:	3c 09                	cmp    $0x9,%al
f0105768:	74 f2                	je     f010575c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
f010576a:	3c 2b                	cmp    $0x2b,%al
f010576c:	74 2e                	je     f010579c <strtol+0x4e>
	int neg = 0;
f010576e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105773:	3c 2d                	cmp    $0x2d,%al
f0105775:	74 2f                	je     f01057a6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105777:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f010577d:	75 05                	jne    f0105784 <strtol+0x36>
f010577f:	80 39 30             	cmpb   $0x30,(%ecx)
f0105782:	74 2c                	je     f01057b0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105784:	85 db                	test   %ebx,%ebx
f0105786:	75 0a                	jne    f0105792 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105788:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
f010578d:	80 39 30             	cmpb   $0x30,(%ecx)
f0105790:	74 28                	je     f01057ba <strtol+0x6c>
		base = 10;
f0105792:	b8 00 00 00 00       	mov    $0x0,%eax
f0105797:	89 5d 10             	mov    %ebx,0x10(%ebp)
f010579a:	eb 50                	jmp    f01057ec <strtol+0x9e>
		s++;
f010579c:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f010579f:	bf 00 00 00 00       	mov    $0x0,%edi
f01057a4:	eb d1                	jmp    f0105777 <strtol+0x29>
		s++, neg = 1;
f01057a6:	83 c1 01             	add    $0x1,%ecx
f01057a9:	bf 01 00 00 00       	mov    $0x1,%edi
f01057ae:	eb c7                	jmp    f0105777 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01057b0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01057b4:	74 0e                	je     f01057c4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01057b6:	85 db                	test   %ebx,%ebx
f01057b8:	75 d8                	jne    f0105792 <strtol+0x44>
		s++, base = 8;
f01057ba:	83 c1 01             	add    $0x1,%ecx
f01057bd:	bb 08 00 00 00       	mov    $0x8,%ebx
f01057c2:	eb ce                	jmp    f0105792 <strtol+0x44>
		s += 2, base = 16;
f01057c4:	83 c1 02             	add    $0x2,%ecx
f01057c7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01057cc:	eb c4                	jmp    f0105792 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01057ce:	8d 72 9f             	lea    -0x61(%edx),%esi
f01057d1:	89 f3                	mov    %esi,%ebx
f01057d3:	80 fb 19             	cmp    $0x19,%bl
f01057d6:	77 29                	ja     f0105801 <strtol+0xb3>
			dig = *s - 'a' + 10;
f01057d8:	0f be d2             	movsbl %dl,%edx
f01057db:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01057de:	3b 55 10             	cmp    0x10(%ebp),%edx
f01057e1:	7d 30                	jge    f0105813 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f01057e3:	83 c1 01             	add    $0x1,%ecx
f01057e6:	0f af 45 10          	imul   0x10(%ebp),%eax
f01057ea:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f01057ec:	0f b6 11             	movzbl (%ecx),%edx
f01057ef:	8d 72 d0             	lea    -0x30(%edx),%esi
f01057f2:	89 f3                	mov    %esi,%ebx
f01057f4:	80 fb 09             	cmp    $0x9,%bl
f01057f7:	77 d5                	ja     f01057ce <strtol+0x80>
			dig = *s - '0';
f01057f9:	0f be d2             	movsbl %dl,%edx
f01057fc:	83 ea 30             	sub    $0x30,%edx
f01057ff:	eb dd                	jmp    f01057de <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
f0105801:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105804:	89 f3                	mov    %esi,%ebx
f0105806:	80 fb 19             	cmp    $0x19,%bl
f0105809:	77 08                	ja     f0105813 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010580b:	0f be d2             	movsbl %dl,%edx
f010580e:	83 ea 37             	sub    $0x37,%edx
f0105811:	eb cb                	jmp    f01057de <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105813:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105817:	74 05                	je     f010581e <strtol+0xd0>
		*endptr = (char *) s;
f0105819:	8b 75 0c             	mov    0xc(%ebp),%esi
f010581c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f010581e:	89 c2                	mov    %eax,%edx
f0105820:	f7 da                	neg    %edx
f0105822:	85 ff                	test   %edi,%edi
f0105824:	0f 45 c2             	cmovne %edx,%eax
}
f0105827:	5b                   	pop    %ebx
f0105828:	5e                   	pop    %esi
f0105829:	5f                   	pop    %edi
f010582a:	5d                   	pop    %ebp
f010582b:	c3                   	ret    

f010582c <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f010582c:	fa                   	cli    

	xorw    %ax, %ax
f010582d:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010582f:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105831:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105833:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105835:	0f 01 16             	lgdtl  (%esi)
f0105838:	74 70                	je     f01058aa <mpsearch1+0x3>
	movl    %cr0, %eax
f010583a:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f010583d:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105841:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105844:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f010584a:	08 00                	or     %al,(%eax)

f010584c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f010584c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105850:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105852:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105854:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105856:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010585a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f010585c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010585e:	b8 00 f0 11 00       	mov    $0x11f000,%eax
	movl    %eax, %cr3
f0105863:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105866:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105869:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010586e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105871:	8b 25 84 4e 23 f0    	mov    0xf0234e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105877:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f010587c:	b8 a0 01 10 f0       	mov    $0xf01001a0,%eax
	call    *%eax
f0105881:	ff d0                	call   *%eax

f0105883 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105883:	eb fe                	jmp    f0105883 <spin>
f0105885:	8d 76 00             	lea    0x0(%esi),%esi

f0105888 <gdt>:
	...
f0105890:	ff                   	(bad)  
f0105891:	ff 00                	incl   (%eax)
f0105893:	00 00                	add    %al,(%eax)
f0105895:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f010589c:	00                   	.byte 0x0
f010589d:	92                   	xchg   %eax,%edx
f010589e:	cf                   	iret   
	...

f01058a0 <gdtdesc>:
f01058a0:	17                   	pop    %ss
f01058a1:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01058a6 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01058a6:	90                   	nop

f01058a7 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01058a7:	55                   	push   %ebp
f01058a8:	89 e5                	mov    %esp,%ebp
f01058aa:	57                   	push   %edi
f01058ab:	56                   	push   %esi
f01058ac:	53                   	push   %ebx
f01058ad:	83 ec 0c             	sub    $0xc,%esp
	if (PGNUM(pa) >= npages)
f01058b0:	8b 0d 88 4e 23 f0    	mov    0xf0234e88,%ecx
f01058b6:	89 c3                	mov    %eax,%ebx
f01058b8:	c1 eb 0c             	shr    $0xc,%ebx
f01058bb:	39 cb                	cmp    %ecx,%ebx
f01058bd:	73 1a                	jae    f01058d9 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f01058bf:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01058c5:	8d 34 02             	lea    (%edx,%eax,1),%esi
	if (PGNUM(pa) >= npages)
f01058c8:	89 f0                	mov    %esi,%eax
f01058ca:	c1 e8 0c             	shr    $0xc,%eax
f01058cd:	39 c8                	cmp    %ecx,%eax
f01058cf:	73 1a                	jae    f01058eb <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f01058d1:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01058d7:	eb 27                	jmp    f0105900 <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01058d9:	50                   	push   %eax
f01058da:	68 c4 62 10 f0       	push   $0xf01062c4
f01058df:	6a 57                	push   $0x57
f01058e1:	68 41 7e 10 f0       	push   $0xf0107e41
f01058e6:	e8 55 a7 ff ff       	call   f0100040 <_panic>
f01058eb:	56                   	push   %esi
f01058ec:	68 c4 62 10 f0       	push   $0xf01062c4
f01058f1:	6a 57                	push   $0x57
f01058f3:	68 41 7e 10 f0       	push   $0xf0107e41
f01058f8:	e8 43 a7 ff ff       	call   f0100040 <_panic>
f01058fd:	83 c3 10             	add    $0x10,%ebx
f0105900:	39 f3                	cmp    %esi,%ebx
f0105902:	73 2e                	jae    f0105932 <mpsearch1+0x8b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105904:	83 ec 04             	sub    $0x4,%esp
f0105907:	6a 04                	push   $0x4
f0105909:	68 51 7e 10 f0       	push   $0xf0107e51
f010590e:	53                   	push   %ebx
f010590f:	e8 e4 fd ff ff       	call   f01056f8 <memcmp>
f0105914:	83 c4 10             	add    $0x10,%esp
f0105917:	85 c0                	test   %eax,%eax
f0105919:	75 e2                	jne    f01058fd <mpsearch1+0x56>
f010591b:	89 da                	mov    %ebx,%edx
f010591d:	8d 7b 10             	lea    0x10(%ebx),%edi
		sum += ((uint8_t *)addr)[i];
f0105920:	0f b6 0a             	movzbl (%edx),%ecx
f0105923:	01 c8                	add    %ecx,%eax
f0105925:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105928:	39 fa                	cmp    %edi,%edx
f010592a:	75 f4                	jne    f0105920 <mpsearch1+0x79>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010592c:	84 c0                	test   %al,%al
f010592e:	75 cd                	jne    f01058fd <mpsearch1+0x56>
f0105930:	eb 05                	jmp    f0105937 <mpsearch1+0x90>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105932:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105937:	89 d8                	mov    %ebx,%eax
f0105939:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010593c:	5b                   	pop    %ebx
f010593d:	5e                   	pop    %esi
f010593e:	5f                   	pop    %edi
f010593f:	5d                   	pop    %ebp
f0105940:	c3                   	ret    

f0105941 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105941:	55                   	push   %ebp
f0105942:	89 e5                	mov    %esp,%ebp
f0105944:	57                   	push   %edi
f0105945:	56                   	push   %esi
f0105946:	53                   	push   %ebx
f0105947:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f010594a:	c7 05 c0 53 23 f0 20 	movl   $0xf0235020,0xf02353c0
f0105951:	50 23 f0 
	if (PGNUM(pa) >= npages)
f0105954:	83 3d 88 4e 23 f0 00 	cmpl   $0x0,0xf0234e88
f010595b:	0f 84 87 00 00 00    	je     f01059e8 <mp_init+0xa7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105961:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105968:	85 c0                	test   %eax,%eax
f010596a:	0f 84 8e 00 00 00    	je     f01059fe <mp_init+0xbd>
		p <<= 4;	// Translate from segment to PA
f0105970:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105973:	ba 00 04 00 00       	mov    $0x400,%edx
f0105978:	e8 2a ff ff ff       	call   f01058a7 <mpsearch1>
f010597d:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105980:	85 c0                	test   %eax,%eax
f0105982:	0f 84 9a 00 00 00    	je     f0105a22 <mp_init+0xe1>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105988:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010598b:	8b 41 04             	mov    0x4(%ecx),%eax
f010598e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105991:	85 c0                	test   %eax,%eax
f0105993:	0f 84 a8 00 00 00    	je     f0105a41 <mp_init+0x100>
f0105999:	80 79 0b 00          	cmpb   $0x0,0xb(%ecx)
f010599d:	0f 85 9e 00 00 00    	jne    f0105a41 <mp_init+0x100>
f01059a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059a6:	c1 e8 0c             	shr    $0xc,%eax
f01059a9:	3b 05 88 4e 23 f0    	cmp    0xf0234e88,%eax
f01059af:	0f 83 a1 00 00 00    	jae    f0105a56 <mp_init+0x115>
	return (void *)(pa + KERNBASE);
f01059b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01059b8:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01059be:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f01059c0:	83 ec 04             	sub    $0x4,%esp
f01059c3:	6a 04                	push   $0x4
f01059c5:	68 56 7e 10 f0       	push   $0xf0107e56
f01059ca:	53                   	push   %ebx
f01059cb:	e8 28 fd ff ff       	call   f01056f8 <memcmp>
f01059d0:	83 c4 10             	add    $0x10,%esp
f01059d3:	85 c0                	test   %eax,%eax
f01059d5:	0f 85 92 00 00 00    	jne    f0105a6d <mp_init+0x12c>
f01059db:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f01059df:	01 df                	add    %ebx,%edi
	sum = 0;
f01059e1:	89 c2                	mov    %eax,%edx
f01059e3:	e9 a2 00 00 00       	jmp    f0105a8a <mp_init+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01059e8:	68 00 04 00 00       	push   $0x400
f01059ed:	68 c4 62 10 f0       	push   $0xf01062c4
f01059f2:	6a 6f                	push   $0x6f
f01059f4:	68 41 7e 10 f0       	push   $0xf0107e41
f01059f9:	e8 42 a6 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01059fe:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105a05:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105a08:	2d 00 04 00 00       	sub    $0x400,%eax
f0105a0d:	ba 00 04 00 00       	mov    $0x400,%edx
f0105a12:	e8 90 fe ff ff       	call   f01058a7 <mpsearch1>
f0105a17:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105a1a:	85 c0                	test   %eax,%eax
f0105a1c:	0f 85 66 ff ff ff    	jne    f0105988 <mp_init+0x47>
	return mpsearch1(0xF0000, 0x10000);
f0105a22:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105a27:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105a2c:	e8 76 fe ff ff       	call   f01058a7 <mpsearch1>
f0105a31:	89 45 e0             	mov    %eax,-0x20(%ebp)
	if ((mp = mpsearch()) == 0)
f0105a34:	85 c0                	test   %eax,%eax
f0105a36:	0f 85 4c ff ff ff    	jne    f0105988 <mp_init+0x47>
f0105a3c:	e9 a8 01 00 00       	jmp    f0105be9 <mp_init+0x2a8>
		cprintf("SMP: Default configurations not implemented\n");
f0105a41:	83 ec 0c             	sub    $0xc,%esp
f0105a44:	68 b4 7c 10 f0       	push   $0xf0107cb4
f0105a49:	e8 8f de ff ff       	call   f01038dd <cprintf>
f0105a4e:	83 c4 10             	add    $0x10,%esp
f0105a51:	e9 93 01 00 00       	jmp    f0105be9 <mp_init+0x2a8>
f0105a56:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105a59:	68 c4 62 10 f0       	push   $0xf01062c4
f0105a5e:	68 90 00 00 00       	push   $0x90
f0105a63:	68 41 7e 10 f0       	push   $0xf0107e41
f0105a68:	e8 d3 a5 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105a6d:	83 ec 0c             	sub    $0xc,%esp
f0105a70:	68 e4 7c 10 f0       	push   $0xf0107ce4
f0105a75:	e8 63 de ff ff       	call   f01038dd <cprintf>
f0105a7a:	83 c4 10             	add    $0x10,%esp
f0105a7d:	e9 67 01 00 00       	jmp    f0105be9 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105a82:	0f b6 0b             	movzbl (%ebx),%ecx
f0105a85:	01 ca                	add    %ecx,%edx
f0105a87:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105a8a:	39 fb                	cmp    %edi,%ebx
f0105a8c:	75 f4                	jne    f0105a82 <mp_init+0x141>
	if (sum(conf, conf->length) != 0) {
f0105a8e:	84 d2                	test   %dl,%dl
f0105a90:	75 16                	jne    f0105aa8 <mp_init+0x167>
	if (conf->version != 1 && conf->version != 4) {
f0105a92:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105a96:	80 fa 01             	cmp    $0x1,%dl
f0105a99:	74 05                	je     f0105aa0 <mp_init+0x15f>
f0105a9b:	80 fa 04             	cmp    $0x4,%dl
f0105a9e:	75 1d                	jne    f0105abd <mp_init+0x17c>
f0105aa0:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105aa4:	01 d9                	add    %ebx,%ecx
f0105aa6:	eb 36                	jmp    f0105ade <mp_init+0x19d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105aa8:	83 ec 0c             	sub    $0xc,%esp
f0105aab:	68 18 7d 10 f0       	push   $0xf0107d18
f0105ab0:	e8 28 de ff ff       	call   f01038dd <cprintf>
f0105ab5:	83 c4 10             	add    $0x10,%esp
f0105ab8:	e9 2c 01 00 00       	jmp    f0105be9 <mp_init+0x2a8>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105abd:	83 ec 08             	sub    $0x8,%esp
f0105ac0:	0f b6 d2             	movzbl %dl,%edx
f0105ac3:	52                   	push   %edx
f0105ac4:	68 3c 7d 10 f0       	push   $0xf0107d3c
f0105ac9:	e8 0f de ff ff       	call   f01038dd <cprintf>
f0105ace:	83 c4 10             	add    $0x10,%esp
f0105ad1:	e9 13 01 00 00       	jmp    f0105be9 <mp_init+0x2a8>
		sum += ((uint8_t *)addr)[i];
f0105ad6:	0f b6 13             	movzbl (%ebx),%edx
f0105ad9:	01 d0                	add    %edx,%eax
f0105adb:	83 c3 01             	add    $0x1,%ebx
	for (i = 0; i < len; i++)
f0105ade:	39 d9                	cmp    %ebx,%ecx
f0105ae0:	75 f4                	jne    f0105ad6 <mp_init+0x195>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105ae2:	02 46 2a             	add    0x2a(%esi),%al
f0105ae5:	75 29                	jne    f0105b10 <mp_init+0x1cf>
	if ((conf = mpconfig(&mp)) == 0)
f0105ae7:	81 7d e4 00 00 00 10 	cmpl   $0x10000000,-0x1c(%ebp)
f0105aee:	0f 84 f5 00 00 00    	je     f0105be9 <mp_init+0x2a8>
		return;
	ismp = 1;
f0105af4:	c7 05 00 50 23 f0 01 	movl   $0x1,0xf0235000
f0105afb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105afe:	8b 46 24             	mov    0x24(%esi),%eax
f0105b01:	a3 00 60 27 f0       	mov    %eax,0xf0276000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b06:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0105b09:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105b0e:	eb 4d                	jmp    f0105b5d <mp_init+0x21c>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105b10:	83 ec 0c             	sub    $0xc,%esp
f0105b13:	68 5c 7d 10 f0       	push   $0xf0107d5c
f0105b18:	e8 c0 dd ff ff       	call   f01038dd <cprintf>
f0105b1d:	83 c4 10             	add    $0x10,%esp
f0105b20:	e9 c4 00 00 00       	jmp    f0105be9 <mp_init+0x2a8>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105b25:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105b29:	74 11                	je     f0105b3c <mp_init+0x1fb>
				bootcpu = &cpus[ncpu];
f0105b2b:	6b 05 c4 53 23 f0 74 	imul   $0x74,0xf02353c4,%eax
f0105b32:	05 20 50 23 f0       	add    $0xf0235020,%eax
f0105b37:	a3 c0 53 23 f0       	mov    %eax,0xf02353c0
			if (ncpu < NCPU) {
f0105b3c:	a1 c4 53 23 f0       	mov    0xf02353c4,%eax
f0105b41:	83 f8 07             	cmp    $0x7,%eax
f0105b44:	7f 2f                	jg     f0105b75 <mp_init+0x234>
				cpus[ncpu].cpu_id = ncpu;
f0105b46:	6b d0 74             	imul   $0x74,%eax,%edx
f0105b49:	88 82 20 50 23 f0    	mov    %al,-0xfdcafe0(%edx)
				ncpu++;
f0105b4f:	83 c0 01             	add    $0x1,%eax
f0105b52:	a3 c4 53 23 f0       	mov    %eax,0xf02353c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105b57:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105b5a:	83 c3 01             	add    $0x1,%ebx
f0105b5d:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f0105b61:	39 d8                	cmp    %ebx,%eax
f0105b63:	76 4b                	jbe    f0105bb0 <mp_init+0x26f>
		switch (*p) {
f0105b65:	0f b6 07             	movzbl (%edi),%eax
f0105b68:	84 c0                	test   %al,%al
f0105b6a:	74 b9                	je     f0105b25 <mp_init+0x1e4>
f0105b6c:	3c 04                	cmp    $0x4,%al
f0105b6e:	77 1c                	ja     f0105b8c <mp_init+0x24b>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105b70:	83 c7 08             	add    $0x8,%edi
			continue;
f0105b73:	eb e5                	jmp    f0105b5a <mp_init+0x219>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105b75:	83 ec 08             	sub    $0x8,%esp
f0105b78:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0105b7c:	50                   	push   %eax
f0105b7d:	68 8c 7d 10 f0       	push   $0xf0107d8c
f0105b82:	e8 56 dd ff ff       	call   f01038dd <cprintf>
f0105b87:	83 c4 10             	add    $0x10,%esp
f0105b8a:	eb cb                	jmp    f0105b57 <mp_init+0x216>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b8c:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f0105b8f:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f0105b92:	50                   	push   %eax
f0105b93:	68 b4 7d 10 f0       	push   $0xf0107db4
f0105b98:	e8 40 dd ff ff       	call   f01038dd <cprintf>
			ismp = 0;
f0105b9d:	c7 05 00 50 23 f0 00 	movl   $0x0,0xf0235000
f0105ba4:	00 00 00 
			i = conf->entry;
f0105ba7:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f0105bab:	83 c4 10             	add    $0x10,%esp
f0105bae:	eb aa                	jmp    f0105b5a <mp_init+0x219>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105bb0:	a1 c0 53 23 f0       	mov    0xf02353c0,%eax
f0105bb5:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105bbc:	83 3d 00 50 23 f0 00 	cmpl   $0x0,0xf0235000
f0105bc3:	75 2c                	jne    f0105bf1 <mp_init+0x2b0>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105bc5:	c7 05 c4 53 23 f0 01 	movl   $0x1,0xf02353c4
f0105bcc:	00 00 00 
		lapicaddr = 0;
f0105bcf:	c7 05 00 60 27 f0 00 	movl   $0x0,0xf0276000
f0105bd6:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105bd9:	83 ec 0c             	sub    $0xc,%esp
f0105bdc:	68 d4 7d 10 f0       	push   $0xf0107dd4
f0105be1:	e8 f7 dc ff ff       	call   f01038dd <cprintf>
		return;
f0105be6:	83 c4 10             	add    $0x10,%esp
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105bec:	5b                   	pop    %ebx
f0105bed:	5e                   	pop    %esi
f0105bee:	5f                   	pop    %edi
f0105bef:	5d                   	pop    %ebp
f0105bf0:	c3                   	ret    
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105bf1:	83 ec 04             	sub    $0x4,%esp
f0105bf4:	ff 35 c4 53 23 f0    	pushl  0xf02353c4
f0105bfa:	0f b6 00             	movzbl (%eax),%eax
f0105bfd:	50                   	push   %eax
f0105bfe:	68 5b 7e 10 f0       	push   $0xf0107e5b
f0105c03:	e8 d5 dc ff ff       	call   f01038dd <cprintf>
	if (mp->imcrp) {
f0105c08:	83 c4 10             	add    $0x10,%esp
f0105c0b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105c0e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105c12:	74 d5                	je     f0105be9 <mp_init+0x2a8>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105c14:	83 ec 0c             	sub    $0xc,%esp
f0105c17:	68 00 7e 10 f0       	push   $0xf0107e00
f0105c1c:	e8 bc dc ff ff       	call   f01038dd <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105c21:	b8 70 00 00 00       	mov    $0x70,%eax
f0105c26:	ba 22 00 00 00       	mov    $0x22,%edx
f0105c2b:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105c2c:	ba 23 00 00 00       	mov    $0x23,%edx
f0105c31:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0105c32:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105c35:	ee                   	out    %al,(%dx)
f0105c36:	83 c4 10             	add    $0x10,%esp
f0105c39:	eb ae                	jmp    f0105be9 <mp_init+0x2a8>

f0105c3b <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105c3b:	55                   	push   %ebp
f0105c3c:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105c3e:	8b 0d 04 60 27 f0    	mov    0xf0276004,%ecx
f0105c44:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105c47:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105c49:	a1 04 60 27 f0       	mov    0xf0276004,%eax
f0105c4e:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105c51:	5d                   	pop    %ebp
f0105c52:	c3                   	ret    

f0105c53 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105c53:	55                   	push   %ebp
f0105c54:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105c56:	8b 15 04 60 27 f0    	mov    0xf0276004,%edx
		return lapic[ID] >> 24;
	return 0;
f0105c5c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f0105c61:	85 d2                	test   %edx,%edx
f0105c63:	74 06                	je     f0105c6b <cpunum+0x18>
		return lapic[ID] >> 24;
f0105c65:	8b 42 20             	mov    0x20(%edx),%eax
f0105c68:	c1 e8 18             	shr    $0x18,%eax
}
f0105c6b:	5d                   	pop    %ebp
f0105c6c:	c3                   	ret    

f0105c6d <lapic_init>:
	if (!lapicaddr)
f0105c6d:	a1 00 60 27 f0       	mov    0xf0276000,%eax
f0105c72:	85 c0                	test   %eax,%eax
f0105c74:	75 02                	jne    f0105c78 <lapic_init+0xb>
f0105c76:	f3 c3                	repz ret 
{
f0105c78:	55                   	push   %ebp
f0105c79:	89 e5                	mov    %esp,%ebp
f0105c7b:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f0105c7e:	68 00 10 00 00       	push   $0x1000
f0105c83:	50                   	push   %eax
f0105c84:	e8 d2 b5 ff ff       	call   f010125b <mmio_map_region>
f0105c89:	a3 04 60 27 f0       	mov    %eax,0xf0276004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105c8e:	ba 27 01 00 00       	mov    $0x127,%edx
f0105c93:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105c98:	e8 9e ff ff ff       	call   f0105c3b <lapicw>
	lapicw(TDCR, X1);
f0105c9d:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105ca2:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105ca7:	e8 8f ff ff ff       	call   f0105c3b <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105cac:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105cb1:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105cb6:	e8 80 ff ff ff       	call   f0105c3b <lapicw>
	lapicw(TICR, 10000000); 
f0105cbb:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105cc0:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105cc5:	e8 71 ff ff ff       	call   f0105c3b <lapicw>
	if (thiscpu != bootcpu)
f0105cca:	e8 84 ff ff ff       	call   f0105c53 <cpunum>
f0105ccf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105cd2:	05 20 50 23 f0       	add    $0xf0235020,%eax
f0105cd7:	83 c4 10             	add    $0x10,%esp
f0105cda:	39 05 c0 53 23 f0    	cmp    %eax,0xf02353c0
f0105ce0:	74 0f                	je     f0105cf1 <lapic_init+0x84>
		lapicw(LINT0, MASKED);
f0105ce2:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ce7:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105cec:	e8 4a ff ff ff       	call   f0105c3b <lapicw>
	lapicw(LINT1, MASKED);
f0105cf1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105cf6:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105cfb:	e8 3b ff ff ff       	call   f0105c3b <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105d00:	a1 04 60 27 f0       	mov    0xf0276004,%eax
f0105d05:	8b 40 30             	mov    0x30(%eax),%eax
f0105d08:	c1 e8 10             	shr    $0x10,%eax
f0105d0b:	3c 03                	cmp    $0x3,%al
f0105d0d:	77 7c                	ja     f0105d8b <lapic_init+0x11e>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105d0f:	ba 33 00 00 00       	mov    $0x33,%edx
f0105d14:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0105d19:	e8 1d ff ff ff       	call   f0105c3b <lapicw>
	lapicw(ESR, 0);
f0105d1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d23:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d28:	e8 0e ff ff ff       	call   f0105c3b <lapicw>
	lapicw(ESR, 0);
f0105d2d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d32:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105d37:	e8 ff fe ff ff       	call   f0105c3b <lapicw>
	lapicw(EOI, 0);
f0105d3c:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d41:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105d46:	e8 f0 fe ff ff       	call   f0105c3b <lapicw>
	lapicw(ICRHI, 0);
f0105d4b:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d50:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105d55:	e8 e1 fe ff ff       	call   f0105c3b <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0105d5a:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105d5f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105d64:	e8 d2 fe ff ff       	call   f0105c3b <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0105d69:	8b 15 04 60 27 f0    	mov    0xf0276004,%edx
f0105d6f:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105d75:	f6 c4 10             	test   $0x10,%ah
f0105d78:	75 f5                	jne    f0105d6f <lapic_init+0x102>
	lapicw(TPR, 0);
f0105d7a:	ba 00 00 00 00       	mov    $0x0,%edx
f0105d7f:	b8 20 00 00 00       	mov    $0x20,%eax
f0105d84:	e8 b2 fe ff ff       	call   f0105c3b <lapicw>
}
f0105d89:	c9                   	leave  
f0105d8a:	c3                   	ret    
		lapicw(PCINT, MASKED);
f0105d8b:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105d90:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0105d95:	e8 a1 fe ff ff       	call   f0105c3b <lapicw>
f0105d9a:	e9 70 ff ff ff       	jmp    f0105d0f <lapic_init+0xa2>

f0105d9f <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f0105d9f:	83 3d 04 60 27 f0 00 	cmpl   $0x0,0xf0276004
f0105da6:	74 14                	je     f0105dbc <lapic_eoi+0x1d>
{
f0105da8:	55                   	push   %ebp
f0105da9:	89 e5                	mov    %esp,%ebp
		lapicw(EOI, 0);
f0105dab:	ba 00 00 00 00       	mov    $0x0,%edx
f0105db0:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105db5:	e8 81 fe ff ff       	call   f0105c3b <lapicw>
}
f0105dba:	5d                   	pop    %ebp
f0105dbb:	c3                   	ret    
f0105dbc:	f3 c3                	repz ret 

f0105dbe <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105dbe:	55                   	push   %ebp
f0105dbf:	89 e5                	mov    %esp,%ebp
f0105dc1:	56                   	push   %esi
f0105dc2:	53                   	push   %ebx
f0105dc3:	8b 75 08             	mov    0x8(%ebp),%esi
f0105dc6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105dc9:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105dce:	ba 70 00 00 00       	mov    $0x70,%edx
f0105dd3:	ee                   	out    %al,(%dx)
f0105dd4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105dd9:	ba 71 00 00 00       	mov    $0x71,%edx
f0105dde:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0105ddf:	83 3d 88 4e 23 f0 00 	cmpl   $0x0,0xf0234e88
f0105de6:	74 7e                	je     f0105e66 <lapic_startap+0xa8>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105de8:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105def:	00 00 
	wrv[1] = addr >> 4;
f0105df1:	89 d8                	mov    %ebx,%eax
f0105df3:	c1 e8 04             	shr    $0x4,%eax
f0105df6:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105dfc:	c1 e6 18             	shl    $0x18,%esi
f0105dff:	89 f2                	mov    %esi,%edx
f0105e01:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e06:	e8 30 fe ff ff       	call   f0105c3b <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105e0b:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105e10:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e15:	e8 21 fe ff ff       	call   f0105c3b <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105e1a:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105e1f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e24:	e8 12 fe ff ff       	call   f0105c3b <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e29:	c1 eb 0c             	shr    $0xc,%ebx
f0105e2c:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0105e2f:	89 f2                	mov    %esi,%edx
f0105e31:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e36:	e8 00 fe ff ff       	call   f0105c3b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e3b:	89 da                	mov    %ebx,%edx
f0105e3d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e42:	e8 f4 fd ff ff       	call   f0105c3b <lapicw>
		lapicw(ICRHI, apicid << 24);
f0105e47:	89 f2                	mov    %esi,%edx
f0105e49:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105e4e:	e8 e8 fd ff ff       	call   f0105c3b <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105e53:	89 da                	mov    %ebx,%edx
f0105e55:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e5a:	e8 dc fd ff ff       	call   f0105c3b <lapicw>
		microdelay(200);
	}
}
f0105e5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105e62:	5b                   	pop    %ebx
f0105e63:	5e                   	pop    %esi
f0105e64:	5d                   	pop    %ebp
f0105e65:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e66:	68 67 04 00 00       	push   $0x467
f0105e6b:	68 c4 62 10 f0       	push   $0xf01062c4
f0105e70:	68 98 00 00 00       	push   $0x98
f0105e75:	68 78 7e 10 f0       	push   $0xf0107e78
f0105e7a:	e8 c1 a1 ff ff       	call   f0100040 <_panic>

f0105e7f <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0105e7f:	55                   	push   %ebp
f0105e80:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e82:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e85:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e8b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e90:	e8 a6 fd ff ff       	call   f0105c3b <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e95:	8b 15 04 60 27 f0    	mov    0xf0276004,%edx
f0105e9b:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0105ea1:	f6 c4 10             	test   $0x10,%ah
f0105ea4:	75 f5                	jne    f0105e9b <lapic_ipi+0x1c>
		;
}
f0105ea6:	5d                   	pop    %ebp
f0105ea7:	c3                   	ret    

f0105ea8 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f0105ea8:	55                   	push   %ebp
f0105ea9:	89 e5                	mov    %esp,%ebp
f0105eab:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f0105eae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0105eb4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105eb7:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0105eba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f0105ec1:	5d                   	pop    %ebp
f0105ec2:	c3                   	ret    

f0105ec3 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105ec3:	55                   	push   %ebp
f0105ec4:	89 e5                	mov    %esp,%ebp
f0105ec6:	56                   	push   %esi
f0105ec7:	53                   	push   %ebx
f0105ec8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0105ecb:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105ece:	75 07                	jne    f0105ed7 <spin_lock+0x14>
	asm volatile("lock; xchgl %0, %1"
f0105ed0:	ba 01 00 00 00       	mov    $0x1,%edx
f0105ed5:	eb 34                	jmp    f0105f0b <spin_lock+0x48>
f0105ed7:	8b 73 08             	mov    0x8(%ebx),%esi
f0105eda:	e8 74 fd ff ff       	call   f0105c53 <cpunum>
f0105edf:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ee2:	05 20 50 23 f0       	add    $0xf0235020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105ee7:	39 c6                	cmp    %eax,%esi
f0105ee9:	75 e5                	jne    f0105ed0 <spin_lock+0xd>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105eeb:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105eee:	e8 60 fd ff ff       	call   f0105c53 <cpunum>
f0105ef3:	83 ec 0c             	sub    $0xc,%esp
f0105ef6:	53                   	push   %ebx
f0105ef7:	50                   	push   %eax
f0105ef8:	68 88 7e 10 f0       	push   $0xf0107e88
f0105efd:	6a 41                	push   $0x41
f0105eff:	68 ec 7e 10 f0       	push   $0xf0107eec
f0105f04:	e8 37 a1 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105f09:	f3 90                	pause  
f0105f0b:	89 d0                	mov    %edx,%eax
f0105f0d:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)
f0105f10:	85 c0                	test   %eax,%eax
f0105f12:	75 f5                	jne    f0105f09 <spin_lock+0x46>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105f14:	e8 3a fd ff ff       	call   f0105c53 <cpunum>
f0105f19:	6b c0 74             	imul   $0x74,%eax,%eax
f0105f1c:	05 20 50 23 f0       	add    $0xf0235020,%eax
f0105f21:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105f24:	83 c3 0c             	add    $0xc,%ebx
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105f27:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0105f29:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f2e:	eb 0b                	jmp    f0105f3b <spin_lock+0x78>
		pcs[i] = ebp[1];          // saved %eip
f0105f30:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105f33:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105f36:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0105f38:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105f3b:	83 f8 09             	cmp    $0x9,%eax
f0105f3e:	7f 14                	jg     f0105f54 <spin_lock+0x91>
f0105f40:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105f46:	77 e8                	ja     f0105f30 <spin_lock+0x6d>
f0105f48:	eb 0a                	jmp    f0105f54 <spin_lock+0x91>
		pcs[i] = 0;
f0105f4a:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
	for (; i < 10; i++)
f0105f51:	83 c0 01             	add    $0x1,%eax
f0105f54:	83 f8 09             	cmp    $0x9,%eax
f0105f57:	7e f1                	jle    f0105f4a <spin_lock+0x87>
#endif
}
f0105f59:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105f5c:	5b                   	pop    %ebx
f0105f5d:	5e                   	pop    %esi
f0105f5e:	5d                   	pop    %ebp
f0105f5f:	c3                   	ret    

f0105f60 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105f60:	55                   	push   %ebp
f0105f61:	89 e5                	mov    %esp,%ebp
f0105f63:	57                   	push   %edi
f0105f64:	56                   	push   %esi
f0105f65:	53                   	push   %ebx
f0105f66:	83 ec 4c             	sub    $0x4c,%esp
f0105f69:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f0105f6c:	83 3e 00             	cmpl   $0x0,(%esi)
f0105f6f:	75 35                	jne    f0105fa6 <spin_unlock+0x46>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105f71:	83 ec 04             	sub    $0x4,%esp
f0105f74:	6a 28                	push   $0x28
f0105f76:	8d 46 0c             	lea    0xc(%esi),%eax
f0105f79:	50                   	push   %eax
f0105f7a:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105f7d:	53                   	push   %ebx
f0105f7e:	e8 fa f6 ff ff       	call   f010567d <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105f83:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105f86:	0f b6 38             	movzbl (%eax),%edi
f0105f89:	8b 76 04             	mov    0x4(%esi),%esi
f0105f8c:	e8 c2 fc ff ff       	call   f0105c53 <cpunum>
f0105f91:	57                   	push   %edi
f0105f92:	56                   	push   %esi
f0105f93:	50                   	push   %eax
f0105f94:	68 b4 7e 10 f0       	push   $0xf0107eb4
f0105f99:	e8 3f d9 ff ff       	call   f01038dd <cprintf>
f0105f9e:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105fa1:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105fa4:	eb 61                	jmp    f0106007 <spin_unlock+0xa7>
	return lock->locked && lock->cpu == thiscpu;
f0105fa6:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105fa9:	e8 a5 fc ff ff       	call   f0105c53 <cpunum>
f0105fae:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fb1:	05 20 50 23 f0       	add    $0xf0235020,%eax
	if (!holding(lk)) {
f0105fb6:	39 c3                	cmp    %eax,%ebx
f0105fb8:	75 b7                	jne    f0105f71 <spin_unlock+0x11>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f0105fba:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105fc1:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0105fc8:	b8 00 00 00 00       	mov    $0x0,%eax
f0105fcd:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105fd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105fd3:	5b                   	pop    %ebx
f0105fd4:	5e                   	pop    %esi
f0105fd5:	5f                   	pop    %edi
f0105fd6:	5d                   	pop    %ebp
f0105fd7:	c3                   	ret    
					pcs[i] - info.eip_fn_addr);
f0105fd8:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105fda:	83 ec 04             	sub    $0x4,%esp
f0105fdd:	89 c2                	mov    %eax,%edx
f0105fdf:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105fe2:	52                   	push   %edx
f0105fe3:	ff 75 b0             	pushl  -0x50(%ebp)
f0105fe6:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105fe9:	ff 75 ac             	pushl  -0x54(%ebp)
f0105fec:	ff 75 a8             	pushl  -0x58(%ebp)
f0105fef:	50                   	push   %eax
f0105ff0:	68 fc 7e 10 f0       	push   $0xf0107efc
f0105ff5:	e8 e3 d8 ff ff       	call   f01038dd <cprintf>
f0105ffa:	83 c4 20             	add    $0x20,%esp
f0105ffd:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106000:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106003:	39 c3                	cmp    %eax,%ebx
f0106005:	74 2d                	je     f0106034 <spin_unlock+0xd4>
f0106007:	89 de                	mov    %ebx,%esi
f0106009:	8b 03                	mov    (%ebx),%eax
f010600b:	85 c0                	test   %eax,%eax
f010600d:	74 25                	je     f0106034 <spin_unlock+0xd4>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010600f:	83 ec 08             	sub    $0x8,%esp
f0106012:	57                   	push   %edi
f0106013:	50                   	push   %eax
f0106014:	e8 a1 eb ff ff       	call   f0104bba <debuginfo_eip>
f0106019:	83 c4 10             	add    $0x10,%esp
f010601c:	85 c0                	test   %eax,%eax
f010601e:	79 b8                	jns    f0105fd8 <spin_unlock+0x78>
				cprintf("  %08x\n", pcs[i]);
f0106020:	83 ec 08             	sub    $0x8,%esp
f0106023:	ff 36                	pushl  (%esi)
f0106025:	68 13 7f 10 f0       	push   $0xf0107f13
f010602a:	e8 ae d8 ff ff       	call   f01038dd <cprintf>
f010602f:	83 c4 10             	add    $0x10,%esp
f0106032:	eb c9                	jmp    f0105ffd <spin_unlock+0x9d>
		panic("spin_unlock");
f0106034:	83 ec 04             	sub    $0x4,%esp
f0106037:	68 1b 7f 10 f0       	push   $0xf0107f1b
f010603c:	6a 67                	push   $0x67
f010603e:	68 ec 7e 10 f0       	push   $0xf0107eec
f0106043:	e8 f8 9f ff ff       	call   f0100040 <_panic>
f0106048:	66 90                	xchg   %ax,%ax
f010604a:	66 90                	xchg   %ax,%ax
f010604c:	66 90                	xchg   %ax,%ax
f010604e:	66 90                	xchg   %ax,%ax

f0106050 <__udivdi3>:
f0106050:	55                   	push   %ebp
f0106051:	57                   	push   %edi
f0106052:	56                   	push   %esi
f0106053:	53                   	push   %ebx
f0106054:	83 ec 1c             	sub    $0x1c,%esp
f0106057:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010605b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f010605f:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106063:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0106067:	85 d2                	test   %edx,%edx
f0106069:	75 35                	jne    f01060a0 <__udivdi3+0x50>
f010606b:	39 f3                	cmp    %esi,%ebx
f010606d:	0f 87 bd 00 00 00    	ja     f0106130 <__udivdi3+0xe0>
f0106073:	85 db                	test   %ebx,%ebx
f0106075:	89 d9                	mov    %ebx,%ecx
f0106077:	75 0b                	jne    f0106084 <__udivdi3+0x34>
f0106079:	b8 01 00 00 00       	mov    $0x1,%eax
f010607e:	31 d2                	xor    %edx,%edx
f0106080:	f7 f3                	div    %ebx
f0106082:	89 c1                	mov    %eax,%ecx
f0106084:	31 d2                	xor    %edx,%edx
f0106086:	89 f0                	mov    %esi,%eax
f0106088:	f7 f1                	div    %ecx
f010608a:	89 c6                	mov    %eax,%esi
f010608c:	89 e8                	mov    %ebp,%eax
f010608e:	89 f7                	mov    %esi,%edi
f0106090:	f7 f1                	div    %ecx
f0106092:	89 fa                	mov    %edi,%edx
f0106094:	83 c4 1c             	add    $0x1c,%esp
f0106097:	5b                   	pop    %ebx
f0106098:	5e                   	pop    %esi
f0106099:	5f                   	pop    %edi
f010609a:	5d                   	pop    %ebp
f010609b:	c3                   	ret    
f010609c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01060a0:	39 f2                	cmp    %esi,%edx
f01060a2:	77 7c                	ja     f0106120 <__udivdi3+0xd0>
f01060a4:	0f bd fa             	bsr    %edx,%edi
f01060a7:	83 f7 1f             	xor    $0x1f,%edi
f01060aa:	0f 84 98 00 00 00    	je     f0106148 <__udivdi3+0xf8>
f01060b0:	89 f9                	mov    %edi,%ecx
f01060b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01060b7:	29 f8                	sub    %edi,%eax
f01060b9:	d3 e2                	shl    %cl,%edx
f01060bb:	89 54 24 08          	mov    %edx,0x8(%esp)
f01060bf:	89 c1                	mov    %eax,%ecx
f01060c1:	89 da                	mov    %ebx,%edx
f01060c3:	d3 ea                	shr    %cl,%edx
f01060c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f01060c9:	09 d1                	or     %edx,%ecx
f01060cb:	89 f2                	mov    %esi,%edx
f01060cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01060d1:	89 f9                	mov    %edi,%ecx
f01060d3:	d3 e3                	shl    %cl,%ebx
f01060d5:	89 c1                	mov    %eax,%ecx
f01060d7:	d3 ea                	shr    %cl,%edx
f01060d9:	89 f9                	mov    %edi,%ecx
f01060db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01060df:	d3 e6                	shl    %cl,%esi
f01060e1:	89 eb                	mov    %ebp,%ebx
f01060e3:	89 c1                	mov    %eax,%ecx
f01060e5:	d3 eb                	shr    %cl,%ebx
f01060e7:	09 de                	or     %ebx,%esi
f01060e9:	89 f0                	mov    %esi,%eax
f01060eb:	f7 74 24 08          	divl   0x8(%esp)
f01060ef:	89 d6                	mov    %edx,%esi
f01060f1:	89 c3                	mov    %eax,%ebx
f01060f3:	f7 64 24 0c          	mull   0xc(%esp)
f01060f7:	39 d6                	cmp    %edx,%esi
f01060f9:	72 0c                	jb     f0106107 <__udivdi3+0xb7>
f01060fb:	89 f9                	mov    %edi,%ecx
f01060fd:	d3 e5                	shl    %cl,%ebp
f01060ff:	39 c5                	cmp    %eax,%ebp
f0106101:	73 5d                	jae    f0106160 <__udivdi3+0x110>
f0106103:	39 d6                	cmp    %edx,%esi
f0106105:	75 59                	jne    f0106160 <__udivdi3+0x110>
f0106107:	8d 43 ff             	lea    -0x1(%ebx),%eax
f010610a:	31 ff                	xor    %edi,%edi
f010610c:	89 fa                	mov    %edi,%edx
f010610e:	83 c4 1c             	add    $0x1c,%esp
f0106111:	5b                   	pop    %ebx
f0106112:	5e                   	pop    %esi
f0106113:	5f                   	pop    %edi
f0106114:	5d                   	pop    %ebp
f0106115:	c3                   	ret    
f0106116:	8d 76 00             	lea    0x0(%esi),%esi
f0106119:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0106120:	31 ff                	xor    %edi,%edi
f0106122:	31 c0                	xor    %eax,%eax
f0106124:	89 fa                	mov    %edi,%edx
f0106126:	83 c4 1c             	add    $0x1c,%esp
f0106129:	5b                   	pop    %ebx
f010612a:	5e                   	pop    %esi
f010612b:	5f                   	pop    %edi
f010612c:	5d                   	pop    %ebp
f010612d:	c3                   	ret    
f010612e:	66 90                	xchg   %ax,%ax
f0106130:	31 ff                	xor    %edi,%edi
f0106132:	89 e8                	mov    %ebp,%eax
f0106134:	89 f2                	mov    %esi,%edx
f0106136:	f7 f3                	div    %ebx
f0106138:	89 fa                	mov    %edi,%edx
f010613a:	83 c4 1c             	add    $0x1c,%esp
f010613d:	5b                   	pop    %ebx
f010613e:	5e                   	pop    %esi
f010613f:	5f                   	pop    %edi
f0106140:	5d                   	pop    %ebp
f0106141:	c3                   	ret    
f0106142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106148:	39 f2                	cmp    %esi,%edx
f010614a:	72 06                	jb     f0106152 <__udivdi3+0x102>
f010614c:	31 c0                	xor    %eax,%eax
f010614e:	39 eb                	cmp    %ebp,%ebx
f0106150:	77 d2                	ja     f0106124 <__udivdi3+0xd4>
f0106152:	b8 01 00 00 00       	mov    $0x1,%eax
f0106157:	eb cb                	jmp    f0106124 <__udivdi3+0xd4>
f0106159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106160:	89 d8                	mov    %ebx,%eax
f0106162:	31 ff                	xor    %edi,%edi
f0106164:	eb be                	jmp    f0106124 <__udivdi3+0xd4>
f0106166:	66 90                	xchg   %ax,%ax
f0106168:	66 90                	xchg   %ax,%ax
f010616a:	66 90                	xchg   %ax,%ax
f010616c:	66 90                	xchg   %ax,%ax
f010616e:	66 90                	xchg   %ax,%ax

f0106170 <__umoddi3>:
f0106170:	55                   	push   %ebp
f0106171:	57                   	push   %edi
f0106172:	56                   	push   %esi
f0106173:	53                   	push   %ebx
f0106174:	83 ec 1c             	sub    $0x1c,%esp
f0106177:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f010617b:	8b 74 24 30          	mov    0x30(%esp),%esi
f010617f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f0106183:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0106187:	85 ed                	test   %ebp,%ebp
f0106189:	89 f0                	mov    %esi,%eax
f010618b:	89 da                	mov    %ebx,%edx
f010618d:	75 19                	jne    f01061a8 <__umoddi3+0x38>
f010618f:	39 df                	cmp    %ebx,%edi
f0106191:	0f 86 b1 00 00 00    	jbe    f0106248 <__umoddi3+0xd8>
f0106197:	f7 f7                	div    %edi
f0106199:	89 d0                	mov    %edx,%eax
f010619b:	31 d2                	xor    %edx,%edx
f010619d:	83 c4 1c             	add    $0x1c,%esp
f01061a0:	5b                   	pop    %ebx
f01061a1:	5e                   	pop    %esi
f01061a2:	5f                   	pop    %edi
f01061a3:	5d                   	pop    %ebp
f01061a4:	c3                   	ret    
f01061a5:	8d 76 00             	lea    0x0(%esi),%esi
f01061a8:	39 dd                	cmp    %ebx,%ebp
f01061aa:	77 f1                	ja     f010619d <__umoddi3+0x2d>
f01061ac:	0f bd cd             	bsr    %ebp,%ecx
f01061af:	83 f1 1f             	xor    $0x1f,%ecx
f01061b2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01061b6:	0f 84 b4 00 00 00    	je     f0106270 <__umoddi3+0x100>
f01061bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01061c1:	89 c2                	mov    %eax,%edx
f01061c3:	8b 44 24 04          	mov    0x4(%esp),%eax
f01061c7:	29 c2                	sub    %eax,%edx
f01061c9:	89 c1                	mov    %eax,%ecx
f01061cb:	89 f8                	mov    %edi,%eax
f01061cd:	d3 e5                	shl    %cl,%ebp
f01061cf:	89 d1                	mov    %edx,%ecx
f01061d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01061d5:	d3 e8                	shr    %cl,%eax
f01061d7:	09 c5                	or     %eax,%ebp
f01061d9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01061dd:	89 c1                	mov    %eax,%ecx
f01061df:	d3 e7                	shl    %cl,%edi
f01061e1:	89 d1                	mov    %edx,%ecx
f01061e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01061e7:	89 df                	mov    %ebx,%edi
f01061e9:	d3 ef                	shr    %cl,%edi
f01061eb:	89 c1                	mov    %eax,%ecx
f01061ed:	89 f0                	mov    %esi,%eax
f01061ef:	d3 e3                	shl    %cl,%ebx
f01061f1:	89 d1                	mov    %edx,%ecx
f01061f3:	89 fa                	mov    %edi,%edx
f01061f5:	d3 e8                	shr    %cl,%eax
f01061f7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01061fc:	09 d8                	or     %ebx,%eax
f01061fe:	f7 f5                	div    %ebp
f0106200:	d3 e6                	shl    %cl,%esi
f0106202:	89 d1                	mov    %edx,%ecx
f0106204:	f7 64 24 08          	mull   0x8(%esp)
f0106208:	39 d1                	cmp    %edx,%ecx
f010620a:	89 c3                	mov    %eax,%ebx
f010620c:	89 d7                	mov    %edx,%edi
f010620e:	72 06                	jb     f0106216 <__umoddi3+0xa6>
f0106210:	75 0e                	jne    f0106220 <__umoddi3+0xb0>
f0106212:	39 c6                	cmp    %eax,%esi
f0106214:	73 0a                	jae    f0106220 <__umoddi3+0xb0>
f0106216:	2b 44 24 08          	sub    0x8(%esp),%eax
f010621a:	19 ea                	sbb    %ebp,%edx
f010621c:	89 d7                	mov    %edx,%edi
f010621e:	89 c3                	mov    %eax,%ebx
f0106220:	89 ca                	mov    %ecx,%edx
f0106222:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
f0106227:	29 de                	sub    %ebx,%esi
f0106229:	19 fa                	sbb    %edi,%edx
f010622b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
f010622f:	89 d0                	mov    %edx,%eax
f0106231:	d3 e0                	shl    %cl,%eax
f0106233:	89 d9                	mov    %ebx,%ecx
f0106235:	d3 ee                	shr    %cl,%esi
f0106237:	d3 ea                	shr    %cl,%edx
f0106239:	09 f0                	or     %esi,%eax
f010623b:	83 c4 1c             	add    $0x1c,%esp
f010623e:	5b                   	pop    %ebx
f010623f:	5e                   	pop    %esi
f0106240:	5f                   	pop    %edi
f0106241:	5d                   	pop    %ebp
f0106242:	c3                   	ret    
f0106243:	90                   	nop
f0106244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106248:	85 ff                	test   %edi,%edi
f010624a:	89 f9                	mov    %edi,%ecx
f010624c:	75 0b                	jne    f0106259 <__umoddi3+0xe9>
f010624e:	b8 01 00 00 00       	mov    $0x1,%eax
f0106253:	31 d2                	xor    %edx,%edx
f0106255:	f7 f7                	div    %edi
f0106257:	89 c1                	mov    %eax,%ecx
f0106259:	89 d8                	mov    %ebx,%eax
f010625b:	31 d2                	xor    %edx,%edx
f010625d:	f7 f1                	div    %ecx
f010625f:	89 f0                	mov    %esi,%eax
f0106261:	f7 f1                	div    %ecx
f0106263:	e9 31 ff ff ff       	jmp    f0106199 <__umoddi3+0x29>
f0106268:	90                   	nop
f0106269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106270:	39 dd                	cmp    %ebx,%ebp
f0106272:	72 08                	jb     f010627c <__umoddi3+0x10c>
f0106274:	39 f7                	cmp    %esi,%edi
f0106276:	0f 87 21 ff ff ff    	ja     f010619d <__umoddi3+0x2d>
f010627c:	89 da                	mov    %ebx,%edx
f010627e:	89 f0                	mov    %esi,%eax
f0106280:	29 f8                	sub    %edi,%eax
f0106282:	19 ea                	sbb    %ebp,%edx
f0106284:	e9 14 ff ff ff       	jmp    f010619d <__umoddi3+0x2d>
