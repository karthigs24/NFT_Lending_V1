// SPDX-License-Identifier: MIT
pragma solidity >=0.4.18 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./NFTLendingV1Core.sol";

contract NFTLendingV1Gov is Ownable, Pausable, NFTLendingV1Core {
    event FundDeposited(address sender, uint256 amount);
    event FundWithdrawn(address sender, uint256 amount, address to);
    event Upgraded(address newAddress);

    function addNFTCollection(
        address nftAddress,
        uint8 nftType,
        uint256 value,
        uint256 ltv,
        uint256 interestRate
    ) external onlyOwner {
        require(
            nftAddress != address(0),
            "NFTLendingV1Gov: NFT address can not be 0"
        );
        require(
            !_acceptedNFTs[nftAddress],
            "NFTLendingV1Gov: NFT collection already exists"
        );
        require(
            nftType == 0 || nftType == 1,
            "NFTLendingV1Gov: NFT type must be 0 or 1"
        );

        nftCollections[nftAddress] = NFTCollection(
            nftType,
            value,
            ltv,
            interestRate,
            true
        );

        _acceptedNFTSet.push(nftAddress);
        _acceptedNFTs[nftAddress] = true;

        emit NFTCollectionAdded(nftAddress, nftType, value, ltv, interestRate);
    }

    function editNFTCollection(
        address nftAddress,
        uint256 value,
        uint256 ltv,
        uint256 interestRate
    ) external onlyOwner {
        require(
            _acceptedNFTs[nftAddress],
            "NFTLendingV1Gov: NFT address does not exist"
        );

        nftCollections[nftAddress].value = value;
        nftCollections[nftAddress].ltv = ltv;
        nftCollections[nftAddress].interestRate = interestRate;

        emit NFTCollectionEdited(nftAddress, value, ltv, interestRate);
    }

    function enableNFTCollection(address nftAddress) external onlyOwner {
        require(
            _acceptedNFTs[nftAddress],
            "NFTLendingV1Gov: NFT collection does not exist"
        );
        require(
            !nftCollections[nftAddress].enabled,
            "NFTLendingV1Gov: NFT collection already enabled"
        );

        nftCollections[nftAddress].enabled = true;

        emit NFTCollectionEnabled(nftAddress);
    }

    function disableNFTCollection(address nftAddress) external onlyOwner {
        require(
            _acceptedNFTs[nftAddress],
            "NFTLendingV1Gov: NFT collection does not exist"
        );
        require(
            nftCollections[nftAddress].enabled,
            "NFTLendingV1Gov: NFT collection already disabled"
        );

        nftCollections[nftAddress].enabled = false;

        emit NFTCollectionDisabled(nftAddress);
    }

    function setLoanDueTimeForTest(uint256 loanId, uint256 dueTime)
        external
        onlyOwner
    {
        loans[loanId].dueTime = dueTime;
    }

    function depositFunds() external payable onlyOwner {
        require(msg.value > 0, "NFTLendingV1Gov: deposit amount can not be 0");

        lendableFunds += msg.value;

        emit FundDeposited(msg.sender, msg.value);
    }

    function withdrawFunds(uint256 amount, address payable to)
        external
        onlyOwner
    {
        require(
            to != address(0),
            "NFTLendingV1Gov: the recipient address can not be 0"
        );
        require(
            address(this).balance >= amount,
            "NFTLendingV1Gov: insufficient balance"
        );

        lendableFunds -= amount;

        to.transfer(amount);

        emit FundWithdrawn(msg.sender, amount, to);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function upgrade(address newAddress) external onlyOwner {
        emit Upgraded(newAddress);
    }
}
