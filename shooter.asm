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
    mov h_V1_right, eax


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
    mov h_V2_right, eax

    ret
loadImages endp

;printPlayer proc

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

    invoke SelectObject, hMemDC, h_V1_top_left

    ;invoke TransparentBlt, hDC, 0, 0,\
    ;    50, 50, hMemDC,\    
    ;    0, 0, 50, 50, 16777215
    invoke BitBlt, hDC, 0, 0, 50, 50, hMemDC, 0, 0, SRCCOPY 

    invoke DeleteDC, hMemDC
    invoke EndPaint, hWnd, ADDR paintstruct

    ret
updateScreen endp




;PaintToScreen proc _hDC:DWORD, _hMemDC:DWORD
;    invoke SelectObject, _hMemDC, hTankPosition1 



; _ WINMAIN __________________________________________________________________________________
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

    .ELSEIF uMsg == WM_DESTROY                                        ; if the user closes our window 
        invoke PostQuitMessage,NULL                                   ; quit our application 
    
    .ELSEIF uMsg == WM_PAINT
        invoke updateScreen

    .ELSE   
        invoke DefWindowProc,_hWnd,uMsg,wParam,lParam                  ; Default message processing 
        ret 
    .ENDIF
    xor eax,eax 
    ret 
WndProc endp

;_ END PROCEDURES ______________________________________________________________________

end start