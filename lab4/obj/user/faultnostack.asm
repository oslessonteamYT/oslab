
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 4a 10 80 00       	push   $0x80104a
  80011e:	6a 23                	push   $0x23
  800120:	68 67 10 80 00       	push   $0x801067
  800125:	e8 13 02 00 00       	call   80033d <_panic>

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 4a 10 80 00       	push   $0x80104a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 67 10 80 00       	push   $0x801067
  8001a6:	e8 92 01 00 00       	call   80033d <_panic>

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 4a 10 80 00       	push   $0x80104a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 67 10 80 00       	push   $0x801067
  8001e8:	e8 50 01 00 00       	call   80033d <_panic>

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 4a 10 80 00       	push   $0x80104a
  800223:	6a 23                	push   $0x23
  800225:	68 67 10 80 00       	push   $0x801067
  80022a:	e8 0e 01 00 00       	call   80033d <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 4a 10 80 00       	push   $0x80104a
  800265:	6a 23                	push   $0x23
  800267:	68 67 10 80 00       	push   $0x801067
  80026c:	e8 cc 00 00 00       	call   80033d <_panic>

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 4a 10 80 00       	push   $0x80104a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 67 10 80 00       	push   $0x801067
  8002ae:	e8 8a 00 00 00       	call   80033d <_panic>

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 4a 10 80 00       	push   $0x80104a
  80030b:	6a 23                	push   $0x23
  80030d:	68 67 10 80 00       	push   $0x801067
  800312:	e8 26 00 00 00       	call   80033d <_panic>

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800322:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800326:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800329:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 40(%esp), %ebx
  80032d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  800331:	89 18                	mov    %ebx,(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800333:	83 c4 08             	add    $0x8,%esp
	popal
  800336:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $0x4, %esp
  800337:	83 c4 04             	add    $0x4,%esp
	popfl
  80033a:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80033b:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  80033c:	c3                   	ret    

0080033d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800345:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034b:	e8 da fd ff ff       	call   80012a <sys_getenvid>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 0c             	pushl  0xc(%ebp)
  800356:	ff 75 08             	pushl  0x8(%ebp)
  800359:	56                   	push   %esi
  80035a:	50                   	push   %eax
  80035b:	68 78 10 80 00       	push   $0x801078
  800360:	e8 b3 00 00 00       	call   800418 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	53                   	push   %ebx
  800369:	ff 75 10             	pushl  0x10(%ebp)
  80036c:	e8 56 00 00 00       	call   8003c7 <vcprintf>
	cprintf("\n");
  800371:	c7 04 24 9b 10 80 00 	movl   $0x80109b,(%esp)
  800378:	e8 9b 00 00 00       	call   800418 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800380:	cc                   	int3   
  800381:	eb fd                	jmp    800380 <_panic+0x43>

00800383 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	53                   	push   %ebx
  800387:	83 ec 04             	sub    $0x4,%esp
  80038a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038d:	8b 13                	mov    (%ebx),%edx
  80038f:	8d 42 01             	lea    0x1(%edx),%eax
  800392:	89 03                	mov    %eax,(%ebx)
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a0:	74 09                	je     8003ab <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	68 ff 00 00 00       	push   $0xff
  8003b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b6:	50                   	push   %eax
  8003b7:	e8 f0 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	eb db                	jmp    8003a2 <putch+0x1f>

008003c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d7:	00 00 00 
	b.cnt = 0;
  8003da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e4:	ff 75 0c             	pushl  0xc(%ebp)
  8003e7:	ff 75 08             	pushl  0x8(%ebp)
  8003ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f0:	50                   	push   %eax
  8003f1:	68 83 03 80 00       	push   $0x800383
  8003f6:	e8 1a 01 00 00       	call   800515 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fb:	83 c4 08             	add    $0x8,%esp
  8003fe:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800404:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040a:	50                   	push   %eax
  80040b:	e8 9c fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800410:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800421:	50                   	push   %eax
  800422:	ff 75 08             	pushl  0x8(%ebp)
  800425:	e8 9d ff ff ff       	call   8003c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    

0080042c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 1c             	sub    $0x1c,%esp
  800435:	89 c7                	mov    %eax,%edi
  800437:	89 d6                	mov    %edx,%esi
  800439:	8b 45 08             	mov    0x8(%ebp),%eax
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800442:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800445:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800448:	bb 00 00 00 00       	mov    $0x0,%ebx
  80044d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800450:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800453:	39 d3                	cmp    %edx,%ebx
  800455:	72 05                	jb     80045c <printnum+0x30>
  800457:	39 45 10             	cmp    %eax,0x10(%ebp)
  80045a:	77 7a                	ja     8004d6 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80045c:	83 ec 0c             	sub    $0xc,%esp
  80045f:	ff 75 18             	pushl  0x18(%ebp)
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800468:	53                   	push   %ebx
  800469:	ff 75 10             	pushl  0x10(%ebp)
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800472:	ff 75 e0             	pushl  -0x20(%ebp)
  800475:	ff 75 dc             	pushl  -0x24(%ebp)
  800478:	ff 75 d8             	pushl  -0x28(%ebp)
  80047b:	e8 70 09 00 00       	call   800df0 <__udivdi3>
  800480:	83 c4 18             	add    $0x18,%esp
  800483:	52                   	push   %edx
  800484:	50                   	push   %eax
  800485:	89 f2                	mov    %esi,%edx
  800487:	89 f8                	mov    %edi,%eax
  800489:	e8 9e ff ff ff       	call   80042c <printnum>
  80048e:	83 c4 20             	add    $0x20,%esp
  800491:	eb 13                	jmp    8004a6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	56                   	push   %esi
  800497:	ff 75 18             	pushl  0x18(%ebp)
  80049a:	ff d7                	call   *%edi
  80049c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80049f:	83 eb 01             	sub    $0x1,%ebx
  8004a2:	85 db                	test   %ebx,%ebx
  8004a4:	7f ed                	jg     800493 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a6:	83 ec 08             	sub    $0x8,%esp
  8004a9:	56                   	push   %esi
  8004aa:	83 ec 04             	sub    $0x4,%esp
  8004ad:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8004b3:	ff 75 dc             	pushl  -0x24(%ebp)
  8004b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b9:	e8 52 0a 00 00       	call   800f10 <__umoddi3>
  8004be:	83 c4 14             	add    $0x14,%esp
  8004c1:	0f be 80 9d 10 80 00 	movsbl 0x80109d(%eax),%eax
  8004c8:	50                   	push   %eax
  8004c9:	ff d7                	call   *%edi
}
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d1:	5b                   	pop    %ebx
  8004d2:	5e                   	pop    %esi
  8004d3:	5f                   	pop    %edi
  8004d4:	5d                   	pop    %ebp
  8004d5:	c3                   	ret    
  8004d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004d9:	eb c4                	jmp    80049f <printnum+0x73>

