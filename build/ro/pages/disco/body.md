as i've intimated obliquely in some of my socials, i've been working at https://syntheticecho.com for over 8 months on a system i've named `disco`.

`disco` is short for **"discovery"** and it brings a unique and important aspect to **any** AI application:

##### "the social voice"

> what do you mean by that?

i mean that we have compiled a:

- currated, distilled, and augmented dataset of over a million high quality organic social conversations from around the internet
- from these we have extracted `hopes`, `fears`, `dreams`, and other goodness
- these conversations are organized into `audiences` and, to these, you can literally _ask any question_

but unlike google's gemini, which aims to inform you in a way that sells ads, or openai, which aims to inform you with _democracy_ending_ intell.  `disco` informs you with real conversations, from _real people_, and it gives the the citations for you to verify, for yourself, if you accept the line it's feeding you.

in the examples above you can also notice, and this is just for the sake of example, that one can constrain the answer given to certain criteria.  for example:

- _what did people think in 2024_?

or

- what would a cynical or _negative_ answer be to this question?

and clearly, each is constrained to an audience.   these are pre-made but, under the covers, they are arbitrary collections of subreddits, authors, message boards, etc.

> i am so lost....

see [this example of forty-two answers from `disco`](https://gist.github.com/ahoward/ae562567579a3e936d9b9bb7e4ffde88)

this small example shows:

- giving `disco` a prompt, in this case _"what keeps you up at night"_
- running this prompt by 42 disctinct audiences
- a sample of the citations used to inform each of the answers given, so you can _see for yourself_

this took about 5 minutes to run.  using `disco`, i can bring AI to bear on literally any task that should, or would be better, if informed by the social voice.

this includes, but is not limited to:

- running suveys on audiences prior to making a decision
- having specfic audiences read a proposal peice of content and give an honest review in thier own words
- examine the fears vs hopes of _science minded people_ in 2024, vs. 2025
- mock elections
- etc.

as little bit of technical background, this project was started with an ephasis on marketing but, it actually has a much, much broader applicability, not limited to politics, social issues, and product development.  any time you are using AI, or even if you aren't, and you think _what if i could know what people with think about this_ stop, **because you can**.   _apriori_.   perhaps not perfectly, but, very rapidly, you can, and should, bring millions of disparate, but real conversations to be bear on your question using the one ability AI actually has: _to reivew piles of human language and derive patterns out of it_.

`disco` isn't about getting 'the right' answer, it is about **knowing what people think the answer is**.

every entreprenuer understands the difference.

`disco` started out as an RHLF process but, since, has evolved into what amounts to two unique approaches from an IP perspetive:

- it uses a clever process to discover not _what is commonly accepted and said_ about _anything_ but, instead, is able to identify _significant clusterthe s of outliers_.   in otherwords, it helps find the conversations that are most relevant to consider.  this is _vastly_ different than most AI approaches which aim to give you vanilla, book reporish, correct, and non-controversial answers.  `disco` does the opposite: it gives you are _real_ answer, and backs it up with proof.  you be the judge.

- it uses a clever way of pre-indexing this information so reteriving it is a simple query and scales quite well

> wut?

it's ok. you aren't a developer.  or a vc.  stop reading now.

but if you are:

- please be aware that i am releasing an API, which will be single, simple endpoint, so that you can bring 'the social voice' to your RAG pipelines with about 5, maybe 3 lines of code.  not matter which AI you use.  [hmu](/contact) if you want a beta API key.  priorty on devs that are willing to share what they are doing with it

- a demo app will be out in 7-10 days

- i am working to indroduce the bluesky firehose.  goal is to be the authority on 'the real voice' when it comes to the RLHF training data set wars which are about to ensue.  crytpgraphic guarantees about authorship and all.

[reach out](/contact) if that didn't sound like gibberish ;-)

and, for good measure, [here are the audience configurations i used for this run](https://gist.github.com/ahoward/95092a816c9a3f752f9d8ec421f24be5)