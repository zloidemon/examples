#!/usr/bin/env tarantool

local swift_module_name = 'SwiftTarantoolModule'

-- module search paths for box.schema.func.create
package.cpath =
    '.build/debug/lib'..swift_module_name..'.so;.build/debug/lib'..swift_module_name..'.dylib;'..
    '.build/release/lib'..swift_module_name..'.so;.build/release/lib'..swift_module_name..'.dylib;'..
    package.cpath

os.execute("mkdir -p data")

-- init tarantool
box.cfg {
    listen = 3301,
    wal_dir = "data",
    memtx_dir = "data",
    vinyl_dir = "data",
    memtx_memory=209715200 -- limit memory to 200mb to run on cheap virtual servers
}

-- create data space
local data = box.schema.create_space('data', {if_not_exists = true})
-- create primary index, type: tree, field type: string
data:create_index('primary', { parts = {1, 'STR'}, if_not_exists = true})

-- init swift module
swift = require(swift_module_name)

-- 1. native way
box.schema.func.create('helloSwiftNative', {language = "C", if_not_exists = true})
box.schema.func.create('getFooNative', {language = "C", if_not_exists = true})
box.schema.func.create('getCountNative', {language = "C", if_not_exists = true})
box.schema.func.create('evalLuaScriptNative', {language = "C", if_not_exists = true})

-- 2. convenient way
for key, value in pairs(swift) do
    _G[key] = function( ... )
        -- pass the function name with arguments
        return swift[key](key, ...)
    end
    print('lua: creating '..key..' function')
    box.schema.func.create(key, {if_not_exists = true})
end

-- hello from lua
box.schema.func.create('helloLua', {if_not_exists = true})
function helloLua()
    return 'hello from lua'
end

-- guest user rights
box.schema.user.grant('guest', 'read,write,execute', 'universe', nil, {if_not_exists = true})

-- test space for getCount function
local test = box.schema.space.create('test', {if_not_exists = true})
test:create_index('primary', {type = 'hash', parts = {1, 'unsigned'}, if_not_exists = true})

test:replace({1, 'foo'})
test:replace({2, 'bar'})
test:replace({3, 'baz'})

-- enable console if needed
require('console').start()