008004db <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004db:	55                   	push   %ebp
  8004dc:	89 e5                	mov    %esp,%ebp
  8004de:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004e1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ea:	73 0a                	jae    8004f6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ec:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ef:	89 08                	mov    %ecx,(%eax)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	88 02                	mov    %al,(%edx)
}
  8004f6:	5d                   	pop    %ebp
  8004f7:	c3                   	ret    

008004f8 <printfmt>:
{
  8004f8:	55                   	push   %ebp
  8004f9:	89 e5                	mov    %esp,%ebp
  8004fb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004fe:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800501:	50                   	push   %eax
  800502:	ff 75 10             	pushl  0x10(%ebp)
  800505:	ff 75 0c             	pushl  0xc(%ebp)
  800508:	ff 75 08             	pushl  0x8(%ebp)
  80050b:	e8 05 00 00 00       	call   800515 <vprintfmt>
}
  800510:	83 c4 10             	add    $0x10,%esp
  800513:	c9                   	leave  
  800514:	c3                   	ret    

00800515 <vprintfmt>:
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	57                   	push   %edi
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	83 ec 2c             	sub    $0x2c,%esp
  80051e:	8b 75 08             	mov    0x8(%ebp),%esi
  800521:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800524:	8b 7d 10             	mov    0x10(%ebp),%edi
  800527:	e9 c1 03 00 00       	jmp    8008ed <vprintfmt+0x3d8>
		padc = ' ';
  80052c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800530:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  800537:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  80053e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800545:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8d 47 01             	lea    0x1(%edi),%eax
  80054d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800550:	0f b6 17             	movzbl (%edi),%edx
  800553:	8d 42 dd             	lea    -0x23(%edx),%eax
  800556:	3c 55                	cmp    $0x55,%al
  800558:	0f 87 12 04 00 00    	ja     800970 <vprintfmt+0x45b>
  80055e:	0f b6 c0             	movzbl %al,%eax
  800561:	ff 24 85 60 11 80 00 	jmp    *0x801160(,%eax,4)
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80056b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80056f:	eb d9                	jmp    80054a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800574:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800578:	eb d0                	jmp    80054a <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	0f b6 d2             	movzbl %dl,%edx
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800580:	b8 00 00 00 00       	mov    $0x0,%eax
  800585:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800588:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80058f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800592:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800595:	83 f9 09             	cmp    $0x9,%ecx
  800598:	77 55                	ja     8005ef <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80059a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80059d:	eb e9                	jmp    800588 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80059f:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a2:	8b 00                	mov    (%eax),%eax
  8005a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005aa:	8d 40 04             	lea    0x4(%eax),%eax
  8005ad:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005b3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005b7:	79 91                	jns    80054a <vprintfmt+0x35>
				width = precision, precision = -1;
  8005b9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005bf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005c6:	eb 82                	jmp    80054a <vprintfmt+0x35>
  8005c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8005d2:	0f 49 d0             	cmovns %eax,%edx
  8005d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005db:	e9 6a ff ff ff       	jmp    80054a <vprintfmt+0x35>
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005e3:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ea:	e9 5b ff ff ff       	jmp    80054a <vprintfmt+0x35>
  8005ef:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005f5:	eb bc                	jmp    8005b3 <vprintfmt+0x9e>
			lflag++;
  8005f7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005fd:	e9 48 ff ff ff       	jmp    80054a <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 78 04             	lea    0x4(%eax),%edi
  800608:	83 ec 08             	sub    $0x8,%esp
  80060b:	53                   	push   %ebx
  80060c:	ff 30                	pushl  (%eax)
  80060e:	ff d6                	call   *%esi
			break;
  800610:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800613:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800616:	e9 cf 02 00 00       	jmp    8008ea <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 78 04             	lea    0x4(%eax),%edi
  800621:	8b 00                	mov    (%eax),%eax
  800623:	99                   	cltd   
  800624:	31 d0                	xor    %edx,%eax
  800626:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800628:	83 f8 08             	cmp    $0x8,%eax
  80062b:	7f 23                	jg     800650 <vprintfmt+0x13b>
  80062d:	8b 14 85 c0 12 80 00 	mov    0x8012c0(,%eax,4),%edx
  800634:	85 d2                	test   %edx,%edx
  800636:	74 18                	je     800650 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  800638:	52                   	push   %edx
  800639:	68 be 10 80 00       	push   $0x8010be
  80063e:	53                   	push   %ebx
  80063f:	56                   	push   %esi
  800640:	e8 b3 fe ff ff       	call   8004f8 <printfmt>
  800645:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800648:	89 7d 14             	mov    %edi,0x14(%ebp)
  80064b:	e9 9a 02 00 00       	jmp    8008ea <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800650:	50                   	push   %eax
  800651:	68 b5 10 80 00       	push   $0x8010b5
  800656:	53                   	push   %ebx
  800657:	56                   	push   %esi
  800658:	e8 9b fe ff ff       	call   8004f8 <printfmt>
  80065d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800660:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800663:	e9 82 02 00 00       	jmp    8008ea <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800668:	8b 45 14             	mov    0x14(%ebp),%eax
  80066b:	83 c0 04             	add    $0x4,%eax
  80066e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800676:	85 ff                	test   %edi,%edi
  800678:	b8 ae 10 80 00       	mov    $0x8010ae,%eax
  80067d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800680:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800684:	0f 8e bd 00 00 00    	jle    800747 <vprintfmt+0x232>
  80068a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80068e:	75 0e                	jne    80069e <vprintfmt+0x189>
  800690:	89 75 08             	mov    %esi,0x8(%ebp)
  800693:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800696:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800699:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80069c:	eb 6d                	jmp    80070b <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	ff 75 d0             	pushl  -0x30(%ebp)
  8006a4:	57                   	push   %edi
  8006a5:	e8 6e 03 00 00       	call   800a18 <strnlen>
  8006aa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ad:	29 c1                	sub    %eax,%ecx
  8006af:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006b2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006b5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006bc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006bf:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c1:	eb 0f                	jmp    8006d2 <vprintfmt+0x1bd>
					putch(padc, putdat);
  8006c3:	83 ec 08             	sub    $0x8,%esp
  8006c6:	53                   	push   %ebx
  8006c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006ca:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cc:	83 ef 01             	sub    $0x1,%edi
  8006cf:	83 c4 10             	add    $0x10,%esp
  8006d2:	85 ff                	test   %edi,%edi
  8006d4:	7f ed                	jg     8006c3 <vprintfmt+0x1ae>
  8006d6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006d9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	0f 49 c1             	cmovns %ecx,%eax
  8006e6:	29 c1                	sub    %eax,%ecx
  8006e8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006eb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006f1:	89 cb                	mov    %ecx,%ebx
  8006f3:	eb 16                	jmp    80070b <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f9:	75 31                	jne    80072c <vprintfmt+0x217>
					putch(ch, putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	50                   	push   %eax
  800702:	ff 55 08             	call   *0x8(%ebp)
  800705:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800708:	83 eb 01             	sub    $0x1,%ebx
  80070b:	83 c7 01             	add    $0x1,%edi
  80070e:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  800712:	0f be c2             	movsbl %dl,%eax
  800715:	85 c0                	test   %eax,%eax
  800717:	74 59                	je     800772 <vprintfmt+0x25d>
  800719:	85 f6                	test   %esi,%esi
  80071b:	78 d8                	js     8006f5 <vprintfmt+0x1e0>
  80071d:	83 ee 01             	sub    $0x1,%esi
  800720:	79 d3                	jns    8006f5 <vprintfmt+0x1e0>
  800722:	89 df                	mov    %ebx,%edi
  800724:	8b 75 08             	mov    0x8(%ebp),%esi
  800727:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80072a:	eb 37                	jmp    800763 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  80072c:	0f be d2             	movsbl %dl,%edx
  80072f:	83 ea 20             	sub    $0x20,%edx
  800732:	83 fa 5e             	cmp    $0x5e,%edx
  800735:	76 c4                	jbe    8006fb <vprintfmt+0x1e6>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	6a 3f                	push   $0x3f
  80073f:	ff 55 08             	call   *0x8(%ebp)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	eb c1                	jmp    800708 <vprintfmt+0x1f3>
  800747:	89 75 08             	mov    %esi,0x8(%ebp)
  80074a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80074d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800750:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800753:	eb b6                	jmp    80070b <vprintfmt+0x1f6>
				putch(' ', putdat);
  800755:	83 ec 08             	sub    $0x8,%esp
  800758:	53                   	push   %ebx
  800759:	6a 20                	push   $0x20
  80075b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80075d:	83 ef 01             	sub    $0x1,%edi
  800760:	83 c4 10             	add    $0x10,%esp
  800763:	85 ff                	test   %edi,%edi
  800765:	7f ee                	jg     800755 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800767:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
  80076d:	e9 78 01 00 00       	jmp    8008ea <vprintfmt+0x3d5>
  800772:	89 df                	mov    %ebx,%edi
  800774:	8b 75 08             	mov    0x8(%ebp),%esi
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077a:	eb e7                	jmp    800763 <vprintfmt+0x24e>
	if (lflag >= 2)
  80077c:	83 f9 01             	cmp    $0x1,%ecx
  80077f:	7e 3f                	jle    8007c0 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800781:	8b 45 14             	mov    0x14(%ebp),%eax
  800784:	8b 50 04             	mov    0x4(%eax),%edx
  800787:	8b 00                	mov    (%eax),%eax
  800789:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80078f:	8b 45 14             	mov    0x14(%ebp),%eax
  800792:	8d 40 08             	lea    0x8(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800798:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80079c:	79 5c                	jns    8007fa <vprintfmt+0x2e5>
				putch('-', putdat);
  80079e:	83 ec 08             	sub    $0x8,%esp
  8007a1:	53                   	push   %ebx
  8007a2:	6a 2d                	push   $0x2d
  8007a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ac:	f7 da                	neg    %edx
  8007ae:	83 d1 00             	adc    $0x0,%ecx
  8007b1:	f7 d9                	neg    %ecx
  8007b3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007b6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007bb:	e9 10 01 00 00       	jmp    8008d0 <vprintfmt+0x3bb>
	else if (lflag)
  8007c0:	85 c9                	test   %ecx,%ecx
  8007c2:	75 1b                	jne    8007df <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8b 00                	mov    (%eax),%eax
  8007c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cc:	89 c1                	mov    %eax,%ecx
  8007ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 40 04             	lea    0x4(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
  8007dd:	eb b9                	jmp    800798 <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8b 00                	mov    (%eax),%eax
  8007e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e7:	89 c1                	mov    %eax,%ecx
  8007e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
  8007f8:	eb 9e                	jmp    800798 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800800:	b8 0a 00 00 00       	mov    $0xa,%eax
  800805:	e9 c6 00 00 00       	jmp    8008d0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80080a:	83 f9 01             	cmp    $0x1,%ecx
  80080d:	7e 18                	jle    800827 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8b 10                	mov    (%eax),%edx
  800814:	8b 48 04             	mov    0x4(%eax),%ecx
  800817:	8d 40 08             	lea    0x8(%eax),%eax
  80081a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800822:	e9 a9 00 00 00       	jmp    8008d0 <vprintfmt+0x3bb>
	else if (lflag)
  800827:	85 c9                	test   %ecx,%ecx
  800829:	75 1a                	jne    800845 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  80082b:	8b 45 14             	mov    0x14(%ebp),%eax
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	b9 00 00 00 00       	mov    $0x0,%ecx
  800835:	8d 40 04             	lea    0x4(%eax),%eax
  800838:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800840:	e9 8b 00 00 00       	jmp    8008d0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084f:	8d 40 04             	lea    0x4(%eax),%eax
  800852:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800855:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085a:	eb 74                	jmp    8008d0 <vprintfmt+0x3bb>
	if (lflag >= 2)
  80085c:	83 f9 01             	cmp    $0x1,%ecx
  80085f:	7e 15                	jle    800876 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8b 10                	mov    (%eax),%edx
  800866:	8b 48 04             	mov    0x4(%eax),%ecx
  800869:	8d 40 08             	lea    0x8(%eax),%eax
  80086c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80086f:	b8 08 00 00 00       	mov    $0x8,%eax
  800874:	eb 5a                	jmp    8008d0 <vprintfmt+0x3bb>
	else if (lflag)
  800876:	85 c9                	test   %ecx,%ecx
  800878:	75 17                	jne    800891 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8b 10                	mov    (%eax),%edx
  80087f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800884:	8d 40 04             	lea    0x4(%eax),%eax
  800887:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80088a:	b8 08 00 00 00       	mov    $0x8,%eax
  80088f:	eb 3f                	jmp    8008d0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800891:	8b 45 14             	mov    0x14(%ebp),%eax
  800894:	8b 10                	mov    (%eax),%edx
  800896:	b9 00 00 00 00       	mov    $0x0,%ecx
  80089b:	8d 40 04             	lea    0x4(%eax),%eax
  80089e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8008a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8008a6:	eb 28                	jmp    8008d0 <vprintfmt+0x3bb>
			putch('0', putdat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	6a 30                	push   $0x30
  8008ae:	ff d6                	call   *%esi
			putch('x', putdat);
  8008b0:	83 c4 08             	add    $0x8,%esp
  8008b3:	53                   	push   %ebx
  8008b4:	6a 78                	push   $0x78
  8008b6:	ff d6                	call   *%esi
			num = (unsigned long long)
  8008b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bb:	8b 10                	mov    (%eax),%edx
  8008bd:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008c2:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008c5:	8d 40 04             	lea    0x4(%eax),%eax
  8008c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008cb:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008d0:	83 ec 0c             	sub    $0xc,%esp
  8008d3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008d7:	57                   	push   %edi
  8008d8:	ff 75 e0             	pushl  -0x20(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	51                   	push   %ecx
  8008dd:	52                   	push   %edx
  8008de:	89 da                	mov    %ebx,%edx
  8008e0:	89 f0                	mov    %esi,%eax
  8008e2:	e8 45 fb ff ff       	call   80042c <printnum>
			break;
  8008e7:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ed:	83 c7 01             	add    $0x1,%edi
  8008f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008f4:	83 f8 25             	cmp    $0x25,%eax
  8008f7:	0f 84 2f fc ff ff    	je     80052c <vprintfmt+0x17>
			if (ch == '\0')
  8008fd:	85 c0                	test   %eax,%eax
  8008ff:	0f 84 8b 00 00 00    	je     800990 <vprintfmt+0x47b>
			putch(ch, putdat);
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	53                   	push   %ebx
  800909:	50                   	push   %eax
  80090a:	ff d6                	call   *%esi
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	eb dc                	jmp    8008ed <vprintfmt+0x3d8>
	if (lflag >= 2)
  800911:	83 f9 01             	cmp    $0x1,%ecx
  800914:	7e 15                	jle    80092b <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  800916:	8b 45 14             	mov    0x14(%ebp),%eax
  800919:	8b 10                	mov    (%eax),%edx
  80091b:	8b 48 04             	mov    0x4(%eax),%ecx
  80091e:	8d 40 08             	lea    0x8(%eax),%eax
  800921:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800924:	b8 10 00 00 00       	mov    $0x10,%eax
  800929:	eb a5                	jmp    8008d0 <vprintfmt+0x3bb>
	else if (lflag)
  80092b:	85 c9                	test   %ecx,%ecx
  80092d:	75 17                	jne    800946 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  80092f:	8b 45 14             	mov    0x14(%ebp),%eax
  800932:	8b 10                	mov    (%eax),%edx
  800934:	b9 00 00 00 00       	mov    $0x0,%ecx
  800939:	8d 40 04             	lea    0x4(%eax),%eax
  80093c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80093f:	b8 10 00 00 00       	mov    $0x10,%eax
  800944:	eb 8a                	jmp    8008d0 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800946:	8b 45 14             	mov    0x14(%ebp),%eax
  800949:	8b 10                	mov    (%eax),%edx
  80094b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800950:	8d 40 04             	lea    0x4(%eax),%eax
  800953:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800956:	b8 10 00 00 00       	mov    $0x10,%eax
  80095b:	e9 70 ff ff ff       	jmp    8008d0 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800960:	83 ec 08             	sub    $0x8,%esp
  800963:	53                   	push   %ebx
  800964:	6a 25                	push   $0x25
  800966:	ff d6                	call   *%esi
			break;
  800968:	83 c4 10             	add    $0x10,%esp
  80096b:	e9 7a ff ff ff       	jmp    8008ea <vprintfmt+0x3d5>
			putch('%', putdat);
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	6a 25                	push   $0x25
  800976:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	89 f8                	mov    %edi,%eax
  80097d:	eb 03                	jmp    800982 <vprintfmt+0x46d>
  80097f:	83 e8 01             	sub    $0x1,%eax
  800982:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800986:	75 f7                	jne    80097f <vprintfmt+0x46a>
  800988:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80098b:	e9 5a ff ff ff       	jmp    8008ea <vprintfmt+0x3d5>
}
  800990:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800993:	5b                   	pop    %ebx
  800994:	5e                   	pop    %esi
  800995:	5f                   	pop    %edi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	83 ec 18             	sub    $0x18,%esp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	74 26                	je     8009df <vsnprintf+0x47>
  8009b9:	85 d2                	test   %edx,%edx
  8009bb:	7e 22                	jle    8009df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009bd:	ff 75 14             	pushl  0x14(%ebp)
  8009c0:	ff 75 10             	pushl  0x10(%ebp)
  8009c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009c6:	50                   	push   %eax
  8009c7:	68 db 04 80 00       	push   $0x8004db
  8009cc:	e8 44 fb ff ff       	call   800515 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009da:	83 c4 10             	add    $0x10,%esp
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    
		return -E_INVAL;
  8009df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009e4:	eb f7                	jmp    8009dd <vsnprintf+0x45>

008009e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ef:	50                   	push   %eax
  8009f0:	ff 75 10             	pushl  0x10(%ebp)
  8009f3:	ff 75 0c             	pushl  0xc(%ebp)
  8009f6:	ff 75 08             	pushl  0x8(%ebp)
  8009f9:	e8 9a ff ff ff       	call   800998 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a06:	b8 00 00 00 00       	mov    $0x0,%eax
  800a0b:	eb 03                	jmp    800a10 <strlen+0x10>
		n++;
  800a0d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800a10:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a14:	75 f7                	jne    800a0d <strlen+0xd>
	return n;
}
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
  800a26:	eb 03                	jmp    800a2b <strnlen+0x13>
		n++;
  800a28:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a2b:	39 d0                	cmp    %edx,%eax
  800a2d:	74 06                	je     800a35 <strnlen+0x1d>
  800a2f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a33:	75 f3                	jne    800a28 <strnlen+0x10>
	return n;
}
  800a35:	5d                   	pop    %ebp
  800a36:	c3                   	ret    

00800a37 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a37:	55                   	push   %ebp
  800a38:	89 e5                	mov    %esp,%ebp
  800a3a:	53                   	push   %ebx
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a41:	89 c2                	mov    %eax,%edx
  800a43:	83 c1 01             	add    $0x1,%ecx
  800a46:	83 c2 01             	add    $0x1,%edx
  800a49:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a4d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a50:	84 db                	test   %bl,%bl
  800a52:	75 ef                	jne    800a43 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a54:	5b                   	pop    %ebx
  800a55:	5d                   	pop    %ebp
  800a56:	c3                   	ret    

00800a57 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a5e:	53                   	push   %ebx
  800a5f:	e8 9c ff ff ff       	call   800a00 <strlen>
  800a64:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a67:	ff 75 0c             	pushl  0xc(%ebp)
  800a6a:	01 d8                	add    %ebx,%eax
  800a6c:	50                   	push   %eax
  800a6d:	e8 c5 ff ff ff       	call   800a37 <strcpy>
	return dst;
}
  800a72:	89 d8                	mov    %ebx,%eax
  800a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800a81:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a84:	89 f3                	mov    %esi,%ebx
  800a86:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a89:	89 f2                	mov    %esi,%edx
  800a8b:	eb 0f                	jmp    800a9c <strncpy+0x23>
		*dst++ = *src;
  800a8d:	83 c2 01             	add    $0x1,%edx
  800a90:	0f b6 01             	movzbl (%ecx),%eax
  800a93:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a96:	80 39 01             	cmpb   $0x1,(%ecx)
  800a99:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a9c:	39 da                	cmp    %ebx,%edx
  800a9e:	75 ed                	jne    800a8d <strncpy+0x14>
	}
	return ret;
}
  800aa0:	89 f0                	mov    %esi,%eax
  800aa2:	5b                   	pop    %ebx
  800aa3:	5e                   	pop    %esi
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 75 08             	mov    0x8(%ebp),%esi
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ab4:	89 f0                	mov    %esi,%eax
  800ab6:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800aba:	85 c9                	test   %ecx,%ecx
  800abc:	75 0b                	jne    800ac9 <strlcpy+0x23>
  800abe:	eb 17                	jmp    800ad7 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ac0:	83 c2 01             	add    $0x1,%edx
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800ac9:	39 d8                	cmp    %ebx,%eax
  800acb:	74 07                	je     800ad4 <strlcpy+0x2e>
  800acd:	0f b6 0a             	movzbl (%edx),%ecx
  800ad0:	84 c9                	test   %cl,%cl
  800ad2:	75 ec                	jne    800ac0 <strlcpy+0x1a>
		*dst = '\0';
  800ad4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ad7:	29 f0                	sub    %esi,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ae6:	eb 06                	jmp    800aee <strcmp+0x11>
		p++, q++;
  800ae8:	83 c1 01             	add    $0x1,%ecx
  800aeb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aee:	0f b6 01             	movzbl (%ecx),%eax
  800af1:	84 c0                	test   %al,%al
  800af3:	74 04                	je     800af9 <strcmp+0x1c>
  800af5:	3a 02                	cmp    (%edx),%al
  800af7:	74 ef                	je     800ae8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800af9:	0f b6 c0             	movzbl %al,%eax
  800afc:	0f b6 12             	movzbl (%edx),%edx
  800aff:	29 d0                	sub    %edx,%eax
}
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b12:	eb 06                	jmp    800b1a <strncmp+0x17>
		n--, p++, q++;
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b1a:	39 d8                	cmp    %ebx,%eax
  800b1c:	74 16                	je     800b34 <strncmp+0x31>
  800b1e:	0f b6 08             	movzbl (%eax),%ecx
  800b21:	84 c9                	test   %cl,%cl
  800b23:	74 04                	je     800b29 <strncmp+0x26>
  800b25:	3a 0a                	cmp    (%edx),%cl
  800b27:	74 eb                	je     800b14 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b29:	0f b6 00             	movzbl (%eax),%eax
  800b2c:	0f b6 12             	movzbl (%edx),%edx
  800b2f:	29 d0                	sub    %edx,%eax
}
  800b31:	5b                   	pop    %ebx
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    
		return 0;
  800b34:	b8 00 00 00 00       	mov    $0x0,%eax
  800b39:	eb f6                	jmp    800b31 <strncmp+0x2e>

