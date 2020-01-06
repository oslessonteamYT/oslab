
obj/user/idle：     文件格式 elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 a0 	movl   $0x800fa0,0x802000
  800040:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 f7 00 00 00       	call   80013f <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7f 08                	jg     800109 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 af 0f 80 00       	push   $0x800faf
  800114:	6a 23                	push   $0x23
  800116:	68 cc 0f 80 00       	push   $0x800fcc
  80011b:	e8 ed 01 00 00       	call   80030d <_panic>

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800172:	b8 04 00 00 00       	mov    $0x4,%eax
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7f 08                	jg     80018a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 af 0f 80 00       	push   $0x800faf
  800195:	6a 23                	push   $0x23
  800197:	68 cc 0f 80 00       	push   $0x800fcc
  80019c:	e8 6c 01 00 00       	call   80030d <_panic>

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7f 08                	jg     8001cc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 af 0f 80 00       	push   $0x800faf
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 cc 0f 80 00       	push   $0x800fcc
  8001de:	e8 2a 01 00 00       	call   80030d <_panic>

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7f 08                	jg     80020e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 af 0f 80 00       	push   $0x800faf
  800219:	6a 23                	push   $0x23
  80021b:	68 cc 0f 80 00       	push   $0x800fcc
  800220:	e8 e8 00 00 00       	call   80030d <_panic>

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	b8 08 00 00 00       	mov    $0x8,%eax
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7f 08                	jg     800250 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 af 0f 80 00       	push   $0x800faf
  80025b:	6a 23                	push   $0x23
  80025d:	68 cc 0f 80 00       	push   $0x800fcc
  800262:	e8 a6 00 00 00       	call   80030d <_panic>

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	b8 09 00 00 00       	mov    $0x9,%eax
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7f 08                	jg     800292 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 af 0f 80 00       	push   $0x800faf
  80029d:	6a 23                	push   $0x23
  80029f:	68 cc 0f 80 00       	push   $0x800fcc
  8002a4:	e8 64 00 00 00       	call   80030d <_panic>

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ba:	be 00 00 00 00       	mov    $0x0,%esi
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7f 08                	jg     8002f6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f6:	83 ec 0c             	sub    $0xc,%esp
  8002f9:	50                   	push   %eax
  8002fa:	6a 0c                	push   $0xc
  8002fc:	68 af 0f 80 00       	push   $0x800faf
  800301:	6a 23                	push   $0x23
  800303:	68 cc 0f 80 00       	push   $0x800fcc
  800308:	e8 00 00 00 00       	call   80030d <_panic>

0080030d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800315:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031b:	e8 00 fe ff ff       	call   800120 <sys_getenvid>
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	ff 75 0c             	pushl  0xc(%ebp)
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	56                   	push   %esi
  80032a:	50                   	push   %eax
  80032b:	68 dc 0f 80 00       	push   $0x800fdc
  800330:	e8 b3 00 00 00       	call   8003e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	53                   	push   %ebx
  800339:	ff 75 10             	pushl  0x10(%ebp)
  80033c:	e8 56 00 00 00       	call   800397 <vcprintf>
	cprintf("\n");
  800341:	c7 04 24 00 10 80 00 	movl   $0x801000,(%esp)
  800348:	e8 9b 00 00 00       	call   8003e8 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800350:	cc                   	int3   
  800351:	eb fd                	jmp    800350 <_panic+0x43>

00800353 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	53                   	push   %ebx
  800357:	83 ec 04             	sub    $0x4,%esp
  80035a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035d:	8b 13                	mov    (%ebx),%edx
  80035f:	8d 42 01             	lea    0x1(%edx),%eax
  800362:	89 03                	mov    %eax,(%ebx)
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800370:	74 09                	je     80037b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800372:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800376:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800379:	c9                   	leave  
  80037a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80037b:	83 ec 08             	sub    $0x8,%esp
  80037e:	68 ff 00 00 00       	push   $0xff
  800383:	8d 43 08             	lea    0x8(%ebx),%eax
  800386:	50                   	push   %eax
  800387:	e8 16 fd ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  80038c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	eb db                	jmp    800372 <putch+0x1f>

00800397 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a7:	00 00 00 
	b.cnt = 0;
  8003aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b4:	ff 75 0c             	pushl  0xc(%ebp)
  8003b7:	ff 75 08             	pushl  0x8(%ebp)
  8003ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c0:	50                   	push   %eax
  8003c1:	68 53 03 80 00       	push   $0x800353
  8003c6:	e8 1a 01 00 00       	call   8004e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cb:	83 c4 08             	add    $0x8,%esp
  8003ce:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003da:	50                   	push   %eax
  8003db:	e8 c2 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8003e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f1:	50                   	push   %eax
  8003f2:	ff 75 08             	pushl  0x8(%ebp)
  8003f5:	e8 9d ff ff ff       	call   800397 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
  800402:	83 ec 1c             	sub    $0x1c,%esp
  800405:	89 c7                	mov    %eax,%edi
  800407:	89 d6                	mov    %edx,%esi
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800412:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800415:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800418:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800420:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800423:	39 d3                	cmp    %edx,%ebx
  800425:	72 05                	jb     80042c <printnum+0x30>
  800427:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042a:	77 7a                	ja     8004a6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042c:	83 ec 0c             	sub    $0xc,%esp
  80042f:	ff 75 18             	pushl  0x18(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800438:	53                   	push   %ebx
  800439:	ff 75 10             	pushl  0x10(%ebp)
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800442:	ff 75 e0             	pushl  -0x20(%ebp)
  800445:	ff 75 dc             	pushl  -0x24(%ebp)
  800448:	ff 75 d8             	pushl  -0x28(%ebp)
  80044b:	e8 00 09 00 00       	call   800d50 <__udivdi3>
  800450:	83 c4 18             	add    $0x18,%esp
  800453:	52                   	push   %edx
  800454:	50                   	push   %eax
  800455:	89 f2                	mov    %esi,%edx
  800457:	89 f8                	mov    %edi,%eax
  800459:	e8 9e ff ff ff       	call   8003fc <printnum>
  80045e:	83 c4 20             	add    $0x20,%esp
  800461:	eb 13                	jmp    800476 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	56                   	push   %esi
  800467:	ff 75 18             	pushl  0x18(%ebp)
  80046a:	ff d7                	call   *%edi
  80046c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80046f:	83 eb 01             	sub    $0x1,%ebx
  800472:	85 db                	test   %ebx,%ebx
  800474:	7f ed                	jg     800463 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	56                   	push   %esi
  80047a:	83 ec 04             	sub    $0x4,%esp
  80047d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 75 dc             	pushl  -0x24(%ebp)
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	e8 e2 09 00 00       	call   800e70 <__umoddi3>
  80048e:	83 c4 14             	add    $0x14,%esp
  800491:	0f be 80 02 10 80 00 	movsbl 0x801002(%eax),%eax
  800498:	50                   	push   %eax
  800499:	ff d7                	call   *%edi
}
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a1:	5b                   	pop    %ebx
  8004a2:	5e                   	pop    %esi
  8004a3:	5f                   	pop    %edi
  8004a4:	5d                   	pop    %ebp
  8004a5:	c3                   	ret    
  8004a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004a9:	eb c4                	jmp    80046f <printnum+0x73>

