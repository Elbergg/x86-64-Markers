

section .text
global markers
markers:
    push rbp
    mov rbp, rsp
    sub rsp, 184
    push rbx
    mov QWORD[rbp-8], 0 ;marker counter
    mov QWORD[rbp-16], 0 ;x coord
    mov QWORD[rbp-24], 0 ;y cord
    mov QWORD[rbp-32], 0 ;bottom length
    mov QWORD[rbp-40], 0 ;return x cord
    mov QWORD[rbp-48], 0 ;return y cord
    mov QWORD[rbp-56], 0 ;height of marker
    mov QWORD[rbp-64], 0 ;saved y cord
    mov QWORD[rbp-72], 0 ;left x cord
    mov QWORD[rbp-80], 0 ; saved x cord in urf
    mov QWORD[rbp-88], 0 ;saved y cord in down loop
    mov QWORD[rbp-96], 0 ; arm_width
    mov QWORD[rbp-104], 0 ; a point at which the inner arms should intersect
    mov QWORD[rbp-112], 0 ; saved x cord in left again
    mov QWORD[rbp-120], 0 ; saved y cord in da
    mov QWORD[rbp-128], 0 ; x cord of inner intersection
    mov QWORD[rbp-136], rsi ;address of output_x buffer
    mov QWORD[rbp-144], rdx ;address of output_x buffer
    mov QWORD[rbp-152], 0 ;heigth of image
    mov QWORD[rbp-160], 0 ;width of image
    mov QWORD[rbp-168], 0 ;right border
    mov QWORD[rbp-176], 0 ;bottom border
    mov QWORD[rbp-184], 0 ;bytes per row
    jmp get_info
    jmp find_black
    jmp exit

get_info:
    xor rax, rax
    mov eax, DWORD[rdi+19] ; load width
    shl rax, 8
    mov eax, DWORD[rdi+18]
    mov QWORD[rbp-160], rax
    xor rax, rax
    mov eax, DWORD[rdi+23] ;load heigth
    shl rax, 8
    mov eax, DWORD[rdi+22]
    mov QWORD[rbp-152], rax
    xor rax, rax
    mov al, BYTE[rdi+11] ;data offset
    shl rax, 8
    mov al, BYTE[rdi+10]
    add rdi, rax ;first pixel
    mov rax, QWORD[rbp-160] ;right
    sub rax, 1
    mov QWORD[rbp-168], rax ;right border
    mov rax, QWORD[rbp-152]
    sub rax, 1
    mov QWORD[rbp-176], rax ;top border
    mov rax, QWORD[rbp-160]
    imul rax, 24 ; calculatirng byter per pixel  - 3*8*width- Bitperpixel*width
    add rax, 31  ; Bitperpixel*[rbp-160]+31
    xor rdx, rdx
    mov rcx, 32
    div rcx ; (Bitperpixel*[rbp-160]+31) /32
    shl rax, 2 ; (Bitperpixel*[rbp-160]+31) /32 *4
    mov QWORD[rbp-184], rax
    xor rcx, rcx
    xor rsi, rsi


find_black:
    mov rax, [rbp-24] ;load rax with y cord
    mov rbx, [rbp-16] ;load rbx with x cord
    cmp rbx, [rbp-160] ;check if reached right border
    je next_row ;if so go one row up
    call get_pixel ;check pixel under current rbx, rax coords
    cmp bl, 0 ;check if its black
    je go_right ;if so go right
    inc QWORD[rbp-16] ;go to the right
    jmp find_black

next_row:
    inc QWORD[rbp-24] ;inc y coord
    mov QWORD[rbp-16], 0 ;reset x cord
    mov rax, [rbp-24]
    cmp rax, [rbp-152] ;if reached the top exit
    je exit
    jmp find_black

go_right:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rbx, [rbp-160]
    je end_right ;if right border end_right
    call get_pixel
    cmp bl, 0
    jne end_right ;if pixel not black  end_right
    inc QWORD[rbp-32] ;inc length counter
    inc QWORD[rbp-16] ;go right
    jmp go_right


end_right:
    dec QWORD[rbp-16] ;move one to the left
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    mov [rbp-40], rbx ;save return x and y coords
    mov [rbp-48], rax
bottom_frame:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rax, 0 ;if we are at the bottom end bf
    je end_bf
    sub rbx, [rbp-32]
    inc rbx
    mov [rbp-16], rbx
    dec QWORD[rbp-24]
b_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rbx, [rbp-40]
    jg end_bf ;if we reached the return x cord
    call get_pixel
    cmp bl, 0
    je not_found ;if pixel is black not found
    inc QWORD[rbp-16]
    jmp b_loop


end_bf:
    mov rbx, [rbp-40] ;change x and y coords to return values
    mov rax, [rbp-48]
    mov [rbp-16], rbx
    mov [rbp-24], rax
    mov rcx, [rbp-32]
    test rcx, 1
    jnz not_found ;if length is not an even number not found
    shr rcx, 1 ;divide length by 2
    jmp go_up



