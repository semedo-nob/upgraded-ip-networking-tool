# 📡 IP Networking Tool

**Platform:** Flutter  
**License:** MIT  
**Flutter Version:** 3.19.0+  

A mobile-first, offline-capable subnetting utility built with Flutter. Designed for network administrators, IT students, and hobbyists, the tool calculates IPv4 subnets using VLSM, visualizes bitwise operations, stores subnet history, and exports results in CSV or PDF format.

---

## 📚 Table of Contents

- [✨ Features](#-features)  
- [📸 Screenshots](#-screenshots)  
- [🔧 Installation](#-installation)  
- [🚀 Usage](#-usage)  
- [📂 Project Structure](#-project-structure)  
- [📦 Dependencies](#-dependencies)  
- [🤝 Contributing](#-contributing)  
- [📈 Future Plans](#-future-plans)  
- [📜 License](#-license)  
- [📬 Contact](#-contact)

---

## ✨ Features

### 🔢 IPv4 Subnetting with VLSM
- Input base IP (e.g. `192.168.1.0/24`) and define LANs with required hosts.
- Outputs:  
  - CIDR  
  - Subnet mask  
  - Network & broadcast address  
  - Usable IPs  
  - IP waste count  

### 🕘 History Storage
- Stores calculations locally.
- Browse history with pagination & search.
- Handles data corruption gracefully.

### 📤 Export Support
- Export results in:
  - CSV (per LAN or entire history)
  - PDF reports
- Files saved to device’s **Documents** directory.

### 🧠 Bitwise Visualization
- See bitwise logic (e.g. subnet mask AND operation).
- Great for CCNA/Network+ learning.

### 🎯 User-Friendly Interface
- Tabbed navigation: **Input**, **Output**, **Export**
- Input validation & error alerts
- Fully offline-capable

### ✅ Recent Fixes
- Resolved history parsing issues (`MapEntry` operator).
- Improved IP calculation accuracy.
- Hardened error handling (file I/O, validation).

---

## 📸 Screenshots

_(Coming soon: Include UI images for Input, Output, Export tabs)_

---

## 🔧 Installation

### 📋 Prerequisites
- Flutter SDK 3.19.0+
- Dart (bundled with Flutter)
- IDE: VS Code, Android Studio, or IntelliJ
- Android/iOS emulator or device

### 📥 Steps

1. **Clone the Repository**
  
   git clone https://github.com/your-username/ip-networking-tool.git
   cd ip-networking-tool
Install Dependencies


flutter pub get
Run the App


flutter run
Build for Release

Android:


flutter build apk --release
iOS (macOS only):


flutter build ios --release
🚀 Usage
🧮 Calculate Subnets
Navigate to Input Tab

Enter:

Base IP (e.g. 192.168.1.0/24)

Add LANs (e.g. Finance: 45 users)

Tap Calculate

📝 Example Input
yaml
Copy
Edit
IP:       192.168.1.0/24
LAN 1:    Finance - 45 users
LAN 2:    ICT     - 62 users
✅ Example Output
yaml
Copy
Edit
LAN Name:         Finance
CIDR:             /26
Subnet Mask:      255.255.255.192
Network Address:  192.168.1.0
Broadcast:        192.168.1.63
Usable IPs:       192.168.1.1 → 192.168.1.62
IP Waste:         17
📜 View History
Check saved subnets in Output Tab

Filter by LAN name, CIDR, or address

Paginated view for long history

📁 Export Options
Output Tab → Export All to CSV

Export Tab → Export current calculation to CSV or PDF

Files saved to:


Android: data/data/<package>/app_flutter/
🔍 Bitwise Visualization
Tap “Visualize” to see bitwise operations

Shows AND logic between IP & subnet mask

📂 Project Structure
graphql
Copy
Edit
ip-networking-tool/
├── assets/                  # Static files (e.g., future quizzes)
├── lib/
│   ├── logic/               # Core VLSM and IP logic
│   ├── models/              # LAN and IP data classes
│   ├── screens/             # Input, Output, Export tabs
│   ├── utils/               # Storage & export helpers
│   ├── widgets/             # Reusable UI components
│   └── main.dart            # App entry point
├── pubspec.yaml             # Dependencies & metadata
└── README.md                # This file
📦 Dependencies

dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.1.5
  csv: ^6.0.0
  pdf: ^3.10.8
See pubspec.yaml for full list.

🤝 Contributing
Fork the repo

Create a feature branch


git checkout -b feature/your-feature
Commit and push


git commit -m "Add feature"
git push origin feature/your-feature
Open a Pull Request

📌 Guidelines
Follow Dart style conventions.

Write tests for new logic (planned).

Document any new features.

📈 Future Plans
Planned Feature	Description
✅ Dark Mode	Theme toggle for better UX
✅ Learn Mode	CCNA-style subnetting quizzes
✅ Onboarding	First-time user guide/tutorial
✅ IPv6 Support (Basic)	For modern networks
✅ Error Reporting	Sentry integration
✅ Freemium Monetization	Unlock advanced features
✅ Network Simulation	Visualize routers, hosts, subnets
✅ Cloud Sync	Firebase history & cross-device use

See Issues for updates.

📜 License
This project is licensed under the MIT License.


MIT License

Copyright (c) 2025 NELSON

Permission is hereby granted, free of charge, to any person obtaining a copy...
📬 Contact
Author: Nelson Apidi

Email: nsemedo73@gmail.com

GitHub: semedo-nob

Issues: Submit Feedback
