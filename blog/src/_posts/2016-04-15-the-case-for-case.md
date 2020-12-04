---
layout: post
title:  "The Case for Case"
date:   2016-04-14 16:24 +0200
author: Oskar Wickström
categories: programming
tags: ["haskell", "functional"]
excerpt: "Top-level pattern matching in Haskell leads to repeating the function name. Here we look at how case and LambdaCase can make your code more succinct."
---

I try to keep an eye out for quick wins that can improve my Haskell code. One
thing that annoys me in the code I have written before is the use of pattern
matching at the top level where the function name is repeated for each
pattern.

```haskell
greet :: Maybe String -> String
greet (Just "Oskar")       = "Ohai, me."
greet (Just "John Bonham") = "Wait... How is this happening?"
greet (Just someone)       = "Hi, " ++ someone ++ "."
greet Nothing              = "People of the Earth!"
```

Greet, greet, greet, greet... _*Sigh*_. Would you agree that the repetition
becomes a bit tedious? Let's put those patterns into a case expression instead.

```haskell
greet :: Maybe String -> String
greet who = case who of
  Just "Oskar"       -> "Ohai, me."
  Just "John Bonham" -> "Wait... How is this happening?"
  Just someone       -> "Hi, " ++ someone ++ "."
  Nothing            -> "People of the Earth!"
```

Much better! Notice also how the parenthesis around the Maybe pattern can be
removed.

If you want you can take this even further using the _LambdaCase_ language
extension. Either use the flag `-XLambdaCase` when compiling or add a language
pragma at the top of your module as in the following example.

```haskell
{-# LANGUAGE LambdaCase #-}
module Greetings where

greet :: Maybe String -> String
greet = \case
  Just "Oskar"       -> "Ohai, me."
  Just "John Bonham" -> "Wait... How is this happening?"
  Just someone       -> "Hi, " ++ someone ++ "."
  Nothing            -> "People of the Earth!"
```

If you want to find out more about syntax extensions you should check out the
[GHC users guide](https://downloads.haskell.org/~ghc/7.8.4/docs/html/users_guide/syntax-extns.html).
Thanks for reading. Happy pattern matching!
