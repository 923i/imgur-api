--[[
	creds:
	    • terr for originally making the same thing for reddit 3 months ago --> https://v3rmillion.net/showthread.php?tid=1205837
		• https://pypi.org/project/imgur-scraper/ -- took some features from here
	features: 
		• gen random image
		• download image comments (provide a link)
		• Scrape Post Data (provide a link)
		• Scrape album data (provide a album link)
		
	uses:
		• absolutely none lol
		
	"Why didnt you just use jsondecode for majority of this 'api' " Because for some reason my fluxus errors when using it not sure why :|
]]

if not isfolder('imgur_collection') then
    makefolder('imgur_collection')
end

local request = (request and http.request) or (syn and syn.request) or error("Unable to find suitable HTTP library")

local HttpService = game:GetService('HttpService')

local imgurapi = {}

function imgurapi:Random_sequence(len) -- made this for the generator
    local _ = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local string = {}

    for i = 1, len do
        local ranidx = math.random(1, #_)
        local rc = _:sub(ranidx, ranidx)
        table.insert(string,rc)
    end
    return table.concat(string)
end

function imgurapi:GrabImageFromGalleryLink(link)
	assert(string.match(link, "%f[%a]gallery%f[%A]"),'gallery links only.')

    local response =  request(
        {
            Url = link,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            },
        })
    if response.StatusCode == 200 then
        local imageLink = response.Body:match('https://i%.imgur%.com/[%w%p]+%.%a+')
        local safeImageName = imageLink:gsub("[/\\:%.]", "_")

        if imageLink then
            writefile('imgur_collection/'.. safeImageName .. '-gallery ' .. '.jpeg',game:HttpGet(imageLink))
        else
            return print('image not found in body.');
        end
    end
end

--imgurapi:GrabImageFromGalleryLink('https://imgur.com/gallery/h75B8Y8')

function imgurapi:GenRandom(amount, ext, len)
    assert(typeof(amount) == 'number', 'amount needs to be a number.')
    assert(typeof(len) == 'number', 'length needs to be a number.')
    assert(typeof(ext) == 'string', 'extension needs to be a string.')

    local a = 0
    while a < amount do
        repeat
            task.wait()
            local urlpattern = 'https://i.imgur.com/' .. imgurapi:Random_sequence(len)

            local response = request(
                {
                    Url = urlpattern,
                    Method = "GET",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    }
                }
            )

            local image = response.Body:match('<meta%s+property="og:image"%s+data%-react%-helmet="true"%s+content="(https://i%.imgur%.com/[%w%p]+%.%a+)')

            if image then
                a = a + 1
                local safeImageName = image:gsub("[/\\:%.]", "_")
                local filename = 'imgur_collection/' .. safeImageName .. '-gen_' .. safeImageName .. '.' .. ext

                local success, errorMessage = pcall(function()
                    writefile(filename, game:HttpGet(image))
                end)

                if not success then
                    print("Error writing file:", errorMessage)
                end
            end
        until a == amount
    end
end

--[[
local tbl_dep = {
    amount = 35,
    ext = 'jpg',
    length = 5 -- 4-6
}
imgurapi:GenRandom(tbl_dep.amount,tbl_dep.ext,tbl_dep.length) -- jpg,gif,png
]]


function imgurapi:AlbumData(link)
    assert(typeof(link) == 'string', 'link needs to be a string!')

    local pattern = "https://i%.imgur%.com/[a-zA-Z0-9]+%.[a-zA-Z0-9]+"

    local matches = {}

    local function fetchMatches(str, pattern)
        for match in string.gmatch(str, pattern) do
            table.insert(matches, match)
        end
        return table.concat(matches)
    end

    local response = request(
        {
            Url = link,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        }
    )

    fetchMatches(response.Body, pattern)

    local processedUrls = {}

    local success, errorMessage = pcall(function()
        if #matches > 0 then
            for i = 1, #matches do
                local url = matches[i]
                if not processedUrls[url] then
                    processedUrls[url] = true
                    local updatedUrl = url:gsub("(%.%w+)$", ".jpeg")
                    local safeUpdatedUrl = updatedUrl:gsub("[/\\:%.]", "_")
                    print(updatedUrl)
                    writefile('imgur_collection/' .. safeUpdatedUrl .. '-album_data' .. '.' .. 'jpg', game:HttpGet(updatedUrl))
                end
            end
        end
    end)

    if not success then
        print('Something went wrong: ' .. errorMessage)
    end
end

--imgurapi:AlbumData('https://imgur.com/gallery/O4VIC') -- duplicates may occur from time to time

function imgurapi:ScrapeAnalytics(link)
    assert(typeof(link) == 'string', 'link needs to be a string.')

    local response = request(
        {
            Url = link,
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json"
            }
        }
    )

    if response.Success and response.Body then
        local jsonString = string.match(response.Body, "window%.postDataJSON%s*=%s*\"({.-})\"")
        if jsonString then
            jsonString = jsonString:gsub("\\\"", "\""):gsub("\\\\", "\\")

            local data = {
                view_count = tonumber(string.match(jsonString, "\"view_count\":(%d+)")),
                comment_amount = tonumber(string.match(jsonString, "\"comment_count\":(%d+)")),
                likes_count = tonumber(string.match(jsonString, "\"point_count\":(%d+)"))
            }
            local i = {} -- cause for some reason it prints twice lol fluxus issue
            local seenValues = {}

            for k, v in pairs(data) do
                if not seenValues[v] then
                    seenValues[v] = true
                    table.insert(i, { key = k, value = v })
                end
            end

            for _, v in ipairs(i) do
                print(v.key .. ":", v.value)
            end
        end
    end
end

--imgurapi:ScrapeAnalytics('https://imgur.com/gallery/gmQtHMI')

return imgurapi;
