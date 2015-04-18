module Models where

import Time (..)
import Signal (..)
import Keyboard

type ScreenState = Menu | Play
type GameState = NewDay | Playing | EndDay | End | Pause

type Mood = Happy | Excited | Tender | Scared | Angry | Sad
type Emotion = Good | Bad

type alias Cat = {
  x: Float,
  y: Float,
  w: Int,
  h: Int,
  vx: Float,
  vy: Float
}

type alias People = {
  x: Int,
  y: Int,
  w: Int,
  h: Int,
  mood: Mood,
  emotionBar: List Emotion
}

type alias Screen = {
  state: ScreenState,
  game: Game
}

type alias Game = {
  cat: Cat,
  people: List People,
  state: GameState,
  time: Float
}

cat: Cat
cat = { x = 0, y = 0, w = 144, h = 200, vx = 0, vy = 0 }

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
