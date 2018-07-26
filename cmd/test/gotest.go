package main

import (
	"fmt"
	"github.com/blockchain/imobilechain/common"
	//"github.com/blockchain/imobilechain/log"
	
)

func main() {
    xt:=common.Hex2Bytes("56b99e67")
	yt:=common.Hex2Bytes("39f3105d")
	mt:=common.Hex2Bytes("18d63143")
	nt:=common.Hex2Bytes("42c8705b")
	fmt.Println(xt)
	fmt.Println(yt)
	fmt.Println(mt)
	fmt.Println(nt)

}

