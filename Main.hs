-- (c) 2013, Chris Hodapp
-- 2013-11-17, this is a rewriting of a buzzword generator I wrote in Python
-- way back when.
module Main where

import qualified Data.Map as Map
import qualified Data.List as List
import System.Random

-- 'State' just represents a state within this FSM.
data State = Start | End |
             Adj1 | Adj2 | Noun | Intro | Prefix | Linker | Adverb
           deriving (Show, Ord, Eq);

data Transition = Transition {
  transitionStart :: State,   -- Starting state of this transition
  transitionNext :: [State],  -- Where a state may transition to
  transitionWords :: [String] -- What words a state may emit
  -- TODO: Make transitionWords into something more generic (e.g. a function
  -- producing its output, or encoding a side-effect)
  } deriving (Show);
-- TODO: Somehow enforce non-emptiness in transitionNext. (Either that, or
-- handle it somehow, like treating it as a terminal state rather than having
-- a sentinel (End) for this)

-- stateTuple: Create a transition from, respectively, start state, next states,
-- and words; return a tuple mapping a start state to its associated transition,
-- meant for adding to a map.
-- (This is mostly just syntactic sugar to avoid repetition.)
stateTuple :: State -> [State] -> [String] -> (State, Transition)
stateTuple start next words = (start, Transition start next words)

type Fsm = Map.Map State Transition
buzzwordFsm :: Fsm
buzzwordFsm = Map.fromList(
  [stateTuple Start [Intro, Adj1, Adj2, Adverb] [],
   stateTuple End [] [],
   stateTuple Intro [Adj1, Adj2, Prefix, Noun] ["focusing on", "integrating with",
                                                "improving", "approaching",
                                                "revising", "updating corporate policy to",
                                                "ensuring", "introducing", "managing",
                                                "accelerating", "maximizing profit with",
                                                "maximizing", "increasing", "developing",
                                                "pushing the envelope of", "envisioning",
                                                "optimizing", "examining a novel new method for",
                                                "ushering in the era of", "synergizing with",
                                                "reviving", "pioneering", "crowd-sourcing",
                                                "supporting", "consolidating", "strengthening",
                                                "disrupting the", "globalizing",
                                                "moving beyond", "leaping beyond",
                                                "stimulating"],
   stateTuple Adj1 [Adj2, Noun, Prefix] ["integrated", "total", "systematized", "parallel",
                           "functional", "responsive", "optional", "synchronized",
                           "compatible", "balanced", "flexible", "complete",
                           "unified", "diverse", "enterprise", "adaptive",
                           "synergized", "high-performance", "high-speed",
                           "improved", "new", "accelerated", "innovative",
                           "next-generation", "cyber", "enhanced", "efficient",
                           "guaranteed", "revised", "strategic", "reliable",
                           "revolutionary", "secure", "dynamic", "connected",
                           "mobile", "portable", "updated", "independent",
                           "fundamental", "social", "cloud", "quantitative",
                           "media-driven", "agile", "dynamic", "result-oriented",
                           "pragmatic", "pragmatic", "robust", "disruptive",
                           "competitive", "optimal", "web-scale", "global",
                           "international", "localized"],
   stateTuple Adj2 [Noun, Prefix] ["management", "organizational", "monitored",
                                   "reciprocal", "digital", "logistical",
                                   "transitional", "incremental", "third-generation",
                                   "policy", "corporate", "statistical", "financial",
                                   "fiscal", "client", "client-focused", "customer-focused",
                                   "forward-thinking", "quality", "connectivity",
                                   "intelligence", "asset", "legacy"],
-- N.B. Next state had ADV_OR_I in the Python, but could make this transition
-- only once; the point here was to separate things with colon.
   stateTuple Noun [Linker, End] ["options", "flexibility", "capability",
                                  "mobility", "programming", "concept",
                                  "time-phase", "projection", "hardware",
                                  "contingency", "software", "modeling",
                                  "simulation", "innovation", "improvement",
                                  "platform", "rendering", "development",
                                  "skills", "connectivity", "consolidation",
                                  "vision", "synergy", "media",
                                  "team", "agility", "paradigm", "allocation",
                                  "externalities", "mind-share"],
   stateTuple Prefix [Noun] ["e-commerce", "Internet", "e-business", "profit",
                             "financial", "marketing", "web", "processing",
                             "decision", "support", "media", "communication",
                             "information", "data", "economic", "logic",
                             "creativity", "relations", "mindset", "relations",
                             "morale", "customer", "client"],
   stateTuple Linker [Prefix, Adj2, Adj1] ["through application of", "by applying",
                                           "using", "by utilizing the power of",
                                           "through the power of", "through",
                                           "in conjunction with",
                                           "by pushing the envelope of",
                                           "by leveraging",
                                           "through integration of the technologies of",
                                           "by breaking the barrier of",
                                           "with the leap ahead to", "leveraging",
                                           "by opening the doors of", "with the advantage of",
                                           "from the platform of",
                                           "by bringing a new generation of",
                                           "by consolidating", "by disrupting"],
   stateTuple Adverb [Intro, Adj1] ["boldly", "innovatively", "creatively",
                                    "efficiently", "solidly", "disruptively",
                                    "dynamically", "fluidly", "progressively",
                                    "conservatively", "incrementally",
                                    "pragmatically", "collaboratively",
                                    "intelligently", "elastically",
                                    "proactively", "robustly", "competitively",
                                    "strategically", "proactively"]
   ])

-- randomElement: Given a generator and a list (which must be finite, unless
-- you want this function to never return), this returns a random element out
-- of the list (or Nothing if said list was empty) and a new random number
-- generator.
-- (I'm almost certain a method of this sort has to be in the API already
-- somewhere, but I wrote it myself anyway.)
randomElement :: RandomGen g => [a] -> g -> (Maybe a, g)
randomElement [] gen = (Nothing, gen)
randomElement l gen = (Just (l !! idx), newGen)
  where (idx, newGen) = randomR (0, length l - 1) gen

-- runFsm: Pass starting state, Fsm to govern transitions, and RandomGen;
-- return a list of tuples, each tuple containing a state and a string which
-- that state emitted.  Note that this list may be infinite!
runFsm :: RandomGen g => State -> Fsm -> g -> [(State, String)]
runFsm End _ _ = []
runFsm start fsm gen = case stateMaybe of
  -- 'Nothing' indicates that the list of next states was empty, thus terminal:
  Nothing -> []
  Just state -> (state, emit):runFsm state fsm newGen
  where trans = fsm Map.! start
        (stateMaybe, gen2) = (randomElement (transitionNext trans) gen)
        (emitMaybe, newGen) = (randomElement (transitionWords trans) gen2)
        emit = case emitMaybe of
          Nothing -> ""
          Just str -> str
          -- there must be an easier way than this...

-- Questions for pondering:
-- (2) How can I make use of the Random monad? Starting from
-- http://hackage.haskell.org/package/MonadRandom-0.1.8/docs/Control-Monad-Random.html
-- but still a bit confused
-- (3) How can I make Transition more generic in terms of state behavior?  That
-- is, right now it is tied to FSMs which emit words (or strings) when in that
-- state.  Why now instead parametrize the type over something else?
-- (4) Should I generalize State a little more?  I could perhaps make it a
-- typeclass.  It seems silly to have BuzzwordFsm decoupled from the algorithm,
-- but the states themselves are tied to a specific type that is fixed at
-- compile time.

main :: IO()
main = getStdGen >>=
       (putStrLn . List.intercalate " " . map snd . runFsm Start buzzwordFsm)
