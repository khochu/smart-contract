def test_name(chain):
    hydro, _ = chain.provider.get_or_deploy_contract('HydroToken')

    name = hydro.call().name()
    assert name == 'Hydro'

def test_symbol(chain):
    hydro, _ = chain.provider.get_or_deploy_contract('HydroToken')

    symbol = hydro.call().symbol()
    assert symbol == 'HYDRO'

def test_decimals(chain):
    hydro, _ = chain.provider.get_or_deploy_contract('HydroToken')

    decimals = hydro.call().decimals()
    assert decimals == 18

def test_totalSupply(chain):
    hydro, _ = chain.provider.get_or_deploy_contract('HydroToken')

    supply = hydro.call().totalSupply()
    assert supply == 1000000000000000000000000000

def whitelist(address, hydro, web3, chain):
    set_txn_hash = hydro.transact().whitelistAddress(address, True, 1)
    chain.wait.for_receipt(set_txn_hash)

    whitelist = hydro.call().whitelist(1,address)
    assert whitelist == True

    whitelist = hydro.call().whitelist(2,address)
    assert whitelist == False

def hydroPartnerMap(address, hydro, web3, chain):
    set_txn_hash = hydro.transact().updateHydroMap(address, 5, 1)
    chain.wait.for_receipt(set_txn_hash)

    hydroMap = hydro.call().hydroPartnerMap(1,address)
    assert hydroMap[0] == 5
    assert hydroMap[0] != 4

def authenticate(address, hydro, web3, chain):
    set_txn_hash = hydro.transact().authenticate(5, 'testdata', 1)
    chain.wait.for_receipt(set_txn_hash)

    hydroMap = hydro.call().partnerMap(1,address)
    assert hydroMap[0] == 5
    assert hydroMap[1] == 'testdata'

def test_authenticationProcess(web3, chain):
    hydro, _ = chain.provider.get_or_deploy_contract('HydroToken')

    address = web3.eth.coinbase

    whitelist(address, hydro, web3, chain)

    hydroPartnerMap(address, hydro, web3, chain)

    authenticate(address, hydro, web3, chain)

    authenticated = hydro.call().validateAuthentication(address, 'testdata', 1)
    assert authenticated == True

    authenticated = hydro.call().validateAuthentication(address, 'wrongData', 1)
    assert authenticated == False

    authenticated = hydro.call().validateAuthentication(address, 'testdata', 2)
    assert authenticated == False