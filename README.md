buzzword
====

This is a business buzzword (or buzz-phrase) generator based on Markov
chains.  I wrote this in about 2013 in order to learn some Haskell
(and just didn't get around to putting it online until now), and it
was re-implementing an older Python version that I had written in
around 2004 and kept updating periodically.

That Python version came about after I saw the below quote in the
`fortune` command on Linux:

*The procedure is simple.  Think of any three-digit number, then
select the corresponding buzzword from each column.  For instance,
number 257 produces "systematized logistical projection," a phrase
that can be dropped into virtually any report with that ring of
decisive, knowledgeable authority.  "No one will have the remotest
idea of what you're talking about," says Broughton, "but the important
thing is that they're not about to admit it."* (Philip Broughton, "How
to Win at Wordsmanship")

I implemented that, and then extended it later to a finite state
machine which had the added benefit that it could make much longer,
more rambling phrases.  It may still need some updates for more recent
additions to our buzzword lexicon.
