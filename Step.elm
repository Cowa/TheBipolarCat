module Step where

import Debug
import Touch
import Time(inSeconds)
import List (map, (::), length, drop, reverse)

-- Game modules
import Utils (..)
import Input (..)
import Models (..)

--
-- Some stuff
--

-- Ground level
ground: Float
ground = -111

--
-- All the steps!
-- aka game logic update
--

stepScreen: Input -> Screen -> Screen
stepScreen ({ escape } as input) ({ state, game } as screen) =
  let input' = input |> Debug.watch "input"
      game'  = game  |> Debug.watch "game" in
  case state of
  Menu -> stepMenu input' screen
  Play -> { screen |
    game  <- stepGame input' game',
    state <- if escape then Menu else Play }

stepMenu: Input -> Screen -> Screen
stepMenu { enter, touch } screen = { screen | state <- if enter then Play else Menu }

stepGame: Input -> Game -> Game
stepGame ({ dir, delta, escape } as input) ({ state } as game) =
  let input' = { input | nextDay <- False } in
  if escape then { game | state <- NewDay }
  else case state of
    NewDay  -> stepNewDay  input  game
    Playing -> stepPlaying input' game
    EndDay  -> stepEndDay  input' game
    End     -> stepEnd     input' game
    Pause   -> stepNewDay  input' game

stepNewDay: Input -> Game -> Game
stepNewDay ({ enter, touch, nextDay } as input) ({ state } as game) =
  if nextDay then { game | state <- Playing } else game

stepEndDay: Input -> Game -> Game
stepEndDay { endDay } game = if endDay then { game | state <- End } else game

stepEnd: Input -> Game -> Game
stepEnd input game = game

-- Handle cat's velocity left & right (vx)
walkCat: Input -> Cat -> Cat
walkCat { dir } cat = { cat | vx <-
  if | dir.x < 0 -> -0.65
     | dir.x > 0 ->  0.65
     | otherwise ->  0.00 }

-- Handle cat's physics (x, y)
physicsCat: Input -> Cat -> Cat
physicsCat { delta } cat = { cat |
  x <- cat.x + delta * cat.vx,
  y <- max ground (cat.y + delta * cat.vy) }

-- Handle cat's jump
jumpCat: Input -> Cat -> Cat
jumpCat { dir } cat = if dir.y > 0 && cat.y == ground then { cat | vy <- 2 } else cat

-- Handle cat's gravity
gravityCat: Input -> Cat -> Cat
gravityCat { delta } cat = if cat.y > ground then { cat | vy <- cat.vy - delta / 50 } else cat

-- Handle cat's actions (meooww, purrr)
actionCat: Input -> Cat -> Cat
actionCat { space } cat = { cat |
  action <- if | space     -> Meow
               | otherwise -> Nope }

-- People step logic (emotion)
stepPeople: Cat -> List People -> List People
stepPeople cat people = map (\p -> { p |
  emotionBar <-
    if nearCatInAction cat p && length p.emotionBar < 8 then
      (receivedEmotion cat p) :: p.emotionBar
    else if nearCatInAction cat p then
      (receivedEmotion cat p) :: (drop 1 (reverse p.emotionBar))
    else
      p.emotionBar }) people

-- Check if a cat is near a people AND in action
nearCatInAction: Cat -> People -> Bool
nearCatInAction cat people = (case cat.action of
  Meow -> True
  Purr -> True
  _    -> False) && nearCat cat people |> Debug.watch "nearAction"

-- The emotion emitted by the people in response to cat's action
receivedEmotion: Cat -> People -> Emotion
receivedEmotion cat people = case cat.action of
  Meow -> Good
  Purr -> Bad
  _    -> Bad

stepPlaying: Input -> Game -> Game
stepPlaying ({ delta } as input) ({ time, cat, people } as game) =
  let
    cat' = cat |> jumpCat input |> gravityCat input
               |> walkCat input |> physicsCat input
               |> actionCat input
               |> Debug.watch "cat"
    people' = people |> stepPeople cat
  in
  if time < 100 then { game |
    time <- time + (inSeconds (delta * 4)),
    cat  <- cat',
    people <- people' }
  else { game |
    time <- 0,
    state <- EndDay
  }
