// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

contract Test {
    function test(uint256 a, uint256 b) public pure returns (uint256) {
        if (a % 2 == 0) {
            return a + b;
        } else {
            return a * b;
        }
    }
}
