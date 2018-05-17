defmodule Expenses.Render do
  require EEx
  import Expenses.Gettext

  EEx.function_from_file :def, :expenses_per_person,
    "lib/expenses/templates/expenses_per_person.eex", [:people_list]
  EEx.function_from_file :def, :expenses_per_item,
    "lib/expenses/templates/expenses_per_item.eex", [:expenses_list]

    #defdelegate t(backend, msgid, bindings \\ %{}), to: Expenses.Gettext, as: :gettext
    #def t(backend, msgid, bindings \\ %{}) do
    #deExpenses.Gettext.gettext(backend, msgid, bindings)
  #ded

  defp print_money(%Money{} = money) do
    Money.to_string(money)
  end
  defp print_money(money) when is_number(money) do
    (money/1)
    |>Money.parse!()
    |>Money.to_string()
  end
end
