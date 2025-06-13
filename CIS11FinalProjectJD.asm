;==============================================================================
; CIS11 
; Student Names: Daniel Rios & Jade Thong
; Course Project: Test Score Calculator Program with Stack Implementation
; Description: LC-3 Program that gets 5 test scores:
; -> Displays the corresponding letter grade for each score
; -> Calculates/displays the minimum, maximum, and average of all scores
; -> Demonstrates stack operations by finding the lowest grade using PUSH/POP

; Inputs: Five test scores entered by user
; Outputs: Letter grade for each score, minimum score, maximum score, average score,
;          and lowest grade found using stack operations
;==============================================================================

.ORIG x3000

;------------------------------------------------------------------------------
; MAIN PROGRAM
;------------------------------------------------------------------------------

; Display welcome message to user
LEA R0, WELCOME             ; Load address of welcome message into R0
PUTS                        ; Print welcome message to console

; Get Score 1 and display its grade
LEA R0, PROMPT1             ; Load address of "Score 1: " prompt
PUTS                        ; Display the prompt to user
JSR GET_SCORE               ; Call subroutine to get score, returns value in R3
LEA R1, SCORES              ; Load base address of scores array
STR R3, R1, #0              ; Store first score at SCORES[0]
ADD R0, R3, #0              ; Copy score to R0 for grade display
JSR SHOW_GRADE              ; Call subroutine to show letter grade

; Get Score 2 and display its grade
LEA R0, PROMPT2             ; Load address of "Score 2: " prompt
PUTS                        ; Display the prompt to user
JSR GET_SCORE               ; Call subroutine to get second score
LEA R1, SCORES              ; Load base address of scores array
STR R3, R1, #1              ; Store second score at SCORES[1]
ADD R0, R3, #0              ; Copy score to R0 for grade display
JSR SHOW_GRADE              ; Call subroutine to show letter grade

; Get Score 3 and display its grade
LEA R0, PROMPT3             ; Load address of "Score 3: " prompt
PUTS                        ; Display the prompt to user
JSR GET_SCORE               ; Call subroutine to get third score
LEA R1, SCORES              ; Load base address of scores array
STR R3, R1, #2              ; Store third score at SCORES[2]
ADD R0, R3, #0              ; Copy score to R0 for grade display
JSR SHOW_GRADE              ; Call subroutine to show letter grade

; Get Score 4 and display its grade
LEA R0, PROMPT4             ; Load address of "Score 4: " prompt
PUTS                        ; Display the prompt to user  
JSR GET_SCORE               ; Call subroutine to get fourth score
LEA R1, SCORES              ; Load base address of scores array
STR R3, R1, #3              ; Store fourth score at SCORES[3]
ADD R0, R3, #0              ; Copy score to R0 for grade display
JSR SHOW_GRADE              ; Call subroutine to show letter grade

; Get Score 5 and display its grade
LEA R0, PROMPT5             ; Load address of "Score 5: " prompt
PUTS                        ; Display the prompt to user
JSR GET_SCORE               ; Call subroutine to get fifth score
LEA R1, SCORES              ; Load base address of scores array
STR R3, R1, #4              ; Store fifth score at SCORES[4]
ADD R0, R3, #0              ; Copy score to R0 for grade display
JSR SHOW_GRADE              ; Call subroutine to show letter grade

; Calculate and display statistics (min, max, average)
JSR CALC_RESULTS            ; Call subroutine to calculate and display results

; Demonstrate stack operations by finding lowest grade
JSR FIND_LOWEST_GRADE       ; Call subroutine to demonstrate PUSH/POP operations

HALT                        ; Stop program execution

;------------------------------------------------------------------------------
; DATA SECTION - String constants and variables
;------------------------------------------------------------------------------

