import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/host_request_service.dart';
import '../home/host_dashboard.dart';
import 'create_owner_account_screen.dart';

const Color _kBackground = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1F1B1B);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroonStart = Color(0xFF7A1F35);
const Color _kMaroonEnd = Color(0xFF4E1220);
const Color _kMutedText = Color(0xFF9E9E9E);
const Color _kBorder = Color(0xFF2E2929);
const Color _kSuccess = Color(0xFF2ECC71);
const Color _kWarning = Color(0xFFF39C12);
const Color _kDanger = Color(0xFFE74C3C);

class HostRequestStatusScreen extends StatefulWidget {
  final HostRequest? request;

  const HostRequestStatusScreen({super.key, this.request});

  @override
  State<HostRequestStatusScreen> createState() =>
      _HostRequestStatusScreenState();
}

class _HostRequestStatusScreenState extends State<HostRequestStatusScreen> {
  HostRequest? _request;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    setState(() => _isLoading = true);
    final latest = await HostRequestService.getLatestRequestForCurrentUser();
    if (mounted) {
      setState(() {
        if (latest != null) {
          _request = latest;
        }
        _isLoading = false;
      });
    }
  }

  void _proceedToHostDashboard() async {
    if (_request != null) {
      await HostRequestService.markCongratsAcknowledged(_request!.id);
    }
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HostDashboard()),
      (route) => false,
    );
  }

  void _reapply() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CreateOwnerAccountScreen(initialRequest: _request),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _kBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_kGold),
          ),
        ),
      );
    }

    if (_request == null) {
      return Scaffold(
        backgroundColor: _kBackground,
        appBar: AppBar(
          backgroundColor: _kBackground,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: _kGold, size: 50),
                const SizedBox(height: 16),
                const Text(
                  'No Host Application Found',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have not submitted a request to become a host yet.',
                  style: TextStyle(color: _kMutedText, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const CreateOwnerAccountScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: _kBackground,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Create Owner Account',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final status = _request!.status.toLowerCase();

    return Scaffold(
      backgroundColor: _kBackground,
      appBar: AppBar(
        backgroundColor: _kBackground,
        elevation: 0,
        title: Text(
          status == 'approved'
              ? 'Host Approved'
              : status == 'rejected'
                  ? 'Request Rejected'
                  : 'Approval Status',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh, color: _kGold),
            onPressed: _refreshStatus,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            if (status == 'approved')
              _buildApprovedView()
            else if (status == 'rejected')
              _buildRejectedView()
            else
              _buildPendingView(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 1. PENDING STATE: "Wait for admin approval"
  Widget _buildPendingView() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Animated/Glowing Hourglass icon
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kWarning.withOpacity(0.12),
            border: Border.all(color: _kWarning.withOpacity(0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: _kWarning.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            color: _kWarning,
            size: 46,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Wait for Admin Approval',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _kWarning.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kWarning.withOpacity(0.5)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pending_actions_rounded, color: _kWarning, size: 16),
              SizedBox(width: 6),
              Text(
                'Request Under Review',
                style: TextStyle(
                  color: _kWarning,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Aap ki host banne ki darkhwast aur room details admin ko bhej di gayi hain. Barah-e-karam approval ka intizar karein.',
          style: TextStyle(color: _kMutedText, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Application Summary Card
        _buildApplicationSummaryCard(),
        const SizedBox(height: 24),

        // Refresh / Check Status Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _refreshStatus,
            icon: const Icon(Icons.sync_rounded),
            label: const Text(
              'Check Admin Approval Status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGold,
              foregroundColor: _kBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Profile'),
          ),
        ),
      ],
    );
  }

  // 2. APPROVED STATE: "Congratulations you become host" -> Host Screen
  Widget _buildApprovedView() {
    return Column(
      children: [
        const SizedBox(height: 10),
        // Celebratory Trophy Container
        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kSuccess.withOpacity(0.15),
            border: Border.all(color: _kSuccess, width: 2),
            boxShadow: [
              BoxShadow(
                color: _kSuccess.withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: _kSuccess,
            size: 52,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Congratulations!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _kGoldLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        const Text(
          'You Have Become a Host',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _kSuccess.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kSuccess.withOpacity(0.5)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded, color: _kSuccess, size: 16),
              SizedBox(width: 6),
              Text(
                'Admin Accepted Your Request',
                style: TextStyle(
                  color: _kSuccess,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Admin ne aap ki darkhwast accept kar li hai. Aap ka account Host me convert ho gaya hai aur aap ka room publicly live ho chuka hai.',
          style: TextStyle(color: _kMutedText, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Host Features Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_kMaroonStart, _kMaroonEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kGold.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.stars_rounded, color: _kGold, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Host Privileges Activated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFeatureBullet('Manage and post multiple room listings'),
              _buildFeatureBullet('Receive renter booking & room requests'),
              _buildFeatureBullet('Track views, saves & tenant inquiries'),
              _buildFeatureBullet('Chat directly with potential roommates'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Go to Host Screen Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _proceedToHostDashboard,
            icon: const Icon(Icons.dashboard_rounded, size: 20),
            label: const Text(
              'Go to Host Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGold,
              foregroundColor: _kBackground,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Profile'),
          ),
        ),
      ],
    );
  }

  // 3. REJECTED STATE: "Admin rejected"
  Widget _buildRejectedView() {
    final reason = _request!.rejectionReason ??
        'Room details or room pictures were incomplete.';

    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kDanger.withOpacity(0.12),
            border: Border.all(color: _kDanger.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: _kDanger.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.cancel_rounded,
            color: _kDanger,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Admin Rejected Your Request',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _kDanger.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kDanger.withOpacity(0.5)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: _kDanger, size: 16),
              SizedBox(width: 6),
              Text(
                'Application Declined',
                style: TextStyle(
                  color: _kDanger,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Admin ne aap ki host request reject kar di hai. Neeche di gayi wajah dekh kar apni details ya room pics update kar ke dobara apply karein.',
          style: TextStyle(color: _kMutedText, fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Rejection Reason Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kDanger.withOpacity(0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.report_problem_outlined,
                      color: _kDanger, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Rejection Reason by Admin:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  reason,
                  style: const TextStyle(
                    color: Color(0xFFFFB3B3),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Re-Apply Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _reapply,
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: const Text(
              'Edit Details & Apply Again',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGold,
              foregroundColor: _kBackground,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Back to Profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationSummaryCard() {
    final req = _request!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, color: _kGold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Submitted Room Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                req.submittedAt,
                style: const TextStyle(color: _kMutedText, fontSize: 11),
              ),
            ],
          ),
          const Divider(color: _kBorder, height: 20),
          _buildSummaryRow('Room Title', req.roomTitle),
          _buildSummaryRow('Location', '${req.area}, ${req.city}'),
          _buildSummaryRow('Room Type', req.roomType),
          _buildSummaryRow(
              'Rent', 'PKR ${req.rent.toString()} / Month'),
          _buildSummaryRow('Owner Name', req.ownerName),
          _buildSummaryRow('Phone', req.phone),
          _buildSummaryRow('Room Pics', '${req.roomImages.length} photo(s) attached'),
          if (req.roomImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 70,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: req.roomImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildSmallThumb(req.roomImages[i], 70, 70),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: _kMutedText, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: _kGoldLight, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallThumb(String source, double width, double height) {
    if (source.startsWith('data:image')) {
      final base64Part = source.split(',').last;
      return Image.memory(
        base64Decode(base64Part),
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    if (source.startsWith('http')) {
      return Image.network(
        source,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: _kSurface,
          child: const Icon(Icons.image, color: _kMutedText),
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      color: _kSurface,
      child: const Icon(Icons.image, color: _kMutedText),
    );
  }
}