008004ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ab:	55                   	push   %ebp
  8004ac:	89 e5                	mov    %esp,%ebp
  8004ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ba:	73 0a                	jae    8004c6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004bf:	89 08                	mov    %ecx,(%eax)
  8004c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c4:	88 02                	mov    %al,(%edx)
}
  8004c6:	5d                   	pop    %ebp
  8004c7:	c3                   	ret    

008004c8 <printfmt>:
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d1:	50                   	push   %eax
  8004d2:	ff 75 10             	pushl  0x10(%ebp)
  8004d5:	ff 75 0c             	pushl  0xc(%ebp)
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 05 00 00 00       	call   8004e5 <vprintfmt>
}
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	c9                   	leave  
  8004e4:	c3                   	ret    

008004e5 <vprintfmt>:
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	57                   	push   %edi
  8004e9:	56                   	push   %esi
  8004ea:	53                   	push   %ebx
  8004eb:	83 ec 2c             	sub    $0x2c,%esp
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f7:	e9 c1 03 00 00       	jmp    8008bd <vprintfmt+0x3d8>
		padc = ' ';
  8004fc:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800500:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800507:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80050e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800515:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80051a:	8d 47 01             	lea    0x1(%edi),%eax
  80051d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800520:	0f b6 17             	movzbl (%edi),%edx
  800523:	8d 42 dd             	lea    -0x23(%edx),%eax
  800526:	3c 55                	cmp    $0x55,%al
  800528:	0f 87 12 04 00 00    	ja     800940 <vprintfmt+0x45b>
  80052e:	0f b6 c0             	movzbl %al,%eax
  800531:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  800538:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80053b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80053f:	eb d9                	jmp    80051a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800544:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800548:	eb d0                	jmp    80051a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	0f b6 d2             	movzbl %dl,%edx
  80054d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800550:	b8 00 00 00 00       	mov    $0x0,%eax
  800555:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800558:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80055f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800562:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800565:	83 f9 09             	cmp    $0x9,%ecx
  800568:	77 55                	ja     8005bf <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80056a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80056d:	eb e9                	jmp    800558 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80056f:	8b 45 14             	mov    0x14(%ebp),%eax
  800572:	8b 00                	mov    (%eax),%eax
  800574:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800583:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800587:	79 91                	jns    80051a <vprintfmt+0x35>
				width = precision, precision = -1;
  800589:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80058c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80058f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800596:	eb 82                	jmp    80051a <vprintfmt+0x35>
  800598:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059b:	85 c0                	test   %eax,%eax
  80059d:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a2:	0f 49 d0             	cmovns %eax,%edx
  8005a5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ab:	e9 6a ff ff ff       	jmp    80051a <vprintfmt+0x35>
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005b3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ba:	e9 5b ff ff ff       	jmp    80051a <vprintfmt+0x35>
  8005bf:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c5:	eb bc                	jmp    800583 <vprintfmt+0x9e>
			lflag++;
  8005c7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005cd:	e9 48 ff ff ff       	jmp    80051a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 78 04             	lea    0x4(%eax),%edi
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	ff 30                	pushl  (%eax)
  8005de:	ff d6                	call   *%esi
			break;
  8005e0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005e3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005e6:	e9 cf 02 00 00       	jmp    8008ba <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 78 04             	lea    0x4(%eax),%edi
  8005f1:	8b 00                	mov    (%eax),%eax
  8005f3:	99                   	cltd   
  8005f4:	31 d0                	xor    %edx,%eax
  8005f6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005f8:	83 f8 08             	cmp    $0x8,%eax
  8005fb:	7f 23                	jg     800620 <vprintfmt+0x13b>
  8005fd:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800604:	85 d2                	test   %edx,%edx
  800606:	74 18                	je     800620 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800608:	52                   	push   %edx
  800609:	68 23 10 80 00       	push   $0x801023
  80060e:	53                   	push   %ebx
  80060f:	56                   	push   %esi
  800610:	e8 b3 fe ff ff       	call   8004c8 <printfmt>
  800615:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800618:	89 7d 14             	mov    %edi,0x14(%ebp)
  80061b:	e9 9a 02 00 00       	jmp    8008ba <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800620:	50                   	push   %eax
  800621:	68 1a 10 80 00       	push   $0x80101a
  800626:	53                   	push   %ebx
  800627:	56                   	push   %esi
  800628:	e8 9b fe ff ff       	call   8004c8 <printfmt>
  80062d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800630:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800633:	e9 82 02 00 00       	jmp    8008ba <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	83 c0 04             	add    $0x4,%eax
  80063e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800646:	85 ff                	test   %edi,%edi
  800648:	b8 13 10 80 00       	mov    $0x801013,%eax
  80064d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800650:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800654:	0f 8e bd 00 00 00    	jle    800717 <vprintfmt+0x232>
  80065a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80065e:	75 0e                	jne    80066e <vprintfmt+0x189>
  800660:	89 75 08             	mov    %esi,0x8(%ebp)
  800663:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800666:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800669:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066c:	eb 6d                	jmp    8006db <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	ff 75 d0             	pushl  -0x30(%ebp)
  800674:	57                   	push   %edi
  800675:	e8 6e 03 00 00       	call   8009e8 <strnlen>
  80067a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80067d:	29 c1                	sub    %eax,%ecx
  80067f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800682:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800685:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800689:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80068c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80068f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800691:	eb 0f                	jmp    8006a2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	ff 75 e0             	pushl  -0x20(%ebp)
  80069a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80069c:	83 ef 01             	sub    $0x1,%edi
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	85 ff                	test   %edi,%edi
  8006a4:	7f ed                	jg     800693 <vprintfmt+0x1ae>
  8006a6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006a9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ac:	85 c9                	test   %ecx,%ecx
  8006ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b3:	0f 49 c1             	cmovns %ecx,%eax
  8006b6:	29 c1                	sub    %eax,%ecx
  8006b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c1:	89 cb                	mov    %ecx,%ebx
  8006c3:	eb 16                	jmp    8006db <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006c9:	75 31                	jne    8006fc <vprintfmt+0x217>
					putch(ch, putdat);
  8006cb:	83 ec 08             	sub    $0x8,%esp
  8006ce:	ff 75 0c             	pushl  0xc(%ebp)
  8006d1:	50                   	push   %eax
  8006d2:	ff 55 08             	call   *0x8(%ebp)
  8006d5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d8:	83 eb 01             	sub    $0x1,%ebx
  8006db:	83 c7 01             	add    $0x1,%edi
  8006de:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006e2:	0f be c2             	movsbl %dl,%eax
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 59                	je     800742 <vprintfmt+0x25d>
  8006e9:	85 f6                	test   %esi,%esi
  8006eb:	78 d8                	js     8006c5 <vprintfmt+0x1e0>
  8006ed:	83 ee 01             	sub    $0x1,%esi
  8006f0:	79 d3                	jns    8006c5 <vprintfmt+0x1e0>
  8006f2:	89 df                	mov    %ebx,%edi
  8006f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fa:	eb 37                	jmp    800733 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006fc:	0f be d2             	movsbl %dl,%edx
  8006ff:	83 ea 20             	sub    $0x20,%edx
  800702:	83 fa 5e             	cmp    $0x5e,%edx
  800705:	76 c4                	jbe    8006cb <vprintfmt+0x1e6>
					putch('?', putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	6a 3f                	push   $0x3f
  80070f:	ff 55 08             	call   *0x8(%ebp)
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	eb c1                	jmp    8006d8 <vprintfmt+0x1f3>
  800717:	89 75 08             	mov    %esi,0x8(%ebp)
  80071a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800720:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800723:	eb b6                	jmp    8006db <vprintfmt+0x1f6>
				putch(' ', putdat);
  800725:	83 ec 08             	sub    $0x8,%esp
  800728:	53                   	push   %ebx
  800729:	6a 20                	push   $0x20
  80072b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80072d:	83 ef 01             	sub    $0x1,%edi
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	85 ff                	test   %edi,%edi
  800735:	7f ee                	jg     800725 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800737:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80073a:	89 45 14             	mov    %eax,0x14(%ebp)
  80073d:	e9 78 01 00 00       	jmp    8008ba <vprintfmt+0x3d5>
  800742:	89 df                	mov    %ebx,%edi
  800744:	8b 75 08             	mov    0x8(%ebp),%esi
  800747:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074a:	eb e7                	jmp    800733 <vprintfmt+0x24e>
	if (lflag >= 2)
  80074c:	83 f9 01             	cmp    $0x1,%ecx
  80074f:	7e 3f                	jle    800790 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 50 04             	mov    0x4(%eax),%edx
  800757:	8b 00                	mov    (%eax),%eax
  800759:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 40 08             	lea    0x8(%eax),%eax
  800765:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800768:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80076c:	79 5c                	jns    8007ca <vprintfmt+0x2e5>
				putch('-', putdat);
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 2d                	push   $0x2d
  800774:	ff d6                	call   *%esi
				num = -(long long) num;
  800776:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800779:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80077c:	f7 da                	neg    %edx
  80077e:	83 d1 00             	adc    $0x0,%ecx
  800781:	f7 d9                	neg    %ecx
  800783:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800786:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078b:	e9 10 01 00 00       	jmp    8008a0 <vprintfmt+0x3bb>
	else if (lflag)
  800790:	85 c9                	test   %ecx,%ecx
  800792:	75 1b                	jne    8007af <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8b 00                	mov    (%eax),%eax
  800799:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079c:	89 c1                	mov    %eax,%ecx
  80079e:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a7:	8d 40 04             	lea    0x4(%eax),%eax
  8007aa:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ad:	eb b9                	jmp    800768 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8b 00                	mov    (%eax),%eax
  8007b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b7:	89 c1                	mov    %eax,%ecx
  8007b9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007bc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c2:	8d 40 04             	lea    0x4(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007c8:	eb 9e                	jmp    800768 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d5:	e9 c6 00 00 00       	jmp    8008a0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007da:	83 f9 01             	cmp    $0x1,%ecx
  8007dd:	7e 18                	jle    8007f7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e7:	8d 40 08             	lea    0x8(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f2:	e9 a9 00 00 00       	jmp    8008a0 <vprintfmt+0x3bb>
	else if (lflag)
  8007f7:	85 c9                	test   %ecx,%ecx
  8007f9:	75 1a                	jne    800815 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8007fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fe:	8b 10                	mov    (%eax),%edx
  800800:	b9 00 00 00 00       	mov    $0x0,%ecx
  800805:	8d 40 04             	lea    0x4(%eax),%eax
  800808:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800810:	e9 8b 00 00 00       	jmp    8008a0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800815:	8b 45 14             	mov    0x14(%ebp),%eax
  800818:	8b 10                	mov    (%eax),%edx
  80081a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081f:	8d 40 04             	lea    0x4(%eax),%eax
  800822:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800825:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082a:	eb 74                	jmp    8008a0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80082c:	83 f9 01             	cmp    $0x1,%ecx
  80082f:	7e 15                	jle    800846 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800831:	8b 45 14             	mov    0x14(%ebp),%eax
  800834:	8b 10                	mov    (%eax),%edx
  800836:	8b 48 04             	mov    0x4(%eax),%ecx
  800839:	8d 40 08             	lea    0x8(%eax),%eax
  80083c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80083f:	b8 08 00 00 00       	mov    $0x8,%eax
  800844:	eb 5a                	jmp    8008a0 <vprintfmt+0x3bb>
	else if (lflag)
  800846:	85 c9                	test   %ecx,%ecx
  800848:	75 17                	jne    800861 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80084a:	8b 45 14             	mov    0x14(%ebp),%eax
  80084d:	8b 10                	mov    (%eax),%edx
  80084f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800854:	8d 40 04             	lea    0x4(%eax),%eax
  800857:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80085a:	b8 08 00 00 00       	mov    $0x8,%eax
  80085f:	eb 3f                	jmp    8008a0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086b:	8d 40 04             	lea    0x4(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800871:	b8 08 00 00 00       	mov    $0x8,%eax
  800876:	eb 28                	jmp    8008a0 <vprintfmt+0x3bb>
			putch('0', putdat);
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	53                   	push   %ebx
  80087c:	6a 30                	push   $0x30
  80087e:	ff d6                	call   *%esi
			putch('x', putdat);
  800880:	83 c4 08             	add    $0x8,%esp
  800883:	53                   	push   %ebx
  800884:	6a 78                	push   $0x78
  800886:	ff d6                	call   *%esi
			num = (unsigned long long)
  800888:	8b 45 14             	mov    0x14(%ebp),%eax
  80088b:	8b 10                	mov    (%eax),%edx
  80088d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800892:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800895:	8d 40 04             	lea    0x4(%eax),%eax
  800898:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008a0:	83 ec 0c             	sub    $0xc,%esp
  8008a3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008a7:	57                   	push   %edi
  8008a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008ab:	50                   	push   %eax
  8008ac:	51                   	push   %ecx
  8008ad:	52                   	push   %edx
  8008ae:	89 da                	mov    %ebx,%edx
  8008b0:	89 f0                	mov    %esi,%eax
  8008b2:	e8 45 fb ff ff       	call   8003fc <printnum>
			break;
  8008b7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008bd:	83 c7 01             	add    $0x1,%edi
  8008c0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c4:	83 f8 25             	cmp    $0x25,%eax
  8008c7:	0f 84 2f fc ff ff    	je     8004fc <vprintfmt+0x17>
			if (ch == '\0')
  8008cd:	85 c0                	test   %eax,%eax
  8008cf:	0f 84 8b 00 00 00    	je     800960 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	53                   	push   %ebx
  8008d9:	50                   	push   %eax
  8008da:	ff d6                	call   *%esi
  8008dc:	83 c4 10             	add    $0x10,%esp
  8008df:	eb dc                	jmp    8008bd <vprintfmt+0x3d8>
	if (lflag >= 2)
  8008e1:	83 f9 01             	cmp    $0x1,%ecx
  8008e4:	7e 15                	jle    8008fb <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8008e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e9:	8b 10                	mov    (%eax),%edx
  8008eb:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ee:	8d 40 08             	lea    0x8(%eax),%eax
  8008f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f4:	b8 10 00 00 00       	mov    $0x10,%eax
  8008f9:	eb a5                	jmp    8008a0 <vprintfmt+0x3bb>
	else if (lflag)
  8008fb:	85 c9                	test   %ecx,%ecx
  8008fd:	75 17                	jne    800916 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8008ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800902:	8b 10                	mov    (%eax),%edx
  800904:	b9 00 00 00 00       	mov    $0x0,%ecx
  800909:	8d 40 04             	lea    0x4(%eax),%eax
  80090c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090f:	b8 10 00 00 00       	mov    $0x10,%eax
  800914:	eb 8a                	jmp    8008a0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8b 10                	mov    (%eax),%edx
  80091b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800920:	8d 40 04             	lea    0x4(%eax),%eax
  800923:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800926:	b8 10 00 00 00       	mov    $0x10,%eax
  80092b:	e9 70 ff ff ff       	jmp    8008a0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	53                   	push   %ebx
  800934:	6a 25                	push   $0x25
  800936:	ff d6                	call   *%esi
			break;
  800938:	83 c4 10             	add    $0x10,%esp
  80093b:	e9 7a ff ff ff       	jmp    8008ba <vprintfmt+0x3d5>
			putch('%', putdat);
  800940:	83 ec 08             	sub    $0x8,%esp
  800943:	53                   	push   %ebx
  800944:	6a 25                	push   $0x25
  800946:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800948:	83 c4 10             	add    $0x10,%esp
  80094b:	89 f8                	mov    %edi,%eax
  80094d:	eb 03                	jmp    800952 <vprintfmt+0x46d>
  80094f:	83 e8 01             	sub    $0x1,%eax
  800952:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800956:	75 f7                	jne    80094f <vprintfmt+0x46a>
  800958:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80095b:	e9 5a ff ff ff       	jmp    8008ba <vprintfmt+0x3d5>
}
  800960:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 18             	sub    $0x18,%esp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800974:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800977:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80097b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80097e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800985:	85 c0                	test   %eax,%eax
  800987:	74 26                	je     8009af <vsnprintf+0x47>
  800989:	85 d2                	test   %edx,%edx
  80098b:	7e 22                	jle    8009af <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098d:	ff 75 14             	pushl  0x14(%ebp)
  800990:	ff 75 10             	pushl  0x10(%ebp)
  800993:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800996:	50                   	push   %eax
  800997:	68 ab 04 80 00       	push   $0x8004ab
  80099c:	e8 44 fb ff ff       	call   8004e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009aa:	83 c4 10             	add    $0x10,%esp
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    
		return -E_INVAL;
  8009af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b4:	eb f7                	jmp    8009ad <vsnprintf+0x45>

008009b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009bc:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009bf:	50                   	push   %eax
  8009c0:	ff 75 10             	pushl  0x10(%ebp)
  8009c3:	ff 75 0c             	pushl  0xc(%ebp)
  8009c6:	ff 75 08             	pushl  0x8(%ebp)
  8009c9:	e8 9a ff ff ff       	call   800968 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009db:	eb 03                	jmp    8009e0 <strlen+0x10>
		n++;
  8009dd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009e0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e4:	75 f7                	jne    8009dd <strlen+0xd>
	return n;
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	eb 03                	jmp    8009fb <strnlen+0x13>
		n++;
  8009f8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009fb:	39 d0                	cmp    %edx,%eax
  8009fd:	74 06                	je     800a05 <strnlen+0x1d>
  8009ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a03:	75 f3                	jne    8009f8 <strnlen+0x10>
	return n;
}
  800a05:	5d                   	pop    %ebp
  800a06:	c3                   	ret    

00800a07 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	53                   	push   %ebx
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a11:	89 c2                	mov    %eax,%edx
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	83 c2 01             	add    $0x1,%edx
  800a19:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a1d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a20:	84 db                	test   %bl,%bl
  800a22:	75 ef                	jne    800a13 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a24:	5b                   	pop    %ebx
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	53                   	push   %ebx
  800a2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a2e:	53                   	push   %ebx
  800a2f:	e8 9c ff ff ff       	call   8009d0 <strlen>
  800a34:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a37:	ff 75 0c             	pushl  0xc(%ebp)
  800a3a:	01 d8                	add    %ebx,%eax
  800a3c:	50                   	push   %eax
  800a3d:	e8 c5 ff ff ff       	call   800a07 <strcpy>
	return dst;
}
  800a42:	89 d8                	mov    %ebx,%eax
  800a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a47:	c9                   	leave  
  800a48:	c3                   	ret    

00800a49 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	56                   	push   %esi
  800a4d:	53                   	push   %ebx
  800a4e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a51:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a59:	89 f2                	mov    %esi,%edx
  800a5b:	eb 0f                	jmp    800a6c <strncpy+0x23>
		*dst++ = *src;
  800a5d:	83 c2 01             	add    $0x1,%edx
  800a60:	0f b6 01             	movzbl (%ecx),%eax
  800a63:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a66:	80 39 01             	cmpb   $0x1,(%ecx)
  800a69:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a6c:	39 da                	cmp    %ebx,%edx
  800a6e:	75 ed                	jne    800a5d <strncpy+0x14>
	}
	return ret;
}
  800a70:	89 f0                	mov    %esi,%eax
  800a72:	5b                   	pop    %ebx
  800a73:	5e                   	pop    %esi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	56                   	push   %esi
  800a7a:	53                   	push   %ebx
  800a7b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a81:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a84:	89 f0                	mov    %esi,%eax
  800a86:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a8a:	85 c9                	test   %ecx,%ecx
  800a8c:	75 0b                	jne    800a99 <strlcpy+0x23>
  800a8e:	eb 17                	jmp    800aa7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a90:	83 c2 01             	add    $0x1,%edx
  800a93:	83 c0 01             	add    $0x1,%eax
  800a96:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a99:	39 d8                	cmp    %ebx,%eax
  800a9b:	74 07                	je     800aa4 <strlcpy+0x2e>
  800a9d:	0f b6 0a             	movzbl (%edx),%ecx
  800aa0:	84 c9                	test   %cl,%cl
  800aa2:	75 ec                	jne    800a90 <strlcpy+0x1a>
		*dst = '\0';
  800aa4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aa7:	29 f0                	sub    %esi,%eax
}
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab6:	eb 06                	jmp    800abe <strcmp+0x11>
		p++, q++;
  800ab8:	83 c1 01             	add    $0x1,%ecx
  800abb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800abe:	0f b6 01             	movzbl (%ecx),%eax
  800ac1:	84 c0                	test   %al,%al
  800ac3:	74 04                	je     800ac9 <strcmp+0x1c>
  800ac5:	3a 02                	cmp    (%edx),%al
  800ac7:	74 ef                	je     800ab8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ac9:	0f b6 c0             	movzbl %al,%eax
  800acc:	0f b6 12             	movzbl (%edx),%edx
  800acf:	29 d0                	sub    %edx,%eax
}
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	53                   	push   %ebx
  800ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  800ada:	8b 55 0c             	mov    0xc(%ebp),%edx
  800add:	89 c3                	mov    %eax,%ebx
  800adf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae2:	eb 06                	jmp    800aea <strncmp+0x17>
		n--, p++, q++;
  800ae4:	83 c0 01             	add    $0x1,%eax
  800ae7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aea:	39 d8                	cmp    %ebx,%eax
  800aec:	74 16                	je     800b04 <strncmp+0x31>
  800aee:	0f b6 08             	movzbl (%eax),%ecx
  800af1:	84 c9                	test   %cl,%cl
  800af3:	74 04                	je     800af9 <strncmp+0x26>
  800af5:	3a 0a                	cmp    (%edx),%cl
  800af7:	74 eb                	je     800ae4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800af9:	0f b6 00             	movzbl (%eax),%eax
  800afc:	0f b6 12             	movzbl (%edx),%edx
  800aff:	29 d0                	sub    %edx,%eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    
		return 0;
  800b04:	b8 00 00 00 00       	mov    $0x0,%eax
  800b09:	eb f6                	jmp    800b01 <strncmp+0x2e>

