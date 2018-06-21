pragma solidity ^0.4.18;
//引用待交换币
contract Token {
    bytes32 public standard;          //定义变量standard
    bytes32 public name;              //定义变量name
    bytes32 public symbol;           //定义变量symbol;
    uint256 public totalSupply;    //定义变量totalSupply
    uint8 public decimals;           //定义变量decimals
    bool public allowTransactions;    //定义变量allowTransactions为逻辑变量
    mapping (address => uint256) public balanceOf;     //定义帐户数组
    mapping (address => mapping (address => uint256)) public allowance;     //定义帐户授权帐户可支配数额
    function transfer(address _to, uint _value) public returns (bool success);    //定义转帐函数，返回布尔值
    function approveAndCall(address _spender, uint _value, bytes _extraData) public returns (bool success);   //对指定帐户授信可操作额度
    function approve(address _spender, uint _value) public returns (bool success);   //对指定账户授权可操作额度
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);    //被授权帐户转帐函数，从发送者转到接收者
}
//定义去中心化交易合约
contract Exchange {
//安全乘，需要要么c/a等于b，要么a等于0
  function safeMul(uint a, uint b) internal pure returns (uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
//安全减，需要减数小于或等于被减数
  function safeSub(uint a, uint b) internal pure returns (uint) {
    require(b <= a);
    return a - b;
  }

//安全加，需要和大于加数与被加数
  function safeAdd(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    require(c>=a && c>=b);
    return c;
  }
  address public owner;    //定义合约拥有者为地址类型
  mapping (address => uint256) public invalidOrder;   //定义无效定单的mapping数组
  event SetOwner(address indexed previousOwner, address indexed newOwner);   //定义设置合约拥有者事件
//定义仅能由合约主人修改修饰函数 
 modifier onlyOwner {
    require(msg.sender == owner);
     _;
  }
//合约主人帐户更改
  function setOwner(address newOwner) public onlyOwner {
    SetOwner(owner, newOwner);
    owner = newOwner;
  }
//查询当前合约主人地址
  function getOwner() public constant returns (address out) {
    return owner;
  }
//设置无效定单
  function invalidateOrdersBefore(address user, uint256 nonce) public onlyAdmin {
    if (nonce < invalidOrder[user]) revert();    //如果待定义随机数小于用户已登记随机数，则退出；
    invalidOrder[user] = nonce;    //设置指定用户帐户的无效定单为指定随机数
  }
//定义指定币种的指定帐户的余额数组tokens[币种][帐号]=余额
  mapping (address => mapping (address => uint256)) public tokens; //mapping of token addresses to mapping of account balances
//定义管理账户数组 amins[帐户]=true/false
  mapping (address => bool) public admins;
//定义指定帐户最新活跃交易 lastActiveTransaction[帐户]=最新活跃交易
  mapping (address => uint256) public lastActiveTransaction;
//定义所填写定单的额度  orderFills[定单号]=金额
  mapping (bytes32 => uint256) public orderFills;
 //定义收取手续费的账户地址 
 address public feeAccount;
//定义冻结时间，在该时间内不能撤单，撤单收手续费
  uint256 public inactivityReleasePeriod;
//定义已完成交易清单trades[编号]=true/fase
  mapping (bytes32 => bool) public traded;
//定义是否是外部币种foreignToken[币址]=true/fase
  mapping (address => bool) public foreignToken;
//定义已撤单交易清单withdrawn[编号]=true/false
  mapping (bytes32 => bool) public withdrawn;
//定义挂单事件（待买币种，数量，待卖币种，数量，挂单有效期，随机数，挂单账户，签名v,r,s)
  event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
//定义撤单事件（待买币种，数量，待卖币种，数量，挂单有效期，随机数，挂单账户，签名v,r,s)
  event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
//定义交易事件（待买币种，数量，待卖币种，数量，买家账户，卖家账户)  
event Trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, address get, address give);
//定义存币事件（待存币种，账户，数量，存后余额） 
 event Deposit(address token, address user, uint256 amount, uint256 balance);
//定义外链币提币事件（待提币种，账户，数量，提后余额） 
  event ForeignTokenWithdraw(address token, address user, uint256 amount, uint256 balance);
//定义提币事件（待提币种，账户，数量，提后余额） 
  event Withdraw(address token, address user, uint256 amount, uint256 balance);

//定义冻结时间
  function setInactivityReleasePeriod(uint256 expiry) public onlyAdmin returns (bool success) {
    if (expiry > 1000000) revert();    //若冻结时间超过10余天，则设置无效
    inactivityReleasePeriod = expiry;   //设定冻结时间
    return true;
  }
//构造函数
  function Exchange(address feeAccount_) public {
    owner = msg.sender;    //合约主人为合约创建者
    feeAccount = feeAccount_;    //设置收取手续费合约
    inactivityReleasePeriod = 100000;    // 设置冻结时间超过1天87600秒
  }
//设置管理帐户
  function setAdmin(address admin, bool isAdmin) public onlyOwner {
    admins[admin] = isAdmin;
  }
//定义仅能由管理帐户操作修饰函数
  modifier onlyAdmin {
    if (msg.sender != owner && !admins[msg.sender]) revert();   //如果发送者不是合约主人或管理帐户，则退出
    _;
  }
//不充许外部调用
  function() external {
    revert();
  }
//存币函数（币种，数量）
  function depositToken(address token, uint256 amount) public{
    tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);    //在tokens数组中进行设置 tokens[币种][帐户]=原有额度+存入数量
    lastActiveTransaction[msg.sender] = block.number;   //在最新活跃交易数组中存放当前区块号lastActiveTransaction[帐户]=当前区块号
    if (!Token(token).transferFrom(msg.sender, this, amount)) revert();  //执行转币操作，将待存币从消息调用者账户转入指定数额待存币到交易合约帐户。
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);  //存币事件
  }
