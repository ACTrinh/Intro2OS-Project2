
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  // 2. child -> parent
  int p2c[2]; // Pipe for parent to child
  int c2p[2]; // Pipe for child to parent

  // Create both pipes. pipe() returns -1 on error.
  if (pipe(p2c) < 0 || pipe(c2p) < 0) {
   8:	fe840513          	addi	a0,s0,-24
   c:	3de000ef          	jal	3ea <pipe>
  10:	00054863          	bltz	a0,20 <main+0x20>
  14:	fe040513          	addi	a0,s0,-32
  18:	3d2000ef          	jal	3ea <pipe>
  1c:	00055c63          	bgez	a0,34 <main+0x34>
    fprintf(2, "pingpong: pipe creation failed\n");
  20:	00001597          	auipc	a1,0x1
  24:	99058593          	addi	a1,a1,-1648 # 9b0 <malloc+0xfa>
  28:	4509                	li	a0,2
  2a:	7ae000ef          	jal	7d8 <fprintf>
    exit(1);
  2e:	4505                	li	a0,1
  30:	3aa000ef          	jal	3da <exit>

  // A buffer to hold the single byte for ping-pong
  char buf[1];

  // Fork to create the child process
  int pid = fork();
  34:	39e000ef          	jal	3d2 <fork>

  if (pid < 0) {
  38:	02054f63          	bltz	a0,76 <main+0x76>
    fprintf(2, "pingpong: fork failed\n");
    exit(1);
  }

  if (pid == 0) {
  3c:	ed59                	bnez	a0,da <main+0xda>
    // --- CHILD PROCESS ---

    // The child doesn't need to write to the p2c pipe or read from the c2p pipe.
    // It's good practice to close unused file descriptors.
    close(p2c[1]); // Close write end of parent->child pipe
  3e:	fec42503          	lw	a0,-20(s0)
  42:	3c0000ef          	jal	402 <close>
    close(c2p[0]); // Close read end of child->parent pipe
  46:	fe042503          	lw	a0,-32(s0)
  4a:	3b8000ef          	jal	402 <close>

    // Read the "ping" byte from the parent.
    // read() returns the number of bytes read. We expect 1.
    if (read(p2c[0], buf, 1) != 1) {
  4e:	4605                	li	a2,1
  50:	fd840593          	addi	a1,s0,-40
  54:	fe842503          	lw	a0,-24(s0)
  58:	39a000ef          	jal	3f2 <read>
  5c:	4785                	li	a5,1
  5e:	02f50663          	beq	a0,a5,8a <main+0x8a>
      fprintf(2, "pingpong: child failed to read from parent\n");
  62:	00001597          	auipc	a1,0x1
  66:	98e58593          	addi	a1,a1,-1650 # 9f0 <malloc+0x13a>
  6a:	4509                	li	a0,2
  6c:	76c000ef          	jal	7d8 <fprintf>
      exit(1);
  70:	4505                	li	a0,1
  72:	368000ef          	jal	3da <exit>
    fprintf(2, "pingpong: fork failed\n");
  76:	00001597          	auipc	a1,0x1
  7a:	95a58593          	addi	a1,a1,-1702 # 9d0 <malloc+0x11a>
  7e:	4509                	li	a0,2
  80:	758000ef          	jal	7d8 <fprintf>
    exit(1);
  84:	4505                	li	a0,1
  86:	354000ef          	jal	3da <exit>
    }
    
    // Print the required message.
    printf("%d: received ping\n", getpid());
  8a:	3d0000ef          	jal	45a <getpid>
  8e:	85aa                	mv	a1,a0
  90:	00001517          	auipc	a0,0x1
  94:	99050513          	addi	a0,a0,-1648 # a20 <malloc+0x16a>
  98:	76a000ef          	jal	802 <printf>

    // Write the byte back to the parent as a "pong".
    if (write(c2p[1], buf, 1) != 1) {
  9c:	4605                	li	a2,1
  9e:	fd840593          	addi	a1,s0,-40
  a2:	fe442503          	lw	a0,-28(s0)
  a6:	354000ef          	jal	3fa <write>
  aa:	4785                	li	a5,1
  ac:	00f50c63          	beq	a0,a5,c4 <main+0xc4>
      fprintf(2, "pingpong: child failed to write to parent\n");
  b0:	00001597          	auipc	a1,0x1
  b4:	98858593          	addi	a1,a1,-1656 # a38 <malloc+0x182>
  b8:	4509                	li	a0,2
  ba:	71e000ef          	jal	7d8 <fprintf>
      exit(1);
  be:	4505                	li	a0,1
  c0:	31a000ef          	jal	3da <exit>
    }

    // Close remaining pipe ends before exiting.
    close(p2c[0]);
  c4:	fe842503          	lw	a0,-24(s0)
  c8:	33a000ef          	jal	402 <close>
    close(c2p[1]);
  cc:	fe442503          	lw	a0,-28(s0)
  d0:	332000ef          	jal	402 <close>
    
    exit(0);
  d4:	4501                	li	a0,0
  d6:	304000ef          	jal	3da <exit>

  } else {
    // --- PARENT PROCESS ---

    // The parent doesn't need to read from the p2c pipe or write to the c2p pipe.
    close(p2c[0]); // Close read end of parent->child pipe
  da:	fe842503          	lw	a0,-24(s0)
  de:	324000ef          	jal	402 <close>
    close(c2p[1]); // Close write end of child->parent pipe
  e2:	fe442503          	lw	a0,-28(s0)
  e6:	31c000ef          	jal	402 <close>

    // Write the "ping" byte to the child.
    buf[0] = 'B'; // Any byte will do.
  ea:	04200793          	li	a5,66
  ee:	fcf40c23          	sb	a5,-40(s0)
    if (write(p2c[1], buf, 1) != 1) {
  f2:	4605                	li	a2,1
  f4:	fd840593          	addi	a1,s0,-40
  f8:	fec42503          	lw	a0,-20(s0)
  fc:	2fe000ef          	jal	3fa <write>
 100:	4785                	li	a5,1
 102:	00f50c63          	beq	a0,a5,11a <main+0x11a>
      fprintf(2, "pingpong: parent failed to write to child\n");
 106:	00001597          	auipc	a1,0x1
 10a:	96258593          	addi	a1,a1,-1694 # a68 <malloc+0x1b2>
 10e:	4509                	li	a0,2
 110:	6c8000ef          	jal	7d8 <fprintf>
      exit(1);
 114:	4505                	li	a0,1
 116:	2c4000ef          	jal	3da <exit>
    }

    // Wait and read the "pong" byte from the child.
    if (read(c2p[0], buf, 1) != 1) {
 11a:	4605                	li	a2,1
 11c:	fd840593          	addi	a1,s0,-40
 120:	fe042503          	lw	a0,-32(s0)
 124:	2ce000ef          	jal	3f2 <read>
 128:	4785                	li	a5,1
 12a:	00f50c63          	beq	a0,a5,142 <main+0x142>
      fprintf(2, "pingpong: parent failed to read from child\n");
 12e:	00001597          	auipc	a1,0x1
 132:	96a58593          	addi	a1,a1,-1686 # a98 <malloc+0x1e2>
 136:	4509                	li	a0,2
 138:	6a0000ef          	jal	7d8 <fprintf>
      exit(1);
 13c:	4505                	li	a0,1
 13e:	29c000ef          	jal	3da <exit>
    }

    // Print the required message.
    printf("%d: received pong\n", getpid());
 142:	318000ef          	jal	45a <getpid>
 146:	85aa                	mv	a1,a0
 148:	00001517          	auipc	a0,0x1
 14c:	98050513          	addi	a0,a0,-1664 # ac8 <malloc+0x212>
 150:	6b2000ef          	jal	802 <printf>

    // Close remaining pipe ends before exiting.
    close(p2c[1]);
 154:	fec42503          	lw	a0,-20(s0)
 158:	2aa000ef          	jal	402 <close>
    close(c2p[0]);
 15c:	fe042503          	lw	a0,-32(s0)
 160:	2a2000ef          	jal	402 <close>

    // Optional: wait for child to fully exit to prevent a zombie process,
    // though in this simple case it's not strictly necessary as parent exits immediately.
    wait(0);
 164:	4501                	li	a0,0
 166:	27c000ef          	jal	3e2 <wait>
    
    exit(0);
 16a:	4501                	li	a0,0
 16c:	26e000ef          	jal	3da <exit>

0000000000000170 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 170:	1141                	addi	sp,sp,-16
 172:	e406                	sd	ra,8(sp)
 174:	e022                	sd	s0,0(sp)
 176:	0800                	addi	s0,sp,16
  extern int main();
  main();
 178:	e89ff0ef          	jal	0 <main>
  exit(0);
 17c:	4501                	li	a0,0
 17e:	25c000ef          	jal	3da <exit>

0000000000000182 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 188:	87aa                	mv	a5,a0
 18a:	0585                	addi	a1,a1,1
 18c:	0785                	addi	a5,a5,1
 18e:	fff5c703          	lbu	a4,-1(a1)
 192:	fee78fa3          	sb	a4,-1(a5)
 196:	fb75                	bnez	a4,18a <strcpy+0x8>
    ;
  return os;
}
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cb91                	beqz	a5,1bc <strcmp+0x1e>
 1aa:	0005c703          	lbu	a4,0(a1)
 1ae:	00f71763          	bne	a4,a5,1bc <strcmp+0x1e>
    p++, q++;
 1b2:	0505                	addi	a0,a0,1
 1b4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	fbe5                	bnez	a5,1aa <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1bc:	0005c503          	lbu	a0,0(a1)
}
 1c0:	40a7853b          	subw	a0,a5,a0
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strlen>:

