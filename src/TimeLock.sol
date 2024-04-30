// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {TimelockController} from "../lib/openzeppelin-contracts/contracts/governance/TimelockController.sol";
//minDelay is how long you have to wait before executing
//

contract TimeLock is TimelockController {
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors /*address admin*/ )
        TimelockController(minDelay, proposers, executors, msg.sender)
    {}
}
