import 'package:TrustTags_DMS/common/widgets/auto_translate_text.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/approve_distributor_registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TrustTags_DMS/common/widgets/app_status_bar.dart';
import 'package:TrustTags_DMS/features/salesDashboard/provider/distributor_for_approval_provider.dart';
import 'package:TrustTags_DMS/core/utils/shared_prefs_helper.dart';

class DistributorApprovalListScreen extends StatefulWidget {
  const DistributorApprovalListScreen({super.key});

  @override
  State<DistributorApprovalListScreen> createState() =>
      _DistributorApprovalListScreenState();
}

class _DistributorApprovalListScreenState
    extends State<DistributorApprovalListScreen> {
  String? loadingDistributorId; // track which distributor is currently updating
  String? _userId; // store userId from shared prefs

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final userId = await SharedPrefsHelper.getUserId(); // ✅ helper method
    setState(() {
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    // wait until userId is loaded
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DistributorRsmProvider()..fetchDistributors(_userId!),
        ),
        ChangeNotifierProvider(
          create: (_) => UpdateDistributorProvider(),
        ),
      ],
      child: Scaffold(
        body: Column(
          children: [
            const AppStatusBar(),

            /// Custom AppBar
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const AutoTranslateText(
                    "Registered Distributor",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon:
                      const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),

            /// Body List
            Expanded(
              child: Consumer2<DistributorRsmProvider,
                  UpdateDistributorProvider>(
                builder: (context, provider, updateProvider, _) {
                  if (provider.loading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  } else if (provider.errorMessage != null) {
                    return Center(
                      child: AutoTranslateText(
                        provider.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (provider.distributors.isEmpty) {
                    return const Center(
                        child: AutoTranslateText("No distributors found"));
                  }

                  return ListView.builder(
                    itemCount: provider.distributors.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final distributor = provider.distributors[index];
                      final id = distributor.id ?? '';

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: AutoTranslateText(
                                    distributor.name?.substring(0, 1) ?? "-",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: AutoTranslateText(
                                  distributor.name ?? "-",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),


                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // APPROVE BUTTON
                                  SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed:
                                      loadingDistributorId == id
                                          ? null
                                          : () async {
                                        setState(() =>
                                        loadingDistributorId =
                                            id);

                                        await updateProvider
                                            .updateDistributorStatus(
                                          id: id,
                                          status: true,
                                        );

                                        if (updateProvider
                                            .error !=
                                            null) {
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: AutoTranslateText(
                                                  updateProvider
                                                      .error!),
                                            ),
                                          );
                                        } else if (updateProvider
                                            .response !=
                                            null) {
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: AutoTranslateText(
                                                  updateProvider
                                                      .response!
                                                      .message),
                                            ),
                                          );
                                          // Refetch distributor list
                                          await provider
                                              .fetchDistributors(
                                              _userId!);
                                        }

                                        setState(() =>
                                        loadingDistributorId =
                                        null);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                            color: Colors.purple,
                                            width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              20), // circular pill shape
                                        ),
                                        minimumSize: const Size(80, 36),
                                      ),
                                      child: loadingDistributorId == id &&
                                          updateProvider.isLoading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                        CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const AutoTranslateText(
                                        "Approve",
                                        style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight:
                                            FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // REJECT BUTTON
                                  SizedBox(
                                    height: 36,
                                    child: OutlinedButton(
                                      onPressed:
                                      loadingDistributorId == id
                                          ? null
                                          : () async {
                                        setState(() =>
                                        loadingDistributorId =
                                            id);

                                        await updateProvider
                                            .updateDistributorStatus(
                                          id: id,
                                          status: false,
                                        );

                                        if (updateProvider
                                            .error !=
                                            null) {
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: AutoTranslateText(
                                                  updateProvider
                                                      .error!),
                                            ),
                                          );
                                        } else if (updateProvider
                                            .response !=
                                            null) {
                                          ScaffoldMessenger.of(
                                              context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: AutoTranslateText(
                                                  updateProvider
                                                      .response!
                                                      .message),
                                            ),
                                          );
                                          // Refetch distributor list
                                          await provider
                                              .fetchDistributors(
                                              _userId!);
                                        }

                                        setState(() =>
                                        loadingDistributorId =
                                        null);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                            color: Colors.purple,
                                            width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              20), // circular pill shape
                                        ),
                                        minimumSize: const Size(80, 36),
                                      ),
                                      child: loadingDistributorId == id &&
                                          updateProvider.isLoading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child:
                                        CircularProgressIndicator(
                                          color: Colors.purple,
                                          strokeWidth: 2,
                                        ),
                                      )
                                          : const AutoTranslateText(
                                        "Reject",
                                        style: TextStyle(
                                            color: Colors.purple,
                                            fontWeight:
                                            FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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
  }
}
