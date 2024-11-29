import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart'; // HTTP client
import 'package:flutter/services.dart'; // For loading the ABI file

class BlockchainService {
  final String _rpcUrl = "http://127.0.0.1:8545";  // Ganache RPC URL
  final String _contractAddress = "0x985C8E7027f04E42be8c56bA171dAd43e4eaFbC9";  // Contract address
  final String _privateKey = "0xdc1234f1adcc42cebc3e581bdf2d950a807bfb68182011e2ba23a48082456dfe"; // Private key for signing transactions

  late Web3Client _client;
  late EthereumAddress _contractAddr;
  late DeployedContract _contract;
  bool _isInitialized = false;

  BlockchainService() {
    _client = Web3Client(_rpcUrl, Client());
    _contractAddr = EthereumAddress.fromHex(_contractAddress);
  }

  // Initialization method to load ABI and contract
  Future<void> init() async {
    try {
      final abi = await _loadAbi();
      _contract = DeployedContract(
        ContractAbi.fromJson(abi, "AttendanceContract"),  // Contract name in ABI
        _contractAddr,
      );
      _isInitialized = true;  // Set to true after successful initialization
    } catch (e) {
      print("Error during initialization: $e");
    }
  }

  // Check if contract is initialized
  bool get isInitialized => _isInitialized;

  // Load ABI from the assets folder
  Future<String> _loadAbi() async {
    return await rootBundle.loadString('src/artifacts/Attendance.json');  // Ensure correct path
  }

  // Mark attendance method
  Future<void> markAttendance(String studentAddress, bool isPresent) async {
    if (!_isInitialized) {
      throw Exception("Contract not initialized yet.");
    }

    try {
      final student = EthereumAddress.fromHex(studentAddress);

      final markAttendanceFunction = _contract.function("markAttendance");

      final credentials = EthPrivateKey.fromHex(_privateKey);
      await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: _contract,
          function: markAttendanceFunction,
          parameters: [student, isPresent],
        ),
        chainId: 1337,  // Ganache chain ID
      );
    } catch (e) {
      print("Error during transaction: $e");
    }
  }
}
