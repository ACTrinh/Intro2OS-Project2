
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
	char *p;

	// Find first character after last slash.
	for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	22c000ef          	jal	238 <strlen>
  10:	1502                	slli	a0,a0,0x20
  12:	9101                	srli	a0,a0,0x20
  14:	9526                	add	a0,a0,s1
  16:	02f00713          	li	a4,47
  1a:	00956963          	bltu	a0,s1,2c <fmtname+0x2c>
  1e:	00054783          	lbu	a5,0(a0)
  22:	00e78563          	beq	a5,a4,2c <fmtname+0x2c>
  26:	157d                	addi	a0,a0,-1
  28:	fe957be3          	bgeu	a0,s1,1e <fmtname+0x1e>
		;
	p++;

	return p;
}
  2c:	0505                	addi	a0,a0,1
  2e:	60e2                	ld	ra,24(sp)
  30:	6442                	ld	s0,16(sp)
  32:	64a2                	ld	s1,8(sp)
  34:	6105                	addi	sp,sp,32
  36:	8082                	ret

0000000000000038 <find>:

void
find(char *path, char *targetname) 
{
  38:	d9010113          	addi	sp,sp,-624
  3c:	26113423          	sd	ra,616(sp)
  40:	26813023          	sd	s0,608(sp)
  44:	24913c23          	sd	s1,600(sp)
  48:	25213823          	sd	s2,592(sp)
  4c:	25313423          	sd	s3,584(sp)
  50:	1c80                	addi	s0,sp,624
  52:	892a                	mv	s2,a0
  54:	89ae                	mv	s3,a1
	char buf[512], *p;
	int fd;
	struct dirent de;
	struct stat st;

	if (!strcmp(fmtname(path), targetname)) {
  56:	fabff0ef          	jal	0 <fmtname>
  5a:	85ce                	mv	a1,s3
  5c:	1b0000ef          	jal	20c <strcmp>
  60:	c139                	beqz	a0,a6 <find+0x6e>
		printf("%s\n", path);
	}

	if ((fd = open(path, O_RDONLY)) < 0) {
  62:	4581                	li	a1,0
  64:	854a                	mv	a0,s2
  66:	422000ef          	jal	488 <open>
  6a:	84aa                	mv	s1,a0
  6c:	04054563          	bltz	a0,b6 <find+0x7e>
		fprintf(2, "find: cannot open [%s], fd=%d\n", path, fd);
		return;
	}

	if (fstat(fd, &st) < 0) {
  70:	d9840593          	addi	a1,s0,-616
  74:	42c000ef          	jal	4a0 <fstat>
  78:	04054963          	bltz	a0,ca <find+0x92>
		fprintf(2, "find: cannot stat %s\n", path);
		close(fd);
		return;
	}

	if (st.type != T_DIR) {
  7c:	da041703          	lh	a4,-608(s0)
  80:	4785                	li	a5,1
  82:	06f70063          	beq	a4,a5,e2 <find+0xaa>
		close(fd);
  86:	8526                	mv	a0,s1
  88:	3e8000ef          	jal	470 <close>
			continue;

		find(buf, targetname);
	}
	close(fd);
}
  8c:	26813083          	ld	ra,616(sp)
  90:	26013403          	ld	s0,608(sp)
  94:	25813483          	ld	s1,600(sp)
  98:	25013903          	ld	s2,592(sp)
  9c:	24813983          	ld	s3,584(sp)
  a0:	27010113          	addi	sp,sp,624
  a4:	8082                	ret
		printf("%s\n", path);
  a6:	85ca                	mv	a1,s2
  a8:	00001517          	auipc	a0,0x1
  ac:	97850513          	addi	a0,a0,-1672 # a20 <malloc+0xfc>
  b0:	7c0000ef          	jal	870 <printf>
  b4:	b77d                	j	62 <find+0x2a>
		fprintf(2, "find: cannot open [%s], fd=%d\n", path, fd);
  b6:	86aa                	mv	a3,a0
  b8:	864a                	mv	a2,s2
  ba:	00001597          	auipc	a1,0x1
  be:	96e58593          	addi	a1,a1,-1682 # a28 <malloc+0x104>
  c2:	4509                	li	a0,2
  c4:	782000ef          	jal	846 <fprintf>
		return;
  c8:	b7d1                	j	8c <find+0x54>
		fprintf(2, "find: cannot stat %s\n", path);
  ca:	864a                	mv	a2,s2
  cc:	00001597          	auipc	a1,0x1
  d0:	97c58593          	addi	a1,a1,-1668 # a48 <malloc+0x124>
  d4:	4509                	li	a0,2
  d6:	770000ef          	jal	846 <fprintf>
		close(fd);
  da:	8526                	mv	a0,s1
  dc:	394000ef          	jal	470 <close>
		return;
  e0:	b775                	j	8c <find+0x54>
	if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf) {
  e2:	854a                	mv	a0,s2
  e4:	154000ef          	jal	238 <strlen>
  e8:	2541                	addiw	a0,a0,16
  ea:	20000793          	li	a5,512
  ee:	08a7eb63          	bltu	a5,a0,184 <find+0x14c>
  f2:	25413023          	sd	s4,576(sp)
  f6:	23513c23          	sd	s5,568(sp)
  fa:	23613823          	sd	s6,560(sp)
	strcpy(buf, path);
  fe:	85ca                	mv	a1,s2
 100:	dc040513          	addi	a0,s0,-576
 104:	0ec000ef          	jal	1f0 <strcpy>
	p = buf+strlen(buf);
 108:	dc040513          	addi	a0,s0,-576
 10c:	12c000ef          	jal	238 <strlen>
 110:	1502                	slli	a0,a0,0x20
 112:	9101                	srli	a0,a0,0x20
 114:	dc040793          	addi	a5,s0,-576
 118:	00a78933          	add	s2,a5,a0
	*p++ = '/';
 11c:	00190a93          	addi	s5,s2,1
 120:	02f00793          	li	a5,47
 124:	00f90023          	sb	a5,0(s2)
		if (!strcmp(de.name, ".") || !strcmp(de.name, ".."))
 128:	00001a17          	auipc	s4,0x1
 12c:	950a0a13          	addi	s4,s4,-1712 # a78 <malloc+0x154>
 130:	00001b17          	auipc	s6,0x1
 134:	950b0b13          	addi	s6,s6,-1712 # a80 <malloc+0x15c>
	while (read(fd, &de, sizeof(de)) == sizeof(de)) {
 138:	4641                	li	a2,16
 13a:	db040593          	addi	a1,s0,-592
 13e:	8526                	mv	a0,s1
 140:	320000ef          	jal	460 <read>
 144:	47c1                	li	a5,16
 146:	04f51963          	bne	a0,a5,198 <find+0x160>
		if (de.inum == 0)
 14a:	db045783          	lhu	a5,-592(s0)
 14e:	d7ed                	beqz	a5,138 <find+0x100>
		memmove(p, de.name, DIRSIZ);
 150:	4639                	li	a2,14
 152:	db240593          	addi	a1,s0,-590
 156:	8556                	mv	a0,s5
 158:	242000ef          	jal	39a <memmove>
		p[DIRSIZ] = 0;
 15c:	000907a3          	sb	zero,15(s2)
		if (!strcmp(de.name, ".") || !strcmp(de.name, ".."))
 160:	85d2                	mv	a1,s4
 162:	db240513          	addi	a0,s0,-590
 166:	0a6000ef          	jal	20c <strcmp>
 16a:	d579                	beqz	a0,138 <find+0x100>
 16c:	85da                	mv	a1,s6
 16e:	db240513          	addi	a0,s0,-590
 172:	09a000ef          	jal	20c <strcmp>
 176:	d169                	beqz	a0,138 <find+0x100>
		find(buf, targetname);
 178:	85ce                	mv	a1,s3
 17a:	dc040513          	addi	a0,s0,-576
 17e:	ebbff0ef          	jal	38 <find>
 182:	bf5d                	j	138 <find+0x100>
		printf("find: path too long\n");
 184:	00001517          	auipc	a0,0x1
 188:	8dc50513          	addi	a0,a0,-1828 # a60 <malloc+0x13c>
 18c:	6e4000ef          	jal	870 <printf>
		close(fd);
 190:	8526                	mv	a0,s1
 192:	2de000ef          	jal	470 <close>
		return;
 196:	bddd                	j	8c <find+0x54>
	close(fd);
 198:	8526                	mv	a0,s1
 19a:	2d6000ef          	jal	470 <close>
 19e:	24013a03          	ld	s4,576(sp)
 1a2:	23813a83          	ld	s5,568(sp)
 1a6:	23013b03          	ld	s6,560(sp)
 1aa:	b5cd                	j	8c <find+0x54>

00000000000001ac <main>:

int
main(int argc, char *argv[])
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e406                	sd	ra,8(sp)
 1b0:	e022                	sd	s0,0(sp)
 1b2:	0800                	addi	s0,sp,16
	if(argc < 3){
 1b4:	4709                	li	a4,2
 1b6:	00a74c63          	blt	a4,a0,1ce <main+0x22>
		fprintf(2, "usage: find path filename\n");
 1ba:	00001597          	auipc	a1,0x1
 1be:	8ce58593          	addi	a1,a1,-1842 # a88 <malloc+0x164>
 1c2:	4509                	li	a0,2
 1c4:	682000ef          	jal	846 <fprintf>
		exit(1);
 1c8:	4505                	li	a0,1
 1ca:	27e000ef          	jal	448 <exit>
 1ce:	87ae                	mv	a5,a1
	}

	find(argv[1], argv[2]);
 1d0:	698c                	ld	a1,16(a1)
 1d2:	6788                	ld	a0,8(a5)
 1d4:	e65ff0ef          	jal	38 <find>

	exit(0);
 1d8:	4501                	li	a0,0
 1da:	26e000ef          	jal	448 <exit>

00000000000001de <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 1de:	1141                	addi	sp,sp,-16
 1e0:	e406                	sd	ra,8(sp)
 1e2:	e022                	sd	s0,0(sp)
 1e4:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1e6:	fc7ff0ef          	jal	1ac <main>
  exit(0);
 1ea:	4501                	li	a0,0
 1ec:	25c000ef          	jal	448 <exit>

00000000000001f0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1f0:	1141                	addi	sp,sp,-16
 1f2:	e422                	sd	s0,8(sp)
 1f4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f6:	87aa                	mv	a5,a0
 1f8:	0585                	addi	a1,a1,1
 1fa:	0785                	addi	a5,a5,1
 1fc:	fff5c703          	lbu	a4,-1(a1)
 200:	fee78fa3          	sb	a4,-1(a5)
 204:	fb75                	bnez	a4,1f8 <strcpy+0x8>
    ;
  return os;
}
 206:	6422                	ld	s0,8(sp)
 208:	0141                	addi	sp,sp,16
 20a:	8082                	ret

000000000000020c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 20c:	1141                	addi	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 212:	00054783          	lbu	a5,0(a0)
 216:	cb91                	beqz	a5,22a <strcmp+0x1e>
 218:	0005c703          	lbu	a4,0(a1)
 21c:	00f71763          	bne	a4,a5,22a <strcmp+0x1e>
    p++, q++;
 220:	0505                	addi	a0,a0,1
 222:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 224:	00054783          	lbu	a5,0(a0)
 228:	fbe5                	bnez	a5,218 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 22a:	0005c503          	lbu	a0,0(a1)
}
 22e:	40a7853b          	subw	a0,a5,a0
 232:	6422                	ld	s0,8(sp)
 234:	0141                	addi	sp,sp,16
 236:	8082                	ret

