module Re
( REOperatorType (And, Or, Repeat)
, RECharType (CommonChar, Epsilon)
, REToken (REChar, REOperator, ParenOpen, ParenClose)
, tokenize_regular_expression
, shunting_yard
) where

import qualified Data.Set as Set
import qualified Data.List as List

data REOperatorType = And | Or | Repeat deriving (Eq, Show, Ord)
data RECharType = CommonChar Char | Epsilon deriving (Eq, Ord)
data REToken = REChar RECharType | REOperator REOperatorType | ParenOpen | ParenClose deriving (Eq, Show, Ord)

instance Show RECharType where
    show c = case c of
                CommonChar common_char -> show common_char
                Epsilon -> "ε"

tokenize_regular_char :: Char -> REToken
tokenize_regular_char operator = case operator of
    '.' -> REOperator And
    '|' -> REOperator Or
    '*' -> REOperator Repeat
    '(' -> ParenOpen
    ')' -> ParenClose
    c   -> REChar (CommonChar c)

tokenize_regular_expression :: String -> [REToken]
tokenize_regular_expression xs = foldl (\tokens c -> tokens ++ [tokenize_regular_char c]) [] xs

priority :: REToken -> Int
priority token = case token of
    REOperator Or -> 0
    REOperator And -> 1
    REOperator Repeat -> 2
    ParenOpen -> 3
    ParenClose -> 3
    REChar _ -> 4

is_operator :: REToken -> Bool
is_operator token = case token of
    REOperator _ -> True
    _ -> False
    
shunting_yard :: [REToken] -> [REToken]
-- shunting_yard' x s q
-- @param x tokens
-- @param s operator stack, with top at left
-- @param q output queue, with front at left
shunting_yard x = shunting_yard' x [] [] where
    shunting_yard' [] [] q = q
    shunting_yard' [] s q =
        if head s == ParenOpen
            then error "Mismatched Parentheses"
            else shunting_yard' [] (tail s) (q ++ [head s])
    shunting_yard' xs@(x:remain) s q = case x of
        REChar c -> shunting_yard' remain s (q ++ [REChar c])
        REOperator operator ->
            if not (null s) && is_operator (head s) && priority (head s) > priority (REOperator operator)
                then shunting_yard' xs (tail s) (q ++ [head s])
                else shunting_yard' remain (REOperator operator : s) q
        ParenOpen -> shunting_yard' remain (ParenOpen : s) q
        ParenClose ->
            if not (null s) && head s /= ParenOpen
                then shunting_yard' xs (tail s) (q ++ [head s])
                else shunting_yard' remain (tail s) q