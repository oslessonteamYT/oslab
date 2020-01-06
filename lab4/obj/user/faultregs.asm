
obj/user/faultregs：     文件格式 elf32-i386


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
  80002c:	e8 ae 05 00 00       	call   8005df <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 f1 15 80 00       	push   $0x8015f1
  800049:	68 c0 15 80 00       	push   $0x8015c0
  80004e:	e8 bf 06 00 00       	call   800712 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 d0 15 80 00       	push   $0x8015d0
  80005c:	68 d4 15 80 00       	push   $0x8015d4
  800061:	e8 ac 06 00 00       	call   800712 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	0f 84 31 02 00 00    	je     8002a4 <check_regs+0x271>
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 e8 15 80 00       	push   $0x8015e8
  80007b:	e8 92 06 00 00       	call   800712 <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  800088:	ff 73 04             	pushl  0x4(%ebx)
  80008b:	ff 76 04             	pushl  0x4(%esi)
  80008e:	68 f2 15 80 00       	push   $0x8015f2
  800093:	68 d4 15 80 00       	push   $0x8015d4
  800098:	e8 75 06 00 00       	call   800712 <cprintf>
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	8b 43 04             	mov    0x4(%ebx),%eax
  8000a3:	39 46 04             	cmp    %eax,0x4(%esi)
  8000a6:	0f 84 12 02 00 00    	je     8002be <check_regs+0x28b>
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 e8 15 80 00       	push   $0x8015e8
  8000b4:	e8 59 06 00 00       	call   800712 <cprintf>
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000c1:	ff 73 08             	pushl  0x8(%ebx)
  8000c4:	ff 76 08             	pushl  0x8(%esi)
  8000c7:	68 f6 15 80 00       	push   $0x8015f6
  8000cc:	68 d4 15 80 00       	push   $0x8015d4
  8000d1:	e8 3c 06 00 00       	call   800712 <cprintf>
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	8b 43 08             	mov    0x8(%ebx),%eax
  8000dc:	39 46 08             	cmp    %eax,0x8(%esi)
  8000df:	0f 84 ee 01 00 00    	je     8002d3 <check_regs+0x2a0>
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	68 e8 15 80 00       	push   $0x8015e8
  8000ed:	e8 20 06 00 00       	call   800712 <cprintf>
  8000f2:	83 c4 10             	add    $0x10,%esp
  8000f5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  8000fa:	ff 73 10             	pushl  0x10(%ebx)
  8000fd:	ff 76 10             	pushl  0x10(%esi)
  800100:	68 fa 15 80 00       	push   $0x8015fa
  800105:	68 d4 15 80 00       	push   $0x8015d4
  80010a:	e8 03 06 00 00       	call   800712 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	8b 43 10             	mov    0x10(%ebx),%eax
  800115:	39 46 10             	cmp    %eax,0x10(%esi)
  800118:	0f 84 ca 01 00 00    	je     8002e8 <check_regs+0x2b5>
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	68 e8 15 80 00       	push   $0x8015e8
  800126:	e8 e7 05 00 00       	call   800712 <cprintf>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800133:	ff 73 14             	pushl  0x14(%ebx)
  800136:	ff 76 14             	pushl  0x14(%esi)
  800139:	68 fe 15 80 00       	push   $0x8015fe
  80013e:	68 d4 15 80 00       	push   $0x8015d4
  800143:	e8 ca 05 00 00       	call   800712 <cprintf>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	8b 43 14             	mov    0x14(%ebx),%eax
  80014e:	39 46 14             	cmp    %eax,0x14(%esi)
  800151:	0f 84 a6 01 00 00    	je     8002fd <check_regs+0x2ca>
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	68 e8 15 80 00       	push   $0x8015e8
  80015f:	e8 ae 05 00 00       	call   800712 <cprintf>
  800164:	83 c4 10             	add    $0x10,%esp
  800167:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  80016c:	ff 73 18             	pushl  0x18(%ebx)
  80016f:	ff 76 18             	pushl  0x18(%esi)
  800172:	68 02 16 80 00       	push   $0x801602
  800177:	68 d4 15 80 00       	push   $0x8015d4
  80017c:	e8 91 05 00 00       	call   800712 <cprintf>
  800181:	83 c4 10             	add    $0x10,%esp
  800184:	8b 43 18             	mov    0x18(%ebx),%eax
  800187:	39 46 18             	cmp    %eax,0x18(%esi)
  80018a:	0f 84 82 01 00 00    	je     800312 <check_regs+0x2df>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 e8 15 80 00       	push   $0x8015e8
  800198:	e8 75 05 00 00       	call   800712 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001a5:	ff 73 1c             	pushl  0x1c(%ebx)
  8001a8:	ff 76 1c             	pushl  0x1c(%esi)
  8001ab:	68 06 16 80 00       	push   $0x801606
  8001b0:	68 d4 15 80 00       	push   $0x8015d4
  8001b5:	e8 58 05 00 00       	call   800712 <cprintf>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	8b 43 1c             	mov    0x1c(%ebx),%eax
  8001c0:	39 46 1c             	cmp    %eax,0x1c(%esi)
  8001c3:	0f 84 5e 01 00 00    	je     800327 <check_regs+0x2f4>
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	68 e8 15 80 00       	push   $0x8015e8
  8001d1:	e8 3c 05 00 00       	call   800712 <cprintf>
  8001d6:	83 c4 10             	add    $0x10,%esp
  8001d9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  8001de:	ff 73 20             	pushl  0x20(%ebx)
  8001e1:	ff 76 20             	pushl  0x20(%esi)
  8001e4:	68 0a 16 80 00       	push   $0x80160a
  8001e9:	68 d4 15 80 00       	push   $0x8015d4
  8001ee:	e8 1f 05 00 00       	call   800712 <cprintf>
  8001f3:	83 c4 10             	add    $0x10,%esp
  8001f6:	8b 43 20             	mov    0x20(%ebx),%eax
  8001f9:	39 46 20             	cmp    %eax,0x20(%esi)
  8001fc:	0f 84 3a 01 00 00    	je     80033c <check_regs+0x309>
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	68 e8 15 80 00       	push   $0x8015e8
  80020a:	e8 03 05 00 00       	call   800712 <cprintf>
  80020f:	83 c4 10             	add    $0x10,%esp
  800212:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  800217:	ff 73 24             	pushl  0x24(%ebx)
  80021a:	ff 76 24             	pushl  0x24(%esi)
  80021d:	68 0e 16 80 00       	push   $0x80160e
  800222:	68 d4 15 80 00       	push   $0x8015d4
  800227:	e8 e6 04 00 00       	call   800712 <cprintf>
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	8b 43 24             	mov    0x24(%ebx),%eax
  800232:	39 46 24             	cmp    %eax,0x24(%esi)
  800235:	0f 84 16 01 00 00    	je     800351 <check_regs+0x31e>
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	68 e8 15 80 00       	push   $0x8015e8
  800243:	e8 ca 04 00 00       	call   800712 <cprintf>
	CHECK(esp, esp);
  800248:	ff 73 28             	pushl  0x28(%ebx)
  80024b:	ff 76 28             	pushl  0x28(%esi)
  80024e:	68 15 16 80 00       	push   $0x801615
  800253:	68 d4 15 80 00       	push   $0x8015d4
  800258:	e8 b5 04 00 00       	call   800712 <cprintf>
  80025d:	83 c4 20             	add    $0x20,%esp
  800260:	8b 43 28             	mov    0x28(%ebx),%eax
  800263:	39 46 28             	cmp    %eax,0x28(%esi)
  800266:	0f 84 53 01 00 00    	je     8003bf <check_regs+0x38c>
  80026c:	83 ec 0c             	sub    $0xc,%esp
  80026f:	68 e8 15 80 00       	push   $0x8015e8
  800274:	e8 99 04 00 00       	call   800712 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800279:	83 c4 08             	add    $0x8,%esp
  80027c:	ff 75 0c             	pushl  0xc(%ebp)
  80027f:	68 19 16 80 00       	push   $0x801619
  800284:	e8 89 04 00 00       	call   800712 <cprintf>
  800289:	83 c4 10             	add    $0x10,%esp
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
  80028c:	83 ec 0c             	sub    $0xc,%esp
  80028f:	68 e8 15 80 00       	push   $0x8015e8
  800294:	e8 79 04 00 00       	call   800712 <cprintf>
  800299:	83 c4 10             	add    $0x10,%esp
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
	CHECK(edi, regs.reg_edi);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	68 e4 15 80 00       	push   $0x8015e4
  8002ac:	e8 61 04 00 00       	call   800712 <cprintf>
  8002b1:	83 c4 10             	add    $0x10,%esp
	int mismatch = 0;
  8002b4:	bf 00 00 00 00       	mov    $0x0,%edi
  8002b9:	e9 ca fd ff ff       	jmp    800088 <check_regs+0x55>
	CHECK(esi, regs.reg_esi);
  8002be:	83 ec 0c             	sub    $0xc,%esp
  8002c1:	68 e4 15 80 00       	push   $0x8015e4
  8002c6:	e8 47 04 00 00       	call   800712 <cprintf>
  8002cb:	83 c4 10             	add    $0x10,%esp
  8002ce:	e9 ee fd ff ff       	jmp    8000c1 <check_regs+0x8e>
	CHECK(ebp, regs.reg_ebp);
  8002d3:	83 ec 0c             	sub    $0xc,%esp
  8002d6:	68 e4 15 80 00       	push   $0x8015e4
  8002db:	e8 32 04 00 00       	call   800712 <cprintf>
  8002e0:	83 c4 10             	add    $0x10,%esp
  8002e3:	e9 12 fe ff ff       	jmp    8000fa <check_regs+0xc7>
	CHECK(ebx, regs.reg_ebx);
  8002e8:	83 ec 0c             	sub    $0xc,%esp
  8002eb:	68 e4 15 80 00       	push   $0x8015e4
  8002f0:	e8 1d 04 00 00       	call   800712 <cprintf>
  8002f5:	83 c4 10             	add    $0x10,%esp
  8002f8:	e9 36 fe ff ff       	jmp    800133 <check_regs+0x100>
	CHECK(edx, regs.reg_edx);
  8002fd:	83 ec 0c             	sub    $0xc,%esp
  800300:	68 e4 15 80 00       	push   $0x8015e4
  800305:	e8 08 04 00 00       	call   800712 <cprintf>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	e9 5a fe ff ff       	jmp    80016c <check_regs+0x139>
	CHECK(ecx, regs.reg_ecx);
  800312:	83 ec 0c             	sub    $0xc,%esp
  800315:	68 e4 15 80 00       	push   $0x8015e4
  80031a:	e8 f3 03 00 00       	call   800712 <cprintf>
  80031f:	83 c4 10             	add    $0x10,%esp
  800322:	e9 7e fe ff ff       	jmp    8001a5 <check_regs+0x172>
	CHECK(eax, regs.reg_eax);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	68 e4 15 80 00       	push   $0x8015e4
  80032f:	e8 de 03 00 00       	call   800712 <cprintf>
  800334:	83 c4 10             	add    $0x10,%esp
  800337:	e9 a2 fe ff ff       	jmp    8001de <check_regs+0x1ab>
	CHECK(eip, eip);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	68 e4 15 80 00       	push   $0x8015e4
  800344:	e8 c9 03 00 00       	call   800712 <cprintf>
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	e9 c6 fe ff ff       	jmp    800217 <check_regs+0x1e4>
	CHECK(eflags, eflags);
  800351:	83 ec 0c             	sub    $0xc,%esp
  800354:	68 e4 15 80 00       	push   $0x8015e4
  800359:	e8 b4 03 00 00       	call   800712 <cprintf>
	CHECK(esp, esp);
  80035e:	ff 73 28             	pushl  0x28(%ebx)
  800361:	ff 76 28             	pushl  0x28(%esi)
  800364:	68 15 16 80 00       	push   $0x801615
  800369:	68 d4 15 80 00       	push   $0x8015d4
  80036e:	e8 9f 03 00 00       	call   800712 <cprintf>
  800373:	83 c4 20             	add    $0x20,%esp
  800376:	8b 43 28             	mov    0x28(%ebx),%eax
  800379:	39 46 28             	cmp    %eax,0x28(%esi)
  80037c:	0f 85 ea fe ff ff    	jne    80026c <check_regs+0x239>
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	68 e4 15 80 00       	push   $0x8015e4
  80038a:	e8 83 03 00 00       	call   800712 <cprintf>
	cprintf("Registers %s ", testname);
  80038f:	83 c4 08             	add    $0x8,%esp
  800392:	ff 75 0c             	pushl  0xc(%ebp)
  800395:	68 19 16 80 00       	push   $0x801619
  80039a:	e8 73 03 00 00       	call   800712 <cprintf>
	if (!mismatch)
  80039f:	83 c4 10             	add    $0x10,%esp
  8003a2:	85 ff                	test   %edi,%edi
  8003a4:	0f 85 e2 fe ff ff    	jne    80028c <check_regs+0x259>
		cprintf("OK\n");
  8003aa:	83 ec 0c             	sub    $0xc,%esp
  8003ad:	68 e4 15 80 00       	push   $0x8015e4
  8003b2:	e8 5b 03 00 00       	call   800712 <cprintf>
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	e9 dd fe ff ff       	jmp    80029c <check_regs+0x269>
	CHECK(esp, esp);
  8003bf:	83 ec 0c             	sub    $0xc,%esp
  8003c2:	68 e4 15 80 00       	push   $0x8015e4
  8003c7:	e8 46 03 00 00       	call   800712 <cprintf>
	cprintf("Registers %s ", testname);
  8003cc:	83 c4 08             	add    $0x8,%esp
  8003cf:	ff 75 0c             	pushl  0xc(%ebp)
  8003d2:	68 19 16 80 00       	push   $0x801619
  8003d7:	e8 36 03 00 00       	call   800712 <cprintf>
  8003dc:	83 c4 10             	add    $0x10,%esp
  8003df:	e9 a8 fe ff ff       	jmp    80028c <check_regs+0x259>

