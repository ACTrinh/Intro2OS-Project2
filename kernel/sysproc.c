#include "types.h"
#include "riscv.h"
#include "param.h"
#include "defs.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  exit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return fork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return wait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int n;

  argint(0, &n);
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
  return addr;
}

uint64
sys_sleep(void)
{
  int n;
  uint ticks0;


  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

#ifdef LAB_PGTBL
int sys_pgaccess(void)
{
    uint64 first_page_va;
    int n_of_pages_to_check;
    uint64 output_va;
    uint64 output_bitmask = 0;

    argaddr(0, &first_page_va);
    argint(1, &n_of_pages_to_check);
    argaddr(2, &output_va);

    struct proc *current_process = myproc();

    for (int i = 0; i < n_of_pages_to_check; i++) {
        uint64 page_va = first_page_va + i * PGSIZE;
        pte_t *page_table_entry = walk(current_process->pagetable, page_va, 0);

        if ((*page_table_entry & PTE_A) != 0) {
            output_bitmask |= (1 << i);
            *page_table_entry = (*page_table_entry) & (~PTE_A);
        }
    }

    copyout(current_process->pagetable, output_va, (char *)&output_bitmask, sizeof(output_bitmask));

    return 0;
}
uint64
sys_pgpte(void)
{
  uint64 va;
  argaddr(0, &va);

  pte_t *pte = pgpte(myproc()->pagetable, va);
  if (pte == 0)
    return 0;

  return *pte;
}

uint64
sys_kpgtbl(void)
{
  vmprint(kernel_pagetable);
  return 0;
}
#endif


uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}
