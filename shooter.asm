; http://win32assembly.programminghorizon.com/tut25.html
; http://win32assembly.programminghorizon.com/tut3.html

.386 
.model flat,stdcall
option casemap:none

include shooter.inc

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD




.DATA
ClassName db "ShooterWindowClass",0        ; nome da classe de janela
AppName db "ATARI SHOOTER",0         




.DATA?
hInstance HINSTANCE ?        ; Instance handle do programa
CommandLine LPSTR ? 



.CODE                ; Here begins our code 
start: 
    invoke GetModuleHandle, NULL            ; get the instance handle of our program. 
                                            ; Under Win32, hmodule==hinstance mov hInstance,eax 
    mov hInstance,eax 

    invoke GetCommandLine                   ; get the command line. You don't have to call this function IF 
                                            ; your program doesn't process the command line. 
    mov CommandLine,eax 

    invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT      ; call the main function 
    invoke ExitProcess, eax                                           ; quit our program. The exit code is returned in eax from WinMain.


; _ PROCEDURES ___________________________________________________________________________

loadImages proc                                                 

    ;Loading background bitmap
    invoke LoadBitmap, hInstance, 169
    mov h_background, eax

    ;Loading Arrow 1's Bitmaps:

    invoke LoadBitmap, hInstance, 116
    mov A1_left, eax

    invoke LoadBitmap, hInstance, 124
    mov A1_onGround, eax

    ;Loading Player's Bitmaps:

    invoke LoadBitmap, hInstance, 130
    mov p2_spritesheet, eax

    invoke LoadBitmap, hInstance, 134
    mov p1_spritesheet, eax

    ret
loadImages endp

;______________________________________________________________________________

isColliding proc obj1Pos:point, obj2Pos:point, obj1Size:point, obj2Size:point

    ;.if obj1Pos.x < obj2Pos.x + obj2Size.x && \
    ;    obj1Pos.x + obj1Size.x > obj2Pos.x && \
    ;    obj1Pos.y < obj2Pos.y + obj2Size.y && \
    ;    obj1Pos.y + obj1Size.y > obj2Pos.y
    ;    mov eax, TRUE
    ;.else
    ;    mov eax, FALSE
    ;.endif
    
    push eax
    push ebx

    mov eax, obj1Pos.x
    add eax, obj1Size.x ; eax = obj1Pos.x + obj1Size.x
    mov ebx, obj2Pos.x
    add ebx, obj2Size.x ; ebx = obj2Pos.x + obj2Size.x

    .if obj1Pos.x < ebx && eax > obj2Pos.x
        mov eax, obj1Pos.y
        add eax, obj1Size.y ; eax = obj1Pos.y + obj1Size.y
        mov ebx, obj2Pos.y
        add ebx, obj2Size.y ; ebx = obj2Pos.y + obj2Size.y
        
        .if obj1Pos.y < ebx && eax > obj2Pos.y
            ; the objects are colliding
            mov edx, TRUE
        .else
            mov edx, FALSE
        .endif
    .else
        mov edx, FALSE
    .endif

    pop ebx
    pop eax

    ret

isColliding endp


;______________________________________________________________________________

isStopped proc addrPlayer:dword
assume edx:ptr player
    mov edx, addrPlayer

.if [edx].playerObj.speed.x == 0  && [edx].playerObj.speed.y == 0
    mov [edx].stopped, 1
.endif

ret
isStopped endp
;______________________________________________________________________________

;______________________________________________________________________________

paintBackground proc _hdc:HDC, _hMemDC:HDC
    invoke SelectObject, _hMemDC, h_background
    invoke BitBlt, _hdc, 0, 0, 1200, 800, _hMemDC, 0, 0, SRCCOPY

    ret
paintBackground endp

;______________________________________________________________________________

