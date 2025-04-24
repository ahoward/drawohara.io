# Today's Moment of Zen

Somehow, all the articles from [James Mickens](http://research.microsoft.com/en-us/people/mickens/) end up in [my twitter stream](https://twitter.com/copiousfreetime). It is a thoroughly enjoyable time when it does.

This edition, [To Wash It All Away](https://www.usenix.org/system/files/1403_02-08_mickens.pdf), does not disappoint.

The nugget I learned today about JavaScript from James.

> “\r\n\t” == false

WTF? I had to try it out.

```bash

    % node
    > "\r\n\t" == false
    true

```

And of course, the explanation from James:

> Here’s why: the browser detects that the two operands have different types, so it converts false to 0 and retries the comparison. The operands still have different types (string and number), so the browser coerces “\r\n\t” into the number 0, because somehow, a non-zero number of characters is equal to 0. Voila—0 equals 0! AWESOME. That explanation was like the plot to Inception, but the implanted idea was “the correctness of your program has been coerced to false.”

Really, I just had to share.

P.S. [WAT](https://www.destroyallsoftware.com/talks/wat)

