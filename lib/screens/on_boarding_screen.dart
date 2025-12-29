import 'package:flutter/material.dart';
import 'package:task_manager/models/onboarding.dart';
import 'package:task_manager/screens/task_list_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int _currentPageIndex = 0;

  final _pageController = PageController();

  void _nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskListScreen()),
      );
    }
  }

  void _skipOnBoarding() {
    _pageController.jumpToPage(_pages.length - 1);
  }

  final List<Onboarding> _pages = [
    Onboarding(
      imagePath: 'assets/first_onboarding.png',
      heading: 'Welcome to Clarity.',
      shortInfo:
          ' The simplest way to manage your tasks and focus on what matters. ',
    ),
    Onboarding(
      imagePath: 'assets/second_onboarding.png',
      heading: 'Create & Organize Task. ',
      shortInfo:
          'Easily add new tasks and see everything you need to do in one place. ',
    ),
    Onboarding(
      imagePath: 'assets/third_onboarding.png',
      heading: "You're All Set!.",
      shortInfo: ' Your journey to organized productivity starts now. ',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    bool isLastPage = _currentPageIndex == _pages.length - 1;
    return Scaffold(
      body: Column(
        children: [
          // page view
          Expanded(
            flex: 3,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (value) {
                _currentPageIndex = value;
                setState(() {});
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return _buildOnboardingContent(content: page, context: context);
              },
            ),
          ),
          //dot indicator
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final currentPageIndex = _currentPageIndex == index;
                return Container(
                  margin: EdgeInsets.all(5),
                  width: currentPageIndex ? 22 : 10,
                  height: 9,
                  decoration: BoxDecoration(
                    color: currentPageIndex
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).hintColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ),

          // skip + continue buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLastPage
                    ? SizedBox.shrink()
                    : Expanded(
                        child: ElevatedButton(
                          onPressed: _skipOnBoarding,
                          child: Text('Skip'),
                        ),
                      ),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      _nextPage();
                    },
                    child: Text(isLastPage ? 'Get Started' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

Widget _buildOnboardingContent({
  required Onboarding content,
  required BuildContext context,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    spacing: 10,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(content.imagePath, height: 280),
      ),
      SizedBox(height: 20),
      Text(content.heading, style: Theme.of(context).textTheme.headlineLarge),
      Text(content.shortInfo, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}
