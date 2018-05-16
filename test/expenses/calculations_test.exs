defmodule ExpensesTest.CalculationsTest do
  use ExUnit.Case

  alias Expenses.Calculations

  #  doctest Expenses.Calculations, import: true
  test "force some percentages" do
    assert Calculations.process_items([
        "Bungalow Rent": {103, [bob: 0.3333, alice: 0.3333, carol: 0.3333]},
        "Telephone Bill": -20],
      %{
        "Bungalow Rent" => [bob: 0.33, alice: 0.166],
        "Telephone Bill" => [bob: 0.33, alice: 0.166],
        "Car Gas" => [bob: 1]
      }) === 
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
  end

  test "Expenses are ordered by quantity" do
    assert Calculations.process_items([
      "cost": -1, "expensive": -10, "save": 5
      ],
      %{
        "cost" => [bob: 0.33, alice: 0.166],
        "expensive" => [bob: 0.33, alice: 0.166],
        "save" => [bob: 0.33, alice: 0.166]
      })
      |> Enum.map(fn({item, amount, _pay_each})-> {item, amount} end)
      === [{"expensive", -10}, {"cost", -1}, {"save", 5}]
  end
end
