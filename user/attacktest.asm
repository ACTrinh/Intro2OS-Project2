
user/_attacktest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
char output[64];

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
   6:	611c                	ld	a5,0(a0)
   8:	80000737          	lui	a4,0x80000
   c:	ffe74713          	xori	a4,a4,-2
  10:	02e7f7b3          	remu	a5,a5,a4
  14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
  16:	66fd                	lui	a3,0x1f
  18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1e2bd>
  1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
  20:	6611                	lui	a2,0x4
  22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x3147>
  26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
  2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
  2e:	76fd                	lui	a3,0xfffff
  30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffe48c>
  34:	02d787b3          	mul	a5,a5,a3
  38:	97ba                	add	a5,a5,a4
    if (x < 0)
  3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
  3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
  40:	e11c                	sd	a5,0(a0)
    return (x);
}
  42:	0007851b          	sext.w	a0,a5
  46:	6422                	ld	s0,8(sp)
  48:	0141                	addi	sp,sp,16
  4a:	8082                	ret
        x += 0x7fffffff;
  4c:	80000737          	lui	a4,0x80000
  50:	fff74713          	not	a4,a4
  54:	97ba                	add	a5,a5,a4
  56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e406                	sd	ra,8(sp)
  5c:	e022                	sd	s0,0(sp)
  5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
  60:	00001517          	auipc	a0,0x1
  64:	fa050513          	addi	a0,a0,-96 # 1000 <rand_next>
  68:	f99ff0ef          	jal	0 <do_rand>
}
  6c:	60a2                	ld	ra,8(sp)
  6e:	6402                	ld	s0,0(sp)
  70:	0141                	addi	sp,sp,16
  72:	8082                	ret

0000000000000074 <randstring>:

