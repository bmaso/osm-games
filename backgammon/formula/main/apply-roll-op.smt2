#include "board.smt2"
#include "die-roll.smt2"
#include "color.smt2"
#include "point.smt2"

;; || __FILE__ || __LINE__ ||

#ifndef BACKGAMMON_OPS_APPLYROLL
#define BACKGAMMON_OPS_APPLYROLL

;;;;;;;;;;
;; There are 4 types of individual die roll applications, each one here represented with a different `ApplyRollOp` datatype
;; constant value of the `ApplyRollOp` datatype:
;;
;; - `re-enter`, which indicates a checker enters from the bar into the opponent's home board where the roll indicates. A
;;   valid re-enter roll application has these restrictions:
;;   - the prior bar has at least 1 checker of the current player's color
;;   - the opponent's prior inner table point in the position corresponding to the roll value is not controlled by the opposing player
;;   - IF the opponent's prior board point corresponding to the roll value is an opposing player blot, THEN
;;     - the same point in the post board has a single checker of the current player's color
;;     - the bar in the post board has 1 more checker of the opposing player's color compared to the prior board's bar
;;   - IF the opponent's prior board point corresponding to the roll value is not an opponent blot, THEN
;;     - the same point in the post board has one more checker of the current player than the prior board's point
;;
;; - `bear-off`, which indicates a checker exits the player's home board from a point indicated by the roll. The conditions for a valid
;;   application of this roll application are:
;;   - there are none of the current player's checkers on the bar, player's outer table, or the opponent's inner or outer tables in the
;;     prior board
;;   - EITHER
;;     - there is at least 1 of the current player's checker on the inner baord point corresponding to the roll value, in
;;       which case the _bearing off point_ is the point corresponding to the roll value
;;     - OR there are none of the current player's checkers on the inner baord at a point corresponding to the roll value or any
;;       higher value, i whcih case the _bearing off point_ is the highest point in the current player's inner board with at
;;       least one of the player's checker on it
;;   - the post board point corresponding to the bearing off point has 1 fewer checker that the bearing off point on the prior board
;;
;; - `move`, which indicates one of the current player's checkers is moved towards the end of the current player's home table in the
;;   post board vs the prior board. A valid roll application of this type has these restrictions:
;;   - there is a _source point_ and a _target point_, which differ in position exactly equal to the roll value in the direction
;;     of the current player's home table
;;   - the current player owners the source point
;;   - the current player can land on the target point with a checker (see the `point.can-target` convenience function)
;;   - the post source point has one fewer checker than the prior board source point
;;   - IF the prior target point is an opposing player blot, THEN the post target point is a current player blot AND the post bar
;;     has one more opposing player checker than the prior bar
;;   - IF the prior target point is not an opposing player blot, THEN the post target point is owned by the current player and has one
;;     more checker than the prior target board point
;;
;; - `inapplicable`, which indicates that a roll cannot be applied to a board. A valid `inapplicable` roll application leaves
;;   the board points and bar the same in prior and post states. This type of roll is valid if the the following conditions
;;   are met:
;;   - there is at least one checker of the current player's color on the prior bar, and the player cannot target the prior
;;     point in the
;;     opponent's home table corresponding to the roll value
;;   - all of the current player's checkers are not in the player's home table, or if they are then there are no checkers
;;     that can be borne off on the prior board because the prior point corresponding to the roll value has none of the
;;     player's checkers on it AND there is at least 1 higher point in the player's prior home table owned by the player 
;;   - there are no combinations of one prior point owned by the current player, and one prior point the player can land on, a distance
;;     forward in the current player's direction of play equal to the roll value
;;   - the post board and the prior board and bar are identical
;;
;;  The `apply-roll-op.validation` method verifies that the prior and post conditions for the move type, passed as input params,
;;  are met. The game validation logic uses this method to verify each of 2 die rolls of a player's turn meets the
;;  appropriate validation rule when applied to the player's board. In the case of doubles, 4 applications of the validation rule
;;  are applied as part of the player's turn.