00800b3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b45:	0f b6 10             	movzbl (%eax),%edx
  800b48:	84 d2                	test   %dl,%dl
  800b4a:	74 09                	je     800b55 <strchr+0x1a>
		if (*s == c)
  800b4c:	38 ca                	cmp    %cl,%dl
  800b4e:	74 0a                	je     800b5a <strchr+0x1f>
	for (; *s; s++)
  800b50:	83 c0 01             	add    $0x1,%eax
  800b53:	eb f0                	jmp    800b45 <strchr+0xa>
			return (char *) s;
	return 0;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    

00800b5c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b66:	eb 03                	jmp    800b6b <strfind+0xf>
  800b68:	83 c0 01             	add    $0x1,%eax
  800b6b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b6e:	38 ca                	cmp    %cl,%dl
  800b70:	74 04                	je     800b76 <strfind+0x1a>
  800b72:	84 d2                	test   %dl,%dl
  800b74:	75 f2                	jne    800b68 <strfind+0xc>
			break;
	return (char *) s;
}
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    

00800b78 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	57                   	push   %edi
  800b7c:	56                   	push   %esi
  800b7d:	53                   	push   %ebx
  800b7e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b84:	85 c9                	test   %ecx,%ecx
  800b86:	74 13                	je     800b9b <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b88:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b8e:	75 05                	jne    800b95 <memset+0x1d>
  800b90:	f6 c1 03             	test   $0x3,%cl
  800b93:	74 0d                	je     800ba2 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b98:	fc                   	cld    
  800b99:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b9b:	89 f8                	mov    %edi,%eax
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5f                   	pop    %edi
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    
		c &= 0xFF;
  800ba2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ba6:	89 d3                	mov    %edx,%ebx
  800ba8:	c1 e3 08             	shl    $0x8,%ebx
  800bab:	89 d0                	mov    %edx,%eax
  800bad:	c1 e0 18             	shl    $0x18,%eax
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	c1 e6 10             	shl    $0x10,%esi
  800bb5:	09 f0                	or     %esi,%eax
  800bb7:	09 c2                	or     %eax,%edx
  800bb9:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800bbb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bbe:	89 d0                	mov    %edx,%eax
  800bc0:	fc                   	cld    
  800bc1:	f3 ab                	rep stos %eax,%es:(%edi)
  800bc3:	eb d6                	jmp    800b9b <memset+0x23>

