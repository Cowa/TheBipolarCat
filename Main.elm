import Text (asText)
import Time (Time, every, second, fps, inSeconds)
import Signal (Signal, foldp, (<~), (~))
import Signal
import Color (..)
import Graphics.Collage (..)
import Graphics.Element (..)
import Touch
import Window
import Keyboard

-- Custom modules
import Models (..)

--
-- Implemented models
--
delta: Signal Time
delta = fps 60

dir: Signal { x: Int, y: Int }
dir = (\a -> a) <~ Keyboard.arrows

enter: Signal Bool
enter = (\a -> a) <~ Keyboard.enter

escape: Signal Bool
escape = (\a -> a) <~ Keyboard.isDown 27

input: Signal Input
input = (Input <~ dir ~ enter ~ escape ~ delta)

cat: Cat
cat = { x = 0, y = 0, w = 400, h = 400, vx = 0, vy = 0 }

people: People
people = { x = 0, y = 0, w = 10, h = 10, mood = Tender, emotionBar = [Good, Good, Bad] }

game: Game
game = {
  cat = cat,
  people = [people],
  state = NewDay,
  time = 0.0 }

screen: Screen
screen = {
  state = Menu,
  game = game }

--
-- Update
--
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
walkCat { dir } cat = { cat |
  vx <-
    if | dir.x < 0 -> -0.5
       | dir.x > 0 ->  0.5
       | True      ->  0.0 }

-- Handle cat's physics (x, y)
physicsCat: Input -> Cat -> Cat
physicsCat { delta } cat = { cat |
  x <- cat.x + delta * cat.vx,
  y <- max 0 (cat.y + delta * cat.vy) }

stepGame: Input -> Game -> Game
stepGame ({ dir, delta } as input) game =
  let
    cat' = game.cat |> walkCat input |> physicsCat input
  in
  { game |
    time <- game.time + (inSeconds delta),
    cat <- cat' }

--
-- View
--
drawCat: Cat -> Color -> Form
drawCat cat color = toForm (image cat.w cat.h "assets/cat.gif")

displayMenu (w, h) =
  collage w h [
    toForm (image 1024 800 "assets/menu-background.png")
  ]

displayGame (w, h) ({cat, people, state, time} as game) =
  container w h middle
    (collage 1024 800 [
      filled green (rect (toFloat 1024) (toFloat 800)),
      move (cat.x, cat.y) (drawCat cat red)
    ])

display (w, h) ({state, game} as screen) = case state of
  Menu -> displayMenu (w, h)
  Play -> displayGame (w, h) game

--
-- Boostrap!
--
main = display <~ (Window.dimensions) ~ (foldp stepScreen screen input)
