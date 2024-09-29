OneBet - Sports Betting Management App 📱🎉
OneBet is a mobile application designed for sports betting enthusiasts, offering an intuitive experience to create, track, and share bets. Whether you're a beginner or a seasoned bettor, OneBet keeps you informed and connected with the betting community.

🚀 Features
Bet Management: Create, track, and share your sports bets.
Authentication: Secure login via Google, Facebook, or Email.
Social Sharing: Share your predictions and discuss results with other users.
Personal Statistics: Track your performance and improve your betting strategy.
Image Uploads: Share images related to your bets for better interaction.
🛠️ Technologies Used
Language: Swift
Architecture: MVC (Model-View-Controller)
Interface: UIKit & SwiftUI
Backend: Firebase
Firestore: For managing data (bets, users, publications).
Firebase Auth: For authentication (Google, Facebook, Email).
Firebase Storage: For image upload and storage.
📱 Installation
Clone the repository:
sh
Copier le code
git clone https://github.com/FlopDev/OneBet.git
Install dependencies using CocoaPods (if necessary):
sh
Copier le code
cd OneBet
pod install
Open the project:
Use the .xcworkspace file to open the project in Xcode:
sh
Copier le code
open OneBet.xcworkspace
Configure Firebase:
Download the GoogleService-Info.plist file from the Firebase console and add it to the project in Xcode.
🧪 Testing
The OneBet app uses unit tests to verify business logic. Tests focus on:

Managing notifications (FBAnswerSuccess, FBAnswerFail).
Validating data preparation before sending it to Firebase.
To run the tests:

Open the project in Xcode.
Press Cmd + U to run the unit tests.
📂 Project Structure
Models: Handles data (User, Publication, Comment).
Controllers: Contains business logic and Firebase interactions.
Services:
FirebaseService: Authentication and user data management.
FirebaseStorageService: Image management.
Views: Uses UIKit and SwiftUI for a modern, responsive user interface.
✨ Key Features
Performance: Asynchronous image downloads to prevent UI lag.
Security: Authentication is managed by Firebase for added security.
Clear Architecture: MVC architecture and shared services for clean separation of responsibilities.
📖 Roadmap
Push Notifications: To keep users updated in real time.
Enhanced User Profiles: Add advanced statistics and a more detailed interface.
Live Betting Modes: Real-time tracking of bets with chat functionality.
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

👥 Contributors
Florian Peyrony - Lead Developer
Open to Contributions: Contributions are welcome! Feel free to submit issues or pull requests.
📞 Contact
If you have any questions, feel free to contact us:

Email: peyronyflorian.pro@gmail.com
Website: www.flopdev-wordpress.com
