import 'package:radiologist_helper/data/onboarding.dart';

// Static app content, not backend data -- no repository, imported directly
// by OnboardingPage.
const mockOnboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/ob1/400/240',
    title: 'AI-Powered Analysis',
    description: 'Analyze DICOM studies with AI assistance.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/ob2/400/240',
    title: 'Ask Anything',
    description: 'Chat with the AI radiologist assistant.',
  ),
  OnboardingSlide(
    imageUrl: 'https://picsum.photos/seed/ob3/400/240',
    title: 'Review with Confidence',
    description: 'Confident reporting backed by AI findings.',
  ),
];
