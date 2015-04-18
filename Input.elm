module Input where

import Keyboard
import Time (Time, fps)
import Signal (Signal, (<~), (~))

type alias Input = { dir: { x:Int, y: Int }, enter: Bool, escape: Bool, delta: Time }

delta: Signal Time
delta = fps 20

dir: Signal { x: Int, y: Int }
dir = (\a -> a) <~ Keyboard.arrows

enter: Signal Bool
enter = (\a -> a) <~ Keyboard.enter

escape: Signal Bool
escape = (\a -> a) <~ Keyboard.isDown 27

input: Signal Input
input = (Input <~ dir ~ enter ~ escape ~ delta)