uint
strlen(const char *s)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cf91                	beqz	a5,1f0 <strlen+0x26>
 1d6:	0505                	addi	a0,a0,1
 1d8:	87aa                	mv	a5,a0
 1da:	86be                	mv	a3,a5
 1dc:	0785                	addi	a5,a5,1
 1de:	fff7c703          	lbu	a4,-1(a5)
 1e2:	ff65                	bnez	a4,1da <strlen+0x10>
 1e4:	40a6853b          	subw	a0,a3,a0
 1e8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 1ea:	6422                	ld	s0,8(sp)
 1ec:	0141                	addi	sp,sp,16
 1ee:	8082                	ret
  for(n = 0; s[n]; n++)
 1f0:	4501                	li	a0,0
 1f2:	bfe5                	j	1ea <strlen+0x20>

00000000000001f4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1f4:	1141                	addi	sp,sp,-16
 1f6:	e422                	sd	s0,8(sp)
 1f8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1fa:	ca19                	beqz	a2,210 <memset+0x1c>
 1fc:	87aa                	mv	a5,a0
 1fe:	1602                	slli	a2,a2,0x20
 200:	9201                	srli	a2,a2,0x20
 202:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 206:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 20a:	0785                	addi	a5,a5,1
 20c:	fee79de3          	bne	a5,a4,206 <memset+0x12>
  }
  return dst;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strchr>:

