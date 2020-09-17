--
-- linq.lua
--
-- Copyright (c) 2020 Mathew Mariani
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do
-- so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--

local linq = { _version = "1.0.0" }

local isarray = function(t)
	return type(t) == "table" and t[1] ~= nil
end

local getitr = function(t)
	if isarray(t) then
		return ipairs
	elseif type(t) == "table" then
		return pairs
	end
end

function linq.select(t, fn)
	local r = {}
	if isarray(t) then
		for i, v in ipairs(t) do
			r[#r + 1] = fn(i, v)
		end
	else
		local c = 1
		for k, v in pairs(t) do
			r[k], c = fn(c, v), c + 1
		end
	end
	return r
end

function linq.where(t, fn)
	local r = {}
	if isarray(t) then
		for _, v in ipairs(t) do
			if fn(v) then r[#r + 1] = v end
		end
	else
		for k, v in pairs(t) do
			if fn(v) then r[k] = v end
		end
	end
	return r
end

function linq.take(t, n, fn)
	local r, c = {}, 0
	if fn then
		if isarray(t) then
			for _, v in ipairs(t) do
				if fn(v) then r[#r + 1] = v end
				if #r == n then break end
			end
		else
			for k, v in pairs(t) do
				if fn(v) then r[k], c = v, c + 1 end
				if c == n then break end
			end
		end
	else
		if isarray(t) then
			for i = 1, n do
				r[#r + 1] = t[i]
			end
		else
			for k, v in pairs(t) do
				r[k], c = v, c + 1
				if c == n then break end
			end
		end
	end
	return r
end

function linq.skip(t, n)
	local r = {}
	local j = n >0 and n+1 or 1
	local k = n > 0 and #t or #t+n
	for i = j, k do
		r[#r + 1] = t[i]
	end
	return r
end

function linq.reverse(t)
	local r = {}
	for i = #t, 1, -1 do
		r[#r+1] = t[i]
	end
	return r
end

function linq.first(t, fn)
	local itr = getitr(t)
	if fn then
		for _, v in itr(t) do
			if fn(v) then return v end
		end
	end
	return t[1]
end

function linq.last(t, fn)
	local itr = getitr(t)
	if fn then
		local l = nil
		for _, v in itr(t) do
			if fn(v) then l = v end
		end
		return l
	end
	return t[#t]
end

function linq.any(t, fn)
	if fn then
		local itr = getitr(t)
		for _, v in itr(t) do
			if fn(v) then return true end
		end
		return false
	end
	return linq.count(t) > 0
end

function linq.contains(t, value)
	local itr = getitr(t)
	for _, v in itr(t) do
		if v == value then return true end
	end
	return false
end

function linq.count(t, fn)
	local itr = getitr(t)
	local c = 0
	if fn then
		for _, v in itr(t) do
			if fn(v) then c = c + 1 end
		end
	else
		if isarray(t) then
			return #t
		else
			for _ in itr(t) do c = c + 1 end
		end
	end
	return c
end

local trans_fn = function(fn)
	return function(self, ...)
		self._value = fn(self._value, ...)
		return self
	end
end

local transaction_mt = {}
transaction_mt.__index = {
	select = trans_fn(linq.select),
	where = trans_fn(linq.where),
	take = trans_fn(linq.take),
	skip = trans_fn(linq.skip),
	reverse = trans_fn(linq.reverse),
	first = trans_fn(linq.first),
	last = trans_fn(linq.last),
	any = trans_fn(linq.any),
	contains = trans_fn(linq.contains),
	count = trans_fn(linq.count),
	result = function(x) return x._value end
}

function linq.transaction(value)
	return setmetatable({ _value = value }, transaction_mt)
end

setmetatable(linq,  {
	__call = function(_, ...)
		return linq.transaction(...)
	end
})

return linq