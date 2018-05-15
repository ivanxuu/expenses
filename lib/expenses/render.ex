defmodule Expenses.Render do
  require EEx
  EEx.function_from_file :def, :expenses_per_person,
    "lib/expenses/templates/expenses_per_person.eex", [:people_list]
  EEx.function_from_file :def, :expenses_per_item,
    "lib/expenses/templates/expenses_per_item.eex", [:expenses_list]
end
