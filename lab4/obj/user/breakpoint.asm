
obj/user/breakpoint：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800044:	e8 c6 00 00 00       	call   80010f <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800085:	6a 00                	push   $0x0
  800087:	e8 42 00 00 00       	call   8000ce <sys_env_destroy>
}
  80008c:	83 c4 10             	add    $0x10,%esp
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
	asm volatile("int %1\n"
  800097:	b8 00 00 00 00       	mov    $0x0,%eax
  80009c:	8b 55 08             	mov    0x8(%ebp),%edx
  80009f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a2:	89 c3                	mov    %eax,%ebx
  8000a4:	89 c7                	mov    %eax,%edi
  8000a6:	89 c6                	mov    %eax,%esi
  8000a8:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5f                   	pop    %edi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <sys_cgetc>:

int
sys_cgetc(void)
{
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bf:	89 d1                	mov    %edx,%ecx
  8000c1:	89 d3                	mov    %edx,%ebx
  8000c3:	89 d7                	mov    %edx,%edi
  8000c5:	89 d6                	mov    %edx,%esi
  8000c7:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c9:	5b                   	pop    %ebx
  8000ca:	5e                   	pop    %esi
  8000cb:	5f                   	pop    %edi
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	57                   	push   %edi
  8000d2:	56                   	push   %esi
  8000d3:	53                   	push   %ebx
  8000d4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e4:	89 cb                	mov    %ecx,%ebx
  8000e6:	89 cf                	mov    %ecx,%edi
  8000e8:	89 ce                	mov    %ecx,%esi
  8000ea:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000ec:	85 c0                	test   %eax,%eax
  8000ee:	7f 08                	jg     8000f8 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f3:	5b                   	pop    %ebx
  8000f4:	5e                   	pop    %esi
  8000f5:	5f                   	pop    %edi
  8000f6:	5d                   	pop    %ebp
  8000f7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 8a 0f 80 00       	push   $0x800f8a
  800103:	6a 23                	push   $0x23
  800105:	68 a7 0f 80 00       	push   $0x800fa7
  80010a:	e8 ed 01 00 00       	call   8002fc <_panic>

0080010f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	57                   	push   %edi
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
	asm volatile("int %1\n"
  800115:	ba 00 00 00 00       	mov    $0x0,%edx
  80011a:	b8 02 00 00 00       	mov    $0x2,%eax
  80011f:	89 d1                	mov    %edx,%ecx
  800121:	89 d3                	mov    %edx,%ebx
  800123:	89 d7                	mov    %edx,%edi
  800125:	89 d6                	mov    %edx,%esi
  800127:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800129:	5b                   	pop    %ebx
  80012a:	5e                   	pop    %esi
  80012b:	5f                   	pop    %edi
  80012c:	5d                   	pop    %ebp
  80012d:	c3                   	ret    

0080012e <sys_yield>:

void
sys_yield(void)
{
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	57                   	push   %edi
  800132:	56                   	push   %esi
  800133:	53                   	push   %ebx
	asm volatile("int %1\n"
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013e:	89 d1                	mov    %edx,%ecx
  800140:	89 d3                	mov    %edx,%ebx
  800142:	89 d7                	mov    %edx,%edi
  800144:	89 d6                	mov    %edx,%esi
  800146:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5f                   	pop    %edi
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	57                   	push   %edi
  800151:	56                   	push   %esi
  800152:	53                   	push   %ebx
  800153:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800156:	be 00 00 00 00       	mov    $0x0,%esi
  80015b:	8b 55 08             	mov    0x8(%ebp),%edx
  80015e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800161:	b8 04 00 00 00       	mov    $0x4,%eax
  800166:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800169:	89 f7                	mov    %esi,%edi
  80016b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7f 08                	jg     800179 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800171:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 8a 0f 80 00       	push   $0x800f8a
  800184:	6a 23                	push   $0x23
  800186:	68 a7 0f 80 00       	push   $0x800fa7
  80018b:	e8 6c 01 00 00       	call   8002fc <_panic>

00800190 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800199:	8b 55 08             	mov    0x8(%ebp),%edx
  80019c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019f:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001aa:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ad:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001af:	85 c0                	test   %eax,%eax
  8001b1:	7f 08                	jg     8001bb <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b6:	5b                   	pop    %ebx
  8001b7:	5e                   	pop    %esi
  8001b8:	5f                   	pop    %edi
  8001b9:	5d                   	pop    %ebp
  8001ba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 8a 0f 80 00       	push   $0x800f8a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 a7 0f 80 00       	push   $0x800fa7
  8001cd:	e8 2a 01 00 00       	call   8002fc <_panic>

008001d2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d2:	55                   	push   %ebp
  8001d3:	89 e5                	mov    %esp,%ebp
  8001d5:	57                   	push   %edi
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001eb:	89 df                	mov    %ebx,%edi
  8001ed:	89 de                	mov    %ebx,%esi
  8001ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f1:	85 c0                	test   %eax,%eax
  8001f3:	7f 08                	jg     8001fd <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f8:	5b                   	pop    %ebx
  8001f9:	5e                   	pop    %esi
  8001fa:	5f                   	pop    %edi
  8001fb:	5d                   	pop    %ebp
  8001fc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 8a 0f 80 00       	push   $0x800f8a
  800208:	6a 23                	push   $0x23
  80020a:	68 a7 0f 80 00       	push   $0x800fa7
  80020f:	e8 e8 00 00 00       	call   8002fc <_panic>

00800214 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	57                   	push   %edi
  800218:	56                   	push   %esi
  800219:	53                   	push   %ebx
  80021a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800222:	8b 55 08             	mov    0x8(%ebp),%edx
  800225:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800228:	b8 08 00 00 00       	mov    $0x8,%eax
  80022d:	89 df                	mov    %ebx,%edi
  80022f:	89 de                	mov    %ebx,%esi
  800231:	cd 30                	int    $0x30
	if(check && ret > 0)
  800233:	85 c0                	test   %eax,%eax
  800235:	7f 08                	jg     80023f <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800237:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023a:	5b                   	pop    %ebx
  80023b:	5e                   	pop    %esi
  80023c:	5f                   	pop    %edi
  80023d:	5d                   	pop    %ebp
  80023e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 8a 0f 80 00       	push   $0x800f8a
  80024a:	6a 23                	push   $0x23
  80024c:	68 a7 0f 80 00       	push   $0x800fa7
  800251:	e8 a6 00 00 00       	call   8002fc <_panic>

00800256 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800256:	55                   	push   %ebp
  800257:	89 e5                	mov    %esp,%ebp
  800259:	57                   	push   %edi
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
  80025c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800264:	8b 55 08             	mov    0x8(%ebp),%edx
  800267:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026a:	b8 09 00 00 00       	mov    $0x9,%eax
  80026f:	89 df                	mov    %ebx,%edi
  800271:	89 de                	mov    %ebx,%esi
  800273:	cd 30                	int    $0x30
	if(check && ret > 0)
  800275:	85 c0                	test   %eax,%eax
  800277:	7f 08                	jg     800281 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800279:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027c:	5b                   	pop    %ebx
  80027d:	5e                   	pop    %esi
  80027e:	5f                   	pop    %edi
  80027f:	5d                   	pop    %ebp
  800280:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 8a 0f 80 00       	push   $0x800f8a
  80028c:	6a 23                	push   $0x23
  80028e:	68 a7 0f 80 00       	push   $0x800fa7
  800293:	e8 64 00 00 00       	call   8002fc <_panic>

00800298 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	57                   	push   %edi
  80029c:	56                   	push   %esi
  80029d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029e:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a4:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ae:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b4:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d1:	89 cb                	mov    %ecx,%ebx
  8002d3:	89 cf                	mov    %ecx,%edi
  8002d5:	89 ce                	mov    %ecx,%esi
  8002d7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d9:	85 c0                	test   %eax,%eax
  8002db:	7f 08                	jg     8002e5 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e0:	5b                   	pop    %ebx
  8002e1:	5e                   	pop    %esi
  8002e2:	5f                   	pop    %edi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e5:	83 ec 0c             	sub    $0xc,%esp
  8002e8:	50                   	push   %eax
  8002e9:	6a 0c                	push   $0xc
  8002eb:	68 8a 0f 80 00       	push   $0x800f8a
  8002f0:	6a 23                	push   $0x23
  8002f2:	68 a7 0f 80 00       	push   $0x800fa7
  8002f7:	e8 00 00 00 00       	call   8002fc <_panic>

008002fc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fc:	55                   	push   %ebp
  8002fd:	89 e5                	mov    %esp,%ebp
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800301:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800304:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030a:	e8 00 fe ff ff       	call   80010f <sys_getenvid>
  80030f:	83 ec 0c             	sub    $0xc,%esp
  800312:	ff 75 0c             	pushl  0xc(%ebp)
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	56                   	push   %esi
  800319:	50                   	push   %eax
  80031a:	68 b8 0f 80 00       	push   $0x800fb8
  80031f:	e8 b3 00 00 00       	call   8003d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800324:	83 c4 18             	add    $0x18,%esp
  800327:	53                   	push   %ebx
  800328:	ff 75 10             	pushl  0x10(%ebp)
  80032b:	e8 56 00 00 00       	call   800386 <vcprintf>
	cprintf("\n");
  800330:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  800337:	e8 9b 00 00 00       	call   8003d7 <cprintf>
  80033c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033f:	cc                   	int3   
  800340:	eb fd                	jmp    80033f <_panic+0x43>

00800342 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	53                   	push   %ebx
  800346:	83 ec 04             	sub    $0x4,%esp
  800349:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034c:	8b 13                	mov    (%ebx),%edx
  80034e:	8d 42 01             	lea    0x1(%edx),%eax
  800351:	89 03                	mov    %eax,(%ebx)
  800353:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800356:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035f:	74 09                	je     80036a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800361:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800365:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800368:	c9                   	leave  
  800369:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80036a:	83 ec 08             	sub    $0x8,%esp
  80036d:	68 ff 00 00 00       	push   $0xff
  800372:	8d 43 08             	lea    0x8(%ebx),%eax
  800375:	50                   	push   %eax
  800376:	e8 16 fd ff ff       	call   800091 <sys_cputs>
		b->idx = 0;
  80037b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800381:	83 c4 10             	add    $0x10,%esp
  800384:	eb db                	jmp    800361 <putch+0x1f>

00800386 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800396:	00 00 00 
	b.cnt = 0;
  800399:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a3:	ff 75 0c             	pushl  0xc(%ebp)
  8003a6:	ff 75 08             	pushl  0x8(%ebp)
  8003a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003af:	50                   	push   %eax
  8003b0:	68 42 03 80 00       	push   $0x800342
  8003b5:	e8 1a 01 00 00       	call   8004d4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ba:	83 c4 08             	add    $0x8,%esp
  8003bd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c9:	50                   	push   %eax
  8003ca:	e8 c2 fc ff ff       	call   800091 <sys_cputs>

	return b.cnt;
}
  8003cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d5:	c9                   	leave  
  8003d6:	c3                   	ret    

008003d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e0:	50                   	push   %eax
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 9d ff ff ff       	call   800386 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	57                   	push   %edi
  8003ef:	56                   	push   %esi
  8003f0:	53                   	push   %ebx
  8003f1:	83 ec 1c             	sub    $0x1c,%esp
  8003f4:	89 c7                	mov    %eax,%edi
  8003f6:	89 d6                	mov    %edx,%esi
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800401:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800404:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800407:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80040f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800412:	39 d3                	cmp    %edx,%ebx
  800414:	72 05                	jb     80041b <printnum+0x30>
  800416:	39 45 10             	cmp    %eax,0x10(%ebp)
  800419:	77 7a                	ja     800495 <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041b:	83 ec 0c             	sub    $0xc,%esp
  80041e:	ff 75 18             	pushl  0x18(%ebp)
  800421:	8b 45 14             	mov    0x14(%ebp),%eax
  800424:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800427:	53                   	push   %ebx
  800428:	ff 75 10             	pushl  0x10(%ebp)
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800431:	ff 75 e0             	pushl  -0x20(%ebp)
  800434:	ff 75 dc             	pushl  -0x24(%ebp)
  800437:	ff 75 d8             	pushl  -0x28(%ebp)
  80043a:	e8 01 09 00 00       	call   800d40 <__udivdi3>
  80043f:	83 c4 18             	add    $0x18,%esp
  800442:	52                   	push   %edx
  800443:	50                   	push   %eax
  800444:	89 f2                	mov    %esi,%edx
  800446:	89 f8                	mov    %edi,%eax
  800448:	e8 9e ff ff ff       	call   8003eb <printnum>
  80044d:	83 c4 20             	add    $0x20,%esp
  800450:	eb 13                	jmp    800465 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	56                   	push   %esi
  800456:	ff 75 18             	pushl  0x18(%ebp)
  800459:	ff d7                	call   *%edi
  80045b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80045e:	83 eb 01             	sub    $0x1,%ebx
  800461:	85 db                	test   %ebx,%ebx
  800463:	7f ed                	jg     800452 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	83 ec 04             	sub    $0x4,%esp
  80046c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046f:	ff 75 e0             	pushl  -0x20(%ebp)
  800472:	ff 75 dc             	pushl  -0x24(%ebp)
  800475:	ff 75 d8             	pushl  -0x28(%ebp)
  800478:	e8 e3 09 00 00       	call   800e60 <__umoddi3>
  80047d:	83 c4 14             	add    $0x14,%esp
  800480:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  800487:	50                   	push   %eax
  800488:	ff d7                	call   *%edi
}
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800490:	5b                   	pop    %ebx
  800491:	5e                   	pop    %esi
  800492:	5f                   	pop    %edi
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    
  800495:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800498:	eb c4                	jmp    80045e <printnum+0x73>

0080049a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a4:	8b 10                	mov    (%eax),%edx
  8004a6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a9:	73 0a                	jae    8004b5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004ab:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ae:	89 08                	mov    %ecx,(%eax)
  8004b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b3:	88 02                	mov    %al,(%edx)
}
  8004b5:	5d                   	pop    %ebp
  8004b6:	c3                   	ret    

008004b7 <printfmt>:
{
  8004b7:	55                   	push   %ebp
  8004b8:	89 e5                	mov    %esp,%ebp
  8004ba:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004bd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c0:	50                   	push   %eax
  8004c1:	ff 75 10             	pushl  0x10(%ebp)
  8004c4:	ff 75 0c             	pushl  0xc(%ebp)
  8004c7:	ff 75 08             	pushl  0x8(%ebp)
  8004ca:	e8 05 00 00 00       	call   8004d4 <vprintfmt>
}
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <vprintfmt>:
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	57                   	push   %edi
  8004d8:	56                   	push   %esi
  8004d9:	53                   	push   %ebx
  8004da:	83 ec 2c             	sub    $0x2c,%esp
  8004dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e6:	e9 c1 03 00 00       	jmp    8008ac <vprintfmt+0x3d8>
		padc = ' ';
  8004eb:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  8004ef:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  8004f6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  8004fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800504:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800509:	8d 47 01             	lea    0x1(%edi),%eax
  80050c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80050f:	0f b6 17             	movzbl (%edi),%edx
  800512:	8d 42 dd             	lea    -0x23(%edx),%eax
  800515:	3c 55                	cmp    $0x55,%al
  800517:	0f 87 12 04 00 00    	ja     80092f <vprintfmt+0x45b>
  80051d:	0f b6 c0             	movzbl %al,%eax
  800520:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  800527:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80052a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  80052e:	eb d9                	jmp    800509 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800533:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800537:	eb d0                	jmp    800509 <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800539:	0f b6 d2             	movzbl %dl,%edx
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80053f:	b8 00 00 00 00       	mov    $0x0,%eax
  800544:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800547:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80054a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80054e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800551:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800554:	83 f9 09             	cmp    $0x9,%ecx
  800557:	77 55                	ja     8005ae <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  800559:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80055c:	eb e9                	jmp    800547 <vprintfmt+0x73>
			precision = va_arg(ap, int);
  80055e:	8b 45 14             	mov    0x14(%ebp),%eax
  800561:	8b 00                	mov    (%eax),%eax
  800563:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80056f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800572:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800576:	79 91                	jns    800509 <vprintfmt+0x35>
				width = precision, precision = -1;
  800578:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80057b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80057e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800585:	eb 82                	jmp    800509 <vprintfmt+0x35>
  800587:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80058a:	85 c0                	test   %eax,%eax
  80058c:	ba 00 00 00 00       	mov    $0x0,%edx
  800591:	0f 49 d0             	cmovns %eax,%edx
  800594:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800597:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059a:	e9 6a ff ff ff       	jmp    800509 <vprintfmt+0x35>
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005a2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005a9:	e9 5b ff ff ff       	jmp    800509 <vprintfmt+0x35>
  8005ae:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005b4:	eb bc                	jmp    800572 <vprintfmt+0x9e>
			lflag++;
  8005b6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005bc:	e9 48 ff ff ff       	jmp    800509 <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 78 04             	lea    0x4(%eax),%edi
  8005c7:	83 ec 08             	sub    $0x8,%esp
  8005ca:	53                   	push   %ebx
  8005cb:	ff 30                	pushl  (%eax)
  8005cd:	ff d6                	call   *%esi
			break;
  8005cf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005d2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005d5:	e9 cf 02 00 00       	jmp    8008a9 <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8d 78 04             	lea    0x4(%eax),%edi
  8005e0:	8b 00                	mov    (%eax),%eax
  8005e2:	99                   	cltd   
  8005e3:	31 d0                	xor    %edx,%eax
  8005e5:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005e7:	83 f8 08             	cmp    $0x8,%eax
  8005ea:	7f 23                	jg     80060f <vprintfmt+0x13b>
  8005ec:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  8005f3:	85 d2                	test   %edx,%edx
  8005f5:	74 18                	je     80060f <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  8005f7:	52                   	push   %edx
  8005f8:	68 ff 0f 80 00       	push   $0x800fff
  8005fd:	53                   	push   %ebx
  8005fe:	56                   	push   %esi
  8005ff:	e8 b3 fe ff ff       	call   8004b7 <printfmt>
  800604:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800607:	89 7d 14             	mov    %edi,0x14(%ebp)
  80060a:	e9 9a 02 00 00       	jmp    8008a9 <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  80060f:	50                   	push   %eax
  800610:	68 f6 0f 80 00       	push   $0x800ff6
  800615:	53                   	push   %ebx
  800616:	56                   	push   %esi
  800617:	e8 9b fe ff ff       	call   8004b7 <printfmt>
  80061c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80061f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800622:	e9 82 02 00 00       	jmp    8008a9 <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	83 c0 04             	add    $0x4,%eax
  80062d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800635:	85 ff                	test   %edi,%edi
  800637:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  80063c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80063f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800643:	0f 8e bd 00 00 00    	jle    800706 <vprintfmt+0x232>
  800649:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80064d:	75 0e                	jne    80065d <vprintfmt+0x189>
  80064f:	89 75 08             	mov    %esi,0x8(%ebp)
  800652:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800655:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800658:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065b:	eb 6d                	jmp    8006ca <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  80065d:	83 ec 08             	sub    $0x8,%esp
  800660:	ff 75 d0             	pushl  -0x30(%ebp)
  800663:	57                   	push   %edi
  800664:	e8 6e 03 00 00       	call   8009d7 <strnlen>
  800669:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80066c:	29 c1                	sub    %eax,%ecx
  80066e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800674:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800678:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80067b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80067e:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800680:	eb 0f                	jmp    800691 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800682:	83 ec 08             	sub    $0x8,%esp
  800685:	53                   	push   %ebx
  800686:	ff 75 e0             	pushl  -0x20(%ebp)
  800689:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80068b:	83 ef 01             	sub    $0x1,%edi
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	85 ff                	test   %edi,%edi
  800693:	7f ed                	jg     800682 <vprintfmt+0x1ae>
  800695:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800698:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069b:	85 c9                	test   %ecx,%ecx
  80069d:	b8 00 00 00 00       	mov    $0x0,%eax
  8006a2:	0f 49 c1             	cmovns %ecx,%eax
  8006a5:	29 c1                	sub    %eax,%ecx
  8006a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8006aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006b0:	89 cb                	mov    %ecx,%ebx
  8006b2:	eb 16                	jmp    8006ca <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006b4:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006b8:	75 31                	jne    8006eb <vprintfmt+0x217>
					putch(ch, putdat);
  8006ba:	83 ec 08             	sub    $0x8,%esp
  8006bd:	ff 75 0c             	pushl  0xc(%ebp)
  8006c0:	50                   	push   %eax
  8006c1:	ff 55 08             	call   *0x8(%ebp)
  8006c4:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006c7:	83 eb 01             	sub    $0x1,%ebx
  8006ca:	83 c7 01             	add    $0x1,%edi
  8006cd:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006d1:	0f be c2             	movsbl %dl,%eax
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 59                	je     800731 <vprintfmt+0x25d>
  8006d8:	85 f6                	test   %esi,%esi
  8006da:	78 d8                	js     8006b4 <vprintfmt+0x1e0>
  8006dc:	83 ee 01             	sub    $0x1,%esi
  8006df:	79 d3                	jns    8006b4 <vprintfmt+0x1e0>
  8006e1:	89 df                	mov    %ebx,%edi
  8006e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8006e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006e9:	eb 37                	jmp    800722 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  8006eb:	0f be d2             	movsbl %dl,%edx
  8006ee:	83 ea 20             	sub    $0x20,%edx
  8006f1:	83 fa 5e             	cmp    $0x5e,%edx
  8006f4:	76 c4                	jbe    8006ba <vprintfmt+0x1e6>
					putch('?', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	6a 3f                	push   $0x3f
  8006fe:	ff 55 08             	call   *0x8(%ebp)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb c1                	jmp    8006c7 <vprintfmt+0x1f3>
  800706:	89 75 08             	mov    %esi,0x8(%ebp)
  800709:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80070c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800712:	eb b6                	jmp    8006ca <vprintfmt+0x1f6>
				putch(' ', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	53                   	push   %ebx
  800718:	6a 20                	push   $0x20
  80071a:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80071c:	83 ef 01             	sub    $0x1,%edi
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	85 ff                	test   %edi,%edi
  800724:	7f ee                	jg     800714 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  800726:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
  80072c:	e9 78 01 00 00       	jmp    8008a9 <vprintfmt+0x3d5>
  800731:	89 df                	mov    %ebx,%edi
  800733:	8b 75 08             	mov    0x8(%ebp),%esi
  800736:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800739:	eb e7                	jmp    800722 <vprintfmt+0x24e>
	if (lflag >= 2)
  80073b:	83 f9 01             	cmp    $0x1,%ecx
  80073e:	7e 3f                	jle    80077f <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8b 50 04             	mov    0x4(%eax),%edx
  800746:	8b 00                	mov    (%eax),%eax
  800748:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80074e:	8b 45 14             	mov    0x14(%ebp),%eax
  800751:	8d 40 08             	lea    0x8(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800757:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80075b:	79 5c                	jns    8007b9 <vprintfmt+0x2e5>
				putch('-', putdat);
  80075d:	83 ec 08             	sub    $0x8,%esp
  800760:	53                   	push   %ebx
  800761:	6a 2d                	push   $0x2d
  800763:	ff d6                	call   *%esi
				num = -(long long) num;
  800765:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800768:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80076b:	f7 da                	neg    %edx
  80076d:	83 d1 00             	adc    $0x0,%ecx
  800770:	f7 d9                	neg    %ecx
  800772:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800775:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077a:	e9 10 01 00 00       	jmp    80088f <vprintfmt+0x3bb>
	else if (lflag)
  80077f:	85 c9                	test   %ecx,%ecx
  800781:	75 1b                	jne    80079e <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 00                	mov    (%eax),%eax
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 c1                	mov    %eax,%ecx
  80078d:	c1 f9 1f             	sar    $0x1f,%ecx
  800790:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 40 04             	lea    0x4(%eax),%eax
  800799:	89 45 14             	mov    %eax,0x14(%ebp)
  80079c:	eb b9                	jmp    800757 <vprintfmt+0x283>
		return va_arg(*ap, long);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a6:	89 c1                	mov    %eax,%ecx
  8007a8:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 40 04             	lea    0x4(%eax),%eax
  8007b4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b7:	eb 9e                	jmp    800757 <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007b9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007c4:	e9 c6 00 00 00       	jmp    80088f <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007c9:	83 f9 01             	cmp    $0x1,%ecx
  8007cc:	7e 18                	jle    8007e6 <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8007ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d1:	8b 10                	mov    (%eax),%edx
  8007d3:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d6:	8d 40 08             	lea    0x8(%eax),%eax
  8007d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007dc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007e1:	e9 a9 00 00 00       	jmp    80088f <vprintfmt+0x3bb>
	else if (lflag)
  8007e6:	85 c9                	test   %ecx,%ecx
  8007e8:	75 1a                	jne    800804 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	8b 10                	mov    (%eax),%edx
  8007ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f4:	8d 40 04             	lea    0x4(%eax),%eax
  8007f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ff:	e9 8b 00 00 00       	jmp    80088f <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800804:	8b 45 14             	mov    0x14(%ebp),%eax
  800807:	8b 10                	mov    (%eax),%edx
  800809:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080e:	8d 40 04             	lea    0x4(%eax),%eax
  800811:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800814:	b8 0a 00 00 00       	mov    $0xa,%eax
  800819:	eb 74                	jmp    80088f <vprintfmt+0x3bb>
	if (lflag >= 2)
  80081b:	83 f9 01             	cmp    $0x1,%ecx
  80081e:	7e 15                	jle    800835 <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800820:	8b 45 14             	mov    0x14(%ebp),%eax
  800823:	8b 10                	mov    (%eax),%edx
  800825:	8b 48 04             	mov    0x4(%eax),%ecx
  800828:	8d 40 08             	lea    0x8(%eax),%eax
  80082b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80082e:	b8 08 00 00 00       	mov    $0x8,%eax
  800833:	eb 5a                	jmp    80088f <vprintfmt+0x3bb>
	else if (lflag)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	75 17                	jne    800850 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	8b 10                	mov    (%eax),%edx
  80083e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800843:	8d 40 04             	lea    0x4(%eax),%eax
  800846:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800849:	b8 08 00 00 00       	mov    $0x8,%eax
  80084e:	eb 3f                	jmp    80088f <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8b 10                	mov    (%eax),%edx
  800855:	b9 00 00 00 00       	mov    $0x0,%ecx
  80085a:	8d 40 04             	lea    0x4(%eax),%eax
  80085d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800860:	b8 08 00 00 00       	mov    $0x8,%eax
  800865:	eb 28                	jmp    80088f <vprintfmt+0x3bb>
			putch('0', putdat);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	53                   	push   %ebx
  80086b:	6a 30                	push   $0x30
  80086d:	ff d6                	call   *%esi
			putch('x', putdat);
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 78                	push   $0x78
  800875:	ff d6                	call   *%esi
			num = (unsigned long long)
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8b 10                	mov    (%eax),%edx
  80087c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800881:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800884:	8d 40 04             	lea    0x4(%eax),%eax
  800887:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80088a:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80088f:	83 ec 0c             	sub    $0xc,%esp
  800892:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800896:	57                   	push   %edi
  800897:	ff 75 e0             	pushl  -0x20(%ebp)
  80089a:	50                   	push   %eax
  80089b:	51                   	push   %ecx
  80089c:	52                   	push   %edx
  80089d:	89 da                	mov    %ebx,%edx
  80089f:	89 f0                	mov    %esi,%eax
  8008a1:	e8 45 fb ff ff       	call   8003eb <printnum>
			break;
  8008a6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008ac:	83 c7 01             	add    $0x1,%edi
  8008af:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008b3:	83 f8 25             	cmp    $0x25,%eax
  8008b6:	0f 84 2f fc ff ff    	je     8004eb <vprintfmt+0x17>
			if (ch == '\0')
  8008bc:	85 c0                	test   %eax,%eax
  8008be:	0f 84 8b 00 00 00    	je     80094f <vprintfmt+0x47b>
			putch(ch, putdat);
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	53                   	push   %ebx
  8008c8:	50                   	push   %eax
  8008c9:	ff d6                	call   *%esi
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb dc                	jmp    8008ac <vprintfmt+0x3d8>
	if (lflag >= 2)
  8008d0:	83 f9 01             	cmp    $0x1,%ecx
  8008d3:	7e 15                	jle    8008ea <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8008d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d8:	8b 10                	mov    (%eax),%edx
  8008da:	8b 48 04             	mov    0x4(%eax),%ecx
  8008dd:	8d 40 08             	lea    0x8(%eax),%eax
  8008e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e3:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e8:	eb a5                	jmp    80088f <vprintfmt+0x3bb>
	else if (lflag)
  8008ea:	85 c9                	test   %ecx,%ecx
  8008ec:	75 17                	jne    800905 <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8b 10                	mov    (%eax),%edx
  8008f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008f8:	8d 40 04             	lea    0x4(%eax),%eax
  8008fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008fe:	b8 10 00 00 00       	mov    $0x10,%eax
  800903:	eb 8a                	jmp    80088f <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800905:	8b 45 14             	mov    0x14(%ebp),%eax
  800908:	8b 10                	mov    (%eax),%edx
  80090a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090f:	8d 40 04             	lea    0x4(%eax),%eax
  800912:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800915:	b8 10 00 00 00       	mov    $0x10,%eax
  80091a:	e9 70 ff ff ff       	jmp    80088f <vprintfmt+0x3bb>
			putch(ch, putdat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	53                   	push   %ebx
  800923:	6a 25                	push   $0x25
  800925:	ff d6                	call   *%esi
			break;
  800927:	83 c4 10             	add    $0x10,%esp
  80092a:	e9 7a ff ff ff       	jmp    8008a9 <vprintfmt+0x3d5>
			putch('%', putdat);
  80092f:	83 ec 08             	sub    $0x8,%esp
  800932:	53                   	push   %ebx
  800933:	6a 25                	push   $0x25
  800935:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	89 f8                	mov    %edi,%eax
  80093c:	eb 03                	jmp    800941 <vprintfmt+0x46d>
  80093e:	83 e8 01             	sub    $0x1,%eax
  800941:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800945:	75 f7                	jne    80093e <vprintfmt+0x46a>
  800947:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094a:	e9 5a ff ff ff       	jmp    8008a9 <vprintfmt+0x3d5>
}
  80094f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5f                   	pop    %edi
  800955:	5d                   	pop    %ebp
  800956:	c3                   	ret    

00800957 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800957:	55                   	push   %ebp
  800958:	89 e5                	mov    %esp,%ebp
  80095a:	83 ec 18             	sub    $0x18,%esp
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800963:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800966:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80096a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80096d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800974:	85 c0                	test   %eax,%eax
  800976:	74 26                	je     80099e <vsnprintf+0x47>
  800978:	85 d2                	test   %edx,%edx
  80097a:	7e 22                	jle    80099e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80097c:	ff 75 14             	pushl  0x14(%ebp)
  80097f:	ff 75 10             	pushl  0x10(%ebp)
  800982:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800985:	50                   	push   %eax
  800986:	68 9a 04 80 00       	push   $0x80049a
  80098b:	e8 44 fb ff ff       	call   8004d4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800990:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800993:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800996:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800999:	83 c4 10             	add    $0x10,%esp
}
  80099c:	c9                   	leave  
  80099d:	c3                   	ret    
		return -E_INVAL;
  80099e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009a3:	eb f7                	jmp    80099c <vsnprintf+0x45>

008009a5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009ab:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009ae:	50                   	push   %eax
  8009af:	ff 75 10             	pushl  0x10(%ebp)
  8009b2:	ff 75 0c             	pushl  0xc(%ebp)
  8009b5:	ff 75 08             	pushl  0x8(%ebp)
  8009b8:	e8 9a ff ff ff       	call   800957 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ca:	eb 03                	jmp    8009cf <strlen+0x10>
		n++;
  8009cc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009cf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009d3:	75 f7                	jne    8009cc <strlen+0xd>
	return n;
}
  8009d5:	5d                   	pop    %ebp
  8009d6:	c3                   	ret    

008009d7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009d7:	55                   	push   %ebp
  8009d8:	89 e5                	mov    %esp,%ebp
  8009da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e5:	eb 03                	jmp    8009ea <strnlen+0x13>
		n++;
  8009e7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ea:	39 d0                	cmp    %edx,%eax
  8009ec:	74 06                	je     8009f4 <strnlen+0x1d>
  8009ee:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009f2:	75 f3                	jne    8009e7 <strnlen+0x10>
	return n;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	53                   	push   %ebx
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a00:	89 c2                	mov    %eax,%edx
  800a02:	83 c1 01             	add    $0x1,%ecx
  800a05:	83 c2 01             	add    $0x1,%edx
  800a08:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a0c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a0f:	84 db                	test   %bl,%bl
  800a11:	75 ef                	jne    800a02 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a13:	5b                   	pop    %ebx
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a1d:	53                   	push   %ebx
  800a1e:	e8 9c ff ff ff       	call   8009bf <strlen>
  800a23:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a26:	ff 75 0c             	pushl  0xc(%ebp)
  800a29:	01 d8                	add    %ebx,%eax
  800a2b:	50                   	push   %eax
  800a2c:	e8 c5 ff ff ff       	call   8009f6 <strcpy>
	return dst;
}
  800a31:	89 d8                	mov    %ebx,%eax
  800a33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a36:	c9                   	leave  
  800a37:	c3                   	ret    

00800a38 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a43:	89 f3                	mov    %esi,%ebx
  800a45:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a48:	89 f2                	mov    %esi,%edx
  800a4a:	eb 0f                	jmp    800a5b <strncpy+0x23>
		*dst++ = *src;
  800a4c:	83 c2 01             	add    $0x1,%edx
  800a4f:	0f b6 01             	movzbl (%ecx),%eax
  800a52:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a55:	80 39 01             	cmpb   $0x1,(%ecx)
  800a58:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a5b:	39 da                	cmp    %ebx,%edx
  800a5d:	75 ed                	jne    800a4c <strncpy+0x14>
	}
	return ret;
}
  800a5f:	89 f0                	mov    %esi,%eax
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a70:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a73:	89 f0                	mov    %esi,%eax
  800a75:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a79:	85 c9                	test   %ecx,%ecx
  800a7b:	75 0b                	jne    800a88 <strlcpy+0x23>
  800a7d:	eb 17                	jmp    800a96 <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7f:	83 c2 01             	add    $0x1,%edx
  800a82:	83 c0 01             	add    $0x1,%eax
  800a85:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a88:	39 d8                	cmp    %ebx,%eax
  800a8a:	74 07                	je     800a93 <strlcpy+0x2e>
  800a8c:	0f b6 0a             	movzbl (%edx),%ecx
  800a8f:	84 c9                	test   %cl,%cl
  800a91:	75 ec                	jne    800a7f <strlcpy+0x1a>
		*dst = '\0';
  800a93:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a96:	29 f0                	sub    %esi,%eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa5:	eb 06                	jmp    800aad <strcmp+0x11>
		p++, q++;
  800aa7:	83 c1 01             	add    $0x1,%ecx
  800aaa:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aad:	0f b6 01             	movzbl (%ecx),%eax
  800ab0:	84 c0                	test   %al,%al
  800ab2:	74 04                	je     800ab8 <strcmp+0x1c>
  800ab4:	3a 02                	cmp    (%edx),%al
  800ab6:	74 ef                	je     800aa7 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab8:	0f b6 c0             	movzbl %al,%eax
  800abb:	0f b6 12             	movzbl (%edx),%edx
  800abe:	29 d0                	sub    %edx,%eax
}
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	53                   	push   %ebx
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acc:	89 c3                	mov    %eax,%ebx
  800ace:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad1:	eb 06                	jmp    800ad9 <strncmp+0x17>
		n--, p++, q++;
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ad9:	39 d8                	cmp    %ebx,%eax
  800adb:	74 16                	je     800af3 <strncmp+0x31>
  800add:	0f b6 08             	movzbl (%eax),%ecx
  800ae0:	84 c9                	test   %cl,%cl
  800ae2:	74 04                	je     800ae8 <strncmp+0x26>
  800ae4:	3a 0a                	cmp    (%edx),%cl
  800ae6:	74 eb                	je     800ad3 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae8:	0f b6 00             	movzbl (%eax),%eax
  800aeb:	0f b6 12             	movzbl (%edx),%edx
  800aee:	29 d0                	sub    %edx,%eax
}
  800af0:	5b                   	pop    %ebx
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    
		return 0;
  800af3:	b8 00 00 00 00       	mov    $0x0,%eax
  800af8:	eb f6                	jmp    800af0 <strncmp+0x2e>