paintPlayers proc _hdc:HDC, _hMemDC:HDC

   ;PLAYER 1___________________________________________
        invoke SelectObject, _hMemDC, p1_spritesheet

        movsx eax, player1.direction
        mov ebx, PLAYER_SIZE
        mul ebx
        mov ecx, eax

        invoke isStopped, addr player1

        .if player1.stopped == 1
            mov edx, 0
        .elseif player1.dashsequence == 0
            movsx eax, player1.walksequence
            mov ebx, PLAYER_SIZE               ; se for mudar hitbox, essa e a largura
            mul ebx
            mov edx, eax
        .else
            movsx eax, player1.dashsequence
            mov ebx, PLAYER_SIZE               ; se for mudar hitbox, essa e a largura
            mul ebx
            mov edx, eax
        .endif

    ;________PLAYER 1 PAINTING________________________________________________________________________

        mov eax, player1.playerObj.pos.x
        mov ebx, player1.playerObj.pos.y
        sub eax, PLAYER_HALF_SIZE
        sub ebx, PLAYER_HALF_SIZE

        ;invoke BitBlt, _hdc, eax, ebx, PLAYER_SIZE, PLAYER_SIZE, _hMemDC, edx, ecx, SRCCOPY 
        invoke TransparentBlt, _hdc, eax, ebx,\
            PLAYER_SIZE, PLAYER_SIZE, _hMemDC,\
            edx, ecx, PLAYER_SIZE, PLAYER_SIZE, 16777215
    ;________________________________________________________________________________


   ;PLAYER 2___________________________________________

        invoke SelectObject, _hMemDC, p2_spritesheet

        movsx eax, player2.direction
        mov ebx, PLAYER_SIZE
        mul ebx
        mov ecx, eax

        invoke isStopped, addr player2

        .if player2.stopped == 1
            mov edx, 0
        .elseif player2.dashsequence == 0
            movsx eax, player2.walksequence
            mov ebx, PLAYER_SIZE               ; se for mudar hitbox, essa e a largura
            mul ebx
            mov edx, eax
        .else
            movsx eax, player2.dashsequence
            mov ebx, PLAYER_SIZE               ; se for mudar hitbox, essa e a largura
            mul ebx
            mov edx, eax
        .endif

    ;________PLAYER 2 PAINTING________________________________________________________________________

        mov eax, player2.playerObj.pos.x
        mov ebx, player2.playerObj.pos.y
        sub eax, PLAYER_HALF_SIZE
        sub ebx, PLAYER_HALF_SIZE

        ;invoke BitBlt, _hdc, eax, ebx, PLAYER_SIZE, PLAYER_SIZE, _hMemDC, edx, ecx, SRCCOPY 
        invoke TransparentBlt, _hdc, eax, ebx,\
            PLAYER_SIZE, PLAYER_SIZE, _hMemDC,\
            edx, ecx, PLAYER_SIZE, PLAYER_SIZE, 16777215
    ;________________________________________________________________________________
    
    ret
paintPlayers endp

;________________________________________________________________________________

paintArrows proc _hdc:HDC, _hMemDC:HDC 

    ;________PLAYER 1 PAINTING_____________________________________________________________

        .if arrow1.onGround == 1 
            invoke SelectObject, _hMemDC, A1_onGround
        .else
            invoke SelectObject, _hMemDC, A1_left  
        .endif

        mov eax, arrow1.arrowObj.pos.x
        mov ebx, arrow1.arrowObj.pos.y
        sub eax, ARROW_HALF_SIZE_P.x
        sub ebx, ARROW_HALF_SIZE_P.y

        invoke BitBlt, _hdc, eax, ebx, ARROW_SIZE_POINT.x, ARROW_SIZE_POINT.y, _hMemDC, 0, 0, SRCCOPY 


;________PLAYER 2 PAINTING_____________________________________________________________
        .if arrow2.onGround == 1 
            invoke SelectObject, _hMemDC, A1_onGround
        .else
            invoke SelectObject, _hMemDC, A1_left  
        .endif

        mov eax, arrow2.arrowObj.pos.x
        mov ebx, arrow2.arrowObj.pos.y
        sub eax, ARROW_HALF_SIZE_P.x
        sub ebx, ARROW_HALF_SIZE_P.y

        invoke BitBlt, _hdc, eax, ebx, ARROW_SIZE_POINT.x, ARROW_SIZE_POINT.y, _hMemDC, 0, 0, SRCCOPY 
    
    ret
paintArrows endp

;________________________________________________________________________________

