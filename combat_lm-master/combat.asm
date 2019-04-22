.386
.model flat, stdcall
option casemap :none

include combat.inc

.data
    ;Estruturas dos jogadores:
    player1 player <MAX_LIFE, 7, <IMG_SIZE, WIN_HT / 2, <0, 0>>>
    player2 player <MAX_LIFE, 3, <WIN_WD - IMG_SIZE, WIN_HT / 2, <0, 0>>>

    isShooting pair <0, 0> ;Indica se cada jogador está atirando
    canPlyrsMov pair <0, 0> ;Indica se cada jogador pode se mover

    scoreP1 pair <48 + 0, 48 + 0> ;Score do primeiro jogador
    scoreP2 pair <48 + 0, 48 + 0> ;Score do segundo jogador

    maxScore pair <48 + 0, 48 + 5> ;Score máximo

    hit db FALSE ;Indica se algum jogador pontuo

    ;Listas ligada de tiros:
    ;Player1:
    fShot1 dword 0 ;Primeiro nó
    lShot1 dword 0 ;Último nó
    numShots1 byte 0 ;Número de nós

    ;Player2:
    fShot2 dword 0 ;Primeiro nó
    lShot2 dword 0 ;Último nó
    numShots2 byte 0 ;Número de nós

    shotsDelays pair <0, 0> ;Delay dos tiros

    over byte 0 ;Indica se o jogo acabou

.code 
start:

invoke GetModuleHandle, NULL
mov hInstance, eax

invoke WinMain, hInstance, SW_SHOWDEFAULT
invoke ExitProcess, eax

loadBitmaps proc ;Carrega os bitmaps do jogo:
    ;imagens do primeiro jogador:
    invoke LoadBitmap, hInstance, 100
    mov h100, eax

    invoke LoadBitmap, hInstance, 101
    mov h101, eax

    invoke LoadBitmap, hInstance, 102
    mov h102, eax

    invoke LoadBitmap, hInstance, 103
    mov h103, eax

    invoke LoadBitmap, hInstance, 104
    mov h104, eax

    invoke LoadBitmap, hInstance, 105
    mov h105, eax

    invoke LoadBitmap, hInstance, 106
    mov h106, eax

    invoke LoadBitmap, hInstance, 107
    mov h107, eax	

    ;imagens do segundo jogador:
    invoke LoadBitmap, hInstance, 110
    mov h110, eax

    invoke LoadBitmap, hInstance, 111
    mov h111, eax

    invoke LoadBitmap, hInstance, 112
    mov h112, eax

    invoke LoadBitmap, hInstance, 113
    mov h113, eax

    invoke LoadBitmap, hInstance, 114
    mov h114, eax

    invoke LoadBitmap, hInstance, 115
    mov h115, eax

    invoke LoadBitmap, hInstance, 116
    mov h116, eax

    invoke LoadBitmap, hInstance, 117
    mov h117, eax	

    ret
loadBitmaps endp