00800afa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	8b 45 08             	mov    0x8(%ebp),%eax
  800b00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b04:	0f b6 10             	movzbl (%eax),%edx
  800b07:	84 d2                	test   %dl,%dl
  800b09:	74 09                	je     800b14 <strchr+0x1a>
		if (*s == c)
  800b0b:	38 ca                	cmp    %cl,%dl
  800b0d:	74 0a                	je     800b19 <strchr+0x1f>
	for (; *s; s++)
  800b0f:	83 c0 01             	add    $0x1,%eax
  800b12:	eb f0                	jmp    800b04 <strchr+0xa>
			return (char *) s;
	return 0;
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b25:	eb 03                	jmp    800b2a <strfind+0xf>
  800b27:	83 c0 01             	add    $0x1,%eax
  800b2a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b2d:	38 ca                	cmp    %cl,%dl
  800b2f:	74 04                	je     800b35 <strfind+0x1a>
  800b31:	84 d2                	test   %dl,%dl
  800b33:	75 f2                	jne    800b27 <strfind+0xc>
			break;
	return (char *) s;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b43:	85 c9                	test   %ecx,%ecx
  800b45:	74 13                	je     800b5a <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4d:	75 05                	jne    800b54 <memset+0x1d>
  800b4f:	f6 c1 03             	test   $0x3,%cl
  800b52:	74 0d                	je     800b61 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	fc                   	cld    
  800b58:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b5a:	89 f8                	mov    %edi,%eax
  800b5c:	5b                   	pop    %ebx
  800b5d:	5e                   	pop    %esi
  800b5e:	5f                   	pop    %edi
  800b5f:	5d                   	pop    %ebp
  800b60:	c3                   	ret    
		c &= 0xFF;
  800b61:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	c1 e3 08             	shl    $0x8,%ebx
  800b6a:	89 d0                	mov    %edx,%eax
  800b6c:	c1 e0 18             	shl    $0x18,%eax
  800b6f:	89 d6                	mov    %edx,%esi
  800b71:	c1 e6 10             	shl    $0x10,%esi
  800b74:	09 f0                	or     %esi,%eax
  800b76:	09 c2                	or     %eax,%edx
  800b78:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b7a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b7d:	89 d0                	mov    %edx,%eax
  800b7f:	fc                   	cld    
  800b80:	f3 ab                	rep stos %eax,%es:(%edi)
  800b82:	eb d6                	jmp    800b5a <memset+0x23>