updateScreen proc
    LOCAL paintstruct:PAINTSTRUCT
    LOCAL hMemDC:HDC 
    LOCAL hDC:HDC

    invoke BeginPaint, hWnd, ADDR paintstruct
    mov hDC, eax
    invoke CreateCompatibleDC, hDC
    mov hMemDC, eax

    ;invoke wsprintf, ADDR buffer, ADDR test_header_format, h_V1_top_left
    ;invoke MessageBox, NULL, ADDR buffer, ADDR msgBoxTitle, MB_OKCANCEL

    ;invoke SelectObject, hMemDC, h_V1_top_left
    ;invoke TransparentBlt, hDC, 0, 0,\
    ;    50, 50, hMemDC,\    
    ;    0, 0, 50, 50, 16777215

    invoke paintBackground, hDC, hMemDC

    invoke paintPlayers, hDC, hMemDC
    invoke paintArrows, hDC, hMemDC

    invoke DeleteDC, hMemDC
    invoke EndPaint, hWnd, ADDR paintstruct


    ret
updateScreen endp

;______________________________________________________________________________

paintThread proc p:DWORD
    .while !over
        invoke Sleep, 25 ; 60 FPS

        ;invoke updateScreen

        ;invoke InvalidateRect, hWnd, NULL, TRUE

    .endw

    ret
paintThread endp

;______________________________________________________________________________

movePlayer proc uses eax addrPlayer:dword               ; updates a gameObject position based on its speed
    assume ecx:ptr gameObject
    mov ecx, addrPlayer

    ; X AXIS ______________
    mov eax, [ecx].pos.x
    mov ebx, [ecx].speed.x
    .if bx > 7fh
        or bx, 65280    ; if negative
    .endif
    add eax, ebx
    mov [ecx].pos.x, eax

    ; Y AXIS ______________
    mov eax, [ecx].pos.y
    mov ebx, [ecx].speed.y
    .if bx > 7fh 
        or bx, 65280    ; if negative
    .endif
    add ax, bx
    mov [ecx].pos.y, eax

    assume ecx:nothing
    ret
movePlayer endp

;______________________________________________________________________________

dashPlayer proc addrPlayer:dword
assume eax:ptr player
    mov eax, addrPlayer
    mov edx, DASH_DISTANCE

    mov [eax].stopped, 0
    mov [eax].dashsequence, 6

    .if [eax].direction == D_TOP_LEFT
        mov [eax].playerObj.speed.x, -DASH_SPEED
        mov [eax].playerObj.speed.y, -DASH_SPEED

    .elseif [eax].direction == D_TOP
        mov [eax].playerObj.speed.y, -DASH_SPEED

    .elseif [eax].direction == D_TOP_RIGHT
        mov [eax].playerObj.speed.x,  DASH_SPEED
        mov [eax].playerObj.speed.y, -DASH_SPEED

    .elseif [eax].direction == D_RIGHT
        mov [eax].playerObj.speed.x,  DASH_SPEED

    .elseif [eax].direction == D_DOWN_RIGHT
        mov [eax].playerObj.speed.x,  DASH_SPEED
        mov [eax].playerObj.speed.y,  DASH_SPEED

    .elseif [eax].direction == D_DOWN
        mov [eax].playerObj.speed.y,  DASH_SPEED

    .elseif [eax].direction == D_DOWN_LEFT
        mov [eax].playerObj.speed.x, -DASH_SPEED
        mov [eax].playerObj.speed.y,  DASH_SPEED

    .elseif [eax].direction == D_LEFT
        mov [eax].playerObj.speed.x,  -DASH_SPEED
    .endif

    mov [eax].cooldownDash, 0

    ret
dashPlayer endp

;______________________________________________________________________________


updateDirection proc addrPlayer:dword     ; updates direction based on players axis's speed
assume eax:ptr player
    mov eax, addrPlayer

    mov ebx, [eax].playerObj.speed.x      ; player's x axis 
    mov edx, [eax].playerObj.speed.y      ; player's y axis

    .if ebx != 0 || edx != 0
        .if ebx == 0                                 ; if x axis = 0 then:
            .if edx > 7fh                                  ; if y axis < 0
                mov [eax].direction, D_TOP       
            .else                                          ;    y axis > 0
                mov [eax].direction, D_DOWN     
            .endif 


        .elseif ebx > 7fh                             ; if x axis > 0
            .if edx == 0                                    ; if y axis = 0
                mov [eax].direction, D_LEFT  
            .elseif edx > 7fh                               ; if y axis > 0
                mov [eax].direction, D_TOP_LEFT             
            .else 
                mov [eax].direction, D_DOWN_LEFT            ; if y axis < 0
            .endif    


        .else                                          ; if x axis < 0
            .if edx == 0                                    ; if y axis = 0
                mov [eax].direction, D_RIGHT  
            .elseif edx > 7fh                               ; if y axis > 0
                mov [eax].direction, D_TOP_RIGHT   
            .else                                           ;    y axis < 0
                mov [eax].direction, D_DOWN_RIGHT  
            .endif 
        .endif
    .endif
    ret