WinMain proc hInst:HINSTANCE, CmdShow:dword
    local clientRect:RECT
    local wc:WNDCLASSEX                                            
    local msg:MSG 

    ;Fill values in members of wc
    mov wc.cbSize, SIZEOF WNDCLASSEX  
    mov wc.style, CS_BYTEALIGNWINDOW or CS_BYTEALIGNCLIENT
    mov wc.lpfnWndProc, OFFSET WndProc 
    mov wc.cbClsExtra, NULL 
    mov wc.cbWndExtra, NULL 

    push hInstance 
    pop wc.hInstance 

    mov wc.hbrBackground, COLOR_WINDOW + 1 
    mov wc.lpszMenuName, NULL 
    mov wc.lpszClassName, OFFSET ClassName 

    invoke LoadIcon, hInstance, 500 
    mov wc.hIcon, eax 
    mov wc.hIconSm, eax

    invoke LoadCursor, NULL, IDC_ARROW 
    mov wc.hCursor, eax 

    invoke RegisterClassEx, addr wc ;Register our window class 

    mov clientRect.left, 0
    mov clientRect.top, 0
    mov clientRect.right, WIN_WD
    mov clientRect.bottom, WIN_HT

    invoke AdjustWindowRect, addr clientRect, WS_CAPTION, FALSE

    mov eax, clientRect.right
    sub eax, clientRect.left
    mov ebx, clientRect.bottom
    sub ebx, clientRect.top

    invoke CreateWindowEx, NULL, addr ClassName, addr AppName,\ 
        WS_OVERLAPPED or WS_SYSMENU or WS_MINIMIZEBOX,\ 
        CW_USEDEFAULT, CW_USEDEFAULT,\
        eax, ebx, NULL, NULL, hInst, NULL 

    mov hWnd, eax 
    invoke ShowWindow, hWnd, CmdShow ;Display our window on desktop 
    invoke UpdateWindow, hWnd ;Refresh the client area

    ;Enter message loop
    .while TRUE  
        invoke GetMessage, addr msg, NULL, 0, 0 
        .break .if (!eax)       

        invoke TranslateMessage, addr msg 
        invoke DispatchMessage, addr msg
    .endw 

    mov eax, msg.wParam ;Return exit code in eax 

    ret 
WinMain endp

WndProc proc _hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM ;wParam -  
                                                            ;Parametro recebido
                                                            ;do Windows
    .if uMsg == WM_CREATE ;Carrega as imagens e cria a thread principal:---------
;________________________________________________________________________________

        invoke loadBitmaps

        mov eax, offset gameHandler 
        invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 

        invoke CloseHandle, eax 
;________________________________________________________________________________

    .elseif uMsg == WM_DESTROY ;If the user closes the window  
        invoke PostQuitMessage, NULL ;Quit the application 
    .elseif uMsg == WM_CHAR ;Keydown printable:----------------------------------
;________________________________________________________________________________

        ;Teclas de movimento player1:
        .if (wParam == 77h || wParam == 57h) ;w
            mov player1.playerObj.speed.y, -SPEED 
        .elseif (wParam == 61h || wParam == 41h) ;a
            mov player1.playerObj.speed.x, -SPEED
        .elseif (wParam == 73h || wParam == 53h) ;s
            mov player1.playerObj.speed.y, SPEED
        .elseif (wParam == 64h || wParam == 44h) ;d
            mov player1.playerObj.speed.x, SPEED
;________________________________________________________________________________

        .elseif (wParam == 79h || wParam == 59h) ;y - Tiro player1:
            mov isShooting.x, TRUE
        .elseif (wParam == 75h || wParam == 55h) ;u - Especial player1:
;________________________________________________________________________________

        .elseif (wParam == 32h) ;2 - Tiro player2:
            mov isShooting.y, TRUE      
        .elseif (wParam == 33h) ;3 - Especial player2:
        .elseif (wParam == 72h) ;r - Reinicia o jogo
            .if over
                mov over, FALSE 

                ;Zera os scores:
				mov scoreP1.x, 48 + 0
                mov scoreP1.y, 48 + 0

                mov scoreP2.x, 48 + 0
                mov scoreP2.y, 48 + 0

                mov eax, offset gameHandler 
                invoke CreateThread, NULL, NULL, eax, 0, 0, addr threadID 

                invoke CloseHandle, eax
            .endif
        .endif
;________________________________________________________________________________
        
    .elseif uMsg == WM_KEYDOWN ;Keydown nonprintable:----------------------------
;________________________________________________________________________________

        ;Teclas de movimento player2:
        .if (wParam == VK_UP) ;seta cima
            mov player2.playerObj.speed.y, -SPEED
        .elseif (wParam == VK_DOWN) ;seta baixo
            mov player2.playerObj.speed.y, SPEED
        .elseif (wParam == VK_LEFT) ;seta esquerda
            mov player2.playerObj.speed.x, -SPEED
        .elseif (wParam == VK_RIGHT) ;seta direita
            mov player2.playerObj.speed.x, SPEED
        .endif
;________________________________________________________________________________

    .elseif uMsg == WM_KEYUP ;Keyup:---------------------------------------------
