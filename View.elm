module View where

import Color (..)
import Debug
import Signal
import Signal ((<~))
import Graphics.Input (..)
import Graphics.Collage (..)
import Graphics.Element (..)

-- Game module
import Input (..)
import Models (..)

--
-- Some stuff
--
bgColor: Color
bgColor = rgb 133 117 102

bgLight: Color
bgLight = rgb 230 230 230

--
-- Screen
--

-- Display the whole screen (based on the screen state)
display: (Int, Int) -> Screen -> Element
display (w, h) ({ state, game } as screen) = case state of
  Menu -> displayMenu (w, h)
  Play -> displayGame (w, h) game

--
-- Menu
--

displayMenu (w, h) =
  collage w h [
    filled bgColor (rect (toFloat 1024) (toFloat 800)),
    toForm (image 1024 800 "assets/menu/bg.png"),
    move (30, -300)(toForm (image 307 27 "assets/menu/pressEnter.gif")),
    move (20, 140) (toForm (image 144 200 "assets/cat/catStanding.gif"))
  ]

--
-- Game
--

-- Display game by delegating the work (based on the game state)
displayGame: (Int, Int) -> Game -> Element
displayGame (w, h) ({ cat, people, state, time } as game) =
  let (w', h') = (1024, 800) in
  container w h middle
    (case state of
      NewDay  -> displayNewDay  (w', h') game
      Playing -> displayPlaying (w', h') game
      EndDay  -> displayNewDay  (w', h') game
      End     -> displayNewDay  (w', h') game
      Pause   -> displayNewDay  (w', h') game
    )

-- Display game in playing state (when you can move around and interact)
displayPlaying: (Int, Int) -> Game -> Element
displayPlaying (w, h) ({ cat, people, state, time } as game) =
  collage w h [
    filled lightBlue (rect (toFloat w) (toFloat h)),
    toForm (image w h "assets/scene/background.png"),
    toForm (image w h "assets/scene/mainPath.png"),
    toForm (image w h "assets/scene/housesPath.png"),
    toForm (image w h "assets/scene/houses.png"),
    toForm (image w h "assets/scene/trees.png"),
    cat
      |> drawCat
      |> move (cat.x, cat.y)
      |> scale 0.5
  ]

-- This draw a cute cat... right?
drawCat: Cat -> Form
drawCat cat = toForm (image cat.w cat.h "assets/cat/catStanding.gif")

-- Display game in new day state (when you see the daily newspaper)
displayNewDay: (Int, Int) -> Game -> Element
displayNewDay (w, h) ({ cat, people, state, time } as game) =
  collage w h [
    filled bgColor (rect (toFloat w) (toFloat h)),
    toForm (image w h "assets/newspaper/skeleton.png"),
    toForm (image w h "assets/newspaper/day1Label.png"),
    toForm (image w h "assets/newspaper/day1HeadLines.png"),
    move (415, -345) (toForm newDayButton) |> scale 0.75
  ]

newDayButton: Element
newDayButton =
  customButton (Signal.send clickNewDayButton True)
    (image 225 116 "assets/newspaper/button.png")
    (image 225 116 "assets/newspaper/button_hover.png")
    (image 225 116 "assets/newspaper/button_down.png")