updateDirection endp

;______________________________________________________________________________

moveArrow proc uses eax addrArrow:dword               ; updates a gameObject position based on its speed
    assume eax:ptr arrow
    mov eax, addrArrow

    mov ebx, [eax].arrowObj.speed.x
    mov ecx, [eax].arrowObj.speed.y

    mov [eax].onGround, 0
    .if [eax].remainingDistance > 0
        .if [eax].direction == D_TOP_LEFT
            add [eax].arrowObj.pos.x, -ARROW_SPEED
            add [eax].arrowObj.pos.y, -ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED

        .elseif [eax].direction == D_TOP
            add [eax].arrowObj.pos.y, -ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED

        .elseif [eax].direction == D_TOP_RIGHT
            add [eax].arrowObj.pos.x,  ARROW_SPEED
            add [eax].arrowObj.pos.y, -ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED
        
        .elseif [eax].direction == D_RIGHT
            add [eax].arrowObj.pos.x,  ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED

        .elseif [eax].direction == D_DOWN_RIGHT
            add [eax].arrowObj.pos.x,  ARROW_SPEED
            add [eax].arrowObj.pos.y,  ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED

        .elseif [eax].direction == D_DOWN
            add [eax].arrowObj.pos.y,  ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED

        .elseif [eax].direction == D_DOWN_LEFT
            add [eax].arrowObj.pos.x, -ARROW_SPEED
            add [eax].arrowObj.pos.y,  ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED

        .elseif [eax].direction == D_LEFT
            add [eax].arrowObj.pos.x,  -ARROW_SPEED
            sub [eax].remainingDistance, ARROW_SPEED
        .endif
    .else
        mov [eax].onGround, 1 
    .endif
    assume eax:nothing
    ret
moveArrow endp
;______________________________________________________________________________

fixCoordinates proc addrPlayer:dword
assume eax:ptr player
    mov eax, addrPlayer

    .if [eax].playerObj.pos.x > WINDOW_SIZE_X && [eax].playerObj.pos.x < 80000000h
        mov [eax].playerObj.pos.x, 20                   ;sorry
    .endif

    .if [eax].playerObj.pos.x <= 10 || [eax].playerObj.pos.x > 80000000h
        mov [eax].playerObj.pos.x, WINDOW_SIZE_X - 20 
    .endif


    .if [eax].playerObj.pos.y > WINDOW_SIZE_Y - 70 && [eax].playerObj.pos.y < 80000000h
        mov [eax].playerObj.pos.y, 20
    .endif

    .if [eax].playerObj.pos.y <= 10 || [eax].playerObj.pos.y > 80000000h
        mov [eax].playerObj.pos.y, WINDOW_SIZE_Y - 80 
    .endif
ret
fixCoordinates endp

;______________________________________________________________________________

fixArrowCoordinates proc addrArrow:dword
assume eax:ptr arrow
    mov eax, addrArrow
    
.if [eax].onGround == 0
        .if [eax].arrowObj.pos.x > WINDOW_SIZE_X && [eax].arrowObj.pos.x < 80000000h
            mov [eax].arrowObj.pos.x, 20                  
        .endif

        .if [eax].arrowObj.pos.x <= 10 || [eax].arrowObj.pos.x > 80000000h
            mov [eax].arrowObj.pos.x, 1180 
        .endif


        .if [eax].arrowObj.pos.y > WINDOW_SIZE_Y - 80 && [eax].arrowObj.pos.y < 80000000h
            mov [eax].arrowObj.pos.y, 20
        .endif

        .if [eax].arrowObj.pos.y <= 10 || [eax].arrowObj.pos.y > 80000000h
            mov [eax].arrowObj.pos.y, WINDOW_SIZE_Y - 90 
        .endif
.endif
ret
fixArrowCoordinates endp

;______________________________________________________________________________


