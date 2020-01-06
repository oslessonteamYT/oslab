
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800045:	e8 c6 00 00 00       	call   800110 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7f 08                	jg     8000f9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 8a 0f 80 00       	push   $0x800f8a
  800104:	6a 23                	push   $0x23
  800106:	68 a7 0f 80 00       	push   $0x800fa7
  80010b:	e8 ed 01 00 00       	call   8002fd <_panic>

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800162:	b8 04 00 00 00       	mov    $0x4,%eax
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7f 08                	jg     80017a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 8a 0f 80 00       	push   $0x800f8a
  800185:	6a 23                	push   $0x23
  800187:	68 a7 0f 80 00       	push   $0x800fa7
  80018c:	e8 6c 01 00 00       	call   8002fd <_panic>

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7f 08                	jg     8001bc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 8a 0f 80 00       	push   $0x800f8a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 a7 0f 80 00       	push   $0x800fa7
  8001ce:	e8 2a 01 00 00       	call   8002fd <_panic>

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7f 08                	jg     8001fe <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 8a 0f 80 00       	push   $0x800f8a
  800209:	6a 23                	push   $0x23
  80020b:	68 a7 0f 80 00       	push   $0x800fa7
  800210:	e8 e8 00 00 00       	call   8002fd <_panic>

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800229:	b8 08 00 00 00       	mov    $0x8,%eax
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7f 08                	jg     800240 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 8a 0f 80 00       	push   $0x800f8a
  80024b:	6a 23                	push   $0x23
  80024d:	68 a7 0f 80 00       	push   $0x800fa7
  800252:	e8 a6 00 00 00       	call   8002fd <_panic>

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026b:	b8 09 00 00 00       	mov    $0x9,%eax
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7f 08                	jg     800282 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 8a 0f 80 00       	push   $0x800f8a
  80028d:	6a 23                	push   $0x23
  80028f:	68 a7 0f 80 00       	push   $0x800fa7
  800294:	e8 64 00 00 00       	call   8002fd <_panic>

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029f:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002aa:	be 00 00 00 00       	mov    $0x0,%esi
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7f 08                	jg     8002e6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0c                	push   $0xc
  8002ec:	68 8a 0f 80 00       	push   $0x800f8a
  8002f1:	6a 23                	push   $0x23
  8002f3:	68 a7 0f 80 00       	push   $0x800fa7
  8002f8:	e8 00 00 00 00       	call   8002fd <_panic>

008002fd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800305:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030b:	e8 00 fe ff ff       	call   800110 <sys_getenvid>
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	ff 75 0c             	pushl  0xc(%ebp)
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	56                   	push   %esi
  80031a:	50                   	push   %eax
  80031b:	68 b8 0f 80 00       	push   $0x800fb8
  800320:	e8 b3 00 00 00       	call   8003d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	53                   	push   %ebx
  800329:	ff 75 10             	pushl  0x10(%ebp)
  80032c:	e8 56 00 00 00       	call   800387 <vcprintf>
	cprintf("\n");
  800331:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800338:	e8 9b 00 00 00       	call   8003d8 <cprintf>
  80033d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800340:	cc                   	int3   
  800341:	eb fd                	jmp    800340 <_panic+0x43>

00800343 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	53                   	push   %ebx
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034d:	8b 13                	mov    (%ebx),%edx
  80034f:	8d 42 01             	lea    0x1(%edx),%eax
  800352:	89 03                	mov    %eax,(%ebx)
  800354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800357:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800360:	74 09                	je     80036b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800362:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800369:	c9                   	leave  
  80036a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80036b:	83 ec 08             	sub    $0x8,%esp
  80036e:	68 ff 00 00 00       	push   $0xff
  800373:	8d 43 08             	lea    0x8(%ebx),%eax
  800376:	50                   	push   %eax
  800377:	e8 16 fd ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  80037c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800382:	83 c4 10             	add    $0x10,%esp
  800385:	eb db                	jmp    800362 <putch+0x1f>

00800387 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800390:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800397:	00 00 00 
	b.cnt = 0;
  80039a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a4:	ff 75 0c             	pushl  0xc(%ebp)
  8003a7:	ff 75 08             	pushl  0x8(%ebp)
  8003aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b0:	50                   	push   %eax
  8003b1:	68 43 03 80 00       	push   $0x800343
  8003b6:	e8 1a 01 00 00       	call   8004d5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bb:	83 c4 08             	add    $0x8,%esp
  8003be:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ca:	50                   	push   %eax
  8003cb:	e8 c2 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8003d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 08             	pushl  0x8(%ebp)
  8003e5:	e8 9d ff ff ff       	call   800387 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	83 ec 1c             	sub    $0x1c,%esp
  8003f5:	89 c7                	mov    %eax,%edi
  8003f7:	89 d6                	mov    %edx,%esi
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800402:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800405:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800408:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800410:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800413:	39 d3                	cmp    %edx,%ebx
  800415:	72 05                	jb     80041c <printnum+0x30>
  800417:	39 45 10             	cmp    %eax,0x10(%ebp)
  80041a:	77 7a                	ja     800496 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041c:	83 ec 0c             	sub    $0xc,%esp
  80041f:	ff 75 18             	pushl  0x18(%ebp)
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800428:	53                   	push   %ebx
  800429:	ff 75 10             	pushl  0x10(%ebp)
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800432:	ff 75 e0             	pushl  -0x20(%ebp)
  800435:	ff 75 dc             	pushl  -0x24(%ebp)
  800438:	ff 75 d8             	pushl  -0x28(%ebp)
  80043b:	e8 00 09 00 00       	call   800d40 <__udivdi3>
  800440:	83 c4 18             	add    $0x18,%esp
  800443:	52                   	push   %edx
  800444:	50                   	push   %eax
  800445:	89 f2                	mov    %esi,%edx
  800447:	89 f8                	mov    %edi,%eax
  800449:	e8 9e ff ff ff       	call   8003ec <printnum>
  80044e:	83 c4 20             	add    $0x20,%esp
  800451:	eb 13                	jmp    800466 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	56                   	push   %esi
  800457:	ff 75 18             	pushl  0x18(%ebp)
  80045a:	ff d7                	call   *%edi
  80045c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80045f:	83 eb 01             	sub    $0x1,%ebx
  800462:	85 db                	test   %ebx,%ebx
  800464:	7f ed                	jg     800453 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	83 ec 04             	sub    $0x4,%esp
  80046d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800470:	ff 75 e0             	pushl  -0x20(%ebp)
  800473:	ff 75 dc             	pushl  -0x24(%ebp)
  800476:	ff 75 d8             	pushl  -0x28(%ebp)
  800479:	e8 e2 09 00 00       	call   800e60 <__umoddi3>
  80047e:	83 c4 14             	add    $0x14,%esp
  800481:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  800488:	50                   	push   %eax
  800489:	ff d7                	call   *%edi
}
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800491:	5b                   	pop    %ebx
  800492:	5e                   	pop    %esi
  800493:	5f                   	pop    %edi
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    
  800496:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800499:	eb c4                	jmp    80045f <printnum+0x73>

