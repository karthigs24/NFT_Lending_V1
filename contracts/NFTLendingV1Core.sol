// SPDX-License-Identifier: MIT
pragma solidity >=0.4.18 <0.9.0;

import "@openzeppelin/contracts/utils/math/Math.sol";

contract NFTLendingV1Core {
    using Math for uint256;

    uint256 public constant LOAN_PERIOD = 180 * 1 days; // 180 days; loan period
    uint256 public numLoans; // total number of issued loans
    mapping(uint256 => Loan) public loans; // mapping from ids to loans
    mapping(address => uint256[]) public accountLoans; // mapping from accounts to loanIds
    mapping(address => NFTCollection) public nftCollections; // mapping from NFT addresses to NFTCollections
    address[] internal _acceptedNFTSet; // accepted NFT address set
    mapping(address => bool) internal _acceptedNFTs; // accepted NFT address mapping
    uint256 public lendableFunds; // total lendable funds

    enum Status {
        CREATED,
        REPAYED,
        LIQUIDATED
    }

    struct Loan {
        address borrower; // the loan initiator
        uint256 loanAmount; // the loan amount in native token
        uint256 interestRate; // the loan interest rate
        uint256 nftValue; // the value of the collateralized NFT
        address nftAddress; // the address of the NFT
        uint256 nftId; // the token id of the NFT
        uint8 nftType; // the NFT type; 0 for ERC721, 1 for ERC1155
        uint256 startTime; // loan starting time
        uint256 dueTime; // loan due time
        Status status; // the loan status
    }

    struct NFTCollection {
        uint8 nftType; // NFT type; 0 for ERC721 and 1 for ERC1155
        uint256 value; // NFT value in native token
        uint256 ltv; // loan to value ratio, e.g. 80, which represents 80%
        uint256 interestRate; // annual interest rate, e.g. 500, which represents 5%
        bool enabled; // indicates if the NFT is enabled for collateralized loans
    }

    event LoanCreated(
        address indexed borrower,
        uint256 indexed loanId,
        uint256 loanAmount,
        address nftAddress,
        uint256 nftId,
        uint8 nftType
    );

    event LoanRepayed(
        address indexed borrower,
        uint256 indexed loanId,
        uint256 interest
    );

    event LoanLiquidated(address sender, uint256 indexed loanId, address to);

    event NFTCollectionAdded(
        address nftAddress,
        uint8 nftType,
        uint256 value,
        uint256 ltv,
        uint256 intererstRate
    );

    event NFTCollectionEdited(
        address nftAddress,
        uint256 value,
        uint256 ltv,
        uint256 intererstRate
    );

    event NFTCollectionEnabled(address nftAddress);

    event NFTCollectionDisabled(address nftAddress);

    function calcLoanAmount(address nftAddress) public view returns (uint256) {
        return
            (nftCollections[nftAddress].value *
                nftCollections[nftAddress].ltv) / 100;
    }

    function calcLoanInterest(uint256 loanId)
        public
        view
        returns (uint256 timestamp, uint256 interest)
    {
        timestamp = block.timestamp;

        uint256 dailyInterest = (loans[loanId].loanAmount *
            loans[loanId].interestRate).ceilDiv(10000 * 365);

        uint256 loanTime = timestamp - loans[loanId].startTime;
        uint256 loanDays = loanTime > 0 ? loanTime.ceilDiv(1 days) : 1;

        interest = dailyInterest * loanDays;
    }
}