// generate a random string of the indicated length.
char *
randstring(char *buf, int n)
{
  74:	7139                	addi	sp,sp,-64
  76:	fc06                	sd	ra,56(sp)
  78:	f822                	sd	s0,48(sp)
  7a:	e852                	sd	s4,16(sp)
  7c:	e456                	sd	s5,8(sp)
  7e:	0080                	addi	s0,sp,64
  80:	8aaa                	mv	s5,a0
  82:	8a2e                	mv	s4,a1
  for(int i = 0; i < n-1; i++) {
  84:	4785                	li	a5,1
  86:	06b7d163          	bge	a5,a1,e8 <randstring+0x74>
  8a:	f426                	sd	s1,40(sp)
  8c:	f04a                	sd	s2,32(sp)
  8e:	ec4e                	sd	s3,24(sp)
  90:	84aa                	mv	s1,a0
  92:	00150913          	addi	s2,a0,1
  96:	ffe5879b          	addiw	a5,a1,-2
  9a:	1782                	slli	a5,a5,0x20
  9c:	9381                	srli	a5,a5,0x20
  9e:	993e                	add	s2,s2,a5
    buf[i] = "./abcdef"[(rand() >> 7) % 8];
  a0:	00001997          	auipc	s3,0x1
  a4:	a0098993          	addi	s3,s3,-1536 # aa0 <malloc+0xfa>
  a8:	fb1ff0ef          	jal	58 <rand>
  ac:	4075579b          	sraiw	a5,a0,0x7
  b0:	41f5551b          	sraiw	a0,a0,0x1f
  b4:	01d5571b          	srliw	a4,a0,0x1d
  b8:	9fb9                	addw	a5,a5,a4
  ba:	8b9d                	andi	a5,a5,7
  bc:	9f99                	subw	a5,a5,a4
  be:	97ce                	add	a5,a5,s3
  c0:	0007c783          	lbu	a5,0(a5)
  c4:	00f48023          	sb	a5,0(s1)
  for(int i = 0; i < n-1; i++) {
  c8:	0485                	addi	s1,s1,1
  ca:	fd249fe3          	bne	s1,s2,a8 <randstring+0x34>
  ce:	74a2                	ld	s1,40(sp)
  d0:	7902                	ld	s2,32(sp)
  d2:	69e2                	ld	s3,24(sp)
  }
  if(n > 0)
    buf[n-1] = '\0';
  d4:	9a56                	add	s4,s4,s5
  d6:	fe0a0fa3          	sb	zero,-1(s4)
  return buf;
}
  da:	8556                	mv	a0,s5
  dc:	70e2                	ld	ra,56(sp)
  de:	7442                	ld	s0,48(sp)
  e0:	6a42                	ld	s4,16(sp)
  e2:	6aa2                	ld	s5,8(sp)
  e4:	6121                	addi	sp,sp,64
  e6:	8082                	ret
  if(n > 0)
  e8:	feb059e3          	blez	a1,da <randstring+0x66>
  ec:	b7e5                	j	d4 <randstring+0x60>

00000000000000ee <main>:

int
main(int argc, char *argv[])
{
  ee:	7179                	addi	sp,sp,-48
  f0:	f406                	sd	ra,40(sp)
  f2:	f022                	sd	s0,32(sp)
  f4:	1800                	addi	s0,sp,48
  int pid;
  int fds[2];

  // an insecure way of generating a random string, because xv6
  // doesn't have good source of randomness.
  rand_next = uptime();
  f6:	46c000ef          	jal	562 <uptime>
  fa:	00001797          	auipc	a5,0x1
  fe:	f0a7b323          	sd	a0,-250(a5) # 1000 <rand_next>
  randstring(secret, 8);
 102:	45a1                	li	a1,8
 104:	00001517          	auipc	a0,0x1
 108:	f0c50513          	addi	a0,a0,-244 # 1010 <secret>
 10c:	f69ff0ef          	jal	74 <randstring>
  
  if((pid = fork()) < 0) {
 110:	3b2000ef          	jal	4c2 <fork>
 114:	06054c63          	bltz	a0,18c <main+0x9e>
    printf("fork failed\n");
    exit(1);   
  }
  if(pid == 0) {
 118:	c159                	beqz	a0,19e <main+0xb0>
    char *newargv[] = { "secret", secret, 0 };
    exec(newargv[0], newargv);
    printf("exec %s failed\n", newargv[0]);
    exit(1);
  } else {
    wait(0);  // wait for secret to exit
 11a:	4501                	li	a0,0
 11c:	3b6000ef          	jal	4d2 <wait>
    if(pipe(fds) < 0) {
 120:	fe840513          	addi	a0,s0,-24
 124:	3b6000ef          	jal	4da <pipe>
 128:	0a054863          	bltz	a0,1d8 <main+0xea>
      printf("pipe failed\n");
      exit(1);   
    }
    if((pid = fork()) < 0) {
 12c:	396000ef          	jal	4c2 <fork>
 130:	0a054d63          	bltz	a0,1ea <main+0xfc>
      printf("fork failed\n");
      exit(1);   
    }
    if(pid == 0) {
 134:	c561                	beqz	a0,1fc <main+0x10e>
      char *newargv[] = { "attack", 0 };
      exec(newargv[0], newargv);
      printf("exec %s failed\n", newargv[0]);
      exit(1);
    } else {
       close(fds[1]);
 136:	fec42503          	lw	a0,-20(s0)
 13a:	3b8000ef          	jal	4f2 <close>
      if(read(fds[0], output, 64) < 0) {
 13e:	04000613          	li	a2,64
 142:	00001597          	auipc	a1,0x1
 146:	ede58593          	addi	a1,a1,-290 # 1020 <output>
 14a:	fe842503          	lw	a0,-24(s0)
 14e:	394000ef          	jal	4e2 <read>
 152:	0e054763          	bltz	a0,240 <main+0x152>
        printf("FAIL; read failed; no secret\n");
        exit(1);
      }
      if(strcmp(secret, output) == 0) {
 156:	00001597          	auipc	a1,0x1
 15a:	eca58593          	addi	a1,a1,-310 # 1020 <output>
 15e:	00001517          	auipc	a0,0x1
 162:	eb250513          	addi	a0,a0,-334 # 1010 <secret>
 166:	128000ef          	jal	28e <strcmp>
 16a:	0e051463          	bnez	a0,252 <main+0x164>
        printf("OK: secret is %s\n", output);
 16e:	00001597          	auipc	a1,0x1
 172:	eb258593          	addi	a1,a1,-334 # 1020 <output>
 176:	00001517          	auipc	a0,0x1
 17a:	99a50513          	addi	a0,a0,-1638 # b10 <malloc+0x16a>
 17e:	774000ef          	jal	8f2 <printf>
      } else {
        printf("FAIL: no/incorrect secret\n");
      }
    }
  }
}
 182:	4501                	li	a0,0
 184:	70a2                	ld	ra,40(sp)
 186:	7402                	ld	s0,32(sp)
 188:	6145                	addi	sp,sp,48
 18a:	8082                	ret
    printf("fork failed\n");
 18c:	00001517          	auipc	a0,0x1
 190:	92450513          	addi	a0,a0,-1756 # ab0 <malloc+0x10a>
 194:	75e000ef          	jal	8f2 <printf>
    exit(1);   
 198:	4505                	li	a0,1
 19a:	330000ef          	jal	4ca <exit>
    char *newargv[] = { "secret", secret, 0 };
 19e:	00001517          	auipc	a0,0x1
 1a2:	92250513          	addi	a0,a0,-1758 # ac0 <malloc+0x11a>
 1a6:	fca43823          	sd	a0,-48(s0)
 1aa:	00001797          	auipc	a5,0x1
 1ae:	e6678793          	addi	a5,a5,-410 # 1010 <secret>
 1b2:	fcf43c23          	sd	a5,-40(s0)
 1b6:	fe043023          	sd	zero,-32(s0)
    exec(newargv[0], newargv);
 1ba:	fd040593          	addi	a1,s0,-48
 1be:	344000ef          	jal	502 <exec>
    printf("exec %s failed\n", newargv[0]);
 1c2:	fd043583          	ld	a1,-48(s0)
 1c6:	00001517          	auipc	a0,0x1
 1ca:	90250513          	addi	a0,a0,-1790 # ac8 <malloc+0x122>
 1ce:	724000ef          	jal	8f2 <printf>
    exit(1);
 1d2:	4505                	li	a0,1
 1d4:	2f6000ef          	jal	4ca <exit>
      printf("pipe failed\n");
 1d8:	00001517          	auipc	a0,0x1
 1dc:	90050513          	addi	a0,a0,-1792 # ad8 <malloc+0x132>
 1e0:	712000ef          	jal	8f2 <printf>
      exit(1);   
 1e4:	4505                	li	a0,1
 1e6:	2e4000ef          	jal	4ca <exit>
      printf("fork failed\n");
 1ea:	00001517          	auipc	a0,0x1
 1ee:	8c650513          	addi	a0,a0,-1850 # ab0 <malloc+0x10a>
 1f2:	700000ef          	jal	8f2 <printf>
      exit(1);   
 1f6:	4505                	li	a0,1
 1f8:	2d2000ef          	jal	4ca <exit>
      close(fds[0]);
 1fc:	fe842503          	lw	a0,-24(s0)
 200:	2f2000ef          	jal	4f2 <close>
      close(2);
 204:	4509                	li	a0,2
 206:	2ec000ef          	jal	4f2 <close>
      dup(fds[1]);
 20a:	fec42503          	lw	a0,-20(s0)
 20e:	334000ef          	jal	542 <dup>
      char *newargv[] = { "attack", 0 };
 212:	00001517          	auipc	a0,0x1
 216:	8d650513          	addi	a0,a0,-1834 # ae8 <malloc+0x142>
 21a:	fca43823          	sd	a0,-48(s0)
 21e:	fc043c23          	sd	zero,-40(s0)
      exec(newargv[0], newargv);
 222:	fd040593          	addi	a1,s0,-48
 226:	2dc000ef          	jal	502 <exec>
      printf("exec %s failed\n", newargv[0]);
 22a:	fd043583          	ld	a1,-48(s0)
 22e:	00001517          	auipc	a0,0x1
 232:	89a50513          	addi	a0,a0,-1894 # ac8 <malloc+0x122>
 236:	6bc000ef          	jal	8f2 <printf>
      exit(1);
 23a:	4505                	li	a0,1
 23c:	28e000ef          	jal	4ca <exit>
        printf("FAIL; read failed; no secret\n");
 240:	00001517          	auipc	a0,0x1
 244:	8b050513          	addi	a0,a0,-1872 # af0 <malloc+0x14a>
 248:	6aa000ef          	jal	8f2 <printf>
        exit(1);
 24c:	4505                	li	a0,1
 24e:	27c000ef          	jal	4ca <exit>
        printf("FAIL: no/incorrect secret\n");
 252:	00001517          	auipc	a0,0x1
 256:	8d650513          	addi	a0,a0,-1834 # b28 <malloc+0x182>
 25a:	698000ef          	jal	8f2 <printf>
 25e:	b715                	j	182 <main+0x94>

0000000000000260 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 260:	1141                	addi	sp,sp,-16
 262:	e406                	sd	ra,8(sp)
 264:	e022                	sd	s0,0(sp)
 266:	0800                	addi	s0,sp,16
  extern int main();
  main();
 268:	e87ff0ef          	jal	ee <main>
  exit(0);
 26c:	4501                	li	a0,0
 26e:	25c000ef          	jal	4ca <exit>

0000000000000272 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 278:	87aa                	mv	a5,a0
 27a:	0585                	addi	a1,a1,1
 27c:	0785                	addi	a5,a5,1
 27e:	fff5c703          	lbu	a4,-1(a1)
 282:	fee78fa3          	sb	a4,-1(a5)
 286:	fb75                	bnez	a4,27a <strcpy+0x8>
    ;
  return os;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 294:	00054783          	lbu	a5,0(a0)
 298:	cb91                	beqz	a5,2ac <strcmp+0x1e>
 29a:	0005c703          	lbu	a4,0(a1)
 29e:	00f71763          	bne	a4,a5,2ac <strcmp+0x1e>
    p++, q++;
 2a2:	0505                	addi	a0,a0,1
 2a4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	fbe5                	bnez	a5,29a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2ac:	0005c503          	lbu	a0,0(a1)
}
 2b0:	40a7853b          	subw	a0,a5,a0
 2b4:	6422                	ld	s0,8(sp)
 2b6:	0141                	addi	sp,sp,16
 2b8:	8082                	ret

