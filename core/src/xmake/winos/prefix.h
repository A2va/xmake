/*!A cross-platform build utility based on Lua
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Copyright (C) 2015-present, TBOOX Open Source Group.
 *
 * @author      ruki
 * @file        prefix.h
 *
 */
#ifndef XM_WINOS_PREFIX_H
#define XM_WINOS_PREFIX_H

/* //////////////////////////////////////////////////////////////////////////////////////
 * includes
 */
#include "../prefix.h"
#if __COSMOPOLITAN__
    #define typeof __typeof
    #include <windowsesque.h>
    #undef typeof
   
    // In the cosmopolitan windowsesque header HKEY is defined as int64_t and not a pointer
    // #undef HKEY
    // #define HKEY int64_t*

    #define RegOpenKeyExW RegOpenKeyEx
    #define RegQueryInfoKeyW RegQueryInfoKey
    #define RegEnumKeyExW RegEnumKeyEx
    #define RegEnumValueW RegEnumValue

    // Temp def until PR is made to cosmopolitan
    #define KEY_QUERY_VALUE         (0x0001)
#elif TB_CONFIG_OS_WINDOWS
    #include <windows.h>
#endif

#endif


