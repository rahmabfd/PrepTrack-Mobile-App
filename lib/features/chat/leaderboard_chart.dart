import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import 'dart:ui';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900,
              Colors.lightBlue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('points', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error loading leaderboard',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      );
                    }

                    final users = snapshot.data!.docs;
                    int? currentUserIndex;
                    if (currentUser != null) {
                      currentUserIndex =
                          users.indexWhere((doc) => doc['uid'] == currentUser.uid);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: users.length +
                          (currentUserIndex != null && currentUserIndex >= 0 ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (currentUserIndex != null &&
                            currentUserIndex >= 0 &&
                            index == 0 &&
                            currentUserIndex > 2) {
                          final userData =
                          users[currentUserIndex].data() as Map<String, dynamic>;
                          return _buildUserCard(
                            context,
                            userData,
                            currentUserIndex + 1,
                            isCurrentUser: true,
                          );
                        }
                        final adjustedIndex = (currentUserIndex != null &&
                            currentUserIndex >= 0 &&
                            index > 0 &&
                            currentUserIndex > 2)
                            ? index - 1
                            : index;
                        if (adjustedIndex >= users.length) return const SizedBox.shrink();
                        final userData = users[adjustedIndex].data() as Map<String, dynamic>;
                        final isCurrentUser =
                            currentUser != null && userData['uid'] == currentUser.uid;
                        return _buildUserCard(
                          context,
                          userData,
                          adjustedIndex + 1,
                          isCurrentUser: isCurrentUser,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Navigate back to the previous screen (home)
            },
          ),
          const Expanded(
            child: Text(
              'Leaderboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black45,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 24,
              ),
            ),
            onPressed: () {
              // Trigger a refresh if needed
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, Map<String, dynamic> userData, int rank, {bool isCurrentUser = false}) {
    final badge = _getBadgeLevel(userData['badge'] ?? 'bronze');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrentUser ? Colors.amberAccent.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                width: isCurrentUser ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              leading: _buildRankAvatar(rank, isCurrentUser),
              title: Text(
                '${userData['name']} ${userData['surname']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isCurrentUser ? Colors.amberAccent : Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 3,
                      color: Colors.black45,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    '${userData['school']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      shadows: const [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    ' ${userData['class']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      shadows: const [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Points: ${userData['points']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.9),
                      shadows: const [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black45,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: _buildBadgeWidget(badge),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankAvatar(int rank, bool isCurrentUser) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: isCurrentUser ? Colors.amberAccent : Colors.indigo.shade300,
      child: Text(
        rank.toString(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBadgeWidget(BadgeLevel badge) {
    String badgeText;
    Color badgeColor;
    IconData badgeIcon;

    switch (badge) {
      case BadgeLevel.platinum:
        badgeText = 'Platinum';
        badgeColor = Colors.grey.shade200;
        badgeIcon = Icons.diamond;
        break;
      case BadgeLevel.gold:
        badgeText = 'Gold';
        badgeColor = Colors.amber.shade400;
        badgeIcon = Icons.star;
        break;
      case BadgeLevel.silver:
        badgeText = 'Silver';
        badgeColor = Colors.grey.shade400;
        badgeIcon = Icons.star_border;
        break;
      case BadgeLevel.bronze:
        badgeText = 'Bronze';
        badgeColor = Colors.brown.shade300;
        badgeIcon = Icons.star_border;
        break;
      default:
        badgeText = 'None';
        badgeColor = Colors.grey;
        badgeIcon = Icons.star_border;
    }

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 50, maxHeight: 50), // Tighter constraints
        padding: const EdgeInsets.all(6), // Smaller padding
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: badgeColor, // Fully colored background
          boxShadow: [
            BoxShadow(
              color: badgeColor.withOpacity(0.5),
              blurRadius: 4, // Smaller glow
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              badgeIcon,
              size: 16, // Smaller icon
              color: Colors.black87, // Darker icon for contrast
            ),
            Text(
              badgeText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10, // Smaller font
                fontWeight: FontWeight.w600,
                color: Colors.black87, // Darker text for contrast
                shadows: const [
                  Shadow(
                    blurRadius: 1,
                    color: Colors.black45,
                    offset: Offset(0.5, 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BadgeLevel _getBadgeLevel(String badgeString) {
    switch (badgeString.toLowerCase()) {
      case 'platinum':
        return BadgeLevel.platinum;
      case 'gold':
        return BadgeLevel.gold;
      case 'silver':
        return BadgeLevel.silver;
      case 'bronze':
        return BadgeLevel.bronze;
      default:
        return BadgeLevel.none;
    }
  }
}