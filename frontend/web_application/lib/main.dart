import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_application/history_page.dart';
import 'questionnaire_page.dart';
import 'onboarding.dart';
import 'chat_fab.dart';
import 'login.dart';
import 'register.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkinGenie',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF6A9113), 
          secondary: Color(0xFF141517), 
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/questionnaire': (context) => QuestionnairePage(),
        '/onboarding': (context) => OnboardingPage1(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/history': (context) => HistoryPage(),
      },
    );
  }
}


class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  AuthService._internal();
  
  final storage = const FlutterSecureStorage();
  
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }
  
  Future<void> removeToken() async {
    await storage.delete(key: 'jwt_token');
  }
  
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
  
  Future<bool> validateToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      final response = await http.get(
        Uri.parse('http://localhost:5000/check-auth'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        
        await removeToken();
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<Alignment> _gradientAnimation;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    
    _checkLoginStatus();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _titleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  Future<void> _checkLoginStatus() async {
    final isLoggedIn = await AuthService().validateToken();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void navigateToHistory() async {
    final isLoggedIn = await AuthService().isLoggedIn();

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You need to log in to view history.")),
      );
      Navigator.pushNamed(context, '/login').then((_) {
        _checkLoginStatus();
      });
      return;
    }

    Navigator.pushNamed(context, '/history');
  }

  void _handleLogout() async {
    await AuthService().removeToken();
    setState(() {
      _isLoggedIn = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logged out successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.green.shade800],
              begin: _gradientAnimation.value,
              end: Alignment(-_gradientAnimation.value.x, -_gradientAnimation.value.y),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.white),
            onPressed: navigateToHistory,
          ),
          if (!_isLoggedIn) ...[
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login').then((_) {
                  _checkLoginStatus();
                });
              },
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register').then((_) {
                  _checkLoginStatus();
                });
              },
              child: const Text('Register', style: TextStyle(color: Colors.white)),
            ),
          ] else ...[
            TextButton(
              onPressed: _handleLogout,
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.teal.shade600],
                begin: _gradientAnimation.value,
                end: Alignment(-_gradientAnimation.value.x, -_gradientAnimation.value.y),
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _titleAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, -0.5),
                          end: Offset.zero,
                        ).animate(_titleAnimation),
                        child: _buildAnimatedTitle(),
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildFeatureCards(),
                    SizedBox(height: 40),
                    ScaleTransition(
                      scale: _buttonAnimation,
                      child: FadeTransition(
                        opacity: _buttonAnimation,
                        child: _buildStartButton(context),
                      ),
                    ),
                    if (_isLoggedIn) ...[
                      SizedBox(height: 20),
                      Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: const ChatFloatingButton(),
    );
  }

  Widget _buildAnimatedTitle() {
    return Column(
      children: [
        Text(
          'SkinGenie',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.1,
            height: 1.3,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Tailored to your unique skin needs',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade300,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade900,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/onboarding');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          'Begin Your Journey',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _buildFeatureCard(Icons.spa, 'Skin Analysis'),
        _buildFeatureCard(Icons.eco, 'Research-backed Ingredients'),
        _buildFeatureCard(Icons.assignment, 'Custom Routine'),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String text) {
    return Card(
      color: Colors.green.shade900.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.green.shade200),
            SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}