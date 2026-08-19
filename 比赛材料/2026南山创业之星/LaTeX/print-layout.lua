-- Print-oriented transformations for the semifinal business plan.
-- The Markdown remains the content source; this file controls only layout.

local function header_text(tbl)
  if not tbl.head or not tbl.head.rows or not tbl.head.rows[1] then
    return ""
  end

  local cells = tbl.head.rows[1].cells
  local values = {}
  for i, cell in ipairs(cells) do
    values[i] = pandoc.utils.stringify(cell.contents)
  end
  return table.concat(values, "|")
end

local function widths_for(header, count)
  local layouts = {
    ["维度|当前基础"] = {0.18, 0.82},
    ["项目|当前状态|证明意义"] = {0.17, 0.18, 0.65},
    ["角色|成员|核心背景与职责"] = {0.24, 0.13, 0.63},
    ["产品/类型|已验证价值|本项目增加的价值"] = {0.25, 0.34, 0.41},
    ["阶段|时间|核心动作|关键验证"] = {0.14, 0.14, 0.36, 0.36},
    ["阶段|时间|核心交付与决策"] = {0.15, 0.16, 0.69},
    ["节点|指标|当前目标|用途"] = {0.16, 0.18, 0.27, 0.39},
    ["项目|内容"] = {0.22, 0.78},
    ["用途|金额|占比|主要依据"] = {0.40, 0.12, 0.10, 0.38},
    ["阶段|计划到账时间|金额|主要覆盖|下一阶段拨付依据"] = {0.22, 0.14, 0.10, 0.25, 0.29},
    ["用途|金额|说明"] = {0.43, 0.15, 0.42},
    ["成本层级|金额|覆盖范围"] = {0.22, 0.18, 0.60},
    ["情景|销量|消费者支付总额|平台费后回款（税前）|项目累计经营现金净额|管理动作"] = {0.12, 0.10, 0.15, 0.17, 0.18, 0.28},
    ["风险|当前事实|控制措施与决策门槛"] = {0.18, 0.24, 0.58}
  }

  if layouts[header] then
    return layouts[header]
  end

  local widths = {}
  for i = 1, count do
    widths[i] = 1 / count
  end
  return widths
end

local function decorate_header_cell(cell)
  if not cell.contents or not cell.contents[1] then
    return
  end

  local block = cell.contents[1]
  if block.t == "Plain" or block.t == "Para" then
    table.insert(block.content, 1, pandoc.RawInline("latex", "\\cellcolor{TableHeader}\\color{BrandBlue}\\bfseries "))
  end
end

function Table(tbl)
  local header = header_text(tbl)
  local widths = widths_for(header, #tbl.colspecs)

  for i, spec in ipairs(tbl.colspecs) do
    local alignment = spec[1]
    tbl.colspecs[i] = {alignment, widths[i]}
  end

  if tbl.head and tbl.head.rows then
    for _, row in ipairs(tbl.head.rows) do
      for _, cell in ipairs(row.cells) do
        decorate_header_cell(cell)
      end
    end
  end

  return {
    pandoc.RawBlock("latex", "\\begin{BusinessTable}"),
    tbl,
    pandoc.RawBlock("latex", "\\end{BusinessTable}")
  }
end

function HorizontalRule()
  return {}
end
