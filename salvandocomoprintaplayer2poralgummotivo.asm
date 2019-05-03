;PLAYER 2___________________________________________
        .if player2.direction == D_TOP_LEFT
            invoke SelectObject, _hMemDC, h_V2_top_left
        
        .elseif player2.direction == D_TOP
            invoke SelectObject, _hMemDC, h_V2_top

        .elseif player2.direction == D_TOP_RIGHT
            invoke SelectObject, _hMemDC, h_V2_top_right 

        .elseif player2.direction == D_RIGHT
            .if RIGHTARROW == 1                          
                .if player2.walksequence == 1
                    invoke SelectObject, _hMemDC, p2_right1
                .elseif player2.walksequence == 2
                    invoke SelectObject, _hMemDC, p2_right2
                .elseif player2.walksequence == 3
                    invoke SelectObject, _hMemDC, p2_right3 
                .elseif player2.walksequence == 4
                    invoke SelectObject, _hMemDC, p2_right4 
                .endif
            .else 
                invoke SelectObject, _hMemDC, p2_right1
            .endif

        .elseif player2.direction == D_DOWN_RIGHT
            invoke SelectObject, _hMemDC, h_V2_down_right 

        .elseif player2.direction == D_DOWN
            invoke SelectObject, _hMemDC, h_V2_down 

        .elseif player2.direction == D_DOWN_LEFT
            invoke SelectObject, _hMemDC, h_V2_down_left 

        .else ;left is the last possible direction
            invoke SelectObject, _hMemDC, h_V2_left  
        .endif 

        ;invoke SelectObject, _hMemDC, p2_spritesheet 

    ;________PLAYER 2 PAINTING________________________________________________________________________

        ;mov eax, walksequence
        ;mul PLAYER2_SIZE
        ;mov edx, eax

        ;mov eax, player2.direction
        ;mul PLAYER2_SIZE
        ;mov ecx, eax

        mov eax, player2.playerObj.pos.x
        mov ebx, player2.playerObj.pos.y
        sub eax, PLAYER2_HALF_SIZE
        sub ebx, PLAYER2_HALF_SIZE

        invoke BitBlt, _hdc, eax, ebx, PLAYER2_SIZE, PLAYER2_SIZE, _hMemDC, 0, 0, SRCCOPY 




        .elseif player2.direction == D_RIGHT
            .if player2.walking.rightarrow == 1                          
                .if player2.walksequence == 1
                
                    invoke SelectObject, _hMemDC, p2_spritesheet
                    
                    mov ah, 1
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov edx, eax

                    mov ah, player2.direction
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov ecx, eax

                .elseif player2.walksequence == 2
                    invoke SelectObject, _hMemDC, p2_spritesheet
                    
                    mov ah, 2
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov edx, eax

                    mov ah, player2.direction
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov ecx, eax

                .elseif player2.walksequence == 3
                    invoke SelectObject, _hMemDC, p2_spritesheet
                    
                    mov ah, 3
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov edx, eax

                    mov ah, player2.direction
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov ecx, eax 
                    
                .elseif player2.walksequence == 4
                    invoke SelectObject, _hMemDC, p2_spritesheet
                    
                    mov ah, 4
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov edx, eax

                    mov ah, player2.direction
                    mov ebx, PLAYER2_SIZE
                    mul ebx
                    mov ecx, eax
                .endif
            .else 
                invoke SelectObject, _hMemDC, p2_spritesheet
            .endif

        .elseif player2.direction == D_DOWN_RIGHT
            invoke SelectObject, _hMemDC, h_V2_down_right 

        .elseif player2.direction == D_DOWN
            invoke SelectObject, _hMemDC, h_V2_down 

        .elseif player2.direction == D_DOWN_LEFT
            invoke SelectObject, _hMemDC, h_V2_down_left 

        .else ;left is the last possible direction
            invoke SelectObject, _hMemDC, h_V2_left  
        .endif 