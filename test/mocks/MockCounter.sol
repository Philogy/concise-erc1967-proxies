// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

/// @author Philippe Dumonet <philippe@dumo.net>
contract MockCounter {
    uint256[1] internal __gap;
    uint256 public counter;

    function increment() external {
        counter++;
    }
}
