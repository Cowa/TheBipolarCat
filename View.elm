module View where

import Color (..)
import Graphics.Collage (..)
import Graphics.Element (..)

-- Game module
import Models (..)

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

displayPlaying: (Int, Int) -> Game -> Element
displayPlaying (w, h) ({cat, people, state, time} as game) =
  collage w h [
    filled bgColor (rect (toFloat w) (toFloat h)),
    scale 0.5 (move (cat.x, cat.y) (drawCat cat red))
  ]

displayNewDay: (Int, Int) -> Game -> Element
displayNewDay (w, h) ({cat, people, state, time} as game) =
  collage w h [
    filled bgColor (rect (toFloat w) (toFloat h)),
    toForm (image w h "assets/newspaper/skeleton.png")
  ]

displayGame: (Int, Int) -> Game -> Element
displayGame (w, h) ({cat, people, state, time} as game) =
  let (w', h') = (1024, 800) in
  container w h middle
    (case state of
      NewDay  -> displayNewDay  (w', h') game
      Playing -> displayPlaying (w', h') game
      EndDay  -> displayNewDay  (w', h') game
      End     -> displayNewDay  (w', h') game
      Pause   -> displayNewDay  (w', h') game
    )

display: (Int, Int) -> Screen -> Element
display (w, h) ({state, game} as screen) = case state of
  Menu -> displayMenu (w, h)
  Play -> displayGame (w, h) game
