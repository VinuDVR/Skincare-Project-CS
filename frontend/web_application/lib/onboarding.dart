import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:web_application/questionnaire_page.dart';
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd

class OnboardingPage1 extends StatelessWidget {
  const OnboardingPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPagePresenter(pages: [
        OnboardingPageModel(
<<<<<<< HEAD
          title: '✨ Your Personalized Skincare Journey',
          description: 'Discover products perfectly matched to your skin type and needs',
          imageUrl: 'https://i.ibb.co/mFNWTT48/23985538-6881579-copy.png',
        ),
        OnboardingPageModel(
          title: '🧪 Science Meets Simplicity',
          description: 'Research-backed ingredients curate your ideal routine',
          imageUrl: 'https://i.ibb.co/gkPYFyw/21935406-6536717-copy.png',
        ),
        OnboardingPageModel(
          title: '🌱 Made Just for You',
          description: 'From acne to aging, we match products to your unique needs',
          imageUrl: 'https://i.ibb.co/hRCcM3DX/36077992-8378225-copy.png',
        ),
        OnboardingPageModel(
          title: '🚀 Ready to Glow?',
          description: 'Your personalized skincare map is just 2 minutes away',
          imageUrl: 'https://i.ibb.co/96D37RC/11806983-4835678-copy.png',
=======
          title: '✨ Your Personalized Skincare Journey Starts Here',
          description: 'Say goodbye to guesswork and hello to healthy, glowing skin!',
          imageUrl: 'https://i.ibb.co/mFNWTT48/23985538-6881579-copy.png',
          bgColor: Colors.indigo,
        ),
        OnboardingPageModel(
          title: '🧪 Science Meets Simplicity',
          description: ' Research-backed ingredient matching algorithms to curate your ideal routine.',
          imageUrl: 'https://i.ibb.co/gkPYFyw/21935406-6536717-copy.png',
          bgColor: const Color.fromARGB(255, 244, 143, 143),
        ),
        OnboardingPageModel(
          title: '🌱 Made Just for You',
          description:
              'We match you with products that suit your skin type, budget, and lifestyle.',
          imageUrl: 'https://i.ibb.co/hRCcM3DX/36077992-8378225-copy.png',
          bgColor: const Color(0xff1eb090),
        ),
        OnboardingPageModel(
          title: '🚀 Ready to Glow?',
          description: 'Let’s create your personalized skincare map in just 2 minutes!',
          imageUrl: 'https://i.ibb.co/96D37RC/11806983-4835678-copy.png',
          bgColor: const Color.fromARGB(255, 181, 107, 27),
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
        ),
      ]),
    );
  }
}

class OnboardingPagePresenter extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final VoidCallback? onSkip;
  final VoidCallback? onFinish;

<<<<<<< HEAD
  const OnboardingPagePresenter({
    Key? key,
    required this.pages,
    this.onSkip,
    this.onFinish,
  }) : super(key: key);
=======
  const OnboardingPagePresenter(
      {Key? key, required this.pages, this.onSkip, this.onFinish})
      : super(key: key);
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd

  @override
  State<OnboardingPagePresenter> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPagePresenter> {
<<<<<<< HEAD
  int _currentPage = 0;
=======
  // Store the currently visible page
  int _currentPage = 0;
  // Define a controller for the pageview
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
=======
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: widget.pages[_currentPage].bgColor,
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
<<<<<<< HEAD
=======
                // Pageview to render each page
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.pages.length,
                  onPageChanged: (idx) {
<<<<<<< HEAD
=======
                    // Change current page when pageview changes
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
                    setState(() {
                      _currentPage = idx;
                    });
                  },
                  itemBuilder: (context, idx) {
                    final item = widget.pages[idx];
<<<<<<< HEAD
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.green.shade900.withOpacity(0.3),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Image.network(
                                  item.imageUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade300,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
=======
                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Image.network(
                              item.imageUrl,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Column(children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(item.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: item.textColor,
                                        )),
                              ),
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 380),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0, vertical: 8.0),
                                child: Text(item.description,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: item.textColor,
                                        )),
                              )
                            ]))
                      ],
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
                    );
                  },
                ),
              ),
<<<<<<< HEAD
              _buildPageIndicator(),
              _buildBottomButtons(),
=======

              // Current page indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.pages
                    .map((item) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: _currentPage == widget.pages.indexOf(item)
                              ? 30
                              : 8,
                          height: 8,
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0)),
                        ))
                    .toList(),
              ),

              // Bottom buttons
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.comfortable,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pushNamed(context, '/questionnaire');
                        },
                        child: const Text("Skip")),
                    TextButton(
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.comfortable,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (_currentPage == widget.pages.length - 1) {
                          Navigator.pushNamed(context, '/questionnaire');
                        } else {
                          _pageController.animateToPage(_currentPage + 1,
                              curve: Curves.easeInOutCubic,
                              duration: const Duration(milliseconds: 250));
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            _currentPage == widget.pages.length - 1
                                ? "Finish"
                                : "Next",
                          ),
                          const SizedBox(width: 8),
                          Icon(_currentPage == widget.pages.length - 1
                              ? Icons.done
                              : Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ],
                ),
              )
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
            ],
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.pages.map((item) {
          final isActive = _currentPage == widget.pages.indexOf(item);
          return AnimatedContainer(
            duration: Duration(milliseconds: 250),
            margin: EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? Colors.green.shade400 : Colors.green.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/questionnaire');
            },
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: 18,
                color: Colors.green.shade200,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_currentPage == widget.pages.length - 1) {
                Navigator.pushNamed(context, '/questionnaire');
              } else {
                _pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              _currentPage == widget.pages.length - 1 ? 'Get Started' : 'Next',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
=======
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
}

class OnboardingPageModel {
  final String title;
  final String description;
  final String imageUrl;
<<<<<<< HEAD

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
=======
  final Color bgColor;
  final Color textColor;

  OnboardingPageModel(
      {required this.title,
      required this.description,
      required this.imageUrl,
      this.bgColor = Colors.blue,
      this.textColor = Colors.white});
}
>>>>>>> 9b75dfa68459ec4ff4da941694b8de3ba5541cdd
