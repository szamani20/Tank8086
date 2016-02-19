;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Tank game using Intel 8086 assembly language ;;;;;;
;;;;;;;;;; Developed in emu8086 for windows ;;;;;;;;;;;;

include emu8086.inc        ; for using library functions
org 100h                   ; output .com
                                               
call initializeData        ; initialize tanks positions and others!
call getName               ; getting the name of player
call prepare               ; prepare the screen to draw map
call drawmap               ; draw map on screen
call drawTanks             ; draw tanks on screen
call drawActivation        ; draw activation spots for tanks on screen
call mouseListener         ; listen to mouse events
call congrats              ; show congratulations message if the player win
ret
  
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
initializeData proc
pop ax                     ; random generation
push ax                    ; random generation
mov bx, cs                 ; random generation
add ax, bx				   ; random generation
mov bl, 15                 ; random generation
div bl                     ; random generation
mov al, ah                 ; random generation
and ah, 0                  ; random generation
add ax, 15                 ; random generation
mov si, ax                 ; now si contains a number between 15 and 30

pop bx                     ; random generation
pop ax                     ; random generation
push ax                    ; random generation
push bx                    ; random generation
add ax, bx                 ; random generation              
mov bx, ss                 ; random generation
add ax, bx				   ; random generation
mov bl, 60                 ; random generation
div bl                     ; random generation
mov al, ah                 ; random generation
and ah, 0                  ; random generation
add ax, 15                 ; random generation
mov di, ax                 ; now di contains a number between 15 and 75

mov bx, 0                  ; index for array

initloop:                  ; loop for initializing coordinates for tanks
mov points[bx], di         ; initializing
add bx, 2                  ; initializing
mov points[bx], si         ; initializing
add bx, 2                  ; initializing

add di, tankxrandom        ; adding displacement to coordinates
add si, tankyrandom        ; adding displacement to coordinates

cmp bx, 20                 ; check for ending of loop
jz initActive              ; end loop
jmp initloop               ; loop

initActive:
mov bx, 0

activeLoop:                ; initializing activation sign coordinate array
mov cx, points[bx]
add cx, 4
mov active[bx], cx
add bx, 2
mov cx, points[bx]
sub cx, 10
mov active[bx], cx
add bx, 2

cmp bx, 20
jz initBound
jmp activeLoop

initBound:                 ; initializing boundaries array
mov bx, 0                  

boundLoop:
mov cx, points[bx]
add cx, 10
mov bound[bx], cx
add bx, 2
mov cx, points[bx]
mov dx, 190
sub dx, cx
mov bound[bx], dx
add bx, 2
cmp bx, 20
jz initEn
jmp boundLoop

initEn:
ret
initializeData endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getName proc
mov dx, offset entername   ; load offset of entername message into dx
mov ah, 9                  ; prepare appropriate interrupt
int 21h                    ; output entername message on screen

mov dx, offset buffer      ; store the input in name array
mov ah, 0ah                ; setting appropriate interrupt
int 21h                    ; get input name
 
ret
getName endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
prepare proc
mov ah, 0                  ; setting appropriate interrupt
mov al, 13h                ; mode 13h = 320x200 pixels, 256 colors
int 10h                    ; set display mode    
ret
prepare endp 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawMap proc    
mov al, 100                ; set the color
mov cx, 0                  ; set column
mov dx, 100                ; set row
mov ah, 0ch                ; setting appropriate interrupt
    
outerLop:                  ; loop to draw map pixel by pixel
inc cx                     ; increase column number
int 10h                    ; setting appropriate interrupt
cmp cx, mapWidth           ; watch the boundaries!
jne outerlop               ; loop
ret
drawmap endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawtanks proc
mov bx, 0                  ; counter to loop through array of tanks coordinates
mov al, 75                 ; set the color of tank
                           
startdrawing:              ; loop for every tank
cmp bx, 20                 ; check for end of tanks
jz en
     
