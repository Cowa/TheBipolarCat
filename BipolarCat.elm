import Window
import Signal (foldp, (<~), (~))

-- Game modules
import Input (input)
import Models (screen)
import Step (stepScreen)
import View (display)

--
-- Boostrap!
--
main = display <~ (Window.dimensions) ~ (foldp stepScreen screen input)
