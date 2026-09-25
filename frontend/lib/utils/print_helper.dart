import 'print_receipt_stub.dart'
    if (dart.library.html) 'print_receipt_web.dart';

void triggerPrint() {
  printReceiptWeb();
}
