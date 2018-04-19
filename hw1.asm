.data

initialarr: .asciiz "THE INITIAL ARRAY IS"
sortedarr: .asciiz "THE SORTED ARRAY IS"
newline: .asciiz "\n"
space: .asciiz " "

#const char * data[] = {"Joe", "Jenny", "Jill", "John","Jeff", "Joyce", "Jerry", "Janice","Jake", "Jonna", "Jack", "Jocelyn","Jessie", "Jess", "Janet", "Jane"};
data:
	  .align 5  
	  .asciiz "Joe"
	 .align 5
        .asciiz "Jenny"
        .align 5
        .asciiz "Jill"
        .align 5
        .asciiz "John"
        .align 5
        .asciiz "Jeff"
        .align 5
        .asciiz "Joyce"
        .align 5
        .asciiz "Jerry"
        .align 5
        .asciiz "Janice"
        .align 5  
	.asciiz "Jake"
	 .align 5
        .asciiz "Jonna"
        .align 5
        .asciiz "Jack"
        .align 5
        .asciiz "Jocelyn"
        .align 5
        .asciiz "Jessie"
        .align 5
        .asciiz "Jess"
        .align 5
        .asciiz "Janet"
        .align 5
        .asciiz "Jane"
	 .align 2
	  ptr: .space 64
	  endptr: .space 64
	 
	 
.text
# the main method
main:   la $t0,ptr
	la $t1,endptr
	la $t2,data
	
	#int size = 16;  
	la $t0,0($t2) # $t0 is pointing to the first address of the array data[]
	la $t1,0($t2) #$t1 is initially pointing to the first element
	addi $t1,$t1,480 #$t1 is incremented to point to the last element of the array
	
	#printf("Initial array:\n");
	la $a0,initialarr
	li $v0,4
	syscall
	la $a0,newline
	li $v0,4
	syscall
	#print_array(data, size);
	jal print
	#restoring the value of $t0 after printing
	subu $t0,$t0,512
	
	#quick_sort(data, size);
	# arguments for the quick function
	move $a1,$t0 # first argument contains the first element
	subu $t1,$t1,$t0 #length of the array
	move $a2,$t1 # second argument contains the length of the array
	jal quick
	
	#printf("Sorted array:\n");
	la $a0,newline
	li $v0,4
	syscall
	la $a0,sortedarr
	li $v0,4
	syscall
	la $a0,newline
	li $v0,4
	syscall
	#print_array(data, size);
	jal print
	#exit(0);
	j exit
	
	
#function to exit the program 	
exit:
	
	li      $v0,10
        syscall 
        
#function to print the array		
print:
	addu   $t7,$t0,480 #points to the last element of the array
#loop through the array
ploop:	move $a0,$t0 #print the element.
	li $v0,4
	syscall
	la $a0,space
	li $v0,4
	syscall
	addi 	$t0,$t0,32 #add 32 to go to the next element
	ble   	$t0,$t7,ploop	#loop until it reaches last element
	jr $ra
	
#function to compare two strings 	
strcpr:
	#the arguments are $a2 and $a3
	
	lb 	$s2,($a2) #loading the first byte  ---> comparing each character of string 1
	lb 	$s3,($a3) #loading the secend byte ---> comparing each character of string 2
	bne     $s3,$s2,cmpneq # if the characters are not equal then jump to the function cmpneq
	beq 	$s2,$zero,cmpeq # if the characters are equal the jump to the function cmpeq
	addi $a2,$a2,1 #add 1 to go compare the next character
	addi $a3,$a3,1 #add 1 to compare the next character
	j strcpr       # loop through the function strcpr
	j exit		#else exit
	
	


 cmpneq:
        #load compare both the charcacters of str1 and str2
        lb 	$s2,($a2)#loading the first byte  ---> comparing each character of string 1
	lb 	$s3,($a3)#loading the secend byte ---> comparing each character of string 2
	#if ( *x < *y ) 
	blt      $s2,$s3,cmpneless #jump to the function cmpneless if str1 is less than str2
	#if ( *y < *x )
        bgt      $s2,$s3,cmpnegre #jump to the function cmpnegre if str1 is greater than str2
        j exit #else terminate the program
        
 cmpneless:
 	#return 1;
        li $v0,1 #if str1 is less than str2 then return 1.
        jr $ra
               
        
 cmpnegre:
 	# return 0;
        li $v0,0 #if str1 is greater than str2 then return 0.
        jr $ra
        
 
 cmpeq:
 	#else return 0;
        li $v0,0
        jr $ra
        