(declare-datatype ApplyRollOp (
  (re-enter)
  (bear-off)
  (move (from_index Int))
  (inapplicable)
))

;;;;
;; A valid `re-enter` operation application has these restrictions:
;; - the prior board, post board, and die roll are all valid
;; - the prior and post board `player` value are equal to each other and to the die roll's owner, and both are either `Red` or `Black`
;; - the prior player bar count has a value of 1 or higher
;; - the opponent's prior inner table point in the position corresponding to the roll value, the _reentry_point_, is not
;;   controlled by the opposing player. (See the `point.can-target` function.)
;;   - note that the opponent's inner able is at index 19-24 of this player's board
;; - IF the prior reentry point is an opposing player blot, THEN
;;   - the post reentry point has a single checker of the current player's color
;;   - the opponent post bar count is 1 one higher than the prior count
;; - IF the opponent's prior board point corresponding to the roll value is not an opponent blot, THEN
;;   - the same point in the post board has one more checker of the current player than the prior board's point
;; - the player post bar count is 1 less than the prior count
;; - all other points than the reentry point are identical in the prior and post boards

(declare-fun apply-roll-op.re-enter.validation (Board Board DieRoll) Bool)
(assert (! (forall (
  (prior_board Board)
  (post_board Board)
  (roll DieRoll))

  (let (
    (prior_reentry_point (select (points prior_board) (- 25 (value roll))))
    (post_reentry_point (select (points post_board) (- 25 (value roll)))))

    (=
      (and
        (board.validation prior_board)
        (board.validation post_board)
        (die-roll.validation roll)

        (not (= Neutral (player prior_board)))
        (= (player prior_board) (player post_board) (player roll))

        (>= (player_bar_count prior_board) 1)

        (point.can-target prior_reentry_point (player prior_board))
        (or
          (and
            (point.is-blot prior_reentry_point)
            (= 1 (count post_reentry_point))
            (= (player prior_board) (color post_reentry_point))
            (= (opponent_bar_count post_board) (+ 1 (opponent_bar_count prior_board))))
          (and
            (not (point.is-blot (select (points prior_board) (- 25 (value roll)))))
            (= (+ 1 (count prior_reentry_point)) (count post_reentry_point))
            (= (player prior_board) (color post_reentry_point))))
        (= (- (player_bar_count prior_board) 1) (player_bar_count post_board))
        (= (points post_board) (store (points prior_board) (- 25 (value roll)) post_reentry_point)))

    (apply-roll-op.re-enter.validation prior_board post_board roll)))
) :named apply-roll-op.re-enter.validation ))

;;;;
;; A valid `bear-off` operation application has these restrictions:
;; - the prior and post board `player` value are equal to each other and to the die roll's owner, and both are either `Red` or `Black`
;; - the prior player bar count is 0
;; - All of the player's checkers in the player's inner table
;; - One of the following 2 must be true:
;;   - IFF the player occupies the point at the index indicated by the roll, THEN the post board is identical to the prior board,
;;       except the point indicated by the roll has 1 less checker on it than on the same point on the prior board
;;   - let P be the higest index number of a point occupied by the owning player on the prior inner table
;;     - IFF P is less than the die roll, THEN the post board is identical to the prior board, except the point P has 1 less
;;       checker on it than on the prior board
;; - All other points than the bearing-off point are identical in the post board and prior board states
;; - the player bar count is the same in the prior and post board states


;;;;
;; Computing P, the higest index number of a point occupied by the owning player on the prior board, would be pretty easy to
;; express recursively. However, you should avoid recursive definitions in SMT as much as possible, because SMT solvers tend
;; to avoid exploring problem spaces recursively. Instead, this definition includes a function that explicitly tests all 6
;; possible cases.
;;
;; If none of the 6 inner table points are owned by the board player, the function yields 0. It assumed that additional
;; validation rules will be applied in conjunction so that this case is not part of any valid solution.

