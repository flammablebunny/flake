local function get_caelestia_data()
  local home = os.getenv("HOME")
  local cmd = 'ls -td ' .. home .. '/.cache/caelestia/schemes/*/ 2>/dev/null | head -1'
  
  local handle = io.popen(cmd)
  local latest_dir = handle:read("*a"):gsub("\n", "")
  handle:close()

  if latest_dir == "" then return nil end

  local file_path = latest_dir .. "/vibrant/dark.json"
  local file = io.open(file_path, "r")
  if not file then return nil end

  local content = file:read("*a")
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok then return nil end
  return data
end

local overrides = nil
local c = get_caelestia_data()

if c then
  local function h(hex) return "#" .. (hex or "000000") end
  overrides = {
    mocha = {
      base = h(c.base),
      mantle = h(c.mantle),
      crust = h(c.crust),
      text = h(c.text),
      subtext1 = h(c.subtext1),
      subtext0 = h(c.subtext0),
      blue = h(c.blue),
      mauve = h(c.mauve),
      pink = h(c.pink),
      red = h(c.red),
      peach = h(c.peach),
      yellow = h(c.yellow),
      green = h(c.green),
      teal = h(c.teal),
    },
  }
end

require("catppuccin").setup({
  flavour = "mocha",
  transparent_background = true,
  color_overrides = overrides
})

vim.cmd.colorscheme "catppuccin"
