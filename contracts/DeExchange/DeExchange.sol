/*ԭ��1��������SHOPRC���Һ�Լ��ʹ��Sale�������Խ�������Լ������Ȩ�����ǼǴ����������۸񣬹ҵ���2����Ҳ�ѯ��������ֱ�Ӷ�������������������ȷ���ļ۸񣬶��������������ܺ�Լ���ͽ��ף����ܺ�Լ�յ��󣬽���Ӧ�����ʲ�ת������ʻ������ʽ��͵������ʻ������������������������ݽ��м����ɾ����3��������Ҫ����������ֱ�ӽ����׺ż��������������ܺ�Լ�����ܺ�Լ��֤��ֱ�ӽ������ʲ�����Ȩת�������ʻ����������������������������*/
pragma solidity ^0.4.18;

interface SHOPRC20{
      function transfer(address _to,uint256 _value) public;
      function transferFrom(address _from, address _to, uint256 _value) public;
      function approve(address _spender, uint256 _value) public;
} 

contract DeExChange{
    //ExChange things' Information. �����������Ʒ���ݽṹ
    struct ExThingInfo {
          address owner; //the owner's account. �������ʺ�
          SHOPRC20 Token;  //the wishing to exchange thing's  token address  ��������Ʒ���Һ�Լ��ַ
          uint256 amount; //the amount of withing to exchange thiing ��������Ʒ����
          uint256 price;  //the price of the things per unit ��Ʒ����
          string AttachInfo; //additional information ��ע�򸽼���Ϣ��
        }
 //uint public SalesNum;    //�ҵ�����
  address public Manager; //�������Ա  
  mapping(bytes32=>ExThingInfo)  public Sales; //����ҵ�����
  SHOPRC20  ExChToken;   //���ö���Ϊ���Һ�Լ
 //�������������볷���¼�
 event SaleEvent(bytes32 salehash,SHOPRC20 saler,address Token, uint256 Amount,uint256 price);
 event BuyEvent(bytes32 salehash,SHOPRC20 buyer,address Token, uint256 Amount,uint256 price);
 event WithdrawEvent(bytes32 salehash);



//���캯�����������Ա
function DeExChange(
         ) public {
        Manager=msg.sender;    
}

/* Saler send the sale information and transfer the owner power to contract ���ҹҵ������ʲ�����������Ȩת�Ƹ����ܺ�Լ*/
  function Sale(address ThisToken,uint256 Amount,uint256 Price,string Attachstr)  external returns (bool success){
        // ���Լת������Ȩ�����������еǼǡ�
             ExChToken=SHOPRC20(ThisToken);
             bytes32 Saleshash=sha256(ThisToken,tx.origin,Amount,Price,Attachstr);
             Sales[Saleshash]=ExThingInfo(tx.origin,ExChToken,Amount,Price, Attachstr);
             SaleEvent(Saleshash,ExChToken,tx.origin,Amount,Price);
             return true;
     }
/* Buyer send money to the contract and get the Token. ��ҷ����ʽ�����ܺ�Լ���������Ӧ�����ʲ�����*/
  function Buy(bytes32 SalesIndex,uint256 Amount) payable public {
        // ���Լ�����ʽ𣬲���ô�������Ȩ�� 
           require(Amount<=Sales[SalesIndex].amount);    //���������Ƿ�С�ڻ������������
           uint256 BalanceChange=msg.value-Sales[SalesIndex].price*Amount;  //��������
           require( BalanceChange>=0);   //����Ӧ���ڻ���0
           ExChToken=Sales[SalesIndex].Token;  //������Һ�ԼΪ��ǰ���۴��ҡ�
           ExChToken.transferFrom(Sales[SalesIndex].owner,msg.sender,Amount);  //�����ת�ƴ�������������Ȩ
           Sales[SalesIndex].owner.transfer(Sales[SalesIndex].price*Amount*999/1000);  //�����ҷ������յ������99%
           Manager.transfer(Sales[SalesIndex].price*Amount*1/1000);  //�����������ʺ�֧��1%���׷�
           Sales[SalesIndex].amount-=Amount;   //�������м�ȥ��������
           if (Sales[SalesIndex].amount==0){                     //�����������Ϊ0������������������ɾ��
                 delete Sales[SalesIndex];
           } 
           if (BalanceChange>0) {                   //�����ʣ�࣬��������㡣
                msg.sender.transfer(BalanceChange);    
           }
          BuyEvent(SalesIndex,ExChToken,msg.sender,Amount,Sales[SalesIndex].price);
      }
function Withdraw(bytes32 SalesIndex) public {
        // ָ�������ţ������ҳ��ء� 
           require(Sales[SalesIndex].owner==msg.sender);   //ֻ�����������߲��ܳ�����
           ExChToken=Sales[SalesIndex].Token;  //������Һ�ԼΪ��ǰ���۴��ҡ�
           ExChToken.approve(this,0);  //ȡ����������Ȩ     
           delete Sales[SalesIndex]; //������������ɾ��������.
           WithdrawEvent(SalesIndex);
      } 
}
