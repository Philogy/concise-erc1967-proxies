// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {IMorphingFactory} from "./IMorphingFactory.sol";
import {MorphingProxyDeployer} from "./MorphingProxyDeployer.sol";

/// @author Philippe Dumonet <philippe@dumo.net>
contract MorphingFactory is IMorphingFactory {
    address internal constant NO_ADDRESS = address(uint160(1));
    address public getImplementation = NO_ADDRESS;

    mapping(address => address) public adminOf;
    mapping(address => bytes32) internal proxySalt;

    modifier onlyAdminOf(address _proxy) {
        if (adminOf[_proxy] != msg.sender) revert NotProxyAdmin();
        _;
    }

    modifier withImplementation(address _implementation) {
        getImplementation = _implementation;
        _;
        getImplementation = NO_ADDRESS;
    }

    modifier returnETHDiff() {
        uint256 balBefore = address(this).balance;
        _;
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        if (!success) revert FailedToSendETH();
    }

    function deployProxy(address _implementation, bytes32 _subSalt)
        external
        payable
        withImplementation(_implementation)
        returns (address proxy)
    {
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, _subSalt));
        proxy = address(new MorphingProxyDeployer{salt: salt}());
        proxySalt[proxy] = salt;
        adminOf[proxy] = msg.sender;
    }

    function changeAdminOf(address _proxy, address _newAdmin)
        external
        onlyAdminOf(_proxy)
    {
        adminOf[_proxy] = _newAdmin;
    }

    function killForUpgrade(address _proxy)
        external
        onlyAdminOf(_proxy)
        returnETHDiff
    {
        _proxy.call("");
    }

    function completeUpgrade(address _proxy, address _newImplementation)
        external
        payable
        onlyAdminOf(_proxy)
        withImplementation(_newImplementation)
    {
        new MorphingProxyDeployer{salt: proxySalt[_proxy], value: msg.value}(); // redeploy
    }
}
