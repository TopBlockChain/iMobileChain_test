/*原理：1、卖家选定数字资产的代币，在交易智能合约登记待售数量、价格，挂单，智能合约调用save存入函数将资产转到智能合约帐户上；2、买家查询到卖单后，直接对卖单操作，按照卖单确定的价格，定义数量，向智能合约发送交易，智能合约收到后，将相应数量资产转到买家帐户，将资金发送到卖家帐户，根据所售数量对卖单数据进行减额或删除。3、卖家若要撤回卖单，直接将交易号及代币名发给智能合约，智能合约验证后，直接将卖单资产所有权转回卖家帐户，并在卖单数组中清除该卖单。*/
pragma solidity ^0.4.18;

interface SHOPRC20{
      function transferFrom(address _from,address _to,uint256 _value) public;
} 

contract DeExChange{
    //ExChange things' Information. 定义待交换物品数据结构
    struct ExThingInfo {
         address owner;
         address Token;  //the wishing to exchange thing's  token address  待交易物品代币合约地址
          uint256 amount; //the amount of withing to exchange thiing 待交换物品数量
          uint256 price;  //the price of the things per unit 物品单价
          string AttachInfo; //additional information 备注或附加信息。
        }
//Buy things' Information. 定义待买物品数据结构
    struct BuyInfo {
          address buyer;
          address Token;  //the wishing to buy thing's  token address  待买物品代币合约地址
          uint256 amount; //the amount of withing to exchange thiing 待交换物品数量
          uint256 price;  //the price of the things per unit 物品单价
          uint256 balance;//the balance of buyer for buy products  买家帐户余额
          string AttachInfo; //additional information 备注或附加信息。
        }

  uint public SalesNum;
  uint public BuysNum;    //挂单数量
  address public Manager; //定义管理员  
  mapping(uint=>ExThingInfo)  public Sales; //定义挂单数组
  SHOPRC20  ExChToken;   //设置对象为代币合约
   mapping(uint=>BuyInfo) public Buys;//定义买单 
//构造函数，定义管理员
function DeExChange(
         ) public {
        Manager=msg.sender;    
}

  
/* Saler send the sale information and transfer the owner power to contract 卖家挂单待售资产，并将所有权转移给智能合约*/
  function Sale(address ThisToken,uint256 Amount,uint256 Price,string Attachstr)  public returns (bool success){
        // 在数组中登记买单信息。
             Sales[SalesNum]=ExThingInfo(tx.origin,ThisToken,Amount,Price, Attachstr);
             SalesNum+=1;
             return true;
     }
//卖单撤回
function SaleWithdraw(uint salenum) public {
        // 指定卖单号，由卖家撤回。 
           require(Sales[salenum].owner==msg.sender);   //只有卖单所有者才能撤单。
           delete Sales[salenum]; //从卖单数组中删除该卖单.
       }  
/* Buyer send money to the contract and get the Token. 买家发送资金给智能合约，并获得相应数量资产代币*/
  function Buy(address ThisToken,uint256 Amount,uint256 Price,string Attachstr) payable public {
        // 向合约发送资金，并获得代币所有权。 
           uint256 Balance=Price*Amount;  //计算找零
           require( msg.value>=Balance);   //找零应大于或于0
       // 向合约转移所有权，并在数组中登记。
             Buys[BuysNum]=BuyInfo(msg.sender,ThisToken,Amount,Price,msg.value, Attachstr);
             BuysNum+=1;
      }
//买单撤回
function BuyWithdraw(uint buynum) public {
        // 指定买单号，由买家撤回。 
           require(Buys[buynum].buyer==msg.sender);   //只有买单所有者才能撤单。
           Buys[buynum].buyer.transfer(Buys[buynum].balance);  //将发送给合约保管的资金撤回。
           delete Buys[buynum]; //从买单数组中删除该买单.
      } 

/*卖单与买单撮合，以卖单价格为准，对指定买单卖单按指定数量交易*/
  function ExChange(uint buynum,uint salenum,uint256 Amount)public {
        // 向合约发送资金，并获得代币所有权。 
           require(Amount<=Sales[salenum].amount);    //所购数量是否小于或等于卖单数量
           require(Amount<=Buys[buynum].amount);    //所购数量是否小于或等于买单数量
           require(Buys[buynum].price>=Sales[salenum].price);    //所购数量是否小于或等于买单数量
          // uint256 BuyerBalance=Buys[buynum].price*.Buys[buynum].amount-Sales[salesnum].price*Amount;  //计算买家余额
           ExChToken=SHOPRC20(Sales[salenum].Token);  //定义代币合约为当前所售代币。
           ExChToken.transferFrom(Sales[salenum].owner,Buys[buynum].buyer,Amount);  //向买家转移待交换代币所有权
           Sales[salenum].owner.transfer(Sales[salenum].price*Amount*999/1000);  //向卖家发送已收到货款的999%
           msg.sender.transfer(Sales[salenum].price*Amount*1/1000);  //向交易所帐号支付千分之一交易费
           Sales[salenum].amount-=Amount;   //从卖单中减去已售数量
           Buys[buynum].amount-=Amount;   //从买单中减去已售数量
           Buys[buynum].balance-=Sales[salenum].price*Amount;   //从买家帐户中减去已花费资金
           if (Sales[salenum].amount==0){                     //如果卖单数量为0，将该卖单从数组中删除
                 delete Sales[salenum];
                 SalesNum-=1;
            } 
           if (Buys[buynum].amount==0){                     //如果卖单数量为0，将该卖单从数组中删除
                 delete Buys[buynum];
                 Buys[buynum].buyer.transfer(Buys[buynum].balance);  //将剩余资金返回买家。    
            } 
      }
}