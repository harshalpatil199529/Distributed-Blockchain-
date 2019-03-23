defmodule Block do
  defstruct index: nil, hash: nil, previousHash: nil, timestamp: nil, data: nil, nonce: 0

  # calculate hash value for a block
  def calchash(block) do
    trans =
      Enum.reduce(block.data, "", fn transaction, acc ->
        acc <>
          transaction.from <>
          transaction.to <>
          Integer.to_string(transaction.amount) <>
          Integer.to_string(transaction.timestamp) <> transaction.signature
      end)

    input =
      Integer.to_string(block.index) <>
        block.previousHash <>
        Integer.to_string(block.timestamp) <> trans <> Integer.to_string(block.nonce)

    blockhash = :crypto.hash(:sha256, input) |> Base.encode16()
    block = Map.put(block, :hash, blockhash)
    block
  end

  # create new block structure based on latest block and nonce found by proof of work
  def createnewblock(datafield, latest_block, newnonce) do
    %Block{
      index: latest_block.index + 1,
      previousHash: latest_block.hash,
      timestamp: System.system_time(:millisecond),
      data: datafield,
      nonce: newnonce
    }
    |> calchash
  end

  # check if block hash is valid and uncorrupted
  def valid?(block) do
    block.hash == calchash(block)
  end

  # verify previoushash
  def valid?(block, prevblock) do
    block.previousHash == prevblock.hash && valid?(block)
  end

  # create genesis block
  def genblock do
    transaction = %Transaction{
      from: "Genesis_sender",
      to: "Genesis_destination",
      amount: 0,
      timestamp: System.system_time(:millisecond)
    }

    %Block{
      index: 0,
      previousHash: "",
      timestamp: System.system_time(:millisecond),
      data: [transaction],
      nonce: 0
    }
    |> calchash
  end
end
