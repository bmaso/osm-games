#include "throw.smt2"
;;|| __FILE__ || __LINE__ ||

;;;;
;; Rather than exhaustively test all possible cases, we test a few "interesting" cases to assure us the `throw.points`
;; function acts like we expect it to for valid throws matching these cases:
;; - All zeros
;; - All ones
;; - Edge cases: all bits unset but LSB, all set but LSB; same cases w/ MSB
;; - Lower half bits set and higher half bits set
;; - Alternating bits set and unset
;; - a random dense set of bits and random sparse set of bits
;; - foul, unused, and incomplete (all should be 0)
;;;;

(define-const test-data.throw.all-zeros      Throw (throw #b0000000000 false false false))
(define-const test-data.throw.all-ones       Throw (throw #b1111111111 false false false))
(define-const test-data.throw.all-but-lsb-0  Throw (throw #b0000000001 false false false))
(define-const test-data.throw.all-but-lsb-1  Throw (throw #b1111111110 false false false))
(define-const test-data.throw.all-but-msb-0  Throw (throw #b1000000000 false false false))
(define-const test-data.throw.all-but-msb-1  Throw (throw #b0111111111 false false false))
(define-const test-data.throw.lower-half-0   Throw (throw #b1111100000 false false false))
(define-const test-data.throw.upper-half-0   Throw (throw #b0000011111 false false false))
(define-const test-data.throw.alt-bits-0     Throw (throw #b1010101010 false false false))
(define-const test-data.throw.alt-bits-1     Throw (throw #b0101010101 false false false))
(define-const test-data.throw.random-dense   Throw (throw #b1101110111 false false false))
(define-const test-data.throw.random-sparse  Throw (throw #b0001001010 false false false))

;; prove all these throws are valid
(assert
  (and
    (throw.valid test-data.throw.all-zeros)
    (throw.valid test-data.throw.all-ones)
    (throw.valid test-data.throw.all-but-lsb-0)
    (throw.valid test-data.throw.all-but-lsb-1)
    (throw.valid test-data.throw.all-but-msb-0)
    (throw.valid test-data.throw.all-but-msb-1)
    (throw.valid test-data.throw.lower-half-0)
    (throw.valid test-data.throw.upper-half-0)
    (throw.valid test-data.throw.alt-bits-0)
    (throw.valid test-data.throw.alt-bits-1)
    (throw.valid test-data.throw.random-dense)
    (throw.valid test-data.throw.random-sparse)))

;; prove throw.points function computes expected value for all cases 
(assert
  (and
    (= (throw.points test-data.throw.all-zeros) 0)
    (= (throw.points test-data.throw.all-ones) 10)
    (= (throw.points test-data.throw.all-but-lsb-0) 1)
    (= (throw.points test-data.throw.all-but-lsb-1) 9)
    (= (throw.points test-data.throw.all-but-msb-0) 1)
    (= (throw.points test-data.throw.all-but-msb-1) 9)
    (= (throw.points test-data.throw.lower-half-0) 5)
    (= (throw.points test-data.throw.upper-half-0) 5)
    (= (throw.points test-data.throw.alt-bits-0) 5)
    (= (throw.points test-data.throw.alt-bits-1) 5)
    (= (throw.points test-data.throw.random-dense) 8)
    (= (throw.points test-data.throw.random-sparse) 3)
    (= (throw.points foul-throw) 0)
    (= (throw.points unused-throw) 0)
    (= (throw.points incomplete-throw) 0)))

(check-sat)