0080049b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049b:	55                   	push   %ebp
  80049c:	89 e5                	mov    %esp,%ebp
  80049e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004aa:	73 0a                	jae    8004b6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ac:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b4:	88 02                	mov    %al,(%edx)
}
  8004b6:	5d                   	pop    %ebp
  8004b7:	c3                   	ret    

008004b8 <printfmt>:
{
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004be:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c1:	50                   	push   %eax
  8004c2:	ff 75 10             	pushl  0x10(%ebp)
  8004c5:	ff 75 0c             	pushl  0xc(%ebp)
  8004c8:	ff 75 08             	pushl  0x8(%ebp)
  8004cb:	e8 05 00 00 00       	call   8004d5 <vprintfmt>
}
  8004d0:	83 c4 10             	add    $0x10,%esp
  8004d3:	c9                   	leave  
  8004d4:	c3                   	ret    

008004d5 <vprintfmt>:
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	57                   	push   %edi
  8004d9:	56                   	push   %esi
  8004da:	53                   	push   %ebx
  8004db:	83 ec 2c             	sub    $0x2c,%esp
  8004de:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e7:	e9 c1 03 00 00       	jmp    8008ad <vprintfmt+0x3d8>
		padc = ' ';
  8004ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8004fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800505:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80050a:	8d 47 01             	lea    0x1(%edi),%eax
  80050d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800510:	0f b6 17             	movzbl (%edi),%edx
  800513:	8d 42 dd             	lea    -0x23(%edx),%eax
  800516:	3c 55                	cmp    $0x55,%al
  800518:	0f 87 12 04 00 00    	ja     800930 <vprintfmt+0x45b>
  80051e:	0f b6 c0             	movzbl %al,%eax
  800521:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80052b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80052f:	eb d9                	jmp    80050a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800534:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800538:	eb d0                	jmp    80050a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	0f b6 d2             	movzbl %dl,%edx
  80053d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800540:	b8 00 00 00 00       	mov    $0x0,%eax
  800545:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800548:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80054b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80054f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800552:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800555:	83 f9 09             	cmp    $0x9,%ecx
  800558:	77 55                	ja     8005af <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80055a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80055d:	eb e9                	jmp    800548 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8b 00                	mov    (%eax),%eax
  800564:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800567:	8b 45 14             	mov    0x14(%ebp),%eax
  80056a:	8d 40 04             	lea    0x4(%eax),%eax
  80056d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800570:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800573:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800577:	79 91                	jns    80050a <vprintfmt+0x35>
				width = precision, precision = -1;
  800579:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800586:	eb 82                	jmp    80050a <vprintfmt+0x35>
  800588:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058b:	85 c0                	test   %eax,%eax
  80058d:	ba 00 00 00 00       	mov    $0x0,%edx
  800592:	0f 49 d0             	cmovns %eax,%edx
  800595:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059b:	e9 6a ff ff ff       	jmp    80050a <vprintfmt+0x35>
  8005a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005a3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005aa:	e9 5b ff ff ff       	jmp    80050a <vprintfmt+0x35>
  8005af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b5:	eb bc                	jmp    800573 <vprintfmt+0x9e>
			lflag++;
  8005b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005bd:	e9 48 ff ff ff       	jmp    80050a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8d 78 04             	lea    0x4(%eax),%edi
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	ff 30                	pushl  (%eax)
  8005ce:	ff d6                	call   *%esi
			break;
  8005d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005d6:	e9 cf 02 00 00       	jmp    8008aa <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 78 04             	lea    0x4(%eax),%edi
  8005e1:	8b 00                	mov    (%eax),%eax
  8005e3:	99                   	cltd   
  8005e4:	31 d0                	xor    %edx,%eax
  8005e6:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e8:	83 f8 08             	cmp    $0x8,%eax
  8005eb:	7f 23                	jg     800610 <vprintfmt+0x13b>
  8005ed:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8005f4:	85 d2                	test   %edx,%edx
  8005f6:	74 18                	je     800610 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8005f8:	52                   	push   %edx
  8005f9:	68 ff 0f 80 00       	push   $0x800fff
  8005fe:	53                   	push   %ebx
  8005ff:	56                   	push   %esi
  800600:	e8 b3 fe ff ff       	call   8004b8 <printfmt>
  800605:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800608:	89 7d 14             	mov    %edi,0x14(%ebp)
  80060b:	e9 9a 02 00 00       	jmp    8008aa <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800610:	50                   	push   %eax
  800611:	68 f6 0f 80 00       	push   $0x800ff6
  800616:	53                   	push   %ebx
  800617:	56                   	push   %esi
  800618:	e8 9b fe ff ff       	call   8004b8 <printfmt>
  80061d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800620:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800623:	e9 82 02 00 00       	jmp    8008aa <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800628:	8b 45 14             	mov    0x14(%ebp),%eax
  80062b:	83 c0 04             	add    $0x4,%eax
  80062e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800636:	85 ff                	test   %edi,%edi
  800638:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  80063d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800640:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800644:	0f 8e bd 00 00 00    	jle    800707 <vprintfmt+0x232>
  80064a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80064e:	75 0e                	jne    80065e <vprintfmt+0x189>
  800650:	89 75 08             	mov    %esi,0x8(%ebp)
  800653:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800656:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800659:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065c:	eb 6d                	jmp    8006cb <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 d0             	pushl  -0x30(%ebp)
  800664:	57                   	push   %edi
  800665:	e8 6e 03 00 00       	call   8009d8 <strnlen>
  80066a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80066d:	29 c1                	sub    %eax,%ecx
  80066f:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800672:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800675:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800679:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80067f:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800681:	eb 0f                	jmp    800692 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800683:	83 ec 08             	sub    $0x8,%esp
  800686:	53                   	push   %ebx
  800687:	ff 75 e0             	pushl  -0x20(%ebp)
  80068a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068c:	83 ef 01             	sub    $0x1,%edi
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	85 ff                	test   %edi,%edi
  800694:	7f ed                	jg     800683 <vprintfmt+0x1ae>
  800696:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800699:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069c:	85 c9                	test   %ecx,%ecx
  80069e:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a3:	0f 49 c1             	cmovns %ecx,%eax
  8006a6:	29 c1                	sub    %eax,%ecx
  8006a8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006ab:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ae:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b1:	89 cb                	mov    %ecx,%ebx
  8006b3:	eb 16                	jmp    8006cb <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b9:	75 31                	jne    8006ec <vprintfmt+0x217>
					putch(ch, putdat);
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	ff 75 0c             	pushl  0xc(%ebp)
  8006c1:	50                   	push   %eax
  8006c2:	ff 55 08             	call   *0x8(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c8:	83 eb 01             	sub    $0x1,%ebx
  8006cb:	83 c7 01             	add    $0x1,%edi
  8006ce:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006d2:	0f be c2             	movsbl %dl,%eax
  8006d5:	85 c0                	test   %eax,%eax
  8006d7:	74 59                	je     800732 <vprintfmt+0x25d>
  8006d9:	85 f6                	test   %esi,%esi
  8006db:	78 d8                	js     8006b5 <vprintfmt+0x1e0>
  8006dd:	83 ee 01             	sub    $0x1,%esi
  8006e0:	79 d3                	jns    8006b5 <vprintfmt+0x1e0>
  8006e2:	89 df                	mov    %ebx,%edi
  8006e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ea:	eb 37                	jmp    800723 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ec:	0f be d2             	movsbl %dl,%edx
  8006ef:	83 ea 20             	sub    $0x20,%edx
  8006f2:	83 fa 5e             	cmp    $0x5e,%edx
  8006f5:	76 c4                	jbe    8006bb <vprintfmt+0x1e6>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb c1                	jmp    8006c8 <vprintfmt+0x1f3>
  800707:	89 75 08             	mov    %esi,0x8(%ebp)
  80070a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800710:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800713:	eb b6                	jmp    8006cb <vprintfmt+0x1f6>
				putch(' ', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	6a 20                	push   $0x20
  80071b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80071d:	83 ef 01             	sub    $0x1,%edi
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	85 ff                	test   %edi,%edi
  800725:	7f ee                	jg     800715 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800727:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80072a:	89 45 14             	mov    %eax,0x14(%ebp)
  80072d:	e9 78 01 00 00       	jmp    8008aa <vprintfmt+0x3d5>
  800732:	89 df                	mov    %ebx,%edi
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb e7                	jmp    800723 <vprintfmt+0x24e>
	if (lflag >= 2)
  80073c:	83 f9 01             	cmp    $0x1,%ecx
  80073f:	7e 3f                	jle    800780 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800741:	8b 45 14             	mov    0x14(%ebp),%eax
  800744:	8b 50 04             	mov    0x4(%eax),%edx
  800747:	8b 00                	mov    (%eax),%eax
  800749:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074f:	8b 45 14             	mov    0x14(%ebp),%eax
  800752:	8d 40 08             	lea    0x8(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800758:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80075c:	79 5c                	jns    8007ba <vprintfmt+0x2e5>
				putch('-', putdat);
  80075e:	83 ec 08             	sub    $0x8,%esp
  800761:	53                   	push   %ebx
  800762:	6a 2d                	push   $0x2d
  800764:	ff d6                	call   *%esi
				num = -(long long) num;
  800766:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800769:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076c:	f7 da                	neg    %edx
  80076e:	83 d1 00             	adc    $0x0,%ecx
  800771:	f7 d9                	neg    %ecx
  800773:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800776:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077b:	e9 10 01 00 00       	jmp    800890 <vprintfmt+0x3bb>
	else if (lflag)
  800780:	85 c9                	test   %ecx,%ecx
  800782:	75 1b                	jne    80079f <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800784:	8b 45 14             	mov    0x14(%ebp),%eax
  800787:	8b 00                	mov    (%eax),%eax
  800789:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078c:	89 c1                	mov    %eax,%ecx
  80078e:	c1 f9 1f             	sar    $0x1f,%ecx
  800791:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 40 04             	lea    0x4(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
  80079d:	eb b9                	jmp    800758 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 00                	mov    (%eax),%eax
  8007a4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a7:	89 c1                	mov    %eax,%ecx
  8007a9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007af:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b8:	eb 9e                	jmp    800758 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007c0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c5:	e9 c6 00 00 00       	jmp    800890 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007ca:	83 f9 01             	cmp    $0x1,%ecx
  8007cd:	7e 18                	jle    8007e7 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e2:	e9 a9 00 00 00       	jmp    800890 <vprintfmt+0x3bb>
	else if (lflag)
  8007e7:	85 c9                	test   %ecx,%ecx
  8007e9:	75 1a                	jne    800805 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8007eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ee:	8b 10                	mov    (%eax),%edx
  8007f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f5:	8d 40 04             	lea    0x4(%eax),%eax
  8007f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007fb:	b8 0a 00 00 00       	mov    $0xa,%eax
  800800:	e9 8b 00 00 00       	jmp    800890 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800805:	8b 45 14             	mov    0x14(%ebp),%eax
  800808:	8b 10                	mov    (%eax),%edx
  80080a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080f:	8d 40 04             	lea    0x4(%eax),%eax
  800812:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800815:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081a:	eb 74                	jmp    800890 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80081c:	83 f9 01             	cmp    $0x1,%ecx
  80081f:	7e 15                	jle    800836 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	8b 48 04             	mov    0x4(%eax),%ecx
  800829:	8d 40 08             	lea    0x8(%eax),%eax
  80082c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80082f:	b8 08 00 00 00       	mov    $0x8,%eax
  800834:	eb 5a                	jmp    800890 <vprintfmt+0x3bb>
	else if (lflag)
  800836:	85 c9                	test   %ecx,%ecx
  800838:	75 17                	jne    800851 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	8b 10                	mov    (%eax),%edx
  80083f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800844:	8d 40 04             	lea    0x4(%eax),%eax
  800847:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80084a:	b8 08 00 00 00       	mov    $0x8,%eax
  80084f:	eb 3f                	jmp    800890 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8b 10                	mov    (%eax),%edx
  800856:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085b:	8d 40 04             	lea    0x4(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800861:	b8 08 00 00 00       	mov    $0x8,%eax
  800866:	eb 28                	jmp    800890 <vprintfmt+0x3bb>
			putch('0', putdat);
  800868:	83 ec 08             	sub    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 30                	push   $0x30
  80086e:	ff d6                	call   *%esi
			putch('x', putdat);
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 78                	push   $0x78
  800876:	ff d6                	call   *%esi
			num = (unsigned long long)
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800882:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800885:	8d 40 04             	lea    0x4(%eax),%eax
  800888:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80088b:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800890:	83 ec 0c             	sub    $0xc,%esp
  800893:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800897:	57                   	push   %edi
  800898:	ff 75 e0             	pushl  -0x20(%ebp)
  80089b:	50                   	push   %eax
  80089c:	51                   	push   %ecx
  80089d:	52                   	push   %edx
  80089e:	89 da                	mov    %ebx,%edx
  8008a0:	89 f0                	mov    %esi,%eax
  8008a2:	e8 45 fb ff ff       	call   8003ec <printnum>
			break;
  8008a7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ad:	83 c7 01             	add    $0x1,%edi
  8008b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008b4:	83 f8 25             	cmp    $0x25,%eax
  8008b7:	0f 84 2f fc ff ff    	je     8004ec <vprintfmt+0x17>
			if (ch == '\0')
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	0f 84 8b 00 00 00    	je     800950 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008c5:	83 ec 08             	sub    $0x8,%esp
  8008c8:	53                   	push   %ebx
  8008c9:	50                   	push   %eax
  8008ca:	ff d6                	call   *%esi
  8008cc:	83 c4 10             	add    $0x10,%esp
  8008cf:	eb dc                	jmp    8008ad <vprintfmt+0x3d8>
	if (lflag >= 2)
  8008d1:	83 f9 01             	cmp    $0x1,%ecx
  8008d4:	7e 15                	jle    8008eb <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8008d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d9:	8b 10                	mov    (%eax),%edx
  8008db:	8b 48 04             	mov    0x4(%eax),%ecx
  8008de:	8d 40 08             	lea    0x8(%eax),%eax
  8008e1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e9:	eb a5                	jmp    800890 <vprintfmt+0x3bb>
	else if (lflag)
  8008eb:	85 c9                	test   %ecx,%ecx
  8008ed:	75 17                	jne    800906 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8008ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f2:	8b 10                	mov    (%eax),%edx
  8008f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f9:	8d 40 04             	lea    0x4(%eax),%eax
  8008fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800904:	eb 8a                	jmp    800890 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8b 10                	mov    (%eax),%edx
  80090b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800910:	8d 40 04             	lea    0x4(%eax),%eax
  800913:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800916:	b8 10 00 00 00       	mov    $0x10,%eax
  80091b:	e9 70 ff ff ff       	jmp    800890 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800920:	83 ec 08             	sub    $0x8,%esp
  800923:	53                   	push   %ebx
  800924:	6a 25                	push   $0x25
  800926:	ff d6                	call   *%esi
			break;
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	e9 7a ff ff ff       	jmp    8008aa <vprintfmt+0x3d5>
			putch('%', putdat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	53                   	push   %ebx
  800934:	6a 25                	push   $0x25
  800936:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800938:	83 c4 10             	add    $0x10,%esp
  80093b:	89 f8                	mov    %edi,%eax
  80093d:	eb 03                	jmp    800942 <vprintfmt+0x46d>
  80093f:	83 e8 01             	sub    $0x1,%eax
  800942:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800946:	75 f7                	jne    80093f <vprintfmt+0x46a>
  800948:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094b:	e9 5a ff ff ff       	jmp    8008aa <vprintfmt+0x3d5>
}
  800950:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 18             	sub    $0x18,%esp
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800964:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800967:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80096e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800975:	85 c0                	test   %eax,%eax
  800977:	74 26                	je     80099f <vsnprintf+0x47>
  800979:	85 d2                	test   %edx,%edx
  80097b:	7e 22                	jle    80099f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80097d:	ff 75 14             	pushl  0x14(%ebp)
  800980:	ff 75 10             	pushl  0x10(%ebp)
  800983:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800986:	50                   	push   %eax
  800987:	68 9b 04 80 00       	push   $0x80049b
  80098c:	e8 44 fb ff ff       	call   8004d5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800991:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800994:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099a:	83 c4 10             	add    $0x10,%esp
}
  80099d:	c9                   	leave  
  80099e:	c3                   	ret    
		return -E_INVAL;
  80099f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a4:	eb f7                	jmp    80099d <vsnprintf+0x45>

008009a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ac:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009af:	50                   	push   %eax
  8009b0:	ff 75 10             	pushl  0x10(%ebp)
  8009b3:	ff 75 0c             	pushl  0xc(%ebp)
  8009b6:	ff 75 08             	pushl  0x8(%ebp)
  8009b9:	e8 9a ff ff ff       	call   800958 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cb:	eb 03                	jmp    8009d0 <strlen+0x10>
		n++;
  8009cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009d0:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d4:	75 f7                	jne    8009cd <strlen+0xd>
	return n;
}
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009de:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e6:	eb 03                	jmp    8009eb <strnlen+0x13>
		n++;
  8009e8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009eb:	39 d0                	cmp    %edx,%eax
  8009ed:	74 06                	je     8009f5 <strnlen+0x1d>
  8009ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009f3:	75 f3                	jne    8009e8 <strnlen+0x10>
	return n;
}
  8009f5:	5d                   	pop    %ebp
  8009f6:	c3                   	ret    

008009f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a01:	89 c2                	mov    %eax,%edx
  800a03:	83 c1 01             	add    $0x1,%ecx
  800a06:	83 c2 01             	add    $0x1,%edx
  800a09:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a0d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a10:	84 db                	test   %bl,%bl
  800a12:	75 ef                	jne    800a03 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a14:	5b                   	pop    %ebx
  800a15:	5d                   	pop    %ebp
  800a16:	c3                   	ret    

00800a17 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	53                   	push   %ebx
  800a1b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a1e:	53                   	push   %ebx
  800a1f:	e8 9c ff ff ff       	call   8009c0 <strlen>
  800a24:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a27:	ff 75 0c             	pushl  0xc(%ebp)
  800a2a:	01 d8                	add    %ebx,%eax
  800a2c:	50                   	push   %eax
  800a2d:	e8 c5 ff ff ff       	call   8009f7 <strcpy>
	return dst;
}
  800a32:	89 d8                	mov    %ebx,%eax
  800a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a44:	89 f3                	mov    %esi,%ebx
  800a46:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a49:	89 f2                	mov    %esi,%edx
  800a4b:	eb 0f                	jmp    800a5c <strncpy+0x23>
		*dst++ = *src;
  800a4d:	83 c2 01             	add    $0x1,%edx
  800a50:	0f b6 01             	movzbl (%ecx),%eax
  800a53:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a56:	80 39 01             	cmpb   $0x1,(%ecx)
  800a59:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a5c:	39 da                	cmp    %ebx,%edx
  800a5e:	75 ed                	jne    800a4d <strncpy+0x14>
	}
	return ret;
}
  800a60:	89 f0                	mov    %esi,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	56                   	push   %esi
  800a6a:	53                   	push   %ebx
  800a6b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a71:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a74:	89 f0                	mov    %esi,%eax
  800a76:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a7a:	85 c9                	test   %ecx,%ecx
  800a7c:	75 0b                	jne    800a89 <strlcpy+0x23>
  800a7e:	eb 17                	jmp    800a97 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a80:	83 c2 01             	add    $0x1,%edx
  800a83:	83 c0 01             	add    $0x1,%eax
  800a86:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a89:	39 d8                	cmp    %ebx,%eax
  800a8b:	74 07                	je     800a94 <strlcpy+0x2e>
  800a8d:	0f b6 0a             	movzbl (%edx),%ecx
  800a90:	84 c9                	test   %cl,%cl
  800a92:	75 ec                	jne    800a80 <strlcpy+0x1a>
		*dst = '\0';
  800a94:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a97:	29 f0                	sub    %esi,%eax
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    