00000000000002ba <strlen>:

uint
strlen(const char *s)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	cf91                	beqz	a5,2e0 <strlen+0x26>
 2c6:	0505                	addi	a0,a0,1
 2c8:	87aa                	mv	a5,a0
 2ca:	86be                	mv	a3,a5
 2cc:	0785                	addi	a5,a5,1
 2ce:	fff7c703          	lbu	a4,-1(a5)
 2d2:	ff65                	bnez	a4,2ca <strlen+0x10>
 2d4:	40a6853b          	subw	a0,a3,a0
 2d8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2da:	6422                	ld	s0,8(sp)
 2dc:	0141                	addi	sp,sp,16
 2de:	8082                	ret
  for(n = 0; s[n]; n++)
 2e0:	4501                	li	a0,0
 2e2:	bfe5                	j	2da <strlen+0x20>

00000000000002e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2ea:	ca19                	beqz	a2,300 <memset+0x1c>
 2ec:	87aa                	mv	a5,a0
 2ee:	1602                	slli	a2,a2,0x20
 2f0:	9201                	srli	a2,a2,0x20
 2f2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2f6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2fa:	0785                	addi	a5,a5,1
 2fc:	fee79de3          	bne	a5,a4,2f6 <memset+0x12>
  }
  return dst;
}
 300:	6422                	ld	s0,8(sp)
 302:	0141                	addi	sp,sp,16
 304:	8082                	ret

0000000000000306 <strchr>:

char*
strchr(const char *s, char c)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 30c:	00054783          	lbu	a5,0(a0)
 310:	cb99                	beqz	a5,326 <strchr+0x20>
    if(*s == c)
 312:	00f58763          	beq	a1,a5,320 <strchr+0x1a>
  for(; *s; s++)
 316:	0505                	addi	a0,a0,1
 318:	00054783          	lbu	a5,0(a0)
 31c:	fbfd                	bnez	a5,312 <strchr+0xc>
      return (char*)s;
  return 0;
 31e:	4501                	li	a0,0
}
 320:	6422                	ld	s0,8(sp)
 322:	0141                	addi	sp,sp,16
 324:	8082                	ret
  return 0;
 326:	4501                	li	a0,0
 328:	bfe5                	j	320 <strchr+0x1a>

000000000000032a <gets>:

char*
gets(char *buf, int max)
{
 32a:	711d                	addi	sp,sp,-96
 32c:	ec86                	sd	ra,88(sp)
 32e:	e8a2                	sd	s0,80(sp)
 330:	e4a6                	sd	s1,72(sp)
 332:	e0ca                	sd	s2,64(sp)
 334:	fc4e                	sd	s3,56(sp)
 336:	f852                	sd	s4,48(sp)
 338:	f456                	sd	s5,40(sp)
 33a:	f05a                	sd	s6,32(sp)
 33c:	ec5e                	sd	s7,24(sp)
 33e:	1080                	addi	s0,sp,96
 340:	8baa                	mv	s7,a0
 342:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 344:	892a                	mv	s2,a0
 346:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 348:	4aa9                	li	s5,10
 34a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 34c:	89a6                	mv	s3,s1
 34e:	2485                	addiw	s1,s1,1
 350:	0344d663          	bge	s1,s4,37c <gets+0x52>
    cc = read(0, &c, 1);
 354:	4605                	li	a2,1
 356:	faf40593          	addi	a1,s0,-81
 35a:	4501                	li	a0,0
 35c:	186000ef          	jal	4e2 <read>
    if(cc < 1)
 360:	00a05e63          	blez	a0,37c <gets+0x52>
    buf[i++] = c;
 364:	faf44783          	lbu	a5,-81(s0)
 368:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 36c:	01578763          	beq	a5,s5,37a <gets+0x50>
 370:	0905                	addi	s2,s2,1
 372:	fd679de3          	bne	a5,s6,34c <gets+0x22>
    buf[i++] = c;
 376:	89a6                	mv	s3,s1
 378:	a011                	j	37c <gets+0x52>
 37a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 37c:	99de                	add	s3,s3,s7
 37e:	00098023          	sb	zero,0(s3)
  return buf;
}
 382:	855e                	mv	a0,s7
 384:	60e6                	ld	ra,88(sp)
 386:	6446                	ld	s0,80(sp)
 388:	64a6                	ld	s1,72(sp)
 38a:	6906                	ld	s2,64(sp)
 38c:	79e2                	ld	s3,56(sp)
 38e:	7a42                	ld	s4,48(sp)
 390:	7aa2                	ld	s5,40(sp)
 392:	7b02                	ld	s6,32(sp)
 394:	6be2                	ld	s7,24(sp)
 396:	6125                	addi	sp,sp,96
 398:	8082                	ret