;________________________________________________________________________________

        ;Teclas de movimento player1:
        .if (wParam == 77h || wParam == 57h) ;w
            .if (player1.playerObj.speed.y > 7fh) ;Caso seja negativo:
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 61h || wParam == 41h) ;a
            .if (player1.playerObj.speed.x > 7fh) ;Caso seja negativo:
                mov player1.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == 73h || wParam == 53h) ;s
            .if (player1.playerObj.speed.y < 80h) ;Caso seja positivo:
                mov player1.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == 64h || wParam == 44h) ;d
            .if (player1.playerObj.speed.x < 80h) ;Caso seja positivo:
                mov player1.playerObj.speed.x, 0 
            .endif
;________________________________________________________________________________

        .elseif (wParam == 59h) ;y - Tiro player1:
            mov isShooting.x, FALSE
            mov shotsDelays.x, 0
        .elseif (wParam == 55h) ;u - Especial player1:
;________________________________________________________________________________

        .elseif (wParam == 62h) ;2 - Tiro player2:
            mov isShooting.y, FALSE
            mov shotsDelays.y, 0
        .elseif (wParam == 63h) ;3 - Especial player2:
;________________________________________________________________________________
        
        ;Teclas de movimento player2:
        .elseif (wParam == VK_UP) ;seta cima
            .if (player2.playerObj.speed.y > 7fh) ;Caso seja negativo:
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_DOWN) ;seta baixo
            .if (player2.playerObj.speed.y < 80h) ;Caso seja positivo:
                mov player2.playerObj.speed.y, 0 
            .endif
        .elseif (wParam == VK_LEFT) ;seta esquerda
            .if (player2.playerObj.speed.x > 7fh) ;Caso seja negativo:
                mov player2.playerObj.speed.x, 0 
            .endif
        .elseif (wParam == VK_RIGHT) ;seta direita
            .if (player2.playerObj.speed.x < 80h) ;Caso seja positivo:
                mov player2.playerObj.speed.x, 0 
            .endif
        .endif
;________________________________________________________________________________

    .elseif uMsg == WM_PAINT ;Atualizar da página:-------------------------------  
        invoke updateScreen
    .else ;Default:
        invoke DefWindowProc, _hWnd, uMsg, wParam, lParam ;Default processing 
        ret 
    .endif 

    xor eax, eax 

    ret 
WndProc endp

mult proc uses ebx edx n1:word, n2:word ;Multiplica dois números (16 b) e coloca em eax:
    xor eax, eax 
    xor edx, edx

    mov ax, n1
    mov bx, n2

    imul bx

    ;Move as duas partes para eax:
    shl edx, 16

    add eax, edx

    ret
mult endp

movObj proc uses eax addrObj:dword ;Atualiza a posição de um gameObj de acordo 
                        ;com sua velocidade:
    assume ecx:ptr gameObj
    mov ecx, addrObj

    ;Eixo x:---------------------------------------------------------------------
;________________________________________________________________________________

    mov ax, [ecx].x
    movzx bx, [ecx].speed.x

    .if bx > 7fh ;Caso seja negativo:
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].x, ax

    ;Eixo y:---------------------------------------------------------------------
;________________________________________________________________________________

    mov ax, [ecx].y
    movzx bx, [ecx].speed.y

    .if bx > 7fh ;Caso seja negativo:
        or bx, 65280
    .endif

    add ax, bx
    mov [ecx].y, ax
;________________________________________________________________________________
    
    assume ecx:nothing

    ret
movObj endp

movShots proc uses eax ;Move todos o tiros:
    assume eax:ptr node

    ;Move os tiros do player1
    mov eax, fShot1

    xor dl, dl
    mov dh, numShots1 
    .while dl < dh
        mov ecx, eax
        add ecx, 4
        invoke movObj, ecx

        mov eax, [eax].next

        inc dl
    .endw

    ;Move os tiros do player2
    mov eax, fShot2

    xor dl, dl
    mov dh, numShots2 
    .while dl < dh
        mov ecx, eax
        add ecx, 4
        invoke movObj, ecx

        mov eax, [eax].next

        inc dl
    .endw

    assume eax:nothing

    ret
