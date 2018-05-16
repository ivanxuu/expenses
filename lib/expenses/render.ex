defmodule Expenses.Render do
  require EEx
  EEx.function_from_file :def, :expenses_per_person,
    "lib/expenses/templates/expenses_per_person.eex", [:people_list]
  EEx.function_from_file :def, :expenses_per_item,
    "lib/expenses/templates/expenses_per_item.eex", [:expenses_list]
  defp print_money(%Money{} = money) do
    Money.to_string(money)
  end
  defp print_money(money) when is_number(money) do
    (money/1)
    |>Money.parse!()
    |>Money.to_string()
  end
end
