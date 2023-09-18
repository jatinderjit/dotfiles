-- Replaces the HTML content in the clipboard with the equivalent Markdown

local logger = hs.logger.new('joplin-pb', 'debug')

getmetatable('').__index = function(str, i)
    if type(i) == 'number' then
        return string.sub(str, i, i)
    else
        return string[i]
    end
end

local function trim(text)
    text = text:gsub("^[ \n\t]+", "")
    return text:gsub("[ \n\t]+$", "")
end

local TagHandler = {
    compact_whitespace = true,
    has_closing_tag = true,
    processor = function(text, props, parent_tag) return text end,
}

function TagHandler:new(props)
    local handler = {}
    -- Shorthand to allow passing just the processor
    if type(props):sub(1, 8) == "function" then
        props = { processor = props }
    end
    if props ~= nil then
        for key, value in pairs(props) do
            handler[key] = value
        end
    end
    self.__index = self
    return setmetatable(handler, self)
end

local tag_handlers = {
    a = TagHandler:new(function(text, props)
        assert(props.href ~= nil)
        return string.format("[%s](%s)", text, props.href)
    end),
    b = TagHandler:new(function(text) return string.format("**%s**", text) end),
    strong = TagHandler:new(function(text) return string.format("**%s**", text) end),
    i = TagHandler:new(function(text) return string.format("_%s_", text) end),
    em = TagHandler:new(function(text) return string.format("_%s_", text) end),
    p = TagHandler:new(function(text) return string.format("\n\n%s\n\n", text) end),
    h1 = TagHandler:new(function(text) return string.format("\n# %s\n", text) end),
    h2 = TagHandler:new(function(text) return string.format("\n## %s\n", text) end),
    h3 = TagHandler:new(function(text) return string.format("\n### %s\n", text) end),
    h4 = TagHandler:new(function(text) return string.format("\n#### %s\n", text) end),
    h5 = TagHandler:new(function(text) return string.format("\n##### %s\n", text) end),
    h6 = TagHandler:new(function(text) return string.format("\n###### %s\n", text) end),
    code = TagHandler:new(function(text) return string.format("`%s` ", text) end),
    li = TagHandler:new(function(text)
        -- print("li received:\n", text)
        return "\n- " .. trim(text):gsub("\n", "\n\t")
    end),
    pre = TagHandler:new({
        compact_whitespace = false,
        processor = function(text)
            return string.format("\n```\n%s```\n", text)
        end,
    }),
    ul = TagHandler:new(function(text, props, parent_tag)
        if parent_tag == "ul" or parent_tag == "li" then
            return text:gsub("\n", "\n\t")
        else
            return text
        end
    end),
    ol = TagHandler:new(function(text, props, parent_tag)
        local i = 1
        local out = ""
        for line in text:gmatch("([^\n]*\n)") do
            if line:sub(1, 2) == "- " then
                out = string.format("%s%d. %s", out, i, line:sub(3, line:len()))
                i = i + 1
            else
                out = out .. line
            end
        end
        if parent_tag == "ul" or parent_tag == "li" then
            out = out:gsub("\n", "\n\t")
        end
        return out
    end),
    br = TagHandler:new({
        has_closing_tag = false,
        processor = function() return "\n\n" end,
    }),
    hr = TagHandler:new({
        has_closing_tag = false,
        processor = function() return "\n\n---\n\n" end,
    }),
}

local function parse_attribute(html, props, i)
    while html[i] == " " do
        i = i + 1
    end
    if html[i] == ">" then
        return i
    end
    local eq = html:find("=", i)
    assert(html[eq + 1] == '"', "Attribute values must be in quotes")
    local attr_end = html:find('"', eq + 2)
    local key = html:sub(i, eq - 1)
    local value = html:sub(eq + 2, attr_end - 1)
    props[key] = value
    return attr_end + 1
end

