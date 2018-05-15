defmodule Expenses.Calculations do

  @doc """

      iex> process_items(["Bungalow Rent": {103, [bob: 0.3333, alice: 0.3333, carol: 0.3333]}, "Telephone Bill": -20], %{
      ...>   "Bungalow Rent" => [bob: 0.33, alice: 0.166],
      ...>   "Telephone Bill" => [bob: 0.33, alice: 0.166],
      ...>   "Car Gas" => [bob: 1]
      ...> })
      [
        {"Telephone Bill", -20,[ {:bob, -0.33, -6.6000000000000005}, {:alice, -0.166, -3.3200000000000003}]},
        {"Bungalow Rent", 103, [{:bob, 0.33, 33.99}, {:alice, 0.3333, 33.99}, {:carol, 0.3333, 33.99} ]}
      ]
  """
  def process_items(expenses_list, percentages_table) do
    _process_items(expenses_list, percentages_table, [])
  end
  defp _process_items([{item, {total_spent, force_percentages}}|rest], percentages_table, acc) when is_number(total_spent) do
    percentages_table = Map.put(percentages_table, Atom.to_string(item), force_percentages)
    _process_items([{item, total_spent}|rest], percentages_table, acc)
  end
  defp _process_items([{item, total_spent}|rest], percentages_table, acc) when is_number(total_spent) do
    _process_items(rest,
      percentages_table,
      [calculate_amount_item_per_person({item, total_spent}, percentages_table) | acc])
  end
  defp _process_items([], percentages_table, acc) do
    acc
    |>Enum.sort(fn({_, price_a, _}, {_, price_b, _})-> price_a <= price_b end)
  end

  # calculate_amount_item_per_person({"Bungalow Rent", 103}) do
  # {"Bungalow Rent", [Bob: 51.50, Alice: 51.50]}
  defp calculate_amount_item_per_person({item, total_spent}, percentages_table) do
    with \
      item <- Atom.to_string(item),
      {:ok, percentages} <- get_percentages(item, percentages_table) do
      {item, total_spent, calculate_amount_per_person(total_spent, percentages)}
    end
  end

  # get_percentages("Bungalow Rent")
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

  # calculate_amount_item_per_person(200, bob: 0.33, alice: 0.66)
  # [{"bob", 0.33, 66}, {"alice", 0.66, 132}]
  defp calculate_amount_per_person(total, percentages) do
    Enum.map(percentages, fn({person, percentage})->
      {person, percentage, total * percentage}
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
