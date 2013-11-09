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
• Reimagined iPad paradigm. Less like old Twitter for iPad, more like Tweetdeck.
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
