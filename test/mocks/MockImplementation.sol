// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

/// @author philogy <https://github.com/philogy>
contract MockImplementation {
    uint256 public a;

    error MockError();

    function setA(uint256 _a) external {
        a = _a;
    }

    function throwError() external view {
        revert MockError();
    }
}
