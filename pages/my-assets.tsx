import { ethers } from "ethers";
import { useEffect, useState } from "react";
import axios from "axios";
import Web3Modal from "web3modal";

import { nftAddress, nftMarketplaceAddress } from "../config";

import Marketplace from "../artifacts/contracts/Marketplace.sol/Marketplace.json";
import NFT from "../artifacts/contracts/NFT.sol/NFT.json";

const MyAssets = () => {
  const [nfts, setNfts] = useState([]);
  const [loadingState, setLoadingState] = useState("not-loaded");

  useEffect(() => {
    loadNFTs();
  }, []);

  const loadNFTs = async () => {
    const web3modal: any = new Web3Modal();
    const connection = await web3modal.connect();
    const provider = new ethers.providers.JsonRpcProvider();
    const signer = provider.getSigner();

    const marketContract = new ethers.Contract(
      nftMarketplaceAddress,
      Marketplace.abi,
      signer
    );
    const tokenContract = new ethers.Contract(nftAddress, NFT.abi, provider);
    const data = await marketContract.fetchMyNFTs();
    const items: any = await Promise.all(
      data.map(async (i: any) => {
        const tokenUri = await tokenContract.tokenURI(i.tokenId);
        let meta: any = await axios.get(tokenUri);
        meta = JSON.parse(meta.data);
        let price = ethers.utils.formatUnits(i.price.toString(), "ether");
        let item = {
          price,
          tokenId: i.tokenId.toNumber(),
          seller: i.seller,
          owner: i.owner,
          image: meta.image,
        };
        return item;
      })
    );
    setNfts(items);
    setLoadingState("loaded");
  };

  if (loadingState === "loaded" && !nfts.length)
    return <h1 className="py-10 px-20 text-3xl">No assets owned</h1>;
  return (
    <div className="flex justify-center">
      <div className="p-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
          {nfts.map((nft: any, i) => (
            <div key={i} className="border shadow rounded-xl overflow-hidden">
              <img src={nft.image ? nft.image : ""} className="rounded" />
              <div className="p-4 bg-black">
                <p className="text-2xl font-bold text-white">
                  Price - {nft.price} Eth
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default MyAssets;
