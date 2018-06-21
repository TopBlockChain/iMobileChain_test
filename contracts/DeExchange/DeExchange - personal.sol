/*原理：1、卖家选定数字资产的代币，在交易智能合约登记待售数量、价格，挂单，智能合约调用save存入函数将资产转到智能合约帐户上；2、买家查询到卖单后，直接对卖单操作，按照卖单确定的价格，定义数量，向智能合约发送交易，智能合约收到后，将相应数量资产转到买家帐户，将资金发送到卖家帐户，根据所售数量对卖单数据进行减额或删除。3、卖家若要撤回卖单，直接将交易号及代币名发给智能合约，智能合约验证后，直接将卖单资产所有权转回卖家帐户，并在卖单数组中清除该卖单。*/
pragma solidity ^0.4.18;

interface TokenERC20{
      function transfer(address _to,uint256 _value) public;
      function save(address _to,uint256 _value) public;
} 

contract DeExChange{
    //ExChange things' Information. 定义待交换物品数据结构
    struct ExThingInfo {
          address owner; //the owner's account. 所有者帐号
          TokenERC20 Token;  //the wishing to exchange thing's  token address  待交易物品代币合约地址
          uint256 token_num; //the amount of withing to exchange thiing 待交换物品数量
          uint256 price;  //the price of the things per unit 物品单价
          string AttachInfo; //additional information 备注或附加信息。
        }
  uint public SalesNum;    //挂单数量
 address public Manager; //定义管理员  
//uint public decimals=18;
  mapping(uint=>ExThingInfo)  public Sales; //定义挂单数组
  TokenERC20  ExChToken;   //设置对象为代币合约
 //构造函数，定义管理员
function DeExChange(
         ) public {
        manager=msg.sender;    
}

/* Saler send the sale information and transfer the owner power to contract 卖家挂单待售资产，并将所有权转移给智能合约*/
  function Sale(address ThisToken,uint256 _token_num,uint256 Price,string Attachstr)  public returns (bool success){
        // 向合约转移所有权，并在数组中登记。
             ExChToken=TokenERC20(ThisToken);
             ExChToken.save(this,_token_num);  //向合约转移待交换代币所有权
             Sales[SalesNum]=ExThingInfo(msg.sender,ExChToken,_token_num,Price, Attachstr);
              SalesNum+=1;
             return true;
     }
/* Buyer send money to the contract and get the Token. 买家发送资金给智能合约，并获得相应数量资产代币*/
  function Buy(uint SalesIndex,uint256 _token_num) payable public {
        // 向合约发送资金，并获得代币所有权。 
           uint256 BalanceChange=msg.value-Sales[SalesIndex].price;  //计算找零
           require( BalanceChange>=0);   //找零应大于或于0
           ExChToken=Sales[SalesIndex].Token;  //定义代币合约为当前所售代币。
           ExChToken.transfer(msg.sender,_token_num);  //向买家转移待交换代币所有权
           Sales[SalesIndex].owner.transfer(Sales[SalesIndex].price*99/100);  //向卖家支付99%货款
           manager.transfer(Sales[SalesIndex].price*1/100);  //向交易管理帐号支付1%手续
           delete Sales[SalesIndex];   //删除卖单
           SalesNum-=1;  //卖单数量减1
           if (BalanceChange>0) {                   //如果有剩余，向买家找零。
                msg.sender.transfer(BalanceChange);    
           }
      }
function Withdraw(uint SalesIndex) public {
        // 指定卖单号，由卖家撤回。 
           require(Sales[SalesIndex].owner==msg.sender);   //只有卖单所有者才能撤单。
           ExChToken=Sales[SalesIndex].Token;
           ExChToken.transfer(msg.sender,Sales[SalesIndex].amount);  //将合约中的待售物品还回所有者。
           delete Sales[SalesIndex]; //从卖单数组中删除该卖单.
           SalesNum-=1;
      } 
}
