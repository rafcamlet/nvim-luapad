local Config = require("luapad.config").config
local hrtime = vim.loop.hrtime

local Benchmark = {}
Benchmark.__index = Benchmark
Benchmark.benchmark_index = 1

function Benchmark:start_benchmark(f, iterations, handle_result)
	self.benchmark_index = self.benchmark_index + 1
	local this_benchmark_index = self.benchmark_index
	local total_time = 0
	local cur_iteration = 0

	local run_iter
	run_iter = function()
		cur_iteration = cur_iteration + 1
		vim.defer_fn(function()
			if self.benchmark_index == this_benchmark_index then
				local start = hrtime()
				self:tcall(f)
				local stop = hrtime()
				local diff = (stop - start) / 1e6
				total_time = total_time + diff
				if cur_iteration <= iterations then
					self:update_view(total_time, cur_iteration, iterations, handle_result)
					run_iter()
				end
			end
		end, 5)
	end

	run_iter()
end

function Benchmark:update_view(total_time, cur_iteration, max_iterations, handle_result)
	local percentage = ("%s"):format(math.floor((cur_iteration / max_iterations) * 100))
	local percentage_str = string.rep(" ", 3 - #percentage) .. percentage .. "%"
	local avg_time = total_time / cur_iteration
	handle_result(("BENCHMARK: %s ms (avg, %s of %s iterations)"):format(avg_time, percentage_str, max_iterations))
end

function Benchmark:tcall(fun)
	local count_limit = Config.count_limit < 1000 and 1000 or Config.count_limit
	pcall(function()
		debug.sethook(function()
			error("LuapadTimeoutError")
		end, "", count_limit)
		fun()
	end)
	debug.sethook()
end

return Benchmark
