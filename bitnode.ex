defmodule Bitnode do
  use GenServer

  def startnode(i, numnodes, mainblockchain, wallet, task) do
    pid =
      GenServer.start_link(__MODULE__, [i, mainblockchain, wallet, task, numnodes],
        name: register_node(i)
      )
  end

  def init([name, blockChain, wallet, task, numnodes]) do
    # task = Task.start fn -> helper(name,numnodes,wallet) end
    IO.puts("In INIT of #{name}")
    {:ok, {name, blockChain, wallet, task, numnodes}}
  end

  def helper(name, numnodes, wallet, blockchain) do
    IO.puts("Helper called #{name}")
    # Process.sleep(1000)
    # blockChain  = GenServer.call(Bitnode.findnode(name),:getBlockChain)
    # IO.puts("\n\n\n============= Pending list ===========================================\n\n\n")
    # IO.inspect(Map.get(blockchain, :pending))
    # # IO.inspect(blockchain)
    # IO.puts("\n\n\n========================================================\n\n\n")
    # TODO Figure out why blockchain is coming as a list of maps
    if length(Map.get(blockchain, :pending)) > 0 do
      IO.puts("Starting mining task now")
      task = Task.start(fn -> Blockchain.minepending(name, blockchain, wallet, numnodes) end)
      # else
      #   helper(name,numnodes,wallet,blockchain)
    end
  end

  def handle_cast({:done, latestchain}, state) do
    {name, mychain, wallet, task, numnodes} = state
    # IO.puts "Length of my chain is"
    # IO.inspect length(mychain.blockchain)
    # IO.puts "Length of latest is"
    # IO.inspect length(latestchain.blockchain)

    mylastblock = List.last(mychain.blockchain)
    gotlastblock = List.last(latestchain.blockchain)

    finalchain =
      if(mylastblock.index == gotlastblock.index) do
        chain =
          if(mylastblock.timestamp > gotlastblock.timestamp) do
            latestchain
          else
            mychain
          end

        chain
      else
        latestchain
      end

    IO.inspect(task, label: "Task inside #################################")
    send(task, {:fullydone})
    # Task.start fn -> helper(name,numnodes,wallet) end
    {:noreply, {name, finalchain, wallet, task, numnodes}}
  end

  def handle_cast({:startmining, blockchain}, state) do
    {name, blockChain, wallet, task, numnodes} = state
    IO.puts("Started mining")
    Task.start(fn -> helper(name, numnodes, wallet, blockchain) end)
    {:noreply, {name, blockchain, wallet, task, numnodes}}
  end

  defp register_node(nid) do
    {:via, Registry, {:hashmap, nid}}
  end

  def handle_call(:latest_block, _from, state) do
    {_, blockChain, _, _, _} = state
    prevblock = List.last(blockChain.blockchain)
    {:reply, prevblock, state}
  end

  def handle_call({:clearpending, updatedchain}, _from, state) do
    {name, _, wallet, task, numnodes} = state
    latestchain = Map.put(updatedchain, :pending, [])
    {:reply, latestchain, {name, latestchain, wallet, task, numnodes}}
  end

  def handle_call(:getnumnodes, _from, state) do
    {_, _, _, _, numnodes} = state
    {:reply, numnodes, state}
  end

  def handle_call(:getwallet, _from, state) do
    {_, _, wallet, _, _} = state
    {:reply, wallet, state}
  end

  def handle_call(:get_task, _from, state) do
    {_, _, _, taskid, _} = state
    {:reply, taskid, state}
  end

  def handle_call({:updateBlockChain, new_blockChain}, _from, state) do
    {name, _, wallet, task, numnodes} = state
    {:reply, :ok, {name, new_blockChain, wallet, task, numnodes}}
  end

  def handle_cast({:updateBlockChain, new_blockChain}, state) do
    {name, _, wallet, task, numnodes} = state
    {:noreply, {name, new_blockChain, wallet, task, numnodes}}
  end

  def handle_call({:updatestate, task}, _from, state) do
    {name, blockchain, wallet, _, numnodes} = state
    {:reply, :ok, {name, blockchain, wallet, task, numnodes}}
  end

  def handle_call(:getBlockChain, _from, state) do
    {_, blockChain, _, _, _} = state
    {:reply, blockChain, state}
  end

  def findnode(nid) do
    ret = Registry.lookup(:hashmap, nid)
    val = handle(ret)
    val
  end

  def handle([{pid, _}]) do
    pid
  end

  def handle([]) do
    nil
  end

  def findlatest(i) do
    GenServer.call(findnode(i), :latest_block)
  end
end
