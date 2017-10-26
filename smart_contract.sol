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
    event Authorize(address target, bool authorize); // Event for when an address is authorized to authenticate

    struct authStruct {
        uint value;
        string data;
    }

    struct validStruct {
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
    mapping (address => authStruct) public authStructMap;
    mapping (address => validStruct) public validStructMap;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address centralMiner) {
        balanceOf[msg.sender] = initialSupply * uint256(10 ** 18);              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        if (centralMiner != 0) owner = centralMiner;        // Set the owner of the contract on creation
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        _transfer(msg.sender, _to, _value);
        Transfer(msg.sender, _to, _value);
    }

    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint _value) internal {
        _value = _value * (10 ** 18);
        require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
    }

    function whitelistAddress(address target, bool authorize) onlyOwner {
        whitelist[target] = authorize;
        Authorize(target, authorize);
    }

    /* Function to authenticate user
       Restricted to whitelisted partners */
    function authenticate(address _to, uint256 _value, string data) {
        require(whitelist[msg.sender]);
        _transfer(msg.sender, _to, _value);
        updateAuthStruct(msg.sender, _value, data);
        Authenticate(msg.sender, _to, _value, msg.data);
    }

    function updateAuthStruct(address _sender, uint _value, string data) internal {
        authStructMap[_sender].value = _value;
        authStructMap[_sender].data = data;
    }

    function updateValidStruct(address _sender, uint _value, string data) onlyOwner {
        validStructMap[_sender].value = _value;
        validStructMap[_sender].data = data;
        validStructMap[_sender].timestamp = block.timestamp + 1 days;
    }

    function validateAuthentication(address _sender) public constant returns (bool _isValid) {
        if (authStructMap[_sender].value == validStructMap[_sender].value
        && block.timestamp < validStructMap[_sender].timestamp
        && sha3(authStructMap[_sender].data) == sha3(validStructMap[_sender].data)){
            return true;
        }
        return false;
    }
}