00800bc5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bd3:	39 c6                	cmp    %eax,%esi
  800bd5:	73 35                	jae    800c0c <memmove+0x47>
  800bd7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bda:	39 c2                	cmp    %eax,%edx
  800bdc:	76 2e                	jbe    800c0c <memmove+0x47>
		s += n;
		d += n;
  800bde:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	09 fe                	or     %edi,%esi
  800be5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800beb:	74 0c                	je     800bf9 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bed:	83 ef 01             	sub    $0x1,%edi
  800bf0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bf3:	fd                   	std    
  800bf4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bf6:	fc                   	cld    
  800bf7:	eb 21                	jmp    800c1a <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf9:	f6 c1 03             	test   $0x3,%cl
  800bfc:	75 ef                	jne    800bed <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bfe:	83 ef 04             	sub    $0x4,%edi
  800c01:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c04:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c07:	fd                   	std    
  800c08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c0a:	eb ea                	jmp    800bf6 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0c:	89 f2                	mov    %esi,%edx
  800c0e:	09 c2                	or     %eax,%edx
  800c10:	f6 c2 03             	test   $0x3,%dl
  800c13:	74 09                	je     800c1e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c15:	89 c7                	mov    %eax,%edi
  800c17:	fc                   	cld    
  800c18:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c1a:	5e                   	pop    %esi
  800c1b:	5f                   	pop    %edi
  800c1c:	5d                   	pop    %ebp
  800c1d:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c1e:	f6 c1 03             	test   $0x3,%cl
  800c21:	75 f2                	jne    800c15 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c23:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c26:	89 c7                	mov    %eax,%edi
  800c28:	fc                   	cld    
  800c29:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c2b:	eb ed                	jmp    800c1a <memmove+0x55>

