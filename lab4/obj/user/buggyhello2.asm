
obj/user/buggyhello2：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
	thisenv = envs + ENVX(envid); 
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7f 08                	jg     80010d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 b8 0f 80 00       	push   $0x800fb8
  800118:	6a 23                	push   $0x23
  80011a:	68 d5 0f 80 00       	push   $0x800fd5
  80011f:	e8 ed 01 00 00       	call   800311 <_panic>

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800176:	b8 04 00 00 00       	mov    $0x4,%eax
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7f 08                	jg     80018e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800186:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800189:	5b                   	pop    %ebx
  80018a:	5e                   	pop    %esi
  80018b:	5f                   	pop    %edi
  80018c:	5d                   	pop    %ebp
  80018d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 b8 0f 80 00       	push   $0x800fb8
  800199:	6a 23                	push   $0x23
  80019b:	68 d5 0f 80 00       	push   $0x800fd5
  8001a0:	e8 6c 01 00 00       	call   800311 <_panic>

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7f 08                	jg     8001d0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cb:	5b                   	pop    %ebx
  8001cc:	5e                   	pop    %esi
  8001cd:	5f                   	pop    %edi
  8001ce:	5d                   	pop    %ebp
  8001cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 b8 0f 80 00       	push   $0x800fb8
  8001db:	6a 23                	push   $0x23
  8001dd:	68 d5 0f 80 00       	push   $0x800fd5
  8001e2:	e8 2a 01 00 00       	call   800311 <_panic>

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fb:	b8 06 00 00 00       	mov    $0x6,%eax
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7f 08                	jg     800212 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5f                   	pop    %edi
  800210:	5d                   	pop    %ebp
  800211:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 b8 0f 80 00       	push   $0x800fb8
  80021d:	6a 23                	push   $0x23
  80021f:	68 d5 0f 80 00       	push   $0x800fd5
  800224:	e8 e8 00 00 00       	call   800311 <_panic>

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023d:	b8 08 00 00 00       	mov    $0x8,%eax
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7f 08                	jg     800254 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80024c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024f:	5b                   	pop    %ebx
  800250:	5e                   	pop    %esi
  800251:	5f                   	pop    %edi
  800252:	5d                   	pop    %ebp
  800253:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 b8 0f 80 00       	push   $0x800fb8
  80025f:	6a 23                	push   $0x23
  800261:	68 d5 0f 80 00       	push   $0x800fd5
  800266:	e8 a6 00 00 00       	call   800311 <_panic>

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027f:	b8 09 00 00 00       	mov    $0x9,%eax
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7f 08                	jg     800296 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 b8 0f 80 00       	push   $0x800fb8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 d5 0f 80 00       	push   $0x800fd5
  8002a8:	e8 64 00 00 00       	call   800311 <_panic>

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002be:	be 00 00 00 00       	mov    $0x0,%esi
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7f 08                	jg     8002fa <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	50                   	push   %eax
  8002fe:	6a 0c                	push   $0xc
  800300:	68 b8 0f 80 00       	push   $0x800fb8
  800305:	6a 23                	push   $0x23
  800307:	68 d5 0f 80 00       	push   $0x800fd5
  80030c:	e8 00 00 00 00       	call   800311 <_panic>

00800311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800319:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80031f:	e8 00 fe ff ff       	call   800124 <sys_getenvid>
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	56                   	push   %esi
  80032e:	50                   	push   %eax
  80032f:	68 e4 0f 80 00       	push   $0x800fe4
  800334:	e8 b3 00 00 00       	call   8003ec <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	e8 56 00 00 00       	call   80039b <vcprintf>
	cprintf("\n");
  800345:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  80034c:	e8 9b 00 00 00       	call   8003ec <cprintf>
  800351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800354:	cc                   	int3   
  800355:	eb fd                	jmp    800354 <_panic+0x43>

00800357 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	53                   	push   %ebx
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800361:	8b 13                	mov    (%ebx),%edx
  800363:	8d 42 01             	lea    0x1(%edx),%eax
  800366:	89 03                	mov    %eax,(%ebx)
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800374:	74 09                	je     80037f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800376:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80037a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80037d:	c9                   	leave  
  80037e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80037f:	83 ec 08             	sub    $0x8,%esp
  800382:	68 ff 00 00 00       	push   $0xff
  800387:	8d 43 08             	lea    0x8(%ebx),%eax
  80038a:	50                   	push   %eax
  80038b:	e8 16 fd ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  800390:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	eb db                	jmp    800376 <putch+0x1f>