00800a9d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa6:	eb 06                	jmp    800aae <strcmp+0x11>
		p++, q++;
  800aa8:	83 c1 01             	add    $0x1,%ecx
  800aab:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aae:	0f b6 01             	movzbl (%ecx),%eax
  800ab1:	84 c0                	test   %al,%al
  800ab3:	74 04                	je     800ab9 <strcmp+0x1c>
  800ab5:	3a 02                	cmp    (%edx),%al
  800ab7:	74 ef                	je     800aa8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab9:	0f b6 c0             	movzbl %al,%eax
  800abc:	0f b6 12             	movzbl (%edx),%edx
  800abf:	29 d0                	sub    %edx,%eax
}
  800ac1:	5d                   	pop    %ebp
  800ac2:	c3                   	ret    

00800ac3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad2:	eb 06                	jmp    800ada <strncmp+0x17>
		n--, p++, q++;
  800ad4:	83 c0 01             	add    $0x1,%eax
  800ad7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ada:	39 d8                	cmp    %ebx,%eax
  800adc:	74 16                	je     800af4 <strncmp+0x31>
  800ade:	0f b6 08             	movzbl (%eax),%ecx
  800ae1:	84 c9                	test   %cl,%cl
  800ae3:	74 04                	je     800ae9 <strncmp+0x26>
  800ae5:	3a 0a                	cmp    (%edx),%cl
  800ae7:	74 eb                	je     800ad4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae9:	0f b6 00             	movzbl (%eax),%eax
  800aec:	0f b6 12             	movzbl (%edx),%edx
  800aef:	29 d0                	sub    %edx,%eax
}
  800af1:	5b                   	pop    %ebx
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    
		return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	eb f6                	jmp    800af1 <strncmp+0x2e>

