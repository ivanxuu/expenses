defmodule Expenses.Calculations do

  @doc """

      iex> process_items(["Bungalow Rent": {103, [bob: 0.3333, alice: 0.3333, carol: 0.3333]}, "Telephone Bill": -20], %{
      ...>   "Bungalow Rent" => [bob: 0.33, alice: 0.166],
      ...>   "Telephone Bill" => [bob: 0.33, alice: 0.166],
      ...>   "Car Gas" => [bob: 1]
      ...> })
      [
        {"Telephone Bill", -20, [
          {:bob,    0.33,   %Money{amount: -660, currency: :EUR}},
          {:alice,  0.166,  %Money{amount: -332, currency: :EUR}}
        ]},
        {"Bungalow Rent", 103, [
          {:bob,    0.3333, %Money{amount: 3433, currency: :EUR}},
          {:alice,  0.3333, %Money{amount: 3433, currency: :EUR}},
          {:carol,  0.3333, %Money{amount: 3433, currency: :EUR}}
        ]}
      ]
  """
  def process_items(expenses_list, percentages_table) do
    _process_items(expenses_list, percentages_table, [])
  end
  # The item includes some custom percentages of how much every person should
  # pay.
  defp _process_items([{item, {total_spent, force_percentages}}|rest],
      percentages_table, acc)
      when is_number(total_spent) do
    #Update percentages table with custom percents and add the item
    percentages_table = percentages_table
                        |>Map.put(Atom.to_string(item), force_percentages)
    _process_items([{item, total_spent}|rest], percentages_table, acc)
  end
  # Base call
  defp _process_items([{item, total_spent}|rest], percentages_table, acc)
      when is_number(total_spent) do
    _process_items(rest,
      percentages_table,
      [calculate_amount_item_per_person({item, total_spent}, percentages_table) | acc])
  end
  # Finish call. Order all items.
  defp _process_items([], _percentages_table, acc) do
    acc
    |>Enum.sort(fn({_, price_a, _}, {_, price_b, _})->
        price_a <= price_b
      end)
  end

  # iex> calculate_amount_item_per_person({"Bungalow Rent", 103},
  # ...>   %{"Bungalow Rent"=> [bob: 0.5, alice: 0.5]})
  # {"Bungalow Rent", [bob: 51.50, alice: 51.50]}
  defp calculate_amount_item_per_person({item, total_spent}, percentages_table) do
    with \
      item <- Atom.to_string(item),
      {:ok, item_percentages} <- get_percentages(item, percentages_table),
      amount_per_person <-
           calculate_amount_per_person(total_spent, item_percentages) do
      {item, total_spent, amount_per_person}
    end
  end

  # iex> get_percentages("Bungalow Rent",
  # ...>   %{"Bungalow Rent"=> [bob: 0.5, alice: 0.5]})
  # [bob: 0.33, alice: 0.166],
  defp get_percentages(item, percentages_table) when is_binary(item) do
    percentages_table
    |>Map.get(item)
    |>case do
        nil -> {:error, "Expense #{item} not found. Add it to "<>
          "'config/expenses.exs' like '\"#{item}\" => "<>
          "[bob: 0.3333, alice: 0.6666]'"}
        percentages when is_list(percentages) -> {:ok, percentages}
      end
  end

  # iex> calculate_amount_item_per_person(200, bob: 0.33, alice: 0.66)
  # [{"bob", 0.33, 66}, {"alice", 0.66, 132}]
  defp calculate_amount_per_person(total, percentages) when is_number(total) do
    Enum.map(percentages, fn({person, percentage})->
      with \
        {:ok, total_money} <- Money.parse(total/1),
        pay_pers_money <- Money.multiply(total_money, percentage)
      do
        {person, percentage, pay_pers_money}
      end
    end)
  end

  # Expenses.process("Bungalow Rent": 103, "Telephone bill": 20)
  #   %{bob: [
  #       {"Bungalow Rent", 0.33, -6.6},
  #     ], alice: [
  #       {" Bungalow Rent", 0.166, -3.2}
  #     ]},
  @doc """
      iex> process_persons(["Bungalow Rent": 103, "Telephone Bill": -20], %{
      ...>   "Bungalow Rent" => [bob: 0.3333, alice: 0.6666],
      ...>   "Telephone Bill" => [bob: 0.3333, alice: 0.6666],
      ...>   "Car Gas" => [bob: 1]
      ...> })
      %{
        alice: [
          {"Bungalow Rent", 0.6666, 68.65979999999999},
          {"Telephone Bill", 0.6666, -13.331999999999999}
        ],
        bob: [
          {"Bungalow Rent", 0.3333, 34.329899999999995},
          {"Telephone Bill", 0.3333, -6.6659999999999995}
        ]
      }
  """
  def process_persons(expenses_list, percentages_table) do
    items_list = process_items(expenses_list, percentages_table)
    for {item, total_amount, each_person} <- items_list do
      for {person, percentage, pay_person} <- each_person do
        {item, total_amount, person, percentage, pay_person}
      end
    end
    |>List.flatten()
    |>Enum.reduce(%{}, fn({item, _total_amount, person, percentage, pay_person}, acc)->
        update_in(acc, [person], fn(other_expenses)->
          [{item, percentage, pay_person}] ++ (other_expenses || [])
        end)
      end)
  end

end
