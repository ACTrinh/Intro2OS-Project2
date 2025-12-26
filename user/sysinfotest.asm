
user/_sysinfotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sinfo>:
#include "kernel/sysinfo.h"
#include "user/user.h"


void
sinfo(struct sysinfo *info) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if (sysinfo(info) < 0) {
   8:	648000ef          	jal	650 <sysinfo>
   c:	00054663          	bltz	a0,18 <sinfo+0x18>
    printf("FAIL: sysinfo failed");
    exit(1);
  }
}
  10:	60a2                	ld	ra,8(sp)
  12:	6402                	ld	s0,0(sp)
  14:	0141                	addi	sp,sp,16
  16:	8082                	ret
    printf("FAIL: sysinfo failed");
  18:	00001517          	auipc	a0,0x1
  1c:	b6850513          	addi	a0,a0,-1176 # b80 <malloc+0xfc>
  20:	1b1000ef          	jal	9d0 <printf>
    exit(1);
  24:	4505                	li	a0,1
  26:	582000ef          	jal	5a8 <exit>

000000000000002a <countfree>:
//
// use sbrk() to count how many free physical memory pages there are.
//
int
countfree()
{
  2a:	715d                	addi	sp,sp,-80
  2c:	e486                	sd	ra,72(sp)
  2e:	e0a2                	sd	s0,64(sp)
  30:	fc26                	sd	s1,56(sp)
  32:	f84a                	sd	s2,48(sp)
  34:	f44e                	sd	s3,40(sp)
  36:	f052                	sd	s4,32(sp)
  38:	0880                	addi	s0,sp,80
  uint64 sz0 = (uint64)sbrk(0);
  3a:	4501                	li	a0,0
  3c:	5f4000ef          	jal	630 <sbrk>
  40:	8a2a                	mv	s4,a0
  struct sysinfo info;
  int n = 0;
  42:	4481                	li	s1,0

  while(1){
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  44:	597d                	li	s2,-1
      break;
    }
    n += PGSIZE;
  46:	6985                	lui	s3,0x1
  48:	a019                	j	4e <countfree+0x24>
  4a:	009984bb          	addw	s1,s3,s1
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  4e:	6505                	lui	a0,0x1
  50:	5e0000ef          	jal	630 <sbrk>
  54:	ff251be3          	bne	a0,s2,4a <countfree+0x20>
  }
  sinfo(&info);
  58:	fb840513          	addi	a0,s0,-72
  5c:	fa5ff0ef          	jal	0 <sinfo>
  if (info.freemem != 0) {
  60:	fb843583          	ld	a1,-72(s0)
  64:	e18d                	bnez	a1,86 <countfree+0x5c>
    printf("FAIL: there is no free mem, but sysinfo.freemem=%ld\n",
      info.freemem);
    exit(1);
  }
  sbrk(-((uint64)sbrk(0) - sz0));
  66:	4501                	li	a0,0
  68:	5c8000ef          	jal	630 <sbrk>
  6c:	40aa053b          	subw	a0,s4,a0
  70:	5c0000ef          	jal	630 <sbrk>
  return n;
}
  74:	8526                	mv	a0,s1
  76:	60a6                	ld	ra,72(sp)
  78:	6406                	ld	s0,64(sp)
  7a:	74e2                	ld	s1,56(sp)
  7c:	7942                	ld	s2,48(sp)
  7e:	79a2                	ld	s3,40(sp)
  80:	7a02                	ld	s4,32(sp)
  82:	6161                	addi	sp,sp,80
  84:	8082                	ret
    printf("FAIL: there is no free mem, but sysinfo.freemem=%ld\n",
  86:	00001517          	auipc	a0,0x1
  8a:	b1a50513          	addi	a0,a0,-1254 # ba0 <malloc+0x11c>
  8e:	143000ef          	jal	9d0 <printf>
    exit(1);
  92:	4505                	li	a0,1
  94:	514000ef          	jal	5a8 <exit>

0000000000000098 <testmem>:

void
testmem() {
  98:	7139                	addi	sp,sp,-64
  9a:	fc06                	sd	ra,56(sp)
  9c:	f822                	sd	s0,48(sp)
  9e:	f426                	sd	s1,40(sp)
  a0:	f04a                	sd	s2,32(sp)
  a2:	0080                	addi	s0,sp,64
  struct sysinfo info;
  uint64 n = countfree();
  a4:	f87ff0ef          	jal	2a <countfree>
  a8:	84aa                	mv	s1,a0
  
  sinfo(&info);
  aa:	fc840513          	addi	a0,s0,-56
  ae:	f53ff0ef          	jal	0 <sinfo>

  if (info.freemem!= n) {
  b2:	fc843583          	ld	a1,-56(s0)
  b6:	04959663          	bne	a1,s1,102 <testmem+0x6a>
    printf("FAIL: free mem %ld (bytes) instead of %ld\n", info.freemem, n);
    exit(1);
  }
  
  if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  ba:	6505                	lui	a0,0x1
  bc:	574000ef          	jal	630 <sbrk>
  c0:	57fd                	li	a5,-1
  c2:	04f50a63          	beq	a0,a5,116 <testmem+0x7e>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
  c6:	fc840513          	addi	a0,s0,-56
  ca:	f37ff0ef          	jal	0 <sinfo>
    
  if (info.freemem != n-PGSIZE) {
  ce:	fc843603          	ld	a2,-56(s0)
  d2:	75fd                	lui	a1,0xfffff
  d4:	95a6                	add	a1,a1,s1
  d6:	04b61963          	bne	a2,a1,128 <testmem+0x90>
    printf("FAIL: free mem %ld (bytes) instead of %ld\n", n-PGSIZE, info.freemem);
    exit(1);
  }
  
  if((uint64)sbrk(-PGSIZE) == 0xffffffffffffffff){
  da:	757d                	lui	a0,0xfffff
  dc:	554000ef          	jal	630 <sbrk>
  e0:	57fd                	li	a5,-1
  e2:	04f50c63          	beq	a0,a5,13a <testmem+0xa2>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
  e6:	fc840513          	addi	a0,s0,-56
  ea:	f17ff0ef          	jal	0 <sinfo>
    
  if (info.freemem != n) {
  ee:	fc843603          	ld	a2,-56(s0)
  f2:	04961d63          	bne	a2,s1,14c <testmem+0xb4>
    printf("FAIL: free mem %ld (bytes) instead of %ld\n", n, info.freemem);
    exit(1);
  }
}
  f6:	70e2                	ld	ra,56(sp)
  f8:	7442                	ld	s0,48(sp)
  fa:	74a2                	ld	s1,40(sp)
  fc:	7902                	ld	s2,32(sp)
  fe:	6121                	addi	sp,sp,64
 100:	8082                	ret
    printf("FAIL: free mem %ld (bytes) instead of %ld\n", info.freemem, n);
 102:	8626                	mv	a2,s1
 104:	00001517          	auipc	a0,0x1
 108:	ad450513          	addi	a0,a0,-1324 # bd8 <malloc+0x154>
 10c:	0c5000ef          	jal	9d0 <printf>
    exit(1);
 110:	4505                	li	a0,1
 112:	496000ef          	jal	5a8 <exit>
    printf("sbrk failed");
 116:	00001517          	auipc	a0,0x1
 11a:	af250513          	addi	a0,a0,-1294 # c08 <malloc+0x184>
 11e:	0b3000ef          	jal	9d0 <printf>
    exit(1);
 122:	4505                	li	a0,1
 124:	484000ef          	jal	5a8 <exit>
    printf("FAIL: free mem %ld (bytes) instead of %ld\n", n-PGSIZE, info.freemem);
 128:	00001517          	auipc	a0,0x1
 12c:	ab050513          	addi	a0,a0,-1360 # bd8 <malloc+0x154>
 130:	0a1000ef          	jal	9d0 <printf>
    exit(1);
 134:	4505                	li	a0,1
 136:	472000ef          	jal	5a8 <exit>
    printf("sbrk failed");
 13a:	00001517          	auipc	a0,0x1
 13e:	ace50513          	addi	a0,a0,-1330 # c08 <malloc+0x184>
 142:	08f000ef          	jal	9d0 <printf>
    exit(1);
 146:	4505                	li	a0,1
 148:	460000ef          	jal	5a8 <exit>
    printf("FAIL: free mem %ld (bytes) instead of %ld\n", n, info.freemem);
 14c:	85a6                	mv	a1,s1
 14e:	00001517          	auipc	a0,0x1
 152:	a8a50513          	addi	a0,a0,-1398 # bd8 <malloc+0x154>
 156:	07b000ef          	jal	9d0 <printf>
    exit(1);
 15a:	4505                	li	a0,1
 15c:	44c000ef          	jal	5a8 <exit>

0000000000000160 <testcall>:

void
testcall() {
 160:	7179                	addi	sp,sp,-48
 162:	f406                	sd	ra,40(sp)
 164:	f022                	sd	s0,32(sp)
 166:	1800                	addi	s0,sp,48
  struct sysinfo info;
  
  if (sysinfo(&info) < 0) {
 168:	fd840513          	addi	a0,s0,-40
 16c:	4e4000ef          	jal	650 <sysinfo>
 170:	02054463          	bltz	a0,198 <testcall+0x38>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }

  if (sysinfo((struct sysinfo *) 0xeaeb0b5b00002f5e) !=  0xffffffffffffffff) {
 174:	eaeb1537          	lui	a0,0xeaeb1
 178:	b5b50513          	addi	a0,a0,-1189 # ffffffffeaeb0b5b <base+0xffffffffeaeafb4b>
 17c:	0552                	slli	a0,a0,0x14
 17e:	050d                	addi	a0,a0,3
 180:	0532                	slli	a0,a0,0xc
 182:	f5e50513          	addi	a0,a0,-162
 186:	4ca000ef          	jal	650 <sysinfo>
 18a:	57fd                	li	a5,-1
 18c:	00f51f63          	bne	a0,a5,1aa <testcall+0x4a>
    printf("FAIL: sysinfo succeeded with bad argument\n");
    exit(1);
  }
}
 190:	70a2                	ld	ra,40(sp)
 192:	7402                	ld	s0,32(sp)
 194:	6145                	addi	sp,sp,48
 196:	8082                	ret
    printf("FAIL: sysinfo failed\n");
 198:	00001517          	auipc	a0,0x1
 19c:	a8050513          	addi	a0,a0,-1408 # c18 <malloc+0x194>
 1a0:	031000ef          	jal	9d0 <printf>
    exit(1);
 1a4:	4505                	li	a0,1
 1a6:	402000ef          	jal	5a8 <exit>
    printf("FAIL: sysinfo succeeded with bad argument\n");
 1aa:	00001517          	auipc	a0,0x1
 1ae:	a8650513          	addi	a0,a0,-1402 # c30 <malloc+0x1ac>
 1b2:	01f000ef          	jal	9d0 <printf>
    exit(1);
 1b6:	4505                	li	a0,1
 1b8:	3f0000ef          	jal	5a8 <exit>

00000000000001bc <testproc>:

void testproc() {
 1bc:	7139                	addi	sp,sp,-64
 1be:	fc06                	sd	ra,56(sp)
 1c0:	f822                	sd	s0,48(sp)
 1c2:	f426                	sd	s1,40(sp)
 1c4:	0080                	addi	s0,sp,64
  struct sysinfo info;
  uint64 nproc;
  int status;
  int pid;
  
  sinfo(&info);
 1c6:	fc840513          	addi	a0,s0,-56
 1ca:	e37ff0ef          	jal	0 <sinfo>
  nproc = info.nproc;
 1ce:	fd043483          	ld	s1,-48(s0)

  pid = fork();
 1d2:	3ce000ef          	jal	5a0 <fork>
  if(pid < 0){
 1d6:	02054663          	bltz	a0,202 <testproc+0x46>
    printf("sysinfotest: fork failed\n");
    exit(1);
  }
  if(pid == 0){
 1da:	e121                	bnez	a0,21a <testproc+0x5e>
    sinfo(&info);
 1dc:	fc840513          	addi	a0,s0,-56
 1e0:	e21ff0ef          	jal	0 <sinfo>
    if(info.nproc != nproc+1) {
 1e4:	fd043583          	ld	a1,-48(s0)
 1e8:	00148613          	addi	a2,s1,1
 1ec:	02c58463          	beq	a1,a2,214 <testproc+0x58>
      printf("sysinfotest: FAIL nproc is %ld instead of %ld\n", info.nproc, nproc+1);
 1f0:	00001517          	auipc	a0,0x1
 1f4:	a9050513          	addi	a0,a0,-1392 # c80 <malloc+0x1fc>
 1f8:	7d8000ef          	jal	9d0 <printf>
      exit(1);
 1fc:	4505                	li	a0,1
 1fe:	3aa000ef          	jal	5a8 <exit>
    printf("sysinfotest: fork failed\n");
 202:	00001517          	auipc	a0,0x1
 206:	a5e50513          	addi	a0,a0,-1442 # c60 <malloc+0x1dc>
 20a:	7c6000ef          	jal	9d0 <printf>
    exit(1);
 20e:	4505                	li	a0,1
 210:	398000ef          	jal	5a8 <exit>
    }
    exit(0);
 214:	4501                	li	a0,0
 216:	392000ef          	jal	5a8 <exit>
  }
  wait(&status);
 21a:	fc440513          	addi	a0,s0,-60
 21e:	392000ef          	jal	5b0 <wait>
  sinfo(&info);
 222:	fc840513          	addi	a0,s0,-56
 226:	ddbff0ef          	jal	0 <sinfo>
  if(info.nproc != nproc) {
 22a:	fd043583          	ld	a1,-48(s0)
 22e:	00959763          	bne	a1,s1,23c <testproc+0x80>
      printf("sysinfotest: FAIL nproc is %ld instead of %ld\n", info.nproc, nproc);
      exit(1);
  }
}
 232:	70e2                	ld	ra,56(sp)
 234:	7442                	ld	s0,48(sp)
 236:	74a2                	ld	s1,40(sp)
 238:	6121                	addi	sp,sp,64
 23a:	8082                	ret
      printf("sysinfotest: FAIL nproc is %ld instead of %ld\n", info.nproc, nproc);
 23c:	8626                	mv	a2,s1
 23e:	00001517          	auipc	a0,0x1
 242:	a4250513          	addi	a0,a0,-1470 # c80 <malloc+0x1fc>
 246:	78a000ef          	jal	9d0 <printf>
      exit(1);
 24a:	4505                	li	a0,1
 24c:	35c000ef          	jal	5a8 <exit>

0000000000000250 <testbad>:

void testbad() {
 250:	1101                	addi	sp,sp,-32
 252:	ec06                	sd	ra,24(sp)
 254:	e822                	sd	s0,16(sp)
 256:	1000                	addi	s0,sp,32
  int pid = fork();
 258:	348000ef          	jal	5a0 <fork>
  int xstatus;
  
  if(pid < 0){
 25c:	00054863          	bltz	a0,26c <testbad+0x1c>
    printf("sysinfotest: fork failed\n");
    exit(1);
  }
  if(pid == 0){
 260:	ed19                	bnez	a0,27e <testbad+0x2e>
      sinfo(0x0);
 262:	d9fff0ef          	jal	0 <sinfo>
      exit(0);
 266:	4501                	li	a0,0
 268:	340000ef          	jal	5a8 <exit>
    printf("sysinfotest: fork failed\n");
 26c:	00001517          	auipc	a0,0x1
 270:	9f450513          	addi	a0,a0,-1548 # c60 <malloc+0x1dc>
 274:	75c000ef          	jal	9d0 <printf>
    exit(1);
 278:	4505                	li	a0,1
 27a:	32e000ef          	jal	5a8 <exit>
  }
  wait(&xstatus);
 27e:	fec40513          	addi	a0,s0,-20
 282:	32e000ef          	jal	5b0 <wait>
  if(xstatus == -1)  // kernel killed child?
 286:	fec42583          	lw	a1,-20(s0)
 28a:	57fd                	li	a5,-1
 28c:	00f58c63          	beq	a1,a5,2a4 <testbad+0x54>
    exit(0);
  else {
    printf("sysinfotest: testbad succeeded %d\n", xstatus);
 290:	00001517          	auipc	a0,0x1
 294:	a2050513          	addi	a0,a0,-1504 # cb0 <malloc+0x22c>
 298:	738000ef          	jal	9d0 <printf>
    exit(xstatus);
 29c:	fec42503          	lw	a0,-20(s0)
 2a0:	308000ef          	jal	5a8 <exit>
    exit(0);
 2a4:	4501                	li	a0,0
 2a6:	302000ef          	jal	5a8 <exit>

00000000000002aa <testload>:
  }
}

void
testload() {
 2aa:	7179                	addi	sp,sp,-48
 2ac:	f406                	sd	ra,40(sp)
 2ae:	f022                	sd	s0,32(sp)
 2b0:	1800                	addi	s0,sp,48
  struct sysinfo info;
  
  printf("sysinfotest: test load\n");
 2b2:	00001517          	auipc	a0,0x1
 2b6:	a2650513          	addi	a0,a0,-1498 # cd8 <malloc+0x254>
 2ba:	716000ef          	jal	9d0 <printf>
  
  if(sysinfo(&info) < 0){
 2be:	fd840513          	addi	a0,s0,-40
 2c2:	38e000ef          	jal	650 <sysinfo>
 2c6:	00054f63          	bltz	a0,2e4 <testload+0x3a>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }
  
  if(info.load < 1){
 2ca:	fe843583          	ld	a1,-24(s0)
 2ce:	c585                	beqz	a1,2f6 <testload+0x4c>
    printf("FAIL: load %ld < 1 (expect >= 1)\n", info.load);
    exit(1);
  }
  
  printf("sysinfotest: load ok (val=%ld)\n", info.load);
 2d0:	00001517          	auipc	a0,0x1
 2d4:	a4850513          	addi	a0,a0,-1464 # d18 <malloc+0x294>
 2d8:	6f8000ef          	jal	9d0 <printf>
}
 2dc:	70a2                	ld	ra,40(sp)
 2de:	7402                	ld	s0,32(sp)
 2e0:	6145                	addi	sp,sp,48
 2e2:	8082                	ret
    printf("FAIL: sysinfo failed\n");
 2e4:	00001517          	auipc	a0,0x1
 2e8:	93450513          	addi	a0,a0,-1740 # c18 <malloc+0x194>
 2ec:	6e4000ef          	jal	9d0 <printf>
    exit(1);
 2f0:	4505                	li	a0,1
 2f2:	2b6000ef          	jal	5a8 <exit>
    printf("FAIL: load %ld < 1 (expect >= 1)\n", info.load);
 2f6:	00001517          	auipc	a0,0x1
 2fa:	9fa50513          	addi	a0,a0,-1542 # cf0 <malloc+0x26c>
 2fe:	6d2000ef          	jal	9d0 <printf>
    exit(1);
 302:	4505                	li	a0,1
 304:	2a4000ef          	jal	5a8 <exit>

0000000000000308 <main>:

int
main(int argc, char *argv[])
{
 308:	1141                	addi	sp,sp,-16
 30a:	e406                	sd	ra,8(sp)
 30c:	e022                	sd	s0,0(sp)
 30e:	0800                	addi	s0,sp,16
  printf("sysinfotest: start\n");
 310:	00001517          	auipc	a0,0x1
 314:	a2850513          	addi	a0,a0,-1496 # d38 <malloc+0x2b4>
 318:	6b8000ef          	jal	9d0 <printf>
  testcall();
 31c:	e45ff0ef          	jal	160 <testcall>
  testmem();
 320:	d79ff0ef          	jal	98 <testmem>
  testproc();
 324:	e99ff0ef          	jal	1bc <testproc>
  testload();
 328:	f83ff0ef          	jal	2aa <testload>
  printf("sysinfotest: OK\n");
 32c:	00001517          	auipc	a0,0x1
 330:	a2450513          	addi	a0,a0,-1500 # d50 <malloc+0x2cc>
 334:	69c000ef          	jal	9d0 <printf>
  exit(0);
 338:	4501                	li	a0,0
 33a:	26e000ef          	jal	5a8 <exit>

000000000000033e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  extern int main();
  main();
 346:	fc3ff0ef          	jal	308 <main>
  exit(0);
 34a:	4501                	li	a0,0
 34c:	25c000ef          	jal	5a8 <exit>

0000000000000350 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 350:	1141                	addi	sp,sp,-16
 352:	e422                	sd	s0,8(sp)
 354:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 356:	87aa                	mv	a5,a0
 358:	0585                	addi	a1,a1,1 # fffffffffffff001 <base+0xffffffffffffdff1>
 35a:	0785                	addi	a5,a5,1
 35c:	fff5c703          	lbu	a4,-1(a1)
 360:	fee78fa3          	sb	a4,-1(a5)
 364:	fb75                	bnez	a4,358 <strcpy+0x8>
    ;
  return os;
}
 366:	6422                	ld	s0,8(sp)
 368:	0141                	addi	sp,sp,16
 36a:	8082                	ret

000000000000036c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 372:	00054783          	lbu	a5,0(a0)
 376:	cb91                	beqz	a5,38a <strcmp+0x1e>
 378:	0005c703          	lbu	a4,0(a1)
 37c:	00f71763          	bne	a4,a5,38a <strcmp+0x1e>
    p++, q++;
 380:	0505                	addi	a0,a0,1
 382:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 384:	00054783          	lbu	a5,0(a0)
 388:	fbe5                	bnez	a5,378 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 38a:	0005c503          	lbu	a0,0(a1)
}
 38e:	40a7853b          	subw	a0,a5,a0
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret

0000000000000398 <strlen>:

uint
strlen(const char *s)
{
 398:	1141                	addi	sp,sp,-16
 39a:	e422                	sd	s0,8(sp)
 39c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 39e:	00054783          	lbu	a5,0(a0)
 3a2:	cf91                	beqz	a5,3be <strlen+0x26>
 3a4:	0505                	addi	a0,a0,1
 3a6:	87aa                	mv	a5,a0
 3a8:	86be                	mv	a3,a5
 3aa:	0785                	addi	a5,a5,1
 3ac:	fff7c703          	lbu	a4,-1(a5)
 3b0:	ff65                	bnez	a4,3a8 <strlen+0x10>
 3b2:	40a6853b          	subw	a0,a3,a0
 3b6:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 3b8:	6422                	ld	s0,8(sp)
 3ba:	0141                	addi	sp,sp,16
 3bc:	8082                	ret
  for(n = 0; s[n]; n++)
 3be:	4501                	li	a0,0
 3c0:	bfe5                	j	3b8 <strlen+0x20>

00000000000003c2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e422                	sd	s0,8(sp)
 3c6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3c8:	ca19                	beqz	a2,3de <memset+0x1c>
 3ca:	87aa                	mv	a5,a0
 3cc:	1602                	slli	a2,a2,0x20
 3ce:	9201                	srli	a2,a2,0x20
 3d0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3d4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3d8:	0785                	addi	a5,a5,1
 3da:	fee79de3          	bne	a5,a4,3d4 <memset+0x12>
  }
  return dst;
}
 3de:	6422                	ld	s0,8(sp)
 3e0:	0141                	addi	sp,sp,16
 3e2:	8082                	ret

