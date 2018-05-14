defmodule Expenses.Calculations do

  @doc """
      iex> process(["Bungalow Rent": 103, "Telephone Bill": 20], %{
      ...>   "Bungalow Rent" => [bob: 0.33, alice: 0.166],
      ...>   "Telephone Bill" => [bob: -0.33, alice: -0.166],
      ...>   "Car Gas" => [bob: -1]
      ...> })
      [
        {"Bungalow Rent", [{:bob, 0.33, 33.99}, {:alice, 0.166, 17.098000000000003}]},
        {"Telephone Bill", [ {:bob, -0.33, -6.6000000000000005}, {:alice, -0.166, -3.3200000000000003}]}
      ]
  """
  def process(expenses_list, percentages_table) do
    expenses_list
    |>Enum.map(&calculate_amount_item_per_person(&1, percentages_table))
  end

  # calculate_amount_item_per_person({"Bungalow Rent", 103}) do
  # {"Bungalow Rent", [Bob: 51.50, Alice: 51.50]}
  defp calculate_amount_item_per_person({item, total_spent}, percentages_table) do
    with \
      item <- Atom.to_string(item),
      {:ok, percentages} <- get_percentages(item, percentages_table) do
      {item, calculate_amount_per_person(total_spent, percentages)}
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

end