008003e4 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 08             	sub    $0x8,%esp
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003ed:	8b 10                	mov    (%eax),%edx
  8003ef:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003f5:	0f 85 a3 00 00 00    	jne    80049e <pgfault+0xba>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003fb:	8b 50 08             	mov    0x8(%eax),%edx
  8003fe:	89 15 60 20 80 00    	mov    %edx,0x802060
  800404:	8b 50 0c             	mov    0xc(%eax),%edx
  800407:	89 15 64 20 80 00    	mov    %edx,0x802064
  80040d:	8b 50 10             	mov    0x10(%eax),%edx
  800410:	89 15 68 20 80 00    	mov    %edx,0x802068
  800416:	8b 50 14             	mov    0x14(%eax),%edx
  800419:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  80041f:	8b 50 18             	mov    0x18(%eax),%edx
  800422:	89 15 70 20 80 00    	mov    %edx,0x802070
  800428:	8b 50 1c             	mov    0x1c(%eax),%edx
  80042b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800431:	8b 50 20             	mov    0x20(%eax),%edx
  800434:	89 15 78 20 80 00    	mov    %edx,0x802078
  80043a:	8b 50 24             	mov    0x24(%eax),%edx
  80043d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800443:	8b 50 28             	mov    0x28(%eax),%edx
  800446:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags & ~FL_RF;
  80044c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80044f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800455:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  80045b:	8b 40 30             	mov    0x30(%eax),%eax
  80045e:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	68 3f 16 80 00       	push   $0x80163f
  80046b:	68 4d 16 80 00       	push   $0x80164d
  800470:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800475:	ba 38 16 80 00       	mov    $0x801638,%edx
  80047a:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  80047f:	e8 af fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800484:	83 c4 0c             	add    $0xc,%esp
  800487:	6a 07                	push   $0x7
  800489:	68 00 00 40 00       	push   $0x400000
  80048e:	6a 00                	push   $0x0
  800490:	e8 95 0c 00 00       	call   80112a <sys_page_alloc>
  800495:	83 c4 10             	add    $0x10,%esp
  800498:	85 c0                	test   %eax,%eax
  80049a:	78 1a                	js     8004b6 <pgfault+0xd2>
		panic("sys_page_alloc: %e", r);
}
  80049c:	c9                   	leave  
  80049d:	c3                   	ret    
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	ff 70 28             	pushl  0x28(%eax)
  8004a4:	52                   	push   %edx
  8004a5:	68 80 16 80 00       	push   $0x801680
  8004aa:	6a 51                	push   $0x51
  8004ac:	68 27 16 80 00       	push   $0x801627
  8004b1:	e8 81 01 00 00       	call   800637 <_panic>
		panic("sys_page_alloc: %e", r);
  8004b6:	50                   	push   %eax
  8004b7:	68 54 16 80 00       	push   $0x801654
  8004bc:	6a 5c                	push   $0x5c
  8004be:	68 27 16 80 00       	push   $0x801627
  8004c3:	e8 6f 01 00 00       	call   800637 <_panic>

008004c8 <umain>:

void
umain(int argc, char **argv)
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  8004ce:	68 e4 03 80 00       	push   $0x8003e4
  8004d3:	e8 01 0e 00 00       	call   8012d9 <set_pgfault_handler>

	asm volatile(
  8004d8:	50                   	push   %eax
  8004d9:	9c                   	pushf  
  8004da:	58                   	pop    %eax
  8004db:	0d d5 08 00 00       	or     $0x8d5,%eax
  8004e0:	50                   	push   %eax
  8004e1:	9d                   	popf   
  8004e2:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  8004e7:	8d 05 22 05 80 00    	lea    0x800522,%eax
  8004ed:	a3 c0 20 80 00       	mov    %eax,0x8020c0
  8004f2:	58                   	pop    %eax
  8004f3:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8004f9:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  8004ff:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800505:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80050b:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800511:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  800517:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80051c:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800522:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  800529:	00 00 00 
  80052c:	89 3d 20 20 80 00    	mov    %edi,0x802020
  800532:	89 35 24 20 80 00    	mov    %esi,0x802024
  800538:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  80053e:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  800544:	89 15 34 20 80 00    	mov    %edx,0x802034
  80054a:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  800550:	a3 3c 20 80 00       	mov    %eax,0x80203c
  800555:	89 25 48 20 80 00    	mov    %esp,0x802048
  80055b:	8b 3d a0 20 80 00    	mov    0x8020a0,%edi
  800561:	8b 35 a4 20 80 00    	mov    0x8020a4,%esi
  800567:	8b 2d a8 20 80 00    	mov    0x8020a8,%ebp
  80056d:	8b 1d b0 20 80 00    	mov    0x8020b0,%ebx
  800573:	8b 15 b4 20 80 00    	mov    0x8020b4,%edx
  800579:	8b 0d b8 20 80 00    	mov    0x8020b8,%ecx
  80057f:	a1 bc 20 80 00       	mov    0x8020bc,%eax
  800584:	8b 25 c8 20 80 00    	mov    0x8020c8,%esp
  80058a:	50                   	push   %eax
  80058b:	9c                   	pushf  
  80058c:	58                   	pop    %eax
  80058d:	a3 44 20 80 00       	mov    %eax,0x802044
  800592:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80059d:	74 10                	je     8005af <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  80059f:	83 ec 0c             	sub    $0xc,%esp
  8005a2:	68 b4 16 80 00       	push   $0x8016b4
  8005a7:	e8 66 01 00 00       	call   800712 <cprintf>
  8005ac:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  8005af:	a1 c0 20 80 00       	mov    0x8020c0,%eax
  8005b4:	a3 40 20 80 00       	mov    %eax,0x802040

	check_regs(&before, "before", &after, "after", "after page-fault");
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	68 67 16 80 00       	push   $0x801667
  8005c1:	68 78 16 80 00       	push   $0x801678
  8005c6:	b9 20 20 80 00       	mov    $0x802020,%ecx
  8005cb:	ba 38 16 80 00       	mov    $0x801638,%edx
  8005d0:	b8 a0 20 80 00       	mov    $0x8020a0,%eax
  8005d5:	e8 59 fa ff ff       	call   800033 <check_regs>
}
  8005da:	83 c4 10             	add    $0x10,%esp
  8005dd:	c9                   	leave  
  8005de:	c3                   	ret    

008005df <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005df:	55                   	push   %ebp
  8005e0:	89 e5                	mov    %esp,%ebp
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8005ea:	e8 fd 0a 00 00       	call   8010ec <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  8005ef:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005f4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005f7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005fc:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800601:	85 db                	test   %ebx,%ebx
  800603:	7e 07                	jle    80060c <libmain+0x2d>
		binaryname = argv[0];
  800605:	8b 06                	mov    (%esi),%eax
  800607:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	56                   	push   %esi
  800610:	53                   	push   %ebx
  800611:	e8 b2 fe ff ff       	call   8004c8 <umain>

	// exit gracefully
	exit();
  800616:	e8 0a 00 00 00       	call   800625 <exit>
}
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800621:	5b                   	pop    %ebx
  800622:	5e                   	pop    %esi
  800623:	5d                   	pop    %ebp
  800624:	c3                   	ret    

00800625 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800625:	55                   	push   %ebp
  800626:	89 e5                	mov    %esp,%ebp
  800628:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80062b:	6a 00                	push   $0x0
  80062d:	e8 79 0a 00 00       	call   8010ab <sys_env_destroy>
}
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	c9                   	leave  
  800636:	c3                   	ret    

