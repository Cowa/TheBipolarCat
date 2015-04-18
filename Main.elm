import Text (asText)
import List
import Time (Time, every, second, fps, inSeconds)
import Signal (..)

--
-- Models
--
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
  state = Menu,
  game = game }

--
-- Update
--
stepGame: Input -> Game -> Game
stepGame { delta } game = { game |
  time <- game.time + (inSeconds delta),
  state <- Playing }

gameState : Signal Game
gameState = foldp stepGame game input

--
-- View
--
main = (toString >> asText) <~ gameState