go_up:
    inc QWORD[rbp-56] ; inc [rbp-152] counter
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    call get_pixel
    cmp bl, 0
    jne not_found ; if pixel not black go not found
    cmp [rbp-56], rcx ; check if
    je end_up
    inc QWORD[rbp-24]
    jmp go_up


end_up:
    inc QWORD[rbp-24] ; go one row up
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rax, [rbp-152] ; check if we are at top, if so just go left
    je go_left
    mov [rbp-64], rax ; save y cord
    call get_pixel ;check if pixel above is black
    cmp bl, 0
    je not_found ;if its black not found
    mov rbx, [rbp-16]
    cmp rbx, [rbp-168] ; if we are at the right border go left
    je go_left
    jmp right_frame

right_frame:
    mov rax, [rbp-48] ;load saved t5 value into a1
    mov [rbp-24], rax
    inc QWORD[rbp-16] ;increment x coordinate by 1

rf_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rax, [rbp-64]
    je end_rf ;if y coordinate equal to saved a5, end right frame
    call get_pixel ;get color of pixel at a0,a1
    inc QWORD[rbp-24] ;go one row up
    cmp bl, 0 ;if pixel is black, not found
    je not_found
    jmp rf_loop

end_rf:
    dec QWORD[rbp-16] ;dec x coord
    jmp go_left


go_left:
    dec QWORD[rbp-24] ;dec row by one
    shl rcx, 1 ;bottom length
    mov rsi, [rbp-16]
    sub rsi, rcx ;main_X - bl
    inc rsi ;correction
    mov [rbp-72], rsi
    shr rcx, 1 ;divide s6 by 2
    mov rdx, [rbp-48]

left_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rbx, [rbp-72] ;not square
    jle not_found
    mov rsi, rax
    mov rcx, rbx
    call get_pixel
    cmp bl, 0
    jne up_right_frame ;if not black, check ur frame
    call cd ;check if all the pixels beneath the current one are black as well
    dec QWORD[rbp-16] ;go left
    jmp left_loop

up_right_frame:
    mov rbx, [rbp-16]  ;load x and y with saved cords
    mov [rbp-80], rbx
    mov rbx, [rbp-40]
    mov [rbp-16], rbx
    inc QWORD[rbp-24] ;go one row up

urf_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rbx, [rbp-80] ;if reached end of urf, go down
    je go_down
    cmp rax, [rbp-152]
    je go_down_border
    call get_pixel ;if pixel is black, not found
    cmp bl, 0
    je not_found
    dec QWORD[rbp-16] ;go left
    jmp urf_loop

go_down_border:
    mov rbx, [rbp-80]
    mov [rbp-16], rbx
go_down:
    inc QWORD[rbp-16] ;correct x coord
    dec QWORD[rbp-24] ;correct y coord
    mov rbx, [rbp-16] ;save y cord
    mov rax, [rbp-24]
    mov [rbp-88], rax
    mov rsi, [rbp-40]
    sub rsi, [rbp-16]
    mov [rbp-96], rsi
    mov rcx, [rbp-48]
    add rcx, [rbp-96]
    mov [rbp-104], rcx ;a point at which inner arms should intersect

down_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rax, [rbp-104]
    je up_left_frame ;if that point is reached, go to ulf
    call get_pixel
    cmp bl, 0 ;if pixel not black, not found
    jne not_found
    dec QWORD[rbp-24] ;go down
    jmp down_loop

up_left_frame:
    dec QWORD[rbp-16] ;go left
    mov rax, [rbp-88]
    mov [rbp-24], rax ;load previous y value
ulf_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rax, [rbp-104]
    je left_again ;it reached intersection point, go left again
    call get_pixel
    cmp bl, 0
    je not_found ;if pixel is black, not found
    dec QWORD[rbp-24] ; go down
    jmp ulf_loop

left_again:
    mov [rbp-112], rbx ;save x coord
la_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rbx, [rbp-72]
    je la_frame ;if it reached the left border, got o laframe
    call get_pixel
    cmp bl, 0 ;if pixel not black, not found
    jne not_found
    dec QWORD[rbp-16] ;go left
    jmp la_loop

la_frame:
    inc QWORD[rbp-24] ;go one row up
    mov rbx, [rbp-112] ;load previously saved x coord
    mov [rbp-16], rbx
laf_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rbx, [rbp-72]
    je down_again ;if reached left border, go down again
    call get_pixel
    cmp bl, 0
    je not_found ;if the pixel is black, not found
    dec QWORD[rbp-16] ;go left
    jmp laf_loop

down_again:
    dec QWORD[rbp-24] ;correct y cord
    mov rax, [rbp-24]
    mov [rbp-120], rax ;save y cord
