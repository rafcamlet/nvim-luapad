local Job = require("plenary.job")
local harness = require'plenary.test_harness'
local log = require("plenary.log")

local print_output = vim.schedule_wrap(function(_, ...)
  for _, v in ipairs({...}) do
    io.stdout:write(tostring(v))
    io.stdout:write("\n")
  end

  vim.cmd [[mode]]
end)

local function non_paraller_test_directory(directory)

  print("Starting...")

  local res = {}

  local outputter = print_output

  local paths = harness._find_files_to_run(directory)

  local path_len = #paths

  local failure = false

  local jobs = vim.tbl_map(
    function(p)
      local args = {
        '--headless',
        '-c',
        string.format('lua require("plenary.busted").run("%s")', p:absolute())
      }

      local job = Job:new {
        command = vim.v.progpath,
        args = args,

        -- Can be turned on to debug
        on_stdout = function(_, data)
          if path_len == 1 then
            outputter(res.bufnr, data)
          end
        end,

        on_stderr = function(_, data)
          if path_len == 1 then
            outputter(res.bufnr, data)
          end
        end,

        on_exit = vim.schedule_wrap(function(j_self, _, _)
          if path_len ~= 1 then
            outputter(res.bufnr, unpack(j_self:stderr_result()))
            outputter(res.bufnr, unpack(j_self:result()))
          end

          vim.cmd('mode')
        end)
      }
      job.nvim_busted_path = p.filename
      return job
    end,
    paths
  )

  log.debug("Running...")
  for i, j in ipairs(jobs) do
    outputter(res.bufnr, "Scheduling: " .. j.nvim_busted_path)
    j:start()
    log.debug("... Sequential wait for job number", i)
    Job.join(j,50000)
    log.debug("... Completed job number", i)
    if j.code ~= 0 then
      failure = true
    end
  end

  vim.wait(100)

  if failure then os.exit(1) end

  os.exit(0)
end

non_paraller_test_directory('spec/')
