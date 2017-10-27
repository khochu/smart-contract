pragma solidity ^0.4.15;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract MyToken is owned{
    event Transfer(address indexed from, address indexed to, uint256 value); // Event for a normal transfer of funds
    event Authenticate(address indexed from, address indexed to, uint256 value, bytes data); // Event for when an address is authenticated
    event Whitelist(address target, bool whitelist); // Event for when an address is whitelisted to authenticate

    struct partnerValues {
        uint value;
        string data;
    }

    struct hedgeableValues {
        uint value;
        string data;
        uint timestamp;
    }

    string public name;
    string public symbol;
    uint8 public decimals;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    /* This creates an array of all whitelisted addresses */
    mapping (address => bool) public whitelist;
    mapping (address => partnerValues) public partnerValuesMap;
    mapping (address => hedgeableValues) public hedgeableValuesMap;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address ownerAddr) {
        balanceOf[msg.sender] = initialSupply * uint256(10 ** 18);              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        if (ownerAddr != 0) owner = ownerAddr;              // Set the owner of the contract on creation
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        _value = _value * (10 ** 18);
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value);
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
    }

    /* Function to whitelist partner address. Can only be called by owner */
    function whitelistAddress(address target, bool whitelistBool) onlyOwner {
        whitelist[target] = whitelistBool;
        Whitelist(target, whitelistBool);
    }

    /* Function to authenticate user
       Restricted to whitelisted partners */
    function authenticate(address _to, uint256 _value, string data) {
        require(whitelist[msg.sender]);                     // Make sure the sender is whitelisted
        _value = _value * (10 ** 18);                       // Adjust for decimals
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        _transfer(msg.sender, _to, _value);
        updatePartnerValuesMap(msg.sender, _value, data);
        Authenticate(msg.sender, _to, _value, msg.data);
    }

    /* Function to update the partnerValuesMap with their amount and challenge string */
    function updatePartnerValuesMap(address _sender, uint _value, string data) internal {
        partnerValuesMap[_sender].value = _value;
        partnerValuesMap[_sender].data = data;
    }

    /* Function to update the hedgeableValuesMap. Called exclusively from the Hedgeable API */
    function updateHedgeableValuesMap(address _sender, uint _value, string data) onlyOwner {
        hedgeableValuesMap[_sender].value = _value;
        hedgeableValuesMap[_sender].data = data;
        hedgeableValuesMap[_sender].timestamp = block.timestamp + 1 days;
    }

    /* Function called by Hedgeable API to check if the partner has validated
       The partners value and data must match and it must be less than a day since the last authentication */
    function validateAuthentication(address _sender) public constant returns (bool _isValid) {
        if (partnerValuesMap[_sender].value == hedgeableValuesMap[_sender].value
        && block.timestamp < hedgeableValuesMap[_sender].timestamp
        && sha3(partnerValuesMap[_sender].data) == sha3(hedgeableValuesMap[_sender].data)){
            return true;
        }
        return false;
    }
}