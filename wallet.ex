defmodule Wallet do
  # Fields : Public key visible to all, Private key only visible to self, initial balance of 100 BTC to begin transaction.
  defstruct publickey: nil, privatekey: nil, balance: 100

  #######################  BITCOIN ADDRESS AND KEY GENERATION  ############################
  # Create wallet

  def create_wallet do
    privatekey_1 = Wallet.create_keys()
    wallet_addr1 = Wallet.create_address(privatekey_1 |> Base.decode16!())
    wallet1 = %Wallet{publickey: wallet_addr1, privatekey: privatekey_1}
    wallet1
  end

  # Create private key for wallet
  def create_keys() do
    {public_key, private_key} = :crypto.generate_key(:ecdh, :secp256k1)
    Base.encode16(private_key)
  end

  # Get public key from private key
  def get_public_key(privkey) do
    {public_key, _} = :crypto.generate_key(:ecdh, :secp256k1, privkey)
    public_key |> Base.encode16()
  end

  # Derive public key from private key and derive bitcoin address for the wallet using reaL Bitcoin algorithm
  def create_address(privkey) do
    {public_key, _} = :crypto.generate_key(:ecdh, :secp256k1, privkey)
    firsthash = :crypto.hash(:sha256, public_key)
    secondhash = :crypto.hash(:ripemd160, firsthash)
    thirdhash = prepend_version_byte(secondhash)
    fourthhash = :crypto.hash(:sha256, thirdhash)
    fifthhash = :crypto.hash(:sha256, fourthhash)
    check = checksum(fifthhash)
    sixthhash = thirdhash <> check
    seventhhash = Encode.call(sixthhash)
  end

  # prepend version byte to hash
  def prepend_version_byte(public_hash) do
    prepended = <<0x00>> |> Kernel.<>(public_hash)
  end

  # generate checksum
  defp checksum(<<checksum::bytes-size(4), _::bits>>), do: checksum

  ########################## SIGNING AND VERIFYING TRANSACTIONS ##########################

  # Sign a transaction using sender's private key
  def signtransaction(privkey, transaction) do
    signature =
      :crypto.sign(:ecdsa, :sha256, Transaction.makestring(transaction), [
        privkey |> Base.decode16!(),
        :secp256k1
      ])
      |> Base.encode16()

    transaction = Map.put(transaction, :signature, signature)
    transaction
  end

  # Verify the transaction by using sender's public key
  def verifytransaction(publickey, transaction) do
    verify =
      :crypto.verify(
        :ecdsa,
        :sha256,
        Transaction.makestring(transaction),
        transaction.signature |> Base.decode16!(),
        [publickey |> Base.decode16!(), :secp256k1]
      )
  end

  # Create a transaction, sign in with private key and send it to public address of another wallet
  def send(wallet1, wallet2address, sendamount, mainblockchain) do
    mainblockchain =
      cond do
        wallet1.balance >= sendamount ->
          createtrans(wallet1, wallet2address, sendamount, mainblockchain)

        true ->
          IO.puts("Not enough balance")
          mainblockchain
      end
  end

  # create a transaction, sign it, add it to list of pending transactions in the blockchain and return this blockchain
  def createtrans(wallet1, wallet2address, sendamount, mainblockchain) do
    transaction1 = %Transaction{
      from: wallet1.publickey,
      to: wallet2address,
      amount: sendamount,
      timestamp: System.system_time(:millisecond)
    }

    transaction1 = Wallet.signtransaction(wallet1.privatekey, transaction1)
    mainblockchain = Blockchain.add_signed_but_pending(mainblockchain, transaction1)
  end

  def getbalance(mainblockchain, walletaddress, original_bal) do
    listofblocks = mainblockchain.blockchain
    size = length(listofblocks)
    transactlist = Enum.at(listofblocks, size - 1).data

    balance =
      for j <- 0..(length(transactlist) - 1) do
        cond do
          Enum.at(transactlist, j).from === walletaddress -> Enum.at(transactlist, j).amount * -1
          Enum.at(transactlist, j).to === walletaddress -> Enum.at(transactlist, j).amount
          true -> 0
        end
      end

    bal = Enum.reduce(balance, original_bal, fn x, acc -> acc + x end)
  end

  # get balance of any wallet address by summing all the transactions it went through so far in the blockchain
  def getbal(mainblockchain, walletaddress) do
    listofblocks = mainblockchain.blockchain
    size = length(listofblocks)
    finalbal = 100 + findbalforblock(listofblocks, 1, size - 1, walletaddress)
  end

  # get balance of a wallet address in a single block in the blockchain
  def findbalforblock(listofblocks, i, numblocks, walletaddress) when i != numblocks do
    transactlist = Enum.at(listofblocks, i).data

    blocksum =
      Enum.reduce(transactlist, 0, fn x, acc ->
        cond do
          x.to == walletaddress -> x.amount + acc
          x.from == walletaddress -> acc - x.amount
          true -> acc
        end
      end)

    ret = blocksum + findbalforblock(listofblocks, i + 1, numblocks, walletaddress)
  end

  # exit condition for recursion
  def findbalforblock(listofblocks, i, numblocks, walletaddress) when i == numblocks do
    transactlist = Enum.at(listofblocks, i).data

    blocksum =
      Enum.reduce(transactlist, 0, fn x, acc ->
        cond do
          x.to == walletaddress -> x.amount + acc
          x.from == walletaddress -> acc - x.amount
          true -> acc
        end
      end)

    blocksum
  end
end
