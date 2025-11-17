import 'package:flutter/material.dart';
import 'package:smartlocker/models/package.dart';
import 'package:smartlocker/services/package_service.dart';
import 'package:smartlocker/utils/app_colors.dart';
import 'package:smartlocker/widgets/app_logo.dart';
import 'package:smartlocker/widgets/receiver_drawer.dart';

class PackageInputScreen extends StatefulWidget {
  const PackageInputScreen({super.key, this.package});

  final Package? package;

  bool get isEditing => package != null;

  @override
  State<PackageInputScreen> createState() => _PackageInputScreenState();
}

class _PackageInputScreenState extends State<PackageInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _packageNameController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _courierController = TextEditingController();
  final _lockerSlotController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  final PackageService _packageService = PackageService.instance;

  DateTime? _orderDate;
  DateTime? _deliveredDate;
  late PackageStatus _selectedStatus;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final package = widget.package;
    _selectedStatus = package?.status ?? PackageStatus.registered;
    if (package != null) {
      _packageNameController.text = package.packageName;
      _trackingNumberController.text = package.trackingNumber;
      _courierController.text = package.courier ?? '';
      _lockerSlotController.text = package.lockerSlot ?? '';
      _receiverNameController.text = package.receiverName ?? '';
      _receiverPhoneController.text = package.receiverPhone ?? '';
      _notesController.text = package.notes ?? '';
      _orderDate = package.orderDate;
      _deliveredDate = package.deliveredDate;
    }
  }

  @override
  void dispose() {
    _packageNameController.dispose();
    _trackingNumberController.dispose();
    _courierController.dispose();
    _lockerSlotController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isOrderDate}) async {
    final now = DateTime.now();
    final initial = isOrderDate ? _orderDate : _deliveredDate;
    final selected = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (selected != null) {
      setState(() {
        if (isOrderDate) {
          _orderDate = selected;
        } else {
          _deliveredDate = selected;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final result = widget.isEditing
          ? await _packageService.updatePackage(
              id: widget.package!.id,
              packageName: _packageNameController.text.trim(),
              trackingNumber: _trackingNumberController.text.trim(),
              courier: _courierController.text.trim().isEmpty
                  ? null
                  : _courierController.text.trim(),
              orderDate: _orderDate,
              deliveredDate: _deliveredDate,
              status: _selectedStatus,
              lockerSlot: _lockerSlotController.text.trim().isEmpty
                  ? null
                  : _lockerSlotController.text.trim(),
              receiverName: _receiverNameController.text.trim().isEmpty
                  ? null
                  : _receiverNameController.text.trim(),
              receiverPhone: _receiverPhoneController.text.trim().isEmpty
                  ? null
                  : _receiverPhoneController.text.trim(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            )
          : await _packageService.createPackage(
              packageName: _packageNameController.text.trim(),
              trackingNumber: _trackingNumberController.text.trim(),
              courier: _courierController.text.trim().isEmpty
                  ? null
                  : _courierController.text.trim(),
              orderDate: _orderDate,
              deliveredDate: _deliveredDate,
              status: _selectedStatus,
              lockerSlot: _lockerSlotController.text.trim().isEmpty
                  ? null
                  : _lockerSlotController.text.trim(),
              receiverName: _receiverNameController.text.trim().isEmpty
                  ? null
                  : _receiverNameController.text.trim(),
              receiverPhone: _receiverPhoneController.text.trim().isEmpty
                  ? null
                  : _receiverPhoneController.text.trim(),
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing ? 'Package updated.' : 'Package registered.',
          ),
        ),
      );
      Navigator.pop(context, result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save package: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const AppTextLogo(height: 28),
            const SizedBox(width: 8),
            Text(widget.isEditing ? 'Edit Package' : 'Add New Package'),
          ],
        ),
      ),
      drawer: const ReceiverDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _packageNameController,
                decoration: const InputDecoration(
                  labelText: 'Package Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter package name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _trackingNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tracking Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter tracking number'
                    : null,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PackageStatus>(
                    value: _selectedStatus,
                    items: PackageStatus.values
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courierController,
                decoration: const InputDecoration(
                  labelText: 'Courier (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              _buildDatePickerTile(
                label: 'Order Date',
                value: _orderDate,
                onTap: () => _pickDate(isOrderDate: true),
                clearValue: () => setState(() => _orderDate = null),
              ),
              const SizedBox(height: 16),
              _buildDatePickerTile(
                label: 'Delivered Date',
                value: _deliveredDate,
                onTap: () => _pickDate(isOrderDate: false),
                clearValue: () => setState(() => _deliveredDate = null),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lockerSlotController,
                decoration: const InputDecoration(
                  labelText: 'Locker Slot',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiverNameController,
                decoration: const InputDecoration(
                  labelText: 'Receiver Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiverPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Receiver Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.isEditing ? 'Update Package' : 'Save Package',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerTile({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required VoidCallback clearValue,
  }) {
    final text = value == null
        ? 'Tap to select date'
        : '${value.day}/${value.month}/${value.year}';
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: clearValue,
                ),
        ),
        child: Text(text),
      ),
    );
  }
}