0080039b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003ab:	00 00 00 
	b.cnt = 0;
  8003ae:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b8:	ff 75 0c             	pushl  0xc(%ebp)
  8003bb:	ff 75 08             	pushl  0x8(%ebp)
  8003be:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c4:	50                   	push   %eax
  8003c5:	68 57 03 80 00       	push   $0x800357
  8003ca:	e8 1a 01 00 00       	call   8004e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cf:	83 c4 08             	add    $0x8,%esp
  8003d2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003de:	50                   	push   %eax
  8003df:	e8 c2 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8003e4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f5:	50                   	push   %eax
  8003f6:	ff 75 08             	pushl  0x8(%ebp)
  8003f9:	e8 9d ff ff ff       	call   80039b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	57                   	push   %edi
  800404:	56                   	push   %esi
  800405:	53                   	push   %ebx
  800406:	83 ec 1c             	sub    $0x1c,%esp
  800409:	89 c7                	mov    %eax,%edi
  80040b:	89 d6                	mov    %edx,%esi
  80040d:	8b 45 08             	mov    0x8(%ebp),%eax
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800419:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800421:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800424:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800427:	39 d3                	cmp    %edx,%ebx
  800429:	72 05                	jb     800430 <printnum+0x30>
  80042b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042e:	77 7a                	ja     8004aa <printnum+0xaa>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800430:	83 ec 0c             	sub    $0xc,%esp
  800433:	ff 75 18             	pushl  0x18(%ebp)
  800436:	8b 45 14             	mov    0x14(%ebp),%eax
  800439:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043c:	53                   	push   %ebx
  80043d:	ff 75 10             	pushl  0x10(%ebp)
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	ff 75 e4             	pushl  -0x1c(%ebp)
  800446:	ff 75 e0             	pushl  -0x20(%ebp)
  800449:	ff 75 dc             	pushl  -0x24(%ebp)
  80044c:	ff 75 d8             	pushl  -0x28(%ebp)
  80044f:	e8 fc 08 00 00       	call   800d50 <__udivdi3>
  800454:	83 c4 18             	add    $0x18,%esp
  800457:	52                   	push   %edx
  800458:	50                   	push   %eax
  800459:	89 f2                	mov    %esi,%edx
  80045b:	89 f8                	mov    %edi,%eax
  80045d:	e8 9e ff ff ff       	call   800400 <printnum>
  800462:	83 c4 20             	add    $0x20,%esp
  800465:	eb 13                	jmp    80047a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800467:	83 ec 08             	sub    $0x8,%esp
  80046a:	56                   	push   %esi
  80046b:	ff 75 18             	pushl  0x18(%ebp)
  80046e:	ff d7                	call   *%edi
  800470:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800473:	83 eb 01             	sub    $0x1,%ebx
  800476:	85 db                	test   %ebx,%ebx
  800478:	7f ed                	jg     800467 <printnum+0x67>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	56                   	push   %esi
  80047e:	83 ec 04             	sub    $0x4,%esp
  800481:	ff 75 e4             	pushl  -0x1c(%ebp)
  800484:	ff 75 e0             	pushl  -0x20(%ebp)
  800487:	ff 75 dc             	pushl  -0x24(%ebp)
  80048a:	ff 75 d8             	pushl  -0x28(%ebp)
  80048d:	e8 de 09 00 00       	call   800e70 <__umoddi3>
  800492:	83 c4 14             	add    $0x14,%esp
  800495:	0f be 80 08 10 80 00 	movsbl 0x801008(%eax),%eax
  80049c:	50                   	push   %eax
  80049d:	ff d7                	call   *%edi
}
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a5:	5b                   	pop    %ebx
  8004a6:	5e                   	pop    %esi
  8004a7:	5f                   	pop    %edi
  8004a8:	5d                   	pop    %ebp
  8004a9:	c3                   	ret    
  8004aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8004ad:	eb c4                	jmp    800473 <printnum+0x73>

008004af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b9:	8b 10                	mov    (%eax),%edx
  8004bb:	3b 50 04             	cmp    0x4(%eax),%edx
  8004be:	73 0a                	jae    8004ca <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c0:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c3:	89 08                	mov    %ecx,(%eax)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	88 02                	mov    %al,(%edx)
}
  8004ca:	5d                   	pop    %ebp
  8004cb:	c3                   	ret    

008004cc <printfmt>:
{
  8004cc:	55                   	push   %ebp
  8004cd:	89 e5                	mov    %esp,%ebp
  8004cf:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004d2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d5:	50                   	push   %eax
  8004d6:	ff 75 10             	pushl  0x10(%ebp)
  8004d9:	ff 75 0c             	pushl  0xc(%ebp)
  8004dc:	ff 75 08             	pushl  0x8(%ebp)
  8004df:	e8 05 00 00 00       	call   8004e9 <vprintfmt>
}
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    

