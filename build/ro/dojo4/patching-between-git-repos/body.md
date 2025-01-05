(This post originally appears on Spike's [Stuff... And Things... blog](http://stuff-things.net/))

While the fame and free cars are nice, the reason I blog is to learn, or, as in this case, to help me remember things.

I work across a number of distinct Rails projects that share a common ancestry. Often a bug fix or a new feature in one needs to be ported to (some of) the others.

Because projects all live in their own repos, the changes can not be merged using Git. No, this is a job for patches. And when it comes to patching with Git, there are two posts about the process I can not live without.

When patching, three Git commands that come into play, [git format-patch](http://git-scm.com/docs/git-format-patch), [git apply](http://git-scm.com/docs/git-apply]), and the somewhat obscure [git am](http://git-scm.com/docs/git-am).

`git patch` is pretty straight forward, give a list of commits, it generates a diff in [patch format](http://en.wikipedia.org/wiki/Patch_%28Unix%29) which can then be applied by Git or by the patch command. The thing I always have to look up is the shortcut to get a patch from the last commit.

The non-shortcut way is to get the SHA of the second to last commit and pass it to format-patch. Why the second to last? The SHA represents the state of the repo after the commit is made, thus the final SHA is where we are now, and the second to last where we where before our changes.

We generate the patch thusly:

```
git log --oneline
975d4dc Auto-generated CHANGELOG.md
ca1216d Bump for validation fix
git format-patch ca1216d
0001-Auto-generated-CHANGELOG.md.patch
```

(You can also create multiple patches by using a SHA further back in the history.)

However, there's shortcut to get the second to last commit that I found log ago in this post:

[http://stackoverflow.com/questions/9396240/how-do-i-simply-create-a-patch-from-my-latest-git-commit](http://stackoverflow.com/questions/9396240/how-do-i-simply-create-a-patch-from-my-latest-git-commit) and is:

```
git format-patch HEAD^
0001-Auto-generated-CHANGELOG.md.patch
```

`HEAD^` is short for `HEAD^1`, the *^1* means the first parent of the commit, in this case commit before *HEAD*, which is, of course, the second to last commit.

Now that you have you patch you need to apply it. For that, I reach for the advice found in [https://ariejan.net/2009/10/26/how-to-create-and-apply-a-patch-with-git/](https://ariejan.net/2009/10/26/how-to-create-and-apply-a-patch-with-git/)

First you can use:

```
git apply --stat patch-file
```

to see what changes are actually in the patch. Then you can use

```
git apply --check patch-file
```

to see if it will actually work.

However, per Ariejan's article, I don't actually use `git apply` to apply the patch. Why not? Attribution.

The alternative to *apply* is `git am`, which is designed to apply patches from email(s). What makes it different is that the committer on the commit is taken from the *From* address in the patch. For patches the created by `git format-patch` this is the committer of the original code. With `git apply` you are the committer. Thus, if you use `git am`, you get a record of who wrote the code and with `git apply` a record of who applied the patch.

Which bring us to the `--signoff` option. Passed to `git am` it adds *Signed-off-by* containing the name of the person applying the patch to the `git log`.

```
git am --signoff < patch file
```

With that we get both, a commit that shows who wrote the code and who applied it to this repo.

And now maybe I'll be able to remember it!
