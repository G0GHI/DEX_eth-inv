from brownie import accounts, config, INVtokenCreator, DEX_eth_inv, network
from scripts.helpfulScripts import get_account
from web3 import Web3

myKeepBalance = Web3.toWei(100000, "ether")


def deploy_DEX_and_tokenCreator():
    account = get_account()
    inv_token = INVtokenCreator.deploy({"from": account})
    dex = DEX_eth_inv.deploy(
        inv_token.address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    tx = inv_token.transfer(
        dex.address, inv_token.totalSupply() - myKeepBalance, {"from": account}
    )
    tx.wait(1)
    print("DEX contract is now supplied with INV tokens.")
    return dex, inv_token


def main():
    deploy_DEX_and_tokenCreator()