00000000000003e4 <strchr>:

char*
strchr(const char *s, char c)
{
 3e4:	1141                	addi	sp,sp,-16
 3e6:	e422                	sd	s0,8(sp)
 3e8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3ea:	00054783          	lbu	a5,0(a0)
 3ee:	cb99                	beqz	a5,404 <strchr+0x20>
    if(*s == c)
 3f0:	00f58763          	beq	a1,a5,3fe <strchr+0x1a>
  for(; *s; s++)
 3f4:	0505                	addi	a0,a0,1
 3f6:	00054783          	lbu	a5,0(a0)
 3fa:	fbfd                	bnez	a5,3f0 <strchr+0xc>
      return (char*)s;
  return 0;
 3fc:	4501                	li	a0,0
}
 3fe:	6422                	ld	s0,8(sp)
 400:	0141                	addi	sp,sp,16
 402:	8082                	ret
  return 0;
 404:	4501                	li	a0,0
 406:	bfe5                	j	3fe <strchr+0x1a>

0000000000000408 <gets>:

char*
gets(char *buf, int max)
{
 408:	711d                	addi	sp,sp,-96
 40a:	ec86                	sd	ra,88(sp)
 40c:	e8a2                	sd	s0,80(sp)
 40e:	e4a6                	sd	s1,72(sp)
 410:	e0ca                	sd	s2,64(sp)
 412:	fc4e                	sd	s3,56(sp)
 414:	f852                	sd	s4,48(sp)
 416:	f456                	sd	s5,40(sp)
 418:	f05a                	sd	s6,32(sp)
 41a:	ec5e                	sd	s7,24(sp)
 41c:	1080                	addi	s0,sp,96
 41e:	8baa                	mv	s7,a0
 420:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 422:	892a                	mv	s2,a0
 424:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 426:	4aa9                	li	s5,10
 428:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 42a:	89a6                	mv	s3,s1
 42c:	2485                	addiw	s1,s1,1
 42e:	0344d663          	bge	s1,s4,45a <gets+0x52>
    cc = read(0, &c, 1);
 432:	4605                	li	a2,1
 434:	faf40593          	addi	a1,s0,-81
 438:	4501                	li	a0,0
 43a:	186000ef          	jal	5c0 <read>
    if(cc < 1)
 43e:	00a05e63          	blez	a0,45a <gets+0x52>
    buf[i++] = c;
 442:	faf44783          	lbu	a5,-81(s0)
 446:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 44a:	01578763          	beq	a5,s5,458 <gets+0x50>
 44e:	0905                	addi	s2,s2,1
 450:	fd679de3          	bne	a5,s6,42a <gets+0x22>
    buf[i++] = c;
 454:	89a6                	mv	s3,s1
 456:	a011                	j	45a <gets+0x52>
 458:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 45a:	99de                	add	s3,s3,s7
 45c:	00098023          	sb	zero,0(s3) # 1000 <freep>
  return buf;
}
 460:	855e                	mv	a0,s7
 462:	60e6                	ld	ra,88(sp)
 464:	6446                	ld	s0,80(sp)
 466:	64a6                	ld	s1,72(sp)
 468:	6906                	ld	s2,64(sp)
 46a:	79e2                	ld	s3,56(sp)
 46c:	7a42                	ld	s4,48(sp)
 46e:	7aa2                	ld	s5,40(sp)
 470:	7b02                	ld	s6,32(sp)
 472:	6be2                	ld	s7,24(sp)
 474:	6125                	addi	sp,sp,96
 476:	8082                	ret

