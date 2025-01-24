#include "board.smt2"
#include "cube.smt2"
#include "color.smt2"
#include "die-roll.smt2"

#ifndef BACKGAMMON_DOMAIN_GAME
#define BACKGAMMON_DOMAIN_GAME

;;;;;;;;;;
;; The `Game` datatype represents a snapshot of the game state at any one point in time. Operations, such as `ApplyRollOp` and
;; `RollForFirstTurnOp`, are vectors that link game states together in a directed prior/post relationship. A `Game` is
;; comprised of:
;; - `next_player`, a `Color` value indicating which player's turn is next
;; - `red_board` and `black_board` values, `Board` values representing each player's own "view" of the game
;; - `cube`, which store the doubling cube value and owner
;; - `complete`, a boolean flag indicating the game is in a terminal state

(declare-datatype Game (
  (game
    (next_player Color)
    (red_board Board)
    (black_board Board)
    (cube DoublingCube)
    (complete Bool)))
)

;;;;
;; convenience constant `new-game`: equal to the initial state at the very beginning of all valid game processes.

(define-const new-game Game
  (game
    Neutral                  ; next_player, which hasn't been chosen by an initial die roll yet
    (new-game-board Red)     ; red_board
    (new-game-board Black)   ; black_board
    new-game-cube            ; cube
    false)                   ; game completion state, which is false initially
)

;;;;
;; A _valid_ game state has the following invariant restrictions:
;; - all member values must be valid
;; - the `next_player` can only be `Neutral` when the red board and black board are in the "new game" state, and the doubling
;;   cube is in the "initial" state.
;; - the `red_board` owner must be `Red` and the `black_board` owner must be `Black`
;; - the `red_board` points are equal to the reverse-ordered `black_board` points; this ensures that the `Red` player's own inner table is
;;   equal to the `Black` player's opponent's inner table, and so other with the other quadrants of the board
;; - the `red_board` player bar count is equal the the `black_board` opponent bar count, and the `red_board` opponent bar
;;   count is equal to the `black_board` player bar count

(declare-fun game.validation.members-valid (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (board.validation (red_board g))
      (board.validation (black_board g))
      (cube.validation (cube g)))
    (game.validation.members-valid g))
) :named game.validation.members-valid ))

(declare-fun game.validation.next-player-consistent-with-game-state (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (=>
      (= Neutral (next_player g))
      (and
        (= (new-game-board Red) (red_board g))
        (= (new-game-board Black) (black_board g))
        (= new-game-cube (cube g))))
    (game.validation.next-player-consistent-with-game-state g))
) :named game.validation.next-player-consistent-with-game-state ))

(declare-fun game.validation.board-owners-consistent-with-game (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (= Red (player (red_board g)))
      (= Black (player (black_board g))))
    (game.validation.board-owners-consistent-with-game g))
) :named game.validation.board-owners-consistent-with-game ))

(declare-fun game.validation.player-board-points-are-consistent-with-each-other (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (= (select (points (red_board g)) 1)  (select (points (black_board g)) 24))
      (= (select (points (red_board g)) 2)  (select (points (black_board g)) 23))
      (= (select (points (red_board g)) 3)  (select (points (black_board g)) 22))
      (= (select (points (red_board g)) 4)  (select (points (black_board g)) 21))
      (= (select (points (red_board g)) 5)  (select (points (black_board g)) 20))
      (= (select (points (red_board g)) 6)  (select (points (black_board g)) 19))
      (= (select (points (red_board g)) 7)  (select (points (black_board g)) 18))
      (= (select (points (red_board g)) 8)  (select (points (black_board g)) 17))
      (= (select (points (red_board g)) 9)  (select (points (black_board g)) 16))
      (= (select (points (red_board g)) 10) (select (points (black_board g)) 15))
      (= (select (points (red_board g)) 11) (select (points (black_board g)) 14))
      (= (select (points (red_board g)) 12) (select (points (black_board g)) 13))
      (= (select (points (red_board g)) 13) (select (points (black_board g)) 12))
      (= (select (points (red_board g)) 14) (select (points (black_board g)) 11))
      (= (select (points (red_board g)) 15) (select (points (black_board g)) 10))
      (= (select (points (red_board g)) 16) (select (points (black_board g)) 9))
      (= (select (points (red_board g)) 17) (select (points (black_board g)) 8))
      (= (select (points (red_board g)) 18) (select (points (black_board g)) 7))
      (= (select (points (red_board g)) 19) (select (points (black_board g)) 6))
      (= (select (points (red_board g)) 20) (select (points (black_board g)) 5))
      (= (select (points (red_board g)) 21) (select (points (black_board g)) 4))
      (= (select (points (red_board g)) 22) (select (points (black_board g)) 3))
      (= (select (points (red_board g)) 23) (select (points (black_board g)) 2))
      (= (select (points (red_board g)) 24) (select (points (black_board g)) 1)))
    (game.validation.player-board-points-are-consistent-with-each-other g))
) :named game.validation.player-board-points-are-consistent-with-each-other ))

(declare-fun game.validation.player-bar-counts-are-consistent-with-each-other (Game) Bool)
(assert (! (forall ((g Game))
  (=
    (and
      (= (player_bar_count (red_board g))   (opponent_bar_count (black_board g)))
      (= (opponent_bar_count (red_board g)) (player_bar_count (black_board g))))
    (game.validation.player-bar-counts-are-consistent-with-each-other g))
) :named game.validation.player-bar-counts-are-consistent-with-each-other ))

(define-fun game.validation ((g Game)) Bool
  (and
    (game.validation.members-valid g)
    (game.validation.next-player-consistent-with-game-state g)
    (game.validation.board-owners-consistent-with-game g)
    (game.validation.player-board-points-are-consistent-with-each-other g)
    (game.validation.player-bar-counts-are-consistent-with-each-other g))
)

#endif