//存入外部链币种函数
 function depositForeignToken(address token, uint256 amount,address user) public onlyAdmin{
    tokens[token][user] = safeAdd(tokens[token][user], amount);    //在tokens数组中进行设置 tokens[币种][帐户]=原有额度+存入数量
    lastActiveTransaction[user] = block.number;   //在最新活跃交易数组中存放当前区块号lastActiveTransaction[帐户]=当前区块号
    //设置该币种为外链币种，需用户在外链所部署合约中存入相应数量的外链币
    ForeignToken[token]=true;
    Deposit(token, msg.sender, amount, tokens[token][user]);  //存币事件
  }
//存入基础币函数
  function deposit() public payable {
    tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value);    //token[0地址][账户]=原有余额+新发送金额
    lastActiveTransaction[msg.sender] = block.number;    //lastActiveTransaction[存币帐户]=当前区块号
    Deposit(address(0), msg.sender, msg.value, tokens[address(0)][msg.sender]);  //存币事件
  }
//提币函数（提币币种，数量）
  function withdraw(address token, uint256 amount) public returns (bool success) {
    if (safeSub(block.number, lastActiveTransaction[msg.sender]) < inactivityReleasePeriod) revert();  //条件：当前区块时间减去最新存币时间不得小于冻结时间
    if (tokens[token][msg.sender] < amount) revert();   //条件：用户待提币帐户余额不得小于提币数量
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);  //在tokens数组中将用户待提币帐户余额减去提币数量
    if (token == address(0)) {      //当提币币种为基础币时，从本合约中直接向提币帐户转入指定数量基础币
      if (!msg.sender.send(amount)) revert();
    } else if (foreignToken[token]==true){   //如果是外链币，则仅事件提示，同时在外链合约中执行提币操作
     ForeignTokenWithtraw(token,msg.sender, amount, tokens[token][msg.sender]);
  }else
{   //当为其它代币币种时，从待提币币种本合约帐户转入提币用户帐户指定数额提币币种。
      if (!Token(token).transfer(msg.sender, amount)) revert();
    }
   //提币事件
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
    return true;
  }
