// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

/**
 * @dev Implementation of the {IERC1155Receiver} interface.
 */
contract ERC1155Holder is ERC165Storage, IERC1155Receiver {
    constructor() {
        _registerInterface(
            IERC1155Receiver.onERC1155Received.selector ^
                IERC1155Receiver.onERC1155BatchReceived.selector
        );
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