008004e9 <vprintfmt>:
{
  8004e9:	55                   	push   %ebp
  8004ea:	89 e5                	mov    %esp,%ebp
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	53                   	push   %ebx
  8004ef:	83 ec 2c             	sub    $0x2c,%esp
  8004f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f8:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fb:	e9 c1 03 00 00       	jmp    8008c1 <vprintfmt+0x3d8>
		padc = ' ';
  800500:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
		altflag = 0;
  800504:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
		precision = -1;
  80050b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
		width = -1;
  800512:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800519:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8d 47 01             	lea    0x1(%edi),%eax
  800521:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800524:	0f b6 17             	movzbl (%edi),%edx
  800527:	8d 42 dd             	lea    -0x23(%edx),%eax
  80052a:	3c 55                	cmp    $0x55,%al
  80052c:	0f 87 12 04 00 00    	ja     800944 <vprintfmt+0x45b>
  800532:	0f b6 c0             	movzbl %al,%eax
  800535:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80053f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
  800543:	eb d9                	jmp    80051e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '0';
  800548:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80054c:	eb d0                	jmp    80051e <vprintfmt+0x35>
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	0f b6 d2             	movzbl %dl,%edx
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800554:	b8 00 00 00 00       	mov    $0x0,%eax
  800559:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80055c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800563:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800566:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800569:	83 f9 09             	cmp    $0x9,%ecx
  80056c:	77 55                	ja     8005c3 <vprintfmt+0xda>
			for (precision = 0; ; ++fmt) {
  80056e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800571:	eb e9                	jmp    80055c <vprintfmt+0x73>
			precision = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 40 04             	lea    0x4(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	79 91                	jns    80051e <vprintfmt+0x35>
				width = precision, precision = -1;
  80058d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800590:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800593:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80059a:	eb 82                	jmp    80051e <vprintfmt+0x35>
  80059c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a6:	0f 49 d0             	cmovns %eax,%edx
  8005a9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005af:	e9 6a ff ff ff       	jmp    80051e <vprintfmt+0x35>
  8005b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005b7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005be:	e9 5b ff ff ff       	jmp    80051e <vprintfmt+0x35>
  8005c3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005c9:	eb bc                	jmp    800587 <vprintfmt+0x9e>
			lflag++;
  8005cb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d1:	e9 48 ff ff ff       	jmp    80051e <vprintfmt+0x35>
			putch(va_arg(ap, int), putdat);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 78 04             	lea    0x4(%eax),%edi
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	53                   	push   %ebx
  8005e0:	ff 30                	pushl  (%eax)
  8005e2:	ff d6                	call   *%esi
			break;
  8005e4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005e7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ea:	e9 cf 02 00 00       	jmp    8008be <vprintfmt+0x3d5>
			err = va_arg(ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 78 04             	lea    0x4(%eax),%edi
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	99                   	cltd   
  8005f8:	31 d0                	xor    %edx,%eax
  8005fa:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fc:	83 f8 08             	cmp    $0x8,%eax
  8005ff:	7f 23                	jg     800624 <vprintfmt+0x13b>
  800601:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  800608:	85 d2                	test   %edx,%edx
  80060a:	74 18                	je     800624 <vprintfmt+0x13b>
				printfmt(putch, putdat, "%s", p);
  80060c:	52                   	push   %edx
  80060d:	68 29 10 80 00       	push   $0x801029
  800612:	53                   	push   %ebx
  800613:	56                   	push   %esi
  800614:	e8 b3 fe ff ff       	call   8004cc <printfmt>
  800619:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80061c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80061f:	e9 9a 02 00 00       	jmp    8008be <vprintfmt+0x3d5>
				printfmt(putch, putdat, "error %d", err);
  800624:	50                   	push   %eax
  800625:	68 20 10 80 00       	push   $0x801020
  80062a:	53                   	push   %ebx
  80062b:	56                   	push   %esi
  80062c:	e8 9b fe ff ff       	call   8004cc <printfmt>
  800631:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800634:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800637:	e9 82 02 00 00       	jmp    8008be <vprintfmt+0x3d5>
			if ((p = va_arg(ap, char *)) == NULL)
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	83 c0 04             	add    $0x4,%eax
  800642:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800645:	8b 45 14             	mov    0x14(%ebp),%eax
  800648:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80064a:	85 ff                	test   %edi,%edi
  80064c:	b8 19 10 80 00       	mov    $0x801019,%eax
  800651:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800654:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800658:	0f 8e bd 00 00 00    	jle    80071b <vprintfmt+0x232>
  80065e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800662:	75 0e                	jne    800672 <vprintfmt+0x189>
  800664:	89 75 08             	mov    %esi,0x8(%ebp)
  800667:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80066d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800670:	eb 6d                	jmp    8006df <vprintfmt+0x1f6>
				for (width -= strnlen(p, precision); width > 0; width--)
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	ff 75 d0             	pushl  -0x30(%ebp)
  800678:	57                   	push   %edi
  800679:	e8 6e 03 00 00       	call   8009ec <strnlen>
  80067e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800681:	29 c1                	sub    %eax,%ecx
  800683:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800686:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800689:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80068d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800690:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800693:	89 cf                	mov    %ecx,%edi
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	eb 0f                	jmp    8006a6 <vprintfmt+0x1bd>
					putch(padc, putdat);
  800697:	83 ec 08             	sub    $0x8,%esp
  80069a:	53                   	push   %ebx
  80069b:	ff 75 e0             	pushl  -0x20(%ebp)
  80069e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	83 ef 01             	sub    $0x1,%edi
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	85 ff                	test   %edi,%edi
  8006a8:	7f ed                	jg     800697 <vprintfmt+0x1ae>
  8006aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ad:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b0:	85 c9                	test   %ecx,%ecx
  8006b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b7:	0f 49 c1             	cmovns %ecx,%eax
  8006ba:	29 c1                	sub    %eax,%ecx
  8006bc:	89 75 08             	mov    %esi,0x8(%ebp)
  8006bf:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006c5:	89 cb                	mov    %ecx,%ebx
  8006c7:	eb 16                	jmp    8006df <vprintfmt+0x1f6>
				if (altflag && (ch < ' ' || ch > '~'))
  8006c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006cd:	75 31                	jne    800700 <vprintfmt+0x217>
					putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	ff 75 0c             	pushl  0xc(%ebp)
  8006d5:	50                   	push   %eax
  8006d6:	ff 55 08             	call   *0x8(%ebp)
  8006d9:	83 c4 10             	add    $0x10,%esp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006dc:	83 eb 01             	sub    $0x1,%ebx
  8006df:	83 c7 01             	add    $0x1,%edi
  8006e2:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
  8006e6:	0f be c2             	movsbl %dl,%eax
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 59                	je     800746 <vprintfmt+0x25d>
  8006ed:	85 f6                	test   %esi,%esi
  8006ef:	78 d8                	js     8006c9 <vprintfmt+0x1e0>
  8006f1:	83 ee 01             	sub    $0x1,%esi
  8006f4:	79 d3                	jns    8006c9 <vprintfmt+0x1e0>
  8006f6:	89 df                	mov    %ebx,%edi
  8006f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006fe:	eb 37                	jmp    800737 <vprintfmt+0x24e>
				if (altflag && (ch < ' ' || ch > '~'))
  800700:	0f be d2             	movsbl %dl,%edx
  800703:	83 ea 20             	sub    $0x20,%edx
  800706:	83 fa 5e             	cmp    $0x5e,%edx
  800709:	76 c4                	jbe    8006cf <vprintfmt+0x1e6>
					putch('?', putdat);
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	ff 75 0c             	pushl  0xc(%ebp)
  800711:	6a 3f                	push   $0x3f
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	83 c4 10             	add    $0x10,%esp
  800719:	eb c1                	jmp    8006dc <vprintfmt+0x1f3>
  80071b:	89 75 08             	mov    %esi,0x8(%ebp)
  80071e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800721:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800724:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800727:	eb b6                	jmp    8006df <vprintfmt+0x1f6>
				putch(' ', putdat);
  800729:	83 ec 08             	sub    $0x8,%esp
  80072c:	53                   	push   %ebx
  80072d:	6a 20                	push   $0x20
  80072f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800731:	83 ef 01             	sub    $0x1,%edi
  800734:	83 c4 10             	add    $0x10,%esp
  800737:	85 ff                	test   %edi,%edi
  800739:	7f ee                	jg     800729 <vprintfmt+0x240>
			if ((p = va_arg(ap, char *)) == NULL)
  80073b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
  800741:	e9 78 01 00 00       	jmp    8008be <vprintfmt+0x3d5>
  800746:	89 df                	mov    %ebx,%edi
  800748:	8b 75 08             	mov    0x8(%ebp),%esi
  80074b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80074e:	eb e7                	jmp    800737 <vprintfmt+0x24e>
	if (lflag >= 2)
  800750:	83 f9 01             	cmp    $0x1,%ecx
  800753:	7e 3f                	jle    800794 <vprintfmt+0x2ab>
		return va_arg(*ap, long long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 50 04             	mov    0x4(%eax),%edx
  80075b:	8b 00                	mov    (%eax),%eax
  80075d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800760:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800763:	8b 45 14             	mov    0x14(%ebp),%eax
  800766:	8d 40 08             	lea    0x8(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80076c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800770:	79 5c                	jns    8007ce <vprintfmt+0x2e5>
				putch('-', putdat);
  800772:	83 ec 08             	sub    $0x8,%esp
  800775:	53                   	push   %ebx
  800776:	6a 2d                	push   $0x2d
  800778:	ff d6                	call   *%esi
				num = -(long long) num;
  80077a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800780:	f7 da                	neg    %edx
  800782:	83 d1 00             	adc    $0x0,%ecx
  800785:	f7 d9                	neg    %ecx
  800787:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80078a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80078f:	e9 10 01 00 00       	jmp    8008a4 <vprintfmt+0x3bb>
	else if (lflag)
  800794:	85 c9                	test   %ecx,%ecx
  800796:	75 1b                	jne    8007b3 <vprintfmt+0x2ca>
		return va_arg(*ap, int);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8b 00                	mov    (%eax),%eax
  80079d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a0:	89 c1                	mov    %eax,%ecx
  8007a2:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8d 40 04             	lea    0x4(%eax),%eax
  8007ae:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b1:	eb b9                	jmp    80076c <vprintfmt+0x283>
		return va_arg(*ap, long);
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8b 00                	mov    (%eax),%eax
  8007b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bb:	89 c1                	mov    %eax,%ecx
  8007bd:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c6:	8d 40 04             	lea    0x4(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007cc:	eb 9e                	jmp    80076c <vprintfmt+0x283>
			num = getint(&ap, lflag);
  8007ce:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d9:	e9 c6 00 00 00       	jmp    8008a4 <vprintfmt+0x3bb>
	if (lflag >= 2)
  8007de:	83 f9 01             	cmp    $0x1,%ecx
  8007e1:	7e 18                	jle    8007fb <vprintfmt+0x312>
		return va_arg(*ap, unsigned long long);
  8007e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e6:	8b 10                	mov    (%eax),%edx
  8007e8:	8b 48 04             	mov    0x4(%eax),%ecx
  8007eb:	8d 40 08             	lea    0x8(%eax),%eax
  8007ee:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007f6:	e9 a9 00 00 00       	jmp    8008a4 <vprintfmt+0x3bb>
	else if (lflag)
  8007fb:	85 c9                	test   %ecx,%ecx
  8007fd:	75 1a                	jne    800819 <vprintfmt+0x330>
		return va_arg(*ap, unsigned int);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	b9 00 00 00 00       	mov    $0x0,%ecx
  800809:	8d 40 04             	lea    0x4(%eax),%eax
  80080c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800814:	e9 8b 00 00 00       	jmp    8008a4 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800823:	8d 40 04             	lea    0x4(%eax),%eax
  800826:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800829:	b8 0a 00 00 00       	mov    $0xa,%eax
  80082e:	eb 74                	jmp    8008a4 <vprintfmt+0x3bb>
	if (lflag >= 2)
  800830:	83 f9 01             	cmp    $0x1,%ecx
  800833:	7e 15                	jle    80084a <vprintfmt+0x361>
		return va_arg(*ap, unsigned long long);
  800835:	8b 45 14             	mov    0x14(%ebp),%eax
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	8b 48 04             	mov    0x4(%eax),%ecx
  80083d:	8d 40 08             	lea    0x8(%eax),%eax
  800840:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800843:	b8 08 00 00 00       	mov    $0x8,%eax
  800848:	eb 5a                	jmp    8008a4 <vprintfmt+0x3bb>
	else if (lflag)
  80084a:	85 c9                	test   %ecx,%ecx
  80084c:	75 17                	jne    800865 <vprintfmt+0x37c>
		return va_arg(*ap, unsigned int);
  80084e:	8b 45 14             	mov    0x14(%ebp),%eax
  800851:	8b 10                	mov    (%eax),%edx
  800853:	b9 00 00 00 00       	mov    $0x0,%ecx
  800858:	8d 40 04             	lea    0x4(%eax),%eax
  80085b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80085e:	b8 08 00 00 00       	mov    $0x8,%eax
  800863:	eb 3f                	jmp    8008a4 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086f:	8d 40 04             	lea    0x4(%eax),%eax
  800872:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800875:	b8 08 00 00 00       	mov    $0x8,%eax
  80087a:	eb 28                	jmp    8008a4 <vprintfmt+0x3bb>
			putch('0', putdat);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	53                   	push   %ebx
  800880:	6a 30                	push   $0x30
  800882:	ff d6                	call   *%esi
			putch('x', putdat);
  800884:	83 c4 08             	add    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 78                	push   $0x78
  80088a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80088c:	8b 45 14             	mov    0x14(%ebp),%eax
  80088f:	8b 10                	mov    (%eax),%edx
  800891:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800896:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800899:	8d 40 04             	lea    0x4(%eax),%eax
  80089c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008a4:	83 ec 0c             	sub    $0xc,%esp
  8008a7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008ab:	57                   	push   %edi
  8008ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8008af:	50                   	push   %eax
  8008b0:	51                   	push   %ecx
  8008b1:	52                   	push   %edx
  8008b2:	89 da                	mov    %ebx,%edx
  8008b4:	89 f0                	mov    %esi,%eax
  8008b6:	e8 45 fb ff ff       	call   800400 <printnum>
			break;
  8008bb:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c1:	83 c7 01             	add    $0x1,%edi
  8008c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008c8:	83 f8 25             	cmp    $0x25,%eax
  8008cb:	0f 84 2f fc ff ff    	je     800500 <vprintfmt+0x17>
			if (ch == '\0')
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	0f 84 8b 00 00 00    	je     800964 <vprintfmt+0x47b>
			putch(ch, putdat);
  8008d9:	83 ec 08             	sub    $0x8,%esp
  8008dc:	53                   	push   %ebx
  8008dd:	50                   	push   %eax
  8008de:	ff d6                	call   *%esi
  8008e0:	83 c4 10             	add    $0x10,%esp
  8008e3:	eb dc                	jmp    8008c1 <vprintfmt+0x3d8>
	if (lflag >= 2)
  8008e5:	83 f9 01             	cmp    $0x1,%ecx
  8008e8:	7e 15                	jle    8008ff <vprintfmt+0x416>
		return va_arg(*ap, unsigned long long);
  8008ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ed:	8b 10                	mov    (%eax),%edx
  8008ef:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f2:	8d 40 08             	lea    0x8(%eax),%eax
  8008f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f8:	b8 10 00 00 00       	mov    $0x10,%eax
  8008fd:	eb a5                	jmp    8008a4 <vprintfmt+0x3bb>
	else if (lflag)
  8008ff:	85 c9                	test   %ecx,%ecx
  800901:	75 17                	jne    80091a <vprintfmt+0x431>
		return va_arg(*ap, unsigned int);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 10                	mov    (%eax),%edx
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090d:	8d 40 04             	lea    0x4(%eax),%eax
  800910:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800913:	b8 10 00 00 00       	mov    $0x10,%eax
  800918:	eb 8a                	jmp    8008a4 <vprintfmt+0x3bb>
		return va_arg(*ap, unsigned long);
  80091a:	8b 45 14             	mov    0x14(%ebp),%eax
  80091d:	8b 10                	mov    (%eax),%edx
  80091f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800924:	8d 40 04             	lea    0x4(%eax),%eax
  800927:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80092a:	b8 10 00 00 00       	mov    $0x10,%eax
  80092f:	e9 70 ff ff ff       	jmp    8008a4 <vprintfmt+0x3bb>
			putch(ch, putdat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	53                   	push   %ebx
  800938:	6a 25                	push   $0x25
  80093a:	ff d6                	call   *%esi
			break;
  80093c:	83 c4 10             	add    $0x10,%esp
  80093f:	e9 7a ff ff ff       	jmp    8008be <vprintfmt+0x3d5>
			putch('%', putdat);
  800944:	83 ec 08             	sub    $0x8,%esp
  800947:	53                   	push   %ebx
  800948:	6a 25                	push   $0x25
  80094a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	89 f8                	mov    %edi,%eax
  800951:	eb 03                	jmp    800956 <vprintfmt+0x46d>
  800953:	83 e8 01             	sub    $0x1,%eax
  800956:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80095a:	75 f7                	jne    800953 <vprintfmt+0x46a>
  80095c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80095f:	e9 5a ff ff ff       	jmp    8008be <vprintfmt+0x3d5>
}
  800964:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 18             	sub    $0x18,%esp
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800978:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80097f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800982:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800989:	85 c0                	test   %eax,%eax
  80098b:	74 26                	je     8009b3 <vsnprintf+0x47>
  80098d:	85 d2                	test   %edx,%edx
  80098f:	7e 22                	jle    8009b3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800991:	ff 75 14             	pushl  0x14(%ebp)
  800994:	ff 75 10             	pushl  0x10(%ebp)
  800997:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099a:	50                   	push   %eax
  80099b:	68 af 04 80 00       	push   $0x8004af
  8009a0:	e8 44 fb ff ff       	call   8004e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009ae:	83 c4 10             	add    $0x10,%esp
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    
		return -E_INVAL;
  8009b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009b8:	eb f7                	jmp    8009b1 <vsnprintf+0x45>

008009ba <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009c0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009c3:	50                   	push   %eax
  8009c4:	ff 75 10             	pushl  0x10(%ebp)
  8009c7:	ff 75 0c             	pushl  0xc(%ebp)
  8009ca:	ff 75 08             	pushl  0x8(%ebp)
  8009cd:	e8 9a ff ff ff       	call   80096c <vsnprintf>
	va_end(ap);

	return rc;
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009da:	b8 00 00 00 00       	mov    $0x0,%eax
  8009df:	eb 03                	jmp    8009e4 <strlen+0x10>
		n++;
  8009e1:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009e4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e8:	75 f7                	jne    8009e1 <strlen+0xd>
	return n;
}
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fa:	eb 03                	jmp    8009ff <strnlen+0x13>
		n++;
  8009fc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ff:	39 d0                	cmp    %edx,%eax
  800a01:	74 06                	je     800a09 <strnlen+0x1d>
  800a03:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a07:	75 f3                	jne    8009fc <strnlen+0x10>
	return n;
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a15:	89 c2                	mov    %eax,%edx
  800a17:	83 c1 01             	add    $0x1,%ecx
  800a1a:	83 c2 01             	add    $0x1,%edx
  800a1d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a21:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a24:	84 db                	test   %bl,%bl
  800a26:	75 ef                	jne    800a17 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a28:	5b                   	pop    %ebx
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a32:	53                   	push   %ebx
  800a33:	e8 9c ff ff ff       	call   8009d4 <strlen>
  800a38:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a3b:	ff 75 0c             	pushl  0xc(%ebp)
  800a3e:	01 d8                	add    %ebx,%eax
  800a40:	50                   	push   %eax
  800a41:	e8 c5 ff ff ff       	call   800a0b <strcpy>
	return dst;
}
  800a46:	89 d8                	mov    %ebx,%eax
  800a48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 75 08             	mov    0x8(%ebp),%esi
  800a55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a58:	89 f3                	mov    %esi,%ebx
  800a5a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a5d:	89 f2                	mov    %esi,%edx
  800a5f:	eb 0f                	jmp    800a70 <strncpy+0x23>
		*dst++ = *src;
  800a61:	83 c2 01             	add    $0x1,%edx
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a6a:	80 39 01             	cmpb   $0x1,(%ecx)
  800a6d:	83 d9 ff             	sbb    $0xffffffff,%ecx
	for (i = 0; i < size; i++) {
  800a70:	39 da                	cmp    %ebx,%edx
  800a72:	75 ed                	jne    800a61 <strncpy+0x14>
	}
	return ret;
}
  800a74:	89 f0                	mov    %esi,%eax
  800a76:	5b                   	pop    %ebx
  800a77:	5e                   	pop    %esi
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	56                   	push   %esi
  800a7e:	53                   	push   %ebx
  800a7f:	8b 75 08             	mov    0x8(%ebp),%esi
  800a82:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a85:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800a88:	89 f0                	mov    %esi,%eax
  800a8a:	8d 5c 0e ff          	lea    -0x1(%esi,%ecx,1),%ebx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a8e:	85 c9                	test   %ecx,%ecx
  800a90:	75 0b                	jne    800a9d <strlcpy+0x23>
  800a92:	eb 17                	jmp    800aab <strlcpy+0x31>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a94:	83 c2 01             	add    $0x1,%edx
  800a97:	83 c0 01             	add    $0x1,%eax
  800a9a:	88 48 ff             	mov    %cl,-0x1(%eax)
		while (--size > 0 && *src != '\0')
  800a9d:	39 d8                	cmp    %ebx,%eax
  800a9f:	74 07                	je     800aa8 <strlcpy+0x2e>
  800aa1:	0f b6 0a             	movzbl (%edx),%ecx
  800aa4:	84 c9                	test   %cl,%cl
  800aa6:	75 ec                	jne    800a94 <strlcpy+0x1a>
		*dst = '\0';
  800aa8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aab:	29 f0                	sub    %esi,%eax
}
  800aad:	5b                   	pop    %ebx
  800aae:	5e                   	pop    %esi
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aba:	eb 06                	jmp    800ac2 <strcmp+0x11>
		p++, q++;
  800abc:	83 c1 01             	add    $0x1,%ecx
  800abf:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ac2:	0f b6 01             	movzbl (%ecx),%eax
  800ac5:	84 c0                	test   %al,%al
  800ac7:	74 04                	je     800acd <strcmp+0x1c>
  800ac9:	3a 02                	cmp    (%edx),%al
  800acb:	74 ef                	je     800abc <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800acd:	0f b6 c0             	movzbl %al,%eax
  800ad0:	0f b6 12             	movzbl (%edx),%edx
  800ad3:	29 d0                	sub    %edx,%eax
}
  800ad5:	5d                   	pop    %ebp
  800ad6:	c3                   	ret    

00800ad7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	53                   	push   %ebx
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae1:	89 c3                	mov    %eax,%ebx
  800ae3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae6:	eb 06                	jmp    800aee <strncmp+0x17>
		n--, p++, q++;
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aee:	39 d8                	cmp    %ebx,%eax
  800af0:	74 16                	je     800b08 <strncmp+0x31>
  800af2:	0f b6 08             	movzbl (%eax),%ecx
  800af5:	84 c9                	test   %cl,%cl
  800af7:	74 04                	je     800afd <strncmp+0x26>
  800af9:	3a 0a                	cmp    (%edx),%cl
  800afb:	74 eb                	je     800ae8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800afd:	0f b6 00             	movzbl (%eax),%eax
  800b00:	0f b6 12             	movzbl (%edx),%edx
  800b03:	29 d0                	sub    %edx,%eax
}
  800b05:	5b                   	pop    %ebx
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    
		return 0;
  800b08:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0d:	eb f6                	jmp    800b05 <strncmp+0x2e>

00800b0f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b19:	0f b6 10             	movzbl (%eax),%edx
  800b1c:	84 d2                	test   %dl,%dl
  800b1e:	74 09                	je     800b29 <strchr+0x1a>
		if (*s == c)
  800b20:	38 ca                	cmp    %cl,%dl
  800b22:	74 0a                	je     800b2e <strchr+0x1f>
	for (; *s; s++)
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	eb f0                	jmp    800b19 <strchr+0xa>
			return (char *) s;
	return 0;
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b3a:	eb 03                	jmp    800b3f <strfind+0xf>
  800b3c:	83 c0 01             	add    $0x1,%eax
  800b3f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b42:	38 ca                	cmp    %cl,%dl
  800b44:	74 04                	je     800b4a <strfind+0x1a>
  800b46:	84 d2                	test   %dl,%dl
  800b48:	75 f2                	jne    800b3c <strfind+0xc>
			break;
	return (char *) s;
}
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	53                   	push   %ebx
  800b52:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b58:	85 c9                	test   %ecx,%ecx
  800b5a:	74 13                	je     800b6f <memset+0x23>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5c:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b62:	75 05                	jne    800b69 <memset+0x1d>
  800b64:	f6 c1 03             	test   $0x3,%cl
  800b67:	74 0d                	je     800b76 <memset+0x2a>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6c:	fc                   	cld    
  800b6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6f:	89 f8                	mov    %edi,%eax
  800b71:	5b                   	pop    %ebx
  800b72:	5e                   	pop    %esi
  800b73:	5f                   	pop    %edi
  800b74:	5d                   	pop    %ebp
  800b75:	c3                   	ret    
		c &= 0xFF;
  800b76:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b7a:	89 d3                	mov    %edx,%ebx
  800b7c:	c1 e3 08             	shl    $0x8,%ebx
  800b7f:	89 d0                	mov    %edx,%eax
  800b81:	c1 e0 18             	shl    $0x18,%eax
  800b84:	89 d6                	mov    %edx,%esi
  800b86:	c1 e6 10             	shl    $0x10,%esi
  800b89:	09 f0                	or     %esi,%eax
  800b8b:	09 c2                	or     %eax,%edx
  800b8d:	09 da                	or     %ebx,%edx
			:: "D" (v), "a" (c), "c" (n/4)
  800b8f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b92:	89 d0                	mov    %edx,%eax
  800b94:	fc                   	cld    
  800b95:	f3 ab                	rep stos %eax,%es:(%edi)
  800b97:	eb d6                	jmp    800b6f <memset+0x23>

