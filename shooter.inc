include \masm32\include\windows.inc 
include \masm32\include\user32.inc 
include \masm32\include\kernel32.inc 
include \masm32\include\gdi32.inc
;include C:\masm32\include\gdi32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\gdi32.lib
;includelib C:\masm32\lib\gdi32.lib   ; pode muda depois so fiz isso pra consegui usa em casa

;include C:\masm32\include\windows.inc
;include C:\masm32\include\masm32.inc
;include C:\masm32\include\gdi32.inc
;include C:\masm32\include\user32.inc
;include C:\masm32\include\kernel32.inc
;include C:\masm32\include\Comctl32.inc
;include C:\masm32\include\comdlg32.inc
;include C:\masm32\include\shell32.inc
;include C:\masm32\include\msimg32.inc

;includelib C:\masm32\lib\masm32.lib
;includelib C:\masm32\lib\gdi32.lib
;includelib C:\masm32\lib\user32.lib
;includelib C:\masm32\lib\kernel32.lib
;includelib C:\masm32\lib\Comctl32.lib
;includelib C:\masm32\lib\comdlg32.lib
;includelib C:\masm32\lib\shell32.lib
;includelib C:\masm32\lib\msimg32.lib

point struct 
    x dd 0      
    y dd 0
point ends

gameObject struct
    pos   point <>
    speed point <> ; horizontal and vertical speeds
gameObject ends

player struct
    playerObj gameObject <>

    life      BYTE 2
    direction BYTE 0
player ends


.CONST
    D_TOP_LEFT   EQU 0
    D_TOP        EQU 1
    D_TOP_RIGHT  EQU 2
    D_RIGHT      EQU 3
    D_DOWN_RIGHT EQU 4
    D_DOWN       EQU 5
    D_DOWN_LEFT  EQU 6
    D_LEFT       EQU 7

    PLAYER_SIZE  EQU 50
    PLAYER_HALF_SIZE EQU PLAYER_SIZE / 2

    PLAYER_SPEED EQU 6

.DATA
    ;Player 1 Bitmaps:
    h_V1_top_left       dd 0
    h_V1_top            dd 0
    h_V1_top_right      dd 0
    h_V1_right          dd 0
    h_V1_down_right     dd 0
    h_V1_down           dd 0
    h_V1_down_left      dd 0
    h_V1_left           dd 0

    ;Player 2 Bitmaps:
    h_V2_top_left       dd 0
    h_V2_top            dd 0
    h_V2_top_right      dd 0
    h_V2_right          dd 0
    h_V2_down_right     dd 0
    h_V2_down           dd 0
    h_V2_down_left      dd 0
    h_V2_left           dd 0

    test_header_format  db  "%d",0
    buffer              db 256 dup(?)
    msgBoxTitle         db "Testing",0

    over byte 0                                ; control game state (occuring or terminated)

    ; Players
    player1 player <<<100,100>, <0,0>>, 2, D_LEFT>
    player2 player <<<200,200>, <0,0>>, 2, D_DOWN_LEFT>

.DATA?
    hWnd HWND ?
    threadID DWORD ?

    