mov cx, points[bx]         ; set the x coordinate
add bx, 2                  ; go 2 bytes further in array of tanks coordinates to reach the y coordinate
mov dx, points[bx]         ; set the y coordinate
add bx, 2                  ; go 2 bytes forward
mov si, cx                 ; 
add si, tankWidth          ; width of every tank is 10 pixels
mov di, dx
add di, tankHeight         ; height of every tank is also 10 pixels

tankLop:
inc cx                     ; move one pixel forward in x coordinate
int 10h                    ; setting appropriate interrupt
cmp cx, si                 ; check if width of tank is complete
jne tankLop                ; loop through width of every tank

mov cx, si                 ; get back the starting x coordinate
sub cx, tankWidth          ; get back the starting x coordinate

inc dx                     ; move one pixel forward in y coordinate
cmp dx, di                 ; check if height of tank is complete
jne tanklop                ; loop through height of every tank

sub bx, 2                  ; getting back x and y coordinates of tank to draw the gun pipe
mov dx, points[bx]         ; getting back x and y coordinates of tank to draw the gun pipe
sub bx, 2                  ; getting back x and y coordinates of tank to draw the gun pipe
mov cx, points[bx]         ; getting back x and y coordinates of tank to draw the gun pipe
add bx, 4                  ; go back to the first index of array

add cx, 5                  ; gun pipe is at the middle of tank with respect to x coordinate
add dx, 10                 ; gun pipe is at the end of tank with respect to y coordinate
add di, gunHeight          ; height of gun pipe is 5 and width is 1

gunlop:                    ; loop to draw gun pipe
inc dx                     ; move one pixel forward in height to draw gun pipe
int 10h                    ; setting appropriate interrupt
cmp dx, di                 ; check the boundaries!
jne gunlop                 ; loop through y coordinate to draw gun pipe

jmp startdrawing           ; loop to draw next tank

en:    
ret
drawtanks endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
drawActivation proc
mov bx, 0                  ; set counter to 0
mov al, 150                ; set the color of activation sign

activedraw:                ; loop to draw activation sign
cmp bx, 20                 ; check the boundaries!
jz en                      ; if done then return 
     
mov cx, active[bx]         ; set x coordinate of activation sign
add bx, 2                  ; move 2 bytes further in activation array
mov dx, active[bx]         ; set y coordinate of activation sign
add bx, 2                  ; move 2 bytes further in activation array
mov si, cx                 ; 
add si, activeWidth        ; width of activation sign is 3
mov di, dx                 ;
add di, activeHeight       ; height of activation sign is also 3

activelop:                 ; loop to draw activation sign
inc cx                     ; move 1 pixel forward
int 10h                    ; set appropriate interrupt
cmp cx, si                 ; check if width of activation sign is drawn
jne activelop              ; loop to draw the width of activation sign

mov cx, si                 ; 
sub cx, activeWidth        ; getting back the original value of width

inc dx                     ; move 1 pixel forward in y coordinate
cmp dx, di                 ; check if height of activation sign is drawn
jne activelop              ; loop to draw activation sign

jmp activedraw             ; loop to draw next activation sign

ret
drawActivation endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diactivate1 proc
cmp tank1, 0
jz diactivate1en

mov tank1, 0
inc counter                ; one more tank is destroyed!

mov al, 250                ; change the activation sign color
mov ah, 0ch                ; set appropriate interrupt

mov bx, 0                  ; counter to obtain the corresponding coordinates from activation sign coordinates array
     
mov cx, active[bx]         ; width of activation sign
add bx, 2                  ; move 2 bytes forward
mov dx, active[bx]         ; height of activation sign
mov si, cx                 ; 
add si, activeWidth        ; width is 3
mov di, dx                 ;
add di, activeHeight       ; height is 3

diactive1lop:              ; loop to change the color of number 1 activation sign
inc cx                     ; move 1 pixel forward in x coordinate
int 10h                    ; set appropriate interrupt
cmp cx, si                 ; draw only the size of sign width!
jne diactive1lop           ; if width is done

