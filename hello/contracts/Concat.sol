pragma solidity ^0.4.19;

contract Concat {

    function Concat() public {}

    function concat(string a, string b) returns (string) {
        bytes memory _ba = bytes(a);
        bytes memory _bb = bytes(b);
        bytes memory newString = bytes(new string(_ba.length + _bb.length));
        for (uint i = 0; i < _ba.length; i++) newString[i] = _ba[i];
        for (i = 0; i < _bb.length; i++) newString[i + _ba.length] = _bb[i];

        return string(newString);

    }
}