00800afb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b05:	0f b6 10             	movzbl (%eax),%edx
  800b08:	84 d2                	test   %dl,%dl
  800b0a:	74 09                	je     800b15 <strchr+0x1a>
		if (*s == c)
  800b0c:	38 ca                	cmp    %cl,%dl
  800b0e:	74 0a                	je     800b1a <strchr+0x1f>
	for (; *s; s++)
  800b10:	83 c0 01             	add    $0x1,%eax
  800b13:	eb f0                	jmp    800b05 <strchr+0xa>
			return (char *) s;
	return 0;
  800b15:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b26:	eb 03                	jmp    800b2b <strfind+0xf>
  800b28:	83 c0 01             	add    $0x1,%eax
  800b2b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b2e:	38 ca                	cmp    %cl,%dl
  800b30:	74 04                	je     800b36 <strfind+0x1a>
  800b32:	84 d2                	test   %dl,%dl
  800b34:	75 f2                	jne    800b28 <strfind+0xc>
			break;
	return (char *) s;
}
  800b36:	5d                   	pop    %ebp
  800b37:	c3                   	ret    

00800b38 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	57                   	push   %edi
  800b3c:	56                   	push   %esi
  800b3d:	53                   	push   %ebx
  800b3e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b41:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b44:	85 c9                	test   %ecx,%ecx
  800b46:	74 13                	je     800b5b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b48:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4e:	75 05                	jne    800b55 <memset+0x1d>
  800b50:	f6 c1 03             	test   $0x3,%cl
  800b53:	74 0d                	je     800b62 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	fc                   	cld    
  800b59:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5b:	89 f8                	mov    %edi,%eax
  800b5d:	5b                   	pop    %ebx
  800b5e:	5e                   	pop    %esi
  800b5f:	5f                   	pop    %edi
  800b60:	5d                   	pop    %ebp
  800b61:	c3                   	ret    
		c &= 0xFF;
  800b62:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b66:	89 d3                	mov    %edx,%ebx
  800b68:	c1 e3 08             	shl    $0x8,%ebx
  800b6b:	89 d0                	mov    %edx,%eax
  800b6d:	c1 e0 18             	shl    $0x18,%eax
  800b70:	89 d6                	mov    %edx,%esi
  800b72:	c1 e6 10             	shl    $0x10,%esi
  800b75:	09 f0                	or     %esi,%eax
  800b77:	09 c2                	or     %eax,%edx
  800b79:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b7e:	89 d0                	mov    %edx,%eax
  800b80:	fc                   	cld    
  800b81:	f3 ab                	rep stos %eax,%es:(%edi)
  800b83:	eb d6                	jmp    800b5b <memset+0x23>

