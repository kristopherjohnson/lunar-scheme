;; Translation of
;; <http://www.cs.brandeis.edu/~storer/LunarLander/LunarLander/LunarLanderListing.jpg>
;; by Jim Storer from FOCAL to Scheme.

;; Global game state variables
(define A 0.0)    ; Altitude (miles)
(define V 0.0)    ; Downward speed (miles/sec)
(define M 0.0)    ; Total weight (lbs)
(define N 0.0)    ; Empty weight (lbs)
(define G 0.0)    ; Gravity
(define Z 0.0)    ; Thrust per pound of fuel burned
(define L 0.0)    ; Elapsed time (sec)
(define K 0.0)    ; Fuel rate (lbs/sec)
(define S 0.0)    ; Time elapsed in current turn (sec)
(define T 0.0)    ; Time remaining in current turn (sec)
(define I 0.0)    ; Intermediate altitude (miles)
(define J 0.0)    ; Intermediate velocity (miles/sec)
(define W 0.0)    ; Temporary working variable

;; Input/Output procedures


;; Read a line from input (portable)
(define (read-line-safe)
  (let ((line
         ;; Build line character by character for maximum portability
         (let loop ((chars '()))
           (let ((c (read-char)))
             (cond
               ((eof-object? c)
                (if (null? chars) c (list->string (reverse chars))))
               ((char=? c #\newline)
                (list->string (reverse chars)))
               (else (loop (cons c chars))))))))
    (if (eof-object? line)
        (begin
          (display "END OF INPUT" (current-error-port))
          (newline (current-error-port))
          (exit 1))
        line)))

;; Parse a number from string, return #f if invalid
(define (parse-number str)
  (let ((trimmed (string-trim-both str)))
    (if (string=? trimmed "")
        #f
        (let ((num (string->number trimmed)))
          (if (and num (real? num))
              num
              #f)))))

;; Accept a double value from input
(define (accept-double)
  (let* ((line (read-line-safe))
         (num (parse-number line)))
    (if num
        num
        #f)))

;; Accept yes or no answer
(define (accept-yes-or-no)
  (let loop ()
    (display "(ANS. YES OR NO):")
    (let* ((line (read-line-safe))
           (trimmed (string-trim-both line)))
      (cond
        ((> (string-length trimmed) 0)
         (let ((first-char (char-downcase (string-ref trimmed 0))))
           (cond
             ((char=? first-char #\y) #t)
             ((char=? first-char #\n) #f)
             (else (loop)))))
        (else (loop))))))

;; String trimming procedures for portability
(define (string-trim-both str)
  (string-trim-right (string-trim-left str)))

(define (string-trim-left str)
  (let ((len (string-length str)))
    (let loop ((i 0))
      (cond
        ((>= i len) "")
        ((char-whitespace? (string-ref str i))
         (loop (+ i 1)))
        (else (substring str i len))))))

(define (string-trim-right str)
  (let ((len (string-length str)))
    (let loop ((i (- len 1)))
      (cond
        ((< i 0) "")
        ((char-whitespace? (string-ref str i))
         (loop (- i 1)))
        (else (substring str 0 (+ i 1)))))))

;; String utility functions for portability
(define (string-contains str substr)
  (let ((str-len (string-length str))
        (substr-len (string-length substr)))
    (let loop ((i 0))
      (cond
        ((> (+ i substr-len) str-len) #f)
        ((string=? (substring str i (+ i substr-len)) substr) #t)
        (else (loop (+ i 1)))))))

(define (string-split str delim)
  (let ((delim-len (string-length delim))
        (str-len (string-length str)))
    (let loop ((start 0) (result '()))
      (let ((pos (string-find-pos str delim start)))
        (if pos
            (loop (+ pos delim-len)
                  (cons (substring str start pos) result))
            (reverse (cons (substring str start str-len) result)))))))

(define (string-find-pos str substr start)
  (let ((str-len (string-length str))
        (substr-len (string-length substr)))
    (let loop ((i start))
      (cond
        ((> (+ i substr-len) str-len) #f)
        ((string=? (substring str i (+ i substr-len)) substr) i)
        (else (loop (+ i 1)))))))


;; Physics calculations

;; Apply thrust for time S with fuel rate K
(define (apply-thrust!)
  (let* ((Q (/ (* S K) M))
         (Q-2 (* Q Q))
         (Q-3 (* Q-2 Q))
         (Q-4 (* Q-3 Q))
         (Q-5 (* Q-4 Q)))
    (set! J (+ V
               (* G S)
               (* Z (- (+ Q
                          (/ Q-2 2)
                          (/ Q-3 3)
                          (/ Q-4 4)
                          (/ Q-5 5))))))
    (set! I (+ A
               (- (* G S S 0.5))
               (- (* V S))
               (* Z S (+ (/ Q 2)
                         (/ Q-2 6)
                         (/ Q-3 12)
                         (/ Q-4 20)
                         (/ Q-5 30)))))))

;; Update lander state
(define (update-lander-state!)
  (set! L (+ L S))
  (set! T (- T S))
  (set! M (- M (* S K)))
  (set! A I)
  (set! V J))

;; Game procedures

;; Initialize game state
(define (init-game!)
  (set! A 120.0)
  (set! V 1.0)
  (set! M 32500.0)
  (set! N 16500.0)
  (set! G 0.001)
  (set! Z 1.8)
  (set! L 0.0))

;; Number formatting helpers
(define (pad-left str width)
  (let ((len (string-length str)))
    (if (>= len width)
        str
        (string-append (make-string (- width len) #\space) str))))

(define (format-float num decimals)
  (let* ((factor (expt 10 decimals))
         (rounded (/ (round (* num factor)) factor)))
    (if (= decimals 0)
        (number->string (inexact->exact (round rounded)))
        (let ((str (number->string rounded)))
          (cond
            ((string-contains str ".")
             (let* ((parts (string-split str "."))
                    (int-part (car parts))
                    (frac-part (if (null? (cdr parts)) "" (cadr parts)))
                    (padded-frac (string-append frac-part
                                               (make-string (max 0 (- decimals (string-length frac-part))) #\0))))
               (string-append int-part "." (substring padded-frac 0 (min decimals (string-length padded-frac))))))
            (else
             (string-append str "." (make-string decimals #\0))))))))

;; Format and display game status line
(define (display-status)
  (let ((time-str (pad-left (format-float L 0) 7))
        (alt-miles-str (pad-left (format-float (truncate A) 0) 16))
        (alt-feet-str (pad-left (format-float (* 5280 (- A (truncate A))) 0) 7))
        (vel-str (pad-left (format-float (* 3600 V) 2) 15))
        (fuel-str (pad-left (format-float (- M N) 1) 12)))
    (display time-str)
    (display alt-miles-str)
    (display alt-feet-str)
    (display vel-str)
    (display fuel-str)
    (display "      ")))

;; Prompt for fuel rate K
(define (prompt-for-k)
  (let loop ()
    (display "K=:")
    (let ((input-k (accept-double)))
      (cond
        ((or (not input-k)
             (< input-k 0)
             (and (> input-k 0) (< input-k 8))
             (> input-k 200))
         (display "NOT POSSIBLE")
         (let loop-dots ((x 1))
           (when (<= x 51)
             (display ".")
             (loop-dots (+ x 1))))
         (loop))
        (else
         (set! K input-k))))))

;; Main game loop
(define (play-game)
  (display "FIRST RADAR CHECK COMING UP")
  (newline)
  (newline)
  (newline)
  (display "COMMENCE LANDING PROCEDURE")
  (newline)
  (display "TIME,SECS   ALTITUDE,MILES+FEET   VELOCITY,MPH   FUEL,LBS   FUEL RATE")
  (newline)

  (init-game!)

  ;; Game state control
  (let main-loop ()
    ;; Start turn
    (display-status)
    (prompt-for-k)
    (set! T 10.0)

    ;; Turn processing
    (let turn-loop ()
      (cond
        ;; Check for fuel out
        ((< (- M N) 0.001)
         (fuel-out))
        ;; Check if turn is over
        ((< T 0.001)
         (main-loop))
        ;; Continue turn
        (else
         (set! S T)
         ;; Check if we have enough fuel for full burn
         (when (> (- (+ N (* S K)) M) 0)
           (set! S (/ (- M N) K)))

         (apply-thrust!)

         (cond
           ;; Check if we hit the moon
           ((<= I 0)
            (loop-until-on-moon))
           ;; Check for velocity sign change and handle special case
           ((and (> V 0) (< J 0))
            (velocity-sign-change-turn-loop turn-loop))
           ;; Normal case
           (else
            (update-lander-state!)
            (turn-loop))))))))

;; Handle velocity sign change with continuation
(define (velocity-sign-change-turn-loop continue-turn)
  (let loop ()
    (set! W (/ (- 1 (/ (* M G) (* Z K))) 2))
    (set! S (+ (/ (* M V)
                  (* Z K (+ W (sqrt (+ (* W W) (/ V Z))))))
               0.05))
    (apply-thrust!)
    (cond
      ((<= I 0)
       (loop-until-on-moon))
      (else
       (update-lander-state!)
       (cond
         ((>= (- J) 0)
          (continue-turn))
         ((<= V 0)
          (continue-turn))
         (else
          (loop)))))))

;; Continue until on the moon
(define (loop-until-on-moon)
  (let loop ()
    (when (>= S 0.005)
      (set! S (/ (* 2 A)
                 (+ V (sqrt (+ (* V V) (* 2 A (- G (/ (* Z K) M))))))))
      (apply-thrust!)
      (update-lander-state!)
      (loop)))
  (on-the-moon))

;; Handle fuel exhaustion
(define (fuel-out)
  (display "FUEL OUT AT ")
  (display (pad-left (format-float L 2) 8))
  (display " SECS")
  (newline)
  (set! S (/ (- (sqrt (+ (* V V) (* 2 A G))) V) G))
  (set! V (+ V (* G S)))
  (set! L (+ L S))
  (on-the-moon))

;; Handle landing
(define (on-the-moon)
  (display "ON THE MOON AT ")
  (display (pad-left (format-float L 2) 8))
  (display " SECS")
  (newline)
  (set! W (* 3600 V))
  (display "IMPACT VELOCITY OF ")
  (display (pad-left (format-float W 2) 8))
  (display " M.P.H.")
  (newline)
  (display "FUEL LEFT: ")
  (display (pad-left (format-float (- M N) 2) 8))
  (display " LBS")
  (newline)
  (cond
    ((<= W 1)
     (display "PERFECT LANDING !-(LUCKY)")
     (newline))
    ((<= W 10)
     (display "GOOD LANDING-(COULD BE BETTER)")
     (newline))
    ((<= W 22)
     (display "CONGRATULATIONS ON A POOR LANDING")
     (newline))
    ((<= W 40)
     (display "CRAFT DAMAGE. GOOD LUCK")
     (newline))
    ((<= W 60)
     (display "CRASH LANDING-YOU'VE 5 HRS OXYGEN")
     (newline))
    (else
     (display "SORRY,BUT THERE WERE NO SURVIVORS-YOU BLEW IT!")
     (newline)
     (display "IN FACT YOU BLASTED A NEW LUNAR CRATER ")
     (display (pad-left (format-float (* W 0.277777) 2) 8))
     (display " FT. DEEP")
     (newline))))

;; Main program
(define (main)
  (display "CONTROL CALLING LUNAR MODULE. MANUAL CONTROL IS NECESSARY")
  (newline)
  (display "YOU MAY RESET FUEL RATE K EACH 10 SECS TO 0 OR ANY VALUE")
  (newline)
  (display "BETWEEN 8 & 200 LBS/SEC. YOU'VE 16000 LBS FUEL. ESTIMATED")
  (newline)
  (display "FREE FALL IMPACT TIME-120 SECS. CAPSULE WEIGHT-32500 LBS")
  (newline)
  (newline)
  (newline)

  (let loop ()
    (play-game)
    (newline)
    (newline)
    (newline)
    (display "TRY AGAIN?")
    (newline)
    (when (accept-yes-or-no)
      (loop)))

  (display "CONTROL OUT")
  (newline)
  (newline)
  (newline))

;; Start the game
(main)