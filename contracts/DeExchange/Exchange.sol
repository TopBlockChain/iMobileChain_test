pragma solidity ^0.4.18;

contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint _value) public returns (bool success);
    function approveAndCall(address _spender, uint _value, bytes _extraData) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Exchange {
  function safeMul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }

  function safeSub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c>=a && c>=b);
    return c;
  }
  address public owner;
  mapping (address => uint256) public invalidOrder;
  event SetOwner(address indexed previousOwner, address indexed newOwner);
  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }
  function setOwner(address newOwner) public onlyOwner {
    SetOwner(owner, newOwner);
    owner = newOwner;
  }
  function getOwner() public constant returns (address out) {
    return owner;
  }
  function invalidateOrdersBefore(address user, uint256 nonce) public onlyAdmin {
    if (nonce < invalidOrder[user]) revert();
    invalidOrder[user] = nonce;
  }

  mapping (address => mapping (address => uint256)) public tokens; //mapping of token addresses to mapping of account balances

  mapping (address => bool) public admins;
  mapping (address => uint256) public lastActiveTransaction;
  mapping (bytes32 => uint256) public orderFills;
  address public feeAccount;
  uint256 public inactivityReleasePeriod;
  mapping (bytes32 => bool) public traded;
  mapping (bytes32 => bool) public withdrawn;
  event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, address get, address give);
  event Deposit(address token, address user, uint256 amount, uint256 balance);
  event Withdraw(address token, address user, uint256 amount, uint256 balance);

  function setInactivityReleasePeriod(uint256 expiry) public onlyAdmin returns (bool success) {
    if (expiry > 1000000) revert();
    inactivityReleasePeriod = expiry;
    return true;
  }

  function Exchange(address feeAccount_) public {
    owner = msg.sender;
    feeAccount = feeAccount_;
    inactivityReleasePeriod = 100000;
  }

  function setAdmin(address admin, bool isAdmin) public onlyOwner {
    admins[admin] = isAdmin;
  }

  modifier onlyAdmin {
    if (msg.sender != owner && !admins[msg.sender]) revert();
    _;
  }

  function() external {
    revert();
  }

  function depositToken(address token, uint256 amount) public{
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
    lastActiveTransaction[msg.sender] = block.number;
    if (!Token(token).transferFrom(msg.sender, this, amount)) revert();
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function deposit() public payable {
    tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value);
    lastActiveTransaction[msg.sender] = block.number;
    Deposit(address(0), msg.sender, msg.value, tokens[address(0)][msg.sender]);
  }

  function withdraw(address token, uint256 amount) public returns (bool success) {
    if (safeSub(block.number, lastActiveTransaction[msg.sender]) < inactivityReleasePeriod) revert();
    if (tokens[token][msg.sender] < amount) revert();
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
    if (token == address(0)) {
      if (!msg.sender.send(amount)) revert();
    } else {
      if (!Token(token).transfer(msg.sender, amount)) revert();
    }
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
    return true;
  }

  function adminWithdraw(address token, uint256 amount, address user, uint256 nonce, uint8 v, bytes32 r, bytes32 s, uint256 feeWithdrawal) public onlyAdmin returns (bool success) {
    bytes32 hash = keccak256(this, token, amount, user, nonce);
    if (withdrawn[hash]) revert();
    withdrawn[hash] = true;
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) revert();
    if (feeWithdrawal > 50 finney) feeWithdrawal = 50 finney;
    if (tokens[token][user] < amount) revert();
    tokens[token][user] = safeSub(tokens[token][user], amount);
    tokens[token][feeAccount] = safeAdd(tokens[token][feeAccount], safeMul(feeWithdrawal, amount) / 1 ether);
    amount = safeMul((1 ether - feeWithdrawal), amount) / 1 ether;
    if (token == address(0)) {
      if (!user.send(amount)) revert();
    } else {
      if (!Token(token).transfer(user, amount)) revert();
    }
    lastActiveTransaction[user] = block.number;
    Withdraw(token, user, amount, tokens[token][user]);
    return true;
  }

  function balanceOf(address token, address user) public constant returns (uint256) {
    return tokens[token][user];
  }

  function trade(uint256[8] tradeValues, address[4] tradeAddresses, uint8[2] v, bytes32[4] rs) public onlyAdmin returns (bool success) {
    /* amount is in amountBuy terms */
    /* tradeValues
       [0] amountBuy
       [1] amountSell
       [2] expires
       [3] nonce
       [4] amount
       [5] tradeNonce
       [6] feeMake
       [7] feeTake
     tradeAddressses
       [0] tokenBuy
       [1] tokenSell
       [2] maker
       [3] taker
     */
    if (invalidOrder[tradeAddresses[2]] > tradeValues[3]) revert();
    bytes32 orderHash = keccak256(this, tradeAddresses[0], tradeValues[0], tradeAddresses[1], tradeValues[1], tradeValues[2], tradeValues[3], tradeAddresses[2]);
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", orderHash), v[0], rs[0], rs[1]) != tradeAddresses[2]) revert();
    bytes32 tradeHash = keccak256(orderHash, tradeValues[4], tradeAddresses[3], tradeValues[5]); 
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", tradeHash), v[1], rs[2], rs[3]) != tradeAddresses[3]) revert();
    if (traded[tradeHash]) revert();
    traded[tradeHash] = true;
    if (tradeValues[6] > 100 finney) tradeValues[6] = 100 finney;
    if (tradeValues[7] > 100 finney) tradeValues[7] = 100 finney;
    if (safeAdd(orderFills[orderHash], tradeValues[4]) > tradeValues[0]) revert();
    if (tokens[tradeAddresses[0]][tradeAddresses[3]] < tradeValues[4]) revert();
    if (tokens[tradeAddresses[1]][tradeAddresses[2]] < (safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0])) revert();
    tokens[tradeAddresses[0]][tradeAddresses[3]] = safeSub(tokens[tradeAddresses[0]][tradeAddresses[3]], tradeValues[4]);
    tokens[tradeAddresses[0]][tradeAddresses[2]] = safeAdd(tokens[tradeAddresses[0]][tradeAddresses[2]], safeMul(tradeValues[4], ((1 ether) - tradeValues[6])) / (1 ether));
    tokens[tradeAddresses[0]][feeAccount] = safeAdd(tokens[tradeAddresses[0]][feeAccount], safeMul(tradeValues[4], tradeValues[6]) / (1 ether));
    tokens[tradeAddresses[1]][tradeAddresses[2]] = safeSub(tokens[tradeAddresses[1]][tradeAddresses[2]], safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0]);
    tokens[tradeAddresses[1]][tradeAddresses[3]] = safeAdd(tokens[tradeAddresses[1]][tradeAddresses[3]], safeMul(safeMul(((1 ether) - tradeValues[7]), tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
    tokens[tradeAddresses[1]][feeAccount] = safeAdd(tokens[tradeAddresses[1]][feeAccount], safeMul(safeMul(tradeValues[7], tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
    orderFills[orderHash] = safeAdd(orderFills[orderHash], tradeValues[4]);
    lastActiveTransaction[tradeAddresses[2]] = block.number;
    lastActiveTransaction[tradeAddresses[3]] = block.number;
    return true;
  }
}