00800c2d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c30:	ff 75 10             	pushl  0x10(%ebp)
  800c33:	ff 75 0c             	pushl  0xc(%ebp)
  800c36:	ff 75 08             	pushl  0x8(%ebp)
  800c39:	e8 87 ff ff ff       	call   800bc5 <memmove>
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4b:	89 c6                	mov    %eax,%esi
  800c4d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c50:	39 f0                	cmp    %esi,%eax
  800c52:	74 1c                	je     800c70 <memcmp+0x30>
		if (*s1 != *s2)
  800c54:	0f b6 08             	movzbl (%eax),%ecx
  800c57:	0f b6 1a             	movzbl (%edx),%ebx
  800c5a:	38 d9                	cmp    %bl,%cl
  800c5c:	75 08                	jne    800c66 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c5e:	83 c0 01             	add    $0x1,%eax
  800c61:	83 c2 01             	add    $0x1,%edx
  800c64:	eb ea                	jmp    800c50 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c66:	0f b6 c1             	movzbl %cl,%eax
  800c69:	0f b6 db             	movzbl %bl,%ebx
  800c6c:	29 d8                	sub    %ebx,%eax
  800c6e:	eb 05                	jmp    800c75 <memcmp+0x35>
	}

	return 0;
  800c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c87:	39 d0                	cmp    %edx,%eax
  800c89:	73 09                	jae    800c94 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c8b:	38 08                	cmp    %cl,(%eax)
  800c8d:	74 05                	je     800c94 <memfind+0x1b>
	for (; s < ends; s++)
  800c8f:	83 c0 01             	add    $0x1,%eax
  800c92:	eb f3                	jmp    800c87 <memfind+0xe>
			break;
	return (void *) s;
}
  800c94:	5d                   	pop    %ebp
  800c95:	c3                   	ret    

