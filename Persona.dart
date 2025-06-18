import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

void main() {
  runApp(CampusPersonaApp());
}

class CampusPersonaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Persona',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: HomePage(),
      routes: {
        '/qr-scanner': (context) => QRScannerPage(),
        '/friends': (context) => FriendsPage(),
        '/stats': (context) => StatsPage(),
        '/quest': (context) => QuestPage(initialCategory: null), // Default tanpa kategori
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}

class User {
  String name;
  String title;
  int level;
  int currentXP;
  int maxXP;
  Map<String, int> stats;
  List<String> avatarItems;
  List<String> attendedEvents;

  User({
    required this.name,
    required this.title,
    required this.level,
    required this.currentXP,
    required this.maxXP,
    required this.stats,
    required this.avatarItems,
    required this.attendedEvents,
  });
}

class Event {
  String name;
  String location;
  String time;
  int xpReward;
  String qrCode;

  Event({
    required this.name,
    required this.location,
    required this.time,
    required this.xpReward,
    required this.qrCode,
  });
}

class MLService {
  static List<User> recommendFriends(User currentUser, List<User> allUsers) {
    // Clustering berdasarkan level dan stats
    List<User> recommendations = [];
    
    for (User user in allUsers) {
      if (user.name != currentUser.name) {
        double similarity = _calculateSimilarity(currentUser, user);
        if (similarity > 0.7) {
          recommendations.add(user);
        }
      }
    }
    
    recommendations.sort((a, b) => 
        _calculateSimilarity(currentUser, b).compareTo(_calculateSimilarity(currentUser, a)));
    
    return recommendations.take(5).toList();
  }

  static double _calculateSimilarity(User user1, User user2) {
    // Similarity berdasarkan level dan stats
    double levelSimilarity = 1 - (user1.level - user2.level).abs() / 100;
    
    double statsSimilarity = 0;
    user1.stats.forEach((key, value) {
      if (user2.stats.containsKey(key)) {
        statsSimilarity += 1 - (value - user2.stats[key]!).abs() / 100;
      }
    });
    statsSimilarity /= user1.stats.length;
    
    return (levelSimilarity + statsSimilarity) / 2;
  }

  static List<Event> recommendEvents(User user, List<Event> allEvents) {
    // Rekomendasi berdasarkan kegiatan yang sering dihadiri
    Map<String, int> eventCategories = {};
    
    for (String eventName in user.attendedEvents) {
      String category = _getEventCategory(eventName);
      eventCategories[category] = (eventCategories[category] ?? 0) + 1;
    }
    
    List<Event> recommendations = [];
    for (Event event in allEvents) {
      String category = _getEventCategory(event.name);
      if (eventCategories.containsKey(category)) {
        recommendations.add(event);
      }
    }
    
    return recommendations;
  }

  static String _getEventCategory(String eventName) {
    if (eventName.toLowerCase().contains('workshop') || 
        eventName.toLowerCase().contains('design')) {
      return 'Creative';
    } else if (eventName.toLowerCase().contains('marketing') || 
               eventName.toLowerCase().contains('business')) {
      return 'Business';
    } else if (eventName.toLowerCase().contains('tech') || 
               eventName.toLowerCase().contains('coding')) {
      return 'Technology';
    }
    return 'General';
  }
}

class DataService {
  static User currentUser = User(
    name: "Kiraitsu M.",
    title: "The Creative Leader",
    level: 15,
    currentXP: 2450,
    maxXP: 3600,
    stats: {
      'Social': 85,
      'Academic': 92,
      'Leadership': 78,
      'Creative': 96,
    },
    avatarItems: ['hat_1', 'glasses_1', 'shirt_1'],
    attendedEvents: ['Workshop Design Thinking', 'Rapat Tim Marketing', 'Creative Workshop'],
  );

