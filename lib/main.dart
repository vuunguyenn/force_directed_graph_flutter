// ignore_for_file: avoid_print
import 'package:example/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Force Directed Graph Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Force Directed Graph Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imgEthereum = 'assets/images/ethereum.jpeg';
  String imgDogcoin = 'assets/images/dogcoin.jpeg';
  late final ForceDirectedGraphController<Data> _controller =
      ForceDirectedGraphController(
    graph: ForceDirectedGraph.generateNTree(
      nodeCount: 50,
      maxDepth: 3,
      n: 4,
      generator: () {
        Data data = Data(
            id: _nodeCount,
            image: _nodeCount % 2 == 0 ? imgDogcoin : imgEthereum,
            name: _nodeCount % 2 == 0 ? 'Dogcoin' : 'Ethereum');
        _nodeCount++;
        return data;
      },
    ),
  );

  int _nodeCount = 0;
  Data _node = Data(id: -1, image: '', name: '');
  final Set<String> _edges = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.needUpdate();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: ForceDirectedGraphWidget(
              controller: _controller,
              nodesBuilder: (context, data) {
                final Color color;
                if (data == _node) {
                  color = Colors.green;
                } else {
                  color = Colors.red;
                }
                return GestureDetector(
                  onTap: () {
                    if (_node.id == data.id) return;
                    setState(() {
                      _node = data;
                    });
                    ;
                  },
                  child: AnimatedContainer(
                    key: ValueKey(data),
                    width: _node.id == data.id ? 60 : 50,
                    height: _node.id == data.id ? 60 : 50,
                    decoration: BoxDecoration(
                        color: Colors.transparent.withOpacity(1),
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: 2,
                            color: _node.id == data.id
                                ? Colors.red
                                : Colors.grey)),
                    alignment: Alignment.center,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                        margin: const EdgeInsets.all(5),
                        decoration:
                            BoxDecoration(shape: BoxShape.circle, color: color),
                        child: ClipOval(
                          child: SizedBox.fromSize(
                            size: const Size.fromRadius(48),
                            child: Image.asset(
                              data.image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
                  ),
                );
              },
              edgesBuilder: (context, a, b, distance) {
                final Color color;
                if (_node.id == a.id || _node.id == b.id) {
                  color = Colors.green;
                } else {
                  color = Colors.grey;
                }
                return GestureDetector(
                  onTap: () {
                    final edge = "$a <-> $b";
                    setState(() {
                      if (_edges.contains(edge)) {
                        _edges.remove(edge);
                      } else {
                        _edges.add(edge);
                      }
                    });
                  },
                  child: Container(
                    width: distance,
                    height: 3,
                    color: color,
                    alignment: Alignment.center,
                  ),
                );
              },
            ),
          ),
          _node.id != -1
              ? _buildMenu(context)
              : const SizedBox(
                  height: 50,
                  child: Text('No data'),
                ),
          const SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Wrap(
          children: [
            ElevatedButton(
              onPressed: () {
                var data = Data(
                    id: _nodeCount,
                    image: _nodeCount % 2 == 0 ? imgDogcoin : imgEthereum,
                    name: _nodeCount % 2 == 0 ? 'Dogcoin' : 'Ethereum');
                _controller.addNode(data);
                if (_node.id != -1) {
                  _controller.addEdgeByData(_node, data);
                }
                _nodeCount++;
                _edges.clear();
              },
              child: const Text('Add node'),
            ),
            const SizedBox(
              width: 25,
            ),
            ElevatedButton(
              onPressed: _node.id == -1
                  ? null
                  : () {
                      _controller.deleteNodeByData(_node);
                      _edges.clear();
                    },
              child: const Text('Del node'),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Image.asset(
              _node.image,
              height: 40,
            ),
            const SizedBox(
              width: 30,
            ),
            Text("Name: ${_node.name}"),
          ],
        )
      ],
    );
  }
}