; String messages for user interface
WELCOME     .STRINGZ "=== Test Score Calculator ===\n"
PROMPT1     .STRINGZ "Score 1: "
PROMPT2     .STRINGZ "Score 2: "
PROMPT3     .STRINGZ "Score 3: "
PROMPT4     .STRINGZ "Score 4: "
PROMPT5     .STRINGZ "Score 5: "
GRADE_MSG   .STRINGZ " Grade: "
MAX_MSG     .STRINGZ "Maximum: "
MIN_MSG     .STRINGZ "Minimum: "
AVG_MSG     .STRINGZ "Average: "

; Useful constants
NEG_48      .FILL #-48      ; Negative ASCII '0' for converting ASCII to number
NEWLINE     .FILL #10       ; ASCII newline character
SPACE       .FILL #32       ; ASCII space character

; Memory allocation
SCORES      .BLKW 5         ; Reserve 5 words for storing the test scores
SAVE_R7     .FILL #0        ; Memory location to save R7 register
STACK_SAVE_R1 .FILL #0      ; Save location for R1 in stack operations
STACK_SAVE_R2 .FILL #0      ; Save location for R2 in comparison operations
STACK_SAVE_R3 .FILL #0      ; Save location for R3 in print operations

;==============================================================================
; GET_SCORE - Subroutine to get a two-digit score from user input
; Input: None (reads from keyboard)
; Output: R3 = numeric score value (0-99)
; Registers used: R0, R1, R2, R3, R4
; Side effects: Echoes input characters to console
;==============================================================================
GET_SCORE
    ST R7, SAVE_R7          ; Save return address
    
    AND R3, R3, #0          ; Clear R3
    LD R4, NEG_48           ; Load -48 for ASCII to number conversion
    
    ; Get first digit (tens place)
    GETC                    ; Get character from keyboard into R0
    OUT                     ; Echo the character to console
    ADD R1, R0, R4          ; Convert ASCII digit to number (R1 = R0 - 48)
    
    ; Multiply first digit by 10 using repeated addition
    AND R3, R3, #0          ; Clear result register
    AND R2, R2, #0          ; Clear counter
    ADD R2, R2, #10         ; Set counter to 10
MULT_LOOP
    ADD R3, R3, R1          ; Add first digit to result
    ADD R2, R2, #-1         ; Decrement counter
    BRp MULT_LOOP           ; Continue if counter > 0
    
    ; Get second digit (ones place)
    GETC                    ; Get second character from keyboard
    OUT                     ; Echo the character to console
    ADD R0, R0, R4          ; Convert ASCII digit to number
    ADD R3, R3, R0          ; Add ones digit to (tens digit * 10)
    
    LD R7, SAVE_R7          ; Restore return address
    RET                     ; Return to caller

;==============================================================================
; SHOW_GRADE - Subroutine to display letter grade based on numeric score
; Input: R3 = numeric score (0-100)
; Output: Prints letter grade and newline to console
; Registers used: R0, R1, R2
; Grading scale: A=90+, B=80-89, C=70-79, D=60-69, F=0-59
;==============================================================================
SHOW_GRADE
    ST R7, SAVE_R7          ; Save return address
    
    LEA R0, GRADE_MSG       ; Load address of " Grade: " message
    PUTS                    ; Display the grade message
    
    ADD R1, R3, #0          ; Copy score to R1
    
    ; Check for A grade (90 or higher)
    ; Subtract 90 from score using multiple ADD operations
    ADD R2, R1, #-15        ; R2 = score - 15
    ADD R2, R2, #-15        ; R2 = score - 30
    ADD R2, R2, #-15        ; R2 = score - 45
    ADD R2, R2, #-15        ; R2 = score - 60
    ADD R2, R2, #-15        ; R2 = score - 75
    ADD R2, R2, #-15        ; R2 = score - 90
    BRzp PRINT_A            ; If result = 0, score = 90, so print A
    
    ; Check for B grade (80-89)
    ADD R2, R1, #-15        ; Start over: R2 = score - 15
    ADD R2, R2, #-15        ; R2 = score - 30
    ADD R2, R2, #-15        ; R2 = score - 45
    ADD R2, R2, #-15        ; R2 = score - 60
    ADD R2, R2, #-15        ; R2 = score - 75
    ADD R2, R2, #-5         ; R2 = score - 80
    BRzp PRINT_B            ; If result = 0, score = 80, so print B
    
    ; Check for C grade (70-79)
    ADD R2, R1, #-15        ; Start over: R2 = score - 15
    ADD R2, R2, #-15        ; R2 = score - 30
    ADD R2, R2, #-15        ; R2 = score - 45
    ADD R2, R2, #-15        ; R2 = score - 60
    ADD R2, R2, #-10        ; R2 = score - 70
    BRzp PRINT_C            ; If result = 0, score = 70, so print C
    
    ; Check for D grade (60-69)
    ADD R2, R1, #-15        ; Start over: R2 = score - 15
    ADD R2, R2, #-15        ; R2 = score - 30
    ADD R2, R2, #-15        ; R2 = score - 45
    ADD R2, R2, #-15        ; R2 = score - 60
    BRzp PRINT_D            ; If result = 0, score = 60, so print D
    
    ; If we reach here, score < 60, so it's an F
    BR PRINT_F