da_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rax, [rbp-48]
    je da_frame ;if reached bottom, down_again frame
    call get_pixel
    cmp bl, 0 ;if pixel is not zero, not found
    jne not_found
    mov rcx, [rbp-16]
    mov rsi, [rbp-24]
    mov rdx, [rbp-40]
    sub rdx, [rbp-96]
    mov [rbp-128], rdx
    call cr   ; check if all the pixels right of the current one, until the intersection are black
    dec QWORD[rbp-24] ; go down
    jmp da_loop


cr:
    push rbp
    mov rbp, rsp
    push rax
    push rbx

cr_loop:
    inc rcx
    mov rbx, rcx
    mov rax, rsi
    cmp rbx, rdx ;check if reached intersection line
    je end_cr
    call get_pixel_from_inside
    cmp bl, 0 ;not black, not found
    jne not_found_cr
    jmp cr_loop


end_cr:
    pop rbx
    pop rax
    mov rsp, rbp
    pop rbp
    ret


not_found_cr:
    pop rbx
    pop rax
    mov rsp, rbp
    pop rbp
    add rsp, 8
    jmp not_found
da_frame:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rbx, 0
    je marker_found ;we are at the left border, marker found
    mov rax, [rbp-120]
    mov [rbp-24], rax
    dec QWORD[rbp-16] ;correct x cord
daf_loop:
    mov rbx, [rbp-16]
    mov rax, [rbp-24]
    cmp rax, [rbp-48]
    je marker_found ;if reached bottom, marker found
    call get_pixel
    cmp bl, 0
    je not_found ;if pixel is black, not found
    dec QWORD[rbp-24] ;go down
    jmp daf_loop

marker_found:
    inc QWORD[rbp-8]
    mov rax, [rbp-136]
    mov rbx, [rbp-40]
    mov QWORD[rax], rbx
    add QWORD[rbp-136], 4
    add rax, 4
    mov rbx, QWORD[rbp-176]
    sub rbx, [rbp-48]
    mov rax, [rbp-144]
    mov QWORD[rax], rbx
    add QWORD[rbp-144], 4
    add rax, 4
    jmp not_found

not_found:
    inc QWORD[rbp-40] ;go one pixel to the left on the saved ones
    mov rax, [rbp-40]
    mov [rbp-16], rax
    mov rax, [rbp-48]
    mov [rbp-24], rax
    mov QWORD[rbp-32], 0 ;bottom length
    mov QWORD[rbp-40], 0 ;return x cord
    mov QWORD[rbp-48], 0 ;return y cord
    mov QWORD[rbp-56], 0 ;[rbp-152]
    mov QWORD[rbp-64], 0 ;saved y cord
    mov QWORD[rbp-72], 0 ;left x cord
    mov QWORD[rbp-80], 0 ; saved x cord in urf
    mov QWORD[rbp-88], 0 ;saved y cord in down loop
    mov QWORD[rbp-96], 0 ; arm_[rbp-160]
    mov QWORD[rbp-104], 0 ; a point at which the inner arms should intersect
    mov QWORD[rbp-112], 0 ; saved x cord in left again
    mov QWORD[rbp-120], 0 ; saved y cord in da
    mov QWORD[rbp-128], 0 ; x cord of inner intersection
    jmp find_black


cd:
    push rbp
    mov rbp, rsp
    push rax
    push rbx
cd_loop:
    dec rsi
    mov rbx, rcx
    mov rax, rsi
    cmp rax, rdx
    je end_cd ;if reached bottom of the marker, end cd
    call get_pixel_from_inside
    cmp bl, 0 ;if pixel not black, not found
    jne not_found_cd
    jmp cd_loop

end_cd:
    pop rbx
    pop rax
    mov rsp, rbp
    pop rbp
    ret

not_found_cd:
    pop rbx
    pop rax
    mov rsp, rbp
    pop rbp
    add rsp, 8
    jmp not_found


get_pixel:
    push rbp
    mov rbp, rsp
    imul rax, [rbp+24] ; t = y*bytes per row
    imul rbx, 3
    add rax, rbx ; t+= 3*x
    add rax, rdi ; add first pixel address
    mov rbx, 0
    add bl, BYTE[rax] ;add R,G and B and if the pixel is not black, the value of bl will not be 0 after the function
    inc rax
    add bl, BYTE[rax]
    inc rax
    add bl, BYTE[rax]
    inc rax
    mov rsp, rbp
    pop rbp
    ret

get_pixel_from_inside:
    push rbp
    mov rbp, rsp
    imul rax, [rbp+56] ; t = y*bytes per row
    imul rbx, 3
    add rax, rbx ; t+= 3*x
    add rax, rdi ; add first pixel address
    mov rbx, 0
    add bl, BYTE[rax] ;add R,G and B and if the pixel is not black, the value of bl will not be 0 after the function
    inc rax
    add bl, BYTE[rax]
    inc rax
    add bl, BYTE[rax]
    inc rax
    mov rsp, rbp
    pop rbp
    ret
exit:
    mov rax, [rbp-8]
    pop rbx
    mov rsp, rbp
    pop rbp
    ret
