
obj/user/badsegment：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7f 08                	jg     8000fd <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 8a 0f 80 00       	push   $0x800f8a
  800108:	6a 23                	push   $0x23
  80010a:	68 a7 0f 80 00       	push   $0x800fa7
  80010f:	e8 ed 01 00 00       	call   800301 <_panic>

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800166:	b8 04 00 00 00       	mov    $0x4,%eax
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7f 08                	jg     80017e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 8a 0f 80 00       	push   $0x800f8a
  800189:	6a 23                	push   $0x23
  80018b:	68 a7 0f 80 00       	push   $0x800fa7
  800190:	e8 6c 01 00 00       	call   800301 <_panic>

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7f 08                	jg     8001c0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 8a 0f 80 00       	push   $0x800f8a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 a7 0f 80 00       	push   $0x800fa7
  8001d2:	e8 2a 01 00 00       	call   800301 <_panic>

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7f 08                	jg     800202 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5e                   	pop    %esi
  8001ff:	5f                   	pop    %edi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 8a 0f 80 00       	push   $0x800f8a
  80020d:	6a 23                	push   $0x23
  80020f:	68 a7 0f 80 00       	push   $0x800fa7
  800214:	e8 e8 00 00 00       	call   800301 <_panic>

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	b8 08 00 00 00       	mov    $0x8,%eax
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7f 08                	jg     800244 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 8a 0f 80 00       	push   $0x800f8a
  80024f:	6a 23                	push   $0x23
  800251:	68 a7 0f 80 00       	push   $0x800fa7
  800256:	e8 a6 00 00 00       	call   800301 <_panic>

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026f:	b8 09 00 00 00       	mov    $0x9,%eax
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7f 08                	jg     800286 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80027e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 8a 0f 80 00       	push   $0x800f8a
  800291:	6a 23                	push   $0x23
  800293:	68 a7 0f 80 00       	push   $0x800fa7
  800298:	e8 64 00 00 00       	call   800301 <_panic>

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ae:	be 00 00 00 00       	mov    $0x0,%esi
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7f 08                	jg     8002ea <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ea:	83 ec 0c             	sub    $0xc,%esp
  8002ed:	50                   	push   %eax
  8002ee:	6a 0c                	push   $0xc
  8002f0:	68 8a 0f 80 00       	push   $0x800f8a
  8002f5:	6a 23                	push   $0x23
  8002f7:	68 a7 0f 80 00       	push   $0x800fa7
  8002fc:	e8 00 00 00 00       	call   800301 <_panic>

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030f:	e8 00 fe ff ff       	call   800114 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 b8 0f 80 00       	push   $0x800fb8
  800324:	e8 b3 00 00 00       	call   8003dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	pushl  0x10(%ebp)
  800330:	e8 56 00 00 00       	call   80038b <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  80033c:	e8 9b 00 00 00       	call   8003dc <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	74 09                	je     80036f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800366:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	68 ff 00 00 00       	push   $0xff
  800377:	8d 43 08             	lea    0x8(%ebx),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 16 fd ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	eb db                	jmp    800366 <putch+0x1f>

