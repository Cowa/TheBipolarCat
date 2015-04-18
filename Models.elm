module Models where

import Time (..)
import Signal (..)

type ScreenState = Menu | Play
type GameState = NewDay | Playing | EndDay | End | Pause

type Mood = Happy | Excited | Tender | Scared | Angry | Sad
type Emotion = Good | Bad

type alias Input = { dir: { x:Int, y: Int }, delta: Time }

type alias Cat = {
  x: Float, y: Float,
  w: Int, h: Int,
  vx: Float, vy: Float
}

type alias People = {
  x: Int, y: Int,
  w: Int, h: Int,
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
