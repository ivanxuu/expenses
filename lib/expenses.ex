defmodule Expenses do
  @moduledoc """
  Documentation for Expenses.
  """

  @percentages_table Application.get_env(:expenses, :percentages_table)

  alias Expenses.{Calculations, Render}

  @doc """
  Calculate expenses using configured expenses:

      iex> summary("Bungalow Rent": 103, "Telephone Bill": 20) |> IO.puts
          Bungalow Rent:
            Bob(33.33%): 51.50, Alice(66.66%): 51.50
          Telephone Bill:
            Bob(100%): -20

  Returns a string based on a template.
  """
  def summary(expenses_list) when is_list(expenses_list) do
    process_items(expenses_list)
    <> "\n"
    <> process_persons(expenses_list)
  end

  # Returns a list of each item, with how much everyone should pay
  defp process_items(expenses_list) do
    Calculations.process_items(expenses_list, @percentages_table)
    |> Render.expenses_per_item()
  end

  # Returns a list of each person, with how much everyone should pay of each
  # item.
  defp process_persons(expenses_list) do
    Calculations.process_persons(expenses_list, @percentages_table)
    |> Render.expenses_per_person()
  end

  #def markdown(expenses_list) when is_list(expenses_list) do
  #  Calculations.process(expenses_list)
  #  # TODO: Pasar por el template processor
  #end
  #def markdown(expenses_file) when is_binary(expenses_file) do
  #  Calculations.process(expenses_file)
  #  # TODO: Pasar por el template processor
  #end

end