0080038b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800394:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039b:	00 00 00 
	b.cnt = 0;
  80039e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a8:	ff 75 0c             	pushl  0xc(%ebp)
  8003ab:	ff 75 08             	pushl  0x8(%ebp)
  8003ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b4:	50                   	push   %eax
  8003b5:	68 47 03 80 00       	push   $0x800347
  8003ba:	e8 1a 01 00 00       	call   8004d9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bf:	83 c4 08             	add    $0x8,%esp
  8003c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ce:	50                   	push   %eax
  8003cf:	e8 c2 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e5:	50                   	push   %eax
  8003e6:	ff 75 08             	pushl  0x8(%ebp)
  8003e9:	e8 9d ff ff ff       	call   80038b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 1c             	sub    $0x1c,%esp
  8003f9:	89 c7                	mov    %eax,%edi
  8003fb:	89 d6                	mov    %edx,%esi
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	8b 55 0c             	mov    0xc(%ebp),%edx
  800403:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800406:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800409:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800411:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800414:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800417:	39 d3                	cmp    %edx,%ebx
  800419:	72 05                	jb     800420 <printnum+0x30>
  80041b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80041e:	77 7a                	ja     80049a <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800420:	83 ec 0c             	sub    $0xc,%esp
  800423:	ff 75 18             	pushl  0x18(%ebp)
  800426:	8b 45 14             	mov    0x14(%ebp),%eax
  800429:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042c:	53                   	push   %ebx
  80042d:	ff 75 10             	pushl  0x10(%ebp)
  800430:	83 ec 08             	sub    $0x8,%esp
  800433:	ff 75 e4             	pushl  -0x1c(%ebp)
  800436:	ff 75 e0             	pushl  -0x20(%ebp)
  800439:	ff 75 dc             	pushl  -0x24(%ebp)
  80043c:	ff 75 d8             	pushl  -0x28(%ebp)
  80043f:	e8 fc 08 00 00       	call   800d40 <__udivdi3>
  800444:	83 c4 18             	add    $0x18,%esp
  800447:	52                   	push   %edx
  800448:	50                   	push   %eax
  800449:	89 f2                	mov    %esi,%edx
  80044b:	89 f8                	mov    %edi,%eax
  80044d:	e8 9e ff ff ff       	call   8003f0 <printnum>
  800452:	83 c4 20             	add    $0x20,%esp
  800455:	eb 13                	jmp    80046a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800457:	83 ec 08             	sub    $0x8,%esp
  80045a:	56                   	push   %esi
  80045b:	ff 75 18             	pushl  0x18(%ebp)
  80045e:	ff d7                	call   *%edi
  800460:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800463:	83 eb 01             	sub    $0x1,%ebx
  800466:	85 db                	test   %ebx,%ebx
  800468:	7f ed                	jg     800457 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046a:	83 ec 08             	sub    $0x8,%esp
  80046d:	56                   	push   %esi
  80046e:	83 ec 04             	sub    $0x4,%esp
  800471:	ff 75 e4             	pushl  -0x1c(%ebp)
  800474:	ff 75 e0             	pushl  -0x20(%ebp)
  800477:	ff 75 dc             	pushl  -0x24(%ebp)
  80047a:	ff 75 d8             	pushl  -0x28(%ebp)
  80047d:	e8 de 09 00 00       	call   800e60 <__umoddi3>
  800482:	83 c4 14             	add    $0x14,%esp
  800485:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  80048c:	50                   	push   %eax
  80048d:	ff d7                	call   *%edi
}
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800495:	5b                   	pop    %ebx
  800496:	5e                   	pop    %esi
  800497:	5f                   	pop    %edi
  800498:	5d                   	pop    %ebp
  800499:	c3                   	ret    
  80049a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80049d:	eb c4                	jmp    800463 <printnum+0x73>

0080049f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a9:	8b 10                	mov    (%eax),%edx
  8004ab:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ae:	73 0a                	jae    8004ba <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b3:	89 08                	mov    %ecx,(%eax)
  8004b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b8:	88 02                	mov    %al,(%edx)
}
  8004ba:	5d                   	pop    %ebp
  8004bb:	c3                   	ret    

