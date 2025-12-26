
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00019117          	auipc	sp,0x19
    80000004:	f5010113          	addi	sp,sp,-176 # 80018f50 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	689040ef          	jal	80004e9e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	e3a9                	bnez	a5,8000006e <kfree+0x52>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00021797          	auipc	a5,0x21
    80000034:	02078793          	addi	a5,a5,32 # 80021050 <end>
    80000038:	02f56b63          	bltu	a0,a5,8000006e <kfree+0x52>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	02f57763          	bgeu	a0,a5,8000006e <kfree+0x52>
  memset(pa, 1, PGSIZE);
#endif
  
  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000044:	00008917          	auipc	s2,0x8
    80000048:	adc90913          	addi	s2,s2,-1316 # 80007b20 <kmem>
    8000004c:	854a                	mv	a0,s2
    8000004e:	0b3050ef          	jal	80005900 <acquire>
  r->next = kmem.freelist;
    80000052:	01893783          	ld	a5,24(s2)
    80000056:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000058:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000005c:	854a                	mv	a0,s2
    8000005e:	13b050ef          	jal	80005998 <release>
}
    80000062:	60e2                	ld	ra,24(sp)
    80000064:	6442                	ld	s0,16(sp)
    80000066:	64a2                	ld	s1,8(sp)
    80000068:	6902                	ld	s2,0(sp)
    8000006a:	6105                	addi	sp,sp,32
    8000006c:	8082                	ret
    panic("kfree");
    8000006e:	00007517          	auipc	a0,0x7
    80000072:	f9250513          	addi	a0,a0,-110 # 80007000 <etext>
    80000076:	55c050ef          	jal	800055d2 <panic>

000000008000007a <freerange>:
{
    8000007a:	7179                	addi	sp,sp,-48
    8000007c:	f406                	sd	ra,40(sp)
    8000007e:	f022                	sd	s0,32(sp)
    80000080:	ec26                	sd	s1,24(sp)
    80000082:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000084:	6785                	lui	a5,0x1
    80000086:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    8000008a:	00e504b3          	add	s1,a0,a4
    8000008e:	777d                	lui	a4,0xfffff
    80000090:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    80000092:	94be                	add	s1,s1,a5
    80000094:	0295e263          	bltu	a1,s1,800000b8 <freerange+0x3e>
    80000098:	e84a                	sd	s2,16(sp)
    8000009a:	e44e                	sd	s3,8(sp)
    8000009c:	e052                	sd	s4,0(sp)
    8000009e:	892e                	mv	s2,a1
    kfree(p);
    800000a0:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000a2:	6985                	lui	s3,0x1
    kfree(p);
    800000a4:	01448533          	add	a0,s1,s4
    800000a8:	f75ff0ef          	jal	8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    800000ac:	94ce                	add	s1,s1,s3
    800000ae:	fe997be3          	bgeu	s2,s1,800000a4 <freerange+0x2a>
    800000b2:	6942                	ld	s2,16(sp)
    800000b4:	69a2                	ld	s3,8(sp)
    800000b6:	6a02                	ld	s4,0(sp)
}
    800000b8:	70a2                	ld	ra,40(sp)
    800000ba:	7402                	ld	s0,32(sp)
    800000bc:	64e2                	ld	s1,24(sp)
    800000be:	6145                	addi	sp,sp,48
    800000c0:	8082                	ret

00000000800000c2 <kinit>:
{
    800000c2:	1141                	addi	sp,sp,-16
    800000c4:	e406                	sd	ra,8(sp)
    800000c6:	e022                	sd	s0,0(sp)
    800000c8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000ca:	00007597          	auipc	a1,0x7
    800000ce:	f4658593          	addi	a1,a1,-186 # 80007010 <etext+0x10>
    800000d2:	00008517          	auipc	a0,0x8
    800000d6:	a4e50513          	addi	a0,a0,-1458 # 80007b20 <kmem>
    800000da:	7a6050ef          	jal	80005880 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000de:	45c5                	li	a1,17
    800000e0:	05ee                	slli	a1,a1,0x1b
    800000e2:	00021517          	auipc	a0,0x21
    800000e6:	f6e50513          	addi	a0,a0,-146 # 80021050 <end>
    800000ea:	f91ff0ef          	jal	8000007a <freerange>
}
    800000ee:	60a2                	ld	ra,8(sp)
    800000f0:	6402                	ld	s0,0(sp)
    800000f2:	0141                	addi	sp,sp,16
    800000f4:	8082                	ret

00000000800000f6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    800000f6:	1101                	addi	sp,sp,-32
    800000f8:	ec06                	sd	ra,24(sp)
    800000fa:	e822                	sd	s0,16(sp)
    800000fc:	e426                	sd	s1,8(sp)
    800000fe:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000100:	00008497          	auipc	s1,0x8
    80000104:	a2048493          	addi	s1,s1,-1504 # 80007b20 <kmem>
    80000108:	8526                	mv	a0,s1
    8000010a:	7f6050ef          	jal	80005900 <acquire>
  r = kmem.freelist;
    8000010e:	6c84                	ld	s1,24(s1)
  if(r) {
    80000110:	c491                	beqz	s1,8000011c <kalloc+0x26>
    kmem.freelist = r->next;
    80000112:	609c                	ld	a5,0(s1)
    80000114:	00008717          	auipc	a4,0x8
    80000118:	a2f73223          	sd	a5,-1500(a4) # 80007b38 <kmem+0x18>
  }
  release(&kmem.lock);
    8000011c:	00008517          	auipc	a0,0x8
    80000120:	a0450513          	addi	a0,a0,-1532 # 80007b20 <kmem>
    80000124:	075050ef          	jal	80005998 <release>
#ifndef LAB_SYSCALL
  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
#endif
  return (void*)r;
}
    80000128:	8526                	mv	a0,s1
    8000012a:	60e2                	ld	ra,24(sp)
    8000012c:	6442                	ld	s0,16(sp)
    8000012e:	64a2                	ld	s1,8(sp)
    80000130:	6105                	addi	sp,sp,32
    80000132:	8082                	ret

0000000080000134 <kcollect_free>:

uint64
kcollect_free(void)
{
    80000134:	1101                	addi	sp,sp,-32
    80000136:	ec06                	sd	ra,24(sp)
    80000138:	e822                	sd	s0,16(sp)
    8000013a:	e426                	sd	s1,8(sp)
    8000013c:	1000                	addi	s0,sp,32
  struct run *r;
  uint64 count = 0;

  acquire(&kmem.lock); 
    8000013e:	00008497          	auipc	s1,0x8
    80000142:	9e248493          	addi	s1,s1,-1566 # 80007b20 <kmem>
    80000146:	8526                	mv	a0,s1
    80000148:	7b8050ef          	jal	80005900 <acquire>
  r = kmem.freelist;
    8000014c:	6c9c                	ld	a5,24(s1)
  while(r){
    8000014e:	c395                	beqz	a5,80000172 <kcollect_free+0x3e>
  uint64 count = 0;
    80000150:	4481                	li	s1,0
    count++;
    80000152:	0485                	addi	s1,s1,1
    r = r->next;
    80000154:	639c                	ld	a5,0(a5)
  while(r){
    80000156:	fff5                	bnez	a5,80000152 <kcollect_free+0x1e>
  }
  release(&kmem.lock);
    80000158:	00008517          	auipc	a0,0x8
    8000015c:	9c850513          	addi	a0,a0,-1592 # 80007b20 <kmem>
    80000160:	039050ef          	jal	80005998 <release>

  return count * PGSIZE; // Số trang * 4096 bytes
    80000164:	00c49513          	slli	a0,s1,0xc
    80000168:	60e2                	ld	ra,24(sp)
    8000016a:	6442                	ld	s0,16(sp)
    8000016c:	64a2                	ld	s1,8(sp)
    8000016e:	6105                	addi	sp,sp,32
    80000170:	8082                	ret
  uint64 count = 0;
    80000172:	4481                	li	s1,0
    80000174:	b7d5                	j	80000158 <kcollect_free+0x24>

0000000080000176 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000176:	1141                	addi	sp,sp,-16
    80000178:	e422                	sd	s0,8(sp)
    8000017a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    8000017c:	ca19                	beqz	a2,80000192 <memset+0x1c>
    8000017e:	87aa                	mv	a5,a0
    80000180:	1602                	slli	a2,a2,0x20
    80000182:	9201                	srli	a2,a2,0x20
    80000184:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000188:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    8000018c:	0785                	addi	a5,a5,1
    8000018e:	fee79de3          	bne	a5,a4,80000188 <memset+0x12>
  }
  return dst;
}
    80000192:	6422                	ld	s0,8(sp)
    80000194:	0141                	addi	sp,sp,16
    80000196:	8082                	ret

0000000080000198 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000198:	1141                	addi	sp,sp,-16
    8000019a:	e422                	sd	s0,8(sp)
    8000019c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    8000019e:	ca05                	beqz	a2,800001ce <memcmp+0x36>
    800001a0:	fff6069b          	addiw	a3,a2,-1
    800001a4:	1682                	slli	a3,a3,0x20
    800001a6:	9281                	srli	a3,a3,0x20
    800001a8:	0685                	addi	a3,a3,1
    800001aa:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001ac:	00054783          	lbu	a5,0(a0)
    800001b0:	0005c703          	lbu	a4,0(a1)
    800001b4:	00e79863          	bne	a5,a4,800001c4 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800001b8:	0505                	addi	a0,a0,1
    800001ba:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001bc:	fed518e3          	bne	a0,a3,800001ac <memcmp+0x14>
  }

  return 0;
    800001c0:	4501                	li	a0,0
    800001c2:	a019                	j	800001c8 <memcmp+0x30>
      return *s1 - *s2;
    800001c4:	40e7853b          	subw	a0,a5,a4
}
    800001c8:	6422                	ld	s0,8(sp)
    800001ca:	0141                	addi	sp,sp,16
    800001cc:	8082                	ret
  return 0;
    800001ce:	4501                	li	a0,0
    800001d0:	bfe5                	j	800001c8 <memcmp+0x30>

00000000800001d2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001d2:	1141                	addi	sp,sp,-16
    800001d4:	e422                	sd	s0,8(sp)
    800001d6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001d8:	c205                	beqz	a2,800001f8 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001da:	02a5e263          	bltu	a1,a0,800001fe <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001de:	1602                	slli	a2,a2,0x20
    800001e0:	9201                	srli	a2,a2,0x20
    800001e2:	00c587b3          	add	a5,a1,a2
{
    800001e6:	872a                	mv	a4,a0
      *d++ = *s++;
    800001e8:	0585                	addi	a1,a1,1
    800001ea:	0705                	addi	a4,a4,1
    800001ec:	fff5c683          	lbu	a3,-1(a1)
    800001f0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001f4:	feb79ae3          	bne	a5,a1,800001e8 <memmove+0x16>

  return dst;
}
    800001f8:	6422                	ld	s0,8(sp)
    800001fa:	0141                	addi	sp,sp,16
    800001fc:	8082                	ret
  if(s < d && s + n > d){
    800001fe:	02061693          	slli	a3,a2,0x20
    80000202:	9281                	srli	a3,a3,0x20
    80000204:	00d58733          	add	a4,a1,a3
    80000208:	fce57be3          	bgeu	a0,a4,800001de <memmove+0xc>
    d += n;
    8000020c:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000020e:	fff6079b          	addiw	a5,a2,-1
    80000212:	1782                	slli	a5,a5,0x20
    80000214:	9381                	srli	a5,a5,0x20
    80000216:	fff7c793          	not	a5,a5
    8000021a:	97ba                	add	a5,a5,a4
      *--d = *--s;
    8000021c:	177d                	addi	a4,a4,-1
    8000021e:	16fd                	addi	a3,a3,-1
    80000220:	00074603          	lbu	a2,0(a4)
    80000224:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000228:	fef71ae3          	bne	a4,a5,8000021c <memmove+0x4a>
    8000022c:	b7f1                	j	800001f8 <memmove+0x26>

000000008000022e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000022e:	1141                	addi	sp,sp,-16
    80000230:	e406                	sd	ra,8(sp)
    80000232:	e022                	sd	s0,0(sp)
    80000234:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000236:	f9dff0ef          	jal	800001d2 <memmove>
}
    8000023a:	60a2                	ld	ra,8(sp)
    8000023c:	6402                	ld	s0,0(sp)
    8000023e:	0141                	addi	sp,sp,16
    80000240:	8082                	ret

0000000080000242 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000242:	1141                	addi	sp,sp,-16
    80000244:	e422                	sd	s0,8(sp)
    80000246:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000248:	ce11                	beqz	a2,80000264 <strncmp+0x22>
    8000024a:	00054783          	lbu	a5,0(a0)
    8000024e:	cf89                	beqz	a5,80000268 <strncmp+0x26>
    80000250:	0005c703          	lbu	a4,0(a1)
    80000254:	00f71a63          	bne	a4,a5,80000268 <strncmp+0x26>
    n--, p++, q++;
    80000258:	367d                	addiw	a2,a2,-1
    8000025a:	0505                	addi	a0,a0,1
    8000025c:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000025e:	f675                	bnez	a2,8000024a <strncmp+0x8>
  if(n == 0)
    return 0;
    80000260:	4501                	li	a0,0
    80000262:	a801                	j	80000272 <strncmp+0x30>
    80000264:	4501                	li	a0,0
    80000266:	a031                	j	80000272 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000268:	00054503          	lbu	a0,0(a0)
    8000026c:	0005c783          	lbu	a5,0(a1)
    80000270:	9d1d                	subw	a0,a0,a5
}
    80000272:	6422                	ld	s0,8(sp)
    80000274:	0141                	addi	sp,sp,16
    80000276:	8082                	ret

0000000080000278 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e422                	sd	s0,8(sp)
    8000027c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000027e:	87aa                	mv	a5,a0
    80000280:	86b2                	mv	a3,a2
    80000282:	367d                	addiw	a2,a2,-1
    80000284:	02d05563          	blez	a3,800002ae <strncpy+0x36>
    80000288:	0785                	addi	a5,a5,1
    8000028a:	0005c703          	lbu	a4,0(a1)
    8000028e:	fee78fa3          	sb	a4,-1(a5)
    80000292:	0585                	addi	a1,a1,1
    80000294:	f775                	bnez	a4,80000280 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000296:	873e                	mv	a4,a5
    80000298:	9fb5                	addw	a5,a5,a3
    8000029a:	37fd                	addiw	a5,a5,-1
    8000029c:	00c05963          	blez	a2,800002ae <strncpy+0x36>
    *s++ = 0;
    800002a0:	0705                	addi	a4,a4,1
    800002a2:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    800002a6:	40e786bb          	subw	a3,a5,a4
    800002aa:	fed04be3          	bgtz	a3,800002a0 <strncpy+0x28>
  return os;
}
    800002ae:	6422                	ld	s0,8(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret

00000000800002b4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002b4:	1141                	addi	sp,sp,-16
    800002b6:	e422                	sd	s0,8(sp)
    800002b8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002ba:	02c05363          	blez	a2,800002e0 <safestrcpy+0x2c>
    800002be:	fff6069b          	addiw	a3,a2,-1
    800002c2:	1682                	slli	a3,a3,0x20
    800002c4:	9281                	srli	a3,a3,0x20
    800002c6:	96ae                	add	a3,a3,a1
    800002c8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002ca:	00d58963          	beq	a1,a3,800002dc <safestrcpy+0x28>
    800002ce:	0585                	addi	a1,a1,1
    800002d0:	0785                	addi	a5,a5,1
    800002d2:	fff5c703          	lbu	a4,-1(a1)
    800002d6:	fee78fa3          	sb	a4,-1(a5)
    800002da:	fb65                	bnez	a4,800002ca <safestrcpy+0x16>
    ;
  *s = 0;
    800002dc:	00078023          	sb	zero,0(a5)
  return os;
}
    800002e0:	6422                	ld	s0,8(sp)
    800002e2:	0141                	addi	sp,sp,16
    800002e4:	8082                	ret

00000000800002e6 <strlen>:

int
strlen(const char *s)
{
    800002e6:	1141                	addi	sp,sp,-16
    800002e8:	e422                	sd	s0,8(sp)
    800002ea:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002ec:	00054783          	lbu	a5,0(a0)
    800002f0:	cf91                	beqz	a5,8000030c <strlen+0x26>
    800002f2:	0505                	addi	a0,a0,1
    800002f4:	87aa                	mv	a5,a0
    800002f6:	86be                	mv	a3,a5
    800002f8:	0785                	addi	a5,a5,1
    800002fa:	fff7c703          	lbu	a4,-1(a5)
    800002fe:	ff65                	bnez	a4,800002f6 <strlen+0x10>
    80000300:	40a6853b          	subw	a0,a3,a0
    80000304:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000306:	6422                	ld	s0,8(sp)
    80000308:	0141                	addi	sp,sp,16
    8000030a:	8082                	ret
  for(n = 0; s[n]; n++)
    8000030c:	4501                	li	a0,0
    8000030e:	bfe5                	j	80000306 <strlen+0x20>

0000000080000310 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000310:	1141                	addi	sp,sp,-16
    80000312:	e406                	sd	ra,8(sp)
    80000314:	e022                	sd	s0,0(sp)
    80000316:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000318:	255000ef          	jal	80000d6c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000031c:	00007717          	auipc	a4,0x7
    80000320:	7d470713          	addi	a4,a4,2004 # 80007af0 <started>
  if(cpuid() == 0){
    80000324:	c51d                	beqz	a0,80000352 <main+0x42>
    while(started == 0)
    80000326:	431c                	lw	a5,0(a4)
    80000328:	2781                	sext.w	a5,a5
    8000032a:	dff5                	beqz	a5,80000326 <main+0x16>
      ;
    __sync_synchronize();
    8000032c:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000330:	23d000ef          	jal	80000d6c <cpuid>
    80000334:	85aa                	mv	a1,a0
    80000336:	00007517          	auipc	a0,0x7
    8000033a:	d0250513          	addi	a0,a0,-766 # 80007038 <etext+0x38>
    8000033e:	7c3040ef          	jal	80005300 <printf>
    kvminithart();    // turn on paging
    80000342:	080000ef          	jal	800003c2 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000346:	5ae010ef          	jal	800018f4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000034a:	56e040ef          	jal	800048b8 <plicinithart>
  }

  scheduler();        
    8000034e:	687000ef          	jal	800011d4 <scheduler>
    consoleinit();
    80000352:	6d9040ef          	jal	8000522a <consoleinit>
    printfinit();
    80000356:	2b6050ef          	jal	8000560c <printfinit>
    printf("\n");
    8000035a:	00007517          	auipc	a0,0x7
    8000035e:	cbe50513          	addi	a0,a0,-834 # 80007018 <etext+0x18>
    80000362:	79f040ef          	jal	80005300 <printf>
    printf("xv6 kernel is booting\n");
    80000366:	00007517          	auipc	a0,0x7
    8000036a:	cba50513          	addi	a0,a0,-838 # 80007020 <etext+0x20>
    8000036e:	793040ef          	jal	80005300 <printf>
    printf("\n");
    80000372:	00007517          	auipc	a0,0x7
    80000376:	ca650513          	addi	a0,a0,-858 # 80007018 <etext+0x18>
    8000037a:	787040ef          	jal	80005300 <printf>
    kinit();         // physical page allocator
    8000037e:	d45ff0ef          	jal	800000c2 <kinit>
    kvminit();       // create kernel page table
    80000382:	2ca000ef          	jal	8000064c <kvminit>
    kvminithart();   // turn on paging
    80000386:	03c000ef          	jal	800003c2 <kvminithart>
    procinit();      // process table
    8000038a:	12d000ef          	jal	80000cb6 <procinit>
    trapinit();      // trap vectors
    8000038e:	542010ef          	jal	800018d0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000392:	562010ef          	jal	800018f4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000396:	508040ef          	jal	8000489e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000039a:	51e040ef          	jal	800048b8 <plicinithart>
    binit();         // buffer cache
    8000039e:	4bf010ef          	jal	8000205c <binit>
    iinit();         // inode table
    800003a2:	2b0020ef          	jal	80002652 <iinit>
    fileinit();      // file table
    800003a6:	05c030ef          	jal	80003402 <fileinit>
    virtio_disk_init(); // emulated hard disk
    800003aa:	5fe040ef          	jal	800049a8 <virtio_disk_init>
    userinit();      // first user process
    800003ae:	453000ef          	jal	80001000 <userinit>
    __sync_synchronize();
    800003b2:	0ff0000f          	fence
    started = 1;
    800003b6:	4785                	li	a5,1
    800003b8:	00007717          	auipc	a4,0x7
    800003bc:	72f72c23          	sw	a5,1848(a4) # 80007af0 <started>
    800003c0:	b779                	j	8000034e <main+0x3e>

00000000800003c2 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800003c2:	1141                	addi	sp,sp,-16
    800003c4:	e422                	sd	s0,8(sp)
    800003c6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800003c8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    800003cc:	00007797          	auipc	a5,0x7
    800003d0:	72c7b783          	ld	a5,1836(a5) # 80007af8 <kernel_pagetable>
    800003d4:	83b1                	srli	a5,a5,0xc
    800003d6:	577d                	li	a4,-1
    800003d8:	177e                	slli	a4,a4,0x3f
    800003da:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800003dc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    800003e0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    800003e4:	6422                	ld	s0,8(sp)
    800003e6:	0141                	addi	sp,sp,16
    800003e8:	8082                	ret

00000000800003ea <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800003ea:	7139                	addi	sp,sp,-64
    800003ec:	fc06                	sd	ra,56(sp)
    800003ee:	f822                	sd	s0,48(sp)
    800003f0:	f426                	sd	s1,40(sp)
    800003f2:	f04a                	sd	s2,32(sp)
    800003f4:	ec4e                	sd	s3,24(sp)
    800003f6:	e852                	sd	s4,16(sp)
    800003f8:	e456                	sd	s5,8(sp)
    800003fa:	e05a                	sd	s6,0(sp)
    800003fc:	0080                	addi	s0,sp,64
    800003fe:	84aa                	mv	s1,a0
    80000400:	89ae                	mv	s3,a1
    80000402:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000404:	57fd                	li	a5,-1
    80000406:	83e9                	srli	a5,a5,0x1a
    80000408:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000040a:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000040c:	02b7fc63          	bgeu	a5,a1,80000444 <walk+0x5a>
    panic("walk");
    80000410:	00007517          	auipc	a0,0x7
    80000414:	c4050513          	addi	a0,a0,-960 # 80007050 <etext+0x50>
    80000418:	1ba050ef          	jal	800055d2 <panic>
      if(PTE_LEAF(*pte)) {
        return pte;
      }
#endif
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000041c:	060a8263          	beqz	s5,80000480 <walk+0x96>
    80000420:	cd7ff0ef          	jal	800000f6 <kalloc>
    80000424:	84aa                	mv	s1,a0
    80000426:	c139                	beqz	a0,8000046c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000428:	6605                	lui	a2,0x1
    8000042a:	4581                	li	a1,0
    8000042c:	d4bff0ef          	jal	80000176 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000430:	00c4d793          	srli	a5,s1,0xc
    80000434:	07aa                	slli	a5,a5,0xa
    80000436:	0017e793          	ori	a5,a5,1
    8000043a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000043e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffddfa7>
    80000440:	036a0063          	beq	s4,s6,80000460 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000444:	0149d933          	srl	s2,s3,s4
    80000448:	1ff97913          	andi	s2,s2,511
    8000044c:	090e                	slli	s2,s2,0x3
    8000044e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000450:	00093483          	ld	s1,0(s2)
    80000454:	0014f793          	andi	a5,s1,1
    80000458:	d3f1                	beqz	a5,8000041c <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000045a:	80a9                	srli	s1,s1,0xa
    8000045c:	04b2                	slli	s1,s1,0xc
    8000045e:	b7c5                	j	8000043e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000460:	00c9d513          	srli	a0,s3,0xc
    80000464:	1ff57513          	andi	a0,a0,511
    80000468:	050e                	slli	a0,a0,0x3
    8000046a:	9526                	add	a0,a0,s1
}
    8000046c:	70e2                	ld	ra,56(sp)
    8000046e:	7442                	ld	s0,48(sp)
    80000470:	74a2                	ld	s1,40(sp)
    80000472:	7902                	ld	s2,32(sp)
    80000474:	69e2                	ld	s3,24(sp)
    80000476:	6a42                	ld	s4,16(sp)
    80000478:	6aa2                	ld	s5,8(sp)
    8000047a:	6b02                	ld	s6,0(sp)
    8000047c:	6121                	addi	sp,sp,64
    8000047e:	8082                	ret
        return 0;
    80000480:	4501                	li	a0,0
    80000482:	b7ed                	j	8000046c <walk+0x82>

0000000080000484 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000484:	57fd                	li	a5,-1
    80000486:	83e9                	srli	a5,a5,0x1a
    80000488:	00b7f463          	bgeu	a5,a1,80000490 <walkaddr+0xc>
    return 0;
    8000048c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000048e:	8082                	ret
{
    80000490:	1141                	addi	sp,sp,-16
    80000492:	e406                	sd	ra,8(sp)
    80000494:	e022                	sd	s0,0(sp)
    80000496:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000498:	4601                	li	a2,0
    8000049a:	f51ff0ef          	jal	800003ea <walk>
  if(pte == 0)
    8000049e:	c105                	beqz	a0,800004be <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800004a0:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800004a2:	0117f693          	andi	a3,a5,17
    800004a6:	4745                	li	a4,17
    return 0;
    800004a8:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800004aa:	00e68663          	beq	a3,a4,800004b6 <walkaddr+0x32>
}
    800004ae:	60a2                	ld	ra,8(sp)
    800004b0:	6402                	ld	s0,0(sp)
    800004b2:	0141                	addi	sp,sp,16
    800004b4:	8082                	ret
  pa = PTE2PA(*pte);
    800004b6:	83a9                	srli	a5,a5,0xa
    800004b8:	00c79513          	slli	a0,a5,0xc
  return pa;
    800004bc:	bfcd                	j	800004ae <walkaddr+0x2a>
    return 0;
    800004be:	4501                	li	a0,0
    800004c0:	b7fd                	j	800004ae <walkaddr+0x2a>

00000000800004c2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800004c2:	715d                	addi	sp,sp,-80
    800004c4:	e486                	sd	ra,72(sp)
    800004c6:	e0a2                	sd	s0,64(sp)
    800004c8:	fc26                	sd	s1,56(sp)
    800004ca:	f84a                	sd	s2,48(sp)
    800004cc:	f44e                	sd	s3,40(sp)
    800004ce:	f052                	sd	s4,32(sp)
    800004d0:	ec56                	sd	s5,24(sp)
    800004d2:	e85a                	sd	s6,16(sp)
    800004d4:	e45e                	sd	s7,8(sp)
    800004d6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800004d8:	03459793          	slli	a5,a1,0x34
    800004dc:	e7a9                	bnez	a5,80000526 <mappages+0x64>
    800004de:	8aaa                	mv	s5,a0
    800004e0:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800004e2:	03461793          	slli	a5,a2,0x34
    800004e6:	e7b1                	bnez	a5,80000532 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    800004e8:	ca39                	beqz	a2,8000053e <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800004ea:	77fd                	lui	a5,0xfffff
    800004ec:	963e                	add	a2,a2,a5
    800004ee:	00b609b3          	add	s3,a2,a1
  a = va;
    800004f2:	892e                	mv	s2,a1
    800004f4:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800004f8:	6b85                	lui	s7,0x1
    800004fa:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    800004fe:	4605                	li	a2,1
    80000500:	85ca                	mv	a1,s2
    80000502:	8556                	mv	a0,s5
    80000504:	ee7ff0ef          	jal	800003ea <walk>
    80000508:	c539                	beqz	a0,80000556 <mappages+0x94>
    if(*pte & PTE_V)
    8000050a:	611c                	ld	a5,0(a0)
    8000050c:	8b85                	andi	a5,a5,1
    8000050e:	ef95                	bnez	a5,8000054a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000510:	80b1                	srli	s1,s1,0xc
    80000512:	04aa                	slli	s1,s1,0xa
    80000514:	0164e4b3          	or	s1,s1,s6
    80000518:	0014e493          	ori	s1,s1,1
    8000051c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000051e:	05390863          	beq	s2,s3,8000056e <mappages+0xac>
    a += PGSIZE;
    80000522:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80000524:	bfd9                	j	800004fa <mappages+0x38>
    panic("mappages: va not aligned");
    80000526:	00007517          	auipc	a0,0x7
    8000052a:	b3250513          	addi	a0,a0,-1230 # 80007058 <etext+0x58>
    8000052e:	0a4050ef          	jal	800055d2 <panic>
    panic("mappages: size not aligned");
    80000532:	00007517          	auipc	a0,0x7
    80000536:	b4650513          	addi	a0,a0,-1210 # 80007078 <etext+0x78>
    8000053a:	098050ef          	jal	800055d2 <panic>
    panic("mappages: size");
    8000053e:	00007517          	auipc	a0,0x7
    80000542:	b5a50513          	addi	a0,a0,-1190 # 80007098 <etext+0x98>
    80000546:	08c050ef          	jal	800055d2 <panic>
      panic("mappages: remap");
    8000054a:	00007517          	auipc	a0,0x7
    8000054e:	b5e50513          	addi	a0,a0,-1186 # 800070a8 <etext+0xa8>
    80000552:	080050ef          	jal	800055d2 <panic>
      return -1;
    80000556:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80000558:	60a6                	ld	ra,72(sp)
    8000055a:	6406                	ld	s0,64(sp)
    8000055c:	74e2                	ld	s1,56(sp)
    8000055e:	7942                	ld	s2,48(sp)
    80000560:	79a2                	ld	s3,40(sp)
    80000562:	7a02                	ld	s4,32(sp)
    80000564:	6ae2                	ld	s5,24(sp)
    80000566:	6b42                	ld	s6,16(sp)
    80000568:	6ba2                	ld	s7,8(sp)
    8000056a:	6161                	addi	sp,sp,80
    8000056c:	8082                	ret
  return 0;
    8000056e:	4501                	li	a0,0
    80000570:	b7e5                	j	80000558 <mappages+0x96>

0000000080000572 <kvmmap>:
{
    80000572:	1141                	addi	sp,sp,-16
    80000574:	e406                	sd	ra,8(sp)
    80000576:	e022                	sd	s0,0(sp)
    80000578:	0800                	addi	s0,sp,16
    8000057a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000057c:	86b2                	mv	a3,a2
    8000057e:	863e                	mv	a2,a5
    80000580:	f43ff0ef          	jal	800004c2 <mappages>
    80000584:	e509                	bnez	a0,8000058e <kvmmap+0x1c>
}
    80000586:	60a2                	ld	ra,8(sp)
    80000588:	6402                	ld	s0,0(sp)
    8000058a:	0141                	addi	sp,sp,16
    8000058c:	8082                	ret
    panic("kvmmap");
    8000058e:	00007517          	auipc	a0,0x7
    80000592:	b2a50513          	addi	a0,a0,-1238 # 800070b8 <etext+0xb8>
    80000596:	03c050ef          	jal	800055d2 <panic>

000000008000059a <kvmmake>:
{
    8000059a:	1101                	addi	sp,sp,-32
    8000059c:	ec06                	sd	ra,24(sp)
    8000059e:	e822                	sd	s0,16(sp)
    800005a0:	e426                	sd	s1,8(sp)
    800005a2:	e04a                	sd	s2,0(sp)
    800005a4:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800005a6:	b51ff0ef          	jal	800000f6 <kalloc>
    800005aa:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800005ac:	6605                	lui	a2,0x1
    800005ae:	4581                	li	a1,0
    800005b0:	bc7ff0ef          	jal	80000176 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800005b4:	4719                	li	a4,6
    800005b6:	6685                	lui	a3,0x1
    800005b8:	10000637          	lui	a2,0x10000
    800005bc:	100005b7          	lui	a1,0x10000
    800005c0:	8526                	mv	a0,s1
    800005c2:	fb1ff0ef          	jal	80000572 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800005c6:	4719                	li	a4,6
    800005c8:	6685                	lui	a3,0x1
    800005ca:	10001637          	lui	a2,0x10001
    800005ce:	100015b7          	lui	a1,0x10001
    800005d2:	8526                	mv	a0,s1
    800005d4:	f9fff0ef          	jal	80000572 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800005d8:	4719                	li	a4,6
    800005da:	040006b7          	lui	a3,0x4000
    800005de:	0c000637          	lui	a2,0xc000
    800005e2:	0c0005b7          	lui	a1,0xc000
    800005e6:	8526                	mv	a0,s1
    800005e8:	f8bff0ef          	jal	80000572 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800005ec:	00007917          	auipc	s2,0x7
    800005f0:	a1490913          	addi	s2,s2,-1516 # 80007000 <etext>
    800005f4:	4729                	li	a4,10
    800005f6:	80007697          	auipc	a3,0x80007
    800005fa:	a0a68693          	addi	a3,a3,-1526 # 7000 <_entry-0x7fff9000>
    800005fe:	4605                	li	a2,1
    80000600:	067e                	slli	a2,a2,0x1f
    80000602:	85b2                	mv	a1,a2
    80000604:	8526                	mv	a0,s1
    80000606:	f6dff0ef          	jal	80000572 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000060a:	46c5                	li	a3,17
    8000060c:	06ee                	slli	a3,a3,0x1b
    8000060e:	4719                	li	a4,6
    80000610:	412686b3          	sub	a3,a3,s2
    80000614:	864a                	mv	a2,s2
    80000616:	85ca                	mv	a1,s2
    80000618:	8526                	mv	a0,s1
    8000061a:	f59ff0ef          	jal	80000572 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000061e:	4729                	li	a4,10
    80000620:	6685                	lui	a3,0x1
    80000622:	00006617          	auipc	a2,0x6
    80000626:	9de60613          	addi	a2,a2,-1570 # 80006000 <_trampoline>
    8000062a:	040005b7          	lui	a1,0x4000
    8000062e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000630:	05b2                	slli	a1,a1,0xc
    80000632:	8526                	mv	a0,s1
    80000634:	f3fff0ef          	jal	80000572 <kvmmap>
  proc_mapstacks(kpgtbl);
    80000638:	8526                	mv	a0,s1
    8000063a:	5e4000ef          	jal	80000c1e <proc_mapstacks>
}
    8000063e:	8526                	mv	a0,s1
    80000640:	60e2                	ld	ra,24(sp)
    80000642:	6442                	ld	s0,16(sp)
    80000644:	64a2                	ld	s1,8(sp)
    80000646:	6902                	ld	s2,0(sp)
    80000648:	6105                	addi	sp,sp,32
    8000064a:	8082                	ret

000000008000064c <kvminit>:
{
    8000064c:	1141                	addi	sp,sp,-16
    8000064e:	e406                	sd	ra,8(sp)
    80000650:	e022                	sd	s0,0(sp)
    80000652:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000654:	f47ff0ef          	jal	8000059a <kvmmake>
    80000658:	00007797          	auipc	a5,0x7
    8000065c:	4aa7b023          	sd	a0,1184(a5) # 80007af8 <kernel_pagetable>
}
    80000660:	60a2                	ld	ra,8(sp)
    80000662:	6402                	ld	s0,0(sp)
    80000664:	0141                	addi	sp,sp,16
    80000666:	8082                	ret

0000000080000668 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000668:	715d                	addi	sp,sp,-80
    8000066a:	e486                	sd	ra,72(sp)
    8000066c:	e0a2                	sd	s0,64(sp)
    8000066e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;
  int sz;

  if((va % PGSIZE) != 0)
    80000670:	03459793          	slli	a5,a1,0x34
    80000674:	e39d                	bnez	a5,8000069a <uvmunmap+0x32>
    80000676:	f84a                	sd	s2,48(sp)
    80000678:	f44e                	sd	s3,40(sp)
    8000067a:	f052                	sd	s4,32(sp)
    8000067c:	ec56                	sd	s5,24(sp)
    8000067e:	e85a                	sd	s6,16(sp)
    80000680:	e45e                	sd	s7,8(sp)
    80000682:	8a2a                	mv	s4,a0
    80000684:	892e                	mv	s2,a1
    80000686:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += sz){
    80000688:	0632                	slli	a2,a2,0xc
    8000068a:	00b609b3          	add	s3,a2,a1
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0) {
      printf("va=%ld pte=%ld\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if(PTE_FLAGS(*pte) == PTE_V)
    8000068e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += sz){
    80000690:	6b05                	lui	s6,0x1
    80000692:	0935f763          	bgeu	a1,s3,80000720 <uvmunmap+0xb8>
    80000696:	fc26                	sd	s1,56(sp)
    80000698:	a8a1                	j	800006f0 <uvmunmap+0x88>
    8000069a:	fc26                	sd	s1,56(sp)
    8000069c:	f84a                	sd	s2,48(sp)
    8000069e:	f44e                	sd	s3,40(sp)
    800006a0:	f052                	sd	s4,32(sp)
    800006a2:	ec56                	sd	s5,24(sp)
    800006a4:	e85a                	sd	s6,16(sp)
    800006a6:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800006a8:	00007517          	auipc	a0,0x7
    800006ac:	a1850513          	addi	a0,a0,-1512 # 800070c0 <etext+0xc0>
    800006b0:	723040ef          	jal	800055d2 <panic>
      panic("uvmunmap: walk");
    800006b4:	00007517          	auipc	a0,0x7
    800006b8:	a2450513          	addi	a0,a0,-1500 # 800070d8 <etext+0xd8>
    800006bc:	717040ef          	jal	800055d2 <panic>
      printf("va=%ld pte=%ld\n", a, *pte);
    800006c0:	85ca                	mv	a1,s2
    800006c2:	00007517          	auipc	a0,0x7
    800006c6:	a2650513          	addi	a0,a0,-1498 # 800070e8 <etext+0xe8>
    800006ca:	437040ef          	jal	80005300 <printf>
      panic("uvmunmap: not mapped");
    800006ce:	00007517          	auipc	a0,0x7
    800006d2:	a2a50513          	addi	a0,a0,-1494 # 800070f8 <etext+0xf8>
    800006d6:	6fd040ef          	jal	800055d2 <panic>
      panic("uvmunmap: not a leaf");
    800006da:	00007517          	auipc	a0,0x7
    800006de:	a3650513          	addi	a0,a0,-1482 # 80007110 <etext+0x110>
    800006e2:	6f1040ef          	jal	800055d2 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800006e6:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += sz){
    800006ea:	995a                	add	s2,s2,s6
    800006ec:	03397963          	bgeu	s2,s3,8000071e <uvmunmap+0xb6>
    if((pte = walk(pagetable, a, 0)) == 0)
    800006f0:	4601                	li	a2,0
    800006f2:	85ca                	mv	a1,s2
    800006f4:	8552                	mv	a0,s4
    800006f6:	cf5ff0ef          	jal	800003ea <walk>
    800006fa:	84aa                	mv	s1,a0
    800006fc:	dd45                	beqz	a0,800006b4 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0) {
    800006fe:	6110                	ld	a2,0(a0)
    80000700:	00167793          	andi	a5,a2,1
    80000704:	dfd5                	beqz	a5,800006c0 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    80000706:	3ff67793          	andi	a5,a2,1023
    8000070a:	fd7788e3          	beq	a5,s7,800006da <uvmunmap+0x72>
    if(do_free){
    8000070e:	fc0a8ce3          	beqz	s5,800006e6 <uvmunmap+0x7e>
      uint64 pa = PTE2PA(*pte);
    80000712:	8229                	srli	a2,a2,0xa
      kfree((void*)pa);
    80000714:	00c61513          	slli	a0,a2,0xc
    80000718:	905ff0ef          	jal	8000001c <kfree>
    8000071c:	b7e9                	j	800006e6 <uvmunmap+0x7e>
    8000071e:	74e2                	ld	s1,56(sp)
    80000720:	7942                	ld	s2,48(sp)
    80000722:	79a2                	ld	s3,40(sp)
    80000724:	7a02                	ld	s4,32(sp)
    80000726:	6ae2                	ld	s5,24(sp)
    80000728:	6b42                	ld	s6,16(sp)
    8000072a:	6ba2                	ld	s7,8(sp)
  }
}
    8000072c:	60a6                	ld	ra,72(sp)
    8000072e:	6406                	ld	s0,64(sp)
    80000730:	6161                	addi	sp,sp,80
    80000732:	8082                	ret

0000000080000734 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000734:	1101                	addi	sp,sp,-32
    80000736:	ec06                	sd	ra,24(sp)
    80000738:	e822                	sd	s0,16(sp)
    8000073a:	e426                	sd	s1,8(sp)
    8000073c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000073e:	9b9ff0ef          	jal	800000f6 <kalloc>
    80000742:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000744:	c509                	beqz	a0,8000074e <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000746:	6605                	lui	a2,0x1
    80000748:	4581                	li	a1,0
    8000074a:	a2dff0ef          	jal	80000176 <memset>
  return pagetable;
}
    8000074e:	8526                	mv	a0,s1
    80000750:	60e2                	ld	ra,24(sp)
    80000752:	6442                	ld	s0,16(sp)
    80000754:	64a2                	ld	s1,8(sp)
    80000756:	6105                	addi	sp,sp,32
    80000758:	8082                	ret

000000008000075a <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000075a:	7179                	addi	sp,sp,-48
    8000075c:	f406                	sd	ra,40(sp)
    8000075e:	f022                	sd	s0,32(sp)
    80000760:	ec26                	sd	s1,24(sp)
    80000762:	e84a                	sd	s2,16(sp)
    80000764:	e44e                	sd	s3,8(sp)
    80000766:	e052                	sd	s4,0(sp)
    80000768:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000076a:	6785                	lui	a5,0x1
    8000076c:	04f67063          	bgeu	a2,a5,800007ac <uvmfirst+0x52>
    80000770:	8a2a                	mv	s4,a0
    80000772:	89ae                	mv	s3,a1
    80000774:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000776:	981ff0ef          	jal	800000f6 <kalloc>
    8000077a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000077c:	6605                	lui	a2,0x1
    8000077e:	4581                	li	a1,0
    80000780:	9f7ff0ef          	jal	80000176 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000784:	4779                	li	a4,30
    80000786:	86ca                	mv	a3,s2
    80000788:	6605                	lui	a2,0x1
    8000078a:	4581                	li	a1,0
    8000078c:	8552                	mv	a0,s4
    8000078e:	d35ff0ef          	jal	800004c2 <mappages>
  memmove(mem, src, sz);
    80000792:	8626                	mv	a2,s1
    80000794:	85ce                	mv	a1,s3
    80000796:	854a                	mv	a0,s2
    80000798:	a3bff0ef          	jal	800001d2 <memmove>
}
    8000079c:	70a2                	ld	ra,40(sp)
    8000079e:	7402                	ld	s0,32(sp)
    800007a0:	64e2                	ld	s1,24(sp)
    800007a2:	6942                	ld	s2,16(sp)
    800007a4:	69a2                	ld	s3,8(sp)
    800007a6:	6a02                	ld	s4,0(sp)
    800007a8:	6145                	addi	sp,sp,48
    800007aa:	8082                	ret
    panic("uvmfirst: more than a page");
    800007ac:	00007517          	auipc	a0,0x7
    800007b0:	97c50513          	addi	a0,a0,-1668 # 80007128 <etext+0x128>
    800007b4:	61f040ef          	jal	800055d2 <panic>

00000000800007b8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800007b8:	1101                	addi	sp,sp,-32
    800007ba:	ec06                	sd	ra,24(sp)
    800007bc:	e822                	sd	s0,16(sp)
    800007be:	e426                	sd	s1,8(sp)
    800007c0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800007c2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800007c4:	00b67d63          	bgeu	a2,a1,800007de <uvmdealloc+0x26>
    800007c8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800007ca:	6785                	lui	a5,0x1
    800007cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007ce:	00f60733          	add	a4,a2,a5
    800007d2:	76fd                	lui	a3,0xfffff
    800007d4:	8f75                	and	a4,a4,a3
    800007d6:	97ae                	add	a5,a5,a1
    800007d8:	8ff5                	and	a5,a5,a3
    800007da:	00f76863          	bltu	a4,a5,800007ea <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800007de:	8526                	mv	a0,s1
    800007e0:	60e2                	ld	ra,24(sp)
    800007e2:	6442                	ld	s0,16(sp)
    800007e4:	64a2                	ld	s1,8(sp)
    800007e6:	6105                	addi	sp,sp,32
    800007e8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800007ea:	8f99                	sub	a5,a5,a4
    800007ec:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800007ee:	4685                	li	a3,1
    800007f0:	0007861b          	sext.w	a2,a5
    800007f4:	85ba                	mv	a1,a4
    800007f6:	e73ff0ef          	jal	80000668 <uvmunmap>
    800007fa:	b7d5                	j	800007de <uvmdealloc+0x26>

00000000800007fc <uvmalloc>:
  if(newsz < oldsz)
    800007fc:	08b66b63          	bltu	a2,a1,80000892 <uvmalloc+0x96>
{
    80000800:	7139                	addi	sp,sp,-64
    80000802:	fc06                	sd	ra,56(sp)
    80000804:	f822                	sd	s0,48(sp)
    80000806:	ec4e                	sd	s3,24(sp)
    80000808:	e852                	sd	s4,16(sp)
    8000080a:	e456                	sd	s5,8(sp)
    8000080c:	0080                	addi	s0,sp,64
    8000080e:	8aaa                	mv	s5,a0
    80000810:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000812:	6785                	lui	a5,0x1
    80000814:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000816:	95be                	add	a1,a1,a5
    80000818:	77fd                	lui	a5,0xfffff
    8000081a:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += sz){
    8000081e:	06c9fc63          	bgeu	s3,a2,80000896 <uvmalloc+0x9a>
    80000822:	f426                	sd	s1,40(sp)
    80000824:	f04a                	sd	s2,32(sp)
    80000826:	e05a                	sd	s6,0(sp)
    80000828:	894e                	mv	s2,s3
    if(mappages(pagetable, a, sz, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000082a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000082e:	8c9ff0ef          	jal	800000f6 <kalloc>
    80000832:	84aa                	mv	s1,a0
    if(mem == 0){
    80000834:	c115                	beqz	a0,80000858 <uvmalloc+0x5c>
    if(mappages(pagetable, a, sz, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000836:	875a                	mv	a4,s6
    80000838:	86aa                	mv	a3,a0
    8000083a:	6605                	lui	a2,0x1
    8000083c:	85ca                	mv	a1,s2
    8000083e:	8556                	mv	a0,s5
    80000840:	c83ff0ef          	jal	800004c2 <mappages>
    80000844:	e915                	bnez	a0,80000878 <uvmalloc+0x7c>
  for(a = oldsz; a < newsz; a += sz){
    80000846:	6785                	lui	a5,0x1
    80000848:	993e                	add	s2,s2,a5
    8000084a:	ff4962e3          	bltu	s2,s4,8000082e <uvmalloc+0x32>
  return newsz;
    8000084e:	8552                	mv	a0,s4
    80000850:	74a2                	ld	s1,40(sp)
    80000852:	7902                	ld	s2,32(sp)
    80000854:	6b02                	ld	s6,0(sp)
    80000856:	a811                	j	8000086a <uvmalloc+0x6e>
      uvmdealloc(pagetable, a, oldsz);
    80000858:	864e                	mv	a2,s3
    8000085a:	85ca                	mv	a1,s2
    8000085c:	8556                	mv	a0,s5
    8000085e:	f5bff0ef          	jal	800007b8 <uvmdealloc>
      return 0;
    80000862:	4501                	li	a0,0
    80000864:	74a2                	ld	s1,40(sp)
    80000866:	7902                	ld	s2,32(sp)
    80000868:	6b02                	ld	s6,0(sp)
}
    8000086a:	70e2                	ld	ra,56(sp)
    8000086c:	7442                	ld	s0,48(sp)
    8000086e:	69e2                	ld	s3,24(sp)
    80000870:	6a42                	ld	s4,16(sp)
    80000872:	6aa2                	ld	s5,8(sp)
    80000874:	6121                	addi	sp,sp,64
    80000876:	8082                	ret
      kfree(mem);
    80000878:	8526                	mv	a0,s1
    8000087a:	fa2ff0ef          	jal	8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000087e:	864e                	mv	a2,s3
    80000880:	85ca                	mv	a1,s2
    80000882:	8556                	mv	a0,s5
    80000884:	f35ff0ef          	jal	800007b8 <uvmdealloc>
      return 0;
    80000888:	4501                	li	a0,0
    8000088a:	74a2                	ld	s1,40(sp)
    8000088c:	7902                	ld	s2,32(sp)
    8000088e:	6b02                	ld	s6,0(sp)
    80000890:	bfe9                	j	8000086a <uvmalloc+0x6e>
    return oldsz;
    80000892:	852e                	mv	a0,a1
}
    80000894:	8082                	ret
  return newsz;
    80000896:	8532                	mv	a0,a2
    80000898:	bfc9                	j	8000086a <uvmalloc+0x6e>

000000008000089a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000089a:	7179                	addi	sp,sp,-48
    8000089c:	f406                	sd	ra,40(sp)
    8000089e:	f022                	sd	s0,32(sp)
    800008a0:	ec26                	sd	s1,24(sp)
    800008a2:	e84a                	sd	s2,16(sp)
    800008a4:	e44e                	sd	s3,8(sp)
    800008a6:	e052                	sd	s4,0(sp)
    800008a8:	1800                	addi	s0,sp,48
    800008aa:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800008ac:	84aa                	mv	s1,a0
    800008ae:	6905                	lui	s2,0x1
    800008b0:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800008b2:	4985                	li	s3,1
    800008b4:	a819                	j	800008ca <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800008b6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800008b8:	00c79513          	slli	a0,a5,0xc
    800008bc:	fdfff0ef          	jal	8000089a <freewalk>
      pagetable[i] = 0;
    800008c0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800008c4:	04a1                	addi	s1,s1,8
    800008c6:	01248f63          	beq	s1,s2,800008e4 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800008ca:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800008cc:	00f7f713          	andi	a4,a5,15
    800008d0:	ff3703e3          	beq	a4,s3,800008b6 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800008d4:	8b85                	andi	a5,a5,1
    800008d6:	d7fd                	beqz	a5,800008c4 <freewalk+0x2a>
      panic("freewalk: leaf");
    800008d8:	00007517          	auipc	a0,0x7
    800008dc:	87050513          	addi	a0,a0,-1936 # 80007148 <etext+0x148>
    800008e0:	4f3040ef          	jal	800055d2 <panic>
    }
  }
  kfree((void*)pagetable);
    800008e4:	8552                	mv	a0,s4
    800008e6:	f36ff0ef          	jal	8000001c <kfree>
}
    800008ea:	70a2                	ld	ra,40(sp)
    800008ec:	7402                	ld	s0,32(sp)
    800008ee:	64e2                	ld	s1,24(sp)
    800008f0:	6942                	ld	s2,16(sp)
    800008f2:	69a2                	ld	s3,8(sp)
    800008f4:	6a02                	ld	s4,0(sp)
    800008f6:	6145                	addi	sp,sp,48
    800008f8:	8082                	ret

00000000800008fa <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800008fa:	1101                	addi	sp,sp,-32
    800008fc:	ec06                	sd	ra,24(sp)
    800008fe:	e822                	sd	s0,16(sp)
    80000900:	e426                	sd	s1,8(sp)
    80000902:	1000                	addi	s0,sp,32
    80000904:	84aa                	mv	s1,a0
  if(sz > 0)
    80000906:	e989                	bnez	a1,80000918 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000908:	8526                	mv	a0,s1
    8000090a:	f91ff0ef          	jal	8000089a <freewalk>
}
    8000090e:	60e2                	ld	ra,24(sp)
    80000910:	6442                	ld	s0,16(sp)
    80000912:	64a2                	ld	s1,8(sp)
    80000914:	6105                	addi	sp,sp,32
    80000916:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000918:	6785                	lui	a5,0x1
    8000091a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000091c:	95be                	add	a1,a1,a5
    8000091e:	4685                	li	a3,1
    80000920:	00c5d613          	srli	a2,a1,0xc
    80000924:	4581                	li	a1,0
    80000926:	d43ff0ef          	jal	80000668 <uvmunmap>
    8000092a:	bff9                	j	80000908 <uvmfree+0xe>

000000008000092c <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;
  int szinc;

  for(i = 0; i < sz; i += szinc){
    8000092c:	c65d                	beqz	a2,800009da <uvmcopy+0xae>
{
    8000092e:	715d                	addi	sp,sp,-80
    80000930:	e486                	sd	ra,72(sp)
    80000932:	e0a2                	sd	s0,64(sp)
    80000934:	fc26                	sd	s1,56(sp)
    80000936:	f84a                	sd	s2,48(sp)
    80000938:	f44e                	sd	s3,40(sp)
    8000093a:	f052                	sd	s4,32(sp)
    8000093c:	ec56                	sd	s5,24(sp)
    8000093e:	e85a                	sd	s6,16(sp)
    80000940:	e45e                	sd	s7,8(sp)
    80000942:	0880                	addi	s0,sp,80
    80000944:	8b2a                	mv	s6,a0
    80000946:	8aae                	mv	s5,a1
    80000948:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += szinc){
    8000094a:	4981                	li	s3,0
    szinc = PGSIZE;
    szinc = PGSIZE;
    if((pte = walk(old, i, 0)) == 0)
    8000094c:	4601                	li	a2,0
    8000094e:	85ce                	mv	a1,s3
    80000950:	855a                	mv	a0,s6
    80000952:	a99ff0ef          	jal	800003ea <walk>
    80000956:	c121                	beqz	a0,80000996 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000958:	6118                	ld	a4,0(a0)
    8000095a:	00177793          	andi	a5,a4,1
    8000095e:	c3b1                	beqz	a5,800009a2 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000960:	00a75593          	srli	a1,a4,0xa
    80000964:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000968:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000096c:	f8aff0ef          	jal	800000f6 <kalloc>
    80000970:	892a                	mv	s2,a0
    80000972:	c129                	beqz	a0,800009b4 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000974:	6605                	lui	a2,0x1
    80000976:	85de                	mv	a1,s7
    80000978:	85bff0ef          	jal	800001d2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000097c:	8726                	mv	a4,s1
    8000097e:	86ca                	mv	a3,s2
    80000980:	6605                	lui	a2,0x1
    80000982:	85ce                	mv	a1,s3
    80000984:	8556                	mv	a0,s5
    80000986:	b3dff0ef          	jal	800004c2 <mappages>
    8000098a:	e115                	bnez	a0,800009ae <uvmcopy+0x82>
  for(i = 0; i < sz; i += szinc){
    8000098c:	6785                	lui	a5,0x1
    8000098e:	99be                	add	s3,s3,a5
    80000990:	fb49eee3          	bltu	s3,s4,8000094c <uvmcopy+0x20>
    80000994:	a805                	j	800009c4 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80000996:	00006517          	auipc	a0,0x6
    8000099a:	7c250513          	addi	a0,a0,1986 # 80007158 <etext+0x158>
    8000099e:	435040ef          	jal	800055d2 <panic>
      panic("uvmcopy: page not present");
    800009a2:	00006517          	auipc	a0,0x6
    800009a6:	7d650513          	addi	a0,a0,2006 # 80007178 <etext+0x178>
    800009aa:	429040ef          	jal	800055d2 <panic>
      kfree(mem);
    800009ae:	854a                	mv	a0,s2
    800009b0:	e6cff0ef          	jal	8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800009b4:	4685                	li	a3,1
    800009b6:	00c9d613          	srli	a2,s3,0xc
    800009ba:	4581                	li	a1,0
    800009bc:	8556                	mv	a0,s5
    800009be:	cabff0ef          	jal	80000668 <uvmunmap>
  return -1;
    800009c2:	557d                	li	a0,-1
}
    800009c4:	60a6                	ld	ra,72(sp)
    800009c6:	6406                	ld	s0,64(sp)
    800009c8:	74e2                	ld	s1,56(sp)
    800009ca:	7942                	ld	s2,48(sp)
    800009cc:	79a2                	ld	s3,40(sp)
    800009ce:	7a02                	ld	s4,32(sp)
    800009d0:	6ae2                	ld	s5,24(sp)
    800009d2:	6b42                	ld	s6,16(sp)
    800009d4:	6ba2                	ld	s7,8(sp)
    800009d6:	6161                	addi	sp,sp,80
    800009d8:	8082                	ret
  return 0;
    800009da:	4501                	li	a0,0
}
    800009dc:	8082                	ret

00000000800009de <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800009de:	1141                	addi	sp,sp,-16
    800009e0:	e406                	sd	ra,8(sp)
    800009e2:	e022                	sd	s0,0(sp)
    800009e4:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800009e6:	4601                	li	a2,0
    800009e8:	a03ff0ef          	jal	800003ea <walk>
  if(pte == 0)
    800009ec:	c901                	beqz	a0,800009fc <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800009ee:	611c                	ld	a5,0(a0)
    800009f0:	9bbd                	andi	a5,a5,-17
    800009f2:	e11c                	sd	a5,0(a0)
}
    800009f4:	60a2                	ld	ra,8(sp)
    800009f6:	6402                	ld	s0,0(sp)
    800009f8:	0141                	addi	sp,sp,16
    800009fa:	8082                	ret
    panic("uvmclear");
    800009fc:	00006517          	auipc	a0,0x6
    80000a00:	79c50513          	addi	a0,a0,1948 # 80007198 <etext+0x198>
    80000a04:	3cf040ef          	jal	800055d2 <panic>

0000000080000a08 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80000a08:	cac1                	beqz	a3,80000a98 <copyout+0x90>
{
    80000a0a:	711d                	addi	sp,sp,-96
    80000a0c:	ec86                	sd	ra,88(sp)
    80000a0e:	e8a2                	sd	s0,80(sp)
    80000a10:	e4a6                	sd	s1,72(sp)
    80000a12:	fc4e                	sd	s3,56(sp)
    80000a14:	f852                	sd	s4,48(sp)
    80000a16:	f456                	sd	s5,40(sp)
    80000a18:	f05a                	sd	s6,32(sp)
    80000a1a:	1080                	addi	s0,sp,96
    80000a1c:	8b2a                	mv	s6,a0
    80000a1e:	8a2e                	mv	s4,a1
    80000a20:	8ab2                	mv	s5,a2
    80000a22:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000a24:	74fd                	lui	s1,0xfffff
    80000a26:	8ced                	and	s1,s1,a1
    if (va0 >= MAXVA)
    80000a28:	57fd                	li	a5,-1
    80000a2a:	83e9                	srli	a5,a5,0x1a
    80000a2c:	0697e863          	bltu	a5,s1,80000a9c <copyout+0x94>
    80000a30:	e0ca                	sd	s2,64(sp)
    80000a32:	ec5e                	sd	s7,24(sp)
    80000a34:	e862                	sd	s8,16(sp)
    80000a36:	e466                	sd	s9,8(sp)
    80000a38:	6c05                	lui	s8,0x1
    80000a3a:	8bbe                	mv	s7,a5
    80000a3c:	a015                	j	80000a60 <copyout+0x58>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000a3e:	409a04b3          	sub	s1,s4,s1
    80000a42:	0009061b          	sext.w	a2,s2
    80000a46:	85d6                	mv	a1,s5
    80000a48:	9526                	add	a0,a0,s1
    80000a4a:	f88ff0ef          	jal	800001d2 <memmove>

    len -= n;
    80000a4e:	412989b3          	sub	s3,s3,s2
    src += n;
    80000a52:	9aca                	add	s5,s5,s2
  while(len > 0){
    80000a54:	02098c63          	beqz	s3,80000a8c <copyout+0x84>
    if (va0 >= MAXVA)
    80000a58:	059be463          	bltu	s7,s9,80000aa0 <copyout+0x98>
    80000a5c:	84e6                	mv	s1,s9
    80000a5e:	8a66                	mv	s4,s9
    if((pte = walk(pagetable, va0, 0)) == 0) {
    80000a60:	4601                	li	a2,0
    80000a62:	85a6                	mv	a1,s1
    80000a64:	855a                	mv	a0,s6
    80000a66:	985ff0ef          	jal	800003ea <walk>
    80000a6a:	c129                	beqz	a0,80000aac <copyout+0xa4>
    if((*pte & PTE_W) == 0)
    80000a6c:	611c                	ld	a5,0(a0)
    80000a6e:	8b91                	andi	a5,a5,4
    80000a70:	cfa1                	beqz	a5,80000ac8 <copyout+0xc0>
    pa0 = walkaddr(pagetable, va0);
    80000a72:	85a6                	mv	a1,s1
    80000a74:	855a                	mv	a0,s6
    80000a76:	a0fff0ef          	jal	80000484 <walkaddr>
    if(pa0 == 0)
    80000a7a:	cd29                	beqz	a0,80000ad4 <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    80000a7c:	01848cb3          	add	s9,s1,s8
    80000a80:	414c8933          	sub	s2,s9,s4
    if(n > len)
    80000a84:	fb29fde3          	bgeu	s3,s2,80000a3e <copyout+0x36>
    80000a88:	894e                	mv	s2,s3
    80000a8a:	bf55                	j	80000a3e <copyout+0x36>
    dstva = va0 + PGSIZE;
  }
  return 0;
    80000a8c:	4501                	li	a0,0
    80000a8e:	6906                	ld	s2,64(sp)
    80000a90:	6be2                	ld	s7,24(sp)
    80000a92:	6c42                	ld	s8,16(sp)
    80000a94:	6ca2                	ld	s9,8(sp)
    80000a96:	a005                	j	80000ab6 <copyout+0xae>
    80000a98:	4501                	li	a0,0
}
    80000a9a:	8082                	ret
      return -1;
    80000a9c:	557d                	li	a0,-1
    80000a9e:	a821                	j	80000ab6 <copyout+0xae>
    80000aa0:	557d                	li	a0,-1
    80000aa2:	6906                	ld	s2,64(sp)
    80000aa4:	6be2                	ld	s7,24(sp)
    80000aa6:	6c42                	ld	s8,16(sp)
    80000aa8:	6ca2                	ld	s9,8(sp)
    80000aaa:	a031                	j	80000ab6 <copyout+0xae>
      return -1;
    80000aac:	557d                	li	a0,-1
    80000aae:	6906                	ld	s2,64(sp)
    80000ab0:	6be2                	ld	s7,24(sp)
    80000ab2:	6c42                	ld	s8,16(sp)
    80000ab4:	6ca2                	ld	s9,8(sp)
}
    80000ab6:	60e6                	ld	ra,88(sp)
    80000ab8:	6446                	ld	s0,80(sp)
    80000aba:	64a6                	ld	s1,72(sp)
    80000abc:	79e2                	ld	s3,56(sp)
    80000abe:	7a42                	ld	s4,48(sp)
    80000ac0:	7aa2                	ld	s5,40(sp)
    80000ac2:	7b02                	ld	s6,32(sp)
    80000ac4:	6125                	addi	sp,sp,96
    80000ac6:	8082                	ret
      return -1;
    80000ac8:	557d                	li	a0,-1
    80000aca:	6906                	ld	s2,64(sp)
    80000acc:	6be2                	ld	s7,24(sp)
    80000ace:	6c42                	ld	s8,16(sp)
    80000ad0:	6ca2                	ld	s9,8(sp)
    80000ad2:	b7d5                	j	80000ab6 <copyout+0xae>
      return -1;
    80000ad4:	557d                	li	a0,-1
    80000ad6:	6906                	ld	s2,64(sp)
    80000ad8:	6be2                	ld	s7,24(sp)
    80000ada:	6c42                	ld	s8,16(sp)
    80000adc:	6ca2                	ld	s9,8(sp)
    80000ade:	bfe1                	j	80000ab6 <copyout+0xae>

0000000080000ae0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;
  
  while(len > 0){
    80000ae0:	c6a5                	beqz	a3,80000b48 <copyin+0x68>
{
    80000ae2:	715d                	addi	sp,sp,-80
    80000ae4:	e486                	sd	ra,72(sp)
    80000ae6:	e0a2                	sd	s0,64(sp)
    80000ae8:	fc26                	sd	s1,56(sp)
    80000aea:	f84a                	sd	s2,48(sp)
    80000aec:	f44e                	sd	s3,40(sp)
    80000aee:	f052                	sd	s4,32(sp)
    80000af0:	ec56                	sd	s5,24(sp)
    80000af2:	e85a                	sd	s6,16(sp)
    80000af4:	e45e                	sd	s7,8(sp)
    80000af6:	e062                	sd	s8,0(sp)
    80000af8:	0880                	addi	s0,sp,80
    80000afa:	8b2a                	mv	s6,a0
    80000afc:	8a2e                	mv	s4,a1
    80000afe:	8c32                	mv	s8,a2
    80000b00:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000b02:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b04:	6a85                	lui	s5,0x1
    80000b06:	a00d                	j	80000b28 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000b08:	018505b3          	add	a1,a0,s8
    80000b0c:	0004861b          	sext.w	a2,s1
    80000b10:	412585b3          	sub	a1,a1,s2
    80000b14:	8552                	mv	a0,s4
    80000b16:	ebcff0ef          	jal	800001d2 <memmove>

    len -= n;
    80000b1a:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000b1e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000b20:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000b24:	02098063          	beqz	s3,80000b44 <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80000b28:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000b2c:	85ca                	mv	a1,s2
    80000b2e:	855a                	mv	a0,s6
    80000b30:	955ff0ef          	jal	80000484 <walkaddr>
    if(pa0 == 0)
    80000b34:	cd01                	beqz	a0,80000b4c <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    80000b36:	418904b3          	sub	s1,s2,s8
    80000b3a:	94d6                	add	s1,s1,s5
    if(n > len)
    80000b3c:	fc99f6e3          	bgeu	s3,s1,80000b08 <copyin+0x28>
    80000b40:	84ce                	mv	s1,s3
    80000b42:	b7d9                	j	80000b08 <copyin+0x28>
  }
  return 0;
    80000b44:	4501                	li	a0,0
    80000b46:	a021                	j	80000b4e <copyin+0x6e>
    80000b48:	4501                	li	a0,0
}
    80000b4a:	8082                	ret
      return -1;
    80000b4c:	557d                	li	a0,-1
}
    80000b4e:	60a6                	ld	ra,72(sp)
    80000b50:	6406                	ld	s0,64(sp)
    80000b52:	74e2                	ld	s1,56(sp)
    80000b54:	7942                	ld	s2,48(sp)
    80000b56:	79a2                	ld	s3,40(sp)
    80000b58:	7a02                	ld	s4,32(sp)
    80000b5a:	6ae2                	ld	s5,24(sp)
    80000b5c:	6b42                	ld	s6,16(sp)
    80000b5e:	6ba2                	ld	s7,8(sp)
    80000b60:	6c02                	ld	s8,0(sp)
    80000b62:	6161                	addi	sp,sp,80
    80000b64:	8082                	ret

0000000080000b66 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000b66:	c6dd                	beqz	a3,80000c14 <copyinstr+0xae>
{
    80000b68:	715d                	addi	sp,sp,-80
    80000b6a:	e486                	sd	ra,72(sp)
    80000b6c:	e0a2                	sd	s0,64(sp)
    80000b6e:	fc26                	sd	s1,56(sp)
    80000b70:	f84a                	sd	s2,48(sp)
    80000b72:	f44e                	sd	s3,40(sp)
    80000b74:	f052                	sd	s4,32(sp)
    80000b76:	ec56                	sd	s5,24(sp)
    80000b78:	e85a                	sd	s6,16(sp)
    80000b7a:	e45e                	sd	s7,8(sp)
    80000b7c:	0880                	addi	s0,sp,80
    80000b7e:	8a2a                	mv	s4,a0
    80000b80:	8b2e                	mv	s6,a1
    80000b82:	8bb2                	mv	s7,a2
    80000b84:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80000b86:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000b88:	6985                	lui	s3,0x1
    80000b8a:	a825                	j	80000bc2 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000b8c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000b90:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000b92:	37fd                	addiw	a5,a5,-1
    80000b94:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000b98:	60a6                	ld	ra,72(sp)
    80000b9a:	6406                	ld	s0,64(sp)
    80000b9c:	74e2                	ld	s1,56(sp)
    80000b9e:	7942                	ld	s2,48(sp)
    80000ba0:	79a2                	ld	s3,40(sp)
    80000ba2:	7a02                	ld	s4,32(sp)
    80000ba4:	6ae2                	ld	s5,24(sp)
    80000ba6:	6b42                	ld	s6,16(sp)
    80000ba8:	6ba2                	ld	s7,8(sp)
    80000baa:	6161                	addi	sp,sp,80
    80000bac:	8082                	ret
    80000bae:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80000bb2:	9742                	add	a4,a4,a6
      --max;
    80000bb4:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80000bb8:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80000bbc:	04e58463          	beq	a1,a4,80000c04 <copyinstr+0x9e>
{
    80000bc0:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80000bc2:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000bc6:	85a6                	mv	a1,s1
    80000bc8:	8552                	mv	a0,s4
    80000bca:	8bbff0ef          	jal	80000484 <walkaddr>
    if(pa0 == 0)
    80000bce:	cd0d                	beqz	a0,80000c08 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000bd0:	417486b3          	sub	a3,s1,s7
    80000bd4:	96ce                	add	a3,a3,s3
    if(n > max)
    80000bd6:	00d97363          	bgeu	s2,a3,80000bdc <copyinstr+0x76>
    80000bda:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80000bdc:	955e                	add	a0,a0,s7
    80000bde:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80000be0:	c695                	beqz	a3,80000c0c <copyinstr+0xa6>
    80000be2:	87da                	mv	a5,s6
    80000be4:	885a                	mv	a6,s6
      if(*p == '\0'){
    80000be6:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80000bea:	96da                	add	a3,a3,s6
    80000bec:	85be                	mv	a1,a5
      if(*p == '\0'){
    80000bee:	00f60733          	add	a4,a2,a5
    80000bf2:	00074703          	lbu	a4,0(a4)
    80000bf6:	db59                	beqz	a4,80000b8c <copyinstr+0x26>
        *dst = *p;
    80000bf8:	00e78023          	sb	a4,0(a5)
      dst++;
    80000bfc:	0785                	addi	a5,a5,1
    while(n > 0){
    80000bfe:	fed797e3          	bne	a5,a3,80000bec <copyinstr+0x86>
    80000c02:	b775                	j	80000bae <copyinstr+0x48>
    80000c04:	4781                	li	a5,0
    80000c06:	b771                	j	80000b92 <copyinstr+0x2c>
      return -1;
    80000c08:	557d                	li	a0,-1
    80000c0a:	b779                	j	80000b98 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80000c0c:	6b85                	lui	s7,0x1
    80000c0e:	9ba6                	add	s7,s7,s1
    80000c10:	87da                	mv	a5,s6
    80000c12:	b77d                	j	80000bc0 <copyinstr+0x5a>
  int got_null = 0;
    80000c14:	4781                	li	a5,0
  if(got_null){
    80000c16:	37fd                	addiw	a5,a5,-1
    80000c18:	0007851b          	sext.w	a0,a5
}
    80000c1c:	8082                	ret

0000000080000c1e <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000c1e:	7139                	addi	sp,sp,-64
    80000c20:	fc06                	sd	ra,56(sp)
    80000c22:	f822                	sd	s0,48(sp)
    80000c24:	f426                	sd	s1,40(sp)
    80000c26:	f04a                	sd	s2,32(sp)
    80000c28:	ec4e                	sd	s3,24(sp)
    80000c2a:	e852                	sd	s4,16(sp)
    80000c2c:	e456                	sd	s5,8(sp)
    80000c2e:	e05a                	sd	s6,0(sp)
    80000c30:	0080                	addi	s0,sp,64
    80000c32:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c34:	00007497          	auipc	s1,0x7
    80000c38:	33c48493          	addi	s1,s1,828 # 80007f70 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000c3c:	8b26                	mv	s6,s1
    80000c3e:	ff4df937          	lui	s2,0xff4df
    80000c42:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bd96d>
    80000c46:	0936                	slli	s2,s2,0xd
    80000c48:	6f590913          	addi	s2,s2,1781
    80000c4c:	0936                	slli	s2,s2,0xd
    80000c4e:	bd390913          	addi	s2,s2,-1069
    80000c52:	0932                	slli	s2,s2,0xc
    80000c54:	7a790913          	addi	s2,s2,1959
    80000c58:	040009b7          	lui	s3,0x4000
    80000c5c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000c5e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c60:	0000da97          	auipc	s5,0xd
    80000c64:	f10a8a93          	addi	s5,s5,-240 # 8000db70 <tickslock>
    char *pa = kalloc();
    80000c68:	c8eff0ef          	jal	800000f6 <kalloc>
    80000c6c:	862a                	mv	a2,a0
    if(pa == 0)
    80000c6e:	cd15                	beqz	a0,80000caa <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80000c70:	416485b3          	sub	a1,s1,s6
    80000c74:	8591                	srai	a1,a1,0x4
    80000c76:	032585b3          	mul	a1,a1,s2
    80000c7a:	2585                	addiw	a1,a1,1
    80000c7c:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000c80:	4719                	li	a4,6
    80000c82:	6685                	lui	a3,0x1
    80000c84:	40b985b3          	sub	a1,s3,a1
    80000c88:	8552                	mv	a0,s4
    80000c8a:	8e9ff0ef          	jal	80000572 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000c8e:	17048493          	addi	s1,s1,368
    80000c92:	fd549be3          	bne	s1,s5,80000c68 <proc_mapstacks+0x4a>
  }
}
    80000c96:	70e2                	ld	ra,56(sp)
    80000c98:	7442                	ld	s0,48(sp)
    80000c9a:	74a2                	ld	s1,40(sp)
    80000c9c:	7902                	ld	s2,32(sp)
    80000c9e:	69e2                	ld	s3,24(sp)
    80000ca0:	6a42                	ld	s4,16(sp)
    80000ca2:	6aa2                	ld	s5,8(sp)
    80000ca4:	6b02                	ld	s6,0(sp)
    80000ca6:	6121                	addi	sp,sp,64
    80000ca8:	8082                	ret
      panic("kalloc");
    80000caa:	00006517          	auipc	a0,0x6
    80000cae:	4fe50513          	addi	a0,a0,1278 # 800071a8 <etext+0x1a8>
    80000cb2:	121040ef          	jal	800055d2 <panic>

0000000080000cb6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000cb6:	7139                	addi	sp,sp,-64
    80000cb8:	fc06                	sd	ra,56(sp)
    80000cba:	f822                	sd	s0,48(sp)
    80000cbc:	f426                	sd	s1,40(sp)
    80000cbe:	f04a                	sd	s2,32(sp)
    80000cc0:	ec4e                	sd	s3,24(sp)
    80000cc2:	e852                	sd	s4,16(sp)
    80000cc4:	e456                	sd	s5,8(sp)
    80000cc6:	e05a                	sd	s6,0(sp)
    80000cc8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000cca:	00006597          	auipc	a1,0x6
    80000cce:	4e658593          	addi	a1,a1,1254 # 800071b0 <etext+0x1b0>
    80000cd2:	00007517          	auipc	a0,0x7
    80000cd6:	e6e50513          	addi	a0,a0,-402 # 80007b40 <pid_lock>
    80000cda:	3a7040ef          	jal	80005880 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000cde:	00006597          	auipc	a1,0x6
    80000ce2:	4da58593          	addi	a1,a1,1242 # 800071b8 <etext+0x1b8>
    80000ce6:	00007517          	auipc	a0,0x7
    80000cea:	e7250513          	addi	a0,a0,-398 # 80007b58 <wait_lock>
    80000cee:	393040ef          	jal	80005880 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cf2:	00007497          	auipc	s1,0x7
    80000cf6:	27e48493          	addi	s1,s1,638 # 80007f70 <proc>
      initlock(&p->lock, "proc");
    80000cfa:	00006b17          	auipc	s6,0x6
    80000cfe:	4ceb0b13          	addi	s6,s6,1230 # 800071c8 <etext+0x1c8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000d02:	8aa6                	mv	s5,s1
    80000d04:	ff4df937          	lui	s2,0xff4df
    80000d08:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4bd96d>
    80000d0c:	0936                	slli	s2,s2,0xd
    80000d0e:	6f590913          	addi	s2,s2,1781
    80000d12:	0936                	slli	s2,s2,0xd
    80000d14:	bd390913          	addi	s2,s2,-1069
    80000d18:	0932                	slli	s2,s2,0xc
    80000d1a:	7a790913          	addi	s2,s2,1959
    80000d1e:	040009b7          	lui	s3,0x4000
    80000d22:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80000d24:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d26:	0000da17          	auipc	s4,0xd
    80000d2a:	e4aa0a13          	addi	s4,s4,-438 # 8000db70 <tickslock>
      initlock(&p->lock, "proc");
    80000d2e:	85da                	mv	a1,s6
    80000d30:	8526                	mv	a0,s1
    80000d32:	34f040ef          	jal	80005880 <initlock>
      p->state = UNUSED;
    80000d36:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000d3a:	415487b3          	sub	a5,s1,s5
    80000d3e:	8791                	srai	a5,a5,0x4
    80000d40:	032787b3          	mul	a5,a5,s2
    80000d44:	2785                	addiw	a5,a5,1
    80000d46:	00d7979b          	slliw	a5,a5,0xd
    80000d4a:	40f987b3          	sub	a5,s3,a5
    80000d4e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d50:	17048493          	addi	s1,s1,368
    80000d54:	fd449de3          	bne	s1,s4,80000d2e <procinit+0x78>
  }
}
    80000d58:	70e2                	ld	ra,56(sp)
    80000d5a:	7442                	ld	s0,48(sp)
    80000d5c:	74a2                	ld	s1,40(sp)
    80000d5e:	7902                	ld	s2,32(sp)
    80000d60:	69e2                	ld	s3,24(sp)
    80000d62:	6a42                	ld	s4,16(sp)
    80000d64:	6aa2                	ld	s5,8(sp)
    80000d66:	6b02                	ld	s6,0(sp)
    80000d68:	6121                	addi	sp,sp,64
    80000d6a:	8082                	ret

0000000080000d6c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000d6c:	1141                	addi	sp,sp,-16
    80000d6e:	e422                	sd	s0,8(sp)
    80000d70:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000d72:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000d74:	2501                	sext.w	a0,a0
    80000d76:	6422                	ld	s0,8(sp)
    80000d78:	0141                	addi	sp,sp,16
    80000d7a:	8082                	ret

0000000080000d7c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000d7c:	1141                	addi	sp,sp,-16
    80000d7e:	e422                	sd	s0,8(sp)
    80000d80:	0800                	addi	s0,sp,16
    80000d82:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000d84:	2781                	sext.w	a5,a5
    80000d86:	079e                	slli	a5,a5,0x7
  return c;
}
    80000d88:	00007517          	auipc	a0,0x7
    80000d8c:	de850513          	addi	a0,a0,-536 # 80007b70 <cpus>
    80000d90:	953e                	add	a0,a0,a5
    80000d92:	6422                	ld	s0,8(sp)
    80000d94:	0141                	addi	sp,sp,16
    80000d96:	8082                	ret

0000000080000d98 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000d98:	1101                	addi	sp,sp,-32
    80000d9a:	ec06                	sd	ra,24(sp)
    80000d9c:	e822                	sd	s0,16(sp)
    80000d9e:	e426                	sd	s1,8(sp)
    80000da0:	1000                	addi	s0,sp,32
  push_off();
    80000da2:	31f040ef          	jal	800058c0 <push_off>
    80000da6:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000da8:	2781                	sext.w	a5,a5
    80000daa:	079e                	slli	a5,a5,0x7
    80000dac:	00007717          	auipc	a4,0x7
    80000db0:	d9470713          	addi	a4,a4,-620 # 80007b40 <pid_lock>
    80000db4:	97ba                	add	a5,a5,a4
    80000db6:	7b84                	ld	s1,48(a5)
  pop_off();
    80000db8:	38d040ef          	jal	80005944 <pop_off>
  return p;
}
    80000dbc:	8526                	mv	a0,s1
    80000dbe:	60e2                	ld	ra,24(sp)
    80000dc0:	6442                	ld	s0,16(sp)
    80000dc2:	64a2                	ld	s1,8(sp)
    80000dc4:	6105                	addi	sp,sp,32
    80000dc6:	8082                	ret

0000000080000dc8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000dc8:	1141                	addi	sp,sp,-16
    80000dca:	e406                	sd	ra,8(sp)
    80000dcc:	e022                	sd	s0,0(sp)
    80000dce:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000dd0:	fc9ff0ef          	jal	80000d98 <myproc>
    80000dd4:	3c5040ef          	jal	80005998 <release>

  if (first) {
    80000dd8:	00007797          	auipc	a5,0x7
    80000ddc:	cc87a783          	lw	a5,-824(a5) # 80007aa0 <first.1>
    80000de0:	e799                	bnez	a5,80000dee <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80000de2:	32b000ef          	jal	8000190c <usertrapret>
}
    80000de6:	60a2                	ld	ra,8(sp)
    80000de8:	6402                	ld	s0,0(sp)
    80000dea:	0141                	addi	sp,sp,16
    80000dec:	8082                	ret
    fsinit(ROOTDEV);
    80000dee:	4505                	li	a0,1
    80000df0:	7f6010ef          	jal	800025e6 <fsinit>
    first = 0;
    80000df4:	00007797          	auipc	a5,0x7
    80000df8:	ca07a623          	sw	zero,-852(a5) # 80007aa0 <first.1>
    __sync_synchronize();
    80000dfc:	0ff0000f          	fence
    80000e00:	b7cd                	j	80000de2 <forkret+0x1a>

0000000080000e02 <allocpid>:
{
    80000e02:	1101                	addi	sp,sp,-32
    80000e04:	ec06                	sd	ra,24(sp)
    80000e06:	e822                	sd	s0,16(sp)
    80000e08:	e426                	sd	s1,8(sp)
    80000e0a:	e04a                	sd	s2,0(sp)
    80000e0c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000e0e:	00007917          	auipc	s2,0x7
    80000e12:	d3290913          	addi	s2,s2,-718 # 80007b40 <pid_lock>
    80000e16:	854a                	mv	a0,s2
    80000e18:	2e9040ef          	jal	80005900 <acquire>
  pid = nextpid;
    80000e1c:	00007797          	auipc	a5,0x7
    80000e20:	c8878793          	addi	a5,a5,-888 # 80007aa4 <nextpid>
    80000e24:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000e26:	0014871b          	addiw	a4,s1,1
    80000e2a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000e2c:	854a                	mv	a0,s2
    80000e2e:	36b040ef          	jal	80005998 <release>
}
    80000e32:	8526                	mv	a0,s1
    80000e34:	60e2                	ld	ra,24(sp)
    80000e36:	6442                	ld	s0,16(sp)
    80000e38:	64a2                	ld	s1,8(sp)
    80000e3a:	6902                	ld	s2,0(sp)
    80000e3c:	6105                	addi	sp,sp,32
    80000e3e:	8082                	ret

0000000080000e40 <proc_pagetable>:
{
    80000e40:	1101                	addi	sp,sp,-32
    80000e42:	ec06                	sd	ra,24(sp)
    80000e44:	e822                	sd	s0,16(sp)
    80000e46:	e426                	sd	s1,8(sp)
    80000e48:	e04a                	sd	s2,0(sp)
    80000e4a:	1000                	addi	s0,sp,32
    80000e4c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000e4e:	8e7ff0ef          	jal	80000734 <uvmcreate>
    80000e52:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000e54:	cd05                	beqz	a0,80000e8c <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000e56:	4729                	li	a4,10
    80000e58:	00005697          	auipc	a3,0x5
    80000e5c:	1a868693          	addi	a3,a3,424 # 80006000 <_trampoline>
    80000e60:	6605                	lui	a2,0x1
    80000e62:	040005b7          	lui	a1,0x4000
    80000e66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000e68:	05b2                	slli	a1,a1,0xc
    80000e6a:	e58ff0ef          	jal	800004c2 <mappages>
    80000e6e:	02054663          	bltz	a0,80000e9a <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000e72:	4719                	li	a4,6
    80000e74:	05893683          	ld	a3,88(s2)
    80000e78:	6605                	lui	a2,0x1
    80000e7a:	020005b7          	lui	a1,0x2000
    80000e7e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000e80:	05b6                	slli	a1,a1,0xd
    80000e82:	8526                	mv	a0,s1
    80000e84:	e3eff0ef          	jal	800004c2 <mappages>
    80000e88:	00054f63          	bltz	a0,80000ea6 <proc_pagetable+0x66>
}
    80000e8c:	8526                	mv	a0,s1
    80000e8e:	60e2                	ld	ra,24(sp)
    80000e90:	6442                	ld	s0,16(sp)
    80000e92:	64a2                	ld	s1,8(sp)
    80000e94:	6902                	ld	s2,0(sp)
    80000e96:	6105                	addi	sp,sp,32
    80000e98:	8082                	ret
    uvmfree(pagetable, 0);
    80000e9a:	4581                	li	a1,0
    80000e9c:	8526                	mv	a0,s1
    80000e9e:	a5dff0ef          	jal	800008fa <uvmfree>
    return 0;
    80000ea2:	4481                	li	s1,0
    80000ea4:	b7e5                	j	80000e8c <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000ea6:	4681                	li	a3,0
    80000ea8:	4605                	li	a2,1
    80000eaa:	040005b7          	lui	a1,0x4000
    80000eae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000eb0:	05b2                	slli	a1,a1,0xc
    80000eb2:	8526                	mv	a0,s1
    80000eb4:	fb4ff0ef          	jal	80000668 <uvmunmap>
    uvmfree(pagetable, 0);
    80000eb8:	4581                	li	a1,0
    80000eba:	8526                	mv	a0,s1
    80000ebc:	a3fff0ef          	jal	800008fa <uvmfree>
    return 0;
    80000ec0:	4481                	li	s1,0
    80000ec2:	b7e9                	j	80000e8c <proc_pagetable+0x4c>

0000000080000ec4 <proc_freepagetable>:
{
    80000ec4:	1101                	addi	sp,sp,-32
    80000ec6:	ec06                	sd	ra,24(sp)
    80000ec8:	e822                	sd	s0,16(sp)
    80000eca:	e426                	sd	s1,8(sp)
    80000ecc:	e04a                	sd	s2,0(sp)
    80000ece:	1000                	addi	s0,sp,32
    80000ed0:	84aa                	mv	s1,a0
    80000ed2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000ed4:	4681                	li	a3,0
    80000ed6:	4605                	li	a2,1
    80000ed8:	040005b7          	lui	a1,0x4000
    80000edc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000ede:	05b2                	slli	a1,a1,0xc
    80000ee0:	f88ff0ef          	jal	80000668 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000ee4:	4681                	li	a3,0
    80000ee6:	4605                	li	a2,1
    80000ee8:	020005b7          	lui	a1,0x2000
    80000eec:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000eee:	05b6                	slli	a1,a1,0xd
    80000ef0:	8526                	mv	a0,s1
    80000ef2:	f76ff0ef          	jal	80000668 <uvmunmap>
  uvmfree(pagetable, sz);
    80000ef6:	85ca                	mv	a1,s2
    80000ef8:	8526                	mv	a0,s1
    80000efa:	a01ff0ef          	jal	800008fa <uvmfree>
}
    80000efe:	60e2                	ld	ra,24(sp)
    80000f00:	6442                	ld	s0,16(sp)
    80000f02:	64a2                	ld	s1,8(sp)
    80000f04:	6902                	ld	s2,0(sp)
    80000f06:	6105                	addi	sp,sp,32
    80000f08:	8082                	ret

0000000080000f0a <freeproc>:
{
    80000f0a:	1101                	addi	sp,sp,-32
    80000f0c:	ec06                	sd	ra,24(sp)
    80000f0e:	e822                	sd	s0,16(sp)
    80000f10:	e426                	sd	s1,8(sp)
    80000f12:	1000                	addi	s0,sp,32
    80000f14:	84aa                	mv	s1,a0
  if(p->trapframe)
    80000f16:	6d28                	ld	a0,88(a0)
    80000f18:	c119                	beqz	a0,80000f1e <freeproc+0x14>
    kfree((void*)p->trapframe);
    80000f1a:	902ff0ef          	jal	8000001c <kfree>
  p->trapframe = 0;
    80000f1e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80000f22:	68a8                	ld	a0,80(s1)
    80000f24:	c501                	beqz	a0,80000f2c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80000f26:	64ac                	ld	a1,72(s1)
    80000f28:	f9dff0ef          	jal	80000ec4 <proc_freepagetable>
  p->pagetable = 0;
    80000f2c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80000f30:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80000f34:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80000f38:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80000f3c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80000f40:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80000f44:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80000f48:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80000f4c:	0004ac23          	sw	zero,24(s1)
}
    80000f50:	60e2                	ld	ra,24(sp)
    80000f52:	6442                	ld	s0,16(sp)
    80000f54:	64a2                	ld	s1,8(sp)
    80000f56:	6105                	addi	sp,sp,32
    80000f58:	8082                	ret

0000000080000f5a <allocproc>:
{
    80000f5a:	1101                	addi	sp,sp,-32
    80000f5c:	ec06                	sd	ra,24(sp)
    80000f5e:	e822                	sd	s0,16(sp)
    80000f60:	e426                	sd	s1,8(sp)
    80000f62:	e04a                	sd	s2,0(sp)
    80000f64:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f66:	00007497          	auipc	s1,0x7
    80000f6a:	00a48493          	addi	s1,s1,10 # 80007f70 <proc>
    80000f6e:	0000d917          	auipc	s2,0xd
    80000f72:	c0290913          	addi	s2,s2,-1022 # 8000db70 <tickslock>
    acquire(&p->lock);
    80000f76:	8526                	mv	a0,s1
    80000f78:	189040ef          	jal	80005900 <acquire>
    if(p->state == UNUSED) {
    80000f7c:	4c9c                	lw	a5,24(s1)
    80000f7e:	cb91                	beqz	a5,80000f92 <allocproc+0x38>
      release(&p->lock);
    80000f80:	8526                	mv	a0,s1
    80000f82:	217040ef          	jal	80005998 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000f86:	17048493          	addi	s1,s1,368
    80000f8a:	ff2496e3          	bne	s1,s2,80000f76 <allocproc+0x1c>
  return 0;
    80000f8e:	4481                	li	s1,0
    80000f90:	a089                	j	80000fd2 <allocproc+0x78>
  p->pid = allocpid();
    80000f92:	e71ff0ef          	jal	80000e02 <allocpid>
    80000f96:	d888                	sw	a0,48(s1)
  p->state = USED;
    80000f98:	4785                	li	a5,1
    80000f9a:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80000f9c:	95aff0ef          	jal	800000f6 <kalloc>
    80000fa0:	892a                	mv	s2,a0
    80000fa2:	eca8                	sd	a0,88(s1)
    80000fa4:	cd15                	beqz	a0,80000fe0 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80000fa6:	8526                	mv	a0,s1
    80000fa8:	e99ff0ef          	jal	80000e40 <proc_pagetable>
    80000fac:	892a                	mv	s2,a0
    80000fae:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80000fb0:	c121                	beqz	a0,80000ff0 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80000fb2:	07000613          	li	a2,112
    80000fb6:	4581                	li	a1,0
    80000fb8:	06048513          	addi	a0,s1,96
    80000fbc:	9baff0ef          	jal	80000176 <memset>
  p->context.ra = (uint64)forkret;
    80000fc0:	00000797          	auipc	a5,0x0
    80000fc4:	e0878793          	addi	a5,a5,-504 # 80000dc8 <forkret>
    80000fc8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80000fca:	60bc                	ld	a5,64(s1)
    80000fcc:	6705                	lui	a4,0x1
    80000fce:	97ba                	add	a5,a5,a4
    80000fd0:	f4bc                	sd	a5,104(s1)
}
    80000fd2:	8526                	mv	a0,s1
    80000fd4:	60e2                	ld	ra,24(sp)
    80000fd6:	6442                	ld	s0,16(sp)
    80000fd8:	64a2                	ld	s1,8(sp)
    80000fda:	6902                	ld	s2,0(sp)
    80000fdc:	6105                	addi	sp,sp,32
    80000fde:	8082                	ret
    freeproc(p);
    80000fe0:	8526                	mv	a0,s1
    80000fe2:	f29ff0ef          	jal	80000f0a <freeproc>
    release(&p->lock);
    80000fe6:	8526                	mv	a0,s1
    80000fe8:	1b1040ef          	jal	80005998 <release>
    return 0;
    80000fec:	84ca                	mv	s1,s2
    80000fee:	b7d5                	j	80000fd2 <allocproc+0x78>
    freeproc(p);
    80000ff0:	8526                	mv	a0,s1
    80000ff2:	f19ff0ef          	jal	80000f0a <freeproc>
    release(&p->lock);
    80000ff6:	8526                	mv	a0,s1
    80000ff8:	1a1040ef          	jal	80005998 <release>
    return 0;
    80000ffc:	84ca                	mv	s1,s2
    80000ffe:	bfd1                	j	80000fd2 <allocproc+0x78>

0000000080001000 <userinit>:
{
    80001000:	1101                	addi	sp,sp,-32
    80001002:	ec06                	sd	ra,24(sp)
    80001004:	e822                	sd	s0,16(sp)
    80001006:	e426                	sd	s1,8(sp)
    80001008:	1000                	addi	s0,sp,32
  p = allocproc();
    8000100a:	f51ff0ef          	jal	80000f5a <allocproc>
    8000100e:	84aa                	mv	s1,a0
  initproc = p;
    80001010:	00007797          	auipc	a5,0x7
    80001014:	aea7b823          	sd	a0,-1296(a5) # 80007b00 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001018:	03400613          	li	a2,52
    8000101c:	00007597          	auipc	a1,0x7
    80001020:	a9458593          	addi	a1,a1,-1388 # 80007ab0 <initcode>
    80001024:	6928                	ld	a0,80(a0)
    80001026:	f34ff0ef          	jal	8000075a <uvmfirst>
  p->sz = PGSIZE;
    8000102a:	6785                	lui	a5,0x1
    8000102c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000102e:	6cb8                	ld	a4,88(s1)
    80001030:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001034:	6cb8                	ld	a4,88(s1)
    80001036:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001038:	4641                	li	a2,16
    8000103a:	00006597          	auipc	a1,0x6
    8000103e:	19658593          	addi	a1,a1,406 # 800071d0 <etext+0x1d0>
    80001042:	15848513          	addi	a0,s1,344
    80001046:	a6eff0ef          	jal	800002b4 <safestrcpy>
  p->cwd = namei("/");
    8000104a:	00006517          	auipc	a0,0x6
    8000104e:	19650513          	addi	a0,a0,406 # 800071e0 <etext+0x1e0>
    80001052:	6a3010ef          	jal	80002ef4 <namei>
    80001056:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000105a:	478d                	li	a5,3
    8000105c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000105e:	8526                	mv	a0,s1
    80001060:	139040ef          	jal	80005998 <release>
}
    80001064:	60e2                	ld	ra,24(sp)
    80001066:	6442                	ld	s0,16(sp)
    80001068:	64a2                	ld	s1,8(sp)
    8000106a:	6105                	addi	sp,sp,32
    8000106c:	8082                	ret

000000008000106e <growproc>:
{
    8000106e:	1101                	addi	sp,sp,-32
    80001070:	ec06                	sd	ra,24(sp)
    80001072:	e822                	sd	s0,16(sp)
    80001074:	e426                	sd	s1,8(sp)
    80001076:	e04a                	sd	s2,0(sp)
    80001078:	1000                	addi	s0,sp,32
    8000107a:	892a                	mv	s2,a0
  struct proc *p = myproc();
    8000107c:	d1dff0ef          	jal	80000d98 <myproc>
    80001080:	84aa                	mv	s1,a0
  sz = p->sz;
    80001082:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001084:	01204c63          	bgtz	s2,8000109c <growproc+0x2e>
  } else if(n < 0){
    80001088:	02094463          	bltz	s2,800010b0 <growproc+0x42>
  p->sz = sz;
    8000108c:	e4ac                	sd	a1,72(s1)
  return 0;
    8000108e:	4501                	li	a0,0
}
    80001090:	60e2                	ld	ra,24(sp)
    80001092:	6442                	ld	s0,16(sp)
    80001094:	64a2                	ld	s1,8(sp)
    80001096:	6902                	ld	s2,0(sp)
    80001098:	6105                	addi	sp,sp,32
    8000109a:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000109c:	4691                	li	a3,4
    8000109e:	00b90633          	add	a2,s2,a1
    800010a2:	6928                	ld	a0,80(a0)
    800010a4:	f58ff0ef          	jal	800007fc <uvmalloc>
    800010a8:	85aa                	mv	a1,a0
    800010aa:	f16d                	bnez	a0,8000108c <growproc+0x1e>
      return -1;
    800010ac:	557d                	li	a0,-1
    800010ae:	b7cd                	j	80001090 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800010b0:	00b90633          	add	a2,s2,a1
    800010b4:	6928                	ld	a0,80(a0)
    800010b6:	f02ff0ef          	jal	800007b8 <uvmdealloc>
    800010ba:	85aa                	mv	a1,a0
    800010bc:	bfc1                	j	8000108c <growproc+0x1e>

00000000800010be <fork>:
{
    800010be:	7139                	addi	sp,sp,-64
    800010c0:	fc06                	sd	ra,56(sp)
    800010c2:	f822                	sd	s0,48(sp)
    800010c4:	f04a                	sd	s2,32(sp)
    800010c6:	e456                	sd	s5,8(sp)
    800010c8:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    800010ca:	ccfff0ef          	jal	80000d98 <myproc>
    800010ce:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    800010d0:	e8bff0ef          	jal	80000f5a <allocproc>
    800010d4:	0e050e63          	beqz	a0,800011d0 <fork+0x112>
    800010d8:	ec4e                	sd	s3,24(sp)
    800010da:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800010dc:	048ab603          	ld	a2,72(s5)
    800010e0:	692c                	ld	a1,80(a0)
    800010e2:	050ab503          	ld	a0,80(s5)
    800010e6:	847ff0ef          	jal	8000092c <uvmcopy>
    800010ea:	04054e63          	bltz	a0,80001146 <fork+0x88>
    800010ee:	f426                	sd	s1,40(sp)
    800010f0:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    800010f2:	048ab783          	ld	a5,72(s5)
    800010f6:	04f9b423          	sd	a5,72(s3)
  np->trace_mask = p->trace_mask;
    800010fa:	168aa783          	lw	a5,360(s5)
    800010fe:	16f9a423          	sw	a5,360(s3)
  *(np->trapframe) = *(p->trapframe);
    80001102:	058ab683          	ld	a3,88(s5)
    80001106:	87b6                	mv	a5,a3
    80001108:	0589b703          	ld	a4,88(s3)
    8000110c:	12068693          	addi	a3,a3,288
    80001110:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001114:	6788                	ld	a0,8(a5)
    80001116:	6b8c                	ld	a1,16(a5)
    80001118:	6f90                	ld	a2,24(a5)
    8000111a:	01073023          	sd	a6,0(a4)
    8000111e:	e708                	sd	a0,8(a4)
    80001120:	eb0c                	sd	a1,16(a4)
    80001122:	ef10                	sd	a2,24(a4)
    80001124:	02078793          	addi	a5,a5,32
    80001128:	02070713          	addi	a4,a4,32
    8000112c:	fed792e3          	bne	a5,a3,80001110 <fork+0x52>
  np->trapframe->a0 = 0;
    80001130:	0589b783          	ld	a5,88(s3)
    80001134:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001138:	0d0a8493          	addi	s1,s5,208
    8000113c:	0d098913          	addi	s2,s3,208
    80001140:	150a8a13          	addi	s4,s5,336
    80001144:	a831                	j	80001160 <fork+0xa2>
    freeproc(np);
    80001146:	854e                	mv	a0,s3
    80001148:	dc3ff0ef          	jal	80000f0a <freeproc>
    release(&np->lock);
    8000114c:	854e                	mv	a0,s3
    8000114e:	04b040ef          	jal	80005998 <release>
    return -1;
    80001152:	597d                	li	s2,-1
    80001154:	69e2                	ld	s3,24(sp)
    80001156:	a0b5                	j	800011c2 <fork+0x104>
  for(i = 0; i < NOFILE; i++)
    80001158:	04a1                	addi	s1,s1,8
    8000115a:	0921                	addi	s2,s2,8
    8000115c:	01448963          	beq	s1,s4,8000116e <fork+0xb0>
    if(p->ofile[i])
    80001160:	6088                	ld	a0,0(s1)
    80001162:	d97d                	beqz	a0,80001158 <fork+0x9a>
      np->ofile[i] = filedup(p->ofile[i]);
    80001164:	320020ef          	jal	80003484 <filedup>
    80001168:	00a93023          	sd	a0,0(s2)
    8000116c:	b7f5                	j	80001158 <fork+0x9a>
  np->cwd = idup(p->cwd);
    8000116e:	150ab503          	ld	a0,336(s5)
    80001172:	672010ef          	jal	800027e4 <idup>
    80001176:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000117a:	4641                	li	a2,16
    8000117c:	158a8593          	addi	a1,s5,344
    80001180:	15898513          	addi	a0,s3,344
    80001184:	930ff0ef          	jal	800002b4 <safestrcpy>
  pid = np->pid;
    80001188:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    8000118c:	854e                	mv	a0,s3
    8000118e:	00b040ef          	jal	80005998 <release>
  acquire(&wait_lock);
    80001192:	00007497          	auipc	s1,0x7
    80001196:	9c648493          	addi	s1,s1,-1594 # 80007b58 <wait_lock>
    8000119a:	8526                	mv	a0,s1
    8000119c:	764040ef          	jal	80005900 <acquire>
  np->parent = p;
    800011a0:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    800011a4:	8526                	mv	a0,s1
    800011a6:	7f2040ef          	jal	80005998 <release>
  acquire(&np->lock);
    800011aa:	854e                	mv	a0,s3
    800011ac:	754040ef          	jal	80005900 <acquire>
  np->state = RUNNABLE;
    800011b0:	478d                	li	a5,3
    800011b2:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800011b6:	854e                	mv	a0,s3
    800011b8:	7e0040ef          	jal	80005998 <release>
  return pid;
    800011bc:	74a2                	ld	s1,40(sp)
    800011be:	69e2                	ld	s3,24(sp)
    800011c0:	6a42                	ld	s4,16(sp)
}
    800011c2:	854a                	mv	a0,s2
    800011c4:	70e2                	ld	ra,56(sp)
    800011c6:	7442                	ld	s0,48(sp)
    800011c8:	7902                	ld	s2,32(sp)
    800011ca:	6aa2                	ld	s5,8(sp)
    800011cc:	6121                	addi	sp,sp,64
    800011ce:	8082                	ret
    return -1;
    800011d0:	597d                	li	s2,-1
    800011d2:	bfc5                	j	800011c2 <fork+0x104>

00000000800011d4 <scheduler>:
{
    800011d4:	715d                	addi	sp,sp,-80
    800011d6:	e486                	sd	ra,72(sp)
    800011d8:	e0a2                	sd	s0,64(sp)
    800011da:	fc26                	sd	s1,56(sp)
    800011dc:	f84a                	sd	s2,48(sp)
    800011de:	f44e                	sd	s3,40(sp)
    800011e0:	f052                	sd	s4,32(sp)
    800011e2:	ec56                	sd	s5,24(sp)
    800011e4:	e85a                	sd	s6,16(sp)
    800011e6:	e45e                	sd	s7,8(sp)
    800011e8:	e062                	sd	s8,0(sp)
    800011ea:	0880                	addi	s0,sp,80
    800011ec:	8792                	mv	a5,tp
  int id = r_tp();
    800011ee:	2781                	sext.w	a5,a5
  c->proc = 0;
    800011f0:	00779b13          	slli	s6,a5,0x7
    800011f4:	00007717          	auipc	a4,0x7
    800011f8:	94c70713          	addi	a4,a4,-1716 # 80007b40 <pid_lock>
    800011fc:	975a                	add	a4,a4,s6
    800011fe:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001202:	00007717          	auipc	a4,0x7
    80001206:	97670713          	addi	a4,a4,-1674 # 80007b78 <cpus+0x8>
    8000120a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000120c:	4c11                	li	s8,4
        c->proc = p;
    8000120e:	079e                	slli	a5,a5,0x7
    80001210:	00007a17          	auipc	s4,0x7
    80001214:	930a0a13          	addi	s4,s4,-1744 # 80007b40 <pid_lock>
    80001218:	9a3e                	add	s4,s4,a5
        found = 1;
    8000121a:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    8000121c:	0000d997          	auipc	s3,0xd
    80001220:	95498993          	addi	s3,s3,-1708 # 8000db70 <tickslock>
    80001224:	a0a9                	j	8000126e <scheduler+0x9a>
      release(&p->lock);
    80001226:	8526                	mv	a0,s1
    80001228:	770040ef          	jal	80005998 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000122c:	17048493          	addi	s1,s1,368
    80001230:	03348563          	beq	s1,s3,8000125a <scheduler+0x86>
      acquire(&p->lock);
    80001234:	8526                	mv	a0,s1
    80001236:	6ca040ef          	jal	80005900 <acquire>
      if(p->state == RUNNABLE) {
    8000123a:	4c9c                	lw	a5,24(s1)
    8000123c:	ff2795e3          	bne	a5,s2,80001226 <scheduler+0x52>
        p->state = RUNNING;
    80001240:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001244:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001248:	06048593          	addi	a1,s1,96
    8000124c:	855a                	mv	a0,s6
    8000124e:	618000ef          	jal	80001866 <swtch>
        c->proc = 0;
    80001252:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001256:	8ade                	mv	s5,s7
    80001258:	b7f9                	j	80001226 <scheduler+0x52>
    if(found == 0) {
    8000125a:	000a9a63          	bnez	s5,8000126e <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000125e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001262:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001266:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    8000126a:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000126e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001272:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001276:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000127a:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000127c:	00007497          	auipc	s1,0x7
    80001280:	cf448493          	addi	s1,s1,-780 # 80007f70 <proc>
      if(p->state == RUNNABLE) {
    80001284:	490d                	li	s2,3
    80001286:	b77d                	j	80001234 <scheduler+0x60>

0000000080001288 <sched>:
{
    80001288:	7179                	addi	sp,sp,-48
    8000128a:	f406                	sd	ra,40(sp)
    8000128c:	f022                	sd	s0,32(sp)
    8000128e:	ec26                	sd	s1,24(sp)
    80001290:	e84a                	sd	s2,16(sp)
    80001292:	e44e                	sd	s3,8(sp)
    80001294:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001296:	b03ff0ef          	jal	80000d98 <myproc>
    8000129a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000129c:	5fa040ef          	jal	80005896 <holding>
    800012a0:	c92d                	beqz	a0,80001312 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800012a2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800012a4:	2781                	sext.w	a5,a5
    800012a6:	079e                	slli	a5,a5,0x7
    800012a8:	00007717          	auipc	a4,0x7
    800012ac:	89870713          	addi	a4,a4,-1896 # 80007b40 <pid_lock>
    800012b0:	97ba                	add	a5,a5,a4
    800012b2:	0a87a703          	lw	a4,168(a5)
    800012b6:	4785                	li	a5,1
    800012b8:	06f71363          	bne	a4,a5,8000131e <sched+0x96>
  if(p->state == RUNNING)
    800012bc:	4c98                	lw	a4,24(s1)
    800012be:	4791                	li	a5,4
    800012c0:	06f70563          	beq	a4,a5,8000132a <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800012c4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800012c8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800012ca:	e7b5                	bnez	a5,80001336 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    800012cc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800012ce:	00007917          	auipc	s2,0x7
    800012d2:	87290913          	addi	s2,s2,-1934 # 80007b40 <pid_lock>
    800012d6:	2781                	sext.w	a5,a5
    800012d8:	079e                	slli	a5,a5,0x7
    800012da:	97ca                	add	a5,a5,s2
    800012dc:	0ac7a983          	lw	s3,172(a5)
    800012e0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800012e2:	2781                	sext.w	a5,a5
    800012e4:	079e                	slli	a5,a5,0x7
    800012e6:	00007597          	auipc	a1,0x7
    800012ea:	89258593          	addi	a1,a1,-1902 # 80007b78 <cpus+0x8>
    800012ee:	95be                	add	a1,a1,a5
    800012f0:	06048513          	addi	a0,s1,96
    800012f4:	572000ef          	jal	80001866 <swtch>
    800012f8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800012fa:	2781                	sext.w	a5,a5
    800012fc:	079e                	slli	a5,a5,0x7
    800012fe:	993e                	add	s2,s2,a5
    80001300:	0b392623          	sw	s3,172(s2)
}
    80001304:	70a2                	ld	ra,40(sp)
    80001306:	7402                	ld	s0,32(sp)
    80001308:	64e2                	ld	s1,24(sp)
    8000130a:	6942                	ld	s2,16(sp)
    8000130c:	69a2                	ld	s3,8(sp)
    8000130e:	6145                	addi	sp,sp,48
    80001310:	8082                	ret
    panic("sched p->lock");
    80001312:	00006517          	auipc	a0,0x6
    80001316:	ed650513          	addi	a0,a0,-298 # 800071e8 <etext+0x1e8>
    8000131a:	2b8040ef          	jal	800055d2 <panic>
    panic("sched locks");
    8000131e:	00006517          	auipc	a0,0x6
    80001322:	eda50513          	addi	a0,a0,-294 # 800071f8 <etext+0x1f8>
    80001326:	2ac040ef          	jal	800055d2 <panic>
    panic("sched running");
    8000132a:	00006517          	auipc	a0,0x6
    8000132e:	ede50513          	addi	a0,a0,-290 # 80007208 <etext+0x208>
    80001332:	2a0040ef          	jal	800055d2 <panic>
    panic("sched interruptible");
    80001336:	00006517          	auipc	a0,0x6
    8000133a:	ee250513          	addi	a0,a0,-286 # 80007218 <etext+0x218>
    8000133e:	294040ef          	jal	800055d2 <panic>

0000000080001342 <yield>:
{
    80001342:	1101                	addi	sp,sp,-32
    80001344:	ec06                	sd	ra,24(sp)
    80001346:	e822                	sd	s0,16(sp)
    80001348:	e426                	sd	s1,8(sp)
    8000134a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000134c:	a4dff0ef          	jal	80000d98 <myproc>
    80001350:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001352:	5ae040ef          	jal	80005900 <acquire>
  p->state = RUNNABLE;
    80001356:	478d                	li	a5,3
    80001358:	cc9c                	sw	a5,24(s1)
  sched();
    8000135a:	f2fff0ef          	jal	80001288 <sched>
  release(&p->lock);
    8000135e:	8526                	mv	a0,s1
    80001360:	638040ef          	jal	80005998 <release>
}
    80001364:	60e2                	ld	ra,24(sp)
    80001366:	6442                	ld	s0,16(sp)
    80001368:	64a2                	ld	s1,8(sp)
    8000136a:	6105                	addi	sp,sp,32
    8000136c:	8082                	ret

000000008000136e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000136e:	7179                	addi	sp,sp,-48
    80001370:	f406                	sd	ra,40(sp)
    80001372:	f022                	sd	s0,32(sp)
    80001374:	ec26                	sd	s1,24(sp)
    80001376:	e84a                	sd	s2,16(sp)
    80001378:	e44e                	sd	s3,8(sp)
    8000137a:	1800                	addi	s0,sp,48
    8000137c:	89aa                	mv	s3,a0
    8000137e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001380:	a19ff0ef          	jal	80000d98 <myproc>
    80001384:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001386:	57a040ef          	jal	80005900 <acquire>
  release(lk);
    8000138a:	854a                	mv	a0,s2
    8000138c:	60c040ef          	jal	80005998 <release>

  // Go to sleep.
  p->chan = chan;
    80001390:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001394:	4789                	li	a5,2
    80001396:	cc9c                	sw	a5,24(s1)

  sched();
    80001398:	ef1ff0ef          	jal	80001288 <sched>

  // Tidy up.
  p->chan = 0;
    8000139c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800013a0:	8526                	mv	a0,s1
    800013a2:	5f6040ef          	jal	80005998 <release>
  acquire(lk);
    800013a6:	854a                	mv	a0,s2
    800013a8:	558040ef          	jal	80005900 <acquire>
}
    800013ac:	70a2                	ld	ra,40(sp)
    800013ae:	7402                	ld	s0,32(sp)
    800013b0:	64e2                	ld	s1,24(sp)
    800013b2:	6942                	ld	s2,16(sp)
    800013b4:	69a2                	ld	s3,8(sp)
    800013b6:	6145                	addi	sp,sp,48
    800013b8:	8082                	ret

00000000800013ba <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800013ba:	7139                	addi	sp,sp,-64
    800013bc:	fc06                	sd	ra,56(sp)
    800013be:	f822                	sd	s0,48(sp)
    800013c0:	f426                	sd	s1,40(sp)
    800013c2:	f04a                	sd	s2,32(sp)
    800013c4:	ec4e                	sd	s3,24(sp)
    800013c6:	e852                	sd	s4,16(sp)
    800013c8:	e456                	sd	s5,8(sp)
    800013ca:	0080                	addi	s0,sp,64
    800013cc:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800013ce:	00007497          	auipc	s1,0x7
    800013d2:	ba248493          	addi	s1,s1,-1118 # 80007f70 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800013d6:	4989                	li	s3,2
        p->state = RUNNABLE;
    800013d8:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800013da:	0000c917          	auipc	s2,0xc
    800013de:	79690913          	addi	s2,s2,1942 # 8000db70 <tickslock>
    800013e2:	a801                	j	800013f2 <wakeup+0x38>
      }
      release(&p->lock);
    800013e4:	8526                	mv	a0,s1
    800013e6:	5b2040ef          	jal	80005998 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800013ea:	17048493          	addi	s1,s1,368
    800013ee:	03248263          	beq	s1,s2,80001412 <wakeup+0x58>
    if(p != myproc()){
    800013f2:	9a7ff0ef          	jal	80000d98 <myproc>
    800013f6:	fea48ae3          	beq	s1,a0,800013ea <wakeup+0x30>
      acquire(&p->lock);
    800013fa:	8526                	mv	a0,s1
    800013fc:	504040ef          	jal	80005900 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001400:	4c9c                	lw	a5,24(s1)
    80001402:	ff3791e3          	bne	a5,s3,800013e4 <wakeup+0x2a>
    80001406:	709c                	ld	a5,32(s1)
    80001408:	fd479ee3          	bne	a5,s4,800013e4 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000140c:	0154ac23          	sw	s5,24(s1)
    80001410:	bfd1                	j	800013e4 <wakeup+0x2a>
    }
  }
}
    80001412:	70e2                	ld	ra,56(sp)
    80001414:	7442                	ld	s0,48(sp)
    80001416:	74a2                	ld	s1,40(sp)
    80001418:	7902                	ld	s2,32(sp)
    8000141a:	69e2                	ld	s3,24(sp)
    8000141c:	6a42                	ld	s4,16(sp)
    8000141e:	6aa2                	ld	s5,8(sp)
    80001420:	6121                	addi	sp,sp,64
    80001422:	8082                	ret

0000000080001424 <reparent>:
{
    80001424:	7179                	addi	sp,sp,-48
    80001426:	f406                	sd	ra,40(sp)
    80001428:	f022                	sd	s0,32(sp)
    8000142a:	ec26                	sd	s1,24(sp)
    8000142c:	e84a                	sd	s2,16(sp)
    8000142e:	e44e                	sd	s3,8(sp)
    80001430:	e052                	sd	s4,0(sp)
    80001432:	1800                	addi	s0,sp,48
    80001434:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001436:	00007497          	auipc	s1,0x7
    8000143a:	b3a48493          	addi	s1,s1,-1222 # 80007f70 <proc>
      pp->parent = initproc;
    8000143e:	00006a17          	auipc	s4,0x6
    80001442:	6c2a0a13          	addi	s4,s4,1730 # 80007b00 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001446:	0000c997          	auipc	s3,0xc
    8000144a:	72a98993          	addi	s3,s3,1834 # 8000db70 <tickslock>
    8000144e:	a029                	j	80001458 <reparent+0x34>
    80001450:	17048493          	addi	s1,s1,368
    80001454:	01348b63          	beq	s1,s3,8000146a <reparent+0x46>
    if(pp->parent == p){
    80001458:	7c9c                	ld	a5,56(s1)
    8000145a:	ff279be3          	bne	a5,s2,80001450 <reparent+0x2c>
      pp->parent = initproc;
    8000145e:	000a3503          	ld	a0,0(s4)
    80001462:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001464:	f57ff0ef          	jal	800013ba <wakeup>
    80001468:	b7e5                	j	80001450 <reparent+0x2c>
}
    8000146a:	70a2                	ld	ra,40(sp)
    8000146c:	7402                	ld	s0,32(sp)
    8000146e:	64e2                	ld	s1,24(sp)
    80001470:	6942                	ld	s2,16(sp)
    80001472:	69a2                	ld	s3,8(sp)
    80001474:	6a02                	ld	s4,0(sp)
    80001476:	6145                	addi	sp,sp,48
    80001478:	8082                	ret

000000008000147a <exit>:
{
    8000147a:	7179                	addi	sp,sp,-48
    8000147c:	f406                	sd	ra,40(sp)
    8000147e:	f022                	sd	s0,32(sp)
    80001480:	ec26                	sd	s1,24(sp)
    80001482:	e84a                	sd	s2,16(sp)
    80001484:	e44e                	sd	s3,8(sp)
    80001486:	e052                	sd	s4,0(sp)
    80001488:	1800                	addi	s0,sp,48
    8000148a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000148c:	90dff0ef          	jal	80000d98 <myproc>
    80001490:	89aa                	mv	s3,a0
  if(p == initproc)
    80001492:	00006797          	auipc	a5,0x6
    80001496:	66e7b783          	ld	a5,1646(a5) # 80007b00 <initproc>
    8000149a:	0d050493          	addi	s1,a0,208
    8000149e:	15050913          	addi	s2,a0,336
    800014a2:	00a79f63          	bne	a5,a0,800014c0 <exit+0x46>
    panic("init exiting");
    800014a6:	00006517          	auipc	a0,0x6
    800014aa:	d8a50513          	addi	a0,a0,-630 # 80007230 <etext+0x230>
    800014ae:	124040ef          	jal	800055d2 <panic>
      fileclose(f);
    800014b2:	018020ef          	jal	800034ca <fileclose>
      p->ofile[fd] = 0;
    800014b6:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800014ba:	04a1                	addi	s1,s1,8
    800014bc:	01248563          	beq	s1,s2,800014c6 <exit+0x4c>
    if(p->ofile[fd]){
    800014c0:	6088                	ld	a0,0(s1)
    800014c2:	f965                	bnez	a0,800014b2 <exit+0x38>
    800014c4:	bfdd                	j	800014ba <exit+0x40>
  begin_op();
    800014c6:	3eb010ef          	jal	800030b0 <begin_op>
  iput(p->cwd);
    800014ca:	1509b503          	ld	a0,336(s3)
    800014ce:	4ce010ef          	jal	8000299c <iput>
  end_op();
    800014d2:	449010ef          	jal	8000311a <end_op>
  p->cwd = 0;
    800014d6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800014da:	00006497          	auipc	s1,0x6
    800014de:	67e48493          	addi	s1,s1,1662 # 80007b58 <wait_lock>
    800014e2:	8526                	mv	a0,s1
    800014e4:	41c040ef          	jal	80005900 <acquire>
  reparent(p);
    800014e8:	854e                	mv	a0,s3
    800014ea:	f3bff0ef          	jal	80001424 <reparent>
  wakeup(p->parent);
    800014ee:	0389b503          	ld	a0,56(s3)
    800014f2:	ec9ff0ef          	jal	800013ba <wakeup>
  acquire(&p->lock);
    800014f6:	854e                	mv	a0,s3
    800014f8:	408040ef          	jal	80005900 <acquire>
  p->xstate = status;
    800014fc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001500:	4795                	li	a5,5
    80001502:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001506:	8526                	mv	a0,s1
    80001508:	490040ef          	jal	80005998 <release>
  sched();
    8000150c:	d7dff0ef          	jal	80001288 <sched>
  panic("zombie exit");
    80001510:	00006517          	auipc	a0,0x6
    80001514:	d3050513          	addi	a0,a0,-720 # 80007240 <etext+0x240>
    80001518:	0ba040ef          	jal	800055d2 <panic>

000000008000151c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000151c:	7179                	addi	sp,sp,-48
    8000151e:	f406                	sd	ra,40(sp)
    80001520:	f022                	sd	s0,32(sp)
    80001522:	ec26                	sd	s1,24(sp)
    80001524:	e84a                	sd	s2,16(sp)
    80001526:	e44e                	sd	s3,8(sp)
    80001528:	1800                	addi	s0,sp,48
    8000152a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000152c:	00007497          	auipc	s1,0x7
    80001530:	a4448493          	addi	s1,s1,-1468 # 80007f70 <proc>
    80001534:	0000c997          	auipc	s3,0xc
    80001538:	63c98993          	addi	s3,s3,1596 # 8000db70 <tickslock>
    acquire(&p->lock);
    8000153c:	8526                	mv	a0,s1
    8000153e:	3c2040ef          	jal	80005900 <acquire>
    if(p->pid == pid){
    80001542:	589c                	lw	a5,48(s1)
    80001544:	01278b63          	beq	a5,s2,8000155a <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001548:	8526                	mv	a0,s1
    8000154a:	44e040ef          	jal	80005998 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000154e:	17048493          	addi	s1,s1,368
    80001552:	ff3495e3          	bne	s1,s3,8000153c <kill+0x20>
  }
  return -1;
    80001556:	557d                	li	a0,-1
    80001558:	a819                	j	8000156e <kill+0x52>
      p->killed = 1;
    8000155a:	4785                	li	a5,1
    8000155c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000155e:	4c98                	lw	a4,24(s1)
    80001560:	4789                	li	a5,2
    80001562:	00f70d63          	beq	a4,a5,8000157c <kill+0x60>
      release(&p->lock);
    80001566:	8526                	mv	a0,s1
    80001568:	430040ef          	jal	80005998 <release>
      return 0;
    8000156c:	4501                	li	a0,0
}
    8000156e:	70a2                	ld	ra,40(sp)
    80001570:	7402                	ld	s0,32(sp)
    80001572:	64e2                	ld	s1,24(sp)
    80001574:	6942                	ld	s2,16(sp)
    80001576:	69a2                	ld	s3,8(sp)
    80001578:	6145                	addi	sp,sp,48
    8000157a:	8082                	ret
        p->state = RUNNABLE;
    8000157c:	478d                	li	a5,3
    8000157e:	cc9c                	sw	a5,24(s1)
    80001580:	b7dd                	j	80001566 <kill+0x4a>

0000000080001582 <setkilled>:

void
setkilled(struct proc *p)
{
    80001582:	1101                	addi	sp,sp,-32
    80001584:	ec06                	sd	ra,24(sp)
    80001586:	e822                	sd	s0,16(sp)
    80001588:	e426                	sd	s1,8(sp)
    8000158a:	1000                	addi	s0,sp,32
    8000158c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000158e:	372040ef          	jal	80005900 <acquire>
  p->killed = 1;
    80001592:	4785                	li	a5,1
    80001594:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001596:	8526                	mv	a0,s1
    80001598:	400040ef          	jal	80005998 <release>
}
    8000159c:	60e2                	ld	ra,24(sp)
    8000159e:	6442                	ld	s0,16(sp)
    800015a0:	64a2                	ld	s1,8(sp)
    800015a2:	6105                	addi	sp,sp,32
    800015a4:	8082                	ret

00000000800015a6 <killed>:

int
killed(struct proc *p)
{
    800015a6:	1101                	addi	sp,sp,-32
    800015a8:	ec06                	sd	ra,24(sp)
    800015aa:	e822                	sd	s0,16(sp)
    800015ac:	e426                	sd	s1,8(sp)
    800015ae:	e04a                	sd	s2,0(sp)
    800015b0:	1000                	addi	s0,sp,32
    800015b2:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800015b4:	34c040ef          	jal	80005900 <acquire>
  k = p->killed;
    800015b8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800015bc:	8526                	mv	a0,s1
    800015be:	3da040ef          	jal	80005998 <release>
  return k;
}
    800015c2:	854a                	mv	a0,s2
    800015c4:	60e2                	ld	ra,24(sp)
    800015c6:	6442                	ld	s0,16(sp)
    800015c8:	64a2                	ld	s1,8(sp)
    800015ca:	6902                	ld	s2,0(sp)
    800015cc:	6105                	addi	sp,sp,32
    800015ce:	8082                	ret

00000000800015d0 <wait>:
{
    800015d0:	715d                	addi	sp,sp,-80
    800015d2:	e486                	sd	ra,72(sp)
    800015d4:	e0a2                	sd	s0,64(sp)
    800015d6:	fc26                	sd	s1,56(sp)
    800015d8:	f84a                	sd	s2,48(sp)
    800015da:	f44e                	sd	s3,40(sp)
    800015dc:	f052                	sd	s4,32(sp)
    800015de:	ec56                	sd	s5,24(sp)
    800015e0:	e85a                	sd	s6,16(sp)
    800015e2:	e45e                	sd	s7,8(sp)
    800015e4:	e062                	sd	s8,0(sp)
    800015e6:	0880                	addi	s0,sp,80
    800015e8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800015ea:	faeff0ef          	jal	80000d98 <myproc>
    800015ee:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800015f0:	00006517          	auipc	a0,0x6
    800015f4:	56850513          	addi	a0,a0,1384 # 80007b58 <wait_lock>
    800015f8:	308040ef          	jal	80005900 <acquire>
    havekids = 0;
    800015fc:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800015fe:	4a15                	li	s4,5
        havekids = 1;
    80001600:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001602:	0000c997          	auipc	s3,0xc
    80001606:	56e98993          	addi	s3,s3,1390 # 8000db70 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000160a:	00006c17          	auipc	s8,0x6
    8000160e:	54ec0c13          	addi	s8,s8,1358 # 80007b58 <wait_lock>
    80001612:	a871                	j	800016ae <wait+0xde>
          pid = pp->pid;
    80001614:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001618:	000b0c63          	beqz	s6,80001630 <wait+0x60>
    8000161c:	4691                	li	a3,4
    8000161e:	02c48613          	addi	a2,s1,44
    80001622:	85da                	mv	a1,s6
    80001624:	05093503          	ld	a0,80(s2)
    80001628:	be0ff0ef          	jal	80000a08 <copyout>
    8000162c:	02054b63          	bltz	a0,80001662 <wait+0x92>
          freeproc(pp);
    80001630:	8526                	mv	a0,s1
    80001632:	8d9ff0ef          	jal	80000f0a <freeproc>
          release(&pp->lock);
    80001636:	8526                	mv	a0,s1
    80001638:	360040ef          	jal	80005998 <release>
          release(&wait_lock);
    8000163c:	00006517          	auipc	a0,0x6
    80001640:	51c50513          	addi	a0,a0,1308 # 80007b58 <wait_lock>
    80001644:	354040ef          	jal	80005998 <release>
}
    80001648:	854e                	mv	a0,s3
    8000164a:	60a6                	ld	ra,72(sp)
    8000164c:	6406                	ld	s0,64(sp)
    8000164e:	74e2                	ld	s1,56(sp)
    80001650:	7942                	ld	s2,48(sp)
    80001652:	79a2                	ld	s3,40(sp)
    80001654:	7a02                	ld	s4,32(sp)
    80001656:	6ae2                	ld	s5,24(sp)
    80001658:	6b42                	ld	s6,16(sp)
    8000165a:	6ba2                	ld	s7,8(sp)
    8000165c:	6c02                	ld	s8,0(sp)
    8000165e:	6161                	addi	sp,sp,80
    80001660:	8082                	ret
            release(&pp->lock);
    80001662:	8526                	mv	a0,s1
    80001664:	334040ef          	jal	80005998 <release>
            release(&wait_lock);
    80001668:	00006517          	auipc	a0,0x6
    8000166c:	4f050513          	addi	a0,a0,1264 # 80007b58 <wait_lock>
    80001670:	328040ef          	jal	80005998 <release>
            return -1;
    80001674:	59fd                	li	s3,-1
    80001676:	bfc9                	j	80001648 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001678:	17048493          	addi	s1,s1,368
    8000167c:	03348063          	beq	s1,s3,8000169c <wait+0xcc>
      if(pp->parent == p){
    80001680:	7c9c                	ld	a5,56(s1)
    80001682:	ff279be3          	bne	a5,s2,80001678 <wait+0xa8>
        acquire(&pp->lock);
    80001686:	8526                	mv	a0,s1
    80001688:	278040ef          	jal	80005900 <acquire>
        if(pp->state == ZOMBIE){
    8000168c:	4c9c                	lw	a5,24(s1)
    8000168e:	f94783e3          	beq	a5,s4,80001614 <wait+0x44>
        release(&pp->lock);
    80001692:	8526                	mv	a0,s1
    80001694:	304040ef          	jal	80005998 <release>
        havekids = 1;
    80001698:	8756                	mv	a4,s5
    8000169a:	bff9                	j	80001678 <wait+0xa8>
    if(!havekids || killed(p)){
    8000169c:	cf19                	beqz	a4,800016ba <wait+0xea>
    8000169e:	854a                	mv	a0,s2
    800016a0:	f07ff0ef          	jal	800015a6 <killed>
    800016a4:	e919                	bnez	a0,800016ba <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800016a6:	85e2                	mv	a1,s8
    800016a8:	854a                	mv	a0,s2
    800016aa:	cc5ff0ef          	jal	8000136e <sleep>
    havekids = 0;
    800016ae:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800016b0:	00007497          	auipc	s1,0x7
    800016b4:	8c048493          	addi	s1,s1,-1856 # 80007f70 <proc>
    800016b8:	b7e1                	j	80001680 <wait+0xb0>
      release(&wait_lock);
    800016ba:	00006517          	auipc	a0,0x6
    800016be:	49e50513          	addi	a0,a0,1182 # 80007b58 <wait_lock>
    800016c2:	2d6040ef          	jal	80005998 <release>
      return -1;
    800016c6:	59fd                	li	s3,-1
    800016c8:	b741                	j	80001648 <wait+0x78>

00000000800016ca <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800016ca:	7179                	addi	sp,sp,-48
    800016cc:	f406                	sd	ra,40(sp)
    800016ce:	f022                	sd	s0,32(sp)
    800016d0:	ec26                	sd	s1,24(sp)
    800016d2:	e84a                	sd	s2,16(sp)
    800016d4:	e44e                	sd	s3,8(sp)
    800016d6:	e052                	sd	s4,0(sp)
    800016d8:	1800                	addi	s0,sp,48
    800016da:	84aa                	mv	s1,a0
    800016dc:	892e                	mv	s2,a1
    800016de:	89b2                	mv	s3,a2
    800016e0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800016e2:	eb6ff0ef          	jal	80000d98 <myproc>
  if(user_dst){
    800016e6:	cc99                	beqz	s1,80001704 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800016e8:	86d2                	mv	a3,s4
    800016ea:	864e                	mv	a2,s3
    800016ec:	85ca                	mv	a1,s2
    800016ee:	6928                	ld	a0,80(a0)
    800016f0:	b18ff0ef          	jal	80000a08 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800016f4:	70a2                	ld	ra,40(sp)
    800016f6:	7402                	ld	s0,32(sp)
    800016f8:	64e2                	ld	s1,24(sp)
    800016fa:	6942                	ld	s2,16(sp)
    800016fc:	69a2                	ld	s3,8(sp)
    800016fe:	6a02                	ld	s4,0(sp)
    80001700:	6145                	addi	sp,sp,48
    80001702:	8082                	ret
    memmove((char *)dst, src, len);
    80001704:	000a061b          	sext.w	a2,s4
    80001708:	85ce                	mv	a1,s3
    8000170a:	854a                	mv	a0,s2
    8000170c:	ac7fe0ef          	jal	800001d2 <memmove>
    return 0;
    80001710:	8526                	mv	a0,s1
    80001712:	b7cd                	j	800016f4 <either_copyout+0x2a>

0000000080001714 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001714:	7179                	addi	sp,sp,-48
    80001716:	f406                	sd	ra,40(sp)
    80001718:	f022                	sd	s0,32(sp)
    8000171a:	ec26                	sd	s1,24(sp)
    8000171c:	e84a                	sd	s2,16(sp)
    8000171e:	e44e                	sd	s3,8(sp)
    80001720:	e052                	sd	s4,0(sp)
    80001722:	1800                	addi	s0,sp,48
    80001724:	892a                	mv	s2,a0
    80001726:	84ae                	mv	s1,a1
    80001728:	89b2                	mv	s3,a2
    8000172a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000172c:	e6cff0ef          	jal	80000d98 <myproc>
  if(user_src){
    80001730:	cc99                	beqz	s1,8000174e <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80001732:	86d2                	mv	a3,s4
    80001734:	864e                	mv	a2,s3
    80001736:	85ca                	mv	a1,s2
    80001738:	6928                	ld	a0,80(a0)
    8000173a:	ba6ff0ef          	jal	80000ae0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000173e:	70a2                	ld	ra,40(sp)
    80001740:	7402                	ld	s0,32(sp)
    80001742:	64e2                	ld	s1,24(sp)
    80001744:	6942                	ld	s2,16(sp)
    80001746:	69a2                	ld	s3,8(sp)
    80001748:	6a02                	ld	s4,0(sp)
    8000174a:	6145                	addi	sp,sp,48
    8000174c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000174e:	000a061b          	sext.w	a2,s4
    80001752:	85ce                	mv	a1,s3
    80001754:	854a                	mv	a0,s2
    80001756:	a7dfe0ef          	jal	800001d2 <memmove>
    return 0;
    8000175a:	8526                	mv	a0,s1
    8000175c:	b7cd                	j	8000173e <either_copyin+0x2a>

000000008000175e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000175e:	715d                	addi	sp,sp,-80
    80001760:	e486                	sd	ra,72(sp)
    80001762:	e0a2                	sd	s0,64(sp)
    80001764:	fc26                	sd	s1,56(sp)
    80001766:	f84a                	sd	s2,48(sp)
    80001768:	f44e                	sd	s3,40(sp)
    8000176a:	f052                	sd	s4,32(sp)
    8000176c:	ec56                	sd	s5,24(sp)
    8000176e:	e85a                	sd	s6,16(sp)
    80001770:	e45e                	sd	s7,8(sp)
    80001772:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001774:	00006517          	auipc	a0,0x6
    80001778:	8a450513          	addi	a0,a0,-1884 # 80007018 <etext+0x18>
    8000177c:	385030ef          	jal	80005300 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001780:	00007497          	auipc	s1,0x7
    80001784:	94848493          	addi	s1,s1,-1720 # 800080c8 <proc+0x158>
    80001788:	0000c917          	auipc	s2,0xc
    8000178c:	54090913          	addi	s2,s2,1344 # 8000dcc8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001790:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001792:	00006997          	auipc	s3,0x6
    80001796:	abe98993          	addi	s3,s3,-1346 # 80007250 <etext+0x250>
    printf("%d %s %s", p->pid, state, p->name);
    8000179a:	00006a97          	auipc	s5,0x6
    8000179e:	abea8a93          	addi	s5,s5,-1346 # 80007258 <etext+0x258>
    printf("\n");
    800017a2:	00006a17          	auipc	s4,0x6
    800017a6:	876a0a13          	addi	s4,s4,-1930 # 80007018 <etext+0x18>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017aa:	00006b97          	auipc	s7,0x6
    800017ae:	0aeb8b93          	addi	s7,s7,174 # 80007858 <states.0>
    800017b2:	a829                	j	800017cc <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800017b4:	ed86a583          	lw	a1,-296(a3)
    800017b8:	8556                	mv	a0,s5
    800017ba:	347030ef          	jal	80005300 <printf>
    printf("\n");
    800017be:	8552                	mv	a0,s4
    800017c0:	341030ef          	jal	80005300 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800017c4:	17048493          	addi	s1,s1,368
    800017c8:	03248263          	beq	s1,s2,800017ec <procdump+0x8e>
    if(p->state == UNUSED)
    800017cc:	86a6                	mv	a3,s1
    800017ce:	ec04a783          	lw	a5,-320(s1)
    800017d2:	dbed                	beqz	a5,800017c4 <procdump+0x66>
      state = "???";
    800017d4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800017d6:	fcfb6fe3          	bltu	s6,a5,800017b4 <procdump+0x56>
    800017da:	02079713          	slli	a4,a5,0x20
    800017de:	01d75793          	srli	a5,a4,0x1d
    800017e2:	97de                	add	a5,a5,s7
    800017e4:	6390                	ld	a2,0(a5)
    800017e6:	f679                	bnez	a2,800017b4 <procdump+0x56>
      state = "???";
    800017e8:	864e                	mv	a2,s3
    800017ea:	b7e9                	j	800017b4 <procdump+0x56>
  }
}
    800017ec:	60a6                	ld	ra,72(sp)
    800017ee:	6406                	ld	s0,64(sp)
    800017f0:	74e2                	ld	s1,56(sp)
    800017f2:	7942                	ld	s2,48(sp)
    800017f4:	79a2                	ld	s3,40(sp)
    800017f6:	7a02                	ld	s4,32(sp)
    800017f8:	6ae2                	ld	s5,24(sp)
    800017fa:	6b42                	ld	s6,16(sp)
    800017fc:	6ba2                	ld	s7,8(sp)
    800017fe:	6161                	addi	sp,sp,80
    80001800:	8082                	ret

0000000080001802 <kcollect_nproc>:

uint64
kcollect_nproc(void)
{
    80001802:	1141                	addi	sp,sp,-16
    80001804:	e422                	sd	s0,8(sp)
    80001806:	0800                	addi	s0,sp,16
  struct proc *p;
  uint64 count = 0;
    80001808:	4501                	li	a0,0

  for(p = proc; p < &proc[NCPU]; p++){
    8000180a:	00006797          	auipc	a5,0x6
    8000180e:	76678793          	addi	a5,a5,1894 # 80007f70 <proc>
    80001812:	00007697          	auipc	a3,0x7
    80001816:	2de68693          	addi	a3,a3,734 # 80008af0 <proc+0xb80>
    if(p->state != UNUSED) {
    8000181a:	4f98                	lw	a4,24(a5)
      count++;
    8000181c:	00e03733          	snez	a4,a4
    80001820:	953a                	add	a0,a0,a4
  for(p = proc; p < &proc[NCPU]; p++){
    80001822:	17078793          	addi	a5,a5,368
    80001826:	fed79ae3          	bne	a5,a3,8000181a <kcollect_nproc+0x18>
    }
  }
  return count;
}
    8000182a:	6422                	ld	s0,8(sp)
    8000182c:	0141                	addi	sp,sp,16
    8000182e:	8082                	ret

0000000080001830 <kcollect_load>:

uint64
kcollect_load(void)
{
    80001830:	1141                	addi	sp,sp,-16
    80001832:	e422                	sd	s0,8(sp)
    80001834:	0800                	addi	s0,sp,16
  struct proc *p;
  uint64 count = 0;
    80001836:	4501                	li	a0,0

  for(p = proc; p < &proc[NPROC]; p++){
    80001838:	00006717          	auipc	a4,0x6
    8000183c:	73870713          	addi	a4,a4,1848 # 80007f70 <proc>
    if(p->state == RUNNING || p->state == RUNNABLE)
    80001840:	4605                	li	a2,1
  for(p = proc; p < &proc[NPROC]; p++){
    80001842:	0000c697          	auipc	a3,0xc
    80001846:	32e68693          	addi	a3,a3,814 # 8000db70 <tickslock>
    if(p->state == RUNNING || p->state == RUNNABLE)
    8000184a:	4f1c                	lw	a5,24(a4)
    8000184c:	37f5                	addiw	a5,a5,-3
      count++;
    8000184e:	00f637b3          	sltu	a5,a2,a5
    80001852:	0017c793          	xori	a5,a5,1
    80001856:	953e                	add	a0,a0,a5
  for(p = proc; p < &proc[NPROC]; p++){
    80001858:	17070713          	addi	a4,a4,368
    8000185c:	fed717e3          	bne	a4,a3,8000184a <kcollect_load+0x1a>
  }
  
  return count;
    80001860:	6422                	ld	s0,8(sp)
    80001862:	0141                	addi	sp,sp,16
    80001864:	8082                	ret

0000000080001866 <swtch>:
    80001866:	00153023          	sd	ra,0(a0)
    8000186a:	00253423          	sd	sp,8(a0)
    8000186e:	e900                	sd	s0,16(a0)
    80001870:	ed04                	sd	s1,24(a0)
    80001872:	03253023          	sd	s2,32(a0)
    80001876:	03353423          	sd	s3,40(a0)
    8000187a:	03453823          	sd	s4,48(a0)
    8000187e:	03553c23          	sd	s5,56(a0)
    80001882:	05653023          	sd	s6,64(a0)
    80001886:	05753423          	sd	s7,72(a0)
    8000188a:	05853823          	sd	s8,80(a0)
    8000188e:	05953c23          	sd	s9,88(a0)
    80001892:	07a53023          	sd	s10,96(a0)
    80001896:	07b53423          	sd	s11,104(a0)
    8000189a:	0005b083          	ld	ra,0(a1)
    8000189e:	0085b103          	ld	sp,8(a1)
    800018a2:	6980                	ld	s0,16(a1)
    800018a4:	6d84                	ld	s1,24(a1)
    800018a6:	0205b903          	ld	s2,32(a1)
    800018aa:	0285b983          	ld	s3,40(a1)
    800018ae:	0305ba03          	ld	s4,48(a1)
    800018b2:	0385ba83          	ld	s5,56(a1)
    800018b6:	0405bb03          	ld	s6,64(a1)
    800018ba:	0485bb83          	ld	s7,72(a1)
    800018be:	0505bc03          	ld	s8,80(a1)
    800018c2:	0585bc83          	ld	s9,88(a1)
    800018c6:	0605bd03          	ld	s10,96(a1)
    800018ca:	0685bd83          	ld	s11,104(a1)
    800018ce:	8082                	ret

00000000800018d0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800018d0:	1141                	addi	sp,sp,-16
    800018d2:	e406                	sd	ra,8(sp)
    800018d4:	e022                	sd	s0,0(sp)
    800018d6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800018d8:	00006597          	auipc	a1,0x6
    800018dc:	9c058593          	addi	a1,a1,-1600 # 80007298 <etext+0x298>
    800018e0:	0000c517          	auipc	a0,0xc
    800018e4:	29050513          	addi	a0,a0,656 # 8000db70 <tickslock>
    800018e8:	799030ef          	jal	80005880 <initlock>
}
    800018ec:	60a2                	ld	ra,8(sp)
    800018ee:	6402                	ld	s0,0(sp)
    800018f0:	0141                	addi	sp,sp,16
    800018f2:	8082                	ret

00000000800018f4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800018f4:	1141                	addi	sp,sp,-16
    800018f6:	e422                	sd	s0,8(sp)
    800018f8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800018fa:	00003797          	auipc	a5,0x3
    800018fe:	f4678793          	addi	a5,a5,-186 # 80004840 <kernelvec>
    80001902:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001906:	6422                	ld	s0,8(sp)
    80001908:	0141                	addi	sp,sp,16
    8000190a:	8082                	ret

000000008000190c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000190c:	1141                	addi	sp,sp,-16
    8000190e:	e406                	sd	ra,8(sp)
    80001910:	e022                	sd	s0,0(sp)
    80001912:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001914:	c84ff0ef          	jal	80000d98 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001918:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000191c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000191e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001922:	00004697          	auipc	a3,0x4
    80001926:	6de68693          	addi	a3,a3,1758 # 80006000 <_trampoline>
    8000192a:	00004717          	auipc	a4,0x4
    8000192e:	6d670713          	addi	a4,a4,1750 # 80006000 <_trampoline>
    80001932:	8f15                	sub	a4,a4,a3
    80001934:	040007b7          	lui	a5,0x4000
    80001938:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000193a:	07b2                	slli	a5,a5,0xc
    8000193c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000193e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001942:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001944:	18002673          	csrr	a2,satp
    80001948:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000194a:	6d30                	ld	a2,88(a0)
    8000194c:	6138                	ld	a4,64(a0)
    8000194e:	6585                	lui	a1,0x1
    80001950:	972e                	add	a4,a4,a1
    80001952:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001954:	6d38                	ld	a4,88(a0)
    80001956:	00000617          	auipc	a2,0x0
    8000195a:	11060613          	addi	a2,a2,272 # 80001a66 <usertrap>
    8000195e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001960:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001962:	8612                	mv	a2,tp
    80001964:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001966:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000196a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000196e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001972:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001976:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001978:	6f18                	ld	a4,24(a4)
    8000197a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000197e:	6928                	ld	a0,80(a0)
    80001980:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001982:	00004717          	auipc	a4,0x4
    80001986:	71a70713          	addi	a4,a4,1818 # 8000609c <userret>
    8000198a:	8f15                	sub	a4,a4,a3
    8000198c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000198e:	577d                	li	a4,-1
    80001990:	177e                	slli	a4,a4,0x3f
    80001992:	8d59                	or	a0,a0,a4
    80001994:	9782                	jalr	a5
}
    80001996:	60a2                	ld	ra,8(sp)
    80001998:	6402                	ld	s0,0(sp)
    8000199a:	0141                	addi	sp,sp,16
    8000199c:	8082                	ret

000000008000199e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000199e:	1101                	addi	sp,sp,-32
    800019a0:	ec06                	sd	ra,24(sp)
    800019a2:	e822                	sd	s0,16(sp)
    800019a4:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800019a6:	bc6ff0ef          	jal	80000d6c <cpuid>
    800019aa:	cd11                	beqz	a0,800019c6 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800019ac:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800019b0:	000f4737          	lui	a4,0xf4
    800019b4:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800019b8:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800019ba:	14d79073          	csrw	stimecmp,a5
}
    800019be:	60e2                	ld	ra,24(sp)
    800019c0:	6442                	ld	s0,16(sp)
    800019c2:	6105                	addi	sp,sp,32
    800019c4:	8082                	ret
    800019c6:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800019c8:	0000c497          	auipc	s1,0xc
    800019cc:	1a848493          	addi	s1,s1,424 # 8000db70 <tickslock>
    800019d0:	8526                	mv	a0,s1
    800019d2:	72f030ef          	jal	80005900 <acquire>
    ticks++;
    800019d6:	00006517          	auipc	a0,0x6
    800019da:	13250513          	addi	a0,a0,306 # 80007b08 <ticks>
    800019de:	411c                	lw	a5,0(a0)
    800019e0:	2785                	addiw	a5,a5,1
    800019e2:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800019e4:	9d7ff0ef          	jal	800013ba <wakeup>
    release(&tickslock);
    800019e8:	8526                	mv	a0,s1
    800019ea:	7af030ef          	jal	80005998 <release>
    800019ee:	64a2                	ld	s1,8(sp)
    800019f0:	bf75                	j	800019ac <clockintr+0xe>

00000000800019f2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800019f2:	1101                	addi	sp,sp,-32
    800019f4:	ec06                	sd	ra,24(sp)
    800019f6:	e822                	sd	s0,16(sp)
    800019f8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800019fa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    800019fe:	57fd                	li	a5,-1
    80001a00:	17fe                	slli	a5,a5,0x3f
    80001a02:	07a5                	addi	a5,a5,9
    80001a04:	00f70c63          	beq	a4,a5,80001a1c <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80001a08:	57fd                	li	a5,-1
    80001a0a:	17fe                	slli	a5,a5,0x3f
    80001a0c:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80001a0e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80001a10:	04f70763          	beq	a4,a5,80001a5e <devintr+0x6c>
  }
}
    80001a14:	60e2                	ld	ra,24(sp)
    80001a16:	6442                	ld	s0,16(sp)
    80001a18:	6105                	addi	sp,sp,32
    80001a1a:	8082                	ret
    80001a1c:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80001a1e:	6cf020ef          	jal	800048ec <plic_claim>
    80001a22:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001a24:	47a9                	li	a5,10
    80001a26:	00f50963          	beq	a0,a5,80001a38 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80001a2a:	4785                	li	a5,1
    80001a2c:	00f50963          	beq	a0,a5,80001a3e <devintr+0x4c>
    return 1;
    80001a30:	4505                	li	a0,1
    } else if(irq){
    80001a32:	e889                	bnez	s1,80001a44 <devintr+0x52>
    80001a34:	64a2                	ld	s1,8(sp)
    80001a36:	bff9                	j	80001a14 <devintr+0x22>
      uartintr();
    80001a38:	60d030ef          	jal	80005844 <uartintr>
    if(irq)
    80001a3c:	a819                	j	80001a52 <devintr+0x60>
      virtio_disk_intr();
    80001a3e:	374030ef          	jal	80004db2 <virtio_disk_intr>
    if(irq)
    80001a42:	a801                	j	80001a52 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80001a44:	85a6                	mv	a1,s1
    80001a46:	00006517          	auipc	a0,0x6
    80001a4a:	85a50513          	addi	a0,a0,-1958 # 800072a0 <etext+0x2a0>
    80001a4e:	0b3030ef          	jal	80005300 <printf>
      plic_complete(irq);
    80001a52:	8526                	mv	a0,s1
    80001a54:	6b9020ef          	jal	8000490c <plic_complete>
    return 1;
    80001a58:	4505                	li	a0,1
    80001a5a:	64a2                	ld	s1,8(sp)
    80001a5c:	bf65                	j	80001a14 <devintr+0x22>
    clockintr();
    80001a5e:	f41ff0ef          	jal	8000199e <clockintr>
    return 2;
    80001a62:	4509                	li	a0,2
    80001a64:	bf45                	j	80001a14 <devintr+0x22>

0000000080001a66 <usertrap>:
{
    80001a66:	1101                	addi	sp,sp,-32
    80001a68:	ec06                	sd	ra,24(sp)
    80001a6a:	e822                	sd	s0,16(sp)
    80001a6c:	e426                	sd	s1,8(sp)
    80001a6e:	e04a                	sd	s2,0(sp)
    80001a70:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a72:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001a76:	1007f793          	andi	a5,a5,256
    80001a7a:	ef85                	bnez	a5,80001ab2 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001a7c:	00003797          	auipc	a5,0x3
    80001a80:	dc478793          	addi	a5,a5,-572 # 80004840 <kernelvec>
    80001a84:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001a88:	b10ff0ef          	jal	80000d98 <myproc>
    80001a8c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001a8e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001a90:	14102773          	csrr	a4,sepc
    80001a94:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001a96:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001a9a:	47a1                	li	a5,8
    80001a9c:	02f70163          	beq	a4,a5,80001abe <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80001aa0:	f53ff0ef          	jal	800019f2 <devintr>
    80001aa4:	892a                	mv	s2,a0
    80001aa6:	c135                	beqz	a0,80001b0a <usertrap+0xa4>
  if(killed(p))
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	afdff0ef          	jal	800015a6 <killed>
    80001aae:	cd1d                	beqz	a0,80001aec <usertrap+0x86>
    80001ab0:	a81d                	j	80001ae6 <usertrap+0x80>
    panic("usertrap: not from user mode");
    80001ab2:	00006517          	auipc	a0,0x6
    80001ab6:	80e50513          	addi	a0,a0,-2034 # 800072c0 <etext+0x2c0>
    80001aba:	319030ef          	jal	800055d2 <panic>
    if(killed(p))
    80001abe:	ae9ff0ef          	jal	800015a6 <killed>
    80001ac2:	e121                	bnez	a0,80001b02 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80001ac4:	6cb8                	ld	a4,88(s1)
    80001ac6:	6f1c                	ld	a5,24(a4)
    80001ac8:	0791                	addi	a5,a5,4
    80001aca:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001acc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ad0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ad4:	10079073          	csrw	sstatus,a5
    syscall();
    80001ad8:	248000ef          	jal	80001d20 <syscall>
  if(killed(p))
    80001adc:	8526                	mv	a0,s1
    80001ade:	ac9ff0ef          	jal	800015a6 <killed>
    80001ae2:	c901                	beqz	a0,80001af2 <usertrap+0x8c>
    80001ae4:	4901                	li	s2,0
    exit(-1);
    80001ae6:	557d                	li	a0,-1
    80001ae8:	993ff0ef          	jal	8000147a <exit>
  if(which_dev == 2)
    80001aec:	4789                	li	a5,2
    80001aee:	04f90563          	beq	s2,a5,80001b38 <usertrap+0xd2>
  usertrapret();
    80001af2:	e1bff0ef          	jal	8000190c <usertrapret>
}
    80001af6:	60e2                	ld	ra,24(sp)
    80001af8:	6442                	ld	s0,16(sp)
    80001afa:	64a2                	ld	s1,8(sp)
    80001afc:	6902                	ld	s2,0(sp)
    80001afe:	6105                	addi	sp,sp,32
    80001b00:	8082                	ret
      exit(-1);
    80001b02:	557d                	li	a0,-1
    80001b04:	977ff0ef          	jal	8000147a <exit>
    80001b08:	bf75                	j	80001ac4 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b0a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80001b0e:	5890                	lw	a2,48(s1)
    80001b10:	00005517          	auipc	a0,0x5
    80001b14:	7d050513          	addi	a0,a0,2000 # 800072e0 <etext+0x2e0>
    80001b18:	7e8030ef          	jal	80005300 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b1c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001b20:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80001b24:	00005517          	auipc	a0,0x5
    80001b28:	7ec50513          	addi	a0,a0,2028 # 80007310 <etext+0x310>
    80001b2c:	7d4030ef          	jal	80005300 <printf>
    setkilled(p);
    80001b30:	8526                	mv	a0,s1
    80001b32:	a51ff0ef          	jal	80001582 <setkilled>
    80001b36:	b75d                	j	80001adc <usertrap+0x76>
    yield();
    80001b38:	80bff0ef          	jal	80001342 <yield>
    80001b3c:	bf5d                	j	80001af2 <usertrap+0x8c>

0000000080001b3e <kerneltrap>:
{
    80001b3e:	7179                	addi	sp,sp,-48
    80001b40:	f406                	sd	ra,40(sp)
    80001b42:	f022                	sd	s0,32(sp)
    80001b44:	ec26                	sd	s1,24(sp)
    80001b46:	e84a                	sd	s2,16(sp)
    80001b48:	e44e                	sd	s3,8(sp)
    80001b4a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001b4c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b50:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001b54:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001b58:	1004f793          	andi	a5,s1,256
    80001b5c:	c795                	beqz	a5,80001b88 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b5e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001b62:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001b64:	eb85                	bnez	a5,80001b94 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80001b66:	e8dff0ef          	jal	800019f2 <devintr>
    80001b6a:	c91d                	beqz	a0,80001ba0 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80001b6c:	4789                	li	a5,2
    80001b6e:	04f50a63          	beq	a0,a5,80001bc2 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b72:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b76:	10049073          	csrw	sstatus,s1
}
    80001b7a:	70a2                	ld	ra,40(sp)
    80001b7c:	7402                	ld	s0,32(sp)
    80001b7e:	64e2                	ld	s1,24(sp)
    80001b80:	6942                	ld	s2,16(sp)
    80001b82:	69a2                	ld	s3,8(sp)
    80001b84:	6145                	addi	sp,sp,48
    80001b86:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001b88:	00005517          	auipc	a0,0x5
    80001b8c:	7b050513          	addi	a0,a0,1968 # 80007338 <etext+0x338>
    80001b90:	243030ef          	jal	800055d2 <panic>
    panic("kerneltrap: interrupts enabled");
    80001b94:	00005517          	auipc	a0,0x5
    80001b98:	7cc50513          	addi	a0,a0,1996 # 80007360 <etext+0x360>
    80001b9c:	237030ef          	jal	800055d2 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ba0:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001ba4:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80001ba8:	85ce                	mv	a1,s3
    80001baa:	00005517          	auipc	a0,0x5
    80001bae:	7d650513          	addi	a0,a0,2006 # 80007380 <etext+0x380>
    80001bb2:	74e030ef          	jal	80005300 <printf>
    panic("kerneltrap");
    80001bb6:	00005517          	auipc	a0,0x5
    80001bba:	7f250513          	addi	a0,a0,2034 # 800073a8 <etext+0x3a8>
    80001bbe:	215030ef          	jal	800055d2 <panic>
  if(which_dev == 2 && myproc() != 0)
    80001bc2:	9d6ff0ef          	jal	80000d98 <myproc>
    80001bc6:	d555                	beqz	a0,80001b72 <kerneltrap+0x34>
    yield();
    80001bc8:	f7aff0ef          	jal	80001342 <yield>
    80001bcc:	b75d                	j	80001b72 <kerneltrap+0x34>

0000000080001bce <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	1000                	addi	s0,sp,32
    80001bd8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bda:	9beff0ef          	jal	80000d98 <myproc>
  switch (n) {
    80001bde:	4795                	li	a5,5
    80001be0:	0497e163          	bltu	a5,s1,80001c22 <argraw+0x54>
    80001be4:	048a                	slli	s1,s1,0x2
    80001be6:	00006717          	auipc	a4,0x6
    80001bea:	ca270713          	addi	a4,a4,-862 # 80007888 <states.0+0x30>
    80001bee:	94ba                	add	s1,s1,a4
    80001bf0:	409c                	lw	a5,0(s1)
    80001bf2:	97ba                	add	a5,a5,a4
    80001bf4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001bf6:	6d3c                	ld	a5,88(a0)
    80001bf8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001bfa:	60e2                	ld	ra,24(sp)
    80001bfc:	6442                	ld	s0,16(sp)
    80001bfe:	64a2                	ld	s1,8(sp)
    80001c00:	6105                	addi	sp,sp,32
    80001c02:	8082                	ret
    return p->trapframe->a1;
    80001c04:	6d3c                	ld	a5,88(a0)
    80001c06:	7fa8                	ld	a0,120(a5)
    80001c08:	bfcd                	j	80001bfa <argraw+0x2c>
    return p->trapframe->a2;
    80001c0a:	6d3c                	ld	a5,88(a0)
    80001c0c:	63c8                	ld	a0,128(a5)
    80001c0e:	b7f5                	j	80001bfa <argraw+0x2c>
    return p->trapframe->a3;
    80001c10:	6d3c                	ld	a5,88(a0)
    80001c12:	67c8                	ld	a0,136(a5)
    80001c14:	b7dd                	j	80001bfa <argraw+0x2c>
    return p->trapframe->a4;
    80001c16:	6d3c                	ld	a5,88(a0)
    80001c18:	6bc8                	ld	a0,144(a5)
    80001c1a:	b7c5                	j	80001bfa <argraw+0x2c>
    return p->trapframe->a5;
    80001c1c:	6d3c                	ld	a5,88(a0)
    80001c1e:	6fc8                	ld	a0,152(a5)
    80001c20:	bfe9                	j	80001bfa <argraw+0x2c>
  panic("argraw");
    80001c22:	00005517          	auipc	a0,0x5
    80001c26:	79650513          	addi	a0,a0,1942 # 800073b8 <etext+0x3b8>
    80001c2a:	1a9030ef          	jal	800055d2 <panic>

0000000080001c2e <fetchaddr>:
{
    80001c2e:	1101                	addi	sp,sp,-32
    80001c30:	ec06                	sd	ra,24(sp)
    80001c32:	e822                	sd	s0,16(sp)
    80001c34:	e426                	sd	s1,8(sp)
    80001c36:	e04a                	sd	s2,0(sp)
    80001c38:	1000                	addi	s0,sp,32
    80001c3a:	84aa                	mv	s1,a0
    80001c3c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001c3e:	95aff0ef          	jal	80000d98 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001c42:	653c                	ld	a5,72(a0)
    80001c44:	02f4f663          	bgeu	s1,a5,80001c70 <fetchaddr+0x42>
    80001c48:	00848713          	addi	a4,s1,8
    80001c4c:	02e7e463          	bltu	a5,a4,80001c74 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001c50:	46a1                	li	a3,8
    80001c52:	8626                	mv	a2,s1
    80001c54:	85ca                	mv	a1,s2
    80001c56:	6928                	ld	a0,80(a0)
    80001c58:	e89fe0ef          	jal	80000ae0 <copyin>
    80001c5c:	00a03533          	snez	a0,a0
    80001c60:	40a00533          	neg	a0,a0
}
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6902                	ld	s2,0(sp)
    80001c6c:	6105                	addi	sp,sp,32
    80001c6e:	8082                	ret
    return -1;
    80001c70:	557d                	li	a0,-1
    80001c72:	bfcd                	j	80001c64 <fetchaddr+0x36>
    80001c74:	557d                	li	a0,-1
    80001c76:	b7fd                	j	80001c64 <fetchaddr+0x36>

0000000080001c78 <fetchstr>:
{
    80001c78:	7179                	addi	sp,sp,-48
    80001c7a:	f406                	sd	ra,40(sp)
    80001c7c:	f022                	sd	s0,32(sp)
    80001c7e:	ec26                	sd	s1,24(sp)
    80001c80:	e84a                	sd	s2,16(sp)
    80001c82:	e44e                	sd	s3,8(sp)
    80001c84:	1800                	addi	s0,sp,48
    80001c86:	892a                	mv	s2,a0
    80001c88:	84ae                	mv	s1,a1
    80001c8a:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001c8c:	90cff0ef          	jal	80000d98 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001c90:	86ce                	mv	a3,s3
    80001c92:	864a                	mv	a2,s2
    80001c94:	85a6                	mv	a1,s1
    80001c96:	6928                	ld	a0,80(a0)
    80001c98:	ecffe0ef          	jal	80000b66 <copyinstr>
    80001c9c:	00054c63          	bltz	a0,80001cb4 <fetchstr+0x3c>
  return strlen(buf);
    80001ca0:	8526                	mv	a0,s1
    80001ca2:	e44fe0ef          	jal	800002e6 <strlen>
}
    80001ca6:	70a2                	ld	ra,40(sp)
    80001ca8:	7402                	ld	s0,32(sp)
    80001caa:	64e2                	ld	s1,24(sp)
    80001cac:	6942                	ld	s2,16(sp)
    80001cae:	69a2                	ld	s3,8(sp)
    80001cb0:	6145                	addi	sp,sp,48
    80001cb2:	8082                	ret
    return -1;
    80001cb4:	557d                	li	a0,-1
    80001cb6:	bfc5                	j	80001ca6 <fetchstr+0x2e>

0000000080001cb8 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001cb8:	1101                	addi	sp,sp,-32
    80001cba:	ec06                	sd	ra,24(sp)
    80001cbc:	e822                	sd	s0,16(sp)
    80001cbe:	e426                	sd	s1,8(sp)
    80001cc0:	1000                	addi	s0,sp,32
    80001cc2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001cc4:	f0bff0ef          	jal	80001bce <argraw>
    80001cc8:	c088                	sw	a0,0(s1)
}
    80001cca:	60e2                	ld	ra,24(sp)
    80001ccc:	6442                	ld	s0,16(sp)
    80001cce:	64a2                	ld	s1,8(sp)
    80001cd0:	6105                	addi	sp,sp,32
    80001cd2:	8082                	ret

0000000080001cd4 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001cd4:	1101                	addi	sp,sp,-32
    80001cd6:	ec06                	sd	ra,24(sp)
    80001cd8:	e822                	sd	s0,16(sp)
    80001cda:	e426                	sd	s1,8(sp)
    80001cdc:	1000                	addi	s0,sp,32
    80001cde:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001ce0:	eefff0ef          	jal	80001bce <argraw>
    80001ce4:	e088                	sd	a0,0(s1)
}
    80001ce6:	60e2                	ld	ra,24(sp)
    80001ce8:	6442                	ld	s0,16(sp)
    80001cea:	64a2                	ld	s1,8(sp)
    80001cec:	6105                	addi	sp,sp,32
    80001cee:	8082                	ret

0000000080001cf0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001cf0:	7179                	addi	sp,sp,-48
    80001cf2:	f406                	sd	ra,40(sp)
    80001cf4:	f022                	sd	s0,32(sp)
    80001cf6:	ec26                	sd	s1,24(sp)
    80001cf8:	e84a                	sd	s2,16(sp)
    80001cfa:	1800                	addi	s0,sp,48
    80001cfc:	84ae                	mv	s1,a1
    80001cfe:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001d00:	fd840593          	addi	a1,s0,-40
    80001d04:	fd1ff0ef          	jal	80001cd4 <argaddr>
  return fetchstr(addr, buf, max);
    80001d08:	864a                	mv	a2,s2
    80001d0a:	85a6                	mv	a1,s1
    80001d0c:	fd843503          	ld	a0,-40(s0)
    80001d10:	f69ff0ef          	jal	80001c78 <fetchstr>
}
    80001d14:	70a2                	ld	ra,40(sp)
    80001d16:	7402                	ld	s0,32(sp)
    80001d18:	64e2                	ld	s1,24(sp)
    80001d1a:	6942                	ld	s2,16(sp)
    80001d1c:	6145                	addi	sp,sp,48
    80001d1e:	8082                	ret

0000000080001d20 <syscall>:
[SYS_sysinfo] 1,
};

void
syscall(void)
{
    80001d20:	7119                	addi	sp,sp,-128
    80001d22:	fc86                	sd	ra,120(sp)
    80001d24:	f8a2                	sd	s0,112(sp)
    80001d26:	f4a6                	sd	s1,104(sp)
    80001d28:	f0ca                	sd	s2,96(sp)
    80001d2a:	ecce                	sd	s3,88(sp)
    80001d2c:	0100                	addi	s0,sp,128
  int num;
  struct proc *p = myproc();
    80001d2e:	86aff0ef          	jal	80000d98 <myproc>
    80001d32:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80001d34:	05853903          	ld	s2,88(a0)
    80001d38:	0a893783          	ld	a5,168(s2)
    80001d3c:	0007899b          	sext.w	s3,a5

  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001d40:	37fd                	addiw	a5,a5,-1
    80001d42:	4759                	li	a4,22
    80001d44:	0cf76f63          	bltu	a4,a5,80001e22 <syscall+0x102>
    80001d48:	00399713          	slli	a4,s3,0x3
    80001d4c:	00006797          	auipc	a5,0x6
    80001d50:	b5478793          	addi	a5,a5,-1196 # 800078a0 <syscalls>
    80001d54:	97ba                	add	a5,a5,a4
    80001d56:	639c                	ld	a5,0(a5)
    80001d58:	c7e9                	beqz	a5,80001e22 <syscall+0x102>
    // Vì a0 sẽ bị ghi đè bởi giá trị trả về, ta cần lưu mảng args lại.
    // RISC-V dùng a0-a5 cho các tham số.
    uint64 args[6];
    args[0] = p->trapframe->a0;
    80001d5a:	07093703          	ld	a4,112(s2)
    80001d5e:	f8e43023          	sd	a4,-128(s0)
    args[1] = p->trapframe->a1;
    80001d62:	07893703          	ld	a4,120(s2)
    80001d66:	f8e43423          	sd	a4,-120(s0)
    args[2] = p->trapframe->a2;
    80001d6a:	08093703          	ld	a4,128(s2)
    80001d6e:	f8e43823          	sd	a4,-112(s0)
    args[3] = p->trapframe->a3;
    80001d72:	08893703          	ld	a4,136(s2)
    80001d76:	f8e43c23          	sd	a4,-104(s0)
    args[4] = p->trapframe->a4;
    80001d7a:	09093703          	ld	a4,144(s2)
    80001d7e:	fae43023          	sd	a4,-96(s0)
    args[5] = p->trapframe->a5;
    80001d82:	09893703          	ld	a4,152(s2)
    80001d86:	fae43423          	sd	a4,-88(s0)

    p->trapframe->a0 = syscalls[num]();
    80001d8a:	9782                	jalr	a5
    80001d8c:	06a93823          	sd	a0,112(s2)

    if((p->trace_mask >> num) & 1){
    80001d90:	1684a783          	lw	a5,360(s1)
    80001d94:	4137d7bb          	sraw	a5,a5,s3
    80001d98:	8b85                	andi	a5,a5,1
    80001d9a:	c3cd                	beqz	a5,80001e3c <syscall+0x11c>
    80001d9c:	e8d2                	sd	s4,80(sp)
      printf("%d: syscall %s(", p->pid, syscall_names[num]);
    80001d9e:	00006917          	auipc	s2,0x6
    80001da2:	b0290913          	addi	s2,s2,-1278 # 800078a0 <syscalls>
    80001da6:	00399793          	slli	a5,s3,0x3
    80001daa:	97ca                	add	a5,a5,s2
    80001dac:	63f0                	ld	a2,192(a5)
    80001dae:	588c                	lw	a1,48(s1)
    80001db0:	00005517          	auipc	a0,0x5
    80001db4:	61050513          	addi	a0,a0,1552 # 800073c0 <etext+0x3c0>
    80001db8:	548030ef          	jal	80005300 <printf>

      int n_args = syscall_argc[num];
    80001dbc:	098a                	slli	s3,s3,0x2
    80001dbe:	994e                	add	s2,s2,s3
    80001dc0:	18092a03          	lw	s4,384(s2)
      for(int i = 0; i < n_args; i++) {
    80001dc4:	05405563          	blez	s4,80001e0e <syscall+0xee>
    80001dc8:	e4d6                	sd	s5,72(sp)
    80001dca:	e0da                	sd	s6,64(sp)
    80001dcc:	fc5e                	sd	s7,56(sp)
    80001dce:	f8040993          	addi	s3,s0,-128
    80001dd2:	4901                	li	s2,0
        printf("%d", (int)args[i]); 
    80001dd4:	00005b17          	auipc	s6,0x5
    80001dd8:	5fcb0b13          	addi	s6,s6,1532 # 800073d0 <etext+0x3d0>
        if(i < n_args - 1) {
    80001ddc:	fffa0a9b          	addiw	s5,s4,-1
          printf(" "); 
    80001de0:	00005b97          	auipc	s7,0x5
    80001de4:	5f8b8b93          	addi	s7,s7,1528 # 800073d8 <etext+0x3d8>
    80001de8:	a029                	j	80001df2 <syscall+0xd2>
      for(int i = 0; i < n_args; i++) {
    80001dea:	2905                	addiw	s2,s2,1
    80001dec:	09a1                	addi	s3,s3,8
    80001dee:	012a0d63          	beq	s4,s2,80001e08 <syscall+0xe8>
        printf("%d", (int)args[i]); 
    80001df2:	0009a583          	lw	a1,0(s3)
    80001df6:	855a                	mv	a0,s6
    80001df8:	508030ef          	jal	80005300 <printf>
        if(i < n_args - 1) {
    80001dfc:	ff5957e3          	bge	s2,s5,80001dea <syscall+0xca>
          printf(" "); 
    80001e00:	855e                	mv	a0,s7
    80001e02:	4fe030ef          	jal	80005300 <printf>
    80001e06:	b7d5                	j	80001dea <syscall+0xca>
    80001e08:	6aa6                	ld	s5,72(sp)
    80001e0a:	6b06                	ld	s6,64(sp)
    80001e0c:	7be2                	ld	s7,56(sp)
        }
      }

      printf(") -> %d\n", (int)p->trapframe->a0);
    80001e0e:	6cbc                	ld	a5,88(s1)
    80001e10:	5bac                	lw	a1,112(a5)
    80001e12:	00005517          	auipc	a0,0x5
    80001e16:	5ce50513          	addi	a0,a0,1486 # 800073e0 <etext+0x3e0>
    80001e1a:	4e6030ef          	jal	80005300 <printf>
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80001e1e:	6a46                	ld	s4,80(sp)
    80001e20:	a831                	j	80001e3c <syscall+0x11c>
    }
  } 
  else {
    printf("%d %s: unknown sys call %d\n",
    80001e22:	86ce                	mv	a3,s3
    80001e24:	15848613          	addi	a2,s1,344
    80001e28:	588c                	lw	a1,48(s1)
    80001e2a:	00005517          	auipc	a0,0x5
    80001e2e:	5c650513          	addi	a0,a0,1478 # 800073f0 <etext+0x3f0>
    80001e32:	4ce030ef          	jal	80005300 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80001e36:	6cbc                	ld	a5,88(s1)
    80001e38:	577d                	li	a4,-1
    80001e3a:	fbb8                	sd	a4,112(a5)
  }
}
    80001e3c:	70e6                	ld	ra,120(sp)
    80001e3e:	7446                	ld	s0,112(sp)
    80001e40:	74a6                	ld	s1,104(sp)
    80001e42:	7906                	ld	s2,96(sp)
    80001e44:	69e6                	ld	s3,88(sp)
    80001e46:	6109                	addi	sp,sp,128
    80001e48:	8082                	ret

0000000080001e4a <sys_exit>:
#include "proc.h"
#include "sysinfo.h"

uint64
sys_exit(void)
{
    80001e4a:	1101                	addi	sp,sp,-32
    80001e4c:	ec06                	sd	ra,24(sp)
    80001e4e:	e822                	sd	s0,16(sp)
    80001e50:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80001e52:	fec40593          	addi	a1,s0,-20
    80001e56:	4501                	li	a0,0
    80001e58:	e61ff0ef          	jal	80001cb8 <argint>
  exit(n);
    80001e5c:	fec42503          	lw	a0,-20(s0)
    80001e60:	e1aff0ef          	jal	8000147a <exit>
  return 0;  // not reached
}
    80001e64:	4501                	li	a0,0
    80001e66:	60e2                	ld	ra,24(sp)
    80001e68:	6442                	ld	s0,16(sp)
    80001e6a:	6105                	addi	sp,sp,32
    80001e6c:	8082                	ret

0000000080001e6e <sys_getpid>:

uint64
sys_getpid(void)
{
    80001e6e:	1141                	addi	sp,sp,-16
    80001e70:	e406                	sd	ra,8(sp)
    80001e72:	e022                	sd	s0,0(sp)
    80001e74:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80001e76:	f23fe0ef          	jal	80000d98 <myproc>
}
    80001e7a:	5908                	lw	a0,48(a0)
    80001e7c:	60a2                	ld	ra,8(sp)
    80001e7e:	6402                	ld	s0,0(sp)
    80001e80:	0141                	addi	sp,sp,16
    80001e82:	8082                	ret

0000000080001e84 <sys_fork>:

uint64
sys_fork(void)
{
    80001e84:	1141                	addi	sp,sp,-16
    80001e86:	e406                	sd	ra,8(sp)
    80001e88:	e022                	sd	s0,0(sp)
    80001e8a:	0800                	addi	s0,sp,16
  return fork();
    80001e8c:	a32ff0ef          	jal	800010be <fork>
}
    80001e90:	60a2                	ld	ra,8(sp)
    80001e92:	6402                	ld	s0,0(sp)
    80001e94:	0141                	addi	sp,sp,16
    80001e96:	8082                	ret

0000000080001e98 <sys_wait>:

uint64
sys_wait(void)
{
    80001e98:	1101                	addi	sp,sp,-32
    80001e9a:	ec06                	sd	ra,24(sp)
    80001e9c:	e822                	sd	s0,16(sp)
    80001e9e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80001ea0:	fe840593          	addi	a1,s0,-24
    80001ea4:	4501                	li	a0,0
    80001ea6:	e2fff0ef          	jal	80001cd4 <argaddr>
  return wait(p);
    80001eaa:	fe843503          	ld	a0,-24(s0)
    80001eae:	f22ff0ef          	jal	800015d0 <wait>
}
    80001eb2:	60e2                	ld	ra,24(sp)
    80001eb4:	6442                	ld	s0,16(sp)
    80001eb6:	6105                	addi	sp,sp,32
    80001eb8:	8082                	ret

0000000080001eba <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80001eba:	7179                	addi	sp,sp,-48
    80001ebc:	f406                	sd	ra,40(sp)
    80001ebe:	f022                	sd	s0,32(sp)
    80001ec0:	ec26                	sd	s1,24(sp)
    80001ec2:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80001ec4:	fdc40593          	addi	a1,s0,-36
    80001ec8:	4501                	li	a0,0
    80001eca:	defff0ef          	jal	80001cb8 <argint>
  addr = myproc()->sz;
    80001ece:	ecbfe0ef          	jal	80000d98 <myproc>
    80001ed2:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80001ed4:	fdc42503          	lw	a0,-36(s0)
    80001ed8:	996ff0ef          	jal	8000106e <growproc>
    80001edc:	00054863          	bltz	a0,80001eec <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80001ee0:	8526                	mv	a0,s1
    80001ee2:	70a2                	ld	ra,40(sp)
    80001ee4:	7402                	ld	s0,32(sp)
    80001ee6:	64e2                	ld	s1,24(sp)
    80001ee8:	6145                	addi	sp,sp,48
    80001eea:	8082                	ret
    return -1;
    80001eec:	54fd                	li	s1,-1
    80001eee:	bfcd                	j	80001ee0 <sys_sbrk+0x26>

0000000080001ef0 <sys_sleep>:

uint64
sys_sleep(void)
{
    80001ef0:	7139                	addi	sp,sp,-64
    80001ef2:	fc06                	sd	ra,56(sp)
    80001ef4:	f822                	sd	s0,48(sp)
    80001ef6:	f04a                	sd	s2,32(sp)
    80001ef8:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80001efa:	fcc40593          	addi	a1,s0,-52
    80001efe:	4501                	li	a0,0
    80001f00:	db9ff0ef          	jal	80001cb8 <argint>
  if(n < 0)
    80001f04:	fcc42783          	lw	a5,-52(s0)
    80001f08:	0607c763          	bltz	a5,80001f76 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80001f0c:	0000c517          	auipc	a0,0xc
    80001f10:	c6450513          	addi	a0,a0,-924 # 8000db70 <tickslock>
    80001f14:	1ed030ef          	jal	80005900 <acquire>
  ticks0 = ticks;
    80001f18:	00006917          	auipc	s2,0x6
    80001f1c:	bf092903          	lw	s2,-1040(s2) # 80007b08 <ticks>
  while(ticks - ticks0 < n){
    80001f20:	fcc42783          	lw	a5,-52(s0)
    80001f24:	cf8d                	beqz	a5,80001f5e <sys_sleep+0x6e>
    80001f26:	f426                	sd	s1,40(sp)
    80001f28:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80001f2a:	0000c997          	auipc	s3,0xc
    80001f2e:	c4698993          	addi	s3,s3,-954 # 8000db70 <tickslock>
    80001f32:	00006497          	auipc	s1,0x6
    80001f36:	bd648493          	addi	s1,s1,-1066 # 80007b08 <ticks>
    if(killed(myproc())){
    80001f3a:	e5ffe0ef          	jal	80000d98 <myproc>
    80001f3e:	e68ff0ef          	jal	800015a6 <killed>
    80001f42:	ed0d                	bnez	a0,80001f7c <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80001f44:	85ce                	mv	a1,s3
    80001f46:	8526                	mv	a0,s1
    80001f48:	c26ff0ef          	jal	8000136e <sleep>
  while(ticks - ticks0 < n){
    80001f4c:	409c                	lw	a5,0(s1)
    80001f4e:	412787bb          	subw	a5,a5,s2
    80001f52:	fcc42703          	lw	a4,-52(s0)
    80001f56:	fee7e2e3          	bltu	a5,a4,80001f3a <sys_sleep+0x4a>
    80001f5a:	74a2                	ld	s1,40(sp)
    80001f5c:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80001f5e:	0000c517          	auipc	a0,0xc
    80001f62:	c1250513          	addi	a0,a0,-1006 # 8000db70 <tickslock>
    80001f66:	233030ef          	jal	80005998 <release>
  return 0;
    80001f6a:	4501                	li	a0,0
}
    80001f6c:	70e2                	ld	ra,56(sp)
    80001f6e:	7442                	ld	s0,48(sp)
    80001f70:	7902                	ld	s2,32(sp)
    80001f72:	6121                	addi	sp,sp,64
    80001f74:	8082                	ret
    n = 0;
    80001f76:	fc042623          	sw	zero,-52(s0)
    80001f7a:	bf49                	j	80001f0c <sys_sleep+0x1c>
      release(&tickslock);
    80001f7c:	0000c517          	auipc	a0,0xc
    80001f80:	bf450513          	addi	a0,a0,-1036 # 8000db70 <tickslock>
    80001f84:	215030ef          	jal	80005998 <release>
      return -1;
    80001f88:	557d                	li	a0,-1
    80001f8a:	74a2                	ld	s1,40(sp)
    80001f8c:	69e2                	ld	s3,24(sp)
    80001f8e:	bff9                	j	80001f6c <sys_sleep+0x7c>

0000000080001f90 <sys_kill>:

uint64
sys_kill(void)
{
    80001f90:	1101                	addi	sp,sp,-32
    80001f92:	ec06                	sd	ra,24(sp)
    80001f94:	e822                	sd	s0,16(sp)
    80001f96:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80001f98:	fec40593          	addi	a1,s0,-20
    80001f9c:	4501                	li	a0,0
    80001f9e:	d1bff0ef          	jal	80001cb8 <argint>
  return kill(pid);
    80001fa2:	fec42503          	lw	a0,-20(s0)
    80001fa6:	d76ff0ef          	jal	8000151c <kill>
}
    80001faa:	60e2                	ld	ra,24(sp)
    80001fac:	6442                	ld	s0,16(sp)
    80001fae:	6105                	addi	sp,sp,32
    80001fb0:	8082                	ret

0000000080001fb2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80001fb2:	1101                	addi	sp,sp,-32
    80001fb4:	ec06                	sd	ra,24(sp)
    80001fb6:	e822                	sd	s0,16(sp)
    80001fb8:	e426                	sd	s1,8(sp)
    80001fba:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80001fbc:	0000c517          	auipc	a0,0xc
    80001fc0:	bb450513          	addi	a0,a0,-1100 # 8000db70 <tickslock>
    80001fc4:	13d030ef          	jal	80005900 <acquire>
  xticks = ticks;
    80001fc8:	00006497          	auipc	s1,0x6
    80001fcc:	b404a483          	lw	s1,-1216(s1) # 80007b08 <ticks>
  release(&tickslock);
    80001fd0:	0000c517          	auipc	a0,0xc
    80001fd4:	ba050513          	addi	a0,a0,-1120 # 8000db70 <tickslock>
    80001fd8:	1c1030ef          	jal	80005998 <release>
  return xticks;
}
    80001fdc:	02049513          	slli	a0,s1,0x20
    80001fe0:	9101                	srli	a0,a0,0x20
    80001fe2:	60e2                	ld	ra,24(sp)
    80001fe4:	6442                	ld	s0,16(sp)
    80001fe6:	64a2                	ld	s1,8(sp)
    80001fe8:	6105                	addi	sp,sp,32
    80001fea:	8082                	ret

0000000080001fec <sys_trace>:

uint64
sys_trace(void)
{
    80001fec:	1101                	addi	sp,sp,-32
    80001fee:	ec06                	sd	ra,24(sp)
    80001ff0:	e822                	sd	s0,16(sp)
    80001ff2:	1000                	addi	s0,sp,32
  int mask;
  argint(0, &mask);
    80001ff4:	fec40593          	addi	a1,s0,-20
    80001ff8:	4501                	li	a0,0
    80001ffa:	cbfff0ef          	jal	80001cb8 <argint>
  
  myproc()->trace_mask = mask;
    80001ffe:	d9bfe0ef          	jal	80000d98 <myproc>
    80002002:	fec42783          	lw	a5,-20(s0)
    80002006:	16f52423          	sw	a5,360(a0)
  return 0;
}
    8000200a:	4501                	li	a0,0
    8000200c:	60e2                	ld	ra,24(sp)
    8000200e:	6442                	ld	s0,16(sp)
    80002010:	6105                	addi	sp,sp,32
    80002012:	8082                	ret

0000000080002014 <sys_sysinfo>:

uint64
sys_sysinfo(void)
{
    80002014:	7179                	addi	sp,sp,-48
    80002016:	f406                	sd	ra,40(sp)
    80002018:	f022                	sd	s0,32(sp)
    8000201a:	1800                	addi	s0,sp,48
  struct sysinfo info;
  uint64 addr;        

  argaddr(0, &addr);
    8000201c:	fd040593          	addi	a1,s0,-48
    80002020:	4501                	li	a0,0
    80002022:	cb3ff0ef          	jal	80001cd4 <argaddr>

  info.freemem = kcollect_free();
    80002026:	90efe0ef          	jal	80000134 <kcollect_free>
    8000202a:	fca43c23          	sd	a0,-40(s0)
  info.nproc = kcollect_nproc();
    8000202e:	fd4ff0ef          	jal	80001802 <kcollect_nproc>
    80002032:	fea43023          	sd	a0,-32(s0)
  info.load = kcollect_load();
    80002036:	ffaff0ef          	jal	80001830 <kcollect_load>
    8000203a:	fea43423          	sd	a0,-24(s0)

  if(copyout(myproc()->pagetable, addr, (char *)&info, sizeof(info)) < 0)
    8000203e:	d5bfe0ef          	jal	80000d98 <myproc>
    80002042:	46e1                	li	a3,24
    80002044:	fd840613          	addi	a2,s0,-40
    80002048:	fd043583          	ld	a1,-48(s0)
    8000204c:	6928                	ld	a0,80(a0)
    8000204e:	9bbfe0ef          	jal	80000a08 <copyout>
    return -1;

  return 0;
    80002052:	957d                	srai	a0,a0,0x3f
    80002054:	70a2                	ld	ra,40(sp)
    80002056:	7402                	ld	s0,32(sp)
    80002058:	6145                	addi	sp,sp,48
    8000205a:	8082                	ret

000000008000205c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000205c:	7179                	addi	sp,sp,-48
    8000205e:	f406                	sd	ra,40(sp)
    80002060:	f022                	sd	s0,32(sp)
    80002062:	ec26                	sd	s1,24(sp)
    80002064:	e84a                	sd	s2,16(sp)
    80002066:	e44e                	sd	s3,8(sp)
    80002068:	e052                	sd	s4,0(sp)
    8000206a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000206c:	00005597          	auipc	a1,0x5
    80002070:	45458593          	addi	a1,a1,1108 # 800074c0 <etext+0x4c0>
    80002074:	0000c517          	auipc	a0,0xc
    80002078:	b1450513          	addi	a0,a0,-1260 # 8000db88 <bcache>
    8000207c:	005030ef          	jal	80005880 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002080:	00014797          	auipc	a5,0x14
    80002084:	b0878793          	addi	a5,a5,-1272 # 80015b88 <bcache+0x8000>
    80002088:	00014717          	auipc	a4,0x14
    8000208c:	d6870713          	addi	a4,a4,-664 # 80015df0 <bcache+0x8268>
    80002090:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002094:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002098:	0000c497          	auipc	s1,0xc
    8000209c:	b0848493          	addi	s1,s1,-1272 # 8000dba0 <bcache+0x18>
    b->next = bcache.head.next;
    800020a0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800020a2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800020a4:	00005a17          	auipc	s4,0x5
    800020a8:	424a0a13          	addi	s4,s4,1060 # 800074c8 <etext+0x4c8>
    b->next = bcache.head.next;
    800020ac:	2b893783          	ld	a5,696(s2)
    800020b0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800020b2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800020b6:	85d2                	mv	a1,s4
    800020b8:	01048513          	addi	a0,s1,16
    800020bc:	248010ef          	jal	80003304 <initsleeplock>
    bcache.head.next->prev = b;
    800020c0:	2b893783          	ld	a5,696(s2)
    800020c4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800020c6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800020ca:	45848493          	addi	s1,s1,1112
    800020ce:	fd349fe3          	bne	s1,s3,800020ac <binit+0x50>
  }
}
    800020d2:	70a2                	ld	ra,40(sp)
    800020d4:	7402                	ld	s0,32(sp)
    800020d6:	64e2                	ld	s1,24(sp)
    800020d8:	6942                	ld	s2,16(sp)
    800020da:	69a2                	ld	s3,8(sp)
    800020dc:	6a02                	ld	s4,0(sp)
    800020de:	6145                	addi	sp,sp,48
    800020e0:	8082                	ret

00000000800020e2 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800020e2:	7179                	addi	sp,sp,-48
    800020e4:	f406                	sd	ra,40(sp)
    800020e6:	f022                	sd	s0,32(sp)
    800020e8:	ec26                	sd	s1,24(sp)
    800020ea:	e84a                	sd	s2,16(sp)
    800020ec:	e44e                	sd	s3,8(sp)
    800020ee:	1800                	addi	s0,sp,48
    800020f0:	892a                	mv	s2,a0
    800020f2:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800020f4:	0000c517          	auipc	a0,0xc
    800020f8:	a9450513          	addi	a0,a0,-1388 # 8000db88 <bcache>
    800020fc:	005030ef          	jal	80005900 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002100:	00014497          	auipc	s1,0x14
    80002104:	d404b483          	ld	s1,-704(s1) # 80015e40 <bcache+0x82b8>
    80002108:	00014797          	auipc	a5,0x14
    8000210c:	ce878793          	addi	a5,a5,-792 # 80015df0 <bcache+0x8268>
    80002110:	02f48b63          	beq	s1,a5,80002146 <bread+0x64>
    80002114:	873e                	mv	a4,a5
    80002116:	a021                	j	8000211e <bread+0x3c>
    80002118:	68a4                	ld	s1,80(s1)
    8000211a:	02e48663          	beq	s1,a4,80002146 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    8000211e:	449c                	lw	a5,8(s1)
    80002120:	ff279ce3          	bne	a5,s2,80002118 <bread+0x36>
    80002124:	44dc                	lw	a5,12(s1)
    80002126:	ff3799e3          	bne	a5,s3,80002118 <bread+0x36>
      b->refcnt++;
    8000212a:	40bc                	lw	a5,64(s1)
    8000212c:	2785                	addiw	a5,a5,1
    8000212e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002130:	0000c517          	auipc	a0,0xc
    80002134:	a5850513          	addi	a0,a0,-1448 # 8000db88 <bcache>
    80002138:	061030ef          	jal	80005998 <release>
      acquiresleep(&b->lock);
    8000213c:	01048513          	addi	a0,s1,16
    80002140:	1fa010ef          	jal	8000333a <acquiresleep>
      return b;
    80002144:	a889                	j	80002196 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002146:	00014497          	auipc	s1,0x14
    8000214a:	cf24b483          	ld	s1,-782(s1) # 80015e38 <bcache+0x82b0>
    8000214e:	00014797          	auipc	a5,0x14
    80002152:	ca278793          	addi	a5,a5,-862 # 80015df0 <bcache+0x8268>
    80002156:	00f48863          	beq	s1,a5,80002166 <bread+0x84>
    8000215a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000215c:	40bc                	lw	a5,64(s1)
    8000215e:	cb91                	beqz	a5,80002172 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002160:	64a4                	ld	s1,72(s1)
    80002162:	fee49de3          	bne	s1,a4,8000215c <bread+0x7a>
  panic("bget: no buffers");
    80002166:	00005517          	auipc	a0,0x5
    8000216a:	36a50513          	addi	a0,a0,874 # 800074d0 <etext+0x4d0>
    8000216e:	464030ef          	jal	800055d2 <panic>
      b->dev = dev;
    80002172:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002176:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000217a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000217e:	4785                	li	a5,1
    80002180:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002182:	0000c517          	auipc	a0,0xc
    80002186:	a0650513          	addi	a0,a0,-1530 # 8000db88 <bcache>
    8000218a:	00f030ef          	jal	80005998 <release>
      acquiresleep(&b->lock);
    8000218e:	01048513          	addi	a0,s1,16
    80002192:	1a8010ef          	jal	8000333a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002196:	409c                	lw	a5,0(s1)
    80002198:	cb89                	beqz	a5,800021aa <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000219a:	8526                	mv	a0,s1
    8000219c:	70a2                	ld	ra,40(sp)
    8000219e:	7402                	ld	s0,32(sp)
    800021a0:	64e2                	ld	s1,24(sp)
    800021a2:	6942                	ld	s2,16(sp)
    800021a4:	69a2                	ld	s3,8(sp)
    800021a6:	6145                	addi	sp,sp,48
    800021a8:	8082                	ret
    virtio_disk_rw(b, 0);
    800021aa:	4581                	li	a1,0
    800021ac:	8526                	mv	a0,s1
    800021ae:	1f3020ef          	jal	80004ba0 <virtio_disk_rw>
    b->valid = 1;
    800021b2:	4785                	li	a5,1
    800021b4:	c09c                	sw	a5,0(s1)
  return b;
    800021b6:	b7d5                	j	8000219a <bread+0xb8>

00000000800021b8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800021b8:	1101                	addi	sp,sp,-32
    800021ba:	ec06                	sd	ra,24(sp)
    800021bc:	e822                	sd	s0,16(sp)
    800021be:	e426                	sd	s1,8(sp)
    800021c0:	1000                	addi	s0,sp,32
    800021c2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800021c4:	0541                	addi	a0,a0,16
    800021c6:	1f2010ef          	jal	800033b8 <holdingsleep>
    800021ca:	c911                	beqz	a0,800021de <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800021cc:	4585                	li	a1,1
    800021ce:	8526                	mv	a0,s1
    800021d0:	1d1020ef          	jal	80004ba0 <virtio_disk_rw>
}
    800021d4:	60e2                	ld	ra,24(sp)
    800021d6:	6442                	ld	s0,16(sp)
    800021d8:	64a2                	ld	s1,8(sp)
    800021da:	6105                	addi	sp,sp,32
    800021dc:	8082                	ret
    panic("bwrite");
    800021de:	00005517          	auipc	a0,0x5
    800021e2:	30a50513          	addi	a0,a0,778 # 800074e8 <etext+0x4e8>
    800021e6:	3ec030ef          	jal	800055d2 <panic>

00000000800021ea <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800021ea:	1101                	addi	sp,sp,-32
    800021ec:	ec06                	sd	ra,24(sp)
    800021ee:	e822                	sd	s0,16(sp)
    800021f0:	e426                	sd	s1,8(sp)
    800021f2:	e04a                	sd	s2,0(sp)
    800021f4:	1000                	addi	s0,sp,32
    800021f6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800021f8:	01050913          	addi	s2,a0,16
    800021fc:	854a                	mv	a0,s2
    800021fe:	1ba010ef          	jal	800033b8 <holdingsleep>
    80002202:	c135                	beqz	a0,80002266 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002204:	854a                	mv	a0,s2
    80002206:	17a010ef          	jal	80003380 <releasesleep>

  acquire(&bcache.lock);
    8000220a:	0000c517          	auipc	a0,0xc
    8000220e:	97e50513          	addi	a0,a0,-1666 # 8000db88 <bcache>
    80002212:	6ee030ef          	jal	80005900 <acquire>
  b->refcnt--;
    80002216:	40bc                	lw	a5,64(s1)
    80002218:	37fd                	addiw	a5,a5,-1
    8000221a:	0007871b          	sext.w	a4,a5
    8000221e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002220:	e71d                	bnez	a4,8000224e <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002222:	68b8                	ld	a4,80(s1)
    80002224:	64bc                	ld	a5,72(s1)
    80002226:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002228:	68b8                	ld	a4,80(s1)
    8000222a:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000222c:	00014797          	auipc	a5,0x14
    80002230:	95c78793          	addi	a5,a5,-1700 # 80015b88 <bcache+0x8000>
    80002234:	2b87b703          	ld	a4,696(a5)
    80002238:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000223a:	00014717          	auipc	a4,0x14
    8000223e:	bb670713          	addi	a4,a4,-1098 # 80015df0 <bcache+0x8268>
    80002242:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002244:	2b87b703          	ld	a4,696(a5)
    80002248:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000224a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000224e:	0000c517          	auipc	a0,0xc
    80002252:	93a50513          	addi	a0,a0,-1734 # 8000db88 <bcache>
    80002256:	742030ef          	jal	80005998 <release>
}
    8000225a:	60e2                	ld	ra,24(sp)
    8000225c:	6442                	ld	s0,16(sp)
    8000225e:	64a2                	ld	s1,8(sp)
    80002260:	6902                	ld	s2,0(sp)
    80002262:	6105                	addi	sp,sp,32
    80002264:	8082                	ret
    panic("brelse");
    80002266:	00005517          	auipc	a0,0x5
    8000226a:	28a50513          	addi	a0,a0,650 # 800074f0 <etext+0x4f0>
    8000226e:	364030ef          	jal	800055d2 <panic>

0000000080002272 <bpin>:

void
bpin(struct buf *b) {
    80002272:	1101                	addi	sp,sp,-32
    80002274:	ec06                	sd	ra,24(sp)
    80002276:	e822                	sd	s0,16(sp)
    80002278:	e426                	sd	s1,8(sp)
    8000227a:	1000                	addi	s0,sp,32
    8000227c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000227e:	0000c517          	auipc	a0,0xc
    80002282:	90a50513          	addi	a0,a0,-1782 # 8000db88 <bcache>
    80002286:	67a030ef          	jal	80005900 <acquire>
  b->refcnt++;
    8000228a:	40bc                	lw	a5,64(s1)
    8000228c:	2785                	addiw	a5,a5,1
    8000228e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002290:	0000c517          	auipc	a0,0xc
    80002294:	8f850513          	addi	a0,a0,-1800 # 8000db88 <bcache>
    80002298:	700030ef          	jal	80005998 <release>
}
    8000229c:	60e2                	ld	ra,24(sp)
    8000229e:	6442                	ld	s0,16(sp)
    800022a0:	64a2                	ld	s1,8(sp)
    800022a2:	6105                	addi	sp,sp,32
    800022a4:	8082                	ret

00000000800022a6 <bunpin>:

void
bunpin(struct buf *b) {
    800022a6:	1101                	addi	sp,sp,-32
    800022a8:	ec06                	sd	ra,24(sp)
    800022aa:	e822                	sd	s0,16(sp)
    800022ac:	e426                	sd	s1,8(sp)
    800022ae:	1000                	addi	s0,sp,32
    800022b0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800022b2:	0000c517          	auipc	a0,0xc
    800022b6:	8d650513          	addi	a0,a0,-1834 # 8000db88 <bcache>
    800022ba:	646030ef          	jal	80005900 <acquire>
  b->refcnt--;
    800022be:	40bc                	lw	a5,64(s1)
    800022c0:	37fd                	addiw	a5,a5,-1
    800022c2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800022c4:	0000c517          	auipc	a0,0xc
    800022c8:	8c450513          	addi	a0,a0,-1852 # 8000db88 <bcache>
    800022cc:	6cc030ef          	jal	80005998 <release>
}
    800022d0:	60e2                	ld	ra,24(sp)
    800022d2:	6442                	ld	s0,16(sp)
    800022d4:	64a2                	ld	s1,8(sp)
    800022d6:	6105                	addi	sp,sp,32
    800022d8:	8082                	ret

00000000800022da <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800022da:	1101                	addi	sp,sp,-32
    800022dc:	ec06                	sd	ra,24(sp)
    800022de:	e822                	sd	s0,16(sp)
    800022e0:	e426                	sd	s1,8(sp)
    800022e2:	e04a                	sd	s2,0(sp)
    800022e4:	1000                	addi	s0,sp,32
    800022e6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800022e8:	00d5d59b          	srliw	a1,a1,0xd
    800022ec:	00014797          	auipc	a5,0x14
    800022f0:	f787a783          	lw	a5,-136(a5) # 80016264 <sb+0x1c>
    800022f4:	9dbd                	addw	a1,a1,a5
    800022f6:	dedff0ef          	jal	800020e2 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800022fa:	0074f713          	andi	a4,s1,7
    800022fe:	4785                	li	a5,1
    80002300:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002304:	14ce                	slli	s1,s1,0x33
    80002306:	90d9                	srli	s1,s1,0x36
    80002308:	00950733          	add	a4,a0,s1
    8000230c:	05874703          	lbu	a4,88(a4)
    80002310:	00e7f6b3          	and	a3,a5,a4
    80002314:	c29d                	beqz	a3,8000233a <bfree+0x60>
    80002316:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002318:	94aa                	add	s1,s1,a0
    8000231a:	fff7c793          	not	a5,a5
    8000231e:	8f7d                	and	a4,a4,a5
    80002320:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002324:	711000ef          	jal	80003234 <log_write>
  brelse(bp);
    80002328:	854a                	mv	a0,s2
    8000232a:	ec1ff0ef          	jal	800021ea <brelse>
}
    8000232e:	60e2                	ld	ra,24(sp)
    80002330:	6442                	ld	s0,16(sp)
    80002332:	64a2                	ld	s1,8(sp)
    80002334:	6902                	ld	s2,0(sp)
    80002336:	6105                	addi	sp,sp,32
    80002338:	8082                	ret
    panic("freeing free block");
    8000233a:	00005517          	auipc	a0,0x5
    8000233e:	1be50513          	addi	a0,a0,446 # 800074f8 <etext+0x4f8>
    80002342:	290030ef          	jal	800055d2 <panic>

0000000080002346 <balloc>:
{
    80002346:	711d                	addi	sp,sp,-96
    80002348:	ec86                	sd	ra,88(sp)
    8000234a:	e8a2                	sd	s0,80(sp)
    8000234c:	e4a6                	sd	s1,72(sp)
    8000234e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002350:	00014797          	auipc	a5,0x14
    80002354:	efc7a783          	lw	a5,-260(a5) # 8001624c <sb+0x4>
    80002358:	0e078f63          	beqz	a5,80002456 <balloc+0x110>
    8000235c:	e0ca                	sd	s2,64(sp)
    8000235e:	fc4e                	sd	s3,56(sp)
    80002360:	f852                	sd	s4,48(sp)
    80002362:	f456                	sd	s5,40(sp)
    80002364:	f05a                	sd	s6,32(sp)
    80002366:	ec5e                	sd	s7,24(sp)
    80002368:	e862                	sd	s8,16(sp)
    8000236a:	e466                	sd	s9,8(sp)
    8000236c:	8baa                	mv	s7,a0
    8000236e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002370:	00014b17          	auipc	s6,0x14
    80002374:	ed8b0b13          	addi	s6,s6,-296 # 80016248 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002378:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000237a:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000237c:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000237e:	6c89                	lui	s9,0x2
    80002380:	a0b5                	j	800023ec <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002382:	97ca                	add	a5,a5,s2
    80002384:	8e55                	or	a2,a2,a3
    80002386:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000238a:	854a                	mv	a0,s2
    8000238c:	6a9000ef          	jal	80003234 <log_write>
        brelse(bp);
    80002390:	854a                	mv	a0,s2
    80002392:	e59ff0ef          	jal	800021ea <brelse>
  bp = bread(dev, bno);
    80002396:	85a6                	mv	a1,s1
    80002398:	855e                	mv	a0,s7
    8000239a:	d49ff0ef          	jal	800020e2 <bread>
    8000239e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800023a0:	40000613          	li	a2,1024
    800023a4:	4581                	li	a1,0
    800023a6:	05850513          	addi	a0,a0,88
    800023aa:	dcdfd0ef          	jal	80000176 <memset>
  log_write(bp);
    800023ae:	854a                	mv	a0,s2
    800023b0:	685000ef          	jal	80003234 <log_write>
  brelse(bp);
    800023b4:	854a                	mv	a0,s2
    800023b6:	e35ff0ef          	jal	800021ea <brelse>
}
    800023ba:	6906                	ld	s2,64(sp)
    800023bc:	79e2                	ld	s3,56(sp)
    800023be:	7a42                	ld	s4,48(sp)
    800023c0:	7aa2                	ld	s5,40(sp)
    800023c2:	7b02                	ld	s6,32(sp)
    800023c4:	6be2                	ld	s7,24(sp)
    800023c6:	6c42                	ld	s8,16(sp)
    800023c8:	6ca2                	ld	s9,8(sp)
}
    800023ca:	8526                	mv	a0,s1
    800023cc:	60e6                	ld	ra,88(sp)
    800023ce:	6446                	ld	s0,80(sp)
    800023d0:	64a6                	ld	s1,72(sp)
    800023d2:	6125                	addi	sp,sp,96
    800023d4:	8082                	ret
    brelse(bp);
    800023d6:	854a                	mv	a0,s2
    800023d8:	e13ff0ef          	jal	800021ea <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800023dc:	015c87bb          	addw	a5,s9,s5
    800023e0:	00078a9b          	sext.w	s5,a5
    800023e4:	004b2703          	lw	a4,4(s6)
    800023e8:	04eaff63          	bgeu	s5,a4,80002446 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    800023ec:	41fad79b          	sraiw	a5,s5,0x1f
    800023f0:	0137d79b          	srliw	a5,a5,0x13
    800023f4:	015787bb          	addw	a5,a5,s5
    800023f8:	40d7d79b          	sraiw	a5,a5,0xd
    800023fc:	01cb2583          	lw	a1,28(s6)
    80002400:	9dbd                	addw	a1,a1,a5
    80002402:	855e                	mv	a0,s7
    80002404:	cdfff0ef          	jal	800020e2 <bread>
    80002408:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000240a:	004b2503          	lw	a0,4(s6)
    8000240e:	000a849b          	sext.w	s1,s5
    80002412:	8762                	mv	a4,s8
    80002414:	fca4f1e3          	bgeu	s1,a0,800023d6 <balloc+0x90>
      m = 1 << (bi % 8);
    80002418:	00777693          	andi	a3,a4,7
    8000241c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002420:	41f7579b          	sraiw	a5,a4,0x1f
    80002424:	01d7d79b          	srliw	a5,a5,0x1d
    80002428:	9fb9                	addw	a5,a5,a4
    8000242a:	4037d79b          	sraiw	a5,a5,0x3
    8000242e:	00f90633          	add	a2,s2,a5
    80002432:	05864603          	lbu	a2,88(a2)
    80002436:	00c6f5b3          	and	a1,a3,a2
    8000243a:	d5a1                	beqz	a1,80002382 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000243c:	2705                	addiw	a4,a4,1
    8000243e:	2485                	addiw	s1,s1,1
    80002440:	fd471ae3          	bne	a4,s4,80002414 <balloc+0xce>
    80002444:	bf49                	j	800023d6 <balloc+0x90>
    80002446:	6906                	ld	s2,64(sp)
    80002448:	79e2                	ld	s3,56(sp)
    8000244a:	7a42                	ld	s4,48(sp)
    8000244c:	7aa2                	ld	s5,40(sp)
    8000244e:	7b02                	ld	s6,32(sp)
    80002450:	6be2                	ld	s7,24(sp)
    80002452:	6c42                	ld	s8,16(sp)
    80002454:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002456:	00005517          	auipc	a0,0x5
    8000245a:	0ba50513          	addi	a0,a0,186 # 80007510 <etext+0x510>
    8000245e:	6a3020ef          	jal	80005300 <printf>
  return 0;
    80002462:	4481                	li	s1,0
    80002464:	b79d                	j	800023ca <balloc+0x84>

0000000080002466 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002466:	7179                	addi	sp,sp,-48
    80002468:	f406                	sd	ra,40(sp)
    8000246a:	f022                	sd	s0,32(sp)
    8000246c:	ec26                	sd	s1,24(sp)
    8000246e:	e84a                	sd	s2,16(sp)
    80002470:	e44e                	sd	s3,8(sp)
    80002472:	1800                	addi	s0,sp,48
    80002474:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002476:	47ad                	li	a5,11
    80002478:	02b7e663          	bltu	a5,a1,800024a4 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000247c:	02059793          	slli	a5,a1,0x20
    80002480:	01e7d593          	srli	a1,a5,0x1e
    80002484:	00b504b3          	add	s1,a0,a1
    80002488:	0504a903          	lw	s2,80(s1)
    8000248c:	06091a63          	bnez	s2,80002500 <bmap+0x9a>
      addr = balloc(ip->dev);
    80002490:	4108                	lw	a0,0(a0)
    80002492:	eb5ff0ef          	jal	80002346 <balloc>
    80002496:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000249a:	06090363          	beqz	s2,80002500 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    8000249e:	0524a823          	sw	s2,80(s1)
    800024a2:	a8b9                	j	80002500 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800024a4:	ff45849b          	addiw	s1,a1,-12
    800024a8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800024ac:	0ff00793          	li	a5,255
    800024b0:	06e7ee63          	bltu	a5,a4,8000252c <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800024b4:	08052903          	lw	s2,128(a0)
    800024b8:	00091d63          	bnez	s2,800024d2 <bmap+0x6c>
      addr = balloc(ip->dev);
    800024bc:	4108                	lw	a0,0(a0)
    800024be:	e89ff0ef          	jal	80002346 <balloc>
    800024c2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800024c6:	02090d63          	beqz	s2,80002500 <bmap+0x9a>
    800024ca:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800024cc:	0929a023          	sw	s2,128(s3)
    800024d0:	a011                	j	800024d4 <bmap+0x6e>
    800024d2:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800024d4:	85ca                	mv	a1,s2
    800024d6:	0009a503          	lw	a0,0(s3)
    800024da:	c09ff0ef          	jal	800020e2 <bread>
    800024de:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800024e0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800024e4:	02049713          	slli	a4,s1,0x20
    800024e8:	01e75593          	srli	a1,a4,0x1e
    800024ec:	00b784b3          	add	s1,a5,a1
    800024f0:	0004a903          	lw	s2,0(s1)
    800024f4:	00090e63          	beqz	s2,80002510 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800024f8:	8552                	mv	a0,s4
    800024fa:	cf1ff0ef          	jal	800021ea <brelse>
    return addr;
    800024fe:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002500:	854a                	mv	a0,s2
    80002502:	70a2                	ld	ra,40(sp)
    80002504:	7402                	ld	s0,32(sp)
    80002506:	64e2                	ld	s1,24(sp)
    80002508:	6942                	ld	s2,16(sp)
    8000250a:	69a2                	ld	s3,8(sp)
    8000250c:	6145                	addi	sp,sp,48
    8000250e:	8082                	ret
      addr = balloc(ip->dev);
    80002510:	0009a503          	lw	a0,0(s3)
    80002514:	e33ff0ef          	jal	80002346 <balloc>
    80002518:	0005091b          	sext.w	s2,a0
      if(addr){
    8000251c:	fc090ee3          	beqz	s2,800024f8 <bmap+0x92>
        a[bn] = addr;
    80002520:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002524:	8552                	mv	a0,s4
    80002526:	50f000ef          	jal	80003234 <log_write>
    8000252a:	b7f9                	j	800024f8 <bmap+0x92>
    8000252c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000252e:	00005517          	auipc	a0,0x5
    80002532:	ffa50513          	addi	a0,a0,-6 # 80007528 <etext+0x528>
    80002536:	09c030ef          	jal	800055d2 <panic>

000000008000253a <iget>:
{
    8000253a:	7179                	addi	sp,sp,-48
    8000253c:	f406                	sd	ra,40(sp)
    8000253e:	f022                	sd	s0,32(sp)
    80002540:	ec26                	sd	s1,24(sp)
    80002542:	e84a                	sd	s2,16(sp)
    80002544:	e44e                	sd	s3,8(sp)
    80002546:	e052                	sd	s4,0(sp)
    80002548:	1800                	addi	s0,sp,48
    8000254a:	89aa                	mv	s3,a0
    8000254c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000254e:	00014517          	auipc	a0,0x14
    80002552:	d1a50513          	addi	a0,a0,-742 # 80016268 <itable>
    80002556:	3aa030ef          	jal	80005900 <acquire>
  empty = 0;
    8000255a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000255c:	00014497          	auipc	s1,0x14
    80002560:	d2448493          	addi	s1,s1,-732 # 80016280 <itable+0x18>
    80002564:	00015697          	auipc	a3,0x15
    80002568:	7ac68693          	addi	a3,a3,1964 # 80017d10 <log>
    8000256c:	a039                	j	8000257a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000256e:	02090963          	beqz	s2,800025a0 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002572:	08848493          	addi	s1,s1,136
    80002576:	02d48863          	beq	s1,a3,800025a6 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000257a:	449c                	lw	a5,8(s1)
    8000257c:	fef059e3          	blez	a5,8000256e <iget+0x34>
    80002580:	4098                	lw	a4,0(s1)
    80002582:	ff3716e3          	bne	a4,s3,8000256e <iget+0x34>
    80002586:	40d8                	lw	a4,4(s1)
    80002588:	ff4713e3          	bne	a4,s4,8000256e <iget+0x34>
      ip->ref++;
    8000258c:	2785                	addiw	a5,a5,1
    8000258e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002590:	00014517          	auipc	a0,0x14
    80002594:	cd850513          	addi	a0,a0,-808 # 80016268 <itable>
    80002598:	400030ef          	jal	80005998 <release>
      return ip;
    8000259c:	8926                	mv	s2,s1
    8000259e:	a02d                	j	800025c8 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800025a0:	fbe9                	bnez	a5,80002572 <iget+0x38>
      empty = ip;
    800025a2:	8926                	mv	s2,s1
    800025a4:	b7f9                	j	80002572 <iget+0x38>
  if(empty == 0)
    800025a6:	02090a63          	beqz	s2,800025da <iget+0xa0>
  ip->dev = dev;
    800025aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800025ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800025b2:	4785                	li	a5,1
    800025b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800025b8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800025bc:	00014517          	auipc	a0,0x14
    800025c0:	cac50513          	addi	a0,a0,-852 # 80016268 <itable>
    800025c4:	3d4030ef          	jal	80005998 <release>
}
    800025c8:	854a                	mv	a0,s2
    800025ca:	70a2                	ld	ra,40(sp)
    800025cc:	7402                	ld	s0,32(sp)
    800025ce:	64e2                	ld	s1,24(sp)
    800025d0:	6942                	ld	s2,16(sp)
    800025d2:	69a2                	ld	s3,8(sp)
    800025d4:	6a02                	ld	s4,0(sp)
    800025d6:	6145                	addi	sp,sp,48
    800025d8:	8082                	ret
    panic("iget: no inodes");
    800025da:	00005517          	auipc	a0,0x5
    800025de:	f6650513          	addi	a0,a0,-154 # 80007540 <etext+0x540>
    800025e2:	7f1020ef          	jal	800055d2 <panic>

00000000800025e6 <fsinit>:
fsinit(int dev) {
    800025e6:	7179                	addi	sp,sp,-48
    800025e8:	f406                	sd	ra,40(sp)
    800025ea:	f022                	sd	s0,32(sp)
    800025ec:	ec26                	sd	s1,24(sp)
    800025ee:	e84a                	sd	s2,16(sp)
    800025f0:	e44e                	sd	s3,8(sp)
    800025f2:	1800                	addi	s0,sp,48
    800025f4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800025f6:	4585                	li	a1,1
    800025f8:	aebff0ef          	jal	800020e2 <bread>
    800025fc:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800025fe:	00014997          	auipc	s3,0x14
    80002602:	c4a98993          	addi	s3,s3,-950 # 80016248 <sb>
    80002606:	02000613          	li	a2,32
    8000260a:	05850593          	addi	a1,a0,88
    8000260e:	854e                	mv	a0,s3
    80002610:	bc3fd0ef          	jal	800001d2 <memmove>
  brelse(bp);
    80002614:	8526                	mv	a0,s1
    80002616:	bd5ff0ef          	jal	800021ea <brelse>
  if(sb.magic != FSMAGIC)
    8000261a:	0009a703          	lw	a4,0(s3)
    8000261e:	102037b7          	lui	a5,0x10203
    80002622:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002626:	02f71063          	bne	a4,a5,80002646 <fsinit+0x60>
  initlog(dev, &sb);
    8000262a:	00014597          	auipc	a1,0x14
    8000262e:	c1e58593          	addi	a1,a1,-994 # 80016248 <sb>
    80002632:	854a                	mv	a0,s2
    80002634:	1f9000ef          	jal	8000302c <initlog>
}
    80002638:	70a2                	ld	ra,40(sp)
    8000263a:	7402                	ld	s0,32(sp)
    8000263c:	64e2                	ld	s1,24(sp)
    8000263e:	6942                	ld	s2,16(sp)
    80002640:	69a2                	ld	s3,8(sp)
    80002642:	6145                	addi	sp,sp,48
    80002644:	8082                	ret
    panic("invalid file system");
    80002646:	00005517          	auipc	a0,0x5
    8000264a:	f0a50513          	addi	a0,a0,-246 # 80007550 <etext+0x550>
    8000264e:	785020ef          	jal	800055d2 <panic>

0000000080002652 <iinit>:
{
    80002652:	7179                	addi	sp,sp,-48
    80002654:	f406                	sd	ra,40(sp)
    80002656:	f022                	sd	s0,32(sp)
    80002658:	ec26                	sd	s1,24(sp)
    8000265a:	e84a                	sd	s2,16(sp)
    8000265c:	e44e                	sd	s3,8(sp)
    8000265e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002660:	00005597          	auipc	a1,0x5
    80002664:	f0858593          	addi	a1,a1,-248 # 80007568 <etext+0x568>
    80002668:	00014517          	auipc	a0,0x14
    8000266c:	c0050513          	addi	a0,a0,-1024 # 80016268 <itable>
    80002670:	210030ef          	jal	80005880 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002674:	00014497          	auipc	s1,0x14
    80002678:	c1c48493          	addi	s1,s1,-996 # 80016290 <itable+0x28>
    8000267c:	00015997          	auipc	s3,0x15
    80002680:	6a498993          	addi	s3,s3,1700 # 80017d20 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002684:	00005917          	auipc	s2,0x5
    80002688:	eec90913          	addi	s2,s2,-276 # 80007570 <etext+0x570>
    8000268c:	85ca                	mv	a1,s2
    8000268e:	8526                	mv	a0,s1
    80002690:	475000ef          	jal	80003304 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002694:	08848493          	addi	s1,s1,136
    80002698:	ff349ae3          	bne	s1,s3,8000268c <iinit+0x3a>
}
    8000269c:	70a2                	ld	ra,40(sp)
    8000269e:	7402                	ld	s0,32(sp)
    800026a0:	64e2                	ld	s1,24(sp)
    800026a2:	6942                	ld	s2,16(sp)
    800026a4:	69a2                	ld	s3,8(sp)
    800026a6:	6145                	addi	sp,sp,48
    800026a8:	8082                	ret

00000000800026aa <ialloc>:
{
    800026aa:	7139                	addi	sp,sp,-64
    800026ac:	fc06                	sd	ra,56(sp)
    800026ae:	f822                	sd	s0,48(sp)
    800026b0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800026b2:	00014717          	auipc	a4,0x14
    800026b6:	ba272703          	lw	a4,-1118(a4) # 80016254 <sb+0xc>
    800026ba:	4785                	li	a5,1
    800026bc:	06e7f063          	bgeu	a5,a4,8000271c <ialloc+0x72>
    800026c0:	f426                	sd	s1,40(sp)
    800026c2:	f04a                	sd	s2,32(sp)
    800026c4:	ec4e                	sd	s3,24(sp)
    800026c6:	e852                	sd	s4,16(sp)
    800026c8:	e456                	sd	s5,8(sp)
    800026ca:	e05a                	sd	s6,0(sp)
    800026cc:	8aaa                	mv	s5,a0
    800026ce:	8b2e                	mv	s6,a1
    800026d0:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800026d2:	00014a17          	auipc	s4,0x14
    800026d6:	b76a0a13          	addi	s4,s4,-1162 # 80016248 <sb>
    800026da:	00495593          	srli	a1,s2,0x4
    800026de:	018a2783          	lw	a5,24(s4)
    800026e2:	9dbd                	addw	a1,a1,a5
    800026e4:	8556                	mv	a0,s5
    800026e6:	9fdff0ef          	jal	800020e2 <bread>
    800026ea:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800026ec:	05850993          	addi	s3,a0,88
    800026f0:	00f97793          	andi	a5,s2,15
    800026f4:	079a                	slli	a5,a5,0x6
    800026f6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800026f8:	00099783          	lh	a5,0(s3)
    800026fc:	cb9d                	beqz	a5,80002732 <ialloc+0x88>
    brelse(bp);
    800026fe:	aedff0ef          	jal	800021ea <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002702:	0905                	addi	s2,s2,1
    80002704:	00ca2703          	lw	a4,12(s4)
    80002708:	0009079b          	sext.w	a5,s2
    8000270c:	fce7e7e3          	bltu	a5,a4,800026da <ialloc+0x30>
    80002710:	74a2                	ld	s1,40(sp)
    80002712:	7902                	ld	s2,32(sp)
    80002714:	69e2                	ld	s3,24(sp)
    80002716:	6a42                	ld	s4,16(sp)
    80002718:	6aa2                	ld	s5,8(sp)
    8000271a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000271c:	00005517          	auipc	a0,0x5
    80002720:	e5c50513          	addi	a0,a0,-420 # 80007578 <etext+0x578>
    80002724:	3dd020ef          	jal	80005300 <printf>
  return 0;
    80002728:	4501                	li	a0,0
}
    8000272a:	70e2                	ld	ra,56(sp)
    8000272c:	7442                	ld	s0,48(sp)
    8000272e:	6121                	addi	sp,sp,64
    80002730:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002732:	04000613          	li	a2,64
    80002736:	4581                	li	a1,0
    80002738:	854e                	mv	a0,s3
    8000273a:	a3dfd0ef          	jal	80000176 <memset>
      dip->type = type;
    8000273e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002742:	8526                	mv	a0,s1
    80002744:	2f1000ef          	jal	80003234 <log_write>
      brelse(bp);
    80002748:	8526                	mv	a0,s1
    8000274a:	aa1ff0ef          	jal	800021ea <brelse>
      return iget(dev, inum);
    8000274e:	0009059b          	sext.w	a1,s2
    80002752:	8556                	mv	a0,s5
    80002754:	de7ff0ef          	jal	8000253a <iget>
    80002758:	74a2                	ld	s1,40(sp)
    8000275a:	7902                	ld	s2,32(sp)
    8000275c:	69e2                	ld	s3,24(sp)
    8000275e:	6a42                	ld	s4,16(sp)
    80002760:	6aa2                	ld	s5,8(sp)
    80002762:	6b02                	ld	s6,0(sp)
    80002764:	b7d9                	j	8000272a <ialloc+0x80>

0000000080002766 <iupdate>:
{
    80002766:	1101                	addi	sp,sp,-32
    80002768:	ec06                	sd	ra,24(sp)
    8000276a:	e822                	sd	s0,16(sp)
    8000276c:	e426                	sd	s1,8(sp)
    8000276e:	e04a                	sd	s2,0(sp)
    80002770:	1000                	addi	s0,sp,32
    80002772:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002774:	415c                	lw	a5,4(a0)
    80002776:	0047d79b          	srliw	a5,a5,0x4
    8000277a:	00014597          	auipc	a1,0x14
    8000277e:	ae65a583          	lw	a1,-1306(a1) # 80016260 <sb+0x18>
    80002782:	9dbd                	addw	a1,a1,a5
    80002784:	4108                	lw	a0,0(a0)
    80002786:	95dff0ef          	jal	800020e2 <bread>
    8000278a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000278c:	05850793          	addi	a5,a0,88
    80002790:	40d8                	lw	a4,4(s1)
    80002792:	8b3d                	andi	a4,a4,15
    80002794:	071a                	slli	a4,a4,0x6
    80002796:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002798:	04449703          	lh	a4,68(s1)
    8000279c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800027a0:	04649703          	lh	a4,70(s1)
    800027a4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800027a8:	04849703          	lh	a4,72(s1)
    800027ac:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800027b0:	04a49703          	lh	a4,74(s1)
    800027b4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800027b8:	44f8                	lw	a4,76(s1)
    800027ba:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800027bc:	03400613          	li	a2,52
    800027c0:	05048593          	addi	a1,s1,80
    800027c4:	00c78513          	addi	a0,a5,12
    800027c8:	a0bfd0ef          	jal	800001d2 <memmove>
  log_write(bp);
    800027cc:	854a                	mv	a0,s2
    800027ce:	267000ef          	jal	80003234 <log_write>
  brelse(bp);
    800027d2:	854a                	mv	a0,s2
    800027d4:	a17ff0ef          	jal	800021ea <brelse>
}
    800027d8:	60e2                	ld	ra,24(sp)
    800027da:	6442                	ld	s0,16(sp)
    800027dc:	64a2                	ld	s1,8(sp)
    800027de:	6902                	ld	s2,0(sp)
    800027e0:	6105                	addi	sp,sp,32
    800027e2:	8082                	ret

00000000800027e4 <idup>:
{
    800027e4:	1101                	addi	sp,sp,-32
    800027e6:	ec06                	sd	ra,24(sp)
    800027e8:	e822                	sd	s0,16(sp)
    800027ea:	e426                	sd	s1,8(sp)
    800027ec:	1000                	addi	s0,sp,32
    800027ee:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800027f0:	00014517          	auipc	a0,0x14
    800027f4:	a7850513          	addi	a0,a0,-1416 # 80016268 <itable>
    800027f8:	108030ef          	jal	80005900 <acquire>
  ip->ref++;
    800027fc:	449c                	lw	a5,8(s1)
    800027fe:	2785                	addiw	a5,a5,1
    80002800:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002802:	00014517          	auipc	a0,0x14
    80002806:	a6650513          	addi	a0,a0,-1434 # 80016268 <itable>
    8000280a:	18e030ef          	jal	80005998 <release>
}
    8000280e:	8526                	mv	a0,s1
    80002810:	60e2                	ld	ra,24(sp)
    80002812:	6442                	ld	s0,16(sp)
    80002814:	64a2                	ld	s1,8(sp)
    80002816:	6105                	addi	sp,sp,32
    80002818:	8082                	ret

000000008000281a <ilock>:
{
    8000281a:	1101                	addi	sp,sp,-32
    8000281c:	ec06                	sd	ra,24(sp)
    8000281e:	e822                	sd	s0,16(sp)
    80002820:	e426                	sd	s1,8(sp)
    80002822:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002824:	cd19                	beqz	a0,80002842 <ilock+0x28>
    80002826:	84aa                	mv	s1,a0
    80002828:	451c                	lw	a5,8(a0)
    8000282a:	00f05c63          	blez	a5,80002842 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000282e:	0541                	addi	a0,a0,16
    80002830:	30b000ef          	jal	8000333a <acquiresleep>
  if(ip->valid == 0){
    80002834:	40bc                	lw	a5,64(s1)
    80002836:	cf89                	beqz	a5,80002850 <ilock+0x36>
}
    80002838:	60e2                	ld	ra,24(sp)
    8000283a:	6442                	ld	s0,16(sp)
    8000283c:	64a2                	ld	s1,8(sp)
    8000283e:	6105                	addi	sp,sp,32
    80002840:	8082                	ret
    80002842:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80002844:	00005517          	auipc	a0,0x5
    80002848:	d4c50513          	addi	a0,a0,-692 # 80007590 <etext+0x590>
    8000284c:	587020ef          	jal	800055d2 <panic>
    80002850:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002852:	40dc                	lw	a5,4(s1)
    80002854:	0047d79b          	srliw	a5,a5,0x4
    80002858:	00014597          	auipc	a1,0x14
    8000285c:	a085a583          	lw	a1,-1528(a1) # 80016260 <sb+0x18>
    80002860:	9dbd                	addw	a1,a1,a5
    80002862:	4088                	lw	a0,0(s1)
    80002864:	87fff0ef          	jal	800020e2 <bread>
    80002868:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000286a:	05850593          	addi	a1,a0,88
    8000286e:	40dc                	lw	a5,4(s1)
    80002870:	8bbd                	andi	a5,a5,15
    80002872:	079a                	slli	a5,a5,0x6
    80002874:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002876:	00059783          	lh	a5,0(a1)
    8000287a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000287e:	00259783          	lh	a5,2(a1)
    80002882:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002886:	00459783          	lh	a5,4(a1)
    8000288a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000288e:	00659783          	lh	a5,6(a1)
    80002892:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002896:	459c                	lw	a5,8(a1)
    80002898:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000289a:	03400613          	li	a2,52
    8000289e:	05b1                	addi	a1,a1,12
    800028a0:	05048513          	addi	a0,s1,80
    800028a4:	92ffd0ef          	jal	800001d2 <memmove>
    brelse(bp);
    800028a8:	854a                	mv	a0,s2
    800028aa:	941ff0ef          	jal	800021ea <brelse>
    ip->valid = 1;
    800028ae:	4785                	li	a5,1
    800028b0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800028b2:	04449783          	lh	a5,68(s1)
    800028b6:	c399                	beqz	a5,800028bc <ilock+0xa2>
    800028b8:	6902                	ld	s2,0(sp)
    800028ba:	bfbd                	j	80002838 <ilock+0x1e>
      panic("ilock: no type");
    800028bc:	00005517          	auipc	a0,0x5
    800028c0:	cdc50513          	addi	a0,a0,-804 # 80007598 <etext+0x598>
    800028c4:	50f020ef          	jal	800055d2 <panic>

00000000800028c8 <iunlock>:
{
    800028c8:	1101                	addi	sp,sp,-32
    800028ca:	ec06                	sd	ra,24(sp)
    800028cc:	e822                	sd	s0,16(sp)
    800028ce:	e426                	sd	s1,8(sp)
    800028d0:	e04a                	sd	s2,0(sp)
    800028d2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800028d4:	c505                	beqz	a0,800028fc <iunlock+0x34>
    800028d6:	84aa                	mv	s1,a0
    800028d8:	01050913          	addi	s2,a0,16
    800028dc:	854a                	mv	a0,s2
    800028de:	2db000ef          	jal	800033b8 <holdingsleep>
    800028e2:	cd09                	beqz	a0,800028fc <iunlock+0x34>
    800028e4:	449c                	lw	a5,8(s1)
    800028e6:	00f05b63          	blez	a5,800028fc <iunlock+0x34>
  releasesleep(&ip->lock);
    800028ea:	854a                	mv	a0,s2
    800028ec:	295000ef          	jal	80003380 <releasesleep>
}
    800028f0:	60e2                	ld	ra,24(sp)
    800028f2:	6442                	ld	s0,16(sp)
    800028f4:	64a2                	ld	s1,8(sp)
    800028f6:	6902                	ld	s2,0(sp)
    800028f8:	6105                	addi	sp,sp,32
    800028fa:	8082                	ret
    panic("iunlock");
    800028fc:	00005517          	auipc	a0,0x5
    80002900:	cac50513          	addi	a0,a0,-852 # 800075a8 <etext+0x5a8>
    80002904:	4cf020ef          	jal	800055d2 <panic>

0000000080002908 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002908:	7179                	addi	sp,sp,-48
    8000290a:	f406                	sd	ra,40(sp)
    8000290c:	f022                	sd	s0,32(sp)
    8000290e:	ec26                	sd	s1,24(sp)
    80002910:	e84a                	sd	s2,16(sp)
    80002912:	e44e                	sd	s3,8(sp)
    80002914:	1800                	addi	s0,sp,48
    80002916:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002918:	05050493          	addi	s1,a0,80
    8000291c:	08050913          	addi	s2,a0,128
    80002920:	a021                	j	80002928 <itrunc+0x20>
    80002922:	0491                	addi	s1,s1,4
    80002924:	01248b63          	beq	s1,s2,8000293a <itrunc+0x32>
    if(ip->addrs[i]){
    80002928:	408c                	lw	a1,0(s1)
    8000292a:	dde5                	beqz	a1,80002922 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000292c:	0009a503          	lw	a0,0(s3)
    80002930:	9abff0ef          	jal	800022da <bfree>
      ip->addrs[i] = 0;
    80002934:	0004a023          	sw	zero,0(s1)
    80002938:	b7ed                	j	80002922 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000293a:	0809a583          	lw	a1,128(s3)
    8000293e:	ed89                	bnez	a1,80002958 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002940:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002944:	854e                	mv	a0,s3
    80002946:	e21ff0ef          	jal	80002766 <iupdate>
}
    8000294a:	70a2                	ld	ra,40(sp)
    8000294c:	7402                	ld	s0,32(sp)
    8000294e:	64e2                	ld	s1,24(sp)
    80002950:	6942                	ld	s2,16(sp)
    80002952:	69a2                	ld	s3,8(sp)
    80002954:	6145                	addi	sp,sp,48
    80002956:	8082                	ret
    80002958:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000295a:	0009a503          	lw	a0,0(s3)
    8000295e:	f84ff0ef          	jal	800020e2 <bread>
    80002962:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002964:	05850493          	addi	s1,a0,88
    80002968:	45850913          	addi	s2,a0,1112
    8000296c:	a021                	j	80002974 <itrunc+0x6c>
    8000296e:	0491                	addi	s1,s1,4
    80002970:	01248963          	beq	s1,s2,80002982 <itrunc+0x7a>
      if(a[j])
    80002974:	408c                	lw	a1,0(s1)
    80002976:	dde5                	beqz	a1,8000296e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80002978:	0009a503          	lw	a0,0(s3)
    8000297c:	95fff0ef          	jal	800022da <bfree>
    80002980:	b7fd                	j	8000296e <itrunc+0x66>
    brelse(bp);
    80002982:	8552                	mv	a0,s4
    80002984:	867ff0ef          	jal	800021ea <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002988:	0809a583          	lw	a1,128(s3)
    8000298c:	0009a503          	lw	a0,0(s3)
    80002990:	94bff0ef          	jal	800022da <bfree>
    ip->addrs[NDIRECT] = 0;
    80002994:	0809a023          	sw	zero,128(s3)
    80002998:	6a02                	ld	s4,0(sp)
    8000299a:	b75d                	j	80002940 <itrunc+0x38>

000000008000299c <iput>:
{
    8000299c:	1101                	addi	sp,sp,-32
    8000299e:	ec06                	sd	ra,24(sp)
    800029a0:	e822                	sd	s0,16(sp)
    800029a2:	e426                	sd	s1,8(sp)
    800029a4:	1000                	addi	s0,sp,32
    800029a6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800029a8:	00014517          	auipc	a0,0x14
    800029ac:	8c050513          	addi	a0,a0,-1856 # 80016268 <itable>
    800029b0:	751020ef          	jal	80005900 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800029b4:	4498                	lw	a4,8(s1)
    800029b6:	4785                	li	a5,1
    800029b8:	02f70063          	beq	a4,a5,800029d8 <iput+0x3c>
  ip->ref--;
    800029bc:	449c                	lw	a5,8(s1)
    800029be:	37fd                	addiw	a5,a5,-1
    800029c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800029c2:	00014517          	auipc	a0,0x14
    800029c6:	8a650513          	addi	a0,a0,-1882 # 80016268 <itable>
    800029ca:	7cf020ef          	jal	80005998 <release>
}
    800029ce:	60e2                	ld	ra,24(sp)
    800029d0:	6442                	ld	s0,16(sp)
    800029d2:	64a2                	ld	s1,8(sp)
    800029d4:	6105                	addi	sp,sp,32
    800029d6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800029d8:	40bc                	lw	a5,64(s1)
    800029da:	d3ed                	beqz	a5,800029bc <iput+0x20>
    800029dc:	04a49783          	lh	a5,74(s1)
    800029e0:	fff1                	bnez	a5,800029bc <iput+0x20>
    800029e2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800029e4:	01048913          	addi	s2,s1,16
    800029e8:	854a                	mv	a0,s2
    800029ea:	151000ef          	jal	8000333a <acquiresleep>
    release(&itable.lock);
    800029ee:	00014517          	auipc	a0,0x14
    800029f2:	87a50513          	addi	a0,a0,-1926 # 80016268 <itable>
    800029f6:	7a3020ef          	jal	80005998 <release>
    itrunc(ip);
    800029fa:	8526                	mv	a0,s1
    800029fc:	f0dff0ef          	jal	80002908 <itrunc>
    ip->type = 0;
    80002a00:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002a04:	8526                	mv	a0,s1
    80002a06:	d61ff0ef          	jal	80002766 <iupdate>
    ip->valid = 0;
    80002a0a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002a0e:	854a                	mv	a0,s2
    80002a10:	171000ef          	jal	80003380 <releasesleep>
    acquire(&itable.lock);
    80002a14:	00014517          	auipc	a0,0x14
    80002a18:	85450513          	addi	a0,a0,-1964 # 80016268 <itable>
    80002a1c:	6e5020ef          	jal	80005900 <acquire>
    80002a20:	6902                	ld	s2,0(sp)
    80002a22:	bf69                	j	800029bc <iput+0x20>

0000000080002a24 <iunlockput>:
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	e426                	sd	s1,8(sp)
    80002a2c:	1000                	addi	s0,sp,32
    80002a2e:	84aa                	mv	s1,a0
  iunlock(ip);
    80002a30:	e99ff0ef          	jal	800028c8 <iunlock>
  iput(ip);
    80002a34:	8526                	mv	a0,s1
    80002a36:	f67ff0ef          	jal	8000299c <iput>
}
    80002a3a:	60e2                	ld	ra,24(sp)
    80002a3c:	6442                	ld	s0,16(sp)
    80002a3e:	64a2                	ld	s1,8(sp)
    80002a40:	6105                	addi	sp,sp,32
    80002a42:	8082                	ret

0000000080002a44 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002a44:	1141                	addi	sp,sp,-16
    80002a46:	e422                	sd	s0,8(sp)
    80002a48:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002a4a:	411c                	lw	a5,0(a0)
    80002a4c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002a4e:	415c                	lw	a5,4(a0)
    80002a50:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002a52:	04451783          	lh	a5,68(a0)
    80002a56:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002a5a:	04a51783          	lh	a5,74(a0)
    80002a5e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002a62:	04c56783          	lwu	a5,76(a0)
    80002a66:	e99c                	sd	a5,16(a1)
}
    80002a68:	6422                	ld	s0,8(sp)
    80002a6a:	0141                	addi	sp,sp,16
    80002a6c:	8082                	ret

0000000080002a6e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002a6e:	457c                	lw	a5,76(a0)
    80002a70:	0ed7eb63          	bltu	a5,a3,80002b66 <readi+0xf8>
{
    80002a74:	7159                	addi	sp,sp,-112
    80002a76:	f486                	sd	ra,104(sp)
    80002a78:	f0a2                	sd	s0,96(sp)
    80002a7a:	eca6                	sd	s1,88(sp)
    80002a7c:	e0d2                	sd	s4,64(sp)
    80002a7e:	fc56                	sd	s5,56(sp)
    80002a80:	f85a                	sd	s6,48(sp)
    80002a82:	f45e                	sd	s7,40(sp)
    80002a84:	1880                	addi	s0,sp,112
    80002a86:	8b2a                	mv	s6,a0
    80002a88:	8bae                	mv	s7,a1
    80002a8a:	8a32                	mv	s4,a2
    80002a8c:	84b6                	mv	s1,a3
    80002a8e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002a90:	9f35                	addw	a4,a4,a3
    return 0;
    80002a92:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002a94:	0cd76063          	bltu	a4,a3,80002b54 <readi+0xe6>
    80002a98:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80002a9a:	00e7f463          	bgeu	a5,a4,80002aa2 <readi+0x34>
    n = ip->size - off;
    80002a9e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002aa2:	080a8f63          	beqz	s5,80002b40 <readi+0xd2>
    80002aa6:	e8ca                	sd	s2,80(sp)
    80002aa8:	f062                	sd	s8,32(sp)
    80002aaa:	ec66                	sd	s9,24(sp)
    80002aac:	e86a                	sd	s10,16(sp)
    80002aae:	e46e                	sd	s11,8(sp)
    80002ab0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002ab2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002ab6:	5c7d                	li	s8,-1
    80002ab8:	a80d                	j	80002aea <readi+0x7c>
    80002aba:	020d1d93          	slli	s11,s10,0x20
    80002abe:	020ddd93          	srli	s11,s11,0x20
    80002ac2:	05890613          	addi	a2,s2,88
    80002ac6:	86ee                	mv	a3,s11
    80002ac8:	963a                	add	a2,a2,a4
    80002aca:	85d2                	mv	a1,s4
    80002acc:	855e                	mv	a0,s7
    80002ace:	bfdfe0ef          	jal	800016ca <either_copyout>
    80002ad2:	05850763          	beq	a0,s8,80002b20 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002ad6:	854a                	mv	a0,s2
    80002ad8:	f12ff0ef          	jal	800021ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002adc:	013d09bb          	addw	s3,s10,s3
    80002ae0:	009d04bb          	addw	s1,s10,s1
    80002ae4:	9a6e                	add	s4,s4,s11
    80002ae6:	0559f763          	bgeu	s3,s5,80002b34 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80002aea:	00a4d59b          	srliw	a1,s1,0xa
    80002aee:	855a                	mv	a0,s6
    80002af0:	977ff0ef          	jal	80002466 <bmap>
    80002af4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002af8:	c5b1                	beqz	a1,80002b44 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80002afa:	000b2503          	lw	a0,0(s6)
    80002afe:	de4ff0ef          	jal	800020e2 <bread>
    80002b02:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002b04:	3ff4f713          	andi	a4,s1,1023
    80002b08:	40ec87bb          	subw	a5,s9,a4
    80002b0c:	413a86bb          	subw	a3,s5,s3
    80002b10:	8d3e                	mv	s10,a5
    80002b12:	2781                	sext.w	a5,a5
    80002b14:	0006861b          	sext.w	a2,a3
    80002b18:	faf671e3          	bgeu	a2,a5,80002aba <readi+0x4c>
    80002b1c:	8d36                	mv	s10,a3
    80002b1e:	bf71                	j	80002aba <readi+0x4c>
      brelse(bp);
    80002b20:	854a                	mv	a0,s2
    80002b22:	ec8ff0ef          	jal	800021ea <brelse>
      tot = -1;
    80002b26:	59fd                	li	s3,-1
      break;
    80002b28:	6946                	ld	s2,80(sp)
    80002b2a:	7c02                	ld	s8,32(sp)
    80002b2c:	6ce2                	ld	s9,24(sp)
    80002b2e:	6d42                	ld	s10,16(sp)
    80002b30:	6da2                	ld	s11,8(sp)
    80002b32:	a831                	j	80002b4e <readi+0xe0>
    80002b34:	6946                	ld	s2,80(sp)
    80002b36:	7c02                	ld	s8,32(sp)
    80002b38:	6ce2                	ld	s9,24(sp)
    80002b3a:	6d42                	ld	s10,16(sp)
    80002b3c:	6da2                	ld	s11,8(sp)
    80002b3e:	a801                	j	80002b4e <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002b40:	89d6                	mv	s3,s5
    80002b42:	a031                	j	80002b4e <readi+0xe0>
    80002b44:	6946                	ld	s2,80(sp)
    80002b46:	7c02                	ld	s8,32(sp)
    80002b48:	6ce2                	ld	s9,24(sp)
    80002b4a:	6d42                	ld	s10,16(sp)
    80002b4c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80002b4e:	0009851b          	sext.w	a0,s3
    80002b52:	69a6                	ld	s3,72(sp)
}
    80002b54:	70a6                	ld	ra,104(sp)
    80002b56:	7406                	ld	s0,96(sp)
    80002b58:	64e6                	ld	s1,88(sp)
    80002b5a:	6a06                	ld	s4,64(sp)
    80002b5c:	7ae2                	ld	s5,56(sp)
    80002b5e:	7b42                	ld	s6,48(sp)
    80002b60:	7ba2                	ld	s7,40(sp)
    80002b62:	6165                	addi	sp,sp,112
    80002b64:	8082                	ret
    return 0;
    80002b66:	4501                	li	a0,0
}
    80002b68:	8082                	ret

0000000080002b6a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002b6a:	457c                	lw	a5,76(a0)
    80002b6c:	10d7e063          	bltu	a5,a3,80002c6c <writei+0x102>
{
    80002b70:	7159                	addi	sp,sp,-112
    80002b72:	f486                	sd	ra,104(sp)
    80002b74:	f0a2                	sd	s0,96(sp)
    80002b76:	e8ca                	sd	s2,80(sp)
    80002b78:	e0d2                	sd	s4,64(sp)
    80002b7a:	fc56                	sd	s5,56(sp)
    80002b7c:	f85a                	sd	s6,48(sp)
    80002b7e:	f45e                	sd	s7,40(sp)
    80002b80:	1880                	addi	s0,sp,112
    80002b82:	8aaa                	mv	s5,a0
    80002b84:	8bae                	mv	s7,a1
    80002b86:	8a32                	mv	s4,a2
    80002b88:	8936                	mv	s2,a3
    80002b8a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002b8c:	00e687bb          	addw	a5,a3,a4
    80002b90:	0ed7e063          	bltu	a5,a3,80002c70 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002b94:	00043737          	lui	a4,0x43
    80002b98:	0cf76e63          	bltu	a4,a5,80002c74 <writei+0x10a>
    80002b9c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002b9e:	0a0b0f63          	beqz	s6,80002c5c <writei+0xf2>
    80002ba2:	eca6                	sd	s1,88(sp)
    80002ba4:	f062                	sd	s8,32(sp)
    80002ba6:	ec66                	sd	s9,24(sp)
    80002ba8:	e86a                	sd	s10,16(sp)
    80002baa:	e46e                	sd	s11,8(sp)
    80002bac:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002bae:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002bb2:	5c7d                	li	s8,-1
    80002bb4:	a825                	j	80002bec <writei+0x82>
    80002bb6:	020d1d93          	slli	s11,s10,0x20
    80002bba:	020ddd93          	srli	s11,s11,0x20
    80002bbe:	05848513          	addi	a0,s1,88
    80002bc2:	86ee                	mv	a3,s11
    80002bc4:	8652                	mv	a2,s4
    80002bc6:	85de                	mv	a1,s7
    80002bc8:	953a                	add	a0,a0,a4
    80002bca:	b4bfe0ef          	jal	80001714 <either_copyin>
    80002bce:	05850a63          	beq	a0,s8,80002c22 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002bd2:	8526                	mv	a0,s1
    80002bd4:	660000ef          	jal	80003234 <log_write>
    brelse(bp);
    80002bd8:	8526                	mv	a0,s1
    80002bda:	e10ff0ef          	jal	800021ea <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002bde:	013d09bb          	addw	s3,s10,s3
    80002be2:	012d093b          	addw	s2,s10,s2
    80002be6:	9a6e                	add	s4,s4,s11
    80002be8:	0569f063          	bgeu	s3,s6,80002c28 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80002bec:	00a9559b          	srliw	a1,s2,0xa
    80002bf0:	8556                	mv	a0,s5
    80002bf2:	875ff0ef          	jal	80002466 <bmap>
    80002bf6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002bfa:	c59d                	beqz	a1,80002c28 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80002bfc:	000aa503          	lw	a0,0(s5)
    80002c00:	ce2ff0ef          	jal	800020e2 <bread>
    80002c04:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002c06:	3ff97713          	andi	a4,s2,1023
    80002c0a:	40ec87bb          	subw	a5,s9,a4
    80002c0e:	413b06bb          	subw	a3,s6,s3
    80002c12:	8d3e                	mv	s10,a5
    80002c14:	2781                	sext.w	a5,a5
    80002c16:	0006861b          	sext.w	a2,a3
    80002c1a:	f8f67ee3          	bgeu	a2,a5,80002bb6 <writei+0x4c>
    80002c1e:	8d36                	mv	s10,a3
    80002c20:	bf59                	j	80002bb6 <writei+0x4c>
      brelse(bp);
    80002c22:	8526                	mv	a0,s1
    80002c24:	dc6ff0ef          	jal	800021ea <brelse>
  }

  if(off > ip->size)
    80002c28:	04caa783          	lw	a5,76(s5)
    80002c2c:	0327fa63          	bgeu	a5,s2,80002c60 <writei+0xf6>
    ip->size = off;
    80002c30:	052aa623          	sw	s2,76(s5)
    80002c34:	64e6                	ld	s1,88(sp)
    80002c36:	7c02                	ld	s8,32(sp)
    80002c38:	6ce2                	ld	s9,24(sp)
    80002c3a:	6d42                	ld	s10,16(sp)
    80002c3c:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002c3e:	8556                	mv	a0,s5
    80002c40:	b27ff0ef          	jal	80002766 <iupdate>

  return tot;
    80002c44:	0009851b          	sext.w	a0,s3
    80002c48:	69a6                	ld	s3,72(sp)
}
    80002c4a:	70a6                	ld	ra,104(sp)
    80002c4c:	7406                	ld	s0,96(sp)
    80002c4e:	6946                	ld	s2,80(sp)
    80002c50:	6a06                	ld	s4,64(sp)
    80002c52:	7ae2                	ld	s5,56(sp)
    80002c54:	7b42                	ld	s6,48(sp)
    80002c56:	7ba2                	ld	s7,40(sp)
    80002c58:	6165                	addi	sp,sp,112
    80002c5a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002c5c:	89da                	mv	s3,s6
    80002c5e:	b7c5                	j	80002c3e <writei+0xd4>
    80002c60:	64e6                	ld	s1,88(sp)
    80002c62:	7c02                	ld	s8,32(sp)
    80002c64:	6ce2                	ld	s9,24(sp)
    80002c66:	6d42                	ld	s10,16(sp)
    80002c68:	6da2                	ld	s11,8(sp)
    80002c6a:	bfd1                	j	80002c3e <writei+0xd4>
    return -1;
    80002c6c:	557d                	li	a0,-1
}
    80002c6e:	8082                	ret
    return -1;
    80002c70:	557d                	li	a0,-1
    80002c72:	bfe1                	j	80002c4a <writei+0xe0>
    return -1;
    80002c74:	557d                	li	a0,-1
    80002c76:	bfd1                	j	80002c4a <writei+0xe0>

0000000080002c78 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80002c78:	1141                	addi	sp,sp,-16
    80002c7a:	e406                	sd	ra,8(sp)
    80002c7c:	e022                	sd	s0,0(sp)
    80002c7e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80002c80:	4639                	li	a2,14
    80002c82:	dc0fd0ef          	jal	80000242 <strncmp>
}
    80002c86:	60a2                	ld	ra,8(sp)
    80002c88:	6402                	ld	s0,0(sp)
    80002c8a:	0141                	addi	sp,sp,16
    80002c8c:	8082                	ret

0000000080002c8e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80002c8e:	7139                	addi	sp,sp,-64
    80002c90:	fc06                	sd	ra,56(sp)
    80002c92:	f822                	sd	s0,48(sp)
    80002c94:	f426                	sd	s1,40(sp)
    80002c96:	f04a                	sd	s2,32(sp)
    80002c98:	ec4e                	sd	s3,24(sp)
    80002c9a:	e852                	sd	s4,16(sp)
    80002c9c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80002c9e:	04451703          	lh	a4,68(a0)
    80002ca2:	4785                	li	a5,1
    80002ca4:	00f71a63          	bne	a4,a5,80002cb8 <dirlookup+0x2a>
    80002ca8:	892a                	mv	s2,a0
    80002caa:	89ae                	mv	s3,a1
    80002cac:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80002cae:	457c                	lw	a5,76(a0)
    80002cb0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80002cb2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002cb4:	e39d                	bnez	a5,80002cda <dirlookup+0x4c>
    80002cb6:	a095                	j	80002d1a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80002cb8:	00005517          	auipc	a0,0x5
    80002cbc:	8f850513          	addi	a0,a0,-1800 # 800075b0 <etext+0x5b0>
    80002cc0:	113020ef          	jal	800055d2 <panic>
      panic("dirlookup read");
    80002cc4:	00005517          	auipc	a0,0x5
    80002cc8:	90450513          	addi	a0,a0,-1788 # 800075c8 <etext+0x5c8>
    80002ccc:	107020ef          	jal	800055d2 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002cd0:	24c1                	addiw	s1,s1,16
    80002cd2:	04c92783          	lw	a5,76(s2)
    80002cd6:	04f4f163          	bgeu	s1,a5,80002d18 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002cda:	4741                	li	a4,16
    80002cdc:	86a6                	mv	a3,s1
    80002cde:	fc040613          	addi	a2,s0,-64
    80002ce2:	4581                	li	a1,0
    80002ce4:	854a                	mv	a0,s2
    80002ce6:	d89ff0ef          	jal	80002a6e <readi>
    80002cea:	47c1                	li	a5,16
    80002cec:	fcf51ce3          	bne	a0,a5,80002cc4 <dirlookup+0x36>
    if(de.inum == 0)
    80002cf0:	fc045783          	lhu	a5,-64(s0)
    80002cf4:	dff1                	beqz	a5,80002cd0 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80002cf6:	fc240593          	addi	a1,s0,-62
    80002cfa:	854e                	mv	a0,s3
    80002cfc:	f7dff0ef          	jal	80002c78 <namecmp>
    80002d00:	f961                	bnez	a0,80002cd0 <dirlookup+0x42>
      if(poff)
    80002d02:	000a0463          	beqz	s4,80002d0a <dirlookup+0x7c>
        *poff = off;
    80002d06:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80002d0a:	fc045583          	lhu	a1,-64(s0)
    80002d0e:	00092503          	lw	a0,0(s2)
    80002d12:	829ff0ef          	jal	8000253a <iget>
    80002d16:	a011                	j	80002d1a <dirlookup+0x8c>
  return 0;
    80002d18:	4501                	li	a0,0
}
    80002d1a:	70e2                	ld	ra,56(sp)
    80002d1c:	7442                	ld	s0,48(sp)
    80002d1e:	74a2                	ld	s1,40(sp)
    80002d20:	7902                	ld	s2,32(sp)
    80002d22:	69e2                	ld	s3,24(sp)
    80002d24:	6a42                	ld	s4,16(sp)
    80002d26:	6121                	addi	sp,sp,64
    80002d28:	8082                	ret

0000000080002d2a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80002d2a:	711d                	addi	sp,sp,-96
    80002d2c:	ec86                	sd	ra,88(sp)
    80002d2e:	e8a2                	sd	s0,80(sp)
    80002d30:	e4a6                	sd	s1,72(sp)
    80002d32:	e0ca                	sd	s2,64(sp)
    80002d34:	fc4e                	sd	s3,56(sp)
    80002d36:	f852                	sd	s4,48(sp)
    80002d38:	f456                	sd	s5,40(sp)
    80002d3a:	f05a                	sd	s6,32(sp)
    80002d3c:	ec5e                	sd	s7,24(sp)
    80002d3e:	e862                	sd	s8,16(sp)
    80002d40:	e466                	sd	s9,8(sp)
    80002d42:	1080                	addi	s0,sp,96
    80002d44:	84aa                	mv	s1,a0
    80002d46:	8b2e                	mv	s6,a1
    80002d48:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80002d4a:	00054703          	lbu	a4,0(a0)
    80002d4e:	02f00793          	li	a5,47
    80002d52:	00f70e63          	beq	a4,a5,80002d6e <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80002d56:	842fe0ef          	jal	80000d98 <myproc>
    80002d5a:	15053503          	ld	a0,336(a0)
    80002d5e:	a87ff0ef          	jal	800027e4 <idup>
    80002d62:	8a2a                	mv	s4,a0
  while(*path == '/')
    80002d64:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80002d68:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80002d6a:	4b85                	li	s7,1
    80002d6c:	a871                	j	80002e08 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80002d6e:	4585                	li	a1,1
    80002d70:	4505                	li	a0,1
    80002d72:	fc8ff0ef          	jal	8000253a <iget>
    80002d76:	8a2a                	mv	s4,a0
    80002d78:	b7f5                	j	80002d64 <namex+0x3a>
      iunlockput(ip);
    80002d7a:	8552                	mv	a0,s4
    80002d7c:	ca9ff0ef          	jal	80002a24 <iunlockput>
      return 0;
    80002d80:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80002d82:	8552                	mv	a0,s4
    80002d84:	60e6                	ld	ra,88(sp)
    80002d86:	6446                	ld	s0,80(sp)
    80002d88:	64a6                	ld	s1,72(sp)
    80002d8a:	6906                	ld	s2,64(sp)
    80002d8c:	79e2                	ld	s3,56(sp)
    80002d8e:	7a42                	ld	s4,48(sp)
    80002d90:	7aa2                	ld	s5,40(sp)
    80002d92:	7b02                	ld	s6,32(sp)
    80002d94:	6be2                	ld	s7,24(sp)
    80002d96:	6c42                	ld	s8,16(sp)
    80002d98:	6ca2                	ld	s9,8(sp)
    80002d9a:	6125                	addi	sp,sp,96
    80002d9c:	8082                	ret
      iunlock(ip);
    80002d9e:	8552                	mv	a0,s4
    80002da0:	b29ff0ef          	jal	800028c8 <iunlock>
      return ip;
    80002da4:	bff9                	j	80002d82 <namex+0x58>
      iunlockput(ip);
    80002da6:	8552                	mv	a0,s4
    80002da8:	c7dff0ef          	jal	80002a24 <iunlockput>
      return 0;
    80002dac:	8a4e                	mv	s4,s3
    80002dae:	bfd1                	j	80002d82 <namex+0x58>
  len = path - s;
    80002db0:	40998633          	sub	a2,s3,s1
    80002db4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80002db8:	099c5063          	bge	s8,s9,80002e38 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80002dbc:	4639                	li	a2,14
    80002dbe:	85a6                	mv	a1,s1
    80002dc0:	8556                	mv	a0,s5
    80002dc2:	c10fd0ef          	jal	800001d2 <memmove>
    80002dc6:	84ce                	mv	s1,s3
  while(*path == '/')
    80002dc8:	0004c783          	lbu	a5,0(s1)
    80002dcc:	01279763          	bne	a5,s2,80002dda <namex+0xb0>
    path++;
    80002dd0:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002dd2:	0004c783          	lbu	a5,0(s1)
    80002dd6:	ff278de3          	beq	a5,s2,80002dd0 <namex+0xa6>
    ilock(ip);
    80002dda:	8552                	mv	a0,s4
    80002ddc:	a3fff0ef          	jal	8000281a <ilock>
    if(ip->type != T_DIR){
    80002de0:	044a1783          	lh	a5,68(s4)
    80002de4:	f9779be3          	bne	a5,s7,80002d7a <namex+0x50>
    if(nameiparent && *path == '\0'){
    80002de8:	000b0563          	beqz	s6,80002df2 <namex+0xc8>
    80002dec:	0004c783          	lbu	a5,0(s1)
    80002df0:	d7dd                	beqz	a5,80002d9e <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80002df2:	4601                	li	a2,0
    80002df4:	85d6                	mv	a1,s5
    80002df6:	8552                	mv	a0,s4
    80002df8:	e97ff0ef          	jal	80002c8e <dirlookup>
    80002dfc:	89aa                	mv	s3,a0
    80002dfe:	d545                	beqz	a0,80002da6 <namex+0x7c>
    iunlockput(ip);
    80002e00:	8552                	mv	a0,s4
    80002e02:	c23ff0ef          	jal	80002a24 <iunlockput>
    ip = next;
    80002e06:	8a4e                	mv	s4,s3
  while(*path == '/')
    80002e08:	0004c783          	lbu	a5,0(s1)
    80002e0c:	01279763          	bne	a5,s2,80002e1a <namex+0xf0>
    path++;
    80002e10:	0485                	addi	s1,s1,1
  while(*path == '/')
    80002e12:	0004c783          	lbu	a5,0(s1)
    80002e16:	ff278de3          	beq	a5,s2,80002e10 <namex+0xe6>
  if(*path == 0)
    80002e1a:	cb8d                	beqz	a5,80002e4c <namex+0x122>
  while(*path != '/' && *path != 0)
    80002e1c:	0004c783          	lbu	a5,0(s1)
    80002e20:	89a6                	mv	s3,s1
  len = path - s;
    80002e22:	4c81                	li	s9,0
    80002e24:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80002e26:	01278963          	beq	a5,s2,80002e38 <namex+0x10e>
    80002e2a:	d3d9                	beqz	a5,80002db0 <namex+0x86>
    path++;
    80002e2c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80002e2e:	0009c783          	lbu	a5,0(s3)
    80002e32:	ff279ce3          	bne	a5,s2,80002e2a <namex+0x100>
    80002e36:	bfad                	j	80002db0 <namex+0x86>
    memmove(name, s, len);
    80002e38:	2601                	sext.w	a2,a2
    80002e3a:	85a6                	mv	a1,s1
    80002e3c:	8556                	mv	a0,s5
    80002e3e:	b94fd0ef          	jal	800001d2 <memmove>
    name[len] = 0;
    80002e42:	9cd6                	add	s9,s9,s5
    80002e44:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80002e48:	84ce                	mv	s1,s3
    80002e4a:	bfbd                	j	80002dc8 <namex+0x9e>
  if(nameiparent){
    80002e4c:	f20b0be3          	beqz	s6,80002d82 <namex+0x58>
    iput(ip);
    80002e50:	8552                	mv	a0,s4
    80002e52:	b4bff0ef          	jal	8000299c <iput>
    return 0;
    80002e56:	4a01                	li	s4,0
    80002e58:	b72d                	j	80002d82 <namex+0x58>

0000000080002e5a <dirlink>:
{
    80002e5a:	7139                	addi	sp,sp,-64
    80002e5c:	fc06                	sd	ra,56(sp)
    80002e5e:	f822                	sd	s0,48(sp)
    80002e60:	f04a                	sd	s2,32(sp)
    80002e62:	ec4e                	sd	s3,24(sp)
    80002e64:	e852                	sd	s4,16(sp)
    80002e66:	0080                	addi	s0,sp,64
    80002e68:	892a                	mv	s2,a0
    80002e6a:	8a2e                	mv	s4,a1
    80002e6c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80002e6e:	4601                	li	a2,0
    80002e70:	e1fff0ef          	jal	80002c8e <dirlookup>
    80002e74:	e535                	bnez	a0,80002ee0 <dirlink+0x86>
    80002e76:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e78:	04c92483          	lw	s1,76(s2)
    80002e7c:	c48d                	beqz	s1,80002ea6 <dirlink+0x4c>
    80002e7e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002e80:	4741                	li	a4,16
    80002e82:	86a6                	mv	a3,s1
    80002e84:	fc040613          	addi	a2,s0,-64
    80002e88:	4581                	li	a1,0
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	be3ff0ef          	jal	80002a6e <readi>
    80002e90:	47c1                	li	a5,16
    80002e92:	04f51b63          	bne	a0,a5,80002ee8 <dirlink+0x8e>
    if(de.inum == 0)
    80002e96:	fc045783          	lhu	a5,-64(s0)
    80002e9a:	c791                	beqz	a5,80002ea6 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80002e9c:	24c1                	addiw	s1,s1,16
    80002e9e:	04c92783          	lw	a5,76(s2)
    80002ea2:	fcf4efe3          	bltu	s1,a5,80002e80 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80002ea6:	4639                	li	a2,14
    80002ea8:	85d2                	mv	a1,s4
    80002eaa:	fc240513          	addi	a0,s0,-62
    80002eae:	bcafd0ef          	jal	80000278 <strncpy>
  de.inum = inum;
    80002eb2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80002eb6:	4741                	li	a4,16
    80002eb8:	86a6                	mv	a3,s1
    80002eba:	fc040613          	addi	a2,s0,-64
    80002ebe:	4581                	li	a1,0
    80002ec0:	854a                	mv	a0,s2
    80002ec2:	ca9ff0ef          	jal	80002b6a <writei>
    80002ec6:	1541                	addi	a0,a0,-16
    80002ec8:	00a03533          	snez	a0,a0
    80002ecc:	40a00533          	neg	a0,a0
    80002ed0:	74a2                	ld	s1,40(sp)
}
    80002ed2:	70e2                	ld	ra,56(sp)
    80002ed4:	7442                	ld	s0,48(sp)
    80002ed6:	7902                	ld	s2,32(sp)
    80002ed8:	69e2                	ld	s3,24(sp)
    80002eda:	6a42                	ld	s4,16(sp)
    80002edc:	6121                	addi	sp,sp,64
    80002ede:	8082                	ret
    iput(ip);
    80002ee0:	abdff0ef          	jal	8000299c <iput>
    return -1;
    80002ee4:	557d                	li	a0,-1
    80002ee6:	b7f5                	j	80002ed2 <dirlink+0x78>
      panic("dirlink read");
    80002ee8:	00004517          	auipc	a0,0x4
    80002eec:	6f050513          	addi	a0,a0,1776 # 800075d8 <etext+0x5d8>
    80002ef0:	6e2020ef          	jal	800055d2 <panic>

0000000080002ef4 <namei>:

struct inode*
namei(char *path)
{
    80002ef4:	1101                	addi	sp,sp,-32
    80002ef6:	ec06                	sd	ra,24(sp)
    80002ef8:	e822                	sd	s0,16(sp)
    80002efa:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80002efc:	fe040613          	addi	a2,s0,-32
    80002f00:	4581                	li	a1,0
    80002f02:	e29ff0ef          	jal	80002d2a <namex>
}
    80002f06:	60e2                	ld	ra,24(sp)
    80002f08:	6442                	ld	s0,16(sp)
    80002f0a:	6105                	addi	sp,sp,32
    80002f0c:	8082                	ret

0000000080002f0e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80002f0e:	1141                	addi	sp,sp,-16
    80002f10:	e406                	sd	ra,8(sp)
    80002f12:	e022                	sd	s0,0(sp)
    80002f14:	0800                	addi	s0,sp,16
    80002f16:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80002f18:	4585                	li	a1,1
    80002f1a:	e11ff0ef          	jal	80002d2a <namex>
}
    80002f1e:	60a2                	ld	ra,8(sp)
    80002f20:	6402                	ld	s0,0(sp)
    80002f22:	0141                	addi	sp,sp,16
    80002f24:	8082                	ret

0000000080002f26 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80002f26:	1101                	addi	sp,sp,-32
    80002f28:	ec06                	sd	ra,24(sp)
    80002f2a:	e822                	sd	s0,16(sp)
    80002f2c:	e426                	sd	s1,8(sp)
    80002f2e:	e04a                	sd	s2,0(sp)
    80002f30:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80002f32:	00015917          	auipc	s2,0x15
    80002f36:	dde90913          	addi	s2,s2,-546 # 80017d10 <log>
    80002f3a:	01892583          	lw	a1,24(s2)
    80002f3e:	02892503          	lw	a0,40(s2)
    80002f42:	9a0ff0ef          	jal	800020e2 <bread>
    80002f46:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80002f48:	02c92603          	lw	a2,44(s2)
    80002f4c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80002f4e:	00c05f63          	blez	a2,80002f6c <write_head+0x46>
    80002f52:	00015717          	auipc	a4,0x15
    80002f56:	dee70713          	addi	a4,a4,-530 # 80017d40 <log+0x30>
    80002f5a:	87aa                	mv	a5,a0
    80002f5c:	060a                	slli	a2,a2,0x2
    80002f5e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80002f60:	4314                	lw	a3,0(a4)
    80002f62:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80002f64:	0711                	addi	a4,a4,4
    80002f66:	0791                	addi	a5,a5,4
    80002f68:	fec79ce3          	bne	a5,a2,80002f60 <write_head+0x3a>
  }
  bwrite(buf);
    80002f6c:	8526                	mv	a0,s1
    80002f6e:	a4aff0ef          	jal	800021b8 <bwrite>
  brelse(buf);
    80002f72:	8526                	mv	a0,s1
    80002f74:	a76ff0ef          	jal	800021ea <brelse>
}
    80002f78:	60e2                	ld	ra,24(sp)
    80002f7a:	6442                	ld	s0,16(sp)
    80002f7c:	64a2                	ld	s1,8(sp)
    80002f7e:	6902                	ld	s2,0(sp)
    80002f80:	6105                	addi	sp,sp,32
    80002f82:	8082                	ret

0000000080002f84 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80002f84:	00015797          	auipc	a5,0x15
    80002f88:	db87a783          	lw	a5,-584(a5) # 80017d3c <log+0x2c>
    80002f8c:	08f05f63          	blez	a5,8000302a <install_trans+0xa6>
{
    80002f90:	7139                	addi	sp,sp,-64
    80002f92:	fc06                	sd	ra,56(sp)
    80002f94:	f822                	sd	s0,48(sp)
    80002f96:	f426                	sd	s1,40(sp)
    80002f98:	f04a                	sd	s2,32(sp)
    80002f9a:	ec4e                	sd	s3,24(sp)
    80002f9c:	e852                	sd	s4,16(sp)
    80002f9e:	e456                	sd	s5,8(sp)
    80002fa0:	e05a                	sd	s6,0(sp)
    80002fa2:	0080                	addi	s0,sp,64
    80002fa4:	8b2a                	mv	s6,a0
    80002fa6:	00015a97          	auipc	s5,0x15
    80002faa:	d9aa8a93          	addi	s5,s5,-614 # 80017d40 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002fae:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002fb0:	00015997          	auipc	s3,0x15
    80002fb4:	d6098993          	addi	s3,s3,-672 # 80017d10 <log>
    80002fb8:	a829                	j	80002fd2 <install_trans+0x4e>
    brelse(lbuf);
    80002fba:	854a                	mv	a0,s2
    80002fbc:	a2eff0ef          	jal	800021ea <brelse>
    brelse(dbuf);
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	a28ff0ef          	jal	800021ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80002fc6:	2a05                	addiw	s4,s4,1
    80002fc8:	0a91                	addi	s5,s5,4
    80002fca:	02c9a783          	lw	a5,44(s3)
    80002fce:	04fa5463          	bge	s4,a5,80003016 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80002fd2:	0189a583          	lw	a1,24(s3)
    80002fd6:	014585bb          	addw	a1,a1,s4
    80002fda:	2585                	addiw	a1,a1,1
    80002fdc:	0289a503          	lw	a0,40(s3)
    80002fe0:	902ff0ef          	jal	800020e2 <bread>
    80002fe4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80002fe6:	000aa583          	lw	a1,0(s5)
    80002fea:	0289a503          	lw	a0,40(s3)
    80002fee:	8f4ff0ef          	jal	800020e2 <bread>
    80002ff2:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80002ff4:	40000613          	li	a2,1024
    80002ff8:	05890593          	addi	a1,s2,88
    80002ffc:	05850513          	addi	a0,a0,88
    80003000:	9d2fd0ef          	jal	800001d2 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003004:	8526                	mv	a0,s1
    80003006:	9b2ff0ef          	jal	800021b8 <bwrite>
    if(recovering == 0)
    8000300a:	fa0b18e3          	bnez	s6,80002fba <install_trans+0x36>
      bunpin(dbuf);
    8000300e:	8526                	mv	a0,s1
    80003010:	a96ff0ef          	jal	800022a6 <bunpin>
    80003014:	b75d                	j	80002fba <install_trans+0x36>
}
    80003016:	70e2                	ld	ra,56(sp)
    80003018:	7442                	ld	s0,48(sp)
    8000301a:	74a2                	ld	s1,40(sp)
    8000301c:	7902                	ld	s2,32(sp)
    8000301e:	69e2                	ld	s3,24(sp)
    80003020:	6a42                	ld	s4,16(sp)
    80003022:	6aa2                	ld	s5,8(sp)
    80003024:	6b02                	ld	s6,0(sp)
    80003026:	6121                	addi	sp,sp,64
    80003028:	8082                	ret
    8000302a:	8082                	ret

000000008000302c <initlog>:
{
    8000302c:	7179                	addi	sp,sp,-48
    8000302e:	f406                	sd	ra,40(sp)
    80003030:	f022                	sd	s0,32(sp)
    80003032:	ec26                	sd	s1,24(sp)
    80003034:	e84a                	sd	s2,16(sp)
    80003036:	e44e                	sd	s3,8(sp)
    80003038:	1800                	addi	s0,sp,48
    8000303a:	892a                	mv	s2,a0
    8000303c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000303e:	00015497          	auipc	s1,0x15
    80003042:	cd248493          	addi	s1,s1,-814 # 80017d10 <log>
    80003046:	00004597          	auipc	a1,0x4
    8000304a:	5a258593          	addi	a1,a1,1442 # 800075e8 <etext+0x5e8>
    8000304e:	8526                	mv	a0,s1
    80003050:	031020ef          	jal	80005880 <initlock>
  log.start = sb->logstart;
    80003054:	0149a583          	lw	a1,20(s3)
    80003058:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000305a:	0109a783          	lw	a5,16(s3)
    8000305e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003060:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003064:	854a                	mv	a0,s2
    80003066:	87cff0ef          	jal	800020e2 <bread>
  log.lh.n = lh->n;
    8000306a:	4d30                	lw	a2,88(a0)
    8000306c:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000306e:	00c05f63          	blez	a2,8000308c <initlog+0x60>
    80003072:	87aa                	mv	a5,a0
    80003074:	00015717          	auipc	a4,0x15
    80003078:	ccc70713          	addi	a4,a4,-820 # 80017d40 <log+0x30>
    8000307c:	060a                	slli	a2,a2,0x2
    8000307e:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003080:	4ff4                	lw	a3,92(a5)
    80003082:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003084:	0791                	addi	a5,a5,4
    80003086:	0711                	addi	a4,a4,4
    80003088:	fec79ce3          	bne	a5,a2,80003080 <initlog+0x54>
  brelse(buf);
    8000308c:	95eff0ef          	jal	800021ea <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003090:	4505                	li	a0,1
    80003092:	ef3ff0ef          	jal	80002f84 <install_trans>
  log.lh.n = 0;
    80003096:	00015797          	auipc	a5,0x15
    8000309a:	ca07a323          	sw	zero,-858(a5) # 80017d3c <log+0x2c>
  write_head(); // clear the log
    8000309e:	e89ff0ef          	jal	80002f26 <write_head>
}
    800030a2:	70a2                	ld	ra,40(sp)
    800030a4:	7402                	ld	s0,32(sp)
    800030a6:	64e2                	ld	s1,24(sp)
    800030a8:	6942                	ld	s2,16(sp)
    800030aa:	69a2                	ld	s3,8(sp)
    800030ac:	6145                	addi	sp,sp,48
    800030ae:	8082                	ret

00000000800030b0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800030b0:	1101                	addi	sp,sp,-32
    800030b2:	ec06                	sd	ra,24(sp)
    800030b4:	e822                	sd	s0,16(sp)
    800030b6:	e426                	sd	s1,8(sp)
    800030b8:	e04a                	sd	s2,0(sp)
    800030ba:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800030bc:	00015517          	auipc	a0,0x15
    800030c0:	c5450513          	addi	a0,a0,-940 # 80017d10 <log>
    800030c4:	03d020ef          	jal	80005900 <acquire>
  while(1){
    if(log.committing){
    800030c8:	00015497          	auipc	s1,0x15
    800030cc:	c4848493          	addi	s1,s1,-952 # 80017d10 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800030d0:	4979                	li	s2,30
    800030d2:	a029                	j	800030dc <begin_op+0x2c>
      sleep(&log, &log.lock);
    800030d4:	85a6                	mv	a1,s1
    800030d6:	8526                	mv	a0,s1
    800030d8:	a96fe0ef          	jal	8000136e <sleep>
    if(log.committing){
    800030dc:	50dc                	lw	a5,36(s1)
    800030de:	fbfd                	bnez	a5,800030d4 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800030e0:	5098                	lw	a4,32(s1)
    800030e2:	2705                	addiw	a4,a4,1
    800030e4:	0027179b          	slliw	a5,a4,0x2
    800030e8:	9fb9                	addw	a5,a5,a4
    800030ea:	0017979b          	slliw	a5,a5,0x1
    800030ee:	54d4                	lw	a3,44(s1)
    800030f0:	9fb5                	addw	a5,a5,a3
    800030f2:	00f95763          	bge	s2,a5,80003100 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800030f6:	85a6                	mv	a1,s1
    800030f8:	8526                	mv	a0,s1
    800030fa:	a74fe0ef          	jal	8000136e <sleep>
    800030fe:	bff9                	j	800030dc <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003100:	00015517          	auipc	a0,0x15
    80003104:	c1050513          	addi	a0,a0,-1008 # 80017d10 <log>
    80003108:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000310a:	08f020ef          	jal	80005998 <release>
      break;
    }
  }
}
    8000310e:	60e2                	ld	ra,24(sp)
    80003110:	6442                	ld	s0,16(sp)
    80003112:	64a2                	ld	s1,8(sp)
    80003114:	6902                	ld	s2,0(sp)
    80003116:	6105                	addi	sp,sp,32
    80003118:	8082                	ret

000000008000311a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000311a:	7139                	addi	sp,sp,-64
    8000311c:	fc06                	sd	ra,56(sp)
    8000311e:	f822                	sd	s0,48(sp)
    80003120:	f426                	sd	s1,40(sp)
    80003122:	f04a                	sd	s2,32(sp)
    80003124:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003126:	00015497          	auipc	s1,0x15
    8000312a:	bea48493          	addi	s1,s1,-1046 # 80017d10 <log>
    8000312e:	8526                	mv	a0,s1
    80003130:	7d0020ef          	jal	80005900 <acquire>
  log.outstanding -= 1;
    80003134:	509c                	lw	a5,32(s1)
    80003136:	37fd                	addiw	a5,a5,-1
    80003138:	0007891b          	sext.w	s2,a5
    8000313c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000313e:	50dc                	lw	a5,36(s1)
    80003140:	ef9d                	bnez	a5,8000317e <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003142:	04091763          	bnez	s2,80003190 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003146:	00015497          	auipc	s1,0x15
    8000314a:	bca48493          	addi	s1,s1,-1078 # 80017d10 <log>
    8000314e:	4785                	li	a5,1
    80003150:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003152:	8526                	mv	a0,s1
    80003154:	045020ef          	jal	80005998 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003158:	54dc                	lw	a5,44(s1)
    8000315a:	04f04b63          	bgtz	a5,800031b0 <end_op+0x96>
    acquire(&log.lock);
    8000315e:	00015497          	auipc	s1,0x15
    80003162:	bb248493          	addi	s1,s1,-1102 # 80017d10 <log>
    80003166:	8526                	mv	a0,s1
    80003168:	798020ef          	jal	80005900 <acquire>
    log.committing = 0;
    8000316c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003170:	8526                	mv	a0,s1
    80003172:	a48fe0ef          	jal	800013ba <wakeup>
    release(&log.lock);
    80003176:	8526                	mv	a0,s1
    80003178:	021020ef          	jal	80005998 <release>
}
    8000317c:	a025                	j	800031a4 <end_op+0x8a>
    8000317e:	ec4e                	sd	s3,24(sp)
    80003180:	e852                	sd	s4,16(sp)
    80003182:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003184:	00004517          	auipc	a0,0x4
    80003188:	46c50513          	addi	a0,a0,1132 # 800075f0 <etext+0x5f0>
    8000318c:	446020ef          	jal	800055d2 <panic>
    wakeup(&log);
    80003190:	00015497          	auipc	s1,0x15
    80003194:	b8048493          	addi	s1,s1,-1152 # 80017d10 <log>
    80003198:	8526                	mv	a0,s1
    8000319a:	a20fe0ef          	jal	800013ba <wakeup>
  release(&log.lock);
    8000319e:	8526                	mv	a0,s1
    800031a0:	7f8020ef          	jal	80005998 <release>
}
    800031a4:	70e2                	ld	ra,56(sp)
    800031a6:	7442                	ld	s0,48(sp)
    800031a8:	74a2                	ld	s1,40(sp)
    800031aa:	7902                	ld	s2,32(sp)
    800031ac:	6121                	addi	sp,sp,64
    800031ae:	8082                	ret
    800031b0:	ec4e                	sd	s3,24(sp)
    800031b2:	e852                	sd	s4,16(sp)
    800031b4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800031b6:	00015a97          	auipc	s5,0x15
    800031ba:	b8aa8a93          	addi	s5,s5,-1142 # 80017d40 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800031be:	00015a17          	auipc	s4,0x15
    800031c2:	b52a0a13          	addi	s4,s4,-1198 # 80017d10 <log>
    800031c6:	018a2583          	lw	a1,24(s4)
    800031ca:	012585bb          	addw	a1,a1,s2
    800031ce:	2585                	addiw	a1,a1,1
    800031d0:	028a2503          	lw	a0,40(s4)
    800031d4:	f0ffe0ef          	jal	800020e2 <bread>
    800031d8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800031da:	000aa583          	lw	a1,0(s5)
    800031de:	028a2503          	lw	a0,40(s4)
    800031e2:	f01fe0ef          	jal	800020e2 <bread>
    800031e6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800031e8:	40000613          	li	a2,1024
    800031ec:	05850593          	addi	a1,a0,88
    800031f0:	05848513          	addi	a0,s1,88
    800031f4:	fdffc0ef          	jal	800001d2 <memmove>
    bwrite(to);  // write the log
    800031f8:	8526                	mv	a0,s1
    800031fa:	fbffe0ef          	jal	800021b8 <bwrite>
    brelse(from);
    800031fe:	854e                	mv	a0,s3
    80003200:	febfe0ef          	jal	800021ea <brelse>
    brelse(to);
    80003204:	8526                	mv	a0,s1
    80003206:	fe5fe0ef          	jal	800021ea <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000320a:	2905                	addiw	s2,s2,1
    8000320c:	0a91                	addi	s5,s5,4
    8000320e:	02ca2783          	lw	a5,44(s4)
    80003212:	faf94ae3          	blt	s2,a5,800031c6 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003216:	d11ff0ef          	jal	80002f26 <write_head>
    install_trans(0); // Now install writes to home locations
    8000321a:	4501                	li	a0,0
    8000321c:	d69ff0ef          	jal	80002f84 <install_trans>
    log.lh.n = 0;
    80003220:	00015797          	auipc	a5,0x15
    80003224:	b007ae23          	sw	zero,-1252(a5) # 80017d3c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003228:	cffff0ef          	jal	80002f26 <write_head>
    8000322c:	69e2                	ld	s3,24(sp)
    8000322e:	6a42                	ld	s4,16(sp)
    80003230:	6aa2                	ld	s5,8(sp)
    80003232:	b735                	j	8000315e <end_op+0x44>

0000000080003234 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003234:	1101                	addi	sp,sp,-32
    80003236:	ec06                	sd	ra,24(sp)
    80003238:	e822                	sd	s0,16(sp)
    8000323a:	e426                	sd	s1,8(sp)
    8000323c:	e04a                	sd	s2,0(sp)
    8000323e:	1000                	addi	s0,sp,32
    80003240:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003242:	00015917          	auipc	s2,0x15
    80003246:	ace90913          	addi	s2,s2,-1330 # 80017d10 <log>
    8000324a:	854a                	mv	a0,s2
    8000324c:	6b4020ef          	jal	80005900 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003250:	02c92603          	lw	a2,44(s2)
    80003254:	47f5                	li	a5,29
    80003256:	06c7c363          	blt	a5,a2,800032bc <log_write+0x88>
    8000325a:	00015797          	auipc	a5,0x15
    8000325e:	ad27a783          	lw	a5,-1326(a5) # 80017d2c <log+0x1c>
    80003262:	37fd                	addiw	a5,a5,-1
    80003264:	04f65c63          	bge	a2,a5,800032bc <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003268:	00015797          	auipc	a5,0x15
    8000326c:	ac87a783          	lw	a5,-1336(a5) # 80017d30 <log+0x20>
    80003270:	04f05c63          	blez	a5,800032c8 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003274:	4781                	li	a5,0
    80003276:	04c05f63          	blez	a2,800032d4 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000327a:	44cc                	lw	a1,12(s1)
    8000327c:	00015717          	auipc	a4,0x15
    80003280:	ac470713          	addi	a4,a4,-1340 # 80017d40 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003284:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003286:	4314                	lw	a3,0(a4)
    80003288:	04b68663          	beq	a3,a1,800032d4 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    8000328c:	2785                	addiw	a5,a5,1
    8000328e:	0711                	addi	a4,a4,4
    80003290:	fef61be3          	bne	a2,a5,80003286 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003294:	0621                	addi	a2,a2,8
    80003296:	060a                	slli	a2,a2,0x2
    80003298:	00015797          	auipc	a5,0x15
    8000329c:	a7878793          	addi	a5,a5,-1416 # 80017d10 <log>
    800032a0:	97b2                	add	a5,a5,a2
    800032a2:	44d8                	lw	a4,12(s1)
    800032a4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800032a6:	8526                	mv	a0,s1
    800032a8:	fcbfe0ef          	jal	80002272 <bpin>
    log.lh.n++;
    800032ac:	00015717          	auipc	a4,0x15
    800032b0:	a6470713          	addi	a4,a4,-1436 # 80017d10 <log>
    800032b4:	575c                	lw	a5,44(a4)
    800032b6:	2785                	addiw	a5,a5,1
    800032b8:	d75c                	sw	a5,44(a4)
    800032ba:	a80d                	j	800032ec <log_write+0xb8>
    panic("too big a transaction");
    800032bc:	00004517          	auipc	a0,0x4
    800032c0:	34450513          	addi	a0,a0,836 # 80007600 <etext+0x600>
    800032c4:	30e020ef          	jal	800055d2 <panic>
    panic("log_write outside of trans");
    800032c8:	00004517          	auipc	a0,0x4
    800032cc:	35050513          	addi	a0,a0,848 # 80007618 <etext+0x618>
    800032d0:	302020ef          	jal	800055d2 <panic>
  log.lh.block[i] = b->blockno;
    800032d4:	00878693          	addi	a3,a5,8
    800032d8:	068a                	slli	a3,a3,0x2
    800032da:	00015717          	auipc	a4,0x15
    800032de:	a3670713          	addi	a4,a4,-1482 # 80017d10 <log>
    800032e2:	9736                	add	a4,a4,a3
    800032e4:	44d4                	lw	a3,12(s1)
    800032e6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800032e8:	faf60fe3          	beq	a2,a5,800032a6 <log_write+0x72>
  }
  release(&log.lock);
    800032ec:	00015517          	auipc	a0,0x15
    800032f0:	a2450513          	addi	a0,a0,-1500 # 80017d10 <log>
    800032f4:	6a4020ef          	jal	80005998 <release>
}
    800032f8:	60e2                	ld	ra,24(sp)
    800032fa:	6442                	ld	s0,16(sp)
    800032fc:	64a2                	ld	s1,8(sp)
    800032fe:	6902                	ld	s2,0(sp)
    80003300:	6105                	addi	sp,sp,32
    80003302:	8082                	ret

0000000080003304 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003304:	1101                	addi	sp,sp,-32
    80003306:	ec06                	sd	ra,24(sp)
    80003308:	e822                	sd	s0,16(sp)
    8000330a:	e426                	sd	s1,8(sp)
    8000330c:	e04a                	sd	s2,0(sp)
    8000330e:	1000                	addi	s0,sp,32
    80003310:	84aa                	mv	s1,a0
    80003312:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003314:	00004597          	auipc	a1,0x4
    80003318:	32458593          	addi	a1,a1,804 # 80007638 <etext+0x638>
    8000331c:	0521                	addi	a0,a0,8
    8000331e:	562020ef          	jal	80005880 <initlock>
  lk->name = name;
    80003322:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003326:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000332a:	0204a423          	sw	zero,40(s1)
}
    8000332e:	60e2                	ld	ra,24(sp)
    80003330:	6442                	ld	s0,16(sp)
    80003332:	64a2                	ld	s1,8(sp)
    80003334:	6902                	ld	s2,0(sp)
    80003336:	6105                	addi	sp,sp,32
    80003338:	8082                	ret

000000008000333a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000333a:	1101                	addi	sp,sp,-32
    8000333c:	ec06                	sd	ra,24(sp)
    8000333e:	e822                	sd	s0,16(sp)
    80003340:	e426                	sd	s1,8(sp)
    80003342:	e04a                	sd	s2,0(sp)
    80003344:	1000                	addi	s0,sp,32
    80003346:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003348:	00850913          	addi	s2,a0,8
    8000334c:	854a                	mv	a0,s2
    8000334e:	5b2020ef          	jal	80005900 <acquire>
  while (lk->locked) {
    80003352:	409c                	lw	a5,0(s1)
    80003354:	c799                	beqz	a5,80003362 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003356:	85ca                	mv	a1,s2
    80003358:	8526                	mv	a0,s1
    8000335a:	814fe0ef          	jal	8000136e <sleep>
  while (lk->locked) {
    8000335e:	409c                	lw	a5,0(s1)
    80003360:	fbfd                	bnez	a5,80003356 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003362:	4785                	li	a5,1
    80003364:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003366:	a33fd0ef          	jal	80000d98 <myproc>
    8000336a:	591c                	lw	a5,48(a0)
    8000336c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000336e:	854a                	mv	a0,s2
    80003370:	628020ef          	jal	80005998 <release>
}
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	64a2                	ld	s1,8(sp)
    8000337a:	6902                	ld	s2,0(sp)
    8000337c:	6105                	addi	sp,sp,32
    8000337e:	8082                	ret

0000000080003380 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003380:	1101                	addi	sp,sp,-32
    80003382:	ec06                	sd	ra,24(sp)
    80003384:	e822                	sd	s0,16(sp)
    80003386:	e426                	sd	s1,8(sp)
    80003388:	e04a                	sd	s2,0(sp)
    8000338a:	1000                	addi	s0,sp,32
    8000338c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000338e:	00850913          	addi	s2,a0,8
    80003392:	854a                	mv	a0,s2
    80003394:	56c020ef          	jal	80005900 <acquire>
  lk->locked = 0;
    80003398:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000339c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800033a0:	8526                	mv	a0,s1
    800033a2:	818fe0ef          	jal	800013ba <wakeup>
  release(&lk->lk);
    800033a6:	854a                	mv	a0,s2
    800033a8:	5f0020ef          	jal	80005998 <release>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6902                	ld	s2,0(sp)
    800033b4:	6105                	addi	sp,sp,32
    800033b6:	8082                	ret

00000000800033b8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800033b8:	7179                	addi	sp,sp,-48
    800033ba:	f406                	sd	ra,40(sp)
    800033bc:	f022                	sd	s0,32(sp)
    800033be:	ec26                	sd	s1,24(sp)
    800033c0:	e84a                	sd	s2,16(sp)
    800033c2:	1800                	addi	s0,sp,48
    800033c4:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800033c6:	00850913          	addi	s2,a0,8
    800033ca:	854a                	mv	a0,s2
    800033cc:	534020ef          	jal	80005900 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800033d0:	409c                	lw	a5,0(s1)
    800033d2:	ef81                	bnez	a5,800033ea <holdingsleep+0x32>
    800033d4:	4481                	li	s1,0
  release(&lk->lk);
    800033d6:	854a                	mv	a0,s2
    800033d8:	5c0020ef          	jal	80005998 <release>
  return r;
}
    800033dc:	8526                	mv	a0,s1
    800033de:	70a2                	ld	ra,40(sp)
    800033e0:	7402                	ld	s0,32(sp)
    800033e2:	64e2                	ld	s1,24(sp)
    800033e4:	6942                	ld	s2,16(sp)
    800033e6:	6145                	addi	sp,sp,48
    800033e8:	8082                	ret
    800033ea:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800033ec:	0284a983          	lw	s3,40(s1)
    800033f0:	9a9fd0ef          	jal	80000d98 <myproc>
    800033f4:	5904                	lw	s1,48(a0)
    800033f6:	413484b3          	sub	s1,s1,s3
    800033fa:	0014b493          	seqz	s1,s1
    800033fe:	69a2                	ld	s3,8(sp)
    80003400:	bfd9                	j	800033d6 <holdingsleep+0x1e>

0000000080003402 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003402:	1141                	addi	sp,sp,-16
    80003404:	e406                	sd	ra,8(sp)
    80003406:	e022                	sd	s0,0(sp)
    80003408:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000340a:	00004597          	auipc	a1,0x4
    8000340e:	23e58593          	addi	a1,a1,574 # 80007648 <etext+0x648>
    80003412:	00015517          	auipc	a0,0x15
    80003416:	a4650513          	addi	a0,a0,-1466 # 80017e58 <ftable>
    8000341a:	466020ef          	jal	80005880 <initlock>
}
    8000341e:	60a2                	ld	ra,8(sp)
    80003420:	6402                	ld	s0,0(sp)
    80003422:	0141                	addi	sp,sp,16
    80003424:	8082                	ret

0000000080003426 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003426:	1101                	addi	sp,sp,-32
    80003428:	ec06                	sd	ra,24(sp)
    8000342a:	e822                	sd	s0,16(sp)
    8000342c:	e426                	sd	s1,8(sp)
    8000342e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003430:	00015517          	auipc	a0,0x15
    80003434:	a2850513          	addi	a0,a0,-1496 # 80017e58 <ftable>
    80003438:	4c8020ef          	jal	80005900 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000343c:	00015497          	auipc	s1,0x15
    80003440:	a3448493          	addi	s1,s1,-1484 # 80017e70 <ftable+0x18>
    80003444:	00016717          	auipc	a4,0x16
    80003448:	9cc70713          	addi	a4,a4,-1588 # 80018e10 <disk>
    if(f->ref == 0){
    8000344c:	40dc                	lw	a5,4(s1)
    8000344e:	cf89                	beqz	a5,80003468 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003450:	02848493          	addi	s1,s1,40
    80003454:	fee49ce3          	bne	s1,a4,8000344c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003458:	00015517          	auipc	a0,0x15
    8000345c:	a0050513          	addi	a0,a0,-1536 # 80017e58 <ftable>
    80003460:	538020ef          	jal	80005998 <release>
  return 0;
    80003464:	4481                	li	s1,0
    80003466:	a809                	j	80003478 <filealloc+0x52>
      f->ref = 1;
    80003468:	4785                	li	a5,1
    8000346a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000346c:	00015517          	auipc	a0,0x15
    80003470:	9ec50513          	addi	a0,a0,-1556 # 80017e58 <ftable>
    80003474:	524020ef          	jal	80005998 <release>
}
    80003478:	8526                	mv	a0,s1
    8000347a:	60e2                	ld	ra,24(sp)
    8000347c:	6442                	ld	s0,16(sp)
    8000347e:	64a2                	ld	s1,8(sp)
    80003480:	6105                	addi	sp,sp,32
    80003482:	8082                	ret

0000000080003484 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003484:	1101                	addi	sp,sp,-32
    80003486:	ec06                	sd	ra,24(sp)
    80003488:	e822                	sd	s0,16(sp)
    8000348a:	e426                	sd	s1,8(sp)
    8000348c:	1000                	addi	s0,sp,32
    8000348e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003490:	00015517          	auipc	a0,0x15
    80003494:	9c850513          	addi	a0,a0,-1592 # 80017e58 <ftable>
    80003498:	468020ef          	jal	80005900 <acquire>
  if(f->ref < 1)
    8000349c:	40dc                	lw	a5,4(s1)
    8000349e:	02f05063          	blez	a5,800034be <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800034a2:	2785                	addiw	a5,a5,1
    800034a4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800034a6:	00015517          	auipc	a0,0x15
    800034aa:	9b250513          	addi	a0,a0,-1614 # 80017e58 <ftable>
    800034ae:	4ea020ef          	jal	80005998 <release>
  return f;
}
    800034b2:	8526                	mv	a0,s1
    800034b4:	60e2                	ld	ra,24(sp)
    800034b6:	6442                	ld	s0,16(sp)
    800034b8:	64a2                	ld	s1,8(sp)
    800034ba:	6105                	addi	sp,sp,32
    800034bc:	8082                	ret
    panic("filedup");
    800034be:	00004517          	auipc	a0,0x4
    800034c2:	19250513          	addi	a0,a0,402 # 80007650 <etext+0x650>
    800034c6:	10c020ef          	jal	800055d2 <panic>

00000000800034ca <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800034ca:	7139                	addi	sp,sp,-64
    800034cc:	fc06                	sd	ra,56(sp)
    800034ce:	f822                	sd	s0,48(sp)
    800034d0:	f426                	sd	s1,40(sp)
    800034d2:	0080                	addi	s0,sp,64
    800034d4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800034d6:	00015517          	auipc	a0,0x15
    800034da:	98250513          	addi	a0,a0,-1662 # 80017e58 <ftable>
    800034de:	422020ef          	jal	80005900 <acquire>
  if(f->ref < 1)
    800034e2:	40dc                	lw	a5,4(s1)
    800034e4:	04f05a63          	blez	a5,80003538 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800034e8:	37fd                	addiw	a5,a5,-1
    800034ea:	0007871b          	sext.w	a4,a5
    800034ee:	c0dc                	sw	a5,4(s1)
    800034f0:	04e04e63          	bgtz	a4,8000354c <fileclose+0x82>
    800034f4:	f04a                	sd	s2,32(sp)
    800034f6:	ec4e                	sd	s3,24(sp)
    800034f8:	e852                	sd	s4,16(sp)
    800034fa:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800034fc:	0004a903          	lw	s2,0(s1)
    80003500:	0094ca83          	lbu	s5,9(s1)
    80003504:	0104ba03          	ld	s4,16(s1)
    80003508:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000350c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003510:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003514:	00015517          	auipc	a0,0x15
    80003518:	94450513          	addi	a0,a0,-1724 # 80017e58 <ftable>
    8000351c:	47c020ef          	jal	80005998 <release>

  if(ff.type == FD_PIPE){
    80003520:	4785                	li	a5,1
    80003522:	04f90063          	beq	s2,a5,80003562 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003526:	3979                	addiw	s2,s2,-2
    80003528:	4785                	li	a5,1
    8000352a:	0527f563          	bgeu	a5,s2,80003574 <fileclose+0xaa>
    8000352e:	7902                	ld	s2,32(sp)
    80003530:	69e2                	ld	s3,24(sp)
    80003532:	6a42                	ld	s4,16(sp)
    80003534:	6aa2                	ld	s5,8(sp)
    80003536:	a00d                	j	80003558 <fileclose+0x8e>
    80003538:	f04a                	sd	s2,32(sp)
    8000353a:	ec4e                	sd	s3,24(sp)
    8000353c:	e852                	sd	s4,16(sp)
    8000353e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003540:	00004517          	auipc	a0,0x4
    80003544:	11850513          	addi	a0,a0,280 # 80007658 <etext+0x658>
    80003548:	08a020ef          	jal	800055d2 <panic>
    release(&ftable.lock);
    8000354c:	00015517          	auipc	a0,0x15
    80003550:	90c50513          	addi	a0,a0,-1780 # 80017e58 <ftable>
    80003554:	444020ef          	jal	80005998 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003558:	70e2                	ld	ra,56(sp)
    8000355a:	7442                	ld	s0,48(sp)
    8000355c:	74a2                	ld	s1,40(sp)
    8000355e:	6121                	addi	sp,sp,64
    80003560:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003562:	85d6                	mv	a1,s5
    80003564:	8552                	mv	a0,s4
    80003566:	336000ef          	jal	8000389c <pipeclose>
    8000356a:	7902                	ld	s2,32(sp)
    8000356c:	69e2                	ld	s3,24(sp)
    8000356e:	6a42                	ld	s4,16(sp)
    80003570:	6aa2                	ld	s5,8(sp)
    80003572:	b7dd                	j	80003558 <fileclose+0x8e>
    begin_op();
    80003574:	b3dff0ef          	jal	800030b0 <begin_op>
    iput(ff.ip);
    80003578:	854e                	mv	a0,s3
    8000357a:	c22ff0ef          	jal	8000299c <iput>
    end_op();
    8000357e:	b9dff0ef          	jal	8000311a <end_op>
    80003582:	7902                	ld	s2,32(sp)
    80003584:	69e2                	ld	s3,24(sp)
    80003586:	6a42                	ld	s4,16(sp)
    80003588:	6aa2                	ld	s5,8(sp)
    8000358a:	b7f9                	j	80003558 <fileclose+0x8e>

000000008000358c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000358c:	715d                	addi	sp,sp,-80
    8000358e:	e486                	sd	ra,72(sp)
    80003590:	e0a2                	sd	s0,64(sp)
    80003592:	fc26                	sd	s1,56(sp)
    80003594:	f44e                	sd	s3,40(sp)
    80003596:	0880                	addi	s0,sp,80
    80003598:	84aa                	mv	s1,a0
    8000359a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000359c:	ffcfd0ef          	jal	80000d98 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800035a0:	409c                	lw	a5,0(s1)
    800035a2:	37f9                	addiw	a5,a5,-2
    800035a4:	4705                	li	a4,1
    800035a6:	04f76063          	bltu	a4,a5,800035e6 <filestat+0x5a>
    800035aa:	f84a                	sd	s2,48(sp)
    800035ac:	892a                	mv	s2,a0
    ilock(f->ip);
    800035ae:	6c88                	ld	a0,24(s1)
    800035b0:	a6aff0ef          	jal	8000281a <ilock>
    stati(f->ip, &st);
    800035b4:	fb840593          	addi	a1,s0,-72
    800035b8:	6c88                	ld	a0,24(s1)
    800035ba:	c8aff0ef          	jal	80002a44 <stati>
    iunlock(f->ip);
    800035be:	6c88                	ld	a0,24(s1)
    800035c0:	b08ff0ef          	jal	800028c8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800035c4:	46e1                	li	a3,24
    800035c6:	fb840613          	addi	a2,s0,-72
    800035ca:	85ce                	mv	a1,s3
    800035cc:	05093503          	ld	a0,80(s2)
    800035d0:	c38fd0ef          	jal	80000a08 <copyout>
    800035d4:	41f5551b          	sraiw	a0,a0,0x1f
    800035d8:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800035da:	60a6                	ld	ra,72(sp)
    800035dc:	6406                	ld	s0,64(sp)
    800035de:	74e2                	ld	s1,56(sp)
    800035e0:	79a2                	ld	s3,40(sp)
    800035e2:	6161                	addi	sp,sp,80
    800035e4:	8082                	ret
  return -1;
    800035e6:	557d                	li	a0,-1
    800035e8:	bfcd                	j	800035da <filestat+0x4e>

00000000800035ea <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800035ea:	7179                	addi	sp,sp,-48
    800035ec:	f406                	sd	ra,40(sp)
    800035ee:	f022                	sd	s0,32(sp)
    800035f0:	e84a                	sd	s2,16(sp)
    800035f2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800035f4:	00854783          	lbu	a5,8(a0)
    800035f8:	cfd1                	beqz	a5,80003694 <fileread+0xaa>
    800035fa:	ec26                	sd	s1,24(sp)
    800035fc:	e44e                	sd	s3,8(sp)
    800035fe:	84aa                	mv	s1,a0
    80003600:	89ae                	mv	s3,a1
    80003602:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003604:	411c                	lw	a5,0(a0)
    80003606:	4705                	li	a4,1
    80003608:	04e78363          	beq	a5,a4,8000364e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000360c:	470d                	li	a4,3
    8000360e:	04e78763          	beq	a5,a4,8000365c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003612:	4709                	li	a4,2
    80003614:	06e79a63          	bne	a5,a4,80003688 <fileread+0x9e>
    ilock(f->ip);
    80003618:	6d08                	ld	a0,24(a0)
    8000361a:	a00ff0ef          	jal	8000281a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000361e:	874a                	mv	a4,s2
    80003620:	5094                	lw	a3,32(s1)
    80003622:	864e                	mv	a2,s3
    80003624:	4585                	li	a1,1
    80003626:	6c88                	ld	a0,24(s1)
    80003628:	c46ff0ef          	jal	80002a6e <readi>
    8000362c:	892a                	mv	s2,a0
    8000362e:	00a05563          	blez	a0,80003638 <fileread+0x4e>
      f->off += r;
    80003632:	509c                	lw	a5,32(s1)
    80003634:	9fa9                	addw	a5,a5,a0
    80003636:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003638:	6c88                	ld	a0,24(s1)
    8000363a:	a8eff0ef          	jal	800028c8 <iunlock>
    8000363e:	64e2                	ld	s1,24(sp)
    80003640:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80003642:	854a                	mv	a0,s2
    80003644:	70a2                	ld	ra,40(sp)
    80003646:	7402                	ld	s0,32(sp)
    80003648:	6942                	ld	s2,16(sp)
    8000364a:	6145                	addi	sp,sp,48
    8000364c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000364e:	6908                	ld	a0,16(a0)
    80003650:	388000ef          	jal	800039d8 <piperead>
    80003654:	892a                	mv	s2,a0
    80003656:	64e2                	ld	s1,24(sp)
    80003658:	69a2                	ld	s3,8(sp)
    8000365a:	b7e5                	j	80003642 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000365c:	02451783          	lh	a5,36(a0)
    80003660:	03079693          	slli	a3,a5,0x30
    80003664:	92c1                	srli	a3,a3,0x30
    80003666:	4725                	li	a4,9
    80003668:	02d76863          	bltu	a4,a3,80003698 <fileread+0xae>
    8000366c:	0792                	slli	a5,a5,0x4
    8000366e:	00014717          	auipc	a4,0x14
    80003672:	74a70713          	addi	a4,a4,1866 # 80017db8 <devsw>
    80003676:	97ba                	add	a5,a5,a4
    80003678:	639c                	ld	a5,0(a5)
    8000367a:	c39d                	beqz	a5,800036a0 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000367c:	4505                	li	a0,1
    8000367e:	9782                	jalr	a5
    80003680:	892a                	mv	s2,a0
    80003682:	64e2                	ld	s1,24(sp)
    80003684:	69a2                	ld	s3,8(sp)
    80003686:	bf75                	j	80003642 <fileread+0x58>
    panic("fileread");
    80003688:	00004517          	auipc	a0,0x4
    8000368c:	fe050513          	addi	a0,a0,-32 # 80007668 <etext+0x668>
    80003690:	743010ef          	jal	800055d2 <panic>
    return -1;
    80003694:	597d                	li	s2,-1
    80003696:	b775                	j	80003642 <fileread+0x58>
      return -1;
    80003698:	597d                	li	s2,-1
    8000369a:	64e2                	ld	s1,24(sp)
    8000369c:	69a2                	ld	s3,8(sp)
    8000369e:	b755                	j	80003642 <fileread+0x58>
    800036a0:	597d                	li	s2,-1
    800036a2:	64e2                	ld	s1,24(sp)
    800036a4:	69a2                	ld	s3,8(sp)
    800036a6:	bf71                	j	80003642 <fileread+0x58>

00000000800036a8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800036a8:	00954783          	lbu	a5,9(a0)
    800036ac:	10078b63          	beqz	a5,800037c2 <filewrite+0x11a>
{
    800036b0:	715d                	addi	sp,sp,-80
    800036b2:	e486                	sd	ra,72(sp)
    800036b4:	e0a2                	sd	s0,64(sp)
    800036b6:	f84a                	sd	s2,48(sp)
    800036b8:	f052                	sd	s4,32(sp)
    800036ba:	e85a                	sd	s6,16(sp)
    800036bc:	0880                	addi	s0,sp,80
    800036be:	892a                	mv	s2,a0
    800036c0:	8b2e                	mv	s6,a1
    800036c2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800036c4:	411c                	lw	a5,0(a0)
    800036c6:	4705                	li	a4,1
    800036c8:	02e78763          	beq	a5,a4,800036f6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800036cc:	470d                	li	a4,3
    800036ce:	02e78863          	beq	a5,a4,800036fe <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800036d2:	4709                	li	a4,2
    800036d4:	0ce79c63          	bne	a5,a4,800037ac <filewrite+0x104>
    800036d8:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800036da:	0ac05863          	blez	a2,8000378a <filewrite+0xe2>
    800036de:	fc26                	sd	s1,56(sp)
    800036e0:	ec56                	sd	s5,24(sp)
    800036e2:	e45e                	sd	s7,8(sp)
    800036e4:	e062                	sd	s8,0(sp)
    int i = 0;
    800036e6:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800036e8:	6b85                	lui	s7,0x1
    800036ea:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800036ee:	6c05                	lui	s8,0x1
    800036f0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800036f4:	a8b5                	j	80003770 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800036f6:	6908                	ld	a0,16(a0)
    800036f8:	1fc000ef          	jal	800038f4 <pipewrite>
    800036fc:	a04d                	j	8000379e <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800036fe:	02451783          	lh	a5,36(a0)
    80003702:	03079693          	slli	a3,a5,0x30
    80003706:	92c1                	srli	a3,a3,0x30
    80003708:	4725                	li	a4,9
    8000370a:	0ad76e63          	bltu	a4,a3,800037c6 <filewrite+0x11e>
    8000370e:	0792                	slli	a5,a5,0x4
    80003710:	00014717          	auipc	a4,0x14
    80003714:	6a870713          	addi	a4,a4,1704 # 80017db8 <devsw>
    80003718:	97ba                	add	a5,a5,a4
    8000371a:	679c                	ld	a5,8(a5)
    8000371c:	c7dd                	beqz	a5,800037ca <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000371e:	4505                	li	a0,1
    80003720:	9782                	jalr	a5
    80003722:	a8b5                	j	8000379e <filewrite+0xf6>
      if(n1 > max)
    80003724:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80003728:	989ff0ef          	jal	800030b0 <begin_op>
      ilock(f->ip);
    8000372c:	01893503          	ld	a0,24(s2)
    80003730:	8eaff0ef          	jal	8000281a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003734:	8756                	mv	a4,s5
    80003736:	02092683          	lw	a3,32(s2)
    8000373a:	01698633          	add	a2,s3,s6
    8000373e:	4585                	li	a1,1
    80003740:	01893503          	ld	a0,24(s2)
    80003744:	c26ff0ef          	jal	80002b6a <writei>
    80003748:	84aa                	mv	s1,a0
    8000374a:	00a05763          	blez	a0,80003758 <filewrite+0xb0>
        f->off += r;
    8000374e:	02092783          	lw	a5,32(s2)
    80003752:	9fa9                	addw	a5,a5,a0
    80003754:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003758:	01893503          	ld	a0,24(s2)
    8000375c:	96cff0ef          	jal	800028c8 <iunlock>
      end_op();
    80003760:	9bbff0ef          	jal	8000311a <end_op>

      if(r != n1){
    80003764:	029a9563          	bne	s5,s1,8000378e <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80003768:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000376c:	0149da63          	bge	s3,s4,80003780 <filewrite+0xd8>
      int n1 = n - i;
    80003770:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80003774:	0004879b          	sext.w	a5,s1
    80003778:	fafbd6e3          	bge	s7,a5,80003724 <filewrite+0x7c>
    8000377c:	84e2                	mv	s1,s8
    8000377e:	b75d                	j	80003724 <filewrite+0x7c>
    80003780:	74e2                	ld	s1,56(sp)
    80003782:	6ae2                	ld	s5,24(sp)
    80003784:	6ba2                	ld	s7,8(sp)
    80003786:	6c02                	ld	s8,0(sp)
    80003788:	a039                	j	80003796 <filewrite+0xee>
    int i = 0;
    8000378a:	4981                	li	s3,0
    8000378c:	a029                	j	80003796 <filewrite+0xee>
    8000378e:	74e2                	ld	s1,56(sp)
    80003790:	6ae2                	ld	s5,24(sp)
    80003792:	6ba2                	ld	s7,8(sp)
    80003794:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80003796:	033a1c63          	bne	s4,s3,800037ce <filewrite+0x126>
    8000379a:	8552                	mv	a0,s4
    8000379c:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000379e:	60a6                	ld	ra,72(sp)
    800037a0:	6406                	ld	s0,64(sp)
    800037a2:	7942                	ld	s2,48(sp)
    800037a4:	7a02                	ld	s4,32(sp)
    800037a6:	6b42                	ld	s6,16(sp)
    800037a8:	6161                	addi	sp,sp,80
    800037aa:	8082                	ret
    800037ac:	fc26                	sd	s1,56(sp)
    800037ae:	f44e                	sd	s3,40(sp)
    800037b0:	ec56                	sd	s5,24(sp)
    800037b2:	e45e                	sd	s7,8(sp)
    800037b4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800037b6:	00004517          	auipc	a0,0x4
    800037ba:	ec250513          	addi	a0,a0,-318 # 80007678 <etext+0x678>
    800037be:	615010ef          	jal	800055d2 <panic>
    return -1;
    800037c2:	557d                	li	a0,-1
}
    800037c4:	8082                	ret
      return -1;
    800037c6:	557d                	li	a0,-1
    800037c8:	bfd9                	j	8000379e <filewrite+0xf6>
    800037ca:	557d                	li	a0,-1
    800037cc:	bfc9                	j	8000379e <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800037ce:	557d                	li	a0,-1
    800037d0:	79a2                	ld	s3,40(sp)
    800037d2:	b7f1                	j	8000379e <filewrite+0xf6>

00000000800037d4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800037d4:	7179                	addi	sp,sp,-48
    800037d6:	f406                	sd	ra,40(sp)
    800037d8:	f022                	sd	s0,32(sp)
    800037da:	ec26                	sd	s1,24(sp)
    800037dc:	e052                	sd	s4,0(sp)
    800037de:	1800                	addi	s0,sp,48
    800037e0:	84aa                	mv	s1,a0
    800037e2:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800037e4:	0005b023          	sd	zero,0(a1)
    800037e8:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800037ec:	c3bff0ef          	jal	80003426 <filealloc>
    800037f0:	e088                	sd	a0,0(s1)
    800037f2:	c549                	beqz	a0,8000387c <pipealloc+0xa8>
    800037f4:	c33ff0ef          	jal	80003426 <filealloc>
    800037f8:	00aa3023          	sd	a0,0(s4)
    800037fc:	cd25                	beqz	a0,80003874 <pipealloc+0xa0>
    800037fe:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003800:	8f7fc0ef          	jal	800000f6 <kalloc>
    80003804:	892a                	mv	s2,a0
    80003806:	c12d                	beqz	a0,80003868 <pipealloc+0x94>
    80003808:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000380a:	4985                	li	s3,1
    8000380c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003810:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003814:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003818:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000381c:	00004597          	auipc	a1,0x4
    80003820:	c0c58593          	addi	a1,a1,-1012 # 80007428 <etext+0x428>
    80003824:	05c020ef          	jal	80005880 <initlock>
  (*f0)->type = FD_PIPE;
    80003828:	609c                	ld	a5,0(s1)
    8000382a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000382e:	609c                	ld	a5,0(s1)
    80003830:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003834:	609c                	ld	a5,0(s1)
    80003836:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000383a:	609c                	ld	a5,0(s1)
    8000383c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003840:	000a3783          	ld	a5,0(s4)
    80003844:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003848:	000a3783          	ld	a5,0(s4)
    8000384c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003850:	000a3783          	ld	a5,0(s4)
    80003854:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003858:	000a3783          	ld	a5,0(s4)
    8000385c:	0127b823          	sd	s2,16(a5)
  return 0;
    80003860:	4501                	li	a0,0
    80003862:	6942                	ld	s2,16(sp)
    80003864:	69a2                	ld	s3,8(sp)
    80003866:	a01d                	j	8000388c <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003868:	6088                	ld	a0,0(s1)
    8000386a:	c119                	beqz	a0,80003870 <pipealloc+0x9c>
    8000386c:	6942                	ld	s2,16(sp)
    8000386e:	a029                	j	80003878 <pipealloc+0xa4>
    80003870:	6942                	ld	s2,16(sp)
    80003872:	a029                	j	8000387c <pipealloc+0xa8>
    80003874:	6088                	ld	a0,0(s1)
    80003876:	c10d                	beqz	a0,80003898 <pipealloc+0xc4>
    fileclose(*f0);
    80003878:	c53ff0ef          	jal	800034ca <fileclose>
  if(*f1)
    8000387c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003880:	557d                	li	a0,-1
  if(*f1)
    80003882:	c789                	beqz	a5,8000388c <pipealloc+0xb8>
    fileclose(*f1);
    80003884:	853e                	mv	a0,a5
    80003886:	c45ff0ef          	jal	800034ca <fileclose>
  return -1;
    8000388a:	557d                	li	a0,-1
}
    8000388c:	70a2                	ld	ra,40(sp)
    8000388e:	7402                	ld	s0,32(sp)
    80003890:	64e2                	ld	s1,24(sp)
    80003892:	6a02                	ld	s4,0(sp)
    80003894:	6145                	addi	sp,sp,48
    80003896:	8082                	ret
  return -1;
    80003898:	557d                	li	a0,-1
    8000389a:	bfcd                	j	8000388c <pipealloc+0xb8>

000000008000389c <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000389c:	1101                	addi	sp,sp,-32
    8000389e:	ec06                	sd	ra,24(sp)
    800038a0:	e822                	sd	s0,16(sp)
    800038a2:	e426                	sd	s1,8(sp)
    800038a4:	e04a                	sd	s2,0(sp)
    800038a6:	1000                	addi	s0,sp,32
    800038a8:	84aa                	mv	s1,a0
    800038aa:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800038ac:	054020ef          	jal	80005900 <acquire>
  if(writable){
    800038b0:	02090763          	beqz	s2,800038de <pipeclose+0x42>
    pi->writeopen = 0;
    800038b4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800038b8:	21848513          	addi	a0,s1,536
    800038bc:	afffd0ef          	jal	800013ba <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800038c0:	2204b783          	ld	a5,544(s1)
    800038c4:	e785                	bnez	a5,800038ec <pipeclose+0x50>
    release(&pi->lock);
    800038c6:	8526                	mv	a0,s1
    800038c8:	0d0020ef          	jal	80005998 <release>
    kfree((char*)pi);
    800038cc:	8526                	mv	a0,s1
    800038ce:	f4efc0ef          	jal	8000001c <kfree>
  } else
    release(&pi->lock);
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6902                	ld	s2,0(sp)
    800038da:	6105                	addi	sp,sp,32
    800038dc:	8082                	ret
    pi->readopen = 0;
    800038de:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800038e2:	21c48513          	addi	a0,s1,540
    800038e6:	ad5fd0ef          	jal	800013ba <wakeup>
    800038ea:	bfd9                	j	800038c0 <pipeclose+0x24>
    release(&pi->lock);
    800038ec:	8526                	mv	a0,s1
    800038ee:	0aa020ef          	jal	80005998 <release>
}
    800038f2:	b7c5                	j	800038d2 <pipeclose+0x36>

00000000800038f4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800038f4:	711d                	addi	sp,sp,-96
    800038f6:	ec86                	sd	ra,88(sp)
    800038f8:	e8a2                	sd	s0,80(sp)
    800038fa:	e4a6                	sd	s1,72(sp)
    800038fc:	e0ca                	sd	s2,64(sp)
    800038fe:	fc4e                	sd	s3,56(sp)
    80003900:	f852                	sd	s4,48(sp)
    80003902:	f456                	sd	s5,40(sp)
    80003904:	1080                	addi	s0,sp,96
    80003906:	84aa                	mv	s1,a0
    80003908:	8aae                	mv	s5,a1
    8000390a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000390c:	c8cfd0ef          	jal	80000d98 <myproc>
    80003910:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003912:	8526                	mv	a0,s1
    80003914:	7ed010ef          	jal	80005900 <acquire>
  while(i < n){
    80003918:	0b405a63          	blez	s4,800039cc <pipewrite+0xd8>
    8000391c:	f05a                	sd	s6,32(sp)
    8000391e:	ec5e                	sd	s7,24(sp)
    80003920:	e862                	sd	s8,16(sp)
  int i = 0;
    80003922:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003924:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003926:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000392a:	21c48b93          	addi	s7,s1,540
    8000392e:	a81d                	j	80003964 <pipewrite+0x70>
      release(&pi->lock);
    80003930:	8526                	mv	a0,s1
    80003932:	066020ef          	jal	80005998 <release>
      return -1;
    80003936:	597d                	li	s2,-1
    80003938:	7b02                	ld	s6,32(sp)
    8000393a:	6be2                	ld	s7,24(sp)
    8000393c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000393e:	854a                	mv	a0,s2
    80003940:	60e6                	ld	ra,88(sp)
    80003942:	6446                	ld	s0,80(sp)
    80003944:	64a6                	ld	s1,72(sp)
    80003946:	6906                	ld	s2,64(sp)
    80003948:	79e2                	ld	s3,56(sp)
    8000394a:	7a42                	ld	s4,48(sp)
    8000394c:	7aa2                	ld	s5,40(sp)
    8000394e:	6125                	addi	sp,sp,96
    80003950:	8082                	ret
      wakeup(&pi->nread);
    80003952:	8562                	mv	a0,s8
    80003954:	a67fd0ef          	jal	800013ba <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003958:	85a6                	mv	a1,s1
    8000395a:	855e                	mv	a0,s7
    8000395c:	a13fd0ef          	jal	8000136e <sleep>
  while(i < n){
    80003960:	05495b63          	bge	s2,s4,800039b6 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80003964:	2204a783          	lw	a5,544(s1)
    80003968:	d7e1                	beqz	a5,80003930 <pipewrite+0x3c>
    8000396a:	854e                	mv	a0,s3
    8000396c:	c3bfd0ef          	jal	800015a6 <killed>
    80003970:	f161                	bnez	a0,80003930 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003972:	2184a783          	lw	a5,536(s1)
    80003976:	21c4a703          	lw	a4,540(s1)
    8000397a:	2007879b          	addiw	a5,a5,512
    8000397e:	fcf70ae3          	beq	a4,a5,80003952 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003982:	4685                	li	a3,1
    80003984:	01590633          	add	a2,s2,s5
    80003988:	faf40593          	addi	a1,s0,-81
    8000398c:	0509b503          	ld	a0,80(s3)
    80003990:	950fd0ef          	jal	80000ae0 <copyin>
    80003994:	03650e63          	beq	a0,s6,800039d0 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003998:	21c4a783          	lw	a5,540(s1)
    8000399c:	0017871b          	addiw	a4,a5,1
    800039a0:	20e4ae23          	sw	a4,540(s1)
    800039a4:	1ff7f793          	andi	a5,a5,511
    800039a8:	97a6                	add	a5,a5,s1
    800039aa:	faf44703          	lbu	a4,-81(s0)
    800039ae:	00e78c23          	sb	a4,24(a5)
      i++;
    800039b2:	2905                	addiw	s2,s2,1
    800039b4:	b775                	j	80003960 <pipewrite+0x6c>
    800039b6:	7b02                	ld	s6,32(sp)
    800039b8:	6be2                	ld	s7,24(sp)
    800039ba:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    800039bc:	21848513          	addi	a0,s1,536
    800039c0:	9fbfd0ef          	jal	800013ba <wakeup>
  release(&pi->lock);
    800039c4:	8526                	mv	a0,s1
    800039c6:	7d3010ef          	jal	80005998 <release>
  return i;
    800039ca:	bf95                	j	8000393e <pipewrite+0x4a>
  int i = 0;
    800039cc:	4901                	li	s2,0
    800039ce:	b7fd                	j	800039bc <pipewrite+0xc8>
    800039d0:	7b02                	ld	s6,32(sp)
    800039d2:	6be2                	ld	s7,24(sp)
    800039d4:	6c42                	ld	s8,16(sp)
    800039d6:	b7dd                	j	800039bc <pipewrite+0xc8>

00000000800039d8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800039d8:	715d                	addi	sp,sp,-80
    800039da:	e486                	sd	ra,72(sp)
    800039dc:	e0a2                	sd	s0,64(sp)
    800039de:	fc26                	sd	s1,56(sp)
    800039e0:	f84a                	sd	s2,48(sp)
    800039e2:	f44e                	sd	s3,40(sp)
    800039e4:	f052                	sd	s4,32(sp)
    800039e6:	ec56                	sd	s5,24(sp)
    800039e8:	0880                	addi	s0,sp,80
    800039ea:	84aa                	mv	s1,a0
    800039ec:	892e                	mv	s2,a1
    800039ee:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800039f0:	ba8fd0ef          	jal	80000d98 <myproc>
    800039f4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800039f6:	8526                	mv	a0,s1
    800039f8:	709010ef          	jal	80005900 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800039fc:	2184a703          	lw	a4,536(s1)
    80003a00:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003a04:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003a08:	02f71563          	bne	a4,a5,80003a32 <piperead+0x5a>
    80003a0c:	2244a783          	lw	a5,548(s1)
    80003a10:	cb85                	beqz	a5,80003a40 <piperead+0x68>
    if(killed(pr)){
    80003a12:	8552                	mv	a0,s4
    80003a14:	b93fd0ef          	jal	800015a6 <killed>
    80003a18:	ed19                	bnez	a0,80003a36 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003a1a:	85a6                	mv	a1,s1
    80003a1c:	854e                	mv	a0,s3
    80003a1e:	951fd0ef          	jal	8000136e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003a22:	2184a703          	lw	a4,536(s1)
    80003a26:	21c4a783          	lw	a5,540(s1)
    80003a2a:	fef701e3          	beq	a4,a5,80003a0c <piperead+0x34>
    80003a2e:	e85a                	sd	s6,16(sp)
    80003a30:	a809                	j	80003a42 <piperead+0x6a>
    80003a32:	e85a                	sd	s6,16(sp)
    80003a34:	a039                	j	80003a42 <piperead+0x6a>
      release(&pi->lock);
    80003a36:	8526                	mv	a0,s1
    80003a38:	761010ef          	jal	80005998 <release>
      return -1;
    80003a3c:	59fd                	li	s3,-1
    80003a3e:	a8b1                	j	80003a9a <piperead+0xc2>
    80003a40:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a42:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a44:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a46:	05505263          	blez	s5,80003a8a <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    80003a4a:	2184a783          	lw	a5,536(s1)
    80003a4e:	21c4a703          	lw	a4,540(s1)
    80003a52:	02f70c63          	beq	a4,a5,80003a8a <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003a56:	0017871b          	addiw	a4,a5,1
    80003a5a:	20e4ac23          	sw	a4,536(s1)
    80003a5e:	1ff7f793          	andi	a5,a5,511
    80003a62:	97a6                	add	a5,a5,s1
    80003a64:	0187c783          	lbu	a5,24(a5)
    80003a68:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003a6c:	4685                	li	a3,1
    80003a6e:	fbf40613          	addi	a2,s0,-65
    80003a72:	85ca                	mv	a1,s2
    80003a74:	050a3503          	ld	a0,80(s4)
    80003a78:	f91fc0ef          	jal	80000a08 <copyout>
    80003a7c:	01650763          	beq	a0,s6,80003a8a <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003a80:	2985                	addiw	s3,s3,1
    80003a82:	0905                	addi	s2,s2,1
    80003a84:	fd3a93e3          	bne	s5,s3,80003a4a <piperead+0x72>
    80003a88:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80003a8a:	21c48513          	addi	a0,s1,540
    80003a8e:	92dfd0ef          	jal	800013ba <wakeup>
  release(&pi->lock);
    80003a92:	8526                	mv	a0,s1
    80003a94:	705010ef          	jal	80005998 <release>
    80003a98:	6b42                	ld	s6,16(sp)
  return i;
}
    80003a9a:	854e                	mv	a0,s3
    80003a9c:	60a6                	ld	ra,72(sp)
    80003a9e:	6406                	ld	s0,64(sp)
    80003aa0:	74e2                	ld	s1,56(sp)
    80003aa2:	7942                	ld	s2,48(sp)
    80003aa4:	79a2                	ld	s3,40(sp)
    80003aa6:	7a02                	ld	s4,32(sp)
    80003aa8:	6ae2                	ld	s5,24(sp)
    80003aaa:	6161                	addi	sp,sp,80
    80003aac:	8082                	ret

0000000080003aae <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80003aae:	1141                	addi	sp,sp,-16
    80003ab0:	e422                	sd	s0,8(sp)
    80003ab2:	0800                	addi	s0,sp,16
    80003ab4:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80003ab6:	8905                	andi	a0,a0,1
    80003ab8:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80003aba:	8b89                	andi	a5,a5,2
    80003abc:	c399                	beqz	a5,80003ac2 <flags2perm+0x14>
      perm |= PTE_W;
    80003abe:	00456513          	ori	a0,a0,4
    return perm;
}
    80003ac2:	6422                	ld	s0,8(sp)
    80003ac4:	0141                	addi	sp,sp,16
    80003ac6:	8082                	ret

0000000080003ac8 <exec>:

int
exec(char *path, char **argv)
{
    80003ac8:	df010113          	addi	sp,sp,-528
    80003acc:	20113423          	sd	ra,520(sp)
    80003ad0:	20813023          	sd	s0,512(sp)
    80003ad4:	ffa6                	sd	s1,504(sp)
    80003ad6:	fbca                	sd	s2,496(sp)
    80003ad8:	0c00                	addi	s0,sp,528
    80003ada:	892a                	mv	s2,a0
    80003adc:	dea43c23          	sd	a0,-520(s0)
    80003ae0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80003ae4:	ab4fd0ef          	jal	80000d98 <myproc>
    80003ae8:	84aa                	mv	s1,a0

  begin_op();
    80003aea:	dc6ff0ef          	jal	800030b0 <begin_op>

  if((ip = namei(path)) == 0){
    80003aee:	854a                	mv	a0,s2
    80003af0:	c04ff0ef          	jal	80002ef4 <namei>
    80003af4:	c931                	beqz	a0,80003b48 <exec+0x80>
    80003af6:	f3d2                	sd	s4,480(sp)
    80003af8:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80003afa:	d21fe0ef          	jal	8000281a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80003afe:	04000713          	li	a4,64
    80003b02:	4681                	li	a3,0
    80003b04:	e5040613          	addi	a2,s0,-432
    80003b08:	4581                	li	a1,0
    80003b0a:	8552                	mv	a0,s4
    80003b0c:	f63fe0ef          	jal	80002a6e <readi>
    80003b10:	04000793          	li	a5,64
    80003b14:	00f51a63          	bne	a0,a5,80003b28 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80003b18:	e5042703          	lw	a4,-432(s0)
    80003b1c:	464c47b7          	lui	a5,0x464c4
    80003b20:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80003b24:	02f70663          	beq	a4,a5,80003b50 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80003b28:	8552                	mv	a0,s4
    80003b2a:	efbfe0ef          	jal	80002a24 <iunlockput>
    end_op();
    80003b2e:	decff0ef          	jal	8000311a <end_op>
  }
  return -1;
    80003b32:	557d                	li	a0,-1
    80003b34:	7a1e                	ld	s4,480(sp)
}
    80003b36:	20813083          	ld	ra,520(sp)
    80003b3a:	20013403          	ld	s0,512(sp)
    80003b3e:	74fe                	ld	s1,504(sp)
    80003b40:	795e                	ld	s2,496(sp)
    80003b42:	21010113          	addi	sp,sp,528
    80003b46:	8082                	ret
    end_op();
    80003b48:	dd2ff0ef          	jal	8000311a <end_op>
    return -1;
    80003b4c:	557d                	li	a0,-1
    80003b4e:	b7e5                	j	80003b36 <exec+0x6e>
    80003b50:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80003b52:	8526                	mv	a0,s1
    80003b54:	aecfd0ef          	jal	80000e40 <proc_pagetable>
    80003b58:	8b2a                	mv	s6,a0
    80003b5a:	2c050b63          	beqz	a0,80003e30 <exec+0x368>
    80003b5e:	f7ce                	sd	s3,488(sp)
    80003b60:	efd6                	sd	s5,472(sp)
    80003b62:	e7de                	sd	s7,456(sp)
    80003b64:	e3e2                	sd	s8,448(sp)
    80003b66:	ff66                	sd	s9,440(sp)
    80003b68:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b6a:	e7042d03          	lw	s10,-400(s0)
    80003b6e:	e8845783          	lhu	a5,-376(s0)
    80003b72:	12078963          	beqz	a5,80003ca4 <exec+0x1dc>
    80003b76:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003b78:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003b7a:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80003b7c:	6c85                	lui	s9,0x1
    80003b7e:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80003b82:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80003b86:	6a85                	lui	s5,0x1
    80003b88:	a085                	j	80003be8 <exec+0x120>
      panic("loadseg: address should exist");
    80003b8a:	00004517          	auipc	a0,0x4
    80003b8e:	afe50513          	addi	a0,a0,-1282 # 80007688 <etext+0x688>
    80003b92:	241010ef          	jal	800055d2 <panic>
    if(sz - i < PGSIZE)
    80003b96:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80003b98:	8726                	mv	a4,s1
    80003b9a:	012c06bb          	addw	a3,s8,s2
    80003b9e:	4581                	li	a1,0
    80003ba0:	8552                	mv	a0,s4
    80003ba2:	ecdfe0ef          	jal	80002a6e <readi>
    80003ba6:	2501                	sext.w	a0,a0
    80003ba8:	24a49a63          	bne	s1,a0,80003dfc <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80003bac:	012a893b          	addw	s2,s5,s2
    80003bb0:	03397363          	bgeu	s2,s3,80003bd6 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80003bb4:	02091593          	slli	a1,s2,0x20
    80003bb8:	9181                	srli	a1,a1,0x20
    80003bba:	95de                	add	a1,a1,s7
    80003bbc:	855a                	mv	a0,s6
    80003bbe:	8c7fc0ef          	jal	80000484 <walkaddr>
    80003bc2:	862a                	mv	a2,a0
    if(pa == 0)
    80003bc4:	d179                	beqz	a0,80003b8a <exec+0xc2>
    if(sz - i < PGSIZE)
    80003bc6:	412984bb          	subw	s1,s3,s2
    80003bca:	0004879b          	sext.w	a5,s1
    80003bce:	fcfcf4e3          	bgeu	s9,a5,80003b96 <exec+0xce>
    80003bd2:	84d6                	mv	s1,s5
    80003bd4:	b7c9                	j	80003b96 <exec+0xce>
    sz = sz1;
    80003bd6:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80003bda:	2d85                	addiw	s11,s11,1
    80003bdc:	038d0d1b          	addiw	s10,s10,56
    80003be0:	e8845783          	lhu	a5,-376(s0)
    80003be4:	08fdd063          	bge	s11,a5,80003c64 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80003be8:	2d01                	sext.w	s10,s10
    80003bea:	03800713          	li	a4,56
    80003bee:	86ea                	mv	a3,s10
    80003bf0:	e1840613          	addi	a2,s0,-488
    80003bf4:	4581                	li	a1,0
    80003bf6:	8552                	mv	a0,s4
    80003bf8:	e77fe0ef          	jal	80002a6e <readi>
    80003bfc:	03800793          	li	a5,56
    80003c00:	1cf51663          	bne	a0,a5,80003dcc <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80003c04:	e1842783          	lw	a5,-488(s0)
    80003c08:	4705                	li	a4,1
    80003c0a:	fce798e3          	bne	a5,a4,80003bda <exec+0x112>
    if(ph.memsz < ph.filesz)
    80003c0e:	e4043483          	ld	s1,-448(s0)
    80003c12:	e3843783          	ld	a5,-456(s0)
    80003c16:	1af4ef63          	bltu	s1,a5,80003dd4 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80003c1a:	e2843783          	ld	a5,-472(s0)
    80003c1e:	94be                	add	s1,s1,a5
    80003c20:	1af4ee63          	bltu	s1,a5,80003ddc <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80003c24:	df043703          	ld	a4,-528(s0)
    80003c28:	8ff9                	and	a5,a5,a4
    80003c2a:	1a079d63          	bnez	a5,80003de4 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80003c2e:	e1c42503          	lw	a0,-484(s0)
    80003c32:	e7dff0ef          	jal	80003aae <flags2perm>
    80003c36:	86aa                	mv	a3,a0
    80003c38:	8626                	mv	a2,s1
    80003c3a:	85ca                	mv	a1,s2
    80003c3c:	855a                	mv	a0,s6
    80003c3e:	bbffc0ef          	jal	800007fc <uvmalloc>
    80003c42:	e0a43423          	sd	a0,-504(s0)
    80003c46:	1a050363          	beqz	a0,80003dec <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80003c4a:	e2843b83          	ld	s7,-472(s0)
    80003c4e:	e2042c03          	lw	s8,-480(s0)
    80003c52:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80003c56:	00098463          	beqz	s3,80003c5e <exec+0x196>
    80003c5a:	4901                	li	s2,0
    80003c5c:	bfa1                	j	80003bb4 <exec+0xec>
    sz = sz1;
    80003c5e:	e0843903          	ld	s2,-504(s0)
    80003c62:	bfa5                	j	80003bda <exec+0x112>
    80003c64:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80003c66:	8552                	mv	a0,s4
    80003c68:	dbdfe0ef          	jal	80002a24 <iunlockput>
  end_op();
    80003c6c:	caeff0ef          	jal	8000311a <end_op>
  p = myproc();
    80003c70:	928fd0ef          	jal	80000d98 <myproc>
    80003c74:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80003c76:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80003c7a:	6985                	lui	s3,0x1
    80003c7c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80003c7e:	99ca                	add	s3,s3,s2
    80003c80:	77fd                	lui	a5,0xfffff
    80003c82:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80003c86:	4691                	li	a3,4
    80003c88:	6609                	lui	a2,0x2
    80003c8a:	964e                	add	a2,a2,s3
    80003c8c:	85ce                	mv	a1,s3
    80003c8e:	855a                	mv	a0,s6
    80003c90:	b6dfc0ef          	jal	800007fc <uvmalloc>
    80003c94:	892a                	mv	s2,a0
    80003c96:	e0a43423          	sd	a0,-504(s0)
    80003c9a:	e519                	bnez	a0,80003ca8 <exec+0x1e0>
  if(pagetable)
    80003c9c:	e1343423          	sd	s3,-504(s0)
    80003ca0:	4a01                	li	s4,0
    80003ca2:	aab1                	j	80003dfe <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80003ca4:	4901                	li	s2,0
    80003ca6:	b7c1                	j	80003c66 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80003ca8:	75f9                	lui	a1,0xffffe
    80003caa:	95aa                	add	a1,a1,a0
    80003cac:	855a                	mv	a0,s6
    80003cae:	d31fc0ef          	jal	800009de <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80003cb2:	7bfd                	lui	s7,0xfffff
    80003cb4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80003cb6:	e0043783          	ld	a5,-512(s0)
    80003cba:	6388                	ld	a0,0(a5)
    80003cbc:	cd39                	beqz	a0,80003d1a <exec+0x252>
    80003cbe:	e9040993          	addi	s3,s0,-368
    80003cc2:	f9040c13          	addi	s8,s0,-112
    80003cc6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80003cc8:	e1efc0ef          	jal	800002e6 <strlen>
    80003ccc:	0015079b          	addiw	a5,a0,1
    80003cd0:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80003cd4:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80003cd8:	11796e63          	bltu	s2,s7,80003df4 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80003cdc:	e0043d03          	ld	s10,-512(s0)
    80003ce0:	000d3a03          	ld	s4,0(s10)
    80003ce4:	8552                	mv	a0,s4
    80003ce6:	e00fc0ef          	jal	800002e6 <strlen>
    80003cea:	0015069b          	addiw	a3,a0,1
    80003cee:	8652                	mv	a2,s4
    80003cf0:	85ca                	mv	a1,s2
    80003cf2:	855a                	mv	a0,s6
    80003cf4:	d15fc0ef          	jal	80000a08 <copyout>
    80003cf8:	10054063          	bltz	a0,80003df8 <exec+0x330>
    ustack[argc] = sp;
    80003cfc:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80003d00:	0485                	addi	s1,s1,1
    80003d02:	008d0793          	addi	a5,s10,8
    80003d06:	e0f43023          	sd	a5,-512(s0)
    80003d0a:	008d3503          	ld	a0,8(s10)
    80003d0e:	c909                	beqz	a0,80003d20 <exec+0x258>
    if(argc >= MAXARG)
    80003d10:	09a1                	addi	s3,s3,8
    80003d12:	fb899be3          	bne	s3,s8,80003cc8 <exec+0x200>
  ip = 0;
    80003d16:	4a01                	li	s4,0
    80003d18:	a0dd                	j	80003dfe <exec+0x336>
  sp = sz;
    80003d1a:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80003d1e:	4481                	li	s1,0
  ustack[argc] = 0;
    80003d20:	00349793          	slli	a5,s1,0x3
    80003d24:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffddf40>
    80003d28:	97a2                	add	a5,a5,s0
    80003d2a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80003d2e:	00148693          	addi	a3,s1,1
    80003d32:	068e                	slli	a3,a3,0x3
    80003d34:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80003d38:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80003d3c:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80003d40:	f5796ee3          	bltu	s2,s7,80003c9c <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80003d44:	e9040613          	addi	a2,s0,-368
    80003d48:	85ca                	mv	a1,s2
    80003d4a:	855a                	mv	a0,s6
    80003d4c:	cbdfc0ef          	jal	80000a08 <copyout>
    80003d50:	0e054263          	bltz	a0,80003e34 <exec+0x36c>
  p->trapframe->a1 = sp;
    80003d54:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80003d58:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80003d5c:	df843783          	ld	a5,-520(s0)
    80003d60:	0007c703          	lbu	a4,0(a5)
    80003d64:	cf11                	beqz	a4,80003d80 <exec+0x2b8>
    80003d66:	0785                	addi	a5,a5,1
    if(*s == '/')
    80003d68:	02f00693          	li	a3,47
    80003d6c:	a039                	j	80003d7a <exec+0x2b2>
      last = s+1;
    80003d6e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80003d72:	0785                	addi	a5,a5,1
    80003d74:	fff7c703          	lbu	a4,-1(a5)
    80003d78:	c701                	beqz	a4,80003d80 <exec+0x2b8>
    if(*s == '/')
    80003d7a:	fed71ce3          	bne	a4,a3,80003d72 <exec+0x2aa>
    80003d7e:	bfc5                	j	80003d6e <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80003d80:	4641                	li	a2,16
    80003d82:	df843583          	ld	a1,-520(s0)
    80003d86:	158a8513          	addi	a0,s5,344
    80003d8a:	d2afc0ef          	jal	800002b4 <safestrcpy>
  oldpagetable = p->pagetable;
    80003d8e:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80003d92:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80003d96:	e0843783          	ld	a5,-504(s0)
    80003d9a:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80003d9e:	058ab783          	ld	a5,88(s5)
    80003da2:	e6843703          	ld	a4,-408(s0)
    80003da6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80003da8:	058ab783          	ld	a5,88(s5)
    80003dac:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80003db0:	85e6                	mv	a1,s9
    80003db2:	912fd0ef          	jal	80000ec4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80003db6:	0004851b          	sext.w	a0,s1
    80003dba:	79be                	ld	s3,488(sp)
    80003dbc:	7a1e                	ld	s4,480(sp)
    80003dbe:	6afe                	ld	s5,472(sp)
    80003dc0:	6b5e                	ld	s6,464(sp)
    80003dc2:	6bbe                	ld	s7,456(sp)
    80003dc4:	6c1e                	ld	s8,448(sp)
    80003dc6:	7cfa                	ld	s9,440(sp)
    80003dc8:	7d5a                	ld	s10,432(sp)
    80003dca:	b3b5                	j	80003b36 <exec+0x6e>
    80003dcc:	e1243423          	sd	s2,-504(s0)
    80003dd0:	7dba                	ld	s11,424(sp)
    80003dd2:	a035                	j	80003dfe <exec+0x336>
    80003dd4:	e1243423          	sd	s2,-504(s0)
    80003dd8:	7dba                	ld	s11,424(sp)
    80003dda:	a015                	j	80003dfe <exec+0x336>
    80003ddc:	e1243423          	sd	s2,-504(s0)
    80003de0:	7dba                	ld	s11,424(sp)
    80003de2:	a831                	j	80003dfe <exec+0x336>
    80003de4:	e1243423          	sd	s2,-504(s0)
    80003de8:	7dba                	ld	s11,424(sp)
    80003dea:	a811                	j	80003dfe <exec+0x336>
    80003dec:	e1243423          	sd	s2,-504(s0)
    80003df0:	7dba                	ld	s11,424(sp)
    80003df2:	a031                	j	80003dfe <exec+0x336>
  ip = 0;
    80003df4:	4a01                	li	s4,0
    80003df6:	a021                	j	80003dfe <exec+0x336>
    80003df8:	4a01                	li	s4,0
  if(pagetable)
    80003dfa:	a011                	j	80003dfe <exec+0x336>
    80003dfc:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80003dfe:	e0843583          	ld	a1,-504(s0)
    80003e02:	855a                	mv	a0,s6
    80003e04:	8c0fd0ef          	jal	80000ec4 <proc_freepagetable>
  return -1;
    80003e08:	557d                	li	a0,-1
  if(ip){
    80003e0a:	000a1b63          	bnez	s4,80003e20 <exec+0x358>
    80003e0e:	79be                	ld	s3,488(sp)
    80003e10:	7a1e                	ld	s4,480(sp)
    80003e12:	6afe                	ld	s5,472(sp)
    80003e14:	6b5e                	ld	s6,464(sp)
    80003e16:	6bbe                	ld	s7,456(sp)
    80003e18:	6c1e                	ld	s8,448(sp)
    80003e1a:	7cfa                	ld	s9,440(sp)
    80003e1c:	7d5a                	ld	s10,432(sp)
    80003e1e:	bb21                	j	80003b36 <exec+0x6e>
    80003e20:	79be                	ld	s3,488(sp)
    80003e22:	6afe                	ld	s5,472(sp)
    80003e24:	6b5e                	ld	s6,464(sp)
    80003e26:	6bbe                	ld	s7,456(sp)
    80003e28:	6c1e                	ld	s8,448(sp)
    80003e2a:	7cfa                	ld	s9,440(sp)
    80003e2c:	7d5a                	ld	s10,432(sp)
    80003e2e:	b9ed                	j	80003b28 <exec+0x60>
    80003e30:	6b5e                	ld	s6,464(sp)
    80003e32:	b9dd                	j	80003b28 <exec+0x60>
  sz = sz1;
    80003e34:	e0843983          	ld	s3,-504(s0)
    80003e38:	b595                	j	80003c9c <exec+0x1d4>

0000000080003e3a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80003e3a:	7179                	addi	sp,sp,-48
    80003e3c:	f406                	sd	ra,40(sp)
    80003e3e:	f022                	sd	s0,32(sp)
    80003e40:	ec26                	sd	s1,24(sp)
    80003e42:	e84a                	sd	s2,16(sp)
    80003e44:	1800                	addi	s0,sp,48
    80003e46:	892e                	mv	s2,a1
    80003e48:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80003e4a:	fdc40593          	addi	a1,s0,-36
    80003e4e:	e6bfd0ef          	jal	80001cb8 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80003e52:	fdc42703          	lw	a4,-36(s0)
    80003e56:	47bd                	li	a5,15
    80003e58:	02e7e963          	bltu	a5,a4,80003e8a <argfd+0x50>
    80003e5c:	f3dfc0ef          	jal	80000d98 <myproc>
    80003e60:	fdc42703          	lw	a4,-36(s0)
    80003e64:	01a70793          	addi	a5,a4,26
    80003e68:	078e                	slli	a5,a5,0x3
    80003e6a:	953e                	add	a0,a0,a5
    80003e6c:	611c                	ld	a5,0(a0)
    80003e6e:	c385                	beqz	a5,80003e8e <argfd+0x54>
    return -1;
  if(pfd)
    80003e70:	00090463          	beqz	s2,80003e78 <argfd+0x3e>
    *pfd = fd;
    80003e74:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80003e78:	4501                	li	a0,0
  if(pf)
    80003e7a:	c091                	beqz	s1,80003e7e <argfd+0x44>
    *pf = f;
    80003e7c:	e09c                	sd	a5,0(s1)
}
    80003e7e:	70a2                	ld	ra,40(sp)
    80003e80:	7402                	ld	s0,32(sp)
    80003e82:	64e2                	ld	s1,24(sp)
    80003e84:	6942                	ld	s2,16(sp)
    80003e86:	6145                	addi	sp,sp,48
    80003e88:	8082                	ret
    return -1;
    80003e8a:	557d                	li	a0,-1
    80003e8c:	bfcd                	j	80003e7e <argfd+0x44>
    80003e8e:	557d                	li	a0,-1
    80003e90:	b7fd                	j	80003e7e <argfd+0x44>

0000000080003e92 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80003e92:	1101                	addi	sp,sp,-32
    80003e94:	ec06                	sd	ra,24(sp)
    80003e96:	e822                	sd	s0,16(sp)
    80003e98:	e426                	sd	s1,8(sp)
    80003e9a:	1000                	addi	s0,sp,32
    80003e9c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80003e9e:	efbfc0ef          	jal	80000d98 <myproc>
    80003ea2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80003ea4:	0d050793          	addi	a5,a0,208
    80003ea8:	4501                	li	a0,0
    80003eaa:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80003eac:	6398                	ld	a4,0(a5)
    80003eae:	cb19                	beqz	a4,80003ec4 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80003eb0:	2505                	addiw	a0,a0,1
    80003eb2:	07a1                	addi	a5,a5,8
    80003eb4:	fed51ce3          	bne	a0,a3,80003eac <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80003eb8:	557d                	li	a0,-1
}
    80003eba:	60e2                	ld	ra,24(sp)
    80003ebc:	6442                	ld	s0,16(sp)
    80003ebe:	64a2                	ld	s1,8(sp)
    80003ec0:	6105                	addi	sp,sp,32
    80003ec2:	8082                	ret
      p->ofile[fd] = f;
    80003ec4:	01a50793          	addi	a5,a0,26
    80003ec8:	078e                	slli	a5,a5,0x3
    80003eca:	963e                	add	a2,a2,a5
    80003ecc:	e204                	sd	s1,0(a2)
      return fd;
    80003ece:	b7f5                	j	80003eba <fdalloc+0x28>

0000000080003ed0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80003ed0:	715d                	addi	sp,sp,-80
    80003ed2:	e486                	sd	ra,72(sp)
    80003ed4:	e0a2                	sd	s0,64(sp)
    80003ed6:	fc26                	sd	s1,56(sp)
    80003ed8:	f84a                	sd	s2,48(sp)
    80003eda:	f44e                	sd	s3,40(sp)
    80003edc:	ec56                	sd	s5,24(sp)
    80003ede:	e85a                	sd	s6,16(sp)
    80003ee0:	0880                	addi	s0,sp,80
    80003ee2:	8b2e                	mv	s6,a1
    80003ee4:	89b2                	mv	s3,a2
    80003ee6:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80003ee8:	fb040593          	addi	a1,s0,-80
    80003eec:	822ff0ef          	jal	80002f0e <nameiparent>
    80003ef0:	84aa                	mv	s1,a0
    80003ef2:	10050a63          	beqz	a0,80004006 <create+0x136>
    return 0;

  ilock(dp);
    80003ef6:	925fe0ef          	jal	8000281a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80003efa:	4601                	li	a2,0
    80003efc:	fb040593          	addi	a1,s0,-80
    80003f00:	8526                	mv	a0,s1
    80003f02:	d8dfe0ef          	jal	80002c8e <dirlookup>
    80003f06:	8aaa                	mv	s5,a0
    80003f08:	c129                	beqz	a0,80003f4a <create+0x7a>
    iunlockput(dp);
    80003f0a:	8526                	mv	a0,s1
    80003f0c:	b19fe0ef          	jal	80002a24 <iunlockput>
    ilock(ip);
    80003f10:	8556                	mv	a0,s5
    80003f12:	909fe0ef          	jal	8000281a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80003f16:	4789                	li	a5,2
    80003f18:	02fb1463          	bne	s6,a5,80003f40 <create+0x70>
    80003f1c:	044ad783          	lhu	a5,68(s5)
    80003f20:	37f9                	addiw	a5,a5,-2
    80003f22:	17c2                	slli	a5,a5,0x30
    80003f24:	93c1                	srli	a5,a5,0x30
    80003f26:	4705                	li	a4,1
    80003f28:	00f76c63          	bltu	a4,a5,80003f40 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80003f2c:	8556                	mv	a0,s5
    80003f2e:	60a6                	ld	ra,72(sp)
    80003f30:	6406                	ld	s0,64(sp)
    80003f32:	74e2                	ld	s1,56(sp)
    80003f34:	7942                	ld	s2,48(sp)
    80003f36:	79a2                	ld	s3,40(sp)
    80003f38:	6ae2                	ld	s5,24(sp)
    80003f3a:	6b42                	ld	s6,16(sp)
    80003f3c:	6161                	addi	sp,sp,80
    80003f3e:	8082                	ret
    iunlockput(ip);
    80003f40:	8556                	mv	a0,s5
    80003f42:	ae3fe0ef          	jal	80002a24 <iunlockput>
    return 0;
    80003f46:	4a81                	li	s5,0
    80003f48:	b7d5                	j	80003f2c <create+0x5c>
    80003f4a:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80003f4c:	85da                	mv	a1,s6
    80003f4e:	4088                	lw	a0,0(s1)
    80003f50:	f5afe0ef          	jal	800026aa <ialloc>
    80003f54:	8a2a                	mv	s4,a0
    80003f56:	cd15                	beqz	a0,80003f92 <create+0xc2>
  ilock(ip);
    80003f58:	8c3fe0ef          	jal	8000281a <ilock>
  ip->major = major;
    80003f5c:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80003f60:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80003f64:	4905                	li	s2,1
    80003f66:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80003f6a:	8552                	mv	a0,s4
    80003f6c:	ffafe0ef          	jal	80002766 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80003f70:	032b0763          	beq	s6,s2,80003f9e <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80003f74:	004a2603          	lw	a2,4(s4)
    80003f78:	fb040593          	addi	a1,s0,-80
    80003f7c:	8526                	mv	a0,s1
    80003f7e:	eddfe0ef          	jal	80002e5a <dirlink>
    80003f82:	06054563          	bltz	a0,80003fec <create+0x11c>
  iunlockput(dp);
    80003f86:	8526                	mv	a0,s1
    80003f88:	a9dfe0ef          	jal	80002a24 <iunlockput>
  return ip;
    80003f8c:	8ad2                	mv	s5,s4
    80003f8e:	7a02                	ld	s4,32(sp)
    80003f90:	bf71                	j	80003f2c <create+0x5c>
    iunlockput(dp);
    80003f92:	8526                	mv	a0,s1
    80003f94:	a91fe0ef          	jal	80002a24 <iunlockput>
    return 0;
    80003f98:	8ad2                	mv	s5,s4
    80003f9a:	7a02                	ld	s4,32(sp)
    80003f9c:	bf41                	j	80003f2c <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80003f9e:	004a2603          	lw	a2,4(s4)
    80003fa2:	00003597          	auipc	a1,0x3
    80003fa6:	70658593          	addi	a1,a1,1798 # 800076a8 <etext+0x6a8>
    80003faa:	8552                	mv	a0,s4
    80003fac:	eaffe0ef          	jal	80002e5a <dirlink>
    80003fb0:	02054e63          	bltz	a0,80003fec <create+0x11c>
    80003fb4:	40d0                	lw	a2,4(s1)
    80003fb6:	00003597          	auipc	a1,0x3
    80003fba:	6fa58593          	addi	a1,a1,1786 # 800076b0 <etext+0x6b0>
    80003fbe:	8552                	mv	a0,s4
    80003fc0:	e9bfe0ef          	jal	80002e5a <dirlink>
    80003fc4:	02054463          	bltz	a0,80003fec <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80003fc8:	004a2603          	lw	a2,4(s4)
    80003fcc:	fb040593          	addi	a1,s0,-80
    80003fd0:	8526                	mv	a0,s1
    80003fd2:	e89fe0ef          	jal	80002e5a <dirlink>
    80003fd6:	00054b63          	bltz	a0,80003fec <create+0x11c>
    dp->nlink++;  // for ".."
    80003fda:	04a4d783          	lhu	a5,74(s1)
    80003fde:	2785                	addiw	a5,a5,1
    80003fe0:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	f80fe0ef          	jal	80002766 <iupdate>
    80003fea:	bf71                	j	80003f86 <create+0xb6>
  ip->nlink = 0;
    80003fec:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80003ff0:	8552                	mv	a0,s4
    80003ff2:	f74fe0ef          	jal	80002766 <iupdate>
  iunlockput(ip);
    80003ff6:	8552                	mv	a0,s4
    80003ff8:	a2dfe0ef          	jal	80002a24 <iunlockput>
  iunlockput(dp);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	a27fe0ef          	jal	80002a24 <iunlockput>
  return 0;
    80004002:	7a02                	ld	s4,32(sp)
    80004004:	b725                	j	80003f2c <create+0x5c>
    return 0;
    80004006:	8aaa                	mv	s5,a0
    80004008:	b715                	j	80003f2c <create+0x5c>

000000008000400a <sys_dup>:
{
    8000400a:	7179                	addi	sp,sp,-48
    8000400c:	f406                	sd	ra,40(sp)
    8000400e:	f022                	sd	s0,32(sp)
    80004010:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004012:	fd840613          	addi	a2,s0,-40
    80004016:	4581                	li	a1,0
    80004018:	4501                	li	a0,0
    8000401a:	e21ff0ef          	jal	80003e3a <argfd>
    return -1;
    8000401e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004020:	02054363          	bltz	a0,80004046 <sys_dup+0x3c>
    80004024:	ec26                	sd	s1,24(sp)
    80004026:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004028:	fd843903          	ld	s2,-40(s0)
    8000402c:	854a                	mv	a0,s2
    8000402e:	e65ff0ef          	jal	80003e92 <fdalloc>
    80004032:	84aa                	mv	s1,a0
    return -1;
    80004034:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004036:	00054d63          	bltz	a0,80004050 <sys_dup+0x46>
  filedup(f);
    8000403a:	854a                	mv	a0,s2
    8000403c:	c48ff0ef          	jal	80003484 <filedup>
  return fd;
    80004040:	87a6                	mv	a5,s1
    80004042:	64e2                	ld	s1,24(sp)
    80004044:	6942                	ld	s2,16(sp)
}
    80004046:	853e                	mv	a0,a5
    80004048:	70a2                	ld	ra,40(sp)
    8000404a:	7402                	ld	s0,32(sp)
    8000404c:	6145                	addi	sp,sp,48
    8000404e:	8082                	ret
    80004050:	64e2                	ld	s1,24(sp)
    80004052:	6942                	ld	s2,16(sp)
    80004054:	bfcd                	j	80004046 <sys_dup+0x3c>

0000000080004056 <sys_read>:
{
    80004056:	7179                	addi	sp,sp,-48
    80004058:	f406                	sd	ra,40(sp)
    8000405a:	f022                	sd	s0,32(sp)
    8000405c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000405e:	fd840593          	addi	a1,s0,-40
    80004062:	4505                	li	a0,1
    80004064:	c71fd0ef          	jal	80001cd4 <argaddr>
  argint(2, &n);
    80004068:	fe440593          	addi	a1,s0,-28
    8000406c:	4509                	li	a0,2
    8000406e:	c4bfd0ef          	jal	80001cb8 <argint>
  if(argfd(0, 0, &f) < 0)
    80004072:	fe840613          	addi	a2,s0,-24
    80004076:	4581                	li	a1,0
    80004078:	4501                	li	a0,0
    8000407a:	dc1ff0ef          	jal	80003e3a <argfd>
    8000407e:	87aa                	mv	a5,a0
    return -1;
    80004080:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004082:	0007ca63          	bltz	a5,80004096 <sys_read+0x40>
  return fileread(f, p, n);
    80004086:	fe442603          	lw	a2,-28(s0)
    8000408a:	fd843583          	ld	a1,-40(s0)
    8000408e:	fe843503          	ld	a0,-24(s0)
    80004092:	d58ff0ef          	jal	800035ea <fileread>
}
    80004096:	70a2                	ld	ra,40(sp)
    80004098:	7402                	ld	s0,32(sp)
    8000409a:	6145                	addi	sp,sp,48
    8000409c:	8082                	ret

000000008000409e <sys_write>:
{
    8000409e:	7179                	addi	sp,sp,-48
    800040a0:	f406                	sd	ra,40(sp)
    800040a2:	f022                	sd	s0,32(sp)
    800040a4:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800040a6:	fd840593          	addi	a1,s0,-40
    800040aa:	4505                	li	a0,1
    800040ac:	c29fd0ef          	jal	80001cd4 <argaddr>
  argint(2, &n);
    800040b0:	fe440593          	addi	a1,s0,-28
    800040b4:	4509                	li	a0,2
    800040b6:	c03fd0ef          	jal	80001cb8 <argint>
  if(argfd(0, 0, &f) < 0)
    800040ba:	fe840613          	addi	a2,s0,-24
    800040be:	4581                	li	a1,0
    800040c0:	4501                	li	a0,0
    800040c2:	d79ff0ef          	jal	80003e3a <argfd>
    800040c6:	87aa                	mv	a5,a0
    return -1;
    800040c8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800040ca:	0007ca63          	bltz	a5,800040de <sys_write+0x40>
  return filewrite(f, p, n);
    800040ce:	fe442603          	lw	a2,-28(s0)
    800040d2:	fd843583          	ld	a1,-40(s0)
    800040d6:	fe843503          	ld	a0,-24(s0)
    800040da:	dceff0ef          	jal	800036a8 <filewrite>
}
    800040de:	70a2                	ld	ra,40(sp)
    800040e0:	7402                	ld	s0,32(sp)
    800040e2:	6145                	addi	sp,sp,48
    800040e4:	8082                	ret

00000000800040e6 <sys_close>:
{
    800040e6:	1101                	addi	sp,sp,-32
    800040e8:	ec06                	sd	ra,24(sp)
    800040ea:	e822                	sd	s0,16(sp)
    800040ec:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800040ee:	fe040613          	addi	a2,s0,-32
    800040f2:	fec40593          	addi	a1,s0,-20
    800040f6:	4501                	li	a0,0
    800040f8:	d43ff0ef          	jal	80003e3a <argfd>
    return -1;
    800040fc:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800040fe:	02054063          	bltz	a0,8000411e <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004102:	c97fc0ef          	jal	80000d98 <myproc>
    80004106:	fec42783          	lw	a5,-20(s0)
    8000410a:	07e9                	addi	a5,a5,26
    8000410c:	078e                	slli	a5,a5,0x3
    8000410e:	953e                	add	a0,a0,a5
    80004110:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004114:	fe043503          	ld	a0,-32(s0)
    80004118:	bb2ff0ef          	jal	800034ca <fileclose>
  return 0;
    8000411c:	4781                	li	a5,0
}
    8000411e:	853e                	mv	a0,a5
    80004120:	60e2                	ld	ra,24(sp)
    80004122:	6442                	ld	s0,16(sp)
    80004124:	6105                	addi	sp,sp,32
    80004126:	8082                	ret

0000000080004128 <sys_fstat>:
{
    80004128:	1101                	addi	sp,sp,-32
    8000412a:	ec06                	sd	ra,24(sp)
    8000412c:	e822                	sd	s0,16(sp)
    8000412e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004130:	fe040593          	addi	a1,s0,-32
    80004134:	4505                	li	a0,1
    80004136:	b9ffd0ef          	jal	80001cd4 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000413a:	fe840613          	addi	a2,s0,-24
    8000413e:	4581                	li	a1,0
    80004140:	4501                	li	a0,0
    80004142:	cf9ff0ef          	jal	80003e3a <argfd>
    80004146:	87aa                	mv	a5,a0
    return -1;
    80004148:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000414a:	0007c863          	bltz	a5,8000415a <sys_fstat+0x32>
  return filestat(f, st);
    8000414e:	fe043583          	ld	a1,-32(s0)
    80004152:	fe843503          	ld	a0,-24(s0)
    80004156:	c36ff0ef          	jal	8000358c <filestat>
}
    8000415a:	60e2                	ld	ra,24(sp)
    8000415c:	6442                	ld	s0,16(sp)
    8000415e:	6105                	addi	sp,sp,32
    80004160:	8082                	ret

0000000080004162 <sys_link>:
{
    80004162:	7169                	addi	sp,sp,-304
    80004164:	f606                	sd	ra,296(sp)
    80004166:	f222                	sd	s0,288(sp)
    80004168:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000416a:	08000613          	li	a2,128
    8000416e:	ed040593          	addi	a1,s0,-304
    80004172:	4501                	li	a0,0
    80004174:	b7dfd0ef          	jal	80001cf0 <argstr>
    return -1;
    80004178:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000417a:	0c054e63          	bltz	a0,80004256 <sys_link+0xf4>
    8000417e:	08000613          	li	a2,128
    80004182:	f5040593          	addi	a1,s0,-176
    80004186:	4505                	li	a0,1
    80004188:	b69fd0ef          	jal	80001cf0 <argstr>
    return -1;
    8000418c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000418e:	0c054463          	bltz	a0,80004256 <sys_link+0xf4>
    80004192:	ee26                	sd	s1,280(sp)
  begin_op();
    80004194:	f1dfe0ef          	jal	800030b0 <begin_op>
  if((ip = namei(old)) == 0){
    80004198:	ed040513          	addi	a0,s0,-304
    8000419c:	d59fe0ef          	jal	80002ef4 <namei>
    800041a0:	84aa                	mv	s1,a0
    800041a2:	c53d                	beqz	a0,80004210 <sys_link+0xae>
  ilock(ip);
    800041a4:	e76fe0ef          	jal	8000281a <ilock>
  if(ip->type == T_DIR){
    800041a8:	04449703          	lh	a4,68(s1)
    800041ac:	4785                	li	a5,1
    800041ae:	06f70663          	beq	a4,a5,8000421a <sys_link+0xb8>
    800041b2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800041b4:	04a4d783          	lhu	a5,74(s1)
    800041b8:	2785                	addiw	a5,a5,1
    800041ba:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800041be:	8526                	mv	a0,s1
    800041c0:	da6fe0ef          	jal	80002766 <iupdate>
  iunlock(ip);
    800041c4:	8526                	mv	a0,s1
    800041c6:	f02fe0ef          	jal	800028c8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800041ca:	fd040593          	addi	a1,s0,-48
    800041ce:	f5040513          	addi	a0,s0,-176
    800041d2:	d3dfe0ef          	jal	80002f0e <nameiparent>
    800041d6:	892a                	mv	s2,a0
    800041d8:	cd21                	beqz	a0,80004230 <sys_link+0xce>
  ilock(dp);
    800041da:	e40fe0ef          	jal	8000281a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800041de:	00092703          	lw	a4,0(s2)
    800041e2:	409c                	lw	a5,0(s1)
    800041e4:	04f71363          	bne	a4,a5,8000422a <sys_link+0xc8>
    800041e8:	40d0                	lw	a2,4(s1)
    800041ea:	fd040593          	addi	a1,s0,-48
    800041ee:	854a                	mv	a0,s2
    800041f0:	c6bfe0ef          	jal	80002e5a <dirlink>
    800041f4:	02054b63          	bltz	a0,8000422a <sys_link+0xc8>
  iunlockput(dp);
    800041f8:	854a                	mv	a0,s2
    800041fa:	82bfe0ef          	jal	80002a24 <iunlockput>
  iput(ip);
    800041fe:	8526                	mv	a0,s1
    80004200:	f9cfe0ef          	jal	8000299c <iput>
  end_op();
    80004204:	f17fe0ef          	jal	8000311a <end_op>
  return 0;
    80004208:	4781                	li	a5,0
    8000420a:	64f2                	ld	s1,280(sp)
    8000420c:	6952                	ld	s2,272(sp)
    8000420e:	a0a1                	j	80004256 <sys_link+0xf4>
    end_op();
    80004210:	f0bfe0ef          	jal	8000311a <end_op>
    return -1;
    80004214:	57fd                	li	a5,-1
    80004216:	64f2                	ld	s1,280(sp)
    80004218:	a83d                	j	80004256 <sys_link+0xf4>
    iunlockput(ip);
    8000421a:	8526                	mv	a0,s1
    8000421c:	809fe0ef          	jal	80002a24 <iunlockput>
    end_op();
    80004220:	efbfe0ef          	jal	8000311a <end_op>
    return -1;
    80004224:	57fd                	li	a5,-1
    80004226:	64f2                	ld	s1,280(sp)
    80004228:	a03d                	j	80004256 <sys_link+0xf4>
    iunlockput(dp);
    8000422a:	854a                	mv	a0,s2
    8000422c:	ff8fe0ef          	jal	80002a24 <iunlockput>
  ilock(ip);
    80004230:	8526                	mv	a0,s1
    80004232:	de8fe0ef          	jal	8000281a <ilock>
  ip->nlink--;
    80004236:	04a4d783          	lhu	a5,74(s1)
    8000423a:	37fd                	addiw	a5,a5,-1
    8000423c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004240:	8526                	mv	a0,s1
    80004242:	d24fe0ef          	jal	80002766 <iupdate>
  iunlockput(ip);
    80004246:	8526                	mv	a0,s1
    80004248:	fdcfe0ef          	jal	80002a24 <iunlockput>
  end_op();
    8000424c:	ecffe0ef          	jal	8000311a <end_op>
  return -1;
    80004250:	57fd                	li	a5,-1
    80004252:	64f2                	ld	s1,280(sp)
    80004254:	6952                	ld	s2,272(sp)
}
    80004256:	853e                	mv	a0,a5
    80004258:	70b2                	ld	ra,296(sp)
    8000425a:	7412                	ld	s0,288(sp)
    8000425c:	6155                	addi	sp,sp,304
    8000425e:	8082                	ret

0000000080004260 <sys_unlink>:
{
    80004260:	7151                	addi	sp,sp,-240
    80004262:	f586                	sd	ra,232(sp)
    80004264:	f1a2                	sd	s0,224(sp)
    80004266:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004268:	08000613          	li	a2,128
    8000426c:	f3040593          	addi	a1,s0,-208
    80004270:	4501                	li	a0,0
    80004272:	a7ffd0ef          	jal	80001cf0 <argstr>
    80004276:	16054063          	bltz	a0,800043d6 <sys_unlink+0x176>
    8000427a:	eda6                	sd	s1,216(sp)
  begin_op();
    8000427c:	e35fe0ef          	jal	800030b0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004280:	fb040593          	addi	a1,s0,-80
    80004284:	f3040513          	addi	a0,s0,-208
    80004288:	c87fe0ef          	jal	80002f0e <nameiparent>
    8000428c:	84aa                	mv	s1,a0
    8000428e:	c945                	beqz	a0,8000433e <sys_unlink+0xde>
  ilock(dp);
    80004290:	d8afe0ef          	jal	8000281a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004294:	00003597          	auipc	a1,0x3
    80004298:	41458593          	addi	a1,a1,1044 # 800076a8 <etext+0x6a8>
    8000429c:	fb040513          	addi	a0,s0,-80
    800042a0:	9d9fe0ef          	jal	80002c78 <namecmp>
    800042a4:	10050e63          	beqz	a0,800043c0 <sys_unlink+0x160>
    800042a8:	00003597          	auipc	a1,0x3
    800042ac:	40858593          	addi	a1,a1,1032 # 800076b0 <etext+0x6b0>
    800042b0:	fb040513          	addi	a0,s0,-80
    800042b4:	9c5fe0ef          	jal	80002c78 <namecmp>
    800042b8:	10050463          	beqz	a0,800043c0 <sys_unlink+0x160>
    800042bc:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800042be:	f2c40613          	addi	a2,s0,-212
    800042c2:	fb040593          	addi	a1,s0,-80
    800042c6:	8526                	mv	a0,s1
    800042c8:	9c7fe0ef          	jal	80002c8e <dirlookup>
    800042cc:	892a                	mv	s2,a0
    800042ce:	0e050863          	beqz	a0,800043be <sys_unlink+0x15e>
  ilock(ip);
    800042d2:	d48fe0ef          	jal	8000281a <ilock>
  if(ip->nlink < 1)
    800042d6:	04a91783          	lh	a5,74(s2)
    800042da:	06f05763          	blez	a5,80004348 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800042de:	04491703          	lh	a4,68(s2)
    800042e2:	4785                	li	a5,1
    800042e4:	06f70963          	beq	a4,a5,80004356 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800042e8:	4641                	li	a2,16
    800042ea:	4581                	li	a1,0
    800042ec:	fc040513          	addi	a0,s0,-64
    800042f0:	e87fb0ef          	jal	80000176 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042f4:	4741                	li	a4,16
    800042f6:	f2c42683          	lw	a3,-212(s0)
    800042fa:	fc040613          	addi	a2,s0,-64
    800042fe:	4581                	li	a1,0
    80004300:	8526                	mv	a0,s1
    80004302:	869fe0ef          	jal	80002b6a <writei>
    80004306:	47c1                	li	a5,16
    80004308:	08f51b63          	bne	a0,a5,8000439e <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    8000430c:	04491703          	lh	a4,68(s2)
    80004310:	4785                	li	a5,1
    80004312:	08f70d63          	beq	a4,a5,800043ac <sys_unlink+0x14c>
  iunlockput(dp);
    80004316:	8526                	mv	a0,s1
    80004318:	f0cfe0ef          	jal	80002a24 <iunlockput>
  ip->nlink--;
    8000431c:	04a95783          	lhu	a5,74(s2)
    80004320:	37fd                	addiw	a5,a5,-1
    80004322:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004326:	854a                	mv	a0,s2
    80004328:	c3efe0ef          	jal	80002766 <iupdate>
  iunlockput(ip);
    8000432c:	854a                	mv	a0,s2
    8000432e:	ef6fe0ef          	jal	80002a24 <iunlockput>
  end_op();
    80004332:	de9fe0ef          	jal	8000311a <end_op>
  return 0;
    80004336:	4501                	li	a0,0
    80004338:	64ee                	ld	s1,216(sp)
    8000433a:	694e                	ld	s2,208(sp)
    8000433c:	a849                	j	800043ce <sys_unlink+0x16e>
    end_op();
    8000433e:	dddfe0ef          	jal	8000311a <end_op>
    return -1;
    80004342:	557d                	li	a0,-1
    80004344:	64ee                	ld	s1,216(sp)
    80004346:	a061                	j	800043ce <sys_unlink+0x16e>
    80004348:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    8000434a:	00003517          	auipc	a0,0x3
    8000434e:	36e50513          	addi	a0,a0,878 # 800076b8 <etext+0x6b8>
    80004352:	280010ef          	jal	800055d2 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004356:	04c92703          	lw	a4,76(s2)
    8000435a:	02000793          	li	a5,32
    8000435e:	f8e7f5e3          	bgeu	a5,a4,800042e8 <sys_unlink+0x88>
    80004362:	e5ce                	sd	s3,200(sp)
    80004364:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004368:	4741                	li	a4,16
    8000436a:	86ce                	mv	a3,s3
    8000436c:	f1840613          	addi	a2,s0,-232
    80004370:	4581                	li	a1,0
    80004372:	854a                	mv	a0,s2
    80004374:	efafe0ef          	jal	80002a6e <readi>
    80004378:	47c1                	li	a5,16
    8000437a:	00f51c63          	bne	a0,a5,80004392 <sys_unlink+0x132>
    if(de.inum != 0)
    8000437e:	f1845783          	lhu	a5,-232(s0)
    80004382:	efa1                	bnez	a5,800043da <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004384:	29c1                	addiw	s3,s3,16
    80004386:	04c92783          	lw	a5,76(s2)
    8000438a:	fcf9efe3          	bltu	s3,a5,80004368 <sys_unlink+0x108>
    8000438e:	69ae                	ld	s3,200(sp)
    80004390:	bfa1                	j	800042e8 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004392:	00003517          	auipc	a0,0x3
    80004396:	33e50513          	addi	a0,a0,830 # 800076d0 <etext+0x6d0>
    8000439a:	238010ef          	jal	800055d2 <panic>
    8000439e:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800043a0:	00003517          	auipc	a0,0x3
    800043a4:	34850513          	addi	a0,a0,840 # 800076e8 <etext+0x6e8>
    800043a8:	22a010ef          	jal	800055d2 <panic>
    dp->nlink--;
    800043ac:	04a4d783          	lhu	a5,74(s1)
    800043b0:	37fd                	addiw	a5,a5,-1
    800043b2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800043b6:	8526                	mv	a0,s1
    800043b8:	baefe0ef          	jal	80002766 <iupdate>
    800043bc:	bfa9                	j	80004316 <sys_unlink+0xb6>
    800043be:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800043c0:	8526                	mv	a0,s1
    800043c2:	e62fe0ef          	jal	80002a24 <iunlockput>
  end_op();
    800043c6:	d55fe0ef          	jal	8000311a <end_op>
  return -1;
    800043ca:	557d                	li	a0,-1
    800043cc:	64ee                	ld	s1,216(sp)
}
    800043ce:	70ae                	ld	ra,232(sp)
    800043d0:	740e                	ld	s0,224(sp)
    800043d2:	616d                	addi	sp,sp,240
    800043d4:	8082                	ret
    return -1;
    800043d6:	557d                	li	a0,-1
    800043d8:	bfdd                	j	800043ce <sys_unlink+0x16e>
    iunlockput(ip);
    800043da:	854a                	mv	a0,s2
    800043dc:	e48fe0ef          	jal	80002a24 <iunlockput>
    goto bad;
    800043e0:	694e                	ld	s2,208(sp)
    800043e2:	69ae                	ld	s3,200(sp)
    800043e4:	bff1                	j	800043c0 <sys_unlink+0x160>

00000000800043e6 <sys_open>:

uint64
sys_open(void)
{
    800043e6:	7131                	addi	sp,sp,-192
    800043e8:	fd06                	sd	ra,184(sp)
    800043ea:	f922                	sd	s0,176(sp)
    800043ec:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800043ee:	f4c40593          	addi	a1,s0,-180
    800043f2:	4505                	li	a0,1
    800043f4:	8c5fd0ef          	jal	80001cb8 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800043f8:	08000613          	li	a2,128
    800043fc:	f5040593          	addi	a1,s0,-176
    80004400:	4501                	li	a0,0
    80004402:	8effd0ef          	jal	80001cf0 <argstr>
    80004406:	87aa                	mv	a5,a0
    return -1;
    80004408:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000440a:	0a07c263          	bltz	a5,800044ae <sys_open+0xc8>
    8000440e:	f526                	sd	s1,168(sp)

  begin_op();
    80004410:	ca1fe0ef          	jal	800030b0 <begin_op>

  if(omode & O_CREATE){
    80004414:	f4c42783          	lw	a5,-180(s0)
    80004418:	2007f793          	andi	a5,a5,512
    8000441c:	c3d5                	beqz	a5,800044c0 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000441e:	4681                	li	a3,0
    80004420:	4601                	li	a2,0
    80004422:	4589                	li	a1,2
    80004424:	f5040513          	addi	a0,s0,-176
    80004428:	aa9ff0ef          	jal	80003ed0 <create>
    8000442c:	84aa                	mv	s1,a0
    if(ip == 0){
    8000442e:	c541                	beqz	a0,800044b6 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004430:	04449703          	lh	a4,68(s1)
    80004434:	478d                	li	a5,3
    80004436:	00f71763          	bne	a4,a5,80004444 <sys_open+0x5e>
    8000443a:	0464d703          	lhu	a4,70(s1)
    8000443e:	47a5                	li	a5,9
    80004440:	0ae7ed63          	bltu	a5,a4,800044fa <sys_open+0x114>
    80004444:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004446:	fe1fe0ef          	jal	80003426 <filealloc>
    8000444a:	892a                	mv	s2,a0
    8000444c:	c179                	beqz	a0,80004512 <sys_open+0x12c>
    8000444e:	ed4e                	sd	s3,152(sp)
    80004450:	a43ff0ef          	jal	80003e92 <fdalloc>
    80004454:	89aa                	mv	s3,a0
    80004456:	0a054a63          	bltz	a0,8000450a <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000445a:	04449703          	lh	a4,68(s1)
    8000445e:	478d                	li	a5,3
    80004460:	0cf70263          	beq	a4,a5,80004524 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004464:	4789                	li	a5,2
    80004466:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000446a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000446e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004472:	f4c42783          	lw	a5,-180(s0)
    80004476:	0017c713          	xori	a4,a5,1
    8000447a:	8b05                	andi	a4,a4,1
    8000447c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004480:	0037f713          	andi	a4,a5,3
    80004484:	00e03733          	snez	a4,a4
    80004488:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000448c:	4007f793          	andi	a5,a5,1024
    80004490:	c791                	beqz	a5,8000449c <sys_open+0xb6>
    80004492:	04449703          	lh	a4,68(s1)
    80004496:	4789                	li	a5,2
    80004498:	08f70d63          	beq	a4,a5,80004532 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000449c:	8526                	mv	a0,s1
    8000449e:	c2afe0ef          	jal	800028c8 <iunlock>
  end_op();
    800044a2:	c79fe0ef          	jal	8000311a <end_op>

  return fd;
    800044a6:	854e                	mv	a0,s3
    800044a8:	74aa                	ld	s1,168(sp)
    800044aa:	790a                	ld	s2,160(sp)
    800044ac:	69ea                	ld	s3,152(sp)
}
    800044ae:	70ea                	ld	ra,184(sp)
    800044b0:	744a                	ld	s0,176(sp)
    800044b2:	6129                	addi	sp,sp,192
    800044b4:	8082                	ret
      end_op();
    800044b6:	c65fe0ef          	jal	8000311a <end_op>
      return -1;
    800044ba:	557d                	li	a0,-1
    800044bc:	74aa                	ld	s1,168(sp)
    800044be:	bfc5                	j	800044ae <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800044c0:	f5040513          	addi	a0,s0,-176
    800044c4:	a31fe0ef          	jal	80002ef4 <namei>
    800044c8:	84aa                	mv	s1,a0
    800044ca:	c11d                	beqz	a0,800044f0 <sys_open+0x10a>
    ilock(ip);
    800044cc:	b4efe0ef          	jal	8000281a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800044d0:	04449703          	lh	a4,68(s1)
    800044d4:	4785                	li	a5,1
    800044d6:	f4f71de3          	bne	a4,a5,80004430 <sys_open+0x4a>
    800044da:	f4c42783          	lw	a5,-180(s0)
    800044de:	d3bd                	beqz	a5,80004444 <sys_open+0x5e>
      iunlockput(ip);
    800044e0:	8526                	mv	a0,s1
    800044e2:	d42fe0ef          	jal	80002a24 <iunlockput>
      end_op();
    800044e6:	c35fe0ef          	jal	8000311a <end_op>
      return -1;
    800044ea:	557d                	li	a0,-1
    800044ec:	74aa                	ld	s1,168(sp)
    800044ee:	b7c1                	j	800044ae <sys_open+0xc8>
      end_op();
    800044f0:	c2bfe0ef          	jal	8000311a <end_op>
      return -1;
    800044f4:	557d                	li	a0,-1
    800044f6:	74aa                	ld	s1,168(sp)
    800044f8:	bf5d                	j	800044ae <sys_open+0xc8>
    iunlockput(ip);
    800044fa:	8526                	mv	a0,s1
    800044fc:	d28fe0ef          	jal	80002a24 <iunlockput>
    end_op();
    80004500:	c1bfe0ef          	jal	8000311a <end_op>
    return -1;
    80004504:	557d                	li	a0,-1
    80004506:	74aa                	ld	s1,168(sp)
    80004508:	b75d                	j	800044ae <sys_open+0xc8>
      fileclose(f);
    8000450a:	854a                	mv	a0,s2
    8000450c:	fbffe0ef          	jal	800034ca <fileclose>
    80004510:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004512:	8526                	mv	a0,s1
    80004514:	d10fe0ef          	jal	80002a24 <iunlockput>
    end_op();
    80004518:	c03fe0ef          	jal	8000311a <end_op>
    return -1;
    8000451c:	557d                	li	a0,-1
    8000451e:	74aa                	ld	s1,168(sp)
    80004520:	790a                	ld	s2,160(sp)
    80004522:	b771                	j	800044ae <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004524:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004528:	04649783          	lh	a5,70(s1)
    8000452c:	02f91223          	sh	a5,36(s2)
    80004530:	bf3d                	j	8000446e <sys_open+0x88>
    itrunc(ip);
    80004532:	8526                	mv	a0,s1
    80004534:	bd4fe0ef          	jal	80002908 <itrunc>
    80004538:	b795                	j	8000449c <sys_open+0xb6>

000000008000453a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000453a:	7175                	addi	sp,sp,-144
    8000453c:	e506                	sd	ra,136(sp)
    8000453e:	e122                	sd	s0,128(sp)
    80004540:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004542:	b6ffe0ef          	jal	800030b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004546:	08000613          	li	a2,128
    8000454a:	f7040593          	addi	a1,s0,-144
    8000454e:	4501                	li	a0,0
    80004550:	fa0fd0ef          	jal	80001cf0 <argstr>
    80004554:	02054363          	bltz	a0,8000457a <sys_mkdir+0x40>
    80004558:	4681                	li	a3,0
    8000455a:	4601                	li	a2,0
    8000455c:	4585                	li	a1,1
    8000455e:	f7040513          	addi	a0,s0,-144
    80004562:	96fff0ef          	jal	80003ed0 <create>
    80004566:	c911                	beqz	a0,8000457a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004568:	cbcfe0ef          	jal	80002a24 <iunlockput>
  end_op();
    8000456c:	baffe0ef          	jal	8000311a <end_op>
  return 0;
    80004570:	4501                	li	a0,0
}
    80004572:	60aa                	ld	ra,136(sp)
    80004574:	640a                	ld	s0,128(sp)
    80004576:	6149                	addi	sp,sp,144
    80004578:	8082                	ret
    end_op();
    8000457a:	ba1fe0ef          	jal	8000311a <end_op>
    return -1;
    8000457e:	557d                	li	a0,-1
    80004580:	bfcd                	j	80004572 <sys_mkdir+0x38>

0000000080004582 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004582:	7135                	addi	sp,sp,-160
    80004584:	ed06                	sd	ra,152(sp)
    80004586:	e922                	sd	s0,144(sp)
    80004588:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000458a:	b27fe0ef          	jal	800030b0 <begin_op>
  argint(1, &major);
    8000458e:	f6c40593          	addi	a1,s0,-148
    80004592:	4505                	li	a0,1
    80004594:	f24fd0ef          	jal	80001cb8 <argint>
  argint(2, &minor);
    80004598:	f6840593          	addi	a1,s0,-152
    8000459c:	4509                	li	a0,2
    8000459e:	f1afd0ef          	jal	80001cb8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800045a2:	08000613          	li	a2,128
    800045a6:	f7040593          	addi	a1,s0,-144
    800045aa:	4501                	li	a0,0
    800045ac:	f44fd0ef          	jal	80001cf0 <argstr>
    800045b0:	02054563          	bltz	a0,800045da <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800045b4:	f6841683          	lh	a3,-152(s0)
    800045b8:	f6c41603          	lh	a2,-148(s0)
    800045bc:	458d                	li	a1,3
    800045be:	f7040513          	addi	a0,s0,-144
    800045c2:	90fff0ef          	jal	80003ed0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800045c6:	c911                	beqz	a0,800045da <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800045c8:	c5cfe0ef          	jal	80002a24 <iunlockput>
  end_op();
    800045cc:	b4ffe0ef          	jal	8000311a <end_op>
  return 0;
    800045d0:	4501                	li	a0,0
}
    800045d2:	60ea                	ld	ra,152(sp)
    800045d4:	644a                	ld	s0,144(sp)
    800045d6:	610d                	addi	sp,sp,160
    800045d8:	8082                	ret
    end_op();
    800045da:	b41fe0ef          	jal	8000311a <end_op>
    return -1;
    800045de:	557d                	li	a0,-1
    800045e0:	bfcd                	j	800045d2 <sys_mknod+0x50>

00000000800045e2 <sys_chdir>:

uint64
sys_chdir(void)
{
    800045e2:	7135                	addi	sp,sp,-160
    800045e4:	ed06                	sd	ra,152(sp)
    800045e6:	e922                	sd	s0,144(sp)
    800045e8:	e14a                	sd	s2,128(sp)
    800045ea:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800045ec:	facfc0ef          	jal	80000d98 <myproc>
    800045f0:	892a                	mv	s2,a0
  
  begin_op();
    800045f2:	abffe0ef          	jal	800030b0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800045f6:	08000613          	li	a2,128
    800045fa:	f6040593          	addi	a1,s0,-160
    800045fe:	4501                	li	a0,0
    80004600:	ef0fd0ef          	jal	80001cf0 <argstr>
    80004604:	04054363          	bltz	a0,8000464a <sys_chdir+0x68>
    80004608:	e526                	sd	s1,136(sp)
    8000460a:	f6040513          	addi	a0,s0,-160
    8000460e:	8e7fe0ef          	jal	80002ef4 <namei>
    80004612:	84aa                	mv	s1,a0
    80004614:	c915                	beqz	a0,80004648 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80004616:	a04fe0ef          	jal	8000281a <ilock>
  if(ip->type != T_DIR){
    8000461a:	04449703          	lh	a4,68(s1)
    8000461e:	4785                	li	a5,1
    80004620:	02f71963          	bne	a4,a5,80004652 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004624:	8526                	mv	a0,s1
    80004626:	aa2fe0ef          	jal	800028c8 <iunlock>
  iput(p->cwd);
    8000462a:	15093503          	ld	a0,336(s2)
    8000462e:	b6efe0ef          	jal	8000299c <iput>
  end_op();
    80004632:	ae9fe0ef          	jal	8000311a <end_op>
  p->cwd = ip;
    80004636:	14993823          	sd	s1,336(s2)
  return 0;
    8000463a:	4501                	li	a0,0
    8000463c:	64aa                	ld	s1,136(sp)
}
    8000463e:	60ea                	ld	ra,152(sp)
    80004640:	644a                	ld	s0,144(sp)
    80004642:	690a                	ld	s2,128(sp)
    80004644:	610d                	addi	sp,sp,160
    80004646:	8082                	ret
    80004648:	64aa                	ld	s1,136(sp)
    end_op();
    8000464a:	ad1fe0ef          	jal	8000311a <end_op>
    return -1;
    8000464e:	557d                	li	a0,-1
    80004650:	b7fd                	j	8000463e <sys_chdir+0x5c>
    iunlockput(ip);
    80004652:	8526                	mv	a0,s1
    80004654:	bd0fe0ef          	jal	80002a24 <iunlockput>
    end_op();
    80004658:	ac3fe0ef          	jal	8000311a <end_op>
    return -1;
    8000465c:	557d                	li	a0,-1
    8000465e:	64aa                	ld	s1,136(sp)
    80004660:	bff9                	j	8000463e <sys_chdir+0x5c>

0000000080004662 <sys_exec>:

uint64
sys_exec(void)
{
    80004662:	7121                	addi	sp,sp,-448
    80004664:	ff06                	sd	ra,440(sp)
    80004666:	fb22                	sd	s0,432(sp)
    80004668:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000466a:	e4840593          	addi	a1,s0,-440
    8000466e:	4505                	li	a0,1
    80004670:	e64fd0ef          	jal	80001cd4 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004674:	08000613          	li	a2,128
    80004678:	f5040593          	addi	a1,s0,-176
    8000467c:	4501                	li	a0,0
    8000467e:	e72fd0ef          	jal	80001cf0 <argstr>
    80004682:	87aa                	mv	a5,a0
    return -1;
    80004684:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004686:	0c07c463          	bltz	a5,8000474e <sys_exec+0xec>
    8000468a:	f726                	sd	s1,424(sp)
    8000468c:	f34a                	sd	s2,416(sp)
    8000468e:	ef4e                	sd	s3,408(sp)
    80004690:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80004692:	10000613          	li	a2,256
    80004696:	4581                	li	a1,0
    80004698:	e5040513          	addi	a0,s0,-432
    8000469c:	adbfb0ef          	jal	80000176 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800046a0:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800046a4:	89a6                	mv	s3,s1
    800046a6:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800046a8:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800046ac:	00391513          	slli	a0,s2,0x3
    800046b0:	e4040593          	addi	a1,s0,-448
    800046b4:	e4843783          	ld	a5,-440(s0)
    800046b8:	953e                	add	a0,a0,a5
    800046ba:	d74fd0ef          	jal	80001c2e <fetchaddr>
    800046be:	02054663          	bltz	a0,800046ea <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800046c2:	e4043783          	ld	a5,-448(s0)
    800046c6:	c3a9                	beqz	a5,80004708 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800046c8:	a2ffb0ef          	jal	800000f6 <kalloc>
    800046cc:	85aa                	mv	a1,a0
    800046ce:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800046d2:	cd01                	beqz	a0,800046ea <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800046d4:	6605                	lui	a2,0x1
    800046d6:	e4043503          	ld	a0,-448(s0)
    800046da:	d9efd0ef          	jal	80001c78 <fetchstr>
    800046de:	00054663          	bltz	a0,800046ea <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800046e2:	0905                	addi	s2,s2,1
    800046e4:	09a1                	addi	s3,s3,8
    800046e6:	fd4913e3          	bne	s2,s4,800046ac <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046ea:	f5040913          	addi	s2,s0,-176
    800046ee:	6088                	ld	a0,0(s1)
    800046f0:	c931                	beqz	a0,80004744 <sys_exec+0xe2>
    kfree(argv[i]);
    800046f2:	92bfb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800046f6:	04a1                	addi	s1,s1,8
    800046f8:	ff249be3          	bne	s1,s2,800046ee <sys_exec+0x8c>
  return -1;
    800046fc:	557d                	li	a0,-1
    800046fe:	74ba                	ld	s1,424(sp)
    80004700:	791a                	ld	s2,416(sp)
    80004702:	69fa                	ld	s3,408(sp)
    80004704:	6a5a                	ld	s4,400(sp)
    80004706:	a0a1                	j	8000474e <sys_exec+0xec>
      argv[i] = 0;
    80004708:	0009079b          	sext.w	a5,s2
    8000470c:	078e                	slli	a5,a5,0x3
    8000470e:	fd078793          	addi	a5,a5,-48
    80004712:	97a2                	add	a5,a5,s0
    80004714:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80004718:	e5040593          	addi	a1,s0,-432
    8000471c:	f5040513          	addi	a0,s0,-176
    80004720:	ba8ff0ef          	jal	80003ac8 <exec>
    80004724:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004726:	f5040993          	addi	s3,s0,-176
    8000472a:	6088                	ld	a0,0(s1)
    8000472c:	c511                	beqz	a0,80004738 <sys_exec+0xd6>
    kfree(argv[i]);
    8000472e:	8effb0ef          	jal	8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004732:	04a1                	addi	s1,s1,8
    80004734:	ff349be3          	bne	s1,s3,8000472a <sys_exec+0xc8>
  return ret;
    80004738:	854a                	mv	a0,s2
    8000473a:	74ba                	ld	s1,424(sp)
    8000473c:	791a                	ld	s2,416(sp)
    8000473e:	69fa                	ld	s3,408(sp)
    80004740:	6a5a                	ld	s4,400(sp)
    80004742:	a031                	j	8000474e <sys_exec+0xec>
  return -1;
    80004744:	557d                	li	a0,-1
    80004746:	74ba                	ld	s1,424(sp)
    80004748:	791a                	ld	s2,416(sp)
    8000474a:	69fa                	ld	s3,408(sp)
    8000474c:	6a5a                	ld	s4,400(sp)
}
    8000474e:	70fa                	ld	ra,440(sp)
    80004750:	745a                	ld	s0,432(sp)
    80004752:	6139                	addi	sp,sp,448
    80004754:	8082                	ret

0000000080004756 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004756:	7139                	addi	sp,sp,-64
    80004758:	fc06                	sd	ra,56(sp)
    8000475a:	f822                	sd	s0,48(sp)
    8000475c:	f426                	sd	s1,40(sp)
    8000475e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004760:	e38fc0ef          	jal	80000d98 <myproc>
    80004764:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004766:	fd840593          	addi	a1,s0,-40
    8000476a:	4501                	li	a0,0
    8000476c:	d68fd0ef          	jal	80001cd4 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004770:	fc840593          	addi	a1,s0,-56
    80004774:	fd040513          	addi	a0,s0,-48
    80004778:	85cff0ef          	jal	800037d4 <pipealloc>
    return -1;
    8000477c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000477e:	0a054463          	bltz	a0,80004826 <sys_pipe+0xd0>
  fd0 = -1;
    80004782:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004786:	fd043503          	ld	a0,-48(s0)
    8000478a:	f08ff0ef          	jal	80003e92 <fdalloc>
    8000478e:	fca42223          	sw	a0,-60(s0)
    80004792:	08054163          	bltz	a0,80004814 <sys_pipe+0xbe>
    80004796:	fc843503          	ld	a0,-56(s0)
    8000479a:	ef8ff0ef          	jal	80003e92 <fdalloc>
    8000479e:	fca42023          	sw	a0,-64(s0)
    800047a2:	06054063          	bltz	a0,80004802 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800047a6:	4691                	li	a3,4
    800047a8:	fc440613          	addi	a2,s0,-60
    800047ac:	fd843583          	ld	a1,-40(s0)
    800047b0:	68a8                	ld	a0,80(s1)
    800047b2:	a56fc0ef          	jal	80000a08 <copyout>
    800047b6:	00054e63          	bltz	a0,800047d2 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800047ba:	4691                	li	a3,4
    800047bc:	fc040613          	addi	a2,s0,-64
    800047c0:	fd843583          	ld	a1,-40(s0)
    800047c4:	0591                	addi	a1,a1,4
    800047c6:	68a8                	ld	a0,80(s1)
    800047c8:	a40fc0ef          	jal	80000a08 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800047cc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800047ce:	04055c63          	bgez	a0,80004826 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800047d2:	fc442783          	lw	a5,-60(s0)
    800047d6:	07e9                	addi	a5,a5,26
    800047d8:	078e                	slli	a5,a5,0x3
    800047da:	97a6                	add	a5,a5,s1
    800047dc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800047e0:	fc042783          	lw	a5,-64(s0)
    800047e4:	07e9                	addi	a5,a5,26
    800047e6:	078e                	slli	a5,a5,0x3
    800047e8:	94be                	add	s1,s1,a5
    800047ea:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800047ee:	fd043503          	ld	a0,-48(s0)
    800047f2:	cd9fe0ef          	jal	800034ca <fileclose>
    fileclose(wf);
    800047f6:	fc843503          	ld	a0,-56(s0)
    800047fa:	cd1fe0ef          	jal	800034ca <fileclose>
    return -1;
    800047fe:	57fd                	li	a5,-1
    80004800:	a01d                	j	80004826 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80004802:	fc442783          	lw	a5,-60(s0)
    80004806:	0007c763          	bltz	a5,80004814 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000480a:	07e9                	addi	a5,a5,26
    8000480c:	078e                	slli	a5,a5,0x3
    8000480e:	97a6                	add	a5,a5,s1
    80004810:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80004814:	fd043503          	ld	a0,-48(s0)
    80004818:	cb3fe0ef          	jal	800034ca <fileclose>
    fileclose(wf);
    8000481c:	fc843503          	ld	a0,-56(s0)
    80004820:	cabfe0ef          	jal	800034ca <fileclose>
    return -1;
    80004824:	57fd                	li	a5,-1
}
    80004826:	853e                	mv	a0,a5
    80004828:	70e2                	ld	ra,56(sp)
    8000482a:	7442                	ld	s0,48(sp)
    8000482c:	74a2                	ld	s1,40(sp)
    8000482e:	6121                	addi	sp,sp,64
    80004830:	8082                	ret
	...

0000000080004840 <kernelvec>:
    80004840:	7111                	addi	sp,sp,-256
    80004842:	e006                	sd	ra,0(sp)
    80004844:	e40a                	sd	sp,8(sp)
    80004846:	e80e                	sd	gp,16(sp)
    80004848:	ec12                	sd	tp,24(sp)
    8000484a:	f016                	sd	t0,32(sp)
    8000484c:	f41a                	sd	t1,40(sp)
    8000484e:	f81e                	sd	t2,48(sp)
    80004850:	e4aa                	sd	a0,72(sp)
    80004852:	e8ae                	sd	a1,80(sp)
    80004854:	ecb2                	sd	a2,88(sp)
    80004856:	f0b6                	sd	a3,96(sp)
    80004858:	f4ba                	sd	a4,104(sp)
    8000485a:	f8be                	sd	a5,112(sp)
    8000485c:	fcc2                	sd	a6,120(sp)
    8000485e:	e146                	sd	a7,128(sp)
    80004860:	edf2                	sd	t3,216(sp)
    80004862:	f1f6                	sd	t4,224(sp)
    80004864:	f5fa                	sd	t5,232(sp)
    80004866:	f9fe                	sd	t6,240(sp)
    80004868:	ad6fd0ef          	jal	80001b3e <kerneltrap>
    8000486c:	6082                	ld	ra,0(sp)
    8000486e:	6122                	ld	sp,8(sp)
    80004870:	61c2                	ld	gp,16(sp)
    80004872:	7282                	ld	t0,32(sp)
    80004874:	7322                	ld	t1,40(sp)
    80004876:	73c2                	ld	t2,48(sp)
    80004878:	6526                	ld	a0,72(sp)
    8000487a:	65c6                	ld	a1,80(sp)
    8000487c:	6666                	ld	a2,88(sp)
    8000487e:	7686                	ld	a3,96(sp)
    80004880:	7726                	ld	a4,104(sp)
    80004882:	77c6                	ld	a5,112(sp)
    80004884:	7866                	ld	a6,120(sp)
    80004886:	688a                	ld	a7,128(sp)
    80004888:	6e6e                	ld	t3,216(sp)
    8000488a:	7e8e                	ld	t4,224(sp)
    8000488c:	7f2e                	ld	t5,232(sp)
    8000488e:	7fce                	ld	t6,240(sp)
    80004890:	6111                	addi	sp,sp,256
    80004892:	10200073          	sret
	...

000000008000489e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000489e:	1141                	addi	sp,sp,-16
    800048a0:	e422                	sd	s0,8(sp)
    800048a2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800048a4:	0c0007b7          	lui	a5,0xc000
    800048a8:	4705                	li	a4,1
    800048aa:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800048ac:	0c0007b7          	lui	a5,0xc000
    800048b0:	c3d8                	sw	a4,4(a5)
}
    800048b2:	6422                	ld	s0,8(sp)
    800048b4:	0141                	addi	sp,sp,16
    800048b6:	8082                	ret

00000000800048b8 <plicinithart>:

void
plicinithart(void)
{
    800048b8:	1141                	addi	sp,sp,-16
    800048ba:	e406                	sd	ra,8(sp)
    800048bc:	e022                	sd	s0,0(sp)
    800048be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800048c0:	cacfc0ef          	jal	80000d6c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800048c4:	0085171b          	slliw	a4,a0,0x8
    800048c8:	0c0027b7          	lui	a5,0xc002
    800048cc:	97ba                	add	a5,a5,a4
    800048ce:	40200713          	li	a4,1026
    800048d2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800048d6:	00d5151b          	slliw	a0,a0,0xd
    800048da:	0c2017b7          	lui	a5,0xc201
    800048de:	97aa                	add	a5,a5,a0
    800048e0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800048e4:	60a2                	ld	ra,8(sp)
    800048e6:	6402                	ld	s0,0(sp)
    800048e8:	0141                	addi	sp,sp,16
    800048ea:	8082                	ret

00000000800048ec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800048ec:	1141                	addi	sp,sp,-16
    800048ee:	e406                	sd	ra,8(sp)
    800048f0:	e022                	sd	s0,0(sp)
    800048f2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800048f4:	c78fc0ef          	jal	80000d6c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800048f8:	00d5151b          	slliw	a0,a0,0xd
    800048fc:	0c2017b7          	lui	a5,0xc201
    80004900:	97aa                	add	a5,a5,a0
  return irq;
}
    80004902:	43c8                	lw	a0,4(a5)
    80004904:	60a2                	ld	ra,8(sp)
    80004906:	6402                	ld	s0,0(sp)
    80004908:	0141                	addi	sp,sp,16
    8000490a:	8082                	ret

000000008000490c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000490c:	1101                	addi	sp,sp,-32
    8000490e:	ec06                	sd	ra,24(sp)
    80004910:	e822                	sd	s0,16(sp)
    80004912:	e426                	sd	s1,8(sp)
    80004914:	1000                	addi	s0,sp,32
    80004916:	84aa                	mv	s1,a0
  int hart = cpuid();
    80004918:	c54fc0ef          	jal	80000d6c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000491c:	00d5151b          	slliw	a0,a0,0xd
    80004920:	0c2017b7          	lui	a5,0xc201
    80004924:	97aa                	add	a5,a5,a0
    80004926:	c3c4                	sw	s1,4(a5)
}
    80004928:	60e2                	ld	ra,24(sp)
    8000492a:	6442                	ld	s0,16(sp)
    8000492c:	64a2                	ld	s1,8(sp)
    8000492e:	6105                	addi	sp,sp,32
    80004930:	8082                	ret

0000000080004932 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80004932:	1141                	addi	sp,sp,-16
    80004934:	e406                	sd	ra,8(sp)
    80004936:	e022                	sd	s0,0(sp)
    80004938:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000493a:	479d                	li	a5,7
    8000493c:	04a7ca63          	blt	a5,a0,80004990 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80004940:	00014797          	auipc	a5,0x14
    80004944:	4d078793          	addi	a5,a5,1232 # 80018e10 <disk>
    80004948:	97aa                	add	a5,a5,a0
    8000494a:	0187c783          	lbu	a5,24(a5)
    8000494e:	e7b9                	bnez	a5,8000499c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80004950:	00451693          	slli	a3,a0,0x4
    80004954:	00014797          	auipc	a5,0x14
    80004958:	4bc78793          	addi	a5,a5,1212 # 80018e10 <disk>
    8000495c:	6398                	ld	a4,0(a5)
    8000495e:	9736                	add	a4,a4,a3
    80004960:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80004964:	6398                	ld	a4,0(a5)
    80004966:	9736                	add	a4,a4,a3
    80004968:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000496c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80004970:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80004974:	97aa                	add	a5,a5,a0
    80004976:	4705                	li	a4,1
    80004978:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000497c:	00014517          	auipc	a0,0x14
    80004980:	4ac50513          	addi	a0,a0,1196 # 80018e28 <disk+0x18>
    80004984:	a37fc0ef          	jal	800013ba <wakeup>
}
    80004988:	60a2                	ld	ra,8(sp)
    8000498a:	6402                	ld	s0,0(sp)
    8000498c:	0141                	addi	sp,sp,16
    8000498e:	8082                	ret
    panic("free_desc 1");
    80004990:	00003517          	auipc	a0,0x3
    80004994:	d6850513          	addi	a0,a0,-664 # 800076f8 <etext+0x6f8>
    80004998:	43b000ef          	jal	800055d2 <panic>
    panic("free_desc 2");
    8000499c:	00003517          	auipc	a0,0x3
    800049a0:	d6c50513          	addi	a0,a0,-660 # 80007708 <etext+0x708>
    800049a4:	42f000ef          	jal	800055d2 <panic>

00000000800049a8 <virtio_disk_init>:
{
    800049a8:	1101                	addi	sp,sp,-32
    800049aa:	ec06                	sd	ra,24(sp)
    800049ac:	e822                	sd	s0,16(sp)
    800049ae:	e426                	sd	s1,8(sp)
    800049b0:	e04a                	sd	s2,0(sp)
    800049b2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800049b4:	00003597          	auipc	a1,0x3
    800049b8:	d6458593          	addi	a1,a1,-668 # 80007718 <etext+0x718>
    800049bc:	00014517          	auipc	a0,0x14
    800049c0:	57c50513          	addi	a0,a0,1404 # 80018f38 <disk+0x128>
    800049c4:	6bd000ef          	jal	80005880 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800049c8:	100017b7          	lui	a5,0x10001
    800049cc:	4398                	lw	a4,0(a5)
    800049ce:	2701                	sext.w	a4,a4
    800049d0:	747277b7          	lui	a5,0x74727
    800049d4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800049d8:	18f71063          	bne	a4,a5,80004b58 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049dc:	100017b7          	lui	a5,0x10001
    800049e0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800049e2:	439c                	lw	a5,0(a5)
    800049e4:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800049e6:	4709                	li	a4,2
    800049e8:	16e79863          	bne	a5,a4,80004b58 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800049ec:	100017b7          	lui	a5,0x10001
    800049f0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800049f2:	439c                	lw	a5,0(a5)
    800049f4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800049f6:	16e79163          	bne	a5,a4,80004b58 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800049fa:	100017b7          	lui	a5,0x10001
    800049fe:	47d8                	lw	a4,12(a5)
    80004a00:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80004a02:	554d47b7          	lui	a5,0x554d4
    80004a06:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80004a0a:	14f71763          	bne	a4,a5,80004b58 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a0e:	100017b7          	lui	a5,0x10001
    80004a12:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a16:	4705                	li	a4,1
    80004a18:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a1a:	470d                	li	a4,3
    80004a1c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80004a1e:	10001737          	lui	a4,0x10001
    80004a22:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80004a24:	c7ffe737          	lui	a4,0xc7ffe
    80004a28:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdd70f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80004a2c:	8ef9                	and	a3,a3,a4
    80004a2e:	10001737          	lui	a4,0x10001
    80004a32:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a34:	472d                	li	a4,11
    80004a36:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80004a38:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80004a3c:	439c                	lw	a5,0(a5)
    80004a3e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80004a42:	8ba1                	andi	a5,a5,8
    80004a44:	12078063          	beqz	a5,80004b64 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80004a48:	100017b7          	lui	a5,0x10001
    80004a4c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80004a50:	100017b7          	lui	a5,0x10001
    80004a54:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80004a58:	439c                	lw	a5,0(a5)
    80004a5a:	2781                	sext.w	a5,a5
    80004a5c:	10079a63          	bnez	a5,80004b70 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80004a60:	100017b7          	lui	a5,0x10001
    80004a64:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80004a68:	439c                	lw	a5,0(a5)
    80004a6a:	2781                	sext.w	a5,a5
  if(max == 0)
    80004a6c:	10078863          	beqz	a5,80004b7c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80004a70:	471d                	li	a4,7
    80004a72:	10f77b63          	bgeu	a4,a5,80004b88 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80004a76:	e80fb0ef          	jal	800000f6 <kalloc>
    80004a7a:	00014497          	auipc	s1,0x14
    80004a7e:	39648493          	addi	s1,s1,918 # 80018e10 <disk>
    80004a82:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80004a84:	e72fb0ef          	jal	800000f6 <kalloc>
    80004a88:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80004a8a:	e6cfb0ef          	jal	800000f6 <kalloc>
    80004a8e:	87aa                	mv	a5,a0
    80004a90:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80004a92:	6088                	ld	a0,0(s1)
    80004a94:	10050063          	beqz	a0,80004b94 <virtio_disk_init+0x1ec>
    80004a98:	00014717          	auipc	a4,0x14
    80004a9c:	38073703          	ld	a4,896(a4) # 80018e18 <disk+0x8>
    80004aa0:	0e070a63          	beqz	a4,80004b94 <virtio_disk_init+0x1ec>
    80004aa4:	0e078863          	beqz	a5,80004b94 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80004aa8:	6605                	lui	a2,0x1
    80004aaa:	4581                	li	a1,0
    80004aac:	ecafb0ef          	jal	80000176 <memset>
  memset(disk.avail, 0, PGSIZE);
    80004ab0:	00014497          	auipc	s1,0x14
    80004ab4:	36048493          	addi	s1,s1,864 # 80018e10 <disk>
    80004ab8:	6605                	lui	a2,0x1
    80004aba:	4581                	li	a1,0
    80004abc:	6488                	ld	a0,8(s1)
    80004abe:	eb8fb0ef          	jal	80000176 <memset>
  memset(disk.used, 0, PGSIZE);
    80004ac2:	6605                	lui	a2,0x1
    80004ac4:	4581                	li	a1,0
    80004ac6:	6888                	ld	a0,16(s1)
    80004ac8:	eaefb0ef          	jal	80000176 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80004acc:	100017b7          	lui	a5,0x10001
    80004ad0:	4721                	li	a4,8
    80004ad2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80004ad4:	4098                	lw	a4,0(s1)
    80004ad6:	100017b7          	lui	a5,0x10001
    80004ada:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80004ade:	40d8                	lw	a4,4(s1)
    80004ae0:	100017b7          	lui	a5,0x10001
    80004ae4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80004ae8:	649c                	ld	a5,8(s1)
    80004aea:	0007869b          	sext.w	a3,a5
    80004aee:	10001737          	lui	a4,0x10001
    80004af2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80004af6:	9781                	srai	a5,a5,0x20
    80004af8:	10001737          	lui	a4,0x10001
    80004afc:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80004b00:	689c                	ld	a5,16(s1)
    80004b02:	0007869b          	sext.w	a3,a5
    80004b06:	10001737          	lui	a4,0x10001
    80004b0a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80004b0e:	9781                	srai	a5,a5,0x20
    80004b10:	10001737          	lui	a4,0x10001
    80004b14:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80004b18:	10001737          	lui	a4,0x10001
    80004b1c:	4785                	li	a5,1
    80004b1e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80004b20:	00f48c23          	sb	a5,24(s1)
    80004b24:	00f48ca3          	sb	a5,25(s1)
    80004b28:	00f48d23          	sb	a5,26(s1)
    80004b2c:	00f48da3          	sb	a5,27(s1)
    80004b30:	00f48e23          	sb	a5,28(s1)
    80004b34:	00f48ea3          	sb	a5,29(s1)
    80004b38:	00f48f23          	sb	a5,30(s1)
    80004b3c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80004b40:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80004b44:	100017b7          	lui	a5,0x10001
    80004b48:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80004b4c:	60e2                	ld	ra,24(sp)
    80004b4e:	6442                	ld	s0,16(sp)
    80004b50:	64a2                	ld	s1,8(sp)
    80004b52:	6902                	ld	s2,0(sp)
    80004b54:	6105                	addi	sp,sp,32
    80004b56:	8082                	ret
    panic("could not find virtio disk");
    80004b58:	00003517          	auipc	a0,0x3
    80004b5c:	bd050513          	addi	a0,a0,-1072 # 80007728 <etext+0x728>
    80004b60:	273000ef          	jal	800055d2 <panic>
    panic("virtio disk FEATURES_OK unset");
    80004b64:	00003517          	auipc	a0,0x3
    80004b68:	be450513          	addi	a0,a0,-1052 # 80007748 <etext+0x748>
    80004b6c:	267000ef          	jal	800055d2 <panic>
    panic("virtio disk should not be ready");
    80004b70:	00003517          	auipc	a0,0x3
    80004b74:	bf850513          	addi	a0,a0,-1032 # 80007768 <etext+0x768>
    80004b78:	25b000ef          	jal	800055d2 <panic>
    panic("virtio disk has no queue 0");
    80004b7c:	00003517          	auipc	a0,0x3
    80004b80:	c0c50513          	addi	a0,a0,-1012 # 80007788 <etext+0x788>
    80004b84:	24f000ef          	jal	800055d2 <panic>
    panic("virtio disk max queue too short");
    80004b88:	00003517          	auipc	a0,0x3
    80004b8c:	c2050513          	addi	a0,a0,-992 # 800077a8 <etext+0x7a8>
    80004b90:	243000ef          	jal	800055d2 <panic>
    panic("virtio disk kalloc");
    80004b94:	00003517          	auipc	a0,0x3
    80004b98:	c3450513          	addi	a0,a0,-972 # 800077c8 <etext+0x7c8>
    80004b9c:	237000ef          	jal	800055d2 <panic>

0000000080004ba0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80004ba0:	7159                	addi	sp,sp,-112
    80004ba2:	f486                	sd	ra,104(sp)
    80004ba4:	f0a2                	sd	s0,96(sp)
    80004ba6:	eca6                	sd	s1,88(sp)
    80004ba8:	e8ca                	sd	s2,80(sp)
    80004baa:	e4ce                	sd	s3,72(sp)
    80004bac:	e0d2                	sd	s4,64(sp)
    80004bae:	fc56                	sd	s5,56(sp)
    80004bb0:	f85a                	sd	s6,48(sp)
    80004bb2:	f45e                	sd	s7,40(sp)
    80004bb4:	f062                	sd	s8,32(sp)
    80004bb6:	ec66                	sd	s9,24(sp)
    80004bb8:	1880                	addi	s0,sp,112
    80004bba:	8a2a                	mv	s4,a0
    80004bbc:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80004bbe:	00c52c83          	lw	s9,12(a0)
    80004bc2:	001c9c9b          	slliw	s9,s9,0x1
    80004bc6:	1c82                	slli	s9,s9,0x20
    80004bc8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80004bcc:	00014517          	auipc	a0,0x14
    80004bd0:	36c50513          	addi	a0,a0,876 # 80018f38 <disk+0x128>
    80004bd4:	52d000ef          	jal	80005900 <acquire>
  for(int i = 0; i < 3; i++){
    80004bd8:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80004bda:	44a1                	li	s1,8
      disk.free[i] = 0;
    80004bdc:	00014b17          	auipc	s6,0x14
    80004be0:	234b0b13          	addi	s6,s6,564 # 80018e10 <disk>
  for(int i = 0; i < 3; i++){
    80004be4:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004be6:	00014c17          	auipc	s8,0x14
    80004bea:	352c0c13          	addi	s8,s8,850 # 80018f38 <disk+0x128>
    80004bee:	a8b9                	j	80004c4c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80004bf0:	00fb0733          	add	a4,s6,a5
    80004bf4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80004bf8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80004bfa:	0207c563          	bltz	a5,80004c24 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80004bfe:	2905                	addiw	s2,s2,1
    80004c00:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80004c02:	05590963          	beq	s2,s5,80004c54 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80004c06:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80004c08:	00014717          	auipc	a4,0x14
    80004c0c:	20870713          	addi	a4,a4,520 # 80018e10 <disk>
    80004c10:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80004c12:	01874683          	lbu	a3,24(a4)
    80004c16:	fee9                	bnez	a3,80004bf0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80004c18:	2785                	addiw	a5,a5,1
    80004c1a:	0705                	addi	a4,a4,1
    80004c1c:	fe979be3          	bne	a5,s1,80004c12 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80004c20:	57fd                	li	a5,-1
    80004c22:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80004c24:	01205d63          	blez	s2,80004c3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004c28:	f9042503          	lw	a0,-112(s0)
    80004c2c:	d07ff0ef          	jal	80004932 <free_desc>
      for(int j = 0; j < i; j++)
    80004c30:	4785                	li	a5,1
    80004c32:	0127d663          	bge	a5,s2,80004c3e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80004c36:	f9442503          	lw	a0,-108(s0)
    80004c3a:	cf9ff0ef          	jal	80004932 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80004c3e:	85e2                	mv	a1,s8
    80004c40:	00014517          	auipc	a0,0x14
    80004c44:	1e850513          	addi	a0,a0,488 # 80018e28 <disk+0x18>
    80004c48:	f26fc0ef          	jal	8000136e <sleep>
  for(int i = 0; i < 3; i++){
    80004c4c:	f9040613          	addi	a2,s0,-112
    80004c50:	894e                	mv	s2,s3
    80004c52:	bf55                	j	80004c06 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c54:	f9042503          	lw	a0,-112(s0)
    80004c58:	00451693          	slli	a3,a0,0x4

  if(write)
    80004c5c:	00014797          	auipc	a5,0x14
    80004c60:	1b478793          	addi	a5,a5,436 # 80018e10 <disk>
    80004c64:	00a50713          	addi	a4,a0,10
    80004c68:	0712                	slli	a4,a4,0x4
    80004c6a:	973e                	add	a4,a4,a5
    80004c6c:	01703633          	snez	a2,s7
    80004c70:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80004c72:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80004c76:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c7a:	6398                	ld	a4,0(a5)
    80004c7c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80004c7e:	0a868613          	addi	a2,a3,168
    80004c82:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80004c84:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80004c86:	6390                	ld	a2,0(a5)
    80004c88:	00d605b3          	add	a1,a2,a3
    80004c8c:	4741                	li	a4,16
    80004c8e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80004c90:	4805                	li	a6,1
    80004c92:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80004c96:	f9442703          	lw	a4,-108(s0)
    80004c9a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80004c9e:	0712                	slli	a4,a4,0x4
    80004ca0:	963a                	add	a2,a2,a4
    80004ca2:	058a0593          	addi	a1,s4,88
    80004ca6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80004ca8:	0007b883          	ld	a7,0(a5)
    80004cac:	9746                	add	a4,a4,a7
    80004cae:	40000613          	li	a2,1024
    80004cb2:	c710                	sw	a2,8(a4)
  if(write)
    80004cb4:	001bb613          	seqz	a2,s7
    80004cb8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80004cbc:	00166613          	ori	a2,a2,1
    80004cc0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80004cc4:	f9842583          	lw	a1,-104(s0)
    80004cc8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80004ccc:	00250613          	addi	a2,a0,2
    80004cd0:	0612                	slli	a2,a2,0x4
    80004cd2:	963e                	add	a2,a2,a5
    80004cd4:	577d                	li	a4,-1
    80004cd6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80004cda:	0592                	slli	a1,a1,0x4
    80004cdc:	98ae                	add	a7,a7,a1
    80004cde:	03068713          	addi	a4,a3,48
    80004ce2:	973e                	add	a4,a4,a5
    80004ce4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80004ce8:	6398                	ld	a4,0(a5)
    80004cea:	972e                	add	a4,a4,a1
    80004cec:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80004cf0:	4689                	li	a3,2
    80004cf2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80004cf6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80004cfa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80004cfe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80004d02:	6794                	ld	a3,8(a5)
    80004d04:	0026d703          	lhu	a4,2(a3)
    80004d08:	8b1d                	andi	a4,a4,7
    80004d0a:	0706                	slli	a4,a4,0x1
    80004d0c:	96ba                	add	a3,a3,a4
    80004d0e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80004d12:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80004d16:	6798                	ld	a4,8(a5)
    80004d18:	00275783          	lhu	a5,2(a4)
    80004d1c:	2785                	addiw	a5,a5,1
    80004d1e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80004d22:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80004d26:	100017b7          	lui	a5,0x10001
    80004d2a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80004d2e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80004d32:	00014917          	auipc	s2,0x14
    80004d36:	20690913          	addi	s2,s2,518 # 80018f38 <disk+0x128>
  while(b->disk == 1) {
    80004d3a:	4485                	li	s1,1
    80004d3c:	01079a63          	bne	a5,a6,80004d50 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80004d40:	85ca                	mv	a1,s2
    80004d42:	8552                	mv	a0,s4
    80004d44:	e2afc0ef          	jal	8000136e <sleep>
  while(b->disk == 1) {
    80004d48:	004a2783          	lw	a5,4(s4)
    80004d4c:	fe978ae3          	beq	a5,s1,80004d40 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80004d50:	f9042903          	lw	s2,-112(s0)
    80004d54:	00290713          	addi	a4,s2,2
    80004d58:	0712                	slli	a4,a4,0x4
    80004d5a:	00014797          	auipc	a5,0x14
    80004d5e:	0b678793          	addi	a5,a5,182 # 80018e10 <disk>
    80004d62:	97ba                	add	a5,a5,a4
    80004d64:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80004d68:	00014997          	auipc	s3,0x14
    80004d6c:	0a898993          	addi	s3,s3,168 # 80018e10 <disk>
    80004d70:	00491713          	slli	a4,s2,0x4
    80004d74:	0009b783          	ld	a5,0(s3)
    80004d78:	97ba                	add	a5,a5,a4
    80004d7a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80004d7e:	854a                	mv	a0,s2
    80004d80:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80004d84:	bafff0ef          	jal	80004932 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80004d88:	8885                	andi	s1,s1,1
    80004d8a:	f0fd                	bnez	s1,80004d70 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80004d8c:	00014517          	auipc	a0,0x14
    80004d90:	1ac50513          	addi	a0,a0,428 # 80018f38 <disk+0x128>
    80004d94:	405000ef          	jal	80005998 <release>
}
    80004d98:	70a6                	ld	ra,104(sp)
    80004d9a:	7406                	ld	s0,96(sp)
    80004d9c:	64e6                	ld	s1,88(sp)
    80004d9e:	6946                	ld	s2,80(sp)
    80004da0:	69a6                	ld	s3,72(sp)
    80004da2:	6a06                	ld	s4,64(sp)
    80004da4:	7ae2                	ld	s5,56(sp)
    80004da6:	7b42                	ld	s6,48(sp)
    80004da8:	7ba2                	ld	s7,40(sp)
    80004daa:	7c02                	ld	s8,32(sp)
    80004dac:	6ce2                	ld	s9,24(sp)
    80004dae:	6165                	addi	sp,sp,112
    80004db0:	8082                	ret

0000000080004db2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80004db2:	1101                	addi	sp,sp,-32
    80004db4:	ec06                	sd	ra,24(sp)
    80004db6:	e822                	sd	s0,16(sp)
    80004db8:	e426                	sd	s1,8(sp)
    80004dba:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80004dbc:	00014497          	auipc	s1,0x14
    80004dc0:	05448493          	addi	s1,s1,84 # 80018e10 <disk>
    80004dc4:	00014517          	auipc	a0,0x14
    80004dc8:	17450513          	addi	a0,a0,372 # 80018f38 <disk+0x128>
    80004dcc:	335000ef          	jal	80005900 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80004dd0:	100017b7          	lui	a5,0x10001
    80004dd4:	53b8                	lw	a4,96(a5)
    80004dd6:	8b0d                	andi	a4,a4,3
    80004dd8:	100017b7          	lui	a5,0x10001
    80004ddc:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80004dde:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80004de2:	689c                	ld	a5,16(s1)
    80004de4:	0204d703          	lhu	a4,32(s1)
    80004de8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80004dec:	04f70663          	beq	a4,a5,80004e38 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80004df0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80004df4:	6898                	ld	a4,16(s1)
    80004df6:	0204d783          	lhu	a5,32(s1)
    80004dfa:	8b9d                	andi	a5,a5,7
    80004dfc:	078e                	slli	a5,a5,0x3
    80004dfe:	97ba                	add	a5,a5,a4
    80004e00:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80004e02:	00278713          	addi	a4,a5,2
    80004e06:	0712                	slli	a4,a4,0x4
    80004e08:	9726                	add	a4,a4,s1
    80004e0a:	01074703          	lbu	a4,16(a4)
    80004e0e:	e321                	bnez	a4,80004e4e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80004e10:	0789                	addi	a5,a5,2
    80004e12:	0792                	slli	a5,a5,0x4
    80004e14:	97a6                	add	a5,a5,s1
    80004e16:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80004e18:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80004e1c:	d9efc0ef          	jal	800013ba <wakeup>

    disk.used_idx += 1;
    80004e20:	0204d783          	lhu	a5,32(s1)
    80004e24:	2785                	addiw	a5,a5,1
    80004e26:	17c2                	slli	a5,a5,0x30
    80004e28:	93c1                	srli	a5,a5,0x30
    80004e2a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80004e2e:	6898                	ld	a4,16(s1)
    80004e30:	00275703          	lhu	a4,2(a4)
    80004e34:	faf71ee3          	bne	a4,a5,80004df0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80004e38:	00014517          	auipc	a0,0x14
    80004e3c:	10050513          	addi	a0,a0,256 # 80018f38 <disk+0x128>
    80004e40:	359000ef          	jal	80005998 <release>
}
    80004e44:	60e2                	ld	ra,24(sp)
    80004e46:	6442                	ld	s0,16(sp)
    80004e48:	64a2                	ld	s1,8(sp)
    80004e4a:	6105                	addi	sp,sp,32
    80004e4c:	8082                	ret
      panic("virtio_disk_intr status");
    80004e4e:	00003517          	auipc	a0,0x3
    80004e52:	99250513          	addi	a0,a0,-1646 # 800077e0 <etext+0x7e0>
    80004e56:	77c000ef          	jal	800055d2 <panic>

0000000080004e5a <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    80004e5a:	1141                	addi	sp,sp,-16
    80004e5c:	e422                	sd	s0,8(sp)
    80004e5e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mie" : "=r" (x) );
    80004e60:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80004e64:	0207e793          	ori	a5,a5,32
  asm volatile("csrw mie, %0" : : "r" (x));
    80004e68:	30479073          	csrw	mie,a5
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80004e6c:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80004e70:	577d                	li	a4,-1
    80004e72:	177e                	slli	a4,a4,0x3f
    80004e74:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80004e76:	30a79073          	csrw	0x30a,a5
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    80004e7a:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80004e7e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80004e82:	30679073          	csrw	mcounteren,a5
  asm volatile("csrr %0, time" : "=r" (x) );
    80004e86:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80004e8a:	000f4737          	lui	a4,0xf4
    80004e8e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80004e92:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80004e94:	14d79073          	csrw	stimecmp,a5
}
    80004e98:	6422                	ld	s0,8(sp)
    80004e9a:	0141                	addi	sp,sp,16
    80004e9c:	8082                	ret

0000000080004e9e <start>:
{
    80004e9e:	1141                	addi	sp,sp,-16
    80004ea0:	e406                	sd	ra,8(sp)
    80004ea2:	e022                	sd	s0,0(sp)
    80004ea4:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80004ea6:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80004eaa:	7779                	lui	a4,0xffffe
    80004eac:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdd7af>
    80004eb0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80004eb2:	6705                	lui	a4,0x1
    80004eb4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80004eb8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80004eba:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80004ebe:	ffffb797          	auipc	a5,0xffffb
    80004ec2:	45278793          	addi	a5,a5,1106 # 80000310 <main>
    80004ec6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80004eca:	4781                	li	a5,0
    80004ecc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80004ed0:	67c1                	lui	a5,0x10
    80004ed2:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80004ed4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80004ed8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80004edc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80004ee0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80004ee4:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80004ee8:	57fd                	li	a5,-1
    80004eea:	83a9                	srli	a5,a5,0xa
    80004eec:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80004ef0:	47bd                	li	a5,15
    80004ef2:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80004ef6:	f65ff0ef          	jal	80004e5a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80004efa:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80004efe:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80004f00:	823e                	mv	tp,a5
  asm volatile("mret");
    80004f02:	30200073          	mret
}
    80004f06:	60a2                	ld	ra,8(sp)
    80004f08:	6402                	ld	s0,0(sp)
    80004f0a:	0141                	addi	sp,sp,16
    80004f0c:	8082                	ret

0000000080004f0e <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80004f0e:	715d                	addi	sp,sp,-80
    80004f10:	e486                	sd	ra,72(sp)
    80004f12:	e0a2                	sd	s0,64(sp)
    80004f14:	f84a                	sd	s2,48(sp)
    80004f16:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80004f18:	04c05263          	blez	a2,80004f5c <consolewrite+0x4e>
    80004f1c:	fc26                	sd	s1,56(sp)
    80004f1e:	f44e                	sd	s3,40(sp)
    80004f20:	f052                	sd	s4,32(sp)
    80004f22:	ec56                	sd	s5,24(sp)
    80004f24:	8a2a                	mv	s4,a0
    80004f26:	84ae                	mv	s1,a1
    80004f28:	89b2                	mv	s3,a2
    80004f2a:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80004f2c:	5afd                	li	s5,-1
    80004f2e:	4685                	li	a3,1
    80004f30:	8626                	mv	a2,s1
    80004f32:	85d2                	mv	a1,s4
    80004f34:	fbf40513          	addi	a0,s0,-65
    80004f38:	fdcfc0ef          	jal	80001714 <either_copyin>
    80004f3c:	03550263          	beq	a0,s5,80004f60 <consolewrite+0x52>
      break;
    uartputc(c);
    80004f40:	fbf44503          	lbu	a0,-65(s0)
    80004f44:	035000ef          	jal	80005778 <uartputc>
  for(i = 0; i < n; i++){
    80004f48:	2905                	addiw	s2,s2,1
    80004f4a:	0485                	addi	s1,s1,1
    80004f4c:	ff2991e3          	bne	s3,s2,80004f2e <consolewrite+0x20>
    80004f50:	894e                	mv	s2,s3
    80004f52:	74e2                	ld	s1,56(sp)
    80004f54:	79a2                	ld	s3,40(sp)
    80004f56:	7a02                	ld	s4,32(sp)
    80004f58:	6ae2                	ld	s5,24(sp)
    80004f5a:	a039                	j	80004f68 <consolewrite+0x5a>
    80004f5c:	4901                	li	s2,0
    80004f5e:	a029                	j	80004f68 <consolewrite+0x5a>
    80004f60:	74e2                	ld	s1,56(sp)
    80004f62:	79a2                	ld	s3,40(sp)
    80004f64:	7a02                	ld	s4,32(sp)
    80004f66:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    80004f68:	854a                	mv	a0,s2
    80004f6a:	60a6                	ld	ra,72(sp)
    80004f6c:	6406                	ld	s0,64(sp)
    80004f6e:	7942                	ld	s2,48(sp)
    80004f70:	6161                	addi	sp,sp,80
    80004f72:	8082                	ret

0000000080004f74 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80004f74:	711d                	addi	sp,sp,-96
    80004f76:	ec86                	sd	ra,88(sp)
    80004f78:	e8a2                	sd	s0,80(sp)
    80004f7a:	e4a6                	sd	s1,72(sp)
    80004f7c:	e0ca                	sd	s2,64(sp)
    80004f7e:	fc4e                	sd	s3,56(sp)
    80004f80:	f852                	sd	s4,48(sp)
    80004f82:	f456                	sd	s5,40(sp)
    80004f84:	f05a                	sd	s6,32(sp)
    80004f86:	1080                	addi	s0,sp,96
    80004f88:	8aaa                	mv	s5,a0
    80004f8a:	8a2e                	mv	s4,a1
    80004f8c:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80004f8e:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80004f92:	0001c517          	auipc	a0,0x1c
    80004f96:	fbe50513          	addi	a0,a0,-66 # 80020f50 <cons>
    80004f9a:	167000ef          	jal	80005900 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80004f9e:	0001c497          	auipc	s1,0x1c
    80004fa2:	fb248493          	addi	s1,s1,-78 # 80020f50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80004fa6:	0001c917          	auipc	s2,0x1c
    80004faa:	04290913          	addi	s2,s2,66 # 80020fe8 <cons+0x98>
  while(n > 0){
    80004fae:	0b305d63          	blez	s3,80005068 <consoleread+0xf4>
    while(cons.r == cons.w){
    80004fb2:	0984a783          	lw	a5,152(s1)
    80004fb6:	09c4a703          	lw	a4,156(s1)
    80004fba:	0af71263          	bne	a4,a5,8000505e <consoleread+0xea>
      if(killed(myproc())){
    80004fbe:	ddbfb0ef          	jal	80000d98 <myproc>
    80004fc2:	de4fc0ef          	jal	800015a6 <killed>
    80004fc6:	e12d                	bnez	a0,80005028 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    80004fc8:	85a6                	mv	a1,s1
    80004fca:	854a                	mv	a0,s2
    80004fcc:	ba2fc0ef          	jal	8000136e <sleep>
    while(cons.r == cons.w){
    80004fd0:	0984a783          	lw	a5,152(s1)
    80004fd4:	09c4a703          	lw	a4,156(s1)
    80004fd8:	fef703e3          	beq	a4,a5,80004fbe <consoleread+0x4a>
    80004fdc:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80004fde:	0001c717          	auipc	a4,0x1c
    80004fe2:	f7270713          	addi	a4,a4,-142 # 80020f50 <cons>
    80004fe6:	0017869b          	addiw	a3,a5,1
    80004fea:	08d72c23          	sw	a3,152(a4)
    80004fee:	07f7f693          	andi	a3,a5,127
    80004ff2:	9736                	add	a4,a4,a3
    80004ff4:	01874703          	lbu	a4,24(a4)
    80004ff8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    80004ffc:	4691                	li	a3,4
    80004ffe:	04db8663          	beq	s7,a3,8000504a <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80005002:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005006:	4685                	li	a3,1
    80005008:	faf40613          	addi	a2,s0,-81
    8000500c:	85d2                	mv	a1,s4
    8000500e:	8556                	mv	a0,s5
    80005010:	ebafc0ef          	jal	800016ca <either_copyout>
    80005014:	57fd                	li	a5,-1
    80005016:	04f50863          	beq	a0,a5,80005066 <consoleread+0xf2>
      break;

    dst++;
    8000501a:	0a05                	addi	s4,s4,1
    --n;
    8000501c:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    8000501e:	47a9                	li	a5,10
    80005020:	04fb8d63          	beq	s7,a5,8000507a <consoleread+0x106>
    80005024:	6be2                	ld	s7,24(sp)
    80005026:	b761                	j	80004fae <consoleread+0x3a>
        release(&cons.lock);
    80005028:	0001c517          	auipc	a0,0x1c
    8000502c:	f2850513          	addi	a0,a0,-216 # 80020f50 <cons>
    80005030:	169000ef          	jal	80005998 <release>
        return -1;
    80005034:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80005036:	60e6                	ld	ra,88(sp)
    80005038:	6446                	ld	s0,80(sp)
    8000503a:	64a6                	ld	s1,72(sp)
    8000503c:	6906                	ld	s2,64(sp)
    8000503e:	79e2                	ld	s3,56(sp)
    80005040:	7a42                	ld	s4,48(sp)
    80005042:	7aa2                	ld	s5,40(sp)
    80005044:	7b02                	ld	s6,32(sp)
    80005046:	6125                	addi	sp,sp,96
    80005048:	8082                	ret
      if(n < target){
    8000504a:	0009871b          	sext.w	a4,s3
    8000504e:	01677a63          	bgeu	a4,s6,80005062 <consoleread+0xee>
        cons.r--;
    80005052:	0001c717          	auipc	a4,0x1c
    80005056:	f8f72b23          	sw	a5,-106(a4) # 80020fe8 <cons+0x98>
    8000505a:	6be2                	ld	s7,24(sp)
    8000505c:	a031                	j	80005068 <consoleread+0xf4>
    8000505e:	ec5e                	sd	s7,24(sp)
    80005060:	bfbd                	j	80004fde <consoleread+0x6a>
    80005062:	6be2                	ld	s7,24(sp)
    80005064:	a011                	j	80005068 <consoleread+0xf4>
    80005066:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80005068:	0001c517          	auipc	a0,0x1c
    8000506c:	ee850513          	addi	a0,a0,-280 # 80020f50 <cons>
    80005070:	129000ef          	jal	80005998 <release>
  return target - n;
    80005074:	413b053b          	subw	a0,s6,s3
    80005078:	bf7d                	j	80005036 <consoleread+0xc2>
    8000507a:	6be2                	ld	s7,24(sp)
    8000507c:	b7f5                	j	80005068 <consoleread+0xf4>

000000008000507e <consputc>:
{
    8000507e:	1141                	addi	sp,sp,-16
    80005080:	e406                	sd	ra,8(sp)
    80005082:	e022                	sd	s0,0(sp)
    80005084:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005086:	10000793          	li	a5,256
    8000508a:	00f50863          	beq	a0,a5,8000509a <consputc+0x1c>
    uartputc_sync(c);
    8000508e:	604000ef          	jal	80005692 <uartputc_sync>
}
    80005092:	60a2                	ld	ra,8(sp)
    80005094:	6402                	ld	s0,0(sp)
    80005096:	0141                	addi	sp,sp,16
    80005098:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000509a:	4521                	li	a0,8
    8000509c:	5f6000ef          	jal	80005692 <uartputc_sync>
    800050a0:	02000513          	li	a0,32
    800050a4:	5ee000ef          	jal	80005692 <uartputc_sync>
    800050a8:	4521                	li	a0,8
    800050aa:	5e8000ef          	jal	80005692 <uartputc_sync>
    800050ae:	b7d5                	j	80005092 <consputc+0x14>

00000000800050b0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800050b0:	1101                	addi	sp,sp,-32
    800050b2:	ec06                	sd	ra,24(sp)
    800050b4:	e822                	sd	s0,16(sp)
    800050b6:	e426                	sd	s1,8(sp)
    800050b8:	1000                	addi	s0,sp,32
    800050ba:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800050bc:	0001c517          	auipc	a0,0x1c
    800050c0:	e9450513          	addi	a0,a0,-364 # 80020f50 <cons>
    800050c4:	03d000ef          	jal	80005900 <acquire>

  switch(c){
    800050c8:	47d5                	li	a5,21
    800050ca:	08f48f63          	beq	s1,a5,80005168 <consoleintr+0xb8>
    800050ce:	0297c563          	blt	a5,s1,800050f8 <consoleintr+0x48>
    800050d2:	47a1                	li	a5,8
    800050d4:	0ef48463          	beq	s1,a5,800051bc <consoleintr+0x10c>
    800050d8:	47c1                	li	a5,16
    800050da:	10f49563          	bne	s1,a5,800051e4 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800050de:	e80fc0ef          	jal	8000175e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800050e2:	0001c517          	auipc	a0,0x1c
    800050e6:	e6e50513          	addi	a0,a0,-402 # 80020f50 <cons>
    800050ea:	0af000ef          	jal	80005998 <release>
}
    800050ee:	60e2                	ld	ra,24(sp)
    800050f0:	6442                	ld	s0,16(sp)
    800050f2:	64a2                	ld	s1,8(sp)
    800050f4:	6105                	addi	sp,sp,32
    800050f6:	8082                	ret
  switch(c){
    800050f8:	07f00793          	li	a5,127
    800050fc:	0cf48063          	beq	s1,a5,800051bc <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005100:	0001c717          	auipc	a4,0x1c
    80005104:	e5070713          	addi	a4,a4,-432 # 80020f50 <cons>
    80005108:	0a072783          	lw	a5,160(a4)
    8000510c:	09872703          	lw	a4,152(a4)
    80005110:	9f99                	subw	a5,a5,a4
    80005112:	07f00713          	li	a4,127
    80005116:	fcf766e3          	bltu	a4,a5,800050e2 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    8000511a:	47b5                	li	a5,13
    8000511c:	0cf48763          	beq	s1,a5,800051ea <consoleintr+0x13a>
      consputc(c);
    80005120:	8526                	mv	a0,s1
    80005122:	f5dff0ef          	jal	8000507e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005126:	0001c797          	auipc	a5,0x1c
    8000512a:	e2a78793          	addi	a5,a5,-470 # 80020f50 <cons>
    8000512e:	0a07a683          	lw	a3,160(a5)
    80005132:	0016871b          	addiw	a4,a3,1
    80005136:	0007061b          	sext.w	a2,a4
    8000513a:	0ae7a023          	sw	a4,160(a5)
    8000513e:	07f6f693          	andi	a3,a3,127
    80005142:	97b6                	add	a5,a5,a3
    80005144:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005148:	47a9                	li	a5,10
    8000514a:	0cf48563          	beq	s1,a5,80005214 <consoleintr+0x164>
    8000514e:	4791                	li	a5,4
    80005150:	0cf48263          	beq	s1,a5,80005214 <consoleintr+0x164>
    80005154:	0001c797          	auipc	a5,0x1c
    80005158:	e947a783          	lw	a5,-364(a5) # 80020fe8 <cons+0x98>
    8000515c:	9f1d                	subw	a4,a4,a5
    8000515e:	08000793          	li	a5,128
    80005162:	f8f710e3          	bne	a4,a5,800050e2 <consoleintr+0x32>
    80005166:	a07d                	j	80005214 <consoleintr+0x164>
    80005168:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000516a:	0001c717          	auipc	a4,0x1c
    8000516e:	de670713          	addi	a4,a4,-538 # 80020f50 <cons>
    80005172:	0a072783          	lw	a5,160(a4)
    80005176:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000517a:	0001c497          	auipc	s1,0x1c
    8000517e:	dd648493          	addi	s1,s1,-554 # 80020f50 <cons>
    while(cons.e != cons.w &&
    80005182:	4929                	li	s2,10
    80005184:	02f70863          	beq	a4,a5,800051b4 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005188:	37fd                	addiw	a5,a5,-1
    8000518a:	07f7f713          	andi	a4,a5,127
    8000518e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005190:	01874703          	lbu	a4,24(a4)
    80005194:	03270263          	beq	a4,s2,800051b8 <consoleintr+0x108>
      cons.e--;
    80005198:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000519c:	10000513          	li	a0,256
    800051a0:	edfff0ef          	jal	8000507e <consputc>
    while(cons.e != cons.w &&
    800051a4:	0a04a783          	lw	a5,160(s1)
    800051a8:	09c4a703          	lw	a4,156(s1)
    800051ac:	fcf71ee3          	bne	a4,a5,80005188 <consoleintr+0xd8>
    800051b0:	6902                	ld	s2,0(sp)
    800051b2:	bf05                	j	800050e2 <consoleintr+0x32>
    800051b4:	6902                	ld	s2,0(sp)
    800051b6:	b735                	j	800050e2 <consoleintr+0x32>
    800051b8:	6902                	ld	s2,0(sp)
    800051ba:	b725                	j	800050e2 <consoleintr+0x32>
    if(cons.e != cons.w){
    800051bc:	0001c717          	auipc	a4,0x1c
    800051c0:	d9470713          	addi	a4,a4,-620 # 80020f50 <cons>
    800051c4:	0a072783          	lw	a5,160(a4)
    800051c8:	09c72703          	lw	a4,156(a4)
    800051cc:	f0f70be3          	beq	a4,a5,800050e2 <consoleintr+0x32>
      cons.e--;
    800051d0:	37fd                	addiw	a5,a5,-1
    800051d2:	0001c717          	auipc	a4,0x1c
    800051d6:	e0f72f23          	sw	a5,-482(a4) # 80020ff0 <cons+0xa0>
      consputc(BACKSPACE);
    800051da:	10000513          	li	a0,256
    800051de:	ea1ff0ef          	jal	8000507e <consputc>
    800051e2:	b701                	j	800050e2 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800051e4:	ee048fe3          	beqz	s1,800050e2 <consoleintr+0x32>
    800051e8:	bf21                	j	80005100 <consoleintr+0x50>
      consputc(c);
    800051ea:	4529                	li	a0,10
    800051ec:	e93ff0ef          	jal	8000507e <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800051f0:	0001c797          	auipc	a5,0x1c
    800051f4:	d6078793          	addi	a5,a5,-672 # 80020f50 <cons>
    800051f8:	0a07a703          	lw	a4,160(a5)
    800051fc:	0017069b          	addiw	a3,a4,1
    80005200:	0006861b          	sext.w	a2,a3
    80005204:	0ad7a023          	sw	a3,160(a5)
    80005208:	07f77713          	andi	a4,a4,127
    8000520c:	97ba                	add	a5,a5,a4
    8000520e:	4729                	li	a4,10
    80005210:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005214:	0001c797          	auipc	a5,0x1c
    80005218:	dcc7ac23          	sw	a2,-552(a5) # 80020fec <cons+0x9c>
        wakeup(&cons.r);
    8000521c:	0001c517          	auipc	a0,0x1c
    80005220:	dcc50513          	addi	a0,a0,-564 # 80020fe8 <cons+0x98>
    80005224:	996fc0ef          	jal	800013ba <wakeup>
    80005228:	bd6d                	j	800050e2 <consoleintr+0x32>

000000008000522a <consoleinit>:

void
consoleinit(void)
{
    8000522a:	1141                	addi	sp,sp,-16
    8000522c:	e406                	sd	ra,8(sp)
    8000522e:	e022                	sd	s0,0(sp)
    80005230:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005232:	00002597          	auipc	a1,0x2
    80005236:	5c658593          	addi	a1,a1,1478 # 800077f8 <etext+0x7f8>
    8000523a:	0001c517          	auipc	a0,0x1c
    8000523e:	d1650513          	addi	a0,a0,-746 # 80020f50 <cons>
    80005242:	63e000ef          	jal	80005880 <initlock>

  uartinit();
    80005246:	3f4000ef          	jal	8000563a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000524a:	00013797          	auipc	a5,0x13
    8000524e:	b6e78793          	addi	a5,a5,-1170 # 80017db8 <devsw>
    80005252:	00000717          	auipc	a4,0x0
    80005256:	d2270713          	addi	a4,a4,-734 # 80004f74 <consoleread>
    8000525a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000525c:	00000717          	auipc	a4,0x0
    80005260:	cb270713          	addi	a4,a4,-846 # 80004f0e <consolewrite>
    80005264:	ef98                	sd	a4,24(a5)
}
    80005266:	60a2                	ld	ra,8(sp)
    80005268:	6402                	ld	s0,0(sp)
    8000526a:	0141                	addi	sp,sp,16
    8000526c:	8082                	ret

000000008000526e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000526e:	7179                	addi	sp,sp,-48
    80005270:	f406                	sd	ra,40(sp)
    80005272:	f022                	sd	s0,32(sp)
    80005274:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80005276:	c219                	beqz	a2,8000527c <printint+0xe>
    80005278:	08054063          	bltz	a0,800052f8 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000527c:	4881                	li	a7,0
    8000527e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005282:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80005284:	00002617          	auipc	a2,0x2
    80005288:	7fc60613          	addi	a2,a2,2044 # 80007a80 <digits>
    8000528c:	883e                	mv	a6,a5
    8000528e:	2785                	addiw	a5,a5,1
    80005290:	02b57733          	remu	a4,a0,a1
    80005294:	9732                	add	a4,a4,a2
    80005296:	00074703          	lbu	a4,0(a4)
    8000529a:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    8000529e:	872a                	mv	a4,a0
    800052a0:	02b55533          	divu	a0,a0,a1
    800052a4:	0685                	addi	a3,a3,1
    800052a6:	feb773e3          	bgeu	a4,a1,8000528c <printint+0x1e>

  if(sign)
    800052aa:	00088a63          	beqz	a7,800052be <printint+0x50>
    buf[i++] = '-';
    800052ae:	1781                	addi	a5,a5,-32
    800052b0:	97a2                	add	a5,a5,s0
    800052b2:	02d00713          	li	a4,45
    800052b6:	fee78823          	sb	a4,-16(a5)
    800052ba:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800052be:	02f05963          	blez	a5,800052f0 <printint+0x82>
    800052c2:	ec26                	sd	s1,24(sp)
    800052c4:	e84a                	sd	s2,16(sp)
    800052c6:	fd040713          	addi	a4,s0,-48
    800052ca:	00f704b3          	add	s1,a4,a5
    800052ce:	fff70913          	addi	s2,a4,-1
    800052d2:	993e                	add	s2,s2,a5
    800052d4:	37fd                	addiw	a5,a5,-1
    800052d6:	1782                	slli	a5,a5,0x20
    800052d8:	9381                	srli	a5,a5,0x20
    800052da:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800052de:	fff4c503          	lbu	a0,-1(s1)
    800052e2:	d9dff0ef          	jal	8000507e <consputc>
  while(--i >= 0)
    800052e6:	14fd                	addi	s1,s1,-1
    800052e8:	ff249be3          	bne	s1,s2,800052de <printint+0x70>
    800052ec:	64e2                	ld	s1,24(sp)
    800052ee:	6942                	ld	s2,16(sp)
}
    800052f0:	70a2                	ld	ra,40(sp)
    800052f2:	7402                	ld	s0,32(sp)
    800052f4:	6145                	addi	sp,sp,48
    800052f6:	8082                	ret
    x = -xx;
    800052f8:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800052fc:	4885                	li	a7,1
    x = -xx;
    800052fe:	b741                	j	8000527e <printint+0x10>

0000000080005300 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    80005300:	7155                	addi	sp,sp,-208
    80005302:	e506                	sd	ra,136(sp)
    80005304:	e122                	sd	s0,128(sp)
    80005306:	f0d2                	sd	s4,96(sp)
    80005308:	0900                	addi	s0,sp,144
    8000530a:	8a2a                	mv	s4,a0
    8000530c:	e40c                	sd	a1,8(s0)
    8000530e:	e810                	sd	a2,16(s0)
    80005310:	ec14                	sd	a3,24(s0)
    80005312:	f018                	sd	a4,32(s0)
    80005314:	f41c                	sd	a5,40(s0)
    80005316:	03043823          	sd	a6,48(s0)
    8000531a:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    8000531e:	0001c797          	auipc	a5,0x1c
    80005322:	cf27a783          	lw	a5,-782(a5) # 80021010 <pr+0x18>
    80005326:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    8000532a:	e3a1                	bnez	a5,8000536a <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    8000532c:	00840793          	addi	a5,s0,8
    80005330:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80005334:	00054503          	lbu	a0,0(a0)
    80005338:	26050763          	beqz	a0,800055a6 <printf+0x2a6>
    8000533c:	fca6                	sd	s1,120(sp)
    8000533e:	f8ca                	sd	s2,112(sp)
    80005340:	f4ce                	sd	s3,104(sp)
    80005342:	ecd6                	sd	s5,88(sp)
    80005344:	e8da                	sd	s6,80(sp)
    80005346:	e0e2                	sd	s8,64(sp)
    80005348:	fc66                	sd	s9,56(sp)
    8000534a:	f86a                	sd	s10,48(sp)
    8000534c:	f46e                	sd	s11,40(sp)
    8000534e:	4981                	li	s3,0
    if(cx != '%'){
    80005350:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80005354:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80005358:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000535c:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80005360:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80005364:	07000d93          	li	s11,112
    80005368:	a815                	j	8000539c <printf+0x9c>
    acquire(&pr.lock);
    8000536a:	0001c517          	auipc	a0,0x1c
    8000536e:	c8e50513          	addi	a0,a0,-882 # 80020ff8 <pr>
    80005372:	58e000ef          	jal	80005900 <acquire>
  va_start(ap, fmt);
    80005376:	00840793          	addi	a5,s0,8
    8000537a:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000537e:	000a4503          	lbu	a0,0(s4)
    80005382:	fd4d                	bnez	a0,8000533c <printf+0x3c>
    80005384:	a481                	j	800055c4 <printf+0x2c4>
      consputc(cx);
    80005386:	cf9ff0ef          	jal	8000507e <consputc>
      continue;
    8000538a:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000538c:	0014899b          	addiw	s3,s1,1
    80005390:	013a07b3          	add	a5,s4,s3
    80005394:	0007c503          	lbu	a0,0(a5)
    80005398:	1e050b63          	beqz	a0,8000558e <printf+0x28e>
    if(cx != '%'){
    8000539c:	ff5515e3          	bne	a0,s5,80005386 <printf+0x86>
    i++;
    800053a0:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    800053a4:	009a07b3          	add	a5,s4,s1
    800053a8:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800053ac:	1e090163          	beqz	s2,8000558e <printf+0x28e>
    800053b0:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800053b4:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800053b6:	c789                	beqz	a5,800053c0 <printf+0xc0>
    800053b8:	009a0733          	add	a4,s4,s1
    800053bc:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800053c0:	03690763          	beq	s2,s6,800053ee <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    800053c4:	05890163          	beq	s2,s8,80005406 <printf+0x106>
    } else if(c0 == 'u'){
    800053c8:	0d990b63          	beq	s2,s9,8000549e <printf+0x19e>
    } else if(c0 == 'x'){
    800053cc:	13a90163          	beq	s2,s10,800054ee <printf+0x1ee>
    } else if(c0 == 'p'){
    800053d0:	13b90b63          	beq	s2,s11,80005506 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    800053d4:	07300793          	li	a5,115
    800053d8:	16f90a63          	beq	s2,a5,8000554c <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800053dc:	1b590463          	beq	s2,s5,80005584 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800053e0:	8556                	mv	a0,s5
    800053e2:	c9dff0ef          	jal	8000507e <consputc>
      consputc(c0);
    800053e6:	854a                	mv	a0,s2
    800053e8:	c97ff0ef          	jal	8000507e <consputc>
    800053ec:	b745                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800053ee:	f8843783          	ld	a5,-120(s0)
    800053f2:	00878713          	addi	a4,a5,8
    800053f6:	f8e43423          	sd	a4,-120(s0)
    800053fa:	4605                	li	a2,1
    800053fc:	45a9                	li	a1,10
    800053fe:	4388                	lw	a0,0(a5)
    80005400:	e6fff0ef          	jal	8000526e <printint>
    80005404:	b761                	j	8000538c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    80005406:	03678663          	beq	a5,s6,80005432 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000540a:	05878263          	beq	a5,s8,8000544e <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    8000540e:	0b978463          	beq	a5,s9,800054b6 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    80005412:	fda797e3          	bne	a5,s10,800053e0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005416:	f8843783          	ld	a5,-120(s0)
    8000541a:	00878713          	addi	a4,a5,8
    8000541e:	f8e43423          	sd	a4,-120(s0)
    80005422:	4601                	li	a2,0
    80005424:	45c1                	li	a1,16
    80005426:	6388                	ld	a0,0(a5)
    80005428:	e47ff0ef          	jal	8000526e <printint>
      i += 1;
    8000542c:	0029849b          	addiw	s1,s3,2
    80005430:	bfb1                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005432:	f8843783          	ld	a5,-120(s0)
    80005436:	00878713          	addi	a4,a5,8
    8000543a:	f8e43423          	sd	a4,-120(s0)
    8000543e:	4605                	li	a2,1
    80005440:	45a9                	li	a1,10
    80005442:	6388                	ld	a0,0(a5)
    80005444:	e2bff0ef          	jal	8000526e <printint>
      i += 1;
    80005448:	0029849b          	addiw	s1,s3,2
    8000544c:	b781                	j	8000538c <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000544e:	06400793          	li	a5,100
    80005452:	02f68863          	beq	a3,a5,80005482 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80005456:	07500793          	li	a5,117
    8000545a:	06f68c63          	beq	a3,a5,800054d2 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000545e:	07800793          	li	a5,120
    80005462:	f6f69fe3          	bne	a3,a5,800053e0 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80005466:	f8843783          	ld	a5,-120(s0)
    8000546a:	00878713          	addi	a4,a5,8
    8000546e:	f8e43423          	sd	a4,-120(s0)
    80005472:	4601                	li	a2,0
    80005474:	45c1                	li	a1,16
    80005476:	6388                	ld	a0,0(a5)
    80005478:	df7ff0ef          	jal	8000526e <printint>
      i += 2;
    8000547c:	0039849b          	addiw	s1,s3,3
    80005480:	b731                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80005482:	f8843783          	ld	a5,-120(s0)
    80005486:	00878713          	addi	a4,a5,8
    8000548a:	f8e43423          	sd	a4,-120(s0)
    8000548e:	4605                	li	a2,1
    80005490:	45a9                	li	a1,10
    80005492:	6388                	ld	a0,0(a5)
    80005494:	ddbff0ef          	jal	8000526e <printint>
      i += 2;
    80005498:	0039849b          	addiw	s1,s3,3
    8000549c:	bdc5                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    8000549e:	f8843783          	ld	a5,-120(s0)
    800054a2:	00878713          	addi	a4,a5,8
    800054a6:	f8e43423          	sd	a4,-120(s0)
    800054aa:	4601                	li	a2,0
    800054ac:	45a9                	li	a1,10
    800054ae:	4388                	lw	a0,0(a5)
    800054b0:	dbfff0ef          	jal	8000526e <printint>
    800054b4:	bde1                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800054b6:	f8843783          	ld	a5,-120(s0)
    800054ba:	00878713          	addi	a4,a5,8
    800054be:	f8e43423          	sd	a4,-120(s0)
    800054c2:	4601                	li	a2,0
    800054c4:	45a9                	li	a1,10
    800054c6:	6388                	ld	a0,0(a5)
    800054c8:	da7ff0ef          	jal	8000526e <printint>
      i += 1;
    800054cc:	0029849b          	addiw	s1,s3,2
    800054d0:	bd75                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    800054d2:	f8843783          	ld	a5,-120(s0)
    800054d6:	00878713          	addi	a4,a5,8
    800054da:	f8e43423          	sd	a4,-120(s0)
    800054de:	4601                	li	a2,0
    800054e0:	45a9                	li	a1,10
    800054e2:	6388                	ld	a0,0(a5)
    800054e4:	d8bff0ef          	jal	8000526e <printint>
      i += 2;
    800054e8:	0039849b          	addiw	s1,s3,3
    800054ec:	b545                	j	8000538c <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800054ee:	f8843783          	ld	a5,-120(s0)
    800054f2:	00878713          	addi	a4,a5,8
    800054f6:	f8e43423          	sd	a4,-120(s0)
    800054fa:	4601                	li	a2,0
    800054fc:	45c1                	li	a1,16
    800054fe:	4388                	lw	a0,0(a5)
    80005500:	d6fff0ef          	jal	8000526e <printint>
    80005504:	b561                	j	8000538c <printf+0x8c>
    80005506:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    80005508:	f8843783          	ld	a5,-120(s0)
    8000550c:	00878713          	addi	a4,a5,8
    80005510:	f8e43423          	sd	a4,-120(s0)
    80005514:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80005518:	03000513          	li	a0,48
    8000551c:	b63ff0ef          	jal	8000507e <consputc>
  consputc('x');
    80005520:	07800513          	li	a0,120
    80005524:	b5bff0ef          	jal	8000507e <consputc>
    80005528:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000552a:	00002b97          	auipc	s7,0x2
    8000552e:	556b8b93          	addi	s7,s7,1366 # 80007a80 <digits>
    80005532:	03c9d793          	srli	a5,s3,0x3c
    80005536:	97de                	add	a5,a5,s7
    80005538:	0007c503          	lbu	a0,0(a5)
    8000553c:	b43ff0ef          	jal	8000507e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005540:	0992                	slli	s3,s3,0x4
    80005542:	397d                	addiw	s2,s2,-1
    80005544:	fe0917e3          	bnez	s2,80005532 <printf+0x232>
    80005548:	6ba6                	ld	s7,72(sp)
    8000554a:	b589                	j	8000538c <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000554c:	f8843783          	ld	a5,-120(s0)
    80005550:	00878713          	addi	a4,a5,8
    80005554:	f8e43423          	sd	a4,-120(s0)
    80005558:	0007b903          	ld	s2,0(a5)
    8000555c:	00090d63          	beqz	s2,80005576 <printf+0x276>
      for(; *s; s++)
    80005560:	00094503          	lbu	a0,0(s2)
    80005564:	e20504e3          	beqz	a0,8000538c <printf+0x8c>
        consputc(*s);
    80005568:	b17ff0ef          	jal	8000507e <consputc>
      for(; *s; s++)
    8000556c:	0905                	addi	s2,s2,1
    8000556e:	00094503          	lbu	a0,0(s2)
    80005572:	f97d                	bnez	a0,80005568 <printf+0x268>
    80005574:	bd21                	j	8000538c <printf+0x8c>
        s = "(null)";
    80005576:	00002917          	auipc	s2,0x2
    8000557a:	28a90913          	addi	s2,s2,650 # 80007800 <etext+0x800>
      for(; *s; s++)
    8000557e:	02800513          	li	a0,40
    80005582:	b7dd                	j	80005568 <printf+0x268>
      consputc('%');
    80005584:	02500513          	li	a0,37
    80005588:	af7ff0ef          	jal	8000507e <consputc>
    8000558c:	b501                	j	8000538c <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    8000558e:	f7843783          	ld	a5,-136(s0)
    80005592:	e385                	bnez	a5,800055b2 <printf+0x2b2>
    80005594:	74e6                	ld	s1,120(sp)
    80005596:	7946                	ld	s2,112(sp)
    80005598:	79a6                	ld	s3,104(sp)
    8000559a:	6ae6                	ld	s5,88(sp)
    8000559c:	6b46                	ld	s6,80(sp)
    8000559e:	6c06                	ld	s8,64(sp)
    800055a0:	7ce2                	ld	s9,56(sp)
    800055a2:	7d42                	ld	s10,48(sp)
    800055a4:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    800055a6:	4501                	li	a0,0
    800055a8:	60aa                	ld	ra,136(sp)
    800055aa:	640a                	ld	s0,128(sp)
    800055ac:	7a06                	ld	s4,96(sp)
    800055ae:	6169                	addi	sp,sp,208
    800055b0:	8082                	ret
    800055b2:	74e6                	ld	s1,120(sp)
    800055b4:	7946                	ld	s2,112(sp)
    800055b6:	79a6                	ld	s3,104(sp)
    800055b8:	6ae6                	ld	s5,88(sp)
    800055ba:	6b46                	ld	s6,80(sp)
    800055bc:	6c06                	ld	s8,64(sp)
    800055be:	7ce2                	ld	s9,56(sp)
    800055c0:	7d42                	ld	s10,48(sp)
    800055c2:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    800055c4:	0001c517          	auipc	a0,0x1c
    800055c8:	a3450513          	addi	a0,a0,-1484 # 80020ff8 <pr>
    800055cc:	3cc000ef          	jal	80005998 <release>
    800055d0:	bfd9                	j	800055a6 <printf+0x2a6>

00000000800055d2 <panic>:

void
panic(char *s)
{
    800055d2:	1101                	addi	sp,sp,-32
    800055d4:	ec06                	sd	ra,24(sp)
    800055d6:	e822                	sd	s0,16(sp)
    800055d8:	e426                	sd	s1,8(sp)
    800055da:	1000                	addi	s0,sp,32
    800055dc:	84aa                	mv	s1,a0
  pr.locking = 0;
    800055de:	0001c797          	auipc	a5,0x1c
    800055e2:	a207a923          	sw	zero,-1486(a5) # 80021010 <pr+0x18>
  printf("panic: ");
    800055e6:	00002517          	auipc	a0,0x2
    800055ea:	22250513          	addi	a0,a0,546 # 80007808 <etext+0x808>
    800055ee:	d13ff0ef          	jal	80005300 <printf>
  printf("%s\n", s);
    800055f2:	85a6                	mv	a1,s1
    800055f4:	00002517          	auipc	a0,0x2
    800055f8:	21c50513          	addi	a0,a0,540 # 80007810 <etext+0x810>
    800055fc:	d05ff0ef          	jal	80005300 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005600:	4785                	li	a5,1
    80005602:	00002717          	auipc	a4,0x2
    80005606:	50f72523          	sw	a5,1290(a4) # 80007b0c <panicked>
  for(;;)
    8000560a:	a001                	j	8000560a <panic+0x38>

000000008000560c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000560c:	1101                	addi	sp,sp,-32
    8000560e:	ec06                	sd	ra,24(sp)
    80005610:	e822                	sd	s0,16(sp)
    80005612:	e426                	sd	s1,8(sp)
    80005614:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005616:	0001c497          	auipc	s1,0x1c
    8000561a:	9e248493          	addi	s1,s1,-1566 # 80020ff8 <pr>
    8000561e:	00002597          	auipc	a1,0x2
    80005622:	1fa58593          	addi	a1,a1,506 # 80007818 <etext+0x818>
    80005626:	8526                	mv	a0,s1
    80005628:	258000ef          	jal	80005880 <initlock>
  pr.locking = 1;
    8000562c:	4785                	li	a5,1
    8000562e:	cc9c                	sw	a5,24(s1)
}
    80005630:	60e2                	ld	ra,24(sp)
    80005632:	6442                	ld	s0,16(sp)
    80005634:	64a2                	ld	s1,8(sp)
    80005636:	6105                	addi	sp,sp,32
    80005638:	8082                	ret

000000008000563a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000563a:	1141                	addi	sp,sp,-16
    8000563c:	e406                	sd	ra,8(sp)
    8000563e:	e022                	sd	s0,0(sp)
    80005640:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005642:	100007b7          	lui	a5,0x10000
    80005646:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000564a:	10000737          	lui	a4,0x10000
    8000564e:	f8000693          	li	a3,-128
    80005652:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005656:	468d                	li	a3,3
    80005658:	10000637          	lui	a2,0x10000
    8000565c:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005660:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005664:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005668:	10000737          	lui	a4,0x10000
    8000566c:	461d                	li	a2,7
    8000566e:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005672:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005676:	00002597          	auipc	a1,0x2
    8000567a:	1aa58593          	addi	a1,a1,426 # 80007820 <etext+0x820>
    8000567e:	0001c517          	auipc	a0,0x1c
    80005682:	99a50513          	addi	a0,a0,-1638 # 80021018 <uart_tx_lock>
    80005686:	1fa000ef          	jal	80005880 <initlock>
}
    8000568a:	60a2                	ld	ra,8(sp)
    8000568c:	6402                	ld	s0,0(sp)
    8000568e:	0141                	addi	sp,sp,16
    80005690:	8082                	ret

0000000080005692 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005692:	1101                	addi	sp,sp,-32
    80005694:	ec06                	sd	ra,24(sp)
    80005696:	e822                	sd	s0,16(sp)
    80005698:	e426                	sd	s1,8(sp)
    8000569a:	1000                	addi	s0,sp,32
    8000569c:	84aa                	mv	s1,a0
  push_off();
    8000569e:	222000ef          	jal	800058c0 <push_off>

  if(panicked){
    800056a2:	00002797          	auipc	a5,0x2
    800056a6:	46a7a783          	lw	a5,1130(a5) # 80007b0c <panicked>
    800056aa:	e795                	bnez	a5,800056d6 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800056ac:	10000737          	lui	a4,0x10000
    800056b0:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800056b2:	00074783          	lbu	a5,0(a4)
    800056b6:	0207f793          	andi	a5,a5,32
    800056ba:	dfe5                	beqz	a5,800056b2 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    800056bc:	0ff4f513          	zext.b	a0,s1
    800056c0:	100007b7          	lui	a5,0x10000
    800056c4:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    800056c8:	27c000ef          	jal	80005944 <pop_off>
}
    800056cc:	60e2                	ld	ra,24(sp)
    800056ce:	6442                	ld	s0,16(sp)
    800056d0:	64a2                	ld	s1,8(sp)
    800056d2:	6105                	addi	sp,sp,32
    800056d4:	8082                	ret
    for(;;)
    800056d6:	a001                	j	800056d6 <uartputc_sync+0x44>

00000000800056d8 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    800056d8:	00002797          	auipc	a5,0x2
    800056dc:	4387b783          	ld	a5,1080(a5) # 80007b10 <uart_tx_r>
    800056e0:	00002717          	auipc	a4,0x2
    800056e4:	43873703          	ld	a4,1080(a4) # 80007b18 <uart_tx_w>
    800056e8:	08f70263          	beq	a4,a5,8000576c <uartstart+0x94>
{
    800056ec:	7139                	addi	sp,sp,-64
    800056ee:	fc06                	sd	ra,56(sp)
    800056f0:	f822                	sd	s0,48(sp)
    800056f2:	f426                	sd	s1,40(sp)
    800056f4:	f04a                	sd	s2,32(sp)
    800056f6:	ec4e                	sd	s3,24(sp)
    800056f8:	e852                	sd	s4,16(sp)
    800056fa:	e456                	sd	s5,8(sp)
    800056fc:	e05a                	sd	s6,0(sp)
    800056fe:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005700:	10000937          	lui	s2,0x10000
    80005704:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005706:	0001ca97          	auipc	s5,0x1c
    8000570a:	912a8a93          	addi	s5,s5,-1774 # 80021018 <uart_tx_lock>
    uart_tx_r += 1;
    8000570e:	00002497          	auipc	s1,0x2
    80005712:	40248493          	addi	s1,s1,1026 # 80007b10 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    80005716:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    8000571a:	00002997          	auipc	s3,0x2
    8000571e:	3fe98993          	addi	s3,s3,1022 # 80007b18 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005722:	00094703          	lbu	a4,0(s2)
    80005726:	02077713          	andi	a4,a4,32
    8000572a:	c71d                	beqz	a4,80005758 <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000572c:	01f7f713          	andi	a4,a5,31
    80005730:	9756                	add	a4,a4,s5
    80005732:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    80005736:	0785                	addi	a5,a5,1
    80005738:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    8000573a:	8526                	mv	a0,s1
    8000573c:	c7ffb0ef          	jal	800013ba <wakeup>
    WriteReg(THR, c);
    80005740:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80005744:	609c                	ld	a5,0(s1)
    80005746:	0009b703          	ld	a4,0(s3)
    8000574a:	fcf71ce3          	bne	a4,a5,80005722 <uartstart+0x4a>
      ReadReg(ISR);
    8000574e:	100007b7          	lui	a5,0x10000
    80005752:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005754:	0007c783          	lbu	a5,0(a5)
  }
}
    80005758:	70e2                	ld	ra,56(sp)
    8000575a:	7442                	ld	s0,48(sp)
    8000575c:	74a2                	ld	s1,40(sp)
    8000575e:	7902                	ld	s2,32(sp)
    80005760:	69e2                	ld	s3,24(sp)
    80005762:	6a42                	ld	s4,16(sp)
    80005764:	6aa2                	ld	s5,8(sp)
    80005766:	6b02                	ld	s6,0(sp)
    80005768:	6121                	addi	sp,sp,64
    8000576a:	8082                	ret
      ReadReg(ISR);
    8000576c:	100007b7          	lui	a5,0x10000
    80005770:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80005772:	0007c783          	lbu	a5,0(a5)
      return;
    80005776:	8082                	ret

0000000080005778 <uartputc>:
{
    80005778:	7179                	addi	sp,sp,-48
    8000577a:	f406                	sd	ra,40(sp)
    8000577c:	f022                	sd	s0,32(sp)
    8000577e:	ec26                	sd	s1,24(sp)
    80005780:	e84a                	sd	s2,16(sp)
    80005782:	e44e                	sd	s3,8(sp)
    80005784:	e052                	sd	s4,0(sp)
    80005786:	1800                	addi	s0,sp,48
    80005788:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000578a:	0001c517          	auipc	a0,0x1c
    8000578e:	88e50513          	addi	a0,a0,-1906 # 80021018 <uart_tx_lock>
    80005792:	16e000ef          	jal	80005900 <acquire>
  if(panicked){
    80005796:	00002797          	auipc	a5,0x2
    8000579a:	3767a783          	lw	a5,886(a5) # 80007b0c <panicked>
    8000579e:	efbd                	bnez	a5,8000581c <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057a0:	00002717          	auipc	a4,0x2
    800057a4:	37873703          	ld	a4,888(a4) # 80007b18 <uart_tx_w>
    800057a8:	00002797          	auipc	a5,0x2
    800057ac:	3687b783          	ld	a5,872(a5) # 80007b10 <uart_tx_r>
    800057b0:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800057b4:	0001c997          	auipc	s3,0x1c
    800057b8:	86498993          	addi	s3,s3,-1948 # 80021018 <uart_tx_lock>
    800057bc:	00002497          	auipc	s1,0x2
    800057c0:	35448493          	addi	s1,s1,852 # 80007b10 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057c4:	00002917          	auipc	s2,0x2
    800057c8:	35490913          	addi	s2,s2,852 # 80007b18 <uart_tx_w>
    800057cc:	00e79d63          	bne	a5,a4,800057e6 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    800057d0:	85ce                	mv	a1,s3
    800057d2:	8526                	mv	a0,s1
    800057d4:	b9bfb0ef          	jal	8000136e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800057d8:	00093703          	ld	a4,0(s2)
    800057dc:	609c                	ld	a5,0(s1)
    800057de:	02078793          	addi	a5,a5,32
    800057e2:	fee787e3          	beq	a5,a4,800057d0 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800057e6:	0001c497          	auipc	s1,0x1c
    800057ea:	83248493          	addi	s1,s1,-1998 # 80021018 <uart_tx_lock>
    800057ee:	01f77793          	andi	a5,a4,31
    800057f2:	97a6                	add	a5,a5,s1
    800057f4:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800057f8:	0705                	addi	a4,a4,1
    800057fa:	00002797          	auipc	a5,0x2
    800057fe:	30e7bf23          	sd	a4,798(a5) # 80007b18 <uart_tx_w>
  uartstart();
    80005802:	ed7ff0ef          	jal	800056d8 <uartstart>
  release(&uart_tx_lock);
    80005806:	8526                	mv	a0,s1
    80005808:	190000ef          	jal	80005998 <release>
}
    8000580c:	70a2                	ld	ra,40(sp)
    8000580e:	7402                	ld	s0,32(sp)
    80005810:	64e2                	ld	s1,24(sp)
    80005812:	6942                	ld	s2,16(sp)
    80005814:	69a2                	ld	s3,8(sp)
    80005816:	6a02                	ld	s4,0(sp)
    80005818:	6145                	addi	sp,sp,48
    8000581a:	8082                	ret
    for(;;)
    8000581c:	a001                	j	8000581c <uartputc+0xa4>

000000008000581e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000581e:	1141                	addi	sp,sp,-16
    80005820:	e422                	sd	s0,8(sp)
    80005822:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80005824:	100007b7          	lui	a5,0x10000
    80005828:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    8000582a:	0007c783          	lbu	a5,0(a5)
    8000582e:	8b85                	andi	a5,a5,1
    80005830:	cb81                	beqz	a5,80005840 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    80005832:	100007b7          	lui	a5,0x10000
    80005836:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000583a:	6422                	ld	s0,8(sp)
    8000583c:	0141                	addi	sp,sp,16
    8000583e:	8082                	ret
    return -1;
    80005840:	557d                	li	a0,-1
    80005842:	bfe5                	j	8000583a <uartgetc+0x1c>

0000000080005844 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80005844:	1101                	addi	sp,sp,-32
    80005846:	ec06                	sd	ra,24(sp)
    80005848:	e822                	sd	s0,16(sp)
    8000584a:	e426                	sd	s1,8(sp)
    8000584c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000584e:	54fd                	li	s1,-1
    80005850:	a019                	j	80005856 <uartintr+0x12>
      break;
    consoleintr(c);
    80005852:	85fff0ef          	jal	800050b0 <consoleintr>
    int c = uartgetc();
    80005856:	fc9ff0ef          	jal	8000581e <uartgetc>
    if(c == -1)
    8000585a:	fe951ce3          	bne	a0,s1,80005852 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000585e:	0001b497          	auipc	s1,0x1b
    80005862:	7ba48493          	addi	s1,s1,1978 # 80021018 <uart_tx_lock>
    80005866:	8526                	mv	a0,s1
    80005868:	098000ef          	jal	80005900 <acquire>
  uartstart();
    8000586c:	e6dff0ef          	jal	800056d8 <uartstart>
  release(&uart_tx_lock);
    80005870:	8526                	mv	a0,s1
    80005872:	126000ef          	jal	80005998 <release>
}
    80005876:	60e2                	ld	ra,24(sp)
    80005878:	6442                	ld	s0,16(sp)
    8000587a:	64a2                	ld	s1,8(sp)
    8000587c:	6105                	addi	sp,sp,32
    8000587e:	8082                	ret

0000000080005880 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80005880:	1141                	addi	sp,sp,-16
    80005882:	e422                	sd	s0,8(sp)
    80005884:	0800                	addi	s0,sp,16
  lk->name = name;
    80005886:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80005888:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    8000588c:	00053823          	sd	zero,16(a0)
}
    80005890:	6422                	ld	s0,8(sp)
    80005892:	0141                	addi	sp,sp,16
    80005894:	8082                	ret

0000000080005896 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80005896:	411c                	lw	a5,0(a0)
    80005898:	e399                	bnez	a5,8000589e <holding+0x8>
    8000589a:	4501                	li	a0,0
  return r;
}
    8000589c:	8082                	ret
{
    8000589e:	1101                	addi	sp,sp,-32
    800058a0:	ec06                	sd	ra,24(sp)
    800058a2:	e822                	sd	s0,16(sp)
    800058a4:	e426                	sd	s1,8(sp)
    800058a6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800058a8:	6904                	ld	s1,16(a0)
    800058aa:	cd2fb0ef          	jal	80000d7c <mycpu>
    800058ae:	40a48533          	sub	a0,s1,a0
    800058b2:	00153513          	seqz	a0,a0
}
    800058b6:	60e2                	ld	ra,24(sp)
    800058b8:	6442                	ld	s0,16(sp)
    800058ba:	64a2                	ld	s1,8(sp)
    800058bc:	6105                	addi	sp,sp,32
    800058be:	8082                	ret

00000000800058c0 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800058c0:	1101                	addi	sp,sp,-32
    800058c2:	ec06                	sd	ra,24(sp)
    800058c4:	e822                	sd	s0,16(sp)
    800058c6:	e426                	sd	s1,8(sp)
    800058c8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800058ca:	100024f3          	csrr	s1,sstatus
    800058ce:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800058d2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800058d4:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800058d8:	ca4fb0ef          	jal	80000d7c <mycpu>
    800058dc:	5d3c                	lw	a5,120(a0)
    800058de:	cb99                	beqz	a5,800058f4 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800058e0:	c9cfb0ef          	jal	80000d7c <mycpu>
    800058e4:	5d3c                	lw	a5,120(a0)
    800058e6:	2785                	addiw	a5,a5,1
    800058e8:	dd3c                	sw	a5,120(a0)
}
    800058ea:	60e2                	ld	ra,24(sp)
    800058ec:	6442                	ld	s0,16(sp)
    800058ee:	64a2                	ld	s1,8(sp)
    800058f0:	6105                	addi	sp,sp,32
    800058f2:	8082                	ret
    mycpu()->intena = old;
    800058f4:	c88fb0ef          	jal	80000d7c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800058f8:	8085                	srli	s1,s1,0x1
    800058fa:	8885                	andi	s1,s1,1
    800058fc:	dd64                	sw	s1,124(a0)
    800058fe:	b7cd                	j	800058e0 <push_off+0x20>

0000000080005900 <acquire>:
{
    80005900:	1101                	addi	sp,sp,-32
    80005902:	ec06                	sd	ra,24(sp)
    80005904:	e822                	sd	s0,16(sp)
    80005906:	e426                	sd	s1,8(sp)
    80005908:	1000                	addi	s0,sp,32
    8000590a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    8000590c:	fb5ff0ef          	jal	800058c0 <push_off>
  if(holding(lk))
    80005910:	8526                	mv	a0,s1
    80005912:	f85ff0ef          	jal	80005896 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80005916:	4705                	li	a4,1
  if(holding(lk))
    80005918:	e105                	bnez	a0,80005938 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    8000591a:	87ba                	mv	a5,a4
    8000591c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80005920:	2781                	sext.w	a5,a5
    80005922:	ffe5                	bnez	a5,8000591a <acquire+0x1a>
  __sync_synchronize();
    80005924:	0ff0000f          	fence
  lk->cpu = mycpu();
    80005928:	c54fb0ef          	jal	80000d7c <mycpu>
    8000592c:	e888                	sd	a0,16(s1)
}
    8000592e:	60e2                	ld	ra,24(sp)
    80005930:	6442                	ld	s0,16(sp)
    80005932:	64a2                	ld	s1,8(sp)
    80005934:	6105                	addi	sp,sp,32
    80005936:	8082                	ret
    panic("acquire");
    80005938:	00002517          	auipc	a0,0x2
    8000593c:	ef050513          	addi	a0,a0,-272 # 80007828 <etext+0x828>
    80005940:	c93ff0ef          	jal	800055d2 <panic>

0000000080005944 <pop_off>:

void
pop_off(void)
{
    80005944:	1141                	addi	sp,sp,-16
    80005946:	e406                	sd	ra,8(sp)
    80005948:	e022                	sd	s0,0(sp)
    8000594a:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    8000594c:	c30fb0ef          	jal	80000d7c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80005950:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80005954:	8b89                	andi	a5,a5,2
  if(intr_get())
    80005956:	e78d                	bnez	a5,80005980 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80005958:	5d3c                	lw	a5,120(a0)
    8000595a:	02f05963          	blez	a5,8000598c <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    8000595e:	37fd                	addiw	a5,a5,-1
    80005960:	0007871b          	sext.w	a4,a5
    80005964:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80005966:	eb09                	bnez	a4,80005978 <pop_off+0x34>
    80005968:	5d7c                	lw	a5,124(a0)
    8000596a:	c799                	beqz	a5,80005978 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000596c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80005970:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80005974:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80005978:	60a2                	ld	ra,8(sp)
    8000597a:	6402                	ld	s0,0(sp)
    8000597c:	0141                	addi	sp,sp,16
    8000597e:	8082                	ret
    panic("pop_off - interruptible");
    80005980:	00002517          	auipc	a0,0x2
    80005984:	eb050513          	addi	a0,a0,-336 # 80007830 <etext+0x830>
    80005988:	c4bff0ef          	jal	800055d2 <panic>
    panic("pop_off");
    8000598c:	00002517          	auipc	a0,0x2
    80005990:	ebc50513          	addi	a0,a0,-324 # 80007848 <etext+0x848>
    80005994:	c3fff0ef          	jal	800055d2 <panic>

0000000080005998 <release>:
{
    80005998:	1101                	addi	sp,sp,-32
    8000599a:	ec06                	sd	ra,24(sp)
    8000599c:	e822                	sd	s0,16(sp)
    8000599e:	e426                	sd	s1,8(sp)
    800059a0:	1000                	addi	s0,sp,32
    800059a2:	84aa                	mv	s1,a0
  if(!holding(lk))
    800059a4:	ef3ff0ef          	jal	80005896 <holding>
    800059a8:	c105                	beqz	a0,800059c8 <release+0x30>
  lk->cpu = 0;
    800059aa:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800059ae:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800059b2:	0f50000f          	fence	iorw,ow
    800059b6:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800059ba:	f8bff0ef          	jal	80005944 <pop_off>
}
    800059be:	60e2                	ld	ra,24(sp)
    800059c0:	6442                	ld	s0,16(sp)
    800059c2:	64a2                	ld	s1,8(sp)
    800059c4:	6105                	addi	sp,sp,32
    800059c6:	8082                	ret
    panic("release");
    800059c8:	00002517          	auipc	a0,0x2
    800059cc:	e8850513          	addi	a0,a0,-376 # 80007850 <etext+0x850>
    800059d0:	c03ff0ef          	jal	800055d2 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