000000000000039a <stat>:

int
stat(const char *n, struct stat *st)
{
 39a:	1101                	addi	sp,sp,-32
 39c:	ec06                	sd	ra,24(sp)
 39e:	e822                	sd	s0,16(sp)
 3a0:	e04a                	sd	s2,0(sp)
 3a2:	1000                	addi	s0,sp,32
 3a4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3a6:	4581                	li	a1,0
 3a8:	162000ef          	jal	50a <open>
  if(fd < 0)
 3ac:	02054263          	bltz	a0,3d0 <stat+0x36>
 3b0:	e426                	sd	s1,8(sp)
 3b2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3b4:	85ca                	mv	a1,s2
 3b6:	16c000ef          	jal	522 <fstat>
 3ba:	892a                	mv	s2,a0
  close(fd);
 3bc:	8526                	mv	a0,s1
 3be:	134000ef          	jal	4f2 <close>
  return r;
 3c2:	64a2                	ld	s1,8(sp)
}
 3c4:	854a                	mv	a0,s2
 3c6:	60e2                	ld	ra,24(sp)
 3c8:	6442                	ld	s0,16(sp)
 3ca:	6902                	ld	s2,0(sp)
 3cc:	6105                	addi	sp,sp,32
 3ce:	8082                	ret
    return -1;
 3d0:	597d                	li	s2,-1
 3d2:	bfcd                	j	3c4 <stat+0x2a>

00000000000003d4 <atoi>:

int
atoi(const char *s)
{
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e422                	sd	s0,8(sp)
 3d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3da:	00054683          	lbu	a3,0(a0)
 3de:	fd06879b          	addiw	a5,a3,-48
 3e2:	0ff7f793          	zext.b	a5,a5
 3e6:	4625                	li	a2,9
 3e8:	02f66863          	bltu	a2,a5,418 <atoi+0x44>
 3ec:	872a                	mv	a4,a0
  n = 0;
 3ee:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3f0:	0705                	addi	a4,a4,1 # ffffffff80000001 <base+0xffffffff7fffefa1>
 3f2:	0025179b          	slliw	a5,a0,0x2
 3f6:	9fa9                	addw	a5,a5,a0
 3f8:	0017979b          	slliw	a5,a5,0x1
 3fc:	9fb5                	addw	a5,a5,a3
 3fe:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 402:	00074683          	lbu	a3,0(a4)
 406:	fd06879b          	addiw	a5,a3,-48
 40a:	0ff7f793          	zext.b	a5,a5
 40e:	fef671e3          	bgeu	a2,a5,3f0 <atoi+0x1c>
  return n;
}
 412:	6422                	ld	s0,8(sp)
 414:	0141                	addi	sp,sp,16
 416:	8082                	ret
  n = 0;
 418:	4501                	li	a0,0
 41a:	bfe5                	j	412 <atoi+0x3e>

000000000000041c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 41c:	1141                	addi	sp,sp,-16
 41e:	e422                	sd	s0,8(sp)
 420:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 422:	02b57463          	bgeu	a0,a1,44a <memmove+0x2e>
    while(n-- > 0)
 426:	00c05f63          	blez	a2,444 <memmove+0x28>
 42a:	1602                	slli	a2,a2,0x20
 42c:	9201                	srli	a2,a2,0x20
 42e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 432:	872a                	mv	a4,a0
      *dst++ = *src++;
 434:	0585                	addi	a1,a1,1
 436:	0705                	addi	a4,a4,1
 438:	fff5c683          	lbu	a3,-1(a1)
 43c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 440:	fef71ae3          	bne	a4,a5,434 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 444:	6422                	ld	s0,8(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret
    dst += n;
 44a:	00c50733          	add	a4,a0,a2
    src += n;
 44e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 450:	fec05ae3          	blez	a2,444 <memmove+0x28>
 454:	fff6079b          	addiw	a5,a2,-1
 458:	1782                	slli	a5,a5,0x20
 45a:	9381                	srli	a5,a5,0x20
 45c:	fff7c793          	not	a5,a5
 460:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 462:	15fd                	addi	a1,a1,-1
 464:	177d                	addi	a4,a4,-1
 466:	0005c683          	lbu	a3,0(a1)
 46a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 46e:	fee79ae3          	bne	a5,a4,462 <memmove+0x46>
 472:	bfc9                	j	444 <memmove+0x28>

0000000000000474 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 474:	1141                	addi	sp,sp,-16
 476:	e422                	sd	s0,8(sp)
 478:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 47a:	ca05                	beqz	a2,4aa <memcmp+0x36>
 47c:	fff6069b          	addiw	a3,a2,-1
 480:	1682                	slli	a3,a3,0x20
 482:	9281                	srli	a3,a3,0x20
 484:	0685                	addi	a3,a3,1
 486:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 488:	00054783          	lbu	a5,0(a0)
 48c:	0005c703          	lbu	a4,0(a1)
 490:	00e79863          	bne	a5,a4,4a0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 494:	0505                	addi	a0,a0,1
    p2++;
 496:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 498:	fed518e3          	bne	a0,a3,488 <memcmp+0x14>
  }
  return 0;
 49c:	4501                	li	a0,0
 49e:	a019                	j	4a4 <memcmp+0x30>
      return *p1 - *p2;
 4a0:	40e7853b          	subw	a0,a5,a4
}
 4a4:	6422                	ld	s0,8(sp)
 4a6:	0141                	addi	sp,sp,16
 4a8:	8082                	ret
  return 0;
 4aa:	4501                	li	a0,0
 4ac:	bfe5                	j	4a4 <memcmp+0x30>

