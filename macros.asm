print macro p1
pusha

mov ah,09h          ;Function(print string)
mov dx,offset p1         ;DX = String terminated by "$"
int 21h

popa           ;Interruptions DOS Functions
endm

convertirString macro buffer
LOCAL Dividir,Dividir2,FinCr3,NEGATIVO,FIN2,FIN
xor si,si
xor cx,cx
xor bx,bx
xor dx,dx
mov dl,0ah
test ax,1000000000000000
jnz NEGATIVO
jmp Dividir2

NEGATIVO:
neg ax
mov buffer[si],45
inc si
jmp Dividir2

Dividir:
xor ah,ah
Dividir2:
div dl
inc cx
push ax
cmp al,00h
je FinCr3
jmp Dividir

FinCr3:
pop ax
add ah,30h
mov buffer[si],ah
inc si
Loop FinCr3
mov ah,24h
mov buffer[si],ah
inc si
FIN:
endm

convertirAscii macro numero
LOCAL INICIO,FIN
push cx
push si

xor ax,ax
xor bx,bx
xor cx,cx
mov bx,10
xor si,si
INICIO:
mov cl,numero[si]
cmp cl,48
jl FIN
cmp cl,57
jg FIN
inc si
sub cl,48
mul bx
add ax,cx
jmp INICIO
FIN:
pop si
pop cx
endm

pushear macro
  push ax
  push bx
  push cx
  push dx
  push si
  push di
endm

popear macro
  pop di
  pop si
  pop dx
  pop cx
  pop bx
  pop ax
endm