PRINT_A
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'A' = 65
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #15         ; 30 + 15 = 45
    ADD R0, R0, #15         ; 45 + 15 = 60
    ADD R0, R0, #5          ; 60 + 5 = 65 (ASCII 'A')
    OUT                     ; Print 'A'
    BR GRADE_DONE           ; Jump to end

PRINT_B
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'B' = 66
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #6          ; 60 + 6 = 66 (ASCII 'B')
    OUT                     ; Print 'B'
    BR GRADE_DONE

PRINT_C
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'C' = 67
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #7          ; 60 + 7 = 67 (ASCII 'C')
    OUT                     ; Print 'C'
    BR GRADE_DONE

PRINT_D
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'D' = 68
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #8          ; 60 + 8 = 68 (ASCII 'D')
    OUT                     ; Print 'D'
    BR GRADE_DONE

PRINT_F
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'F' = 70
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #10         ; 60 + 10 = 70 (ASCII 'F')
    OUT                     ; Print 'F'

GRADE_DONE
    LD R0, NEWLINE          ; Load newline character
    OUT                     ; Print newline
    LD R7, SAVE_R7          ; Restore return address
    RET                     ; Return to caller

;==============================================================================
; CALC_RESULTS - Calculate and display minimum, maximum, and average scores
; Input: SCORES array contains 5 test scores
; Output: Prints min, max, and average to console
; Registers used: R0, R1, R2, R3, R4
;==============================================================================
CALC_RESULTS
    ST R7, SAVE_R7          ; Save return address
    
    ;--------------------------------------------------------------------------
    ; Find and display maximum score
    ;--------------------------------------------------------------------------
    LEA R0, MAX_MSG         ; Load address of "Maximum: " message
    PUTS                    ; Display the message
    
    LEA R1, SCORES          ; Load base address of scores array
    LDR R2, R1, #0          ; Initialize max with first score
    
    ; Compare with remaining scores
    LDR R3, R1, #1          ; Load second score
    JSR COMPARE_MAX         ; Compare and update max if needed
    LDR R3, R1, #2          ; Load third score
    JSR COMPARE_MAX         ; Compare and update max if needed
    LDR R3, R1, #3          ; Load fourth score
    JSR COMPARE_MAX         ; Compare and update max if needed
    LDR R3, R1, #4          ; Load fifth score
    JSR COMPARE_MAX         ; Compare and update max if needed
    
    ADD R0, R2, #0          ; Move maximum score to R0
    JSR STACK_PRINT         ; Print the maximum score
    
    ;--------------------------------------------------------------------------
    ; Find and display minimum score
    ;--------------------------------------------------------------------------
    LEA R0, MIN_MSG         ; Load address of "Minimum: " message
    PUTS                    ; Display the message
    
    LEA R1, SCORES          ; Load base address of scores array
    LDR R2, R1, #0          ; Initialize min with first score
    
    ; Compare with remaining scores
    LDR R3, R1, #1          ; Load second score
    JSR COMPARE_MIN         ; Compare and update min if needed
    LDR R3, R1, #2          ; Load third score
    JSR COMPARE_MIN         ; Compare and update min if needed
    LDR R3, R1, #3          ; Load fourth score
    JSR COMPARE_MIN         ; Compare and update min if needed
    LDR R3, R1, #4          ; Load fifth score
    JSR COMPARE_MIN         ; Compare and update min if needed
    
    ADD R0, R2, #0          ; Move minimum score to R0
    JSR STACK_PRINT         ; Print the minimum score
    
    ;--------------------------------------------------------------------------
    ; Calculate and display average score
    ;--------------------------------------------------------------------------
    LEA R0, AVG_MSG         ; Load address of "Average: " message
    PUTS                    ; Display the message
    
    LEA R1, SCORES          ; Load base address of scores array
    AND R0, R0, #0          ; Initialize sum to 0
    
    ; Add all five scores
    LDR R2, R1, #0          ; Load first score
    ADD R0, R0, R2          ; Add to sum
    LDR R2, R1, #1          ; Load second score
    ADD R0, R0, R2          ; Add to sum
    LDR R2, R1, #2          ; Load third score
    ADD R0, R0, R2          ; Add to sum
    LDR R2, R1, #3          ; Load fourth score
    ADD R0, R0, R2          ; Add to sum
    LDR R2, R1, #4          ; Load fifth score
    ADD R0, R0, R2          ; Add to sum
    
    ; Divide sum by 5 using repeated subtraction
    AND R3, R3, #0          ; Initialize quotient to 0
