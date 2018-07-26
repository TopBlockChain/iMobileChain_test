pragma solidity ^0.4.18;
/*操作步骤：
1、部署本合约；
2、获得本合约的合约地址，将应用矿池的挖矿地址设为本合约地址；
3、老用户（帐户余额不为0）使用推荐函数Refering将新帐号（要求其帐号余额为0）登记；
4、矿工使用Mine函数挖矿,若有推荐人将为其推荐人奖励10%，为推荐人的上级机构奖励5%(若有），为矿池奖励1%，其余奖励给矿工；
*/
//引用燃料加注合约中的变量
contract MinerRefuel{
      mapping (address => uint) public MinerRefuelTime;   //定义移动矿工能量时间Mapping 数组
      mapping (address => address) public MinerRefuelPool;   //定义移动矿工能量时间Mapping 数组
}
//移动用户挖矿合约
contract MobileMine {
    //Define the Manager  定义合约管理员
     address public Manager;
     //在App中显示开关
     bool public ShowInApp;
     //定义转帐事件
     event Transfer(address indexed from, address indexed to, uint256 value);
    //Only manager can modify. 定义修饰函数，仅合约管理员能修改 
     modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }
//Active users' information. 定义活跃用户数据结构
    struct ActiveInfo {
          uint LastTime;     //Last calculate time. 上次活跃用户统计时间
          uint Users; //the number of already ActiveUsers since lasttime calculate. 活跃用户数量
        }
  /*Miner and active users defining  定义活跃用户公共变量ActiveUsers*/
  ActiveInfo public ActiveUsers;
  mapping(address=>uint) Miners;   //定义移动矿工Mapping数组，用于存储最近的奖励支付时间
  mapping(address=>address)  public Referees; //定义矿工的推荐人
  uint public RecFoundation;    //定义本合约所收到的直接转入款总额
  uint MineAmount;    //定义临时变量，用于计算矿工的奖励支付金额。
  uint MinerRefTime;    //设置变量:矿工在能量加注合约中的能量时间，需要访问能量加注合约获取  
  address MinerRefPool; 
 MinerRefuel MinerRef;   //设置对象为能量加注合约
 
  //Constuct function，initially define the creator as the manager. 构造函数：定义管理员为合约创建者；初始设置活跃矿工数组变量的值；设置注册合约的合约地址。
   function MobileMine() public {
           Manager=msg.sender;
           ShowInApp = false; //默认为不显示，可根据需要修改
           ActiveUsers=ActiveInfo(now,0);     //定义活跃矿工变量：活跃用户统计时间为当前区块的时间，活跃用户数为1。
           MinerRef=MinerRefuel(0x8C00B660792b235d4382368299E77C8c04ED4754);     //登记注册合约的合约地址，供访问注册合约数据所使用
    }
    //设置ShowInApp
    function setShowInApp(bool b) onlyManager public {
           ShowInApp=b;
    }
  //Management power transfer. 合约管理权转移，仅管理员能操作。
  function transferManagement(address newManager) onlyManager public {
           Manager=newManager;
   }
//Define the contract can receive mining reward foundation. 本合约所收到的转入款数据累加。
   function () payable public {
         RecFoundation+=msg.value; 
   }
//推荐函数，记录下推荐人
  function Refering(address _newMiner) public {
        require(_newMiner.balance==0);  //需要新矿工未被推荐过，并且余额为0；
        Referees[_newMiner]=msg.sender;      //将新矿工的推荐人设置为消息发送者
    }

/* Miner mine function, modify miner's status 移动矿工挖矿函数，仅符合条件的移动矿工能操作*/
  function Mine() public returns (bool success){
        //Pay the reward and change the miner's status. 向矿工支付奖励，并修改矿工的Mapping存储挖矿状态。
         if(ActiveUsers.LastTime+86400<now){     //如果统计时间已超过一天
                  ActiveUsers.LastTime=now;    //设置活跃用户统计时间为当前时间
                  ActiveUsers.Users=1;    //设置活跃用户数为1p
         }else{    //如果统计时间未超过一天
                 ActiveUsers.Users+=1;   //累加活跃用户数。
         }
        MinerRefTime=MinerRef.MinerRefuelTime (msg.sender);   //访问注册合约函数，获取矿工在合约中的注册时间
        MinerRefPool=MinerRef.MinerRefuelPool (msg.sender);   //访问注册合约函数，获取矿工在合约中的注册矿池
        require (MinerRefTime+3600>now&&Miners[msg.sender]+86400<now&&MinerRefPool==address(this));   //要求满足条件：在能量加注合约中能量时间尚未超过1小时，在本矿池中领取奖金已超过一天。
        MineAmount=this.balance/(ActiveUsers.Users+10)*(now+1-ActiveUsers.LastTime)/86400;   //计算矿工的奖励金额：当前合约帐户余额除以当前已登记的活跃用户数，乘以当前时间在一天时间中的比例。
        if  (Referees[msg.sender]!=0x0){   //矿工若有推荐人，则执行推荐人奖励。
            Referees[msg.sender].transfer(MineAmount/10);  //向矿工直接推荐人奖励10%.
            Transfer(this,Referees[msg.sender],MineAmount/10);//向矿工直接推荐人转帐事件
            MineAmount-=MineAmount/10;  //扣除直接推荐人奖励
                if  (Referees[Referees[msg.sender]]!=0x0){   //矿工若有推荐人，则执行推荐人奖励。
                    Referees[Referees[msg.sender]].transfer(MineAmount/20);  //向矿工间接推荐人奖励5%.
                    Transfer(this,Referees[Referees[msg.sender]],MineAmount/20);  //向矿工间接推荐人转帐事件
                    MineAmount-=MineAmount/20;//扣除间接推荐人奖励
                }
         }
         Manager.transfer(MineAmount/100);     //pay the manager the minerpool reward. 向矿池管理员帐号支付当前合约余额的1%（此值可调整）
         Transfer(this, Manager, this.balance/100); //转帐事件报告。
         MineAmount-=MineAmount/100;//扣除矿池奖励
         msg.sender.transfer(MineAmount);   //支付奖励
         Transfer(this, msg.sender, MineAmount); //转帐事件报告。
         Miners[msg.sender]=now;    //更新移动矿工的支付状态为当前时间
       //Check if the calculating time of active user is lasting one day or not. 检查活跃用户数统计时间是否已到一天
        return true;
  }
} 