008004bc <printfmt>:
{
  8004bc:	55                   	push   %ebp
  8004bd:	89 e5                	mov    %esp,%ebp
  8004bf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004c2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c5:	50                   	push   %eax
  8004c6:	ff 75 10             	pushl  0x10(%ebp)
  8004c9:	ff 75 0c             	pushl  0xc(%ebp)
  8004cc:	ff 75 08             	pushl  0x8(%ebp)
  8004cf:	e8 05 00 00 00       	call   8004d9 <vprintfmt>
}
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <vprintfmt>:
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	57                   	push   %edi
  8004dd:	56                   	push   %esi
  8004de:	53                   	push   %ebx
  8004df:	83 ec 2c             	sub    $0x2c,%esp
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004eb:	e9 c1 03 00 00       	jmp    8008b1 <vprintfmt+0x3d8>
		padc = ' ';
  8004f0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004f4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004fb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800502:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800509:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8d 47 01             	lea    0x1(%edi),%eax
  800511:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800514:	0f b6 17             	movzbl (%edi),%edx
  800517:	8d 42 dd             	lea    -0x23(%edx),%eax
  80051a:	3c 55                	cmp    $0x55,%al
  80051c:	0f 87 12 04 00 00    	ja     800934 <vprintfmt+0x45b>
  800522:	0f b6 c0             	movzbl %al,%eax
  800525:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  80052c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80052f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800533:	eb d9                	jmp    80050e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800535:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800538:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80053c:	eb d0                	jmp    80050e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80053e:	0f b6 d2             	movzbl %dl,%edx
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800544:	b8 00 00 00 00       	mov    $0x0,%eax
  800549:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80054c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80054f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800553:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800556:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800559:	83 f9 09             	cmp    $0x9,%ecx
  80055c:	77 55                	ja     8005b3 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80055e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800561:	eb e9                	jmp    80054c <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8b 00                	mov    (%eax),%eax
  800568:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	8d 40 04             	lea    0x4(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800574:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800577:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80057b:	79 91                	jns    80050e <vprintfmt+0x35>
				width = precision, precision = -1;
  80057d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800580:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800583:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80058a:	eb 82                	jmp    80050e <vprintfmt+0x35>
  80058c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058f:	85 c0                	test   %eax,%eax
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	0f 49 d0             	cmovns %eax,%edx
  800599:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80059c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059f:	e9 6a ff ff ff       	jmp    80050e <vprintfmt+0x35>
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ae:	e9 5b ff ff ff       	jmp    80050e <vprintfmt+0x35>
  8005b3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b9:	eb bc                	jmp    800577 <vprintfmt+0x9e>
			lflag++;
  8005bb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005c1:	e9 48 ff ff ff       	jmp    80050e <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 78 04             	lea    0x4(%eax),%edi
  8005cc:	83 ec 08             	sub    $0x8,%esp
  8005cf:	53                   	push   %ebx
  8005d0:	ff 30                	pushl  (%eax)
  8005d2:	ff d6                	call   *%esi
			break;
  8005d4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005d7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005da:	e9 cf 02 00 00       	jmp    8008ae <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 78 04             	lea    0x4(%eax),%edi
  8005e5:	8b 00                	mov    (%eax),%eax
  8005e7:	99                   	cltd   
  8005e8:	31 d0                	xor    %edx,%eax
  8005ea:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005ec:	83 f8 08             	cmp    $0x8,%eax
  8005ef:	7f 23                	jg     800614 <vprintfmt+0x13b>
  8005f1:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8005f8:	85 d2                	test   %edx,%edx
  8005fa:	74 18                	je     800614 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8005fc:	52                   	push   %edx
  8005fd:	68 ff 0f 80 00       	push   $0x800fff
  800602:	53                   	push   %ebx
  800603:	56                   	push   %esi
  800604:	e8 b3 fe ff ff       	call   8004bc <printfmt>
  800609:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80060c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80060f:	e9 9a 02 00 00       	jmp    8008ae <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800614:	50                   	push   %eax
  800615:	68 f6 0f 80 00       	push   $0x800ff6
  80061a:	53                   	push   %ebx
  80061b:	56                   	push   %esi
  80061c:	e8 9b fe ff ff       	call   8004bc <printfmt>
  800621:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800624:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800627:	e9 82 02 00 00       	jmp    8008ae <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	83 c0 04             	add    $0x4,%eax
  800632:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800635:	8b 45 14             	mov    0x14(%ebp),%eax
  800638:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80063a:	85 ff                	test   %edi,%edi
  80063c:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  800641:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800644:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800648:	0f 8e bd 00 00 00    	jle    80070b <vprintfmt+0x232>
  80064e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800652:	75 0e                	jne    800662 <vprintfmt+0x189>
  800654:	89 75 08             	mov    %esi,0x8(%ebp)
  800657:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80065a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80065d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800660:	eb 6d                	jmp    8006cf <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	ff 75 d0             	pushl  -0x30(%ebp)
  800668:	57                   	push   %edi
  800669:	e8 6e 03 00 00       	call   8009dc <strnlen>
  80066e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800671:	29 c1                	sub    %eax,%ecx
  800673:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800676:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800679:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80067d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800680:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800683:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800685:	eb 0f                	jmp    800696 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	53                   	push   %ebx
  80068b:	ff 75 e0             	pushl  -0x20(%ebp)
  80068e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800690:	83 ef 01             	sub    $0x1,%edi
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	85 ff                	test   %edi,%edi
  800698:	7f ed                	jg     800687 <vprintfmt+0x1ae>
  80069a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80069d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a0:	85 c9                	test   %ecx,%ecx
  8006a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a7:	0f 49 c1             	cmovns %ecx,%eax
  8006aa:	29 c1                	sub    %eax,%ecx
  8006ac:	89 75 08             	mov    %esi,0x8(%ebp)
  8006af:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006b2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b5:	89 cb                	mov    %ecx,%ebx
  8006b7:	eb 16                	jmp    8006cf <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006bd:	75 31                	jne    8006f0 <vprintfmt+0x217>
					putch(ch, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	50                   	push   %eax
  8006c6:	ff 55 08             	call   *0x8(%ebp)
  8006c9:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cc:	83 eb 01             	sub    $0x1,%ebx
  8006cf:	83 c7 01             	add    $0x1,%edi
  8006d2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006d6:	0f be c2             	movsbl %dl,%eax
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 59                	je     800736 <vprintfmt+0x25d>
  8006dd:	85 f6                	test   %esi,%esi
  8006df:	78 d8                	js     8006b9 <vprintfmt+0x1e0>
  8006e1:	83 ee 01             	sub    $0x1,%esi
  8006e4:	79 d3                	jns    8006b9 <vprintfmt+0x1e0>
  8006e6:	89 df                	mov    %ebx,%edi
  8006e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ee:	eb 37                	jmp    800727 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f0:	0f be d2             	movsbl %dl,%edx
  8006f3:	83 ea 20             	sub    $0x20,%edx
  8006f6:	83 fa 5e             	cmp    $0x5e,%edx
  8006f9:	76 c4                	jbe    8006bf <vprintfmt+0x1e6>
					putch('?', putdat);
  8006fb:	83 ec 08             	sub    $0x8,%esp
  8006fe:	ff 75 0c             	pushl  0xc(%ebp)
  800701:	6a 3f                	push   $0x3f
  800703:	ff 55 08             	call   *0x8(%ebp)
  800706:	83 c4 10             	add    $0x10,%esp
  800709:	eb c1                	jmp    8006cc <vprintfmt+0x1f3>
  80070b:	89 75 08             	mov    %esi,0x8(%ebp)
  80070e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800711:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800714:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800717:	eb b6                	jmp    8006cf <vprintfmt+0x1f6>
				putch(' ', putdat);
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	53                   	push   %ebx
  80071d:	6a 20                	push   $0x20
  80071f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800721:	83 ef 01             	sub    $0x1,%edi
  800724:	83 c4 10             	add    $0x10,%esp
  800727:	85 ff                	test   %edi,%edi
  800729:	7f ee                	jg     800719 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80072b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80072e:	89 45 14             	mov    %eax,0x14(%ebp)
  800731:	e9 78 01 00 00       	jmp    8008ae <vprintfmt+0x3d5>
  800736:	89 df                	mov    %ebx,%edi
  800738:	8b 75 08             	mov    0x8(%ebp),%esi
  80073b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073e:	eb e7                	jmp    800727 <vprintfmt+0x24e>
	if (lflag >= 2)
  800740:	83 f9 01             	cmp    $0x1,%ecx
  800743:	7e 3f                	jle    800784 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800745:	8b 45 14             	mov    0x14(%ebp),%eax
  800748:	8b 50 04             	mov    0x4(%eax),%edx
  80074b:	8b 00                	mov    (%eax),%eax
  80074d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800750:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 40 08             	lea    0x8(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80075c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800760:	79 5c                	jns    8007be <vprintfmt+0x2e5>
				putch('-', putdat);
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	53                   	push   %ebx
  800766:	6a 2d                	push   $0x2d
  800768:	ff d6                	call   *%esi
				num = -(long long) num;
  80076a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800770:	f7 da                	neg    %edx
  800772:	83 d1 00             	adc    $0x0,%ecx
  800775:	f7 d9                	neg    %ecx
  800777:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 10 01 00 00       	jmp    800894 <vprintfmt+0x3bb>
	else if (lflag)
  800784:	85 c9                	test   %ecx,%ecx
  800786:	75 1b                	jne    8007a3 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800788:	8b 45 14             	mov    0x14(%ebp),%eax
  80078b:	8b 00                	mov    (%eax),%eax
  80078d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800790:	89 c1                	mov    %eax,%ecx
  800792:	c1 f9 1f             	sar    $0x1f,%ecx
  800795:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
  8007a1:	eb b9                	jmp    80075c <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007ab:	89 c1                	mov    %eax,%ecx
  8007ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8007b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 40 04             	lea    0x4(%eax),%eax
  8007b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bc:	eb 9e                	jmp    80075c <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c9:	e9 c6 00 00 00       	jmp    800894 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007ce:	83 f9 01             	cmp    $0x1,%ecx
  8007d1:	7e 18                	jle    8007eb <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8007d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d6:	8b 10                	mov    (%eax),%edx
  8007d8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007db:	8d 40 08             	lea    0x8(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e6:	e9 a9 00 00 00       	jmp    800894 <vprintfmt+0x3bb>
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	75 1a                	jne    800809 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ff:	b8 0a 00 00 00       	mov    $0xa,%eax
  800804:	e9 8b 00 00 00       	jmp    800894 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 10                	mov    (%eax),%edx
  80080e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800813:	8d 40 04             	lea    0x4(%eax),%eax
  800816:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800819:	b8 0a 00 00 00       	mov    $0xa,%eax
  80081e:	eb 74                	jmp    800894 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800820:	83 f9 01             	cmp    $0x1,%ecx
  800823:	7e 15                	jle    80083a <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800825:	8b 45 14             	mov    0x14(%ebp),%eax
  800828:	8b 10                	mov    (%eax),%edx
  80082a:	8b 48 04             	mov    0x4(%eax),%ecx
  80082d:	8d 40 08             	lea    0x8(%eax),%eax
  800830:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800833:	b8 08 00 00 00       	mov    $0x8,%eax
  800838:	eb 5a                	jmp    800894 <vprintfmt+0x3bb>
	else if (lflag)
  80083a:	85 c9                	test   %ecx,%ecx
  80083c:	75 17                	jne    800855 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80083e:	8b 45 14             	mov    0x14(%ebp),%eax
  800841:	8b 10                	mov    (%eax),%edx
  800843:	b9 00 00 00 00       	mov    $0x0,%ecx
  800848:	8d 40 04             	lea    0x4(%eax),%eax
  80084b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80084e:	b8 08 00 00 00       	mov    $0x8,%eax
  800853:	eb 3f                	jmp    800894 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800855:	8b 45 14             	mov    0x14(%ebp),%eax
  800858:	8b 10                	mov    (%eax),%edx
  80085a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085f:	8d 40 04             	lea    0x4(%eax),%eax
  800862:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800865:	b8 08 00 00 00       	mov    $0x8,%eax
  80086a:	eb 28                	jmp    800894 <vprintfmt+0x3bb>
			putch('0', putdat);
  80086c:	83 ec 08             	sub    $0x8,%esp
  80086f:	53                   	push   %ebx
  800870:	6a 30                	push   $0x30
  800872:	ff d6                	call   *%esi
			putch('x', putdat);
  800874:	83 c4 08             	add    $0x8,%esp
  800877:	53                   	push   %ebx
  800878:	6a 78                	push   $0x78
  80087a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80087c:	8b 45 14             	mov    0x14(%ebp),%eax
  80087f:	8b 10                	mov    (%eax),%edx
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800886:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800889:	8d 40 04             	lea    0x4(%eax),%eax
  80088c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80088f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800894:	83 ec 0c             	sub    $0xc,%esp
  800897:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80089b:	57                   	push   %edi
  80089c:	ff 75 e0             	pushl  -0x20(%ebp)
  80089f:	50                   	push   %eax
  8008a0:	51                   	push   %ecx
  8008a1:	52                   	push   %edx
  8008a2:	89 da                	mov    %ebx,%edx
  8008a4:	89 f0                	mov    %esi,%eax
  8008a6:	e8 45 fb ff ff       	call   8003f0 <printnum>
			break;
  8008ab:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b1:	83 c7 01             	add    $0x1,%edi
  8008b4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008b8:	83 f8 25             	cmp    $0x25,%eax
  8008bb:	0f 84 2f fc ff ff    	je     8004f0 <vprintfmt+0x17>
			if (ch == '\0')
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	0f 84 8b 00 00 00    	je     800954 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008c9:	83 ec 08             	sub    $0x8,%esp
  8008cc:	53                   	push   %ebx
  8008cd:	50                   	push   %eax
  8008ce:	ff d6                	call   *%esi
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	eb dc                	jmp    8008b1 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8008d5:	83 f9 01             	cmp    $0x1,%ecx
  8008d8:	7e 15                	jle    8008ef <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8b 10                	mov    (%eax),%edx
  8008df:	8b 48 04             	mov    0x4(%eax),%ecx
  8008e2:	8d 40 08             	lea    0x8(%eax),%eax
  8008e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e8:	b8 10 00 00 00       	mov    $0x10,%eax
  8008ed:	eb a5                	jmp    800894 <vprintfmt+0x3bb>
	else if (lflag)
  8008ef:	85 c9                	test   %ecx,%ecx
  8008f1:	75 17                	jne    80090a <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8008f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f6:	8b 10                	mov    (%eax),%edx
  8008f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008fd:	8d 40 04             	lea    0x4(%eax),%eax
  800900:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800903:	b8 10 00 00 00       	mov    $0x10,%eax
  800908:	eb 8a                	jmp    800894 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80090a:	8b 45 14             	mov    0x14(%ebp),%eax
  80090d:	8b 10                	mov    (%eax),%edx
  80090f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800914:	8d 40 04             	lea    0x4(%eax),%eax
  800917:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091a:	b8 10 00 00 00       	mov    $0x10,%eax
  80091f:	e9 70 ff ff ff       	jmp    800894 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	53                   	push   %ebx
  800928:	6a 25                	push   $0x25
  80092a:	ff d6                	call   *%esi
			break;
  80092c:	83 c4 10             	add    $0x10,%esp
  80092f:	e9 7a ff ff ff       	jmp    8008ae <vprintfmt+0x3d5>
			putch('%', putdat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	53                   	push   %ebx
  800938:	6a 25                	push   $0x25
  80093a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80093c:	83 c4 10             	add    $0x10,%esp
  80093f:	89 f8                	mov    %edi,%eax
  800941:	eb 03                	jmp    800946 <vprintfmt+0x46d>
  800943:	83 e8 01             	sub    $0x1,%eax
  800946:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80094a:	75 f7                	jne    800943 <vprintfmt+0x46a>
  80094c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094f:	e9 5a ff ff ff       	jmp    8008ae <vprintfmt+0x3d5>
}
  800954:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	83 ec 18             	sub    $0x18,%esp
  800962:	8b 45 08             	mov    0x8(%ebp),%eax
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800968:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80096b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800972:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800979:	85 c0                	test   %eax,%eax
  80097b:	74 26                	je     8009a3 <vsnprintf+0x47>
  80097d:	85 d2                	test   %edx,%edx
  80097f:	7e 22                	jle    8009a3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800981:	ff 75 14             	pushl  0x14(%ebp)
  800984:	ff 75 10             	pushl  0x10(%ebp)
  800987:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80098a:	50                   	push   %eax
  80098b:	68 9f 04 80 00       	push   $0x80049f
  800990:	e8 44 fb ff ff       	call   8004d9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800995:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800998:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80099b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099e:	83 c4 10             	add    $0x10,%esp
}
  8009a1:	c9                   	leave  
  8009a2:	c3                   	ret    
		return -E_INVAL;
  8009a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a8:	eb f7                	jmp    8009a1 <vsnprintf+0x45>

008009aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009b3:	50                   	push   %eax
  8009b4:	ff 75 10             	pushl  0x10(%ebp)
  8009b7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ba:	ff 75 08             	pushl  0x8(%ebp)
  8009bd:	e8 9a ff ff ff       	call   80095c <vsnprintf>
	va_end(ap);

	return rc;
}
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8009cf:	eb 03                	jmp    8009d4 <strlen+0x10>
		n++;
  8009d1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d8:	75 f7                	jne    8009d1 <strlen+0xd>
	return n;
}
  8009da:	5d                   	pop    %ebp
  8009db:	c3                   	ret    

008009dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ea:	eb 03                	jmp    8009ef <strnlen+0x13>
		n++;
  8009ec:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ef:	39 d0                	cmp    %edx,%eax
  8009f1:	74 06                	je     8009f9 <strnlen+0x1d>
  8009f3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009f7:	75 f3                	jne    8009ec <strnlen+0x10>
	return n;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a05:	89 c2                	mov    %eax,%edx
  800a07:	83 c1 01             	add    $0x1,%ecx
  800a0a:	83 c2 01             	add    $0x1,%edx
  800a0d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a11:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a14:	84 db                	test   %bl,%bl
  800a16:	75 ef                	jne    800a07 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	53                   	push   %ebx
  800a1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a22:	53                   	push   %ebx
  800a23:	e8 9c ff ff ff       	call   8009c4 <strlen>
  800a28:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a2b:	ff 75 0c             	pushl  0xc(%ebp)
  800a2e:	01 d8                	add    %ebx,%eax
  800a30:	50                   	push   %eax
  800a31:	e8 c5 ff ff ff       	call   8009fb <strcpy>
	return dst;
}
  800a36:	89 d8                	mov    %ebx,%eax
  800a38:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a3b:	c9                   	leave  
  800a3c:	c3                   	ret    

