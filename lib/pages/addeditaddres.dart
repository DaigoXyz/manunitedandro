import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shippingaddressmodel.dart';
import '../services/address_service.dart';

class AddEditAddressPage extends StatefulWidget {
  final ShippingAddress? address; // null = add mode, not null = edit mode

  const AddEditAddressPage({super.key, this.address});

  @override
  State<AddEditAddressPage> createState() => _AddEditAddressPageState();
}

class _AddEditAddressPageState extends State<AddEditAddressPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _provinceController;
  late TextEditingController _postalCodeController;
  late TextEditingController _phoneController;

  bool isLoading = false;
  bool get isEditMode => widget.address != null;

  // List of Indonesian provinces
  final List<String> provinces = [
    'Aceh',
    'Sumatera Utara',
    'Sumatera Barat',
    'Riau',
    'Kepulauan Riau',
    'Jambi',
    'Sumatera Selatan',
    'Kepulauan Bangka Belitung',
    'Bengkulu',
    'Lampung',
    'DKI Jakarta',
    'Jawa Barat',
    'Banten',
    'Jawa Tengah',
    'DI Yogyakarta',
    'Jawa Timur',
    'Bali',
    'Nusa Tenggara Barat',
    'Nusa Tenggara Timur',
    'Kalimantan Barat',
    'Kalimantan Tengah',
    'Kalimantan Selatan',
    'Kalimantan Timur',
    'Kalimantan Utara',
    'Sulawesi Utara',
    'Gorontalo',
    'Sulawesi Tengah',
    'Sulawesi Selatan',
    'Sulawesi Barat',
    'Sulawesi Tenggara',
    'Maluku',
    'Maluku Utara',
    'Papua',
    'Papua Barat',
    'Papua Selatan',
    'Papua Tengah',
    'Papua Pegunungan',
    'Papua Barat Daya',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data if editing
    _addressController = TextEditingController(
      text: widget.address?.address ?? '',
    );
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _provinceController = TextEditingController(
      text: widget.address?.province ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.address?.postalCode ?? '',
    );
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isEditMode) {
        // Update existing address
        await AddressService.updateAddress(
          id: widget.address!.id,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          province: _provinceController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      } else {
        // Create new address
        await AddressService.createAddress(
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          province: _provinceController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          phone: _phoneController.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Alamat berhasil diperbarui'
                  : 'Alamat berhasil ditambahkan',
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan alamat: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showProvinceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Provinsi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
            // Province list
            Expanded(
              child: ListView.builder(
                itemCount: provinces.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(provinces[index]),
                    trailing: _provinceController.text == provinces[index]
                        ? const Icon(Icons.check, color: Color(0xFF8B1A1A))
                        : null,
                    onTap: () {
                      setState(() {
                        _provinceController.text = provinces[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? 'Edit Alamat' : 'Tambah Alamat',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone Number
                    _buildSectionTitle('Nomor Telepon'),
                    const SizedBox(height: 8),
                    _buildPhoneField(),
                    const SizedBox(height: 20),

                    // Province
                    _buildSectionTitle('Provinsi'),
                    const SizedBox(height: 8),
                    _buildProvinceSelector(),
                    const SizedBox(height: 20),

                    // City
                    _buildSectionTitle('Kota/Kabupaten'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _cityController,
                      hint: 'Contoh: Kota Jakarta Timur',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kota/Kabupaten tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Postal Code
                    _buildSectionTitle('Kode Pos'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _postalCodeController,
                      hint: 'Contoh: 13890',
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kode pos tidak boleh kosong';
                        }
                        if (value.length < 5) {
                          return 'Kode pos minimal 5 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Full Address
                    _buildSectionTitle('Alamat Lengkap'),
                    const SizedBox(height: 8),
                    _buildAddressField(),
                    const SizedBox(height: 20),

                    // Tips
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFFFA000),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Pastikan alamat lengkap dan jelas agar kurir dapat menemukan lokasi dengan mudah.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        counterText: '',
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B1A1A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      maxLength: 20,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
      ],
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Contoh: 08111222208',
        hintStyle: TextStyle(color: Colors.grey[400]),
        counterText: '',
        filled: true,
        fillColor: Colors.grey[100],
        prefixIcon: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://flagcdn.com/w20/id.png',
                width: 24,
                height: 16,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('🇮🇩', style: TextStyle(fontSize: 16));
                },
              ),
              const SizedBox(width: 8),
              Text(
                '+62',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(height: 24, width: 1, color: Colors.grey[300]),
            ],
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B1A1A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nomor telepon tidak boleh kosong';
        }
        if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
          return 'Nomor telepon minimal 9 digit';
        }
        return null;
      },
    );
  }

  Widget _buildProvinceSelector() {
    return GestureDetector(
      onTap: _showProvinceSelector,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _provinceController,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Pilih provinsi',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF8B1A1A),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Provinsi tidak boleh kosong';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      maxLength: 255,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan',
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B1A1A), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Alamat tidak boleh kosong';
        }
        if (value.trim().length < 10) {
          return 'Alamat terlalu pendek, minimal 10 karakter';
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _saveAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1A1A),
              disabledBackgroundColor: Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isEditMode ? 'Simpan Perubahan' : 'Simpan Alamat',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
