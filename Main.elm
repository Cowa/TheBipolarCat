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
    if | dir.x < 0 -> -0.20
       | dir.x > 0 ->  0.20
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
bgColor: Color
bgColor = rgb 133 117 102

drawCat: Cat -> Color -> Form
drawCat cat color = toForm (image cat.w cat.h "assets/cat/catStanding.gif")

displayMenu (w, h) =
  collage w h [
    filled bgColor (rect (toFloat 1024) (toFloat 800)),
    toForm (image 1024 800 "assets/menu/bg.png"),
    move (10, 136) (toForm (image 144 200 "assets/cat/catStanding.gif"))
  ]

displayGame: (Int, Int) -> Game -> Element
displayGame (w, h) ({cat, people, state, time} as game) =
  container w h middle
    (collage 1024 800 [
      filled bgColor (rect (toFloat 1024) (toFloat 800)),
      scale 0.5 (move (cat.x, cat.y) (drawCat cat red))
    ])

display: (Int, Int) -> Screen -> Element
display (w, h) ({state, game} as screen) = case state of
  Menu -> displayMenu (w, h)
  Play -> displayGame (w, h) game

--
-- Boostrap!
--
main = display <~ (Window.dimensions) ~ (foldp stepScreen screen input)