00800a3d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a3d:	55                   	push   %ebp
  800a3e:	89 e5                	mov    %esp,%ebp
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 75 08             	mov    0x8(%ebp),%esi
  800a45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a48:	89 f3                	mov    %esi,%ebx
  800a4a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a4d:	89 f2                	mov    %esi,%edx
  800a4f:	eb 0f                	jmp    800a60 <strncpy+0x23>
		*dst++ = *src;
  800a51:	83 c2 01             	add    $0x1,%edx
  800a54:	0f b6 01             	movzbl (%ecx),%eax
  800a57:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a5a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a5d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a60:	39 da                	cmp    %ebx,%edx
  800a62:	75 ed                	jne    800a51 <strncpy+0x14>
	}
	return ret;
}
  800a64:	89 f0                	mov    %esi,%eax
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a78:	89 f0                	mov    %esi,%eax
  800a7a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a7e:	85 c9                	test   %ecx,%ecx
  800a80:	75 0b                	jne    800a8d <strlcpy+0x23>
  800a82:	eb 17                	jmp    800a9b <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a84:	83 c2 01             	add    $0x1,%edx
  800a87:	83 c0 01             	add    $0x1,%eax
  800a8a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a8d:	39 d8                	cmp    %ebx,%eax
  800a8f:	74 07                	je     800a98 <strlcpy+0x2e>
  800a91:	0f b6 0a             	movzbl (%edx),%ecx
  800a94:	84 c9                	test   %cl,%cl
  800a96:	75 ec                	jne    800a84 <strlcpy+0x1a>
		*dst = '\0';
  800a98:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a9b:	29 f0                	sub    %esi,%eax
}
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5d                   	pop    %ebp
  800aa0:	c3                   	ret    

