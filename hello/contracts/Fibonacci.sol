pragma solidity ^0.4.19;

contract Fibonacci {
    uint a;
    uint b;

    function Fibonacci() public {
        a = 0;
        b = 1;
    }

    function next() public returns (uint) {
        uint prevA = a;
        a = b;
        b += prevA;

        return prevA;
    }
}