char*
strchr(const char *s, char c)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cb99                	beqz	a5,236 <strchr+0x20>
    if(*s == c)
 222:	00f58763          	beq	a1,a5,230 <strchr+0x1a>
  for(; *s; s++)
 226:	0505                	addi	a0,a0,1
 228:	00054783          	lbu	a5,0(a0)
 22c:	fbfd                	bnez	a5,222 <strchr+0xc>
      return (char*)s;
  return 0;
 22e:	4501                	li	a0,0
}
 230:	6422                	ld	s0,8(sp)
 232:	0141                	addi	sp,sp,16
 234:	8082                	ret
  return 0;
 236:	4501                	li	a0,0
 238:	bfe5                	j	230 <strchr+0x1a>

000000000000023a <gets>:

char*
gets(char *buf, int max)
{
 23a:	711d                	addi	sp,sp,-96
 23c:	ec86                	sd	ra,88(sp)
 23e:	e8a2                	sd	s0,80(sp)
 240:	e4a6                	sd	s1,72(sp)
 242:	e0ca                	sd	s2,64(sp)
 244:	fc4e                	sd	s3,56(sp)
 246:	f852                	sd	s4,48(sp)
 248:	f456                	sd	s5,40(sp)
 24a:	f05a                	sd	s6,32(sp)
 24c:	ec5e                	sd	s7,24(sp)
 24e:	1080                	addi	s0,sp,96
 250:	8baa                	mv	s7,a0
 252:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 254:	892a                	mv	s2,a0
 256:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 258:	4aa9                	li	s5,10
 25a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 25c:	89a6                	mv	s3,s1
 25e:	2485                	addiw	s1,s1,1
 260:	0344d663          	bge	s1,s4,28c <gets+0x52>
    cc = read(0, &c, 1);
 264:	4605                	li	a2,1
 266:	faf40593          	addi	a1,s0,-81
 26a:	4501                	li	a0,0
 26c:	186000ef          	jal	3f2 <read>
    if(cc < 1)
 270:	00a05e63          	blez	a0,28c <gets+0x52>
    buf[i++] = c;
 274:	faf44783          	lbu	a5,-81(s0)
 278:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 27c:	01578763          	beq	a5,s5,28a <gets+0x50>
 280:	0905                	addi	s2,s2,1
 282:	fd679de3          	bne	a5,s6,25c <gets+0x22>
    buf[i++] = c;
 286:	89a6                	mv	s3,s1
 288:	a011                	j	28c <gets+0x52>
 28a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 28c:	99de                	add	s3,s3,s7
 28e:	00098023          	sb	zero,0(s3)
  return buf;
}
 292:	855e                	mv	a0,s7
 294:	60e6                	ld	ra,88(sp)
 296:	6446                	ld	s0,80(sp)
 298:	64a6                	ld	s1,72(sp)
 29a:	6906                	ld	s2,64(sp)
 29c:	79e2                	ld	s3,56(sp)
 29e:	7a42                	ld	s4,48(sp)
 2a0:	7aa2                	ld	s5,40(sp)
 2a2:	7b02                	ld	s6,32(sp)
 2a4:	6be2                	ld	s7,24(sp)
 2a6:	6125                	addi	sp,sp,96
 2a8:	8082                	ret

00000000000002aa <stat>:

int
stat(const char *n, struct stat *st)
{
 2aa:	1101                	addi	sp,sp,-32
 2ac:	ec06                	sd	ra,24(sp)
 2ae:	e822                	sd	s0,16(sp)
 2b0:	e04a                	sd	s2,0(sp)
 2b2:	1000                	addi	s0,sp,32
 2b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2b6:	4581                	li	a1,0
 2b8:	162000ef          	jal	41a <open>
  if(fd < 0)
 2bc:	02054263          	bltz	a0,2e0 <stat+0x36>
 2c0:	e426                	sd	s1,8(sp)
 2c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2c4:	85ca                	mv	a1,s2
 2c6:	16c000ef          	jal	432 <fstat>
 2ca:	892a                	mv	s2,a0
  close(fd);
 2cc:	8526                	mv	a0,s1
 2ce:	134000ef          	jal	402 <close>
  return r;
 2d2:	64a2                	ld	s1,8(sp)
}
 2d4:	854a                	mv	a0,s2
 2d6:	60e2                	ld	ra,24(sp)
 2d8:	6442                	ld	s0,16(sp)
 2da:	6902                	ld	s2,0(sp)
 2dc:	6105                	addi	sp,sp,32
 2de:	8082                	ret
    return -1;
 2e0:	597d                	li	s2,-1
 2e2:	bfcd                	j	2d4 <stat+0x2a>

00000000000002e4 <atoi>:

int
atoi(const char *s)
{
 2e4:	1141                	addi	sp,sp,-16
 2e6:	e422                	sd	s0,8(sp)
 2e8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ea:	00054683          	lbu	a3,0(a0)
 2ee:	fd06879b          	addiw	a5,a3,-48
 2f2:	0ff7f793          	zext.b	a5,a5
 2f6:	4625                	li	a2,9
 2f8:	02f66863          	bltu	a2,a5,328 <atoi+0x44>
 2fc:	872a                	mv	a4,a0
  n = 0;
 2fe:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 300:	0705                	addi	a4,a4,1
 302:	0025179b          	slliw	a5,a0,0x2
 306:	9fa9                	addw	a5,a5,a0
 308:	0017979b          	slliw	a5,a5,0x1
 30c:	9fb5                	addw	a5,a5,a3
 30e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 312:	00074683          	lbu	a3,0(a4)
 316:	fd06879b          	addiw	a5,a3,-48
 31a:	0ff7f793          	zext.b	a5,a5
 31e:	fef671e3          	bgeu	a2,a5,300 <atoi+0x1c>
  return n;
}
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret
  n = 0;
 328:	4501                	li	a0,0
 32a:	bfe5                	j	322 <atoi+0x3e>