00800b0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b15:	0f b6 10             	movzbl (%eax),%edx
  800b18:	84 d2                	test   %dl,%dl
  800b1a:	74 09                	je     800b25 <strchr+0x1a>
		if (*s == c)
  800b1c:	38 ca                	cmp    %cl,%dl
  800b1e:	74 0a                	je     800b2a <strchr+0x1f>
	for (; *s; s++)
  800b20:	83 c0 01             	add    $0x1,%eax
  800b23:	eb f0                	jmp    800b15 <strchr+0xa>
			return (char *) s;
	return 0;
  800b25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b32:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b36:	eb 03                	jmp    800b3b <strfind+0xf>
  800b38:	83 c0 01             	add    $0x1,%eax
  800b3b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b3e:	38 ca                	cmp    %cl,%dl
  800b40:	74 04                	je     800b46 <strfind+0x1a>
  800b42:	84 d2                	test   %dl,%dl
  800b44:	75 f2                	jne    800b38 <strfind+0xc>
			break;
	return (char *) s;
}
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b54:	85 c9                	test   %ecx,%ecx
  800b56:	74 13                	je     800b6b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b58:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b5e:	75 05                	jne    800b65 <memset+0x1d>
  800b60:	f6 c1 03             	test   $0x3,%cl
  800b63:	74 0d                	je     800b72 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b68:	fc                   	cld    
  800b69:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6b:	89 f8                	mov    %edi,%eax
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    
		c &= 0xFF;
  800b72:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b76:	89 d3                	mov    %edx,%ebx
  800b78:	c1 e3 08             	shl    $0x8,%ebx
  800b7b:	89 d0                	mov    %edx,%eax
  800b7d:	c1 e0 18             	shl    $0x18,%eax
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	c1 e6 10             	shl    $0x10,%esi
  800b85:	09 f0                	or     %esi,%eax
  800b87:	09 c2                	or     %eax,%edx
  800b89:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b8b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b8e:	89 d0                	mov    %edx,%eax
  800b90:	fc                   	cld    
  800b91:	f3 ab                	rep stos %eax,%es:(%edi)
  800b93:	eb d6                	jmp    800b6b <memset+0x23>

