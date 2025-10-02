import 'package:flutter/material.dart';
import 'plant2.dart'; // Make sure this includes DedicationAndPaymentPage

class Tree {
  final String id;
  final String name;
  final String description;
  final int priceCents;
  final String imageUrl;

  const Tree({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.imageUrl,
  });
}

class TreeSelectionPage extends StatefulWidget {
  const TreeSelectionPage({super.key});

  @override
  State<TreeSelectionPage> createState() => _TreeSelectionPageState();
}

class _TreeSelectionPageState extends State<TreeSelectionPage> {
  int? selectedIndex;

  final List<Tree> trees = [
    Tree(
      id: "sidra",
      name: "Sidra",
      priceCents: 5000, // 50 QAR
      description:
      "A resilient tree native to Qatar's desert, symbolizing endurance and strength.",
      imageUrl:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuBMQnglH0lYH4mFf_57emYkMovzO-RGCdiq5JmgEVkPlkI8aROeiHo9ZbRn5X4XTB95FLZIZZ7tcp2qpuU3qhvr92NUL8hAIRZTbzTId2rLkyqH6ND9UUbeq2Aztm60vFRM-YQaYbEwO0SyVClvRd0REZgPSK0WKsZCAx6ScW6FxyuqTC3LiofIM9KHXc0EGn61I_VTtKjUilVmrAn70hB6hQBArwi_cfDEKR2I20glQi6bw9IO2MlRSWU-LWlhEmuoBejCy4hSxge_",
    ),
    Tree(
      id: "ghaf",
      name: "Ghaf",
      priceCents: 5000,
      description:
      "A drought-tolerant tree revered for its role in sustainable desert ecosystems.",
      imageUrl:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuBTU1o1qOq2JNfDB_8KTBCJGhm8S5d5fSb9hmlmuooY2vy0-8y5XELlflJG-Fekhm-1OIW3YW_veYeoEt82KpN1W04JSNrNmkblTdkSGDvxLTeJcAzH3EaVnwVuP77xfY76JTBvFtwY8ZhznI72Ij9kCQeP43hC2cdhtJWRLdOT-Op08J8UIcnbF-s5efscLTIkpecI11rVqA96oShJkwyik2eofmNZL77R-EGCpr-5ZyfHjRLvtpxhIwi67GAuI53biMCdLq5UJ3__",
    ),
    Tree(
      id: "palm",
      name: "Palm",
      priceCents: 5000,
      description:
      "An iconic tree offering shade and fruit, integral to the local heritage.",
      imageUrl:
      "https://lh3.googleusercontent.com/aida-public/AB6AXuCm8-hy5zjAqjiUz8R15k0MbY7hZxUTKwFon-v3vwi0rQ0aytFTYeJsNSLRa4A3LwTr4g23Tp_lqPdm0b3UTSJo93Bo_I1oqFl8R31IKNaqxI90rnWMOiVT4KhHM_nAY7GsZSJat4RXDNGoVGjyKtELvCsbgiCUdlsG39XI-tfoTjVJJF-SS7VAP4emKmJJU_kvnAz3vFa1pQ7BwXQP2tBkD01RRNR43m2PBHY4DkKDQYRro3jz_LoxJlW4j4CxsD0cX-YVWViGsJCB",
    ),
  ];

  String formatPrice(int cents) => "${(cents / 100).toStringAsFixed(0)} QAR/tree";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Plant a Tree"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            "Choose a Tree",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff0c1c17),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(trees.length, (index) {
            final tree = trees[index];
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => setState(() => selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xffe6f4ef) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tree.name,
                                style: const TextStyle(
                                  color: Color(0xff46a080),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                )),
                            const SizedBox(height: 4),
                            Text(formatPrice(tree.priceCents),
                                style: const TextStyle(
                                  color: Color(0xff0c1c17),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 6),
                            Text(tree.description,
                                style: const TextStyle(
                                  color: Color(0xff46a080),
                                  fontSize: 13,
                                  height: 1.4,
                                )),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Image.network(
                            tree.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: selectedIndex != null
                ? () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DedicationAndPaymentPage(
                  selectedTree: trees[selectedIndex!],
                ),
              ),
            )
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff46a080),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
            ),
            child: const Text(
              "Continue",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}