0000000000000478 <stat>:

int
stat(const char *n, struct stat *st)
{
 478:	1101                	addi	sp,sp,-32
 47a:	ec06                	sd	ra,24(sp)
 47c:	e822                	sd	s0,16(sp)
 47e:	e04a                	sd	s2,0(sp)
 480:	1000                	addi	s0,sp,32
 482:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 484:	4581                	li	a1,0
 486:	162000ef          	jal	5e8 <open>
  if(fd < 0)
 48a:	02054263          	bltz	a0,4ae <stat+0x36>
 48e:	e426                	sd	s1,8(sp)
 490:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 492:	85ca                	mv	a1,s2
 494:	16c000ef          	jal	600 <fstat>
 498:	892a                	mv	s2,a0
  close(fd);
 49a:	8526                	mv	a0,s1
 49c:	134000ef          	jal	5d0 <close>
  return r;
 4a0:	64a2                	ld	s1,8(sp)
}
 4a2:	854a                	mv	a0,s2
 4a4:	60e2                	ld	ra,24(sp)
 4a6:	6442                	ld	s0,16(sp)
 4a8:	6902                	ld	s2,0(sp)
 4aa:	6105                	addi	sp,sp,32
 4ac:	8082                	ret
    return -1;
 4ae:	597d                	li	s2,-1
 4b0:	bfcd                	j	4a2 <stat+0x2a>

