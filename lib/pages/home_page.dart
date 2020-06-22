import 'dart:async';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

int level = 6;
int actualLevel = 1;

class Home extends StatefulWidget {
  final int size;

  const Home({Key key, this.size = 8}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<GlobalKey<FlipCardState>> cardStateKeys = [];
  List<bool> cardsEscondidos = [];
  List<String> data = [];
  int cardAnterior = -1;
  bool flip = false;

  int tempo = 0;
  Timer timer;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.size; i++) {
      cardStateKeys.add(GlobalKey<FlipCardState>());
      cardsEscondidos.add(true);
    }
    // Cria linhas com itens iguais, por isso dos dois fors
    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }
    for (var i = 0; i < widget.size ~/ 2; i++) {
      data.add(i.toString());
    }
    startTimer();
    // Embaralha todos os itens da lista
    data.shuffle();
  }

  startTimer() {
    // Inicia o temporizador
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        tempo++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "Nível atual: $actualLevel ",
                    style: TextStyle(
                      fontSize: 36.0,
                    ),
                  ),
                ),
              ),
              Theme(
                data: ThemeData.dark(),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemBuilder: (context, index) => FlipCard(
                      key: cardStateKeys[index],
                      onFlip: () {
                        if (!flip) {
                          flip = true;
                          cardAnterior = index;
                        } else {
                          flip = false;
                          if (cardAnterior != index) {
                            if (data[cardAnterior] == data[index]) {
                              // Caso seja a mesma, então desabilita a mesma
                              cardsEscondidos[cardAnterior] = false;
                              cardsEscondidos[index] = false;
                              // Se todos os itens foram feitos
                              if (cardsEscondidos.every((t) => !t)) {
                                _mostraResultado();
                              }
                            } else {
                              // Se não for a carta selecionada, gira a carta anterior
                              cardStateKeys[cardAnterior]
                                  .currentState
                                  .toggleCard();
                              cardAnterior = index;
                            }
                          }
                        }
                      },
                      direction: FlipDirection.HORIZONTAL,
                      // Habilita somente caso a carta não esteja com o valor de true
                      flipOnTouch: cardsEscondidos[index],
                      front: Container(
                        margin: EdgeInsets.all(2.0),
                        color: Colors.green[200],
                      ),
                      back: Container(
                        margin: EdgeInsets.all(2.0),
                        color: Colors.green,
                        child: Center(
                          child: Text(
                            "${data[index]}",
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    itemCount: data.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _mostraResultado() {
    // Abre um modal com o resultado
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          "Parabéns, você completou o nível $actualLevel!!!",
          style: TextStyle(
            fontSize: 14.0,
          ),
        ),
        content: Text(
          "Tempo: $tempo",
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Home(
                    size: level,
                  ),
                ),
              );
              // Multiplica o numero de cartas por nivel
              level *= 2;
              actualLevel++;
            },
            child: Text("Proximo nível!"),
          ),
        ],
      ),
    );
  }
}