  static List<User> allUsers = [
    User(name: "Alice K.", title: "Tech Enthusiast", level: 12, currentXP: 1800, maxXP: 2500, 
         stats: {'Social': 70, 'Academic': 88, 'Leadership': 65, 'Creative': 75}, 
         avatarItems: [], attendedEvents: []),
    User(name: "Bob S.", title: "Marketing Pro", level: 18, currentXP: 3200, maxXP: 4000, 
         stats: {'Social': 90, 'Academic': 75, 'Leadership': 85, 'Creative': 80}, 
         avatarItems: [], attendedEvents: []),
    User(name: "Carol D.", title: "Design Master", level: 14, currentXP: 2100, maxXP: 3000, 
         stats: {'Social': 80, 'Academic': 82, 'Leadership': 70, 'Creative': 95}, 
         avatarItems: [], attendedEvents: []),
  ];

  static List<Event> todayEvents = [
    Event(name: "Rapat Tim Marketing", location: "Ruang Rapat A", 
          time: "09:00", xpReward: 250, qrCode: "MARKETING_001"),
    Event(name: "Workshop Design Thinking", location: "Lab Komputer 2", 
          time: "13:30", xpReward: 180, qrCode: "DESIGN_002"),
    Event(name: "Seminar Teknologi", location: "Auditorium", 
          time: "15:00", xpReward: 300, qrCode: "TECH_003"),
  ];

  static void addXP(int amount) {
    currentUser.currentXP += amount;
    while (currentUser.currentXP >= currentUser.maxXP) {
      currentUser.currentXP -= currentUser.maxXP;
      currentUser.level++;
      currentUser.maxXP = (currentUser.maxXP * 1.2).round();
    }
  }