000000000000032c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e422                	sd	s0,8(sp)
 330:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 332:	02b57463          	bgeu	a0,a1,35a <memmove+0x2e>
    while(n-- > 0)
 336:	00c05f63          	blez	a2,354 <memmove+0x28>
 33a:	1602                	slli	a2,a2,0x20
 33c:	9201                	srli	a2,a2,0x20
 33e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 342:	872a                	mv	a4,a0
      *dst++ = *src++;
 344:	0585                	addi	a1,a1,1
 346:	0705                	addi	a4,a4,1
 348:	fff5c683          	lbu	a3,-1(a1)
 34c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 350:	fef71ae3          	bne	a4,a5,344 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 354:	6422                	ld	s0,8(sp)
 356:	0141                	addi	sp,sp,16
 358:	8082                	ret
    dst += n;
 35a:	00c50733          	add	a4,a0,a2
    src += n;
 35e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 360:	fec05ae3          	blez	a2,354 <memmove+0x28>
 364:	fff6079b          	addiw	a5,a2,-1
 368:	1782                	slli	a5,a5,0x20
 36a:	9381                	srli	a5,a5,0x20
 36c:	fff7c793          	not	a5,a5
 370:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 372:	15fd                	addi	a1,a1,-1
 374:	177d                	addi	a4,a4,-1
 376:	0005c683          	lbu	a3,0(a1)
 37a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 37e:	fee79ae3          	bne	a5,a4,372 <memmove+0x46>
 382:	bfc9                	j	354 <memmove+0x28>

0000000000000384 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e422                	sd	s0,8(sp)
 388:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 38a:	ca05                	beqz	a2,3ba <memcmp+0x36>
 38c:	fff6069b          	addiw	a3,a2,-1
 390:	1682                	slli	a3,a3,0x20
 392:	9281                	srli	a3,a3,0x20
 394:	0685                	addi	a3,a3,1
 396:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 398:	00054783          	lbu	a5,0(a0)
 39c:	0005c703          	lbu	a4,0(a1)
 3a0:	00e79863          	bne	a5,a4,3b0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3a4:	0505                	addi	a0,a0,1
    p2++;
 3a6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3a8:	fed518e3          	bne	a0,a3,398 <memcmp+0x14>
  }
  return 0;
 3ac:	4501                	li	a0,0
 3ae:	a019                	j	3b4 <memcmp+0x30>
      return *p1 - *p2;
 3b0:	40e7853b          	subw	a0,a5,a4
}
 3b4:	6422                	ld	s0,8(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret
  return 0;
 3ba:	4501                	li	a0,0
 3bc:	bfe5                	j	3b4 <memcmp+0x30>

00000000000003be <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e406                	sd	ra,8(sp)
 3c2:	e022                	sd	s0,0(sp)
 3c4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3c6:	f67ff0ef          	jal	32c <memmove>
}
 3ca:	60a2                	ld	ra,8(sp)
 3cc:	6402                	ld	s0,0(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret

00000000000003d2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d2:	4885                	li	a7,1
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <exit>:
.global exit
exit:
 li a7, SYS_exit
 3da:	4889                	li	a7,2
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e2:	488d                	li	a7,3
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ea:	4891                	li	a7,4
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <read>:
.global read
read:
 li a7, SYS_read
 3f2:	4895                	li	a7,5
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <write>:
.global write
write:
 li a7, SYS_write
 3fa:	48c1                	li	a7,16
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <close>:
.global close
close:
 li a7, SYS_close
 402:	48d5                	li	a7,21
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <kill>:
.global kill
kill:
 li a7, SYS_kill
 40a:	4899                	li	a7,6
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exec>:
.global exec
exec:
 li a7, SYS_exec
 412:	489d                	li	a7,7
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <open>:
.global open
open:
 li a7, SYS_open
 41a:	48bd                	li	a7,15
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 422:	48c5                	li	a7,17
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42a:	48c9                	li	a7,18
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 432:	48a1                	li	a7,8
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <link>:
.global link
link:
 li a7, SYS_link
 43a:	48cd                	li	a7,19
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 442:	48d1                	li	a7,20
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44a:	48a5                	li	a7,9
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <dup>:
.global dup
dup:
 li a7, SYS_dup
 452:	48a9                	li	a7,10
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45a:	48ad                	li	a7,11
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 462:	48b1                	li	a7,12
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 46a:	48b5                	li	a7,13
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 472:	48b9                	li	a7,14
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <trace>:
.global trace
trace:
 li a7, SYS_trace
 47a:	48d9                	li	a7,22
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 482:	48dd                	li	a7,23
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 48a:	1101                	addi	sp,sp,-32
 48c:	ec06                	sd	ra,24(sp)
 48e:	e822                	sd	s0,16(sp)
 490:	1000                	addi	s0,sp,32
 492:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 496:	4605                	li	a2,1
 498:	fef40593          	addi	a1,s0,-17
 49c:	f5fff0ef          	jal	3fa <write>
}
 4a0:	60e2                	ld	ra,24(sp)
 4a2:	6442                	ld	s0,16(sp)
 4a4:	6105                	addi	sp,sp,32
 4a6:	8082                	ret