//管理帐户提币函数（待提币币种，数量，用户帐户，随机数，签名V，r,s, 手续费），该函数用于提币时间处于冻结期时，由用户通过管理员帐户操作。
  function adminWithdraw(address token, uint256 amount, address user, uint256 nonce, uint8 v, bytes32 r, bytes32 s, uint256 feeWithdrawal) public onlyAdmin returns (bool success) {
    bytes32 hash = keccak256(this, token, amount, user, nonce);   //使用“合约地址，待提币，数量，用户地址，随机数”等数据生成哈希码；
    if (withdrawn[hash]) revert();    //如果该哈希码在提币数组withdrawn中已登记，则退出
    withdrawn[hash] = true;     //在提币数组withdrawn中登记该提币哈希码
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) revert();   //对哈希码进行解码识别是否为指定用户签名，若不是，则退出
    if (feeWithdrawal > 50 finney) feeWithdrawal = 50 finney;     //如果手续费大于50finney，则重置为50finney
    if (tokens[token][user] < amount) revert();   //如果用户待提币余额小于待提数量，则退出
    tokens[token][user] = safeSub(tokens[token][user], amount);   //从数组tokens中对待提币待提账户余额减去指定数量
    tokens[token][feeAccount] = safeAdd(tokens[token][feeAccount], safeMul(feeWithdrawal, amount) / 1 ether);   //在tokens数组中对手续费收取帐户上加入手续费（余额+费率*数量/10**18)
    amount = safeMul((1 ether - feeWithdrawal), amount) / 1 ether;  //提币数量=（10**18-费率）*数量/10**18
    if (token == address(0)) {       //如果是基础币，则直接向提币用户转帐指定数量
      if (!user.send(amount)) revert();
    }else if (foreignToken[token]==true){   //如果是外链币，则仅事件提示，同时在外链合约中执行提币操作
      ForeignTokenWithtraw(token,msg.sender, amount, tokens[token][msg.sender]);
    } else {       //如果是其它代币，则在指定代币从合约帐户向指定用户转帐指定数量
      if (!Token(token).transfer(user, amount)) revert();
    }
//设置当前用户的最新活跃交易数为当前区块数
    lastActiveTransaction[user] = block.number;
//提币事件
    Withdraw(token, user, amount, tokens[token][user]);
    return true;
  }
//返加指定用户指定币种在合约中的存币余额。
  function balanceOf(address token, address user) public constant returns (uint256) {
    return tokens[token][user];
  }