  static void unlockAvatarItem(String item) {
    if (!currentUser.avatarItems.contains(item)) {
      currentUser.avatarItems.add(item);
    }
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? _lastSelectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildUserCard(),
              SizedBox(height: 20),
              _buildStatsRow(),
              SizedBox(height: 30),
              _buildTodayActivities(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/qr-scanner'),
        backgroundColor: Colors.deepPurple,
        child: Icon(CupertinoIcons.qrcode_viewfinder, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(CupertinoIcons.building_2_fill, color: Colors.deepPurple, size: 24),
        SizedBox(width: 8),
        Text(
          'Campus Persona',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Spacer(),
        Text(
          'Level up your campus life!',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(width: 8),
        IconButton(
          icon: Icon(CupertinoIcons.bell),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildUserCard() {
    User user = DataService.currentUser;
    double progress = user.currentXP / user.maxXP;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.yellow,
                child: Icon(CupertinoIcons.person_fill, size: 30, color: Colors.white),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Text(
                user.level.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${user.currentXP} / ${user.maxXP} XP',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${(user.maxXP - user.currentXP)} XP to next level',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    User user = DataService.currentUser;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: user.stats.entries.map((entry) {
        IconData icon;
        switch (entry.key) {
          case 'Social':
            icon = CupertinoIcons.person_2_fill;
            break;
          case 'Academic':
            icon = CupertinoIcons.book_fill;
            break;
          case 'Leadership':
            icon = CupertinoIcons.star_fill;
            break;
          case 'Creative':
            icon = CupertinoIcons.paintbrush_fill;
            break;
          default:
            icon = CupertinoIcons.star;
        }

        return Column(
          children: [
            Icon(icon, color: Colors.grey[600]),
            SizedBox(height: 4),
            Text(
              entry.key,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Text(
              entry.value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTodayActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(CupertinoIcons.calendar_today, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text(
              "Today's Activities",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...DataService.todayEvents.map((event) => _buildEventCard(event)),
      ],
    );
  }

  Widget _buildEventCard(Event event) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            child: Text(
              event.time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(CupertinoIcons.location_solid, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      event.location,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${event.xpReward} XP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        
        switch (index) {
          case 0: // Home
            break;
          case 1:
            Navigator.pushNamed(context, '/friends');
            break;
          case 2:
            Navigator.pushNamed(context, '/stats');
            break;
          case 3:
            // Navigasi ke QuestPage dengan membawa kategori terakhir
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => QuestPage(
                  initialCategory: _lastSelectedCategory,
                ),
              ),
            );
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_fill), 
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_2_fill), 
          label: 'Friends'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chart_bar_fill), 
          label: 'Stats'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.list_bullet), 
          label: 'Quest'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_fill), 
          label: 'Profile'
        ),
      ],
    );
  }
}

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  // Dummy QR codes untuk testing
  List<String> dummyQRCodes = [
    'MARKETING_001',
    'DESIGN_002', 
    'TECH_003',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.qrcode_viewfinder,
                      size: 100,
                      color: Colors.deepPurple,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'QR Scanner',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Scan QR code to get XP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Test with Dummy QR Codes:',
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: dummyQRCodes.map((code) => 
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          child: ElevatedButton(
                            onPressed: () => _handleQRCode(code),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.qrcode, size: 20),
                                SizedBox(height: 4),
                                Text(
                                  code.split('_')[0],
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ).toList(),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap any button above to simulate QR scan',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCode(String qrCode) {
     Event? event;
  
    for (Event e in DataService.todayEvents) {
      if (e.qrCode == qrCode) {
        event = e;
        break;
      }
    }

    if (event != null) {
      DataService.addXP(event.xpReward);

      // Simpan kategori terakhir
      final homeState = context.findAncestorStateOfType<_HomePageState>();
      if (homeState != null) {
        homeState.setState(() {
          homeState._lastSelectedCategory = qrCode.split('_')[0];
        });
      }

      // Navigasi ke QuestPage dengan membawa kategori
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuestPage(
            initialCategory: qrCode.split('_')[0],
          ),
        ),
      );
      
      // Update quest progress
      final questPageState = context.findAncestorStateOfType<_QuestPageState>();
      if (questPageState != null) {
        questPageState.completeRecommendedQuest(qrCode);
        questPageState.updateScanQuestProgress();
      }

      // Random avatar item reward
      List<String> possibleItems = ['hat_2', 'glasses_2', 'shirt_2', 'badge_1'];
      if (Random().nextBool()) {
        String item = possibleItems[Random().nextInt(possibleItems.length)];
        DataService.unlockAvatarItem(item);
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(CupertinoIcons.checkmark_circle_fill, 
                   color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Event Attended!'),
            ],
          ),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎉 You attended: ${event!.name}'),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '💰 XP Gained: +${event.xpReward}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                if (Random().nextBool()) ...[
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🎁 New avatar item unlocked!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
              Navigator.pop(context); // Hanya tutup dialog
                // Jangan navigasi kembali ke HomePage
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Awesome!'),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  int _selectedIndex = 1;
  String _selectedTab = 'My Friends';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.person_2_fill, color: Colors.deepPurple, size: 24),
              SizedBox(width: 8),
              Text(
                'Campus Friends',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'Connect with your campus community',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: TextField(
          decoration: InputDecoration(
            icon: Icon(CupertinoIcons.search, color: Colors.grey),
            hintText: 'Search friends by name or level...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    List<String> tabs = ['My Friends', 'Recommended', 'Requests', 'Ranking'];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: tabs.map((tab) {
          bool isSelected = _selectedTab == tab;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = tab;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepPurple : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSquadHeader(),
          SizedBox(height: 16),
          Expanded(child: _buildFriendsList()),
        ],
      ),
    );
  }

  Widget _buildSquadHeader() {
    return Row(
      children: [
        Icon(CupertinoIcons.person_3_fill, color: Colors.black, size: 20),
        SizedBox(width: 8),
        Text(
          'Campus Squad (15)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildFriendsList() {
    List<Map<String, dynamic>> friends = [
      {
        'name': 'Andi Pratama',
        'level': 12,
        'title': 'The Strategist',
        'status': 'Online now',
        'statusColor': Colors.green,
        'initial': 'A',
      },
      {
        'name': 'Sari Dewi',
        'level': 18,
        'title': 'The Academic',
        'status': 'Away • Last seen 2h ago',
        'statusColor': Colors.orange,
        'initial': 'S',
      },
      {
        'name': 'Rio Saputra',
        'level': 14,
        'title': 'The Innovator',
        'status': 'Online • In Library',
        'statusColor': Colors.green,
        'initial': 'R',
      },
      {
        'name': 'Dina Marlina',
        'level': 13,
        'title': 'The Collaborator',
        'status': 'Offline • Last seen yesterday',
        'statusColor': Colors.grey,
        'initial': 'D',
      },
    ];

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        var friend = friends[index];
        return _buildFriendCard(friend);
      },
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.yellow,
            child: Text(
              friend['initial'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Level ${friend['level']} • ${friend['title']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: friend['statusColor'],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      friend['status'],
                      style: TextStyle(
                        fontSize: 12,
                        color: friend['statusColor'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Chat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'View',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        
        switch (index) {
          case 0:
            Navigator.pushReplacementNamed(context, '/');
            break;
          case 1:
            break;
          case 2:
            Navigator.pushNamed(context, '/stats');
            break;
          case 3:
            Navigator.pushNamed(context, '/quest');
            break;
          case 4:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_fill), 
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_2_fill), 
          label: 'Friends'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chart_bar_fill), 
          label: 'Stats'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.list_bullet), 
          label: 'Quest'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_fill), 
          label: 'Profile'
        ),
      ],
    );
  }
}

class StatsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Your Progress',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...DataService.currentUser.stats.entries.map((entry) =>
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestPage extends StatefulWidget {
  final String? initialCategory;
  
  const QuestPage({Key? key, this.initialCategory}) : super(key: key);

  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  int _selectedIndex = 3;
  String? _selectedQuestCategory; // Tambahkan state untuk kategori yang dipilih
  
  @override
  void initState() {
    super.initState();
    _selectedQuestCategory = widget.initialCategory;
  }

  // Daftar daily missions yang sudah ada
  List<Map<String, dynamic>> dailyMissions = [
    {
      'title': 'Attend Classes',
      'xp': 50,
      'description': 'Hadir ke minimal 2 kelas hari ini',
      'completed': 2,
      'required': 2,
      'isCompleted': true,
    },
    {
      'title': 'Help a Friend',
      'xp': 30,
      'description': 'Bantu teman dengan tugas atau masalah',
      'completed': 1,
      'required': 1,
      'isCompleted': true,
    },
    {
      'title': 'Join UKM Activity',
      'xp': 75,
      'description': 'Ikuti kegiatan UKM apapun hari ini',
      'completed': 0,
      'required': 1,
      'isCompleted': false,
    },
    {
      'title': 'Find UKM',
      'xp': 0,
      'description': 'Skip Quest',
      'completed': 0,
      'required': 0,
      'isCompleted': false,
    },
    {
      'title': 'Scan QR Codes',
      'xp': 25,
      'description': 'Scan 3 QR code dari berbagai tempat di kampus',
      'completed': 2,
      'required': 3,
      'isCompleted': false,
    },
    {
      'title': 'Open Scanner',
      'xp': 0,
      'description': '',
      'completed': 0,
      'required': 0,
      'isCompleted': false,
    },
  ];

  // Daftar recommended quests berdasarkan QR
  List<Map<String, dynamic>> allRecommendedQuests = [ // Ganti nama variabel
    {
      'title': 'Attend Marketing Event',
      'xp': 100,
      'description': 'Hadiri acara marketing untuk mendapatkan XP',
      'qrCode': 'MARKETING',
      'isCompleted': false,
      'category': 'MARKETING', // Tambahkan field category
    },
    {
      'title': 'Join Design Workshop',
      'xp': 120,
      'description': 'Ikuti workshop design untuk meningkatkan skill kreatif',
      'qrCode': 'DESIGN',
      'isCompleted': false,
      'category': 'DESIGN',
    },
    {
      'title': 'Tech Seminar Participation',
      'xp': 150,
      'description': 'Hadiri seminar teknologi terbaru',
      'qrCode': 'TECH',
      'isCompleted': false,
      'category': 'TECH',
    },
  ];

  // Getter untuk quest yang difilter
  List<Map<String, dynamic>> get recommendedQuests {
    if (_selectedQuestCategory == null) {
      return []; // Atau return allRecommendedQuests jika ingin tampilkan semua saat awal
    }
    return allRecommendedQuests.where((quest) => 
        quest['category'] == _selectedQuestCategory).toList();
  }

  void completeRecommendedQuest(String qrCode) {
    setState(() {
      // Ekstrak kategori dari QR code (contoh: "DESIGN_002" → "DESIGN")
      _selectedQuestCategory = qrCode.split('_')[0];
      
      // Tandai quest sebagai completed
      for (var quest in allRecommendedQuests) {
        if (quest['category'] == _selectedQuestCategory) {
          quest['isCompleted'] = true;
          DataService.addXP(quest['xp'] as int);
          break;
        }
      }
    });
  }


  void updateScanQuestProgress() {
    setState(() {
      for (var mission in dailyMissions) {
        if (mission['title'] == 'Scan QR Codes') {
          // Konversi nilai ke int sebelum menggunakan min()
          int completed = mission['completed'] as int;
          int required = mission['required'] as int;
          mission['completed'] = min(completed + 1, required);
          mission['isCompleted'] = mission['completed'] >= required;
        }
      }
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: AppBar(
      title: Text('Quest Board'),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete quests to level up!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          
          // Daily Missions
          Text(
            'Daily Missions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 16),
          ...dailyMissions.map((mission) => _buildMissionCard(mission)).toList(),
          
          SizedBox(height: 24),
          
          // Recommended Quests
            Text(
              _selectedQuestCategory != null 
                  ? 'Recommended Quest' 
                  : 'Recommended Quests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            SizedBox(height: 16),
            
            // Menampilkan quest berdasarkan kondisi
            if (_selectedQuestCategory != null)
              ...recommendedQuests.map((quest) => _buildRecommendedQuestCard(quest)).toList(),
            if (_selectedQuestCategory == null)
              ...allRecommendedQuests.map((quest) => _buildRecommendedQuestCard(quest)).toList(),
          
          // Weekly Challenges
          Text(
            'Weekly Challenges',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Coming soon...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: _buildBottomNav(),
  );
}

  Widget _buildMissionCard(Map<String, dynamic> mission) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: mission['isCompleted'],
                onChanged: (value) {
                  setState(() {
                    mission['isCompleted'] = value ?? false;
                  });
                },
                activeColor: Colors.deepPurple,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission['title'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: mission['isCompleted']
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    if (mission['xp'] > 0)
                      Text(
                        '+${mission['xp']} XP',
                        style: TextStyle(
                          color: Colors.teal,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (mission['description'].isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 48, top: 8),
              child: Text(
                mission['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          if (mission['required'] > 0)
            Padding(
              padding: EdgeInsets.only(left: 48, top: 8),
              child: LinearProgressIndicator(
                value: mission['completed'] / mission['required'],
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
          if (mission['required'] > 0)
            Padding(
              padding: EdgeInsets.only(left: 48, top: 4),
              child: Text(
                '${mission['completed']}/${mission['required']} '
                '${mission['completed'] >= mission['required'] ? 'Completed ✓' : mission['completed'] >= mission['required'] * 0.7 ? 'Almost Done!' : 'In Progress'}',
                style: TextStyle(
                  fontSize: 12,
                  color: mission['completed'] >= mission['required']
                      ? Colors.green
                      : Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendedQuestCard(Map<String, dynamic> quest) {
  return Container(
    margin: EdgeInsets.only(bottom: 16),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: quest['isCompleted'],
              onChanged: (value) {
                setState(() {
                  quest['isCompleted'] = value ?? false;
                });
              },
              activeColor: Colors.deepPurple,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: quest['isCompleted']
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text(
                    '+${quest['xp']} XP',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 48, top: 8),
          child: Text(
            quest['description'],
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 48, top: 8),
          child: Text(
            'Scan QR Code: ${quest['qrCode']}',
            style: TextStyle(
              color: Colors.deepPurple,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildBottomNav() {
    return BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: (index) {
      setState(() {
        _selectedIndex = index;
      });
      
      if (index == _selectedIndex) return; // Tidak lakukan apa-apa jika sudah di halaman yang sama

      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/friends');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/stats');
          break;
        case 3:
          // Tetap di halaman yang sama
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
      }
    },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.house_fill), 
          label: 'Home'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_2_fill), 
          label: 'Friends'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chart_bar_fill), 
          label: 'Stats'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.list_bullet), 
          label: 'Quest'
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person_fill), 
          label: 'Profile'
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User user = DataService.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple,
              child: Icon(CupertinoIcons.person_fill, size: 50, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              user.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(user.title),
            SizedBox(height: 20),
            Text(
              'Avatar Items: ${user.avatarItems.length}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Wrap(
              children: user.avatarItems.map((item) => 
                Chip(label: Text(item))
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
