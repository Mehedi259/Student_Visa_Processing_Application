// lib/global/controller/settings/address_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../../model/settings/address_model.dart';
import '../../service/settings/address_service.dart';
import '../../utils/snackbar_utils.dart';

class AddressController extends GetxController {
  final isLoading = false.obs;
  final addresses = <AddressModel>[].obs;

  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();

  final selectedType = 'Residence'.obs;
  final selectedCountry = 'USA'.obs;

  String? currentAddressId;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  // Load all addresses
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final data = await AddressService.getAddresses();
      addresses.value = data;
    } catch (e) {
      print('Error loading addresses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Populate fields for editing
  void populateFields(AddressModel address) {
    currentAddressId = address.addressId;
    addressController.text = address.address ?? '';
    cityController.text = address.city ?? '';
    stateController.text = address.stateProvince ?? '';
    zipController.text = address.zipPostalCode ?? '';
    selectedType.value = address.addressType ?? 'Residence';
  }

  // Clear form fields
  void clearFields() {
    currentAddressId = null;
    addressController.clear();
    cityController.clear();
    stateController.clear();
    zipController.clear();
    selectedType.value = 'Residence';
    selectedCountry.value = 'USA';
  }

  // Save or update address
  Future<void> saveAddress(BuildContext context) async {
    if (currentAddressId == null) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'Address ID not found');
      }
      return;
    }

    try {
      isLoading.value = true;

      final address = AddressModel(
        address: addressController.text,
        city: cityController.text,
        stateProvince: stateController.text,
        zipPostalCode: zipController.text,
        county: '',
        addressType: selectedType.value,
        addressId: currentAddressId,
      );

      final success = await AddressService.updateAddress(currentAddressId!, address);

      if (success) {
        await loadAddresses();
        if (context.mounted) {
          SnackbarUtils.showSuccess(context, 'Address saved successfully');
          context.pop();
        }
      } else {
        if (context.mounted) {
          SnackbarUtils.showError(context, 'Failed to save address');
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showError(context, 'An error occurred');
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    super.onClose();
  }
}