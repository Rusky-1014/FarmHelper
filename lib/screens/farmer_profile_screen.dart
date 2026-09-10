import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _preferredCrop = 'Both';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('farmer_name') ?? '';
      _locationCtrl.text = prefs.getString('farmer_location') ?? '';
      _phoneCtrl.text = prefs.getString('farmer_phone') ?? '';
      _preferredCrop = prefs.getString('farmer_crop') ?? 'Both';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('farmer_name', _nameCtrl.text.trim());
    await prefs.setString('farmer_location', _locationCtrl.text.trim());
    await prefs.setString('farmer_phone', _phoneCtrl.text.trim());
    await prefs.setString('farmer_crop', _preferredCrop);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text('Profile saved ✓',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF2DBD6E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    '👨‍🌾 FARMER PROFILE',
                    style: TextStyle(
                      color: Color(0xFF2DBD6E),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            if (_loading)
              const Expanded(
                child: Center(
                  child:
                      CircularProgressIndicator(color: Color(0xFF2DBD6E)),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Avatar
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2DBD6E).withOpacity(0.12),
                          border: Border.all(
                              color: const Color(0xFF2DBD6E).withOpacity(0.4),
                              width: 2),
                        ),
                        child: const Center(
                          child:
                              Text('👨‍🌾', style: TextStyle(fontSize: 38)),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Name
                      _ProfileField(
                        icon: Icons.person_outline_rounded,
                        label: 'Your Name',
                        hint: 'e.g. Ramesh Patel',
                        controller: _nameCtrl,
                        keyboardType: TextInputType.name,
                      ),

                      const SizedBox(height: 14),

                      // Location
                      _ProfileField(
                        icon: Icons.location_on_outlined,
                        label: 'Farm Location',
                        hint: 'e.g. Nagpur, Maharashtra',
                        controller: _locationCtrl,
                        keyboardType: TextInputType.streetAddress,
                      ),

                      const SizedBox(height: 14),

                      // Phone
                      _ProfileField(
                        icon: Icons.phone_outlined,
                        label: 'Phone Number (optional)',
                        hint: 'e.g. 9876543210',
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 14),

                      // Preferred crop dropdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.07)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.grass_rounded,
                                    color: const Color(0xFF2DBD6E),
                                    size: 20),
                                const SizedBox(width: 10),
                                const Text(
                                  'Preferred Crop',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _preferredCrop,
                              dropdownColor: const Color(0xFF1C2128),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                              items: ['Mango', 'Grape', 'Both']
                                  .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _preferredCrop = v!),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save button
                      GestureDetector(
                        onTap: _saveProfile,
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF2DBD6E),
                                Color(0xFF1A8A4A),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF2DBD6E).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'SAVE PROFILE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _ProfileField({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2DBD6E), size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.25), fontSize: 14),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}