gameManager proc p:dword
        .while !over
            invoke Sleep, 30

            ;invoke isColliding, player1.playerObj.pos, player2.playerObj.pos, PLAYER_SIZE_POS_S, PLAYER_SIZE_POS_S
            ;.if edx == TRUE
            ;    invoke wsprintf, ADDR buffer, ADDR test_header_format, edx
            ;    invoke MessageBox, NULL, ADDR buffer, ADDR msgBoxTitle, MB_OKCANCEL
            ;.endif
            invoke isColliding, player2.playerObj.pos, arrow1.arrowObj.pos, PLAYER_SIZE_POINT, ARROW_SIZE_POINT
            .if edx == TRUE
                mov player2.playerObj.pos.x, 50
                mov player2.playerObj.pos.y, 50
            .endif

            invoke isColliding, player1.playerObj.pos, arrow1.arrowObj.pos, PLAYER_SIZE_POINT, ARROW_SIZE_POINT
            .if edx == TRUE
                .if arrow1.onGround == 1
                    ;mov arrow1.onGround, 0               ; pick up arrow from the ground
                    mov arrow1.arrowObj.pos.x, -100
                    mov arrow1.arrowObj.pos.y, -100
                    mov arrow1.playerOwns, 1
                .endif
            .endif

            invoke isColliding, player1.playerObj.pos, arrow2.arrowObj.pos, PLAYER_SIZE_POINT, ARROW_SIZE_POINT
            .if edx == TRUE
                mov player1.playerObj.pos.x, 50
                mov player1.playerObj.pos.y, 50
            .endif

            invoke isColliding, player2.playerObj.pos, arrow2.arrowObj.pos, PLAYER_SIZE_POINT, ARROW_SIZE_POINT
            .if edx == TRUE
                .if arrow2.onGround == 1
                    ;mov arrow1.onGround, 0               ; pick up arrow from the ground
                    mov arrow2.arrowObj.pos.x, -100
                    mov arrow2.arrowObj.pos.y, -100
                    mov arrow2.playerOwns, 1
                .endif
            .endif

            .if player2.cooldownDash  != 30
                inc player2.cooldownDash
            .else
                mov player2CanDash, 1
            .endif

            .if player1.cooldownDash != 30
                inc player1.cooldownDash
            .else
                mov player1CanDash, 1
            .endif

            .if player2DashClick == 1
                invoke dashPlayer, addr player2
                mov player2DashClick, 0
                mov player2CanDash, 0
            .endif
            .if player1DashClick == 1
                invoke dashPlayer, addr player1
                mov player1DashClick, 0
                mov player1CanDash, 0
            .endif

            .if arrow1.remainingDistance > 0
                invoke moveArrow, addr arrow1
            .else
                mov arrow1.onGround, 1
            .endif

            .if arrow2.remainingDistance > 0
                invoke moveArrow, addr arrow2
            .else
                mov arrow2.onGround, 1
            .endif


            ; ----- PLAYER 1 WALKING SEQUENCE ------

            .if player1.dashsequence == 0
                ; the player is walking
                .if player1.walkanimationCD != 2
                    inc player1.walkanimationCD
                .else
                    inc player1.walksequence
                    .if player1.walksequence == 6
                        ; walking animation over
                        mov player1.walksequence, 0
                    .endif
                    mov player1.walkanimationCD, 0
                .endif
            .else
                ; the player is dashing
                .if player1.dashanimationCD != 2
                    inc player1.dashanimationCD
                .else
                    inc player1.dashsequence
                    .if player1.dashsequence == 12
                        ; dash over
                        mov player1.dashsequence, 0
                        .if player1.playerObj.speed.x == DASH_SPEED
                            mov player1.playerObj.speed.x, PLAYER_SPEED
                        .elseif player1.playerObj.speed.x == -DASH_SPEED
                            mov player1.playerObj.speed.x, -PLAYER_SPEED
                        .endif
                        .if player1.playerObj.speed.y == DASH_SPEED
                            mov player1.playerObj.speed.y, PLAYER_SPEED
                        .elseif player1.playerObj.speed.y == -DASH_SPEED
                            mov player1.playerObj.speed.y, -PLAYER_SPEED
                        .endif

                        ;mov player1.playerObj.speed.x, 0
                        ;mov player1.playerObj.speed.y, 0
                    .endif
                    mov player1.dashanimationCD, 0
                .endif
            .endif


            ; ----- PLAYER 2 WALKING SEQUENCE ------
            
            .if player2.dashsequence == 0
                ; the player is walking
                .if player2.walkanimationCD != 2
                    inc player2.walkanimationCD
                .else
                    inc player2.walksequence
                    .if player2.walksequence == 6
                        ; walking animation over
                        mov player2.walksequence, 0
                    .endif
                    mov player2.walkanimationCD, 0
                .endif
            .else
                ; the player is dashing
                .if player2.dashanimationCD != 2
                    inc player2.dashanimationCD
                .else
                    inc player2.dashsequence
                    .if player2.dashsequence == 12
                        ; dash over
                        mov player2.dashsequence, 0
                        .if player2.playerObj.speed.x == DASH_SPEED
                            mov player2.playerObj.speed.x, PLAYER_SPEED
                        .elseif player2.playerObj.speed.x == -DASH_SPEED
                            mov player2.playerObj.speed.x, -PLAYER_SPEED
                        .endif
                        .if player2.playerObj.speed.y == DASH_SPEED
                            mov player2.playerObj.speed.y, PLAYER_SPEED
                        .elseif player2.playerObj.speed.y == -DASH_SPEED
                            mov player2.playerObj.speed.y, -PLAYER_SPEED
                        .endif

                        ;mov player2.playerObj.speed.x, 0
                        ;mov player2.playerObj.speed.y, 0
                    .endif
                    mov player2.dashanimationCD, 0
                .endif
            .endif

            invoke movePlayer, addr player1
            invoke movePlayer, addr player2
            
            
            invoke updateDirection, addr player1.playerObj
            invoke updateDirection, addr player2.playerObj

            invoke fixArrowCoordinates, addr arrow1
            invoke fixArrowCoordinates, addr arrow2

            invoke fixCoordinates, addr player1
            invoke fixCoordinates, addr player2

            invoke InvalidateRect, hWnd, NULL, TRUE
        .endw
    ret
