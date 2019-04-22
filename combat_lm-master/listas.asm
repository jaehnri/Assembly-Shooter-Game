no struct ;Estrutura do nó:
    dado db ?
    prox  dd ?
no ends

mov eax, SIZEOF no
invoke GlobalAlloc, GMEM_FIXED, eax

mov prim.prox, eax
mov (no PTR prim.prox).dado, 69
mov (no PTR prim.prox).prox, 0

invoke MessageBox, NULL, addr (no PTR prim.prox).dado, addr AppName, MB_OK 

invoke GlobalFree, prim.prox