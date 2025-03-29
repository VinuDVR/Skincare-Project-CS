import 'package:flutter/material.dart';
import 'questionnaire_page.dart';
import 'onboarding.dart';
<<<<<<< HEAD
=======
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'dart:math' as math;
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
<<<<<<< HEAD
      title: 'SkinGenie',
=======
      title: 'Skincare Recommender',
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        colorScheme: ColorScheme.light(
          primary: Color(0xFF6A9113), // Darker gradient color
          secondary: Color(0xFF141517), // Lighter gradient color
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/questionnaire': (context) => QuestionnairePage(),
        '/onboarding' : (context) => OnboardingPage1()
      },
       
    );
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

  @override
  void initState() {
    super.initState();
    
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
<<<<<<< HEAD
                colors: [Colors.green.shade800, Colors.teal.shade600],
=======
                colors: [Color.fromARGB(255, 9, 221, 175), Color(0xFF141517)],
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
                begin: _gradientAnimation.value,
                end: Alignment(-_gradientAnimation.value.x, -_gradientAnimation.value.y),
              ),
            ),
            child: Center(
<<<<<<< HEAD
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
                  ],
                ),
=======
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
                  SizedBox(height: 30),
                  _buildFloatingIcons(),
                  SizedBox(height: 40),
                  ScaleTransition(
                    scale: _buttonAnimation,
                    child: FadeTransition(
                      opacity: _buttonAnimation,
                      child: _buildStartButton(context),
                    ),
                  ),
                ],
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return Column(
      children: [
        Text(
<<<<<<< HEAD
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
=======
          'Personalized Skincare Recommendations tailored for your Skin Needs',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                blurRadius: 3,
                color: const Color.fromARGB(138, 243, 243, 243),
                offset: Offset(2, 2),
              )
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            ' ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              color: Colors.white.withOpacity(1.0),
              height: 1.4,
              shadows: [
              Shadow(
                blurRadius: 10,
                color: const Color.fromARGB(255, 255, 255, 255),
                offset: Offset(2, 2),
              )
            ],
            ),
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
<<<<<<< HEAD
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
        _buildFeatureCard(Icons.shopping_basket, 'Product Finder'),
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
=======
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/onboarding');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 4, 4, 4),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 8,
        shadowColor: Colors.purple.withOpacity(0.3),
      ),
      child: Text(
        'Begin Your Journey',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFloatingIcons() {
    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildFloatingIcon(Icons.spa, offset: Offset(-100, -70)),
          _buildFloatingIcon(Icons.water_drop, offset: Offset(100, 30)),
          _buildFloatingIcon(Icons.brush, offset: Offset(-60, 20)),
          _buildFloatingIcon(Icons.face, offset: Offset(60, -60)),
        ],
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, {required Offset offset}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            offset.dx,
            offset.dy + 20 * math.sin(_controller.value * math.pi * 2),
          ),
          child: Opacity(
            opacity: 0.2,
            child: Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
          ),
        );
      },
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
    );
  }
}