00800b85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	57                   	push   %edi
  800b89:	56                   	push   %esi
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b90:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b93:	39 c6                	cmp    %eax,%esi
  800b95:	73 35                	jae    800bcc <memmove+0x47>
  800b97:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9a:	39 c2                	cmp    %eax,%edx
  800b9c:	76 2e                	jbe    800bcc <memmove+0x47>
		s += n;
		d += n;
  800b9e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba1:	89 d6                	mov    %edx,%esi
  800ba3:	09 fe                	or     %edi,%esi
  800ba5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bab:	74 0c                	je     800bb9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bad:	83 ef 01             	sub    $0x1,%edi
  800bb0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bb3:	fd                   	std    
  800bb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb6:	fc                   	cld    
  800bb7:	eb 21                	jmp    800bda <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb9:	f6 c1 03             	test   $0x3,%cl
  800bbc:	75 ef                	jne    800bad <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bbe:	83 ef 04             	sub    $0x4,%edi
  800bc1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bc7:	fd                   	std    
  800bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bca:	eb ea                	jmp    800bb6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	09 c2                	or     %eax,%edx
  800bd0:	f6 c2 03             	test   $0x3,%dl
  800bd3:	74 09                	je     800bde <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd5:	89 c7                	mov    %eax,%edi
  800bd7:	fc                   	cld    
  800bd8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bde:	f6 c1 03             	test   $0x3,%cl
  800be1:	75 f2                	jne    800bd5 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	fc                   	cld    
  800be9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800beb:	eb ed                	jmp    800bda <memmove+0x55>

