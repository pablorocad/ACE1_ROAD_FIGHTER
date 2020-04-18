include macros.asm

.model small
.stack 250h
.data
;=================================================================
;===========================PRIMER MENU===========================
;=================================================================
primerMenu db 0ah,0dh,'1) Ingresar',0ah,0dh,'2) Registrar',0ah,0dh,'3) Salir',0ah,0dh,'$'
menuUsuario db 0ah,0dh,'1) Iniciar Juego',0ah,0dh,'2) Cargar Juego',0ah,0dh,'3) Salir',0ah,0dh,'$'

;=================================================================
;===============================JUEGO=============================
;=================================================================
usuarioActual dw 0,'$'
nivelActual dw 0,'$'
contadorPuntos dw 3
tiempoTranscurrido dw 0
espacio db 09h,'$'
numero dw 0

;===============================CARRO=============================
posicionCarroX dw 148
resultado db 100 dup('$')
colorCarro dw 127

;========================OBSTACULOS========================
puntosMalos dw 4
puntosBuenos dw 5
;========================OBSTACULOS MALOS========================
posicionObstaculoX1 dw -1
posicionObstaculoY1 dw 9600
tipoObstaculo1 dw -3
posicionObstaculoX2 dw -1
posicionObstaculoY2 dw 9600
tipoObstaculo2 dw -3
posicionObstaculoX3 dw -1
posicionObstaculoY3 dw 9600
tipoObstaculo3 dw -3
posicionObstaculoX4 dw -1
posicionObstaculoY4 dw 9600
tipoObstaculo4 dw -3
posicionObstaculoX5 dw -1
posicionObstaculoY5 dw 9600
tipoObstaculo5 dw -3

;========================OBSTACULOS BUENOS========================
posicionObstaculoX6 dw -1
posicionObstaculoY6 dw 9600
tipoObstaculo6 dw 3
posicionObstaculoX7 dw -1
posicionObstaculoY7 dw 9600
tipoObstaculo7 dw 3
posicionObstaculoX8 dw -1
posicionObstaculoY8 dw 9600
tipoObstaculo8 dw 3
posicionObstaculoX9 dw -1
posicionObstaculoY9 dw 9600
tipoObstaculo9 dw 3
posicionObstaculoX10 dw -1
posicionObstaculoY10 dw 9600
tipoObstaculo10 dw 3


;============================TIEMPO==============================
segundos db 0
;timer dw 20
tiempoNivel dw 30

timerObstaculo dw 2
tiempoObstaculo dw 2

timerPremio dw 5
tiempoPremio dw 5

.code
;=================================================================
;=============================INICIO==============================
;=================================================================
main  proc
mov ax,@data
mov ds, ax;LIMPIAMOS

_menuUsuario:

print menuUsuario
call getchar

cmp al,31h
je _iJ

cmp al,32h
je _cJ

cmp al,33h
je _salir

jmp _menuUsuario

;=================================================================
;===============================JUEGO=============================
;=================================================================
_iJ:

pushear
;mov dl,posicionCarroX
;mov dh,colorCarro
resetVariables
_reset:
pushVariables

mov ax,0013h
int 10h

call encabezado

mov ax,0a000h
mov ds,ax

popVariables

;===============================JUEGO=============================
call pintarPista
mov dx,0
call pintarCarro

TOP:
mov ah,2ch
int 21h
MOV segundos,dh  ; DH has current second
_loop_game:
call insertarMalos
call insertarBuenos

;GETSEC:      ; Loops until the current second is not equal to the last, in BH
mov ah,2Ch
int 21h
cmp segundos,dh  ; Here is the comparison to exit the loop and print 'A'
jne PRINTA
;jmp GETSEC

call moverObstaculo1
cmp al,8
je _reset1
call moverObstaculo2
cmp al,8
je _reset1
call moverObstaculo3
cmp al,8
je _reset1
call moverObstaculo4
cmp al,8
je _reset1
call moverObstaculo5
cmp al,8
je _reset1

call moverObstaculo6
cmp al,8
je _reset1
call moverObstaculo7
cmp al,8
je _reset1
call moverObstaculo8
cmp al,8
je _reset1
call moverObstaculo9
cmp al,8
je _reset1
call moverObstaculo10
cmp al,8
je _reset1

;delay 80
call detectarTecla

cmp al,27
je _exit_game

jmp _loop_game

PRINTA:
dec tiempoNivel
dec timerPremio
dec timerObstaculo
inc tiempoTranscurrido
cmp tiempoNivel,0
je _exit_game
jmp TOP


_reset1:
pushVariables

mov ax,0003h
int 10h
mov ax,@data
mov ds, ax;LIMPIAMOS

popVariables
jmp _reset

_exit_game:

