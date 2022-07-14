from brownie import accounts, config, INVtokenCreator, DEX_eth_inv
from helpfulScripts import get_account


def deploy_DEX_and_tokenCreator():
    account = get_account(0)
    inv_token = INVtokeCreator.deploy({"from": account})
    dex = DEX_eth_inv.deploy(inv_token.address, {"from": account})


def main():
    deploy_DEX_and_tokenCreator()
