
_init:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:

char *argv[] = { "sh", 0 };

int
main(void)
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	push   -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  set_page_allocator(1);
  11:	83 ec 0c             	sub    $0xc,%esp
  14:	6a 01                	push   $0x1
  16:	e8 f2 03 00 00       	call   40d <set_page_allocator>
  1b:	83 c4 10             	add    $0x10,%esp
  int pid, wpid;

  if(open("console", O_RDWR) < 0){
  1e:	83 ec 08             	sub    $0x8,%esp
  21:	6a 02                	push   $0x2
  23:	68 b3 08 00 00       	push   $0x8b3
  28:	e8 78 03 00 00       	call   3a5 <open>
  2d:	83 c4 10             	add    $0x10,%esp
  30:	85 c0                	test   %eax,%eax
  32:	79 26                	jns    5a <main+0x5a>
    mknod("console", 1, 1);
  34:	83 ec 04             	sub    $0x4,%esp
  37:	6a 01                	push   $0x1
  39:	6a 01                	push   $0x1
  3b:	68 b3 08 00 00       	push   $0x8b3
  40:	e8 68 03 00 00       	call   3ad <mknod>
  45:	83 c4 10             	add    $0x10,%esp
    open("console", O_RDWR);
  48:	83 ec 08             	sub    $0x8,%esp
  4b:	6a 02                	push   $0x2
  4d:	68 b3 08 00 00       	push   $0x8b3
  52:	e8 4e 03 00 00       	call   3a5 <open>
  57:	83 c4 10             	add    $0x10,%esp
  }
  dup(0);  // stdout
  5a:	83 ec 0c             	sub    $0xc,%esp
  5d:	6a 00                	push   $0x0
  5f:	e8 79 03 00 00       	call   3dd <dup>
  64:	83 c4 10             	add    $0x10,%esp
  dup(0);  // stderr
  67:	83 ec 0c             	sub    $0xc,%esp
  6a:	6a 00                	push   $0x0
  6c:	e8 6c 03 00 00       	call   3dd <dup>
  71:	83 c4 10             	add    $0x10,%esp

  for(;;){
    printf(1, "init: starting sh\n");
  74:	83 ec 08             	sub    $0x8,%esp
  77:	68 bb 08 00 00       	push   $0x8bb
  7c:	6a 01                	push   $0x1
  7e:	e8 76 04 00 00       	call   4f9 <printf>
  83:	83 c4 10             	add    $0x10,%esp
    pid = fork();
  86:	e8 d2 02 00 00       	call   35d <fork>
  8b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(pid < 0){
  8e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  92:	79 17                	jns    ab <main+0xab>
      printf(1, "init: fork failed\n");
  94:	83 ec 08             	sub    $0x8,%esp
  97:	68 ce 08 00 00       	push   $0x8ce
  9c:	6a 01                	push   $0x1
  9e:	e8 56 04 00 00       	call   4f9 <printf>
  a3:	83 c4 10             	add    $0x10,%esp
      exit();
  a6:	e8 ba 02 00 00       	call   365 <exit>
    }
    if(pid == 0){
  ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  af:	75 3e                	jne    ef <main+0xef>
      exec("sh", argv);
  b1:	83 ec 08             	sub    $0x8,%esp
  b4:	68 4c 0b 00 00       	push   $0xb4c
  b9:	68 b0 08 00 00       	push   $0x8b0
  be:	e8 da 02 00 00       	call   39d <exec>
  c3:	83 c4 10             	add    $0x10,%esp
      printf(1, "init: exec sh failed\n");
  c6:	83 ec 08             	sub    $0x8,%esp
  c9:	68 e1 08 00 00       	push   $0x8e1
  ce:	6a 01                	push   $0x1
  d0:	e8 24 04 00 00       	call   4f9 <printf>
  d5:	83 c4 10             	add    $0x10,%esp
      exit();
  d8:	e8 88 02 00 00       	call   365 <exit>
    }
    while((wpid=wait()) >= 0 && wpid != pid)
      printf(1, "zombie!\n");
  dd:	83 ec 08             	sub    $0x8,%esp
  e0:	68 f7 08 00 00       	push   $0x8f7
  e5:	6a 01                	push   $0x1
  e7:	e8 0d 04 00 00       	call   4f9 <printf>
  ec:	83 c4 10             	add    $0x10,%esp
    while((wpid=wait()) >= 0 && wpid != pid)
  ef:	e8 79 02 00 00       	call   36d <wait>
  f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  fb:	0f 88 73 ff ff ff    	js     74 <main+0x74>
 101:	8b 45 f0             	mov    -0x10(%ebp),%eax
 104:	3b 45 f4             	cmp    -0xc(%ebp),%eax
 107:	75 d4                	jne    dd <main+0xdd>
    printf(1, "init: starting sh\n");
 109:	e9 66 ff ff ff       	jmp    74 <main+0x74>

0000010e <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 10e:	55                   	push   %ebp
 10f:	89 e5                	mov    %esp,%ebp
 111:	57                   	push   %edi
 112:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 113:	8b 4d 08             	mov    0x8(%ebp),%ecx
 116:	8b 55 10             	mov    0x10(%ebp),%edx
 119:	8b 45 0c             	mov    0xc(%ebp),%eax
 11c:	89 cb                	mov    %ecx,%ebx
 11e:	89 df                	mov    %ebx,%edi
 120:	89 d1                	mov    %edx,%ecx
 122:	fc                   	cld    
 123:	f3 aa                	rep stos %al,%es:(%edi)
 125:	89 ca                	mov    %ecx,%edx
 127:	89 fb                	mov    %edi,%ebx
 129:	89 5d 08             	mov    %ebx,0x8(%ebp)
 12c:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 12f:	90                   	nop
 130:	5b                   	pop    %ebx
 131:	5f                   	pop    %edi
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13a:	8b 45 08             	mov    0x8(%ebp),%eax
 13d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 140:	90                   	nop
 141:	8b 55 0c             	mov    0xc(%ebp),%edx
 144:	8d 42 01             	lea    0x1(%edx),%eax
 147:	89 45 0c             	mov    %eax,0xc(%ebp)
 14a:	8b 45 08             	mov    0x8(%ebp),%eax
 14d:	8d 48 01             	lea    0x1(%eax),%ecx
 150:	89 4d 08             	mov    %ecx,0x8(%ebp)
 153:	0f b6 12             	movzbl (%edx),%edx
 156:	88 10                	mov    %dl,(%eax)
 158:	0f b6 00             	movzbl (%eax),%eax
 15b:	84 c0                	test   %al,%al
 15d:	75 e2                	jne    141 <strcpy+0xd>
    ;
  return os;
 15f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 162:	c9                   	leave  
 163:	c3                   	ret    

00000164 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 167:	eb 08                	jmp    171 <strcmp+0xd>
    p++, q++;
 169:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 171:	8b 45 08             	mov    0x8(%ebp),%eax
 174:	0f b6 00             	movzbl (%eax),%eax
 177:	84 c0                	test   %al,%al
 179:	74 10                	je     18b <strcmp+0x27>
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	0f b6 10             	movzbl (%eax),%edx
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	0f b6 00             	movzbl (%eax),%eax
 187:	38 c2                	cmp    %al,%dl
 189:	74 de                	je     169 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	0f b6 00             	movzbl (%eax),%eax
 191:	0f b6 d0             	movzbl %al,%edx
 194:	8b 45 0c             	mov    0xc(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	0f b6 c8             	movzbl %al,%ecx
 19d:	89 d0                	mov    %edx,%eax
 19f:	29 c8                	sub    %ecx,%eax
}
 1a1:	5d                   	pop    %ebp
 1a2:	c3                   	ret    

000001a3 <strlen>:

uint
strlen(char *s)
{
 1a3:	55                   	push   %ebp
 1a4:	89 e5                	mov    %esp,%ebp
 1a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1b0:	eb 04                	jmp    1b6 <strlen+0x13>
 1b2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 1b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b9:	8b 45 08             	mov    0x8(%ebp),%eax
 1bc:	01 d0                	add    %edx,%eax
 1be:	0f b6 00             	movzbl (%eax),%eax
 1c1:	84 c0                	test   %al,%al
 1c3:	75 ed                	jne    1b2 <strlen+0xf>
    ;
  return n;
 1c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c8:	c9                   	leave  
 1c9:	c3                   	ret    

000001ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 1ca:	55                   	push   %ebp
 1cb:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 1cd:	8b 45 10             	mov    0x10(%ebp),%eax
 1d0:	50                   	push   %eax
 1d1:	ff 75 0c             	push   0xc(%ebp)
 1d4:	ff 75 08             	push   0x8(%ebp)
 1d7:	e8 32 ff ff ff       	call   10e <stosb>
 1dc:	83 c4 0c             	add    $0xc,%esp
  return dst;
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e2:	c9                   	leave  
 1e3:	c3                   	ret    

000001e4 <strchr>:

char*
strchr(const char *s, char c)
{
 1e4:	55                   	push   %ebp
 1e5:	89 e5                	mov    %esp,%ebp
 1e7:	83 ec 04             	sub    $0x4,%esp
 1ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f0:	eb 14                	jmp    206 <strchr+0x22>
    if(*s == c)
 1f2:	8b 45 08             	mov    0x8(%ebp),%eax
 1f5:	0f b6 00             	movzbl (%eax),%eax
 1f8:	38 45 fc             	cmp    %al,-0x4(%ebp)
 1fb:	75 05                	jne    202 <strchr+0x1e>
      return (char*)s;
 1fd:	8b 45 08             	mov    0x8(%ebp),%eax
 200:	eb 13                	jmp    215 <strchr+0x31>
  for(; *s; s++)
 202:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 206:	8b 45 08             	mov    0x8(%ebp),%eax
 209:	0f b6 00             	movzbl (%eax),%eax
 20c:	84 c0                	test   %al,%al
 20e:	75 e2                	jne    1f2 <strchr+0xe>
  return 0;
 210:	b8 00 00 00 00       	mov    $0x0,%eax
}
 215:	c9                   	leave  
 216:	c3                   	ret    

00000217 <gets>:

char*
gets(char *buf, int max)
{
 217:	55                   	push   %ebp
 218:	89 e5                	mov    %esp,%ebp
 21a:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 224:	eb 42                	jmp    268 <gets+0x51>
    cc = read(0, &c, 1);
 226:	83 ec 04             	sub    $0x4,%esp
 229:	6a 01                	push   $0x1
 22b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 22e:	50                   	push   %eax
 22f:	6a 00                	push   $0x0
 231:	e8 47 01 00 00       	call   37d <read>
 236:	83 c4 10             	add    $0x10,%esp
 239:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 23c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 240:	7e 33                	jle    275 <gets+0x5e>
      break;
    buf[i++] = c;
 242:	8b 45 f4             	mov    -0xc(%ebp),%eax
 245:	8d 50 01             	lea    0x1(%eax),%edx
 248:	89 55 f4             	mov    %edx,-0xc(%ebp)
 24b:	89 c2                	mov    %eax,%edx
 24d:	8b 45 08             	mov    0x8(%ebp),%eax
 250:	01 c2                	add    %eax,%edx
 252:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 256:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 258:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 25c:	3c 0a                	cmp    $0xa,%al
 25e:	74 16                	je     276 <gets+0x5f>
 260:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 264:	3c 0d                	cmp    $0xd,%al
 266:	74 0e                	je     276 <gets+0x5f>
  for(i=0; i+1 < max; ){
 268:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26b:	83 c0 01             	add    $0x1,%eax
 26e:	39 45 0c             	cmp    %eax,0xc(%ebp)
 271:	7f b3                	jg     226 <gets+0xf>
 273:	eb 01                	jmp    276 <gets+0x5f>
      break;
 275:	90                   	nop
      break;
  }
  buf[i] = '\0';
 276:	8b 55 f4             	mov    -0xc(%ebp),%edx
 279:	8b 45 08             	mov    0x8(%ebp),%eax
 27c:	01 d0                	add    %edx,%eax
 27e:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 281:	8b 45 08             	mov    0x8(%ebp),%eax
}
 284:	c9                   	leave  
 285:	c3                   	ret    

00000286 <stat>:

int
stat(char *n, struct stat *st)
{
 286:	55                   	push   %ebp
 287:	89 e5                	mov    %esp,%ebp
 289:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28c:	83 ec 08             	sub    $0x8,%esp
 28f:	6a 00                	push   $0x0
 291:	ff 75 08             	push   0x8(%ebp)
 294:	e8 0c 01 00 00       	call   3a5 <open>
 299:	83 c4 10             	add    $0x10,%esp
 29c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 29f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a3:	79 07                	jns    2ac <stat+0x26>
    return -1;
 2a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2aa:	eb 25                	jmp    2d1 <stat+0x4b>
  r = fstat(fd, st);
 2ac:	83 ec 08             	sub    $0x8,%esp
 2af:	ff 75 0c             	push   0xc(%ebp)
 2b2:	ff 75 f4             	push   -0xc(%ebp)
 2b5:	e8 03 01 00 00       	call   3bd <fstat>
 2ba:	83 c4 10             	add    $0x10,%esp
 2bd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c0:	83 ec 0c             	sub    $0xc,%esp
 2c3:	ff 75 f4             	push   -0xc(%ebp)
 2c6:	e8 c2 00 00 00       	call   38d <close>
 2cb:	83 c4 10             	add    $0x10,%esp
  return r;
 2ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d1:	c9                   	leave  
 2d2:	c3                   	ret    

000002d3 <atoi>:

int
atoi(const char *s)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e0:	eb 25                	jmp    307 <atoi+0x34>
    n = n*10 + *s++ - '0';
 2e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e5:	89 d0                	mov    %edx,%eax
 2e7:	c1 e0 02             	shl    $0x2,%eax
 2ea:	01 d0                	add    %edx,%eax
 2ec:	01 c0                	add    %eax,%eax
 2ee:	89 c1                	mov    %eax,%ecx
 2f0:	8b 45 08             	mov    0x8(%ebp),%eax
 2f3:	8d 50 01             	lea    0x1(%eax),%edx
 2f6:	89 55 08             	mov    %edx,0x8(%ebp)
 2f9:	0f b6 00             	movzbl (%eax),%eax
 2fc:	0f be c0             	movsbl %al,%eax
 2ff:	01 c8                	add    %ecx,%eax
 301:	83 e8 30             	sub    $0x30,%eax
 304:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 307:	8b 45 08             	mov    0x8(%ebp),%eax
 30a:	0f b6 00             	movzbl (%eax),%eax
 30d:	3c 2f                	cmp    $0x2f,%al
 30f:	7e 0a                	jle    31b <atoi+0x48>
 311:	8b 45 08             	mov    0x8(%ebp),%eax
 314:	0f b6 00             	movzbl (%eax),%eax
 317:	3c 39                	cmp    $0x39,%al
 319:	7e c7                	jle    2e2 <atoi+0xf>
  return n;
 31b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31e:	c9                   	leave  
 31f:	c3                   	ret    

00000320 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 320:	55                   	push   %ebp
 321:	89 e5                	mov    %esp,%ebp
 323:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 326:	8b 45 08             	mov    0x8(%ebp),%eax
 329:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 32c:	8b 45 0c             	mov    0xc(%ebp),%eax
 32f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 332:	eb 17                	jmp    34b <memmove+0x2b>
    *dst++ = *src++;
 334:	8b 55 f8             	mov    -0x8(%ebp),%edx
 337:	8d 42 01             	lea    0x1(%edx),%eax
 33a:	89 45 f8             	mov    %eax,-0x8(%ebp)
 33d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 340:	8d 48 01             	lea    0x1(%eax),%ecx
 343:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 346:	0f b6 12             	movzbl (%edx),%edx
 349:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 34b:	8b 45 10             	mov    0x10(%ebp),%eax
 34e:	8d 50 ff             	lea    -0x1(%eax),%edx
 351:	89 55 10             	mov    %edx,0x10(%ebp)
 354:	85 c0                	test   %eax,%eax
 356:	7f dc                	jg     334 <memmove+0x14>
  return vdst;
 358:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35b:	c9                   	leave  
 35c:	c3                   	ret    

0000035d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 35d:	b8 01 00 00 00       	mov    $0x1,%eax
 362:	cd 40                	int    $0x40
 364:	c3                   	ret    

00000365 <exit>:
SYSCALL(exit)
 365:	b8 02 00 00 00       	mov    $0x2,%eax
 36a:	cd 40                	int    $0x40
 36c:	c3                   	ret    

0000036d <wait>:
SYSCALL(wait)
 36d:	b8 03 00 00 00       	mov    $0x3,%eax
 372:	cd 40                	int    $0x40
 374:	c3                   	ret    

00000375 <pipe>:
SYSCALL(pipe)
 375:	b8 04 00 00 00       	mov    $0x4,%eax
 37a:	cd 40                	int    $0x40
 37c:	c3                   	ret    

0000037d <read>:
SYSCALL(read)
 37d:	b8 05 00 00 00       	mov    $0x5,%eax
 382:	cd 40                	int    $0x40
 384:	c3                   	ret    

00000385 <write>:
SYSCALL(write)
 385:	b8 10 00 00 00       	mov    $0x10,%eax
 38a:	cd 40                	int    $0x40
 38c:	c3                   	ret    

0000038d <close>:
SYSCALL(close)
 38d:	b8 15 00 00 00       	mov    $0x15,%eax
 392:	cd 40                	int    $0x40
 394:	c3                   	ret    

00000395 <kill>:
SYSCALL(kill)
 395:	b8 06 00 00 00       	mov    $0x6,%eax
 39a:	cd 40                	int    $0x40
 39c:	c3                   	ret    

0000039d <exec>:
SYSCALL(exec)
 39d:	b8 07 00 00 00       	mov    $0x7,%eax
 3a2:	cd 40                	int    $0x40
 3a4:	c3                   	ret    

000003a5 <open>:
SYSCALL(open)
 3a5:	b8 0f 00 00 00       	mov    $0xf,%eax
 3aa:	cd 40                	int    $0x40
 3ac:	c3                   	ret    

000003ad <mknod>:
SYSCALL(mknod)
 3ad:	b8 11 00 00 00       	mov    $0x11,%eax
 3b2:	cd 40                	int    $0x40
 3b4:	c3                   	ret    

000003b5 <unlink>:
SYSCALL(unlink)
 3b5:	b8 12 00 00 00       	mov    $0x12,%eax
 3ba:	cd 40                	int    $0x40
 3bc:	c3                   	ret    

000003bd <fstat>:
SYSCALL(fstat)
 3bd:	b8 08 00 00 00       	mov    $0x8,%eax
 3c2:	cd 40                	int    $0x40
 3c4:	c3                   	ret    

000003c5 <link>:
SYSCALL(link)
 3c5:	b8 13 00 00 00       	mov    $0x13,%eax
 3ca:	cd 40                	int    $0x40
 3cc:	c3                   	ret    

000003cd <mkdir>:
SYSCALL(mkdir)
 3cd:	b8 14 00 00 00       	mov    $0x14,%eax
 3d2:	cd 40                	int    $0x40
 3d4:	c3                   	ret    

000003d5 <chdir>:
SYSCALL(chdir)
 3d5:	b8 09 00 00 00       	mov    $0x9,%eax
 3da:	cd 40                	int    $0x40
 3dc:	c3                   	ret    

000003dd <dup>:
SYSCALL(dup)
 3dd:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e2:	cd 40                	int    $0x40
 3e4:	c3                   	ret    

000003e5 <getpid>:
SYSCALL(getpid)
 3e5:	b8 0b 00 00 00       	mov    $0xb,%eax
 3ea:	cd 40                	int    $0x40
 3ec:	c3                   	ret    

000003ed <sbrk>:
SYSCALL(sbrk)
 3ed:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f2:	cd 40                	int    $0x40
 3f4:	c3                   	ret    

000003f5 <sleep>:
SYSCALL(sleep)
 3f5:	b8 0d 00 00 00       	mov    $0xd,%eax
 3fa:	cd 40                	int    $0x40
 3fc:	c3                   	ret    

000003fd <uptime>:
SYSCALL(uptime)
 3fd:	b8 0e 00 00 00       	mov    $0xe,%eax
 402:	cd 40                	int    $0x40
 404:	c3                   	ret    

00000405 <print_free_frame_cnt>:
SYSCALL(print_free_frame_cnt)  //CS 3320 project 2
 405:	b8 17 00 00 00       	mov    $0x17,%eax
 40a:	cd 40                	int    $0x40
 40c:	c3                   	ret    

0000040d <set_page_allocator>:
SYSCALL(set_page_allocator) // CS 3320 project 2
 40d:	b8 18 00 00 00       	mov    $0x18,%eax
 412:	cd 40                	int    $0x40
 414:	c3                   	ret    

00000415 <shmget>:
SYSCALL(shmget) // CS 3320 project 2
 415:	b8 19 00 00 00       	mov    $0x19,%eax
 41a:	cd 40                	int    $0x40
 41c:	c3                   	ret    

0000041d <shmdel>:
SYSCALL(shmdel) // CS3320 project 2
 41d:	b8 1a 00 00 00       	mov    $0x1a,%eax
 422:	cd 40                	int    $0x40
 424:	c3                   	ret    

00000425 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 425:	55                   	push   %ebp
 426:	89 e5                	mov    %esp,%ebp
 428:	83 ec 18             	sub    $0x18,%esp
 42b:	8b 45 0c             	mov    0xc(%ebp),%eax
 42e:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 431:	83 ec 04             	sub    $0x4,%esp
 434:	6a 01                	push   $0x1
 436:	8d 45 f4             	lea    -0xc(%ebp),%eax
 439:	50                   	push   %eax
 43a:	ff 75 08             	push   0x8(%ebp)
 43d:	e8 43 ff ff ff       	call   385 <write>
 442:	83 c4 10             	add    $0x10,%esp
}
 445:	90                   	nop
 446:	c9                   	leave  
 447:	c3                   	ret    

00000448 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 448:	55                   	push   %ebp
 449:	89 e5                	mov    %esp,%ebp
 44b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 44e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 455:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 459:	74 17                	je     472 <printint+0x2a>
 45b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 45f:	79 11                	jns    472 <printint+0x2a>
    neg = 1;
 461:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 468:	8b 45 0c             	mov    0xc(%ebp),%eax
 46b:	f7 d8                	neg    %eax
 46d:	89 45 ec             	mov    %eax,-0x14(%ebp)
 470:	eb 06                	jmp    478 <printint+0x30>
  } else {
    x = xx;
 472:	8b 45 0c             	mov    0xc(%ebp),%eax
 475:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 478:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 47f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 482:	8b 45 ec             	mov    -0x14(%ebp),%eax
 485:	ba 00 00 00 00       	mov    $0x0,%edx
 48a:	f7 f1                	div    %ecx
 48c:	89 d1                	mov    %edx,%ecx
 48e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 491:	8d 50 01             	lea    0x1(%eax),%edx
 494:	89 55 f4             	mov    %edx,-0xc(%ebp)
 497:	0f b6 91 54 0b 00 00 	movzbl 0xb54(%ecx),%edx
 49e:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 4a2:	8b 4d 10             	mov    0x10(%ebp),%ecx
 4a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4a8:	ba 00 00 00 00       	mov    $0x0,%edx
 4ad:	f7 f1                	div    %ecx
 4af:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4b2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4b6:	75 c7                	jne    47f <printint+0x37>
  if(neg)
 4b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4bc:	74 2d                	je     4eb <printint+0xa3>
    buf[i++] = '-';
 4be:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c1:	8d 50 01             	lea    0x1(%eax),%edx
 4c4:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4c7:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4cc:	eb 1d                	jmp    4eb <printint+0xa3>
    putc(fd, buf[i]);
 4ce:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4d4:	01 d0                	add    %edx,%eax
 4d6:	0f b6 00             	movzbl (%eax),%eax
 4d9:	0f be c0             	movsbl %al,%eax
 4dc:	83 ec 08             	sub    $0x8,%esp
 4df:	50                   	push   %eax
 4e0:	ff 75 08             	push   0x8(%ebp)
 4e3:	e8 3d ff ff ff       	call   425 <putc>
 4e8:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 4eb:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 4ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4f3:	79 d9                	jns    4ce <printint+0x86>
}
 4f5:	90                   	nop
 4f6:	90                   	nop
 4f7:	c9                   	leave  
 4f8:	c3                   	ret    

000004f9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 4f9:	55                   	push   %ebp
 4fa:	89 e5                	mov    %esp,%ebp
 4fc:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 4ff:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 506:	8d 45 0c             	lea    0xc(%ebp),%eax
 509:	83 c0 04             	add    $0x4,%eax
 50c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 50f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 516:	e9 59 01 00 00       	jmp    674 <printf+0x17b>
    c = fmt[i] & 0xff;
 51b:	8b 55 0c             	mov    0xc(%ebp),%edx
 51e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 521:	01 d0                	add    %edx,%eax
 523:	0f b6 00             	movzbl (%eax),%eax
 526:	0f be c0             	movsbl %al,%eax
 529:	25 ff 00 00 00       	and    $0xff,%eax
 52e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 531:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 535:	75 2c                	jne    563 <printf+0x6a>
      if(c == '%'){
 537:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 53b:	75 0c                	jne    549 <printf+0x50>
        state = '%';
 53d:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 544:	e9 27 01 00 00       	jmp    670 <printf+0x177>
      } else {
        putc(fd, c);
 549:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 54c:	0f be c0             	movsbl %al,%eax
 54f:	83 ec 08             	sub    $0x8,%esp
 552:	50                   	push   %eax
 553:	ff 75 08             	push   0x8(%ebp)
 556:	e8 ca fe ff ff       	call   425 <putc>
 55b:	83 c4 10             	add    $0x10,%esp
 55e:	e9 0d 01 00 00       	jmp    670 <printf+0x177>
      }
    } else if(state == '%'){
 563:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 567:	0f 85 03 01 00 00    	jne    670 <printf+0x177>
      if(c == 'd'){
 56d:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 571:	75 1e                	jne    591 <printf+0x98>
        printint(fd, *ap, 10, 1);
 573:	8b 45 e8             	mov    -0x18(%ebp),%eax
 576:	8b 00                	mov    (%eax),%eax
 578:	6a 01                	push   $0x1
 57a:	6a 0a                	push   $0xa
 57c:	50                   	push   %eax
 57d:	ff 75 08             	push   0x8(%ebp)
 580:	e8 c3 fe ff ff       	call   448 <printint>
 585:	83 c4 10             	add    $0x10,%esp
        ap++;
 588:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 58c:	e9 d8 00 00 00       	jmp    669 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 591:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 595:	74 06                	je     59d <printf+0xa4>
 597:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 59b:	75 1e                	jne    5bb <printf+0xc2>
        printint(fd, *ap, 16, 0);
 59d:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5a0:	8b 00                	mov    (%eax),%eax
 5a2:	6a 00                	push   $0x0
 5a4:	6a 10                	push   $0x10
 5a6:	50                   	push   %eax
 5a7:	ff 75 08             	push   0x8(%ebp)
 5aa:	e8 99 fe ff ff       	call   448 <printint>
 5af:	83 c4 10             	add    $0x10,%esp
        ap++;
 5b2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5b6:	e9 ae 00 00 00       	jmp    669 <printf+0x170>
      } else if(c == 's'){
 5bb:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5bf:	75 43                	jne    604 <printf+0x10b>
        s = (char*)*ap;
 5c1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5c4:	8b 00                	mov    (%eax),%eax
 5c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5c9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5d1:	75 25                	jne    5f8 <printf+0xff>
          s = "(null)";
 5d3:	c7 45 f4 00 09 00 00 	movl   $0x900,-0xc(%ebp)
        while(*s != 0){
 5da:	eb 1c                	jmp    5f8 <printf+0xff>
          putc(fd, *s);
 5dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5df:	0f b6 00             	movzbl (%eax),%eax
 5e2:	0f be c0             	movsbl %al,%eax
 5e5:	83 ec 08             	sub    $0x8,%esp
 5e8:	50                   	push   %eax
 5e9:	ff 75 08             	push   0x8(%ebp)
 5ec:	e8 34 fe ff ff       	call   425 <putc>
 5f1:	83 c4 10             	add    $0x10,%esp
          s++;
 5f4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 5f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5fb:	0f b6 00             	movzbl (%eax),%eax
 5fe:	84 c0                	test   %al,%al
 600:	75 da                	jne    5dc <printf+0xe3>
 602:	eb 65                	jmp    669 <printf+0x170>
        }
      } else if(c == 'c'){
 604:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 608:	75 1d                	jne    627 <printf+0x12e>
        putc(fd, *ap);
 60a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 60d:	8b 00                	mov    (%eax),%eax
 60f:	0f be c0             	movsbl %al,%eax
 612:	83 ec 08             	sub    $0x8,%esp
 615:	50                   	push   %eax
 616:	ff 75 08             	push   0x8(%ebp)
 619:	e8 07 fe ff ff       	call   425 <putc>
 61e:	83 c4 10             	add    $0x10,%esp
        ap++;
 621:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 625:	eb 42                	jmp    669 <printf+0x170>
      } else if(c == '%'){
 627:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 62b:	75 17                	jne    644 <printf+0x14b>
        putc(fd, c);
 62d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 630:	0f be c0             	movsbl %al,%eax
 633:	83 ec 08             	sub    $0x8,%esp
 636:	50                   	push   %eax
 637:	ff 75 08             	push   0x8(%ebp)
 63a:	e8 e6 fd ff ff       	call   425 <putc>
 63f:	83 c4 10             	add    $0x10,%esp
 642:	eb 25                	jmp    669 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 644:	83 ec 08             	sub    $0x8,%esp
 647:	6a 25                	push   $0x25
 649:	ff 75 08             	push   0x8(%ebp)
 64c:	e8 d4 fd ff ff       	call   425 <putc>
 651:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 654:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 657:	0f be c0             	movsbl %al,%eax
 65a:	83 ec 08             	sub    $0x8,%esp
 65d:	50                   	push   %eax
 65e:	ff 75 08             	push   0x8(%ebp)
 661:	e8 bf fd ff ff       	call   425 <putc>
 666:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 669:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 670:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 674:	8b 55 0c             	mov    0xc(%ebp),%edx
 677:	8b 45 f0             	mov    -0x10(%ebp),%eax
 67a:	01 d0                	add    %edx,%eax
 67c:	0f b6 00             	movzbl (%eax),%eax
 67f:	84 c0                	test   %al,%al
 681:	0f 85 94 fe ff ff    	jne    51b <printf+0x22>
    }
  }
}
 687:	90                   	nop
 688:	90                   	nop
 689:	c9                   	leave  
 68a:	c3                   	ret    

