import { useMoralis } from "react-moralis";
import { useEffect } from "react";
import { useRouter } from "next/router";

const Authenticate = () => {
  const { isAuthenticated, authenticate } = useMoralis();
  const router = useRouter();

  useEffect(() => {
    if (isAuthenticated) {
      router.replace("/");
    }
  }, []);

  return (
    <div
      style={{
        textAlign: "center",
      }}
    >
      <button
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
        onClick={async () => {
          await authenticate();
          router.replace("/");
        }}
      >
        Login
      </button>
    </div>
  );
};

export default Authenticate;