0000000000000238 <strlen>:

uint
strlen(const char *s)
{
 238:	1141                	addi	sp,sp,-16
 23a:	e422                	sd	s0,8(sp)
 23c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 23e:	00054783          	lbu	a5,0(a0)
 242:	cf91                	beqz	a5,25e <strlen+0x26>
 244:	0505                	addi	a0,a0,1
 246:	87aa                	mv	a5,a0
 248:	86be                	mv	a3,a5
 24a:	0785                	addi	a5,a5,1
 24c:	fff7c703          	lbu	a4,-1(a5)
 250:	ff65                	bnez	a4,248 <strlen+0x10>
 252:	40a6853b          	subw	a0,a3,a0
 256:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret
  for(n = 0; s[n]; n++)
 25e:	4501                	li	a0,0
 260:	bfe5                	j	258 <strlen+0x20>

0000000000000262 <memset>:

void*
memset(void *dst, int c, uint n)
{
 262:	1141                	addi	sp,sp,-16
 264:	e422                	sd	s0,8(sp)
 266:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 268:	ca19                	beqz	a2,27e <memset+0x1c>
 26a:	87aa                	mv	a5,a0
 26c:	1602                	slli	a2,a2,0x20
 26e:	9201                	srli	a2,a2,0x20
 270:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 274:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 278:	0785                	addi	a5,a5,1
 27a:	fee79de3          	bne	a5,a4,274 <memset+0x12>
  }
  return dst;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret

0000000000000284 <strchr>:

char*
strchr(const char *s, char c)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  for(; *s; s++)
 28a:	00054783          	lbu	a5,0(a0)
 28e:	cb99                	beqz	a5,2a4 <strchr+0x20>
    if(*s == c)
 290:	00f58763          	beq	a1,a5,29e <strchr+0x1a>
  for(; *s; s++)
 294:	0505                	addi	a0,a0,1
 296:	00054783          	lbu	a5,0(a0)
 29a:	fbfd                	bnez	a5,290 <strchr+0xc>
      return (char*)s;
  return 0;
 29c:	4501                	li	a0,0
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  return 0;
 2a4:	4501                	li	a0,0
 2a6:	bfe5                	j	29e <strchr+0x1a>

00000000000002a8 <gets>:

char*
gets(char *buf, int max)
{
 2a8:	711d                	addi	sp,sp,-96
 2aa:	ec86                	sd	ra,88(sp)
 2ac:	e8a2                	sd	s0,80(sp)
 2ae:	e4a6                	sd	s1,72(sp)
 2b0:	e0ca                	sd	s2,64(sp)
 2b2:	fc4e                	sd	s3,56(sp)
 2b4:	f852                	sd	s4,48(sp)
 2b6:	f456                	sd	s5,40(sp)
 2b8:	f05a                	sd	s6,32(sp)
 2ba:	ec5e                	sd	s7,24(sp)
 2bc:	1080                	addi	s0,sp,96
 2be:	8baa                	mv	s7,a0
 2c0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c2:	892a                	mv	s2,a0
 2c4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2c6:	4aa9                	li	s5,10
 2c8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ca:	89a6                	mv	s3,s1
 2cc:	2485                	addiw	s1,s1,1
 2ce:	0344d663          	bge	s1,s4,2fa <gets+0x52>
    cc = read(0, &c, 1);
 2d2:	4605                	li	a2,1
 2d4:	faf40593          	addi	a1,s0,-81
 2d8:	4501                	li	a0,0
 2da:	186000ef          	jal	460 <read>
    if(cc < 1)
 2de:	00a05e63          	blez	a0,2fa <gets+0x52>
    buf[i++] = c;
 2e2:	faf44783          	lbu	a5,-81(s0)
 2e6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2ea:	01578763          	beq	a5,s5,2f8 <gets+0x50>
 2ee:	0905                	addi	s2,s2,1
 2f0:	fd679de3          	bne	a5,s6,2ca <gets+0x22>
    buf[i++] = c;
 2f4:	89a6                	mv	s3,s1
 2f6:	a011                	j	2fa <gets+0x52>
 2f8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2fa:	99de                	add	s3,s3,s7
 2fc:	00098023          	sb	zero,0(s3)
  return buf;
}
 300:	855e                	mv	a0,s7
 302:	60e6                	ld	ra,88(sp)
 304:	6446                	ld	s0,80(sp)
 306:	64a6                	ld	s1,72(sp)
 308:	6906                	ld	s2,64(sp)
 30a:	79e2                	ld	s3,56(sp)
 30c:	7a42                	ld	s4,48(sp)
 30e:	7aa2                	ld	s5,40(sp)
 310:	7b02                	ld	s6,32(sp)
 312:	6be2                	ld	s7,24(sp)
 314:	6125                	addi	sp,sp,96
 316:	8082                	ret

0000000000000318 <stat>:

int
stat(const char *n, struct stat *st)
{
 318:	1101                	addi	sp,sp,-32
 31a:	ec06                	sd	ra,24(sp)
 31c:	e822                	sd	s0,16(sp)
 31e:	e04a                	sd	s2,0(sp)
 320:	1000                	addi	s0,sp,32
 322:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 324:	4581                	li	a1,0
 326:	162000ef          	jal	488 <open>
  if(fd < 0)
 32a:	02054263          	bltz	a0,34e <stat+0x36>
 32e:	e426                	sd	s1,8(sp)
 330:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 332:	85ca                	mv	a1,s2
 334:	16c000ef          	jal	4a0 <fstat>
 338:	892a                	mv	s2,a0
  close(fd);
 33a:	8526                	mv	a0,s1
 33c:	134000ef          	jal	470 <close>
  return r;
 340:	64a2                	ld	s1,8(sp)
}
 342:	854a                	mv	a0,s2
 344:	60e2                	ld	ra,24(sp)
 346:	6442                	ld	s0,16(sp)
 348:	6902                	ld	s2,0(sp)
 34a:	6105                	addi	sp,sp,32
 34c:	8082                	ret
    return -1;
 34e:	597d                	li	s2,-1
 350:	bfcd                	j	342 <stat+0x2a>

0000000000000352 <atoi>:

int
atoi(const char *s)
{
 352:	1141                	addi	sp,sp,-16
 354:	e422                	sd	s0,8(sp)
 356:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 358:	00054683          	lbu	a3,0(a0)
 35c:	fd06879b          	addiw	a5,a3,-48
 360:	0ff7f793          	zext.b	a5,a5
 364:	4625                	li	a2,9
 366:	02f66863          	bltu	a2,a5,396 <atoi+0x44>
 36a:	872a                	mv	a4,a0
  n = 0;
 36c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 36e:	0705                	addi	a4,a4,1
 370:	0025179b          	slliw	a5,a0,0x2
 374:	9fa9                	addw	a5,a5,a0
 376:	0017979b          	slliw	a5,a5,0x1
 37a:	9fb5                	addw	a5,a5,a3
 37c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 380:	00074683          	lbu	a3,0(a4)
 384:	fd06879b          	addiw	a5,a3,-48
 388:	0ff7f793          	zext.b	a5,a5
 38c:	fef671e3          	bgeu	a2,a5,36e <atoi+0x1c>
  return n;
}
 390:	6422                	ld	s0,8(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret
  n = 0;
 396:	4501                	li	a0,0
 398:	bfe5                	j	390 <atoi+0x3e>

000000000000039a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 39a:	1141                	addi	sp,sp,-16
 39c:	e422                	sd	s0,8(sp)
 39e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3a0:	02b57463          	bgeu	a0,a1,3c8 <memmove+0x2e>
    while(n-- > 0)
 3a4:	00c05f63          	blez	a2,3c2 <memmove+0x28>
 3a8:	1602                	slli	a2,a2,0x20
 3aa:	9201                	srli	a2,a2,0x20
 3ac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3b0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3b2:	0585                	addi	a1,a1,1
 3b4:	0705                	addi	a4,a4,1
 3b6:	fff5c683          	lbu	a3,-1(a1)
 3ba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3be:	fef71ae3          	bne	a4,a5,3b2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret
    dst += n;
 3c8:	00c50733          	add	a4,a0,a2
    src += n;
 3cc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ce:	fec05ae3          	blez	a2,3c2 <memmove+0x28>
 3d2:	fff6079b          	addiw	a5,a2,-1
 3d6:	1782                	slli	a5,a5,0x20
 3d8:	9381                	srli	a5,a5,0x20
 3da:	fff7c793          	not	a5,a5
 3de:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3e0:	15fd                	addi	a1,a1,-1
 3e2:	177d                	addi	a4,a4,-1
 3e4:	0005c683          	lbu	a3,0(a1)
 3e8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3ec:	fee79ae3          	bne	a5,a4,3e0 <memmove+0x46>
 3f0:	bfc9                	j	3c2 <memmove+0x28>

00000000000003f2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e422                	sd	s0,8(sp)
 3f6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3f8:	ca05                	beqz	a2,428 <memcmp+0x36>
 3fa:	fff6069b          	addiw	a3,a2,-1
 3fe:	1682                	slli	a3,a3,0x20
 400:	9281                	srli	a3,a3,0x20
 402:	0685                	addi	a3,a3,1
 404:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 406:	00054783          	lbu	a5,0(a0)
 40a:	0005c703          	lbu	a4,0(a1)
 40e:	00e79863          	bne	a5,a4,41e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 412:	0505                	addi	a0,a0,1
    p2++;
 414:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 416:	fed518e3          	bne	a0,a3,406 <memcmp+0x14>
  }
  return 0;
 41a:	4501                	li	a0,0
 41c:	a019                	j	422 <memcmp+0x30>
      return *p1 - *p2;
 41e:	40e7853b          	subw	a0,a5,a4
}
 422:	6422                	ld	s0,8(sp)
 424:	0141                	addi	sp,sp,16
 426:	8082                	ret
  return 0;
 428:	4501                	li	a0,0
 42a:	bfe5                	j	422 <memcmp+0x30>

