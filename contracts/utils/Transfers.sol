// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "./ERC721Holder.sol";
import "./ERC1155Holder.sol";

/**
 * @title Intended to transfer tokens(native token or ERC20 tokens) or NFTs(ERC721 or ERC1155).
 */
contract Transfers is ERC721Holder, ERC1155Holder {
    /**
     * @notice Transfer native or ERC20 token.
     */
    function transferToken(
        address from,
        address payable to,
        address token,
        uint256 amount
    ) public {
        if (token != address(0)) {
            require(
                IERC20(token).transferFrom(from, to, amount),
                "Transfers: token transfer failed"
            );
        } else {
            require(to.send(amount), "Transfers: native token transfer failed");
        }
    }

    /**
     * @notice Transfer NFT.
     */
    function transferNFT(
        address from,
        address to,
        address nftAddress,
        uint256 nftId,
        uint8 nftType
    ) public {
        if (nftType == 0) {
            IERC721(nftAddress).safeTransferFrom(from, to, nftId);
        } else {
            IERC1155(nftAddress).safeTransferFrom(from, to, nftId, 1, "0x00");
        }
    }
}
