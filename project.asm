include Irvine32.inc
.data 
consoleHandle DWord ?
Ground COORD < 0,20 >
Bricks COORD < 0,0 >
BallsImage   BYTE "   ===   ", 0
.code 
Brick PROC,                                                        ; Create a Brick
    BBrick : COORD,
    BconsoleHandle : DWord

MOV ecx, 1                                                         ; Determine how many row the brick have
BiO:
    push ecx
    invoke SetConsoleCursorPosition, BconsoleHandle, BBrick   
    inc BBrick.y
    mov eax, black + ( black * 16 )                                 ; Set the color of the first space of  brick
    call SetTextColor
    mov al, ' '
    call WriteChar
    mov ecx, 6                                                      ; Set the column of the brick
    mov eax, black + ( white * 16 )                                 ; Set the color of brick
    call SetTextColor
    Bi:
        MOV  al, ' '
        CALL WriteChar
        loop Bi
    pop ecx
    mov al, ' '
    call WriteChar
    loop BiO
    ret
Brick ENDP

SetBrickSpace PROC ,
    pBrick : PTR COORD
MOV esi, pBrick
MOV ecx, 3

BR: 
    push ecx
    mov ecx, 19
    call GetMaxXY
    movzx bx, dl
    BC: 
        push ecx
        invoke Brick, (COORD PTR [esi]), consoleHandle
        pop ecx
        add (COORD PTR [esi]).x, 6
        mov dx, (COORD PTR [esi]).x
        add dx, 6
        cmp bx, dx
        ja BC
    pop ecx
    add (COORD PTR [esi]).y, 2
    mov (COORD PTR [esi]).x, 0
    loop BR
    ret
SetBrickSpace ENDP

MoveByKey PROC,
    pBallImage : PTR BYTE
mov dl, 0030h
mov dh, 0013h
LookForKey:
    mov eax, 0
    call ReadChar                                                   ; Get keyboard input from user
    cmp al, 34h
    jz  move_left
    cmp al, 36h
    jz  move_right
    jnz LookForKey

    move_left:
        push edx
        mov bl, 0
        pop edx
        cmp bl, dl
        jb do_move_left
        jmp LookForKey
        do_move_left:
            sub dl, 1h
            call Gotoxy
            push edx
            mov edx, pBallImage
            call WriteString 
            pop edx
            jmp LookForKey
    move_right:
        push edx
        call GetMaxXY
        mov ebx, edx
        sub bl, 9
        pop edx
        cmp bl, dl
        ja do_move_right
        jmp LookForKey 
        do_move_right:
            add dl, 1h
            call Gotoxy
            push edx
            mov edx, pBallImage   
            call WriteString 
            pop edx
            jmp LookForKey
    ret
MoveByKey ENDP

main PROC 
invoke GetStdHandle, STD_OUTPUT_HANDLE                              ; Define the output handle of these scream
mov consoleHandle, eax                                      

invoke SetBrickSpace, OFFSET Bricks                                 ; Set whole brick
invoke SetConsoleCursorPosition, consoleHandle, Ground              ; Set the position of ground

mov eax, white + ( black * 16 )
call SetTextColor                                                   ; The practice of ground
call GetMaxXY
movzx bx, dl
L1:
    mov  al, '-'
    call WriteChar
    inc Ground.x
    cmp Ground.x, bx
    jb L1
INVOKE MoveByKey, OFFSET BallsImage                   ; operate the move of the ball
exit
main ENDP 

END main