#end of string comparision        
	
#function to swap two strings	
swap:
	  
	    #arguments for the swap function
            move $t4,$a1 #char **s1
	    move $t5,$s5 #char **s2
	   #load the entire string 1
	    lw $t6,($t4)
	    lw $t8,4($t4)
	   #load the entire string 2
	    lw $t7,($t5)
	    lw $t9,4($t5)
	   #*s1 = *s2;
	   #store string 2 in string 1's address 
	    sw $t6,($t5)
	    sw $t8,4($t5)
	   #*s2 = tmp;
	   #store string 1 in string 2's address
	    sw $t7,($t4)
	    sw $t9,4($t4)
	      
            jr  $ra 
                    
#end of string swapping function

#function to quicksort
quick:
	subu $sp,$sp,32 # making space for the stack
 	sw $ra,28($sp) # saving return address in stack
 	sw $fp,24($sp) # saving frame pointer in stack
 	sw $s0,20($sp) # saving callee saved register
 	sw $s1,16($sp) # saving callee saved register
 	sw $s2,12($sp) # saving callee saved register
 	sw $s3,8($sp) # saving callee saved register
 	sw $s4,4($sp) # saving callee saved register
 	addu $fp,$sp,32 # move the frame pointer to the base of the call frame
	
	#storing in stack
	#arguments $a1,$a2
	move $s0,$a1 # (arr) ----> const char *a[]
	
	
	#length of the array (len)
	move $s2,$a2 # size_t len
	
	#pivot $t3 is for pivot
	li $t3,0 # int pivot = 0;
	addu $t3,$t3,$s0
	
	#base case 
	blt $s2,32,basecase #if (len <= 1) {return;}
	
	
	#$t6 contains the last index
	addu $t6,$s0,$s2
	move $s1,$t6
	

	
	
	#int i=0 -----> $s4	
	li $s4,0
	addu $s4,$s4,$s0

	# the for loop within the quicksort function converted into while loop
	#start of while loop	
	while:	 	
		move $a2,$s4 #argument 1 for the string compare function
		move $a3,$s1 #argument 2 for the string compare function
		jal strcpr   #jump to string compare function ----> if (str_lt(a[i], a[len - 1]))
		bgt $v0,0,pivot #swap_str_ptrs(&a[i], &a[pivot]); ----> jump to pivot function if return value of strcpr function is greater than 0
		
	afterpivot:   	addu $s4,$s4,32 #add 32 to go to the next element --->  i++
			blt $s4,$s1,while # loop till "i < len - 1" is true
	#end of while loop
	
	#arguments for the swap function
	#swap_str_ptrs(&a[i], &a[pivot]);
	move $a1,$t3
	move $s5,$s1
	jal swap
	
	#quick_sort(a, pivot);
	move $a1,$s0 # the array to be sent ----> argument 1 of the quicksort function
	subu $t7,$t3,$s0 
	subu $t7,$t7,32
	move $a2,$t7 # the length of the array---> argument 2  ---> pivot
	jal quick    #calling the quicksort function 
	
	#quick_sort(a + pivot + 1, len - pivot - 1);
	#argument 1 of the quick sort function ----> a + pivot + 1
	subu $t9,$t3,$s0
	addu $s0,$s0,$t9
	addu $s0,$s0,32
	move $a1,$s0
	
	#argument 2 of the quick sort function ----> len - pivot - 1
	subu $t8,$a1,$t3
	subu $t8,$t8,32
	addu $t8,$t8,$s1
	subu $t8,$t8,$s0
	move $a2,$t8
	# calling the quicksort function with the two arguments 
	jal quick
	b finalreturn

	
	
	
#function when base condition is satisfied	
basecase:
	#call the finalreturn function if the base condition is satisfied
	b finalreturn
	
# function to pop all the saved values 	
finalreturn:
 		#poping the stack and resetting the values
 		lw $ra,28($sp) 
 		lw $fp,24($sp) 
 		lw $s0,20($sp) 
 		lw $s1,16($sp)
 		lw $s2,12($sp)
 		lw $s3,8($sp)
 		lw $s4,4($sp)
 		addu $sp,$sp,32
 		jr $ra

 		
#function to swap strings anf increase the pivot		 		 		
 pivot:
 	#swap_str_ptrs(&a[i], &a[pivot]);  pivot++;
	move $a1,$s4
	move $s5,$t3
	jal swap
	add $t3,$t3,32
	j afterpivot
 
 		
 		
 		
    
    
	

	