00800bed <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf0:	ff 75 10             	pushl  0x10(%ebp)
  800bf3:	ff 75 0c             	pushl  0xc(%ebp)
  800bf6:	ff 75 08             	pushl  0x8(%ebp)
  800bf9:	e8 87 ff ff ff       	call   800b85 <memmove>
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c10:	39 f0                	cmp    %esi,%eax
  800c12:	74 1c                	je     800c30 <memcmp+0x30>
		if (*s1 != *s2)
  800c14:	0f b6 08             	movzbl (%eax),%ecx
  800c17:	0f b6 1a             	movzbl (%edx),%ebx
  800c1a:	38 d9                	cmp    %bl,%cl
  800c1c:	75 08                	jne    800c26 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c1e:	83 c0 01             	add    $0x1,%eax
  800c21:	83 c2 01             	add    $0x1,%edx
  800c24:	eb ea                	jmp    800c10 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c26:	0f b6 c1             	movzbl %cl,%eax
  800c29:	0f b6 db             	movzbl %bl,%ebx
  800c2c:	29 d8                	sub    %ebx,%eax
  800c2e:	eb 05                	jmp    800c35 <memcmp+0x35>
	}

	return 0;
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c42:	89 c2                	mov    %eax,%edx
  800c44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c47:	39 d0                	cmp    %edx,%eax
  800c49:	73 09                	jae    800c54 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4b:	38 08                	cmp    %cl,(%eax)
  800c4d:	74 05                	je     800c54 <memfind+0x1b>
	for (; s < ends; s++)
  800c4f:	83 c0 01             	add    $0x1,%eax
  800c52:	eb f3                	jmp    800c47 <memfind+0xe>
			break;
	return (void *) s;
}
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c62:	eb 03                	jmp    800c67 <strtol+0x11>
		s++;
  800c64:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c67:	0f b6 01             	movzbl (%ecx),%eax
  800c6a:	3c 20                	cmp    $0x20,%al
  800c6c:	74 f6                	je     800c64 <strtol+0xe>
  800c6e:	3c 09                	cmp    $0x9,%al
  800c70:	74 f2                	je     800c64 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c72:	3c 2b                	cmp    $0x2b,%al
  800c74:	74 2e                	je     800ca4 <strtol+0x4e>
	int neg = 0;
  800c76:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c7b:	3c 2d                	cmp    $0x2d,%al
  800c7d:	74 2f                	je     800cae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c85:	75 05                	jne    800c8c <strtol+0x36>
  800c87:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8a:	74 2c                	je     800cb8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8c:	85 db                	test   %ebx,%ebx
  800c8e:	75 0a                	jne    800c9a <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c90:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c95:	80 39 30             	cmpb   $0x30,(%ecx)
  800c98:	74 28                	je     800cc2 <strtol+0x6c>
		base = 10;
  800c9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ca2:	eb 50                	jmp    800cf4 <strtol+0x9e>
		s++;
  800ca4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ca7:	bf 00 00 00 00       	mov    $0x0,%edi
  800cac:	eb d1                	jmp    800c7f <strtol+0x29>
		s++, neg = 1;
  800cae:	83 c1 01             	add    $0x1,%ecx
  800cb1:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb6:	eb c7                	jmp    800c7f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cbc:	74 0e                	je     800ccc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cbe:	85 db                	test   %ebx,%ebx
  800cc0:	75 d8                	jne    800c9a <strtol+0x44>
		s++, base = 8;
  800cc2:	83 c1 01             	add    $0x1,%ecx
  800cc5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cca:	eb ce                	jmp    800c9a <strtol+0x44>
		s += 2, base = 16;
  800ccc:	83 c1 02             	add    $0x2,%ecx
  800ccf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd4:	eb c4                	jmp    800c9a <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cd6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cd9:	89 f3                	mov    %esi,%ebx
  800cdb:	80 fb 19             	cmp    $0x19,%bl
  800cde:	77 29                	ja     800d09 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ce0:	0f be d2             	movsbl %dl,%edx
  800ce3:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ce6:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce9:	7d 30                	jge    800d1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ceb:	83 c1 01             	add    $0x1,%ecx
  800cee:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cf4:	0f b6 11             	movzbl (%ecx),%edx
  800cf7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cfa:	89 f3                	mov    %esi,%ebx
  800cfc:	80 fb 09             	cmp    $0x9,%bl
  800cff:	77 d5                	ja     800cd6 <strtol+0x80>
			dig = *s - '0';
  800d01:	0f be d2             	movsbl %dl,%edx
  800d04:	83 ea 30             	sub    $0x30,%edx
  800d07:	eb dd                	jmp    800ce6 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d09:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d0c:	89 f3                	mov    %esi,%ebx
  800d0e:	80 fb 19             	cmp    $0x19,%bl
  800d11:	77 08                	ja     800d1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d13:	0f be d2             	movsbl %dl,%edx
  800d16:	83 ea 37             	sub    $0x37,%edx
  800d19:	eb cb                	jmp    800ce6 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d1f:	74 05                	je     800d26 <strtol+0xd0>
		*endptr = (char *) s;
  800d21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d26:	89 c2                	mov    %eax,%edx
  800d28:	f7 da                	neg    %edx
  800d2a:	85 ff                	test   %edi,%edi
  800d2c:	0f 45 c2             	cmovne %edx,%eax
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    
  800d34:	66 90                	xchg   %ax,%ax
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__udivdi3>:
  800d40:	55                   	push   %ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
  800d47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800d4b:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d53:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d57:	85 d2                	test   %edx,%edx
  800d59:	75 35                	jne    800d90 <__udivdi3+0x50>
  800d5b:	39 f3                	cmp    %esi,%ebx
  800d5d:	0f 87 bd 00 00 00    	ja     800e20 <__udivdi3+0xe0>
  800d63:	85 db                	test   %ebx,%ebx
  800d65:	89 d9                	mov    %ebx,%ecx
  800d67:	75 0b                	jne    800d74 <__udivdi3+0x34>
  800d69:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6e:	31 d2                	xor    %edx,%edx
  800d70:	f7 f3                	div    %ebx
  800d72:	89 c1                	mov    %eax,%ecx
  800d74:	31 d2                	xor    %edx,%edx
  800d76:	89 f0                	mov    %esi,%eax
  800d78:	f7 f1                	div    %ecx
  800d7a:	89 c6                	mov    %eax,%esi
  800d7c:	89 e8                	mov    %ebp,%eax
  800d7e:	89 f7                	mov    %esi,%edi
  800d80:	f7 f1                	div    %ecx
  800d82:	89 fa                	mov    %edi,%edx
  800d84:	83 c4 1c             	add    $0x1c,%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    
  800d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d90:	39 f2                	cmp    %esi,%edx
  800d92:	77 7c                	ja     800e10 <__udivdi3+0xd0>
  800d94:	0f bd fa             	bsr    %edx,%edi
  800d97:	83 f7 1f             	xor    $0x1f,%edi
  800d9a:	0f 84 98 00 00 00    	je     800e38 <__udivdi3+0xf8>
  800da0:	89 f9                	mov    %edi,%ecx
  800da2:	b8 20 00 00 00       	mov    $0x20,%eax
  800da7:	29 f8                	sub    %edi,%eax
  800da9:	d3 e2                	shl    %cl,%edx
  800dab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	89 da                	mov    %ebx,%edx
  800db3:	d3 ea                	shr    %cl,%edx
  800db5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800db9:	09 d1                	or     %edx,%ecx
  800dbb:	89 f2                	mov    %esi,%edx
  800dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	d3 e3                	shl    %cl,%ebx
  800dc5:	89 c1                	mov    %eax,%ecx
  800dc7:	d3 ea                	shr    %cl,%edx
  800dc9:	89 f9                	mov    %edi,%ecx
  800dcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dcf:	d3 e6                	shl    %cl,%esi
  800dd1:	89 eb                	mov    %ebp,%ebx
  800dd3:	89 c1                	mov    %eax,%ecx
  800dd5:	d3 eb                	shr    %cl,%ebx
  800dd7:	09 de                	or     %ebx,%esi
  800dd9:	89 f0                	mov    %esi,%eax
  800ddb:	f7 74 24 08          	divl   0x8(%esp)
  800ddf:	89 d6                	mov    %edx,%esi
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	f7 64 24 0c          	mull   0xc(%esp)
  800de7:	39 d6                	cmp    %edx,%esi
  800de9:	72 0c                	jb     800df7 <__udivdi3+0xb7>
  800deb:	89 f9                	mov    %edi,%ecx
  800ded:	d3 e5                	shl    %cl,%ebp
  800def:	39 c5                	cmp    %eax,%ebp
  800df1:	73 5d                	jae    800e50 <__udivdi3+0x110>
  800df3:	39 d6                	cmp    %edx,%esi
  800df5:	75 59                	jne    800e50 <__udivdi3+0x110>
  800df7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dfa:	31 ff                	xor    %edi,%edi
  800dfc:	89 fa                	mov    %edi,%edx
  800dfe:	83 c4 1c             	add    $0x1c,%esp
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5f                   	pop    %edi
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    
  800e06:	8d 76 00             	lea    0x0(%esi),%esi
  800e09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800e10:	31 ff                	xor    %edi,%edi
  800e12:	31 c0                	xor    %eax,%eax
  800e14:	89 fa                	mov    %edi,%edx
  800e16:	83 c4 1c             	add    $0x1c,%esp
  800e19:	5b                   	pop    %ebx
  800e1a:	5e                   	pop    %esi
  800e1b:	5f                   	pop    %edi
  800e1c:	5d                   	pop    %ebp
  800e1d:	c3                   	ret    
  800e1e:	66 90                	xchg   %ax,%ax
  800e20:	31 ff                	xor    %edi,%edi
  800e22:	89 e8                	mov    %ebp,%eax
  800e24:	89 f2                	mov    %esi,%edx
  800e26:	f7 f3                	div    %ebx
  800e28:	89 fa                	mov    %edi,%edx
  800e2a:	83 c4 1c             	add    $0x1c,%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    
  800e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	72 06                	jb     800e42 <__udivdi3+0x102>
  800e3c:	31 c0                	xor    %eax,%eax
  800e3e:	39 eb                	cmp    %ebp,%ebx
  800e40:	77 d2                	ja     800e14 <__udivdi3+0xd4>
  800e42:	b8 01 00 00 00       	mov    $0x1,%eax
  800e47:	eb cb                	jmp    800e14 <__udivdi3+0xd4>
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 d8                	mov    %ebx,%eax
  800e52:	31 ff                	xor    %edi,%edi
  800e54:	eb be                	jmp    800e14 <__udivdi3+0xd4>
  800e56:	66 90                	xchg   %ax,%ax
  800e58:	66 90                	xchg   %ax,%ax
  800e5a:	66 90                	xchg   %ax,%ax
  800e5c:	66 90                	xchg   %ax,%ax
  800e5e:	66 90                	xchg   %ax,%ax

