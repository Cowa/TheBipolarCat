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
  space: Bool,
  ctrl: Bool,
  nextDay: Bool,
  endDay: Bool,
  delta: Time }

delta: Signal Time
delta = (\a -> a / 4) <~ fps 30

touch: Signal Bool
touch = (\t -> (length t) > 1 ||
  any (\ { x, x0 } -> (x0 - x) == 0) t) <~ Touch.touches

nextDay: Signal Bool
nextDay = (\a -> a) <~ subscribe clickNewDayButton

endDay: Signal Bool
endDay = (\a -> a) <~ subscribe clickEndDayButton

clickNewDayButton: Signal.Channel Bool
clickNewDayButton = Signal.channel False

clickEndDayButton: Signal.Channel Bool
clickEndDayButton = Signal.channel False

input: Signal Input
input = (Input <~ Keyboard.arrows ~ touch ~ Keyboard.enter ~ Keyboard.isDown 27 ~ Keyboard.space ~ Keyboard.ctrl ~ nextDay ~ endDay ~ delta)
