# fiskabur 🐡
fiskabúr - pronouced (fish-ka-bush) is a basic template for running javascript app in a desktop wrapper
the code is tiny and easy to read and *seems* less resource intensive then electron


## Run Example

```bash
$ python3 main.py
```

# Why make this?
- too many eletron apps kill computers, so im exploring alternatives
- somethings a dead simple wrapper is all you need
- it's KISS
- nicer dependencies and simple system with python

# Building
Mac
```
$ python3 build-mac.py py2app
```

## TODO
- Close button doesnt work (mac os)
- include chumbucket install somehow
- migrate to deathmark

# Docs
https://pywebview.flowrl.com/

# Icons

Size generator + Mac icns
```
$ generate-iconset assets/icon.png
```

https://pngtoicon.com/
https://pypi.org/project/generate-iconset/

