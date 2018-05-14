defmodule ExpensesTest do
  use ExUnit.Case
  doctest Expenses

  test "greets the world" do
    assert Expenses.hello() == :world
  end
end