00000000000004a8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a8:	7139                	addi	sp,sp,-64
 4aa:	fc06                	sd	ra,56(sp)
 4ac:	f822                	sd	s0,48(sp)
 4ae:	f426                	sd	s1,40(sp)
 4b0:	0080                	addi	s0,sp,64
 4b2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b4:	c299                	beqz	a3,4ba <printint+0x12>
 4b6:	0805c963          	bltz	a1,548 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4ba:	2581                	sext.w	a1,a1
  neg = 0;
 4bc:	4881                	li	a7,0
 4be:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c4:	2601                	sext.w	a2,a2
 4c6:	00000517          	auipc	a0,0x0
 4ca:	62250513          	addi	a0,a0,1570 # ae8 <digits>
 4ce:	883a                	mv	a6,a4
 4d0:	2705                	addiw	a4,a4,1
 4d2:	02c5f7bb          	remuw	a5,a1,a2
 4d6:	1782                	slli	a5,a5,0x20
 4d8:	9381                	srli	a5,a5,0x20
 4da:	97aa                	add	a5,a5,a0
 4dc:	0007c783          	lbu	a5,0(a5)
 4e0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e4:	0005879b          	sext.w	a5,a1
 4e8:	02c5d5bb          	divuw	a1,a1,a2
 4ec:	0685                	addi	a3,a3,1
 4ee:	fec7f0e3          	bgeu	a5,a2,4ce <printint+0x26>
  if(neg)
 4f2:	00088c63          	beqz	a7,50a <printint+0x62>
    buf[i++] = '-';
 4f6:	fd070793          	addi	a5,a4,-48
 4fa:	00878733          	add	a4,a5,s0
 4fe:	02d00793          	li	a5,45
 502:	fef70823          	sb	a5,-16(a4)
 506:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 50a:	02e05a63          	blez	a4,53e <printint+0x96>
 50e:	f04a                	sd	s2,32(sp)
 510:	ec4e                	sd	s3,24(sp)
 512:	fc040793          	addi	a5,s0,-64
 516:	00e78933          	add	s2,a5,a4
 51a:	fff78993          	addi	s3,a5,-1
 51e:	99ba                	add	s3,s3,a4
 520:	377d                	addiw	a4,a4,-1
 522:	1702                	slli	a4,a4,0x20
 524:	9301                	srli	a4,a4,0x20
 526:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 52a:	fff94583          	lbu	a1,-1(s2)
 52e:	8526                	mv	a0,s1
 530:	f5bff0ef          	jal	48a <putc>
  while(--i >= 0)
 534:	197d                	addi	s2,s2,-1
 536:	ff391ae3          	bne	s2,s3,52a <printint+0x82>
 53a:	7902                	ld	s2,32(sp)
 53c:	69e2                	ld	s3,24(sp)
}
 53e:	70e2                	ld	ra,56(sp)
 540:	7442                	ld	s0,48(sp)
 542:	74a2                	ld	s1,40(sp)
 544:	6121                	addi	sp,sp,64
 546:	8082                	ret
    x = -xx;
 548:	40b005bb          	negw	a1,a1
    neg = 1;
 54c:	4885                	li	a7,1
    x = -xx;
 54e:	bf85                	j	4be <printint+0x16>

