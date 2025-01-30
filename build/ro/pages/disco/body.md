as i’ve hinted on some of my socials, i’ve been working at [synthetic echo](https://syntheticecho.com/) on a system i’ve named **`disco`**.

`disco` stands for **"discovery"**, and it brings a unique, important, and beneficial aspect to **many** AI applications:

### **"the social voice"**

> _what do you mean by that?_

take a look at [this example =>](https://gist.github.com/ahoward/ae562567579a3e936d9b9bb7e4ffde88)

as you can probably see, `disco` is a unique system that utilizes AI and a **curated, distilled, and augmented dataset** of over a million high-quality, organic social conversations from across the internet to _bring the social voice to AI_.

from the authentic conversations, `disco` extracts people’s **hopes**, **fears**, **dreams**, and more.  then the conversations are organized into **audiences**, to which you can literally ask *any question*.

but here’s the kicker: unlike google’s gemini, which informs you in ways
optimized to sell ads.

or openAI, which informs you… for reasons we can only guess...

`disco` informs you with **real conversations from real people.**

and it gives **citations to those conversations**, so that you can guage the reality of the answers it gives _for yourself_.

`disco` does not give you some sanitized, middle-of-the-bell-curve, socially correct, book report style answer to your questions.  it gives you back answers that **real people** could, and would give.

> what would you do if you could ask your audience _anything_?

the **audiences** in this particular example were built from subreddits. [you can see the configurations i used here.](https://gist.github.com/ahoward/95092a816c9a3f752f9d8ec421f24be5) other sources are possible, of course, including thousands of message boards, threads, and, coming soon, bluesky.

> _i’m lost..._

let’s clarify. [in the example ==>>](https://gist.github.com/ahoward/ae562567579a3e936d9b9bb7e4ffde88):

* we gave `disco` the prompt: *"what keeps you up at night?"*.
* it ran this prompt by **42 distinct audiences**.
* for each audience, it provided a sample of citations, alongside the answer, so you can verify the sources yourself.
* the year, and sentiment, was selected in a randomized way to show 'answers based on "negative" 2024 commentary', etc.

this entire process took about five minutes to run.

so, this is how using `disco`, you can leverage AI to inform any task that could benefit from contextualizing the subject of inquiry in **the authentic social voice**.

applications include:

* running dynamic real-time surveys on audiences before making decisions.
* having specific audiences review proposals or content and give honest feedback, in their own words.
* mocking elections.
* understanding unfiltered thoughts about your company, practice, or brand.
* and much, much more.

### **why `disco`?**

this project started with a focus on sales and marketing but has evolved towards much broader applicability: politics, social issues, product development... you name it.

anytime you think, *"what would people think about this?"* you can stop wondering: with `disco`, you can find out **now**.

`disco` isn’t about getting "the right" answer; it’s about getting **the answer real humans would actually give**.

every entrepreneur understands the difference between these two styles of answers and, the good ones want the unbiased truth.

with some marketing tools, you could discover, that people really want 'dark mode' or 'a bookmark feature' in the app you're building.  with `disco`, you might discover that no one even wants another app - the one question your research company forgot to ask.

### **how `disco` works**

from an ip perspective, `disco` has several unique strengths:

1. it doesn’t just show you what’s commonly accepted or said. instead, it identifies **clusters of outliers**: the conversations most relevant to consider. while other AI approaches aim for safe, generic answers, `disco` delivers **real answers backed by evidence.**

2. it uses an innovative pre-indexing system, making information retrieval fast and scalable.

> _wut?_

it’s fine if this sounds technical\! if you’re not a developer or vc, you can stop reading here.

but if you are:

* we’re releasing an API with a single, simple endpoint. you’ll be able to add "the social voice" to your rag pipelines with about 3–5 lines of code, no matter what AI you use. [contact me](/contact) for a beta API key—priority goes to devs willing to share their use cases.  
* a demo app will be out in 7–10 days.  
* we’re working to integrate the bluesky firehose, with the goal of becoming the authority on "the real voice" for RLHF training data wars. cryptographic guarantees of authorship included ;-).

[reach out](/contact) if this sounds like your kind of thing.

and for the curious, [here’s the audience configuration used in this example.](https://gist.github.com/ahoward/95093a816c9a3f752f9d8ec421f24be5)
