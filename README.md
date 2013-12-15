# Aphelion
![Aphelion](http://i.imgur.com/4m8ndyE.png)

## Setting up
1. Install ruby so you can install gem so you can install cocoapods so you can install dependencies for the project:

        sudo port install ruby # or whatever
        gem install cocoapods
        pod install
2. Grab [cycript](https://cydia.saurik.com/api/latest/3), copy the framework to /Library/Frameworks, the cycript binary to /usr/bin, and the libraries to /usr/lib
3. ???
4. Profit

## Using cycript for on-device debug
When the app launches, it'll log a cycript command you can paste into a shell to get the cycript REPL we all love so much. (Yes, even on jailed devices.) Just be sure to hit `^D` when you're done or the app will crash with a CYPoolError for about 20 seconds.