00800b84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	57                   	push   %edi
  800b88:	56                   	push   %esi
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b92:	39 c6                	cmp    %eax,%esi
  800b94:	73 35                	jae    800bcb <memmove+0x47>
  800b96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b99:	39 c2                	cmp    %eax,%edx
  800b9b:	76 2e                	jbe    800bcb <memmove+0x47>
		s += n;
		d += n;
  800b9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba0:	89 d6                	mov    %edx,%esi
  800ba2:	09 fe                	or     %edi,%esi
  800ba4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800baa:	74 0c                	je     800bb8 <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bac:	83 ef 01             	sub    $0x1,%edi
  800baf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bb2:	fd                   	std    
  800bb3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb5:	fc                   	cld    
  800bb6:	eb 21                	jmp    800bd9 <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb8:	f6 c1 03             	test   $0x3,%cl
  800bbb:	75 ef                	jne    800bac <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bbd:	83 ef 04             	sub    $0x4,%edi
  800bc0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bc3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bc6:	fd                   	std    
  800bc7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bc9:	eb ea                	jmp    800bb5 <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcb:	89 f2                	mov    %esi,%edx
  800bcd:	09 c2                	or     %eax,%edx
  800bcf:	f6 c2 03             	test   $0x3,%dl
  800bd2:	74 09                	je     800bdd <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bd4:	89 c7                	mov    %eax,%edi
  800bd6:	fc                   	cld    
  800bd7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bdd:	f6 c1 03             	test   $0x3,%cl
  800be0:	75 f2                	jne    800bd4 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800be2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800be5:	89 c7                	mov    %eax,%edi
  800be7:	fc                   	cld    
  800be8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bea:	eb ed                	jmp    800bd9 <memmove+0x55>