00800b99 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba7:	39 c6                	cmp    %eax,%esi
  800ba9:	73 35                	jae    800be0 <memmove+0x47>
  800bab:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bae:	39 c2                	cmp    %eax,%edx
  800bb0:	76 2e                	jbe    800be0 <memmove+0x47>
		s += n;
		d += n;
  800bb2:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb5:	89 d6                	mov    %edx,%esi
  800bb7:	09 fe                	or     %edi,%esi
  800bb9:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbf:	74 0c                	je     800bcd <memmove+0x34>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bc1:	83 ef 01             	sub    $0x1,%edi
  800bc4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bc7:	fd                   	std    
  800bc8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bca:	fc                   	cld    
  800bcb:	eb 21                	jmp    800bee <memmove+0x55>
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcd:	f6 c1 03             	test   $0x3,%cl
  800bd0:	75 ef                	jne    800bc1 <memmove+0x28>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bd2:	83 ef 04             	sub    $0x4,%edi
  800bd5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bd8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bdb:	fd                   	std    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb ea                	jmp    800bca <memmove+0x31>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be0:	89 f2                	mov    %esi,%edx
  800be2:	09 c2                	or     %eax,%edx
  800be4:	f6 c2 03             	test   $0x3,%dl
  800be7:	74 09                	je     800bf2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be9:	89 c7                	mov    %eax,%edi
  800beb:	fc                   	cld    
  800bec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bf2:	f6 c1 03             	test   $0x3,%cl
  800bf5:	75 f2                	jne    800be9 <memmove+0x50>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bf7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bfa:	89 c7                	mov    %eax,%edi
  800bfc:	fc                   	cld    
  800bfd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bff:	eb ed                	jmp    800bee <memmove+0x55>