00000000000004b2 <atoi>:

int
atoi(const char *s)
{
 4b2:	1141                	addi	sp,sp,-16
 4b4:	e422                	sd	s0,8(sp)
 4b6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4b8:	00054683          	lbu	a3,0(a0)
 4bc:	fd06879b          	addiw	a5,a3,-48
 4c0:	0ff7f793          	zext.b	a5,a5
 4c4:	4625                	li	a2,9
 4c6:	02f66863          	bltu	a2,a5,4f6 <atoi+0x44>
 4ca:	872a                	mv	a4,a0
  n = 0;
 4cc:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 4ce:	0705                	addi	a4,a4,1
 4d0:	0025179b          	slliw	a5,a0,0x2
 4d4:	9fa9                	addw	a5,a5,a0
 4d6:	0017979b          	slliw	a5,a5,0x1
 4da:	9fb5                	addw	a5,a5,a3
 4dc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4e0:	00074683          	lbu	a3,0(a4)
 4e4:	fd06879b          	addiw	a5,a3,-48
 4e8:	0ff7f793          	zext.b	a5,a5
 4ec:	fef671e3          	bgeu	a2,a5,4ce <atoi+0x1c>
  return n;
}
 4f0:	6422                	ld	s0,8(sp)
 4f2:	0141                	addi	sp,sp,16
 4f4:	8082                	ret
  n = 0;
 4f6:	4501                	li	a0,0
 4f8:	bfe5                	j	4f0 <atoi+0x3e>

