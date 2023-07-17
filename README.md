
# Crappy Imgur Api

```lua
local s,r = pcall(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/923i/imgur-api/main/main.lua"))()
end)

if not s then
	print('something went wrong ',r)
end
```

## Features

- gen random image
- Scrape Analytics
- Scrape Album
- Grab Image From Gallery Link

## Documentation

Grab image from gallery link:


```lua
imgurapi:GrabImageFromGalleryLink('https://imgur.com/gallery/h75B8Y8')
```

Generate random image usually 2010-2015:

```lua
local tbl_dep = {
    amount = 35,
    ext = 'jpg',
    length = 5 -- 4-6
}
imgurapi:GenRandom(tbl_dep.amount,tbl_dep.ext,tbl_dep.length) -- jpg,gif,png
```


scrape photos from album:
```lua
imgurapi:AlbumData('https://imgur.com/gallery/O4VIC')
```

scrape image analytics:
```lua
imgurapi:ScrapeAnalytics('https://imgur.com/gallery/gmQtHMI')
```

