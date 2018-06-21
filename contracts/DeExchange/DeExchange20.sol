/*原理：1、卖家在交易所合约使用Sale函数，登记待售币合约地址、数量、价格，挂单；2、买家查询到卖单后，直接对卖单操作，按照卖单确定的价格，定义数量，向智能合约发送交易，智能合约收到后，将相应数量资产转到买家帐户，将资金发送到卖家帐户，根据所售数量对卖单数据进行减额或删除。3、卖家若要撤回卖单，直接将交易号及代币名发给智能合约，智能合约验证后，取消交易所授权，并在卖单数组中清除该卖单。*/
pragma solidity ^0.4.18;

interface SHOPRC30{
      function transferFrom(address _from, address _to, uint256 _value) public;
      function approveAndCall(address _spender, uint256 _value, bytes _extraData) public;
} 

contract DeExChange{
    //ExChange things' Information. 定义待交换物品数据结构
    struct ExThingInfo {
          address owner; //the owner's account. 所有者帐号
          SHOPRC30 Token;  //the wishing to exchange thing's  token address  待交易物品代币合约地址
          uint256 amount; //the amount of withing to exchange thiing 待交换物品数量
          uint256 price;  //the price of the things per unit 物品单价
          string AttachInfo; //additional information 备注或附加信息。
        }
 address public Manager; //定义管理员  
  mapping(bytes32=>ExThingInfo)  public Sales; //定义卖单数组
  SHOPRC30  ExChToken;   //设置对象为代币合约
 //定义卖单、买单与撤单事件
 event SaleEvent(bytes32 salehash,SHOPRC30 saler,address Token, uint256 Amount,uint256 price);
 event ApproveEvent(address _from, uint256 _value, address _token, bytes _extraData);
 event BuyEvent(bytes32 salehash,SHOPRC30 buyer,address Token, uint256 Amount,uint256 price);
 event WithdrawEvent(bytes32 salehash);

//定义修饰函数：仅合约管理员能修改
        modifier onlyManager {
         require(msg.sender ==Manager);
         _;
     }
//构造函数，定义管理员
function DeExChange(
         ) public {
        Manager=msg.sender;    
}

/* Saler send the sale information and transfer the owner power to contract 卖家挂单待售资产，并对交易所合约授权*/
  function Sale(address Token,uint256 Amount,uint256 Price,string Attachstr)  external returns (bool success){
        // 向交易所合约授权，并在数组中登记。
             ExChToken=SHOPRC30(Token);   //实例化代币对象
             ExChToken.approveAndCall(this,Amount,bytes(Attachstr));  //对交易所合约授权
             bytes32 Saleshash=sha256(Token,tx.origin,Amount,Price,Attachstr);  //生成卖单Hash序列码
             Sales[Saleshash]=ExThingInfo(tx.origin,ExChToken,Amount,Price, Attachstr);   //加入卖单数组
             SaleEvent(Saleshash,ExChToken,tx.origin,Amount,Price);   //触发卖单事件
             return true;
     }

/* Buyer send money to the contract and get the Token. 买家发送资金给智能合约，并获得相应数量资产代币*/
  function Buy(bytes32 SalesIndex,uint256 Amount) payable public {
        // 向合约发送资金，并获得代币所有权。 
           require(Amount<=Sales[SalesIndex].amount);    //所购数量是否小于或等于卖单数量
           uint256 BalanceChange=msg.value-Sales[SalesIndex].price*Amount;  //计算找零
           require( BalanceChange>=0);   //找零应大于或于0
           ExChToken=Sales[SalesIndex].Token;  //定义代币合约为当前所售代币。
           ExChToken.transferFrom(Sales[SalesIndex].owner,msg.sender,Amount);  //向买家转移待交换代币所有权
           Sales[SalesIndex].owner.transfer(Sales[SalesIndex].price*Amount*999/1000);  //向卖家发送已收到货款
           Manager.transfer(Sales[SalesIndex].price*Amount*1/1000);  //向交易所管理帐号支付交易费。
           Sales[SalesIndex].amount-=Amount;   //从卖单中减去已售数量
           if (Sales[SalesIndex].amount==0){                     //如果卖单数量为0，将该卖单从数组中删除
                 delete Sales[SalesIndex];
           } 
           if (BalanceChange>0) {                   //如果有剩余，向买家找零。
                msg.sender.transfer(BalanceChange);    
           }
          BuyEvent(SalesIndex,ExChToken,msg.sender,Amount,Sales[SalesIndex].price);  //触发买单事件
      }
function Withdraw(bytes32 SalesIndex) public {
        // 指定卖单号，由卖家撤回。 
           bytes memory b = new bytes(0);
           require(Sales[SalesIndex].owner==msg.sender);   //只有卖单所有者才能撤单。
           ExChToken=Sales[SalesIndex].Token;  //定义代币合约为当前所售代币。
           ExChToken.approveAndCall(this,0,b);  //取消交易所授权     
           delete Sales[SalesIndex]; //从卖单数组中删除该卖单.
           WithdrawEvent(SalesIndex);   //触发撤单事件
      } 
 function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public{
      ApproveEvent(_from,_value,_token,_extraData);  //由代币授权成功时调用，触发授权成功事件
  }
//Management power thansfer. 管理权转移，仅能由当前合约管理员操作
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
}