00800c96 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ca2:	eb 03                	jmp    800ca7 <strtol+0x11>
		s++;
  800ca4:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ca7:	0f b6 01             	movzbl (%ecx),%eax
  800caa:	3c 20                	cmp    $0x20,%al
  800cac:	74 f6                	je     800ca4 <strtol+0xe>
  800cae:	3c 09                	cmp    $0x9,%al
  800cb0:	74 f2                	je     800ca4 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800cb2:	3c 2b                	cmp    $0x2b,%al
  800cb4:	74 2e                	je     800ce4 <strtol+0x4e>
	int neg = 0;
  800cb6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cbb:	3c 2d                	cmp    $0x2d,%al
  800cbd:	74 2f                	je     800cee <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cc5:	75 05                	jne    800ccc <strtol+0x36>
  800cc7:	80 39 30             	cmpb   $0x30,(%ecx)
  800cca:	74 2c                	je     800cf8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccc:	85 db                	test   %ebx,%ebx
  800cce:	75 0a                	jne    800cda <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cd0:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800cd5:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd8:	74 28                	je     800d02 <strtol+0x6c>
		base = 10;
  800cda:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdf:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ce2:	eb 50                	jmp    800d34 <strtol+0x9e>
		s++;
  800ce4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ce7:	bf 00 00 00 00       	mov    $0x0,%edi
  800cec:	eb d1                	jmp    800cbf <strtol+0x29>
		s++, neg = 1;
  800cee:	83 c1 01             	add    $0x1,%ecx
  800cf1:	bf 01 00 00 00       	mov    $0x1,%edi
  800cf6:	eb c7                	jmp    800cbf <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cfc:	74 0e                	je     800d0c <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cfe:	85 db                	test   %ebx,%ebx
  800d00:	75 d8                	jne    800cda <strtol+0x44>
		s++, base = 8;
  800d02:	83 c1 01             	add    $0x1,%ecx
  800d05:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d0a:	eb ce                	jmp    800cda <strtol+0x44>
		s += 2, base = 16;
  800d0c:	83 c1 02             	add    $0x2,%ecx
  800d0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d14:	eb c4                	jmp    800cda <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800d16:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d19:	89 f3                	mov    %esi,%ebx
  800d1b:	80 fb 19             	cmp    $0x19,%bl
  800d1e:	77 29                	ja     800d49 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d20:	0f be d2             	movsbl %dl,%edx
  800d23:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d26:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d29:	7d 30                	jge    800d5b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d2b:	83 c1 01             	add    $0x1,%ecx
  800d2e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d32:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d34:	0f b6 11             	movzbl (%ecx),%edx
  800d37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d3a:	89 f3                	mov    %esi,%ebx
  800d3c:	80 fb 09             	cmp    $0x9,%bl
  800d3f:	77 d5                	ja     800d16 <strtol+0x80>
			dig = *s - '0';
  800d41:	0f be d2             	movsbl %dl,%edx
  800d44:	83 ea 30             	sub    $0x30,%edx
  800d47:	eb dd                	jmp    800d26 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d4c:	89 f3                	mov    %esi,%ebx
  800d4e:	80 fb 19             	cmp    $0x19,%bl
  800d51:	77 08                	ja     800d5b <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d53:	0f be d2             	movsbl %dl,%edx
  800d56:	83 ea 37             	sub    $0x37,%edx
  800d59:	eb cb                	jmp    800d26 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d5f:	74 05                	je     800d66 <strtol+0xd0>
		*endptr = (char *) s;
  800d61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d64:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d66:	89 c2                	mov    %eax,%edx
  800d68:	f7 da                	neg    %edx
  800d6a:	85 ff                	test   %edi,%edi
  800d6c:	0f 45 c2             	cmovne %edx,%eax
}
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    

