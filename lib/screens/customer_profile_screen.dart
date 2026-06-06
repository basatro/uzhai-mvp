import 'package:flutter/material.dart';
import '../widgets/customer_bottom_nav.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  static const Color primaryBlue = Color(0xFF1E88E5);
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// PROFILE HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _box(),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryBlue,
                  child: Text(
                    "R",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ramesh Kumar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "+91 98765 43210",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "#12, Main Street, Anna Nagar, Chennai",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("Edit Profile"),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle("General"),

          _tile(
            icon: Icons.language,
            title: "Language",
            subtitle: "English / Tamil",
            trailing: const Text(
              "English",
              style: TextStyle(color: Colors.grey),
            ),
          ),

          _switchTile(
            icon: Icons.notifications,
            title: "Notifications",
            value: notificationsEnabled,
            onChanged: (v) {
              setState(() => notificationsEnabled = v);
            },
          ),

          _tile(
            icon: Icons.location_on,
            title: "Location Permissions",
            subtitle: "Used to find nearby technicians",
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Allowed",
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          _tile(icon: Icons.lock, title: "Privacy & Policy"),
          _tile(icon: Icons.description, title: "Terms & Conditions"),

          const SizedBox(height: 24),

          _sectionTitle("Support"),

          _tile(icon: Icons.help_outline, title: "Help & Support"),
          _tile(
            icon: Icons.phone,
            title: "Contact Us",
            subtitle: "Phone / WhatsApp / Email",
          ),

          const SizedBox(height: 24),

          _sectionTitle("App Info"),

          _tile(
            icon: Icons.info_outline,
            title: "App Version",
            subtitle: "v1.0.0",
            showArrow: false,
          ),

          const SizedBox(height: 24),

          /// LOGOUT
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: const CustomerBottomNav(currentIndex: 3),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Yes, Logout"),
          ),
        ],
      ),
    );
  }
}

/// ================= REUSABLE WIDGETS =================

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );
}

Widget _tile({
  required IconData icon,
  required String title,
  String? subtitle,
  Widget? trailing,
  bool showArrow = true,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: _box(),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE3F2FD),
        child: Icon(icon, color: Color(0xFF1E88E5)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ??
          (showArrow
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : null),
      onTap: () {},
    ),
  );
}

Widget _switchTile({
  required IconData icon,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: _box(),
    child: SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF1E88E5),
      title: Text(title),
      secondary: CircleAvatar(
        backgroundColor: const Color(0xFFE3F2FD),
        child: Icon(icon, color: Color(0xFF1E88E5)),
      ),
    ),
  );
}

BoxDecoration _box() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: Colors.grey.shade200),
  );
}