000000000000042c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 42c:	1141                	addi	sp,sp,-16
 42e:	e406                	sd	ra,8(sp)
 430:	e022                	sd	s0,0(sp)
 432:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 434:	f67ff0ef          	jal	39a <memmove>
}
 438:	60a2                	ld	ra,8(sp)
 43a:	6402                	ld	s0,0(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret

0000000000000440 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 440:	4885                	li	a7,1
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <exit>:
.global exit
exit:
 li a7, SYS_exit
 448:	4889                	li	a7,2
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <wait>:
.global wait
wait:
 li a7, SYS_wait
 450:	488d                	li	a7,3
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 458:	4891                	li	a7,4
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <read>:
.global read
read:
 li a7, SYS_read
 460:	4895                	li	a7,5
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <write>:
.global write
write:
 li a7, SYS_write
 468:	48c1                	li	a7,16
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <close>:
.global close
close:
 li a7, SYS_close
 470:	48d5                	li	a7,21
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <kill>:
.global kill
kill:
 li a7, SYS_kill
 478:	4899                	li	a7,6
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <exec>:
.global exec
exec:
 li a7, SYS_exec
 480:	489d                	li	a7,7
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <open>:
.global open
open:
 li a7, SYS_open
 488:	48bd                	li	a7,15
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 490:	48c5                	li	a7,17
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 498:	48c9                	li	a7,18
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4a0:	48a1                	li	a7,8
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <link>:
.global link
link:
 li a7, SYS_link
 4a8:	48cd                	li	a7,19
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4b0:	48d1                	li	a7,20
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4b8:	48a5                	li	a7,9
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4c0:	48a9                	li	a7,10
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4c8:	48ad                	li	a7,11
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4d0:	48b1                	li	a7,12
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4d8:	48b5                	li	a7,13
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4e0:	48b9                	li	a7,14
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <trace>:
.global trace
trace:
 li a7, SYS_trace
 4e8:	48d9                	li	a7,22
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 4f0:	48dd                	li	a7,23
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4f8:	1101                	addi	sp,sp,-32
 4fa:	ec06                	sd	ra,24(sp)
 4fc:	e822                	sd	s0,16(sp)
 4fe:	1000                	addi	s0,sp,32
 500:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 504:	4605                	li	a2,1
 506:	fef40593          	addi	a1,s0,-17
 50a:	f5fff0ef          	jal	468 <write>
}
 50e:	60e2                	ld	ra,24(sp)
 510:	6442                	ld	s0,16(sp)
 512:	6105                	addi	sp,sp,32
 514:	8082                	ret

