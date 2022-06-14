import pytest
from brownie import RedeemItem, ERC20, accounts

PRICE = 0.01
MIN_LVL = 25
TOTAL_OF_TOKENS = 100

@pytest.fixture(scope="function", autouse=True)
def token():
    return accounts[0].deploy(ERC20, "Test token", "TST", 0, TOTAL_OF_TOKENS)

@pytest.fixture(scope="function", autouse=True)
def item_contract_ok():
    
    # deploy contract
    yield RedeemItem.deploy(MIN_LVL, PRICE, TOTAL_OF_TOKENS, {'from': accounts[0]})

def test_initial_state(item_contract_ok, token):
    
    # check if the constructor of the contract is set up properly
    assert item_contract_ok.price() == PRICE
    assert item_contract_ok.min_lvl() == MIN_LVL
    assert token.balanceOf(accounts[0]) == item_contract_ok.amount_of_tokens()

def test_redeem(item_contract_ok, token):
    
    # Redeem by level test
    item_contract_ok.redeem(25, {'from': accounts[2], 'value': 0})
    assert item_contract_ok.users(accounts[2].address)
    token.transfer(accounts[2].address, 1)
    token.approve(accounts[2].address, 1)
    assert token.balanceOf(accounts[2].address) == 1

    # Redeem by payment test
    item_contract_ok.redeem(10, {'from': accounts[3], 'value': 0.015})
    assert item_contract_ok.users(accounts[3].address)
    token.transfer(accounts[3].address, 1)
    token.approve(accounts[3].address, 1)
    assert token.balanceOf(accounts[3].address) == 1

    # Transfer ownership
    item_contract_ok.transfer(accounts[4].address, {'from': accounts[2]})
    assert item_contract_ok.users(accounts[4].address)
    token.transferFrom(accounts[2].address, accounts[4].address, 1)
    assert token.balanceOf(accounts[2].address) == 0
    assert token.balanceOf(accounts[4].address) == 1
