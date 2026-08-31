import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class InviteStaffScreen extends StatefulWidget {
  final PieCrewUser currentUser;
  const InviteStaffScreen({super.key, required this.currentUser});

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  UserRole _role = UserRole.staff;
  bool _loading = false;
  String? _error;
  String? _successName;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _successName = null;
    });
    try {
      final auth = AuthService();
      await auth.inviteStaff(
        email: _emailCtrl.text.trim(),
        tempPassword: _passwordCtrl.text.trim(),
        displayName: _nameCtrl.text.trim(),
        locationId: widget.currentUser.locationId,
        role: _role,
      );
      setState(() {
        _successName = _nameCtrl.text.trim();
        _nameCtrl.clear();
        _emailCtrl.clear();
        _passwordCtrl.clear();
        _role = UserRole.staff;
      });
    } catch (e) {
      setState(() => _error = "Could not create that account. Check the email isn't already in use.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite team member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Adding a team member at your location. They'll sign in with the "
                'email and temporary password you set below.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PieCrewColors.inkMuted),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Temporary password',
                  helperText: 'At least 6 characters. Share this with them directly.',
                ),
                validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: UserRole.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v ?? UserRole.staff),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: PieCrewColors.pie, fontSize: 13)),
              ],
              if (_successName != null) ...[
                const SizedBox(height: 16),
                Text('$_successName has been added.',
                    style: const TextStyle(color: PieCrewColors.basil, fontWeight: FontWeight.w600)),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add team member'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