00800bec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bef:	ff 75 10             	pushl  0x10(%ebp)
  800bf2:	ff 75 0c             	pushl  0xc(%ebp)
  800bf5:	ff 75 08             	pushl  0x8(%ebp)
  800bf8:	e8 87 ff ff ff       	call   800b84 <memmove>
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0a:	89 c6                	mov    %eax,%esi
  800c0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0f:	39 f0                	cmp    %esi,%eax
  800c11:	74 1c                	je     800c2f <memcmp+0x30>
		if (*s1 != *s2)
  800c13:	0f b6 08             	movzbl (%eax),%ecx
  800c16:	0f b6 1a             	movzbl (%edx),%ebx
  800c19:	38 d9                	cmp    %bl,%cl
  800c1b:	75 08                	jne    800c25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c1d:	83 c0 01             	add    $0x1,%eax
  800c20:	83 c2 01             	add    $0x1,%edx
  800c23:	eb ea                	jmp    800c0f <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c25:	0f b6 c1             	movzbl %cl,%eax
  800c28:	0f b6 db             	movzbl %bl,%ebx
  800c2b:	29 d8                	sub    %ebx,%eax
  800c2d:	eb 05                	jmp    800c34 <memcmp+0x35>
	}

	return 0;
  800c2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c41:	89 c2                	mov    %eax,%edx
  800c43:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c46:	39 d0                	cmp    %edx,%eax
  800c48:	73 09                	jae    800c53 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c4a:	38 08                	cmp    %cl,(%eax)
  800c4c:	74 05                	je     800c53 <memfind+0x1b>
	for (; s < ends; s++)
  800c4e:	83 c0 01             	add    $0x1,%eax
  800c51:	eb f3                	jmp    800c46 <memfind+0xe>
			break;
	return (void *) s;
}
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c61:	eb 03                	jmp    800c66 <strtol+0x11>
		s++;
  800c63:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c66:	0f b6 01             	movzbl (%ecx),%eax
  800c69:	3c 20                	cmp    $0x20,%al
  800c6b:	74 f6                	je     800c63 <strtol+0xe>
  800c6d:	3c 09                	cmp    $0x9,%al
  800c6f:	74 f2                	je     800c63 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c71:	3c 2b                	cmp    $0x2b,%al
  800c73:	74 2e                	je     800ca3 <strtol+0x4e>
	int neg = 0;
  800c75:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c7a:	3c 2d                	cmp    $0x2d,%al
  800c7c:	74 2f                	je     800cad <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c84:	75 05                	jne    800c8b <strtol+0x36>
  800c86:	80 39 30             	cmpb   $0x30,(%ecx)
  800c89:	74 2c                	je     800cb7 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c8b:	85 db                	test   %ebx,%ebx
  800c8d:	75 0a                	jne    800c99 <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8f:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800c94:	80 39 30             	cmpb   $0x30,(%ecx)
  800c97:	74 28                	je     800cc1 <strtol+0x6c>
		base = 10;
  800c99:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ca1:	eb 50                	jmp    800cf3 <strtol+0x9e>
		s++;
  800ca3:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	eb d1                	jmp    800c7e <strtol+0x29>
		s++, neg = 1;
  800cad:	83 c1 01             	add    $0x1,%ecx
  800cb0:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb5:	eb c7                	jmp    800c7e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cbb:	74 0e                	je     800ccb <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cbd:	85 db                	test   %ebx,%ebx
  800cbf:	75 d8                	jne    800c99 <strtol+0x44>
		s++, base = 8;
  800cc1:	83 c1 01             	add    $0x1,%ecx
  800cc4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cc9:	eb ce                	jmp    800c99 <strtol+0x44>
		s += 2, base = 16;
  800ccb:	83 c1 02             	add    $0x2,%ecx
  800cce:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd3:	eb c4                	jmp    800c99 <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cd5:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cd8:	89 f3                	mov    %esi,%ebx
  800cda:	80 fb 19             	cmp    $0x19,%bl
  800cdd:	77 29                	ja     800d08 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cdf:	0f be d2             	movsbl %dl,%edx
  800ce2:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ce5:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ce8:	7d 30                	jge    800d1a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cea:	83 c1 01             	add    $0x1,%ecx
  800ced:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cf1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cf3:	0f b6 11             	movzbl (%ecx),%edx
  800cf6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cf9:	89 f3                	mov    %esi,%ebx
  800cfb:	80 fb 09             	cmp    $0x9,%bl
  800cfe:	77 d5                	ja     800cd5 <strtol+0x80>
			dig = *s - '0';
  800d00:	0f be d2             	movsbl %dl,%edx
  800d03:	83 ea 30             	sub    $0x30,%edx
  800d06:	eb dd                	jmp    800ce5 <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d08:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d0b:	89 f3                	mov    %esi,%ebx
  800d0d:	80 fb 19             	cmp    $0x19,%bl
  800d10:	77 08                	ja     800d1a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d12:	0f be d2             	movsbl %dl,%edx
  800d15:	83 ea 37             	sub    $0x37,%edx
  800d18:	eb cb                	jmp    800ce5 <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d1a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d1e:	74 05                	je     800d25 <strtol+0xd0>
		*endptr = (char *) s;
  800d20:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d23:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d25:	89 c2                	mov    %eax,%edx
  800d27:	f7 da                	neg    %edx
  800d29:	85 ff                	test   %edi,%edi
  800d2b:	0f 45 c2             	cmovne %edx,%eax
}
  800d2e:	5b                   	pop    %ebx
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
  800d33:	66 90                	xchg   %ax,%ax
  800d35:	66 90                	xchg   %ax,%ax
  800d37:	66 90                	xchg   %ax,%ax
  800d39:	66 90                	xchg   %ax,%ax
  800d3b:	66 90                	xchg   %ax,%ax
  800d3d:	66 90                	xchg   %ax,%ax
  800d3f:	90                   	nop

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
