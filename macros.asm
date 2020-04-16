print macro p1
pusha

mov ah,09h          ;Function(print string)
mov dx,offset p1         ;DX = String terminated by "$"
int 21h

popa           ;Interruptions DOS Functions
endm

pintarLlanta macro p1
LOCAL ciclo_pintar,sig_pix_pintar
mov dx,p1
mov cx,8
xor bx,bx
ciclo_pintar:
  mov [si],dx ; poner color en A000:DI
  inc si
  inc bx
  cmp bx,2
  jne sig_pix_pintar
            ; nueva fila
  xor bx,bx ; resetear contador de columnas
  add si,318
  sig_pix_pintar:
loop ciclo_pintar

endm

pintarCarcasa macro p1
LOCAL ciclo_pintar,sig_pix_pintar
mov dx,p1
mov cx,360
xor bx,bx
ciclo_pintar:
  mov [di],dx ; poner color en A000:DI
  inc di
  inc bx
  cmp bx,15
  jne sig_pix_pintar
            ; nueva fila
  xor bx,bx ; resetear contador de columnas
  add di,305
  sig_pix_pintar:
loop ciclo_pintar
endm

pintarObstaculo macro obsX,obsY,tipoObs
LOCAL ciclo_pintar_int,sig_pix_pintar_int,_bad,_p
pushear

cmp tipoObs,31h
je _bad
mov dx,43
jmp _p

_bad:
mov dx,02

_p:
;INTERIOR====================
mov ax,obsX
add ax,obsY
mov di,ax
sub di,3200
mov cx,100
xor bx,bx
ciclo_pintar_int:
  mov [di],dx ; poner color en A000:DI
  inc di
  inc bx
  cmp bx,10
  jne sig_pix_pintar_int
            ; nueva fila
  xor bx,bx ; resetear contador de columnas
  add di,310
  sig_pix_pintar_int:
loop ciclo_pintar_int

popear
endm

pintarFranjaPista macro p1,p2
LOCAL ciclo_pintar,sig_pix_pintar
pushear

xor ax,ax
xor bx,bx
xor cx,cx

mov cx,p1
mov di,p2
mov dx,29

ciclo_pintar:
  mov [di], dx ; poner color en A000:DI
  inc di
  inc bx
  cmp bx,150
  jne sig_pix_pintar
            ; nueva fila
  xor bx,bx ; resetear contador de columnas
  add di,170
  sig_pix_pintar:
  loop ciclo_pintar

popear
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

;-------------DELAY DOBLE LAZO RECURSIÓN
delay macro constante
LOCAL D1,D2,Fin
pushear

mov si,constante
D1:
dec si
jz Fin
mov di,constante
D2:
dec di
jnz D2
jmp D1

Fin:

popear
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
