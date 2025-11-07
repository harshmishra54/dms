import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';
import 'package:TrustTags_DMS/data/models/rout_meeting_list_model.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/route_meeting_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../common/widgets/app_status_bar.dart';

class MeetingHistory extends StatelessWidget {
  final String? tsiId;
  const MeetingHistory({super.key, this.tsiId});

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  Future<Map<String, String?>> _buildRequestBody() async {
    final roleId = await SharedPrefsHelper.getRoleId();
    final userId = await SharedPrefsHelper.getUserId();

    if (roleId == 18) {
      // TSI → use logged in userId
      return {"tsi_id": userId, "u_id": ''};
    } else {
      // RSM or other → use tsiId passed from screen
      return {"tsi_id": tsiId, "u_id": ''};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _buildRequestBody(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final requestBody = snapshot.data!;

        return ChangeNotifierProvider(
          create: (_) => RouteMeetingProvider()
            ..fetchRouteMeetings(requestBody: requestBody),
          child: Scaffold(
            backgroundColor: const Color(0xFFF8F9FD),
            body: Column(
              children: [
                const AppStatusBar(),

                // Custom AppBar
                Container(
                  color: Colors.white,
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Center(
                          child: AutoTranslateText(
                            'Meeting History',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Body
                Expanded(
                  child: Consumer<RouteMeetingProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.errorMessage != null) {
                        return Center(
                          child: AutoTranslateText(
                            provider.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      if (provider.meetings.isEmpty) {
                        return const Center(
                          child: AutoTranslateText(
                            'No meetings found',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.meetings.length,
                        itemBuilder: (context, index) {
                          RouteMeetingData meeting = provider.meetings[index];

                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            margin: const EdgeInsets.only(bottom: 18),
                            elevation: 6,
                            shadowColor: Colors.grey.shade100,
                            child: ListTile(
                              title: AutoTranslateText(
                                meeting.meetingName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoTranslateText(formatDate(meeting.meetingTime),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.place,
                                          size: 16, color: Colors.blueAccent),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: AutoTranslateText(
                                          meeting.routeName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MeetingDetailsPage(meeting),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MeetingDetailsPage extends StatefulWidget {
  final RouteMeetingData meeting;
  const MeetingDetailsPage(this.meeting, {super.key});

  @override
  State<MeetingDetailsPage> createState() => _MeetingDetailsPageState();
}

class _MeetingDetailsPageState extends State<MeetingDetailsPage> {
  final PageController _pageController = PageController();
  int _currentPhoto = 0;

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final meeting = widget.meeting;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Column(
        children: [
          const AppStatusBar(),

          // Custom AppBar
          Container(
            color: Colors.white,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Center(
                    child: AutoTranslateText(
                      meeting.meetingName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Meeting info card
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: Colors.blueAccent),
                          const SizedBox(width: 8),
                          AutoTranslateText(formatDate(meeting.meetingTime),
                              style: const TextStyle(fontSize: 14)),
                        ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.place,
                              size: 18, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                              child: AutoTranslateText(meeting.routeName,
                                  style: const TextStyle(fontSize: 14))),
                        ]),
                      ],
                    ),
                  ),
                ),

                // Notes card
                if (meeting.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: AutoTranslateText(meeting.notes,
                          style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ],

                // Slidable Photos
                if (meeting.meetingPhotos.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const AutoTranslateText("Photos",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: meeting.meetingPhotos.length,
                          onPageChanged: (index) {
                            setState(() => _currentPhoto = index);
                          },
                          itemBuilder: (context, index) {
                            final photoUrl = meeting.meetingPhotos[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FullScreenImagePage(photoUrl: photoUrl),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(photoUrl,
                                    fit: BoxFit.cover, width: double.infinity),
                              ),
                            );
                          },
                        ),
                        // Dots indicator
                        Positioned(
                          bottom: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              meeting.meetingPhotos.length,
                                  (index) => Container(
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPhoto == index ? 10 : 6,
                                height: _currentPhoto == index ? 10 : 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPhoto == index
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],

                // Members list
                if (meeting.meetingMembers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const AutoTranslateText("Members",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meeting.meetingMembers.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.grey),
                      itemBuilder: (context, index) {
                        final member = meeting.meetingMembers[index];
                        return ListTile(
                          leading: const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child:
                              Icon(Icons.person, color: Colors.white)),
                          title: AutoTranslateText(member.name),
                          subtitle: AutoTranslateText(member.phone),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String photoUrl;
  const FullScreenImagePage({super.key, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: Image.network(photoUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