00000000000004fa <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4fa:	1141                	addi	sp,sp,-16
 4fc:	e422                	sd	s0,8(sp)
 4fe:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 500:	02b57463          	bgeu	a0,a1,528 <memmove+0x2e>
    while(n-- > 0)
 504:	00c05f63          	blez	a2,522 <memmove+0x28>
 508:	1602                	slli	a2,a2,0x20
 50a:	9201                	srli	a2,a2,0x20
 50c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 510:	872a                	mv	a4,a0
      *dst++ = *src++;
 512:	0585                	addi	a1,a1,1
 514:	0705                	addi	a4,a4,1
 516:	fff5c683          	lbu	a3,-1(a1)
 51a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 51e:	fef71ae3          	bne	a4,a5,512 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 522:	6422                	ld	s0,8(sp)
 524:	0141                	addi	sp,sp,16
 526:	8082                	ret
    dst += n;
 528:	00c50733          	add	a4,a0,a2
    src += n;
 52c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 52e:	fec05ae3          	blez	a2,522 <memmove+0x28>
 532:	fff6079b          	addiw	a5,a2,-1
 536:	1782                	slli	a5,a5,0x20
 538:	9381                	srli	a5,a5,0x20
 53a:	fff7c793          	not	a5,a5
 53e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 540:	15fd                	addi	a1,a1,-1
 542:	177d                	addi	a4,a4,-1
 544:	0005c683          	lbu	a3,0(a1)
 548:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 54c:	fee79ae3          	bne	a5,a4,540 <memmove+0x46>
 550:	bfc9                	j	522 <memmove+0x28>

0000000000000552 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 552:	1141                	addi	sp,sp,-16
 554:	e422                	sd	s0,8(sp)
 556:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 558:	ca05                	beqz	a2,588 <memcmp+0x36>
 55a:	fff6069b          	addiw	a3,a2,-1
 55e:	1682                	slli	a3,a3,0x20
 560:	9281                	srli	a3,a3,0x20
 562:	0685                	addi	a3,a3,1
 564:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 566:	00054783          	lbu	a5,0(a0)
 56a:	0005c703          	lbu	a4,0(a1)
 56e:	00e79863          	bne	a5,a4,57e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 572:	0505                	addi	a0,a0,1
    p2++;
 574:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 576:	fed518e3          	bne	a0,a3,566 <memcmp+0x14>
  }
  return 0;
 57a:	4501                	li	a0,0
 57c:	a019                	j	582 <memcmp+0x30>
      return *p1 - *p2;
 57e:	40e7853b          	subw	a0,a5,a4
}
 582:	6422                	ld	s0,8(sp)
 584:	0141                	addi	sp,sp,16
 586:	8082                	ret
  return 0;
 588:	4501                	li	a0,0
 58a:	bfe5                	j	582 <memcmp+0x30>

000000000000058c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 58c:	1141                	addi	sp,sp,-16
 58e:	e406                	sd	ra,8(sp)
 590:	e022                	sd	s0,0(sp)
 592:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 594:	f67ff0ef          	jal	4fa <memmove>
}
 598:	60a2                	ld	ra,8(sp)
 59a:	6402                	ld	s0,0(sp)
 59c:	0141                	addi	sp,sp,16
 59e:	8082                	ret

00000000000005a0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5a0:	4885                	li	a7,1
 ecall
 5a2:	00000073          	ecall
 ret
 5a6:	8082                	ret

00000000000005a8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5a8:	4889                	li	a7,2
 ecall
 5aa:	00000073          	ecall
 ret
 5ae:	8082                	ret

00000000000005b0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b0:	488d                	li	a7,3
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5b8:	4891                	li	a7,4
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <read>:
.global read
read:
 li a7, SYS_read
 5c0:	4895                	li	a7,5
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <write>:
.global write
write:
 li a7, SYS_write
 5c8:	48c1                	li	a7,16
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <close>:
.global close
close:
 li a7, SYS_close
 5d0:	48d5                	li	a7,21
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5d8:	4899                	li	a7,6
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e0:	489d                	li	a7,7
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <open>:
.global open
open:
 li a7, SYS_open
 5e8:	48bd                	li	a7,15
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f0:	48c5                	li	a7,17
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5f8:	48c9                	li	a7,18
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 600:	48a1                	li	a7,8
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <link>:
.global link
link:
 li a7, SYS_link
 608:	48cd                	li	a7,19
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 610:	48d1                	li	a7,20
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 618:	48a5                	li	a7,9
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <dup>:
.global dup
dup:
 li a7, SYS_dup
 620:	48a9                	li	a7,10
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 628:	48ad                	li	a7,11
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 630:	48b1                	li	a7,12
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 638:	48b5                	li	a7,13
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 640:	48b9                	li	a7,14
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <trace>:
.global trace
trace:
 li a7, SYS_trace
 648:	48d9                	li	a7,22
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 650:	48dd                	li	a7,23
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 658:	1101                	addi	sp,sp,-32
 65a:	ec06                	sd	ra,24(sp)
 65c:	e822                	sd	s0,16(sp)
 65e:	1000                	addi	s0,sp,32
 660:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 664:	4605                	li	a2,1
 666:	fef40593          	addi	a1,s0,-17
 66a:	f5fff0ef          	jal	5c8 <write>
}
 66e:	60e2                	ld	ra,24(sp)
 670:	6442                	ld	s0,16(sp)
 672:	6105                	addi	sp,sp,32
 674:	8082                	ret

