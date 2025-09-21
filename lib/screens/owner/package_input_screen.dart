import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/services/package_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageInputScreen extends StatefulWidget {
  final Package? package; // For editing, null for new package

  const PackageInputScreen({super.key, this.package});

  @override
  State<PackageInputScreen> createState() => _PackageInputScreenState();
}

class _PackageInputScreenState extends State<PackageInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _trackingNumberController = TextEditingController();
  final _packageNameController = TextEditingController();
  final _courierController = TextEditingController();
  late DateTime _selectedDate;
  final PackageService _packageService = PackageService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    
    // If editing existing package, populate fields
    if (widget.package != null) {
      _trackingNumberController.text = widget.package!.trackingNumber;
      _packageNameController.text = widget.package!.packageName;
      _courierController.text = widget.package!.courier ?? '';
      _selectedDate = widget.package!.orderDate ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _packageNameController.dispose();
    _courierController.dispose();
    super.dispose();
  }

  void _savePackage() {
    if (_formKey.currentState!.validate()) {
      if (widget.package == null) {
        // Add new package
        _packageService.addPackage(
          _trackingNumberController.text,
          _packageNameController.text,
          courier: _courierController.text,
          orderDate: _selectedDate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package added successfully!')),
        );
      } else {
        // Update existing package
        _packageService.updatePackage(
          widget.package!.id,
          _trackingNumberController.text,
          _packageNameController.text,
          courier: _courierController.text,
          orderDate: _selectedDate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Package updated successfully!')),
        );
      }
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  void _deletePackage() {
    if (widget.package != null) {
      _packageService.deletePackage(widget.package!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Package deleted successfully!')),
      );
      Navigator.pop(context, true); // Return true to indicate success
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.package == null ? 'Add New Package' : 'Edit Package'),
        actions: widget.package != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Package'),
                          content: const Text('Are you sure you want to delete this package?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              onPressed: () {
                                Navigator.of(context).pop();
                                _deletePackage();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ]
            : null,
      ),
      drawer: const ReceiverDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _trackingNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tracking Number (Resi)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a tracking number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _packageNameController,
                decoration: const InputDecoration(
                  labelText: 'Package Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a package name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courierController,
                decoration: const InputDecoration(
                  labelText: 'Courier',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Order Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePackage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.package == null ? 'Add Package' : 'Update Package',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}