;regresar a modo texto
  mov ax,0003h
  int 10h
_j:
popear
mov ax,@data
mov ds, ax;LIMPIAMOS
;===============================JUEGO=============================
jmp _menuUsuario

_cJ:
jmp _menuUsuario

_salir:
    mov ah,4ch       ;Function (Quit with exit code (EXIT))
    xor al,al
    int 21h
main endp
;=================================================================
;===============================FIN===============================
;=================================================================

;=================================================================
;============================PROCESOS=============================
;=================================================================
getchar proc near
mov ah,01h
int 21h
ret
getchar endp

encabezado proc near
pushear

print usuarioActual
print espacio
print nivelActual
print espacio

mov resultado,0
xor ax,ax
mov ax,contadorPuntos
convertirString resultado
print resultado
print espacio

mov resultado,0
xor ax,ax
mov ax,tiempoTranscurrido
convertirString resultado
print resultado

popear
ret
encabezado endp

numeroAleatorio proc near
pushear
mov ah,2ch
int 21h
xor ax,ax
mov dh,00h
add ax,dx
mov numero,ax

popear
ret
numeroAleatorio endp

;=================================================================
;=============================FLECHAS=============================
;=================================================================
detectarTecla proc near
xor ax,ax
_dectectar:
mov ah,01h;estamos atentos en caso se presione algo
int 16h
jz _salir
mov ah,00h;si lo presiono tomamos el codigo de rastreo AH y ASCII AL
int 16h

cmp ah,4bh;flecha izq
je _izq

cmp ah,4dh;flecha der
je _der

jmp _salir

_der:
push colorCarro
push dx
mov dx,29
mov colorCarro,29
call pintarCarro
pop dx
pop colorCarro

cmp posicionCarroX,208;si llgamos al borde derecho
je _retroceder
jne _no_retroceder
_retroceder:
sub posicionCarroX,5

_no_retroceder:
add posicionCarroX,5

mov dx,0
call pintarCarro
jmp _salir


_izq:
;delay 350
pushear
pintarFranjaPista 3600,48078
popear

cmp posicionCarroX,83;si llgamos al borde izquierdo
je _avanzar
jne _no_avanzar
_avanzar:
add posicionCarroX,5

_no_avanzar:
sub posicionCarroX,5
mov dx,0
call pintarCarro
jmp _salir

_salir:
ret
detectarTecla endp

moverObstaculo1 proc near
;pushear

cmp posicionObstaculoX1,-1
je _exit

mov dx,78
add dx,posicionObstaculoY1
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY1,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY1,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX1

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosMalos
sub contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoY1,-1
mov posicionObstaculoX1,-1
jmp _continue

_continue:
add posicionObstaculoY1,320
pintarObstaculo posicionObstaculoX1,posicionObstaculoY1,tipoObstaculo1
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
;popear
ret
moverObstaculo1 endp

moverObstaculo2 proc near
;pushear

cmp posicionObstaculoX2,-1
je _exit

mov dx,78
add dx,posicionObstaculoY2
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY2,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY2,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX2

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosMalos
sub contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoY2,-1
mov posicionObstaculoX2,-1
jmp _continue

_continue:
add posicionObstaculoY2,320
pintarObstaculo posicionObstaculoX2,posicionObstaculoY2,tipoObstaculo2
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
;popear
ret
moverObstaculo2 endp

moverObstaculo3 proc near
;pushear

cmp posicionObstaculoX3,-1
je _exit

mov dx,78
add dx,posicionObstaculoY3
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY3,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY3,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX3

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosMalos
sub contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoY3,-1
mov posicionObstaculoX3,-1
jmp _continue

_continue:
add posicionObstaculoY3,320
pintarObstaculo posicionObstaculoX3,posicionObstaculoY3,tipoObstaculo3
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
;popear
ret
moverObstaculo3 endp

moverObstaculo4 proc near
;pushear

cmp posicionObstaculoX4,-1
je _exit

mov dx,78
add dx,posicionObstaculoY4
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY4,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY4,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX4

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosMalos
sub contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoY4,-1
mov posicionObstaculoX4,-1
jmp _continue

_continue:
add posicionObstaculoY4,320
pintarObstaculo posicionObstaculoX4,posicionObstaculoY4,tipoObstaculo4
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
;popear
ret
moverObstaculo4 endp

moverObstaculo5 proc near
;pushear

cmp posicionObstaculoX5,-1
je _exit

mov dx,78
add dx,posicionObstaculoY5
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY5,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY5,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX5

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosMalos
sub contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoY5,-1
mov posicionObstaculoX5,-1
jmp _continue

_continue:
add posicionObstaculoY5,320
pintarObstaculo posicionObstaculoX5,posicionObstaculoY5,tipoObstaculo5
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
;popear
ret
moverObstaculo5 endp

