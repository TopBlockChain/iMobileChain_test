pragma solidity ^0.4.18;
//第三代移动认证合约
contract MinerRefuel {
  //变量定义
    address public Manager;
    //Only manager can modify. 
   //转账事件定义 
   event Transfer(address indexed from, address indexed to, uint256 value);
   //定义修饰函数仅管理员能修改
        modifier onlyManager {
         require(msg.sender ==Manager);
         _;
      }

//EnergyStation Manager Information.
//定义能量加注站注册信息结构
   struct EnergyStation {
         bool status;      //注册状态，TRUE使能；FALSE，去能
         string AppAddr;   //能量加注站的地址
}
 uint public ReceiveFoundation;    //Having received reward foundation.  已收到基金总额
 mapping (address=>EnergyStation) public EnergyStations;     //定义能量加注站Mapping数组
 mapping (address =>uint) public MinerRefuelTime;   //定义矿工注册时间数组
 mapping (address =>address) public MinerRefuelPool;   //定义矿工矿池数组

   //Only EnergyStation manager can modify. 定义修饰函数，仅能量加注站能修改
     modifier onlyEnergyStation {
         require(EnergyStations[msg.sender].status ==true);    //需要能量加注站的注册状态为true
         _;
      }
    //Construction function, initially define the creator as the manager. 构造函数，管量员为合约创建者
    function MinerRefuel() public {
            Manager=msg.sender;
    }
//Define the contract can receive mining reward foundation. 收到基金注入后，增加总额
   function () payable public {
         ReceiveFoundation+=msg.value;    
   }
//Management power thansfer. 管理权转移
  function transferManagement(address newManager) onlyManager public {
               Manager=newManager;
       }
   //EnergyStation manager setting, only manager can modify. 能量加注站设置，仅管理员能设置
   function EnergyStationSet(address energystation,bool status,string AppAddr) onlyManager public {
        EnergyStations[energystation]=EnergyStation(status,AppAddr);    
    }
   //Miner refuel time setting , only Energy Station manager  can modify.  //矿工注册，仅注册能量加注站能操作
   function Refuel(address Miner,address pool) onlyEnergyStation public {
        require(MinerRefuelTime[Miner]+3600<now);   //要求矿工在1小时内未注册过
        MinerRefuelPool[Miner]=pool;     //设置矿工所注册的矿池
        MinerRefuelTime[Miner]=now;      //设置注册时间为当前时间
        if (Miner.balance<10000000000000000){      //如果账户余额小于0.01IMC，则为其加注0.01IMC
             Miner.transfer(10000000000000000);       //加注ת��0.01
             Transfer(this, Miner, 10000000000000000); //事件
        }
    }
   function _Refuel(address Miner, address pool) onlyEnergyStation public {
        require(MinerRefuelTime[Miner]+3600<now);
        MinerRefuelPool[Miner]=pool;
        MinerRefuelTime[Miner]=now;      //设置加注时间
        if (Miner.balance<10000000000000000){      //加注燃料0.01APC
             Miner.transfer(10000000000000000);       //0.01APC
             Transfer(this, Miner, 10000000000000000); //事件
        }
    }
}
