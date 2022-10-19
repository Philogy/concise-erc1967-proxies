// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

/// @author Philippe Dumonet <philippe@dumo.net>
interface IMorphingFactory {
    function getImplementation() external view returns (address);

    function adminOf(address _proxy) external view returns (address);

    function deployProxy(address _implementation, bytes32 _subSalt)
        external
        payable
        returns (address);

    function changeAdminOf(address _proxy, address _newAdmin) external;

    function killForUpgrade(address _proxy) external;

    function completeUpgrade(address _proxy, address _newImplementation)
        external
        payable;

    error NotProxyAdmin();
    error FailedToSendETH();
    error UpgradePending();
    error NoUpgradePending();
    error InvalidAddress();
}
