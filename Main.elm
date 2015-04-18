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
cat = { x = 0, y = 0, w = 75, h = 75 }

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
  state = Play,
  game = game }

--
-- Update
--
stepScreen: Input -> Screen -> Screen
stepScreen input ({ state, game } as screen) = case state of
  Menu -> stepMenu input screen
  Credits -> stepCredits input screen
  Play -> { screen |
    game <- stepGame input game }

stepMenu: Input -> Screen -> Screen
stepMenu input screen = screen

stepCredits: Input -> Screen -> Screen
stepCredits input screen = screen

stepGame: Input -> Game -> Game
stepGame { delta } game = { game |
  time <- game.time + (inSeconds delta),
  state <- Playing }

--
-- View
--
drawCat: Cat -> Color -> Form
drawCat cat color = filled color (rect (toFloat cat.w) (toFloat cat.h))

displayMenu (w, h) =
  collage w h [
    toForm (image 150 250 "assets/menu.png")
  ]

displayCredits (w, h) =
  collage w h [
    toForm (image 150 250 "assets/menu.png")
  ]

displayGame (w, h) ({cat, people, state, time} as game) =
  collage w h [
    drawCat cat red,
    move (100, time * 10) (drawCat cat blue)
  ]

display (w, h) ({state, game} as screen) = case state of
  Menu -> displayMenu (w, h)
  Credits -> displayCredits (w, h)
  Play -> displayGame (w, h) game

--
-- Boostrap!
--
main = display <~ (Window.dimensions) ~ (foldp stepScreen screen input)
