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
-- @file        toml.lua
--

-- define module: toml

local toml = toml or {}
local io    = require("base/io")
local utils = require("base/utils")

-- save original interfaces
toml._decode = toml._decode or toml.decode
toml._encode = toml._encode or toml.encode

-- decode toml string to the lua table
--
-- @param tomlstr       the toml string
-- @param opt           the options
--
-- @return              the lua table
--
function toml.decode(tomlstr, opt)
    local ok, luatable_or_errors = utils.trycall(toml._decode, nil, tomlstr)
    if not ok then
        return nil, string.format("decode toml failed, %s", luatable_or_errors)
    end
    return luatable_or_errors
end

-- encode lua table to the toml string
--
-- @param luatable      the lua table
-- @param opt           the options
--
-- @return              the toml string
--
function toml.encode(luatable, opt)
    local ok, luatable_or_errors = utils.trycall(toml._encode, nil, luatable)
    if not ok then
        return nil, string.format("encode toml failed, %s", luatable_or_errors)
    end
    return luatable_or_errors
end


-- load toml file to the lua table
--
-- @param filepath      the toml file path
-- @param opt           the options
--                      - encoding for io/file, e.g. utf8, utf16, utf16le, utf16be ..
--                      - continuation for io/read (concat string with the given continuation characters)
--
-- @return              the lua table
--
function toml.loadfile(filepath, opt)
    local filedata, errors = io.readfile(filepath, opt)
    if not filedata then
        return nil, errors
    end
    return toml.decode(filedata, opt)
end

-- save lua table to the toml file
--
-- @param filepath      the toml file path
-- @param luatable      the lua table
-- @param opt           the options
--                      - encoding for io/file, e.g. utf8, utf16, utf16le, utf16be ..
--
-- @return              true of false
--
function toml.savefile(filepath, luatable, opt)
    local tomlstr, errors = toml.encode(luatable, opt)
    if not tomlstr then
        return false, errors
    end
    return io.writefile(filepath, tomlstr, opt)
end

-- return module: toml
return toml