AVG_DIV_LOOP
    ADD R4, R0, #-5         ; Check if sum >= 5
    BRn AVG_DIV_DONE        ; If sum < 5, division is complete
    ADD R0, R0, #-5         ; Subtract 5 from sum
    ADD R3, R3, #1          ; Increment quotient
    BR AVG_DIV_LOOP         ; Continue division
AVG_DIV_DONE
    ADD R0, R3, #0          ; Move quotient (average) to R0
    JSR STACK_PRINT         ; Print the average
    
    LD R7, SAVE_R7          ; Restore return address
    RET                     ; Return to caller

;==============================================================================
; COMPARE_MAX - Helper subroutine to update maximum value
; Input: R2 = current maximum, R3 = value to compare
; Output: R2 = updated maximum (R2 or R3, whichever is larger)
; Registers used: R4
;==============================================================================
COMPARE_MAX
    ST R7, STACK_SAVE_R1    ; Save return address
    ; Check if R3 > R2 by computing R3 - R2
    NOT R4, R2              ; R4 = bitwise NOT of R2
    ADD R4, R4, #1          ; R4 = -R2 (two's complement)
    ADD R4, R3, R4          ; R4 = R3 - R2
    BRnz SKIP_MAX_UPDATE    ; If R3 <= R2, don't update
    ADD R2, R3, #0          ; Update max: R2 = R3
SKIP_MAX_UPDATE
    LD R7, STACK_SAVE_R1    ; Restore return address
    RET                     ; Return to caller

;==============================================================================
; COMPARE_MIN - Helper subroutine to update minimum value
; Input: R2 = current minimum, R3 = value to compare
; Output: R2 = updated minimum (R2 or R3, whichever is smaller)
; Registers used: R4
;==============================================================================
COMPARE_MIN
    ST R7, STACK_SAVE_R2    ; Save return address
    ; Check if R3 < R2 by computing R2 - R3
    NOT R4, R3              ; R4 = bitwise NOT of R3
    ADD R4, R4, #1          ; R4 = -R3 (two's complement)
    ADD R4, R2, R4          ; R4 = R2 - R3
    BRnz SKIP_MIN_UPDATE    ; If R2 <= R3, don't update
    ADD R2, R3, #0          ; Update min: R2 = R3
SKIP_MIN_UPDATE
    LD R7, STACK_SAVE_R2    ; Restore return address
    RET                     ; Return to caller