movShots endp

canMov proc p1:gameObj, p2:gameObj ;Atualiza se cada jogador pode se mover:
    local d2:dword ;Quadrado da distância entre os jogadores
                   ;d^2 = (x2 - x1)^2 + (y2 - y1)^2

    ;Move a cópia dos jogadores para uma posição futura:-------------------------
;________________________________________________________________________________

    invoke movObj, addr p1 
    invoke movObj, addr p2   

    ;Calcula d2:-----------------------------------------------------------------
;________________________________________________________________________________

    ;Calcula (x2 - x1)^2 e coloca em d2:
    mov ax, p2.x 
    sub ax, p1.x
    invoke mult, ax, ax
    mov d2, eax

    ;Calcula (y2 - y1)^2 e soma em d2:
    mov ax, p2.y 
    sub ax, p1.y
    invoke mult, ax, ax
    add d2, eax

    ;Checa se os jogadores vão colidir:------------------------------------------
;________________________________________________________________________________   

    .if d2 < IMG_SIZE2
        mov canPlyrsMov.x, FALSE
        mov canPlyrsMov.y, FALSE
        ret
    .endif
    
    ;Checa se cada jogador vai sair da tela:-------------------------------------
;________________________________________________________________________________

    ;Player1:
    mov canPlyrsMov.x, FALSE
    .if p1.x <= OFFSETX && p1.x >= HALF_SIZE &&\
        p1.y <= OFFSETY && p1.y >= HALF_SIZE
        mov canPlyrsMov.x, TRUE    
    .endif

    ;Player2:
    mov canPlyrsMov.y, FALSE
    .if p2.x <= OFFSETX && p2.x >= HALF_SIZE &&\
        p2.y <= OFFSETY && p2.y >= HALF_SIZE
        mov canPlyrsMov.y, TRUE    
    .endif

    ret
canMov endp

checkCrashs proc uses ebx edx
    assume ebx:ptr node

    ;Checa se o jogador 2 foi atingido:
    mov ebx, fShot1

    xor dl, dl
    mov dh, numShots1
    .while dl < dh
        invoke checkShot, player2.playerObj, [ebx].value

        .if eax
			invoke checkShot, player2.playerObj, [ebx].value

            invoke incScore, addr scoreP1

            mov hit, TRUE

            .break .if (TRUE)
        .endif

        mov ebx, [ebx].next
        inc dl
    .endw

    ;Checa se o jogador 1 foi atingido:
    mov ebx, fShot2

    xor dl, dl
    mov dh, numShots2
    .while dl < dh
        invoke checkShot, player1.playerObj, [ebx].value

        .if eax
            invoke incScore, addr scoreP2

            mov hit, TRUE

            .break .if (TRUE)
        .endif

        mov ebx, [ebx].next
        inc dl
    .endw

    assume ebx:nothing

    ret
checkCrashs endp

checkShot proc plyr:gameObj, shot:gameObj
    local d2:dword ;Quadrado da distância entre o tiro e o jogador
                   ;d^2 = (xp - xs)^2 + (yp - ys)^2

    ;Calcula d2:-----------------------------------------------------------------
;________________________________________________________________________________

    ;Calcula (xp - xs)^2 e coloca em d2:
    mov ax, plyr.x 
    sub ax, shot.x
    invoke mult, ax, ax
    mov d2, eax

    ;Calcula (yp - ys)^2 e soma em d2:
    mov ax, plyr.y 
    sub ax, shot.y
    invoke mult, ax, ax
    add d2, eax

;Checa se o tiro vai colidir:----------------------------------------------------
;________________________________________________________________________________   

    .if d2 < D2_SHOT
        mov eax, TRUE
	.else 
		mov eax, FALSE
    .endif
    
    ret
checkShot endp

printPlyr proc plyr:player, _hdc:HDC, _hMemDC:HDC, whichImg:byte ;Desenha na tela um jogador:
    ;Seleciona qual imagem vai ser desenhada:
