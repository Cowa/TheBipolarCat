module Models where

import Time (..)
import Signal (..)

type GameWrapperState = Menu | Credits | Play
type GameState = NewDay | Playing | EndDay | End | Pause

type Mood = Happy | Excited | Tender | Scared | Angry | Sad
type Emotion = Good | Bad

type alias Input = { delta: Time }

type alias Cat = {
  x: Int, y: Int,
  w: Int, h: Int
}

type alias People = {
  x: Int, y: Int,
  w: Int, h: Int,
  mood: Mood,
  emotionBar: List Emotion
}

type alias GameWrapper = {
  state: GameWrapperState,
  game: Game
}

type alias Game = {
  cat: Cat,
  people: List People,
  state: GameState,
  time: Float
}
