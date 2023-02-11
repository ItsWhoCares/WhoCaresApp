export const generateKeyPair = async () => {
  const { generateKeyPair } = await import("crypto");
  const { publicKey, privateKey } = generateKeyPair("rsa", {
    modulusLength: 4096,
    publicKeyEncoding: {
      type: "spki",
      format: "pem",
    },
    privateKeyEncoding: {
      type: "pkcs8",
      format: "pem",
      cipher: "aes-256-cbc",
      passphrase: "",
    },
  });
  return { publicKey, privateKey };
};