;________________________________________________________________________________
    ;Se for o primeiro jogador:
	.if whichImg
	    .if plyr.direc == 0
	        invoke SelectObject, _hMemDC, h100
	    .elseif plyr.direc == 1
	        invoke SelectObject, _hMemDC, h101
	    .elseif plyr.direc == 2
	        invoke SelectObject, _hMemDC, h102
	    .elseif plyr.direc == 3
	        invoke SelectObject, _hMemDC, h103
	    .elseif plyr.direc == 4
	        invoke SelectObject, _hMemDC, h104
	    .elseif plyr.direc == 5
	        invoke SelectObject, _hMemDC, h105
	    .elseif plyr.direc == 6
	        invoke SelectObject, _hMemDC, h106
	    .else
	        invoke SelectObject, _hMemDC, h107
	    .endif
	.else
    ;Se for o segundo jogador:
		.if plyr.direc == 0
	        invoke SelectObject, _hMemDC, h110
	    .elseif plyr.direc == 1
	        invoke SelectObject, _hMemDC, h111
	    .elseif plyr.direc == 2
	        invoke SelectObject, _hMemDC, h112
	    .elseif plyr.direc == 3
	        invoke SelectObject, _hMemDC, h113
	    .elseif plyr.direc == 4
	        invoke SelectObject, _hMemDC, h114
	    .elseif plyr.direc == 5
	        invoke SelectObject, _hMemDC, h115
	    .elseif plyr.direc == 6
	        invoke SelectObject, _hMemDC, h116
	    .else
	        invoke SelectObject, _hMemDC, h117
	    .endif
	.endif

    ;Calcula as coordenadas do ponto superior esquerdo:
;________________________________________________________________________________

    movzx eax, plyr.playerObj.x
    movzx ebx, plyr.playerObj.y
    sub eax, HALF_SIZE
    sub ebx, HALF_SIZE

;________________________________________________________________________________

    invoke TransparentBlt, _hdc, eax, ebx,\
        IMG_SIZE, IMG_SIZE, _hMemDC,\    
        0, 0, IMG_SIZE, IMG_SIZE, 16777215

    ret
printPlyr endp

printShots proc uses eax edx _hdc:HDC ;Desenha todos o tiros:
    local currShot:gameObj

    assume eax:ptr node

    ;Desenha os tiros do player1
    mov eax, fShot1

    xor dl, dl
    mov dh, numShots1 
    .while dl < dh
        mov bx, [eax].value.x
        mov currShot.x, bx
        mov bx, [eax].value.y
        mov currShot.y, bx

        mov bx, [eax].value.speed
        mov currShot.speed, bx

        invoke printShot, currShot, _hdc 

        mov eax, [eax].next

        inc dl
    .endw

    ;Desenha os tiros do player2
    mov eax, fShot2

    xor dl, dl
    mov dh, numShots2 
    .while dl < dh
        mov bx, [eax].value.x
        mov currShot.x, bx
        mov bx, [eax].value.y
        mov currShot.y, bx

        mov bx, [eax].value.speed
        mov currShot.speed, bx

        invoke printShot, currShot, _hdc 

        mov eax, [eax].next

        inc dl
    .endw

    assume eax:nothing

    ret
printShots endp

printShot proc uses eax edx shot:gameObj, _hdc:HDC ;Desenha na tela um tiro:
    local upperLX:dword
    local upperLY:dword

    ;Calcula as coordenadas do ponto superior esquerdo:
;________________________________________________________________________________

    movzx eax, shot.x
    movzx ebx, shot.y
    sub eax, SHOT_RADIUS
    sub ebx, SHOT_RADIUS

    mov upperLX, eax  
    mov upperLY, ebx
;________________________________________________________________________________

    movzx eax, shot.x
    movzx ebx, shot.y
    add eax, SHOT_RADIUS
    add ebx, SHOT_RADIUS

    invoke Ellipse, _hdc, upperLX, upperLY,\
        eax, ebx

    ret
printShot endp
    
