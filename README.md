# Hydro Smart Contract
<img src="https://www.hydrogenplatform.com/images/logo_hydro.png">

## Introduction
<p>The Hydro Smart Contract is open source blockchain software developed by <a href="http://www.projecthydro.com">Project Hydro</a>.</p>
<p><a href="https://etherscan.io/address/0x12fb5d5802c3b284761d76c3e723ea913877afba">Hydro Contract Address</a></p></p>

## Documentation
<p>Project Hydro has also created an API to interface with this smart contract:

<a href="https://www.hydrogenplatform.com/docs/hydro/v1/">Hydro API Documentation</a>

## Testing With Populus
- All changes made to HydroToken.sol must be ported over to HydroTokenTest.sol (Currently populus does not support create contracts with arguments so we must manually set the owner)
- Navigate to the tests folder in command line
- $ populus compile
- $ populus deploy --chain tester --no-wait-for-sync
- $ pytest tests/

## Copyright & License
Copyright 2018 The Hydrogen Technology Corporation under the GNU General Public License v3.0.