moverObstaculo6 proc near
cmp posicionObstaculoX6,-1
je _exit

mov dx,78
add dx,posicionObstaculoY6
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY6,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY6,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX6

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosBuenos
add contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoX6,-1
mov posicionObstaculoY6,-1
jmp _continue

_continue:
add posicionObstaculoY6,320
pintarObstaculo posicionObstaculoX6,posicionObstaculoY6,tipoObstaculo6
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
ret
moverObstaculo6 endp

moverObstaculo7 proc near
cmp posicionObstaculoX7,-1
je _exit

mov dx,78
add dx,posicionObstaculoY7
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY7,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY7,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX7

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosBuenos
add contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoX7,-1
mov posicionObstaculoY7,-1
jmp _continue

_continue:
add posicionObstaculoY7,320
pintarObstaculo posicionObstaculoX7,posicionObstaculoY7,tipoObstaculo7
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
ret
moverObstaculo7 endp

moverObstaculo8 proc near
cmp posicionObstaculoX8,-1
je _exit

mov dx,78
add dx,posicionObstaculoY8
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY8,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY8,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX8

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosBuenos
add contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoX8,-1
mov posicionObstaculoY8,-1
jmp _continue

_continue:
add posicionObstaculoY8,320
pintarObstaculo posicionObstaculoX8,posicionObstaculoY8,tipoObstaculo8
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
ret
moverObstaculo8 endp

moverObstaculo9 proc near
cmp posicionObstaculoX9,-1
je _exit

mov dx,78
add dx,posicionObstaculoY9
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY9,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY9,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX9

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosBuenos
add contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoX9,-1
mov posicionObstaculoY9,-1
jmp _continue

_continue:
add posicionObstaculoY9,320
pintarObstaculo posicionObstaculoX9,posicionObstaculoY9,tipoObstaculo9
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
ret
moverObstaculo9 endp

moverObstaculo10 proc near
cmp posicionObstaculoX10,-1
je _exit

mov dx,78
add dx,posicionObstaculoY10
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY10,60800
je _remove

;Si llego al Y del carro==========================
xor ax,ax
mov ax,49600
cmp posicionObstaculoY10,ax
je _remove_points_x

jmp _continue

;Si llego al X del carro==========================
_remove_points_x:
xor cx,cx
xor ax,ax

mov cx,15
mov ax,posicionCarroX
_loop_comp_x:
push cx
mov cx,10
mov bx,posicionObstaculoX10

_loop_comp_x_int:
cmp bx,ax
je _remove_point_t
inc bx
Loop _loop_comp_x_int
pop cx

inc ax
Loop _loop_comp_x
jmp _continue

_remove_point_t:
pop cx
push bx
mov bx,puntosBuenos
add contadorPuntos,bx
pop bx
mov al,8

_remove:
mov posicionObstaculoX10,-1
mov posicionObstaculoY10,-1
jmp _continue

_continue:
add posicionObstaculoY10,320
pintarObstaculo posicionObstaculoX10,posicionObstaculoY10,tipoObstaculo10
mov dx,0
call pintarCarro
call pintarFranjaAbajo
_exit:
ret
moverObstaculo10 endp

GetTime proc near
    mov ah,2ch
    int 21h

    mov al,ch
    call Convert
    mov [bx + 24],ax

    mov al,cl
    call convert
    mov [bx+27],ax

    mov al,dh
    call convert
    mov [bx+30],ax

    ret
GetTime endp

Convert proc near
    mov ah,0
    mov dl,10
    div dl
    or ax,3030h
    ret
Convert endp

insertarObstaculo1 proc near
pushear

cmp posicionObstaculoX1,-1
jne _exit

call numeroAleatorio
mov ax,83
add ax,numero

mov posicionObstaculoX1,ax
mov posicionObstaculoY1,9600

_exit:
popear
ret
insertarObstaculo1 endp

insertarObstaculo2 proc near
pushear

cmp posicionObstaculoX2,-1
jne _exit

call numeroAleatorio
mov ax,163
add ax,numero

mov posicionObstaculoX2,ax
mov posicionObstaculoY2,9600

_exit:
popear
ret
insertarObstaculo2 endp

insertarObstaculo3 proc near
pushear

cmp posicionObstaculoX3,-1
jne _exit

call numeroAleatorio
mov ax,113
add ax,numero

mov posicionObstaculoX3,ax
mov posicionObstaculoY3,9600

_exit:
popear
ret
insertarObstaculo3 endp

insertarObstaculo4 proc near
pushear

cmp posicionObstaculoX4,-1
jne _exit

call numeroAleatorio
mov ax,103
add ax,numero