0000000000000516 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 516:	7139                	addi	sp,sp,-64
 518:	fc06                	sd	ra,56(sp)
 51a:	f822                	sd	s0,48(sp)
 51c:	f426                	sd	s1,40(sp)
 51e:	0080                	addi	s0,sp,64
 520:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 522:	c299                	beqz	a3,528 <printint+0x12>
 524:	0805c963          	bltz	a1,5b6 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 528:	2581                	sext.w	a1,a1
  neg = 0;
 52a:	4881                	li	a7,0
 52c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 530:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 532:	2601                	sext.w	a2,a2
 534:	00000517          	auipc	a0,0x0
 538:	57c50513          	addi	a0,a0,1404 # ab0 <digits>
 53c:	883a                	mv	a6,a4
 53e:	2705                	addiw	a4,a4,1
 540:	02c5f7bb          	remuw	a5,a1,a2
 544:	1782                	slli	a5,a5,0x20
 546:	9381                	srli	a5,a5,0x20
 548:	97aa                	add	a5,a5,a0
 54a:	0007c783          	lbu	a5,0(a5)
 54e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 552:	0005879b          	sext.w	a5,a1
 556:	02c5d5bb          	divuw	a1,a1,a2
 55a:	0685                	addi	a3,a3,1
 55c:	fec7f0e3          	bgeu	a5,a2,53c <printint+0x26>
  if(neg)
 560:	00088c63          	beqz	a7,578 <printint+0x62>
    buf[i++] = '-';
 564:	fd070793          	addi	a5,a4,-48
 568:	00878733          	add	a4,a5,s0
 56c:	02d00793          	li	a5,45
 570:	fef70823          	sb	a5,-16(a4)
 574:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 578:	02e05a63          	blez	a4,5ac <printint+0x96>
 57c:	f04a                	sd	s2,32(sp)
 57e:	ec4e                	sd	s3,24(sp)
 580:	fc040793          	addi	a5,s0,-64
 584:	00e78933          	add	s2,a5,a4
 588:	fff78993          	addi	s3,a5,-1
 58c:	99ba                	add	s3,s3,a4
 58e:	377d                	addiw	a4,a4,-1
 590:	1702                	slli	a4,a4,0x20
 592:	9301                	srli	a4,a4,0x20
 594:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 598:	fff94583          	lbu	a1,-1(s2)
 59c:	8526                	mv	a0,s1
 59e:	f5bff0ef          	jal	4f8 <putc>
  while(--i >= 0)
 5a2:	197d                	addi	s2,s2,-1
 5a4:	ff391ae3          	bne	s2,s3,598 <printint+0x82>
 5a8:	7902                	ld	s2,32(sp)
 5aa:	69e2                	ld	s3,24(sp)
}
 5ac:	70e2                	ld	ra,56(sp)
 5ae:	7442                	ld	s0,48(sp)
 5b0:	74a2                	ld	s1,40(sp)
 5b2:	6121                	addi	sp,sp,64
 5b4:	8082                	ret
    x = -xx;
 5b6:	40b005bb          	negw	a1,a1
    neg = 1;
 5ba:	4885                	li	a7,1
    x = -xx;
 5bc:	bf85                	j	52c <printint+0x16>