printScores proc _hdc:HDC
    ;Score do jogador 1:
    invoke SetTextAlign, _hdc, TA_LEFT
    invoke TextOut, _hdc, SCORE_SPACING, SCORE_SPACING, addr scoreP1, 2

    ;Score do jogador 2:
    invoke SetTextAlign, _hdc, TA_RIGHT
    invoke TextOut, _hdc, WIN_WD - SCORE_SPACING, SCORE_SPACING, addr scoreP2, 2

    ret
printScores endp

incScore proc addrScore:dword ;Soma um no score passado:
    assume eax:ptr pair
    mov eax, addrScore

    .if [eax].y == 48 + 9
        mov [eax].y, 48 + 0

        .if [eax].x == 48 + 9
            mov [eax].x, 48 + 0
            mov [eax].y, 48 + 0
        .else
            inc [eax].x
        .endif
    .else
        inc [eax].y
    .endif


    assume eax:nothing

    ret
incScore endp

updateScreen proc ;Desenha na tela todos os objetos:
    locaL ps:PAINTSTRUCT
    locaL hMemDC:HDC 
    locaL hdc:HDC 

    invoke BeginPaint, hWnd, addr ps 
    mov hdc, eax 

    invoke CreateCompatibleDC, hdc 
    mov hMemDC, eax 
    
    .if !over
        ;Desenha os jogadores:
        invoke printPlyr, player1, hdc, hMemDC, TRUE
        invoke printPlyr, player2, hdc, hMemDC, FALSE

        ;Desenha os tiros:
        invoke printShots, hdc 

        ;Desenha os scores:
        invoke printScores, hdc
    .else ;Caso o jogo tenha acabado:
        invoke SetTextAlign, hdc, TA_CENTER

        .if over == 3 ;Caso seja empate:
            invoke TextOut, hdc, WIN_WD / 2, WIN_HT / 2, addr draw, len_draw
        .elseif over == 1 ;Caso o primeiro tenha ganho:
            invoke TextOut, hdc, WIN_WD / 2, WIN_HT / 2, addr won1, len_won1
        .elseif over == 2 ;Caso o segundo tenha ganho:
            invoke TextOut, hdc, WIN_WD / 2, WIN_HT / 2, addr won2, len_won2
        .endif
    .endif

    invoke DeleteDC, hMemDC 
    invoke EndPaint, hWnd, addr ps 
    
    ret
updateScreen endp

gameHandler proc p:dword
    .while !over
        invoke  Sleep, 60

        invoke movShots ;Move todos os tiros na tela

        invoke canMov, player1.playerObj, player2.playerObj ;Verifica se no futuro
                                                            ;os jogadores vão colidir

        ;Caso o jogador não for colidir ele é movido:
;________________________________________________________________________________

        .if canPlyrsMov.x 
            invoke movObj, addr player1.playerObj
        .endif

        .if canPlyrsMov.y
            invoke movObj, addr player2.playerObj
        .endif
;________________________________________________________________________________

        ;Atualiza a direção dos jogadores baseado nas suas velocidades nos eixos:
        invoke updateDirec, addr player1
        invoke updateDirec, addr player2

        .if isShooting.x
            ;Adiciona um tiro se o tempo de delay tiver sido atingido:
        	.if shotsDelays.x == SHOTS_DELAY
            	invoke addShot, player1, addr fShot1, addr lShot1,\
                    addr numShots1 

            	mov shotsDelays.x, 0
            .else
            	inc shotsDelays.x
            .endif
        .endif

        .if isShooting.y
            ;Adiciona um tiro se o tempo de delay tiver sido atingido:
        	.if shotsDelays.y == SHOTS_DELAY
				invoke addShot, player2, addr fShot2, addr lShot2,\
                    addr numShots2

				mov shotsDelays.y, 0
            .else
            	inc shotsDelays.y
            .endif
        .endif

		invoke checkCrashs ;Verifica se os jogadores foram atingidos por algum tiro

        .if hit ;Caso atingido os jogadores voltam para a posição inicial:
            mov hit, FALSE
            invoke clearAllShots

            invoke resetAll
        .endif

        ;Checa se o jogo acabou:
