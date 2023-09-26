add_requires("sol2", "magic_enum", "toml++")
-- add target
target("toml-lua")
    -- make as a static library
    set_kind("static")
    set_languages("cxx17")
    if is_config("runtime", "luajit") then
        add_deps("luajit")
    else
        add_deps("lua")
    end

    add_packages("sol2", "magic_enum", "toml++")

    add_includedirs("toml-lua/src")
    add_files("toml-lua/src/**.cpp")
    add_headerfiles("toml-lua/src/**.hpp")

    before_build(function (target)
        local files = table.join(target:sourcefiles(), target:headerfiles())
        for _, file in ipairs(files) do
            io.replace(file, "toml.hpp", "toml++/toml.h")
        end
    end)