0000000000000676 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 676:	7139                	addi	sp,sp,-64
 678:	fc06                	sd	ra,56(sp)
 67a:	f822                	sd	s0,48(sp)
 67c:	f426                	sd	s1,40(sp)
 67e:	0080                	addi	s0,sp,64
 680:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 682:	c299                	beqz	a3,688 <printint+0x12>
 684:	0805c963          	bltz	a1,716 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 688:	2581                	sext.w	a1,a1
  neg = 0;
 68a:	4881                	li	a7,0
 68c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 690:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 692:	2601                	sext.w	a2,a2
 694:	00000517          	auipc	a0,0x0
 698:	6dc50513          	addi	a0,a0,1756 # d70 <digits>
 69c:	883a                	mv	a6,a4
 69e:	2705                	addiw	a4,a4,1
 6a0:	02c5f7bb          	remuw	a5,a1,a2
 6a4:	1782                	slli	a5,a5,0x20
 6a6:	9381                	srli	a5,a5,0x20
 6a8:	97aa                	add	a5,a5,a0
 6aa:	0007c783          	lbu	a5,0(a5)
 6ae:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6b2:	0005879b          	sext.w	a5,a1
 6b6:	02c5d5bb          	divuw	a1,a1,a2
 6ba:	0685                	addi	a3,a3,1
 6bc:	fec7f0e3          	bgeu	a5,a2,69c <printint+0x26>
  if(neg)
 6c0:	00088c63          	beqz	a7,6d8 <printint+0x62>
    buf[i++] = '-';
 6c4:	fd070793          	addi	a5,a4,-48
 6c8:	00878733          	add	a4,a5,s0
 6cc:	02d00793          	li	a5,45
 6d0:	fef70823          	sb	a5,-16(a4)
 6d4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6d8:	02e05a63          	blez	a4,70c <printint+0x96>
 6dc:	f04a                	sd	s2,32(sp)
 6de:	ec4e                	sd	s3,24(sp)
 6e0:	fc040793          	addi	a5,s0,-64
 6e4:	00e78933          	add	s2,a5,a4
 6e8:	fff78993          	addi	s3,a5,-1
 6ec:	99ba                	add	s3,s3,a4
 6ee:	377d                	addiw	a4,a4,-1
 6f0:	1702                	slli	a4,a4,0x20
 6f2:	9301                	srli	a4,a4,0x20
 6f4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 6f8:	fff94583          	lbu	a1,-1(s2)
 6fc:	8526                	mv	a0,s1
 6fe:	f5bff0ef          	jal	658 <putc>
  while(--i >= 0)
 702:	197d                	addi	s2,s2,-1
 704:	ff391ae3          	bne	s2,s3,6f8 <printint+0x82>
 708:	7902                	ld	s2,32(sp)
 70a:	69e2                	ld	s3,24(sp)
}
 70c:	70e2                	ld	ra,56(sp)
 70e:	7442                	ld	s0,48(sp)
 710:	74a2                	ld	s1,40(sp)
 712:	6121                	addi	sp,sp,64
 714:	8082                	ret
    x = -xx;
 716:	40b005bb          	negw	a1,a1
    neg = 1;
 71a:	4885                	li	a7,1
    x = -xx;
 71c:	bf85                	j	68c <printint+0x16>

