local internet = require("internet")
local fs = require("filesystem")

local args = table.pack(...)

local api_dev_key = args[1]
local file = args[2]

if not fs.exists(file) then
  error("file not found: " .. file)
end

local file, err = fs.open(file)

if not file then
  error("failed to open file: " .. err)
end

local content = file:read(math.huge)

local req = {}

req["api_dev_key"] = api_dev_key
req["api_option"] = "paste"
req["api_paste_code"] = content or ""

local resp = internet.request("https://pastebin.com/api/api_post.php", req)

for chunk in resp do
  io.stdout:write(chunk)
end

io.stdout:write("\n")