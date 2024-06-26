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
-- @author      ruki
-- @file        toolchain.lua
--

-- is the compatible with the host?
function is_compatible_with_host(name)
    if is_host("linux", "macosx", "bsd") then
        if name:startswith("clang") or name:startswith("gcc") or name == "llvm" then
            return true
        end
    elseif is_host("windows") then
        if name == "msvc" or name == "llvm" or name == "clang-cl" then
            return true
        end
    end
end

-- get vs toolset version, e.g. v143, v144, ..
function get_vs_toolset_ver(vs_toolset)
    local toolset_ver
    if vs_toolset then
        local verinfo = vs_toolset:split('%.')
        if #verinfo >= 2 then
            toolset_ver = "v" .. verinfo[1] .. (verinfo[2]:sub(1, 1) or "0")
        end

        -- @see https://github.com/xmake-io/xmake/pull/5176
        if toolset_ver and toolset_ver == "v144" and vs_toolset:startswith("14.40.") then
            toolset_ver = "v143"
        end
    end
    return toolset_ver
end