0000068b <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 68b:	55                   	push   %ebp
 68c:	89 e5                	mov    %esp,%ebp
 68e:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 691:	8b 45 08             	mov    0x8(%ebp),%eax
 694:	83 e8 08             	sub    $0x8,%eax
 697:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 69a:	a1 70 0b 00 00       	mov    0xb70,%eax
 69f:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6a2:	eb 24                	jmp    6c8 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a7:	8b 00                	mov    (%eax),%eax
 6a9:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 6ac:	72 12                	jb     6c0 <free+0x35>
 6ae:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6b4:	77 24                	ja     6da <free+0x4f>
 6b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b9:	8b 00                	mov    (%eax),%eax
 6bb:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6be:	72 1a                	jb     6da <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c3:	8b 00                	mov    (%eax),%eax
 6c5:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6cb:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6ce:	76 d4                	jbe    6a4 <free+0x19>
 6d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d3:	8b 00                	mov    (%eax),%eax
 6d5:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 6d8:	73 ca                	jae    6a4 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6da:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6dd:	8b 40 04             	mov    0x4(%eax),%eax
 6e0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6ea:	01 c2                	add    %eax,%edx
 6ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ef:	8b 00                	mov    (%eax),%eax
 6f1:	39 c2                	cmp    %eax,%edx
 6f3:	75 24                	jne    719 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 6f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f8:	8b 50 04             	mov    0x4(%eax),%edx
 6fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fe:	8b 00                	mov    (%eax),%eax
 700:	8b 40 04             	mov    0x4(%eax),%eax
 703:	01 c2                	add    %eax,%edx
 705:	8b 45 f8             	mov    -0x8(%ebp),%eax
 708:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 70b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 70e:	8b 00                	mov    (%eax),%eax
 710:	8b 10                	mov    (%eax),%edx
 712:	8b 45 f8             	mov    -0x8(%ebp),%eax
 715:	89 10                	mov    %edx,(%eax)
 717:	eb 0a                	jmp    723 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 719:	8b 45 fc             	mov    -0x4(%ebp),%eax
 71c:	8b 10                	mov    (%eax),%edx
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 723:	8b 45 fc             	mov    -0x4(%ebp),%eax
 726:	8b 40 04             	mov    0x4(%eax),%eax
 729:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 730:	8b 45 fc             	mov    -0x4(%ebp),%eax
 733:	01 d0                	add    %edx,%eax
 735:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 738:	75 20                	jne    75a <free+0xcf>
    p->s.size += bp->s.size;
 73a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 73d:	8b 50 04             	mov    0x4(%eax),%edx
 740:	8b 45 f8             	mov    -0x8(%ebp),%eax
 743:	8b 40 04             	mov    0x4(%eax),%eax
 746:	01 c2                	add    %eax,%edx
 748:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 74e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 751:	8b 10                	mov    (%eax),%edx
 753:	8b 45 fc             	mov    -0x4(%ebp),%eax
 756:	89 10                	mov    %edx,(%eax)
 758:	eb 08                	jmp    762 <free+0xd7>
  } else
    p->s.ptr = bp;
 75a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75d:	8b 55 f8             	mov    -0x8(%ebp),%edx
 760:	89 10                	mov    %edx,(%eax)
  freep = p;
 762:	8b 45 fc             	mov    -0x4(%ebp),%eax
 765:	a3 70 0b 00 00       	mov    %eax,0xb70
}
 76a:	90                   	nop
 76b:	c9                   	leave  
 76c:	c3                   	ret    

