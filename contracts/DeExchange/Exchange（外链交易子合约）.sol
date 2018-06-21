pragma solidity ^0.4.18;
//引用待交换币
contract Token {
    function transfer(address _to, uint _value) public returns (bool success);    //定义转帐函数，返回布尔值
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);    //被授权帐户转帐函数，从发送者转到接收者
}
//定义去中心化交易合约
contract Exchange {
  address public owner;    //定义合约拥有者为地址类型
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
//定义管理账户数组 amins[帐户]=true/false
  mapping (address => bool) public admins;
//定义存币事件（待存币种，账户，数量，存后余额） 
 event Deposit(address token, address user, uint256 amount, uint256 balance);
//定义提币事件（待提币种，账户，数量，提后余额） 
  event Withdraw(address token, address user, uint256 amount, uint256 balance);
//构造函数
  function Exchange(address feeAccount_) public {
    owner = msg.sender;    //合约主人为合约创建者
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
    if (!Token(token).transferFrom(msg.sender, this, amount)) revert();  //执行转币操作，将待存币从消息调用者账户转入指定数额待存币到交易合约帐户。
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);  //存币事件
  }
//存入基础币函数
  function deposit() public payable {
     Deposit(address(0), msg.sender, msg.value, tokens[address(0)][msg.sender]);  //存币事件
  }
//提币函数（提币币种，数量）
  function withdraw(address token, uint256 amount,user) public onlyAdmin returns (bool success) {
     if (token == address(0)) {      //当提币币种为基础币时，从本合约中直接向提币帐户转入指定数量基础币
      if (!user.send(amount)) revert();
    } else
    {   //当为其它代币币种时，从待提币币种本合约帐户转入提币用户帐户指定数额提币币种。
      if (!Token(token).transfer(user, amount)) revert();
     }
   //提币事件
    Withdraw(token, user, amount, tokens[token][user]);
    return true;
   }
}