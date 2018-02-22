pragma solidity ^0.4.19;

contract XOR {

    function XOR() public {}

    function calc(string a, string b) returns (bool) {
        return sha3(a) != sha3(b);
    }
}
