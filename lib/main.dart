import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SupabaseConfig.initialize();

  runApp(const SafeZoneApp());
}

// ========================================
// MOCK DATA STORE
// ========================================
class MockDataStore {
  static String currentUserRole = 'resident'; // 'resident', 'patrol_officer', 'admin'
  static String currentUserName = 'John Doe';
  static String currentUserEmail = 'john@example.com';
  
  static List<Map<String, dynamic>> incidents = [
    {
      'id': '1',
      'title': 'Suspicious Vehicle',
      'description': 'White van circling the neighborhood multiple times',
      'type': 'suspicious_activity',
      'severity': 'High',
      'status': 'Verified',
      'location': 'Oak Street, Block C',
      'lat': -33.9588,
      'lng': 25.6022,
      'reporter': 'Sarah Johnson',
      'time': '2 hours ago',
      'date': '2025-01-07 14:30',
      'hasMedia': true,
    },
    {
      'id': '2',
      'title': 'Break-in Attempt',
      'description': 'Someone tried to break the back door lock',
      'type': 'burglary',
      'severity': 'Critical',
      'status': 'Investigating',
      'location': 'Maple Avenue, Block A',
      'lat': -33.9598,
      'lng': 25.6032,
      'reporter': 'Michael Brown',
      'time': '5 hours ago',
      'date': '2025-01-07 11:00',
      'hasMedia': true,
    },
    {
      'id': '3',
      'title': 'Vandalism',
      'description': 'Graffiti on community wall',
      'type': 'vandalism',
      'severity': 'Low',
      'status': 'Resolved',
      'location': 'Pine Road, Block B',
      'lat': -33.9578,
      'lng': 25.6012,
      'reporter': 'Lisa Davis',
      'time': '1 day ago',
      'date': '2025-01-06 09:15',
      'hasMedia': false,
    },
  ];

  static List<Map<String, dynamic>> messages = [
    {'text': 'Welcome to SafeZone community!', 'sender': 'Admin', 'isMine': false, 'time': '09:00'},
    {'text': 'Stay safe everyone!', 'sender': 'You', 'isMine': true, 'time': '09:15'},
    {'text': 'Thanks for keeping us updated', 'sender': 'Mary Wilson', 'isMine': false, 'time': '09:20'},
  ];

  static List<Map<String, dynamic>> emergencyAlerts = [
    {
      'id': '1',
      'type': 'Police',
      'location': 'Oak Street, Block C',
      'time': '30 minutes ago',
      'status': 'Active',
      'reporter': 'Anonymous',
    },
    {
      'id': '2',
      'type': 'Medical',
      'location': 'Elm Street, Block D',
      'time': '2 hours ago',
      'status': 'Responded',
      'reporter': 'John Smith',
    },
  ];

  static List<Map<String, dynamic>> patrols = [
    {
      'id': '1',
      'officer': 'Officer James Lee',
      'area': 'Block A & B',
      'startTime': '18:00',
      'endTime': '22:00',
      'date': 'Today',
      'status': 'Scheduled',
    },
    {
      'id': '2',
      'officer': 'Officer Sarah Chen',
      'area': 'Block C & D',
      'startTime': '22:00',
      'endTime': '02:00',
      'date': 'Today',
      'status': 'Active',
    },
  ];

  static List<Map<String, dynamic>> vulnerableResidents = [
    {
      'id': '1',
      'name': 'Mrs. Margaret Thompson',
      'age': 78,
      'address': 'Oak Street, House 12',
      'lastChecked': '2 days ago',
      'status': 'Needs Check',
      'phone': '+27 82 123 4567',
    },
    {
      'id': '2',
      'name': 'Mr. Robert Williams',
      'age': 82,
      'address': 'Pine Road, House 45',
      'lastChecked': 'Today',
      'status': 'OK',
      'phone': '+27 82 765 4321',
    },
  ];
}

// ========================================
// APP WIDGET
// ========================================
class SafeZoneApp extends StatelessWidget {
  const SafeZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeZone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

// ========================================
// THEME
// ========================================
class AppTheme {
  static const primaryColor = Color(0xFF2563EB);
  static const secondaryColor = Color(0xFF10B981);
  static const dangerColor = Color(0xFFEF4444);
  static const warningColor = Color(0xFFF59E0B);
  static const backgroundColor = Color(0xFFF8FAFC);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

// ========================================
// SPLASH SCREEN
// ========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SafeZone',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Community Safety Together',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ========================================
// LOGIN SCREEN
// ========================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final profile = await AuthService().signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      MockDataStore.currentUserName = profile.name;
      MockDataStore.currentUserEmail = profile.email;
      MockDataStore.currentUserRole = profile.role;