gameManager endp

;_____________________________________________________________________________________________________________________________


changePlayerSpeed proc uses eax addrPlayer : DWORD, direction : BYTE, keydown : BYTE
    assume eax: ptr player
    mov eax, addrPlayer

    .if keydown == FALSE
        .if direction == 0 ;w
            .if [eax].playerObj.speed.y > 7fh
                mov [eax].playerObj.speed.y, 0 
            .endif
        .elseif direction == 1 ;a
            .if [eax].playerObj.speed.x > 7fh
                mov [eax].playerObj.speed.x, 0 
            .endif
        .elseif direction == 2 ;s
            .if [eax].playerObj.speed.y < 80h
                mov [eax].playerObj.speed.y, 0 
            .endif
        .elseif direction == 3 ;d
            .if [eax].playerObj.speed.x < 80h
                mov [eax].playerObj.speed.x, 0 
            .endif
        .endif
    .else
        .if [eax].dashsequence == 0
            .if direction == 0 ; w
                mov [eax].playerObj.speed.y, -PLAYER_SPEED
                mov [eax].stopped, 0
            .elseif direction == 1 ; s
                mov [eax].playerObj.speed.y, PLAYER_SPEED
                mov [eax].stopped, 0
            .elseif direction == 2 ; a
                mov [eax].playerObj.speed.x, -PLAYER_SPEED
                mov [eax].stopped, 0
            .elseif direction == 3 ; d
                mov [eax].playerObj.speed.x, PLAYER_SPEED
                mov [eax].stopped, 0
            .endif
        .else
            .if direction == 0 ; w
                mov [eax].playerObj.speed.y, -DASH_SPEED
                mov [eax].stopped, 0
            .elseif direction == 1 ; s
                mov [eax].playerObj.speed.y, DASH_SPEED
                mov [eax].stopped, 0
            .elseif direction == 2 ; a
                mov [eax].playerObj.speed.x, -DASH_SPEED
                mov [eax].stopped, 0
            .elseif direction == 3 ; d
                mov [eax].playerObj.speed.x, DASH_SPEED
                mov [eax].stopped, 0
            .endif
        .endif
    .endif

    assume ecx: nothing
    ret
changePlayerSpeed endp



;_____________________________________________________________________________________________________________________________
;_____________________________________________________________________________________________________________________________
;_____________________________________________________________________________________________________________________________