00800aa1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aaa:	eb 06                	jmp    800ab2 <strcmp+0x11>
		p++, q++;
  800aac:	83 c1 01             	add    $0x1,%ecx
  800aaf:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ab2:	0f b6 01             	movzbl (%ecx),%eax
  800ab5:	84 c0                	test   %al,%al
  800ab7:	74 04                	je     800abd <strcmp+0x1c>
  800ab9:	3a 02                	cmp    (%edx),%al
  800abb:	74 ef                	je     800aac <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800abd:	0f b6 c0             	movzbl %al,%eax
  800ac0:	0f b6 12             	movzbl (%edx),%edx
  800ac3:	29 d0                	sub    %edx,%eax
}
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	53                   	push   %ebx
  800acb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ace:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad6:	eb 06                	jmp    800ade <strncmp+0x17>
		n--, p++, q++;
  800ad8:	83 c0 01             	add    $0x1,%eax
  800adb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ade:	39 d8                	cmp    %ebx,%eax
  800ae0:	74 16                	je     800af8 <strncmp+0x31>
  800ae2:	0f b6 08             	movzbl (%eax),%ecx
  800ae5:	84 c9                	test   %cl,%cl
  800ae7:	74 04                	je     800aed <strncmp+0x26>
  800ae9:	3a 0a                	cmp    (%edx),%cl
  800aeb:	74 eb                	je     800ad8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aed:	0f b6 00             	movzbl (%eax),%eax
  800af0:	0f b6 12             	movzbl (%edx),%edx
  800af3:	29 d0                	sub    %edx,%eax
}
  800af5:	5b                   	pop    %ebx
  800af6:	5d                   	pop    %ebp
  800af7:	c3                   	ret    
		return 0;
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	eb f6                	jmp    800af5 <strncmp+0x2e>

