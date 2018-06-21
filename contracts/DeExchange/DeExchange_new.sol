/*ԭ��1������ѡ�������ʲ��Ĵ��ң��ڽ������ܺ�Լ�ǼǴ����������۸񣬹ҵ������ܺ�Լ����save���뺯�����ʲ�ת�����ܺ�Լ�ʻ��ϣ�2����Ҳ�ѯ��������ֱ�Ӷ�������������������ȷ���ļ۸񣬶��������������ܺ�Լ���ͽ��ף����ܺ�Լ�յ��󣬽���Ӧ�����ʲ�ת������ʻ������ʽ��͵������ʻ������������������������ݽ��м����ɾ����3��������Ҫ����������ֱ�ӽ����׺ż��������������ܺ�Լ�����ܺ�Լ��֤��ֱ�ӽ������ʲ�����Ȩת�������ʻ����������������������������*/
pragma solidity ^0.4.18;

interface SHOPRC20{
      function transferFrom(address _from,address _to,uint256 _value) public;
} 

contract DeExChange{
    //ExChange things' Information. �����������Ʒ���ݽṹ
    struct ExThingInfo {
         address owner;
         address Token;  //the wishing to exchange thing's  token address  ��������Ʒ���Һ�Լ��ַ
          uint256 amount; //the amount of withing to exchange thiing ��������Ʒ����
          uint256 price;  //the price of the things per unit ��Ʒ����
          string AttachInfo; //additional information ��ע�򸽼���Ϣ��
        }
//Buy things' Information. ���������Ʒ���ݽṹ
    struct BuyInfo {
          address buyer;
          address Token;  //the wishing to buy thing's  token address  ������Ʒ���Һ�Լ��ַ
          uint256 amount; //the amount of withing to exchange thiing ��������Ʒ����
          uint256 price;  //the price of the things per unit ��Ʒ����
          uint256 balance;//the balance of buyer for buy products  ����ʻ����
          string AttachInfo; //additional information ��ע�򸽼���Ϣ��
        }

  uint public SalesNum;
  uint public BuysNum;    //�ҵ�����
  address public Manager; //�������Ա  
  mapping(uint=>ExThingInfo)  public Sales; //����ҵ�����
  SHOPRC20  ExChToken;   //���ö���Ϊ���Һ�Լ
   mapping(uint=>BuyInfo) public Buys;//������ 
//���캯�����������Ա
function DeExChange(
         ) public {
        Manager=msg.sender;    
}

  
/* Saler send the sale information and transfer the owner power to contract ���ҹҵ������ʲ�����������Ȩת�Ƹ����ܺ�Լ*/
  function Sale(address ThisToken,uint256 Amount,uint256 Price,string Attachstr)  public returns (bool success){
        // �������еǼ�����Ϣ��
             Sales[SalesNum]=ExThingInfo(tx.origin,ThisToken,Amount,Price, Attachstr);
             SalesNum+=1;
             return true;
     }
//��������
function SaleWithdraw(uint salenum) public {
        // ָ�������ţ������ҳ��ء� 
           require(Sales[salenum].owner==msg.sender);   //ֻ�����������߲��ܳ�����
           delete Sales[salenum]; //������������ɾ��������.
       }  
/* Buyer send money to the contract and get the Token. ��ҷ����ʽ�����ܺ�Լ���������Ӧ�����ʲ�����*/
  function Buy(address ThisToken,uint256 Amount,uint256 Price,string Attachstr) payable public {
        // ���Լ�����ʽ𣬲���ô�������Ȩ�� 
           uint256 Balance=Price*Amount;  //��������
           require( msg.value>=Balance);   //����Ӧ���ڻ���0
       // ���Լת������Ȩ�����������еǼǡ�
             Buys[BuysNum]=BuyInfo(msg.sender,ThisToken,Amount,Price,msg.value, Attachstr);
             BuysNum+=1;
      }
//�򵥳���
function BuyWithdraw(uint buynum) public {
        // ָ���򵥺ţ�����ҳ��ء� 
           require(Buys[buynum].buyer==msg.sender);   //ֻ���������߲��ܳ�����
           Buys[buynum].buyer.transfer(Buys[buynum].balance);  //�����͸���Լ���ܵ��ʽ𳷻ء�
           delete Buys[buynum]; //����������ɾ������.
      } 

/*�������򵥴�ϣ��������۸�Ϊ׼����ָ����������ָ����������*/
  function ExChange(uint buynum,uint salenum,uint256 Amount)public {
        // ���Լ�����ʽ𣬲���ô�������Ȩ�� 
           require(Amount<=Sales[salenum].amount);    //���������Ƿ�С�ڻ������������
           require(Amount<=Buys[buynum].amount);    //���������Ƿ�С�ڻ����������
           require(Buys[buynum].price>=Sales[salenum].price);    //���������Ƿ�С�ڻ����������
          // uint256 BuyerBalance=Buys[buynum].price*.Buys[buynum].amount-Sales[salesnum].price*Amount;  //����������
           ExChToken=SHOPRC20(Sales[salenum].Token);  //������Һ�ԼΪ��ǰ���۴��ҡ�
           ExChToken.transferFrom(Sales[salenum].owner,Buys[buynum].buyer,Amount);  //�����ת�ƴ�������������Ȩ
           Sales[salenum].owner.transfer(Sales[salenum].price*Amount*999/1000);  //�����ҷ������յ������999%
           msg.sender.transfer(Sales[salenum].price*Amount*1/1000);  //�������ʺ�֧��ǧ��֮һ���׷�
           Sales[salenum].amount-=Amount;   //�������м�ȥ��������
           Buys[buynum].amount-=Amount;   //�����м�ȥ��������
           Buys[buynum].balance-=Sales[salenum].price*Amount;   //������ʻ��м�ȥ�ѻ����ʽ�
           if (Sales[salenum].amount==0){                     //�����������Ϊ0������������������ɾ��
                 delete Sales[salenum];
                 SalesNum-=1;
            } 
           if (Buys[buynum].amount==0){                     //�����������Ϊ0������������������ɾ��
                 delete Buys[buynum];
                 Buys[buynum].buyer.transfer(Buys[buynum].balance);  //��ʣ���ʽ𷵻���ҡ�    
            } 
      }
}