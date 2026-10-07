/// A member of the team shown in Account → Developers.
///
/// Optional fields ([email], [location], [linkedIn]) are hidden in the UI
/// until they are filled in below.
class Developer {
  final String id;
  final String name;
  final String role;
  final String bio;
  final List<String> focusAreas;
  final String githubUsername;
  final String imageAsset;
  final String? email;
  final String? location;
  final String? linkedIn;

  const Developer({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.focusAreas,
    required this.githubUsername,
    required this.imageAsset,
    this.email,
    this.location,
    this.linkedIn,
  });

  String get githubUrl => 'https://github.com/$githubUsername';

  /// Hero tag shared by the avatar across list, detail and photo viewer.
  String get heroTag => 'developer-photo-$id';
}

/// The team. Add more details here once they are available.
const List<Developer> kDevelopers = [
  Developer(
    id: 'abdullah-rana',
    name: 'Abdullah Rana',
    role: 'Software Architect, Team Lead & Full Stack Engineer',
    bio:
        'Leads the technical direction of Smart Fitness & Step Counter, '
        'defining the architecture and guiding the team from planning to '
        'release. Delivers features across the full stack, from polished '
        'mobile interfaces to the services behind them.',
    focusAreas: ['Software Architecture', 'Team Leadership', 'Full Stack'],
    githubUsername: 'Abdullah-819',
    imageAsset: 'assets/developers/Abdullah Rana.jpeg',
  ),
  Developer(
    id: 'ahmad-ali',
    name: 'Ahmad Ali',
    role: 'Architecture & Front-End Engineer',
    bio:
        'Shapes the structure of the application and builds responsive, '
        'high-quality front-end experiences. Focuses on clean, scalable '
        'code that keeps the app fast and easy to extend.',
    focusAreas: ['App Architecture', 'Front-End', 'Clean Code'],
    githubUsername: 'ahmadali-63',
    imageAsset: 'assets/developers/Ahmad Ali.jpeg',
  ),
  Developer(
    id: 'abdullah-qureshi',
    name: 'Abdullah Qureshi',
    role: 'Front-End Developer & UI/UX Designer',
    bio:
        'Designs and implements the look and feel of the app, turning '
        'ideas into intuitive, visually consistent screens with smooth '
        'interactions and careful attention to detail.',
    focusAreas: ['UI/UX Design', 'Front-End', 'Interaction Design'],
    githubUsername: 'SyedAbdullahQureshi',
    imageAsset: 'assets/developers/Abdullah Qureshi.jpeg',
  ),
];
