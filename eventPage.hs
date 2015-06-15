{-# LANGUAGE JavaScriptFFI #-}
module Main where
import GHCJS.Types
import GHCJS.Foreign
import qualified GHCJS.Prim as Prim

foreign import javascript unsafe "Date.now()"
  dateNow :: IO Int
foreign import javascript safe "chrome.tabs.onActivated.addListener(function(info){$1(info.tabId)})"
  addOnActivatedListener :: JSFun (JSNumber -> IO b) -> IO ()

registerOnActivated :: (Int -> IO b) -> IO ()
registerOnActivated innerCallback = do
  -- Asynchronous callbacks seem to leak memory faster.
  -- If "NotRetain" is set, then printing produces an error
  cb' <- syncCallback1 AlwaysRetain True (outerCallback innerCallback)
  addOnActivatedListener cb'
    where
      outerCallback innerCB val = innerCB $ Prim.fromJSInt val

main :: IO ()
main = do
  time <- dateNow
  print time
  registerOnActivated (\v -> putStrLn $ "page id=" ++ (show v))
  putStrLn "The eventPage started!!"
