import Window
import Signal (foldp, (<~), (~))

-- Game modules
import Input (input)
import Models (screen)
import Step (stepScreen)
import View (display)

-- Go!
main = display <~ Window.dimensions ~ foldp stepScreen screen input
