# linq.lua

A collection of [LINQ](https://en.wikipedia.org/wiki/Language_Integrated_Query) like functions for Lua.


## Installation

The [linq.lua](linq.lua?raw=1) file should be dropped into an existing project
and required by it:

```lua
local linq = require("linq")
```


## Function Reference

#### linq.select(t, fn)
Performs a projection of function `fn` to each value in table `t` and returns a new table of the resulting projection.
```lua
linq.select({ 1, 2, 3 }, function(x) return x * 2 end)	-- > { 2, 4, 6 }
```

#### linq.where(t, fn)
Calls function `fn` on each value of table `t` returning a new table of all values where `fn` returns true.
```lua
linq.where({ 1, 2, 3, 4 }, function(x) return x % 2 == 0 end)	-- > { 2, 4 }
```

#### linq.take(t, n [, fn])
Returns an table of `n` values from the start of table `t`. If a predicate function `fn` is provided only values where `fn` returns true will be returned.
```lua
linq.take({ 1, 2, 3, 4 }, 3)	-- > { 1, 2, 3 }
```

#### linq.skip(t, n)
Returns a table consisting of values from table `t` after skipping the first `n` values.
A negative value for `n` can be used to skip the last `n` values.
```lua
linq.skip({ 1, 2, 3, 4 }, 2)	-- > { 1, 2 }
linq.skip({ 1, 2, 3, 4 }, -2)	-- > { 3, 4 }
```

#### linq.reverse(t)
Reverses the order of the values in a table.
```lua
linq.reverse({ 1, 2, 3, 4 })	-- > { 4, 3, 2, 1 }
```

#### linq.first(t [, fn])
Returns the first value in table `t`. If a predicate function `fn` is provided it is called on each value, a value is returned if a call to `fn` returns true.
```lua
linq.first({ 1, 2, 3, 4 }, function(x) x % 2 == 0 end)	-- > 2
```

#### linq.last(t [, fn])
Returns the last value in table `t`. If a predicate function `fn` is provided it is called on each value, the last value where a call to `fn` returns true will be returned.
```lua
linq.last({ 1, 2, 3, 4 }, function(x) x % 2 == 0 end)	-- > 4
```

#### linq.any(t [, fn])
Returns true if any values in table `t` exist. If a predicate function `fn` is provided it is called on each value, true is returned if any of the calls to fn return true.
```lua
linq.any({ 1, 2, 3, 4 }, function(x) x % 2 == 0 end)	-- > true
```

#### linq.contains(t, value)
Returns true if the table `t` contains a given value.
```lua
linq.contains({ "tea", "coffee", "water" }, "coffee")	-- > true
```

#### linq.count(t [, fn])
Returns the number of values in table `t`. If a predicate function `fn` is provided it is called on each value, the number of values where `fn` returns true will be returned.
```lua
linq.count({ 1, 2, 3, 4 })	-- > 4
linq.count({ 1, 2, 3, 4 }, function(x) return x % 2 == 0 end)	-- > 2
```

#### linq.transaction(t)
Returns a wrapped object that allows chaining linq function calls. The function `result()` should be called at the end of a transaction to retrieve the resulting value.
```lua
linq.transaction(t)
	:select(function(x) return x * 2 end)
	:last()
	:result()
```

## License

This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.