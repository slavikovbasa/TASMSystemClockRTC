.model tiny
.stack 100h

.code
main:
    mov al, 00h ; read seconds
    out 70h, al ; from RTC
    in al, 71h  ; in
    mov bl, al  ; bl
    
    mov al, 02h ; read minutes
    out 70h, al ; from RTC
    in al, 71h  ; in
    mov bh, al  ; bh
    
    call printDecimal
    
    mov cx, 2
@wait_loop1:
    call wait10
    loop @wait_loop1
    
    mov al, 00h ; read new seconds
    out 70h, al ; from RTC
    in al, 71h  ; in
    mov cl, al  ; cl
    
    mov al, 02h ; read new minutes
    out 70h, al ; from RTC
    in al, 71h  ; in
    mov ch, al  ; ch
    
    
    cmp cl, bl  
    jnb @sub_sec; if cl<bl
    mov al, 60h ; normalize seconds value
    sub al, bl  ; by doing 60-bl
    das         
    add al, cl  ; and then 60-bl+cl
    daa
    mov bl, al
    mov al, bh
    inc al      ; reduce minutes range by 1
    daa
    mov bh, al
    jmp @minutes
@sub_sec:
    mov al, cl
    sub al, bl  ; else just substract bl from cl
    das
    mov bl, al

@minutes:
    cmp ch, bh  
    jnb @sub_min; if cl<bl
    mov al, 60h ; normalize minutes value
    sub al, bh  ; by doing 60-bh
    das
    add al, ch  ; and then 60-bh+ch
    daa
    mov bh, al
    jmp @print
@sub_min:
    mov al, ch
    sub al, bh  ; else just substract bl from cl
    das
    mov bh, al
    
@print:
    call printDecimal
    
    mov ax, 4C00h
    int 21h

wait10 proc
    xor ah, ah
    mov al, 40h
    mov es, ax
    mov ax, es:[6Ch]
    add ax, 182 ; 10sec = 182 ticks
@wait_loop:
    cmp ax, es:[6Ch]
    jne @wait_loop
    ret
wait10 endp

printDecimal proc
    ;output minutes
    mov al, bh ; move minutes in al
    shr al, 4  ; choose only four higher bits
    add al, 30h; add ASCII '0' symbol to value
    int 29h    ; output the symbol
    mov al, bh 
    and al, 0Fh; choose only four lower bits
    add al, 30h; add ASCII '0' symbol to value
    int 29h    ; output the symbol
    
    mov al, ':'
    int 29h
    
    ;output seconds
    mov al, bl ; move seconds in al
    shr al, 4  ; choose only four higher bits
    add al, 30h; add ASCII '0' symbol to value
    int 29h    ; output the symbol
    mov al, bl 
    and al, 0Fh; choose only four lower bits
    add al, 30h; add ASCII '0' symbol to value
    int 29h    ; output the symbol
    
    mov al, 0Ah
    int 29h
    
    mov al, 0Dh
    int 29h
    ret
printDecimal endp

end main