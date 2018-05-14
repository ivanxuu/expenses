use Mix.Config

# The expenses table contains all the typicall expenses with what quantity each
# person should pay.
#
# Access this configuration in your application as:
#
#     Application.get_env(:expenses, :percentages_table)
config :expenses, percentages_table: %{
  "Bungalow Rent" => [bob: 0.33, alice: 0.166],
  "Telephone bill" => [bob: -0.33, alice: -0.166],
  "Car Gas" => [bob: -1]
}
