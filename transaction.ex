defmodule Transaction do
  defstruct from: nil, to: nil, amount: nil, timestamp: nil, signature: ""

  # Calculate string form of Transaction for hashing
  def makestring(transaction) do
    transaction.from <>
      transaction.to <>
      Integer.to_string(transaction.amount) <> Integer.to_string(transaction.timestamp)
  end
end
