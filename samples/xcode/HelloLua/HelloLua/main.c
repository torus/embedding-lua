//
//  main.c
//  HelloLua
//
//  Created by Hisai Toru on 2013/09/22.
//  Copyright (c) 2013年 Kronecker's Delta Studio. All rights reserved.
//

#include <stdio.h>
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

int main(int argc, const char * argv[])
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    
    lua_getglobal(L, "print");
    lua_pushstring(L, "Hello Lua!");
    lua_call(L, 1, 0);
    
    return 0;
}
