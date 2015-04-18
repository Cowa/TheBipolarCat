module Step where

import Time(inSeconds)

-- Game modules
import Input (..)
import Models (..)

stepScreen: Input -> Screen -> Screen
stepScreen ({ escape } as input) ({ state, game } as screen) = case state of
  Menu -> stepMenu input screen
  Play -> { screen |
    game  <- stepGame input game,
    state <- if escape then Menu else Play }

stepMenu: Input -> Screen -> Screen
stepMenu { enter } screen =  { screen | state <- if enter then Play else Menu }

-- Handle cat's velocity left & right (vx)
walkCat: Input -> Cat -> Cat
walkCat { dir } cat = { cat | vx <-
  if | dir.x < 0 -> -0.20
     | dir.x > 0 ->  0.20
     | True      ->  0.00 }

-- Handle cat's physics (x, y)
physicsCat: Input -> Cat -> Cat
physicsCat { delta } cat = { cat |
  x <- cat.x + delta * cat.vx,
  y <- max 0 (cat.y + delta * cat.vy) }

stepGame: Input -> Game -> Game
stepGame ({ dir, delta } as input) ({ state } as game) = case state of
  NewDay  -> stepNewDay  input game
  Playing -> stepPlaying input game
  EndDay  -> stepNewDay  input game
  End     -> stepNewDay  input game
  Pause   -> stepNewDay  input game

stepNewDay: Input -> Game -> Game
stepNewDay input game = game

stepPlaying: Input -> Game -> Game
stepPlaying ({ dir, delta } as input) ({ state, time, cat } as game) =
  let
    cat' = cat |> walkCat input |> physicsCat input
  in
  { game |
    time <- time + (inSeconds delta),
    cat  <- cat' }
