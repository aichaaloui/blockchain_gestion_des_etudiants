module.exports = {
  networks: {
    development: {
      host: "127.0.0.1", // Localhost
      port: 7545,        // Port standard utilisé par Ganache
      network_id: "*",   // Permet de se connecter à n'importe quel réseau
    },
  },
  contracts_build_directory: "./src/artifacts/", // Répertoire des artefacts

  compilers: {
    solc: {
      version: "0.5.16", // Version exacte du compilateur Solidity
      settings: {
        optimizer: {
          enabled: false, // Désactiver l'optimisation
          runs: 200       // Nombre d'exécutions d'optimisation
        },
        evmVersion: "byzantium", // Version de l'EVM
      }
    }
  },

  mocha: {
    // timeout: 100000
  },
};