;________________________________________________________________________________

        mov dl, maxScore.x
        mov dh, maxScore.y
        .if scoreP1.x == dl && scoreP1.y == dh
            invoke clearAllShots
            mov over, 1
        .endif
            
        .if scoreP2.x == dl && scoreP2.y == dh
            invoke clearAllShots
            or over, 2
        .endif
;________________________________________________________________________________


        invoke InvalidateRect, hWnd, NULL, TRUE
    .endw

    ret
gameHandler endp

updateDirec proc addrPlyr:dword ;Atualiza a direção dos jogadores baseado nas suas
                                ;velocidades nos eixos:
    assume eax:ptr player
    mov eax, addrPlyr

    mov bh, [eax].playerObj.speed.x
    mov bl, [eax].playerObj.speed.y

    .if bh != 0 || bl != 0
        .if bh == 0 ;Caso seja zero:
            .if bl > 7fh ;Caso seja negativo:
                mov [eax].direc, 1   
            .else ;Caso seja positivo:
                mov [eax].direc, 5  
            .endif 
        .elseif bh > 7fh ;Caso seja negativo:
            .if bl == 0 ;Caso seja zero:
                mov [eax].direc, 7  
            .elseif bl > 7fh ;Caso seja negativo:
                mov [eax].direc, 0   
            .else ;Caso seja positivo:
                mov [eax].direc, 6  
            .endif    
        .else ;Caso seja positivo:
            .if bl == 0 ;Caso seja zero:
                mov [eax].direc, 3  
            .elseif bl > 7fh ;Caso seja negativo:
                mov [eax].direc, 2   
            .else ;Caso seja positivo:
                mov [eax].direc, 4  
            .endif 
        .endif
    .endif

    assume eax:nothing

    ret
updateDirec endp

addShot proc plyr:player, fNodePtrPtr:dword, lNodePtrPtr:dword, sizePtr:dword 
                                                ;Adiciona um tiro em uma lista:
    local newShot: gameObj

    mov eax, sizePtr
    mov al, [eax]

    .if al == TRACKED_SHOTS ;Checa se a lista esta cheia, caso verdadeiro o primeiro tiro
                            ;da lista é removido:
        invoke removeFNode, fNodePtrPtr, lNodePtrPtr, sizePtr
    .endif 
    
    ;Cria um novo tiro na posição do jogador:
    mov ax, plyr.playerObj.x
    mov newShot.x, ax
    mov ax, plyr.playerObj.y
    mov newShot.y, ax

    ;Desloca o tiro para a frente do cano do tanque:
;________________________________________________________________________________

    mov al, plyr.direc

    .if al == 0 || al == 1 || al == 2
        mov newShot.speed.y, SHOT_SPEED * -SPEED
        sub newShot.y, HALF_SIZE
    .elseif al == 6 || al == 5 || al == 4
        mov newShot.speed.y, SHOT_SPEED * SPEED
        add newShot.y, HALF_SIZE
    .else ;Caso seja 3 ou 7
        mov newShot.speed.y, 0
    .endif 

    .if al == 0 || al == 7 || al == 6
        mov newShot.speed.x, SHOT_SPEED * -SPEED
        sub newShot.x, HALF_SIZE
    .elseif al == 2 || al == 3 || al == 4
        mov newShot.speed.x, SHOT_SPEED * SPEED
        add newShot.x, HALF_SIZE
    .else ;Caso seja 1 ou 5
        mov newShot.speed.x, 0
    .endif 
;________________________________________________________________________________

    invoke addNode, fNodePtrPtr, lNodePtrPtr, sizePtr, newShot ;Adiciona o tiro na lista

    ret
addShot endp

addNode proc fNodePtrPtr:dword, lNodePtrPtr:dword, sizePtr:dword, 
    newValue:gameObj ;Adiciona um nó no final de uma lista:

    assume eax:ptr node

    invoke GlobalAlloc, GMEM_FIXED, NODE_SIZE ;Aloca memória para o novo nó

    ;Copia os dados na nova estrutura alocada:-----------------------------------
