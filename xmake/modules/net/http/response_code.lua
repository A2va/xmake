--!A cross-platform build utility based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-present, TBOOX Open Source Group.
--
-- @author      A2va
-- @file        response_code.lua
--

-- imports
import("core.base.option")
import("lib.detect.find_tool")
import("net.proxy")

-- https://unix.stackexchange.com/questions/474805/verify-if-a-url-exists

-- get user agent
function _get_user_agent()

    -- init user agent
    if _g._USER_AGENT == nil then

        -- init systems
        local systems = {macosx = "Macintosh", linux = "Linux", windows = "Windows", msys = "MSYS", cygwin = "Cygwin"}

        -- os user agent
        local os_user_agent = ""
        if is_host("macosx") then
            local osver = try { function() return os.iorun("/usr/bin/sw_vers -productVersion") end }
            if osver then
                os_user_agent = ("Intel Mac OS X " .. (osver or "")):trim()
            end
        elseif is_subhost("linux", "msys", "cygwin") then
            local osver = try { function () return os.iorun("uname -r") end }
            if osver then
                os_user_agent = (os_user_agent .. " " .. (osver or "")):trim()
            end
        end

        -- make user agent
        _g._USER_AGENT = string.format("Xmake/%s (%s;%s)", xmake.version(), systems[os.subhost()] or os.subhost(), os_user_agent)
    end
    return _g._USER_AGENT
end

function _parse_output(output)
    -- match the first line
    local s = string.match(output, "(.-)\n", 1)
    local t = s:split(" ")
    -- return response code and text
    return s[2], s[3]
end

-- get response using curl
function _curl_response(tool, url, outputfile, opt)

    -- set basic arguments
    local argv = {}
    if option.get("verbose") then
        table.insert(argv, "-SL")
    else
        table.insert(argv, "-fsSL")
    end

    -- use proxy?
    local proxy_conf = proxy.config(url)
    if proxy_conf then
        table.insert(argv, "-x")
        table.insert(argv, proxy_conf)
    end

    -- set user-agent
    local user_agent = _get_user_agent()
    if user_agent then
        if tool.version then
            user_agent = user_agent .. " curl/" .. tool.version
        end
        table.insert(argv, "-A")
        table.insert(argv, user_agent)
    end

    -- ignore to check ssl certificates
    if opt.insecure then
        table.insert(argv, "-k")
    end

    -- add custom headers
    if opt.headers then
        for _, header in ipairs(opt.headers) do
            table.insert(argv, "-H")
            table.insert(argv, header)
        end
    end

    table.insert(argv, "--head")
    table.insert(argv, "--fail")

    -- set url
    table.insert(argv, url)

    -- get curl output
    local output = os.iorunv(tool.program, argv)
    return _parse_output(os.iorunv(tool.program, argv))

end

-- get response using wget
function _wget_response(tool, url, outputfile, opt)

    -- ensure output directory
    local argv = {url}
    local outputdir = path.directory(outputfile)
    if not os.isdir(outputdir) then
        os.mkdir(outputdir)
    end

    -- use proxy?
    local proxy_conf = proxy.config(url)
    if proxy_conf then
        table.insert(argv, "-e")
        table.insert(argv, "use_proxy=yes")
        table.insert(argv, "-e")
        if url:startswith("http://") then
            table.insert(argv, "http_proxy=" .. proxy_conf)
        elseif url:startswith("https://") then
            table.insert(argv, "https_proxy=" .. proxy_conf)
        elseif url:startswith("ftp://") then
            table.insert(argv, "ftp_proxy=" .. proxy_conf)
        else
            table.insert(argv, "http_proxy=" .. proxy_conf)
        end
    end

    -- set user-agent
    local user_agent = _get_user_agent()
    if user_agent then
        if tool.version then
            user_agent = user_agent .. " wget/" .. tool.version
        end
        table.insert(argv, "-U")
        table.insert(argv, user_agent)
    end

    -- ignore to check ssl certificates
    if opt.insecure then
        table.insert(argv, "--no-check-certificate")
    end

    -- add custom headers
    if opt.headers then
        for _, header in ipairs(opt.headers) do
            table.insert(argv, "--header=" .. header)
        end
    end

    table.insert(argv, "--method=HEAD")

    -- get wget output
    return _parse_output(os.iorunv(tool.program, argv))
end

-- get the response code from an url
--
-- @param url           the input url
-- @param opt           the option
--
function main(url, outputfile, opt)

    -- init output file
    opt = opt or {}

    -- attempt to use curl first
    local tool = find_tool("curl", {version = true})
    if tool then
        return _curl_response(tool, url, outputfile, opt)
    end

    --  then using wget
    tool = find_tool("wget", {version = true})
    if tool then
        return _wget_response(tool, url, outputfile, opt)
    end
end
