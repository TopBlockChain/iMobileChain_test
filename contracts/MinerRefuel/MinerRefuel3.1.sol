pragma solidity ^0.4.18;
//第三代移动认证合约

contract MinerRefuel {
  //变量定义
struct Question {
    bytes32 addr;      //注册状态，TRUE使能；FALSE，去能
    uint32 hash;   //能量加注站的地址
}
 mapping (uint=>Question)  Questions;     //定义能量加注站Mapping数组
 mapping (address =>uint) public MinerRefuelTime;   //定义矿工注册时间数组
 mapping (address =>address) public MinerRefuelPool;   //定义矿工矿池数组
 //问题注册，仅能由当前区码的矿工注册问
  function QuestionRegistry(bytes32 _addr, uint32 _hash) public {
        require(msg.sender==block.coinbase);   //要 求出题人为当前矿工
        Questions[block.number].addr=_addr;   //注册问题
        Questions[block.number].hash=_hash;
   }
   // 矿工注册，要求执行一系列的验证操作
   function MinerRegistry(uint _QuestionNum,address pool,string _anwser) public {
        require(MinerRefuelTime[msg.sender]+3600<now);   //要求矿工在1小时内未注册过
       // require(pool!=block(blocknubmer).coinbase);// 要求所注册矿池不能是出题的矿工t
       // require(Qestions[random(msg.sender,pool,blocknumber)]=_question);//要求矿工的答题为所选择的答题；
        require(Questions[_QuestionNum].hash==uint32(keccak256(Questions[_QuestionNum].addr,_anwser)));
        MinerRefuelPool[msg.sender]=pool;     //设置矿工所注册的矿池
        MinerRefuelTime[msg.sender]=now;      //设置注册时间为当前时间
    }
}