00800e60 <__umoddi3>:
  800e60:	55                   	push   %ebp
  800e61:	57                   	push   %edi
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	83 ec 1c             	sub    $0x1c,%esp
  800e67:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800e6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e77:	85 ed                	test   %ebp,%ebp
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	89 da                	mov    %ebx,%edx
  800e7d:	75 19                	jne    800e98 <__umoddi3+0x38>
  800e7f:	39 df                	cmp    %ebx,%edi
  800e81:	0f 86 b1 00 00 00    	jbe    800f38 <__umoddi3+0xd8>
  800e87:	f7 f7                	div    %edi
  800e89:	89 d0                	mov    %edx,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	83 c4 1c             	add    $0x1c,%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    
  800e95:	8d 76 00             	lea    0x0(%esi),%esi
  800e98:	39 dd                	cmp    %ebx,%ebp
  800e9a:	77 f1                	ja     800e8d <__umoddi3+0x2d>
  800e9c:	0f bd cd             	bsr    %ebp,%ecx
  800e9f:	83 f1 1f             	xor    $0x1f,%ecx
  800ea2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ea6:	0f 84 b4 00 00 00    	je     800f60 <__umoddi3+0x100>
  800eac:	b8 20 00 00 00       	mov    $0x20,%eax
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eb7:	29 c2                	sub    %eax,%edx
  800eb9:	89 c1                	mov    %eax,%ecx
  800ebb:	89 f8                	mov    %edi,%eax
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	89 d1                	mov    %edx,%ecx
  800ec1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ec5:	d3 e8                	shr    %cl,%eax
  800ec7:	09 c5                	or     %eax,%ebp
  800ec9:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ecd:	89 c1                	mov    %eax,%ecx
  800ecf:	d3 e7                	shl    %cl,%edi
  800ed1:	89 d1                	mov    %edx,%ecx
  800ed3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ed7:	89 df                	mov    %ebx,%edi
  800ed9:	d3 ef                	shr    %cl,%edi
  800edb:	89 c1                	mov    %eax,%ecx
  800edd:	89 f0                	mov    %esi,%eax
  800edf:	d3 e3                	shl    %cl,%ebx
  800ee1:	89 d1                	mov    %edx,%ecx
  800ee3:	89 fa                	mov    %edi,%edx
  800ee5:	d3 e8                	shr    %cl,%eax
  800ee7:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800eec:	09 d8                	or     %ebx,%eax
  800eee:	f7 f5                	div    %ebp
  800ef0:	d3 e6                	shl    %cl,%esi
  800ef2:	89 d1                	mov    %edx,%ecx
  800ef4:	f7 64 24 08          	mull   0x8(%esp)
  800ef8:	39 d1                	cmp    %edx,%ecx
  800efa:	89 c3                	mov    %eax,%ebx
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	72 06                	jb     800f06 <__umoddi3+0xa6>
  800f00:	75 0e                	jne    800f10 <__umoddi3+0xb0>
  800f02:	39 c6                	cmp    %eax,%esi
  800f04:	73 0a                	jae    800f10 <__umoddi3+0xb0>
  800f06:	2b 44 24 08          	sub    0x8(%esp),%eax
  800f0a:	19 ea                	sbb    %ebp,%edx
  800f0c:	89 d7                	mov    %edx,%edi
  800f0e:	89 c3                	mov    %eax,%ebx
  800f10:	89 ca                	mov    %ecx,%edx
  800f12:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f17:	29 de                	sub    %ebx,%esi
  800f19:	19 fa                	sbb    %edi,%edx
  800f1b:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800f1f:	89 d0                	mov    %edx,%eax
  800f21:	d3 e0                	shl    %cl,%eax
  800f23:	89 d9                	mov    %ebx,%ecx
  800f25:	d3 ee                	shr    %cl,%esi
  800f27:	d3 ea                	shr    %cl,%edx
  800f29:	09 f0                	or     %esi,%eax
  800f2b:	83 c4 1c             	add    $0x1c,%esp
  800f2e:	5b                   	pop    %ebx
  800f2f:	5e                   	pop    %esi
  800f30:	5f                   	pop    %edi
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    
  800f33:	90                   	nop
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	85 ff                	test   %edi,%edi
  800f3a:	89 f9                	mov    %edi,%ecx
  800f3c:	75 0b                	jne    800f49 <__umoddi3+0xe9>
  800f3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f7                	div    %edi
  800f47:	89 c1                	mov    %eax,%ecx
  800f49:	89 d8                	mov    %ebx,%eax
  800f4b:	31 d2                	xor    %edx,%edx
  800f4d:	f7 f1                	div    %ecx
  800f4f:	89 f0                	mov    %esi,%eax
  800f51:	f7 f1                	div    %ecx
  800f53:	e9 31 ff ff ff       	jmp    800e89 <__umoddi3+0x29>
  800f58:	90                   	nop
  800f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f60:	39 dd                	cmp    %ebx,%ebp
  800f62:	72 08                	jb     800f6c <__umoddi3+0x10c>
  800f64:	39 f7                	cmp    %esi,%edi
  800f66:	0f 87 21 ff ff ff    	ja     800e8d <__umoddi3+0x2d>
  800f6c:	89 da                	mov    %ebx,%edx
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	29 f8                	sub    %edi,%eax
  800f72:	19 ea                	sbb    %ebp,%edx
  800f74:	e9 14 ff ff ff       	jmp    800e8d <__umoddi3+0x2d>
