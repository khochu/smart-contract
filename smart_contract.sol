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

contract basicToken {
    function balanceOf(address) constant returns (uint256) {}
    function transfer(address, uint256) returns (bool) {}
    function transferFrom(address, address, uint256) returns (bool) {}
    function approve(address, uint256) returns (bool) {}
    function allowance(address, address) constant returns (uint256) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20Standard is basicToken{

    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) public balances;

    /* Send coins */
    function transfer(address _to, uint256 _value) returns (bool success){
        require (_to != 0x0);                               // Prevent transfer to 0x0 address
        require (balances[msg.sender] > _value);            // Check if the sender has enough
        require (balances[_to] + _value > balances[_to]);   // Check for overflows
        _transfer(msg.sender, _to, _value);                 // Perform actually transfer
        Transfer(msg.sender, _to, _value);                  // Trigger Transfer event
        return true;
    }

    /* Use admin powers to send from a users account */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
        require (_to != 0x0);                               // Prevent transfer to 0x0 address
        require (balances[msg.sender] > _value);            // Check if the sender has enough
        require (balances[_to] + _value > balances[_to]);   // Check for overflows
        require (allowed[_from][msg.sender] >= _value);     // Only allow if sender is allowed to do this
        _transfer(msg.sender, _to, _value);                 // Perform actually transfer
        Transfer(msg.sender, _to, _value);                  // Trigger Transfer event
        return true;
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        balances[_from] -= _value;                          // Subtract from the sender
        balances[_to] += _value;                            // Add the same to the recipient
    }

    /* Get balance of an account */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* Approve an address to have admin power to use transferFrom */
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}

contract HydroToken is ERC20Standard, owned{
    event Authenticate(address indexed from, uint256 value, bytes data);     // Event for when an address is authenticated
    event Whitelist(address target, bool whitelist);                         // Event for when an address is whitelisted to authenticate
    event Burn(address indexed burner, uint256 value);                       // Event for when tokens are burned

    struct partnerValues {
        uint value;
        string data;
    }

    struct hydrogenValues {
        uint value;
        string data;
        uint timestamp;
    }

    string public name = "Hydro Token";
    string public symbol = "H2O";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    /* This creates an array of all whitelisted addresses
     * Must be whitelisted to be able to utilize auth
     */
    mapping (address => bool) public whitelist;
    mapping (address => partnerValues) public partnerValuesMap;
    mapping (address => hydrogenValues) public hydrogenValuesMap;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function HydroToken(address ownerAddress) {
        totalSupply = 10**9 * 10**18;
        balances[msg.sender] = totalSupply;                 // Give the creator all initial tokens
        if (ownerAddress != 0) owner = ownerAddress;        // Set the owner of the contract on creation
    }

    /* Function to whitelist partner address. Can only be called by owner */
    function whitelistAddress(address target, bool whitelistBool) onlyOwner {
        whitelist[target] = whitelistBool;
        Whitelist(target, whitelistBool);
    }

    /* Function to authenticate user
       Restricted to whitelisted partners */
    function authenticate(uint256 _value, string data) {
        require(whitelist[msg.sender]);                    // Make sure the sender is whitelisted
        require(balances[msg.sender] > _value);            // Check if the sender has enough
        require(hydrogenValuesMap[msg.sender].value == _value)
        burn(msg.sender, _value);
        updatePartnerValuesMap(msg.sender, _value, data);
        Authenticate(msg.sender, _value, msg.data);
    }

    function burn(address burner, uint256 _value) internal {
        balances[burner] -= _value;
        totalSupply -= _value;
        Burn(burner, _value);
    }

    /* Function to update the partnerValuesMap with their amount and challenge string */
    function updatePartnerValuesMap(address _sender, uint _value, string data) internal {
        partnerValuesMap[_sender].value = _value;
        partnerValuesMap[_sender].data = data;
    }

    /* Function to update the hydrogenValuesMap. Called exclusively from the Hedgeable API */
    function updateHydrogenValuesMap(address _sender, uint _value, string data) onlyOwner {
        hydrogenValuesMap[_sender].value = _value;
        hydrogenValuesMap[_sender].data = data;
        hydrogenValuesMap[_sender].timestamp = block.timestamp + 1 days;
    }

    /* Function called by Hydrogen API to check if the partner has validated
     * The partners value and data must match and it must be less than a day since the last authentication
     */
    function validateAuthentication(address _sender) public constant returns (bool _isValid) {
        if (partnerValuesMap[_sender].value == hydrogenValuesMap[_sender].value
        && block.timestamp < hydrogenValuesMap[_sender].timestamp
        && sha3(partnerValuesMap[_sender].data) == sha3(hydrogenValuesMap[_sender].data)){
            return true;
        }
        return false;
    }
}