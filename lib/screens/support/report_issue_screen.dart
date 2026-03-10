import 'package:flutter/material.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  // Variable to store the currently selected issue
  String _selectedIssue = "";

  void _handleSelection(String issue) {
    setState(() {
      _selectedIssue = issue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Report Issue")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("WHAT'S WRONG?", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _IssueChip(label: "Bug / Crash", isSelected: _selectedIssue == "Bug / Crash", onTap: () => _handleSelection("Bug / Crash"))),
                const SizedBox(width: 10),
                Expanded(child: _IssueChip(label: "Order Issue", isSelected: _selectedIssue == "Order Issue", onTap: () => _handleSelection("Order Issue"))),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _IssueChip(label: "Product Defect", isSelected: _selectedIssue == "Product Defect", onTap: () => _handleSelection("Product Defect"))),
                const SizedBox(width: 10),
                Expanded(child: _IssueChip(label: "Other", isSelected: _selectedIssue == "Other", onTap: () => _handleSelection("Other"))),
              ],
            ),
            const SizedBox(height: 30),
            const Text("DETAILS", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            const TextField(maxLines: 5, decoration: InputDecoration(hintText: "Please describe the issue in detail...")),
            const SizedBox(height: 30),
            const Text("SCREENSHOTS (OPTIONAL)", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.camera_alt, color: Colors.grey), Text("ADD", style: TextStyle(fontSize: 10, color: Colors.grey))])),
            const Spacer(),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Submit Report"), SizedBox(width: 8), Icon(Icons.send, size: 16)])
                )
            )
          ],
        ),
      ),
    );
  }
}

class _IssueChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IssueChip({
    required this.label,
    required this.isSelected,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8C44FF).withOpacity(0.2) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: const Color(0xFF8C44FF)) : Border.all(color: Colors.transparent),
        ),
        child: Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF8C44FF) : Colors.grey
            )
        ),
      ),
    );
  }
}