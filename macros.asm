print macro p1
pushear

mov ah,09h          ;Function(print string)
mov dx,offset p1         ;DX = String terminated by "$"
int 21h

popear        ;Interruptions DOS Functions
endm

message macro mesi,long,color
mov ah,13h
mov al,01h
mov bh,00h
mov bl,color
lea bp,mesi
mov cl,long
int 10h
endm

poscur macro row,col
mov ah,02h
mov bh,00h
mov dh,row
mov dl,col
int 10h
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

cmp tipoObs,-3
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

resetVariables macro

mov posicionCarroX,148
mov posicionObstaculoX1,-1
mov posicionObstaculoY1,9600
mov tipoObstaculo1,-3
mov posicionObstaculoX2,-1
mov posicionObstaculoY2,9600
mov tipoObstaculo2,-3
mov posicionObstaculoX3,-1
mov posicionObstaculoY3,9600
mov tipoObstaculo3,-3
mov posicionObstaculoX4,-1
mov posicionObstaculoY4,9600
mov tipoObstaculo4,-3
mov posicionObstaculoX5,-1
mov posicionObstaculoY5,9600
mov tipoObstaculo5,-3
mov posicionObstaculoX6,-1
mov posicionObstaculoY6,9600
mov tipoObstaculo6,3
mov posicionObstaculoX7,-1
mov posicionObstaculoY7,9600
mov tipoObstaculo7,3
mov posicionObstaculoX8,-1
mov posicionObstaculoY8,9600
mov tipoObstaculo8,3
mov posicionObstaculoX9,-1
mov posicionObstaculoY9,9600
mov tipoObstaculo9,3
mov posicionObstaculoX10,-1
mov posicionObstaculoY10,9600
mov tipoObstaculo10,3

mov tiempoTranscurrido,0
mov contadorPuntos,0
mov tiempoNivel,30

endm

pushVariables macro
push posicionCarroX
push colorCarro
push posicionObstaculoX1
push posicionObstaculoY1
push tipoObstaculo1
push posicionObstaculoX2
push posicionObstaculoY2
push tipoObstaculo2
push posicionObstaculoX3
push posicionObstaculoY3
push tipoObstaculo3
push posicionObstaculoX4
push posicionObstaculoY4
push tipoObstaculo4
push posicionObstaculoX5
push posicionObstaculoY5
push tipoObstaculo5

push posicionObstaculoX6
push posicionObstaculoY6
push tipoObstaculo6
push posicionObstaculoX7
push posicionObstaculoY7
push tipoObstaculo7
push posicionObstaculoX8
push posicionObstaculoY8
push tipoObstaculo8
push posicionObstaculoX9
push posicionObstaculoY9
push tipoObstaculo9
push posicionObstaculoX10
push posicionObstaculoY10
push tipoObstaculo10
push numero

push puntosMalos
push puntosBuenos

push tiempoTranscurrido
push contadorPuntos
push tiempoNivel
push tiempoPremio
push timerPremio
push tiempoObstaculo
push timerObstaculo
endm

popVariables macro
pop timerObstaculo
pop tiempoObstaculo
pop timerPremio
pop tiempoPremio
pop tiempoNivel
pop contadorPuntos
pop tiempoTranscurrido

pop puntosBuenos
pop puntosMalos

pop numero
pop tipoObstaculo10
pop posicionObstaculoY10
pop posicionObstaculoX10
pop tipoObstaculo9
pop posicionObstaculoY9
pop posicionObstaculoX9
pop tipoObstaculo8
pop posicionObstaculoY8
pop posicionObstaculoX8
pop tipoObstaculo7
pop posicionObstaculoY7
pop posicionObstaculoX7
pop tipoObstaculo6
pop posicionObstaculoY6
pop posicionObstaculoX6

pop tipoObstaculo5
pop posicionObstaculoY5
pop posicionObstaculoX5
pop tipoObstaculo4
pop posicionObstaculoY4
pop posicionObstaculoX4
pop tipoObstaculo3
pop posicionObstaculoY3
pop posicionObstaculoX3
pop tipoObstaculo2
pop posicionObstaculoY2
pop posicionObstaculoX2
pop tipoObstaculo1
pop posicionObstaculoY1
pop posicionObstaculoX1
pop colorCarro
pop posicionCarroX
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