mov posicionObstaculoX4,ax
mov posicionObstaculoY4,9600

_exit:
popear
ret
insertarObstaculo4 endp

insertarObstaculo5 proc near
pushear

cmp posicionObstaculoX5,-1
jne _exit

call numeroAleatorio
mov ax,123
add ax,numero

mov posicionObstaculoX5,ax
mov posicionObstaculoY5,9600

_exit:
popear
ret
insertarObstaculo5 endp

insertarObstaculo6 proc near
pushear

cmp posicionObstaculoX6,-1
jne _exit

call numeroAleatorio
mov ax,183
add ax,numero

mov posicionObstaculoX6,ax
mov posicionObstaculoY6,9600

_exit:
popear
ret
insertarObstaculo6 endp

insertarObstaculo7 proc near
pushear

cmp posicionObstaculoX7,-1
jne _exit

call numeroAleatorio
mov ax,133
add ax,numero

mov posicionObstaculoX7,ax
mov posicionObstaculoY7,9600

_exit:
popear
ret
insertarObstaculo7 endp

insertarObstaculo8 proc near
pushear

cmp posicionObstaculoX8,-1
jne _exit

call numeroAleatorio
mov ax,153
add ax,numero

mov posicionObstaculoX8,ax
mov posicionObstaculoY8,9600

_exit:
popear
ret
insertarObstaculo8 endp

insertarObstaculo9 proc near
pushear
cmp posicionObstaculoX9,-1
jne _exit

call numeroAleatorio
mov ax,143
add ax,numero

mov posicionObstaculoX9,ax
mov posicionObstaculoY9,9600

_exit:
popear
ret
insertarObstaculo9 endp

insertarObstaculo10 proc near
pushear

cmp posicionObstaculoX10,-1
jne _exit

call numeroAleatorio
mov ax,83
add ax,numero

mov posicionObstaculoX10,ax
mov posicionObstaculoY10,9600

_exit:
popear
ret
insertarObstaculo10 endp

insertarMalos proc near
pushear
cmp timerObstaculo,0
jne _exit
mov bx,tiempoObstaculo
mov timerObstaculo,bx

mov bx,posicionObstaculoX1
call insertarObstaculo1
cmp bx,-1
je _exit

mov bx,posicionObstaculoX2
call insertarObstaculo2
cmp bx,-1
je _exit

mov bx,posicionObstaculoX3
call insertarObstaculo3
cmp bx,-1
je _exit

mov bx,posicionObstaculoX4
call insertarObstaculo4
cmp bx,-1
je _exit

mov bx,posicionObstaculoX5
call insertarObstaculo5
cmp bx,-1
je _exit
_exit:
popear
ret
insertarMalos endp

insertarBuenos proc near
pushear
cmp timerPremio,0
jne _exit
mov bx,tiempoPremio
mov timerPremio,bx

mov bx,posicionObstaculoX6
call insertarObstaculo6
cmp bx,-1
je _exit

mov bx,posicionObstaculoX7
call insertarObstaculo7
cmp bx,-1
je _exit

mov bx,posicionObstaculoX8
call insertarObstaculo8
cmp bx,-1
je _exit

mov bx,posicionObstaculoX9
call insertarObstaculo9
cmp bx,-1
je _exit

mov bx,posicionObstaculoX10
call insertarObstaculo10
cmp bx,-1
je _exit
_exit:
popear
ret
insertarBuenos endp

;=================================================================
;==============================PINTAR=============================
;=================================================================
pintarCarro proc near
pushear
;LLANTAS IZQUIERDAS===========
xor ax,ax
mov ax,posicionCarroX
add ax,48000;posicion Y fija
sub ax,2
add ax,1280
mov si,ax
pintarLlanta dx

;add si,318
add si,2560
pintarLlanta dx

;LLANTAS DERECHAS===========
xor ax,ax
mov ax,posicionCarroX
add ax,48000;posicion Y fija
add ax,15
add ax,1280
mov si,ax
pintarLlanta dx
add si,2560
pintarLlanta dx

;AUTO====================
xor ax,ax
mov ax,posicionCarroX
add ax,48000;posicion Y fija
xor dx,dx
mov di,ax
pintarCarcasa colorCarro

popear
ret
pintarCarro endp


pintarPista proc near
push ax
push bx
push cx
xor ax,ax
xor bx,bx
xor cx,cx

mov cx,24000
mov di,6478
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

pop cx
pop bx
pop ax
ret
pintarPista endp

pintarFranjaAbajo proc near
pushear
xor ax,ax
xor bx,bx
xor cx,cx

mov cx,3000
mov di,57678
mov dx,0

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
ret
pintarFranjaAbajo endp



;=================================================================
;==============================JUEGO==============================
;=================================================================

end
