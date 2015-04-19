module Utils where

import Models (..)

-- Check if a cat is near a people (unlock interaction!)
nearCat: Cat -> People -> Bool
nearCat cat people =
  sqrt ((people.x - cat.x)^2 + (people.y - cat.y)^2) < 175