00000000000004ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4ae:	1141                	addi	sp,sp,-16
 4b0:	e406                	sd	ra,8(sp)
 4b2:	e022                	sd	s0,0(sp)
 4b4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4b6:	f67ff0ef          	jal	41c <memmove>
}
 4ba:	60a2                	ld	ra,8(sp)
 4bc:	6402                	ld	s0,0(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret

00000000000004c2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4c2:	4885                	li	a7,1
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <exit>:
.global exit
exit:
 li a7, SYS_exit
 4ca:	4889                	li	a7,2
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 4d2:	488d                	li	a7,3
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4da:	4891                	li	a7,4
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <read>:
.global read
read:
 li a7, SYS_read
 4e2:	4895                	li	a7,5
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <write>:
.global write
write:
 li a7, SYS_write
 4ea:	48c1                	li	a7,16
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <close>:
.global close
close:
 li a7, SYS_close
 4f2:	48d5                	li	a7,21
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <kill>:
.global kill
kill:
 li a7, SYS_kill
 4fa:	4899                	li	a7,6
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <exec>:
.global exec
exec:
 li a7, SYS_exec
 502:	489d                	li	a7,7
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <open>:
.global open
open:
 li a7, SYS_open
 50a:	48bd                	li	a7,15
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 512:	48c5                	li	a7,17
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 51a:	48c9                	li	a7,18
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 522:	48a1                	li	a7,8
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <link>:
.global link
link:
 li a7, SYS_link
 52a:	48cd                	li	a7,19
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 532:	48d1                	li	a7,20
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 53a:	48a5                	li	a7,9
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <dup>:
.global dup
dup:
 li a7, SYS_dup
 542:	48a9                	li	a7,10
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 54a:	48ad                	li	a7,11
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 552:	48b1                	li	a7,12
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 55a:	48b5                	li	a7,13
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 562:	48b9                	li	a7,14
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <trace>:
.global trace
trace:
 li a7, SYS_trace
 56a:	48d9                	li	a7,22
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 572:	48dd                	li	a7,23
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 57a:	1101                	addi	sp,sp,-32
 57c:	ec06                	sd	ra,24(sp)
 57e:	e822                	sd	s0,16(sp)
 580:	1000                	addi	s0,sp,32
 582:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 586:	4605                	li	a2,1
 588:	fef40593          	addi	a1,s0,-17
 58c:	f5fff0ef          	jal	4ea <write>
}
 590:	60e2                	ld	ra,24(sp)
 592:	6442                	ld	s0,16(sp)
 594:	6105                	addi	sp,sp,32
 596:	8082                	ret

0000000000000598 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 598:	7139                	addi	sp,sp,-64
 59a:	fc06                	sd	ra,56(sp)
 59c:	f822                	sd	s0,48(sp)
 59e:	f426                	sd	s1,40(sp)
 5a0:	0080                	addi	s0,sp,64
 5a2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5a4:	c299                	beqz	a3,5aa <printint+0x12>
 5a6:	0805c963          	bltz	a1,638 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 5aa:	2581                	sext.w	a1,a1
  neg = 0;
 5ac:	4881                	li	a7,0
 5ae:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5b2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5b4:	2601                	sext.w	a2,a2
 5b6:	00000517          	auipc	a0,0x0
 5ba:	59a50513          	addi	a0,a0,1434 # b50 <digits>
 5be:	883a                	mv	a6,a4
 5c0:	2705                	addiw	a4,a4,1
 5c2:	02c5f7bb          	remuw	a5,a1,a2
 5c6:	1782                	slli	a5,a5,0x20
 5c8:	9381                	srli	a5,a5,0x20
 5ca:	97aa                	add	a5,a5,a0
 5cc:	0007c783          	lbu	a5,0(a5)
 5d0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5d4:	0005879b          	sext.w	a5,a1
 5d8:	02c5d5bb          	divuw	a1,a1,a2
 5dc:	0685                	addi	a3,a3,1
 5de:	fec7f0e3          	bgeu	a5,a2,5be <printint+0x26>
  if(neg)
 5e2:	00088c63          	beqz	a7,5fa <printint+0x62>
    buf[i++] = '-';
 5e6:	fd070793          	addi	a5,a4,-48
 5ea:	00878733          	add	a4,a5,s0
 5ee:	02d00793          	li	a5,45
 5f2:	fef70823          	sb	a5,-16(a4)
 5f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5fa:	02e05a63          	blez	a4,62e <printint+0x96>
 5fe:	f04a                	sd	s2,32(sp)
 600:	ec4e                	sd	s3,24(sp)
 602:	fc040793          	addi	a5,s0,-64
 606:	00e78933          	add	s2,a5,a4
 60a:	fff78993          	addi	s3,a5,-1
 60e:	99ba                	add	s3,s3,a4
 610:	377d                	addiw	a4,a4,-1
 612:	1702                	slli	a4,a4,0x20
 614:	9301                	srli	a4,a4,0x20
 616:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 61a:	fff94583          	lbu	a1,-1(s2)
 61e:	8526                	mv	a0,s1
 620:	f5bff0ef          	jal	57a <putc>
  while(--i >= 0)
 624:	197d                	addi	s2,s2,-1
 626:	ff391ae3          	bne	s2,s3,61a <printint+0x82>
 62a:	7902                	ld	s2,32(sp)
 62c:	69e2                	ld	s3,24(sp)
}
 62e:	70e2                	ld	ra,56(sp)
 630:	7442                	ld	s0,48(sp)
 632:	74a2                	ld	s1,40(sp)
 634:	6121                	addi	sp,sp,64
 636:	8082                	ret
    x = -xx;
 638:	40b005bb          	negw	a1,a1
    neg = 1;
 63c:	4885                	li	a7,1
    x = -xx;
 63e:	bf85                	j	5ae <printint+0x16>

