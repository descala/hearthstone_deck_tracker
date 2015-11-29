# hearthstone_deck_tracker
rudimentary hearthstone deck tracker in ruby

* Enable logging in Hearthstone, creating file in
```
$wineprefix/drive_c/users/$user/Local\ Settings/Application\ Data/Blizzard/Hearthstone/log.config
```

with contents:

```
[Zone]
LogLevel=1
FilePrinting=true
ConsolePrinting=false
ScreenPrinting=false
Verbose=true
[Bob]
LogLevel=1
FilePrinting=true
ConsolePrinting=false
ScreenPrinting=false
Verbose=true
[Power]
LogLevel=1
FilePrinting=true
ConsolePrinting=false
ScreenPrinting=false
Verbose=true
[Asset]
LogLevel=1
FilePrinting=true
ConsolePrinting=false
ScreenPrinting=false
Verbose=true
[Rachelle]
LogLevel=1
FilePrinting=true
ConsolePrinting=false
ScreenPrinting=false
Verbose=true
[Arena]
LogLevel=1
FilePrinting=true
ConsolePrinting=false
ScreenPrinting=false
Verbose=true
[Achievements]
LogLevel=1
FilePrinting=true
ConsolePrinting=false
ScreenPrinting=false
Verbose=true
```
* create config.json with path to Hearthstone log dir, for example
```
{
  "log_path": "/home/user/.local/share/wineprefixes/hearthstone/drive_c/Program Files/Hearthstone/Logs"
}
```

* run main.rb
