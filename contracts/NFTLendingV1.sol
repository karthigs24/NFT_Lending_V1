// SPDX-License-Identifier: MIT
pragma solidity >=0.4.18 <0.9.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interfaces/INFTLendingV1.sol";
import "./utils/Transfers.sol";
import "./NFTLendingV1Gov.sol";

contract NFTLendingV1 is
    INFTLendingV1,
    NFTLendingV1Gov,
    Transfers,
    ReentrancyGuard
{
    function createLoan(address nftAddress, uint256 nftId)
        external
        whenNotPaused
        nonReentrant
        returns (uint256 loanId)
    {
        require(
            _acceptedNFTs[nftAddress],
            "NFTLendingV1: NFT collection not accepted"
        );
        require(
            nftCollections[nftAddress].enabled,
            "NFTLendingV1: NFT collection not enabled"
        );

        uint256 loanAmount = calcLoanAmount(nftAddress);
        require(loanAmount > 0, "NFTLendingV1: loan amount can not be zero");
        require(
            loanAmount <= lendableFunds,
            "NFTLendingV1: loan amount can not exceed lendable funds"
        );

        loanId = ++numLoans;

        loans[loanId].borrower = msg.sender;
        loans[loanId].loanAmount = loanAmount;
        loans[loanId].interestRate = nftCollections[nftAddress].interestRate;
        loans[loanId].nftValue = nftCollections[nftAddress].value;

        loans[loanId].nftId = nftId;
        loans[loanId].nftAddress = nftAddress;
        loans[loanId].nftType = nftCollections[nftAddress].nftType;

        loans[loanId].startTime = block.timestamp;
        loans[loanId].dueTime = block.timestamp + LOAN_PERIOD;
        loans[loanId].status = Status.CREATED;

        // transfer NFT from borrower to lending contract
        transferNFT(
            msg.sender,
            address(this),
            nftAddress,
            nftId,
            loans[loanId].nftType
        );

        // transfer token from lending contract to borrower
        transferToken(
            address(this),
            payable(msg.sender),
            address(0),
            loanAmount
        );

        accountLoans[msg.sender].push(loanId);
        lendableFunds -= loanAmount;

        emit LoanCreated(
            msg.sender,
            loanId,
            loanAmount,
            nftAddress,
            nftId,
            loans[loanId].nftType
        );
    }

    function repayLoan(uint256 loanId) external payable {
        require(
            loans[loanId].borrower == msg.sender,
            "NFTLendingV1: sender must be the loan borrower"
        );
        require(
            loans[loanId].status == Status.CREATED,
            "NFTLendingV1: invalid loan status"
        );
        require(
            loans[loanId].dueTime >= block.timestamp,
            "NFTLendingV1: loan is already overdue"
        );

        (, uint256 interest) = calcLoanInterest(loanId);
        require(
            msg.value >= loans[loanId].loanAmount + interest,
            "NFTLendingV1: insufficient repayment amount"
        );

        loans[loanId].status = Status.REPAYED;
        lendableFunds += msg.value;

        // transfer NFT from lending contract to borrower
        transferNFT(
            address(this),
            msg.sender,
            loans[loanId].nftAddress,
            loans[loanId].nftId,
            loans[loanId].nftType
        );

        emit LoanRepayed(msg.sender, loanId, interest);
    }

    function liquidateLoan(uint256 loanId, address to) external onlyOwner {
        require(
            loans[loanId].status == Status.CREATED,
            "NFTLendingV1: invalid loan status"
        );
        require(
            block.timestamp > loans[loanId].dueTime,
            "NFTLendingV1: loan is not overdue"
        );

        loans[loanId].status = Status.LIQUIDATED;

        transferNFT(
            address(this),
            to,
            loans[loanId].nftAddress,
            loans[loanId].nftId,
            loans[loanId].nftType
        );

        emit LoanLiquidated(msg.sender, loanId, to);
    }

    function getLoan(uint256 loanId) external view returns (Loan memory loan) {
        return loans[loanId];
    }

    function getLoans(address account)
        external
        view
        returns (uint256[] memory loanIds)
    {
        return accountLoans[account];
    }

    function getNFTCollection(address nftAddress)
        external
        view
        returns (NFTCollection memory nftCollection)
    {
        return nftCollections[nftAddress];
    }

    function isNFTAccepted(address nftAddress) external view returns (bool) {
        return _acceptedNFTs[nftAddress];
    }

    function getAcceptedNFTs() external view returns (address[] memory) {
        return _acceptedNFTSet;
    }
}
