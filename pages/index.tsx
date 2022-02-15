import Head from "next/head";
import Image from "next/image";
import styles from "../styles/Home.module.scss";
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

  if (loadingState === "loaded" && !nfts.length)
    return <h1 className="px-20 py-10 text-3xl">No items in marketplace</h1>;

  return (
    <div className={styles.container}>
      <Head>
        <title>Marketplace</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
    </div>
  );
}
