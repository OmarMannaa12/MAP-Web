// --- Keep previous imports and color/shadow definitions ---
import 'package:flutter/material.dart';
// Assuming these exist and are correctly imported
import 'years_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

// --- Colors from the Established Style ---
const Color styleFormBgColor = Color(0xFFEDDCD9); // Container Background
const Color stylePrimaryTextColor = Color(0xFF264143); // Container Border, Text
const Color styleShadowColor = Color(0xFFE99F4C); // Container Shadow
const Color styleAccentPinkColor = Color(0xFFDE5499); // Accent (e.g., active state, slider/switch)
const Color styleScreenBgColor = Color(0xFFFDF6F0); // Screen Background
// --- End Color Definitions ---

// --- Shadow Definitions (Consistent Style) ---
const List<BoxShadow> _normalShadow = [
  BoxShadow(
    color: styleShadowColor,
    offset: Offset(3.0, 4.0), // dx=3, dy=4
    blurRadius: 0.0,
    spreadRadius: 1.0, // spread=1
  ),
];
const List<BoxShadow> _pressedShadow = [
  BoxShadow(
    color: styleShadowColor,
    offset: Offset(1.0, 2.0), // dx=1, dy=2
    blurRadius: 0.0,
    spreadRadius: 0.0, // spread=0
  ),
];
// --- End Shadow Definitions ---

// --- Press Offset ---
const _pressOffset = Offset(0, 4.0); // translateY(4px)


// --- HomeScreen ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default to YearsScreen
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = const [
    ProfileScreen(),
    YearsScreen(),
    StatsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: styleScreenBgColor,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              if (_selectedIndex != index) {
                setState(() => _selectedIndex = index);
              }
            },
            children: _pages,
          ),

          // *** MODIFICATION HERE: Move Positioned to bottom ***
          Positioned(
            // remove 'top' property
            // top: MediaQuery.of(context).padding.top + 15,
            // add 'bottom' property
            bottom: MediaQuery.of(context).padding.bottom + 15, // Space from bottom edge + system padding
            left: 0, // Keep centered horizontally
            right: 0,
            child: Center( // Keep Center widget
              child: _FloatingTopNavBar( // Widget remains the same
                selectedIndex: _selectedIndex,
                onItemTapped: _onNavItemTapped,
                onSettingsTap: _showSettingsModal,
              ),
            ),
          ),
          // *** END OF MODIFICATION ***
        ],
      ),
    );
  }
}

// --- _FloatingTopNavBar, _NavItem, _SettingsSheet, _SettingItem ---
// (Keep the implementations of these widgets exactly the same as the previous version)
// ... (Paste the full code for _FloatingTopNavBar here) ...
// ... (Paste the full code for _NavItem here) ...
// ... (Paste the full code for _SettingsSheet here) ...
// ... (Paste the full code for _SettingItem here) ...

// --- Paste the full code for the unchanged widgets below ---

// --- Styled Top Navigation Bar ---
class _FloatingTopNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onSettingsTap;

  const _FloatingTopNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Adjust padding
      decoration: BoxDecoration(
        color: styleFormBgColor, // Use the pinkish background
        // Use consistent border radius (adjust as needed, 12 matches modal)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: stylePrimaryTextColor, width: 2), // Use style border
        boxShadow: _normalShadow, // Use the standard hard shadow
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Keep it compact
        children: [
          _NavItem( // Profile
            icon: Icons.person_outline_rounded, // Consider rounded icons
            activeIcon: Icons.person_rounded,
            isActive: selectedIndex == 0,
            onTap: () => onItemTapped(0),
          ),
          const SizedBox(width: 5), // Adjust spacing
          _NavItem( // Years (Main)
            icon: Icons.calendar_today_outlined, // Different icon example
            activeIcon: Icons.calendar_today_rounded,
            isActive: selectedIndex == 1,
            onTap: () => onItemTapped(1),
          ),
          const SizedBox(width: 5),
          _NavItem( // Stats
            icon: Icons.bar_chart_outlined, // Different icon example
            activeIcon: Icons.bar_chart_rounded,
            isActive: selectedIndex == 2,
            onTap: () => onItemTapped(2),
          ),
          const SizedBox(width: 5),
          // Settings Icon - treated similarly but always inactive state visually
          _NavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_outlined, // Same icon, never "active"
            isActive: false, // Settings is not a main nav item state
            onTap: onSettingsTap,
            // No need for isSettingsButton flag if styling is consistent
          ),
        ],
      ),
    );
  }
}

