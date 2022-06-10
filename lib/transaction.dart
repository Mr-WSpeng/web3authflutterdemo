/*
 * @Author: 王赛鹏
 * @Date: 2022-06-08 20:32:34
 * @FilePath: /web3authflutterdemo/lib/transaction.dart
 * @Description: 
 */

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:web3auth_flutter/web3auth_flutter.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class TransactionPage extends StatefulWidget {
  final Web3AuthResponse response;
  const TransactionPage({Key? key, required this.response}) : super(key: key);
  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  static const titleStyle =
      TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  TextStyle contentStyle = const TextStyle(fontSize: 15);
  final FocusNode _focusNode = FocusNode(); //输入框焦点控制
  final TextEditingController _addressController =
      TextEditingController(); //输入框控制
  final FocusNode _numberFocusNode = FocusNode(); //输入框焦点控制
  final TextEditingController _numberController =
      TextEditingController(); //输入框控制

  bool canTransaction = false;
  var address = '';
  var balance = 0.0;
  var tranctionNumber = 0.0;
  String transactionResult = '';
  @override
  void initState() {
    _initCredentials();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'name',
                style: titleStyle,
              ),
              Text(
                widget.response.userInfo.name ?? "",
                style: contentStyle,
              ),
              const SizedBox(height: 20),
              const Text(
                'balance',
                style: titleStyle,
              ),
              Text(
                '${balance.toString()} ETH',
                style: contentStyle,
              ),
              const SizedBox(height: 20),
              const Text(
                'privateKey',
                style: titleStyle,
              ),
              Text(
                widget.response.privKey,
                style: contentStyle,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'adress',
                style: titleStyle,
              ),
              Text(
                address,
                style: contentStyle,
              ),
              const SizedBox(height: 20),
              const Text(
                'Transaction',
                style: titleStyle,
              ),
              TextField(
                focusNode: _focusNode,
                controller: _addressController,
                maxLines: 1,
                // keyboardType: TextInputType.multiline,
                keyboardAppearance: Brightness.dark,
                maxLength: 100,
                cursorColor: Colors.black,
                onChanged: (text) {
                  setState(_changeButtonState);
                },
                style: const TextStyle(fontSize: 15, color: Colors.black),
                decoration: const InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey, //Color.fromRGBO(45, 46, 57, 1),
                  counterText: "", //右下角显示
                  hintText: 'Please input adress',
                  hintStyle: TextStyle(color: Color(0xFF5F6275)),
                  contentPadding:
                      EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                focusNode: _numberFocusNode,
                controller: _numberController,
                keyboardType: TextInputType.number,
                maxLines: 1,
                keyboardAppearance: Brightness.dark,
                maxLength: 100,
                cursorColor: Colors.black,
                onChanged: (text) {
                  setState(_changeButtonState);
                },
                style: const TextStyle(fontSize: 15, color: Colors.black),
                decoration: const InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey, //Color.fromRGBO(45, 46, 57, 1),
                  counterText: "", //右下角显示
                  hintText: 'Please input number',
                  hintStyle: TextStyle(color: Color(0xFF5F6275)),
                  contentPadding:
                      EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              GestureDetector(
                onTap: _transactionAction,
                child: Text(
                  '确认转账',
                  style: TextStyle(
                      color: canTransaction ? Colors.red : Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Text(transactionResult, style: contentStyle)
            ],
          ),
        ));
  }

  void _changeButtonState() {
    if (_addressController.text.isEmpty || _numberController.text.isEmpty) {
      canTransaction = false;
      return;
    }
    if (_addressController.text.startsWith('0x') &&
        (double.parse(_numberController.text) > 0) &&
        (double.parse(_numberController.text) <= balance)) {
      canTransaction = true;
    } else {
      canTransaction = false;
    }
  }

  void _initCredentials() async {
    Credentials credentials = EthPrivateKey.fromHex(widget.response.privKey);
    var ehereumAddress = await credentials.extractAddress();
    var apiUrl =
        "https://rinkeby.infura.io/v3/21ead65c912e442c936cc818da30a81c"; //Replace with your API
    address = ehereumAddress.toString();
    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);

    EtherAmount amount = await ethClient.getBalance(ehereumAddress);
    setState(() {
      balance = amount.getInWei / BigInt.from(10).pow(18);
    });
  }

  void _transactionAction() async {
    if (!canTransaction) {
      return;
    }
    Credentials fromHex = EthPrivateKey.fromHex(widget.response.privKey);
    var apiUrl =
        "https://rinkeby.infura.io/v3/21ead65c912e442c936cc818da30a81c"; //Replace with your API

    var httpClient = Client();
    var ethClient = Web3Client(apiUrl, httpClient);
// 0xA5a38c207801A3d933Bfc0D6b42A24Dc4e2AE07D
    var number =
        double.parse(_numberController.text) * BigInt.from(10).pow(18).toInt();
    transactionResult = await ethClient.sendTransaction(
        fromHex,
        Transaction(
          to: EthereumAddress.fromHex(_addressController.text),
          value: EtherAmount.fromUnitAndValue(EtherUnit.wei, number.toInt()),
        ),
        chainId: 4);
    setState(() {});
    print(transactionResult);
  }
}