00800637 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	56                   	push   %esi
  80063b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80063c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80063f:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800645:	e8 a2 0a 00 00       	call   8010ec <sys_getenvid>
  80064a:	83 ec 0c             	sub    $0xc,%esp
  80064d:	ff 75 0c             	pushl  0xc(%ebp)
  800650:	ff 75 08             	pushl  0x8(%ebp)
  800653:	56                   	push   %esi
  800654:	50                   	push   %eax
  800655:	68 e0 16 80 00       	push   $0x8016e0
  80065a:	e8 b3 00 00 00       	call   800712 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80065f:	83 c4 18             	add    $0x18,%esp
  800662:	53                   	push   %ebx
  800663:	ff 75 10             	pushl  0x10(%ebp)
  800666:	e8 56 00 00 00       	call   8006c1 <vcprintf>
	cprintf("\n");
  80066b:	c7 04 24 f0 15 80 00 	movl   $0x8015f0,(%esp)
  800672:	e8 9b 00 00 00       	call   800712 <cprintf>
  800677:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80067a:	cc                   	int3   
  80067b:	eb fd                	jmp    80067a <_panic+0x43>

0080067d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80067d:	55                   	push   %ebp
  80067e:	89 e5                	mov    %esp,%ebp
  800680:	53                   	push   %ebx
  800681:	83 ec 04             	sub    $0x4,%esp
  800684:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800687:	8b 13                	mov    (%ebx),%edx
  800689:	8d 42 01             	lea    0x1(%edx),%eax
  80068c:	89 03                	mov    %eax,(%ebx)
  80068e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800691:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800695:	3d ff 00 00 00       	cmp    $0xff,%eax
  80069a:	74 09                	je     8006a5 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80069c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8006a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006a3:	c9                   	leave  
  8006a4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	68 ff 00 00 00       	push   $0xff
  8006ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8006b0:	50                   	push   %eax
  8006b1:	e8 b8 09 00 00       	call   80106e <sys_cputs>
		b->idx = 0;
  8006b6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	eb db                	jmp    80069c <putch+0x1f>

008006c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8006ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8006d1:	00 00 00 
	b.cnt = 0;
  8006d4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8006db:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8006de:	ff 75 0c             	pushl  0xc(%ebp)
  8006e1:	ff 75 08             	pushl  0x8(%ebp)
  8006e4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	68 7d 06 80 00       	push   $0x80067d
  8006f0:	e8 1a 01 00 00       	call   80080f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006f5:	83 c4 08             	add    $0x8,%esp
  8006f8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	e8 64 09 00 00       	call   80106e <sys_cputs>

	return b.cnt;
}
  80070a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800710:	c9                   	leave  
  800711:	c3                   	ret    

00800712 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800718:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80071b:	50                   	push   %eax
  80071c:	ff 75 08             	pushl  0x8(%ebp)
  80071f:	e8 9d ff ff ff       	call   8006c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800724:	c9                   	leave  
  800725:	c3                   	ret    

00800726 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	57                   	push   %edi
  80072a:	56                   	push   %esi
  80072b:	53                   	push   %ebx
  80072c:	83 ec 1c             	sub    $0x1c,%esp
  80072f:	89 c7                	mov    %eax,%edi
  800731:	89 d6                	mov    %edx,%esi
  800733:	8b 45 08             	mov    0x8(%ebp),%eax
  800736:	8b 55 0c             	mov    0xc(%ebp),%edx
  800739:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80073f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800742:	bb 00 00 00 00       	mov    $0x0,%ebx
  800747:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80074a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80074d:	39 d3                	cmp    %edx,%ebx
  80074f:	72 05                	jb     800756 <printnum+0x30>
  800751:	39 45 10             	cmp    %eax,0x10(%ebp)
  800754:	77 7a                	ja     8007d0 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800756:	83 ec 0c             	sub    $0xc,%esp
  800759:	ff 75 18             	pushl  0x18(%ebp)
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800762:	53                   	push   %ebx
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076c:	ff 75 e0             	pushl  -0x20(%ebp)
  80076f:	ff 75 dc             	pushl  -0x24(%ebp)
  800772:	ff 75 d8             	pushl  -0x28(%ebp)
  800775:	e8 f6 0b 00 00       	call   801370 <__udivdi3>
  80077a:	83 c4 18             	add    $0x18,%esp
  80077d:	52                   	push   %edx
  80077e:	50                   	push   %eax
  80077f:	89 f2                	mov    %esi,%edx
  800781:	89 f8                	mov    %edi,%eax
  800783:	e8 9e ff ff ff       	call   800726 <printnum>
  800788:	83 c4 20             	add    $0x20,%esp
  80078b:	eb 13                	jmp    8007a0 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80078d:	83 ec 08             	sub    $0x8,%esp
  800790:	56                   	push   %esi
  800791:	ff 75 18             	pushl  0x18(%ebp)
  800794:	ff d7                	call   *%edi
  800796:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800799:	83 eb 01             	sub    $0x1,%ebx
  80079c:	85 db                	test   %ebx,%ebx
  80079e:	7f ed                	jg     80078d <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	56                   	push   %esi
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8007ad:	ff 75 dc             	pushl  -0x24(%ebp)
  8007b0:	ff 75 d8             	pushl  -0x28(%ebp)
  8007b3:	e8 d8 0c 00 00       	call   801490 <__umoddi3>
  8007b8:	83 c4 14             	add    $0x14,%esp
  8007bb:	0f be 80 03 17 80 00 	movsbl 0x801703(%eax),%eax
  8007c2:	50                   	push   %eax
  8007c3:	ff d7                	call   *%edi
}
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5f                   	pop    %edi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    
  8007d0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8007d3:	eb c4                	jmp    800799 <printnum+0x73>

008007d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007df:	8b 10                	mov    (%eax),%edx
  8007e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8007e4:	73 0a                	jae    8007f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8007e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007e9:	89 08                	mov    %ecx,(%eax)
  8007eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ee:	88 02                	mov    %al,(%edx)
}
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <printfmt>:
{
  8007f2:	55                   	push   %ebp
  8007f3:	89 e5                	mov    %esp,%ebp
  8007f5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8007f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007fb:	50                   	push   %eax
  8007fc:	ff 75 10             	pushl  0x10(%ebp)
  8007ff:	ff 75 0c             	pushl  0xc(%ebp)
  800802:	ff 75 08             	pushl  0x8(%ebp)
  800805:	e8 05 00 00 00       	call   80080f <vprintfmt>
}
  80080a:	83 c4 10             	add    $0x10,%esp
  80080d:	c9                   	leave  
  80080e:	c3                   	ret    

