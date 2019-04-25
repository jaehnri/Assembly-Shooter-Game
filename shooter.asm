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
    ; Loading Player 1's Bitmaps:

    invoke LoadBitmap, hInstance, 100       
    mov h_V1_top_left, eax

    invoke LoadBitmap, hInstance, 101       
    mov h_V1_top, eax

    invoke LoadBitmap, hInstance, 102       
    mov h_V1_top_right, eax

    invoke LoadBitmap, hInstance, 103       
    mov h_V1_right, eax

    invoke LoadBitmap, hInstance, 104       
    mov h_V1_down_right, eax

    invoke LoadBitmap, hInstance, 105       
    mov h_V1_down, eax

    invoke LoadBitmap, hInstance, 106       
    mov h_V1_down_left, eax

    invoke LoadBitmap, hInstance, 107       
    mov h_V1_left, eax


    ;Loading Player 2's Bitmaps:

    invoke LoadBitmap, hInstance, 108       
    mov h_V2_top_left, eax

    invoke LoadBitmap, hInstance, 109       
    mov h_V2_top, eax

    invoke LoadBitmap, hInstance, 110       
    mov h_V2_top_right, eax

    invoke LoadBitmap, hInstance, 111       
    mov h_V2_right, eax

    invoke LoadBitmap, hInstance, 112       
    mov h_V2_down_right, eax

    invoke LoadBitmap, hInstance, 113       
    mov h_V2_down, eax

    invoke LoadBitmap, hInstance, 114       
    mov h_V2_down_left, eax

    invoke LoadBitmap, hInstance, 115       
    mov h_V2_left, eax

    ret
loadImages endp

;printPlayer proc

paintPlayers proc _hdc:HDC, _hMemDC:HDC
    ;PLAYER 1___________________________________________
        .if player1.direction == D_TOP_LEFT
            invoke SelectObject, _hMemDC, h_V1_top_left
        
        .elseif player1.direction == D_TOP
            invoke SelectObject, _hMemDC, h_V1_top

        .elseif player1.direction == D_TOP_RIGHT
            invoke SelectObject, _hMemDC, h_V1_top_right 

        .elseif player1.direction == D_RIGHT
            invoke SelectObject, _hMemDC, h_V1_right 

        .elseif player1.direction == D_DOWN_RIGHT
            invoke SelectObject, _hMemDC, h_V1_down_right 

        .elseif player1.direction == D_DOWN
            invoke SelectObject, _hMemDC, h_V1_down 

        .elseif player1.direction == D_DOWN_LEFT
            invoke SelectObject, _hMemDC, h_V1_down_left 

        .elseif player1.direction == D_LEFT ;left is the last possible direction
            invoke SelectObject, _hMemDC, h_V1_left  
        .endif  

    ;________PLAYER 1 PAINTING_____________________________________________________________

        mov eax, player1.playerObj.pos.x
        mov ebx, player1.playerObj.pos.y
        sub eax, PLAYER_HALF_SIZE
        sub ebx, PLAYER_HALF_SIZE

        invoke BitBlt, _hdc, eax, ebx, PLAYER_SIZE, PLAYER_SIZE, _hMemDC, 0, 0, SRCCOPY 
    ;_______________________________________________________________________________________


    ;PLAYER 2___________________________________________
        .if player2.direction == D_TOP_LEFT
            invoke SelectObject, _hMemDC, h_V2_top_left
        
        .elseif player2.direction == D_TOP
            invoke SelectObject, _hMemDC, h_V2_top

        .elseif player2.direction == D_TOP_RIGHT
            invoke SelectObject, _hMemDC, h_V2_top_right 

        .elseif player2.direction == D_RIGHT
            invoke SelectObject, _hMemDC, h_V2_right 

        .elseif player2.direction == D_DOWN_RIGHT
            invoke SelectObject, _hMemDC, h_V2_down_right 

        .elseif player2.direction == D_DOWN
            invoke SelectObject, _hMemDC, h_V2_down 

        .elseif player2.direction == D_DOWN_LEFT
            invoke SelectObject, _hMemDC, h_V2_down_left 

        .else ;left is the last possible direction
            invoke SelectObject, _hMemDC, h_V2_left  
        .endif 

    ;________PLAYER 2 PAINTING________________________________________________________________________

        mov eax, player2.playerObj.pos.x
        mov ebx, player2.playerObj.pos.y
        sub eax, PLAYER_HALF_SIZE
        sub ebx, PLAYER_HALF_SIZE

        invoke BitBlt, _hdc, eax, ebx, PLAYER_SIZE, PLAYER_SIZE, _hMemDC, 0, 0, SRCCOPY 
    ;________________________________________________________________________________
    
    ret
paintPlayers endp

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

    invoke paintPlayers, hDC, hMemDC

    invoke DeleteDC, hMemDC
    invoke EndPaint, hWnd, ADDR paintstruct

    ret
