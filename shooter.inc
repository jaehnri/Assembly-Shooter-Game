include c:\masm32\include\masm32rt.inc

;include \masm32\include\windows.inc 
;include \masm32\include\user32.inc 
;include \masm32\include\kernel32.inc 
;include \masm32\include\gdi32.inc
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

    cooldownDash BYTE 0
    life         BYTE 2
    direction    BYTE 0
player ends

arrow struct
    arrowObj          gameObject <>

    remainingDistance DWORD 0    ; DISTANCE REMAINING TIL IT STOPS
    playerOwns        BYTE  1
    stopped           BYTE  0
    owner             BYTE  0    ; IF 1 -> PLAYER1 
    direction         BYTE  0    ; IF 2 -> PLAYER2 
arrow ends                                                      
                      


.CONST
    WINDOW_SIZE_X EQU 1200
    WINDOW_SIZE_Y EQU 700

    D_TOP_LEFT    EQU 0
    D_TOP         EQU 1
    D_TOP_RIGHT   EQU 2
    D_RIGHT       EQU 3
    D_DOWN_RIGHT  EQU 4
    D_DOWN        EQU 5
    D_DOWN_LEFT   EQU 6
    D_LEFT        EQU 7

    PLAYER_SIZE      EQU 50
    PLAYER_HALF_SIZE EQU PLAYER_SIZE / 2
    ARROW_SIZE       EQU 46
    ARROW_HALF_SIZE  EQU ARROW_SIZE / 2

    PLAYER_SPEED  EQU 6
    ARROW_SPEED   EQU 50

    DASH_DISTANCE EQU 100

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

    ;Arrow 1 Bitmaps:
    h_A1_left           dd 0

    test_header_format  db  "A: %d",13,10,0
    buffer              db 256 dup(?)
    msgBoxTitle         db "Testing",0

    over byte 0                                ; control game state (occuring or terminated)

    ; Players
    player1 player <<<100,350>,  <0,0>>, 0, 2, D_RIGHT>  ; dash initialized as 8 because 0 to 7 are directions, so 8 is the same as null 
    player2 player <<<1120,350>, <0,0>>, 0, 2, D_LEFT>

    arrow1 arrow <<<50, 50>, <ARROW_SPEED, ARROW_SPEED>>, 0, 1, 1, 1, 8>  
    arrow2 arrow <<<50, 50>, <ARROW_SPEED, ARROW_SPEED>>, 0, 1, 1, 2, 8>

    player1CanDash        BYTE 0
    player2CanDash        BYTE 0

    player1DashClick      BYTE 0
    player2DashClick      BYTE 0

    arrow1Shot            BYTE 0
    arrow2Shot            BYTE 0 

.DATA?
    hWnd HWND ?
    threadID DWORD ?

    