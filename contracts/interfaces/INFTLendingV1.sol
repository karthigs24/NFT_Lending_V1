// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Interfaces for NFT collateralized lending.
 */
interface INFTLendingV1 {
    /**
     * @notice Initiate a loan with the specified NFT.
     * @param nftAddress The NFT address
     * @param nftId The token id of the NFT
     * @return loanId The loan id
     */
    function createLoan(address nftAddress, uint256 nftId)
        external
        returns (uint256 loanId);

    /**
     * @notice Repay the given loan.
     * @param loanId The loan id
     */
    function repayLoan(uint256 loanId) external payable;

    /**
     * @notice Liquidate loan when the loan is defaulted.
     * @param loanId The loan id
     * @param to The NFT recipient address
     */
    function liquidateLoan(uint256 loanId, address to) external;

    /**
     * @notice Retrieve the loan list of the given account.
     * @param account The destination account address
     * @return loanIds The loan id list
     */
    function getLoans(address account)
        external
        view
        returns (uint256[] memory loanIds);

    /**
     * @notice Check if the given NFT collection is accepted.
     * @param nftAddress The destination NFT address
     * @return bool True if the given NFT collection is accepted, false otherwise
     */
    function isNFTAccepted(address nftAddress) external view returns (bool);

    /**
     * @notice Retrieve the accepted NFT address list.
     * @return nftAddresses The accepted NFT address list
     */
    function getAcceptedNFTs()
        external
        view
        returns (address[] memory nftAddresses);
}