0000000000000550 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 550:	711d                	addi	sp,sp,-96
 552:	ec86                	sd	ra,88(sp)
 554:	e8a2                	sd	s0,80(sp)
 556:	e0ca                	sd	s2,64(sp)
 558:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 55a:	0005c903          	lbu	s2,0(a1)
 55e:	26090863          	beqz	s2,7ce <vprintf+0x27e>
 562:	e4a6                	sd	s1,72(sp)
 564:	fc4e                	sd	s3,56(sp)
 566:	f852                	sd	s4,48(sp)
 568:	f456                	sd	s5,40(sp)
 56a:	f05a                	sd	s6,32(sp)
 56c:	ec5e                	sd	s7,24(sp)
 56e:	e862                	sd	s8,16(sp)
 570:	e466                	sd	s9,8(sp)
 572:	8b2a                	mv	s6,a0
 574:	8a2e                	mv	s4,a1
 576:	8bb2                	mv	s7,a2
  state = 0;
 578:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 57a:	4481                	li	s1,0
 57c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 57e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 582:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 586:	06c00c93          	li	s9,108
 58a:	a005                	j	5aa <vprintf+0x5a>
        putc(fd, c0);
 58c:	85ca                	mv	a1,s2
 58e:	855a                	mv	a0,s6
 590:	efbff0ef          	jal	48a <putc>
 594:	a019                	j	59a <vprintf+0x4a>
    } else if(state == '%'){
 596:	03598263          	beq	s3,s5,5ba <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 59a:	2485                	addiw	s1,s1,1
 59c:	8726                	mv	a4,s1
 59e:	009a07b3          	add	a5,s4,s1
 5a2:	0007c903          	lbu	s2,0(a5)
 5a6:	20090c63          	beqz	s2,7be <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 5aa:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5ae:	fe0994e3          	bnez	s3,596 <vprintf+0x46>
      if(c0 == '%'){
 5b2:	fd579de3          	bne	a5,s5,58c <vprintf+0x3c>
        state = '%';
 5b6:	89be                	mv	s3,a5
 5b8:	b7cd                	j	59a <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5ba:	00ea06b3          	add	a3,s4,a4
 5be:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5c2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5c4:	c681                	beqz	a3,5cc <vprintf+0x7c>
 5c6:	9752                	add	a4,a4,s4
 5c8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5cc:	03878f63          	beq	a5,s8,60a <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 5d0:	05978963          	beq	a5,s9,622 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5d4:	07500713          	li	a4,117
 5d8:	0ee78363          	beq	a5,a4,6be <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5dc:	07800713          	li	a4,120
 5e0:	12e78563          	beq	a5,a4,70a <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5e4:	07000713          	li	a4,112
 5e8:	14e78a63          	beq	a5,a4,73c <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 5ec:	07300713          	li	a4,115
 5f0:	18e78a63          	beq	a5,a4,784 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5f4:	02500713          	li	a4,37
 5f8:	04e79563          	bne	a5,a4,642 <vprintf+0xf2>
        putc(fd, '%');
 5fc:	02500593          	li	a1,37
 600:	855a                	mv	a0,s6
 602:	e89ff0ef          	jal	48a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 606:	4981                	li	s3,0
 608:	bf49                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 60a:	008b8913          	addi	s2,s7,8
 60e:	4685                	li	a3,1
 610:	4629                	li	a2,10
 612:	000ba583          	lw	a1,0(s7)
 616:	855a                	mv	a0,s6
 618:	e91ff0ef          	jal	4a8 <printint>
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	bfad                	j	59a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 622:	06400793          	li	a5,100
 626:	02f68963          	beq	a3,a5,658 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 62a:	06c00793          	li	a5,108
 62e:	04f68263          	beq	a3,a5,672 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 632:	07500793          	li	a5,117
 636:	0af68063          	beq	a3,a5,6d6 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 63a:	07800793          	li	a5,120
 63e:	0ef68263          	beq	a3,a5,722 <vprintf+0x1d2>
        putc(fd, '%');
 642:	02500593          	li	a1,37
 646:	855a                	mv	a0,s6
 648:	e43ff0ef          	jal	48a <putc>
        putc(fd, c0);
 64c:	85ca                	mv	a1,s2
 64e:	855a                	mv	a0,s6
 650:	e3bff0ef          	jal	48a <putc>
      state = 0;
 654:	4981                	li	s3,0
 656:	b791                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 658:	008b8913          	addi	s2,s7,8
 65c:	4685                	li	a3,1
 65e:	4629                	li	a2,10
 660:	000ba583          	lw	a1,0(s7)
 664:	855a                	mv	a0,s6
 666:	e43ff0ef          	jal	4a8 <printint>
        i += 1;
 66a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 66c:	8bca                	mv	s7,s2
      state = 0;
 66e:	4981                	li	s3,0
        i += 1;
 670:	b72d                	j	59a <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 672:	06400793          	li	a5,100
 676:	02f60763          	beq	a2,a5,6a4 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 67a:	07500793          	li	a5,117
 67e:	06f60963          	beq	a2,a5,6f0 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 682:	07800793          	li	a5,120
 686:	faf61ee3          	bne	a2,a5,642 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4681                	li	a3,0
 690:	4641                	li	a2,16
 692:	000ba583          	lw	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	e11ff0ef          	jal	4a8 <printint>
        i += 2;
 69c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
        i += 2;
 6a2:	bde5                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4685                	li	a3,1
 6aa:	4629                	li	a2,10
 6ac:	000ba583          	lw	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	df7ff0ef          	jal	4a8 <printint>
        i += 2;
 6b6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b8:	8bca                	mv	s7,s2
      state = 0;
 6ba:	4981                	li	s3,0
        i += 2;
 6bc:	bdf9                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 6be:	008b8913          	addi	s2,s7,8
 6c2:	4681                	li	a3,0
 6c4:	4629                	li	a2,10
 6c6:	000ba583          	lw	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	dddff0ef          	jal	4a8 <printint>
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	b5d9                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d6:	008b8913          	addi	s2,s7,8
 6da:	4681                	li	a3,0
 6dc:	4629                	li	a2,10
 6de:	000ba583          	lw	a1,0(s7)
 6e2:	855a                	mv	a0,s6
 6e4:	dc5ff0ef          	jal	4a8 <printint>
        i += 1;
 6e8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
        i += 1;
 6ee:	b575                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4629                	li	a2,10
 6f8:	000ba583          	lw	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	dabff0ef          	jal	4a8 <printint>
        i += 2;
 702:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 704:	8bca                	mv	s7,s2
      state = 0;
 706:	4981                	li	s3,0
        i += 2;
 708:	bd49                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 70a:	008b8913          	addi	s2,s7,8
 70e:	4681                	li	a3,0
 710:	4641                	li	a2,16
 712:	000ba583          	lw	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	d91ff0ef          	jal	4a8 <printint>
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
 720:	bdad                	j	59a <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 722:	008b8913          	addi	s2,s7,8
 726:	4681                	li	a3,0
 728:	4641                	li	a2,16
 72a:	000ba583          	lw	a1,0(s7)
 72e:	855a                	mv	a0,s6
 730:	d79ff0ef          	jal	4a8 <printint>
        i += 1;
 734:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 736:	8bca                	mv	s7,s2
      state = 0;
 738:	4981                	li	s3,0
        i += 1;
 73a:	b585                	j	59a <vprintf+0x4a>
 73c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 73e:	008b8d13          	addi	s10,s7,8
 742:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 746:	03000593          	li	a1,48
 74a:	855a                	mv	a0,s6
 74c:	d3fff0ef          	jal	48a <putc>
  putc(fd, 'x');
 750:	07800593          	li	a1,120
 754:	855a                	mv	a0,s6
 756:	d35ff0ef          	jal	48a <putc>
 75a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 75c:	00000b97          	auipc	s7,0x0
 760:	38cb8b93          	addi	s7,s7,908 # ae8 <digits>
 764:	03c9d793          	srli	a5,s3,0x3c
 768:	97de                	add	a5,a5,s7
 76a:	0007c583          	lbu	a1,0(a5)
 76e:	855a                	mv	a0,s6
 770:	d1bff0ef          	jal	48a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 774:	0992                	slli	s3,s3,0x4
 776:	397d                	addiw	s2,s2,-1
 778:	fe0916e3          	bnez	s2,764 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 77c:	8bea                	mv	s7,s10
      state = 0;
 77e:	4981                	li	s3,0
 780:	6d02                	ld	s10,0(sp)
 782:	bd21                	j	59a <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 784:	008b8993          	addi	s3,s7,8
 788:	000bb903          	ld	s2,0(s7)
 78c:	00090f63          	beqz	s2,7aa <vprintf+0x25a>
        for(; *s; s++)
 790:	00094583          	lbu	a1,0(s2)
 794:	c195                	beqz	a1,7b8 <vprintf+0x268>
          putc(fd, *s);
 796:	855a                	mv	a0,s6
 798:	cf3ff0ef          	jal	48a <putc>
        for(; *s; s++)
 79c:	0905                	addi	s2,s2,1
 79e:	00094583          	lbu	a1,0(s2)
 7a2:	f9f5                	bnez	a1,796 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7a4:	8bce                	mv	s7,s3
      state = 0;
 7a6:	4981                	li	s3,0
 7a8:	bbcd                	j	59a <vprintf+0x4a>
          s = "(null)";
 7aa:	00000917          	auipc	s2,0x0
 7ae:	33690913          	addi	s2,s2,822 # ae0 <malloc+0x22a>
        for(; *s; s++)
 7b2:	02800593          	li	a1,40
 7b6:	b7c5                	j	796 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 7b8:	8bce                	mv	s7,s3
      state = 0;
 7ba:	4981                	li	s3,0
 7bc:	bbf9                	j	59a <vprintf+0x4a>
 7be:	64a6                	ld	s1,72(sp)
 7c0:	79e2                	ld	s3,56(sp)
 7c2:	7a42                	ld	s4,48(sp)
 7c4:	7aa2                	ld	s5,40(sp)
 7c6:	7b02                	ld	s6,32(sp)
 7c8:	6be2                	ld	s7,24(sp)
 7ca:	6c42                	ld	s8,16(sp)
 7cc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7ce:	60e6                	ld	ra,88(sp)
 7d0:	6446                	ld	s0,80(sp)
 7d2:	6906                	ld	s2,64(sp)
 7d4:	6125                	addi	sp,sp,96
 7d6:	8082                	ret

00000000000007d8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d8:	715d                	addi	sp,sp,-80
 7da:	ec06                	sd	ra,24(sp)
 7dc:	e822                	sd	s0,16(sp)
 7de:	1000                	addi	s0,sp,32
 7e0:	e010                	sd	a2,0(s0)
 7e2:	e414                	sd	a3,8(s0)
 7e4:	e818                	sd	a4,16(s0)
 7e6:	ec1c                	sd	a5,24(s0)
 7e8:	03043023          	sd	a6,32(s0)
 7ec:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f4:	8622                	mv	a2,s0
 7f6:	d5bff0ef          	jal	550 <vprintf>
}
 7fa:	60e2                	ld	ra,24(sp)
 7fc:	6442                	ld	s0,16(sp)
 7fe:	6161                	addi	sp,sp,80
 800:	8082                	ret

0000000000000802 <printf>:

void
printf(const char *fmt, ...)
{
 802:	711d                	addi	sp,sp,-96
 804:	ec06                	sd	ra,24(sp)
 806:	e822                	sd	s0,16(sp)
 808:	1000                	addi	s0,sp,32
 80a:	e40c                	sd	a1,8(s0)
 80c:	e810                	sd	a2,16(s0)
 80e:	ec14                	sd	a3,24(s0)
 810:	f018                	sd	a4,32(s0)
 812:	f41c                	sd	a5,40(s0)
 814:	03043823          	sd	a6,48(s0)
 818:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81c:	00840613          	addi	a2,s0,8
 820:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 824:	85aa                	mv	a1,a0
 826:	4505                	li	a0,1
 828:	d29ff0ef          	jal	550 <vprintf>
}
 82c:	60e2                	ld	ra,24(sp)
 82e:	6442                	ld	s0,16(sp)
 830:	6125                	addi	sp,sp,96
 832:	8082                	ret

0000000000000834 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 834:	1141                	addi	sp,sp,-16
 836:	e422                	sd	s0,8(sp)
 838:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83e:	00000797          	auipc	a5,0x0
 842:	7c27b783          	ld	a5,1986(a5) # 1000 <freep>
 846:	a02d                	j	870 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 848:	4618                	lw	a4,8(a2)
 84a:	9f2d                	addw	a4,a4,a1
 84c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 850:	6398                	ld	a4,0(a5)
 852:	6310                	ld	a2,0(a4)
 854:	a83d                	j	892 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 856:	ff852703          	lw	a4,-8(a0)
 85a:	9f31                	addw	a4,a4,a2
 85c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 85e:	ff053683          	ld	a3,-16(a0)
 862:	a091                	j	8a6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 864:	6398                	ld	a4,0(a5)
 866:	00e7e463          	bltu	a5,a4,86e <free+0x3a>
 86a:	00e6ea63          	bltu	a3,a4,87e <free+0x4a>
{
 86e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 870:	fed7fae3          	bgeu	a5,a3,864 <free+0x30>
 874:	6398                	ld	a4,0(a5)
 876:	00e6e463          	bltu	a3,a4,87e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87a:	fee7eae3          	bltu	a5,a4,86e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 87e:	ff852583          	lw	a1,-8(a0)
 882:	6390                	ld	a2,0(a5)
 884:	02059813          	slli	a6,a1,0x20
 888:	01c85713          	srli	a4,a6,0x1c
 88c:	9736                	add	a4,a4,a3
 88e:	fae60de3          	beq	a2,a4,848 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 892:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 896:	4790                	lw	a2,8(a5)
 898:	02061593          	slli	a1,a2,0x20
 89c:	01c5d713          	srli	a4,a1,0x1c
 8a0:	973e                	add	a4,a4,a5
 8a2:	fae68ae3          	beq	a3,a4,856 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a8:	00000717          	auipc	a4,0x0
 8ac:	74f73c23          	sd	a5,1880(a4) # 1000 <freep>
}
 8b0:	6422                	ld	s0,8(sp)
 8b2:	0141                	addi	sp,sp,16
 8b4:	8082                	ret

00000000000008b6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b6:	7139                	addi	sp,sp,-64
 8b8:	fc06                	sd	ra,56(sp)
 8ba:	f822                	sd	s0,48(sp)
 8bc:	f426                	sd	s1,40(sp)
 8be:	ec4e                	sd	s3,24(sp)
 8c0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c2:	02051493          	slli	s1,a0,0x20
 8c6:	9081                	srli	s1,s1,0x20
 8c8:	04bd                	addi	s1,s1,15
 8ca:	8091                	srli	s1,s1,0x4
 8cc:	0014899b          	addiw	s3,s1,1
 8d0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d2:	00000517          	auipc	a0,0x0
 8d6:	72e53503          	ld	a0,1838(a0) # 1000 <freep>
 8da:	c915                	beqz	a0,90e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8dc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8de:	4798                	lw	a4,8(a5)
 8e0:	08977a63          	bgeu	a4,s1,974 <malloc+0xbe>
 8e4:	f04a                	sd	s2,32(sp)
 8e6:	e852                	sd	s4,16(sp)
 8e8:	e456                	sd	s5,8(sp)
 8ea:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ec:	8a4e                	mv	s4,s3
 8ee:	0009871b          	sext.w	a4,s3
 8f2:	6685                	lui	a3,0x1
 8f4:	00d77363          	bgeu	a4,a3,8fa <malloc+0x44>
 8f8:	6a05                	lui	s4,0x1
 8fa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fe:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 902:	00000917          	auipc	s2,0x0
 906:	6fe90913          	addi	s2,s2,1790 # 1000 <freep>
  if(p == (char*)-1)
 90a:	5afd                	li	s5,-1
 90c:	a081                	j	94c <malloc+0x96>
 90e:	f04a                	sd	s2,32(sp)
 910:	e852                	sd	s4,16(sp)
 912:	e456                	sd	s5,8(sp)
 914:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 916:	00000797          	auipc	a5,0x0
 91a:	6fa78793          	addi	a5,a5,1786 # 1010 <base>
 91e:	00000717          	auipc	a4,0x0
 922:	6ef73123          	sd	a5,1762(a4) # 1000 <freep>
 926:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 928:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92c:	b7c1                	j	8ec <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 92e:	6398                	ld	a4,0(a5)
 930:	e118                	sd	a4,0(a0)
 932:	a8a9                	j	98c <malloc+0xd6>
  hp->s.size = nu;
 934:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 938:	0541                	addi	a0,a0,16
 93a:	efbff0ef          	jal	834 <free>
  return freep;
 93e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 942:	c12d                	beqz	a0,9a4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 944:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 946:	4798                	lw	a4,8(a5)
 948:	02977263          	bgeu	a4,s1,96c <malloc+0xb6>
    if(p == freep)
 94c:	00093703          	ld	a4,0(s2)
 950:	853e                	mv	a0,a5
 952:	fef719e3          	bne	a4,a5,944 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 956:	8552                	mv	a0,s4
 958:	b0bff0ef          	jal	462 <sbrk>
  if(p == (char*)-1)
 95c:	fd551ce3          	bne	a0,s5,934 <malloc+0x7e>
        return 0;
 960:	4501                	li	a0,0
 962:	7902                	ld	s2,32(sp)
 964:	6a42                	ld	s4,16(sp)
 966:	6aa2                	ld	s5,8(sp)
 968:	6b02                	ld	s6,0(sp)
 96a:	a03d                	j	998 <malloc+0xe2>
 96c:	7902                	ld	s2,32(sp)
 96e:	6a42                	ld	s4,16(sp)
 970:	6aa2                	ld	s5,8(sp)
 972:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 974:	fae48de3          	beq	s1,a4,92e <malloc+0x78>
        p->s.size -= nunits;
 978:	4137073b          	subw	a4,a4,s3
 97c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 97e:	02071693          	slli	a3,a4,0x20
 982:	01c6d713          	srli	a4,a3,0x1c
 986:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 988:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 98c:	00000717          	auipc	a4,0x0
 990:	66a73a23          	sd	a0,1652(a4) # 1000 <freep>
      return (void*)(p + 1);
 994:	01078513          	addi	a0,a5,16
  }
}
 998:	70e2                	ld	ra,56(sp)
 99a:	7442                	ld	s0,48(sp)
 99c:	74a2                	ld	s1,40(sp)
 99e:	69e2                	ld	s3,24(sp)
 9a0:	6121                	addi	sp,sp,64
 9a2:	8082                	ret
 9a4:	7902                	ld	s2,32(sp)
 9a6:	6a42                	ld	s4,16(sp)
 9a8:	6aa2                	ld	s5,8(sp)
 9aa:	6b02                	ld	s6,0(sp)
 9ac:	b7f5                	j	998 <malloc+0xe2>
