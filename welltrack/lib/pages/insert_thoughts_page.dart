import 'package:flutter/material.dart';
import 'package:welltrack/components/main_navigation.dart';

class InsertThoughtsPage extends StatefulWidget {
  final int? originIndex;
  
  const InsertThoughtsPage({super.key, this.originIndex});

  @override
  State<InsertThoughtsPage> createState() => _InsertThoughtsPageState();
}

class _InsertThoughtsPageState extends State<InsertThoughtsPage> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFF9CD0FF);
    const unselectedColor = Colors.black54;
    
    return NonMainPageWrapper(
      originIndex: widget.originIndex,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('journal', style: TextStyle(color: Colors.black)),
          centerTitle: true,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text('16/05', style: TextStyle(color: Colors.black)),
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: StatefulBuilder(
              builder: (context, setStateTab) {
                return TabBar(
                  controller: _tabController,
                  indicator: UnderlineTabIndicator(
                    borderSide: const BorderSide(width: 4.0, color: selectedColor),
                    insets: EdgeInsets.symmetric(
                      horizontal: (MediaQuery.of(context).size.width / 3 - 32) / 2,
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(
                      icon: Icon(
                        Icons.edit,
                        color: _tabController.index == 0 ? selectedColor : unselectedColor,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.camera_alt,
                        color: _tabController.index == 1 ? selectedColor : unselectedColor,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        Icons.graphic_eq,
                        color: _tabController.index == 2 ? selectedColor : unselectedColor,
                      ),
                    ),
                  ],
                  onTap: (index) {
                    setStateTab(() {
                      _tabController.index = index;
                    });
                    setState(() {});
                  },
                );
              },
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Text input
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TextField(
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Insert text here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // Image input
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Take a photo',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 220,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade200,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Choose from gallery',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Audio input (placeholder)
            const Center(
              child: Text(
                'Audio input coming soon...',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 