updateScreen endp
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

    .if [eax].direction == D_TOP_LEFT
        add [eax].playerObj.pos.x, -DASH_DISTANCE
        add [eax].playerObj.pos.y, -DASH_DISTANCE
    
    .elseif [eax].direction == D_TOP
        add [eax].playerObj.pos.y, -DASH_DISTANCE

    .elseif [eax].direction == D_TOP_RIGHT
        add [eax].playerObj.pos.x,  DASH_DISTANCE
        add [eax].playerObj.pos.y, -DASH_DISTANCE
    
    .elseif [eax].direction == D_RIGHT
        add [eax].playerObj.pos.x,  DASH_DISTANCE

    .elseif [eax].direction == D_DOWN_RIGHT
        add [eax].playerObj.pos.x,  DASH_DISTANCE
        add [eax].playerObj.pos.y,  DASH_DISTANCE

    .elseif [eax].direction == D_DOWN
        add [eax].playerObj.pos.y,  DASH_DISTANCE

    .elseif [eax].direction == D_DOWN_LEFT
        add [eax].playerObj.pos.x, -DASH_DISTANCE
        add [eax].playerObj.pos.y,  DASH_DISTANCE

    .elseif [eax].direction == D_LEFT
        add [eax].playerObj.pos.x,  -DASH_DISTANCE
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

fixCoordinates proc addrPlayer:dword
assume eax:ptr player
    mov eax, addrPlayer

    .if [eax].playerObj.pos.x > 1230
        mov [eax].playerObj.pos.x, 20
    .endif

    .if [eax].playerObj.pos.x <= 10
        mov [eax].playerObj.pos.x, 1200 
    .endif


    .if [eax].playerObj.pos.y > 700
        mov [eax].playerObj.pos.y, 20
    .endif

    .if [eax].playerObj.pos.y <= 10
        mov [eax].playerObj.pos.y, 695 
    .endif
ret
fixCoordinates endp
;______________________________________________________________________________


gameManager proc p:dword
        .while !over
            invoke Sleep, 30


            .if player2.cooldownDash  != 10
                inc player2.cooldownDash
            .else
                mov player2CanDash, 1
            .endif

            .if player1.cooldownDash != 10
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

            invoke movePlayer, addr player1
            invoke movePlayer, addr player2
            
            invoke updateDirection, addr player1.playerObj
            invoke updateDirection, addr player2.playerObj

            invoke fixCoordinates, addr player1
            invoke fixCoordinates, addr player2

            invoke InvalidateRect, hWnd, NULL, TRUE
        .endw
    ret
gameManager endp



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
    mov   wc.hbrBackground, COLOR_WINDOW + 3 ; black window
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

    .IF uMsg == WM_CREATE
        invoke loadImages

        mov eax, offset gameManager 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 
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
        .if (wParam == 77h || wParam == 57h) ;w
            .if (player1.playerObj.speed.y > 7fh) 
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 61h || wParam == 41h) ;a
            .if (player1.playerObj.speed.x > 7fh) 
                mov player1.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == 73h || wParam == 53h) ;s
            .if (player1.playerObj.speed.y < 80h) 
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 64h || wParam == 44h) ;d
            .if (player1.playerObj.speed.x < 80h) 
                mov player1.playerObj.speed.x, 0 
            .endif
            
;________________________________________________________________________________
;________________________________________________________________________________
        
    ; PLAYER 2 __________________________________________________________________
        .elseif (wParam == VK_UP) ;up arrow
            .if (player2.playerObj.speed.y > 7fh) 
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_DOWN) ;down arrow
            .if (player2.playerObj.speed.y < 80h) 
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_LEFT) ;left arrow
            .if (player2.playerObj.speed.x > 7fh) 
                mov player2.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == VK_RIGHT) ;right arrow
            .if (player2.playerObj.speed.x < 80h)
                mov player2.playerObj.speed.x, 0 
            .endif
        .endif

;________________________________________________________________________________
;________________________________________________________________________________

    .ELSEIF uMsg == WM_KEYDOWN    

    ;___________________PLAYER 1 MOVEMENT KEYS____________________________________
        .if (wParam == 57h) ; w
            mov player1.playerObj.speed.y, -PLAYER_SPEED
        .elseif (wParam == 53h) ; s
            mov player1.playerObj.speed.y, PLAYER_SPEED
        .elseif (wParam == 41h) ; a
            mov player1.playerObj.speed.x, -PLAYER_SPEED
        .elseif (wParam == 44h) ; d
            mov player1.playerObj.speed.x, PLAYER_SPEED
        .elseif (wParam == 46h) ; f
            .if player1CanDash == 1
                mov player1DashClick, 1                              ; means the player CAN and WANTS TO dash                
            .endif

        .elseif (wParam == VK_UP) ;up arrow
            mov player2.playerObj.speed.y, -PLAYER_SPEED
        .elseif (wParam == VK_DOWN) ;down arrow 
            mov player2.playerObj.speed.y, PLAYER_SPEED
        .elseif (wParam == VK_LEFT) ;left arrow
            mov player2.playerObj.speed.x, -PLAYER_SPEED
        .elseif (wParam == VK_RIGHT) ;right arrow
             mov player2.playerObj.speed.x, PLAYER_SPEED
        .elseif (wParam == 4Ch) ; l
            .if player2CanDash == 1
                mov player2DashClick, 1                              ; means the player CAN and WANTS TO dash                
            .endif
        .endif 
    
    .ELSE   

        invoke DefWindowProc,_hWnd,uMsg,wParam,lParam                  ; Default message processing 
        ret 

    .ENDIF

    xor eax,eax 
    ret 
WndProc endp

;_ END PROCEDURES ______________________________________________________________________

end start