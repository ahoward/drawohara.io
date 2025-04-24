We've been utilizing [Can.js](http://canjs.us/) lately for some mobile work on tablets. It's a lightweight frontend JS library for building web applications and we've been using it in Phonegap to create native feeling interfaces. The effort to learn and apply the framework seems to have been successful so we wanted to share our experience.

## Pros

Can.js has many qualities that developers have come to know and love over the years. To list them:

* Lightweight -- The framework doesn't impose at all. In fact, there seems to be very little convention expressed by the developers.
* Concise -- Using Can objects is a quick and clean affair and they tend to provide nice, declarative interfaces for things like event binding and routing.
* Fast -- Can.js touts itself as being fast. We didn't run our own benchmarks, but haven't noticed anything to the contrary.
* Flexible -- Since the framework doesn't express or imply many conventions, code organization and usage is very much up to us, the developer.
* Composable -- Can comes with a handy base object called `Can.Construct` that supports things like static as well as prototype properties, constructors, and inheritance. This is useful for defining your own application or domain specific objects in a consistent manner.

## Annoyances

I was tempted to call this list a list of "cons", but it didn't seem appropriate as they are more so annoyances than cons.

* Documentation -- It seems thorough at first glance, but I found the text and examples to be not as helpful as they could be. I think an increase of the diversity of the examples would be an immediate win.
* No suggested structure -- This was also mentioned above as a pro. We invested a significant amount of time coming up with what seemed like boilerplate code to start a rich application. I don't believe this belongs in the framework itself, but examples of different methodoligies could help.
* Lack of higher-level abstractions -- Most of the Can objects provided are fairly low-level from an application standpoint. A lot of the investment mentioned in the previous bullet point was used to create some useful base objects for different purposes to bind together Can's in different ways. This included things like an application class to attach to `window` and represent/contain some stateful concepts. Also, we created a base object to represent page-level controllers as opposed to "widget"-level controllers.

## Conclusion

We wholeheartedly recommend giving Can.js a try. It has a lot more going on that isn't even covered here such as how it helps to prevent memory leaks. Feel free to email ryan@dojo4.com with any questions you have.