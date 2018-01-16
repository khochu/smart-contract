# smart-contract

Hedgeable's Authorization Smart Contract

# Testing with Populus
- All changes made to HydroToken.sol must be ported over to HydroTokenTest.sol (Currently populus does not support create contracts with arguments so we must manually set the owner)
- Navigate to the tests folder in command line
- $ populus compile
- $ populus deploy --chain tester --no-wait-for-sync
- $ pytest tests/
