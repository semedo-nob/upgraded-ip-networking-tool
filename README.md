
IP Networking Tool
Platform: Flutter
License: MIT
Flutter Version: 3.19.0+
A mobile-first, offline-capable IP subnetting tool built with Flutter for network administrators, IT students, and hobbyists. Calculate IPv4 subnets using Variable Length Subnet Masking (VLSM), save calculation history, export results to CSV/PDF, and visualize bitwise operations for educational purposes.
📖 Table of Contents
Features (#features)
Screenshots (#screenshots)
Installation (#installation)
Usage (#usage)
Project Structure (#project-structure)
Dependencies (#dependencies)
Contributing (#contributing)
Future Plans (#future-plans)
License (#license)
Contact (#contact)
✨ Features
IPv4 Subnetting with VLSM:
Calculate subnets for inputs like 192.168.1.0/24 with custom LANs (e.g., "Finance: 45 users").
Outputs CIDR, subnet mask, network address, broadcast address, usable IPs, and IP waste.
Supports manual mode (user-defined LANs) and auto mode (basic auto-allocation).
Accurate calculations (e.g., broadcast: 192.168.1.63, usable IPs: 192.168.1.1 → .62 for /26).
History Storage:
Saves calculations to a local history.json file for revisiting past subnets.
Displays history in the Output tab with pagination and search functionality.
Handles corrupt data with robust error messages.
Export Capabilities:
Export subnet results to CSV (single or all history entries).
Generate formatted PDF reports for professional use.
Files saved to the device’s Documents directory.
Bitwise Visualization:
Interactive bitwise operation view to understand subnet calculations (e.g., network vs. broadcast address).
Educational tool for CCNA/Network+ students.
User-Friendly Interface:
Tabbed navigation (Input, Output, Export) for seamless workflow.
Input validation and error handling for reliable calculations.
Offline support for on-the-go use.
Recent Improvements:
Fixed MapEntry operator error for history parsing.
Corrected broadcast address and usable IPs calculations.
Enhanced error handling for file operations and invalid inputs.
📷 Screenshots
Coming soon! (Add screenshots of Input, Output, and Export tabs after UI polish.)
🛠️ Installation
Prerequisites
Flutter: Version 3.19.0 or higher (flutter --version).
Dart: Included with Flutter.
IDE: VS Code, Android Studio, or IntelliJ IDEA.
Devices: Android/iOS emulator or physical device.
Steps
Clone the Repository:
bash
git clone https://github.com/your-username/ip-networking-tool.git
cd ip-networking-tool
Install Dependencies:
bash
flutter pub get
Run the App:
bash
flutter run --debug
Select an emulator or connected device.
Ensure Android SDK or Xcode is configured for Android/iOS builds.
Build for Release
Android: flutter build apk --release
iOS: flutter build ios --release (requires macOS and Xcode)
📋 Usage
Launch the App:
Open on an Android/iOS device or emulator.
Navigate via the bottom navigation bar (Input, Output, Export).
Calculate Subnets:
Input Tab:
Enter a network IP (e.g., 192.168.1.0/24 or 192.168.1.0,255.255.255.0).
Choose Manual mode to add LANs (e.g., Name: "Finance", Users: 45).
Click "Calculate" to process.
Example Input:
IP: 192.168.1.0/24
LAN 1: Finance, 45 users
LAN 2: ICT, 62 users
Example Output (Output Tab):
LAN Name: Finance
CIDR: /26
Subnet Mask: 255.255.255.192
Network Address: 192.168.1.0
Broadcast Address: 192.168.1.63
Usable IPs: 192.168.1.1 → 192.168.1.62
IP Waste: 17
View History:
In the Output tab, select past calculations via a dropdown.
Search LANs by name, IP, or CIDR.
Paginate results for large subnets.
Export Results:
Output Tab: Export all history to CSV with "Export All to CSV".
Export Tab: Export current calculation to CSV or PDF.
Files are saved to Documents (e.g., Android: data/data/<package>/app_flutter/).
Visualize Bitwise Operations:
In the Output tab, click "Visualize" on a LAN to see bitwise calculations (e.g., network address AND subnet mask).
Example Workflow
Enter 192.168.1.0/24 in the Input tab.
Add LANs: "Finance" (45 users), "ICT" (62 users).
Calculate and view results in the Output tab.
Export to PDF for a report.
Revisit the calculation later via history.
📂 Project Structure
ip-networking-tool/
├── assets/                  # Assets (e.g., future questions.json)
├── lib/
│   ├── logic/               # Core logic
│   │   └── subnet_calculator.dart
│   ├── models/              # Data models
│   │   ├── ip_info.dart
│   │   └── lan_model.dart
│   ├── screens/             # UI screens
│   │   ├── export_tab.dart
│   │   ├── home_screen.dart
│   │   ├── input_tab.dart
│   │   └── output_tab.dart
│   ├── utils/               # Utilities
│   │   ├── export_to_csv.dart
│   │   └── history_storage.dart
│   ├── widgets/             # Reusable UI components
│   │   ├── bitwise_operations.dart
│   │   ├── bitwise_view.dart
│   │   ├── lan_input_tile.dart
│   │   └── lan_output_tile.dart
│   └── main.dart            # App entry point
├── pubspec.yaml             # Dependencies and configuration
└── README.md                # Project documentation
📦 Dependencies
flutter: SDK for cross-platform UI.
path_provider: ^2.1.5: File system access for history and exports.
csv: ^6.0.0: CSV file generation.
pdf: ^3.10.8: PDF report generation.
See pubspec.yaml for details.
🤝 Contributing
Contributions are welcome! To contribute:
Fork the repository.
Create a feature branch (git checkout -b feature/your-feature).
Commit changes (git commit -m "Add your feature").
Push to the branch (git push origin feature/your-feature).
Open a pull request with a clear description.
Guidelines
Follow Dart coding conventions.
Add tests for new features (future: unit tests for subnet_calculator.dart).
Update documentation (e.g., README, code comments).
🚀 Future Plans
Dark Mode: Add light/dark theme switching for better UX.
Learning Mode: Include subnetting quizzes for CCNA/Network+ preparation.
Onboarding: Guide new users with an interactive tutorial.
Basic IPv6 Support: Parse and calculate IPv6 subnets.
Error Reporting: Integrate Sentry for crash tracking.
Monetization: Introduce a freemium model with premium features (e.g., IPv6, advanced quizzes).
Network Simulation: Visualize and simulate network topologies.
Cloud Sync: Save history to Firebase for cross-device access.
See Issues for planned enhancements.
📜 License
This project is licensed under the MIT License. See LICENSE for details.
📬 Contact
Author: [NELSON APIDI]
Email: [nsemedo73@gmail.com]
GitHub: semedo-nob
Issues: Report bugs or suggest features here.


MIT License

Copyright (c) 2025 [NELSON]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
Update the repository URL (https://github.com/your-username/ip-networking-tool) once you host the project.


Check links (e.g., Issues, License) after hosting.
Update pubspec.yaml:
Ensure dependencies match:

dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.5
  csv: ^6.0.0
  pdf: ^3.10.8
Verify Flutter version: flutter --version (3.19.0+).
