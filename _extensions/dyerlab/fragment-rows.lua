-- fragment-rows.lua
-- Reveal the body rows of a table one at a time on slides.
--
-- Usage in a revealjs .qmd — wrap the table in a div:
--   ::: {.fragment-rows}
--   | A | B |
--   |---|---|
--   | 1 | 2 |
--   :::
-- Header rows stay visible; each body row becomes a reveal.js fragment.
-- Other formats ignore it, so the same markup is safe in narratives.

local function mark_rows(tbl)
  for _, body in ipairs(tbl.bodies) do
    for _, row in ipairs(body.body) do
      row.attr.classes:insert("fragment")
    end
  end
  return tbl
end

function Div(div)
  if not div.classes:includes("fragment-rows") then return nil end
  if not quarto.doc.is_format("revealjs") then return nil end
  return div:walk({ Table = mark_rows })
end