;________________________________________________________________________________

    mov bx, newValue.x
    mov [eax].value.x, bx
    mov bx, newValue.y
    mov [eax].value.y, bx

    mov bx, newValue.speed
    mov [eax].value.speed, bx
    
    mov [eax].next, 0

    assume eax:nothing
;________________________________________________________________________________

    mov ecx, sizePtr
    mov bh, [ecx]

    inc bh 
    mov [ecx], bh

    .if bh == 1 ;Caso a lista esteja vazia:
        mov ecx, fNodePtrPtr  
        mov [ecx], eax ;Faz o ponteiro de começo apontar o novo nó
    .else
        mov ecx, lNodePtrPtr
        mov ecx, [ecx]

        mov (node ptr [ecx]).next, eax ;Faz o último nó apontar para a 
                                    ;nova estrutura
    .endif

    mov ecx, lNodePtrPtr
    mov [ecx], eax ;Faz o ponteiro de final apontar o novo

    ret
addNode endp

removeFNode proc uses edx fNodePtrPtr:dword, lNodePtrPtr:dword, sizePtr:dword
    local nodeSize:byte ;Remove um nó do começo de uma lista:
    
    ;Move para al o tamanho da lista:
    mov ebx, sizePtr
    mov al, [ebx]
    
    .if al == 0 ;Caso a lista esteja vazia o método para:
        ret
    .endif

    mov nodeSize, al ;Salva o tamanho da lista para uso posterior

    assume eax:ptr node

    ;Remove um nó da lista:
;________________________________________________________________________________

    mov ecx, fNodePtrPtr ;Move o local onde está salvo o endereço do primeiro nó
    mov eax, [ecx] ;Move o endereço do primeiro nó

    .if nodeSize > 1 ;Caso a lista tenha mais de um nó, o primeiro é removido e o
                    ;ponteiro de início aponta o segundo nó:
        mov edx, [eax].next ;Move o endereço do segundo nó  

        mov [ecx], edx ;Aponta o ponteiro de início para o segundo nó 
    .else ;Caso a lista tenha um unico nó, esse nó é removido e os ponteiro são 
        ;zerados:
        xor edx, edx

        mov [ecx], edx ;Zera o ponteiro de início

        mov ecx, lNodePtrPtr
        mov [ecx], edx ;Zera o ponteiro de fim
    .endif

    invoke GlobalFree, eax ;Deleta o primeiro nó da memória
;________________________________________________________________________________

    assume eax:nothing

    ;Subtrai um do tamanho e salva o valor:
    dec nodeSize 
    mov al, nodeSize
    mov [ebx], al

    ret
removeFNode endp

clearAllShots proc uses edx ;Limpa todas as listas de tiros:
    ;Limpa os tiros do primeiro jogador
    xor dl, dl
    mov dh, numShots1
    .while dl < dh
        invoke removeFNode, addr fShot1, addr lShot1, addr numShots1

        inc dl
    .endw

    ;Limpa os tiros do segundo jogador
    xor dl, dl
    mov dh, numShots2
    .while dl < dh
        invoke removeFNode, addr fShot2, addr lShot2, addr numShots2

        inc dl
    .endw

    ret
clearAllShots endp

resetAll proc ;Reseta a posição dos jogadores, limpa as listas de tiros e zera a 
            ;velocidade dos jogadores:

    ;Reseta a direção dos jogadores:
	mov player1.direc, 7
	mov player2.direc, 3

    ;Reseta a posição dos jogadores:
;________________________________________________________________________________

	mov player1.playerObj.x, IMG_SIZE
	mov player1.playerObj.y, WIN_HT / 2

	mov player2.playerObj.x, WIN_WD - IMG_SIZE
	mov player2.playerObj.y, WIN_HT / 2
;________________________________________________________________________________

    ;Zera a velocidade dos jogadores:
;________________________________________________________________________________

	mov player1.playerObj.speed.x, 0
	mov player1.playerObj.speed.y, 0

	mov player2.playerObj.speed.x, 0
	mov player2.playerObj.speed.y, 0
;________________________________________________________________________________

	ret
resetAll endp

end start