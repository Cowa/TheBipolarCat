module Models where

import Time (..)
import Signal (..)
import Keyboard

type ScreenState = Menu | Play
type GameState = NewDay | Playing | EndDay | End | Pause

type Mood = Happy | Excited | Tender | Scared | Angry | Sad
type Emotion = Good | Bad
type PeopleType = Tie | Citizen

type CatAction = Meow | Purr | Nope

type alias Cat = {
  action: CatAction,
  x: Float,
  y: Float,
  w: Int,
  h: Int,
  vx: Float,
  vy: Float
}

type alias People = {
  x: Float,
  y: Float,
  w: Int,
  h: Int,
  mood: Mood,
  kind: PeopleType,
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

type alias Button = {
  x: Int,
  y: Int,
  w: Int,
  h: Int
}

cat: Cat
cat = { action = Nope, x = -450, y = -111, w = 144, h = 200, vx = 0, vy = 0 }

tie: People
tie = { x = 270, y = -20, w = 117, h = 155, mood = Tender,
  emotionBar = [], kind = Tie }

citizen: People
citizen = { x = -170, y = -20, w = 117, h = 155, mood = Tender,
  emotionBar = [], kind = Citizen }

game: Game
game = {
  cat = cat,
  people = [tie, citizen],
  state = NewDay,
  time = 0.0 }

screen: Screen
screen = {
  state = Menu,
  game = game }
