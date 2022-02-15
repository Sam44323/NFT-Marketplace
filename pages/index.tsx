import Head from "next/head";
import Image from "next/image";
import styles from "../styles/Home.module.scss";
import { ethers } from "ethers";
import { useState, useEffect } from "react";
import axios from "axios";
import Web3Modal from "web3modal";

export default function Home() {
  return (
    <div className={styles.container}>
      <Head>
        <title>Marketplace</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
    </div>
  );
}