00800b95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	57                   	push   %edi
  800b99:	56                   	push   %esi
  800b9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba3:	39 c6                	cmp    %eax,%esi
  800ba5:	73 35                	jae    800bdc <memmove+0x47>
  800ba7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800baa:	39 c2                	cmp    %eax,%edx
  800bac:	76 2e                	jbe    800bdc <memmove+0x47>
		s += n;
		d += n;
  800bae:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb1:	89 d6                	mov    %edx,%esi
  800bb3:	09 fe                	or     %edi,%esi
  800bb5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbb:	74 0c                	je     800bc9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bbd:	83 ef 01             	sub    $0x1,%edi
  800bc0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bc3:	fd                   	std    
  800bc4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc6:	fc                   	cld    
  800bc7:	eb 21                	jmp    800bea <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc9:	f6 c1 03             	test   $0x3,%cl
  800bcc:	75 ef                	jne    800bbd <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bce:	83 ef 04             	sub    $0x4,%edi
  800bd1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bd7:	fd                   	std    
  800bd8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bda:	eb ea                	jmp    800bc6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdc:	89 f2                	mov    %esi,%edx
  800bde:	09 c2                	or     %eax,%edx
  800be0:	f6 c2 03             	test   $0x3,%dl
  800be3:	74 09                	je     800bee <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be5:	89 c7                	mov    %eax,%edi
  800be7:	fc                   	cld    
  800be8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bea:	5e                   	pop    %esi
  800beb:	5f                   	pop    %edi
  800bec:	5d                   	pop    %ebp
  800bed:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bee:	f6 c1 03             	test   $0x3,%cl
  800bf1:	75 f2                	jne    800be5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	fc                   	cld    
  800bf9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bfb:	eb ed                	jmp    800bea <memmove+0x55>