00800d74 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d7a:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d81:	74 20                	je     800da3 <set_pgfault_handler+0x2f>
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
			panic("set_pgfault_handler:sys_page_alloc failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d83:	8b 45 08             	mov    0x8(%ebp),%eax
  800d86:	a3 08 20 80 00       	mov    %eax,0x802008
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  800d8b:	83 ec 08             	sub    $0x8,%esp
  800d8e:	68 17 03 80 00       	push   $0x800317
  800d93:	6a 00                	push   $0x0
  800d95:	e8 d7 f4 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	78 2e                	js     800dcf <set_pgfault_handler+0x5b>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
}
  800da1:	c9                   	leave  
  800da2:	c3                   	ret    
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  800da3:	83 ec 04             	sub    $0x4,%esp
  800da6:	6a 07                	push   $0x7
  800da8:	68 00 f0 bf ee       	push   $0xeebff000
  800dad:	6a 00                	push   $0x0
  800daf:	e8 b4 f3 ff ff       	call   800168 <sys_page_alloc>
  800db4:	83 c4 10             	add    $0x10,%esp
  800db7:	85 c0                	test   %eax,%eax
  800db9:	79 c8                	jns    800d83 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler:sys_page_alloc failed");
  800dbb:	83 ec 04             	sub    $0x4,%esp
  800dbe:	68 e4 12 80 00       	push   $0x8012e4
  800dc3:	6a 21                	push   $0x21
  800dc5:	68 48 13 80 00       	push   $0x801348
  800dca:	e8 6e f5 ff ff       	call   80033d <_panic>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  800dcf:	83 ec 04             	sub    $0x4,%esp
  800dd2:	68 10 13 80 00       	push   $0x801310
  800dd7:	6a 27                	push   $0x27
  800dd9:	68 48 13 80 00       	push   $0x801348
  800dde:	e8 5a f5 ff ff       	call   80033d <_panic>
  800de3:	66 90                	xchg   %ax,%ax
  800de5:	66 90                	xchg   %ax,%ax
  800de7:	66 90                	xchg   %ax,%ax
  800de9:	66 90                	xchg   %ax,%ax
  800deb:	66 90                	xchg   %ax,%ax
  800ded:	66 90                	xchg   %ax,%ax
  800def:	90                   	nop