; _ WINMAIN __________________________________________________________________________________________________________________
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD 
    LOCAL wc:WNDCLASSEX                                               ; create local variables on stack 
    LOCAL msg:MSG 

    mov   wc.cbSize,SIZEOF WNDCLASSEX ; fill values in members of wc 
    mov   wc.style, CS_HREDRAW or CS_VREDRAW 
    mov   wc.lpfnWndProc, OFFSET WndProc 
    mov   wc.cbClsExtra,NULL 
    mov   wc.cbWndExtra,NULL 
    push  hInstance 
    pop   wc.hInstance 
    mov   wc.hbrBackground, COLOR_WINDOW + 1; black window
    mov   wc.lpszMenuName,NULL 
    mov   wc.lpszClassName ,OFFSET ClassName 
    invoke LoadIcon, NULL, IDI_APPLICATION 
    mov   wc.hIcon,eax 
    mov   wc.hIconSm,eax 
    invoke LoadCursor, NULL,IDC_ARROW 
    mov   wc.hCursor, eax 
    invoke RegisterClassEx, addr wc ; register our window class 
    invoke CreateWindowEx,NULL,\ 
                ADDR ClassName,\ 
                ADDR AppName,\ 
                WS_OVERLAPPEDWINDOW,\ 
                CW_USEDEFAULT,\ 
                CW_USEDEFAULT,\ 
                CW_USEDEFAULT,\ 
                CW_USEDEFAULT,\ 
                NULL,\ 
                NULL,\ 
                hInst,\ 
                NULL 
    mov   hWnd,eax 
    invoke ShowWindow, hWnd, CmdShow                                  ; display our window on desktop 
    invoke UpdateWindow, hWnd                                         ; refresh the client area

    .WHILE TRUE                                                       ; Enter message loop 
                invoke GetMessage, ADDR msg,NULL,0,0 
                .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg 
                invoke DispatchMessage, ADDR msg 
    .ENDW 
    mov     eax,msg.wParam                                            ; return exit code in eax 
    ret 
WinMain endp

WndProc proc _hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
    LOCAL direction : BYTE
    LOCAL keydown   : BYTE
    mov direction, -1
    mov keydown, -1


    .IF uMsg == WM_CREATE
        invoke loadImages

        mov eax, offset gameManager 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread1ID 
        invoke CloseHandle, eax 

        mov eax, offset paintThread
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr thread2ID
        invoke CloseHandle, eax
    ;____________________________________________________________________________

    .ELSEIF uMsg == WM_DESTROY                                        ; if the user closes our window 
        invoke PostQuitMessage,NULL                                   ; quit our application 
    
    .ELSEIF uMsg == WM_PAINT
        invoke updateScreen
    ;_____________________________________________________________________________
    .ELSEIF uMsg == WM_CHAR
        ;mov eax, offset gameManager
        ;invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 
        ;invoke CloseHandle, eax

    .ELSEIF uMsg == WM_KEYUP
    ; PLAYER 1 ____________________________________________________________________
    ;.if player1.dashsequence == 0

        ; TODO: FAZER VARIAVEL QUE GUARDA SE O KEYUP FOI APERTADO OU NAO

        .if (wParam == 77h || wParam == 57h) ;w
            ;.if (player1.playerObj.speed.y > 7fh) 
            ;    mov player1.playerObj.speed.y, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 0

        .elseif (wParam == 61h || wParam == 41h) ;a
            ;.if (player1.playerObj.speed.x > 7fh) 
            ;    mov player1.playerObj.speed.x, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 1

        .elseif (wParam == 73h || wParam == 53h) ;s
            ;.if (player1.playerObj.speed.y < 80h) 
            ;    mov player1.playerObj.speed.y, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 2

        .elseif (wParam == 64h || wParam == 44h) ;d
            ;.if (player1.playerObj.speed.x < 80h) 
            ;    mov player1.playerObj.speed.x, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 3

        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR player1, direction, keydown
            mov direction, -1
            mov keydown, -1
        .endif

    ;.endif
;________________________________________________________________________________
;________________________________________________________________________________
        
    ; PLAYER 2 __________________________________________________________________
    ;.if player2.dashsequence == 0
        .if (wParam == VK_UP) ;up arrow
            ;.if (player2.playerObj.speed.y > 7fh) 
            ;    mov player2.playerObj.speed.y, 0
            ;.endif
            mov keydown, FALSE
            mov direction, 0

        .elseif (wParam == VK_LEFT) ;down arrow
            ;.if (player2.playerObj.speed.y < 80h) 
            ;    mov player2.playerObj.speed.y, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 1

        .elseif (wParam == VK_DOWN) ;left arrow
            ;.if (player2.playerObj.speed.x > 7fh) 
            ;    mov player2.playerObj.speed.x, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 2

        .elseif (wParam == VK_RIGHT) ;right arrow
            ;.if (player2.playerObj.speed.x < 80h)
            ;    mov player2.playerObj.speed.x, 0 
            ;.endif
            mov keydown, FALSE
            mov direction, 3

        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR player2, direction, keydown
            mov direction, -1
            mov keydown, -1
        .endif
    ;.endif