(define-fun greatest-player-occupied-inner-table-point-index ((b Board) (i Int)) Int
  (ite (and (= i 6) (= (color (board.get-point b 6)) (player b))) 6
    (ite (and (>= i 5) (= (color (board.get-point b 5)) (player b))) 5
      (ite (and (>= i 4) (= (color (board.get-point b 4)) (player b))) 4
        (ite (and (>= i 3) (= (color (board.get-point b 3)) (player b))) 3
          (ite (and (>= i 2) (= (color (board.get-point b 2)) (player b))) 2
            (ite (and (>= i 1) (= (color (board.get-point b 1)) (player b))) 1 0)))))))

(declare-fun apply-roll-op.bear-off.validation (Board Board DieRoll) Bool)
(assert (! (forall (
  (prior_board Board)
  (post_board Board)
  (roll DieRoll))

  (=
    (let (
      (count_checkers_not_in_inner_table
        (+
          (count (board.get-point prior_board 7))
          (count (board.get-point prior_board 8))
          (count (board.get-point prior_board 9))
          (count (board.get-point prior_board 10))
          (count (board.get-point prior_board 11))
          (count (board.get-point prior_board 12))
          (count (board.get-point prior_board 13))
          (count (board.get-point prior_board 14))
          (count (board.get-point prior_board 15))
          (count (board.get-point prior_board 16))
          (count (board.get-point prior_board 17))
          (count (board.get-point prior_board 18))
          (count (board.get-point prior_board 19))
          (count (board.get-point prior_board 20))
          (count (board.get-point prior_board 21))
          (count (board.get-point prior_board 22))
          (count (board.get-point prior_board 23))
          (count (board.get-point prior_board 24))
          (player_bar_count prior_board))))

        (and
          (not (= Neutral (player prior_board)))
          (= (player prior_board) (player post_board) (player roll))

          (= 0 count_checkers_not_in_inner_table)
          (> (board.count-player-checkers prior_board) 0)

          (or
            (and
              ;; repeating the logic described above that's being implemented here:
              ;;   - IFF the player occupies the point at the index indicated by the roll, THEN the post board is
              ;;     identical to the prior board, except the point indicated by the roll has 1 less checker on it
              ;;     than on the same point on the prior board
              (= (player prior_board) (color (board.get-point prior_board (value roll))))
              (= post_board
                (let (
                  (post_point
                    (point
                      (ite (= 0 (- (count (board.get-point prior_board (value roll))) 1))
                        Neutral
                        (player prior_board))
                      (- (count (board.get-point prior_board (value roll))) 1))))

                  ((_ update-field points) prior_board (store (points prior_board) (value roll) post_point)))))

            (and
              ;; repeating the logic described above that's being implemented here:
              ;;   - let P be the higest index number of a point occupied by the owning player on the prior inner table
              ;;     - IFF P is less than the die roll, THEN the post board is identical to the prior board, except the
              ;;       point P has 1 less checker on it than on the prior board
              (let (
                (target_idx (greatest-player-occupied-inner-table-point-index prior_board (value roll))))

                (>= (value roll) target_idx)
                (= post_board
                  (let (
                    (post_point
                      (point
                        (player prior_board)
                        (- (count (board.get-point prior_board target_idx)) 1))))

                    ((_ update-field points) prior_board (store (points prior_board) target_idx post_point)))))))))

    (apply-roll-op.bear-off.validation prior_board post_board roll))
) :named apply-roll-op.bear-off.validation ))

;;;;
;; A valid `move` operation application has these restrictions:
;; - the prior and post board `player` values are equal to each other and to the die roll's owner, and both are either `Red` or `Black`
;; - the prior player bar count is 0
;; - the roll value is less than `from_index` -- otherwise the checker would be moved from its source point right off the end of
;;   the board
;; - the `from_index` is in the range 1-24
;; - the player occupies the source point, which is the point at the `from_index` operation value
;; - the player can land on the target point, which is the point at index `from-index` minus the roll value
;; - One of the following must be true:
;;   - IF the target point is a blot point owned by the opponent, THEN
;;     - in the post game board the target point is owned by the player and has exactly 1 checker on it
;;     - in the post game board the opponent bar count is 1 higher than the opponent bar count in the prior board
;;     - the source point has 1 fewer player checker in the post state than in the prior state
;;   - IF the target point is not an opponent blot point, THEN
;;     - in the post game board the target point is owned by the player and has 1 more checker on it than in the prior board state
;;     - the source point has 1 fewer player checker in the post state than in the prior state
;; - all other points than the source point and the target point are identical in the post board and prior board states
;; - the player bar count is the same in the prior and post board states

