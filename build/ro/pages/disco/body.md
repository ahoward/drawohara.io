as i’ve hinted on some of my socials, i’ve been working at [synthetic echo](https://syntheticecho.com/) for over eight months on a system we’ve named **`disco`**.

`disco` stands for **"discovery"**, and it brings a unique, important aspect to **any** AI application:

### **"the social voice"**

> _what do you mean by that?_

we’ve built a unique system that utilizes AI and a **curated, distilled, and augmented dataset** of over a million high-quality, organic social conversations from across the internet to _bring the social voice to AI_.

from these conversations, we extracted insights into people’s **hopes**, **fears**, **dreams**, and more.  these conversations were then organized into **audiences**, to whom you can literally ask *any question*.

but here’s the kicker: unlike google’s gemini, which informs you in ways optimized to sell ads, or openAI, which informs you… for reasons we can only guess, `disco` informs you with **real conversations from real people.**

it even provides citations to those conversations, so you can see the variety of opinions different groups of *real* people have about your prompt. it’s not some sanitized, middle-of-the-bell-curve, socially correct answer that might be *technically smarter* but dodges honest feedback, risks, or anything that could hurt the AI provider's shot at world domination.

for instance, the **audiences** in this experiment were built from subreddits. [you can see the configurations i used here.](https://gist.github.com/ahoward/95092a816c9a3f752f9d8ec421f24be5) other sources are possible, of course, including thousands of message boards, threads, and, comign soon, bluesky.

in the examples, you’ll also notice annotations like **(year=202x)** and **(sentiment=negative)**. these demonstrate the refinements `disco` brings to *the social voice*. for example, a **(year=2024, sentiment=positive)** filter limits responses to optimistic commentary from 2024\. these refinements let you customize perspectives to fit your needs.

> _i’m lost..._

let’s clarify. [in this example](https://gist.github.com/ahoward/ae562567579a3e936d9b9bb7e4ffde88):

* we gave `disco` the prompt: *"what keeps you up at night?"*.
* it ran this prompt by **42 distinct audiences**.  
* for each audience, it provided a sample of citations, so you can verify the sources yourself.
* the responses uses a few combinations of years and sentiments, for demonstration purposes.

this process took about five minutes. using `disco`, you can leverage AI to inform any task that benefits from understanding **the social voice**.

applications include:

* running surveys on audiences before making decisions.  
* having specific audiences review proposals or content and give honest feedback in their own words.  
* comparing hopes vs. fears of different groups (e.g., science-minded people in 2024 vs. 2025).  
* mock elections.  
* and much more.

### **why `disco`?**

this project started with a focus on marketing but has much broader applicability: politics, social issues, product development—you name it. anytime you think, *"what would people think about this?"* you can stop wondering. with `disco`, you can find out—**quickly and accurately**.

`disco` isn’t about getting "the right" answer; it’s about understanding **what people really think**. every entrepreneur understands the difference.

### **how `disco` works**

from an ip perspective, `disco` has two unique strengths:

1. it doesn’t just show you what’s commonly accepted or said. instead, it identifies **clusters of outliers**—the conversations most relevant to consider. while other AI approaches aim for safe, generic answers, `disco` delivers **real answers backed by evidence.**

2. it uses an innovative pre-indexing system, making information retrieval fast and scalable.

> _wut?_

it’s fine if this sounds technical\! if you’re not a developer or vc, you can stop reading here.

but if you are:

* we’re releasing an API with a single, simple endpoint. you’ll be able to add "the social voice" to your rag pipelines with about 3–5 lines of code, no matter what AI you use. [contact me](/contact) for a beta API key—priority goes to devs willing to share their use cases.  
* a demo app will be out in 7–10 days.  
* we’re working to integrate the bluesky firehose, with the goal of becoming the authority on "the real voice" for RLHF training data wars. cryptographic guarantees of authorship included ;-).

[reach out](/contact) if this sounds like your kind of thing.

and for the curious, [here’s the audience configuration used in this example.](https://gist.github.com/ahoward/95092a816c9a3f752f9d8ec421f24be5)