mov cx, si                 ; getting back the original value of sign width
sub cx, activeWidth        ; set the width 

inc dx                     ; move 1 pixel forward in y coordinate
cmp dx, di                 ; draw only the size of sign height
jne diactive1lop           ; loop to draw next line of y coordinate

mov ax, 3                  ; restore the value for getting mouse status for interrupt 33

diactivate1en:
ret
diactivate1 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
diactivate2 proc           ; do the same thing as diactivate1 procedure for the next tank
cmp tank2, 0
jz diactivate2en

mov tank2, 0
inc counter

mov al, 250 
mov ah, 0ch

mov bx, 4
     
mov cx, active[bx]
add bx, 2
mov dx, active[bx]
mov si, cx
add si, activeWidth
mov di, dx
add di, activeHeight

diactive2lop:
inc cx
int 10h
cmp cx, si
jne diactive2lop

mov cx, si
sub cx, activeWidth

inc dx
cmp dx, di
jne diactive2lop

mov ax, 3    

diactivate2en:
ret
diactivate2 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diactivate3 proc           ; do the same thing as diactivate1 procedure for the next tank
cmp tank3, 0
jz diactivate3en

mov tank3, 0
inc counter                

mov al, 250 
mov ah, 0ch

mov bx, 8
     
mov cx, active[bx]
add bx, 2
mov dx, active[bx]
mov si, cx
add si, activeWidth
mov di, dx
add di, activeHeight

diactive3lop:
inc cx
int 10h
cmp cx, si
jne diactive3lop

mov cx, si
sub cx, activeWidth

inc dx
cmp dx, di
jne diactive3lop

mov ax, 3

diactivate3en:
ret
diactivate3 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diactivate4 proc           ; do the same thing as diactivate1 procedure for the next tank
cmp tank4, 0
jz diactivate4en

mov tank4, 0
inc counter


mov al, 250 
mov ah, 0ch

mov bx, 12
     
mov cx, active[bx]
add bx, 2
mov dx, active[bx]
mov si, cx
add si, activeWidth
mov di, dx
add di, activeHeight

diactive4lop:
inc cx
int 10h
cmp cx, si
jne diactive4lop

mov cx, si
sub cx, activeWidth

inc dx
cmp dx, di
jne diactive4lop

mov ax, 3    

diactivate4en:
ret
diactivate4 endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
diactivate5 proc           ; do the same thing as diactivate1 procedure for the next tank
cmp tank5, 0
jz diactivate5en

mov tank5, 0
inc counter

mov al, 250 
mov ah, 0ch

mov bx, 16
     
mov cx, active[bx]
add bx, 2
mov dx, active[bx]
mov si, cx
add si, activeWidth
mov di, dx
add di, activeHeight

diactive5lop:
inc cx
int 10h
cmp cx, si
jne diactive5lop

mov cx, si
sub cx, activeWidth

inc dx
cmp dx, di
jne diactive5lop

mov ax, 3 

diactivate5en:
ret
diactivate5 endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mouseListener proc         ; listen to mouse events 
mov ax, 3                  ; set the appropriate interrupt
listenerlop:               ; loop to listen to mouse event continuously
cmp counter, 5             ; check if all of the tanks are destroyed
jz endmouse                ; if so then we are victorious!
int 33h                    ; get the mouse event
cmp bx, 1                  ; if the left button is pressed
jnz listenerlop            ; if not the listen until the left button is pressed

inc shoots
mov bx, 0

shr cx, 1                  ; for some reason as the documentation said 
                           ; the value of cx which represent the x coordinate is doubled
