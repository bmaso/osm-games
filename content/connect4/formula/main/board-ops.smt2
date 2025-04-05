#import "board.smt2"
#import "row-col.smt2"
#import "color.smt2"

#ifndef CONNECTFOUR_OPS
#define CONNECTFOUR_OPS

;; || __FILE__ || __LINE__ ||

;;;;;;;;;;
;; There are only 3 operations that take a Connect Four board from one state to another:
;;
;; * **Choose first player**. When the game first starts there is `current_player` value. The first
;;   task of the players is to choose a first player. This is encoded in the datatype `board-op.choose-first-player`,
;;   which has it's own validation rule `board-op.validation.choose-first-player`. This validation rule requires:
;;   * the before and after board state to be valid
;;   * the before state has no `current_player`
;;   * the before and after state have no `winner` value
;;   * the after value has a `current_player` must be either `red` or `black`, and it must be equal to the operation
;;     object's `first_player` value.
;;   * the `table` in the _after_ board is identical to the `table` in the _before_ board
;;
;; * **Player turn**. The operation object includes the _before_ and _after_ state of the board, and the `Coordinate`
;;   of the position to add a marker to. The operation is encoded in the datatype `board-op.player-turn`,
;;   which has its own validation rule `board-op.validation.player-turn`. This validation rule requires:
;;   * the before and after states to be valid
;;   * the _before_ state `current_player` is `red` or `black`
;;   * the _after_ state `current_player` is also `red` or `black`, and is not equal to the _before_ state value
;;   * neither the _before_ nor _after_ boards have a `winner` value
;;   * all table positions _except_ the position indicated by the operation object's `targetCoord` value
;;     are identical in the _before_ and _after_ state
;;   * the `targetCoord` position in the _before_ board must not have a checker in it
;;   * the `targetCoord` position in the _after_ baord must have a check that is the same color as the _before_ baord's
;;     `current_player` value
;;
;; * **Winner declaration**. The operation object includes the winner's color, and a description of where on the
;;   table there is a sequence of 4-in-a-row to justify the declaration of winning. (There is no requirement that the
;;   `current_player` be the declared winner -- if you find that you have 4-in-a-row after your turn is over, you can
;;   still declare yourself a winner.) The operation is encoded in the datatype `board-op.declare-winner`, which
;;   has its own validation rule `board-op.validation.declare-winner`. This validation rule requires:
;;   * the before and after state to be valid
;;   * the _before_ state has no `winner` value
;;   * the operation's `declared_winner` value must be either `red` or `black`
;;   * the _after_ board's `winner` value is equal to the operation object's `declared_winner` value.
;;   * the _after_ and _before_ boards are identical in the `current-player` and `table` fields
;;   * the row, column, and direction values in the operation object reference a sequence of 4 table markers
;;     that are all the same color as the `declared_winner` value in the operation object
;;
;; For all valid "winner declaration" operations, the _after_ board state is invalid as a _before_ state for all operations.
;; Similarly, if a board's table is full and there are no sequences of 4-in-a-row, then the board is also invaid as a _before_ state
;; for all operations -- this represents a "draw" game.

;;;;
;; Datatype and validation function for the operation "choose first player".

(declare-datatype board-op.choose-first-player (
  (before_board Board)
  (after_board Board)
  (first_player Color)))

(define-function board-op.validation.choose-first-player ((op board-op.choose-first-player)) Bool
  (and
    (board.validation before_board)
    (board.validation after_board)
    (= neutral (current_player before_board))
    (= (first_player op) (current_player after_board))
    (= neutral (winner before_board))
    (= neutral (winner after_board))
    (= (table before_board) (table after_board))))

;;;;
;; Datatype and validation function for the operation "player turn"

(declare-datatype board-op.player-turn (
  (before_board Board)
  (after_board Board)
  (targetCoord Coordinate)))

(definte-function board-op.validation.player_turn ((op board.player-turn)) Bool
  (and
    (board.validation (before_board op))
    (board.validation (after_board op))
    (not (= neutral (current_player (before_board op))))
    (not (= neutral (current_player (after_board op))))
    (not (= (current_player (before_board op)) (current_player (after_board op))))
    (= neutral (winner (before_board op)))
    (= neutral (winner (after_board op)))
    (forall ((c Coordinate))
      (ite (= targetCoord c)
          (and
            (= neutral (select (table (before_board op)) c))
            (= (current_player (before_board op)) (select (table (after_board op)) c)))
          (= (select (table (before_board op)) c) (select (table (after_board op)) c))))))

;;;;
;; Datatype and vaidation function for the operation "declare winner"

(declare-datatype board-op.validation.declare-winner (
  (before_board Board)
  (after_board Board)
  (declared_winner Color)
  (rootCoord Coordinate)
  (dir Direction)))

(define-function board-op.validation.declare-winner ((op board-op.declare-winner)) Bool
  (and
    (board.validation (before_board op))
    (board.validation (after_board op))
    (not (= neutral (declared_winner op)))
    (= neutral (winner (before_board op)))
    (= (declared_winner op) (winner (after_board op)))
    (= (current_player (before_board op)) (current_player (after_board op)))
    (= (table (before_board op)) (table (after_board op)))
    (table.verify-winning (table (before_board op)) (rootCoord op) (dir op) (declared_winner op))))

#endif