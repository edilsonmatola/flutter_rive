import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Artboard do arquivo que contém o "desenho" do .riv
  Artboard? _artboard;

  /* Controladores para as animações. Deixei estes nomes para ficar algo mais genérico.
  Foram declarados dois controladores porque pretendemos usar duas animações.
  Se fôssemos utilizar apenas 1 animação, poderíamos utilizar um único RiveAnimationController*/
  RiveAnimationController? _animation1Controller;
  RiveAnimationController? _animation2Controller;

  // Variável para especificar o estado de play/pause
  bool _isPlaying = true;

  /* Variáveis adicionais para guardar o último estado de cada animação.
  Como pretendo que a animação 1 comece ativa, declarei as variáveis já inicializadas */
  bool _lastAnimation1State = true;
  bool _lastAnimation2State = false;

  @override
  void initState() {
    super.initState();
    // Carregamento do arquivo desejado
    rootBundle.load('animations/animgears.riv').then((data) async {
      /* O resultado do arquivo de carregamento é em ByteData.
      Aqui transformamos este resultado em RiveFile */
      final file = RiveFile.import(data);

      // Aqui criamos os controllers com os respectivos nomes das animações que desejamos usar
      _animation1Controller = SimpleAnimation('spin1');
      _animation2Controller = SimpleAnimation('spin2');

      /* Aqui nos extraimos os dados da "prancheta" que contém nosso elemento gráfico
      e associamos os controllers
      Aproveitei o operador 'cascata' para adicionar as animações ao artboard de forma mais rápida
      Recomendo que a animação a ser executada primeira seja associada por último,
      pois a animação da última associação fica como sendo a "padrão"*/
      final artboard = file.mainArtboard
        ..addController(_animation2Controller!)
        ..addController(_animation1Controller!);

      // Aqui atualizamos a variável da classe com um setState para que a tela seja reconstruida.
      setState(() {
        _artboard = artboard;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            /* Esta condicional visa permitir a troca da animação somente se o "play" estiver ativo.
            Caso esteja em "pause", nada acontece. */
            if (_isPlaying) {
              setState(() {
                /* Como no momento o controle das animações é mais "manual", para alternarmos as animações
                precisamos de fato desativar uma e ativar a outra. Portanto, apenas atribui a cada animação
                o valor oposto ao atual atraves do operador de "negação" */
                _animation1Controller!.isActive =
                    !_animation1Controller!.isActive;
                _animation2Controller!.isActive =
                    !_animation2Controller!.isActive;

                // Após alternar o estado de cada controller, atualizamos as variáveis de apoio também
                _lastAnimation1State = _animation1Controller!.isActive;
                _lastAnimation2State = _animation2Controller!.isActive;
              });
            }
          },
          child: Container(
            width: 150,
            height: 150,
            // Como o _artboard começa nulo, precisamos fazer esta verificação para não quebrarmos a aplicação
            child: _artboard == null
                ? const SizedBox.shrink()
                /* Depois de carregado o _artboard, basta utilizarmos o widget Rive passando sua referência
                Atenção ao detalhe de que o "!" aqui não é o operador de negação, e sim o operador que diz
                que _artboard certamente não será null */
                : Rive(artboard: _artboard!),
          ),
        ),
      ),
      // Código do botão que fará a alternância play/pause
      floatingActionButton: FloatingActionButton(
        // Lógica para trocar o ícone de acordo com o modo
        child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
        onPressed: () {
          setState(() {
            if (_isPlaying) {
              // Ativação do "pause"
              _animation1Controller!.isActive = false;
              _animation2Controller!.isActive = false;
            } else {
              // Ativação do play (retorno ao estado anterior das animações)
              _animation1Controller!.isActive = _lastAnimation1State;
              _animation2Controller!.isActive = _lastAnimation2State;
            }
            // Alternância entre true/false para o "_isPlaying"
            _isPlaying = !_isPlaying;
          });
        },
      ),
    );
  }
}
