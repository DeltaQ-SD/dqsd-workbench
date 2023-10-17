module DeltaQ.Workbench.Numeric
  ( module DQ
  , module WB
  , module MIO
  , createSystemRandom
  , plotDQs
  , plotCDFs
  , plotPDFs
  , nWayChoice
  )
where


import DeltaQ.Numeric.CDF as DQ
import DeltaQ.Numeric.PDF as DQ
import DeltaQ.QTA.Support as DQ
import DeltaQ.RationalProbabilityDoubleDelay as DQ
import DeltaQ.Visualisation.PlotUtils as DQ
import DeltaQ.Algebra as DQ hiding (DeltaQ)

import Control.Monad.IO.Class as MIO
import Data.List (nubBy)
import Data.Ord (Ordering(EQ), comparing)
import Graphics.Rendering.Chart.Easy as WB hiding (close)
import IHaskell.Display as WB
import IHaskell.Display.Charts as WB
import Numeric.IEEE (epsilon)
import System.Random.MWC (createSystemRandom)


-- | Plot a sequence of named ∆Q's
plotDQs :: String -- ^ plot title
        -> [(String, DeltaQ)] -- ^ list of named ∆Q's
        -> IO (Renderable ())
plotDQs t dqs = do
  gen <- createSystemRandom
  vs <- mapM (toPlottableCDF' (PI 10000 (AbsoluteDelayExtension 1)) gen . snd) dqs
  return $ p $ zip (map fst dqs) vs
  where
    p xs = toRenderable $ do
      layout_title .= t
      layout_x_axis . laxis_title .= "Delay (s)"
      layout_y_axis . laxis_title .= "Prob. Mass"
      mapM (\(a,b) -> plot $ line a [b]) xs

-- | Plot a sequence of named emphiricalCDFs
plotCDFs:: String -- ^ plot title
        -> [(String, EmpiricalCDF)] -- ^ list of emphiricalCDFs
        -> IO (Renderable ())
plotCDFs t ecdfs = return $ toRenderable $ do
  layout_title .= t
  layout_x_axis . laxis_title .= "Delay (s)"
  layout_y_axis . laxis_title .= "Prob. Mass"
  mapM (\(a,b) -> plot $ line a [[(x, f b x) | x <- points b]]) ecdfs
  where
    points cdf = enumFromThenTo lwb (lwb + step) upb
      where
        (npoints, lwb, upb, step)
          = (1000, _ecdfMin cdf, _ecdfMax cdf, (upb - lwb)/ fromIntegral npoints)

    f :: EmpiricalCDF -> Double -> Double
    f = (realToFrac .) . _ecdf

-- | Plot a sequence of empirical PDF's
plotPDFs ::  String -> [(String, EmpiricalCDF)] -> IO (Renderable ())
plotPDFs t ecdfs = return $ toRenderable $ do
  layout_title .= t
  layout_x_axis . laxis_title .= "Delay (s)"
  layout_y_axis . laxis_title .= "Prob. Density (mass / s)"
  mapM (\(a,b) -> plot $ line a [f b]) ecdfs
  where
    points cdf = filter (< upb) $ enumFromThenTo lwb (lwb + step) upb
      where
        (npoints, lwb, upb, step)
          = (1000, _ecdfMin cdf, _ecdfMax cdf, (upb - lwb)/ fromIntegral npoints)

    f :: EmpiricalCDF -> [(Double, Double)]
    f ecdf = lEdge : (body ++ rEdge)
      where
        upb = _ecdfMax ecdf
        g   = _ecdfPdf ecdf
        lEdge = (_ecdfMin ecdf, 0)
        rEdge = let u = g (upb - epsilon)
          in  [ (snd $ fst u, realToFrac $ snd u)
              , (_ecdfMax ecdf, 0) ]
        body = nubBy (((== EQ) .) . comparing fst)
               . map (\((a,_), c) -> (a, realToFrac c))
               $ [g x | x <- points ecdf]

-- | Construct an N-way weighted choice between ∆Q's
nWayChoice :: [(Rational, DeltaQ)] -> DeltaQ
nWayChoice [] = bottom
nWayChoice [(_, x)] = x
nWayChoice ((w_x,dq_x):xs) =
  ProbChoice (w_x / (w_x + sumW xs)) dq_x (nWayChoice xs)
  where
     sumW = sum . map fst