;________________________________________________________________________________
;________________________________________________________________________________

    .ELSEIF uMsg == WM_KEYDOWN

    ;___________________PLAYER 1 MOVEMENT KEYS____________________________________
    ;.if player1.dashsequence == 0
        .if (wParam == 57h) ; w
            ;mov player1.playerObj.speed.y, -PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 0

        .elseif (wParam == 53h) ; s
            ;mov player1.playerObj.speed.y, PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 1

        .elseif (wParam == 41h) ; a
            ;mov player1.playerObj.speed.x, -PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 2

        .elseif (wParam == 44h) ; d
            ;mov player1.playerObj.speed.x, PLAYER_SPEED
            ;mov player1.stopped, 0
            mov keydown, TRUE
            mov direction, 3

        .elseif (wParam == 46h) ; f
            .if player1CanDash == 1 && player1.stopped == 0
                mov player1DashClick, 1                              ; means the player CAN and WANTS TO dash
            .endif
        .elseif (wParam == 47h) ; g
            .if arrow1.playerOwns != 0              ;if has arrow, can shoot
                mov arrow1.remainingDistance, 800 
                mov arrow1.playerOwns, 0
                
                mov ah, player1.direction
                mov arrow1.direction, ah
                
                mov arrow1.onGround, FALSE
                mov eax, player1.playerObj.pos.x
                mov arrow1.arrowObj.pos.x, eax

                mov eax, player1.playerObj.pos.y
                mov arrow1.arrowObj.pos.y, eax  
            .endif
        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR player1, direction, keydown
            mov direction, -1
            mov keydown, -1
        .endif
    ;.endif

    ;.if player2.dashsequence == 0
        .if (wParam == VK_UP) ;up arrow
            ;mov player2.playerObj.speed.y, -PLAYER_SPEED
            ;mov player2.stopped, 0
            mov direction, 0
            mov keydown, TRUE

        .elseif (wParam == VK_DOWN) ;down arrow 
            ;mov player2.playerObj.speed.y, PLAYER_SPEED
            ;mov player2.stopped, 0
            mov direction, 1
            mov keydown, TRUE

        .elseif (wParam == VK_LEFT) ;left arrow
            ;mov player2.playerObj.speed.x, -PLAYER_SPEED
            ;mov player2.stopped, 0
            mov direction, 2
            mov keydown, TRUE

        .elseif (wParam == VK_RIGHT) ;right arrow
            ;mov player2.playerObj.speed.x, PLAYER_SPEED
            ;mov player2.stopped, 0
            mov direction, 3
            mov keydown, TRUE

        .elseif (wParam == 193) ;      ;
            .if player2CanDash == 1 && player2.stopped == 0
                mov player2DashClick, 1     ; means the player CAN and WANTS TO dash                
            .endif
        .elseif (wParam== 191)  ;     .
            .if arrow2.playerOwns != 0              ;if has arrow, can shoot
                mov arrow2.remainingDistance, 800 
                mov arrow2.playerOwns, 0
                
                mov ah, player2.direction
                mov arrow2.direction, ah
                
                mov arrow2.onGround, FALSE
                mov eax, player2.playerObj.pos.x
                mov arrow2.arrowObj.pos.x, eax

                mov eax, player2.playerObj.pos.y
                mov arrow2.arrowObj.pos.y, eax  
            .endif
        .endif

        .if direction != -1
            invoke changePlayerSpeed, ADDR player2, direction, keydown
            mov direction, -1
            mov keydown, -1
        .endif

        ; invoke wsprintf, ADDR buffer, ADDR test_header_format, wParam
        ; invoke MessageBox, NULL, ADDR buffer, ADDR msgBoxTitle, MB_OKCANCEL 
    ;.endif

    .ELSE   

        invoke DefWindowProc,_hWnd,uMsg,wParam,lParam                  ; Default message processing 
        ret 

    .ENDIF

    xor eax,eax 
    ret 
WndProc endp

;_ END PROCEDURES ______________________________________________________________________

end start