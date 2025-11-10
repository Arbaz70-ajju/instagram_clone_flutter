// ✅ IMPORTS
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const InstaCloneImproved());
}

class InstaCloneImproved extends StatelessWidget {
  const InstaCloneImproved({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Instagram Lite",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
      ),
      home: const LoginScreen(),
    );
  }
}

// ----------------------------- LOGIN SCREEN -----------------------------
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = TextEditingController();
    final pass = TextEditingController();

    return Scaffold(
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FlutterLogo(size: 70),
                const SizedBox(height: 20),
                Text("Welcome Back!", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                TextField(
                  controller: user,
                  decoration: const InputDecoration(labelText: "Username", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen(username: user.text.trim())),
                    );
                  },
                  child: const Text("Log In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------- HOME SCREEN -----------------------------
class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> profileImages = [];
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  List<Map<String, dynamic>> stories = [
    {"name": "you", "image": "https://picsum.photos/300"},
    {"name": "alex", "image": "https://picsum.photos/450"},
    {"name": "sam", "image": "https://picsum.photos/500"},
    {"name": "john", "image": "https://picsum.photos/550"},
    {"name": "mike", "image": "https://picsum.photos/600"},
  ];

  @override
  void initState() {
    super.initState();

    posts = [
      {
        "username": "arbaaj",
        "image": "https://picsum.photos/500",
        "bytes": null,
        "caption": "Morning vibes ✨",
        "likes": 10,
        "liked": false,
        "comments": ["Awesome!", "🔥 Beautiful shot!"]
      },
      {
        "username": "alex",
        "image": "https://picsum.photos/600",
        "bytes": null,
        "caption": "City walk 🏙️",
        "likes": 30,
        "liked": false,
        "comments": ["Cool 😎", "Nice city vibe!", "👌", "🔥🔥"]
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      FeedScreen(
        stories: stories,
        posts: posts.where((p) => p["caption"].toLowerCase().contains(searchText.toLowerCase())).toList(),
        toggleLike: (i) {
          setState(() {
            posts[i]["liked"] = !posts[i]["liked"];
            posts[i]["likes"] += posts[i]["liked"] ? 1 : -1;
          });
        },
        openComments: (i) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommentScreen(
                post: posts[i],
                onAddComment: (comment) {
                  setState(() {
                    posts[i]["comments"].add(comment);
                  });
                },
              ),
            ),
          );
        },
        openStoryView: (story) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewScreen(story: story)));
        },
        searchBar: searchController,
        onSearchChanged: (value) {
          setState(() => searchText = value);
        },
      ),

      AddPostScreen(
        onPostAdd: (url, bytes, caption) {
          setState(() {
            posts.insert(0, {
              "username": widget.username,
              "image": url,
              "bytes": bytes,
              "caption": caption,
              "likes": 0,
              "liked": false,
              "comments": [],
            });

            profileImages.insert(0, {
              "image": url,
              "bytes": bytes,
            });
          });
        },
      ),

      ProfileScreen(username: widget.username, profileImages: profileImages),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Instagram Lite")),
      body: screens[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Feed"),
          NavigationDestination(icon: Icon(Icons.add), label: "Add"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ----------------------------- STORY VIEW -----------------------------
class StoryViewScreen extends StatelessWidget {
  final Map<String, dynamic> story;
  const StoryViewScreen({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Center(
          child: Image.network(story["image"], fit: BoxFit.contain, width: double.infinity),
        ),
        Positioned(
          top: 40,
          left: 20,
          child: Row(children: [
            CircleAvatar(backgroundImage: NetworkImage(story["image"])),
            const SizedBox(width: 10),
            Text(story["name"], style: const TextStyle(color: Colors.white, fontSize: 20)),
          ]),
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ]),
    );
  }
}

// ----------------------------- FEED SCREEN -----------------------------
class FeedScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stories;
  final List<Map<String, dynamic>> posts;
  final Function(int) toggleLike;
  final Function(int) openComments;
  final Function(Map<String, dynamic>) openStoryView;
  final TextEditingController searchBar;
  final Function(String) onSearchChanged;

  const FeedScreen({
    super.key,
    required this.stories,
    required this.posts,
    required this.toggleLike,
    required this.openComments,
    required this.openStoryView,
    required this.searchBar,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: searchBar,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search posts...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onChanged: onSearchChanged,
          ),
        ),

        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: stories.length,
            itemBuilder: (_, i) {
              final s = stories[i];
              return GestureDetector(
                onTap: () => openStoryView(s),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [Colors.orange, Colors.purple]),
                      ),
                      child: CircleAvatar(radius: 35, backgroundImage: NetworkImage(s["image"])),
                    ),
                    const SizedBox(height: 5),
                    Text(s["name"]),
                  ]),
                ),
              );
            },
          ),
        ),

        ...posts.map((p) {
          int index = posts.indexOf(p);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const CircleAvatar(),
                      title: Text(p["username"]),
                    ),

                    p["bytes"] != null
                        ? Image.memory(p["bytes"], height: 350, fit: BoxFit.cover)
                        : Image.network(p["image"], height: 350, fit: BoxFit.cover),

                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            p["liked"] ? Icons.favorite : Icons.favorite_border,
                            color: p["liked"] ? Colors.red : Colors.black,
                          ),
                          onPressed: () => toggleLike(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline),
                          onPressed: () => openComments(index),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${p['likes']} likes", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(p["caption"]),
                          TextButton(
                            onPressed: () => openComments(index),
                            child: Text("View all ${p["comments"].length} comments"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ----------------------------- COMMENT SCREEN -----------------------------
class CommentScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final Function(String) onAddComment;

  const CommentScreen({super.key, required this.post, required this.onAddComment});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comments")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.post["comments"].length,
              itemBuilder: (_, i) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      const CircleAvatar(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(widget.post["comments"][i]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.trim().isNotEmpty) {
                      widget.onAddComment(textController.text.trim());
                      textController.clear();
                      setState(() {});
                    }
                  },
                  child: const Text("Post"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------------------- ADD POST SCREEN -----------------------------
class AddPostScreen extends StatefulWidget {
  final Function(String?, Uint8List?, String) onPostAdd;

  const AddPostScreen({super.key, required this.onPostAdd});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final url = TextEditingController();
  final caption = TextEditingController();
  Uint8List? pickedImageBytes;
  String? pickedUrl;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.image),
            label: const Text("Pick Image"),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
              if (result != null && result.files.first.bytes != null) {
                setState(() {
                  pickedImageBytes = result.files.first.bytes;
                  pickedUrl = null;
                });
              }
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: url,
              decoration: const InputDecoration(labelText: "Enter image URL", border: OutlineInputBorder()),
            ),
          ),
        ]),

        const SizedBox(height: 15),

        ElevatedButton(
          onPressed: () {
            if (url.text.trim().isNotEmpty) {
              setState(() {
                pickedUrl = url.text.trim();
                pickedImageBytes = null;
              });
            }
          },
          child: const Text("Use URL"),
        ),

        const SizedBox(height: 20),

        if (pickedImageBytes != null)
          Image.memory(pickedImageBytes!, height: 250, fit: BoxFit.cover),
        if (pickedUrl != null)
          Image.network(pickedUrl!, height: 250, fit: BoxFit.cover),

        const SizedBox(height: 20),
        TextField(
          controller: caption,
          maxLines: 2,
          decoration: const InputDecoration(labelText: "Caption", border: OutlineInputBorder()),
        ),

        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if ((pickedUrl != null || pickedImageBytes != null) && caption.text.isNotEmpty) {
              widget.onPostAdd(pickedUrl, pickedImageBytes, caption.text.trim());
              url.clear();
              caption.clear();
              pickedUrl = null;
              pickedImageBytes = null;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post Added ✅")));
            }
          },
          child: const Text("Add Post"),
        ),
      ]),
    );
  }
}

// ----------------------------- PROFILE SCREEN -----------------------------
class ProfileScreen extends StatelessWidget {
  final String username;
  final List<Map<String, dynamic>> profileImages;

  const ProfileScreen({super.key, required this.username, required this.profileImages});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 20),
      const CircleAvatar(radius: 45, backgroundImage: NetworkImage("https://picsum.photos/200")),
      const SizedBox(height: 10),
      Text("@you", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      Expanded(
        child: GridView.builder(
          itemCount: profileImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
          ),
          itemBuilder: (_, i) {
            var img = profileImages[i];
            return img["bytes"] != null
                ? Image.memory(img["bytes"], fit: BoxFit.cover)
                : Image.network(img["image"], fit: BoxFit.cover);
          },
        ),
      ),
    ]);
  }
}