      Widget destination;
      if (profile.role == 'patrol_officer') {
        destination = profile.verificationStatus == 'approved'
            ? const PatrolDashboard()
            : const PendingApprovalScreen();
      } else {
        destination = const HomeScreen();
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => destination));
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: AppTheme.dangerColor),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $error'), backgroundColor: AppTheme.dangerColor),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'logo',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield,
                      size: 60,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to continue protecting your community',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!value!.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Sign In', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account? '),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      MockDataStore.currentUserRole = 'patrol_officer';
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const PatrolDashboard()),
                      );
                    },
                    icon: const Icon(Icons.local_police),
                    label: const Text('Login as Patrol Officer (Demo)'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ========================================
// REGISTER SCREEN
// ========================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join SafeZone',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Help make your community safer',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Email is required';
                    if (!value!.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Phone is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Password is required';
                    if (value!.length < 6) return 'Password must be 6+ characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Confirm password';
                    if (value != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoleSelectionScreen(
                            name: _nameController.text.trim(),
                            email: _emailController.text.trim(),
                            phone: _phoneController.text.trim(),
                            password: _passwordController.text,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Continue', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// ========================================
// ROLE SELECTION SCREEN
// ========================================
class RoleSelectionScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;

  const RoleSelectionScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    if (_selectedRole == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await AuthService().signUp(
        name: widget.name,
        email: widget.email,
        phone: widget.phone,
        password: widget.password,
        role: _selectedRole!,
      );
      if (!mounted) return;

      MockDataStore.currentUserName = widget.name;
      MockDataStore.currentUserEmail = widget.email;
      MockDataStore.currentUserRole = _selectedRole!;

      if (response.session == null) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Check your email'),
            content: Text('We sent a confirmation link to ${widget.email}. Confirm it, then sign in to SafeZone.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
      }

      final destination = _selectedRole == 'resident'
          ? const HomeScreen()
          : const PatrolVerificationScreen();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message), backgroundColor: AppTheme.dangerColor),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $error'), backgroundColor: AppTheme.dangerColor),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Role'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'How will you use SafeZone?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the role that best describes you',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            RoleCard(
              icon: Icons.home_outlined,
              title: 'Resident',
              description: 'Report incidents, receive alerts, and stay informed about your community',
              isSelected: _selectedRole == 'resident',
              onTap: () => setState(() => _selectedRole = 'resident'),
            ),
            const SizedBox(height: 16),
            RoleCard(
              icon: Icons.local_police_outlined,
              title: 'Patrol Officer',
              description: 'Respond to emergencies, verify reports, patrol areas, and check on vulnerable residents',
              isSelected: _selectedRole == 'patrol_officer',
              onTap: () => setState(() => _selectedRole = 'patrol_officer'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedRole == null || _isLoading ? null : _completeRegistration,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Complete Registration', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// HOME SCREEN (UPDATED STRUCTURE)
// ========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _emergencyTapCount = 0;
  Timer? _tapTimer;

  final List<Widget> _screens = const [
    HomeFeedScreen(), // New home screen with live incident feeds
    MapScreen(),
    CreateReportScreen(), // Direct report creation instead of reports list
    CommunitiesScreen(), // Communities as 4th option
  ];

  void _handleEmergencyTap() {
    _emergencyTapCount++;
    
    if (_tapTimer != null) {
      _tapTimer!.cancel();
    }
    
    if (_emergencyTapCount == 2) {
      // Double tap detected - trigger extreme emergency
      _showExtremeEmergencyAlert();
      _emergencyTapCount = 0;
    } else {
      // Single tap - show emergency options
      _tapTimer = Timer(const Duration(milliseconds: 500), () {
        if (_emergencyTapCount == 1) {
          _showEmergencyDialog(context);
        }
        _emergencyTapCount = 0;
      });
    }
  }

  void _showExtremeEmergencyAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.dangerColor,
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white, size: 32),
            SizedBox(width: 12),
            Text('EXTREME EMERGENCY', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alerting:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 8),
            Text('✓ Police', style: TextStyle(color: Colors.white)),
            Text('✓ Emergency Contacts', style: TextStyle(color: Colors.white)),
            Text('✓ Patrol Officers', style: TextStyle(color: Colors.white)),
            SizedBox(height: 16),
            Text(
              'Your location has been shared',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeZone'),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          _screens[_currentIndex],
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: 80,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondary,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add_circle_outline),
                  activeIcon: Icon(Icons.add_circle),
                  label: 'Report',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_outlined),
                  activeIcon: Icon(Icons.forum),
                  label: 'Communities',
                ),
              ],
            ),
          ),
          // Silent Emergency Button positioned above bottom nav
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35,
            top: -35,
            child: GestureDetector(
              onTap: _handleEmergencyTap,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppTheme.dangerColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.dangerColor.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Emergency Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tap twice for extreme emergency',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            EmergencyButton(
              icon: Icons.local_police,
              label: 'Police',
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🚨 Police alert sent!')),
                );
              },
            ),
            const SizedBox(height: 12),
            EmergencyButton(
              icon: Icons.local_hospital,
              label: 'Medical',
              color: AppTheme.dangerColor,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🏥 Medical alert sent!')),
                );
              },
            ),
            const SizedBox(height: 12),
            EmergencyButton(
              icon: Icons.local_fire_department,
              label: 'Fire',
              color: AppTheme.warningColor,
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔥 Fire alert sent!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }
}

class EmergencyButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const EmergencyButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// HOME FEED SCREEN (LIVE INCIDENT FEEDS ONLY)
// ========================================
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final _incidentService = IncidentService();
  late Future<List<Map<String, dynamic>>> _incidentsFuture;

  @override
  void initState() {
    super.initState();
    _incidentsFuture = _loadIncidents();
  }

  Future<List<Map<String, dynamic>>> _loadIncidents() async {
    final incidents = await _incidentService.getIncidents();
    return incidents.map((incident) => incident.toLegacyMap()).toList();
  }

  Future<void> _refresh() async {
    final future = _loadIncidents();
    setState(() => _incidentsFuture = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.local_police,
                    label: 'Police',
                    color: AppTheme.primaryColor,
                    onTap: () => _showEmergencyAlert(context, 'Police'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.local_hospital,
                    label: 'Medical',
                    color: AppTheme.dangerColor,
                    onTap: () => _showEmergencyAlert(context, 'Medical'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionButton(
                    icon: Icons.local_fire_department,
                    label: 'Fire',
                    color: AppTheme.warningColor,
                    onTap: () => _showEmergencyAlert(context, 'Fire'),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Live Incident Feed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _incidentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off, size: 48, color: AppTheme.textSecondary),
                          const SizedBox(height: 12),
                          Text('Could not load incidents\n${snapshot.error}', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          OutlinedButton(onPressed: _refresh, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  );
                }
                final incidents = snapshot.data ?? const <Map<String, dynamic>>[];
                if (incidents.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 100),
                        Icon(Icons.shield_outlined, size: 54, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Center(child: Text('No incidents reported yet.')),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: incidents.length,
                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      return IncidentCard(
                        incident: incident,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ReportDetailScreen(incident: incident)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyAlert(BuildContext context, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type emergency dispatch is still a prototype feature.')),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// COMMUNITIES SCREEN (Updated with proper padding)
// ========================================
class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Community Info Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Community',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        Text(
                          'Oak Street Neighborhood',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '247 Members',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Added bottom padding
                itemCount: 5,
                itemBuilder: (context, index) {
                  final channels = [
                    {'name': 'General Discussion', 'unread': 3, 'last': 'John: Thanks for the update!', 'time': '2m'},
                    {'name': 'Safety Alerts', 'unread': 0, 'last': 'New incident reported', 'time': '1h'},
                    {'name': 'Events & Meetings', 'unread': 1, 'last': 'Community meeting on Saturday', 'time': '3h'},
                    {'name': 'Lost & Found', 'unread': 0, 'last': 'Found: Black cat', 'time': '5h'},
                    {'name': 'Neighborhood Watch', 'unread': 2, 'last': 'Patrol schedule updated', 'time': '1d'},
                  ];
                  
                  final channel = channels[index];
                  return ChatPreviewCard(
                    title: channel['name'] as String,
                    lastMessage: channel['last'] as String,
                    time: channel['time'] as String,
                    unreadCount: channel['unread'] as int,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(channelName: channel['name'] as String),
                        ),
                      );
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
}

class ChatPreviewCard extends StatelessWidget {
  final String title;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatPreviewCard({
    super.key,
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          child: const Icon(Icons.group, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========================================
// MAP SCREEN
// ========================================
class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crime Hotspots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map placeholder
          Container(
            color: const Color(0xFFE8F4F8),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 100,
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Crime Heatmap',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Google Maps integration coming soon',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Mock incident markers
                Positioned(
                  top: 150,
                  left: 100,
                  child: _IncidentMarker(
                    color: AppTheme.dangerColor,
                    label: 'High',
                    onTap: () => _showIncidentDetails(context, MockDataStore.incidents[0]),
                  ),
                ),
                Positioned(
                  top: 300,
                  right: 80,
                  child: _IncidentMarker(
                    color: AppTheme.warningColor,
                    label: 'Med',
                    onTap: () => _showIncidentDetails(context, MockDataStore.incidents[1]),
                  ),
                ),
                Positioned(
                  bottom: 200,
                  left: 150,
                  child: _IncidentMarker(
                    color: AppTheme.secondaryColor,
                    label: 'Low',
                    onTap: () => _showIncidentDetails(context, MockDataStore.incidents[2]),
                  ),
                ),
              ],
            ),
          ),
          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Risk Levels',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(color: AppTheme.dangerColor, label: 'High Risk'),
                  _LegendItem(color: AppTheme.warningColor, label: 'Medium'),
                  _LegendItem(color: AppTheme.secondaryColor, label: 'Low Risk'),
                ],
              ),
            ),
          ),
          // Stats Card
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.report,
                    label: 'Incidents',
                    value: '${MockDataStore.incidents.length}',
                    color: AppTheme.dangerColor,
                  ),
                  _StatItem(
                    icon: Icons.location_on,
                    label: 'Hotspots',
                    value: '2',
                    color: AppTheme.warningColor,
                  ),
                  _StatItem(
                    icon: Icons.check_circle,
                    label: 'Resolved',
                    value: '1',
                    color: AppTheme.secondaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Incidents'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Theft'),
            ),
            CheckboxListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Burglary'),
            ),
            CheckboxListTile(
              value: true,
              onChanged: (_) {},
              title: const Text('Suspicious Activity'),
            ),
            CheckboxListTile(
              value: false,
              onChanged: (_) {},
              title: const Text('Vandalism'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showIncidentDetails(BuildContext context, Map<String, dynamic> incident) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              incident['title'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(incident['description']),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(incident['location']),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(incident['time']),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(incident: incident),
                  ),
                );
              },
              child: const Text('View Full Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentMarker extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _IncidentMarker({
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ========================================
// CREATE REPORT SCREEN
// ========================================
class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  String? _selectedSeverity;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _hasMedia = false;
  bool _isSubmitting = false;

  final List<String> _incidentTypes = [
    'Theft',
    'Burglary',
    'Assault',
    'Suspicious Activity',
    'Vandalism',
    'Other',
  ];

  final List<String> _severityLevels = ['Low', 'Medium', 'High', 'Critical'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Help keep the community safe by reporting suspicious activities or incidents.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Incident Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _incidentTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value),
                validator: (value) => value == null ? 'Please select type' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSeverity,
                decoration: const InputDecoration(
                  labelText: 'Severity Level',
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: _severityLevels.map((severity) {
                  return DropdownMenuItem(value: severity, child: Text(severity));
                }).toList(),
                onChanged: (value) => setState(() => _selectedSeverity = value),
                validator: (value) => value == null ? 'Please select severity' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                  hintText: 'Brief description of the incident',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                  hintText: 'Provide detailed information',
                ),
                maxLines: 5,
                validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _hasMedia = !_hasMedia);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_hasMedia 
                        ? 'Media upload is not connected yet'
                        : 'Media selection cleared'),
                    ),
                  );
                },
                icon: Icon(_hasMedia ? Icons.check_circle : Icons.camera_alt),
                label: const Text('Add Photos/Videos (coming next)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: _hasMedia ? AppTheme.secondaryColor : AppTheme.primaryColor,
                  ),
                  foregroundColor: _hasMedia ? AppTheme.secondaryColor : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Location',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Oak Street, Block C',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: AppTheme.primaryColor),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isSubmitting = true);
                        try {
                          await IncidentService().createIncident(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            type: _selectedType!.toLowerCase().replaceAll(' ', '_'),
                            severity: _selectedSeverity!,
                            location: 'Oak Street, Block C',
                            lat: -33.9588,
                            lng: 25.6022,
                            hasMedia: false,
                          );
                          if (!mounted) return;
                          _formKey.currentState!.reset();
                          _titleController.clear();
                          _descriptionController.clear();
                          setState(() {
                            _selectedType = null;
                            _selectedSeverity = null;
                            _hasMedia = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Report saved to SafeZone.'),
                              backgroundColor: AppTheme.secondaryColor,
                            ),
                          );
                        } on AuthException catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error.message), backgroundColor: AppTheme.dangerColor),
                          );
                        } catch (error) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not submit report: $error'), backgroundColor: AppTheme.dangerColor),
                          );
                        } finally {
                          if (mounted) setState(() => _isSubmitting = false);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Report', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

// ========================================
// INCIDENT CARD (REUSABLE)
// ========================================
class IncidentCard extends StatelessWidget {
  final Map<String, dynamic> incident;
  final VoidCallback onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = incident['severity'] == 'High' || incident['severity'] == 'Critical'
        ? AppTheme.dangerColor
        : incident['severity'] == 'Medium'
            ? AppTheme.warningColor
            : AppTheme.secondaryColor;

    final statusColor = incident['status'] == 'Verified'
        ? AppTheme.secondaryColor
        : incident['status'] == 'Investigating'
            ? AppTheme.warningColor
            : AppTheme.textSecondary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      incident['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      incident['severity'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: severityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                incident['description'],
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      incident['location'],
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                  const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    incident['time'],
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    incident['status'] == 'Verified' ? Icons.verified :
                    incident['status'] == 'Investigating' ? Icons.pending :
                    Icons.check_circle,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    incident['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: statusColor,
                    ),
                  ),
                  if (incident['hasMedia']) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.photo_camera, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    const Text(
                      'Media attached',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// REPORT DETAIL SCREEN
// ========================================
class ReportDetailScreen extends StatelessWidget {
  final Map<String, dynamic> incident;

  const ReportDetailScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder
            if (incident['hasMedia'])
              Container(
                height: 250,
                color: Colors.grey[300],
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          incident['date'],
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(incident['severity']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${incident['severity']} Severity',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getSeverityColor(incident['severity']),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(incident['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getStatusIcon(incident['status']),
                              size: 14,
                              color: _getStatusColor(incident['status']),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              incident['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(incident['status']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    incident['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: incident['location'],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Reported',
                    value: '${incident['time']} (${incident['date']})',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.person,
                    label: 'Reporter',
                    value: incident['reporter'],
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Type',
                    value: incident['type'].toString().split('_').map((e) => 
                      e[0].toUpperCase() + e.substring(1)).join(' '),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    incident['description'],
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (incident['status'] != 'Pending') ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Actions Taken',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ActionItem(
                      icon: Icons.check_circle,
                      text: 'Report verified by patrol officer',
                      time: '1 hour ago',
                    ),
                    _ActionItem(
                      icon: Icons.notifications,
                      text: 'Neighbors notified',
                      time: '1 hour ago',
                    ),
                    if (incident['severity'] == 'High' || incident['severity'] == 'Critical')
                      _ActionItem(
                        icon: Icons.local_police,
                        text: 'Police informed',
                        time: '50 minutes ago',
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Critical':
      case 'High':
        return AppTheme.dangerColor;
      case 'Medium':
        return AppTheme.warningColor;
      default:
        return AppTheme.secondaryColor;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Verified':
        return AppTheme.secondaryColor;
      case 'Investigating':
        return AppTheme.warningColor;
      case 'Resolved':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Verified':
        return Icons.verified;
      case 'Investigating':
        return Icons.pending;
      case 'Resolved':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final String time;

  const _ActionItem({
    required this.icon,
    required this.text,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.secondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// PROFILE SCREEN
// ========================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    MockDataStore.currentUserName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      MockDataStore.currentUserRole == 'resident' ? 'Resident' : 'Patrol Officer',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    MockDataStore.currentUserEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Oak Street, Block C',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ProfileOption(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.shield_outlined,
              title: 'Emergency Contacts',
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              trailing: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.dangerColor,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.history,
              title: 'My Reports',
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.lock_outline,
              title: 'Privacy & Security',
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {},
            ),
            ProfileOption(
              icon: Icons.info_outline,
              title: 'About SafeZone',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            ProfileOption(
              icon: Icons.logout,
              title: 'Logout',
              textColor: AppTheme.dangerColor,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.dangerColor,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Widget? trailing;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppTheme.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: textColor ?? AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ========================================
// PATROL VERIFICATION SCREEN
// ========================================
class PatrolVerificationScreen extends StatefulWidget {
  const PatrolVerificationScreen({super.key});

  @override
  State<PatrolVerificationScreen> createState() => _PatrolVerificationScreenState();
}

class _PatrolVerificationScreenState extends State<PatrolVerificationScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _idNumberController = TextEditingController();
  final _companyController = TextEditingController();
  final _licenseController = TextEditingController();
  final _referenceNameController = TextEditingController();
  final _referencePhoneController = TextEditingController();
  
  bool _hasIdDocument = false;
  bool _hasPoliceCheck = false;
  bool _hasCompanyLetter = false;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol Officer Verification'),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    decoration: BoxDecoration(
                      color: index <= _currentStep
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: _buildStepContent(),
              ),
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    child: Text(_currentStep == 3 ? 'Submit for Review' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalVerification();
      case 1:
        return _buildDocumentUpload();
      case 2:
        return _buildBackgroundCheck();
      case 3:
        return _buildTermsAndConditions();
      default:
        return Container();
    }
  }

  // STEP 1: Personal Verification
  Widget _buildPersonalVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.badge,
          size: 64,
          color: Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),
        const Text(
          'Personal Verification',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We need to verify your identity to ensure community safety.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 32),
        TextFormField(
          controller: _idNumberController,
          decoration: const InputDecoration(
            labelText: 'National ID / Passport Number',
            prefixIcon: Icon(Icons.credit_card),
            hintText: 'Enter your ID number',
          ),
          validator: (value) => value?.isEmpty ?? true ? 'ID number is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _companyController,
          decoration: const InputDecoration(
            labelText: 'Security Company / Organization',
            prefixIcon: Icon(Icons.business),
            hintText: 'Your employer or organization',
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Company name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _licenseController,
          decoration: const InputDecoration(
            labelText: 'Security License Number (if applicable)',
            prefixIcon: Icon(Icons.verified_user),
            hintText: 'PSIRA/Security license',
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF2563EB)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All information will be verified with relevant authorities.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2: Document Upload
  Widget _buildDocumentUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.upload_file,
          size: 64,
          color: Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),
        const Text(
          'Required Documents',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload the following documents for verification.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 32),
        _DocumentUploadTile(
          title: 'ID Document (Front & Back)',
          description: 'Clear photo of your National ID or Passport',
          isUploaded: _hasIdDocument,
          onUpload: () => setState(() => _hasIdDocument = !_hasIdDocument),
          required: true,
        ),
        const SizedBox(height: 16),
        _DocumentUploadTile(
          title: 'Police Clearance Certificate',
          description: 'Must be less than 6 months old',
          isUploaded: _hasPoliceCheck,
          onUpload: () => setState(() => _hasPoliceCheck = !_hasPoliceCheck),
          required: true,
        ),
        const SizedBox(height: 16),
        _DocumentUploadTile(
          title: 'Company Authorization Letter',
          description: 'Letter from security company or neighborhood association',
          isUploaded: _hasCompanyLetter,
          onUpload: () => setState(() => _hasCompanyLetter = !_hasCompanyLetter),
          required: true,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber, color: Color(0xFFF59E0B)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Documents must be clear and legible. Fraudulent documents will result in permanent ban.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: Background Check & References
  Widget _buildBackgroundCheck() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.people_outline,
          size: 64,
          color: Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),
        const Text(
          'Background Check',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Provide references who can vouch for your character.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Reference 1 (Supervisor/Manager)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _referenceNameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Reference name is required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _referencePhoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Phone number is required' : null,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF10B981)),
                  SizedBox(width: 12),
                  Text(
                    'Background Check Process',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ChecklistItem('Criminal record verification'),
              _ChecklistItem('Employment history check'),
              _ChecklistItem('Reference interviews'),
              _ChecklistItem('Address verification'),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 4: Terms and Conditions
  Widget _buildTermsAndConditions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.gavel,
          size: 64,
          color: Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),
        const Text(
          'Terms & Responsibilities',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please read and agree to the following terms.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'As a Patrol Officer, you agree to:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _ResponsibilityItem('Maintain professional conduct at all times'),
              _ResponsibilityItem('Respond promptly to emergency alerts'),
              _ResponsibilityItem('Verify incidents accurately and honestly'),
              _ResponsibilityItem('Respect resident privacy and confidentiality'),
              _ResponsibilityItem('Follow all security protocols and regulations'),
              _ResponsibilityItem('Submit to random audits and monitoring'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.warning, color: Color(0xFFEF4444)),
                  SizedBox(width: 12),
                  Text(
                    'Consequences of Misconduct',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '• Immediate account suspension\n'
                '• Legal action for fraudulent activity\n'
                '• Reporting to law enforcement\n'
                '• Permanent ban from platform\n'
                '• Criminal charges where applicable',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CheckboxListTile(
          value: _agreeToTerms,
          onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I have read and agree to all terms, conditions, and responsibilities',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (!_hasIdDocument || !_hasPoliceCheck || !_hasCompanyLetter) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload all required documents'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 3) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please agree to terms and conditions'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
      _submitApplication();
    }
  }

  void _submitApplication() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 32),
            SizedBox(width: 12),
            Text('Application Submitted'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your patrol officer application has been submitted for review.'),
            SizedBox(height: 16),
            Text(
              'What happens next:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Admin will review your documents (1-3 days)'),
            Text('• Background check will be conducted'),
            Text('• References will be contacted'),
            Text('• You will receive approval notification'),
            SizedBox(height: 16),
            Text(
              'You can use the app as a Resident while waiting for approval.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const PendingApprovalScreen()),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _companyController.dispose();
    _licenseController.dispose();
    _referenceNameController.dispose();
    _referencePhoneController.dispose();
    super.dispose();
  }
}

// ========================================
// HELPER WIDGETS FOR PATROL VERIFICATION
// ========================================
class _DocumentUploadTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isUploaded;
  final VoidCallback onUpload;
  final bool required;

  const _DocumentUploadTile({
    required this.title,
    required this.description,
    required this.isUploaded,
    required this.onUpload,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (required) ...[
                          const SizedBox(width: 4),
                          const Text(
                            '*',
                            style: TextStyle(color: Color(0xFFEF4444)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                color: isUploaded ? const Color(0xFF10B981) : const Color(0xFF64748B),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onUpload,
            icon: Icon(isUploaded ? Icons.refresh : Icons.upload_file),
            label: Text(isUploaded ? 'Replace Document' : 'Upload Document'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isUploaded ? const Color(0xFF10B981) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;

  const _ChecklistItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check, color: Color(0xFF10B981), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _ResponsibilityItem extends StatelessWidget {
  final String text;

  const _ResponsibilityItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ========================================
// PENDING APPROVAL SCREEN
// ========================================
class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Status'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.pending_actions,
                size: 100,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification in Progress',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your patrol officer application is being reviewed by our admin team.',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    _TimelineItem(
                      icon: Icons.check_circle,
                      title: 'Application Submitted',
                      subtitle: 'Completed',
                      isCompleted: true,
                    ),
                    _TimelineItem(
                      icon: Icons.schedule,
                      title: 'Document Verification',
                      subtitle: 'In Progress (1-2 days)',
                      isCompleted: false,
                    ),
                    _TimelineItem(
                      icon: Icons.schedule,
                      title: 'Background Check',
                      subtitle: 'Pending',
                      isCompleted: false,
                    ),
                    _TimelineItem(
                      icon: Icons.schedule,
                      title: 'Admin Approval',
                      subtitle: 'Pending',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to resident home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                child: const Text('Continue as Resident'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isLast;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF10B981)
                    : const Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCompleted
                        ? const Color(0xFF10B981)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ========================================
// PATROL DASHBOARD (PATROL OFFICER VIEW)
// ========================================
class PatrolDashboard extends StatefulWidget {
  const PatrolDashboard({super.key});

  @override
  State<PatrolDashboard> createState() => _PatrolDashboardState();
}

class _PatrolDashboardState extends State<PatrolDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    PatrolHomeScreen(),
    PatrolAlertsScreen(),
    PatrolScheduleScreen(),
    VulnerableResidentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active_outlined),
            activeIcon: Icon(Icons.notifications_active),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.elderly_outlined),
            activeIcon: Icon(Icons.elderly),
            label: 'Care',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ========================================
// PATROL HOME SCREEN
// ========================================
class PatrolHomeScreen extends StatelessWidget {
  const PatrolHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'On Duty',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Area: Block A & B',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Shift: 18:00 - 22:00',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('End Shift'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.report,
                    label: 'Reports',
                    value: '${MockDataStore.incidents.length}',
                    color: AppTheme.dangerColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.notifications_active,
                    label: 'Alerts',
                    value: '${MockDataStore.emergencyAlerts.length}',
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.elderly,
                    label: 'Checks Due',
                    value: '${MockDataStore.vulnerableResidents.where((r) => r['status'] == 'Needs Check').length}',
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Resolved',
                    value: '${MockDataStore.incidents.where((i) => i['status'] == 'Resolved').length}',
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...MockDataStore.emergencyAlerts.map((alert) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: alert['status'] == 'Active'
                      ? AppTheme.dangerColor.withOpacity(0.2)
                      : AppTheme.secondaryColor.withOpacity(0.2),
                  child: Icon(
                    alert['type'] == 'Police' ? Icons.local_police :
                    alert['type'] == 'Medical' ? Icons.local_hospital :
                    Icons.local_fire_department,
                    color: alert['status'] == 'Active'
                        ? AppTheme.dangerColor
                        : AppTheme.secondaryColor,
                  ),
                ),
                title: Text('${alert['type']} Emergency'),
                subtitle: Text(alert['location']),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: alert['status'] == 'Active'
                            ? AppTheme.dangerColor.withOpacity(0.1)
                            : AppTheme.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert['status'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: alert['status'] == 'Active'
                              ? AppTheme.dangerColor
                              : AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alert['time'],
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                onTap: () {},
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// PATROL ALERTS SCREEN
// ========================================
class PatrolAlertsScreen extends StatelessWidget {
  const PatrolAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockDataStore.emergencyAlerts.length,
        itemBuilder: (context, index) {
          final alert = MockDataStore.emergencyAlerts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: alert['status'] == 'Active'
                              ? AppTheme.dangerColor.withOpacity(0.1)
                              : AppTheme.secondaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          alert['type'] == 'Police' ? Icons.local_police :
                          alert['type'] == 'Medical' ? Icons.local_hospital :
                          Icons.local_fire_department,
                          color: alert['status'] == 'Active'
                              ? AppTheme.dangerColor
                              : AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${alert['type']} Emergency',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Reporter: ${alert['reporter']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: alert['status'] == 'Active'
                              ? AppTheme.dangerColor.withOpacity(0.1)
                              : AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alert['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: alert['status'] == 'Active'
                                ? AppTheme.dangerColor
                                : AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          alert['location'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        alert['time'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  if (alert['status'] == 'Active') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Responding to alert...')),
                              );
                            },
                            icon: const Icon(Icons.directions_car),
                            label: const Text('Respond'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call),
                            label: const Text('Call'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ========================================
// PATROL SCHEDULE SCREEN
// ========================================
class PatrolScheduleScreen extends StatelessWidget {
  const PatrolScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPatrolDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockDataStore.patrols.length,
        itemBuilder: (context, index) {
          final patrol = MockDataStore.patrols[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: patrol['status'] == 'Active'
                              ? AppTheme.secondaryColor.withOpacity(0.1)
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_police,
                          color: patrol['status'] == 'Active'
                              ? AppTheme.secondaryColor
                              : AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patrol['officer'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              patrol['area'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: patrol['status'] == 'Active'
                              ? AppTheme.secondaryColor.withOpacity(0.1)
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          patrol['status'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: patrol['status'] == 'Active'
                                ? AppTheme.secondaryColor
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(patrol['date'], style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${patrol['startTime']} - ${patrol['endTime']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  if (patrol['status'] == 'Active') ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerColor,
                      ),
                      child: const Text('End Patrol'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddPatrolDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Patrol'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Patrol scheduling form will be implemented here'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Patrol scheduled!')),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }
}

// ========================================
// VULNERABLE RESIDENTS SCREEN
// ========================================
class VulnerableResidentsScreen extends StatelessWidget {
  const VulnerableResidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Care'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Check on vulnerable residents regularly to ensure their safety and wellbeing.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MockDataStore.vulnerableResidents.length,
              itemBuilder: (context, index) {
                final resident = MockDataStore.vulnerableResidents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: resident['status'] == 'Needs Check'
                                    ? AppTheme.warningColor.withOpacity(0.1)
                                    : AppTheme.secondaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.elderly,
                                color: resident['status'] == 'Needs Check'
                                    ? AppTheme.warningColor
                                    : AppTheme.secondaryColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resident['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Age: ${resident['age']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: resident['status'] == 'Needs Check'
                                    ? AppTheme.warningColor.withOpacity(0.1)
                                    : AppTheme.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                resident['status'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: resident['status'] == 'Needs Check'
                                      ? AppTheme.warningColor
                                      : AppTheme.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                resident['address'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Last checked: ${resident['lastChecked']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showCheckDialog(context, resident);
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Check In'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.call),
                                label: const Text('Call'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckDialog(BuildContext context, Map<String, dynamic> resident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Check In: ${resident['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How is the resident doing?'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Good'),
              leading: Radio(value: 1, groupValue: 1, onChanged: (_) {}),
            ),
            ListTile(
              title: const Text('Needs Attention'),
              leading: Radio(value: 2, groupValue: 1, onChanged: (_) {}),
            ),
            ListTile(
              title: const Text('Emergency'),
              leading: Radio(value: 3, groupValue: 1, onChanged: (_) {}),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✓ Check-in recorded for ${resident['name']}')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// ========================================
// CHAT SCREEN
// ========================================
class ChatScreen extends StatefulWidget {
  final String channelName;
  
  const ChatScreen({super.key, required this.channelName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  late List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(MockDataStore.messages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channelName),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  text: msg['text'],
                  sender: msg['sender'],
                  isMine: msg['isMine'],
                  time: msg['time'],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        setState(() {
                          _messages.add({
                            'text': _messageController.text,
                            'sender': 'You',
                            'isMine': true,
                            'time': 'Now',
                          });
                        });
                        _messageController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final String sender;
  final bool isMine;
  final String time;

  const MessageBubble({
    super.key,
    required this.text,
    required this.sender,
    required this.isMine,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMine)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                sender,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMine ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isMine ? Colors.white : AppTheme.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isMine ? Colors.white70 : AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}