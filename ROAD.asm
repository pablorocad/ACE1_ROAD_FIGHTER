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
usuarioActual db 0,'$'
nivelActual db 0,'$'
contadorPuntos db 0,'$'
tiempoTranscurrido db 0,'$'
tiempoTranscurridoTxt db '00:00:00','$'
espacio db 09h,'$'

;===============================CARRO=============================
posicionCarroX dw 148
resultado db 100 dup('$')
colorCarro dw 127

;===========================OBSTACULOS=============================
posicionObstaculoX1 dw 100
posicionObstaculoY1 dw 16000
tipoObstaculo1 dw -3

posicionObstaculoX2 dw 148
posicionObstaculoY2 dw 25600
tipoObstaculo2 dw 3

numero dw ?

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

;=================================================================
;===============================JUEGO=============================
;=================================================================
_iJ:

pushear
;mov dl,posicionCarroX
;mov dh,colorCarro
push posicionCarroX
push colorCarro
push posicionObstaculoX1
push posicionObstaculoY1
push tipoObstaculo1
push posicionObstaculoX2
push posicionObstaculoY2
push tipoObstaculo2

mov ax,0013h
int 10h
mov ax,0a000h
mov ds,ax

pop tipoObstaculo2
pop posicionObstaculoY2
pop posicionObstaculoX2
pop tipoObstaculo1
pop posicionObstaculoY1
pop posicionObstaculoX1
pop colorCarro
pop posicionCarroX

call pintarPista
;call pintarObstaculo
mov dx,0
call pintarCarro
_loop_game:

call moverObstaculo1
;call moverObstaculo2
call detectarTecla

cmp al,27
je _exit_game
jne _loop_game

_exit_game:

;regresar a modo texto
  mov ax,0003h
  int 10h

popear
mov ax,@data
mov ds, ax;LIMPIAMOS

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
print usuarioActual
print espacio
print nivelActual
print espacio
print contadorPuntos
print espacio
print tiempoTranscurridoTxt
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
pushear

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
mov posicionObstaculoY1,16000

_remove:
mov posicionObstaculoY1,16000
jmp _continue

_continue:
add posicionObstaculoY1,320
pintarObstaculo posicionObstaculoX1,posicionObstaculoY1,tipoObstaculo1

_exit:
mov dx,0
call pintarCarro
call pintarFranjaAbajo
delay 180
popear
ret
moverObstaculo1 endp

moverObstaculo2 proc near
pushear

mov dx,78
add dx,posicionObstaculoY2
sub dx,3200
pintarFranjaPista 1500,dx

;Si ya llego al final==========================00
cmp posicionObstaculoY2,60800
je _remove
jne _continue

_remove:
mov posicionObstaculoY2,16000

_continue:
add posicionObstaculoY2,320
pintarObstaculo posicionObstaculoX2,posicionObstaculoY2,tipoObstaculo2

_exit:
mov dx,0
call pintarCarro
call pintarFranjaAbajo
delay 180
popear
ret
moverObstaculo2 endp

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
