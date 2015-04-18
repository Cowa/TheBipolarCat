import Text (asText)
import List
import Time (Time, every, second, fps, inSeconds)
import Signal (Signal, foldp, (<~), (~))
import Signal
import Color (..)
import Graphics.Collage (..)
import Graphics.Element (..)
import Touch
import Window

import Models (..)

--
-- Implemented models
--
input: Signal Input
input = (Input <~ fps 60)

cat: Cat
cat = {
  x = 0, y = 0, w = 10, h = 10 }

people: People
people = {
  x = 0, y = 0, w = 10, h = 10,
  mood = Tender, emotionBar = [Good, Good, Bad] }

game: Game
game = {
  cat = cat,
  people = [people],
  state = NewDay,
  time = 0.0 }

gameWrapper: GameWrapper
gameWrapper = {
  state = Play,
  game = game }

--
-- Update
--
stepGameWrapper: Input -> GameWrapper -> GameWrapper
stepGameWrapper input ({ state, game } as gameWrapper) = case state of
  Menu -> gameWrapper
  Credits -> gameWrapper
  Play -> { gameWrapper |
    game <- stepGame input game }



stepGame: Input -> Game -> Game
stepGame { delta } game = { game |
  time <- game.time + (inSeconds delta),
  state <- Playing }



gameWrapperState: Signal GameWrapper
gameWrapperState = foldp stepGameWrapper gameWrapper input

--
-- View
--
box color = filled color (square 40)

drawCat: Cat -> Color -> Form
drawCat cat color = filled color (rect (toFloat cat.w) (toFloat cat.h))

display (w, h) {state, game} = case state of
  Menu -> image 150 250 "assets/menu.png"
  Credits -> image 150 250 "assets/menu.png"
  Play -> collage w h
    [ drawCat game.cat red
    , move (100, game.time * 10) (drawCat game.cat blue)
    ]

--
-- Boostrap!
--
main = display <~ Window.dimensions ~ gameWrapperState