0080080f <vprintfmt>:
{
  80080f:	55                   	push   %ebp
  800810:	89 e5                	mov    %esp,%ebp
  800812:	57                   	push   %edi
  800813:	56                   	push   %esi
  800814:	53                   	push   %ebx
  800815:	83 ec 2c             	sub    $0x2c,%esp
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80081e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800821:	e9 c1 03 00 00       	jmp    800be7 <vprintfmt+0x3d8>
		padc = ' ';
  800826:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  80082a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800831:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800838:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80083f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800844:	8d 47 01             	lea    0x1(%edi),%eax
  800847:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80084a:	0f b6 17             	movzbl (%edi),%edx
  80084d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800850:	3c 55                	cmp    $0x55,%al
  800852:	0f 87 12 04 00 00    	ja     800c6a <vprintfmt+0x45b>
  800858:	0f b6 c0             	movzbl %al,%eax
  80085b:	ff 24 85 c0 17 80 00 	jmp    *0x8017c0(,%eax,4)
  800862:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800865:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800869:	eb d9                	jmp    800844 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80086b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  80086e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800872:	eb d0                	jmp    800844 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800874:	0f b6 d2             	movzbl %dl,%edx
  800877:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800882:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800885:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800889:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80088c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80088f:	83 f9 09             	cmp    $0x9,%ecx
  800892:	77 55                	ja     8008e9 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800894:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800897:	eb e9                	jmp    800882 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800899:	8b 45 14             	mov    0x14(%ebp),%eax
  80089c:	8b 00                	mov    (%eax),%eax
  80089e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 40 04             	lea    0x4(%eax),%eax
  8008a7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8008ad:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008b1:	79 91                	jns    800844 <vprintfmt+0x35>
				width = precision, precision = -1;
  8008b3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008b9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008c0:	eb 82                	jmp    800844 <vprintfmt+0x35>
  8008c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8008cc:	0f 49 d0             	cmovns %eax,%edx
  8008cf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8008d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008d5:	e9 6a ff ff ff       	jmp    800844 <vprintfmt+0x35>
  8008da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8008dd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008e4:	e9 5b ff ff ff       	jmp    800844 <vprintfmt+0x35>
  8008e9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008ec:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8008ef:	eb bc                	jmp    8008ad <vprintfmt+0x9e>
			lflag++;
  8008f1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8008f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8008f7:	e9 48 ff ff ff       	jmp    800844 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	8d 78 04             	lea    0x4(%eax),%edi
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	53                   	push   %ebx
  800906:	ff 30                	pushl  (%eax)
  800908:	ff d6                	call   *%esi
			break;
  80090a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80090d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800910:	e9 cf 02 00 00       	jmp    800be4 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  800915:	8b 45 14             	mov    0x14(%ebp),%eax
  800918:	8d 78 04             	lea    0x4(%eax),%edi
  80091b:	8b 00                	mov    (%eax),%eax
  80091d:	99                   	cltd   
  80091e:	31 d0                	xor    %edx,%eax
  800920:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800922:	83 f8 08             	cmp    $0x8,%eax
  800925:	7f 23                	jg     80094a <vprintfmt+0x13b>
  800927:	8b 14 85 20 19 80 00 	mov    0x801920(,%eax,4),%edx
  80092e:	85 d2                	test   %edx,%edx
  800930:	74 18                	je     80094a <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800932:	52                   	push   %edx
  800933:	68 24 17 80 00       	push   $0x801724
  800938:	53                   	push   %ebx
  800939:	56                   	push   %esi
  80093a:	e8 b3 fe ff ff       	call   8007f2 <printfmt>
  80093f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800942:	89 7d 14             	mov    %edi,0x14(%ebp)
  800945:	e9 9a 02 00 00       	jmp    800be4 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80094a:	50                   	push   %eax
  80094b:	68 1b 17 80 00       	push   $0x80171b
  800950:	53                   	push   %ebx
  800951:	56                   	push   %esi
  800952:	e8 9b fe ff ff       	call   8007f2 <printfmt>
  800957:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80095a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80095d:	e9 82 02 00 00       	jmp    800be4 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800962:	8b 45 14             	mov    0x14(%ebp),%eax
  800965:	83 c0 04             	add    $0x4,%eax
  800968:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80096b:	8b 45 14             	mov    0x14(%ebp),%eax
  80096e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800970:	85 ff                	test   %edi,%edi
  800972:	b8 14 17 80 00       	mov    $0x801714,%eax
  800977:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80097a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80097e:	0f 8e bd 00 00 00    	jle    800a41 <vprintfmt+0x232>
  800984:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800988:	75 0e                	jne    800998 <vprintfmt+0x189>
  80098a:	89 75 08             	mov    %esi,0x8(%ebp)
  80098d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800990:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800993:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800996:	eb 6d                	jmp    800a05 <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800998:	83 ec 08             	sub    $0x8,%esp
  80099b:	ff 75 d0             	pushl  -0x30(%ebp)
  80099e:	57                   	push   %edi
  80099f:	e8 6e 03 00 00       	call   800d12 <strnlen>
  8009a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8009a7:	29 c1                	sub    %eax,%ecx
  8009a9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8009ac:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009af:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009b6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009b9:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bb:	eb 0f                	jmp    8009cc <vprintfmt+0x1bd>
					putch(padc, putdat);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	53                   	push   %ebx
  8009c1:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c4:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8009c6:	83 ef 01             	sub    $0x1,%edi
  8009c9:	83 c4 10             	add    $0x10,%esp
  8009cc:	85 ff                	test   %edi,%edi
  8009ce:	7f ed                	jg     8009bd <vprintfmt+0x1ae>
  8009d0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009d6:	85 c9                	test   %ecx,%ecx
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dd:	0f 49 c1             	cmovns %ecx,%eax
  8009e0:	29 c1                	sub    %eax,%ecx
  8009e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009eb:	89 cb                	mov    %ecx,%ebx
  8009ed:	eb 16                	jmp    800a05 <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8009ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f3:	75 31                	jne    800a26 <vprintfmt+0x217>
					putch(ch, putdat);
  8009f5:	83 ec 08             	sub    $0x8,%esp
  8009f8:	ff 75 0c             	pushl  0xc(%ebp)
  8009fb:	50                   	push   %eax
  8009fc:	ff 55 08             	call   *0x8(%ebp)
  8009ff:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a02:	83 eb 01             	sub    $0x1,%ebx
  800a05:	83 c7 01             	add    $0x1,%edi
  800a08:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800a0c:	0f be c2             	movsbl %dl,%eax
  800a0f:	85 c0                	test   %eax,%eax
  800a11:	74 59                	je     800a6c <vprintfmt+0x25d>
  800a13:	85 f6                	test   %esi,%esi
  800a15:	78 d8                	js     8009ef <vprintfmt+0x1e0>
  800a17:	83 ee 01             	sub    $0x1,%esi
  800a1a:	79 d3                	jns    8009ef <vprintfmt+0x1e0>
  800a1c:	89 df                	mov    %ebx,%edi
  800a1e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a24:	eb 37                	jmp    800a5d <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800a26:	0f be d2             	movsbl %dl,%edx
  800a29:	83 ea 20             	sub    $0x20,%edx
  800a2c:	83 fa 5e             	cmp    $0x5e,%edx
  800a2f:	76 c4                	jbe    8009f5 <vprintfmt+0x1e6>
					putch('?', putdat);
  800a31:	83 ec 08             	sub    $0x8,%esp
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	6a 3f                	push   $0x3f
  800a39:	ff 55 08             	call   *0x8(%ebp)
  800a3c:	83 c4 10             	add    $0x10,%esp
  800a3f:	eb c1                	jmp    800a02 <vprintfmt+0x1f3>
  800a41:	89 75 08             	mov    %esi,0x8(%ebp)
  800a44:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a47:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a4a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a4d:	eb b6                	jmp    800a05 <vprintfmt+0x1f6>
				putch(' ', putdat);
  800a4f:	83 ec 08             	sub    $0x8,%esp
  800a52:	53                   	push   %ebx
  800a53:	6a 20                	push   $0x20
  800a55:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800a57:	83 ef 01             	sub    $0x1,%edi
  800a5a:	83 c4 10             	add    $0x10,%esp
  800a5d:	85 ff                	test   %edi,%edi
  800a5f:	7f ee                	jg     800a4f <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800a61:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a64:	89 45 14             	mov    %eax,0x14(%ebp)
  800a67:	e9 78 01 00 00       	jmp    800be4 <vprintfmt+0x3d5>
  800a6c:	89 df                	mov    %ebx,%edi
  800a6e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a74:	eb e7                	jmp    800a5d <vprintfmt+0x24e>
	if (lflag >= 2)
  800a76:	83 f9 01             	cmp    $0x1,%ecx
  800a79:	7e 3f                	jle    800aba <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800a7b:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7e:	8b 50 04             	mov    0x4(%eax),%edx
  800a81:	8b 00                	mov    (%eax),%eax
  800a83:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a86:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a89:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8c:	8d 40 08             	lea    0x8(%eax),%eax
  800a8f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800a92:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800a96:	79 5c                	jns    800af4 <vprintfmt+0x2e5>
				putch('-', putdat);
  800a98:	83 ec 08             	sub    $0x8,%esp
  800a9b:	53                   	push   %ebx
  800a9c:	6a 2d                	push   $0x2d
  800a9e:	ff d6                	call   *%esi
				num = -(long long) num;
  800aa0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800aa3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800aa6:	f7 da                	neg    %edx
  800aa8:	83 d1 00             	adc    $0x0,%ecx
  800aab:	f7 d9                	neg    %ecx
  800aad:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ab0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ab5:	e9 10 01 00 00       	jmp    800bca <vprintfmt+0x3bb>
	else if (lflag)
  800aba:	85 c9                	test   %ecx,%ecx
  800abc:	75 1b                	jne    800ad9 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800abe:	8b 45 14             	mov    0x14(%ebp),%eax
  800ac1:	8b 00                	mov    (%eax),%eax
  800ac3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac6:	89 c1                	mov    %eax,%ecx
  800ac8:	c1 f9 1f             	sar    $0x1f,%ecx
  800acb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ace:	8b 45 14             	mov    0x14(%ebp),%eax
  800ad1:	8d 40 04             	lea    0x4(%eax),%eax
  800ad4:	89 45 14             	mov    %eax,0x14(%ebp)
  800ad7:	eb b9                	jmp    800a92 <vprintfmt+0x283>
		return va_arg(*ap, long);
  800ad9:	8b 45 14             	mov    0x14(%ebp),%eax
  800adc:	8b 00                	mov    (%eax),%eax
  800ade:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	c1 f9 1f             	sar    $0x1f,%ecx
  800ae6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ae9:	8b 45 14             	mov    0x14(%ebp),%eax
  800aec:	8d 40 04             	lea    0x4(%eax),%eax
  800aef:	89 45 14             	mov    %eax,0x14(%ebp)
  800af2:	eb 9e                	jmp    800a92 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  800af4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800af7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800afa:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aff:	e9 c6 00 00 00       	jmp    800bca <vprintfmt+0x3bb>
	if (lflag >= 2)
  800b04:	83 f9 01             	cmp    $0x1,%ecx
  800b07:	7e 18                	jle    800b21 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  800b09:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0c:	8b 10                	mov    (%eax),%edx
  800b0e:	8b 48 04             	mov    0x4(%eax),%ecx
  800b11:	8d 40 08             	lea    0x8(%eax),%eax
  800b14:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b17:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b1c:	e9 a9 00 00 00       	jmp    800bca <vprintfmt+0x3bb>
	else if (lflag)
  800b21:	85 c9                	test   %ecx,%ecx
  800b23:	75 1a                	jne    800b3f <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  800b25:	8b 45 14             	mov    0x14(%ebp),%eax
  800b28:	8b 10                	mov    (%eax),%edx
  800b2a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b2f:	8d 40 04             	lea    0x4(%eax),%eax
  800b32:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b35:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b3a:	e9 8b 00 00 00       	jmp    800bca <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800b3f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b42:	8b 10                	mov    (%eax),%edx
  800b44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b49:	8d 40 04             	lea    0x4(%eax),%eax
  800b4c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800b4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b54:	eb 74                	jmp    800bca <vprintfmt+0x3bb>
	if (lflag >= 2)
  800b56:	83 f9 01             	cmp    $0x1,%ecx
  800b59:	7e 15                	jle    800b70 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800b5b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5e:	8b 10                	mov    (%eax),%edx
  800b60:	8b 48 04             	mov    0x4(%eax),%ecx
  800b63:	8d 40 08             	lea    0x8(%eax),%eax
  800b66:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b69:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6e:	eb 5a                	jmp    800bca <vprintfmt+0x3bb>
	else if (lflag)
  800b70:	85 c9                	test   %ecx,%ecx
  800b72:	75 17                	jne    800b8b <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800b74:	8b 45 14             	mov    0x14(%ebp),%eax
  800b77:	8b 10                	mov    (%eax),%edx
  800b79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7e:	8d 40 04             	lea    0x4(%eax),%eax
  800b81:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b84:	b8 08 00 00 00       	mov    $0x8,%eax
  800b89:	eb 3f                	jmp    800bca <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800b8b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8e:	8b 10                	mov    (%eax),%edx
  800b90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b95:	8d 40 04             	lea    0x4(%eax),%eax
  800b98:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800b9b:	b8 08 00 00 00       	mov    $0x8,%eax
  800ba0:	eb 28                	jmp    800bca <vprintfmt+0x3bb>
			putch('0', putdat);
  800ba2:	83 ec 08             	sub    $0x8,%esp
  800ba5:	53                   	push   %ebx
  800ba6:	6a 30                	push   $0x30
  800ba8:	ff d6                	call   *%esi
			putch('x', putdat);
  800baa:	83 c4 08             	add    $0x8,%esp
  800bad:	53                   	push   %ebx
  800bae:	6a 78                	push   $0x78
  800bb0:	ff d6                	call   *%esi
			num = (unsigned long long)
  800bb2:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb5:	8b 10                	mov    (%eax),%edx
  800bb7:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800bbc:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800bbf:	8d 40 04             	lea    0x4(%eax),%eax
  800bc2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800bc5:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bd1:	57                   	push   %edi
  800bd2:	ff 75 e0             	pushl  -0x20(%ebp)
  800bd5:	50                   	push   %eax
  800bd6:	51                   	push   %ecx
  800bd7:	52                   	push   %edx
  800bd8:	89 da                	mov    %ebx,%edx
  800bda:	89 f0                	mov    %esi,%eax
  800bdc:	e8 45 fb ff ff       	call   800726 <printnum>
			break;
  800be1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800be4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800be7:	83 c7 01             	add    $0x1,%edi
  800bea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800bee:	83 f8 25             	cmp    $0x25,%eax
  800bf1:	0f 84 2f fc ff ff    	je     800826 <vprintfmt+0x17>
			if (ch == '\0')
  800bf7:	85 c0                	test   %eax,%eax
  800bf9:	0f 84 8b 00 00 00    	je     800c8a <vprintfmt+0x47b>
			putch(ch, putdat);
  800bff:	83 ec 08             	sub    $0x8,%esp
  800c02:	53                   	push   %ebx
  800c03:	50                   	push   %eax
  800c04:	ff d6                	call   *%esi
  800c06:	83 c4 10             	add    $0x10,%esp
  800c09:	eb dc                	jmp    800be7 <vprintfmt+0x3d8>
	if (lflag >= 2)
  800c0b:	83 f9 01             	cmp    $0x1,%ecx
  800c0e:	7e 15                	jle    800c25 <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800c10:	8b 45 14             	mov    0x14(%ebp),%eax
  800c13:	8b 10                	mov    (%eax),%edx
  800c15:	8b 48 04             	mov    0x4(%eax),%ecx
  800c18:	8d 40 08             	lea    0x8(%eax),%eax
  800c1b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c1e:	b8 10 00 00 00       	mov    $0x10,%eax
  800c23:	eb a5                	jmp    800bca <vprintfmt+0x3bb>
	else if (lflag)
  800c25:	85 c9                	test   %ecx,%ecx
  800c27:	75 17                	jne    800c40 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800c29:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2c:	8b 10                	mov    (%eax),%edx
  800c2e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c33:	8d 40 04             	lea    0x4(%eax),%eax
  800c36:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c39:	b8 10 00 00 00       	mov    $0x10,%eax
  800c3e:	eb 8a                	jmp    800bca <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800c40:	8b 45 14             	mov    0x14(%ebp),%eax
  800c43:	8b 10                	mov    (%eax),%edx
  800c45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4a:	8d 40 04             	lea    0x4(%eax),%eax
  800c4d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c50:	b8 10 00 00 00       	mov    $0x10,%eax
  800c55:	e9 70 ff ff ff       	jmp    800bca <vprintfmt+0x3bb>
			putch(ch, putdat);
  800c5a:	83 ec 08             	sub    $0x8,%esp
  800c5d:	53                   	push   %ebx
  800c5e:	6a 25                	push   $0x25
  800c60:	ff d6                	call   *%esi
			break;
  800c62:	83 c4 10             	add    $0x10,%esp
  800c65:	e9 7a ff ff ff       	jmp    800be4 <vprintfmt+0x3d5>
			putch('%', putdat);
  800c6a:	83 ec 08             	sub    $0x8,%esp
  800c6d:	53                   	push   %ebx
  800c6e:	6a 25                	push   $0x25
  800c70:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	89 f8                	mov    %edi,%eax
  800c77:	eb 03                	jmp    800c7c <vprintfmt+0x46d>
  800c79:	83 e8 01             	sub    $0x1,%eax
  800c7c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c80:	75 f7                	jne    800c79 <vprintfmt+0x46a>
  800c82:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c85:	e9 5a ff ff ff       	jmp    800be4 <vprintfmt+0x3d5>
}
  800c8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8d:	5b                   	pop    %ebx
  800c8e:	5e                   	pop    %esi
  800c8f:	5f                   	pop    %edi
  800c90:	5d                   	pop    %ebp
  800c91:	c3                   	ret    