00000000000005be <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5be:	711d                	addi	sp,sp,-96
 5c0:	ec86                	sd	ra,88(sp)
 5c2:	e8a2                	sd	s0,80(sp)
 5c4:	e0ca                	sd	s2,64(sp)
 5c6:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5c8:	0005c903          	lbu	s2,0(a1)
 5cc:	26090863          	beqz	s2,83c <vprintf+0x27e>
 5d0:	e4a6                	sd	s1,72(sp)
 5d2:	fc4e                	sd	s3,56(sp)
 5d4:	f852                	sd	s4,48(sp)
 5d6:	f456                	sd	s5,40(sp)
 5d8:	f05a                	sd	s6,32(sp)
 5da:	ec5e                	sd	s7,24(sp)
 5dc:	e862                	sd	s8,16(sp)
 5de:	e466                	sd	s9,8(sp)
 5e0:	8b2a                	mv	s6,a0
 5e2:	8a2e                	mv	s4,a1
 5e4:	8bb2                	mv	s7,a2
  state = 0;
 5e6:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 5e8:	4481                	li	s1,0
 5ea:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 5ec:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 5f0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5f4:	06c00c93          	li	s9,108
 5f8:	a005                	j	618 <vprintf+0x5a>
        putc(fd, c0);
 5fa:	85ca                	mv	a1,s2
 5fc:	855a                	mv	a0,s6
 5fe:	efbff0ef          	jal	4f8 <putc>
 602:	a019                	j	608 <vprintf+0x4a>
    } else if(state == '%'){
 604:	03598263          	beq	s3,s5,628 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 608:	2485                	addiw	s1,s1,1
 60a:	8726                	mv	a4,s1
 60c:	009a07b3          	add	a5,s4,s1
 610:	0007c903          	lbu	s2,0(a5)
 614:	20090c63          	beqz	s2,82c <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 618:	0009079b          	sext.w	a5,s2
    if(state == 0){
 61c:	fe0994e3          	bnez	s3,604 <vprintf+0x46>
      if(c0 == '%'){
 620:	fd579de3          	bne	a5,s5,5fa <vprintf+0x3c>
        state = '%';
 624:	89be                	mv	s3,a5
 626:	b7cd                	j	608 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 628:	00ea06b3          	add	a3,s4,a4
 62c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 630:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 632:	c681                	beqz	a3,63a <vprintf+0x7c>
 634:	9752                	add	a4,a4,s4
 636:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 63a:	03878f63          	beq	a5,s8,678 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 63e:	05978963          	beq	a5,s9,690 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 642:	07500713          	li	a4,117
 646:	0ee78363          	beq	a5,a4,72c <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 64a:	07800713          	li	a4,120
 64e:	12e78563          	beq	a5,a4,778 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 652:	07000713          	li	a4,112
 656:	14e78a63          	beq	a5,a4,7aa <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 65a:	07300713          	li	a4,115
 65e:	18e78a63          	beq	a5,a4,7f2 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 662:	02500713          	li	a4,37
 666:	04e79563          	bne	a5,a4,6b0 <vprintf+0xf2>
        putc(fd, '%');
 66a:	02500593          	li	a1,37
 66e:	855a                	mv	a0,s6
 670:	e89ff0ef          	jal	4f8 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 674:	4981                	li	s3,0
 676:	bf49                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 678:	008b8913          	addi	s2,s7,8
 67c:	4685                	li	a3,1
 67e:	4629                	li	a2,10
 680:	000ba583          	lw	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e91ff0ef          	jal	516 <printint>
 68a:	8bca                	mv	s7,s2
      state = 0;
 68c:	4981                	li	s3,0
 68e:	bfad                	j	608 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 690:	06400793          	li	a5,100
 694:	02f68963          	beq	a3,a5,6c6 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 698:	06c00793          	li	a5,108
 69c:	04f68263          	beq	a3,a5,6e0 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 6a0:	07500793          	li	a5,117
 6a4:	0af68063          	beq	a3,a5,744 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 6a8:	07800793          	li	a5,120
 6ac:	0ef68263          	beq	a3,a5,790 <vprintf+0x1d2>
        putc(fd, '%');
 6b0:	02500593          	li	a1,37
 6b4:	855a                	mv	a0,s6
 6b6:	e43ff0ef          	jal	4f8 <putc>
        putc(fd, c0);
 6ba:	85ca                	mv	a1,s2
 6bc:	855a                	mv	a0,s6
 6be:	e3bff0ef          	jal	4f8 <putc>
      state = 0;
 6c2:	4981                	li	s3,0
 6c4:	b791                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c6:	008b8913          	addi	s2,s7,8
 6ca:	4685                	li	a3,1
 6cc:	4629                	li	a2,10
 6ce:	000ba583          	lw	a1,0(s7)
 6d2:	855a                	mv	a0,s6
 6d4:	e43ff0ef          	jal	516 <printint>
        i += 1;
 6d8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 6da:	8bca                	mv	s7,s2
      state = 0;
 6dc:	4981                	li	s3,0
        i += 1;
 6de:	b72d                	j	608 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6e0:	06400793          	li	a5,100
 6e4:	02f60763          	beq	a2,a5,712 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 6e8:	07500793          	li	a5,117
 6ec:	06f60963          	beq	a2,a5,75e <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 6f0:	07800793          	li	a5,120
 6f4:	faf61ee3          	bne	a2,a5,6b0 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6f8:	008b8913          	addi	s2,s7,8
 6fc:	4681                	li	a3,0
 6fe:	4641                	li	a2,16
 700:	000ba583          	lw	a1,0(s7)
 704:	855a                	mv	a0,s6
 706:	e11ff0ef          	jal	516 <printint>
        i += 2;
 70a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 70c:	8bca                	mv	s7,s2
      state = 0;
 70e:	4981                	li	s3,0
        i += 2;
 710:	bde5                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 712:	008b8913          	addi	s2,s7,8
 716:	4685                	li	a3,1
 718:	4629                	li	a2,10
 71a:	000ba583          	lw	a1,0(s7)
 71e:	855a                	mv	a0,s6
 720:	df7ff0ef          	jal	516 <printint>
        i += 2;
 724:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 726:	8bca                	mv	s7,s2
      state = 0;
 728:	4981                	li	s3,0
        i += 2;
 72a:	bdf9                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 72c:	008b8913          	addi	s2,s7,8
 730:	4681                	li	a3,0
 732:	4629                	li	a2,10
 734:	000ba583          	lw	a1,0(s7)
 738:	855a                	mv	a0,s6
 73a:	dddff0ef          	jal	516 <printint>
 73e:	8bca                	mv	s7,s2
      state = 0;
 740:	4981                	li	s3,0
 742:	b5d9                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 744:	008b8913          	addi	s2,s7,8
 748:	4681                	li	a3,0
 74a:	4629                	li	a2,10
 74c:	000ba583          	lw	a1,0(s7)
 750:	855a                	mv	a0,s6
 752:	dc5ff0ef          	jal	516 <printint>
        i += 1;
 756:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 758:	8bca                	mv	s7,s2
      state = 0;
 75a:	4981                	li	s3,0
        i += 1;
 75c:	b575                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 75e:	008b8913          	addi	s2,s7,8
 762:	4681                	li	a3,0
 764:	4629                	li	a2,10
 766:	000ba583          	lw	a1,0(s7)
 76a:	855a                	mv	a0,s6
 76c:	dabff0ef          	jal	516 <printint>
        i += 2;
 770:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
        i += 2;
 776:	bd49                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 778:	008b8913          	addi	s2,s7,8
 77c:	4681                	li	a3,0
 77e:	4641                	li	a2,16
 780:	000ba583          	lw	a1,0(s7)
 784:	855a                	mv	a0,s6
 786:	d91ff0ef          	jal	516 <printint>
 78a:	8bca                	mv	s7,s2
      state = 0;
 78c:	4981                	li	s3,0
 78e:	bdad                	j	608 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 790:	008b8913          	addi	s2,s7,8
 794:	4681                	li	a3,0
 796:	4641                	li	a2,16
 798:	000ba583          	lw	a1,0(s7)
 79c:	855a                	mv	a0,s6
 79e:	d79ff0ef          	jal	516 <printint>
        i += 1;
 7a2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7a4:	8bca                	mv	s7,s2
      state = 0;
 7a6:	4981                	li	s3,0
        i += 1;
 7a8:	b585                	j	608 <vprintf+0x4a>
 7aa:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7ac:	008b8d13          	addi	s10,s7,8
 7b0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7b4:	03000593          	li	a1,48
 7b8:	855a                	mv	a0,s6
 7ba:	d3fff0ef          	jal	4f8 <putc>
  putc(fd, 'x');
 7be:	07800593          	li	a1,120
 7c2:	855a                	mv	a0,s6
 7c4:	d35ff0ef          	jal	4f8 <putc>
 7c8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 7ca:	00000b97          	auipc	s7,0x0
 7ce:	2e6b8b93          	addi	s7,s7,742 # ab0 <digits>
 7d2:	03c9d793          	srli	a5,s3,0x3c
 7d6:	97de                	add	a5,a5,s7
 7d8:	0007c583          	lbu	a1,0(a5)
 7dc:	855a                	mv	a0,s6
 7de:	d1bff0ef          	jal	4f8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 7e2:	0992                	slli	s3,s3,0x4
 7e4:	397d                	addiw	s2,s2,-1
 7e6:	fe0916e3          	bnez	s2,7d2 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 7ea:	8bea                	mv	s7,s10
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	6d02                	ld	s10,0(sp)
 7f0:	bd21                	j	608 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7f2:	008b8993          	addi	s3,s7,8
 7f6:	000bb903          	ld	s2,0(s7)
 7fa:	00090f63          	beqz	s2,818 <vprintf+0x25a>
        for(; *s; s++)
 7fe:	00094583          	lbu	a1,0(s2)
 802:	c195                	beqz	a1,826 <vprintf+0x268>
          putc(fd, *s);
 804:	855a                	mv	a0,s6
 806:	cf3ff0ef          	jal	4f8 <putc>
        for(; *s; s++)
 80a:	0905                	addi	s2,s2,1
 80c:	00094583          	lbu	a1,0(s2)
 810:	f9f5                	bnez	a1,804 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 812:	8bce                	mv	s7,s3
      state = 0;
 814:	4981                	li	s3,0
 816:	bbcd                	j	608 <vprintf+0x4a>
          s = "(null)";
 818:	00000917          	auipc	s2,0x0
 81c:	29090913          	addi	s2,s2,656 # aa8 <malloc+0x184>
        for(; *s; s++)
 820:	02800593          	li	a1,40
 824:	b7c5                	j	804 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 826:	8bce                	mv	s7,s3
      state = 0;
 828:	4981                	li	s3,0
 82a:	bbf9                	j	608 <vprintf+0x4a>
 82c:	64a6                	ld	s1,72(sp)
 82e:	79e2                	ld	s3,56(sp)
 830:	7a42                	ld	s4,48(sp)
 832:	7aa2                	ld	s5,40(sp)
 834:	7b02                	ld	s6,32(sp)
 836:	6be2                	ld	s7,24(sp)
 838:	6c42                	ld	s8,16(sp)
 83a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 83c:	60e6                	ld	ra,88(sp)
 83e:	6446                	ld	s0,80(sp)
 840:	6906                	ld	s2,64(sp)
 842:	6125                	addi	sp,sp,96
 844:	8082                	ret

0000000000000846 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 846:	715d                	addi	sp,sp,-80
 848:	ec06                	sd	ra,24(sp)
 84a:	e822                	sd	s0,16(sp)
 84c:	1000                	addi	s0,sp,32
 84e:	e010                	sd	a2,0(s0)
 850:	e414                	sd	a3,8(s0)
 852:	e818                	sd	a4,16(s0)
 854:	ec1c                	sd	a5,24(s0)
 856:	03043023          	sd	a6,32(s0)
 85a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 85e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 862:	8622                	mv	a2,s0
 864:	d5bff0ef          	jal	5be <vprintf>
}
 868:	60e2                	ld	ra,24(sp)
 86a:	6442                	ld	s0,16(sp)
 86c:	6161                	addi	sp,sp,80
 86e:	8082                	ret

0000000000000870 <printf>:

void
printf(const char *fmt, ...)
{
 870:	711d                	addi	sp,sp,-96
 872:	ec06                	sd	ra,24(sp)
 874:	e822                	sd	s0,16(sp)
 876:	1000                	addi	s0,sp,32
 878:	e40c                	sd	a1,8(s0)
 87a:	e810                	sd	a2,16(s0)
 87c:	ec14                	sd	a3,24(s0)
 87e:	f018                	sd	a4,32(s0)
 880:	f41c                	sd	a5,40(s0)
 882:	03043823          	sd	a6,48(s0)
 886:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 88a:	00840613          	addi	a2,s0,8
 88e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 892:	85aa                	mv	a1,a0
 894:	4505                	li	a0,1
 896:	d29ff0ef          	jal	5be <vprintf>
}
 89a:	60e2                	ld	ra,24(sp)
 89c:	6442                	ld	s0,16(sp)
 89e:	6125                	addi	sp,sp,96
 8a0:	8082                	ret

00000000000008a2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8a2:	1141                	addi	sp,sp,-16
 8a4:	e422                	sd	s0,8(sp)
 8a6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8a8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8ac:	00000797          	auipc	a5,0x0
 8b0:	7547b783          	ld	a5,1876(a5) # 1000 <freep>
 8b4:	a02d                	j	8de <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8b6:	4618                	lw	a4,8(a2)
 8b8:	9f2d                	addw	a4,a4,a1
 8ba:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8be:	6398                	ld	a4,0(a5)
 8c0:	6310                	ld	a2,0(a4)
 8c2:	a83d                	j	900 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 8c4:	ff852703          	lw	a4,-8(a0)
 8c8:	9f31                	addw	a4,a4,a2
 8ca:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8cc:	ff053683          	ld	a3,-16(a0)
 8d0:	a091                	j	914 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8d2:	6398                	ld	a4,0(a5)
 8d4:	00e7e463          	bltu	a5,a4,8dc <free+0x3a>
 8d8:	00e6ea63          	bltu	a3,a4,8ec <free+0x4a>
{
 8dc:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8de:	fed7fae3          	bgeu	a5,a3,8d2 <free+0x30>
 8e2:	6398                	ld	a4,0(a5)
 8e4:	00e6e463          	bltu	a3,a4,8ec <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8e8:	fee7eae3          	bltu	a5,a4,8dc <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8ec:	ff852583          	lw	a1,-8(a0)
 8f0:	6390                	ld	a2,0(a5)
 8f2:	02059813          	slli	a6,a1,0x20
 8f6:	01c85713          	srli	a4,a6,0x1c
 8fa:	9736                	add	a4,a4,a3
 8fc:	fae60de3          	beq	a2,a4,8b6 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 900:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 904:	4790                	lw	a2,8(a5)
 906:	02061593          	slli	a1,a2,0x20
 90a:	01c5d713          	srli	a4,a1,0x1c
 90e:	973e                	add	a4,a4,a5
 910:	fae68ae3          	beq	a3,a4,8c4 <free+0x22>
    p->s.ptr = bp->s.ptr;
 914:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 916:	00000717          	auipc	a4,0x0
 91a:	6ef73523          	sd	a5,1770(a4) # 1000 <freep>
}
 91e:	6422                	ld	s0,8(sp)
 920:	0141                	addi	sp,sp,16
 922:	8082                	ret

0000000000000924 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 924:	7139                	addi	sp,sp,-64
 926:	fc06                	sd	ra,56(sp)
 928:	f822                	sd	s0,48(sp)
 92a:	f426                	sd	s1,40(sp)
 92c:	ec4e                	sd	s3,24(sp)
 92e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 930:	02051493          	slli	s1,a0,0x20
 934:	9081                	srli	s1,s1,0x20
 936:	04bd                	addi	s1,s1,15
 938:	8091                	srli	s1,s1,0x4
 93a:	0014899b          	addiw	s3,s1,1
 93e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 940:	00000517          	auipc	a0,0x0
 944:	6c053503          	ld	a0,1728(a0) # 1000 <freep>
 948:	c915                	beqz	a0,97c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94c:	4798                	lw	a4,8(a5)
 94e:	08977a63          	bgeu	a4,s1,9e2 <malloc+0xbe>
 952:	f04a                	sd	s2,32(sp)
 954:	e852                	sd	s4,16(sp)
 956:	e456                	sd	s5,8(sp)
 958:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 95a:	8a4e                	mv	s4,s3
 95c:	0009871b          	sext.w	a4,s3
 960:	6685                	lui	a3,0x1
 962:	00d77363          	bgeu	a4,a3,968 <malloc+0x44>
 966:	6a05                	lui	s4,0x1
 968:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 96c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 970:	00000917          	auipc	s2,0x0
 974:	69090913          	addi	s2,s2,1680 # 1000 <freep>
  if(p == (char*)-1)
 978:	5afd                	li	s5,-1
 97a:	a081                	j	9ba <malloc+0x96>
 97c:	f04a                	sd	s2,32(sp)
 97e:	e852                	sd	s4,16(sp)
 980:	e456                	sd	s5,8(sp)
 982:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 984:	00000797          	auipc	a5,0x0
 988:	68c78793          	addi	a5,a5,1676 # 1010 <base>
 98c:	00000717          	auipc	a4,0x0
 990:	66f73a23          	sd	a5,1652(a4) # 1000 <freep>
 994:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 996:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 99a:	b7c1                	j	95a <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 99c:	6398                	ld	a4,0(a5)
 99e:	e118                	sd	a4,0(a0)
 9a0:	a8a9                	j	9fa <malloc+0xd6>
  hp->s.size = nu;
 9a2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9a6:	0541                	addi	a0,a0,16
 9a8:	efbff0ef          	jal	8a2 <free>
  return freep;
 9ac:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9b0:	c12d                	beqz	a0,a12 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9b4:	4798                	lw	a4,8(a5)
 9b6:	02977263          	bgeu	a4,s1,9da <malloc+0xb6>
    if(p == freep)
 9ba:	00093703          	ld	a4,0(s2)
 9be:	853e                	mv	a0,a5
 9c0:	fef719e3          	bne	a4,a5,9b2 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 9c4:	8552                	mv	a0,s4
 9c6:	b0bff0ef          	jal	4d0 <sbrk>
  if(p == (char*)-1)
 9ca:	fd551ce3          	bne	a0,s5,9a2 <malloc+0x7e>
        return 0;
 9ce:	4501                	li	a0,0
 9d0:	7902                	ld	s2,32(sp)
 9d2:	6a42                	ld	s4,16(sp)
 9d4:	6aa2                	ld	s5,8(sp)
 9d6:	6b02                	ld	s6,0(sp)
 9d8:	a03d                	j	a06 <malloc+0xe2>
 9da:	7902                	ld	s2,32(sp)
 9dc:	6a42                	ld	s4,16(sp)
 9de:	6aa2                	ld	s5,8(sp)
 9e0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9e2:	fae48de3          	beq	s1,a4,99c <malloc+0x78>
        p->s.size -= nunits;
 9e6:	4137073b          	subw	a4,a4,s3
 9ea:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9ec:	02071693          	slli	a3,a4,0x20
 9f0:	01c6d713          	srli	a4,a3,0x1c
 9f4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9f6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9fa:	00000717          	auipc	a4,0x0
 9fe:	60a73323          	sd	a0,1542(a4) # 1000 <freep>
      return (void*)(p + 1);
 a02:	01078513          	addi	a0,a5,16
  }
}
 a06:	70e2                	ld	ra,56(sp)
 a08:	7442                	ld	s0,48(sp)
 a0a:	74a2                	ld	s1,40(sp)
 a0c:	69e2                	ld	s3,24(sp)
 a0e:	6121                	addi	sp,sp,64
 a10:	8082                	ret
 a12:	7902                	ld	s2,32(sp)
 a14:	6a42                	ld	s4,16(sp)
 a16:	6aa2                	ld	s5,8(sp)
 a18:	6b02                	ld	s6,0(sp)
 a1a:	b7f5                	j	a06 <malloc+0xe2>
