defmodule ExpensesTest.CalculationsTest do
  use ExUnit.Case

  alias Expenses.Calculations

  #  doctest Expenses.Calculations, import: true
  test "force some percentages" do
    assert Calculations.process_items(["Bungalow Rent": {103, [bob: 0.3333, alice: 0.3333, carol: 0.3333]}, "Telephone Bill": -20], %{
      "Bungalow Rent" => [bob: 0.33, alice: 0.166],
      "Telephone Bill" => [bob: 0.33, alice: 0.166],
      "Car Gas" => [bob: 1]
    }) === [
        {"Telephone Bill", -20,[ {:bob, -0.33, -6.6000000000000005}, {:alice, -0.166, -3.3200000000000003}]},
        {"Bungalow Rent", 103, [{:bob, 0.33, 33.99}, {:alice, 0.3333, 33.99}, {:carol, 0.3333, 33.99} ]}
      ]
  end
end
