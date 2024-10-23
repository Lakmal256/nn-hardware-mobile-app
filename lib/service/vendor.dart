import 'package:flutter/cupertino.dart';
import 'package:insee_hardware/service/dto/dto.dart';

class VendorService extends ValueNotifier<VendorDto?>{
  VendorService(super.value);

  setValue(VendorDto vendor){
    value = vendor;
  }
}