// --- Styled Navigation Item (Stateful for Press Effect) ---
class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    Key? key, // Add key
  }) : super(key: key); // Pass key

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (mounted) setState(() => _isPressed = true);
  }
  void _handleTapUp(TapUpDetails details) {
    if (mounted) {
      setState(() => _isPressed = false);
      widget.onTap(); // Trigger action
    }
  }
  void _handleTapCancel() {
    if (mounted) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    // Active state uses the accent pink, inactive uses primary teal
    final Color iconColor = widget.isActive ? styleAccentPinkColor : stylePrimaryTextColor;
    // Determine current shadow based ONLY on press state
    final List<BoxShadow> currentShadow = _isPressed ? _pressedShadow : _normalShadow;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: Transform.translate(
        // Apply translation based on press state
        offset: _isPressed ? _pressOffset : Offset.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent, // Or styleFormBgColor if you want distinct buttons
            borderRadius: BorderRadius.circular(8.0), // Rounded corners for the shadow area
            boxShadow: _isPressed ? _pressedShadow : null, // Only show shadow when pressed
          ),
          child: Padding( // Padding defines the tap area and icon spacing
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              widget.isActive ? widget.activeIcon : widget.icon,
              size: 24, // Adjust icon size
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}


// --- Styled Settings Bottom Sheet ---
class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Consistent padding
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 30), // Reduced top padding
      decoration: BoxDecoration(
        color: styleFormBgColor, // Use the styled background
        // Apply border radius only to top corners
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        // Apply border only to the top
        border: Border(top: BorderSide(color: stylePrimaryTextColor, width: 2)),
        // No shadow needed for bottom sheet itself
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Fit content vertically
        children: [
          // Handle styled with primary color
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20, top: 4), // Adjust margin
            decoration: BoxDecoration(
              color: stylePrimaryTextColor.withOpacity(0.6), // Use muted primary color
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header row
          Row(
            children: [
              const Text( // Title styled consistently
                'Settings',
                style: TextStyle(
                  fontSize: 20, // Adjust size
                  fontWeight: FontWeight.w700, // Or w900 like login title
                  color: stylePrimaryTextColor,
                ),
              ),
              const Spacer(),
              // Close button styled minimally but with correct color
              IconButton(
                icon: const Icon(Icons.close, color: stylePrimaryTextColor, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                splashRadius: 20, // Control splash size
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 25), // Spacing

          // Setting Item 1: Volume
          _SettingItem(
            icon: Icons.volume_up_outlined,
            title: 'Volume',
            child: SliderTheme( // Apply styling theme to Slider
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: styleAccentPinkColor, // Use accent pink
                inactiveTrackColor: stylePrimaryTextColor.withOpacity(0.3), // Muted teal
                thumbColor: styleAccentPinkColor, // Accent pink thumb
                overlayColor: styleAccentPinkColor.withOpacity(0.2), // Accent pink overlay
                trackHeight: 3.0, // Slightly thicker track
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7.0), // Smaller thumb
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              ),
              child: Slider(
                value: 0.7, // Example value
                onChanged: (v) { /* Add state management */ },
              ),
            ),
          ),

          // Divider styled consistently
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Divider(height: 2, thickness: 2, color: stylePrimaryTextColor.withOpacity(0.5)), // Use muted teal
          ),

          // Setting Item 2: Notifications
          _SettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            // Apply styling directly or via SwitchTheme
            child: Transform.scale( // Keep scale if desired
              scale: 0.85,
              alignment: Alignment.centerRight,
              child: Switch(
                value: true, // Example value
                onChanged: (v) { /* Add state management */ },
                activeColor: styleFormBgColor, // Thumb color when active (matches bg)
                activeTrackColor: styleAccentPinkColor, // Track color when active (accent pink)
                inactiveThumbColor: stylePrimaryTextColor.withOpacity(0.6), // Thumb color when inactive (muted teal)
                inactiveTrackColor: stylePrimaryTextColor.withOpacity(0.2), // Track color when inactive (very muted teal)
                // trackOutlineColor: MaterialStateProperty.resolveWith((states) => Colors.transparent), // Remove outline if present
              ),
            ),
          ),
          const SizedBox(height: 15), // Bottom padding inside modal
        ],
      ),
    );
  }
}

// --- Styled Setting Item Row ---
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: stylePrimaryTextColor, size: 22), // Use primary color
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16, // Adjust size
              fontWeight: FontWeight.w600, // Match label weight
              color: stylePrimaryTextColor,
            ),
          ),
        ),
        // Ensure the child widget (Slider/Switch) is aligned correctly
        // Adjust width constraints as needed based on child widget size
        SizedBox(width: 130, child: Align(alignment: Alignment.centerRight, child: child)),
      ],
    );
  }
}