import Head from "next/head";
import { ethers } from "ethers";
import { useState, useEffect } from "react";
import axios from "axios";
import Web3Modal from "web3modal";

import { nftAddress, nftMarketplaceAddress } from "../config";
import NFT from "../artifacts/contracts/NFT.sol/NFT.json";
import Marketplace from "../artifacts/contracts/Marketplace.sol/Marketplace.json";

export default function Home() {
  const [nfts, setNfts] = useState([]);
  const [loadingState, setLoadingState] = useState("not-loaded");
  useEffect(() => {
    loadNfts();
  }, []);

  const loadNfts = async () => {
    const provider = new ethers.providers.JsonRpcProvider();
    const tokenContract = new ethers.Contract(nftAddress, NFT.abi, provider);
    const marketplaceContract = new ethers.Contract(
      nftMarketplaceAddress,
      Marketplace.abi,
      provider
    );

    const data = await marketplaceContract.fetchMarketItems();
    const items = await Promise.all(
      data.map(async (i: any) => {
        const tokenUri = await tokenContract.tokenURI(i.tokenId);
        const metaData = await axios.get(tokenUri); // getting the metadata json from the uri
        const price = ethers.utils.formatUnits(i.price.toString(), "ether");

        return {
          price,
          tokenId: i.tokenId.toNumber(),
          seller: i.seller,
          owner: i.owner,
          image: metaData.data.image,
          name: metaData.data.name,
          description: metaData.data.description,
        };
      })
    );
    setNfts(items as any);
    setLoadingState("loaded");
  };

  const buyNft = async (nft: any) => {
    const web3modal: any = new Web3Modal();
    const connection = await web3modal.connect();
    const provider = new ethers.providers.JsonRpcProvider();

    const signer = provider.getSigner(); // getting the signer for signing the transaction
    const marketplaceContract = new ethers.Contract(
      nftMarketplaceAddress,
      Marketplace.abi,
      signer
    );

    const price = ethers.utils.parseUnits(nft.price, "ether");
    const transaction = await marketplaceContract.createMarketSale(
      nftAddress,
      nft.tokenId,
      { value: price }
    );

    await transaction.wait();
    loadNfts();
  };

  if (loadingState === "loaded" && !nfts.length)
    return <h1 className="px-20 py-10 text-3xl">No items in marketplace</h1>;

  return (
    <>
      <Head>
        <title>Marketplace</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <div className="flex justify-center">
        <div className="px-4" style={{ maxWidth: "1600px" }}>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 pt-4">
            {nfts.map((nft: any, i) => (
              <div key={i} className="border shadow rounded-xl overflow-hidden">
                <img src={nft.image} />
                <div className="p-4">
                  <p
                    style={{ height: "64px" }}
                    className="text-2xl font-semibold"
                  >
                    {nft.name}
                  </p>
                  <div style={{ height: "70px", overflow: "hidden" }}>
                    <p className="text-gray-400">{nft.description}</p>
                  </div>
                </div>
                <div className="p-4 bg-black">
                  <p className="text-2xl mb-4 font-bold text-white">
                    {nft.price} ETH
                  </p>
                  <button
                    className="w-full bg-pink-500 text-white font-bold py-2 px-12 rounded"
                    onClick={() => buyNft(nft)}
                  >
                    Buy
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}
