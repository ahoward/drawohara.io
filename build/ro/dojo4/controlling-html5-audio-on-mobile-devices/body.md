(This originally appeared on Spike's [Stuff… And Things…](http://stuff-things.net/) blog)

HTML5 `<audio>` tags is pretty straight forward. Given:

```html
<audio id="player"></audio>
```

this bit of Javascript:

```javascript
player = document.getElementById('player');
player.src = 'some-audio-file-url';
player.play()
```

will start playing whatever the src points to. (Pro-tip: If you are using jQuery, you need get the actual HTML element with `player = $('#player')[0]` or `player = $('#player').get(0)`)

However, if the user is on either an iOS or Android mobile device, the above won't actually play anything. Neither of those OSs allow web audio (or video) to start streaming without user interaction. The rational is that streaming data over the cellular network can cost money and shouldn't happen without the user actually hitting a button.

All well and good, but what if you want to play a sound in response to an event, say beep the browser once per minute:

```javascript
player = document.getElementById('player');
player.src = 'beep-url';
beeper = setInterval(function() { player.play(); } ,1000 * 60);
```

This will work fine in desktop browsers, but on mobile the call to `play()` will do nothing.

Fortunately, there are three things that make the work-around simple:

1. The user only has to push play once per audio element.
2. "Pushing play" can also mean triggering `play()` through a click event.
3. Playing an audio element with no source is a legal no-op.

In short, all we need is for the user to click a button that plays an empty audio element to gain control of it:

```html
<audio id="player"></audio>
<button id="ok">OK to beep</button>
```

```javascript
// Presumes jQuery
$("#ok").click(function() {
	player = document.getElementById('player');
	$( this ).slideUp();
	player.play(); // Play the empty element to get control
	player.src = 'beep-url'; // Set the real audio source
	beeper = setInterval(function() { player.play(); } ,1000 * 60);
});
```

The click can be anything, a more subtle version would be attaching it to the *close* button an instruction modal at the start of a game.

This technique probably blurs the line a bit between the spirit and the letter of the law, but it gets the job done and allows you to create a consistent experience for both desktop and mobile users.