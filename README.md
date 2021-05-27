<h1 align="center">
  <img src="https://github.com/hbang/Aphelion/raw/master/pxm/aphelion.png" width="96" height="96" alt=""><br>
  Aphelion
</h1>

This is a Twitter client app I wrote many years ago, in 2013 to 2014, for iOS 7, which ultimately was not completed or released.

I realised the source code was never open-sourced, so here’s the entire Git repo, including all commits (minus the API keys – supply those yourself in `HBAPTwitterAPISessionManager.h` and `.m`).

This is the project where I first truly “cut my teeth” on iOS development, or really, on developing a software project of more than a few hundred lines at all. Of course, being code I wrote so long ago, I wouldn’t recommend you use it as a gospel of how to write an iOS app, or Twitter client, or what have you, in any year past 2014. It might still be fun to look through for nostalgia at least, and perhaps to poke around and learn a few things from the business logic.

It’s written in pure Objective-C (Swift was yet to be announced!), uses classic memory management (MRC) rather than automatic reference counting (ARC), constructs UI in code (doesn’t use storyboards/xibs), uses autoresizing masks and -layoutSubviews rather than Auto Layout, doesn’t use launch storyboards… Yeah, needless to say, iOS dev has come a long way since 2014.

Surprisingly, after wrangling a few dependencies, it actually builds! Hard to say that about Swift codebases I wrote before Swift 5. The passage of time has ensured there are a lot of build warnings now for things that got deprecated, and issues like memory leaks that I failed to notice back then, but it’s still a crazy feeling to take code that has been untouched for over half a decade.

Fatally though, the app currently can’t do anything, because the onboarding experience depended on iOS’s Twitter integration, which was removed in iOS 11. Since the Twitter app, and other client apps such as Tweetbot and Twitterrific, would add your logged-in Twitter accounts to the iOS system Twitter account store, implementing onboarding in this way pretty much made getting logged-in effortless to the user – though implementing the odd [“reverse auth”](https://blog.twitter.com/developer/en_us/a/2012/reverse-auth-enabled-by-default.html) scheme Twitter designed for getting usable API keys out of the system Twitter accounts store was anything but effortless. Perhaps one day I’ll rewrite this to use standard OAuth login so we can see the app running in all its glory once again.

## Credits
I’m probably forgetting more of the people who were involved in the project, but these are the ones I was able to find:

* Myself, [Adam Demasi (@kirb)](https://github.com/kirb) worked on the app.
* [Alex Hamilton (@Aehmlo)](https://github.com/Aehmlo) worked on the push notifications server.
* [Andy Liang (@meteochu)](https://github.com/meteochu) originally worked on UI/UX, and during the course of the project, got interested in programming, later rewriting the entire app in Swift (not included in this repo).
* Daniel (@chickenfriez) designed the original app icon, and was also a beta tester.
* [Julian Weiss (@insanj)](https://github.com/insanj) helped out around the place, and was a beta tester.
* [Kyle Pierre (@_kpierre)](https://twitter.com/_kpierre) named the app, and was also a beta tester.

## License
Licensed under the Apache License, version 2.0. Refer to [LICENSE.md](LICENSE.md).

Please note: Graphic assets are not being included in this license, as most of them were designed by other people, and I don’t want to give away their work without permission.