local function parse_tag(html, i, depth, parent_tag)
    -- print(string.format("depth: %d, parse_tag(%d) (%s)", depth, i, html:sub(i, i+20)))
    assert(html[i] == "<", string.format('Invalid tag start: "%s"', html:sub(i, i + 10)))
    i = i + 1
    local tag = ""
    local props = {}
    local text = ""

    while html[i] ~= ">" and html[i] ~= " " do
        tag = tag .. html[i]
        i = i + 1
    end
    while html[i] == " " do
        i = parse_attribute(html, props, i)
    end
    assert(html[i] == ">", string.format("Invalid tag end at %d", i))

    local handler = tag_handlers[tag] or TagHandler
    if not handler.has_closing_tag then
        return { text = handler.processor(), i = i + 1 }
    end

    i = i + 1
    local is_prev_whitespace = handler.compact_whitespace
    while html:sub(i, i + 1) ~= "</" do
        if html[i] ~= "<" then
            if html[i]:match("[ \t\n]") then
                if handler.compact_whitespace and not is_prev_whitespace then
                    text = text .. " "
                elseif not handler.compact_whitespace then
                    text = text .. html[i]
                end
                is_prev_whitespace = true
            else
                text = text .. html[i]
                is_prev_whitespace = false
            end
            i = i + 1
        else
            local child = parse_tag(html, i, depth + 1, tag)
            if child.text ~= nil then
                if is_prev_whitespace then
                    text = text .. " "
                end
                text = text .. child.text
            end
            i = child.i
            is_prev_whitespace = child.is_prev_whitespace
        end
    end
    if handler.compact_whitespace then
        text = trim(text)
    end
    i = html:find(">", i) + 1
    -- print(string.format("depth:%d, ending at i=%d (%s)", depth, i, html:sub(i, i+20)))
    if handler ~= nil then
        return {
            text = handler.processor(text, props, parent_tag),
            is_prev_whitespace = is_prev_whitespace,
            i = i,
        }
    else
        return { text = text, is_prev_whitespace = is_prev_whitespace, i = i }
    end
end

local function clean(text)
    text = text:gsub("^\n+", "")   -- trim at the beginning
    text = text:gsub("\n+$", "\n") -- trim at the end

    local truncated = true
    while truncated do
        local prev_len = text:len()
        text = text:gsub("\n[ \t]+\n", "\n\n") -- truncate blank lines
        truncated = prev_len ~= text:len()
    end

    text = text:gsub("\n\n\n+", "\n\n") -- combine redundant lines
    text = text:gsub("&amp;", "&")
    return text
end

local function parse(html)
    local body_start = html:find("<body>")
    local body_end = html:find("</body>")
    html = html:sub(body_start, body_end + 6)
    local result = parse_tag(html, 1, 0).text
    return clean(result)
end

local function log(tb, msg)
    if msg == nil then
        msg = "table"
    end
    logger.d(string.format("start logging %s", msg))
    if type(tb) == "string" then
        logger.d(tb)
    else
        for key, value in pairs(tb) do
            if type(value) == "table" then
                log(value, string.format("%s:%s:%s", key, msg, msg))
            else
                local msg = string.format("'%s' => %s", key, value)
                logger.d(msg)
            end
        end
    end
    logger.d(string.format("end logging %s", msg))
end

function obj:cleanPasteboard()
    local pb = hs.pasteboard
    local pbct = pb.contentTypes()
    -- local contains = hs.fnutils.contains
    -- log(pb.typesAvailable(), "TypesAvailable")
    -- log(pb.readStyledText():asTable(), "StyledText")
    -- log(pb.readStyledText():convert("text"), "StyledText")
    -- log(pb.readStyledText():convert("html"), "StyledText-html")
    -- local html = pb.readStyledText():convert("html")
    -- local mdHtml = parse(html)
    -- hs.pasteboard.setContents(mdHtml)
    -- log(mdHtml, "Converted")
    local contains = hs.fnutils.contains
    if contains(pbct, "public.html") then
        local data = pb.readAllData()
        log(data, "readAllData")
        local value = data["public.html"]
        log(value, "public.html")
        local mdHtml = parse(value)
        hs.pasteboard.setContents(mdHtml)
        log(mdHtml, "Converted")
        -- value = string.gsub(value, '<a href="([^"]+)"[^>]*>([^<]+)</a>', '[%2](%1)')
    end
end

return obj