00800c92 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c92:	55                   	push   %ebp
  800c93:	89 e5                	mov    %esp,%ebp
  800c95:	83 ec 18             	sub    $0x18,%esp
  800c98:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c9e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ca5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ca8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800caf:	85 c0                	test   %eax,%eax
  800cb1:	74 26                	je     800cd9 <vsnprintf+0x47>
  800cb3:	85 d2                	test   %edx,%edx
  800cb5:	7e 22                	jle    800cd9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cb7:	ff 75 14             	pushl  0x14(%ebp)
  800cba:	ff 75 10             	pushl  0x10(%ebp)
  800cbd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc0:	50                   	push   %eax
  800cc1:	68 d5 07 80 00       	push   $0x8007d5
  800cc6:	e8 44 fb ff ff       	call   80080f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ccb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd4:	83 c4 10             	add    $0x10,%esp
}
  800cd7:	c9                   	leave  
  800cd8:	c3                   	ret    
		return -E_INVAL;
  800cd9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cde:	eb f7                	jmp    800cd7 <vsnprintf+0x45>

00800ce0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800ce6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800ce9:	50                   	push   %eax
  800cea:	ff 75 10             	pushl  0x10(%ebp)
  800ced:	ff 75 0c             	pushl  0xc(%ebp)
  800cf0:	ff 75 08             	pushl  0x8(%ebp)
  800cf3:	e8 9a ff ff ff       	call   800c92 <vsnprintf>
	va_end(ap);

	return rc;
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d00:	b8 00 00 00 00       	mov    $0x0,%eax
  800d05:	eb 03                	jmp    800d0a <strlen+0x10>
		n++;
  800d07:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800d0a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d0e:	75 f7                	jne    800d07 <strlen+0xd>
	return n;
}
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d18:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d20:	eb 03                	jmp    800d25 <strnlen+0x13>
		n++;
  800d22:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d25:	39 d0                	cmp    %edx,%eax
  800d27:	74 06                	je     800d2f <strnlen+0x1d>
  800d29:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d2d:	75 f3                	jne    800d22 <strnlen+0x10>
	return n;
}
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    

00800d31 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	53                   	push   %ebx
  800d35:	8b 45 08             	mov    0x8(%ebp),%eax
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	83 c1 01             	add    $0x1,%ecx
  800d40:	83 c2 01             	add    $0x1,%edx
  800d43:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d47:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d4a:	84 db                	test   %bl,%bl
  800d4c:	75 ef                	jne    800d3d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d4e:	5b                   	pop    %ebx
  800d4f:	5d                   	pop    %ebp
  800d50:	c3                   	ret    

00800d51 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	53                   	push   %ebx
  800d55:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d58:	53                   	push   %ebx
  800d59:	e8 9c ff ff ff       	call   800cfa <strlen>
  800d5e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d61:	ff 75 0c             	pushl  0xc(%ebp)
  800d64:	01 d8                	add    %ebx,%eax
  800d66:	50                   	push   %eax
  800d67:	e8 c5 ff ff ff       	call   800d31 <strcpy>
	return dst;
}
  800d6c:	89 d8                	mov    %ebx,%eax
  800d6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    

00800d73 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
  800d78:	8b 75 08             	mov    0x8(%ebp),%esi
  800d7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7e:	89 f3                	mov    %esi,%ebx
  800d80:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d83:	89 f2                	mov    %esi,%edx
  800d85:	eb 0f                	jmp    800d96 <strncpy+0x23>
		*dst++ = *src;
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	0f b6 01             	movzbl (%ecx),%eax
  800d8d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d90:	80 39 01             	cmpb   $0x1,(%ecx)
  800d93:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800d96:	39 da                	cmp    %ebx,%edx
  800d98:	75 ed                	jne    800d87 <strncpy+0x14>
	}
	return ret;
}
  800d9a:	89 f0                	mov    %esi,%eax
  800d9c:	5b                   	pop    %ebx
  800d9d:	5e                   	pop    %esi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	8b 75 08             	mov    0x8(%ebp),%esi
  800da8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dab:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800dae:	89 f0                	mov    %esi,%eax
  800db0:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800db4:	85 c9                	test   %ecx,%ecx
  800db6:	75 0b                	jne    800dc3 <strlcpy+0x23>
  800db8:	eb 17                	jmp    800dd1 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800dba:	83 c2 01             	add    $0x1,%edx
  800dbd:	83 c0 01             	add    $0x1,%eax
  800dc0:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800dc3:	39 d8                	cmp    %ebx,%eax
  800dc5:	74 07                	je     800dce <strlcpy+0x2e>
  800dc7:	0f b6 0a             	movzbl (%edx),%ecx
  800dca:	84 c9                	test   %cl,%cl
  800dcc:	75 ec                	jne    800dba <strlcpy+0x1a>
		*dst = '\0';
  800dce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dd1:	29 f0                	sub    %esi,%eax
}
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5d                   	pop    %ebp
  800dd6:	c3                   	ret    

00800dd7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800dd7:	55                   	push   %ebp
  800dd8:	89 e5                	mov    %esp,%ebp
  800dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800de0:	eb 06                	jmp    800de8 <strcmp+0x11>
		p++, q++;
  800de2:	83 c1 01             	add    $0x1,%ecx
  800de5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800de8:	0f b6 01             	movzbl (%ecx),%eax
  800deb:	84 c0                	test   %al,%al
  800ded:	74 04                	je     800df3 <strcmp+0x1c>
  800def:	3a 02                	cmp    (%edx),%al
  800df1:	74 ef                	je     800de2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800df3:	0f b6 c0             	movzbl %al,%eax
  800df6:	0f b6 12             	movzbl (%edx),%edx
  800df9:	29 d0                	sub    %edx,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	53                   	push   %ebx
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e07:	89 c3                	mov    %eax,%ebx
  800e09:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e0c:	eb 06                	jmp    800e14 <strncmp+0x17>
		n--, p++, q++;
  800e0e:	83 c0 01             	add    $0x1,%eax
  800e11:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e14:	39 d8                	cmp    %ebx,%eax
  800e16:	74 16                	je     800e2e <strncmp+0x31>
  800e18:	0f b6 08             	movzbl (%eax),%ecx
  800e1b:	84 c9                	test   %cl,%cl
  800e1d:	74 04                	je     800e23 <strncmp+0x26>
  800e1f:	3a 0a                	cmp    (%edx),%cl
  800e21:	74 eb                	je     800e0e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e23:	0f b6 00             	movzbl (%eax),%eax
  800e26:	0f b6 12             	movzbl (%edx),%edx
  800e29:	29 d0                	sub    %edx,%eax
}
  800e2b:	5b                   	pop    %ebx
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
		return 0;
  800e2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e33:	eb f6                	jmp    800e2b <strncmp+0x2e>

00800e35 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e3f:	0f b6 10             	movzbl (%eax),%edx
  800e42:	84 d2                	test   %dl,%dl
  800e44:	74 09                	je     800e4f <strchr+0x1a>
		if (*s == c)
  800e46:	38 ca                	cmp    %cl,%dl
  800e48:	74 0a                	je     800e54 <strchr+0x1f>
	for (; *s; s++)
  800e4a:	83 c0 01             	add    $0x1,%eax
  800e4d:	eb f0                	jmp    800e3f <strchr+0xa>
			return (char *) s;
	return 0;
  800e4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e60:	eb 03                	jmp    800e65 <strfind+0xf>
  800e62:	83 c0 01             	add    $0x1,%eax
  800e65:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e68:	38 ca                	cmp    %cl,%dl
  800e6a:	74 04                	je     800e70 <strfind+0x1a>
  800e6c:	84 d2                	test   %dl,%dl
  800e6e:	75 f2                	jne    800e62 <strfind+0xc>
			break;
	return (char *) s;
}
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    

