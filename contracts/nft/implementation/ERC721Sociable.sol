// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../utils/Context.sol";
import "./ERC165.sol";
import "../interfaces/IERC721.sol";
import "../interfaces/IERC721Metadata.sol";
import "../interfaces/IERC721Sociable.sol";
import "../interfaces/IERC721Receiver.sol";
import "../../utils/Strings.sol";
import "../../utils/Address.sol";

contract ERC721Sociable is Context, ERC165, IERC721Sociable {
    using Address for address;
    using Strings for uint256;

    // token name
    string private _name;

    // token symbol
    string private _symbol;

    // mapping from token ID to TokenData type
    mapping(uint256 => TokenData) private _tokenDatas;

    // mapping from owner addres to token count
    mapping(address => uint256) private _balances;

    // mapping from owner to operator to is approved
    mapping(address => mapping(address => bool)) _operatorApprovals;

    /// @dev Initializes the contract by setting a `name` and a `symbol` to the token collection
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /// @dev See {IERC721-supportsInterface}.
    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual
        override(ERC165, IERC165)
        returns (bool)
    {
        return
            interfaceId_ == type(IERC721).interfaceId ||
            interfaceId_ == type(IERC721Metadata).interfaceId ||
            interfaceId_ == type(IERC721Sociable).interfaceId ||
            super.supportsInterface(interfaceId_);
    }

    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        if (owner == address(0)) revert ERC721__AddressZeroIsNotValid();

        return _balances[owner];
    }

    function ownerOf(uint256 tokenId)
        public
        view
        virtual
        override
        returns (address)
    {
        address owner = _tokenDatas[tokenId]._owner;
        if (owner == address(0)) revert ERC721__InvalidTokenId();
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenDatas[tokenId]._tokenURI;
        string memory base = _baseURI();

        // if there is no base URI, return the token URI
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // if both are set, concatenate the baseURI and tokenURI
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function tokenData(uint256 tokenId)
        public
        view
        virtual
        override
        returns (TokenData memory)
    {
        _requireMinted(tokenId);
        return _tokenDatas[tokenId];
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        if (!_exists(tokenId)) revert ERC721__InvalidTokenId();

        _tokenDatas[tokenId]._tokenURI = _tokenURI;
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId); /*ERC721.*/
        if (to == owner) revert ERC721__ApprovalToCurrentOwner();

        if (_msgSender() != owner && !isApprovedForAll(owner, _msgSender()))
            revert ERC721__NotOwnerNorApprovedForAll();

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId_)
        public
        view
        virtual
        override
        returns (address)
    {
        _requireMinted(tokenId_);

        return _tokenDatas[tokenId_]._approval;
    }

    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
    {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner_, address operator_)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _operatorApprovals[owner_][operator_];
    }

    function transferFrom(
        address from_,
        address to_,
        uint256 tokenId_
    ) public virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId_))
            revert ERC721__NotOwnerNorApproved();

        _transfer(from_, to_, tokenId_);
    }

    function safeTransferFrom(
        address from_,
        address to_,
        uint256 tokenId_,
        bytes memory data_
    ) public virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId_))
            revert ERC721__NotOwnerNorApproved();

        _safeTransfer(from_, to_, tokenId_, data_);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, data))
            revert ERC721__TransferToNonERC721Receiver();
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _tokenDatas[tokenId]._owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        virtual
        returns (bool)
    {
        address owner = ownerOf(tokenId); /*ERC721.*/
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        if (!_checkOnERC721Received(address(0), to, tokenId, data))
            revert ERC721__TransferToNonERC721Receiver();
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        if (to == address(0)) revert ERC721__MintToZeroAddress();
        if (_exists(tokenId)) revert ERC721__TokenAlreadyMinted();

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _tokenDatas[tokenId]._owner = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId); /*ERC721.*/

        _beforeTokenTransfer(owner, address(0), tokenId);

        // to clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _tokenDatas[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        if (
            /*ERC721.*/
            ownerOf(tokenId) != from
        ) revert ERC721__TransferFromIncorrectOwner();
        if (to == address(0)) revert ERC721__TransferToZeroAddress();

        _beforeTokenTransfer(from, to, tokenId);

        // clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _tokenDatas[tokenId]._owner = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenDatas[tokenId]._approval = to;
        emit Approval(
            /*ERC721.*/
            ownerOf(tokenId),
            to,
            tokenId
        );
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        if (owner == operator) revert ERC721__ApprovalToCurrentOwner();
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _requireMinted(uint256 tokenId) internal view virtual {
        if (!_exists(tokenId)) revert ERC721__InvalidTokenId();
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    _msgSender(),
                    from,
                    tokenId,
                    data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721__TransferToNonERC721Receiver();
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}