0000076d <morecore>:

static Header*
morecore(uint nu)
{
 76d:	55                   	push   %ebp
 76e:	89 e5                	mov    %esp,%ebp
 770:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 773:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 77a:	77 07                	ja     783 <morecore+0x16>
    nu = 4096;
 77c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 783:	8b 45 08             	mov    0x8(%ebp),%eax
 786:	c1 e0 03             	shl    $0x3,%eax
 789:	83 ec 0c             	sub    $0xc,%esp
 78c:	50                   	push   %eax
 78d:	e8 5b fc ff ff       	call   3ed <sbrk>
 792:	83 c4 10             	add    $0x10,%esp
 795:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 798:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 79c:	75 07                	jne    7a5 <morecore+0x38>
    return 0;
 79e:	b8 00 00 00 00       	mov    $0x0,%eax
 7a3:	eb 26                	jmp    7cb <morecore+0x5e>
  hp = (Header*)p;
 7a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7ae:	8b 55 08             	mov    0x8(%ebp),%edx
 7b1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b7:	83 c0 08             	add    $0x8,%eax
 7ba:	83 ec 0c             	sub    $0xc,%esp
 7bd:	50                   	push   %eax
 7be:	e8 c8 fe ff ff       	call   68b <free>
 7c3:	83 c4 10             	add    $0x10,%esp
  return freep;
 7c6:	a1 70 0b 00 00       	mov    0xb70,%eax
}
 7cb:	c9                   	leave  
 7cc:	c3                   	ret    

