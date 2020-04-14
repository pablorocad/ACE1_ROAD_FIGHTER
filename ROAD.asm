include macros.asm

.model small
.stack 100h
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

posicionCarroX db 155
resultado db 100 dup('$')
colorCarro db 127

der db 'derecha','$'
izq db 'izquierda','$'
nada db 'nada','$'

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

_iJ:

pushear
mov dl,posicionCarroX
mov dh,colorCarro

mov ax,0013h
int 10h
mov ax,0a000h
mov ds,ax

_loop_game:
mov posicionCarroX,dl
mov colorCarro,dh

call pintarComponentes
call detectarTecla

mov dl,posicionCarroX
mov dh,colorCarro

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
add posicionCarroX,5
jmp _salir
_izq:
sub posicionCarroX,5
jmp _salir

_salir:
ret
detectarTecla endp

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

pintarCarro proc near
pushear
xor ax,ax
xor bx,bx

mov al,posicionCarroX
add ax,48000;posicion Y fija

;LLANTAS IZQUIERDAS===========
sub ax,2
add ax,1280
mov si,ax
call pintarLlanta

;add si,318
add si,2560
call pintarLlanta

;LLANTAS DERECHAS===========
xor ax,ax

mov al,posicionCarroX
add ax,48000;posicion Y fija
add ax,15
add ax,1280
mov si,ax
call pintarLlanta
add si,2560
call pintarLlanta

;AUTO====================
xor ax,ax
mov al,posicionCarroX
add ax,48000;posicion Y fija

xor dx,dx
mov di,ax
mov dl,colorCarro
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

popear
ret
pintarCarro endp

pintarLlanta proc near
mov dx,0
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

ret
pintarLlanta endp

pintarPista proc near
push ax
push bx
push cx
xor ax,ax
xor bx,bx
xor cx,cx

mov cx,44800
mov di,6420
mov dx,29

ciclo_pintar:
  mov [di], dx ; poner color en A000:DI
  inc di
  inc bx
  cmp bx,280
  jne sig_pix_pintar
            ; nueva fila
  xor bx,bx ; resetear contador de columnas
  add di,40
  sig_pix_pintar:
  loop ciclo_pintar

pop cx
pop bx
pop ax
ret
pintarPista endp

;=================================================================
;==============================JUEGO==============================
;=================================================================
pintarComponentes proc near

call pintarPista
call pintarCarro

ret
pintarComponentes endp

end