00800aff <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b09:	0f b6 10             	movzbl (%eax),%edx
  800b0c:	84 d2                	test   %dl,%dl
  800b0e:	74 09                	je     800b19 <strchr+0x1a>
		if (*s == c)
  800b10:	38 ca                	cmp    %cl,%dl
  800b12:	74 0a                	je     800b1e <strchr+0x1f>
	for (; *s; s++)
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	eb f0                	jmp    800b09 <strchr+0xa>
			return (char *) s;
	return 0;
  800b19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b2a:	eb 03                	jmp    800b2f <strfind+0xf>
  800b2c:	83 c0 01             	add    $0x1,%eax
  800b2f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b32:	38 ca                	cmp    %cl,%dl
  800b34:	74 04                	je     800b3a <strfind+0x1a>
  800b36:	84 d2                	test   %dl,%dl
  800b38:	75 f2                	jne    800b2c <strfind+0xc>
			break;
	return (char *) s;
}
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b48:	85 c9                	test   %ecx,%ecx
  800b4a:	74 13                	je     800b5f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b52:	75 05                	jne    800b59 <memset+0x1d>
  800b54:	f6 c1 03             	test   $0x3,%cl
  800b57:	74 0d                	je     800b66 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5c:	fc                   	cld    
  800b5d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5f:	89 f8                	mov    %edi,%eax
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    
		c &= 0xFF;
  800b66:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6a:	89 d3                	mov    %edx,%ebx
  800b6c:	c1 e3 08             	shl    $0x8,%ebx
  800b6f:	89 d0                	mov    %edx,%eax
  800b71:	c1 e0 18             	shl    $0x18,%eax
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	c1 e6 10             	shl    $0x10,%esi
  800b79:	09 f0                	or     %esi,%eax
  800b7b:	09 c2                	or     %eax,%edx
  800b7d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b7f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b82:	89 d0                	mov    %edx,%eax
  800b84:	fc                   	cld    
  800b85:	f3 ab                	rep stos %eax,%es:(%edi)
  800b87:	eb d6                	jmp    800b5f <memset+0x23>