00800c01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c01:	55                   	push   %ebp
  800c02:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c04:	ff 75 10             	pushl  0x10(%ebp)
  800c07:	ff 75 0c             	pushl  0xc(%ebp)
  800c0a:	ff 75 08             	pushl  0x8(%ebp)
  800c0d:	e8 87 ff ff ff       	call   800b99 <memmove>
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	89 c6                	mov    %eax,%esi
  800c21:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c24:	39 f0                	cmp    %esi,%eax
  800c26:	74 1c                	je     800c44 <memcmp+0x30>
		if (*s1 != *s2)
  800c28:	0f b6 08             	movzbl (%eax),%ecx
  800c2b:	0f b6 1a             	movzbl (%edx),%ebx
  800c2e:	38 d9                	cmp    %bl,%cl
  800c30:	75 08                	jne    800c3a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c32:	83 c0 01             	add    $0x1,%eax
  800c35:	83 c2 01             	add    $0x1,%edx
  800c38:	eb ea                	jmp    800c24 <memcmp+0x10>
			return (int) *s1 - (int) *s2;
  800c3a:	0f b6 c1             	movzbl %cl,%eax
  800c3d:	0f b6 db             	movzbl %bl,%ebx
  800c40:	29 d8                	sub    %ebx,%eax
  800c42:	eb 05                	jmp    800c49 <memcmp+0x35>
	}

	return 0;
  800c44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c49:	5b                   	pop    %ebx
  800c4a:	5e                   	pop    %esi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c56:	89 c2                	mov    %eax,%edx
  800c58:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c5b:	39 d0                	cmp    %edx,%eax
  800c5d:	73 09                	jae    800c68 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c5f:	38 08                	cmp    %cl,(%eax)
  800c61:	74 05                	je     800c68 <memfind+0x1b>
	for (; s < ends; s++)
  800c63:	83 c0 01             	add    $0x1,%eax
  800c66:	eb f3                	jmp    800c5b <memfind+0xe>
			break;
	return (void *) s;
}
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c76:	eb 03                	jmp    800c7b <strtol+0x11>
		s++;
  800c78:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c7b:	0f b6 01             	movzbl (%ecx),%eax
  800c7e:	3c 20                	cmp    $0x20,%al
  800c80:	74 f6                	je     800c78 <strtol+0xe>
  800c82:	3c 09                	cmp    $0x9,%al
  800c84:	74 f2                	je     800c78 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c86:	3c 2b                	cmp    $0x2b,%al
  800c88:	74 2e                	je     800cb8 <strtol+0x4e>
	int neg = 0;
  800c8a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c8f:	3c 2d                	cmp    $0x2d,%al
  800c91:	74 2f                	je     800cc2 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c99:	75 05                	jne    800ca0 <strtol+0x36>
  800c9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9e:	74 2c                	je     800ccc <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ca0:	85 db                	test   %ebx,%ebx
  800ca2:	75 0a                	jne    800cae <strtol+0x44>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ca4:	bb 0a 00 00 00       	mov    $0xa,%ebx
	else if (base == 0 && s[0] == '0')
  800ca9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cac:	74 28                	je     800cd6 <strtol+0x6c>
		base = 10;
  800cae:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb3:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800cb6:	eb 50                	jmp    800d08 <strtol+0x9e>
		s++;
  800cb8:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800cbb:	bf 00 00 00 00       	mov    $0x0,%edi
  800cc0:	eb d1                	jmp    800c93 <strtol+0x29>
		s++, neg = 1;
  800cc2:	83 c1 01             	add    $0x1,%ecx
  800cc5:	bf 01 00 00 00       	mov    $0x1,%edi
  800cca:	eb c7                	jmp    800c93 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ccc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cd0:	74 0e                	je     800ce0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cd2:	85 db                	test   %ebx,%ebx
  800cd4:	75 d8                	jne    800cae <strtol+0x44>
		s++, base = 8;
  800cd6:	83 c1 01             	add    $0x1,%ecx
  800cd9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cde:	eb ce                	jmp    800cae <strtol+0x44>
		s += 2, base = 16;
  800ce0:	83 c1 02             	add    $0x2,%ecx
  800ce3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ce8:	eb c4                	jmp    800cae <strtol+0x44>
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
  800cea:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ced:	89 f3                	mov    %esi,%ebx
  800cef:	80 fb 19             	cmp    $0x19,%bl
  800cf2:	77 29                	ja     800d1d <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cf4:	0f be d2             	movsbl %dl,%edx
  800cf7:	83 ea 57             	sub    $0x57,%edx
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cfa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cfd:	7d 30                	jge    800d2f <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cff:	83 c1 01             	add    $0x1,%ecx
  800d02:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d06:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d08:	0f b6 11             	movzbl (%ecx),%edx
  800d0b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d0e:	89 f3                	mov    %esi,%ebx
  800d10:	80 fb 09             	cmp    $0x9,%bl
  800d13:	77 d5                	ja     800cea <strtol+0x80>
			dig = *s - '0';
  800d15:	0f be d2             	movsbl %dl,%edx
  800d18:	83 ea 30             	sub    $0x30,%edx
  800d1b:	eb dd                	jmp    800cfa <strtol+0x90>
		else if (*s >= 'A' && *s <= 'Z')
  800d1d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d20:	89 f3                	mov    %esi,%ebx
  800d22:	80 fb 19             	cmp    $0x19,%bl
  800d25:	77 08                	ja     800d2f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d27:	0f be d2             	movsbl %dl,%edx
  800d2a:	83 ea 37             	sub    $0x37,%edx
  800d2d:	eb cb                	jmp    800cfa <strtol+0x90>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d2f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d33:	74 05                	je     800d3a <strtol+0xd0>
		*endptr = (char *) s;
  800d35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d38:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d3a:	89 c2                	mov    %eax,%edx
  800d3c:	f7 da                	neg    %edx
  800d3e:	85 ff                	test   %edi,%edi
  800d40:	0f 45 c2             	cmovne %edx,%eax
}
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    
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