000007cd <malloc>:

void*
malloc(uint nbytes)
{
 7cd:	55                   	push   %ebp
 7ce:	89 e5                	mov    %esp,%ebp
 7d0:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d3:	8b 45 08             	mov    0x8(%ebp),%eax
 7d6:	83 c0 07             	add    $0x7,%eax
 7d9:	c1 e8 03             	shr    $0x3,%eax
 7dc:	83 c0 01             	add    $0x1,%eax
 7df:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 7e2:	a1 70 0b 00 00       	mov    0xb70,%eax
 7e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ee:	75 23                	jne    813 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 7f0:	c7 45 f0 68 0b 00 00 	movl   $0xb68,-0x10(%ebp)
 7f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7fa:	a3 70 0b 00 00       	mov    %eax,0xb70
 7ff:	a1 70 0b 00 00       	mov    0xb70,%eax
 804:	a3 68 0b 00 00       	mov    %eax,0xb68
    base.s.size = 0;
 809:	c7 05 6c 0b 00 00 00 	movl   $0x0,0xb6c
 810:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 813:	8b 45 f0             	mov    -0x10(%ebp),%eax
 816:	8b 00                	mov    (%eax),%eax
 818:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 81b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81e:	8b 40 04             	mov    0x4(%eax),%eax
 821:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 824:	77 4d                	ja     873 <malloc+0xa6>
      if(p->s.size == nunits)
 826:	8b 45 f4             	mov    -0xc(%ebp),%eax
 829:	8b 40 04             	mov    0x4(%eax),%eax
 82c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 82f:	75 0c                	jne    83d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 831:	8b 45 f4             	mov    -0xc(%ebp),%eax
 834:	8b 10                	mov    (%eax),%edx
 836:	8b 45 f0             	mov    -0x10(%ebp),%eax
 839:	89 10                	mov    %edx,(%eax)
 83b:	eb 26                	jmp    863 <malloc+0x96>
      else {
        p->s.size -= nunits;
 83d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 840:	8b 40 04             	mov    0x4(%eax),%eax
 843:	2b 45 ec             	sub    -0x14(%ebp),%eax
 846:	89 c2                	mov    %eax,%edx
 848:	8b 45 f4             	mov    -0xc(%ebp),%eax
 84b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 84e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 851:	8b 40 04             	mov    0x4(%eax),%eax
 854:	c1 e0 03             	shl    $0x3,%eax
 857:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 85a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85d:	8b 55 ec             	mov    -0x14(%ebp),%edx
 860:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 863:	8b 45 f0             	mov    -0x10(%ebp),%eax
 866:	a3 70 0b 00 00       	mov    %eax,0xb70
      return (void*)(p + 1);
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	83 c0 08             	add    $0x8,%eax
 871:	eb 3b                	jmp    8ae <malloc+0xe1>
    }
    if(p == freep)
 873:	a1 70 0b 00 00       	mov    0xb70,%eax
 878:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 87b:	75 1e                	jne    89b <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 87d:	83 ec 0c             	sub    $0xc,%esp
 880:	ff 75 ec             	push   -0x14(%ebp)
 883:	e8 e5 fe ff ff       	call   76d <morecore>
 888:	83 c4 10             	add    $0x10,%esp
 88b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 88e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 892:	75 07                	jne    89b <malloc+0xce>
        return 0;
 894:	b8 00 00 00 00       	mov    $0x0,%eax
 899:	eb 13                	jmp    8ae <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 89b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 89e:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a4:	8b 00                	mov    (%eax),%eax
 8a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 8a9:	e9 6d ff ff ff       	jmp    81b <malloc+0x4e>
  }
}
 8ae:	c9                   	leave  
 8af:	c3                   	ret    