00800b89 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b94:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b97:	39 c6                	cmp    %eax,%esi
  800b99:	73 35                	jae    800bd0 <memmove+0x47>
  800b9b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9e:	39 c2                	cmp    %eax,%edx
  800ba0:	76 2e                	jbe    800bd0 <memmove+0x47>
		s += n;
		d += n;
  800ba2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	09 fe                	or     %edi,%esi
  800ba9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800baf:	74 0c                	je     800bbd <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb1:	83 ef 01             	sub    $0x1,%edi
  800bb4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bb7:	fd                   	std    
  800bb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bba:	fc                   	cld    
  800bbb:	eb 21                	jmp    800bde <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bbd:	f6 c1 03             	test   $0x3,%cl
  800bc0:	75 ef                	jne    800bb1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc2:	83 ef 04             	sub    $0x4,%edi
  800bc5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bcb:	fd                   	std    
  800bcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bce:	eb ea                	jmp    800bba <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bd0:	89 f2                	mov    %esi,%edx
  800bd2:	09 c2                	or     %eax,%edx
  800bd4:	f6 c2 03             	test   $0x3,%dl
  800bd7:	74 09                	je     800be2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be2:	f6 c1 03             	test   $0x3,%cl
  800be5:	75 f2                	jne    800bd9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bea:	89 c7                	mov    %eax,%edi
  800bec:	fc                   	cld    
  800bed:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bef:	eb ed                	jmp    800bde <memmove+0x55>