//交易函数（仅能由交易管理员操作）（交易值数组，地址数组，maker和taker的签名V,rs数组）
  function trade(uint256[8] tradeValues, address[4] tradeAddresses, uint8[2] v, bytes32[4] rs) public onlyAdmin returns (bool success) {
    /* amount is in amountBuy terms */
    /* tradeValues     交易值数组定义
       [0] amountBuy        // 待换数量
       [1] amountSell         //待卖数量
       [2] expires              //时效
       [3] nonce             //随机数
       [4] amount           //提供的定单数量（与amountBuy币相同）
       [5] tradeNonce     //交易随机数
       [6] feeMake         //提供交易费
       [7] feeTake          //获取交易费
     tradeAddressses     //交易地址
       [0] tokenBuy       //待买币种
       [1] tokenSell        //待卖币种
       [2] maker           //卖家
       [3] taker             //买家
     */
     //条件：如果买家无效定单中的随机数大于交易值数组所提供的随机数，则退出
    if (invalidOrder[tradeAddresses[2]] > tradeValues[3]) revert();
   //生成卖单哈希码=（本合约地址，待售币种，待售数量，待换币种，待换币量，时效，随机数，卖家）
    bytes32 orderHash = keccak256(this, tradeAddresses[0], tradeValues[0], tradeAddresses[1], tradeValues[1], tradeValues[2], tradeValues[3], tradeAddresses[2]);
  //使用该哈希码及签名数组中的卖家签名数据，进行解签名，若签名地址不为卖家帐户地址，则退出   
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", orderHash), v[0], rs[0], rs[1]) != tradeAddresses[2]) revert();
    //生成交易哈希码=（卖单哈希，待买数量，买家地址，交易随机数）
    bytes32 tradeHash = keccak256(orderHash, tradeValues[4], tradeAddresses[3], tradeValues[5]); 
   //使用该交易哈希码和买家签名，进行解签名，若地址不为买家帐户地址，则退出。
    if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", tradeHash), v[1], rs[2], rs[3]) != tradeAddresses[3]) revert();
   //如果该交易哈希已经执行，则退出
    if (traded[tradeHash]) revert();
   //在交易哈希数组中设置本交易哈希的值为true
    traded[tradeHash] = true;
   //如果所设置的交易费率大于100finney，则交易费率设置为100finney
    if (tradeValues[6] > 100 finney) tradeValues[6] = 100 finney;
  //如果所设置的卖币费率大于100finney，则重置为100finney
    if (tradeValues[7] > 100 finney) tradeValues[7] = 100 finney;
   //如果卖单已卖数量+本次数量>待售总额，则退出（数量不够，则退出）
    if (safeAdd(orderFills[orderHash], tradeValues[4]) > tradeValues[0]) revert();
  //如果买家持有币数量小于定单提供数量，则退出（费用不够，则退出）
    if (tokens[tradeAddresses[0]][tradeAddresses[3]] < tradeValues[4]) revert();
  //如果卖家待售币数量小于（待售数量/待换数量)*定单待买数量，则退出 （存货不够，则退出）
    if (tokens[tradeAddresses[1]][tradeAddresses[2]] < (safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0])) revert();
  //tokens[待换币种][买家]=tokens[待换币种][买家]-定单数量
    tokens[tradeAddresses[0]][tradeAddresses[3]] = safeSub(tokens[tradeAddresses[0]][tradeAddresses[3]], tradeValues[4]);
 //tokens[待换币种][卖家]=tokens[待换币种][卖家]+（定单数量*（10**18-买家费率）/10**18)
    tokens[tradeAddresses[0]][tradeAddresses[2]] = safeAdd(tokens[tradeAddresses[0]][tradeAddresses[2]], safeMul(tradeValues[4], ((1 ether) - tradeValues[6])) / (1 ether));
 //tokens[待换币种][手续费帐户]=tokens[待换币种][手续费帐户]+(定单数量*买家费率）/10**18)  
   tokens[tradeAddresses[0]][feeAccount] = safeAdd(tokens[tradeAddresses[0]][feeAccount], safeMul(tradeValues[4], tradeValues[6]) / (1 ether));
 //tokens[待卖币种][卖家]=tokens[待卖币种][卖家]-(待售数量/待换数量)*定单数量
    tokens[tradeAddresses[1]][tradeAddresses[2]] = safeSub(tokens[tradeAddresses[1]][tradeAddresses[2]], safeMul(tradeValues[1], tradeValues[4]) / tradeValues[0]);
 //tokens[待卖币种][买家]=tokens[待卖币种][买家]+(10**18-卖币费率）*（待售数量/待换数量）*定单数量/10**18
    tokens[tradeAddresses[1]][tradeAddresses[3]] = safeAdd(tokens[tradeAddresses[1]][tradeAddresses[3]], safeMul(safeMul(((1 ether) - tradeValues[7]), tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
  //tokens[待卖币种][手续费帐户]=tokens[待卖币种][手续费帐户]+卖币费率*（待售数量/待换数量）*定单数量/10**18
    tokens[tradeAddresses[1]][feeAccount] = safeAdd(tokens[tradeAddresses[1]][feeAccount], safeMul(safeMul(tradeValues[7], tradeValues[1]), tradeValues[4]) / tradeValues[0] / (1 ether));
  // 在卖单数组中对该卖单已售数量加上本次定单数量
    orderFills[orderHash] = safeAdd(orderFills[orderHash], tradeValues[4]);
  //设置卖家活跃数为当前区块数
    lastActiveTransaction[tradeAddresses[2]] = block.number;
  //设置买家活跃数为当前区块数
    lastActiveTransaction[tradeAddresses[3]] = block.number;
    return true;
  }
}