00800e72 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e7e:	85 c9                	test   %ecx,%ecx
  800e80:	74 13                	je     800e95 <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e82:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e88:	75 05                	jne    800e8f <memset+0x1d>
  800e8a:	f6 c1 03             	test   $0x3,%cl
  800e8d:	74 0d                	je     800e9c <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	fc                   	cld    
  800e93:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e95:	89 f8                	mov    %edi,%eax
  800e97:	5b                   	pop    %ebx
  800e98:	5e                   	pop    %esi
  800e99:	5f                   	pop    %edi
  800e9a:	5d                   	pop    %ebp
  800e9b:	c3                   	ret    
		c &= 0xFF;
  800e9c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ea0:	89 d3                	mov    %edx,%ebx
  800ea2:	c1 e3 08             	shl    $0x8,%ebx
  800ea5:	89 d0                	mov    %edx,%eax
  800ea7:	c1 e0 18             	shl    $0x18,%eax
  800eaa:	89 d6                	mov    %edx,%esi
  800eac:	c1 e6 10             	shl    $0x10,%esi
  800eaf:	09 f0                	or     %esi,%eax
  800eb1:	09 c2                	or     %eax,%edx
  800eb3:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800eb5:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800eb8:	89 d0                	mov    %edx,%eax
  800eba:	fc                   	cld    
  800ebb:	f3 ab                	rep stos %eax,%es:(%edi)
  800ebd:	eb d6                	jmp    800e95 <memset+0x23>

00800ebf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800eca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ecd:	39 c6                	cmp    %eax,%esi
  800ecf:	73 35                	jae    800f06 <memmove+0x47>
  800ed1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ed4:	39 c2                	cmp    %eax,%edx
  800ed6:	76 2e                	jbe    800f06 <memmove+0x47>
		s += n;
		d += n;
  800ed8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edb:	89 d6                	mov    %edx,%esi
  800edd:	09 fe                	or     %edi,%esi
  800edf:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ee5:	74 0c                	je     800ef3 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ee7:	83 ef 01             	sub    $0x1,%edi
  800eea:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800eed:	fd                   	std    
  800eee:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ef0:	fc                   	cld    
  800ef1:	eb 21                	jmp    800f14 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ef3:	f6 c1 03             	test   $0x3,%cl
  800ef6:	75 ef                	jne    800ee7 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef8:	83 ef 04             	sub    $0x4,%edi
  800efb:	8d 72 fc             	lea    -0x4(%edx),%esi
  800efe:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f01:	fd                   	std    
  800f02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f04:	eb ea                	jmp    800ef0 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f06:	89 f2                	mov    %esi,%edx
  800f08:	09 c2                	or     %eax,%edx
  800f0a:	f6 c2 03             	test   $0x3,%dl
  800f0d:	74 09                	je     800f18 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f0f:	89 c7                	mov    %eax,%edi
  800f11:	fc                   	cld    
  800f12:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f18:	f6 c1 03             	test   $0x3,%cl
  800f1b:	75 f2                	jne    800f0f <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f1d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f20:	89 c7                	mov    %eax,%edi
  800f22:	fc                   	cld    
  800f23:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f25:	eb ed                	jmp    800f14 <memmove+0x55>

00800f27 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f2a:	ff 75 10             	pushl  0x10(%ebp)
  800f2d:	ff 75 0c             	pushl  0xc(%ebp)
  800f30:	ff 75 08             	pushl  0x8(%ebp)
  800f33:	e8 87 ff ff ff       	call   800ebf <memmove>
}
  800f38:	c9                   	leave  
  800f39:	c3                   	ret    

00800f3a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f45:	89 c6                	mov    %eax,%esi
  800f47:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f4a:	39 f0                	cmp    %esi,%eax
  800f4c:	74 1c                	je     800f6a <memcmp+0x30>
		if (*s1 != *s2)
  800f4e:	0f b6 08             	movzbl (%eax),%ecx
  800f51:	0f b6 1a             	movzbl (%edx),%ebx
  800f54:	38 d9                	cmp    %bl,%cl
  800f56:	75 08                	jne    800f60 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800f58:	83 c0 01             	add    $0x1,%eax
  800f5b:	83 c2 01             	add    $0x1,%edx
  800f5e:	eb ea                	jmp    800f4a <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800f60:	0f b6 c1             	movzbl %cl,%eax
  800f63:	0f b6 db             	movzbl %bl,%ebx
  800f66:	29 d8                	sub    %ebx,%eax
  800f68:	eb 05                	jmp    800f6f <memcmp+0x35>
	}

	return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f6f:	5b                   	pop    %ebx
  800f70:	5e                   	pop    %esi
  800f71:	5d                   	pop    %ebp
  800f72:	c3                   	ret    

00800f73 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f7c:	89 c2                	mov    %eax,%edx
  800f7e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f81:	39 d0                	cmp    %edx,%eax
  800f83:	73 09                	jae    800f8e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f85:	38 08                	cmp    %cl,(%eax)
  800f87:	74 05                	je     800f8e <memfind+0x1b>
	for (; s < ends; s++)
  800f89:	83 c0 01             	add    $0x1,%eax
  800f8c:	eb f3                	jmp    800f81 <memfind+0xe>
			break;
	return (void *) s;
}
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	57                   	push   %edi
  800f94:	56                   	push   %esi
  800f95:	53                   	push   %ebx
  800f96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f9c:	eb 03                	jmp    800fa1 <strtol+0x11>
		s++;
  800f9e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800fa1:	0f b6 01             	movzbl (%ecx),%eax
  800fa4:	3c 20                	cmp    $0x20,%al
  800fa6:	74 f6                	je     800f9e <strtol+0xe>
  800fa8:	3c 09                	cmp    $0x9,%al
  800faa:	74 f2                	je     800f9e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800fac:	3c 2b                	cmp    $0x2b,%al
  800fae:	74 2e                	je     800fde <strtol+0x4e>
	int neg = 0;
  800fb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800fb5:	3c 2d                	cmp    $0x2d,%al
  800fb7:	74 2f                	je     800fe8 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800fb9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800fbf:	75 05                	jne    800fc6 <strtol+0x36>
  800fc1:	80 39 30             	cmpb   $0x30,(%ecx)
  800fc4:	74 2c                	je     800ff2 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fc6:	85 db                	test   %ebx,%ebx
  800fc8:	75 0a                	jne    800fd4 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fca:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800fcf:	80 39 30             	cmpb   $0x30,(%ecx)
  800fd2:	74 28                	je     800ffc <strtol+0x6c>
		base = 10;
  800fd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800fdc:	eb 50                	jmp    80102e <strtol+0x9e>
		s++;
  800fde:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800fe1:	bf 00 00 00 00       	mov    $0x0,%edi
  800fe6:	eb d1                	jmp    800fb9 <strtol+0x29>
		s++, neg = 1;
  800fe8:	83 c1 01             	add    $0x1,%ecx
  800feb:	bf 01 00 00 00       	mov    $0x1,%edi
  800ff0:	eb c7                	jmp    800fb9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ff2:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ff6:	74 0e                	je     801006 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800ff8:	85 db                	test   %ebx,%ebx
  800ffa:	75 d8                	jne    800fd4 <strtol+0x44>
		s++, base = 8;
  800ffc:	83 c1 01             	add    $0x1,%ecx
  800fff:	bb 08 00 00 00       	mov    $0x8,%ebx
  801004:	eb ce                	jmp    800fd4 <strtol+0x44>
		s += 2, base = 16;
  801006:	83 c1 02             	add    $0x2,%ecx
  801009:	bb 10 00 00 00       	mov    $0x10,%ebx
  80100e:	eb c4                	jmp    800fd4 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  801010:	8d 72 9f             	lea    -0x61(%edx),%esi
  801013:	89 f3                	mov    %esi,%ebx
  801015:	80 fb 19             	cmp    $0x19,%bl
  801018:	77 29                	ja     801043 <strtol+0xb3>
			dig = *s - 'a' + 10;
  80101a:	0f be d2             	movsbl %dl,%edx
  80101d:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801020:	3b 55 10             	cmp    0x10(%ebp),%edx
  801023:	7d 30                	jge    801055 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801025:	83 c1 01             	add    $0x1,%ecx
  801028:	0f af 45 10          	imul   0x10(%ebp),%eax
  80102c:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  80102e:	0f b6 11             	movzbl (%ecx),%edx
  801031:	8d 72 d0             	lea    -0x30(%edx),%esi
  801034:	89 f3                	mov    %esi,%ebx
  801036:	80 fb 09             	cmp    $0x9,%bl
  801039:	77 d5                	ja     801010 <strtol+0x80>
			dig = *s - '0';
  80103b:	0f be d2             	movsbl %dl,%edx
  80103e:	83 ea 30             	sub    $0x30,%edx
  801041:	eb dd                	jmp    801020 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  801043:	8d 72 bf             	lea    -0x41(%edx),%esi
  801046:	89 f3                	mov    %esi,%ebx
  801048:	80 fb 19             	cmp    $0x19,%bl
  80104b:	77 08                	ja     801055 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80104d:	0f be d2             	movsbl %dl,%edx
  801050:	83 ea 37             	sub    $0x37,%edx
  801053:	eb cb                	jmp    801020 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  801055:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801059:	74 05                	je     801060 <strtol+0xd0>
		*endptr = (char *) s;
  80105b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80105e:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801060:	89 c2                	mov    %eax,%edx
  801062:	f7 da                	neg    %edx
  801064:	85 ff                	test   %edi,%edi
  801066:	0f 45 c2             	cmovne %edx,%eax
}
  801069:	5b                   	pop    %ebx
  80106a:	5e                   	pop    %esi
  80106b:	5f                   	pop    %edi
  80106c:	5d                   	pop    %ebp
  80106d:	c3                   	ret    

