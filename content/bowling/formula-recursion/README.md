# Recursion-based definition of bowling

The equational definition of the game of bowling in [bowling.smt2](./bowling.smt2) is logically complete and correct.

However, its heavy use of recursion to define how to accumulate throws and how to score a game frame-by-frame makes
this a poor definition for the SMT solvers. Such solvers can _eventually_ deduce frame scores andallocation of throws to frames,
but it will take a long time.

The alternative is to defne a game not as a recursive list of frames, but rather as a datatype with exactly 10
frames in it. See the alternative definition of bowling.