module View where

import Color (..)
import Debug
import Signal
import Signal ((<~))
import List
import List (map, filter, append, map2, length)
import Text
import Text (..)
import Graphics.Input (..)
import Graphics.Collage (..)
import Graphics.Element (..)

-- Game module
import Utils (..)
import Input (..)
import Models (..)

--
-- Some stuff
--
bgColor: Color
bgColor = rgb 133 117 102

nightColor: Color
nightColor = rgb 56 56 56

--
-- Screen
--

-- Display the whole screen (based on the screen state)
display: (Int, Int) -> Screen -> Element
display (w, h) ({ state, game } as screen) =
  collage w h [
    filled black (rect (toFloat w) (toFloat h)),
    (case state of
      Menu -> displayMenu (w, h)
      Play -> displayGame (w, h) game) |> toForm
  ]
--
-- Menu
--

displayMenu: (Int, Int) -> Element
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
      EndDay  -> displayEndDay  (w', h') game
      End     -> displayEnd     (w', h') game
      Pause   -> displayNewDay  (w', h') game
    )

-- Display game in playing state (when you can move around and interact)
displayPlaying: (Int, Int) -> Game -> Element
displayPlaying (w, h) ({ cat, people, state, time } as game) =
  collage w h [
    filled lightBlue (rect (toFloat w) (toFloat h)),
    -- Sun
    filled yellow (circle 50) |> move (-500  + time * 16, 330),
    -- Moon
    filled grey (circle 50)  |> move (-1600 + time * 16, 330),
    toForm (image w h "assets/scene/background.png"),
    toForm (image w h "assets/scene/mainPath.png"),
    toForm (image w h "assets/scene/housesPath.png"),
    toForm (image w h "assets/scene/houses.png"),
    toForm (image w h "assets/scene/trees.png"),
    people |> drawPeople (w, h),
    drawEmotionBars (w, h) cat people,
    cat
      |> drawCat (w, h)
      |> move (cat.x, cat.y)
      |> scale 0.75,
    filled nightColor (rect (toFloat w) (toFloat h)) |> alpha (nightLevel time),
    cat
      |> drawCatAction (w, h)
      |> move (cat.x + 85, cat.y + 65),
    toForm (fromString "Use ←↑→ to move "
      |> monospace |> bold |> Text.height 15 |> Text.color black |> centered) |> moveY (-340),
    toForm (fromString "Space to Meow, Ctrl to Purr"
      |> monospace |> bold |> Text.height 15 |> Text.color black |> centered) |> moveY (-360),
    toForm (fromString "Play with humans emotions until night (100s)"
      |> monospace |> bold |> Text.height 15 |> Text.color black |> centered) |> moveY (-380)
  ]

-- Give us a nice opacity level based on the time (seconds)
nightLevel: Float -> Float
nightLevel time =
  if time > 60 then
    (min (toFloat ((truncate (time) % 60)) / 30) 0.75)
  else 0
  |> Debug.watch "night"

-- This draw a cute cat... right?
drawCat: (Int, Int) -> Cat -> Form
drawCat (w, h) cat = toForm (image cat.w cat.h "assets/cat/catStanding.gif")

-- Draw cat's actions (Meoooow, purrrrr)
drawCatAction: (Int, Int) -> Cat -> Form
drawCatAction (w, h) cat =
  let action = case cat.action of
    Nope -> ""
    Meow -> "Meow"
    Purr -> "Purr"
  in
  if not (action == "") then
  collage w h [
    toForm (fromString action |> monospace |> bold |> Text.height 20 |> Text.color white |> centered)
  ] |> toForm
  else toForm (fromString action |> monospace |> bold |> Text.color white |> centered)

-- This draw people!
drawPeople: (Int, Int) -> List People -> Form
drawPeople (w, h) people =
  toForm (collage w h (map (\x -> case x.kind of
    Tie     -> toForm (image x.w x.h "assets/people/tieMan.gif") |> move (x.x, x.y)
    Citizen -> toForm (image x.w x.h "assets/people/purpleMan.gif") |> move (x.x, x.y)
  ) people))

-- Draw emotionsBar when the cat is near
drawEmotionBars: (Int, Int) -> Cat -> List People -> Form
drawEmotionBars (w, h) cat people =
  let nearPeople = (filter (\x -> nearCat cat x) people) in
  toForm (collage w h (List.append
      (map (\x -> drawEmotionBarsContent (w, h) x) nearPeople)
      (map (\x -> drawEmotionBarsBorder  x) nearPeople)))

-- Draw emotion bar border
drawEmotionBarsBorder: People -> Form
drawEmotionBarsBorder people =
  move (people.x, people.y + 90) (outlined (solid black) (rect 80 20))

-- Draw emotion bar content
drawEmotionBarsContent: (Int, Int) -> People -> Form
drawEmotionBarsContent (w, h) people =
  let
    emotionsWithIndex = List.map2 (,) people.emotionBar [0..length people.emotionBar]
    goodEmotions = filter (\(x, i) -> case x of
      Good -> True
      Bad  -> False) emotionsWithIndex
    badEmotions  = filter (\(x, i) -> case x of
      Bad  -> True
      Good -> False) emotionsWithIndex
  in
  collage w h (List.append
    (map (\(x, i) -> move ((people.x + 34) - 10 * (toFloat i), people.y + 90) (filled blue (rect 10 18))) goodEmotions)
    (map (\(x, i) -> move ((people.x + 34) - 10 * (toFloat i), people.y + 90) (filled lightRed  (rect 10 18))) badEmotions))
    |> toForm

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

-- Display game in end day state
displayEndDay: (Int, Int) -> Game -> Element
displayEndDay (w, h) ({ cat, people, state, time } as game) =
  collage w h [
    displayPlaying (w, h) { game | time <- 100 } |> toForm,
    toForm (image w h "assets/endDay/skeleton.png"),
    move (415, -345) (toForm endDayButton) |> scale 0.75
  ]

-- Display end game state (when party is over)
displayEnd: (Int, Int) -> Game -> Element
displayEnd (w, h) ({ cat, people, state, time } as game) =
  collage w h [
    filled nightColor (rect (toFloat w) (toFloat h)),
    toForm (image w h "assets/end/skeleton.png")
  ]

newDayButton: Element
newDayButton =
  customButton (Signal.send clickNewDayButton True)
    (image 225 116 "assets/newspaper/button.png")
    (image 225 116 "assets/newspaper/button_hover.png")
    (image 225 116 "assets/newspaper/button_down.png")

endDayButton: Element
endDayButton =
  customButton (Signal.send clickEndDayButton True)
    (image 225 116 "assets/newspaper/button.png")
    (image 225 116 "assets/newspaper/button_hover.png")
    (image 225 116 "assets/newspaper/button_down.png")