00800bfd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c00:	ff 75 10             	pushl  0x10(%ebp)
  800c03:	ff 75 0c             	pushl  0xc(%ebp)
  800c06:	ff 75 08             	pushl  0x8(%ebp)
  800c09:	e8 87 ff ff ff       	call   800b95 <memmove>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1b:	89 c6                	mov    %eax,%esi
  800c1d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c20:	39 f0                	cmp    %esi,%eax
  800c22:	74 1c                	je     800c40 <memcmp+0x30>
		if (*s1 != *s2)
  800c24:	0f b6 08             	movzbl (%eax),%ecx
  800c27:	0f b6 1a             	movzbl (%edx),%ebx
  800c2a:	38 d9                	cmp    %bl,%cl
  800c2c:	75 08                	jne    800c36 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c2e:	83 c0 01             	add    $0x1,%eax
  800c31:	83 c2 01             	add    $0x1,%edx
  800c34:	eb ea                	jmp    800c20 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c36:	0f b6 c1             	movzbl %cl,%eax
  800c39:	0f b6 db             	movzbl %bl,%ebx
  800c3c:	29 d8                	sub    %ebx,%eax
  800c3e:	eb 05                	jmp    800c45 <memcmp+0x35>
	}

	return 0;
  800c40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c49:	55                   	push   %ebp
  800c4a:	89 e5                	mov    %esp,%ebp
  800c4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c57:	39 d0                	cmp    %edx,%eax
  800c59:	73 09                	jae    800c64 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c5b:	38 08                	cmp    %cl,(%eax)
  800c5d:	74 05                	je     800c64 <memfind+0x1b>
	for (; s < ends; s++)
  800c5f:	83 c0 01             	add    $0x1,%eax
  800c62:	eb f3                	jmp    800c57 <memfind+0xe>
			break;
	return (void *) s;
}
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	57                   	push   %edi
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c72:	eb 03                	jmp    800c77 <strtol+0x11>
		s++;
  800c74:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c77:	0f b6 01             	movzbl (%ecx),%eax
  800c7a:	3c 20                	cmp    $0x20,%al
  800c7c:	74 f6                	je     800c74 <strtol+0xe>
  800c7e:	3c 09                	cmp    $0x9,%al
  800c80:	74 f2                	je     800c74 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c82:	3c 2b                	cmp    $0x2b,%al
  800c84:	74 2e                	je     800cb4 <strtol+0x4e>
	int neg = 0;
  800c86:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c8b:	3c 2d                	cmp    $0x2d,%al
  800c8d:	74 2f                	je     800cbe <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c95:	75 05                	jne    800c9c <strtol+0x36>
  800c97:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9a:	74 2c                	je     800cc8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9c:	85 db                	test   %ebx,%ebx
  800c9e:	75 0a                	jne    800caa <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ca5:	80 39 30             	cmpb   $0x30,(%ecx)
  800ca8:	74 28                	je     800cd2 <strtol+0x6c>
		base = 10;
  800caa:	b8 00 00 00 00       	mov    $0x0,%eax
  800caf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cb2:	eb 50                	jmp    800d04 <strtol+0x9e>
		s++;
  800cb4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cb7:	bf 00 00 00 00       	mov    $0x0,%edi
  800cbc:	eb d1                	jmp    800c8f <strtol+0x29>
		s++, neg = 1;
  800cbe:	83 c1 01             	add    $0x1,%ecx
  800cc1:	bf 01 00 00 00       	mov    $0x1,%edi
  800cc6:	eb c7                	jmp    800c8f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cc8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ccc:	74 0e                	je     800cdc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cce:	85 db                	test   %ebx,%ebx
  800cd0:	75 d8                	jne    800caa <strtol+0x44>
		s++, base = 8;
  800cd2:	83 c1 01             	add    $0x1,%ecx
  800cd5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cda:	eb ce                	jmp    800caa <strtol+0x44>
		s += 2, base = 16;
  800cdc:	83 c1 02             	add    $0x2,%ecx
  800cdf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce4:	eb c4                	jmp    800caa <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800ce6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce9:	89 f3                	mov    %esi,%ebx
  800ceb:	80 fb 19             	cmp    $0x19,%bl
  800cee:	77 29                	ja     800d19 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cf0:	0f be d2             	movsbl %dl,%edx
  800cf3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cf6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cf9:	7d 30                	jge    800d2b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cfb:	83 c1 01             	add    $0x1,%ecx
  800cfe:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d02:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d04:	0f b6 11             	movzbl (%ecx),%edx
  800d07:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d0a:	89 f3                	mov    %esi,%ebx
  800d0c:	80 fb 09             	cmp    $0x9,%bl
  800d0f:	77 d5                	ja     800ce6 <strtol+0x80>
			dig = *s - '0';
  800d11:	0f be d2             	movsbl %dl,%edx
  800d14:	83 ea 30             	sub    $0x30,%edx
  800d17:	eb dd                	jmp    800cf6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d1c:	89 f3                	mov    %esi,%ebx
  800d1e:	80 fb 19             	cmp    $0x19,%bl
  800d21:	77 08                	ja     800d2b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d23:	0f be d2             	movsbl %dl,%edx
  800d26:	83 ea 37             	sub    $0x37,%edx
  800d29:	eb cb                	jmp    800cf6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d2b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d2f:	74 05                	je     800d36 <strtol+0xd0>
		*endptr = (char *) s;
  800d31:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d34:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d36:	89 c2                	mov    %eax,%edx
  800d38:	f7 da                	neg    %edx
  800d3a:	85 ff                	test   %edi,%edi
  800d3c:	0f 45 c2             	cmovne %edx,%eax
}
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
  800d44:	66 90                	xchg   %ax,%ax
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__udivdi3>:
  800d50:	55                   	push   %ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
  800d57:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d5b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d5f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d63:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d67:	85 d2                	test   %edx,%edx
  800d69:	75 35                	jne    800da0 <__udivdi3+0x50>
  800d6b:	39 f3                	cmp    %esi,%ebx
  800d6d:	0f 87 bd 00 00 00    	ja     800e30 <__udivdi3+0xe0>
  800d73:	85 db                	test   %ebx,%ebx
  800d75:	89 d9                	mov    %ebx,%ecx
  800d77:	75 0b                	jne    800d84 <__udivdi3+0x34>
  800d79:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7e:	31 d2                	xor    %edx,%edx
  800d80:	f7 f3                	div    %ebx
  800d82:	89 c1                	mov    %eax,%ecx
  800d84:	31 d2                	xor    %edx,%edx
  800d86:	89 f0                	mov    %esi,%eax
  800d88:	f7 f1                	div    %ecx
  800d8a:	89 c6                	mov    %eax,%esi
  800d8c:	89 e8                	mov    %ebp,%eax
  800d8e:	89 f7                	mov    %esi,%edi
  800d90:	f7 f1                	div    %ecx
  800d92:	89 fa                	mov    %edi,%edx
  800d94:	83 c4 1c             	add    $0x1c,%esp
  800d97:	5b                   	pop    %ebx
  800d98:	5e                   	pop    %esi
  800d99:	5f                   	pop    %edi
  800d9a:	5d                   	pop    %ebp
  800d9b:	c3                   	ret    
  800d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800da0:	39 f2                	cmp    %esi,%edx
  800da2:	77 7c                	ja     800e20 <__udivdi3+0xd0>
  800da4:	0f bd fa             	bsr    %edx,%edi
  800da7:	83 f7 1f             	xor    $0x1f,%edi
  800daa:	0f 84 98 00 00 00    	je     800e48 <__udivdi3+0xf8>
  800db0:	89 f9                	mov    %edi,%ecx
  800db2:	b8 20 00 00 00       	mov    $0x20,%eax
  800db7:	29 f8                	sub    %edi,%eax
  800db9:	d3 e2                	shl    %cl,%edx
  800dbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	89 da                	mov    %ebx,%edx
  800dc3:	d3 ea                	shr    %cl,%edx
  800dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc9:	09 d1                	or     %edx,%ecx
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e3                	shl    %cl,%ebx
  800dd5:	89 c1                	mov    %eax,%ecx
  800dd7:	d3 ea                	shr    %cl,%edx
  800dd9:	89 f9                	mov    %edi,%ecx
  800ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ddf:	d3 e6                	shl    %cl,%esi
  800de1:	89 eb                	mov    %ebp,%ebx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	d3 eb                	shr    %cl,%ebx
  800de7:	09 de                	or     %ebx,%esi
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	f7 74 24 08          	divl   0x8(%esp)
  800def:	89 d6                	mov    %edx,%esi
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	f7 64 24 0c          	mull   0xc(%esp)
  800df7:	39 d6                	cmp    %edx,%esi
  800df9:	72 0c                	jb     800e07 <__udivdi3+0xb7>
  800dfb:	89 f9                	mov    %edi,%ecx
  800dfd:	d3 e5                	shl    %cl,%ebp
  800dff:	39 c5                	cmp    %eax,%ebp
  800e01:	73 5d                	jae    800e60 <__udivdi3+0x110>
  800e03:	39 d6                	cmp    %edx,%esi
  800e05:	75 59                	jne    800e60 <__udivdi3+0x110>
  800e07:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e0a:	31 ff                	xor    %edi,%edi
  800e0c:	89 fa                	mov    %edi,%edx
  800e0e:	83 c4 1c             	add    $0x1c,%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
  800e16:	8d 76 00             	lea    0x0(%esi),%esi
  800e19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	31 c0                	xor    %eax,%eax
  800e24:	89 fa                	mov    %edi,%edx
  800e26:	83 c4 1c             	add    $0x1c,%esp
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    
  800e2e:	66 90                	xchg   %ax,%ax
  800e30:	31 ff                	xor    %edi,%edi
  800e32:	89 e8                	mov    %ebp,%eax
  800e34:	89 f2                	mov    %esi,%edx
  800e36:	f7 f3                	div    %ebx
  800e38:	89 fa                	mov    %edi,%edx
  800e3a:	83 c4 1c             	add    $0x1c,%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
  800e42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e48:	39 f2                	cmp    %esi,%edx
  800e4a:	72 06                	jb     800e52 <__udivdi3+0x102>
  800e4c:	31 c0                	xor    %eax,%eax
  800e4e:	39 eb                	cmp    %ebp,%ebx
  800e50:	77 d2                	ja     800e24 <__udivdi3+0xd4>
  800e52:	b8 01 00 00 00       	mov    $0x1,%eax
  800e57:	eb cb                	jmp    800e24 <__udivdi3+0xd4>
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 d8                	mov    %ebx,%eax
  800e62:	31 ff                	xor    %edi,%edi
  800e64:	eb be                	jmp    800e24 <__udivdi3+0xd4>
  800e66:	66 90                	xchg   %ax,%ax
  800e68:	66 90                	xchg   %ax,%ax
  800e6a:	66 90                	xchg   %ax,%ax
  800e6c:	66 90                	xchg   %ax,%ax
  800e6e:	66 90                	xchg   %ax,%ax

