import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light));
  runApp(const MenuAimApp());
}

class MenuAimApp extends StatelessWidget {
  const MenuAimApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0B0E14), primaryColor: const Color(0xFF00E5FF)),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isBridgeConnected = false;
  String _selectedGame = 'FF thường';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomePage(onGameChanged: (val) => setState(() => _selectedGame = val), selectedGame: _selectedGame, isConnected: _isBridgeConnected),
          const FeaturesPage(),
          ConfigPage(onConnect: (status) => setState(() => _isBridgeConnected = status), isConnected: _isBridgeConnected),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1E232F), width: 1))),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: const Color(0xFF0B0E14),
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'TRANG CHỦ'),
            BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'TÍNH NĂNG'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_applications), label: 'CẤU HÌNH'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Function(String) onGameChanged;
  final String selectedGame;
  final bool isConnected;
  const HomePage({super.key, required this.onGameChanged, required this.selectedGame, required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('MENU AIM', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [Text('ID\n69FEFAC7', style: TextStyle(fontSize: 10, color: Colors.grey)), SizedBox(width: 8), Icon(Icons.person_outline, color: Colors.white70)]),
                )
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(children: [
                Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: isConnected ? const Color(0xFF00E5FF) : Colors.grey, width: 2),
                    boxShadow: isConnected ? [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.5), blurRadius: 20)] : [],
                  ),
                  child: Center(child: Icon(Icons.gps_fixed, size: 50, color: isConnected ? const Color(0xFF00E5FF) : Colors.grey)),
                ),
                const SizedBox(height: 10),
                Text(isConnected ? 'HỆ THỐNG ĐÃ KẾT NỐI' : 'CHƯA KẾT NỐI', style: TextStyle(color: isConnected ? const Color(0xFF00E5FF) : Colors.grey, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 30),
            const Text('Chọn Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Column(children: ['FF thường', 'FF Max', 'FF VN'].map((game) {
              return RadioListTile<String>(
                title: Text(game, style: const TextStyle(color: Colors.white)),
                value: game, groupValue: selectedGame, activeColor: const Color(0xFF00E5FF), contentPadding: EdgeInsets.zero,
                onChanged: (val) { if (val != null) onGameChanged(val); },
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}

class FeaturesPage extends StatefulWidget {
  const FeaturesPage({super.key});
  @override
  State<FeaturesPage> createState() => _FeaturesPageState();
}

class _FeaturesPageState extends State<FeaturesPage> {
  bool _markerEnabled = false;
  bool _aimPointEnabled = true;
  double _aimHeight = 68.0;
  bool _antibanEnabled = true;
  bool _hideAppEnabled = false;
  static const platform = MethodChannel('com.sgcodexs.menuaim/native');

  void _updateAimConfig() async {
    double sensMultiplier = 1.0 + (_aimHeight / 100);
    double yMultiplier = 1.0 + (_aimHeight / 200);
    await platform.invokeMethod('updateAimConfig', {'sensitivity': sensMultiplier, 'yMultiplier': yMultiplier});
  }

  void _toggleAntiban(bool enabled) async { await platform.invokeMethod('toggleAntiban', {'enable': enabled}); }
  void _toggleHideApp(bool enabled) async { await platform.invokeMethod('hideApp', {'enable': enabled}); }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('FEATURES', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildFeatureCard(title: '01 MARKER', subtitle: 'marks every enemy on your screen.', isEnabled: _markerEnabled, onToggle: (val) => setState(() => _markerEnabled = val), child: const Text('Marker active', style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 16),
            _buildFeatureCard(
              title: '02 AIMPOINT', subtitle: 'moves your aim from the chest toward the head.',
              isEnabled: _aimPointEnabled, onToggle: (val) => setState(() => _aimPointEnabled = val),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('AIM HEIGHT', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text('NECK ${_aimHeight.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ]),
                Slider(value: _aimHeight, min: 0, max: 100, activeColor: Colors.white, onChanged: (val) { setState(() => _aimHeight = val); _updateAimConfig(); }),
              ]),
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(title: '03 ANTIBAN', subtitle: 'Chặn gói tin báo cáo & quét.', isEnabled: _antibanEnabled, onToggle: (val) { setState(() => _antibanEnabled = val); _toggleAntiban(val); }, child: const Text('Đang hoạt động: Chặn report & Fake signature', style: TextStyle(color: Colors.green, fontSize: 12))),
            const SizedBox(height: 16),
            _buildFeatureCard(title: '04 HIDE APP', subtitle: 'Ẩn ứng dụng khỏi Recent Apps và Task Manager.', isEnabled: _hideAppEnabled, onToggle: (val) { setState(() => _hideAppEnabled = val); _toggleHideApp(val); }, child: const Text('Đang ẩn: Chống Garena quét tác vụ.', style: TextStyle(color: Colors.green, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({required String title, required String subtitle, required bool isEnabled, required Function(bool) onToggle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF141A27), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Switch(value: isEnabled, onChanged: onToggle, activeColor: const Color(0xFF00E5FF)),
        ]),
        Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        if (isEnabled) ...[const SizedBox(height: 16), child],
      ]),
    );
  }
}

class ConfigPage extends StatefulWidget {
  final Function(bool) onConnect;
  final bool isConnected;
  const ConfigPage({super.key, required this.onConnect, required this.isConnected});
  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  static const platform = MethodChannel('com.sgcodexs.menuaim/native');
  final TextEditingController _configController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CẤP QUYỀN HỆ THỐNG', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Bấm lần lượt 3 nút dưới đây:', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 20),
          
          ElevatedButton.icon(
            onPressed: () {
              platform.invokeMethod('requestOverlayPermission');
            },
            icon: const Icon(Icons.layers, color: Colors.black),
            label: const Text('1. CẤP QUYỀN VẼ TÂM (OVERLAY)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {
              platform.invokeMethod('startVpn');
            },
            icon: const Icon(Icons.vpn_lock, color: Colors.black),
            label: const Text('2. CẤP QUYỀN VPN (ANTIBAN)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 15),

          ElevatedButton.icon(
            onPressed: () {
              platform.invokeMethod('openAccessibilitySettings');
            },
            icon: const Icon(Icons.accessibility_new, color: Colors.black),
            label: const Text('3. BẬT TRỢ NĂNG (KÉO TÂM)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E5FF), minimumSize: const Size(double.infinity, 50)),
          ),
          
          const SizedBox(height: 30),
          const Divider(color: Colors.grey),
          const SizedBox(height: 20),
          
          TextField(
            controller: _configController, maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: InputDecoration(hintText: 'Dán link VMess/VLESS (Nếu có)', hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: const Color(0xFF141A27), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, height: 55,
            child: ElevatedButton(
              onPressed: () {
                platform.invokeMethod('startOverlay');
                platform.invokeMethod('startVpn');
                if (_configController.text.isNotEmpty) {
                  platform.invokeMethod('sendToV2rayNG', {'config': _configController.text});
                }
                widget.onConnect(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: widget.isConnected ? Colors.green : const Color(0xFF00E5FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Text(widget.isConnected ? 'ĐÃ KẾT NỐI (BRIDGE ON)' : 'KÍCH HOẠT CẦU NỐI', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}