(declare-fun apply-roll-op.move.validation (Board Board Int DieRoll) Bool)
(assert (! (forall (
  (prior_board Board)
  (post_board Board)
  (from_index Int)
  (roll DieRoll))

    (=
      (let (
        (prior_source_point (board.get-point prior_board from_index))
        (post_source_point (board.get-point post_board from_index))
        (prior_target_point (board.get-point prior_board (- from_index (value roll))))
        (post_target_point (board.get-point post_board (- from_index (value roll)))))

        (and
          (not (= Neutral (player prior_board)))
          (= (player prior_board) (player post_board) (player roll))

          (= (player_bar_count prior_board) 0)

          (>= from_index 1)
          (<= from_index 24)

          (> from_index (value roll))
          (= (player prior_board) (color prior_source_point))

          (point.can-target prior_target_point (player prior_board))

          (or
            (and
              (point.is-blot prior_target_point)
              (= post_target_point (point (color prior_source_point) 1))
              (= (opponent_bar_count post_board) (+ 1 (opponent_bar_count prior_board)))
              (= post_source_point (point (color prior_source_point) (- (count prior_source_point) 1))))
            (and
              (not (point.is-blot prior_target_point))
              (= post_target_point (point (color prior_source_point) (+ 1 (count prior_source_point))))
              (= post_source_point (point (color prior_source_point) (- (count prior_source_point) 1)))))

          (=
            (points post_board)
            (store
              (store (points prior_board)
                (- from_index (value roll))
                post_target_point)
              from_index
              post_source_point))

          (= (player_bar_count post_board) (player_bar_count prior_board))))

    (apply-roll-op.move.validation prior_board post_board from_index roll))
) :named apply-roll-op.move.validation ))

;;;;
;; A valid `inapplcable` operation application has these restrictions:
;; - there does not exist any valid `re-enter`, `bear-off`, or `move` operation with the same prior board and die roll
;;   as the operation
;;   - this restriction captures the backgammon rule that says you _must_ perform a move if you have one
;; - the post board state is identical to the prior board state in all points and in the bar counts

(declare-fun apply-roll-op.inapplicable.validation (Board Board DieRoll) Bool)
(assert (! (forall (
  (prior_board Board)
  (post_board Board)
  (roll DieRoll))

  (=
    (and
      (not (exists ((reenter_post_board Board))
        (apply-roll-op.re-enter.validation prior_board reenter_post_board roll)))
      (not (exists ((bearoff_post_board Board))
        (apply-roll-op.bear-off.validation prior_board bearoff_post_board roll)))
      (not (exists ((move_post_board Board) (from_idx Int))
        (apply-roll-op.move.validation prior_board move_post_board from_idx roll)))
      (= post_board prior_board))

    (apply-roll-op.inapplicable.validation prior_board post_board roll))
) :named apply-roll-op.inapplicable.validation ))

;;;;
;; Convenience method `apply-roll-op.validation` entangles the prior and post board state with the roll value, as defined by the
;; type of roll application (re-enter, bear-off, move, or inapplicable).

(define-fun apply-roll-op.validation ((op ApplyRollOp) (prior_board Board) (post_board Board) (roll DieRoll)) Bool
  (or
    (and
      (= re-enter op)
      (apply-roll-op.re-enter.validation prior_board post_board roll))
    (and
      (= bear-off op)
      (apply-roll-op.bear-off.validation prior_board post_board roll))
    (and
      ((_ is move) op)
      (apply-roll-op.move.validation prior_board post_board (from_index op) roll)
    (and
      (= inapplicable op)
      (apply-roll-op.inapplicable.validation prior_board post_board roll))))
)

#endif


