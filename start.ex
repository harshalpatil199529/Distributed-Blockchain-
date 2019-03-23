defmodule Start do
 # def main(args) do
def main do
    numnodes = 100
    handle(numnodes)
    #args |> read_arguments |> handle

  end

  defp read_arguments(args) do
    {_, arguments, _} = OptionParser.parse(args)
    arguments
  end

  def handle([]) do
    IO.puts("Please provide some arguments")
  end

  def handle(arguments) do
    #numnodes = String.to_integer(Enum.at(arguments, 0))
    numnodes = arguments
    numtransact = 15
    Registry.start_link(keys: :unique, name: :hashmap)
    mainblockchain = Blockchain.createchain()
    task = self()

    IO.inspect(task, label: "Task inside ***************************************************")

    for i <- 0..(numnodes - 1) do
      wallet = Wallet.create_wallet()
      pid = spawn(fn -> Bitnode.startnode(i, numnodes, mainblockchain, wallet, task) end)
      Process.monitor(pid)
    end



    finalblockchain = addedtransact(mainblockchain, 0, numtransact, numnodes)

    IO.puts("In Start")
    IO.inspect(finalblockchain)

    for i <- 0..(numnodes - 1) do
      GenServer.cast(Bitnode.findnode(i), {:startmining, finalblockchain})
      # GenServer.cast(Bitnode.findnode(i),{:updateBlockChain,newblockchain})
      # IO.puts "For #{i}"
      # IO.inspect GenServer.call(Bitnode.findnode(i),:getBlockChain)
    end

    Process.sleep(1000)

    wrapper(numnodes * numnodes)

    # for i <- 0..(numnodes - 1) do
    #   IO.puts("Updated blockchain is")

    #   finalchain = GenServer.call(Bitnode.findnode(i), :getBlockChain)
    #   IO.inspect(finalchain)
    # end

    #############################################################################################################

    finalblockchain = GenServer.call(Bitnode.findnode(0), :getBlockChain)

    finalblockchain = addedtransact(finalblockchain, 0, numtransact, numnodes)

    for i <- 0..(numnodes - 1) do
      GenServer.cast(Bitnode.findnode(i), {:startmining, finalblockchain})
      # GenServer.cast(Bitnode.findnode(i),{:updateBlockChain,newblockchain})
      # IO.puts "For #{i}"
      # IO.inspect GenServer.call(Bitnode.findnode(i),:getBlockChain)
    end

    Process.sleep(1000)

    wrapper(numnodes * numnodes)


#############################################################################################################

finalblockchain = GenServer.call(Bitnode.findnode(0), :getBlockChain)

finalblockchain = addedtransact(finalblockchain, 0, numtransact, numnodes)

for i <- 0..(numnodes - 1) do
  GenServer.cast(Bitnode.findnode(i), {:startmining, finalblockchain})
  # GenServer.cast(Bitnode.findnode(i),{:updateBlockChain,newblockchain})
  # IO.puts "For #{i}"
  # IO.inspect GenServer.call(Bitnode.findnode(i),:getBlockChain)
end

Process.sleep(1000)

wrapper(numnodes * numnodes)


#############################################################################################################


finalblockchain = GenServer.call(Bitnode.findnode(0), :getBlockChain)

finalblockchain = addedtransact(finalblockchain, 0, numtransact, numnodes)

for i <- 0..(numnodes - 1) do
  GenServer.cast(Bitnode.findnode(i), {:startmining, finalblockchain})
  # GenServer.cast(Bitnode.findnode(i),{:updateBlockChain,newblockchain})
  # IO.puts "For #{i}"
  # IO.inspect GenServer.call(Bitnode.findnode(i),:getBlockChain)
end

Process.sleep(1000)

wrapper(numnodes * numnodes)


####################################  CODE TO PRINT BALANCE #########################################################################v
bchain = GenServer.call(Bitnode.findnode(0), :getBlockChain)
for i <- 0..(numnodes - 1) do

  wallet = GenServer.call(Bitnode.findnode(i),:getwallet)
  IO.puts "Balance of wallet #{i} is"
  walletbal = Wallet.getbal(bchain,wallet.publickey)
  IO.puts walletbal

  wallet_map=%{nodeID: Integer.to_string(i),bal: Integer.to_string(walletbal)}                                                  #value for phoenix should always be in a map
  BitcoinmineWeb.Endpoint.broadcast!("room:lobby","new_balance",wallet_map)


  wallet_chart=%{usernum: Integer.to_string(i),balfinal: walletbal}                                                  #value for phoenix should always be in a map
  BitcoinmineWeb.Endpoint.broadcast!("room:lobby","new_chart",wallet_chart)
end

####################################################################################################



    for i <- 0..(numnodes - 1) do
      IO.puts("Updated blockchain is")

      finalchain = GenServer.call(Bitnode.findnode(i), :getBlockChain)
      IO.inspect(finalchain)
    end



  end

  def wrapper(numtimes) when numtimes == 1 do
    receive do
      {:fullydone} -> nil
    end
  end

  def wrapper(numtimes) do
    receive do
      {:fullydone} -> nil
    end

    wrapper(numtimes - 1)
  end

  def addedtransact(mainblockchain, number, numtransact, numnodes) when number == numtransact do
    IO.puts("In recurision exit")
    rand_send = :rand.uniform(numnodes) - 1
    wallet_send = GenServer.call(Bitnode.findnode(rand_send), :getwallet)

    rand_recv = :rand.uniform(numnodes) - 1
    wallet_recv = GenServer.call(Bitnode.findnode(rand_recv), :getwallet)

    sendtransaction=%{sender: "From: " <> Integer.to_string(rand_send),receiver: "To: " <> Integer.to_string(rand_recv),value: "Amount: " <> Integer.to_string(10),number: number}                                                  #value for phoenix should always be in a map
    BitcoinmineWeb.Endpoint.broadcast!("room:lobby","new_message",sendtransaction)

    # blockchain  = GenServer.call(Bitnode.findnode(rand_send),:getBlockChain)

    addedblockchain = Wallet.send(wallet_send, wallet_recv.publickey, 10, mainblockchain)



    # Process.sleep(10000)
  end

  def addedtransact(mainblockchain, number, numtransact, numnodes) do
    #IO.puts("In recurision")
    rand_send = :rand.uniform(numnodes) - 1
    wallet_send = GenServer.call(Bitnode.findnode(rand_send), :getwallet)

    rand_recv = :rand.uniform(numnodes) - 1
    wallet_recv = GenServer.call(Bitnode.findnode(rand_recv), :getwallet)

    sendtransaction=%{sender: "From: " <> Integer.to_string(rand_send),receiver: "To: " <> Integer.to_string(rand_recv),value: "Amount: " <> Integer.to_string(10),number: number}
    BitcoinmineWeb.Endpoint.broadcast!("room:lobby","new_message",sendtransaction)

    # blockchain  = GenServer.call(Bitnode.findnode(rand_send),:getBlockChain)

    addedblockchain = Wallet.send(wallet_send, wallet_recv.publickey, 10, mainblockchain)
    addedtransact(addedblockchain, number + 1, numtransact, numnodes)

    # Process.sleep(10000)
  end
end