;==============================================================================
; STACK_PRINT - Print a two-digit number (0-99)
; Input: R0 = number to print (0-99)
; Output: Prints number followed by newline to console
; Registers used: R0, R1, R2, R3
;==============================================================================
STACK_PRINT
    ST R7, STACK_SAVE_R3    ; Save return address
    AND R1, R1, #0          ; Initialize tens digit counter to 0
    ADD R2, R0, #0          ; Copy number to R2
    
    ; Count tens digits by repeated subtraction
TENS_LOOP_SP
    ADD R3, R2, #-10        ; Check if number >= 10
    BRn PRINT_BOTH_SP       ; If < 10, we're done counting tens
    ADD R1, R1, #1          ; Increment tens counter
    ADD R2, R2, #-10        ; Subtract 10 from number
    BR TENS_LOOP_SP         ; Continue counting
    
PRINT_BOTH_SP
    ; Print tens digit
    LD R0, NEG_48           ; Load -48
    NOT R0, R0              ; Bitwise NOT of -48
    ADD R0, R0, #1          ; R0 = 48 (ASCII '0')
    ADD R0, R0, R1          ; Add tens digit value
    OUT                     ; Print tens digit
    
    ; Print ones digit
    LD R0, NEG_48           ; Load -48  
    NOT R0, R0              ; Bitwise NOT of -48
    ADD R0, R0, #1          ; R0 = 48 (ASCII '0')
    ADD R0, R0, R2          ; Add ones digit value
    OUT                     ; Print ones digit
    
    LD R0, NEWLINE          ; Load newline character
    OUT                     ; Print newline
    LD R7, STACK_SAVE_R3    ; Restore return address
    RET                     ; Return to caller