000000000000071e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 71e:	711d                	addi	sp,sp,-96
 720:	ec86                	sd	ra,88(sp)
 722:	e8a2                	sd	s0,80(sp)
 724:	e0ca                	sd	s2,64(sp)
 726:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 728:	0005c903          	lbu	s2,0(a1)
 72c:	26090863          	beqz	s2,99c <vprintf+0x27e>
 730:	e4a6                	sd	s1,72(sp)
 732:	fc4e                	sd	s3,56(sp)
 734:	f852                	sd	s4,48(sp)
 736:	f456                	sd	s5,40(sp)
 738:	f05a                	sd	s6,32(sp)
 73a:	ec5e                	sd	s7,24(sp)
 73c:	e862                	sd	s8,16(sp)
 73e:	e466                	sd	s9,8(sp)
 740:	8b2a                	mv	s6,a0
 742:	8a2e                	mv	s4,a1
 744:	8bb2                	mv	s7,a2
  state = 0;
 746:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 748:	4481                	li	s1,0
 74a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 74c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 750:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 754:	06c00c93          	li	s9,108
 758:	a005                	j	778 <vprintf+0x5a>
        putc(fd, c0);
 75a:	85ca                	mv	a1,s2
 75c:	855a                	mv	a0,s6
 75e:	efbff0ef          	jal	658 <putc>
 762:	a019                	j	768 <vprintf+0x4a>
    } else if(state == '%'){
 764:	03598263          	beq	s3,s5,788 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 768:	2485                	addiw	s1,s1,1
 76a:	8726                	mv	a4,s1
 76c:	009a07b3          	add	a5,s4,s1
 770:	0007c903          	lbu	s2,0(a5)
 774:	20090c63          	beqz	s2,98c <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 778:	0009079b          	sext.w	a5,s2
    if(state == 0){
 77c:	fe0994e3          	bnez	s3,764 <vprintf+0x46>
      if(c0 == '%'){
 780:	fd579de3          	bne	a5,s5,75a <vprintf+0x3c>
        state = '%';
 784:	89be                	mv	s3,a5
 786:	b7cd                	j	768 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 788:	00ea06b3          	add	a3,s4,a4
 78c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 790:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 792:	c681                	beqz	a3,79a <vprintf+0x7c>
 794:	9752                	add	a4,a4,s4
 796:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 79a:	03878f63          	beq	a5,s8,7d8 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 79e:	05978963          	beq	a5,s9,7f0 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 7a2:	07500713          	li	a4,117
 7a6:	0ee78363          	beq	a5,a4,88c <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7aa:	07800713          	li	a4,120
 7ae:	12e78563          	beq	a5,a4,8d8 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7b2:	07000713          	li	a4,112
 7b6:	14e78a63          	beq	a5,a4,90a <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 7ba:	07300713          	li	a4,115
 7be:	18e78a63          	beq	a5,a4,952 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7c2:	02500713          	li	a4,37
 7c6:	04e79563          	bne	a5,a4,810 <vprintf+0xf2>
        putc(fd, '%');
 7ca:	02500593          	li	a1,37
 7ce:	855a                	mv	a0,s6
 7d0:	e89ff0ef          	jal	658 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	bf49                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 7d8:	008b8913          	addi	s2,s7,8
 7dc:	4685                	li	a3,1
 7de:	4629                	li	a2,10
 7e0:	000ba583          	lw	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	e91ff0ef          	jal	676 <printint>
 7ea:	8bca                	mv	s7,s2
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	bfad                	j	768 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 7f0:	06400793          	li	a5,100
 7f4:	02f68963          	beq	a3,a5,826 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7f8:	06c00793          	li	a5,108
 7fc:	04f68263          	beq	a3,a5,840 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 800:	07500793          	li	a5,117
 804:	0af68063          	beq	a3,a5,8a4 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 808:	07800793          	li	a5,120
 80c:	0ef68263          	beq	a3,a5,8f0 <vprintf+0x1d2>
        putc(fd, '%');
 810:	02500593          	li	a1,37
 814:	855a                	mv	a0,s6
 816:	e43ff0ef          	jal	658 <putc>
        putc(fd, c0);
 81a:	85ca                	mv	a1,s2
 81c:	855a                	mv	a0,s6
 81e:	e3bff0ef          	jal	658 <putc>
      state = 0;
 822:	4981                	li	s3,0
 824:	b791                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 826:	008b8913          	addi	s2,s7,8
 82a:	4685                	li	a3,1
 82c:	4629                	li	a2,10
 82e:	000ba583          	lw	a1,0(s7)
 832:	855a                	mv	a0,s6
 834:	e43ff0ef          	jal	676 <printint>
        i += 1;
 838:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 83a:	8bca                	mv	s7,s2
      state = 0;
 83c:	4981                	li	s3,0
        i += 1;
 83e:	b72d                	j	768 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 840:	06400793          	li	a5,100
 844:	02f60763          	beq	a2,a5,872 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 848:	07500793          	li	a5,117
 84c:	06f60963          	beq	a2,a5,8be <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 850:	07800793          	li	a5,120
 854:	faf61ee3          	bne	a2,a5,810 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 858:	008b8913          	addi	s2,s7,8
 85c:	4681                	li	a3,0
 85e:	4641                	li	a2,16
 860:	000ba583          	lw	a1,0(s7)
 864:	855a                	mv	a0,s6
 866:	e11ff0ef          	jal	676 <printint>
        i += 2;
 86a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 86c:	8bca                	mv	s7,s2
      state = 0;
 86e:	4981                	li	s3,0
        i += 2;
 870:	bde5                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 872:	008b8913          	addi	s2,s7,8
 876:	4685                	li	a3,1
 878:	4629                	li	a2,10
 87a:	000ba583          	lw	a1,0(s7)
 87e:	855a                	mv	a0,s6
 880:	df7ff0ef          	jal	676 <printint>
        i += 2;
 884:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 886:	8bca                	mv	s7,s2
      state = 0;
 888:	4981                	li	s3,0
        i += 2;
 88a:	bdf9                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 88c:	008b8913          	addi	s2,s7,8
 890:	4681                	li	a3,0
 892:	4629                	li	a2,10
 894:	000ba583          	lw	a1,0(s7)
 898:	855a                	mv	a0,s6
 89a:	dddff0ef          	jal	676 <printint>
 89e:	8bca                	mv	s7,s2
      state = 0;
 8a0:	4981                	li	s3,0
 8a2:	b5d9                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8a4:	008b8913          	addi	s2,s7,8
 8a8:	4681                	li	a3,0
 8aa:	4629                	li	a2,10
 8ac:	000ba583          	lw	a1,0(s7)
 8b0:	855a                	mv	a0,s6
 8b2:	dc5ff0ef          	jal	676 <printint>
        i += 1;
 8b6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b8:	8bca                	mv	s7,s2
      state = 0;
 8ba:	4981                	li	s3,0
        i += 1;
 8bc:	b575                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8be:	008b8913          	addi	s2,s7,8
 8c2:	4681                	li	a3,0
 8c4:	4629                	li	a2,10
 8c6:	000ba583          	lw	a1,0(s7)
 8ca:	855a                	mv	a0,s6
 8cc:	dabff0ef          	jal	676 <printint>
        i += 2;
 8d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d2:	8bca                	mv	s7,s2
      state = 0;
 8d4:	4981                	li	s3,0
        i += 2;
 8d6:	bd49                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 8d8:	008b8913          	addi	s2,s7,8
 8dc:	4681                	li	a3,0
 8de:	4641                	li	a2,16
 8e0:	000ba583          	lw	a1,0(s7)
 8e4:	855a                	mv	a0,s6
 8e6:	d91ff0ef          	jal	676 <printint>
 8ea:	8bca                	mv	s7,s2
      state = 0;
 8ec:	4981                	li	s3,0
 8ee:	bdad                	j	768 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8f0:	008b8913          	addi	s2,s7,8
 8f4:	4681                	li	a3,0
 8f6:	4641                	li	a2,16
 8f8:	000ba583          	lw	a1,0(s7)
 8fc:	855a                	mv	a0,s6
 8fe:	d79ff0ef          	jal	676 <printint>
        i += 1;
 902:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 904:	8bca                	mv	s7,s2
      state = 0;
 906:	4981                	li	s3,0
        i += 1;
 908:	b585                	j	768 <vprintf+0x4a>
 90a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 90c:	008b8d13          	addi	s10,s7,8
 910:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 914:	03000593          	li	a1,48
 918:	855a                	mv	a0,s6
 91a:	d3fff0ef          	jal	658 <putc>
  putc(fd, 'x');
 91e:	07800593          	li	a1,120
 922:	855a                	mv	a0,s6
 924:	d35ff0ef          	jal	658 <putc>
 928:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 92a:	00000b97          	auipc	s7,0x0
 92e:	446b8b93          	addi	s7,s7,1094 # d70 <digits>
 932:	03c9d793          	srli	a5,s3,0x3c
 936:	97de                	add	a5,a5,s7
 938:	0007c583          	lbu	a1,0(a5)
 93c:	855a                	mv	a0,s6
 93e:	d1bff0ef          	jal	658 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 942:	0992                	slli	s3,s3,0x4
 944:	397d                	addiw	s2,s2,-1
 946:	fe0916e3          	bnez	s2,932 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 94a:	8bea                	mv	s7,s10
      state = 0;
 94c:	4981                	li	s3,0
 94e:	6d02                	ld	s10,0(sp)
 950:	bd21                	j	768 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 952:	008b8993          	addi	s3,s7,8
 956:	000bb903          	ld	s2,0(s7)
 95a:	00090f63          	beqz	s2,978 <vprintf+0x25a>
        for(; *s; s++)
 95e:	00094583          	lbu	a1,0(s2)
 962:	c195                	beqz	a1,986 <vprintf+0x268>
          putc(fd, *s);
 964:	855a                	mv	a0,s6
 966:	cf3ff0ef          	jal	658 <putc>
        for(; *s; s++)
 96a:	0905                	addi	s2,s2,1
 96c:	00094583          	lbu	a1,0(s2)
 970:	f9f5                	bnez	a1,964 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 972:	8bce                	mv	s7,s3
      state = 0;
 974:	4981                	li	s3,0
 976:	bbcd                	j	768 <vprintf+0x4a>
          s = "(null)";
 978:	00000917          	auipc	s2,0x0
 97c:	3f090913          	addi	s2,s2,1008 # d68 <malloc+0x2e4>
        for(; *s; s++)
 980:	02800593          	li	a1,40
 984:	b7c5                	j	964 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 986:	8bce                	mv	s7,s3
      state = 0;
 988:	4981                	li	s3,0
 98a:	bbf9                	j	768 <vprintf+0x4a>
 98c:	64a6                	ld	s1,72(sp)
 98e:	79e2                	ld	s3,56(sp)
 990:	7a42                	ld	s4,48(sp)
 992:	7aa2                	ld	s5,40(sp)
 994:	7b02                	ld	s6,32(sp)
 996:	6be2                	ld	s7,24(sp)
 998:	6c42                	ld	s8,16(sp)
 99a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 99c:	60e6                	ld	ra,88(sp)
 99e:	6446                	ld	s0,80(sp)
 9a0:	6906                	ld	s2,64(sp)
 9a2:	6125                	addi	sp,sp,96
 9a4:	8082                	ret

00000000000009a6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9a6:	715d                	addi	sp,sp,-80
 9a8:	ec06                	sd	ra,24(sp)
 9aa:	e822                	sd	s0,16(sp)
 9ac:	1000                	addi	s0,sp,32
 9ae:	e010                	sd	a2,0(s0)
 9b0:	e414                	sd	a3,8(s0)
 9b2:	e818                	sd	a4,16(s0)
 9b4:	ec1c                	sd	a5,24(s0)
 9b6:	03043023          	sd	a6,32(s0)
 9ba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9be:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9c2:	8622                	mv	a2,s0
 9c4:	d5bff0ef          	jal	71e <vprintf>
}
 9c8:	60e2                	ld	ra,24(sp)
 9ca:	6442                	ld	s0,16(sp)
 9cc:	6161                	addi	sp,sp,80
 9ce:	8082                	ret

00000000000009d0 <printf>:

void
printf(const char *fmt, ...)
{
 9d0:	711d                	addi	sp,sp,-96
 9d2:	ec06                	sd	ra,24(sp)
 9d4:	e822                	sd	s0,16(sp)
 9d6:	1000                	addi	s0,sp,32
 9d8:	e40c                	sd	a1,8(s0)
 9da:	e810                	sd	a2,16(s0)
 9dc:	ec14                	sd	a3,24(s0)
 9de:	f018                	sd	a4,32(s0)
 9e0:	f41c                	sd	a5,40(s0)
 9e2:	03043823          	sd	a6,48(s0)
 9e6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9ea:	00840613          	addi	a2,s0,8
 9ee:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9f2:	85aa                	mv	a1,a0
 9f4:	4505                	li	a0,1
 9f6:	d29ff0ef          	jal	71e <vprintf>
}
 9fa:	60e2                	ld	ra,24(sp)
 9fc:	6442                	ld	s0,16(sp)
 9fe:	6125                	addi	sp,sp,96
 a00:	8082                	ret

0000000000000a02 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a02:	1141                	addi	sp,sp,-16
 a04:	e422                	sd	s0,8(sp)
 a06:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a08:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a0c:	00000797          	auipc	a5,0x0
 a10:	5f47b783          	ld	a5,1524(a5) # 1000 <freep>
 a14:	a02d                	j	a3e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a16:	4618                	lw	a4,8(a2)
 a18:	9f2d                	addw	a4,a4,a1
 a1a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a1e:	6398                	ld	a4,0(a5)
 a20:	6310                	ld	a2,0(a4)
 a22:	a83d                	j	a60 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a24:	ff852703          	lw	a4,-8(a0)
 a28:	9f31                	addw	a4,a4,a2
 a2a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a2c:	ff053683          	ld	a3,-16(a0)
 a30:	a091                	j	a74 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a32:	6398                	ld	a4,0(a5)
 a34:	00e7e463          	bltu	a5,a4,a3c <free+0x3a>
 a38:	00e6ea63          	bltu	a3,a4,a4c <free+0x4a>
{
 a3c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a3e:	fed7fae3          	bgeu	a5,a3,a32 <free+0x30>
 a42:	6398                	ld	a4,0(a5)
 a44:	00e6e463          	bltu	a3,a4,a4c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a48:	fee7eae3          	bltu	a5,a4,a3c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a4c:	ff852583          	lw	a1,-8(a0)
 a50:	6390                	ld	a2,0(a5)
 a52:	02059813          	slli	a6,a1,0x20
 a56:	01c85713          	srli	a4,a6,0x1c
 a5a:	9736                	add	a4,a4,a3
 a5c:	fae60de3          	beq	a2,a4,a16 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a60:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a64:	4790                	lw	a2,8(a5)
 a66:	02061593          	slli	a1,a2,0x20
 a6a:	01c5d713          	srli	a4,a1,0x1c
 a6e:	973e                	add	a4,a4,a5
 a70:	fae68ae3          	beq	a3,a4,a24 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a74:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a76:	00000717          	auipc	a4,0x0
 a7a:	58f73523          	sd	a5,1418(a4) # 1000 <freep>
}
 a7e:	6422                	ld	s0,8(sp)
 a80:	0141                	addi	sp,sp,16
 a82:	8082                	ret

0000000000000a84 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a84:	7139                	addi	sp,sp,-64
 a86:	fc06                	sd	ra,56(sp)
 a88:	f822                	sd	s0,48(sp)
 a8a:	f426                	sd	s1,40(sp)
 a8c:	ec4e                	sd	s3,24(sp)
 a8e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a90:	02051493          	slli	s1,a0,0x20
 a94:	9081                	srli	s1,s1,0x20
 a96:	04bd                	addi	s1,s1,15
 a98:	8091                	srli	s1,s1,0x4
 a9a:	0014899b          	addiw	s3,s1,1
 a9e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 aa0:	00000517          	auipc	a0,0x0
 aa4:	56053503          	ld	a0,1376(a0) # 1000 <freep>
 aa8:	c915                	beqz	a0,adc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 aaa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aac:	4798                	lw	a4,8(a5)
 aae:	08977a63          	bgeu	a4,s1,b42 <malloc+0xbe>
 ab2:	f04a                	sd	s2,32(sp)
 ab4:	e852                	sd	s4,16(sp)
 ab6:	e456                	sd	s5,8(sp)
 ab8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 aba:	8a4e                	mv	s4,s3
 abc:	0009871b          	sext.w	a4,s3
 ac0:	6685                	lui	a3,0x1
 ac2:	00d77363          	bgeu	a4,a3,ac8 <malloc+0x44>
 ac6:	6a05                	lui	s4,0x1
 ac8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 acc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ad0:	00000917          	auipc	s2,0x0
 ad4:	53090913          	addi	s2,s2,1328 # 1000 <freep>
  if(p == (char*)-1)
 ad8:	5afd                	li	s5,-1
 ada:	a081                	j	b1a <malloc+0x96>
 adc:	f04a                	sd	s2,32(sp)
 ade:	e852                	sd	s4,16(sp)
 ae0:	e456                	sd	s5,8(sp)
 ae2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 ae4:	00000797          	auipc	a5,0x0
 ae8:	52c78793          	addi	a5,a5,1324 # 1010 <base>
 aec:	00000717          	auipc	a4,0x0
 af0:	50f73a23          	sd	a5,1300(a4) # 1000 <freep>
 af4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 af6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 afa:	b7c1                	j	aba <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 afc:	6398                	ld	a4,0(a5)
 afe:	e118                	sd	a4,0(a0)
 b00:	a8a9                	j	b5a <malloc+0xd6>
  hp->s.size = nu;
 b02:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b06:	0541                	addi	a0,a0,16
 b08:	efbff0ef          	jal	a02 <free>
  return freep;
 b0c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b10:	c12d                	beqz	a0,b72 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b12:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b14:	4798                	lw	a4,8(a5)
 b16:	02977263          	bgeu	a4,s1,b3a <malloc+0xb6>
    if(p == freep)
 b1a:	00093703          	ld	a4,0(s2)
 b1e:	853e                	mv	a0,a5
 b20:	fef719e3          	bne	a4,a5,b12 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b24:	8552                	mv	a0,s4
 b26:	b0bff0ef          	jal	630 <sbrk>
  if(p == (char*)-1)
 b2a:	fd551ce3          	bne	a0,s5,b02 <malloc+0x7e>
        return 0;
 b2e:	4501                	li	a0,0
 b30:	7902                	ld	s2,32(sp)
 b32:	6a42                	ld	s4,16(sp)
 b34:	6aa2                	ld	s5,8(sp)
 b36:	6b02                	ld	s6,0(sp)
 b38:	a03d                	j	b66 <malloc+0xe2>
 b3a:	7902                	ld	s2,32(sp)
 b3c:	6a42                	ld	s4,16(sp)
 b3e:	6aa2                	ld	s5,8(sp)
 b40:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b42:	fae48de3          	beq	s1,a4,afc <malloc+0x78>
        p->s.size -= nunits;
 b46:	4137073b          	subw	a4,a4,s3
 b4a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b4c:	02071693          	slli	a3,a4,0x20
 b50:	01c6d713          	srli	a4,a3,0x1c
 b54:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b56:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b5a:	00000717          	auipc	a4,0x0
 b5e:	4aa73323          	sd	a0,1190(a4) # 1000 <freep>
      return (void*)(p + 1);
 b62:	01078513          	addi	a0,a5,16
  }
}
 b66:	70e2                	ld	ra,56(sp)
 b68:	7442                	ld	s0,48(sp)
 b6a:	74a2                	ld	s1,40(sp)
 b6c:	69e2                	ld	s3,24(sp)
 b6e:	6121                	addi	sp,sp,64
 b70:	8082                	ret
 b72:	7902                	ld	s2,32(sp)
 b74:	6a42                	ld	s4,16(sp)
 b76:	6aa2                	ld	s5,8(sp)
 b78:	6b02                	ld	s6,0(sp)
 b7a:	b7f5                	j	b66 <malloc+0xe2>
