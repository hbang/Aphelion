# 1.0b1
Very very very very beta build. Mostly just want feedback on whether authentication, timelines and links work. If the app crashes while loading or scrolling the timeline, please tell me the url to the tweet.

Known issues:
• Can't send tweets.
• Tapping cancel after tapping tweet crashes.
• iPad UI is probably really really broken.

# 1.0b2
• Completely reimplements OAuth support. Should fix some issues.
• Fixes crash when tapping Send, followed by Cancel.
• Fixes issues with the iPad UI.
• Fixes search tab glitches/crashes.
• Fixes TestFlight not sending back device UDID alongside crash logs.

Known issues:
• Messages, Profile, Search, Tweet Details are empty.
• Can't send tweets.
• Toolbar buttons above the tweet composer keyboard don't work.
• iPad: Sidebar buttons don't work.
• iPad: Tapping tweets/avatars makes it show in the same column instead of a new one.

# 1.0b3
I realised I suck at changelogs. (Thanks insanj.) Let's fix that.

• You wanted to send tweets? Well, you'll need to wait a bit longer. But we're getting closer! (aka, made the character counter actually count)
• Fixes those tweets that would cause a crash. Most of them, anyway. Also, I can't believe I didn't realise the solution for a month.
• Although it doesn't achieve much yet, tapping usernames and tweet URLs now opens it in-app.
• Ok, no bueno with the TestFlight UDID thing. Just going to use your device name instead.

Known issues:
• Not implemented yet: Messages, Profile, Search, Tweet Details.
• Account switcher doesn't live up to its name.
• Needs more awesome.

# 1.0b4
Bugs. Bugs everywhere.

• Fixes crashing tweets for real this time.
• Support pic.twitter.com links. (They're kinda weird.)
• Seeing your own avatar probably isn't all that important, but I fixed those bugs that ate your avatar (bugs do get hungry)
• Probably a good idea if I let you scroll in the tweet composer.

Known issues:
• Not implemented yet: Messages, Profile, Search, Tweet Details.
• Account switcher still doesn't live up to its name.
• Needs more awesome.

# 1.0b5
Big leaps ahead. "Only HASHBANG could do this." https://youtu.be/A_rjrFTGKpM

• Put down your guns, you can now tweet from Aphelion!
• Very colorful update, be sure to check out the themes under the settings tab.
• To fill in tab bar icons or to enlarge the outline, that is the question. I went with the former.
• Added some blurs here and there to make things look cool. For something that's all over iOS 7, blurring is insanely hard.
• Fixes logging in not working unless you tap "Add All". I think.
• Reimagined iPad paradigm. Less like old Twitter for iPad, more like TweetDeck.
• Twitter thought it was sane for 20 tweets to be returned by default on your timelines, but kirb thinks 200 is better.
• Adds support for SSL pinning, so you know you're connecting to Twitter and only Twitter. (Sorry, doesn't stop the NSA.)
• Don't worry, I added the awesome I kept promising.
• More bullet points in the changelog.

Known issues:
• Switching themes requires a restart to actually look good.
• Some themes might look pretty bad; let me know if your favorite does.
• May not be enough awesome themes. Again let me know if you want any added.
• Still not implemented yet: Messages, Profile, Search, Tweet Details.
• Account switcher continues to not live up to its name.

# 1.0b6
• Fixes errors while logging into the app. Sorry!
• Replaced the themes with ones designed to match the iPhone 5s and iPhone 5c colors. If you have a 5s/5c, let me know if your color doesn't fit in well.
• Tab bar icons: two pixels bigger, two pixels more awesome. Also using standard iOS 7 icons (or very close ones). You'll never look at Tweetbot 3's tab bar the same again.
• Improves the login experience; all you have to do now is tap a button.
• Added some memory management that my memory managed to forget.
• Profiles: finally implemented! Be sure to set your background color to something awesome on the Twitter website if you get the standard light blue on yours.
• Fixes status bar not becoming white if the theme is dark.
• Supports a ton of fonts, including some downloadable ones. Yeah, there's even our all-time favorite, Comic Sans.
• Avatars are more efficiently cached, and are retina. Kinda. Half-retina.

Known issues:
• You'll get 403 errors after signing in. Just relaunch the app and it'll work.
• There's no differentiation between the day and night theme yet.
• Switching themes may still require a restart for some things, and old tweets' colors may not change at all.
• Profiles probably look really really really bad. Really. Don't worry, I've got a designer.
• Tab bar looks bad. Its days are numbered.
• There's no progress indication when you download a font.
• Still not implemented yet: Messages, Search, Tweet Details.
• Will the account switcher ever live up to its name?!

# 1.0b6a
• Fixes some really weird random crashes.
• Now compiled for arm64 (in English: more efficient on iPhone 5s and iPad Air)

See the 1.0b6 changelog for the rest of the new features and known issues in this beta.

# 1.0b7
It's been a while! So long that when I started writing this I forgot most of the changes I made...

(Please note that, by installing this beta and any future betas, you accept to be under a nondisclosure agreement. I don't do lawyer-ish stuff so I don't have a book of legalese for you to not read, but just take my word for it, Really Bad Things™ will happen if you share infomation/screenshots of features added in this or future betas with non-beta testers.)

Ok, boring stuff over, now the changelog.

• The important one: SSL pinning has been disabled for now because quite frankly it makes my brain hurt. In other words, Twitter updating a certificate won't break the app again.
• Profile headers redesigned. It's kinda like Tweetbot 3, but I only realised this half way through implementing it.
• Had to write my own link touch handling system, which still isn't perfect... But all that matters is that now tapping and dragging off of a link won't cause it to be opened, among other really weird quirks in Apple's implementation.
• Sort-of supports 3rd-party browsers. If you have Chrome, it'll pick it by default for now and give you that fancy back arrow in its toolbar. Settings page coming.
• Fixes tapping of usernames mentioned in a tweet leading to nothingness.
• Updated some UI stuff that I didn't go into detail about in the corresponding git commit message for some reason.
• Fixes avatars being downloaded on the main thread (plain English: freezes while scrolling the timeline)
• Removes that "please restart Aphelion" alert that Apple would scould me for leaving in the final release.
• Speaking of themes, tweets finally properly change their colors when you change themes. I'm probably stressing about this minor, almost unimportant feature a bit too much.
• Are you sick of these bullet points yet? Are you even reading them? Just tap install already!
• Tapping and holding a tweet now reveals an activity sheet that doesn't do anything but dismiss yet. The very same one that I painfully spent forever trying to reproduce the UI of Apple's very limited built in one.
• What's a Twitter client without automatically updating timestamps? (Yes, I just called Twitter's own apps not Twitter clients.)
• Fix crashing when changing font sizes in Settings.
• Performance improvements, at least I think they are.
• Added pretty blur effect behind account switcher.
• Includes another 38 days worth of awesome.

This is still very much the beginning of what Aphelion is to ultimately become.

Known issues:
• You'll get 403 errors after signing in. Just relaunch the app and it'll work.
• There's no differentiation between the day and night theme yet.
• Profile colors can clash.
• Tweet tap-and-hold activity sheet doesn't do much else than let you cancel it. And admire my hard work.
• Tab bar looks bad. Its days are numbered.
• There's no progress indication when you download a font.
• Stilllllllll not implemented yet: Messages, Search, Tweet Details.
• Will the account switcher ever live up to its name?! Chickenfriez says we'll find out on the next episode of Dragon Ball Z! *insert theme song*