00800df0 <__udivdi3>:
  800df0:	55                   	push   %ebp
  800df1:	57                   	push   %edi
  800df2:	56                   	push   %esi
  800df3:	53                   	push   %ebx
  800df4:	83 ec 1c             	sub    $0x1c,%esp
  800df7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dfb:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dff:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e03:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e07:	85 d2                	test   %edx,%edx
  800e09:	75 35                	jne    800e40 <__udivdi3+0x50>
  800e0b:	39 f3                	cmp    %esi,%ebx
  800e0d:	0f 87 bd 00 00 00    	ja     800ed0 <__udivdi3+0xe0>
  800e13:	85 db                	test   %ebx,%ebx
  800e15:	89 d9                	mov    %ebx,%ecx
  800e17:	75 0b                	jne    800e24 <__udivdi3+0x34>
  800e19:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1e:	31 d2                	xor    %edx,%edx
  800e20:	f7 f3                	div    %ebx
  800e22:	89 c1                	mov    %eax,%ecx
  800e24:	31 d2                	xor    %edx,%edx
  800e26:	89 f0                	mov    %esi,%eax
  800e28:	f7 f1                	div    %ecx
  800e2a:	89 c6                	mov    %eax,%esi
  800e2c:	89 e8                	mov    %ebp,%eax
  800e2e:	89 f7                	mov    %esi,%edi
  800e30:	f7 f1                	div    %ecx
  800e32:	89 fa                	mov    %edi,%edx
  800e34:	83 c4 1c             	add    $0x1c,%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    
  800e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e40:	39 f2                	cmp    %esi,%edx
  800e42:	77 7c                	ja     800ec0 <__udivdi3+0xd0>
  800e44:	0f bd fa             	bsr    %edx,%edi
  800e47:	83 f7 1f             	xor    $0x1f,%edi
  800e4a:	0f 84 98 00 00 00    	je     800ee8 <__udivdi3+0xf8>
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	b8 20 00 00 00       	mov    $0x20,%eax
  800e57:	29 f8                	sub    %edi,%eax
  800e59:	d3 e2                	shl    %cl,%edx
  800e5b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e5f:	89 c1                	mov    %eax,%ecx
  800e61:	89 da                	mov    %ebx,%edx
  800e63:	d3 ea                	shr    %cl,%edx
  800e65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e69:	09 d1                	or     %edx,%ecx
  800e6b:	89 f2                	mov    %esi,%edx
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e3                	shl    %cl,%ebx
  800e75:	89 c1                	mov    %eax,%ecx
  800e77:	d3 ea                	shr    %cl,%edx
  800e79:	89 f9                	mov    %edi,%ecx
  800e7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e7f:	d3 e6                	shl    %cl,%esi
  800e81:	89 eb                	mov    %ebp,%ebx
  800e83:	89 c1                	mov    %eax,%ecx
  800e85:	d3 eb                	shr    %cl,%ebx
  800e87:	09 de                	or     %ebx,%esi
  800e89:	89 f0                	mov    %esi,%eax
  800e8b:	f7 74 24 08          	divl   0x8(%esp)
  800e8f:	89 d6                	mov    %edx,%esi
  800e91:	89 c3                	mov    %eax,%ebx
  800e93:	f7 64 24 0c          	mull   0xc(%esp)
  800e97:	39 d6                	cmp    %edx,%esi
  800e99:	72 0c                	jb     800ea7 <__udivdi3+0xb7>
  800e9b:	89 f9                	mov    %edi,%ecx
  800e9d:	d3 e5                	shl    %cl,%ebp
  800e9f:	39 c5                	cmp    %eax,%ebp
  800ea1:	73 5d                	jae    800f00 <__udivdi3+0x110>
  800ea3:	39 d6                	cmp    %edx,%esi
  800ea5:	75 59                	jne    800f00 <__udivdi3+0x110>
  800ea7:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800eaa:	31 ff                	xor    %edi,%edi
  800eac:	89 fa                	mov    %edi,%edx
  800eae:	83 c4 1c             	add    $0x1c,%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    
  800eb6:	8d 76 00             	lea    0x0(%esi),%esi
  800eb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  800ec0:	31 ff                	xor    %edi,%edi
  800ec2:	31 c0                	xor    %eax,%eax
  800ec4:	89 fa                	mov    %edi,%edx
  800ec6:	83 c4 1c             	add    $0x1c,%esp
  800ec9:	5b                   	pop    %ebx
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    
  800ece:	66 90                	xchg   %ax,%ax
  800ed0:	31 ff                	xor    %edi,%edi
  800ed2:	89 e8                	mov    %ebp,%eax
  800ed4:	89 f2                	mov    %esi,%edx
  800ed6:	f7 f3                	div    %ebx
  800ed8:	89 fa                	mov    %edi,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	39 f2                	cmp    %esi,%edx
  800eea:	72 06                	jb     800ef2 <__udivdi3+0x102>
  800eec:	31 c0                	xor    %eax,%eax
  800eee:	39 eb                	cmp    %ebp,%ebx
  800ef0:	77 d2                	ja     800ec4 <__udivdi3+0xd4>
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	eb cb                	jmp    800ec4 <__udivdi3+0xd4>
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	31 ff                	xor    %edi,%edi
  800f04:	eb be                	jmp    800ec4 <__udivdi3+0xd4>
  800f06:	66 90                	xchg   %ax,%ax
  800f08:	66 90                	xchg   %ax,%ax
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	53                   	push   %ebx
  800f14:	83 ec 1c             	sub    $0x1c,%esp
  800f17:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800f1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f27:	85 ed                	test   %ebp,%ebp
  800f29:	89 f0                	mov    %esi,%eax
  800f2b:	89 da                	mov    %ebx,%edx
  800f2d:	75 19                	jne    800f48 <__umoddi3+0x38>
  800f2f:	39 df                	cmp    %ebx,%edi
  800f31:	0f 86 b1 00 00 00    	jbe    800fe8 <__umoddi3+0xd8>
  800f37:	f7 f7                	div    %edi
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	39 dd                	cmp    %ebx,%ebp
  800f4a:	77 f1                	ja     800f3d <__umoddi3+0x2d>
  800f4c:	0f bd cd             	bsr    %ebp,%ecx
  800f4f:	83 f1 1f             	xor    $0x1f,%ecx
  800f52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f56:	0f 84 b4 00 00 00    	je     801010 <__umoddi3+0x100>
  800f5c:	b8 20 00 00 00       	mov    $0x20,%eax
  800f61:	89 c2                	mov    %eax,%edx
  800f63:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f67:	29 c2                	sub    %eax,%edx
  800f69:	89 c1                	mov    %eax,%ecx
  800f6b:	89 f8                	mov    %edi,%eax
  800f6d:	d3 e5                	shl    %cl,%ebp
  800f6f:	89 d1                	mov    %edx,%ecx
  800f71:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f75:	d3 e8                	shr    %cl,%eax
  800f77:	09 c5                	or     %eax,%ebp
  800f79:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f7d:	89 c1                	mov    %eax,%ecx
  800f7f:	d3 e7                	shl    %cl,%edi
  800f81:	89 d1                	mov    %edx,%ecx
  800f83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f87:	89 df                	mov    %ebx,%edi
  800f89:	d3 ef                	shr    %cl,%edi
  800f8b:	89 c1                	mov    %eax,%ecx
  800f8d:	89 f0                	mov    %esi,%eax
  800f8f:	d3 e3                	shl    %cl,%ebx
  800f91:	89 d1                	mov    %edx,%ecx
  800f93:	89 fa                	mov    %edi,%edx
  800f95:	d3 e8                	shr    %cl,%eax
  800f97:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f9c:	09 d8                	or     %ebx,%eax
  800f9e:	f7 f5                	div    %ebp
  800fa0:	d3 e6                	shl    %cl,%esi
  800fa2:	89 d1                	mov    %edx,%ecx
  800fa4:	f7 64 24 08          	mull   0x8(%esp)
  800fa8:	39 d1                	cmp    %edx,%ecx
  800faa:	89 c3                	mov    %eax,%ebx
  800fac:	89 d7                	mov    %edx,%edi
  800fae:	72 06                	jb     800fb6 <__umoddi3+0xa6>
  800fb0:	75 0e                	jne    800fc0 <__umoddi3+0xb0>
  800fb2:	39 c6                	cmp    %eax,%esi
  800fb4:	73 0a                	jae    800fc0 <__umoddi3+0xb0>
  800fb6:	2b 44 24 08          	sub    0x8(%esp),%eax
  800fba:	19 ea                	sbb    %ebp,%edx
  800fbc:	89 d7                	mov    %edx,%edi
  800fbe:	89 c3                	mov    %eax,%ebx
  800fc0:	89 ca                	mov    %ecx,%edx
  800fc2:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fc7:	29 de                	sub    %ebx,%esi
  800fc9:	19 fa                	sbb    %edi,%edx
  800fcb:	8b 5c 24 04          	mov    0x4(%esp),%ebx
  800fcf:	89 d0                	mov    %edx,%eax
  800fd1:	d3 e0                	shl    %cl,%eax
  800fd3:	89 d9                	mov    %ebx,%ecx
  800fd5:	d3 ee                	shr    %cl,%esi
  800fd7:	d3 ea                	shr    %cl,%edx
  800fd9:	09 f0                	or     %esi,%eax
  800fdb:	83 c4 1c             	add    $0x1c,%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    
  800fe3:	90                   	nop
  800fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800fe8:	85 ff                	test   %edi,%edi
  800fea:	89 f9                	mov    %edi,%ecx
  800fec:	75 0b                	jne    800ff9 <__umoddi3+0xe9>
  800fee:	b8 01 00 00 00       	mov    $0x1,%eax
  800ff3:	31 d2                	xor    %edx,%edx
  800ff5:	f7 f7                	div    %edi
  800ff7:	89 c1                	mov    %eax,%ecx
  800ff9:	89 d8                	mov    %ebx,%eax
  800ffb:	31 d2                	xor    %edx,%edx
  800ffd:	f7 f1                	div    %ecx
  800fff:	89 f0                	mov    %esi,%eax
  801001:	f7 f1                	div    %ecx
  801003:	e9 31 ff ff ff       	jmp    800f39 <__umoddi3+0x29>
  801008:	90                   	nop
  801009:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801010:	39 dd                	cmp    %ebx,%ebp
  801012:	72 08                	jb     80101c <__umoddi3+0x10c>
  801014:	39 f7                	cmp    %esi,%edi
  801016:	0f 87 21 ff ff ff    	ja     800f3d <__umoddi3+0x2d>
  80101c:	89 da                	mov    %ebx,%edx
  80101e:	89 f0                	mov    %esi,%eax
  801020:	29 f8                	sub    %edi,%eax
  801022:	19 ea                	sbb    %ebp,%edx
  801024:	e9 14 ff ff ff       	jmp    800f3d <__umoddi3+0x2d>
