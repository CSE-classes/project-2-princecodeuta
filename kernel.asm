
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 60 51 11 80       	mov    $0x80115160,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 b9 38 10 80       	mov    $0x801038b9,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 74 87 10 80       	push   $0x80108774
80100042:	68 c0 b5 10 80       	push   $0x8010b5c0
80100047:	e8 1b 50 00 00       	call   80105067 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 d0 f4 10 80 c4 	movl   $0x8010f4c4,0x8010f4d0
80100056:	f4 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 d4 f4 10 80 c4 	movl   $0x8010f4c4,0x8010f4d4
80100060:	f4 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 f4 b5 10 80 	movl   $0x8010b5f4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 d4 f4 10 80    	mov    0x8010f4d4,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c c4 f4 10 80 	movl   $0x8010f4c4,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 d4 f4 10 80       	mov    0x8010f4d4,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 d4 f4 10 80       	mov    %eax,0x8010f4d4
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 c4 f4 10 80       	mov    $0x8010f4c4,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
  }
}
801000b0:	90                   	nop
801000b1:	90                   	nop
801000b2:	c9                   	leave  
801000b3:	c3                   	ret    

801000b4 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000ba:	83 ec 0c             	sub    $0xc,%esp
801000bd:	68 c0 b5 10 80       	push   $0x8010b5c0
801000c2:	e8 c2 4f 00 00       	call   80105089 <acquire>
801000c7:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ca:	a1 d4 f4 10 80       	mov    0x8010f4d4,%eax
801000cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d2:	eb 67                	jmp    8010013b <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d7:	8b 40 04             	mov    0x4(%eax),%eax
801000da:	39 45 08             	cmp    %eax,0x8(%ebp)
801000dd:	75 53                	jne    80100132 <bget+0x7e>
801000df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e2:	8b 40 08             	mov    0x8(%eax),%eax
801000e5:	39 45 0c             	cmp    %eax,0xc(%ebp)
801000e8:	75 48                	jne    80100132 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ed:	8b 00                	mov    (%eax),%eax
801000ef:	83 e0 01             	and    $0x1,%eax
801000f2:	85 c0                	test   %eax,%eax
801000f4:	75 27                	jne    8010011d <bget+0x69>
        b->flags |= B_BUSY;
801000f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f9:	8b 00                	mov    (%eax),%eax
801000fb:	83 c8 01             	or     $0x1,%eax
801000fe:	89 c2                	mov    %eax,%edx
80100100:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100103:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100105:	83 ec 0c             	sub    $0xc,%esp
80100108:	68 c0 b5 10 80       	push   $0x8010b5c0
8010010d:	e8 de 4f 00 00       	call   801050f0 <release>
80100112:	83 c4 10             	add    $0x10,%esp
        return b;
80100115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100118:	e9 98 00 00 00       	jmp    801001b5 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011d:	83 ec 08             	sub    $0x8,%esp
80100120:	68 c0 b5 10 80       	push   $0x8010b5c0
80100125:	ff 75 f4             	push   -0xc(%ebp)
80100128:	e8 61 4c 00 00       	call   80104d8e <sleep>
8010012d:	83 c4 10             	add    $0x10,%esp
      goto loop;
80100130:	eb 98                	jmp    801000ca <bget+0x16>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	8b 40 10             	mov    0x10(%eax),%eax
80100138:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013b:	81 7d f4 c4 f4 10 80 	cmpl   $0x8010f4c4,-0xc(%ebp)
80100142:	75 90                	jne    801000d4 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100144:	a1 d0 f4 10 80       	mov    0x8010f4d0,%eax
80100149:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014c:	eb 51                	jmp    8010019f <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100151:	8b 00                	mov    (%eax),%eax
80100153:	83 e0 01             	and    $0x1,%eax
80100156:	85 c0                	test   %eax,%eax
80100158:	75 3c                	jne    80100196 <bget+0xe2>
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 00                	mov    (%eax),%eax
8010015f:	83 e0 04             	and    $0x4,%eax
80100162:	85 c0                	test   %eax,%eax
80100164:	75 30                	jne    80100196 <bget+0xe2>
      b->dev = dev;
80100166:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100169:	8b 55 08             	mov    0x8(%ebp),%edx
8010016c:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100172:	8b 55 0c             	mov    0xc(%ebp),%edx
80100175:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100178:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100181:	83 ec 0c             	sub    $0xc,%esp
80100184:	68 c0 b5 10 80       	push   $0x8010b5c0
80100189:	e8 62 4f 00 00       	call   801050f0 <release>
8010018e:	83 c4 10             	add    $0x10,%esp
      return b;
80100191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100194:	eb 1f                	jmp    801001b5 <bget+0x101>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100196:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100199:	8b 40 0c             	mov    0xc(%eax),%eax
8010019c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019f:	81 7d f4 c4 f4 10 80 	cmpl   $0x8010f4c4,-0xc(%ebp)
801001a6:	75 a6                	jne    8010014e <bget+0x9a>
    }
  }
  panic("bget: no buffers");
801001a8:	83 ec 0c             	sub    $0xc,%esp
801001ab:	68 7b 87 10 80       	push   $0x8010877b
801001b0:	e8 c6 03 00 00       	call   8010057b <panic>
}
801001b5:	c9                   	leave  
801001b6:	c3                   	ret    

801001b7 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b7:	55                   	push   %ebp
801001b8:	89 e5                	mov    %esp,%ebp
801001ba:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bd:	83 ec 08             	sub    $0x8,%esp
801001c0:	ff 75 0c             	push   0xc(%ebp)
801001c3:	ff 75 08             	push   0x8(%ebp)
801001c6:	e8 e9 fe ff ff       	call   801000b4 <bget>
801001cb:	83 c4 10             	add    $0x10,%esp
801001ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d4:	8b 00                	mov    (%eax),%eax
801001d6:	83 e0 02             	and    $0x2,%eax
801001d9:	85 c0                	test   %eax,%eax
801001db:	75 0e                	jne    801001eb <bread+0x34>
    iderw(b);
801001dd:	83 ec 0c             	sub    $0xc,%esp
801001e0:	ff 75 f4             	push   -0xc(%ebp)
801001e3:	e8 37 27 00 00       	call   8010291f <iderw>
801001e8:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ee:	c9                   	leave  
801001ef:	c3                   	ret    

801001f0 <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f6:	8b 45 08             	mov    0x8(%ebp),%eax
801001f9:	8b 00                	mov    (%eax),%eax
801001fb:	83 e0 01             	and    $0x1,%eax
801001fe:	85 c0                	test   %eax,%eax
80100200:	75 0d                	jne    8010020f <bwrite+0x1f>
    panic("bwrite");
80100202:	83 ec 0c             	sub    $0xc,%esp
80100205:	68 8c 87 10 80       	push   $0x8010878c
8010020a:	e8 6c 03 00 00       	call   8010057b <panic>
  b->flags |= B_DIRTY;
8010020f:	8b 45 08             	mov    0x8(%ebp),%eax
80100212:	8b 00                	mov    (%eax),%eax
80100214:	83 c8 04             	or     $0x4,%eax
80100217:	89 c2                	mov    %eax,%edx
80100219:	8b 45 08             	mov    0x8(%ebp),%eax
8010021c:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021e:	83 ec 0c             	sub    $0xc,%esp
80100221:	ff 75 08             	push   0x8(%ebp)
80100224:	e8 f6 26 00 00       	call   8010291f <iderw>
80100229:	83 c4 10             	add    $0x10,%esp
}
8010022c:	90                   	nop
8010022d:	c9                   	leave  
8010022e:	c3                   	ret    

8010022f <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022f:	55                   	push   %ebp
80100230:	89 e5                	mov    %esp,%ebp
80100232:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100235:	8b 45 08             	mov    0x8(%ebp),%eax
80100238:	8b 00                	mov    (%eax),%eax
8010023a:	83 e0 01             	and    $0x1,%eax
8010023d:	85 c0                	test   %eax,%eax
8010023f:	75 0d                	jne    8010024e <brelse+0x1f>
    panic("brelse");
80100241:	83 ec 0c             	sub    $0xc,%esp
80100244:	68 93 87 10 80       	push   $0x80108793
80100249:	e8 2d 03 00 00       	call   8010057b <panic>

  acquire(&bcache.lock);
8010024e:	83 ec 0c             	sub    $0xc,%esp
80100251:	68 c0 b5 10 80       	push   $0x8010b5c0
80100256:	e8 2e 4e 00 00       	call   80105089 <acquire>
8010025b:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025e:	8b 45 08             	mov    0x8(%ebp),%eax
80100261:	8b 40 10             	mov    0x10(%eax),%eax
80100264:	8b 55 08             	mov    0x8(%ebp),%edx
80100267:	8b 52 0c             	mov    0xc(%edx),%edx
8010026a:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	8b 40 0c             	mov    0xc(%eax),%eax
80100273:	8b 55 08             	mov    0x8(%ebp),%edx
80100276:	8b 52 10             	mov    0x10(%edx),%edx
80100279:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027c:	8b 15 d4 f4 10 80    	mov    0x8010f4d4,%edx
80100282:	8b 45 08             	mov    0x8(%ebp),%eax
80100285:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100288:	8b 45 08             	mov    0x8(%ebp),%eax
8010028b:	c7 40 0c c4 f4 10 80 	movl   $0x8010f4c4,0xc(%eax)
  bcache.head.next->prev = b;
80100292:	a1 d4 f4 10 80       	mov    0x8010f4d4,%eax
80100297:	8b 55 08             	mov    0x8(%ebp),%edx
8010029a:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029d:	8b 45 08             	mov    0x8(%ebp),%eax
801002a0:	a3 d4 f4 10 80       	mov    %eax,0x8010f4d4

  b->flags &= ~B_BUSY;
801002a5:	8b 45 08             	mov    0x8(%ebp),%eax
801002a8:	8b 00                	mov    (%eax),%eax
801002aa:	83 e0 fe             	and    $0xfffffffe,%eax
801002ad:	89 c2                	mov    %eax,%edx
801002af:	8b 45 08             	mov    0x8(%ebp),%eax
801002b2:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b4:	83 ec 0c             	sub    $0xc,%esp
801002b7:	ff 75 08             	push   0x8(%ebp)
801002ba:	e8 bb 4b 00 00       	call   80104e7a <wakeup>
801002bf:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c2:	83 ec 0c             	sub    $0xc,%esp
801002c5:	68 c0 b5 10 80       	push   $0x8010b5c0
801002ca:	e8 21 4e 00 00       	call   801050f0 <release>
801002cf:	83 c4 10             	add    $0x10,%esp
}
801002d2:	90                   	nop
801002d3:	c9                   	leave  
801002d4:	c3                   	ret    

801002d5 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d5:	55                   	push   %ebp
801002d6:	89 e5                	mov    %esp,%ebp
801002d8:	83 ec 14             	sub    $0x14,%esp
801002db:	8b 45 08             	mov    0x8(%ebp),%eax
801002de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e6:	89 c2                	mov    %eax,%edx
801002e8:	ec                   	in     (%dx),%al
801002e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002f0:	c9                   	leave  
801002f1:	c3                   	ret    

801002f2 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f2:	55                   	push   %ebp
801002f3:	89 e5                	mov    %esp,%ebp
801002f5:	83 ec 08             	sub    $0x8,%esp
801002f8:	8b 45 08             	mov    0x8(%ebp),%eax
801002fb:	8b 55 0c             	mov    0xc(%ebp),%edx
801002fe:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100302:	89 d0                	mov    %edx,%eax
80100304:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100307:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010030b:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030f:	ee                   	out    %al,(%dx)
}
80100310:	90                   	nop
80100311:	c9                   	leave  
80100312:	c3                   	ret    

80100313 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100313:	55                   	push   %ebp
80100314:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100316:	fa                   	cli    
}
80100317:	90                   	nop
80100318:	5d                   	pop    %ebp
80100319:	c3                   	ret    

8010031a <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
8010031a:	55                   	push   %ebp
8010031b:	89 e5                	mov    %esp,%ebp
8010031d:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100320:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100324:	74 1c                	je     80100342 <printint+0x28>
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	c1 e8 1f             	shr    $0x1f,%eax
8010032c:	0f b6 c0             	movzbl %al,%eax
8010032f:	89 45 10             	mov    %eax,0x10(%ebp)
80100332:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100336:	74 0a                	je     80100342 <printint+0x28>
    x = -xx;
80100338:	8b 45 08             	mov    0x8(%ebp),%eax
8010033b:	f7 d8                	neg    %eax
8010033d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100340:	eb 06                	jmp    80100348 <printint+0x2e>
  else
    x = xx;
80100342:	8b 45 08             	mov    0x8(%ebp),%eax
80100345:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100348:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100352:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100355:	ba 00 00 00 00       	mov    $0x0,%edx
8010035a:	f7 f1                	div    %ecx
8010035c:	89 d1                	mov    %edx,%ecx
8010035e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100361:	8d 50 01             	lea    0x1(%eax),%edx
80100364:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100367:	0f b6 91 04 90 10 80 	movzbl -0x7fef6ffc(%ecx),%edx
8010036e:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
80100372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100375:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100378:	ba 00 00 00 00       	mov    $0x0,%edx
8010037d:	f7 f1                	div    %ecx
8010037f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100382:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100386:	75 c7                	jne    8010034f <printint+0x35>

  if(sign)
80100388:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038c:	74 2a                	je     801003b8 <printint+0x9e>
    buf[i++] = '-';
8010038e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100391:	8d 50 01             	lea    0x1(%eax),%edx
80100394:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100397:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039c:	eb 1a                	jmp    801003b8 <printint+0x9e>
    consputc(buf[i]);
8010039e:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a4:	01 d0                	add    %edx,%eax
801003a6:	0f b6 00             	movzbl (%eax),%eax
801003a9:	0f be c0             	movsbl %al,%eax
801003ac:	83 ec 0c             	sub    $0xc,%esp
801003af:	50                   	push   %eax
801003b0:	e8 00 04 00 00       	call   801007b5 <consputc>
801003b5:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003b8:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003c0:	79 dc                	jns    8010039e <printint+0x84>
}
801003c2:	90                   	nop
801003c3:	90                   	nop
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 b4 f7 10 80       	mov    0x8010f7b4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 80 f7 10 80       	push   $0x8010f780
801003e2:	e8 a2 4c 00 00       	call   80105089 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 9a 87 10 80       	push   $0x8010879a
801003f9:	e8 7d 01 00 00       	call   8010057b <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 2f 01 00 00       	jmp    8010053f <cprintf+0x179>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	push   -0x1c(%ebp)
8010041c:	e8 94 03 00 00       	call   801007b5 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 12 01 00 00       	jmp    8010053b <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 14 01 00 00    	je     80100561 <cprintf+0x19b>
      break;
    switch(c){
8010044d:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100451:	74 5e                	je     801004b1 <cprintf+0xeb>
80100453:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100457:	0f 8f c2 00 00 00    	jg     8010051f <cprintf+0x159>
8010045d:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100461:	74 6b                	je     801004ce <cprintf+0x108>
80100463:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100467:	0f 8f b2 00 00 00    	jg     8010051f <cprintf+0x159>
8010046d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100471:	74 3e                	je     801004b1 <cprintf+0xeb>
80100473:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
80100477:	0f 8f a2 00 00 00    	jg     8010051f <cprintf+0x159>
8010047d:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100481:	0f 84 89 00 00 00    	je     80100510 <cprintf+0x14a>
80100487:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
8010048b:	0f 85 8e 00 00 00    	jne    8010051f <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
80100491:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100494:	8d 50 04             	lea    0x4(%eax),%edx
80100497:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049a:	8b 00                	mov    (%eax),%eax
8010049c:	83 ec 04             	sub    $0x4,%esp
8010049f:	6a 01                	push   $0x1
801004a1:	6a 0a                	push   $0xa
801004a3:	50                   	push   %eax
801004a4:	e8 71 fe ff ff       	call   8010031a <printint>
801004a9:	83 c4 10             	add    $0x10,%esp
      break;
801004ac:	e9 8a 00 00 00       	jmp    8010053b <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004b4:	8d 50 04             	lea    0x4(%eax),%edx
801004b7:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004ba:	8b 00                	mov    (%eax),%eax
801004bc:	83 ec 04             	sub    $0x4,%esp
801004bf:	6a 00                	push   $0x0
801004c1:	6a 10                	push   $0x10
801004c3:	50                   	push   %eax
801004c4:	e8 51 fe ff ff       	call   8010031a <printint>
801004c9:	83 c4 10             	add    $0x10,%esp
      break;
801004cc:	eb 6d                	jmp    8010053b <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004d1:	8d 50 04             	lea    0x4(%eax),%edx
801004d4:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004d7:	8b 00                	mov    (%eax),%eax
801004d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004dc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004e0:	75 22                	jne    80100504 <cprintf+0x13e>
        s = "(null)";
801004e2:	c7 45 ec a3 87 10 80 	movl   $0x801087a3,-0x14(%ebp)
      for(; *s; s++)
801004e9:	eb 19                	jmp    80100504 <cprintf+0x13e>
        consputc(*s);
801004eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004ee:	0f b6 00             	movzbl (%eax),%eax
801004f1:	0f be c0             	movsbl %al,%eax
801004f4:	83 ec 0c             	sub    $0xc,%esp
801004f7:	50                   	push   %eax
801004f8:	e8 b8 02 00 00       	call   801007b5 <consputc>
801004fd:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
80100500:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100504:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100507:	0f b6 00             	movzbl (%eax),%eax
8010050a:	84 c0                	test   %al,%al
8010050c:	75 dd                	jne    801004eb <cprintf+0x125>
      break;
8010050e:	eb 2b                	jmp    8010053b <cprintf+0x175>
    case '%':
      consputc('%');
80100510:	83 ec 0c             	sub    $0xc,%esp
80100513:	6a 25                	push   $0x25
80100515:	e8 9b 02 00 00       	call   801007b5 <consputc>
8010051a:	83 c4 10             	add    $0x10,%esp
      break;
8010051d:	eb 1c                	jmp    8010053b <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010051f:	83 ec 0c             	sub    $0xc,%esp
80100522:	6a 25                	push   $0x25
80100524:	e8 8c 02 00 00       	call   801007b5 <consputc>
80100529:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010052c:	83 ec 0c             	sub    $0xc,%esp
8010052f:	ff 75 e4             	push   -0x1c(%ebp)
80100532:	e8 7e 02 00 00       	call   801007b5 <consputc>
80100537:	83 c4 10             	add    $0x10,%esp
      break;
8010053a:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010053b:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010053f:	8b 55 08             	mov    0x8(%ebp),%edx
80100542:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100545:	01 d0                	add    %edx,%eax
80100547:	0f b6 00             	movzbl (%eax),%eax
8010054a:	0f be c0             	movsbl %al,%eax
8010054d:	25 ff 00 00 00       	and    $0xff,%eax
80100552:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100555:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100559:	0f 85 b1 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010055f:	eb 01                	jmp    80100562 <cprintf+0x19c>
      break;
80100561:	90                   	nop
    }
  }

  if(locking)
80100562:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100566:	74 10                	je     80100578 <cprintf+0x1b2>
    release(&cons.lock);
80100568:	83 ec 0c             	sub    $0xc,%esp
8010056b:	68 80 f7 10 80       	push   $0x8010f780
80100570:	e8 7b 4b 00 00       	call   801050f0 <release>
80100575:	83 c4 10             	add    $0x10,%esp
}
80100578:	90                   	nop
80100579:	c9                   	leave  
8010057a:	c3                   	ret    

8010057b <panic>:

void
panic(char *s)
{
8010057b:	55                   	push   %ebp
8010057c:	89 e5                	mov    %esp,%ebp
8010057e:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
80100581:	e8 8d fd ff ff       	call   80100313 <cli>
  cons.locking = 0;
80100586:	c7 05 b4 f7 10 80 00 	movl   $0x0,0x8010f7b4
8010058d:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
80100590:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100596:	0f b6 00             	movzbl (%eax),%eax
80100599:	0f b6 c0             	movzbl %al,%eax
8010059c:	83 ec 08             	sub    $0x8,%esp
8010059f:	50                   	push   %eax
801005a0:	68 aa 87 10 80       	push   $0x801087aa
801005a5:	e8 1c fe ff ff       	call   801003c6 <cprintf>
801005aa:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005ad:	8b 45 08             	mov    0x8(%ebp),%eax
801005b0:	83 ec 0c             	sub    $0xc,%esp
801005b3:	50                   	push   %eax
801005b4:	e8 0d fe ff ff       	call   801003c6 <cprintf>
801005b9:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005bc:	83 ec 0c             	sub    $0xc,%esp
801005bf:	68 b9 87 10 80       	push   $0x801087b9
801005c4:	e8 fd fd ff ff       	call   801003c6 <cprintf>
801005c9:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005cc:	83 ec 08             	sub    $0x8,%esp
801005cf:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005d2:	50                   	push   %eax
801005d3:	8d 45 08             	lea    0x8(%ebp),%eax
801005d6:	50                   	push   %eax
801005d7:	e8 66 4b 00 00       	call   80105142 <getcallerpcs>
801005dc:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005df:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005e6:	eb 1c                	jmp    80100604 <panic+0x89>
    cprintf(" %p", pcs[i]);
801005e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005eb:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005ef:	83 ec 08             	sub    $0x8,%esp
801005f2:	50                   	push   %eax
801005f3:	68 bb 87 10 80       	push   $0x801087bb
801005f8:	e8 c9 fd ff ff       	call   801003c6 <cprintf>
801005fd:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100600:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100604:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80100608:	7e de                	jle    801005e8 <panic+0x6d>
  panicked = 1; // freeze other CPU
8010060a:	c7 05 6c f7 10 80 01 	movl   $0x1,0x8010f76c
80100611:	00 00 00 
  for(;;)
80100614:	eb fe                	jmp    80100614 <panic+0x99>

80100616 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100616:	55                   	push   %ebp
80100617:	89 e5                	mov    %esp,%ebp
80100619:	53                   	push   %ebx
8010061a:	83 ec 14             	sub    $0x14,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
8010061d:	6a 0e                	push   $0xe
8010061f:	68 d4 03 00 00       	push   $0x3d4
80100624:	e8 c9 fc ff ff       	call   801002f2 <outb>
80100629:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
8010062c:	68 d5 03 00 00       	push   $0x3d5
80100631:	e8 9f fc ff ff       	call   801002d5 <inb>
80100636:	83 c4 04             	add    $0x4,%esp
80100639:	0f b6 c0             	movzbl %al,%eax
8010063c:	c1 e0 08             	shl    $0x8,%eax
8010063f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
80100642:	6a 0f                	push   $0xf
80100644:	68 d4 03 00 00       	push   $0x3d4
80100649:	e8 a4 fc ff ff       	call   801002f2 <outb>
8010064e:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
80100651:	68 d5 03 00 00       	push   $0x3d5
80100656:	e8 7a fc ff ff       	call   801002d5 <inb>
8010065b:	83 c4 04             	add    $0x4,%esp
8010065e:	0f b6 c0             	movzbl %al,%eax
80100661:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100664:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100668:	75 34                	jne    8010069e <cgaputc+0x88>
    pos += 80 - pos%80;
8010066a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010066d:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100672:	89 c8                	mov    %ecx,%eax
80100674:	f7 ea                	imul   %edx
80100676:	89 d0                	mov    %edx,%eax
80100678:	c1 f8 05             	sar    $0x5,%eax
8010067b:	89 cb                	mov    %ecx,%ebx
8010067d:	c1 fb 1f             	sar    $0x1f,%ebx
80100680:	29 d8                	sub    %ebx,%eax
80100682:	89 c2                	mov    %eax,%edx
80100684:	89 d0                	mov    %edx,%eax
80100686:	c1 e0 02             	shl    $0x2,%eax
80100689:	01 d0                	add    %edx,%eax
8010068b:	c1 e0 04             	shl    $0x4,%eax
8010068e:	29 c1                	sub    %eax,%ecx
80100690:	89 ca                	mov    %ecx,%edx
80100692:	b8 50 00 00 00       	mov    $0x50,%eax
80100697:	29 d0                	sub    %edx,%eax
80100699:	01 45 f4             	add    %eax,-0xc(%ebp)
8010069c:	eb 38                	jmp    801006d6 <cgaputc+0xc0>
  else if(c == BACKSPACE){
8010069e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006a5:	75 0c                	jne    801006b3 <cgaputc+0x9d>
    if(pos > 0) --pos;
801006a7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006ab:	7e 29                	jle    801006d6 <cgaputc+0xc0>
801006ad:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801006b1:	eb 23                	jmp    801006d6 <cgaputc+0xc0>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801006b3:	8b 45 08             	mov    0x8(%ebp),%eax
801006b6:	0f b6 c0             	movzbl %al,%eax
801006b9:	80 cc 07             	or     $0x7,%ah
801006bc:	89 c1                	mov    %eax,%ecx
801006be:	8b 1d 00 90 10 80    	mov    0x80109000,%ebx
801006c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006c7:	8d 50 01             	lea    0x1(%eax),%edx
801006ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006cd:	01 c0                	add    %eax,%eax
801006cf:	01 d8                	add    %ebx,%eax
801006d1:	89 ca                	mov    %ecx,%edx
801006d3:	66 89 10             	mov    %dx,(%eax)

  if(pos < 0 || pos > 25*80)
801006d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801006da:	78 09                	js     801006e5 <cgaputc+0xcf>
801006dc:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
801006e3:	7e 0d                	jle    801006f2 <cgaputc+0xdc>
    panic("pos under/overflow");
801006e5:	83 ec 0c             	sub    $0xc,%esp
801006e8:	68 bf 87 10 80       	push   $0x801087bf
801006ed:	e8 89 fe ff ff       	call   8010057b <panic>
  
  if((pos/80) >= 24){  // Scroll up.
801006f2:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006f9:	7e 4d                	jle    80100748 <cgaputc+0x132>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006fb:	a1 00 90 10 80       	mov    0x80109000,%eax
80100700:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
80100706:	a1 00 90 10 80       	mov    0x80109000,%eax
8010070b:	83 ec 04             	sub    $0x4,%esp
8010070e:	68 60 0e 00 00       	push   $0xe60
80100713:	52                   	push   %edx
80100714:	50                   	push   %eax
80100715:	e8 91 4c 00 00       	call   801053ab <memmove>
8010071a:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
8010071d:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100721:	b8 80 07 00 00       	mov    $0x780,%eax
80100726:	2b 45 f4             	sub    -0xc(%ebp),%eax
80100729:	8d 14 00             	lea    (%eax,%eax,1),%edx
8010072c:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
80100732:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100735:	01 c0                	add    %eax,%eax
80100737:	01 c8                	add    %ecx,%eax
80100739:	83 ec 04             	sub    $0x4,%esp
8010073c:	52                   	push   %edx
8010073d:	6a 00                	push   $0x0
8010073f:	50                   	push   %eax
80100740:	e8 a7 4b 00 00       	call   801052ec <memset>
80100745:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
80100748:	83 ec 08             	sub    $0x8,%esp
8010074b:	6a 0e                	push   $0xe
8010074d:	68 d4 03 00 00       	push   $0x3d4
80100752:	e8 9b fb ff ff       	call   801002f2 <outb>
80100757:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	c1 f8 08             	sar    $0x8,%eax
80100760:	0f b6 c0             	movzbl %al,%eax
80100763:	83 ec 08             	sub    $0x8,%esp
80100766:	50                   	push   %eax
80100767:	68 d5 03 00 00       	push   $0x3d5
8010076c:	e8 81 fb ff ff       	call   801002f2 <outb>
80100771:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100774:	83 ec 08             	sub    $0x8,%esp
80100777:	6a 0f                	push   $0xf
80100779:	68 d4 03 00 00       	push   $0x3d4
8010077e:	e8 6f fb ff ff       	call   801002f2 <outb>
80100783:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
80100786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100789:	0f b6 c0             	movzbl %al,%eax
8010078c:	83 ec 08             	sub    $0x8,%esp
8010078f:	50                   	push   %eax
80100790:	68 d5 03 00 00       	push   $0x3d5
80100795:	e8 58 fb ff ff       	call   801002f2 <outb>
8010079a:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
8010079d:	8b 15 00 90 10 80    	mov    0x80109000,%edx
801007a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007a6:	01 c0                	add    %eax,%eax
801007a8:	01 d0                	add    %edx,%eax
801007aa:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
801007af:	90                   	nop
801007b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801007b3:	c9                   	leave  
801007b4:	c3                   	ret    

801007b5 <consputc>:

void
consputc(int c)
{
801007b5:	55                   	push   %ebp
801007b6:	89 e5                	mov    %esp,%ebp
801007b8:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
801007bb:	a1 6c f7 10 80       	mov    0x8010f76c,%eax
801007c0:	85 c0                	test   %eax,%eax
801007c2:	74 07                	je     801007cb <consputc+0x16>
    cli();
801007c4:	e8 4a fb ff ff       	call   80100313 <cli>
    for(;;)
801007c9:	eb fe                	jmp    801007c9 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
801007cb:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801007d2:	75 29                	jne    801007fd <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
801007d4:	83 ec 0c             	sub    $0xc,%esp
801007d7:	6a 08                	push   $0x8
801007d9:	e8 1f 66 00 00       	call   80106dfd <uartputc>
801007de:	83 c4 10             	add    $0x10,%esp
801007e1:	83 ec 0c             	sub    $0xc,%esp
801007e4:	6a 20                	push   $0x20
801007e6:	e8 12 66 00 00       	call   80106dfd <uartputc>
801007eb:	83 c4 10             	add    $0x10,%esp
801007ee:	83 ec 0c             	sub    $0xc,%esp
801007f1:	6a 08                	push   $0x8
801007f3:	e8 05 66 00 00       	call   80106dfd <uartputc>
801007f8:	83 c4 10             	add    $0x10,%esp
801007fb:	eb 0e                	jmp    8010080b <consputc+0x56>
  } else
    uartputc(c);
801007fd:	83 ec 0c             	sub    $0xc,%esp
80100800:	ff 75 08             	push   0x8(%ebp)
80100803:	e8 f5 65 00 00       	call   80106dfd <uartputc>
80100808:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010080b:	83 ec 0c             	sub    $0xc,%esp
8010080e:	ff 75 08             	push   0x8(%ebp)
80100811:	e8 00 fe ff ff       	call   80100616 <cgaputc>
80100816:	83 c4 10             	add    $0x10,%esp
}
80100819:	90                   	nop
8010081a:	c9                   	leave  
8010081b:	c3                   	ret    

8010081c <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
8010081c:	55                   	push   %ebp
8010081d:	89 e5                	mov    %esp,%ebp
8010081f:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
80100822:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
80100829:	83 ec 0c             	sub    $0xc,%esp
8010082c:	68 80 f7 10 80       	push   $0x8010f780
80100831:	e8 53 48 00 00       	call   80105089 <acquire>
80100836:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
80100839:	e9 50 01 00 00       	jmp    8010098e <consoleintr+0x172>
    switch(c){
8010083e:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100842:	0f 84 81 00 00 00    	je     801008c9 <consoleintr+0xad>
80100848:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010084c:	0f 8f ac 00 00 00    	jg     801008fe <consoleintr+0xe2>
80100852:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100856:	74 43                	je     8010089b <consoleintr+0x7f>
80100858:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
8010085c:	0f 8f 9c 00 00 00    	jg     801008fe <consoleintr+0xe2>
80100862:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100866:	74 61                	je     801008c9 <consoleintr+0xad>
80100868:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
8010086c:	0f 85 8c 00 00 00    	jne    801008fe <consoleintr+0xe2>
    case C('P'):  // Process listing.
      doprocdump = 1;   // procdump() locks cons.lock indirectly; invoke later
80100872:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100879:	e9 10 01 00 00       	jmp    8010098e <consoleintr+0x172>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
8010087e:	a1 68 f7 10 80       	mov    0x8010f768,%eax
80100883:	83 e8 01             	sub    $0x1,%eax
80100886:	a3 68 f7 10 80       	mov    %eax,0x8010f768
        consputc(BACKSPACE);
8010088b:	83 ec 0c             	sub    $0xc,%esp
8010088e:	68 00 01 00 00       	push   $0x100
80100893:	e8 1d ff ff ff       	call   801007b5 <consputc>
80100898:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
8010089b:	8b 15 68 f7 10 80    	mov    0x8010f768,%edx
801008a1:	a1 64 f7 10 80       	mov    0x8010f764,%eax
801008a6:	39 c2                	cmp    %eax,%edx
801008a8:	0f 84 e0 00 00 00    	je     8010098e <consoleintr+0x172>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
801008ae:	a1 68 f7 10 80       	mov    0x8010f768,%eax
801008b3:	83 e8 01             	sub    $0x1,%eax
801008b6:	83 e0 7f             	and    $0x7f,%eax
801008b9:	0f b6 80 e0 f6 10 80 	movzbl -0x7fef0920(%eax),%eax
      while(input.e != input.w &&
801008c0:	3c 0a                	cmp    $0xa,%al
801008c2:	75 ba                	jne    8010087e <consoleintr+0x62>
      }
      break;
801008c4:	e9 c5 00 00 00       	jmp    8010098e <consoleintr+0x172>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801008c9:	8b 15 68 f7 10 80    	mov    0x8010f768,%edx
801008cf:	a1 64 f7 10 80       	mov    0x8010f764,%eax
801008d4:	39 c2                	cmp    %eax,%edx
801008d6:	0f 84 b2 00 00 00    	je     8010098e <consoleintr+0x172>
        input.e--;
801008dc:	a1 68 f7 10 80       	mov    0x8010f768,%eax
801008e1:	83 e8 01             	sub    $0x1,%eax
801008e4:	a3 68 f7 10 80       	mov    %eax,0x8010f768
        consputc(BACKSPACE);
801008e9:	83 ec 0c             	sub    $0xc,%esp
801008ec:	68 00 01 00 00       	push   $0x100
801008f1:	e8 bf fe ff ff       	call   801007b5 <consputc>
801008f6:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008f9:	e9 90 00 00 00       	jmp    8010098e <consoleintr+0x172>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008fe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100902:	0f 84 85 00 00 00    	je     8010098d <consoleintr+0x171>
80100908:	a1 68 f7 10 80       	mov    0x8010f768,%eax
8010090d:	8b 15 60 f7 10 80    	mov    0x8010f760,%edx
80100913:	29 d0                	sub    %edx,%eax
80100915:	83 f8 7f             	cmp    $0x7f,%eax
80100918:	77 73                	ja     8010098d <consoleintr+0x171>
        c = (c == '\r') ? '\n' : c;
8010091a:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010091e:	74 05                	je     80100925 <consoleintr+0x109>
80100920:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100923:	eb 05                	jmp    8010092a <consoleintr+0x10e>
80100925:	b8 0a 00 00 00       	mov    $0xa,%eax
8010092a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010092d:	a1 68 f7 10 80       	mov    0x8010f768,%eax
80100932:	8d 50 01             	lea    0x1(%eax),%edx
80100935:	89 15 68 f7 10 80    	mov    %edx,0x8010f768
8010093b:	83 e0 7f             	and    $0x7f,%eax
8010093e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100941:	88 90 e0 f6 10 80    	mov    %dl,-0x7fef0920(%eax)
        consputc(c);
80100947:	83 ec 0c             	sub    $0xc,%esp
8010094a:	ff 75 f0             	push   -0x10(%ebp)
8010094d:	e8 63 fe ff ff       	call   801007b5 <consputc>
80100952:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100955:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100959:	74 18                	je     80100973 <consoleintr+0x157>
8010095b:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
8010095f:	74 12                	je     80100973 <consoleintr+0x157>
80100961:	a1 68 f7 10 80       	mov    0x8010f768,%eax
80100966:	8b 15 60 f7 10 80    	mov    0x8010f760,%edx
8010096c:	83 ea 80             	sub    $0xffffff80,%edx
8010096f:	39 d0                	cmp    %edx,%eax
80100971:	75 1a                	jne    8010098d <consoleintr+0x171>
          input.w = input.e;
80100973:	a1 68 f7 10 80       	mov    0x8010f768,%eax
80100978:	a3 64 f7 10 80       	mov    %eax,0x8010f764
          wakeup(&input.r);
8010097d:	83 ec 0c             	sub    $0xc,%esp
80100980:	68 60 f7 10 80       	push   $0x8010f760
80100985:	e8 f0 44 00 00       	call   80104e7a <wakeup>
8010098a:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
8010098d:	90                   	nop
  while((c = getc()) >= 0){
8010098e:	8b 45 08             	mov    0x8(%ebp),%eax
80100991:	ff d0                	call   *%eax
80100993:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100996:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010099a:	0f 89 9e fe ff ff    	jns    8010083e <consoleintr+0x22>
    }
  }
  release(&cons.lock);
801009a0:	83 ec 0c             	sub    $0xc,%esp
801009a3:	68 80 f7 10 80       	push   $0x8010f780
801009a8:	e8 43 47 00 00       	call   801050f0 <release>
801009ad:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
801009b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801009b4:	74 05                	je     801009bb <consoleintr+0x19f>
    procdump();  // now call procdump() wo. cons.lock held
801009b6:	e8 7a 45 00 00       	call   80104f35 <procdump>
  }
}
801009bb:	90                   	nop
801009bc:	c9                   	leave  
801009bd:	c3                   	ret    

801009be <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
801009be:	55                   	push   %ebp
801009bf:	89 e5                	mov    %esp,%ebp
801009c1:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
801009c4:	83 ec 0c             	sub    $0xc,%esp
801009c7:	ff 75 08             	push   0x8(%ebp)
801009ca:	e8 16 11 00 00       	call   80101ae5 <iunlock>
801009cf:	83 c4 10             	add    $0x10,%esp
  target = n;
801009d2:	8b 45 10             	mov    0x10(%ebp),%eax
801009d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
801009d8:	83 ec 0c             	sub    $0xc,%esp
801009db:	68 80 f7 10 80       	push   $0x8010f780
801009e0:	e8 a4 46 00 00       	call   80105089 <acquire>
801009e5:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009e8:	e9 ac 00 00 00       	jmp    80100a99 <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
801009ed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801009f3:	8b 40 24             	mov    0x24(%eax),%eax
801009f6:	85 c0                	test   %eax,%eax
801009f8:	74 28                	je     80100a22 <consoleread+0x64>
        release(&cons.lock);
801009fa:	83 ec 0c             	sub    $0xc,%esp
801009fd:	68 80 f7 10 80       	push   $0x8010f780
80100a02:	e8 e9 46 00 00       	call   801050f0 <release>
80100a07:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
80100a0a:	83 ec 0c             	sub    $0xc,%esp
80100a0d:	ff 75 08             	push   0x8(%ebp)
80100a10:	e8 72 0f 00 00       	call   80101987 <ilock>
80100a15:	83 c4 10             	add    $0x10,%esp
        return -1;
80100a18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a1d:	e9 a9 00 00 00       	jmp    80100acb <consoleread+0x10d>
      }
      sleep(&input.r, &cons.lock);
80100a22:	83 ec 08             	sub    $0x8,%esp
80100a25:	68 80 f7 10 80       	push   $0x8010f780
80100a2a:	68 60 f7 10 80       	push   $0x8010f760
80100a2f:	e8 5a 43 00 00       	call   80104d8e <sleep>
80100a34:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
80100a37:	8b 15 60 f7 10 80    	mov    0x8010f760,%edx
80100a3d:	a1 64 f7 10 80       	mov    0x8010f764,%eax
80100a42:	39 c2                	cmp    %eax,%edx
80100a44:	74 a7                	je     801009ed <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a46:	a1 60 f7 10 80       	mov    0x8010f760,%eax
80100a4b:	8d 50 01             	lea    0x1(%eax),%edx
80100a4e:	89 15 60 f7 10 80    	mov    %edx,0x8010f760
80100a54:	83 e0 7f             	and    $0x7f,%eax
80100a57:	0f b6 80 e0 f6 10 80 	movzbl -0x7fef0920(%eax),%eax
80100a5e:	0f be c0             	movsbl %al,%eax
80100a61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a64:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a68:	75 17                	jne    80100a81 <consoleread+0xc3>
      if(n < target){
80100a6a:	8b 45 10             	mov    0x10(%ebp),%eax
80100a6d:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100a70:	76 2f                	jbe    80100aa1 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a72:	a1 60 f7 10 80       	mov    0x8010f760,%eax
80100a77:	83 e8 01             	sub    $0x1,%eax
80100a7a:	a3 60 f7 10 80       	mov    %eax,0x8010f760
      }
      break;
80100a7f:	eb 20                	jmp    80100aa1 <consoleread+0xe3>
    }
    *dst++ = c;
80100a81:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a84:	8d 50 01             	lea    0x1(%eax),%edx
80100a87:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a8a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a8d:	88 10                	mov    %dl,(%eax)
    --n;
80100a8f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a93:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a97:	74 0b                	je     80100aa4 <consoleread+0xe6>
  while(n > 0){
80100a99:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a9d:	7f 98                	jg     80100a37 <consoleread+0x79>
80100a9f:	eb 04                	jmp    80100aa5 <consoleread+0xe7>
      break;
80100aa1:	90                   	nop
80100aa2:	eb 01                	jmp    80100aa5 <consoleread+0xe7>
      break;
80100aa4:	90                   	nop
  }
  release(&cons.lock);
80100aa5:	83 ec 0c             	sub    $0xc,%esp
80100aa8:	68 80 f7 10 80       	push   $0x8010f780
80100aad:	e8 3e 46 00 00       	call   801050f0 <release>
80100ab2:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ab5:	83 ec 0c             	sub    $0xc,%esp
80100ab8:	ff 75 08             	push   0x8(%ebp)
80100abb:	e8 c7 0e 00 00       	call   80101987 <ilock>
80100ac0:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100ac3:	8b 55 10             	mov    0x10(%ebp),%edx
80100ac6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac9:	29 d0                	sub    %edx,%eax
}
80100acb:	c9                   	leave  
80100acc:	c3                   	ret    

80100acd <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100acd:	55                   	push   %ebp
80100ace:	89 e5                	mov    %esp,%ebp
80100ad0:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100ad3:	83 ec 0c             	sub    $0xc,%esp
80100ad6:	ff 75 08             	push   0x8(%ebp)
80100ad9:	e8 07 10 00 00       	call   80101ae5 <iunlock>
80100ade:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100ae1:	83 ec 0c             	sub    $0xc,%esp
80100ae4:	68 80 f7 10 80       	push   $0x8010f780
80100ae9:	e8 9b 45 00 00       	call   80105089 <acquire>
80100aee:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100af1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100af8:	eb 21                	jmp    80100b1b <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100afd:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b00:	01 d0                	add    %edx,%eax
80100b02:	0f b6 00             	movzbl (%eax),%eax
80100b05:	0f be c0             	movsbl %al,%eax
80100b08:	0f b6 c0             	movzbl %al,%eax
80100b0b:	83 ec 0c             	sub    $0xc,%esp
80100b0e:	50                   	push   %eax
80100b0f:	e8 a1 fc ff ff       	call   801007b5 <consputc>
80100b14:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100b17:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b1e:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b21:	7c d7                	jl     80100afa <consolewrite+0x2d>
  release(&cons.lock);
80100b23:	83 ec 0c             	sub    $0xc,%esp
80100b26:	68 80 f7 10 80       	push   $0x8010f780
80100b2b:	e8 c0 45 00 00       	call   801050f0 <release>
80100b30:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100b33:	83 ec 0c             	sub    $0xc,%esp
80100b36:	ff 75 08             	push   0x8(%ebp)
80100b39:	e8 49 0e 00 00       	call   80101987 <ilock>
80100b3e:	83 c4 10             	add    $0x10,%esp

  return n;
80100b41:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b44:	c9                   	leave  
80100b45:	c3                   	ret    

80100b46 <consoleinit>:

void
consoleinit(void)
{
80100b46:	55                   	push   %ebp
80100b47:	89 e5                	mov    %esp,%ebp
80100b49:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100b4c:	83 ec 08             	sub    $0x8,%esp
80100b4f:	68 d2 87 10 80       	push   $0x801087d2
80100b54:	68 80 f7 10 80       	push   $0x8010f780
80100b59:	e8 09 45 00 00       	call   80105067 <initlock>
80100b5e:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b61:	c7 05 cc f7 10 80 cd 	movl   $0x80100acd,0x8010f7cc
80100b68:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b6b:	c7 05 c8 f7 10 80 be 	movl   $0x801009be,0x8010f7c8
80100b72:	09 10 80 
  cons.locking = 1;
80100b75:	c7 05 b4 f7 10 80 01 	movl   $0x1,0x8010f7b4
80100b7c:	00 00 00 

  picenable(IRQ_KBD);
80100b7f:	83 ec 0c             	sub    $0xc,%esp
80100b82:	6a 01                	push   $0x1
80100b84:	e8 e9 33 00 00       	call   80103f72 <picenable>
80100b89:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b8c:	83 ec 08             	sub    $0x8,%esp
80100b8f:	6a 00                	push   $0x0
80100b91:	6a 01                	push   $0x1
80100b93:	e8 54 1f 00 00       	call   80102aec <ioapicenable>
80100b98:	83 c4 10             	add    $0x10,%esp
}
80100b9b:	90                   	nop
80100b9c:	c9                   	leave  
80100b9d:	c3                   	ret    

80100b9e <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b9e:	55                   	push   %ebp
80100b9f:	89 e5                	mov    %esp,%ebp
80100ba1:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100ba7:	e8 ca 29 00 00       	call   80103576 <begin_op>
  if((ip = namei(path)) == 0){
80100bac:	83 ec 0c             	sub    $0xc,%esp
80100baf:	ff 75 08             	push   0x8(%ebp)
80100bb2:	e8 81 19 00 00       	call   80102538 <namei>
80100bb7:	83 c4 10             	add    $0x10,%esp
80100bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bbd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bc1:	75 0f                	jne    80100bd2 <exec+0x34>
    end_op();
80100bc3:	e8 3a 2a 00 00       	call   80103602 <end_op>
    return -1;
80100bc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bcd:	e9 ce 03 00 00       	jmp    80100fa0 <exec+0x402>
  }
  ilock(ip);
80100bd2:	83 ec 0c             	sub    $0xc,%esp
80100bd5:	ff 75 d8             	push   -0x28(%ebp)
80100bd8:	e8 aa 0d 00 00       	call   80101987 <ilock>
80100bdd:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100be7:	6a 34                	push   $0x34
80100be9:	6a 00                	push   $0x0
80100beb:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100bf1:	50                   	push   %eax
80100bf2:	ff 75 d8             	push   -0x28(%ebp)
80100bf5:	e8 f6 12 00 00       	call   80101ef0 <readi>
80100bfa:	83 c4 10             	add    $0x10,%esp
80100bfd:	83 f8 33             	cmp    $0x33,%eax
80100c00:	0f 86 49 03 00 00    	jbe    80100f4f <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c06:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c0c:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c11:	0f 85 3b 03 00 00    	jne    80100f52 <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c17:	e8 36 73 00 00       	call   80107f52 <setupkvm>
80100c1c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c1f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c23:	0f 84 2c 03 00 00    	je     80100f55 <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c29:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c30:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c37:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100c3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c40:	e9 ab 00 00 00       	jmp    80100cf0 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c45:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c48:	6a 20                	push   $0x20
80100c4a:	50                   	push   %eax
80100c4b:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c51:	50                   	push   %eax
80100c52:	ff 75 d8             	push   -0x28(%ebp)
80100c55:	e8 96 12 00 00       	call   80101ef0 <readi>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	83 f8 20             	cmp    $0x20,%eax
80100c60:	0f 85 f2 02 00 00    	jne    80100f58 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c66:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c6c:	83 f8 01             	cmp    $0x1,%eax
80100c6f:	75 71                	jne    80100ce2 <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c71:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c77:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c7d:	39 c2                	cmp    %eax,%edx
80100c7f:	0f 82 d6 02 00 00    	jb     80100f5b <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c85:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c8b:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c91:	01 d0                	add    %edx,%eax
80100c93:	83 ec 04             	sub    $0x4,%esp
80100c96:	50                   	push   %eax
80100c97:	ff 75 e0             	push   -0x20(%ebp)
80100c9a:	ff 75 d4             	push   -0x2c(%ebp)
80100c9d:	e8 58 76 00 00       	call   801082fa <allocuvm>
80100ca2:	83 c4 10             	add    $0x10,%esp
80100ca5:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ca8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cac:	0f 84 ac 02 00 00    	je     80100f5e <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100cb2:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100cb8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cbe:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100cc4:	83 ec 0c             	sub    $0xc,%esp
80100cc7:	52                   	push   %edx
80100cc8:	50                   	push   %eax
80100cc9:	ff 75 d8             	push   -0x28(%ebp)
80100ccc:	51                   	push   %ecx
80100ccd:	ff 75 d4             	push   -0x2c(%ebp)
80100cd0:	e8 4e 75 00 00       	call   80108223 <loaduvm>
80100cd5:	83 c4 20             	add    $0x20,%esp
80100cd8:	85 c0                	test   %eax,%eax
80100cda:	0f 88 81 02 00 00    	js     80100f61 <exec+0x3c3>
80100ce0:	eb 01                	jmp    80100ce3 <exec+0x145>
      continue;
80100ce2:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ce3:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100ce7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cea:	83 c0 20             	add    $0x20,%eax
80100ced:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cf0:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100cf7:	0f b7 c0             	movzwl %ax,%eax
80100cfa:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100cfd:	0f 8c 42 ff ff ff    	jl     80100c45 <exec+0xa7>
      goto bad;
  }
  iunlockput(ip);
80100d03:	83 ec 0c             	sub    $0xc,%esp
80100d06:	ff 75 d8             	push   -0x28(%ebp)
80100d09:	e8 39 0f 00 00       	call   80101c47 <iunlockput>
80100d0e:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d11:	e8 ec 28 00 00       	call   80103602 <end_op>
  ip = 0;
80100d16:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d1d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d20:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d25:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d2a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d30:	05 00 20 00 00       	add    $0x2000,%eax
80100d35:	83 ec 04             	sub    $0x4,%esp
80100d38:	50                   	push   %eax
80100d39:	ff 75 e0             	push   -0x20(%ebp)
80100d3c:	ff 75 d4             	push   -0x2c(%ebp)
80100d3f:	e8 b6 75 00 00       	call   801082fa <allocuvm>
80100d44:	83 c4 10             	add    $0x10,%esp
80100d47:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d4a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d4e:	0f 84 10 02 00 00    	je     80100f64 <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d57:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d5c:	83 ec 08             	sub    $0x8,%esp
80100d5f:	50                   	push   %eax
80100d60:	ff 75 d4             	push   -0x2c(%ebp)
80100d63:	e8 b6 77 00 00       	call   8010851e <clearpteu>
80100d68:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d6e:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d71:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d78:	e9 96 00 00 00       	jmp    80100e13 <exec+0x275>
    if(argc >= MAXARG)
80100d7d:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d81:	0f 87 e0 01 00 00    	ja     80100f67 <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d8a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d91:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d94:	01 d0                	add    %edx,%eax
80100d96:	8b 00                	mov    (%eax),%eax
80100d98:	83 ec 0c             	sub    $0xc,%esp
80100d9b:	50                   	push   %eax
80100d9c:	e8 99 47 00 00       	call   8010553a <strlen>
80100da1:	83 c4 10             	add    $0x10,%esp
80100da4:	89 c2                	mov    %eax,%edx
80100da6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100da9:	29 d0                	sub    %edx,%eax
80100dab:	83 e8 01             	sub    $0x1,%eax
80100dae:	83 e0 fc             	and    $0xfffffffc,%eax
80100db1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100db4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100db7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dbe:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc1:	01 d0                	add    %edx,%eax
80100dc3:	8b 00                	mov    (%eax),%eax
80100dc5:	83 ec 0c             	sub    $0xc,%esp
80100dc8:	50                   	push   %eax
80100dc9:	e8 6c 47 00 00       	call   8010553a <strlen>
80100dce:	83 c4 10             	add    $0x10,%esp
80100dd1:	83 c0 01             	add    $0x1,%eax
80100dd4:	89 c2                	mov    %eax,%edx
80100dd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dd9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100de0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100de3:	01 c8                	add    %ecx,%eax
80100de5:	8b 00                	mov    (%eax),%eax
80100de7:	52                   	push   %edx
80100de8:	50                   	push   %eax
80100de9:	ff 75 dc             	push   -0x24(%ebp)
80100dec:	ff 75 d4             	push   -0x2c(%ebp)
80100def:	e8 e0 78 00 00       	call   801086d4 <copyout>
80100df4:	83 c4 10             	add    $0x10,%esp
80100df7:	85 c0                	test   %eax,%eax
80100df9:	0f 88 6b 01 00 00    	js     80100f6a <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	8d 50 03             	lea    0x3(%eax),%edx
80100e05:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e08:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e0f:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e13:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e1d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e20:	01 d0                	add    %edx,%eax
80100e22:	8b 00                	mov    (%eax),%eax
80100e24:	85 c0                	test   %eax,%eax
80100e26:	0f 85 51 ff ff ff    	jne    80100d7d <exec+0x1df>
  }
  ustack[3+argc] = 0;
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	83 c0 03             	add    $0x3,%eax
80100e32:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100e39:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e3d:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100e44:	ff ff ff 
  ustack[1] = argc;
80100e47:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4a:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e53:	83 c0 01             	add    $0x1,%eax
80100e56:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e5d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e60:	29 d0                	sub    %edx,%eax
80100e62:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e6b:	83 c0 04             	add    $0x4,%eax
80100e6e:	c1 e0 02             	shl    $0x2,%eax
80100e71:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e77:	83 c0 04             	add    $0x4,%eax
80100e7a:	c1 e0 02             	shl    $0x2,%eax
80100e7d:	50                   	push   %eax
80100e7e:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e84:	50                   	push   %eax
80100e85:	ff 75 dc             	push   -0x24(%ebp)
80100e88:	ff 75 d4             	push   -0x2c(%ebp)
80100e8b:	e8 44 78 00 00       	call   801086d4 <copyout>
80100e90:	83 c4 10             	add    $0x10,%esp
80100e93:	85 c0                	test   %eax,%eax
80100e95:	0f 88 d2 00 00 00    	js     80100f6d <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80100e9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ea7:	eb 17                	jmp    80100ec0 <exec+0x322>
    if(*s == '/')
80100ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eac:	0f b6 00             	movzbl (%eax),%eax
80100eaf:	3c 2f                	cmp    $0x2f,%al
80100eb1:	75 09                	jne    80100ebc <exec+0x31e>
      last = s+1;
80100eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eb6:	83 c0 01             	add    $0x1,%eax
80100eb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ebc:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ec0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ec3:	0f b6 00             	movzbl (%eax),%eax
80100ec6:	84 c0                	test   %al,%al
80100ec8:	75 df                	jne    80100ea9 <exec+0x30b>
  safestrcpy(proc->name, last, sizeof(proc->name));
80100eca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed0:	83 c0 6c             	add    $0x6c,%eax
80100ed3:	83 ec 04             	sub    $0x4,%esp
80100ed6:	6a 10                	push   $0x10
80100ed8:	ff 75 f0             	push   -0x10(%ebp)
80100edb:	50                   	push   %eax
80100edc:	e8 0e 46 00 00       	call   801054ef <safestrcpy>
80100ee1:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100ee4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eea:	8b 40 04             	mov    0x4(%eax),%eax
80100eed:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ef0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ef6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100ef9:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100efc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f02:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f05:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100f07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f0d:	8b 40 18             	mov    0x18(%eax),%eax
80100f10:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100f16:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100f19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f1f:	8b 40 18             	mov    0x18(%eax),%eax
80100f22:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f25:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100f28:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100f2e:	83 ec 0c             	sub    $0xc,%esp
80100f31:	50                   	push   %eax
80100f32:	e8 02 71 00 00       	call   80108039 <switchuvm>
80100f37:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f3a:	83 ec 0c             	sub    $0xc,%esp
80100f3d:	ff 75 d0             	push   -0x30(%ebp)
80100f40:	e8 39 75 00 00       	call   8010847e <freevm>
80100f45:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f48:	b8 00 00 00 00       	mov    $0x0,%eax
80100f4d:	eb 51                	jmp    80100fa0 <exec+0x402>
    goto bad;
80100f4f:	90                   	nop
80100f50:	eb 1c                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f52:	90                   	nop
80100f53:	eb 19                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f55:	90                   	nop
80100f56:	eb 16                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f58:	90                   	nop
80100f59:	eb 13                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f5b:	90                   	nop
80100f5c:	eb 10                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f5e:	90                   	nop
80100f5f:	eb 0d                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f61:	90                   	nop
80100f62:	eb 0a                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f64:	90                   	nop
80100f65:	eb 07                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f67:	90                   	nop
80100f68:	eb 04                	jmp    80100f6e <exec+0x3d0>
      goto bad;
80100f6a:	90                   	nop
80100f6b:	eb 01                	jmp    80100f6e <exec+0x3d0>
    goto bad;
80100f6d:	90                   	nop

 bad:
  if(pgdir)
80100f6e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f72:	74 0e                	je     80100f82 <exec+0x3e4>
    freevm(pgdir);
80100f74:	83 ec 0c             	sub    $0xc,%esp
80100f77:	ff 75 d4             	push   -0x2c(%ebp)
80100f7a:	e8 ff 74 00 00       	call   8010847e <freevm>
80100f7f:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f82:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f86:	74 13                	je     80100f9b <exec+0x3fd>
    iunlockput(ip);
80100f88:	83 ec 0c             	sub    $0xc,%esp
80100f8b:	ff 75 d8             	push   -0x28(%ebp)
80100f8e:	e8 b4 0c 00 00       	call   80101c47 <iunlockput>
80100f93:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f96:	e8 67 26 00 00       	call   80103602 <end_op>
  }
  return -1;
80100f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fa0:	c9                   	leave  
80100fa1:	c3                   	ret    

80100fa2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fa2:	55                   	push   %ebp
80100fa3:	89 e5                	mov    %esp,%ebp
80100fa5:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fa8:	83 ec 08             	sub    $0x8,%esp
80100fab:	68 da 87 10 80       	push   $0x801087da
80100fb0:	68 20 f8 10 80       	push   $0x8010f820
80100fb5:	e8 ad 40 00 00       	call   80105067 <initlock>
80100fba:	83 c4 10             	add    $0x10,%esp
}
80100fbd:	90                   	nop
80100fbe:	c9                   	leave  
80100fbf:	c3                   	ret    

80100fc0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fc0:	55                   	push   %ebp
80100fc1:	89 e5                	mov    %esp,%ebp
80100fc3:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fc6:	83 ec 0c             	sub    $0xc,%esp
80100fc9:	68 20 f8 10 80       	push   $0x8010f820
80100fce:	e8 b6 40 00 00       	call   80105089 <acquire>
80100fd3:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fd6:	c7 45 f4 54 f8 10 80 	movl   $0x8010f854,-0xc(%ebp)
80100fdd:	eb 2d                	jmp    8010100c <filealloc+0x4c>
    if(f->ref == 0){
80100fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fe2:	8b 40 04             	mov    0x4(%eax),%eax
80100fe5:	85 c0                	test   %eax,%eax
80100fe7:	75 1f                	jne    80101008 <filealloc+0x48>
      f->ref = 1;
80100fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fec:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100ff3:	83 ec 0c             	sub    $0xc,%esp
80100ff6:	68 20 f8 10 80       	push   $0x8010f820
80100ffb:	e8 f0 40 00 00       	call   801050f0 <release>
80101000:	83 c4 10             	add    $0x10,%esp
      return f;
80101003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101006:	eb 23                	jmp    8010102b <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101008:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
8010100c:	b8 b4 01 11 80       	mov    $0x801101b4,%eax
80101011:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80101014:	72 c9                	jb     80100fdf <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
80101016:	83 ec 0c             	sub    $0xc,%esp
80101019:	68 20 f8 10 80       	push   $0x8010f820
8010101e:	e8 cd 40 00 00       	call   801050f0 <release>
80101023:	83 c4 10             	add    $0x10,%esp
  return 0;
80101026:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010102b:	c9                   	leave  
8010102c:	c3                   	ret    

8010102d <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010102d:	55                   	push   %ebp
8010102e:	89 e5                	mov    %esp,%ebp
80101030:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80101033:	83 ec 0c             	sub    $0xc,%esp
80101036:	68 20 f8 10 80       	push   $0x8010f820
8010103b:	e8 49 40 00 00       	call   80105089 <acquire>
80101040:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101043:	8b 45 08             	mov    0x8(%ebp),%eax
80101046:	8b 40 04             	mov    0x4(%eax),%eax
80101049:	85 c0                	test   %eax,%eax
8010104b:	7f 0d                	jg     8010105a <filedup+0x2d>
    panic("filedup");
8010104d:	83 ec 0c             	sub    $0xc,%esp
80101050:	68 e1 87 10 80       	push   $0x801087e1
80101055:	e8 21 f5 ff ff       	call   8010057b <panic>
  f->ref++;
8010105a:	8b 45 08             	mov    0x8(%ebp),%eax
8010105d:	8b 40 04             	mov    0x4(%eax),%eax
80101060:	8d 50 01             	lea    0x1(%eax),%edx
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101069:	83 ec 0c             	sub    $0xc,%esp
8010106c:	68 20 f8 10 80       	push   $0x8010f820
80101071:	e8 7a 40 00 00       	call   801050f0 <release>
80101076:	83 c4 10             	add    $0x10,%esp
  return f;
80101079:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010107c:	c9                   	leave  
8010107d:	c3                   	ret    

8010107e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010107e:	55                   	push   %ebp
8010107f:	89 e5                	mov    %esp,%ebp
80101081:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
80101084:	83 ec 0c             	sub    $0xc,%esp
80101087:	68 20 f8 10 80       	push   $0x8010f820
8010108c:	e8 f8 3f 00 00       	call   80105089 <acquire>
80101091:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80101094:	8b 45 08             	mov    0x8(%ebp),%eax
80101097:	8b 40 04             	mov    0x4(%eax),%eax
8010109a:	85 c0                	test   %eax,%eax
8010109c:	7f 0d                	jg     801010ab <fileclose+0x2d>
    panic("fileclose");
8010109e:	83 ec 0c             	sub    $0xc,%esp
801010a1:	68 e9 87 10 80       	push   $0x801087e9
801010a6:	e8 d0 f4 ff ff       	call   8010057b <panic>
  if(--f->ref > 0){
801010ab:	8b 45 08             	mov    0x8(%ebp),%eax
801010ae:	8b 40 04             	mov    0x4(%eax),%eax
801010b1:	8d 50 ff             	lea    -0x1(%eax),%edx
801010b4:	8b 45 08             	mov    0x8(%ebp),%eax
801010b7:	89 50 04             	mov    %edx,0x4(%eax)
801010ba:	8b 45 08             	mov    0x8(%ebp),%eax
801010bd:	8b 40 04             	mov    0x4(%eax),%eax
801010c0:	85 c0                	test   %eax,%eax
801010c2:	7e 15                	jle    801010d9 <fileclose+0x5b>
    release(&ftable.lock);
801010c4:	83 ec 0c             	sub    $0xc,%esp
801010c7:	68 20 f8 10 80       	push   $0x8010f820
801010cc:	e8 1f 40 00 00       	call   801050f0 <release>
801010d1:	83 c4 10             	add    $0x10,%esp
801010d4:	e9 8b 00 00 00       	jmp    80101164 <fileclose+0xe6>
    return;
  }
  ff = *f;
801010d9:	8b 45 08             	mov    0x8(%ebp),%eax
801010dc:	8b 10                	mov    (%eax),%edx
801010de:	89 55 e0             	mov    %edx,-0x20(%ebp)
801010e1:	8b 50 04             	mov    0x4(%eax),%edx
801010e4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801010e7:	8b 50 08             	mov    0x8(%eax),%edx
801010ea:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010ed:	8b 50 0c             	mov    0xc(%eax),%edx
801010f0:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010f3:	8b 50 10             	mov    0x10(%eax),%edx
801010f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010f9:	8b 40 14             	mov    0x14(%eax),%eax
801010fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101102:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101109:	8b 45 08             	mov    0x8(%ebp),%eax
8010110c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101112:	83 ec 0c             	sub    $0xc,%esp
80101115:	68 20 f8 10 80       	push   $0x8010f820
8010111a:	e8 d1 3f 00 00       	call   801050f0 <release>
8010111f:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
80101122:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101125:	83 f8 01             	cmp    $0x1,%eax
80101128:	75 19                	jne    80101143 <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
8010112a:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
8010112e:	0f be d0             	movsbl %al,%edx
80101131:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101134:	83 ec 08             	sub    $0x8,%esp
80101137:	52                   	push   %edx
80101138:	50                   	push   %eax
80101139:	e8 9c 30 00 00       	call   801041da <pipeclose>
8010113e:	83 c4 10             	add    $0x10,%esp
80101141:	eb 21                	jmp    80101164 <fileclose+0xe6>
  else if(ff.type == FD_INODE){
80101143:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101146:	83 f8 02             	cmp    $0x2,%eax
80101149:	75 19                	jne    80101164 <fileclose+0xe6>
    begin_op();
8010114b:	e8 26 24 00 00       	call   80103576 <begin_op>
    iput(ff.ip);
80101150:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101153:	83 ec 0c             	sub    $0xc,%esp
80101156:	50                   	push   %eax
80101157:	e8 fb 09 00 00       	call   80101b57 <iput>
8010115c:	83 c4 10             	add    $0x10,%esp
    end_op();
8010115f:	e8 9e 24 00 00       	call   80103602 <end_op>
  }
}
80101164:	c9                   	leave  
80101165:	c3                   	ret    

80101166 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80101166:	55                   	push   %ebp
80101167:	89 e5                	mov    %esp,%ebp
80101169:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
8010116c:	8b 45 08             	mov    0x8(%ebp),%eax
8010116f:	8b 00                	mov    (%eax),%eax
80101171:	83 f8 02             	cmp    $0x2,%eax
80101174:	75 40                	jne    801011b6 <filestat+0x50>
    ilock(f->ip);
80101176:	8b 45 08             	mov    0x8(%ebp),%eax
80101179:	8b 40 10             	mov    0x10(%eax),%eax
8010117c:	83 ec 0c             	sub    $0xc,%esp
8010117f:	50                   	push   %eax
80101180:	e8 02 08 00 00       	call   80101987 <ilock>
80101185:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101188:	8b 45 08             	mov    0x8(%ebp),%eax
8010118b:	8b 40 10             	mov    0x10(%eax),%eax
8010118e:	83 ec 08             	sub    $0x8,%esp
80101191:	ff 75 0c             	push   0xc(%ebp)
80101194:	50                   	push   %eax
80101195:	e8 10 0d 00 00       	call   80101eaa <stati>
8010119a:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 39 09 00 00       	call   80101ae5 <iunlock>
801011ac:	83 c4 10             	add    $0x10,%esp
    return 0;
801011af:	b8 00 00 00 00       	mov    $0x0,%eax
801011b4:	eb 05                	jmp    801011bb <filestat+0x55>
  }
  return -1;
801011b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011bb:	c9                   	leave  
801011bc:	c3                   	ret    

801011bd <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011bd:	55                   	push   %ebp
801011be:	89 e5                	mov    %esp,%ebp
801011c0:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011c3:	8b 45 08             	mov    0x8(%ebp),%eax
801011c6:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011ca:	84 c0                	test   %al,%al
801011cc:	75 0a                	jne    801011d8 <fileread+0x1b>
    return -1;
801011ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011d3:	e9 9b 00 00 00       	jmp    80101273 <fileread+0xb6>
  if(f->type == FD_PIPE)
801011d8:	8b 45 08             	mov    0x8(%ebp),%eax
801011db:	8b 00                	mov    (%eax),%eax
801011dd:	83 f8 01             	cmp    $0x1,%eax
801011e0:	75 1a                	jne    801011fc <fileread+0x3f>
    return piperead(f->pipe, addr, n);
801011e2:	8b 45 08             	mov    0x8(%ebp),%eax
801011e5:	8b 40 0c             	mov    0xc(%eax),%eax
801011e8:	83 ec 04             	sub    $0x4,%esp
801011eb:	ff 75 10             	push   0x10(%ebp)
801011ee:	ff 75 0c             	push   0xc(%ebp)
801011f1:	50                   	push   %eax
801011f2:	e8 91 31 00 00       	call   80104388 <piperead>
801011f7:	83 c4 10             	add    $0x10,%esp
801011fa:	eb 77                	jmp    80101273 <fileread+0xb6>
  if(f->type == FD_INODE){
801011fc:	8b 45 08             	mov    0x8(%ebp),%eax
801011ff:	8b 00                	mov    (%eax),%eax
80101201:	83 f8 02             	cmp    $0x2,%eax
80101204:	75 60                	jne    80101266 <fileread+0xa9>
    ilock(f->ip);
80101206:	8b 45 08             	mov    0x8(%ebp),%eax
80101209:	8b 40 10             	mov    0x10(%eax),%eax
8010120c:	83 ec 0c             	sub    $0xc,%esp
8010120f:	50                   	push   %eax
80101210:	e8 72 07 00 00       	call   80101987 <ilock>
80101215:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101218:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010121b:	8b 45 08             	mov    0x8(%ebp),%eax
8010121e:	8b 50 14             	mov    0x14(%eax),%edx
80101221:	8b 45 08             	mov    0x8(%ebp),%eax
80101224:	8b 40 10             	mov    0x10(%eax),%eax
80101227:	51                   	push   %ecx
80101228:	52                   	push   %edx
80101229:	ff 75 0c             	push   0xc(%ebp)
8010122c:	50                   	push   %eax
8010122d:	e8 be 0c 00 00       	call   80101ef0 <readi>
80101232:	83 c4 10             	add    $0x10,%esp
80101235:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101238:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010123c:	7e 11                	jle    8010124f <fileread+0x92>
      f->off += r;
8010123e:	8b 45 08             	mov    0x8(%ebp),%eax
80101241:	8b 50 14             	mov    0x14(%eax),%edx
80101244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101247:	01 c2                	add    %eax,%edx
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
8010124f:	8b 45 08             	mov    0x8(%ebp),%eax
80101252:	8b 40 10             	mov    0x10(%eax),%eax
80101255:	83 ec 0c             	sub    $0xc,%esp
80101258:	50                   	push   %eax
80101259:	e8 87 08 00 00       	call   80101ae5 <iunlock>
8010125e:	83 c4 10             	add    $0x10,%esp
    return r;
80101261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101264:	eb 0d                	jmp    80101273 <fileread+0xb6>
  }
  panic("fileread");
80101266:	83 ec 0c             	sub    $0xc,%esp
80101269:	68 f3 87 10 80       	push   $0x801087f3
8010126e:	e8 08 f3 ff ff       	call   8010057b <panic>
}
80101273:	c9                   	leave  
80101274:	c3                   	ret    

80101275 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101275:	55                   	push   %ebp
80101276:	89 e5                	mov    %esp,%ebp
80101278:	53                   	push   %ebx
80101279:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
8010127c:	8b 45 08             	mov    0x8(%ebp),%eax
8010127f:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80101283:	84 c0                	test   %al,%al
80101285:	75 0a                	jne    80101291 <filewrite+0x1c>
    return -1;
80101287:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010128c:	e9 1b 01 00 00       	jmp    801013ac <filewrite+0x137>
  if(f->type == FD_PIPE)
80101291:	8b 45 08             	mov    0x8(%ebp),%eax
80101294:	8b 00                	mov    (%eax),%eax
80101296:	83 f8 01             	cmp    $0x1,%eax
80101299:	75 1d                	jne    801012b8 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
8010129b:	8b 45 08             	mov    0x8(%ebp),%eax
8010129e:	8b 40 0c             	mov    0xc(%eax),%eax
801012a1:	83 ec 04             	sub    $0x4,%esp
801012a4:	ff 75 10             	push   0x10(%ebp)
801012a7:	ff 75 0c             	push   0xc(%ebp)
801012aa:	50                   	push   %eax
801012ab:	e8 d5 2f 00 00       	call   80104285 <pipewrite>
801012b0:	83 c4 10             	add    $0x10,%esp
801012b3:	e9 f4 00 00 00       	jmp    801013ac <filewrite+0x137>
  if(f->type == FD_INODE){
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 02             	cmp    $0x2,%eax
801012c0:	0f 85 d9 00 00 00    	jne    8010139f <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801012c6:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801012cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012d4:	e9 a3 00 00 00       	jmp    8010137c <filewrite+0x107>
      int n1 = n - i;
801012d9:	8b 45 10             	mov    0x10(%ebp),%eax
801012dc:	2b 45 f4             	sub    -0xc(%ebp),%eax
801012df:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801012e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801012e5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012e8:	7e 06                	jle    801012f0 <filewrite+0x7b>
        n1 = max;
801012ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012ed:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012f0:	e8 81 22 00 00       	call   80103576 <begin_op>
      ilock(f->ip);
801012f5:	8b 45 08             	mov    0x8(%ebp),%eax
801012f8:	8b 40 10             	mov    0x10(%eax),%eax
801012fb:	83 ec 0c             	sub    $0xc,%esp
801012fe:	50                   	push   %eax
801012ff:	e8 83 06 00 00       	call   80101987 <ilock>
80101304:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101307:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010130a:	8b 45 08             	mov    0x8(%ebp),%eax
8010130d:	8b 50 14             	mov    0x14(%eax),%edx
80101310:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101313:	8b 45 0c             	mov    0xc(%ebp),%eax
80101316:	01 c3                	add    %eax,%ebx
80101318:	8b 45 08             	mov    0x8(%ebp),%eax
8010131b:	8b 40 10             	mov    0x10(%eax),%eax
8010131e:	51                   	push   %ecx
8010131f:	52                   	push   %edx
80101320:	53                   	push   %ebx
80101321:	50                   	push   %eax
80101322:	e8 1e 0d 00 00       	call   80102045 <writei>
80101327:	83 c4 10             	add    $0x10,%esp
8010132a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010132d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101331:	7e 11                	jle    80101344 <filewrite+0xcf>
        f->off += r;
80101333:	8b 45 08             	mov    0x8(%ebp),%eax
80101336:	8b 50 14             	mov    0x14(%eax),%edx
80101339:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010133c:	01 c2                	add    %eax,%edx
8010133e:	8b 45 08             	mov    0x8(%ebp),%eax
80101341:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101344:	8b 45 08             	mov    0x8(%ebp),%eax
80101347:	8b 40 10             	mov    0x10(%eax),%eax
8010134a:	83 ec 0c             	sub    $0xc,%esp
8010134d:	50                   	push   %eax
8010134e:	e8 92 07 00 00       	call   80101ae5 <iunlock>
80101353:	83 c4 10             	add    $0x10,%esp
      end_op();
80101356:	e8 a7 22 00 00       	call   80103602 <end_op>

      if(r < 0)
8010135b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010135f:	78 29                	js     8010138a <filewrite+0x115>
        break;
      if(r != n1)
80101361:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101364:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101367:	74 0d                	je     80101376 <filewrite+0x101>
        panic("short filewrite");
80101369:	83 ec 0c             	sub    $0xc,%esp
8010136c:	68 fc 87 10 80       	push   $0x801087fc
80101371:	e8 05 f2 ff ff       	call   8010057b <panic>
      i += r;
80101376:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101379:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
8010137c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010137f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101382:	0f 8c 51 ff ff ff    	jl     801012d9 <filewrite+0x64>
80101388:	eb 01                	jmp    8010138b <filewrite+0x116>
        break;
8010138a:	90                   	nop
    }
    return i == n ? n : -1;
8010138b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010138e:	3b 45 10             	cmp    0x10(%ebp),%eax
80101391:	75 05                	jne    80101398 <filewrite+0x123>
80101393:	8b 45 10             	mov    0x10(%ebp),%eax
80101396:	eb 14                	jmp    801013ac <filewrite+0x137>
80101398:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010139d:	eb 0d                	jmp    801013ac <filewrite+0x137>
  }
  panic("filewrite");
8010139f:	83 ec 0c             	sub    $0xc,%esp
801013a2:	68 0c 88 10 80       	push   $0x8010880c
801013a7:	e8 cf f1 ff ff       	call   8010057b <panic>
}
801013ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013af:	c9                   	leave  
801013b0:	c3                   	ret    

801013b1 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013b1:	55                   	push   %ebp
801013b2:	89 e5                	mov    %esp,%ebp
801013b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
801013b7:	8b 45 08             	mov    0x8(%ebp),%eax
801013ba:	83 ec 08             	sub    $0x8,%esp
801013bd:	6a 01                	push   $0x1
801013bf:	50                   	push   %eax
801013c0:	e8 f2 ed ff ff       	call   801001b7 <bread>
801013c5:	83 c4 10             	add    $0x10,%esp
801013c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ce:	83 c0 18             	add    $0x18,%eax
801013d1:	83 ec 04             	sub    $0x4,%esp
801013d4:	6a 1c                	push   $0x1c
801013d6:	50                   	push   %eax
801013d7:	ff 75 0c             	push   0xc(%ebp)
801013da:	e8 cc 3f 00 00       	call   801053ab <memmove>
801013df:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013e2:	83 ec 0c             	sub    $0xc,%esp
801013e5:	ff 75 f4             	push   -0xc(%ebp)
801013e8:	e8 42 ee ff ff       	call   8010022f <brelse>
801013ed:	83 c4 10             	add    $0x10,%esp
}
801013f0:	90                   	nop
801013f1:	c9                   	leave  
801013f2:	c3                   	ret    

801013f3 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013f3:	55                   	push   %ebp
801013f4:	89 e5                	mov    %esp,%ebp
801013f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013f9:	8b 55 0c             	mov    0xc(%ebp),%edx
801013fc:	8b 45 08             	mov    0x8(%ebp),%eax
801013ff:	83 ec 08             	sub    $0x8,%esp
80101402:	52                   	push   %edx
80101403:	50                   	push   %eax
80101404:	e8 ae ed ff ff       	call   801001b7 <bread>
80101409:	83 c4 10             	add    $0x10,%esp
8010140c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
8010140f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101412:	83 c0 18             	add    $0x18,%eax
80101415:	83 ec 04             	sub    $0x4,%esp
80101418:	68 00 02 00 00       	push   $0x200
8010141d:	6a 00                	push   $0x0
8010141f:	50                   	push   %eax
80101420:	e8 c7 3e 00 00       	call   801052ec <memset>
80101425:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101428:	83 ec 0c             	sub    $0xc,%esp
8010142b:	ff 75 f4             	push   -0xc(%ebp)
8010142e:	e8 7c 23 00 00       	call   801037af <log_write>
80101433:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101436:	83 ec 0c             	sub    $0xc,%esp
80101439:	ff 75 f4             	push   -0xc(%ebp)
8010143c:	e8 ee ed ff ff       	call   8010022f <brelse>
80101441:	83 c4 10             	add    $0x10,%esp
}
80101444:	90                   	nop
80101445:	c9                   	leave  
80101446:	c3                   	ret    

80101447 <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101447:	55                   	push   %ebp
80101448:	89 e5                	mov    %esp,%ebp
8010144a:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
8010144d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101454:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010145b:	e9 0b 01 00 00       	jmp    8010156b <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101460:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101463:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101469:	85 c0                	test   %eax,%eax
8010146b:	0f 48 c2             	cmovs  %edx,%eax
8010146e:	c1 f8 0c             	sar    $0xc,%eax
80101471:	89 c2                	mov    %eax,%edx
80101473:	a1 d8 01 11 80       	mov    0x801101d8,%eax
80101478:	01 d0                	add    %edx,%eax
8010147a:	83 ec 08             	sub    $0x8,%esp
8010147d:	50                   	push   %eax
8010147e:	ff 75 08             	push   0x8(%ebp)
80101481:	e8 31 ed ff ff       	call   801001b7 <bread>
80101486:	83 c4 10             	add    $0x10,%esp
80101489:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010148c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101493:	e9 9e 00 00 00       	jmp    80101536 <balloc+0xef>
      m = 1 << (bi % 8);
80101498:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010149b:	83 e0 07             	and    $0x7,%eax
8010149e:	ba 01 00 00 00       	mov    $0x1,%edx
801014a3:	89 c1                	mov    %eax,%ecx
801014a5:	d3 e2                	shl    %cl,%edx
801014a7:	89 d0                	mov    %edx,%eax
801014a9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014af:	8d 50 07             	lea    0x7(%eax),%edx
801014b2:	85 c0                	test   %eax,%eax
801014b4:	0f 48 c2             	cmovs  %edx,%eax
801014b7:	c1 f8 03             	sar    $0x3,%eax
801014ba:	89 c2                	mov    %eax,%edx
801014bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014bf:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801014c4:	0f b6 c0             	movzbl %al,%eax
801014c7:	23 45 e8             	and    -0x18(%ebp),%eax
801014ca:	85 c0                	test   %eax,%eax
801014cc:	75 64                	jne    80101532 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d1:	8d 50 07             	lea    0x7(%eax),%edx
801014d4:	85 c0                	test   %eax,%eax
801014d6:	0f 48 c2             	cmovs  %edx,%eax
801014d9:	c1 f8 03             	sar    $0x3,%eax
801014dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014df:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014e4:	89 d1                	mov    %edx,%ecx
801014e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014e9:	09 ca                	or     %ecx,%edx
801014eb:	89 d1                	mov    %edx,%ecx
801014ed:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014f0:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014f4:	83 ec 0c             	sub    $0xc,%esp
801014f7:	ff 75 ec             	push   -0x14(%ebp)
801014fa:	e8 b0 22 00 00       	call   801037af <log_write>
801014ff:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101502:	83 ec 0c             	sub    $0xc,%esp
80101505:	ff 75 ec             	push   -0x14(%ebp)
80101508:	e8 22 ed ff ff       	call   8010022f <brelse>
8010150d:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101510:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101513:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101516:	01 c2                	add    %eax,%edx
80101518:	8b 45 08             	mov    0x8(%ebp),%eax
8010151b:	83 ec 08             	sub    $0x8,%esp
8010151e:	52                   	push   %edx
8010151f:	50                   	push   %eax
80101520:	e8 ce fe ff ff       	call   801013f3 <bzero>
80101525:	83 c4 10             	add    $0x10,%esp
        return b + bi;
80101528:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010152b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152e:	01 d0                	add    %edx,%eax
80101530:	eb 57                	jmp    80101589 <balloc+0x142>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101532:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101536:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
8010153d:	7f 17                	jg     80101556 <balloc+0x10f>
8010153f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101542:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101545:	01 d0                	add    %edx,%eax
80101547:	89 c2                	mov    %eax,%edx
80101549:	a1 c0 01 11 80       	mov    0x801101c0,%eax
8010154e:	39 c2                	cmp    %eax,%edx
80101550:	0f 82 42 ff ff ff    	jb     80101498 <balloc+0x51>
      }
    }
    brelse(bp);
80101556:	83 ec 0c             	sub    $0xc,%esp
80101559:	ff 75 ec             	push   -0x14(%ebp)
8010155c:	e8 ce ec ff ff       	call   8010022f <brelse>
80101561:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
80101564:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010156b:	8b 15 c0 01 11 80    	mov    0x801101c0,%edx
80101571:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101574:	39 c2                	cmp    %eax,%edx
80101576:	0f 87 e4 fe ff ff    	ja     80101460 <balloc+0x19>
  }
  panic("balloc: out of blocks");
8010157c:	83 ec 0c             	sub    $0xc,%esp
8010157f:	68 18 88 10 80       	push   $0x80108818
80101584:	e8 f2 ef ff ff       	call   8010057b <panic>
}
80101589:	c9                   	leave  
8010158a:	c3                   	ret    

8010158b <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010158b:	55                   	push   %ebp
8010158c:	89 e5                	mov    %esp,%ebp
8010158e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101591:	83 ec 08             	sub    $0x8,%esp
80101594:	68 c0 01 11 80       	push   $0x801101c0
80101599:	ff 75 08             	push   0x8(%ebp)
8010159c:	e8 10 fe ff ff       	call   801013b1 <readsb>
801015a1:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801015a7:	c1 e8 0c             	shr    $0xc,%eax
801015aa:	89 c2                	mov    %eax,%edx
801015ac:	a1 d8 01 11 80       	mov    0x801101d8,%eax
801015b1:	01 c2                	add    %eax,%edx
801015b3:	8b 45 08             	mov    0x8(%ebp),%eax
801015b6:	83 ec 08             	sub    $0x8,%esp
801015b9:	52                   	push   %edx
801015ba:	50                   	push   %eax
801015bb:	e8 f7 eb ff ff       	call   801001b7 <bread>
801015c0:	83 c4 10             	add    $0x10,%esp
801015c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801015c9:	25 ff 0f 00 00       	and    $0xfff,%eax
801015ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015d4:	83 e0 07             	and    $0x7,%eax
801015d7:	ba 01 00 00 00       	mov    $0x1,%edx
801015dc:	89 c1                	mov    %eax,%ecx
801015de:	d3 e2                	shl    %cl,%edx
801015e0:	89 d0                	mov    %edx,%eax
801015e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015e8:	8d 50 07             	lea    0x7(%eax),%edx
801015eb:	85 c0                	test   %eax,%eax
801015ed:	0f 48 c2             	cmovs  %edx,%eax
801015f0:	c1 f8 03             	sar    $0x3,%eax
801015f3:	89 c2                	mov    %eax,%edx
801015f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015f8:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015fd:	0f b6 c0             	movzbl %al,%eax
80101600:	23 45 ec             	and    -0x14(%ebp),%eax
80101603:	85 c0                	test   %eax,%eax
80101605:	75 0d                	jne    80101614 <bfree+0x89>
    panic("freeing free block");
80101607:	83 ec 0c             	sub    $0xc,%esp
8010160a:	68 2e 88 10 80       	push   $0x8010882e
8010160f:	e8 67 ef ff ff       	call   8010057b <panic>
  bp->data[bi/8] &= ~m;
80101614:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101617:	8d 50 07             	lea    0x7(%eax),%edx
8010161a:	85 c0                	test   %eax,%eax
8010161c:	0f 48 c2             	cmovs  %edx,%eax
8010161f:	c1 f8 03             	sar    $0x3,%eax
80101622:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101625:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
8010162a:	89 d1                	mov    %edx,%ecx
8010162c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010162f:	f7 d2                	not    %edx
80101631:	21 ca                	and    %ecx,%edx
80101633:	89 d1                	mov    %edx,%ecx
80101635:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101638:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
8010163c:	83 ec 0c             	sub    $0xc,%esp
8010163f:	ff 75 f4             	push   -0xc(%ebp)
80101642:	e8 68 21 00 00       	call   801037af <log_write>
80101647:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010164a:	83 ec 0c             	sub    $0xc,%esp
8010164d:	ff 75 f4             	push   -0xc(%ebp)
80101650:	e8 da eb ff ff       	call   8010022f <brelse>
80101655:	83 c4 10             	add    $0x10,%esp
}
80101658:	90                   	nop
80101659:	c9                   	leave  
8010165a:	c3                   	ret    

8010165b <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
8010165b:	55                   	push   %ebp
8010165c:	89 e5                	mov    %esp,%ebp
8010165e:	57                   	push   %edi
8010165f:	56                   	push   %esi
80101660:	53                   	push   %ebx
80101661:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
80101664:	83 ec 08             	sub    $0x8,%esp
80101667:	68 41 88 10 80       	push   $0x80108841
8010166c:	68 e0 01 11 80       	push   $0x801101e0
80101671:	e8 f1 39 00 00       	call   80105067 <initlock>
80101676:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101679:	83 ec 08             	sub    $0x8,%esp
8010167c:	68 c0 01 11 80       	push   $0x801101c0
80101681:	ff 75 08             	push   0x8(%ebp)
80101684:	e8 28 fd ff ff       	call   801013b1 <readsb>
80101689:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
8010168c:	a1 d8 01 11 80       	mov    0x801101d8,%eax
80101691:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101694:	8b 3d d4 01 11 80    	mov    0x801101d4,%edi
8010169a:	8b 35 d0 01 11 80    	mov    0x801101d0,%esi
801016a0:	8b 1d cc 01 11 80    	mov    0x801101cc,%ebx
801016a6:	8b 0d c8 01 11 80    	mov    0x801101c8,%ecx
801016ac:	8b 15 c4 01 11 80    	mov    0x801101c4,%edx
801016b2:	a1 c0 01 11 80       	mov    0x801101c0,%eax
801016b7:	ff 75 e4             	push   -0x1c(%ebp)
801016ba:	57                   	push   %edi
801016bb:	56                   	push   %esi
801016bc:	53                   	push   %ebx
801016bd:	51                   	push   %ecx
801016be:	52                   	push   %edx
801016bf:	50                   	push   %eax
801016c0:	68 48 88 10 80       	push   $0x80108848
801016c5:	e8 fc ec ff ff       	call   801003c6 <cprintf>
801016ca:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
801016cd:	90                   	nop
801016ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016d1:	5b                   	pop    %ebx
801016d2:	5e                   	pop    %esi
801016d3:	5f                   	pop    %edi
801016d4:	5d                   	pop    %ebp
801016d5:	c3                   	ret    

801016d6 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
801016d6:	55                   	push   %ebp
801016d7:	89 e5                	mov    %esp,%ebp
801016d9:	83 ec 28             	sub    $0x28,%esp
801016dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801016df:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016e3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016ea:	e9 9e 00 00 00       	jmp    8010178d <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f2:	c1 e8 03             	shr    $0x3,%eax
801016f5:	89 c2                	mov    %eax,%edx
801016f7:	a1 d4 01 11 80       	mov    0x801101d4,%eax
801016fc:	01 d0                	add    %edx,%eax
801016fe:	83 ec 08             	sub    $0x8,%esp
80101701:	50                   	push   %eax
80101702:	ff 75 08             	push   0x8(%ebp)
80101705:	e8 ad ea ff ff       	call   801001b7 <bread>
8010170a:	83 c4 10             	add    $0x10,%esp
8010170d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101713:	8d 50 18             	lea    0x18(%eax),%edx
80101716:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101719:	83 e0 07             	and    $0x7,%eax
8010171c:	c1 e0 06             	shl    $0x6,%eax
8010171f:	01 d0                	add    %edx,%eax
80101721:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101724:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101727:	0f b7 00             	movzwl (%eax),%eax
8010172a:	66 85 c0             	test   %ax,%ax
8010172d:	75 4c                	jne    8010177b <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
8010172f:	83 ec 04             	sub    $0x4,%esp
80101732:	6a 40                	push   $0x40
80101734:	6a 00                	push   $0x0
80101736:	ff 75 ec             	push   -0x14(%ebp)
80101739:	e8 ae 3b 00 00       	call   801052ec <memset>
8010173e:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101741:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101744:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101748:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
8010174b:	83 ec 0c             	sub    $0xc,%esp
8010174e:	ff 75 f0             	push   -0x10(%ebp)
80101751:	e8 59 20 00 00       	call   801037af <log_write>
80101756:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101759:	83 ec 0c             	sub    $0xc,%esp
8010175c:	ff 75 f0             	push   -0x10(%ebp)
8010175f:	e8 cb ea ff ff       	call   8010022f <brelse>
80101764:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
80101767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010176a:	83 ec 08             	sub    $0x8,%esp
8010176d:	50                   	push   %eax
8010176e:	ff 75 08             	push   0x8(%ebp)
80101771:	e8 f8 00 00 00       	call   8010186e <iget>
80101776:	83 c4 10             	add    $0x10,%esp
80101779:	eb 30                	jmp    801017ab <ialloc+0xd5>
    }
    brelse(bp);
8010177b:	83 ec 0c             	sub    $0xc,%esp
8010177e:	ff 75 f0             	push   -0x10(%ebp)
80101781:	e8 a9 ea ff ff       	call   8010022f <brelse>
80101786:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101789:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010178d:	8b 15 c8 01 11 80    	mov    0x801101c8,%edx
80101793:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101796:	39 c2                	cmp    %eax,%edx
80101798:	0f 87 51 ff ff ff    	ja     801016ef <ialloc+0x19>
  }
  panic("ialloc: no inodes");
8010179e:	83 ec 0c             	sub    $0xc,%esp
801017a1:	68 9b 88 10 80       	push   $0x8010889b
801017a6:	e8 d0 ed ff ff       	call   8010057b <panic>
}
801017ab:	c9                   	leave  
801017ac:	c3                   	ret    

801017ad <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
801017ad:	55                   	push   %ebp
801017ae:	89 e5                	mov    %esp,%ebp
801017b0:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017b3:	8b 45 08             	mov    0x8(%ebp),%eax
801017b6:	8b 40 04             	mov    0x4(%eax),%eax
801017b9:	c1 e8 03             	shr    $0x3,%eax
801017bc:	89 c2                	mov    %eax,%edx
801017be:	a1 d4 01 11 80       	mov    0x801101d4,%eax
801017c3:	01 c2                	add    %eax,%edx
801017c5:	8b 45 08             	mov    0x8(%ebp),%eax
801017c8:	8b 00                	mov    (%eax),%eax
801017ca:	83 ec 08             	sub    $0x8,%esp
801017cd:	52                   	push   %edx
801017ce:	50                   	push   %eax
801017cf:	e8 e3 e9 ff ff       	call   801001b7 <bread>
801017d4:	83 c4 10             	add    $0x10,%esp
801017d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017dd:	8d 50 18             	lea    0x18(%eax),%edx
801017e0:	8b 45 08             	mov    0x8(%ebp),%eax
801017e3:	8b 40 04             	mov    0x4(%eax),%eax
801017e6:	83 e0 07             	and    $0x7,%eax
801017e9:	c1 e0 06             	shl    $0x6,%eax
801017ec:	01 d0                	add    %edx,%eax
801017ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017f1:	8b 45 08             	mov    0x8(%ebp),%eax
801017f4:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017fb:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101801:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101805:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101808:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010180c:	8b 45 08             	mov    0x8(%ebp),%eax
8010180f:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101816:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010181a:	8b 45 08             	mov    0x8(%ebp),%eax
8010181d:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101821:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101824:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101828:	8b 45 08             	mov    0x8(%ebp),%eax
8010182b:	8b 50 18             	mov    0x18(%eax),%edx
8010182e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101831:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101834:	8b 45 08             	mov    0x8(%ebp),%eax
80101837:	8d 50 1c             	lea    0x1c(%eax),%edx
8010183a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183d:	83 c0 0c             	add    $0xc,%eax
80101840:	83 ec 04             	sub    $0x4,%esp
80101843:	6a 34                	push   $0x34
80101845:	52                   	push   %edx
80101846:	50                   	push   %eax
80101847:	e8 5f 3b 00 00       	call   801053ab <memmove>
8010184c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010184f:	83 ec 0c             	sub    $0xc,%esp
80101852:	ff 75 f4             	push   -0xc(%ebp)
80101855:	e8 55 1f 00 00       	call   801037af <log_write>
8010185a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010185d:	83 ec 0c             	sub    $0xc,%esp
80101860:	ff 75 f4             	push   -0xc(%ebp)
80101863:	e8 c7 e9 ff ff       	call   8010022f <brelse>
80101868:	83 c4 10             	add    $0x10,%esp
}
8010186b:	90                   	nop
8010186c:	c9                   	leave  
8010186d:	c3                   	ret    

8010186e <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010186e:	55                   	push   %ebp
8010186f:	89 e5                	mov    %esp,%ebp
80101871:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101874:	83 ec 0c             	sub    $0xc,%esp
80101877:	68 e0 01 11 80       	push   $0x801101e0
8010187c:	e8 08 38 00 00       	call   80105089 <acquire>
80101881:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101884:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010188b:	c7 45 f4 14 02 11 80 	movl   $0x80110214,-0xc(%ebp)
80101892:	eb 5d                	jmp    801018f1 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101897:	8b 40 08             	mov    0x8(%eax),%eax
8010189a:	85 c0                	test   %eax,%eax
8010189c:	7e 39                	jle    801018d7 <iget+0x69>
8010189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a1:	8b 00                	mov    (%eax),%eax
801018a3:	39 45 08             	cmp    %eax,0x8(%ebp)
801018a6:	75 2f                	jne    801018d7 <iget+0x69>
801018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ab:	8b 40 04             	mov    0x4(%eax),%eax
801018ae:	39 45 0c             	cmp    %eax,0xc(%ebp)
801018b1:	75 24                	jne    801018d7 <iget+0x69>
      ip->ref++;
801018b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b6:	8b 40 08             	mov    0x8(%eax),%eax
801018b9:	8d 50 01             	lea    0x1(%eax),%edx
801018bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018bf:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801018c2:	83 ec 0c             	sub    $0xc,%esp
801018c5:	68 e0 01 11 80       	push   $0x801101e0
801018ca:	e8 21 38 00 00       	call   801050f0 <release>
801018cf:	83 c4 10             	add    $0x10,%esp
      return ip;
801018d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018d5:	eb 74                	jmp    8010194b <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801018d7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018db:	75 10                	jne    801018ed <iget+0x7f>
801018dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e0:	8b 40 08             	mov    0x8(%eax),%eax
801018e3:	85 c0                	test   %eax,%eax
801018e5:	75 06                	jne    801018ed <iget+0x7f>
      empty = ip;
801018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018ed:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018f1:	81 7d f4 b4 11 11 80 	cmpl   $0x801111b4,-0xc(%ebp)
801018f8:	72 9a                	jb     80101894 <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018fa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018fe:	75 0d                	jne    8010190d <iget+0x9f>
    panic("iget: no inodes");
80101900:	83 ec 0c             	sub    $0xc,%esp
80101903:	68 ad 88 10 80       	push   $0x801088ad
80101908:	e8 6e ec ff ff       	call   8010057b <panic>

  ip = empty;
8010190d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101910:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101913:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101916:	8b 55 08             	mov    0x8(%ebp),%edx
80101919:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101921:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
8010192e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101931:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101938:	83 ec 0c             	sub    $0xc,%esp
8010193b:	68 e0 01 11 80       	push   $0x801101e0
80101940:	e8 ab 37 00 00       	call   801050f0 <release>
80101945:	83 c4 10             	add    $0x10,%esp

  return ip;
80101948:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010194b:	c9                   	leave  
8010194c:	c3                   	ret    

8010194d <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
8010194d:	55                   	push   %ebp
8010194e:	89 e5                	mov    %esp,%ebp
80101950:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101953:	83 ec 0c             	sub    $0xc,%esp
80101956:	68 e0 01 11 80       	push   $0x801101e0
8010195b:	e8 29 37 00 00       	call   80105089 <acquire>
80101960:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
80101963:	8b 45 08             	mov    0x8(%ebp),%eax
80101966:	8b 40 08             	mov    0x8(%eax),%eax
80101969:	8d 50 01             	lea    0x1(%eax),%edx
8010196c:	8b 45 08             	mov    0x8(%ebp),%eax
8010196f:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101972:	83 ec 0c             	sub    $0xc,%esp
80101975:	68 e0 01 11 80       	push   $0x801101e0
8010197a:	e8 71 37 00 00       	call   801050f0 <release>
8010197f:	83 c4 10             	add    $0x10,%esp
  return ip;
80101982:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101985:	c9                   	leave  
80101986:	c3                   	ret    

80101987 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101987:	55                   	push   %ebp
80101988:	89 e5                	mov    %esp,%ebp
8010198a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
8010198d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101991:	74 0a                	je     8010199d <ilock+0x16>
80101993:	8b 45 08             	mov    0x8(%ebp),%eax
80101996:	8b 40 08             	mov    0x8(%eax),%eax
80101999:	85 c0                	test   %eax,%eax
8010199b:	7f 0d                	jg     801019aa <ilock+0x23>
    panic("ilock");
8010199d:	83 ec 0c             	sub    $0xc,%esp
801019a0:	68 bd 88 10 80       	push   $0x801088bd
801019a5:	e8 d1 eb ff ff       	call   8010057b <panic>

  acquire(&icache.lock);
801019aa:	83 ec 0c             	sub    $0xc,%esp
801019ad:	68 e0 01 11 80       	push   $0x801101e0
801019b2:	e8 d2 36 00 00       	call   80105089 <acquire>
801019b7:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019ba:	eb 13                	jmp    801019cf <ilock+0x48>
    sleep(ip, &icache.lock);
801019bc:	83 ec 08             	sub    $0x8,%esp
801019bf:	68 e0 01 11 80       	push   $0x801101e0
801019c4:	ff 75 08             	push   0x8(%ebp)
801019c7:	e8 c2 33 00 00       	call   80104d8e <sleep>
801019cc:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
801019cf:	8b 45 08             	mov    0x8(%ebp),%eax
801019d2:	8b 40 0c             	mov    0xc(%eax),%eax
801019d5:	83 e0 01             	and    $0x1,%eax
801019d8:	85 c0                	test   %eax,%eax
801019da:	75 e0                	jne    801019bc <ilock+0x35>
  ip->flags |= I_BUSY;
801019dc:	8b 45 08             	mov    0x8(%ebp),%eax
801019df:	8b 40 0c             	mov    0xc(%eax),%eax
801019e2:	83 c8 01             	or     $0x1,%eax
801019e5:	89 c2                	mov    %eax,%edx
801019e7:	8b 45 08             	mov    0x8(%ebp),%eax
801019ea:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019ed:	83 ec 0c             	sub    $0xc,%esp
801019f0:	68 e0 01 11 80       	push   $0x801101e0
801019f5:	e8 f6 36 00 00       	call   801050f0 <release>
801019fa:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019fd:	8b 45 08             	mov    0x8(%ebp),%eax
80101a00:	8b 40 0c             	mov    0xc(%eax),%eax
80101a03:	83 e0 02             	and    $0x2,%eax
80101a06:	85 c0                	test   %eax,%eax
80101a08:	0f 85 d4 00 00 00    	jne    80101ae2 <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a11:	8b 40 04             	mov    0x4(%eax),%eax
80101a14:	c1 e8 03             	shr    $0x3,%eax
80101a17:	89 c2                	mov    %eax,%edx
80101a19:	a1 d4 01 11 80       	mov    0x801101d4,%eax
80101a1e:	01 c2                	add    %eax,%edx
80101a20:	8b 45 08             	mov    0x8(%ebp),%eax
80101a23:	8b 00                	mov    (%eax),%eax
80101a25:	83 ec 08             	sub    $0x8,%esp
80101a28:	52                   	push   %edx
80101a29:	50                   	push   %eax
80101a2a:	e8 88 e7 ff ff       	call   801001b7 <bread>
80101a2f:	83 c4 10             	add    $0x10,%esp
80101a32:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a38:	8d 50 18             	lea    0x18(%eax),%edx
80101a3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a3e:	8b 40 04             	mov    0x4(%eax),%eax
80101a41:	83 e0 07             	and    $0x7,%eax
80101a44:	c1 e0 06             	shl    $0x6,%eax
80101a47:	01 d0                	add    %edx,%eax
80101a49:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4f:	0f b7 10             	movzwl (%eax),%edx
80101a52:	8b 45 08             	mov    0x8(%ebp),%eax
80101a55:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5c:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a60:	8b 45 08             	mov    0x8(%ebp),%eax
80101a63:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a6a:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a71:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a78:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7f:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a86:	8b 50 08             	mov    0x8(%eax),%edx
80101a89:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8c:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a92:	8d 50 0c             	lea    0xc(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	83 c0 1c             	add    $0x1c,%eax
80101a9b:	83 ec 04             	sub    $0x4,%esp
80101a9e:	6a 34                	push   $0x34
80101aa0:	52                   	push   %edx
80101aa1:	50                   	push   %eax
80101aa2:	e8 04 39 00 00       	call   801053ab <memmove>
80101aa7:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101aaa:	83 ec 0c             	sub    $0xc,%esp
80101aad:	ff 75 f4             	push   -0xc(%ebp)
80101ab0:	e8 7a e7 ff ff       	call   8010022f <brelse>
80101ab5:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80101abb:	8b 40 0c             	mov    0xc(%eax),%eax
80101abe:	83 c8 02             	or     $0x2,%eax
80101ac1:	89 c2                	mov    %eax,%edx
80101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac6:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101ac9:	8b 45 08             	mov    0x8(%ebp),%eax
80101acc:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101ad0:	66 85 c0             	test   %ax,%ax
80101ad3:	75 0d                	jne    80101ae2 <ilock+0x15b>
      panic("ilock: no type");
80101ad5:	83 ec 0c             	sub    $0xc,%esp
80101ad8:	68 c3 88 10 80       	push   $0x801088c3
80101add:	e8 99 ea ff ff       	call   8010057b <panic>
  }
}
80101ae2:	90                   	nop
80101ae3:	c9                   	leave  
80101ae4:	c3                   	ret    

80101ae5 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ae5:	55                   	push   %ebp
80101ae6:	89 e5                	mov    %esp,%ebp
80101ae8:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101aeb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aef:	74 17                	je     80101b08 <iunlock+0x23>
80101af1:	8b 45 08             	mov    0x8(%ebp),%eax
80101af4:	8b 40 0c             	mov    0xc(%eax),%eax
80101af7:	83 e0 01             	and    $0x1,%eax
80101afa:	85 c0                	test   %eax,%eax
80101afc:	74 0a                	je     80101b08 <iunlock+0x23>
80101afe:	8b 45 08             	mov    0x8(%ebp),%eax
80101b01:	8b 40 08             	mov    0x8(%eax),%eax
80101b04:	85 c0                	test   %eax,%eax
80101b06:	7f 0d                	jg     80101b15 <iunlock+0x30>
    panic("iunlock");
80101b08:	83 ec 0c             	sub    $0xc,%esp
80101b0b:	68 d2 88 10 80       	push   $0x801088d2
80101b10:	e8 66 ea ff ff       	call   8010057b <panic>

  acquire(&icache.lock);
80101b15:	83 ec 0c             	sub    $0xc,%esp
80101b18:	68 e0 01 11 80       	push   $0x801101e0
80101b1d:	e8 67 35 00 00       	call   80105089 <acquire>
80101b22:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101b25:	8b 45 08             	mov    0x8(%ebp),%eax
80101b28:	8b 40 0c             	mov    0xc(%eax),%eax
80101b2b:	83 e0 fe             	and    $0xfffffffe,%eax
80101b2e:	89 c2                	mov    %eax,%edx
80101b30:	8b 45 08             	mov    0x8(%ebp),%eax
80101b33:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101b36:	83 ec 0c             	sub    $0xc,%esp
80101b39:	ff 75 08             	push   0x8(%ebp)
80101b3c:	e8 39 33 00 00       	call   80104e7a <wakeup>
80101b41:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	68 e0 01 11 80       	push   $0x801101e0
80101b4c:	e8 9f 35 00 00       	call   801050f0 <release>
80101b51:	83 c4 10             	add    $0x10,%esp
}
80101b54:	90                   	nop
80101b55:	c9                   	leave  
80101b56:	c3                   	ret    

80101b57 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b57:	55                   	push   %ebp
80101b58:	89 e5                	mov    %esp,%ebp
80101b5a:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b5d:	83 ec 0c             	sub    $0xc,%esp
80101b60:	68 e0 01 11 80       	push   $0x801101e0
80101b65:	e8 1f 35 00 00       	call   80105089 <acquire>
80101b6a:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b70:	8b 40 08             	mov    0x8(%eax),%eax
80101b73:	83 f8 01             	cmp    $0x1,%eax
80101b76:	0f 85 a9 00 00 00    	jne    80101c25 <iput+0xce>
80101b7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7f:	8b 40 0c             	mov    0xc(%eax),%eax
80101b82:	83 e0 02             	and    $0x2,%eax
80101b85:	85 c0                	test   %eax,%eax
80101b87:	0f 84 98 00 00 00    	je     80101c25 <iput+0xce>
80101b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b90:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b94:	66 85 c0             	test   %ax,%ax
80101b97:	0f 85 88 00 00 00    	jne    80101c25 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b9d:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba0:	8b 40 0c             	mov    0xc(%eax),%eax
80101ba3:	83 e0 01             	and    $0x1,%eax
80101ba6:	85 c0                	test   %eax,%eax
80101ba8:	74 0d                	je     80101bb7 <iput+0x60>
      panic("iput busy");
80101baa:	83 ec 0c             	sub    $0xc,%esp
80101bad:	68 da 88 10 80       	push   $0x801088da
80101bb2:	e8 c4 e9 ff ff       	call   8010057b <panic>
    ip->flags |= I_BUSY;
80101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bba:	8b 40 0c             	mov    0xc(%eax),%eax
80101bbd:	83 c8 01             	or     $0x1,%eax
80101bc0:	89 c2                	mov    %eax,%edx
80101bc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc5:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101bc8:	83 ec 0c             	sub    $0xc,%esp
80101bcb:	68 e0 01 11 80       	push   $0x801101e0
80101bd0:	e8 1b 35 00 00       	call   801050f0 <release>
80101bd5:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101bd8:	83 ec 0c             	sub    $0xc,%esp
80101bdb:	ff 75 08             	push   0x8(%ebp)
80101bde:	e8 a3 01 00 00       	call   80101d86 <itrunc>
80101be3:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101be6:	8b 45 08             	mov    0x8(%ebp),%eax
80101be9:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bef:	83 ec 0c             	sub    $0xc,%esp
80101bf2:	ff 75 08             	push   0x8(%ebp)
80101bf5:	e8 b3 fb ff ff       	call   801017ad <iupdate>
80101bfa:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bfd:	83 ec 0c             	sub    $0xc,%esp
80101c00:	68 e0 01 11 80       	push   $0x801101e0
80101c05:	e8 7f 34 00 00       	call   80105089 <acquire>
80101c0a:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101c17:	83 ec 0c             	sub    $0xc,%esp
80101c1a:	ff 75 08             	push   0x8(%ebp)
80101c1d:	e8 58 32 00 00       	call   80104e7a <wakeup>
80101c22:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101c25:	8b 45 08             	mov    0x8(%ebp),%eax
80101c28:	8b 40 08             	mov    0x8(%eax),%eax
80101c2b:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c31:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c34:	83 ec 0c             	sub    $0xc,%esp
80101c37:	68 e0 01 11 80       	push   $0x801101e0
80101c3c:	e8 af 34 00 00       	call   801050f0 <release>
80101c41:	83 c4 10             	add    $0x10,%esp
}
80101c44:	90                   	nop
80101c45:	c9                   	leave  
80101c46:	c3                   	ret    

80101c47 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c47:	55                   	push   %ebp
80101c48:	89 e5                	mov    %esp,%ebp
80101c4a:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c4d:	83 ec 0c             	sub    $0xc,%esp
80101c50:	ff 75 08             	push   0x8(%ebp)
80101c53:	e8 8d fe ff ff       	call   80101ae5 <iunlock>
80101c58:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c5b:	83 ec 0c             	sub    $0xc,%esp
80101c5e:	ff 75 08             	push   0x8(%ebp)
80101c61:	e8 f1 fe ff ff       	call   80101b57 <iput>
80101c66:	83 c4 10             	add    $0x10,%esp
}
80101c69:	90                   	nop
80101c6a:	c9                   	leave  
80101c6b:	c3                   	ret    

80101c6c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c6c:	55                   	push   %ebp
80101c6d:	89 e5                	mov    %esp,%ebp
80101c6f:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c72:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c76:	77 42                	ja     80101cba <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c78:	8b 45 08             	mov    0x8(%ebp),%eax
80101c7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7e:	83 c2 04             	add    $0x4,%edx
80101c81:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c85:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c88:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c8c:	75 24                	jne    80101cb2 <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c91:	8b 00                	mov    (%eax),%eax
80101c93:	83 ec 0c             	sub    $0xc,%esp
80101c96:	50                   	push   %eax
80101c97:	e8 ab f7 ff ff       	call   80101447 <balloc>
80101c9c:	83 c4 10             	add    $0x10,%esp
80101c9f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca5:	8b 55 0c             	mov    0xc(%ebp),%edx
80101ca8:	8d 4a 04             	lea    0x4(%edx),%ecx
80101cab:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cae:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cb5:	e9 ca 00 00 00       	jmp    80101d84 <bmap+0x118>
  }
  bn -= NDIRECT;
80101cba:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101cbe:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101cc2:	0f 87 af 00 00 00    	ja     80101d77 <bmap+0x10b>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccb:	8b 40 4c             	mov    0x4c(%eax),%eax
80101cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cd5:	75 1d                	jne    80101cf4 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80101cda:	8b 00                	mov    (%eax),%eax
80101cdc:	83 ec 0c             	sub    $0xc,%esp
80101cdf:	50                   	push   %eax
80101ce0:	e8 62 f7 ff ff       	call   80101447 <balloc>
80101ce5:	83 c4 10             	add    $0x10,%esp
80101ce8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80101cee:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cf1:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cf4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf7:	8b 00                	mov    (%eax),%eax
80101cf9:	83 ec 08             	sub    $0x8,%esp
80101cfc:	ff 75 f4             	push   -0xc(%ebp)
80101cff:	50                   	push   %eax
80101d00:	e8 b2 e4 ff ff       	call   801001b7 <bread>
80101d05:	83 c4 10             	add    $0x10,%esp
80101d08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d0e:	83 c0 18             	add    $0x18,%eax
80101d11:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d14:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d17:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d21:	01 d0                	add    %edx,%eax
80101d23:	8b 00                	mov    (%eax),%eax
80101d25:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d28:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d2c:	75 36                	jne    80101d64 <bmap+0xf8>
      a[bn] = addr = balloc(ip->dev);
80101d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80101d31:	8b 00                	mov    (%eax),%eax
80101d33:	83 ec 0c             	sub    $0xc,%esp
80101d36:	50                   	push   %eax
80101d37:	e8 0b f7 ff ff       	call   80101447 <balloc>
80101d3c:	83 c4 10             	add    $0x10,%esp
80101d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d42:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d45:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d4f:	01 c2                	add    %eax,%edx
80101d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d54:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d56:	83 ec 0c             	sub    $0xc,%esp
80101d59:	ff 75 f0             	push   -0x10(%ebp)
80101d5c:	e8 4e 1a 00 00       	call   801037af <log_write>
80101d61:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d64:	83 ec 0c             	sub    $0xc,%esp
80101d67:	ff 75 f0             	push   -0x10(%ebp)
80101d6a:	e8 c0 e4 ff ff       	call   8010022f <brelse>
80101d6f:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d75:	eb 0d                	jmp    80101d84 <bmap+0x118>
  }

  panic("bmap: out of range");
80101d77:	83 ec 0c             	sub    $0xc,%esp
80101d7a:	68 e4 88 10 80       	push   $0x801088e4
80101d7f:	e8 f7 e7 ff ff       	call   8010057b <panic>
}
80101d84:	c9                   	leave  
80101d85:	c3                   	ret    

80101d86 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d86:	55                   	push   %ebp
80101d87:	89 e5                	mov    %esp,%ebp
80101d89:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d8c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d93:	eb 45                	jmp    80101dda <itrunc+0x54>
    if(ip->addrs[i]){
80101d95:	8b 45 08             	mov    0x8(%ebp),%eax
80101d98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9b:	83 c2 04             	add    $0x4,%edx
80101d9e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101da2:	85 c0                	test   %eax,%eax
80101da4:	74 30                	je     80101dd6 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101da6:	8b 45 08             	mov    0x8(%ebp),%eax
80101da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dac:	83 c2 04             	add    $0x4,%edx
80101daf:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101db3:	8b 55 08             	mov    0x8(%ebp),%edx
80101db6:	8b 12                	mov    (%edx),%edx
80101db8:	83 ec 08             	sub    $0x8,%esp
80101dbb:	50                   	push   %eax
80101dbc:	52                   	push   %edx
80101dbd:	e8 c9 f7 ff ff       	call   8010158b <bfree>
80101dc2:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101dc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dcb:	83 c2 04             	add    $0x4,%edx
80101dce:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101dd5:	00 
  for(i = 0; i < NDIRECT; i++){
80101dd6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dda:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dde:	7e b5                	jle    80101d95 <itrunc+0xf>
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101de0:	8b 45 08             	mov    0x8(%ebp),%eax
80101de3:	8b 40 4c             	mov    0x4c(%eax),%eax
80101de6:	85 c0                	test   %eax,%eax
80101de8:	0f 84 a1 00 00 00    	je     80101e8f <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dee:	8b 45 08             	mov    0x8(%ebp),%eax
80101df1:	8b 50 4c             	mov    0x4c(%eax),%edx
80101df4:	8b 45 08             	mov    0x8(%ebp),%eax
80101df7:	8b 00                	mov    (%eax),%eax
80101df9:	83 ec 08             	sub    $0x8,%esp
80101dfc:	52                   	push   %edx
80101dfd:	50                   	push   %eax
80101dfe:	e8 b4 e3 ff ff       	call   801001b7 <bread>
80101e03:	83 c4 10             	add    $0x10,%esp
80101e06:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e0c:	83 c0 18             	add    $0x18,%eax
80101e0f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e12:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e19:	eb 3c                	jmp    80101e57 <itrunc+0xd1>
      if(a[j])
80101e1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e25:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e28:	01 d0                	add    %edx,%eax
80101e2a:	8b 00                	mov    (%eax),%eax
80101e2c:	85 c0                	test   %eax,%eax
80101e2e:	74 23                	je     80101e53 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e3a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e3d:	01 d0                	add    %edx,%eax
80101e3f:	8b 00                	mov    (%eax),%eax
80101e41:	8b 55 08             	mov    0x8(%ebp),%edx
80101e44:	8b 12                	mov    (%edx),%edx
80101e46:	83 ec 08             	sub    $0x8,%esp
80101e49:	50                   	push   %eax
80101e4a:	52                   	push   %edx
80101e4b:	e8 3b f7 ff ff       	call   8010158b <bfree>
80101e50:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e53:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e5a:	83 f8 7f             	cmp    $0x7f,%eax
80101e5d:	76 bc                	jbe    80101e1b <itrunc+0x95>
    }
    brelse(bp);
80101e5f:	83 ec 0c             	sub    $0xc,%esp
80101e62:	ff 75 ec             	push   -0x14(%ebp)
80101e65:	e8 c5 e3 ff ff       	call   8010022f <brelse>
80101e6a:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e70:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e73:	8b 55 08             	mov    0x8(%ebp),%edx
80101e76:	8b 12                	mov    (%edx),%edx
80101e78:	83 ec 08             	sub    $0x8,%esp
80101e7b:	50                   	push   %eax
80101e7c:	52                   	push   %edx
80101e7d:	e8 09 f7 ff ff       	call   8010158b <bfree>
80101e82:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e85:	8b 45 08             	mov    0x8(%ebp),%eax
80101e88:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101e92:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e99:	83 ec 0c             	sub    $0xc,%esp
80101e9c:	ff 75 08             	push   0x8(%ebp)
80101e9f:	e8 09 f9 ff ff       	call   801017ad <iupdate>
80101ea4:	83 c4 10             	add    $0x10,%esp
}
80101ea7:	90                   	nop
80101ea8:	c9                   	leave  
80101ea9:	c3                   	ret    

80101eaa <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101eaa:	55                   	push   %ebp
80101eab:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ead:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb0:	8b 00                	mov    (%eax),%eax
80101eb2:	89 c2                	mov    %eax,%edx
80101eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb7:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101eba:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebd:	8b 50 04             	mov    0x4(%eax),%edx
80101ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ec3:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec9:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed0:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed6:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101eda:	8b 45 0c             	mov    0xc(%ebp),%eax
80101edd:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ee1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee4:	8b 50 18             	mov    0x18(%eax),%edx
80101ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eea:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eed:	90                   	nop
80101eee:	5d                   	pop    %ebp
80101eef:	c3                   	ret    

80101ef0 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ef0:	55                   	push   %ebp
80101ef1:	89 e5                	mov    %esp,%ebp
80101ef3:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ef6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef9:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101efd:	66 83 f8 03          	cmp    $0x3,%ax
80101f01:	75 5c                	jne    80101f5f <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f03:	8b 45 08             	mov    0x8(%ebp),%eax
80101f06:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0a:	66 85 c0             	test   %ax,%ax
80101f0d:	78 20                	js     80101f2f <readi+0x3f>
80101f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f12:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f16:	66 83 f8 09          	cmp    $0x9,%ax
80101f1a:	7f 13                	jg     80101f2f <readi+0x3f>
80101f1c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1f:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f23:	98                   	cwtl   
80101f24:	8b 04 c5 c0 f7 10 80 	mov    -0x7fef0840(,%eax,8),%eax
80101f2b:	85 c0                	test   %eax,%eax
80101f2d:	75 0a                	jne    80101f39 <readi+0x49>
      return -1;
80101f2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f34:	e9 0a 01 00 00       	jmp    80102043 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f39:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3c:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f40:	98                   	cwtl   
80101f41:	8b 04 c5 c0 f7 10 80 	mov    -0x7fef0840(,%eax,8),%eax
80101f48:	8b 55 14             	mov    0x14(%ebp),%edx
80101f4b:	83 ec 04             	sub    $0x4,%esp
80101f4e:	52                   	push   %edx
80101f4f:	ff 75 0c             	push   0xc(%ebp)
80101f52:	ff 75 08             	push   0x8(%ebp)
80101f55:	ff d0                	call   *%eax
80101f57:	83 c4 10             	add    $0x10,%esp
80101f5a:	e9 e4 00 00 00       	jmp    80102043 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f5f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f62:	8b 40 18             	mov    0x18(%eax),%eax
80101f65:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f68:	77 0d                	ja     80101f77 <readi+0x87>
80101f6a:	8b 55 10             	mov    0x10(%ebp),%edx
80101f6d:	8b 45 14             	mov    0x14(%ebp),%eax
80101f70:	01 d0                	add    %edx,%eax
80101f72:	39 45 10             	cmp    %eax,0x10(%ebp)
80101f75:	76 0a                	jbe    80101f81 <readi+0x91>
    return -1;
80101f77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f7c:	e9 c2 00 00 00       	jmp    80102043 <readi+0x153>
  if(off + n > ip->size)
80101f81:	8b 55 10             	mov    0x10(%ebp),%edx
80101f84:	8b 45 14             	mov    0x14(%ebp),%eax
80101f87:	01 c2                	add    %eax,%edx
80101f89:	8b 45 08             	mov    0x8(%ebp),%eax
80101f8c:	8b 40 18             	mov    0x18(%eax),%eax
80101f8f:	39 c2                	cmp    %eax,%edx
80101f91:	76 0c                	jbe    80101f9f <readi+0xaf>
    n = ip->size - off;
80101f93:	8b 45 08             	mov    0x8(%ebp),%eax
80101f96:	8b 40 18             	mov    0x18(%eax),%eax
80101f99:	2b 45 10             	sub    0x10(%ebp),%eax
80101f9c:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f9f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fa6:	e9 89 00 00 00       	jmp    80102034 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101fab:	8b 45 10             	mov    0x10(%ebp),%eax
80101fae:	c1 e8 09             	shr    $0x9,%eax
80101fb1:	83 ec 08             	sub    $0x8,%esp
80101fb4:	50                   	push   %eax
80101fb5:	ff 75 08             	push   0x8(%ebp)
80101fb8:	e8 af fc ff ff       	call   80101c6c <bmap>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	8b 55 08             	mov    0x8(%ebp),%edx
80101fc3:	8b 12                	mov    (%edx),%edx
80101fc5:	83 ec 08             	sub    $0x8,%esp
80101fc8:	50                   	push   %eax
80101fc9:	52                   	push   %edx
80101fca:	e8 e8 e1 ff ff       	call   801001b7 <bread>
80101fcf:	83 c4 10             	add    $0x10,%esp
80101fd2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fd5:	8b 45 10             	mov    0x10(%ebp),%eax
80101fd8:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fdd:	ba 00 02 00 00       	mov    $0x200,%edx
80101fe2:	29 c2                	sub    %eax,%edx
80101fe4:	8b 45 14             	mov    0x14(%ebp),%eax
80101fe7:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fea:	39 c2                	cmp    %eax,%edx
80101fec:	0f 46 c2             	cmovbe %edx,%eax
80101fef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101ff2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff5:	8d 50 18             	lea    0x18(%eax),%edx
80101ff8:	8b 45 10             	mov    0x10(%ebp),%eax
80101ffb:	25 ff 01 00 00       	and    $0x1ff,%eax
80102000:	01 d0                	add    %edx,%eax
80102002:	83 ec 04             	sub    $0x4,%esp
80102005:	ff 75 ec             	push   -0x14(%ebp)
80102008:	50                   	push   %eax
80102009:	ff 75 0c             	push   0xc(%ebp)
8010200c:	e8 9a 33 00 00       	call   801053ab <memmove>
80102011:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102014:	83 ec 0c             	sub    $0xc,%esp
80102017:	ff 75 f0             	push   -0x10(%ebp)
8010201a:	e8 10 e2 ff ff       	call   8010022f <brelse>
8010201f:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102022:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102025:	01 45 f4             	add    %eax,-0xc(%ebp)
80102028:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010202b:	01 45 10             	add    %eax,0x10(%ebp)
8010202e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102031:	01 45 0c             	add    %eax,0xc(%ebp)
80102034:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102037:	3b 45 14             	cmp    0x14(%ebp),%eax
8010203a:	0f 82 6b ff ff ff    	jb     80101fab <readi+0xbb>
  }
  return n;
80102040:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102043:	c9                   	leave  
80102044:	c3                   	ret    

80102045 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102045:	55                   	push   %ebp
80102046:	89 e5                	mov    %esp,%ebp
80102048:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010204b:	8b 45 08             	mov    0x8(%ebp),%eax
8010204e:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102052:	66 83 f8 03          	cmp    $0x3,%ax
80102056:	75 5c                	jne    801020b4 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102058:	8b 45 08             	mov    0x8(%ebp),%eax
8010205b:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010205f:	66 85 c0             	test   %ax,%ax
80102062:	78 20                	js     80102084 <writei+0x3f>
80102064:	8b 45 08             	mov    0x8(%ebp),%eax
80102067:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010206b:	66 83 f8 09          	cmp    $0x9,%ax
8010206f:	7f 13                	jg     80102084 <writei+0x3f>
80102071:	8b 45 08             	mov    0x8(%ebp),%eax
80102074:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102078:	98                   	cwtl   
80102079:	8b 04 c5 c4 f7 10 80 	mov    -0x7fef083c(,%eax,8),%eax
80102080:	85 c0                	test   %eax,%eax
80102082:	75 0a                	jne    8010208e <writei+0x49>
      return -1;
80102084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102089:	e9 3b 01 00 00       	jmp    801021c9 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010208e:	8b 45 08             	mov    0x8(%ebp),%eax
80102091:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102095:	98                   	cwtl   
80102096:	8b 04 c5 c4 f7 10 80 	mov    -0x7fef083c(,%eax,8),%eax
8010209d:	8b 55 14             	mov    0x14(%ebp),%edx
801020a0:	83 ec 04             	sub    $0x4,%esp
801020a3:	52                   	push   %edx
801020a4:	ff 75 0c             	push   0xc(%ebp)
801020a7:	ff 75 08             	push   0x8(%ebp)
801020aa:	ff d0                	call   *%eax
801020ac:	83 c4 10             	add    $0x10,%esp
801020af:	e9 15 01 00 00       	jmp    801021c9 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020b4:	8b 45 08             	mov    0x8(%ebp),%eax
801020b7:	8b 40 18             	mov    0x18(%eax),%eax
801020ba:	39 45 10             	cmp    %eax,0x10(%ebp)
801020bd:	77 0d                	ja     801020cc <writei+0x87>
801020bf:	8b 55 10             	mov    0x10(%ebp),%edx
801020c2:	8b 45 14             	mov    0x14(%ebp),%eax
801020c5:	01 d0                	add    %edx,%eax
801020c7:	39 45 10             	cmp    %eax,0x10(%ebp)
801020ca:	76 0a                	jbe    801020d6 <writei+0x91>
    return -1;
801020cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d1:	e9 f3 00 00 00       	jmp    801021c9 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020d6:	8b 55 10             	mov    0x10(%ebp),%edx
801020d9:	8b 45 14             	mov    0x14(%ebp),%eax
801020dc:	01 d0                	add    %edx,%eax
801020de:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020e3:	76 0a                	jbe    801020ef <writei+0xaa>
    return -1;
801020e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020ea:	e9 da 00 00 00       	jmp    801021c9 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020f6:	e9 97 00 00 00       	jmp    80102192 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020fb:	8b 45 10             	mov    0x10(%ebp),%eax
801020fe:	c1 e8 09             	shr    $0x9,%eax
80102101:	83 ec 08             	sub    $0x8,%esp
80102104:	50                   	push   %eax
80102105:	ff 75 08             	push   0x8(%ebp)
80102108:	e8 5f fb ff ff       	call   80101c6c <bmap>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	8b 55 08             	mov    0x8(%ebp),%edx
80102113:	8b 12                	mov    (%edx),%edx
80102115:	83 ec 08             	sub    $0x8,%esp
80102118:	50                   	push   %eax
80102119:	52                   	push   %edx
8010211a:	e8 98 e0 ff ff       	call   801001b7 <bread>
8010211f:	83 c4 10             	add    $0x10,%esp
80102122:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102125:	8b 45 10             	mov    0x10(%ebp),%eax
80102128:	25 ff 01 00 00       	and    $0x1ff,%eax
8010212d:	ba 00 02 00 00       	mov    $0x200,%edx
80102132:	29 c2                	sub    %eax,%edx
80102134:	8b 45 14             	mov    0x14(%ebp),%eax
80102137:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010213a:	39 c2                	cmp    %eax,%edx
8010213c:	0f 46 c2             	cmovbe %edx,%eax
8010213f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102142:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102145:	8d 50 18             	lea    0x18(%eax),%edx
80102148:	8b 45 10             	mov    0x10(%ebp),%eax
8010214b:	25 ff 01 00 00       	and    $0x1ff,%eax
80102150:	01 d0                	add    %edx,%eax
80102152:	83 ec 04             	sub    $0x4,%esp
80102155:	ff 75 ec             	push   -0x14(%ebp)
80102158:	ff 75 0c             	push   0xc(%ebp)
8010215b:	50                   	push   %eax
8010215c:	e8 4a 32 00 00       	call   801053ab <memmove>
80102161:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102164:	83 ec 0c             	sub    $0xc,%esp
80102167:	ff 75 f0             	push   -0x10(%ebp)
8010216a:	e8 40 16 00 00       	call   801037af <log_write>
8010216f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102172:	83 ec 0c             	sub    $0xc,%esp
80102175:	ff 75 f0             	push   -0x10(%ebp)
80102178:	e8 b2 e0 ff ff       	call   8010022f <brelse>
8010217d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102180:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102183:	01 45 f4             	add    %eax,-0xc(%ebp)
80102186:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102189:	01 45 10             	add    %eax,0x10(%ebp)
8010218c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010218f:	01 45 0c             	add    %eax,0xc(%ebp)
80102192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102195:	3b 45 14             	cmp    0x14(%ebp),%eax
80102198:	0f 82 5d ff ff ff    	jb     801020fb <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010219e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801021a2:	74 22                	je     801021c6 <writei+0x181>
801021a4:	8b 45 08             	mov    0x8(%ebp),%eax
801021a7:	8b 40 18             	mov    0x18(%eax),%eax
801021aa:	39 45 10             	cmp    %eax,0x10(%ebp)
801021ad:	76 17                	jbe    801021c6 <writei+0x181>
    ip->size = off;
801021af:	8b 45 08             	mov    0x8(%ebp),%eax
801021b2:	8b 55 10             	mov    0x10(%ebp),%edx
801021b5:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
801021b8:	83 ec 0c             	sub    $0xc,%esp
801021bb:	ff 75 08             	push   0x8(%ebp)
801021be:	e8 ea f5 ff ff       	call   801017ad <iupdate>
801021c3:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021c6:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021c9:	c9                   	leave  
801021ca:	c3                   	ret    

801021cb <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021cb:	55                   	push   %ebp
801021cc:	89 e5                	mov    %esp,%ebp
801021ce:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021d1:	83 ec 04             	sub    $0x4,%esp
801021d4:	6a 0e                	push   $0xe
801021d6:	ff 75 0c             	push   0xc(%ebp)
801021d9:	ff 75 08             	push   0x8(%ebp)
801021dc:	e8 60 32 00 00       	call   80105441 <strncmp>
801021e1:	83 c4 10             	add    $0x10,%esp
}
801021e4:	c9                   	leave  
801021e5:	c3                   	ret    

801021e6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021e6:	55                   	push   %ebp
801021e7:	89 e5                	mov    %esp,%ebp
801021e9:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021ec:	8b 45 08             	mov    0x8(%ebp),%eax
801021ef:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021f3:	66 83 f8 01          	cmp    $0x1,%ax
801021f7:	74 0d                	je     80102206 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021f9:	83 ec 0c             	sub    $0xc,%esp
801021fc:	68 f7 88 10 80       	push   $0x801088f7
80102201:	e8 75 e3 ff ff       	call   8010057b <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102206:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010220d:	eb 7b                	jmp    8010228a <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010220f:	6a 10                	push   $0x10
80102211:	ff 75 f4             	push   -0xc(%ebp)
80102214:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102217:	50                   	push   %eax
80102218:	ff 75 08             	push   0x8(%ebp)
8010221b:	e8 d0 fc ff ff       	call   80101ef0 <readi>
80102220:	83 c4 10             	add    $0x10,%esp
80102223:	83 f8 10             	cmp    $0x10,%eax
80102226:	74 0d                	je     80102235 <dirlookup+0x4f>
      panic("dirlink read");
80102228:	83 ec 0c             	sub    $0xc,%esp
8010222b:	68 09 89 10 80       	push   $0x80108909
80102230:	e8 46 e3 ff ff       	call   8010057b <panic>
    if(de.inum == 0)
80102235:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102239:	66 85 c0             	test   %ax,%ax
8010223c:	74 47                	je     80102285 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010223e:	83 ec 08             	sub    $0x8,%esp
80102241:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102244:	83 c0 02             	add    $0x2,%eax
80102247:	50                   	push   %eax
80102248:	ff 75 0c             	push   0xc(%ebp)
8010224b:	e8 7b ff ff ff       	call   801021cb <namecmp>
80102250:	83 c4 10             	add    $0x10,%esp
80102253:	85 c0                	test   %eax,%eax
80102255:	75 2f                	jne    80102286 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102257:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010225b:	74 08                	je     80102265 <dirlookup+0x7f>
        *poff = off;
8010225d:	8b 45 10             	mov    0x10(%ebp),%eax
80102260:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102263:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102265:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102269:	0f b7 c0             	movzwl %ax,%eax
8010226c:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010226f:	8b 45 08             	mov    0x8(%ebp),%eax
80102272:	8b 00                	mov    (%eax),%eax
80102274:	83 ec 08             	sub    $0x8,%esp
80102277:	ff 75 f0             	push   -0x10(%ebp)
8010227a:	50                   	push   %eax
8010227b:	e8 ee f5 ff ff       	call   8010186e <iget>
80102280:	83 c4 10             	add    $0x10,%esp
80102283:	eb 19                	jmp    8010229e <dirlookup+0xb8>
      continue;
80102285:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102286:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010228a:	8b 45 08             	mov    0x8(%ebp),%eax
8010228d:	8b 40 18             	mov    0x18(%eax),%eax
80102290:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102293:	0f 82 76 ff ff ff    	jb     8010220f <dirlookup+0x29>
    }
  }

  return 0;
80102299:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010229e:	c9                   	leave  
8010229f:	c3                   	ret    

801022a0 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022a0:	55                   	push   %ebp
801022a1:	89 e5                	mov    %esp,%ebp
801022a3:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022a6:	83 ec 04             	sub    $0x4,%esp
801022a9:	6a 00                	push   $0x0
801022ab:	ff 75 0c             	push   0xc(%ebp)
801022ae:	ff 75 08             	push   0x8(%ebp)
801022b1:	e8 30 ff ff ff       	call   801021e6 <dirlookup>
801022b6:	83 c4 10             	add    $0x10,%esp
801022b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022c0:	74 18                	je     801022da <dirlink+0x3a>
    iput(ip);
801022c2:	83 ec 0c             	sub    $0xc,%esp
801022c5:	ff 75 f0             	push   -0x10(%ebp)
801022c8:	e8 8a f8 ff ff       	call   80101b57 <iput>
801022cd:	83 c4 10             	add    $0x10,%esp
    return -1;
801022d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022d5:	e9 9c 00 00 00       	jmp    80102376 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022e1:	eb 39                	jmp    8010231c <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e6:	6a 10                	push   $0x10
801022e8:	50                   	push   %eax
801022e9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022ec:	50                   	push   %eax
801022ed:	ff 75 08             	push   0x8(%ebp)
801022f0:	e8 fb fb ff ff       	call   80101ef0 <readi>
801022f5:	83 c4 10             	add    $0x10,%esp
801022f8:	83 f8 10             	cmp    $0x10,%eax
801022fb:	74 0d                	je     8010230a <dirlink+0x6a>
      panic("dirlink read");
801022fd:	83 ec 0c             	sub    $0xc,%esp
80102300:	68 09 89 10 80       	push   $0x80108909
80102305:	e8 71 e2 ff ff       	call   8010057b <panic>
    if(de.inum == 0)
8010230a:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010230e:	66 85 c0             	test   %ax,%ax
80102311:	74 18                	je     8010232b <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102316:	83 c0 10             	add    $0x10,%eax
80102319:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010231c:	8b 45 08             	mov    0x8(%ebp),%eax
8010231f:	8b 50 18             	mov    0x18(%eax),%edx
80102322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102325:	39 c2                	cmp    %eax,%edx
80102327:	77 ba                	ja     801022e3 <dirlink+0x43>
80102329:	eb 01                	jmp    8010232c <dirlink+0x8c>
      break;
8010232b:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010232c:	83 ec 04             	sub    $0x4,%esp
8010232f:	6a 0e                	push   $0xe
80102331:	ff 75 0c             	push   0xc(%ebp)
80102334:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102337:	83 c0 02             	add    $0x2,%eax
8010233a:	50                   	push   %eax
8010233b:	e8 57 31 00 00       	call   80105497 <strncpy>
80102340:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102343:	8b 45 10             	mov    0x10(%ebp),%eax
80102346:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010234a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234d:	6a 10                	push   $0x10
8010234f:	50                   	push   %eax
80102350:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102353:	50                   	push   %eax
80102354:	ff 75 08             	push   0x8(%ebp)
80102357:	e8 e9 fc ff ff       	call   80102045 <writei>
8010235c:	83 c4 10             	add    $0x10,%esp
8010235f:	83 f8 10             	cmp    $0x10,%eax
80102362:	74 0d                	je     80102371 <dirlink+0xd1>
    panic("dirlink");
80102364:	83 ec 0c             	sub    $0xc,%esp
80102367:	68 16 89 10 80       	push   $0x80108916
8010236c:	e8 0a e2 ff ff       	call   8010057b <panic>
  
  return 0;
80102371:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102376:	c9                   	leave  
80102377:	c3                   	ret    

80102378 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102378:	55                   	push   %ebp
80102379:	89 e5                	mov    %esp,%ebp
8010237b:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010237e:	eb 04                	jmp    80102384 <skipelem+0xc>
    path++;
80102380:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102384:	8b 45 08             	mov    0x8(%ebp),%eax
80102387:	0f b6 00             	movzbl (%eax),%eax
8010238a:	3c 2f                	cmp    $0x2f,%al
8010238c:	74 f2                	je     80102380 <skipelem+0x8>
  if(*path == 0)
8010238e:	8b 45 08             	mov    0x8(%ebp),%eax
80102391:	0f b6 00             	movzbl (%eax),%eax
80102394:	84 c0                	test   %al,%al
80102396:	75 07                	jne    8010239f <skipelem+0x27>
    return 0;
80102398:	b8 00 00 00 00       	mov    $0x0,%eax
8010239d:	eb 77                	jmp    80102416 <skipelem+0x9e>
  s = path;
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023a5:	eb 04                	jmp    801023ab <skipelem+0x33>
    path++;
801023a7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
801023ab:	8b 45 08             	mov    0x8(%ebp),%eax
801023ae:	0f b6 00             	movzbl (%eax),%eax
801023b1:	3c 2f                	cmp    $0x2f,%al
801023b3:	74 0a                	je     801023bf <skipelem+0x47>
801023b5:	8b 45 08             	mov    0x8(%ebp),%eax
801023b8:	0f b6 00             	movzbl (%eax),%eax
801023bb:	84 c0                	test   %al,%al
801023bd:	75 e8                	jne    801023a7 <skipelem+0x2f>
  len = path - s;
801023bf:	8b 45 08             	mov    0x8(%ebp),%eax
801023c2:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023c8:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023cc:	7e 15                	jle    801023e3 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023ce:	83 ec 04             	sub    $0x4,%esp
801023d1:	6a 0e                	push   $0xe
801023d3:	ff 75 f4             	push   -0xc(%ebp)
801023d6:	ff 75 0c             	push   0xc(%ebp)
801023d9:	e8 cd 2f 00 00       	call   801053ab <memmove>
801023de:	83 c4 10             	add    $0x10,%esp
801023e1:	eb 26                	jmp    80102409 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023e6:	83 ec 04             	sub    $0x4,%esp
801023e9:	50                   	push   %eax
801023ea:	ff 75 f4             	push   -0xc(%ebp)
801023ed:	ff 75 0c             	push   0xc(%ebp)
801023f0:	e8 b6 2f 00 00       	call   801053ab <memmove>
801023f5:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801023fe:	01 d0                	add    %edx,%eax
80102400:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102403:	eb 04                	jmp    80102409 <skipelem+0x91>
    path++;
80102405:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102409:	8b 45 08             	mov    0x8(%ebp),%eax
8010240c:	0f b6 00             	movzbl (%eax),%eax
8010240f:	3c 2f                	cmp    $0x2f,%al
80102411:	74 f2                	je     80102405 <skipelem+0x8d>
  return path;
80102413:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102416:	c9                   	leave  
80102417:	c3                   	ret    

80102418 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102418:	55                   	push   %ebp
80102419:	89 e5                	mov    %esp,%ebp
8010241b:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010241e:	8b 45 08             	mov    0x8(%ebp),%eax
80102421:	0f b6 00             	movzbl (%eax),%eax
80102424:	3c 2f                	cmp    $0x2f,%al
80102426:	75 17                	jne    8010243f <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102428:	83 ec 08             	sub    $0x8,%esp
8010242b:	6a 01                	push   $0x1
8010242d:	6a 01                	push   $0x1
8010242f:	e8 3a f4 ff ff       	call   8010186e <iget>
80102434:	83 c4 10             	add    $0x10,%esp
80102437:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010243a:	e9 bb 00 00 00       	jmp    801024fa <namex+0xe2>
  else
    ip = idup(proc->cwd);
8010243f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80102445:	8b 40 68             	mov    0x68(%eax),%eax
80102448:	83 ec 0c             	sub    $0xc,%esp
8010244b:	50                   	push   %eax
8010244c:	e8 fc f4 ff ff       	call   8010194d <idup>
80102451:	83 c4 10             	add    $0x10,%esp
80102454:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102457:	e9 9e 00 00 00       	jmp    801024fa <namex+0xe2>
    ilock(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	push   -0xc(%ebp)
80102462:	e8 20 f5 ff ff       	call   80101987 <ilock>
80102467:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010246a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010246d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102471:	66 83 f8 01          	cmp    $0x1,%ax
80102475:	74 18                	je     8010248f <namex+0x77>
      iunlockput(ip);
80102477:	83 ec 0c             	sub    $0xc,%esp
8010247a:	ff 75 f4             	push   -0xc(%ebp)
8010247d:	e8 c5 f7 ff ff       	call   80101c47 <iunlockput>
80102482:	83 c4 10             	add    $0x10,%esp
      return 0;
80102485:	b8 00 00 00 00       	mov    $0x0,%eax
8010248a:	e9 a7 00 00 00       	jmp    80102536 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010248f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102493:	74 20                	je     801024b5 <namex+0x9d>
80102495:	8b 45 08             	mov    0x8(%ebp),%eax
80102498:	0f b6 00             	movzbl (%eax),%eax
8010249b:	84 c0                	test   %al,%al
8010249d:	75 16                	jne    801024b5 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010249f:	83 ec 0c             	sub    $0xc,%esp
801024a2:	ff 75 f4             	push   -0xc(%ebp)
801024a5:	e8 3b f6 ff ff       	call   80101ae5 <iunlock>
801024aa:	83 c4 10             	add    $0x10,%esp
      return ip;
801024ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b0:	e9 81 00 00 00       	jmp    80102536 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024b5:	83 ec 04             	sub    $0x4,%esp
801024b8:	6a 00                	push   $0x0
801024ba:	ff 75 10             	push   0x10(%ebp)
801024bd:	ff 75 f4             	push   -0xc(%ebp)
801024c0:	e8 21 fd ff ff       	call   801021e6 <dirlookup>
801024c5:	83 c4 10             	add    $0x10,%esp
801024c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024cf:	75 15                	jne    801024e6 <namex+0xce>
      iunlockput(ip);
801024d1:	83 ec 0c             	sub    $0xc,%esp
801024d4:	ff 75 f4             	push   -0xc(%ebp)
801024d7:	e8 6b f7 ff ff       	call   80101c47 <iunlockput>
801024dc:	83 c4 10             	add    $0x10,%esp
      return 0;
801024df:	b8 00 00 00 00       	mov    $0x0,%eax
801024e4:	eb 50                	jmp    80102536 <namex+0x11e>
    }
    iunlockput(ip);
801024e6:	83 ec 0c             	sub    $0xc,%esp
801024e9:	ff 75 f4             	push   -0xc(%ebp)
801024ec:	e8 56 f7 ff ff       	call   80101c47 <iunlockput>
801024f1:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024fa:	83 ec 08             	sub    $0x8,%esp
801024fd:	ff 75 10             	push   0x10(%ebp)
80102500:	ff 75 08             	push   0x8(%ebp)
80102503:	e8 70 fe ff ff       	call   80102378 <skipelem>
80102508:	83 c4 10             	add    $0x10,%esp
8010250b:	89 45 08             	mov    %eax,0x8(%ebp)
8010250e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102512:	0f 85 44 ff ff ff    	jne    8010245c <namex+0x44>
  }
  if(nameiparent){
80102518:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010251c:	74 15                	je     80102533 <namex+0x11b>
    iput(ip);
8010251e:	83 ec 0c             	sub    $0xc,%esp
80102521:	ff 75 f4             	push   -0xc(%ebp)
80102524:	e8 2e f6 ff ff       	call   80101b57 <iput>
80102529:	83 c4 10             	add    $0x10,%esp
    return 0;
8010252c:	b8 00 00 00 00       	mov    $0x0,%eax
80102531:	eb 03                	jmp    80102536 <namex+0x11e>
  }
  return ip;
80102533:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102536:	c9                   	leave  
80102537:	c3                   	ret    

80102538 <namei>:

struct inode*
namei(char *path)
{
80102538:	55                   	push   %ebp
80102539:	89 e5                	mov    %esp,%ebp
8010253b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010253e:	83 ec 04             	sub    $0x4,%esp
80102541:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102544:	50                   	push   %eax
80102545:	6a 00                	push   $0x0
80102547:	ff 75 08             	push   0x8(%ebp)
8010254a:	e8 c9 fe ff ff       	call   80102418 <namex>
8010254f:	83 c4 10             	add    $0x10,%esp
}
80102552:	c9                   	leave  
80102553:	c3                   	ret    

80102554 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102554:	55                   	push   %ebp
80102555:	89 e5                	mov    %esp,%ebp
80102557:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010255a:	83 ec 04             	sub    $0x4,%esp
8010255d:	ff 75 0c             	push   0xc(%ebp)
80102560:	6a 01                	push   $0x1
80102562:	ff 75 08             	push   0x8(%ebp)
80102565:	e8 ae fe ff ff       	call   80102418 <namex>
8010256a:	83 c4 10             	add    $0x10,%esp
}
8010256d:	c9                   	leave  
8010256e:	c3                   	ret    

8010256f <inb>:
{
8010256f:	55                   	push   %ebp
80102570:	89 e5                	mov    %esp,%ebp
80102572:	83 ec 14             	sub    $0x14,%esp
80102575:	8b 45 08             	mov    0x8(%ebp),%eax
80102578:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010257c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102580:	89 c2                	mov    %eax,%edx
80102582:	ec                   	in     (%dx),%al
80102583:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102586:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010258a:	c9                   	leave  
8010258b:	c3                   	ret    

8010258c <insl>:
{
8010258c:	55                   	push   %ebp
8010258d:	89 e5                	mov    %esp,%ebp
8010258f:	57                   	push   %edi
80102590:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102591:	8b 55 08             	mov    0x8(%ebp),%edx
80102594:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102597:	8b 45 10             	mov    0x10(%ebp),%eax
8010259a:	89 cb                	mov    %ecx,%ebx
8010259c:	89 df                	mov    %ebx,%edi
8010259e:	89 c1                	mov    %eax,%ecx
801025a0:	fc                   	cld    
801025a1:	f3 6d                	rep insl (%dx),%es:(%edi)
801025a3:	89 c8                	mov    %ecx,%eax
801025a5:	89 fb                	mov    %edi,%ebx
801025a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025aa:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025ad:	90                   	nop
801025ae:	5b                   	pop    %ebx
801025af:	5f                   	pop    %edi
801025b0:	5d                   	pop    %ebp
801025b1:	c3                   	ret    

801025b2 <outb>:
{
801025b2:	55                   	push   %ebp
801025b3:	89 e5                	mov    %esp,%ebp
801025b5:	83 ec 08             	sub    $0x8,%esp
801025b8:	8b 45 08             	mov    0x8(%ebp),%eax
801025bb:	8b 55 0c             	mov    0xc(%ebp),%edx
801025be:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025c2:	89 d0                	mov    %edx,%eax
801025c4:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025c7:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801025cb:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025cf:	ee                   	out    %al,(%dx)
}
801025d0:	90                   	nop
801025d1:	c9                   	leave  
801025d2:	c3                   	ret    

801025d3 <outsl>:
{
801025d3:	55                   	push   %ebp
801025d4:	89 e5                	mov    %esp,%ebp
801025d6:	56                   	push   %esi
801025d7:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025d8:	8b 55 08             	mov    0x8(%ebp),%edx
801025db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025de:	8b 45 10             	mov    0x10(%ebp),%eax
801025e1:	89 cb                	mov    %ecx,%ebx
801025e3:	89 de                	mov    %ebx,%esi
801025e5:	89 c1                	mov    %eax,%ecx
801025e7:	fc                   	cld    
801025e8:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025ea:	89 c8                	mov    %ecx,%eax
801025ec:	89 f3                	mov    %esi,%ebx
801025ee:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025f1:	89 45 10             	mov    %eax,0x10(%ebp)
}
801025f4:	90                   	nop
801025f5:	5b                   	pop    %ebx
801025f6:	5e                   	pop    %esi
801025f7:	5d                   	pop    %ebp
801025f8:	c3                   	ret    

801025f9 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025f9:	55                   	push   %ebp
801025fa:	89 e5                	mov    %esp,%ebp
801025fc:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025ff:	90                   	nop
80102600:	68 f7 01 00 00       	push   $0x1f7
80102605:	e8 65 ff ff ff       	call   8010256f <inb>
8010260a:	83 c4 04             	add    $0x4,%esp
8010260d:	0f b6 c0             	movzbl %al,%eax
80102610:	89 45 fc             	mov    %eax,-0x4(%ebp)
80102613:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102616:	25 c0 00 00 00       	and    $0xc0,%eax
8010261b:	83 f8 40             	cmp    $0x40,%eax
8010261e:	75 e0                	jne    80102600 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102624:	74 11                	je     80102637 <idewait+0x3e>
80102626:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102629:	83 e0 21             	and    $0x21,%eax
8010262c:	85 c0                	test   %eax,%eax
8010262e:	74 07                	je     80102637 <idewait+0x3e>
    return -1;
80102630:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102635:	eb 05                	jmp    8010263c <idewait+0x43>
  return 0;
80102637:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010263c:	c9                   	leave  
8010263d:	c3                   	ret    

8010263e <ideinit>:

void
ideinit(void)
{
8010263e:	55                   	push   %ebp
8010263f:	89 e5                	mov    %esp,%ebp
80102641:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102644:	83 ec 08             	sub    $0x8,%esp
80102647:	68 1e 89 10 80       	push   $0x8010891e
8010264c:	68 c0 11 11 80       	push   $0x801111c0
80102651:	e8 11 2a 00 00       	call   80105067 <initlock>
80102656:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
80102659:	83 ec 0c             	sub    $0xc,%esp
8010265c:	6a 0e                	push   $0xe
8010265e:	e8 0f 19 00 00       	call   80103f72 <picenable>
80102663:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102666:	a1 44 19 11 80       	mov    0x80111944,%eax
8010266b:	83 e8 01             	sub    $0x1,%eax
8010266e:	83 ec 08             	sub    $0x8,%esp
80102671:	50                   	push   %eax
80102672:	6a 0e                	push   $0xe
80102674:	e8 73 04 00 00       	call   80102aec <ioapicenable>
80102679:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010267c:	83 ec 0c             	sub    $0xc,%esp
8010267f:	6a 00                	push   $0x0
80102681:	e8 73 ff ff ff       	call   801025f9 <idewait>
80102686:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102689:	83 ec 08             	sub    $0x8,%esp
8010268c:	68 f0 00 00 00       	push   $0xf0
80102691:	68 f6 01 00 00       	push   $0x1f6
80102696:	e8 17 ff ff ff       	call   801025b2 <outb>
8010269b:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
8010269e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026a5:	eb 24                	jmp    801026cb <ideinit+0x8d>
    if(inb(0x1f7) != 0){
801026a7:	83 ec 0c             	sub    $0xc,%esp
801026aa:	68 f7 01 00 00       	push   $0x1f7
801026af:	e8 bb fe ff ff       	call   8010256f <inb>
801026b4:	83 c4 10             	add    $0x10,%esp
801026b7:	84 c0                	test   %al,%al
801026b9:	74 0c                	je     801026c7 <ideinit+0x89>
      havedisk1 = 1;
801026bb:	c7 05 f8 11 11 80 01 	movl   $0x1,0x801111f8
801026c2:	00 00 00 
      break;
801026c5:	eb 0d                	jmp    801026d4 <ideinit+0x96>
  for(i=0; i<1000; i++){
801026c7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801026cb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026d2:	7e d3                	jle    801026a7 <ideinit+0x69>
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026d4:	83 ec 08             	sub    $0x8,%esp
801026d7:	68 e0 00 00 00       	push   $0xe0
801026dc:	68 f6 01 00 00       	push   $0x1f6
801026e1:	e8 cc fe ff ff       	call   801025b2 <outb>
801026e6:	83 c4 10             	add    $0x10,%esp
}
801026e9:	90                   	nop
801026ea:	c9                   	leave  
801026eb:	c3                   	ret    

801026ec <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ec:	55                   	push   %ebp
801026ed:	89 e5                	mov    %esp,%ebp
801026ef:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f6:	75 0d                	jne    80102705 <idestart+0x19>
    panic("idestart");
801026f8:	83 ec 0c             	sub    $0xc,%esp
801026fb:	68 22 89 10 80       	push   $0x80108922
80102700:	e8 76 de ff ff       	call   8010057b <panic>
  if(b->blockno >= FSSIZE)
80102705:	8b 45 08             	mov    0x8(%ebp),%eax
80102708:	8b 40 08             	mov    0x8(%eax),%eax
8010270b:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102710:	76 0d                	jbe    8010271f <idestart+0x33>
    panic("incorrect blockno");
80102712:	83 ec 0c             	sub    $0xc,%esp
80102715:	68 2b 89 10 80       	push   $0x8010892b
8010271a:	e8 5c de ff ff       	call   8010057b <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010271f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102726:	8b 45 08             	mov    0x8(%ebp),%eax
80102729:	8b 50 08             	mov    0x8(%eax),%edx
8010272c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272f:	0f af c2             	imul   %edx,%eax
80102732:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102735:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102739:	7e 0d                	jle    80102748 <idestart+0x5c>
8010273b:	83 ec 0c             	sub    $0xc,%esp
8010273e:	68 22 89 10 80       	push   $0x80108922
80102743:	e8 33 de ff ff       	call   8010057b <panic>
  
  idewait(0);
80102748:	83 ec 0c             	sub    $0xc,%esp
8010274b:	6a 00                	push   $0x0
8010274d:	e8 a7 fe ff ff       	call   801025f9 <idewait>
80102752:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102755:	83 ec 08             	sub    $0x8,%esp
80102758:	6a 00                	push   $0x0
8010275a:	68 f6 03 00 00       	push   $0x3f6
8010275f:	e8 4e fe ff ff       	call   801025b2 <outb>
80102764:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
80102767:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010276a:	0f b6 c0             	movzbl %al,%eax
8010276d:	83 ec 08             	sub    $0x8,%esp
80102770:	50                   	push   %eax
80102771:	68 f2 01 00 00       	push   $0x1f2
80102776:	e8 37 fe ff ff       	call   801025b2 <outb>
8010277b:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
8010277e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102781:	0f b6 c0             	movzbl %al,%eax
80102784:	83 ec 08             	sub    $0x8,%esp
80102787:	50                   	push   %eax
80102788:	68 f3 01 00 00       	push   $0x1f3
8010278d:	e8 20 fe ff ff       	call   801025b2 <outb>
80102792:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102795:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102798:	c1 f8 08             	sar    $0x8,%eax
8010279b:	0f b6 c0             	movzbl %al,%eax
8010279e:	83 ec 08             	sub    $0x8,%esp
801027a1:	50                   	push   %eax
801027a2:	68 f4 01 00 00       	push   $0x1f4
801027a7:	e8 06 fe ff ff       	call   801025b2 <outb>
801027ac:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
801027af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027b2:	c1 f8 10             	sar    $0x10,%eax
801027b5:	0f b6 c0             	movzbl %al,%eax
801027b8:	83 ec 08             	sub    $0x8,%esp
801027bb:	50                   	push   %eax
801027bc:	68 f5 01 00 00       	push   $0x1f5
801027c1:	e8 ec fd ff ff       	call   801025b2 <outb>
801027c6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027c9:	8b 45 08             	mov    0x8(%ebp),%eax
801027cc:	8b 40 04             	mov    0x4(%eax),%eax
801027cf:	c1 e0 04             	shl    $0x4,%eax
801027d2:	83 e0 10             	and    $0x10,%eax
801027d5:	89 c2                	mov    %eax,%edx
801027d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027da:	c1 f8 18             	sar    $0x18,%eax
801027dd:	83 e0 0f             	and    $0xf,%eax
801027e0:	09 d0                	or     %edx,%eax
801027e2:	83 c8 e0             	or     $0xffffffe0,%eax
801027e5:	0f b6 c0             	movzbl %al,%eax
801027e8:	83 ec 08             	sub    $0x8,%esp
801027eb:	50                   	push   %eax
801027ec:	68 f6 01 00 00       	push   $0x1f6
801027f1:	e8 bc fd ff ff       	call   801025b2 <outb>
801027f6:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027f9:	8b 45 08             	mov    0x8(%ebp),%eax
801027fc:	8b 00                	mov    (%eax),%eax
801027fe:	83 e0 04             	and    $0x4,%eax
80102801:	85 c0                	test   %eax,%eax
80102803:	74 30                	je     80102835 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
80102805:	83 ec 08             	sub    $0x8,%esp
80102808:	6a 30                	push   $0x30
8010280a:	68 f7 01 00 00       	push   $0x1f7
8010280f:	e8 9e fd ff ff       	call   801025b2 <outb>
80102814:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
80102817:	8b 45 08             	mov    0x8(%ebp),%eax
8010281a:	83 c0 18             	add    $0x18,%eax
8010281d:	83 ec 04             	sub    $0x4,%esp
80102820:	68 80 00 00 00       	push   $0x80
80102825:	50                   	push   %eax
80102826:	68 f0 01 00 00       	push   $0x1f0
8010282b:	e8 a3 fd ff ff       	call   801025d3 <outsl>
80102830:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102833:	eb 12                	jmp    80102847 <idestart+0x15b>
    outb(0x1f7, IDE_CMD_READ);
80102835:	83 ec 08             	sub    $0x8,%esp
80102838:	6a 20                	push   $0x20
8010283a:	68 f7 01 00 00       	push   $0x1f7
8010283f:	e8 6e fd ff ff       	call   801025b2 <outb>
80102844:	83 c4 10             	add    $0x10,%esp
}
80102847:	90                   	nop
80102848:	c9                   	leave  
80102849:	c3                   	ret    

8010284a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010284a:	55                   	push   %ebp
8010284b:	89 e5                	mov    %esp,%ebp
8010284d:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102850:	83 ec 0c             	sub    $0xc,%esp
80102853:	68 c0 11 11 80       	push   $0x801111c0
80102858:	e8 2c 28 00 00       	call   80105089 <acquire>
8010285d:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102860:	a1 f4 11 11 80       	mov    0x801111f4,%eax
80102865:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102868:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010286c:	75 15                	jne    80102883 <ideintr+0x39>
    release(&idelock);
8010286e:	83 ec 0c             	sub    $0xc,%esp
80102871:	68 c0 11 11 80       	push   $0x801111c0
80102876:	e8 75 28 00 00       	call   801050f0 <release>
8010287b:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
8010287e:	e9 9a 00 00 00       	jmp    8010291d <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102883:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102886:	8b 40 14             	mov    0x14(%eax),%eax
80102889:	a3 f4 11 11 80       	mov    %eax,0x801111f4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010288e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102891:	8b 00                	mov    (%eax),%eax
80102893:	83 e0 04             	and    $0x4,%eax
80102896:	85 c0                	test   %eax,%eax
80102898:	75 2d                	jne    801028c7 <ideintr+0x7d>
8010289a:	83 ec 0c             	sub    $0xc,%esp
8010289d:	6a 01                	push   $0x1
8010289f:	e8 55 fd ff ff       	call   801025f9 <idewait>
801028a4:	83 c4 10             	add    $0x10,%esp
801028a7:	85 c0                	test   %eax,%eax
801028a9:	78 1c                	js     801028c7 <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
801028ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ae:	83 c0 18             	add    $0x18,%eax
801028b1:	83 ec 04             	sub    $0x4,%esp
801028b4:	68 80 00 00 00       	push   $0x80
801028b9:	50                   	push   %eax
801028ba:	68 f0 01 00 00       	push   $0x1f0
801028bf:	e8 c8 fc ff ff       	call   8010258c <insl>
801028c4:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ca:	8b 00                	mov    (%eax),%eax
801028cc:	83 c8 02             	or     $0x2,%eax
801028cf:	89 c2                	mov    %eax,%edx
801028d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d4:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d9:	8b 00                	mov    (%eax),%eax
801028db:	83 e0 fb             	and    $0xfffffffb,%eax
801028de:	89 c2                	mov    %eax,%edx
801028e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028e3:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028e5:	83 ec 0c             	sub    $0xc,%esp
801028e8:	ff 75 f4             	push   -0xc(%ebp)
801028eb:	e8 8a 25 00 00       	call   80104e7a <wakeup>
801028f0:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028f3:	a1 f4 11 11 80       	mov    0x801111f4,%eax
801028f8:	85 c0                	test   %eax,%eax
801028fa:	74 11                	je     8010290d <ideintr+0xc3>
    idestart(idequeue);
801028fc:	a1 f4 11 11 80       	mov    0x801111f4,%eax
80102901:	83 ec 0c             	sub    $0xc,%esp
80102904:	50                   	push   %eax
80102905:	e8 e2 fd ff ff       	call   801026ec <idestart>
8010290a:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010290d:	83 ec 0c             	sub    $0xc,%esp
80102910:	68 c0 11 11 80       	push   $0x801111c0
80102915:	e8 d6 27 00 00       	call   801050f0 <release>
8010291a:	83 c4 10             	add    $0x10,%esp
}
8010291d:	c9                   	leave  
8010291e:	c3                   	ret    

8010291f <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010291f:	55                   	push   %ebp
80102920:	89 e5                	mov    %esp,%ebp
80102922:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102925:	8b 45 08             	mov    0x8(%ebp),%eax
80102928:	8b 00                	mov    (%eax),%eax
8010292a:	83 e0 01             	and    $0x1,%eax
8010292d:	85 c0                	test   %eax,%eax
8010292f:	75 0d                	jne    8010293e <iderw+0x1f>
    panic("iderw: buf not busy");
80102931:	83 ec 0c             	sub    $0xc,%esp
80102934:	68 3d 89 10 80       	push   $0x8010893d
80102939:	e8 3d dc ff ff       	call   8010057b <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010293e:	8b 45 08             	mov    0x8(%ebp),%eax
80102941:	8b 00                	mov    (%eax),%eax
80102943:	83 e0 06             	and    $0x6,%eax
80102946:	83 f8 02             	cmp    $0x2,%eax
80102949:	75 0d                	jne    80102958 <iderw+0x39>
    panic("iderw: nothing to do");
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	68 51 89 10 80       	push   $0x80108951
80102953:	e8 23 dc ff ff       	call   8010057b <panic>
  if(b->dev != 0 && !havedisk1)
80102958:	8b 45 08             	mov    0x8(%ebp),%eax
8010295b:	8b 40 04             	mov    0x4(%eax),%eax
8010295e:	85 c0                	test   %eax,%eax
80102960:	74 16                	je     80102978 <iderw+0x59>
80102962:	a1 f8 11 11 80       	mov    0x801111f8,%eax
80102967:	85 c0                	test   %eax,%eax
80102969:	75 0d                	jne    80102978 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010296b:	83 ec 0c             	sub    $0xc,%esp
8010296e:	68 66 89 10 80       	push   $0x80108966
80102973:	e8 03 dc ff ff       	call   8010057b <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102978:	83 ec 0c             	sub    $0xc,%esp
8010297b:	68 c0 11 11 80       	push   $0x801111c0
80102980:	e8 04 27 00 00       	call   80105089 <acquire>
80102985:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102992:	c7 45 f4 f4 11 11 80 	movl   $0x801111f4,-0xc(%ebp)
80102999:	eb 0b                	jmp    801029a6 <iderw+0x87>
8010299b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010299e:	8b 00                	mov    (%eax),%eax
801029a0:	83 c0 14             	add    $0x14,%eax
801029a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029a9:	8b 00                	mov    (%eax),%eax
801029ab:	85 c0                	test   %eax,%eax
801029ad:	75 ec                	jne    8010299b <iderw+0x7c>
    ;
  *pp = b;
801029af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b2:	8b 55 08             	mov    0x8(%ebp),%edx
801029b5:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
801029b7:	a1 f4 11 11 80       	mov    0x801111f4,%eax
801029bc:	39 45 08             	cmp    %eax,0x8(%ebp)
801029bf:	75 23                	jne    801029e4 <iderw+0xc5>
    idestart(b);
801029c1:	83 ec 0c             	sub    $0xc,%esp
801029c4:	ff 75 08             	push   0x8(%ebp)
801029c7:	e8 20 fd ff ff       	call   801026ec <idestart>
801029cc:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029cf:	eb 13                	jmp    801029e4 <iderw+0xc5>
    sleep(b, &idelock);
801029d1:	83 ec 08             	sub    $0x8,%esp
801029d4:	68 c0 11 11 80       	push   $0x801111c0
801029d9:	ff 75 08             	push   0x8(%ebp)
801029dc:	e8 ad 23 00 00       	call   80104d8e <sleep>
801029e1:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029e4:	8b 45 08             	mov    0x8(%ebp),%eax
801029e7:	8b 00                	mov    (%eax),%eax
801029e9:	83 e0 06             	and    $0x6,%eax
801029ec:	83 f8 02             	cmp    $0x2,%eax
801029ef:	75 e0                	jne    801029d1 <iderw+0xb2>
  }

  release(&idelock);
801029f1:	83 ec 0c             	sub    $0xc,%esp
801029f4:	68 c0 11 11 80       	push   $0x801111c0
801029f9:	e8 f2 26 00 00       	call   801050f0 <release>
801029fe:	83 c4 10             	add    $0x10,%esp
}
80102a01:	90                   	nop
80102a02:	c9                   	leave  
80102a03:	c3                   	ret    

80102a04 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a04:	55                   	push   %ebp
80102a05:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a07:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a0c:	8b 55 08             	mov    0x8(%ebp),%edx
80102a0f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a11:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a16:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a19:	5d                   	pop    %ebp
80102a1a:	c3                   	ret    

80102a1b <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a1b:	55                   	push   %ebp
80102a1c:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a1e:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a23:	8b 55 08             	mov    0x8(%ebp),%edx
80102a26:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a28:	a1 fc 11 11 80       	mov    0x801111fc,%eax
80102a2d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a30:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a33:	90                   	nop
80102a34:	5d                   	pop    %ebp
80102a35:	c3                   	ret    

80102a36 <ioapicinit>:

void
ioapicinit(void)
{
80102a36:	55                   	push   %ebp
80102a37:	89 e5                	mov    %esp,%ebp
80102a39:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a3c:	a1 40 19 11 80       	mov    0x80111940,%eax
80102a41:	85 c0                	test   %eax,%eax
80102a43:	0f 84 a0 00 00 00    	je     80102ae9 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a49:	c7 05 fc 11 11 80 00 	movl   $0xfec00000,0x801111fc
80102a50:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a53:	6a 01                	push   $0x1
80102a55:	e8 aa ff ff ff       	call   80102a04 <ioapicread>
80102a5a:	83 c4 04             	add    $0x4,%esp
80102a5d:	c1 e8 10             	shr    $0x10,%eax
80102a60:	25 ff 00 00 00       	and    $0xff,%eax
80102a65:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a68:	6a 00                	push   $0x0
80102a6a:	e8 95 ff ff ff       	call   80102a04 <ioapicread>
80102a6f:	83 c4 04             	add    $0x4,%esp
80102a72:	c1 e8 18             	shr    $0x18,%eax
80102a75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a78:	0f b6 05 48 19 11 80 	movzbl 0x80111948,%eax
80102a7f:	0f b6 c0             	movzbl %al,%eax
80102a82:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80102a85:	74 10                	je     80102a97 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a87:	83 ec 0c             	sub    $0xc,%esp
80102a8a:	68 84 89 10 80       	push   $0x80108984
80102a8f:	e8 32 d9 ff ff       	call   801003c6 <cprintf>
80102a94:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a9e:	eb 3f                	jmp    80102adf <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa3:	83 c0 20             	add    $0x20,%eax
80102aa6:	0d 00 00 01 00       	or     $0x10000,%eax
80102aab:	89 c2                	mov    %eax,%edx
80102aad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab0:	83 c0 08             	add    $0x8,%eax
80102ab3:	01 c0                	add    %eax,%eax
80102ab5:	83 ec 08             	sub    $0x8,%esp
80102ab8:	52                   	push   %edx
80102ab9:	50                   	push   %eax
80102aba:	e8 5c ff ff ff       	call   80102a1b <ioapicwrite>
80102abf:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac5:	83 c0 08             	add    $0x8,%eax
80102ac8:	01 c0                	add    %eax,%eax
80102aca:	83 c0 01             	add    $0x1,%eax
80102acd:	83 ec 08             	sub    $0x8,%esp
80102ad0:	6a 00                	push   $0x0
80102ad2:	50                   	push   %eax
80102ad3:	e8 43 ff ff ff       	call   80102a1b <ioapicwrite>
80102ad8:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102adb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ae5:	7e b9                	jle    80102aa0 <ioapicinit+0x6a>
80102ae7:	eb 01                	jmp    80102aea <ioapicinit+0xb4>
    return;
80102ae9:	90                   	nop
  }
}
80102aea:	c9                   	leave  
80102aeb:	c3                   	ret    

80102aec <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102aec:	55                   	push   %ebp
80102aed:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102aef:	a1 40 19 11 80       	mov    0x80111940,%eax
80102af4:	85 c0                	test   %eax,%eax
80102af6:	74 39                	je     80102b31 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102af8:	8b 45 08             	mov    0x8(%ebp),%eax
80102afb:	83 c0 20             	add    $0x20,%eax
80102afe:	89 c2                	mov    %eax,%edx
80102b00:	8b 45 08             	mov    0x8(%ebp),%eax
80102b03:	83 c0 08             	add    $0x8,%eax
80102b06:	01 c0                	add    %eax,%eax
80102b08:	52                   	push   %edx
80102b09:	50                   	push   %eax
80102b0a:	e8 0c ff ff ff       	call   80102a1b <ioapicwrite>
80102b0f:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b12:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b15:	c1 e0 18             	shl    $0x18,%eax
80102b18:	89 c2                	mov    %eax,%edx
80102b1a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b1d:	83 c0 08             	add    $0x8,%eax
80102b20:	01 c0                	add    %eax,%eax
80102b22:	83 c0 01             	add    $0x1,%eax
80102b25:	52                   	push   %edx
80102b26:	50                   	push   %eax
80102b27:	e8 ef fe ff ff       	call   80102a1b <ioapicwrite>
80102b2c:	83 c4 08             	add    $0x8,%esp
80102b2f:	eb 01                	jmp    80102b32 <ioapicenable+0x46>
    return;
80102b31:	90                   	nop
}
80102b32:	c9                   	leave  
80102b33:	c3                   	ret    

80102b34 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b34:	55                   	push   %ebp
80102b35:	89 e5                	mov    %esp,%ebp
80102b37:	8b 45 08             	mov    0x8(%ebp),%eax
80102b3a:	05 00 00 00 80       	add    $0x80000000,%eax
80102b3f:	5d                   	pop    %ebp
80102b40:	c3                   	ret    

80102b41 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b41:	55                   	push   %ebp
80102b42:	89 e5                	mov    %esp,%ebp
80102b44:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b47:	83 ec 08             	sub    $0x8,%esp
80102b4a:	68 b6 89 10 80       	push   $0x801089b6
80102b4f:	68 20 12 11 80       	push   $0x80111220
80102b54:	e8 0e 25 00 00       	call   80105067 <initlock>
80102b59:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b5c:	c7 05 54 12 11 80 00 	movl   $0x0,0x80111254
80102b63:	00 00 00 
  freerange(vstart, vend);
80102b66:	83 ec 08             	sub    $0x8,%esp
80102b69:	ff 75 0c             	push   0xc(%ebp)
80102b6c:	ff 75 08             	push   0x8(%ebp)
80102b6f:	e8 2a 00 00 00       	call   80102b9e <freerange>
80102b74:	83 c4 10             	add    $0x10,%esp
}
80102b77:	90                   	nop
80102b78:	c9                   	leave  
80102b79:	c3                   	ret    

80102b7a <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b7a:	55                   	push   %ebp
80102b7b:	89 e5                	mov    %esp,%ebp
80102b7d:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b80:	83 ec 08             	sub    $0x8,%esp
80102b83:	ff 75 0c             	push   0xc(%ebp)
80102b86:	ff 75 08             	push   0x8(%ebp)
80102b89:	e8 10 00 00 00       	call   80102b9e <freerange>
80102b8e:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b91:	c7 05 54 12 11 80 01 	movl   $0x1,0x80111254
80102b98:	00 00 00 
}
80102b9b:	90                   	nop
80102b9c:	c9                   	leave  
80102b9d:	c3                   	ret    

80102b9e <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b9e:	55                   	push   %ebp
80102b9f:	89 e5                	mov    %esp,%ebp
80102ba1:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102ba4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ba7:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bb4:	eb 15                	jmp    80102bcb <freerange+0x2d>
    kfree(p);
80102bb6:	83 ec 0c             	sub    $0xc,%esp
80102bb9:	ff 75 f4             	push   -0xc(%ebp)
80102bbc:	e8 1b 00 00 00       	call   80102bdc <kfree>
80102bc1:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bc4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bce:	05 00 10 00 00       	add    $0x1000,%eax
80102bd3:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102bd6:	73 de                	jae    80102bb6 <freerange+0x18>
}
80102bd8:	90                   	nop
80102bd9:	90                   	nop
80102bda:	c9                   	leave  
80102bdb:	c3                   	ret    

80102bdc <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bdc:	55                   	push   %ebp
80102bdd:	89 e5                	mov    %esp,%ebp
80102bdf:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102be2:	8b 45 08             	mov    0x8(%ebp),%eax
80102be5:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bea:	85 c0                	test   %eax,%eax
80102bec:	75 1b                	jne    80102c09 <kfree+0x2d>
80102bee:	81 7d 08 60 51 11 80 	cmpl   $0x80115160,0x8(%ebp)
80102bf5:	72 12                	jb     80102c09 <kfree+0x2d>
80102bf7:	ff 75 08             	push   0x8(%ebp)
80102bfa:	e8 35 ff ff ff       	call   80102b34 <v2p>
80102bff:	83 c4 04             	add    $0x4,%esp
80102c02:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c07:	76 0d                	jbe    80102c16 <kfree+0x3a>
    panic("kfree");
80102c09:	83 ec 0c             	sub    $0xc,%esp
80102c0c:	68 bb 89 10 80       	push   $0x801089bb
80102c11:	e8 65 d9 ff ff       	call   8010057b <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c16:	83 ec 04             	sub    $0x4,%esp
80102c19:	68 00 10 00 00       	push   $0x1000
80102c1e:	6a 01                	push   $0x1
80102c20:	ff 75 08             	push   0x8(%ebp)
80102c23:	e8 c4 26 00 00       	call   801052ec <memset>
80102c28:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102c2b:	a1 54 12 11 80       	mov    0x80111254,%eax
80102c30:	85 c0                	test   %eax,%eax
80102c32:	74 10                	je     80102c44 <kfree+0x68>
    acquire(&kmem.lock);
80102c34:	83 ec 0c             	sub    $0xc,%esp
80102c37:	68 20 12 11 80       	push   $0x80111220
80102c3c:	e8 48 24 00 00       	call   80105089 <acquire>
80102c41:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c44:	8b 45 08             	mov    0x8(%ebp),%eax
80102c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c4a:	8b 15 58 12 11 80    	mov    0x80111258,%edx
80102c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c53:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c58:	a3 58 12 11 80       	mov    %eax,0x80111258
  free_frame_cnt++;         // CS 3320: project 2
80102c5d:	a1 00 12 11 80       	mov    0x80111200,%eax
80102c62:	83 c0 01             	add    $0x1,%eax
80102c65:	a3 00 12 11 80       	mov    %eax,0x80111200
  if(kmem.use_lock)
80102c6a:	a1 54 12 11 80       	mov    0x80111254,%eax
80102c6f:	85 c0                	test   %eax,%eax
80102c71:	74 10                	je     80102c83 <kfree+0xa7>
    release(&kmem.lock);
80102c73:	83 ec 0c             	sub    $0xc,%esp
80102c76:	68 20 12 11 80       	push   $0x80111220
80102c7b:	e8 70 24 00 00       	call   801050f0 <release>
80102c80:	83 c4 10             	add    $0x10,%esp
}
80102c83:	90                   	nop
80102c84:	c9                   	leave  
80102c85:	c3                   	ret    

80102c86 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c86:	55                   	push   %ebp
80102c87:	89 e5                	mov    %esp,%ebp
80102c89:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c8c:	a1 54 12 11 80       	mov    0x80111254,%eax
80102c91:	85 c0                	test   %eax,%eax
80102c93:	74 10                	je     80102ca5 <kalloc+0x1f>
    acquire(&kmem.lock);
80102c95:	83 ec 0c             	sub    $0xc,%esp
80102c98:	68 20 12 11 80       	push   $0x80111220
80102c9d:	e8 e7 23 00 00       	call   80105089 <acquire>
80102ca2:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102ca5:	a1 58 12 11 80       	mov    0x80111258,%eax
80102caa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cb1:	74 17                	je     80102cca <kalloc+0x44>
  {
    free_frame_cnt--;     // CS 3320: project 2
80102cb3:	a1 00 12 11 80       	mov    0x80111200,%eax
80102cb8:	83 e8 01             	sub    $0x1,%eax
80102cbb:	a3 00 12 11 80       	mov    %eax,0x80111200
    kmem.freelist = r->next;
80102cc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc3:	8b 00                	mov    (%eax),%eax
80102cc5:	a3 58 12 11 80       	mov    %eax,0x80111258
  }
  if(kmem.use_lock)
80102cca:	a1 54 12 11 80       	mov    0x80111254,%eax
80102ccf:	85 c0                	test   %eax,%eax
80102cd1:	74 10                	je     80102ce3 <kalloc+0x5d>
    release(&kmem.lock);
80102cd3:	83 ec 0c             	sub    $0xc,%esp
80102cd6:	68 20 12 11 80       	push   $0x80111220
80102cdb:	e8 10 24 00 00       	call   801050f0 <release>
80102ce0:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ce6:	c9                   	leave  
80102ce7:	c3                   	ret    

80102ce8 <inb>:
{
80102ce8:	55                   	push   %ebp
80102ce9:	89 e5                	mov    %esp,%ebp
80102ceb:	83 ec 14             	sub    $0x14,%esp
80102cee:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf5:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cf9:	89 c2                	mov    %eax,%edx
80102cfb:	ec                   	in     (%dx),%al
80102cfc:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cff:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102d03:	c9                   	leave  
80102d04:	c3                   	ret    

80102d05 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d05:	55                   	push   %ebp
80102d06:	89 e5                	mov    %esp,%ebp
80102d08:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d0b:	6a 64                	push   $0x64
80102d0d:	e8 d6 ff ff ff       	call   80102ce8 <inb>
80102d12:	83 c4 04             	add    $0x4,%esp
80102d15:	0f b6 c0             	movzbl %al,%eax
80102d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d1e:	83 e0 01             	and    $0x1,%eax
80102d21:	85 c0                	test   %eax,%eax
80102d23:	75 0a                	jne    80102d2f <kbdgetc+0x2a>
    return -1;
80102d25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d2a:	e9 23 01 00 00       	jmp    80102e52 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d2f:	6a 60                	push   $0x60
80102d31:	e8 b2 ff ff ff       	call   80102ce8 <inb>
80102d36:	83 c4 04             	add    $0x4,%esp
80102d39:	0f b6 c0             	movzbl %al,%eax
80102d3c:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d3f:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d46:	75 17                	jne    80102d5f <kbdgetc+0x5a>
    shift |= E0ESC;
80102d48:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102d4d:	83 c8 40             	or     $0x40,%eax
80102d50:	a3 5c 12 11 80       	mov    %eax,0x8011125c
    return 0;
80102d55:	b8 00 00 00 00       	mov    $0x0,%eax
80102d5a:	e9 f3 00 00 00       	jmp    80102e52 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d62:	25 80 00 00 00       	and    $0x80,%eax
80102d67:	85 c0                	test   %eax,%eax
80102d69:	74 45                	je     80102db0 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d6b:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102d70:	83 e0 40             	and    $0x40,%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	75 08                	jne    80102d7f <kbdgetc+0x7a>
80102d77:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7a:	83 e0 7f             	and    $0x7f,%eax
80102d7d:	eb 03                	jmp    80102d82 <kbdgetc+0x7d>
80102d7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d82:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d88:	05 20 90 10 80       	add    $0x80109020,%eax
80102d8d:	0f b6 00             	movzbl (%eax),%eax
80102d90:	83 c8 40             	or     $0x40,%eax
80102d93:	0f b6 c0             	movzbl %al,%eax
80102d96:	f7 d0                	not    %eax
80102d98:	89 c2                	mov    %eax,%edx
80102d9a:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102d9f:	21 d0                	and    %edx,%eax
80102da1:	a3 5c 12 11 80       	mov    %eax,0x8011125c
    return 0;
80102da6:	b8 00 00 00 00       	mov    $0x0,%eax
80102dab:	e9 a2 00 00 00       	jmp    80102e52 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102db0:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102db5:	83 e0 40             	and    $0x40,%eax
80102db8:	85 c0                	test   %eax,%eax
80102dba:	74 14                	je     80102dd0 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dbc:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dc3:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102dc8:	83 e0 bf             	and    $0xffffffbf,%eax
80102dcb:	a3 5c 12 11 80       	mov    %eax,0x8011125c
  }

  shift |= shiftcode[data];
80102dd0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd3:	05 20 90 10 80       	add    $0x80109020,%eax
80102dd8:	0f b6 00             	movzbl (%eax),%eax
80102ddb:	0f b6 d0             	movzbl %al,%edx
80102dde:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102de3:	09 d0                	or     %edx,%eax
80102de5:	a3 5c 12 11 80       	mov    %eax,0x8011125c
  shift ^= togglecode[data];
80102dea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ded:	05 20 91 10 80       	add    $0x80109120,%eax
80102df2:	0f b6 00             	movzbl (%eax),%eax
80102df5:	0f b6 d0             	movzbl %al,%edx
80102df8:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102dfd:	31 d0                	xor    %edx,%eax
80102dff:	a3 5c 12 11 80       	mov    %eax,0x8011125c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e04:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102e09:	83 e0 03             	and    $0x3,%eax
80102e0c:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102e13:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e16:	01 d0                	add    %edx,%eax
80102e18:	0f b6 00             	movzbl (%eax),%eax
80102e1b:	0f b6 c0             	movzbl %al,%eax
80102e1e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e21:	a1 5c 12 11 80       	mov    0x8011125c,%eax
80102e26:	83 e0 08             	and    $0x8,%eax
80102e29:	85 c0                	test   %eax,%eax
80102e2b:	74 22                	je     80102e4f <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e2d:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e31:	76 0c                	jbe    80102e3f <kbdgetc+0x13a>
80102e33:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e37:	77 06                	ja     80102e3f <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e39:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e3d:	eb 10                	jmp    80102e4f <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e3f:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e43:	76 0a                	jbe    80102e4f <kbdgetc+0x14a>
80102e45:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e49:	77 04                	ja     80102e4f <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e4b:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e52:	c9                   	leave  
80102e53:	c3                   	ret    

80102e54 <kbdintr>:

void
kbdintr(void)
{
80102e54:	55                   	push   %ebp
80102e55:	89 e5                	mov    %esp,%ebp
80102e57:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e5a:	83 ec 0c             	sub    $0xc,%esp
80102e5d:	68 05 2d 10 80       	push   $0x80102d05
80102e62:	e8 b5 d9 ff ff       	call   8010081c <consoleintr>
80102e67:	83 c4 10             	add    $0x10,%esp
}
80102e6a:	90                   	nop
80102e6b:	c9                   	leave  
80102e6c:	c3                   	ret    

80102e6d <inb>:
{
80102e6d:	55                   	push   %ebp
80102e6e:	89 e5                	mov    %esp,%ebp
80102e70:	83 ec 14             	sub    $0x14,%esp
80102e73:	8b 45 08             	mov    0x8(%ebp),%eax
80102e76:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e7a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e7e:	89 c2                	mov    %eax,%edx
80102e80:	ec                   	in     (%dx),%al
80102e81:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e84:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e88:	c9                   	leave  
80102e89:	c3                   	ret    

80102e8a <outb>:
{
80102e8a:	55                   	push   %ebp
80102e8b:	89 e5                	mov    %esp,%ebp
80102e8d:	83 ec 08             	sub    $0x8,%esp
80102e90:	8b 45 08             	mov    0x8(%ebp),%eax
80102e93:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e96:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e9a:	89 d0                	mov    %edx,%eax
80102e9c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e9f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102ea3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102ea7:	ee                   	out    %al,(%dx)
}
80102ea8:	90                   	nop
80102ea9:	c9                   	leave  
80102eaa:	c3                   	ret    

80102eab <readeflags>:
{
80102eab:	55                   	push   %ebp
80102eac:	89 e5                	mov    %esp,%ebp
80102eae:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102eb1:	9c                   	pushf  
80102eb2:	58                   	pop    %eax
80102eb3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102eb6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102eb9:	c9                   	leave  
80102eba:	c3                   	ret    

80102ebb <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102ebb:	55                   	push   %ebp
80102ebc:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ebe:	8b 15 60 12 11 80    	mov    0x80111260,%edx
80102ec4:	8b 45 08             	mov    0x8(%ebp),%eax
80102ec7:	c1 e0 02             	shl    $0x2,%eax
80102eca:	01 c2                	add    %eax,%edx
80102ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ecf:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102ed1:	a1 60 12 11 80       	mov    0x80111260,%eax
80102ed6:	83 c0 20             	add    $0x20,%eax
80102ed9:	8b 00                	mov    (%eax),%eax
}
80102edb:	90                   	nop
80102edc:	5d                   	pop    %ebp
80102edd:	c3                   	ret    

80102ede <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102ede:	55                   	push   %ebp
80102edf:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102ee1:	a1 60 12 11 80       	mov    0x80111260,%eax
80102ee6:	85 c0                	test   %eax,%eax
80102ee8:	0f 84 0c 01 00 00    	je     80102ffa <lapicinit+0x11c>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102eee:	68 3f 01 00 00       	push   $0x13f
80102ef3:	6a 3c                	push   $0x3c
80102ef5:	e8 c1 ff ff ff       	call   80102ebb <lapicw>
80102efa:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102efd:	6a 0b                	push   $0xb
80102eff:	68 f8 00 00 00       	push   $0xf8
80102f04:	e8 b2 ff ff ff       	call   80102ebb <lapicw>
80102f09:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102f0c:	68 20 00 02 00       	push   $0x20020
80102f11:	68 c8 00 00 00       	push   $0xc8
80102f16:	e8 a0 ff ff ff       	call   80102ebb <lapicw>
80102f1b:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102f1e:	68 80 96 98 00       	push   $0x989680
80102f23:	68 e0 00 00 00       	push   $0xe0
80102f28:	e8 8e ff ff ff       	call   80102ebb <lapicw>
80102f2d:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f30:	68 00 00 01 00       	push   $0x10000
80102f35:	68 d4 00 00 00       	push   $0xd4
80102f3a:	e8 7c ff ff ff       	call   80102ebb <lapicw>
80102f3f:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102f42:	68 00 00 01 00       	push   $0x10000
80102f47:	68 d8 00 00 00       	push   $0xd8
80102f4c:	e8 6a ff ff ff       	call   80102ebb <lapicw>
80102f51:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f54:	a1 60 12 11 80       	mov    0x80111260,%eax
80102f59:	83 c0 30             	add    $0x30,%eax
80102f5c:	8b 00                	mov    (%eax),%eax
80102f5e:	c1 e8 10             	shr    $0x10,%eax
80102f61:	25 fc 00 00 00       	and    $0xfc,%eax
80102f66:	85 c0                	test   %eax,%eax
80102f68:	74 12                	je     80102f7c <lapicinit+0x9e>
    lapicw(PCINT, MASKED);
80102f6a:	68 00 00 01 00       	push   $0x10000
80102f6f:	68 d0 00 00 00       	push   $0xd0
80102f74:	e8 42 ff ff ff       	call   80102ebb <lapicw>
80102f79:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f7c:	6a 33                	push   $0x33
80102f7e:	68 dc 00 00 00       	push   $0xdc
80102f83:	e8 33 ff ff ff       	call   80102ebb <lapicw>
80102f88:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f8b:	6a 00                	push   $0x0
80102f8d:	68 a0 00 00 00       	push   $0xa0
80102f92:	e8 24 ff ff ff       	call   80102ebb <lapicw>
80102f97:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f9a:	6a 00                	push   $0x0
80102f9c:	68 a0 00 00 00       	push   $0xa0
80102fa1:	e8 15 ff ff ff       	call   80102ebb <lapicw>
80102fa6:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fa9:	6a 00                	push   $0x0
80102fab:	6a 2c                	push   $0x2c
80102fad:	e8 09 ff ff ff       	call   80102ebb <lapicw>
80102fb2:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fb5:	6a 00                	push   $0x0
80102fb7:	68 c4 00 00 00       	push   $0xc4
80102fbc:	e8 fa fe ff ff       	call   80102ebb <lapicw>
80102fc1:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fc4:	68 00 85 08 00       	push   $0x88500
80102fc9:	68 c0 00 00 00       	push   $0xc0
80102fce:	e8 e8 fe ff ff       	call   80102ebb <lapicw>
80102fd3:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102fd6:	90                   	nop
80102fd7:	a1 60 12 11 80       	mov    0x80111260,%eax
80102fdc:	05 00 03 00 00       	add    $0x300,%eax
80102fe1:	8b 00                	mov    (%eax),%eax
80102fe3:	25 00 10 00 00       	and    $0x1000,%eax
80102fe8:	85 c0                	test   %eax,%eax
80102fea:	75 eb                	jne    80102fd7 <lapicinit+0xf9>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fec:	6a 00                	push   $0x0
80102fee:	6a 20                	push   $0x20
80102ff0:	e8 c6 fe ff ff       	call   80102ebb <lapicw>
80102ff5:	83 c4 08             	add    $0x8,%esp
80102ff8:	eb 01                	jmp    80102ffb <lapicinit+0x11d>
    return;
80102ffa:	90                   	nop
}
80102ffb:	c9                   	leave  
80102ffc:	c3                   	ret    

80102ffd <cpunum>:

int
cpunum(void)
{
80102ffd:	55                   	push   %ebp
80102ffe:	89 e5                	mov    %esp,%ebp
80103000:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80103003:	e8 a3 fe ff ff       	call   80102eab <readeflags>
80103008:	25 00 02 00 00       	and    $0x200,%eax
8010300d:	85 c0                	test   %eax,%eax
8010300f:	74 26                	je     80103037 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80103011:	a1 64 12 11 80       	mov    0x80111264,%eax
80103016:	8d 50 01             	lea    0x1(%eax),%edx
80103019:	89 15 64 12 11 80    	mov    %edx,0x80111264
8010301f:	85 c0                	test   %eax,%eax
80103021:	75 14                	jne    80103037 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80103023:	8b 45 04             	mov    0x4(%ebp),%eax
80103026:	83 ec 08             	sub    $0x8,%esp
80103029:	50                   	push   %eax
8010302a:	68 c4 89 10 80       	push   $0x801089c4
8010302f:	e8 92 d3 ff ff       	call   801003c6 <cprintf>
80103034:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80103037:	a1 60 12 11 80       	mov    0x80111260,%eax
8010303c:	85 c0                	test   %eax,%eax
8010303e:	74 0f                	je     8010304f <cpunum+0x52>
    return lapic[ID]>>24;
80103040:	a1 60 12 11 80       	mov    0x80111260,%eax
80103045:	83 c0 20             	add    $0x20,%eax
80103048:	8b 00                	mov    (%eax),%eax
8010304a:	c1 e8 18             	shr    $0x18,%eax
8010304d:	eb 05                	jmp    80103054 <cpunum+0x57>
  return 0;
8010304f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103054:	c9                   	leave  
80103055:	c3                   	ret    

80103056 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103056:	55                   	push   %ebp
80103057:	89 e5                	mov    %esp,%ebp
  if(lapic)
80103059:	a1 60 12 11 80       	mov    0x80111260,%eax
8010305e:	85 c0                	test   %eax,%eax
80103060:	74 0c                	je     8010306e <lapiceoi+0x18>
    lapicw(EOI, 0);
80103062:	6a 00                	push   $0x0
80103064:	6a 2c                	push   $0x2c
80103066:	e8 50 fe ff ff       	call   80102ebb <lapicw>
8010306b:	83 c4 08             	add    $0x8,%esp
}
8010306e:	90                   	nop
8010306f:	c9                   	leave  
80103070:	c3                   	ret    

80103071 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103071:	55                   	push   %ebp
80103072:	89 e5                	mov    %esp,%ebp
}
80103074:	90                   	nop
80103075:	5d                   	pop    %ebp
80103076:	c3                   	ret    

80103077 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103077:	55                   	push   %ebp
80103078:	89 e5                	mov    %esp,%ebp
8010307a:	83 ec 14             	sub    $0x14,%esp
8010307d:	8b 45 08             	mov    0x8(%ebp),%eax
80103080:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103083:	6a 0f                	push   $0xf
80103085:	6a 70                	push   $0x70
80103087:	e8 fe fd ff ff       	call   80102e8a <outb>
8010308c:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
8010308f:	6a 0a                	push   $0xa
80103091:	6a 71                	push   $0x71
80103093:	e8 f2 fd ff ff       	call   80102e8a <outb>
80103098:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010309b:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030a2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030a5:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801030ad:	c1 e8 04             	shr    $0x4,%eax
801030b0:	89 c2                	mov    %eax,%edx
801030b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030b5:	83 c0 02             	add    $0x2,%eax
801030b8:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030bb:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030bf:	c1 e0 18             	shl    $0x18,%eax
801030c2:	50                   	push   %eax
801030c3:	68 c4 00 00 00       	push   $0xc4
801030c8:	e8 ee fd ff ff       	call   80102ebb <lapicw>
801030cd:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030d0:	68 00 c5 00 00       	push   $0xc500
801030d5:	68 c0 00 00 00       	push   $0xc0
801030da:	e8 dc fd ff ff       	call   80102ebb <lapicw>
801030df:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
801030e2:	68 c8 00 00 00       	push   $0xc8
801030e7:	e8 85 ff ff ff       	call   80103071 <microdelay>
801030ec:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030ef:	68 00 85 00 00       	push   $0x8500
801030f4:	68 c0 00 00 00       	push   $0xc0
801030f9:	e8 bd fd ff ff       	call   80102ebb <lapicw>
801030fe:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103101:	6a 64                	push   $0x64
80103103:	e8 69 ff ff ff       	call   80103071 <microdelay>
80103108:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010310b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103112:	eb 3d                	jmp    80103151 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80103114:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103118:	c1 e0 18             	shl    $0x18,%eax
8010311b:	50                   	push   %eax
8010311c:	68 c4 00 00 00       	push   $0xc4
80103121:	e8 95 fd ff ff       	call   80102ebb <lapicw>
80103126:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103129:	8b 45 0c             	mov    0xc(%ebp),%eax
8010312c:	c1 e8 0c             	shr    $0xc,%eax
8010312f:	80 cc 06             	or     $0x6,%ah
80103132:	50                   	push   %eax
80103133:	68 c0 00 00 00       	push   $0xc0
80103138:	e8 7e fd ff ff       	call   80102ebb <lapicw>
8010313d:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80103140:	68 c8 00 00 00       	push   $0xc8
80103145:	e8 27 ff ff ff       	call   80103071 <microdelay>
8010314a:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
8010314d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103151:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103155:	7e bd                	jle    80103114 <lapicstartap+0x9d>
  }
}
80103157:	90                   	nop
80103158:	90                   	nop
80103159:	c9                   	leave  
8010315a:	c3                   	ret    

8010315b <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010315b:	55                   	push   %ebp
8010315c:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010315e:	8b 45 08             	mov    0x8(%ebp),%eax
80103161:	0f b6 c0             	movzbl %al,%eax
80103164:	50                   	push   %eax
80103165:	6a 70                	push   $0x70
80103167:	e8 1e fd ff ff       	call   80102e8a <outb>
8010316c:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010316f:	68 c8 00 00 00       	push   $0xc8
80103174:	e8 f8 fe ff ff       	call   80103071 <microdelay>
80103179:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010317c:	6a 71                	push   $0x71
8010317e:	e8 ea fc ff ff       	call   80102e6d <inb>
80103183:	83 c4 04             	add    $0x4,%esp
80103186:	0f b6 c0             	movzbl %al,%eax
}
80103189:	c9                   	leave  
8010318a:	c3                   	ret    

8010318b <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010318b:	55                   	push   %ebp
8010318c:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010318e:	6a 00                	push   $0x0
80103190:	e8 c6 ff ff ff       	call   8010315b <cmos_read>
80103195:	83 c4 04             	add    $0x4,%esp
80103198:	8b 55 08             	mov    0x8(%ebp),%edx
8010319b:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010319d:	6a 02                	push   $0x2
8010319f:	e8 b7 ff ff ff       	call   8010315b <cmos_read>
801031a4:	83 c4 04             	add    $0x4,%esp
801031a7:	8b 55 08             	mov    0x8(%ebp),%edx
801031aa:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801031ad:	6a 04                	push   $0x4
801031af:	e8 a7 ff ff ff       	call   8010315b <cmos_read>
801031b4:	83 c4 04             	add    $0x4,%esp
801031b7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ba:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031bd:	6a 07                	push   $0x7
801031bf:	e8 97 ff ff ff       	call   8010315b <cmos_read>
801031c4:	83 c4 04             	add    $0x4,%esp
801031c7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ca:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031cd:	6a 08                	push   $0x8
801031cf:	e8 87 ff ff ff       	call   8010315b <cmos_read>
801031d4:	83 c4 04             	add    $0x4,%esp
801031d7:	8b 55 08             	mov    0x8(%ebp),%edx
801031da:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031dd:	6a 09                	push   $0x9
801031df:	e8 77 ff ff ff       	call   8010315b <cmos_read>
801031e4:	83 c4 04             	add    $0x4,%esp
801031e7:	8b 55 08             	mov    0x8(%ebp),%edx
801031ea:	89 42 14             	mov    %eax,0x14(%edx)
}
801031ed:	90                   	nop
801031ee:	c9                   	leave  
801031ef:	c3                   	ret    

801031f0 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031f0:	55                   	push   %ebp
801031f1:	89 e5                	mov    %esp,%ebp
801031f3:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031f6:	6a 0b                	push   $0xb
801031f8:	e8 5e ff ff ff       	call   8010315b <cmos_read>
801031fd:	83 c4 04             	add    $0x4,%esp
80103200:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103203:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103206:	83 e0 04             	and    $0x4,%eax
80103209:	85 c0                	test   %eax,%eax
8010320b:	0f 94 c0             	sete   %al
8010320e:	0f b6 c0             	movzbl %al,%eax
80103211:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
80103214:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103217:	50                   	push   %eax
80103218:	e8 6e ff ff ff       	call   8010318b <fill_rtcdate>
8010321d:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103220:	6a 0a                	push   $0xa
80103222:	e8 34 ff ff ff       	call   8010315b <cmos_read>
80103227:	83 c4 04             	add    $0x4,%esp
8010322a:	25 80 00 00 00       	and    $0x80,%eax
8010322f:	85 c0                	test   %eax,%eax
80103231:	75 27                	jne    8010325a <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80103233:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103236:	50                   	push   %eax
80103237:	e8 4f ff ff ff       	call   8010318b <fill_rtcdate>
8010323c:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
8010323f:	83 ec 04             	sub    $0x4,%esp
80103242:	6a 18                	push   $0x18
80103244:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103247:	50                   	push   %eax
80103248:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010324b:	50                   	push   %eax
8010324c:	e8 02 21 00 00       	call   80105353 <memcmp>
80103251:	83 c4 10             	add    $0x10,%esp
80103254:	85 c0                	test   %eax,%eax
80103256:	74 05                	je     8010325d <cmostime+0x6d>
80103258:	eb ba                	jmp    80103214 <cmostime+0x24>
        continue;
8010325a:	90                   	nop
    fill_rtcdate(&t1);
8010325b:	eb b7                	jmp    80103214 <cmostime+0x24>
      break;
8010325d:	90                   	nop
  }

  // convert
  if (bcd) {
8010325e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103262:	0f 84 b4 00 00 00    	je     8010331c <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103268:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010326b:	c1 e8 04             	shr    $0x4,%eax
8010326e:	89 c2                	mov    %eax,%edx
80103270:	89 d0                	mov    %edx,%eax
80103272:	c1 e0 02             	shl    $0x2,%eax
80103275:	01 d0                	add    %edx,%eax
80103277:	01 c0                	add    %eax,%eax
80103279:	89 c2                	mov    %eax,%edx
8010327b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010327e:	83 e0 0f             	and    $0xf,%eax
80103281:	01 d0                	add    %edx,%eax
80103283:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103286:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103289:	c1 e8 04             	shr    $0x4,%eax
8010328c:	89 c2                	mov    %eax,%edx
8010328e:	89 d0                	mov    %edx,%eax
80103290:	c1 e0 02             	shl    $0x2,%eax
80103293:	01 d0                	add    %edx,%eax
80103295:	01 c0                	add    %eax,%eax
80103297:	89 c2                	mov    %eax,%edx
80103299:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010329c:	83 e0 0f             	and    $0xf,%eax
8010329f:	01 d0                	add    %edx,%eax
801032a1:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801032a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032a7:	c1 e8 04             	shr    $0x4,%eax
801032aa:	89 c2                	mov    %eax,%edx
801032ac:	89 d0                	mov    %edx,%eax
801032ae:	c1 e0 02             	shl    $0x2,%eax
801032b1:	01 d0                	add    %edx,%eax
801032b3:	01 c0                	add    %eax,%eax
801032b5:	89 c2                	mov    %eax,%edx
801032b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801032ba:	83 e0 0f             	and    $0xf,%eax
801032bd:	01 d0                	add    %edx,%eax
801032bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801032c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032c5:	c1 e8 04             	shr    $0x4,%eax
801032c8:	89 c2                	mov    %eax,%edx
801032ca:	89 d0                	mov    %edx,%eax
801032cc:	c1 e0 02             	shl    $0x2,%eax
801032cf:	01 d0                	add    %edx,%eax
801032d1:	01 c0                	add    %eax,%eax
801032d3:	89 c2                	mov    %eax,%edx
801032d5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801032d8:	83 e0 0f             	and    $0xf,%eax
801032db:	01 d0                	add    %edx,%eax
801032dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
801032e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032e3:	c1 e8 04             	shr    $0x4,%eax
801032e6:	89 c2                	mov    %eax,%edx
801032e8:	89 d0                	mov    %edx,%eax
801032ea:	c1 e0 02             	shl    $0x2,%eax
801032ed:	01 d0                	add    %edx,%eax
801032ef:	01 c0                	add    %eax,%eax
801032f1:	89 c2                	mov    %eax,%edx
801032f3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032f6:	83 e0 0f             	and    $0xf,%eax
801032f9:	01 d0                	add    %edx,%eax
801032fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103301:	c1 e8 04             	shr    $0x4,%eax
80103304:	89 c2                	mov    %eax,%edx
80103306:	89 d0                	mov    %edx,%eax
80103308:	c1 e0 02             	shl    $0x2,%eax
8010330b:	01 d0                	add    %edx,%eax
8010330d:	01 c0                	add    %eax,%eax
8010330f:	89 c2                	mov    %eax,%edx
80103311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103314:	83 e0 0f             	and    $0xf,%eax
80103317:	01 d0                	add    %edx,%eax
80103319:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
8010331c:	8b 45 08             	mov    0x8(%ebp),%eax
8010331f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103322:	89 10                	mov    %edx,(%eax)
80103324:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103327:	89 50 04             	mov    %edx,0x4(%eax)
8010332a:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010332d:	89 50 08             	mov    %edx,0x8(%eax)
80103330:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103333:	89 50 0c             	mov    %edx,0xc(%eax)
80103336:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103339:	89 50 10             	mov    %edx,0x10(%eax)
8010333c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010333f:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103342:	8b 45 08             	mov    0x8(%ebp),%eax
80103345:	8b 40 14             	mov    0x14(%eax),%eax
80103348:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010334e:	8b 45 08             	mov    0x8(%ebp),%eax
80103351:	89 50 14             	mov    %edx,0x14(%eax)
}
80103354:	90                   	nop
80103355:	c9                   	leave  
80103356:	c3                   	ret    

80103357 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103357:	55                   	push   %ebp
80103358:	89 e5                	mov    %esp,%ebp
8010335a:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010335d:	83 ec 08             	sub    $0x8,%esp
80103360:	68 f0 89 10 80       	push   $0x801089f0
80103365:	68 80 12 11 80       	push   $0x80111280
8010336a:	e8 f8 1c 00 00       	call   80105067 <initlock>
8010336f:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80103372:	83 ec 08             	sub    $0x8,%esp
80103375:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103378:	50                   	push   %eax
80103379:	ff 75 08             	push   0x8(%ebp)
8010337c:	e8 30 e0 ff ff       	call   801013b1 <readsb>
80103381:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103384:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103387:	a3 b4 12 11 80       	mov    %eax,0x801112b4
  log.size = sb.nlog;
8010338c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010338f:	a3 b8 12 11 80       	mov    %eax,0x801112b8
  log.dev = dev;
80103394:	8b 45 08             	mov    0x8(%ebp),%eax
80103397:	a3 c4 12 11 80       	mov    %eax,0x801112c4
  recover_from_log();
8010339c:	e8 b3 01 00 00       	call   80103554 <recover_from_log>
}
801033a1:	90                   	nop
801033a2:	c9                   	leave  
801033a3:	c3                   	ret    

801033a4 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801033a4:	55                   	push   %ebp
801033a5:	89 e5                	mov    %esp,%ebp
801033a7:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033b1:	e9 95 00 00 00       	jmp    8010344b <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033b6:	8b 15 b4 12 11 80    	mov    0x801112b4,%edx
801033bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033bf:	01 d0                	add    %edx,%eax
801033c1:	83 c0 01             	add    $0x1,%eax
801033c4:	89 c2                	mov    %eax,%edx
801033c6:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801033cb:	83 ec 08             	sub    $0x8,%esp
801033ce:	52                   	push   %edx
801033cf:	50                   	push   %eax
801033d0:	e8 e2 cd ff ff       	call   801001b7 <bread>
801033d5:	83 c4 10             	add    $0x10,%esp
801033d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033de:	83 c0 10             	add    $0x10,%eax
801033e1:	8b 04 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%eax
801033e8:	89 c2                	mov    %eax,%edx
801033ea:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801033ef:	83 ec 08             	sub    $0x8,%esp
801033f2:	52                   	push   %edx
801033f3:	50                   	push   %eax
801033f4:	e8 be cd ff ff       	call   801001b7 <bread>
801033f9:	83 c4 10             	add    $0x10,%esp
801033fc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103402:	8d 50 18             	lea    0x18(%eax),%edx
80103405:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103408:	83 c0 18             	add    $0x18,%eax
8010340b:	83 ec 04             	sub    $0x4,%esp
8010340e:	68 00 02 00 00       	push   $0x200
80103413:	52                   	push   %edx
80103414:	50                   	push   %eax
80103415:	e8 91 1f 00 00       	call   801053ab <memmove>
8010341a:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010341d:	83 ec 0c             	sub    $0xc,%esp
80103420:	ff 75 ec             	push   -0x14(%ebp)
80103423:	e8 c8 cd ff ff       	call   801001f0 <bwrite>
80103428:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
8010342b:	83 ec 0c             	sub    $0xc,%esp
8010342e:	ff 75 f0             	push   -0x10(%ebp)
80103431:	e8 f9 cd ff ff       	call   8010022f <brelse>
80103436:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103439:	83 ec 0c             	sub    $0xc,%esp
8010343c:	ff 75 ec             	push   -0x14(%ebp)
8010343f:	e8 eb cd ff ff       	call   8010022f <brelse>
80103444:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103447:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010344b:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80103450:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103453:	0f 8c 5d ff ff ff    	jl     801033b6 <install_trans+0x12>
  }
}
80103459:	90                   	nop
8010345a:	90                   	nop
8010345b:	c9                   	leave  
8010345c:	c3                   	ret    

8010345d <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010345d:	55                   	push   %ebp
8010345e:	89 e5                	mov    %esp,%ebp
80103460:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103463:	a1 b4 12 11 80       	mov    0x801112b4,%eax
80103468:	89 c2                	mov    %eax,%edx
8010346a:	a1 c4 12 11 80       	mov    0x801112c4,%eax
8010346f:	83 ec 08             	sub    $0x8,%esp
80103472:	52                   	push   %edx
80103473:	50                   	push   %eax
80103474:	e8 3e cd ff ff       	call   801001b7 <bread>
80103479:	83 c4 10             	add    $0x10,%esp
8010347c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010347f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103482:	83 c0 18             	add    $0x18,%eax
80103485:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103488:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010348b:	8b 00                	mov    (%eax),%eax
8010348d:	a3 c8 12 11 80       	mov    %eax,0x801112c8
  for (i = 0; i < log.lh.n; i++) {
80103492:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103499:	eb 1b                	jmp    801034b6 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
8010349b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010349e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a1:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a8:	83 c2 10             	add    $0x10,%edx
801034ab:	89 04 95 8c 12 11 80 	mov    %eax,-0x7feeed74(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801034b2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034b6:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801034bb:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801034be:	7c db                	jl     8010349b <read_head+0x3e>
  }
  brelse(buf);
801034c0:	83 ec 0c             	sub    $0xc,%esp
801034c3:	ff 75 f0             	push   -0x10(%ebp)
801034c6:	e8 64 cd ff ff       	call   8010022f <brelse>
801034cb:	83 c4 10             	add    $0x10,%esp
}
801034ce:	90                   	nop
801034cf:	c9                   	leave  
801034d0:	c3                   	ret    

801034d1 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034d1:	55                   	push   %ebp
801034d2:	89 e5                	mov    %esp,%ebp
801034d4:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801034d7:	a1 b4 12 11 80       	mov    0x801112b4,%eax
801034dc:	89 c2                	mov    %eax,%edx
801034de:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801034e3:	83 ec 08             	sub    $0x8,%esp
801034e6:	52                   	push   %edx
801034e7:	50                   	push   %eax
801034e8:	e8 ca cc ff ff       	call   801001b7 <bread>
801034ed:	83 c4 10             	add    $0x10,%esp
801034f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f6:	83 c0 18             	add    $0x18,%eax
801034f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034fc:	8b 15 c8 12 11 80    	mov    0x801112c8,%edx
80103502:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103505:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103507:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010350e:	eb 1b                	jmp    8010352b <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80103510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103513:	83 c0 10             	add    $0x10,%eax
80103516:	8b 0c 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%ecx
8010351d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103520:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103523:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80103527:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010352b:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80103530:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103533:	7c db                	jl     80103510 <write_head+0x3f>
  }
  bwrite(buf);
80103535:	83 ec 0c             	sub    $0xc,%esp
80103538:	ff 75 f0             	push   -0x10(%ebp)
8010353b:	e8 b0 cc ff ff       	call   801001f0 <bwrite>
80103540:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103543:	83 ec 0c             	sub    $0xc,%esp
80103546:	ff 75 f0             	push   -0x10(%ebp)
80103549:	e8 e1 cc ff ff       	call   8010022f <brelse>
8010354e:	83 c4 10             	add    $0x10,%esp
}
80103551:	90                   	nop
80103552:	c9                   	leave  
80103553:	c3                   	ret    

80103554 <recover_from_log>:

static void
recover_from_log(void)
{
80103554:	55                   	push   %ebp
80103555:	89 e5                	mov    %esp,%ebp
80103557:	83 ec 08             	sub    $0x8,%esp
  read_head();      
8010355a:	e8 fe fe ff ff       	call   8010345d <read_head>
  install_trans(); // if committed, copy from log to disk
8010355f:	e8 40 fe ff ff       	call   801033a4 <install_trans>
  log.lh.n = 0;
80103564:	c7 05 c8 12 11 80 00 	movl   $0x0,0x801112c8
8010356b:	00 00 00 
  write_head(); // clear the log
8010356e:	e8 5e ff ff ff       	call   801034d1 <write_head>
}
80103573:	90                   	nop
80103574:	c9                   	leave  
80103575:	c3                   	ret    

80103576 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103576:	55                   	push   %ebp
80103577:	89 e5                	mov    %esp,%ebp
80103579:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
8010357c:	83 ec 0c             	sub    $0xc,%esp
8010357f:	68 80 12 11 80       	push   $0x80111280
80103584:	e8 00 1b 00 00       	call   80105089 <acquire>
80103589:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
8010358c:	a1 c0 12 11 80       	mov    0x801112c0,%eax
80103591:	85 c0                	test   %eax,%eax
80103593:	74 17                	je     801035ac <begin_op+0x36>
      sleep(&log, &log.lock);
80103595:	83 ec 08             	sub    $0x8,%esp
80103598:	68 80 12 11 80       	push   $0x80111280
8010359d:	68 80 12 11 80       	push   $0x80111280
801035a2:	e8 e7 17 00 00       	call   80104d8e <sleep>
801035a7:	83 c4 10             	add    $0x10,%esp
801035aa:	eb e0                	jmp    8010358c <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801035ac:	8b 0d c8 12 11 80    	mov    0x801112c8,%ecx
801035b2:	a1 bc 12 11 80       	mov    0x801112bc,%eax
801035b7:	8d 50 01             	lea    0x1(%eax),%edx
801035ba:	89 d0                	mov    %edx,%eax
801035bc:	c1 e0 02             	shl    $0x2,%eax
801035bf:	01 d0                	add    %edx,%eax
801035c1:	01 c0                	add    %eax,%eax
801035c3:	01 c8                	add    %ecx,%eax
801035c5:	83 f8 1e             	cmp    $0x1e,%eax
801035c8:	7e 17                	jle    801035e1 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035ca:	83 ec 08             	sub    $0x8,%esp
801035cd:	68 80 12 11 80       	push   $0x80111280
801035d2:	68 80 12 11 80       	push   $0x80111280
801035d7:	e8 b2 17 00 00       	call   80104d8e <sleep>
801035dc:	83 c4 10             	add    $0x10,%esp
801035df:	eb ab                	jmp    8010358c <begin_op+0x16>
    } else {
      log.outstanding += 1;
801035e1:	a1 bc 12 11 80       	mov    0x801112bc,%eax
801035e6:	83 c0 01             	add    $0x1,%eax
801035e9:	a3 bc 12 11 80       	mov    %eax,0x801112bc
      release(&log.lock);
801035ee:	83 ec 0c             	sub    $0xc,%esp
801035f1:	68 80 12 11 80       	push   $0x80111280
801035f6:	e8 f5 1a 00 00       	call   801050f0 <release>
801035fb:	83 c4 10             	add    $0x10,%esp
      break;
801035fe:	90                   	nop
    }
  }
}
801035ff:	90                   	nop
80103600:	c9                   	leave  
80103601:	c3                   	ret    

80103602 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103602:	55                   	push   %ebp
80103603:	89 e5                	mov    %esp,%ebp
80103605:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103608:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010360f:	83 ec 0c             	sub    $0xc,%esp
80103612:	68 80 12 11 80       	push   $0x80111280
80103617:	e8 6d 1a 00 00       	call   80105089 <acquire>
8010361c:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010361f:	a1 bc 12 11 80       	mov    0x801112bc,%eax
80103624:	83 e8 01             	sub    $0x1,%eax
80103627:	a3 bc 12 11 80       	mov    %eax,0x801112bc
  if(log.committing)
8010362c:	a1 c0 12 11 80       	mov    0x801112c0,%eax
80103631:	85 c0                	test   %eax,%eax
80103633:	74 0d                	je     80103642 <end_op+0x40>
    panic("log.committing");
80103635:	83 ec 0c             	sub    $0xc,%esp
80103638:	68 f4 89 10 80       	push   $0x801089f4
8010363d:	e8 39 cf ff ff       	call   8010057b <panic>
  if(log.outstanding == 0){
80103642:	a1 bc 12 11 80       	mov    0x801112bc,%eax
80103647:	85 c0                	test   %eax,%eax
80103649:	75 13                	jne    8010365e <end_op+0x5c>
    do_commit = 1;
8010364b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103652:	c7 05 c0 12 11 80 01 	movl   $0x1,0x801112c0
80103659:	00 00 00 
8010365c:	eb 10                	jmp    8010366e <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010365e:	83 ec 0c             	sub    $0xc,%esp
80103661:	68 80 12 11 80       	push   $0x80111280
80103666:	e8 0f 18 00 00       	call   80104e7a <wakeup>
8010366b:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010366e:	83 ec 0c             	sub    $0xc,%esp
80103671:	68 80 12 11 80       	push   $0x80111280
80103676:	e8 75 1a 00 00       	call   801050f0 <release>
8010367b:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010367e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103682:	74 3f                	je     801036c3 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103684:	e8 f6 00 00 00       	call   8010377f <commit>
    acquire(&log.lock);
80103689:	83 ec 0c             	sub    $0xc,%esp
8010368c:	68 80 12 11 80       	push   $0x80111280
80103691:	e8 f3 19 00 00       	call   80105089 <acquire>
80103696:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103699:	c7 05 c0 12 11 80 00 	movl   $0x0,0x801112c0
801036a0:	00 00 00 
    wakeup(&log);
801036a3:	83 ec 0c             	sub    $0xc,%esp
801036a6:	68 80 12 11 80       	push   $0x80111280
801036ab:	e8 ca 17 00 00       	call   80104e7a <wakeup>
801036b0:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801036b3:	83 ec 0c             	sub    $0xc,%esp
801036b6:	68 80 12 11 80       	push   $0x80111280
801036bb:	e8 30 1a 00 00       	call   801050f0 <release>
801036c0:	83 c4 10             	add    $0x10,%esp
  }
}
801036c3:	90                   	nop
801036c4:	c9                   	leave  
801036c5:	c3                   	ret    

801036c6 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
801036c6:	55                   	push   %ebp
801036c7:	89 e5                	mov    %esp,%ebp
801036c9:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036d3:	e9 95 00 00 00       	jmp    8010376d <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801036d8:	8b 15 b4 12 11 80    	mov    0x801112b4,%edx
801036de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036e1:	01 d0                	add    %edx,%eax
801036e3:	83 c0 01             	add    $0x1,%eax
801036e6:	89 c2                	mov    %eax,%edx
801036e8:	a1 c4 12 11 80       	mov    0x801112c4,%eax
801036ed:	83 ec 08             	sub    $0x8,%esp
801036f0:	52                   	push   %edx
801036f1:	50                   	push   %eax
801036f2:	e8 c0 ca ff ff       	call   801001b7 <bread>
801036f7:	83 c4 10             	add    $0x10,%esp
801036fa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103700:	83 c0 10             	add    $0x10,%eax
80103703:	8b 04 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%eax
8010370a:	89 c2                	mov    %eax,%edx
8010370c:	a1 c4 12 11 80       	mov    0x801112c4,%eax
80103711:	83 ec 08             	sub    $0x8,%esp
80103714:	52                   	push   %edx
80103715:	50                   	push   %eax
80103716:	e8 9c ca ff ff       	call   801001b7 <bread>
8010371b:	83 c4 10             	add    $0x10,%esp
8010371e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103721:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103724:	8d 50 18             	lea    0x18(%eax),%edx
80103727:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010372a:	83 c0 18             	add    $0x18,%eax
8010372d:	83 ec 04             	sub    $0x4,%esp
80103730:	68 00 02 00 00       	push   $0x200
80103735:	52                   	push   %edx
80103736:	50                   	push   %eax
80103737:	e8 6f 1c 00 00       	call   801053ab <memmove>
8010373c:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010373f:	83 ec 0c             	sub    $0xc,%esp
80103742:	ff 75 f0             	push   -0x10(%ebp)
80103745:	e8 a6 ca ff ff       	call   801001f0 <bwrite>
8010374a:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010374d:	83 ec 0c             	sub    $0xc,%esp
80103750:	ff 75 ec             	push   -0x14(%ebp)
80103753:	e8 d7 ca ff ff       	call   8010022f <brelse>
80103758:	83 c4 10             	add    $0x10,%esp
    brelse(to);
8010375b:	83 ec 0c             	sub    $0xc,%esp
8010375e:	ff 75 f0             	push   -0x10(%ebp)
80103761:	e8 c9 ca ff ff       	call   8010022f <brelse>
80103766:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103769:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010376d:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80103772:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103775:	0f 8c 5d ff ff ff    	jl     801036d8 <write_log+0x12>
  }
}
8010377b:	90                   	nop
8010377c:	90                   	nop
8010377d:	c9                   	leave  
8010377e:	c3                   	ret    

8010377f <commit>:

static void
commit()
{
8010377f:	55                   	push   %ebp
80103780:	89 e5                	mov    %esp,%ebp
80103782:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103785:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010378a:	85 c0                	test   %eax,%eax
8010378c:	7e 1e                	jle    801037ac <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010378e:	e8 33 ff ff ff       	call   801036c6 <write_log>
    write_head();    // Write header to disk -- the real commit
80103793:	e8 39 fd ff ff       	call   801034d1 <write_head>
    install_trans(); // Now install writes to home locations
80103798:	e8 07 fc ff ff       	call   801033a4 <install_trans>
    log.lh.n = 0; 
8010379d:	c7 05 c8 12 11 80 00 	movl   $0x0,0x801112c8
801037a4:	00 00 00 
    write_head();    // Erase the transaction from the log
801037a7:	e8 25 fd ff ff       	call   801034d1 <write_head>
  }
}
801037ac:	90                   	nop
801037ad:	c9                   	leave  
801037ae:	c3                   	ret    

801037af <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801037af:	55                   	push   %ebp
801037b0:	89 e5                	mov    %esp,%ebp
801037b2:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801037b5:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801037ba:	83 f8 1d             	cmp    $0x1d,%eax
801037bd:	7f 12                	jg     801037d1 <log_write+0x22>
801037bf:	a1 c8 12 11 80       	mov    0x801112c8,%eax
801037c4:	8b 15 b8 12 11 80    	mov    0x801112b8,%edx
801037ca:	83 ea 01             	sub    $0x1,%edx
801037cd:	39 d0                	cmp    %edx,%eax
801037cf:	7c 0d                	jl     801037de <log_write+0x2f>
    panic("too big a transaction");
801037d1:	83 ec 0c             	sub    $0xc,%esp
801037d4:	68 03 8a 10 80       	push   $0x80108a03
801037d9:	e8 9d cd ff ff       	call   8010057b <panic>
  if (log.outstanding < 1)
801037de:	a1 bc 12 11 80       	mov    0x801112bc,%eax
801037e3:	85 c0                	test   %eax,%eax
801037e5:	7f 0d                	jg     801037f4 <log_write+0x45>
    panic("log_write outside of trans");
801037e7:	83 ec 0c             	sub    $0xc,%esp
801037ea:	68 19 8a 10 80       	push   $0x80108a19
801037ef:	e8 87 cd ff ff       	call   8010057b <panic>

  acquire(&log.lock);
801037f4:	83 ec 0c             	sub    $0xc,%esp
801037f7:	68 80 12 11 80       	push   $0x80111280
801037fc:	e8 88 18 00 00       	call   80105089 <acquire>
80103801:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103804:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010380b:	eb 1d                	jmp    8010382a <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010380d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103810:	83 c0 10             	add    $0x10,%eax
80103813:	8b 04 85 8c 12 11 80 	mov    -0x7feeed74(,%eax,4),%eax
8010381a:	89 c2                	mov    %eax,%edx
8010381c:	8b 45 08             	mov    0x8(%ebp),%eax
8010381f:	8b 40 08             	mov    0x8(%eax),%eax
80103822:	39 c2                	cmp    %eax,%edx
80103824:	74 10                	je     80103836 <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
80103826:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010382a:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010382f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103832:	7c d9                	jl     8010380d <log_write+0x5e>
80103834:	eb 01                	jmp    80103837 <log_write+0x88>
      break;
80103836:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
80103837:	8b 45 08             	mov    0x8(%ebp),%eax
8010383a:	8b 40 08             	mov    0x8(%eax),%eax
8010383d:	89 c2                	mov    %eax,%edx
8010383f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103842:	83 c0 10             	add    $0x10,%eax
80103845:	89 14 85 8c 12 11 80 	mov    %edx,-0x7feeed74(,%eax,4)
  if (i == log.lh.n)
8010384c:	a1 c8 12 11 80       	mov    0x801112c8,%eax
80103851:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103854:	75 0d                	jne    80103863 <log_write+0xb4>
    log.lh.n++;
80103856:	a1 c8 12 11 80       	mov    0x801112c8,%eax
8010385b:	83 c0 01             	add    $0x1,%eax
8010385e:	a3 c8 12 11 80       	mov    %eax,0x801112c8
  b->flags |= B_DIRTY; // prevent eviction
80103863:	8b 45 08             	mov    0x8(%ebp),%eax
80103866:	8b 00                	mov    (%eax),%eax
80103868:	83 c8 04             	or     $0x4,%eax
8010386b:	89 c2                	mov    %eax,%edx
8010386d:	8b 45 08             	mov    0x8(%ebp),%eax
80103870:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103872:	83 ec 0c             	sub    $0xc,%esp
80103875:	68 80 12 11 80       	push   $0x80111280
8010387a:	e8 71 18 00 00       	call   801050f0 <release>
8010387f:	83 c4 10             	add    $0x10,%esp
}
80103882:	90                   	nop
80103883:	c9                   	leave  
80103884:	c3                   	ret    

80103885 <v2p>:
80103885:	55                   	push   %ebp
80103886:	89 e5                	mov    %esp,%ebp
80103888:	8b 45 08             	mov    0x8(%ebp),%eax
8010388b:	05 00 00 00 80       	add    $0x80000000,%eax
80103890:	5d                   	pop    %ebp
80103891:	c3                   	ret    

80103892 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80103892:	55                   	push   %ebp
80103893:	89 e5                	mov    %esp,%ebp
80103895:	8b 45 08             	mov    0x8(%ebp),%eax
80103898:	05 00 00 00 80       	add    $0x80000000,%eax
8010389d:	5d                   	pop    %ebp
8010389e:	c3                   	ret    

8010389f <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010389f:	55                   	push   %ebp
801038a0:	89 e5                	mov    %esp,%ebp
801038a2:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801038a5:	8b 55 08             	mov    0x8(%ebp),%edx
801038a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801038ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
801038ae:	f0 87 02             	lock xchg %eax,(%edx)
801038b1:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801038b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801038b7:	c9                   	leave  
801038b8:	c3                   	ret    

801038b9 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801038b9:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801038bd:	83 e4 f0             	and    $0xfffffff0,%esp
801038c0:	ff 71 fc             	push   -0x4(%ecx)
801038c3:	55                   	push   %ebp
801038c4:	89 e5                	mov    %esp,%ebp
801038c6:	51                   	push   %ecx
801038c7:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801038ca:	83 ec 08             	sub    $0x8,%esp
801038cd:	68 00 00 40 80       	push   $0x80400000
801038d2:	68 60 51 11 80       	push   $0x80115160
801038d7:	e8 65 f2 ff ff       	call   80102b41 <kinit1>
801038dc:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
801038df:	e8 20 47 00 00       	call   80108004 <kvmalloc>
  mpinit();        // collect info about this machine
801038e4:	e8 3a 04 00 00       	call   80103d23 <mpinit>
  lapicinit();
801038e9:	e8 f0 f5 ff ff       	call   80102ede <lapicinit>
  seginit();       // set up segments
801038ee:	e8 ba 40 00 00       	call   801079ad <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038f3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038f9:	0f b6 00             	movzbl (%eax),%eax
801038fc:	0f b6 c0             	movzbl %al,%eax
801038ff:	83 ec 08             	sub    $0x8,%esp
80103902:	50                   	push   %eax
80103903:	68 34 8a 10 80       	push   $0x80108a34
80103908:	e8 b9 ca ff ff       	call   801003c6 <cprintf>
8010390d:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
80103910:	e8 8a 06 00 00       	call   80103f9f <picinit>
  ioapicinit();    // another interrupt controller
80103915:	e8 1c f1 ff ff       	call   80102a36 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
8010391a:	e8 27 d2 ff ff       	call   80100b46 <consoleinit>
  uartinit();      // serial port
8010391f:	e8 e5 33 00 00       	call   80106d09 <uartinit>
  pinit();         // process table
80103924:	e8 7a 0b 00 00       	call   801044a3 <pinit>
  tvinit();        // trap vectors
80103929:	e8 a0 2e 00 00       	call   801067ce <tvinit>
  binit();         // buffer cache
8010392e:	e8 01 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103933:	e8 6a d6 ff ff       	call   80100fa2 <fileinit>
  ideinit();       // disk
80103938:	e8 01 ed ff ff       	call   8010263e <ideinit>
  if(!ismp)
8010393d:	a1 40 19 11 80       	mov    0x80111940,%eax
80103942:	85 c0                	test   %eax,%eax
80103944:	75 05                	jne    8010394b <main+0x92>
    timerinit();   // uniprocessor timer
80103946:	e8 e0 2d 00 00       	call   8010672b <timerinit>
  startothers();   // start other processors
8010394b:	e8 7f 00 00 00       	call   801039cf <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103950:	83 ec 08             	sub    $0x8,%esp
80103953:	68 00 00 00 8e       	push   $0x8e000000
80103958:	68 00 00 40 80       	push   $0x80400000
8010395d:	e8 18 f2 ff ff       	call   80102b7a <kinit2>
80103962:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103965:	e8 5b 0c 00 00       	call   801045c5 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
8010396a:	e8 1a 00 00 00       	call   80103989 <mpmain>

8010396f <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010396f:	55                   	push   %ebp
80103970:	89 e5                	mov    %esp,%ebp
80103972:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103975:	e8 a2 46 00 00       	call   8010801c <switchkvm>
  seginit();
8010397a:	e8 2e 40 00 00       	call   801079ad <seginit>
  lapicinit();
8010397f:	e8 5a f5 ff ff       	call   80102ede <lapicinit>
  mpmain();
80103984:	e8 00 00 00 00       	call   80103989 <mpmain>

80103989 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103989:	55                   	push   %ebp
8010398a:	89 e5                	mov    %esp,%ebp
8010398c:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010398f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103995:	0f b6 00             	movzbl (%eax),%eax
80103998:	0f b6 c0             	movzbl %al,%eax
8010399b:	83 ec 08             	sub    $0x8,%esp
8010399e:	50                   	push   %eax
8010399f:	68 4b 8a 10 80       	push   $0x80108a4b
801039a4:	e8 1d ca ff ff       	call   801003c6 <cprintf>
801039a9:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801039ac:	e8 93 2f 00 00       	call   80106944 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801039b1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801039b7:	05 a8 00 00 00       	add    $0xa8,%eax
801039bc:	83 ec 08             	sub    $0x8,%esp
801039bf:	6a 01                	push   $0x1
801039c1:	50                   	push   %eax
801039c2:	e8 d8 fe ff ff       	call   8010389f <xchg>
801039c7:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
801039ca:	e8 b9 11 00 00       	call   80104b88 <scheduler>

801039cf <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801039cf:	55                   	push   %ebp
801039d0:	89 e5                	mov    %esp,%ebp
801039d2:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
801039d5:	68 00 70 00 00       	push   $0x7000
801039da:	e8 b3 fe ff ff       	call   80103892 <p2v>
801039df:	83 c4 04             	add    $0x4,%esp
801039e2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039e5:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039ea:	83 ec 04             	sub    $0x4,%esp
801039ed:	50                   	push   %eax
801039ee:	68 2c b5 10 80       	push   $0x8010b52c
801039f3:	ff 75 f0             	push   -0x10(%ebp)
801039f6:	e8 b0 19 00 00       	call   801053ab <memmove>
801039fb:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039fe:	c7 45 f4 60 13 11 80 	movl   $0x80111360,-0xc(%ebp)
80103a05:	e9 8e 00 00 00       	jmp    80103a98 <startothers+0xc9>
    if(c == cpus+cpunum())  // We've started already.
80103a0a:	e8 ee f5 ff ff       	call   80102ffd <cpunum>
80103a0f:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a15:	05 60 13 11 80       	add    $0x80111360,%eax
80103a1a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1d:	74 71                	je     80103a90 <startothers+0xc1>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a1f:	e8 62 f2 ff ff       	call   80102c86 <kalloc>
80103a24:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a2a:	83 e8 04             	sub    $0x4,%eax
80103a2d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a30:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a36:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a3b:	83 e8 08             	sub    $0x8,%eax
80103a3e:	c7 00 6f 39 10 80    	movl   $0x8010396f,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a44:	83 ec 0c             	sub    $0xc,%esp
80103a47:	68 00 a0 10 80       	push   $0x8010a000
80103a4c:	e8 34 fe ff ff       	call   80103885 <v2p>
80103a51:	83 c4 10             	add    $0x10,%esp
80103a54:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103a57:	83 ea 0c             	sub    $0xc,%edx
80103a5a:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->id, v2p(code));
80103a5c:	83 ec 0c             	sub    $0xc,%esp
80103a5f:	ff 75 f0             	push   -0x10(%ebp)
80103a62:	e8 1e fe ff ff       	call   80103885 <v2p>
80103a67:	83 c4 10             	add    $0x10,%esp
80103a6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103a6d:	0f b6 12             	movzbl (%edx),%edx
80103a70:	0f b6 d2             	movzbl %dl,%edx
80103a73:	83 ec 08             	sub    $0x8,%esp
80103a76:	50                   	push   %eax
80103a77:	52                   	push   %edx
80103a78:	e8 fa f5 ff ff       	call   80103077 <lapicstartap>
80103a7d:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a80:	90                   	nop
80103a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a84:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a8a:	85 c0                	test   %eax,%eax
80103a8c:	74 f3                	je     80103a81 <startothers+0xb2>
80103a8e:	eb 01                	jmp    80103a91 <startothers+0xc2>
      continue;
80103a90:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103a91:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a98:	a1 44 19 11 80       	mov    0x80111944,%eax
80103a9d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103aa3:	05 60 13 11 80       	add    $0x80111360,%eax
80103aa8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103aab:	0f 82 59 ff ff ff    	jb     80103a0a <startothers+0x3b>
      ;
  }
}
80103ab1:	90                   	nop
80103ab2:	90                   	nop
80103ab3:	c9                   	leave  
80103ab4:	c3                   	ret    

80103ab5 <p2v>:
80103ab5:	55                   	push   %ebp
80103ab6:	89 e5                	mov    %esp,%ebp
80103ab8:	8b 45 08             	mov    0x8(%ebp),%eax
80103abb:	05 00 00 00 80       	add    $0x80000000,%eax
80103ac0:	5d                   	pop    %ebp
80103ac1:	c3                   	ret    

80103ac2 <inb>:
{
80103ac2:	55                   	push   %ebp
80103ac3:	89 e5                	mov    %esp,%ebp
80103ac5:	83 ec 14             	sub    $0x14,%esp
80103ac8:	8b 45 08             	mov    0x8(%ebp),%eax
80103acb:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103acf:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103ad3:	89 c2                	mov    %eax,%edx
80103ad5:	ec                   	in     (%dx),%al
80103ad6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103ad9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103add:	c9                   	leave  
80103ade:	c3                   	ret    

80103adf <outb>:
{
80103adf:	55                   	push   %ebp
80103ae0:	89 e5                	mov    %esp,%ebp
80103ae2:	83 ec 08             	sub    $0x8,%esp
80103ae5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ae8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103aeb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103aef:	89 d0                	mov    %edx,%eax
80103af1:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103af4:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103af8:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103afc:	ee                   	out    %al,(%dx)
}
80103afd:	90                   	nop
80103afe:	c9                   	leave  
80103aff:	c3                   	ret    

80103b00 <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103b00:	55                   	push   %ebp
80103b01:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103b03:	a1 4c 19 11 80       	mov    0x8011194c,%eax
80103b08:	2d 60 13 11 80       	sub    $0x80111360,%eax
80103b0d:	c1 f8 02             	sar    $0x2,%eax
80103b10:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103b16:	5d                   	pop    %ebp
80103b17:	c3                   	ret    

80103b18 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103b18:	55                   	push   %ebp
80103b19:	89 e5                	mov    %esp,%ebp
80103b1b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103b1e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b25:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b2c:	eb 15                	jmp    80103b43 <sum+0x2b>
    sum += addr[i];
80103b2e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b31:	8b 45 08             	mov    0x8(%ebp),%eax
80103b34:	01 d0                	add    %edx,%eax
80103b36:	0f b6 00             	movzbl (%eax),%eax
80103b39:	0f b6 c0             	movzbl %al,%eax
80103b3c:	01 45 f8             	add    %eax,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b3f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b46:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b49:	7c e3                	jl     80103b2e <sum+0x16>
  return sum;
80103b4b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b4e:	c9                   	leave  
80103b4f:	c3                   	ret    

80103b50 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b50:	55                   	push   %ebp
80103b51:	89 e5                	mov    %esp,%ebp
80103b53:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b56:	ff 75 08             	push   0x8(%ebp)
80103b59:	e8 57 ff ff ff       	call   80103ab5 <p2v>
80103b5e:	83 c4 04             	add    $0x4,%esp
80103b61:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b64:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b6a:	01 d0                	add    %edx,%eax
80103b6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b75:	eb 36                	jmp    80103bad <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b77:	83 ec 04             	sub    $0x4,%esp
80103b7a:	6a 04                	push   $0x4
80103b7c:	68 5c 8a 10 80       	push   $0x80108a5c
80103b81:	ff 75 f4             	push   -0xc(%ebp)
80103b84:	e8 ca 17 00 00       	call   80105353 <memcmp>
80103b89:	83 c4 10             	add    $0x10,%esp
80103b8c:	85 c0                	test   %eax,%eax
80103b8e:	75 19                	jne    80103ba9 <mpsearch1+0x59>
80103b90:	83 ec 08             	sub    $0x8,%esp
80103b93:	6a 10                	push   $0x10
80103b95:	ff 75 f4             	push   -0xc(%ebp)
80103b98:	e8 7b ff ff ff       	call   80103b18 <sum>
80103b9d:	83 c4 10             	add    $0x10,%esp
80103ba0:	84 c0                	test   %al,%al
80103ba2:	75 05                	jne    80103ba9 <mpsearch1+0x59>
      return (struct mp*)p;
80103ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba7:	eb 11                	jmp    80103bba <mpsearch1+0x6a>
  for(p = addr; p < e; p += sizeof(struct mp))
80103ba9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103bad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bb3:	72 c2                	jb     80103b77 <mpsearch1+0x27>
  return 0;
80103bb5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bba:	c9                   	leave  
80103bbb:	c3                   	ret    

80103bbc <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bbc:	55                   	push   %ebp
80103bbd:	89 e5                	mov    %esp,%ebp
80103bbf:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bc2:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bcc:	83 c0 0f             	add    $0xf,%eax
80103bcf:	0f b6 00             	movzbl (%eax),%eax
80103bd2:	0f b6 c0             	movzbl %al,%eax
80103bd5:	c1 e0 08             	shl    $0x8,%eax
80103bd8:	89 c2                	mov    %eax,%edx
80103bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdd:	83 c0 0e             	add    $0xe,%eax
80103be0:	0f b6 00             	movzbl (%eax),%eax
80103be3:	0f b6 c0             	movzbl %al,%eax
80103be6:	09 d0                	or     %edx,%eax
80103be8:	c1 e0 04             	shl    $0x4,%eax
80103beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bee:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bf2:	74 21                	je     80103c15 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bf4:	83 ec 08             	sub    $0x8,%esp
80103bf7:	68 00 04 00 00       	push   $0x400
80103bfc:	ff 75 f0             	push   -0x10(%ebp)
80103bff:	e8 4c ff ff ff       	call   80103b50 <mpsearch1>
80103c04:	83 c4 10             	add    $0x10,%esp
80103c07:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c0a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c0e:	74 51                	je     80103c61 <mpsearch+0xa5>
      return mp;
80103c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c13:	eb 61                	jmp    80103c76 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c18:	83 c0 14             	add    $0x14,%eax
80103c1b:	0f b6 00             	movzbl (%eax),%eax
80103c1e:	0f b6 c0             	movzbl %al,%eax
80103c21:	c1 e0 08             	shl    $0x8,%eax
80103c24:	89 c2                	mov    %eax,%edx
80103c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c29:	83 c0 13             	add    $0x13,%eax
80103c2c:	0f b6 00             	movzbl (%eax),%eax
80103c2f:	0f b6 c0             	movzbl %al,%eax
80103c32:	09 d0                	or     %edx,%eax
80103c34:	c1 e0 0a             	shl    $0xa,%eax
80103c37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c3d:	2d 00 04 00 00       	sub    $0x400,%eax
80103c42:	83 ec 08             	sub    $0x8,%esp
80103c45:	68 00 04 00 00       	push   $0x400
80103c4a:	50                   	push   %eax
80103c4b:	e8 00 ff ff ff       	call   80103b50 <mpsearch1>
80103c50:	83 c4 10             	add    $0x10,%esp
80103c53:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c56:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c5a:	74 05                	je     80103c61 <mpsearch+0xa5>
      return mp;
80103c5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c5f:	eb 15                	jmp    80103c76 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c61:	83 ec 08             	sub    $0x8,%esp
80103c64:	68 00 00 01 00       	push   $0x10000
80103c69:	68 00 00 0f 00       	push   $0xf0000
80103c6e:	e8 dd fe ff ff       	call   80103b50 <mpsearch1>
80103c73:	83 c4 10             	add    $0x10,%esp
}
80103c76:	c9                   	leave  
80103c77:	c3                   	ret    

80103c78 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c78:	55                   	push   %ebp
80103c79:	89 e5                	mov    %esp,%ebp
80103c7b:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c7e:	e8 39 ff ff ff       	call   80103bbc <mpsearch>
80103c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c8a:	74 0a                	je     80103c96 <mpconfig+0x1e>
80103c8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c8f:	8b 40 04             	mov    0x4(%eax),%eax
80103c92:	85 c0                	test   %eax,%eax
80103c94:	75 0a                	jne    80103ca0 <mpconfig+0x28>
    return 0;
80103c96:	b8 00 00 00 00       	mov    $0x0,%eax
80103c9b:	e9 81 00 00 00       	jmp    80103d21 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca3:	8b 40 04             	mov    0x4(%eax),%eax
80103ca6:	83 ec 0c             	sub    $0xc,%esp
80103ca9:	50                   	push   %eax
80103caa:	e8 06 fe ff ff       	call   80103ab5 <p2v>
80103caf:	83 c4 10             	add    $0x10,%esp
80103cb2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cb5:	83 ec 04             	sub    $0x4,%esp
80103cb8:	6a 04                	push   $0x4
80103cba:	68 61 8a 10 80       	push   $0x80108a61
80103cbf:	ff 75 f0             	push   -0x10(%ebp)
80103cc2:	e8 8c 16 00 00       	call   80105353 <memcmp>
80103cc7:	83 c4 10             	add    $0x10,%esp
80103cca:	85 c0                	test   %eax,%eax
80103ccc:	74 07                	je     80103cd5 <mpconfig+0x5d>
    return 0;
80103cce:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd3:	eb 4c                	jmp    80103d21 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103cd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd8:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cdc:	3c 01                	cmp    $0x1,%al
80103cde:	74 12                	je     80103cf2 <mpconfig+0x7a>
80103ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ce3:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ce7:	3c 04                	cmp    $0x4,%al
80103ce9:	74 07                	je     80103cf2 <mpconfig+0x7a>
    return 0;
80103ceb:	b8 00 00 00 00       	mov    $0x0,%eax
80103cf0:	eb 2f                	jmp    80103d21 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cf2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf5:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cf9:	0f b7 c0             	movzwl %ax,%eax
80103cfc:	83 ec 08             	sub    $0x8,%esp
80103cff:	50                   	push   %eax
80103d00:	ff 75 f0             	push   -0x10(%ebp)
80103d03:	e8 10 fe ff ff       	call   80103b18 <sum>
80103d08:	83 c4 10             	add    $0x10,%esp
80103d0b:	84 c0                	test   %al,%al
80103d0d:	74 07                	je     80103d16 <mpconfig+0x9e>
    return 0;
80103d0f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d14:	eb 0b                	jmp    80103d21 <mpconfig+0xa9>
  *pmp = mp;
80103d16:	8b 45 08             	mov    0x8(%ebp),%eax
80103d19:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d1c:	89 10                	mov    %edx,(%eax)
  return conf;
80103d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d21:	c9                   	leave  
80103d22:	c3                   	ret    

80103d23 <mpinit>:

void
mpinit(void)
{
80103d23:	55                   	push   %ebp
80103d24:	89 e5                	mov    %esp,%ebp
80103d26:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103d29:	c7 05 4c 19 11 80 60 	movl   $0x80111360,0x8011194c
80103d30:	13 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103d33:	83 ec 0c             	sub    $0xc,%esp
80103d36:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103d39:	50                   	push   %eax
80103d3a:	e8 39 ff ff ff       	call   80103c78 <mpconfig>
80103d3f:	83 c4 10             	add    $0x10,%esp
80103d42:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d45:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d49:	0f 84 ba 01 00 00    	je     80103f09 <mpinit+0x1e6>
    return;
  ismp = 1;
80103d4f:	c7 05 40 19 11 80 01 	movl   $0x1,0x80111940
80103d56:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d5c:	8b 40 24             	mov    0x24(%eax),%eax
80103d5f:	a3 60 12 11 80       	mov    %eax,0x80111260
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d67:	83 c0 2c             	add    $0x2c,%eax
80103d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d70:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d74:	0f b7 d0             	movzwl %ax,%edx
80103d77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d7a:	01 d0                	add    %edx,%eax
80103d7c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d7f:	e9 16 01 00 00       	jmp    80103e9a <mpinit+0x177>
    switch(*p){
80103d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d87:	0f b6 00             	movzbl (%eax),%eax
80103d8a:	0f b6 c0             	movzbl %al,%eax
80103d8d:	83 f8 04             	cmp    $0x4,%eax
80103d90:	0f 8f e0 00 00 00    	jg     80103e76 <mpinit+0x153>
80103d96:	83 f8 03             	cmp    $0x3,%eax
80103d99:	0f 8d d1 00 00 00    	jge    80103e70 <mpinit+0x14d>
80103d9f:	83 f8 02             	cmp    $0x2,%eax
80103da2:	0f 84 b0 00 00 00    	je     80103e58 <mpinit+0x135>
80103da8:	83 f8 02             	cmp    $0x2,%eax
80103dab:	0f 8f c5 00 00 00    	jg     80103e76 <mpinit+0x153>
80103db1:	85 c0                	test   %eax,%eax
80103db3:	74 0e                	je     80103dc3 <mpinit+0xa0>
80103db5:	83 f8 01             	cmp    $0x1,%eax
80103db8:	0f 84 b2 00 00 00    	je     80103e70 <mpinit+0x14d>
80103dbe:	e9 b3 00 00 00       	jmp    80103e76 <mpinit+0x153>
    case MPPROC:
      proc = (struct mpproc*)p;
80103dc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu != proc->apicid){
80103dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dcc:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103dd0:	0f b6 d0             	movzbl %al,%edx
80103dd3:	a1 44 19 11 80       	mov    0x80111944,%eax
80103dd8:	39 c2                	cmp    %eax,%edx
80103dda:	74 2b                	je     80103e07 <mpinit+0xe4>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103ddf:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103de3:	0f b6 d0             	movzbl %al,%edx
80103de6:	a1 44 19 11 80       	mov    0x80111944,%eax
80103deb:	83 ec 04             	sub    $0x4,%esp
80103dee:	52                   	push   %edx
80103def:	50                   	push   %eax
80103df0:	68 66 8a 10 80       	push   $0x80108a66
80103df5:	e8 cc c5 ff ff       	call   801003c6 <cprintf>
80103dfa:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103dfd:	c7 05 40 19 11 80 00 	movl   $0x0,0x80111940
80103e04:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103e07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e0a:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103e0e:	0f b6 c0             	movzbl %al,%eax
80103e11:	83 e0 02             	and    $0x2,%eax
80103e14:	85 c0                	test   %eax,%eax
80103e16:	74 15                	je     80103e2d <mpinit+0x10a>
        bcpu = &cpus[ncpu];
80103e18:	a1 44 19 11 80       	mov    0x80111944,%eax
80103e1d:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e23:	05 60 13 11 80       	add    $0x80111360,%eax
80103e28:	a3 4c 19 11 80       	mov    %eax,0x8011194c
      cpus[ncpu].id = ncpu;
80103e2d:	8b 15 44 19 11 80    	mov    0x80111944,%edx
80103e33:	a1 44 19 11 80       	mov    0x80111944,%eax
80103e38:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103e3e:	05 60 13 11 80       	add    $0x80111360,%eax
80103e43:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103e45:	a1 44 19 11 80       	mov    0x80111944,%eax
80103e4a:	83 c0 01             	add    $0x1,%eax
80103e4d:	a3 44 19 11 80       	mov    %eax,0x80111944
      p += sizeof(struct mpproc);
80103e52:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e56:	eb 42                	jmp    80103e9a <mpinit+0x177>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e5b:	89 45 e8             	mov    %eax,-0x18(%ebp)
      ioapicid = ioapic->apicno;
80103e5e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103e61:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e65:	a2 48 19 11 80       	mov    %al,0x80111948
      p += sizeof(struct mpioapic);
80103e6a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e6e:	eb 2a                	jmp    80103e9a <mpinit+0x177>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e70:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e74:	eb 24                	jmp    80103e9a <mpinit+0x177>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e79:	0f b6 00             	movzbl (%eax),%eax
80103e7c:	0f b6 c0             	movzbl %al,%eax
80103e7f:	83 ec 08             	sub    $0x8,%esp
80103e82:	50                   	push   %eax
80103e83:	68 84 8a 10 80       	push   $0x80108a84
80103e88:	e8 39 c5 ff ff       	call   801003c6 <cprintf>
80103e8d:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e90:	c7 05 40 19 11 80 00 	movl   $0x0,0x80111940
80103e97:	00 00 00 
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e9d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ea0:	0f 82 de fe ff ff    	jb     80103d84 <mpinit+0x61>
    }
  }
  if(!ismp){
80103ea6:	a1 40 19 11 80       	mov    0x80111940,%eax
80103eab:	85 c0                	test   %eax,%eax
80103ead:	75 1d                	jne    80103ecc <mpinit+0x1a9>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103eaf:	c7 05 44 19 11 80 01 	movl   $0x1,0x80111944
80103eb6:	00 00 00 
    lapic = 0;
80103eb9:	c7 05 60 12 11 80 00 	movl   $0x0,0x80111260
80103ec0:	00 00 00 
    ioapicid = 0;
80103ec3:	c6 05 48 19 11 80 00 	movb   $0x0,0x80111948
    return;
80103eca:	eb 3e                	jmp    80103f0a <mpinit+0x1e7>
  }

  if(mp->imcrp){
80103ecc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ecf:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103ed3:	84 c0                	test   %al,%al
80103ed5:	74 33                	je     80103f0a <mpinit+0x1e7>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ed7:	83 ec 08             	sub    $0x8,%esp
80103eda:	6a 70                	push   $0x70
80103edc:	6a 22                	push   $0x22
80103ede:	e8 fc fb ff ff       	call   80103adf <outb>
80103ee3:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ee6:	83 ec 0c             	sub    $0xc,%esp
80103ee9:	6a 23                	push   $0x23
80103eeb:	e8 d2 fb ff ff       	call   80103ac2 <inb>
80103ef0:	83 c4 10             	add    $0x10,%esp
80103ef3:	83 c8 01             	or     $0x1,%eax
80103ef6:	0f b6 c0             	movzbl %al,%eax
80103ef9:	83 ec 08             	sub    $0x8,%esp
80103efc:	50                   	push   %eax
80103efd:	6a 23                	push   $0x23
80103eff:	e8 db fb ff ff       	call   80103adf <outb>
80103f04:	83 c4 10             	add    $0x10,%esp
80103f07:	eb 01                	jmp    80103f0a <mpinit+0x1e7>
    return;
80103f09:	90                   	nop
  }
}
80103f0a:	c9                   	leave  
80103f0b:	c3                   	ret    

80103f0c <outb>:
{
80103f0c:	55                   	push   %ebp
80103f0d:	89 e5                	mov    %esp,%ebp
80103f0f:	83 ec 08             	sub    $0x8,%esp
80103f12:	8b 45 08             	mov    0x8(%ebp),%eax
80103f15:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f18:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f1c:	89 d0                	mov    %edx,%eax
80103f1e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f21:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103f25:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103f29:	ee                   	out    %al,(%dx)
}
80103f2a:	90                   	nop
80103f2b:	c9                   	leave  
80103f2c:	c3                   	ret    

80103f2d <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103f2d:	55                   	push   %ebp
80103f2e:	89 e5                	mov    %esp,%ebp
80103f30:	83 ec 04             	sub    $0x4,%esp
80103f33:	8b 45 08             	mov    0x8(%ebp),%eax
80103f36:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103f3a:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f3e:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103f44:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f48:	0f b6 c0             	movzbl %al,%eax
80103f4b:	50                   	push   %eax
80103f4c:	6a 21                	push   $0x21
80103f4e:	e8 b9 ff ff ff       	call   80103f0c <outb>
80103f53:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103f56:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103f5a:	66 c1 e8 08          	shr    $0x8,%ax
80103f5e:	0f b6 c0             	movzbl %al,%eax
80103f61:	50                   	push   %eax
80103f62:	68 a1 00 00 00       	push   $0xa1
80103f67:	e8 a0 ff ff ff       	call   80103f0c <outb>
80103f6c:	83 c4 08             	add    $0x8,%esp
}
80103f6f:	90                   	nop
80103f70:	c9                   	leave  
80103f71:	c3                   	ret    

80103f72 <picenable>:

void
picenable(int irq)
{
80103f72:	55                   	push   %ebp
80103f73:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f75:	8b 45 08             	mov    0x8(%ebp),%eax
80103f78:	ba 01 00 00 00       	mov    $0x1,%edx
80103f7d:	89 c1                	mov    %eax,%ecx
80103f7f:	d3 e2                	shl    %cl,%edx
80103f81:	89 d0                	mov    %edx,%eax
80103f83:	f7 d0                	not    %eax
80103f85:	89 c2                	mov    %eax,%edx
80103f87:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f8e:	21 d0                	and    %edx,%eax
80103f90:	0f b7 c0             	movzwl %ax,%eax
80103f93:	50                   	push   %eax
80103f94:	e8 94 ff ff ff       	call   80103f2d <picsetmask>
80103f99:	83 c4 04             	add    $0x4,%esp
}
80103f9c:	90                   	nop
80103f9d:	c9                   	leave  
80103f9e:	c3                   	ret    

80103f9f <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f9f:	55                   	push   %ebp
80103fa0:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103fa2:	68 ff 00 00 00       	push   $0xff
80103fa7:	6a 21                	push   $0x21
80103fa9:	e8 5e ff ff ff       	call   80103f0c <outb>
80103fae:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103fb1:	68 ff 00 00 00       	push   $0xff
80103fb6:	68 a1 00 00 00       	push   $0xa1
80103fbb:	e8 4c ff ff ff       	call   80103f0c <outb>
80103fc0:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103fc3:	6a 11                	push   $0x11
80103fc5:	6a 20                	push   $0x20
80103fc7:	e8 40 ff ff ff       	call   80103f0c <outb>
80103fcc:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103fcf:	6a 20                	push   $0x20
80103fd1:	6a 21                	push   $0x21
80103fd3:	e8 34 ff ff ff       	call   80103f0c <outb>
80103fd8:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103fdb:	6a 04                	push   $0x4
80103fdd:	6a 21                	push   $0x21
80103fdf:	e8 28 ff ff ff       	call   80103f0c <outb>
80103fe4:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103fe7:	6a 03                	push   $0x3
80103fe9:	6a 21                	push   $0x21
80103feb:	e8 1c ff ff ff       	call   80103f0c <outb>
80103ff0:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103ff3:	6a 11                	push   $0x11
80103ff5:	68 a0 00 00 00       	push   $0xa0
80103ffa:	e8 0d ff ff ff       	call   80103f0c <outb>
80103fff:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80104002:	6a 28                	push   $0x28
80104004:	68 a1 00 00 00       	push   $0xa1
80104009:	e8 fe fe ff ff       	call   80103f0c <outb>
8010400e:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80104011:	6a 02                	push   $0x2
80104013:	68 a1 00 00 00       	push   $0xa1
80104018:	e8 ef fe ff ff       	call   80103f0c <outb>
8010401d:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80104020:	6a 03                	push   $0x3
80104022:	68 a1 00 00 00       	push   $0xa1
80104027:	e8 e0 fe ff ff       	call   80103f0c <outb>
8010402c:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
8010402f:	6a 68                	push   $0x68
80104031:	6a 20                	push   $0x20
80104033:	e8 d4 fe ff ff       	call   80103f0c <outb>
80104038:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
8010403b:	6a 0a                	push   $0xa
8010403d:	6a 20                	push   $0x20
8010403f:	e8 c8 fe ff ff       	call   80103f0c <outb>
80104044:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80104047:	6a 68                	push   $0x68
80104049:	68 a0 00 00 00       	push   $0xa0
8010404e:	e8 b9 fe ff ff       	call   80103f0c <outb>
80104053:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80104056:	6a 0a                	push   $0xa
80104058:	68 a0 00 00 00       	push   $0xa0
8010405d:	e8 aa fe ff ff       	call   80103f0c <outb>
80104062:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104065:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010406c:	66 83 f8 ff          	cmp    $0xffff,%ax
80104070:	74 13                	je     80104085 <picinit+0xe6>
    picsetmask(irqmask);
80104072:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104079:	0f b7 c0             	movzwl %ax,%eax
8010407c:	50                   	push   %eax
8010407d:	e8 ab fe ff ff       	call   80103f2d <picsetmask>
80104082:	83 c4 04             	add    $0x4,%esp
}
80104085:	90                   	nop
80104086:	c9                   	leave  
80104087:	c3                   	ret    

80104088 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104088:	55                   	push   %ebp
80104089:	89 e5                	mov    %esp,%ebp
8010408b:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010408e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104095:	8b 45 0c             	mov    0xc(%ebp),%eax
80104098:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010409e:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a1:	8b 10                	mov    (%eax),%edx
801040a3:	8b 45 08             	mov    0x8(%ebp),%eax
801040a6:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
801040a8:	e8 13 cf ff ff       	call   80100fc0 <filealloc>
801040ad:	8b 55 08             	mov    0x8(%ebp),%edx
801040b0:	89 02                	mov    %eax,(%edx)
801040b2:	8b 45 08             	mov    0x8(%ebp),%eax
801040b5:	8b 00                	mov    (%eax),%eax
801040b7:	85 c0                	test   %eax,%eax
801040b9:	0f 84 c8 00 00 00    	je     80104187 <pipealloc+0xff>
801040bf:	e8 fc ce ff ff       	call   80100fc0 <filealloc>
801040c4:	8b 55 0c             	mov    0xc(%ebp),%edx
801040c7:	89 02                	mov    %eax,(%edx)
801040c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cc:	8b 00                	mov    (%eax),%eax
801040ce:	85 c0                	test   %eax,%eax
801040d0:	0f 84 b1 00 00 00    	je     80104187 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801040d6:	e8 ab eb ff ff       	call   80102c86 <kalloc>
801040db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801040de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040e2:	0f 84 a2 00 00 00    	je     8010418a <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801040e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040eb:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801040f2:	00 00 00 
  p->writeopen = 1;
801040f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f8:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040ff:	00 00 00 
  p->nwrite = 0;
80104102:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104105:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010410c:	00 00 00 
  p->nread = 0;
8010410f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104112:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104119:	00 00 00 
  initlock(&p->lock, "pipe");
8010411c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411f:	83 ec 08             	sub    $0x8,%esp
80104122:	68 a4 8a 10 80       	push   $0x80108aa4
80104127:	50                   	push   %eax
80104128:	e8 3a 0f 00 00       	call   80105067 <initlock>
8010412d:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80104130:	8b 45 08             	mov    0x8(%ebp),%eax
80104133:	8b 00                	mov    (%eax),%eax
80104135:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	8b 00                	mov    (%eax),%eax
80104140:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	8b 00                	mov    (%eax),%eax
80104149:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	8b 00                	mov    (%eax),%eax
80104152:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104155:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415b:	8b 00                	mov    (%eax),%eax
8010415d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104163:	8b 45 0c             	mov    0xc(%ebp),%eax
80104166:	8b 00                	mov    (%eax),%eax
80104168:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010416c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416f:	8b 00                	mov    (%eax),%eax
80104171:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104175:	8b 45 0c             	mov    0xc(%ebp),%eax
80104178:	8b 00                	mov    (%eax),%eax
8010417a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010417d:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104180:	b8 00 00 00 00       	mov    $0x0,%eax
80104185:	eb 51                	jmp    801041d8 <pipealloc+0x150>
    goto bad;
80104187:	90                   	nop
80104188:	eb 01                	jmp    8010418b <pipealloc+0x103>
    goto bad;
8010418a:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
8010418b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010418f:	74 0e                	je     8010419f <pipealloc+0x117>
    kfree((char*)p);
80104191:	83 ec 0c             	sub    $0xc,%esp
80104194:	ff 75 f4             	push   -0xc(%ebp)
80104197:	e8 40 ea ff ff       	call   80102bdc <kfree>
8010419c:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010419f:	8b 45 08             	mov    0x8(%ebp),%eax
801041a2:	8b 00                	mov    (%eax),%eax
801041a4:	85 c0                	test   %eax,%eax
801041a6:	74 11                	je     801041b9 <pipealloc+0x131>
    fileclose(*f0);
801041a8:	8b 45 08             	mov    0x8(%ebp),%eax
801041ab:	8b 00                	mov    (%eax),%eax
801041ad:	83 ec 0c             	sub    $0xc,%esp
801041b0:	50                   	push   %eax
801041b1:	e8 c8 ce ff ff       	call   8010107e <fileclose>
801041b6:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801041b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801041bc:	8b 00                	mov    (%eax),%eax
801041be:	85 c0                	test   %eax,%eax
801041c0:	74 11                	je     801041d3 <pipealloc+0x14b>
    fileclose(*f1);
801041c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801041c5:	8b 00                	mov    (%eax),%eax
801041c7:	83 ec 0c             	sub    $0xc,%esp
801041ca:	50                   	push   %eax
801041cb:	e8 ae ce ff ff       	call   8010107e <fileclose>
801041d0:	83 c4 10             	add    $0x10,%esp
  return -1;
801041d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801041d8:	c9                   	leave  
801041d9:	c3                   	ret    

801041da <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801041da:	55                   	push   %ebp
801041db:	89 e5                	mov    %esp,%ebp
801041dd:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801041e0:	8b 45 08             	mov    0x8(%ebp),%eax
801041e3:	83 ec 0c             	sub    $0xc,%esp
801041e6:	50                   	push   %eax
801041e7:	e8 9d 0e 00 00       	call   80105089 <acquire>
801041ec:	83 c4 10             	add    $0x10,%esp
  if(writable){
801041ef:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801041f3:	74 23                	je     80104218 <pipeclose+0x3e>
    p->writeopen = 0;
801041f5:	8b 45 08             	mov    0x8(%ebp),%eax
801041f8:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801041ff:	00 00 00 
    wakeup(&p->nread);
80104202:	8b 45 08             	mov    0x8(%ebp),%eax
80104205:	05 34 02 00 00       	add    $0x234,%eax
8010420a:	83 ec 0c             	sub    $0xc,%esp
8010420d:	50                   	push   %eax
8010420e:	e8 67 0c 00 00       	call   80104e7a <wakeup>
80104213:	83 c4 10             	add    $0x10,%esp
80104216:	eb 21                	jmp    80104239 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104218:	8b 45 08             	mov    0x8(%ebp),%eax
8010421b:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80104222:	00 00 00 
    wakeup(&p->nwrite);
80104225:	8b 45 08             	mov    0x8(%ebp),%eax
80104228:	05 38 02 00 00       	add    $0x238,%eax
8010422d:	83 ec 0c             	sub    $0xc,%esp
80104230:	50                   	push   %eax
80104231:	e8 44 0c 00 00       	call   80104e7a <wakeup>
80104236:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104242:	85 c0                	test   %eax,%eax
80104244:	75 2c                	jne    80104272 <pipeclose+0x98>
80104246:	8b 45 08             	mov    0x8(%ebp),%eax
80104249:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010424f:	85 c0                	test   %eax,%eax
80104251:	75 1f                	jne    80104272 <pipeclose+0x98>
    release(&p->lock);
80104253:	8b 45 08             	mov    0x8(%ebp),%eax
80104256:	83 ec 0c             	sub    $0xc,%esp
80104259:	50                   	push   %eax
8010425a:	e8 91 0e 00 00       	call   801050f0 <release>
8010425f:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104262:	83 ec 0c             	sub    $0xc,%esp
80104265:	ff 75 08             	push   0x8(%ebp)
80104268:	e8 6f e9 ff ff       	call   80102bdc <kfree>
8010426d:	83 c4 10             	add    $0x10,%esp
80104270:	eb 10                	jmp    80104282 <pipeclose+0xa8>
  } else
    release(&p->lock);
80104272:	8b 45 08             	mov    0x8(%ebp),%eax
80104275:	83 ec 0c             	sub    $0xc,%esp
80104278:	50                   	push   %eax
80104279:	e8 72 0e 00 00       	call   801050f0 <release>
8010427e:	83 c4 10             	add    $0x10,%esp
}
80104281:	90                   	nop
80104282:	90                   	nop
80104283:	c9                   	leave  
80104284:	c3                   	ret    

80104285 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104285:	55                   	push   %ebp
80104286:	89 e5                	mov    %esp,%ebp
80104288:	53                   	push   %ebx
80104289:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
8010428c:	8b 45 08             	mov    0x8(%ebp),%eax
8010428f:	83 ec 0c             	sub    $0xc,%esp
80104292:	50                   	push   %eax
80104293:	e8 f1 0d 00 00       	call   80105089 <acquire>
80104298:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
8010429b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801042a2:	e9 ae 00 00 00       	jmp    80104355 <pipewrite+0xd0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801042a7:	8b 45 08             	mov    0x8(%ebp),%eax
801042aa:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801042b0:	85 c0                	test   %eax,%eax
801042b2:	74 0d                	je     801042c1 <pipewrite+0x3c>
801042b4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042ba:	8b 40 24             	mov    0x24(%eax),%eax
801042bd:	85 c0                	test   %eax,%eax
801042bf:	74 19                	je     801042da <pipewrite+0x55>
        release(&p->lock);
801042c1:	8b 45 08             	mov    0x8(%ebp),%eax
801042c4:	83 ec 0c             	sub    $0xc,%esp
801042c7:	50                   	push   %eax
801042c8:	e8 23 0e 00 00       	call   801050f0 <release>
801042cd:	83 c4 10             	add    $0x10,%esp
        return -1;
801042d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042d5:	e9 a9 00 00 00       	jmp    80104383 <pipewrite+0xfe>
      }
      wakeup(&p->nread);
801042da:	8b 45 08             	mov    0x8(%ebp),%eax
801042dd:	05 34 02 00 00       	add    $0x234,%eax
801042e2:	83 ec 0c             	sub    $0xc,%esp
801042e5:	50                   	push   %eax
801042e6:	e8 8f 0b 00 00       	call   80104e7a <wakeup>
801042eb:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801042ee:	8b 45 08             	mov    0x8(%ebp),%eax
801042f1:	8b 55 08             	mov    0x8(%ebp),%edx
801042f4:	81 c2 38 02 00 00    	add    $0x238,%edx
801042fa:	83 ec 08             	sub    $0x8,%esp
801042fd:	50                   	push   %eax
801042fe:	52                   	push   %edx
801042ff:	e8 8a 0a 00 00       	call   80104d8e <sleep>
80104304:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104307:	8b 45 08             	mov    0x8(%ebp),%eax
8010430a:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104310:	8b 45 08             	mov    0x8(%ebp),%eax
80104313:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104319:	05 00 02 00 00       	add    $0x200,%eax
8010431e:	39 c2                	cmp    %eax,%edx
80104320:	74 85                	je     801042a7 <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104322:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104325:	8b 45 0c             	mov    0xc(%ebp),%eax
80104328:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010432b:	8b 45 08             	mov    0x8(%ebp),%eax
8010432e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104334:	8d 48 01             	lea    0x1(%eax),%ecx
80104337:	8b 55 08             	mov    0x8(%ebp),%edx
8010433a:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104340:	25 ff 01 00 00       	and    $0x1ff,%eax
80104345:	89 c1                	mov    %eax,%ecx
80104347:	0f b6 13             	movzbl (%ebx),%edx
8010434a:	8b 45 08             	mov    0x8(%ebp),%eax
8010434d:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80104351:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104358:	3b 45 10             	cmp    0x10(%ebp),%eax
8010435b:	7c aa                	jl     80104307 <pipewrite+0x82>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010435d:	8b 45 08             	mov    0x8(%ebp),%eax
80104360:	05 34 02 00 00       	add    $0x234,%eax
80104365:	83 ec 0c             	sub    $0xc,%esp
80104368:	50                   	push   %eax
80104369:	e8 0c 0b 00 00       	call   80104e7a <wakeup>
8010436e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104371:	8b 45 08             	mov    0x8(%ebp),%eax
80104374:	83 ec 0c             	sub    $0xc,%esp
80104377:	50                   	push   %eax
80104378:	e8 73 0d 00 00       	call   801050f0 <release>
8010437d:	83 c4 10             	add    $0x10,%esp
  return n;
80104380:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104386:	c9                   	leave  
80104387:	c3                   	ret    

80104388 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104388:	55                   	push   %ebp
80104389:	89 e5                	mov    %esp,%ebp
8010438b:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
8010438e:	8b 45 08             	mov    0x8(%ebp),%eax
80104391:	83 ec 0c             	sub    $0xc,%esp
80104394:	50                   	push   %eax
80104395:	e8 ef 0c 00 00       	call   80105089 <acquire>
8010439a:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010439d:	eb 3f                	jmp    801043de <piperead+0x56>
    if(proc->killed){
8010439f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801043a5:	8b 40 24             	mov    0x24(%eax),%eax
801043a8:	85 c0                	test   %eax,%eax
801043aa:	74 19                	je     801043c5 <piperead+0x3d>
      release(&p->lock);
801043ac:	8b 45 08             	mov    0x8(%ebp),%eax
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	50                   	push   %eax
801043b3:	e8 38 0d 00 00       	call   801050f0 <release>
801043b8:	83 c4 10             	add    $0x10,%esp
      return -1;
801043bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043c0:	e9 be 00 00 00       	jmp    80104483 <piperead+0xfb>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801043c5:	8b 45 08             	mov    0x8(%ebp),%eax
801043c8:	8b 55 08             	mov    0x8(%ebp),%edx
801043cb:	81 c2 34 02 00 00    	add    $0x234,%edx
801043d1:	83 ec 08             	sub    $0x8,%esp
801043d4:	50                   	push   %eax
801043d5:	52                   	push   %edx
801043d6:	e8 b3 09 00 00       	call   80104d8e <sleep>
801043db:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801043de:	8b 45 08             	mov    0x8(%ebp),%eax
801043e1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043e7:	8b 45 08             	mov    0x8(%ebp),%eax
801043ea:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043f0:	39 c2                	cmp    %eax,%edx
801043f2:	75 0d                	jne    80104401 <piperead+0x79>
801043f4:	8b 45 08             	mov    0x8(%ebp),%eax
801043f7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801043fd:	85 c0                	test   %eax,%eax
801043ff:	75 9e                	jne    8010439f <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104401:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104408:	eb 48                	jmp    80104452 <piperead+0xca>
    if(p->nread == p->nwrite)
8010440a:	8b 45 08             	mov    0x8(%ebp),%eax
8010440d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104413:	8b 45 08             	mov    0x8(%ebp),%eax
80104416:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010441c:	39 c2                	cmp    %eax,%edx
8010441e:	74 3c                	je     8010445c <piperead+0xd4>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104420:	8b 45 08             	mov    0x8(%ebp),%eax
80104423:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104429:	8d 48 01             	lea    0x1(%eax),%ecx
8010442c:	8b 55 08             	mov    0x8(%ebp),%edx
8010442f:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104435:	25 ff 01 00 00       	and    $0x1ff,%eax
8010443a:	89 c1                	mov    %eax,%ecx
8010443c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010443f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104442:	01 c2                	add    %eax,%edx
80104444:	8b 45 08             	mov    0x8(%ebp),%eax
80104447:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010444c:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010444e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104455:	3b 45 10             	cmp    0x10(%ebp),%eax
80104458:	7c b0                	jl     8010440a <piperead+0x82>
8010445a:	eb 01                	jmp    8010445d <piperead+0xd5>
      break;
8010445c:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010445d:	8b 45 08             	mov    0x8(%ebp),%eax
80104460:	05 38 02 00 00       	add    $0x238,%eax
80104465:	83 ec 0c             	sub    $0xc,%esp
80104468:	50                   	push   %eax
80104469:	e8 0c 0a 00 00       	call   80104e7a <wakeup>
8010446e:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104471:	8b 45 08             	mov    0x8(%ebp),%eax
80104474:	83 ec 0c             	sub    $0xc,%esp
80104477:	50                   	push   %eax
80104478:	e8 73 0c 00 00       	call   801050f0 <release>
8010447d:	83 c4 10             	add    $0x10,%esp
  return i;
80104480:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104483:	c9                   	leave  
80104484:	c3                   	ret    

80104485 <readeflags>:
{
80104485:	55                   	push   %ebp
80104486:	89 e5                	mov    %esp,%ebp
80104488:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010448b:	9c                   	pushf  
8010448c:	58                   	pop    %eax
8010448d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104490:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104493:	c9                   	leave  
80104494:	c3                   	ret    

80104495 <sti>:
{
80104495:	55                   	push   %ebp
80104496:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104498:	fb                   	sti    
}
80104499:	90                   	nop
8010449a:	5d                   	pop    %ebp
8010449b:	c3                   	ret    

8010449c <halt>:
}

// CS550: to solve the 100%-CPU-utilization-when-idling problem - "hlt" instruction puts CPU to sleep
static inline void
halt()
{
8010449c:	55                   	push   %ebp
8010449d:	89 e5                	mov    %esp,%ebp
    asm volatile("hlt" : : :"memory");
8010449f:	f4                   	hlt    
}
801044a0:	90                   	nop
801044a1:	5d                   	pop    %ebp
801044a2:	c3                   	ret    

801044a3 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801044a3:	55                   	push   %ebp
801044a4:	89 e5                	mov    %esp,%ebp
801044a6:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801044a9:	83 ec 08             	sub    $0x8,%esp
801044ac:	68 a9 8a 10 80       	push   $0x80108aa9
801044b1:	68 80 19 11 80       	push   $0x80111980
801044b6:	e8 ac 0b 00 00       	call   80105067 <initlock>
801044bb:	83 c4 10             	add    $0x10,%esp
}
801044be:	90                   	nop
801044bf:	c9                   	leave  
801044c0:	c3                   	ret    

801044c1 <allocproc>:
// Otherwise return 0.


static struct proc*
allocproc(void)
{
801044c1:	55                   	push   %ebp
801044c2:	89 e5                	mov    %esp,%ebp
801044c4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801044c7:	83 ec 0c             	sub    $0xc,%esp
801044ca:	68 80 19 11 80       	push   $0x80111980
801044cf:	e8 b5 0b 00 00       	call   80105089 <acquire>
801044d4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044d7:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
801044de:	eb 0e                	jmp    801044ee <allocproc+0x2d>
    if(p->state == UNUSED)
801044e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e3:	8b 40 0c             	mov    0xc(%eax),%eax
801044e6:	85 c0                	test   %eax,%eax
801044e8:	74 27                	je     80104511 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801044ea:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
801044ee:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
801044f5:	72 e9                	jb     801044e0 <allocproc+0x1f>
      goto found;
  release(&ptable.lock);
801044f7:	83 ec 0c             	sub    $0xc,%esp
801044fa:	68 80 19 11 80       	push   $0x80111980
801044ff:	e8 ec 0b 00 00       	call   801050f0 <release>
80104504:	83 c4 10             	add    $0x10,%esp
  return 0;
80104507:	b8 00 00 00 00       	mov    $0x0,%eax
8010450c:	e9 b2 00 00 00       	jmp    801045c3 <allocproc+0x102>
      goto found;
80104511:	90                   	nop

found:
  p->state = EMBRYO;
80104512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104515:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
8010451c:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104521:	8d 50 01             	lea    0x1(%eax),%edx
80104524:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
8010452a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010452d:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104530:	83 ec 0c             	sub    $0xc,%esp
80104533:	68 80 19 11 80       	push   $0x80111980
80104538:	e8 b3 0b 00 00       	call   801050f0 <release>
8010453d:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104540:	e8 41 e7 ff ff       	call   80102c86 <kalloc>
80104545:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104548:	89 42 08             	mov    %eax,0x8(%edx)
8010454b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454e:	8b 40 08             	mov    0x8(%eax),%eax
80104551:	85 c0                	test   %eax,%eax
80104553:	75 11                	jne    80104566 <allocproc+0xa5>
    p->state = UNUSED;
80104555:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104558:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010455f:	b8 00 00 00 00       	mov    $0x0,%eax
80104564:	eb 5d                	jmp    801045c3 <allocproc+0x102>
  }
  sp = p->kstack + KSTACKSIZE;
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	8b 40 08             	mov    0x8(%eax),%eax
8010456c:	05 00 10 00 00       	add    $0x1000,%eax
80104571:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104574:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104578:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010457e:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104581:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104585:	ba 88 67 10 80       	mov    $0x80106788,%edx
8010458a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010458d:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010458f:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104596:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104599:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010459c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010459f:	8b 40 1c             	mov    0x1c(%eax),%eax
801045a2:	83 ec 04             	sub    $0x4,%esp
801045a5:	6a 14                	push   $0x14
801045a7:	6a 00                	push   $0x0
801045a9:	50                   	push   %eax
801045aa:	e8 3d 0d 00 00       	call   801052ec <memset>
801045af:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801045b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b5:	8b 40 1c             	mov    0x1c(%eax),%eax
801045b8:	ba 48 4d 10 80       	mov    $0x80104d48,%edx
801045bd:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
801045c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801045c3:	c9                   	leave  
801045c4:	c3                   	ret    

801045c5 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801045c5:	55                   	push   %ebp
801045c6:	89 e5                	mov    %esp,%ebp
801045c8:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
801045cb:	e8 f1 fe ff ff       	call   801044c1 <allocproc>
801045d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045d6:	a3 b4 38 11 80       	mov    %eax,0x801138b4
  if((p->pgdir = setupkvm()) == 0)
801045db:	e8 72 39 00 00       	call   80107f52 <setupkvm>
801045e0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045e3:	89 42 04             	mov    %eax,0x4(%edx)
801045e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045e9:	8b 40 04             	mov    0x4(%eax),%eax
801045ec:	85 c0                	test   %eax,%eax
801045ee:	75 0d                	jne    801045fd <userinit+0x38>
    panic("userinit: out of memory?");
801045f0:	83 ec 0c             	sub    $0xc,%esp
801045f3:	68 b0 8a 10 80       	push   $0x80108ab0
801045f8:	e8 7e bf ff ff       	call   8010057b <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045fd:	ba 2c 00 00 00       	mov    $0x2c,%edx
80104602:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104605:	8b 40 04             	mov    0x4(%eax),%eax
80104608:	83 ec 04             	sub    $0x4,%esp
8010460b:	52                   	push   %edx
8010460c:	68 00 b5 10 80       	push   $0x8010b500
80104611:	50                   	push   %eax
80104612:	e8 96 3b 00 00       	call   801081ad <inituvm>
80104617:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
8010461a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461d:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104623:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104626:	8b 40 18             	mov    0x18(%eax),%eax
80104629:	83 ec 04             	sub    $0x4,%esp
8010462c:	6a 4c                	push   $0x4c
8010462e:	6a 00                	push   $0x0
80104630:	50                   	push   %eax
80104631:	e8 b6 0c 00 00       	call   801052ec <memset>
80104636:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104639:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463c:	8b 40 18             	mov    0x18(%eax),%eax
8010463f:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104645:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104648:	8b 40 18             	mov    0x18(%eax),%eax
8010464b:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104651:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104654:	8b 50 18             	mov    0x18(%eax),%edx
80104657:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465a:	8b 40 18             	mov    0x18(%eax),%eax
8010465d:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104661:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104665:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104668:	8b 50 18             	mov    0x18(%eax),%edx
8010466b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466e:	8b 40 18             	mov    0x18(%eax),%eax
80104671:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104675:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80104679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467c:	8b 40 18             	mov    0x18(%eax),%eax
8010467f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104689:	8b 40 18             	mov    0x18(%eax),%eax
8010468c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104693:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104696:	8b 40 18             	mov    0x18(%eax),%eax
80104699:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a3:	83 c0 6c             	add    $0x6c,%eax
801046a6:	83 ec 04             	sub    $0x4,%esp
801046a9:	6a 10                	push   $0x10
801046ab:	68 c9 8a 10 80       	push   $0x80108ac9
801046b0:	50                   	push   %eax
801046b1:	e8 39 0e 00 00       	call   801054ef <safestrcpy>
801046b6:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046b9:	83 ec 0c             	sub    $0xc,%esp
801046bc:	68 d2 8a 10 80       	push   $0x80108ad2
801046c1:	e8 72 de ff ff       	call   80102538 <namei>
801046c6:	83 c4 10             	add    $0x10,%esp
801046c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801046cc:	89 42 68             	mov    %eax,0x68(%edx)

  p->state = RUNNABLE;
801046cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046d9:	90                   	nop
801046da:	c9                   	leave  
801046db:	c3                   	ret    

801046dc <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046dc:	55                   	push   %ebp
801046dd:	89 e5                	mov    %esp,%ebp
801046df:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046e8:	8b 00                	mov    (%eax),%eax
801046ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046f1:	7e 41                	jle    80104734 <growproc+0x58>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046f3:	8b 55 08             	mov    0x8(%ebp),%edx
801046f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046f9:	01 c2                	add    %eax,%edx
801046fb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104701:	8b 40 04             	mov    0x4(%eax),%eax
80104704:	83 ec 04             	sub    $0x4,%esp
80104707:	52                   	push   %edx
80104708:	ff 75 f4             	push   -0xc(%ebp)
8010470b:	50                   	push   %eax
8010470c:	e8 e9 3b 00 00       	call   801082fa <allocuvm>
80104711:	83 c4 10             	add    $0x10,%esp
80104714:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104717:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010471b:	75 5e                	jne    8010477b <growproc+0x9f>
    {
      cprintf("Allocating pages failed!\n"); // CS3320: project 2
8010471d:	83 ec 0c             	sub    $0xc,%esp
80104720:	68 d4 8a 10 80       	push   $0x80108ad4
80104725:	e8 9c bc ff ff       	call   801003c6 <cprintf>
8010472a:	83 c4 10             	add    $0x10,%esp
      return -1;
8010472d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104732:	eb 69                	jmp    8010479d <growproc+0xc1>
    }
  } else if(n < 0){
80104734:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104738:	79 41                	jns    8010477b <growproc+0x9f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010473a:	8b 55 08             	mov    0x8(%ebp),%edx
8010473d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104740:	01 c2                	add    %eax,%edx
80104742:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104748:	8b 40 04             	mov    0x4(%eax),%eax
8010474b:	83 ec 04             	sub    $0x4,%esp
8010474e:	52                   	push   %edx
8010474f:	ff 75 f4             	push   -0xc(%ebp)
80104752:	50                   	push   %eax
80104753:	e8 69 3c 00 00       	call   801083c1 <deallocuvm>
80104758:	83 c4 10             	add    $0x10,%esp
8010475b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010475e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104762:	75 17                	jne    8010477b <growproc+0x9f>
    {
      cprintf("Deallocating pages failed!\n"); // CS3320: project 2
80104764:	83 ec 0c             	sub    $0xc,%esp
80104767:	68 ee 8a 10 80       	push   $0x80108aee
8010476c:	e8 55 bc ff ff       	call   801003c6 <cprintf>
80104771:	83 c4 10             	add    $0x10,%esp
      return -1;
80104774:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104779:	eb 22                	jmp    8010479d <growproc+0xc1>
    }
  }
  proc->sz = sz;
8010477b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104781:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104784:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104786:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010478c:	83 ec 0c             	sub    $0xc,%esp
8010478f:	50                   	push   %eax
80104790:	e8 a4 38 00 00       	call   80108039 <switchuvm>
80104795:	83 c4 10             	add    $0x10,%esp
  return 0;
80104798:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010479d:	c9                   	leave  
8010479e:	c3                   	ret    

8010479f <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010479f:	55                   	push   %ebp
801047a0:	89 e5                	mov    %esp,%ebp
801047a2:	57                   	push   %edi
801047a3:	56                   	push   %esi
801047a4:	53                   	push   %ebx
801047a5:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801047a8:	e8 14 fd ff ff       	call   801044c1 <allocproc>
801047ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047b0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047b4:	75 0a                	jne    801047c0 <fork+0x21>
    return -1;
801047b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047bb:	e9 64 01 00 00       	jmp    80104924 <fork+0x185>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801047c0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047c6:	8b 10                	mov    (%eax),%edx
801047c8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047ce:	8b 40 04             	mov    0x4(%eax),%eax
801047d1:	83 ec 08             	sub    $0x8,%esp
801047d4:	52                   	push   %edx
801047d5:	50                   	push   %eax
801047d6:	e8 84 3d 00 00       	call   8010855f <copyuvm>
801047db:	83 c4 10             	add    $0x10,%esp
801047de:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047e1:	89 42 04             	mov    %eax,0x4(%edx)
801047e4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e7:	8b 40 04             	mov    0x4(%eax),%eax
801047ea:	85 c0                	test   %eax,%eax
801047ec:	75 30                	jne    8010481e <fork+0x7f>
    kfree(np->kstack);
801047ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f1:	8b 40 08             	mov    0x8(%eax),%eax
801047f4:	83 ec 0c             	sub    $0xc,%esp
801047f7:	50                   	push   %eax
801047f8:	e8 df e3 ff ff       	call   80102bdc <kfree>
801047fd:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104800:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104803:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010480a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010480d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104814:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104819:	e9 06 01 00 00       	jmp    80104924 <fork+0x185>
  }
  np->sz = proc->sz;
8010481e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104824:	8b 10                	mov    (%eax),%edx
80104826:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104829:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
8010482b:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104832:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104835:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
80104838:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483e:	8b 48 18             	mov    0x18(%eax),%ecx
80104841:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104844:	8b 40 18             	mov    0x18(%eax),%eax
80104847:	89 c2                	mov    %eax,%edx
80104849:	89 cb                	mov    %ecx,%ebx
8010484b:	b8 13 00 00 00       	mov    $0x13,%eax
80104850:	89 d7                	mov    %edx,%edi
80104852:	89 de                	mov    %ebx,%esi
80104854:	89 c1                	mov    %eax,%ecx
80104856:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104858:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010485b:	8b 40 18             	mov    0x18(%eax),%eax
8010485e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104865:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010486c:	eb 41                	jmp    801048af <fork+0x110>
    if(proc->ofile[i])
8010486e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104874:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104877:	83 c2 08             	add    $0x8,%edx
8010487a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010487e:	85 c0                	test   %eax,%eax
80104880:	74 29                	je     801048ab <fork+0x10c>
      np->ofile[i] = filedup(proc->ofile[i]);
80104882:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104888:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010488b:	83 c2 08             	add    $0x8,%edx
8010488e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104892:	83 ec 0c             	sub    $0xc,%esp
80104895:	50                   	push   %eax
80104896:	e8 92 c7 ff ff       	call   8010102d <filedup>
8010489b:	83 c4 10             	add    $0x10,%esp
8010489e:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801048a4:	83 c1 08             	add    $0x8,%ecx
801048a7:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
801048ab:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801048af:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048b3:	7e b9                	jle    8010486e <fork+0xcf>
  np->cwd = idup(proc->cwd);
801048b5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048bb:	8b 40 68             	mov    0x68(%eax),%eax
801048be:	83 ec 0c             	sub    $0xc,%esp
801048c1:	50                   	push   %eax
801048c2:	e8 86 d0 ff ff       	call   8010194d <idup>
801048c7:	83 c4 10             	add    $0x10,%esp
801048ca:	8b 55 e0             	mov    -0x20(%ebp),%edx
801048cd:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
801048d0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d6:	8d 50 6c             	lea    0x6c(%eax),%edx
801048d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048dc:	83 c0 6c             	add    $0x6c,%eax
801048df:	83 ec 04             	sub    $0x4,%esp
801048e2:	6a 10                	push   $0x10
801048e4:	52                   	push   %edx
801048e5:	50                   	push   %eax
801048e6:	e8 04 0c 00 00       	call   801054ef <safestrcpy>
801048eb:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f1:	8b 40 10             	mov    0x10(%eax),%eax
801048f4:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048f7:	83 ec 0c             	sub    $0xc,%esp
801048fa:	68 80 19 11 80       	push   $0x80111980
801048ff:	e8 85 07 00 00       	call   80105089 <acquire>
80104904:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
80104907:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010490a:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
80104911:	83 ec 0c             	sub    $0xc,%esp
80104914:	68 80 19 11 80       	push   $0x80111980
80104919:	e8 d2 07 00 00       	call   801050f0 <release>
8010491e:	83 c4 10             	add    $0x10,%esp
  
  return pid;
80104921:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104924:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104927:	5b                   	pop    %ebx
80104928:	5e                   	pop    %esi
80104929:	5f                   	pop    %edi
8010492a:	5d                   	pop    %ebp
8010492b:	c3                   	ret    

8010492c <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010492c:	55                   	push   %ebp
8010492d:	89 e5                	mov    %esp,%ebp
8010492f:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
80104932:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104939:	a1 b4 38 11 80       	mov    0x801138b4,%eax
8010493e:	39 c2                	cmp    %eax,%edx
80104940:	75 0d                	jne    8010494f <exit+0x23>
    panic("init exiting");
80104942:	83 ec 0c             	sub    $0xc,%esp
80104945:	68 0a 8b 10 80       	push   $0x80108b0a
8010494a:	e8 2c bc ff ff       	call   8010057b <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010494f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104956:	eb 48                	jmp    801049a0 <exit+0x74>
    if(proc->ofile[fd]){
80104958:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010495e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104961:	83 c2 08             	add    $0x8,%edx
80104964:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104968:	85 c0                	test   %eax,%eax
8010496a:	74 30                	je     8010499c <exit+0x70>
      fileclose(proc->ofile[fd]);
8010496c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104972:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104975:	83 c2 08             	add    $0x8,%edx
80104978:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010497c:	83 ec 0c             	sub    $0xc,%esp
8010497f:	50                   	push   %eax
80104980:	e8 f9 c6 ff ff       	call   8010107e <fileclose>
80104985:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104988:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010498e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104991:	83 c2 08             	add    $0x8,%edx
80104994:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010499b:	00 
  for(fd = 0; fd < NOFILE; fd++){
8010499c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801049a0:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
801049a4:	7e b2                	jle    80104958 <exit+0x2c>
    }
  }

  begin_op();
801049a6:	e8 cb eb ff ff       	call   80103576 <begin_op>
  iput(proc->cwd);
801049ab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049b1:	8b 40 68             	mov    0x68(%eax),%eax
801049b4:	83 ec 0c             	sub    $0xc,%esp
801049b7:	50                   	push   %eax
801049b8:	e8 9a d1 ff ff       	call   80101b57 <iput>
801049bd:	83 c4 10             	add    $0x10,%esp
  end_op();
801049c0:	e8 3d ec ff ff       	call   80103602 <end_op>
  proc->cwd = 0;
801049c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cb:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
801049d2:	83 ec 0c             	sub    $0xc,%esp
801049d5:	68 80 19 11 80       	push   $0x80111980
801049da:	e8 aa 06 00 00       	call   80105089 <acquire>
801049df:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
801049e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049e8:	8b 40 14             	mov    0x14(%eax),%eax
801049eb:	83 ec 0c             	sub    $0xc,%esp
801049ee:	50                   	push   %eax
801049ef:	e8 46 04 00 00       	call   80104e3a <wakeup1>
801049f4:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f7:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
801049fe:	eb 3c                	jmp    80104a3c <exit+0x110>
    if(p->parent == proc){
80104a00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a03:	8b 50 14             	mov    0x14(%eax),%edx
80104a06:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a0c:	39 c2                	cmp    %eax,%edx
80104a0e:	75 28                	jne    80104a38 <exit+0x10c>
      p->parent = initproc;
80104a10:	8b 15 b4 38 11 80    	mov    0x801138b4,%edx
80104a16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a19:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a1f:	8b 40 0c             	mov    0xc(%eax),%eax
80104a22:	83 f8 05             	cmp    $0x5,%eax
80104a25:	75 11                	jne    80104a38 <exit+0x10c>
        wakeup1(initproc);
80104a27:	a1 b4 38 11 80       	mov    0x801138b4,%eax
80104a2c:	83 ec 0c             	sub    $0xc,%esp
80104a2f:	50                   	push   %eax
80104a30:	e8 05 04 00 00       	call   80104e3a <wakeup1>
80104a35:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a38:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104a3c:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104a43:	72 bb                	jb     80104a00 <exit+0xd4>
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a4b:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a52:	e8 fa 01 00 00       	call   80104c51 <sched>
  panic("zombie exit");
80104a57:	83 ec 0c             	sub    $0xc,%esp
80104a5a:	68 17 8b 10 80       	push   $0x80108b17
80104a5f:	e8 17 bb ff ff       	call   8010057b <panic>

80104a64 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a64:	55                   	push   %ebp
80104a65:	89 e5                	mov    %esp,%ebp
80104a67:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a6a:	83 ec 0c             	sub    $0xc,%esp
80104a6d:	68 80 19 11 80       	push   $0x80111980
80104a72:	e8 12 06 00 00       	call   80105089 <acquire>
80104a77:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a81:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
80104a88:	e9 a6 00 00 00       	jmp    80104b33 <wait+0xcf>
      if(p->parent != proc)
80104a8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a90:	8b 50 14             	mov    0x14(%eax),%edx
80104a93:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a99:	39 c2                	cmp    %eax,%edx
80104a9b:	0f 85 8d 00 00 00    	jne    80104b2e <wait+0xca>
        continue;
      havekids = 1;
80104aa1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aab:	8b 40 0c             	mov    0xc(%eax),%eax
80104aae:	83 f8 05             	cmp    $0x5,%eax
80104ab1:	75 7c                	jne    80104b2f <wait+0xcb>
        // Found one.
        pid = p->pid;
80104ab3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ab6:	8b 40 10             	mov    0x10(%eax),%eax
80104ab9:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abf:	8b 40 08             	mov    0x8(%eax),%eax
80104ac2:	83 ec 0c             	sub    $0xc,%esp
80104ac5:	50                   	push   %eax
80104ac6:	e8 11 e1 ff ff       	call   80102bdc <kfree>
80104acb:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adb:	8b 40 04             	mov    0x4(%eax),%eax
80104ade:	83 ec 0c             	sub    $0xc,%esp
80104ae1:	50                   	push   %eax
80104ae2:	e8 97 39 00 00       	call   8010847e <freevm>
80104ae7:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b01:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b12:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b19:	83 ec 0c             	sub    $0xc,%esp
80104b1c:	68 80 19 11 80       	push   $0x80111980
80104b21:	e8 ca 05 00 00       	call   801050f0 <release>
80104b26:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b2c:	eb 58                	jmp    80104b86 <wait+0x122>
        continue;
80104b2e:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b2f:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104b33:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104b3a:	0f 82 4d ff ff ff    	jb     80104a8d <wait+0x29>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b40:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b44:	74 0d                	je     80104b53 <wait+0xef>
80104b46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b4c:	8b 40 24             	mov    0x24(%eax),%eax
80104b4f:	85 c0                	test   %eax,%eax
80104b51:	74 17                	je     80104b6a <wait+0x106>
      release(&ptable.lock);
80104b53:	83 ec 0c             	sub    $0xc,%esp
80104b56:	68 80 19 11 80       	push   $0x80111980
80104b5b:	e8 90 05 00 00       	call   801050f0 <release>
80104b60:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b68:	eb 1c                	jmp    80104b86 <wait+0x122>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b6a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b70:	83 ec 08             	sub    $0x8,%esp
80104b73:	68 80 19 11 80       	push   $0x80111980
80104b78:	50                   	push   %eax
80104b79:	e8 10 02 00 00       	call   80104d8e <sleep>
80104b7e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80104b81:	e9 f4 fe ff ff       	jmp    80104a7a <wait+0x16>
  }
}
80104b86:	c9                   	leave  
80104b87:	c3                   	ret    

80104b88 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104b88:	55                   	push   %ebp
80104b89:	89 e5                	mov    %esp,%ebp
80104b8b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int ran = 0; // CS550: to solve the 100%-CPU-utilization-when-idling problem
80104b8e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104b95:	e8 fb f8 ff ff       	call   80104495 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104b9a:	83 ec 0c             	sub    $0xc,%esp
80104b9d:	68 80 19 11 80       	push   $0x80111980
80104ba2:	e8 e2 04 00 00       	call   80105089 <acquire>
80104ba7:	83 c4 10             	add    $0x10,%esp
    ran = 0;
80104baa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bb1:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
80104bb8:	eb 6a                	jmp    80104c24 <scheduler+0x9c>
      if(p->state != RUNNABLE)
80104bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bbd:	8b 40 0c             	mov    0xc(%eax),%eax
80104bc0:	83 f8 03             	cmp    $0x3,%eax
80104bc3:	75 5a                	jne    80104c1f <scheduler+0x97>
        continue;

      ran = 1;
80104bc5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      
      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcf:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104bd5:	83 ec 0c             	sub    $0xc,%esp
80104bd8:	ff 75 f4             	push   -0xc(%ebp)
80104bdb:	e8 59 34 00 00       	call   80108039 <switchuvm>
80104be0:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104be6:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104bed:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bf3:	8b 40 1c             	mov    0x1c(%eax),%eax
80104bf6:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104bfd:	83 c2 04             	add    $0x4,%edx
80104c00:	83 ec 08             	sub    $0x8,%esp
80104c03:	50                   	push   %eax
80104c04:	52                   	push   %edx
80104c05:	e8 57 09 00 00       	call   80105561 <swtch>
80104c0a:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104c0d:	e8 0a 34 00 00       	call   8010801c <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104c12:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104c19:	00 00 00 00 
80104c1d:	eb 01                	jmp    80104c20 <scheduler+0x98>
        continue;
80104c1f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c20:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104c24:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104c2b:	72 8d                	jb     80104bba <scheduler+0x32>
    }
    release(&ptable.lock);
80104c2d:	83 ec 0c             	sub    $0xc,%esp
80104c30:	68 80 19 11 80       	push   $0x80111980
80104c35:	e8 b6 04 00 00       	call   801050f0 <release>
80104c3a:	83 c4 10             	add    $0x10,%esp

    if (ran == 0){
80104c3d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c41:	0f 85 4e ff ff ff    	jne    80104b95 <scheduler+0xd>
        halt();
80104c47:	e8 50 f8 ff ff       	call   8010449c <halt>
    sti();
80104c4c:	e9 44 ff ff ff       	jmp    80104b95 <scheduler+0xd>

80104c51 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104c51:	55                   	push   %ebp
80104c52:	89 e5                	mov    %esp,%ebp
80104c54:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104c57:	83 ec 0c             	sub    $0xc,%esp
80104c5a:	68 80 19 11 80       	push   $0x80111980
80104c5f:	e8 59 05 00 00       	call   801051bd <holding>
80104c64:	83 c4 10             	add    $0x10,%esp
80104c67:	85 c0                	test   %eax,%eax
80104c69:	75 0d                	jne    80104c78 <sched+0x27>
    panic("sched ptable.lock");
80104c6b:	83 ec 0c             	sub    $0xc,%esp
80104c6e:	68 23 8b 10 80       	push   $0x80108b23
80104c73:	e8 03 b9 ff ff       	call   8010057b <panic>
  if(cpu->ncli != 1)
80104c78:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104c7e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104c84:	83 f8 01             	cmp    $0x1,%eax
80104c87:	74 0d                	je     80104c96 <sched+0x45>
    panic("sched locks");
80104c89:	83 ec 0c             	sub    $0xc,%esp
80104c8c:	68 35 8b 10 80       	push   $0x80108b35
80104c91:	e8 e5 b8 ff ff       	call   8010057b <panic>
  if(proc->state == RUNNING)
80104c96:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c9c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c9f:	83 f8 04             	cmp    $0x4,%eax
80104ca2:	75 0d                	jne    80104cb1 <sched+0x60>
    panic("sched running");
80104ca4:	83 ec 0c             	sub    $0xc,%esp
80104ca7:	68 41 8b 10 80       	push   $0x80108b41
80104cac:	e8 ca b8 ff ff       	call   8010057b <panic>
  if(readeflags()&FL_IF)
80104cb1:	e8 cf f7 ff ff       	call   80104485 <readeflags>
80104cb6:	25 00 02 00 00       	and    $0x200,%eax
80104cbb:	85 c0                	test   %eax,%eax
80104cbd:	74 0d                	je     80104ccc <sched+0x7b>
    panic("sched interruptible");
80104cbf:	83 ec 0c             	sub    $0xc,%esp
80104cc2:	68 4f 8b 10 80       	push   $0x80108b4f
80104cc7:	e8 af b8 ff ff       	call   8010057b <panic>
  intena = cpu->intena;
80104ccc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104cd2:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104cdb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104ce1:	8b 40 04             	mov    0x4(%eax),%eax
80104ce4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104ceb:	83 c2 1c             	add    $0x1c,%edx
80104cee:	83 ec 08             	sub    $0x8,%esp
80104cf1:	50                   	push   %eax
80104cf2:	52                   	push   %edx
80104cf3:	e8 69 08 00 00       	call   80105561 <swtch>
80104cf8:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104cfb:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d01:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d04:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d0a:	90                   	nop
80104d0b:	c9                   	leave  
80104d0c:	c3                   	ret    

80104d0d <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104d0d:	55                   	push   %ebp
80104d0e:	89 e5                	mov    %esp,%ebp
80104d10:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104d13:	83 ec 0c             	sub    $0xc,%esp
80104d16:	68 80 19 11 80       	push   $0x80111980
80104d1b:	e8 69 03 00 00       	call   80105089 <acquire>
80104d20:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104d23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d29:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104d30:	e8 1c ff ff ff       	call   80104c51 <sched>
  release(&ptable.lock);
80104d35:	83 ec 0c             	sub    $0xc,%esp
80104d38:	68 80 19 11 80       	push   $0x80111980
80104d3d:	e8 ae 03 00 00       	call   801050f0 <release>
80104d42:	83 c4 10             	add    $0x10,%esp
}
80104d45:	90                   	nop
80104d46:	c9                   	leave  
80104d47:	c3                   	ret    

80104d48 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
80104d4b:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104d4e:	83 ec 0c             	sub    $0xc,%esp
80104d51:	68 80 19 11 80       	push   $0x80111980
80104d56:	e8 95 03 00 00       	call   801050f0 <release>
80104d5b:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104d5e:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104d63:	85 c0                	test   %eax,%eax
80104d65:	74 24                	je     80104d8b <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104d67:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104d6e:	00 00 00 
    iinit(ROOTDEV);
80104d71:	83 ec 0c             	sub    $0xc,%esp
80104d74:	6a 01                	push   $0x1
80104d76:	e8 e0 c8 ff ff       	call   8010165b <iinit>
80104d7b:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104d7e:	83 ec 0c             	sub    $0xc,%esp
80104d81:	6a 01                	push   $0x1
80104d83:	e8 cf e5 ff ff       	call   80103357 <initlog>
80104d88:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104d8b:	90                   	nop
80104d8c:	c9                   	leave  
80104d8d:	c3                   	ret    

80104d8e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104d8e:	55                   	push   %ebp
80104d8f:	89 e5                	mov    %esp,%ebp
80104d91:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104d94:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d9a:	85 c0                	test   %eax,%eax
80104d9c:	75 0d                	jne    80104dab <sleep+0x1d>
    panic("sleep");
80104d9e:	83 ec 0c             	sub    $0xc,%esp
80104da1:	68 63 8b 10 80       	push   $0x80108b63
80104da6:	e8 d0 b7 ff ff       	call   8010057b <panic>

  if(lk == 0)
80104dab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104daf:	75 0d                	jne    80104dbe <sleep+0x30>
    panic("sleep without lk");
80104db1:	83 ec 0c             	sub    $0xc,%esp
80104db4:	68 69 8b 10 80       	push   $0x80108b69
80104db9:	e8 bd b7 ff ff       	call   8010057b <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104dbe:	81 7d 0c 80 19 11 80 	cmpl   $0x80111980,0xc(%ebp)
80104dc5:	74 1e                	je     80104de5 <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104dc7:	83 ec 0c             	sub    $0xc,%esp
80104dca:	68 80 19 11 80       	push   $0x80111980
80104dcf:	e8 b5 02 00 00       	call   80105089 <acquire>
80104dd4:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104dd7:	83 ec 0c             	sub    $0xc,%esp
80104dda:	ff 75 0c             	push   0xc(%ebp)
80104ddd:	e8 0e 03 00 00       	call   801050f0 <release>
80104de2:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104de5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104deb:	8b 55 08             	mov    0x8(%ebp),%edx
80104dee:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104df1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104df7:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104dfe:	e8 4e fe ff ff       	call   80104c51 <sched>

  // Tidy up.
  proc->chan = 0;
80104e03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e09:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104e10:	81 7d 0c 80 19 11 80 	cmpl   $0x80111980,0xc(%ebp)
80104e17:	74 1e                	je     80104e37 <sleep+0xa9>
    release(&ptable.lock);
80104e19:	83 ec 0c             	sub    $0xc,%esp
80104e1c:	68 80 19 11 80       	push   $0x80111980
80104e21:	e8 ca 02 00 00       	call   801050f0 <release>
80104e26:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104e29:	83 ec 0c             	sub    $0xc,%esp
80104e2c:	ff 75 0c             	push   0xc(%ebp)
80104e2f:	e8 55 02 00 00       	call   80105089 <acquire>
80104e34:	83 c4 10             	add    $0x10,%esp
  }
}
80104e37:	90                   	nop
80104e38:	c9                   	leave  
80104e39:	c3                   	ret    

80104e3a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104e3a:	55                   	push   %ebp
80104e3b:	89 e5                	mov    %esp,%ebp
80104e3d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e40:	c7 45 fc b4 19 11 80 	movl   $0x801119b4,-0x4(%ebp)
80104e47:	eb 24                	jmp    80104e6d <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104e49:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e4c:	8b 40 0c             	mov    0xc(%eax),%eax
80104e4f:	83 f8 02             	cmp    $0x2,%eax
80104e52:	75 15                	jne    80104e69 <wakeup1+0x2f>
80104e54:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e57:	8b 40 20             	mov    0x20(%eax),%eax
80104e5a:	39 45 08             	cmp    %eax,0x8(%ebp)
80104e5d:	75 0a                	jne    80104e69 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104e5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104e62:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104e69:	83 45 fc 7c          	addl   $0x7c,-0x4(%ebp)
80104e6d:	81 7d fc b4 38 11 80 	cmpl   $0x801138b4,-0x4(%ebp)
80104e74:	72 d3                	jb     80104e49 <wakeup1+0xf>
}
80104e76:	90                   	nop
80104e77:	90                   	nop
80104e78:	c9                   	leave  
80104e79:	c3                   	ret    

80104e7a <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104e7a:	55                   	push   %ebp
80104e7b:	89 e5                	mov    %esp,%ebp
80104e7d:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104e80:	83 ec 0c             	sub    $0xc,%esp
80104e83:	68 80 19 11 80       	push   $0x80111980
80104e88:	e8 fc 01 00 00       	call   80105089 <acquire>
80104e8d:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104e90:	83 ec 0c             	sub    $0xc,%esp
80104e93:	ff 75 08             	push   0x8(%ebp)
80104e96:	e8 9f ff ff ff       	call   80104e3a <wakeup1>
80104e9b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104e9e:	83 ec 0c             	sub    $0xc,%esp
80104ea1:	68 80 19 11 80       	push   $0x80111980
80104ea6:	e8 45 02 00 00       	call   801050f0 <release>
80104eab:	83 c4 10             	add    $0x10,%esp
}
80104eae:	90                   	nop
80104eaf:	c9                   	leave  
80104eb0:	c3                   	ret    

80104eb1 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104eb1:	55                   	push   %ebp
80104eb2:	89 e5                	mov    %esp,%ebp
80104eb4:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104eb7:	83 ec 0c             	sub    $0xc,%esp
80104eba:	68 80 19 11 80       	push   $0x80111980
80104ebf:	e8 c5 01 00 00       	call   80105089 <acquire>
80104ec4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ec7:	c7 45 f4 b4 19 11 80 	movl   $0x801119b4,-0xc(%ebp)
80104ece:	eb 45                	jmp    80104f15 <kill+0x64>
    if(p->pid == pid){
80104ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ed3:	8b 40 10             	mov    0x10(%eax),%eax
80104ed6:	39 45 08             	cmp    %eax,0x8(%ebp)
80104ed9:	75 36                	jne    80104f11 <kill+0x60>
      p->killed = 1;
80104edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ede:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ee8:	8b 40 0c             	mov    0xc(%eax),%eax
80104eeb:	83 f8 02             	cmp    $0x2,%eax
80104eee:	75 0a                	jne    80104efa <kill+0x49>
        p->state = RUNNABLE;
80104ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104efa:	83 ec 0c             	sub    $0xc,%esp
80104efd:	68 80 19 11 80       	push   $0x80111980
80104f02:	e8 e9 01 00 00       	call   801050f0 <release>
80104f07:	83 c4 10             	add    $0x10,%esp
      return 0;
80104f0a:	b8 00 00 00 00       	mov    $0x0,%eax
80104f0f:	eb 22                	jmp    80104f33 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f11:	83 45 f4 7c          	addl   $0x7c,-0xc(%ebp)
80104f15:	81 7d f4 b4 38 11 80 	cmpl   $0x801138b4,-0xc(%ebp)
80104f1c:	72 b2                	jb     80104ed0 <kill+0x1f>
    }
  }
  release(&ptable.lock);
80104f1e:	83 ec 0c             	sub    $0xc,%esp
80104f21:	68 80 19 11 80       	push   $0x80111980
80104f26:	e8 c5 01 00 00       	call   801050f0 <release>
80104f2b:	83 c4 10             	add    $0x10,%esp
  return -1;
80104f2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f33:	c9                   	leave  
80104f34:	c3                   	ret    

80104f35 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104f35:	55                   	push   %ebp
80104f36:	89 e5                	mov    %esp,%ebp
80104f38:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104f3b:	c7 45 f0 b4 19 11 80 	movl   $0x801119b4,-0x10(%ebp)
80104f42:	e9 d7 00 00 00       	jmp    8010501e <procdump+0xe9>
    if(p->state == UNUSED)
80104f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4a:	8b 40 0c             	mov    0xc(%eax),%eax
80104f4d:	85 c0                	test   %eax,%eax
80104f4f:	0f 84 c4 00 00 00    	je     80105019 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104f55:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f58:	8b 40 0c             	mov    0xc(%eax),%eax
80104f5b:	83 f8 05             	cmp    $0x5,%eax
80104f5e:	77 23                	ja     80104f83 <procdump+0x4e>
80104f60:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f63:	8b 40 0c             	mov    0xc(%eax),%eax
80104f66:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f6d:	85 c0                	test   %eax,%eax
80104f6f:	74 12                	je     80104f83 <procdump+0x4e>
      state = states[p->state];
80104f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f74:	8b 40 0c             	mov    0xc(%eax),%eax
80104f77:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80104f7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f81:	eb 07                	jmp    80104f8a <procdump+0x55>
    else
      state = "???";
80104f83:	c7 45 ec 7a 8b 10 80 	movl   $0x80108b7a,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104f8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f8d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f93:	8b 40 10             	mov    0x10(%eax),%eax
80104f96:	52                   	push   %edx
80104f97:	ff 75 ec             	push   -0x14(%ebp)
80104f9a:	50                   	push   %eax
80104f9b:	68 7e 8b 10 80       	push   $0x80108b7e
80104fa0:	e8 21 b4 ff ff       	call   801003c6 <cprintf>
80104fa5:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
80104fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fab:	8b 40 0c             	mov    0xc(%eax),%eax
80104fae:	83 f8 02             	cmp    $0x2,%eax
80104fb1:	75 54                	jne    80105007 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb6:	8b 40 1c             	mov    0x1c(%eax),%eax
80104fb9:	8b 40 0c             	mov    0xc(%eax),%eax
80104fbc:	83 c0 08             	add    $0x8,%eax
80104fbf:	89 c2                	mov    %eax,%edx
80104fc1:	83 ec 08             	sub    $0x8,%esp
80104fc4:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104fc7:	50                   	push   %eax
80104fc8:	52                   	push   %edx
80104fc9:	e8 74 01 00 00       	call   80105142 <getcallerpcs>
80104fce:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104fd1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fd8:	eb 1c                	jmp    80104ff6 <procdump+0xc1>
        cprintf(" %p", pc[i]);
80104fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdd:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104fe1:	83 ec 08             	sub    $0x8,%esp
80104fe4:	50                   	push   %eax
80104fe5:	68 87 8b 10 80       	push   $0x80108b87
80104fea:	e8 d7 b3 ff ff       	call   801003c6 <cprintf>
80104fef:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104ff2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ff6:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ffa:	7f 0b                	jg     80105007 <procdump+0xd2>
80104ffc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fff:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80105003:	85 c0                	test   %eax,%eax
80105005:	75 d3                	jne    80104fda <procdump+0xa5>
    }
    cprintf("\n");
80105007:	83 ec 0c             	sub    $0xc,%esp
8010500a:	68 8b 8b 10 80       	push   $0x80108b8b
8010500f:	e8 b2 b3 ff ff       	call   801003c6 <cprintf>
80105014:	83 c4 10             	add    $0x10,%esp
80105017:	eb 01                	jmp    8010501a <procdump+0xe5>
      continue;
80105019:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010501a:	83 45 f0 7c          	addl   $0x7c,-0x10(%ebp)
8010501e:	81 7d f0 b4 38 11 80 	cmpl   $0x801138b4,-0x10(%ebp)
80105025:	0f 82 1c ff ff ff    	jb     80104f47 <procdump+0x12>
  }
}
8010502b:	90                   	nop
8010502c:	90                   	nop
8010502d:	c9                   	leave  
8010502e:	c3                   	ret    

8010502f <readeflags>:
{
8010502f:	55                   	push   %ebp
80105030:	89 e5                	mov    %esp,%ebp
80105032:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105035:	9c                   	pushf  
80105036:	58                   	pop    %eax
80105037:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010503a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010503d:	c9                   	leave  
8010503e:	c3                   	ret    

8010503f <cli>:
{
8010503f:	55                   	push   %ebp
80105040:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105042:	fa                   	cli    
}
80105043:	90                   	nop
80105044:	5d                   	pop    %ebp
80105045:	c3                   	ret    

80105046 <sti>:
{
80105046:	55                   	push   %ebp
80105047:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105049:	fb                   	sti    
}
8010504a:	90                   	nop
8010504b:	5d                   	pop    %ebp
8010504c:	c3                   	ret    

8010504d <xchg>:
{
8010504d:	55                   	push   %ebp
8010504e:	89 e5                	mov    %esp,%ebp
80105050:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
80105053:	8b 55 08             	mov    0x8(%ebp),%edx
80105056:	8b 45 0c             	mov    0xc(%ebp),%eax
80105059:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010505c:	f0 87 02             	lock xchg %eax,(%edx)
8010505f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
80105062:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105065:	c9                   	leave  
80105066:	c3                   	ret    

80105067 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105067:	55                   	push   %ebp
80105068:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010506a:	8b 45 08             	mov    0x8(%ebp),%eax
8010506d:	8b 55 0c             	mov    0xc(%ebp),%edx
80105070:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105073:	8b 45 08             	mov    0x8(%ebp),%eax
80105076:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010507c:	8b 45 08             	mov    0x8(%ebp),%eax
8010507f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105086:	90                   	nop
80105087:	5d                   	pop    %ebp
80105088:	c3                   	ret    

80105089 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105089:	55                   	push   %ebp
8010508a:	89 e5                	mov    %esp,%ebp
8010508c:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010508f:	e8 53 01 00 00       	call   801051e7 <pushcli>
  if(holding(lk))
80105094:	8b 45 08             	mov    0x8(%ebp),%eax
80105097:	83 ec 0c             	sub    $0xc,%esp
8010509a:	50                   	push   %eax
8010509b:	e8 1d 01 00 00       	call   801051bd <holding>
801050a0:	83 c4 10             	add    $0x10,%esp
801050a3:	85 c0                	test   %eax,%eax
801050a5:	74 0d                	je     801050b4 <acquire+0x2b>
    panic("acquire");
801050a7:	83 ec 0c             	sub    $0xc,%esp
801050aa:	68 b7 8b 10 80       	push   $0x80108bb7
801050af:	e8 c7 b4 ff ff       	call   8010057b <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801050b4:	90                   	nop
801050b5:	8b 45 08             	mov    0x8(%ebp),%eax
801050b8:	83 ec 08             	sub    $0x8,%esp
801050bb:	6a 01                	push   $0x1
801050bd:	50                   	push   %eax
801050be:	e8 8a ff ff ff       	call   8010504d <xchg>
801050c3:	83 c4 10             	add    $0x10,%esp
801050c6:	85 c0                	test   %eax,%eax
801050c8:	75 eb                	jne    801050b5 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801050ca:	8b 45 08             	mov    0x8(%ebp),%eax
801050cd:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801050d4:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801050d7:	8b 45 08             	mov    0x8(%ebp),%eax
801050da:	83 c0 0c             	add    $0xc,%eax
801050dd:	83 ec 08             	sub    $0x8,%esp
801050e0:	50                   	push   %eax
801050e1:	8d 45 08             	lea    0x8(%ebp),%eax
801050e4:	50                   	push   %eax
801050e5:	e8 58 00 00 00       	call   80105142 <getcallerpcs>
801050ea:	83 c4 10             	add    $0x10,%esp
}
801050ed:	90                   	nop
801050ee:	c9                   	leave  
801050ef:	c3                   	ret    

801050f0 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801050f0:	55                   	push   %ebp
801050f1:	89 e5                	mov    %esp,%ebp
801050f3:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
801050f6:	83 ec 0c             	sub    $0xc,%esp
801050f9:	ff 75 08             	push   0x8(%ebp)
801050fc:	e8 bc 00 00 00       	call   801051bd <holding>
80105101:	83 c4 10             	add    $0x10,%esp
80105104:	85 c0                	test   %eax,%eax
80105106:	75 0d                	jne    80105115 <release+0x25>
    panic("release");
80105108:	83 ec 0c             	sub    $0xc,%esp
8010510b:	68 bf 8b 10 80       	push   $0x80108bbf
80105110:	e8 66 b4 ff ff       	call   8010057b <panic>

  lk->pcs[0] = 0;
80105115:	8b 45 08             	mov    0x8(%ebp),%eax
80105118:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010511f:	8b 45 08             	mov    0x8(%ebp),%eax
80105122:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105129:	8b 45 08             	mov    0x8(%ebp),%eax
8010512c:	83 ec 08             	sub    $0x8,%esp
8010512f:	6a 00                	push   $0x0
80105131:	50                   	push   %eax
80105132:	e8 16 ff ff ff       	call   8010504d <xchg>
80105137:	83 c4 10             	add    $0x10,%esp

  popcli();
8010513a:	e8 ec 00 00 00       	call   8010522b <popcli>
}
8010513f:	90                   	nop
80105140:	c9                   	leave  
80105141:	c3                   	ret    

80105142 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105142:	55                   	push   %ebp
80105143:	89 e5                	mov    %esp,%ebp
80105145:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105148:	8b 45 08             	mov    0x8(%ebp),%eax
8010514b:	83 e8 08             	sub    $0x8,%eax
8010514e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105151:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105158:	eb 38                	jmp    80105192 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010515a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010515e:	74 53                	je     801051b3 <getcallerpcs+0x71>
80105160:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105167:	76 4a                	jbe    801051b3 <getcallerpcs+0x71>
80105169:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010516d:	74 44                	je     801051b3 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010516f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105172:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105179:	8b 45 0c             	mov    0xc(%ebp),%eax
8010517c:	01 c2                	add    %eax,%edx
8010517e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105181:	8b 40 04             	mov    0x4(%eax),%eax
80105184:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105186:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105189:	8b 00                	mov    (%eax),%eax
8010518b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010518e:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80105192:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105196:	7e c2                	jle    8010515a <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
80105198:	eb 19                	jmp    801051b3 <getcallerpcs+0x71>
    pcs[i] = 0;
8010519a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010519d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801051a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801051a7:	01 d0                	add    %edx,%eax
801051a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
801051af:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801051b3:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801051b7:	7e e1                	jle    8010519a <getcallerpcs+0x58>
}
801051b9:	90                   	nop
801051ba:	90                   	nop
801051bb:	c9                   	leave  
801051bc:	c3                   	ret    

801051bd <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801051bd:	55                   	push   %ebp
801051be:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801051c0:	8b 45 08             	mov    0x8(%ebp),%eax
801051c3:	8b 00                	mov    (%eax),%eax
801051c5:	85 c0                	test   %eax,%eax
801051c7:	74 17                	je     801051e0 <holding+0x23>
801051c9:	8b 45 08             	mov    0x8(%ebp),%eax
801051cc:	8b 50 08             	mov    0x8(%eax),%edx
801051cf:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801051d5:	39 c2                	cmp    %eax,%edx
801051d7:	75 07                	jne    801051e0 <holding+0x23>
801051d9:	b8 01 00 00 00       	mov    $0x1,%eax
801051de:	eb 05                	jmp    801051e5 <holding+0x28>
801051e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051e5:	5d                   	pop    %ebp
801051e6:	c3                   	ret    

801051e7 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801051e7:	55                   	push   %ebp
801051e8:	89 e5                	mov    %esp,%ebp
801051ea:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801051ed:	e8 3d fe ff ff       	call   8010502f <readeflags>
801051f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
801051f5:	e8 45 fe ff ff       	call   8010503f <cli>
  if(cpu->ncli++ == 0)
801051fa:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105200:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105206:	8d 4a 01             	lea    0x1(%edx),%ecx
80105209:	89 88 ac 00 00 00    	mov    %ecx,0xac(%eax)
8010520f:	85 d2                	test   %edx,%edx
80105211:	75 15                	jne    80105228 <pushcli+0x41>
    cpu->intena = eflags & FL_IF;
80105213:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105219:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010521c:	81 e2 00 02 00 00    	and    $0x200,%edx
80105222:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105228:	90                   	nop
80105229:	c9                   	leave  
8010522a:	c3                   	ret    

8010522b <popcli>:

void
popcli(void)
{
8010522b:	55                   	push   %ebp
8010522c:	89 e5                	mov    %esp,%ebp
8010522e:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
80105231:	e8 f9 fd ff ff       	call   8010502f <readeflags>
80105236:	25 00 02 00 00       	and    $0x200,%eax
8010523b:	85 c0                	test   %eax,%eax
8010523d:	74 0d                	je     8010524c <popcli+0x21>
    panic("popcli - interruptible");
8010523f:	83 ec 0c             	sub    $0xc,%esp
80105242:	68 c7 8b 10 80       	push   $0x80108bc7
80105247:	e8 2f b3 ff ff       	call   8010057b <panic>
  if(--cpu->ncli < 0)
8010524c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105252:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105258:	83 ea 01             	sub    $0x1,%edx
8010525b:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
80105261:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105267:	85 c0                	test   %eax,%eax
80105269:	79 0d                	jns    80105278 <popcli+0x4d>
    panic("popcli");
8010526b:	83 ec 0c             	sub    $0xc,%esp
8010526e:	68 de 8b 10 80       	push   $0x80108bde
80105273:	e8 03 b3 ff ff       	call   8010057b <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105278:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010527e:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105284:	85 c0                	test   %eax,%eax
80105286:	75 15                	jne    8010529d <popcli+0x72>
80105288:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010528e:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80105294:	85 c0                	test   %eax,%eax
80105296:	74 05                	je     8010529d <popcli+0x72>
    sti();
80105298:	e8 a9 fd ff ff       	call   80105046 <sti>
}
8010529d:	90                   	nop
8010529e:	c9                   	leave  
8010529f:	c3                   	ret    

801052a0 <stosb>:
{
801052a0:	55                   	push   %ebp
801052a1:	89 e5                	mov    %esp,%ebp
801052a3:	57                   	push   %edi
801052a4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801052a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052a8:	8b 55 10             	mov    0x10(%ebp),%edx
801052ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801052ae:	89 cb                	mov    %ecx,%ebx
801052b0:	89 df                	mov    %ebx,%edi
801052b2:	89 d1                	mov    %edx,%ecx
801052b4:	fc                   	cld    
801052b5:	f3 aa                	rep stos %al,%es:(%edi)
801052b7:	89 ca                	mov    %ecx,%edx
801052b9:	89 fb                	mov    %edi,%ebx
801052bb:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052be:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052c1:	90                   	nop
801052c2:	5b                   	pop    %ebx
801052c3:	5f                   	pop    %edi
801052c4:	5d                   	pop    %ebp
801052c5:	c3                   	ret    

801052c6 <stosl>:
{
801052c6:	55                   	push   %ebp
801052c7:	89 e5                	mov    %esp,%ebp
801052c9:	57                   	push   %edi
801052ca:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801052cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
801052ce:	8b 55 10             	mov    0x10(%ebp),%edx
801052d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801052d4:	89 cb                	mov    %ecx,%ebx
801052d6:	89 df                	mov    %ebx,%edi
801052d8:	89 d1                	mov    %edx,%ecx
801052da:	fc                   	cld    
801052db:	f3 ab                	rep stos %eax,%es:(%edi)
801052dd:	89 ca                	mov    %ecx,%edx
801052df:	89 fb                	mov    %edi,%ebx
801052e1:	89 5d 08             	mov    %ebx,0x8(%ebp)
801052e4:	89 55 10             	mov    %edx,0x10(%ebp)
}
801052e7:	90                   	nop
801052e8:	5b                   	pop    %ebx
801052e9:	5f                   	pop    %edi
801052ea:	5d                   	pop    %ebp
801052eb:	c3                   	ret    

801052ec <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801052ec:	55                   	push   %ebp
801052ed:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801052ef:	8b 45 08             	mov    0x8(%ebp),%eax
801052f2:	83 e0 03             	and    $0x3,%eax
801052f5:	85 c0                	test   %eax,%eax
801052f7:	75 43                	jne    8010533c <memset+0x50>
801052f9:	8b 45 10             	mov    0x10(%ebp),%eax
801052fc:	83 e0 03             	and    $0x3,%eax
801052ff:	85 c0                	test   %eax,%eax
80105301:	75 39                	jne    8010533c <memset+0x50>
    c &= 0xFF;
80105303:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010530a:	8b 45 10             	mov    0x10(%ebp),%eax
8010530d:	c1 e8 02             	shr    $0x2,%eax
80105310:	89 c2                	mov    %eax,%edx
80105312:	8b 45 0c             	mov    0xc(%ebp),%eax
80105315:	c1 e0 18             	shl    $0x18,%eax
80105318:	89 c1                	mov    %eax,%ecx
8010531a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010531d:	c1 e0 10             	shl    $0x10,%eax
80105320:	09 c1                	or     %eax,%ecx
80105322:	8b 45 0c             	mov    0xc(%ebp),%eax
80105325:	c1 e0 08             	shl    $0x8,%eax
80105328:	09 c8                	or     %ecx,%eax
8010532a:	0b 45 0c             	or     0xc(%ebp),%eax
8010532d:	52                   	push   %edx
8010532e:	50                   	push   %eax
8010532f:	ff 75 08             	push   0x8(%ebp)
80105332:	e8 8f ff ff ff       	call   801052c6 <stosl>
80105337:	83 c4 0c             	add    $0xc,%esp
8010533a:	eb 12                	jmp    8010534e <memset+0x62>
  } else
    stosb(dst, c, n);
8010533c:	8b 45 10             	mov    0x10(%ebp),%eax
8010533f:	50                   	push   %eax
80105340:	ff 75 0c             	push   0xc(%ebp)
80105343:	ff 75 08             	push   0x8(%ebp)
80105346:	e8 55 ff ff ff       	call   801052a0 <stosb>
8010534b:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010534e:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105351:	c9                   	leave  
80105352:	c3                   	ret    

80105353 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105353:	55                   	push   %ebp
80105354:	89 e5                	mov    %esp,%ebp
80105356:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105359:	8b 45 08             	mov    0x8(%ebp),%eax
8010535c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010535f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105362:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105365:	eb 30                	jmp    80105397 <memcmp+0x44>
    if(*s1 != *s2)
80105367:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010536a:	0f b6 10             	movzbl (%eax),%edx
8010536d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105370:	0f b6 00             	movzbl (%eax),%eax
80105373:	38 c2                	cmp    %al,%dl
80105375:	74 18                	je     8010538f <memcmp+0x3c>
      return *s1 - *s2;
80105377:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010537a:	0f b6 00             	movzbl (%eax),%eax
8010537d:	0f b6 d0             	movzbl %al,%edx
80105380:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105383:	0f b6 00             	movzbl (%eax),%eax
80105386:	0f b6 c8             	movzbl %al,%ecx
80105389:	89 d0                	mov    %edx,%eax
8010538b:	29 c8                	sub    %ecx,%eax
8010538d:	eb 1a                	jmp    801053a9 <memcmp+0x56>
    s1++, s2++;
8010538f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105393:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80105397:	8b 45 10             	mov    0x10(%ebp),%eax
8010539a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010539d:	89 55 10             	mov    %edx,0x10(%ebp)
801053a0:	85 c0                	test   %eax,%eax
801053a2:	75 c3                	jne    80105367 <memcmp+0x14>
  }

  return 0;
801053a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801053a9:	c9                   	leave  
801053aa:	c3                   	ret    

801053ab <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801053ab:	55                   	push   %ebp
801053ac:	89 e5                	mov    %esp,%ebp
801053ae:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801053b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801053b7:	8b 45 08             	mov    0x8(%ebp),%eax
801053ba:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801053bd:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053c0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801053c3:	73 54                	jae    80105419 <memmove+0x6e>
801053c5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801053c8:	8b 45 10             	mov    0x10(%ebp),%eax
801053cb:	01 d0                	add    %edx,%eax
801053cd:	39 45 f8             	cmp    %eax,-0x8(%ebp)
801053d0:	73 47                	jae    80105419 <memmove+0x6e>
    s += n;
801053d2:	8b 45 10             	mov    0x10(%ebp),%eax
801053d5:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801053d8:	8b 45 10             	mov    0x10(%ebp),%eax
801053db:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801053de:	eb 13                	jmp    801053f3 <memmove+0x48>
      *--d = *--s;
801053e0:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
801053e4:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
801053e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
801053eb:	0f b6 10             	movzbl (%eax),%edx
801053ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
801053f1:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
801053f3:	8b 45 10             	mov    0x10(%ebp),%eax
801053f6:	8d 50 ff             	lea    -0x1(%eax),%edx
801053f9:	89 55 10             	mov    %edx,0x10(%ebp)
801053fc:	85 c0                	test   %eax,%eax
801053fe:	75 e0                	jne    801053e0 <memmove+0x35>
  if(s < d && s + n > d){
80105400:	eb 24                	jmp    80105426 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80105402:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105405:	8d 42 01             	lea    0x1(%edx),%eax
80105408:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010540b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010540e:	8d 48 01             	lea    0x1(%eax),%ecx
80105411:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80105414:	0f b6 12             	movzbl (%edx),%edx
80105417:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80105419:	8b 45 10             	mov    0x10(%ebp),%eax
8010541c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010541f:	89 55 10             	mov    %edx,0x10(%ebp)
80105422:	85 c0                	test   %eax,%eax
80105424:	75 dc                	jne    80105402 <memmove+0x57>

  return dst;
80105426:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105429:	c9                   	leave  
8010542a:	c3                   	ret    

8010542b <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010542b:	55                   	push   %ebp
8010542c:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010542e:	ff 75 10             	push   0x10(%ebp)
80105431:	ff 75 0c             	push   0xc(%ebp)
80105434:	ff 75 08             	push   0x8(%ebp)
80105437:	e8 6f ff ff ff       	call   801053ab <memmove>
8010543c:	83 c4 0c             	add    $0xc,%esp
}
8010543f:	c9                   	leave  
80105440:	c3                   	ret    

80105441 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105441:	55                   	push   %ebp
80105442:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105444:	eb 0c                	jmp    80105452 <strncmp+0x11>
    n--, p++, q++;
80105446:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010544a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010544e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80105452:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105456:	74 1a                	je     80105472 <strncmp+0x31>
80105458:	8b 45 08             	mov    0x8(%ebp),%eax
8010545b:	0f b6 00             	movzbl (%eax),%eax
8010545e:	84 c0                	test   %al,%al
80105460:	74 10                	je     80105472 <strncmp+0x31>
80105462:	8b 45 08             	mov    0x8(%ebp),%eax
80105465:	0f b6 10             	movzbl (%eax),%edx
80105468:	8b 45 0c             	mov    0xc(%ebp),%eax
8010546b:	0f b6 00             	movzbl (%eax),%eax
8010546e:	38 c2                	cmp    %al,%dl
80105470:	74 d4                	je     80105446 <strncmp+0x5>
  if(n == 0)
80105472:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105476:	75 07                	jne    8010547f <strncmp+0x3e>
    return 0;
80105478:	b8 00 00 00 00       	mov    $0x0,%eax
8010547d:	eb 16                	jmp    80105495 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010547f:	8b 45 08             	mov    0x8(%ebp),%eax
80105482:	0f b6 00             	movzbl (%eax),%eax
80105485:	0f b6 d0             	movzbl %al,%edx
80105488:	8b 45 0c             	mov    0xc(%ebp),%eax
8010548b:	0f b6 00             	movzbl (%eax),%eax
8010548e:	0f b6 c8             	movzbl %al,%ecx
80105491:	89 d0                	mov    %edx,%eax
80105493:	29 c8                	sub    %ecx,%eax
}
80105495:	5d                   	pop    %ebp
80105496:	c3                   	ret    

80105497 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105497:	55                   	push   %ebp
80105498:	89 e5                	mov    %esp,%ebp
8010549a:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
8010549d:	8b 45 08             	mov    0x8(%ebp),%eax
801054a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801054a3:	90                   	nop
801054a4:	8b 45 10             	mov    0x10(%ebp),%eax
801054a7:	8d 50 ff             	lea    -0x1(%eax),%edx
801054aa:	89 55 10             	mov    %edx,0x10(%ebp)
801054ad:	85 c0                	test   %eax,%eax
801054af:	7e 2c                	jle    801054dd <strncpy+0x46>
801054b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801054b4:	8d 42 01             	lea    0x1(%edx),%eax
801054b7:	89 45 0c             	mov    %eax,0xc(%ebp)
801054ba:	8b 45 08             	mov    0x8(%ebp),%eax
801054bd:	8d 48 01             	lea    0x1(%eax),%ecx
801054c0:	89 4d 08             	mov    %ecx,0x8(%ebp)
801054c3:	0f b6 12             	movzbl (%edx),%edx
801054c6:	88 10                	mov    %dl,(%eax)
801054c8:	0f b6 00             	movzbl (%eax),%eax
801054cb:	84 c0                	test   %al,%al
801054cd:	75 d5                	jne    801054a4 <strncpy+0xd>
    ;
  while(n-- > 0)
801054cf:	eb 0c                	jmp    801054dd <strncpy+0x46>
    *s++ = 0;
801054d1:	8b 45 08             	mov    0x8(%ebp),%eax
801054d4:	8d 50 01             	lea    0x1(%eax),%edx
801054d7:	89 55 08             	mov    %edx,0x8(%ebp)
801054da:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
801054dd:	8b 45 10             	mov    0x10(%ebp),%eax
801054e0:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e3:	89 55 10             	mov    %edx,0x10(%ebp)
801054e6:	85 c0                	test   %eax,%eax
801054e8:	7f e7                	jg     801054d1 <strncpy+0x3a>
  return os;
801054ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801054ed:	c9                   	leave  
801054ee:	c3                   	ret    

801054ef <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801054ef:	55                   	push   %ebp
801054f0:	89 e5                	mov    %esp,%ebp
801054f2:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801054f5:	8b 45 08             	mov    0x8(%ebp),%eax
801054f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801054fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801054ff:	7f 05                	jg     80105506 <safestrcpy+0x17>
    return os;
80105501:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105504:	eb 32                	jmp    80105538 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80105506:	90                   	nop
80105507:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
8010550b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010550f:	7e 1e                	jle    8010552f <safestrcpy+0x40>
80105511:	8b 55 0c             	mov    0xc(%ebp),%edx
80105514:	8d 42 01             	lea    0x1(%edx),%eax
80105517:	89 45 0c             	mov    %eax,0xc(%ebp)
8010551a:	8b 45 08             	mov    0x8(%ebp),%eax
8010551d:	8d 48 01             	lea    0x1(%eax),%ecx
80105520:	89 4d 08             	mov    %ecx,0x8(%ebp)
80105523:	0f b6 12             	movzbl (%edx),%edx
80105526:	88 10                	mov    %dl,(%eax)
80105528:	0f b6 00             	movzbl (%eax),%eax
8010552b:	84 c0                	test   %al,%al
8010552d:	75 d8                	jne    80105507 <safestrcpy+0x18>
    ;
  *s = 0;
8010552f:	8b 45 08             	mov    0x8(%ebp),%eax
80105532:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105535:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105538:	c9                   	leave  
80105539:	c3                   	ret    

8010553a <strlen>:

int
strlen(const char *s)
{
8010553a:	55                   	push   %ebp
8010553b:	89 e5                	mov    %esp,%ebp
8010553d:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105540:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105547:	eb 04                	jmp    8010554d <strlen+0x13>
80105549:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010554d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105550:	8b 45 08             	mov    0x8(%ebp),%eax
80105553:	01 d0                	add    %edx,%eax
80105555:	0f b6 00             	movzbl (%eax),%eax
80105558:	84 c0                	test   %al,%al
8010555a:	75 ed                	jne    80105549 <strlen+0xf>
    ;
  return n;
8010555c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010555f:	c9                   	leave  
80105560:	c3                   	ret    

80105561 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105561:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105565:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105569:	55                   	push   %ebp
  pushl %ebx
8010556a:	53                   	push   %ebx
  pushl %esi
8010556b:	56                   	push   %esi
  pushl %edi
8010556c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010556d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010556f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105571:	5f                   	pop    %edi
  popl %esi
80105572:	5e                   	pop    %esi
  popl %ebx
80105573:	5b                   	pop    %ebx
  popl %ebp
80105574:	5d                   	pop    %ebp
  ret
80105575:	c3                   	ret    

80105576 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105576:	55                   	push   %ebp
80105577:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105579:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010557f:	8b 00                	mov    (%eax),%eax
80105581:	39 45 08             	cmp    %eax,0x8(%ebp)
80105584:	73 12                	jae    80105598 <fetchint+0x22>
80105586:	8b 45 08             	mov    0x8(%ebp),%eax
80105589:	8d 50 04             	lea    0x4(%eax),%edx
8010558c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105592:	8b 00                	mov    (%eax),%eax
80105594:	39 c2                	cmp    %eax,%edx
80105596:	76 07                	jbe    8010559f <fetchint+0x29>
    return -1;
80105598:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010559d:	eb 0f                	jmp    801055ae <fetchint+0x38>
  *ip = *(int*)(addr);
8010559f:	8b 45 08             	mov    0x8(%ebp),%eax
801055a2:	8b 10                	mov    (%eax),%edx
801055a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a7:	89 10                	mov    %edx,(%eax)
  return 0;
801055a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055ae:	5d                   	pop    %ebp
801055af:	c3                   	ret    

801055b0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801055b0:	55                   	push   %ebp
801055b1:	89 e5                	mov    %esp,%ebp
801055b3:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801055b6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055bc:	8b 00                	mov    (%eax),%eax
801055be:	39 45 08             	cmp    %eax,0x8(%ebp)
801055c1:	72 07                	jb     801055ca <fetchstr+0x1a>
    return -1;
801055c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c8:	eb 44                	jmp    8010560e <fetchstr+0x5e>
  *pp = (char*)addr;
801055ca:	8b 55 08             	mov    0x8(%ebp),%edx
801055cd:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d0:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801055d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801055d8:	8b 00                	mov    (%eax),%eax
801055da:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801055dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801055e0:	8b 00                	mov    (%eax),%eax
801055e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
801055e5:	eb 1a                	jmp    80105601 <fetchstr+0x51>
    if(*s == 0)
801055e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ea:	0f b6 00             	movzbl (%eax),%eax
801055ed:	84 c0                	test   %al,%al
801055ef:	75 0c                	jne    801055fd <fetchstr+0x4d>
      return s - *pp;
801055f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801055f4:	8b 10                	mov    (%eax),%edx
801055f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055f9:	29 d0                	sub    %edx,%eax
801055fb:	eb 11                	jmp    8010560e <fetchstr+0x5e>
  for(s = *pp; s < ep; s++)
801055fd:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105601:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105604:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105607:	72 de                	jb     801055e7 <fetchstr+0x37>
  return -1;
80105609:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010560e:	c9                   	leave  
8010560f:	c3                   	ret    

80105610 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105610:	55                   	push   %ebp
80105611:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105613:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105619:	8b 40 18             	mov    0x18(%eax),%eax
8010561c:	8b 50 44             	mov    0x44(%eax),%edx
8010561f:	8b 45 08             	mov    0x8(%ebp),%eax
80105622:	c1 e0 02             	shl    $0x2,%eax
80105625:	01 d0                	add    %edx,%eax
80105627:	83 c0 04             	add    $0x4,%eax
8010562a:	ff 75 0c             	push   0xc(%ebp)
8010562d:	50                   	push   %eax
8010562e:	e8 43 ff ff ff       	call   80105576 <fetchint>
80105633:	83 c4 08             	add    $0x8,%esp
}
80105636:	c9                   	leave  
80105637:	c3                   	ret    

80105638 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105638:	55                   	push   %ebp
80105639:	89 e5                	mov    %esp,%ebp
8010563b:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010563e:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105641:	50                   	push   %eax
80105642:	ff 75 08             	push   0x8(%ebp)
80105645:	e8 c6 ff ff ff       	call   80105610 <argint>
8010564a:	83 c4 08             	add    $0x8,%esp
8010564d:	85 c0                	test   %eax,%eax
8010564f:	79 07                	jns    80105658 <argptr+0x20>
    return -1;
80105651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105656:	eb 3b                	jmp    80105693 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105658:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010565e:	8b 00                	mov    (%eax),%eax
80105660:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105663:	39 d0                	cmp    %edx,%eax
80105665:	76 16                	jbe    8010567d <argptr+0x45>
80105667:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010566a:	89 c2                	mov    %eax,%edx
8010566c:	8b 45 10             	mov    0x10(%ebp),%eax
8010566f:	01 c2                	add    %eax,%edx
80105671:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105677:	8b 00                	mov    (%eax),%eax
80105679:	39 c2                	cmp    %eax,%edx
8010567b:	76 07                	jbe    80105684 <argptr+0x4c>
    return -1;
8010567d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105682:	eb 0f                	jmp    80105693 <argptr+0x5b>
  *pp = (char*)i;
80105684:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105687:	89 c2                	mov    %eax,%edx
80105689:	8b 45 0c             	mov    0xc(%ebp),%eax
8010568c:	89 10                	mov    %edx,(%eax)
  return 0;
8010568e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105693:	c9                   	leave  
80105694:	c3                   	ret    

80105695 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105695:	55                   	push   %ebp
80105696:	89 e5                	mov    %esp,%ebp
80105698:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010569b:	8d 45 fc             	lea    -0x4(%ebp),%eax
8010569e:	50                   	push   %eax
8010569f:	ff 75 08             	push   0x8(%ebp)
801056a2:	e8 69 ff ff ff       	call   80105610 <argint>
801056a7:	83 c4 08             	add    $0x8,%esp
801056aa:	85 c0                	test   %eax,%eax
801056ac:	79 07                	jns    801056b5 <argstr+0x20>
    return -1;
801056ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056b3:	eb 0f                	jmp    801056c4 <argstr+0x2f>
  return fetchstr(addr, pp);
801056b5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801056b8:	ff 75 0c             	push   0xc(%ebp)
801056bb:	50                   	push   %eax
801056bc:	e8 ef fe ff ff       	call   801055b0 <fetchstr>
801056c1:	83 c4 08             	add    $0x8,%esp
}
801056c4:	c9                   	leave  
801056c5:	c3                   	ret    

801056c6 <syscall>:
[SYS_shmdel] sys_shmdel,                                // CS 3320 project 2
};

void
syscall(void)
{
801056c6:	55                   	push   %ebp
801056c7:	89 e5                	mov    %esp,%ebp
801056c9:	83 ec 18             	sub    $0x18,%esp
  int num;

  num = proc->tf->eax;
801056cc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d2:	8b 40 18             	mov    0x18(%eax),%eax
801056d5:	8b 40 1c             	mov    0x1c(%eax),%eax
801056d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801056db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056df:	7e 32                	jle    80105713 <syscall+0x4d>
801056e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056e4:	83 f8 1a             	cmp    $0x1a,%eax
801056e7:	77 2a                	ja     80105713 <syscall+0x4d>
801056e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056ec:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
801056f3:	85 c0                	test   %eax,%eax
801056f5:	74 1c                	je     80105713 <syscall+0x4d>
    proc->tf->eax = syscalls[num]();
801056f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fa:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105701:	ff d0                	call   *%eax
80105703:	89 c2                	mov    %eax,%edx
80105705:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010570b:	8b 40 18             	mov    0x18(%eax),%eax
8010570e:	89 50 1c             	mov    %edx,0x1c(%eax)
80105711:	eb 35                	jmp    80105748 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105713:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105719:	8d 50 6c             	lea    0x6c(%eax),%edx
8010571c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("%d %s: unknown sys call %d\n",
80105722:	8b 40 10             	mov    0x10(%eax),%eax
80105725:	ff 75 f4             	push   -0xc(%ebp)
80105728:	52                   	push   %edx
80105729:	50                   	push   %eax
8010572a:	68 e5 8b 10 80       	push   $0x80108be5
8010572f:	e8 92 ac ff ff       	call   801003c6 <cprintf>
80105734:	83 c4 10             	add    $0x10,%esp
    proc->tf->eax = -1;
80105737:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010573d:	8b 40 18             	mov    0x18(%eax),%eax
80105740:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105747:	90                   	nop
80105748:	90                   	nop
80105749:	c9                   	leave  
8010574a:	c3                   	ret    

8010574b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010574b:	55                   	push   %ebp
8010574c:	89 e5                	mov    %esp,%ebp
8010574e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105751:	83 ec 08             	sub    $0x8,%esp
80105754:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105757:	50                   	push   %eax
80105758:	ff 75 08             	push   0x8(%ebp)
8010575b:	e8 b0 fe ff ff       	call   80105610 <argint>
80105760:	83 c4 10             	add    $0x10,%esp
80105763:	85 c0                	test   %eax,%eax
80105765:	79 07                	jns    8010576e <argfd+0x23>
    return -1;
80105767:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010576c:	eb 50                	jmp    801057be <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010576e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105771:	85 c0                	test   %eax,%eax
80105773:	78 21                	js     80105796 <argfd+0x4b>
80105775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105778:	83 f8 0f             	cmp    $0xf,%eax
8010577b:	7f 19                	jg     80105796 <argfd+0x4b>
8010577d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105783:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105786:	83 c2 08             	add    $0x8,%edx
80105789:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010578d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105790:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105794:	75 07                	jne    8010579d <argfd+0x52>
    return -1;
80105796:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010579b:	eb 21                	jmp    801057be <argfd+0x73>
  if(pfd)
8010579d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801057a1:	74 08                	je     801057ab <argfd+0x60>
    *pfd = fd;
801057a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801057a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801057a9:	89 10                	mov    %edx,(%eax)
  if(pf)
801057ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801057af:	74 08                	je     801057b9 <argfd+0x6e>
    *pf = f;
801057b1:	8b 45 10             	mov    0x10(%ebp),%eax
801057b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801057b7:	89 10                	mov    %edx,(%eax)
  return 0;
801057b9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057be:	c9                   	leave  
801057bf:	c3                   	ret    

801057c0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801057c6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801057cd:	eb 30                	jmp    801057ff <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801057cf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057d8:	83 c2 08             	add    $0x8,%edx
801057db:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801057df:	85 c0                	test   %eax,%eax
801057e1:	75 18                	jne    801057fb <fdalloc+0x3b>
      proc->ofile[fd] = f;
801057e3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057ec:	8d 4a 08             	lea    0x8(%edx),%ecx
801057ef:	8b 55 08             	mov    0x8(%ebp),%edx
801057f2:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801057f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057f9:	eb 0f                	jmp    8010580a <fdalloc+0x4a>
  for(fd = 0; fd < NOFILE; fd++){
801057fb:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801057ff:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105803:	7e ca                	jle    801057cf <fdalloc+0xf>
    }
  }
  return -1;
80105805:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010580a:	c9                   	leave  
8010580b:	c3                   	ret    

8010580c <sys_dup>:

int
sys_dup(void)
{
8010580c:	55                   	push   %ebp
8010580d:	89 e5                	mov    %esp,%ebp
8010580f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105812:	83 ec 04             	sub    $0x4,%esp
80105815:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105818:	50                   	push   %eax
80105819:	6a 00                	push   $0x0
8010581b:	6a 00                	push   $0x0
8010581d:	e8 29 ff ff ff       	call   8010574b <argfd>
80105822:	83 c4 10             	add    $0x10,%esp
80105825:	85 c0                	test   %eax,%eax
80105827:	79 07                	jns    80105830 <sys_dup+0x24>
    return -1;
80105829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010582e:	eb 31                	jmp    80105861 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105830:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105833:	83 ec 0c             	sub    $0xc,%esp
80105836:	50                   	push   %eax
80105837:	e8 84 ff ff ff       	call   801057c0 <fdalloc>
8010583c:	83 c4 10             	add    $0x10,%esp
8010583f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105842:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105846:	79 07                	jns    8010584f <sys_dup+0x43>
    return -1;
80105848:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010584d:	eb 12                	jmp    80105861 <sys_dup+0x55>
  filedup(f);
8010584f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105852:	83 ec 0c             	sub    $0xc,%esp
80105855:	50                   	push   %eax
80105856:	e8 d2 b7 ff ff       	call   8010102d <filedup>
8010585b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010585e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105861:	c9                   	leave  
80105862:	c3                   	ret    

80105863 <sys_read>:

int
sys_read(void)
{
80105863:	55                   	push   %ebp
80105864:	89 e5                	mov    %esp,%ebp
80105866:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105869:	83 ec 04             	sub    $0x4,%esp
8010586c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010586f:	50                   	push   %eax
80105870:	6a 00                	push   $0x0
80105872:	6a 00                	push   $0x0
80105874:	e8 d2 fe ff ff       	call   8010574b <argfd>
80105879:	83 c4 10             	add    $0x10,%esp
8010587c:	85 c0                	test   %eax,%eax
8010587e:	78 2e                	js     801058ae <sys_read+0x4b>
80105880:	83 ec 08             	sub    $0x8,%esp
80105883:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105886:	50                   	push   %eax
80105887:	6a 02                	push   $0x2
80105889:	e8 82 fd ff ff       	call   80105610 <argint>
8010588e:	83 c4 10             	add    $0x10,%esp
80105891:	85 c0                	test   %eax,%eax
80105893:	78 19                	js     801058ae <sys_read+0x4b>
80105895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105898:	83 ec 04             	sub    $0x4,%esp
8010589b:	50                   	push   %eax
8010589c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010589f:	50                   	push   %eax
801058a0:	6a 01                	push   $0x1
801058a2:	e8 91 fd ff ff       	call   80105638 <argptr>
801058a7:	83 c4 10             	add    $0x10,%esp
801058aa:	85 c0                	test   %eax,%eax
801058ac:	79 07                	jns    801058b5 <sys_read+0x52>
    return -1;
801058ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058b3:	eb 17                	jmp    801058cc <sys_read+0x69>
  return fileread(f, p, n);
801058b5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801058b8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801058bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801058be:	83 ec 04             	sub    $0x4,%esp
801058c1:	51                   	push   %ecx
801058c2:	52                   	push   %edx
801058c3:	50                   	push   %eax
801058c4:	e8 f4 b8 ff ff       	call   801011bd <fileread>
801058c9:	83 c4 10             	add    $0x10,%esp
}
801058cc:	c9                   	leave  
801058cd:	c3                   	ret    

801058ce <sys_write>:

int
sys_write(void)
{
801058ce:	55                   	push   %ebp
801058cf:	89 e5                	mov    %esp,%ebp
801058d1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801058d4:	83 ec 04             	sub    $0x4,%esp
801058d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801058da:	50                   	push   %eax
801058db:	6a 00                	push   $0x0
801058dd:	6a 00                	push   $0x0
801058df:	e8 67 fe ff ff       	call   8010574b <argfd>
801058e4:	83 c4 10             	add    $0x10,%esp
801058e7:	85 c0                	test   %eax,%eax
801058e9:	78 2e                	js     80105919 <sys_write+0x4b>
801058eb:	83 ec 08             	sub    $0x8,%esp
801058ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
801058f1:	50                   	push   %eax
801058f2:	6a 02                	push   $0x2
801058f4:	e8 17 fd ff ff       	call   80105610 <argint>
801058f9:	83 c4 10             	add    $0x10,%esp
801058fc:	85 c0                	test   %eax,%eax
801058fe:	78 19                	js     80105919 <sys_write+0x4b>
80105900:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105903:	83 ec 04             	sub    $0x4,%esp
80105906:	50                   	push   %eax
80105907:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010590a:	50                   	push   %eax
8010590b:	6a 01                	push   $0x1
8010590d:	e8 26 fd ff ff       	call   80105638 <argptr>
80105912:	83 c4 10             	add    $0x10,%esp
80105915:	85 c0                	test   %eax,%eax
80105917:	79 07                	jns    80105920 <sys_write+0x52>
    return -1;
80105919:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010591e:	eb 17                	jmp    80105937 <sys_write+0x69>
  return filewrite(f, p, n);
80105920:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105923:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105929:	83 ec 04             	sub    $0x4,%esp
8010592c:	51                   	push   %ecx
8010592d:	52                   	push   %edx
8010592e:	50                   	push   %eax
8010592f:	e8 41 b9 ff ff       	call   80101275 <filewrite>
80105934:	83 c4 10             	add    $0x10,%esp
}
80105937:	c9                   	leave  
80105938:	c3                   	ret    

80105939 <sys_close>:

int
sys_close(void)
{
80105939:	55                   	push   %ebp
8010593a:	89 e5                	mov    %esp,%ebp
8010593c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010593f:	83 ec 04             	sub    $0x4,%esp
80105942:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105945:	50                   	push   %eax
80105946:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105949:	50                   	push   %eax
8010594a:	6a 00                	push   $0x0
8010594c:	e8 fa fd ff ff       	call   8010574b <argfd>
80105951:	83 c4 10             	add    $0x10,%esp
80105954:	85 c0                	test   %eax,%eax
80105956:	79 07                	jns    8010595f <sys_close+0x26>
    return -1;
80105958:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595d:	eb 28                	jmp    80105987 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010595f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105965:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105968:	83 c2 08             	add    $0x8,%edx
8010596b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105972:	00 
  fileclose(f);
80105973:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105976:	83 ec 0c             	sub    $0xc,%esp
80105979:	50                   	push   %eax
8010597a:	e8 ff b6 ff ff       	call   8010107e <fileclose>
8010597f:	83 c4 10             	add    $0x10,%esp
  return 0;
80105982:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105987:	c9                   	leave  
80105988:	c3                   	ret    

80105989 <sys_fstat>:

int
sys_fstat(void)
{
80105989:	55                   	push   %ebp
8010598a:	89 e5                	mov    %esp,%ebp
8010598c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010598f:	83 ec 04             	sub    $0x4,%esp
80105992:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105995:	50                   	push   %eax
80105996:	6a 00                	push   $0x0
80105998:	6a 00                	push   $0x0
8010599a:	e8 ac fd ff ff       	call   8010574b <argfd>
8010599f:	83 c4 10             	add    $0x10,%esp
801059a2:	85 c0                	test   %eax,%eax
801059a4:	78 17                	js     801059bd <sys_fstat+0x34>
801059a6:	83 ec 04             	sub    $0x4,%esp
801059a9:	6a 14                	push   $0x14
801059ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059ae:	50                   	push   %eax
801059af:	6a 01                	push   $0x1
801059b1:	e8 82 fc ff ff       	call   80105638 <argptr>
801059b6:	83 c4 10             	add    $0x10,%esp
801059b9:	85 c0                	test   %eax,%eax
801059bb:	79 07                	jns    801059c4 <sys_fstat+0x3b>
    return -1;
801059bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059c2:	eb 13                	jmp    801059d7 <sys_fstat+0x4e>
  return filestat(f, st);
801059c4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801059c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059ca:	83 ec 08             	sub    $0x8,%esp
801059cd:	52                   	push   %edx
801059ce:	50                   	push   %eax
801059cf:	e8 92 b7 ff ff       	call   80101166 <filestat>
801059d4:	83 c4 10             	add    $0x10,%esp
}
801059d7:	c9                   	leave  
801059d8:	c3                   	ret    

801059d9 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801059d9:	55                   	push   %ebp
801059da:	89 e5                	mov    %esp,%ebp
801059dc:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801059df:	83 ec 08             	sub    $0x8,%esp
801059e2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801059e5:	50                   	push   %eax
801059e6:	6a 00                	push   $0x0
801059e8:	e8 a8 fc ff ff       	call   80105695 <argstr>
801059ed:	83 c4 10             	add    $0x10,%esp
801059f0:	85 c0                	test   %eax,%eax
801059f2:	78 15                	js     80105a09 <sys_link+0x30>
801059f4:	83 ec 08             	sub    $0x8,%esp
801059f7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801059fa:	50                   	push   %eax
801059fb:	6a 01                	push   $0x1
801059fd:	e8 93 fc ff ff       	call   80105695 <argstr>
80105a02:	83 c4 10             	add    $0x10,%esp
80105a05:	85 c0                	test   %eax,%eax
80105a07:	79 0a                	jns    80105a13 <sys_link+0x3a>
    return -1;
80105a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a0e:	e9 68 01 00 00       	jmp    80105b7b <sys_link+0x1a2>

  begin_op();
80105a13:	e8 5e db ff ff       	call   80103576 <begin_op>
  if((ip = namei(old)) == 0){
80105a18:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105a1b:	83 ec 0c             	sub    $0xc,%esp
80105a1e:	50                   	push   %eax
80105a1f:	e8 14 cb ff ff       	call   80102538 <namei>
80105a24:	83 c4 10             	add    $0x10,%esp
80105a27:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105a2a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105a2e:	75 0f                	jne    80105a3f <sys_link+0x66>
    end_op();
80105a30:	e8 cd db ff ff       	call   80103602 <end_op>
    return -1;
80105a35:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a3a:	e9 3c 01 00 00       	jmp    80105b7b <sys_link+0x1a2>
  }

  ilock(ip);
80105a3f:	83 ec 0c             	sub    $0xc,%esp
80105a42:	ff 75 f4             	push   -0xc(%ebp)
80105a45:	e8 3d bf ff ff       	call   80101987 <ilock>
80105a4a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105a4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a50:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105a54:	66 83 f8 01          	cmp    $0x1,%ax
80105a58:	75 1d                	jne    80105a77 <sys_link+0x9e>
    iunlockput(ip);
80105a5a:	83 ec 0c             	sub    $0xc,%esp
80105a5d:	ff 75 f4             	push   -0xc(%ebp)
80105a60:	e8 e2 c1 ff ff       	call   80101c47 <iunlockput>
80105a65:	83 c4 10             	add    $0x10,%esp
    end_op();
80105a68:	e8 95 db ff ff       	call   80103602 <end_op>
    return -1;
80105a6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a72:	e9 04 01 00 00       	jmp    80105b7b <sys_link+0x1a2>
  }

  ip->nlink++;
80105a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a7a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105a7e:	83 c0 01             	add    $0x1,%eax
80105a81:	89 c2                	mov    %eax,%edx
80105a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a86:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105a8a:	83 ec 0c             	sub    $0xc,%esp
80105a8d:	ff 75 f4             	push   -0xc(%ebp)
80105a90:	e8 18 bd ff ff       	call   801017ad <iupdate>
80105a95:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105a98:	83 ec 0c             	sub    $0xc,%esp
80105a9b:	ff 75 f4             	push   -0xc(%ebp)
80105a9e:	e8 42 c0 ff ff       	call   80101ae5 <iunlock>
80105aa3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105aa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105aa9:	83 ec 08             	sub    $0x8,%esp
80105aac:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105aaf:	52                   	push   %edx
80105ab0:	50                   	push   %eax
80105ab1:	e8 9e ca ff ff       	call   80102554 <nameiparent>
80105ab6:	83 c4 10             	add    $0x10,%esp
80105ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105abc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ac0:	74 71                	je     80105b33 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105ac2:	83 ec 0c             	sub    $0xc,%esp
80105ac5:	ff 75 f0             	push   -0x10(%ebp)
80105ac8:	e8 ba be ff ff       	call   80101987 <ilock>
80105acd:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105ad0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad3:	8b 10                	mov    (%eax),%edx
80105ad5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad8:	8b 00                	mov    (%eax),%eax
80105ada:	39 c2                	cmp    %eax,%edx
80105adc:	75 1d                	jne    80105afb <sys_link+0x122>
80105ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ae1:	8b 40 04             	mov    0x4(%eax),%eax
80105ae4:	83 ec 04             	sub    $0x4,%esp
80105ae7:	50                   	push   %eax
80105ae8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105aeb:	50                   	push   %eax
80105aec:	ff 75 f0             	push   -0x10(%ebp)
80105aef:	e8 ac c7 ff ff       	call   801022a0 <dirlink>
80105af4:	83 c4 10             	add    $0x10,%esp
80105af7:	85 c0                	test   %eax,%eax
80105af9:	79 10                	jns    80105b0b <sys_link+0x132>
    iunlockput(dp);
80105afb:	83 ec 0c             	sub    $0xc,%esp
80105afe:	ff 75 f0             	push   -0x10(%ebp)
80105b01:	e8 41 c1 ff ff       	call   80101c47 <iunlockput>
80105b06:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105b09:	eb 29                	jmp    80105b34 <sys_link+0x15b>
  }
  iunlockput(dp);
80105b0b:	83 ec 0c             	sub    $0xc,%esp
80105b0e:	ff 75 f0             	push   -0x10(%ebp)
80105b11:	e8 31 c1 ff ff       	call   80101c47 <iunlockput>
80105b16:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105b19:	83 ec 0c             	sub    $0xc,%esp
80105b1c:	ff 75 f4             	push   -0xc(%ebp)
80105b1f:	e8 33 c0 ff ff       	call   80101b57 <iput>
80105b24:	83 c4 10             	add    $0x10,%esp

  end_op();
80105b27:	e8 d6 da ff ff       	call   80103602 <end_op>

  return 0;
80105b2c:	b8 00 00 00 00       	mov    $0x0,%eax
80105b31:	eb 48                	jmp    80105b7b <sys_link+0x1a2>
    goto bad;
80105b33:	90                   	nop

bad:
  ilock(ip);
80105b34:	83 ec 0c             	sub    $0xc,%esp
80105b37:	ff 75 f4             	push   -0xc(%ebp)
80105b3a:	e8 48 be ff ff       	call   80101987 <ilock>
80105b3f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105b42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b45:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b49:	83 e8 01             	sub    $0x1,%eax
80105b4c:	89 c2                	mov    %eax,%edx
80105b4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b51:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105b55:	83 ec 0c             	sub    $0xc,%esp
80105b58:	ff 75 f4             	push   -0xc(%ebp)
80105b5b:	e8 4d bc ff ff       	call   801017ad <iupdate>
80105b60:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105b63:	83 ec 0c             	sub    $0xc,%esp
80105b66:	ff 75 f4             	push   -0xc(%ebp)
80105b69:	e8 d9 c0 ff ff       	call   80101c47 <iunlockput>
80105b6e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105b71:	e8 8c da ff ff       	call   80103602 <end_op>
  return -1;
80105b76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b7b:	c9                   	leave  
80105b7c:	c3                   	ret    

80105b7d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105b7d:	55                   	push   %ebp
80105b7e:	89 e5                	mov    %esp,%ebp
80105b80:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105b83:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105b8a:	eb 40                	jmp    80105bcc <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8f:	6a 10                	push   $0x10
80105b91:	50                   	push   %eax
80105b92:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105b95:	50                   	push   %eax
80105b96:	ff 75 08             	push   0x8(%ebp)
80105b99:	e8 52 c3 ff ff       	call   80101ef0 <readi>
80105b9e:	83 c4 10             	add    $0x10,%esp
80105ba1:	83 f8 10             	cmp    $0x10,%eax
80105ba4:	74 0d                	je     80105bb3 <isdirempty+0x36>
      panic("isdirempty: readi");
80105ba6:	83 ec 0c             	sub    $0xc,%esp
80105ba9:	68 01 8c 10 80       	push   $0x80108c01
80105bae:	e8 c8 a9 ff ff       	call   8010057b <panic>
    if(de.inum != 0)
80105bb3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105bb7:	66 85 c0             	test   %ax,%ax
80105bba:	74 07                	je     80105bc3 <isdirempty+0x46>
      return 0;
80105bbc:	b8 00 00 00 00       	mov    $0x0,%eax
80105bc1:	eb 1b                	jmp    80105bde <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105bc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc6:	83 c0 10             	add    $0x10,%eax
80105bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105bcc:	8b 45 08             	mov    0x8(%ebp),%eax
80105bcf:	8b 50 18             	mov    0x18(%eax),%edx
80105bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bd5:	39 c2                	cmp    %eax,%edx
80105bd7:	77 b3                	ja     80105b8c <isdirempty+0xf>
  }
  return 1;
80105bd9:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105bde:	c9                   	leave  
80105bdf:	c3                   	ret    

80105be0 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105be0:	55                   	push   %ebp
80105be1:	89 e5                	mov    %esp,%ebp
80105be3:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105be6:	83 ec 08             	sub    $0x8,%esp
80105be9:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105bec:	50                   	push   %eax
80105bed:	6a 00                	push   $0x0
80105bef:	e8 a1 fa ff ff       	call   80105695 <argstr>
80105bf4:	83 c4 10             	add    $0x10,%esp
80105bf7:	85 c0                	test   %eax,%eax
80105bf9:	79 0a                	jns    80105c05 <sys_unlink+0x25>
    return -1;
80105bfb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c00:	e9 bf 01 00 00       	jmp    80105dc4 <sys_unlink+0x1e4>

  begin_op();
80105c05:	e8 6c d9 ff ff       	call   80103576 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105c0a:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105c0d:	83 ec 08             	sub    $0x8,%esp
80105c10:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105c13:	52                   	push   %edx
80105c14:	50                   	push   %eax
80105c15:	e8 3a c9 ff ff       	call   80102554 <nameiparent>
80105c1a:	83 c4 10             	add    $0x10,%esp
80105c1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c24:	75 0f                	jne    80105c35 <sys_unlink+0x55>
    end_op();
80105c26:	e8 d7 d9 ff ff       	call   80103602 <end_op>
    return -1;
80105c2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c30:	e9 8f 01 00 00       	jmp    80105dc4 <sys_unlink+0x1e4>
  }

  ilock(dp);
80105c35:	83 ec 0c             	sub    $0xc,%esp
80105c38:	ff 75 f4             	push   -0xc(%ebp)
80105c3b:	e8 47 bd ff ff       	call   80101987 <ilock>
80105c40:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105c43:	83 ec 08             	sub    $0x8,%esp
80105c46:	68 13 8c 10 80       	push   $0x80108c13
80105c4b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c4e:	50                   	push   %eax
80105c4f:	e8 77 c5 ff ff       	call   801021cb <namecmp>
80105c54:	83 c4 10             	add    $0x10,%esp
80105c57:	85 c0                	test   %eax,%eax
80105c59:	0f 84 49 01 00 00    	je     80105da8 <sys_unlink+0x1c8>
80105c5f:	83 ec 08             	sub    $0x8,%esp
80105c62:	68 15 8c 10 80       	push   $0x80108c15
80105c67:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c6a:	50                   	push   %eax
80105c6b:	e8 5b c5 ff ff       	call   801021cb <namecmp>
80105c70:	83 c4 10             	add    $0x10,%esp
80105c73:	85 c0                	test   %eax,%eax
80105c75:	0f 84 2d 01 00 00    	je     80105da8 <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105c7b:	83 ec 04             	sub    $0x4,%esp
80105c7e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105c81:	50                   	push   %eax
80105c82:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105c85:	50                   	push   %eax
80105c86:	ff 75 f4             	push   -0xc(%ebp)
80105c89:	e8 58 c5 ff ff       	call   801021e6 <dirlookup>
80105c8e:	83 c4 10             	add    $0x10,%esp
80105c91:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105c94:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c98:	0f 84 0d 01 00 00    	je     80105dab <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105c9e:	83 ec 0c             	sub    $0xc,%esp
80105ca1:	ff 75 f0             	push   -0x10(%ebp)
80105ca4:	e8 de bc ff ff       	call   80101987 <ilock>
80105ca9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105caf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105cb3:	66 85 c0             	test   %ax,%ax
80105cb6:	7f 0d                	jg     80105cc5 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105cb8:	83 ec 0c             	sub    $0xc,%esp
80105cbb:	68 18 8c 10 80       	push   $0x80108c18
80105cc0:	e8 b6 a8 ff ff       	call   8010057b <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105cc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cc8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105ccc:	66 83 f8 01          	cmp    $0x1,%ax
80105cd0:	75 25                	jne    80105cf7 <sys_unlink+0x117>
80105cd2:	83 ec 0c             	sub    $0xc,%esp
80105cd5:	ff 75 f0             	push   -0x10(%ebp)
80105cd8:	e8 a0 fe ff ff       	call   80105b7d <isdirempty>
80105cdd:	83 c4 10             	add    $0x10,%esp
80105ce0:	85 c0                	test   %eax,%eax
80105ce2:	75 13                	jne    80105cf7 <sys_unlink+0x117>
    iunlockput(ip);
80105ce4:	83 ec 0c             	sub    $0xc,%esp
80105ce7:	ff 75 f0             	push   -0x10(%ebp)
80105cea:	e8 58 bf ff ff       	call   80101c47 <iunlockput>
80105cef:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105cf2:	e9 b5 00 00 00       	jmp    80105dac <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
80105cf7:	83 ec 04             	sub    $0x4,%esp
80105cfa:	6a 10                	push   $0x10
80105cfc:	6a 00                	push   $0x0
80105cfe:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d01:	50                   	push   %eax
80105d02:	e8 e5 f5 ff ff       	call   801052ec <memset>
80105d07:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105d0a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105d0d:	6a 10                	push   $0x10
80105d0f:	50                   	push   %eax
80105d10:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105d13:	50                   	push   %eax
80105d14:	ff 75 f4             	push   -0xc(%ebp)
80105d17:	e8 29 c3 ff ff       	call   80102045 <writei>
80105d1c:	83 c4 10             	add    $0x10,%esp
80105d1f:	83 f8 10             	cmp    $0x10,%eax
80105d22:	74 0d                	je     80105d31 <sys_unlink+0x151>
    panic("unlink: writei");
80105d24:	83 ec 0c             	sub    $0xc,%esp
80105d27:	68 2a 8c 10 80       	push   $0x80108c2a
80105d2c:	e8 4a a8 ff ff       	call   8010057b <panic>
  if(ip->type == T_DIR){
80105d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d34:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105d38:	66 83 f8 01          	cmp    $0x1,%ax
80105d3c:	75 21                	jne    80105d5f <sys_unlink+0x17f>
    dp->nlink--;
80105d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d41:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d45:	83 e8 01             	sub    $0x1,%eax
80105d48:	89 c2                	mov    %eax,%edx
80105d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105d51:	83 ec 0c             	sub    $0xc,%esp
80105d54:	ff 75 f4             	push   -0xc(%ebp)
80105d57:	e8 51 ba ff ff       	call   801017ad <iupdate>
80105d5c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105d5f:	83 ec 0c             	sub    $0xc,%esp
80105d62:	ff 75 f4             	push   -0xc(%ebp)
80105d65:	e8 dd be ff ff       	call   80101c47 <iunlockput>
80105d6a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d70:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105d74:	83 e8 01             	sub    $0x1,%eax
80105d77:	89 c2                	mov    %eax,%edx
80105d79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d7c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105d80:	83 ec 0c             	sub    $0xc,%esp
80105d83:	ff 75 f0             	push   -0x10(%ebp)
80105d86:	e8 22 ba ff ff       	call   801017ad <iupdate>
80105d8b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105d8e:	83 ec 0c             	sub    $0xc,%esp
80105d91:	ff 75 f0             	push   -0x10(%ebp)
80105d94:	e8 ae be ff ff       	call   80101c47 <iunlockput>
80105d99:	83 c4 10             	add    $0x10,%esp

  end_op();
80105d9c:	e8 61 d8 ff ff       	call   80103602 <end_op>

  return 0;
80105da1:	b8 00 00 00 00       	mov    $0x0,%eax
80105da6:	eb 1c                	jmp    80105dc4 <sys_unlink+0x1e4>
    goto bad;
80105da8:	90                   	nop
80105da9:	eb 01                	jmp    80105dac <sys_unlink+0x1cc>
    goto bad;
80105dab:	90                   	nop

bad:
  iunlockput(dp);
80105dac:	83 ec 0c             	sub    $0xc,%esp
80105daf:	ff 75 f4             	push   -0xc(%ebp)
80105db2:	e8 90 be ff ff       	call   80101c47 <iunlockput>
80105db7:	83 c4 10             	add    $0x10,%esp
  end_op();
80105dba:	e8 43 d8 ff ff       	call   80103602 <end_op>
  return -1;
80105dbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105dc4:	c9                   	leave  
80105dc5:	c3                   	ret    

80105dc6 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105dc6:	55                   	push   %ebp
80105dc7:	89 e5                	mov    %esp,%ebp
80105dc9:	83 ec 38             	sub    $0x38,%esp
80105dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105dcf:	8b 55 10             	mov    0x10(%ebp),%edx
80105dd2:	8b 45 14             	mov    0x14(%ebp),%eax
80105dd5:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105dd9:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105ddd:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105de1:	83 ec 08             	sub    $0x8,%esp
80105de4:	8d 45 de             	lea    -0x22(%ebp),%eax
80105de7:	50                   	push   %eax
80105de8:	ff 75 08             	push   0x8(%ebp)
80105deb:	e8 64 c7 ff ff       	call   80102554 <nameiparent>
80105df0:	83 c4 10             	add    $0x10,%esp
80105df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105df6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105dfa:	75 0a                	jne    80105e06 <create+0x40>
    return 0;
80105dfc:	b8 00 00 00 00       	mov    $0x0,%eax
80105e01:	e9 90 01 00 00       	jmp    80105f96 <create+0x1d0>
  ilock(dp);
80105e06:	83 ec 0c             	sub    $0xc,%esp
80105e09:	ff 75 f4             	push   -0xc(%ebp)
80105e0c:	e8 76 bb ff ff       	call   80101987 <ilock>
80105e11:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105e14:	83 ec 04             	sub    $0x4,%esp
80105e17:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e1a:	50                   	push   %eax
80105e1b:	8d 45 de             	lea    -0x22(%ebp),%eax
80105e1e:	50                   	push   %eax
80105e1f:	ff 75 f4             	push   -0xc(%ebp)
80105e22:	e8 bf c3 ff ff       	call   801021e6 <dirlookup>
80105e27:	83 c4 10             	add    $0x10,%esp
80105e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e2d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105e31:	74 50                	je     80105e83 <create+0xbd>
    iunlockput(dp);
80105e33:	83 ec 0c             	sub    $0xc,%esp
80105e36:	ff 75 f4             	push   -0xc(%ebp)
80105e39:	e8 09 be ff ff       	call   80101c47 <iunlockput>
80105e3e:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105e41:	83 ec 0c             	sub    $0xc,%esp
80105e44:	ff 75 f0             	push   -0x10(%ebp)
80105e47:	e8 3b bb ff ff       	call   80101987 <ilock>
80105e4c:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105e4f:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105e54:	75 15                	jne    80105e6b <create+0xa5>
80105e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e59:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e5d:	66 83 f8 02          	cmp    $0x2,%ax
80105e61:	75 08                	jne    80105e6b <create+0xa5>
      return ip;
80105e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e66:	e9 2b 01 00 00       	jmp    80105f96 <create+0x1d0>
    iunlockput(ip);
80105e6b:	83 ec 0c             	sub    $0xc,%esp
80105e6e:	ff 75 f0             	push   -0x10(%ebp)
80105e71:	e8 d1 bd ff ff       	call   80101c47 <iunlockput>
80105e76:	83 c4 10             	add    $0x10,%esp
    return 0;
80105e79:	b8 00 00 00 00       	mov    $0x0,%eax
80105e7e:	e9 13 01 00 00       	jmp    80105f96 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105e83:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105e87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8a:	8b 00                	mov    (%eax),%eax
80105e8c:	83 ec 08             	sub    $0x8,%esp
80105e8f:	52                   	push   %edx
80105e90:	50                   	push   %eax
80105e91:	e8 40 b8 ff ff       	call   801016d6 <ialloc>
80105e96:	83 c4 10             	add    $0x10,%esp
80105e99:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105e9c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ea0:	75 0d                	jne    80105eaf <create+0xe9>
    panic("create: ialloc");
80105ea2:	83 ec 0c             	sub    $0xc,%esp
80105ea5:	68 39 8c 10 80       	push   $0x80108c39
80105eaa:	e8 cc a6 ff ff       	call   8010057b <panic>

  ilock(ip);
80105eaf:	83 ec 0c             	sub    $0xc,%esp
80105eb2:	ff 75 f0             	push   -0x10(%ebp)
80105eb5:	e8 cd ba ff ff       	call   80101987 <ilock>
80105eba:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ec0:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105ec4:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecb:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105ecf:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed6:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105edc:	83 ec 0c             	sub    $0xc,%esp
80105edf:	ff 75 f0             	push   -0x10(%ebp)
80105ee2:	e8 c6 b8 ff ff       	call   801017ad <iupdate>
80105ee7:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80105eea:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105eef:	75 6a                	jne    80105f5b <create+0x195>
    dp->nlink++;  // for ".."
80105ef1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef4:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105ef8:	83 c0 01             	add    $0x1,%eax
80105efb:	89 c2                	mov    %eax,%edx
80105efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f00:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105f04:	83 ec 0c             	sub    $0xc,%esp
80105f07:	ff 75 f4             	push   -0xc(%ebp)
80105f0a:	e8 9e b8 ff ff       	call   801017ad <iupdate>
80105f0f:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80105f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f15:	8b 40 04             	mov    0x4(%eax),%eax
80105f18:	83 ec 04             	sub    $0x4,%esp
80105f1b:	50                   	push   %eax
80105f1c:	68 13 8c 10 80       	push   $0x80108c13
80105f21:	ff 75 f0             	push   -0x10(%ebp)
80105f24:	e8 77 c3 ff ff       	call   801022a0 <dirlink>
80105f29:	83 c4 10             	add    $0x10,%esp
80105f2c:	85 c0                	test   %eax,%eax
80105f2e:	78 1e                	js     80105f4e <create+0x188>
80105f30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f33:	8b 40 04             	mov    0x4(%eax),%eax
80105f36:	83 ec 04             	sub    $0x4,%esp
80105f39:	50                   	push   %eax
80105f3a:	68 15 8c 10 80       	push   $0x80108c15
80105f3f:	ff 75 f0             	push   -0x10(%ebp)
80105f42:	e8 59 c3 ff ff       	call   801022a0 <dirlink>
80105f47:	83 c4 10             	add    $0x10,%esp
80105f4a:	85 c0                	test   %eax,%eax
80105f4c:	79 0d                	jns    80105f5b <create+0x195>
      panic("create dots");
80105f4e:	83 ec 0c             	sub    $0xc,%esp
80105f51:	68 48 8c 10 80       	push   $0x80108c48
80105f56:	e8 20 a6 ff ff       	call   8010057b <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5e:	8b 40 04             	mov    0x4(%eax),%eax
80105f61:	83 ec 04             	sub    $0x4,%esp
80105f64:	50                   	push   %eax
80105f65:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f68:	50                   	push   %eax
80105f69:	ff 75 f4             	push   -0xc(%ebp)
80105f6c:	e8 2f c3 ff ff       	call   801022a0 <dirlink>
80105f71:	83 c4 10             	add    $0x10,%esp
80105f74:	85 c0                	test   %eax,%eax
80105f76:	79 0d                	jns    80105f85 <create+0x1bf>
    panic("create: dirlink");
80105f78:	83 ec 0c             	sub    $0xc,%esp
80105f7b:	68 54 8c 10 80       	push   $0x80108c54
80105f80:	e8 f6 a5 ff ff       	call   8010057b <panic>

  iunlockput(dp);
80105f85:	83 ec 0c             	sub    $0xc,%esp
80105f88:	ff 75 f4             	push   -0xc(%ebp)
80105f8b:	e8 b7 bc ff ff       	call   80101c47 <iunlockput>
80105f90:	83 c4 10             	add    $0x10,%esp

  return ip;
80105f93:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80105f96:	c9                   	leave  
80105f97:	c3                   	ret    

80105f98 <sys_open>:

int
sys_open(void)
{
80105f98:	55                   	push   %ebp
80105f99:	89 e5                	mov    %esp,%ebp
80105f9b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105f9e:	83 ec 08             	sub    $0x8,%esp
80105fa1:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105fa4:	50                   	push   %eax
80105fa5:	6a 00                	push   $0x0
80105fa7:	e8 e9 f6 ff ff       	call   80105695 <argstr>
80105fac:	83 c4 10             	add    $0x10,%esp
80105faf:	85 c0                	test   %eax,%eax
80105fb1:	78 15                	js     80105fc8 <sys_open+0x30>
80105fb3:	83 ec 08             	sub    $0x8,%esp
80105fb6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fb9:	50                   	push   %eax
80105fba:	6a 01                	push   $0x1
80105fbc:	e8 4f f6 ff ff       	call   80105610 <argint>
80105fc1:	83 c4 10             	add    $0x10,%esp
80105fc4:	85 c0                	test   %eax,%eax
80105fc6:	79 0a                	jns    80105fd2 <sys_open+0x3a>
    return -1;
80105fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fcd:	e9 61 01 00 00       	jmp    80106133 <sys_open+0x19b>

  begin_op();
80105fd2:	e8 9f d5 ff ff       	call   80103576 <begin_op>

  if(omode & O_CREATE){
80105fd7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fda:	25 00 02 00 00       	and    $0x200,%eax
80105fdf:	85 c0                	test   %eax,%eax
80105fe1:	74 2a                	je     8010600d <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105fe3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105fe6:	6a 00                	push   $0x0
80105fe8:	6a 00                	push   $0x0
80105fea:	6a 02                	push   $0x2
80105fec:	50                   	push   %eax
80105fed:	e8 d4 fd ff ff       	call   80105dc6 <create>
80105ff2:	83 c4 10             	add    $0x10,%esp
80105ff5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80105ff8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ffc:	75 75                	jne    80106073 <sys_open+0xdb>
      end_op();
80105ffe:	e8 ff d5 ff ff       	call   80103602 <end_op>
      return -1;
80106003:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106008:	e9 26 01 00 00       	jmp    80106133 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010600d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106010:	83 ec 0c             	sub    $0xc,%esp
80106013:	50                   	push   %eax
80106014:	e8 1f c5 ff ff       	call   80102538 <namei>
80106019:	83 c4 10             	add    $0x10,%esp
8010601c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010601f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106023:	75 0f                	jne    80106034 <sys_open+0x9c>
      end_op();
80106025:	e8 d8 d5 ff ff       	call   80103602 <end_op>
      return -1;
8010602a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602f:	e9 ff 00 00 00       	jmp    80106133 <sys_open+0x19b>
    }
    ilock(ip);
80106034:	83 ec 0c             	sub    $0xc,%esp
80106037:	ff 75 f4             	push   -0xc(%ebp)
8010603a:	e8 48 b9 ff ff       	call   80101987 <ilock>
8010603f:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
80106042:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106045:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106049:	66 83 f8 01          	cmp    $0x1,%ax
8010604d:	75 24                	jne    80106073 <sys_open+0xdb>
8010604f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106052:	85 c0                	test   %eax,%eax
80106054:	74 1d                	je     80106073 <sys_open+0xdb>
      iunlockput(ip);
80106056:	83 ec 0c             	sub    $0xc,%esp
80106059:	ff 75 f4             	push   -0xc(%ebp)
8010605c:	e8 e6 bb ff ff       	call   80101c47 <iunlockput>
80106061:	83 c4 10             	add    $0x10,%esp
      end_op();
80106064:	e8 99 d5 ff ff       	call   80103602 <end_op>
      return -1;
80106069:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606e:	e9 c0 00 00 00       	jmp    80106133 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106073:	e8 48 af ff ff       	call   80100fc0 <filealloc>
80106078:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010607b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010607f:	74 17                	je     80106098 <sys_open+0x100>
80106081:	83 ec 0c             	sub    $0xc,%esp
80106084:	ff 75 f0             	push   -0x10(%ebp)
80106087:	e8 34 f7 ff ff       	call   801057c0 <fdalloc>
8010608c:	83 c4 10             	add    $0x10,%esp
8010608f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106092:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106096:	79 2e                	jns    801060c6 <sys_open+0x12e>
    if(f)
80106098:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010609c:	74 0e                	je     801060ac <sys_open+0x114>
      fileclose(f);
8010609e:	83 ec 0c             	sub    $0xc,%esp
801060a1:	ff 75 f0             	push   -0x10(%ebp)
801060a4:	e8 d5 af ff ff       	call   8010107e <fileclose>
801060a9:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801060ac:	83 ec 0c             	sub    $0xc,%esp
801060af:	ff 75 f4             	push   -0xc(%ebp)
801060b2:	e8 90 bb ff ff       	call   80101c47 <iunlockput>
801060b7:	83 c4 10             	add    $0x10,%esp
    end_op();
801060ba:	e8 43 d5 ff ff       	call   80103602 <end_op>
    return -1;
801060bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c4:	eb 6d                	jmp    80106133 <sys_open+0x19b>
  }
  iunlock(ip);
801060c6:	83 ec 0c             	sub    $0xc,%esp
801060c9:	ff 75 f4             	push   -0xc(%ebp)
801060cc:	e8 14 ba ff ff       	call   80101ae5 <iunlock>
801060d1:	83 c4 10             	add    $0x10,%esp
  end_op();
801060d4:	e8 29 d5 ff ff       	call   80103602 <end_op>

  f->type = FD_INODE;
801060d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060dc:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801060e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060e8:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801060eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ee:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801060f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f8:	83 e0 01             	and    $0x1,%eax
801060fb:	85 c0                	test   %eax,%eax
801060fd:	0f 94 c0             	sete   %al
80106100:	89 c2                	mov    %eax,%edx
80106102:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106105:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010610b:	83 e0 01             	and    $0x1,%eax
8010610e:	85 c0                	test   %eax,%eax
80106110:	75 0a                	jne    8010611c <sys_open+0x184>
80106112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106115:	83 e0 02             	and    $0x2,%eax
80106118:	85 c0                	test   %eax,%eax
8010611a:	74 07                	je     80106123 <sys_open+0x18b>
8010611c:	b8 01 00 00 00       	mov    $0x1,%eax
80106121:	eb 05                	jmp    80106128 <sys_open+0x190>
80106123:	b8 00 00 00 00       	mov    $0x0,%eax
80106128:	89 c2                	mov    %eax,%edx
8010612a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010612d:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106130:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106133:	c9                   	leave  
80106134:	c3                   	ret    

80106135 <sys_mkdir>:

int
sys_mkdir(void)
{
80106135:	55                   	push   %ebp
80106136:	89 e5                	mov    %esp,%ebp
80106138:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010613b:	e8 36 d4 ff ff       	call   80103576 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106140:	83 ec 08             	sub    $0x8,%esp
80106143:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106146:	50                   	push   %eax
80106147:	6a 00                	push   $0x0
80106149:	e8 47 f5 ff ff       	call   80105695 <argstr>
8010614e:	83 c4 10             	add    $0x10,%esp
80106151:	85 c0                	test   %eax,%eax
80106153:	78 1b                	js     80106170 <sys_mkdir+0x3b>
80106155:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106158:	6a 00                	push   $0x0
8010615a:	6a 00                	push   $0x0
8010615c:	6a 01                	push   $0x1
8010615e:	50                   	push   %eax
8010615f:	e8 62 fc ff ff       	call   80105dc6 <create>
80106164:	83 c4 10             	add    $0x10,%esp
80106167:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010616a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010616e:	75 0c                	jne    8010617c <sys_mkdir+0x47>
    end_op();
80106170:	e8 8d d4 ff ff       	call   80103602 <end_op>
    return -1;
80106175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617a:	eb 18                	jmp    80106194 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
8010617c:	83 ec 0c             	sub    $0xc,%esp
8010617f:	ff 75 f4             	push   -0xc(%ebp)
80106182:	e8 c0 ba ff ff       	call   80101c47 <iunlockput>
80106187:	83 c4 10             	add    $0x10,%esp
  end_op();
8010618a:	e8 73 d4 ff ff       	call   80103602 <end_op>
  return 0;
8010618f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106194:	c9                   	leave  
80106195:	c3                   	ret    

80106196 <sys_mknod>:

int
sys_mknod(void)
{
80106196:	55                   	push   %ebp
80106197:	89 e5                	mov    %esp,%ebp
80106199:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
8010619c:	e8 d5 d3 ff ff       	call   80103576 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801061a1:	83 ec 08             	sub    $0x8,%esp
801061a4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061a7:	50                   	push   %eax
801061a8:	6a 00                	push   $0x0
801061aa:	e8 e6 f4 ff ff       	call   80105695 <argstr>
801061af:	83 c4 10             	add    $0x10,%esp
801061b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061b9:	78 4f                	js     8010620a <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801061bb:	83 ec 08             	sub    $0x8,%esp
801061be:	8d 45 e8             	lea    -0x18(%ebp),%eax
801061c1:	50                   	push   %eax
801061c2:	6a 01                	push   $0x1
801061c4:	e8 47 f4 ff ff       	call   80105610 <argint>
801061c9:	83 c4 10             	add    $0x10,%esp
  if((len=argstr(0, &path)) < 0 ||
801061cc:	85 c0                	test   %eax,%eax
801061ce:	78 3a                	js     8010620a <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
801061d0:	83 ec 08             	sub    $0x8,%esp
801061d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801061d6:	50                   	push   %eax
801061d7:	6a 02                	push   $0x2
801061d9:	e8 32 f4 ff ff       	call   80105610 <argint>
801061de:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
801061e1:	85 c0                	test   %eax,%eax
801061e3:	78 25                	js     8010620a <sys_mknod+0x74>
     (ip = create(path, T_DEV, major, minor)) == 0){
801061e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061e8:	0f bf c8             	movswl %ax,%ecx
801061eb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801061ee:	0f bf d0             	movswl %ax,%edx
801061f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801061f4:	51                   	push   %ecx
801061f5:	52                   	push   %edx
801061f6:	6a 03                	push   $0x3
801061f8:	50                   	push   %eax
801061f9:	e8 c8 fb ff ff       	call   80105dc6 <create>
801061fe:	83 c4 10             	add    $0x10,%esp
80106201:	89 45 f0             	mov    %eax,-0x10(%ebp)
     argint(2, &minor) < 0 ||
80106204:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106208:	75 0c                	jne    80106216 <sys_mknod+0x80>
    end_op();
8010620a:	e8 f3 d3 ff ff       	call   80103602 <end_op>
    return -1;
8010620f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106214:	eb 18                	jmp    8010622e <sys_mknod+0x98>
  }
  iunlockput(ip);
80106216:	83 ec 0c             	sub    $0xc,%esp
80106219:	ff 75 f0             	push   -0x10(%ebp)
8010621c:	e8 26 ba ff ff       	call   80101c47 <iunlockput>
80106221:	83 c4 10             	add    $0x10,%esp
  end_op();
80106224:	e8 d9 d3 ff ff       	call   80103602 <end_op>
  return 0;
80106229:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010622e:	c9                   	leave  
8010622f:	c3                   	ret    

80106230 <sys_chdir>:

int
sys_chdir(void)
{
80106230:	55                   	push   %ebp
80106231:	89 e5                	mov    %esp,%ebp
80106233:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106236:	e8 3b d3 ff ff       	call   80103576 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
8010623b:	83 ec 08             	sub    $0x8,%esp
8010623e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106241:	50                   	push   %eax
80106242:	6a 00                	push   $0x0
80106244:	e8 4c f4 ff ff       	call   80105695 <argstr>
80106249:	83 c4 10             	add    $0x10,%esp
8010624c:	85 c0                	test   %eax,%eax
8010624e:	78 18                	js     80106268 <sys_chdir+0x38>
80106250:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106253:	83 ec 0c             	sub    $0xc,%esp
80106256:	50                   	push   %eax
80106257:	e8 dc c2 ff ff       	call   80102538 <namei>
8010625c:	83 c4 10             	add    $0x10,%esp
8010625f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106262:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106266:	75 0c                	jne    80106274 <sys_chdir+0x44>
    end_op();
80106268:	e8 95 d3 ff ff       	call   80103602 <end_op>
    return -1;
8010626d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106272:	eb 6e                	jmp    801062e2 <sys_chdir+0xb2>
  }
  ilock(ip);
80106274:	83 ec 0c             	sub    $0xc,%esp
80106277:	ff 75 f4             	push   -0xc(%ebp)
8010627a:	e8 08 b7 ff ff       	call   80101987 <ilock>
8010627f:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
80106282:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106285:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106289:	66 83 f8 01          	cmp    $0x1,%ax
8010628d:	74 1a                	je     801062a9 <sys_chdir+0x79>
    iunlockput(ip);
8010628f:	83 ec 0c             	sub    $0xc,%esp
80106292:	ff 75 f4             	push   -0xc(%ebp)
80106295:	e8 ad b9 ff ff       	call   80101c47 <iunlockput>
8010629a:	83 c4 10             	add    $0x10,%esp
    end_op();
8010629d:	e8 60 d3 ff ff       	call   80103602 <end_op>
    return -1;
801062a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062a7:	eb 39                	jmp    801062e2 <sys_chdir+0xb2>
  }
  iunlock(ip);
801062a9:	83 ec 0c             	sub    $0xc,%esp
801062ac:	ff 75 f4             	push   -0xc(%ebp)
801062af:	e8 31 b8 ff ff       	call   80101ae5 <iunlock>
801062b4:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801062b7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062bd:	8b 40 68             	mov    0x68(%eax),%eax
801062c0:	83 ec 0c             	sub    $0xc,%esp
801062c3:	50                   	push   %eax
801062c4:	e8 8e b8 ff ff       	call   80101b57 <iput>
801062c9:	83 c4 10             	add    $0x10,%esp
  end_op();
801062cc:	e8 31 d3 ff ff       	call   80103602 <end_op>
  proc->cwd = ip;
801062d1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801062d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062da:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801062dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062e2:	c9                   	leave  
801062e3:	c3                   	ret    

801062e4 <sys_exec>:

int
sys_exec(void)
{
801062e4:	55                   	push   %ebp
801062e5:	89 e5                	mov    %esp,%ebp
801062e7:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801062ed:	83 ec 08             	sub    $0x8,%esp
801062f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062f3:	50                   	push   %eax
801062f4:	6a 00                	push   $0x0
801062f6:	e8 9a f3 ff ff       	call   80105695 <argstr>
801062fb:	83 c4 10             	add    $0x10,%esp
801062fe:	85 c0                	test   %eax,%eax
80106300:	78 18                	js     8010631a <sys_exec+0x36>
80106302:	83 ec 08             	sub    $0x8,%esp
80106305:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
8010630b:	50                   	push   %eax
8010630c:	6a 01                	push   $0x1
8010630e:	e8 fd f2 ff ff       	call   80105610 <argint>
80106313:	83 c4 10             	add    $0x10,%esp
80106316:	85 c0                	test   %eax,%eax
80106318:	79 0a                	jns    80106324 <sys_exec+0x40>
    return -1;
8010631a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010631f:	e9 c6 00 00 00       	jmp    801063ea <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106324:	83 ec 04             	sub    $0x4,%esp
80106327:	68 80 00 00 00       	push   $0x80
8010632c:	6a 00                	push   $0x0
8010632e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106334:	50                   	push   %eax
80106335:	e8 b2 ef ff ff       	call   801052ec <memset>
8010633a:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010633d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106347:	83 f8 1f             	cmp    $0x1f,%eax
8010634a:	76 0a                	jbe    80106356 <sys_exec+0x72>
      return -1;
8010634c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106351:	e9 94 00 00 00       	jmp    801063ea <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106359:	c1 e0 02             	shl    $0x2,%eax
8010635c:	89 c2                	mov    %eax,%edx
8010635e:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106364:	01 c2                	add    %eax,%edx
80106366:	83 ec 08             	sub    $0x8,%esp
80106369:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010636f:	50                   	push   %eax
80106370:	52                   	push   %edx
80106371:	e8 00 f2 ff ff       	call   80105576 <fetchint>
80106376:	83 c4 10             	add    $0x10,%esp
80106379:	85 c0                	test   %eax,%eax
8010637b:	79 07                	jns    80106384 <sys_exec+0xa0>
      return -1;
8010637d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106382:	eb 66                	jmp    801063ea <sys_exec+0x106>
    if(uarg == 0){
80106384:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010638a:	85 c0                	test   %eax,%eax
8010638c:	75 27                	jne    801063b5 <sys_exec+0xd1>
      argv[i] = 0;
8010638e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106391:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106398:	00 00 00 00 
      break;
8010639c:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
8010639d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a0:	83 ec 08             	sub    $0x8,%esp
801063a3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063a9:	52                   	push   %edx
801063aa:	50                   	push   %eax
801063ab:	e8 ee a7 ff ff       	call   80100b9e <exec>
801063b0:	83 c4 10             	add    $0x10,%esp
801063b3:	eb 35                	jmp    801063ea <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
801063b5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801063bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063be:	c1 e0 02             	shl    $0x2,%eax
801063c1:	01 c2                	add    %eax,%edx
801063c3:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801063c9:	83 ec 08             	sub    $0x8,%esp
801063cc:	52                   	push   %edx
801063cd:	50                   	push   %eax
801063ce:	e8 dd f1 ff ff       	call   801055b0 <fetchstr>
801063d3:	83 c4 10             	add    $0x10,%esp
801063d6:	85 c0                	test   %eax,%eax
801063d8:	79 07                	jns    801063e1 <sys_exec+0xfd>
      return -1;
801063da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063df:	eb 09                	jmp    801063ea <sys_exec+0x106>
  for(i=0;; i++){
801063e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
801063e5:	e9 5a ff ff ff       	jmp    80106344 <sys_exec+0x60>
}
801063ea:	c9                   	leave  
801063eb:	c3                   	ret    

801063ec <sys_pipe>:

int
sys_pipe(void)
{
801063ec:	55                   	push   %ebp
801063ed:	89 e5                	mov    %esp,%ebp
801063ef:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801063f2:	83 ec 04             	sub    $0x4,%esp
801063f5:	6a 08                	push   $0x8
801063f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801063fa:	50                   	push   %eax
801063fb:	6a 00                	push   $0x0
801063fd:	e8 36 f2 ff ff       	call   80105638 <argptr>
80106402:	83 c4 10             	add    $0x10,%esp
80106405:	85 c0                	test   %eax,%eax
80106407:	79 0a                	jns    80106413 <sys_pipe+0x27>
    return -1;
80106409:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010640e:	e9 af 00 00 00       	jmp    801064c2 <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106413:	83 ec 08             	sub    $0x8,%esp
80106416:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106419:	50                   	push   %eax
8010641a:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010641d:	50                   	push   %eax
8010641e:	e8 65 dc ff ff       	call   80104088 <pipealloc>
80106423:	83 c4 10             	add    $0x10,%esp
80106426:	85 c0                	test   %eax,%eax
80106428:	79 0a                	jns    80106434 <sys_pipe+0x48>
    return -1;
8010642a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642f:	e9 8e 00 00 00       	jmp    801064c2 <sys_pipe+0xd6>
  fd0 = -1;
80106434:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010643b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010643e:	83 ec 0c             	sub    $0xc,%esp
80106441:	50                   	push   %eax
80106442:	e8 79 f3 ff ff       	call   801057c0 <fdalloc>
80106447:	83 c4 10             	add    $0x10,%esp
8010644a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010644d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106451:	78 18                	js     8010646b <sys_pipe+0x7f>
80106453:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106456:	83 ec 0c             	sub    $0xc,%esp
80106459:	50                   	push   %eax
8010645a:	e8 61 f3 ff ff       	call   801057c0 <fdalloc>
8010645f:	83 c4 10             	add    $0x10,%esp
80106462:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106465:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106469:	79 3f                	jns    801064aa <sys_pipe+0xbe>
    if(fd0 >= 0)
8010646b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010646f:	78 14                	js     80106485 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106471:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106477:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010647a:	83 c2 08             	add    $0x8,%edx
8010647d:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106484:	00 
    fileclose(rf);
80106485:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106488:	83 ec 0c             	sub    $0xc,%esp
8010648b:	50                   	push   %eax
8010648c:	e8 ed ab ff ff       	call   8010107e <fileclose>
80106491:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106494:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106497:	83 ec 0c             	sub    $0xc,%esp
8010649a:	50                   	push   %eax
8010649b:	e8 de ab ff ff       	call   8010107e <fileclose>
801064a0:	83 c4 10             	add    $0x10,%esp
    return -1;
801064a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064a8:	eb 18                	jmp    801064c2 <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801064aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064b0:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801064b2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801064b5:	8d 50 04             	lea    0x4(%eax),%edx
801064b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bb:	89 02                	mov    %eax,(%edx)
  return 0;
801064bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064c2:	c9                   	leave  
801064c3:	c3                   	ret    

801064c4 <sys_fork>:
#include "proc.h"

extern int free_frame_cnt; // CS3320 for project3
int
sys_fork(void)
{
801064c4:	55                   	push   %ebp
801064c5:	89 e5                	mov    %esp,%ebp
801064c7:	83 ec 08             	sub    $0x8,%esp
  return fork();
801064ca:	e8 d0 e2 ff ff       	call   8010479f <fork>
}
801064cf:	c9                   	leave  
801064d0:	c3                   	ret    

801064d1 <sys_exit>:

int
sys_exit(void)
{
801064d1:	55                   	push   %ebp
801064d2:	89 e5                	mov    %esp,%ebp
801064d4:	83 ec 08             	sub    $0x8,%esp
  exit();
801064d7:	e8 50 e4 ff ff       	call   8010492c <exit>
  return 0;  // not reached
801064dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064e1:	c9                   	leave  
801064e2:	c3                   	ret    

801064e3 <sys_wait>:

int
sys_wait(void)
{
801064e3:	55                   	push   %ebp
801064e4:	89 e5                	mov    %esp,%ebp
801064e6:	83 ec 08             	sub    $0x8,%esp
  return wait();
801064e9:	e8 76 e5 ff ff       	call   80104a64 <wait>
}
801064ee:	c9                   	leave  
801064ef:	c3                   	ret    

801064f0 <sys_kill>:

int
sys_kill(void)
{
801064f0:	55                   	push   %ebp
801064f1:	89 e5                	mov    %esp,%ebp
801064f3:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
801064f6:	83 ec 08             	sub    $0x8,%esp
801064f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801064fc:	50                   	push   %eax
801064fd:	6a 00                	push   $0x0
801064ff:	e8 0c f1 ff ff       	call   80105610 <argint>
80106504:	83 c4 10             	add    $0x10,%esp
80106507:	85 c0                	test   %eax,%eax
80106509:	79 07                	jns    80106512 <sys_kill+0x22>
    return -1;
8010650b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106510:	eb 0f                	jmp    80106521 <sys_kill+0x31>
  return kill(pid);
80106512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106515:	83 ec 0c             	sub    $0xc,%esp
80106518:	50                   	push   %eax
80106519:	e8 93 e9 ff ff       	call   80104eb1 <kill>
8010651e:	83 c4 10             	add    $0x10,%esp
}
80106521:	c9                   	leave  
80106522:	c3                   	ret    

80106523 <sys_getpid>:

int
sys_getpid(void)
{
80106523:	55                   	push   %ebp
80106524:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106526:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010652c:	8b 40 10             	mov    0x10(%eax),%eax
}
8010652f:	5d                   	pop    %ebp
80106530:	c3                   	ret    

80106531 <sys_sbrk>:

int
sys_sbrk(void)
{
80106531:	55                   	push   %ebp
80106532:	89 e5                	mov    %esp,%ebp
80106534:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106537:	83 ec 08             	sub    $0x8,%esp
8010653a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010653d:	50                   	push   %eax
8010653e:	6a 00                	push   $0x0
80106540:	e8 cb f0 ff ff       	call   80105610 <argint>
80106545:	83 c4 10             	add    $0x10,%esp
80106548:	85 c0                	test   %eax,%eax
8010654a:	79 07                	jns    80106553 <sys_sbrk+0x22>
    return -1;
8010654c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106551:	eb 28                	jmp    8010657b <sys_sbrk+0x4a>
  addr = proc->sz;
80106553:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106559:	8b 00                	mov    (%eax),%eax
8010655b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
8010655e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106561:	83 ec 0c             	sub    $0xc,%esp
80106564:	50                   	push   %eax
80106565:	e8 72 e1 ff ff       	call   801046dc <growproc>
8010656a:	83 c4 10             	add    $0x10,%esp
8010656d:	85 c0                	test   %eax,%eax
8010656f:	79 07                	jns    80106578 <sys_sbrk+0x47>
    return -1;
80106571:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106576:	eb 03                	jmp    8010657b <sys_sbrk+0x4a>
  return addr;
80106578:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010657b:	c9                   	leave  
8010657c:	c3                   	ret    

8010657d <sys_sleep>:

int
sys_sleep(void)
{
8010657d:	55                   	push   %ebp
8010657e:	89 e5                	mov    %esp,%ebp
80106580:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
80106583:	83 ec 08             	sub    $0x8,%esp
80106586:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106589:	50                   	push   %eax
8010658a:	6a 00                	push   $0x0
8010658c:	e8 7f f0 ff ff       	call   80105610 <argint>
80106591:	83 c4 10             	add    $0x10,%esp
80106594:	85 c0                	test   %eax,%eax
80106596:	79 07                	jns    8010659f <sys_sleep+0x22>
    return -1;
80106598:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659d:	eb 77                	jmp    80106616 <sys_sleep+0x99>
  acquire(&tickslock);
8010659f:	83 ec 0c             	sub    $0xc,%esp
801065a2:	68 c0 40 11 80       	push   $0x801140c0
801065a7:	e8 dd ea ff ff       	call   80105089 <acquire>
801065ac:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
801065af:	a1 f4 40 11 80       	mov    0x801140f4,%eax
801065b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
801065b7:	eb 39                	jmp    801065f2 <sys_sleep+0x75>
    if(proc->killed){
801065b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801065bf:	8b 40 24             	mov    0x24(%eax),%eax
801065c2:	85 c0                	test   %eax,%eax
801065c4:	74 17                	je     801065dd <sys_sleep+0x60>
      release(&tickslock);
801065c6:	83 ec 0c             	sub    $0xc,%esp
801065c9:	68 c0 40 11 80       	push   $0x801140c0
801065ce:	e8 1d eb ff ff       	call   801050f0 <release>
801065d3:	83 c4 10             	add    $0x10,%esp
      return -1;
801065d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065db:	eb 39                	jmp    80106616 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
801065dd:	83 ec 08             	sub    $0x8,%esp
801065e0:	68 c0 40 11 80       	push   $0x801140c0
801065e5:	68 f4 40 11 80       	push   $0x801140f4
801065ea:	e8 9f e7 ff ff       	call   80104d8e <sleep>
801065ef:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
801065f2:	a1 f4 40 11 80       	mov    0x801140f4,%eax
801065f7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801065fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
801065fd:	39 d0                	cmp    %edx,%eax
801065ff:	72 b8                	jb     801065b9 <sys_sleep+0x3c>
  }
  release(&tickslock);
80106601:	83 ec 0c             	sub    $0xc,%esp
80106604:	68 c0 40 11 80       	push   $0x801140c0
80106609:	e8 e2 ea ff ff       	call   801050f0 <release>
8010660e:	83 c4 10             	add    $0x10,%esp
  return 0;
80106611:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106616:	c9                   	leave  
80106617:	c3                   	ret    

80106618 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106618:	55                   	push   %ebp
80106619:	89 e5                	mov    %esp,%ebp
8010661b:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
8010661e:	83 ec 0c             	sub    $0xc,%esp
80106621:	68 c0 40 11 80       	push   $0x801140c0
80106626:	e8 5e ea ff ff       	call   80105089 <acquire>
8010662b:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
8010662e:	a1 f4 40 11 80       	mov    0x801140f4,%eax
80106633:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106636:	83 ec 0c             	sub    $0xc,%esp
80106639:	68 c0 40 11 80       	push   $0x801140c0
8010663e:	e8 ad ea ff ff       	call   801050f0 <release>
80106643:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106646:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106649:	c9                   	leave  
8010664a:	c3                   	ret    

8010664b <sys_print_free_frame_cnt>:

// CS 3320 print out free frames
int sys_print_free_frame_cnt(void)
{
8010664b:	55                   	push   %ebp
8010664c:	89 e5                	mov    %esp,%ebp
8010664e:	83 ec 08             	sub    $0x8,%esp
    cprintf("free-frames %d\n", free_frame_cnt);
80106651:	a1 00 12 11 80       	mov    0x80111200,%eax
80106656:	83 ec 08             	sub    $0x8,%esp
80106659:	50                   	push   %eax
8010665a:	68 64 8c 10 80       	push   $0x80108c64
8010665f:	e8 62 9d ff ff       	call   801003c6 <cprintf>
80106664:	83 c4 10             	add    $0x10,%esp
    return 0;
80106667:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010666c:	c9                   	leave  
8010666d:	c3                   	ret    

8010666e <sys_set_page_allocator>:

// CS 3320 set page allocator
extern int page_allocator_type;
int sys_set_page_allocator(void)
{
8010666e:	55                   	push   %ebp
8010666f:	89 e5                	mov    %esp,%ebp
80106671:	83 ec 08             	sub    $0x8,%esp
    if(argint(0,&page_allocator_type) < 0){
80106674:	83 ec 08             	sub    $0x8,%esp
80106677:	68 60 19 11 80       	push   $0x80111960
8010667c:	6a 00                	push   $0x0
8010667e:	e8 8d ef ff ff       	call   80105610 <argint>
80106683:	83 c4 10             	add    $0x10,%esp
80106686:	85 c0                	test   %eax,%eax
80106688:	79 07                	jns    80106691 <sys_set_page_allocator+0x23>
        return -1;
8010668a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010668f:	eb 05                	jmp    80106696 <sys_set_page_allocator+0x28>
    }
  
    
    return 0;
80106691:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106696:	c9                   	leave  
80106697:	c3                   	ret    

80106698 <sys_shmget>:

// CS 3320 shared memory
int sys_shmget(void)
{
80106698:	55                   	push   %ebp
80106699:	89 e5                	mov    %esp,%ebp
8010669b:	83 ec 18             	sub    $0x18,%esp
    int shm_id;
    if(argint(0, &shm_id) < 0){
8010669e:	83 ec 08             	sub    $0x8,%esp
801066a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066a4:	50                   	push   %eax
801066a5:	6a 00                	push   $0x0
801066a7:	e8 64 ef ff ff       	call   80105610 <argint>
801066ac:	83 c4 10             	add    $0x10,%esp
801066af:	85 c0                	test   %eax,%eax
801066b1:	79 07                	jns    801066ba <sys_shmget+0x22>
        return -1;
801066b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066b8:	eb 15                	jmp    801066cf <sys_shmget+0x37>
    }
    cprintf("Your shared memory mechanism has not been implemented!\n");    
801066ba:	83 ec 0c             	sub    $0xc,%esp
801066bd:	68 74 8c 10 80       	push   $0x80108c74
801066c2:	e8 ff 9c ff ff       	call   801003c6 <cprintf>
801066c7:	83 c4 10             	add    $0x10,%esp
    return 0;
801066ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066cf:	c9                   	leave  
801066d0:	c3                   	ret    

801066d1 <sys_shmdel>:

// delete a shared page
int sys_shmdel(void)
{
801066d1:	55                   	push   %ebp
801066d2:	89 e5                	mov    %esp,%ebp
801066d4:	83 ec 18             	sub    $0x18,%esp
    int shm_id;
    if(argint(0, &shm_id) < 0){
801066d7:	83 ec 08             	sub    $0x8,%esp
801066da:	8d 45 f4             	lea    -0xc(%ebp),%eax
801066dd:	50                   	push   %eax
801066de:	6a 00                	push   $0x0
801066e0:	e8 2b ef ff ff       	call   80105610 <argint>
801066e5:	83 c4 10             	add    $0x10,%esp
801066e8:	85 c0                	test   %eax,%eax
801066ea:	79 07                	jns    801066f3 <sys_shmdel+0x22>
        return -1;
801066ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f1:	eb 15                	jmp    80106708 <sys_shmdel+0x37>
    }
    cprintf("Your shared memory mechanims has not been implemented!\n");
801066f3:	83 ec 0c             	sub    $0xc,%esp
801066f6:	68 ac 8c 10 80       	push   $0x80108cac
801066fb:	e8 c6 9c ff ff       	call   801003c6 <cprintf>
80106700:	83 c4 10             	add    $0x10,%esp
    return 0;
80106703:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106708:	c9                   	leave  
80106709:	c3                   	ret    

8010670a <outb>:
{
8010670a:	55                   	push   %ebp
8010670b:	89 e5                	mov    %esp,%ebp
8010670d:	83 ec 08             	sub    $0x8,%esp
80106710:	8b 45 08             	mov    0x8(%ebp),%eax
80106713:	8b 55 0c             	mov    0xc(%ebp),%edx
80106716:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010671a:	89 d0                	mov    %edx,%eax
8010671c:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010671f:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106723:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106727:	ee                   	out    %al,(%dx)
}
80106728:	90                   	nop
80106729:	c9                   	leave  
8010672a:	c3                   	ret    

8010672b <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
8010672b:	55                   	push   %ebp
8010672c:	89 e5                	mov    %esp,%ebp
8010672e:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106731:	6a 34                	push   $0x34
80106733:	6a 43                	push   $0x43
80106735:	e8 d0 ff ff ff       	call   8010670a <outb>
8010673a:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
8010673d:	68 9c 00 00 00       	push   $0x9c
80106742:	6a 40                	push   $0x40
80106744:	e8 c1 ff ff ff       	call   8010670a <outb>
80106749:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
8010674c:	6a 2e                	push   $0x2e
8010674e:	6a 40                	push   $0x40
80106750:	e8 b5 ff ff ff       	call   8010670a <outb>
80106755:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106758:	83 ec 0c             	sub    $0xc,%esp
8010675b:	6a 00                	push   $0x0
8010675d:	e8 10 d8 ff ff       	call   80103f72 <picenable>
80106762:	83 c4 10             	add    $0x10,%esp
}
80106765:	90                   	nop
80106766:	c9                   	leave  
80106767:	c3                   	ret    

80106768 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106768:	1e                   	push   %ds
  pushl %es
80106769:	06                   	push   %es
  pushl %fs
8010676a:	0f a0                	push   %fs
  pushl %gs
8010676c:	0f a8                	push   %gs
  pushal
8010676e:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
8010676f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106773:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106775:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106777:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010677b:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
8010677d:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
8010677f:	54                   	push   %esp
  call trap
80106780:	e8 d7 01 00 00       	call   8010695c <trap>
  addl $4, %esp
80106785:	83 c4 04             	add    $0x4,%esp

80106788 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106788:	61                   	popa   
  popl %gs
80106789:	0f a9                	pop    %gs
  popl %fs
8010678b:	0f a1                	pop    %fs
  popl %es
8010678d:	07                   	pop    %es
  popl %ds
8010678e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010678f:	83 c4 08             	add    $0x8,%esp
  iret
80106792:	cf                   	iret   

80106793 <lidt>:
{
80106793:	55                   	push   %ebp
80106794:	89 e5                	mov    %esp,%ebp
80106796:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106799:	8b 45 0c             	mov    0xc(%ebp),%eax
8010679c:	83 e8 01             	sub    $0x1,%eax
8010679f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801067a3:	8b 45 08             	mov    0x8(%ebp),%eax
801067a6:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801067aa:	8b 45 08             	mov    0x8(%ebp),%eax
801067ad:	c1 e8 10             	shr    $0x10,%eax
801067b0:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801067b4:	8d 45 fa             	lea    -0x6(%ebp),%eax
801067b7:	0f 01 18             	lidtl  (%eax)
}
801067ba:	90                   	nop
801067bb:	c9                   	leave  
801067bc:	c3                   	ret    

801067bd <rcr2>:
{
801067bd:	55                   	push   %ebp
801067be:	89 e5                	mov    %esp,%ebp
801067c0:	83 ec 10             	sub    $0x10,%esp
  asm volatile("movl %%cr2,%0" : "=r" (val));
801067c3:	0f 20 d0             	mov    %cr2,%eax
801067c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801067c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801067cc:	c9                   	leave  
801067cd:	c3                   	ret    

801067ce <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
801067ce:	55                   	push   %ebp
801067cf:	89 e5                	mov    %esp,%ebp
801067d1:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
801067d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801067db:	e9 c3 00 00 00       	jmp    801068a3 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
801067e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067e3:	8b 04 85 ac b0 10 80 	mov    -0x7fef4f54(,%eax,4),%eax
801067ea:	89 c2                	mov    %eax,%edx
801067ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067ef:	66 89 14 c5 c0 38 11 	mov    %dx,-0x7feec740(,%eax,8)
801067f6:	80 
801067f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fa:	66 c7 04 c5 c2 38 11 	movw   $0x8,-0x7feec73e(,%eax,8)
80106801:	80 08 00 
80106804:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106807:	0f b6 14 c5 c4 38 11 	movzbl -0x7feec73c(,%eax,8),%edx
8010680e:	80 
8010680f:	83 e2 e0             	and    $0xffffffe0,%edx
80106812:	88 14 c5 c4 38 11 80 	mov    %dl,-0x7feec73c(,%eax,8)
80106819:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010681c:	0f b6 14 c5 c4 38 11 	movzbl -0x7feec73c(,%eax,8),%edx
80106823:	80 
80106824:	83 e2 1f             	and    $0x1f,%edx
80106827:	88 14 c5 c4 38 11 80 	mov    %dl,-0x7feec73c(,%eax,8)
8010682e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106831:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
80106838:	80 
80106839:	83 e2 f0             	and    $0xfffffff0,%edx
8010683c:	83 ca 0e             	or     $0xe,%edx
8010683f:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
80106846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106849:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
80106850:	80 
80106851:	83 e2 ef             	and    $0xffffffef,%edx
80106854:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
8010685b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685e:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
80106865:	80 
80106866:	83 e2 9f             	and    $0xffffff9f,%edx
80106869:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
80106870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106873:	0f b6 14 c5 c5 38 11 	movzbl -0x7feec73b(,%eax,8),%edx
8010687a:	80 
8010687b:	83 ca 80             	or     $0xffffff80,%edx
8010687e:	88 14 c5 c5 38 11 80 	mov    %dl,-0x7feec73b(,%eax,8)
80106885:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106888:	8b 04 85 ac b0 10 80 	mov    -0x7fef4f54(,%eax,4),%eax
8010688f:	c1 e8 10             	shr    $0x10,%eax
80106892:	89 c2                	mov    %eax,%edx
80106894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106897:	66 89 14 c5 c6 38 11 	mov    %dx,-0x7feec73a(,%eax,8)
8010689e:	80 
  for(i = 0; i < 256; i++)
8010689f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801068a3:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801068aa:	0f 8e 30 ff ff ff    	jle    801067e0 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801068b0:	a1 ac b1 10 80       	mov    0x8010b1ac,%eax
801068b5:	66 a3 c0 3a 11 80    	mov    %ax,0x80113ac0
801068bb:	66 c7 05 c2 3a 11 80 	movw   $0x8,0x80113ac2
801068c2:	08 00 
801068c4:	0f b6 05 c4 3a 11 80 	movzbl 0x80113ac4,%eax
801068cb:	83 e0 e0             	and    $0xffffffe0,%eax
801068ce:	a2 c4 3a 11 80       	mov    %al,0x80113ac4
801068d3:	0f b6 05 c4 3a 11 80 	movzbl 0x80113ac4,%eax
801068da:	83 e0 1f             	and    $0x1f,%eax
801068dd:	a2 c4 3a 11 80       	mov    %al,0x80113ac4
801068e2:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
801068e9:	83 c8 0f             	or     $0xf,%eax
801068ec:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
801068f1:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
801068f8:	83 e0 ef             	and    $0xffffffef,%eax
801068fb:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
80106900:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
80106907:	83 c8 60             	or     $0x60,%eax
8010690a:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
8010690f:	0f b6 05 c5 3a 11 80 	movzbl 0x80113ac5,%eax
80106916:	83 c8 80             	or     $0xffffff80,%eax
80106919:	a2 c5 3a 11 80       	mov    %al,0x80113ac5
8010691e:	a1 ac b1 10 80       	mov    0x8010b1ac,%eax
80106923:	c1 e8 10             	shr    $0x10,%eax
80106926:	66 a3 c6 3a 11 80    	mov    %ax,0x80113ac6
  
  initlock(&tickslock, "time");
8010692c:	83 ec 08             	sub    $0x8,%esp
8010692f:	68 e4 8c 10 80       	push   $0x80108ce4
80106934:	68 c0 40 11 80       	push   $0x801140c0
80106939:	e8 29 e7 ff ff       	call   80105067 <initlock>
8010693e:	83 c4 10             	add    $0x10,%esp
}
80106941:	90                   	nop
80106942:	c9                   	leave  
80106943:	c3                   	ret    

80106944 <idtinit>:

void
idtinit(void)
{
80106944:	55                   	push   %ebp
80106945:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80106947:	68 00 08 00 00       	push   $0x800
8010694c:	68 c0 38 11 80       	push   $0x801138c0
80106951:	e8 3d fe ff ff       	call   80106793 <lidt>
80106956:	83 c4 08             	add    $0x8,%esp
}
80106959:	90                   	nop
8010695a:	c9                   	leave  
8010695b:	c3                   	ret    

8010695c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
8010695c:	55                   	push   %ebp
8010695d:	89 e5                	mov    %esp,%ebp
8010695f:	57                   	push   %edi
80106960:	56                   	push   %esi
80106961:	53                   	push   %ebx
80106962:	83 ec 2c             	sub    $0x2c,%esp
   uint faulting_va = 0;
80106965:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  if(tf->trapno == T_SYSCALL){
8010696c:	8b 45 08             	mov    0x8(%ebp),%eax
8010696f:	8b 40 30             	mov    0x30(%eax),%eax
80106972:	83 f8 40             	cmp    $0x40,%eax
80106975:	75 3e                	jne    801069b5 <trap+0x59>
    if(proc->killed)
80106977:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010697d:	8b 40 24             	mov    0x24(%eax),%eax
80106980:	85 c0                	test   %eax,%eax
80106982:	74 05                	je     80106989 <trap+0x2d>
      exit();
80106984:	e8 a3 df ff ff       	call   8010492c <exit>
    proc->tf = tf;
80106989:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010698f:	8b 55 08             	mov    0x8(%ebp),%edx
80106992:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106995:	e8 2c ed ff ff       	call   801056c6 <syscall>
    if(proc->killed)
8010699a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069a0:	8b 40 24             	mov    0x24(%eax),%eax
801069a3:	85 c0                	test   %eax,%eax
801069a5:	0f 84 14 03 00 00    	je     80106cbf <trap+0x363>
      exit();
801069ab:	e8 7c df ff ff       	call   8010492c <exit>
    return;
801069b0:	e9 0a 03 00 00       	jmp    80106cbf <trap+0x363>
  }
 // CS 3320 project 2
 // You might need to change the folloiwng default page fault handling
 // for your project 2
 if(tf->trapno == T_PGFLT){
801069b5:	8b 45 08             	mov    0x8(%ebp),%eax
801069b8:	8b 40 30             	mov    0x30(%eax),%eax
801069bb:	83 f8 0e             	cmp    $0xe,%eax
801069be:	0f 85 e9 00 00 00    	jne    80106aad <trap+0x151>
    faulting_va = rcr2(); // get faulting address
801069c4:	e8 f4 fd ff ff       	call   801067bd <rcr2>
801069c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if(page_allocator_type == LAZY){
801069cc:	a1 60 19 11 80       	mov    0x80111960,%eax
801069d1:	83 f8 01             	cmp    $0x1,%eax
801069d4:	0f 85 ae 00 00 00    	jne    80106a88 <trap+0x12c>
      char *mem;
      if((mem = kalloc()) == 0){
801069da:	e8 a7 c2 ff ff       	call   80102c86 <kalloc>
801069df:	89 45 e0             	mov    %eax,-0x20(%ebp)
801069e2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801069e6:	75 22                	jne    80106a0a <trap+0xae>
        cprintf("LAZY allocator: out of memory!\n");
801069e8:	83 ec 0c             	sub    $0xc,%esp
801069eb:	68 ec 8c 10 80       	push   $0x80108cec
801069f0:	e8 d1 99 ff ff       	call   801003c6 <cprintf>
801069f5:	83 c4 10             	add    $0x10,%esp
        proc->killed = 1;
801069f8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069fe:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
        return;
80106a05:	e9 b9 02 00 00       	jmp    80106cc3 <trap+0x367>
      }
      memset(mem, 0, PGSIZE);
80106a0a:	83 ec 04             	sub    $0x4,%esp
80106a0d:	68 00 10 00 00       	push   $0x1000
80106a12:	6a 00                	push   $0x0
80106a14:	ff 75 e0             	push   -0x20(%ebp)
80106a17:	e8 d0 e8 ff ff       	call   801052ec <memset>
80106a1c:	83 c4 10             	add    $0x10,%esp
      if(mappages(proc->pgdir, (void*)PGROUNDDOWN(faulting_va), PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106a1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106a22:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80106a28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106a2b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106a30:	89 c1                	mov    %eax,%ecx
80106a32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a38:	8b 40 04             	mov    0x4(%eax),%eax
80106a3b:	83 ec 0c             	sub    $0xc,%esp
80106a3e:	6a 06                	push   $0x6
80106a40:	52                   	push   %edx
80106a41:	68 00 10 00 00       	push   $0x1000
80106a46:	51                   	push   %ecx
80106a47:	50                   	push   %eax
80106a48:	e8 75 14 00 00       	call   80107ec2 <mappages>
80106a4d:	83 c4 20             	add    $0x20,%esp
80106a50:	85 c0                	test   %eax,%eax
80106a52:	0f 89 6a 02 00 00    	jns    80106cc2 <trap+0x366>
        cprintf("LAZY allocator: mappages failed!\n");
80106a58:	83 ec 0c             	sub    $0xc,%esp
80106a5b:	68 0c 8d 10 80       	push   $0x80108d0c
80106a60:	e8 61 99 ff ff       	call   801003c6 <cprintf>
80106a65:	83 c4 10             	add    $0x10,%esp
        kfree(mem);
80106a68:	83 ec 0c             	sub    $0xc,%esp
80106a6b:	ff 75 e0             	push   -0x20(%ebp)
80106a6e:	e8 69 c1 ff ff       	call   80102bdc <kfree>
80106a73:	83 c4 10             	add    $0x10,%esp
        proc->killed = 1;
80106a76:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a7c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
        return;
80106a83:	e9 3b 02 00 00       	jmp    80106cc3 <trap+0x367>
      }
      return; // page mapped successfully
    }
    // Fault outside heap
    cprintf("Unhandled page fault at va 0x%x\n", faulting_va);
80106a88:	83 ec 08             	sub    $0x8,%esp
80106a8b:	ff 75 e4             	push   -0x1c(%ebp)
80106a8e:	68 30 8d 10 80       	push   $0x80108d30
80106a93:	e8 2e 99 ff ff       	call   801003c6 <cprintf>
80106a98:	83 c4 10             	add    $0x10,%esp
    proc->killed = 1;
80106a9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aa1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
    return;
80106aa8:	e9 16 02 00 00       	jmp    80106cc3 <trap+0x367>
}



  switch(tf->trapno){
80106aad:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab0:	8b 40 30             	mov    0x30(%eax),%eax
80106ab3:	83 e8 20             	sub    $0x20,%eax
80106ab6:	83 f8 1f             	cmp    $0x1f,%eax
80106ab9:	0f 87 c0 00 00 00    	ja     80106b7f <trap+0x223>
80106abf:	8b 04 85 f4 8d 10 80 	mov    -0x7fef720c(,%eax,4),%eax
80106ac6:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106ac8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106ace:	0f b6 00             	movzbl (%eax),%eax
80106ad1:	84 c0                	test   %al,%al
80106ad3:	75 3d                	jne    80106b12 <trap+0x1b6>
      acquire(&tickslock);
80106ad5:	83 ec 0c             	sub    $0xc,%esp
80106ad8:	68 c0 40 11 80       	push   $0x801140c0
80106add:	e8 a7 e5 ff ff       	call   80105089 <acquire>
80106ae2:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106ae5:	a1 f4 40 11 80       	mov    0x801140f4,%eax
80106aea:	83 c0 01             	add    $0x1,%eax
80106aed:	a3 f4 40 11 80       	mov    %eax,0x801140f4
      wakeup(&ticks);
80106af2:	83 ec 0c             	sub    $0xc,%esp
80106af5:	68 f4 40 11 80       	push   $0x801140f4
80106afa:	e8 7b e3 ff ff       	call   80104e7a <wakeup>
80106aff:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106b02:	83 ec 0c             	sub    $0xc,%esp
80106b05:	68 c0 40 11 80       	push   $0x801140c0
80106b0a:	e8 e1 e5 ff ff       	call   801050f0 <release>
80106b0f:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80106b12:	e8 3f c5 ff ff       	call   80103056 <lapiceoi>
    break;
80106b17:	e9 1d 01 00 00       	jmp    80106c39 <trap+0x2dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b1c:	e8 29 bd ff ff       	call   8010284a <ideintr>
    lapiceoi();
80106b21:	e8 30 c5 ff ff       	call   80103056 <lapiceoi>
    break;
80106b26:	e9 0e 01 00 00       	jmp    80106c39 <trap+0x2dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b2b:	e8 24 c3 ff ff       	call   80102e54 <kbdintr>
    lapiceoi();
80106b30:	e8 21 c5 ff ff       	call   80103056 <lapiceoi>
    break;
80106b35:	e9 ff 00 00 00       	jmp    80106c39 <trap+0x2dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b3a:	e8 66 03 00 00       	call   80106ea5 <uartintr>
    lapiceoi();
80106b3f:	e8 12 c5 ff ff       	call   80103056 <lapiceoi>
    break;
80106b44:	e9 f0 00 00 00       	jmp    80106c39 <trap+0x2dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b49:	8b 45 08             	mov    0x8(%ebp),%eax
80106b4c:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106b4f:	8b 45 08             	mov    0x8(%ebp),%eax
80106b52:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b56:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106b59:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b5f:	0f b6 00             	movzbl (%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b62:	0f b6 c0             	movzbl %al,%eax
80106b65:	51                   	push   %ecx
80106b66:	52                   	push   %edx
80106b67:	50                   	push   %eax
80106b68:	68 54 8d 10 80       	push   $0x80108d54
80106b6d:	e8 54 98 ff ff       	call   801003c6 <cprintf>
80106b72:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
80106b75:	e8 dc c4 ff ff       	call   80103056 <lapiceoi>
    break;
80106b7a:	e9 ba 00 00 00       	jmp    80106c39 <trap+0x2dd>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106b7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b85:	85 c0                	test   %eax,%eax
80106b87:	74 11                	je     80106b9a <trap+0x23e>
80106b89:	8b 45 08             	mov    0x8(%ebp),%eax
80106b8c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b90:	0f b7 c0             	movzwl %ax,%eax
80106b93:	83 e0 03             	and    $0x3,%eax
80106b96:	85 c0                	test   %eax,%eax
80106b98:	75 3f                	jne    80106bd9 <trap+0x27d>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106b9a:	e8 1e fc ff ff       	call   801067bd <rcr2>
80106b9f:	8b 55 08             	mov    0x8(%ebp),%edx
80106ba2:	8b 5a 38             	mov    0x38(%edx),%ebx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106ba5:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80106bac:	0f b6 12             	movzbl (%edx),%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106baf:	0f b6 ca             	movzbl %dl,%ecx
80106bb2:	8b 55 08             	mov    0x8(%ebp),%edx
80106bb5:	8b 52 30             	mov    0x30(%edx),%edx
80106bb8:	83 ec 0c             	sub    $0xc,%esp
80106bbb:	50                   	push   %eax
80106bbc:	53                   	push   %ebx
80106bbd:	51                   	push   %ecx
80106bbe:	52                   	push   %edx
80106bbf:	68 78 8d 10 80       	push   $0x80108d78
80106bc4:	e8 fd 97 ff ff       	call   801003c6 <cprintf>
80106bc9:	83 c4 20             	add    $0x20,%esp
      panic("trap");
80106bcc:	83 ec 0c             	sub    $0xc,%esp
80106bcf:	68 aa 8d 10 80       	push   $0x80108daa
80106bd4:	e8 a2 99 ff ff       	call   8010057b <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bd9:	e8 df fb ff ff       	call   801067bd <rcr2>
80106bde:	89 c2                	mov    %eax,%edx
80106be0:	8b 45 08             	mov    0x8(%ebp),%eax
80106be3:	8b 78 38             	mov    0x38(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106be6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bec:	0f b6 00             	movzbl (%eax),%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bef:	0f b6 f0             	movzbl %al,%esi
80106bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80106bf5:	8b 58 34             	mov    0x34(%eax),%ebx
80106bf8:	8b 45 08             	mov    0x8(%ebp),%eax
80106bfb:	8b 48 30             	mov    0x30(%eax),%ecx
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106bfe:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c04:	83 c0 6c             	add    $0x6c,%eax
80106c07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106c0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c10:	8b 40 10             	mov    0x10(%eax),%eax
80106c13:	52                   	push   %edx
80106c14:	57                   	push   %edi
80106c15:	56                   	push   %esi
80106c16:	53                   	push   %ebx
80106c17:	51                   	push   %ecx
80106c18:	ff 75 d4             	push   -0x2c(%ebp)
80106c1b:	50                   	push   %eax
80106c1c:	68 b0 8d 10 80       	push   $0x80108db0
80106c21:	e8 a0 97 ff ff       	call   801003c6 <cprintf>
80106c26:	83 c4 20             	add    $0x20,%esp
            rcr2());
    proc->killed = 1;
80106c29:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c2f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106c36:	eb 01                	jmp    80106c39 <trap+0x2dd>
    break;
80106c38:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c39:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c3f:	85 c0                	test   %eax,%eax
80106c41:	74 24                	je     80106c67 <trap+0x30b>
80106c43:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c49:	8b 40 24             	mov    0x24(%eax),%eax
80106c4c:	85 c0                	test   %eax,%eax
80106c4e:	74 17                	je     80106c67 <trap+0x30b>
80106c50:	8b 45 08             	mov    0x8(%ebp),%eax
80106c53:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c57:	0f b7 c0             	movzwl %ax,%eax
80106c5a:	83 e0 03             	and    $0x3,%eax
80106c5d:	83 f8 03             	cmp    $0x3,%eax
80106c60:	75 05                	jne    80106c67 <trap+0x30b>
    exit();
80106c62:	e8 c5 dc ff ff       	call   8010492c <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106c67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c6d:	85 c0                	test   %eax,%eax
80106c6f:	74 1e                	je     80106c8f <trap+0x333>
80106c71:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c77:	8b 40 0c             	mov    0xc(%eax),%eax
80106c7a:	83 f8 04             	cmp    $0x4,%eax
80106c7d:	75 10                	jne    80106c8f <trap+0x333>
80106c7f:	8b 45 08             	mov    0x8(%ebp),%eax
80106c82:	8b 40 30             	mov    0x30(%eax),%eax
80106c85:	83 f8 20             	cmp    $0x20,%eax
80106c88:	75 05                	jne    80106c8f <trap+0x333>
    yield();
80106c8a:	e8 7e e0 ff ff       	call   80104d0d <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c8f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c95:	85 c0                	test   %eax,%eax
80106c97:	74 2a                	je     80106cc3 <trap+0x367>
80106c99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c9f:	8b 40 24             	mov    0x24(%eax),%eax
80106ca2:	85 c0                	test   %eax,%eax
80106ca4:	74 1d                	je     80106cc3 <trap+0x367>
80106ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ca9:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cad:	0f b7 c0             	movzwl %ax,%eax
80106cb0:	83 e0 03             	and    $0x3,%eax
80106cb3:	83 f8 03             	cmp    $0x3,%eax
80106cb6:	75 0b                	jne    80106cc3 <trap+0x367>
    exit();
80106cb8:	e8 6f dc ff ff       	call   8010492c <exit>
80106cbd:	eb 04                	jmp    80106cc3 <trap+0x367>
    return;
80106cbf:	90                   	nop
80106cc0:	eb 01                	jmp    80106cc3 <trap+0x367>
      return; // page mapped successfully
80106cc2:	90                   	nop
}
80106cc3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106cc6:	5b                   	pop    %ebx
80106cc7:	5e                   	pop    %esi
80106cc8:	5f                   	pop    %edi
80106cc9:	5d                   	pop    %ebp
80106cca:	c3                   	ret    

80106ccb <inb>:
{
80106ccb:	55                   	push   %ebp
80106ccc:	89 e5                	mov    %esp,%ebp
80106cce:	83 ec 14             	sub    $0x14,%esp
80106cd1:	8b 45 08             	mov    0x8(%ebp),%eax
80106cd4:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106cd8:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106cdc:	89 c2                	mov    %eax,%edx
80106cde:	ec                   	in     (%dx),%al
80106cdf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106ce2:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106ce6:	c9                   	leave  
80106ce7:	c3                   	ret    

80106ce8 <outb>:
{
80106ce8:	55                   	push   %ebp
80106ce9:	89 e5                	mov    %esp,%ebp
80106ceb:	83 ec 08             	sub    $0x8,%esp
80106cee:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf1:	8b 55 0c             	mov    0xc(%ebp),%edx
80106cf4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106cf8:	89 d0                	mov    %edx,%eax
80106cfa:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106cfd:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d01:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d05:	ee                   	out    %al,(%dx)
}
80106d06:	90                   	nop
80106d07:	c9                   	leave  
80106d08:	c3                   	ret    

80106d09 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d09:	55                   	push   %ebp
80106d0a:	89 e5                	mov    %esp,%ebp
80106d0c:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d0f:	6a 00                	push   $0x0
80106d11:	68 fa 03 00 00       	push   $0x3fa
80106d16:	e8 cd ff ff ff       	call   80106ce8 <outb>
80106d1b:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d1e:	68 80 00 00 00       	push   $0x80
80106d23:	68 fb 03 00 00       	push   $0x3fb
80106d28:	e8 bb ff ff ff       	call   80106ce8 <outb>
80106d2d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106d30:	6a 0c                	push   $0xc
80106d32:	68 f8 03 00 00       	push   $0x3f8
80106d37:	e8 ac ff ff ff       	call   80106ce8 <outb>
80106d3c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106d3f:	6a 00                	push   $0x0
80106d41:	68 f9 03 00 00       	push   $0x3f9
80106d46:	e8 9d ff ff ff       	call   80106ce8 <outb>
80106d4b:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106d4e:	6a 03                	push   $0x3
80106d50:	68 fb 03 00 00       	push   $0x3fb
80106d55:	e8 8e ff ff ff       	call   80106ce8 <outb>
80106d5a:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106d5d:	6a 00                	push   $0x0
80106d5f:	68 fc 03 00 00       	push   $0x3fc
80106d64:	e8 7f ff ff ff       	call   80106ce8 <outb>
80106d69:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d6c:	6a 01                	push   $0x1
80106d6e:	68 f9 03 00 00       	push   $0x3f9
80106d73:	e8 70 ff ff ff       	call   80106ce8 <outb>
80106d78:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d7b:	68 fd 03 00 00       	push   $0x3fd
80106d80:	e8 46 ff ff ff       	call   80106ccb <inb>
80106d85:	83 c4 04             	add    $0x4,%esp
80106d88:	3c ff                	cmp    $0xff,%al
80106d8a:	74 6e                	je     80106dfa <uartinit+0xf1>
    return;
  uart = 1;
80106d8c:	c7 05 f8 40 11 80 01 	movl   $0x1,0x801140f8
80106d93:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d96:	68 fa 03 00 00       	push   $0x3fa
80106d9b:	e8 2b ff ff ff       	call   80106ccb <inb>
80106da0:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106da3:	68 f8 03 00 00       	push   $0x3f8
80106da8:	e8 1e ff ff ff       	call   80106ccb <inb>
80106dad:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106db0:	83 ec 0c             	sub    $0xc,%esp
80106db3:	6a 04                	push   $0x4
80106db5:	e8 b8 d1 ff ff       	call   80103f72 <picenable>
80106dba:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106dbd:	83 ec 08             	sub    $0x8,%esp
80106dc0:	6a 00                	push   $0x0
80106dc2:	6a 04                	push   $0x4
80106dc4:	e8 23 bd ff ff       	call   80102aec <ioapicenable>
80106dc9:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106dcc:	c7 45 f4 74 8e 10 80 	movl   $0x80108e74,-0xc(%ebp)
80106dd3:	eb 19                	jmp    80106dee <uartinit+0xe5>
    uartputc(*p);
80106dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106dd8:	0f b6 00             	movzbl (%eax),%eax
80106ddb:	0f be c0             	movsbl %al,%eax
80106dde:	83 ec 0c             	sub    $0xc,%esp
80106de1:	50                   	push   %eax
80106de2:	e8 16 00 00 00       	call   80106dfd <uartputc>
80106de7:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
80106dea:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df1:	0f b6 00             	movzbl (%eax),%eax
80106df4:	84 c0                	test   %al,%al
80106df6:	75 dd                	jne    80106dd5 <uartinit+0xcc>
80106df8:	eb 01                	jmp    80106dfb <uartinit+0xf2>
    return;
80106dfa:	90                   	nop
}
80106dfb:	c9                   	leave  
80106dfc:	c3                   	ret    

80106dfd <uartputc>:

void
uartputc(int c)
{
80106dfd:	55                   	push   %ebp
80106dfe:	89 e5                	mov    %esp,%ebp
80106e00:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106e03:	a1 f8 40 11 80       	mov    0x801140f8,%eax
80106e08:	85 c0                	test   %eax,%eax
80106e0a:	74 53                	je     80106e5f <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e13:	eb 11                	jmp    80106e26 <uartputc+0x29>
    microdelay(10);
80106e15:	83 ec 0c             	sub    $0xc,%esp
80106e18:	6a 0a                	push   $0xa
80106e1a:	e8 52 c2 ff ff       	call   80103071 <microdelay>
80106e1f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e22:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e26:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106e2a:	7f 1a                	jg     80106e46 <uartputc+0x49>
80106e2c:	83 ec 0c             	sub    $0xc,%esp
80106e2f:	68 fd 03 00 00       	push   $0x3fd
80106e34:	e8 92 fe ff ff       	call   80106ccb <inb>
80106e39:	83 c4 10             	add    $0x10,%esp
80106e3c:	0f b6 c0             	movzbl %al,%eax
80106e3f:	83 e0 20             	and    $0x20,%eax
80106e42:	85 c0                	test   %eax,%eax
80106e44:	74 cf                	je     80106e15 <uartputc+0x18>
  outb(COM1+0, c);
80106e46:	8b 45 08             	mov    0x8(%ebp),%eax
80106e49:	0f b6 c0             	movzbl %al,%eax
80106e4c:	83 ec 08             	sub    $0x8,%esp
80106e4f:	50                   	push   %eax
80106e50:	68 f8 03 00 00       	push   $0x3f8
80106e55:	e8 8e fe ff ff       	call   80106ce8 <outb>
80106e5a:	83 c4 10             	add    $0x10,%esp
80106e5d:	eb 01                	jmp    80106e60 <uartputc+0x63>
    return;
80106e5f:	90                   	nop
}
80106e60:	c9                   	leave  
80106e61:	c3                   	ret    

80106e62 <uartgetc>:

static int
uartgetc(void)
{
80106e62:	55                   	push   %ebp
80106e63:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106e65:	a1 f8 40 11 80       	mov    0x801140f8,%eax
80106e6a:	85 c0                	test   %eax,%eax
80106e6c:	75 07                	jne    80106e75 <uartgetc+0x13>
    return -1;
80106e6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e73:	eb 2e                	jmp    80106ea3 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106e75:	68 fd 03 00 00       	push   $0x3fd
80106e7a:	e8 4c fe ff ff       	call   80106ccb <inb>
80106e7f:	83 c4 04             	add    $0x4,%esp
80106e82:	0f b6 c0             	movzbl %al,%eax
80106e85:	83 e0 01             	and    $0x1,%eax
80106e88:	85 c0                	test   %eax,%eax
80106e8a:	75 07                	jne    80106e93 <uartgetc+0x31>
    return -1;
80106e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e91:	eb 10                	jmp    80106ea3 <uartgetc+0x41>
  return inb(COM1+0);
80106e93:	68 f8 03 00 00       	push   $0x3f8
80106e98:	e8 2e fe ff ff       	call   80106ccb <inb>
80106e9d:	83 c4 04             	add    $0x4,%esp
80106ea0:	0f b6 c0             	movzbl %al,%eax
}
80106ea3:	c9                   	leave  
80106ea4:	c3                   	ret    

80106ea5 <uartintr>:

void
uartintr(void)
{
80106ea5:	55                   	push   %ebp
80106ea6:	89 e5                	mov    %esp,%ebp
80106ea8:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106eab:	83 ec 0c             	sub    $0xc,%esp
80106eae:	68 62 6e 10 80       	push   $0x80106e62
80106eb3:	e8 64 99 ff ff       	call   8010081c <consoleintr>
80106eb8:	83 c4 10             	add    $0x10,%esp
}
80106ebb:	90                   	nop
80106ebc:	c9                   	leave  
80106ebd:	c3                   	ret    

80106ebe <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106ebe:	6a 00                	push   $0x0
  pushl $0
80106ec0:	6a 00                	push   $0x0
  jmp alltraps
80106ec2:	e9 a1 f8 ff ff       	jmp    80106768 <alltraps>

80106ec7 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ec7:	6a 00                	push   $0x0
  pushl $1
80106ec9:	6a 01                	push   $0x1
  jmp alltraps
80106ecb:	e9 98 f8 ff ff       	jmp    80106768 <alltraps>

80106ed0 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ed0:	6a 00                	push   $0x0
  pushl $2
80106ed2:	6a 02                	push   $0x2
  jmp alltraps
80106ed4:	e9 8f f8 ff ff       	jmp    80106768 <alltraps>

80106ed9 <vector3>:
.globl vector3
vector3:
  pushl $0
80106ed9:	6a 00                	push   $0x0
  pushl $3
80106edb:	6a 03                	push   $0x3
  jmp alltraps
80106edd:	e9 86 f8 ff ff       	jmp    80106768 <alltraps>

80106ee2 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ee2:	6a 00                	push   $0x0
  pushl $4
80106ee4:	6a 04                	push   $0x4
  jmp alltraps
80106ee6:	e9 7d f8 ff ff       	jmp    80106768 <alltraps>

80106eeb <vector5>:
.globl vector5
vector5:
  pushl $0
80106eeb:	6a 00                	push   $0x0
  pushl $5
80106eed:	6a 05                	push   $0x5
  jmp alltraps
80106eef:	e9 74 f8 ff ff       	jmp    80106768 <alltraps>

80106ef4 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ef4:	6a 00                	push   $0x0
  pushl $6
80106ef6:	6a 06                	push   $0x6
  jmp alltraps
80106ef8:	e9 6b f8 ff ff       	jmp    80106768 <alltraps>

80106efd <vector7>:
.globl vector7
vector7:
  pushl $0
80106efd:	6a 00                	push   $0x0
  pushl $7
80106eff:	6a 07                	push   $0x7
  jmp alltraps
80106f01:	e9 62 f8 ff ff       	jmp    80106768 <alltraps>

80106f06 <vector8>:
.globl vector8
vector8:
  pushl $8
80106f06:	6a 08                	push   $0x8
  jmp alltraps
80106f08:	e9 5b f8 ff ff       	jmp    80106768 <alltraps>

80106f0d <vector9>:
.globl vector9
vector9:
  pushl $0
80106f0d:	6a 00                	push   $0x0
  pushl $9
80106f0f:	6a 09                	push   $0x9
  jmp alltraps
80106f11:	e9 52 f8 ff ff       	jmp    80106768 <alltraps>

80106f16 <vector10>:
.globl vector10
vector10:
  pushl $10
80106f16:	6a 0a                	push   $0xa
  jmp alltraps
80106f18:	e9 4b f8 ff ff       	jmp    80106768 <alltraps>

80106f1d <vector11>:
.globl vector11
vector11:
  pushl $11
80106f1d:	6a 0b                	push   $0xb
  jmp alltraps
80106f1f:	e9 44 f8 ff ff       	jmp    80106768 <alltraps>

80106f24 <vector12>:
.globl vector12
vector12:
  pushl $12
80106f24:	6a 0c                	push   $0xc
  jmp alltraps
80106f26:	e9 3d f8 ff ff       	jmp    80106768 <alltraps>

80106f2b <vector13>:
.globl vector13
vector13:
  pushl $13
80106f2b:	6a 0d                	push   $0xd
  jmp alltraps
80106f2d:	e9 36 f8 ff ff       	jmp    80106768 <alltraps>

80106f32 <vector14>:
.globl vector14
vector14:
  pushl $14
80106f32:	6a 0e                	push   $0xe
  jmp alltraps
80106f34:	e9 2f f8 ff ff       	jmp    80106768 <alltraps>

80106f39 <vector15>:
.globl vector15
vector15:
  pushl $0
80106f39:	6a 00                	push   $0x0
  pushl $15
80106f3b:	6a 0f                	push   $0xf
  jmp alltraps
80106f3d:	e9 26 f8 ff ff       	jmp    80106768 <alltraps>

80106f42 <vector16>:
.globl vector16
vector16:
  pushl $0
80106f42:	6a 00                	push   $0x0
  pushl $16
80106f44:	6a 10                	push   $0x10
  jmp alltraps
80106f46:	e9 1d f8 ff ff       	jmp    80106768 <alltraps>

80106f4b <vector17>:
.globl vector17
vector17:
  pushl $17
80106f4b:	6a 11                	push   $0x11
  jmp alltraps
80106f4d:	e9 16 f8 ff ff       	jmp    80106768 <alltraps>

80106f52 <vector18>:
.globl vector18
vector18:
  pushl $0
80106f52:	6a 00                	push   $0x0
  pushl $18
80106f54:	6a 12                	push   $0x12
  jmp alltraps
80106f56:	e9 0d f8 ff ff       	jmp    80106768 <alltraps>

80106f5b <vector19>:
.globl vector19
vector19:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $19
80106f5d:	6a 13                	push   $0x13
  jmp alltraps
80106f5f:	e9 04 f8 ff ff       	jmp    80106768 <alltraps>

80106f64 <vector20>:
.globl vector20
vector20:
  pushl $0
80106f64:	6a 00                	push   $0x0
  pushl $20
80106f66:	6a 14                	push   $0x14
  jmp alltraps
80106f68:	e9 fb f7 ff ff       	jmp    80106768 <alltraps>

80106f6d <vector21>:
.globl vector21
vector21:
  pushl $0
80106f6d:	6a 00                	push   $0x0
  pushl $21
80106f6f:	6a 15                	push   $0x15
  jmp alltraps
80106f71:	e9 f2 f7 ff ff       	jmp    80106768 <alltraps>

80106f76 <vector22>:
.globl vector22
vector22:
  pushl $0
80106f76:	6a 00                	push   $0x0
  pushl $22
80106f78:	6a 16                	push   $0x16
  jmp alltraps
80106f7a:	e9 e9 f7 ff ff       	jmp    80106768 <alltraps>

80106f7f <vector23>:
.globl vector23
vector23:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $23
80106f81:	6a 17                	push   $0x17
  jmp alltraps
80106f83:	e9 e0 f7 ff ff       	jmp    80106768 <alltraps>

80106f88 <vector24>:
.globl vector24
vector24:
  pushl $0
80106f88:	6a 00                	push   $0x0
  pushl $24
80106f8a:	6a 18                	push   $0x18
  jmp alltraps
80106f8c:	e9 d7 f7 ff ff       	jmp    80106768 <alltraps>

80106f91 <vector25>:
.globl vector25
vector25:
  pushl $0
80106f91:	6a 00                	push   $0x0
  pushl $25
80106f93:	6a 19                	push   $0x19
  jmp alltraps
80106f95:	e9 ce f7 ff ff       	jmp    80106768 <alltraps>

80106f9a <vector26>:
.globl vector26
vector26:
  pushl $0
80106f9a:	6a 00                	push   $0x0
  pushl $26
80106f9c:	6a 1a                	push   $0x1a
  jmp alltraps
80106f9e:	e9 c5 f7 ff ff       	jmp    80106768 <alltraps>

80106fa3 <vector27>:
.globl vector27
vector27:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $27
80106fa5:	6a 1b                	push   $0x1b
  jmp alltraps
80106fa7:	e9 bc f7 ff ff       	jmp    80106768 <alltraps>

80106fac <vector28>:
.globl vector28
vector28:
  pushl $0
80106fac:	6a 00                	push   $0x0
  pushl $28
80106fae:	6a 1c                	push   $0x1c
  jmp alltraps
80106fb0:	e9 b3 f7 ff ff       	jmp    80106768 <alltraps>

80106fb5 <vector29>:
.globl vector29
vector29:
  pushl $0
80106fb5:	6a 00                	push   $0x0
  pushl $29
80106fb7:	6a 1d                	push   $0x1d
  jmp alltraps
80106fb9:	e9 aa f7 ff ff       	jmp    80106768 <alltraps>

80106fbe <vector30>:
.globl vector30
vector30:
  pushl $0
80106fbe:	6a 00                	push   $0x0
  pushl $30
80106fc0:	6a 1e                	push   $0x1e
  jmp alltraps
80106fc2:	e9 a1 f7 ff ff       	jmp    80106768 <alltraps>

80106fc7 <vector31>:
.globl vector31
vector31:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $31
80106fc9:	6a 1f                	push   $0x1f
  jmp alltraps
80106fcb:	e9 98 f7 ff ff       	jmp    80106768 <alltraps>

80106fd0 <vector32>:
.globl vector32
vector32:
  pushl $0
80106fd0:	6a 00                	push   $0x0
  pushl $32
80106fd2:	6a 20                	push   $0x20
  jmp alltraps
80106fd4:	e9 8f f7 ff ff       	jmp    80106768 <alltraps>

80106fd9 <vector33>:
.globl vector33
vector33:
  pushl $0
80106fd9:	6a 00                	push   $0x0
  pushl $33
80106fdb:	6a 21                	push   $0x21
  jmp alltraps
80106fdd:	e9 86 f7 ff ff       	jmp    80106768 <alltraps>

80106fe2 <vector34>:
.globl vector34
vector34:
  pushl $0
80106fe2:	6a 00                	push   $0x0
  pushl $34
80106fe4:	6a 22                	push   $0x22
  jmp alltraps
80106fe6:	e9 7d f7 ff ff       	jmp    80106768 <alltraps>

80106feb <vector35>:
.globl vector35
vector35:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $35
80106fed:	6a 23                	push   $0x23
  jmp alltraps
80106fef:	e9 74 f7 ff ff       	jmp    80106768 <alltraps>

80106ff4 <vector36>:
.globl vector36
vector36:
  pushl $0
80106ff4:	6a 00                	push   $0x0
  pushl $36
80106ff6:	6a 24                	push   $0x24
  jmp alltraps
80106ff8:	e9 6b f7 ff ff       	jmp    80106768 <alltraps>

80106ffd <vector37>:
.globl vector37
vector37:
  pushl $0
80106ffd:	6a 00                	push   $0x0
  pushl $37
80106fff:	6a 25                	push   $0x25
  jmp alltraps
80107001:	e9 62 f7 ff ff       	jmp    80106768 <alltraps>

80107006 <vector38>:
.globl vector38
vector38:
  pushl $0
80107006:	6a 00                	push   $0x0
  pushl $38
80107008:	6a 26                	push   $0x26
  jmp alltraps
8010700a:	e9 59 f7 ff ff       	jmp    80106768 <alltraps>

8010700f <vector39>:
.globl vector39
vector39:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $39
80107011:	6a 27                	push   $0x27
  jmp alltraps
80107013:	e9 50 f7 ff ff       	jmp    80106768 <alltraps>

80107018 <vector40>:
.globl vector40
vector40:
  pushl $0
80107018:	6a 00                	push   $0x0
  pushl $40
8010701a:	6a 28                	push   $0x28
  jmp alltraps
8010701c:	e9 47 f7 ff ff       	jmp    80106768 <alltraps>

80107021 <vector41>:
.globl vector41
vector41:
  pushl $0
80107021:	6a 00                	push   $0x0
  pushl $41
80107023:	6a 29                	push   $0x29
  jmp alltraps
80107025:	e9 3e f7 ff ff       	jmp    80106768 <alltraps>

8010702a <vector42>:
.globl vector42
vector42:
  pushl $0
8010702a:	6a 00                	push   $0x0
  pushl $42
8010702c:	6a 2a                	push   $0x2a
  jmp alltraps
8010702e:	e9 35 f7 ff ff       	jmp    80106768 <alltraps>

80107033 <vector43>:
.globl vector43
vector43:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $43
80107035:	6a 2b                	push   $0x2b
  jmp alltraps
80107037:	e9 2c f7 ff ff       	jmp    80106768 <alltraps>

8010703c <vector44>:
.globl vector44
vector44:
  pushl $0
8010703c:	6a 00                	push   $0x0
  pushl $44
8010703e:	6a 2c                	push   $0x2c
  jmp alltraps
80107040:	e9 23 f7 ff ff       	jmp    80106768 <alltraps>

80107045 <vector45>:
.globl vector45
vector45:
  pushl $0
80107045:	6a 00                	push   $0x0
  pushl $45
80107047:	6a 2d                	push   $0x2d
  jmp alltraps
80107049:	e9 1a f7 ff ff       	jmp    80106768 <alltraps>

8010704e <vector46>:
.globl vector46
vector46:
  pushl $0
8010704e:	6a 00                	push   $0x0
  pushl $46
80107050:	6a 2e                	push   $0x2e
  jmp alltraps
80107052:	e9 11 f7 ff ff       	jmp    80106768 <alltraps>

80107057 <vector47>:
.globl vector47
vector47:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $47
80107059:	6a 2f                	push   $0x2f
  jmp alltraps
8010705b:	e9 08 f7 ff ff       	jmp    80106768 <alltraps>

80107060 <vector48>:
.globl vector48
vector48:
  pushl $0
80107060:	6a 00                	push   $0x0
  pushl $48
80107062:	6a 30                	push   $0x30
  jmp alltraps
80107064:	e9 ff f6 ff ff       	jmp    80106768 <alltraps>

80107069 <vector49>:
.globl vector49
vector49:
  pushl $0
80107069:	6a 00                	push   $0x0
  pushl $49
8010706b:	6a 31                	push   $0x31
  jmp alltraps
8010706d:	e9 f6 f6 ff ff       	jmp    80106768 <alltraps>

80107072 <vector50>:
.globl vector50
vector50:
  pushl $0
80107072:	6a 00                	push   $0x0
  pushl $50
80107074:	6a 32                	push   $0x32
  jmp alltraps
80107076:	e9 ed f6 ff ff       	jmp    80106768 <alltraps>

8010707b <vector51>:
.globl vector51
vector51:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $51
8010707d:	6a 33                	push   $0x33
  jmp alltraps
8010707f:	e9 e4 f6 ff ff       	jmp    80106768 <alltraps>

80107084 <vector52>:
.globl vector52
vector52:
  pushl $0
80107084:	6a 00                	push   $0x0
  pushl $52
80107086:	6a 34                	push   $0x34
  jmp alltraps
80107088:	e9 db f6 ff ff       	jmp    80106768 <alltraps>

8010708d <vector53>:
.globl vector53
vector53:
  pushl $0
8010708d:	6a 00                	push   $0x0
  pushl $53
8010708f:	6a 35                	push   $0x35
  jmp alltraps
80107091:	e9 d2 f6 ff ff       	jmp    80106768 <alltraps>

80107096 <vector54>:
.globl vector54
vector54:
  pushl $0
80107096:	6a 00                	push   $0x0
  pushl $54
80107098:	6a 36                	push   $0x36
  jmp alltraps
8010709a:	e9 c9 f6 ff ff       	jmp    80106768 <alltraps>

8010709f <vector55>:
.globl vector55
vector55:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $55
801070a1:	6a 37                	push   $0x37
  jmp alltraps
801070a3:	e9 c0 f6 ff ff       	jmp    80106768 <alltraps>

801070a8 <vector56>:
.globl vector56
vector56:
  pushl $0
801070a8:	6a 00                	push   $0x0
  pushl $56
801070aa:	6a 38                	push   $0x38
  jmp alltraps
801070ac:	e9 b7 f6 ff ff       	jmp    80106768 <alltraps>

801070b1 <vector57>:
.globl vector57
vector57:
  pushl $0
801070b1:	6a 00                	push   $0x0
  pushl $57
801070b3:	6a 39                	push   $0x39
  jmp alltraps
801070b5:	e9 ae f6 ff ff       	jmp    80106768 <alltraps>

801070ba <vector58>:
.globl vector58
vector58:
  pushl $0
801070ba:	6a 00                	push   $0x0
  pushl $58
801070bc:	6a 3a                	push   $0x3a
  jmp alltraps
801070be:	e9 a5 f6 ff ff       	jmp    80106768 <alltraps>

801070c3 <vector59>:
.globl vector59
vector59:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $59
801070c5:	6a 3b                	push   $0x3b
  jmp alltraps
801070c7:	e9 9c f6 ff ff       	jmp    80106768 <alltraps>

801070cc <vector60>:
.globl vector60
vector60:
  pushl $0
801070cc:	6a 00                	push   $0x0
  pushl $60
801070ce:	6a 3c                	push   $0x3c
  jmp alltraps
801070d0:	e9 93 f6 ff ff       	jmp    80106768 <alltraps>

801070d5 <vector61>:
.globl vector61
vector61:
  pushl $0
801070d5:	6a 00                	push   $0x0
  pushl $61
801070d7:	6a 3d                	push   $0x3d
  jmp alltraps
801070d9:	e9 8a f6 ff ff       	jmp    80106768 <alltraps>

801070de <vector62>:
.globl vector62
vector62:
  pushl $0
801070de:	6a 00                	push   $0x0
  pushl $62
801070e0:	6a 3e                	push   $0x3e
  jmp alltraps
801070e2:	e9 81 f6 ff ff       	jmp    80106768 <alltraps>

801070e7 <vector63>:
.globl vector63
vector63:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $63
801070e9:	6a 3f                	push   $0x3f
  jmp alltraps
801070eb:	e9 78 f6 ff ff       	jmp    80106768 <alltraps>

801070f0 <vector64>:
.globl vector64
vector64:
  pushl $0
801070f0:	6a 00                	push   $0x0
  pushl $64
801070f2:	6a 40                	push   $0x40
  jmp alltraps
801070f4:	e9 6f f6 ff ff       	jmp    80106768 <alltraps>

801070f9 <vector65>:
.globl vector65
vector65:
  pushl $0
801070f9:	6a 00                	push   $0x0
  pushl $65
801070fb:	6a 41                	push   $0x41
  jmp alltraps
801070fd:	e9 66 f6 ff ff       	jmp    80106768 <alltraps>

80107102 <vector66>:
.globl vector66
vector66:
  pushl $0
80107102:	6a 00                	push   $0x0
  pushl $66
80107104:	6a 42                	push   $0x42
  jmp alltraps
80107106:	e9 5d f6 ff ff       	jmp    80106768 <alltraps>

8010710b <vector67>:
.globl vector67
vector67:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $67
8010710d:	6a 43                	push   $0x43
  jmp alltraps
8010710f:	e9 54 f6 ff ff       	jmp    80106768 <alltraps>

80107114 <vector68>:
.globl vector68
vector68:
  pushl $0
80107114:	6a 00                	push   $0x0
  pushl $68
80107116:	6a 44                	push   $0x44
  jmp alltraps
80107118:	e9 4b f6 ff ff       	jmp    80106768 <alltraps>

8010711d <vector69>:
.globl vector69
vector69:
  pushl $0
8010711d:	6a 00                	push   $0x0
  pushl $69
8010711f:	6a 45                	push   $0x45
  jmp alltraps
80107121:	e9 42 f6 ff ff       	jmp    80106768 <alltraps>

80107126 <vector70>:
.globl vector70
vector70:
  pushl $0
80107126:	6a 00                	push   $0x0
  pushl $70
80107128:	6a 46                	push   $0x46
  jmp alltraps
8010712a:	e9 39 f6 ff ff       	jmp    80106768 <alltraps>

8010712f <vector71>:
.globl vector71
vector71:
  pushl $0
8010712f:	6a 00                	push   $0x0
  pushl $71
80107131:	6a 47                	push   $0x47
  jmp alltraps
80107133:	e9 30 f6 ff ff       	jmp    80106768 <alltraps>

80107138 <vector72>:
.globl vector72
vector72:
  pushl $0
80107138:	6a 00                	push   $0x0
  pushl $72
8010713a:	6a 48                	push   $0x48
  jmp alltraps
8010713c:	e9 27 f6 ff ff       	jmp    80106768 <alltraps>

80107141 <vector73>:
.globl vector73
vector73:
  pushl $0
80107141:	6a 00                	push   $0x0
  pushl $73
80107143:	6a 49                	push   $0x49
  jmp alltraps
80107145:	e9 1e f6 ff ff       	jmp    80106768 <alltraps>

8010714a <vector74>:
.globl vector74
vector74:
  pushl $0
8010714a:	6a 00                	push   $0x0
  pushl $74
8010714c:	6a 4a                	push   $0x4a
  jmp alltraps
8010714e:	e9 15 f6 ff ff       	jmp    80106768 <alltraps>

80107153 <vector75>:
.globl vector75
vector75:
  pushl $0
80107153:	6a 00                	push   $0x0
  pushl $75
80107155:	6a 4b                	push   $0x4b
  jmp alltraps
80107157:	e9 0c f6 ff ff       	jmp    80106768 <alltraps>

8010715c <vector76>:
.globl vector76
vector76:
  pushl $0
8010715c:	6a 00                	push   $0x0
  pushl $76
8010715e:	6a 4c                	push   $0x4c
  jmp alltraps
80107160:	e9 03 f6 ff ff       	jmp    80106768 <alltraps>

80107165 <vector77>:
.globl vector77
vector77:
  pushl $0
80107165:	6a 00                	push   $0x0
  pushl $77
80107167:	6a 4d                	push   $0x4d
  jmp alltraps
80107169:	e9 fa f5 ff ff       	jmp    80106768 <alltraps>

8010716e <vector78>:
.globl vector78
vector78:
  pushl $0
8010716e:	6a 00                	push   $0x0
  pushl $78
80107170:	6a 4e                	push   $0x4e
  jmp alltraps
80107172:	e9 f1 f5 ff ff       	jmp    80106768 <alltraps>

80107177 <vector79>:
.globl vector79
vector79:
  pushl $0
80107177:	6a 00                	push   $0x0
  pushl $79
80107179:	6a 4f                	push   $0x4f
  jmp alltraps
8010717b:	e9 e8 f5 ff ff       	jmp    80106768 <alltraps>

80107180 <vector80>:
.globl vector80
vector80:
  pushl $0
80107180:	6a 00                	push   $0x0
  pushl $80
80107182:	6a 50                	push   $0x50
  jmp alltraps
80107184:	e9 df f5 ff ff       	jmp    80106768 <alltraps>

80107189 <vector81>:
.globl vector81
vector81:
  pushl $0
80107189:	6a 00                	push   $0x0
  pushl $81
8010718b:	6a 51                	push   $0x51
  jmp alltraps
8010718d:	e9 d6 f5 ff ff       	jmp    80106768 <alltraps>

80107192 <vector82>:
.globl vector82
vector82:
  pushl $0
80107192:	6a 00                	push   $0x0
  pushl $82
80107194:	6a 52                	push   $0x52
  jmp alltraps
80107196:	e9 cd f5 ff ff       	jmp    80106768 <alltraps>

8010719b <vector83>:
.globl vector83
vector83:
  pushl $0
8010719b:	6a 00                	push   $0x0
  pushl $83
8010719d:	6a 53                	push   $0x53
  jmp alltraps
8010719f:	e9 c4 f5 ff ff       	jmp    80106768 <alltraps>

801071a4 <vector84>:
.globl vector84
vector84:
  pushl $0
801071a4:	6a 00                	push   $0x0
  pushl $84
801071a6:	6a 54                	push   $0x54
  jmp alltraps
801071a8:	e9 bb f5 ff ff       	jmp    80106768 <alltraps>

801071ad <vector85>:
.globl vector85
vector85:
  pushl $0
801071ad:	6a 00                	push   $0x0
  pushl $85
801071af:	6a 55                	push   $0x55
  jmp alltraps
801071b1:	e9 b2 f5 ff ff       	jmp    80106768 <alltraps>

801071b6 <vector86>:
.globl vector86
vector86:
  pushl $0
801071b6:	6a 00                	push   $0x0
  pushl $86
801071b8:	6a 56                	push   $0x56
  jmp alltraps
801071ba:	e9 a9 f5 ff ff       	jmp    80106768 <alltraps>

801071bf <vector87>:
.globl vector87
vector87:
  pushl $0
801071bf:	6a 00                	push   $0x0
  pushl $87
801071c1:	6a 57                	push   $0x57
  jmp alltraps
801071c3:	e9 a0 f5 ff ff       	jmp    80106768 <alltraps>

801071c8 <vector88>:
.globl vector88
vector88:
  pushl $0
801071c8:	6a 00                	push   $0x0
  pushl $88
801071ca:	6a 58                	push   $0x58
  jmp alltraps
801071cc:	e9 97 f5 ff ff       	jmp    80106768 <alltraps>

801071d1 <vector89>:
.globl vector89
vector89:
  pushl $0
801071d1:	6a 00                	push   $0x0
  pushl $89
801071d3:	6a 59                	push   $0x59
  jmp alltraps
801071d5:	e9 8e f5 ff ff       	jmp    80106768 <alltraps>

801071da <vector90>:
.globl vector90
vector90:
  pushl $0
801071da:	6a 00                	push   $0x0
  pushl $90
801071dc:	6a 5a                	push   $0x5a
  jmp alltraps
801071de:	e9 85 f5 ff ff       	jmp    80106768 <alltraps>

801071e3 <vector91>:
.globl vector91
vector91:
  pushl $0
801071e3:	6a 00                	push   $0x0
  pushl $91
801071e5:	6a 5b                	push   $0x5b
  jmp alltraps
801071e7:	e9 7c f5 ff ff       	jmp    80106768 <alltraps>

801071ec <vector92>:
.globl vector92
vector92:
  pushl $0
801071ec:	6a 00                	push   $0x0
  pushl $92
801071ee:	6a 5c                	push   $0x5c
  jmp alltraps
801071f0:	e9 73 f5 ff ff       	jmp    80106768 <alltraps>

801071f5 <vector93>:
.globl vector93
vector93:
  pushl $0
801071f5:	6a 00                	push   $0x0
  pushl $93
801071f7:	6a 5d                	push   $0x5d
  jmp alltraps
801071f9:	e9 6a f5 ff ff       	jmp    80106768 <alltraps>

801071fe <vector94>:
.globl vector94
vector94:
  pushl $0
801071fe:	6a 00                	push   $0x0
  pushl $94
80107200:	6a 5e                	push   $0x5e
  jmp alltraps
80107202:	e9 61 f5 ff ff       	jmp    80106768 <alltraps>

80107207 <vector95>:
.globl vector95
vector95:
  pushl $0
80107207:	6a 00                	push   $0x0
  pushl $95
80107209:	6a 5f                	push   $0x5f
  jmp alltraps
8010720b:	e9 58 f5 ff ff       	jmp    80106768 <alltraps>

80107210 <vector96>:
.globl vector96
vector96:
  pushl $0
80107210:	6a 00                	push   $0x0
  pushl $96
80107212:	6a 60                	push   $0x60
  jmp alltraps
80107214:	e9 4f f5 ff ff       	jmp    80106768 <alltraps>

80107219 <vector97>:
.globl vector97
vector97:
  pushl $0
80107219:	6a 00                	push   $0x0
  pushl $97
8010721b:	6a 61                	push   $0x61
  jmp alltraps
8010721d:	e9 46 f5 ff ff       	jmp    80106768 <alltraps>

80107222 <vector98>:
.globl vector98
vector98:
  pushl $0
80107222:	6a 00                	push   $0x0
  pushl $98
80107224:	6a 62                	push   $0x62
  jmp alltraps
80107226:	e9 3d f5 ff ff       	jmp    80106768 <alltraps>

8010722b <vector99>:
.globl vector99
vector99:
  pushl $0
8010722b:	6a 00                	push   $0x0
  pushl $99
8010722d:	6a 63                	push   $0x63
  jmp alltraps
8010722f:	e9 34 f5 ff ff       	jmp    80106768 <alltraps>

80107234 <vector100>:
.globl vector100
vector100:
  pushl $0
80107234:	6a 00                	push   $0x0
  pushl $100
80107236:	6a 64                	push   $0x64
  jmp alltraps
80107238:	e9 2b f5 ff ff       	jmp    80106768 <alltraps>

8010723d <vector101>:
.globl vector101
vector101:
  pushl $0
8010723d:	6a 00                	push   $0x0
  pushl $101
8010723f:	6a 65                	push   $0x65
  jmp alltraps
80107241:	e9 22 f5 ff ff       	jmp    80106768 <alltraps>

80107246 <vector102>:
.globl vector102
vector102:
  pushl $0
80107246:	6a 00                	push   $0x0
  pushl $102
80107248:	6a 66                	push   $0x66
  jmp alltraps
8010724a:	e9 19 f5 ff ff       	jmp    80106768 <alltraps>

8010724f <vector103>:
.globl vector103
vector103:
  pushl $0
8010724f:	6a 00                	push   $0x0
  pushl $103
80107251:	6a 67                	push   $0x67
  jmp alltraps
80107253:	e9 10 f5 ff ff       	jmp    80106768 <alltraps>

80107258 <vector104>:
.globl vector104
vector104:
  pushl $0
80107258:	6a 00                	push   $0x0
  pushl $104
8010725a:	6a 68                	push   $0x68
  jmp alltraps
8010725c:	e9 07 f5 ff ff       	jmp    80106768 <alltraps>

80107261 <vector105>:
.globl vector105
vector105:
  pushl $0
80107261:	6a 00                	push   $0x0
  pushl $105
80107263:	6a 69                	push   $0x69
  jmp alltraps
80107265:	e9 fe f4 ff ff       	jmp    80106768 <alltraps>

8010726a <vector106>:
.globl vector106
vector106:
  pushl $0
8010726a:	6a 00                	push   $0x0
  pushl $106
8010726c:	6a 6a                	push   $0x6a
  jmp alltraps
8010726e:	e9 f5 f4 ff ff       	jmp    80106768 <alltraps>

80107273 <vector107>:
.globl vector107
vector107:
  pushl $0
80107273:	6a 00                	push   $0x0
  pushl $107
80107275:	6a 6b                	push   $0x6b
  jmp alltraps
80107277:	e9 ec f4 ff ff       	jmp    80106768 <alltraps>

8010727c <vector108>:
.globl vector108
vector108:
  pushl $0
8010727c:	6a 00                	push   $0x0
  pushl $108
8010727e:	6a 6c                	push   $0x6c
  jmp alltraps
80107280:	e9 e3 f4 ff ff       	jmp    80106768 <alltraps>

80107285 <vector109>:
.globl vector109
vector109:
  pushl $0
80107285:	6a 00                	push   $0x0
  pushl $109
80107287:	6a 6d                	push   $0x6d
  jmp alltraps
80107289:	e9 da f4 ff ff       	jmp    80106768 <alltraps>

8010728e <vector110>:
.globl vector110
vector110:
  pushl $0
8010728e:	6a 00                	push   $0x0
  pushl $110
80107290:	6a 6e                	push   $0x6e
  jmp alltraps
80107292:	e9 d1 f4 ff ff       	jmp    80106768 <alltraps>

80107297 <vector111>:
.globl vector111
vector111:
  pushl $0
80107297:	6a 00                	push   $0x0
  pushl $111
80107299:	6a 6f                	push   $0x6f
  jmp alltraps
8010729b:	e9 c8 f4 ff ff       	jmp    80106768 <alltraps>

801072a0 <vector112>:
.globl vector112
vector112:
  pushl $0
801072a0:	6a 00                	push   $0x0
  pushl $112
801072a2:	6a 70                	push   $0x70
  jmp alltraps
801072a4:	e9 bf f4 ff ff       	jmp    80106768 <alltraps>

801072a9 <vector113>:
.globl vector113
vector113:
  pushl $0
801072a9:	6a 00                	push   $0x0
  pushl $113
801072ab:	6a 71                	push   $0x71
  jmp alltraps
801072ad:	e9 b6 f4 ff ff       	jmp    80106768 <alltraps>

801072b2 <vector114>:
.globl vector114
vector114:
  pushl $0
801072b2:	6a 00                	push   $0x0
  pushl $114
801072b4:	6a 72                	push   $0x72
  jmp alltraps
801072b6:	e9 ad f4 ff ff       	jmp    80106768 <alltraps>

801072bb <vector115>:
.globl vector115
vector115:
  pushl $0
801072bb:	6a 00                	push   $0x0
  pushl $115
801072bd:	6a 73                	push   $0x73
  jmp alltraps
801072bf:	e9 a4 f4 ff ff       	jmp    80106768 <alltraps>

801072c4 <vector116>:
.globl vector116
vector116:
  pushl $0
801072c4:	6a 00                	push   $0x0
  pushl $116
801072c6:	6a 74                	push   $0x74
  jmp alltraps
801072c8:	e9 9b f4 ff ff       	jmp    80106768 <alltraps>

801072cd <vector117>:
.globl vector117
vector117:
  pushl $0
801072cd:	6a 00                	push   $0x0
  pushl $117
801072cf:	6a 75                	push   $0x75
  jmp alltraps
801072d1:	e9 92 f4 ff ff       	jmp    80106768 <alltraps>

801072d6 <vector118>:
.globl vector118
vector118:
  pushl $0
801072d6:	6a 00                	push   $0x0
  pushl $118
801072d8:	6a 76                	push   $0x76
  jmp alltraps
801072da:	e9 89 f4 ff ff       	jmp    80106768 <alltraps>

801072df <vector119>:
.globl vector119
vector119:
  pushl $0
801072df:	6a 00                	push   $0x0
  pushl $119
801072e1:	6a 77                	push   $0x77
  jmp alltraps
801072e3:	e9 80 f4 ff ff       	jmp    80106768 <alltraps>

801072e8 <vector120>:
.globl vector120
vector120:
  pushl $0
801072e8:	6a 00                	push   $0x0
  pushl $120
801072ea:	6a 78                	push   $0x78
  jmp alltraps
801072ec:	e9 77 f4 ff ff       	jmp    80106768 <alltraps>

801072f1 <vector121>:
.globl vector121
vector121:
  pushl $0
801072f1:	6a 00                	push   $0x0
  pushl $121
801072f3:	6a 79                	push   $0x79
  jmp alltraps
801072f5:	e9 6e f4 ff ff       	jmp    80106768 <alltraps>

801072fa <vector122>:
.globl vector122
vector122:
  pushl $0
801072fa:	6a 00                	push   $0x0
  pushl $122
801072fc:	6a 7a                	push   $0x7a
  jmp alltraps
801072fe:	e9 65 f4 ff ff       	jmp    80106768 <alltraps>

80107303 <vector123>:
.globl vector123
vector123:
  pushl $0
80107303:	6a 00                	push   $0x0
  pushl $123
80107305:	6a 7b                	push   $0x7b
  jmp alltraps
80107307:	e9 5c f4 ff ff       	jmp    80106768 <alltraps>

8010730c <vector124>:
.globl vector124
vector124:
  pushl $0
8010730c:	6a 00                	push   $0x0
  pushl $124
8010730e:	6a 7c                	push   $0x7c
  jmp alltraps
80107310:	e9 53 f4 ff ff       	jmp    80106768 <alltraps>

80107315 <vector125>:
.globl vector125
vector125:
  pushl $0
80107315:	6a 00                	push   $0x0
  pushl $125
80107317:	6a 7d                	push   $0x7d
  jmp alltraps
80107319:	e9 4a f4 ff ff       	jmp    80106768 <alltraps>

8010731e <vector126>:
.globl vector126
vector126:
  pushl $0
8010731e:	6a 00                	push   $0x0
  pushl $126
80107320:	6a 7e                	push   $0x7e
  jmp alltraps
80107322:	e9 41 f4 ff ff       	jmp    80106768 <alltraps>

80107327 <vector127>:
.globl vector127
vector127:
  pushl $0
80107327:	6a 00                	push   $0x0
  pushl $127
80107329:	6a 7f                	push   $0x7f
  jmp alltraps
8010732b:	e9 38 f4 ff ff       	jmp    80106768 <alltraps>

80107330 <vector128>:
.globl vector128
vector128:
  pushl $0
80107330:	6a 00                	push   $0x0
  pushl $128
80107332:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107337:	e9 2c f4 ff ff       	jmp    80106768 <alltraps>

8010733c <vector129>:
.globl vector129
vector129:
  pushl $0
8010733c:	6a 00                	push   $0x0
  pushl $129
8010733e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107343:	e9 20 f4 ff ff       	jmp    80106768 <alltraps>

80107348 <vector130>:
.globl vector130
vector130:
  pushl $0
80107348:	6a 00                	push   $0x0
  pushl $130
8010734a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010734f:	e9 14 f4 ff ff       	jmp    80106768 <alltraps>

80107354 <vector131>:
.globl vector131
vector131:
  pushl $0
80107354:	6a 00                	push   $0x0
  pushl $131
80107356:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010735b:	e9 08 f4 ff ff       	jmp    80106768 <alltraps>

80107360 <vector132>:
.globl vector132
vector132:
  pushl $0
80107360:	6a 00                	push   $0x0
  pushl $132
80107362:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107367:	e9 fc f3 ff ff       	jmp    80106768 <alltraps>

8010736c <vector133>:
.globl vector133
vector133:
  pushl $0
8010736c:	6a 00                	push   $0x0
  pushl $133
8010736e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107373:	e9 f0 f3 ff ff       	jmp    80106768 <alltraps>

80107378 <vector134>:
.globl vector134
vector134:
  pushl $0
80107378:	6a 00                	push   $0x0
  pushl $134
8010737a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010737f:	e9 e4 f3 ff ff       	jmp    80106768 <alltraps>

80107384 <vector135>:
.globl vector135
vector135:
  pushl $0
80107384:	6a 00                	push   $0x0
  pushl $135
80107386:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010738b:	e9 d8 f3 ff ff       	jmp    80106768 <alltraps>

80107390 <vector136>:
.globl vector136
vector136:
  pushl $0
80107390:	6a 00                	push   $0x0
  pushl $136
80107392:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107397:	e9 cc f3 ff ff       	jmp    80106768 <alltraps>

8010739c <vector137>:
.globl vector137
vector137:
  pushl $0
8010739c:	6a 00                	push   $0x0
  pushl $137
8010739e:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801073a3:	e9 c0 f3 ff ff       	jmp    80106768 <alltraps>

801073a8 <vector138>:
.globl vector138
vector138:
  pushl $0
801073a8:	6a 00                	push   $0x0
  pushl $138
801073aa:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801073af:	e9 b4 f3 ff ff       	jmp    80106768 <alltraps>

801073b4 <vector139>:
.globl vector139
vector139:
  pushl $0
801073b4:	6a 00                	push   $0x0
  pushl $139
801073b6:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801073bb:	e9 a8 f3 ff ff       	jmp    80106768 <alltraps>

801073c0 <vector140>:
.globl vector140
vector140:
  pushl $0
801073c0:	6a 00                	push   $0x0
  pushl $140
801073c2:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801073c7:	e9 9c f3 ff ff       	jmp    80106768 <alltraps>

801073cc <vector141>:
.globl vector141
vector141:
  pushl $0
801073cc:	6a 00                	push   $0x0
  pushl $141
801073ce:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801073d3:	e9 90 f3 ff ff       	jmp    80106768 <alltraps>

801073d8 <vector142>:
.globl vector142
vector142:
  pushl $0
801073d8:	6a 00                	push   $0x0
  pushl $142
801073da:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801073df:	e9 84 f3 ff ff       	jmp    80106768 <alltraps>

801073e4 <vector143>:
.globl vector143
vector143:
  pushl $0
801073e4:	6a 00                	push   $0x0
  pushl $143
801073e6:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801073eb:	e9 78 f3 ff ff       	jmp    80106768 <alltraps>

801073f0 <vector144>:
.globl vector144
vector144:
  pushl $0
801073f0:	6a 00                	push   $0x0
  pushl $144
801073f2:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801073f7:	e9 6c f3 ff ff       	jmp    80106768 <alltraps>

801073fc <vector145>:
.globl vector145
vector145:
  pushl $0
801073fc:	6a 00                	push   $0x0
  pushl $145
801073fe:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107403:	e9 60 f3 ff ff       	jmp    80106768 <alltraps>

80107408 <vector146>:
.globl vector146
vector146:
  pushl $0
80107408:	6a 00                	push   $0x0
  pushl $146
8010740a:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010740f:	e9 54 f3 ff ff       	jmp    80106768 <alltraps>

80107414 <vector147>:
.globl vector147
vector147:
  pushl $0
80107414:	6a 00                	push   $0x0
  pushl $147
80107416:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010741b:	e9 48 f3 ff ff       	jmp    80106768 <alltraps>

80107420 <vector148>:
.globl vector148
vector148:
  pushl $0
80107420:	6a 00                	push   $0x0
  pushl $148
80107422:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107427:	e9 3c f3 ff ff       	jmp    80106768 <alltraps>

8010742c <vector149>:
.globl vector149
vector149:
  pushl $0
8010742c:	6a 00                	push   $0x0
  pushl $149
8010742e:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107433:	e9 30 f3 ff ff       	jmp    80106768 <alltraps>

80107438 <vector150>:
.globl vector150
vector150:
  pushl $0
80107438:	6a 00                	push   $0x0
  pushl $150
8010743a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010743f:	e9 24 f3 ff ff       	jmp    80106768 <alltraps>

80107444 <vector151>:
.globl vector151
vector151:
  pushl $0
80107444:	6a 00                	push   $0x0
  pushl $151
80107446:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010744b:	e9 18 f3 ff ff       	jmp    80106768 <alltraps>

80107450 <vector152>:
.globl vector152
vector152:
  pushl $0
80107450:	6a 00                	push   $0x0
  pushl $152
80107452:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107457:	e9 0c f3 ff ff       	jmp    80106768 <alltraps>

8010745c <vector153>:
.globl vector153
vector153:
  pushl $0
8010745c:	6a 00                	push   $0x0
  pushl $153
8010745e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107463:	e9 00 f3 ff ff       	jmp    80106768 <alltraps>

80107468 <vector154>:
.globl vector154
vector154:
  pushl $0
80107468:	6a 00                	push   $0x0
  pushl $154
8010746a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010746f:	e9 f4 f2 ff ff       	jmp    80106768 <alltraps>

80107474 <vector155>:
.globl vector155
vector155:
  pushl $0
80107474:	6a 00                	push   $0x0
  pushl $155
80107476:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010747b:	e9 e8 f2 ff ff       	jmp    80106768 <alltraps>

80107480 <vector156>:
.globl vector156
vector156:
  pushl $0
80107480:	6a 00                	push   $0x0
  pushl $156
80107482:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107487:	e9 dc f2 ff ff       	jmp    80106768 <alltraps>

8010748c <vector157>:
.globl vector157
vector157:
  pushl $0
8010748c:	6a 00                	push   $0x0
  pushl $157
8010748e:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107493:	e9 d0 f2 ff ff       	jmp    80106768 <alltraps>

80107498 <vector158>:
.globl vector158
vector158:
  pushl $0
80107498:	6a 00                	push   $0x0
  pushl $158
8010749a:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010749f:	e9 c4 f2 ff ff       	jmp    80106768 <alltraps>

801074a4 <vector159>:
.globl vector159
vector159:
  pushl $0
801074a4:	6a 00                	push   $0x0
  pushl $159
801074a6:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801074ab:	e9 b8 f2 ff ff       	jmp    80106768 <alltraps>

801074b0 <vector160>:
.globl vector160
vector160:
  pushl $0
801074b0:	6a 00                	push   $0x0
  pushl $160
801074b2:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801074b7:	e9 ac f2 ff ff       	jmp    80106768 <alltraps>

801074bc <vector161>:
.globl vector161
vector161:
  pushl $0
801074bc:	6a 00                	push   $0x0
  pushl $161
801074be:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801074c3:	e9 a0 f2 ff ff       	jmp    80106768 <alltraps>

801074c8 <vector162>:
.globl vector162
vector162:
  pushl $0
801074c8:	6a 00                	push   $0x0
  pushl $162
801074ca:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801074cf:	e9 94 f2 ff ff       	jmp    80106768 <alltraps>

801074d4 <vector163>:
.globl vector163
vector163:
  pushl $0
801074d4:	6a 00                	push   $0x0
  pushl $163
801074d6:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801074db:	e9 88 f2 ff ff       	jmp    80106768 <alltraps>

801074e0 <vector164>:
.globl vector164
vector164:
  pushl $0
801074e0:	6a 00                	push   $0x0
  pushl $164
801074e2:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801074e7:	e9 7c f2 ff ff       	jmp    80106768 <alltraps>

801074ec <vector165>:
.globl vector165
vector165:
  pushl $0
801074ec:	6a 00                	push   $0x0
  pushl $165
801074ee:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801074f3:	e9 70 f2 ff ff       	jmp    80106768 <alltraps>

801074f8 <vector166>:
.globl vector166
vector166:
  pushl $0
801074f8:	6a 00                	push   $0x0
  pushl $166
801074fa:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801074ff:	e9 64 f2 ff ff       	jmp    80106768 <alltraps>

80107504 <vector167>:
.globl vector167
vector167:
  pushl $0
80107504:	6a 00                	push   $0x0
  pushl $167
80107506:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010750b:	e9 58 f2 ff ff       	jmp    80106768 <alltraps>

80107510 <vector168>:
.globl vector168
vector168:
  pushl $0
80107510:	6a 00                	push   $0x0
  pushl $168
80107512:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107517:	e9 4c f2 ff ff       	jmp    80106768 <alltraps>

8010751c <vector169>:
.globl vector169
vector169:
  pushl $0
8010751c:	6a 00                	push   $0x0
  pushl $169
8010751e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107523:	e9 40 f2 ff ff       	jmp    80106768 <alltraps>

80107528 <vector170>:
.globl vector170
vector170:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $170
8010752a:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010752f:	e9 34 f2 ff ff       	jmp    80106768 <alltraps>

80107534 <vector171>:
.globl vector171
vector171:
  pushl $0
80107534:	6a 00                	push   $0x0
  pushl $171
80107536:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010753b:	e9 28 f2 ff ff       	jmp    80106768 <alltraps>

80107540 <vector172>:
.globl vector172
vector172:
  pushl $0
80107540:	6a 00                	push   $0x0
  pushl $172
80107542:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107547:	e9 1c f2 ff ff       	jmp    80106768 <alltraps>

8010754c <vector173>:
.globl vector173
vector173:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $173
8010754e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107553:	e9 10 f2 ff ff       	jmp    80106768 <alltraps>

80107558 <vector174>:
.globl vector174
vector174:
  pushl $0
80107558:	6a 00                	push   $0x0
  pushl $174
8010755a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010755f:	e9 04 f2 ff ff       	jmp    80106768 <alltraps>

80107564 <vector175>:
.globl vector175
vector175:
  pushl $0
80107564:	6a 00                	push   $0x0
  pushl $175
80107566:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010756b:	e9 f8 f1 ff ff       	jmp    80106768 <alltraps>

80107570 <vector176>:
.globl vector176
vector176:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $176
80107572:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107577:	e9 ec f1 ff ff       	jmp    80106768 <alltraps>

8010757c <vector177>:
.globl vector177
vector177:
  pushl $0
8010757c:	6a 00                	push   $0x0
  pushl $177
8010757e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107583:	e9 e0 f1 ff ff       	jmp    80106768 <alltraps>

80107588 <vector178>:
.globl vector178
vector178:
  pushl $0
80107588:	6a 00                	push   $0x0
  pushl $178
8010758a:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010758f:	e9 d4 f1 ff ff       	jmp    80106768 <alltraps>

80107594 <vector179>:
.globl vector179
vector179:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $179
80107596:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010759b:	e9 c8 f1 ff ff       	jmp    80106768 <alltraps>

801075a0 <vector180>:
.globl vector180
vector180:
  pushl $0
801075a0:	6a 00                	push   $0x0
  pushl $180
801075a2:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801075a7:	e9 bc f1 ff ff       	jmp    80106768 <alltraps>

801075ac <vector181>:
.globl vector181
vector181:
  pushl $0
801075ac:	6a 00                	push   $0x0
  pushl $181
801075ae:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801075b3:	e9 b0 f1 ff ff       	jmp    80106768 <alltraps>

801075b8 <vector182>:
.globl vector182
vector182:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $182
801075ba:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801075bf:	e9 a4 f1 ff ff       	jmp    80106768 <alltraps>

801075c4 <vector183>:
.globl vector183
vector183:
  pushl $0
801075c4:	6a 00                	push   $0x0
  pushl $183
801075c6:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801075cb:	e9 98 f1 ff ff       	jmp    80106768 <alltraps>

801075d0 <vector184>:
.globl vector184
vector184:
  pushl $0
801075d0:	6a 00                	push   $0x0
  pushl $184
801075d2:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801075d7:	e9 8c f1 ff ff       	jmp    80106768 <alltraps>

801075dc <vector185>:
.globl vector185
vector185:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $185
801075de:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801075e3:	e9 80 f1 ff ff       	jmp    80106768 <alltraps>

801075e8 <vector186>:
.globl vector186
vector186:
  pushl $0
801075e8:	6a 00                	push   $0x0
  pushl $186
801075ea:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801075ef:	e9 74 f1 ff ff       	jmp    80106768 <alltraps>

801075f4 <vector187>:
.globl vector187
vector187:
  pushl $0
801075f4:	6a 00                	push   $0x0
  pushl $187
801075f6:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801075fb:	e9 68 f1 ff ff       	jmp    80106768 <alltraps>

80107600 <vector188>:
.globl vector188
vector188:
  pushl $0
80107600:	6a 00                	push   $0x0
  pushl $188
80107602:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107607:	e9 5c f1 ff ff       	jmp    80106768 <alltraps>

8010760c <vector189>:
.globl vector189
vector189:
  pushl $0
8010760c:	6a 00                	push   $0x0
  pushl $189
8010760e:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107613:	e9 50 f1 ff ff       	jmp    80106768 <alltraps>

80107618 <vector190>:
.globl vector190
vector190:
  pushl $0
80107618:	6a 00                	push   $0x0
  pushl $190
8010761a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010761f:	e9 44 f1 ff ff       	jmp    80106768 <alltraps>

80107624 <vector191>:
.globl vector191
vector191:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $191
80107626:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010762b:	e9 38 f1 ff ff       	jmp    80106768 <alltraps>

80107630 <vector192>:
.globl vector192
vector192:
  pushl $0
80107630:	6a 00                	push   $0x0
  pushl $192
80107632:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107637:	e9 2c f1 ff ff       	jmp    80106768 <alltraps>

8010763c <vector193>:
.globl vector193
vector193:
  pushl $0
8010763c:	6a 00                	push   $0x0
  pushl $193
8010763e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107643:	e9 20 f1 ff ff       	jmp    80106768 <alltraps>

80107648 <vector194>:
.globl vector194
vector194:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $194
8010764a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010764f:	e9 14 f1 ff ff       	jmp    80106768 <alltraps>

80107654 <vector195>:
.globl vector195
vector195:
  pushl $0
80107654:	6a 00                	push   $0x0
  pushl $195
80107656:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010765b:	e9 08 f1 ff ff       	jmp    80106768 <alltraps>

80107660 <vector196>:
.globl vector196
vector196:
  pushl $0
80107660:	6a 00                	push   $0x0
  pushl $196
80107662:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107667:	e9 fc f0 ff ff       	jmp    80106768 <alltraps>

8010766c <vector197>:
.globl vector197
vector197:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $197
8010766e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107673:	e9 f0 f0 ff ff       	jmp    80106768 <alltraps>

80107678 <vector198>:
.globl vector198
vector198:
  pushl $0
80107678:	6a 00                	push   $0x0
  pushl $198
8010767a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010767f:	e9 e4 f0 ff ff       	jmp    80106768 <alltraps>

80107684 <vector199>:
.globl vector199
vector199:
  pushl $0
80107684:	6a 00                	push   $0x0
  pushl $199
80107686:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010768b:	e9 d8 f0 ff ff       	jmp    80106768 <alltraps>

80107690 <vector200>:
.globl vector200
vector200:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $200
80107692:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107697:	e9 cc f0 ff ff       	jmp    80106768 <alltraps>

8010769c <vector201>:
.globl vector201
vector201:
  pushl $0
8010769c:	6a 00                	push   $0x0
  pushl $201
8010769e:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801076a3:	e9 c0 f0 ff ff       	jmp    80106768 <alltraps>

801076a8 <vector202>:
.globl vector202
vector202:
  pushl $0
801076a8:	6a 00                	push   $0x0
  pushl $202
801076aa:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801076af:	e9 b4 f0 ff ff       	jmp    80106768 <alltraps>

801076b4 <vector203>:
.globl vector203
vector203:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $203
801076b6:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801076bb:	e9 a8 f0 ff ff       	jmp    80106768 <alltraps>

801076c0 <vector204>:
.globl vector204
vector204:
  pushl $0
801076c0:	6a 00                	push   $0x0
  pushl $204
801076c2:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801076c7:	e9 9c f0 ff ff       	jmp    80106768 <alltraps>

801076cc <vector205>:
.globl vector205
vector205:
  pushl $0
801076cc:	6a 00                	push   $0x0
  pushl $205
801076ce:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801076d3:	e9 90 f0 ff ff       	jmp    80106768 <alltraps>

801076d8 <vector206>:
.globl vector206
vector206:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $206
801076da:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801076df:	e9 84 f0 ff ff       	jmp    80106768 <alltraps>

801076e4 <vector207>:
.globl vector207
vector207:
  pushl $0
801076e4:	6a 00                	push   $0x0
  pushl $207
801076e6:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801076eb:	e9 78 f0 ff ff       	jmp    80106768 <alltraps>

801076f0 <vector208>:
.globl vector208
vector208:
  pushl $0
801076f0:	6a 00                	push   $0x0
  pushl $208
801076f2:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801076f7:	e9 6c f0 ff ff       	jmp    80106768 <alltraps>

801076fc <vector209>:
.globl vector209
vector209:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $209
801076fe:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107703:	e9 60 f0 ff ff       	jmp    80106768 <alltraps>

80107708 <vector210>:
.globl vector210
vector210:
  pushl $0
80107708:	6a 00                	push   $0x0
  pushl $210
8010770a:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010770f:	e9 54 f0 ff ff       	jmp    80106768 <alltraps>

80107714 <vector211>:
.globl vector211
vector211:
  pushl $0
80107714:	6a 00                	push   $0x0
  pushl $211
80107716:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010771b:	e9 48 f0 ff ff       	jmp    80106768 <alltraps>

80107720 <vector212>:
.globl vector212
vector212:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $212
80107722:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107727:	e9 3c f0 ff ff       	jmp    80106768 <alltraps>

8010772c <vector213>:
.globl vector213
vector213:
  pushl $0
8010772c:	6a 00                	push   $0x0
  pushl $213
8010772e:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107733:	e9 30 f0 ff ff       	jmp    80106768 <alltraps>

80107738 <vector214>:
.globl vector214
vector214:
  pushl $0
80107738:	6a 00                	push   $0x0
  pushl $214
8010773a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010773f:	e9 24 f0 ff ff       	jmp    80106768 <alltraps>

80107744 <vector215>:
.globl vector215
vector215:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $215
80107746:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010774b:	e9 18 f0 ff ff       	jmp    80106768 <alltraps>

80107750 <vector216>:
.globl vector216
vector216:
  pushl $0
80107750:	6a 00                	push   $0x0
  pushl $216
80107752:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107757:	e9 0c f0 ff ff       	jmp    80106768 <alltraps>

8010775c <vector217>:
.globl vector217
vector217:
  pushl $0
8010775c:	6a 00                	push   $0x0
  pushl $217
8010775e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107763:	e9 00 f0 ff ff       	jmp    80106768 <alltraps>

80107768 <vector218>:
.globl vector218
vector218:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $218
8010776a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010776f:	e9 f4 ef ff ff       	jmp    80106768 <alltraps>

80107774 <vector219>:
.globl vector219
vector219:
  pushl $0
80107774:	6a 00                	push   $0x0
  pushl $219
80107776:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010777b:	e9 e8 ef ff ff       	jmp    80106768 <alltraps>

80107780 <vector220>:
.globl vector220
vector220:
  pushl $0
80107780:	6a 00                	push   $0x0
  pushl $220
80107782:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107787:	e9 dc ef ff ff       	jmp    80106768 <alltraps>

8010778c <vector221>:
.globl vector221
vector221:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $221
8010778e:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107793:	e9 d0 ef ff ff       	jmp    80106768 <alltraps>

80107798 <vector222>:
.globl vector222
vector222:
  pushl $0
80107798:	6a 00                	push   $0x0
  pushl $222
8010779a:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010779f:	e9 c4 ef ff ff       	jmp    80106768 <alltraps>

801077a4 <vector223>:
.globl vector223
vector223:
  pushl $0
801077a4:	6a 00                	push   $0x0
  pushl $223
801077a6:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801077ab:	e9 b8 ef ff ff       	jmp    80106768 <alltraps>

801077b0 <vector224>:
.globl vector224
vector224:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $224
801077b2:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801077b7:	e9 ac ef ff ff       	jmp    80106768 <alltraps>

801077bc <vector225>:
.globl vector225
vector225:
  pushl $0
801077bc:	6a 00                	push   $0x0
  pushl $225
801077be:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801077c3:	e9 a0 ef ff ff       	jmp    80106768 <alltraps>

801077c8 <vector226>:
.globl vector226
vector226:
  pushl $0
801077c8:	6a 00                	push   $0x0
  pushl $226
801077ca:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801077cf:	e9 94 ef ff ff       	jmp    80106768 <alltraps>

801077d4 <vector227>:
.globl vector227
vector227:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $227
801077d6:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801077db:	e9 88 ef ff ff       	jmp    80106768 <alltraps>

801077e0 <vector228>:
.globl vector228
vector228:
  pushl $0
801077e0:	6a 00                	push   $0x0
  pushl $228
801077e2:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801077e7:	e9 7c ef ff ff       	jmp    80106768 <alltraps>

801077ec <vector229>:
.globl vector229
vector229:
  pushl $0
801077ec:	6a 00                	push   $0x0
  pushl $229
801077ee:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801077f3:	e9 70 ef ff ff       	jmp    80106768 <alltraps>

801077f8 <vector230>:
.globl vector230
vector230:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $230
801077fa:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801077ff:	e9 64 ef ff ff       	jmp    80106768 <alltraps>

80107804 <vector231>:
.globl vector231
vector231:
  pushl $0
80107804:	6a 00                	push   $0x0
  pushl $231
80107806:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010780b:	e9 58 ef ff ff       	jmp    80106768 <alltraps>

80107810 <vector232>:
.globl vector232
vector232:
  pushl $0
80107810:	6a 00                	push   $0x0
  pushl $232
80107812:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107817:	e9 4c ef ff ff       	jmp    80106768 <alltraps>

8010781c <vector233>:
.globl vector233
vector233:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $233
8010781e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107823:	e9 40 ef ff ff       	jmp    80106768 <alltraps>

80107828 <vector234>:
.globl vector234
vector234:
  pushl $0
80107828:	6a 00                	push   $0x0
  pushl $234
8010782a:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010782f:	e9 34 ef ff ff       	jmp    80106768 <alltraps>

80107834 <vector235>:
.globl vector235
vector235:
  pushl $0
80107834:	6a 00                	push   $0x0
  pushl $235
80107836:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010783b:	e9 28 ef ff ff       	jmp    80106768 <alltraps>

80107840 <vector236>:
.globl vector236
vector236:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $236
80107842:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107847:	e9 1c ef ff ff       	jmp    80106768 <alltraps>

8010784c <vector237>:
.globl vector237
vector237:
  pushl $0
8010784c:	6a 00                	push   $0x0
  pushl $237
8010784e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107853:	e9 10 ef ff ff       	jmp    80106768 <alltraps>

80107858 <vector238>:
.globl vector238
vector238:
  pushl $0
80107858:	6a 00                	push   $0x0
  pushl $238
8010785a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010785f:	e9 04 ef ff ff       	jmp    80106768 <alltraps>

80107864 <vector239>:
.globl vector239
vector239:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $239
80107866:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010786b:	e9 f8 ee ff ff       	jmp    80106768 <alltraps>

80107870 <vector240>:
.globl vector240
vector240:
  pushl $0
80107870:	6a 00                	push   $0x0
  pushl $240
80107872:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107877:	e9 ec ee ff ff       	jmp    80106768 <alltraps>

8010787c <vector241>:
.globl vector241
vector241:
  pushl $0
8010787c:	6a 00                	push   $0x0
  pushl $241
8010787e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107883:	e9 e0 ee ff ff       	jmp    80106768 <alltraps>

80107888 <vector242>:
.globl vector242
vector242:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $242
8010788a:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010788f:	e9 d4 ee ff ff       	jmp    80106768 <alltraps>

80107894 <vector243>:
.globl vector243
vector243:
  pushl $0
80107894:	6a 00                	push   $0x0
  pushl $243
80107896:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010789b:	e9 c8 ee ff ff       	jmp    80106768 <alltraps>

801078a0 <vector244>:
.globl vector244
vector244:
  pushl $0
801078a0:	6a 00                	push   $0x0
  pushl $244
801078a2:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801078a7:	e9 bc ee ff ff       	jmp    80106768 <alltraps>

801078ac <vector245>:
.globl vector245
vector245:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $245
801078ae:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801078b3:	e9 b0 ee ff ff       	jmp    80106768 <alltraps>

801078b8 <vector246>:
.globl vector246
vector246:
  pushl $0
801078b8:	6a 00                	push   $0x0
  pushl $246
801078ba:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801078bf:	e9 a4 ee ff ff       	jmp    80106768 <alltraps>

801078c4 <vector247>:
.globl vector247
vector247:
  pushl $0
801078c4:	6a 00                	push   $0x0
  pushl $247
801078c6:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801078cb:	e9 98 ee ff ff       	jmp    80106768 <alltraps>

801078d0 <vector248>:
.globl vector248
vector248:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $248
801078d2:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801078d7:	e9 8c ee ff ff       	jmp    80106768 <alltraps>

801078dc <vector249>:
.globl vector249
vector249:
  pushl $0
801078dc:	6a 00                	push   $0x0
  pushl $249
801078de:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801078e3:	e9 80 ee ff ff       	jmp    80106768 <alltraps>

801078e8 <vector250>:
.globl vector250
vector250:
  pushl $0
801078e8:	6a 00                	push   $0x0
  pushl $250
801078ea:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801078ef:	e9 74 ee ff ff       	jmp    80106768 <alltraps>

801078f4 <vector251>:
.globl vector251
vector251:
  pushl $0
801078f4:	6a 00                	push   $0x0
  pushl $251
801078f6:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801078fb:	e9 68 ee ff ff       	jmp    80106768 <alltraps>

80107900 <vector252>:
.globl vector252
vector252:
  pushl $0
80107900:	6a 00                	push   $0x0
  pushl $252
80107902:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107907:	e9 5c ee ff ff       	jmp    80106768 <alltraps>

8010790c <vector253>:
.globl vector253
vector253:
  pushl $0
8010790c:	6a 00                	push   $0x0
  pushl $253
8010790e:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107913:	e9 50 ee ff ff       	jmp    80106768 <alltraps>

80107918 <vector254>:
.globl vector254
vector254:
  pushl $0
80107918:	6a 00                	push   $0x0
  pushl $254
8010791a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
8010791f:	e9 44 ee ff ff       	jmp    80106768 <alltraps>

80107924 <vector255>:
.globl vector255
vector255:
  pushl $0
80107924:	6a 00                	push   $0x0
  pushl $255
80107926:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010792b:	e9 38 ee ff ff       	jmp    80106768 <alltraps>

80107930 <lgdt>:
{
80107930:	55                   	push   %ebp
80107931:	89 e5                	mov    %esp,%ebp
80107933:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80107936:	8b 45 0c             	mov    0xc(%ebp),%eax
80107939:	83 e8 01             	sub    $0x1,%eax
8010793c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107940:	8b 45 08             	mov    0x8(%ebp),%eax
80107943:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107947:	8b 45 08             	mov    0x8(%ebp),%eax
8010794a:	c1 e8 10             	shr    $0x10,%eax
8010794d:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80107951:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107954:	0f 01 10             	lgdtl  (%eax)
}
80107957:	90                   	nop
80107958:	c9                   	leave  
80107959:	c3                   	ret    

8010795a <ltr>:
{
8010795a:	55                   	push   %ebp
8010795b:	89 e5                	mov    %esp,%ebp
8010795d:	83 ec 04             	sub    $0x4,%esp
80107960:	8b 45 08             	mov    0x8(%ebp),%eax
80107963:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107967:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010796b:	0f 00 d8             	ltr    %ax
}
8010796e:	90                   	nop
8010796f:	c9                   	leave  
80107970:	c3                   	ret    

80107971 <loadgs>:
{
80107971:	55                   	push   %ebp
80107972:	89 e5                	mov    %esp,%ebp
80107974:	83 ec 04             	sub    $0x4,%esp
80107977:	8b 45 08             	mov    0x8(%ebp),%eax
8010797a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
8010797e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107982:	8e e8                	mov    %eax,%gs
}
80107984:	90                   	nop
80107985:	c9                   	leave  
80107986:	c3                   	ret    

80107987 <lcr3>:
{
80107987:	55                   	push   %ebp
80107988:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010798a:	8b 45 08             	mov    0x8(%ebp),%eax
8010798d:	0f 22 d8             	mov    %eax,%cr3
}
80107990:	90                   	nop
80107991:	5d                   	pop    %ebp
80107992:	c3                   	ret    

80107993 <v2p>:
static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107993:	55                   	push   %ebp
80107994:	89 e5                	mov    %esp,%ebp
80107996:	8b 45 08             	mov    0x8(%ebp),%eax
80107999:	05 00 00 00 80       	add    $0x80000000,%eax
8010799e:	5d                   	pop    %ebp
8010799f:	c3                   	ret    

801079a0 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801079a0:	55                   	push   %ebp
801079a1:	89 e5                	mov    %esp,%ebp
801079a3:	8b 45 08             	mov    0x8(%ebp),%eax
801079a6:	05 00 00 00 80       	add    $0x80000000,%eax
801079ab:	5d                   	pop    %ebp
801079ac:	c3                   	ret    

801079ad <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801079ad:	55                   	push   %ebp
801079ae:	89 e5                	mov    %esp,%ebp
801079b0:	53                   	push   %ebx
801079b1:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801079b4:	e8 44 b6 ff ff       	call   80102ffd <cpunum>
801079b9:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801079bf:	05 60 13 11 80       	add    $0x80111360,%eax
801079c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801079c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ca:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801079d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d3:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801079d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079dc:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801079e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079e7:	83 e2 f0             	and    $0xfffffff0,%edx
801079ea:	83 ca 0a             	or     $0xa,%edx
801079ed:	88 50 7d             	mov    %dl,0x7d(%eax)
801079f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f3:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079f7:	83 ca 10             	or     $0x10,%edx
801079fa:	88 50 7d             	mov    %dl,0x7d(%eax)
801079fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a00:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a04:	83 e2 9f             	and    $0xffffff9f,%edx
80107a07:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a0d:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a11:	83 ca 80             	or     $0xffffff80,%edx
80107a14:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1a:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a1e:	83 ca 0f             	or     $0xf,%edx
80107a21:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a27:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a2b:	83 e2 ef             	and    $0xffffffef,%edx
80107a2e:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a34:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a38:	83 e2 df             	and    $0xffffffdf,%edx
80107a3b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a41:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a45:	83 ca 40             	or     $0x40,%edx
80107a48:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a4e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a52:	83 ca 80             	or     $0xffffff80,%edx
80107a55:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5b:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107a5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a62:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107a69:	ff ff 
80107a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a6e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107a75:	00 00 
80107a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7a:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a84:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a8b:	83 e2 f0             	and    $0xfffffff0,%edx
80107a8e:	83 ca 02             	or     $0x2,%edx
80107a91:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107aa1:	83 ca 10             	or     $0x10,%edx
80107aa4:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aad:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ab4:	83 e2 9f             	and    $0xffffff9f,%edx
80107ab7:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac0:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ac7:	83 ca 80             	or     $0xffffff80,%edx
80107aca:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ada:	83 ca 0f             	or     $0xf,%edx
80107add:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107aed:	83 e2 ef             	and    $0xffffffef,%edx
80107af0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b00:	83 e2 df             	and    $0xffffffdf,%edx
80107b03:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0c:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b13:	83 ca 40             	or     $0x40,%edx
80107b16:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b1f:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b26:	83 ca 80             	or     $0xffffff80,%edx
80107b29:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b32:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107b39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3c:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107b43:	ff ff 
80107b45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b48:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b4f:	00 00 
80107b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b54:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b65:	83 e2 f0             	and    $0xfffffff0,%edx
80107b68:	83 ca 0a             	or     $0xa,%edx
80107b6b:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b74:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b7b:	83 ca 10             	or     $0x10,%edx
80107b7e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b87:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b8e:	83 ca 60             	or     $0x60,%edx
80107b91:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9a:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ba1:	83 ca 80             	or     $0xffffff80,%edx
80107ba4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bad:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bb4:	83 ca 0f             	or     $0xf,%edx
80107bb7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc0:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bc7:	83 e2 ef             	and    $0xffffffef,%edx
80107bca:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd3:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bda:	83 e2 df             	and    $0xffffffdf,%edx
80107bdd:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107be6:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bed:	83 ca 40             	or     $0x40,%edx
80107bf0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bf9:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c00:	83 ca 80             	or     $0xffffff80,%edx
80107c03:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c0c:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c16:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107c1d:	ff ff 
80107c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c22:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107c29:	00 00 
80107c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2e:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c38:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c3f:	83 e2 f0             	and    $0xfffffff0,%edx
80107c42:	83 ca 02             	or     $0x2,%edx
80107c45:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c55:	83 ca 10             	or     $0x10,%edx
80107c58:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c61:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c68:	83 ca 60             	or     $0x60,%edx
80107c6b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c74:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c7b:	83 ca 80             	or     $0xffffff80,%edx
80107c7e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c87:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c8e:	83 ca 0f             	or     $0xf,%edx
80107c91:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ca1:	83 e2 ef             	and    $0xffffffef,%edx
80107ca4:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cad:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cb4:	83 e2 df             	and    $0xffffffdf,%edx
80107cb7:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc0:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cc7:	83 ca 40             	or     $0x40,%edx
80107cca:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd3:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cda:	83 ca 80             	or     $0xffffff80,%edx
80107cdd:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce6:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf0:	05 b4 00 00 00       	add    $0xb4,%eax
80107cf5:	89 c3                	mov    %eax,%ebx
80107cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfa:	05 b4 00 00 00       	add    $0xb4,%eax
80107cff:	c1 e8 10             	shr    $0x10,%eax
80107d02:	89 c2                	mov    %eax,%edx
80107d04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d07:	05 b4 00 00 00       	add    $0xb4,%eax
80107d0c:	c1 e8 18             	shr    $0x18,%eax
80107d0f:	89 c1                	mov    %eax,%ecx
80107d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d14:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107d1b:	00 00 
80107d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d20:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2a:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107d30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d33:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d3a:	83 e2 f0             	and    $0xfffffff0,%edx
80107d3d:	83 ca 02             	or     $0x2,%edx
80107d40:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d49:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d50:	83 ca 10             	or     $0x10,%edx
80107d53:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d5c:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d63:	83 e2 9f             	and    $0xffffff9f,%edx
80107d66:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6f:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d76:	83 ca 80             	or     $0xffffff80,%edx
80107d79:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d82:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d89:	83 e2 f0             	and    $0xfffffff0,%edx
80107d8c:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d95:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d9c:	83 e2 ef             	and    $0xffffffef,%edx
80107d9f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da8:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107daf:	83 e2 df             	and    $0xffffffdf,%edx
80107db2:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbb:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107dc2:	83 ca 40             	or     $0x40,%edx
80107dc5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107dcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dce:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107dd5:	83 ca 80             	or     $0xffffff80,%edx
80107dd8:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107dde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de1:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dea:	83 c0 70             	add    $0x70,%eax
80107ded:	83 ec 08             	sub    $0x8,%esp
80107df0:	6a 38                	push   $0x38
80107df2:	50                   	push   %eax
80107df3:	e8 38 fb ff ff       	call   80107930 <lgdt>
80107df8:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107dfb:	83 ec 0c             	sub    $0xc,%esp
80107dfe:	6a 18                	push   $0x18
80107e00:	e8 6c fb ff ff       	call   80107971 <loadgs>
80107e05:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0b:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107e11:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107e18:	00 00 00 00 
}
80107e1c:	90                   	nop
80107e1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e20:	c9                   	leave  
80107e21:	c3                   	ret    

80107e22 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e22:	55                   	push   %ebp
80107e23:	89 e5                	mov    %esp,%ebp
80107e25:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107e28:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e2b:	c1 e8 16             	shr    $0x16,%eax
80107e2e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e35:	8b 45 08             	mov    0x8(%ebp),%eax
80107e38:	01 d0                	add    %edx,%eax
80107e3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107e3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e40:	8b 00                	mov    (%eax),%eax
80107e42:	83 e0 01             	and    $0x1,%eax
80107e45:	85 c0                	test   %eax,%eax
80107e47:	74 18                	je     80107e61 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107e49:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e4c:	8b 00                	mov    (%eax),%eax
80107e4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e53:	50                   	push   %eax
80107e54:	e8 47 fb ff ff       	call   801079a0 <p2v>
80107e59:	83 c4 04             	add    $0x4,%esp
80107e5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e5f:	eb 48                	jmp    80107ea9 <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e61:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e65:	74 0e                	je     80107e75 <walkpgdir+0x53>
80107e67:	e8 1a ae ff ff       	call   80102c86 <kalloc>
80107e6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e73:	75 07                	jne    80107e7c <walkpgdir+0x5a>
      return 0;
80107e75:	b8 00 00 00 00       	mov    $0x0,%eax
80107e7a:	eb 44                	jmp    80107ec0 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e7c:	83 ec 04             	sub    $0x4,%esp
80107e7f:	68 00 10 00 00       	push   $0x1000
80107e84:	6a 00                	push   $0x0
80107e86:	ff 75 f4             	push   -0xc(%ebp)
80107e89:	e8 5e d4 ff ff       	call   801052ec <memset>
80107e8e:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107e91:	83 ec 0c             	sub    $0xc,%esp
80107e94:	ff 75 f4             	push   -0xc(%ebp)
80107e97:	e8 f7 fa ff ff       	call   80107993 <v2p>
80107e9c:	83 c4 10             	add    $0x10,%esp
80107e9f:	83 c8 07             	or     $0x7,%eax
80107ea2:	89 c2                	mov    %eax,%edx
80107ea4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107ea7:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eac:	c1 e8 0c             	shr    $0xc,%eax
80107eaf:	25 ff 03 00 00       	and    $0x3ff,%eax
80107eb4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ebe:	01 d0                	add    %edx,%eax
}
80107ec0:	c9                   	leave  
80107ec1:	c3                   	ret    

80107ec2 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ec2:	55                   	push   %ebp
80107ec3:	89 e5                	mov    %esp,%ebp
80107ec5:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ecb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ed0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ed3:	8b 55 0c             	mov    0xc(%ebp),%edx
80107ed6:	8b 45 10             	mov    0x10(%ebp),%eax
80107ed9:	01 d0                	add    %edx,%eax
80107edb:	83 e8 01             	sub    $0x1,%eax
80107ede:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ee6:	83 ec 04             	sub    $0x4,%esp
80107ee9:	6a 01                	push   $0x1
80107eeb:	ff 75 f4             	push   -0xc(%ebp)
80107eee:	ff 75 08             	push   0x8(%ebp)
80107ef1:	e8 2c ff ff ff       	call   80107e22 <walkpgdir>
80107ef6:	83 c4 10             	add    $0x10,%esp
80107ef9:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107efc:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f00:	75 07                	jne    80107f09 <mappages+0x47>
      return -1;
80107f02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f07:	eb 47                	jmp    80107f50 <mappages+0x8e>
    if(*pte & PTE_P)
80107f09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f0c:	8b 00                	mov    (%eax),%eax
80107f0e:	83 e0 01             	and    $0x1,%eax
80107f11:	85 c0                	test   %eax,%eax
80107f13:	74 0d                	je     80107f22 <mappages+0x60>
      panic("remap");
80107f15:	83 ec 0c             	sub    $0xc,%esp
80107f18:	68 7c 8e 10 80       	push   $0x80108e7c
80107f1d:	e8 59 86 ff ff       	call   8010057b <panic>
    *pte = pa | perm | PTE_P;
80107f22:	8b 45 18             	mov    0x18(%ebp),%eax
80107f25:	0b 45 14             	or     0x14(%ebp),%eax
80107f28:	83 c8 01             	or     $0x1,%eax
80107f2b:	89 c2                	mov    %eax,%edx
80107f2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f30:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107f32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f35:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f38:	74 10                	je     80107f4a <mappages+0x88>
      break;
    a += PGSIZE;
80107f3a:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107f41:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107f48:	eb 9c                	jmp    80107ee6 <mappages+0x24>
      break;
80107f4a:	90                   	nop
  }
  return 0;
80107f4b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f50:	c9                   	leave  
80107f51:	c3                   	ret    

80107f52 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f52:	55                   	push   %ebp
80107f53:	89 e5                	mov    %esp,%ebp
80107f55:	53                   	push   %ebx
80107f56:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107f59:	e8 28 ad ff ff       	call   80102c86 <kalloc>
80107f5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f65:	75 0a                	jne    80107f71 <setupkvm+0x1f>
    return 0;
80107f67:	b8 00 00 00 00       	mov    $0x0,%eax
80107f6c:	e9 8e 00 00 00       	jmp    80107fff <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107f71:	83 ec 04             	sub    $0x4,%esp
80107f74:	68 00 10 00 00       	push   $0x1000
80107f79:	6a 00                	push   $0x0
80107f7b:	ff 75 f0             	push   -0x10(%ebp)
80107f7e:	e8 69 d3 ff ff       	call   801052ec <memset>
80107f83:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107f86:	83 ec 0c             	sub    $0xc,%esp
80107f89:	68 00 00 00 0e       	push   $0xe000000
80107f8e:	e8 0d fa ff ff       	call   801079a0 <p2v>
80107f93:	83 c4 10             	add    $0x10,%esp
80107f96:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107f9b:	76 0d                	jbe    80107faa <setupkvm+0x58>
    panic("PHYSTOP too high");
80107f9d:	83 ec 0c             	sub    $0xc,%esp
80107fa0:	68 82 8e 10 80       	push   $0x80108e82
80107fa5:	e8 d1 85 ff ff       	call   8010057b <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107faa:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107fb1:	eb 40                	jmp    80107ff3 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107fb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb6:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fbc:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107fbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc2:	8b 58 08             	mov    0x8(%eax),%ebx
80107fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc8:	8b 40 04             	mov    0x4(%eax),%eax
80107fcb:	29 c3                	sub    %eax,%ebx
80107fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd0:	8b 00                	mov    (%eax),%eax
80107fd2:	83 ec 0c             	sub    $0xc,%esp
80107fd5:	51                   	push   %ecx
80107fd6:	52                   	push   %edx
80107fd7:	53                   	push   %ebx
80107fd8:	50                   	push   %eax
80107fd9:	ff 75 f0             	push   -0x10(%ebp)
80107fdc:	e8 e1 fe ff ff       	call   80107ec2 <mappages>
80107fe1:	83 c4 20             	add    $0x20,%esp
80107fe4:	85 c0                	test   %eax,%eax
80107fe6:	79 07                	jns    80107fef <setupkvm+0x9d>
      return 0;
80107fe8:	b8 00 00 00 00       	mov    $0x0,%eax
80107fed:	eb 10                	jmp    80107fff <setupkvm+0xad>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fef:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107ff3:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107ffa:	72 b7                	jb     80107fb3 <setupkvm+0x61>
  return pgdir;
80107ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107fff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108002:	c9                   	leave  
80108003:	c3                   	ret    

80108004 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108004:	55                   	push   %ebp
80108005:	89 e5                	mov    %esp,%ebp
80108007:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010800a:	e8 43 ff ff ff       	call   80107f52 <setupkvm>
8010800f:	a3 00 41 11 80       	mov    %eax,0x80114100
  switchkvm();
80108014:	e8 03 00 00 00       	call   8010801c <switchkvm>
}
80108019:	90                   	nop
8010801a:	c9                   	leave  
8010801b:	c3                   	ret    

8010801c <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010801c:	55                   	push   %ebp
8010801d:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
8010801f:	a1 00 41 11 80       	mov    0x80114100,%eax
80108024:	50                   	push   %eax
80108025:	e8 69 f9 ff ff       	call   80107993 <v2p>
8010802a:	83 c4 04             	add    $0x4,%esp
8010802d:	50                   	push   %eax
8010802e:	e8 54 f9 ff ff       	call   80107987 <lcr3>
80108033:	83 c4 04             	add    $0x4,%esp
}
80108036:	90                   	nop
80108037:	c9                   	leave  
80108038:	c3                   	ret    

80108039 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108039:	55                   	push   %ebp
8010803a:	89 e5                	mov    %esp,%ebp
8010803c:	56                   	push   %esi
8010803d:	53                   	push   %ebx
  pushcli();
8010803e:	e8 a4 d1 ff ff       	call   801051e7 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108043:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108049:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108050:	83 c2 08             	add    $0x8,%edx
80108053:	89 d6                	mov    %edx,%esi
80108055:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010805c:	83 c2 08             	add    $0x8,%edx
8010805f:	c1 ea 10             	shr    $0x10,%edx
80108062:	89 d3                	mov    %edx,%ebx
80108064:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010806b:	83 c2 08             	add    $0x8,%edx
8010806e:	c1 ea 18             	shr    $0x18,%edx
80108071:	89 d1                	mov    %edx,%ecx
80108073:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010807a:	67 00 
8010807c:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108083:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
80108089:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108090:	83 e2 f0             	and    $0xfffffff0,%edx
80108093:	83 ca 09             	or     $0x9,%edx
80108096:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
8010809c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080a3:	83 ca 10             	or     $0x10,%edx
801080a6:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801080ac:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080b3:	83 e2 9f             	and    $0xffffff9f,%edx
801080b6:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801080bc:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080c3:	83 ca 80             	or     $0xffffff80,%edx
801080c6:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801080cc:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801080d3:	83 e2 f0             	and    $0xfffffff0,%edx
801080d6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801080dc:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801080e3:	83 e2 ef             	and    $0xffffffef,%edx
801080e6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801080ec:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801080f3:	83 e2 df             	and    $0xffffffdf,%edx
801080f6:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801080fc:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108103:	83 ca 40             	or     $0x40,%edx
80108106:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010810c:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108113:	83 e2 7f             	and    $0x7f,%edx
80108116:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
8010811c:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108122:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108128:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
8010812f:	83 e2 ef             	and    $0xffffffef,%edx
80108132:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
80108138:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010813e:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108144:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010814a:	8b 40 08             	mov    0x8(%eax),%eax
8010814d:	89 c2                	mov    %eax,%edx
8010814f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108155:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010815b:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
8010815e:	83 ec 0c             	sub    $0xc,%esp
80108161:	6a 30                	push   $0x30
80108163:	e8 f2 f7 ff ff       	call   8010795a <ltr>
80108168:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
8010816b:	8b 45 08             	mov    0x8(%ebp),%eax
8010816e:	8b 40 04             	mov    0x4(%eax),%eax
80108171:	85 c0                	test   %eax,%eax
80108173:	75 0d                	jne    80108182 <switchuvm+0x149>
    panic("switchuvm: no pgdir");
80108175:	83 ec 0c             	sub    $0xc,%esp
80108178:	68 93 8e 10 80       	push   $0x80108e93
8010817d:	e8 f9 83 ff ff       	call   8010057b <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108182:	8b 45 08             	mov    0x8(%ebp),%eax
80108185:	8b 40 04             	mov    0x4(%eax),%eax
80108188:	83 ec 0c             	sub    $0xc,%esp
8010818b:	50                   	push   %eax
8010818c:	e8 02 f8 ff ff       	call   80107993 <v2p>
80108191:	83 c4 10             	add    $0x10,%esp
80108194:	83 ec 0c             	sub    $0xc,%esp
80108197:	50                   	push   %eax
80108198:	e8 ea f7 ff ff       	call   80107987 <lcr3>
8010819d:	83 c4 10             	add    $0x10,%esp
  popcli();
801081a0:	e8 86 d0 ff ff       	call   8010522b <popcli>
}
801081a5:	90                   	nop
801081a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801081a9:	5b                   	pop    %ebx
801081aa:	5e                   	pop    %esi
801081ab:	5d                   	pop    %ebp
801081ac:	c3                   	ret    

801081ad <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801081ad:	55                   	push   %ebp
801081ae:	89 e5                	mov    %esp,%ebp
801081b0:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801081b3:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801081ba:	76 0d                	jbe    801081c9 <inituvm+0x1c>
    panic("inituvm: more than a page");
801081bc:	83 ec 0c             	sub    $0xc,%esp
801081bf:	68 a7 8e 10 80       	push   $0x80108ea7
801081c4:	e8 b2 83 ff ff       	call   8010057b <panic>
  mem = kalloc();
801081c9:	e8 b8 aa ff ff       	call   80102c86 <kalloc>
801081ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801081d1:	83 ec 04             	sub    $0x4,%esp
801081d4:	68 00 10 00 00       	push   $0x1000
801081d9:	6a 00                	push   $0x0
801081db:	ff 75 f4             	push   -0xc(%ebp)
801081de:	e8 09 d1 ff ff       	call   801052ec <memset>
801081e3:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081e6:	83 ec 0c             	sub    $0xc,%esp
801081e9:	ff 75 f4             	push   -0xc(%ebp)
801081ec:	e8 a2 f7 ff ff       	call   80107993 <v2p>
801081f1:	83 c4 10             	add    $0x10,%esp
801081f4:	83 ec 0c             	sub    $0xc,%esp
801081f7:	6a 06                	push   $0x6
801081f9:	50                   	push   %eax
801081fa:	68 00 10 00 00       	push   $0x1000
801081ff:	6a 00                	push   $0x0
80108201:	ff 75 08             	push   0x8(%ebp)
80108204:	e8 b9 fc ff ff       	call   80107ec2 <mappages>
80108209:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010820c:	83 ec 04             	sub    $0x4,%esp
8010820f:	ff 75 10             	push   0x10(%ebp)
80108212:	ff 75 0c             	push   0xc(%ebp)
80108215:	ff 75 f4             	push   -0xc(%ebp)
80108218:	e8 8e d1 ff ff       	call   801053ab <memmove>
8010821d:	83 c4 10             	add    $0x10,%esp
}
80108220:	90                   	nop
80108221:	c9                   	leave  
80108222:	c3                   	ret    

80108223 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108223:	55                   	push   %ebp
80108224:	89 e5                	mov    %esp,%ebp
80108226:	53                   	push   %ebx
80108227:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010822a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010822d:	25 ff 0f 00 00       	and    $0xfff,%eax
80108232:	85 c0                	test   %eax,%eax
80108234:	74 0d                	je     80108243 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108236:	83 ec 0c             	sub    $0xc,%esp
80108239:	68 c4 8e 10 80       	push   $0x80108ec4
8010823e:	e8 38 83 ff ff       	call   8010057b <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108243:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010824a:	e9 95 00 00 00       	jmp    801082e4 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010824f:	8b 55 0c             	mov    0xc(%ebp),%edx
80108252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108255:	01 d0                	add    %edx,%eax
80108257:	83 ec 04             	sub    $0x4,%esp
8010825a:	6a 00                	push   $0x0
8010825c:	50                   	push   %eax
8010825d:	ff 75 08             	push   0x8(%ebp)
80108260:	e8 bd fb ff ff       	call   80107e22 <walkpgdir>
80108265:	83 c4 10             	add    $0x10,%esp
80108268:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010826b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010826f:	75 0d                	jne    8010827e <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108271:	83 ec 0c             	sub    $0xc,%esp
80108274:	68 e7 8e 10 80       	push   $0x80108ee7
80108279:	e8 fd 82 ff ff       	call   8010057b <panic>
    pa = PTE_ADDR(*pte);
8010827e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108281:	8b 00                	mov    (%eax),%eax
80108283:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108288:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010828b:	8b 45 18             	mov    0x18(%ebp),%eax
8010828e:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108291:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108296:	77 0b                	ja     801082a3 <loaduvm+0x80>
      n = sz - i;
80108298:	8b 45 18             	mov    0x18(%ebp),%eax
8010829b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010829e:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082a1:	eb 07                	jmp    801082aa <loaduvm+0x87>
    else
      n = PGSIZE;
801082a3:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801082aa:	8b 55 14             	mov    0x14(%ebp),%edx
801082ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801082b3:	83 ec 0c             	sub    $0xc,%esp
801082b6:	ff 75 e8             	push   -0x18(%ebp)
801082b9:	e8 e2 f6 ff ff       	call   801079a0 <p2v>
801082be:	83 c4 10             	add    $0x10,%esp
801082c1:	ff 75 f0             	push   -0x10(%ebp)
801082c4:	53                   	push   %ebx
801082c5:	50                   	push   %eax
801082c6:	ff 75 10             	push   0x10(%ebp)
801082c9:	e8 22 9c ff ff       	call   80101ef0 <readi>
801082ce:	83 c4 10             	add    $0x10,%esp
801082d1:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801082d4:	74 07                	je     801082dd <loaduvm+0xba>
      return -1;
801082d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082db:	eb 18                	jmp    801082f5 <loaduvm+0xd2>
  for(i = 0; i < sz; i += PGSIZE){
801082dd:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e7:	3b 45 18             	cmp    0x18(%ebp),%eax
801082ea:	0f 82 5f ff ff ff    	jb     8010824f <loaduvm+0x2c>
  }
  return 0;
801082f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801082f8:	c9                   	leave  
801082f9:	c3                   	ret    

801082fa <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082fa:	55                   	push   %ebp
801082fb:	89 e5                	mov    %esp,%ebp
801082fd:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108300:	8b 45 10             	mov    0x10(%ebp),%eax
80108303:	85 c0                	test   %eax,%eax
80108305:	79 0a                	jns    80108311 <allocuvm+0x17>
    return 0;
80108307:	b8 00 00 00 00       	mov    $0x0,%eax
8010830c:	e9 ae 00 00 00       	jmp    801083bf <allocuvm+0xc5>
  if(newsz < oldsz)
80108311:	8b 45 10             	mov    0x10(%ebp),%eax
80108314:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108317:	73 08                	jae    80108321 <allocuvm+0x27>
    return oldsz;
80108319:	8b 45 0c             	mov    0xc(%ebp),%eax
8010831c:	e9 9e 00 00 00       	jmp    801083bf <allocuvm+0xc5>

  a = PGROUNDUP(oldsz);
80108321:	8b 45 0c             	mov    0xc(%ebp),%eax
80108324:	05 ff 0f 00 00       	add    $0xfff,%eax
80108329:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010832e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108331:	eb 7d                	jmp    801083b0 <allocuvm+0xb6>
    mem = kalloc();
80108333:	e8 4e a9 ff ff       	call   80102c86 <kalloc>
80108338:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010833b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010833f:	75 2b                	jne    8010836c <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108341:	83 ec 0c             	sub    $0xc,%esp
80108344:	68 05 8f 10 80       	push   $0x80108f05
80108349:	e8 78 80 ff ff       	call   801003c6 <cprintf>
8010834e:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108351:	83 ec 04             	sub    $0x4,%esp
80108354:	ff 75 0c             	push   0xc(%ebp)
80108357:	ff 75 10             	push   0x10(%ebp)
8010835a:	ff 75 08             	push   0x8(%ebp)
8010835d:	e8 5f 00 00 00       	call   801083c1 <deallocuvm>
80108362:	83 c4 10             	add    $0x10,%esp
      return 0;
80108365:	b8 00 00 00 00       	mov    $0x0,%eax
8010836a:	eb 53                	jmp    801083bf <allocuvm+0xc5>
    }
    memset(mem, 0, PGSIZE);
8010836c:	83 ec 04             	sub    $0x4,%esp
8010836f:	68 00 10 00 00       	push   $0x1000
80108374:	6a 00                	push   $0x0
80108376:	ff 75 f0             	push   -0x10(%ebp)
80108379:	e8 6e cf ff ff       	call   801052ec <memset>
8010837e:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108381:	83 ec 0c             	sub    $0xc,%esp
80108384:	ff 75 f0             	push   -0x10(%ebp)
80108387:	e8 07 f6 ff ff       	call   80107993 <v2p>
8010838c:	83 c4 10             	add    $0x10,%esp
8010838f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108392:	83 ec 0c             	sub    $0xc,%esp
80108395:	6a 06                	push   $0x6
80108397:	50                   	push   %eax
80108398:	68 00 10 00 00       	push   $0x1000
8010839d:	52                   	push   %edx
8010839e:	ff 75 08             	push   0x8(%ebp)
801083a1:	e8 1c fb ff ff       	call   80107ec2 <mappages>
801083a6:	83 c4 20             	add    $0x20,%esp
  for(; a < newsz; a += PGSIZE){
801083a9:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b3:	3b 45 10             	cmp    0x10(%ebp),%eax
801083b6:	0f 82 77 ff ff ff    	jb     80108333 <allocuvm+0x39>
  }
  return newsz;
801083bc:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083bf:	c9                   	leave  
801083c0:	c3                   	ret    

801083c1 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083c1:	55                   	push   %ebp
801083c2:	89 e5                	mov    %esp,%ebp
801083c4:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801083c7:	8b 45 10             	mov    0x10(%ebp),%eax
801083ca:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083cd:	72 08                	jb     801083d7 <deallocuvm+0x16>
    return oldsz;
801083cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d2:	e9 a5 00 00 00       	jmp    8010847c <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801083d7:	8b 45 10             	mov    0x10(%ebp),%eax
801083da:	05 ff 0f 00 00       	add    $0xfff,%eax
801083df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083e7:	e9 81 00 00 00       	jmp    8010846d <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ef:	83 ec 04             	sub    $0x4,%esp
801083f2:	6a 00                	push   $0x0
801083f4:	50                   	push   %eax
801083f5:	ff 75 08             	push   0x8(%ebp)
801083f8:	e8 25 fa ff ff       	call   80107e22 <walkpgdir>
801083fd:	83 c4 10             	add    $0x10,%esp
80108400:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108403:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108407:	75 09                	jne    80108412 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108409:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108410:	eb 54                	jmp    80108466 <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108415:	8b 00                	mov    (%eax),%eax
80108417:	83 e0 01             	and    $0x1,%eax
8010841a:	85 c0                	test   %eax,%eax
8010841c:	74 48                	je     80108466 <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
8010841e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108421:	8b 00                	mov    (%eax),%eax
80108423:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108428:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010842b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010842f:	75 0d                	jne    8010843e <deallocuvm+0x7d>
        panic("kfree");
80108431:	83 ec 0c             	sub    $0xc,%esp
80108434:	68 1d 8f 10 80       	push   $0x80108f1d
80108439:	e8 3d 81 ff ff       	call   8010057b <panic>
      char *v = p2v(pa);
8010843e:	83 ec 0c             	sub    $0xc,%esp
80108441:	ff 75 ec             	push   -0x14(%ebp)
80108444:	e8 57 f5 ff ff       	call   801079a0 <p2v>
80108449:	83 c4 10             	add    $0x10,%esp
8010844c:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
8010844f:	83 ec 0c             	sub    $0xc,%esp
80108452:	ff 75 e8             	push   -0x18(%ebp)
80108455:	e8 82 a7 ff ff       	call   80102bdc <kfree>
8010845a:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
8010845d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108460:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
80108466:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010846d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108470:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108473:	0f 82 73 ff ff ff    	jb     801083ec <deallocuvm+0x2b>
    }
  }
  return newsz;
80108479:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010847c:	c9                   	leave  
8010847d:	c3                   	ret    

8010847e <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010847e:	55                   	push   %ebp
8010847f:	89 e5                	mov    %esp,%ebp
80108481:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108484:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108488:	75 0d                	jne    80108497 <freevm+0x19>
    panic("freevm: no pgdir");
8010848a:	83 ec 0c             	sub    $0xc,%esp
8010848d:	68 23 8f 10 80       	push   $0x80108f23
80108492:	e8 e4 80 ff ff       	call   8010057b <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108497:	83 ec 04             	sub    $0x4,%esp
8010849a:	6a 00                	push   $0x0
8010849c:	68 00 00 00 80       	push   $0x80000000
801084a1:	ff 75 08             	push   0x8(%ebp)
801084a4:	e8 18 ff ff ff       	call   801083c1 <deallocuvm>
801084a9:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084ac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084b3:	eb 4f                	jmp    80108504 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801084b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084bf:	8b 45 08             	mov    0x8(%ebp),%eax
801084c2:	01 d0                	add    %edx,%eax
801084c4:	8b 00                	mov    (%eax),%eax
801084c6:	83 e0 01             	and    $0x1,%eax
801084c9:	85 c0                	test   %eax,%eax
801084cb:	74 33                	je     80108500 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801084cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084d7:	8b 45 08             	mov    0x8(%ebp),%eax
801084da:	01 d0                	add    %edx,%eax
801084dc:	8b 00                	mov    (%eax),%eax
801084de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e3:	83 ec 0c             	sub    $0xc,%esp
801084e6:	50                   	push   %eax
801084e7:	e8 b4 f4 ff ff       	call   801079a0 <p2v>
801084ec:	83 c4 10             	add    $0x10,%esp
801084ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084f2:	83 ec 0c             	sub    $0xc,%esp
801084f5:	ff 75 f0             	push   -0x10(%ebp)
801084f8:	e8 df a6 ff ff       	call   80102bdc <kfree>
801084fd:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108500:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108504:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010850b:	76 a8                	jbe    801084b5 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010850d:	83 ec 0c             	sub    $0xc,%esp
80108510:	ff 75 08             	push   0x8(%ebp)
80108513:	e8 c4 a6 ff ff       	call   80102bdc <kfree>
80108518:	83 c4 10             	add    $0x10,%esp
}
8010851b:	90                   	nop
8010851c:	c9                   	leave  
8010851d:	c3                   	ret    

8010851e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010851e:	55                   	push   %ebp
8010851f:	89 e5                	mov    %esp,%ebp
80108521:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108524:	83 ec 04             	sub    $0x4,%esp
80108527:	6a 00                	push   $0x0
80108529:	ff 75 0c             	push   0xc(%ebp)
8010852c:	ff 75 08             	push   0x8(%ebp)
8010852f:	e8 ee f8 ff ff       	call   80107e22 <walkpgdir>
80108534:	83 c4 10             	add    $0x10,%esp
80108537:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010853a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010853e:	75 0d                	jne    8010854d <clearpteu+0x2f>
    panic("clearpteu");
80108540:	83 ec 0c             	sub    $0xc,%esp
80108543:	68 34 8f 10 80       	push   $0x80108f34
80108548:	e8 2e 80 ff ff       	call   8010057b <panic>
  *pte &= ~PTE_U;
8010854d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108550:	8b 00                	mov    (%eax),%eax
80108552:	83 e0 fb             	and    $0xfffffffb,%eax
80108555:	89 c2                	mov    %eax,%edx
80108557:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855a:	89 10                	mov    %edx,(%eax)
}
8010855c:	90                   	nop
8010855d:	c9                   	leave  
8010855e:	c3                   	ret    

8010855f <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010855f:	55                   	push   %ebp
80108560:	89 e5                	mov    %esp,%ebp
80108562:	53                   	push   %ebx
80108563:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108566:	e8 e7 f9 ff ff       	call   80107f52 <setupkvm>
8010856b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010856e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108572:	75 0a                	jne    8010857e <copyuvm+0x1f>
    return 0;
80108574:	b8 00 00 00 00       	mov    $0x0,%eax
80108579:	e9 f6 00 00 00       	jmp    80108674 <copyuvm+0x115>
  for(i = 0; i < sz; i += PGSIZE){
8010857e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108585:	e9 c2 00 00 00       	jmp    8010864c <copyuvm+0xed>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010858a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858d:	83 ec 04             	sub    $0x4,%esp
80108590:	6a 00                	push   $0x0
80108592:	50                   	push   %eax
80108593:	ff 75 08             	push   0x8(%ebp)
80108596:	e8 87 f8 ff ff       	call   80107e22 <walkpgdir>
8010859b:	83 c4 10             	add    $0x10,%esp
8010859e:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085a5:	75 0d                	jne    801085b4 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801085a7:	83 ec 0c             	sub    $0xc,%esp
801085aa:	68 3e 8f 10 80       	push   $0x80108f3e
801085af:	e8 c7 7f ff ff       	call   8010057b <panic>
    if(!(*pte & PTE_P))
801085b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085b7:	8b 00                	mov    (%eax),%eax
801085b9:	83 e0 01             	and    $0x1,%eax
801085bc:	85 c0                	test   %eax,%eax
801085be:	75 0d                	jne    801085cd <copyuvm+0x6e>
      panic("copyuvm: page not present");
801085c0:	83 ec 0c             	sub    $0xc,%esp
801085c3:	68 58 8f 10 80       	push   $0x80108f58
801085c8:	e8 ae 7f ff ff       	call   8010057b <panic>
    pa = PTE_ADDR(*pte);
801085cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085d0:	8b 00                	mov    (%eax),%eax
801085d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801085da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085dd:	8b 00                	mov    (%eax),%eax
801085df:	25 ff 0f 00 00       	and    $0xfff,%eax
801085e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801085e7:	e8 9a a6 ff ff       	call   80102c86 <kalloc>
801085ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
801085ef:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801085f3:	74 68                	je     8010865d <copyuvm+0xfe>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801085f5:	83 ec 0c             	sub    $0xc,%esp
801085f8:	ff 75 e8             	push   -0x18(%ebp)
801085fb:	e8 a0 f3 ff ff       	call   801079a0 <p2v>
80108600:	83 c4 10             	add    $0x10,%esp
80108603:	83 ec 04             	sub    $0x4,%esp
80108606:	68 00 10 00 00       	push   $0x1000
8010860b:	50                   	push   %eax
8010860c:	ff 75 e0             	push   -0x20(%ebp)
8010860f:	e8 97 cd ff ff       	call   801053ab <memmove>
80108614:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108617:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010861a:	83 ec 0c             	sub    $0xc,%esp
8010861d:	ff 75 e0             	push   -0x20(%ebp)
80108620:	e8 6e f3 ff ff       	call   80107993 <v2p>
80108625:	83 c4 10             	add    $0x10,%esp
80108628:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010862b:	83 ec 0c             	sub    $0xc,%esp
8010862e:	53                   	push   %ebx
8010862f:	50                   	push   %eax
80108630:	68 00 10 00 00       	push   $0x1000
80108635:	52                   	push   %edx
80108636:	ff 75 f0             	push   -0x10(%ebp)
80108639:	e8 84 f8 ff ff       	call   80107ec2 <mappages>
8010863e:	83 c4 20             	add    $0x20,%esp
80108641:	85 c0                	test   %eax,%eax
80108643:	78 1b                	js     80108660 <copyuvm+0x101>
  for(i = 0; i < sz; i += PGSIZE){
80108645:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010864c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108652:	0f 82 32 ff ff ff    	jb     8010858a <copyuvm+0x2b>
      goto bad;
  }
  return d;
80108658:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010865b:	eb 17                	jmp    80108674 <copyuvm+0x115>
      goto bad;
8010865d:	90                   	nop
8010865e:	eb 01                	jmp    80108661 <copyuvm+0x102>
      goto bad;
80108660:	90                   	nop

bad:
  freevm(d);
80108661:	83 ec 0c             	sub    $0xc,%esp
80108664:	ff 75 f0             	push   -0x10(%ebp)
80108667:	e8 12 fe ff ff       	call   8010847e <freevm>
8010866c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010866f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108677:	c9                   	leave  
80108678:	c3                   	ret    

80108679 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108679:	55                   	push   %ebp
8010867a:	89 e5                	mov    %esp,%ebp
8010867c:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010867f:	83 ec 04             	sub    $0x4,%esp
80108682:	6a 00                	push   $0x0
80108684:	ff 75 0c             	push   0xc(%ebp)
80108687:	ff 75 08             	push   0x8(%ebp)
8010868a:	e8 93 f7 ff ff       	call   80107e22 <walkpgdir>
8010868f:	83 c4 10             	add    $0x10,%esp
80108692:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108695:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108698:	8b 00                	mov    (%eax),%eax
8010869a:	83 e0 01             	and    $0x1,%eax
8010869d:	85 c0                	test   %eax,%eax
8010869f:	75 07                	jne    801086a8 <uva2ka+0x2f>
    return 0;
801086a1:	b8 00 00 00 00       	mov    $0x0,%eax
801086a6:	eb 2a                	jmp    801086d2 <uva2ka+0x59>
  if((*pte & PTE_U) == 0)
801086a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ab:	8b 00                	mov    (%eax),%eax
801086ad:	83 e0 04             	and    $0x4,%eax
801086b0:	85 c0                	test   %eax,%eax
801086b2:	75 07                	jne    801086bb <uva2ka+0x42>
    return 0;
801086b4:	b8 00 00 00 00       	mov    $0x0,%eax
801086b9:	eb 17                	jmp    801086d2 <uva2ka+0x59>
  return (char*)p2v(PTE_ADDR(*pte));
801086bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086be:	8b 00                	mov    (%eax),%eax
801086c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086c5:	83 ec 0c             	sub    $0xc,%esp
801086c8:	50                   	push   %eax
801086c9:	e8 d2 f2 ff ff       	call   801079a0 <p2v>
801086ce:	83 c4 10             	add    $0x10,%esp
801086d1:	90                   	nop
}
801086d2:	c9                   	leave  
801086d3:	c3                   	ret    

801086d4 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801086d4:	55                   	push   %ebp
801086d5:	89 e5                	mov    %esp,%ebp
801086d7:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801086da:	8b 45 10             	mov    0x10(%ebp),%eax
801086dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801086e0:	eb 7f                	jmp    80108761 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801086e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801086e5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086ea:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801086ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f0:	83 ec 08             	sub    $0x8,%esp
801086f3:	50                   	push   %eax
801086f4:	ff 75 08             	push   0x8(%ebp)
801086f7:	e8 7d ff ff ff       	call   80108679 <uva2ka>
801086fc:	83 c4 10             	add    $0x10,%esp
801086ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108702:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108706:	75 07                	jne    8010870f <copyout+0x3b>
      return -1;
80108708:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010870d:	eb 61                	jmp    80108770 <copyout+0x9c>
    n = PGSIZE - (va - va0);
8010870f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108712:	2b 45 0c             	sub    0xc(%ebp),%eax
80108715:	05 00 10 00 00       	add    $0x1000,%eax
8010871a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010871d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108720:	3b 45 14             	cmp    0x14(%ebp),%eax
80108723:	76 06                	jbe    8010872b <copyout+0x57>
      n = len;
80108725:	8b 45 14             	mov    0x14(%ebp),%eax
80108728:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
8010872b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010872e:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108731:	89 c2                	mov    %eax,%edx
80108733:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108736:	01 d0                	add    %edx,%eax
80108738:	83 ec 04             	sub    $0x4,%esp
8010873b:	ff 75 f0             	push   -0x10(%ebp)
8010873e:	ff 75 f4             	push   -0xc(%ebp)
80108741:	50                   	push   %eax
80108742:	e8 64 cc ff ff       	call   801053ab <memmove>
80108747:	83 c4 10             	add    $0x10,%esp
    len -= n;
8010874a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010874d:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108750:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108753:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108756:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108759:	05 00 10 00 00       	add    $0x1000,%eax
8010875e:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80108761:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108765:	0f 85 77 ff ff ff    	jne    801086e2 <copyout+0xe>
  }
  return 0;
8010876b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108770:	c9                   	leave  
80108771:	c3                   	ret    
