{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}

import Data.Aeson (FromJSON, ToJSON, encode)
import Data.Aeson.Text (encodeToLazyText)
import GHC.Generics
import Web.Scotty
import Data.Monoid((<>))
import System.IO (readFile, writeFile, appendFile)

data Person = Person {
  name :: String,
  age :: Int
} deriving (Show, Generic)

instance ToJSON Person
instance FromJSON Person

rob = Person {
  name = "Rob",
  age = 23
}

incidentFilename :: FilePath
incidentFilename = "../data-collection/data/incidents.txt"

-- getIncidents :: FilePath -> [String]
-- getIncidents filepath = unlines (readFile filepath)

index :: ActionM ()
index = do
  html "<h2>FP-UWA Web Service</h2>"

person :: ActionM ()
person = do
  json rob

routes :: ScottyM ()
routes = do
  get "/" index
  get "/person/" person

main :: IO ()
main = do
  putStrLn "Starting Server on PORT: 3000"
  scotty 3000 routes
