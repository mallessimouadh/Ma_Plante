import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';
import '../screens/saved_posts_screen.dart';
import '../screens/create_post_screen.dart';

class CommunityChatScreen extends StatefulWidget {
  const CommunityChatScreen({Key? key}) : super(key: key);

  @override
  _CommunityChatScreenState createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isSearching = false;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final posts = _isSearching
        ? postProvider.posts
            .where((post) =>
                post.content
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                post.userName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
            .toList()
        : postProvider.posts;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search plant community...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.green[300]),
                ),
                style: const TextStyle(color: Colors.green),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text(
                "Plant Community",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFF2E7D32),
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = "";
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: Color(0xFF2E7D32),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SavedPostsScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          tabs: const [
            Tab(text: "Recent"),
            Tab(text: "Popular"),
          ],
        ),
      ),
      body: postProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                posts.isEmpty
                    ? const Center(
                        child: Text("No posts yet. Be the first to share!"),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF2E7D32),
                        onRefresh: () async {
                          await postProvider.fetchPosts();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(post: posts[index]);
                          },
                        ),
                      ),
                posts.isEmpty
                    ? const Center(
                        child: Text("No posts yet. Be the first to share!"),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF2E7D32),
                        onRefresh: () async {
                          await postProvider.fetchPosts();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final sortedPosts = List<Post>.from(posts)
                              ..sort((a, b) =>
                                  b.likes.length.compareTo(a.likes.length));
                            return PostCard(post: sortedPosts[index]);
                          },
                        ),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
      ),
    );
  }
}