;==============================================================================
; FIND_LOWEST_GRADE - Demonstrate stack operations by finding lowest grade
; Input: SCORES array contains 5 test scores
; Output: Prints lowest grade found using stack operations
; Registers used: R0, R1, R2
; Stack Operations: Demonstrates both PUSH (store) and POP (retrieve) functionality
;==============================================================================
FIND_LOWEST_GRADE
    ST R7, LOCAL_SAVE_R7    ; Save return address
    
    ; Push all letter grades to stack (demonstrates PUSH operations)
    LEA R1, SCORES          ; Load base address of scores array
    
    ; Convert first score to grade and push to stack
    LDR R0, R1, #0          ; Load first score
    JSR GET_STACK_GRADE     ; Convert score to stack grade letter (A or F)
    JSR STACK_PUSH          ; Push grade letter onto stack
    
    ; Convert second score to grade and push to stack  
    LDR R0, R1, #1          ; Load second score
    JSR GET_STACK_GRADE     ; Convert score to stack grade letter (A or F)
    JSR STACK_PUSH          ; Push grade letter onto stack
    
    ; Convert third score to grade and push to stack
    LDR R0, R1, #2          ; Load third score
    JSR GET_STACK_GRADE     ; Convert score to stack grade letter (A or F)
    JSR STACK_PUSH          ; Push grade letter onto stack
    
    ; Convert fourth score to grade and push to stack
    LDR R0, R1, #3          ; Load fourth score
    JSR GET_STACK_GRADE     ; Convert score to stack grade letter (A or F)
    JSR STACK_PUSH          ; Push grade letter onto stack
    
    ; Convert fifth score to grade and push to stack
    LDR R0, R1, #4          ; Load fifth score
    JSR GET_STACK_GRADE     ; Convert score to stack grade letter (A or F)
    JSR STACK_PUSH          ; Push grade letter onto stack
    
    ; Now find the lowest grade by popping and comparing (demonstrates POP operations)
    JSR STACK_POP           ; Pop first grade from stack
    ADD R2, R0, #0          ; R2 = lowest grade so far
    
    JSR STACK_POP           ; Pop second grade from stack
    JSR COMPARE_LOWER       ; Compare and update R2 if current grade is lower
    
    JSR STACK_POP           ; Pop third grade from stack
    JSR COMPARE_LOWER       ; Compare and update R2 if current grade is lower
    
    JSR STACK_POP           ; Pop fourth grade from stack
    JSR COMPARE_LOWER       ; Compare and update R2 if current grade is lower
    
    JSR STACK_POP           ; Pop fifth grade from stack
    JSR COMPARE_LOWER       ; Compare and update R2 if current grade is lower
    
    ; Display the result with proper formatting
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #10         ; Load ASCII newline character (10)
    OUT                     ; Print newline for spacing
    
    ; Print "Low: " message
    ; Print 'L' (ASCII 76)
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'L' = 76
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #15         ; 30 + 15 = 45
    ADD R0, R0, #15         ; 45 + 15 = 60
    ADD R0, R0, #15         ; 60 + 15 = 75
    ADD R0, R0, #1          ; 75 + 1 = 76 (ASCII 'L')
    OUT                     ; Print 'L'
    
    ; Print 'o' (ASCII 111)
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'o' = 111
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #15         ; 30 + 15 = 45
    ADD R0, R0, #15         ; 45 + 15 = 60
    ADD R0, R0, #15         ; 60 + 15 = 75
    ADD R0, R0, #15         ; 75 + 15 = 90
    ADD R0, R0, #15         ; 90 + 15 = 105
    ADD R0, R0, #6          ; 105 + 6 = 111 (ASCII 'o')
    OUT                     ; Print 'o'
    
    ; Print 'w' (ASCII 119)
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'w' = 119
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #15         ; 30 + 15 = 45
    ADD R0, R0, #15         ; 45 + 15 = 60
    ADD R0, R0, #15         ; 60 + 15 = 75
    ADD R0, R0, #15         ; 75 + 15 = 90
    ADD R0, R0, #15         ; 90 + 15 = 105
    ADD R0, R0, #14         ; 105 + 14 = 119 (ASCII 'w')
    OUT                     ; Print 'w'
    
    ; Print ':' (ASCII 58)
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII ':' = 58
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #15         ; 30 + 15 = 45
    ADD R0, R0, #13         ; 45 + 13 = 58 (ASCII ':')
    OUT                     ; Print ':'
    
    ; Print space character (ASCII 32)
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII space = 32
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #2          ; 30 + 2 = 32 (ASCII space)
    OUT                     ; Print space
    
    ; Output the lowest grade letter found by stack operations
    ADD R0, R2, #0          ; Move lowest grade from R2 to R0
    OUT                     ; Print the lowest grade letter (A or F)
    
    ; Print final newline
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #10         ; Load ASCII newline character (10)
    OUT                     ; Print newline
    
    LD R7, LOCAL_SAVE_R7    ; Restore return address
    RET                     ; Return to calling program

;==============================================================================
; GET_STACK_GRADE - Convert numeric score to stack letter grade
; Input: R0 = numeric score (0-100)
; Output: R0 = grade letter (A for 90+, F for below 90)
; Registers used: R0, R3
; NOTE: Grading scale updated to A=90+, F=0-89 (simplified for stack operations).
; The rest of the program still utilizes the grading scale accurately & as intended.
;==============================================================================
GET_STACK_GRADE
    ; Check for A grade (90 or higher)
    ; Subtract 90 from score using multiple ADD operations
    ADD R3, R0, #-15        ; R3 = score - 15
    ADD R3, R3, #-15        ; R3 = score - 30
    ADD R3, R3, #-15        ; R3 = score - 45
    ADD R3, R3, #-15        ; R3 = score - 60
    ADD R3, R3, #-15        ; R3 = score - 75
    ADD R3, R3, #-15        ; R3 = score - 90
    BRzp RETURN_STACK_A     ; If result = 0, score = 90, so return A
    
    ; If score < 90, return F grade
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'F' = 70
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #15         ; 30 + 15 = 45
    ADD R0, R0, #15         ; 45 + 15 = 60
    ADD R0, R0, #10         ; 60 + 10 = 70 (ASCII 'F')
    RET                     ; Return to caller with F in R0

