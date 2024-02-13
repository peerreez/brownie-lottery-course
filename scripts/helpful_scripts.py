from brownie import network, accounts, config, Contract, MockV3Aggregator, VRFCoordinatorMock, LinkToken, interface
from web3 import Web3


DECIMALS = 8
STARTING_PRICE = Web3.toWei(2000,"ether")
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development","ganache-local"]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork"]

contract_to_mock = {
    "eth_usd_price_feed":  MockV3Aggregator,
    "vrf_coordinator": VRFCoordinatorMock,
    "link_token": LinkToken,
}

def get_account(id=None, index=None):
    if id:
        return accounts.load(id)
    if index:
        return accounts[index]
    if (network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
        ):
        return accounts[0]
    return accounts.add(config["wallets"]["from_key"])

def get_contract(contract_name):
    """
        Toma el address de contrato desde brownie-config, si esta definido. En caso contrario 
        despliega Mocks de ese contrato

        Args:
            contract_name (string)
        Returns:
            brownie.network.contract.ProjectContract: Implementacion mas reciente de este contrato
    """
    contract_type = contract_to_mock[contract_name]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        contract_address = config["networks"][network.show_active()][contract_name]
        contract = Contract.from_abi(contract_type._name, contract_address, contract_type.abi)
    return contract

def deploy_mocks():
    account = get_account()
    MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from":account})
    link_token = LinkToken.deploy({"from":account})
    VRFCoordinatorMock.deploy(link_token.address, {"from":account})
    print("Mocks deployed")

def fund_with_link(contract_address, account=None, link_token=None, amount=100000000000000000):
    account = account if account else get_account()
    link_token = link_token if link_token else get_contract("link_token")
    tx = link_token.transfer(contract_address, amount, {"from": account})
    # link_token_contract = interface.LinkTokenInterface(link_token.address)
    # tx = link_token_contract.transfer(contract_address, amount, {"from": account})
    tx.wait(1)
    print("contract funded!")
    return tx