0000000000000640 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 640:	711d                	addi	sp,sp,-96
 642:	ec86                	sd	ra,88(sp)
 644:	e8a2                	sd	s0,80(sp)
 646:	e0ca                	sd	s2,64(sp)
 648:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 64a:	0005c903          	lbu	s2,0(a1)
 64e:	26090863          	beqz	s2,8be <vprintf+0x27e>
 652:	e4a6                	sd	s1,72(sp)
 654:	fc4e                	sd	s3,56(sp)
 656:	f852                	sd	s4,48(sp)
 658:	f456                	sd	s5,40(sp)
 65a:	f05a                	sd	s6,32(sp)
 65c:	ec5e                	sd	s7,24(sp)
 65e:	e862                	sd	s8,16(sp)
 660:	e466                	sd	s9,8(sp)
 662:	8b2a                	mv	s6,a0
 664:	8a2e                	mv	s4,a1
 666:	8bb2                	mv	s7,a2
  state = 0;
 668:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 66a:	4481                	li	s1,0
 66c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 66e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 672:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 676:	06c00c93          	li	s9,108
 67a:	a005                	j	69a <vprintf+0x5a>
        putc(fd, c0);
 67c:	85ca                	mv	a1,s2
 67e:	855a                	mv	a0,s6
 680:	efbff0ef          	jal	57a <putc>
 684:	a019                	j	68a <vprintf+0x4a>
    } else if(state == '%'){
 686:	03598263          	beq	s3,s5,6aa <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 68a:	2485                	addiw	s1,s1,1
 68c:	8726                	mv	a4,s1
 68e:	009a07b3          	add	a5,s4,s1
 692:	0007c903          	lbu	s2,0(a5)
 696:	20090c63          	beqz	s2,8ae <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 69a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 69e:	fe0994e3          	bnez	s3,686 <vprintf+0x46>
      if(c0 == '%'){
 6a2:	fd579de3          	bne	a5,s5,67c <vprintf+0x3c>
        state = '%';
 6a6:	89be                	mv	s3,a5
 6a8:	b7cd                	j	68a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6aa:	00ea06b3          	add	a3,s4,a4
 6ae:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6b2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6b4:	c681                	beqz	a3,6bc <vprintf+0x7c>
 6b6:	9752                	add	a4,a4,s4
 6b8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6bc:	03878f63          	beq	a5,s8,6fa <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 6c0:	05978963          	beq	a5,s9,712 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6c4:	07500713          	li	a4,117
 6c8:	0ee78363          	beq	a5,a4,7ae <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6cc:	07800713          	li	a4,120
 6d0:	12e78563          	beq	a5,a4,7fa <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6d4:	07000713          	li	a4,112
 6d8:	14e78a63          	beq	a5,a4,82c <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 6dc:	07300713          	li	a4,115
 6e0:	18e78a63          	beq	a5,a4,874 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6e4:	02500713          	li	a4,37
 6e8:	04e79563          	bne	a5,a4,732 <vprintf+0xf2>
        putc(fd, '%');
 6ec:	02500593          	li	a1,37
 6f0:	855a                	mv	a0,s6
 6f2:	e89ff0ef          	jal	57a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bf49                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6fa:	008b8913          	addi	s2,s7,8
 6fe:	4685                	li	a3,1
 700:	4629                	li	a2,10
 702:	000ba583          	lw	a1,0(s7)
 706:	855a                	mv	a0,s6
 708:	e91ff0ef          	jal	598 <printint>
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
 710:	bfad                	j	68a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 712:	06400793          	li	a5,100
 716:	02f68963          	beq	a3,a5,748 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 71a:	06c00793          	li	a5,108
 71e:	04f68263          	beq	a3,a5,762 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 722:	07500793          	li	a5,117
 726:	0af68063          	beq	a3,a5,7c6 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 72a:	07800793          	li	a5,120
 72e:	0ef68263          	beq	a3,a5,812 <vprintf+0x1d2>
        putc(fd, '%');
 732:	02500593          	li	a1,37
 736:	855a                	mv	a0,s6
 738:	e43ff0ef          	jal	57a <putc>
        putc(fd, c0);
 73c:	85ca                	mv	a1,s2
 73e:	855a                	mv	a0,s6
 740:	e3bff0ef          	jal	57a <putc>
      state = 0;
 744:	4981                	li	s3,0
 746:	b791                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 748:	008b8913          	addi	s2,s7,8
 74c:	4685                	li	a3,1
 74e:	4629                	li	a2,10
 750:	000ba583          	lw	a1,0(s7)
 754:	855a                	mv	a0,s6
 756:	e43ff0ef          	jal	598 <printint>
        i += 1;
 75a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 75c:	8bca                	mv	s7,s2
      state = 0;
 75e:	4981                	li	s3,0
        i += 1;
 760:	b72d                	j	68a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 762:	06400793          	li	a5,100
 766:	02f60763          	beq	a2,a5,794 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 76a:	07500793          	li	a5,117
 76e:	06f60963          	beq	a2,a5,7e0 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 772:	07800793          	li	a5,120
 776:	faf61ee3          	bne	a2,a5,732 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 77a:	008b8913          	addi	s2,s7,8
 77e:	4681                	li	a3,0
 780:	4641                	li	a2,16
 782:	000ba583          	lw	a1,0(s7)
 786:	855a                	mv	a0,s6
 788:	e11ff0ef          	jal	598 <printint>
        i += 2;
 78c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 78e:	8bca                	mv	s7,s2
      state = 0;
 790:	4981                	li	s3,0
        i += 2;
 792:	bde5                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 794:	008b8913          	addi	s2,s7,8
 798:	4685                	li	a3,1
 79a:	4629                	li	a2,10
 79c:	000ba583          	lw	a1,0(s7)
 7a0:	855a                	mv	a0,s6
 7a2:	df7ff0ef          	jal	598 <printint>
        i += 2;
 7a6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7a8:	8bca                	mv	s7,s2
      state = 0;
 7aa:	4981                	li	s3,0
        i += 2;
 7ac:	bdf9                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 7ae:	008b8913          	addi	s2,s7,8
 7b2:	4681                	li	a3,0
 7b4:	4629                	li	a2,10
 7b6:	000ba583          	lw	a1,0(s7)
 7ba:	855a                	mv	a0,s6
 7bc:	dddff0ef          	jal	598 <printint>
 7c0:	8bca                	mv	s7,s2
      state = 0;
 7c2:	4981                	li	s3,0
 7c4:	b5d9                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7c6:	008b8913          	addi	s2,s7,8
 7ca:	4681                	li	a3,0
 7cc:	4629                	li	a2,10
 7ce:	000ba583          	lw	a1,0(s7)
 7d2:	855a                	mv	a0,s6
 7d4:	dc5ff0ef          	jal	598 <printint>
        i += 1;
 7d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7da:	8bca                	mv	s7,s2
      state = 0;
 7dc:	4981                	li	s3,0
        i += 1;
 7de:	b575                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e0:	008b8913          	addi	s2,s7,8
 7e4:	4681                	li	a3,0
 7e6:	4629                	li	a2,10
 7e8:	000ba583          	lw	a1,0(s7)
 7ec:	855a                	mv	a0,s6
 7ee:	dabff0ef          	jal	598 <printint>
        i += 2;
 7f2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f4:	8bca                	mv	s7,s2
      state = 0;
 7f6:	4981                	li	s3,0
        i += 2;
 7f8:	bd49                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 7fa:	008b8913          	addi	s2,s7,8
 7fe:	4681                	li	a3,0
 800:	4641                	li	a2,16
 802:	000ba583          	lw	a1,0(s7)
 806:	855a                	mv	a0,s6
 808:	d91ff0ef          	jal	598 <printint>
 80c:	8bca                	mv	s7,s2
      state = 0;
 80e:	4981                	li	s3,0
 810:	bdad                	j	68a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 812:	008b8913          	addi	s2,s7,8
 816:	4681                	li	a3,0
 818:	4641                	li	a2,16
 81a:	000ba583          	lw	a1,0(s7)
 81e:	855a                	mv	a0,s6
 820:	d79ff0ef          	jal	598 <printint>
        i += 1;
 824:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 826:	8bca                	mv	s7,s2
      state = 0;
 828:	4981                	li	s3,0
        i += 1;
 82a:	b585                	j	68a <vprintf+0x4a>
 82c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 82e:	008b8d13          	addi	s10,s7,8
 832:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 836:	03000593          	li	a1,48
 83a:	855a                	mv	a0,s6
 83c:	d3fff0ef          	jal	57a <putc>
  putc(fd, 'x');
 840:	07800593          	li	a1,120
 844:	855a                	mv	a0,s6
 846:	d35ff0ef          	jal	57a <putc>
 84a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 84c:	00000b97          	auipc	s7,0x0
 850:	304b8b93          	addi	s7,s7,772 # b50 <digits>
 854:	03c9d793          	srli	a5,s3,0x3c
 858:	97de                	add	a5,a5,s7
 85a:	0007c583          	lbu	a1,0(a5)
 85e:	855a                	mv	a0,s6
 860:	d1bff0ef          	jal	57a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 864:	0992                	slli	s3,s3,0x4
 866:	397d                	addiw	s2,s2,-1
 868:	fe0916e3          	bnez	s2,854 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 86c:	8bea                	mv	s7,s10
      state = 0;
 86e:	4981                	li	s3,0
 870:	6d02                	ld	s10,0(sp)
 872:	bd21                	j	68a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 874:	008b8993          	addi	s3,s7,8
 878:	000bb903          	ld	s2,0(s7)
 87c:	00090f63          	beqz	s2,89a <vprintf+0x25a>
        for(; *s; s++)
 880:	00094583          	lbu	a1,0(s2)
 884:	c195                	beqz	a1,8a8 <vprintf+0x268>
          putc(fd, *s);
 886:	855a                	mv	a0,s6
 888:	cf3ff0ef          	jal	57a <putc>
        for(; *s; s++)
 88c:	0905                	addi	s2,s2,1
 88e:	00094583          	lbu	a1,0(s2)
 892:	f9f5                	bnez	a1,886 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 894:	8bce                	mv	s7,s3
      state = 0;
 896:	4981                	li	s3,0
 898:	bbcd                	j	68a <vprintf+0x4a>
          s = "(null)";
 89a:	00000917          	auipc	s2,0x0
 89e:	2ae90913          	addi	s2,s2,686 # b48 <malloc+0x1a2>
        for(; *s; s++)
 8a2:	02800593          	li	a1,40
 8a6:	b7c5                	j	886 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 8a8:	8bce                	mv	s7,s3
      state = 0;
 8aa:	4981                	li	s3,0
 8ac:	bbf9                	j	68a <vprintf+0x4a>
 8ae:	64a6                	ld	s1,72(sp)
 8b0:	79e2                	ld	s3,56(sp)
 8b2:	7a42                	ld	s4,48(sp)
 8b4:	7aa2                	ld	s5,40(sp)
 8b6:	7b02                	ld	s6,32(sp)
 8b8:	6be2                	ld	s7,24(sp)
 8ba:	6c42                	ld	s8,16(sp)
 8bc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8be:	60e6                	ld	ra,88(sp)
 8c0:	6446                	ld	s0,80(sp)
 8c2:	6906                	ld	s2,64(sp)
 8c4:	6125                	addi	sp,sp,96
 8c6:	8082                	ret

00000000000008c8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8c8:	715d                	addi	sp,sp,-80
 8ca:	ec06                	sd	ra,24(sp)
 8cc:	e822                	sd	s0,16(sp)
 8ce:	1000                	addi	s0,sp,32
 8d0:	e010                	sd	a2,0(s0)
 8d2:	e414                	sd	a3,8(s0)
 8d4:	e818                	sd	a4,16(s0)
 8d6:	ec1c                	sd	a5,24(s0)
 8d8:	03043023          	sd	a6,32(s0)
 8dc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8e0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8e4:	8622                	mv	a2,s0
 8e6:	d5bff0ef          	jal	640 <vprintf>
}
 8ea:	60e2                	ld	ra,24(sp)
 8ec:	6442                	ld	s0,16(sp)
 8ee:	6161                	addi	sp,sp,80
 8f0:	8082                	ret

00000000000008f2 <printf>:

void
printf(const char *fmt, ...)
{
 8f2:	711d                	addi	sp,sp,-96
 8f4:	ec06                	sd	ra,24(sp)
 8f6:	e822                	sd	s0,16(sp)
 8f8:	1000                	addi	s0,sp,32
 8fa:	e40c                	sd	a1,8(s0)
 8fc:	e810                	sd	a2,16(s0)
 8fe:	ec14                	sd	a3,24(s0)
 900:	f018                	sd	a4,32(s0)
 902:	f41c                	sd	a5,40(s0)
 904:	03043823          	sd	a6,48(s0)
 908:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 90c:	00840613          	addi	a2,s0,8
 910:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 914:	85aa                	mv	a1,a0
 916:	4505                	li	a0,1
 918:	d29ff0ef          	jal	640 <vprintf>
}
 91c:	60e2                	ld	ra,24(sp)
 91e:	6442                	ld	s0,16(sp)
 920:	6125                	addi	sp,sp,96
 922:	8082                	ret

0000000000000924 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 924:	1141                	addi	sp,sp,-16
 926:	e422                	sd	s0,8(sp)
 928:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 92a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 92e:	00000797          	auipc	a5,0x0
 932:	6ea7b783          	ld	a5,1770(a5) # 1018 <freep>
 936:	a02d                	j	960 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 938:	4618                	lw	a4,8(a2)
 93a:	9f2d                	addw	a4,a4,a1
 93c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 940:	6398                	ld	a4,0(a5)
 942:	6310                	ld	a2,0(a4)
 944:	a83d                	j	982 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 946:	ff852703          	lw	a4,-8(a0)
 94a:	9f31                	addw	a4,a4,a2
 94c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 94e:	ff053683          	ld	a3,-16(a0)
 952:	a091                	j	996 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 954:	6398                	ld	a4,0(a5)
 956:	00e7e463          	bltu	a5,a4,95e <free+0x3a>
 95a:	00e6ea63          	bltu	a3,a4,96e <free+0x4a>
{
 95e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 960:	fed7fae3          	bgeu	a5,a3,954 <free+0x30>
 964:	6398                	ld	a4,0(a5)
 966:	00e6e463          	bltu	a3,a4,96e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 96a:	fee7eae3          	bltu	a5,a4,95e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 96e:	ff852583          	lw	a1,-8(a0)
 972:	6390                	ld	a2,0(a5)
 974:	02059813          	slli	a6,a1,0x20
 978:	01c85713          	srli	a4,a6,0x1c
 97c:	9736                	add	a4,a4,a3
 97e:	fae60de3          	beq	a2,a4,938 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 982:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 986:	4790                	lw	a2,8(a5)
 988:	02061593          	slli	a1,a2,0x20
 98c:	01c5d713          	srli	a4,a1,0x1c
 990:	973e                	add	a4,a4,a5
 992:	fae68ae3          	beq	a3,a4,946 <free+0x22>
    p->s.ptr = bp->s.ptr;
 996:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 998:	00000717          	auipc	a4,0x0
 99c:	68f73023          	sd	a5,1664(a4) # 1018 <freep>
}
 9a0:	6422                	ld	s0,8(sp)
 9a2:	0141                	addi	sp,sp,16
 9a4:	8082                	ret

00000000000009a6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9a6:	7139                	addi	sp,sp,-64
 9a8:	fc06                	sd	ra,56(sp)
 9aa:	f822                	sd	s0,48(sp)
 9ac:	f426                	sd	s1,40(sp)
 9ae:	ec4e                	sd	s3,24(sp)
 9b0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9b2:	02051493          	slli	s1,a0,0x20
 9b6:	9081                	srli	s1,s1,0x20
 9b8:	04bd                	addi	s1,s1,15
 9ba:	8091                	srli	s1,s1,0x4
 9bc:	0014899b          	addiw	s3,s1,1
 9c0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9c2:	00000517          	auipc	a0,0x0
 9c6:	65653503          	ld	a0,1622(a0) # 1018 <freep>
 9ca:	c915                	beqz	a0,9fe <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9cc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ce:	4798                	lw	a4,8(a5)
 9d0:	08977a63          	bgeu	a4,s1,a64 <malloc+0xbe>
 9d4:	f04a                	sd	s2,32(sp)
 9d6:	e852                	sd	s4,16(sp)
 9d8:	e456                	sd	s5,8(sp)
 9da:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9dc:	8a4e                	mv	s4,s3
 9de:	0009871b          	sext.w	a4,s3
 9e2:	6685                	lui	a3,0x1
 9e4:	00d77363          	bgeu	a4,a3,9ea <malloc+0x44>
 9e8:	6a05                	lui	s4,0x1
 9ea:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9ee:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9f2:	00000917          	auipc	s2,0x0
 9f6:	62690913          	addi	s2,s2,1574 # 1018 <freep>
  if(p == (char*)-1)
 9fa:	5afd                	li	s5,-1
 9fc:	a081                	j	a3c <malloc+0x96>
 9fe:	f04a                	sd	s2,32(sp)
 a00:	e852                	sd	s4,16(sp)
 a02:	e456                	sd	s5,8(sp)
 a04:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a06:	00000797          	auipc	a5,0x0
 a0a:	65a78793          	addi	a5,a5,1626 # 1060 <base>
 a0e:	00000717          	auipc	a4,0x0
 a12:	60f73523          	sd	a5,1546(a4) # 1018 <freep>
 a16:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a18:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a1c:	b7c1                	j	9dc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a1e:	6398                	ld	a4,0(a5)
 a20:	e118                	sd	a4,0(a0)
 a22:	a8a9                	j	a7c <malloc+0xd6>
  hp->s.size = nu;
 a24:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a28:	0541                	addi	a0,a0,16
 a2a:	efbff0ef          	jal	924 <free>
  return freep;
 a2e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a32:	c12d                	beqz	a0,a94 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a34:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a36:	4798                	lw	a4,8(a5)
 a38:	02977263          	bgeu	a4,s1,a5c <malloc+0xb6>
    if(p == freep)
 a3c:	00093703          	ld	a4,0(s2)
 a40:	853e                	mv	a0,a5
 a42:	fef719e3          	bne	a4,a5,a34 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a46:	8552                	mv	a0,s4
 a48:	b0bff0ef          	jal	552 <sbrk>
  if(p == (char*)-1)
 a4c:	fd551ce3          	bne	a0,s5,a24 <malloc+0x7e>
        return 0;
 a50:	4501                	li	a0,0
 a52:	7902                	ld	s2,32(sp)
 a54:	6a42                	ld	s4,16(sp)
 a56:	6aa2                	ld	s5,8(sp)
 a58:	6b02                	ld	s6,0(sp)
 a5a:	a03d                	j	a88 <malloc+0xe2>
 a5c:	7902                	ld	s2,32(sp)
 a5e:	6a42                	ld	s4,16(sp)
 a60:	6aa2                	ld	s5,8(sp)
 a62:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a64:	fae48de3          	beq	s1,a4,a1e <malloc+0x78>
        p->s.size -= nunits;
 a68:	4137073b          	subw	a4,a4,s3
 a6c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a6e:	02071693          	slli	a3,a4,0x20
 a72:	01c6d713          	srli	a4,a3,0x1c
 a76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a7c:	00000717          	auipc	a4,0x0
 a80:	58a73e23          	sd	a0,1436(a4) # 1018 <freep>
      return (void*)(p + 1);
 a84:	01078513          	addi	a0,a5,16
  }
}
 a88:	70e2                	ld	ra,56(sp)
 a8a:	7442                	ld	s0,48(sp)
 a8c:	74a2                	ld	s1,40(sp)
 a8e:	69e2                	ld	s3,24(sp)
 a90:	6121                	addi	sp,sp,64
 a92:	8082                	ret
 a94:	7902                	ld	s2,32(sp)
 a96:	6a42                	ld	s4,16(sp)
 a98:	6aa2                	ld	s5,8(sp)
 a9a:	6b02                	ld	s6,0(sp)
 a9c:	b7f5                	j	a88 <malloc+0xe2>