RETURN_STACK_A
    AND R0, R0, #0          ; Clear R0
    ADD R0, R0, #15         ; Build ASCII 'A' = 65
    ADD R0, R0, #15         ; 15 + 15 = 30
    ADD R0, R0, #15         ; 30 + 15 = 45
    ADD R0, R0, #15         ; 45 + 15 = 60
    ADD R0, R0, #5          ; 60 + 5 = 65 (ASCII 'A')
    RET                     ; Return to caller with A in R0

;==============================================================================
; STACK_PUSH - Push a value onto the local stack
; Input: R0 = value to push onto stack
; Output: None (value stored in stack)
; Registers used: R0, R1, R2
;==============================================================================
STACK_PUSH
    ST R1, PUSH_SAVE_R1     ; Save R1
    ST R2, PUSH_SAVE_R2     ; Save R2
    
    ; Use local array-based stack implementation
    LEA R1, LOCAL_STACK     ; Load address of local stack array
    LD R2, STACK_INDEX      ; Load current stack index (0-4)
    ADD R1, R1, R2          ; Add index offset to stack base
    STR R0, R1, #0          ; Store value at calculated stack position
    ADD R2, R2, #1          ; Increment stack index
    ST R2, STACK_INDEX      ; Save updated stack index
    
    LD R2, PUSH_SAVE_R2     ; Restore R2
    LD R1, PUSH_SAVE_R1     ; Restore R1
    RET                     ; Return to calling program

;==============================================================================  
; STACK_POP - Pop a value from the local stack
; Input: None
; Output: R0 = value popped from stack
; Registers used: R0, R1, R2
;==============================================================================
STACK_POP
    ST R1, POP_SAVE_R1      ; Save R1
    ST R2, POP_SAVE_R2      ; Save R2
    
    ; Use local array-based stack implementation
    LEA R1, LOCAL_STACK     ; Load address of local stack array
    LD R2, STACK_INDEX      ; Load current stack index
    ADD R2, R2, #-1         ; Decrement stack index (pop operation)
    ST R2, STACK_INDEX      ; Save updated stack index
    ADD R1, R1, R2          ; Add index offset to stack base
    LDR R0, R1, #0          ; Load value from calculated stack position
    
    LD R2, POP_SAVE_R2      ; Restore R2
    LD R1, POP_SAVE_R1      ; Restore R1
    RET                     ; Return with popped value in R0

;==============================================================================
; COMPARE_LOWER - Compare grades and update lowest grade holder
; Input: R0 = current grade to compare, R2 = current lowest grade
; Output: R2 = updated lowest grade (whichever is "lower")
; Registers used: R0, R2, R3
;==============================================================================
COMPARE_LOWER
    ; Compare ASCII values: F(70) is "lower grade" than A(65)
    ; We want the higher ASCII value since F > A in ASCII but F < A academically
    NOT R3, R0              ; R3 = bitwise NOT of current grade
    ADD R3, R3, #1          ; R3 = -R0 (two's complement)
    ADD R3, R2, R3          ; R3 = R2 - R0
    BRzp SKIP_UPDATE        ; If R2 >= R0, skip update
    ADD R2, R0, #0          ; Update lowest grade: R2 = R0
SKIP_UPDATE
    RET                     ; Return with updated R2

; Local stack implementation
LOCAL_STACK  .BLKW 5        ; Reserve 5 words for local stack array
STACK_INDEX  .FILL #0       ; Current stack index (0-4), starts at 0

; Save locations for stack operations
LOCAL_SAVE_R7 .FILL #0      ; Save location for R7 in FIND_LOWEST_GRADE
PUSH_SAVE_R1 .FILL #0       ; Save location for R1 in SIMPLE_PUSH
PUSH_SAVE_R2 .FILL #0       ; Save location for R2 in SIMPLE_PUSH
POP_SAVE_R1  .FILL #0       ; Save location for R1 in SIMPLE_POP
POP_SAVE_R2  .FILL #0       ; Save location for R2 in SIMPLE_POP

.END