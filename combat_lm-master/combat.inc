include C:\masm32\include\windows.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\gdi32.inc
include C:\masm32\include\user32.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\Comctl32.inc
include C:\masm32\include\comdlg32.inc
include C:\masm32\include\shell32.inc
include C:\masm32\include\msimg32.inc

includelib C:\masm32\lib\masm32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\lib\user32.lib
includelib C:\masm32\lib\kernel32.lib
includelib C:\masm32\lib\Comctl32.lib
includelib C:\masm32\lib\comdlg32.lib
includelib C:\masm32\lib\shell32.lib
includelib C:\masm32\lib\msimg32.lib

;=================
; structs
;=================
pair struct ;Par ordenado (<a, b>): 
    x  db ?
    y  db ?
pair ends

gameObj struct ;Objeto primário (<x, y, <Vx, Vy>>):
	x  dw ?
    y  dw ?
    
	speed pair <>
gameObj ends

player struct ;Dados de um jogador (<Life, <x, y, <Vx, Vy>>>):
    life db ?
    direc db ?

    playerObj gameObj <>
player ends

node struct ;Nó de uma lista ligada
    next dd ?
    value gameObj <>
node ends

;=================
; consts
;=================
.const
	WIN_HT equ 700 ;Altura da janela
    WIN_WD equ 1200 ;Largura da janela

    OFFSETX equ WIN_WD - HALF_SIZE
    OFFSETY equ WIN_HT - HALF_SIZE

    IMG_SIZE equ 32 ;Altura e largura da img do jogador
    IMG_SIZE2 equ IMG_SIZE * IMG_SIZE ;Quadrado de IMG_SIZE
    HALF_SIZE equ IMG_SIZE / 2 

    SHOT_RADIUS equ 3

    D2_SHOT equ (HALF_SIZE + SHOT_RADIUS) * (HALF_SIZE + SHOT_RADIUS) ;Quadrado
                                    ;da distância minima entre o tiro e o jogador 

    SCORE_SPACING equ 10 ;Espaço de separação dos digitos do jogo

    SPEED equ 4 ;Velocidade dos jogadores
    MAX_SCORE equ 5 ;Score máximo para o termino do jogo
    MAX_LIFE equ 100 ;Vida inicial dos jogadores
    SHOTS_DELAY equ 3 ;Número de ciclos de espera para atirar
    TRACKED_SHOTS equ 255 ;Número máximo de tiros na tela, 
    					 ;antes deles desaparecerem (para cada jogador)

    SHOT_SPEED equ 3 ;Multiplicador de velocidade dos tiros 

    NODE_SIZE equ SIZEOF node ;Tamanho em bytes da estrutura de nó

;=================
; data
;=================
.data      
AppName db "Combat", 0 ;Título da janela
ClassName db "CombatClass", 0 ;Classe da janela

won1 db "O jogador 1 ganhou!!! Aperte (r) para reiniciar.", 0
len_won1 equ $ - won1

won2 db "O jogador 2 ganhou!!! Aperte (r) para reiniciar.", 0
len_won2 equ $ - won2

draw db "Ouve um empate!!! Aperte (r) para reiniciar.", 0
len_draw equ $ - draw

;Bitmaps do jogador 1:
h100 dd 0
h101 dd 0
h102 dd 0
h103 dd 0
h104 dd 0
h105 dd 0
h106 dd 0
h107 dd 0

;Bitmaps do jogador 2:
h110 dd 0
h111 dd 0
h112 dd 0
h113 dd 0
h114 dd 0
h115 dd 0
h116 dd 0
h117 dd 0

.data?                
hWnd HWND ?
threadID DWORD ?
hInstance HINSTANCE ?  

;=================
; prototypes
;=================
WinMain proto :DWORD, :DWORD   

loadBitmaps proto ;Carrega os bitmaps do jogo

gameHandler proto :DWORD ;Thread principal do jogo

updateScreen proto ;Desenha na tela todos os objetos

printShots proto :HDC ;Desenha todos o tiros
printScores proto :HDC ;Desenha os placares dos jogadores
printShot proto :gameObj, :HDC ;Desenha o tiro passado
printPlyr proto :player, :HDC, :HDC, :BYTE ;Desenha o jogador passado

movShots proto ;Move todos o tiros
movObj proto :DWORD ;Atualiza a posição do gameObj passado

updateDirec proto :DWORD ;Atualiza a direção de um jogador

canMov proto :gameObj, :gameObj ;Atualiza se cada jogador pode se mover

mult proto :WORD, :WORD ;Multiplica dois números (16 b) e coloca em eax

incScore proto :DWORD ;Incrementa o score do jogador passado

checkCrashs proto ;Incrementa o score quando um jogador acerta um tiro
checkShot proto :gameObj, :gameObj ;Checa se um tiro atingiu um jogador

resetAll proto ;Restabelece a posição dos jogadores para a inicial

;Métodos de lista ligada:

addShot proto :player, :DWORD, :DWORD, :DWORD ;Adiciona um tiro em uma lista
                                            ;(dados do jogador que atirou, ptr 
                                            ;para um ptr do primeiro nó, ptr para
                                            ;um ptr do último nó, ptr para o 
                                            ;tamanho da lista)

;Adiciona um nó no final de uma lista (ptr para um ptr do primeiro nó, 
;ptr para um ptr do último nó, ptr para o tamanho da lista, novo dado):
addNode proto :DWORD, :DWORD, :DWORD, :gameObj 

removeFNode proto :DWORD, :DWORD, :DWORD ;Remove um nó do começo de uma lista
                                        ;(ptr para um ptr do primeiro nó, ptr 
                                        ;para um ptr do último nó, ptr para o 
                                        ;tamanho da lista)

clearAllShots proto ;Limpa as listas de tiros