00800bf1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bf4:	ff 75 10             	pushl  0x10(%ebp)
  800bf7:	ff 75 0c             	pushl  0xc(%ebp)
  800bfa:	ff 75 08             	pushl  0x8(%ebp)
  800bfd:	e8 87 ff ff ff       	call   800b89 <memmove>
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0f:	89 c6                	mov    %eax,%esi
  800c11:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c14:	39 f0                	cmp    %esi,%eax
  800c16:	74 1c                	je     800c34 <memcmp+0x30>
		if (*s1 != *s2)
  800c18:	0f b6 08             	movzbl (%eax),%ecx
  800c1b:	0f b6 1a             	movzbl (%edx),%ebx
  800c1e:	38 d9                	cmp    %bl,%cl
  800c20:	75 08                	jne    800c2a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	83 c2 01             	add    $0x1,%edx
  800c28:	eb ea                	jmp    800c14 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c2a:	0f b6 c1             	movzbl %cl,%eax
  800c2d:	0f b6 db             	movzbl %bl,%ebx
  800c30:	29 d8                	sub    %ebx,%eax
  800c32:	eb 05                	jmp    800c39 <memcmp+0x35>
	}

	return 0;
  800c34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	8b 45 08             	mov    0x8(%ebp),%eax
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c46:	89 c2                	mov    %eax,%edx
  800c48:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c4b:	39 d0                	cmp    %edx,%eax
  800c4d:	73 09                	jae    800c58 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4f:	38 08                	cmp    %cl,(%eax)
  800c51:	74 05                	je     800c58 <memfind+0x1b>
	for (; s < ends; s++)
  800c53:	83 c0 01             	add    $0x1,%eax
  800c56:	eb f3                	jmp    800c4b <memfind+0xe>
			break;
	return (void *) s;
}
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c66:	eb 03                	jmp    800c6b <strtol+0x11>
		s++;
  800c68:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c6b:	0f b6 01             	movzbl (%ecx),%eax
  800c6e:	3c 20                	cmp    $0x20,%al
  800c70:	74 f6                	je     800c68 <strtol+0xe>
  800c72:	3c 09                	cmp    $0x9,%al
  800c74:	74 f2                	je     800c68 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c76:	3c 2b                	cmp    $0x2b,%al
  800c78:	74 2e                	je     800ca8 <strtol+0x4e>
	int neg = 0;
  800c7a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c7f:	3c 2d                	cmp    $0x2d,%al
  800c81:	74 2f                	je     800cb2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c83:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c89:	75 05                	jne    800c90 <strtol+0x36>
  800c8b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c8e:	74 2c                	je     800cbc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c90:	85 db                	test   %ebx,%ebx
  800c92:	75 0a                	jne    800c9e <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c94:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c99:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9c:	74 28                	je     800cc6 <strtol+0x6c>
		base = 10;
  800c9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ca6:	eb 50                	jmp    800cf8 <strtol+0x9e>
		s++;
  800ca8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cab:	bf 00 00 00 00       	mov    $0x0,%edi
  800cb0:	eb d1                	jmp    800c83 <strtol+0x29>
		s++, neg = 1;
  800cb2:	83 c1 01             	add    $0x1,%ecx
  800cb5:	bf 01 00 00 00       	mov    $0x1,%edi
  800cba:	eb c7                	jmp    800c83 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cbc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cc0:	74 0e                	je     800cd0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cc2:	85 db                	test   %ebx,%ebx
  800cc4:	75 d8                	jne    800c9e <strtol+0x44>
		s++, base = 8;
  800cc6:	83 c1 01             	add    $0x1,%ecx
  800cc9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cce:	eb ce                	jmp    800c9e <strtol+0x44>
		s += 2, base = 16;
  800cd0:	83 c1 02             	add    $0x2,%ecx
  800cd3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd8:	eb c4                	jmp    800c9e <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cda:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cdd:	89 f3                	mov    %esi,%ebx
  800cdf:	80 fb 19             	cmp    $0x19,%bl
  800ce2:	77 29                	ja     800d0d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ce4:	0f be d2             	movsbl %dl,%edx
  800ce7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cea:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ced:	7d 30                	jge    800d1f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cef:	83 c1 01             	add    $0x1,%ecx
  800cf2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf6:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cf8:	0f b6 11             	movzbl (%ecx),%edx
  800cfb:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cfe:	89 f3                	mov    %esi,%ebx
  800d00:	80 fb 09             	cmp    $0x9,%bl
  800d03:	77 d5                	ja     800cda <strtol+0x80>
			dig = *s - '0';
  800d05:	0f be d2             	movsbl %dl,%edx
  800d08:	83 ea 30             	sub    $0x30,%edx
  800d0b:	eb dd                	jmp    800cea <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d0d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d10:	89 f3                	mov    %esi,%ebx
  800d12:	80 fb 19             	cmp    $0x19,%bl
  800d15:	77 08                	ja     800d1f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d17:	0f be d2             	movsbl %dl,%edx
  800d1a:	83 ea 37             	sub    $0x37,%edx
  800d1d:	eb cb                	jmp    800cea <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d1f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d23:	74 05                	je     800d2a <strtol+0xd0>
		*endptr = (char *) s;
  800d25:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d28:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d2a:	89 c2                	mov    %eax,%edx
  800d2c:	f7 da                	neg    %edx
  800d2e:	85 ff                	test   %edi,%edi
  800d30:	0f 45 c2             	cmovne %edx,%eax
}
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
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