00800e70 <__umoddi3>:
  800e70:	55                   	push   %ebp
  800e71:	57                   	push   %edi
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	83 ec 1c             	sub    $0x1c,%esp
  800e77:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e87:	85 ed                	test   %ebp,%ebp
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	89 da                	mov    %ebx,%edx
  800e8d:	75 19                	jne    800ea8 <__umoddi3+0x38>
  800e8f:	39 df                	cmp    %ebx,%edi
  800e91:	0f 86 b1 00 00 00    	jbe    800f48 <__umoddi3+0xd8>
  800e97:	f7 f7                	div    %edi
  800e99:	89 d0                	mov    %edx,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	83 c4 1c             	add    $0x1c,%esp
  800ea0:	5b                   	pop    %ebx
  800ea1:	5e                   	pop    %esi
  800ea2:	5f                   	pop    %edi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
  800ea5:	8d 76 00             	lea    0x0(%esi),%esi
  800ea8:	39 dd                	cmp    %ebx,%ebp
  800eaa:	77 f1                	ja     800e9d <__umoddi3+0x2d>
  800eac:	0f bd cd             	bsr    %ebp,%ecx
  800eaf:	83 f1 1f             	xor    $0x1f,%ecx
  800eb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800eb6:	0f 84 b4 00 00 00    	je     800f70 <__umoddi3+0x100>
  800ebc:	b8 20 00 00 00       	mov    $0x20,%eax
  800ec1:	89 c2                	mov    %eax,%edx
  800ec3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ec7:	29 c2                	sub    %eax,%edx
  800ec9:	89 c1                	mov    %eax,%ecx
  800ecb:	89 f8                	mov    %edi,%eax
  800ecd:	d3 e5                	shl    %cl,%ebp
  800ecf:	89 d1                	mov    %edx,%ecx
  800ed1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ed5:	d3 e8                	shr    %cl,%eax
  800ed7:	09 c5                	or     %eax,%ebp
  800ed9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800edd:	89 c1                	mov    %eax,%ecx
  800edf:	d3 e7                	shl    %cl,%edi
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ee7:	89 df                	mov    %ebx,%edi
  800ee9:	d3 ef                	shr    %cl,%edi
  800eeb:	89 c1                	mov    %eax,%ecx
  800eed:	89 f0                	mov    %esi,%eax
  800eef:	d3 e3                	shl    %cl,%ebx
  800ef1:	89 d1                	mov    %edx,%ecx
  800ef3:	89 fa                	mov    %edi,%edx
  800ef5:	d3 e8                	shr    %cl,%eax
  800ef7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800efc:	09 d8                	or     %ebx,%eax
  800efe:	f7 f5                	div    %ebp
  800f00:	d3 e6                	shl    %cl,%esi
  800f02:	89 d1                	mov    %edx,%ecx
  800f04:	f7 64 24 08          	mull   0x8(%esp)
  800f08:	39 d1                	cmp    %edx,%ecx
  800f0a:	89 c3                	mov    %eax,%ebx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	72 06                	jb     800f16 <__umoddi3+0xa6>
  800f10:	75 0e                	jne    800f20 <__umoddi3+0xb0>
  800f12:	39 c6                	cmp    %eax,%esi
  800f14:	73 0a                	jae    800f20 <__umoddi3+0xb0>
  800f16:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f1a:	19 ea                	sbb    %ebp,%edx
  800f1c:	89 d7                	mov    %edx,%edi
  800f1e:	89 c3                	mov    %eax,%ebx
  800f20:	89 ca                	mov    %ecx,%edx
  800f22:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f27:	29 de                	sub    %ebx,%esi
  800f29:	19 fa                	sbb    %edi,%edx
  800f2b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f2f:	89 d0                	mov    %edx,%eax
  800f31:	d3 e0                	shl    %cl,%eax
  800f33:	89 d9                	mov    %ebx,%ecx
  800f35:	d3 ee                	shr    %cl,%esi
  800f37:	d3 ea                	shr    %cl,%edx
  800f39:	09 f0                	or     %esi,%eax
  800f3b:	83 c4 1c             	add    $0x1c,%esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
  800f43:	90                   	nop
  800f44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f48:	85 ff                	test   %edi,%edi
  800f4a:	89 f9                	mov    %edi,%ecx
  800f4c:	75 0b                	jne    800f59 <__umoddi3+0xe9>
  800f4e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f53:	31 d2                	xor    %edx,%edx
  800f55:	f7 f7                	div    %edi
  800f57:	89 c1                	mov    %eax,%ecx
  800f59:	89 d8                	mov    %ebx,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f1                	div    %ecx
  800f5f:	89 f0                	mov    %esi,%eax
  800f61:	f7 f1                	div    %ecx
  800f63:	e9 31 ff ff ff       	jmp    800e99 <__umoddi3+0x29>
  800f68:	90                   	nop
  800f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f70:	39 dd                	cmp    %ebx,%ebp
  800f72:	72 08                	jb     800f7c <__umoddi3+0x10c>
  800f74:	39 f7                	cmp    %esi,%edi
  800f76:	0f 87 21 ff ff ff    	ja     800e9d <__umoddi3+0x2d>
  800f7c:	89 da                	mov    %ebx,%edx
  800f7e:	89 f0                	mov    %esi,%eax
  800f80:	29 f8                	sub    %edi,%eax
  800f82:	19 ea                	sbb    %ebp,%edx
  800f84:	e9 14 ff ff ff       	jmp    800e9d <__umoddi3+0x2d>
