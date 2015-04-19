module Input where

import Touch
import Keyboard
import List (length, any)
import Time (Time, fps)
import Signal
import Signal (Signal, subscribe, (<~), (~))

type alias Input = {
  dir: { x:Int, y: Int },
  touch: Bool,
  enter: Bool,
  escape: Bool,
  nextDay: Bool,
  endDay: Bool,
  delta: Time }

delta: Signal Time
delta = (\a -> a / 4) <~ fps 30

dir: Signal { x: Int, y: Int }
dir = (\a -> a) <~ Keyboard.arrows

touch: Signal Bool
touch = (\t -> (length t) > 1 ||
  any (\ { x, x0 } -> (x0 - x) == 0) t) <~ Touch.touches

enter: Signal Bool
enter = (\a -> a) <~ Keyboard.enter

escape: Signal Bool
escape = (\a -> a) <~ Keyboard.isDown 27

nextDay: Signal Bool
nextDay = (\a -> a) <~ subscribe clickNewDayButton

endDay: Signal Bool
endDay = (\a -> a) <~ subscribe clickEndDayButton

clickNewDayButton: Signal.Channel Bool
clickNewDayButton = Signal.channel False

clickEndDayButton: Signal.Channel Bool
clickEndDayButton = Signal.channel False

input: Signal Input
input = (Input <~ dir ~ touch ~ enter ~ escape ~ nextDay ~ endDay ~ delta)