first:                     ; check for first tank
mov bx, 0
mov si, points[bx]
cmp cx, si                 ; check the boundaries
jb second                  ; check the boundaries
mov di, bound[bx]
cmp cx, di                 ; check the boundaries
ja second                  ; check the boundaries
add bx, 2
mov si, bound[bx]
cmp dx, si                 ; check the boundaries
jb second                  ; check the boundaries
mov di, mapHeight
sub di, points[bx]
cmp dx, di                 ; check the boundaries
ja second                  ; check the boundaries
call diactivate1           ; if the coordinates are correct then destroy the tank!
jmp listenerlop            ; and listen to next mouse event

second:                    ; same as first for the next tank
mov bx, 4
mov si, points[bx]
cmp cx, si
jb third
mov di, bound[bx]
cmp cx, di
ja third
add bx, 2
mov si, bound[bx]
cmp dx, si
jb third
mov di, mapHeight
sub di, points[bx]
cmp dx, di
ja third
call diactivate2
jmp listenerlop

third:                     ; same as first for the next tank
mov bx, 8
mov si, points[bx]
cmp cx, si
jb fourth
mov di, bound[bx]
cmp cx, di
ja fourth
add bx, 2
mov si, bound[bx]
cmp dx, si
jb fourth
mov di, mapHeight
sub di, points[bx]
cmp dx, di
ja fourth
call diactivate3
jmp listenerlop

fourth:                    ; same as first for the next tank
mov bx, 12
mov si, points[bx]
cmp cx, si
jb fifth
mov di, bound[bx]
cmp cx, di
ja fifth
add bx, 2
mov si, bound[bx]
cmp dx, si
jb fifth
mov di, mapHeight
sub di, points[bx]
cmp dx, di
ja fifth
call diactivate4
jmp listenerlop

fifth:                     ; same as first for the next tank
mov bx, 16
mov si, points[bx]
cmp cx, si
jb listenerlop
mov di, bound[bx]
cmp cx, di
ja listenerlop
add bx, 2
mov si, bound[bx]
cmp dx, si
jb listenerlop
mov di, mapHeight
sub di, points[bx]
cmp dx, di
ja listenerlop
call diactivate5

jmp listenerlop            ; if none of them is not shot then listen to the next mouse event

endmouse:
ret
mouseListener endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
congrats proc              ; show the congratulations message
mov ch, 6                  ; set the mode of screen first 
mov cl, 7                  ; set the mode of screen first
mov ah, 1                  ; set the mode of screen first
int 10h

mov dx, offset congratsMSG ; load the offset of message in dx register
mov ah, 9                  ; set the appropriate interrupt
int 21h                    ; show the message

xor bx, bx                 ; prepare to add $ at the end of player name
mov bl, buffer[1]          ; prepare to add $ at the end of player name
mov buffer[bx+2], '$'      ; Do it!
mov dx, offset buffer+2    ; load the $ terminated player name in dx register to display it
int 21h                    ; show the player name

mov dx, offset scoreMSG
mov ah, 9
int 21h

mov ax, shoots
call print_num

mov dx, offset scoreMSGHelp
mov ah, 9
int 21h

ret
congrats endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   ; here lies data segment


points dw 10 dup('?')                                   ; tanks coordinates!
bound dw 10 dup('?')                                    ; tanks boundaries
active dw 10 dup('?')                                   ; activation sign coordinates
counter dw 0                                            ; counter for tanks
shoots dw 0                                             ; counter for shoots
scoreMSG db " you have shot $"
scoreMSGHelp db " bullets $"
congratsMSG db " CONGRATULATIONS! $"                    ; congratulations!
entername db "Enter your name: $"                       ; what is your name? :)
buffer db nameLength,?, nameLength dup(' ')             ; array to store player name (only 10 characters)
tank1 db 1
tank2 db 1
tank3 db 1
tank4 db 1
tank5 db 1
mapWidth equ 315
mapHeight equ 200                                        
tankWidth equ 10
tankHeight equ 10
gunHeight equ 5
activeWidth equ 3
activeHeight equ 3
nameLength equ 15
tankXRandom equ 50
tankYRandom equ 10

define_print_num                                        ; library function
define_print_num_uns                                    ; library function