0080106e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
	asm volatile("int %1\n"
  801074:	b8 00 00 00 00       	mov    $0x0,%eax
  801079:	8b 55 08             	mov    0x8(%ebp),%edx
  80107c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80107f:	89 c3                	mov    %eax,%ebx
  801081:	89 c7                	mov    %eax,%edi
  801083:	89 c6                	mov    %eax,%esi
  801085:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801087:	5b                   	pop    %ebx
  801088:	5e                   	pop    %esi
  801089:	5f                   	pop    %edi
  80108a:	5d                   	pop    %ebp
  80108b:	c3                   	ret    

0080108c <sys_cgetc>:

int
sys_cgetc(void)
{
  80108c:	55                   	push   %ebp
  80108d:	89 e5                	mov    %esp,%ebp
  80108f:	57                   	push   %edi
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	asm volatile("int %1\n"
  801092:	ba 00 00 00 00       	mov    $0x0,%edx
  801097:	b8 01 00 00 00       	mov    $0x1,%eax
  80109c:	89 d1                	mov    %edx,%ecx
  80109e:	89 d3                	mov    %edx,%ebx
  8010a0:	89 d7                	mov    %edx,%edi
  8010a2:	89 d6                	mov    %edx,%esi
  8010a4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010a6:	5b                   	pop    %ebx
  8010a7:	5e                   	pop    %esi
  8010a8:	5f                   	pop    %edi
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	57                   	push   %edi
  8010af:	56                   	push   %esi
  8010b0:	53                   	push   %ebx
  8010b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8010b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bc:	b8 03 00 00 00       	mov    $0x3,%eax
  8010c1:	89 cb                	mov    %ecx,%ebx
  8010c3:	89 cf                	mov    %ecx,%edi
  8010c5:	89 ce                	mov    %ecx,%esi
  8010c7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8010c9:	85 c0                	test   %eax,%eax
  8010cb:	7f 08                	jg     8010d5 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d0:	5b                   	pop    %ebx
  8010d1:	5e                   	pop    %esi
  8010d2:	5f                   	pop    %edi
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010d5:	83 ec 0c             	sub    $0xc,%esp
  8010d8:	50                   	push   %eax
  8010d9:	6a 03                	push   $0x3
  8010db:	68 44 19 80 00       	push   $0x801944
  8010e0:	6a 23                	push   $0x23
  8010e2:	68 61 19 80 00       	push   $0x801961
  8010e7:	e8 4b f5 ff ff       	call   800637 <_panic>

008010ec <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8010f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8010f7:	b8 02 00 00 00       	mov    $0x2,%eax
  8010fc:	89 d1                	mov    %edx,%ecx
  8010fe:	89 d3                	mov    %edx,%ebx
  801100:	89 d7                	mov    %edx,%edi
  801102:	89 d6                	mov    %edx,%esi
  801104:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801106:	5b                   	pop    %ebx
  801107:	5e                   	pop    %esi
  801108:	5f                   	pop    %edi
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <sys_yield>:

void
sys_yield(void)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	57                   	push   %edi
  80110f:	56                   	push   %esi
  801110:	53                   	push   %ebx
	asm volatile("int %1\n"
  801111:	ba 00 00 00 00       	mov    $0x0,%edx
  801116:	b8 0a 00 00 00       	mov    $0xa,%eax
  80111b:	89 d1                	mov    %edx,%ecx
  80111d:	89 d3                	mov    %edx,%ebx
  80111f:	89 d7                	mov    %edx,%edi
  801121:	89 d6                	mov    %edx,%esi
  801123:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801133:	be 00 00 00 00       	mov    $0x0,%esi
  801138:	8b 55 08             	mov    0x8(%ebp),%edx
  80113b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113e:	b8 04 00 00 00       	mov    $0x4,%eax
  801143:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801146:	89 f7                	mov    %esi,%edi
  801148:	cd 30                	int    $0x30
	if(check && ret > 0)
  80114a:	85 c0                	test   %eax,%eax
  80114c:	7f 08                	jg     801156 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	50                   	push   %eax
  80115a:	6a 04                	push   $0x4
  80115c:	68 44 19 80 00       	push   $0x801944
  801161:	6a 23                	push   $0x23
  801163:	68 61 19 80 00       	push   $0x801961
  801168:	e8 ca f4 ff ff       	call   800637 <_panic>

0080116d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	57                   	push   %edi
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  801176:	8b 55 08             	mov    0x8(%ebp),%edx
  801179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117c:	b8 05 00 00 00       	mov    $0x5,%eax
  801181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801184:	8b 7d 14             	mov    0x14(%ebp),%edi
  801187:	8b 75 18             	mov    0x18(%ebp),%esi
  80118a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80118c:	85 c0                	test   %eax,%eax
  80118e:	7f 08                	jg     801198 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801193:	5b                   	pop    %ebx
  801194:	5e                   	pop    %esi
  801195:	5f                   	pop    %edi
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	50                   	push   %eax
  80119c:	6a 05                	push   $0x5
  80119e:	68 44 19 80 00       	push   $0x801944
  8011a3:	6a 23                	push   $0x23
  8011a5:	68 61 19 80 00       	push   $0x801961
  8011aa:	e8 88 f4 ff ff       	call   800637 <_panic>

008011af <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	57                   	push   %edi
  8011b3:	56                   	push   %esi
  8011b4:	53                   	push   %ebx
  8011b5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8011c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c3:	b8 06 00 00 00       	mov    $0x6,%eax
  8011c8:	89 df                	mov    %ebx,%edi
  8011ca:	89 de                	mov    %ebx,%esi
  8011cc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	7f 08                	jg     8011da <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8011da:	83 ec 0c             	sub    $0xc,%esp
  8011dd:	50                   	push   %eax
  8011de:	6a 06                	push   $0x6
  8011e0:	68 44 19 80 00       	push   $0x801944
  8011e5:	6a 23                	push   $0x23
  8011e7:	68 61 19 80 00       	push   $0x801961
  8011ec:	e8 46 f4 ff ff       	call   800637 <_panic>

008011f1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
  8011f4:	57                   	push   %edi
  8011f5:	56                   	push   %esi
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8011fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801205:	b8 08 00 00 00       	mov    $0x8,%eax
  80120a:	89 df                	mov    %ebx,%edi
  80120c:	89 de                	mov    %ebx,%esi
  80120e:	cd 30                	int    $0x30
	if(check && ret > 0)
  801210:	85 c0                	test   %eax,%eax
  801212:	7f 08                	jg     80121c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801217:	5b                   	pop    %ebx
  801218:	5e                   	pop    %esi
  801219:	5f                   	pop    %edi
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80121c:	83 ec 0c             	sub    $0xc,%esp
  80121f:	50                   	push   %eax
  801220:	6a 08                	push   $0x8
  801222:	68 44 19 80 00       	push   $0x801944
  801227:	6a 23                	push   $0x23
  801229:	68 61 19 80 00       	push   $0x801961
  80122e:	e8 04 f4 ff ff       	call   800637 <_panic>

00801233 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801233:	55                   	push   %ebp
  801234:	89 e5                	mov    %esp,%ebp
  801236:	57                   	push   %edi
  801237:	56                   	push   %esi
  801238:	53                   	push   %ebx
  801239:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80123c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801241:	8b 55 08             	mov    0x8(%ebp),%edx
  801244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801247:	b8 09 00 00 00       	mov    $0x9,%eax
  80124c:	89 df                	mov    %ebx,%edi
  80124e:	89 de                	mov    %ebx,%esi
  801250:	cd 30                	int    $0x30
	if(check && ret > 0)
  801252:	85 c0                	test   %eax,%eax
  801254:	7f 08                	jg     80125e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801259:	5b                   	pop    %ebx
  80125a:	5e                   	pop    %esi
  80125b:	5f                   	pop    %edi
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80125e:	83 ec 0c             	sub    $0xc,%esp
  801261:	50                   	push   %eax
  801262:	6a 09                	push   $0x9
  801264:	68 44 19 80 00       	push   $0x801944
  801269:	6a 23                	push   $0x23
  80126b:	68 61 19 80 00       	push   $0x801961
  801270:	e8 c2 f3 ff ff       	call   800637 <_panic>

00801275 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	57                   	push   %edi
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80127b:	8b 55 08             	mov    0x8(%ebp),%edx
  80127e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801281:	b8 0b 00 00 00       	mov    $0xb,%eax
  801286:	be 00 00 00 00       	mov    $0x0,%esi
  80128b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801291:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801293:	5b                   	pop    %ebx
  801294:	5e                   	pop    %esi
  801295:	5f                   	pop    %edi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8012a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8012a9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012ae:	89 cb                	mov    %ecx,%ebx
  8012b0:	89 cf                	mov    %ecx,%edi
  8012b2:	89 ce                	mov    %ecx,%esi
  8012b4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	7f 08                	jg     8012c2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c2:	83 ec 0c             	sub    $0xc,%esp
  8012c5:	50                   	push   %eax
  8012c6:	6a 0c                	push   $0xc
  8012c8:	68 44 19 80 00       	push   $0x801944
  8012cd:	6a 23                	push   $0x23
  8012cf:	68 61 19 80 00       	push   $0x801961
  8012d4:	e8 5e f3 ff ff       	call   800637 <_panic>

008012d9 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8012df:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  8012e6:	74 20                	je     801308 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8012eb:	a3 d0 20 80 00       	mov    %eax,0x8020d0
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	68 48 13 80 00       	push   $0x801348
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 34 ff ff ff       	call   801233 <sys_env_set_pgfault_upcall>
  8012ff:	83 c4 10             	add    $0x10,%esp
  801302:	85 c0                	test   %eax,%eax
  801304:	78 2e                	js     801334 <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  801306:	c9                   	leave  
  801307:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801308:	83 ec 04             	sub    $0x4,%esp
  80130b:	6a 07                	push   $0x7
  80130d:	68 00 f0 bf ee       	push   $0xeebff000
  801312:	6a 00                	push   $0x0
  801314:	e8 11 fe ff ff       	call   80112a <sys_page_alloc>
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	85 c0                	test   %eax,%eax
  80131e:	79 c8                	jns    8012e8 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	68 70 19 80 00       	push   $0x801970
  801328:	6a 21                	push   $0x21
  80132a:	68 d4 19 80 00       	push   $0x8019d4
  80132f:	e8 03 f3 ff ff       	call   800637 <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801334:	83 ec 04             	sub    $0x4,%esp
  801337:	68 9c 19 80 00       	push   $0x80199c
  80133c:	6a 27                	push   $0x27
  80133e:	68 d4 19 80 00       	push   $0x8019d4
  801343:	e8 ef f2 ff ff       	call   800637 <_panic>

00801348 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801348:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801349:	a1 d0 20 80 00       	mov    0x8020d0,%eax
	call *%eax
  80134e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801350:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801353:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801357:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80135a:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  80135e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801362:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801364:	83 c4 08             	add    $0x8,%esp
	popal
  801367:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  801368:	83 c4 04             	add    $0x4,%esp
	popfl
  80136b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80136c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80136d:	c3                   	ret    
  80136e:	66 90                	xchg   %ax,%ax

00801370 <__udivdi3>:
  801370:	55                   	push   %ebp
  801371:	57                   	push   %edi
  801372:	56                   	push   %esi
  801373:	53                   	push   %ebx
  801374:	83 ec 1c             	sub    $0x1c,%esp
  801377:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80137b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  80137f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801383:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801387:	85 d2                	test   %edx,%edx
  801389:	75 35                	jne    8013c0 <__udivdi3+0x50>
  80138b:	39 f3                	cmp    %esi,%ebx
  80138d:	0f 87 bd 00 00 00    	ja     801450 <__udivdi3+0xe0>
  801393:	85 db                	test   %ebx,%ebx
  801395:	89 d9                	mov    %ebx,%ecx
  801397:	75 0b                	jne    8013a4 <__udivdi3+0x34>
  801399:	b8 01 00 00 00       	mov    $0x1,%eax
  80139e:	31 d2                	xor    %edx,%edx
  8013a0:	f7 f3                	div    %ebx
  8013a2:	89 c1                	mov    %eax,%ecx
  8013a4:	31 d2                	xor    %edx,%edx
  8013a6:	89 f0                	mov    %esi,%eax
  8013a8:	f7 f1                	div    %ecx
  8013aa:	89 c6                	mov    %eax,%esi
  8013ac:	89 e8                	mov    %ebp,%eax
  8013ae:	89 f7                	mov    %esi,%edi
  8013b0:	f7 f1                	div    %ecx
  8013b2:	89 fa                	mov    %edi,%edx
  8013b4:	83 c4 1c             	add    $0x1c,%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    
  8013bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c0:	39 f2                	cmp    %esi,%edx
  8013c2:	77 7c                	ja     801440 <__udivdi3+0xd0>
  8013c4:	0f bd fa             	bsr    %edx,%edi
  8013c7:	83 f7 1f             	xor    $0x1f,%edi
  8013ca:	0f 84 98 00 00 00    	je     801468 <__udivdi3+0xf8>
  8013d0:	89 f9                	mov    %edi,%ecx
  8013d2:	b8 20 00 00 00       	mov    $0x20,%eax
  8013d7:	29 f8                	sub    %edi,%eax
  8013d9:	d3 e2                	shl    %cl,%edx
  8013db:	89 54 24 08          	mov    %edx,0x8(%esp)
  8013df:	89 c1                	mov    %eax,%ecx
  8013e1:	89 da                	mov    %ebx,%edx
  8013e3:	d3 ea                	shr    %cl,%edx
  8013e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8013e9:	09 d1                	or     %edx,%ecx
  8013eb:	89 f2                	mov    %esi,%edx
  8013ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013f1:	89 f9                	mov    %edi,%ecx
  8013f3:	d3 e3                	shl    %cl,%ebx
  8013f5:	89 c1                	mov    %eax,%ecx
  8013f7:	d3 ea                	shr    %cl,%edx
  8013f9:	89 f9                	mov    %edi,%ecx
  8013fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013ff:	d3 e6                	shl    %cl,%esi
  801401:	89 eb                	mov    %ebp,%ebx
  801403:	89 c1                	mov    %eax,%ecx
  801405:	d3 eb                	shr    %cl,%ebx
  801407:	09 de                	or     %ebx,%esi
  801409:	89 f0                	mov    %esi,%eax
  80140b:	f7 74 24 08          	divl   0x8(%esp)
  80140f:	89 d6                	mov    %edx,%esi
  801411:	89 c3                	mov    %eax,%ebx
  801413:	f7 64 24 0c          	mull   0xc(%esp)
  801417:	39 d6                	cmp    %edx,%esi
  801419:	72 0c                	jb     801427 <__udivdi3+0xb7>
  80141b:	89 f9                	mov    %edi,%ecx
  80141d:	d3 e5                	shl    %cl,%ebp
  80141f:	39 c5                	cmp    %eax,%ebp
  801421:	73 5d                	jae    801480 <__udivdi3+0x110>
  801423:	39 d6                	cmp    %edx,%esi
  801425:	75 59                	jne    801480 <__udivdi3+0x110>
  801427:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80142a:	31 ff                	xor    %edi,%edi
  80142c:	89 fa                	mov    %edi,%edx
  80142e:	83 c4 1c             	add    $0x1c,%esp
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5f                   	pop    %edi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    
  801436:	8d 76 00             	lea    0x0(%esi),%esi
  801439:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801440:	31 ff                	xor    %edi,%edi
  801442:	31 c0                	xor    %eax,%eax
  801444:	89 fa                	mov    %edi,%edx
  801446:	83 c4 1c             	add    $0x1c,%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5f                   	pop    %edi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    
  80144e:	66 90                	xchg   %ax,%ax
  801450:	31 ff                	xor    %edi,%edi
  801452:	89 e8                	mov    %ebp,%eax
  801454:	89 f2                	mov    %esi,%edx
  801456:	f7 f3                	div    %ebx
  801458:	89 fa                	mov    %edi,%edx
  80145a:	83 c4 1c             	add    $0x1c,%esp
  80145d:	5b                   	pop    %ebx
  80145e:	5e                   	pop    %esi
  80145f:	5f                   	pop    %edi
  801460:	5d                   	pop    %ebp
  801461:	c3                   	ret    
  801462:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801468:	39 f2                	cmp    %esi,%edx
  80146a:	72 06                	jb     801472 <__udivdi3+0x102>
  80146c:	31 c0                	xor    %eax,%eax
  80146e:	39 eb                	cmp    %ebp,%ebx
  801470:	77 d2                	ja     801444 <__udivdi3+0xd4>
  801472:	b8 01 00 00 00       	mov    $0x1,%eax
  801477:	eb cb                	jmp    801444 <__udivdi3+0xd4>
  801479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801480:	89 d8                	mov    %ebx,%eax
  801482:	31 ff                	xor    %edi,%edi
  801484:	eb be                	jmp    801444 <__udivdi3+0xd4>
  801486:	66 90                	xchg   %ax,%ax
  801488:	66 90                	xchg   %ax,%ax
  80148a:	66 90                	xchg   %ax,%ax
  80148c:	66 90                	xchg   %ax,%ax
  80148e:	66 90                	xchg   %ax,%ax

00801490 <__umoddi3>:
  801490:	55                   	push   %ebp
  801491:	57                   	push   %edi
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
  801494:	83 ec 1c             	sub    $0x1c,%esp
  801497:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80149b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80149f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8014a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8014a7:	85 ed                	test   %ebp,%ebp
  8014a9:	89 f0                	mov    %esi,%eax
  8014ab:	89 da                	mov    %ebx,%edx
  8014ad:	75 19                	jne    8014c8 <__umoddi3+0x38>
  8014af:	39 df                	cmp    %ebx,%edi
  8014b1:	0f 86 b1 00 00 00    	jbe    801568 <__umoddi3+0xd8>
  8014b7:	f7 f7                	div    %edi
  8014b9:	89 d0                	mov    %edx,%eax
  8014bb:	31 d2                	xor    %edx,%edx
  8014bd:	83 c4 1c             	add    $0x1c,%esp
  8014c0:	5b                   	pop    %ebx
  8014c1:	5e                   	pop    %esi
  8014c2:	5f                   	pop    %edi
  8014c3:	5d                   	pop    %ebp
  8014c4:	c3                   	ret    
  8014c5:	8d 76 00             	lea    0x0(%esi),%esi
  8014c8:	39 dd                	cmp    %ebx,%ebp
  8014ca:	77 f1                	ja     8014bd <__umoddi3+0x2d>
  8014cc:	0f bd cd             	bsr    %ebp,%ecx
  8014cf:	83 f1 1f             	xor    $0x1f,%ecx
  8014d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014d6:	0f 84 b4 00 00 00    	je     801590 <__umoddi3+0x100>
  8014dc:	b8 20 00 00 00       	mov    $0x20,%eax
  8014e1:	89 c2                	mov    %eax,%edx
  8014e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014e7:	29 c2                	sub    %eax,%edx
  8014e9:	89 c1                	mov    %eax,%ecx
  8014eb:	89 f8                	mov    %edi,%eax
  8014ed:	d3 e5                	shl    %cl,%ebp
  8014ef:	89 d1                	mov    %edx,%ecx
  8014f1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8014f5:	d3 e8                	shr    %cl,%eax
  8014f7:	09 c5                	or     %eax,%ebp
  8014f9:	8b 44 24 04          	mov    0x4(%esp),%eax
  8014fd:	89 c1                	mov    %eax,%ecx
  8014ff:	d3 e7                	shl    %cl,%edi
  801501:	89 d1                	mov    %edx,%ecx
  801503:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801507:	89 df                	mov    %ebx,%edi
  801509:	d3 ef                	shr    %cl,%edi
  80150b:	89 c1                	mov    %eax,%ecx
  80150d:	89 f0                	mov    %esi,%eax
  80150f:	d3 e3                	shl    %cl,%ebx
  801511:	89 d1                	mov    %edx,%ecx
  801513:	89 fa                	mov    %edi,%edx
  801515:	d3 e8                	shr    %cl,%eax
  801517:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80151c:	09 d8                	or     %ebx,%eax
  80151e:	f7 f5                	div    %ebp
  801520:	d3 e6                	shl    %cl,%esi
  801522:	89 d1                	mov    %edx,%ecx
  801524:	f7 64 24 08          	mull   0x8(%esp)
  801528:	39 d1                	cmp    %edx,%ecx
  80152a:	89 c3                	mov    %eax,%ebx
  80152c:	89 d7                	mov    %edx,%edi
  80152e:	72 06                	jb     801536 <__umoddi3+0xa6>
  801530:	75 0e                	jne    801540 <__umoddi3+0xb0>
  801532:	39 c6                	cmp    %eax,%esi
  801534:	73 0a                	jae    801540 <__umoddi3+0xb0>
  801536:	2b 44 24 08          	sub    0x8(%esp),%eax
  80153a:	19 ea                	sbb    %ebp,%edx
  80153c:	89 d7                	mov    %edx,%edi
  80153e:	89 c3                	mov    %eax,%ebx
  801540:	89 ca                	mov    %ecx,%edx
  801542:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801547:	29 de                	sub    %ebx,%esi
  801549:	19 fa                	sbb    %edi,%edx
  80154b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  80154f:	89 d0                	mov    %edx,%eax
  801551:	d3 e0                	shl    %cl,%eax
  801553:	89 d9                	mov    %ebx,%ecx
  801555:	d3 ee                	shr    %cl,%esi
  801557:	d3 ea                	shr    %cl,%edx
  801559:	09 f0                	or     %esi,%eax
  80155b:	83 c4 1c             	add    $0x1c,%esp
  80155e:	5b                   	pop    %ebx
  80155f:	5e                   	pop    %esi
  801560:	5f                   	pop    %edi
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
  801563:	90                   	nop
  801564:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801568:	85 ff                	test   %edi,%edi
  80156a:	89 f9                	mov    %edi,%ecx
  80156c:	75 0b                	jne    801579 <__umoddi3+0xe9>
  80156e:	b8 01 00 00 00       	mov    $0x1,%eax
  801573:	31 d2                	xor    %edx,%edx
  801575:	f7 f7                	div    %edi
  801577:	89 c1                	mov    %eax,%ecx
  801579:	89 d8                	mov    %ebx,%eax
  80157b:	31 d2                	xor    %edx,%edx
  80157d:	f7 f1                	div    %ecx
  80157f:	89 f0                	mov    %esi,%eax
  801581:	f7 f1                	div    %ecx
  801583:	e9 31 ff ff ff       	jmp    8014b9 <__umoddi3+0x29>
  801588:	90                   	nop
  801589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801590:	39 dd                	cmp    %ebx,%ebp
  801592:	72 08                	jb     80159c <__umoddi3+0x10c>
  801594:	39 f7                	cmp    %esi,%edi
  801596:	0f 87 21 ff ff ff    	ja     8014bd <__umoddi3+0x2d>
  80159c:	89 da                	mov    %ebx,%edx
  80159e:	89 f0                	mov    %esi,%eax
  8015a0:	29 f8                	sub    %edi,%eax
  8015a2:	19 ea                	sbb    %ebp,%edx
  8015a4:	e9 14 ff ff ff       	jmp    8014bd <__umoddi3+0x2d>
